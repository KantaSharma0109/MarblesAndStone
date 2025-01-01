import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/config/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/image/open_image.dart';

class ImagePlaceholder extends StatelessWidget {
  final String url;
  final double? height;
  final double width;
  final bool? openImage;
  const ImagePlaceholder({
    Key? key,
    required this.url,
    required this.height,
    required this.width,
    this.openImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: GestureDetector(
        onTap: openImage ?? false
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenImage(url: url),
                  ),
                );
              }
            : null,
        child: CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) {
            return placeholder();
          },
          errorWidget: (context, url, error) {
            return placeholder();
          },
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget placeholder() {
    return Container(
      color: Palette.appBarColor,
      child: Center(
        child: Image.asset(
          'assets/images/white_logo.webp',
          width: 80.0,
        ),
      ),
    );
  }
}
