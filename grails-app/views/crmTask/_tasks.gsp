%{--
  - Copyright (c) 2018 Goran Ehrsson.
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

<%@ page import="org.apache.commons.lang.StringUtils" %>
<style type="text/css">
tr.crm-status-confirmed td,
tr.crm-status-completed td {
    color: #009900;
    background-color: #eeffee !important;
}
tr.crm-status-active td {
    color: #f89406;
    background-color: #eeeeff !important;
}
</style>

<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmTask.date.label" default="Date"/></th>
        <th><g:message code="crmTask.name.label" default="Name"/></th>
        <th><g:message code="crmTask.type.label" default="Type"/></th>
        <th><g:message code="crmTask.complete.label" default="Status"/></th>
        <th><g:message code="crmTask.description.label" default="Notes"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="crmTask">
        <tr class="crm-status-${crmTask.completed ? 'completed' : (crmTask.active ? 'active' : 'planned')}">
            <td>
                <g:link controller="crmTask" action="show" id="${crmTask.id}">
                    <g:formatDate type="date" date="${crmTask.startTime}"/>
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
                ${message(code: 'crmTask.complete.' + crmTask.complete + '.label', default: crmTask.complete.toString())}
            </td>

            <td>${StringUtils.abbreviate(crmTask.description ?: '', 40)}</td>
        </tr>
    </g:each>
    </tbody>
</table>

<g:if test="${createParams}">
    <div class="form-actions">
        <crm:hasPermission permission="crmTask:create">
            <div class="btn-group">
                <crm:button type="link" group="true" controller="crmTask" action="create" visual="success"
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
                                    <g:link controller="crmTask" action="create" params="${createParams + ['type.id': type.id, referer: request.forwardURI]}">
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