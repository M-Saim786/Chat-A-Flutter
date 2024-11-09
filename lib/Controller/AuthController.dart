import 'package:chat_app/Home.dart';
import 'package:chat_app/utils/global_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // Method to log in an existing user
  loginUser(email, password) async {
    try {
      print(email);
      print(password);
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      print(user);
      userId = user!.uid;
      print("userId $userId");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId);
      prefs.setBool("isLogin", true);
      Get.off(ContactsScreen());
    } catch (err) {
      print(err);
    }
  }

  // Method to sign up a new user and save user info in Firestore
  signUpUser(String email, String password, String name, String phone) async {
    try {
      // Create a new user with Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        // Get the user ID and store it
        userId = user.uid;
        final prefs = await SharedPreferences.getInstance();
        print("userId $userId");

        prefs.setString("userId", userId);
        prefs.setBool("isLogin", true);

        // Save the user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'createdAt': DateTime.now(),
          'uid': user.uid,
        });

        // Navigate to the ContactsScreen after successful signup
        Get.off(ContactsScreen());
      }
    } catch (err) {
      print(err);
    }
  }
}
