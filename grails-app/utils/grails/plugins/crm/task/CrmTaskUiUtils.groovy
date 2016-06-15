/*
 * Copyright (c) 2016 Goran Ehrsson.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package grails.plugins.crm.task

import grails.plugins.crm.core.CrmContactInformation

/**
 * Created by goran on 2016-06-15.
 */
final class CrmTaskUiUtils {

    private CrmTaskUiUtils() {
    }

    private static final Comparator<CrmTaskAttender> ATTENDER_COMPARATOR = new Comparator<CrmTaskAttender>() {
        @Override
        int compare(CrmTaskAttender o1, CrmTaskAttender o2) {
            if (o1.booking.bookingRef != null) {
                int i = o1.booking.bookingRef.compareTo(o2.booking.bookingRef)
                if (i != 0) {
                    return i
                }
            }
            if (o1.externalRef != null) {
                int i = o1.externalRef.compareTo(o2.externalRef)
                if (i != 0) {
                    return i
                }
            }
            CrmContactInformation contact1 = o1.contactInformation
            CrmContactInformation contact2 = o2.contactInformation
            if (contact1.lastName != null) {
                int i = contact1.lastName.compareTo(contact2.lastName)
                if (i != 0) {
                    return i
                }
            }
            if (contact1.firstName != null) {
                int i = contact1.firstName.compareTo(contact2.firstName)
                if (i != 0) {
                    return i
                }
            }
            return o1.id.compareTo(o2.id)
        }
    }

    public static List<CrmTaskAttender> sortByExternalId(Collection<CrmTaskAttender> list) {
        list.sort(false, ATTENDER_COMPARATOR)
    }
}
