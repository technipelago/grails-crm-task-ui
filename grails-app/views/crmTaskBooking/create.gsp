<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskBooking.label', default: 'Booking')}"/>
    <title><g:message code="crmTaskBooking.create.title" args="[entityName, crmTaskBooking]"/></title>
    <r:require modules="datepicker,autocomplete"/>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <crm:user>
                <h1>
                    ${crmTaskAttender}
                    <small>${crmTask}</small>
                </h1>
            </crm:user>
        </header>

        <g:hasErrors bean="${crmTaskBooking}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmTaskBooking}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form action="create">
            <g:hiddenField name="id" value="${crmTaskAttender.id}"/>

            <div class="row-fluid">
                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmTaskBooking.bookingDate.label"/>
                    </label>

                    <div class="controls">
                        <div class="input-append date">
                            <g:textField name="bookingDate" class="span9" size="10"
                                         value="${formatDate(type: 'date', date: crmTaskBooking.bookingDate ?: new Date())}"/><span
                                class="add-on"><i class="icon-th"></i></span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTaskBooking.bookingRef.label"/></label>

                        <div class="controls">
                            <g:textField name="bookingRef" value="${crmTaskBooking.bookingRef}" class="span11"
                                         placeholder="${message(code: 'crmTaskBooking.bookingRef.help', default: '')}"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTaskBooking.comments.label"/></label>

                        <div class="controls">
                            <g:textArea name="comments" value="${crmTaskBooking.comments}" rows="6" class="span11"
                                        placeholder="${message(code: 'crmTaskBooking.comments.help', default: '')}"/>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <crm:button visual="success" icon="icon-ok icon-white" label="crmTaskBooking.button.save.label"/>
                <crm:button type="link" controller="crmTask" action="show" id="${crmTask.id}"
                            icon="icon-remove"
                            label="crmTaskBooking.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
    </div>

</div>

</body>
</html>