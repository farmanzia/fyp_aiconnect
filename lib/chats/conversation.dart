// import 'dart:developer';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:provider/provider.dart';
// import 'package:fyp_social_app/components/chat_bubble.dart';
// import 'package:fyp_social_app/models/enum/message_type.dart';
// import 'package:fyp_social_app/models/message.dart';
// import 'package:fyp_social_app/models/user.dart';
// import 'package:fyp_social_app/pages/profile.dart';
// import 'package:fyp_social_app/utils/firebase.dart';
// import 'package:fyp_social_app/view_models/conversation/conversation_view_model.dart';
// import 'package:fyp_social_app/view_models/user/user_view_model.dart';
// import 'package:fyp_social_app/widgets/indicators.dart';
// import 'package:timeago/timeago.dart' as timeago;
//
// class Conversation extends StatefulWidget {
//   final String userId;
//   final String chatId;
//
//   const Conversation({required this.userId, required this.chatId});
//
//   @override
//   _ConversationState createState() => _ConversationState();
// }
//
// class _ConversationState extends State<Conversation> {
//   FocusNode focusNode = FocusNode();
//   ScrollController scrollController = ScrollController();
//   TextEditingController messageController = TextEditingController();
//   bool isFirst = false;
//   String? chatId;
//
//   @override
//   void initState() {
//     super.initState();
//     scrollController.addListener(() {
//       focusNode.unfocus();
//     });
//     if (widget.chatId == 'newMsg') {
//       isFirst = true;
//     }
//     chatId = widget.chatId;
//
//     messageController.addListener(() {
//       if (focusNode.hasFocus && messageController.text.isNotEmpty) {
//         setTyping(true);
//       } else if (!focusNode.hasFocus ||
//           (focusNode.hasFocus && messageController.text.isEmpty)) {
//         setTyping(false);
//       }
//     });
//   }
//
//   setTyping(typing) {
//     UserViewModel viewModel = Provider.of<UserViewModel>(context);
//     viewModel.setUser();
//     var user = Provider.of<UserViewModel>(context, listen: true).user;
//     Provider.of<ConversationViewModel>(context, listen: false)
//         .setUserTyping(widget.chatId, user, typing);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     UserViewModel viewModel = Provider.of<UserViewModel>(context);
//     viewModel.setUser();
//     var user = Provider.of<UserViewModel>(context, listen: true).user;
//     return Consumer<ConversationViewModel>(
//         builder: (BuildContext context, viewModel, Widget? child) {
//       return Scaffold(
//         key: viewModel.scaffoldKey,
//         appBar: AppBar(
//           leading: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: const Icon(
//               Icons.keyboard_backspace,
//             ),
//           ),
//           elevation: 0.0,
//           titleSpacing: 0,
//           title: buildUserName(),
//         ),
//         body: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           child: Column(
//             children: [
//               Flexible(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: messageListStream(widget.chatId),
//                   builder: (context, snapshot) {
//                     log("==== widget.chatId ${widget.chatId}");
//                     if (snapshot.hasData) {
//                       List messages = snapshot.data!.docs;
//                       viewModel.setReadCount(widget.chatId, user, messages.length);
//                       return ListView.builder(
//                         controller: scrollController,
//                         padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                         itemCount: messages.length,
//                         reverse: true,
//                         itemBuilder: (BuildContext context, int index) {
//                           Message message = Message.fromJson(
//                             messages.reversed.toList()[index].data(),
//                           );
//                           return ChatBubbleWidget(
//                             message: '${message.content}',
//                             time: message.time!,
//                             isMe: message.senderUid == user!.uid,
//                             type: message.type!,
//                           );
//                         },
//                       );
//                     } else {
//                       return Center(child: circularProgress(context));
//                     }
//                   },
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: BottomAppBar(
//                   elevation: 10.0,
//                   child: Container(
//                     constraints: const BoxConstraints(maxHeight: 100.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             CupertinoIcons.photo_on_rectangle,
//                             color: Theme.of(context).colorScheme.secondary,
//                           ),
//                           onPressed: () => showPhotoOptions(viewModel, user),
//                         ),
//                         Flexible(
//                           child: TextField(
//                             controller: messageController,
//                             focusNode: focusNode,
//                             style: TextStyle(
//                               fontSize: 15.0,
//                               color: Theme.of(context).textTheme.headlineMedium!.color,
//                             ),
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.all(10.0),
//                               enabledBorder: InputBorder.none,
//                               border: InputBorder.none,
//                               hintText: "Type your message",
//                               hintStyle: TextStyle(
//                                 color: Theme.of(context)
//                                     .textTheme
//                                     .headlineMedium
//                                     ?.color,
//                               ),
//                             ),
//                             maxLines: null,
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             Ionicons.send,
//                             color: Theme.of(context).colorScheme.secondary,
//                           ),
//                           onPressed: () {
//                             if (messageController.text.isNotEmpty) {
//                               sendMessage(viewModel, user);
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   _buildOnlineText(
//     var user,
//     bool typing,
//   ) {
//     if (user.isOnline) {
//       if (typing) {
//         return "typing...";
//       } else {
//         return "online";
//       }
//     } else {
//       return 'last seen ${timeago.format(user.lastSeen.toDate())}';
//     }
//   }
//
//   buildUserName() {
//     return StreamBuilder(
//       stream: usersRef.doc(widget.userId).snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           DocumentSnapshot documentSnapshot =
//               snapshot.data as DocumentSnapshot<Object?>;
//           UserModel user = UserModel.fromJson(
//             documentSnapshot.data() as Map<String, dynamic>,
//           );
//           return InkWell(
//             child: Row(
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                   child: Hero(
//                     tag: user.email!,
//                     child: user.photoUrl!.isEmpty
//                         ? CircleAvatar(
//                             radius: 25.0,
//                             backgroundColor:
//                                 Theme.of(context).colorScheme.secondary,
//                             child: Center(
//                               child: Text(
//                                 user.username![0].toUpperCase(),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15.0,
//                                   fontWeight: FontWeight.w900,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : CircleAvatar(
//                             radius: 25.0,
//                             backgroundImage: CachedNetworkImageProvider(
//                               '${user.photoUrl}',
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(width: 10.0),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         '${user.username}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15.0,
//                         ),
//                       ),
//                       const SizedBox(height: 5.0),
//                       // StreamBuilder(
//                       //   stream: chatRef.doc(widget.chatId).snapshots(),
//                       //   builder: (context, snapshot) {
//                       //     if (snapshot.hasData) {
//                       //       DocumentSnapshot? snap =
//                       //           snapshot.data as DocumentSnapshot<Object?>;
//                       //       Map? data = snap.data() as Map<dynamic, dynamic>?;
//                       //       Map? usersTyping = data?['typing'] ?? {};
//                       //       return Text(
//                       //         _buildOnlineText(
//                       //           user,
//                       //           usersTyping![widget.userId] ?? false,
//                       //         ),
//                       //         style: const TextStyle(
//                       //           fontWeight: FontWeight.w400,
//                       //           fontSize: 11,
//                       //         ),
//                       //       );
//                       //     } else {
//                       //       return SizedBox();
//                       //     }
//                       //   },
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             onTap: () {
//               Navigator.of(context).push(
//                 CupertinoPageRoute(
//                   builder: (_) => Profile(profileId: user.id),
//                 ),
//               );
//             },
//           );
//         } else {
//           return Center(child: circularProgress(context));
//         }
//       },
//     );
//   }
//
//   showPhotoOptions(ConversationViewModel viewModel, var user) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(
//           Radius.circular(10.0),
//         ),
//       ),
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             ListTile(
//               title: const Text("Camera"),
//               onTap: () {
//                 sendMessage(viewModel, user, imageType: 0, isImage: true);
//               },
//             ),
//             ListTile(
//               title: const Text("Gallery"),
//               onTap: () {
//                 sendMessage(viewModel, user, imageType: 1, isImage: true);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   sendMessage(ConversationViewModel viewModel, var user,
//       {bool isImage = false, int? imageType}) async {
//     String msg;
//     if (isImage) {
//       msg = await viewModel.pickImage(
//         source: imageType!,
//         context: context,
//         chatId: widget.chatId,
//       );
//     } else {
//       msg = messageController.text.trim();
//       messageController.clear();
//     }
//
//     Message message = Message(
//       content: '$msg',
//       senderUid: user?.uid,
//       type: isImage ? MessageType.IMAGE : MessageType.TEXT,
//       time: Timestamp.now(),
//     );
//
//     if (msg.isNotEmpty) {
//       if (isFirst) {
//         print("FIRST");
//         String id = await viewModel.sendFirstMessage(widget.userId, message);
//         setState(() {
//           isFirst = false;
//           chatId = id;
//           //Add the IDs of the two users to the chatID reference
//           //the users map will be concatenation of the two users
//           //involved in the chat
//           chatIdRef.add({
//             "users": getUser(firebaseAuth.currentUser!.uid, widget.userId),
//             "chatId": id
//           });
//           viewModel.sendMessage(widget.chatId, message);
//         });
//         //update the reads to an empty map in other to avoid null value bug
//         chatRef.doc(chatId).update({'reads': {}});
//         //update the typing to an empty map in other to avoid null value bug
//         chatRef.doc(chatId).update({'typing': {}});
//       } else {
//         viewModel.sendMessage(
//           widget.chatId,
//           message,
//         );
//       }
//     }
//   }
//
//   //this will concatenate the two users involved in the chat
//   //and  return a unique id, because firebase doesn't perform
//   //some complex queries
//   String getUser(String user1, String user2) {
//     user1 = user1.substring(0, 5);
//     user2 = user2.substring(0, 5);
//     List<String> list = [user1, user2];
//     list.sort();
//     var chatId = "${list[0]}-${list[1]}";
//     return chatId;
//   }
//
//   Stream<QuerySnapshot> messageListStream(String documentId) {
//     return chatRef
//         .doc(documentId)
//         .collection('messages')
//         .orderBy('time')
//         .snapshots();
//   }
// }


import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;

class Conversation extends StatefulWidget {
  final String currentUserId;
  final String selectedUserId;

  Conversation({required this.currentUserId, required this.selectedUserId});

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendMessage(String text, [File? imageFile]) async {
    if (text.isEmpty && imageFile == null) return;

    String? imageUrl;
    if (imageFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('chat_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    await _firestore.collection('conversations').add({
      'senderId': widget.currentUserId,
      'receiverId': widget.selectedUserId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'participants': [widget.currentUserId, widget.selectedUserId],
    });

    _messageController.clear();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendMessage('', File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.4),

      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('conversations')
                  .where('participants', arrayContains: widget.currentUserId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs.where((doc) {
                  return (doc['senderId'] == widget.currentUserId && doc['receiverId'] == widget.selectedUserId) ||
                      (doc['senderId'] == widget.selectedUserId && doc['receiverId'] == widget.currentUserId);
                }).toList();
                return messages.isEmpty?const Center(child: Text("No Conservation Started")) : ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isCurrentUser = message['senderId'] == widget.currentUserId;
                    DateTime timestamp=DateTime.now();
                    if(message['timestamp']!=null){
                       timestamp = (message['timestamp'] as Timestamp).toDate();

                    }
                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.purple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            message['imageUrl'] != null
                                ? Image.network(message['imageUrl'],height: 250,)
                                : Text(
                              message['text'],
                              style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
                            ),
                            SizedBox(height: 5),
                            Text(
                              timeago.format(timestamp),
                              style: TextStyle(
                                color: isCurrentUser ? Colors.white : Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
       Container(
          decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
          BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 2), // changes position of shadow
          ),
          ],
          ),
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
          children: [
          IconButton(
          icon: const Icon(Icons.image),
          onPressed: _pickImage,
          color: Theme.of(context).colorScheme.secondary,
    ),
    Expanded(
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: TextField(
    controller: _messageController,
    decoration: const InputDecoration(
    hintText: 'Type a message',
    border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
    ),
    contentPadding:
    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    ),
    ),
    ),
    ),
    IconButton(
    icon:  Icon(Icons.send),
    onPressed:()=> _sendMessage(_messageController.text),
    color:    Theme.of(context).colorScheme.secondary,

    ),
    ],
    ),
    ),
    )
        ],
      ),
    );
  }
}

