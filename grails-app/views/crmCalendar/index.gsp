<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title><g:message code="crmCalendar.index.title"/></title>
    <r:require module="calendar"/>
    <r:script>
        $(document).ready(function() {
            $("#calendar").fullCalendar({
                events: "${createLink(action: 'events', params: [username: params.username, calendars:calendars])}",
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                monthNames: <%= metadata.monthNames.collect{"'$it'"} %>,
                monthNamesShort: <%= metadata.monthNamesShort.collect{"'$it'"} %>,
                dayNames: <%= metadata.dayNames.collect{"'$it'"} %>,
                dayNamesShort: <%= metadata.dayNamesShort.collect{"'$it'"} %>,
                buttonText: {
                    today: "${message(code: 'crmCalendar.today.label', default: 'Today')}",
                    month: "${message(code: 'crmCalendar.month.label', default: 'Month')}",
                    week: "${message(code: 'crmCalendar.week.label', default: 'Week')}",
                    day: "${message(code: 'crmCalendar.day.label', default: 'Dag')}"
                },
                allDayText: "${message(code: 'crmCalendar.allday.label', default: 'All day')}",
                axisFormat: 'H:mm',
                timeFormat: {
                    '': 'H:mm', // default
                    agenda: 'H:mm{ - H:mm}'
                },
                firstDay: <%= metadata.firstDayOfWeek - 1 %>,
                weekNumbers: true,
                weekNumberTitle: "${message(code: 'crmCalendar.weekNumber.label', default: 'w.')}",
                eventClick: function(calEvent, jsEvent, view) {
                    window.location.href = calEvent.url;
                }
            });

            $("#tenantForm :checkbox").click(function(ev) {
                $(this).closest("form").submit();
            });
        });
    </r:script>
</head>

<body>

<div class="row-fluid">
    <div class="span10">
        <div id="calendar"></div>
    </div>

    <div class="span2">
        <h4><g:message code="crmCalendar.tenants.label" default="Show tenants"/></h4>
        <g:form name="tenantForm">
            <crm:eachTenant var="t">
                <label class="checkbox"><g:checkBox name="calendars" value="${t.id}"
                                                    checked="${calendars.contains(t.id)}"/> ${t.name.encodeAsHTML()}</label>
            </crm:eachTenant>
        </g:form>
    </div>
</div>

<div class="form-actions btn-toolbar">
    <crm:selectionMenu visual="primary">
        <crm:button type="link" controller="crmTask" action="index" icon="icon-search icon-white" visual="primary"
                    label="crmTask.button.find.label"/>
    </crm:selectionMenu>
    <crm:button type="link" group="true" controller="crmTask" action="create" visual="success"
                icon="icon-file icon-white"
                label="crmTask.button.create.label" permission="crmTask:create"/>
</div>

</body>

</html>
