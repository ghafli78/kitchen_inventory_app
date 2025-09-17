import 'package:flutter/material.dart';

class KitchenScreen extends StatefulWidget {
  final List<List<dynamic>> csvTable;

  const KitchenScreen({Key? key, required this.csvTable}) : super(key: key);

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  late List<List<dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = widget.csvTable.sublist(1); // حذف الهيدر
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📦 نظام الجرد الذكي - المطبخ"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            dataRowHeight: 100,
            headingRowColor: MaterialStateColor.resolveWith(
              (_) => Colors.grey.shade300,
            ),
            border: TableBorder.all(color: Colors.grey.shade400, width: 1),
            columns: const [
              DataColumn(label: Text('📷 الصورة')),
              DataColumn(label: Text('اسم الصنف')),
              DataColumn(label: Text('❌ ناقص')),
              DataColumn(label: Text('⚠️ متوسط')),
              DataColumn(label: Text('✅ كافي')),
              DataColumn(label: Text('المكان')),
              DataColumn(label: Text('الكمية')),
              DataColumn(label: Text('السعر')),
              DataColumn(label: Text('الملاحظات')),
              DataColumn(label: Text('🛠️ أدوات')),
            ],
            rows: List.generate(data.length, (index) {
              final row = data[index];

              final notes = row[0].toString();
              final price = row[1].toString();
              final qty = row[2].toString();
              final place = row[3].toString();
              final isGreen = _toBool(row[4]);
              final isOrange = _toBool(row[5]);
              final isRed = _toBool(row[6]);
              final itemName = row[7].toString();
              final imageUrl = row[8].toString();

              return DataRow(
                cells: [
                  DataCell(
                    Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                  DataCell(Text(itemName)),
                  DataCell(
                    _buildExclusiveCheckbox(
                      index,
                      "red",
                      isRed,
                      Colors.red.shade100,
                    ),
                  ),
                  DataCell(
                    _buildExclusiveCheckbox(
                      index,
                      "orange",
                      isOrange,
                      Colors.orange.shade100,
                    ),
                  ),
                  DataCell(
                    _buildExclusiveCheckbox(
                      index,
                      "green",
                      isGreen,
                      Colors.green.shade100,
                    ),
                  ),
                  DataCell(Text(place)),
                  DataCell(Text(qty)),
                  DataCell(Text(price)),
                  DataCell(Text(notes)),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // زر التعديل
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editRowDialog(index),
                        ),
                        // زر الحذف
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              data.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  bool _toBool(dynamic value) {
    final str = value.toString().toLowerCase();
    return str == 'true' || str == '✅';
  }

  Widget _buildExclusiveCheckbox(
    int rowIndex,
    String type,
    bool value,
    Color background,
  ) {
    return Container(
      color: value ? background : null,
      child: Checkbox(
        value: value,
        onChanged: (newVal) {
          setState(() {
            // إعادة تعيين الثلاثة
            data[rowIndex][6] = false; // ناقص
            data[rowIndex][5] = false; // متوسط
            data[rowIndex][4] = false; // كافي

            if (type == "red") data[rowIndex][6] = newVal;
            if (type == "orange") data[rowIndex][5] = newVal;
            if (type == "green") data[rowIndex][4] = newVal;
          });
        },
      ),
    );
  }

  /// نافذة تعديل الصف
  void _editRowDialog(int index) {
    final notesController = TextEditingController(
      text: data[index][0].toString(),
    );
    final priceController = TextEditingController(
      text: data[index][1].toString(),
    );
    final qtyController = TextEditingController(
      text: data[index][2].toString(),
    );
    final placeController = TextEditingController(
      text: data[index][3].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("✏️ تعديل الصنف"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "الملاحظات"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "السعر"),
            ),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: "الكمية"),
            ),
            TextField(
              controller: placeController,
              decoration: const InputDecoration(labelText: "المكان"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("حفظ"),
            onPressed: () {
              setState(() {
                data[index][0] = notesController.text;
                data[index][1] = priceController.text;
                data[index][2] = qtyController.text;
                data[index][3] = placeController.text;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
