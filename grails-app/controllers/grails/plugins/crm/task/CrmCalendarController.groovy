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

import org.joda.time.Instant
import org.joda.time.DateTime
import grails.converters.JSON
import grails.plugins.crm.core.TenantUtils
import org.apache.commons.lang.StringUtils
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
        // TODO Move month name stuff to DateUtils in plugin crm-core
        def locale = RCU.getLocale(request)
        def calendar = Calendar.getInstance(user.timezone, locale)
        def metadata = [:]
        metadata.firstDayOfWeek = calendar.getFirstDayOfWeek()
        metadata.monthNames = (0..11).collect{calendar.set(Calendar.MONTH, it); calendar.getDisplayName(Calendar.MONTH, Calendar.LONG, locale)}
        metadata.monthNamesShort = (0..11).collect{calendar.set(Calendar.MONTH, it); calendar.getDisplayName(Calendar.MONTH, Calendar.SHORT, locale)}
        metadata.dayNames = [1,2,3,4,5,6,0].collect{calendar.set(Calendar.DAY_OF_WEEK, it); calendar.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.LONG, locale)}
        metadata.dayNamesShort = [1,2,3,4,5,6,0].collect{calendar.set(Calendar.DAY_OF_WEEK, it); calendar.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, locale)}
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
        def t0 = params.long('start') ?: (new Date() - 45).time
        def t1 = params.long('end') ?: (new Date() + 45).time
        def (startRange, endRange) = [t0, t1].collect { new Instant(it * 1000L).toDate() }
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
                    between("startTime", startRange, endRange)
                }
                and {
                    eq("isRecurring", true)
                    or {
                        isNull("recurUntil")
                        ge("recurUntil", startRange)
                    }
                }
            }
        }

        // iterate through to see if we need to add additional Event instances because of recurring
        // events
        def eventList = []
        def currentTenant = TenantUtils.tenant
        events.each {event ->

            def dates = crmCalendarService.findOccurrencesInRange(event, startRange, endRange)

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
                        start: (startTime.toInstant().millis / 1000L),
                        end: (endTime.toInstant().millis / 1000L)
                ]
            }
        }

        render eventList as JSON
    }

}
