import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FlutterSyncService {}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await backupSqliteToFirebase();
    return Future.value(true);
  });
}

Future<void> backupSqliteToFirebase() async {
  // Open the SQLite database
  print('Start backing ip to Firebase complete');
  await Firebase.initializeApp();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'transactions.db'),
  );

  // Query all rows from the table you want to back up
  final List<Map<String, dynamic>> data = await database.query('transactions');

  // Use Firebase Firestore to backup the data
  final CollectionReference firebaseCollection =
      FirebaseFirestore.instance.collection('transactions');

  // First, delete all documents in the Firebase collection
  final QuerySnapshot existingData = await firebaseCollection.get();
  for (var doc in existingData.docs) {
    print("deleting firebase item" + doc.toString());
    await doc.reference.delete(); // Delete each document
  }

  for (var entry in data) {
    await firebaseCollection.add(entry); // Add each row to Firestore
  }
  print('Backup to Firebase complete');
}

Future<void> restoreDataFromFirebase() async {
  // Open SQLite database
  await Firebase.initializeApp();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'transactions.db'),
  );

  // Clear existing data in the SQLite table
  await database.delete('transactions');

  // Fetch data from Firebase Firestore
  final CollectionReference firebaseCollection =
      FirebaseFirestore.instance.collection('transactions');

  QuerySnapshot snapshot = await firebaseCollection.get();

  for (var doc in snapshot.docs) {
    // Insert data into SQLite database
    await database.insert(
      'transactions',
      doc.data() as Map<String, dynamic>, // Ensure the data is a Map
    );
  }

  print('Data restored from Firebase');
}
