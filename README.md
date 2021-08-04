# 腾讯云即时通信IM flutter demo

- #### 在腾讯云即时通信IM控制台创建应用
 使用Demo前请先配置`sdkappid`,`secret`,需到[腾讯云控制台](https://cloud.tencent.com/product/im)注册账号，创建应用.拿到所需的sdkappid和secret

- #### 运行demo

```
flutter run --dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID） --dart-define=KEY=xxxx（xxxx是你自己申请的密钥）
```
如需使用手机验证码登陆请再添加：--dart-define=ISPRODUCT_ENV=true

- #### 修改配置（可选）

目录：/example/lib/utils/config
这里配置了环境变量，建议通过运行环境时添加对应配置信息，上面运行demo就是这里配置的，要想直接写死也可

- ### 若要使用vs的调试工具
请在launch.json中添加环境参数
```
"args": [
            "--dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID）",
            "--dart-define=KEY=xxxx（xxxx是你自己申请的密钥）"
        ]
```

PS: 若出现白屏无法启动的情况，可能是SDK_APPID填写错误 请检查

