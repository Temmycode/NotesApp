import 'package:animation_and_notes/helper/dimension.dart';
import 'package:animation_and_notes/screens/search_page.dart';
import 'package:animation_and_notes/services/data/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'edit_notes_page.dart';
import 'notes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Stream<QuerySnapshot>? stream;
  getNotesList() {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Container(
              height: Dimensions.screenHeight / 1.5,
              alignment: Alignment.center,
              child: LottieBuilder.asset(
                'assets/animation/notes_animation.json',
                height: Dimensions.notesAnimation,
                controller: _animController,
              ),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = (snapshot.data!.docs[index].data()
                      as Map<String, dynamic>);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditNotesPage(
                                    docsToEdit: snapshot.data!.docs[index],
                                  )));
                    },
                    // padding: EdgeInsets.only(right: 20),
                    child: NotesTile(
                      title: data['title'],
                      content: data['content'],
                      deleteNote: () async {
                        await snapshot.data!.docs[index].reference.delete();
                      },
                      shareNote: () {
                        Share.share(data['title']);
                      },
                    ),
                  );
                });
          } else {
            return Container();
          }
        });
  }

  getNotesInfo() async {
    await DatabaseService.firestore().getNoteRooms().then((value) {
      setState(() {
        stream = value;
      });
    });
  }

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animController.forward();
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
    getNotesInfo();
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
            Container(
              margin: const EdgeInsets.only(
                left: Dimensions.width20,
                right: Dimensions.width20,
                top: Dimensions.height15,
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Notes",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.height50,
                              color: Colors.grey[800])),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchPage()));
                      },
                      child: Icon(
                        Icons.search,
                        color: Colors.grey[700],
                        size: Dimensions.height30,
                      ),
                    ),
                  ]),
            ),
            const SizedBox(
              height: Dimensions.height30,
            ),
            Expanded(child: getNotesList())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const NotesPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NotesTile extends StatefulWidget {
  final String title;
  final String content;
  final Function deleteNote;
  final Function shareNote;
  const NotesTile({
    super.key,
    required this.title,
    required this.content,
    required this.deleteNote,
    required this.shareNote,
  });

  @override
  State<NotesTile> createState() => _NotesTileState();
}

class _NotesTileState extends State<NotesTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.pink,
      height: Dimensions.height90,
      margin: const EdgeInsets.only(
        bottom: Dimensions.height20,
        left: Dimensions.width15,
        right: Dimensions.width15,
      ),
      child: Slidable(
        key: const ValueKey(0),
        enabled: true,
        closeOnScroll: true,
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                // share notes
                widget.shareNote;
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              icon: Icons.share,
              backgroundColor: const Color.fromARGB(255, 237, 204, 224),
            ),
            SlidableAction(
              onPressed: (context) async {
                // delete note
                widget.deleteNote;
              },
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(Dimensions.radius15),
                  topLeft: Radius.circular(Dimensions.radius15)),
              backgroundColor: Colors.redAccent,
              icon: Icons.delete,
            ),
          ],
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            color: Colors.grey[200]!.withOpacity(0.6),
          ),
          child: ListTile(
            title: Text(
              widget.title,
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            subtitle: Text(
              widget.content,
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
          ),
        ),
      ),
    );
  }
}
