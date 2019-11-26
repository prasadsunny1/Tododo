import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tododo/theme_bloc.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeBloc themeBloc = Provider.of<ThemeBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Theme'),
              subtitle: Text(EnumToString.parse(themeBloc.currentTheme)),
              trailing: Icon(Icons.chevron_right),
              leading: Icon(Icons.brightness_medium),
              onTap: () {
                //let user change theme of the app
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  child: AlertDialog(
                    title: Text('Select a Theme'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: AppTheme.values
                          .map(
                            (item) => ListTile(
                              title: Text(EnumToString.parse(item)),
                              onTap: () {
                                themeBloc.switchTheme(item);
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Sound'),
              subtitle: Text('Birds'),
              trailing: Icon(Icons.chevron_right),
              leading: Icon(Icons.music_note),
              onTap: () {
                //let user change theme of the app
              },
            )
          ],
        ),
      ),
    );
  }
}
