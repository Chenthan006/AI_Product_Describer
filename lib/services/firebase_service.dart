import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_descriptor/models/product_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Save product to Firestore
  Future<void> saveProduct(ProductModel product) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('history')
        .doc(product.id)
        .set(product.toMap());
  }

  // Get all saved products
  Future<List<ProductModel>> getSavedProducts() async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('history')
        .doc(id)
        .delete();
  }
}