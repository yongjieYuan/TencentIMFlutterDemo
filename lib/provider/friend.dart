import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class FriendListModel with ChangeNotifier, DiagnosticableTreeMixin {
  List<V2TimFriendInfo> _friendList = new List<V2TimFriendInfo>();
  get friendList => _friendList;
  setFriendList(newLst) {
    _friendList = newLst;
    notifyListeners();
    return _friendList;
  }

  clear() {
    _friendList = new List<V2TimFriendInfo>();
    notifyListeners();
    return _friendList;
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('friendList', friendList));
  }
}
