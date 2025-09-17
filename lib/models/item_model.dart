class ItemModel {
  final String id; // معرف المستند في Firestore
  final String name; // اسم الصنف
  final String status; // الحالة (ناقص / متوسط / كافي)
  final String? place; // المكان (اختياري)
  final int? qty; // الكمية (اختياري)
  final double? price; // السعر (اختياري)
  final String? imageUrl; // رابط الصورة (اختياري)

  ItemModel({
    required this.id,
    required this.name,
    required this.status,
    this.place,
    this.qty,
    this.price,
    this.imageUrl,
  });

  /// إنشاء كائن من Firestore
  factory ItemModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return ItemModel(
      id: docId,
      name: map["name"] ?? "",
      status: map["status"] ?? "كافي",
      place: map["place"],
      qty: map["qty"] is int
          ? map["qty"]
          : int.tryParse(map["qty"]?.toString() ?? ""),
      price: map["price"] is double
          ? map["price"]
          : double.tryParse(map["price"]?.toString() ?? ""),
      imageUrl: map["imageUrl"],
    );
  }

  /// تحويل الكائن إلى Map للتخزين في Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "status": status,
      "place": place,
      "qty": qty,
      "price": price,
      "imageUrl": imageUrl,
    };
  }
}
