import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
/* import 'package:shopping_list/models/category.dart'; */
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https('flutter-projects-a2fcc-default-rtdb.firebaseio.com',
        'shopping_list.json');

    final response = await http.get(url);
    final Map<String, dynamic> listData = jsonDecode(response.body);
    /* print(listData); */
    final List<GroceryItem> loadeditems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((el) => el.value.title == item.value['category'])
          .value;
      loadeditems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItem = loadeditems;
    });
  }

  void _addNewItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    _groceryItem.add(newItem);
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItem.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No item added yet!!!'),
    );
    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItem[index].id),
          onDismissed: (direction) => {
            _removeItem(_groceryItem[index]),
          },
          child: ListTile(
            title: Text(_groceryItem[index].name),
            leading: Container(
              width: 33,
              height: 33,
              color: _groceryItem[index].category.color,
            ),
            trailing: Text(
              _groceryItem[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries!'),
          actions: [
            IconButton(
              onPressed: _addNewItem,
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: content);
  }
}
