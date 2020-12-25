import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:alsalamchat/models/call_model.dart';
// import 'package:naya_project/provider/user_provider.dart';
import 'package:alsalamchat/services/call_methods.dart';
import 'package:alsalamchat/screens/call_screens/pickup/pickup_screen.dart';
// import 'package:provider/provider.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();
  final String userUid;

  PickupLayout({
    @required this.scaffold,
    @required this.userUid,
  });

  @override
  Widget build(BuildContext context) {
    // final UserProvider userProvider = Provider.of<UserProvider>(context);
    // final String _myUid =  Constants.getUserUidSharedPreference().toString();

    return (this.userUid != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: this.userUid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data != null) {
                Call call = Call.fromMap(snapshot.data.data);

                if (!call.hasDialled) {
                  return PickupScreen(call: call);
                }
              }
              return scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
