import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:alsalamchat/screens/ChatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alsalamchat/dialog/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alsalamchat/helpers/constants.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'dart:async';
import 'dart:convert';
String avatarurl = 'https://firebasestorage.googleapis.com/v0/b/chatapp-efe14.appspot.com/o/66d9d2d54bebdc4e16942412c97b622c.png?alt=media&token=a2833bd9-bec0-4261-a493-0dd1600d3106';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PhoneVerify extends StatefulWidget {
  static const routeName = 'Phoneverify';
  bool _isInit = true;
  // var _contact = '';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<PhoneVerify> {
  final _phoneverifyEditingController = TextEditingController();
  String phoneNo;
  String smsOTP;
  String username;
  String status;
  String verificationId;
  String errorMessage = '';
  // final Firestore firestore = Firestore();
  // Timer _timer;

    //this is method is used to initialize data
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data only once after screen load
    if (widget._isInit) {
      // widget._contact = '${ModalRoute.of(context).settings.arguments}';

      Map<String, dynamic> map = jsonDecode('${ModalRoute.of(context).settings.arguments}'); // import 'dart:convert';
      this.phoneNo = map['phone'];
      this.username = map['name'];
      this.status = map['status'];
      print(map);
      // print(widget._contact);
      generateOtp(map['phone']);
      widget._isInit = false;
    }
  }

    //dispose controllers
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    //test feild state

    //for showing loading

    // this below line is used to make notification bar transparent
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

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
            AppBar(
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: EdgeInsets.only(
             bottom: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Enter Code',
                    style: TextStyle(
                      fontSize: 27.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    '* * * * * *',
                    style: TextStyle(
                      fontSize: 27.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    'We have sent you an SMS on ${this.phoneNo}',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'with 6 digit verification code',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(50)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                height: 22,
                                width: 22,
                                child: Icon(
                                  Icons.sms,
                                  color: Color(0xffCE402C),
                                  size: 20,
                                ),
                              ),
                            ],
                          )),
                      Container(
                          height: 50,
                          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: TextField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: 'Enter SMS code Number',
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Colors.white70
                                )
                            ),
                            controller: _phoneverifyEditingController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 16,
                                color: Colors.white),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: () {
                      verifyOtp();
                    },
                    child:Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)
                    ),
                    margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Center(
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black),
                        )),
                  )),
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
                          "Did not receive the code?",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white),
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      generateOtp(this.phoneNo);
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Center(
                          child: Text(
                            "Re-Send",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
    );
  }
  Future<void> generateOtp(String contact) async {
    print("hello");
    print(contact);
    
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      print("what");
      print(verId);
      print("whaty");

      verificationId = verId;
    };
    print(smsOTPSent);
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: contact,
          codeAutoRetrievalTimeout: (String verId) {
            verificationId = verId;
          },
          codeSent: smsOTPSent,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (AuthCredential phoneAuthCredential) {},
          verificationFailed: (AuthException exception) {
           showAlertDialog(context, exception.message);
          });
    } catch (e) {
      handleError(e as PlatformException);
     showAlertDialog(context, (e as PlatformException).message);
    }
  }

  Future<void> verifyOtp() async {
    // final batchWrite = firestore.batch();
    if (_phoneverifyEditingController == null || _phoneverifyEditingController.text == '') {
      showAlertDialog(context, 'please enter 6 digit otp');
      return;
    }
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: _phoneverifyEditingController.text,
      );
      final AuthResult user = await _auth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.user.uid == currentUser.uid);
      print('xxxxxxxxxxxxxxxxxxxxx');
      print(currentUser.uid);
      print(this.username);
      print(this.phoneNo);
      print('yyyyyyyyyyyyyyyyyyyyy');
      final QuerySnapshot result = await Firestore.instance
          .collection("users")
          .where("uid", isEqualTo : user.user.uid)
          .getDocuments();
      if (this.status == "register"){
        if ( ! result.documents.isEmpty){
          showDialog(context: context,
                    builder: (context){
                      return CustomDialog(title: "Warning", description: "This phone number already are registered before", buttonText: 'Okay');
                    },
                        );
          Navigator.pushReplacementNamed(context, 'Login');
        }
        else{
          Firestore.instance.collection("users").document(user.user.uid).setData({"uid": user.user.uid,"name":this.username,"phone": this.phoneNo,"avatarUrl":avatarurl});
          Constants
              .saveUserLoggedInSharedPreference(
                  true);
          Constants.saveUserNameSharedPreference(
              this.username);
          Constants.saveUserUidSharedPreference(
              user.user.uid);
          Constants
              .saveUserAvatarSharedPreference(
                  avatarurl);
          print(
              "$avatarurl user avatar saved");
          Constants.saveUserPhoneSharedPreference(
              this.phoneNo);
          print('success');
          // Navigator.pushReplacementNamed(context, 'Chat');
          Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Chat()));
        }
      }
      else {
        if ( ! result.documents.isEmpty){
          print(result.documents[0].data);
          Constants
              .saveUserLoggedInSharedPreference(
                  true);
          Constants.saveUserNameSharedPreference(
              result.documents[0].data["name"]);
          Constants.saveUserAvatarSharedPreference(
              result.documents[0].data["avatarUrl"]);
          Constants.saveUserUidSharedPreference(
              user.user.uid);
          Constants.saveUserPhoneSharedPreference(this.phoneNo);
          // Navigator.pushReplacementNamed(context, 'Chat');
          Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Chat()));
        }
        else {
          showDialog(context: context,
                    builder: (context){
                      return CustomDialog(title: "Warning", description: "Please register this number", buttonText: 'Okay');
                    },
                        );
        }
      }
    } catch (e) {
      handleError(e as PlatformException);
    }
  }

    //Method for handle the errors
  void handleError(PlatformException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        showAlertDialog(context, 'Invalid Code');
        break;
      default:
        showAlertDialog(context, error.message);
        break;
    }
  }
  void showAlertDialog(BuildContext context, String message) {
    // set up the AlertDialog
    showDialog(context: context,
                builder: (context){
                  return CustomDialog(title: "Warning", description: message, buttonText: 'Okay');
                },
                    );
  }


}