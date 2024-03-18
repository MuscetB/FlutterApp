import 'package:flutter/material.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:shimmer/shimmer.dart';

class AppNameTextWidget extends StatelessWidget {
  const AppNameTextWidget({super.key, this.fontSize = 30});

  final double fontSize;
  //Animacija boje u naslovu na stranici profila
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: Duration(seconds: 13),
      baseColor: Colors.purple,
      highlightColor: Colors.red,
      child: TitlesTextWidget(
        label: "WebShop",
        fontSize: fontSize,
      ),
    );
  }
}
