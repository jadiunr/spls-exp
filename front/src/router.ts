import Vue from 'vue';
import Router from 'vue-router';
import axios from '@/plugins/axios';
import Home from './pages/Home.vue';
import About from './pages/About.vue';
import Login from './pages/Login.vue';
import Live from './pages/Live.vue';
import Watch from './pages/Watch.vue';

Vue.use(Router);

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    { path: '/', name: 'home', component: Home },
    { path: '/about', name: 'about', component: About },
    { path: '/login', name: 'login', component: Login },
    {
      path: '/live',
      name: 'live',
      component: Live,
      beforeEnter(to, from, next) {
        axios
          .validateToken()
          .then(() => next())
          .catch(() => next({ path: '/login' }));
      },
    },
    { path: '/watch/:streamer', name: 'watch', component: Watch},
  ],
});
