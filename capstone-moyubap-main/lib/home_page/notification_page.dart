import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 알림 목록 임시 샘플
    final notifications = [
      '새 댓글이 달렸습니다.',
      '새 게시글이 등록되었습니다.',
      '이벤트 알림이 도착했습니다.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notifications[index]),
          );
        },
      ),
    );
  }
}
