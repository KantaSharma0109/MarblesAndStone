import 'dart:async';
import 'dart:io';

import 'package:chef_taruna_birla/pages/wallet/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../services/mysql_db_service.dart';
import 'consumable_store.dart';

const bool _kAutoConsume = true;

const String _kConsumableId = 'com.technotwist.tarunaBirla.wallet';
const String _kUpgradeId = 'non_consumable';
const String _kSilverSubscriptionId = 'wallet_for_user';
const String _kGoldSubscriptionId = 'subscription_gold';
const List<String> _kProductIds = <String>[_kConsumableId];

class AppleCartPaymentPage extends StatefulWidget {
  const AppleCartPaymentPage({Key? key}) : super(key: key);

  @override
  _AppleCartPaymentPageState createState() => _AppleCartPaymentPageState();
}

class _AppleCartPaymentPageState extends State<AppleCartPaymentPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  String finalPrice = '';

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
            _buildConsumableBox(),
            // _buildRestoreButton(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: const [
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
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
          'In App Purchase',
          style: TextStyle(
            color: Palette.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: Palette.appBarColor,
        shadowColor: Palette.shadowColor.withOpacity(1.0),
      ),
      body: Stack(
        children: stack,
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable
              ? Colors.green
              : ThemeData.light().colorScheme.error),
      title: Text(
          'The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return const Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching products...'))));
    }
    if (!_isAvailable) {
      return const Card();
    }
    final ListTile productHeader =
        const ListTile(title: Text('Products for Sale'));
    List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
              'This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: previousPurchase != null
                ? IconButton(
                    onPressed: () => confirmPriceChange(context),
                    icon: const Icon(Icons.upgrade))
                : TextButton(
                    child: Text(productDetails.price),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green[800],
                    ),
                    onPressed: () {
                      late PurchaseParam purchaseParam;

                      setState(() {
                        finalPrice = productDetails.rawPrice.toString();
                      });

                      if (Platform.isAndroid) {
                        // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
                        // verify the latest status of you your subscription by using server side receipt validation
                        // and update the UI accordingly. The subscription purchase status shown
                        // inside the app may not be accurate.
                        final oldSubscription =
                            _getOldSubscription(productDetails, purchases);

                        purchaseParam = GooglePlayPurchaseParam(
                            productDetails: productDetails,
                            applicationUserName: null,
                            changeSubscriptionParam: (oldSubscription != null)
                                ? ChangeSubscriptionParam(
                                    oldPurchaseDetails: oldSubscription,
                                    prorationMode: ProrationMode
                                        .immediateWithTimeProration,
                                  )
                                : null);
                      } else {
                        purchaseParam = PurchaseParam(
                          productDetails: productDetails,
                          applicationUserName: null,
                        );
                      }

                      if (productDetails.id == _kConsumableId) {
                        _inAppPurchase.buyConsumable(
                            purchaseParam: purchaseParam,
                            autoConsume: _kAutoConsume || Platform.isIOS);
                      } else {
                        _inAppPurchase.buyNonConsumable(
                            purchaseParam: purchaseParam);
                      }
                    },
                  ));
      },
    ));

    return Card(
        child:
            Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...'))));
    }
    if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
      return Card();
    }
    final ListTile consumableHeader =
        ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
        child: Column(children: <Widget>[
      consumableHeader,
      Divider(),
      GridView.count(
        crossAxisCount: 5,
        children: tokens,
        shrinkWrap: true,
        padding: EdgeInsets.all(16.0),
      )
    ]));
  }

  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // TextButton(
          //   child: Text('Restore purchases'),
          //   style: TextButton.styleFrom(
          //     backgroundColor: Theme.of(context).primaryColor,
          //     primary: Colors.white,
          //   ),
          //   onPressed: () => _inAppPurchase.restorePurchases(),
          // ),
        ],
      ),
    );
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> updateWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: '$url/users/applepaymentsucessfull',
      body: {
        'id': userId,
        'payment': finalPrice,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // print(_data);
    if (_status) {
      // data loaded
      // print(_data);
      if (_data['message'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WalletPage(),
          ),
        );
      }
    } else {
      print('Something went wrong.');
    }
  }

  goback() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> _openPaymentDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(msg),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                // Text('Please Connect to internet'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => {
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                goback()
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      print(purchaseDetails.verificationData);
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
      updateWallet();
    } else {
      print(purchaseDetails.verificationData);
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  // Future<void> confirmPriceChange(BuildContext context) async {
  //   if (Platform.isAndroid) {
  //     final InAppPurchaseAndroidPlatformAddition androidAddition =
  //         _inAppPurchase
  //             .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
  //     var priceChangeConfirmationResult =
  //         await androidAddition.launchPriceChangeConfirmationFlow(
  //       sku: 'purchaseId',
  //     );
  //     if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Price change accepted'),
  //       ));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text(
  //           priceChangeConfirmationResult.debugMessage ??
  //               "Price change failed with code ${priceChangeConfirmationResult.responseCode}",
  //         ),
  //       ));
  //     }
  //   }
  //   if (Platform.isIOS) {
  //     var iapStoreKitPlatformAddition = _inAppPurchase
  //         .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  //     await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
  //   }
  // }
  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Price change flow is not supported in the current in_app_purchase package version.',
        ),
      ));
      return;
    }
    if (Platform.isIOS) {
      final iapStoreKitPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == _kSilverSubscriptionId &&
        purchases[_kGoldSubscriptionId] != null) {
      oldSubscription =
          purchases[_kGoldSubscriptionId] as GooglePlayPurchaseDetails;
    } else if (productDetails.id == _kGoldSubscriptionId &&
        purchases[_kSilverSubscriptionId] != null) {
      oldSubscription =
          purchases[_kSilverSubscriptionId] as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
