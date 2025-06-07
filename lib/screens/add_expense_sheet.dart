import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/add_tag_dialog.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? expense;

  const AddExpenseSheet({Key? key, this.expense}) : super(key: key);

  @override
  _AddExpenseSheetState createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  late TextEditingController _amountController;
  late TextEditingController _payeeController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;
  String? _selectedTagId;
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _isExpense = widget.expense!.amount < 0;
      _amountController =
          TextEditingController(text: widget.expense!.amount.abs().toString());
    } else {
      _amountController = TextEditingController();
    }
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
              widget.expense == null ? 'Add Transaction' : 'Edit Transaction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 24),
            // This now calls our new, robust toggle widget
            buildTransactionTypeToggle(),
            SizedBox(height: 16),
            buildTextField(_amountController, 'Amount',
                TextInputType.numberWithOptions(decimal: true)),
            if (_isExpense)
              buildTextField(
                  _payeeController, 'Payee (Optional)', TextInputType.text),
            buildTextField(
                _noteController, 'Note (Optional)', TextInputType.text),
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
              onPressed: _saveTransaction,
              child: Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET REWRITTEN TO FIX OVERFLOW ---
  Widget buildTransactionTypeToggle() {
    // This custom implementation using Row and Expanded is more robust
    // and prevents layout overflows.
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isExpense) setState(() => _isExpense = true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isExpense ? Colors.red[400] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isExpense ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isExpense) setState(() => _isExpense = false);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isExpense ? Colors.green[400] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Income',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !_isExpense ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveTransaction() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Amount and Category are required!')));
      return;
    }

    final double amount = double.tryParse(amountText) ?? 0.0;
    final double finalAmount = _isExpense ? -amount : amount;

    final expense = Expense(
      id: widget.expense?.id ?? DateTime.now().toString(),
      amount: finalAmount,
      categoryId: _selectedCategoryId!,
      payee: _payeeController.text,
      note: _noteController.text,
      date: _selectedDate,
      tag: _selectedTagId ?? '',
    );

    Provider.of<ExpenseProvider>(context, listen: false)
        .addOrUpdateExpense(expense);
    Navigator.pop(context);
  }

  // Helper methods are unchanged
  Widget buildTextField(
      TextEditingController controller, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: type,
      ),
    );
  }

  Widget buildDateField(BuildContext context, DateTime selectedDate) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[600]!, width: 0.6),
            borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }

  Widget buildCategoryDropdown(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder: (context) => AddCategoryDialog(onAdd: (newCategory) {
              provider.addCategory(newCategory);
              setState(() => _selectedCategoryId = newCategory.id);
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
          child: Text("＋ Add New Category",
              style: TextStyle(color: const Color(0xFF2E9A91))),
        )),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildTagDropdown(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedTagId,
      onChanged: (newValue) {
        if (newValue == 'New') {
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
          child: Text("＋ Add New Tag",
              style: TextStyle(color: const Color(0xFF2E9A91))),
        )),
      decoration: InputDecoration(
        labelText: 'Tag (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}