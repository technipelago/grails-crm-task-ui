<%@ page import="org.apache.shiro.SecurityUtils; grails.plugins.crm.task.CrmTask" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmTaskAttender.label', default: 'Attender')}"/>
    <title><g:message code="crmTaskAttender.edit.title" args="[entityName, crmTaskAttender]"/></title>
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
                    $("input[name='telephone']").val(item.data[5]);
                    $("input[name='email']").val(item.data[6]);
                    $("input[name='address1']").val(item.data[7]);
                    $("input[name='address2']").val(item.data[8]);
                    $("input[name='address3']").val(item.data[9]);
                    $("input[name='postalCode']").val(item.data[10]);
                    $("input[name='city']").val(item.data[11]);
                    $("input[name='country']").val(item.data[12]);
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
                    $("input[name='telephone']").val(item.data[5]);
                    $("input[name='email']").val(item.data[6]);
                    $("input[name='address1']").val(item.data[7]);
                    $("input[name='address2']").val(item.data[8]);
                    $("input[name='address3']").val(item.data[9]);
                    $("input[name='postalCode']").val(item.data[10]);
                    $("input[name='city']").val(item.data[11]);
                    $("input[name='country']").val(item.data[12]);
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
                    $("input[name='telephone']").val(item.data[5]);
                    $("input[name='email']").val(item.data[6]);
                    $("input[name='address1']").val(item.data[7]);
                    $("input[name='address2']").val(item.data[8]);
                    $("input[name='address3']").val(item.data[9]);
                    $("input[name='postalCode']").val(item.data[10]);
                    $("input[name='city']").val(item.data[11]);
                    $("input[name='country']").val(item.data[12]);
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
            bindPanelEvents($('#editForm'));
        });
    </r:script>

    <style type="text/css">
    .crm-status-confirmed, .crm-status-attended {
        color: #009900;
    }
    .crm-status-cancelled {
        color: #f89406;
    }
    .crm-status-absent {
        color: #9d261d;
    }
    </style>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header crm-status-${crmTaskAttender.status.param}">
            <crm:user>
                <h1>
                    ${crmTaskAttender}
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

        <g:form action="edit" name="editForm">
            <input type="hidden" name="id" value="${crmTaskAttender.id}"/>
            <input type="hidden" name="booking" value="${crmTaskAttender.bookingId}"/>
            <input type="hidden" name="task" value="${crmTaskAttender.booking.taskId}"/>

            <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active">
                    <a href="#main" data-toggle="tab"><g:message code="crmTaskAttender.tab.main.label"/></a>
                </li>
                <li>
                    <a href="#desc" data-toggle="tab"><g:message code="crmTaskAttender.tab.desc.label"/></a>
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

                        <div class="control-group">
                            <label id="crm-company-label" class="control-label"><g:message code="crmTaskAttender.company.label" /><span></span></label>

                            <div class="controls">
                                <g:textField name="companyName" value="${contact.companyName}" class="span11"
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
                                <g:textField name="title" value="${contact.title}" class="span11"
                                             placeholder="${message(code: 'crmContact.title.help')}" disabled="${crmTaskAttender.contact != null}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.telephone.label" /></label>

                            <div class="controls">
                                <g:textField name="telephone" value="${contact.telephone}" class="span11"
                                             placeholder="${message(code: 'crmTaskAttender.telephone.help')}" disabled="${crmTaskAttender.contact != null}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.email.label" /></label>

                            <div class="controls">
                                <g:textField name="email" value="${contact.email}" class="span11"
                                             placeholder="${message(code: 'crmTaskAttender.email.help')}" disabled="${crmTaskAttender.contact != null}"/>
                            </div>
                        </div>

                        <g:if test="${address}">
                            <tmpl:address bean="${address}" disabled="${crmTaskAttender.contact != null}"/>
                        </g:if>

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
                            <label class="control-label"><g:message code="crmTaskAttender.food.label" /></label>

                            <div class="controls">
                                <g:textArea name="food" value="${crmTaskAttender.food}" rows="2" class="span11"
                                            placeholder="${message(code: 'crmTaskAttender.food.help')}"/>
                            </div>
                        </div>

                        <div class="control-group">
                            <label class="control-label"><g:message code="crmTaskAttender.notes.label" /></label>

                            <div class="controls">
                                <g:textArea name="notes" value="${crmTaskAttender.description}" rows="7" class="span11"
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
            </div>

            <div class="tab-pane" id="desc">
                <div class="row-fluid">
                    <div class="control-group">
                        <label class="control-label"><g:message code="crmTaskAttender.bio.label" /></label>

                        <div class="controls">
                            <g:textArea name="bio" value="${crmTaskAttender.bio}" rows="12" cols="70"
                                        class="span11"/>
                        </div>
                        </div>
                </div>
            </div>

            </div>
            </div>

            <div class="form-actions">
                <crm:button action="edit" visual="warning" icon="icon-ok icon-white"
                            label="crmTaskAttender.button.save.label"/>
                <crm:button action="delete" visual="danger" label="crmTaskAttender.button.delete.label" icon="icon-trash icon-white"
                            confirm="${message(code: 'crmTaskAttender.button.delete.confirm')}"/>
                <g:link action="show" id="${crmTaskAttender.id}" class="btn">
                    <i class="icon-remove"></i>
                    <g:message code="crmAttender.button.cancel.label" default="Cancel"/>
                </g:link>
            </div>

        </g:form>
    </div>

    <div class="span3">
        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmTaskAttender]}"/>
    </div>

</div>

</body>
</html>
