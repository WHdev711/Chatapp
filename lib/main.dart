import 'package:alsalamchat/screens/LoginandSignupScreen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:alsalamchat/screens/LoginScreen.dart';
import 'package:alsalamchat/screens/PhoneScreen.dart';
import 'package:alsalamchat/screens/RegisterScreen.dart';
import 'package:alsalamchat/screens/ChatScreen.dart';
import 'package:alsalamchat/helpers/constants.dart';
void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

bool userIsLoggedIn;
class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  
  getLoggedInState() async {
    await Constants.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 10,
        navigateAfterSeconds:new Myhome(),
        title: new Text(
          'Welcome To Al Salam State Company ',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.asset(
          'assets/logo.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Flutter Iraq"),
        loaderColor: Colors.red);
  }
}

class Myhome extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Al Salam Chat app',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: userIsLoggedIn != null ? userIsLoggedIn ? Chat() : SignInOrRegister() : Container(),
        routes: {
          SignInOrRegister.routeName: (ctx) => SignInOrRegister(),
          Chat.routeName: (ctx) => Chat(),
          Login.routeName: (ctx) => Login(),
          PhoneVerify.routeName: (ctx) => PhoneVerify(),
          Register.routeName: (ctx) => Register(),

        },);
  }
}
