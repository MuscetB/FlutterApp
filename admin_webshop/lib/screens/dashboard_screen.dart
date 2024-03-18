import 'package:admin_webshop/models/dashboard_btn_model.dart';
import 'package:admin_webshop/widgets/dashboard_btns.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/assets_manager.dart';
import '../widgets/title_text.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/DashboardScreen';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Dashboard Screen"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        actions: [ //ikonica mijeseza za promijenu teme
          IconButton(
            onPressed: () {
              themeProvider.setDarkTheme(
                  themeValue: !themeProvider.getIsDarkTheme);
            },
            icon: Icon(themeProvider.getIsDarkTheme
                ? Icons.light_mode
                : Icons.dark_mode),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2, // broj items-a smještenih jedno pored drugog na ekranu
        children: List.generate(
          DashboardButtonsModel.dashboardBtnList(context).length, // lista widgeta na ekranu
          (index) =>  DashboardButtomWidget(
            text: DashboardButtonsModel.dashboardBtnList(context)[index].text,
            imagePath: DashboardButtonsModel.dashboardBtnList(context)[index].imagePath,
            onPressed: DashboardButtonsModel.dashboardBtnList(context)[index].onPressed,
          )
        ),
      ),
    );
  }
}
