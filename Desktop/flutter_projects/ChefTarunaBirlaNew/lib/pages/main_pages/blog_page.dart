import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/pages/blog/each_blog.dart';
import 'package:chef_taruna_birla/pages/common/pdf_view_page.dart';
import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:chef_taruna_birla/widgets/text_to_html.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../viewmodels/blog_page_viewmodel.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen>
    with AutomaticKeepAliveClientMixin {
  bool isLoadingVertical = false;
  bool isSearching = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> getBlogData() async {
    Provider.of<BlogPageViewModel>(context, listen: false).getBlogData(context);
    // await Future.delayed(const Duration(milliseconds: 3000));
  }

  @override
  void initState() {
    super.initState();
    //get Blogs Data
    getBlogData();
  }

  Future _loadMoreVertical() async {
    Utility.printLog('scrolling');
    Provider.of<BlogPageViewModel>(context, listen: false)
        .getMoreBlogData(context);
  }

  @override
  Widget build(BuildContext context) {
    return LazyLoadScrollView(
      isLoading: context.watch<BlogPageViewModel>().isVerticalLoading,
      onEndOfPage: () {
        if (!isSearching) {
          Provider.of<BlogPageViewModel>(context, listen: false).setOffset();
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
                        Provider.of<BlogPageViewModel>(context, listen: false)
                            .getSearchedBlogs(value, context);
                      } else {
                        setState(() {
                          isSearching = false;
                        });
                        getBlogData();
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
                      hintText: "Search Blogs",
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
                height: 20.0,
              ),
              !context.watch<BlogPageViewModel>().isLoading
                  ? Container()
                  : firstBlog(),
              !context.watch<BlogPageViewModel>().isLoading
                  ? Container()
                  : blogList(),
              !context.watch<BlogPageViewModel>().isLoading
                  ? Container()
                  : Container(
                      child:
                          !context.watch<BlogPageViewModel>().isVerticalLoading
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

  Widget firstBlog() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 0.0,
        horizontal: 24.0,
      ),
      child: context.watch<BlogPageViewModel>().firstBlog!.title.isEmpty
          ? Center(
              child: Container(),
            )
          : GestureDetector(
              onTap: () {
                if (Provider.of<BlogPageViewModel>(context, listen: false)
                    .firstBlog!
                    .pdflink
                    .isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewPage(
                        path: Constants.imgBackendUrl +
                            Provider.of<BlogPageViewModel>(context,
                                    listen: false)
                                .firstBlog!
                                .pdflink,
                        isHorizontal: false,
                      ),
                    ),
                  );
                } else {
                  Utility.printLog('No Pdf is present');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EachBlog(
                        title:
                            context.watch<BlogPageViewModel>().firstBlog!.title,
                        description: context
                            .watch<BlogPageViewModel>()
                            .firstBlog!
                            .description,
                        id: context.watch<BlogPageViewModel>().firstBlog!.id,
                        time: DateTime.parse(context
                                .watch<BlogPageViewModel>()
                                .firstBlog!
                                .created_at)
                            .toString()
                            .substring(0, 10),
                        share_url: context
                            .watch<BlogPageViewModel>()
                            .firstBlog!
                            .share_url,
                      ),
                    ),
                  );
                }
              },
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: Constants.imgBackendUrl +
                              context
                                  .watch<BlogPageViewModel>()
                                  .firstBlog!
                                  .image_path,
                          placeholder: (context, url) =>
                              const ImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              const ImagePlaceholder(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      child: Text(
                        context.watch<BlogPageViewModel>().firstBlog!.title,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontFamily: 'EuclidCircularA Medium'),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      child: TextToHtml(
                        description:
                            '${context.watch<BlogPageViewModel>().firstBlog!.description.substring(0, 80)}...',
                        textColor: Palette.textGrey,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            DateTime.parse(context
                                    .watch<BlogPageViewModel>()
                                    .firstBlog!
                                    .created_at)
                                .toString()
                                .substring(0, 10),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Palette.contrastColor,
                                fontSize: 14.0,
                                fontFamily: 'EuclidCircularA Regular'),
                          ),
                          const SizedBox(
                            width: 6.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget blogList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: context.watch<BlogPageViewModel>().bloglist.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const SizedBox(
            height: 8.0,
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                if (Provider.of<BlogPageViewModel>(context, listen: false)
                    .bloglist[index]
                    .pdflink
                    .isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewPage(
                        path: Constants.imgBackendUrl +
                            Provider.of<BlogPageViewModel>(context,
                                    listen: false)
                                .bloglist[index]
                                .pdflink,
                        isHorizontal: false,
                      ),
                    ),
                  );
                } else {
                  Utility.printLog('No Pdf is present');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EachBlog(
                        title: context
                            .watch<BlogPageViewModel>()
                            .bloglist[index]
                            .title,
                        description: context
                            .watch<BlogPageViewModel>()
                            .bloglist[index]
                            .description,
                        id: context
                            .watch<BlogPageViewModel>()
                            .bloglist[index]
                            .id,
                        time: DateTime.parse(context
                                .watch<BlogPageViewModel>()
                                .bloglist[index]
                                .created_at)
                            .toString()
                            .substring(0, 10),
                        share_url: context
                            .watch<BlogPageViewModel>()
                            .bloglist[index]
                            .share_url,
                      ),
                    ),
                  );
                }
              },
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: Constants.imgBackendUrl +
                                context
                                    .watch<BlogPageViewModel>()
                                    .bloglist[index]
                                    .image_path,
                            placeholder: (context, url) =>
                                const ImagePlaceholder(),
                            errorWidget: (context, url, error) =>
                                const ImagePlaceholder(),
                            fit: BoxFit.cover,
                            height: 70.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Text(
                                '${context.watch<BlogPageViewModel>().bloglist[index].title.length > 50 ? context.watch<BlogPageViewModel>().bloglist[index].title.substring(0, 50) : context.watch<BlogPageViewModel>().bloglist[index].title}..',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontFamily: 'EuclidCircularA Medium'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateTime.parse(context
                                            .watch<BlogPageViewModel>()
                                            .bloglist[index]
                                            .created_at)
                                        .toString()
                                        .substring(0, 10),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Palette.contrastColor,
                                        fontSize: 12.0,
                                        fontFamily: 'EuclidCircularA Regular'),
                                  ),
                                  const SizedBox(
                                    width: 6.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
