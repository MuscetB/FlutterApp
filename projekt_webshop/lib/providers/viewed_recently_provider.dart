import 'package:flutter/material.dart';
import 'package:projekt_webshop/models/viewed_products.dart';
import 'package:uuid/uuid.dart';

class ViewedProdProvider with ChangeNotifier {
  final Map<String, ViewedProdModel> _viewedProdItems = {}; // kreiramo mapu
  
  Map<String, ViewedProdModel> get getViewedProds { //kreiramo getter za mapu
    return _viewedProdItems;
  }
  
  // Funkcija za dodavanje i uklanjanje proizvoda iz ViewedProd-e
  void addViewedProd({required String productId}) {
    
      _viewedProdItems.putIfAbsent(
      productId,
        () => ViewedProdModel(
          viewedProdId: const Uuid().v4(),
          productId: productId
          ),
        );
    
     notifyListeners(); // s ovom funkcijom vidimo update direktno na ekranu
  }




}