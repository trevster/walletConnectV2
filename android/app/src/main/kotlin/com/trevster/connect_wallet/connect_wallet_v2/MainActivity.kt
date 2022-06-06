package com.trevster.connect_wallet.connect_wallet_v2

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.walletconnect.walletconnectv2.client.Sign
import com.walletconnect.walletconnectv2.client.SignClient
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.net.URI


class MainActivity : FlutterActivity() {
    private val CHANNEL = "WalletConnectMethodChannel"
    private lateinit var channel: MethodChannel

    private lateinit var proposal: Sign.Model.SessionProposal /*= Sign.Model.SessionProposal(
        name = "A",
        description = "B",
        url = "C",
        icons = listOf(URI.create("https://cdn-icons.flaticon.com/png/512/855/premium/855381.png?token=exp=1654498348~hmac=d09df53c90cdaf267b663a011abc7645")),
        requiredNamespaces = mapOf("eip155" to Sign.Model.Namespace.Proposal(listOf("A"),listOf("A"),listOf("A"), null)),
        proposerPublicKey = "A",
        relayProtocol = "C",
        relayData = null,
    )*/

//    private val EVENT_CHANNEL = "com.trevster.connectWallet/responses"
//    private lateinit var eventChannel: EventChannel

    private companion object {
        const val WALLET_CONNECT_URL = "relay.walletconnect.com"
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(methodCallsFromFlutter())

        val initConnect = Sign.Params.Init(
            this.application,
            "wss://$WALLET_CONNECT_URL?projectId=b3492619c0f2f0429cf8f67532896405",
            Sign.Model.AppMetaData(
                "Flutter Wallet",
                "Test Wallet",
                "com.trevster.connect_wallet",
                listOf("https://cdn-icons.flaticon.com/png/512/855/premium/855381.png?token=exp=1654498348~hmac=d09df53c90cdaf267b663a011abc7645")
            ),
            null,
            Sign.ConnectionType.AUTOMATIC
        )

        SignClient.initialize(initConnect) { error ->
            Log.i("Dev", "Sign Client Initialize Error ${error.throwable.message}")
        }
        SignClient.setWalletDelegate(walletDelegate)


//        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
//        eventChannel.setStreamHandler(WalletStreamHandler(context))
    }


    private fun methodCallsFromFlutter(): MethodChannel.MethodCallHandler {
        return MethodChannel.MethodCallHandler { call, result ->
            if (call.method == "pairWallet") {
                Log.i("Dev", "mcff ---- pairWallet ----")
                println("mcff pairWallet call.arguments ${call.arguments}")
                val uri = "wc:${(call.arguments as String)}"
                println("mcff pairWallet arguments $uri")
                if (uri.isEmpty()) {
                    result.error("500", "argument is null", null)
                }
                val pairParams = Sign.Params.Pair(uri)

                println("mcff pairWallet pairParams $pairParams")
                SignClient.pair(pairParams) { error: Sign.Model.Error ->
                    result.error("Dev", "${error.throwable.message}", null)
                }
            }
            if (call.method == "approveSession") {

                val namespace = proposal.requiredNamespaces.keys.first()
                val accounts: List<String> = call.arguments() as List<String>
                val methods: List<String> = proposal.requiredNamespaces[proposal.requiredNamespaces.keys.first()]!!.methods
                val events: List<String> = proposal.requiredNamespaces[proposal.requiredNamespaces.keys.first()]!!.events
                val namespaces: Map<String, Sign.Model.Namespace.Session> = mapOf(
                    namespace to Sign.Model.Namespace.Session(
                        accounts,
                        methods,
                        events,
                        null
                    )
                )


                val approve = Sign.Params.Approve(proposal.proposerPublicKey, namespaces)
                SignClient.approveSession(approve) { error: Sign.Model.Error ->
                    result.error(
                        "Dev",
                        "Sign Client Approve Session Failed ${error.throwable.message}",
                        null
                    )
                }
            }

            if (call.method == "rejectSession") {
                val rejectionReason = "Reject Session"
                val proposalTopic: String = proposal.name
                val reject = Sign.Params.Reject(rejectionReason, proposalTopic, 500)

                SignClient.rejectSession(reject) { error: Sign.Model.Error ->
                    result.error(
                        "408",
                        "Sign Client Reject Session Failed ${error.throwable.message}",
                        null
                    )
                }
            }
        }
    }

    private val walletDelegate = object : SignClient.WalletDelegate {
        override fun onSessionProposal(sessionProposal: Sign.Model.SessionProposal) {
            // Triggered when wallet receives the session proposal sent by a Dapp
            Log.i("Dev", "---- onSessionProposal ----")
            println("walDel sessionProposal $sessionProposal")
            proposal = sessionProposal
            println("walDel sessionProposal gonna invoke method: proposal $proposal")
            runOnUiThread {
                channel.invokeMethod(
                    "sessionProposal",
                    sessionProposal.requiredNamespaces[sessionProposal.requiredNamespaces.keys.first()]?.methods
            ) }
            println("walDel sessionProposal method invoked $sessionProposal")
        }

        override fun onSessionRequest(sessionRequest: Sign.Model.SessionRequest) {
            // Triggered when a Dapp sends SessionRequest to sign a transaction or a message
            channel.invokeMethod("sessionRequest", sessionRequest)
        }

        override fun onSessionDelete(deletedSession: Sign.Model.DeletedSession) {
            // Triggered when the session is deleted by the peer
            channel.invokeMethod("deletedSession", deletedSession)
        }

        override fun onSessionSettleResponse(settleSessionResponse: Sign.Model.SettledSessionResponse) {
            // Triggered when wallet receives the session settlement response from Dapp
            channel.invokeMethod("settleSessionResponse", settleSessionResponse)
        }

        override fun onSessionUpdateResponse(sessionUpdateResponse: Sign.Model.SessionUpdateResponse) {
            // Triggered when wallet receives the session update response from Dapp
            channel.invokeMethod("sessionUpdateResponse", sessionUpdateResponse)
        }

        override fun onConnectionStateChange(state: Sign.Model.ConnectionState) {
            println("connectionStateChanged")
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

