<template>
  <div v-if="modelData">
    <div class="form-group">
      <label class="col-sm-2 control-label">
        Schedule to run repeatedly?
      </label>
      <div class="col-sm-10 ">
        <div class="radio radio-inline">
          <input id="scheduledFalse"
                 type="radio"
                 name="scheduled"
                 :value="false"
                 v-model="modelData.scheduled"/>
          <label for="scheduledFalse">
            {{ $t('no') }}
          </label>
        </div>
        <div class="radio radio-inline">
          <input type="radio"
                 name="scheduled"
                 :value="true"
                 v-model="modelData.scheduled"
                 id="scheduledTrue"/>
          <label for="scheduledTrue">
            {{ $t('yes') }}
          </label>
        </div>
      </div>
    </div>
    <div class="form-group" id="scheduledExecutionEditTZ">
    <template v-if="modelData.scheduled">
      <div class="form-group">
        <div class="col-sm-10 col-sm-offset-2">
          <div class="row">
            <div class="col-xs-12">
              <div class="base-filters">
                <div class="row">
                  <div class="col-xs-10">
                    <div class="vue-tabs"><div class="nav-tabs-navigation">
                      <ul class="nav nav-tabs ">
                        <li id="simpleLi" v-bind:class="{active: !modelData.useCrontabString}">
                          <a data-crontabstring="false"
                             href="#cronsimple"
                             @click="showSimpleCron"
                          >Simple</a>
                        </li>
                        <li id="cronLi" v-bind:class="{active: !!modelData.useCrontabString}">
                          <a data-crontabstring="true"
                             href="#cronstrtab"
                             @click="showCronExpression"
                          >Crontab</a>
                        </li>
                      </ul>
                    </div></div>
                  </div>
                  <div class="col-xs-10">
                    <div class="form-group">

                      <div id="cronsimple" v-if="!modelData.useCrontabString">
                        <div class="crontab tabtarget" >
                          <div class="panel-body">
                            <div class="col-sm-4 form-inline" id="hourTab">
                              <label for="hourNumber" aria-hidden="false" style="display: none;">Hour</label>
                              <select
                                id="hourNumber"
                                name="hour"
                                v-model="modelData.hourSelected"
                                class="form-control"
                                style="width:auto;"
                              >
                                <option v-for="hour in hours" :key="hour" v-bind:value="hour">{{hour}}</option>
                              </select>
                              :
                              <label for="minuteNumber" aria-hidden="false" style="display: none;">Minute</label>
                              <select
                                id="minuteNumber"
                                name="minute"
                                v-model="modelData.minuteSelected"
                                class="form-control"
                                style="width:auto;"
                              >
                                <option v-for="minute in minutes" :key="minute" v-bind:value="minute">{{minute}}</option>
                              </select>
                            </div>
                            <div class="col-sm-4">
                              <div class="checklist checkbox" id="DayOfWeekDialog">
                                <input
                                  id="everyDay"
                                  name="everyDay"
                                  type="checkbox"
                                  value="all"
                                  v-model="modelData.everyDayOfWeek"
                                >
                                <label for="everyDay">Every Day</label>
                                  <template v-if="!modelData.everyDayOfWeek">
                                <div class="_defaultInput checkbox" v-for="(day,n) in days">
                                  <input
                                    :id="'dayCheckbox_'+n"
                                    type="checkbox"
                                    :value="day.shortName"
                                    v-model="modelData.selectedDays"
                                  >
                                  <label :for="'dayCheckbox_'+n">{{day.name}}</label>
                                </div>
                                  </template>
                                <input type="hidden" name="selectedDaysOfWeek" :value="modelData.selectedDays.join(',')" >
                              </div>
                            </div>
                            <div class="col-sm-4">
                              <div class="checklist checkbox" id="MonthDialog">
                                <input
                                  id="everyMonth"
                                  name="everyMonth"
                                  type="checkbox"
                                  value="all"
                                  v-model="modelData.allMonths"
                                >
                                <label for="everyMonth">Every Month</label>
                                <template v-if="!modelData.allMonths">
                                <div class="_defaultInput checkbox" v-for="(month,n) in months">
                                  <input
                                    :id="'monthCheckbox_'+n"
                                    type="checkbox"
                                    :value="month.shortName"
                                    v-model="modelData.selectedMonths"
                                  >
                                  <label :for="'monthCheckbox_'+n">{{month.name}}</label>
                                </div>
                                </template>
                              </div>
                              <input type="hidden" name="selectedMonths" :value="modelData.selectedMonths.join(',')" >
                            </div>
                          </div>
                        </div>
                      </div>

                      <div id="cronstrtab" v-if="modelData.useCrontabString">
                        <div>
                          <div class="panel-body">
                            <div class="container">
                              <div class="row">
                                <div class="col-sm-6">
                                  <div class="form-group">
                                    <input
                                      ref="crontabInput"
                                      type="text"
                                      name="crontabString"
                                      autofocus="true"
                                      class="form-control input-sm"
                                      size="50"
                                      @click="updateCrontabPosition"
                                      @keyup="updateCrontabPosition"
                                      @change="validateCronExpression"
                                      @blur="crontabBlur"
                                      v-model="modelData.crontabString"
                                    >
                                    <input type="hidden" name="useCrontabString" v-model="modelData.useCrontabString">
                                  </div>
                                  <span class="text-muted" style="font-style: italic" v-if="crontabHint">{{crontabHint}}</span>
                                </div>
                                <div class="col-sm-6">
                                    <div v-html="errors">
                                    </div>
                                </div>
                              </div>
                              <div class="row">
                                <div class="text-strong col-sm-12">
                                  <div>
                                    <p>Ranges: <code>1-3</code>.  Lists: <code>1,4,6</code>. Increments: <code>0/15</code> "every 15 units starting at 0".</p>
                                    <p>Valid values of Day of Week: 1-7 or SUN-SAT</p>
                                    <p>Valid values of Month: 1-12 or JAN-DEC</p>
                                  </div>
                                  See: <a :href="$t('documentation.reference.cron.url')" class="external" target="_blank">Cron reference</a> for formatting help
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>


              </div>
            </div>
          </div>
        </div>
      </div>
      <!--------------------------->
      <div class="form-group">
        <div class="col-sm-2 control-label text-form-label">
          {{$t('scheduledExecution.property.timezone.prompt')}}
        </div>
        <div class="col-sm-5">
          <input
            type="text"
            name="timeZone"
            id="timeZone"
            autofocus="true"
            class="form-control input-sm"
            size="50"
            v-model="modelData.timeZone"
          >
          <typeahead  v-model="modelData.timeZone"  target="#timeZone" :data="modelData.timeZones"  />
          <span class="help-block">
            {{$t('scheduledExecution.property.timezone.description')}}
          </span>
        </div>
      </div>
    </template>
    </div>
    <ui-socket section="job-edit-schedules-editor" location="scheduledExecutionEditTZ:after" :event-bus="eventBus"/>
    <div class="form-group">
        <div class="col-sm-2 control-label text-form-label">
          {{ $t('scheduledExecution.property.scheduleEnabled.label') }}
        </div>

        <div class="col-sm-10">
          <div class="radio radio-inline">
            <input type="radio"
                   name="scheduleEnabled"
                   :value="true"
                   v-model="modelData.scheduleEnabled"
                   id="scheduleEnabledTrue"/>
            <label for="scheduleEnabledTrue">
              {{ $t('yes') }}
            </label>
          </div>
          <div class="radio radio-inline">
            <input type=radio
                   :value="false"
                   name="scheduleEnabled"
                   v-model="modelData.scheduleEnabled"
                   id="scheduleEnabledFalse"/>
            <label for="scheduleEnabledFalse">
              {{ $t('no') }}
            </label>
          </div>

          <span class="help-block">
                {{ $t('scheduledExecution.property.scheduleEnabled.description') }}
          </span>
        </div>
      </div>

      <div class="form-group">
        <div class="col-sm-2 control-label text-form-label">
          {{ $t('scheduledExecution.property.executionEnabled.label') }}
        </div>

        <div class="col-sm-10">
          <div class="radio radio-inline">
            <input type="radio"
                   name="executionEnabled"
                   :value="true"
                   v-model="modelData.executionEnabled"
                   id="executionEnabledTrue"/>
            <label for="executionEnabledTrue">
              {{ $t('yes') }}
            </label>
          </div>

          <div class="radio radio-inline">
            <input type=radio
                   :value="false"
                   name="executionEnabled"
                   v-model="modelData.executionEnabled"
                   id="executionEnabledFalse"/>
            <label for="executionEnabledFalse">
              {{ $t('no') }}
            </label>
          </div>

          <span class="help-block">
                {{ $t('scheduledExecution.property.executionEnabled.description') }}
          </span>
        </div>
      </div>
</div>
</template>
<script setup lang="ts">
import axios from 'axios'
import UiSocket from '../../../../library/components/utils/UiSocket.vue'
import {computed, onBeforeMount, onMounted, ref, watch} from 'vue'
import { useI18n } from 'vue-i18n'

import {
  getDays,
  getMonths,
  getSimpleDecomposition,
} from "./services/scheduleDefinition"
import { EventBus } from "../../../../library";

const props = withDefaults(defineProps<{
    modelValue: any
    eventBus: typeof EventBus
    useCrontabString?: boolean
}>(),{
    useCrontabString: false
})

  const labelColClass = 'col-sm-2 control-label'
  const fieldColSize = 'col-sm-10'

  const modelData = ref<any>({})

  const name = ref<string>("")
  const errors = ref<string>("")
  const hours = ref<string[]>([])
  const minutes = ref<string[]>([])
  const days = ref([])
  const months = ref([])
  const crontabpos = ref<number>(-1)
  const crontabInput = ref(null)

  onBeforeMount(async () => {
    var _hours: string[] = []
    var _minutes: string[] = []
    for(let x = 0; x < 24; x++) {
        _hours.push(x< 10? '0'+x.toString(): x.toString())
    }
    for(let x = 0; x < 60; x++) {
        _minutes.push(x< 10? '0'+x.toString(): x.toString())
    }
    hours.value = _hours;
    minutes.value = _minutes;
    days.value = getDays();
    months.value = getMonths();
  })
  onMounted(() => {
    modelData.value = Object.assign({
      selectedDays: [],
      selectedMonths: [],
      useCrontabString: props.useCrontabString
    }, props.modelValue)
    
    if(modelData.value.useCrontabString)
      showCronExpression()
    else
      showSimpleCron()
  })

  function loadScheduleIntoSimpleTab (decomposedSchedule:any){
    modelData.value.hourSelected = decomposedSchedule.hour;
    modelData.value.minuteSelected = decomposedSchedule.minute;
    modelData.value.selectedDays = decomposedSchedule.days.length <= 7 ? decomposedSchedule.days : [];
    modelData.value.selectedMonths = decomposedSchedule.months.length <= 12 ? decomposedSchedule.months : [];
    modelData.value.everyDayOfWeek = decomposedSchedule.days.length === 7;
    modelData.value.allMonths = decomposedSchedule.months.length === 12;
  }

  function showSimpleCron(){
    if(modelData.value.crontabString) {
      let cronComponents = modelData.value.crontabString.split(" ");

      let decomposedSchedule = getSimpleDecomposition(
        cronComponents[2],
        cronComponents[1],
        cronComponents[5],
        cronComponents[4],
      );
      loadScheduleIntoSimpleTab(decomposedSchedule);
    }
    modelData.value.useCrontabString = false;
  }
  function showCronExpression(){
    modelData.value.useCrontabString = true;
  }
  function validateCronExpression(){
    errors.value = ''
    axios({
      method: "post",
      headers: {
      },
      params: {
        project: window._rundeck.projectName,
        crontabString: modelData.value.crontabString
      },
      url: new URL(`scheduledExecution/checkCrontab`, window._rundeck.rdBase).toString(),
      withCredentials: true
    }).then(response => {
      errors.value = response.request.response
    })
  }
  const emit = defineEmits(['update:modelValue'])

  watch(modelData,() =>{
      emit('update:modelValue', modelData.value)
  }, {deep:true})

  function crontabBlur(){
    validateCronExpression()
    crontabpos.value=-1
  }
  function updateCrontabPosition(){
    crontabpos.value = getCaretPos(crontabInput.value);
  }

  const crontabHint = computed(() =>{
    return modelData.value.useCrontabString ?
      getHintText(crontabpos.value, modelData.value.crontabString)
      : ''
  })

  /**
   * Get crontab position hint string
   * @param pos caret position within string
   * @param text string
   */
  function getHintText(pos:number, text:string){
    let c = getCrontabSection(pos,text)
    const { t } = useI18n()
    if (c >= 0 && c <= 6) {
      return t(`cron.section.${c}`)
    }
    return ''
  }

  /**
   * Get crontab position hint string
   * @param pos caret position within string
   * @param text string
   */
  function getCrontabSection(pos:number, text:string):number{
    if (pos < 0) {
      return -1
    }
    //find # of space chars prior to pos
    let sub = text.substring(0, pos)
    let c = sub.split(' ').length
    if (c >= 1 && c <= 7) {
      return c-1
    }
    return -1
  }

  /**
   * Determine selection caret position within the input field
   * nb: there's probably a better/modern way to do this, this is old code
   * @param el input element
   */
 function getCaretPos(el:any) {
    let rng, ii = -1;
    if (typeof el.selectionStart == "number") {
      return  el.selectionStart;
      //@ts-ignore
    } else if (document.selection && el.createTextRange) {
      //@ts-ignore
      rng = document.selection.createRange();
      rng.collapse(true);
      rng.moveStart("character", -el.value.length);
      return  rng.text.length;
    }
    return ii;
  }

</script>
