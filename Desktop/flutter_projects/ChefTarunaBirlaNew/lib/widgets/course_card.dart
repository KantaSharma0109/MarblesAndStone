import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/models/course.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../config/config.dart';
import '../pages/course/each_course.dart';
import '../utils/utility.dart';
import 'image_placeholder.dart';

class CourseMainCard extends StatelessWidget {
  final double marginLeft;
  final double marginRight;
  final void Function() onAddPressed;
  final void Function() onWhislistPressed;
  final Course course;
  final int whislistCounter;
  final int counter;
  const CourseMainCard({
    Key? key,
    required this.marginLeft,
    required this.marginRight,
    required this.onAddPressed,
    required this.course,
    required this.onWhislistPressed,
    this.whislistCounter = 0,
    this.counter = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EachCourse(
              id: course.id,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(marginLeft, 5.0, marginRight, 5.0),
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EachCourse(
                              id: course.id,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: Constants.imgBackendUrl + course.image_path,
                          placeholder: (context, url) =>
                              const ImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              const ImagePlaceholder(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          course.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Palette.black,
                            fontSize: 16.0,
                            fontFamily: 'EuclidCircularA Regular',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          course.category == 'free'
                              ? 'Free'
                              : 'Rs ${course.discount_price}',
                          style: const TextStyle(
                            color: Palette.contrastColor,
                            fontSize: 14.0,
                            fontFamily: 'EuclidCircularA Medium',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              course.category == 'free'
                                  ? ''
                                  : course.discount_price == course.price
                                      ? ''
                                      : 'Rs ${course.price}',
                              style: const TextStyle(
                                color: Palette.grey,
                                fontSize: 14.0,
                                fontFamily: 'EuclidCircularA Regular',
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              course.category == 'free'
                                  ? ''
                                  : course.discount_price == course.price
                                      ? ''
                                      : '${(((int.parse(course.price) - int.parse(course.discount_price)) / int.parse(course.price)) * 100).toString().substring(0, 4)} %',
                              style: const TextStyle(
                                color: Palette.discount,
                                fontSize: 14.0,
                                fontFamily: 'EuclidCircularA Medium',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          onAddPressed();
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Palette.secondaryColor,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Center(
                              child: counter >= 1
                                  ? Text(
                                      course.category == 'free'
                                          ? 'Read'
                                          : course.subscribed > 0
                                              ? 'Open'
                                              : 'Remove',
                                      style: const TextStyle(
                                        color: Palette.white,
                                        fontSize: 14.0,
                                        fontFamily: 'EuclidCircularA Medium',
                                      ),
                                    )
                                  : Text(
                                      course.category == 'free'
                                          ? 'Read'
                                          : course.subscribed > 0
                                              ? 'Open'
                                              : 'Add to cart',
                                      style: const TextStyle(
                                        color: Palette.white,
                                        fontSize: 14.0,
                                        fontFamily: 'EuclidCircularA Medium',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Utility.printLog('whislist pressed');
                  onWhislistPressed();
                },
                child: Container(
                  height: 30.0,
                  width: 30.0,
                  decoration: BoxDecoration(
                    color: Palette.white,
                    borderRadius: BorderRadius.circular(50.0),
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
                  child: Icon(
                    whislistCounter >= 1
                        ? MdiIcons.heart
                        : MdiIcons.heartOutline,
                    size: 20.0,
                    color: Palette.contrastColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
