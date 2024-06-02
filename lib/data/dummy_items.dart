import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'Curd',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryItem(
      id: 'b',
      name: 'Apples',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: 'Pulses',
      quantity: 2,
      category: categories[Categories.carbs]!),
  GroceryItem(
      id: 'd',
      name: 'Potatoes',
      quantity: 5,
      category: categories[Categories.vegetables]!),
];
