import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raven_swift/models/user.dart';
import 'package:raven_swift/pages/activity_feed.dart';
import 'package:raven_swift/pages/create_account.dart';
import 'package:raven_swift/pages/profile.dart';
import 'package:raven_swift/pages/search.dart';
import 'package:raven_swift/pages/timeline.dart';
import 'package:raven_swift/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';



final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  final _formkey = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool _obscureText = true;


  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  } //email verification

  void _toggle() {
    setState(() {
      _obscureText =!_obscureText;
      print("inside toggle");
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef
          .document(user.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
                body,
                overflow: TextOverflow.ellipsis,
              ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });
      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .document(user.id)
          .collection('userFollowers')
          .document(user.id)
          .setData({});

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
    print("inside login");
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(
      pageIndex,
    );
  }

  Scaffold buildAuthScreen() {
    //MediaQueryData queryData = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          Search(),
          Upload(currentUser: currentUser),
          ActivityFeed(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
          index: pageIndex,
          onTap: onTap,
          height: 50.0,
        //activeColor: Theme.of(context).primaryColor,
          items: [
            FaIcon(FontAwesomeIcons.home, size: 25, color: Colors.white,),
            FaIcon(FontAwesomeIcons.search, size: 25, color: Colors.white,),
            FaIcon(FontAwesomeIcons.feather, size: 25, color: Colors.white,),
            FaIcon(FontAwesomeIcons.bell, size: 25, color: Colors.white,),
            Icon(Icons.perm_identity, size: 30, color: Colors.white,),
          ],
        color: Colors.redAccent,
        buttonBackgroundColor: Colors.redAccent,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 400),),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildUnAuthScreen() {
    MediaQueryData queryData = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,

      body: SafeArea(
        child: Container(
          height: queryData.size.height,
          width: queryData.size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background1.jpg'),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.topLeft,
                  colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.35), BlendMode.dstATop)
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: queryData.size.height/2.5,
                    color: Colors.transparent,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          right: 40,
                          top: 18,
                          width: 330,
                          height: queryData.size.height/2.67,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/organic_red.png'),
                                )
                            ),
                          ),
                        ),
                        Positioned(
                            left: 20,
                            top: 20,
                            width: 400,
                            height: queryData.size.height/2.67,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/organic_blue.png'),
                                  )
                              ),
                            )
                        ),
                        Positioned(
                            left: 0,
                            top: 30,
                            width: 420,
                            height: queryData.size.height/2.76,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/peacock_feather.png'),
                                  )
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 25,),
                  Container(
                      width: queryData.size.width - 68,
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (val) {
                                if(val.isEmpty)
                                  return 'Empty';
                                if(validateEmail(val) == false )
                                  return 'Enter a valid Email Address';
                                return null;
                              },
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black54
                              ),
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    color: Colors.black45
                                ),
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                            ),

                            SizedBox(height: 5,),

                            TextFormField(
                              controller: passwordController,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black54
                              ),
                              validator: (val){
                                if(val.isEmpty)
                                  return 'Empty';
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(
                                  color: Colors.black45,
                                ),
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _toggle();
                                    print("this is working");
                                  },

                                  padding: EdgeInsets.only(left: 6),
                                  icon: Icon(Icons.remove_red_eye),
                                ),
                              ),
                              obscureText: _obscureText,

                            ),
                            SizedBox(height:22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  /*onTap: () async {
                                    if(_formkey.currentState.validate()){
                                      setState(() {
                                        loading = true;
                                      });
                                      dynamic result = await _auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
                                      FirebaseUser  user = result.user;
                                      if(user.isEmailVerified) {
                                        if(result == null){

                                          setState(() => error = 'Wrong Email-Address or Password');
                                          print(error);
                                          loading = false;
                                        }
                                      } else {
                                        await _auth.signOut();
                                      }


                                    }
                                  },*/
                                  child: Container(
                                    height: 35,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.deepPurple,
                                              Colors.blue
                                            ]
                                        )
                                    ),
                                    child: Center(
                                        child: RichText(text: TextSpan(text: "Sign In   ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            children: [WidgetSpan(child: FaIcon(FontAwesomeIcons.locationArrow, color: Colors.white, size: 15,), alignment: PlaceholderAlignment.middle),
                                            ]), )
                                    ),
                                  ),
                                ),
                                Text("Forgot Password?", textAlign: TextAlign.right, style: TextStyle(
                                    color: Colors.purple, fontSize: 15.5, decoration: TextDecoration.underline
                                ),),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                //Text(error, style: TextStyle(fontSize: 13, color: Colors.redAccent), textAlign: TextAlign.left,),
                              ],
                            )
                          ],
                        ),
                      )
                  ),


                ],
              ),


              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Container(
                    width: queryData.size.width - 33,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: login,
                          child: Container(
                            height: 45,
                            width: queryData.size.width - 230,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.pink
                                    ]
                                )
                            ),
                            child: Center(
                                child: RichText(text: TextSpan(text: "Login with Google   ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    children: [WidgetSpan(child: FaIcon(FontAwesomeIcons.google, color: Colors.white,), alignment: PlaceholderAlignment.middle),
                                    ]), )
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            height: 45,
                            width: queryData.size.width - 230,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.pink
                                    ]
                                )
                            ),
                            child: Center(
                                child: RichText(text: TextSpan(text: "Login with Phone Number   ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,),
                                    children: [WidgetSpan(child: FaIcon(FontAwesomeIcons.phone, color: Colors.white,), alignment: PlaceholderAlignment.middle),
                                    ]), )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ", style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 13,
                        ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                              //recognizer: _signUp,
                            ),

                          ],

                        ),


                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}