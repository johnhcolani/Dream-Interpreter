import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai_response_notifier.dart';
import '../../database_helper/database_helper.dart';
import '../widgets/background_image1.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/input_row.dart';
import '../widgets/question_list.dart';
import 'journal_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<HomePage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _savedConversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final db = DatabaseHelper();
      final conversations = await db.getConversations();
      setState(() {
        _savedConversations = List<Map<String, String>>.from(
          conversations.map((conversation) => {
            'date': conversation['date'] as String,
            'question': conversation['question'] as String,
            'answer': conversation['answer'] as String,
          }),
        );
      });
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load conversations")),
      );
    }
  }

  void _handleSubmit() {
    final notifier = ref.read(aiResponseProvider.notifier);
    notifier.fetchAIResponse(controller.text);
    controller.clear();
  }

  void _handleStop() {
    final notifier = ref.read(aiResponseProvider.notifier);
    notifier.cancelTyping();
  }

  Future<void> _handleSave() async {
    final state = ref.read(aiResponseProvider);
    if (state.questions.isNotEmpty && state.aiAnswers.isNotEmpty) {
      try {
        final db = DatabaseHelper();
        await db.insertConversation(
          DateTime.now().toString(),
          state.questions.last,
          state.aiAnswers.last,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved conversation")),
        );
        await _loadConversations();
      } catch (e) {
        debugPrint('Error saving conversation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save conversation: $e')),
        );
      }
    }
  }

  void _handleClear() {
    final notifier = ref.read(aiResponseProvider.notifier);
    notifier.clearAll();
    controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _navigateToJournal() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const JournalPage(),
      ),
    );

    // Reload conversations if the journal made changes
    if (result == true) {
      await _loadConversations();
    }
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiResponseProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.isLoading || state.currentAnswer.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const BackgroundImage1(),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
              child: Column(
                children: [
                  if (state.needsUpdate)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.red,
                      child: const Text(
                        'Please update the AI model',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: QuestionsList(
                      state: state,
                      scrollController: _scrollController,
                    ),
                  ),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  const SizedBox(height: 16),
                  InputRow(
                    controller: controller,
                    isLoading: state.isLoading,
                    onSubmit: _handleSubmit,
                    onStop: _handleStop,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            CustomAppBar(
              onNewPage: _handleClear,
              onJournal: _navigateToJournal,
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
