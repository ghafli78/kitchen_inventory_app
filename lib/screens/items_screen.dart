import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/item_model.dart';
import '../models/group_model.dart'; // ✅ استدعاء الموديل
import '../widgets/item_card.dart';

class ItemsScreen extends StatefulWidget {
  final GroupModel group; // ✅ استبدلنا groupId بالكائن كامل

  const ItemsScreen({super.key, required this.group});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final userId = "demoUser";

  Map<String, bool> selected = {};

  Future<void> addItem() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc(widget.group.id) // ✅ استخدم id من الكائن
        .collection("items")
        .add(ItemModel(
          id: "",
          name: "صنف جديد",
          status: "كافي",
          place: "",
          qty: 0,
          price: 0.0,
          imageUrl: "",
        ).toMap());
  }

  Future<void> updateItem(String docId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc(widget.group.id) // ✅
        .collection("items")
        .doc(docId)
        .update(data);
  }

  Future<void> deleteItem(String docId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .doc(widget.group.id) // ✅
        .collection("items")
        .doc(docId)
        .delete();
  }

  Future<String?> uploadImage(String docId) async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("اختر مصدر الصورة"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text("📷 الكاميرا"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text("📂 المعرض"),
          ),
        ],
      ),
    );
    if (source == null) return null;

    final picked = await picker.pickImage(source: source);
    if (picked == null) return null;

    final file = File(picked.path);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("users/$userId/groups/${widget.group.id}/images/$docId.jpg");
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      Navigator.pop(context);
      return url;
    } catch (_) {
      Navigator.pop(context);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ الهيدر صار يعرض صورة المجموعة بشكل أكبر + اسم المجموعة
        title: Row(
          children: [
            if (widget.group.asset != null) ...[
              Image.asset(widget.group.asset!,
                  width: 40, height: 40), // ✅ مكبرة
              const SizedBox(width: 8),
            ],
            Text("الأصناف لـ ${widget.group.name}"),
          ],
        ),
        actions: [
          // ✅ مربع تحديد الكل
          Checkbox(
            value:
                selected.isNotEmpty && selected.values.every((v) => v == true),
            onChanged: (val) {
              setState(() {
                final check = val ?? false;
                for (final entry in selected.keys) {
                  selected[entry] = check;
                }
              });
            },
          ),

          // ✅ زر الحذف مع تأكيد
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: "حذف المحدد",
            onPressed: selected.containsValue(true)
                ? () async {
                    final idsToDelete = selected.entries
                        .where((entry) => entry.value == true)
                        .map((entry) => entry.key)
                        .toList();

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("تأكيد الحذف"),
                        content: Text(
                          "هل أنت متأكد أنك تريد حذف (${idsToDelete.length}) من الأصناف؟",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("إلغاء"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              for (final id in idsToDelete) {
                                await deleteItem(id);
                              }

                              setState(() {
                                for (final id in idsToDelete) {
                                  selected.remove(id);
                                }
                              });

                              Navigator.pop(context);
                            },
                            child: const Text("تأكيد"),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("groups")
            .doc(widget.group.id) // ✅
            .collection("items")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد أصناف حالياً"));
          }

          final docs = snapshot.data!.docs;
          final items = docs
              .map((doc) => ItemModel.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          for (final item in items) {
            selected.putIfAbsent(item.id, () => false);
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isChecked = selected[item.id] ?? false;

              return ItemCard(
                key: ValueKey(item.id),
                item: item,
                isSelected: isChecked,
                onSelect: (val) {
                  setState(() {
                    selected[item.id] = val ?? false;
                  });
                },
                onNotes: () {
                  final placeController =
                      TextEditingController(text: item.place ?? "");
                  final qtyController = TextEditingController(
                      text: (item.qty != null && item.qty != 0)
                          ? item.qty.toString()
                          : "");
                  final priceController = TextEditingController(
                      text: (item.price != null && item.price != 0.0)
                          ? item.price.toString()
                          : "");

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("📝 تفاصيل الصنف"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: placeController,
                            decoration: const InputDecoration(
                              labelText: "🏠 المكان",
                              hintText: "أدخل مكان الصنف",
                            ),
                          ),
                          TextField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "📦 الكمية",
                              hintText: "أدخل الكمية",
                            ),
                          ),
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "💰 السعر",
                              hintText: "أدخل السعر",
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("إلغاء"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            updateItem(item.id, {
                              "place": placeController.text,
                              "qty": int.tryParse(qtyController.text) ?? 0,
                              "price":
                                  double.tryParse(priceController.text) ?? 0.0,
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("حفظ"),
                        ),
                      ],
                    ),
                  );
                },
                onEdit: () async {
                  final nameController = TextEditingController(text: item.name);
                  String? tempImageUrl = item.imageUrl;

                  showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setStateDialog) => AlertDialog(
                        title: const Text("✏️ تعديل الصنف"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "اسم الصنف",
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final url = await uploadImage(item.id);
                                if (url != null) {
                                  setStateDialog(() => tempImageUrl = url);
                                }
                              },
                              icon: const Icon(Icons.image),
                              label: const Text("تغيير الصورة"),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("إلغاء"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              updateItem(item.id, {
                                "name": nameController.text,
                                "imageUrl": tempImageUrl ?? "",
                              });
                              Navigator.pop(context);
                            },
                            child: const Text("حفظ"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onStatusChange: (newStatus) {
                  updateItem(item.id, {"status": newStatus});
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
