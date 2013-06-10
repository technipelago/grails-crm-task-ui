<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title>%{--
  - Copyright (c) 2013 Goran Ehrsson.
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

<g:message code="crmCalendar.index.title"/></title>
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
                monthNames: ['januari', 'februari','mars','april','maj','juni','juli','augusti','september','oktober','november','december'],
                monthNamesShort: ['jan','feb','mar','apr','maj','jun','jul','aug','sep','okt','nov','dec'],
                dayNames: ['söndag', 'måndag', 'tisdag', 'onsdag', 'torsdag', 'fredag', 'lördag'],
                dayNamesShort: ['sön', 'mån', 'tis', 'ons', 'tor', 'fre', 'lör'],
                buttonText: {
                    today: 'Idag',
                    month: 'Månad',
                    week: 'Vecka',
                    day: 'Dag'
                },
                allDayText: 'Heldag',
                axisFormat: 'H:mm',
                timeFormat: {
                    '': 'H:mm', // default
                    agenda: 'H:mm{ - H:mm}'
                },
                firstDay: 1, // Monday
                eventClick: function(calEvent, jsEvent, view) {
                    window.location = "${createLink(controller: 'crmTask', action: 'show')}/" + calEvent.id;
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
        <h4>Visa uppgifter i följande vyer</h4>
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
