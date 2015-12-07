<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTaskAttender.archive.title" args="[entityName, crmTask]"/></title>
    <style type="text/css">
    .crm-summary h4 {
        text-overflow: ellipsis;
    }
    </style>
</head>

<body>

<crm:hasPermission permission="crmTaskAttender:archive">
    <g:set var="editPermission" value="${true}"/>
</crm:hasPermission>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <crm:user>
                <h1>
                    ${crmTask.name}
                    <crm:favoriteIcon bean="${crmTask}"/>
                    <small>${(crmTask.reference ?: crmTask.location)}</small>
                    ${crmTask.alarm ? raw('<i class="icon-bell"></i>') : ''}
                    ${crmTask.complete ? raw('<i class="icon-check"></i>') : ''}
                </h1>
            </crm:user>
        </header>

        <div class="alert alert-error">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <h4><g:message code="crmTaskAttender.archive.title" args="[entityName, crmTask]"/></h4>
            <g:message code="crmTaskAttender.archive.help" args="${[crmTask, crmTask.attenders.size()]}"/>
        </div>

        <g:form action="archive">

            <input type="hidden" name="id" value="${crmTask.id}"/>

            <div class="row-fluid">

                <div class="span8">
                    <div class="row-fluid">
                        <div class="span7">
                            <dl>

                                <g:if test="${crmTask.number}">
                                    <dt><g:message code="crmTask.number.label" default="Number"/></dt>
                                    <dd><g:fieldValue bean="${crmTask}" field="number"/></dd>
                                </g:if>

                                <dt><g:message code="crmTask.name.label" default="Name"/></dt>
                                <dd><g:fieldValue bean="${crmTask}" field="name"/></dd>

                                <g:if test="${crmTask.location}">
                                    <dt><g:message code="crmTask.location.label" default="Location"/></dt>
                                    <dd><g:fieldValue bean="${crmTask}" field="location"/></dd>
                                </g:if>

                            </dl>
                        </div>

                        <div class="span5">
                            <dl>

                                <g:if test="${crmTask.startTime}">
                                    <dt><g:message code="crmTask.startTime.label" default="Starts"/></dt>
                                    <dd class="nowrap"><g:formatDate date="${crmTask.startTime}" type="datetime"/></dd>
                                </g:if>
                                <g:if test="${crmTask.endTime}">
                                    <dt><g:message code="crmTask.endTime.label" default="Ends"/></dt>
                                    <dd class="nowrap"><g:formatDate date="${crmTask.endTime}" type="datetime"/></dd>
                                </g:if>
                                <g:if test="${crmTask.displayDate}">
                                    <dt><g:message code="crmTask.displayDate.label" default="Display Date"/></dt>
                                    <dd class="nowrap"><g:fieldValue bean="${crmTask}" field="displayDate"/></dd>
                                </g:if>
                                <g:if test="${crmTask.isRecurring}">
                                    <dt><g:message code="crmTask.isRecurring.label" default="Repeats"/></dt>
                                    <dd>Repeats every ${crmTask.recurInterval}</dd>
                                </g:if>
                                <g:if test="${crmTask.alarmType != CrmTask.ALARM_NONE}">
                                    <dt><g:message code="crmTask.alarm.label" default="Reminder"/></dt>
                                    <dd>
                                        <g:message code="crmTask.alarmType.${crmTask.alarmType}"/>
                                        <g:message code="crmTask.alarmOffset.${crmTask.alarmOffset}"/>
                                    </dd>
                                </g:if>

                            </dl>
                        </div>
                    </div>

                    <div class="row-fluid">
                        <div class="control-group">
                            <label class="control-label">
                                <g:message code="crmTask.description.label" default="Description"/>
                            </label>

                            <div class="controls">
                                <g:textArea name="description" value="${crmTask.description}" rows="6" cols="70"
                                            class="span12" autofocus="autofocus"/>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="span4">
                    <dl>

                        <g:if test="${crmTask.type}">
                            <dt><g:message code="crmTask.type.label" default="Type"/></dt>
                            <dd><g:fieldValue bean="${crmTask}" field="type"/></dd>
                        </g:if>

                        <dt><g:message code="crmTask.complete.label" default="Status"/></dt>
                        <dd>${message(code: 'crmTask.complete.' + crmTask.complete + '.label', default: crmTask.complete.toString())}</dd>

                        <dt><g:message code="crmTask.priority.label" default="Priority"/></dt>
                        <dd>${message(code: 'crmTask.priority.' + crmTask.priority + '.label', default: crmTask.priority.toString())}</dd>

                        <g:if test="${crmTask.ref}">
                            <dt><g:message code="crmTask.reference.label" default="Reference"/></dt>
                            <dd><crm:referenceLink reference="${crmTask.reference}"/></dd>
                        </g:if>

                        <g:if test="${crmTask.username}">
                            <dt><g:message code="crmTask.username.label" default="Responsible"/></dt>
                            <dd>
                                <crm:user username="${crmTask.username}" nouser="${crmTask.username}">
                                    ${name}
                                </crm:user>
                            </dd>
                        </g:if>

                    </dl>
                </div>

            </div>

            <div class="form-actions">
                <crm:button action="archive" visual="danger" icon="icon-trash icon-white"
                            label="crmTaskAttender.button.archive.label"
                            confirm="crmTaskAttender.button.archive.confirm.message"
                            permission="crmTaskAttander:archive"/>
                <crm:button type="link" controller="crmTask" action="show" id="${crmTask.id}" fragment="attender"
                            icon="icon-remove"
                            label="crmTask.button.cancel.label"/>
            </div>

            <crm:timestamp bean="${crmTask}"/>
        </g:form>

    </div>

    <div class="span3">
        <div class="alert alert-info crm-summary">
            <g:render template="/crmTask/summary" model="${[bean: crmTask]}"/>
        </div>

        <div class="well">
            <ul class="nav nav-list">

                <li class="nav-header">
                    <i class="icon-glass"></i>
                    <g:message code="crmTaskAttender.statistics.title" default="Statistics"/>
                </li>

                <g:each in="${attenderStatistics}" var="stat">
                    <li>${stat[0]}: <strong>${stat[1]}</strong></li>
                </g:each>
            </ul>
        </div>
    </div>
</div>

</body>
</html>
