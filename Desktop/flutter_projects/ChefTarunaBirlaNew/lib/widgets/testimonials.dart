import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chef_taruna_birla/models/testimonial.dart';
import 'package:chef_taruna_birla/widgets/text_to_html.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../viewmodels/main_container_viewmodel.dart';
import 'image_placeholder.dart';

class Testimonials extends StatefulWidget {
  const Testimonials({Key? key}) : super(key: key);

  @override
  State<Testimonials> createState() => _TestimonialsState();
}

class _TestimonialsState extends State<Testimonials> {
  List list = [];
  bool isLoading = false;

  void setImpBooks() {
    list.clear();
    Provider.of<MainContainerViewModel>(context, listen: false)
        .testimonial
        .forEach((testimonial) {
      list.add(
        Testimonial(
          id: testimonial.id,
          name: testimonial.name,
          message: testimonial.message,
          image_path: testimonial.image_path,
          profile_image: testimonial.profile_image,
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Testimonials',
                style: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontSize: 24.0,
                  color: Palette.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 450.0,
          child: CarouselSlider.builder(
            itemCount: list.length,
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 1 / 1,
              viewportFraction: 0.85,
              autoPlayAnimationDuration: const Duration(milliseconds: 1500),
              enlargeCenterPage: false,
              enableInfiniteScroll: list.length == 1 ? false : true,
            ),
            itemBuilder: (context, index, realIdx) {
              return Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Palette.shadowColor.withOpacity(0.1),
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 0.0, //extend the shadow
                        offset: const Offset(
                          0.0, // Move to right 10  horizontally
                          -0.0, // Move to bottom 10 Vertically
                        ),
                      ),
                    ],
                    color: Palette.white,
                    borderRadius: BorderRadius.circular(10.0)),
                margin:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                height: 300.0,
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => VideoPage(
                    //       url: _data['data'][i]['path'].toString(),
                    //     ),
                    //   ),
                    // );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: Constants.imgBackendUrl +
                                  list[index].image_path.toString(),
                              placeholder: (context, url) =>
                                  const ImagePlaceholder(),
                              errorWidget: (context, url, error) =>
                                  const ImagePlaceholder(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: CachedNetworkImage(
                                          imageUrl: Constants.imgBackendUrl +
                                              list[index]
                                                  .profile_image
                                                  .toString(),
                                          placeholder: (context, url) =>
                                              const ImagePlaceholder(),
                                          errorWidget: (context, url, error) =>
                                              const ImagePlaceholder(),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  Text(
                                    list[index].name,
                                    style: const TextStyle(
                                      color: Palette.black,
                                      fontSize: 20.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                child: TextToHtml(
                                  description: list[index]
                                              .message
                                              .toString()
                                              .length >=
                                          250
                                      ? '${list[index].message.toString().substring(0, 250)}...'
                                      : list[index].message,
                                  textColor: Palette.grey,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
