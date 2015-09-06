<%@ page import="grails.plugins.crm.contact.CrmContact; org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskAttender.label', default: 'Attender')}"/>
    <title><g:message code="crmTaskAttender.show.title" args="[entityName, crmTaskAttender]"/></title>

    <style type="text/css">
    .crm-status-confirmed,
    .crm-status-attended {
        color: #009900;
    }
    .crm-status-cancelled {
        color: #f89406;
    }
    .crm-status-absent {
        color: #9d261d;
    }
    </style>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header crm-status-${crmTaskAttender.status.param}">
            <crm:user>
                <h1>
                    ${crmTaskAttender}
                    <small>${crmTask}</small>
                </h1>
            </crm:user>
        </header>

        <g:set var="contact" value="${crmTaskAttender.contactInformation}"/>

        <div class="row-fluid">

            <div class="span6">

                <div class="row-fluid">

                    <dl>

                        <g:if test="${contact.companyName}">
                            <dt><g:message code="crmTaskAttender.company.label" /></dt>
                            <dd>${contact.companyName}</dd>
                        </g:if>

                        <dt><g:message code="crmTaskAttender.person.label" /></dt>
                        <dd>
                            <g:if test="${contact instanceof grails.plugins.crm.contact.CrmContact}">
                                <g:link mapping="crm-contact-show" id="${contact.id}">
                                    ${contact.name}
                                </g:link>
                            </g:if>
                            <g:else>
                                ${contact.name}
                                <i class="icon-leaf"></i>
                            </g:else>
                        </dd>

                        <g:if test="${contact.title}">
                            <dt><g:message code="crmContact.title.label" /></dt>
                            <dd>${contact.title}</dd>
                        </g:if>

                        <g:if test="${contact.fullAddress}">
                            <dt><g:message code="crmTaskAttender.address.label" /></dt>
                            <dd>${contact.fullAddress}</dd>
                        </g:if>

                        <g:if test="${contact.telephone}">
                            <dt><g:message code="crmTaskAttender.telephone.label" /></dt>
                            <dd>${contact.telephone}</dd>
                        </g:if>

                        <g:if test="${contact.email}">
                            <dt><g:message code="crmTaskAttender.email.label" /></dt>
                            <dd>${contact.email}</dd>
                        </g:if>

                        <g:if test="${crmTaskAttender.hide}">
                            <dt><g:message code="crmTaskAttender.hidden.label" /></dt>
                            <dd>&nbsp;</dd>
                        </g:if>

                    </dl>

                </div>
            </div>

            <div class="span6">
                <div class="row-fluid">

                    <dl>
                        <dt><g:message code="crmTaskAttender.status.label" /></dt>
                        <dd>${crmTaskAttender.status}</dd>

                        <g:if test="${crmTaskAttender.bookingId}">
                            <dt><g:message code="crmTaskAttender.booking.label" /></dt>
                            <dd>
                                <g:link controller="crmTaskBooking" action="show" id="${crmTaskAttender.bookingId}">
                                    ${crmTaskAttender.booking.bookingRef ?: crmTaskAttender.booking}
                                </g:link>
                            </dd>
                        </g:if>

                        <g:if test="${crmTaskAttender.bookingRef}">
                            <dt><g:message code="crmTaskAttender.bookingRef.label" /></dt>
                            <dd>${crmTaskAttender.bookingRef}</dd>
                        </g:if>

                        <dt><g:message code="crmTaskAttender.bookingDate.label" /></dt>
                        <dd>${formatDate(type: 'date', date: crmTaskAttender.bookingDate ?: new Date())}</dd>

                        <g:if test="${crmTaskAttender.source}">
                            <dt><g:message code="crmTaskAttender.source.label" /></dt>
                            <dd>${crmTaskAttender.source}</dd>
                        </g:if>

                        <g:if test="${crmTaskAttender.externalRef}">
                            <dt><g:message code="crmTaskAttender.externalRef.label" /></dt>
                            <dd>${crmTaskAttender.externalRef}</dd>
                        </g:if>

                        <g:if test="${crmTaskAttender.description}">
                            <dt><g:message code="crmTaskAttender.notes.label" /></dt>
                            <dd>${crmTaskAttender.description}</dd>
                        </g:if>
                    </dl>

                </div>
            </div>
        </div>

        <div class="form-actions">
            <crm:button type="link" group="true" action="edit" id="${crmTaskAttender.id}" visual="warning"
                        icon="icon-pencil icon-white"
                        label="crmTaskAttender.button.edit.label" permission="crmTaskAttender:edit">
                <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <li>
                        <g:link action="move" id="${crmTaskAttender.id}">
                            <g:message code="crmTaskAttender.move.label" default="Move to another booking"/>
                        </g:link>
                    </li>
                </ul>
            </crm:button>
            <g:link controller="crmTaskBooking" action="show" id="${crmTaskAttender.bookingId}" class="btn">
                <i class="icon-glass"></i>
                <g:message code="crmTaskBooking.label" default="Booking"/>
            </g:link>
        </div>

    </div>

    <div class="span3">
        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTaskAttender]}"/>
    </div>

</div>

</body>
</html>