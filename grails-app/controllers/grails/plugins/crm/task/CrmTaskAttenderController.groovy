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

import grails.plugins.crm.contact.CrmContact
import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.CrmAddress
import grails.plugins.crm.core.CrmEmbeddedAddress
import grails.transaction.Transactional
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.dao.DataIntegrityViolationException

import javax.servlet.http.HttpServletResponse

/**
 * Created by goran on 15-06-26.
 */
class CrmTaskAttenderController {

    private static final List ATTENDER_WHITELIST = ['notes', 'status', 'hide', 'bookingRef', 'externalRef']
    private static
    final List CONTACT_WHITELIST = CrmAddress.BIND_WHITELIST + ['firstName', 'lastName', 'companyName', 'title']

    def crmTaskService
    def crmContactService
    def crmSecurityService

    def show(Long id) {
        final CrmTaskAttender crmTaskAttender = CrmTaskAttender.get(id)
        if (!crmTaskAttender) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        final CrmTaskBooking crmTaskBooking = crmTaskAttender.booking
        final CrmTask crmTask = crmTaskBooking.task
        if (crmTask.tenantId != TenantUtils.tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND) // Forbidden
            return
        }

        [crmTaskAttender: crmTaskAttender, crmTaskBooking: crmTaskBooking, crmTask: crmTask,
         statusList     : CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
    }

    @Transactional
    def create(Long id) {
        CrmTask crmTask = CrmTask.get(id)
        if (!crmTask) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        if (crmTask.tenantId != TenantUtils.tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND) // Forbidden
            return
        }

        def crmTaskBooking = new CrmTaskBooking(task: crmTask)
        def crmTaskAttender = new CrmTaskAttender(booking: crmTaskBooking)
        def bookingList = crmTask.bookings

        if (request.post) {
            try {
                boolean newBooking = params['booking.id'] == '0'
                if (newBooking) {
                    crmTaskBooking.bookingRef = params.externalRef ?: params.bookingRef // TODO This is IVA specific!
                    if(crmTaskBooking.validate()) {
                        crmTask.addToBookings(crmTaskBooking)
                    } else {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST) // TODO this is a little hard
                        return
                    }
                } else {
                    bindData(crmTaskAttender, params, [include: ['booking']])
                    crmTaskBooking = crmTaskAttender.booking
                    if(crmTaskBooking?.taskId != crmTask.id) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST)
                        return
                    }
                }
                def currentUser = crmSecurityService.getUserInfo()
                bindData(crmTaskAttender, params, [include: ATTENDER_WHITELIST])
                bindDate(crmTaskAttender, 'bookingDate', params.bookingDate, currentUser.timezone)
                fixContact(crmTaskAttender, params, params.boolean('createContact'))
                if (!crmTaskAttender.contact && crmTaskAttender.tmp) {
                    bindData(crmTaskAttender.tmp, params, [include: CONTACT_WHITELIST])
                }
                if(newBooking) {
                    if(crmTaskAttender.bookingDate) {
                        crmTaskBooking.bookingDate = crmTaskAttender.bookingDate
                    }
                    def addr = crmTaskAttender.getContactInformation()?.getAddressInformation()
                    if(addr) {
                        if(crmTaskBooking.invoiceAddress == null) {
                            crmTaskBooking.invoiceAddress = new CrmEmbeddedAddress()
                        }
                        addr.copyTo(crmTaskBooking.invoiceAddress)
                    }
                }
                if (crmTask.save(flush: true) && crmTaskAttender.save()) {
                    if (crmTaskAttender.contact) {
                        rememberDomain(crmTaskAttender.contact)
                    }
                    flash.success = message(code: 'crmTaskAttender.created.message', args: [message(code: 'crmTaskAttender.label', default: 'Attender'), crmTaskAttender.toString()])
                    redirect action: "show", id: crmTaskAttender.id
                    return
                }
            } catch (Exception e) {
                flash.error = e.getLocalizedMessage()
            }
            render view: 'create', model: [crmTaskAttender: crmTaskAttender, crmTask: crmTask, bookingList: bookingList,
                                           statusList     : CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
        } else {
            return [crmTaskAttender: crmTaskAttender, crmTask: crmTask, bookingList: bookingList,

                    statusList     : CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
        }
    }

    @Transactional
    def edit(Long id) {
        final CrmTaskAttender crmTaskAttender = CrmTaskAttender.get(id)
        if (!crmTaskAttender) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        final CrmTaskBooking crmTaskBooking = crmTaskAttender.booking
        final CrmTask crmTask = crmTaskBooking.task
        if (crmTask.tenantId != TenantUtils.tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND) // Forbidden
            return
        }
        def contact = crmTaskAttender.contactInformation
        def address = contact?.addressInformation

        if (request.post) {
            try {
                def currentUser = crmSecurityService.getUserInfo()
                bindData(crmTaskAttender, params, [include: ATTENDER_WHITELIST])
                bindDate(crmTaskAttender, 'bookingDate', params.bookingDate, currentUser.timezone)
                fixContact(crmTaskAttender, params, params.boolean('createContact'))
                if (!crmTaskAttender.contact && crmTaskAttender.tmp) {
                    bindData(crmTaskAttender.tmp, params, [include: CONTACT_WHITELIST])
                }
                if (params['booking.id'] == '0') {
                    crmTaskAttender.booking = new CrmTaskBooking(task: crmTask, bookingDate: crmTaskAttender.bookingDate).save()
                } else {
                    bindData(crmTaskAttender, params, [include: ['booking']])
                }
                if (crmTaskAttender.save()) {
                    if (crmTaskAttender.contact) {
                        rememberDomain(crmTaskAttender.contact)
                    }
                    flash.success = message(code: 'crmTaskAttender.updated.message', args: [message(code: 'crmTaskAttender.label', default: 'Attender'), crmTaskAttender.toString()])
                    redirect action: "show", id: crmTaskAttender.id
                    return
                }
            } catch (Exception e) {
                flash.error = e.getLocalizedMessage()
            }
            render view: 'edit', model: [crmTaskAttender: crmTaskAttender, crmTaskBooking: crmTaskBooking, crmTask: crmTask,
                                         contact        : contact, address: address,
                                         statusList     : CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
        } else {
            return [crmTaskAttender: crmTaskAttender, crmTaskBooking: crmTaskBooking, crmTask: crmTask,
                    contact        : contact, address: address,
                    statusList     : CrmTaskAttenderStatus.findAllByTenantId(crmTask.tenantId)]
        }
    }

    private void bindDate(CrmTaskAttender crmTaskAttender, String property, String value, TimeZone timezone = null) {
        if (value) {
            try {
                crmTaskAttender[property] = DateUtils.parseDateTime(value, timezone ?: TimeZone.default)
            } catch (Exception e) {
                log.error("error", e)
                def entityName = message(code: 'crmTask.label', default: 'Task')
                def propertyName = message(code: 'crmTask.' + property + '.label', default: property)
                crmTaskAttender.errors.rejectValue(property, 'default.invalid.date.message', [propertyName, entityName, value.toString(), e.message].toArray(), "Invalid date: {2}")
            }
        } else {
            crmTaskAttender[property] = null
        }
    }

    private void fixContact(CrmTaskAttender attender, GrailsParameterMap params, Boolean add) {
        def tenant = TenantUtils.tenant
        CrmContact contact = params['contactId'] ? CrmContact.findByIdAndTenantId(params.long('contactId'), tenant) : null
        if (contact) {
            attender.contact = contact
        } else if (add) {
            def address = CrmAddress.BIND_WHITELIST.inject([:]) { map, p ->
                map[p] = params[p]
                map
            }
            def company = params['companyId'] ? CrmContact.findByIdAndTenantId(params.long('companyId'), tenant) : null
            if (params.companyName && !company) {
                company = crmContactService.createCompany(name: params.companyName,
                        telephone: params.telephone, email: params.email, address: address,
                        true)
                params['companyId'] = company.ident()
            }

            // A contact name is specified but it's not an existing contact.
            // Create a new person.
            def person
            if (params.firstName) {
                if (company?.hasErrors()) {
                    company = null // TODO lame...
                }
                if (company) {
                    address = null // Inherit address form company
                }
                person = crmContactService.createPerson(related: company, firstName: params.firstName, lastName: params.lastName,
                        title: params.title, telephone: params.telephone, email: params.email, address: address,
                        true)
                params['contactId'] = person.ident()
                if (!person.hasErrors()) {
                    attender.contact = person
                    attender.tmp = null
                }
            }
        } else {
            attender.contact = null
            bindData(attender.contactInformation, params,
                    [include: ['firstName', 'lastName', 'companyName', 'companyId', 'title', 'telephone', 'email']])
        }
    }

    @Transactional
    def delete(Long id) {
        final CrmTaskAttender crmTaskAttender = CrmTaskAttender.get(id)
        if (!crmTaskAttender) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        final CrmTaskBooking crmTaskBooking = crmTaskAttender.booking
        final Long bookingId = crmTaskBooking.id
        final CrmTask crmTask = crmTaskBooking.task
        if (crmTask.tenantId != TenantUtils.tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND) // Forbidden
            return
        }
        try {
            def tombstone = crmTaskService.deleteAttender(crmTaskAttender)
            flash.warning = message(code: 'crmTaskAttender.deleted.message', args: [message(code: 'crmTaskAttender.label', default: 'Attender'), tombstone])
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmTaskAttender.not.deleted.message', args: [message(code: 'crmTaskAttender.label', default: 'Attender'), id])
        }

        if(CrmTaskBooking.findById(bookingId)) {
            redirect(controller: 'crmTaskBooking', action: "show", id: bookingId)
        } else {
            redirect(controller: 'crmTask', action: "show", id: crmTask.id, fragment: "attender")
        }
    }

    @Transactional
    def move(Long id, Long booking) {
        final CrmTaskAttender crmTaskAttender = CrmTaskAttender.get(id)
        if (!crmTaskAttender) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        final CrmTaskBooking oldBooking = crmTaskAttender.booking
        final CrmTask crmTask = oldBooking.task
        if (crmTask.tenantId != TenantUtils.tenant) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND) // Forbidden
            return
        }

        if (request.post) {
            def destination
            if (booking) {
                destination = CrmTaskBooking.get(booking)
                if (destination?.taskId != oldBooking.taskId) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST)
                    return
                }
            } else {
                destination = crmTaskService.createBooking(task: crmTask, bookingDate: crmTaskAttender.bookingDate, true)
                if (destination.hasErrors()) {
                    log.error "Failed to create new CrmTaskBooking instance: ${destination.errors.allErrors}"
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST)
                    return
                }
            }
            crmTaskService.moveAttender(crmTaskAttender, destination, true)
            flash.warning = message(code: 'crmTaskAttender.moved.message', args: [message(code: 'crmTaskAttender.label', default: 'Attender'),
                                                                                  crmTaskAttender.toString(), oldBooking.toString()])
            redirect action: 'show', id: id
        } else {
            def bookingId = oldBooking.id
            return [crmTaskAttender: crmTaskAttender, crmTaskBooking: oldBooking, crmTask: crmTask,
                    bookingList    : crmTask.bookings.findAll { it.id != bookingId }]
        }
    }
}
