/*
 * Copyright (c) 2014 Goran Ehrsson.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package grails.plugins.crm.task

import grails.plugins.crm.contact.CrmContact
import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.dao.DataIntegrityViolationException
import grails.converters.JSON
import grails.plugins.crm.core.WebUtils
import grails.plugins.crm.core.SearchUtils
import org.springframework.web.servlet.support.RequestContextUtils

import javax.servlet.http.HttpServletResponse
import java.text.DateFormat
import java.util.concurrent.TimeoutException

class CrmTaskController {

    static allowedMethods = [list: ['GET', 'POST'], create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST', attender: ['GET', 'POST']]

    def grailsApplication
    def crmCoreService
    def crmSecurityService
    def crmTaskService
    def selectionService
    def userTagService
    def crmContactService

    private String createValidationErrorMessage(Object domainInstance) {
        final List<String> errors = []
        eachError(bean: domainInstance) {
            errors << message(error: it)
        }
        errors.join('\n')
    }

    def index() {
        // If any query parameters are specified in the URL, let them override the last query stored in session.
        def cmd = new CrmTaskQueryCommand()
        def query = params.getSelectionQuery()
        bindData(cmd, query ?: WebUtils.getTenantData(request, 'crmTaskQuery'))
        [cmd: cmd, useAttenders: grailsApplication.config.crm.task.attenders.enabled]
    }

    def list() {
        def baseURI = new URI('bean://crmTaskService/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                WebUtils.setTenantData(request, 'crmTaskQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 10, 100)

        def result
        try {
            result = selectionService.select(uri, params)
            if (result.totalCount == 1 && params.view != 'list') {
                redirect action: "show", params: selectionService.createSelectionParameters(uri) + [id: result.head().ident()]
            } else {
                [crmTaskList: result, crmTaskTotal: result.totalCount, selection: uri]
            }
        } catch (Exception e) {
            log.error("Selection failed: $uri", e)
            flash.error = e.message
            [crmTaskList: [], crmTaskTotal: 0, selection: uri]
        }
    }

    def clearQuery() {
        WebUtils.setTenantData(request, 'crmTaskQuery', null)
        redirect(action: "index")
    }

    def print() {
        if (!params.report) {
            params.report = 'list'
        }
        def user = crmSecurityService.currentUser
        def tempFile = event(for: "crmTask", topic: "print", data: params + [user: user, tenant: TenantUtils.tenant]).waitFor(60000)?.value
        if (tempFile instanceof File) {
            try {
                def entityName = message(code: 'crmTask.label', default: 'Task')
                def filename = message(code: 'crmTask.' + params.report + '.label', default: 'Task ' + params.report, args: [entityName]) + '.pdf'
                WebUtils.inlineHeaders(response, "application/pdf", filename)
                WebUtils.renderFile(response, tempFile)
            } finally {
                tempFile.delete()
            }
            return null // Success
        } else if (tempFile) {
            log.error("Print event returned an unexpected value: $tempFile (${tempFile.class.name})")
            flash.error = message(code: 'crmTask.print.error.message', default: 'Printing failed due to an error', args: [tempFile.class.name])
        } else {
            flash.warning = message(code: 'crmTask.print.nothing.message', default: 'Nothing was printed')
        }
        redirect(action: "index") // error condition, return to search form.
    }

    def export() {
        def user = crmSecurityService.getUserInfo()
        if (request.post) {
            def filename = message(code: 'crmTask.label', default: 'Task')
            try {
                def namespace = params.namespace ?: 'crmTask'
                def topic = params.topic ?: 'export'
                def result = event(for: namespace, topic: topic,
                        data: params + [user: user, tenant: TenantUtils.tenant, locale: request.locale, filename: filename]).waitFor(60000)?.value
                if (result?.file) {
                    try {
                        WebUtils.inlineHeaders(response, result.contentType, result.filename ?: namespace)
                        WebUtils.renderFile(response, result.file)
                    } finally {
                        result.file.delete()
                    }
                    return null // Success
                } else {
                    flash.warning = message(code: 'crmTask.export.nothing.message', default: 'Nothing was exported')
                }
            } catch (TimeoutException te) {
                flash.error = message(code: 'crmTask.export.timeout.message', default: 'Export did not complete')
            } catch (Exception e) {
                log.error("Export event throwed an exception", e)
                flash.error = message(code: 'crmTask.export.error.message', default: 'Export failed due to an error', args: [e.message])
            }
            redirect(action: "index")
        } else {
            def uri = params.getSelectionURI()
            def layouts = event(for: 'crmTask', topic: 'exportLayout',
                    data: [tenant: TenantUtils.tenant, username: user.username, uri: uri]).waitFor(10000)?.values
            [layouts: layouts, selection: uri]
        }
    }

    private boolean checkPrerequisites() {
        if (crmTaskService.listTaskTypes().isEmpty()) {
            flash.warning = message(code: 'crmTaskType.lookup.empty.message', args: [message(code: 'crmTaskType.label', default: 'Task Type')])
            return false
        }
        return true
    }

    def create() {
        def startDate = params.remove('startDate') ?: formatDate(type: 'date', date: new Date() + 1)
        def endDate = params.remove('endDate') ?: startDate
        def startTime = params.remove('startTime') ?: '09:00'
        def endTime = params.remove('endTime') ?: '10:00'
        def user = crmSecurityService.getUserInfo(params.username)
        if (!params.username) {
            params.username = user?.username
        }
        if (params.priority == null) {
            params.priority = CrmTask.PRIORITY_NORMAL
        }
        if (params.complete == null) {
            params.complete = CrmTask.STATUS_PLANNED
        }
        if (params.busy == null) {
            params.busy = 'true'
        }
        def crmTask = crmTaskService.createTask(params)
        def typeList = crmTaskService.listTaskTypes()
        def userList = crmSecurityService.getTenantUsers()
        def timeList = (0..23).inject([]) { list, h -> 4.times { list << String.format("%02d:%02d", h, it * 15) }; list }
        if(crmTask.startTime) {
            def hm = crmTask.startTime.format("HH:mm")
            if(! timeList.contains(hm)) {
                timeList << hm
            }
        }
        if(crmTask.endTime) {
            def hm = crmTask.endTime.format("HH:mm")
            if(! timeList.contains(hm)) {
                timeList << hm
            }
        }
        timeList = timeList.sort()

        def metadata = [:]
        metadata.locale = RequestContextUtils.getLocale(request)
        metadata.dateFormat = DateFormat.getDateInstance(DateFormat.SHORT, metadata.locale)
        metadata.typeList = typeList
        metadata.userList = userList
        metadata.timeList = timeList

        switch (request.method) {
            case 'GET':
                if (!checkPrerequisites()) {
                    redirect(mapping: 'crmTask.welcome')
                    return
                }
                setReference(crmTask, params.ref)
                bindDate(crmTask, 'startTime', startDate + ' ' + startTime, user?.timezone)
                bindDate(crmTask, 'endTime', endDate + ' ' + endTime, user?.timezone)
                crmTask.clearErrors()
                return [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
            case 'POST':
                try {
                    setReference(crmTask, params.ref)
                    bindDate(crmTask, 'startTime', startDate + startTime, user?.timezone)
                    bindDate(crmTask, 'endTime', endDate + endTime, user?.timezone)

                    if (crmTask.hasErrors() || !crmTask.save()) {
                        render view: 'create', model: [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
                        return
                    }
                    flash.success = message(code: 'crmTask.created.message', args: [message(code: 'crmTask.label', default: 'Task'), crmTask.toString()])
                    if (params.referer) {
                        redirect(uri: params.referer - request.contextPath)
                    } else {
                        redirect action: 'show', id: crmTask.id
                    }
                } catch (Exception e) {
                    log.error("error", e)
                    flash.error = e.message
                    render view: 'create', model: [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
                }
                break
        }
    }

    private void setReference(object, ref) {
        if (ref) {
            def reference = crmCoreService.getReference(ref)
            if (reference) {
                if (reference.hasProperty('tenantId') && (reference.tenantId == TenantUtils.tenant)) {
                    object.reference = reference
                }
            } else {
                log.warn("User [${crmSecurityService.currentUser?.username}] in tenant [${TenantUtils.tenant}] tried to set invalid reference [${ref}] on [${object.class.name}]")
            }
        } else {
            object.reference = null
        }
    }

    def guessReference(String text) {
        def future = event(for: "crm", topic: "guessReference", data: [text: text, user: crmSecurityService.currentUser,
                tenant: TenantUtils.tenant, locale: request.locale]).waitFor(5000)
        def list = future.values.flatten()
        def result = [q: text, timestamp: System.currentTimeMillis(), length: list.size(), more: false, results: list]
        WebUtils.shortCache(response)
        render result as JSON
    }

    private void bindDate(CrmTask crmTask, String property, String value, TimeZone timezone = null) {
        if (value) {
            try {
                crmTask[property] = DateUtils.parseDateTime(value, timezone ?: TimeZone.default)
            } catch (Exception e) {
                log.error("error", e)
                def entityName = message(code: 'crmTask.label', default: 'Task')
                def propertyName = message(code: 'crmTask.' + property + '.label', default: property)
                crmTask.errors.rejectValue(property, 'default.invalid.date.message', [propertyName, entityName, value.toString(), e.message].toArray(), "Invalid date: {2}")
            }
        } else {
            crmTask[property] = null
        }
    }

    def show() {
        def crmTask = CrmTask.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmTask) {
            flash.error = message(code: 'crmTask.not.found.message', args: [message(code: 'crmTask.label', default: 'Agreement'), params.id])
            redirect action: 'index'
            return
        }

        def attenders
        def recent
        if (grailsApplication.config.crm.task.attenders.enabled) {
            attenders = CrmTaskAttender.createCriteria().list(params) {
                eq('task', crmTask)
            }
            recent = CrmTaskAttender.createCriteria().list([max:5, sort: 'bookingDate', order: 'desc']) {
                eq('task', crmTask)
            }
        }
        [crmTask: crmTask, statusList: CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId),
                attenders: attenders, recentBooked: recent, selection: params.getSelectionURI()]
    }

    def edit() {
        def tenant = TenantUtils.tenant
        def crmTask = CrmTask.findByIdAndTenantId(params.id, tenant)
        if (!crmTask) {
            flash.error = message(code: 'crmTask.not.found.message', args: [message(code: 'crmTask.label', default: 'Task'), params.id])
            redirect action: 'index'
            return
        }
        def user = crmSecurityService.getUserInfo(params.username ?: crmTask.username)
        if(! user) {
            user = crmSecurityService.getUserInfo(null)
        }
        def typeList = crmTaskService.listTaskTypes()
        def userList = crmSecurityService.getTenantUsers()
        def timeList = (0..23).inject([]) { list, h -> 4.times { list << String.format("%02d:%02d", h, it * 15) }; list }
        if(crmTask.startTime) {
            def hm = crmTask.startTime.format("HH:mm")
            if(! timeList.contains(hm)) {
                timeList << hm
            }
        }
        if(crmTask.endTime) {
            def hm = crmTask.endTime.format("HH:mm")
            if(! timeList.contains(hm)) {
                timeList << hm
            }
        }
        timeList = timeList.sort()

        def metadata = [:]
        metadata.locale = RequestContextUtils.getLocale(request)
        metadata.dateFormat = DateFormat.getDateInstance(DateFormat.SHORT, metadata.locale)
        metadata.typeList = typeList
        metadata.userList = userList
        metadata.timeList = timeList

        switch (request.method) {
            case 'GET':
                return [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
            case 'POST':
                try {
                    bindData(crmTask, params, [include: CrmTask.BIND_WHITELIST - ['startTime', 'endTime']])

                    //setReference(crmTask, params.ref)

                    def startDate = params.startDate ?: (new Date() + 1).format("yyyy-MM-dd")
                    def endDate = params.endDate ?: startDate
                    def startTime = params.startTime ?: '09:00'
                    def endTime = params.endTime ?: '10:00'
                    bindDate(crmTask, 'startTime', startDate + startTime, user?.timezone)
                    bindDate(crmTask, 'endTime', endDate + endTime, user?.timezone)

                    if (crmTask.hasErrors() || !crmTask.save()) {
                        render view: 'edit', model: [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
                        return
                    }

                    flash.success = message(code: 'crmTask.updated.message', args: [message(code: 'crmTask.label', default: 'Task'), crmTask.toString()])
                    if (params.referer) {
                        redirect(uri: params.referer - request.contextPath)
                    } else {
                        redirect action: 'show', id: crmTask.id
                    }
                } catch (Exception e) {
                    log.error(e)
                    flash.error = e.message
                    render view: 'edit', model: [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
                }
                break
        }
    }

    def delete() {
        def crmTask = CrmTask.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmTask) {
            flash.error = message(code: 'crmTask.not.found.message', args: [message(code: 'crmTask.label', default: 'Task'), params.id])
            redirect action: 'index'
            return
        }

        try {
            def tombstone = crmTaskService.deleteTask(crmTask)
            flash.warning = message(code: 'crmTask.deleted.message', args: [message(code: 'crmTask.label', default: 'Task'), tombstone])
            if (params.referer) {
                redirect(uri: params.referer - request.contextPath)
            } else {
                redirect action: 'index'
            }
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmTask.not.deleted.message', args: [message(code: 'crmTask.label', default: 'Task'), params.id])
            redirect action: 'show', id: params.id
        }
    }

    def createFavorite() {
        def crmTask = CrmTask.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmTask) {
            flash.error = message(code: 'crmTask.not.found.message', args: [message(code: 'crmTask.label', default: 'Task'), params.id])
            redirect action: 'index'
            return
        }
        userTagService.tag(crmTask, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)

        redirect(action: 'show', id: params.id)
    }

    def deleteFavorite() {
        def crmTask = CrmTask.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmTask) {
            flash.error = message(code: 'crmTask.not.found.message', args: [message(code: 'crmTask.label', default: 'Task'), params.id])
            redirect action: 'index'
            return
        }
        userTagService.untag(crmTask, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)
        redirect(action: 'show', id: params.id)
    }

    def completed(Long id) {
        def crmTask = CrmTask.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmTask) {
            flash.error = message(code: 'crmTask.not.found.message', args: [message(code: 'crmTask.label', default: 'Task'), params.id])
            redirect action: 'index'
            return
        }
        crmTaskService.setStatusCompleted(crmTask)
        flash.success = message(code: 'crmTask.completed.message', args: [message(code: 'crmTask.label', default: 'Task'), crmTask.toString()])
        redirect action: 'show', id: crmTask.id
    }

    def attender(Long id, Long task) {
        def crmTask = CrmTask.findByIdAndTenantId(task, TenantUtils.tenant)
        if (!crmTask) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTask found with id [$task]")
            return
        }
        CrmTaskAttender taskAttender
        if (id) {
            taskAttender = CrmTaskAttender.findByIdAndTask(id, crmTask)
            if (!taskAttender) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTaskAttender found with id [$id] and task [$task]")
                return
            }
        } else {
            taskAttender = new CrmTaskAttender(task: crmTask)
        }

        if (request.method == 'GET') {
            return [bean: taskAttender, crmTask: crmTask,
                    statusList: CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
        } else if (request.method == 'POST') {
            try {
                def currentUser = crmSecurityService.getUserInfo()
                bindData(taskAttender, params, [include: ['bookingRef', 'notes', 'status', 'hide']])
                bindDate(taskAttender, 'bookingDate', params.bookingDate, currentUser.timezone)
                CrmContact.withTransaction {
                    fixContact(taskAttender, params, params.boolean('createContact'))
                }
                if (taskAttender.validate() && taskAttender.save()) {
                    if (taskAttender.contact) {
                        rememberDomain(taskAttender.contact)
                    }
                    flash.success = "Deltagaren uppdaterad"
                } else {
                    flash.error = createValidationErrorMessage(taskAttender)
                }
            } catch (Exception e) {
                flash.error = e.getLocalizedMessage()
            }
            redirect action: "show", id: crmTask.id, fragment: "attender"
        }
    }

    private void fixContact(CrmTaskAttender attender, GrailsParameterMap params, Boolean add) {
        def tenant = TenantUtils.tenant
        CrmContact contact = params['contactId'] ? CrmContact.findByIdAndTenantId(params.long('contactId'), tenant) : null
        if (contact) {
            attender.contact = contact
        } else if (add) {
            def company = params['companyId'] ? CrmContact.findByIdAndTenantId(params.long('companyId'), tenant) : null
            if (params.companyName && !company) {
                company = crmContactService.createCompany(name: params.companyName,
                        telephone: params.telephone, email: params.email, address: [address1: params.address],
                        true)
                params['companyId'] = company.ident()
            }

            // A contact name is specified but it's not an existing contact.
            // Create a new person.
            def person
            if (params.firstName) {
                if (company.hasErrors()) {
                    company = null // TODO lame...
                }
                person = crmContactService.createPerson(parent: company, firstName: params.firstName, lastName: params.lastName,
                        title: params.title, telephone: params.telephone, email: params.email, address: [address1: params.address],
                        true)
                params['contactId'] = person.ident()
                if (!person.hasErrors()) {
                    attender.contact = person
                    attender.tmp = null
                }
            }
        } else {
            attender.contact = null
            bindData(attender.contactInformation, params, [include: ['firstName', 'lastName', 'companyName', 'title', 'address', 'telephone', 'email']])
        }
    }

    def deleteAttender(Long id, Long task) {
        def crmTask = CrmTask.findByIdAndTenantId(task, TenantUtils.tenant)
        if (!crmTask) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTask found with id [$task]")
            return
        }
        def taskAttender = CrmTaskAttender.findByIdAndTask(id, crmTask)
        if (!taskAttender) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTaskAttender found with id [$id] and task [$task]")
            return
        }

        try {
            def tombstone = taskAttender.toString()
            taskAttender.delete(flush: true)
            flash.warning = message(code: 'crmTaskAttender.deleted.message', args: [message(code: 'crmTaskAttender.label', default: 'Attender'), tombstone])
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmTaskAttender.not.deleted.message', args: [message(code: 'crmTaskAttender.label', default: 'Attender'), id])
        }
        redirect(action: "show", id: crmTask.id, fragment: "attender")
    }

    def updateAttenders(Long task, Long status) {
        def tenant = TenantUtils.tenant
        def crmTask = CrmTask.findByIdAndTenantId(task, tenant)
        if (!crmTask) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTask found with id [$task]")
            return
        }
        def attenderStatus = CrmTaskAttenderStatus.findByIdAndTenantId(status, tenant)
        if (!attenderStatus) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTaskAttenderStatus found with id [$status]")
            return
        }
        List<Long> attenders = params.list('attenders')
        CrmTaskAttender.withTransaction {
            for (a in attenders) {
                CrmTaskAttender attender = CrmTaskAttender.findByIdAndTask(a, crmTask)
                if (attender) {
                    attender.status = attenderStatus
                } else {
                    log.error("No CrmTaskAttender found with id [$a] in tenant [$tenant]")
                }
            }
        }
        def linkParams = [id: crmTask.id]
        if (params.sort) {
            linkParams.sort = params.sort
        }
        if (params.order) {
            linkParams.order = params.order
        }
        flash.success = "Status uppdaterades för ${attenders.size()} st deltagare".toString()

        redirect(action: "show", params: linkParams, fragment: "attender")
    }

    private void bindDate(CrmTaskAttender target, String property, String value, TimeZone timezone = null) {
        if (value) {
            try {
                target[property] = DateUtils.parseSqlDate(value, timezone)
            } catch (Exception e) {
                def entityName = message(code: 'crmTask.label', default: 'Task')
                def propertyName = message(code: 'crmTask.' + property + '.label', default: property)
                target.errors.rejectValue(property, 'default.invalid.date.message', [propertyName, entityName, value.toString(), e.message].toArray(), "Invalid date: {2}")
            }
        } else {
            target[property] = null
        }
    }

    def autocompleteContact() {
        if (params.parent) {
            params.parent = params.long('parent')
        }
        if (params.company) {
            params.company = params.boolean('company')
        }
        if (params.person) {
            params.person = params.boolean('person')
        }
        def result = crmContactService.list(params, [max: 100]).collect {
            [it.fullName, it.id, it.parentId, it.parent?.toString(), it.firstName, it.lastName, it.address.toString(), it.telephone, it.email]
        }
        WebUtils.noCache(response)
        render result as JSON
    }

    def autocompleteUsername() {
        def query = params.q?.toLowerCase()
        def result = crmSecurityService.getTenantUsers().collect { it.username }
        if (query) {
            result = result.findAll { it.toLowerCase().contains(query) }
        }
        result = result.sort()
        WebUtils.shortCache(response)
        render result as JSON
    }

    def autocompleteLocation() {
        def result = CrmTask.withCriteria() {
            projections {
                distinct('location')
            }
            eq('tenantId', TenantUtils.tenant)
            if (params.q) {
                ilike('location', SearchUtils.wildcard(params.q))
            }
            order 'location', 'asc'
            maxResults 100
            cache true
        }
        WebUtils.shortCache(response)
        render result as JSON
    }

    def autocompleteType() {
        def result = CrmTaskType.withCriteria(params) {
            projections {
                property('name')
            }
            eq('tenantId', TenantUtils.tenant)
            if (params.q) {
                ilike('name', SearchUtils.wildcard(params.q))
            }
        }
        WebUtils.shortCache(response)
        render result as JSON
    }
}
