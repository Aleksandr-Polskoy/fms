<template>
  <div>
    <h3>Календарь работ по полю</h3>
    <select v-model="selectedFieldPlanId">
      <option value="">Выберите применённый план</option>
      <option v-for="fp in fieldPlans" :key="fp.id" :value="fp.id">
        {{ fp.plan?.name }} ({{ fp.start_date || 'без даты' }})
      </option>
    </select>
    <DeepseekRecommendations :field-id="props.fieldId" />
    <ul v-if="actions.length">
      <li v-for="action in actions" :key="action.id" :style="isDangerDay(weather[action.plan_step?.date]) ? 'background:#ffeaea;' : ''">
        <input type="checkbox" v-model="action.status" true-value="done" false-value="pending" @change="markDone(action)" />
        <img v-if="action.plan_step?.photo" :src="action.plan_step.photo" alt="Фото" style="max-width:40px;max-height:40px;" />
        <strong>{{ action.plan_step?.action }}</strong>
        <span v-if="action.status === 'done'" style="color:green;">✔</span>
        <WeatherIcon v-if="weather[action.plan_step?.date]" :icon="weather[action.plan_step?.date].weather_icon" :temp="weather[action.plan_step?.date].temperature" :desc="weather[action.plan_step?.date].temperature + '°C'" />
        <span v-if="isDangerDay(weather[action.plan_step?.date])" style="color:red;">⚠ Опасная погода!</span>
        <div v-if="notifications[action.plan_step?.date]">
          <div v-for="notif in notifications[action.plan_step?.date]" :key="notif.id" style="color:orange;">
            🔔 {{ notif.message }}
          </div>
        </div>
        <div v-if="action.plan_step?.description">{{ action.plan_step.description }}</div>
        <div v-if="action.actual_date">Выполнено: {{ action.actual_date }}</div>
      </li>
    </ul>
    <div v-else>Нет действий для выбранного плана</div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import WeatherIcon from './WeatherIcon.vue'
import DeepseekRecommendations from './DeepseekRecommendations.vue'

const props = defineProps({
  fieldId: { type: Number, required: true }
})

const fieldPlans = ref([])
const selectedFieldPlanId = ref('')
const actions = ref([])

const API_FIELD_PLANS = 'http://localhost:8000/api/field-plans'
const API_FIELD_ACTIONS = 'http://localhost:8000/api/field-actions'

async function fetchFieldPlans() {
  const res = await fetch(`${API_FIELD_PLANS}?field_id=${props.fieldId}`)
  fieldPlans.value = await res.json()
  if (fieldPlans.value.length > 0 && !selectedFieldPlanId.value) {
    selectedFieldPlanId.value = fieldPlans.value[0].id
  }
}

async function fetchActions() {
  if (!selectedFieldPlanId.value) return
  const res = await fetch(`${API_FIELD_ACTIONS}?field_plan_id=${selectedFieldPlanId.value}`)
  actions.value = await res.json()
}

async function markDone(action) {
  await fetch(`${API_FIELD_ACTIONS}/${action.id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      status: action.status,
      actual_date: action.status === 'done' ? new Date().toISOString().slice(0, 10) : null
    })
  })
  fetchActions()
}

const weather = ref({})

async function fetchWeather() {
  if (!props.fieldId) return
  const res = await fetch(`http://localhost:8000/api/fields/${props.fieldId}/weather-forecast`)
  const arr = await res.json()
  weather.value = {}
  for (const w of arr) {
    weather.value[w.date] = w
  }
}

const notifications = ref({})

async function fetchNotifications() {
  if (!props.fieldId) return
  await fetch(`http://localhost:8000/api/fields/${props.fieldId}/generate-notifications`, { method: 'POST' })
  const res = await fetch(`http://localhost:8000/api/notifications?field_id=${props.fieldId}`)
  const arr = await res.json()
  notifications.value = {}
  for (const n of arr) {
    if (!notifications.value[n.date]) notifications.value[n.date] = []
    notifications.value[n.date].push(n)
  }
}

onMounted(() => {
  fetchFieldPlans()
  fetchWeather()
  fetchNotifications()
})
watch(selectedFieldPlanId, fetchActions)
watch(() => props.fieldId, () => { fetchWeather(); fetchNotifications(); })

function isDangerDay(w) {
  // Пример: температура < 0 или > 30 или осадки > 70%
  if (!w) return false
  return w.temperature < 0 || w.temperature > 30 || w.precipitation > 70
}
</script>

<style scoped>
ul {
  list-style: none;
  padding: 0;
}
li {
  margin-bottom: 1em;
  border-bottom: 1px solid #eee;
  padding-bottom: 1em;
  display: flex;
  align-items: center;
  gap: 1em;
  flex-wrap: wrap;
}
/* Мобильная адаптация */
@media (max-width: 768px) {
  li {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5em;
    padding: 1em;
    border: 1px solid #ddd;
    border-radius: 8px;
    margin-bottom: 1em;
  }
  select {
    width: 100%;
    padding: 0.75em;
    font-size: 16px; /* Предотвращает зум на iOS */
    border-radius: 8px;
    border: 1px solid #ddd;
  }
  button {
    padding: 0.75em 1em;
    font-size: 16px;
    border-radius: 8px;
    border: none;
    background: #007bff;
    color: white;
    cursor: pointer;
    min-height: 44px; /* Минимальная высота для touch */
  }
  input[type="checkbox"] {
    transform: scale(1.5);
    margin-right: 0.5em;
  }
  img {
    max-width: 60px !important;
    max-height: 60px !important;
  }
}
</style> 