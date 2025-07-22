<template>
  <div>
    <h3>Рекомендации Deepseek</h3>
    <div v-if="loading">Загрузка рекомендаций...</div>
    <div v-else-if="recommendations">
      <div v-for="(rec, index) in recommendations" :key="index" style="margin-bottom: 1em; padding: 1em; border: 1px solid #ddd; border-radius: 4px;">
        <strong>{{ rec.title || 'Рекомендация ' + (index + 1) }}</strong>
        <div>{{ rec.description || rec.message || rec }}</div>
        <div v-if="rec.priority" style="color: {{ rec.priority === 'high' ? 'red' : rec.priority === 'medium' ? 'orange' : 'green' }};">
          Приоритет: {{ rec.priority }}
        </div>
      </div>
    </div>
    <div v-else-if="error" style="color: red;">{{ error }}</div>
    <button @click="getRecommendations" :disabled="loading">
      {{ loading ? 'Загрузка...' : 'Получить рекомендации' }}
    </button>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  fieldId: { type: Number, required: true }
})

const recommendations = ref(null)
const loading = ref(false)
const error = ref('')

async function getRecommendations() {
  loading.value = true
  error.value = ''
  try {
    const res = await fetch(`http://localhost:8000/api/fields/${props.fieldId}/deepseek-recommend`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        country: 'Россия',
        region: 'Московская область',
        locality: 'Москва'
      })
    })
    if (!res.ok) {
      const err = await res.json()
      throw new Error(err.error || 'Ошибка получения рекомендаций')
    }
    recommendations.value = await res.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
button {
  margin-top: 1em;
  padding: 0.5em 1em;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
button:disabled {
  background: #ccc;
  cursor: not-allowed;
}
/* Мобильная адаптация */
@media (max-width: 768px) {
  button {
    width: 100%;
    padding: 0.75em 1em;
    font-size: 16px;
    border-radius: 8px;
    min-height: 44px;
  }
  div[style*="border: 1px solid #ddd"] {
    margin: 0.5em 0;
    padding: 1em;
    border-radius: 8px;
  }
}
</style> 