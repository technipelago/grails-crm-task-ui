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

import org.springframework.dao.DataIntegrityViolationException
import javax.servlet.http.HttpServletResponse

class CrmTaskAttenderStatusController {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    static navigation = [
            [group: 'admin',
                    order: 320,
                    title: 'crmTaskAttenderStatus.label',
                    action: 'index'
            ]/*,
            [group: 'crmTaskAttenderStatus',
                    order: 20,
                    title: 'crmTaskAttenderStatus.create.label',
                    action: 'create',
                    isVisible: { actionName != 'create' }
            ],
            [group: 'crmTaskAttenderStatus',
                    order: 30,
                    title: 'crmTaskAttenderStatus.list.label',
                    action: 'list',
                    isVisible: { actionName != 'list' }
            ]*/
    ]

    def selectionService
    def crmTaskService

    def domainClass = CrmTaskAttenderStatus

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        def baseURI = new URI('gorm://crmTaskAttenderStatus/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                grails.plugins.crm.core.WebUtils.setTenantData(request, 'crmTaskAttenderStatusQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        try {
            def result = selectionService.select(uri, params)
            [crmTaskAttenderStatusList: result, crmTaskAttenderStatusTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmTaskAttenderStatusList: [], crmTaskAttenderStatusTotal: 0, selection: uri]
        }
    }

    def create() {
        def crmTaskAttenderStatus = crmTaskService.createTaskType(params)
        switch (request.method) {
            case 'GET':
                return [crmTaskAttenderStatus: crmTaskAttenderStatus]
            case 'POST':
                if (!crmTaskAttenderStatus.save(flush: true)) {
                    render view: 'create', model: [crmTaskAttenderStatus: crmTaskAttenderStatus]
                    return
                }

                flash.success = message(code: 'crmTaskAttenderStatus.created.message', args: [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'), crmTaskAttenderStatus.toString()])
                redirect action: 'list'
                break
        }
    }

    def edit() {
        switch (request.method) {
            case 'GET':
                def crmTaskAttenderStatus = domainClass.get(params.id)
                if (!crmTaskAttenderStatus) {
                    flash.error = message(code: 'crmTaskAttenderStatus.not.found.message', args: [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'), params.id])
                    redirect action: 'list'
                    return
                }

                return [crmTaskAttenderStatus: crmTaskAttenderStatus]
            case 'POST':
                def crmTaskAttenderStatus = domainClass.get(params.id)
                if (!crmTaskAttenderStatus) {
                    flash.error = message(code: 'crmTaskAttenderStatus.not.found.message', args: [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'), params.id])
                    redirect action: 'list'
                    return
                }

                if (params.version) {
                    def version = params.version.toLong()
                    if (crmTaskAttenderStatus.version > version) {
                        crmTaskAttenderStatus.errors.rejectValue('version', 'crmTaskAttenderStatus.optimistic.locking.failure',
                                [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status')] as Object[],
                                "Another user has updated this Attender Status while you were editing")
                        render view: 'edit', model: [crmTaskAttenderStatus: crmTaskAttenderStatus]
                        return
                    }
                }

                crmTaskAttenderStatus.properties = params

                if (!crmTaskAttenderStatus.save(flush: true)) {
                    render view: 'edit', model: [crmTaskAttenderStatus: crmTaskAttenderStatus]
                    return
                }

                flash.success = message(code: 'crmTaskAttenderStatus.updated.message', args: [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'), crmTaskAttenderStatus.toString()])
                redirect action: 'list'
                break
        }
    }

    def delete() {
        def crmTaskAttenderStatus = domainClass.get(params.id)
        if (!crmTaskAttenderStatus) {
            flash.error = message(code: 'crmTaskAttenderStatus.not.found.message', args: [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'), params.id])
            redirect action: 'list'
            return
        }

        if (isInUse(crmTaskAttenderStatus)) {
            render view: 'edit', model: [crmTaskAttenderStatus: crmTaskAttenderStatus]
            return
        }

        try {
            def tombstone = crmTaskAttenderStatus.toString()
            crmTaskAttenderStatus.delete(flush: true)
            flash.warning = message(code: 'crmTaskAttenderStatus.deleted.message', args: [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'), tombstone])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmTaskAttenderStatus.not.deleted.message', args: [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'), params.id])
            redirect action: 'edit', id: params.id
        }
    }

    private boolean isInUse(CrmTaskAttenderStatus type) {
        def count = CrmTaskAttender.countByStatus(type)
        def rval = false
        if (count) {
            flash.error = message(code: "crmTaskAttenderStatus.delete.error.reference", args:
                    [message(code: 'crmTaskAttenderStatus.label', default: 'Attender Status'),
                            message(code: 'crmTask.label', default: 'Task'), count],
                    default: "This {0} is used by {1} {2}")
            rval = true
        }

        return rval
    }

    def moveUp(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def prev = domainClass.createCriteria().list([sort: 'orderIndex', order: 'desc']) {
                lt('orderIndex', sort)
                maxResults 1
            }?.find {it}
            if (prev) {
                domainClass.withTransaction {tx ->
                    target.orderIndex = prev.orderIndex
                    prev.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }

    def moveDown(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def next = domainClass.createCriteria().list([sort: 'orderIndex', order: 'asc']) {
                gt('orderIndex', sort)
                maxResults 1
            }?.find {it}
            if (next) {
                domainClass.withTransaction {tx ->
                    target.orderIndex = next.orderIndex
                    next.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }
}
