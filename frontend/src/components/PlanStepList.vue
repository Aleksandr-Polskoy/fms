<template>
  <div>
    <h3>Шаги плана</h3>
    <form @submit.prevent="submitForm">
      <input v-model="form.action" placeholder="Действие" required />
      <input v-model="form.photo" placeholder="Фото (URL)" />
      <textarea v-model="form.description" placeholder="Описание"></textarea>
      <input v-model="form.step_order" placeholder="Порядок" type="number" min="1" />
      <input v-model="form.weather_conditions" placeholder="Погодные условия (описание)" />
      <input v-model="form.preparation_id" placeholder="ID препарата (опционально)" type="number" min="1" />
      <button type="submit">{{ form.id ? 'Сохранить' : 'Добавить' }}</button>
      <button v-if="form.id" type="button" @click="resetForm">Отмена</button>
    </form>
    <ul>
      <li v-for="step in steps" :key="step.id">
        <img v-if="step.photo" :src="step.photo" alt="Фото" style="max-width:50px;max-height:50px;" />
        <strong>{{ step.action }}</strong> (Порядок: {{ step.step_order || '?' }})
        <button @click="editStep(step)">Редактировать</button>
        <button @click="deleteStep(step.id)">Удалить</button>
        <div v-if="step.description">Описание: {{ step.description }}</div>
        <div v-if="step.weather_conditions">Погода: {{ step.weather_conditions }}</div>
        <div v-if="step.preparation_id">ID препарата: {{ step.preparation_id }}</div>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

const props = defineProps({
  planId: { type: Number, required: true }
})

const steps = ref([])
const form = ref({ id: null, plan_id: props.planId, action: '', description: '', photo: '', preparation_id: '', weather_conditions: '', step_order: '' })

const API_URL = 'http://localhost:8000/api/plan-steps'

async function fetchSteps() {
  const res = await fetch(`${API_URL}?plan_id=${props.planId}`)
  steps.value = await res.json()
}

async function submitForm() {
  form.value.plan_id = props.planId
  if (form.value.id) {
    await fetch(`${API_URL}/${form.value.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  } else {
    await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  }
  resetForm()
  fetchSteps()
}

function editStep(step) {
  form.value = { ...step, plan_id: props.planId }
}

async function deleteStep(id) {
  if (confirm('Удалить шаг?')) {
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' })
    fetchSteps()
  }
}

function resetForm() {
  form.value = { id: null, plan_id: props.planId, action: '', description: '', photo: '', preparation_id: '', weather_conditions: '', step_order: '' }
}

onMounted(fetchSteps)
watch(() => props.planId, fetchSteps)
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