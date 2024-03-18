import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/products_provider.dart';
import '../widgets/product_widget.dart';
import '../widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  List<ProductModel> productListSearch = [];
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    String? passedCategory =
        ModalRoute.of(context)!.settings.arguments as String?;
    List<ProductModel> productList = passedCategory == null
        ? productsProvider.products
        : productsProvider.findByCategory(categoryName: passedCategory);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          // leading: Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Image.asset(
          //     AssetsManager.shoppingCart,
          //   ),
          // ),
          title: TitlesTextWidget(label: passedCategory ?? "Search products"),
        ),
        body: StreamBuilder<List<ProductModel>>(
          stream: productsProvider.fetchProductStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Center(
                child: CircularProgressIndicator(),
              ),
          );
        } else if (snapshot.hasError) {
            return Center(
              child: SelectableText(snapshot.error.toString()),
          );
        } else if (snapshot.data == null) {
            return const Center(
              child: SelectableText("No products has been added"),
          );
        }
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    //polje za unos teksta
                    controller: searchTextController,
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          // setState(() {
                          FocusScope.of(context).unfocus();
                          searchTextController
                              .clear(); //pozivamo kontroler i čistimo tekst unutar polja
                          // });
                        },
                        child: const Icon(
                          Icons.clear,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    // kada korisnik pokušava pretraživati proizvode poziva se funkcija setState
                    // funkcija mijenja svoje vrijednosti svakim upisom korisnika i odma mu daje moguće aktikle koje se podudaraju s dotadašnjim unosom
                    // onChanged: (value) {
                    //   setState(() {
                    //     productListSearch = productsProvider.searchQuery(
                    //       searchText: searchTextController.text);
                    //   });
                    // },
                    onSubmitted: (value) {
                      setState(() {
                        productListSearch = productsProvider.searchQuery(
                          searchText: searchTextController.text,
                          passedList: productList); // ovaj dio koristimo kako bi kad udemo u kategorije kod pretraživanja prikazn bio samo oni proizvodi u toj kategoriji
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  // kratka provjera 1. uvijet je da korisnik pretražuje nešto i 2. uvijet je da taj proizvod ne postoji na productListSearch listi
                  // ako su oba uvijeta uspješno ispunjena prikazuje se widget sa definiranim tekstom
                  if (searchTextController.text.isNotEmpty && productListSearch.isEmpty)...[
                    const Center(
                      child: TitlesTextWidget(label: "No products found"),
                    ),
                  ],
                  Expanded(
                    child: DynamicHeightGridView(
                      //lokalno pretraživanje
                        itemCount: searchTextController.text.isNotEmpty
                        ? productListSearch.length
                        : productList.length,
                        crossAxisCount: 2, //određuje broj elemenata u jedno redu
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        builder: (context, index) {
                          return ProductWidget(
                            productId: searchTextController.text.isNotEmpty
                            ? productListSearch[index].productId
                            : productList[index].productId,
                          );
                        },
                        
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
