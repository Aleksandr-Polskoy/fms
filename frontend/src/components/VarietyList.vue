<template>
  <div>
    <h3>Сорта для культуры: {{ cultureName }}</h3>
    <form @submit.prevent="submitForm">
      <input v-model="form.name" placeholder="Название сорта" required />
      <input v-model="form.photo" placeholder="Фото (URL)" />
      <textarea v-model="form.description" placeholder="Описание"></textarea>
      <input v-model="form.sowing_period" placeholder="Период посева" />
      <input v-model="form.harvest_period" placeholder="Период сбора" />
      <button type="submit">{{ form.id ? 'Сохранить' : 'Добавить' }}</button>
      <button v-if="form.id" type="button" @click="resetForm">Отмена</button>
    </form>
    <ul>
      <li v-for="variety in varieties" :key="variety.id">
        <img v-if="variety.photo" :src="variety.photo" alt="Фото" style="max-width:50px;max-height:50px;" />
        <strong>{{ variety.name }}</strong>
        <button @click="editVariety(variety)">Редактировать</button>
        <button @click="deleteVariety(variety.id)">Удалить</button>
        <div v-if="variety.description">Описание: {{ variety.description }}</div>
        <div v-if="variety.sowing_period">Посев: {{ variety.sowing_period }}</div>
        <div v-if="variety.harvest_period">Сбор: {{ variety.harvest_period }}</div>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

const props = defineProps({
  cultureId: { type: Number, required: true },
  cultureName: { type: String, required: true }
})

const varieties = ref([])
const form = ref({ id: null, culture_id: props.cultureId, name: '', description: '', photo: '', sowing_period: '', harvest_period: '' })

const API_URL = 'http://localhost:8000/api/varieties'

async function fetchVarieties() {
  const res = await fetch(`${API_URL}?culture_id=${props.cultureId}`)
  varieties.value = await res.json()
}

async function submitForm() {
  form.value.culture_id = props.cultureId
  if (form.value.id) {
    // Update
    await fetch(`${API_URL}/${form.value.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  } else {
    // Create
    await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  }
  resetForm()
  fetchVarieties()
}

function editVariety(variety) {
  form.value = { ...variety, culture_id: props.cultureId }
}

async function deleteVariety(id) {
  if (confirm('Удалить сорт?')) {
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' })
    fetchVarieties()
  }
}

function resetForm() {
  form.value = { id: null, culture_id: props.cultureId, name: '', description: '', photo: '', sowing_period: '', harvest_period: '' }
}

onMounted(fetchVarieties)
watch(() => props.cultureId, fetchVarieties)
</script>

<style scoped>
form {
  margin-bottom: 1em;
  display: flex;
  flex-direction: column;
  gap: 0.5em;
  max-width: 400px;
}
ul {
  list-style: none;
  padding: 0;
}
li {
  margin-bottom: 1em;
  border-bottom: 1px solid #eee;
  padding-bottom: 1em;
}
</style> 