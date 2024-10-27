import 'package:flutter/material.dart';
import 'package:spend_wise/model/transaction_repository.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:spend_wise/container_page.dart';
import 'dart:io';

class DetailedRecord extends StatelessWidget {
  final String id;
  final String source;
  final String type;
  final String note;
  final String datetime;
  final double amount;
  final String currency;
  final String? attchementUrl;
  final iconPath;
  final Icon viewIcon;

  DetailedRecord({
    required this.id,
    required this.source,
    required this.type,
    required this.note,
    required this.datetime,
    required this.amount,
    required this.currency,
    required this.attchementUrl,
    required this.iconPath,
    required this.viewIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
              radius: 20,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ClipOval(
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                datetime.substring(0, 10),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(amount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: viewIcon,
            onPressed: () {
              String path = attchementUrl.toString();
              File savedImage = File('$path');
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                      color: Colors.brown,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.get_app_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              source,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount : $amount\n\nType : $type\n\nDate : $datetime\n\nNote : $note\n',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: savedImage != null
                                ? Image.file(
                                    savedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(child: Text('No image')),
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.brown),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_outlined, color: Colors.brown),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                      color: Colors.brown,
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confirm Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to delete this item?',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.brown),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          print(TransactionRepository().deleteTransaction(int.parse(id)));

                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => MyApp(), // Replace with your page
                            ),
                          );
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
