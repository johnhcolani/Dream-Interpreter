import 'package:flutter/material.dart';

class SavedQuestionsPage extends StatelessWidget {
  final List<Map<String, String>> savedQA;

  const SavedQuestionsPage({super.key, required this.savedQA});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      body: ListView.builder(
        itemCount: savedQA.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q: ${savedQA[index]['question']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('A: ${savedQA[index]['answer']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
