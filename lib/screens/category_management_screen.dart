import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart'; // Make sure this import is correct

class CategoryManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9A91);
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Manage Categories"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
              final formattedName = toTitleCase(category.name);
              final icon = categoryIcons[formattedName] ?? Icons.category;
              final theme =
                  categoryThemes[formattedName] ??
                  defaultCategoryThemes[category.name.hashCode %
                      defaultCategoryThemes.length];

              return Dismissible(
                key: Key(category.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red[700],
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmationDialog(context, category);
                },
                // UPDATED: This now calls our new helper method
                onDismissed: (direction) {
                  _deleteCategoryAndShowSnackBar(context, provider, category);
                },
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                      tooltip: 'Delete Category',
                      // UPDATED: This also calls our new helper method
                      onPressed: () async {
                        final bool? shouldDelete =
                            await _showDeleteConfirmationDialog(
                              context,
                              category,
                            );
                        // Check if context is still valid before using it, a good practice after an await
                        if (shouldDelete == true && context.mounted) {
                          _deleteCategoryAndShowSnackBar(
                            context,
                            provider,
                            category,
                          );
                        }
                      },
                    ),
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
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteCategoryAndShowSnackBar(
    BuildContext context,
    ExpenseProvider provider,
    ExpenseCategory category,
  ) {
    provider.deleteCategory(category.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text('"${category.name}" deleted.'),
        backgroundColor: Colors.black87,
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    ExpenseCategory category,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
          'Do you want to delete the category "${category.name}"? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, ExpenseProvider provider) {
    final TextEditingController categoryNameController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            controller: categoryNameController,
            decoration: InputDecoration(hintText: "e.g., 'Health'"),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                final name = toTitleCase(categoryNameController.text.trim());
                if (name.isNotEmpty) {
                  final newCategory = ExpenseCategory(
                    id: DateTime.now().toIso8601String(),
                    name: name,
                    isDefault: false,
                  );
                  provider.addCategory(newCategory);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
