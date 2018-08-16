%{--
  - Copyright (c) 2018 Goran Ehrsson.
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  --}%

<%@ page import="org.springframework.web.servlet.support.RequestContextUtils; grails.plugins.crm.core.DateUtils; grails.plugins.crm.task.CrmTask" %><!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <g:set var="locale" value="${RequestContextUtils.getLocale(request) ?: Locale.getDefault()}"/>
    <title><g:message code="crmTask.create.title" args="[entityName]"/></title>
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
                $("#alarmOffset").val('');
                $("#alarmOffset").hide();
                $("#alarmOffsetLabel").hide();
            } else {
                $("#alarmOffset").show();
                $("#alarmOffsetLabel").show();
            }
        });

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

<crm:header title="crmTask.create.title" subtitle="${attender ?: reference}" args="[entityName, attender ?: reference]"/>

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
                            </div>
                        </div>


                        <div class="span6">
                            <div class="row-fluid">
                                <f:field property="name">
                                    <g:textField name="name" value="${crmTask.name}" class="span11"/>
                                </f:field>

                                <f:field property="description">
                                    <g:textArea name="description" value="${crmTask.description}" rows="12" cols="70"
                                                class="span11"/>
                                </f:field>

                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>

    </f:with>

    <div class="form-actions">
        <crm:button visual="success" icon="icon-ok icon-white" label="crmTask.button.save.label"/>
    </div>

</g:form>

</body>
</html>
