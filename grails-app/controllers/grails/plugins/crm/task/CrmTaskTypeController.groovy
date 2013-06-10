/*
 * Copyright (c) 2013 Goran Ehrsson.
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

class CrmTaskTypeController {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    static navigation = [
            [group: 'admin',
                    order: 310,
                    title: 'crmTaskType.label',
                    action: 'index'
            ]/*,
            [group: 'crmTaskType',
                    order: 20,
                    title: 'crmTaskType.create.label',
                    action: 'create',
                    isVisible: { actionName != 'create' }
            ],
            [group: 'crmTaskType',
                    order: 30,
                    title: 'crmTaskType.list.label',
                    action: 'list',
                    isVisible: { actionName != 'list' }
            ]*/
    ]

    def selectionService
    def crmTaskService

    def domainClass = CrmTaskType

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        def baseURI = new URI('gorm://crmTaskType/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                grails.plugins.crm.core.WebUtils.setTenantData(request, 'crmTaskTypeQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        try {
            def result = selectionService.select(uri, params)
            [crmTaskTypeList: result, crmTaskTypeTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmTaskTypeList: [], crmTaskTypeTotal: 0, selection: uri]
        }
    }

    def create() {
        def crmTaskType = crmTaskService.createTaskType(params)
        switch (request.method) {
            case 'GET':
                return [crmTaskType: crmTaskType]
            case 'POST':
                if (!crmTaskType.save(flush: true)) {
                    render view: 'create', model: [crmTaskType: crmTaskType]
                    return
                }

                flash.success = message(code: 'crmTaskType.created.message', args: [message(code: 'crmTaskType.label', default: 'Type'), crmTaskType.toString()])
                redirect action: 'list'
                break
        }
    }

    def edit() {
        switch (request.method) {
            case 'GET':
                def crmTaskType = domainClass.get(params.id)
                if (!crmTaskType) {
                    flash.error = message(code: 'crmTaskType.not.found.message', args: [message(code: 'crmTaskType.label', default: 'Type'), params.id])
                    redirect action: 'list'
                    return
                }

                return [crmTaskType: crmTaskType]
            case 'POST':
                def crmTaskType = domainClass.get(params.id)
                if (!crmTaskType) {
                    flash.error = message(code: 'crmTaskType.not.found.message', args: [message(code: 'crmTaskType.label', default: 'Type'), params.id])
                    redirect action: 'list'
                    return
                }

                if (params.version) {
                    def version = params.version.toLong()
                    if (crmTaskType.version > version) {
                        crmTaskType.errors.rejectValue('version', 'crmTaskType.optimistic.locking.failure',
                                [message(code: 'crmTaskType.label', default: 'Type')] as Object[],
                                "Another user has updated this Type while you were editing")
                        render view: 'edit', model: [crmTaskType: crmTaskType]
                        return
                    }
                }

                crmTaskType.properties = params

                if (!crmTaskType.save(flush: true)) {
                    render view: 'edit', model: [crmTaskType: crmTaskType]
                    return
                }

                flash.success = message(code: 'crmTaskType.updated.message', args: [message(code: 'crmTaskType.label', default: 'Type'), crmTaskType.toString()])
                redirect action: 'list'
                break
        }
    }

    def delete() {
        def crmTaskType = domainClass.get(params.id)
        if (!crmTaskType) {
            flash.error = message(code: 'crmTaskType.not.found.message', args: [message(code: 'crmTaskType.label', default: 'Type'), params.id])
            redirect action: 'list'
            return
        }

        if (isInUse(crmTaskType)) {
            render view: 'edit', model: [crmTaskType: crmTaskType]
            return
        }

        try {
            def tombstone = crmTaskType.toString()
            crmTaskType.delete(flush: true)
            flash.warning = message(code: 'crmTaskType.deleted.message', args: [message(code: 'crmTaskType.label', default: 'Type'), tombstone])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmTaskType.not.deleted.message', args: [message(code: 'crmTaskType.label', default: 'Type'), params.id])
            redirect action: 'edit', id: params.id
        }
    }

    private boolean isInUse(CrmTaskType type) {
        def count = CrmTask.countByType(type)
        def rval = false
        if (count) {
            flash.error = message(code: "crmTaskType.delete.error.reference", args:
                    [message(code: 'crmTaskType.label', default: 'Task Type'),
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
