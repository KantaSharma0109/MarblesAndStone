import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddMedicinesScreen extends StatefulWidget {
  @override
  _AddMedicinesScreenState createState() => _AddMedicinesScreenState();
}

class _AddMedicinesScreenState extends State<AddMedicinesScreen> {
  String medicineName = "";
  int compartment = 1;
  Color selectedColor = Colors.blue;
  String type = "Tablet";
  String quantity = "1";
  int totalCount = 1;
  String frequency = "Everyday";
  String timesPerDay = "One Time";
  String doseTime = "Before Food";

  Future<void> saveMedicine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> medicines = prefs.getStringList('medicines') ?? [];

    Map<String, dynamic> medicineData = {
      'medicineName': medicineName,
      'compartment': compartment,
      'color': selectedColor.value,
      'type': type,
      'quantity': quantity,
      'totalCount': totalCount,
      'frequency': frequency,
      'timesPerDay': timesPerDay,
      'doseTime': doseTime,
    };

    medicines.add(jsonEncode(medicineData));
    await prefs.setStringList('medicines', medicines);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medicines"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Search Medicine Name
            TextField(
              decoration: InputDecoration(
                labelText: "Search Medicine Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => medicineName = value,
            ),
            SizedBox(height: 16),

            // Compartment
            Text("Compartment"),
            SizedBox(height: 8),
            Row(
              children: List.generate(6, (index) {
                return GestureDetector(
                  onTap: () => setState(() => compartment = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: compartment == index + 1
                          ? Colors.blue
                          : Colors.grey[300],
                      child: Text('${index + 1}'),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),

            // Colour
            Text("Colour"),
            SizedBox(height: 8),
            Row(
              children: Colors.primaries.take(6).map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: color,
                      child: selectedColor == color
                          ? Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Type
            Text("Type"),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTypeOption("Tablet", Icons.tablet),
                _buildTypeOption("Capsule", Icons.circle_sharp),
                _buildTypeOption("Cream", Icons.rectangle),
                _buildTypeOption("Liquid", Icons.water_outlined),
              ],
            ),
            SizedBox(height: 16),

            // Quantity
            Text("Quantity"),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: "Enter Quantity",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => quantity = value,
            ),
            SizedBox(height: 16),

            // Total Count
            Text("Total Count"),
            Slider(
              value: totalCount.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: totalCount.toString(),
              onChanged: (value) => setState(() => totalCount = value.toInt()),
            ),
            SizedBox(height: 16),

            // Frequency of Days
            Text("Frequency of Days"),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: frequency,
              items: ["Everyday", "Alternate Days", "Custom"]
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => frequency = value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // How many times a Day
            Text("How many times a Day"),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: timesPerDay,
              items: ["One Time", "Two Time", "Three Time"]
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => timesPerDay = value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Dose Time
            Text("Dose Time"),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDoseTimeOption("Before Food"),
                  _buildDoseTimeOption("After Food"),
                  _buildDoseTimeOption("Before Sleep"),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Add Button
            ElevatedButton(
              onPressed: saveMedicine,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => type = label),
      child: Column(
        children: [
          Icon(icon,
              size: 40, color: type == label ? Colors.pink : Colors.grey),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildDoseTimeOption(String label) {
    return ElevatedButton(
      onPressed: () => setState(() => doseTime = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: doseTime == label ? Colors.blue : Colors.grey[300],
      ),
      child: Text(label),
    );
  }
}
