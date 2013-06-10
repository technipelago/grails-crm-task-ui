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

<%@ page import="grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.list.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmTask.list.title" subtitle="Sökningen resulterade i ${crmTaskTotal} st uppgifter"
            args="[entityName]">
</crm:header>

<div class="row-fluid">
    <div class="span9">
        <table class="table table-striped">
            <thead>
            <tr>
                <crm:sortableColumn property="name"
                                    title="${message(code: 'crmTask.name.label', default: 'Name')}"/>
                <th><g:message code="crmTask.reference.label" default="Reference"/></th>
                <crm:sortableColumn property="type.orderIndex"
                                    title="${message(code: 'crmTask.type.label', default: 'Type')}"/>

                <crm:sortableColumn property="startTime"
                                    title="${message(code: 'crmTask.startTime.label', default: 'Starts')}"/>
                <crm:sortableColumn property="endTime"
                                    title="${message(code: 'crmTask.endTime.label', default: 'Ends')}"/>
                <crm:sortableColumn property="priority"
                                    title="${message(code: 'crmTask.priority.label', default: 'Priority')}"/>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${crmTaskList}" var="crmTask">
                <tr>
                    <td>
                        <g:link action="show" id="${crmTask.id}">
                            ${fieldValue(bean: crmTask, field: "name")}
                        </g:link>
                    </td>
                    <td>${fieldValue(bean: crmTask, field: "reference")}</td>
                    <td>${fieldValue(bean: crmTask, field: "type")}</td>
                    <td class="nowrap"><g:formatDate type="date" date="${crmTask.startTime}"/></td>
                    <td class="nowrap"><g:formatDate type="date" date="${crmTask.endTime}"/></td>
                    <td>${message(code: 'crmTask.priority.' + crmTask.priority + '.label', default: crmTask.priority.toString())}</td>
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

        <crm:paginate total="${crmTaskTotal}"/>

        <div class="form-actions btn-toolbar">
            <crm:selectionMenu visual="primary"/>

            <g:if test="${crmTaskTotal}">
                <div class="btn-group">
                    <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                        <i class="icon-print icon-white"></i>
                        <g:message code="crmTask.button.print.label" default="Print"/>
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <crm:hasPermission permission="crmTask:print">
                            <li>
                                <select:link action="print" accesskey="p" target="pdf" selection="${selection}">
                                    <g:message code="crmTask.button.print.pdf.label" default="Print to PDF"/>
                                </select:link>
                            </li>
                        </crm:hasPermission>
                        <crm:hasPermission permission="crmTask:export">
                            <li>
                                <select:link action="export" accesskey="e" selection="${selection}">
                                    <g:message code="crmTask.button.export.calc.label" default="Print to spreadsheet"/>
                                </select:link>
                            </li>
                        </crm:hasPermission>
                    </ul>
                </div>
            </g:if>

            <div class="btn-group">
                <crm:button type="link" action="create" visual="success" icon="icon-file icon-white"
                            label="crmTask.button.create.label" permission="crmTask:create"/>
            </div>
        </div>
    </div>

    <div class="span3">

    </div>

</div>

</body>
</html>
