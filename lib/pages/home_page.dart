import 'package:flutter/material.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.brown[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '\$59,765.00',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '2644  7545  3867  1965',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Spacer(),
                      Icon(Icons.credit_card, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Analytics
            const Text(
              'Analytics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 20),
            // Transactions
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  transactionItem('Puma Store', 'Bank Account', '\$952',
                      'assets/puma_logo.png'),
                  transactionItem('Nike Super Store', 'Credit Card', '\$475',
                      'assets/nike_logo.png'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Add transaction page naviation");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ), // Show the FAB only on the HomePage
    );
  }
}

Widget transactionItem(
    String store, String accountType, String amount, String logoPath) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(logoPath), // Store Logo
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              accountType,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
