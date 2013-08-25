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

<%@ page import="grails.plugins.crm.task.CrmTaskType" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskType.label', default: 'CrmTaskType')}"/>
    <title><g:message code="crmTaskType.edit.title" args="[entityName, crmTaskType]"/></title>
</head>

<body>

<crm:header title="crmTaskType.edit.title" args="[entityName, crmTaskType]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmTaskType}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmTaskType}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit"
                id="${crmTaskType?.id}">
            <g:hiddenField name="version" value="${crmTaskType?.version}"/>

            <f:with bean="crmTaskType">
                <f:field property="name" input-autofocus=""/>
                <f:field property="description"/>
                <f:field property="param"/>
                <f:field property="icon"/>
                <f:field property="orderIndex"/>
                <f:field property="enabled"/>
            </f:with>

            <div class="form-actions">
                <crm:button visual="warning" icon="icon-ok icon-white" label="crmTaskType.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmTaskType.button.delete.label"
                            confirm="crmTaskType.button.delete.confirm.message"
                            permission="crmTaskType:delete"/>
                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmTaskType.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>

</body>
</html>
