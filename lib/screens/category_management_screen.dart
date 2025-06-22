import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9A91);
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<ExpenseProvider>(
        builder: (context, consumerProvider, child) {
          final allCategories = consumerProvider.categories;

          if (allCategories.isEmpty) {
            return Center(
              child: Text(
                "No categories found.\nTap '+' to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final bool canDelete = category.isDefault != true;

              final formattedName = toTitleCase(category.name);
              final icon = categoryIcons[formattedName] ?? Icons.category;
              final theme =
                  categoryThemes[formattedName] ??
                  defaultCategoryThemes[category.name.hashCode %
                      defaultCategoryThemes.length];

              return Dismissible(
                key: Key(category.id),
                direction: canDelete
                    ? DismissDirection.endToStart
                    : DismissDirection.none,
                background: Container(
                  color: Colors.red[700],
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmationDialog(context, category);
                },
                onDismissed: (direction) {
                  _deleteCategoryAndShowSnackBar(context, provider, category);
                },
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.backgroundColor,
                      child: Icon(icon, size: 20, color: theme.color),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: canDelete
                        ? IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red[700],
                            ),
                            tooltip: 'Delete Category',
                            onPressed: () async {
                              final bool? shouldDelete =
                                  await _showDeleteConfirmationDialog(
                                    context,
                                    category,
                                  );
                              if (shouldDelete == true) {
                                _deleteCategoryAndShowSnackBar(
                                  context,
                                  provider,
                                  category,
                                );
                              }
                            },
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, provider),
        tooltip: 'Add New Category',
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteCategoryAndShowSnackBar(
    BuildContext context,
    ExpenseProvider provider,
    ExpenseCategory category,
  ) async {
    await provider.deleteCategory(category.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('"${category.name}" deleted.'),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    ExpenseCategory category,
  ) {
    if (category.isDefault == true) {
      return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cannot Delete'),
          content: const Text(
            'This is a default category and cannot be deleted.',
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      );
    }
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
          'Do you want to delete the category "${category.name}"? This action cannot be undone.',
        ),
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
  }

  void _showAddCategoryDialog(BuildContext context, ExpenseProvider provider) {
    final TextEditingController categoryNameController =
        TextEditingController();
    String? dialogErrorMessage;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: categoryNameController,
                    decoration: const InputDecoration(
                      hintText: "e.g., 'Health'",
                    ),
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
                    final name = toTitleCase(
                      categoryNameController.text.trim(),
                    );
                    if (name.isNotEmpty) {
                      final newCategory = await provider.addCategory(name);

                      if (newCategory != null) {
                        if (mounted) Navigator.of(dialogContext).pop();
                      } else {
                        setDialogState(() {
                          dialogErrorMessage = 'This category already exists.';
                        });
                      }
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
}
