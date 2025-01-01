import 'package:chef_taruna_birla/models/cart_item.dart';
import 'package:chef_taruna_birla/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_functions.dart';
import '../config/config.dart';
import '../models/course.dart';
import '../pages/cart/cart_page.dart';
import '../pages/course/each_course.dart';
import '../utils/utility.dart';
import '../viewmodels/main_container_viewmodel.dart';

class FeaturedCourses extends StatefulWidget {
  const FeaturedCourses({Key? key}) : super(key: key);

  @override
  State<FeaturedCourses> createState() => _FeaturedCoursesState();
}

class _FeaturedCoursesState extends State<FeaturedCourses> {
  List<Course> featuredCourses = [];
  bool isLoading = false;
  String url = Constants.finalUrl;

  //
  void setFeaturedCourses() async {
    setState(() {
      isLoading = true;
    });
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
  Future<void> updateCart(id, value, imagePath,
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
    }
  }

  @override
  void initState() {
    super.initState();
    setFeaturedCourses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Container()
        : LayoutBuilder(
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
                      ? 0.66
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
                  crossAxisSpacing: 10.0,
                ),
                itemCount:
                    Provider.of<MainContainerViewModel>(context, listen: false)
                        .featured_courses
                        .length,
                itemBuilder: (context, index) {
                  int counter = 0;
                  int whislistcounter = 0;
                  Provider.of<MainContainerViewModel>(context, listen: false)
                      .cart
                      .forEach((element) {
                    if (element.item_id ==
                            Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .featured_courses[index]
                                .id &&
                        element.item_category == 'course' &&
                        element.cart_category == 'cart') {
                      counter++;
                    }
                  });
                  Provider.of<MainContainerViewModel>(context, listen: false)
                      .whislist
                      .forEach((element) {
                    if (element.item_id ==
                            Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .featured_courses[index]
                                .id &&
                        element.item_category == 'course' &&
                        element.cart_category == 'whislist') {
                      whislistcounter++;
                    }
                  });
                  return CourseMainCard(
                    marginLeft: constraints.maxWidth < 576
                        ? index % 2 == 0
                            ? 24.0
                            : 0.0
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
                        ? index % 2 == 1
                            ? 24.0
                            : 0.0
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
                        if (Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .featured_courses[index]
                                .category ==
                            'free') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EachCourse(
                                id: Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .id,
                              ),
                            ),
                          );
                        } else if (Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .featured_courses[index]
                                .subscribed >
                            0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EachCourse(
                                id: Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .id,
                              ),
                            ),
                          );
                        } else {
                          if (counter >= 1) {
                            updateCart(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .id,
                                'remove',
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .image_path);
                            Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .cart
                                .removeWhere((element) =>
                                    element.item_id ==
                                        Provider.of<MainContainerViewModel>(
                                                context,
                                                listen: false)
                                            .featured_courses[index]
                                            .id &&
                                    element.item_category == 'course' &&
                                    element.cart_category == 'cart');
                            context.read<MainContainerViewModel>().setCart(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .cart);
                            counter = 0;
                          } else {
                            updateCart(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .id,
                                'add',
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .image_path,
                                title: Provider.of<MainContainerViewModel>(
                                        context,
                                        listen: false)
                                    .featured_courses[index]
                                    .title,
                                price: Provider.of<MainContainerViewModel>(
                                        context,
                                        listen: false)
                                    .featured_courses[index]
                                    .discount_price);
                          }
                          counter = 1;
                          var newItem = CartItem(
                            cart_id: '',
                            item_id: Provider.of<MainContainerViewModel>(
                                    context,
                                    listen: false)
                                .featured_courses[index]
                                .id,
                            name: Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .featured_courses[index]
                                .title,
                            price: int.parse(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .discount_price),
                            cart_category: 'cart',
                            image_path: Provider.of<MainContainerViewModel>(
                                    context,
                                    listen: false)
                                .featured_courses[index]
                                .image_path,
                            quantity: 0,
                            item_category: 'course',
                          );
                          Provider.of<MainContainerViewModel>(context,
                                  listen: false)
                              .cart
                              .add(newItem);
                          context.read<MainContainerViewModel>().setCart(
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .cart);
                        }
                      });
                    },
                    course: Provider.of<MainContainerViewModel>(context,
                            listen: false)
                        .featured_courses[index],
                    onWhislistPressed: () {
                      setState(() {
                        if (whislistcounter >= 1) {
                          updateWhislist(
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .featured_courses[index]
                                  .id,
                              'remove',
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .featured_courses[index]
                                  .image_path);
                          whislistcounter = 0;
                          Provider.of<MainContainerViewModel>(context,
                                  listen: false)
                              .whislist
                              .removeWhere((element) =>
                                  element.item_id ==
                                      Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .featured_courses[index]
                                          .id &&
                                  element.item_category == 'course' &&
                                  element.cart_category == 'whislist');
                          context.read<MainContainerViewModel>().setWhislist(
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .whislist);
                        } else {
                          updateWhislist(
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .featured_courses[index]
                                  .id,
                              'add',
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .featured_courses[index]
                                  .image_path,
                              title: Provider.of<MainContainerViewModel>(
                                      context,
                                      listen: false)
                                  .featured_courses[index]
                                  .title,
                              price: Provider.of<MainContainerViewModel>(
                                      context,
                                      listen: false)
                                  .featured_courses[index]
                                  .discount_price);
                          whislistcounter = 1;
                          var newItem = CartItem(
                            cart_id: '',
                            item_id: Provider.of<MainContainerViewModel>(
                                    context,
                                    listen: false)
                                .featured_courses[index]
                                .id,
                            name: Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .featured_courses[index]
                                .title,
                            price: int.parse(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .featured_courses[index]
                                    .discount_price),
                            cart_category: 'whislist',
                            image_path: Provider.of<MainContainerViewModel>(
                                    context,
                                    listen: false)
                                .featured_courses[index]
                                .image_path,
                            quantity: 0,
                            item_category: 'course',
                          );
                          Provider.of<MainContainerViewModel>(context,
                                  listen: false)
                              .whislist
                              .add(newItem);
                          context.read<MainContainerViewModel>().setWhislist(
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .whislist);
                        }
                      });
                    },
                    counter: counter,
                    whislistCounter: whislistcounter,
                  );
                },
              );
            },
          );
  }
}
