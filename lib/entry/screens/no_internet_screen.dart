import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:easy_localization/easy_localization.dart';



class NoInternetScreen extends StatefulWidget{
  const NoInternetScreen({super.key});
  
  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();

}


class _NoInternetScreenState extends State<NoInternetScreen>{
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; 
  
  @override
    void initState() {
      super.initState();
      
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results
      ) {
        if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
          _retryConnection();
        }
      });

    }

  
  @override 
  void dispose(){
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _retryConnection(){
    if (mounted) {
      context.go('/');
    }
  }
  
  @override 
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              const Icon(Icons.wifi_off_rounded),
              const SizedBox(height: 24),

              Text(
                "errors.network.no_connection_label".tr(),
                style: Theme.of(context).textTheme.titleMedium
              ),
              const SizedBox(height: 12),
  
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text("auth.retry".tr()),
                onPressed: _retryConnection,
              ),
            ] 
          ) 
        )
      )
    );
  }

}

