import Foundation
import WebKit

final class Web3InboxClientFactory {

    static func create(
        chatClient: ChatClient,
        pushClient: WalletPushClient,
        account: Account,
        config: [ConfigParam: Bool],
        onSign: @escaping SigningCallback
    ) -> Web3InboxClient {
        let url = buildUrl(account: account, config: config)
        let logger = ConsoleLogger(suffix: "📬", loggingLevel: .debug)
        let chatWebviewSubscriber = WebViewRequestSubscriber(logger: logger)
        let pushWebviewSubscriber = WebViewRequestSubscriber(logger: logger)
        let webView = WebViewFactory(url: url, chatWebviewSubscriber: chatWebviewSubscriber, pushWebviewSubscriber: pushWebviewSubscriber).create()
        let chatWebViewProxy = WebViewProxy(webView: webView, scriptFormatter: ChatWebViewScriptFormatter(), logger: logger)
        let pushWebViewProxy = WebViewProxy(webView: webView, scriptFormatter: PushWebViewScriptFormatter(), logger: logger)

        let clientProxy = ChatClientProxy(client: chatClient, onSign: onSign)
        let clientSubscriber = ChatClientRequestSubscriber(chatClient: chatClient, logger: logger)

        let pushClientProxy = PushClientProxy(client: pushClient, onSign: onSign)
        let pushClientSubscriber = PushClientRequestSubscriber(client: pushClient, logger: logger)

        let webViewRefreshHandler = WebViewRefreshHandler(webView: webView, initUrl: url, logger: logger)

        return Web3InboxClient(
            webView: webView,
            account: account,
            logger: logger,
            chatClientProxy: clientProxy,
            clientSubscriber: clientSubscriber,
            chatWebviewProxy: chatWebViewProxy,
            pushWebviewProxy: pushWebViewProxy,
            chatWebviewSubscriber: chatWebviewSubscriber,
            pushWebviewSubscriber: pushWebviewSubscriber,
            pushClientProxy: pushClientProxy,
            pushClientSubscriber: pushClientSubscriber,
            pushClient: pushClient,
            webViewRefreshHandler: webViewRefreshHandler
        )
    }

    private static func buildUrl(account: Account, config: [ConfigParam: Bool]) -> URL {
        // TODO: Revert url after testing session !!!
        var urlComponents = URLComponents(string: "https://web3inbox-dev-hidden-git-feature-push-sync-walletconnect1.vercel.app/")!
        var queryItems = [URLQueryItem(name: "chatProvider", value: "ios"), URLQueryItem(name: "pushProvider", value: "ios"), URLQueryItem(name: "account", value: account.address), URLQueryItem(name: "authProvider", value: "ios")]

        for param in config.filter({ $0.value == false}) {
            queryItems.append(URLQueryItem(name: "\(param.key)", value: "false"))
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
