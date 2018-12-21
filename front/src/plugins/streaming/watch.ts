import ActionCable from '../actioncable';

export default class WatchStreaming {
  private remoteStream!: MediaStream;
  private parentPeerConnection: {id: string | null, pc: RTCPeerConnection | null} = {id: null, pc: null};
  private childPeerConnections: {[id: string]: RTCPeerConnection} = {};
  private uuid!: string;
  private cable!: ActionCable.Channel;
  private gotRemoteStreamCallback!: (stream: MediaStream) => void;

  public connect(streamerName: string) {
    this.cable = ActionCable.subscriptions.create(
      {
        channel: 'LiveChannel',
        unique_name: streamerName,
      },
      {
        connected: () => {
          console.log('connected');
          this.cable.perform('get_uuid', {});
          this.cable.perform('get_node_tree', {});
        },
        disconnected: () => {
          console.log("aaa");
        },
        received: (data) => {
          switch (data.method) {
            case 'get_uuid':
              console.log(data.uuid);
              this.uuid = data.uuid;
              break;
            case 'get_node_tree':
              console.log(data);
              const parentNodeKeys = Object.keys(data.tree).filter((key) => {
                const node = data.tree[key];
                return (node.children_uuid.length < 1) && (node.uuid !== this.uuid);
              });
              if (!!parentNodeKeys) {
                this.requestStream(parentNodeKeys[0]);
              }
              break;
            default:
              this.signaling(data.from_uuid, data.method, data.message);
              break;
          }
        },
      },
    );
  }

  public onTrack(f: (stream: MediaStream) => void) {
    this.gotRemoteStreamCallback = f;
  }

  private signaling(fromId: string, method: string, message: any) {
    switch (method) {
      case 'request_stream':
        console.log("REQUEST STREAM");
        this.sendOffer(fromId);
        break;
      case 'offer':
        this.cable.perform('add_node_to_tree', {
          parent_uuid: fromId,
          children_uuid: Object.keys(this.childPeerConnections),
        });
        this.setOffer(fromId, message);
        this.sendAnswer(fromId);
        break;
      case 'answer':
        this.setAnswer(fromId, message);
        break;
      case 'candidate':
        this.addIceCandidate(fromId, message);
        break;
      case 'callme':
        this.sendOffer(fromId);
        break;
      case 'disconnected':
        if (this.parentPeerConnection.id === fromId) {
          console.log("Parent disconnected");
          this.parentPeerConnection.pc!.close();
          this.parentPeerConnection.id = null;
          this.parentPeerConnection.pc = null;
          this.cable.perform('get_node_tree', {});
        } else {
          let id = Object.keys(this.childPeerConnections).find((key) => {
            return key === fromId;
          });
          if (!!id) {
            console.log("Child Disconnected");
            this.stopConnection(id);
          }
        }
        break;
    }
  }

  private async setOffer(id: string, message: RTCSessionDescriptionInit) {
    console.log('setoffer');
    const offer = new RTCSessionDescription(message);
    const pc = this.createNewParentConnection(id);
    this.parentPeerConnection.id = id;
    this.parentPeerConnection.pc = pc;
    await pc.setRemoteDescription(offer);
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


  private async sendAnswer(id: any) {
    console.log('sendanswer');
    const pc = this.parentPeerConnection.pc;
    const answer = await pc!.createAnswer();
    pc!.setLocalDescription(answer);
    this.cable.perform('emit_to', {
      sendto: id,
      method: 'answer',
      message: answer,
    });
  }

  private createNewParentConnection(id: any) {
    console.log('createnewconn');
    const pcConfig = {iceServers: [
      {urls: 'stun:stun.l.google.com:19302'},
    ]};
    const peer = new RTCPeerConnection(pcConfig);

    // --- on get remote stream ---
    peer.ontrack = event => {
      if (event.track.kind === 'video') {
        // video追加時の処理
        console.log('ontrack');
        const stream = event.streams[0];
        this.remoteStream = stream;
        this.gotRemoteStreamCallback(stream);
        // -- add remote stream --
        if (!!Object.keys(this.childPeerConnections).length) {
          Object.keys(this.childPeerConnections).forEach(key => {
            this.remoteStream.getTracks().forEach(track => {
              this.childPeerConnections[key].addTrack(track, this.remoteStream);
            });
          });
        }
      }
    };

    // --- on get local ICE candidate
    peer.onicecandidate = evt => {
      console.log('onicecand');
      if (evt.candidate) {
        this.sendIceCandidate(id, evt.candidate);
      }
    };

    return peer;
  }

  private createNewChildConnection(id: any) {
    console.log('createnewconn');
    const pcConfig = {iceServers: [
      {urls: 'stun:stun.l.google.com:19302'}
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
    if (this.remoteStream) {
      this.remoteStream.getTracks().forEach(track => {
        peer.addTrack(track, this.remoteStream);
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
    const pc = this.findPeerConnection(id);
    pc!.addIceCandidate(candidate);
  }

  private stopConnection(id: any) {
    console.log('stopconn');
    const peer = this.findPeerConnection(id);
    peer!.close();
    if (this.parentPeerConnection.id !== id) {
      delete this.childPeerConnections[id];
    }
  }

  private requestStream(id: string) {
    console.log("req stream");
    this.cable.perform('emit_to', {
      sendto: id,
      method: 'request_stream',
      message: 'request_stream',
    });
  }

  private findPeerConnection(id: string) {
    let pc!: RTCPeerConnection | null;

    if (this.parentPeerConnection.id === id) {
      pc = this.parentPeerConnection.pc;
    } else {
      pc = this.childPeerConnections[id];
    }

    return pc;
  }

  private sleep(msec: number) {
    return new Promise((resolve) => {
       setTimeout(() => {resolve(); }, msec);
    });
  }
}
