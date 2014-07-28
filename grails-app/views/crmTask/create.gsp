<%@ page import="org.springframework.web.servlet.support.RequestContextUtils; grails.plugins.crm.core.DateUtils; grails.plugins.crm.task.CrmTask" %><!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <g:set var="locale" value="${RequestContextUtils.getLocale(request) ?: new Locale('sv_SE')}"/>
    <title><g:message code="crmTask.create.title" args="[entityName]"/></title>
    <r:require modules="datepicker,aligndates,autocomplete"/>
    <r:script>
    $(document).ready(function() {

        $('#startDate').closest('.date').datepicker({
            format: "${metadata.dateFormat.toPattern().toLowerCase()}",
            weekStart: <%= DateUtils.getFirstDayOfWeek(locale, user.timezone) - 1 %>,
            language: "${locale.getLanguage()}",
            calendarWeeks: ${grailsApplication.config.crm.datepicker.calendarWeeks ?: false},
            todayHighlight: true,
            autoclose: true
        }).on('changeDate', function(ev) {
            <% if(grailsApplication.config.crm.task.alignDates) { %>
            alignDates($("#startDate"), $("#endDate"), false, ".date");
            <% } %>
        });

        <% if(grailsApplication.config.crm.task.alignDates) { %>
        $("#startDate").blur(function(ev) {
          alignDates($(this), $("#endDate"), false, ".date");
        });
        <% } %>

        $('#endDate').closest('.date').datepicker({
            format: "${metadata.dateFormat.toPattern().toLowerCase()}",
            weekStart: <%= DateUtils.getFirstDayOfWeek(locale, user.timezone) - 1 %>,
            language: "${locale.getLanguage()}",
            calendarWeeks: ${grailsApplication.config.crm.datepicker.calendarWeeks ?: false},
            todayHighlight: true,
            autoclose: true
        }).on('changeDate', function(ev) {
        <% if(grailsApplication.config.crm.task.alignDates) { %>
            alignDates($("#endDate"), $("#startDate"), true, ".date");
        <% } %>
        });

        <% if(grailsApplication.config.crm.task.alignDates) { %>
        $("#endDate").blur(function(ev) {
          alignDates($(this), $("#startDate"), true, ".date");
        });
        <% } %>

        $('select[name="alarmType"]').change(function(ev) {
            if($(this).val() == '0') {
                $("#alarmOffset").hide();
            } else {
                $("#alarmOffset").show();
            }
        });

        // Add autocomplete for location field.
        $("input[name='location']").autocomplete("${createLink(action: 'autocompleteLocation')}", {
            remoteDataType: 'json',
            useCache: false,
            filter: false,
            preventDefaultReturn: true,
            selectFirst: true
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
                        $(".page-header h1").append($(' <small class="pulse">' + first.text + '</small>'));
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
    <g:hiddenField name="referer" id="hiddenReferer" value="${referer}"/>

    <f:with bean="crmTask">

        <div class="row-fluid">

            <div class="span4">
                <div class="row-fluid">
                    <f:field property="name" input-autofocus="" input-class="span11"/>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTask.startTime.label"/></label>

                        <div class="controls">
                            <span class="input-append date" style="margin-right: 20px;">
                                <g:textField name="startDate" class="span9" size="10"
                                             value="${formatDate(type: 'date', date: crmTask.startTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>

                            <g:select name="startTime" from="${metadata.timeList}" value="${formatDate(format: 'HH:mm', date: crmTask.startTime)}" class="span4"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTask.endTime.label"/></label>

                        <div class="controls">
                            <span class="input-append date" style="margin-right: 20px;">
                                <g:textField name="endDate" class="span9" size="10"
                                             value="${formatDate(type: 'date', date: crmTask.endTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>

                            <g:select name="endTime" from="${metadata.timeList}" value="${formatDate(format: 'HH:mm', date: crmTask.endTime)}" class="span4"/>
                        </div>
                    </div>

                    <f:field property="location" input-class="span11"/>
                </div>
            </div>

            <div class="span3">
                <div class="row-fluid">

                    <f:field property="username">
                        <g:select name="username" from="${metadata.userList}" optionKey="username" optionValue="name"
                                  value="${crmTask.username}" class="span11"/>
                    </f:field>

                    <f:field property="type">
                        <g:select name="type.id" from="${metadata.typeList}" optionKey="id"
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

                    <div class="control-group">
                        <div class="controls">
                            <label class="checkbox inline">
                                <g:checkBox name="hidden" value="${crmTask.hidden}"/>
                                <g:message code="crmTask.hidden.label" default="Hidden"/>
                            </label>
                        </div>
                    </div>

                    <f:field property="description">
                        <g:textArea name="description" value="${crmTask.description}" rows="4" cols="50"
                                    class="span12"/>
                    </f:field>
                </div>
            </div>

        </div>

        <div class="form-actions">
            <crm:button visual="success" icon="icon-ok icon-white" label="crmTask.button.save.label"/>
        </div>

    </f:with>

</g:form>

</body>
</html>
