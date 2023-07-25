<template>
    <div class="patabs" :class="[type]">
        <div class="patabs-list">
            <div v-for="(tab, index) in $slots.default()" :key="tab.title" @click="selectTab(index)" class="patab-item"
                 :class="{ 'patab-item--active': index === selectedIndex}">
                {{ tab.props?.title }}
            </div>
        </div>
        <div ref="tabs" class="patab-content">
        <slot></slot>
        </div>
    </div>
</template>

<script>
import {defineComponent, computed} from 'vue'

export default defineComponent({
    name: 'Tabs',
    data(){
        return {
            selectedIndex: 0,
        }
    },
    props:{
        type: {
            type: String,
            default: 'patabs--standard'
        },
    },
    provide() {
      return {
        selectedIndex: computed(() => this.selectedIndex),
      }
    },
    methods: {
        selectTab (i) {
            this.selectedIndex = i
        }
    },
    mounted () {
        this.selectTab(0)
    },
})
</script>