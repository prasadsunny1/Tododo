import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('Theme'),
                subtitle: Text('Light'),
                trailing: Icon(Icons.chevron_right),
                leading: Icon(Icons.brightness_medium),
                onTap: (){
                  //let user change theme of the app
                },
              ),
              ListTile(
                title: Text('Sound'),
                subtitle: Text('Birds'),
                trailing: Icon(Icons.chevron_right),
                leading: Icon(Icons.music_note),
                onTap: (){
                  //let user change theme of the app
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
