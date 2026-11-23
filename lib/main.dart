import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: ProfilePage(),
    ),
  ));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تمرین اول فلاتر')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // اندازه ستون به اندازه محتوا باشد
            children: [
              const Icon(Icons.person, size: 60, color: Colors.blue),
              const SizedBox(height: 10), // ایجاد فاصله خالی
              const Text(
                'نام کاربر: احمد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  print('دکمه کلیک شد!');
                },
                child: const Text('دنبال کردن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
