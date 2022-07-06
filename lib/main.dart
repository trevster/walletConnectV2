
import 'package:connect_wallet_v2/features/home_page/home_page.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Wallet App'),
    );
  }
}
