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

package grails.plugins.crm.task

import grails.plugins.crm.core.CrmContactInformation
import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.transaction.Transactional

import javax.servlet.http.HttpServletResponse

/**
 * CRUD controller for task/event bookings.
 */
class CrmTaskBookingController {

    def crmSecurityService

    def show(Long id) {
        def booking = CrmTaskBooking.get(id)
        if (!booking) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def crmTask = booking.task
        if (crmTask.tenantId != TenantUtils.tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        // TODO make it possible to customize the sort algorithm.
        def attenders = CrmTaskUiUtils.sortByExternalId(booking.attenders)
        def metadata = [statusList: CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
        [crmTaskBooking: booking, crmTask: crmTask, attenders: attenders, metadata: metadata]
    }

    @Transactional
    def edit(Long id) {
        def booking = CrmTaskBooking.get(id)
        if (!booking) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def crmTask = booking.task
        if (crmTask.tenantId != TenantUtils.tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }

        if (request.post) {
            def user = crmSecurityService.getUserInfo(params.username ?: crmTask.username)
            if (!user) {
                user = crmSecurityService.getUserInfo(null)
            }
            def date = params.remove('bookingDate')
            bindData(booking, params)
            bindDate(booking, 'bookingDate', date, user?.timezone)

            if (!booking.save()) {
                def metadata = [:]
                render view: 'edit', model: [crmTaskBooking: booking, crmTask: crmTask, metadata: metadata]
            } else {
                flash.success = message(code: 'crmTaskBooking.updated.message', args: [message(code: 'crmTaskBooking.label', default: 'Booking'), booking.toString()])
                redirect action: 'show', id: booking.id
            }
        } else {
            def metadata = [:]
            [crmTaskBooking: booking, crmTask: crmTask, metadata: metadata]
        }
    }

    private void bindDate(CrmTaskBooking booking, String property, String value, TimeZone timezone = null) {
        if (value) {
            try {
                booking[property] = DateUtils.parseDateTime(value, timezone ?: TimeZone.default)
            } catch (Exception e) {
                log.error("error", e)
                def entityName = message(code: 'crmTaskBooking.label', default: 'Booking')
                def propertyName = message(code: 'crmTaskBooking.' + property + '.label', default: property)
                booking.errors.rejectValue(property, 'default.invalid.date.message', [propertyName, entityName, value.toString(), e.message].toArray(), "Invalid date: {2}")
            }
        } else {
            booking[property] = null
        }
    }

    @Transactional
    def updateAttenders(Long booking, Long status) {
        def tenant = TenantUtils.tenant
        def crmTaskBooking = CrmTaskBooking.get(booking)
        if (!booking) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def crmTask = crmTaskBooking.task
        if (crmTask.tenantId != tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def attenderStatus = CrmTaskAttenderStatus.findByIdAndTenantId(status, tenant)
        if (!attenderStatus) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No CrmTaskAttenderStatus found with id [$status]")
            return
        }
        List<Long> attenders = params.list('attenders')
        for (a in attenders) {
            CrmTaskAttender attender = CrmTaskAttender.findByIdAndBooking(a, crmTaskBooking)
            if (attender) {
                attender.status = attenderStatus
            } else {
                log.error("No CrmTaskAttender found with id [$a] in tenant [$tenant]")
            }
        }
        def linkParams = [id: crmTaskBooking.id]
        if (params.sort) {
            linkParams.sort = params.sort
        }
        if (params.order) {
            linkParams.order = params.order
        }
        flash.success = "Status uppdaterades för ${attenders.size()} st deltagare".toString()

        redirect(action: "show", params: linkParams)
    }

}
