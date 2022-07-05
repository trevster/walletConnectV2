import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';

part 'home_page_state.dart';

enum MethodCallWallet {
  sessionProposal,
  sessionRequest,
  deletedSession,
  settleSessionResponse,
  sessionUpdateResponse,
}

enum InvokeMethodWallet {
  pairWallet,
  approveSession,
  rejectSession,
  disconnectSession,
  respondRequest,
  rejectRequest,
}

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(const HomePageState());
  static const storage = FlutterSecureStorage();
  static const walletAddress = "WALLET_ADDRESS";
  static const platformChannel = MethodChannel('WalletConnectMethodChannel');

  String toCAPI10(String addressHex) {
    if(!addressHex.startsWith('eip')) return 'eip155:42:$addressHex';
    return addressHex;
  }

  void initWallet() async {
    final String? account = await storage.read(key: walletAddress);
    if (account != null) {
      emit(state.copyWith(accounts: [toCAPI10(account)]));
      return;
    }
    final rng = Random.secure();
    Credentials credentials = EthPrivateKey.createRandom(rng);
    final address = await credentials.extractAddress();
    final addressHexEip155 = address.hexEip55;
    if (kDebugMode) {
      print('generated address: $address');
    }
    emit(state.copyWith(accounts: [toCAPI10(addressHexEip155)]));
    storage.write(key: walletAddress, value: addressHexEip155);
  }

  void onListenEvents() {
    platformChannel.setMethodCallHandler((call) async {
      if (call.method == 'sessionProposal') {
        if (call.arguments == null) {
          emit(state.copyWith(
            message: 'No data received',
            methodCallWallet: MethodCallWallet.sessionProposal,
          ));
          return;
        }
        if (kDebugMode) {
          print("flutter do: sessionProposal");
        }
        emit(state.copyWith(
          message: 'Session Proposal',
          methodCallWallet: MethodCallWallet.sessionProposal,
          methods: call.arguments,
        ));
      }
      if (call.method == 'sessionRequest') {
        if (kDebugMode) {
          print("flutter do: sessionRequest");
        }
        emit(state.copyWith(
          message: 'Requested',
          methodCallWallet: MethodCallWallet.sessionRequest,
          methods: call.arguments,
        ));
      }
      if (call.method == 'deletedSession') {
        if (kDebugMode) {
          print("flutter do: deletedSession");
        }
        emit(state.copyWith(
          message: 'Session Deleted by Dapp',
          methodCallWallet: MethodCallWallet.deletedSession,
          sessionExpiry: null,
          methods: null,
        ));
      }
      if (call.method == 'settleSessionResponse') {
        if (kDebugMode) {
          print("flutter do: settleSessionResponse");
        }

        dynamic sessionExpiry = call.arguments;
        try {
          final sessionExpiryInt = int.parse(sessionExpiry.toString());
          sessionExpiry = DateTime.fromMillisecondsSinceEpoch(sessionExpiryInt * 1000).toLocal().toString();
        } catch (e) {
          emit(state.copyWith(
            message: 'Unexpected error',
            methods: MethodCallWallet.settleSessionResponse,
          ));
          if (kDebugMode) {
            print("fail parse: sessionExpiryString");
          }
        }

        emit(state.copyWith(
          message: 'Session connected',
          methodCallWallet: MethodCallWallet.settleSessionResponse,
          sessionExpiry: sessionExpiry,
        ));
      }
      if (call.method == 'sessionUpdateResponse') {
        if (kDebugMode) {
          print("flutter do: sessionUpdateResponse");
        }
      }
    });
  }

  void invokeMethod(
    InvokeMethodWallet invokeMethodWallet, {
    dynamic value,
  }) async {
    if (invokeMethodWallet == InvokeMethodWallet.disconnectSession) {
      emit(state.copyWith(
        message: 'Disconnected',
        methodCallWallet: MethodCallWallet.deletedSession,
        methods: null,
        sessionExpiry: null,
      ));
    }
    if (invokeMethodWallet == InvokeMethodWallet.respondRequest ||
        invokeMethodWallet == InvokeMethodWallet.rejectRequest) {
      // final Credentials credentials = EthPrivateKey.fromHex(state.accounts.first);
      // Todo: sign req
    }
    try {
      await platformChannel.invokeMethod(invokeMethodWallet.name.toString(), value);
    } catch (e) {
      if (kDebugMode) {
        print('Catch invokeMethod ${invokeMethodWallet.name.toString()}, message: $e');
      }
      emit(state.copyWith(message: '${invokeMethodWallet.name.toString()} failed'));
    }
  }
}
