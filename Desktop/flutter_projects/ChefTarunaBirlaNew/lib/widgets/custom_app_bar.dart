import 'package:chef_taruna_birla/pages/cart/whislist_page.dart';
import 'package:chef_taruna_birla/pages/notifications/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../pages/cart/cart_page.dart';
import '../viewmodels/main_container_viewmodel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.preferredSize,
    required this.bottom,
    required this.onshare,
  }) : super(key: key);

  @override
  final Size preferredSize;
  final PreferredSizeWidget bottom;
  final void Function() onshare;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        'assets/images/black_logo.png',
        width: 100.0,
      ),
      centerTitle: false,
      backgroundColor: Palette.appBarColor,
      elevation: 5.0,
      shadowColor: Palette.shadowColor.withOpacity(1.0),
      automaticallyImplyLeading: false,
      actions: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhislistPage(),
                  ),
                );
              },
              icon: Icon(
                MdiIcons.heartOutline,
                color: Palette.appBarIconsColor,
              ),
            ),
            Positioned(
              top: 20,
              right: 10,
              child: context.watch<MainContainerViewModel>().whislist.isNotEmpty
                  ? Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(50.0)),
                    )
                  : const Center(),
            )
          ],
        ),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(),
                  ),
                );
              },
              icon: Icon(
                MdiIcons.shoppingOutline,
                color: Palette.appBarIconsColor,
              ),
            ),
            Positioned(
              top: 20,
              right: 10,
              child: context.watch<MainContainerViewModel>().cart.isNotEmpty
                  ? Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(50.0)),
                    )
                  : const Center(),
            )
          ],
        ),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(),
                  ),
                );
              },
              icon: Icon(
                MdiIcons.bellOutline,
                color: Palette.appBarIconsColor,
              ),
            ),
            Positioned(
              top: 20,
              right: 10,
              child:
                  context.watch<MainContainerViewModel>().notificationCount > 0
                      ? Container(
                          height: 10.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(50.0)),
                        )
                      : const Center(),
            )
          ],
        ),
        IconButton(
          onPressed: () {
            // _saveFilter();
            // _onShare(context);
            onshare();
          },
          icon: Icon(
            MdiIcons.shareVariant,
            color: Palette.appBarIconsColor,
          ),
        ),
      ],
    );
  }
}
