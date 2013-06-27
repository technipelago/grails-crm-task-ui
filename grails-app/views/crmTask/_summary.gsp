<%@ page import="grails.plugins.crm.core.DateUtils" defaultCodec="html" %>

<g:if test="${bean.attenders}">
    <p>${bean.attenders.size()} st deltagare är anmälda till</p>
</g:if>

<h4>${bean.name}</h4>

<p>
    ${bean.type}
    <strong><g:formatDate date="${bean.startTime}" type="date" style="long"/></strong>

    <g:if test="${bean.location}">
        vid <strong>${bean.location}</strong>.
    </g:if>
</p>

<g:if test="${bean.username}">
    <p><strong>${bean.username}</strong> är ansvarig.</p>
</g:if>