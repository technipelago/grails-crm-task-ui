/*
 * Copyright (c) 2015 Goran Ehrsson.
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
    def groupId = ""
    def version = "2.5.1"
    def grailsVersion = "2.4 > *"
    def dependsOn = [:]
    def loadAfter = ['crmTask']
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]
    def title = "Task Management User Interface for GR8 CRM"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = "Provides task management user interface for GR8 CRM applications"
    def documentation = "http://gr8crm.github.io/plugins/crm-task-ui/"
    def license = "APACHE"
    def organization = [name: "Technipelago AB", url: "http://www.technipelago.se/"]
    def issueManagement = [system: "github", url: "https://github.com/technipelago/grails-crm-task-ui/issues"]
    def scm = [url: "https://github.com/technipelago/grails-crm-task-ui"]
}
