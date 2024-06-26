import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_social_app/components/custom_video_player.dart';
import 'package:fyp_social_app/questionaire/questionaire.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:fyp_social_app/components/custom_image.dart';
import 'package:fyp_social_app/models/user.dart';
import 'package:fyp_social_app/utils/constants.dart';
import 'package:fyp_social_app/utils/firebase.dart';
import 'package:fyp_social_app/view_models/auth/posts_view_model.dart';
import 'package:fyp_social_app/widgets/indicators.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
bool isAiExpert=false;
bool isLoading=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUserAiExpert();
  }

  @override
  Widget build(BuildContext context) {



    currentUserId() {
      return firebaseAuth.currentUser!.uid;
    }

    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    return
    WillPopScope(
      onWillPop: () async {
        await viewModel.resetPost();
        return true;
      },
      child: isAiExpert==false?QuizScreen(): LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Ionicons.close_outline),
              onPressed: () {
                viewModel.resetPost();
                Navigator.pop(context);
              },
            ),
            title: Text(
              Constants.appName,
              style: const TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {

                  await viewModel.uploadPosts(context);
                  // Navigator.pop(context);
                  // viewModel.resetPost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Post'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            children: [
              const SizedBox(height: 15.0),
              StreamBuilder(
                stream: usersRef.doc(currentUserId()).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(
                      snapshot.data!.data() as Map<String, dynamic>,
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        backgroundImage:   NetworkImage(user.photoUrl!),
                        child: user.photoUrl!.isEmpty ?Text(user.username!.substring(0,1).toUpperCase()):null,
                      ),
                      title: Text(
                        user.username!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        user.email!,
                      ),
                    );
                  }
                  return Container();
                },
              ),
              InkWell(
                // onTap: () => showImageChoices(context, viewModel),
                onTap: () => showMediaChoices(context, viewModel),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  decoration: Theme.of(context).brightness == Brightness.dark
                      ? BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              offset: const Offset(-6.0, -6.0),
                              blurRadius: 16.0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(6.0, 6.0),
                              blurRadius: 16.0,
                            ),
                          ],
                          color: const Color(0xff2B2B2B),
                          borderRadius: BorderRadius.circular(12.0),
                        )
                      : BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(-6.0, -6.0),
                              blurRadius: 16.0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(6.0, 6.0),
                              blurRadius: 16.0,
                            ),
                          ],
                          color: const Color(0xFFEFEEEE),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                  child: viewModel.imgLink != null
                      ? CustomImage(
                          imageUrl: viewModel.imgLink,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.cover,
                        )
                      : viewModel.mediaUrl == null && viewModel.video==null
                          ? Center(
                              child: Text(
                                'Add an Media',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            )
                          :
                  viewModel.mediaUrl != null?

                  Image.file(
                              viewModel.mediaUrl!,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width - 30,
                              fit: BoxFit.cover,
                            ): MiniVideoPlayer(
                    autoPlay: true,
                    videoUrl: viewModel.video?.path ?? "",
                    fromNetwork: false,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - 30,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Post Something',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: const InputDecoration(
                  hintText: 'Write here',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setDescription(val),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
  showImageChoices(BuildContext context, PostsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Select Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Ionicons.camera_outline),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(camera: true);
                },
              ),
              ListTile(
                leading: const Icon(Ionicons.image),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  isUserAiExpert(){
    if(firebaseAuth.currentUser?.uid!=null){
      firestore.collection("users").doc(firebaseAuth.currentUser?.uid).get().then((value){
        log("============ value['isAiExpert'] ${value['isAiExpert']}");
        if(value['isAiExpert']==false){
          isAiExpert=false;
          // Navigator.of(context).pushReplacement(
          //   CupertinoPageRoute(
          //     builder: (_) => QuizScreen(),
          //   ),
          // );
        }
        else{
          isAiExpert=true;
        }
        setState(() {

        });
      });
    }

    log("============ value[''] ${isAiExpert}");
  }
showMediaChoices(BuildContext context, PostsViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: .6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Select Media',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Ionicons.camera_outline),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImage(camera: true);
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.image),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImage(camera: false);              },
            ),
            ListTile(
              leading: const Icon(Ionicons.videocam_outline),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickVideo(context: context, camera: false);              },
            ),
          ],
        ),
      );
    },
  );
}

}
