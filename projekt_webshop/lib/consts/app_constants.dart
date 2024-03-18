import 'package:projekt_webshop/models/categories_model.dart';
import 'package:projekt_webshop/services/assets_manager.dart';

class AppConstants {
  static const String imageUrl =
      'https://i.ibb.co/8r1Ny2n/20-Nike-Air-Force-1-07.png';

  static List<String> bannersImages = [
    AssetsManagers.banner2,
    AssetsManagers.banner1
  ];

  // LISTA KATEGORIJA
  static List<CategoriesModel> categoriesList = [
    CategoriesModel(
      id: "Phones",
      name: "Phones",
      image: AssetsManagers.mobiles,
    ),
    CategoriesModel(
      id: "Laptops",
      name: "Laptops",
      image: AssetsManagers.pc,
    ),
    CategoriesModel(
      id: "Electronics",
      name: "Electronics",
      image: AssetsManagers.electronics,
    ),
    CategoriesModel(
      id: "Watches",
      name: "Watches",
      image: AssetsManagers.watch,
    ),
    CategoriesModel(
      id: "Clothes",
      name: "Clothes",
      image: AssetsManagers.fashion,
    ),
    CategoriesModel(
      id: "Shoes",
      name: "Shoes",
      image: AssetsManagers.shoes,
    ),
    CategoriesModel(
      id: "Books",
      name: "Books",
      image: AssetsManagers.book,
    ),
    CategoriesModel(
      id: "Cosmetics",
      name: "Cosmetics",
      image: AssetsManagers.cosmetics,
    ),
  ];
}
