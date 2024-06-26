import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:fyp_social_app/auth/register/register.dart';
import 'package:fyp_social_app/components/stream_grid_wrapper.dart';
import 'package:fyp_social_app/models/post.dart';
import 'package:fyp_social_app/models/user.dart';
import 'package:fyp_social_app/screens/edit_profile.dart';
import 'package:fyp_social_app/screens/list_posts.dart';
import 'package:fyp_social_app/screens/settings.dart';
import 'package:fyp_social_app/utils/constants.dart';
import 'package:fyp_social_app/utils/firebase.dart';
import 'package:fyp_social_app/widgets/post_tiles.dart';

class Profile extends StatefulWidget {
  final profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  UserModel? users;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();
  bool isAiExpert = false;
  String score='0';

  currentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    isUserAiExpert();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }
  isUserAiExpert(){
    if(firebaseAuth.currentUser?.uid!=null){
      firestore.collection("users").doc(firebaseAuth.currentUser?.uid).get().then((value){
        if(value['isAiExpert']==false){
          isAiExpert=false;
        }
        else{
          isAiExpert=true;
          score=value['score'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
        title: Text(
          Constants.appName,
          style: const TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: true? Column(

        children: [
        StreamBuilder(
          stream: usersRef.doc(widget.profileId).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              UserModel user = UserModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>,
              );
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16,),
                  user.photoUrl!.isEmpty
                      ? CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary,
                    child: Center(
                      child: Text(
                        user.username![0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  )
                      : CircleAvatar(
                    radius: 40.0,
                    backgroundImage:
                    CachedNetworkImageProvider(
                      '${user.photoUrl}',
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Text(
                    user.username!,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 8,),

                  Text(
                    user.email!,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context)
                          .iconTheme
                          .color,
                    ),
                  ),
                  const SizedBox(height: 8,),

                  Text(
                    user.phoneNumber??"",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context)
                          .iconTheme
                          .color,
                    ),
                  ),
                  const SizedBox(height: 8,),

                  Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      widget.profileId == currentUserId()
                          ? Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => Setting(),
                                ),
                              );
                            },
                            child: Icon(
                              Ionicons.settings_outline,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary,
                            ),
                          ),

                          isAiExpert==true && int.parse(score.toString())>=7?  const Row(
                            children: [
                              CircleAvatar(radius: 8,backgroundColor: Colors.green, child: Icon(Icons.done_outline,size: 8,),),
                              Text(" expert ",style: TextStyle(fontSize: 10),)

                            ],
                          ):const Row(
                            children: [
                              CircleAvatar(
                                radius: 8, child: Icon(Icons.close,size: 8,),),
                              Text(" expert ",style: TextStyle(fontSize: 10),)
                            ],
                          )

                        ],
                      )
                          : const SizedBox.shrink()
                      // : buildLikeButton()
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                    child: user.bio!.isEmpty
                        ? Container()
                        : SizedBox(
                      width: 200,
                      child: Text(
                        user.bio!,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child
                              : StreamBuilder(
                            stream: postRef
                                .where('ownerId',
                                isEqualTo: widget.profileId)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot<Object?>? snap =
                                    snapshot.data;
                                List<DocumentSnapshot> docs = snap!.docs;
                                return buildCount(
                                    "Posts", docs.length ?? 0);
                              } else {
                                return buildCount("Posts", 0);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width:8),
                        Expanded(
                          child: StreamBuilder(
                            stream: followersRef
                                .doc(widget.profileId)
                                .collection('userFollowers')
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot<Object?>? snap =
                                    snapshot.data;
                                List<DocumentSnapshot> docs = snap!.docs;
                                return buildCount(
                                    "Followers", docs.length ?? 0);
                              } else {
                                return buildCount("Followers", 0);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width:8),
                        Expanded(
                          child: StreamBuilder(
                            stream: followingRef
                                .doc(widget.profileId)
                                .collection('userFollowing')
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot<Object?>? snap =
                                    snapshot.data;
                                List<DocumentSnapshot> docs = snap!.docs;
                                return buildCount(
                                    "Following", docs.length ?? 0);
                              } else {
                                return buildCount("Following", 0);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const SizedBox(height:12),
                  buildProfileButton(user),

                ],
              );
            }
            return Container();
          },
        ),
          const SizedBox(height:12),
          const Text(
            'My Posts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height:12),
          Expanded(
            child:   buildPostView(),
          )
      ],):  CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            toolbarHeight: 5.0,
            collapsedHeight: 6.0,
            expandedHeight: 233.0,
            flexibleSpace: FlexibleSpaceBar(
              background: StreamBuilder(
                stream: usersRef.doc(widget.profileId).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(
                      snapshot.data!.data() as Map<String, dynamic>,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16,),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: user.photoUrl!.isEmpty
                                  ? CircleAvatar(
                                      radius: 40.0,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      child: Center(
                                        child: Text(
                                          user.username![0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 40.0,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        '${user.photoUrl}',
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 20.0),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32.0),
                                  FittedBox(
                                    child: Row(
                                      children: [
                                        const Visibility(
                                          visible: false,
                                          child: SizedBox(width: 10.0),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 130.0,
                                              child: Text(
                                                user.username!,
                                                style: const TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: null,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 130.0,
                                              child: Text(
                                                user.phoneNumber!,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 10.0),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.email!,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 40.0),
                                        widget.profileId == currentUserId()
                                            ? Column(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      Navigator.of(context).push(
                                                        CupertinoPageRoute(
                                                          builder: (_) => Setting(),
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Ionicons.settings_outline,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ),

                                                isAiExpert==true && int.parse(score.toString())>=7?  const Row(
                                                  children: [
                                                    CircleAvatar(radius: 8,backgroundColor: Colors.green, child: Icon(Icons.done_outline,size: 8,),),
                                                    Text(" expert ",style: TextStyle(fontSize: 10),)

                                                  ],
                                                ):const Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 8, child: Icon(Icons.close,size: 8,),),
                                                    Text(" expert ",style: TextStyle(fontSize: 10),)
                                                  ],
                                                )

                                              ],
                                            )
                                            : const SizedBox.shrink()
                                        // : buildLikeButton()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                          child: user.bio!.isEmpty
                              ? Container()
                              : Container(
                                  width: 200,
                                  child: Text(
                                    user.bio!,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          // height: 50.0,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child
                                      : StreamBuilder(
                                    stream: postRef
                                        .where('ownerId',
                                            isEqualTo: widget.profileId)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot<Object?>? snap =
                                            snapshot.data;
                                        List<DocumentSnapshot> docs = snap!.docs;
                                        return buildCount(
                                            "Posts", docs.length ?? 0);
                                      } else {
                                        return buildCount("Posts", 0);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width:8),
                                Expanded(
                                  child: StreamBuilder(
                                    stream: followersRef
                                        .doc(widget.profileId)
                                        .collection('userFollowers')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot<Object?>? snap =
                                            snapshot.data;
                                        List<DocumentSnapshot> docs = snap!.docs;
                                        return buildCount(
                                            "Followers", docs.length ?? 0);
                                      } else {
                                        return buildCount("Followers", 0);
                                      }
                                    },
                                  ),
                                ),
                               const SizedBox(width:8),
                                Expanded(
                                  child: StreamBuilder(
                                    stream: followingRef
                                        .doc(widget.profileId)
                                        .collection('userFollowing')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot<Object?>? snap =
                                            snapshot.data;
                                        List<DocumentSnapshot> docs = snap!.docs;
                                        return buildCount(
                                            "Following", docs.length ?? 0);
                                      } else {
                                        return buildCount("Following", 0);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        buildProfileButton(user),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index > 0) return null;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          const Text(
                            'All Posts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              DocumentSnapshot doc =
                                  await usersRef.doc(widget.profileId).get();
                              var currentUser = UserModel.fromJson(
                                doc.data() as Map<String, dynamic>,
                              );
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => ListPosts(
                                    userId: widget.profileId,
                                    username: currentUser.username,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Ionicons.grid_outline),
                          )
                        ],
                      ),
                    ),
                    buildPostView()
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  buildCount(String label, int count) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu-Regular',
              ),
            ),
            const SizedBox(height: 3.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Ubuntu-Regular',
              ),
            )
          ],
        ),
      ),
    );
  }

  buildProfileButton(user) {
    //if isMe then display "edit profile"
    bool isMe = widget.profileId == firebaseAuth.currentUser!.uid;
    if (isMe) {
      return buildButton(
          text: "Edit Profile",
          function: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EditProfile(
                  user: user,
                ),
              ),
            );
          });
      //if you are already following the user then "unfollow"
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
      //if you are not following the user then "follow"
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollow,
      );
    }
  }

  buildButton({String? text, Function()? function}) {
    return Center(
      child: GestureDetector(
        onTap: function!,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.secondary,
                const Color(0xff4CAFE5),
              ],
            ),
          ),
          child: Center(
            child: Text(
              text!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  handleUnfollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove from notifications feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    setState(() {
      isFollowing = true;
    });
    //updates the followers collection of the followed user
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});
    //updates the following collection of the currentUser
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //update the notification feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": users?.username,
      "userId": users?.id,
      "userDp": users?.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildPostView() {
    return buildGridPost();
  }

  buildGridPost() {
    return StreamGridWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      stream: postRef
          .where('ownerId', isEqualTo: widget.profileId)
          // .orderBy('timestamp', descending: false)
          .snapshots(),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        PostModel posts = PostModel.fromJson(snapshot.data() as Map<String, dynamic>);
        return PostTile(
          post: posts,
        );
      },
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: favUsersRef
          .where('postId', isEqualTo: widget.profileId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
          return GestureDetector(
            onTap: () {
              if (docs.isEmpty) {
                favUsersRef.add({
                  'userId': currentUserId(),
                  'postId': widget.profileId,
                  'dateCreated': Timestamp.now(),
                });
              } else {
                favUsersRef.doc(docs[0].id).delete();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3.0,
                    blurRadius: 5.0,
                  )
                ],
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Icon(
                  docs.isEmpty
                      ? CupertinoIcons.heart
                      : CupertinoIcons.heart_fill,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
