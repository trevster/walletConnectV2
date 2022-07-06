import 'package:connect_wallet_v2/features/camera_page/camera_qr_view.dart';
import 'package:connect_wallet_v2/features/home_page/home_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key? key, this.title = ''}) : super(key: key);

  final HomePageCubit _homePageCubit = HomePageCubit();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String? barcodeRawString;

    _homePageCubit
      ..initWallet()
      ..onListenEvents();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                    if (barcodeRawString == null) showSnackBar(context: context);
                    _homePageCubit.invokeMethod(InvokeMethodWallet.pairWallet, value: barcodeRawString!.substring(3));
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
                        if (_textEditingController.text.startsWith('wc', 0) == false) {
                          showSnackBar(context: context, text: 'Code not recognized');
                          return;
                        }
                        _homePageCubit.invokeMethod(InvokeMethodWallet.pairWallet, value: _textEditingController.text);
                      },
                    ),
                  ),
                ),
                BlocConsumer<HomePageCubit, HomePageState>(
                  bloc: _homePageCubit,
                  listenWhen: (previous, current) => previous.methodCallWallet != current.methodCallWallet,
                  listener: (context, state) async {
                    if (state.methodCallWallet == MethodCallWallet.sessionProposal) {
                      final List<Widget> contentWidget = [];

                      for (int i = 0; i < state.accounts.length; i++) {
                        contentWidget.add(
                          Text(state.accounts[i]),
                        );
                      }
                      if (state.sessionProposal == null) {
                        showSnackBar(context: context, text: 'Data empty');
                        return;
                      }
                      walletDialog(
                        context: context,
                        method: state.sessionProposal!.proposal!.methods!.join(','),
                        accounts: state.accounts,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Accounts:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ...contentWidget
                          ],
                        ),
                        approve: () {
                          _homePageCubit.invokeMethod(InvokeMethodWallet.approveSession);
                          Navigator.of(context).pop();
                        },
                        reject: () {
                          _homePageCubit.invokeMethod(InvokeMethodWallet.rejectSession);
                          Navigator.of(context).pop();
                        },
                      );
                    }
                    if (state.message.isNotEmpty) {
                      showSnackBar(
                        context: context,
                        text: state.message,
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.methodCallWallet == MethodCallWallet.settleSessionResponse) {
                      final _accounts = state.accounts;
                      return SizedBox(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            const Text(
                              'Current Paired Accounts',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              title: const Text('Accounts'),
                              subtitle: Text(_accounts.toString()),
                            ),
                            ListTile(
                              title: const Text('Methods'),
                              subtitle: Text(state.methods.toString()),
                            ),
                            ListTile(
                              title: const Text('Expiry'),
                              subtitle: Text(state.sessionExpiry.toString()),
                            ),
                            TextButton(
                              onPressed: () => _homePageCubit.invokeMethod(InvokeMethodWallet.disconnectSession),
                              child: const Text('Disconnect'),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar({String? text, Color? color, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text ?? 'Barcode scan failed'),
      backgroundColor: color,
    ));
  }

  Future<dynamic> walletDialog({
    required BuildContext context,
    String title = 'Request',
    String method = '',
    Widget? content,
    required Function() approve,
    required Function() reject,
    List<String> accounts = const <String>[],
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alertDialogCustom(
          title: title,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Methods',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(method),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              if (content != null) content,
            ],
          ),
          approve: approve,
          reject: reject,
        );
      },
    );
  }

  Widget alertDialogCustom({
    required String title,
    Widget? content,
    void Function()? approve,
    void Function()? reject,
  }) {
    return AlertDialog(
      title: Text(title),
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
}
