import 'package:flutter/material.dart';

class CategoryIcon {
  static Widget getIcon(String category) {
    IconData iconData;
    Color color;

    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'transport':
      case 'transportation':
        iconData = Icons.directions_car;
        color = Colors.blue;
        break;
      case 'utilities':
        iconData = Icons.power;
        color = Colors.yellow[700]!;
        break;
      case 'entertainment':
        iconData = Icons.movie;
        color = Colors.purple;
        break;
      case 'shopping':
        iconData = Icons.shopping_bag;
        color = Colors.pink;
        break;
      case 'health':
      case 'healthcare':
        iconData = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'bills':
        iconData = Icons.receipt;
        color = Colors.blueGrey;
        break;
      case 'education':
        iconData = Icons.school;
        color = Colors.indigo;
        break;
      case 'travel':
        iconData = Icons.flight;
        color = Colors.cyan;
        break;
      default:
        iconData = Icons.category;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  static List<String> getCategories() {
    return [
      'Food',
      'Transport',
      'Utilities',
      'Entertainment',
      'Shopping',
      'Health',
      'Bills',
      'Education',
      'Travel',
      'Other',
    ];
  }
}
