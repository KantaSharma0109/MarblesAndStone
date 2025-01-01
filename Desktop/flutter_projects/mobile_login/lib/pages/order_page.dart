import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:mobile_login/add_campaign_page/city_list.dart';
import 'dart:convert';

import 'package:mobile_login/pages/campaign_history_page.dart';
import 'package:mobile_login/pages/navbar.dart';

class OrderPage extends StatefulWidget {
  final String? userId;

  const OrderPage({super.key, required this.userId});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  List<dynamic> quotations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuotations();
  }

  Future<void> fetchQuotations() async {
    final response = await http.get(
      Uri.parse(
          'https://snpublicity.com/api/fetch_order_data.php?userId=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        quotations = json.decode(response.body);
        isLoading = false;
        updateCustomerAccounts(); // Update customer accounts when data is fetched
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load quotations');
    }
  }

  Map<String, double> calculateTotalAmounts() {
    Map<String, double> totalAmounts = {};

    for (var quotation in quotations) {
      String campaignId = quotation['campaign_id'].toString();
      double total_amount =
          double.tryParse(quotation['total_amount'].toString()) ?? 0.0;
      totalAmounts[campaignId] =
          (totalAmounts[campaignId] ?? 0.0) + total_amount;
    }

    return totalAmounts;
  }

  Future<void> updateCustomerAccounts() async {
    Map<String, double> totalAmounts = calculateTotalAmounts();
    for (var entry in totalAmounts.entries) {
      await http.post(
        Uri.parse('https://snpublicity.com/api/update_customer_account.php'),
        body: {
          'userId': widget.userId!,
          'campaignId': entry.key,
          'totalAmount': entry.value.toString(),
        },
      );
    }
  }

  // void handlePayAction(String campaignId) {
  //   double totalAmount = calculateTotalAmounts()[campaignId] ?? 0.0;
  //   // Navigate to payment page with the campaign ID
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PaymentPage(
  //         userId: widget.userId!,
  //         campaignId: campaignId,
  //         totalAmount: totalAmount,
  //         imageUrl: '',
  //       ),
  //     ),
  //   );
  // }
  void handlePayAction(String campaignId) {
    double totalAmount = calculateTotalAmounts()[campaignId] ?? 0.0;
    // Navigate to NavbarPage with PaymentPage selected and passing parameters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavbarPage(
          userId: widget.userId,
          initialIndex: 2, // Open PaymentPage
          campaignId: campaignId,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Your Orders'),
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quotations.isEmpty
              ? _buildEmptyState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: quotations.length,
                        itemBuilder: (context, index) {
                          final quotation = quotations[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            color: Colors.white,
                            child: ListTile(
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
                                  _buildItemRow(
                                      'End Date', quotation['end_date']),
                                  _buildItemRow(
                                      'Price', quotation['total_amount']),
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     handlePayAction(
                                  //         quotation['campaign_id'].toString());
                                  //   },
                                  //   child: const Text('Pay'),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(thickness: 2),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'Total Amount:',
                    //         style: TextStyle(
                    //             fontSize: 18, fontWeight: FontWeight.bold),
                    //       ),
                    //       ...calculateTotalAmounts().entries.map((entry) {
                    //         return Padding(
                    //           padding: const EdgeInsets.only(bottom: 8.0),
                    //           child: Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 'Campaign ID: ${entry.key}',
                    //                 style: const TextStyle(
                    //                     fontWeight: FontWeight.bold),
                    //               ),
                    //               Text('₹${entry.value.toStringAsFixed(2)}'),
                    //               ElevatedButton(
                    //                 onPressed: () {
                    //                   handlePayAction(entry.key);
                    //                 },
                    //                 child: const Text('Pay'),
                    //               ),
                    //             ],
                    //           ),
                    //         );
                    //       }).toList(),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          ...calculateTotalAmounts().entries.map((entry) {
                            return Card(
                              color: Colors.white,
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Campaign ID:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Amount:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${entry.value.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // ElevatedButton.icon(
                                    //   onPressed: () {
                                    //     handlePayAction(entry.key);
                                    //   },
                                    //   icon: const Icon(Icons.payment),
                                    //   label: const Text('Pay'),
                                    //   style: ElevatedButton.styleFrom(
                                    //     // foregroundColor: Colors.white,
                                    //     // backgroundColor: Colors.blueAccent,
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(8),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const CityListPage(),
                            //     ),
                            //   );
                            // },
                            MaterialPageRoute(
                              builder: (context) => NavbarPage(
                                userId: widget.userId,
                                initialIndex: 1, // Directly open CityListPage
                              ),
                            ),
                          );
                        },
                        child: const Text('Book New Campaign'),
                      ),
                    ),
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

  Widget _buildEmptyState() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("You don't have any active campaigns"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CampaignHistoryPage(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text(
                    "Go to your previous campaign history",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                //     MaterialPageRoute(
                //       builder: (context) => const CityListPage(),
                //     ),
                //   );
                // },
                MaterialPageRoute(
                  builder: (context) => NavbarPage(
                    userId: widget.userId,
                    initialIndex: 1, // Directly open CityListPage
                  ),
                ),
              );
            },
            child: const Text('Book New Campaign'),
          ),
        ),
      ],
    );
  }
}
