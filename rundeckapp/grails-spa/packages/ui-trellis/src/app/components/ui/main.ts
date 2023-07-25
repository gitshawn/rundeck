import {createApp} from 'vue'
import * as uiv from 'uiv'
import VueCookies from "vue-cookies"

import {getRundeckContext} from '../../../library'
import { UiMessage } from '../../../library/stores/UIStore'
import UiSocket from "../../../library/components/utils/UiSocket.vue";
import {initI18n, updateLocaleMessages} from "../../utilities/i18n";

const rootStore = getRundeckContext().rootStore
const EventBus = getRundeckContext().eventBus
let updateI18n: Function | null = null

window.addEventListener('DOMContentLoaded', (() => {
  const elm = document.getElementsByClassName('vue-ui-socket')
  for (const elmElement of elm) {
    const eventName = elmElement.getAttribute("vue-socket-on")
    if(eventName){
      window.addEventListener(eventName, (evt1 => initUiComponentsOnEvent(evt1)))
    } else {
      initUiComponents(elmElement)
    }
  }

  applyUiMessages()
}))

function initUiComponentsOnEvent(evt:Event){
  const elm = document.getElementsByClassName('vue-ui-socket')
  for (const elmElement of elm) {
    const eventName = elmElement.getAttribute("vue-socket-on")
    if(eventName === evt.type){
      initUiComponents(elmElement)
    }
  }
}

function initUiComponents(elmElement:any) {
  const i18n = initI18n()
    const vue = createApp({
      components: {UiSocket},
      data() {
        return {
          EventBus
        }
      },
      provide: {
        rootStore,
      }
    })
    vue.use(VueCookies)
    vue.use(i18n)
    vue.use(uiv)
    vue.mount(elmElement)
    updateI18n = updateLocaleMessages(i18n)
}

function applyUiMessages(){
  const messages = rootStore.ui.getUiMessages()
  const newMessages = messages.reduce((acc:any, message:UiMessage) => message ? ({...acc, ...message}) : acc, {})
  messages.forEach((message:UiMessage) => {
    if(message){
      let _w:any = window
      Object.assign((_w.Messages), message)
    }
  })
  const locale = window._rundeck.locale || 'en_US'
  const lang = window._rundeck.language || 'en'
  if (updateI18n) {
    updateI18n(locale || lang, newMessages)
  }
}
