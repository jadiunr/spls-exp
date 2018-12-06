<template>
  <div class="live">
    <section class="section">
      <div class="container" id="container">
        <h1 class="title">Watch</h1>
        <video ref="remoteVideo" autoplay />
      </div>
    </section>
  </div>
</template>

<script lang="ts">
import WebRTCWatchClient from "@/plugins/streaming/watch";
import { Component, Vue } from 'vue-property-decorator';
import axios from '@/plugins/axios';

@Component({})
export default class Watch extends Vue {
  remoteStream!: MediaStream;
  watch: WebRTCWatchClient = new WebRTCWatchClient;

  mounted() {
    this.watch.connect(this.$route.params.streamer);
    this.watch.onTrack(stream => {
      this.remoteStream = stream;
      (this.$refs.remoteVideo as HTMLVideoElement).srcObject = stream;
    });
  }
};

</script>