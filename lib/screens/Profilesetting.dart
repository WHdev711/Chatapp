import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:alsalamchat/dialog/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alsalamchat/helpers/constants.dart';
import 'package:alsalamchat/screens/ChatScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';


class ProfilePage extends StatefulWidget {
  final String myName,myAvatar,myPhone; 
  ProfilePage({this.myName,this.myAvatar,this.myPhone});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _phoneEditingController = TextEditingController();
  final _firstnameEditingController = TextEditingController();
  final _lastnameEditingController = TextEditingController();
  String avatarurl = '';
  File _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('users/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then(
          (value) =>{ print("Done: $value"),
        setState(() {
              avatarurl = value;
            })}
        );
    // widget.imagePickFn(_image);
  }
  
  Future<void> clickOnLogin(BuildContext context) async {
    if (_phoneEditingController.text.isEmpty || _firstnameEditingController.text.isEmpty || _lastnameEditingController.text.isEmpty ) {
      showDialog(context: context,
                builder: (context){
                  return CustomDialog(title: "Warning", description: "Some field can\'t be empty.", buttonText: 'Okay');
                },
                    );
    } else {
      final _myUid = await Constants.getUserUidSharedPreference();
      print("this is "+_myUid);
      print(_firstnameEditingController.text);
      Firestore.instance.collection("users").document(_myUid).updateData({"uid": _myUid,"name":"${_firstnameEditingController.text} ${_lastnameEditingController.text}","phone": _phoneEditingController.text,"avatarUrl":_image != null ? avatarurl : widget.myAvatar});
      Constants
          .saveUserLoggedInSharedPreference(
              true);
      Constants.saveUserNameSharedPreference(
          "${_firstnameEditingController.text} ${_lastnameEditingController.text}");
      Constants.saveUserAvatarSharedPreference(
           _image != null ? avatarurl : widget.myAvatar);
      Constants.saveUserUidSharedPreference(
          _myUid);
      Constants.saveUserPhoneSharedPreference(_phoneEditingController.text);
      // final responseMessage =  await Navigator.pushNamed(context, 'Phoneverify', arguments: '{"phone":"$_dialCode${_phoneEditingController.text}","name":"${_firstnameEditingController.text} ${_lastnameEditingController.text}","status":"register"}');
      Navigator.push(context,MaterialPageRoute(builder: (context) => Chat()));
          // await Navigator.push(
          //             context,
          //             MaterialPageRoute(builder: (context) => PhoneVerify()),
          //           );
      // if (responseMessage != null) {
      //   showErrorDialog(context, responseMessage as String);
      // }
    }
  }

  //callback function of country picker
  void showErrorDialog(BuildContext context, String message) {
    // set up the AlertDialog
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  void initState() {
    print("this is ${widget.myAvatar}");
    _phoneEditingController.text = widget.myPhone;
    _firstnameEditingController.text = widget.myName.split(' ')[0];
    _lastnameEditingController.text = widget.myName.split(' ')[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //test feild state


    // this below line is used to make notification bar transparent
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(.9),
                      Colors.black.withOpacity(.3),
                    ])),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _image != null ? CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: ClipOval(child: Image.network(avatarurl,height: 150, width: 150, fit: BoxFit.cover,)),
                    ): 
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white,
                      child: ClipOval(child: Image.network(widget.myAvatar,height: 150, width: 150, fit: BoxFit.cover,)),
                    ),
                    FlatButton(
                    onPressed: () {
                      print("this is camera");
                      getImage();
                    },
                    child:Positioned(bottom: 2, right: 2 ,
                    child:Container(
                      height: 40, width: 40,
                      child: Icon(Icons.add_a_photo, color: Colors.white,),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                    )))
                  ],
                ),
                SizedBox(
                  height: 26,
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
                                Icons.people,
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
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: Colors.white70
                            )
                        ),
                        controller: _firstnameEditingController,
                        style: TextStyle(fontSize: 16,
                            color: Colors.white),
                      )),
                  ],
                ),
                //city
                SizedBox(
                  height: 16,
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
                                Icons.people,
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
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.white70
                              )
                          ),
                          controller: _lastnameEditingController,
                          style: TextStyle(fontSize: 16,
                              color: Colors.white),
                        )),
                  ],
                ),
                //phonenumber
                SizedBox(
                  height: 16,
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
                                Icons.phone,
                                color: Color(0xffCE402C),
                                size: 20,
                              ),
                            ),
                          ],
                        )),
                    Container(
                        height: 50,
                        margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 7),
                        child: Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                                                       
                            Expanded(
                              child: TextField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    hintText: 'Mobile Number',
                                    focusedBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: Colors.white70
                                    )
                                ),
                                controller: _phoneEditingController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                                style: TextStyle(fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        ),
                  ],
                ),
                //college
                SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    this.clickOnLogin(context);
                    // showErrorDialog(context, 'Some field can\'t be empty.');
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
                        'Save',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black),
                      )),
                ),
                ),
                SizedBox(
                  height:50,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}