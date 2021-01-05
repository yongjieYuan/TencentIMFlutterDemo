import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

class ConversionModel with ChangeNotifier, DiagnosticableTreeMixin {
  List<V2TimConversation> _conversionList = new List<V2TimConversation>();
  get conversionList => _conversionList;
  setConversionList(List<V2TimConversation> newList) {
    newList.forEach((element) {
      String cid = element.conversationID;
      if (_conversionList.any((ele) => ele.conversationID == cid)) {
        for (int i = 0; i < _conversionList.length; i++) {
          if (_conversionList[i].conversationID == cid) {
            conversionList[i] = element;
            break;
          }
        }
      } else {
        _conversionList.add(element);
      }
    });
    _conversionList.sort((left, right) =>
        right.lastMessage.timestamp.compareTo(left.lastMessage.timestamp));
    notifyListeners();
    return _conversionList;
  }

  removeConversionByConversationId(String conversionId) {
    _conversionList
        .removeWhere((element) => element.conversationID == conversionId);
    notifyListeners();
  }

  clear() {
    _conversionList = new List<V2TimConversation>();
    notifyListeners();
    return _conversionList;
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('conversionList', conversionList));
  }
}
