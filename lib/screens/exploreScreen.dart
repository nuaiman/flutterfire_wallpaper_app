import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterfire_wallpaper_app/screens/walpaperScreen.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // var _images = [
  //   'https://images.pexels.com/photos/5686647/pexels-photo-5686647.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'https://images.pexels.com/photos/4558743/pexels-photo-4558743.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'https://images.pexels.com/photos/5114907/pexels-photo-5114907.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'https://images.pexels.com/photos/1906794/pexels-photo-1906794.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'https://images.pexels.com/photos/8412190/pexels-photo-8412190.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'https://images.pexels.com/photos/6100565/pexels-photo-6100565.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'https://images.pexels.com/photos/4338501/pexels-photo-4338501.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  // ];

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _deviceHeight * 0.06,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Text(
                'Explore',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder(
              stream: _firebaseFirestore
                  .collection('wallpapers')
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
                    itemBuilder: (BuildContext context, int index) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WallpaperScreen(
                                snapShot.data!.docs[index].get('url')),
                          ),
                        );
                      },
                      child: Hero(
                        tag: snapShot.data!.docs[index].id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: snapShot.data!.docs[index].get('url'),
                            placeholder: (context, url) => Image(
                              image: AssetImage('assets/bg.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
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
    );
  }
}
