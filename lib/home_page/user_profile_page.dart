import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String username;
  final String university;
  final String imagePath;
  final String major;
  final String intro;
  final List<String> favoriteFoods;
  final String location;
  final int postCount;
  final int chatCount;

  const UserProfilePage({
    super.key,
    required this.username,
    required this.university,
    required this.imagePath,
    required this.major,
    required this.intro,
    required this.favoriteFoods,
    required this.location,
    required this.postCount,
    required this.chatCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$username 님의 프로필')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(backgroundImage: AssetImage(imagePath), radius: 50),
                  const SizedBox(height: 12),
                  Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('$university ∙ $major', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('자기소개', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(intro),
            const SizedBox(height: 16),
            const Text('좋아하는 음식', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: favoriteFoods.map((food) => Chip(label: Text('#$food'))).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 4),
                Text('선호 지역: $location'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('📝 모집 글: $postCount회')),
                Expanded(child: Text('💬 채팅 신청: $chatCount회')),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat),
              label: const Text('채팅 신청하기'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}
