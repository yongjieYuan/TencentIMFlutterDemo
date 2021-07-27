import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class SoundMessage extends StatefulWidget {
  SoundMessage(this.message);

  final V2TimMessage message;

  @override
  State<StatefulWidget> createState() => SoundMessageState();
}

class SoundMessageState extends State<SoundMessage> {
  bool isPlay = false;
  AudioPlayer audioPlayer = AudioPlayer();
  //实例化对象
  FlutterPluginRecord recordPlugin = new FlutterPluginRecord();
  void initState() {
    super.initState();
    AudioPlayer.logEnabled = true;
    recordPlugin.responsePlayStateController.listen((data) {
      if (data.playState == 'complete') {
        setState(() {
          isPlay = false;
        });
      }
    });
    //    初始化
    recordPlugin.init();
  }

  play() async {
    String? url = widget.message.soundElem!.url;
    if (url != null) {
      setState(() {
        isPlay = !isPlay;
      });
      print("语音地址$url");
      int result = await audioPlayer.play(url);
      if (result == 1) {
        // success
        print("成功了");
      }
      // recordPlugin.playByPath(url, "m4a");
    }
  }

  void deactivate() {
    super.deactivate();
    print("sound message deactivate call ${widget.message.msgID}");
    recordPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        play();
      },
      child: Container(
        child: Row(
          children: [
            Icon(Icons.volume_up),
            Text(isPlay ? '正在播放...' : '点击播放'),
            Expanded(
              child: Container(),
            ),
            Text(" ${widget.message.soundElem!.duration} s")
          ],
        ),
      ),
    );
  }
}
