<%@ page import="grails.plugins.crm.task.CrmTask" %><!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.list.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmTask.list.title" subtitle="crmContact.totalCount.label"
            args="[entityName, crmTaskTotal]">
</crm:header>

<table class="table table-striped">
    <thead>
    <tr>
        <crm:sortableColumn property="startTime"
                            title="${message(code: 'crmTask.startTime.label', default: 'Starts')}"/>

        <crm:sortableColumn property="name"
                            title="${message(code: 'crmTask.name.label', default: 'Name')}"/>
        <crm:sortableColumn property="location"
                            title="${message(code: 'crmTask.location.label', default: 'Location')}"/>

        <crm:sortableColumn property="type.orderIndex"
                            title="${message(code: 'crmTask.type.label', default: 'Type')}"/>

        <crm:sortableColumn property="complete"
                            title="${message(code: 'crmTask.complete.label', default: 'Status')}"/>
        <th></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${crmTaskList}" var="crmTask">
        <tr>
            <td class="nowrap">
                <g:link action="show" id="${crmTask.id}">
                    <g:formatDate type="date" date="${crmTask.startTime}"/>
                </g:link>
            </td>
            <td>
                <g:link action="show" id="${crmTask.id}">
                    ${fieldValue(bean: crmTask, field: "name")}
                </g:link>
            </td>
            <td>${fieldValue(bean: crmTask, field: "location")}</td>
            <td>${fieldValue(bean: crmTask, field: "type")}</td>
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

<div class="form-actions btn-toolbar">
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

</body>
</html>
