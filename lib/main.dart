import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_social_app/auth/register/register.dart';
import 'package:fyp_social_app/questionaire/questionaire.dart';
import 'package:fyp_social_app/utils/firebase.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fyp_social_app/components/life_cycle_event_handler.dart';
import 'package:fyp_social_app/landing/landing_page.dart';
import 'package:fyp_social_app/screens/mainscreen.dart';
import 'package:fyp_social_app/services/user_service.dart';
import 'package:fyp_social_app/utils/config.dart';
import 'package:fyp_social_app/utils/constants.dart';
import 'package:fyp_social_app/utils/providers.dart';
import 'package:fyp_social_app/view_models/theme/theme_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initFirebase();
  runApp( MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () => UserService().setUserStatus(false),
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, Widget? child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeData(
              notifier.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return TabScreen();
                } else {
                  return Landing();
                }
              }),
            ),
          );
        },
      ),
    );
  }
  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.lexendTextTheme(
        theme.textTheme,
      ),
    );
  }
}
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => MyApp(),
        ),
      );
    });

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your splash screen content here (e.g., image, text)
              Image.asset('assets/images/new1.png'),
            ],
          ),
        ),
      ),
    );
  }
}