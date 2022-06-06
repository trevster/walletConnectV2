class AppMetaData {
  final String? name;
  final String? description;
  final String? url;
  final List<String>? icons;

  AppMetaData({this.name, this.description, this.url, this.icons});

  static AppMetaData fromJson(dynamic json) {
    return AppMetaData(
        name: json['name'] as String,
        description: json['description'] as String,
        url: json['url'] as String,
        icons: List<String>.from(json['icons']));
  }
}

class SettledPairing {
  final String? topic;
  final AppMetaData? metaData;

  SettledPairing({this.topic, this.metaData});

  static SettledPairing fromJson(dynamic json) {
    return SettledPairing(
      topic: json['topic'] as String,
      metaData: AppMetaData.fromJson(json['metaData']),
    );
  }
}

class SessionProposal {
  final String? name;
  final String? description;
  final String? url;
  final List<String>? icons;
  final List<String>? chains;
  final List<String>? methods;
  final List<String>? types;
  final String? topic;
  final String? proposerPublicKey;
  final bool? isController;
  final double? ttl;
  final List<String>? accounts;
  final String? relayProtocol;

  SessionProposal(
      {this.name,
      this.description,
      this.url,
      this.icons,
      this.chains,
      this.methods,
      this.types,
      this.topic,
      this.proposerPublicKey,
      this.isController,
      this.ttl,
      this.accounts,
      this.relayProtocol});

  static SessionProposal fromJson(dynamic json) {
    return SessionProposal(
      name: json['name'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      icons: List<String>.from(json['icons']),
      chains: List<String>.from(json['chains']),
      methods: List<String>.from(json['methods']),
      types: List<String>.from(json['types']),
      topic: json['topic'] as String,
      proposerPublicKey: json['proposerPublicKey'] as String,
      isController: json['isController'] as bool,
      ttl: json['ttl'] as double,
      accounts: List<String>.from(json['accounts']),
      relayProtocol: json['relayProtocol'] as String,
    );
  }
}

class SettledSession {
  final String? topic;
  final List<String>? accounts;
  final AppMetaData? peerAppMetaData;
  final Permissions? permissions;

  SettledSession(
      {this.topic, this.accounts, this.peerAppMetaData, this.permissions});

  static SettledSession fromJson(dynamic json) {
    return SettledSession(
        topic: json['topic'] as String,
        accounts: List<String>.from(json['accounts']),
        peerAppMetaData: AppMetaData.fromJson(json['peerAppMetaData']),
        permissions: Permissions.fromJson(json['permissions']));
  }
}

class Permissions {
  final List<String>? blockchain;
  final List<String>? jsonRpc;
  final List<String>? notifications;

  Permissions({this.blockchain, this.jsonRpc, this.notifications});

  static Permissions fromJson(dynamic json) {
    return Permissions(
      blockchain: List<String>.from(json['blockchain']),
      jsonRpc: List<String>.from(json['jsonRpc']),
      notifications: List<String>.from(json['notifications']),
    );
  }
}

class RejectedSession {
  final String? topic;
  final String? reason;

  RejectedSession({
    this.topic,
    this.reason,
  });

  static RejectedSession fromJson(dynamic json){
    return RejectedSession(
      topic: json['topic'] as String,
      reason: json['reason'] as String,
    );
  }
}
