// import 'dart:ui';

// Function HexToColor(color) {
//   return Color(int.parse('111111', radix: 16)).withAlpha(255);
// }

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:toast/toast.dart';
import 'package:flutter_apns/flutter_apns.dart';

class Tools {
  static final PushConnector connector = createPushConnector();

  static setOfflinepush(BuildContext context) async {
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
      const bool isReleaseMode = bool.fromEnvironment("dart.vm.product");

      final connector = Tools.connector;
      connector.configure();
      connector.requestNotificationPermissions();
      connector.token.addListener(() async {
        print('Token ${connector.token.value}');

        // V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.getAPNSManager().setAPNS(
        //   businessID: isReleaseMode ? 24438 : 23945,
        //   token: connector.token.value
        // );

        // if (res.code == 0) {
        //   Toast.show("设置推送成功", context);
        // } else {
        //   Toast.show("设置推送失败${res.desc}", context);
        // }
      });
    }
  }
}
