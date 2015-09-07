<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskBooking.label', default: 'Booking')}"/>
    <title><g:message code="crmTaskBooking.show.title" args="[entityName, crmTaskBooking]"/></title>
    <r:require modules="datepicker,autocomplete"/>

    <r:script>

        function updateAttenders(property, value) {
            if (property == 'status') {
                var $form = $("#attender-change-form");
                $("input[name='status']", $form).val(value);
                $form.submit();
            }
            return false;
        }

        $(document).ready(function () {
            $("#changeAll").click(function (event) {
                $(":checkbox[name='attenders']", $(this).closest('form')).prop('checked', $(this).is(':checked'));
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

    tr.crm-attender i {
        margin-left: 3px;
    }
    </style>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <crm:user>
                <h1>
                    ${crmTaskBooking}
                    <small>${crmTask}</small>
                </h1>
            </crm:user>
        </header>

        <div class="row-fluid">
            <div class="span6">

                <dl>
                    <dt><g:message code="crmTaskBooking.task.label"/></dt>
                    <dd><g:fieldValue bean="${crmTask}" field="name"/></dd>

                    <dt><g:message code="crmTaskBooking.bookingDate.label"/></dt>
                    <dd><g:fieldValue bean="${crmTaskBooking}" field="bookingDate"/></dd>

                    <g:if test="${crmTaskBooking.bookingRef}">
                        <dt><g:message code="crmTaskBooking.bookingRef.label"/></dt>
                        <dd><g:fieldValue bean="${crmTaskBooking}" field="bookingRef"/></dd>
                    </g:if>

                    <g:if test="${crmTaskBooking.contact}">
                        <dt><g:message code="crmTaskBooking.contact.label"/></dt>
                        <dd><g:fieldValue bean="${crmTaskBooking}" field="contact"/></dd>
                    </g:if>
                </dl>
            </div>

            <div class="span6">
                <g:if test="${crmTaskBooking.invoiceAddress}">
                    <dl>
                        <dt><g:message code="crmTaskBooking.invoiceAddress.label"/></dt>
                        <dd>${crmTaskBooking.invoiceAddress}</dd>
                    </dl>
                </g:if>
            </div>
        </div>

        <g:if test="${crmTaskBooking.comments}">
            <div class="row-fluid">
                <dl>
                    <dt><g:message code="crmTaskBooking.comments.label"/></dt>
                    <dd><g:decorate encode="HTML" nlbr="true"><g:fieldValue bean="${crmTaskBooking}" field="comments"/></g:decorate></dd>
                </dl>
            </div>
        </g:if>

        <h3><g:message code="crmTaskBooking.attenders.title"/></h3>

        <g:form name="attender-change-form" action="updateAttenders">

            <g:hiddenField name="booking" value="${crmTaskBooking?.id}"/>
            <g:hiddenField name="task" value="${crmTask?.id}"/>
            <g:hiddenField name="status" value=""/>
            <g:hiddenField name="sort" value="${params.sort}"/>
            <g:hiddenField name="order" value="${params.order}"/>

            <table class="table table-striped">
                <thead>
                <tr>
                    <th><g:message code="crmContact.name.label" default="Name"/></th>
                    <th><g:message code="crmTaskAttender.address.label"/></th>
                    <th><g:message code="crmTaskAttender.status.label"/></th>
                    <th><g:checkBox name="changeAll"
                                    title="${message(code: 'crmTaskAttender.button.select.all.label', default: 'Select all')}"/></th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${attenders}" var="m">
                    <g:set var="contactInfo" value="${m.contactInformation}"/>
                    <tr class="crm-status-${m.status.param} crm-attender" data-crm-booking="${m.bookingId ?: ''}">

                        <td>
                            <g:link controller="crmTaskAttender" action="show" id="${m.id}">
                                    ${fieldValue(bean: contactInfo, field: "fullName")}
                            </g:link>
                        </td>

                        <td class="${m.hide ? 'muted' : ''}">
                            ${contactInfo.address?.encodeAsHTML()}
                        </td>

                        <g:set var="tags" value="${m.getTagValue()}"/>
                        <td>
                            <g:unless test="${m.contact}">
                                <i class="icon-leaf pull-right"></i>
                            </g:unless>
                            <g:if test="${tags}">
                                <i class="icon-tags pull-right" title="${tags?.join(', ')}"></i>
                            </g:if>
                            <g:if test="${m.@notes}">
                                <i class="icon-comment pull-right" title="${m.@notes}"></i>
                            </g:if>

                            <g:fieldValue bean="${m}" field="status"/>
                        </td>
                        <td>
                            <input type="checkbox" name="attenders" value="${m.id}"/>
                        </td>
                    </tr>
                </g:each>
                </tbody>
            </table>

            <div class="form-actions">

                <g:if test="${attenders}">
                    <crm:button type="link" group="true" action="edit" id="${crmTaskBooking.id}"
                                visual="warning"
                                icon="icon-pencil icon-white"
                                label="crmTaskBooking.button.edit.label"
                                title="crmTaskBooking.button.edit.help"
                                permission="crmTaskBooking:edit">
                        <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <crm:hasPermission permission="crmTask:edit">
                                <g:each in="${metadata.statusList}" var="status">
                                    <li>
                                        <a href="javascript:void(0)"
                                           onclick="updateAttenders('status', ${status.id})">${status.encodeAsHTML()}</a>
                                    </li>
                                </g:each>
                            </crm:hasPermission>
                        </ul>
                    </crm:button>
<%--
                    <div class="btn-group">
                        <button class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                            <i class="icon-print icon-white"></i>
                            <g:message code="crmTaskAttender.button.print.label" default="Print"/>
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <li>
                                <select:link action="export" params="${[ns: 'crmTaskAttender']}"
                                             selection="${new URI('bean://crmTaskService/list?id=' + crmTask.id)}">
                                    <g:message code="crmTask.print.attenders.label" default="Attender list"/>
                                </select:link>
                            </li>
                        </ul>
                    </div>
--%>
                </g:if>
                <g:else>

                    <crm:button type="link" action="edit" id="${crmTaskBooking.id}" visual="warning"
                                icon="icon-pencil icon-white"
                                label="crmTask.button.edit.label" permission="crmTaskBooking:edit"/>
                </g:else>

                <crm:hasPermission permission="crmTaskBooking:edit">
                    <g:link controller="crmTaskAttender" action="create"
                            params="${[id: crmTask.id, booking: crmTaskBooking.id]}"
                            class="btn btn-success" accesskey="n">
                        <i class="icon-user icon-white"></i>
                        <g:message code="crmTask.button.book.label"/>
                    </g:link>
                </crm:hasPermission>

                <g:link controller="crmTask" action="show" id="${crmTask.id}" fragment="attender" class="btn">
                    <i class="icon-calendar"></i>
                    <g:message code="crmTask.label"/>
                </g:link>

            </div>

        </g:form>

    </div>

    <div class="span3">
        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTaskBooking]}"/>
    </div>

</div>

</body>
</html>