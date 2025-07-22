<template>
  <div id="app">
    <nav>
      <router-link to="/cultures">Культуры</router-link> |
      <router-link to="/varieties">Сорта</router-link> |
      <router-link to="/preparations">Препараты</router-link> |
      <router-link to="/fields">Поля</router-link> |
      <router-link to="/plans">Планы</router-link> |
      <router-link to="/field-plan-apply">Применить план</router-link> |
      <router-link to="/field-work">Календарь работ</router-link> |
      <router-link to="/notification-rules">Правила уведомлений</router-link>
    </nav>
    <router-view/>
  </div>
</template>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

nav {
  padding: 30px;
}

nav a {
  font-weight: bold;
  color: #2c3e50;
  text-decoration: none;
  margin: 0 10px;
}

nav a.router-link-exact-active {
  color: #42b983;
}

/* Мобильная адаптация */
@media (max-width: 768px) {
  #app {
    margin-top: 20px;
  }
  
  nav {
    padding: 15px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  nav a {
    padding: 10px;
    background: #f8f9fa;
    border-radius: 8px;
    margin: 0;
  }
  
  /* Предотвращает зум на iOS */
  input, textarea, select {
    font-size: 16px !important;
  }
  
  /* Улучшает touch-интерфейс */
  button, a {
    min-height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
</style> 