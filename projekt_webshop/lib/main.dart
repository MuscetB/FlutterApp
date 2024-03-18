import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projekt_webshop/consts/theme_data.dart';
import 'package:projekt_webshop/providers/cart_provider.dart';
import 'package:projekt_webshop/providers/order_provider.dart';
import 'package:projekt_webshop/providers/products_provider.dart';
import 'package:projekt_webshop/providers/theme_provider.dart';
import 'package:projekt_webshop/providers/user_provider.dart';
import 'package:projekt_webshop/providers/viewed_recently_provider.dart';
import 'package:projekt_webshop/providers/wishlist_provider.dart';
import 'package:projekt_webshop/root_screen.dart';
import 'package:projekt_webshop/screens/auth/forgot_password.dart';
import 'package:projekt_webshop/screens/auth/login.dart';
import 'package:projekt_webshop/screens/auth/register.dart';
import 'package:projekt_webshop/screens/inner_screen/orders/orders_screen.dart';
import 'package:projekt_webshop/screens/inner_screen/product_details.dart';
import 'package:projekt_webshop/screens/inner_screen/viewed_recently.dart';
import 'package:projekt_webshop/screens/inner_screen/wishlist.dart';
import 'package:projekt_webshop/screens/search_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
  
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
    FutureBuilder<FirebaseApp>(
      // Inicijalizacija Firebase app.
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: SelectableText(snapshot.error.toString()),
              ),
            ),
          );
        } return MultiProvider(
          //multiprovider koristimo kao roditelja materialApp-u kako bi promijena teme utjecala na cijelu aplikaciju
          providers: [
            ChangeNotifierProvider(create: (_) {
              return ThemeProvider();
            }),
            ChangeNotifierProvider(create: (_) {
              return ProductsProvider();
            }),
            ChangeNotifierProvider(create: (_) {
              return CartProvider();
            }),
            ChangeNotifierProvider(create: (_) {
              return WishlistProvider();
            }),
            ChangeNotifierProvider(create: (_) {
              return ViewedProdProvider();
            }),
            ChangeNotifierProvider(create: (_) {
              return UserProvider();
            }),
            ChangeNotifierProvider(create: (_) {
              return OrderProvider();
            }),
          ],
          child: Consumer<ThemeProvider>(
              //widget koji nam koristi kako bi pristupili getIsDarkTheme metodi
              builder: (context, themeProvider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false, //debug ikonica u kantunu koja samo smeta
              title: 'Webshop',
              theme: Styles.themeData(
                  isDarkTheme: themeProvider.getIsDarkTheme, context: context),
              home: const LoginScreen(),
              routes: {
                RootScreen.routName: (context) => const RootScreen(),
                ProductDetailsScreen.routName: (context) => //navigacija
                    const ProductDetailsScreen(),
                WishlistScreen.routName:(context) => const WishlistScreen(),
                ViewedRecentlyScreen.routName:(context) => const ViewedRecentlyScreen(),
                RegisterScreen.routName:(context) => const RegisterScreen(),
                LoginScreen.routName:(context) => const LoginScreen(),
                OrdersScreenFree.routName: (context) => const OrdersScreenFree(),
                ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
                SearchScreen.routeName: (context) => const SearchScreen(),
              },
            );
          }),
        );
      }
    );
  }
}
