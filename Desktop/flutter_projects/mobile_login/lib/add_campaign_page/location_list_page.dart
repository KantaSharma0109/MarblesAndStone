import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_login/add_campaign_page/location_detail_page.dart';
import 'package:mobile_login/model/campaign_data.dart';
import 'package:mobile_login/model/advertising_structure.dart'; // Import the new detail page

class LocationListPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String? userId;

  const LocationListPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.userId,
  });

  @override
  LocationListPageState createState() => LocationListPageState();
}

class LocationListPageState extends State<LocationListPage> {
  CampaignData campaignData = CampaignData();
  String? userId;
  List<dynamic> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    userId = widget.userId;
  }

  // Future<void> _fetchLocations() async {
  //   final response = await http.get(Uri.parse(
  //       "http://192.168.29.203:8080/admin-panel/mobilelogin_api/locations.php?category_id=${widget.categoryId}"));

  //   if (response.statusCode == 200) {
  //     final List<dynamic> locations = json.decode(response.body);
  //     print("Fetched locations: $locations");
  //     setState(() {
  //       _locations = locations;
  //       _isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     throw Exception('Failed to load locations');
  //   }
  // }
  Future<void> _fetchLocations() async {
    final response = await http.get(Uri.parse(
        "https://snpublicity.com/api/locations.php?category_id=${widget.categoryId}"));

    if (response.statusCode == 200) {
      print("Response: ${response.body}"); // Print the response for debugging
      final List<dynamic> locations = json.decode(response.body);
      print("Parsed locations: $locations"); // Print the parsed locations
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load locations');
    }
  }

  Widget _buildLocationBox(
    BuildContext context,
    String title,
    String subtitle,
    List<String> imagePaths, // List of image paths
    int locationId,
    String cityName,
    int cityId,
    int availableStatus, // Add availableStatus parameter
    String? endDate, // Add endDate parameter
  ) {
    PageController pageController = PageController();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
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
          // Image Section with PageView
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    String imageUrl =
                        'https://snpublicity.com/admin/${imagePaths[index]}';
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              // Left button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.black, // Set the color here
                    size: 50.0,
                  ),
                  onPressed: () {
                    if (pageController.hasClients) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
              // Right button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black, // Set the color here
                    size: 50.0,
                  ),
                  onPressed: () {
                    if (pageController.hasClients) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Subtitle Section
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 30),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0.0,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              width: double.infinity,
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
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Button Section
          Row(
            children: [
              Expanded(
                flex: 6,
                child: availableStatus == 1
                    ? ElevatedButton(
                        onPressed: () {
                          bool alreadyAdded = CampaignData()
                              .selectedStructures
                              .any((element) =>
                                  element.title == title &&
                                  element.subtitle == subtitle &&
                                  element.imagePath == imagePaths[0]);

                          if (alreadyAdded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('This information is already added.'),
                              ),
                            );
                          } else {
                            setState(() {
                              CampaignData().selectedStructures.add(
                                    AdvertisingStructure(
                                      title: title,
                                      subtitle: subtitle,
                                      imagePath:
                                          imagePaths[0], // Use first image path
                                      categoryId: widget.categoryId,
                                      locationId: locationId,
                                      cityName: cityName,
                                      cityId: cityId,
                                      imageUrl:
                                          'https://snpublicity.com/admin/${imagePaths[0]}',
                                    ),
                                  );
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Campaign added to cart.'),
                              ),
                            );
                          }
                        },
                        child: const Text("Add To Campaign"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Not Available'),
                              content: Text(
                                endDate != null
                                    ? 'End Date: $endDate'
                                    : 'No end date available.',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Color for the button
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Not Available"),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => LocationDetailPage(
                        locationId: locationId,
                        userId: widget.userId,
                        imageUrl:
                            'https://snpublicity.com/admin/${imagePaths[0]}',
                      ),
                    );
                  },
                  child: const Text("View Details"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("${widget.categoryName} Locations"),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.shopping_cart),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => CampaignDetailPage(
      //               userId: userId,
      //               categoryId: widget.categoryId,
      //               locationId: null, // You can handle this accordingly
      //             ),
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _locations.length,
              // itemBuilder: (context, index) {
              //   final location = _locations[index];
              //   final locationId = int.tryParse(location['id'].toString()) ?? 0;
              //   final cityId =
              //       int.tryParse(location['city_id'].toString()) ?? 0;
              //   final availableStatus =
              //       int.tryParse(location['available_status'].toString()) ?? 0;
              //   final cityName = location['city_name'] ?? '';
              //   final endDate = location['end_date'] ?? '';
              //   final List<String> imagePaths =
              //       List<String>.from(location['img'] ?? []);

              //   return _buildLocationBox(
              //     context,
              //     widget.categoryName,
              //     location['location_name'] ?? '',
              //     // location['img'] ?? '',
              //     imagePaths,
              //     locationId,
              //     cityName,
              //     cityId,
              //     availableStatus,
              //     endDate,
              //   );
              // },
              itemBuilder: (context, index) {
                final location = _locations[index];
                final locationId = int.tryParse(location['id'].toString()) ?? 0;
                final cityId =
                    int.tryParse(location['city_id'].toString()) ?? 0;
                final availableStatus =
                    int.tryParse(location['available_status'].toString()) ?? 0;
                final cityName = location['city_name'] ?? '';
                final title = location['location_name'] ?? '';
                final endDate = location['end_date'] != null
                    ? location['end_date'].toString()
                    : null;
                final List<String> imagePaths =
                    List<String>.from(location['location_images'] ?? []);

                return _buildLocationBox(
                  context,
                  title,
                  title, // Using the same title for both title and subtitle
                  imagePaths,
                  locationId,
                  cityName,
                  cityId,
                  availableStatus,
                  endDate,
                );
              },
            ),
    );
  }
}
