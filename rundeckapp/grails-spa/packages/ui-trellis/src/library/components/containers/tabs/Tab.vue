<template>
  <div v-if="isActive" class="tab-pane">
    <slot></slot>
  </div>
</template>

<script lang="ts">
import {defineComponent} from "vue";
import {webhookui} from "../../../stores/Webhooks";

export default defineComponent({
    name: 'Tab',
    props:{
        index: {
            type: Number,
            default: 0
        },
        title: {
            type: String,
            default: 'patabs--standard'
        }
    },
    inject: ['selectedIndex'],
    computed: {
        isActive() {
            return this.index === this.selectedIndex
        },
    }
})
</script>

<style scoped>

</style>
