<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.show.title" args="[entityName, crmTask]"/></title>
    <r:require modules="datepicker,autocomplete"/>
    <style type="text/css">
    .crm-summary h4 {
        text-overflow: ellipsis;
    }
    </style>
</head>

<body>

<%
    Closure dateFunction = grailsApplication.config.crm.task.attenders.statistic.date ?: { a -> a.bookingDate }
%>

<crm:hasPermission permission="crmTask:edit">
    <g:set var="editPermission" value="${true}"/>
</crm:hasPermission>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <img src="${resource(dir: 'images', file: 'calendar-icon.png')}" class="avatar pull-right"
                 width="64" height="64"/>
            <crm:user>
                <h1>
                    ${crmTask.name}
                    <crm:favoriteIcon bean="${crmTask}"/>
                    <small>${contact ? contact.fullName : (crmTask.reference ?: crmTask.location)}</small>
                    ${crmTask.alarm ? raw('<i class="icon-bell"></i>') : ''}
                    ${crmTask.complete ? raw('<i class="icon-check"></i>') : ''}
                </h1>
            </crm:user>
        </header>

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmTask.tab.main.label"/></a>
                </li>
                <g:if test="${attendersTotal != null}">
                    <li><a href="#attender" data-toggle="tab"><g:message
                            code="crmTask.tab.attender.label"/><crm:countIndicator
                            count="${attendersTotal}"/></a>
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
                                            <dd>
                                                <g:if test="${registrationMapping}">
                                                    <g:link mapping="${registrationMapping}"
                                                            params="${[tenant: crmTask.tenantId, id: crmTask.id, number: crmTask.number]}">
                                                        <g:fieldValue bean="${crmTask}" field="number"/>
                                                    </g:link>
                                                </g:if>
                                                <g:else>
                                                    <g:fieldValue bean="${crmTask}" field="number"/>
                                                </g:else>
                                            </dd>
                                        </g:if>

                                        <dt><g:message code="crmTask.name.label" default="Name"/></dt>
                                        <dd><g:fieldValue bean="${crmTask}" field="name"/></dd>

                                        <g:if test="${crmTask.location}">
                                            <dt><g:message code="crmTask.location.label" default="Location"/></dt>
                                            <dd><g:fieldValue bean="${crmTask}" field="location"/></dd>
                                        </g:if>

                                        <g:if test="${crmTask.address != null && !crmTask.address.isEmpty()}">
                                            <dt><g:message code="crmTask.address.label" default="Address"/></dt>
                                            <dd><g:fieldValue bean="${crmTask}" field="address"/></dd>
                                        </g:if>

                                    </dl>
                                </div>

                                <div class="span5">
                                    <dl>

                                        <g:if test="${crmTask.startTime}">
                                            <dt><g:message code="crmTask.startTime.label" default="Starts"/></dt>
                                            <dd class="nowrap"><g:formatDate date="${crmTask.startTime}"
                                                                             type="datetime"/></dd>
                                        </g:if>
                                        <g:if test="${crmTask.endTime}">
                                            <dt><g:message code="crmTask.endTime.label" default="Ends"/></dt>
                                            <dd class="nowrap"><g:formatDate date="${crmTask.endTime}"
                                                                             type="datetime"/></dd>
                                        </g:if>
                                        <g:if test="${crmTask.displayDate}">
                                            <dt><g:message code="crmTask.displayDate.label"
                                                           default="Display Date"/></dt>
                                            <dd class="nowrap"><g:fieldValue bean="${crmTask}"
                                                                             field="displayDate"/></dd>
                                        </g:if>
                                        <g:if test="${crmTask.scope}">
                                            <dt><g:message code="crmTask.scope.label"
                                                           default="Scope"/></dt>
                                            <dd><g:fieldValue bean="${crmTask}"
                                                              field="scope"/></dd>
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

                                <g:if test="${crmTask.username}">
                                    <dt><g:message code="crmTask.username.label" default="Responsible"/></dt>
                                    <dd>
                                        <crm:user username="${crmTask.username}" nouser="${crmTask.username}">
                                            ${name}
                                        </crm:user>
                                    </dd>
                                </g:if>

                                <g:if test="${crmTask.ref}">
                                    <dt><g:message code="crmTask.reference.label" default="Reference"/></dt>
                                    <dd><crm:referenceLink reference="${crmTask.reference}"/></dd>
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
                                            <select:link action="list" selection="${selection}"
                                                         params="${[view: 'list']}">
                                                <g:message code="crmTask.show.result.label"
                                                           default="Show result in list view"/>
                                            </select:link>
                                        </li>
                                    </g:if>
                                    <crm:hasPermission permission="crmTask:createFavorite">
                                        <crm:user>
                                            <g:if test="${crmTask.isUserTagged('favorite', username)}">
                                                <li>
                                                    <g:link action="deleteFavorite" id="${crmTask.id}"
                                                            title="${message(code: 'crmTask.button.favorite.delete.help', args: [crmTask])}">
                                                        <g:message
                                                                code="crmTask.button.favorite.delete.label"/></g:link>
                                                </li>
                                            </g:if>
                                            <g:else>
                                                <li>
                                                    <g:link action="createFavorite" id="${crmTask.id}"
                                                            title="${message(code: 'crmTask.button.favorite.create.help', args: [crmTask])}">
                                                        <g:message
                                                                code="crmTask.button.favorite.create.label"/></g:link>
                                                </li>
                                            </g:else>
                                        </crm:user>
                                    </crm:hasPermission>

                                    <li>
                                        <g:link controller="crmCalendar" action="index"
                                                params="${[view: 'agendaDay', date: crmTask.date.format('yyyy-MM-dd')]}">
                                            <g:message code="crmCalendar.index.label" default="Calendar"/>
                                        </g:link>
                                    </li>

                                    <li>
                                        <select:link action="export"
                                                     selection="${new URI('bean://crmTaskService/list?id=' + crmTask.id)}">
                                            <g:message code="crmTaskAttender.button.print.label" default="Print"/>
                                        </select:link>
                                    </li>
                                </ul>
                            </div>

                            <crm:navButtons/>

                        </div>

                        <crm:timestamp bean="${crmTask}"/>
                    </g:form>

                </div>

                <g:if test="${attendersTotal != null}">
                    <div class="tab-pane" id="attender">
                        <g:render template="attenders"
                                  model="${[bean: crmTask, count: attendersTotal, statusList: statusList, status: params.status]}"/>
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
        <div class="alert alert-info crm-summary">
            <g:render template="summary" model="${[bean: crmTask]}"/>
        </div>

        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTask]}"/>

        <g:if test="${recentBooked}">
            <div class="well">
                <ul class="nav nav-list">

                    <li class="nav-header">
                        <i class="icon-user"></i>
                        <g:message code="crmTaskAttender.statistics.title" default="Statistics"/>
                    </li>

                    <crm:attenderStatistics bean="${crmTask}" tags="${attenderTags}">
                        <g:each in="${status.keySet().sort { it.name }}" var="key">
                            <li class="${params.status == key.name ? 'active' : ''}">
                                <g:link action="show" fragment="attender"
                                        params="${[id: crmTask.id, status: key.name]}">
                                    <i class="${key.icon ?: 'icon-check'}"></i>
                                    <g:message code="crmTaskAttender.statistics.label" default="{0}: {1}"
                                               args="${[key, status[key]]}"/>
                                </g:link>
                            </li>
                        </g:each>
                        <g:each in="${attenderTags}" var="t">
                            <g:if test="${tags[t] != null}">
                                <li class="${params.tag == t ? 'active' : ''}">
                                    <g:link action="show" fragment="attender"
                                            params="${[id: crmTask.id, tag: t]}">
                                        <i class="icon-tag"></i>
                                        <g:message code="crmTaskAttender.statistics.label" default="{0}: {1}"
                                                   args="${[t, tags[t]]}"/>
                                    </g:link>
                                </li>
                            </g:if>
                        </g:each>
                        <li class="${params.status ? '' : (params.tag ? '' : 'active')}">
                            <g:link action="show" id="${crmTask.id}" fragment="attender">
                                <i class="icon-user"></i>
                                <g:message code="crmTaskAttender.statistics.total" default="Total: {0}"
                                           args="${[count]}"/>
                            </g:link>
                        </li>
                    </crm:attenderStatistics>

                    <li class="nav-header">
                        <i class="icon-thumbs-up"></i>
                        <g:message code="crmTaskAttender.recent.registered.title" default="Recently Registered"/>
                    </li>
                    <g:each in="${recentBooked}" var="a" status="i">
                        <li>
                            <g:link controller="crmTaskAttender" action="show" id="${a.id}">
                                <i class="${a.status.icon ?: 'icon-check'}"></i>
                                <g:formatDate format="d MMM" date="${dateFunction(a)}"/>
                                ${a.encodeAsHTML()}
                            </g:link>
                        </li>
                    </g:each>
                </ul>
            </div>
        </g:if>
    </div>
</div>

</body>
</html>
