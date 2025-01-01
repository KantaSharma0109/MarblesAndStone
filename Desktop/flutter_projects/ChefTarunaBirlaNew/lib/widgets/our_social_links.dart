import 'package:chef_taruna_birla/widgets/social_link_container.dart';
import 'package:chef_taruna_birla/widgets/webviewx_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../models/social_links.dart';
import '../pages/common/comming_soon.dart';
import '../viewmodels/main_container_viewmodel.dart';

class OurSocialLinks extends StatefulWidget {
  const OurSocialLinks({Key? key}) : super(key: key);

  @override
  State<OurSocialLinks> createState() => _OurSocialLinksState();
}

class _OurSocialLinksState extends State<OurSocialLinks> {
  List<SocialLinks> ourSocialLinks = [];
  bool isLoading = false;

  void setCourseCategory() {
    ourSocialLinks.clear();
    Provider.of<MainContainerViewModel>(context, listen: false)
        .sociallinks
        .forEach((socialLink) {
      if (socialLink.show_category == 'social_link' &&
          socialLink.url != 'null') {
        ourSocialLinks.add(
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
                      ? 6
                      : constraints.maxWidth < 768
                          ? 3
                          : constraints.maxWidth < 992
                              ? 4
                              : 6,
                  childAspectRatio: constraints.maxWidth < 576
                      ? 0.8
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
                  crossAxisSpacing: 14.0,
                ),
                itemCount: ourSocialLinks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (ourSocialLinks[index].url != 'null') {
                        // launchUrl(Uri.parse(ourSocialLinks[index].url));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebviewXPage(
                              url: ourSocialLinks[index].url,
                              fullScreen: false,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommingSoonPage(
                              title: ourSocialLinks[index].name,
                            ),
                          ),
                        );
                      }
                    },
                    child: SocialLinkContainer(
                      imagePath: Constants.imgBackendUrl +
                          ourSocialLinks[index].image_path,
                      marginLeft: 0.0,
                      marginRight: 0.0,
                    ),
                  );
                },
              );
            },
          );
  }
}
