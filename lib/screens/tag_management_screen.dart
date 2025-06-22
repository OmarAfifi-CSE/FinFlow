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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmationDialog(context, tag);
                },
                onDismissed: (direction) {
                  _deleteTagAndShowSnackBar(context, provider, tag);
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
                      backgroundColor: primaryColor.withAlpha(30),
                      child: const Icon(
                        Icons.tag,
                        size: 20,
                        color: primaryColor,
                      ),
                    ),
                    title: Text(
                      tag.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, Tag tag) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text(
          'Do you want to delete the tag "${tag.name}"? This action cannot be undone.',
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

  Future<void> _deleteTagAndShowSnackBar(
    BuildContext context,
    ExpenseProvider provider,
    Tag tag,
  ) async {
    await provider.deleteTag(tag.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('"${tag.name}" deleted.'),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  void _showAddTagDialog(BuildContext context, ExpenseProvider provider) {
    final TextEditingController tagNameController = TextEditingController();
    String? dialogErrorMessage;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Tag'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tagNameController,
                    decoration: const InputDecoration(
                      hintText: "e.g., 'Work' or 'Personal'",
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
                    final name = toTitleCase(tagNameController.text.trim());
                    if (name.isNotEmpty) {
                      final newTag = await provider.addTag(name);
                      if (newTag != null) {
                        if (context.mounted) Navigator.of(dialogContext).pop();
                      } else {
                        setDialogState(() {
                          dialogErrorMessage = 'This tag already exists.';
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
