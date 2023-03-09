import 'package:flutter/foundation.dart';
import 'package:ms_customer_app/providers/products_class.dart';
import 'package:ms_customer_app/providers/sql_helper.dart';

class CartProvider extends ChangeNotifier {
  List<Product> _productsList = [];

  List<Product> get productsList {
    return _productsList;
  }

  int get count {
    return _productsList.length;
  }

  double get totalPrice {
    double total = 0;
    for (var item in _productsList) {
      total += item.price * item.quentity;
    }
    return total;
  }

  void addItem(Product product) async {
    await SQLHelper.insertItem(product)
        .whenComplete(() => _productsList.add(product));
    notifyListeners();
  }

  loadCartItems() async {
    List<Map> data = await SQLHelper.loadCartItems();
    _productsList = data.map((product) {
      return Product(
          name: product["name"],
          price: product["price"],
          quentity: product["quentity"],
          inStock: product["inStock"],
          imagesUrl: product["imagesUrl"],
          documentId: product["documentId"],
          supplierId: product["supplierId"]);
    }).toList();
    notifyListeners();
  }

  void incrementQuentity(Product product) async {
    await SQLHelper.updateItem(product, true)
        .whenComplete(() => product.increaseQuentity());
    notifyListeners();
  }

  void decrementQuentity(Product product) async {
    await SQLHelper.updateItem(product, false)
        .whenComplete(() => product.decreaseQuentity());

    notifyListeners();
  }

  void removeItem(Product product) async {
    await SQLHelper.deleteCartItem(product.documentId)
        .whenComplete(() => _productsList.remove(product));

    notifyListeners();
  }

  void clearCart() async {
    await SQLHelper.deleteAllCartItems()
        .whenComplete(() => _productsList.clear());
    notifyListeners();
  }
}
