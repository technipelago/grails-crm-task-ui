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
        <th><g:message code="crmTaskAttender.status.label" default="Status"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="a">
        <g:set var="crmTask" value="${a.task}"/>
        <tr class="crm-status-${a.status.param}">
            <td>
                <g:link controller="crmTask" action="show" id="${crmTask.id}">
                    <g:formatDate type="date" date="${crmTask.startTime}"/>
                </g:link>
            </td>

            <td>
                <g:link controller="crmTask" action="show" id="${crmTask.id}">
                    ${fieldValue(bean: crmTask, field: "name")}
                </g:link>
            </td>

            <td>
                ${fieldValue(bean: crmTask, field: "type")}
            </td>

            <td>
                ${fieldValue(bean: a, field: "status")}
            </td>
        </tr>
    </g:each>
    </tbody>
</table>
