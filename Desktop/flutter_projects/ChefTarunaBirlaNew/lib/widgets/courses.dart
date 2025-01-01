import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/config/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/live_integration/live_classes.dart';
import '../viewmodels/course_page_viewmodel.dart';
import '../viewmodels/main_container_viewmodel.dart';
import 'image_placeholder.dart';

class Courses extends StatefulWidget {
  const Courses({
    Key? key,
  }) : super(key: key);

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> with AutomaticKeepAliveClientMixin {
  List imageList = [];
  List nameList = [];
  bool isLoading = false;

  void setCourseCategory() {
    nameList.clear();
    imageList.clear();
    Provider.of<MainContainerViewModel>(context, listen: false)
        .courseCategories
        .forEach((coursecat) {
      if (coursecat.imp == '1') {
        nameList.add(coursecat.name);
        imageList.add(coursecat.image_path);
      }
    });
    setState(() => isLoading = true);
  }

  @override
  void initState() {
    super.initState();
    setCourseCategory();
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
                      ? 0.75
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
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (nameList[index].toString().toLowerCase() == 'live') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LiveClasses(),
                          ),
                        );
                      } else {
                        Provider.of<MainContainerViewModel>(context,
                                listen: false)
                            .navigationQueue
                            .addLast(0);
                        Provider.of<CoursePageViewModel>(context, listen: false)
                            .setSelectedCategory(nameList[index]);
                        Provider.of<MainContainerViewModel>(context,
                                listen: false)
                            .setIndex(2);
                      }
                    },
                    child: courseCard(
                      '${nameList[index]}\nCourses',
                      constraints.maxWidth < 576
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
                      constraints.maxWidth < 576
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
                      '${Constants.imgBackendUrl}${imageList[index]}',
                    ),
                  );
                },
              );
            },
          );
  }

  Widget courseCard(
      String name, double marginLeft, double marginRight, String imagePath) {
    return Container(
      margin: EdgeInsets.fromLTRB(marginLeft, 12.0, marginRight, 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Palette.shadowColorTwo.withOpacity(0.7),
            blurRadius: 6.0, // soften the shadow
            spreadRadius: 2.0, //extend the shadow
            offset: const Offset(
              0.0, // Move to right 10  horizontally
              0.0, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          children: [
            Flexible(
              child: CachedNetworkImage(
                imageUrl: imagePath,
                placeholder: (context, url) => const ImagePlaceholder(),
                errorWidget: (context, url, error) => const ImagePlaceholder(),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(color: Palette.white),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                            color: Palette.black,
                            fontSize: 16.0,
                            fontFamily: 'EuclidCircularA Medium'),
                      ),
                    ),
                    Container(
                      height: 32.0,
                      width: 32.0,
                      decoration: BoxDecoration(
                          color: Palette.white,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
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
  }

  @override
  bool get wantKeepAlive => true;
}
