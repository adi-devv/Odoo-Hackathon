import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:stackit/main.dart';
import 'package:stackit/pages/nav/post_question_page.dart';
import 'package:stackit/services/data/user_data_service.dart';
import 'package:stackit/components/utils.dart';
import 'package:flutter/services.dart';

class MyBottomNavbar extends StatefulWidget {
  final void Function(int) onTabChange;

  const MyBottomNavbar({
    super.key,
    required this.onTabChange,
  });

  @override
  MyBottomNavbarState createState() => MyBottomNavbarState();
}

class MyBottomNavbarState extends State<MyBottomNavbar> {
  int _selectedIndex = 0;
  bool _unread = false;

  void changeTab(int index) {
    _onTabChange(index);
  }

  int getIndex() {
    return _selectedIndex;
  }

  void _onTabChange(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
    widget.onTabChange(index);
  }

  void toggleUnread(bool val) {
    if (mounted) {
      setState(() => _unread = val);
    }
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                CupertinoIcons.app_badge_fill,
                "Sell An Item",
                "Post an item you want to sell",
                context,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostQuestionPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    String description,
    BuildContext context,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GNav(
        padding: const EdgeInsets.symmetric(vertical: 10),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        selectedIndex: _selectedIndex,
        color: Theme.of(context).colorScheme.onPrimary,
        activeColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tabBorderRadius: 16,
        onTabChange: (index) async {
          if (index == 2) {
            _showCreateOptions(context);
          } else {
            _onTabChange(index);
          }
        },
        tabs: [
          GButton(
            icon: _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
            iconSize: 30,
            iconColor: Theme.of(context).colorScheme.onPrimary,
            iconActiveColor: Theme.of(context).colorScheme.onPrimary,
          ),
          GButton(
            icon: CupertinoIcons.pen,
            iconSize: 35,
            iconColor: Color(0xFF00C1A2),
            iconActiveColor: Color(0xFF00C1A2),
          ),
          GButton(
            icon: _selectedIndex == 4 ? Icons.person : Icons.person_outline,
            iconSize: 28,
            iconColor: Theme.of(context).colorScheme.onPrimary,
            iconActiveColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
