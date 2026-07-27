//
//  H5BrowserScreen_solva.swift
//  Solva
//
//  内嵌 H5 的浏览页面。
//  设计思路：H5WebViewRepresentable_solva 只做 UIViewRepresentable 搬运（把
//  manager_solva 持有的 WKWebView 接入 SwiftUI 视图树，不含业务判断）；
//  页面本体仅顶部保留系统安全区间距（非沉浸式，避免遮挡刘海/灵动岛），底部铺满到
//  屏幕边缘；最底层铺一层纯黑背景，顶部安全区空出的区域露出的是黑色而非系统默认
//  白色。右上角统一叠加一个关闭按钮，可信域名下回调外部传入的 onClose_solva，
//  不受信任域名下则直接回退到可信入口，所有判断逻辑读取自 H5WebViewManager_solva
//  的响应式属性，本文件不编写业务判断。
//

import SwiftUI
import WebKit

/// WKWebView 的 SwiftUI 薄封装，不含业务逻辑
private struct H5WebViewRepresentable_solva: UIViewRepresentable {
    let webView_solva: WKWebView

    func makeUIView(context: Context) -> WKWebView { webView_solva }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

/// H5 浏览页面
struct H5BrowserScreen_solva: View {

    /// 目标 H5 地址；缺省加载 H5BridgeConfig_solva.entryURLString_solva
    let urlString_solva: String

    /// 整屏关闭回调；由展示方（如 H5BrowserPresenter_solva）注入，本视图不关心具体关闭方式，
    /// 传 nil 时不展示右上角关闭按钮
    let onClose_solva: (() -> Void)?

    @StateObject private var manager_solva = H5WebViewManager_solva()

    init(urlString_solva: String = H5BridgeConfig_solva.entryURLString_solva, onClose_solva: (() -> Void)? = nil) {
        self.urlString_solva = urlString_solva
        self.onClose_solva = onClose_solva
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 最底层纯黑背景：顶部安全区留白处露出黑色，而非系统默认白色
            Color.black.ignoresSafeArea()

            // 顶部保留安全区间距（非沉浸式，避免遮挡刘海/灵动岛），底部铺满到屏幕边缘
            H5WebViewRepresentable_solva(webView_solva: manager_solva.webView_solva)
                .ignoresSafeArea(edges: .bottom)

            if onClose_solva != nil || manager_solva.isOnUntrustedDomain_solva {
                closeButtonBar_solva
            }
        }
        .onAppear {
            AirbridgeSDKManager_solva.shared_solva.requestTrackingAuthorizationIfNeeded_solva()
            manager_solva.load_solva(urlString_solva: urlString_solva)
        }
    }

    /// 右上角关闭按钮：可信域名下整屏退出 H5 浏览页面，不受信任域名下先回退到可信入口
    private var closeButtonBar_solva: some View {
        HStack {
            Spacer()
            Button(action: handleClose_solva) {
                Image(systemName: "xmark")
                    .font(.casinoBody_solva(15, weight: .semibold))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                    .padding(10.0)
                    .background(Palette_solva.panel_solva.alpha_solva(0.92))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 12.0)
        .padding(.horizontal, 16.0)
    }

    /// 关闭按钮统一入口：不受信任域名优先回退到可信入口，否则走外部注入的整屏关闭回调
    private func handleClose_solva() {
        if manager_solva.isOnUntrustedDomain_solva {
            manager_solva.closeToEntry_solva()
        } else {
            onClose_solva?()
        }
    }
}
