import { createRouter, createWebHistory } from 'vue-router'
import PreparationsView from '../views/PreparationsView.vue'
import CulturesView from '../views/CulturesView.vue'
import VarietiesView from '../views/VarietiesView.vue'
import FieldsView from '../views/FieldsView.vue'
import PlansView from '../views/PlansView.vue'
import FieldPlanApplyView from '../views/FieldPlanApplyView.vue'
import FieldWorkView from '../views/FieldWorkView.vue'
import NotificationRulesView from '../views/NotificationRulesView.vue'

const routes = [
  { path: '/preparations', name: 'Preparations', component: PreparationsView },
  { path: '/cultures', name: 'Cultures', component: CulturesView },
  { path: '/varieties', name: 'Varieties', component: VarietiesView },
  { path: '/fields', name: 'Fields', component: FieldsView },
  { path: '/plans', name: 'Plans', component: PlansView },
  { path: '/field-plan-apply', name: 'FieldPlanApply', component: FieldPlanApplyView },
  { path: '/field-work', name: 'FieldWork', component: FieldWorkView },
  { path: '/notification-rules', name: 'NotificationRules', component: NotificationRulesView },
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router 