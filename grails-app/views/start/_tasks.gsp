<ul>
    <g:each in="${result}" var="crmTask">
        <li>
            <g:link controller="crmTask" action="show" id="${crmTask.id}">
                <g:formatDate date="${crmTask.startTime}" format="d MMM"/>
                ${fieldValue(bean: crmTask, field: "name")}
                <g:if test="${showReference}">
                    ${fieldValue(bean: crmTask, field: "reference")}
                </g:if>
            </g:link>
        </li>
    </g:each>
</ul>