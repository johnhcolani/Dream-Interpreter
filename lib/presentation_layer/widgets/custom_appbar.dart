import 'dart:ui';

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function() onNewPage;
  final Function() onJournal;
  final Function() onSave;

  const CustomAppBar({super.key, required this.onNewPage, required this.onJournal, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final double height=MediaQuery.of(context).size.height;



    return SizedBox(
      height: height *0.12,
      child: AppBar(
        title:const Align(
          alignment: Alignment.center,
          child: Text(
            'Dream Whisperer',
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: Semantics(
          label: 'Save Button',
          hint: 'Double tap to start new page',
          enabled: true,
          child: IconButton(
            icon: const Icon(Icons.note_alt_outlined,color: Colors.white,),
            onPressed: onNewPage,
          ),
        ),
        actions: [

          Semantics(
            label: 'Save Button',
            hint: 'Double tap to save your current page',

            child: IconButton(
              icon: const Icon(Icons.save,color: Colors.white,),
              onPressed: onSave,

            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert,color: Colors.white,),
            onSelected: (item) {
              switch (item) {
                case 0:
                  onJournal();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('Journal')),
            ],
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
