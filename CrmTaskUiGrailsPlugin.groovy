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

import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.task.CrmTask

class CrmTaskUiGrailsPlugin {
    def groupId = "grails.crm"
    def version = "1.2.2"
    def grailsVersion = "2.2 > *"
    def dependsOn = [:]
    def loadAfter = ['crmTask']
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]
    def title = "Grails CRM Task Management User Interface"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = "Provides task management user interface for Grails CRM."
    def documentation = "https://github.com/technipelago/grails-crm-task-ui"
    def license = "APACHE"
    def organization = [name: "Technipelago AB", url: "http://www.technipelago.se/"]
    def issueManagement = [system: "github", url: "https://github.com/technipelago/grails-crm-task-ui/issues"]
    def scm = [url: "https://github.com/technipelago/grails-crm-task-ui"]

    // Provided CRM features.
    def features = {
        crmTask {
            description "Grails CRM Task Management"
            link controller: "crmTask", action: "index"
            permissions {
                guest "crmTask:index,list,show,createFavorite,deleteFavorite,clearQuery", "crmCalendar:index,events"
                partner "crmTask:index,list,show,createFavorite,deleteFavorite,clearQuery", "crmCalendar:index,events"
                user "crmTask,crmCalendar:*"
                admin "crmTask,crmTaskCategory,crmTaskStatus,crmTaskType,crmCalendar:*"
            }
            statistics { tenant ->
                def total = CrmTask.countByTenantId(tenant)
                def updated = CrmTask.countByTenantIdAndLastUpdatedGreaterThan(tenant, new Date() - 31)
                def usage
                if (total > 0) {
                    def tmp = updated / total
                    if (tmp < 0.1) {
                        usage = 'low'
                    } else if (tmp < 0.3) {
                        usage = 'medium'
                    } else {
                        usage = 'high'
                    }
                } else {
                    usage = 'none'
                }
                return [usage: usage, objects: total]
            }
        }
    }

    def doWithApplicationContext = { applicationContext ->
        def crmPluginService = applicationContext.crmPluginService
        // TODO Move to application!!!
        crmPluginService.registerView('start', 'index', 'urgent-important',
                [id: "urgent-tasks", permission: "crmTask:index", label: "start.urgent.tasks.label", template: '/start/tasks', plugin: "crm-task-ui", model: {
                    def d = new Date()
                    def result = CrmTask.createCriteria().list() {
                        eq('tenantId', TenantUtils.tenant)
                        between('startTime', * DateUtils.getDateSpan(d))
                        lt('complete', 100)
                    }
                    [result: result]
                }]
        )

        crmPluginService.registerView('start', 'index', 'urgent',
                [id: "important-tasks", permission: "crmTask:index", label: "start.important.tasks.label", template: '/start/tasks', plugin: "crm-task-ui", model: {
                    def d1 = DateUtils.getDateSpan(new Date() + 1)
                    def d2 = DateUtils.endOfWeek(5)
                    def result = CrmTask.createCriteria().list() {
                        eq('tenantId', TenantUtils.tenant)
                        between('startTime', d1[0], d2)
                        lt('complete', 100)
                    }
                    [result: result]
                }]
        )
    }
}
