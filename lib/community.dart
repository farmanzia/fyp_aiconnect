import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp_social_app/utils/firebase.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class GroupListScreen extends StatefulWidget {
  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final String currentUserId = firebaseAuth.currentUser!.uid;
  bool isAiExpert = false;
  String score='0';
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
        setState(() {
          
        });
      });
    }
  }
  @override
  void initState() {
    isUserAiExpert();
    // TODO: implement initState
    super.initState();
  }
 // Replace with actual current user ID
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
        title: const Text(
          "Community",
          style:  TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final groups = snapshot.data!.docs;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(groups[index]['name']),
                    subtitle: Row(
                      children: _buildMemberAvatars(groups[index]['members']),
                    ),
                    leading: groups[index]['image_url'] != ''
                        ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(groups[index]['image_url']))
                        : const Icon(Icons.group),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GroupMessages(groupId: groups[index].id)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:  (isAiExpert==true && int.parse(score.toString())>=7)? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectGroupImage()),
          );
        },
        child: const Icon(Icons.add),
      ):null,
    );
  }

  List<Widget> _buildMemberAvatars(List<dynamic> members) {
    List<Widget> avatars = [];

    for (int i = 0; i < (members.length > 3 ? 3 : members.length); i++) {
      avatars.add(
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(members[i]).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircleAvatar(child: Icon(Icons.person));
            }
            final user = snapshot.data!;
            final userName = user['username'] as String;
            return Text("$userName, ");
          },
        ),
      );
    }

    if (members.length > 3) {
      avatars.add(
        Text('+${members.length - 3}'),
      );
    }

    return avatars;
  }
}

class SelectGroupImage extends StatefulWidget {
  @override
  _SelectGroupImageState createState() => _SelectGroupImageState();
}

class _SelectGroupImageState extends State<SelectGroupImage> {
  XFile? _image;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Group Image')),
      body: Center(
        child: Column(
          children: [
            _image != null
                ? Image.file(File(_image!.path))
                : const Text('No image selected'),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnterGroupName(image: _image)),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class EnterGroupName extends StatelessWidget {
  final XFile? image;

  EnterGroupName({required this.image});

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Group Name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectUsers(image: image, groupName: _nameController.text)),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectUsers extends StatefulWidget {
  final XFile? image;
  final String groupName;

  SelectUsers({required this.image, required this.groupName});

  @override
  _SelectUsersState createState() => _SelectUsersState();
}

class _SelectUsersState extends State<SelectUsers> {
  List<String> selectedUserIds = [];
  final String currentUserId = firebaseAuth.currentUser!.uid; // Replace with actual current user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(currentUserId)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(users[index]['username']),
                subtitle: Text(users[index]['email']),
                trailing: Checkbox(
                  value: selectedUserIds.contains(users[index].id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedUserIds.add(users[index].id);
                      } else {
                        selectedUserIds.remove(users[index].id);
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedUserIds.isNotEmpty) {
            selectedUserIds.add(currentUserId); // Add the current user to the group
            final groupId = await createGroup(widget.image, widget.groupName, selectedUserIds);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroupMessages(groupId: groupId)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one user.')));
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

Future<String> createGroup(XFile? image, String groupName, List<String> userIds) async {
  String imageUrl = '';
  if (image != null) {
    final storageRef = FirebaseStorage.instance.ref().child('group_images/${image.name}');
    await storageRef.putFile(File(image.path));
    imageUrl = await storageRef.getDownloadURL();
  }

  final groupRef = FirebaseFirestore.instance.collection('groups').doc();
  await groupRef.set({
    'name': groupName,
    'image_url': imageUrl,
    'members': userIds,
    'created_at': FieldValue.serverTimestamp(),
  });

  return groupRef.id;
}

class GroupPosts extends StatelessWidget {
  final String groupId;

  GroupPosts({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Posts')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final group = snapshot.data!;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('groups').doc(group.id).collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final posts = snapshot.data!.docs;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(posts[index]['content']),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new post
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupMessages extends StatefulWidget {
  final String groupId;

  GroupMessages({required this.groupId});

  @override
  _GroupMessagesState createState() => _GroupMessagesState();
}

class _GroupMessagesState extends State<GroupMessages> {
  final TextEditingController _messageController = TextEditingController();
  XFile? _image;
  final String currentUserId = firebaseAuth.currentUser!.uid; // Replace with actual current user ID

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedImage;
    });
  }

  Future<void> sendMessage(String groupId, String message, String imageUrl) async {
    if (message.isNotEmpty || imageUrl.isNotEmpty) {
      final messageRef = FirebaseFirestore.instance.collection('groups').doc(groupId).collection('messages').doc();
      await messageRef.set({
        'content': message,
        'image_url': imageUrl,
        'sender_id': currentUserId,
        'created_at': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      setState(() {
        _image = null;
      });
    }
  }
  bool isAiExpert = false;
  String score='0';
  isUsAiExpert(){
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
  void initState() {
    // TODO: implement initState
    super.initState();
    isUsAiExpert();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
        title: const Text(
          'Community Conversation',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('messages').orderBy('created_at').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message['sender_id'] == currentUserId;
                      return Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Card(
                          color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message['image_url'] != '')
                                  Image.network(message['image_url']),
                                if (message['content'] != '')
                                  Text(message['content']),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_image != null)
              Image.file(File(_image!.path)),
           if( isAiExpert==true && int.parse(score.toString())>=7)  Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(labelText: 'Message'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      String imageUrl = '';
                      if (_image != null) {
                        final storageRef = FirebaseStorage.instance.ref().child('message_images/${_image!.name}');
                        await storageRef.putFile(File(_image!.path));
                        imageUrl = await storageRef.getDownloadURL();
                      }
                      sendMessage(widget.groupId, _messageController.text, imageUrl);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
