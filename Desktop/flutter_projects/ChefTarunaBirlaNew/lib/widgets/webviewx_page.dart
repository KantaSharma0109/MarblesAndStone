import 'package:chef_taruna_birla/pages/live_integration/live_classes.dart';
import 'package:chef_taruna_birla/pages/main_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
// import 'package:wakelock/wakelock.dart';
// import 'package:webviewx/webviewx.dart';

import '../pages/notifications/notification_page.dart';
import '../utils/utility.dart';
import '../viewmodels/main_container_viewmodel.dart';

class WebviewXPage extends StatefulWidget {
  final String url;
  final bool fullScreen;
  const WebviewXPage({Key? key, required this.url, required this.fullScreen})
      : super(key: key);

  @override
  _WebviewXPageState createState() => _WebviewXPageState();
}

class _WebviewXPageState extends State<WebviewXPage> {
  late WebViewXController webviewController;
  late bool isFullscreen;
  Size get screenSize => MediaQuery.of(context).size;

  @override
  void initState() {
    super.initState();
    isFullscreen = widget.fullScreen;
    if (isFullscreen) {
      setLandscape();
    } else {
      setAllOrientation();
    }
  }

  Future setLandscape() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await WakelockPlus.enabled;
  }

  Future setAllOrientation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await WakelockPlus.enabled;
  }

  @override
  void dispose() {
    webviewController.dispose();
    setAllOrientation();
    super.dispose();
  }

  void showSnackBar(String content, BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(content),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: widget.url,
      initialSourceType: SourceType.url,
      height: screenSize.height,
      width: screenSize.width,
      onWebViewCreated: (controller) => webviewController = controller,
      onPageStarted: (src) {
        debugPrint('A new page has started loading: $src\n');
        if (src.toString().contains('mailto') ||
            src.toString().contains('tel')) {
          launchUrl(Uri.parse(src));
          webviewController.goBack();
        }
      },
      onPageFinished: (src) {
        debugPrint('The page has finished loading: $src\n');
        if (src.toString().contains('live_subscription_successfull')) {
          context.watch<MainContainerViewModel>().setNotificationCount();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LiveClasses(),
            ),
          );
          Utility.showSnacbar(
            context,
            'Your purchase of live class is successful!!, please click here to check',
            onClicked: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
            duration: 2,
          );
        } else if (src.toString().contains('subscription_successfull')) {
          context.watch<MainContainerViewModel>().setCart([]);
          context.watch<MainContainerViewModel>().setNotificationCount();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainContainer(),
            ),
            (Route<dynamic> route) => false,
          );
          Utility.showSnacbar(
            context,
            'Your purchase is successful!!, please click here to check',
            onClicked: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
            duration: 2,
          );
        }
      },
      jsContent: {
        EmbeddedJsContent(
          js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
        ),
        EmbeddedJsContent(
          webJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
          mobileJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
        ),
      },
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => showSnackBar(msg.toString(), context),
        )
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        debugPrint(navigation.content.sourceType.toString());
        return NavigationDecision.navigate;
      },
    );
  }
}
