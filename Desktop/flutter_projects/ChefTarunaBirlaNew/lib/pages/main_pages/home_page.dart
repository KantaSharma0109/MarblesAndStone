import 'package:chef_taruna_birla/viewmodels/product_page_viewmodel.dart';
import 'package:chef_taruna_birla/widgets/courses.dart';
import 'package:chef_taruna_birla/widgets/featured_courses.dart';
import 'package:chef_taruna_birla/widgets/featured_products.dart';
import 'package:chef_taruna_birla/widgets/gallery.dart';
import 'package:chef_taruna_birla/widgets/our_social_links.dart';
import 'package:chef_taruna_birla/widgets/our_store.dart';
import 'package:chef_taruna_birla/widgets/slider.dart';
import 'package:chef_taruna_birla/widgets/testimonials.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../viewmodels/course_page_viewmodel.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../../widgets/books.dart';
import '../common/gallery_page.dart';
import '../common/webview_page.dart';
import '../profile/my_books.dart';
import '../profile/my_courses.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.scaffoldColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .appslider
                            .isNotEmpty
                        ? 20.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .appslider
                      .isNotEmpty
                  ? const AppSliderWidget()
                  : const SizedBox(),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 24.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyCourses(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Palette.contrastColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 0.0),
                              child: Text(
                                'My courses',
                                style: TextStyle(
                                  fontFamily: 'EuclidCircularA Regular',
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyBooks(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Palette.contrastColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 0.0),
                              child: Text(
                                'My Books',
                                style: TextStyle(
                                  fontFamily: 'EuclidCircularA Regular',
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .courseCategories
                            .isNotEmpty
                        ? 20.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .courseCategories
                      .isNotEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 24.0,
                      ),
                      child: Text(
                        'Find your favourite\ncourses here',
                        style: TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontSize: 24.0,
                          color: Palette.secondaryColor,
                        ),
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .courseCategories
                            .isNotEmpty
                        ? 12.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .courseCategories
                      .isNotEmpty
                  ? const Courses()
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .sociallinks
                            .isNotEmpty
                        ? 12.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .sociallinks
                      .isNotEmpty
                  ? const Padding(
                      padding:
                          EdgeInsets.only(left: 24.0, right: 24.0, top: 12.0),
                      child: Text(
                        'Our Stores',
                        style: TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontSize: 24.0,
                          color: Palette.secondaryColor,
                        ),
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .sociallinks
                            .isNotEmpty
                        ? 12.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .sociallinks
                      .isNotEmpty
                  ? const OurStore()
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .impBooks
                            .isNotEmpty
                        ? 18.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .impBooks
                      .isNotEmpty
                  ? Container(
                      color: Palette.contrastColor,
                      child: const Books(),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .featured_courses
                            .isNotEmpty
                        ? 24.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .featured_courses
                      .isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 24.0, right: 24.0, top: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Courses',
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 24.0,
                              color: Palette.secondaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Provider.of<CoursePageViewModel>(context,
                                      listen: false)
                                  .setSelectedCategory(
                                      Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .courseCategories[0]
                                          .name);
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .setIndex(2);
                            },
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 24.0,
                              color: Palette.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .featured_courses
                            .isNotEmpty
                        ? 12.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .featured_courses
                      .isNotEmpty
                  ? const FeaturedCourses()
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .featured_products
                            .isNotEmpty
                        ? 24.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .featured_products
                      .isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 24.0, right: 24.0, top: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Products',
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 24.0,
                              color: Palette.secondaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Provider.of<ProductPageViewModel>(context,
                                      listen: false)
                                  .setSelectedCategory(
                                      Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .productCategories[0]
                                          .name);
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .setIndex(3);
                            },
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 24.0,
                              color: Palette.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .featured_products
                            .isNotEmpty
                        ? 12.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .featured_products
                      .isNotEmpty
                  ? const FeaturedProducts()
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .testimonial
                            .isNotEmpty
                        ? 24.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .testimonial
                      .isNotEmpty
                  ? Container(
                      color: Palette.contrastColor,
                      child: const Testimonials(),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .gallery
                            .isNotEmpty
                        ? 24.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .gallery
                      .isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 24.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Our Gallery',
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 24.0,
                              color: Palette.secondaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GalleryPage(
                                    itemId: '',
                                    itemCategory: '',
                                    isItemGallery: false,
                                  ),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 24.0,
                              color: Palette.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .gallery
                            .isNotEmpty
                        ? 25.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .gallery
                      .isNotEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 24.0,
                      ),
                      child: Gallery(),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .gallery
                            .isNotEmpty
                        ? 24.0
                        : 0.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebviewPage(
                        url: 'http://www.cheftarunabirla.com/feedback1',
                        title: 'Feedback',
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border:
                        Border.all(width: 2.0, color: Palette.secondaryColor),
                    color: Palette.shadowColorTwo,
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
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, bottom: 30.0, left: 15.0, right: 15.0),
                    child: Center(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Give Feedback/Enquiry',
                              style: TextStyle(
                                color: Palette.secondaryColor,
                                fontSize: 20.0,
                                fontFamily: 'EuclidCircularA Medium',
                              ),
                            ),
                          ),
                          Icon(
                            MdiIcons.arrowRight,
                            color: Palette.secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .sociallinks
                      .isNotEmpty
                  ? const Padding(
                      padding:
                          EdgeInsets.only(left: 24.0, right: 24.0, top: 0.0),
                      child: Text(
                        'Our Social Links',
                        style: TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontSize: 24.0,
                          color: Palette.secondaryColor,
                        ),
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                            .sociallinks
                            .isNotEmpty
                        ? 12.0
                        : 0.0,
              ),
              Provider.of<MainContainerViewModel>(context, listen: false)
                      .sociallinks
                      .isNotEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(left: 24.0, right: 24.0),
                      child: OurSocialLinks(),
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 30.0,
              ),
              const Center(
                child: Text(
                  'ⓒ cheftarunabirla, Inc.All rights reserved',
                  style: TextStyle(
                    fontFamily: 'Euclid Regular',
                    fontSize: 16.0,
                    color: Palette.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
