import 'package:chat_app/utils/global_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  var allUsers = [].obs;

  // Function to get all users excluding the currently logged-in user
  getAllUsers() async {
    try {
      print("Fetching all users...");

      // Get the current logged-in user's UID
      var currentUserId = await FirebaseAuth.instance.currentUser?.uid;
      print("currentUserId $currentUserId");
      current_userId = currentUserId;
      // Fetch all users from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection("users").get();

      // Filter users and exclude the logged-in user
      allUsers.value = snapshot.docs
          .map((doc) {
            var data = doc.data();
            // Check if the user id is not the logged-in user's id
            if (data['uid'] != currentUserId) {
              print("User data: $data");
              return data; // Store each user document data in the list if not logged-in user
            }
            return null;
          })
          .where((user) => user != null)
          .toList(); // Remove null values

      print("All users excluding the logged-in user: $allUsers");
    } catch (err) {
      print("Error: $err");
    }
  }
}
