import 'package:flutter/cupertino.dart';
import 'package:receiptify/data_classes.dart';

const String baseURL = "https://qrcoder-server.herokuapp.com/";
final String securityCode = "A3D263103C27E77EF8B6267C051906C0";

const double edge_padding = 15;
const double card_spacing = 15;
const double horizontal_margin = 14;
const double vertical_margin = 16;
const double item_spacing = 16;
const double selector_height = 60;

const Color green = Color.fromRGBO(0, 223, 100, 1);
const Color red = Color(0xFFFC5B5B);
const Color title = Color(0xFF545454);
const Color subtitle = Color(0xFF787878);
const Color background = Color(0xFFF7F7F7);
const Color canvas = white;
const Color white = Color(0xFFFFFFFF);

class RightArrow {
  RightArrow._();

  static const _kFontFam = 'Arrow';
  static const _kFontPkg = null;

  static const IconData right_arrow = IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}

final mockReceipts = [
  Receipt(
    dateIssued: "10/01/2021",
    businessName: "Business Name",
    address: Address(
      street: "5555 XYZ Avenue",
      city: "Dallas",
      state: "Texas",
      zip: "75025",
    ),
    phone: "469-946-2354",
    subtotal: 40.0,
    total: 42.89,
    order: [
      Product("Sample Product", 12.99, 2),
      Product("Sample Product", 2.99, 1),
      Product("Sample Product", 112.99, 3)
    ],
    coupons: [
      Coupon(
        details: "50% Off Next Purchase",
        expirationDate: "10/11/2021",
      ),
    ],
  ),
  Receipt(
    dateIssued: "10/01/2021",
    businessName: "Business Name",
    address: Address(
      street: "5555 XYZ Avenue",
      city: "Dallas",
      state: "Texas",
      zip: "75025",
    ),
    phone: "469-946-2354",
    subtotal: 40.0,
    total: 42.89,
    order: [
      Product("Sample Product", 12.99, 2),
      Product("Sample Product", 2.99, 1),
      Product("Sample Product", 112.99, 3)
    ],
    coupons: [
      Coupon(
        details: "50% Off Next Purchase",
        expirationDate: "10/11/2021",
      ),
    ],
  ),
  Receipt(
    dateIssued: "10/01/2021",
    businessName: "Business Name",
    address: Address(
      street: "5555 XYZ Avenue",
      city: "Dallas",
      state: "Texas",
      zip: "75025",
    ),
    phone: "469-946-2354",
    subtotal: 40.0,
    total: 42.89,
    order: [
      Product("Sample Product", 12.99, 2),
      Product("Sample Product", 2.99, 1),
      Product("Sample Product", 112.99, 3)
    ],
    coupons: [
      Coupon(
        details: "50% Off Next Purchase",
        expirationDate: "10/11/2021",
      ),
    ],
  ),
];