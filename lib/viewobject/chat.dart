// ignore_for_file: null_check_always_fails

import 'package:flutterbuyandsell/viewobject/common/ps_object.dart';
import 'package:quiver/core.dart';

class Chat extends PsObject<Chat> {
  Chat({
    this.itemId,
    this.receiverId,
    this.senderId,
  });

  String? itemId;
  String? receiverId;
  String? senderId;

  @override
  bool operator ==(dynamic other) => other is Chat && itemId == other.itemId;

  @override
  int get hashCode => hash2(itemId.hashCode, itemId.hashCode);

  @override
  String getPrimaryKey() {
    return itemId!;
  }

  @override
  List<Chat> fromMapList(List<dynamic> dynamicDataList) {
    final List<Chat> subCategoryList = <Chat>[];

    if (dynamicDataList != null) {
      for (dynamic dynamicData in dynamicDataList) {
        if (dynamicData != null) {
          subCategoryList.add(fromMap(dynamicData));
        }
      }
    }
    return subCategoryList;
  }

  @override
  Chat fromMap(dynamic dynamicData) {
    if (dynamicData != null) {
      return Chat(
        itemId: dynamicData['itemId'],
        receiverId: dynamicData['receiver_id'],
        senderId: dynamicData['sender_id'],
      );
    } else {
      return null!;
    }
  }

  @override
  List<Map<String, dynamic>> toMapList(List<Chat> objectList) {
    final List<Map<String, dynamic>> mapList = <Map<String, dynamic>>[];
    if (objectList != null) {
      for (Chat data in objectList) {
        if (data != null) {
          mapList.add(toMap(data));
        }
      }
    }
    return mapList;
  }

  @override
  Map<String, dynamic> toMap(Chat object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['itemId'] = object.itemId;
      data['receiver_id'] = object.receiverId;
      data['sender_id'] = object.senderId;
      return data;
    } else {
      return null!;
    }
  }
}
