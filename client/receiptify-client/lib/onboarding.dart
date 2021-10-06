import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receiptify/base_layout.dart';
import 'package:receiptify/constants.dart';
import 'package:receiptify/data_classes.dart';
import 'package:receiptify/functions.dart';
import 'package:receiptify/main.dart';
import 'package:receiptify/widgets.dart';
import 'package:http/http.dart' as http;

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin {

  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  Animation<double> _titleAnimation;
  Animation<double> _messageAnimation;
  Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, -2.25),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.1, 0.5,
        curve: Curves.decelerate,
      ),
    ));
    _titleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.4, 0.8,
        curve: Curves.decelerate,
      ),
    ));
    _messageAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.5, 0.9,
        curve: Curves.decelerate,
      ),
    ));
    _buttonAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.6, 1,
        curve: Curves.decelerate,
      ),
    ));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: green,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.transparent,
            border: null,
            automaticallyImplyLeading: false,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25 + MediaQuery.of(context).padding.top,
              bottom: 25 + MediaQuery.of(context).padding.bottom + 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 175),
                _title(),
                SizedBox(height: 30),
                _welcomeMessage(context),
                SizedBox(height: 30),
                Spacer(flex: 5,),
                _button("Customer", () => push(CustomerOnboarding(), context, fade: true)),
                SizedBox(height: 15),
                _button("Business", () => push(BusinessOnboarding(), context, fade: true)),
              ],
            ),
          ),
        ),
        _logo(),
      ],
    );
  }

  Widget _title() {
    return FadeTransition(
      opacity: _titleAnimation,
      child: ReceiptifyTitle(inverted: true),
    );
  }

  Widget _button(String text, VoidCallback onPress) {
    return FadeTransition(
      opacity: _buttonAnimation,
      child: LargeButton(title: text, onPress: onPress, inverted: true,),
    );
  }

  Widget _logo() {
    return Center(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Image.asset(
          'assets/icons/logo.png',
          fit: BoxFit.contain,
          width: 100.0,
          height: 100.0,
          color: white,
        ),
      ),
    );
  }

  Widget _welcomeMessage(BuildContext context) {
    return FadeTransition(
      opacity: _messageAnimation,
      child: Container(
        width: 400,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            "Digitize your receipts\nand support small businesses.",
            style: TextStyle(color: white,),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}

class Header extends StatelessWidget {

  final String subTitle;

  Header(this.subTitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptifyTitle(),
        _message(context)
      ],
    );
  }

  Widget _message(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          subTitle,
          style: TextStyle(color: title, fontSize: 28, height: 0.95),
        ),
      ),
    );
  }
}

class CustomerOnboarding extends StatelessWidget {

  final nameController = TextFieldController();
  final emailController = TextFieldController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: canvas,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        automaticallyImplyLeading: false,
        leading: ArrowButton(
          direction: ArrowDirection.left,
          onPress: () => Navigator.of(context).pop(),
          color: subtitle,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
          top: 70 + MediaQuery.of(context).padding.top,
          bottom: 25 + MediaQuery.of(context).padding.bottom + 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Header("Say bye to all those\npaper receipts!"),
            SizedBox(height: 50,),
            _nameField(),
            SizedBox(height: 20,),
            _emailField(),
            Spacer(),
            LargeButton(title: "Continue", onPress: () => {
              _createUser().then((response) =>
                  push(BaseLayout(), context, fade: true)
              )
            }),
          ],
        ),
      ),
    );
  }

  Widget _nameField() {
    return LargeTextField(
      controller: nameController,
      placeholder: "Name",
    );
  }

  Widget _emailField() {
    return LargeTextField(
      controller: emailController,
      placeholder: "Email",
    );
  }

  Future<http.Response> _createUser() async {
    Receiptify.instance.isCustomer = true;
    Receiptify.instance.customer = Customer(nameController.text, emailController.text);

    var url = Uri.parse(baseURL + 'createNewUser');
    return await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'securityCode': 'A3D263103C27E77EF8B6267C051906C0',
        'name': nameController.text,
        'email': emailController.text
      }),
    );
  }

}


class BusinessOnboarding extends StatelessWidget {

  final nameController = TextFieldController();
  final streetController = TextFieldController();
  final cityStateZipController = TextFieldController();
  final phoneController = TextFieldController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: canvas,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        automaticallyImplyLeading: false,
        leading: ArrowButton(
          direction: ArrowDirection.left,
          onPress: () => Navigator.of(context).pop(),
          color: subtitle,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
          top: 70 + MediaQuery.of(context).padding.top,
          bottom: 25 + MediaQuery.of(context).padding.bottom + 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Header("Connect with your customers,\nthrough receipts!"),
            SizedBox(height: 50,),
            _nameField(),
            SizedBox(height: 20,),
            _streetField(),
            SizedBox(height: 20,),
            _cityStateZipField(),
            SizedBox(height: 20,),
            _phoneField(),
            Spacer(),
            LargeButton(title: "Continue", onPress: () =>
                _createBusiness().then((response) => push(BaseLayout(), context, fade: true)),
            )
          ],
        ),
      ),
    );
  }

  Widget _nameField() {
    return LargeTextField(
      controller: nameController,
      placeholder: "Name",
    );
  }

  Widget _streetField() {
    return LargeTextField(
      controller: streetController,
      placeholder: "Street",
    );
  }

  Widget _cityStateZipField() {
    return LargeTextField(
      controller: cityStateZipController,
      placeholder: "City, State Zip",
    );
  }

  Widget _phoneField() {
    return LargeTextField(
      controller: phoneController,
      placeholder: "Phone Number",
    );
  }

  Future<http.Response> _createBusiness() async {
    Receiptify.instance.isCustomer = false;
    String t = cityStateZipController.text;
    final city = t.substring(0, t.indexOf(","));
    final state = t.substring(t.indexOf(",") + 2, t.lastIndexOf(" "));
    final zip = t.substring(t.lastIndexOf(" ") + 1);
    Receiptify.instance.business = Business(
      nameController.text,
      Address(
        street: streetController.text,
        city: city,
        state: state,
        zip: zip,
      ),
      phoneController.text,
    );

    var url = Uri.parse(baseURL + 'createNewBusiness');
    return await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String> {
          'securityCode': 'A3D263103C27E77EF8B6267C051906C0',
          'businessName': nameController.text
        })
    );
  }

}