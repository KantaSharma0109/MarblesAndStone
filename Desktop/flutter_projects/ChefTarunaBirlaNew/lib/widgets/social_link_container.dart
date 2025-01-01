import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import 'image_placeholder.dart';

class SocialLinkContainer extends StatelessWidget {
  final String imagePath;
  final double marginLeft;
  final double marginRight;
  const SocialLinkContainer({
    Key? key,
    required this.imagePath,
    required this.marginLeft,
    required this.marginRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(marginLeft, 9.0, marginRight, 9.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Palette.white,
        boxShadow: [
          BoxShadow(
            color: Palette.shadowColor.withOpacity(0.1),
            blurRadius: 5.0, // soften the shadow
            spreadRadius: 0.0, //extend the shadow
            offset: const Offset(
              0.0, // Move to right 10  horizontally
              0.0, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: CachedNetworkImage(
          imageUrl: imagePath,
          placeholder: (context, url) => const ImagePlaceholder(),
          errorWidget: (context, url, error) => const ImagePlaceholder(),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
