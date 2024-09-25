import 'package:flutter/material.dart';

class ModifyTransactionPage extends StatefulWidget {
  const ModifyTransactionPage({super.key});

  @override
  State<ModifyTransactionPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ModifyTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
      ),
      body: const Center(
        child: Text('Add Income Page here'),
      ),
    );
  }
}
