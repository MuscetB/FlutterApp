import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_webshop/providers/cart_provider.dart';
import 'package:projekt_webshop/providers/products_provider.dart';
import 'package:projekt_webshop/providers/user_provider.dart';
import 'package:projekt_webshop/screens/cart/bottom_checkout.dart';
import 'package:projekt_webshop/screens/cart/cart_widget.dart';
import 'package:projekt_webshop/screens/loading_manager.dart';
import 'package:projekt_webshop/services/assets_manager.dart';
import 'package:projekt_webshop/services/my_app_functions.dart';
import 'package:projekt_webshop/widgets/empty_bag.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<ProductsProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return cartProvider.getCartitems.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManagers.shoppingBasket,
              title: 'Your cart is empty!',
              subtitle: 'Looks like your cart is empty add something inside',
              buttonText: 'Shop now',
            ),
          )
        : Scaffold(
            bottomSheet: CartBottomSheetWidget(
              function: () async {
                await placedOrderAdvanced(
                  cartProvider: cartProvider,
                  productsProvider: productsProvider,
                  userProvider: userProvider,
                );
              },
            ),
            appBar: AppBar(
              // ikonica kraj naslova
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AssetsManagers.shoppingCart,
                ),
              ),
              title: TitlesTextWidget(label: "Cart (${cartProvider.getCartitems.length})"),
              actions: [
                IconButton(
                  onPressed: () {
                    MyAppFunctions.showErrorOrWarningDialog(
                      isError: false,
                      context: context,
                      subtitle: "Clear cart?",
                      fct: () async{
                        // cartProvider.clearLocalCart();
                        cartProvider.clearCartFromFirebase();
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
            body: LoadingManager(
              isLoading: _isLoading,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: cartProvider.getCartitems.length,
                        itemBuilder: (context, index) {
                          return ChangeNotifierProvider.value(
                            value: cartProvider.getCartitems.values.toList()[index], //prouči
                            child: CartWidget());
                        }),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                    ),
                ],
              ),
            ),
          );
  }

  Future<void> placedOrderAdvanced({
    required CartProvider cartProvider,
    required ProductsProvider productsProvider,
    required UserProvider userProvider,
  }) async{{
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if(user == null) {
      return;
    }
    final uid = user.uid;
    try{
      setState(() {
        _isLoading = true;
      });
      cartProvider.getCartitems.forEach((key, value) async{
        final getCurrProduct = productsProvider.findByProdId(value.productId);
        final orderId = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection("ordersAdvanced")
            .doc(orderId)
            .set({
              'orderId': orderId,
              'userId': uid,
              'productId': value.productId,
              'productTitle': getCurrProduct!.productTitle,
              'price': double.parse(getCurrProduct.productPrice) * value.quantity,
              'totalPrice': cartProvider.getTotal(productsProvider: productsProvider),
              'quantity': value.quantity,
              'imageUrl': getCurrProduct.productImage,
              'userName': userProvider.getUserModel!.userName,
              'orderDate': Timestamp.now(),
            });
      });
      await cartProvider.clearCartFromFirebase();
      cartProvider.clearLocalCart();
    }catch (e) {
      await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: e.toString(),
          fct: () {},
        );
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
    }
}
}