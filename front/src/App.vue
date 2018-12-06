<template>
  <div id="app">
    <Navbar/>
    <router-view/>
  </div>
</template>

<script>
import { Component, Vue } from 'vue-property-decorator';
import Navbar from '@/containers/Navbar.vue';

@Component({
  components: {
    Navbar,
  },
})
export default class App extends Vue {}
</script>