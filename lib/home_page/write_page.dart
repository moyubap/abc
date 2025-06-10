// ✅ write_page.dart (전체 정상 작동 버전)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../databaseSvc.dart';

class WritePage extends StatefulWidget {
  final RecruitPost? post;
  const WritePage({super.key, this.post});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? selectedLocation;
  String? locationUrl;
  GeoPoint? selectedGeoPoint;
  File? _selectedImage;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedMealType;

  final List<String> mealTypes = [
    '한식', '일식', '중식', '양식', '분식', '디저트', '패스트푸드',
  ];

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    if (post != null) {
      _titleController.text = post.title;
      _contentController.text = post.content;
      selectedLocation = post.placeName;
      locationUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(post.placeName)}';
      selectedGeoPoint = post.location;
      final meet = post.meetTime.toDate();
      selectedDate = DateTime(meet.year, meet.month, meet.day);
      selectedTime = TimeOfDay(hour: meet.hour, minute: meet.minute);
      selectedMealType = post.foodType;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<String?> _uploadImage(String postId) async {
    if (_selectedImage == null) return null;
    final ref = FirebaseStorage.instance.ref().child('post_images/$postId.jpg');
    await ref.putFile(_selectedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.pushNamed(context, '/locationPicker');
    if (result is Map<String, dynamic>) {
      setState(() {
        selectedLocation = result['placeName'];
        locationUrl = result['locationUrl'];
        selectedGeoPoint = result['geoPoint'];
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _submitPost() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postRef = widget.post == null
        ? FirebaseFirestore.instance.collection('posts').doc()
        : FirebaseFirestore.instance.collection('posts').doc(widget.post!.postId);

    final postId = postRef.id;
    final meetDateTime = DateTime(
      selectedDate?.year ?? 0,
      selectedDate?.month ?? 0,
      selectedDate?.day ?? 0,
      selectedTime?.hour ?? 0,
      selectedTime?.minute ?? 0,
    );
    final imageUrl = await _uploadImage(postId);

    await postRef.set({
      'title': _titleController.text,
      'content': _contentController.text,
      'foodType': selectedMealType,
      'placeName': selectedLocation,
      'location': selectedGeoPoint,
      'meetTime': Timestamp.fromDate(meetDateTime),
      'hostId': uid,
      'createdAt': Timestamp.now(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    }, SetOptions(merge: true));

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('모집글 작성')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: '제목')),
          const SizedBox(height: 12),
          TextField(controller: _contentController, maxLines: 4, decoration: const InputDecoration(labelText: '내용')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedMealType,
            hint: const Text('음식 종류 선택'),
            items: mealTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (val) => setState(() => selectedMealType = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _pickDate,
                  child: Text(selectedDate == null
                      ? '날짜 선택'
                      : '${selectedDate!.year}.${selectedDate!.month}.${selectedDate!.day}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _pickTime,
                  child: Text(selectedTime == null ? '시간 선택' : selectedTime!.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _selectLocation, child: const Text('장소 선택')),
          if (selectedLocation != null && locationUrl != null)
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(locationUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $locationUrl';
                }
              },
              child: Text(
                selectedLocation!,
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _pickImage, child: const Text('이미지 선택')),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _submitPost, child: const Text('등록하기')),
        ],
      ),
    );
  }
}
