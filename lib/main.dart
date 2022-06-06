import 'package:connect_wallet_v2/camera_qr_view.dart';
import 'package:connect_wallet_v2/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ConnectWallet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platformChannel = MethodChannel('WalletConnectMethodChannel');

  late TextEditingController _textEditingController;
  String? barcodeRawString;

  @override
  void initState() {
    super.initState();
    onListenEvents();
    _textEditingController = TextEditingController();
  }

  void onListenEvents(){
    platformChannel.setMethodCallHandler((call) async{
      if(call.method == 'sessionProposal'){
        if(call.arguments == null) {
          showSnackBar(text: 'No data received');
          return;
        }
        sessionProposal(call.arguments);
      }
      if(call.method == 'sessionRequest'){}
      if(call.method == 'deletedSession'){}
      if(call.method == 'sessionNotification'){}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
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
                    if(barcodeRawString == null) showSnackBar();
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
                        if(_textEditingController.text.isEmpty) return;
                        if(_textEditingController.text.startsWith('wc',0) == false) {
                          showSnackBar(text: 'Code not recognized');
                          return;
                        }
                        pairWithDapp(_textEditingController.text);
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar({String? text}){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text ?? 'Barcode scan failed')));
  }

  void showAlertDialog({
    String? title,
    Widget? content,
    void Function()? approve,
    void Function()? reject,
  }){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text(title ?? 'Request'),
        content: content ?? Container(),
        actions: [
          TextButton(
            onPressed: approve ?? (){},
            child: const Text('Approve', style: TextStyle(color: Colors.blue),),
          ),
          TextButton(
            onPressed: reject ?? (){},
            child: const Text('Reject', style: TextStyle(color: Colors.red),),
          ),
        ],
      );
    });
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
    if(result == null) showSnackBar(text: 'Pair with Dapp failed');
    final resultModel = SettledPairing.fromJson(result);
    showSnackBar(text: 'Success pair ${resultModel.topic}');
  }

  void sessionProposal(dynamic json){
    final SessionProposal sessionProposal = SessionProposal.fromJson(json);

    final List<Widget> checkBoxListTile = [];
    final Map<String, bool> accountsBool = {};

    for(int i = 0; i < sessionProposal.accounts!.length; i++){
      accountsBool.addEntries({sessionProposal.accounts![i]: false}.entries);
      checkBoxListTile.add(
        CheckboxListTile(
            value: accountsBool[sessionProposal.accounts![i]],
            onChanged: (bool? value){
              setState(() {
                accountsBool[sessionProposal.accounts![i]] = value!;
              });
            }
        ),
      );
    }

    showAlertDialog(
      title: 'Session Proposal',
      content: Column(
        children: [
          const Text('Choose Accounts'),
          ...checkBoxListTile
        ],
      ),
      approve: (){
        accountsBool.removeWhere((String key, bool value) => value == false);
        approveAccounts(accountsBool.keys.toList());
      },
      reject: reject,
    );
  }
  void approveAccounts(List<String> value) async {
    dynamic result;
    try {
      result = await platformChannel.invokeMethod("approveSession", value);
    } catch (e) {
      if (kDebugMode) {
        print('Catch invokeMethod approveSession, message: $e');
      }
      showSnackBar(text: 'approveSession Dapp failed');
      return;
    }
    if(result == null) showSnackBar(text: 'approveSession failed');
    final resultModel = SettledSession.fromJson(result);
    showSnackBar(text: 'Success approve ${resultModel.topic}');
  }

  void reject() async {
    dynamic result;
    try {
      result = await platformChannel.invokeMethod("rejectSession");
    } catch (e) {
      if (kDebugMode) {
        print('Catch invokeMethod rejectSession, message: $e');
      }
      showSnackBar(text: 'Reject Session Dapp failed');
      return;
    }
    if(result == null) showSnackBar(text: 'approveSession failed');
    final resultModel = RejectedSession.fromJson(result);
    showSnackBar(text: 'Success reject ${resultModel.topic}');
  }



}
