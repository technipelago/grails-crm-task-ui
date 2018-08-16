<%@ page import="grails.plugins.crm.task.CrmTask" %>
<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmTask.startTime.label" default="Starts"/></th>
        <th><g:message code="crmTask.name.label" default="Name"/></th>
        <th><g:message code="crmTask.type.label" default="Type"/></th>
        <th><g:message code="crmTask.username.label" default="Responsible"/></th>
        <th style="width:18px;"></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${result}" var="crmTask">
        <tr>

            <td>
                <g:link controller="crmTask" action="show" id="${crmTask.id}">
                    <g:formatDate type="datetime" date="${crmTask.startTime}"/>
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
                <crm:user username="${crmTask.username}" nouser="${crmTask.username}">${name.encodeAsHTML()}</crm:user>
            </td>
            <td style="width:36px;">
                <g:if test="${crmTask.alarms > 0}">
                    <i class="icon-volume-up" title="${message(code:'crmTask.alarm.sent.message')}"></i>
                </g:if>
                <g:elseif test="${crmTask.alarm}">
                    <i class="icon-bell" title="${message(code:'crmTask.alarm.pending.message')}"></i>
                </g:elseif>
                <g:if test="${crmTask.completed}">
                    <i class="icon-check" title="${message(code:'crmTask.complete.100.label')}"></i>
                </g:if>
            </td>
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
                                    <g:link mapping="crm-task-quick" params="${createParams + ['type.id': type.id, referer: request.forwardURI]}">
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