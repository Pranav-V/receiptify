import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:receiptify/widgets.dart';

class ShowQRCode extends StatelessWidget {

  final String hash;

  ShowQRCode(this.hash);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: QrImage(
            data: hash ?? "ERROR",
            version: QrVersions.auto,
          ),
        ),
        RoundButton(
          text: "Done",
          height: 45,
          onPress: () => Navigator.of(context).pop(),
        )
      ],
    );
  }

}