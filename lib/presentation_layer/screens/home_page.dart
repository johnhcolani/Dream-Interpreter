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
// Prepare your list of prompts
  final List<String> prompts = [
    "Why do we dream?",
    "What does it mean when I dream about falling?",
    "Can dreams predict the future?",
    "What does it mean to dream of flying?",
    "Why do nightmares happen?",
    "How can I control my dreams?",
    "Why do I keep dreaming about the same thing?",
    "What does it mean to dream about water?",
  ];

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

    return Stack(
      children: [
        GestureDetector(
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
                      // New Horizontal Scrolling ListView
                      // Hide prompts when the AI starts generating an answer
                      if (!state.isLoading)
                        SizedBox(
                          height: 80, // Increased height to accommodate two lines
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: prompts.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  controller.text = prompts[index];
                                },
                                child: Container(
                                  width: 150, // Adjust width to fit prompts
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      prompts[index],
                                      textAlign: TextAlign.center, // Center-align text
                                      style:  TextStyle(
                                        color: Colors.grey.shade800, // Gray text color
                                        fontWeight: FontWeight.w300, // Weight 300
                                        fontSize: 14, // Adjust font size if needed
                                      ),
                                      softWrap: true, // Allow wrapping
                                      maxLines: 2, // Limit to 2 lines
                                      overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16), // Space between prompts and InputRow

                      InputRow(
                        controller: controller,
                        isLoading: state.isLoading,
                        onSubmit: _handleSubmit,
                        onStop: _handleStop,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 60, // Adjust height as needed
                        color: Colors.grey,
                        alignment: Alignment.center,
                        child: const Text(
                          "",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height *0.02),
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
        ),
      ],
    );
  }
}
