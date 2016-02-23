<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.export.title" args="[entityName]"/></title>
    <r:script>
        $(document).ready(function () {
            $('h4 a').click(function (ev) {
                ev.preventDefault();
                $(this).closest('form').submit();
            });
            $('.crm-confirm').submit(function(ev) {
                if(confirm('Press ok to start print/export')) {
                    return true;
                }
                ev.preventDefault();
                return false;
            });
        });
    </r:script>
    <style type="text/css">
    .crm-layout {
        border-top: 1px solid #ccc;
        margin-bottom: 0;
    }
    </style>
</head>

<body>

<crm:header title="crmTask.export.title" subtitle="crmTask.export.subtitle" args="[entityName]"/>

<g:each in="${layouts?.sort { it.order }}" var="l">
    <g:form action="export" class="crm-layout ${l.confirm ? 'crm-confirm' : ''}">
        <g:each in="${l}" var="ly">
            <input type="hidden" name="${ly.key}" value="${ly.value}"/>
        </g:each>
        <input type="hidden" name="id" value="${id}"/>
        <input type="hidden" name="q" value="${select.encode(selection: selection)}"/>

        <div class="row-fluid">
            <div class="span7">
                <h4><a href="#">${l.name?.encodeAsHTML()}</a></h4>

                <p>
                    ${l.description?.encodeAsHTML()}
                </p>
            </div>

            <div class="span2" style="padding-top: 10px;">
                <button type="submit" class="btn ${l.confirm ? 'btn-warning' : 'btn-info'}">
                    <i class="icon-ok icon-white"></i>
                    <g:message code="crmExport.button.select.label" default="Select"/>
                </button>
                </div>
            <div class="span2" style="padding-top: 10px;">
                <g:if test="${l.save}">
                    <label class="checkbox">
                        <g:checkBox name="save"/>
                        <g:message code="crmExport.save.output" default="Spara rapporten"/>
                    </label>
                </g:if>
            </div>
        </div>

    </g:form>
</g:each>

<div class="form-actions">
    <select:link action="list" selection="${selection}" class="btn">
        <i class="icon-remove"></i>
        <g:message code="crmTask.button.back.label" default="Back"/>
    </select:link>
</div>

</body>
</html>