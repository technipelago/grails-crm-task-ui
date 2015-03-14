<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title><g:message code="crmCalendar.index.title"/></title>
    <r:require modules="calendar,qtip"/>
    <r:script>
        $(document).ready(function() {
            $("#calendar").fullCalendar({
                events: "${createLink(action: 'events', params: [username: params.username, calendars:calendars])}",
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                lang: '${metadata.lang}',
                axisFormat: 'H:mm',
                timeFormat: {
                    '': 'H:mm', // default
                    agenda: 'H:mm{ - H:mm}'
                },
                firstDay: <%= metadata.firstDayOfWeek - 1 %>,
                weekNumbers: true,
                weekNumberTitle: "${message(code: 'crmCalendar.weekNumber.label', default: 'w.')}",
                businessHours: {
                    start: '8:00',
                    end: '17:00',
                    dow: [1, 2, 3, 4, 5]
                    // days of week. an array of zero-based day of week integers (0=Sunday)
                    // (Monday-Thursday in this example)
                },
                aspectRatio: 2,
                eventRender: function(event, element) {
                    element.find('.fc-time').hide(); // Hide title.
                    if(event.description) {
                        element.qtip({
                            content: {
                                text: '<p><strong>' + event.title + '</strong></p><p>' + event.description + '</p>'
                            }
                        });
                    }
                },
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
