import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class ConnectivityMonitor extends StatefulWidget {
  final Widget child;

  const ConnectivityMonitor({super.key, required this.child});

  @override
  State<ConnectivityMonitor> createState() => _ConnectivityMonitorState();
}

class _ConnectivityMonitorState extends State<ConnectivityMonitor> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final newIsConnected = !result.contains(ConnectivityResult.none);

    // If the connection was previously lost and is now back online...
    if (newIsConnected && !_isConnected) {
      // Show a helpful message and refetch the data from Supabase.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: const Text("You're back online. Syncing data..."),
          backgroundColor: Colors.green[600],
        ),
      );
      Provider.of<ExpenseProvider>(context, listen: false).fetchInitialData();
    }

    setState(() {
      _isConnected = newIsConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Your main application content, which is always present
        widget.child,
        // The "No Internet" overlay, shown only when not connected
        if (!_isConnected)
          Positioned.fill(
            // The Directionality and Material widgets are placed inside to fix the errors.
            child: Directionality(
              textDirection:
                  Directionality.maybeOf(context) ?? TextDirection.ltr,
              // Wrapping the Container with a Material widget provides the necessary context for Text widgets to render correctly.
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  color: Colors.black.withAlpha(180),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 40,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No Internet Connection',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Please check your network settings and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
