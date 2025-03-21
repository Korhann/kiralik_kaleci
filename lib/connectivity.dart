import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late InternetConnectionChecker connectionChecker;
  late Stream<InternetConnectionStatus> connectionStream;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    connectionChecker = InternetConnectionChecker.createInstance();
    connectionStream = connectionChecker.onStatusChange;
    connectionStream.listen((status) {
      if (mounted) {
        setState(() {
        hasInternet = status == InternetConnectionStatus.connected;
      });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!hasInternet)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.all(12),
              child: const Center(
                child: Text(
                  'No internet connection',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
