import 'package:chef_taruna_birla/config/config.dart';
import 'package:chef_taruna_birla/models/social_links.dart';
import 'package:chef_taruna_birla/pages/book/books_page.dart';
import 'package:chef_taruna_birla/pages/common/comming_soon.dart';
import 'package:chef_taruna_birla/widgets/social_link_container.dart';
import 'package:chef_taruna_birla/widgets/webviewx_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../viewmodels/main_container_viewmodel.dart';

class OurStore extends StatefulWidget {
  const OurStore({Key? key}) : super(key: key);

  @override
  State<OurStore> createState() => _OurStoreState();
}

class _OurStoreState extends State<OurStore> {
  List<SocialLinks> ourStore = [];
  bool isLoading = false;

  void setCourseCategory() {
    ourStore.clear();
    Provider.of<MainContainerViewModel>(context, listen: false)
        .sociallinks
        .forEach((socialLink) {
      if (socialLink.show_category == 'our_store') {
        ourStore.add(
          SocialLinks(
            id: socialLink.id,
            name: socialLink.name,
            url: socialLink.url,
            image_path: socialLink.image_path,
            show_category: socialLink.show_category,
            linked_category: socialLink.linked_category,
            linked_array: socialLink.linked_array,
          ),
        );
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
                      ? 1.0
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
                itemCount: ourStore.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (ourStore[index].linked_category == 'no') {
                        if (ourStore[index].url != 'null') {
                          // launchUrl(Uri.parse(ourStore[index].url));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebviewXPage(
                                url: ourStore[index].url,
                                fullScreen: false,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommingSoonPage(
                                title: ourStore[index].name,
                              ),
                            ),
                          );
                        }
                      } else if (ourStore[index].linked_category == 'course') {
                        Provider.of<MainContainerViewModel>(context,
                                listen: false)
                            .navigationQueue
                            .addLast(0);
                        Provider.of<MainContainerViewModel>(context,
                                listen: false)
                            .setIndex(2);
                      } else if (ourStore[index].linked_category == 'product') {
                        Provider.of<MainContainerViewModel>(context,
                                listen: false)
                            .navigationQueue
                            .addLast(0);
                        Provider.of<MainContainerViewModel>(context,
                                listen: false)
                            .setIndex(3);
                      } else if (ourStore[index].linked_category == 'book') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BooksPage(),
                          ),
                        );
                      }
                    },
                    child: SocialLinkContainer(
                      imagePath:
                          Constants.imgBackendUrl + ourStore[index].image_path,
                      marginLeft: index % 2 == 0 ? 24.0 : 0.0,
                      marginRight: index % 2 == 0 ? 0.0 : 24.0,
                    ),
                  );
                },
              );
            },
          );
  }
}
