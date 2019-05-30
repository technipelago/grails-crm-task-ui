<r:script>
    var searchDelay = (function(){
      var timer = 0;
      return function(callback, ms){
        clearTimeout (timer);
        timer = setTimeout(callback, ms);
      };
    })();
    var ATTENDERS = {
        status: '${attenderStatus}',
        tag: '${attenderTag}',
        sort: '${attenderSort}',
        order: 'asc',
        offset: 0,
        max: 25,
        load: function() {
            var params = {};
            params.q = $('#attender-container .crm-search input').val();
            params.status = ATTENDERS.status;
            params.tag = ATTENDERS.tag;
            params.sort = ATTENDERS.sort;
            params.order = ATTENDERS.order;
            params.offset = ATTENDERS.offset;
            params.max = ATTENDERS.max;
            $('#attender-container tbody').load("${createLink(action: 'attenders', id: bean.id)}", params, function() {
                $('#attender-container tbody .crm-attender').hover(function(ev) {
                    var id = $(this).data('crm-booking');
                    if(id != undefined) {
                        $('tr.crm-attender').filter(function() {
                            var myid = $(this).data("crm-booking");
                            return myid == id;
                        }).addClass('selected');
                    }
                }, function(ev) {
                    $('tr.crm-attender').removeClass('selected');
                });
                var $firstRow = $('#attender-container tbody .crm-attender').first();
                if($firstRow) {
                    var totalCount = $firstRow.data('crm-total');
                    if(!totalCount || (totalCount <= ATTENDERS.max)) {
                        $('#pagination').empty();
                        return; // No records found, nothing to paginate.
                    }
                    var offset = $firstRow.data('crm-offset');
                    var max = $firstRow.data('crm-max');
                    var pages = Math.ceil(totalCount / max);
                    var $ul = $('<ul/>');

                    // Prev button.
                    var $li = $('<li><a href="#">&laquo;</a></li>');
                    if(offset <= 0) {
                        $li.addClass('disabled');
                    } else {
                        $('a', $li).click(function(ev) {
                            ev.preventDefault();
                            $(this).html($('#spinner').clone());
                            ATTENDERS.offset = ATTENDERS.offset - ATTENDERS.max;
                            ATTENDERS.load();
                        });
                    }
                    $ul.append($li);

                    for(page = 0; page < pages; page++) {
                        var $a = $('<a href="#"/>');
                        $a.text(page + 1);
                        $a.data('crm-offset', page * ATTENDERS.max);
                        $li = $('<li/>');
                        $li.append($a);
                        $a.click(function(ev) {
                            ev.preventDefault();
                            $(this).html($('#spinner').clone());
                            ATTENDERS.offset = $(this).data('crm-offset');
                            ATTENDERS.load();
                        });
                        if((page * ATTENDERS.max) == ATTENDERS.offset) {
                            $li.addClass('active');
                        }
                        $ul.append($li);
                    }

                    // Next button.
                    $li = $('<li><a href="#">&raquo;</a></li>');
                    if(offset >= ((pages - 1) * ATTENDERS.max)) {
                        $li.addClass('disabled');
                    } else {
                        $('a', $li).click(function(ev) {
                            ev.preventDefault();
                            $(this).html($('#spinner').clone());
                            ATTENDERS.offset = ATTENDERS.offset + ATTENDERS.max;
                            ATTENDERS.load();
                        });
                    }
                    $ul.append($li);

                    $('#pagination').html($ul);
                }
            });
        },
        update: function(property, value) {
            if(property == 'status') {
                var $form = $("#attender-change-form");
                $("input[name='status']", $form).val(value);
                $form.submit();
            }
            return false;
        },
        delete: function() {
            if(confirm("${message(code: 'crmTask.button.delete.confirm.message')}")) {
                var $form = $("#attender-change-form");
                $("input[name='delete']", $form).val('true');
                $form.submit();
            }
            return false;
        }
    };

    $(document).ready(function () {

        $('#changeAll').click(function (event) {
            $(":checkbox[name='attenders']", $(this).closest('form')).prop('checked', $(this).is(':checked'));
        });

        $('#attender-container .crm-search').click(function(ev) {
            var $self = $(this);
            $self.find('label').hide();
            $self.find('input').removeClass('hide');
            $self.find('input').focus();
        });

        $('#attender-container .crm-search input').keyup(function() {
            searchDelay(function(){
                ATTENDERS.offset = 0;
                ATTENDERS.load();
            }, 750 );
        });

        $('#attender-container .crm-search input').keydown(function(event){
            if(event.keyCode == 13) {
                event.preventDefault();
                return false;
            }
        });

        $('#attender-container .crm-sort').click(function(ev) {
            var $self = $(this);
            var sort = $self.data('crm-sort');
            if(sort == ATTENDERS.sort) {
                if(ATTENDERS.order == 'asc') {
                    ATTENDERS.order = 'desc';
                } else {
                    ATTENDERS.order = 'asc';
                }
            } else {
                ATTENDERS.order = 'asc';
            }
            ATTENDERS.sort = sort;
            ATTENDERS.load();
        });

        ATTENDERS.load();
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

tr.selected td {
    background-color: #f9ccff !important;
}

tr.crm-attender i {
    margin-right: 5px;
}

tr.crm-attender i:last-child {
    margin-right: 0;
}

.crm-search input {
    margin-bottom: 0;
    padding: 1px 4px;
}

.crm-search input.hide {
    display: none !important;
}
</style>

<div id="attender-container">
    <g:form name="attender-change-form" action="updateAttenders">

        <g:hiddenField name="task" value="${bean.id}"/>
        <g:hiddenField name="status" value=""/>
        <g:hiddenField name="delete" value=""/>

        <table class="table table-striped">
            <thead>
            <tr>
                <th>
                    <a href="javascript:void(0);" class="crm-sort" data-crm-id="${bean.id}" data-crm-sort="booking.bookingRef"
                       data-crm-order="asc">#</a>
                </th>
                <th class="crm-search">
                    <label>
                        <g:message code="crmContact.name.label" default="Name"/>
                        <i class="icon-search"></i>
                    </label>
                    <input type="text" name="q" maxlength="80" class="hide"/>
                </th>
                <th><g:message code="crmContact.company.label"/></th>
                <th colspan="2">
                    <a href="javascript:void(0);" class="crm-sort" data-crm-id="${bean.id}"
                       data-crm-sort="status.orderIndex" data-crm-order="asc">
                        <g:message code="crmTaskAttender.status.label"/>
                    </a>
                </th>
                <th><g:checkBox name="changeAll"
                                title="${message(code: 'crmTaskAttender.button.select.all.label', default: 'Select all')}"/></th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td colspan="6">
                    <g:img dir="images" file="spinner.gif" alt="Loading..."/>
                </td>
            </tr>
            </tbody>
        </table>
    </g:form>

    <div id="pagination" class="pagination${count > 500 ? ' pagination-mini' : ''}"></div>

    <div id="std-actions" class="form-actions">
        <g:form>
            <g:hiddenField name="id" value="${bean.id}"/>

            <crm:hasPermission permission="crmTask:edit">

                <crm:button type="link" group="true" controller="crmTaskAttender" action="create" id="${bean.id}" visual="success"
                            icon="icon-user icon-white" label="crmTask.button.book.label" accesskey="n">

                    <g:if test="${bean.sourceTask}">
                        <button class="btn btn-success dropdown-toggle" data-toggle="dropdown">
                            <span class="caret"></span>
                        </button>

                        <ul class="dropdown-menu">
                            <li>
                                <g:link controller="crmTask" action="subTask" id="${crmTask.id}">
                                    <g:message code="crmTask.button.subTask.label"/>
                                </g:link>
                            </li>
                        </ul>
                    </g:if>

                </crm:button>
            </crm:hasPermission>

            <g:if test="${count}">
                <crm:hasPermission permission="crmTask:edit">
                    <div class="btn-group">
                        <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown"
                                title="${message(code: 'crmTaskAttender.button.bulkchange.help')}">
                            <g:message code="crmTaskAttender.button.bulkchange.label" default="Change Selected"/>
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <g:each in="${statusList}" var="status">
                                <li>
                                    <a href="javascript:void(0)"
                                       onclick="ATTENDERS.update('status', ${status.id})">${status.encodeAsHTML()}</a>
                                </li>
                            </g:each>
                        </ul>
                    </div>

                    <g:if test="${bean.sourceTask}">
                        <crm:button type="url" href="javascript:void(0)" onclick="ATTENDERS.delete()"
                                    visual="danger" icon="icon-trash icon-white" label="crmTask.button.delete.label"
                                    permission="crmTask:delete"
                        />
                    </g:if>

                </crm:hasPermission>

                <div class="btn-group">
                    <select:link action="export" params="${[ns: 'crmTaskAttender']}" class="btn btn-info"
                                 selection="${new URI('bean://crmTaskService/list?id=' + bean.id)}">
                        <i class="icon-print icon-white"></i>
                        <g:message code="crmTaskAttender.button.print.label" default="Print"/>
                    </select:link>
                </div>
            </g:if>

            <g:if test="${count}">
                <div class="btn-group">
                    <select:link action="export" params="${[ns: 'crmTaskAttender']}" class="btn btn-info"
                                 selection="${new URI('bean://crmTaskService/list?id=' + bean.id)}">
                        <i class="icon-print icon-white"></i>
                        <g:message code="crmTaskAttender.button.print.label" default="Print"/>
                    </select:link>
                </div>
            </g:if>

            <crm:hasPermission permission="crmTaskAttender:archive">
                <g:link controller="crmTaskAttender" action="archive" id="${crmTask.id}" style="margin-left: 12px; color: #990000;">
                    <g:message code="crmTaskAttender.archive.label" default="Archive"/>
                </g:link>
            </crm:hasPermission>
        </g:form>
    </div>
</div>

<div class="hidden">
    <g:img dir="images" file="spinner.gif" alt="Loading..." id="spinner"/>
</div>
