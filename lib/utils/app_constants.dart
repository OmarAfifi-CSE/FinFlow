import 'package:flutter/material.dart';

// A simple class to hold the color theme for a category
class CategoryTheme {
  final Color color;
  final Color backgroundColor;

  const CategoryTheme({required this.color, required this.backgroundColor});
}

// 1. The list of default category names you provided.
//    All keys are in "Title Case" for consistent lookups.
const Map<String, IconData> categoryIcons = {
  'Food': Icons.fastfood,
  'Transport': Icons.train,
  'Shopping': Icons.shopping_bag,
  'Groceries': Icons.local_grocery_store,
  'Bills': Icons.receipt,
  'Entertainment': Icons.movie,
  'Health': Icons.healing,
  'Travel': Icons.airplanemode_active,
  'Education': Icons.school,
  'Gifts': Icons.card_giftcard,
  'Family': Icons.family_restroom,
  'Pets': Icons.pets,
  'Home': Icons.home,
  'Investments': Icons.trending_up,
  'Business': Icons.business_center,
  'Salary': Icons.attach_money,
  'Savings': Icons.savings,
};

// 2. Specific color themes for the default categories.
final Map<String, CategoryTheme> categoryThemes = {
  'Food': CategoryTheme(color: Colors.red[400]!, backgroundColor: Colors.red[50]!),
  'Transport': CategoryTheme(color: Colors.orange[400]!, backgroundColor: Colors.orange[50]!),
  'Shopping': CategoryTheme(color: Colors.blue[400]!, backgroundColor: Colors.blue[50]!),
  'Groceries': CategoryTheme(color: Colors.teal[400]!, backgroundColor: Colors.teal[50]!),
  'Bills': CategoryTheme(color: Colors.purple[400]!, backgroundColor: Colors.purple[50]!),
  'Entertainment': CategoryTheme(color: Colors.brown[400]!, backgroundColor: Colors.brown[50]!),
  'Health': CategoryTheme(color: Colors.pink[400]!, backgroundColor: Colors.pink[50]!),
  'Travel': CategoryTheme(color: Colors.indigo[400]!, backgroundColor: Colors.indigo[50]!),
  'Education': CategoryTheme(color: Colors.cyan[600]!, backgroundColor: Colors.cyan[50]!),
  'Gifts': CategoryTheme(color: Colors.yellow[800]!, backgroundColor: Colors.yellow[50]!),
  'Family': CategoryTheme(color: Colors.lightBlue[400]!, backgroundColor: Colors.lightBlue[50]!),
  'Pets': CategoryTheme(color: Colors.amber[600]!, backgroundColor: Colors.amber[50]!),
  'Home': CategoryTheme(color: Colors.lightGreen[600]!, backgroundColor: Colors.lightGreen[50]!),
  'Investments': CategoryTheme(color: Colors.lime[600]!, backgroundColor: Colors.lime[50]!),
  'Business': CategoryTheme(color: Colors.blueGrey[400]!, backgroundColor: Colors.blueGrey[50]!),
  'Salary': CategoryTheme(color: Colors.green[700]!, backgroundColor: Colors.green[50]!),
  'Savings': CategoryTheme(color: Colors.deepOrange[400]!, backgroundColor: Colors.deepOrange[50]!),
};

// 3. A pool of "random" colors for any new categories the user creates.
final List<CategoryTheme> defaultCategoryThemes = [
  CategoryTheme(color: Colors.lightBlue[600]!, backgroundColor: Colors.lightBlue[50]!),
  CategoryTheme(color: Colors.pink[400]!, backgroundColor: Colors.pink[50]!),
  CategoryTheme(color: Colors.amber[700]!, backgroundColor: Colors.amber[50]!),
  CategoryTheme(color: Colors.indigo[400]!, backgroundColor: Colors.indigo[50]!),
  CategoryTheme(color: Colors.cyan[600]!, backgroundColor: Colors.cyan[50]!),
];

// 4. Helper function to handle capitalization.
//    This converts any string ("food", "FOOD") to "Food".
String toTitleCase(String text) {
  if (text.isEmpty) return '';
  return text.split(' ')
      .map((word) => word.isNotEmpty
      ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
      : '')
      .join(' ');
}