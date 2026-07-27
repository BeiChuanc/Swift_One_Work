//
//  H5WebViewManager_solva.swift
//  Solva
//
//  H5 页面的核心逻辑层。
//  设计思路：创建满足文档第 1 章要求的 WKWebView（UA 标识、原生环境信息注入、
//  iosNative bridge 注册、Airbridge Web SDK 接入），处理导航策略、转发桥接消息，
//  并在合适时机（重复）分发 Airbridge 归因结果。UI 层只读取 @Published 状态与
//  调用本类方法，不编写业务判断，符合 UI 与逻辑解耦的约束。
//

import Foundation
import WebKit
import Combine

/// H5 WebView 生命周期与桥接调度管理器
final class H5WebViewManager_solva: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate, H5BridgeDelegate_solva {

    /// 是否可以在当前 WKWebView 内后退，用于控制悬浮条「Back」按钮的可用状态
    @Published private(set) var canGoBack_solva = false

    /// 是否已经导航到「不受信任」域名，用于驱动悬浮返回/关闭条的展示
    @Published private(set) var isOnUntrustedDomain_solva = false

    /// 对外暴露给 SwiftUI 层展示的 WKWebView 实例，全程由本类持有
    let webView_solva: WKWebView

    private let bridgeHandler_solva = IOSNativeBridgeHandler_solva()
    private var attributionObserver_solva: NSObjectProtocol?

    override init() {
        let userContentController_solva = WKUserContentController()
        userContentController_solva.add(bridgeHandler_solva, name: H5BridgeConfig_solva.nativeBridgeHandlerName_solva)
        userContentController_solva.addUserScript(H5BridgeConfig_solva.nativeInfoUserScript_solva)

        // 必须在创建 WKWebView 之前完成 Airbridge Web SDK 接入，
        // 保证 H5 侧 Web SDK 事件与本 App 的原生归因数据落在同一个 Airbridge App 下
        AirbridgeSDKManager_solva.shared_solva.setWebInterface_solva(controller: userContentController_solva)

        let configuration_solva = WKWebViewConfiguration()
        configuration_solva.userContentController = userContentController_solva
        configuration_solva.preferences.javaScriptCanOpenWindowsAutomatically = true
        // 只追加 App 标识，系统默认 UA 前半部分保持不变，H5 通过检测 UA 里的 App 标识片段识别 App 环境
        configuration_solva.applicationNameForUserAgent = H5BridgeConfig_solva.userAgentSuffix_solva

        webView_solva = WKWebView(frame: .zero, configuration: configuration_solva)

        super.init()

        bridgeHandler_solva.delegate_solva = self
        webView_solva.navigationDelegate = self
        webView_solva.uiDelegate = self
        webView_solva.allowsBackForwardNavigationGestures = true

        attributionObserver_solva = NotificationCenter.default.addObserver(
            forName: .airbridgeAttributionReceived_solva,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Airbridge SDK 异步返回归因结果时，补发一次
            self?.dispatchAttributionIfAvailable_solva()
        }
    }

    deinit {
        if let attributionObserver_solva {
            NotificationCenter.default.removeObserver(attributionObserver_solva)
        }
        // WKUserContentController 会强引用 messageHandler，必须显式移除，避免内存泄漏
        webView_solva.configuration.userContentController.removeScriptMessageHandler(
            forName: H5BridgeConfig_solva.nativeBridgeHandlerName_solva
        )
    }

    /// 加载指定 H5 地址
    /// - Parameter urlString_solva: 目标地址，缺省使用 H5BridgeConfig_solva.entryURLString_solva
    func load_solva(urlString_solva: String = H5BridgeConfig_solva.entryURLString_solva) {
        guard let url_solva = URL(string: urlString_solva) else {
            print("H5 地址无法解析：\(urlString_solva)")
            return
        }
        webView_solva.load(URLRequest(url: url_solva))
    }

    /// 悬浮条「Back」按钮动作：在 WKWebView 内部后退
    func goBack_solva() {
        guard webView_solva.canGoBack else { return }
        webView_solva.goBack()
    }

    /// 悬浮条「Close」按钮动作：直接回到 H5 主入口，脱离当前不受信任域名
    func closeToEntry_solva() {
        load_solva()
    }

    // MARK: WKNavigationDelegate

    /// 导航策略：非 http/https 的外部 scheme（钱包、银行 App、电话、短信等）一律不在主
    /// WKWebView 内承接，转交 ExternalBrowserPresenter_solva 用系统方式打开
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url_solva = navigationAction.request.url, let scheme_solva = url_solva.scheme?.lowercased() else {
            decisionHandler(.allow)
            return
        }

        guard scheme_solva == "http" || scheme_solva == "https" else {
            decisionHandler(.cancel)
            ExternalBrowserPresenter_solva.shared_solva.present_solva(urlString: url_solva.absoluteString, from: nil)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        canGoBack_solva = webView.canGoBack
        isOnUntrustedDomain_solva = !isTrustedHost_solva(webView.url)
        dispatchAttributionIfAvailable_solva()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WKWebView 加载失败：\(error)")
    }

    /// 判断当前 URL 的 host 是否在可信域名白名单内
    private func isTrustedHost_solva(_ url_solva: URL?) -> Bool {
        guard let host_solva = url_solva?.host else { return false }
        return H5BridgeConfig_solva.trustedHosts_solva.contains(host_solva)
    }

    /// 若本地已经缓存归因结果，则重新分发一次；覆盖「首次加载完成」「SDK 异步回调到达」
    /// 「WebView 页面刷新」三种需要补发的场景
    private func dispatchAttributionIfAvailable_solva() {
        guard let raw_solva = AirbridgeSDKManager_solva.shared_solva.latestAttribution_solva as? [String: String] else {
            return
        }
        let payload_solva = AirbridgeAttributionDispatcher_solva.buildPayload_solva(rawAttribution_solva: raw_solva)
        AirbridgeAttributionDispatcher_solva.dispatch_solva(payload_solva: payload_solva, to: webView_solva)
    }

    // MARK: H5BridgeDelegate_solva

    func h5Bridge_solva(_ handler_solva: IOSNativeBridgeHandler_solva, didRequestOpenByBrowser urlString_solva: String) {
        ExternalBrowserPresenter_solva.shared_solva.present_solva(urlString: urlString_solva, from: nil)
    }
}
