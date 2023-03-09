class Product {
  String name;
  double price;
  int quentity = 1;
  int inStock;
  String imagesUrl;
  String documentId;
  String supplierId;
  Product({
    required this.name,
    required this.price,
    required this.quentity,
    required this.inStock,
    required this.imagesUrl,
    required this.documentId,
    required this.supplierId,
  });

  void increaseQuentity() {
    quentity++;
  }

  void decreaseQuentity() {
    quentity--;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
      "quentity": quentity,
      "inStock": inStock,
      "imagesUrl": imagesUrl,
      "documentId": documentId,
      "supplierId": supplierId,
    };
  }

  @override
  String toString() {
    return "Product{name $name , price $price ,quentity $quentity , inStock $inStock, imagesUrl $imagesUrl ,  documentId $documentId supplierId $supplierId}";
  }
}
