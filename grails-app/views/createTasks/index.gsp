<%@ page import="grails.util.GrailsNameUtils; org.springframework.web.servlet.support.RequestContextUtils; grails.plugins.crm.core.DateUtils; grails.plugins.crm.task.CrmTask" %><!DOCTYPE html>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="propertyName" value="${GrailsNameUtils.getPropertyName(entityName)}"/>
    <g:set var="locale" value="${RequestContextUtils.getLocale(request) ?: Locale.getDefault()}"/>
    <title><g:message code="${propertyName}.selection.createTasks.title" args="${[totalCount, message(code: propertyName + '.label')]}"/></title>
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

        $('#alarmDate').closest('.date').datepicker({
            format: "${metadata.dateFormat.toPattern().toLowerCase()}",
            weekStart: <%= DateUtils.getFirstDayOfWeek(locale, user.timezone) - 1 %>,
            language: "${locale.getLanguage()}",
            calendarWeeks: ${grailsApplication.config.crm.datepicker.calendarWeeks ?: false},
            todayHighlight: true,
            autoclose: true
        });

        $('select[name="alarmType"]').change(function(ev) {
            if($(this).val() == '0') {
                $("#alarmOffset").val('0');
                $("#alarmOffset").hide();
                $("#alarmOffsetLabel").hide();
            } else {
                $("#alarmOffset").show();
                $("#alarmOffsetLabel").show();
            }
        });

        $("input[name='location']").autocomplete("${createLink(controller: 'crmTask', action: 'autocompleteLocation')}", {
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
                $.getJSON("${createLink(controller: 'crmTask', action: 'guessReference')}", {text:value}, function(data) {
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

<crm:header title="${propertyName}.selection.createTasks.title" args="${[totalCount, message(code: propertyName + '.label')]}"/>

<g:form action="save">

    <input type="hidden" name="q" value="${select.encode(selection: selection)}"/>
    <input type="hidden" name="entityName" value="${propertyName}"/>

    <f:with bean="crmTask">

        <g:hiddenField name="ref" value="${crmTask.ref}"/>
        <g:hiddenField name="referer" id="hiddenReferer" value="${referer}"/>
        <g:hiddenField name="attender" id="hiddenAttender" value="${attender?.id}"/>

        <input type="hidden" name="busy" value="true"/>

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmTask.tab.main.label"/></a>
                </li>
                <crm:pluginViews location="tabs" var="view">
                    <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
                </crm:pluginViews>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="main">

                    <div class="row-fluid">

                        <div class="span6">
                            <div class="row-fluid">
                                <f:field property="type">
                                    <g:select name="type.id" from="${metadata.typeList}" optionKey="id"
                                              value="${crmTask.type?.id}" class="span11" autofocus=""/>
                                </f:field>

                                <f:field property="complete">
                                    <g:select name="complete"
                                              from="${[CrmTask.STATUS_PLANNED, CrmTask.STATUS_ACTIVE, CrmTask.STATUS_COMPLETED]}"
                                              valueMessagePrefix="crmTask.complete" class="span11"
                                              value="${crmTask.complete}"/>
                                </f:field>

                                <div class="row-fluid">

                                    <div class="span6">
                                        <div class="row-fluid">

                                            <div class="control-group">
                                                <label class="control-label"><g:message code="crmTask.startTime.label"/></label>

                                                <div class="controls">
                                                    <span class="input-append date">
                                                        <g:textField name="startDate" class="span9" size="10"
                                                                     value="${formatDate(type: 'date', date: crmTask.startTime)}"/><span
                                                            class="add-on"><i class="icon-th"></i></span>
                                                    </span>

                                                    <g:select name="startTime" from="${metadata.timeList}"
                                                              value="${formatDate(format: 'HH:mm', date: crmTask.startTime)}"
                                                              class="span3"/>
                                                </div>
                                            </div>

                                            <div class="control-group">
                                                <label class="control-label"><g:message code="crmTask.endTime.label"/></label>

                                                <div class="controls">
                                                    <span class="input-append date">
                                                        <g:textField name="endDate" class="span9" size="10"
                                                                     value="${formatDate(type: 'date', date: crmTask.endTime)}"/><span
                                                            class="add-on"><i class="icon-th"></i></span>
                                                    </span>

                                                    <g:select name="endTime" from="${metadata.timeList}"
                                                              value="${formatDate(format: 'HH:mm', date: crmTask.endTime)}"
                                                              class="span3"/>
                                                </div>
                                            </div>

                                        </div>
                                    </div>

                                    <div class="span6">
                                        <div class="row-fluid">

                                            <div class="control-group">
                                                <label class="control-label"><g:message code="crmTask.alarmType.label"
                                                                                        default="Notify"/></label>

                                                <div class="controls">
                                                    <g:select from="${metadata.alarmTypes}" name="alarmType" class="span10"
                                                              value="${crmTask.alarmType}" optionKey="value" optionValue="label"/>
                                                </div>

                                                <label id="alarmOffsetLabel" class="control-label ${crmTask.alarmType ? '' : 'hide'}"><g:message code="crmTask.alarmOffset.label"
                                                                                                                                                 default="Notify"/></label>
                                                <div class="controls">
                                                    <g:select from="${[0, 5, 10, 15, 30, 60, 120, 180, 240, 1440, 2880, 10080]}" name="alarmOffset"
                                                              value="${crmTask.alarmOffset}"
                                                              valueMessagePrefix="crmTask.alarmOffset"
                                                              class="span10 ${crmTask.alarmType ? '' : 'hide'}"/>
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                </div>


                                <f:field property="username">
                                    <g:select name="username" from="${metadata.userList}" optionKey="username"
                                              optionValue="name"
                                              value="${crmTask.username}" class="span11"/>
                                </f:field>

                                <f:field property="name">
                                    <g:textField name="name" value="${crmTask.name}" class="span11"/>
                                </f:field>

                                <f:field property="description">
                                    <g:textArea name="description" value="${crmTask.description}" rows="6" cols="70"
                                                class="span11"/>
                                </f:field>
                            </div>
                        </div>


                        <div class="span6">
                            <div class="row-fluid">

                                <table class="table table-striped">
                                    <thead>
                                    <tr>
                                        <th><g:message code="${propertyName}.selection.createTasks.sample" args="${totalCount}"/></th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <g:each in="${result}" var="m">
                                        <tr>
                                            <td><crm:referenceLink reference="${m}">${m}</crm:referenceLink></td>
                                        </tr>
                                    </g:each>
                                    </tbody>
                                </table>

                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>

    </f:with>


    <div class="form-actions">
        <crm:button action="save" label="Starta" icon="icon-ok icon-white" visual="success"
                    confirm="${message(code: propertyName + '.selection.createTasks.confirm', args: [totalCount])}"/>
        <select:link controller="${propertyName}" action="list" selection="${selection}" class="btn">
            <i class="icon-remove"></i>
            <g:message code="${propertyName}.button.back.label" default="Back"/>
        </select:link>
    </div>
</g:form>

</body>
