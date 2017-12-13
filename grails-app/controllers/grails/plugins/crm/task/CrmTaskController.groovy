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

import grails.converters.JSON
import grails.plugins.crm.contact.CrmContact
import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.SearchUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.WebUtils
import grails.plugins.crm.tags.CrmTagLink
import grails.transaction.Transactional
import org.apache.commons.lang.StringUtils
import org.codehaus.groovy.grails.web.binding.DataBindingUtils
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.dao.DataIntegrityViolationException
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

    def export() {
        def user = crmSecurityService.getUserInfo()
        def ns = params.ns ?: 'crmTask'
        def locale = RequestContextUtils.getLocale(request) ?: Locale.getDefault()
        if (request.post) {
            def filename = message(code: 'crmTask.label', default: 'Task')
            try {
                def timeout = (grailsApplication.config.crm.task.export.timeout ?: 60) * 1000
                def topic = params.topic ?: 'export'
                def result = event(for: ns, topic: topic,
                        data: params + [user: user, tenant: TenantUtils.tenant, locale: locale, filename: filename]).waitFor(timeout)?.value
                if (result?.file) {
                    try {
                        WebUtils.inlineHeaders(response, result.contentType, result.filename ?: ns)
                        WebUtils.renderFile(response, result.file)
                    } finally {
                        result.file.delete()
                    }
                    return null // Success
                } else if (result?.redirect) {
                    if (result.error) {
                        flash.error = message(code: result.error)
                    } else if (result.warning) {
                        flash.warning = message(code: result.warning)
                    } else if (result.success || result.message) {
                        flash.success = message(code: (result.success ?: result.message))
                    }
                    redirect result.redirect
                    return
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
            def layouts = event(for: ns, topic: (params.topic ?: 'exportLayout'),
                    data: [tenant: TenantUtils.tenant, username: user.username, uri: uri, locale: locale]).waitFor(10000)?.values?.flatten()
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

    @Transactional
    def create() {
        def startDate = params.remove('startDate') ?: formatDate(type: 'date', date: new Date() + 1)
        def endDate = params.remove('endDate') ?: startDate
        def alarmDate = params.remove('alarmDate') ?: startDate
        def startTime = params.remove('startTime') ?: '09:00'
        def endTime = params.remove('endTime') ?: '10:00'
        def alarmTime = params.remove('alarmTime') ?: '08:00'
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
        def timeList = (0..23).inject([]) { list, h ->
            4.times {
                list << String.format("%02d:%02d", h, it * 15)
            }; list
        }
        if (crmTask.startTime) {
            def hm = crmTask.startTime.format("HH:mm")
            if (!timeList.contains(hm)) {
                timeList << hm
            }
        }
        if (crmTask.endTime) {
            def hm = crmTask.endTime.format("HH:mm")
            if (!timeList.contains(hm)) {
                timeList << hm
            }
        }
        if (crmTask.alarmTime) {
            def hm = crmTask.alarmTime.format("HH:mm")
            if (!timeList.contains(hm)) {
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
        metadata.alarmTypes = CrmTask.constraints.alarmType.inList.collect { t ->
            [value: t, label: message(code: 'crmTask.alarmType.' + t, default: '')]
        }.findAll { it.label }

        switch (request.method) {
            case 'GET':
                if (!checkPrerequisites()) {
                    redirect(mapping: 'crmTask.welcome')
                    return
                }
                def attender
                if(params.attender) {
                    def crmContact = crmCoreService.getReference(params.attender)
                    if(crmContact instanceof CrmContact) {
                        attender = crmContact
                    }
                }
                setReference(crmTask, params.ref)
                bindDate(crmTask, 'startTime', startDate + ' ' + startTime, user?.timezone)
                bindDate(crmTask, 'endTime', endDate + ' ' + endTime, user?.timezone)
                crmTask.clearErrors()
                return [crmTask: crmTask, user: user, referer: params.referer, attender: attender, metadata: metadata]
            case 'POST':
                def attender = params.attender ? crmContactService.getContact(params.long('attender')) : null
                try {
                    setReference(crmTask, params.ref)
                    bindDate(crmTask, 'startTime', startDate + startTime, user?.timezone)
                    bindDate(crmTask, 'endTime', endDate + endTime, user?.timezone)
                    bindDate(crmTask, 'alarmTime', alarmDate + alarmTime, user?.timezone)

                    if (crmTask.save()) {
                        if(attender) {
                            crmTaskService.addAttender(crmTask, attender)
                            crmTask.save(flush: true)
                        }
                        event(for: "crmTask", topic: "created", data: [id: crmTask.id, tenant: crmTask.tenantId, user: user.username, name: crmTask.toString()])
                    } else {
                        render view: 'create', model: [crmTask: crmTask, user: user, referer: params.referer, attender: attender, metadata: metadata]
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
                    render view: 'create', model: [crmTask: crmTask, user: user, referer: params.referer, attender: attender, metadata: metadata]
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
        def future = event(for: "crm", topic: "guessReference", data: [text  : text, user: crmSecurityService.currentUser,
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

        switch (params.narrow) {
            case 'booking':
                def attenders = crmTask.getAttenders()
                if (attenders.size() == 1) {
                    redirect controller: 'crmTaskBooking', action: 'show', id: attenders.find { it }.id
                    return
                }
                break
            case 'attender':
                def attenders = crmTask.getAttenders()
                if (attenders.size() == 1) {
                    redirect controller: 'crmTaskAttender', action: 'show', id: attenders.find { it }.id
                    return
                }
                break
            default:
                break
        }

        def attenderCount
        def recent
        def stats

        if (grailsApplication.config.crm.task.attenders.enabled) {
            attenderCount = CrmTaskAttender.createCriteria().count() {
                booking {
                    eq('task', crmTask)
                }
            }
            recent = CrmTaskAttender.createCriteria().list() {
                booking {
                    eq('task', crmTask)
                    order 'bookingDate', 'desc'
                }
                status {
                    ne('param', 'created')
                }
                maxResults 5
            }
            stats = CrmTaskAttender.createCriteria().list() {
                projections {
                    groupProperty('status')
                    rowCount()
                }
                booking {
                    eq('task', crmTask)
                }
            }
        }

        String attenderSort = grailsApplication.config.crm.task.attenders.sort ?: 'booking.bookingRef'
        String registrationMapping = grailsApplication.config.crm.task.registration.mapping ?: null

        [crmTask       : crmTask, contact: crmTask.contact, statusList: CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId),
         attendersTotal: attenderCount, attenderStatistics: stats, recentBooked: recent, attenderSort: attenderSort,
         attenderStatus: params.status ?: '', attenderTag: params.tag ?: '',
         selection     : params.getSelectionURI(), registrationMapping: registrationMapping,
         attenderTags  : (grailsApplication.config.crm.task.attenders.statistics.tags ?: null)]
    }

    @Transactional
    def edit() {
        def tenant = TenantUtils.tenant
        def crmTask = CrmTask.findByIdAndTenantId(params.id, tenant)
        if (!crmTask) {
            flash.error = message(code: 'crmTask.not.found.message', args: [message(code: 'crmTask.label', default: 'Task'), params.id])
            redirect action: 'index'
            return
        }
        def user = crmSecurityService.getUserInfo(params.username ?: crmTask.username)
        if (!user) {
            user = crmSecurityService.getUserInfo(null)
        }
        def typeList = crmTaskService.listTaskTypes()
        def userList = crmSecurityService.getTenantUsers()
        def timeList = (0..23).inject([]) { list, h ->
            4.times {
                list << String.format("%02d:%02d", h, it * 15)
            }; list
        }
        if (crmTask.startTime) {
            def hm = crmTask.startTime.format("HH:mm")
            if (!timeList.contains(hm)) {
                timeList << hm
            }
        }
        if (crmTask.endTime) {
            def hm = crmTask.endTime.format("HH:mm")
            if (!timeList.contains(hm)) {
                timeList << hm
            }
        }
        if (crmTask.alarmTime) {
            def hm = crmTask.alarmTime.format("HH:mm")
            if (!timeList.contains(hm)) {
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
        metadata.alarmTypes = CrmTask.constraints.alarmType.inList.collect { t ->
            [value: t, label: message(code: 'crmTask.alarmType.' + t, default: '')]
        }.findAll { it.label }

        switch (request.method) {
            case 'GET':
                return [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
            case 'POST':
                try {
                    DataBindingUtils.bindObjectToInstance(crmTask, params, CrmTask.BIND_WHITELIST, ['startTime', 'endTime', 'alarmTime'], null)

                    def startDate = params.startDate ?: (new Date() + 1).format("yyyy-MM-dd")
                    def endDate = params.endDate ?: startDate
                    def alarmDate = params.alarmDate ?: startDate
                    def startTime = params.startTime ?: '09:00'
                    def endTime = params.endTime ?: '10:00'
                    def alarmTime = params.alarmTime ?: '08:00'
                    bindDate(crmTask, 'startTime', startDate + startTime, user?.timezone)
                    bindDate(crmTask, 'endTime', endDate + endTime, user?.timezone)
                    bindDate(crmTask, 'alarmTime', alarmDate + alarmTime, user?.timezone)

                    if (!crmTask.save()) {
                        render view: 'edit', model: [crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
                        return
                    }

                    event(for: "crmTask", topic: "updated", data: [id: crmTask.id, tenant: crmTask.tenantId, user: user.username, name: crmTask.toString()])

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

    @Transactional
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

    @Transactional
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

    @Transactional
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

    @Transactional
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

    def attenders(Long id) {
        def tenant = TenantUtils.tenant
        final CrmTask crmTask = CrmTask.get(id)
        if (crmTask?.tenantId != tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }

        String sort = params.remove('sort') ?: 'status.orderIndex'
        String order = params.remove('order') ?: 'asc'
        int offset = Math.max(params.int('offset') ?: 0, 0)
        int max = Math.min(params.int('max') ?: 25, 100)
        params.remove('offset')
        params.remove('max')

        def bag = [] as Set

        List<Long> result = CrmTaskAttender.createCriteria().list() {
            projections {
                property('id')
            }
            booking {
                eq('task', crmTask)
            }
            if (params.q) {
                or {
                    ilike('tmp.firstName', '%' + params.q + '%')
                    ilike('tmp.lastName', '%' + params.q + '%')
                }
            }
            if (params.status) {
                status {
                    or {
                        eq('name', params.status)
                        eq('param', params.status)
                    }
                }
            }
        }
        if (result) {
            bag.addAll(result)
        }

        if (params.q) {
            result = CrmTaskAttender.createCriteria().list() {
                projections {
                    property('id')
                }
                booking {
                    eq('task', crmTask)
                }
                contact {
                    ilike('name', '%' + params.q + '%')
                }
                if (params.status) {
                    status {
                        or {
                            eq('name', params.status)
                            eq('param', params.status)
                        }
                    }
                }
            }
            if (result) {
                bag.addAll(result)
            }
        }

        def tagValue = params.tag
        if (tagValue) {
            result = CrmTagLink.createCriteria().list() {
                projections {
                    property('ref')
                }
                tag {
                    eq('tenantId', tenant)
                    eq('name', CrmTaskAttender.class.name)
                }
                eq('value', tagValue)
            }.collect { StringUtils.substringAfter(it, '@') }.collect { Long.valueOf(it) }
            bag.retainAll(result)
        }

        List<CrmTaskAttender> finalResult = CrmTaskAttender.createCriteria().list() {
            inList('id', bag ?: [0L])
        }
        if (sort == 'booking.bookingRef') {
            finalResult = CrmTaskUiUtils.sortByExternalId(finalResult)
            if (order == 'desc') {
                finalResult.reverse()
            }
        } else if (sort == 'status.orderIndex') {
            finalResult = CrmTaskUiUtils.sortByStatus(finalResult)
            if (order == 'desc') {
                finalResult.reverse()
            }
        }
        int totalCount = finalResult.size()
        if (finalResult) {
            if (totalCount < max) {
                offset = 0
            }
            int end = offset + max
            if (end > totalCount) {
                end = totalCount
            }

            finalResult = finalResult[(offset)..(end - 1)]
        }
        render template: 'attender_list',
                model: [bean      : crmTask, list: finalResult, totalCount: totalCount,
                        statusList: CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
    }

    @Transactional
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
            taskAttender = new CrmTaskAttender(task: crmTask, bookingDate: new Date())
        }

        def newBookingEntry = [id: 0L, title: message(code: 'crmTaskAttender.new.booking.label')]
        def bookingList = [newBookingEntry] + CrmTaskBooking.findAllByTask(crmTask)

        if (request.method == 'GET') {
            return [bean      : taskAttender, crmTask: crmTask, bookingList: bookingList,
                    statusList: CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
        } else if (request.method == 'POST') {
            try {
                def currentUser = crmSecurityService.getUserInfo()
                bindData(taskAttender, params, [include: ['notes', 'status', 'hide', 'bookingRef', 'externalRef']])
                bindDate(taskAttender, 'bookingDate', params.bookingDate, currentUser.timezone)
                fixContact(taskAttender, params, params.boolean('createContact'))
                if (params['booking.id'] == '0') {
                    taskAttender.booking = new CrmTaskBooking(task: crmTask, bookingDate: taskAttender.bookingDate).save()
                } else {
                    bindData(taskAttender, params, [include: ['booking']])
                }
                if (taskAttender.save()) {
                    if (taskAttender.contact) {
                        rememberDomain(taskAttender.contact)
                    }
                    flash.success = "Attender info updated" // TODO i18n
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
                if (company?.hasErrors()) {
                    company = null // TODO lame...
                }
                person = crmContactService.createPerson(related: company, firstName: params.firstName, lastName: params.lastName,
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
            bindData(attender.contactInformation, params,
                    [include: ['firstName', 'lastName', 'companyName', 'companyId', 'title', 'address', 'telephone', 'email']])
        }
    }

    @Transactional
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

    @Transactional
    def updateAttenders(Long task, Long status) {
        def tenant = TenantUtils.tenant
        def crmTask = CrmTask.findByIdAndTenantId(task, tenant)
        if (!crmTask) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTask found with id [$task]")
            return
        }

        if (status) {
            def attenderStatus = CrmTaskAttenderStatus.findByIdAndTenantId(status, tenant)
            if (!attenderStatus) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTaskAttenderStatus found with id [$status]")
                return
            }
            List<Long> attenders = params.list('attenders')
            for (a in attenders) {
                CrmTaskAttender attender = CrmTaskAttender.get(a)
                if (attender != null && attender.booking.taskId == task) {
                    attender.status = attenderStatus
                } else {
                    log.error("No CrmTaskAttender found with id [$a] in tenant [$tenant]")
                }
            }
            flash.success = "Status uppdaterades för ${attenders.size()} st deltagare".toString()
        }

        def linkParams = [id: crmTask.id]
        if (params.sort) {
            linkParams.sort = params.sort
        }
        if (params.order) {
            linkParams.order = params.order
        }

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
        if (params.related) {
            params.related = params.long('related')
        }
        if (params.company) {
            params.company = params.boolean('company')
        }
        if (params.person) {
            params.person = params.boolean('person')
        }
        def result = crmContactService.list(params, [max: 100]).collect {
            def contact = it.primaryContact ?: it.parent
            def address = it.address
            [it.fullName, it.id, contact?.id, contact?.toString(), it.firstName, it.lastName, it.preferredPhone, it.email, address?.address1, address?.address2, address?.address3, address?.postalCode, address?.city, address?.region, address?.country]
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
