import 'package:flutter/material.dart';
import 'package:stackit/components/my_bottom_navbar.dart';
import 'package:stackit/models/bottom_navbar_key.dart';
import 'package:stackit/pages/nav/home_page.dart';
import 'package:stackit/pages/nav/profile_page.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      HomePage(),
      Container(),
      ProfilePage(),
    ];
  }

  void navigateBottomBar(int index) {
    _selectedIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex.value != 0) {
          BottomNavbarKey.instance.key.currentState?.changeTab(0);
          return false;
        }
        return true;
      },
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            body: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
            bottomNavigationBar: MyBottomNavbar(
              key: BottomNavbarKey.instance.key,
              onTabChange: navigateBottomBar,
            ),
          );
        },
      ),
    );
  }
}
