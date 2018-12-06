<template>
  <div class="login">
    <section class="section">
      <div class="container">
        <h1 class="title">Login</h1>
        
        <div class="field">
          <p class="control has-icons-left has-icons-right">
            <input v-model="email" class="input" type="email" placeholder="Email">
            <span class="icon is-small is-left"> <i class="fas fa-envelope"></i> </span>
            <span class="icon is-small is-right"> <i class="fas fa-check"></i> </span>
          </p>
        </div>
        <div class="field">
          <p class="control has-icons-left">
            <input v-model="password" class="input" type="password" placeholder="Password">
            <span class="icon is-small is-left"> <i class="fas fa-lock"></i> </span>
          </p>
        </div>
        <div class="field">
          <p class="control">
            <button @click="login" class="button is-success"> Login </button>
          </p>
        </div>

      </div>
    </section>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import axios from '@/plugins/axios';

@Component({})
export default class Login extends Vue {
  email: string = '';
  password: string = '';

  public async login() {
    const res = await axios.login(this.email, this.password)
    console.log(res);
  }
};
</script>