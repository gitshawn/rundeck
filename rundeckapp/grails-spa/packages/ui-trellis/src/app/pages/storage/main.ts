import {createApp} from 'vue'
import * as uiv from 'uiv'

import KeyStoragePage from "../../../library/components/storage/KeyStoragePage.vue";
import KeyStorageView from "../../../library/components/storage/KeyStorageView.vue";
import KeyStorageEdit from "../../../library/components/storage/KeyStorageEdit.vue";
import {initI18n} from "../../utilities/i18n"

const i18n = initI18n()

const elm = document.getElementById('keyStoragePage')

const vue = createApp({
    name: 'StorageApp',
    components: { KeyStoragePage, KeyStorageView, KeyStorageEdit },
})
vue.use(uiv)
vue.use(i18n)
vue.mount(elm)

