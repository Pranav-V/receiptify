class Customer {

  String name;
  String email;

  Customer(this.name, this.email);

}

class Business {

  String name;
  Address address;
  String phone;
  List<Product> products = [];

  Business(this.name, this.address, this.phone);

}

class Receipt {

  String hash;
  String dateIssued;
  String businessName;
  Address address;
  String phone;
  double subtotal;
  double total;
  List<Product> order;
  List<Coupon> coupons;

  Receipt({this.dateIssued, this.businessName, this.address,
      this.phone, this.subtotal, this.total, this.order, this.coupons}) {
    order = order ?? [];
    coupons = coupons ?? [];
  }

  Receipt.fromJson(Map<String, dynamic> json) {
    dateIssued = json["dateIssued"];
    businessName = json["businessName"];
    address = Address.fromJson(json["businessAddress"]);
    phone = json["businessPhone"];
    subtotal = json["subtotal"].toDouble();
    total = json["total"];
    order = (json["orderInfo"] as List).map<Product>((map) => Product.fromJson(map)).toList();
    coupons = (json["couponInfo"] as List).map<Coupon>((map) => Coupon.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["dateIssued"] = dateIssued;
    json["businessName"] = businessName;
    json["businessAddress"] = address.toJson();
    json["businessPhone"] = phone;
    json["subtotal"] = subtotal;
    json["total"] = total;
    json["orderInfo"] = order.map<Map<String, dynamic>>((product) => product.toJson()).toList();
    json["couponInfo"] = coupons.map<Map<String, dynamic>>((coupon) => coupon.toJson()).toList();
    return json;
  }

}

class Address {

  String street;
  String city;
  String state;
  String zip;

  Address({this.street, this.city, this.state, this.zip});

  Address.fromJson(Map<String, dynamic> json) {
    street = json["street"];
    city = json["city"];
    state = json["state"];
    zip = json["zip"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["street"] = street;
    json["city"] = city;
    json["state"] = state;
    json["zip"] = zip;
    return json;
  }

}

class Product {

  String name;
  double price;
  int quantity;

  Product(this.name, this.price, this.quantity);

  Product.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    price = json["price"].toDouble();
    quantity = json["quantity"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["name"] = name;
    json["price"] = price;
    json["quantity"] = quantity;
    return json;
  }

}

class Coupon {

  String details;
  String expirationDate;

  Coupon({this.details, this.expirationDate});

  Coupon.fromJson(Map<String, dynamic> json) {
    details = json["couponDetails"];
    expirationDate = json["expirationDate"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["couponDetails"] = details;
    json["expirationDate"] = expirationDate;
    return json;
  }

}

class Message {

  String businessName;
  String date;
  String text;

  Message(this.businessName, this.date, this.text);

  Message.fromJson(Map<String, dynamic> json) {
    businessName = json["businessName"];
    date = json["date"];
    text = json["text"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["businessName"] = businessName;
    json["date"] = date;
    json["text"] = text;
    return json;
  }

}

class BusinessSubscription {

  bool isSubscribed;
  String businessName;

  BusinessSubscription(this.isSubscribed, this.businessName);
}