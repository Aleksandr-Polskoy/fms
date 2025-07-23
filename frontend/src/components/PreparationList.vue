<template>
  <div class="preparation-list">
    <h2>Список препаратов</h2>
    <div v-if="loading" class="loading">
      Загрузка...
    </div>
    <div v-else-if="error" class="error">
      {{ error }}
    </div>
    <div v-else class="preparations">
      <div v-for="preparation in preparations" :key="preparation.id" class="preparation-item">
        <h3>{{ preparation.name }}</h3>
        <p>{{ preparation.description }}</p>
        <div class="preparation-details">
          <span class="type">{{ preparation.type }}</span>
          <span class="dosage">{{ preparation.dosage }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'

export default {
  name: 'PreparationList',
  setup() {
    const preparations = ref([])
    const loading = ref(true)
    const error = ref(null)

    const fetchPreparations = async () => {
      try {
        loading.value = true
        const response = await fetch('/api/preparations')
        if (!response.ok) {
          throw new Error('Ошибка загрузки препаратов')
        }
        preparations.value = await response.json()
      } catch (err) {
        error.value = err.message
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      fetchPreparations()
    })

    return {
      preparations,
      loading,
      error
    }
  }
}
</script>

<style scoped>
.preparation-list {
  padding: 20px;
}

.loading {
  text-align: center;
  padding: 20px;
  color: #666;
}

.error {
  color: #d32f2f;
  padding: 20px;
  text-align: center;
}

.preparations {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.preparation-item {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  background: white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.preparation-item h3 {
  margin: 0 0 10px 0;
  color: #333;
}

.preparation-item p {
  margin: 0 0 15px 0;
  color: #666;
  line-height: 1.4;
}

.preparation-details {
  display: flex;
  justify-content: space-between;
  font-size: 0.9em;
}

.type {
  background: #e3f2fd;
  color: #1976d2;
  padding: 4px 8px;
  border-radius: 4px;
}

.dosage {
  color: #666;
}
</style> 