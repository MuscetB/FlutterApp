import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:projekt_webshop/providers/cart_provider.dart';
import 'package:projekt_webshop/providers/products_provider.dart';
import 'package:projekt_webshop/providers/viewed_recently_provider.dart';
import 'package:projekt_webshop/screens/inner_screen/product_details.dart';
import 'package:projekt_webshop/services/my_app_functions.dart';
import 'package:projekt_webshop/widgets/products/heart_btn.dart';
import 'package:projekt_webshop/widgets/subtitle_text.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:provider/provider.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    super.key,
    required this.productId,
    });
  final String productId;
  
  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    
    // final productModelProvider = Provider.of<ProductModel>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final getCurrProduct = productsProvider.findByProdId(widget.productId);
    final cartProvider = Provider.of<CartProvider>(context);
    
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    Size size = MediaQuery.of(context).size;
    return getCurrProduct == null
    ? const SizedBox.shrink()
    : Padding(
      padding: const EdgeInsets.all(0.0),
      child: GestureDetector(
        onTap: () async {
          viewedProdProvider.addViewedProd(
            productId: getCurrProduct.productId
            );
          await Navigator.pushNamed(
            context,
            ProductDetailsScreen.routName,arguments: getCurrProduct.productId
          );
        },
        child: Column(
          children: [
            ClipRRect(
              // rubovi zaobljeni
              borderRadius: BorderRadius.circular(12.0),
              child: FancyShimmerImage(
                imageUrl: getCurrProduct.productImage, //prouči
                height: size.height * 0.22,
                width: double.infinity,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: TitlesTextWidget(
                      label: getCurrProduct.productTitle,
                      fontSize: 18,
                      maxLines: 2,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: HeartButtonWidget(
                      productId: getCurrProduct.productId,),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 6.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: SubtitleTextWidget(
                    label: "${getCurrProduct.productPrice}\$",
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                Flexible(
                    child: Material(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.lightBlue,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () async {
                      try{
                        if(cartProvider.isProdinCart(
                          productId: getCurrProduct.productId)) {
                          return;
                        }
                      await cartProvider.addToCartFirebase(
                          productId: getCurrProduct.productId,
                          qty: 1,
                          context: context
                        );
                      } catch (e){
                        await MyAppFunctions.showErrorOrWarningDialog(
                          context: context,
                          subtitle: e.toString(),
                          fct: () {},
                        );
                      }
                      // if(cartProvider.isProdinCart(
                      //   productId: getCurrProduct.productId)) {
                      //     return;
                      //   }
                      // cartProvider.addProductToCart(
                      //   productId: getCurrProduct.productId);
                    },
                    splashColor: Colors.red,
                    child:  Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        // nakon što pritisnemo ikonicu za dodaj u košaricu ikona se mijenja u kvacicu
                        cartProvider.isProdinCart(
                          productId: getCurrProduct.productId)
                        ? Icons.check
                        : Icons.add_shopping_cart_outlined,
                        size: 20,
                        color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }
}
