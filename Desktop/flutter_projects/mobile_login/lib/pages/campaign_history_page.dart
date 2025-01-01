import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CampaignHistoryPage extends StatefulWidget {
  final String? userId;

  const CampaignHistoryPage({super.key, this.userId});

  @override
  CampaignHistoryPageState createState() => CampaignHistoryPageState();
}

class CampaignHistoryPageState extends State<CampaignHistoryPage> {
  List<dynamic> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCampaignHistory();
  }

  Future<void> fetchCampaignHistory() async {
    final response = await http.get(
      Uri.parse(
          'https://snpublicity.com/api/fetch_campaign_history.php?userId=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        history = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load campaign history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaign History"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(
                  child: Text("No campaign history available."),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final campaign = history[index];
                    return Card(
                      elevation: 4,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildItem('Campaign ID',
                                campaign['campaign_id'].toString()),
                            _buildItem(
                                'Category', '${campaign['categoryname']}'),
                            _buildItem(
                                'Location', '${campaign['location_name']}'),
                            _buildItem(
                                'Start Date', '${campaign['start_date']}'),
                            _buildItem('End Date', '${campaign['end_date']}'),
                            _buildItem('Price', '${campaign['total_amount']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                // No additional styling for normal text after colon
                ),
          ),
        ),
      ],
    );
  }
}
