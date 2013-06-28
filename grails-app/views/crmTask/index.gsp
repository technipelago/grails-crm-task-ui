<%@ page import="grails.plugins.crm.task.CrmTask" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.find.title" args="[entityName]"/></title>
    <r:require modules="datepicker,select2"/>
    <r:script>
        $(document).ready(function() {
            $("form .date").datepicker({weekStart:1});

            // Add autocomplete for task type.
            $("input[name='type']").select2({
                placeholder: "${message(code:'crmTaskQueryCommand.type.placeholder', default:'')}",
                minimumInputLength: 1,
                //tags: true,
                ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
                    url: "${createLink(action: 'autocompleteType')}",
                    dataType: 'json',
                    data: function (term, page) {
                        return {
                            q: term,
                            offset: (page-1) * 10,
                            max: 10
                        };
                    },
                    results: function (data, page) { // parse the results into the format expected by Select2.
                        return data;
                    }
                },
                initSelection : function (element, callback) {
                    var data = [];
                    $(element.val().split(/\s*,\s*/)).each(function () {
                        data.push({id: this, text: this});
                    });
                    callback(data);
                },
                formatSearching: function() { return "Söker..."; },
                formatNoMatches: function(term) { return ""; },
                formatInputTooShort: function(term, minLengh) { return "Skriv ett par tecken i början av sökordet..."; }
            });
        });
    </r:script>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <crm:header title="crmTask.find.title" args="[entityName]"/>

        <g:form action="list">

            <div class="row-fluid">

                <f:with bean="cmd">
                    <div class="span4">
                        <div class="row-fluid">
                            <f:field property="name" label="crmTask.name.label" input-autofocus="" input-class="span12"
                                     input-placeholder="${message(code:'crmTaskQueryCommand.name.placeholder', default:'')}"/>
                            <f:field property="location" label="crmTask.location.label" input-class="span12"
                                     input-placeholder="${message(code:'crmTaskQueryCommand.location.placeholder', default:'')}"/>
                        </div>
                    </div>

                    <div class="span4">
                        <div class="row-fluid">
                            <f:field property="fromDate">
                                <div class="input-append date"
                                     data-date="${formatDate(format: 'yyyy-MM-dd', date: cmd.fromDate ?: new Date())}">
                                    <g:textField name="fromDate" class="span11" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                                 value="${formatDate(format:'yyyy-MM-dd', date:cmd.fromDate)}"/><span
                                        class="add-on"><i
                                            class="icon-th"></i></span>
                                </div>
                            </f:field>
                            <f:field property="toDate">
                                <div class="input-append date"
                                     data-date="${formatDate(format: 'yyyy-MM-dd', date: cmd.toDate ?: new Date())}">
                                    <g:textField name="toDate" class="span11" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                                 value="${formatDate(format:'yyyy-MM-dd', date:cmd.toDate)}"/><span
                                        class="add-on"><i
                                            class="icon-th"></i></span>
                                </div>
                            </f:field>
                        </div>
                    </div>

                    <div class="span4">
                        <div class="row-fluid">
                            <f:field property="type" label="crmTask.type.label">
                                <input type="hidden" name="type" value="${fieldValue(bean:cmd, field:'type')}" class="span12"/>
                            </f:field>
                        </div>
                    </div>
                </f:with>

            </div>

            <div class="form-actions btn-toolbar">
                <crm:selectionMenu visual="primary">
                    <crm:button action="list" icon="icon-search icon-white" visual="primary"
                                label="crmTask.button.find.label"/>
                </crm:selectionMenu>
                <crm:button type="link" group="true" action="create" visual="success" icon="icon-file icon-white"
                            label="crmTask.button.create.label" permission="crmTask:create"/>
                <g:link action="clearQuery" class="btn btn-link"><g:message code="crmAgreement.button.query.clear.label"
                                                                            default="Reset fields"/></g:link>
            </div>

        </g:form>
    </div>

    <div class="span3">
    </div>
</div>

</body>
</html>
