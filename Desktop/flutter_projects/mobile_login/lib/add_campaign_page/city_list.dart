import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_login/add_campaign_page/campaign_list.dart';

class CityListPage extends StatefulWidget {
  final String? userId;

  const CityListPage({super.key, this.userId});

  @override
  CityListPageState createState() => CityListPageState();
}

class CityListPageState extends State<CityListPage> {
  String? userId;
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  int? _selectedCityId;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchCities();
    userId = widget.userId;
  }

  Future<void> _fetchCities() async {
    final response =
        await http.get(Uri.parse("https://snpublicity.com/api/cities.php"));
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> cities = json.decode(response.body);
      setState(() {
        _cities = cities
            .map((city) => {
                  'id': int.parse(city['id']), // Ensure id is an integer
                  'city_name': city['city_name'],
                  'city_image': city['city_img'] ?? '', // Use 'city_img' key
                })
            .toList();
        _isLoading = false;
        _cities.forEach((city) {
          print('City Name: ${city['city_name']}');
        });
      });
    } else {
      print("error");
      throw Exception('Failed to load cities');
    }
  }

  Future<void> _fetchCategories(int cityId) async {
    setState(() {
      _isLoadingCategories = true;
    });
    final response = await http.get(Uri.parse(
        "https://snpublicity.com/api/categories.php?city_id=$cityId"));

    if (response.statusCode == 200) {
      List<dynamic> categories = json.decode(response.body);
      setState(() {
        _categories = categories
            .map((category) => {
                  'id': int.parse(category['id']), // Ensure id is an integer
                  'categoryname': category['categoryname'],
                })
            .toList();
        _isLoadingCategories = false;
        // Set the first category as selected by default
        _selectedCategoryId =
            _categories.isNotEmpty ? _categories.first['id'] : null;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Widget _buildCategoryItem(
      BuildContext context, String categoryName, int categoryId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = categoryId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedCategoryId == categoryId
                  ? Colors.deepPurple
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          categoryName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedCategoryId == categoryId
                ? Colors.deepPurple
                : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedCityId != null
          ? AppBar(
              automaticallyImplyLeading: false,
              title: _selectedCityId != null && !_isLoadingCategories
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          return _buildCategoryItem(context,
                              category['categoryname'], category['id']);
                        }).toList(),
                      ),
                    )
                  : null,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedCityId == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCityId = city['id'];
                            _fetchCategories(city['id']);
                          });
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                city['city_name'] ?? 'Unknown City',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  height: 150, // Adjusted height
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Apply the border radius
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 10, // Width of the white border
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Apply the border radius to the image
                                    child: Image.network(
                                      city['city_image'] ?? '',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print('Error loading image: $error');
                                        return const Center(
                                          child: Text('Image not found'),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : CampaignListPage(
                  userId: userId,
                  cityId: _selectedCityId,
                  categories: _categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                ),
    );
  }
}
