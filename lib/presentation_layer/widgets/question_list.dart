import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ai_response_notifier.dart';

class QuestionsList extends StatelessWidget {
  final AIResponseState state;
  final ScrollController scrollController;

  const QuestionsList({
    super.key,
    required this.state,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: state.questions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blueGrey[400]?.withOpacity(0.4),
                child: ListTile(
                  title: Text(
                    'Q: ${state.questions[index]}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              Card(
                color: Colors.grey[400]?.withOpacity(0.3),
                child: ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'A: ${index == state.questions.length - 1 && state.isLoading ? state.currentAnswer : state.aiAnswers[index]}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.cyan.shade50),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: () {
                          final answerText = index == state.questions.length - 1 && state.isLoading ? state.currentAnswer : state.aiAnswers[index];
                          Clipboard.setData(ClipboardData(text: answerText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Answer copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
