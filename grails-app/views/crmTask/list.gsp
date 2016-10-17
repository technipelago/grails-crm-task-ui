<%@ page import="grails.plugins.crm.task.CrmTask" %><!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.list.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmTask.list.title" subtitle="crmTask.totalCount.label"
            args="[entityName, crmTaskTotal]">
</crm:header>

<table class="table table-striped">
    <thead>
    <tr>
        <crm:sortableColumn property="startTime"
                            title="${message(code: 'crmTask.startTime.label', default: 'Starts')}"/>

        <th><g:message code="crmTask.reference.label" default="Reference"/></th>

        <crm:sortableColumn property="name"
                            title="${message(code: 'crmTask.name.label', default: 'Name')}"/>

        <crm:sortableColumn property="type.orderIndex"
                            title="${message(code: 'crmTask.type.label', default: 'Type')}"/>

        <crm:sortableColumn property="username"
                            title="${message(code: 'crmTask.username.label', default: 'User')}"/>

        <crm:sortableColumn property="complete"
                            title="${message(code: 'crmTask.complete.label', default: 'Status')}"/>
        <th></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${crmTaskList}" var="crmTask">
        <g:set var="reference" value="${crmTask.reference}"/>
        <g:set var="contact" value="${crmTask.contact}"/>

        <tr>
            <td class="nowrap">
                <g:link action="show" id="${crmTask.id}">
                    <g:formatDate type="date" date="${crmTask.startTime}"/>
                </g:link>
            </td>

            <td>
                <g:if test="${contact}">
                    <g:link action="show" id="${crmTask.id}">${contact.fullName}</g:link>
                </g:if>
                <g:elseif test="${reference}">
                    <g:link action="show" id="${crmTask.id}">${reference}</g:link>
                </g:elseif>
            </td>

            <td>
                <g:link action="show" id="${crmTask.id}">
                    ${fieldValue(bean: crmTask, field: "name")}
                </g:link>
            </td>

            <td>${fieldValue(bean: crmTask, field: "type")}</td>

            <td>
                <crm:user username="${crmTask.username}" nouser="${crmTask.username}">
                    ${name}
                </crm:user>
            </td>

            <td>${message(code: 'crmTask.complete.' + crmTask.complete + '.label', default: crmTask.complete.toString())}</td>
            <td style="width:36px;">
                <g:if test="${crmTask.alarms > 0}">
                    <i class="icon-volume-up" title="${message(code: 'crmTask.alarm.sent.message')}"></i>
                </g:if>
                <g:elseif test="${crmTask.alarm}">
                    <i class="icon-bell" title="${message(code: 'crmTask.alarm.pending.message')}"></i>
                </g:elseif>
                <g:if test="${crmTask.completed}">
                    <i class="icon-check" title="${message(code: 'crmTask.complete.100.label')}"></i>
                </g:if>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<crm:paginate total="${crmTaskTotal}"/>

<g:form>

    <div class="form-actions btn-toolbar">
        <input type="hidden" name="offset" value="${params.offset ?: ''}"/>
        <input type="hidden" name="max" value="${params.max ?: ''}"/>
        <input type="hidden" name="sort" value="${params.sort ?: ''}"/>
        <input type="hidden" name="order" value="${params.order ?: ''}"/>

        <g:each in="${selection.selectionMap}" var="entry">
            <input type="hidden" name="${entry.key}" value="${entry.value}"/>
        </g:each>

        <crm:selectionMenu visual="primary"/>

        <g:if test="${crmTaskTotal}">
            <select:link action="export" accesskey="p" selection="${selection}" class="btn btn-info">
                <i class="icon-print icon-white"></i>
                <g:message code="crmTask.button.export.label" default="Print/Export"/>
            </select:link>
        </g:if>

        <div class="btn-group">
            <crm:button type="link" action="create" visual="success" icon="icon-file icon-white"
                        label="crmTask.button.create.label" permission="crmTask:create"/>
        </div>
    </div>
</g:form>

</body>
</html>
