import 'package:chef_taruna_birla/config/config.dart';
import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.contrastColor,
      child: Center(
        child: Image.asset(
          'assets/images/white_logo.webp',
          width: 100.0,
        ),
      ),
    );
  }
}
