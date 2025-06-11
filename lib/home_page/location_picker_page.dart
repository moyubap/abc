import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _pickedLatLng;
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> searchResults = [];


  Future<void> _onSearchChanged(String keyword) async {
    if (keyword.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword');
    final response = await http.get(
      url,
      headers: {'Authorization': 'KakaoAK a6050142a15e2e2ffc660c458f1eb4ff'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        searchResults = (data['documents'] as List)
            .map((e) => {
          'name': e['place_name'],
          'lat': double.parse(e['y']),
          'lng': double.parse(e['x']),
          'address': e['road_address_name'] ?? e['address_name'],
        })
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위치 선택')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "장소명 또는 주소로 검색",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (searchResults.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, idx) {
                  final res = searchResults[idx];
                  return ListTile(
                    title: Text(res['name']),
                    subtitle: Text(res['address']),
                    onTap: () {
                      setState(() {
                        _pickedLatLng = LatLng(res['lat'], res['lng']);
                        _placeNameController.text = res['name'];
                        searchResults = [];
                        _searchController.text = res['name'];
                      });
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(_pickedLatLng!),
                      );
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(35.1796, 129.0756), // 부산 중심 좌표
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _pickedLatLng == null
                  ? {}
                  : {
                Marker(
                  markerId: const MarkerId('picked'),
                  position: _pickedLatLng!,
                  draggable: true,
                  onDragEnd: (newPos) {
                    setState(() => _pickedLatLng = newPos);
                  },
                ),
              },
              onTap: (latLng) {
                setState(() {
                  _pickedLatLng = latLng;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                TextField(
                  controller: _placeNameController,
                  decoration: const InputDecoration(
                    labelText: '장소명 입력 (예: 스타벅스 서면점)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (_pickedLatLng != null)
                  Text(
                    '선택한 좌표: ${_pickedLatLng!.latitude}, ${_pickedLatLng!.longitude}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('이 위치로 선택'),
                  onPressed: (_pickedLatLng != null &&
                      _placeNameController.text.isNotEmpty)
                      ? () {
                    Navigator.pop(context, {
                      'name': _placeNameController.text,
                      'lat': _pickedLatLng!.latitude,
                      'lng': _pickedLatLng!.longitude,
                      'url':
                      'https://www.google.com/maps/search/?api=1&query=${_pickedLatLng!.latitude},${_pickedLatLng!.longitude}',
                    });
                  }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
