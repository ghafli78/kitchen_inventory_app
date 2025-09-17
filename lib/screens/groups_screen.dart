import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/group_model.dart';
import '../widgets/group_card.dart';
import 'items_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final userId = "demoUser";

  /// المجموعات الأساسية (باستخدام GroupModel)
  final List<GroupModel> defaultGroups = [
    GroupModel(id: "cook", name: "طبخ", asset: "assets/images/groups/cook.png"),
    GroupModel(
        id: "cleaning", name: "تنظيف", asset: "assets/images/groups/clean.png"),
    GroupModel(
        id: "tools", name: "أدوات", asset: "assets/images/groups/tools.png"),
    GroupModel(
        id: "health",
        name: "الصحة والعناية",
        asset: "assets/images/groups/health.png"),
  ];

  Future<void> addGroup() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("groups")
        .add({
      "name": "مجموعة جديدة",
      "icon": "📦",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              color: Colors.blue.shade50,
              child: const Center(
                child: Text(
                  "eBook",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text("المجموعات"),
          ],
        ),
      ),
      body: ListView(
        children: [
          // ✅ المجموعات الثابتة (GroupCard)
          GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: defaultGroups.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, i) {
              final g = defaultGroups[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemsScreen(group: g), // ✅ تعديل هنا
                    ),
                  );
                },
                child: GroupCard(group: g),
              );
            },
          ),

          // ✅ المجموعات الإضافية من Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .collection("groups")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("لا توجد مجموعات إضافية"));
              }

              final docs = snapshot.data!.docs;

              return Column(
                children: docs.map((doc) {
                  final group = GroupModel.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: Text(group.icon ?? "📦",
                          style: const TextStyle(fontSize: 22)),
                      title: Text(group.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ItemsScreen(group: group), // ✅ تعديل هنا
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "تعديل المجموعة",
                            onPressed: () {
                              final controller =
                                  TextEditingController(text: group.name);
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("تعديل المجموعة"),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                        labelText: "اسم المجموعة"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("إلغاء"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(userId)
                                            .collection("groups")
                                            .doc(group.id)
                                            .update({"name": controller.text});
                                        Navigator.pop(context);
                                      },
                                      child: const Text("حفظ"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "حذف المجموعة",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("تأكيد الحذف"),
                                  content: const Text(
                                      "هل أنت متأكد أنك تريد حذف هذه المجموعة؟"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("لا",
                                          style: TextStyle(color: Colors.blue)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(userId)
                                            .collection("groups")
                                            .doc(group.id)
                                            .delete();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("نعم"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addGroup,
        child: const Icon(Icons.add),
      ),
    );
  }
}
