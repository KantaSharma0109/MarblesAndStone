import 'package:flutter/material.dart';
import 'package:mobile_login/pages/order_page.dart';
import 'package:mobile_login/pages/quote_page.dart';

class CustomerPage extends StatefulWidget {
  final String? userId;
  final int initialTabIndex;

  const CustomerPage({super.key, this.userId, required this.initialTabIndex});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    userId = widget.userId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Order"),
                  Tab(text: "Quote"),
                ],
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrderPage(userId: userId),
          QuotePage(userId: userId),
        ],
      ),
    );
  }
}
