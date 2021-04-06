import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alsalamchat/screens/LoginandSignupScreen.dart';//when signout
import 'package:alsalamchat/screens/Profilesetting.dart';//when signout
import 'package:alsalamchat/helpers/constants.dart';
// import 'package:flutterchat/helpers/helper_functions.dart'; //open new page url
import 'package:alsalamchat/helpers/responsive_widget.dart'; // responsive large and small
// import 'package:flutterchat/helpers/theme.dart'; // this is theme
import 'package:alsalamchat/models/home_container_model.dart';// model definition
import 'package:alsalamchat/services/auth.dart'; //when signout
import 'package:alsalamchat/services/database.dart';
import 'package:alsalamchat/services/search_service.dart'; // search 
import 'package:alsalamchat/views/chatinfo.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alsalamchat/screens/call_screens/pickup/pickup_layout.dart';

import 'conversation_screen.dart';
import 'dart:io';
import 'dart:convert';

class Chat extends StatefulWidget {
  static const routeName = 'Chat';

  final String userName;
  final String userAvatarUrl;
  final String chatRoomId;
  Chat({this.userName, this.chatRoomId, this.userAvatarUrl});

  @override
  _WebHomeState createState() => _WebHomeState();
}

/// Defining some variable globally

HomeContainerModel homeContainerModel = new HomeContainerModel();
String _myName = "", _myAvatar = "";
String _myPhone = "", _myUid = "";

///
Stream infoStream;

/// creating a chat stream to listen
Stream messagesStreamHome;

class _WebHomeState extends State<Chat> {
  ///using key for scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ///

  ///
  Stream chats;

  @override
  void initState() {
    // messagesStreamHome = widget.messageStream;
    homeContainerModel.chatRoomIdGlobal = widget.chatRoomId;
    databaseMethods
        .getChats(homeContainerModel.chatRoomIdGlobal)
        .then((result) {
      messagesStreamHome = result;
      homeContainerModel.messagesStream = result;
    });

    getMyInfoAndChat();
    registerNotification();
    configLocalNotification();

    /// Stream
    if (infoStream == null) {
      infoStream =
          Stream<HomeContainerModel>.periodic(Duration(milliseconds: 100), (x) {
        return homeContainerModel;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    infoStream = null;
    homeContainerModel.messagesStream = null;
    super.dispose();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(_myUid)
          .updateData({'pushToken': token});
    }).catchError((err) {
      print(err.message.toString());
    });
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.salamcompany.chatapp'
          : 'com.duytq.flutterchatdemo',
      'Salamcompany chat',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/launcher_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  getMyInfoAndChat() async {
    _myAvatar = await Constants.getUserAvatarSharedPreference();
    _myName = await Constants.getUserNameSharedPreference();
    _myPhone = await Constants.getUserPhoneSharedPreference();
    _myUid = await Constants.getUserUidSharedPreference();
    DatabaseMethods().getUserChats(_myUid).then((value) {
      
      //if (!mounted) return;
      setState(() {chats = value;});
    });
  }


  /// Scaffold..........................

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: _onBackPressed,
    child: new StreamBuilder(
      stream: infoStream,
      builder: (context, snapshot) {
        return snapshot.hasData ? SafeArea(
          child: Container(
            child: HomeContainerWidgets(),
          ),
        ) : Container();
      },
    ),
    );
  }

  Future<bool> _onBackPressed() {
  return showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Text('Are you sure?'),
      content: new Text('Do you want to exit an App'),
      actions: <Widget>[
        new GestureDetector(
          onTap: () => Navigator.of(context).pop(false),
          child: Text("NO"),
        ),
        SizedBox(height: 16),
        new GestureDetector(
          onTap: () => exit(0),
          child: Text("YES"),
        ),
      ],
    ),
  ) ??
      false;
}


  Widget HomeContainerWidgets(){
    return ResponsiveWidget(
      /// Large Screen DONE
      largeScreen:
      PickupLayout(
      userUid: _myUid,
      scaffold: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xffFFFFFF),
          drawer: Drawer(child: menu(context: context)),
          endDrawer: Drawer(
            child: ChatInfo(
              userName: homeContainerModel.userNameGlobal,
              userImageUrl: homeContainerModel.userPicUrlGlobal,
              chatRoomId: homeContainerModel.chatRoomIdGlobal,
              height: MediaQuery.of(context).size.height,
              myName: _myName,
              userPhone:homeContainerModel.userPhoneGlobal,
              //userEmail: widget.email,
            ),
          ),
          body: _myAvatar == null
              ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : ItsLargeHome(
            chats: chats,
            userName: homeContainerModel.userNameGlobal,
            userPicUrl: homeContainerModel.userPicUrlGlobal,
            chatRoomId: homeContainerModel.chatRoomIdGlobal,
            scaffoldKey: _scaffoldKey,
          )),
      ),
      smallScreen:PickupLayout(
      userUid: _myUid,
      scaffold:  Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xffFFFFFF),
        drawer: Drawer(child: menu(context: context)),
        endDrawer: Drawer(
          child: ChatInfo(
            userName: homeContainerModel.userNameGlobal,
            userImageUrl: homeContainerModel.userPicUrlGlobal,
            chatRoomId: homeContainerModel.chatRoomIdGlobal,
            myName: _myName,
            height: MediaQuery.of(context).size.height - 24,
            userPhone: homeContainerModel.userPhoneGlobal
          ),
        ),
        body: _myAvatar == null
            ? Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : Stack(
          children: <Widget>[
            homeContainerModel.isChatSelected
                ? Container()
                : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Home(
                    context: context,
                    width: MediaQuery.of(context).size.width,
                    chats: chats,
                    homeScaffoldKey: _scaffoldKey)),
            homeContainerModel.isChatSelected
                ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ConversationScreen(
                  width: MediaQuery.of(context).size.width,
                  name: homeContainerModel.userNameGlobal,
                  profilePicUrl:
                  homeContainerModel.userPicUrlGlobal,
                  chatRoomid:
                  homeContainerModel.chatRoomIdGlobal,
                  messagesStream:
                  homeContainerModel.messagesStream,
                  myNameFinal: _myName,
                  myPhone: _myPhone,
                  myAvatarFinal: _myAvatar,
                  scaffoldKey: _scaffoldKey,
                  toUserinfo : homeContainerModel,
                ))
                : Container(),
          ],
        ),
      ),
      ),
    );
  }

  Widget menu({context, double menuWidth}) {
    return Container(
      decoration: BoxDecoration(color: Color(0xff1C1B1B)),
      width: menuWidth ?? MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 60,
          ),
          Container(
              padding: EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Constants.colorAccent, width: 2),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(120)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: kIsWeb
                              ? Image.network(_myAvatar)
                              : Image.network(_myAvatar))
                            ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    _myName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    _myPhone,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'OverpassRegular',
                    ),
                  ),
                ],
              )),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ProfilePage(myName:_myName,myAvatar:_myAvatar,myPhone:_myPhone,)));
            },
            child: Opacity(
              opacity: 0.8,
              child: Container(
                padding: EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Profile Edit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              AuthService().signOut();
              Constants.saveUserLoggedInSharedPreference(false);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignInOrRegister()));
            },
            child: Opacity(
              opacity: 0.8,
              child: Container(
                padding: EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      "assets/logout.png",
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }
}

String getAvatarUrlOfOther(List<dynamic> avatarUrl) {
  if (avatarUrl[0] == _myAvatar) {
    return avatarUrl[1];
  } else {
    return avatarUrl[0];
  }
}

class Home extends StatefulWidget {
  final BuildContext context;
  final double width;
  Stream chats;
  final GlobalKey<ScaffoldState> homeScaffoldKey;

  Home(
      {@required this.context,
      @required this.width,
      @required this.chats,
      @required this.homeScaffoldKey});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String searchString = "";
  QuerySnapshot querySnapshot;
  bool isLoading = false;

  QuerySnapshot usersSnapshot;


  getRecentMembers() {
    DatabaseMethods().getRecentUsers().then((snapshot) {
      print(snapshot.documents[1].data);
      print(snapshot.documents.length);
      print(snapshot.documents[0].data['name'].toString()+"this is awesome");
      setState(() {
        usersSnapshot = snapshot;
      });
    });
  }

  initiateSearch() {
    getUserAvatar();

    setState(() {
      isLoading = true;
    });
    print("initiated the search with : $searchString");
    setState(() {
      isLoading = true;
    });

    SearchService().searchByName(searchString).then((result) {
      setState(() {
        querySnapshot = result;
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  getUserAvatar() async {
    //_myAvatarUrl = await Constants.getUserAvatarSharedPreference();
    _myPhone = await Constants.getUserPhoneSharedPreference();
    _myName = await Constants.getUserNameSharedPreference();
    setState(() {});
  }

  Widget recentUserList(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 30,),
        Container(
          padding: EdgeInsets.symmetric(horizontal:  16),
          child: Text(
            "Recent users of chat",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'OverpassRegular',
            ),
          ),
        ),
        Container(
          child: usersSnapshot != null
              ? ListView.builder(
              itemCount: usersSnapshot.documents.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return userTile(
                  userPhone: usersSnapshot.documents[index].data['phone'],
                  userName: usersSnapshot.documents[index].data['name'],
                  userAvatarUrl: usersSnapshot.documents[index].data['avatarUrl'],
                  userUid: usersSnapshot.documents[index].data['uid'],
                );
              })
              : Container(),
        ),
      ],
    );
  }

  Widget userList() {
    return isLoading
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            child: querySnapshot != null
                ? ListView.builder(
                    itemCount: querySnapshot.documents.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return userTile(
                        userPhone: querySnapshot.documents[index].data['phone'],
                        userName:
                            querySnapshot.documents[index].data['name'],
                        userAvatarUrl:
                            querySnapshot.documents[index].data['avatarUrl'],
                        userUid: querySnapshot.documents[index].data['uid'],
                      );
                    })
                : Container(),
          );
  }

  @override
  void initState() {
    getRecentMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                  Colors.black.withOpacity(1),
                  Colors.black.withOpacity(.3),
                ])),
      // color: Color(0xff1F1F1F),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                // color: Color(0xffCE402C),
                color: Colors.transparent,
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                width: widget.width ?? 300,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.homeScaffoldKey.currentState.openDrawer();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                          )),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        homeContainerModel.isSearching =
                            !homeContainerModel.isSearching;
                        /* Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Search()));*/
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            homeContainerModel.isSearching
                                ? "Cancel"
                                : "Find",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "OverpassRegular",
                                fontSize: 15),
                          )),
                    ),
                  ],
                ),
              ),
              homeContainerModel.isSearching
                  ? Container(
                  width: MediaQuery.of(context).size.width > 800 ? 300 : MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 1),
                                child: TextField(
                                  // controller: textController,
                                  onChanged: (val) {
                                    searchString = val;
                                  },
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    // border: InputBorder.none,
                                    hintText: "search username ...",
                                    contentPadding: EdgeInsets.only(left: 34.0),
                                     focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    borderSide: BorderSide(color: Colors.yellow),
                                  ),
                                    hintStyle: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            GestureDetector(
                              onTap: () {
                                initiateSearch();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                child: Image.asset(
                                  "assets/search_white.png",
                                  width: 25,
                                  height: 25,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(1),
                                          const Color(0x0FFFFFFF)
                                        ],
                                        begin: FractionalOffset.topLeft,
                                        end: FractionalOffset.bottomRight)),
                                padding: EdgeInsets.all(12),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                      ),

                      /// List.....
                      userList(),
                      recentUserList()
                    ],
                  ),
                    )
                  : Container(
                      // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      height: MediaQuery.of(context).size.height - 56,
                      child: widget.chats != null
                          ? StreamBuilder(
                              stream: widget.chats,
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.documents.length,
                                        itemBuilder: (context, index) {
                                          return ChatTile(
                                            // userName: getusername(snapshot
                                            //         .data
                                            //         .documents[index]
                                            //         .data["chatRoomId"]
                                            //         .toString()
                                            //         .replaceAll("_", "")
                                            //         .replaceAll(_myUid, "")),
                                            userUid: snapshot
                                                    .data
                                                    .documents[index]
                                                    .data["chatRoomId"]
                                                    .toString()
                                                    .replaceAll("_", "")
                                                    .replaceAll(_myUid, ""),
                                            userPicUrl: getAvatarUrlOfOther(
                                                snapshot.data.documents[index]
                                                    .data["avatarUrl"]),
                                            lastMessage: snapshot
                                                .data
                                                .documents[index]
                                                .data["lastmessage"],
                                            timestamp: snapshot
                                                    .data
                                                    .documents[index]
                                                    .data["timestamp"] ??
                                                "NA",
                                            unreadMessages: snapshot
                                                    .data
                                                    .documents[index]
                                                    .data["$_myUid"] ,
                                            lastMessageSendBy: snapshot
                                                .data
                                                .documents[index]
                                                .data["lastMessageSendBy"],
                                            chatRoomId: snapshot
                                                .data
                                                .documents[index]
                                                .data["chatRoomId"],
                                            width: widget.width,
                                          );
                                        })
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                              },
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            )),
            ],
          ),
        ),
      ),
    );
  }
}

Widget userTile({String userName, userPhone, String userAvatarUrl, String userUid}) {
  return Container(
    width: 300,
    margin: EdgeInsets.symmetric(vertical: 12),
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(8),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
            child: Image.network(userAvatarUrl)),
        SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              userName,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            Text(
              userPhone,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () async {
            if (userName != _myName) {
              List<String> users = [_myUid, userUid];

              List<String> avatarUrls = [_myAvatar, userAvatarUrl];

              List<int> unreadMessages = [0, 1];

              String chatRoomid =
                  getChatRoomId(userUid, _myUid); // "$userName\_${myName}";

              /// Create Chat Room
              Map<String, dynamic> chatRoom = {
                "users": users,
                "avatarUrl": avatarUrls,
                "lastmessage": "Hey",
                "lastMessageSendBy": _myName,
                'timestamp': Timestamp.now(),
                "unreadMessage": unreadMessages,
                "chatRoomId": chatRoomid
              };

              bool canMessage;
              DatabaseMethods().addChatRoom(chatRoom, chatRoomid).then((val) {
                canMessage = val;
                if (canMessage) {
                  homeContainerModel.chatRoomIdGlobal = chatRoomid;
                  databaseMethods.getChats(chatRoomid).then((result) {
                    messagesStreamHome = result;
                    homeContainerModel.messagesStream = result;
                    homeContainerModel.isSearching = false;

                    /// setting up the profile pic name and email
                    homeContainerModel.userPicUrlGlobal = userAvatarUrl;
                    homeContainerModel.userNameGlobal = userName;
                    homeContainerModel.userPhoneGlobal = userPhone;
                    homeContainerModel.userUid = userUid;

                    print(
                        "${homeContainerModel.messagesStream}   $messagesStreamHome");
                    homeContainerModel.isChatSelected = true;
                  });
                  /* Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        */ /*
                                userName: userName, userAvatarUrl: userAvatarUrl, chatRoomid,messagesStream,*/ /*
                          builder: (context) => WebHome(
                            userName: userName,
                            userAvatarUrl: userAvatarUrl,
                            chatRoomId: chatRoomid,
                          )));*/
                }
              });

              /// sending to chat

            } else {
              // TODOs show snackbar you cannot send message to yourself
            }
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Constants.colorAccent,
                  borderRadius: BorderRadius.circular(40)),
              child: Text(
                "Message",
                style: TextStyle(color: Colors.white),
              )),
        )
      ],
    ),
  );
}

void _moreOptionBottomSheet(
    {@required BuildContext context, @required String chatRoomId}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.only(bottom: 36),
          child: new Wrap(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Text(
                    "More Options..",
                    style: TextStyle(fontSize: 16),
                  )),
              ListTile(
                  leading: Icon(Icons.delete),
                  title: Text(
                    'Delete Chat',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    databaseMethods.removeChatRoom(chatRoomId);
                    Navigator.pop(context);
                  }),
            ],
          ),
        );
      });
}

class ChatTile extends StatefulWidget {
  final String userUid,  userPicUrl, lastMessage, chatRoomId;
  final Timestamp timestamp;
  final bool unreadMessages;

  // provide 0
  final String lastMessageSendBy;
  final double width;

  // provide false

  ChatTile(
      {this.userUid,
      this.userPicUrl,
      this.lastMessage,
      this.timestamp,
      this.unreadMessages,
      this.lastMessageSendBy,
      this.chatRoomId,
      @required this.width});
  @override
  _ChatTile createState() =>_ChatTile();
}

class _ChatTile extends State<ChatTile> {
  String chatuser = "";
  String chatuseravatar = "";
  @override
  void initState() {

    // getusername(widget.userUid);
    SearchService().searchByUid(widget.userUid).then((user){
      // print(user.documents[0].data['name'].toString() + "");
    //  setState(() {
       chatuser = Constants.makeFirstLetterUpperCase(user.documents[0].data['name'].toString());
       chatuseravatar = Constants.makeFirstLetterUpperCase(user.documents[0].data['avatarUrl'].toString());
      //  });
     }); 
    super.initState();
  }
  @override
  Widget build(BuildContext context) { 
    return GestureDetector(
      onLongPress: () {
        _moreOptionBottomSheet(context: context, chatRoomId: widget.chatRoomId);
      },
      onTap: () {
        homeContainerModel.isChatSelected = true;
        homeContainerModel.userPicUrlGlobal = chatuseravatar;
        homeContainerModel.chatRoomIdGlobal = widget.chatRoomId;
        homeContainerModel.userUid = widget.userUid;
        SearchService().searchByUid(widget.userUid).then((user){
          print(user.documents[0].data['phone'].toString());
          homeContainerModel.userPhoneGlobal =  user.documents[0].data['phone'].toString();
          homeContainerModel.userNameGlobal =Constants.makeFirstLetterUpperCase(user.documents[0].data['name'].toString());
        });
        databaseMethods.getChats(widget.chatRoomId).then((result) {
          messagesStreamHome = result;
          homeContainerModel.messagesStream = result;

          /// setting up the profile pic name and email
          homeContainerModel.userPicUrlGlobal = chatuseravatar;
          // homeContainerModel.userNameGlobal = Constants.makeFirstLetterUpperCase(userName);
          // homeContainerModel.userPhoneGlobal = "testuserphone";
        });

        /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConversationScreen(userName, userPicUrl, chatRoomId)));*/
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        color: homeContainerModel.chatRoomIdGlobal == widget.chatRoomId
            ? Colors.black12
            : Colors.transparent,
        width: widget.width ?? MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(2),

                decoration: BoxDecoration(
                    border:
                        /*selectedAvatarUrl == avatarUrl
                        ?*/
                        Border.all(color: Colors.white, width: 0.7)
                    /* : Border.all(color: Colors.transparent, width: 10)*/,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: kIsWeb
                        ? Image.network(chatuseravatar,height: 40,
                      width: 40,)
                        : Image.network(chatuseravatar,height: 40,
                      width: 40,))),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Container(
                  width: (widget.width ?? MediaQuery.of(context).size.width) - 80,
                  alignment: Alignment.topLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        chatuser,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      widget.unreadMessages == true
                          ? Row(
                              children: <Widget>[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red[900],
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  "New",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'OverpassRegular',
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Spacer(),
                      Text(
                        Constants.timeAgoSinceDate(
                            DateTime.fromMillisecondsSinceEpoch(
                                    widget.timestamp.millisecondsSinceEpoch)
                                .toIso8601String())
                        /*timeago.format(DateTime.
                        fromMillisecondsSinceEpoch(timestamp.nanoseconds),allowFromNow: true)*/
                        ,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'OverpassRegular',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: <Widget>[
                    widget.lastMessageSendBy == _myName
                        ? Row(
                            children: <Widget>[
                              Image.asset(
                                "assets/receive_arrow.png",
                                width: 14,
                                height: 14,
                                color: Constants.colorAccent  ,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          )
                        : Row(
                            children: <Widget>[
                              Image.asset(
                                "assets/back_arrow.png",
                                width: 14,
                                height: 14,
                                color: Colors.red  ,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                    Container(
                      width: (widget.width ?? MediaQuery.of(context).size.width) - 158,
                      child: Text(
                        widget.lastMessage,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Colors.white,
                          fontFamily: 'OverpassRegular',
                        ),
                      ),
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 14,
                // ),
                // Container(
                //   width: (widget.width ?? MediaQuery.of(context).size.width) - 80,
                //   height: 0.4,
                //   color: Colors.white70,
                // ),
                // SizedBox(
                //   height: 8,
                // )
              ],
            )
          ],
        ),
      ),
    );
  }

}
  

class ItsLargeHome extends StatefulWidget {
  final Stream chats;
  final String userName;
  final String userPicUrl;
  final String chatRoomId;
  final scaffoldKey;

  ItsLargeHome(
      {@required this.chats,
      @required this.chatRoomId,
      @required this.userPicUrl,
      @required this.userName,
      @required this.scaffoldKey});

  @override
  _ItsLargeHomeState createState() => _ItsLargeHomeState();
}

class _ItsLargeHomeState extends State<ItsLargeHome> {
  @override
  Widget build(BuildContext context) {
    /*  databaseMethods.getChats(widget.chatRoomId).then((result) {
          messagesStreamHome = result;
          /// setting up the profile pic name and email
          homeContainerModel.userPicUrlGlobal = widget.userPicUrl;
          homeContainerModel.userNameGlobal = widget.userName;
          // homeContainerModel.userEmailGlobal = userEmail;
          setState(() {});
        });*/
    return Row(
      children: <Widget>[
        Expanded(
            child: Home(
                context: context,
                width: 300,
                chats: widget.chats,
                homeScaffoldKey: widget.scaffoldKey)),
        homeContainerModel.isChatSelected
            ? ConversationScreen(
                width: MediaQuery.of(context).size.width - 300,
                name: homeContainerModel.userNameGlobal,
                profilePicUrl: homeContainerModel.userPicUrlGlobal,
                chatRoomid: homeContainerModel.chatRoomIdGlobal,
                messagesStream: homeContainerModel.messagesStream,
                myNameFinal: homeContainerModel.userNameGlobal,
                myPhone: "appc31058@gmail.com",
                myAvatarFinal: homeContainerModel.userPicUrlGlobal,
                scaffoldKey: widget.scaffoldKey,
                toUserinfo : homeContainerModel,
              )
            : Container(
                width: kIsWeb ? MediaQuery.of(context).size.width - 300 : 0,
              ),
      ],
    );
  }
}
