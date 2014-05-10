<h3>${bean.id ? 'Ändra' : 'Registrera'} deltagare</h3>

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
                    <label class="control-label">Företag<span id="crm-company-indicator"></span></label>

                    <div class="controls">
                        <g:textField name="companyName" value="${contact.companyName}" class="span11"
                                     placeholder="Företagsnamn" autocomplete="off"/>
                        <input type="hidden" name="companyId" value="${bean.contact?.parentId}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">Person<span id="crm-person-indicator"></span></label>

                    <div class="controls">
                        <g:textField name="firstName" value="${contact.firstName}" class="span5" placeholder="Förnamn"/>
                        <g:textField name="lastName" value="${contact.lastName}" class="span6" placeholder="Efternamn"/>
                        <input type="hidden" name="contactId" value="${bean.contactId}"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">Titel</label>

                    <div class="controls">
                        <g:textField name="title" value="${contact.title}" class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">Adress</label>

                    <div class="controls">
                        <g:textField name="address" value="${contact.fullAddress}" class="span11"
                                     placeholder="Postadress"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">Telefon</label>

                    <div class="controls">
                        <g:textField name="telephone" value="${contact.telephone}" class="span11"
                                     placeholder="Telefon till deltagaren"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">E-post</label>

                    <div class="controls">
                        <g:textField name="email" value="${contact.email}" class="span11"
                                     placeholder="E-post till deltagaren"/>
                    </div>
                </div>

            </div>
        </div>

        <div class="span6">
            <div class="row-fluid">

                <div class="control-group">
                    <label class="control-label">Referens</label>

                    <div class="controls">
                        <g:textField name="bookingRef" value="${bean.bookingRef}" class="span11"
                                     placeholder="Referens hos beställaren"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">Meddelande</label>

                    <div class="controls">
                        <g:textArea name="notes" value="${bean.notes}" rows="5" class="span11"
                                    placeholder="Eventuellt meddelande, t.ex. allergi eller andra önskemål"/>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">Bokningsdatum</label>

                    <div class="controls">
                        <div class="input-append date">
                            <g:textField name="bookingDate" class="span9" size="10"
                                         placeholder="ÅÅÅÅ-MM-DD"
                                         value="${formatDate(format: 'yyyy-MM-dd', date: bean.bookingDate ?: new Date())}"/><span
                                class="add-on"><i class="icon-th"></i></span>
                        </div>
                    </div>
                </div>

                <div class="control-group">
                    <label class="control-label">Deltagarstatus</label>

                    <div class="controls">
                        <g:select from="${statusList}" name="status.id" optionKey="id" value="${bean.status?.id}"
                                  class="span11"/>
                    </div>
                </div>

                <div class="control-group">
                    <div class="controls">
                        <label class="checkbox">
                            <g:checkBox name="createContact" value="true" checked="${bean.contact != null}"/>
                            Spara deltagaren i kontaktregistret
                        </label>
                    </div>
                </div>

                <div class="control-group">
                    <div class="controls">
                        <label class="checkbox">
                            <g:checkBox name="hide" value="true" checked="${bean.hide}"/>
                            Dölj e-post i detaltagarlistor
                        </label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="form-actions">
        <crm:button action="attender" visual="success" icon="icon-ok icon-white"
                    label="crmTaskAttender.button.save.label"/>
        <g:if test="${bean.id}">
            <crm:button visual="danger" action="deleteAttender" label="Radera" icon="icon-trash icon-white"
                        confirm="Är du säker på att du vill radera bokningen för ${bean}?"/>
        </g:if>

        <button id="crm-cancel" class="btn" onclick="return cancelAttender()">
            <i class="icon-remove"></i>
            <g:message code="crmAttender.button.cancel.label" default="Cancel"/>
        </button>
    </div>

</g:form>