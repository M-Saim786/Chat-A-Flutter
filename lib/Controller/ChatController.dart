// import 'package:chat_app/utils/global_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  // Observable list to hold all messages
  var allMessages = <Map<String, dynamic>>[].obs;

  String generateChatId(String userId1, String userId2) {
    return (userId1.hashCode <= userId2.hashCode)
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  sendMessage(message, senderId, recieverId) async {
    try {
      // print("  senderId $senderId, recieverId $recieverId");
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      // print("userId during sendig emssge $userId");
      // print(senderId == userId ? true : false);

      final chatId = generateChatId(senderId, recieverId);
      print("dnamic chatid $chatId");
      final ref = FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .collection("message");
      ref.add({
        "message": message,
        "isSender": senderId == userId ? true : false,
        "senderId": senderId,
        "recieverId": recieverId,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (err) {
      print(err);
    }
  }

  // Fetch all messages and listen to changes
  Stream<List<Map<String, dynamic>>> getAllMessages(String recieverId) async* {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    final chatId = generateChatId(userId!, recieverId);
    print("reciever $chatId");

    yield* FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("message")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) {
      print("snapshot $snapshot");
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          "isSender": userId == data["senderId"] ? true : false,
          "text": data["message"],
          "messageType": "text",
          "messageStatus": "viewed",
        };
      }).toList();
    });
  }
}
