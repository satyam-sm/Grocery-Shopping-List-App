import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/models/category.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  //UP
  //- required for validation check , as it helps form to retain its state(not rebuilt it)

  var _isSending = false;
  var _enteredName = '';
  var _enteredQuantity = 1;
  late Category _selectedCategory;

  void _saveState() async {
    if (_formKey.currentState!.validate() == true) {
      //UP
      // - validates all inputfields and return true if all field have passed the validation
      _formKey.currentState!.save();
      //UP
      // - triggers onSave funtion when user taps on save button

      setState(() {
        _isSending = true;
      });
      // --- http
      final url = Uri.https('testproject-6a8d8-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.name,
          },
        ),
      );
      
      if (!mounted) return;
      //   DN
      //used to check if the BuildContext is still mounted(ie. same screen is present as before , context get unmounted on switching screen which may occer in await screen if we want to do ) before calling Navigator.of(context).pop()
      
        Navigator.of(context).pop(
          GroceryItem(
              id: json.decode(response.body)['name'],
              name: _enteredName,
              quantity: _enteredQuantity,
              category: _selectedCategory),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
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
                      initialValue: '1',
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
                        hint: const Text('Select Category'),
                        items: [
                          //up
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
                                    //up
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
                            _selectedCategory = value!;
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
                          : const Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
