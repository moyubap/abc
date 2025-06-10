import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../databaseSvc.dart';
import '../home_page/post_detail_page.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  Stream<List<RecruitPost>> myPostsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // 로그인 안 된 경우 빈 스트림 반환
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('posts')
        .where('hostId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => RecruitPost.fromDoc(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 글 목록'),
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder<List<RecruitPost>>(
        stream: myPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('작성한 글이 없습니다.'));
          }
          final recruitPosts = snapshot.data!;
          return ListView.builder(
            itemCount: recruitPosts.length,
            itemBuilder: (context, index) {
              final recruitPost = recruitPosts[index];
              return ListTile(
                leading: const Icon(Icons.article),
                title: Text(recruitPost.title),
                subtitle: Text(
                  recruitPost.meetTime
                      .toDate()
                      .toString()
                      .split(' ')[0], // 날짜만
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: recruitPost),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
