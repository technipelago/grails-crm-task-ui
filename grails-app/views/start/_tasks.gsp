<ul>
    %{--
  - Copyright (c) 2013 Goran Ehrsson.
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  --}%

<g:each in="${result}" var="crmTask">
        <li>
            <g:link controller="crmTask" action="show" id="${crmTask.id}">
                <g:formatDate type="date" date="${crmTask.startTime}"/>
                ${fieldValue(bean: crmTask, field: "name")}
                ${fieldValue(bean: crmTask, field: "reference")}
            </g:link>
        </li>
    </g:each>
</ul>