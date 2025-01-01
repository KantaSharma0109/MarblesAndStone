import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_medicin.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> medicineList = prefs.getStringList('medicines') ?? [];
    setState(() {
      medicines = medicineList
          .map((medicine) => jsonDecode(medicine) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi Harry!',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Text(
              '5 Medicines Left',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_alert, color: Colors.blue),
          ),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/emptybox.jpg'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Days Navigation
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Thu'),
                Text('Fri'),
                Text('Saturday, Sep 3',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                Text('Sun'),
                Text('Mon'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Medicines List
          Expanded(
            child: medicines.isEmpty
                ? _buildEmptyPlaceholder() // Show placeholder if no medicines
                : ListView.builder(
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = medicines[index];
                      return _buildMedicineCard(medicine);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            _showDeviceNotConnectedDialog(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicinesScreen()),
          );
          _loadMedicines(); // Reload medicines after adding a new one
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/emptybox.jpg',
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing Is Here, Add a Medicine',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.medical_services_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(medicine['name'] ?? 'Medicine Name'),
        subtitle: Text(
          '${medicine['type']} | ${medicine['time']} | Day ${medicine['day']}',
        ),
        trailing: Icon(
          medicine['beforeFood'] ? Icons.alarm : Icons.done,
          color: medicine['beforeFood'] ? Colors.orange : Colors.green,
        ),
      ),
    );
  }

  void _showDeviceNotConnectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Device Not Connected'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please connect your device to continue.'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddMedicinesScreen()),
                      );
                    },
                    icon: const Icon(Icons.bluetooth,
                        size: 40, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddMedicinesScreen()),
                      );
                    },
                    icon: const Icon(Icons.wifi, size: 40, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
