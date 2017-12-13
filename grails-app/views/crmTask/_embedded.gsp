<%@ page import="org.apache.commons.lang.StringUtils" %>
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
</style>

<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmTask.date.label" default="Date"/></th>
        <th><g:message code="crmTask.name.label" default="Name"/></th>
        <th><g:message code="crmTask.type.label" default="Type"/></th>
        <th><g:message code="crmTask.complete.label" default="Status"/></th>
        <th><g:message code="crmTaskAttender.status.label" default="Participant"/></th>
        <th><g:message code="crmTask.description.label" default="Notes"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="a">
        <g:set var="crmTaskBooking" value="${a.booking}"/>
        <g:set var="crmTask" value="${crmTaskBooking.task}"/>
        <tr class="crm-status-${a.status.param}">
            <td>
                <g:link controller="crmTaskAttender" action="show" params="${[id: a.id, narrow: 'task']}">
                    <g:formatDate type="date" date="${crmTask.startTime}"/>
                </g:link>
            </td>

            <td>
                <g:link controller="crmTaskAttender" action="show" id="${a.id}">
                    ${fieldValue(bean: crmTask, field: "name")}
                </g:link>
            </td>

            <td>
                ${fieldValue(bean: crmTask, field: "type")}
            </td>

            <td>
                ${message(code: 'crmTask.complete.' + crmTask.complete + '.label', default: crmTask.complete.toString())}
            </td>

            <td>
                ${fieldValue(bean: a, field: "status")}
            </td>

            <td>${StringUtils.abbreviate(((a.notes ?: crmTaskBooking.comments) ?: crmTask.description) ?: '', 40)}</td>
        </tr>
    </g:each>
    </tbody>
</table>

<g:if test="${createParams}">
    <div class="form-actions btn-toolbar">
        <crm:button type="link" group="true" controller="crmTask" action="create" visual="success"
                    icon="icon-file icon-white"
                    label="crmTask.button.create.label"
                    title="crmTask.button.create.help"
                    permission="crmTask:create"
                    params="${createParams + [referer: request.forwardURI]}">
        </crm:button>
    </div>
</g:if>