import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'post_item.dart';
import 'notification_page.dart';
import 'write_page.dart';
import '../databaseSvc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  final locations = [
    '위치',
    '전체 게시글',
    '내 주변 게시글',
  ];
  final menus = [
    '메뉴',
    '한식', '일식', '중식', '양식', '분식', '디저트', '패스트푸드',
  ];

  String selectedLocation = '위치';
  String selectedMenu = '메뉴';

  LatLng? _myLatLng;
  bool _isLoadingLocation = false;
  String? _locationError;

  final double _searchRadius = 5.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const R = 6371;
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLon = _toRadians(b.longitude - a.longitude);
    final aVal = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(a.latitude)) * cos(_toRadians(b.latitude)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * asin(sqrt(aVal));
    return R * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  Future<void> _fetchMyLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = '위치 서비스가 꺼져있습니다.';
        _isLoadingLocation = false;
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = '위치 권한이 거부되었습니다.';
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = '위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.';
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _myLatLng = LatLng(pos.latitude, pos.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = '위치를 가져오는데 실패했습니다: $e';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Row(
          children: [
            Icon(Icons.rice_bowl, color: Colors.white),
            SizedBox(width: 8),
            Text('모여밥',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요...🍚',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedLocation,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: '위치'),
                      items: locations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) async {
                        setState(() => selectedLocation = v ?? '위치');
                        if (selectedLocation == '내 주변 게시글') {
                          await _fetchMyLocation();
                        } else {
                          setState(() {
                            _myLatLng = null;
                            _locationError = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMenu,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: '메뉴'),
                      items: menus.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => selectedMenu = v ?? '메뉴'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<RecruitPost>>(
              stream: RecruitPostDBS.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoadingLocation) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_locationError != null && selectedLocation == '내 주변 게시글') {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _locationError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('게시글이 없습니다.'));
                }

                final posts = snapshot.data!;
                final query = _searchController.text.trim().toLowerCase();

                final filtered = posts.where((post) {
                  final matchesSearch = query.isEmpty ||
                      post.title.toLowerCase().contains(query) ||
                      post.content.toLowerCase().contains(query) ||
                      post.placeName.toLowerCase().contains(query) ||
                      post.foodType.toLowerCase().contains(query);

                  final matchesMenu = selectedMenu == '메뉴' || post.foodType == selectedMenu;

                  final matchesLocation = selectedLocation == '위치' || selectedLocation == '전체 게시글'
                      || (selectedLocation == '내 주변 게시글' && _myLatLng != null &&
                          _calculateDistance(_myLatLng!, LatLng(post.location.latitude, post.location.longitude)) <= _searchRadius)
                      || post.placeName.contains(selectedLocation);

                  return matchesSearch && matchesMenu && matchesLocation;
                }).toList();

                if (selectedLocation == '내 주변 게시글' && _myLatLng != null) {
                  filtered.sort((a, b) {
                    final distA = _calculateDistance(_myLatLng!, LatLng(a.location.latitude, a.location.longitude));
                    final distB = _calculateDistance(_myLatLng!, LatLng(b.location.latitude, b.location.longitude));
                    return distA.compareTo(distB);
                  });
                }

                return filtered.isEmpty
                    ? const Center(child: Text('검색 결과가 없습니다.'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => PostItem(filtered[i]),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WritePage()),
        ),
      ),
    );
  }
}