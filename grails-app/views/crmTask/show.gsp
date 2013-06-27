<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTask.label', default: 'Task')}"/>
    <title><g:message code="crmTask.show.title" args="[entityName, crmTask]"/></title>
    <r:require modules="datepicker,autocomplete"/>
    <r:script>
            function cancelAttender() {
                $("#attender-panel").slideUp('fast', function () {
                    $("#std-actions").slideDown();
                });
                return false;
            }

            function bindPanelEvents(panel) {
                        $('.date', panel).datepicker({weekStart:1});

                        $("input[name='company.name']").autocomplete("${createLink(action: 'autocompleteCompany')}", {
                            remoteDataType: 'json',
                            preventDefaultReturn: true,
                            selectFirst: true,
                            onItemSelect: function(item) {
                                var id = item.data[0];
                                $("input[name='company.id']").val(id);
                                $("input[name='person.name']").data("autocompleter").setExtraParam({'company.id':id});
                            },
                            onNoMatch: function() {
                                $("input[name='company.id']").val('');
                                $("input[name='person.name']").data("autocompleter").setExtraParam({});
                            }
                        });
                        $("input[name='person.name']").autocomplete("${createLink(action: 'autocompletePerson')}", {
                            remoteDataType: 'json',
                            preventDefaultReturn: true,
                            selectFirst: true,
                            onItemSelect: function(item) {
                                var id = item.data[0];
                                $("input[name='person.id']").val(id);
                            },
                            onNoMatch: function() {
                                $("input[name='person.id']").val('');
                            }
                        });
                    }

            $(document).ready(function () {

                $("a.link-edit").click(function (ev) {
        <% if (crm.hasPermission(permission: 'crmTask:edit', { true })) { %>
        var elem = $(this);
        ev.preventDefault();
        $("#attender-panel").load("${createLink(action: 'attender', params: [event: crmTask.id])}&id=" + elem.data('crm-id'), function(data) {
                        var panel = $(this);
                        bindPanelEvents(panel);
                        $("#std-actions").slideUp('fast', function () {
                            panel.slideDown(function () {
                                $(":input:visible:first", panel).focus();
                            });
                        });
                    });
                    return false;
        <% } else { %>
        return true;
        <% } %>
        });

        $("a[href='#attender-create']").click(function (ev) {
            ev.preventDefault();
        <% if (crm.hasPermission(permission: 'crmTask:edit', { true })) { %>
        $("#attender-panel").load("${createLink(action: 'attender', params: [event: crmTask.id])}", function(data) {
                        var panel = $(this);
                        bindPanelEvents(panel);
                        $("#std-actions").slideUp('fast', function () {
                            panel.slideDown(function () {
                                $(":input:visible:first", panel).focus();
                            });
                        });
                    });
        <% } %>
        return false;
    });
});
    </r:script>
</head>

<body>

<div class="row-fluid">
<div class="span9">

    <header class="page-header clearfix">
        <crm:user>
            <h1 class="pull-left">
                ${crmTask.name.encodeAsHTML()}
                <crm:favoriteIcon bean="${crmTask}"/>
                <small>${crmTask.reference?.encodeAsHTML()}</small>
                ${crmTask.alarm ? '<i class="icon-bell"></i>' : ''}
                ${crmTask.complete ? '<i class="icon-check"></i>' : ''}
            </h1>

            <h2 class="pull-right"><g:fieldValue bean="${crmTask}" field="type"/></h2>
        </crm:user>
    </header>

    <div class="tabbable">
        <ul class="nav nav-tabs">
            <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmTask.tab.main.label"/></a>
            </li>
            <li><a href="#attender" data-toggle="tab"><g:message
                    code="crmTask.tab.attender.label"/><crm:countIndicator
                    count="${crmTask.attenders.size()}"/></a>
            </li>
            <crm:pluginViews location="tabs" var="view">
                <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
            </crm:pluginViews>
        </ul>

        <div class="tab-content">
            <div class="tab-pane active" id="main">
                <div class="row-fluid">
                    <div class="span4">
                        <dl>

                            <g:if test="${crmTask.number}">
                                <dt><g:message code="crmTask.number.label" default="Number"/></dt>
                                <dd><g:fieldValue bean="${crmTask}" field="number"/></dd>
                            </g:if>

                            <dt><g:message code="crmTask.name.label" default="Name"/></dt>
                            <dd><g:fieldValue bean="${crmTask}" field="name"/></dd>

                            <g:if test="${crmTask.location}">
                                <dt><g:message code="crmTask.location.label" default="Location"/></dt>
                                <dd><g:fieldValue bean="${crmTask}" field="location"/></dd>
                            </g:if>

                        </dl>
                    </div>

                    <div class="span4">
                        <dl>

                            <g:if test="${crmTask.startTime}">
                                <dt><g:message code="crmTask.startTime.label" default="Starts"/></dt>
                                <dd><g:formatDate date="${crmTask.startTime}" type="datetime"/></dd>
                            </g:if>
                            <g:if test="${crmTask.endTime}">
                                <dt><g:message code="crmTask.endTime.label" default="Ends"/></dt>
                                <dd><g:formatDate date="${crmTask.endTime}" type="datetime"/></dd>
                            </g:if>
                            <g:if test="${crmTask.displayDate}">
                                <dt><g:message code="crmTask.displayDate.label" default="Display Date"/></dt>
                                <dd><g:fieldValue bean="${crmTask}" field="displayDate"/></dd>
                            </g:if>
                            <g:if test="${crmTask.isRecurring}">
                                <dt><g:message code="crmTask.isRecurring.label" default="Repeats"/></dt>
                                <dd>Repeats every ${crmTask.recurInterval}</dd>
                            </g:if>
                            <g:if test="${crmTask.alarmType != CrmTask.ALARM_NONE}">
                                <dt><g:message code="crmTask.alarm.label" default="Reminder"/></dt>
                                <dd>
                                    <g:message code="crmTask.alarmType.${crmTask.alarmType}"/>
                                    <g:message code="crmTask.alarmOffset.${crmTask.alarmOffset}"/>
                                </dd>
                            </g:if>

                        </dl>
                    </div>

                    <div class="span4">
                        <dl>

                            <g:if test="${crmTask.type}">
                                <dt><g:message code="crmTask.type.label" default="Type"/></dt>
                                <dd><g:fieldValue bean="${crmTask}" field="type"/></dd>
                            </g:if>

                            <dt><g:message code="crmTask.complete.label" default="Status"/></dt>
                            <dd>${message(code: 'crmTask.complete.' + crmTask.complete + '.label', default: crmTask.complete.toString())}</dd>

                            <dt><g:message code="crmTask.priority.label" default="Priority"/></dt>
                            <dd>${message(code: 'crmTask.priority.' + crmTask.priority + '.label', default: crmTask.priority.toString())}</dd>

                            <g:if test="${crmTask.ref}">
                                <dt><g:message code="crmTask.reference.label" default="Reference"/></dt>
                                <dd><crm:referenceLink reference="${crmTask.reference}"/></dd>
                            </g:if>

                            <g:if test="${crmTask.username}">
                                <dt><g:message code="crmTask.username.label" default="Responsible"/></dt>
                                <dd><crm:user username="${crmTask.username}">${name}</crm:user></dd>
                            </g:if>

                        </dl>
                    </div>

                </div>

                <g:if test="${crmTask.description}">
                    <div class="row-fluid">
                        <div class="span7">
                            <dl style="margin-top: 0;">
                                <dt><g:message code="crmTask.description.label" default="Description"/></dt>
                                <dd><g:decorate encode="HTML">${crmTask.description}</g:decorate></dd>
                            </dl>
                        </div>
                    </div>
                </g:if>

                <g:form>
                    <g:hiddenField name="id" value="${crmTask.id}"/>
                    <div class="form-actions btn-toolbar">

                        <crm:button type="link" group="true" action="edit" id="${crmTask.id}" visual="primary"
                                    icon="icon-pencil icon-white"
                                    label="crmTask.button.edit.label" permission="crmTask:edit">
                            <g:unless test="${crmTask.completed}">
                                <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                                    <span class="caret"></span>
                                </button>
                                <ul class="dropdown-menu">

                                    <crm:hasPermission permission="crmTask:edit">
                                        <crm:user>
                                            <g:if test="${crmTask.isUserTagged('favorite', username)}">
                                                <li>
                                                    <g:link action="deleteFavorite" id="${crmTask.id}"
                                                            title="${message(code: 'crmTask.button.favorite.delete.help', args: [crmTask])}">
                                                        <g:message
                                                                code="crmTask.button.favorite.delete.label"/></g:link>
                                                </li>
                                            </g:if>
                                            <g:else>
                                                <li>
                                                    <g:link action="createFavorite" id="${crmTask.id}"
                                                            title="${message(code: 'crmTask.button.favorite.create.help', args: [crmTask])}">
                                                        <g:message
                                                                code="crmTask.button.favorite.create.label"/></g:link>
                                                </li>
                                            </g:else>
                                        </crm:user>
                                    </crm:hasPermission>

                                    <li>
                                        <g:link action="completed" id="${crmTask.id}">
                                            <g:message code="crmTask.button.completed.label"
                                                       default="Set status to completed"/>
                                        </g:link>
                                    </li>
                                </ul>
                            </g:unless>
                        </crm:button>

                        <crm:button type="link" group="true" action="create"
                                    params="${['type.id': crmTask.type?.id, ref: crmTask.ref]}" visual="success"
                                    icon="icon-file icon-white"
                                    label="crmTask.button.create.label"
                                    title="crmTask.button.create.help"
                                    permission="crmTask:create"/>

                    </div>

                    <crm:timestamp bean="${crmTask}"/>
                </g:form>

            </div>

            <div class="tab-pane" id="attender">
                <g:render template="attenders"
                          model="${[bean: crmTask, list: crmTask.attenders, statusList: statusList]}"/>
            </div>

            <crm:pluginViews location="tabs" var="view">
                <div class="tab-pane tab-${view.id}" id="${view.id}">
                    <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
                </div>
            </crm:pluginViews>

        </div>
    </div>

</div>

<div class="span3">
    <div class="alert alert-info">
        <h4><g:message code="crmTask.summary.title" default="Summary"/></h4>
        <g:render template="summary" model="${[bean: crmTask]}"/>
    </div>

    <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTask]}"/>

    <g:if test="${crmTask.attenders}">
        <div class="well">
            <ul class="nav nav-list">
                <li class="nav-header">
                    <i class="icon-thumbs-up"></i>
                    Senast anmälda
                </li>
                <g:each in="${crmTask.attenders}" var="a" status="i">
                    <g:if test="${i < 5}">
                        <li>
                            <g:link controller="crmContact" action="show" id="${a.contact.id}">
                                <g:formatDate format="d MMM" date="${a.bookingDate}"/>
                                ${a.encodeAsHTML()}
                            </g:link>
                        </li>
                    </g:if>
                </g:each>
            </ul>
        </div>
    </g:if>
</div>
</div>

</body>
</html>
