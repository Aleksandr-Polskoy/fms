<template>
  <div>
    <h2>Сорта культур</h2>
    <select v-model="selectedCultureId">
      <option v-for="c in cultures" :key="c.id" :value="c.id">{{ c.name }}</option>
    </select>
    <VarietyList v-if="selectedCultureId" :culture-id="selectedCultureId" :culture-name="selectedCultureName" />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import VarietyList from '../components/VarietyList.vue'

const cultures = ref([])
const selectedCultureId = ref(null)

const API_URL = 'http://localhost:8000/api/cultures'

async function fetchCultures() {
  const res = await fetch(API_URL)
  cultures.value = await res.json()
  if (cultures.value.length > 0 && !selectedCultureId.value) {
    selectedCultureId.value = cultures.value[0].id
  }
}

const selectedCultureName = computed(() => {
  const c = cultures.value.find(c => c.id === selectedCultureId.value)
  return c ? c.name : ''
})

onMounted(fetchCultures)
</script> 