import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditItem extends StatefulWidget {
  const EditItem(
      {super.key,
      required this.id,
      required this.name,
      required this.quantity,
      required this.category});

  final String id;
  final String name;
  final int quantity;
  final Category category;

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  final _formKey = GlobalKey<FormState>();
  //UP - required for validation check , as it helps form to retain its state(not rebuilt it)
  var _isSending = false;

  var _enteredName = '';
  var _enteredQuantity = 1;
  late Category selectedCategory;

  @override
  void initState() {
    super.initState();
    _enteredName = widget.name;
    _enteredQuantity = widget.quantity;
    selectedCategory = widget.category;
  }

  void _saveState() async {
    if (_formKey.currentState!.validate() == true) {
      //UP - validates all inputfields and return true if all field have passed the validation
      _formKey.currentState!.save();
      //UP - triggers onSave funtion when user taps on save button

      setState(() {
        _isSending = true;
      });
      // --- http
      final firebaseId = widget.id;

      final url = Uri.https('testproject-6a8d8-default-rtdb.firebaseio.com',
          'shopping-list/$firebaseId.json');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': selectedCategory.name,
          },
        ),
      );
      if (response.statusCode >= 400) {
        print(response.statusCode);
      }

      print(widget.id);

      if (!mounted) return;
      Navigator.of(context).pop(GroceryItem(
          id: widget.id,
          name: _enteredName,
          quantity: _enteredQuantity,
          category: selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit the item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  //form version of TextField()
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 2) {
                      return 'Enter Valid text';
                    } else {
                      return null;
                    }
                  },
                  initialValue: _enteredName,
                  onSaved: (value) {
                    _enteredName = value!;
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //imp - both textfield and its parent row is unconstained horizontally so we should use expanded to solve this issue
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quanity'),
                      ),
                      initialValue: _enteredQuantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Enter Valid positive Integer';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: selectedCategory,
                        hint: const Text('Select Category'),
                        items: [
                          //categories is map (not a iterable) but .entries make it iterable which is req for using in for loop
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              //this value will be availabe to onchanged funtion
                              child: Row(
                                children: [
                                  Container(
                                    height: 16,
                                    width: 16,
                                    color: category.value.color,
                                    //.value gives value of that map item , .key gives key of that map item
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.name)
                                ],
                              ),
                            )
                        ],
                        validator: (value) {
                          if (value == null) {
                            return 'Select a Category';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        }),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  ElevatedButton(
                      onPressed: _isSending ? null : _saveState,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Submit'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
