part of 'home_page_cubit.dart';

class HomePageState extends Equatable {
  final List<String> accounts;
  final String message;
  final MethodCallWallet? methodCallWallet;
  final dynamic methods;
  final dynamic sessionExpiry;
  final SessionProposal? sessionProposal;
  final SessionRequest? sessionRequest;

  const HomePageState({
    this.accounts = const <String>[
      'eip155:42:0xb6f6a28624a70a9e38294587529ba60144940ed1',
      'eip155:42:0xd4e10bdad6a474585a7aba291f86dd332ad0a0d4'
    ],
    this.message = '',
    this.methodCallWallet,
    this.methods,
    this.sessionExpiry,
    this.sessionProposal,
    this.sessionRequest,
  });

  HomePageState copyWith({
    List<String>? accounts,
    String? message,
    MethodCallWallet? methodCallWallet,
    dynamic methods,
    dynamic sessionExpiry,
    SessionProposal? sessionProposal,
    SessionRequest? sessionRequest,
  }) {
    return HomePageState(
      accounts: accounts ?? this.accounts,
      message: message ?? this.message,
      methodCallWallet: methodCallWallet ?? this.methodCallWallet,
      methods: methods ?? this.methods,
      sessionExpiry: sessionExpiry ?? this.sessionExpiry,
      sessionProposal: sessionProposal ?? this.sessionProposal,
      sessionRequest: sessionRequest ?? this.sessionRequest,
    );
  }

  @override
  List<Object?> get props => [
        accounts,
        message,
        methodCallWallet,
        methods,
        sessionExpiry,
        sessionRequest,
        sessionProposal,
      ];
}
