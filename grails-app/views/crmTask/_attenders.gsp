<r:script>
    function cancelAttender() {
        $("#attender-panel").slideUp('fast', function () {
            $("#std-actions").slideDown();
        });
        return false;
    }

    function setCompanyIndicator(icon) {
        if(icon) {
            $("#crm-company-label > span").html(' <i class="' + icon + '"></i>');
        } else {
            $("#crm-company-label > span").empty();
        }
    }

    function setPersonIndicator(icon) {
        if(icon) {
            $("#crm-person-label > span").html(' <i class="' + icon + '"></i>');
        } else {
            $("#crm-person-label > span").empty();
        }
    }

    function bindPanelEvents(panel) {
        $('.date', panel).datepicker({
            weekStart:1,
            language: "${(org.springframework.web.servlet.support.RequestContextUtils.getLocale(request) ?: new Locale('sv_SE')).getLanguage()}",
            calendarWeeks: ${grailsApplication.config.crm.datepicker.calendarWeeks ?: false},
            todayHighlight: true,
            autoclose: true
        });

        $("#crm-company-label").click(function(ev) {
            ev.preventDefault();
            var companyId = $("input[name='companyId']").val();
            if(companyId) {
                window.location.href = "${createLink(mapping: 'crm-contact-show')}/" + companyId;
            }
        });

        $("#crm-person-label").click(function(ev) {
            ev.preventDefault();
            var contactId = $("input[name='contactId']").val();
            if(contactId) {
                window.location.href = "${createLink(mapping: 'crm-contact-show')}/" + contactId;
            }
        });

        $("input[name='companyName']").autocomplete("${createLink(controller: 'crmTask', action: 'autocompleteContact', params: [company: true])}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            selectFirst: true,
            useCache: false,
            filter: false,
            queryParamName: 'name',
            extraParams: {},
            onItemSelect: function(item) {
                var ac = $("input[name='firstName']").data('autocompleter');
                if(ac) {
                    ac.setExtraParam('related', item.data[0]);
                    ac.cacheFlush();
                    }
                ac = $("input[name='lastName']").data('autocompleter');
                if(ac) {
                    ac.setExtraParam('related', item.data[0]);
                    ac.cacheFlush();
                }
                $("input[name='companyId']").val(item.data[0]);
                $("input[name='contactId']").val('');
                $("input[name='firstName']").val('');
                $("input[name='lastName']").val('');
                $("input[name='address']").val(item.data[5]);
                $("input[name='telephone']").val(item.data[6]);
                $("input[name='email']").val(item.data[7]);
                setCompanyIndicator('');
            },
            onNoMatch: function() {
                var ac = $("input[name='firstName']").data('autocompleter');
                if(ac) {
                    ac.setExtraParam('related', '');
                    ac.cacheFlush();
                }
                ac = $("input[name='lastName']").data('autocompleter');
                if(ac) {
                    ac.setExtraParam('related', '');
                    ac.cacheFlush();
                }
                $("input[name='companyId']").val('');
                setCompanyIndicator('icon-leaf');
            }
        });

        $("input[name='firstName']").autocomplete("${createLink(controller: 'crmTask', action: 'autocompleteContact', params: [person: true])}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            minChars: 1,
            /*selectFirst: true,*/
            filter: false,
            useCache: false,
            queryParamName: 'firstName',
            extraParams: {},
            onItemSelect: function(item) {
                $("input[name='contactId']").val(item.data[0]);
                $("input[name='companyId']").val(item.data[1]);
                $("input[name='companyName']").val(item.data[2]);
                $("input[name='firstName']").val(item.data[3]);
                $("input[name='lastName']").val(item.data[4]);
                $("input[name='address']").val(item.data[5]);
                $("input[name='telephone']").val(item.data[6]);
                $("input[name='email']").val(item.data[7]);
                setPersonIndicator('');
            },
            onNoMatch: function() {
                $("input[name='contactId']").val('');
                setPersonIndicator('icon-leaf');
            }
        });

        $("input[name='lastName']").autocomplete("${createLink(controller: 'crmTask', action: 'autocompleteContact', params: [person: true])}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            minChars: 1,
            /*selectFirst: true,*/
            filter: false,
            useCache: false,
            queryParamName: 'lastName',
            extraParams: {},
            onItemSelect: function(item) {
                $("input[name='contactId']").val(item.data[0]);
                $("input[name='companyId']").val(item.data[1]);
                $("input[name='companyName']").val(item.data[2]);
                $("input[name='firstName']").val(item.data[3]);
                $("input[name='lastName']").val(item.data[4]);
                $("input[name='address']").val(item.data[5]);
                $("input[name='telephone']").val(item.data[6]);
                $("input[name='email']").val(item.data[7]);
                setPersonIndicator('');
            },
            onNoMatch: function() {
                $("input[name='contactId']").val('');
                setPersonIndicator('icon-leaf');
            }
        });

        if($("input[name='companyId']").val()) {
            setCompanyIndicator('');
        } else if($("input[name='companyName']").val()) {
            setCompanyIndicator('icon-leaf');
        }
        if($("input[name='contactId']").val()) {
            setPersonIndicator('');
        } else if($("input[name='firstName']").val()) {
            setPersonIndicator('icon-leaf');
        }
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
    $("#attender-panel").load("${createLink(controller: 'crmTask', action: 'attender', params: [task: crmTask.id])}&id=" + $elem.data('crm-id'), function(data) {
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
    $("#attender-panel").load("${createLink(controller: 'crmTask', action: 'attender', params: [task: crmTask.id])}", function(data) {
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

<style type="text/css">
tr.crm-status-confirmed td,
tr.crm-status-attended td {
    color: #009900;
    background-color: #eeffee !important;
}
tr.crm-status-cancelled td {
    color: #f89406;
    background-color: #eeeeff !important;
}
tr.crm-status-absent td {
    color: #9d261d;
    background-color: #ffeeee !important;
}
</style>

<g:form name="attender-change-form" action="updateAttenders">

    <g:hiddenField name="task" value="${crmTask?.id}"/>
    <g:hiddenField name="status" value=""/>
    <g:hiddenField name="sort" value="${params.sort}"/>
    <g:hiddenField name="order" value="${params.order}"/>

    <table class="table table-striped">
        <thead>
        <tr>
            <th><g:message code="crmContact.name.label" default="Name"/></th>
            <th><g:message code="crmContact.address.label"/></th>
            <crm:sortableColumn property="status.orderIndex" fragment="attender"
                                title="${message(code: 'crmTaskAttender.status.label', default: 'Status')}"/>
            <th><g:checkBox name="changeAll" title="${message(code: 'crmTaskAttender.button.select.all.label', default: 'Select all')}"/></th>
        </tr>
        </thead>
        <tbody>
        <g:each in="${list}" var="m">
            <g:set var="contactInfo" value="${m.contactInformation}"/>
            <tr class="crm-status-${m.status.param}">

                <td>
                    <g:if test="${m.contact}">
                        <g:link mapping="crm-contact-show" id="${m.contact.id}"
                                class="link-edit" data-crm-id="${m.id}">
                            ${fieldValue(bean: contactInfo, field: "fullName")}
                        </g:link>
                    </g:if>
                    <g:else>
                        <a href="#" class="link-edit" data-crm-id="${m.id}">
                            ${fieldValue(bean: contactInfo, field: "fullName")}
                        </a>
                        <i class="icon-leaf"></i>
                    </g:else>
                </td>

                <td class="${m.hide ? 'muted' : ''}">
                    ${contactInfo.address?.encodeAsHTML()}
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
            <a href="#attender-create" role="button" class="btn btn-success" accesskey="n">
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

            <div class="btn-group">
                <button class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                    <i class="icon-print icon-white"></i>
                    <g:message code="crmTaskAttender.button.print.label" default="Print"/>
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <li>
                        <select:link action="export" params="${[namespace:'crmTaskAttender']}"
                                     selection="${new URI('bean://crmTaskService/list?id=' + crmTask.id)}">
                            <g:message code="crmTask.print.attenders.label" default="Attender list"/>
                        </select:link>
                    </li>
                </ul>
            </div>
        </g:if>
    </g:form>
</div>
