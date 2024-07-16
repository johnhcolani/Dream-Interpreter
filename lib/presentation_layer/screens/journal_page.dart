import 'package:flutter/material.dart';
import '../widgets/background_image.dart';
import '../widgets/clear_appbar.dart';

class JournalPage extends StatelessWidget {
  final List<Map<String, String>> savedEntries;

  const JournalPage({super.key, required this.savedEntries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const BackgroundImage(),
          Column(
            children: [
              ClearAppBar(
                title: 'Journal',
                onBack: () {
                  Navigator.of(context).pop();
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: savedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = savedEntries[index];
                      return Card(
                        color: Colors.grey[800]?.withOpacity(0.7),
                        child: ListTile(
                          title: Text(
                            'Q: ${entry['question']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'A: ${entry['answer']}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.cyan.shade200),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
