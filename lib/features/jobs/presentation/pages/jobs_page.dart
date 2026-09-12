import 'package:flutter/material.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
      ),
      body: Center(
        child: Text('Jobs Feature Page'),
      ),
    );
  }
}
