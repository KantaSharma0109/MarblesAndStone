import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../pages/image/open_image.dart';
import '../viewmodels/main_container_viewmodel.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List list = [];
  bool isLoading = false;

  void getGalleryImages() {
    list.clear();
    Provider.of<MainContainerViewModel>(context, listen: false)
        .gallery
        .forEach((image) {
      list.add(image.image_path);
    });
    setState(() => isLoading = true);
  }

  @override
  void initState() {
    super.initState();
    getGalleryImages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 768) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: Constants.imgBackendUrl + list[0]),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: '${Constants.imgBackendUrl}${list[0]}',
                            placeholder: (context, url) =>
                                const ImagePlaceholder(),
                            errorWidget: (context, url, error) =>
                                const ImagePlaceholder(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 224.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OpenImage(
                                      url: Constants.imgBackendUrl + list[1]),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl:
                                    '${Constants.imgBackendUrl}${list[1]}',
                                placeholder: (context, url) =>
                                    const ImagePlaceholder(),
                                errorWidget: (context, url, error) =>
                                    const ImagePlaceholder(),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 105.0,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 14.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OpenImage(
                                      url: Constants.imgBackendUrl + list[2]),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl:
                                    '${Constants.imgBackendUrl}${list[2]}',
                                placeholder: (context, url) =>
                                    const ImagePlaceholder(),
                                errorWidget: (context, url, error) =>
                                    const ImagePlaceholder(),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 105.0,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              if (constraints.maxWidth < 2560) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: Constants.imgBackendUrl + list[0]),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: '${Constants.imgBackendUrl}${list[0]}',
                            placeholder: (context, url) =>
                                const ImagePlaceholder(),
                            errorWidget: (context, url, error) =>
                                const ImagePlaceholder(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 350.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: Constants.imgBackendUrl + list[1]),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: '${Constants.imgBackendUrl}${list[1]}',
                            placeholder: (context, url) =>
                                const ImagePlaceholder(),
                            errorWidget: (context, url, error) =>
                                const ImagePlaceholder(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 350.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: Constants.imgBackendUrl + list[2]),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: '${Constants.imgBackendUrl}${list[2]}',
                            placeholder: (context, url) =>
                                const ImagePlaceholder(),
                            errorWidget: (context, url, error) =>
                                const ImagePlaceholder(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 350.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: '${Constants.imgBackendUrl}${list[0]}',
                          placeholder: (context, url) =>
                              const ImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              const ImagePlaceholder(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 224.0,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: '${Constants.imgBackendUrl}${list[1]}',
                          placeholder: (context, url) =>
                              const ImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              const ImagePlaceholder(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 224.0,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: '${Constants.imgBackendUrl}${list[2]}',
                          placeholder: (context, url) =>
                              const ImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              const ImagePlaceholder(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 224.0,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          );
  }
}
