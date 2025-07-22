<template>
  <div>
    <h2>Каталог культур</h2>
    <form @submit.prevent="submitForm">
      <input v-model="form.name" placeholder="Название" required />
      <input v-model="form.photo" placeholder="Фото (URL)" />
      <textarea v-model="form.description" placeholder="Описание"></textarea>
      <button type="submit">{{ form.id ? 'Сохранить' : 'Добавить' }}</button>
      <button v-if="form.id" type="button" @click="resetForm">Отмена</button>
    </form>
    <ul>
      <li v-for="culture in cultures" :key="culture.id">
        <img v-if="culture.photo" :src="culture.photo" alt="Фото" style="max-width:50px;max-height:50px;" />
        <strong>{{ culture.name }}</strong>
        <button @click="editCulture(culture)">Редактировать</button>
        <button @click="deleteCulture(culture.id)">Удалить</button>
        <div v-if="culture.description">Описание: {{ culture.description }}</div>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const cultures = ref([])
const form = ref({ id: null, name: '', description: '', photo: '' })

const API_URL = 'http://localhost:8000/api/cultures'

async function fetchCultures() {
  const res = await fetch(API_URL)
  cultures.value = await res.json()
}

async function submitForm() {
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
  fetchCultures()
}

function editCulture(culture) {
  form.value = { ...culture }
}

async function deleteCulture(id) {
  if (confirm('Удалить культуру?')) {
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' })
    fetchCultures()
  }
}

function resetForm() {
  form.value = { id: null, name: '', description: '', photo: '' }
}

onMounted(fetchCultures)
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