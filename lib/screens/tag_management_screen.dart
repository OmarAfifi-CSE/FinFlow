import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';
import '../utils/app_constants.dart';

class TagManagementScreen extends StatelessWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E9A91);
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    // FIX: Removed the Scaffold and AppBar. This widget now only returns
    // the content to be displayed.
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withValues(alpha: 0.15),
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
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

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
