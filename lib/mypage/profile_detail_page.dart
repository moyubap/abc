import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) return const Center(child: Text("프로필 정보가 없습니다."));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: data['profileImage'] != null
                    ? NetworkImage(data['profileImage'])
                    : const AssetImage('assets/users/profile1.jpg') as ImageProvider,
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      data['nickname'] ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      data['email'] ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _infoTile("닉네임", data['nickname']),
              _infoTile("이메일", data['email']),
              _infoTile("이름", data['name']),
              _infoTile("한 줄 소개", data['bio']),
              _infoTile("나이", data['age']?.toString()),
              _infoTile("성별", data['gender']),
              _infoTile("좋아하는 음식", data['likes']),
              _infoTile("싫어하는 음식", data['dislikes']),
              _infoTile("소개", data['bio']),
              _infoTile("좋아하는 것", data['likes']),
              _infoTile("싫어하는 것", data['dislikes']),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(String title, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value ?? "없음"),
      ),
    );
  }
}
