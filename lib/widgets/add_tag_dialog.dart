import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';

class AddTagDialog extends StatefulWidget {
  final Function(Tag) onAdd;

  AddTagDialog({required this.onAdd});

  @override
  _AddTagDialogState createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Tag'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Tag Name',
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            var newTag = Tag(id: DateTime.now().toString(), name: _controller.text);
            widget.onAdd(newTag);
            // Update the provider and UI
            Provider.of<ExpenseProvider>(context, listen: false).addTag(newTag);
            // Clear the input field for next input
            _controller.clear();

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}