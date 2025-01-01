import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class PaymentPage extends StatefulWidget {
  final String? userId;
  final String? campaignId;
  final double totalAmount;

  const PaymentPage({
    super.key,
    this.userId,
    this.campaignId,
    required this.totalAmount,
    required String imageUrl,
  });

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  File? _image;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  List<dynamic> quotations = [];
  bool showPaymentFields = false;
  String selectedCampaignId = '';

  @override
  void initState() {
    super.initState();
    fetchQuotations();
  }

  // Future<void> fetchQuotations() async {
  //   final response = await http.get(
  //     Uri.parse(
  //         'http://192.168.29.203:8080/mobilelogin_api/fetch_order_data.php?userId=${widget.userId}'),
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       quotations = json.decode(response.body);
  //       isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     throw Exception('Failed to load quotations');
  //   }
  // }

  // Map<String, double> calculateTotalAmounts() {
  //   Map<String, double> totalAmounts = {};

  //   for (var quotation in quotations) {
  //     String campaignId = quotation['campaign_id'].toString();
  //     double totalAmount =
  //         double.tryParse(quotation['total_amount'].toString()) ?? 0.0;
  //     totalAmounts[campaignId] =
  //         (totalAmounts[campaignId] ?? 0.0) + totalAmount;
  //   }

  //   return totalAmounts;
  // }
  Future<void> fetchQuotations() async {
    final response = await http.get(
      Uri.parse(
          'https://snpublicity.com/api/fetch_due_amount.php?userId=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        quotations = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load quotations');
    }
  }

  Map<String, double> calculateDueAmounts() {
    Map<String, double> dueAmounts = {};

    for (var quotation in quotations) {
      String campaignId = quotation['campaign_id'].toString();
      double dueAmount =
          double.tryParse(quotation['due_amount'].toString()) ?? 0.0;
      dueAmounts[campaignId] = (dueAmounts[campaignId] ?? 0.0) + dueAmount;
    }

    return dueAmounts;
  }

  // Future<void> fetchDueAmount(String campaignId) async {
  //   final response = await http.get(
  //     Uri.parse(
  //         'http://192.168.29.203:8080/mobilelogin_api/fetch_due_amount.php?userId=${widget.userId}&campaignId=$campaignId'),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     double dueAmount = data['due_amount']?.toDouble() ?? 0.0;
  //     _amountController.text = dueAmount.toStringAsFixed(2);
  //   } else {
  //     throw Exception('Failed to load due amount');
  //   }
  // }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      const imageUrl =
          'https://upload.wikimedia.org/wikipedia/commons/5/5b/Qrcode_wikipedia.jpg';
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/image.jpg';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Save image to gallery and trigger media scan
        final result = await ImageGallerySaver.saveFile(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['isSuccess']
                ? 'Image downloaded and saved to gallery successfully'
                : 'Failed to save image to gallery'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadReceipt() async {
    if (_image == null ||
        _amountController.text.isEmpty ||
        _referenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https:/snpublicity.com/api/upload_receipt.php'),
    );

    request.fields['userId'] = widget.userId!;
    request.fields['campaignId'] = selectedCampaignId;
    request.fields['amount'] = _amountController.text;
    request.fields['referenceId'] = _referenceController.text;
    request.files.add(
      await http.MultipartFile.fromPath('receiptImage', _image!.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt uploaded successfully')),
      );
      setState(() {
        showPaymentFields = false;
        _image = null;
        _amountController.clear();
        _referenceController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload receipt')),
      );
    }
  }

  void _showPaymentFields(String campaignId, double amount) {
    setState(() {
      showPaymentFields = true;
      selectedCampaignId = campaignId;
      // _amountController.text = amount.toStringAsFixed(2);
      _amountController.clear();
      _referenceController.clear();
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _downloadImage(context);
                        },
                        child: const Center(
                          child: Text(
                            'Get QR Code for Payment',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Due amount:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    // ...calculateTotalAmounts().entries.map((entry) {
                    ...calculateDueAmounts().entries.map((entry) {
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Campaign ID:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 12.0,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Duo Amount:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 12.0,
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
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showPaymentFields(entry.key, entry.value);
                                },
                                icon: const Icon(Icons.payment),
                                label: const Text('Pay'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    if (showPaymentFields) ...[
                      Card(
                        elevation: 5,
                        color: Colors.white,
                        shadowColor: Colors.grey.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  'Pay for Campaign ID: $selectedCampaignId',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50.0),
                                  child: TextField(
                                    controller: _amountController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      hintText: 'Enter Amount',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 12.0,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: 10), // Adjust spacing as needed
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: TextField(
                                    controller: _referenceController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      hintText: 'Enter Reference Number',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical:
                                            12.0, // Adjust vertical padding
                                        horizontal:
                                            12.0, // Adjust horizontal padding
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: 14.0), // Adjust spacing as needed
                              ElevatedButton(
                                onPressed: _pickImage,
                                child: const Text('Upload Receipt Image'),
                              ),
                              if (_image != null)
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 14.0),
                              ElevatedButton(
                                onPressed: _uploadReceipt,
                                child: const Text('Submit Receipt'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
