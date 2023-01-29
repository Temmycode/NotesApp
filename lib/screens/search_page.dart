import 'package:animation_and_notes/helper/dimension.dart';
import 'package:animation_and_notes/screens/edit_notes_page.dart';
import 'package:animation_and_notes/screens/home_screen.dart';
import 'package:animation_and_notes/screens/notes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  String note = '';
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _animController;

  getNotesId(String title) async {
    return await FirebaseFirestore.instance
        .collection('notesRoom')
        .where("title", arrayContains: title);
  }

  Widget searchList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notesRoom').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (note.isEmpty) {
            return Expanded(
              child: LottieBuilder.asset(
                'assets/animations/search_animation.json',
                controller: _animController,
              ),
            );
          } else {
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  if (data['title']
                      .toString()
                      .toLowerCase()
                      .startsWith(note.toLowerCase())) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const NotesPage()));
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditNotesPage(
                                      docsToEdit: snapshot.data!.docs[index])));
                        },
                        child: searchTile(
                          data['title'],
                          data['content'],
                        ),
                      ),
                    );
                  }
                  return Container();
                });
          }
        });
  }

  @override
  void initState() {
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.width15,
                  right: Dimensions.height20,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                        (route) => false);
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      note = value;
                    });
                  },
                  maxLines: 1,
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: '             search...',
                    hintStyle: GoogleFonts.lato(
                      textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                  ),
                ),
              ),
            ],
          ),
          searchList(),
        ],
      )),
    );
  }
}

Widget searchTile(
  String title,
  String content,
) {
  return ListTile(
    title: Text(
      title,
      style: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: Dimensions.font16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
    subtitle: Text(
      content,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: Dimensions.font14,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    ),
  );
}
