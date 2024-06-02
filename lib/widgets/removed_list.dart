import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RemovedList extends StatefulWidget {
  const RemovedList({super.key, required this.removedItems});

  final List<GroceryItem> removedItems;

  @override
  State<RemovedList> createState() => _RemovedListState();
}

class _RemovedListState extends State<RemovedList> {
  List<GroceryItem> tempRemovedList = [];
  var _isLoading = true;
  String? _error;

  void removeItem(GroceryItem groceryItem) async {
    // final groceryIndex = tempRemovedList.indexOf(groceryItem);
    setState(() {
      tempRemovedList.remove(groceryItem);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Grocery Deleted from History.'),
      duration: Duration(seconds: 3),
    ));

    final url = Uri.https('testproject-6a8d8-default-rtdb.firebaseio.com',
        'removed-shopping-list/${groceryItem.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Grocery removal from History failed'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final url = Uri.https('testproject-6a8d8-default-rtdb.firebaseio.com',
        'removed-shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.name == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        tempRemovedList = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
        child: Text(
      'No Items Available in History Yet.. ',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ));

    if (_error != null) {
      content = Center(
          child: Text(
        _error!,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ));
    }

    if (tempRemovedList.isNotEmpty) {
      content = ListView.builder(
        itemCount: tempRemovedList.length,
        itemBuilder: ((ctx, index) {
          return Dismissible(
            key: ValueKey(tempRemovedList[index]),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.red],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              //margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            child: ListTile(
                title: Text(tempRemovedList[index].name),
                leading: Container(
                  height: 20,
                  width: 20,
                  color: tempRemovedList[index].category.color,
                ),
                trailing: Text(
                  tempRemovedList[index].quantity.toString(),
                  style: const TextStyle(fontSize: 15),
                )),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                removeItem(tempRemovedList[index]);
              }
              if (direction == DismissDirection.startToEnd) {
                removeItem(tempRemovedList[index]);
              }
            },
            // child: GestureDetector(
            //     onLongPress: () {
            //       onEditExpense(expenses[index]);
            //     },
            //     child: ExpenseItem(expenses[index]))
          );
        }),
      );
    }

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Groceries History'),
        ),
        body: content);
  }
}
