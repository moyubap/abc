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
    '서울역', '강남역', '김포공항역', '작전역', '홍대입구역',
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
    setState(() => isManualInput = true);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주요 장소 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: locationList.map((loc) => ActionChip(
                label: Text(loc),
                onPressed: () => _selectLocation(loc),
              )).toList(),
            ),
            const SizedBox(height: 24),
            if (!isManualInput) ...[
              ElevatedButton.icon(
                onPressed: _enableManualInput,
                icon: const Icon(Icons.edit_location_alt),
                label: const Text('직접 입력하기'),
              ),
            ] else ...[
              const Text(
                '직접 위치 입력',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: manualLocationController,
                decoration: const InputDecoration(
                  hintText: '장소를 입력하세요 (예: 건대입구역)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submitManualInput,
                  child: const Text('선택 완료'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
