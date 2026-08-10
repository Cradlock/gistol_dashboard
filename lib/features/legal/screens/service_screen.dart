import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceScreen extends StatelessWidget{
  const ServiceScreen({super.key}); 
  
  
  Future<String> _loadPolicyText() async {
    return await rootBundle.loadString("assets/docs/service.txt"); 
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(appBar: AppBar(),body: FutureBuilder(
        future: _loadPolicyText(), 
        builder: (BuildContext context,AsyncSnapshot<String> snapshot)  {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError) {
            return Center( 
              child: Text(" ${snapshot.error}"),
            );
          }

          final String text = snapshot.data ?? "No Data";
          return SingleChildScrollView( 
            padding: const EdgeInsets.all(16),
            child: Text(text,style: Theme.of(context).textTheme.bodyMedium)
          );
        } 
      )
      );
    }
}
