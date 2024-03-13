import 'package:glitzproject/src/view/screen/signin_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:glitzproject/core/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAJKu77gyC9jKnqY8RtaNZ5423Hf08hXws',
      appId: '1:1033859424853:android:7db7c3931243ac7c92aadc',
      messagingSenderId: '1033859424853',
      projectId: 'signin-8fb6a',
      authDomain: 'signin-8fb6a.firebaseapp.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
      debugShowCheckedModeBanner: false,
      home: const SignInScreen(),
      theme: AppTheme.lightAppTheme,
    );
  }
}
