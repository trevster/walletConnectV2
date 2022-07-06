package com.trevster.connect_wallet.connect_wallet_v2

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.walletconnect.walletconnectv2.client.Sign
import com.walletconnect.walletconnectv2.client.SignClient
import java.net.URI
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString


class MainActivity : FlutterActivity() {
    private val CHANNEL = "WalletConnectMethodChannel"
    private lateinit var channel: MethodChannel

    private lateinit var proposal: Sign.Model.SessionProposal
    private lateinit var request: Sign.Model.SessionRequest
    private lateinit var sessionsModel: List<Sign.Model.Session>

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

        runOnUiThread { }
        val walletDelegate = object : SignClient.WalletDelegate {
            override fun onSessionProposal(sessionProposal: Sign.Model.SessionProposal) {
                // Triggered when wallet receives the session proposal sent by a Dapp
                Log.i("Dev", "---- onSessionProposal ----")
                println("walDel sessionProposal $sessionProposal")
                proposal = sessionProposal
                println("walDel sessionProposal gonna invoke method: proposal $proposal")

                val proposedSealed =
                    sessionProposal.requiredNamespaces[sessionProposal.requiredNamespaces.keys.first()]
                var proposalModelTemp = ProposalModel(null, null, null)
                if (proposedSealed != null) {
                    proposalModelTemp = ProposalModel(
                        proposedSealed.chains,
                        proposedSealed.methods,
                        proposedSealed.events,
                    )
                }

                val transform: (URI) -> String = {it.toString()}
                val sessionProposalModelTemp = SessionProposalModel(
                    sessionProposal.name,
                    sessionProposal.description,
                    sessionProposal.url,
                    sessionProposal.icons.map(transform),
                    sessionProposal.requiredNamespaces.keys.first(),
                    proposalModelTemp,
                    sessionProposal.proposerPublicKey,
                    sessionProposal.relayProtocol,
                    sessionProposal.relayData,
                )
                runOnUiThread {
                    channel.invokeMethod(
                        "sessionProposal",
                        Json.encodeToString(sessionProposalModelTemp)
                    )

                }
                println("walDel sessionProposal method invoked $sessionProposal")
            }

            override fun onSessionRequest(sessionRequest: Sign.Model.SessionRequest) {
                // Triggered when a Dapp sends SessionRequest to sign a transaction or a message
                Log.i("Dev", "---- onSessionRequest ----")
                println("walDel sessionRequest $sessionRequest")
                request = sessionRequest
                runOnUiThread {
                    channel.invokeMethod("sessionRequest", sessionRequest)
                }
                println("walDel sessionRequest method invoked $sessionRequest")
            }

            override fun onSessionDelete(deletedSession: Sign.Model.DeletedSession) {
                // Triggered when the session is deleted by the peer
                runOnUiThread {
                    channel.invokeMethod("deletedSession", null)
                }
            }

            override fun onSessionSettleResponse(settleSessionResponse: Sign.Model.SettledSessionResponse) {
                // Triggered when wallet receives the session settlement response from Dapp
                val sessions = SignClient.getListOfSettledSessions()
                sessionsModel = sessions
                runOnUiThread {
                    channel.invokeMethod("settleSessionResponse", sessions.first().expiry)
                }
            }

            override fun onSessionUpdateResponse(sessionUpdateResponse: Sign.Model.SessionUpdateResponse) {
                // Triggered when wallet receives the session update response from Dapp
                runOnUiThread {
                    channel.invokeMethod("sessionUpdateResponse", sessionUpdateResponse)
                }

            }

            override fun onConnectionStateChange(state: Sign.Model.ConnectionState) {
                println("connectionStateChanged")
                runOnUiThread {
                    channel.invokeMethod("connectionStateChange", null)
                }
            }

        }
        SignClient.setWalletDelegate(walletDelegate)

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
                val accounts: List<String> = call.arguments()!!
                val methods: List<String> =
                    proposal.requiredNamespaces[proposal.requiredNamespaces.keys.first()]!!.methods
                val events: List<String> =
                    proposal.requiredNamespaces[proposal.requiredNamespaces.keys.first()]!!.events
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
                val rejectionReason = "Reject Session by Wallet"
                val proposalPublicKey: String = proposal.proposerPublicKey
                val reject = Sign.Params.Reject(proposalPublicKey, rejectionReason, 5000)

                SignClient.rejectSession(reject) { error: Sign.Model.Error ->
                    result.error(
                        "408",
                        "Sign Client Reject Session Failed ${error.throwable.message}",
                        null
                    )
                }
            }
            if (call.method == "disconnectSession") {
                val sessionTopic: String = sessionsModel.first().topic
                val disconnectParams = Sign.Params.Disconnect(sessionTopic)
                SignClient.disconnect(disconnectParams) { error: Sign.Model.Error ->
                    result.error(
                        "408",
                        "Sign Client Disconnect Session Failed ${error.throwable.message}",
                        null
                    )
                }
            }

            if (call.method == "responseRequest") {

                val sessionTopic: String = request.topic
                val jsonRpcResponse: Sign.Model.JsonRpcResponse.JsonRpcResult =
                    Sign.Model.JsonRpcResponse.JsonRpcResult(
                        request.request.id,
                        call.arguments as String,
                    )
                val request = Sign.Params.Response(
                    sessionTopic = sessionTopic,
                    jsonRpcResponse = jsonRpcResponse
                )

                SignClient.respond(request) { error ->
                    result.error(
                        "408",
                        "Sign Client Response Request Failed ${error.throwable.message}",
                        null
                    )
                }
            }
        }
    }
}

@Serializable
data class SessionProposalModel(
    val name: String,
    val description: String,
    val url: String,
    val icons: List<String>,
    val requiredNamespaces: String,
    val proposal: ProposalModel,
    val proposerPublicKey: String,
    val relayProtocol: String,
    val relayData: String?,
)

@Serializable
data class ProposalModel(
    val chains: List<String>?,
    val methods: List<String>?,
    val events: List<String>?,
)

