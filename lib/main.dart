import 'package:flutter/material.dart';
import 'package:tagger/view/host.dart';

import 'view/album/album_page.dart';
import 'view/homepage/homepage.dart';
import 'view/tags_mgmt/tags_mgmt_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Host(),
      // routes: {
      // MyHomePage.routeName: (context) => const MyHomePage(),
      // AlbumPage.routeName: (routeContext) => const AlbumPageWrapper(),
      // TagsMgmtPage.routeName: (context) => const TagsMgmtPage()
      // },
    );
  }
}
