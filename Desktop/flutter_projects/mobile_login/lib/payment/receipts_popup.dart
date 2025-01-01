import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceiptsPopup extends StatelessWidget {
  final String campaignId;

  const ReceiptsPopup({super.key, required this.campaignId});

  Future<List<dynamic>> _fetchReceipts() async {
    final response = await http.get(Uri.parse(
        'https://snpublicity.com/api/get_receipts.php?campaignId=$campaignId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Handle the error
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: Text('Receipts for Campaign ID: $campaignId'),
      title: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 15, // Change the font size here
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        child: Text('All Receipts Of Campaign ID: $campaignId'),
      ),
      content: FutureBuilder<List<dynamic>>(
        future: _fetchReceipts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      // Expanded(child: Text('Campaign ID')),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Amount',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Transaction Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...snapshot.data!.map((receipt) {
                    return Row(
                      children: [
                        // Expanded(
                        // child: Text(receipt['campaign_id'].toString())),
                        Expanded(child: Text(receipt['amount'].toString())),
                        Expanded(
                            child:
                                Text(receipt['transaction_date'].toString())),
                      ],
                    );
                  }),
                ],
              ),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
