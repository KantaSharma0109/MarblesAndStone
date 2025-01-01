import 'package:flutter/material.dart';

class CustomDrawerScaffold extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final List<BottomNavigationBarItem> items;

  const CustomDrawerScaffold({
    super.key,
    required this.drawer,
    required this.body,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
  });

  @override
  _CustomDrawerScaffoldState createState() => _CustomDrawerScaffoldState();
}

class _CustomDrawerScaffoldState extends State<CustomDrawerScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.drawer,
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: widget.items,
        currentIndex: widget.selectedIndex,
        // selectedItemColor: const Color.fromARGB(255, 50, 69, 118),
        onTap: widget.onItemTapped,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2.0,
        shadowColor: Colors.white,
        // backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            // color: Colors.grey,
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            size: 45.0,
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
    );
  }
}
