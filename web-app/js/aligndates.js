/*
 * Copyright (c) 2013 Goran Ehrsson.
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

function alignDates(input1, input2, reversed, dpSelector) {
    var date1 = input1.val();
    var date2 = input2.val();
    if (date1) {
        if (date2) {
            var d1 = new Date(Date.parse(date1));
            var d2 = new Date(Date.parse(date2));
            if ((d1 > d2 && !reversed) || (d1 < d2 && reversed)) {
                input2.val(d1.format("yyyy-mm-dd")); // TODO pick format from datepicker.
                input2.closest(dpSelector).data('date', input2.val());
                input2.closest(dpSelector).datepicker('update');
            }
        } else {
            input2.val(date1);
            input2.closest(dpSelector).data('date', input2.val());
            input2.closest(dpSelector).datepicker('update');
        }
    }
}