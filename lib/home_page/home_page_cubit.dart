import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'home_page_state.dart';

enum MethodCallWallet {
  sessionProposal,
  sessionRequest,
  deletedSession,
  settleSessionResponse,
  sessionUpdateResponse
}

enum InvokeMethodWallet {
  pairWallet,
  approveSession,
  rejectSession,
  disconnectSession,
}

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(const HomePageState());

  static const platformChannel = MethodChannel('WalletConnectMethodChannel');

  void onListenEvents() {
    platformChannel.setMethodCallHandler((call) async {
      if (call.method == 'sessionProposal') {
        if (call.arguments == null) {
          emit(state.copyWith(
              message: 'No data received',
              methodCallWallet: MethodCallWallet.sessionProposal));
          return;
        }
        if (kDebugMode) {
          print("flutter do: sessionProposal");
        }
        emit(state.copyWith(
            message: 'No data received',
            methodCallWallet: MethodCallWallet.sessionProposal,
            methods: call.arguments));
      }
      if (call.method == 'sessionRequest') {
        if (kDebugMode) {
          print("flutter do: sessionRequest");
        }
        emit(state.copyWith(
            message: 'sessionRequest',
            methodCallWallet: MethodCallWallet.sessionRequest,
            methods: call.arguments));
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
          sessionExpiry =
              DateTime.fromMillisecondsSinceEpoch(sessionExpiryInt * 1000)
                  .toLocal()
                  .toString();
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
          message: '${invokeMethodWallet.name.toString()} Disconnected',
          methodCallWallet: MethodCallWallet.deletedSession,
          invokeMethodWallet: InvokeMethodWallet.pairWallet,
          methods: null,
          sessionExpiry: null));
    }
    try {
      await platformChannel.invokeMethod(
          invokeMethodWallet.name.toString(), value);
    } catch (e) {
      if (kDebugMode) {
        print(
            'Catch invokeMethod ${invokeMethodWallet.name.toString()}, message: $e');
      }
      emit(state.copyWith(
          message: '${invokeMethodWallet.name.toString()} failed',
          invokeMethodWallet: InvokeMethodWallet.pairWallet));
    }
  }
}
