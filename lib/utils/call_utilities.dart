import 'dart:math';
import 'package:flutter/material.dart';

import 'package:alsalamchat/models/call_model.dart';
import 'package:alsalamchat/services/call_methods.dart';
import 'package:alsalamchat/screens/call_screens/videocall_screen.dart';
import 'package:alsalamchat/screens/call_screens/voicecall_screen.dart';
// import 'package:chatapp/utils/utilities.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dialVideo({ String fromuid,String fromname,String fromprofilephoto, String touid,String toname,String toprofilephoto, context, String callis}) async {
    Call call = Call(
      callerId: fromuid,
      callerName: fromname,
      callerPic: fromprofilephoto,
      receiverId: touid,
      receiverName: toname,
      receiverPic: toprofilephoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeVideoCall(call: call);
    print("this is video call");

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(call: call),
          ));
    }
  }

  static dialVoice({String fromuid,String fromname,String fromprofilephoto, String touid,String toname,String toprofilephoto, context, String callis}) async {
    Call call = Call(
      callerId: fromuid,
      callerName: fromname,
      callerPic: fromprofilephoto,
      receiverId: touid,
      receiverName: toname,
      receiverPic: toprofilephoto,
      channelId: Random().nextInt(1000).toString(),
    );
     print("this is voice call");
    bool callMade = await callMethods.makeVoiceCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallScreen(call: call),
          ));
    }
  }
}
