import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/dto/user.dart';

class FirebaseUserConfigsRepository {
  Future<void> saveUser(UserDto user) async {
    CollectionReference userCollection = FirebaseFirestore.instance.collection('user');
    userCollection.add(user.toJson());
    print("Storing User in cloude >>>>>>>>>>>>>>>>>>>>>>>");
  }

  Future<void> saveTransactionsFb(TransactionDto txt) async {
    CollectionReference txtCollection = FirebaseFirestore.instance.collection('transactions');
    txtCollection.add(txt.toJson());
    print("Storing User in cloude >>>>>>>>>>>>>>>>>>>>>>>");
  }

  Future<UserDto?> existingUser(UserDto user) async {
    print("Checking user existence in cloud >>>>>>>>>>>>>>>>>>>>>>>" + user.username);
    CollectionReference userCollection = FirebaseFirestore.instance.collection('user');

    // Query Firestore for the user with matching username or email
    QuerySnapshot querySnapshot = await userCollection.where('username', isEqualTo: user.username).get();

    if (querySnapshot.docs.isEmpty) {
      querySnapshot = await userCollection.where('email', isEqualTo: user.email).get();
    }

    if (querySnapshot.docs.isNotEmpty) {
      // The user exists, print or process the user data
      var userData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
      print("User found:1111 >>>>>>>>>>>>>>>>>>>>>>> $userData");
      if (userData != null) {
        UserDto foundUser = UserDto(
            id: userData['id'] ?? 1, // Providing default values if null
            firstName: userData['firstName'] ?? '',
            lastName: userData['lastName'] ?? '',
            username: userData['username'] ?? '',
            password: userData['password'] ?? '',
            email: userData['email'] ?? '');
        return foundUser;
      }
      return null;
      //return true; // User found
    } else {
      print("User not found.1111 >>>>>>>>>>>>>>>>>>>>>>>");
      return null; // User not found
    }
  }
}
