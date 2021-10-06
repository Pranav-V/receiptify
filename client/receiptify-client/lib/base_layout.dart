import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receiptify/business_pages.dart';
import 'package:receiptify/customer_pages.dart';
import 'package:receiptify/main.dart';

import 'constants.dart';

class BaseLayout extends StatefulWidget {
  @override
  _BaseLayoutState createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {

  int currentIndex = 0;
  CupertinoTabController controller;

  @override
  void initState() {
    super.initState();
    controller = CupertinoTabController();
  }

  @override
  Widget build(BuildContext context) {
    return Receiptify.instance.isCustomer ? CustomerLayout(
      controller: controller,
      onTap: onTabPress,
    ) : BusinessLayout(
      controller: controller,
      onTap: onTabPress,
    );
  }

  void onTabPress(int index) {
    currentIndex = index;
  }

}

class CustomerLayout extends StatelessWidget {

  final CupertinoTabController controller;
  final Function(int) onTap;

  CustomerLayout({this.controller, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: controller,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: NavIcon("Receipts", "receipts"),
          ),
          BottomNavigationBarItem(
            icon: NavIcon("Scan QR", "qr_scan"),
          ),
          BottomNavigationBarItem(
            icon: NavIcon("Businesses", "business"),
          ),
        ],
        onTap: onTap,
      ),
      tabBuilder: (context, i) {
        return CupertinoTabView(
          builder: (context) {
            return _getView(i);
          },
        );
      },
    );
  }

  Widget _getView(int index) {
    switch (index) {
      case 0:
        return Receipts();
      case 1:
        return CustomerScanReceipt();
      case 2:
        return Businesses();
    }
    return CupertinoPageScaffold(child: Container());
  }
}

class BusinessLayout extends StatelessWidget {

  final CupertinoTabController controller;
  final Function(int) onTap;

  BusinessLayout({this.controller, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: controller,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: NavIcon("Create", "create_receipt"),
          ),
          BottomNavigationBarItem(
            icon: NavIcon("Scan QR", "qr_scan"),
          ),
          BottomNavigationBarItem(
            icon: NavIcon("Announcements", "announcement"),
          ),
        ],
        onTap: onTap,
      ),
      tabBuilder: (context, i) {
        return CupertinoTabView(
          builder: (context) {
            return _getView(i);
          },
        );
      },
    );
  }

  Widget _getView(int index) {
    switch (index) {
      case 0:
        return CreateReceipt();
      case 1:
        return BusinessScanReceipt();
      case 2:
        return Announcements();
    }
    return CupertinoPageScaffold(child: Container());
  }
}

class NavIcon extends StatelessWidget {

  final String image;
  final String title;

  NavIcon(this.title, this.image);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: image == "qr_scan" ? qrImage(context) : Column(
        children: [
          Container(
            height: 28,
            width: 28,
            child: Center(
              child: Image.asset("assets/icons/$image.png", color: IconTheme.of(context).color,),
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget qrImage(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Container(
          height: 28,
          width: 28,
          child: Image.asset("assets/icons/$image.png", color: white),
        ),
      ),
    );
  }

}