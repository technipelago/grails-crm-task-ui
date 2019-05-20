<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskBooking.label', default: 'Booking')}"/>
    <title><g:message code="crmTaskBooking.edit.title" args="[entityName, crmTaskBooking]"/></title>
    <r:require modules="datepicker,autocomplete"/>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <crm:user>
                <h1>
                    ${crmTaskBooking.title ?: crmTaskBooking.attenderName}
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

        <g:form action="edit">
            <g:hiddenField name="id" value="${crmTaskBooking.id}"/>

            <div class="row-fluid">
                <div class="span6">
                    <div class="row-fluid">
                        <div class="control-group">
                            <label class="control-label">
                                <g:message code="crmTaskBooking.bookingDate.label"/>
                            </label>

                            <div class="controls">
                                <div class="input-append date">
                                    <g:textField name="bookingDate" class="span9" size="10" autofocus=""
                                                 value="${formatDate(type: 'date', date: crmTaskBooking.bookingDate ?: new Date())}"/><span
                                        class="add-on"><i class="icon-th"></i></span>
                                </div>
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
                            <label class="control-label"><g:message code="crmTaskBooking.reserve.label"/></label>

                            <div class="controls">
                                <g:textField name="reserve" value="${crmTaskBooking.reserve}" class="span6"
                                             placeholder="${message(code: 'crmTaskBooking.reserve.help', default: '')}"/>
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

                <div class="span6">
                    <div class="row-fluid">
                        <label><g:message code="crmTaskBooking.invoiceAddress.label"/></label>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskBooking.invoiceAddress.addressee.label"/></label>

                            <div class="controls">
                                <g:textField name="invoiceAddress.addressee" value="${crmTaskBooking.invoiceAddress?.addressee}"
                                             class="span11"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmAddress.address1.label"/></label>

                            <div class="controls">
                                <g:textField name="invoiceAddress.address1" value="${crmTaskBooking.invoiceAddress?.address1}"
                                             class="span11"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmAddress.address2.label"/></label>

                            <div class="controls">
                                <g:textField name="invoiceAddress.address2" value="${crmTaskBooking.invoiceAddress?.address2}"
                                             class="span11"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmAddress.address3.label"/></label>

                            <div class="controls">
                                <g:textField name="invoiceAddress.address3" value="${crmTaskBooking.invoiceAddress?.address3}"
                                             class="span11"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label">Postnr och ort</label>

                            <div class="controls">
                                <g:textField name="invoiceAddress.postalCode" value="${crmTaskBooking.invoiceAddress?.postalCode}"
                                             class="span4"/>
                                <g:textField name="invoiceAddress.city" value="${crmTaskBooking.invoiceAddress?.city}" class="span7"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmAddress.country.label"/></label>

                            <div class="controls">
                                <g:textField name="invoiceAddress.country" value="${crmTaskBooking.invoiceAddress?.country}"
                                             class="span11"/>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <crm:button visual="warning" icon="icon-ok icon-white" label="crmTaskBooking.button.save.label"/>
                <crm:button type="link" controller="crmTaskBooking" action="show" id="${crmTaskBooking.id}"
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
