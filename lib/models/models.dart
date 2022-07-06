import 'dart:core';
import 'dart:ffi';

class AppMetaData {
  final String? name;
  final String? description;
  final String? url;
  final List<String>? icons;

  AppMetaData({this.name, this.description, this.url, this.icons});

  static AppMetaData fromJson(dynamic json) {
    return AppMetaData(
        name: json['name'],
        description: json['description'],
        url: json['url'],
        icons: List<String>.from(json['icons']));
  }
}

class SettledPairing {
  final String? topic;
  final AppMetaData? metaData;

  SettledPairing({this.topic, this.metaData});

  static SettledPairing fromJson(dynamic json) {
    return SettledPairing(
      topic: json['topic'],
      metaData: AppMetaData.fromJson(json['metaData']),
    );
  }
}

class SessionProposal {
  final String? name;
  final String? description;
  final String? url;
  final List<String>? icons;
  final String? requiredNamespaces;
  final Proposal? proposal;
  final String? proposerPublicKey;
  final String? relayData;
  final String? relayProtocol;

  SessionProposal({
    this.name,
    this.description,
    this.url,
    this.icons,
    this.requiredNamespaces,
    this.proposal,
    this.proposerPublicKey,
    this.relayData,
    this.relayProtocol,
  });

  static SessionProposal fromJson(dynamic json) {
    return SessionProposal(
      name: json['name'],
      description: json['description'],
      url: json['url'],
      icons: List<String>.from(json['icons']),
      requiredNamespaces: json['requiredNamespaces'],
      proposal: Proposal.fromJson(json['proposal']),
      proposerPublicKey: json['proposerPublicKey'],
      relayData: json['relayData'],
      relayProtocol: json['relayProtocol'],
    );
  }
}

class Proposal {
  final List<String>? chains;
  final List<String>? methods;
  final List<String>? events;

  Proposal({this.chains, this.methods, this.events});

  static Proposal fromJson(dynamic json) {
    return Proposal(
      chains: List<String>.from(json['chains']),
      methods: List<String>.from(json['methods']),
      events: List<String>.from(json['events']),
    );
  }
}

class SettledSession {
  final String? topic;
  final List<String>? accounts;
  final AppMetaData? peerAppMetaData;
  final Permissions? permissions;

  SettledSession({this.topic, this.accounts, this.peerAppMetaData, this.permissions});

  static SettledSession fromJson(dynamic json) {
    return SettledSession(
        topic: json['topic'],
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

  static RejectedSession fromJson(dynamic json) {
    return RejectedSession(
      topic: json['topic'],
      reason: json['reason'],
    );
  }
}

class SessionRequest {
  final String? topic;
  final String? chainId;
  final AppMetaData? peerMetaData;
  final JSONRPCRequest? request;

  SessionRequest({
    this.topic,
    this.chainId,
    this.peerMetaData,
    this.request,
  });

  static SessionRequest fromJson(dynamic json) {
    return SessionRequest(
      topic: json['topic'],
      chainId: json['chainId'],
      peerMetaData: AppMetaData.fromJson(json['peerMetaData']),
      request: JSONRPCRequest.fromJson(json['request']),
    );
  }
}

class JSONRPCRequest {
  final Long? id;
  final String? method;
  final String? params;

  JSONRPCRequest({
    this.id,
    this.method,
    this.params,
  });

  static JSONRPCRequest fromJson(dynamic json) {
    return JSONRPCRequest(
      id: json['id'],
      method: json['method'],
      params: json['params'],
    );
  }
}
