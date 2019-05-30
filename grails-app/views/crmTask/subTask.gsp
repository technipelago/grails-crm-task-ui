<%@ page contentType="text/html;charset=UTF-8" import="org.apache.commons.lang.StringUtils; org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Event')}"/>
    <title><g:message code="crmTask.subTask.title" args="[entityName, crmTask]"/></title>
    <r:script>
        $(document).ready(function () {
            $('#changeAll').click(function (event) {
                $(":checkbox[name='selected']", $(this).closest('form')).prop('checked', $(this).is(':checked'));
            });
        });
    </r:script>

    <style type="text/css">
    tr.crm-status-confirmed td,
    tr.crm-status-attended td {
        color: #009900;
        background-color: #eeffee !important;
    }

    tr.crm-status-cancelled td {
        color: #f89406;
        background-color: #eeeeff !important;
    }

    tr.crm-status-absent td {
        color: #9d261d;
        background-color: #ffeeee !important;
    }

    tr.selected td {
        background-color: #f9ccff !important;
    }

    tr.crm-attender i {
        margin-right: 5px;
    }

    tr.crm-attender i:last-child {
        margin-right: 0;
    }
    </style>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <img src="${resource(dir: 'images', file: 'calendar-icon.png')}" class="avatar pull-right"
                 width="64" height="64"/>
            <crm:user>
                <h1>
                    <g:message code="crmTask.button.subTask.label"/>
                    <small>${crmTask.name}</small>
                </h1>
            </crm:user>
        </header>

        <g:form action="subTask">

            <input type="hidden" name="id" value="${crmTask.id}"/>

            <table class="table table-striped">
                <thead>
                <tr>
                    <th>#</th>
                    <th><g:message code="crmContact.name.label" default="Name"/></th>
                    <th><g:message code="crmContact.company.label"/></th>
                    <th colspan="2"><g:message code="crmTaskAttender.status.label"/></th>
                    <th>
                        <g:checkBox name="changeAll"
                                    title="${message(code: 'crmTaskAttender.button.select.all.label', default: 'Select all')}"/>
                    </th>
                </tr>
                </thead>

                <tbody>
                <g:set var="selectedAttenderIds" value="${attenders.collect { it.virtualId }}"/>

                <g:each in="${allAttenders}" var="m">
                    <g:set var="contactInfo" value="${m.contactInformation}"/>

                    <tr class="crm-status-${m.status.param} crm-attender">

                        <td>
                            <g:link controller="crmTaskBooking" action="show" id="${m.bookingId}" class="crm-booking">
                                <g:if test="${m.booking.bookingRef}">
                                    <g:fieldValue bean="${m.booking}" field="bookingRef"/>
                                </g:if>
                                <g:else>
                                    <i class="icon-glass"></i>
                                </g:else>
                            </g:link>
                        </td>

                        <td>
                            <g:link controller="crmTaskAttender" action="show" id="${m.id}">
                                ${fieldValue(bean: contactInfo, field: "name")}
                            </g:link>
                        </td>

                        <td class="${m.hide ? 'muted' : ''}">
                            ${contactInfo.companyName?.encodeAsHTML()}
                        </td>

                        <td>
                            <g:fieldValue bean="${m}" field="status"/>
                        </td>

                        <g:set var="tags" value="${m.getTagValue().sort()}"/>
                        <td style="width: 92px;text-align:right;">
                            <g:if test="${m.food}">
                                <i class="icon-warning-sign" title="${StringUtils.abbreviate(m.food, 100)}"></i>
                            </g:if>
                            <g:if test="${m.description}">
                                <i class="icon-comment" title="${StringUtils.abbreviate(m.description, 100)}"></i>
                            </g:if>
                            <g:if test="${tags}">
                                <i class="icon-tags" title="${tags.join(', ')}"></i>
                            </g:if>
                            <g:unless test="${m.contact}">
                                <i class="icon-leaf"></i>
                            </g:unless>
                        </td>

                        <td>
                            <g:checkBox name="selected" id="selected-${m.id}" value="${m.id}"
                                        checked="${selectedAttenderIds.contains(m.virtualId)}"/>
                        </td>
                    </tr>
                </g:each>

                </tbody>
            </table>

            <div class="form-actions">
                <crm:button visual="success" icon="icon-plus icon-white" label="crmTaskAttender.button.add.label"/>
                <crm:button type="link" action="show" id="${crmTask.id}" fragment="attender"
                            icon="icon-remove"
                            label="crmTask.button.cancel.label"/>
            </div>

        </g:form>

    </div>

    <div class="span3">
    </div>

</div>

</body>
</html>
