import 'package:alsalamchat/screens/LoginScreen.dart';
import 'package:alsalamchat/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';

class SignInOrRegister extends StatefulWidget {
  static const routeName = 'SignInOrRegister';
  @override
  _SignInOrRegisterState createState() => _SignInOrRegisterState();
}

class _SignInOrRegisterState extends State<SignInOrRegister> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                  Colors.black.withOpacity(.9),
                  Colors.black.withOpacity(.1),
                ])),
          ),
          Builder(
           builder: (BuildContext context) {
             return Padding(
               padding: EdgeInsets.only(bottom: 60),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.end,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: <Widget>[

                     Image.asset(
                     'assets/logo.png',
                     height: 250,
                     width: 250,),
                  SizedBox(
                     height: 4,
                   ),
                   Text(
                     'Welcome To',
                     style: TextStyle(
                       fontSize: 27.0,
                       color: Colors.white,
                     ),
                   ),
                   SizedBox(
                     height: 4,
                   ),
                   Text(
                     'Al Salam State Company',
                     style: TextStyle(
                       fontSize: 16.0,
                       color: Colors.white,
                     ),
                   ),
                   SizedBox(
                     height: 4,
                   ),
                   InkWell(
                      onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => Login()),
                       );
                     },
                     child: Stack(
                       children: <Widget>[
                         Container(
                             width: double.infinity,
                             margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                             padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                             height: 50,
                             decoration: BoxDecoration(
                                 color: Colors.transparent,
                                 borderRadius: BorderRadius.circular(50)),
                             ),
                         Container(
                           height: 50,
                           decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(50)
                          ),
                           margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                           child: Center(
                               child: Text(
                                 'Login',
                                 style: TextStyle(fontSize: 16,color: Colors.white),
                                 
                               )),
                         )
                       ],
                     ),
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   InkWell(
                     onTap: () {
                       Navigator.of(context).pushNamed(Register.routeName);
                     },
                     child: Stack(
                       children: <Widget>[
                         Container(
                             width: double.infinity,
                             margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                             padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                             height: 50,
                             decoration: BoxDecoration(
                                 color: Color(0xffCE402C),
                                 borderRadius: BorderRadius.circular(50)),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.start,
                               children: <Widget>[
                                 Container(
                                   margin: EdgeInsets.only(left: 20),
                                   height: 22,
                                   width: 22,
                                 ),
                               ],
                             )),
                         Container(
                           height: 50,
                           margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                           child: Center(
                               child: Text(
                                 'Sign Up',
                                 style: TextStyle(
                                     fontSize: 16,
                                     color: Colors.white),
                               )),
                         )
                       ],
                     ),
                   ),
                   SizedBox(
                     height: 20,
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Container(
                     height: 50,
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(50)
                     ),
                     margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                     child: Center(
                         child: Text(
                           "Don't have an account",
                           style: TextStyle(
                               fontSize: 16,
                               color: Colors.white),
                         )),
                   ),
                   InkWell(
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => Register()),
                       );
                     },
                     child: Container(
                       height: 30,
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(50)
                       ),
                       margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                       child: Center(
                           child: Text(
                             "Create account",
                             style: TextStyle(
                                 fontSize: 16,
                                 color: Colors.white,
                                 fontWeight: FontWeight.bold),
                           )),
                     ),
                   ),
                 ],
               ),
             );
           }
          )
        ],
      ),
    );
  }
}