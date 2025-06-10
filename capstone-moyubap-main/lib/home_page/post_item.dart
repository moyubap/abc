import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databaseSvc.dart';
import 'post_detail_page.dart';

class PostItem extends StatelessWidget {
  const PostItem(this.post, {super.key});
  final RecruitPost post;

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(post.meetTime.toDate());
    final currentCount = post.participantIds.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 텍스트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            post.placeName,
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.group, size: 16, color: Colors.teal),
                        const SizedBox(width: 4),
                        Text('$currentCount명',
                            style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                        const SizedBox(width: 16),
                        const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('0', // 조회수 미구현 시 0
                            style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 오른쪽 썸네일
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                    ? Image.network(
                  post.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/images/점심밥.jpeg',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}