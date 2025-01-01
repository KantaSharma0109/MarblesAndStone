import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:mobile_login/add_campaign_page/location_list_page.dart';
import 'dart:convert';
import 'package:mobile_login/pages/customer_page.dart';
import 'package:mobile_login/home_page_ui/home_slider.dart';
import 'package:mobile_login/pages/navbar.dart'; // Import CityListPage

class HomePage extends StatefulWidget {
  final String? userId;
  final String? userName;

  const HomePage({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _featuredLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedLocations();
  }

  Future<void> _fetchFeaturedLocations() async {
    final response = await http
        .get(Uri.parse("https://snpublicity.com/api/featured_locations.php"));

    if (response.statusCode == 200) {
      final List<dynamic> locations = json.decode(response.body);
      setState(() {
        _featuredLocations = locations;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load featured locations');
    }
  }

  Widget _buildLocationBox(
    BuildContext context,
    String title,
    String subtitle,
    String locationName,
    String imagePath,
    String cityId,
    String categoryId,
    String locationId,
    String categoryName,
  ) {
    String imageUrl =
        'https://snpublicity.com/admin/uploads/locations/$imagePath';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          // MaterialPageRoute(
          //   builder: (context) => CityListPage(userId: widget.userId),
          // ),
          MaterialPageRoute(
            builder: (context) => NavbarPage(
              userId: widget.userId,
              initialIndex: 1,
            ),
          ),

          // MaterialPageRoute(
          //   builder: (context) => LocationListPage(
          //     categoryId: int.parse(categoryId),
          //     categoryName: categoryName,
          //     userId: widget.userId,
          //   ),
          // ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          locationName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        // const SizedBox(height: 5),
                        // Text(
                        //   'Category: ${categoryName.isNotEmpty ? categoryName : 'N/A'}',
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.grey,
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        //   maxLines: 1,
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   title: Text(
      //     'Welcome, ${widget.userName ?? "No user Name"}',
      //     style: const TextStyle(fontSize: 18),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSlider(),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: GestureDetector(
                    onTap: () {
                      int initialTabIndex = index == 0 ? 0 : 1;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerPage(
                              userId: widget.userId,
                              initialTabIndex: initialTabIndex),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Text(
                                index == 0
                                    ? 'Check Your Orders'
                                    : 'Check Your Quotations',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18.0,
              ),
              child: Text(
                'Choose Your City',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _featuredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _featuredLocations[index];
                      return _buildLocationBox(
                        context,
                        location['location_name'] ?? '',
                        location['city_name'] ?? '',
                        location['location_name'] ?? '',
                        location['img'] ?? '',
                        location['city_id'], // Pass city ID
                        location['category_id'],
                        location['id'],
                        location['categoryname'] ?? '',
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
