import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chef_taruna_birla/pages/live_integration/live_classes.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../pages/book/books_page.dart';
import '../pages/book/each_book.dart';
import '../pages/common/video_web_player.dart';
import '../pages/course/each_course.dart';
import '../pages/image/open_image.dart';
import '../pages/product/each_product.dart';
import '../viewmodels/product_page_viewmodel.dart';

class ProductSliderWidget extends StatelessWidget {
  const ProductSliderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: context.watch<ProductPageViewModel>().appslider.length,
      options: CarouselOptions(
        autoPlay: true,
        viewportFraction: 0.9,
        autoPlayAnimationDuration: const Duration(milliseconds: 1500),
        enlargeCenterPage: false,
        enableInfiniteScroll:
            context.watch<ProductPageViewModel>().appslider.length == 1
                ? false
                : true,
      ),
      itemBuilder: (context, index, realIdx) {
        return Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Palette.shadowColor.withOpacity(0.1),
                  blurRadius: 6.0, // soften the shadow
                  spreadRadius: 2.0, //extend the shadow
                  offset: const Offset(
                    0.0, // Move to right 10  horizontally
                    0.0, // Move to bottom 10 Vertically
                  ),
                ),
              ],
              // boxShadow: [
              //   BoxShadow(
              //     color: Palette.shadowColor.withOpacity(0.1),
              //     blurRadius: 5.0, // soften the shadow
              //     spreadRadius: 0.0, //extend the shadow
              //     offset: const Offset(
              //       0.0, // Move to right 10  horizontally
              //       -0.0, // Move to bottom 10 Vertically
              //     ),
              //   ),
              // ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            height: 200.0,
            child: GestureDetector(
              onTap: () {
                if (Provider.of<ProductPageViewModel>(context, listen: false)
                        .appslider[index]
                        .category ==
                    'video') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoWebPage(
                        url: Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .image_path,
                      ),
                    ),
                  );
                } else {
                  if (Provider.of<ProductPageViewModel>(context, listen: false)
                          .appslider[index]
                          .linked_array
                          .toString() ==
                      'no_linked_item') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OpenImage(
                          url: Constants.imgBackendUrl +
                              Provider.of<ProductPageViewModel>(context,
                                      listen: false)
                                  .appslider[index]
                                  .image_path
                                  .toString(),
                        ),
                      ),
                    );
                  } else if (Provider.of<ProductPageViewModel>(context,
                              listen: false)
                          .appslider[index]
                          .linked_array
                          .toString() ==
                      'multiple') {
                    if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'course') {
                    } else if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'product') {
                    } else if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'book') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BooksPage(),
                        ),
                      );
                    } else if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'live') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LiveClasses(),
                        ),
                      );
                    }
                  } else {
                    if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'course') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EachCourse(
                            id: Provider.of<ProductPageViewModel>(context,
                                    listen: false)
                                .appslider[index]
                                .linked_array
                                .toString(),
                          ),
                        ),
                      );
                    } else if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EachProduct(
                            id: Provider.of<ProductPageViewModel>(context,
                                    listen: false)
                                .appslider[index]
                                .linked_array
                                .toString(),
                          ),
                        ),
                      );
                    } else if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'book') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EachBook(
                            id: Provider.of<ProductPageViewModel>(context,
                                    listen: false)
                                .appslider[index]
                                .linked_array
                                .toString(),
                          ),
                        ),
                      );
                    } else if (Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .appslider[index]
                            .linked_category
                            .toString() ==
                        'live') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LiveClasses(),
                        ),
                      );
                    }
                  }
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: Provider.of<ProductPageViewModel>(context,
                                      listen: false)
                                  .appslider[index]
                                  .category ==
                              'video'
                          ? Constants.imgBackendUrl +
                              Provider.of<ProductPageViewModel>(context,
                                      listen: false)
                                  .appslider[index]
                                  .thumbnail
                                  .toString()
                          : Constants.imgBackendUrl +
                              Provider.of<ProductPageViewModel>(context,
                                      listen: false)
                                  .appslider[index]
                                  .image_path
                                  .toString(),
                      placeholder: (context, url) => const ImagePlaceholder(),
                      errorWidget: (context, url, error) =>
                          const ImagePlaceholder(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.topCenter,
                    ),
                    Provider.of<ProductPageViewModel>(context, listen: false)
                                .appslider[index]
                                .category ==
                            'video'
                        ? Container(
                            height: 50.0,
                            width: 50.0,
                            decoration: BoxDecoration(
                              color: Palette.secondaryColor,
                              borderRadius: BorderRadius.circular(50.0),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff000000).withOpacity(0.2),
                                  blurRadius: 10.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: const Offset(
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
