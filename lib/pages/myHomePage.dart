import 'package:flutter/material.dart';
import 'package:geminitest/pages/text_only_Page.dart';
import 'package:geminitest/pages/text_with_image_Page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Text only'),
    Tab(text: 'Texto with image'),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: myTabs.length, initialIndex: 0,
    child: Scaffold(appBar: AppBar(title:const Text("Gemini Test"), bottom:  const TabBar(tabs: myTabs),
    ),
    body: TabBarView(children: [TextOnlyPage(), TextWithImagePage()]),
    ),
    );
  }
}