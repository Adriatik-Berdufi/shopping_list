import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItamState();
  }
}

class _NewItamState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _enterName = '';
  var _enterQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final url = Uri.https(
          'flutter-projects-a2fcc-default-rtdb.firebaseio.com',
          'shopping_list.json');
      final response = await http.post(
        url,
        headers: {'Contetnt-Type': 'application/json'},
        body: json.encode({
          'name': _enterName,
          'quantity': _enterQuantity,
          'category': _selectedCategory.title,
        }),
      );

      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      Navigator.of(context).pop(GroceryItem(
        id: responseData['name'],
        name: _enterName,
        quantity: _enterQuantity,
        category: _selectedCategory,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 2 ||
                      value.trim().length > 50) {
                    return 'Must be between 2 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enterName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enterQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'positive int';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enterQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        label: Text('Select Category'),
                      ),
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: category.value.color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(category.value.title),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 18),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    child: _isLoading
                        ? const Text('Saving...')
                        : const Row(
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 6),
                              Text('Add Item')
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
