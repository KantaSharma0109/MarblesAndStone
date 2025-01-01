import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/pages/product/each_product.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../api/api_functions.dart';
import '../../config/config.dart';
import '../../models/cart_item.dart';
import '../../utils/utility.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../../viewmodels/product_page_viewmodel.dart';
import '../../widgets/image_placeholder.dart';
import '../../widgets/product_slider_widget.dart';
import '../product/product_buy_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin {
  bool isLoadingVertical = false;
  bool isSearching = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> getProductData() async {
    Provider.of<ProductPageViewModel>(context, listen: false)
        .getProductData(context);
    // await Future.delayed(const Duration(milliseconds: 3000));
  }

  Future<void> updateWhislist(id, value) async {
    Map<String, String> params = {
      'user_id': Application.userId,
      'category': 'product',
      'id': id,
    };
    String url = value == 'add'
        ? '${Constants.finalUrl}/users/addtowhislist'
        : '${Constants.finalUrl}/users/removefromwhislist';
    Map<String, dynamic> _postResult =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);

    bool _status = _postResult['status'];
    var _data = _postResult['data'];
    // print(_data);
    if (_status) {
      if (_data['message'] == 'success') {
        if (value == 'add') {
          Utility.showSnacbar(context, 'Item successfully added to whislist!!');
        } else {
          Utility.showSnacbar(
              context, 'Item successfully removed from whislist!!');
        }
      } else if (_data['message'] == 'Auth_token_failure') {
        Utility.authErrorPopup(
            context,
            'Sorry for inconvenience. Their is some authentication problem regarding your account contact support: ' +
                Application.adminPhoneNumber);
      } else {
        Utility.showSnacbar(context, 'Some error occurred!!');
      }
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  @override
  void initState() {
    super.initState();
    //get Product Data
    getProductData();
  }

  Future _loadMoreVertical() async {
    Utility.printLog('scrolling');
    Provider.of<ProductPageViewModel>(context, listen: false)
        .getMoreProductData(context);
  }

  @override
  Widget build(BuildContext context) {
    return LazyLoadScrollView(
      isLoading: context.watch<ProductPageViewModel>().isVerticalLoading,
      onEndOfPage: () {
        if (!isSearching) {
          Provider.of<ProductPageViewModel>(context, listen: false).setOffset();
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
                        Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .setSelectedCategory(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .productCategories[0]
                                    .name);
                        Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .getSearchedProducts(value, context);
                      } else {
                        setState(() {
                          isSearching = false;
                        });
                        Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .setSelectedCategory(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .productCategories[0]
                                    .name);
                        getProductData();
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
                      hintText: "Search Products...",
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
              SizedBox(
                height:
                    Provider.of<ProductPageViewModel>(context, listen: false)
                            .appslider
                            .isNotEmpty
                        ? 15.0
                        : 0.0,
              ),
              Provider.of<ProductPageViewModel>(context, listen: false)
                      .appslider
                      .isNotEmpty
                  ? const ProductSliderWidget()
                  : const SizedBox(),
              const SizedBox(
                height: 15.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
                child: GestureDetector(
                  onTap: () {
                    Utility.openWhatsapp(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Palette.shadowColorTwo,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            width: 2.0, color: Palette.secondaryColor)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'For customise cake click here.. !!',
                              style: TextStyle(
                                color: Palette.secondaryColor,
                                fontSize: 16.0,
                                fontFamily: 'EuclidCircularA Medium',
                              ),
                            ),
                          ),
                          Icon(
                            MdiIcons.arrowRight,
                            color: Palette.secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 0.0,
              ),
              SizedBox(
                height: 70.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Provider.of<MainContainerViewModel>(context,
                          listen: false)
                      .productCategories
                      .length,
                  itemBuilder: (BuildContext context, int index) {
                    // print(selected);
                    // print(list[index]);
                    return GestureDetector(
                      onTap: () {
                        Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .setSelectedCategory(
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .productCategories[index]
                                    .name);
                        Provider.of<ProductPageViewModel>(context,
                                listen: false)
                            .getProductData(context);
                      },
                      child: Container(
                        margin: index == 0
                            ? const EdgeInsets.fromLTRB(24.0, 0.0, 20.0, 0.0)
                            : const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                        child: Chip(
                          labelPadding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 20.0),
                          label: Text(
                            Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .productCategories[index]
                                .name,
                            style: TextStyle(
                              color: Provider.of<ProductPageViewModel>(context,
                                              listen: false)
                                          .selectedCategory ==
                                      Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .productCategories[index]
                                          .name
                                  ? Colors.white
                                  : Palette.secondaryColor,
                              fontSize: 12.0,
                              fontFamily: 'EuclidCircularA Regular',
                            ),
                          ),
                          backgroundColor: Provider.of<ProductPageViewModel>(
                                          context,
                                          listen: false)
                                      .selectedCategory ==
                                  Provider.of<MainContainerViewModel>(context,
                                          listen: false)
                                      .productCategories[index]
                                      .name
                              ? Palette.secondaryColor
                              : Colors.white,
                          elevation: 10.0,
                          shadowColor: Provider.of<ProductPageViewModel>(
                                          context,
                                          listen: false)
                                      .selectedCategory ==
                                  Provider.of<MainContainerViewModel>(context,
                                          listen: false)
                                      .productCategories[index]
                                      .name
                              ? Palette.shadowColor.withOpacity(0.3)
                              : Palette.shadowColor.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 0.0,
              ),
              !context.watch<ProductPageViewModel>().isLoading
                  ? Container()
                  : Provider.of<ProductPageViewModel>(context, listen: false)
                          .productList
                          .isEmpty
                      ? const Center(
                          child: Text(
                            'No Products Present..',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 14.0,
                              fontFamily: 'EuclidCircularA Medium',
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth < 576
                                    ? 2
                                    : constraints.maxWidth < 768
                                        ? 3
                                        : constraints.maxWidth < 992
                                            ? 4
                                            : 6,
                                childAspectRatio: constraints.maxWidth < 576
                                    ? 0.72
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
                                crossAxisSpacing: 10.0,
                              ),
                              itemCount: Provider.of<ProductPageViewModel>(
                                      context,
                                      listen: false)
                                  .productList
                                  .length,
                              itemBuilder: (context, index) {
                                int counter = 0;
                                int whislistCounter = 0;
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .cart
                                    .forEach((element) {
                                  if (element.item_id ==
                                          Provider.of<ProductPageViewModel>(
                                                  context,
                                                  listen: false)
                                              .productList[index]
                                              .id &&
                                      element.item_category == 'product' &&
                                      element.cart_category == 'cart') {
                                    counter++;
                                  }
                                });
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .whislist
                                    .forEach((element) {
                                  if (element.item_id ==
                                          Provider.of<ProductPageViewModel>(
                                                  context,
                                                  listen: false)
                                              .productList[index]
                                              .id &&
                                      element.item_category == 'product' &&
                                      element.cart_category == 'whislist') {
                                    whislistCounter++;
                                  }
                                });
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EachProduct(
                                              id: Provider.of<
                                                          ProductPageViewModel>(
                                                      context,
                                                      listen: false)
                                                  .productList[index]
                                                  .id)),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(
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
                                        5.0,
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
                                        5.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Palette.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Palette.shadowColor
                                              .withOpacity(0.1),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => EachProduct(
                                                              id: Provider.of<
                                                                          ProductPageViewModel>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .productList[
                                                                      index]
                                                                  .id)),
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: Constants
                                                              .imgBackendUrl +
                                                          Provider.of<ProductPageViewModel>(
                                                                  context,
                                                                  listen: false)
                                                              .productList[
                                                                  index]
                                                              .image_path,
                                                      placeholder: (context,
                                                              url) =>
                                                          const ImagePlaceholder(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const ImagePlaceholder(),
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      Provider.of<ProductPageViewModel>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .productList[
                                                                      index]
                                                                  .name
                                                                  .length >
                                                              15
                                                          ? '${Provider.of<ProductPageViewModel>(context, listen: false).productList[index].name.substring(0, 15)}...'
                                                          : Provider.of<
                                                                      ProductPageViewModel>(
                                                                  context,
                                                                  listen: false)
                                                              .productList[
                                                                  index]
                                                              .name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        color: Palette.black,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Regular',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      'Rs ${Provider.of<ProductPageViewModel>(context, listen: false).productList[index].discount_price}',
                                                      style: const TextStyle(
                                                        color: Palette
                                                            .contrastColor,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          Provider.of<ProductPageViewModel>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .productList[
                                                                          index]
                                                                      .discount_price ==
                                                                  Provider.of<ProductPageViewModel>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .productList[
                                                                          index]
                                                                      .price
                                                              ? ''
                                                              : 'Rs ${Provider.of<ProductPageViewModel>(context, listen: false).productList[index].price}',
                                                          style:
                                                              const TextStyle(
                                                            color: Palette.grey,
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'EuclidCircularA Regular',
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10.0,
                                                        ),
                                                        Text(
                                                          Provider.of<ProductPageViewModel>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .productList[
                                                                          index]
                                                                      .discount_price ==
                                                                  Provider.of<ProductPageViewModel>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .productList[
                                                                          index]
                                                                      .price
                                                              ? ''
                                                              : '${(((int.parse(Provider.of<ProductPageViewModel>(context, listen: false).productList[index].price) - int.parse(Provider.of<ProductPageViewModel>(context, listen: false).productList[index].discount_price)) / int.parse(Provider.of<ProductPageViewModel>(context, listen: false).productList[index].price)) * 100).toString().substring(0, 4)} %',
                                                          style:
                                                              const TextStyle(
                                                            color: Palette
                                                                .discount,
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'EuclidCircularA Medium',
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
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ProductBuyPage(
                                                                price: Provider.of<
                                                                            ProductPageViewModel>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .productList[
                                                                        index]
                                                                    .discount_price,
                                                                id: Provider.of<
                                                                            ProductPageViewModel>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .productList[
                                                                        index]
                                                                    .id)),
                                                      );
                                                      // setState(() {
                                                      //   if (counter >= 1) {
                                                      //     Provider.of<MainContainerViewModel>(
                                                      //             context,
                                                      //             listen: false)
                                                      //         .cart
                                                      //         .removeWhere((element) =>
                                                      //             element.item_id ==
                                                      //                 Provider.of<ProductPageViewModel>(
                                                      //                         context,
                                                      //                         listen:
                                                      //                             false)
                                                      //                     .productList[
                                                      //                         index]
                                                      //                     .id &&
                                                      //             element.item_category ==
                                                      //                 'product' &&
                                                      //             element.cart_category ==
                                                      //                 'cart');
                                                      //     context
                                                      //         .read<
                                                      //             MainContainerViewModel>()
                                                      //         .setCart(Provider.of<
                                                      //                     MainContainerViewModel>(
                                                      //                 context,
                                                      //                 listen:
                                                      //                     false)
                                                      //             .cart);
                                                      //     counter = 0;
                                                      //     Provider.of<ProductPageViewModel>(
                                                      //             context,
                                                      //             listen: false)
                                                      //         .updateCart(
                                                      //             Provider.of<ProductPageViewModel>(
                                                      //                     context,
                                                      //                     listen:
                                                      //                         false)
                                                      //                 .productList[
                                                      //                     index]
                                                      //                 .id,
                                                      //             'remove');
                                                      //   } else {
                                                      //     var newItem =
                                                      //         CartItem(
                                                      //       cart_id: '',
                                                      //       item_id: Provider.of<
                                                      //                   ProductPageViewModel>(
                                                      //               context,
                                                      //               listen:
                                                      //                   false)
                                                      //           .productList[
                                                      //               index]
                                                      //           .id,
                                                      //       name: Provider.of<
                                                      //                   ProductPageViewModel>(
                                                      //               context,
                                                      //               listen:
                                                      //                   false)
                                                      //           .productList[
                                                      //               index]
                                                      //           .name,
                                                      //       price: Provider.of<
                                                      //                   ProductPageViewModel>(
                                                      //               context,
                                                      //               listen:
                                                      //                   false)
                                                      //           .productList[
                                                      //               index]
                                                      //           .discount_price,
                                                      //       cart_category:
                                                      //           'cart',
                                                      //       image_path: Provider.of<
                                                      //                   ProductPageViewModel>(
                                                      //               context,
                                                      //               listen:
                                                      //                   false)
                                                      //           .productList[
                                                      //               index]
                                                      //           .image_path,
                                                      //       quantity: 0,
                                                      //       item_category:
                                                      //           'product',
                                                      //     );
                                                      //     Provider.of<MainContainerViewModel>(
                                                      //             context,
                                                      //             listen: false)
                                                      //         .cart
                                                      //         .add(newItem);
                                                      //     context
                                                      //         .read<
                                                      //             MainContainerViewModel>()
                                                      //         .setCart(Provider.of<
                                                      //                     MainContainerViewModel>(
                                                      //                 context,
                                                      //                 listen:
                                                      //                     false)
                                                      //             .cart);
                                                      //     counter = 1;
                                                      //     Provider.of<ProductPageViewModel>(
                                                      //             context,
                                                      //             listen: false)
                                                      //         .updateCart(
                                                      //             Provider.of<ProductPageViewModel>(
                                                      //                     context,
                                                      //                     listen:
                                                      //                         false)
                                                      //                 .productList[
                                                      //                     index]
                                                      //                 .id,
                                                      //             'add');
                                                      //   }
                                                      // });
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Palette
                                                            .secondaryColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0)),
                                                      ),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.0,
                                                                bottom: 10.0),
                                                        child: Center(
                                                          child:
                                                              // counter >= 1
                                                              // ? const Text(
                                                              //     'Remove',
                                                              //     style:
                                                              //         TextStyle(
                                                              //       color: Palette
                                                              //           .white,
                                                              //       fontSize:
                                                              //           14.0,
                                                              //       fontFamily:
                                                              //           'EuclidCircularA Medium',
                                                              //     ),
                                                              //   )
                                                              // :
                                                              Text(
                                                            'Buy Now',
                                                            style: TextStyle(
                                                              color:
                                                                  Palette.white,
                                                              fontSize: 14.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Medium',
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
                                              Utility.printLog(
                                                  'whislist pressed');
                                              setState(() {
                                                if (whislistCounter >= 1) {
                                                  Provider.of<MainContainerViewModel>(
                                                          context,
                                                          listen: false)
                                                      .whislist
                                                      .removeWhere((element) =>
                                                          element.item_id ==
                                                              Provider.of<ProductPageViewModel>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .productList[
                                                                      index]
                                                                  .id &&
                                                          element.item_category ==
                                                              'product' &&
                                                          element.cart_category ==
                                                              'whislist');
                                                  context
                                                      .read<
                                                          MainContainerViewModel>()
                                                      .setWhislist(Provider.of<
                                                                  MainContainerViewModel>(
                                                              context,
                                                              listen: false)
                                                          .whislist);
                                                  whislistCounter = 0;
                                                  updateWhislist(
                                                      Provider.of<ProductPageViewModel>(
                                                              context,
                                                              listen: false)
                                                          .productList[index]
                                                          .id,
                                                      'remove');
                                                } else {
                                                  var newItem = CartItem(
                                                    cart_id: '',
                                                    item_id: Provider.of<
                                                                ProductPageViewModel>(
                                                            context,
                                                            listen: false)
                                                        .productList[index]
                                                        .id,
                                                    name: Provider.of<
                                                                ProductPageViewModel>(
                                                            context,
                                                            listen: false)
                                                        .productList[index]
                                                        .name,
                                                    price: int.parse(Provider
                                                            .of<ProductPageViewModel>(
                                                                context,
                                                                listen: false)
                                                        .productList[index]
                                                        .discount_price),
                                                    cart_category: 'whislist',
                                                    image_path: Provider.of<
                                                                ProductPageViewModel>(
                                                            context,
                                                            listen: false)
                                                        .productList[index]
                                                        .image_path,
                                                    quantity: 0,
                                                    item_category: 'product',
                                                  );
                                                  Provider.of<MainContainerViewModel>(
                                                          context,
                                                          listen: false)
                                                      .whislist
                                                      .add(newItem);
                                                  context
                                                      .read<
                                                          MainContainerViewModel>()
                                                      .setWhislist(Provider.of<
                                                                  MainContainerViewModel>(
                                                              context,
                                                              listen: false)
                                                          .whislist);
                                                  whislistCounter = 1;
                                                  updateWhislist(
                                                      Provider.of<ProductPageViewModel>(
                                                              context,
                                                              listen: false)
                                                          .productList[index]
                                                          .id,
                                                      'add');
                                                }
                                              });
                                            },
                                            child: Container(
                                              height: 30.0,
                                              width: 30.0,
                                              decoration: BoxDecoration(
                                                color: Palette.white,
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Palette.shadowColor
                                                        .withOpacity(0.1),
                                                    blurRadius:
                                                        5.0, // soften the shadow
                                                    spreadRadius:
                                                        0.0, //extend the shadow
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
                              },
                            );
                          },
                        ),
              !context.watch<ProductPageViewModel>().isLoading
                  ? Container()
                  : Container(
                      child: !context
                              .watch<ProductPageViewModel>()
                              .isVerticalLoading
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
}
