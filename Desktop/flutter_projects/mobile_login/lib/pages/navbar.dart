import 'package:flutter/material.dart';
import 'package:mobile_login/add_campaign_page/campaign_detail.dart';
import 'package:mobile_login/add_campaign_page/city_list.dart';
import 'package:mobile_login/pages/home_page.dart';
import 'package:mobile_login/pages/campaign_history_page.dart';
import 'package:mobile_login/pages/shared_prefs_helper.dart';
import 'package:mobile_login/payment/payment_page.dart';
import 'package:mobile_login/menu_bar_pages/my_drawer.dart';
import 'package:mobile_login/menu_bar_pages/custom_drawer_scaffold.dart'; // Import CustomDrawerScaffold

class NavbarPage extends StatefulWidget {
  final int initialIndex; // Add initialIndex parameter
  final String? userId;
  final String? campaignId; // Add campaignId
  final double totalAmount; // Add totalAmount

  const NavbarPage({
    super.key,
    required this.initialIndex,
    this.userId,
    this.campaignId,
    this.totalAmount = 0.0,
  }); // Update constructor

  @override
  NavbarPageState createState() => NavbarPageState();
}

class NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 0;
  String? _userId;
  String? _userName;
  String? _campaignId; // Add campaignId
  double _totalAmount = 0.0; // Add totalAmount

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.initialIndex; // Initialize _selectedIndex with initialIndex
    _campaignId = widget.campaignId;
    _totalAmount = widget.totalAmount;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userId = await SharedPrefsHelper.getUserId();
    String? userName = await SharedPrefsHelper.getUserName();
    setState(() {
      _userId = userId;
      _userName = userName;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // void navigateToCityList() {
  //   setState(() {
  //     _selectedIndex = 1; // Assuming 1 is the index for CityListPage
  //   });
  // }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(
          userId: _userId,
          userName: _userName,
          key: UniqueKey(),
        );
      case 1:
        return CityListPage(
          userId: _userId,
          key: UniqueKey(),
        );
      case 2:
        return PaymentPage(
          userId: _userId,
          campaignId: _campaignId,
          totalAmount: _totalAmount,
          imageUrl: '',
        );
      case 3:
        return CampaignDetailPage(
          userId: _userId,
        );
      case 4:
        return CampaignHistoryPage(userId: _userId);

      default:
        return HomePage(userId: _userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDrawerScaffold(
      drawer: MyDrawer(userId: _userId, userName: _userName),
      body: Center(
        child: _userId == null
            ? const CircularProgressIndicator()
            : _getSelectedPage(),
      ),
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_city),
          label: 'City',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Payment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
      ],
    );
  }
}
