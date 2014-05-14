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

class CrmTaskUiGrailsPlugin {
    def groupId = "grails.crm"
    def version = "1.2.6"
    def grailsVersion = "2.2 > *"
    def dependsOn = [:]
    def loadAfter = ['crmTask']
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]
    def title = "GR8 CRM Task Management User Interface"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = "Provides task management user interface for GR8 CRM."
    def documentation = "https://github.com/technipelago/grails-crm-task-ui"
    def license = "APACHE"
    def organization = [name: "Technipelago AB", url: "http://www.technipelago.se/"]
    def issueManagement = [system: "github", url: "https://github.com/technipelago/grails-crm-task-ui/issues"]
    def scm = [url: "https://github.com/technipelago/grails-crm-task-ui"]
}
