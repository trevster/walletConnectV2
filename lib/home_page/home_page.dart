import 'package:connect_wallet_v2/camera_qr_view.dart';
import 'package:connect_wallet_v2/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> accounts = [
    'eip155:42:0xab16a96d359ec27z11e2c2b3d8f8b8942d5bfcdb',
    'eip155:42:0xab16a96d359ec28e11e2c2b3d8f8b8942d5bfcdb'
  ];
  static const platformChannel = MethodChannel('WalletConnectMethodChannel');

  late TextEditingController _textEditingController;
  String? barcodeRawString;
  String? sessionExpiryString;

  dynamic methods;
  dynamic sessionExpiry;

  @override
  void initState() {
    super.initState();
    onListenEvents();
    _textEditingController = TextEditingController();
  }

  void onListenEvents() {
    platformChannel.setMethodCallHandler((call) async {
      if (call.method == 'sessionProposal') {
        if (call.arguments == null) {
          showSnackBar(text: 'No data received');
          return;
        }
        if (kDebugMode) {
          print("flutter do: sessionProposal");
        }
        methods = call.arguments;
        sessionProposal(call.arguments);
      }
      if (call.method == 'sessionRequest') {
        if (kDebugMode) {
          print("flutter do: sessionRequest");
        }
      }
      if (call.method == 'deletedSession') {
        if (kDebugMode) {
          print("flutter do: deletedSession");
        }
        setState(() {
          methods = null;
          sessionExpiry = null;
        });
      }
      if (call.method == 'settleSessionResponse') {
        if (kDebugMode) {
          print("flutter do: settleSessionResponse");
        }

          setState(() {
            sessionExpiry = call.arguments;
          });

        try{
          final sessionExpiryInt = int.parse(sessionExpiry.toString());
          sessionExpiryString = DateTime.fromMillisecondsSinceEpoch(sessionExpiryInt * 1000).toLocal().toString();
        } catch (e){
          if (kDebugMode) {
            print("fail parse: sessionExpiryString");
          }
        }

        showSnackBar(text: 'Approve success', color: Colors.green);
      }
      if (call.method == 'sessionUpdateResponse') {
        if (kDebugMode) {
          print("flutter do: sessionUpdateResponse");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextButton(
                  child: const Text('Scan QR Code'),
                  onPressed: () async {
                    barcodeRawString = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CameraQrView()),
                    );
                    if (barcodeRawString == null) showSnackBar();
                    pairWithDapp(barcodeRawString!.substring(3));
                  },
                ),
                TextFormField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    label: const Text('Input WC Uri Code'),
                    suffix: TextButton(
                      child: const Text('Connect'),
                      onPressed: () {
                        if (_textEditingController.text.isEmpty) return;
                        if (_textEditingController.text.startsWith('wc', 0) ==
                            false) {
                          showSnackBar(text: 'Code not recognized');
                          return;
                        }
                        pairWithDapp(_textEditingController.text);
                      },
                    ),
                  ),
                ),
                if (sessionExpiry != null)
                  SizedBox(
                    child: Column(
                      children: [
                        const SizedBox(height: 50,),
                        const Text('Current Paired Accounts', style: TextStyle(fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10,),
                        ListTile(
                          title: const Text('Accounts'),
                          subtitle: Text(accounts.toString()),
                        ),
                        ListTile(
                          title: const Text('Methods'),
                          subtitle: Text(methods.toString()),
                        ),
                        ListTile(
                          title: const Text('Expiry'),
                          subtitle: Text(sessionExpiryString ?? sessionExpiry.toString()),
                        ),
                        TextButton(
                          onPressed: disconnect,
                          child: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar({String? text, Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text ?? 'Barcode scan failed'),
      backgroundColor: color,
    ));
  }

  Widget alertDialogCustom({
    String? title,
    Widget? content,
    void Function()? approve,
    void Function()? reject,
  }) {
    return AlertDialog(
      title: Text(title ?? 'Request'),
      content: content ?? Container(),
      actions: [
        TextButton(
          onPressed: approve ?? () {},
          child: const Text(
            'Approve',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        TextButton(
          onPressed: reject ?? () {},
          child: const Text(
            'Reject',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void pairWithDapp(String value) async {
    dynamic result;
    try {
      result = await platformChannel.invokeMethod("pairWallet", value);
    } catch (e) {
      if (kDebugMode) {
        print('Catch invokeMethod pair wallet, message: $e');
      }
      showSnackBar(text: 'Pair with Dapp failed');
      return;
    }
    if (result == null) showSnackBar(text: 'Pair with Dapp failed');
    final resultModel = SettledPairing.fromJson(result);
    showSnackBar(text: 'Success pair ${resultModel.topic}');
  }

  void sessionProposal(dynamic value) {
    // final SessionProposal sessionProposal = SessionProposal.fromJson(json);

    final List<Widget> checkBoxListTile = [];
    final Map<String, bool> accountsBool = {};

    for (int i = 0; i < 2; i++) {
      accountsBool.addEntries({accounts[i]: false}.entries);
      checkBoxListTile.add(
        StatefulBuilder(builder: (context, setState) {
          return CheckboxListTile(
              title: Text(accounts[i]),
              value: accountsBool[accounts[i]],
              onChanged: (bool? value) {
                setState(() {
                  accountsBool[accounts[i]] = value!;
                  if (kDebugMode) {
                    print("tapped ${accounts[i]} : $value");
                  }
                });
              });
        }),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (context, setState) {
            return alertDialogCustom(
              title: 'Session Proposal',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Methods', style: TextStyle(fontWeight: FontWeight.bold),),
                      const SizedBox(height: 5,),
                      Text(value.toString()),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  const Text('Choose Accounts', style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 5,),
                  ...checkBoxListTile,
                  if(errorMessage != null)
                    const Text('Choose Accounts', style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              approve: () {
                accountsBool
                    .removeWhere((String key, bool value) => value == false);
                if(accountsBool.keys.toList().isEmpty){
                  setState(() {
                    errorMessage = 'Please choose an account';
                  });
                  Future.delayed(const Duration(seconds: 2)).then((value) => setState((){errorMessage = null;}));
                  return;
                }
                approveAccounts(accountsBool.keys.toList());
                Navigator.of(context).pop();
              },
              reject: () {
                reject();
                Navigator.of(context).pop();
              },
            );
          }
        );
      },
    );
  }

  void approveAccounts(List<String> value) async {
    try {
      platformChannel.invokeMethod("approveSession", value);
    } catch (e) {
      if (kDebugMode) {
        print('Catch invokeMethod approveSession, message: $e');
      }
      showSnackBar(text: 'approveSession Dapp failed');
      return;
    }
  }

  void reject() async {
    try {
      await platformChannel.invokeMethod("rejectSession");
    } catch (e) {
      if (kDebugMode) {
        print('Catch invokeMethod rejectSession, message: $e');
      }
      showSnackBar(text: 'Reject Session Dapp failed');
      return;
    }
    showSnackBar(text: 'Success reject', color: Colors.green);
  }

  void disconnect() async {
    setState(() {
      methods = null;
      sessionExpiry = null;
    });
    try {
      await platformChannel.invokeMethod("disconnectSession");
    } catch (e) {
      if (kDebugMode) {
        print('Catch invokeMethod rejectSession, message: $e');
      }
      showSnackBar(text: 'Disconnect Session Dapp failed');
      return;
    }


    showSnackBar(text: 'Success Disconnect', color: Colors.green);
  }

}