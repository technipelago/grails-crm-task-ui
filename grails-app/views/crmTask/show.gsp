%{--
  - Copyright (c) 2013 Goran Ehrsson.
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  --}%

<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.show.title" args="[entityName, crmTask]"/></title>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header clearfix">
            <crm:user>
                <h1 class="pull-left">
                    ${crmTask.name.encodeAsHTML()}
                    <crm:favoriteIcon bean="${crmTask}"/>
                    <small>${crmTask.reference?.encodeAsHTML()}</small>
                    ${crmTask.alarm ? '<i class="icon-bell"></i>' : ''}
                    ${crmTask.complete ? '<i class="icon-check"></i>' : ''}
                </h1>

                <h2 class="pull-right"><g:fieldValue bean="${crmTask}" field="type"/></h2>
            </crm:user>
        </header>

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmTask.tab.main.label"/></a>
                </li>
                <crm:pluginViews location="tabs" var="view">
                    <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
                </crm:pluginViews>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="main">
                    <div class="row-fluid">
                        <div class="span4">
                            <dl>
                                <g:if test="${crmTask.name}">
                                    <dt><g:message code="crmTask.name.label" default="Name"/></dt>

                                    <dd><g:fieldValue bean="${crmTask}" field="name"/></dd>

                                </g:if>

                                <g:if test="${crmTask.startTime}">
                                    <dt><g:message code="crmTask.startTime.label" default="Starts"/></dt>
                                    <dd><g:formatDate date="${crmTask.startTime}" type="datetime"/></dd>
                                </g:if>
                                <g:if test="${crmTask.endTime}">
                                    <dt><g:message code="crmTask.endTime.label" default="Ends"/></dt>
                                    <dd><g:formatDate date="${crmTask.endTime}" type="datetime"/></dd>
                                </g:if>
                                <g:if test="${crmTask.isRecurring}">
                                    <dt><g:message code="crmTask.isRecurring.label" default="Repeats"/></dt>
                                    <dd>Repeats every ${crmTask.recurInterval}</dd>
                                </g:if>

                                <g:if test="${crmTask.location}">
                                    <dt><g:message code="crmTask.location.label" default="Location"/></dt>

                                    <dd><g:fieldValue bean="${crmTask}" field="location"/></dd>

                                </g:if>

                            </dl>
                        </div>

                        <div class="span4">
                            <dl>
                                <g:if test="${crmTask.username}">
                                    <dt><g:message code="crmTask.username.label" default="Responsible"/></dt>
                                    <dd><crm:user username="${crmTask.username}">${name}</crm:user></dd>
                                </g:if>
                                <g:if test="${crmTask.type}">
                                    <dt><g:message code="crmTask.type.label" default="Type"/></dt>
                                    <dd><g:fieldValue bean="${crmTask}" field="type"/></dd>
                                </g:if>

                                <dt><g:message code="crmTask.complete.label" default="Status"/></dt>
                                <dd>${message(code: 'crmTask.complete.' + crmTask.complete + '.label', default: crmTask.complete.toString())}</dd>

                                <dt><g:message code="crmTask.priority.label" default="Priority"/></dt>
                                <dd>${message(code: 'crmTask.priority.' + crmTask.priority + '.label', default: crmTask.priority.toString())}</dd>

                            </dl>
                        </div>

                        <div class="span4">
                            <dl>
                                <g:if test="${crmTask.ref}">
                                    <dt><g:message code="crmTask.reference.label" default="Reference"/></dt>
                                    <dd><crm:referenceLink reference="${crmTask.reference}"/></dd>
                                </g:if>
                                <g:if test="${crmTask.alarmType != CrmTask.ALARM_NONE}">
                                    <dt><g:message code="crmTask.alarm.label" default="Reminder"/></dt>
                                    <dd>
                                        <g:message code="crmTask.alarmType.${crmTask.alarmType}"/>
                                        <g:message code="crmTask.alarmOffset.${crmTask.alarmOffset}"/>
                                    </dd>
                                </g:if>
                                <g:if test="${crmTask.description}">
                                    <dt><g:message code="crmTask.description.label" default="Description"/></dt>
                                    <dd><g:decorate encode="HTML">${crmTask.description}</g:decorate></dd>
                                </g:if>
                            </dl>
                        </div>

                    </div>

                    <g:form>
                        <g:hiddenField name="id" value="${crmTask.id}"/>
                        <div class="form-actions btn-toolbar">

                            <crm:button type="link" group="true" action="edit" id="${crmTask.id}" visual="primary"
                                        icon="icon-pencil icon-white"
                                        label="crmTask.button.edit.label" permission="crmTask:edit">
                                <g:unless test="${crmTask.completed}">
                                    <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                                        <span class="caret"></span>
                                    </button>
                                    <ul class="dropdown-menu">
                                        <li>
                                            <g:link action="completed" id="${crmTask.id}">
                                                <g:message code="crmTask.button.completed.label"
                                                           default="Set status to completed"/>
                                            </g:link>
                                        </li>
                                    </ul>
                                </g:unless>
                            </crm:button>

                            <crm:button type="link" group="true" action="create"
                                        params="${['type.id': crmTask.type?.id, ref: crmTask.ref]}" visual="success"
                                        icon="icon-file icon-white"
                                        label="crmTask.button.create.label"
                                        title="crmTask.button.create.help"
                                        permission="crmTask:create"/>

                            <crm:user>
                                <g:if test="${crmTask.isUserTagged('favorite', username)}">
                                    <crm:button type="link" group="true" action="deleteFavorite" id="${crmTask.id}"
                                                visual="info"
                                                icon="icon-star-empty icon-white"
                                                label="crmTask.button.favorite.delete.label"
                                                title="crmTask.button.favorite.delete.help"
                                                args="${[message(code: 'crmTask.label', default: 'Task')]}"
                                                permission="crmTask:edit"/>
                                </g:if>
                                <g:else>
                                    <crm:button type="link" group="true" action="createFavorite" id="${crmTask.id}"
                                                visual="info"
                                                icon="icon-star icon-white"
                                                label="crmTask.button.favorite.create.label"
                                                title="crmTask.button.favorite.create.help"
                                                args="${[message(code: 'crmTask.label', default: 'Task')]}"
                                                permission="crmTask:edit"/>
                                </g:else>
                            </crm:user>

                        </div>

                        <crm:timestamp bean="${crmTask}"/>
                    </g:form>

                </div>

                <crm:pluginViews location="tabs" var="view">
                    <div class="tab-pane tab-${view.id}" id="${view.id}">
                        <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
                    </div>
                </crm:pluginViews>

            </div>
        </div>

    </div>

    <div class="span3">

        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTask]}"/>

    </div>
</div>

</body>
</html>
