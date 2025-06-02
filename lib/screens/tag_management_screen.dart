import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_tag_dialog.dart';

class TagManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Tags"),
        backgroundColor: Colors.deepPurple, // Themed color similar to your inspirations
        foregroundColor: Colors.white,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.tags.length,
            itemBuilder: (context, index) {
              final tag = provider.tags[index];
              return ListTile(
                title: Text(tag.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Delete the tag
                    provider.deleteTag(tag.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTagDialog(
              onAdd: (newTag) {
                Provider.of<ExpenseProvider>(context, listen: false).addTag(newTag);
                Navigator.pop(context); // Close the dialog after adding the new tag
              },
            ),
          );
        },
        tooltip: 'Add New Tag',
        child: Icon(Icons.add),
      ),
    );
  }
}