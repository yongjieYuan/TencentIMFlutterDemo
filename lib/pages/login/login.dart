import 'dart:io';
import 'dart:ui';
// import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_progress.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';

import 'package:tencent_im_sdk_plugin_example/pages/home/home.dart';
import 'package:tencent_im_sdk_plugin_example/provider/conversion.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_example/provider/currentMessageList.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friend.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friendApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/groupApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/user.dart';
import 'package:tencent_im_sdk_plugin_example/utils/GenerateTestUserSig.dart';
import 'package:tencent_im_sdk_plugin_example/utils/config.dart';
// import 'package:tencent_tpns_oppo_push_plugin/enum/importance.dart';
// import 'package:tencent_tpns_oppo_push_plugin/tencent_tpns_oppo_push_plugin.dart';
// import 'package:tencent_tpns_vivo_push_plugin/tencent_tpns_vivo_push_plugin.dart';
// import 'package:tencent_tpns_xiaomi_push_plugin/tencent_tpns_xiaomi_push_plugin.dart';
import 'package:toast/toast.dart';

var timLogo = AssetImage("images/logo.png");

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isinit = false;
  String oppoRegId;

  void initState() {
    super.initState();
    init();
  }

  init() async {
    await initSDK();
    await islogin();
    // await toHomePage();
    await setOfflinepush();
  }

  offlinePushCallback(data) {
    if (data['name'] == 'onRegister') {
      if (data['responseCode'] == 0) {
        setState(() {
          oppoRegId = data['data'];
        });
        TencentImSDKPlugin.v2TIMManager
            .getOfflinePushManager()
            .setOfflinePushConfig(businessID: 7005, token: data['data'])
            .then((res) {
          if (res.code == 0) {
            Toast.show("设置推送成功", context);
          } else {
            Toast.show("设置推送失败${res.desc}", context);
          }
        }).catchError((err) {
          Toast.show("设置推送失败$err", context);
          print("设置推送失败$err");
        });
      }
    }
  }

  setOfflinepush() async {
    if (Platform.isAndroid) {
      // DeviceInfoPlugin info = new DeviceInfoPlugin();
      // AndroidDeviceInfo androidInfo = await info.androidInfo;
      // print("androidInfo.brand ${androidInfo.brand}");
      // String brand = androidInfo.brand;
      // switch (brand) {
      //   case 'google':
      //     break;
      //   case 'xiaomi':
      //     initXiaomiPush();
      //     break;
      //   case 'OPPO':
      //     initOppoPush();
      //     break;
      //   case 'vivo':
      //     // initVivoPush();
      //     break;
      // }
    } else {
      V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
          .getAPNSManager()
          .setAPNS(businessID: 23945);
      if (res.code == 0) {
        Toast.show("设置推送成功", context);
      } else {
        Toast.show("设置推送失败${res.desc}", context);
      }
    }
  }

  // initVivoPush() async {
  //   TencentTpnsVivoPushPlugin.initialize();
  //   String regId = await TencentTpnsVivoPushPlugin.getRegId();
  //   print('regId$regId');
  // }

  // initXiaomiPush() async {
  //   TencentTpnsXiaomiPushPlugin.registerPush(
  //     appID: "2882303761518516314",
  //     appToken: "5141851613314",
  //   );
  //   String regId = await TencentTpnsXiaomiPushPlugin.getRegId();
  //   TencentTpnsXiaomiPushPlugin.enablePush();
  //   if (regId.isNotEmpty) {
  //     TencentImSDKPlugin.v2TIMManager
  //         .getOfflinePushManager()
  //         .setOfflinePushConfig(businessID: 5218, token: regId)
  //         .then((res) {
  //       if (res.code == 0) {
  //         Toast.show("设置推送成功", context);
  //       } else {
  //         Toast.show("设置推送失败${res.desc}", context);
  //       }
  //     }).catchError((err) {
  //       Toast.show("设置推送失败$err", context);
  //       print("设置推送失败$err");
  //     });
  //   } else {
  //     Toast.show("获取小米regid失败", context);
  //   }
  // }

  // initOppoPush() async {
  //   TencentTpnsOppoPushPlugin.init(needLog: true);
  //   TencentTpnsOppoPushPlugin.setCallback(callback: offlinePushCallback);
  //   bool isSupport = await TencentTpnsOppoPushPlugin.isSupportPush();
  //   if (isSupport) {
  //     TencentTpnsOppoPushPlugin.createNotificationChannel(
  //       channel: "tuikit",
  //       name: "test",
  //       description: "test description",
  //       importance: Importance.IMPORTANCE_HIGH,
  //     );
  //     TencentTpnsOppoPushPlugin.register(
  //       appKey: "cf080880fc9747cf8f09baa6d806fb85",
  //       appSecret: "75bb981450bc4753b93b1978fd014c95",
  //     );
  //     TencentTpnsOppoPushPlugin.resumePush();
  //   }
  // }

  // TODO: 调试代码，上线删除
  // toHomePage() async {
  //   const userId = "lexuslin";
  //   const userSig =
  //       "eJwtzE8LgjAcxvH3smthv003-0CHwIpo0CG7dSm24pfOpjMxoveeqcfn88D3QzJ59Fpdk4QwD8h82Kh02eANBy5093IFltPnVH6xFhVJaABAo9DnbHx0Z7HWvXPOGQCM2qD5mwAR0ihi4VTBe59W6Xof680OjTPPoArUtfJnPEMpVwdGY3ifFyexfeRpK92SfH8q-zJ8";
  //   V2TimCallback data = await TencentImSDKPlugin.v2TIMManager.login(
  //     userID: userId,
  //     userSig: userSig,
  //   );

  //   V2TimCallback data2 = await TencentImSDKPlugin.v2TIMManager
  //       .getAPNSManager()
  //       .setAPNS(businessID: 23945);

  //   V2TimValueCallback<List<V2TimUserFullInfo>> infos = await TencentImSDKPlugin
  //       .v2TIMManager
  //       .getUsersInfo(userIDList: [userId]);
  //   Provider.of<UserModel>(context, listen: false).setInfo(infos.data[0]);

  //   Navigator.push(
  //     context,
  //     new MaterialPageRoute(
  //       builder: (context) => HomePage(),
  //     ),
  //   );
  // }

  islogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String token = prefs.getString("token");
    String sessionId = prefs.getString("sessionId");
    String phone = prefs.getString("phone");
    String code = prefs.getString("code");
    print("token$token");
    print("sessionId$sessionId");
    print("phone$phone");
    print("code$code");
    if (token != null && sessionId != null && phone != null && code != null) {
      Dio dio = new Dio();
      Response response = await dio.get(
        "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms",
        queryParameters: {
          "phone": "86$phone",
          "method": "login",
          "sessionId": sessionId,
          "token": token,
          "code": code
        },
      );
      print(response);
      if (response.data['errorCode'] == 0) {
        //登录成功
        String userId = response.data['data']['userId'];
        String userSig = response.data['data']['userSig'];
        String avatar = response.data['data']['avatar'];

        V2TimCallback data = await TencentImSDKPlugin.v2TIMManager.login(
          userID: userId,
          userSig: userSig,
        );

        if (data.code != 0) {
          print('登录失败${data.desc}');
          setState(() {
            isinit = true;
          });
          return;
        } else {
          print("登录成功");
        }

        // await Tools.setOfflinepush(context);

        V2TimValueCallback<List<V2TimUserFullInfo>> infos =
            await TencentImSDKPlugin.v2TIMManager
                .getUsersInfo(userIDList: [userId]);
        if (infos.code == 0) {
          if (infos.data[0].nickName == null ||
              infos.data[0].faceUrl == null ||
              infos.data[0].nickName == '' ||
              infos.data[0].faceUrl == '') {
            await TencentImSDKPlugin.v2TIMManager
                .setSelfInfo(nickName: userId, faceUrl: avatar);
          }
          Provider.of<UserModel>(context, listen: false).setInfo(infos.data[0]);
        } else {}
        try {
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) {
                return HomePage();
              },
            ),
          );
        } catch (err) {
          print(err);
        }
      } else {}
    } else {}
    setState(() {
      isinit = true;
    });
  }

  listener(data) async {
    print("init sdk listener emit");
    print(data.type);
    if (data.type == 'onSelfInfoUpdated') {
      //自己信息更新，从新获取自己的信息；
      V2TimValueCallback<String> usercallback =
          await TencentImSDKPlugin.v2TIMManager.getLoginUser();
      V2TimValueCallback<List<V2TimUserFullInfo>> infos =
          await TencentImSDKPlugin.v2TIMManager
              .getUsersInfo(userIDList: [usercallback.data]);
      if (infos.code == 0) {
        Provider.of<UserModel>(context, listen: false).setInfo(infos.data[0]);
      }
    }
    if (data.type == 'onKickedOffline') {
      // 被踢下线
      // 清除本地缓存，回到登录页TODO
      try {
        Provider.of<ConversionModel>(context, listen: false).clear();
        Provider.of<UserModel>(context, listen: false).clear();
        Provider.of<CurrentMessageListModel>(context, listen: false).clear();
        Provider.of<FriendListModel>(context, listen: false).clear();
        Provider.of<FriendApplicationModel>(context, listen: false).clear();
        Provider.of<GroupApplicationModel>(context, listen: false).clear();
        // 去掉存的一些数据
        Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
        SharedPreferences prefs = await _prefs;
        prefs.remove('token');
        prefs.remove('sessionId');
        prefs.remove('phone');
        prefs.remove('code');
      } catch (err) {
        print("someError");
        print(err);
      }
      print("被踢下线了");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        ModalRoute.withName('/'),
      );
    }
  }

  groupListener(data) async {
    print("groupListener emit");
    print(data.type);
    if (data.type == 'onReceiveJoinApplication' ||
        data.type == 'onMemberEnter') {
      //新加群申请
      V2TimValueCallback<V2TimGroupApplicationResult> res =
          await TencentImSDKPlugin.v2TIMManager
              .getGroupManager()
              .getGroupApplicationList();
      if (res.code == 0) {
        if (res.code == 0) {
          if (res.data.groupApplicationList.length > 0) {
            Provider.of<GroupApplicationModel>(context, listen: false)
                .setGroupApplicationResult(res.data.groupApplicationList);
          }
        }
      } else {
        print("获取加群申请失败${res.desc}");
      }
    } else if (data.type == 'onQuitFromGroup') {}
  }

  advancedMsgListener(data) {
    print("advancedMsgListener emit");
    print(data.type);
    if (data.type == 'onRecvNewMessage') {
      try {
        List<V2TimMessage> messageList = new List<V2TimMessage>();
        V2TimMessage message;
        message = data.data;
        messageList.add(message);

        print("c2c_${message.sender}");
        String key;
        if (message.groupID == null) {
          key = "c2c_${message.sender}";
        } else {
          key = "group_${message.groupID}";
        }
        print("conterkey_$key");
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addMessage(key, messageList);
      } catch (err) {
        print(err);
      }
    }
    if (data.type == 'onRecvC2CReadReceipt') {
      print('收到了新消息 已读回执');
      List<V2TimMessageReceipt> list = data.data;
      list.forEach((element) {
        print("已读回执${element.userID} ${element.timestamp}");
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .updateC2CMessageByUserId(element.userID);
      });
    }
    if (data.type == 'onRecvMessageRevoked') {
      //消息撤回 TODO
    }
    if (data.type == 'onSendMessageProgress') {
      //消息进度
      MessageProgress msgPro = data.data;
      V2TimMessage message = msgPro.message;
      String key;
      if (message.groupID == null) {
        key = "c2c_${message.userID}";
      } else {
        key = "group_${message.groupID}";
      }
      try {
        Provider.of<CurrentMessageListModel>(
          context,
          listen: false,
        ).addOneMessageIfNotExits(
          key,
          message,
        );
      } catch (err) {
        print("error $err");
      }
      print(
          "消息发送进度 ${msgPro.progress} ${message.timestamp} ${message.msgID} ${message.timestamp} ${message.status}");
    }
  }

  friendListener(data) async {
    print("friendListener emit");
    String type = data.type;
    if (type == 'onFriendListAdded' ||
        type == 'onFriendListDeleted' ||
        type == 'onFriendInfoChanged' ||
        type == 'onBlackListDeleted') {
      //好友加成功了，删除好友 重新获取好友
      V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
          await TencentImSDKPlugin.v2TIMManager
              .getFriendshipManager()
              .getFriendList();
      if (friendRes.code == 0) {
        List<V2TimFriendInfo> newList = friendRes.data;
        if (newList != null && newList.length > 0) {
          Provider.of<FriendListModel>(context, listen: false)
              .setFriendList(newList);
        } else {
          Provider.of<FriendListModel>(context, listen: false)
              .setFriendList(new List<V2TimFriendInfo>());
        }
      }
    }
    if (type == 'onFriendApplicationListAdded') {
      // 收到加好友申请,添加双向好友时双方都会周到这个回调，这时要过滤掉type=2的不显示
      List<V2TimFriendApplication> list = data.data;
      print("收到加好友申请");
      List<V2TimFriendApplication> newlist = new List<V2TimFriendApplication>();
      list.forEach((element) {
        if (element.type != 2) {
          newlist.add(element);
        }
      });
      if (newlist.isNotEmpty) {
        Provider.of<FriendApplicationModel>(context, listen: false)
            .setFriendApplicationResult(newlist);
      }
    }
    print(data.type);
  }

  Map<String, V2TimConversation> conversationlistToMap(
      List<V2TimConversation> list) {
    Map<int, V2TimConversation> convsersationMap = list.asMap();
    Map<String, V2TimConversation> newConversation = new Map();
    convsersationMap.forEach((key, value) {
      newConversation[value.conversationID] = value;
    });
    return newConversation;
  }

  conversationListener(data) {
    String type = data.type;

    if (type == 'onNewConversation' || type == 'onConversationChanged') {
      print("$type emit");
      try {
        List<V2TimConversation> list = data.data;

        Provider.of<ConversionModel>(context, listen: false)
            .setConversionList(list);
        //如果当前会话在使用中，也更新一下

      } catch (e) {}
    } else {
      print("$type emit but no nerver use");
    }
  }

  signalingListener(data) {
    print("signalingListener emit");
    // print(data);
  }

  simpleMsgListener(data) {
    //这里区分消息
    print("simpleMsgListener emit");

    print(data.type);
  }

  initSDK() async {
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    await timManager.initSDK(
      sdkAppID: Config.sdkappid,
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: listener,
    );

    print("initSDK");

    //简单监听
    timManager.addSimpleMsgListener(
      listener: simpleMsgListener,
    );

    //群组监听
    timManager.setGroupListener(
      listener: groupListener,
    );
    //高级消息监听
    timManager.getMessageManager().addAdvancedMsgListener(
          listener: advancedMsgListener,
        );
    //关系链监听
    timManager.getFriendshipManager().setFriendListener(
          listener: friendListener,
        );
    //会话监听
    timManager.getConversationManager().setConversationListener(
          listener: conversationListener,
        );
    timManager.getSignalingManager().addSignalingListener(
          listener: signalingListener,
        );
    print("初始化完成了");
  }

  @override
  Widget build(BuildContext context) {
    return (!isinit) ? new WaitHomeWidget() : new HomeWidget();
  }
}

class WaitHomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WaitHomeWidgetState();
}

class WaitHomeWidgetState extends State<WaitHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new AppLayout(),
    );
  }
}

class AppLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(),
        Expanded(
          child: LoginForm(),
        )
      ],
    );
  }
}

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192.0,
      color: CommonColors.getThemeColor(),
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        top: 108.0,
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 90,
            width: 90,
            child: Image(
              image: timLogo,
              width: 90.0,
              height: 90.0,
            ),
          ),
          Container(
            height: 90.0,
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  '登录·即时通信',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 28,
                  ),
                ),
                Text(
                  '体验群组聊天，音视频对话等IM功能',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 12,
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          )
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  void initState() {
    super.initState();
  }

  bool isGeted = false;
  String tel = '';
  String pwd = '';
  int timer = 60;
  String token = '';
  String sessionId = '';
  TextEditingController userSigEtController = TextEditingController();
  TextEditingController telEtController = TextEditingController();
  void getHttp() async {
    try {
      Response response = await Dio().get(
        "https://service-qr8jjnpm-1256635546.gz.apigw.tencentcs.com/release/getUserSig?userId=xingchenhe",
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }

  timeDown() {
    new Future.delayed(const Duration(milliseconds: 1000), () {
      if (timer == 0) {
        setState(() {
          timer = 60;
          isGeted = false;
        });
        return;
      }
      setState(() {
        timer = --timer;
      });
      timeDown();
    });
  }

  void getLoginCode(context) async {
    if (tel.length == 0) {
      Toast.show(
        "请输入正确的手机号码",
        context,
        duration: Toast.LENGTH_SHORT,
        gravity: Toast.TOP,
      );
    } else {
      Dio dio = new Dio();
      Response response = await dio.get(
        "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms",
        queryParameters: {
          "phone": "86${this.tel}",
          "method": "getSms",
        },
      );
      print(response);
      try {
        if (response.data['errorCode'] == 0) {
          print(response.data['data']['sessionId']);
        }
        setState(() {
          isGeted = true;
          sessionId = response.data['data']['sessionId'];
        });
        timeDown();
      } catch (err) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Form(
        child: Column(
          children: [
            TextField(
              autofocus: false,
              controller: telEtController,
              decoration: InputDecoration(
                labelText: "用户名",
                hintText: "请输入用户名",
                icon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                setState(() {
                  tel = v;
                });
              },
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: userSigEtController,
            //         decoration: InputDecoration(
            //           labelText: "验证码",
            //           hintText: "请输入验证码",
            //           icon: Icon(Icons.lock),
            //         ),
            //         keyboardType: TextInputType.number,
            //         //校验密码
            //         onChanged: (v) {
            //           setState(() {
            //             pwd = v;
            //           });
            //         },
            //       ),
            //     ),
            //     Container(
            //       width: 120,
            //       child: RaisedButton(
            //         child: isGeted ? Text(timer.toString()) : Text("获取验证码"),
            //         color: CommonColors.getThemeColor(),
            //         textColor: Colors.white,
            //         onPressed: isGeted
            //             ? null
            //             : () {
            //                 //获取验证码
            //                 getLoginCode(context);
            //               },
            //       ),
            //     )
            //   ],
            // ),
            Container(
              margin: EdgeInsets.only(
                top: 28,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      padding: EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                      ),
                      child: Text("登录"),
                      color: CommonColors.getThemeColor(),
                      textColor: Colors.white,
                      onPressed: () async {
                        if (tel == '') {
                          return;
                        }
                        GenerateTestUserSig usersig = new GenerateTestUserSig(
                          sdkappid: Config.sdkappid,
                          key: Config.key,
                        );
                        String pwdStr =
                            usersig.genSig(identifier: tel, expire: 86400);
                        TencentImSDKPlugin.v2TIMManager
                            .login(
                          userID: tel,
                          userSig: pwdStr,
                        )
                            .then((res) async {
                          if (res.code == 0) {
                            V2TimValueCallback<List<V2TimUserFullInfo>> infos =
                                await TencentImSDKPlugin.v2TIMManager
                                    .getUsersInfo(userIDList: [tel]);

                            if (infos.code == 0) {
                              Provider.of<UserModel>(context, listen: false)
                                  .setInfo(infos.data[0]);
                            }
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          } else {
                            Toast.show("${res.code} ${res.desc}", context);
                          }
                        });
                        if (pwd == '') {
                          return;
                        }
                        // 获取userSig
                        Dio dio = new Dio();
                        Response response = await dio.get(
                          "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms",
                          queryParameters: {
                            "phone": "86${this.tel}",
                            "method": "login",
                            "code": pwd,
                            "sessionId": sessionId,
                          },
                        );

                        String userId = response.data['data']['userId'];
                        String userSig = response.data['data']['userSig'];
                        String token = response.data['data']['token'];
                        String avatar = response.data['data']['avatar'];
                        print(response);
                        if (response.data['errorCode'] != 0) {
                          Toast.show(
                            response.data['errorMessage'],
                            context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.TOP,
                          );
                          return;
                        } else {
                          setState(() {
                            token = token;
                          });
                        }
                        var data = await TencentImSDKPlugin.v2TIMManager.login(
                          userID: userId,
                          userSig: userSig,
                        );

                        if (data.code != 0) {
                          print('登录失败${data.desc}');
                          return;
                        }

                        // await Tools.setOfflinepush(context);

                        Future<SharedPreferences> _prefs =
                            SharedPreferences.getInstance();
                        SharedPreferences prefs = await _prefs;
                        prefs.setString("sessionId", sessionId);
                        prefs.setString("token", token);
                        prefs.setString("phone", tel);
                        prefs.setString("code", pwd);
                        V2TimValueCallback<List<V2TimUserFullInfo>> infos =
                            await TencentImSDKPlugin.v2TIMManager
                                .getUsersInfo(userIDList: [userId]);

                        if (infos.code == 0) {
                          if (infos.data[0].nickName == null ||
                              infos.data[0].faceUrl == null ||
                              infos.data[0].nickName == '' ||
                              infos.data[0].faceUrl == '') {
                            await TencentImSDKPlugin.v2TIMManager
                                .setSelfInfo(nickName: userId, faceUrl: avatar);
                          }
                          Provider.of<UserModel>(context, listen: false)
                              .setInfo(infos.data[0]);
                        }
                        setState(() {
                          tel = '';
                          pwd = '';
                          timer = 60;
                          isGeted = false;
                        });
                        userSigEtController.clear();
                        telEtController.clear();
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
