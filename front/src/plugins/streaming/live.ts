import ActionCable from '../actioncable';
import Axios from '@/plugins/axios';

export default class LiveStreaming {
  private localStream!: MediaStream;
  private childPeerConnections: {[index: string]: RTCPeerConnection} = {};
  private cable!: ActionCable.Channel;
  private name!: string;

  public async connect() {
    const userInfo = await Axios.validateToken();
    this.name = userInfo.data.data.unique_name;

    this.cable = ActionCable.subscriptions.create(
      {
        channel: 'LiveChannel',
        unique_name: this.name,
      },
      {
        connected: () => {
          console.log('connected');
          console.log(this.name);
          this.cable.perform('be_root', {});
        },
        disconnected: () => {
          // no op
        },
        received: (data) => {
          switch (data.method) {
            case 'get_node_tree':
              console.log(data.tree);
              break;
            default:
              this.signaling(data.from_uuid, data.method, data.message);
              break;
          }
        },
      },
    );
  }

  public async initLocalStream() {
    const constraints = {
      video: true,
      audio: true,
    };

    this.localStream = await navigator.mediaDevices.getUserMedia(constraints);
    return this.localStream;
  }


  private signaling(fromId: string, method: string, message: any) {
    switch (method) {
      case 'request_stream':
        this.sendOffer(fromId);
        break;
      case 'answer':
        this.setAnswer(fromId, message);
        break;
      case 'candidate':
        this.addIceCandidate(fromId, message);
        break;
      case 'disconnected':
        const id = Object.keys(this.childPeerConnections).find((key) => {
          return key === fromId;
        });
        if (!!id) {
          console.log("Child Disconnected");
          this.stopConnection(id);
        }
        break;
    }
  }

  private async sendOffer(id: any) {
    console.log('sendoffer');
    const pc = this.createNewChildConnection(id);
    this.childPeerConnections[id] = pc;

    const offer = await pc.createOffer();
    pc.setLocalDescription(offer);
    this.cable.perform('emit_to', {
      sendto: id,
      method: 'offer',
      message: pc.localDescription,
    });
  }

  private async setAnswer(id: any, message: RTCSessionDescriptionInit) {
    console.log('setanswer');
    const answer = new RTCSessionDescription(message);
    const pc = this.childPeerConnections[id];
    console.log(answer);
    await pc.setRemoteDescription(answer);
  }

  private createNewChildConnection(id: string) {
    console.log('createnewconn');
    const pcConfig = {iceServers: [
      {urls: 'stun:stun.l.google.com:19302'},
    ]};
    const peer = new RTCPeerConnection(pcConfig);

    // --- on get local ICE candidate
    peer.onicecandidate = evt => {
      console.log('onicecand');
      if (evt.candidate) {
        this.sendIceCandidate(id, evt.candidate);
      }
    };

    // -- add remote stream --
    if (this.localStream!) {
      this.localStream.getTracks().forEach(track => {
        peer.addTrack(track, this.localStream);
      });
    }

    return peer;
  }

  private sendIceCandidate(id: any, candidate: RTCIceCandidate) {
    console.log('sendicecand');
    // let message = JSON.stringify(obj);
    // console.log('sending candidate=' + message);
    // ws.send(message);
    console.log(candidate);
    this.cable.perform('emit_to', {
      sendto: id,
      method: 'candidate',
      message: candidate
    });
  }

  private addIceCandidate(id: any, message: RTCIceCandidateInit) {
    console.log('addicecand');
    const candidate = new RTCIceCandidate(message);
    const pc = this.childPeerConnections[id];
    pc.addIceCandidate(candidate);
  }

  private stopConnection(id: any) {
    console.log('stopconn');
    const peer = this.childPeerConnections[id];
    peer.close();
    delete this.childPeerConnections[id];
  }
}
