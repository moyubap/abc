import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_page.dart';
import '../databaseSvc.dart';
import 'user_profile_page.dart';
import '../chat/chat_detail_page.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.post});
  final RecruitPost post;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool isLiked = false;
  int likeCount = 0;

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.contains(currentUser?.uid);
    likeCount = widget.post.likes.length;
  }

  void toggleLike() async {
    if (currentUser == null) return;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.postId);

    setState(() {
      if (isLiked) {
        isLiked = false;
        likeCount--;
      } else {
        isLiked = true;
        likeCount++;
      }
    });

    if (isLiked) {
      await postRef.update({'likes': FieldValue.arrayUnion([currentUser!.uid])});
    } else {
      await postRef.update({'likes': FieldValue.arrayRemove([currentUser!.uid])});
    }
  }

  bool get isMyPost {
    return currentUser != null && widget.post.hostId == currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF81D4FA),
        elevation: 0,
        title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isMyPost) ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WritePage(post: post)))),
            IconButton(icon: const Icon(Icons.delete), onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("정말 삭제하시겠습니까?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제")),
                  ],
                ),
              );
              if (confirmed == true) {
                await FirebaseFirestore.instance.collection('posts').doc(post.postId).delete();
                if (context.mounted) Navigator.pop(context);
              }
            }),
          ]
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                post.imageUrl != null && post.imageUrl!.isNotEmpty
                    ? Image.network(post.imageUrl!, width: double.infinity, height: 260, fit: BoxFit.cover)
                    : Image.asset('assets/images/점심밥.jpeg', width: double.infinity, height: 260, fit: BoxFit.cover),
                Container(
                  color: const Color(0xFFFFFEFC),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(post.hostId).get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const CircularProgressIndicator();
                          final raw = snapshot.data!.data();
                          if (raw == null) return const SizedBox.shrink();
                          final user = raw as Map<String, dynamic>;
                          final nickname = user['nickname'] ?? post.hostId;
                          final profileUrl = user['profileImage'];
                          final intro = user['bio'] ?? '';
                          final major = user['major'] ?? '';
                          final university = user['university'] ?? '';
                          final rawLikes = user['likes'];
                          List<String> likes = [];
                          if (rawLikes is List) {
                            likes = List<String>.from(rawLikes);
                          } else if (rawLikes is String) {
                            likes = rawLikes.split(',').map((e) => e.trim()).toList();
                          }

                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage(
                              username: nickname,
                              university: university,
                              imagePath: profileUrl ?? '',
                              major: major,
                              intro: intro,
                              favoriteFoods: likes,
                              location: post.placeName,
                              postCount: 0,
                              chatCount: 0,
                            ))),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: profileUrl != null && profileUrl.isNotEmpty
                                      ? NetworkImage(profileUrl)
                                      : const AssetImage('assets/users/profile1.jpg') as ImageProvider,
                                  radius: 22,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('작성자', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 0.5, color: Colors.black26),
                      const SizedBox(height: 6),
                      Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _iconRow(Icons.place, post.placeName),
                      const SizedBox(height: 20),
                      _iconRow(Icons.calendar_today, post.meetTime.toDate().toString().split(" ")[0]),
                      const SizedBox(height: 20),
                      _iconRow(Icons.access_time, post.meetTime.toDate().toString().split(" ")[1].substring(0, 5)),
                      const SizedBox(height: 20),
                      _iconRow(Icons.restaurant, post.foodType),
                      const SizedBox(height: 24),
                      Text(post.content, style: const TextStyle(height: 1.8, fontSize: 16)),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          IconButton(
                            onPressed: toggleLike,
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.black,
                            ),
                          ),
                          Text('관심 $likeCount ∙ 조회수 0', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 0.5, color: Colors.black12),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.people, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('지원자 0명', style: TextStyle(color: Colors.black87, fontSize: 15)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(post.placeName)}');
                          if (!await launchUrl(uri)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('지도를 열 수 없습니다.')),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(post.placeName, style: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              width: double.infinity,
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final otherUserId = post.hostId;
                        if (currentUser == null || currentUser.uid == otherUserId) return;

                        final uids = [currentUser.uid, otherUserId]..sort();
                        final chatRoomId = uids.join('_');
                        final chatRoomRef = FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
                        final postRef = FirebaseFirestore.instance.collection('posts').doc(post.postId);

                        final snapshot = await chatRoomRef.get();
                        if (!snapshot.exists) {
                          await chatRoomRef.set({
                            'members': uids,
                            'createdAt': FieldValue.serverTimestamp(),
                            'lastMessage': '',
                          });
                        } else {
                          await chatRoomRef.update({
                            'members': FieldValue.arrayUnion([currentUser.uid])
                          });
                        }

                        await postRef.update({
                          'participantIds': FieldValue.arrayUnion([currentUser.uid]),
                        });

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                otherUserId: otherUserId,
                                chatRoomId: chatRoomId,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF81D4FA),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('채팅 신청하기', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}