import 'package:flutter/material.dart';
import 'package:mobile_login/add_campaign_page/campaign_detail.dart';

class FlexSelectionPage extends StatefulWidget {
  final int categoryId;

  final String? userId;
  final int? locationId;

  const FlexSelectionPage({
    super.key,
    required this.categoryId,
    required this.userId,
    this.locationId,
  });

  @override
  // ignore: no_logic_in_create_state
  FlexSelectionPageState createState() => FlexSelectionPageState(
        userId: userId,
        categoryId: categoryId,
        locationId: locationId,
      );
}

class FlexSelectionPageState extends State<FlexSelectionPage> {
  bool? _flexSelected;
  final String? userId;
  final int? categoryId;
  final int? locationId;

  FlexSelectionPageState({this.userId, this.categoryId, this.locationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Flex'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Do you want to choose a flex?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _flexSelected = true;
                });
              },
              child: const Text('Yes'),
            ),
            if (_flexSelected == null) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _navigateToQoutePage(context, false, null);
                },
                child: const Text('No'),
              ),
            ],
            if (_flexSelected == true) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _navigateToQoutePage(context, true, "normal");
                },
                child: const Text('Normal Flex'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _navigateToQoutePage(context, true, "black");
                },
                child: const Text('Black Flex'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToQoutePage(
      BuildContext context, bool flexSelected, String? flexType) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailPage(
          categoryId: widget.categoryId,

          userId: widget.userId,
          // flexSelected: flexSelected,
          // flexType: flexType,
        ),
      ),
    );
  }
}
