import 'package:animation_and_notes/helper/dimension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/data/database_service.dart';
import 'home_screen.dart';

class NotesPage extends StatefulWidget {
  // final String noteId;
  const NotesPage({
    super.key,
    // required this.noteId,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  createNotes(title, content) {
    Map<String, dynamic> notesAndContentMap = {
      "title": title,
      "content": content,
      "time": DateTime.now().millisecondsSinceEpoch
    };
    DatabaseService.firestore()
        .addNotes(title: title, notesAndContentMap: notesAndContentMap);
  }

  @override
  void initState() {
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
                (MaterialPageRoute(builder: (context) => const HomePage())),
                (route) => false);
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Dimensions.width20),
            child: IconButton(
                onPressed: () async {
                  String title = _titleController.text;
                  String content = _contentController.text;
                  await createNotes(title, content);

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomePage()));
                },
                icon: Icon(
                  Icons.done,
                  color: Colors.grey[700],
                )),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(
          left: Dimensions.width20,
          right: Dimensions.width20,
          top: Dimensions.height10,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // title
              TextField(
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                maxLines: 1,
                controller: _titleController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54)),
                  hintText: 'Title',
                  hintStyle: GoogleFonts.lato(
                    textStyle: TextStyle(
                        fontSize: Dimensions.radius28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700]),
                  ),
                ),
              ),
              const SizedBox(
                height: Dimensions.height40,
              ),
              // content
              TextField(
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                controller: _contentController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Content',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
