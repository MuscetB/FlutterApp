import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:projekt_webshop/providers/viewed_recently_provider.dart';
import 'package:projekt_webshop/services/assets_manager.dart';
import 'package:projekt_webshop/widgets/empty_bag.dart';
import 'package:projekt_webshop/widgets/products/product_widget.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:provider/provider.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = "/ViewedRecentlyScreen";
  const ViewedRecentlyScreen ({super.key});

  final bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);
    return viewedProdProvider.getViewedProds.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManagers.orderBag,
              title: 'No viewed products yet!',
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
              title:  TitlesTextWidget(label: "Viewed recently (${viewedProdProvider.getViewedProds.length})"),
              actions: [
                IconButton(
                  onPressed: () {
                    // MyAppFunctions.showErrorOrWarningDialog(
                    //   isError: false,
                    //   context: context,
                    //   subtitle: "Clear wishlist?",
                    //   fct: () {
                    //     wishlistProvider.clearLocalWishlist();
                    //   }
                    // );
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
                          productId: viewedProdProvider.getViewedProds.values.toList()[index].productId,),
                      );
                    },
                    itemCount: viewedProdProvider.getViewedProds.length,
                    crossAxisCount: 2,
          ),
          );
  }
}
