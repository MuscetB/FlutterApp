import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:projekt_webshop/models/user_model.dart';
import 'package:projekt_webshop/providers/theme_provider.dart';
import 'package:projekt_webshop/providers/user_provider.dart';
import 'package:projekt_webshop/screens/auth/login.dart';
import 'package:projekt_webshop/screens/inner_screen/orders/orders_screen.dart';
import 'package:projekt_webshop/screens/inner_screen/viewed_recently.dart';
import 'package:projekt_webshop/screens/inner_screen/wishlist.dart';
import 'package:projekt_webshop/screens/loading_manager.dart';
import 'package:projekt_webshop/services/assets_manager.dart';
import 'package:projekt_webshop/services/my_app_functions.dart';
import 'package:projekt_webshop/widgets/app_name_text.dart';
import 'package:projekt_webshop/widgets/subtitle_text.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// AutomaticKeepAliveClientMixin - koristi se kako bi se spriječilo ponovno iscrtavanje widgeta kada se widget pomakne izvan vidljivog područja ekrana
class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true; // prouči

  User? user =FirebaseAuth.instance.currentUser; // ako je currentUser = 0 znači da korisnik ne postoji tj da nema račun
UserModel? userModel;
  bool _isLoading = true;
  Future<void> fetchUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try{
      setState(() {
        _isLoading = true;
      });
      userModel = await userProvider.fetchUserInfo();
    }catch (error) {
      await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.toString(),
          fct: () {},
        );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void initState() {
    fetchUserInfo(); // metoda koja asinkrono dohvaća informacije o korisniku
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider =
        Provider.of<ThemeProvider>(context); // potrebno za promjenu teme app
    return Scaffold(
      appBar: AppBar(
        // ikonica kraj naslova
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            AssetsManagers.shoppingCart,
          ),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body: LoadingManager(
        isLoading: _isLoading, // varijabla koja označava je li u tijeku učitavanje podataka
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: user == null ? true : false,
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: TitlesTextWidget(
                      label: "Please login to have unlimited access"),
                ),
              ),
              userModel == null
                ? const SizedBox.shrink()
                : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Container(
                      //ikona slike profila
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          // rub oko slike profila
                          color: Theme.of(context).colorScheme.background,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            userModel!.userImage
                          ),
                            fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(
                      // razmak između slike profila i teksta u ravnini
                      width: 10,
                    ),
                    Column(
                      // tekst kraj ikone profila
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // pomičemo teks da počinje odmah nakon slike profila
                      children: [
                        TitlesTextWidget(label: userModel!.userName),
                        const SizedBox(
                          // razmak visine između imena i email-a
                          height: 6,
                        ),
                        SubtitleTextWidget(label: userModel!.userEmail),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(height: 6),
                    const TitlesTextWidget(
                      label: "General",
                    ),
                    const SizedBox(height: 6),
                    Visibility(
                      visible: userModel == null ? false : true,
                      child: CustomListTile(
                        imagePath: AssetsManagers.orderSvg,
                        text: "All orders",
                        function: () {
                          Navigator.of(context)
                            .pushNamed(OrdersScreenFree.routName);
                        },
                      ),
                    ),
                    Visibility(
                      visible: userModel == null ? false : true,
                      child: CustomListTile(
                        imagePath: AssetsManagers.wishlistSvg,
                        text: "Wishlist",
                        function: () {
                          Navigator.pushNamed(
                            context, WishlistScreen.routName);
                        },
                      ),
                    ),
                    CustomListTile(
                      imagePath: AssetsManagers.recent,
                      text: "Viewed recently",
                      function: () {
                        Navigator.pushNamed(
                          context, ViewedRecentlyScreen.routName);
                      },
                    ),
                    CustomListTile(
                      imagePath: AssetsManagers.address,
                      text: "Address",
                      function: () {},
                    ),
                    const SizedBox(height: 6),
                    const Divider(
                      thickness: 2,
                    ), //crta iznad settings
                    const SizedBox(height: 6),
                    const TitlesTextWidget(
                      label: "Settings",
                    ),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      //switch komponenta za promijenu teme aplikacije
                      secondary: Image.asset(
                        // ikona kraj swicha za temu app
                        AssetsManagers.theme,
                        height: 34,
                      ),
                      title: Text(themeProvider.getIsDarkTheme
                          ? "Dark Mode"
                          : "Light Mode"),
                      value: themeProvider.getIsDarkTheme,
                      onChanged: (value) {
                        themeProvider.setDarkTheme(themeValue: value);
                      },
                    ),
                  ],
                ),
              ),
              // LOGIN WIDGET
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon:  Icon(user == null ? Icons.login : Icons.logout),
                  label:  Text(user == null ? "Login" : "Logout"),
                  onPressed: () async{
                    if(user == null) {
                      Navigator.pushNamed(context, LoginScreen.routName);
                    }else {
                      await MyAppFunctions.showErrorOrWarningDialog(
                      context: context,
                      subtitle: "Are you sure you want to singout",
                      fct: () async{
                        await FirebaseAuth.instance.signOut();
                        if(!mounted) return;
                        Navigator.pushReplacementNamed(context, LoginScreen.routName);
                      },
                      isError: false,
                    );
                  }
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// widget za 4 komponente dodane ispod general widgeta
class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.imagePath,
      required this.text,
      required this.function});

  final String imagePath, text;
  final Function function;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        function();
      },
      title: SubtitleTextWidget(label: text),
      leading: Image.asset(
        imagePath,
        height: 35,
      ),
      trailing: Icon(IconlyLight.arrowRight2),
    );
  }
}
