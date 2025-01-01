import 'dart:io';
// import 'package:chef_taruna_birla/pages/main_container.dart';
import 'package:chef_taruna_birla/pages/main_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:get/get_navigation/src/routes/get_route.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:chef_taruna_birla/viewmodels/deepLink.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chef_taruna_birla/pages/startup/splash.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:chef_taruna_birla/viewmodels/main_container_viewmodel.dart';
import 'package:chef_taruna_birla/viewmodels/blog_page_viewmodel.dart';
import 'package:chef_taruna_birla/viewmodels/course_page_viewmodel.dart';
import 'package:chef_taruna_birla/viewmodels/product_page_viewmodel.dart';
import 'package:chef_taruna_birla/viewmodels/login_page_view_model.dart';

//App Files
import 'config/config.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.max,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ReceivedNotification {
  ReceivedNotification({
    required this.url,
  });

  final String url;
}

String? selectedNotificationPayload;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // Utility.printLog("Handling a background message: ${message.messageId}");
  // Utility.printLog("message: ${message.messageId}");

  // context.read<DeepLink>().setDeepLinkUrl(message.data["openURL"].toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //Firebase Initialisation
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

//Device Orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MainContainerViewModel()),
      ChangeNotifierProvider(create: (_) => BlogPageViewModel()),
      ChangeNotifierProvider(create: (_) => CoursePageViewModel()),
      ChangeNotifierProvider(create: (_) => ProductPageViewModel()),
      ChangeNotifierProvider(create: (_) => LoginPageViewModel()),
      ChangeNotifierProvider(create: (_) => DeepLink()),
    ],
    child: const MyApp(),
  ));
  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _authStatus = 'Unknown';
  bool _initialized = false;
  bool _error = false;
  bool isTokenLoaded = false;

  Future<void> blockScreenRecording() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (Platform.isAndroid) {
      await FlutterWindowManagerPlus.addFlags(
          FlutterWindowManagerPlus.FLAG_SECURE);
    } else if (Platform.isIOS) {
      // initPlugin();
    }
    setState(() => {isTokenLoaded = true});
  }

// Define an async function to initialize FlutterFire
  void initializeFlutterFire(BuildContext context) async {
    Application.deepLinkUrl = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedToken = prefs.getString('token') ?? '';
    if (savedToken.isEmpty) {
      String? _token;
      String? _apnsToken;
      try {
        _initialized = true;
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        if (Platform.isIOS) {
          _apnsToken = await messaging.getAPNSToken();
          NotificationSettings settings = await messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );
          Utility.printLog(
              'User granted permission: ${settings.authorizationStatus}');
        }
        _token = await messaging.getToken();
        if (_token != null) {
          // Utility.printLog('FCM token $_token');
          //Saving FCM token to local data
          Application.deviceToken = _token;
          prefs.setString('token', _token);
        }
      } catch (e) {
        Utility.printLog(e.toString());
        _error = true;
      }
    } else {
      Application.deviceToken = savedToken;
      // Utility.printLog('SAVED FCM token $savedToken');
    }
    blockScreenRecording();
    if (context.read<DeepLink>().deepLinkUrl.isEmpty) {
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        context.read<DeepLink>().setDeepLinkUrl('');
        if (message != null) {
          Utility.printLog('Initial Message clicked!');
          Utility.printLog(message.data["openURL"].toString());
          context
              .read<DeepLink>()
              .setDeepLinkUrl(message.data["openURL"].toString());
          Application.isDeepLink = true;
          Application.deepLinkUrl = message.data["openURL"].toString();
        }
        message = null;
      });
    } else {
      context.read<DeepLink>().setDeepLinkUrl('');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Utility.printLog(
          "message recieved =" + message.data["openURL"].toString());
      if (android != null) {
        context.read<DeepLink>().setDeepLinkUrl('notifications');
      }
      if (notification != null) {
        context
            .read<DeepLink>()
            .setDeepLinkUrl(message.data["openURL"].toString());
      }
      Application.isDeepLink = true;
      Application.deepLinkUrl = message.data["openURL"].toString();
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Utility.printLog('Message clicked!');
      Utility.printLog(message.data["openURL"].toString());
      context
          .read<DeepLink>()
          .setDeepLinkUrl(message.data["openURL"].toString());
      Application.isDeepLink = true;
      Application.deepLinkUrl = message.data["openURL"].toString();
    });
  }

  Future<void> clearScreenRecording() async {
    if (Platform.isAndroid) {
      await FlutterWindowManagerPlus.clearFlags(
          FlutterWindowManagerPlus.FLAG_SECURE);
    }
  }

  // Future<void> getAppData() async {
  //   // Wait for the data to be fetched before proceeding
  //   await Provider.of<MainContainerViewModel>(context, listen: false)
  //       .getAppData(context);
  // }
  Future<void> getAppData(BuildContext context) async {
    // Wait for the data to be fetched before navigating
    await Provider.of<MainContainerViewModel>(context, listen: false)
        .getAppData(context);

    // You can perform any necessary navigation after data is fetched if needed
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire(context);
  }

  @override
  void dispose() {
    super.dispose();
    clearScreenRecording();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chef Taruna Birla',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Palette.scaffoldColor,
      ),
      // home: const SplashScreen(),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, AsyncSnapshot<User?> user) {
            if (user.hasData) {
              getAppData(context);
              return MainContainer();
            } else {
              return SplashScreen();
            }
          }),
    );
    //   return !isTokenLoaded
    //       ? const MaterialApp(
    //           home: Material(
    //             child: Center(
    //               child: CircularProgressIndicator(),
    //             ),
    //           ),
    //           debugShowCheckedModeBanner: false,
    //         )
    //       : GetMaterialApp(
    //           builder: EasyLoading.init(),
    //           title: 'Chef Taruna Birla',
    //           theme: ThemeData(
    //             primarySwatch: Colors.blue,
    //             visualDensity: VisualDensity.adaptivePlatformDensity,
    //             scaffoldBackgroundColor: Palette.scaffoldColor,
    //           ),
    //           getPages: [
    //             GetPage(
    //               name: Routes.SPLASH_SCREEN,
    //               page: () => const SplashScreen(),
    //             ),
    //             GetPage(
    //               name: Routes.FIREBASE_LINK_ROUTE,
    //               page: () => const MainContainer(),
    //             ),
    //           ],
    //           initialRoute: Routes.SPLASH_SCREEN,
    //           debugShowCheckedModeBanner: false,
    //         );
  }
}

class Routes {
  static const String SPLASH_SCREEN = '/';
  static const String FIREBASE_LINK_ROUTE = '/link';
}
