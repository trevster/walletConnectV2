part of 'home_page_cubit.dart';

class HomePageState extends Equatable {
  final List<String> accounts;
  final String message;
  final MethodCallWallet? methodCallWallet;
  final dynamic methods;
  final dynamic sessionExpiry;
  final dynamic args;

  const HomePageState({
    this.accounts = const <String>[],
    this.message = '',
    this.methodCallWallet,
    this.methods,
    this.sessionExpiry,
    this.args,
  });

  HomePageState copyWith({
    List<String>? accounts,
    String? message,
    MethodCallWallet? methodCallWallet,
    dynamic methods,
    dynamic sessionExpiry,
    dynamic args,
  }) {
    return HomePageState(
      accounts: accounts ?? this.accounts,
      message: message ?? this.message,
      methodCallWallet: methodCallWallet ?? this.methodCallWallet,
      methods: methods ?? this.methods,
      sessionExpiry: sessionExpiry ?? this.sessionExpiry,
      args: args ?? this.args,
    );
  }

  @override
  List<Object?> get props => [
        accounts,
        message,
        methodCallWallet,
        methods,
        sessionExpiry,
        args,
      ];
}
