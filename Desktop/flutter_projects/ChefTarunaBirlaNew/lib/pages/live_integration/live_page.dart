import 'dart:io';

import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../widgets/new_youtube_player_page.dart';
import 'live_classes.dart';

class LivePage extends StatefulWidget {
  final String live_id;
  final String user_id;
  final String userName;
  final String url;
  final int liveUserCount;
  const LivePage({
    Key? key,
    required this.live_id,
    required this.user_id,
    required this.url,
    required this.userName,
    this.liveUserCount = 0,
  }) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  final TextEditingController _message = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  String userId = '';
  String userName = '';

  Future<void> createCollection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('user_id') ?? '';
    final savedName = prefs.getString('name') ?? '';
    setState(() {
      userId = savedUserId;
      userName = savedName;
    });
    await _firestore.collection('liveChat').doc(widget.live_id).set({});
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Utility.printLog(_message.text);
      await _firestore
          .collection('liveChat')
          .doc(widget.live_id)
          .collection('chat')
          .add({
        "user_id": userId,
        "message": _message.text,
        "user_name": userName,
        "time": FieldValue.serverTimestamp(),
      });
      _message.text = "";
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      // _insecureScreenDetector.initialize();
      // _insecureScreenDetector.addListener(() {
      //   Utility.printLog('add event listener');
      //   Utility.forceLogoutUser(context);
      //   // Utility.forceLogout(context);
      // }, (isCaptured) {
      //   Utility.printLog('screen recording event listener');
      //   // Utility.forceLogoutUser(context);
      //   // Utility.forceLogout(context);
      //   setState(() {
      //     _isCaptured = isCaptured;
      //   });
      // });
    }
    createCollection();
  }

  void openChatPopup() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.0),
      enableDrag: false,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * (5 / 8),
              color: Colors.black.withOpacity(0.3),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('liveChat')
                          .doc(widget.live_id)
                          .collection('chat')
                          .orderBy("time", descending: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.data != null) {
                          return ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
                                child: Wrap(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Palette.white.withOpacity(0.2),
                                          border: Border.all(
                                              width: 1.0,
                                              color: Palette.white
                                                  .withOpacity(0.5))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data?.docs[index]
                                                  ['user_name'],
                                              style: const TextStyle(
                                                  fontFamily:
                                                      'EuclidCircularA Regular',
                                                  color: Palette.white,
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              snapshot.data?.docs[index]
                                                  ['message'],
                                              style: TextStyle(
                                                  fontFamily:
                                                      'EuclidCircularA Regular',
                                                  color: Palette.white
                                                      .withOpacity(0.8),
                                                  fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  Container(
                    height: 70.0,
                    decoration: const BoxDecoration(color: Palette.black),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Palette.white.withOpacity(0.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Palette.shadowColor.withOpacity(0.1),
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 0.0, //extend the shadow
                                    offset: const Offset(
                                      0.0, // Move to right 10  horizontally
                                      0.0, // Move to bottom 10 Vertically
                                    ),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _message,
                                style: TextStyle(
                                  fontFamily: 'EuclidCircularA Regular',
                                  color: Palette.white.withOpacity(0.8),
                                ),
                                autofocus: false,
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "Type your message..",
                                  hintStyle: TextStyle(
                                    color: Palette.white.withOpacity(0.5),
                                  ),
                                  labelStyle: TextStyle(
                                    color: Palette.white.withOpacity(0.5),
                                  ),
                                  focusColor: Palette.contrastColor,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Palette.white.withOpacity(0.5),
                                        width: 1.3,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Palette.white.withOpacity(0.5),
                                          width: 1.0),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  filled: true,
                                  fillColor: Palette.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              onSendMessage();
                            },
                            child: Container(
                              height: 45.0,
                              width: 45.0,
                              decoration: BoxDecoration(
                                  color: Palette.contrastColor,
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: Center(
                                child: Icon(
                                  MdiIcons.send,
                                  size: 24.0,
                                  color: Palette.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isCaptured
        ? const Center(
            child: Text(
              'You are not allowed to do screen recording',
              style: TextStyle(
                fontFamily: 'EuclidCircularA Regular',
                fontSize: 20.0,
                color: Palette.black,
              ),
              textAlign: TextAlign.center,
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveClasses(),
                ),
              );
              return false;
            },
            child: Scaffold(
              backgroundColor: Palette.black,
              appBar: AppBar(
                title: const Text(''),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Palette.white,
                    size: 18.0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: Palette.black,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      widget.liveUserCount == 0
                          ? ''
                          : '${widget.liveUserCount > 1000 ? ((widget.liveUserCount / 1000).toString() + 'K') : widget.liveUserCount} users',
                      style: const TextStyle(
                        color: Palette.white,
                        fontSize: 16.0,
                        fontFamily: 'EuclidCircularA Regular',
                      ),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child:
                    // Platform.isIOS
                    //     ? IosYoutubePlayerPage(
                    //         url: widget.url,
                    //       )
                    //     :
                    //     LiveYoutubePlayer(
                    //   url: widget.url,
                    // ),
                    NewYoutubePlayerPage(
                  url: widget.url,
                  fullScreen: false,
                ),
                // child: Container(),
              ),
              floatingActionButton: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Palette.contrastColor,
                  border: Border.all(
                    color: Palette.contrastColor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff000000).withOpacity(0.2),
                      blurRadius: 10.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    openChatPopup();
                  },
                  child: Icon(
                    MdiIcons.chat,
                    size: 25.0,
                    color: Palette.white,
                  ),
                  backgroundColor: Palette.contrastColor,
                  elevation: 0.0,
                ),
              ),
            ),
          );
  }
}
