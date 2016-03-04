<div class="control-group">
    <label class="control-label"><g:message code="crmTaskAttender.address1.label"/></label>

    <div class="controls">
        <g:textField name="address1" value="${bean.address1}" disabled="${disabled == true}" class="span11"/>
    </div>
</div>

<div class="control-group">
    <label class="control-label"><g:message code="crmTaskAttender.address2.label"/></label>

    <div class="controls">
        <g:textField name="address2" value="${bean.address2}" disabled="${disabled == true}" class="span11"/>
    </div>
</div>

<div class="control-group">
    <label class="control-label"><g:message code="crmTaskAttender.address3.label"/></label>

    <div class="controls">
        <g:textField name="address3" value="${bean.address3}" disabled="${disabled == true}" class="span11"/>
    </div>
</div>

<div class="control-group">
    <label class="control-label"><g:message code="crmTaskAttender.postalAddress.label"/></label>

    <div class="controls">
        <g:textField name="postalCode" value="${bean.postalCode}" class="span3" disabled="${disabled == true}"/>
        <g:textField name="city" value="${bean.city}" class="span8" disabled="${disabled == true}"/>
    </div>
</div>

<div class="control-group">
    <label class="control-label"><g:message code="crmTaskAttender.country.label"/></label>

    <div class="controls">
        <g:textField name="country" value="${bean.country}" disabled="${disabled == true}" class="span11"/>
    </div>
</div>