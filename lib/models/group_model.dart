class GroupModel {
  final String id; // معرف المجموعة (من Firestore أو default)
  final String name; // اسم المجموعة
  final String? icon; // إيموجي أو أيقونة
  final String? asset; // صورة محلية (assets) إذا موجودة

  GroupModel({
    required this.id,
    required this.name,
    this.icon,
    this.asset,
  });

  /// إنشاء كائن من Firestore (doc + بيانات)
  factory GroupModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return GroupModel(
      id: docId,
      name: map["name"] ?? "",
      icon: map["icon"],
      asset: map["asset"],
    );
  }

  /// إنشاء كائن من Map عادية (مثلاً للمجموعات الافتراضية)
  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      icon: map["icon"],
      asset: map["asset"],
    );
  }

  /// تحويل الكائن إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "icon": icon,
      "asset": asset,
    };
  }
}
