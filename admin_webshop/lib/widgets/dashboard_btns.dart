import 'package:admin_webshop/widgets/subtitle_text.dart';
import 'package:flutter/material.dart';

class DashboardButtomWidget extends StatelessWidget {
  const DashboardButtomWidget({
    super.key,
    required this.text,
    required this.imagePath,
    required this.onPressed
    });

  final String text, imagePath;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // dodajemo ovaj widget kako bi mogli kliknuti na određenu dio
      onTap: () {onPressed();},
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: 65,
                  width: 65,
                ),
                const SizedBox(
                  height: 10,
                ),
                SubtitleTextWidget(label: text),
              ],
            ),
          ),
      ),
    );
  }
}