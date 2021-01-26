import 'package:flutter/widgets.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/addAdvanceMsg.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/addFaceMsg.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/addTextMsg.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/addVoiceMsg.dart';

class MsgInput extends StatelessWidget {
  MsgInput(this.toUser, this.type);
  final String toUser;
  final int type;
  @override
  Widget build(BuildContext context) {
    print("toUser${toUser} ${type} ***** MsgInput");
    return Container(
      height: 55,
      child: Row(
        children: [
          VoiceMsg(toUser, type),
          TextMsg(toUser, type),
          FaceMsg(toUser, type),
          AdvanceMsg(toUser, type),
        ],
      ),
    );
  }
}
