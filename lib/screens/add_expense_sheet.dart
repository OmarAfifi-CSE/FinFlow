import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart';

const uuid = Uuid();

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
  late DateTime _selectedDate;
  late bool _isExpense;
  String? _errorMessage;

  bool _isSaving = false;

  late TabController _toggleTabController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    _isExpense = widget.expense?.amount == null || widget.expense!.amount < 0;

    _toggleTabController = TabController(
      initialIndex: _isExpense ? 0 : 1,
      length: 2,
      vsync: this,
    );

    _toggleTabController.addListener(() {
      if (_toggleTabController.indexIsChanging) {
        setState(() {
          _isExpense = _toggleTabController.index == 0;
        });
      }
    });

    if (widget.expense != null) {
      _amountController = TextEditingController(
        text: widget.expense!.amount.abs().toStringAsFixed(2),
      );
      _noteController = TextEditingController(text: widget.expense!.note);
      _selectedDate = widget.expense!.date;

      if (provider.categories.any(
        (cat) => cat.id == widget.expense!.categoryId,
      )) {
        _selectedCategoryId = widget.expense!.categoryId;
      }
      if (provider.tags.any((tag) => tag.id == widget.expense!.tag)) {
        _selectedTagId = widget.expense!.tag;
      }
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _toggleTabController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
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

    setState(() {
      _isSaving = true;
    });

    try {
      final double finalAmount = _isExpense ? -amount : amount;
      final expense = Expense(
        id: widget.expense?.id ?? uuid.v4(),
        amount: finalAmount,
        categoryId: _selectedCategoryId!,
        note: _noteController.text,
        date: _selectedDate,
        tag: _selectedTagId,
      );

      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).addOrUpdateExpense(expense);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving transaction: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This transaction will be permanently deleted.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red[700])),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true && widget.expense != null) {
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).deleteExpense(widget.expense!.id);

      if (mounted) {
        Navigator.pop(context);
      }
    }
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
            const SizedBox(height: 16),
            Text(
              widget.expense == null ? 'Add Transaction' : 'Edit Transaction',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            buildTransactionTypeToggle(),
            const SizedBox(height: 16),
            buildTextField(
              _amountController,
              'Amount',
              const TextInputType.numberWithOptions(decimal: true),
            ),
            buildTextField(
              _noteController,
              'Note (Optional)',
              TextInputType.text,
            ),
            buildDateField(context, _selectedDate),
            const SizedBox(height: 8),
            buildCategoryDropdown(context),
            const SizedBox(height: 16),
            buildTagDropdown(context),
            const SizedBox(height: 16),
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
            if (_isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E9A91),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveTransaction,
                      child: const Text(
                        'Save Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (widget.expense != null) ...[
                    const SizedBox(width: 16),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: _deleteTransaction,
                      icon: const Icon(Icons.delete_forever),
                      tooltip: 'Delete Transaction',
                    ),
                  ],
                ],
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.black54,
        tabs: const [
          Tab(text: "Expense"),
          Tab(text: "Income"),
        ],
      ),
    );
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
        trailing: const Icon(Icons.calendar_today, color: Color(0xFF2E9A91)),
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

  void _showAddNewDialog({
    required BuildContext context,
    required String title,
    required String hint,
    required ExpenseProvider provider,
    required Future<dynamic> Function(String) addFunction,
    required void Function(String) onSuccess,
  }) {
    final TextEditingController controller = TextEditingController();
    String? dialogErrorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: hint),
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  if (dialogErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        dialogErrorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    final name = toTitleCase(controller.text.trim());
                    if (name.isNotEmpty) {
                      // Call the provided add function (e.g., provider.addCategory)
                      final result = await addFunction(name);
                      if (result != null) {
                        // On success, close the dialog and call the onSuccess callback
                        if (mounted) Navigator.of(dialogContext).pop();
                        onSuccess(result.id);
                      } else {
                        // On failure, show an error inside the dialog
                        setDialogState(() {
                          dialogErrorMessage =
                              'An item with this name already exists.';
                        });
                      }
                    } else {
                      setDialogState(() {
                        dialogErrorMessage = 'Name cannot be empty.';
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildCategoryDropdown(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    return Consumer<ExpenseProvider>(
      builder: (context, consumerProvider, child) {
        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          onChanged: (newValue) {
            if (newValue == 'New') {
              _showAddNewDialog(
                context: context,
                title: 'Add New Category',
                hint: "e.g., 'Health'",
                provider: provider,
                addFunction: (name) => provider.addCategory(name),
                onSuccess: (newId) {
                  setState(() => _selectedCategoryId = newId);
                },
              );
            } else {
              setState(() => _selectedCategoryId = newValue);
            }
          },
          items:
              consumerProvider.categories.map<DropdownMenuItem<String>>((
                category,
              ) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList()..add(
                const DropdownMenuItem(
                  value: "New",
                  child: Text(
                    "＋ Add New Category",
                    style: TextStyle(color: Color(0xFF2E9A91)),
                  ),
                ),
              ),
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget buildTagDropdown(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    return Consumer<ExpenseProvider>(
      builder: (context, consumerProvider, child) {
        return DropdownButtonFormField<String?>(
          value: _selectedTagId,
          onChanged: (newValue) {
            if (newValue == 'New') {
              _showAddNewDialog(
                context: context,
                title: 'Add New Tag',
                hint: "e.g., 'Work'",
                provider: provider,
                addFunction: (name) => provider.addTag(name),
                onSuccess: (newId) {
                  setState(() => _selectedTagId = newId);
                },
              );
            } else {
              setState(() => _selectedTagId = newValue);
            }
          },
          items:
              consumerProvider.tags.map<DropdownMenuItem<String?>>((tag) {
                return DropdownMenuItem<String?>(
                  value: tag.id,
                  child: Text(tag.name),
                );
              }).toList()..add(
                const DropdownMenuItem(
                  value: "New",
                  child: Text(
                    "＋ Add New Tag",
                    style: TextStyle(color: Color(0xFF2E9A91)),
                  ),
                ),
              ),
          decoration: InputDecoration(
            labelText: 'Tag (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }
}
