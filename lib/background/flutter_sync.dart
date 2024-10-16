import 'package:flutter/material.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:spend_wise/model/transaction_repository_firebase.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spend_wise/model/user_configs_repository_firebase.dart';

class FlutterSyncService {}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await backupSqliteToFirebase();
    return Future.value(true);
  });
}

Future<void> backupUserLogins() async {
  print('Start user logins backing up to Firebase >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
  await Firebase.initializeApp();
  String path = join(await getDatabasesPath(), 'transactions.db');
  final database = await openDatabase(path, version: 6);

  try {
    // Fetch user data from SQLite
    final List<Map<String, dynamic>> users = await database.query('user');
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('user');

    for (var user in users) {
      UserDto userDto = UserDto.fromJson(user);
      // Delete existing documents with the same username
      QuerySnapshot snapshot = await userCollection.where('username', isEqualTo: userDto.username).get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Add the new user data to Firebase
      await userCollection.add(userDto.toJson());
    }
  } catch (e) {
    print("Error during backup: $e");
  }
}

Future<void> backupSqliteToFirebase() async {
  FirebaseRepository firebaseRepository = FirebaseRepository();
  // Open the SQLite database
  print('Start backing ip to Firebase >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
  await Firebase.initializeApp();
  String path = join(await getDatabasesPath(), 'transactions.db');
  final database = await openDatabase(path, version: 6);
  // Query all rows from the table you want to back up
  final List<Map<String, dynamic>> newData = await database.query('transactions', where: "isSynced = ?", whereArgs: [0]);

  // Use Firebase Firestore to backup the data
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = Settings(persistenceEnabled: true);

  final CollectionReference firebaseCollection = FirebaseFirestore.instance.collection('transactions');
  try {
    // Backup new data
    for (var entry in newData) {
      TransactionDto txn = TransactionDto.fromJson(entry);
      saveTransaction(txn);
      int id = entry['id'];

      await database.update(
        'transactions',
        {'isSynced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  } catch (e) {
    print("Error during backup: $e");
  }
  // Open the SQLite database
  final List<Map<String, dynamic>> deletedRecords =
      await database.query('transactions', where: "isDeleted = ? AND isSynced = ?", whereArgs: [1, 1]);

  // Sync deleted record with firebase
  for (var record in deletedRecords) {
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
  try {
    await backupUserLogins();
  } catch (e) {
    print("Error during user backup: $e");
  }
  print('Backup to Firebase complete');
}

Future<void> restoreDataFromFirebase(String userId) async {
  // Open SQLite database
  await Firebase.initializeApp();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'transactions.db'),
  );

  // Clear existing data in the SQLite table
  await database.delete('transactions', where: "userId = ?", whereArgs: [userId]);

  // Fetch data from Firebase Firestore
  final CollectionReference firebaseCollection = FirebaseFirestore.instance.collection('transactions');

  QuerySnapshot snapshot = await firebaseCollection.where('userId', isEqualTo: userId).get();

  for (var doc in snapshot.docs) {
    // Insert data into SQLite database
    await database.insert(
      'transactions',
      doc.data() as Map<String, dynamic>, // Ensure the data is a Map
    );
  }

  print('Data restored from Firebase');
}
