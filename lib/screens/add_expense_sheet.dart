import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/add_tag_dialog.dart';

// The new widget designed to be used in a modal bottom sheet.
class AddExpenseSheet extends StatefulWidget {
  final Expense? expense;

  const AddExpenseSheet({Key? key, this.expense}) : super(key: key);

  @override
  _AddExpenseSheetState createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  // All state and controllers from your original screen are kept here.
  late TextEditingController _amountController;
  late TextEditingController _payeeController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;
  String? _selectedTagId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense?.amount.toString() ?? '');
    _payeeController = TextEditingController(text: widget.expense?.payee ?? '');
    _noteController = TextEditingController(text: widget.expense?.note ?? '');
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _selectedCategoryId = widget.expense?.categoryId;
    _selectedTagId = widget.expense?.tag;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payeeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.expense == null ? 'Add Expense' : 'Edit Expense',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24),
            buildTextField(_amountController, 'Amount',
                TextInputType.numberWithOptions(decimal: true)),
            buildTextField(_payeeController, 'Payee', TextInputType.text),
            buildTextField(_noteController, 'Note', TextInputType.text),
            buildDateField(context, _selectedDate),
            SizedBox(height: 8),
            buildCategoryDropdown(context.watch<ExpenseProvider>()),
            SizedBox(height: 16),
            buildTagDropdown(context.watch<ExpenseProvider>()),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9A91),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveExpense,
              child: Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_amountController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Amount and Category are required!')));
      return;
    }

    final expense = Expense(
      id: widget.expense?.id ?? DateTime.now().toString(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      payee: _payeeController.text,
      note: _noteController.text,
      date: _selectedDate,
      // FIX 1: Provide a default empty string if the tag is null.
      tag: _selectedTagId ?? '',
    );

    Provider.of<ExpenseProvider>(context, listen: false).addOrUpdateExpense(expense);
    Navigator.pop(context);
  }

  Widget buildTextField(
      TextEditingController controller, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: type,
      ),
    );
  }

  Widget buildDateField(BuildContext context, DateTime selectedDate) {
    return ListTile(
      title: Text("Date: ${DateFormat.yMMMd().format(selectedDate)}"),
      trailing: Icon(Icons.calendar_today, color: const Color(0xFF2E9A91)),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

  Widget buildCategoryDropdown(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          // FIX 2: Added the required 'context' and 'builder' arguments.
          showDialog(
            context: context,
            builder: (context) => AddCategoryDialog(onAdd: (newCategory) {
              setState(() {
                _selectedCategoryId = newCategory.id;
                provider.addCategory(newCategory);
              });
            }),
          );
        } else {
          setState(() => _selectedCategoryId = newValue);
        }
      },
      items: provider.categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList()
        ..add(DropdownMenuItem(
          value: "New",
          child: Text("＋ Add New Category", style: TextStyle(color: const Color(0xFF2E9A91))),
        )),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildTagDropdown(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedTagId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          // FIX 3: Added the required 'context' and 'builder' arguments.
          showDialog(
            context: context,
            builder: (context) => AddTagDialog(onAdd: (newTag) {
              provider.addTag(newTag);
              setState(() => _selectedTagId = newTag.id);
            }),
          );
        } else {
          setState(() => _selectedTagId = newValue);
        }
      },
      items: provider.tags.map<DropdownMenuItem<String>>((tag) {
        return DropdownMenuItem<String>(
          value: tag.id,
          child: Text(tag.name),
        );
      }).toList()
        ..add(DropdownMenuItem(
          value: "New",
          child: Text("＋ Add New Tag", style: TextStyle(color: const Color(0xFF2E9A91))),
        )),
      decoration: InputDecoration(
        labelText: 'Tag (Optional)',
        border: OutlineInputBorder(),
      ),
    );
  }
}