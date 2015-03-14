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

import org.joda.time.DateTimeZone
import org.joda.time.Instant
import org.joda.time.DateTime
import grails.converters.JSON
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.DateUtils
import org.apache.commons.lang.StringUtils
import org.joda.time.format.DateTimeFormat
import org.joda.time.format.DateTimeFormatter
import org.springframework.web.servlet.support.RequestContextUtils as RCU
import javax.servlet.http.HttpServletResponse

/**
 * FullCalendar controller.
 */
class CrmCalendarController {

    def crmCalendarService
    def crmSecurityService

    def index() {
        def checked = getCalendarTenants(params)
        if (checked == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN)
            return
        }
        def user = crmSecurityService.getUserInfo(null)
        def locale = RCU.getLocale(request)
        def metadata = [locale: locale, lang: locale.language]
        metadata.firstDayOfWeek = DateUtils.getFirstDayOfWeek(locale, user.timezone)
        return [calendars: checked, metadata: metadata]
    }

    private List<Long> getCalendarTenants(params) {
        if (!params.calendars) {
            params.calendars = [TenantUtils.tenant]
        }
        def checked = params.list('calendars').collect {Long.valueOf(it)}
        def username = crmSecurityService.currentUser?.username
        for (tenant in checked) {
            if (!crmSecurityService.isValidTenant(tenant, username)) {
                crmSecurityService.alert(request, "accessDenied", "User [${username}] is not allowed to view calendar events for tenant [${tenant}]")
                return null
            }
        }
        return checked
    }

    def events() {
        DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd");
        DateTimeFormatter iso8601 = DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ss'Z'").withZone(DateTimeZone.forID("Europe/Stockholm"))
        def t0 = params.start ? fmt.parseDateTime(params.start) : new DateTime().minusDays(45)
        def t1 = params.end ? fmt.parseDateTime(params.end) : new DateTime().plusDays(45)
        def checked = getCalendarTenants(params)
        if (checked == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN)
            return
        }
        def events = CrmTask.withCriteria {
            inList('tenantId', checked)
            eq('hidden', false)
            if (params.username) {
                eq('username', params.username)
            }
            or {
                and {
                    eq("isRecurring", false)
                    between("startTime", t0.toDate(), t1.toDate())
                }
                and {
                    eq("isRecurring", true)
                    or {
                        isNull("recurUntil")
                        ge("recurUntil", t0.toDate())
                    }
                }
            }
        }

        // iterate through to see if we need to add additional Event instances because of recurring
        // events
        def eventList = []
        def currentTenant = TenantUtils.tenant
        events.each {event ->

            def dates = crmCalendarService.findOccurrencesInRange(event, t0.toDate(), t1.toDate())

            dates.each { date ->
                DateTime startTime = new DateTime(date)
                DateTime endTime = startTime.plusMinutes(event.getDurationMinutes() ?: 30)
                def linkParams = [id: event.id]
                if (event.tenantId != currentTenant) {
                    linkParams.tenant = event.tenantId
                }
                eventList << [
                        id: event.id,
                        tenant: event.tenantId,
                        title: event.name + (event.completed ? ' ✓' : ''),
                        description: StringUtils.abbreviate(event.description, 200),
                        url: g.createLink(controller: 'crmTask', action: 'show', params: linkParams),
                        color: crmCalendarService.getEventColor(event),
                        allDay: false,
                        start: iso8601.print(startTime),
                        end: iso8601.print(endTime)
                ]
            }
        }

        render eventList as JSON
    }

}
