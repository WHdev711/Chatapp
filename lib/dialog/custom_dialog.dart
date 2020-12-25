import 'package:flutter/material.dart';


enum CustomDialogType {
  Error,
  Success,
  NoInternet,
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final CustomDialogType alertType;
  final Function onTap;

  CustomDialog(
      {@required this.title,
      @required this.description,
      @required this.buttonText,
      this.alertType = CustomDialogType.NoInternet,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...buttom card part
        Container(
          padding: EdgeInsetsDirectional.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            start: Consts.padding,
            end: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: BoxDecoration(
            color: Colors.white70,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 15.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                  child: Text(buttonText),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onTap();
                  },
                ),
              ),
            ],
          ),
        ),
        // Positioned(
        //   left: Consts.padding,
        //   right: Consts.padding,
        //   child: CircleAvatar(
        //     backgroundColor: alertType == CustomDialogType.Error
        //         ? Colors.redAccent
        //         : Colors.blueAccent,
        //     radius: Consts.avatarRadius,
        //     child: Icon(
        //       alertType == CustomDialogType.Error
        //           ? MdiIcons.alert
        //           : alertType == CustomDialogType.NoInternet
        //               ? MdiIcons.wifiStrength1Alert
        //               : MdiIcons.checkBold,
        //       color: Colors.white,
        //       size: 40,
        //     ),
        //     // backgroundImage: image,
        //   ),
        // ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 10.0;
  static const double avatarRadius = 25.0;
}
