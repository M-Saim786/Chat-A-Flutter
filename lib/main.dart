// ignore_for_file: prefer_const_constructors

import 'package:chat_app/Home.dart';
import 'package:chat_app/Login.dart';
// import 'package:chat_app/SignupScreen.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options from firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  @override
  void initState() {
    super.initState();
    // Navigate to login page after a delay
    checkLogin();
  }

  checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool("isLogin");
    if (isLogin != null) {
      Get.off(ContactsScreen());
    } else {
      Get.to(SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInScreen(),
    );
  }
}
