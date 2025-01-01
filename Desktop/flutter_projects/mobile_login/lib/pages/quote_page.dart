import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuotePage extends StatefulWidget {
  final String? userId;

  const QuotePage({super.key, this.userId});

  @override
  QuotePageState createState() => QuotePageState();
}

class QuotePageState extends State<QuotePage> {
  String? userId;
  List<dynamic> quotations = [];
  bool isLoading = true;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchQuotations();
  }

  Future<void> fetchQuotations() async {
    final response = await http.get(
      Uri.parse(
          'https://snpublicity.com/api/fetch_quatation_data.php?userId=$userId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        quotations = json.decode(response.body);
        calculateTotalPrice();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load quotations');
    }
  }

  void calculateTotalPrice() {
    double total = 0.0;
    for (var quotation in quotations) {
      total += double.tryParse(quotation['total_amount'].toString()) ?? 0.0;
    }
    setState(() {
      totalPrice = total;
    });
  }

  Future<void> updateQuotationStatus(int quotationId, String status) async {
    final response = await http.post(
      Uri.parse('https://snpublicity.com/api/update_quotation_status.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'quotationId': quotationId.toString(),
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          quotations = quotations.map((quotation) {
            if (quotation['id'] == quotationId) {
              quotation['status'] = status;
            }
            return quotation;
          }).toList();
          calculateTotalPrice();
        });
      } else {
        print('Failed to update status: ${result['error']}');
      }
    } else {
      throw Exception('Failed to update status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: quotations.length,
                    itemBuilder: (context, index) {
                      final quotation = quotations[index];
                      return Card(
                        elevation: 4, // Add elevation for shadow
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),

                        color: Colors.white, // Add margin for spacing
                        child: ListTile(
                          // title: const Text('Quotation'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildItemRow('Campaign ID',
                                  quotation['campaign_id'].toString()),
                              _buildItemRow(
                                  'Category', quotation['categoryname']),
                              _buildItemRow(
                                  'Location', quotation['location_name']),
                              _buildItemRow(
                                  'Start Date', quotation['start_date']),
                              _buildItemRow('End Date', quotation['end_date']),
                              _buildItemRow('Price', quotation['total_amount']),
                              if (quotation['status'] != 'approved' &&
                                  quotation['status'] != 'rejected')
                                ButtonBar(
                                  children: [
                                    MaterialButton(
                                      onPressed: () {
                                        updateQuotationStatus(
                                            quotation['id'], 'approved');
                                      },
                                      textColor: Colors.green,
                                      child: const Text('Approve'),
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        updateQuotationStatus(
                                            quotation['id'], 'rejected');
                                      },
                                      textColor: Colors.red,
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(
                  thickness: 2,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 18.0, vertical: 8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       const Text(
                //         'Total Amount:',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       Text(
                //         '₹${totalPrice.toStringAsFixed(2)}',
                //         style: const TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 8.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              // Icon(
                              //   Icons.attach_money,
                              //   color: Color.fromARGB(255, 25, 61, 223),
                              // ),
                              SizedBox(width: 8),
                              Text(
                                'Total Amount:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildItemRow(String label, String value) {
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
