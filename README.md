# 腾讯云即时通信IM flutter demo

- #### 在腾讯云即时通信IM控制台创建应用



- #### 修改配置

目录：/example/lib/utils/config
这里配置了环境变量，建议通过运行环境时添加对应配置信息

- #### 运行demo

```
flutter run --dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID） --dart-define=KEY=xxxx（xxxx是你自己申请的密钥）
```


- ### 若要使用vs的调试工具
请在launch.json中添加环境参数
```
"args": [
            "--dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID）",
            "--dart-define=KEY=xxxx（xxxx是你自己申请的密钥）"
        ]
```

PS: 若出现白屏无法启动的情况，可能是SDK_APPID填写错误 请检查

