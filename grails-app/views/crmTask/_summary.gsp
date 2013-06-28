<%@ page import="org.apache.commons.lang.StringUtils" defaultCodec="html" %>
<h4>${bean.name}</h4>

<p>
    ${bean.type}
    <strong><g:formatDate date="${bean.startTime}" type="date" style="long"/></strong>

    <g:if test="${bean.location}">
        vid <strong>${bean.location}</strong>.
    </g:if>
</p>

<g:if test="${bean.description}">
    <p>${StringUtils.abbreviate(bean.description, 150)}</p>
</g:if>

<g:if test="${bean.attenders}">
    <p><strong>${bean.attenders.size()} st</strong> deltagare är anmälda.</p>
</g:if>
