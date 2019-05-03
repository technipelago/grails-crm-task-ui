<h3>${message(code: 'crmTaskAttender.' + (bean.id ? 'edit' : 'create') + '.title')}</h3>

<g:hasErrors bean="${bean}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${bean}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:set var="contact" value="${bean.contactInformation}"/>

<g:form>
    <input type="hidden" name="id" value="${bean.id}"/>
    <input type="hidden" name="task" value="${bean.taskId}"/>

    <div class="row-fluid">

        <div class="span6">

            <div class="row-fluid">

                <div class="control-group">
                    <label id="crm-company-label" class="control-label"><g:message code="crmTaskAttender.company.label" /><span></span></label>

                    <div class="controls">
                        <g:textField name="companyName" value="${contact.companyName}" class="span11"
                                     placeholder="${message(code: 'crmTaskAttender.company.help')}" autocomplete="false" autocorrect="false" spellcheck="false"/>
                        <input type="hidden" name="companyId" value="${contact?.companyId}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label id="crm-person-label" class="control-label"><g:message code="crmTaskAttender.person.label" /><span></span></label>

                    <div class="controls">
                        <g:textField name="firstName" value="${contact.firstName}" class="span5" placeholder="${message(code: 'crmContact.firstName.help')}" autocomplete="false" autocorrect="false" spellcheck="false"/>
                        <g:textField name="lastName" value="${contact.lastName}" class="span6" placeholder="${message(code: 'crmContact.lastName.help')}" autocomplete="false" autocorrect="false" spellcheck="false"/>
                        <input type="hidden" name="contactId" value="${bean.contactId}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmContact.title.label" /></label>

                    <div class="controls">
                        <g:textField name="title" value="${contact.title}" class="span11" placeholder="${message(code: 'crmContact.title.help')}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.address.label" /></label>

                    <div class="controls">
                        <g:textField name="address" value="${contact.fullAddress}" class="span11"
                                     placeholder="${message(code: 'crmTaskAttender.address.help')}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.telephone.label" /></label>

                    <div class="controls">
                        <g:textField name="telephone" value="${contact.telephone}" class="span11"
                                     placeholder="${message(code: 'crmTaskAttender.telephone.help')}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.email.label" /></label>

                    <div class="controls">
                        <g:textField name="email" value="${contact.email}" class="span11"
                                     placeholder="${message(code: 'crmTaskAttender.email.help')}"/>
                    </div>
                </div>

                <div class="control-group">
                    <div class="controls">
                        <label class="checkbox">
                            <g:checkBox name="hide" value="true" checked="${bean.hide}"/>
                            <g:message code="crmTaskAttender.hidden.label" />
                        </label>
                    </div>
                </div>

                <div class="control-group">
                    <div class="controls">
                        <label class="checkbox">
                            <g:checkBox name="createContact" value="true" checked="${bean.contact != null}"/>
                            <g:message code="crmTaskAttender.save.contact.label" />
                        </label>
                    </div>
                </div>

            </div>
        </div>

        <div class="span6">
            <div class="row-fluid">

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.status.label" /></label>

                    <div class="controls">
                        <g:select from="${statusList}" name="status.id" optionKey="id" value="${bean.status?.id}"
                                  class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.booking.label" /></label>

                    <div class="controls">
                        <div class="input-append">
                        <g:select name="booking.id" from="${bookingList}" optionKey="id" optionValue="title"
                                  value="${bean.bookingId}"
                                  noSelection="['': message(code: 'crmTaskAttender.no.booking.label')]"/>
                        <g:if test="${bean.bookingId}">
                            <g:link controller="crmTaskBooking" action="show" id="${bean.bookingId}" class="add-on">
                                <i class="icon-glass"></i>
                            </g:link>
                        </g:if>
                        </div>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.bookingRef.label" /></label>

                    <div class="controls">
                        <g:textField name="bookingRef" value="${bean.bookingRef}" class="span11"
                                     placeholder="${message(code: 'crmTaskAttender.bookingRef.help')}"/>
                    </div>
                </div>

                <g:set var="tags" value="${bean.id ? bean.getTagValue() : []}"/>
                <g:if test="${tags}">
                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTaskAttender.tags.label" /></label>
                        <div class="controls">
                            <g:each in="${tags}" var="tag">
                                <span class="label label-info">${tag}</span>
                            </g:each>
                        </div>
                    </div>
                </g:if>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.notes.label" /></label>

                    <div class="controls">
                        <g:textArea name="notes" value="${bean.@notes}" rows="2" class="span11"
                                    placeholder="${message(code: 'crmTaskAttender.notes.help')}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.bookingDate.label" /></label>

                    <div class="controls">
                        <div class="input-append date">
                            <g:textField name="bookingDate" class="span9" size="10"
                                         value="${formatDate(type: 'date', date: bean.bookingDate ?: new Date())}"/><span
                                class="add-on"><i class="icon-th"></i></span>
                        </div>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label"><g:message code="crmTaskAttender.externalRef.label" /></label>

                    <div class="controls">
                        <g:textField name="externalRef" value="${bean.externalRef}" class="span6"
                                     placeholder="${message(code: 'crmTaskAttender.externalRef.help')}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="form-actions">
        <g:if test="${bean.id}">
            <crm:button action="attender" visual="warning" icon="icon-ok icon-white"
                        label="crmTaskAttender.button.save.label"/>
            <crm:button visual="danger" action="deleteAttender" label="crmTaskAttender.button.delete.label" icon="icon-trash icon-white"
                        confirm="${message(code: 'crmTaskAttender.button.delete.confirm')}"/>
        </g:if>
        <g:else>
            <crm:button action="attender" visual="success" icon="icon-ok icon-white"
                        label="crmTaskAttender.button.save.label"/>
        </g:else>

        <button id="crm-cancel" class="btn" onclick="return cancelAttender()">
            <i class="icon-remove"></i>
            <g:message code="crmAttender.button.cancel.label" default="Cancel"/>
        </button>
    </div>

</g:form>
