import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raven_swift/models/user.dart';
import 'package:raven_swift/pages/edit_profile.dart';
import 'package:raven_swift/pages/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raven_swift/widgets/post.dart';
import 'package:raven_swift/widgets/post_tile.dart';
import 'package:raven_swift/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  String postOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];


  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

   headerProfile(context,
      {bool isAppTitle = false, String titleText, removeBackButton = false}) {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return AppBar(
        elevation: 20,
        automaticallyImplyLeading: removeBackButton ? false : true,
        actionsIconTheme: IconThemeData(
            size: 30.0,
            color: Colors.white,
            opacity: 1.0
        ),

        title: Text(
          "Profile",
          style:
          GoogleFonts.copse(fontStyle: FontStyle.normal,
              color: Colors.white,
              fontWeight: isAppTitle ? FontWeight.bold : FontWeight.normal,
              fontSize: 30),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        brightness: Brightness.light,
        actions: <Widget>[

          IconButton(
              onPressed: () {
                editProfile();
              },
              icon: Icon(Icons.settings,
                  color: Colors.white
              )
          )
        ],
      );
    } else {
      return AppBar(
        automaticallyImplyLeading: removeBackButton ? false : true,
        actionsIconTheme: IconThemeData(
            size: 30.0,
            color: Colors.white,
            opacity: 1.0
        ),

        title: Text(
          "Profile",
          style:
          GoogleFonts.copse(fontStyle: FontStyle.normal,
              color: Colors.white,
              fontWeight: isAppTitle ? FontWeight.bold : FontWeight.normal,
              fontSize: 30),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        brightness: Brightness.light,

      );
    }
  }


  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildProfileHeader(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgressSecond();
          }
          User user = User.fromDocument(snapshot.data);
          return Container(
            child: Column(
              children: [
                Container(
                  //padding: EdgeInsets.all(16.0),
                  height: queryData.size.height /3,
                  child: Stack(
                    children: [
                      Positioned(
                        child: Container(
                          width: queryData.size.width,
                          height: queryData.size.height/4,
                          //color: Colors.black,
                          decoration: BoxDecoration(
                            //color: Colors.black,
                              image: DecorationImage(
                                  image: AssetImage('assets/images/Vector-peacock.jpg'),
                                  fit: BoxFit.fitWidth,
                                  //scale: 4
                              )
                          ),
                        ),
                      ),
                      Center(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: queryData.size.height /5,
                            width: queryData.size.width/3,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(user.photoUrl),
                                    fit: BoxFit.fill
                                ),
                                border: Border.all(
                                    color: Colors.white,
                                    width: 5)
                            ),
                          ),
                        ),
                      )
                    ],
                  ),


/*
                  child: Column(
                    children: <Widget>[
                      Container(

                        height: queryData.size.height/12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.redAccent.withOpacity(0.5),
                              width: 2
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: IconButton(
                                onPressed: () {},
                                padding: EdgeInsets.only(left: 6),
                                icon: Icon(Icons.person_add, color: Colors.black, size: 25),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                user.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: IconButton(
                                onPressed: () {},
                                padding: EdgeInsets.only(left: 6),
                                icon: Icon(Icons.message, color: Colors.black, size: 25),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: queryData.size.width - 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[

                                Container(
                                  height: queryData.size.height /10,
                                  width: queryData.size.width/6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),

                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(followerCount.toString(), style: TextStyle(
                                            fontSize: 35, fontWeight: FontWeight.bold
                                        ),),
                                        SizedBox(height: 5,),

                                        Text("Followers", style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ))
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10,),

                                Container(
                                  height: queryData.size.height /10,
                                  width: queryData.size.width/6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.5),
                                      width: 2)
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text("Zodiac")
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            Container(
                              height: queryData.size.height /5,
                              width: queryData.size.width/3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(user.photoUrl),
                                  fit: BoxFit.fill
                                ),
                                border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.5),
                                    width: 2)
                              ),
                            ),
                            Column(
                              children: <Widget>[

                                Container(
                                  height: queryData.size.height /10,
                                  width: queryData.size.width/6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),

                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(followingCount.toString(), style: TextStyle(
                                            fontSize: 35, fontWeight: FontWeight.bold
                                        ),),
                                        SizedBox(height: 5,),

                                        Text("Following", style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ))
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10,),

                                Container(
                                  height: queryData.size.height /10,
                                  width: queryData.size.width/6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black,

                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      */
/*Row(
                        children: <Widget>[

                          CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    buildCountColumn("posts", postCount),
                                    buildCountColumn("followers", followerCount),
                                    buildCountColumn("following", followingCount),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    buildProfileButton(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          user.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 2.0),
                        child: Text(
                          user.bio,
                        ),
                      ),*//*

                    ],
                  ),
*/
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: queryData.size.height /10,
                      width: queryData.size.width/6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(followerCount.toString(), style: TextStyle(
                                fontSize: 35, fontWeight: FontWeight.bold
                            ),),
                            SizedBox(height: 5,),

                            Text("Followers", style: TextStyle(
                                fontWeight: FontWeight.bold
                            ))
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: queryData.size.height /10,
                      width: queryData.size.width/6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(followingCount.toString(), style: TextStyle(
                                fontSize: 35, fontWeight: FontWeight.bold
                            ),),
                            SizedBox(height: 5,),

                            Text("Following", style: TextStyle(
                                fontWeight: FontWeight.bold
                            ))
                          ],
                        ),
                      ),
                    ),

                  ],
                )
              ],
            ),
          );
        });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgressMain();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerProfile(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(context),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
