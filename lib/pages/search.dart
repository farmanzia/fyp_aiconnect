import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:fyp_social_app/chats/conversation.dart';
import 'package:fyp_social_app/models/user.dart';
import 'package:fyp_social_app/pages/profile.dart';
import 'package:fyp_social_app/utils/constants.dart';
import 'package:fyp_social_app/utils/firebase.dart';
import 'package:fyp_social_app/widgets/indicators.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  User? user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;

  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  getUsers() async {
    QuerySnapshot snap = await usersRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    users = doc;
    filteredUsers = doc;
    setState(() {
      loading = false;
    });
  }

  search(String query) {
    if (query == "") {
      filteredUsers = users;
    } else {
      List userSearch = users.where((userSnap) {
        Map user = userSnap.data() as Map<String, dynamic>;
        String userName = user['username'];
        return userName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredUsers = userSearch as List<DocumentSnapshot<Object?>>;
      });
    }
  }

  removeFromList(index) {
    filteredUsers.removeAt(index);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () => getUsers(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: buildSearch(),
            ),
            buildUsers(),
          ],
        ),
      ),
    );
  }

  buildSearch() {
    return Row(
      children: [
        Container(
          height: 40.0,
          width: MediaQuery.of(context).size.width - 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CupertinoSearchTextField(
              placeholder: 'Search user',
              onChanged: (query) {
                search(query);
              },
            ),
          ),
        ),
      ],
    );
  }

  buildUsers() {
    if (!loading) {
      if (filteredUsers.isEmpty) {
        return Center(
          child: Text(
            "No User Found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot doc = filteredUsers[index];
                UserModel user =
                    UserModel.fromJson(doc.data() as Map<String, dynamic>);
                if (doc.id == currentUserId()) {
                  Timer(Duration(milliseconds: 500), () {
                    setState(() {
                      removeFromList(index);
                    });
                  });
                }
                return ListTile(
                  onTap: () => showProfile(context, profileId: user.id!),
                  leading: user.photoUrl!.isEmpty
                      ? CircleAvatar(
                          radius: 25.0,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Center(
                            child: Text(
                              '${user.username![0].toUpperCase()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 25.0,
                          backgroundImage: CachedNetworkImageProvider(
                            '${user.photoUrl}',
                          ),
                        ),
                  title: Text(
                    user.username!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user.email!,
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => StreamBuilder(
                              stream: chatIdRef
                                  .where(
                                    "users",
                                    isEqualTo: getUser(
                                      firebaseAuth.currentUser!.uid,
                                      doc.id,
                                    ),
                                  )
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  var snap = snapshot.data;
                                  List docs = snap!.docs;
                                  print(snapshot.data!.docs.toString());
                                  return docs.isEmpty
                                      ? Conversation(
                                          userId: doc.id,
                                          chatId: 'newMsg',
                                        )
                                      : Conversation(
                                          userId: doc.id,
                                          chatId:
                                              docs[0].get('chatId').toString(),
                                        );
                                }
                                return Conversation(
                                  userId: doc.id,
                                  chatId: 'newMsg',
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Iconsax.message,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }

  //get concatenated list of users
  //this will help us query the chat id reference in other
  // to get the correct user id

  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = "${list[0]}-${list[1]}";
    return chatId;
  }

  @override
  bool get wantKeepAlive => true;
}