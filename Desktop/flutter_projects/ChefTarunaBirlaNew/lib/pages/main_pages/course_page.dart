import 'package:chef_taruna_birla/pages/course/each_course.dart';
import 'package:chef_taruna_birla/viewmodels/course_page_viewmodel.dart';
import 'package:chef_taruna_birla/viewmodels/main_container_viewmodel.dart';
import 'package:chef_taruna_birla/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../api/api_functions.dart';
import '../../config/config.dart';
import '../../models/cart_item.dart';
import '../../utils/utility.dart';
import '../cart/cart_page.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key}) : super(key: key);

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool isLoadingVertical = false;
  bool isSearching = false;
  String url = Constants.finalUrl;
  int index = 0;

  //get Course Data
  Future<void> getCourseData() async {
    Provider.of<CoursePageViewModel>(context, listen: false)
        .getCourseData(context);
    index = Provider.of<MainContainerViewModel>(context, listen: false)
        .courseCategories
        .indexWhere((element) =>
            element.name ==
            Provider.of<CoursePageViewModel>(context, listen: false)
                .selectedCategory);
  }

  // ADD OR REMOVE ITEM FROM WHISLIST
  Future<void> updateWhislist(id, value, imagePath,
      {String title = '', String price = ''}) async {
    Map<String, String> params = {
      'user_id': Application.userId,
      'id': id,
      'image_path': imagePath,
    };
    String url = value == 'add'
        ? '${Constants.finalUrl}/courses_api/addToWhislist'
        : '${Constants.finalUrl}/courses_api/removeFromWhislist';
    Map<String, dynamic> _postResult =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);

    bool _status = _postResult['status'];
    var _data = _postResult['data'];
    if (_status) {
      if (_data['message'] == 'success') {
        if (value == 'add') {
          Utility.showSnacbar(context, 'Item successfully added to whislist!!');
        } else {
          Utility.showSnacbar(
              context, 'Item successfully removed from whislist!!');
        }
      } else if (_data['message'] == 'Auth_token_failure') {
        Utility.authErrorPopup(
            context,
            'Sorry for inconvenience. Their is some authentication problem regarding your account contact support: ' +
                Application.adminPhoneNumber);
      } else {
        Utility.showSnacbar(context, 'Some error occurred!!');
      }
    } else {
      Utility.printLog('Something went wrong.');
      Utility.databaseErrorPopup(context);
    }
  }

  // ADD OR REMOVE ITEM FROM CART
  Future<bool> updateCart(id, value, imagePath,
      {String title = '', String price = ''}) async {
    Utility.showProgress(true);
    Map<String, String> params = {
      'user_id': Application.userId,
      'id': id,
      'image_path': imagePath,
    };
    String url = value == 'add'
        ? '${Constants.finalUrl}/courses_api/addToCart'
        : '${Constants.finalUrl}/courses_api/removeFromCart';
    Map<String, dynamic> _postResult =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);

    bool _status = _postResult['status'];
    var _data = _postResult['data'];
    if (_status) {
      Utility.showProgress(false);
      if (_data['message'] == 'success') {
        if (value == 'add') {
          Utility.showSnacbar(context, 'Item successfully added to cart!!');
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartPage(),
              ),
            );
          });
        } else {
          Utility.showSnacbar(context, 'Item successfully removed from cart!!');
        }
        return true;
      } else if (_data['message'] == 'Auth_token_failure') {
        Utility.authErrorPopup(
            context,
            'Sorry for inconvenience. Their is some authentication problem regarding your account contact support: ' +
                Application.adminPhoneNumber);
        return false;
      } else {
        Utility.showSnacbar(context, 'Some error occurred!!');
        return false;
      }
    } else {
      Utility.printLog('Something went wrong.');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getCourseData();
  }

  Future _loadMoreVertical() async {
    // Utility.printLog('scrolling');
    if (!Provider.of<CoursePageViewModel>(context, listen: false)
        .isReachedEnd) {
      Provider.of<CoursePageViewModel>(context, listen: false)
          .getCourseData(context, isMoreData: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LazyLoadScrollView(
      isLoading: context.watch<CoursePageViewModel>().isVerticalLoading,
      onEndOfPage: () {
        if (!isSearching) {
          Provider.of<CoursePageViewModel>(context, listen: false).setOffset();
          _loadMoreVertical();
        }
      },
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
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
                  child: TextField(
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          isSearching = true;
                        });
                        Provider.of<CoursePageViewModel>(context, listen: false)
                            .setSelectedCategory(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .courseCategories[0]
                                    .name);
                        Provider.of<CoursePageViewModel>(context, listen: false)
                            .getSearchedCourses(value, context);
                      } else {
                        setState(() {
                          isSearching = false;
                        });
                        Provider.of<CoursePageViewModel>(context, listen: false)
                            .setSelectedCategory(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .courseCategories[0]
                                    .name);
                        getCourseData();
                      }
                    },
                    // controller: phoneController,
                    style: const TextStyle(
                      fontFamily: 'EuclidCircularA Regular',
                    ),
                    autofocus: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        MdiIcons.magnify,
                      ),
                      counterText: "",
                      hintText: "Search Courses",
                      focusColor: Palette.contrastColor,
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xffffffff),
                            width: 1.3,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xffffffff), width: 1.0),
                          borderRadius: BorderRadius.circular(10.0)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      filled: true,
                      fillColor: const Color(0xffffffff),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 0.0,
              ),
              SizedBox(
                height: 70.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Provider.of<MainContainerViewModel>(context,
                          listen: false)
                      .courseCategories
                      .length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Provider.of<CoursePageViewModel>(context, listen: false)
                            .setSelectedCategory(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .courseCategories[index]
                                    .name);
                        Provider.of<CoursePageViewModel>(context, listen: false)
                            .getCourseData(context);
                      },
                      child: Container(
                        margin: index == 0
                            ? const EdgeInsets.fromLTRB(24.0, 0.0, 20.0, 0.0)
                            : const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                        child: Chip(
                          labelPadding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 20.0),
                          label: Text(
                            Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .courseCategories[index]
                                .name,
                            style: TextStyle(
                              color: Provider.of<CoursePageViewModel>(context,
                                              listen: false)
                                          .selectedCategory ==
                                      Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .courseCategories[index]
                                          .name
                                  ? Colors.white
                                  : Palette.secondaryColor,
                              fontSize: 12.0,
                              fontFamily: 'EuclidCircularA Regular',
                            ),
                          ),
                          backgroundColor: Provider.of<CoursePageViewModel>(
                                          context,
                                          listen: false)
                                      .selectedCategory ==
                                  Provider.of<MainContainerViewModel>(context,
                                          listen: false)
                                      .courseCategories[index]
                                      .name
                              ? Palette.secondaryColor
                              : Colors.white,
                          elevation: 10.0,
                          shadowColor: Provider.of<CoursePageViewModel>(context,
                                          listen: false)
                                      .selectedCategory ==
                                  Provider.of<MainContainerViewModel>(context,
                                          listen: false)
                                      .courseCategories[index]
                                      .name
                              ? Palette.shadowColor.withOpacity(0.3)
                              : Palette.shadowColor.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 0.0,
              ),
              !context.watch<CoursePageViewModel>().isLoading
                  ? Container()
                  : Provider.of<CoursePageViewModel>(context, listen: false)
                          .courseList
                          .isEmpty
                      ? const Center(
                          child: Text(
                            'No Courses Present..',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 14.0,
                              fontFamily: 'EuclidCircularA Medium',
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth < 576
                                    ? 1
                                    : constraints.maxWidth < 768
                                        ? 3
                                        : constraints.maxWidth < 992
                                            ? 4
                                            : 6,
                                childAspectRatio: constraints.maxWidth < 576
                                    ? 1.3
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
                              itemCount: Provider.of<CoursePageViewModel>(
                                      context,
                                      listen: false)
                                  .courseList
                                  .length,
                              itemBuilder: (context, index) {
                                int counter = 0;
                                int whislistCounter = 0;
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .cart
                                    .forEach((element) {
                                  if (element.item_id ==
                                          Provider.of<CoursePageViewModel>(
                                                  context,
                                                  listen: false)
                                              .courseList[index]
                                              .id &&
                                      element.item_category == 'course' &&
                                      element.cart_category == 'cart') {
                                    counter++;
                                  }
                                });
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .whislist
                                    .forEach((element) {
                                  if (element.item_id ==
                                          Provider.of<CoursePageViewModel>(
                                                  context,
                                                  listen: false)
                                              .courseList[index]
                                              .id &&
                                      element.item_category == 'course' &&
                                      element.cart_category == 'whislist') {
                                    whislistCounter++;
                                  }
                                });
                                return CourseMainCard(
                                  marginLeft: constraints.maxWidth < 576
                                      ? 24.0
                                      : constraints.maxWidth < 768
                                          ? index % 3 == 0
                                              ? 24.0
                                              : 0.0
                                          : constraints.maxWidth < 992
                                              ? index % 4 == 0
                                                  ? 24.0
                                                  : 0.0
                                              : index % 6 == 0
                                                  ? 24.0
                                                  : 0.0,
                                  marginRight: constraints.maxWidth < 576
                                      ? 24.0
                                      : constraints.maxWidth < 768
                                          ? index % 3 == 2
                                              ? 24.0
                                              : 0.0
                                          : constraints.maxWidth < 992
                                              ? index % 4 == 3
                                                  ? 24.0
                                                  : 0.0
                                              : index % 6 == 5
                                                  ? 24.0
                                                  : 0.0,
                                  onAddPressed: () {
                                    setState(() {
                                      if (Provider.of<CoursePageViewModel>(
                                                  context,
                                                  listen: false)
                                              .courseList[index]
                                              .category ==
                                          'free') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EachCourse(
                                              id: Provider.of<
                                                          CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .id,
                                            ),
                                          ),
                                        );
                                      } else if (Provider.of<
                                                      CoursePageViewModel>(
                                                  context,
                                                  listen: false)
                                              .courseList[index]
                                              .subscribed >
                                          0) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EachCourse(
                                              id: Provider.of<
                                                          CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .id,
                                            ),
                                          ),
                                        );
                                      } else {
                                        if (counter >= 1) {
                                          updateCart(
                                              Provider.of<CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .id,
                                              'remove',
                                              '');
                                          Provider.of<MainContainerViewModel>(
                                                  context,
                                                  listen: false)
                                              .cart
                                              .removeWhere((element) =>
                                                  element.item_id ==
                                                      Provider.of<CoursePageViewModel>(
                                                              context,
                                                              listen: false)
                                                          .courseList[index]
                                                          .id &&
                                                  element.item_category ==
                                                      'course' &&
                                                  element.cart_category ==
                                                      'cart');
                                          context
                                              .read<MainContainerViewModel>()
                                              .setCart(Provider.of<
                                                          MainContainerViewModel>(
                                                      context,
                                                      listen: false)
                                                  .cart);
                                          counter = 0;
                                        } else {
                                          updateCart(
                                              Provider.of<CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .id,
                                              'add',
                                              Provider.of<CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .image_path,
                                              title: Provider.of<
                                                          CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .title,
                                              price: Provider.of<
                                                          CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .discount_price);
                                          var newItem = CartItem(
                                            cart_id: '',
                                            item_id: Provider.of<
                                                        CoursePageViewModel>(
                                                    context,
                                                    listen: false)
                                                .courseList[index]
                                                .id,
                                            name: Provider.of<
                                                        CoursePageViewModel>(
                                                    context,
                                                    listen: false)
                                                .courseList[index]
                                                .title,
                                            price: int.parse(Provider.of<
                                                        CoursePageViewModel>(
                                                    context,
                                                    listen: false)
                                                .courseList[index]
                                                .discount_price),
                                            cart_category: 'cart',
                                            image_path: Provider.of<
                                                        CoursePageViewModel>(
                                                    context,
                                                    listen: false)
                                                .courseList[index]
                                                .image_path,
                                            quantity: 0,
                                            item_category: 'course',
                                          );
                                          Provider.of<MainContainerViewModel>(
                                                  context,
                                                  listen: false)
                                              .cart
                                              .add(newItem);
                                          context
                                              .read<MainContainerViewModel>()
                                              .setCart(Provider.of<
                                                          MainContainerViewModel>(
                                                      context,
                                                      listen: false)
                                                  .cart);
                                          counter = 1;
                                        }
                                      }
                                    });
                                  },
                                  course: Provider.of<CoursePageViewModel>(
                                          context,
                                          listen: false)
                                      .courseList[index],
                                  onWhislistPressed: () {
                                    setState(() {
                                      if (whislistCounter >= 1) {
                                        updateWhislist(
                                            Provider.of<CoursePageViewModel>(
                                                    context,
                                                    listen: false)
                                                .courseList[index]
                                                .id,
                                            'remove',
                                            '');
                                        whislistCounter = 0;
                                        Provider.of<MainContainerViewModel>(
                                                context,
                                                listen: false)
                                            .whislist
                                            .removeWhere((element) =>
                                                element.item_id ==
                                                    Provider.of<CoursePageViewModel>(
                                                            context,
                                                            listen: false)
                                                        .courseList[index]
                                                        .id &&
                                                element.item_category ==
                                                    'course' &&
                                                element.cart_category ==
                                                    'whislist');
                                        context
                                            .read<MainContainerViewModel>()
                                            .setWhislist(Provider.of<
                                                        MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .whislist);
                                      } else {
                                        updateWhislist(
                                            Provider.of<CoursePageViewModel>(
                                                    context,
                                                    listen: false)
                                                .courseList[index]
                                                .id,
                                            'add',
                                            Provider.of<CoursePageViewModel>(
                                                    context,
                                                    listen: false)
                                                .courseList[index]
                                                .image_path,
                                            title: Provider.of<
                                                        MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .featured_courses[index]
                                                .title,
                                            price: Provider.of<
                                                        MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .featured_courses[index]
                                                .discount_price);
                                        whislistCounter = 1;

                                        var newItem = CartItem(
                                          cart_id: '',
                                          item_id:
                                              Provider.of<CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .id,
                                          name:
                                              Provider.of<CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .title,
                                          price: int.parse(
                                              Provider.of<CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .discount_price),
                                          cart_category: 'whislist',
                                          image_path:
                                              Provider.of<CoursePageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .courseList[index]
                                                  .image_path,
                                          quantity: 0,
                                          item_category: 'course',
                                        );
                                        Provider.of<MainContainerViewModel>(
                                                context,
                                                listen: false)
                                            .whislist
                                            .add(newItem);
                                        context
                                            .read<MainContainerViewModel>()
                                            .setWhislist(Provider.of<
                                                        MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .whislist);
                                      }
                                    });
                                  },
                                  whislistCounter: whislistCounter,
                                  counter: counter,
                                );
                              },
                            );
                          },
                        ),
              !context.watch<CoursePageViewModel>().isLoading
                  ? Container()
                  : Container(
                      child: !context
                              .watch<CoursePageViewModel>()
                              .isVerticalLoading
                          ? const Center()
                          : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text('Loading...'),
                              ),
                            ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
