part of 'home_page_cubit.dart';


class HomePageState extends Equatable {

  final List<String> accounts;
  final String message;
  final MethodCallWallet? methodCallWallet;
  final InvokeMethodWallet? invokeMethodWallet;
  final dynamic methods;
  final dynamic sessionExpiry;

  const HomePageState({
    this.accounts = const <String>[],
    this.message = '',
    this.methodCallWallet,
    this.invokeMethodWallet,
    this.methods,
    this.sessionExpiry
  });

  HomePageState copyWith({
    List<String>? accounts,
    String? message,
    MethodCallWallet? methodCallWallet,
    InvokeMethodWallet? invokeMethodWallet,
    dynamic methods,
    dynamic sessionExpiry,
  }) {
    return HomePageState(
      accounts: accounts ?? this.accounts,
      message: message ?? this.message,
      methodCallWallet: methodCallWallet ?? this.methodCallWallet,
      invokeMethodWallet: invokeMethodWallet ?? this.invokeMethodWallet,
      methods: methods ?? this.methods,
      sessionExpiry: sessionExpiry ?? this.sessionExpiry,
    );
  }

  @override
  List<Object?> get props => [
    accounts,
    message,
    methodCallWallet,
    invokeMethodWallet,
    methods,
    sessionExpiry,
  ];
}
