import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:receiptify/constants.dart';
import 'package:receiptify/create_qrcode.dart';
import 'package:receiptify/data_classes.dart';
import 'package:receiptify/functions.dart';
import 'package:receiptify/main.dart';
import 'package:receiptify/widgets.dart';
import 'package:http/http.dart' as http;

class CreateReceipt extends StatefulWidget {

  @override
  _CreateReceiptState createState() => _CreateReceiptState();
}

class _CreateReceiptState extends State<CreateReceipt> {

  List<Product> productsOrdered = [];
  List<Coupon> couponsMade = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          SliverNavigationBar("Create Receipt"),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(edge_padding),
              child: Column(
                children: verticalSpace(card_spacing, [
                  productsOrdered.isNotEmpty ? _orderCard() : null,
                  ...(couponsMade.isNotEmpty ? couponsMade.map((coupon) => _couponCard(coupon)).toList() : []),
                  productsOrdered.isNotEmpty ? _createReceiptButton() : null,
                  ...Receiptify.instance.business.products.map((product) => _productCard(product)).toList(),
                  _addProductButton(),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard() {
    return GestureDetector(
      onTap: () async {
        final coupon = await showCustomDialog<Coupon>(context, CustomDialog("Add Coupon", AddCoupon()));
        couponsMade.add(coupon);
        setState(() {});
      },
      child: RoundCard(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Center(
                child: Text("+ Add Coupon"),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: vertical_margin, horizontal: horizontal_margin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Receiptify.instance.business.name, style: TextStyle(color: title, fontSize: 20),),
                          Text(currentDateString(), style: TextStyle(color: subtitle, fontSize: 15),),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("\$${(calculateTotal() * 1.06).toStringAsFixed(2)}", style: TextStyle(color: white, fontSize: 16),),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  ...verticalSpace(10, productsOrdered.map<Widget>((product) => Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("${product.quantity}x", style: TextStyle(color: white, fontSize: 14),),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Text(product.name, style: TextStyle(color: title, fontSize: 16),),
                      Spacer(),
                      Text("\$${product.price}", style: TextStyle(color: green, fontSize: 16),)
                    ],
                  )).toList()),
                  SizedBox(height: 32,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _couponCard(Coupon coupon) {
    return RoundCard(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontal_margin),
        child: Row(
          children: [
            Text(coupon.details, style: TextStyle(color: title, fontSize: 16),),
            Spacer(),
            Text(coupon.expirationDate, style: TextStyle(color: subtitle, fontSize: 16),)
          ],
        ),
      ),
    );
  }

  Widget _createReceiptButton() {
    return RoundCard(
      child: Padding(
        padding: const EdgeInsets.all(horizontal_margin),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            RoundButton(
              height: 45,
              text: "Create Receipt",
              onPress: () async {
                final receipt = Receipt(
                  dateIssued: currentDateString(),
                  businessName: Receiptify.instance.business.name,
                  address: Receiptify.instance.business.address,
                  phone: Receiptify.instance.business.phone,
                  subtotal: calculateTotal(),
                  total: calculateTotal() * 1.06,
                  order: productsOrdered,
                  coupons: couponsMade,
                );
                receipt.hash = await _getHashForReceipt(receipt);
                await showCustomDialog<String>(context, CustomDialog("Receipt", ShowQRCode(receipt.hash)));
                productsOrdered = [];
                couponsMade = [];
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                height: 30,
                width: 30,
                child: Center(
                  child: Image.asset("assets/icons/qr_code.png", color: white,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getHashForReceipt(Receipt receipt) async {
    var url = Uri.parse(baseURL + 'createHash');
    var json = receipt.toJson();
    json["securityCode"] = securityCode;
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(json),
    );
    final map = jsonDecode(response.body);
    return map["orderHash"];
  }

  Widget _productCard(Product product) {
    return GestureDetector(
      onTap: () async {
        final p = await showCustomDialog<Product>(context, CustomDialog("Select Product", SelectProduct(product)));
        productsOrdered.add(p);
        setState(() {});
      },
      child: RoundCard(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontal_margin),
          child: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text("+", style: TextStyle(color: white, fontSize: 14),),
                ),
              ),
              SizedBox(width: 8,),
              Text(product.name, style: TextStyle(color: title, fontSize: 16),),
              Spacer(),
              Text("\$${product.price}", style: TextStyle(color: green, fontSize: 16),)
            ],
          ),
        ),
      ),
    );
  }

  Widget _addProductButton() {
    return RoundCard(
      child: Padding(
        padding: const EdgeInsets.all(horizontal_margin),
        child: RoundButton(
          height: 45,
          text: "Add Product",
          onPress: () async {
            final product = await showCustomDialog<Product>(context, CustomDialog("Add Product", AddProduct()));
            Receiptify.instance.business.products.add(product);
            setState(() {});
          },
        ),
      ),
    );
  }

  double calculateTotal() {
    double sum = 0;
    for (Product p in productsOrdered) {
      sum += p.price * p.quantity;
    }
    return sum;
  }

}

class AddProduct extends StatelessWidget {

  final DialogTextController nameController;
  final DialogTextController priceController;

  AddProduct() : nameController = DialogTextController(), priceController = DialogTextController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DialogTextField(
          controller: nameController,
          placeholder: "Name",
        ),
        SizedBox(height: item_spacing),
        DialogTextField(
          controller: priceController,
          placeholder: "Price",
        ),
        SizedBox(height: item_spacing),
        RoundButton(
          text: "Done",
          height: 42,
          onPress: () {
            Navigator.of(context).pop(Product(
              nameController.text,
              double.parse(priceController.text),
              1,
            ));
          },
        )
      ],
    );
  }

}

class SelectProduct extends StatelessWidget {

  final Product product;
  final DialogTextController countController;

  SelectProduct(this.product) : countController = DialogTextController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DialogTextField(
          controller: countController,
          placeholder: "Count",
        ),
        SizedBox(height: item_spacing),
        RoundButton(
          text: "Done",
          height: 42,
          onPress: () {
            Navigator.of(context).pop(Product(
              product.name,
              product.price,
              int.parse(countController.text),
            ));
          },
        )
      ],
    );
  }
}

class AddCoupon extends StatelessWidget {

  final DialogTextController detailsController;
  final DialogTextController expirationController;

  AddCoupon() : detailsController = DialogTextController(), expirationController = DialogTextController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DialogTextField(
          controller: detailsController,
          placeholder: "Details",
        ),
        SizedBox(height: item_spacing),
        DialogTextField(
          controller: expirationController,
          placeholder: "Expiration",
        ),
        SizedBox(height: item_spacing),
        RoundButton(
          text: "Done",
          height: 42,
          onPress: () {
            Navigator.of(context).pop(Coupon(
              details: detailsController.text,
              expirationDate: expirationController.text,
            ));
          },
        )
      ],
    );
  }
}

class BusinessScanReceipt extends StatefulWidget {

  State<BusinessScanReceipt> createState() => _ScanReceipt();
}

class _ScanReceipt extends State<BusinessScanReceipt> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;
  bool isReceipt = true;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: green,
      child: CustomScrollView(
        slivers: [
          SliverNavigationBar("Scan QR Code"),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 80, right: 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundButton(
                        inverted: isReceipt,
                        height: 42,
                        width: 100,
                        text: "Receipt",
                        onPress: () => setState(() => isReceipt = true),
                      ),
                      RoundButton(
                        inverted: !isReceipt,
                        height: 42,
                        width: 100,
                        text: "Coupon",
                        onPress: () => setState(() => isReceipt = false),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 100),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                          borderColor: green,
                          borderRadius: 10,
                          borderWidth: 10.0
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller.stopCamera();
        _queryServer(result.code).then((response) {
          final receipt = _parseData(response);
          if (isReceipt) {
            showCustomDialog(context, CustomDialog("Validated Receipt", Column(
              children: [
                RoundButton(
                  text: "View",
                  height: 45,
                  onPress: () => Navigator.of(context).pop(),
                )
              ],
            ))).whenComplete(() {
              push(ReceiptView(receipt), context);
            });
          } else {
            showCustomDialog(context, CustomDialog("Verified Coupon!", Column(
              children: [
                Text(receipt.coupons[0].details, style: TextStyle(color: title, fontSize: 20)),
                Text("Exp: ${receipt.coupons[0].expirationDate}", style: TextStyle(color: subtitle, fontSize: 15)),
                RoundButton(
                  text: "Use and Deactivate",
                  height: 45,
                  onPress: () => Navigator.of(context).pop(),
                )
              ],
            )));
          }
        });
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<http.Response> _queryServer(String hash) async {
    var url = getAPI(baseURL, 'retrieveHashBusiness');
    return http.post(
      url,
      headers: <String, String> {
      'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'securityCode': 'A3D263103C27E77EF8B6267C051906C0',
        'hashCode': hash,
        'businessName': Receiptify.instance.business.name,
      }),
    );
  }

  Receipt _parseData(response) {
    final json = jsonDecode(response.body);
    return Receipt.fromJson(json['data']);
  }

}

class ReceiptView extends StatelessWidget {

  final Receipt receipt;

  ReceiptView(this.receipt);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(receipt.businessName),
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        brightness: Brightness.dark,
        border: null,
        leading: ArrowButton(direction: ArrowDirection.left, onPress: () => Navigator.of(context).pop(),),
      ),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _body(context),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(edge_padding),
      child: Column(
        children: verticalSpace(card_spacing, [
          Stack(
            alignment: Alignment.topRight,
            children: [
              RoundCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: vertical_margin, horizontal: horizontal_margin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20,),
                      Container(
                        decoration: BoxDecoration(
                          color: title,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Text(receipt.businessName, style: TextStyle(color: white, fontSize: 20),),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(receipt.address.street, style: TextStyle(color: title, fontSize: 20),),
                      Text("${receipt.address.city}, ${receipt.address.state} ${receipt.address.zip}", style: TextStyle(color: title, fontSize: 20),),
                      Text(receipt.phone, style: TextStyle(color: title, fontSize: 20),),
                      SizedBox(height: 20,),
                      ...verticalSpace(10, receipt.order.map<Widget>((product) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text("${product.quantity}x", style: TextStyle(color: white, fontSize: 14),),
                              ),
                            ),
                            SizedBox(width: 8,),
                            Text(product.name, style: TextStyle(color: title, fontSize: 16),),
                            Spacer(),
                            Text("\$${product.price}", style: TextStyle(color: green, fontSize: 16),)
                          ],
                        ),
                      )).toList()),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _dollarAmount(receipt.subtotal, "Subtotal"),
                            _dollarAmount(receipt.total - receipt.subtotal, "Tax 6%"),
                            _dollarAmount(receipt.total, "Total"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(receipt.dateIssued, style: TextStyle(color: subtitle, fontSize: 15)),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _dollarAmount(double amount, String sub) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(color: white, fontSize: 16),),
          ),
        ),
        SizedBox(height: 2,),
        Text(sub, style: TextStyle(color: subtitle, fontSize: 14),),
      ],
    );
  }

}

class Announcements extends StatefulWidget {
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {

  GlobalKey<CustomTabBarViewState> tabViewKey;
  Future<List<Message>> messagesFuture;

  @override
  void initState() {
    super.initState();
    tabViewKey = GlobalKey<CustomTabBarViewState>();
    messagesFuture = _getAllMessages();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          SliverNavigationBar("Announcements", onRefresh: () {
            setState(() {
              messagesFuture = _getAllMessages();
            });
          },),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _body(),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(edge_padding),
      child: FutureBuilder<List<Message>>(
        future: messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(green)));
          } else if (snapshot.hasData) {
            return Column(
              children: verticalSpace(card_spacing, [
                RoundCard(
                  child: Padding(
                    padding: const EdgeInsets.all(horizontal_margin),
                    child: RoundButton(
                      height: 45,
                      text: "Create Announcement",
                      onPress: () async {
                        await _createAnnouncement();
                      },
                    ),
                  ),
                ),
                ...snapshot.data.map((message) => _announcement(message)).toList(),
              ]),
            );
          } else {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(green)));
          }
        },
      ),
    );
  }

  Future<List<Message>> _getAllMessages() async {
    var url = getAPI(baseURL, 'allMessageSent');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'securityCode': securityCode,
        'businessName': Receiptify.instance.business.name,
      }),
    );

    var json = jsonDecode(response.body);
    return json['messageData'].map<Message>((e) => Message.fromJson(e)).toList();
  }

  Future _createAnnouncement() async {
    final messageString = await showCustomDialog<String>(context, CustomDialog("Create Announcement", CreateAnnouncement()));

    var date = DateTime.now();
    String dateStr = zeroPad(date.month, 2) + '/' + zeroPad(date.day, 2) + '/' + date.year.toString();

    var url = getAPI(baseURL, 'createMessage');
    http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic> {
        'securityCode': securityCode,
        'businessName': Receiptify.instance.business.name,
        'message': {
          'text': messageString,
          'date': dateStr,
          'businessName': Receiptify.instance.business.name
        }
      }),
    );
  }

  Widget _announcement(Message message) {
    return RoundCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(message.businessName, style: TextStyle(color: title, fontSize: 20)),
              Text(message.date, style: TextStyle(color: subtitle, fontSize: 15)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(message.text, style: TextStyle(color: title, fontSize: 14), textAlign: TextAlign.left,),
            ],
          )
        ],
      ),
    );
  }

}

class CreateAnnouncement extends StatelessWidget {

  final DialogTextController messageController;

  CreateAnnouncement() : messageController = DialogTextController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DialogTextField(
          controller: messageController,
          placeholder: "Message",
        ),
        SizedBox(height: item_spacing),
        RoundButton(
          text: "Done",
          height: 45,
          onPress: () => Navigator.of(context).pop(messageController.text),
        )
      ],
    );
  }
}
