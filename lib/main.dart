import 'package:animation_and_notes/firebase_options.dart';
import 'package:animation_and_notes/helper/helper_function.dart';
import 'package:animation_and_notes/screens/home_screen.dart';
import 'package:animation_and_notes/screens/introductions/introduction_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isFirstTime = true;
  getFirstTime() async {
    await HelperFunction.getUserIsFirstTime().then((value) {
      setState(() {
        isFirstTime = value!;
      });
    });
  }

  @override
  void initState() {
    getFirstTime();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: isFirstTime ? const IntroductionScreen() : const HomePage(),
    );
  }
}
