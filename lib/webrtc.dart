import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_webrtc/flutter_webrtc.dart' ;

class WebrtcPage extends StatefulWidget {
  WebrtcPage({super.key, required this.title});

  final String title;

  late IO.Socket socket;

  @override
  State<WebrtcPage> createState() => _WebrtcPage();
}

class _WebrtcPage extends State<WebrtcPage> {
  late final IO.Socket socket;
  final _locarRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? pc;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future init() async{
    await _locarRenderer.initialize();
    await _remoteRenderer.initialize();

    await connectSocket();
  }

  Future connectSocket() async{
    socket = IO.io('http://192.168.200.197:3002', IO.OptionBuilder().setTransports(['websocket']).build() );
    socket.onConnect((data) => print("connected") );

    socket.on('offer', (offer) async {
      print(' >>>> offer event arrived');
      print(' offer.sdp ${offer['sdp']}');
      print(' offer.type ${offer['type']}');
      // try{
      //   offer = jsonDecode(offer);
      // } catch(e) {
      //   print('>>>> offer : jsonDecode error $offer');
      // }

      await _gotOffer(RTCSessionDescription(offer['sdp'], offer['type']));
      await _sendAnswer();
    });

    // socket.on('answer', (answer) async{
    //   print('answer event arrived');
    //   answer = jsonDecode(answer);
    //   await _gotAnswer(RTCSessionDescription(answer['sdp'], answer['type']));
    // });

    socket.on('ice', (ice) {
      print('>>>> ice event arrived, $ice');
      _gotIce(RTCIceCandidate(
        ice['candidate'],
        ice['sdpMid'],
        ice['sdpMLineIndex'],
      ));
    });

    // socket.on('create_room_result', (data) {
    //   print(' >>>> create_room_result event arrived');
    //   _sendOffer();
    // });

    // socket.on('all_users', (data) {
    //   print('csr_joined event arrived');
    //   _sendOffer();
    // });

  }

  Future joinWebrtc() async {
    final config = {
      'iceservers' : [
        {"url" : "stun:stun.l.google.com:19302"},
      ]
    };

    final sdpConstraints = {
      'mandatory' : {
        'OfferToReceiveAudio' : true,
        'OfferToReceiveVideo' : true
      },
      'optional' : [],
    };

    pc = await createPeerConnection(config, sdpConstraints);
    print(' >>>>  createPeerConnection');

    final mediaConstraints = {
      'audio' : true,
      // 'video' : {
      //   'facingMode' : 'user',
      // }
    };

    _localStream = await Helper.openCamera(mediaConstraints);
    print('$_localStream');

    //await Future.delayed(const Duration(seconds: 1));

    // Refine video constraints based on desired values
    // final refinedConstraints = {
    //   'audio': true,
    //   'video': {
    //     'facingMode': 'user',
    //     'width': {'min': 256, 'ideal': 256},
    //     'height': {'min': 190, 'ideal': 144},
    //   },
    // };

    _localStream?.getTracks().forEach((track) {
      pc?.addTrack(track, _localStream!);
    });
    print('>>>>  localStream $_localStream');

    setState( () {
      _locarRenderer.srcObject = _localStream;
    });

    print('>>>>  _locarRenderer  $_locarRenderer');

    pc!.onIceCandidate = (ice){
      _sendIce(ice);
      print('sending Ice, $ice');
    };


    pc!.onTrack = (event) {
      print('pc on Add remote stream, $event');
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
    };

  }

  // Future _sendOffer() async {
  //   var offer = await pc?.createOffer();
  //   pc!.setLocalDescription(offer!);
  //   print('>>>>  sendOffer executed $offer');
  //   socket.emit('offer', jsonEncode(offer!.toMap()));
  // }

  Future _gotOffer(RTCSessionDescription rtcSessionDescription) async {
    print('>>>>  gotOffer executed setting remoteDescripton, $rtcSessionDescription');
    pc!.setRemoteDescription(rtcSessionDescription);
  }

  Future _sendAnswer() async {
    var answer = await pc!.createAnswer();
    pc!.setLocalDescription(answer!);
    print('>>>>  sendAnwser executed $answer');
    socket.emit('answer', jsonEncode(answer!.toMap()));
  }

  // Future _gotAnswer(RTCSessionDescription rtcSessionDescription) async {
  //   print('>>>>  gotAnwser executed, $rtcSessionDescription');
  //   pc!.setRemoteDescription(rtcSessionDescription);
  // }

  Future _sendIce(RTCIceCandidate ice) async {
    print('>>>>  sendIce executed $ice');
    socket.emit('ice', jsonEncode(ice.toMap()));
  }

  Future _gotIce(RTCIceCandidate rtcIceCandidate) async {
    print('>>>>  gotIce executed $rtcIceCandidate');
    pc!.addCandidate(rtcIceCandidate);
  }

  void _toPrevious() async {
    await disconnectSocket();
    if (mounted) Navigator.pop(context);
  }
  
  // void _enter() async {
  //   socket.emit('create_room', '01031795981');
  //   await joinWebrtc();
  // }
  
  void  _join() async {
    socket.emit('join_room', 'aaa');
    await joinWebrtc();
  }


  Future disconnectSocket() async{
    socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home : Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Center(
            child : Row(
              children: [
                Expanded(child: RTCVideoView(_locarRenderer)),
                Expanded(child: RTCVideoView(_remoteRenderer))
              ],
            )
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children:[
                ElevatedButton(
                    onPressed: _toPrevious,
                    child: const Text('돌아가기')
                ),
                // ElevatedButton(
                //     onPressed: _enter,
                //     child: const Text('입장')
                // ),
                ElevatedButton(
                    onPressed: _join,
                    child: const Text('참가')
                ),
              ],
            ),
          ),
        )
    );
  }
}