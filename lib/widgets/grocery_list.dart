import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/edit_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/widgets/removed_list.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> items = [];
  List<GroceryItem> removedItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void addInRemovedItem(GroceryItem item) async {
    final url = Uri.https('testproject-6a8d8-default-rtdb.firebaseio.com',
        'removed-shopping-list.json');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'name': item.name,
          'quantity': item.quantity,
          'category': item.category.name,
        },
      ),
    );
    if (response.statusCode >= 400) {
      if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Grocery addition in History failed'),
        ));
    }
  }

  void loadItems() async {
    final url = Uri.https(
        'testproject-6a8d8-default-rtdb.firebaseio.com', 'shopping-list.json');

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
        items = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) {
        return const NewItem();
      }),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      items.add(newItem);
    });
  }

  void removeItem(GroceryItem item) async {
    final groceryIndex = items.indexOf(item);
    var undoPressed = false;
    setState(() {
      items.remove(item);
      removedItems.add(item);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Grocery Deleted.'),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undoPressed = true;
            setState(() {
              items.insert(groceryIndex, item);
              removedItems.remove(item);
            });
          }),
    ));

    final url = Uri.https('testproject-6a8d8-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    await Future.delayed(const Duration(seconds: 3));
    if (!undoPressed) {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        setState(() {
          items.insert(groceryIndex, item);
          removedItems.remove(item);
        });
        if (!context.mounted) {
          return;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Grocery Deletion failed'),
        ));
      } else {
        addInRemovedItem(item);
      }
    }
  }

  void editItem(int index) async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItem(
          id: items[index].id,
          name: items[index].name,
          quantity: items[index].quantity,
          category: items[index].category,
        ),
      ),
    );
    if (newItem != null) {
      setState(() {
        items[index] = newItem;
      });
    }
  }

  void onClickHistory() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RemovedList(removedItems: removedItems)));
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
        child: Text(
      'No Items Added Yet.. ',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      content = Center(
          child: Text(
        _error!,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      ));
    }

    if (items.isNotEmpty) {
      content = ListView.builder(
        itemCount: items.length,
        itemBuilder: ((ctx, index) {
          return Dismissible(
            key: ValueKey(items[index]),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 179, 57, 48),
                    Color.fromARGB(255, 190, 58, 49)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              //margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 207, 207),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 199, 199),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            onDismissed: (direction) {
              removeItem(items[index]);
            },
            child: GestureDetector(
              onLongPress: () {
                editItem(index);
              },
              child: ListTile(
                title: Text(items[index].name),
                leading: Container(
                  height: 20,
                  width: 20,
                  color: items[index].category.color,
                ),
                trailing: Text(
                  items[index].quantity.toString(),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          );
        }),
      );
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: onClickHistory, icon: const Icon(Icons.history)),
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: Column(
          children: [
            Expanded(child: content),
            const Padding(
              padding: EdgeInsets.only(bottom: 13),
              child: Text(
                'Long Press a item to edit.',
                style: TextStyle(color: Color.fromARGB(255, 93, 160, 255)),
              ),
            )
          ],
        ));
  }
}
