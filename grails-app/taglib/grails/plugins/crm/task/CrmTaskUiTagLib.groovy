/*
 * Copyright (c) 2016 Goran Ehrsson.
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

import grails.plugins.crm.tags.CrmTagLink

/**
 * Training UI tags.
 */
class CrmTaskUiTagLib {

    static namespace = "crm"

    /**
     * Aggregate attender statistics for an event (CrmTask).
     * @attr bean a CrmTask instance to collect statistics for
     * @attr status only include tags for attenders with this status (parameter).
     * @return the tag body is invoked with a Map with two keys 'status' and 'tags' that contain attender metrics.
     */
    def attenderStatistics = { attrs, body ->
        def crmTask = attrs.bean
        if (!crmTask) {
            throwTagError("Tag [attenderStatistics] is missing required attribute [bean]")
        }
        Map status = [:]
        List attenders = CrmTaskAttender.createCriteria().list() {
            projections {
                property('id')
                property('status')
            }
            booking {
                eq('task', crmTask)
            }
        }
        def statusFilter = attrs.status ? {it.param == attrs.status} : {true}
        def valueFilter
        if(attrs.tags) {
            if(attrs.tags instanceof Collection) {
                valueFilter = attrs.tags
            } else {
                valueFilter = attrs.tags.toString().split(',').toList()
            }
        }
        Map tags = [:]
        for (a in attenders) {
            status.put(a[1], status.get(a[1], 0) + 1)
            if(statusFilter(a[1])) {
                for (t in CrmTagLink.createCriteria().list() {
                    projections {
                        property('value')
                    }
                    tag {
                        eq('name', CrmTaskAttender.name)
                    }
                    if(valueFilter) {
                        inList('value', valueFilter)
                    }
                    eq('ref', 'crmTaskAttender@' + a[0])
                }) {
                    tags.put(t, tags.get(t, 0) + 1)
                }
            }
        }
        out << body([status: status, tags: tags, count: attenders.size()])
    }
}
