import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stackit/components/my_drawer.dart';
import 'package:stackit/pages/nav/post_question_page.dart';
import 'package:stackit/services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool status = false;

  @override
  void initState() {
    super.initState();
    print("HOME PAGE INIT");
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _getStatus() async {
    status = await AuthService().getStatus();
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('StackIt'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Welcome to My App!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostQuestionPage(),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        icon: const Icon(Icons.edit_note),
        // Your icon
        label: const Text('Ask new question'), // Your text
      ),
    );
  }
}
