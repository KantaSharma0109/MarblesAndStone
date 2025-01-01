import 'dart:io';

import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../config/config.dart';

class PdfViewPage extends StatefulWidget {
  final String path;
  final String filename;
  final String coursename;
  final bool isHorizontal;
  final bool isCourseScreen;
  const PdfViewPage({
    Key? key,
    required this.path,
    this.filename = '',
    this.coursename = '',
    required this.isHorizontal,
    this.isCourseScreen = false,
  }) : super(key: key);

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  // Track the progress of a downloaded file here.
  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = 'File has not been downloaded yet.';
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  // This method uses Dio to download a file from the given URL
  // and saves the file to the provided `savePath`.
  Future download(Dio dio, String url, String savePath) async {
    Utility.showProgress(true);
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      var file = File(savePath).openSync(mode: FileMode.write);
      file.writeFromSync(response.data);
      await OpenFilex.open(file.path);
      await file.close();

      // Here, you're catching an error and printing it. For production
      // apps, you should display the warning to the user and give them a
      // way to restart the download.
    } catch (e) {
      print(e);
    }
  }

  // You can update the download progress here so that the user is
  // aware of the long-running task.
  void updateProgress(done, total) {
    progress = done / total;
    setState(() {
      if (progress >= 1) {
        progressString =
            '✅ File has finished downloading. Try opening the file.';
        // didDownloadPDF = true;
        Utility.showProgress(false);
      } else {
        progressString = 'Download progress: ' +
            (progress * 100).toStringAsFixed(0) +
            '% done.';
        print('Download progress: ' +
            (progress * 100).toStringAsFixed(0) +
            '% done.');
      }
    });
  }

  // permissionServiceCall() async {
  //   await openAppSettings().then(
  //     (value) {
  //       if (value != null) {
  //         if (await Permission.storage.isGranted) {
  //           /* ========= New Screen Added  ============= */
  //
  //         }
  //       }
  //     },
  //   );
  // }

  @override
  void initState() {
    if (Platform.isIOS) {
      // _insecureScreenDetector.initialize();
      // _insecureScreenDetector.addListener(() {
      //   Utility.printLog('add event listener');
      //   Utility.forceLogoutUser(context);
      //   // Utility.forceLogout(context);
      // }, (isCaptured) {
      //   Utility.printLog('screen recording event listener');
      //   // Utility.forceLogoutUser(context);
      //   // Utility.forceLogout(context);
      //   setState(() {
      //     _isCaptured = isCaptured;
      //   });
      // });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isCaptured
        ? const Center(
            child: Text(
              'You are not allowed to do screen recording',
              style: TextStyle(
                fontFamily: 'EuclidCircularA Regular',
                fontSize: 20.0,
                color: Palette.black,
              ),
              textAlign: TextAlign.center,
            ),
          )
        : Scaffold(
            backgroundColor: Palette.scaffoldColor,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Palette.white,
                  size: 18.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                '',
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
              centerTitle: true,
              actions: [
                widget.isCourseScreen
                    ? InkWell(
                        onTap: didDownloadPDF
                            ? null
                            : () async {
                                Map<Permission, PermissionStatus> status =
                                    await [
                                  Permission.storage,
                                ].request();
                                if (status[Permission.storage]?.isGranted ??
                                    false) {
                                  Directory appDocDir =
                                      await getApplicationDocumentsDirectory();
                                  if (Platform.isIOS) {
                                    download(
                                        Dio(),
                                        widget.path,
                                        appDocDir.path +
                                            widget.coursename +
                                            '.pdf');
                                  } else {
                                    download(
                                        Dio(),
                                        widget.path,
                                        '/storage/emulated/0/Download/' +
                                            widget.coursename +
                                            '.pdf');
                                  }
                                } else {
                                  await openAppSettings().then(
                                    (value) async {
                                      if (value) {
                                        if (await Permission.storage.status
                                                    .isPermanentlyDenied ==
                                                true &&
                                            await Permission
                                                    .storage.status.isGranted ==
                                                false) {
                                          openAppSettings();
                                          // permissionServiceCall(); /* opens app settings until permission is granted */
                                        }
                                      }
                                    },
                                  );
                                }
                              },
                        child: Row(
                          children: [
                            Icon(
                              MdiIcons.download,
                              color: Palette.white,
                              size: 24.0,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Download',
                              style: TextStyle(color: Palette.white),
                            ),
                            SizedBox(
                              width: 16.0,
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            body: SfPdfViewer.network(
              widget.path,
              scrollDirection: widget.isHorizontal
                  ? PdfScrollDirection.horizontal
                  : PdfScrollDirection.vertical,
              key: _pdfViewerKey,
              enableDoubleTapZooming: true,
              enableTextSelection: false,
              pageLayoutMode: widget.isHorizontal
                  ? PdfPageLayoutMode.single
                  : PdfPageLayoutMode.continuous,
            ),
          );
  }
}
