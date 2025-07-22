<template>
  <span v-if="icon">
    <img :src="`https://openweathermap.org/img/wn/${icon}@2x.png`" :alt="desc" style="width:32px;height:32px;vertical-align:middle;" />
    <span>{{ temp }}°C, {{ desc }}</span>
  </span>
</template>

<script setup>
const props = defineProps({
  icon: String,
  temp: [String, Number],
  desc: String
})
</script> 