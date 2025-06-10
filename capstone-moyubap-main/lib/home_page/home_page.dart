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

  final locations = ['위치', '전체 게시글', '내 주변 게시글'];
  final menus = ['메뉴', '한식', '일식', '중식', '양식', '분식', '디저트', '패스트푸드'];

  String selectedLocation = '위치';
  String selectedMenu = '메뉴';

  LatLng? _myLatLng;
  bool _isLoadingLocation = false;
  String? _locationError;

  final double _searchRadius = 5.0;

  double _calculateDistance(LatLng a, LatLng b) {
    const R = 6371;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(a.latitude)) * cos(_toRad(b.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * asin(sqrt(h));
  }

  double _toRad(double deg) => deg * pi / 180;

  Future<void> _fetchMyLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        _locationError = '위치 서비스가 꺼져있습니다.';
        _isLoadingLocation = false;
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = '위치 권한이 거부되었습니다.';
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _myLatLng = LatLng(position.latitude, position.longitude);
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF81D4FA),
        title: Row(
          children: [
            const Icon(Icons.rice_bowl, color: Colors.white, size: 28, shadows: [
              Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 2))
            ]),
            const SizedBox(width: 8),
            Stack(children: [
              Text('모여밥',
                  style: TextStyle(
                    fontFamily: 'UhBeeSe_hyun',
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.black45,
                  )),
              const Text('모여밥',
                  style: TextStyle(
                    fontFamily: 'UhBeeSe_hyun',
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ])
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white, size: 28, shadows: [
              Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 2))
            ]),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '검색어를 입력하세요...🍚',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: const Color(0xFFEEF9FD)),
                      child: DropdownButtonFormField<String>(
                        value: selectedLocation,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: locations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) async {
                          setState(() => selectedLocation = v ?? '위치');
                          if (selectedLocation == '내 주변 게시글') await _fetchMyLocation();
                          else setState(() => _myLatLng = null);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(canvasColor: const Color(0xFFEEF9FD)),
                      child: DropdownButtonFormField<String>(
                        value: selectedMenu,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: menus.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => selectedMenu = v ?? '메뉴'),
                      ),
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
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_locationError!, style: const TextStyle(color: Colors.red)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('게시글이 없습니다.'));
                }

                final posts = snapshot.data!;
                final query = _searchController.text.trim().toLowerCase();

                var filtered = posts.where((post) {
                  final matchQuery = query.isEmpty ||
                      post.title.toLowerCase().contains(query) ||
                      post.content.contains(query) ||
                      post.placeName.contains(query) ||
                      post.foodType.contains(query);

                  final matchMenu = selectedMenu == '메뉴' || post.foodType == selectedMenu;

                  final matchLocation = selectedLocation != '내 주변 게시글' || (_myLatLng != null &&
                      _calculateDistance(_myLatLng!,
                          LatLng(post.location.latitude, post.location.longitude)) <= _searchRadius);

                  return matchQuery && matchMenu && matchLocation;
                }).toList();

                if (selectedLocation == '내 주변 게시글' && _myLatLng != null) {
                  filtered.sort((a, b) => _calculateDistance(
                    _myLatLng!,
                    LatLng(a.location.latitude, a.location.longitude),
                  ).compareTo(_calculateDistance(
                    _myLatLng!,
                    LatLng(b.location.latitude, b.location.longitude),
                  )));
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFF81D4FA),
          child: const Icon(Icons.add, color: Colors.white, size: 28, shadows: [
            Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 2))
          ]),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WritePage()),
          ),
        ),
      ),
    );
  }
}
