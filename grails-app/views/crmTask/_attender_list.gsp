<g:each in="${list}" var="m">
    <g:set var="contactInfo" value="${m.contactInformation}"/>
    <tr class="crm-status-${m.status.param} crm-attender"
        data-crm-booking="${m.bookingId ?: ''}" data-crm-total="${totalCount}"
        data-crm-offset="${params.offset ?: 0}" data-crm-max="${params.max ?: 25}">

        <td>
            <g:link controller="crmTaskBooking" action="show" id="${m.bookingId}" class="crm-booking">
                <g:if test="${m.booking.bookingRef}">
                    <g:fieldValue bean="${m.booking}" field="bookingRef"/>
                </g:if>
                <g:else>
                    <i class="icon-glass"></i>
                </g:else>
            </g:link>
        </td>

        <td>
            <g:link controller="crmTaskAttender" action="show" id="${m.id}">
                ${fieldValue(bean: contactInfo, field: "name")}
            </g:link>
        </td>

        <td class="${m.hide ? 'muted' : ''}">
            ${contactInfo.companyName?.encodeAsHTML()}
        </td>

        <td>
            <g:fieldValue bean="${m}" field="status"/>
        </td>

        <g:set var="tags" value="${m.getTagValue()}"/>
        <td style="width: 68px;text-align:right;">
            <g:if test="${m.description}">
                <i class="icon-comment" title="${m.description}"></i>
            </g:if>
            <g:if test="${tags}">
                <i class="icon-tags" title="${tags?.join(', ')}"></i>
            </g:if>
            <g:unless test="${m.contact}">
                <i class="icon-leaf"></i>
            </g:unless>
        </td>

        <td>
            <input type="checkbox" name="attenders" value="${m.id}"/>
        </td>
    </tr>
</g:each>