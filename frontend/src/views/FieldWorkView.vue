<template>
  <div>
    <h2>Календарь работ по полю</h2>
    <select v-model="selectedFieldId">
      <option value="">Выберите поле</option>
      <option v-for="f in fields" :key="f.id" :value="f.id">{{ f.name }}</option>
    </select>
    <FieldActionsList v-if="selectedFieldId" :field-id="Number(selectedFieldId)" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import FieldActionsList from '../components/FieldActionsList.vue'

const fields = ref([])
const selectedFieldId = ref('')

const API_FIELDS = 'http://localhost:8000/api/fields'

async function fetchFields() {
  const res = await fetch(API_FIELDS)
  fields.value = await res.json()
  if (fields.value.length > 0 && !selectedFieldId.value) {
    selectedFieldId.value = fields.value[0].id
  }
}

onMounted(fetchFields)
</script> 