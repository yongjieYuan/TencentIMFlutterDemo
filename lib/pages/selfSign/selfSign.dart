import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';

class SelfSign extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SelfSignState();
}

class SelfSignState extends State<SelfSign> {
  String sign = '';
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置签名'),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                onChanged: (v) {
                  setState(() {
                    sign = v;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      color: CommonColors.getThemeColor(),
                      onPressed: () async {
                        V2TimCallback res =
                            await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
                          selfSignature: sign,
                        );
                        if (res.code == 0) {
                          print("succcess");
                          Navigator.pop(context);
                        } else {
                          print(res);
                        }
                      },
                      textColor: CommonColors.getWitheColor(),
                      child: Text("确定"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
