import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Payments Page Content'),
    );
  }
}
