<r:script>
    function cancelAttender() {
        $("#attender-panel").slideUp('fast', function () {
            $("#std-actions").slideDown();
        });
        return false;
    }

    function bindPanelEvents(panel) {
        $('.date', panel).datepicker({weekStart:1});

        $("input[name='contact.name']").autocomplete("${createLink(action: 'autocompleteContact')}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            selectFirst: true,
            onItemSelect: function(item) {
                var id = item.data[0];
                $("input[name='contact.id']").val(id);
            },
            onNoMatch: function() {
                $("input[name='contact.id']").val('');
            }
        });
    }

    function updateAttenders(property, value) {
        if(property == 'status') {
            var $form = $("#attender-change-form");
            $("input[name='status']", $form).val(value);
            $form.submit();
        }
        return false;
    }

    $(document).ready(function () {
        $("a.link-edit").click(function (ev) {
    <% if (crm.hasPermission(permission: 'crmTask:edit', { true })) { %>
    var $elem = $(this);
    ev.preventDefault();
    $("#attender-panel").load("${createLink(action: 'attender', params: [task: crmTask.id])}&id=" + $elem.data('crm-id'), function(data) {
                var $panel = $(this);
                bindPanelEvents($panel);
                $("#std-actions").slideUp('fast', function () {
                    $panel.slideDown(function () {
                        $(":input:visible:first", $panel).focus();
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
    $("#attender-panel").load("${createLink(action: 'attender', params: [task: crmTask.id])}", function(data) {
                var $panel = $(this);
                bindPanelEvents($panel);
                $("#std-actions").slideUp('fast', function () {
                    $panel.slideDown(function () {
                        $(":input:visible:first", $panel).focus();
                    });
                });
            });
    <% } %>
    return false;
    });

    $("#changeAll").click(function (event) {
        $(":checkbox[name='attenders']", $(this).closest('form')).prop('checked', $(this).is(':checked'));
    });
});
</r:script>

<g:form name="attender-change-form" action="updateAttenders">

    <g:hiddenField name="task" value="${crmTask?.id}"/>
    <g:hiddenField name="status" value=""/>

    <table class="table table-striped">
        <thead>
        <tr>
            <crm:sortableColumn property="name"
                                title="${message(code: 'crmContact.name.label', default: 'Name')}"/>
            <th><g:message code="crmContact.address.label"/></th>
            <crm:sortableColumn property="status"
                                title="${message(code: 'crmTaskAttender.status.label', default: 'Status')}"/>
            <th><g:checkBox name="changeAll" title="Markera alla"/></th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${list}" var="m">
            <tr>

                <td>
                    <g:link controller="crmContact" action="show" id="${m.contact.id}"
                            class="link-edit" data-crm-id="${m.id}">
                        ${fieldValue(bean: m.contact, field: "fullName")}
                    </g:link>
                </td>

                <td>
                    ${m.contact.address?.encodeAsHTML()}
                </td>

                <td title="${m.notes?.encodeAsHTML()}">
                    <g:fieldValue bean="${m}" field="status"/>
                    <g:if test="${m.notes}">
                        <i class="icon-comment"></i>
                    </g:if>
                </td>
                <td>
                    <input type="checkbox" name="attenders" value="${m.id}"/>
                </td>
            </tr>
        </g:each>
        </tbody>
    </table>
</g:form>

<crm:hasPermission permission="crmTask:edit">

    <div id="attender-panel" class="well hide"></div>

</crm:hasPermission>

<div id="std-actions" class="form-actions">
    <g:form>
        <g:hiddenField name="id" value="${crmTask?.id}"/>

        <crm:hasPermission permission="crmTask:edit">
            <a href="#attender-create" role="button" class="btn btn-success">
                <i class="icon-user icon-white"></i>
                <g:message code="crmTask.button.book.label"/>
            </a>
        </crm:hasPermission>

        <g:if test="${list}">
            <div class="btn-group">
                <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown"
                        title="${message(code: 'crmTaskAttender.button.bulkchange.help')}">
                    <g:message code="crmTaskAttender.button.bulkchange.label" default="Change Selected"/>
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <crm:hasPermission permission="crmTask:edit">
                        <g:each in="${statusList}" var="status">
                            <li>
                                <a href="javascript:void(0)"
                                   onclick="updateAttenders('status', ${status.id})">${status.encodeAsHTML()}</a>
                            </li>
                        </g:each>
                    </crm:hasPermission>
                </ul>
            </div>
        </g:if>

    </g:form>
</div>