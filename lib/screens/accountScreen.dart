import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterfire_wallpaper_app/screens/walpaperScreen.dart';

import 'addWallpaperScreen.dart';

class AccPage extends StatefulWidget {
  const AccPage({Key? key}) : super(key: key);

  @override
  _AccPageState createState() => _AccPageState();
}

class _AccPageState extends State<AccPage> {
  User? _user;

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void fetchUserData() async {
    User? u = _firebaseAuth.currentUser;
    setState(() {
      _user = u;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _user != null
          ? SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      height: _deviceHeight * 0.06,
                    ),
                    Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FadeInImage(
                      width: 200,
                      height: 200,
                      image: NetworkImage((_user!.photoURL).toString()),
                      placeholder: AssetImage('assets/bg.png'),
                    ),
                    FittedBox(
                      child: Text(
                        _user!.displayName.toString(),
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.power_settings_new),
                        label: Text('Sign Out'),
                        onPressed: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('My Wallpapers'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddWalpaperScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder(
                      stream: _firebaseFirestore
                          .collection('wallpapers')
                          .where('uploadedBy', isEqualTo: _user!.uid)
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapShot) {
                        if (snapShot.hasData) {
                          return StaggeredGridView.countBuilder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(15),
                            crossAxisCount: 4,
                            itemCount: snapShot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) =>
                                InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WallpaperScreen(
                                        snapShot.data!.docs[index].get('url')),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: snapShot.data!.docs[index].id,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: snapShot.data!.docs[index]
                                            .get('url'),
                                        placeholder: (context, url) => Image(
                                          image: AssetImage('assets/bg.png'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Delete Wallpaper ?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                _firebaseFirestore
                                                    .collection('wallpapers')
                                                    .doc(snapShot
                                                        .data!.docs[index].id)
                                                    .delete();

                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            staggeredTileBuilder: (int index) =>
                                StaggeredTile.fit(2),
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                          );
                        }
                        return Align(
                          alignment: Alignment.center,
                          child: LinearProgressIndicator(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : LinearProgressIndicator(),
    );
  }
}

// Container(
//                       padding: EdgeInsets.symmetric(horizontal: 50),
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon: Icon(Icons.add),
//                         label: Text('Add Walpaper'),
//                         onPressed: () {},
//                       ),
//                     ),
//                     SizedBox(height: _deviceHeight * 0.025),
//                     Container(
//                       height: _deviceHeight * 0.3,
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         scrollDirection: Axis.horizontal,
//                         itemCount: 5,
//                         itemBuilder: (ctx, i) => FadeInImage(
//                           width: 155,
//                           image: AssetImage('assets/bg.png'),
//                           placeholder: AssetImage('assets/bg.png'),
//                         ),
//                       ),
//                     ),
