import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart'; // Ensure you have a Tag model
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart'; // For the toTitleCase helper

class TagManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9A91);
    // Grab the provider once here to pass into our helper methods
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Manage Tags"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, consumerProvider, child) {
          final allTags = consumerProvider.tags;

          if (allTags.isEmpty) {
            return Center(
              child: Text(
                "No tags yet.\nTap '+' to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: allTags.length,
            itemBuilder: (context, index) {
              final tag = allTags[index];

              return Dismissible(
                key: Key(tag.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red[700],
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmationDialog(context, tag);
                },
                onDismissed: (direction) {
                  _deleteTagAndShowSnackBar(context, provider, tag);
                },
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    // Using a standard tag icon for all tags
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.15),
                      child: Icon(Icons.tag, size: 20, color: primaryColor),
                    ),
                    title: Text(
                      tag.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                      tooltip: 'Delete Tag',
                      onPressed: () async {
                        final bool? shouldDelete =
                            await _showDeleteConfirmationDialog(context, tag);
                        if (shouldDelete == true && context.mounted) {
                          _deleteTagAndShowSnackBar(context, provider, tag);
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
        onPressed: () => _showAddTagDialog(context, provider),
        tooltip: 'Add New Tag',
        backgroundColor: primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }

  // Helper method to show the delete confirmation dialog for a Tag
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, Tag tag) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
          'Do you want to delete the tag "${tag.name}"? This action cannot be undone.',
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

  // Helper method that deletes the tag and shows a confirmation SnackBar
  void _deleteTagAndShowSnackBar(
    BuildContext context,
    ExpenseProvider provider,
    Tag tag,
  ) {
    provider.deleteTag(tag.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text('"${tag.name}" deleted.'),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // Helper method for showing the Add Tag dialog
  void _showAddTagDialog(BuildContext context, ExpenseProvider provider) {
    final TextEditingController tagNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add New Tag'),
          content: TextField(
            controller: tagNameController,
            decoration: InputDecoration(hintText: "e.g., 'Work' or 'Personal'"),
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
                final name = toTitleCase(tagNameController.text.trim());
                if (name.isNotEmpty) {
                  final newTag = Tag(
                    id: DateTime.now().toIso8601String(),
                    name: name,
                  );
                  provider.addTag(newTag);
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
