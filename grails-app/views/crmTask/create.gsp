<%@ page import="grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.create.title" args="[entityName]"/></title>
    <r:require modules="datepicker,select2,aligndates"/>
    <r:script>
    $(document).ready(function() {

        $('#startDate').closest('.date').datepicker({weekStart:1}).on('changeDate', function(ev) {
            alignDates($("#startDate"), $("#endDate"), false, ".date");
        });
        $("#startDate").blur(function(ev) {
          alignDates($(this), $("#endDate"), false, ".date");
        });
        $('#endDate').closest('.date').datepicker({weekStart:1}).on('changeDate', function(ev) {
            alignDates($("#endDate"), $("#startDate"), true, ".date");
        });
        $("#endDate").blur(function(ev) {
          alignDates($(this), $("#startDate"), true, ".date");
        });

        $('select[name="alarmType"]').change(function(ev) {
            if($(this).val() == '0') {
                $("#alarmOffset").hide();
            } else {
                $("#alarmOffset").show();
            }
        });

        // Add autocomplete for location field.
        $("input[name='location']").select2({
            placeholder: "${message(code: 'crmTask.location.placeholder', default: '')}",
            minimumInputLength: 1,
            //tags: true,
            ajax: { // instead of writing the function to execute the request we use Select2's convenient helper
                url: "${createLink(action: 'autocompleteLocation')}",
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
                callback({id: element.val(), text: element.val()});
            },
            formatSearching: function() { return "Söker..."; },
            formatNoMatches: function(term) { return ""; },
            formatInputTooShort: function(term, minLengh) { return "Skriv ett par tecken i början av platsen..."; }
        });

        $("input[name='name']").blur(function(ev) {
            var value = $(this).val();
            var ref = $("input[name='ref']").val();
            if(value && !ref) {
                $.getJSON("${createLink(action: 'guessReference')}", {text:value}, function(data) {
                    var result = data.results;
                    if(result.length > 0) {
                        var first = result[0];
                        $("input[name='ref']").val(first.id);
                        $(".page-header h1 small").remove();
                        $(".page-header h1").append($('<small class="pulse">' + first.text + '</small>'));
                    }
                });
            }
        });
    });
    </r:script>
</head>

<body>

<g:set var="reference" value="${crmTask.reference}"/>

<crm:header title="crmTask.create.title" subtitle="${reference}" args="[entityName, reference]"/>

<g:hasErrors bean="${crmTask}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmTask}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:form action="create">

    <g:hiddenField name="ref" value="${crmTask.ref}"/>

    <f:with bean="crmTask">

        <div class="row-fluid">

            <div class="span4">
                <div class="row-fluid">
                    <f:field property="name" input-autofocus="" input-class="span11"/>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTask.startTime.label"/></label>

                        <div class="controls">
                            <span class="input-append date" style="margin-right: 20px;"
                                  data-date="${formatDate(format: 'yyyy-MM-dd', date: crmTask.startTime ?: new Date())}">
                                <g:textField name="startDate" class="span7" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                             value="${formatDate(format: 'yyyy-MM-dd', date: crmTask.startTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>

                            <g:select name="startTime" from="${timeList}" value="${formatDate(format: 'HH:mm', date: crmTask.startTime)}" class="span4"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTask.endTime.label"/></label>

                        <div class="controls">
                            <span class="input-append date" style="margin-right: 20px;"
                                  data-date="${formatDate(format: 'yyyy-MM-dd', date: crmTask.endTime ?: new Date())}">
                                <g:textField name="endDate" class="span7" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                             value="${formatDate(format: 'yyyy-MM-dd', date: crmTask.endTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>

                            <g:select name="endTime" from="${timeList}" value="${formatDate(format: 'HH:mm', date: crmTask.endTime)}" class="span4"/>
                        </div>
                    </div>

                    <div class="control-group clearfix">
                        <label class="control-label"><g:message code="crmTask.location.label"
                                                                default="Location"/></label>

                        <div class="controls">
                            <g:hiddenField id="location-select" name="location" value="${crmTask.location}"
                                           class="span11"/>
                        </div>
                    </div>

                </div>
            </div>

            <div class="span3">
                <div class="row-fluid">

                    <f:field property="username">
                        <g:select name="username" from="${userList}" optionKey="username" optionValue="name"
                                  value="${crmTask.username}" class="span11"/>
                    </f:field>

                    <f:field property="type">
                        <g:select name="type.id" from="${typeList}" optionKey="id"
                                  value="${crmTask.type?.id}" class="span11"/>
                    </f:field>

                    <f:field property="complete">
                        <g:select name="complete"
                                  from="${[CrmTask.STATUS_PLANNED, CrmTask.STATUS_ACTIVE, CrmTask.STATUS_COMPLETED]}"
                                  valueMessagePrefix="crmTask.complete" class="span11" value="${crmTask.complete}"/>
                    </f:field>

                    <f:field property="priority">
                        <g:select name="priority"
                                  from="${[CrmTask.PRIORITY_LOWEST, CrmTask.PRIORITY_LOW, CrmTask.PRIORITY_NORMAL, CrmTask.PRIORITY_HIGH, CrmTask.PRIORITY_HIGHEST]}"
                                  valueMessagePrefix="crmTask.priority" class="span11" value="${crmTask.priority}"/>
                    </f:field>
                </div>
            </div>

            <div class="span5">
                <div class="row-fluid">
                    <%--
                    <f:field property="isRecurring">
                        <div class="inline input-append">
                            <g:textField name="dummy" class="span9" readonly=""
                                         title="Repeterande uppgifter är under utveckling och blir tillgänglig i en framtida version"
                                         value="${crmTask.isRecurring ? 'Repeats every ' + crmTask.recurInterval : 'Ingen repetition'}"/><span
                                class="add-on"><i class="icon-repeat"></i></span>
                        </div>
                    </f:field>
                    --%>
                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTask.alarm.label" default="Notify"/></label>

                        <div class="controls controls-row">
                            <g:select from="${CrmTask.constraints.alarmType.inList}" name="alarmType"
                                      value="${crmTask.alarmType}"
                                      valueMessagePrefix="crmTask.alarmType" class="span6"/>

                            <g:select from="${[0, 5, 10, 15, 30, 60, 120, 180, 240]}" name="alarmOffset"
                                      value="${crmTask.alarmOffset}"
                                      valueMessagePrefix="crmTask.alarmOffset"
                                      class="span6 ${crmTask.alarmType ? '' : 'hide'}"/>
                        </div>
                    </div>


                    <div class="control-group clearfix" style="margin-bottom: 25px;">
                        <div class="controls">
                            <label class="checkbox inline">
                                <g:checkBox name="busy" value="${crmTask.busy}"/>
                                <g:message code="crmTask.busy.label" default="Busy"/>
                            </label>
                            <label class="checkbox inline">
                                <g:checkBox name="dynamic" value="${crmTask.referenceProperty != null}"/>
                                <g:message code="crmTask.dynamic.label" default="Dynamic"/>
                            </label>
                        </div>
                    </div>

                    <f:field property="description">
                        <g:textArea name="description" value="${crmTask.description}" rows="6" cols="50"
                                    class="span12"/>
                    </f:field>
                </div>
            </div>

        </div>

        <div class="form-actions">
            <crm:button visual="primary" icon="icon-ok icon-white" label="crmTask.button.save.label"/>
        </div>

    </f:with>

</g:form>

</body>
</html>
