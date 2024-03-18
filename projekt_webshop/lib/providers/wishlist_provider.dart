import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projekt_webshop/models/wishlist_model.dart';
import 'package:projekt_webshop/services/my_app_functions.dart';
import 'package:uuid/uuid.dart';

class WishlistProvider with ChangeNotifier {
  final Map<String, WishlistModel> _wishlistItems = {}; // kreiramo mapu
  Map<String, WishlistModel> get getWishlis { //kreiramo getter za mapu
    return _wishlistItems;
  }

  final userDb = FirebaseFirestore.instance.collection("users");
  final _auth = FirebaseAuth.instance;
  // Firebase
  Future<void> addToWishlistFirebase (
    {required String productId,
    required BuildContext context,
    }) async {
      final User? user = _auth.currentUser;
      if(user == null) {
        MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: "Please login first",
          fct: (){},
        );
        return;
      }
      final uid = user.uid;
      final wishlistId = const Uuid().v4();
      try {
        await userDb.doc(uid).update({
          'userWish': FieldValue.arrayUnion([
            {
            'wishlistId': wishlistId,
            'productId': productId,
      
            }
          ])
        });
        Fluttertoast.showToast(msg: "Item has been added");
      } catch (e) {
        rethrow;
      }
    }

  Future<void> fetchWishlist() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      _wishlistItems.clear();
      return;
    }
    try {
      final userDoc = await userDb.doc(user.uid).get();
      final data = userDoc.data();
      if (data == null || !data.containsKey('userWish')) {
        return;
      }
      final leng = userDoc.get("userWish").length;
      for (int index = 0; index < leng; index++) {
        _wishlistItems.putIfAbsent(
            userDoc.get("userWish")[index]['productId'],
            () => WishlistModel(
              wishlistId: userDoc.get("userWish")[index]['wishlistId'],
              productId: userDoc.get("userWish")[index]['productId'],
            ));
      }
    }
    catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> removeWishlistItemFromFirestore({
    required String wishlistId,
    required String productId,
  }) async {
    final User? user = _auth.currentUser;
    try {
        await userDb.doc(user!.uid).update({
          'userWish': FieldValue.arrayRemove([
            {
            'wishlistId': wishlistId,
            'productId': productId,
            }
          ])
        });
        _wishlistItems.remove(productId);
        Fluttertoast.showToast(msg: "Item has been removed");
      } catch (e) {
        rethrow;
      }
  }
  Future<void> clearWishlistFromFirebase () async {
    final User? user = _auth.currentUser;
    try {
        await userDb.doc(user!.uid).update({
          'userWish': [],
        });
        _wishlistItems.clear();
        Fluttertoast.showToast(msg: "Wishlist has been cleaned");
      } catch (e) {
        rethrow;
      }
  }



  // Funkcija za dodavanje i uklanjanje proizvoda iz wishlist-e
  void addOrRemoveFromWishlist({required String productId}) {
    if (_wishlistItems.containsKey(productId)){
      _wishlistItems.remove(productId);
    }else {
      _wishlistItems.putIfAbsent(
      productId,
        () => WishlistModel(
          wishlistId: const Uuid().v4(),
          productId: productId
          ),
        );
    }
     notifyListeners(); // s ovom funkcijom vidimo update direktno na ekranu
  }

  // Funkcija koja provjerava nalazi li se proizvod na wishlist-i ili ne
  bool isProdinWishlist({required String productId}) {
    return _wishlistItems.containsKey(productId);
  }

  // Funkcija za uklanjanje svih proizvoda sa lokalne wishlite-e
  void clearLocalWishlist (){
    _wishlistItems.clear();
    notifyListeners();
  }
}