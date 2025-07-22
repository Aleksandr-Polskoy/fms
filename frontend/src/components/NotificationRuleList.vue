<template>
  <div>
    <h2>Правила уведомлений</h2>
    <form @submit.prevent="submitForm">
      <input v-model="form.name" placeholder="Название правила" required />
      <input v-model="form.weather_condition" placeholder="Условие (например: temp>25&humidity>80)" />
      <select v-model="form.culture_id">
        <option value="">Культура (опционально)</option>
        <option v-for="c in cultures" :key="c.id" :value="c.id">{{ c.name }}</option>
      </select>
      <input v-model="form.action" placeholder="Действие (опционально)" />
      <textarea v-model="form.message" placeholder="Текст уведомления" required></textarea>
      <textarea v-model="form.description" placeholder="Описание правила"></textarea>
      <button type="submit">{{ form.id ? 'Сохранить' : 'Добавить' }}</button>
      <button v-if="form.id" type="button" @click="resetForm">Отмена</button>
    </form>
    <ul>
      <li v-for="rule in rules" :key="rule.id">
        <strong>{{ rule.name }}</strong>
        <button @click="editRule(rule)">Редактировать</button>
        <button @click="deleteRule(rule.id)">Удалить</button>
        <div v-if="rule.weather_condition">Условие: {{ rule.weather_condition }}</div>
        <div v-if="rule.culture">Культура: {{ rule.culture.name }}</div>
        <div v-if="rule.action">Действие: {{ rule.action }}</div>
        <div>Текст: {{ rule.message }}</div>
        <div v-if="rule.description">Описание: {{ rule.description }}</div>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const rules = ref([])
const cultures = ref([])
const form = ref({ id: null, name: '', weather_condition: '', culture_id: '', action: '', message: '', description: '' })

const API_RULES = 'http://localhost:8000/api/notification-rules'
const API_CULTURES = 'http://localhost:8000/api/cultures'

async function fetchRules() {
  const res = await fetch(API_RULES)
  rules.value = await res.json()
}
async function fetchCultures() {
  const res = await fetch(API_CULTURES)
  cultures.value = await res.json()
}

async function submitForm() {
  if (form.value.id) {
    await fetch(`${API_RULES}/${form.value.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  } else {
    await fetch(API_RULES, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form.value)
    })
  }
  resetForm()
  fetchRules()
}

function editRule(rule) {
  form.value = { ...rule, culture_id: rule.culture_id || '', description: rule.description || '' }
}

async function deleteRule(id) {
  if (confirm('Удалить правило?')) {
    await fetch(`${API_RULES}/${id}`, { method: 'DELETE' })
    fetchRules()
  }
}

function resetForm() {
  form.value = { id: null, name: '', weather_condition: '', culture_id: '', action: '', message: '', description: '' }
}

onMounted(() => {
  fetchRules()
  fetchCultures()
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