import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './models/user.dart';
import './services/auth.dart';
import './wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  await Firebase.initializeApp();
  runApp(MyApp(savedThemeMode));
}

class MyApp extends StatefulWidget {
  final apptheme;
  MyApp(this.apptheme);

  @override
  State<StatefulWidget> createState() => MainState();
}

class MainState extends State<MyApp> {
  void initState() {
    super.initState();
     checkFirstTime();
  }


  void checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool val = prefs.containsKey("firstTime");
    if (!val) {
      AuthService().clearData();
      prefs.setBool("firstTime", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<MyUsers>.value(value: AuthService().user),
      ],
      child: AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          accentColor: Colors.amber,
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
        ),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          home: Wrapper(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

