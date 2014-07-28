<%@ page import="org.springframework.web.servlet.support.RequestContextUtils; grails.plugins.crm.core.DateUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <g:set var="locale" value="${RequestContextUtils.getLocale(request) ?: new Locale('sv_SE')}"/>
    <title><g:message code="crmTask.edit.title" args="[entityName, crmTask]"/></title>
    <r:require modules="datepicker,autocomplete,aligndates"/>
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

        $("input[name='location']").autocomplete("${createLink(action: 'autocompleteLocation')}", {
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

<g:set var="reference" value="${crmTask.reference}"/>

<crm:header title="crmTask.edit.title" subtitle="${reference}" args="[crmTask, reference]"/>

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

<g:form action="edit">

<f:with bean="crmTask">

<g:hiddenField name="id" value="${crmTask?.id}"/>
<g:hiddenField name="version" value="${crmTask?.version}"/>
<g:hiddenField name="referer" id="hiddenReferer" value="${referer}"/>

<div class="tabbable">
    <ul class="nav nav-tabs">
        <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmTask.tab.main.label"/></a>
        </li>
        <li><a href="#misc" data-toggle="tab"><g:message code="crmTask.tab.misc.label"/>
            ${crmTask.description ? '(1)' : ''}</a>
        </li>
        <crm:pluginViews location="tabs" var="view">
            <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
        </crm:pluginViews>
    </ul>

    <div class="tab-content">
        <div class="tab-pane active" id="main">

            <div class="row-fluid">

                <div class="span4">
                    <div class="row-fluid">
                        <f:field property="name" input-autofocus="" input-class="span11"/>

                        <f:field property="location" input-class="span11"/>

                        <f:field property="displayDate" input-class="span11"/>

                        <f:field property="scope" input-class="span11"/>
                    </div>
                </div>

                <div class="span4">
                    <div class="row-fluid">
                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTask.startTime.label"/></label>

                            <div class="controls">
                                <span class="input-append date">
                                    <g:textField name="startDate" class="span8" size="10"
                                                 value="${formatDate(type: 'date', date: crmTask.startTime)}"/><span
                                        class="add-on"><i class="icon-th"></i></span>
                                </span>

                                <g:select name="startTime" from="${metadata.timeList}"
                                          value="${formatDate(format: 'HH:mm', date: crmTask.startTime)}"
                                          class="span4"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTask.endTime.label"/></label>

                            <div class="controls">
                                <span class="input-append date">
                                    <g:textField name="endDate" class="span8" size="10"
                                                 value="${formatDate(type: 'date', date: crmTask.endTime)}"/><span
                                        class="add-on"><i class="icon-th"></i></span>
                                </span>

                                <g:select name="endTime" from="${metadata.timeList}"
                                          value="${formatDate(format: 'HH:mm', date: crmTask.endTime)}"
                                          class="span4"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTask.alarm.label"
                                                                    default="Notify"/></label>

                            <div class="controls">
                                <g:select from="${CrmTask.constraints.alarmType.inList}" name="alarmType"
                                          value="${crmTask.alarmType}"
                                          valueMessagePrefix="crmTask.alarmType" class="span9"/>
                            </div>

                            <div class="controls">
                                <g:select from="${[0, 5, 10, 15, 30, 60, 120, 180, 240]}" name="alarmOffset"
                                          value="${crmTask.alarmOffset}"
                                          valueMessagePrefix="crmTask.alarmOffset"
                                          class="span9 ${crmTask.alarmType ? '' : 'hide'}"/>
                            </div>
                        </div>

                        <div class="control-group">
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
                    </div>
                </div>

                <div class="span4">
                    <div class="row-fluid">
                        <f:field property="type">
                            <g:select name="type.id" from="${metadata.typeList}" optionKey="id"
                                      value="${crmTask.type?.id}" class="span11"/>
                        </f:field>

                        <f:field property="complete">
                            <g:select name="complete"
                                      from="${[CrmTask.STATUS_PLANNED, CrmTask.STATUS_ACTIVE, CrmTask.STATUS_COMPLETED]}"
                                      valueMessagePrefix="crmTask.complete" class="span11"
                                      value="${crmTask.complete}"/>
                        </f:field>

                        <f:field property="priority">
                            <g:select name="priority"
                                      from="${[CrmTask.PRIORITY_LOWEST, CrmTask.PRIORITY_LOW, CrmTask.PRIORITY_NORMAL, CrmTask.PRIORITY_HIGH, CrmTask.PRIORITY_HIGHEST]}"
                                      valueMessagePrefix="crmTask.priority" class="span11"
                                      value="${crmTask.priority}"/>
                        </f:field>

                        <f:field property="username">
                            <g:select name="username" from="${metadata.userList}" optionKey="username" optionValue="name"
                                      value="${crmTask.username}" class="span11"/>
                        </f:field>
                    </div>
                </div>

            </div>
        </div>

        <div class="tab-pane" id="misc">
            <div class="row-fluid">
                <div class="span6">
                    <f:field property="description">
                        <g:textArea name="description" value="${crmTask.description}" rows="12" cols="70"
                                    class="span12"/>
                    </f:field>
                </div>

                <div class="span6">
                    <f:field property="number" input-class="span5"/>
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
                        <label class="control-label"><g:message code="crmAddress.address1.label"/></label>

                        <div class="controls">
                            <g:textField name="address.address1" value="${crmTask.address?.address1}" class="span8"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmAddress.address2.label"/></label>

                        <div class="controls">
                            <g:textField name="address.address2" value="${crmTask.address?.address2}" class="span8"/>
                        </div>
                    </div>

                    <div class="control-group hide">
                        <label class="control-label"><g:message code="crmAddress.address3.label"/></label>

                        <div class="controls">
                            <g:textField name="address.address3" value="${crmTask.address?.address3}" class="span8"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmAddress.postalAddress.label"/></label>

                        <div class="controls">
                            <g:textField name="address.postalCode" value="${crmTask.address?.postalCode}"
                                         class="span3"/>
                            <g:textField name="address.city" value="${crmTask.address?.city}" class="span5"/>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

</f:with>

<div class="form-actions">
    <crm:button visual="warning" icon="icon-ok icon-white" label="crmTask.button.update.label"/>
    <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                label="crmTask.button.delete.label"
                confirm="crmTask.button.delete.confirm.message" permission="crmTask:delete"/>
    <crm:button type="link" action="show" id="${crmTask.id}"
                icon="icon-remove"
                label="crmTask.button.cancel.label"/>
</div>

</g:form>

</body>
</html>
