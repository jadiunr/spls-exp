<template>
  <div class="live">
    <section class="section">
      <div class="container">
        <h1 class="title">Live</h1>
        <video ref="localVideo" autoplay></video>
        <button @click="videoStart">Video Start</button>
        <button @click="liveStart">Live Start</button>
        <button @click="liveStop">Live Stop</button>
        <button @click="speak">Speak</button>
      </div>
    </section>
  </div>
</template>

<script lang="ts">
import WebRTCLiveClient from "@/plugins/streaming/live";
import { Component, Vue } from 'vue-property-decorator';
import axios from '@/plugins/axios';

@Component({})
export default class Live extends Vue {
  localStream!: MediaStream;
  localVideo!: HTMLVideoElement;
  live: WebRTCLiveClient = new WebRTCLiveClient;

  async videoStart() {
    this.localStream = await this.live.initLocalStream();
    this.localVideo = this.$refs.localVideo as HTMLVideoElement;
    this.localVideo.srcObject = this.localStream;
    this.localVideo.srcObject.getTracks().map(t => {
      if(t.kind === 'audio') t.stop();
    });
  }
  liveStart() {
    if (!this.localStream) { return }
    this.live.connect();
  }
};

</script>