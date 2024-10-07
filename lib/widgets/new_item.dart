import 'package:flutter/material.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItamState();
  }
}

class _NewItamState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('add new item'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('form'),
      ),
    );
  }
}
