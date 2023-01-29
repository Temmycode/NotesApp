import 'package:animation_and_notes/helper/dimension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'home_screen.dart';

class EditNotesPage extends StatefulWidget {
  final DocumentSnapshot docsToEdit;
  const EditNotesPage({super.key, required this.docsToEdit});

  @override
  State<EditNotesPage> createState() => _EditNotesPageState();
}

class _EditNotesPageState extends State<EditNotesPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  updateNotes(String title, String content) {
    widget.docsToEdit.reference.update({
      "title": title,
      "content": content,
    }).whenComplete(() => Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage())));
  }

  deleteNote() {
    const snackBar = SnackBar(
      backgroundColor: Colors.grey,
      content: Text("The note has successfully been deleted"),
    );
    widget.docsToEdit.reference
        .delete()
        .whenComplete(() => snackBar)
        .whenComplete(() => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomePage())));
  }

  @override
  void initState() {
    _titleController = TextEditingController(
        text: (widget.docsToEdit.data() as Map<String, dynamic>)['title']);
    _contentController = TextEditingController(
        text: (widget.docsToEdit.data() as Map<String, dynamic>)['content']);
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
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
                onPressed: () async {
                  String title = _titleController.text;
                  String content = _contentController.text;
                  updateNotes(title, content);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomePage()));
                },
                icon: Icon(
                  Icons.done,
                  color: Colors.grey[700],
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.delete:
                    final shouldDelete = await showMenuActionDialog(context,
                        "Delete", "Are you sure you want to delete this note?");
                    if (shouldDelete) {
                      deleteNote();
                    }
                    break;
                  case MenuAction.share:
                    if (_contentController.text == null ||
                        _contentController.text.isEmpty) {
                      await showCannotShareEmptyNoteDialog(context);
                    } else {
                      Share.share(_titleController.text);
                    }
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.delete,
                    child: Text(
                      "delete",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700],
                      )),
                    ),
                  ),
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.share,
                    child: Text(
                      "share",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700],
                      )),
                    ),
                  ),
                ];
              },
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(
          left: Dimensions.width20,
          right: Dimensions.width20,
          top: Dimensions.width15,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // title
              TextField(
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      fontSize: Dimensions.radius28,
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
                      fontSize: Dimensions.font14,
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

enum MenuAction { delete, share }

Future<bool> showMenuActionDialog(
    BuildContext context, String title, String content) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Ok")),
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showMenuActionDialog(
      context, 'Sharing', "You cannot share an empty note!");
}
