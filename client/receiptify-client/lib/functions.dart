import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'main.dart';

List<Widget> verticalSpace(double gap, List<Widget> children) {
  children.removeWhere((element) => element == null);
  for (int i = 1; i < children.length; i+= 2) {
    children.insert(i, SizedBox(height: gap,));
  }
  return children;
}

List<Widget> horizontalSpace(double gap, List<Widget> children) {
  children.removeWhere((element) => element == null);
  for (int i = 1; i < children.length; i+= 2) {
    children.insert(i, SizedBox(width: gap,));
  }
  return children;
}

Future<T> push<T>(Widget page, BuildContext context, {bool fade = false}) async {
  return Navigator.of(context).push(fade ? PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) => page,
    transitionsBuilder: (context, animation1, animation2, child) => FadeTransition(opacity: animation1, child: child,),
  ) : CupertinoPageRoute(
    builder: (context) => page,
  ),);
}

Future<T> showCustomDialog<T>(BuildContext context, Widget dialog, {bool barrierDismissible = true}) {
  barrierDismissible = true;
  return showCupertinoDialog<T>(context: context, builder: (context) => dialog, barrierDismissible: barrierDismissible);
}

String currentDateString() {
  final now = DateTime.now();
  return "${now.month}/0${now.day}/${now.year}";
}

dynamic getAPI(String base, String function) {
  return Uri.parse(base + function);
}

String zeroPad(int num, int digits) {
  String str = num.toString();
  while(str.length < digits) {
    str = '0' + str;
  }

  return str;
}

Future<http.Response> subscribeToBusiness(String businessName) async{
  var url = getAPI(baseURL, 'addSubscription');
  return await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'securityCode': 'A3D263103C27E77EF8B6267C051906C0',
        'name': Receiptify.instance.customer.name,
        'subscription': businessName
      })
  );
}