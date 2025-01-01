import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationDetailPage extends StatefulWidget {
  final int locationId;
  final String? userId;

  const LocationDetailPage(
      {super.key,
      required this.locationId,
      this.userId,
      required String imageUrl});

  @override
  LocationDetailPageState createState() =>
      // ignore: no_logic_in_create_state
      LocationDetailPageState(userId: userId);
}

class LocationDetailPageState extends State<LocationDetailPage> {
  final String? userId;
  LocationDetailPageState({this.userId});
  Map<String, dynamic>? _detail;
  bool _isLoading = true;
  bool _hasError = false;
  bool _noDetails = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final response = await http.get(Uri.parse(
        "https://snpublicity.com/api/details.php?location_id=${widget.locationId}"));

    if (response.statusCode == 200) {
      final List<dynamic> details = json.decode(response.body);
      if (details.isNotEmpty) {
        setState(() {
          _detail = details[0];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _noDetails = true;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      throw Exception('Failed to load details');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_hasError) {
      return const Dialog(
        child:
            Center(child: Text("An error occurred. Please try again later.")),
      );
    } else if (_noDetails) {
      return Dialog(
        //   content: const Text("This location does not have more details."),
        //   actions: [
        //     TextButton(
        //       onPressed: () {
        //         Navigator.pop(context); // Close the alert dialog
        //         // Navigator.pop(context); // Close the LocationDetailPage
        //       },
        //       child: const Text("Close"),
        //     ),
        //   ],
        // );
        child: Stack(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "This location does not have more details.",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Dialog(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildDetailRow("Country", _detail?['country']),
                    _buildDetailRow("State", _detail?['state']),
                    _buildDetailRow("Height", _detail?['height']),
                    _buildDetailRow("Width", _detail?['width']),
                    _buildDetailRow("Area", _detail?['area']),
                    _buildDetailRow("Traffic From", _detail?['traffic_from']),
                    _buildDetailRow("Traffic To", _detail?['traffic_to']),
                    // const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
