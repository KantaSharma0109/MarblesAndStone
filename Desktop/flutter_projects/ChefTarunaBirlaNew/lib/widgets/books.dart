import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../models/book.dart';
import '../pages/book/books_page.dart';
import '../pages/book/each_book.dart';
import '../viewmodels/main_container_viewmodel.dart';

class Books extends StatefulWidget {
  const Books({Key? key}) : super(key: key);

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  List list = [];
  bool isLoading = false;

  void setImpBooks() {
    list.clear();
    Provider.of<MainContainerViewModel>(context, listen: false)
        .impBooks
        .forEach((impbook) {
      list.add(
        Book(
          id: impbook.id,
          title: impbook.title,
          description: impbook.description,
          price: impbook.price,
          discount_price: impbook.discount_price,
          days: impbook.days,
          category: impbook.category,
          image_path: impbook.image_path,
          count: 0,
          pdflink: impbook.pdflink == 'null' ? '' : impbook.pdflink,
          price_with_video: impbook.price_with_video,
          discount_price_with_video: impbook.discount_price_with_video,
          video_days: impbook.video_days,
          only_video_price: impbook.only_video_price,
          only_video_discount_price: impbook.only_video_discount_price,
          share_url: impbook.share_url,
          include_videos: impbook.include_videos,
        ),
      );
    });
    setState(() => isLoading = true);
  }

  @override
  void initState() {
    super.initState();
    setImpBooks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Container()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Our Books',
                      style: TextStyle(
                        fontFamily: 'CenturyGothic',
                        fontSize: 24.0,
                        color: Palette.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BooksPage(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 24.0,
                        color: Palette.white,
                      ),
                    ),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth < 576
                          ? 2
                          : constraints.maxWidth < 768
                              ? 3
                              : constraints.maxWidth < 992
                                  ? 4
                                  : 6,
                      childAspectRatio: constraints.maxWidth < 576
                          ? 0.68
                          : constraints.maxWidth < 768
                              ? 0.8
                              : constraints.maxWidth < 992
                                  ? 0.8
                                  : constraints.maxWidth < 1024
                                      ? 0.7
                                      : constraints.maxWidth < 1220
                                          ? 0.7
                                          : 0.9,
                      mainAxisSpacing: 0.0,
                      crossAxisSpacing: 18.0,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EachBook(
                                id: list[index].id,
                              ),
                            ),
                          );
                        },
                        child: BookCard(
                          image: list[index].image_path,
                          name: list[index].title,
                          marginLeft: index % 2 == 0 ? 24.0 : 0.0,
                          marginRight: index % 2 == 0 ? 0.0 : 24.0,
                          category: list[index].category,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
  }
}

class BookCard extends StatelessWidget {
  final String image;
  final String category;
  final String name;
  final double marginLeft;
  final double marginRight;
  const BookCard({
    Key? key,
    required this.image,
    required this.name,
    required this.marginLeft,
    required this.marginRight,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(marginLeft, 25.0, marginRight, 30.0),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: '${Constants.imgBackendUrl}$image',
                placeholder: (context, url) => const ImagePlaceholder(),
                errorWidget: (context, url, error) => const ImagePlaceholder(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Palette.shadowColorTwo,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      width: 1.0,
                      color: Palette.secondaryColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Palette.secondaryColor,
                        fontSize: 14.0,
                        fontFamily: 'EuclidCircularA Medium',
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff000000).withOpacity(0.5),
            blurRadius: 30.0, // soften the shadow
            spreadRadius: 0.0, //extend the shadow
            offset: const Offset(
              4.0, // Move to right 10  horizontally
              8.0, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
    );
  }
}
