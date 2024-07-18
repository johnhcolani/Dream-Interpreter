import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai_response_notifier.dart';
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
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> savedEntries = [];

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _handleSave() {
    final state = ref.read(aiResponseProvider);
    if (state.questions.isNotEmpty && state.aiAnswers.isNotEmpty) {
      savedEntries.add({
        'question': state.questions.last,
        'answer': state.aiAnswers.last,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Saved your dream"),
        ),
      );
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

  void _navigateToJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalPage(savedEntries: savedEntries),
      ),
    );
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const BackgroundImage1(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (state.needsUpdate)
                    Container(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 36.0),
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
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
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
