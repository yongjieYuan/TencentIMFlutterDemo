import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversationInfo/conversationInfo.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/conversationInner.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/msgInput.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_example/pages/userProfile/userProfile.dart';
import 'package:tencent_im_sdk_plugin_example/provider/currentMessageList.dart';

class Conversion extends StatefulWidget {
  Conversion(this.conversationID);
  final String conversationID;
  @override
  State<StatefulWidget> createState() => ConversionState(conversationID);
}

class ConversionState extends State<Conversion> {
  String conversationID;
  int type = 1;
  String lastMessageId = '';
  String userID = '';
  String groupID = '';
  List<V2TimMessage> msgList = [];

  Icon righTopIcon;
  bool isreverse = true;
  List<V2TimMessage> currentMessageList = new List<V2TimMessage>();
  ConversionState(this.conversationID);

  void initState() {
    super.initState();

    getConversion();
  }

  openProfile(context) {
    String id = type == 1 ? userID : groupID;
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) =>
            type == 1 ? UserProfile(id) : ConversationInfo(id, type),
      ),
    );
  }

  getConversion() async {
    V2TimValueCallback<V2TimConversation> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    String _msgID;
    int _type;
    String _groupID;
    String _userID;

    if (data.code == 0) {
      _msgID = data.data.lastMessage.msgID;
      _type = data.data.type;
      _groupID = data.data.groupID;
      _userID = data.data.userID;
      print("_type ${_type}");
      print('_userID ${_userID}');
      print('_groupID ${_groupID}');
      setState(() {
        type = _type;
        lastMessageId = _msgID;
        groupID = _groupID;
        userID = _userID;
        righTopIcon = _type == 1
            ? Icon(
                Icons.account_box,
                color: CommonColors.getWitheColor(),
              )
            : Icon(
                Icons.supervisor_account,
                color: CommonColors.getWitheColor(),
              );
      });
    }

    //判断会话类型，c2c or group

    if (_type == 1) {
      // c2c
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(
            userID: _userID,
            count: 100,
          )
          .then((listRes) {
        if (listRes.code == 0) {
          List<V2TimMessage> list = listRes.data;
          if (list == null || list.length == 0) {
            print('没有消息啊！！！');
            list = new List<V2TimMessage>();
          }
          print("conversationID $conversationID 消息数量 ${listRes.data.length}");
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(conversationID, list);
        } else {
          print('conversationID 获取历史消息失败 ${listRes.desc}');
        }
      });
    } else if (_type == 2) {
      // group
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getGroupHistoryMessageList(
            groupID: _groupID,
            count: 100,
          )
          .then((listRes) {
        if (listRes.code == 0) {
          print(
              "conversationID listRes.data ${listRes.data.length} $_groupID ");
          List<V2TimMessage> list = listRes.data;
          if (list == null || list.length == 0) {
            print('conversationID 没有消息啊！！！');
            list = new List();
          } else {
            Provider.of<CurrentMessageListModel>(context, listen: false)
                .addMessage(conversationID, list);
          }
          print("conversationID ${conversationID} 消息数量 ${listRes.data.length}");
        } else {
          print('conversationID 获取历史消息失败');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("会话"),
        backgroundColor: CommonColors.getThemeColor(),
        actions: [
          IconButton(
            icon: righTopIcon,
            onPressed: () {
              openProfile(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ConversationInner(conversationID, type, userID, groupID),
          ),
          type == 0
              ? Container()
              : MsgInput(type == 1 ? userID : groupID, type),
          Container(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }
}
