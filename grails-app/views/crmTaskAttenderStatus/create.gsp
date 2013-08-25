<%@ page import="grails.plugins.crm.task.CrmTaskAttenderStatus" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskAttenderStatus.label', default: 'CrmTaskAttenderStatus')}"/>
    <title><g:message code="crmTaskAttenderStatus.create.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmTaskAttenderStatus.create.title" args="[entityName]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmTaskAttenderStatus}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmTaskAttenderStatus}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="create">

            <f:with bean="crmTaskAttenderStatus">
                <f:field property="name" input-autofocus=""/>
                <f:field property="description"/>
                <f:field property="param"/>
                <f:field property="icon"/>
                <f:field property="orderIndex"/>
                <f:field property="enabled"/>
            </f:with>

            <div class="form-actions">
                <crm:button visual="success" icon="icon-ok icon-white" label="crmTaskAttenderStatus.button.save.label"/>
                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmTaskAttenderStatus.button.cancel.label"/>
            </div>

        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>

</body>
</html>
