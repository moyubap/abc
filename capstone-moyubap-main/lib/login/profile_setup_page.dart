import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isSaving = false;

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'nickname': _nicknameController.text.trim(),
      'bio': _bioController.text.trim(),
      'uid': uid,
      'createdAt': Timestamp.now(),
    });

    setState(() => _isSaving = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("프로필 설정")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(labelText: '닉네임'),
                  validator: (value) => value!.isEmpty ? '닉네임을 입력하세요' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: '한 줄 소개'),
                ),
                const SizedBox(height: 32),
                _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('프로필 저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
