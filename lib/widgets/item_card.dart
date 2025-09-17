import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemCard extends StatefulWidget {
  final ItemModel item;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;
  final VoidCallback onNotes;
  final VoidCallback onEdit;
  final ValueChanged<String> onStatusChange;

  const ItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelect,
    required this.onNotes,
    required this.onEdit,
    required this.onStatusChange,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  late bool _checked;
  bool _isHovered = false; // ✅ حالة hover

  @override
  void initState() {
    super.initState();
    _checked = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _checked = widget.isSelected;
    }
  }

  /// خلفية حسب حالة الصنف
  Color _getBackgroundColor() {
    switch (widget.item.status) {
      case "ناقص":
        return Colors.red.shade50;
      case "متوسط":
        return Colors.orange.shade50;
      case "كافي":
        return Colors.green.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        elevation: _isHovered ? 8 : (_checked ? 6 : 2), // ✅ ظل أقوى عند hover
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // ✅ الضغط يحدد/يلغي التحديد
            setState(() => _checked = !_checked);
            widget.onSelect(_checked);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _checked
                  ? Colors.blue.shade50
                  : (_isHovered ? Colors.grey.shade100 : _getBackgroundColor()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _checked ? Colors.blue : Colors.grey.shade300,
                width: _checked ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // ✅ Checkbox للتحديد
                Checkbox(
                  value: _checked,
                  onChanged: (val) {
                    setState(() => _checked = val ?? false);
                    widget.onSelect(val);
                  },
                ),
                const SizedBox(width: 6),

                // ✅ صورة الصنف مع تكبير عند الضغط
                GestureDetector(
                  onTap: () {
                    if (widget.item.imageUrl != null &&
                        widget.item.imageUrl!.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          insetPadding: const EdgeInsets.all(20),
                          child: InteractiveViewer(
                            child: Image.network(
                              widget.item.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: (widget.item.imageUrl != null &&
                              widget.item.imageUrl!.isNotEmpty)
                          ? Image.network(
                              widget.item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ اسم الصنف
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ✅ الحالات (ناقص / متوسط / كافي)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusCheckbox("ناقص", Colors.red),
                      _buildStatusCheckbox("متوسط", Colors.orange),
                      _buildStatusCheckbox("كافي", Colors.green),
                    ],
                  ),
                ),

                // ✅ زر الملاحظات
                IconButton(
                  icon: const Icon(Icons.sticky_note_2, color: Colors.amber),
                  tooltip: "ملاحظات",
                  onPressed: widget.onNotes,
                ),

                // ✅ زر التعديل
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: "تعديل الاسم/الصورة",
                  onPressed: widget.onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// صورة افتراضية
  Widget _placeholder() {
    return Container(
      color: Colors.blue.shade50,
      child: const Center(
        child: Text(
          "eBook",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// مربعات الحالة
  Widget _buildStatusCheckbox(String status, Color color) {
    return Checkbox(
      activeColor: color,
      value: widget.item.status == status,
      onChanged: (_) => widget.onStatusChange(status),
    );
  }
}
