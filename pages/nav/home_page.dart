import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        resizeToAvoidBottomInset: false, backgroundColor: Theme.of(context).colorScheme.tertiary, body: Column());
  }
}
