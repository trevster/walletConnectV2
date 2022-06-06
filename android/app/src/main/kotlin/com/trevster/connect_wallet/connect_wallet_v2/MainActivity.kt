package com.trevster.connect_wallet.connect_wallet_v2

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.walletconnect.walletconnectv2.client.WalletConnect
import com.walletconnect.walletconnectv2.client.WalletConnectClient
import com.walletconnect.walletconnectv2.client.WalletConnectClient.pair
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "WalletConnectMethodChannel"
    private lateinit var channel: MethodChannel

    private lateinit var proposal: WalletConnect.Model.SessionProposal

//    private val EVENT_CHANNEL = "com.trevster.connectWallet/responses"
//    private lateinit var eventChannel: EventChannel

    private companion object {
        const val WALLET_CONNECT_URL = "relay.walletconnect.com"
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(methodCallsFromFlutter())

        val initConnect = WalletConnect.Params.Init(
            this.application,
            "wss://$WALLET_CONNECT_URL?projectId=b3492619c0f2f0429cf8f67532896405",
            true,
            WalletConnect.Model.AppMetaData(
                "Flutter Wallet",
                "Test Wallet",
                "com.trevster.connect_wallet",
                listOf("https://cdn-icons.flaticon.com/png/512/855/premium/855381.png?token=exp=1654498348~hmac=d09df53c90cdaf267b663a011abc7645")
            )
        )

        WalletConnectClient.initialize(initConnect)
        WalletConnectClient.setWalletDelegate(delegateWallet())


//        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
//        eventChannel.setStreamHandler(WalletStreamHandler(context))
    }


    private fun methodCallsFromFlutter() : MethodChannel.MethodCallHandler{
        return MethodChannel.MethodCallHandler{ call, result ->
            if (call.method == "pairWallet") {
                Log.i("Dev","mcff ---- pairWallet ----")
                println("mcff pairWallet call.arguments ${call.arguments}")
                val uri = "wc:${(call.arguments as String)}"
                println("mcff pairWallet arguments $uri")
                if (uri.isEmpty()){
                    result.error("500","argument is null", null)
                }
                val pairParams = WalletConnect.Params.Pair(uri)

                println("mcff pairWallet pairParams $pairParams")
                pair(pairParams, object : WalletConnect.Listeners.Pairing {
                    override fun onSuccess(settledPairing: WalletConnect.Model.SettledPairing) {
                        Log.i("Dev","mcff Settled Pairing result: $settledPairing")
                        println("Settled Pairing result: $settledPairing")
                        result.success(settledPairing)
                    }

                    override fun onError(error: Throwable) {
                        Log.i("Dev","mcff On Error result: ${error.message} ${error.cause}")
                        println("On Error result: ${error.message} ${error.cause}")
                        result.error("408", "${error.message}", null)
                    }
                })
            }
            if (call.method == "approveSession"){
                val accounts = proposal.chains.map { chainId -> "$chainId:0x022c0c42a80bd19EA4cF0F94c4F9F96645759716" }
                val approve = WalletConnect.Params.Approve(proposal, accounts)

                WalletConnectClient.approve(approve, object : WalletConnect.Listeners.SessionApprove {
                    override fun onSuccess(settledSession: WalletConnect.Model.SettledSession) {
                        println("Settled Pairing result: $settledSession")
                        result.success(settledSession)
                    }

                    override fun onError(error: Throwable) {
                        println("On Error result: ${error.message} ${error.cause}")
                        result.error("408", "${error.message}", null)
                    }
                })
            }

            if (call.method == "rejectSession"){
                val rejectionReason = "Reject Session"
                val proposalTopic: String = proposal.topic
                val reject = WalletConnect.Params.Reject(rejectionReason, proposalTopic)

                WalletConnectClient.reject(reject, object : WalletConnect.Listeners.SessionReject {
                    override fun onSuccess(rejectedSession: WalletConnect.Model.RejectedSession) {
                        // onSuccess reject session
                        result.success(rejectedSession)
                    }

                    override fun onError(error: Throwable) {
                        //Reject proposal error
                        result.error("500", error.message, null)
                    }
                })
            }
        }
    }

    private fun delegateWallet(): WalletConnectClient.WalletDelegate {
        return object : WalletConnectClient.WalletDelegate {
            override fun onSessionProposal(sessionProposal: WalletConnect.Model.SessionProposal) {
                // Triggered when wallet receives the session proposal sent by a Dapp
                proposal = sessionProposal
                channel.invokeMethod("sessionProposal", sessionProposal)
            }

            override fun onSessionRequest(sessionRequest: WalletConnect.Model.SessionRequest) {
                // Triggered when a Dapp sends SessionRequest to sign a transaction or a message
                channel.invokeMethod("sessionRequest", sessionRequest)
            }

            override fun onSessionDelete(deletedSession: WalletConnect.Model.DeletedSession) {
                // Triggered when the session is deleted by the peer
                channel.invokeMethod("deletedSession", deletedSession)
            }

            override fun onSessionNotification(sessionNotification: WalletConnect.Model.SessionNotification) {
                channel.invokeMethod("sessionNotification", sessionNotification)
            }
        }
    }

}

//class WalletStreamHandler(private val context: Context) : EventChannel.StreamHandler{
//    private var receiver: BroadcastReceiver? = null
//    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
//        if(events == null) return
//
//        receiver = initReceiver(events)
//        context.registerReceiver(receiver, IntentFilter())
//    }
//
//    override fun onCancel(arguments: Any?) {
//        TODO("Not yet implemented")
//    }
//
//    private fun initReceiver(events: EventChannel.EventSink) : BroadcastReceiver{
//        return object : BroadcastReceiver(){
//            override fun onReceive(context: Context?, intent: Intent?) {
//                TODO("Not yet implemented")
//            }
//        }
//    }
//}

