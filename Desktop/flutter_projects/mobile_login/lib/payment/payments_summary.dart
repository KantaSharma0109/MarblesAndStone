// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:mobile_login/payment/receipts_popup.dart';

// class PaymentsSummaryPage extends StatefulWidget {
//   final String userId;

//   const PaymentsSummaryPage({super.key, required this.userId});

//   @override
//   _PaymentsSummaryPageState createState() => _PaymentsSummaryPageState();
// }

// class _PaymentsSummaryPageState extends State<PaymentsSummaryPage> {
//   List<dynamic> _accounts = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchPaymentsSummary();
//   }

//   Future<void> _fetchPaymentsSummary() async {
//     final response = await http.get(Uri.parse(
//         'http://192.168.29.203:8080/mobilelogin_api/get_payments_summary.php?userId=${widget.userId}'));

//     if (response.statusCode == 200) {
//       setState(() {
//         _accounts = json.decode(response.body);
//       });
//     } else {
//       // Handle the error
//     }
//   }

//   void _showReceiptsPopup(String campaignId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return ReceiptsPopup(campaignId: campaignId);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payments History'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       'Campaign\nID',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                     ),
//                   ),
//                   Expanded(
//                       flex: 2,
//                       child: Text(
//                         'Total\nAmount',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 14),
//                       )),
//                   Expanded(
//                       flex: 2,
//                       child: Text(
//                         'Received Amount',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 14),
//                       )),
//                 ],
//               ),
//               const Divider(),
//               ..._accounts.map((account) {
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 3.0),
//                   color: Colors.white,
//                   elevation: 4.0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 account['campaign_id'].toString(),
//                                 style: const TextStyle(fontSize: 15),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 account['total_amount'].toString(),
//                                 style: const TextStyle(fontSize: 15),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 account['received_amount'].toString(),
//                                 style: const TextStyle(fontSize: 15),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Align(
//                           alignment: Alignment.center,
//                           child: ElevatedButton(
//                             onPressed: () => _showReceiptsPopup(
//                                 account['campaign_id'].toString()),
//                             child: const Text('See All Receipts'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_login/payment/receipts_popup.dart';

class PaymentsSummaryPage extends StatefulWidget {
  final String? userId;

  const PaymentsSummaryPage({super.key, required this.userId});

  @override
  _PaymentsSummaryPageState createState() => _PaymentsSummaryPageState();
}

class _PaymentsSummaryPageState extends State<PaymentsSummaryPage> {
  List<dynamic> _accounts = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentsSummary();
  }

  Future<void> _fetchPaymentsSummary() async {
    final response = await http.get(Uri.parse(
        'https://snpublicity.com/api/get_payments_summary.php?userId=${widget.userId}'));

    if (response.statusCode == 200) {
      List<dynamic> tempAccounts = json.decode(response.body);

      // Use a set to store unique campaign IDs
      Set<String> uniqueCampaignIds = Set();

      // Filter out duplicate campaign IDs
      tempAccounts.forEach((account) {
        String campaignId = account['campaign_id'].toString();
        if (!uniqueCampaignIds.contains(campaignId)) {
          _accounts.add(account);
          uniqueCampaignIds.add(campaignId);
        }
      });

      setState(() {
        // Set _accounts to a list of unique accounts
        _accounts = _accounts.toList();
      });
    } else {
      // Handle the error
    }
  }

  void _showReceiptsPopup(String campaignId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReceiptsPopup(campaignId: campaignId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments History'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Campaign\nID',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Text(
                        'Total\nAmount',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                  Expanded(
                      flex: 2,
                      child: Text(
                        'Received Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                ],
              ),
              const Divider(),
              ..._accounts.map((account) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 3.0),
                  color: Colors.white,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                account['campaign_id'].toString(),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                account['total_amount'].toString(),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                account['received_amount'].toString(),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () => _showReceiptsPopup(
                                account['campaign_id'].toString()),
                            child: const Text('See All Receipts'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
