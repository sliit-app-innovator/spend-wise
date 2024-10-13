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
  print('Start backing ip to Firebase complete >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
  await Firebase.initializeApp();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'transactions.db'),
  );

  // Query all rows from the table you want to back up
  final List<Map<String, dynamic>> newData = await database.query('transactions', where: "isSynced = ?", whereArgs: [0]);

  // Use Firebase Firestore to backup the data
  final CollectionReference firebaseCollection = FirebaseFirestore.instance.collection('transactions');

  // Backup new data
  for (var entry in newData) {
    entry['isSynced'] = 1;
    await firebaseCollection.add(entry); // Add each row to Firestore

    int id = entry['id'];
    await database.update(
      'transactions',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  print('Completed updating New Record to FIrebase >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');

  // Open the SQLite database
  print('Start updating  ip Deleted records >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');

  final List<Map<String, dynamic>> deletedRecords =
      await database.query('transactions', where: "isDeleted = ? AND isSynced = ?", whereArgs: [1, 1]);

  print('deleted Records counts >>>>>>>>>>>>>>>>>>>>>>>>>> ' + deletedRecords.length.toString());

  // Sync deleted record with firebase
  for (var record in deletedRecords) {
    print('Each deleted Record  >>>>>>>>>>>>>>>>>>>>>>>>>> ' + record['id'].toString());
    try {
      // Assuming you have a unique transaction ID (e.g., 'transactionId')
      int id = record['id'];
      print('Deleted transactio from Firebase.' + id.toString());

      // Query the collection where the 'id' field equals 2
      QuerySnapshot querySnapshot = await firebaseCollection.where('id', isEqualTo: id).get();

      // Check if any document exists with the matching id
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate through the matching documents (if multiple, though typically there should be only one)
        for (var doc in querySnapshot.docs) {
          // Delete the document using its document ID
          await firebaseCollection.doc(doc.id).delete();
          print('Deleted document with id $id');

          // delete permenently for SQLlite
          await database.delete(
            'transactions',
            where: "id = ?",
            whereArgs: [id],
          );
        }
      } else {
        print('No document found with id = $id');
      }

      //  print('Deleted transaction $id from SQLite.');
    } catch (e) {
      print('Failed to delete transaction ${record['id'].toString()} from Firebase: $e');
    }
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
  final CollectionReference firebaseCollection = FirebaseFirestore.instance.collection('transactions');

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
