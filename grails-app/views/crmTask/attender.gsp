<h3>${bean.id ? 'Ändra' : 'Registrera'} deltagare på ${bean.task}</h3>

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

<g:form action="attender">
    <input type="hidden" name="id" value="${bean.id}"/>
    <input type="hidden" name="version" value="${bean.version}"/>
    <input type="hidden" name="task" value="${bean.taskId}"/>

    <div class="row-fluid">

        <div class="span6">
            <div class="control-group">
                <label class="control-label">Person/Företag</label>

                <div class="controls">
                    <div class="input-append">
                        <g:textField name="contact.name" value="${bean.contact?.name}" class="input-large"/><span
                            class="add-on"><g:link controller="crmContact" action="show" id="${bean.contact?.id}"><i
                                class="icon-zoom-in"></i></g:link></span>
                    </div>
                    <input type="hidden" name="contact.id" value="${bean.contact?.id}"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">Referens</label>

                <div class="controls">
                    <g:textField name="bookingRef" value="${bean.bookingRef}" class="input-large"/>
                </div>
            </div>
        </div>

        <div class="span6">

            <div class="control-group">
                <label class="control-label">Deltagarstatus</label>

                <div class="controls">
                    <g:select from="${statusList}" name="status.id" optionKey="id" value="${bean.status?.id}"
                              class="input-large"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">Bokningsdatum</label>

                <div class="controls">
                    <div class="input-append date"
                         data-date="${formatDate(format: 'yyyy-MM-dd', date: new Date())}">
                        <g:textField name="bookingDate" class="input-medium" size="10"
                                     placeholder="ÅÅÅÅ-MM-DD"
                                     value="${formatDate(format: 'yyyy-MM-dd', date: bean.bookingDate ?: new Date())}"/><span
                            class="add-on"><i class="icon-th"></i></span>
                    </div>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">Meddelande</label>

                <div class="controls">
                    <g:textField name="notes" value="${bean.notes}" class="input-large"/>
                </div>
            </div>

        </div>
    </div>

    <div class="form-actions">
        <crm:button visual="success" icon="icon-ok icon-white" label="crmTaskAttender.button.save.label"/>

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