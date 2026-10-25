import SwiftUI
import WebKit

struct BrowserView: View {
    @State private var urlField = "https://duckduckgo.com"
    @State private var currentURL = URL(string: "https://duckduckgo.com")!
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = false
    @State private var goBackTrigger = 0
    @State private var goForwardTrigger = 0
    @State private var reloadTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button { goBackTrigger += 1 } label: { Image(systemName: "chevron.left") }
                    .disabled(!canGoBack)
                Button { goForwardTrigger += 1 } label: { Image(systemName: "chevron.right") }
                    .disabled(!canGoForward)
                TextField("Search or enter address", text: $urlField)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.webSearch)
                    .onSubmit { navigate() }
                if isLoading {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Button { reloadTrigger += 1 } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)

            WebViewRepresentable(url: $currentURL, canGoBack: $canGoBack, canGoForward: $canGoForward,
                                 isLoading: $isLoading, goBack: goBackTrigger, goForward: goForwardTrigger,
                                 reload: reloadTrigger)
        }
        .background(Color(.systemBackground))
    }

    private func navigate() {
        var text = urlField.trimmingCharacters(in: .whitespaces)
        let looksLikeURL = text.contains(".") && !text.contains(" ")
        if looksLikeURL {
            if !text.hasPrefix("http://") && !text.hasPrefix("https://") { text = "https://" + text }
            if let u = URL(string: text) { currentURL = u }
        } else if let q = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let u = URL(string: "https://duckduckgo.com/?q=\(q)") {
            currentURL = u
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    @Binding var url: URL
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    let goBack: Int
    let goForward: Int
    let reload: Int

    func makeUIView(context: Context) -> WKWebView {
        let v = WKWebView()
        v.navigationDelegate = context.coordinator
        v.load(URLRequest(url: url))
        return v
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastLoadedURL != url {
            context.coordinator.lastLoadedURL = url
            webView.load(URLRequest(url: url))
        }
        if context.coordinator.lastBack != goBack { context.coordinator.lastBack = goBack; webView.goBack() }
        if context.coordinator.lastForward != goForward { context.coordinator.lastForward = goForward; webView.goForward() }
        if context.coordinator.lastReload != reload { context.coordinator.lastReload = reload; webView.reload() }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable
        var lastLoadedURL: URL?
        var lastBack = 0, lastForward = 0, lastReload = 0
        init(_ p: WebViewRepresentable) { parent = p; lastLoadedURL = p.url }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation nav: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish nav: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
        func webView(_ webView: WKWebView, didFail nav: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}
