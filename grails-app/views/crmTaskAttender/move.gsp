<%@ page import="grails.plugins.crm.task.CrmTaskAttender" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskAttender.label', default: 'Attender')}"/>
    <title><g:message code="crmTaskAttender.move.title" args="[entityName, crmTaskAttender]"/></title>

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

    <header class="page-header crm-status-${crmTaskAttender.status.param}">
        <crm:user>
            <h1>
                ${crmTaskAttender}
                <small>
                    ${crmTask}
                </small>
            </h1>
        </crm:user>
    </header>

    <g:form action="move" id="${crmTaskAttender.id}">

        <div class="row-fluid">

            <table class="table table-condensed">
                <thead>
                <tr>
                    <th><g:message code="crmTaskAttender.move.title" args="[entityName, crmTaskAttender]"/></th>
                    <th><g:message code="crmTaskAttender.label"/></th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td>
                        <label class="radio">
                            <g:radio name="booking" value="0" checked="true"/>
                            Ny bokning
                        </label>
                    </td>
                    <td></td>
                </tr>
                <g:each in="${bookingList}" var="booking">
                    <tr>
                        <td>
                            <label class="radio">
                                <g:radio name="booking" value="${booking.id}"/>
                                ${booking}
                            </label>
                        </td>
                        <td>
                            <g:set var="itor" value="${booking.attenders.iterator()}"/>
                            <g:if test="${itor.hasNext()}">
                                <div>${itor.next()}</div>
                            </g:if>
                            <g:if test="${itor.hasNext()}">
                                <div>${itor.next()}</div>
                            </g:if>
                            <g:if test="${itor.hasNext()}">
                                <div>${itor.next()}</div>
                            </g:if>
                            <g:if test="${itor.hasNext()}">
                                &hellip; (${booking.attenders.size()})
                            </g:if>
                        </td>
                    </tr>
                </g:each>
                </tbody>
            </table>
        </div>

        <div class="form-actions">
            <crm:button action="move" visual="warning" icon="icon-ok icon-white"
                        label="crmTaskAttender.button.move.label"/>
        </div>
    </g:form>

</body>
</html>