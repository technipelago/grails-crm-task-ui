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
                ${fieldValue(bean: crmTask, field: "username")}
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

<div class="form-actions btn-toolbar">
    <crm:button type="link" group="true" controller="crmTask" action="create" params="${[ref: reference]}"
                visual="success"
                icon="icon-file icon-white"
                label="crmTask.button.create.label" permission="crmTask:create"/>
</div>