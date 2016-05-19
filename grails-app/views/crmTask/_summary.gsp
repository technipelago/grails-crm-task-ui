<%@ page import="org.apache.commons.lang.StringUtils" defaultCodec="html" %>
<g:set var="contact" value="${bean.contact}"/>

<h4>${bean.name}</h4>

<p>
    ${message(code: 'crmTask.complete.' + bean.complete + '.label', default: '')}
    ${bean.type}
    <strong><g:formatDate date="${bean.startTime}" type="date" style="long"/></strong>

    <g:if test="${bean.location}">
        <g:message code="crmTask.summary.at" default="at"/> <strong>${bean.location}</strong>.
    </g:if>
</p>

<g:if test="${contact}">
    <p><strong>${contact.fullName}</strong></p>
</g:if>

<g:if test="${bean.description}">
    <p>${StringUtils.abbreviate(bean.description, 150)}</p>
</g:if>

<g:if test="${!contact && bean.attenders}">
    <p>
        <g:message code="crmTask.attenders.count" args="${[bean.toString(), bean.attenders.size()]}"/>.
    </p>
</g:if>
