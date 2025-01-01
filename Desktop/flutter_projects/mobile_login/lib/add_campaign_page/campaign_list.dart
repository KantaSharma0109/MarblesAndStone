import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_login/add_campaign_page/location_list_page.dart';

class CampaignListPage extends StatelessWidget {
  final String? userId;
  final int? cityId;
  final List<Map<String, dynamic>> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onCategorySelected;

  const CampaignListPage({
    super.key,
    this.userId,
    required this.cityId,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  Future<List<dynamic>> _fetchLocations(int? categoryId) async {
    final response = await http.get(Uri.parse(
        "https://snpublicity.com/api/locations.php?category_id=$categoryId"));

    if (response.statusCode == 200) {
      final List<dynamic> locations = json.decode(response.body);
      return locations;
    } else {
      throw Exception('Failed to load locations');
    }
  }

  Widget _buildCategoryItem(
      BuildContext context, String categoryName, int categoryId) {
    return GestureDetector(
      onTap: () {
        onCategorySelected(categoryId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selectedCategoryId == categoryId
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
            color: selectedCategoryId == categoryId
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
      body: FutureBuilder(
        future: _fetchLocations(selectedCategoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || selectedCategoryId == null) {
            return const Center(child: Text('Category Not Avilable'));
          }
          return LocationListPage(
            categoryId: selectedCategoryId!,
            categoryName: categories.firstWhere(
                (cat) => cat['id'] == selectedCategoryId)['categoryname'],
            userId: userId,
          );
        },
      ),
    );
  }
}
