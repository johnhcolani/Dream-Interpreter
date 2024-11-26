import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../database_helper/database_helper.dart';
import '../widgets/clear_appbar.dart';
import '../widgets/background_image2.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<Map<String, dynamic>> _conversations = [];
  late List<bool> _isExpandedList;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final db = DatabaseHelper();
      final conversations = await db.getConversations();
      setState(() {
        _conversations = List.from(conversations);
        _isExpandedList = List.generate(_conversations.length, (index) => false, growable: true);
      });
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  Future<void> _deleteConversation(int id, int index) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this conversation?',style: TextStyle(color: Colors.grey),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancelled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final db = DatabaseHelper();
        final result = await db.deleteEntry(id);
        if (result > 0) {
          setState(() {
            _conversations.removeAt(index);
            _isExpandedList.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversation deleted.')),
          );
        } else {
          debugPrint('No conversation found to delete.');
        }
      } catch (e) {
        debugPrint('Error deleting conversation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete conversation: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const BackgroundImage2(),
          Column(
            children: [
              ClearAppBar(
                title: 'Journal',
                onBack: () {
                  Navigator.pop(context, true); // Notify changes
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _conversations.isEmpty
                      ? const Center(
                    child: Text(
                      'No conversations saved.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final entry = _conversations[index];
                      final isExpanded = _isExpandedList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        color: Colors.grey[400]?.withOpacity(0.7),
                        child: Column(
                          children: [
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['date'] ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      color: Colors.grey[200],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Q: ${entry['question'] ?? ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: Colors.black,
                                      size: 40,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isExpandedList[index] =
                                        !isExpanded;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon:  Icon(Icons.delete,
                                        color: Colors.red.shade400),
                                    onPressed: () async {
                                      final id = entry['id'] as int;
                                      await _deleteConversation(id, index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'A: ${entry['answer'] ?? ''}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                          ],
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
