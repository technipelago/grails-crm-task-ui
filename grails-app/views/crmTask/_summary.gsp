<%@ page import="grails.plugins.crm.core.DateUtils" defaultCodec="html" %>

<h4>${bean.type}</h4>

<h2>${bean.name}</h2>

<h3><g:formatDate date="${bean.startTime}" type="datetime" style="long"/></h3>

<g:if test="${bean.location}">
    <h3>${bean.location}</h3>
</g:if>

<p>
    ${bean.description}
</p>
