import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:projekt_webshop/providers/wishlist_provider.dart';
import 'package:projekt_webshop/services/assets_manager.dart';
import 'package:projekt_webshop/services/my_app_functions.dart';
import 'package:projekt_webshop/widgets/empty_bag.dart';
import 'package:projekt_webshop/widgets/products/product_widget.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:provider/provider.dart';


class WishlistScreen extends StatelessWidget {
  static const routName = "/WishlistScreen";
  const WishlistScreen ({super.key});

  final bool isEmpty = true;

  @override
  Widget build(BuildContext context) {
  final wishlistProvider = Provider.of<WishlistProvider>(context);

    return wishlistProvider.getWishlis.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManagers.bagWish,
              title: 'Nothing in ur wishlist yet',
              subtitle: 'Looks like your cart is empty add something inside',
              buttonText: 'Shop now',
            ),
          )
        : Scaffold(
            appBar: AppBar(
              // ikonica kraj naslova
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AssetsManagers.shoppingCart,
                ),
              ),
              title:  TitlesTextWidget(label: "Wishlist (${wishlistProvider.getWishlis.length})"),
              actions: [
                IconButton(
                  onPressed: () {
                    MyAppFunctions.showErrorOrWarningDialog(
                      isError: false,
                      context: context,
                      subtitle: "Clear wishlist?",
                      fct: () async{
                        await wishlistProvider.clearWishlistFromFirebase();
                        wishlistProvider.clearLocalWishlist();
                      }
                    );
                  },
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          body: DynamicHeightGridView(
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    builder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProductWidget(
                          productId: wishlistProvider.getWishlis.values
                            .toList()[index]
                            .productId,
                        ),
                      );
                    },
                    itemCount: wishlistProvider.getWishlis.length,
                    crossAxisCount: 2,
          ),
          );
  }
}
