<%@ page import="grails.plugins.crm.contact.CrmContact; org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskAttender.label', default: 'Attender')}"/>
    <title><g:message code="crmTaskAttender.show.title" args="[entityName, crmTaskAttender]"/></title>
    <r:script>
        $(document).ready(function () {
            $('.crm-duplicate').click(function (ev) {
                ev.preventDefault();
                $(this).closest('form').submit();
            });
        });
    </r:script>
    <style type="text/css">
    .crm-status-confirmed .crm-status,
    .crm-status-attended .crm-status {
        color: #009900;
    }
    .crm-status-cancelled .crm-status {
        color: #f89406;
    }
    .crm-status-absent .crm-status {
        color: #9d261d;
    }
    .crm-status-confirmed header,
    .crm-status-attended header {
        border-bottom: 3px solid #009900;
    }
    .crm-status-cancelled header {
        border-bottom: 3px solid #f89406;
    }
    .crm-status-absent header {
        border-bottom: 3px solid #9d261d;
    }
    </style>
</head>

<body>
<div class="crm-status-${crmTaskAttender.status.param}">

<g:set var="contact" value="${crmTaskAttender.contactInformation}"/>
<g:set var="address" value="${contact.addressInformation}"/>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header clearfix">
            <img src="${resource(plugin: 'crm-contact-ui', dir: 'images', file: 'person-avatar.png')}" class="avatar pull-right"
                     width="64" height="64"/>
            <h1>
                ${crmTaskAttender}
                <small>${crmTask}</small>
            </h1>
        </header>

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmTaskAttender.tab.main.label"/></a>
                </li>
                <crm:pluginViews location="tabs" var="view">
                    <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
                </crm:pluginViews>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="main">

        <g:form mapping="crm-contact-duplicates">

            <input type="hidden" name="referer" value="${request.forwardURI}"/>
            <input type="hidden" name="matchController" value="crmTaskAttender"/>
            <input type="hidden" name="matchAction" value="match"/>
            <input type="hidden" name="matchId" value="${crmTaskAttender.id}"/>

            <input type="hidden" name="number" value="${contact.number}"/>
            <input type="hidden" name="name" value="${contact.name}"/>
            <input type="hidden" name="firstName" value="${contact.firstName}"/>
            <input type="hidden" name="lastName" value="${contact.lastName}"/>
            <input type="hidden" name="email" value="${contact.email}"/>
            <input type="hidden" name="telephone" value="${contact.telephone}"/>
            <input type="hidden" name="title" value="${contact.title}"/>
            <input type="hidden" name="companyName" value="${contact.companyName}"/>
            <input type="hidden" name="address.address1" value="${address?.address1}"/>
            <input type="hidden" name="address.address2" value="${address?.address2}"/>
            <input type="hidden" name="address.address3" value="${address?.address3}"/>
            <input type="hidden" name="address.postalCode" value="${address?.postalCode}"/>
            <input type="hidden" name="address.city" value="${address?.city}"/>
            <input type="hidden" name="address.country" value="${address?.country}"/>

            <div class="row-fluid">

                <div class="span6">

                    <div class="row-fluid">

                        <dl>

                            <g:if test="${contact.companyName}">
                                <dt><g:message code="crmTaskAttender.company.label"/></dt>
                                <dd>
                                    <g:if test="${contact.companyId}">
                                        <g:link mapping="crm-contact-show" id="${contact.companyId}">
                                            ${contact.companyName}
                                        </g:link>
                                    </g:if>
                                    <g:else>
                                        ${contact.companyName}
                                    </g:else>
                                </dd>
                            </g:if>

                            <dt><g:message code="crmTaskAttender.person.label"/></dt>
                            <dd>
                                <g:if test="${contact instanceof grails.plugins.crm.contact.CrmContact}">
                                    <g:link mapping="crm-contact-show" id="${contact.id}">
                                        ${contact.name}
                                    </g:link>
                                </g:if>
                                <g:else>
                                    ${contact.name}
                                    <a href="javascript:void(0);" class="crm-duplicate"><i class="icon-leaf"></i></a>
                                </g:else>
                            </dd>

                            <g:if test="${contact.title}">
                                <dt><g:message code="crmContact.title.label"/></dt>
                                <dd>${contact.title}</dd>
                            </g:if>

                            <g:if test="${contact.fullAddress}">
                                <dt><g:message code="crmTaskAttender.address.label"/></dt>
                                <dd>${contact.fullAddress}</dd>
                            </g:if>

                            <g:if test="${contact.telephone}">
                                <dt><g:message code="crmTaskAttender.telephone.label"/></dt>
                                <dd>${contact.telephone}</dd>
                            </g:if>

                            <g:if test="${contact.email}">
                                <dt><g:message code="crmTaskAttender.email.label"/></dt>
                                <dd>${contact.email}</dd>
                            </g:if>

                            <g:if test="${crmTaskAttender.hide}">
                                <dt><g:message code="crmTaskAttender.hidden.label"/></dt>
                                <dd>&nbsp;</dd>
                            </g:if>

                        </dl>

                    </div>
                </div>

                <div class="span6">

                    <div class="row-fluid">

                        <dl>
                            <dt><g:message code="crmTaskAttender.status.label"/></dt>
                            <dd class="crm-status">${crmTaskAttender.status}</dd>

                            <g:if test="${crmTaskAttender.bookingId}">
                                <dt><g:message code="crmTaskAttender.booking.label"/></dt>
                                <dd>
                                    <g:link controller="crmTaskBooking" action="show" id="${crmTaskAttender.bookingId}">
                                        ${crmTaskAttender.booking.bookingRef ?: crmTaskAttender.booking}
                                    </g:link>
                                </dd>
                            </g:if>

                            <g:if test="${crmTaskAttender.bookingRef}">
                                <dt><g:message code="crmTaskAttender.bookingRef.label"/></dt>
                                <dd>${crmTaskAttender.bookingRef}</dd>
                            </g:if>

                            <dt><g:message code="crmTaskAttender.bookingDate.label"/></dt>
                            <dd>${formatDate(type: 'date', date: crmTaskAttender.bookingDate ?: new Date())}</dd>

                            <g:if test="${crmTaskAttender.source}">
                                <dt><g:message code="crmTaskAttender.source.label"/></dt>
                                <dd>${crmTaskAttender.source}</dd>
                            </g:if>

                            <g:if test="${crmTaskAttender.externalRef}">
                                <dt><g:message code="crmTaskAttender.externalRef.label"/></dt>
                                <dd>${crmTaskAttender.externalRef}</dd>
                            </g:if>

                            <g:if test="${crmTaskAttender.description}">
                                <dt><g:message code="crmTaskAttender.notes.label"/></dt>
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
                        <g:unless test="${contact instanceof grails.plugins.crm.contact.CrmContact}">
                            <li>
                                <a href="javascript:void(0);" class="crm-duplicate">
                                    <g:message code="crmTaskAttender.duplicate.find.label" default="Find matching contact"/>
                                </a>
                            </li>
                        </g:unless>
                        <crm:hasPermission permission="crmTask:edit">
                            <g:each in="${statusList}" var="status">
                                <li>
                                    <g:link action="status" params="${[id: crmTaskAttender.id, task: crmTask.id, status: status.param]}">
                                        ${status}
                                    </g:link>
                                </li>
                            </g:each>
                        </crm:hasPermission>
                    </ul>
                </crm:button>
                <g:link controller="crmTaskBooking" action="show" id="${crmTaskAttender.bookingId}" class="btn">
                    <i class="icon-glass"></i>
                    <g:message code="crmTaskAttender.button.booking.label" default="Booking"
                               args="${[crmTaskAttender.booking, crmTaskAttender.booking.attenders.size()]}"/>
                </g:link>
                <g:link controller="crmTask" action="show" id="${crmTaskAttender.booking.taskId}" fragment="attender"
                        class="btn">
                    <i class="icon-calendar"></i>
                    <g:message code="crmTask.label" default="Activity"/>
                </g:link>
            </div>

        </g:form>

        </div>

        <crm:pluginViews location="tabs" var="view">
            <div class="tab-pane tab-${view.id}" id="${view.id}">
                <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
            </div>
        </crm:pluginViews>

        </div>
        </div>
    </div>

    <div class="span3">
        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTaskAttender]}"/>
    </div>

</div>
</div>

</body>
</html>