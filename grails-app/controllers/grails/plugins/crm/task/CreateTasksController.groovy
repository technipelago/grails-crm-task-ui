/*
 * Copyright (c) 2018 Goran Ehrsson.
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
import grails.plugins.crm.core.CrmContactInformation
import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.util.GrailsNameUtils
import org.springframework.web.servlet.support.RequestContextUtils

import java.text.DateFormat

class CreateTasksController {

    static allowedMethods = [save: 'POST']

    def selectionService
    def crmTaskService
    def crmSecurityService

    def index() {
        def entityName = params.entityName
        def uri = params.getSelectionURI()
        def result = selectionService.select(uri, [max: 10])

        def startDate = params.remove('startDate') ?: formatDate(type: 'date', date: new Date() + 1)
        def endDate = params.remove('endDate') ?: startDate
        def startTime = params.remove('startTime') ?: crmTaskService.getDefaultStartTime()
        def endTime = params.remove('endTime') ?: crmTaskService.getDefaultEndTime()
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

        bindDate(crmTask, 'startTime', startDate + ' ' + startTime, user?.timezone)
        bindDate(crmTask, 'endTime', endDate + ' ' + endTime, user?.timezone)
        crmTask.clearErrors()
        return [entityName: entityName, selection: uri, result: result, totalCount: result.totalCount,
                crmTask: crmTask, user: user, referer: params.referer, metadata: metadata]
    }

    def save() {
        def entityName = params.entityName
        def propertyName = GrailsNameUtils.getPropertyName(entityName)
        def uri = params.getSelectionURI()
        def result = selectionService.select(uri, params)

        def startDate = params.remove('startDate') ?: formatDate(type: 'date', date: new Date() + 1)
        def endDate = params.remove('endDate') ?: startDate
        def alarmDate = params.remove('alarmDate') ?: startDate
        def startTime = params.remove('startTime') ?: crmTaskService.getDefaultStartTime()
        def endTime = params.remove('endTime') ?: crmTaskService.getDefaultEndTime()
        def alarmTime = params.remove('alarmTime') ?: crmTaskService.getDefaultAlarmTime()
        def times = [startTime: startDate + startTime, endTime: endDate + endTime, alarmTime: alarmDate + alarmTime]
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

        for (m in result) {
            createTask(m, params, times, user)
        }

        flash.success = message(code: propertyName + '.selection.createTasks.success', args: [result.totalCount, message(code: propertyName + '.label')])

        def redirectParams = params.subMap([grailsApplication.config.selection.uri.parameter ?: 'q'])
        redirect controller: entityName, action: 'list', params: redirectParams
    }

    private CrmTask createTask(Object entityInstance, Map params, Map times, Map user) {
        def crmTask = crmTaskService.createTask(params)

        setReference(crmTask, entityInstance)

        bindDate(crmTask, 'startTime', times.startTime, user?.timezone)
        bindDate(crmTask, 'endTime', times.endTime, user?.timezone)
        bindDate(crmTask, 'alarmTime', times.alarmTime, user?.timezone)

        if (crmTask.save()) {
            if(entityInstance instanceof CrmContactInformation) {
                crmTaskService.addAttender(crmTask, entityInstance)
                crmTask.save(flush: true)
            }
            event(for: "crmTask", topic: "created", data: [id: crmTask.id, tenant: crmTask.tenantId, user: user.username, name: crmTask.toString()])
        }
         return crmTask
    }

    private void setReference(object, reference) {
        if(reference instanceof CrmContact) {
            return
        }
        if (reference.hasProperty('tenantId') && (reference.tenantId == TenantUtils.tenant)) {
            object.reference = reference
        }
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
}
