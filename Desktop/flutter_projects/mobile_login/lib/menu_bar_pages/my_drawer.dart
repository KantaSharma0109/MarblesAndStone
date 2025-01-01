import 'package:flutter/material.dart';
import 'package:mobile_login/controllers/auth_service.dart';
import 'package:mobile_login/menu_bar_pages/profile_page.dart';
import 'package:mobile_login/pages/campaign_history_page.dart';
// import 'package:mobile_login/pages/customer_page.dart';
import 'package:mobile_login/pages/login_page.dart';
import 'package:mobile_login/payment/payments_summary.dart';
import 'package:mobile_login/pages/help_feedback_page.dart'; // Adjust the import path if necessary
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  final String? userId;
  final String? userName;

  const MyDrawer({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                  // color: Colors.white,
                  ),
              accountName: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Text(
                    userName ?? 'User Name',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              currentAccountPicture: Container(
                width: 120, // Adjust width as needed
                height: 120, // Adjust height as needed
                decoration: BoxDecoration(
                  color: Colors.white, // Background color of the container
                  borderRadius: BorderRadius.circular(60.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5), // Shadow color
                      spreadRadius: 2, // How much the shadow spreads
                      blurRadius: 5, // How blurred the shadow is
                      offset: const Offset(0, 3), // Position of the shadow
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(60.0), // Rounded corners
                    child: Image.asset(
                      'assets/SNPublicity.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              accountEmail: null,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: userId),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.article),
            //   title: const Text('Your Orders'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CustomerPage(
            //           userId: userId,
            //           initialTabIndex: 0, // Set to 0 for 'Order'
            //         ),
            //       ),
            //     );
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.request_quote),
            //   title: const Text('Your Quotations'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CustomerPage(
            //           userId: userId,
            //           initialTabIndex: 1, // Set to 1 for 'Quotation'
            //         ),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.payments_sharp),
              title: const Text('Payments History'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentsSummaryPage(userId: userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Purchase History'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampaignHistoryPage(userId: userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.live_help_outlined),
              title: const Text('Help and Feedback'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpFeedbackPage(userId: userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.star,
                color: Color.fromARGB(255, 201, 181, 1),
              ),
              title: const Text(
                'Rate Us',
                style: TextStyle(color: Color.fromARGB(255, 201, 181, 1)),
              ),
              onTap: () async {
                const url =
                    'https://www.google.com/search?q=reting+imge&sca_esv=9267af3241730e66&sca_upv=1&sxsrf=ADLYWILd9KiQyOHAwMejpVZjMVCthr5m1A%3A1722595509723&ei=tbisZsviK6eQnesPgoT44AE&ved=0ahUKEwiLkcurkNaHAxUnSGcHHQICHhwQ4dUDCBA&uact=5&oq=reting+imge&gs_lp=Egxnd3Mtd2l6LXNlcnAiC3JldGluZyBpbWdlMgcQABiABBgNMgcQABiABBgNMgcQABiABBgNMgYQABgNGB4yCBAAGAoYDRgeMgYQABgNGB4yCBAAGA0YHhgPMggQABgFGA0YHjIIEAAYBRgNGB4yCBAAGAUYDRgeSJoVUKsFWKIScAF4AJABAJgB0gGgAcgIqgEFMC40LjK4AQPIAQD4AQGYAgagAuUHwgIKEAAYsAMY1gQYR8ICDRAAGIAEGLADGEMYigXCAhMQLhiABBiwAxhDGMcBGIoFGK8BwgIPEAAYgAQYsAMYQxiKBRgKwgILEAAYgAQYkQIYigXCAg4QABiABBiRAhixAxiKBcICBRAAGIAEwgILEC4YgAQYxwEYrwHCAgcQABiABBgKwgIIEAAYFhgKGB7CAgYQABgWGB6YAwCIBgGQBgqSBwUxLjMuMqAHxy4&sclient=gws-wiz-serp#vhid=MyjLuTYV2_4UeM&vssid=l'; // Change to your app's URL
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                AuthService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
