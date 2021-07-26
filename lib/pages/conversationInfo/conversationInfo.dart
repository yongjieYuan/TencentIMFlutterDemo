import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/allMembers/allMembers.dart';
import 'package:tencent_im_sdk_plugin_example/pages/contact/chooseContact.dart';

import 'package:tencent_im_sdk_plugin_example/pages/profile/component/groupProfilePanel.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/listGap.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class ConversationInfo extends StatefulWidget {
  ConversationInfo(this.id, this.type);
  final String id;
  final int type;
  @override
  State<StatefulWidget> createState() {
    return ConversationInfoState();
  }
}

class GroupMemberProfileTitle extends StatelessWidget {
  GroupMemberProfileTitle(this.memberInfo, this.groupInfo);
  final V2TimGroupMemberInfoResult memberInfo;
  final V2TimGroupInfoResult groupInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => AllMembers(groupInfo),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(right: 10, left: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CommonColors.getBorderColor(),
                  width: 1,
                ),
              ),
            ),
            height: 40,
            child: Row(
              children: [
                Text("群成员"),
                Expanded(child: Container()),
                Text("${groupInfo.groupInfo!.memberCount}人"),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemberListOverview extends StatelessWidget {
  MemberListOverview(this.memberInfo, this.groupInfo);
  final V2TimGroupMemberInfoResult? memberInfo;
  final V2TimGroupInfoResult groupInfo;
  getShowName(V2TimGroupMemberFullInfo info) {
    String name = '';
    if (info.friendRemark != null && info.friendRemark != '') {
      name = info.friendRemark!;
      return name;
    }
    if (info.nickName != null && info.nickName != '') {
      name = info.nickName!;
      return name;
    }
    if (info.nameCard != null && info.nameCard != '') {
      name = info.nameCard!;
      return name;
    }
    if (info.userID != '') {
      name = info.userID;
      return name;
    }
    return name;
  }

  List<Widget> renderMember(context) {
    List<Widget> member = memberInfo!.memberInfoList!
        .sublist(
          0,
          memberInfo!.memberInfoList!.length > 5
              ? 5
              : memberInfo!.memberInfoList!.length,
        )
        .map(
          (e) => Container(
            child: Column(
              children: [
                Avatar(
                  width: 30,
                  height: 30,
                  avtarUrl: e!.faceUrl == '' || e.faceUrl == null
                      ? 'images/logo.png'
                      : e.faceUrl,
                  radius: 2,
                ),
                Text(
                  getShowName(e),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        )
        .toList();
    // 如果是好友工作群允许邀请好友进群
    if ((groupInfo.groupInfo!.role ==
                GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN ||
            groupInfo.groupInfo!.role ==
                GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER) &&
        groupInfo.groupInfo!.groupType == GroupType.Work) {
      member.add(
        Container(
          child: IconButton(
              icon: Icon(
                Icons.add_box,
                color: CommonColors.getTextWeakColor(),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => ChooseContact(
                      6,
                      groupInfo.groupInfo!.groupID,
                    ),
                  ),
                );
              }),
          width: 40,
          height: 40,
        ),
      );
    }
    return member;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 80,
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        children: renderMember(context),
      ),
    );
  }
}

// add(
//               Container(
//                 child: Icon(Icons.add_alarm_outlined),
//                 width: 30,
//                 height: 30,
//               ),
//             )
class GroupMemberProfile extends StatelessWidget {
  GroupMemberProfile(this.memberInfo, this.groupInfo);
  final V2TimGroupMemberInfoResult memberInfo;
  final V2TimGroupInfoResult groupInfo;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GroupMemberProfileTitle(memberInfo, groupInfo),
          MemberListOverview(memberInfo, groupInfo),
        ],
      ),
    );
  }
}

class GroupTypeAndAddInfo extends StatelessWidget {
  GroupTypeAndAddInfo(this.groupInfo);
  final V2TimGroupInfoResult? groupInfo;
  getGroupType() {
    String name = '';
    if (groupInfo!.groupInfo!.groupType == GroupType.AVChatRoom) {
      name = '直播群';
    }
    if (groupInfo!.groupInfo!.groupType == GroupType.Meeting) {
      name = '临时会议群';
    }
    if (groupInfo!.groupInfo!.groupType == GroupType.Public) {
      name = '陌生人社交群';
    }
    if (groupInfo!.groupInfo!.groupType == GroupType.Work) {
      name = '好友工作群';
    }
    return name;
  }

  getAddType() {
    int? type = groupInfo!.groupInfo!.groupAddOpt;
    String name = '';

    if (type == GroupAddOptType.V2TIM_GROUP_ADD_ANY) {
      name = '任何人可以加入';
    }
    if (type == GroupAddOptType.V2TIM_GROUP_ADD_AUTH) {
      name = '需要管理员审批';
    }
    if (type == GroupAddOptType.V2TIM_GROUP_ADD_FORBID) {
      name = '禁止加群';
    }
    return name;
  }

  getRoleType() {
    int? type = groupInfo!.groupInfo!.role;
    String name = '';
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
      name = '群管理员';
    }
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER) {
      name = '群成员';
    }
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER) {
      name = '群主';
    }
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED) {
      name = '身份未知';
    }
    return name;
  }

  bool canDissmiss() {
    String groupType = groupInfo!.groupInfo!.groupType;
    int? role = groupInfo!.groupInfo!.role;
    print(
        "groupType $groupType $role ${groupType != GroupType.Work} ${(groupType != GroupType.Work && (role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN || role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER))}");
    return (groupType == GroupType.Work &&
            role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN) ||
        (groupType != GroupType.Work &&
            (role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN ||
                role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER));
  }

  Future<bool?> showDeleteConfirmDialog(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("您确定要解散当前群组吗?"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            ElevatedButton(
              child: Text("解散"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop();
                TencentImSDKPlugin.v2TIMManager
                    .dismissGroup(groupID: groupInfo!.groupInfo!.groupID)
                    .then((res) {
                  if (res.code == 0) {
                    Utils.toast("解散群组成功");
                    Navigator.of(context).pop();
                  } else {
                    Utils.toast("解散群组失败${res.code}  ${res.desc}");
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget renderDismssGroup(context) {
    return canDissmiss()
        ? InkWell(
            onTap: () {
              showDeleteConfirmDialog(context);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: CommonColors.getBorderColor(),
                  ),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Text("解散本群"),
                ],
              ),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    if (groupInfo == null) {
      return Container();
    }

    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: CommonColors.getBorderColor(),
                  ),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Text('群身份'),
                  Expanded(
                    child: Container(),
                  ),
                  Text(getRoleType())
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: CommonColors.getBorderColor(),
                  ),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Text('群类型'),
                  Expanded(
                    child: Container(),
                  ),
                  Text(getGroupType())
                ],
              ),
            ),
          ),
          renderDismssGroup(context),
          InkWell(
            onTap: () {
              if (GroupType.Public != groupInfo!.groupInfo!.groupType) {
                Utils.toast("非public群不可更改入群方式");
                return;
              }
              if (GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER ==
                      groupInfo!.groupInfo!.role ||
                  GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED ==
                      groupInfo!.groupInfo!.role) {
                Utils.toast("非群主或者管理员");
                return;
              }
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min, // 设置最小的弹出
                      children: <Widget>[
                        new ListTile(
                          title: new Text(
                            "任何人可以加入",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: CommonColors.getThemeColor()),
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();

                            TencentImSDKPlugin.v2TIMManager
                                .getGroupManager()
                                .setGroupInfo(
                                  info: V2TimGroupInfo.fromJson(
                                    {
                                      "groupID": groupInfo!.groupInfo!.groupID,
                                      "addOpt":
                                          GroupAddOptType.V2TIM_GROUP_ADD_ANY,
                                    },
                                  ),
                                )
                                .then((value) {
                              if (value.code == 0) {
                                Utils.toast("设置成功");
                                Navigator.pop(context);
                              } else {
                                Utils.toast("${value.code} ${value.desc}");
                              }
                            });
                          },
                        ),
                        new ListTile(
                          title: new Text(
                            "需要管理员审批",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: CommonColors.getThemeColor()),
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            TencentImSDKPlugin.v2TIMManager
                                .getGroupManager()
                                .setGroupInfo(
                                  info: V2TimGroupInfo.fromJson(
                                    {
                                      "groupID": groupInfo!.groupInfo!.groupID,
                                      "addOpt":
                                          GroupAddOptType.V2TIM_GROUP_ADD_AUTH,
                                    },
                                  ),
                                )
                                .then((value) {
                              if (value.code == 0) {
                                Utils.toast("设置成功");
                                Navigator.pop(context);
                              } else {
                                Utils.toast("${value.code} ${value.desc}");
                              }
                            });
                          },
                        ),
                        new ListTile(
                          title: new Text(
                            "禁止加群",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: CommonColors.getThemeColor()),
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            TencentImSDKPlugin.v2TIMManager
                                .getGroupManager()
                                .setGroupInfo(
                                  info: V2TimGroupInfo.fromJson(
                                    {
                                      "groupID": groupInfo!.groupInfo!.groupID,
                                      "addOpt": GroupAddOptType
                                          .V2TIM_GROUP_ADD_FORBID,
                                    },
                                  ),
                                )
                                .then((value) {
                              if (value.code == 0) {
                                Utils.toast("设置成功");
                                Navigator.pop(context);
                              } else {
                                Utils.toast("${value.code} ${value.desc}");
                              }
                            });
                          },
                        )
                      ],
                    );
                  });
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Text('加群方式'),
                  Expanded(
                    child: Container(),
                  ),
                  Text(getAddType()),
                  Icon(Icons.keyboard_arrow_right_outlined)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExitGroup extends StatelessWidget {
  ExitGroup(this.groupInfo);
  final V2TimGroupInfoResult? groupInfo;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                // 先删一下会话

                V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
                    .quitGroup(groupID: groupInfo!.groupInfo!.groupID);
                V2TimCallback deleteRes = await TencentImSDKPlugin.v2TIMManager
                    .getConversationManager()
                    .deleteConversation(
                        conversationID:
                            "group_${groupInfo!.groupInfo!.groupID}");
                if (res.code == 0) {
                  Utils.toast("退出成功");
                  if (deleteRes.code == 0) {
                    print("删除会话成功");
                  } else {
                    print("删除会话失败 ${deleteRes.code} ${deleteRes.desc}");
                  }
                  Navigator.pop(context);
                } else {
                  Utils.toast("退出失败${res.code} ${res.desc} ");
                }
              },
              child: Text("删除并退出"),
            ),
          )
        ],
      ),
    );
  }
}

class ConversationInfoState extends State<ConversationInfo> {
  void initState() {
    super.initState();
    this.id = widget.id;
    this.type = widget.type;
    this.groupInfo = V2TimGroupInfoResult();
    this.memberInfo = V2TimGroupMemberInfoResult();
    this.memberInfo.memberInfoList = List.empty();
    print("当前会话id ${this.id}");
    getDetail();
  }

  late String id;
  late int type;
  late V2TimGroupInfoResult groupInfo;
  late V2TimGroupMemberInfoResult memberInfo;
  // 获取用户或者群的详细资料
  getDetail() async {
    V2TimValueCallback<List<V2TimGroupInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupsInfo(groupIDList: [id]);
    if (res.code == 0) {
      setState(() {
        groupInfo = res.data![0];
      });
    } else {
      Utils.toast("获取群信息失败 ${res.code} ${res.desc}");
    }

    print("当前用户详情${res.data![0].groupInfo!.toJson()}");
    String groupID = res.data![0].groupInfo!.groupID;
    V2TimValueCallback<V2TimGroupMemberInfoResult> list =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: groupID,
              filter: GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL,
              nextSeq: "0", //第一次从0开始拉
            );
    if (list.code == 0) {
      print(
          "list.data.memberInfoList.length:${list.data!.memberInfoList!.length}");

      setState(() {
        groupInfo = res.data![0];
        memberInfo = list.data!;
      });
    } else {
      Utils.toast("获取群成员信息失败 ${list.code} ${list.desc}");
    }
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CommonColors.getThemeColor(),
        title: Text("详细资料"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            GroupProfilePanel(groupInfo),
            ListGap(),
            GroupMemberProfile(memberInfo, groupInfo),
            ListGap(),
            GroupTypeAndAddInfo(groupInfo),
            ListGap(),
            Expanded(
              child: Container(),
            ),
            ExitGroup(groupInfo)
          ],
        ),
      ),
    );
  }
}
