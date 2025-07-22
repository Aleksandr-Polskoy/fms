<template>
  <div>
    <h2>Применить план к полю</h2>
    <form @submit.prevent="submitForm">
      <select v-model="form.field_id" required>
        <option value="">Выберите поле</option>
        <option v-for="f in fields" :key="f.id" :value="f.id">{{ f.name }}</option>
      </select>
      <select v-model="form.plan_id" required>
        <option value="">Выберите план</option>
        <option v-for="p in plans" :key="p.id" :value="p.id">{{ p.name }}</option>
      </select>
      <input v-model="form.start_date" type="date" placeholder="Дата старта" />
      <button type="submit">Применить</button>
    </form>
    <div v-if="message" style="color:green;">{{ message }}</div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const fields = ref([])
const plans = ref([])
const form = ref({ field_id: '', plan_id: '', start_date: '' })
const message = ref('')

const API_FIELDS = 'http://localhost:8000/api/fields'
const API_PLANS = 'http://localhost:8000/api/plans'
const API_FIELD_PLANS = 'http://localhost:8000/api/field-plans'

async function fetchFields() {
  const res = await fetch(API_FIELDS)
  fields.value = await res.json()
}
async function fetchPlans() {
  const res = await fetch(API_PLANS)
  plans.value = await res.json()
}

async function submitForm() {
  await fetch(API_FIELD_PLANS, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(form.value)
  })
  message.value = 'План успешно применён к полю!'
  form.value = { field_id: '', plan_id: '', start_date: '' }
}

onMounted(() => {
  fetchFields()
  fetchPlans()
})
</script>

<style scoped>
form {
  margin-bottom: 1em;
  display: flex;
  flex-direction: column;
  gap: 0.5em;
  max-width: 400px;
}
</style> 