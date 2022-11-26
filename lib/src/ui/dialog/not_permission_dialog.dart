import 'package:flutter/material.dart';
import 'package:photo/src/provider/i18n_provider.dart';

class NotPermissionDialog extends StatefulWidget {
  final I18NPermissionProvider provider;
  Color backgroundColor;
  Color color;
  Color borderColor;

  NotPermissionDialog(this.provider,
      {required this.backgroundColor,
      required this.color,
      required this.borderColor});

  @override
  _NotPermissionDialogState createState() => _NotPermissionDialogState();
}

class _NotPermissionDialogState extends State<NotPermissionDialog> {
  @override
  Widget build(BuildContext context) {
    var provider = widget.provider;

    return Center(
        child: Wrap(children: [
      Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: AlertDialog(
            backgroundColor: widget.backgroundColor,
            title: Text(provider.titleText!),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(
                    width: 1,
                    color: widget.borderColor,
                    style: BorderStyle.solid)),
            actions: <Widget>[
              ElevatedButton(
                child: Text(
                  provider.cancelText!,
                ),
                onPressed: _onCancel,
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(widget.backgroundColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                width: 1,
                                color: widget.borderColor,
                                style: BorderStyle.solid)))),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(widget.color),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      //side: BorderSide(color: Colors.red)
                    ))),
                child: Text(
                  provider.sureText!,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _onSure,
              ),
            ],
          ))
    ]));

    return AlertDialog(
      title: Text(provider.titleText!),
      actions: <Widget>[
        ElevatedButton(
          onPressed: _onCancel,
          child: Text(provider.cancelText!),
        ),
        ElevatedButton(
          onPressed: _onSure,
          child: Text(provider.sureText!),
        ),
      ],
    );
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onSure() {
    Navigator.pop(context, true);
  }
}
