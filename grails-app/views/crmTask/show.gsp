<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.show.title" args="[entityName, crmTask]"/></title>
    <r:require modules="datepicker,autocomplete"/>
</head>

<body>

<div class="row-fluid">
<div class="span9">

<header class="page-header">
    <crm:user>
        <h1>
            ${crmTask.name.encodeAsHTML()}
            <crm:favoriteIcon bean="${crmTask}"/>
            <small>${(crmTask.reference ?: crmTask.location)?.encodeAsHTML()}</small>
            ${crmTask.alarm ? '<i class="icon-bell"></i>' : ''}
            ${crmTask.complete ? '<i class="icon-check"></i>' : ''}
        </h1>
    </crm:user>
</header>

<div class="tabbable">
<ul class="nav nav-tabs">
    <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmTask.tab.main.label"/></a>
    </li>
    <g:if test="${attenders != null}">
        <li><a href="#attender" data-toggle="tab"><g:message
                code="crmTask.tab.attender.label"/><crm:countIndicator
                count="${attenders.size()}"/></a>
        </li>
    </g:if>
    <crm:pluginViews location="tabs" var="view">
        <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
    </crm:pluginViews>
</ul>

<div class="tab-content">
<div class="tab-pane active" id="main">
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

            <g:if test="${crmTask.description}">
                <dl style="margin-top: 0;">
                    <dt><g:message code="crmTask.description.label" default="Description"/></dt>
                    <dd><g:decorate encode="HTML" nlbr="true">${crmTask.description}</g:decorate></dd>
                </dl>
            </g:if>
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

    <g:form>
        <g:hiddenField name="id" value="${crmTask.id}"/>
        <div class="form-actions btn-toolbar">

            <crm:selectionMenu location="crmTask" visual="primary">
                <crm:button type="link" controller="crmTask" action="index"
                            visual="primary" icon="icon-search icon-white"
                            label="crmTask.button.find.label"/>
            </crm:selectionMenu>

            <crm:button type="link" group="true" action="edit" id="${crmTask.id}" visual="warning"
                        icon="icon-pencil icon-white"
                        label="crmTask.button.edit.label" permission="crmTask:edit">
                <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">

                    <g:unless test="${crmTask.completed}">
                        <li>
                            <g:link action="completed" id="${crmTask.id}">
                                <g:message code="crmTask.button.completed.label"
                                           default="Set status to completed"/>
                            </g:link>
                        </li>
                    </g:unless>

                </ul>
            </crm:button>

            <crm:button type="link" group="true" action="create"
                        params="${['type.id': crmTask.type?.id, ref: crmTask.ref]}" visual="success"
                        icon="icon-file icon-white"
                        label="crmTask.button.create.label"
                        title="crmTask.button.create.help"
                        permission="crmTask:create"/>

            <div class="btn-group">
                <button class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                    <i class="icon-info-sign icon-white"></i>
                    <g:message code="crmTask.button.view.label" default="View"/>
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <g:if test="${selection}">
                        <li>
                            <select:link action="list" selection="${selection}" params="${[view: 'list']}">
                                <g:message code="crmTask.show.result.label" default="Show result in list view"/>
                            </select:link>
                        </li>
                    </g:if>
                    <crm:hasPermission permission="crmTask:createFavorite">
                        <crm:user>
                            <g:if test="${crmTask.isUserTagged('favorite', username)}">
                                <li>
                                    <g:link action="deleteFavorite" id="${crmTask.id}"
                                            title="${message(code: 'crmTask.button.favorite.delete.help', args: [crmTask])}">
                                        <g:message code="crmTask.button.favorite.delete.label"/></g:link>
                                </li>
                            </g:if>
                            <g:else>
                                <li>
                                    <g:link action="createFavorite" id="${crmTask.id}"
                                            title="${message(code: 'crmTask.button.favorite.create.help', args: [crmTask])}">
                                        <g:message code="crmTask.button.favorite.create.label"/></g:link>
                                </li>
                            </g:else>
                        </crm:user>
                    </crm:hasPermission>
                    <li>
                        <g:link controller="crmCalendar" action="index">
                            <g:message code="crmCalendar.index.label" default="Calendar"/>
                        </g:link>
                    </li>
                </ul>
            </div>

        </div>

        <crm:timestamp bean="${crmTask}"/>
    </g:form>

</div>

<g:if test="${attenders != null}">
    <div class="tab-pane" id="attender">
        <g:render template="attenders"
                  model="${[bean: crmTask, list: attenders, statusList: statusList]}"/>
    </div>
</g:if>

<crm:pluginViews location="tabs" var="view">
    <div class="tab-pane tab-${view.id}" id="${view.id}">
        <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
    </div>
</crm:pluginViews>

</div>
</div>

</div>

<div class="span3">
    <div class="alert alert-info">
        <g:render template="summary" model="${[bean: crmTask]}"/>
    </div>

    <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTask]}"/>

    <g:if test="${recentBooked}">
        <div class="well">
            <ul class="nav nav-list">
                <li class="nav-header">
                    <i class="icon-thumbs-up"></i>
                    <g:message code="crmTaskAttender.recent.registered.title" default="Recently Registered"/>
                </li>
                <g:each in="${recentBooked}" var="a" status="i">
                    <li>
                        <g:if test="${a.contact}">
                            <g:link controller="crmContact" action="show" id="${a.contact.id}">
                                <g:formatDate format="d MMM" date="${a.bookingDate}"/>
                                ${a.encodeAsHTML()}
                            </g:link>
                        </g:if>
                        <g:else>
                            <g:formatDate format="d MMM" date="${a.bookingDate}"/>
                            ${a.encodeAsHTML()}
                        </g:else>
                    </li>
                </g:each>
            </ul>
        </div>
    </g:if>
</div>
</div>

</body>
</html>
