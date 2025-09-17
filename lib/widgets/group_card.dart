import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../screens/items_screen.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final String userId = "demoUser"; // ✅ عشان نجيب بيانات Firestore

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ItemsScreen(group: group), // ✅ نمرر GroupModel كامل
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (group.asset != null && group.asset!.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    group.asset!,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            else
              const Expanded(
                child: Icon(Icons.folder, size: 60, color: Colors.blueGrey),
              ),
            const SizedBox(height: 8),

            // ✅ اسم المجموعة
            Text(
              group.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // ✅ عرض الإحصائيات (ناقص / متوسط)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("groups")
                  .doc(group.id)
                  .collection("items")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final docs = snapshot.data!.docs;

                // نحسب كم عنصر "ناقص" و "متوسط"
                final missingCount =
                    docs.where((doc) => (doc['status'] ?? '') == "ناقص").length;
                final mediumCount = docs
                    .where((doc) => (doc['status'] ?? '') == "متوسط")
                    .length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (missingCount > 0)
                      Text(
                        "🔴 $missingCount",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (missingCount > 0 && mediumCount > 0)
                      const SizedBox(width: 12),
                    if (mediumCount > 0)
                      Text(
                        "🟠 $mediumCount",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
