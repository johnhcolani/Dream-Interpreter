import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';

class InputRow extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onStop;

  const InputRow({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
    required this.onStop,
  }) : super(key: key);

  @override
  _InputRowState createState() => _InputRowState();
}

class _InputRowState extends State<InputRow> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextBox(
            textEditingController: widget.controller,
            enabled: !widget.isLoading,
            label: 'Enter Your Dream',
          ),
        ),
        const SizedBox(width: 8),
        if (widget.isLoading)
          IconButton(
            onPressed: widget.onStop,
            icon: const Icon(Icons.stop, color: Colors.red),
          )
        else
          IconButton(
            onPressed: widget.controller.text.isEmpty ? null : widget.onSubmit,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
          ),
      ],
    );
  }
}
