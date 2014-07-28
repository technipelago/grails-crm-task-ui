<%@ page import="grails.plugins.crm.task.CrmTask" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.find.title" args="[entityName]"/></title>
    <r:require modules="datepicker,autocomplete"/>
    <r:script>
        $(document).ready(function() {
            <crm:datepicker selector="form .date"/>

            $("input[name='type']").autocomplete("${createLink(action: 'autocompleteType')}", {
                remoteDataType: 'json',
                useCache: false,
                filter: false,
                preventDefaultReturn: true,
                selectFirst: true
            });
            $("input[name='username']").autocomplete("${createLink(action: 'autocompleteUsername')}", {
                remoteDataType: 'json',
                useCache: false,
                filter: false,
                preventDefaultReturn: true,
                selectFirst: true
            });
        });
    </r:script>
</head>

<body>

<crm:header title="crmTask.find.title" args="[entityName]"/>

<g:form action="list">

    <div class="row-fluid">

        <f:with bean="cmd">
            <div class="span3">
                <div class="row-fluid">
                    <f:field property="name" label="crmTask.name.label" input-autofocus="" input-class="span12"
                             input-placeholder="${message(code: 'crmTaskQueryCommand.name.placeholder', default: '')}"/>
                    <f:field property="location" label="crmTask.location.label" input-class="span12"
                             input-placeholder="${message(code: 'crmTaskQueryCommand.location.placeholder', default: '')}"/>
                </div>
            </div>

            <div class="span3">
                <div class="row-fluid">
                    <f:field property="fromDate">
                        <div class="input-append date">
                            <g:textField name="fromDate" class="span11" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                         value="${formatDate(format: 'yyyy-MM-dd', date: cmd.fromDate)}"/><span
                                class="add-on"><i
                                    class="icon-th"></i></span>
                        </div>
                    </f:field>
                    <f:field property="toDate">
                        <div class="input-append date">
                            <g:textField name="toDate" class="span11" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                         value="${formatDate(format: 'yyyy-MM-dd', date: cmd.toDate)}"/><span
                                class="add-on"><i
                                    class="icon-th"></i></span>
                        </div>
                    </f:field>
                </div>
            </div>

            <div class="span3">
                <div class="row-fluid">
                    <f:field property="type" label="crmTask.type.label">
                        <input type="text" name="type" value="${fieldValue(bean: cmd, field: 'type')}"
                               class="span12" autocomplete="off"/>
                    </f:field>
                    <f:field property="username" label="crmTask.username.label">
                        <input type="text" name="username" value="${fieldValue(bean: cmd, field: 'username')}"
                               class="span12" autocomplete="off"/>
                    </f:field>
                </div>
            </div>

            <div class="span3">
                <div class="row-fluid">
                    <g:if test="${useAttenders}">
                        <f:field property="attender" label="crmTaskAttender.label">
                            <input type="text" name="attender" value="${fieldValue(bean: cmd, field: 'attender')}"
                                   class="span12"/>
                        </f:field>
                    </g:if>
                    <f:field property="tags" label="crmTask.tags.label">
                        <g:textField name="tags" class="span12" value="${cmd.tags}"
                                     placeholder="${message(code: 'crmTask.tags.placeholder', default: '')}"/>
                    </f:field>
                </div>
            </div>
        </f:with>

    </div>

    <div class="form-actions btn-toolbar">
        <crm:selectionMenu visual="primary">
            <crm:button action="list" icon="icon-search icon-white" visual="primary"
                        label="crmTask.button.search.label"/>
        </crm:selectionMenu>
        <crm:button type="link" group="true" action="create" visual="success" icon="icon-file icon-white"
                    label="crmTask.button.create.label" permission="crmTask:create"/>
        <g:link action="clearQuery" class="btn btn-link"><g:message code="crmTask.button.query.clear.label"
                                                                    default="Reset fields"/></g:link>
    </div>

</g:form>

</body>
</html>
