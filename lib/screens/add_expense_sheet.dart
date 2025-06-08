import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/add_tag_dialog.dart';
import '../utils/app_constants.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? expense;

  const AddExpenseSheet({Key? key, this.expense}) : super(key: key);

  @override
  _AddExpenseSheetState createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;
  String? _selectedTagId;
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  String? _errorMessage;

  late TabController _toggleTabController;

  @override
  void initState() {
    super.initState();
    // Get provider once to perform validation check
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    if (widget.expense != null) {
      _isExpense = widget.expense!.amount < 0;
    }

    _toggleTabController = TabController(
      initialIndex: _isExpense ? 0 : 1,
      length: 2,
      vsync: this,
    );

    _toggleTabController.addListener(() {
      if (_toggleTabController.index == 0 && !_isExpense) {
        setState(() {
          _isExpense = true;
        });
      } else if (_toggleTabController.index == 1 && _isExpense) {
        setState(() {
          _isExpense = false;
        });
      }
    });

    if (widget.expense != null) {
      _amountController = TextEditingController(
        text: widget.expense!.amount.abs().toString(),
      );
      _noteController = TextEditingController(text: widget.expense?.note ?? '');
      _selectedDate = widget.expense?.date ?? DateTime.now();

      // --- FIX: VALIDATE CATEGORY AND TAG IDs BEFORE ASSIGNING ---
      final savedCategoryId = widget.expense?.categoryId;
      // Check if a category with this ID still exists in the provider's list
      if (provider.categories.any((cat) => cat.id == savedCategoryId)) {
        _selectedCategoryId = savedCategoryId;
      } else {
        _selectedCategoryId = null; // If not, set to null to avoid crash
      }

      final savedTagId = widget.expense?.tag;
      // Check if a tag with this ID still exists in the provider's list
      if (provider.tags.any((tag) => tag.id == savedTagId)) {
        _selectedTagId = savedTagId;
      } else {
        _selectedTagId = null; // If not, set to null to avoid crash
      }
      // --- END OF FIX ---
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController(text: widget.expense?.note ?? '');
      _selectedDate = widget.expense?.date ?? DateTime.now();
      _selectedCategoryId = widget.expense?.categoryId;
      _selectedTagId = widget.expense?.tag;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _toggleTabController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.4,
              ),
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.expense == null ? 'Add Transaction' : 'Edit Transaction',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            buildTransactionTypeToggle(),
            SizedBox(height: 16),
            buildTextField(
              _amountController,
              'Amount',
              TextInputType.numberWithOptions(decimal: true),
            ),
            buildTextField(
              _noteController,
              'Note (Optional)',
              TextInputType.text,
            ),
            buildDateField(context, _selectedDate),
            SizedBox(height: 8),
            buildCategoryDropdown(context.watch<ExpenseProvider>()),
            SizedBox(height: 16),
            buildTagDropdown(context.watch<ExpenseProvider>()),
            SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
              child: Text(
                'Save Transaction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTransactionTypeToggle() {
    final Color indicatorColor = _isExpense
        ? Colors.red[400]!
        : Colors.green[400]!;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TabBar(
        controller: _toggleTabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: indicatorColor,
          boxShadow: [
            BoxShadow(
              color: indicatorColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: Colors.white,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.black54,
        tabs: const [
          Tab(text: "Expense"),
          Tab(text: "Income"),
        ],
      ),
    );
  }

  void _saveTransaction() {
    setState(() {
      _errorMessage = null;
    });
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'Amount and Category are required!';
      });
      return;
    }
    final double amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter an amount greater than zero.';
      });
      return;
    }
    final double finalAmount = _isExpense ? -amount : amount;
    final expense = Expense(
      id: widget.expense?.id ?? DateTime.now().toString(),
      amount: finalAmount,
      categoryId: _selectedCategoryId!,
      note: _noteController.text,
      date: _selectedDate,
      tag: _selectedTagId ?? '',
    );
    Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).addOrUpdateExpense(expense);
    Navigator.pop(context);
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
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
          borderRadius: BorderRadius.circular(12),
        ),
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
            builder: (context) => AddCategoryDialog(
              onAdd: (newCategory) {
                provider.addCategory(newCategory);
                setState(() => _selectedCategoryId = newCategory.id);
              },
            ),
          );
        } else {
          setState(() => _selectedCategoryId = newValue);
        }
      },
      items:
          provider.categories.map<DropdownMenuItem<String>>((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList()..add(
            DropdownMenuItem(
              value: "New",
              child: Text(
                "＋ Add New Category",
                style: TextStyle(color: const Color(0xFF2E9A91)),
              ),
            ),
          ),
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
            builder: (context) => AddTagDialog(
              onAdd: (newTag) {
                provider.addTag(newTag);
                setState(() => _selectedTagId = newTag.id);
              },
            ),
          );
        } else {
          setState(() => _selectedTagId = newValue);
        }
      },
      items:
          provider.tags.map<DropdownMenuItem<String>>((tag) {
            return DropdownMenuItem<String>(
              value: tag.id,
              child: Text(tag.name),
            );
          }).toList()..add(
            DropdownMenuItem(
              value: "New",
              child: Text(
                "＋ Add New Tag",
                style: TextStyle(color: const Color(0xFF2E9A91)),
              ),
            ),
          ),
      decoration: InputDecoration(
        labelText: 'Tag (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
