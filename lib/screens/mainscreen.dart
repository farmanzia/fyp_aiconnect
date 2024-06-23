import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp_social_app/community.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:fyp_social_app/components/fab_container.dart';
import 'package:fyp_social_app/pages/reels.dart';
import 'package:fyp_social_app/screens/notification.dart';
import 'package:fyp_social_app/pages/profile.dart';
import 'package:fyp_social_app/pages/search.dart';
import 'package:fyp_social_app/pages/feeds.dart';
import 'package:fyp_social_app/utils/firebase.dart';

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _page = 0;

  List pages = [
    {
      'title': 'Home',
      'icon': Iconsax.home,
      'page': Feeds(),
      'index': 0,
    },
    {
      'title': 'People',
      'icon': Icons.person_2_outlined,
      'page': Search(),
      'index': 1,
    },
    {
      'title': 'unsee',
      'icon': Ionicons.add_circle,
      'page': Text('nes'),
      'index': 2,
    },
    {
      'title': 'Community',
      'icon': Iconsax.people,
      // 'page': WoobleReels(),
      'page': GroupListScreen(),
      'index': 3,
    },
    {
      'title': 'Profile',
      'icon': Iconsax.user,
      'page': Profile(profileId: firebaseAuth.currentUser!.uid),
      'index': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages[_page]['page'],
      ),
      bottomNavigationBar: BottomAppBar(
        // color: Theme.of(context).colorScheme.secondary,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
              // borderRadius: const BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 5),
              for (Map item in pages)
                item['index'] == 2
                    ? buildFab()
                    : Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              child: Icon(
                                item['icon'],
                                color: item['index'] != _page
                                    ? Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black
                                    : Theme.of(context).colorScheme.secondary,
                                size: 25.0,
                              ),
                              onTap: () => navigationTapped(item['index']),
                            ),
                            Text(
                              item['title'],
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                  color: item['index'] != _page
                                      ? Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                          ],
                        ),
                      ),
              SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }

  buildFab() {
    return Container(
      height: 45.0,
      width: 45.0,
      // ignore: missing_required_param
      child: FabContainer(
        icon: Ionicons.add_outline,
        mini: true,
      ),
    );
  }

  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
  }
}
