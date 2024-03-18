import 'package:flutter/material.dart';
import 'package:projekt_webshop/providers/cart_provider.dart';
import 'package:projekt_webshop/providers/products_provider.dart';
import 'package:projekt_webshop/widgets/subtitle_text.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:provider/provider.dart';

class CartBottomSheetWidget extends StatelessWidget {
  const CartBottomSheetWidget({super.key, required this.function});
  final Function function;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);


    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: kBottomNavigationBarHeight +
              10, //ovo nam pozicionira naš widget pri dnu ekrana
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                        child: TitlesTextWidget(
                            label: "Total (${cartProvider.getCartitems.length} products/${cartProvider.getQty()} items)")), //informacije u donjem dijelu košarice
                    SubtitleTextWidget(
                      label: "${cartProvider.getTotal(productsProvider: productsProvider).toStringAsFixed(2)}\$", //cijena artikla * količina
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async{
                  await function();
                },
                child: const Text("Checkout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
