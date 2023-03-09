import 'package:flutter/foundation.dart';
import 'package:ms_customer_app/providers/products_class.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlistList = [];

  List<Product> get wishlistList {
    return _wishlistList;
  }

  int get count {
    return _wishlistList.length;
  }

  double get totalPrice {
    double total = 0;
    for (var item in _wishlistList) {
      total += item.price * item.quentity;
    }
    return total;
  }

  void addWishItem(
    String name,
    double price,
    int quentity,
    int inStock,
    String imagesUrl,
    String documentId,
    String supplierId,
  ) {
    final product = Product(
        name: name,
        price: price,
        quentity: quentity,
        inStock: inStock,
        imagesUrl: imagesUrl,
        documentId: documentId,
        supplierId: supplierId);
    _wishlistList.add(product);
    notifyListeners();
  }

  void removeItem(Product product) {
    _wishlistList.remove(product);
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistList.clear();
    notifyListeners();
  }

  void removeFromWishlist(String id) {
    _wishlistList
        .removeWhere((wishlistProduct) => wishlistProduct.documentId == id);
    notifyListeners();
  }
}
