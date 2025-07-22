<template>
  <div>
    <h2>Планы выращивания</h2>
    <form @submit.prevent="submitForm">
      <input v-model="form.name" placeholder="Название плана" required />
      <select v-model="form.culture_id" required>
        <option value="">Выберите культуру</option>
        <option v-for="c in cultures" :key="c.id" :value="c.id">{{ c.name }}</option>
      </select>
      <select v-model="form.variety_id">
        <option value="">Сорт (опционально)</option>
        <option v-for="v in filteredVarieties" :key="v.id" :value="v.id">{{ v.name }}</option>
      </select>
      <textarea v-model="form.description" placeholder="Описание"></textarea>
      <button type="submit">{{ form.id ? 'Сохранить' : 'Добавить' }}</button>
      <button v-if="form.id" type="button" @click="resetForm">Отмена</button>
    </form>
    <ul>
      <li v-for="plan in plans" :key="plan.id">
        <strong>{{ plan.name }}</strong> ({{ plan.culture?.name }})
        <button @click="editPlan(plan)">Редактировать</button>
        <button @click="deletePlan(plan.id)">Удалить</button>
        <div v-if="plan.description">Описание: {{ plan.description }}</div>
        <PlanStepList :plan-id="plan.id" />
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import PlanStepList from './PlanStepList.vue'

const plans = ref([])
const cultures = ref([])
const varieties = ref([])
const form = ref({ id: null, name: '', culture_id: '', variety_id: '', description: '' })

const API_PLANS = 'http://localhost:8000/api/plans'
const API_CULTURES = 'http://localhost:8000/api/cultures'
const API_VARIETIES = 'http://localhost:8000/api/varieties'

async function fetchPlans() {
  const res = await fetch(API_PLANS)
  plans.value = await res.json()
}
async function fetchCultures() {
  const res = await fetch(API_CULTURES)
  cultures.value = await res.json()
}
async function fetchVarieties() {
  const res = await fetch(API_VARIETIES)
  varieties.value = await res.json()
}

const filteredVarieties = computed(() => {
  if (!form.value.culture_id) return []
  return varieties.value.filter(v => v.culture_id == form.value.culture_id)
})

async function submitForm() {
  if (form.value.id) {
    await fetch(`${API_PLANS}/${form.value.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  } else {
    await fetch(API_PLANS, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  }
  resetForm()
  fetchPlans()
}

function editPlan(plan) {
  form.value = { ...plan, culture_id: plan.culture_id || '', variety_id: plan.variety_id || '', description: plan.description || '' }
}

async function deletePlan(id) {
  if (confirm('Удалить план?')) {
    await fetch(`${API_PLANS}/${id}`, { method: 'DELETE' })
    fetchPlans()
  }
}

function resetForm() {
  form.value = { id: null, name: '', culture_id: '', variety_id: '', description: '' }
}

onMounted(() => {
  fetchPlans()
  fetchCultures()
  fetchVarieties()
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
ul {
  list-style: none;
  padding: 0;
}
li {
  margin-bottom: 2em;
  border-bottom: 1px solid #eee;
  padding-bottom: 1em;
}
/* Мобильная адаптация */
@media (max-width: 768px) {
  form {
    max-width: 100%;
    padding: 1em;
  }
  input, textarea, select {
    padding: 0.75em;
    font-size: 16px;
    border-radius: 8px;
    border: 1px solid #ddd;
    width: 100%;
    box-sizing: border-box;
  }
  button {
    padding: 0.75em 1em;
    font-size: 16px;
    border-radius: 8px;
    border: none;
    background: #007bff;
    color: white;
    cursor: pointer;
    min-height: 44px;
  }
  li {
    padding: 1em;
    border: 1px solid #ddd;
    border-radius: 8px;
    margin-bottom: 1em;
  }
}
</style> 