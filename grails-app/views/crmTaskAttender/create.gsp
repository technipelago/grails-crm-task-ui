<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskAttender.label', default: 'Attender')}"/>
    <title><g:message code="crmTaskAttender.create.title" args="[entityName, crmTaskAttender]"/></title>
    <r:require modules="datepicker,autocomplete"/>

    <r:script>
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
                language: "${(org.springframework.web.servlet.support.RequestContextUtils.getLocale(request) ?: Locale.getDefault()).getLanguage()}",
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
                setCompanyIndicator('icon-share-alt');
            } else if($("input[name='companyName']").val()) {
                setCompanyIndicator('icon-leaf');
            }
            if($("input[name='contactId']").val()) {
                setPersonIndicator('icon-share-alt');
            } else if($("input[name='firstName']").val()) {
                setPersonIndicator('icon-leaf');
            }
        }

        $(document).ready(function () {
            bindPanelEvents($('#createForm'));

            $('a.crm-booking').hover(function(ev) {
                var id = $(this).data('crm-id');
                if(id != undefined) {
                    $('tr.crm-attender').filter(function() {
                        var myid = $(this).data("crm-booking");
                        return myid == id;
                    }).addClass('selected');
                }
            }, function(ev) {
                $('tr.crm-attender').removeClass('selected');
            });
        });
    </r:script>

    <style type="text/css">
    .crm-status-confirmed td,
    .crm-status-attended td,
    .crm-status-confirmed h1,
    .crm-status-attended h1 {
        color: #009900;
        background-color: #eeffee !important;
    }
    .crm-status-cancelled td,
    .crm-status-cancelled h1 {
        color: #f89406;
        background-color: #eeeeff !important;
    }
    .crm-status-absent td,
    .crm-status-absent h1 {
        color: #9d261d;
        background-color: #ffeeee !important;
    }
    tr.selected td {
        background-color: #f9ccff !important;
    }
    tr.crm-attender i {
        margin-left: 5px;
    }
    </style>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header">
            <crm:user>
                <h1>
                    <g:message code="crmTaskAttender.create.title" args="[entityName, crmTaskAttender]"/>
                    <small>${crmTask}</small>
                </h1>
            </crm:user>
        </header>

        <g:hasErrors bean="${crmTaskAttender}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmTaskAttender}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:set var="contact" value="${crmTaskAttender.contactInformation}"/>

        <g:form action="create" name="createForm">
            <input type="hidden" name="id" value="${crmTask.id}"/>

            <div class="row-fluid">

                <div class="span6">

                    <div class="row-fluid">

                        <div class="control-group">
                            <label id="crm-company-label" class="control-label"><g:message code="crmTaskAttender.company.label" /><span></span></label>

                            <div class="controls">
                                <g:textField name="companyName" value="${contact.companyName}" class="span11" autofocus=""
                                             placeholder="${message(code: 'crmTaskAttender.company.help')}" autocomplete="off"/>
                                <input type="hidden" name="companyId" value="${contact?.companyId}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label id="crm-person-label" class="control-label"><g:message code="crmTaskAttender.person.label" /><span></span></label>

                            <div class="controls">
                                <g:textField name="firstName" value="${contact.firstName}" class="span5" placeholder="${message(code: 'crmContact.firstName.help')}"/>
                                <g:textField name="lastName" value="${contact.lastName}" class="span6" placeholder="${message(code: 'crmContact.lastName.help')}"/>
                                <input type="hidden" name="contactId" value="${crmTaskAttender.contactId}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmContact.title.label" /></label>

                            <div class="controls">
                                <g:textField name="title" value="${contact.title}" class="span11" placeholder="${message(code: 'crmContact.title.help')}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.telephone.label" /></label>

                            <div class="controls">
                                <g:textField name="telephone" value="${contact.telephone}" class="span11"
                                             placeholder="${message(code: 'crmTaskAttender.telephone.help')}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.email.label" /></label>

                            <div class="controls">
                                <g:textField name="email" value="${contact.email}" class="span11"
                                             placeholder="${message(code: 'crmTaskAttender.email.help')}"/>
                            </div>
                        </div>

                        <tmpl:address bean="${contact}" disabled="false"/>

                    </div>
                </div>

                <div class="span6">
                    <div class="row-fluid">

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.status.label" /></label>

                            <div class="controls">
                                <g:select from="${statusList}" name="status.id" optionKey="id" value="${crmTaskAttender.status?.id}"
                                          class="span11"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.booking.label" /></label>

                            <div class="controls">
                                <g:select name="booking.id" from="${bookingList}" optionKey="id" optionValue="title"
                                      value="${crmTaskAttender.bookingId}" class="span11"
                                      noSelection="['0': message(code: 'crmTaskAttender.new.booking.label')]"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.bookingRef.label" /></label>

                            <div class="controls">
                                <g:textField name="bookingRef" value="${crmTaskAttender.bookingRef}" class="span11"
                                             placeholder="${message(code: 'crmTaskAttender.bookingRef.help')}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.bookingDate.label" /></label>

                            <div class="controls">
                                <div class="input-append date">
                                    <g:textField name="bookingDate" class="span9" size="10"
                                                 value="${formatDate(type: 'date', date: crmTaskAttender.bookingDate ?: new Date())}"/><span
                                        class="add-on"><i class="icon-th"></i></span>
                                </div>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.source.label" /></label>

                            <div class="controls">
                                <g:textField name="source" value="${crmTaskAttender.source}" class="span6"
                                             placeholder="${message(code: 'crmTaskAttender.source.help')}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.externalRef.label" /></label>

                            <div class="controls">
                                <g:textField name="externalRef" value="${crmTaskAttender.externalRef}" class="span6"
                                             placeholder="${message(code: 'crmTaskAttender.externalRef.help')}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.notes.label" /></label>

                            <div class="controls">
                                <g:textArea name="notes" value="${crmTaskAttender.description}" rows="6" class="span11"
                                            placeholder="${message(code: 'crmTaskAttender.notes.help')}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <div class="controls">
                                <label class="checkbox">
                                    <g:checkBox name="hide" value="true" checked="${crmTaskAttender.hide}"/>
                                    <g:message code="crmTaskAttender.hidden.label" />
                                </label>
                            </div>
                        </div>

                        <div class="control-group">
                            <div class="controls">
                                <label class="checkbox">
                                    <g:checkBox name="createContact" value="true" checked="${crmTaskAttender.contact != null}"/>
                                    <g:message code="crmTaskAttender.save.contact.label" />
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <crm:button action="create" visual="success" icon="icon-ok icon-white"
                            label="crmTaskAttender.button.save.label"/>
                <g:link controller="crmTask" action="show" id="${crmTask.id}" fragment="attender" class="btn">
                    <i class="icon-remove"></i>
                    <g:message code="crmAttender.button.cancel.label" default="Cancel"/>
                </g:link>
            </div>

        </g:form>
    </div>

    <div class="span3">

    </div>

</div>

</body>
</html>