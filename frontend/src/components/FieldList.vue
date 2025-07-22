<template>
  <div>
    <h2>Поля</h2>
    <form @submit.prevent="submitForm">
      <input v-model="form.name" placeholder="Название" required />
      <input v-model="form.area" placeholder="Площадь (га)" type="number" step="0.01" />
      <input v-model="form.photo" placeholder="Фото (URL)" />
      <textarea v-model="form.description" placeholder="Описание"></textarea>
      <div style="margin: 1em 0;">
        <label>Координаты:</label>
        <input v-model="form.coordinates" placeholder="Координаты (lat,lng)" readonly />
        <div id="map" style="height: 250px; margin-top: 0.5em;"></div>
      </div>
      <button type="submit">{{ form.id ? 'Сохранить' : 'Добавить' }}</button>
      <button v-if="form.id" type="button" @click="resetForm">Отмена</button>
    </form>
    <ul>
      <li v-for="field in fields" :key="field.id">
        <img v-if="field.photo" :src="field.photo" alt="Фото" style="max-width:50px;max-height:50px;" />
        <strong>{{ field.name }}</strong> ({{ field.area || '?' }} га)
        <button @click="editField(field)">Редактировать</button>
        <button @click="deleteField(field.id)">Удалить</button>
        <div v-if="field.description">Описание: {{ field.description }}</div>
        <div v-if="field.coordinates">Координаты: {{ field.coordinates }}</div>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
let map, marker

const fields = ref([])
const form = ref({ id: null, name: '', description: '', area: '', coordinates: '', photo: '' })

const API_URL = 'http://localhost:8000/api/fields'

async function fetchFields() {
  const res = await fetch(API_URL)
  fields.value = await res.json()
}

async function submitForm() {
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
  fetchFields()
}

function editField(field) {
  form.value = { ...field }
  setTimeout(initMap, 100) // обновить карту после рендера
}

async function deleteField(id) {
  if (confirm('Удалить поле?')) {
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' })
    fetchFields()
  }
}

function resetForm() {
  form.value = { id: null, name: '', description: '', area: '', coordinates: '', photo: '' }
  setTimeout(initMap, 100)
}

function initMap() {
  if (!window.L) return
  if (!map) {
    map = window.L.map('map').setView([55.75, 37.61], 5)
    window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(map)
    map.on('click', onMapClick)
  }
  if (marker) {
    map.removeLayer(marker)
    marker = null
  }
  if (form.value.coordinates) {
    const [lat, lng] = form.value.coordinates.split(',').map(Number)
    marker = window.L.marker([lat, lng]).addTo(map)
    map.setView([lat, lng], 13)
  }
}

function onMapClick(e) {
  const { lat, lng } = e.latlng
  form.value.coordinates = `${lat.toFixed(6)},${lng.toFixed(6)}`
  if (marker) map.removeLayer(marker)
  marker = window.L.marker([lat, lng]).addTo(map)
}

onMounted(() => {
  fetchFields()
  // Загружаем Leaflet динамически
  if (!window.L) {
    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = 'https://unpkg.com/leaflet/dist/leaflet.css'
    document.head.appendChild(link)
    const script = document.createElement('script')
    script.src = 'https://unpkg.com/leaflet/dist/leaflet.js'
    script.onload = initMap
    document.body.appendChild(script)
  } else {
    initMap()
  }
})
watch(() => form.value.id, () => setTimeout(initMap, 100))
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
#map {
  width: 100%;
  border: 1px solid #ccc;
  border-radius: 4px;
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
  #map {
    height: 300px !important;
    margin: 1em 0;
  }
}
</style> 