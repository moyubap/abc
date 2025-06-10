import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  bool isManualInput = false;
  final TextEditingController manualLocationController = TextEditingController();

  final List<String> locationList = [
    '서울역',
    '강남역',
    '김포공항역',
    '작전역',
    '홍대입구역'
  ];

  @override
  void dispose() {
    manualLocationController.dispose();
    super.dispose();
  }

  void _selectLocation(String location) {
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
    final geo = const GeoPoint(37.5665, 126.9780); // 기본 서울 좌표

    Navigator.pop(context, {
      'placeName': location,
      'locationUrl': url,
      'geoPoint': geo,
    });
  }

  void _enableManualInput() {
    setState(() {
      isManualInput = true;
    });
  }

  void _submitManualInput() {
    final input = manualLocationController.text.trim();
    if (input.isNotEmpty) {
      _selectLocation(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 선택'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...locationList.map(
                (loc) => ListTile(
              title: Text(loc),
              onTap: () => _selectLocation(loc),
            ),
          ),
          ListTile(
            title: const Text('직접입력'),
            trailing: const Icon(Icons.edit),
            onTap: _enableManualInput,
          ),
          if (isManualInput) ...[
            const SizedBox(height: 12),
            TextField(
              controller: manualLocationController,
              decoration: const InputDecoration(
                labelText: '직접 입력할 위치',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitManualInput,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              child: const Text('위치 선택'),
            ),
          ],
        ],
      ),
    );
  }
}
