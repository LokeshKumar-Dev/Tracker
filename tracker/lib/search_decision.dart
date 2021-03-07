import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'screen/auth_screen/auth_screen-L.dart';
import 'screen/searchResult_screen.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/search';

  @override
  Widget build(BuildContext context) {
    print('SearchScreen SearchResultScreen');
    return Consumer<Auth>(
      builder: (ctx, auth, _) =>
          auth.searchIsAuth ? SearchResultScreen() : AuthScreenLogin(true),
    );
  }
}
