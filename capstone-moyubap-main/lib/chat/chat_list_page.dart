import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool isEditing = false;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _showCreateChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const Center(child: Text("채팅방 생성 기능 구현 예정")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
          child: Text(
            isEditing ? '완료' : '편집',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        title: const Text('채팅', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
            onPressed: () => _showCreateChatDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색창 (기능 구현 예정)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '채팅방을 검색하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),

          // 실시간 채팅방 목록
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .where('members', arrayContains: currentUserId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final chatRooms = snapshot.data!.docs;
                if (chatRooms.isEmpty) return const Center(child: Text('채팅방이 없습니다.'));

                return ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final doc = chatRooms[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final chatRoomId = doc.id;
                    final members = List<String>.from(data['members'] ?? []);
                    final otherUserId = members.firstWhere((id) => id != currentUserId, orElse: () => '');
                    final lastMessage = data['lastMessage'] ?? '';
                    final isGroup = (members.length > 2);
                    final unreadCount = data['unreadCounts']?[currentUserId] ?? 0;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                        final name = userData?['nickname'] ?? otherUserId;
                        final profileUrl = userData?['profileImage'];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: isGroup
                                    ? null
                                    : (profileUrl != null ? NetworkImage(profileUrl) : null),
                                child: isGroup
                                    ? Text('${members.length}', style: const TextStyle(color: Colors.black))
                                    : (profileUrl == null ? const Icon(Icons.person) : null),
                                backgroundColor: isGroup ? Colors.blueGrey[100] : null,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            lastMessage,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  otherUserId: otherUserId,
                                  chatRoomId: chatRoomId,
                                ),
                              ),
                            );
                          },
                          trailing: isEditing
                              ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await doc.reference.delete();
                            },
                          )
                              : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
