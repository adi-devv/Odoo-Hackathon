import 'package:flutter/material.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  AppLifecycleHandlerState createState() => AppLifecycleHandlerState();
}

class AppLifecycleHandlerState extends State<AppLifecycleHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() async {
      // await ();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
