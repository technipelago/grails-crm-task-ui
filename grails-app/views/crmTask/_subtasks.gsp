<%@ page import="org.apache.commons.lang.StringUtils" %>

<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmTask.date.label" default="Date"/></th>
        <th><g:message code="crmTask.name.label" default="Name"/></th>
        <th><g:message code="crmTask.type.label" default="Type"/></th>
        <th><g:message code="crmTask.complete.label" default="Status"/></th>
        <th><g:message code="crmTask.location.label" default="Location"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="crmTask">
        <tr>
            <td>
                <g:link controller="crmTask" action="show" params="${[id: crmTask.id]}">
                    <g:formatDate type="date" date="${crmTask.startTime}"/>
                </g:link>
            </td>

            <td>
                <g:link controller="crmTask" action="show" params="${[id: crmTask.id]}">
                    ${fieldValue(bean: crmTask, field: "name")}
                </g:link>
            </td>

            <td>
                ${fieldValue(bean: crmTask, field: "type")}
            </td>

            <td>
                ${message(code: 'crmTask.complete.' + crmTask.complete + '.label', default: crmTask.complete.toString())}
            </td>

            <td>${fieldValue(bean: crmTask, field: "location")}</td>
        </tr>
    </g:each>
    </tbody>
</table>

<g:if test="${createParams}">
    <div class="form-actions">
        <crm:hasPermission permission="crmTask:create">
            <div class="btn-group">
                <crm:button type="link" group="true" mapping="crm-task-create" visual="success"
                            icon="icon-file icon-white"
                            label="crmTask.button.create.label"
                            title="crmTask.button.create.help"
                            params="${createParams + [referer: request.forwardURI]}">
                    <g:if test="${typeList}">
                        <button class="btn btn-success dropdown-toggle" data-toggle="dropdown">
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <g:each in="${typeList}" var="type">
                                <li>
                                    <g:link  mapping="crm-task-quick" params="${createParams + ['type.id': type.id, referer: request.forwardURI]}">
                                        ${type}
                                    </g:link>
                                </li>
                            </g:each>
                        </ul>
                    </g:if>
                </crm:button>
            </div>
        </crm:hasPermission>
    </div>
</g:if>