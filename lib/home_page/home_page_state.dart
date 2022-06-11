part of 'home_page_cubit.dart';


class HomePageState extends Equatable {

  final String? message;
  final MethodCallWallet? methodCallWallet;
  final InvokeMethodWallet? invokeMethodWallet;
  final dynamic methods;
  final dynamic sessionExpiry;

  const HomePageState({
    this.message,
    this.methodCallWallet,
    this.invokeMethodWallet,
    this.methods,
    this.sessionExpiry
  });

  HomePageState copyWith({
    String? message,
    MethodCallWallet? methodCallWallet,
    InvokeMethodWallet? invokeMethodWallet,
    dynamic methods,
    dynamic sessionExpiry,
  }) {
    return HomePageState(
      message: message ?? this.message,
      methodCallWallet: methodCallWallet ?? this.methodCallWallet,
      invokeMethodWallet: invokeMethodWallet ?? this.invokeMethodWallet,
      methods: methods ?? this.methods,
      sessionExpiry: sessionExpiry ?? this.sessionExpiry,
    );
  }

  @override
  List<Object?> get props => [
    message,
    methodCallWallet,
    invokeMethodWallet,
    methods,
    sessionExpiry,
  ];
}
