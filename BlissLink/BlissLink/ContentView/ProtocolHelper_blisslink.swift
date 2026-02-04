import SwiftUI
import WebKit

// MARK: - 协议助手
// 核心作用：提供协议相关的UI组件和配置
// 设计思路：模块化设计，支持多种协议类型和展示方式

/// 协议类型枚举
enum ProtocolType_blisslink: Identifiable {
    case terms_blisslink
    case privacy_blisslink
    case eula_blisslink
    case custom_blisslink(String)
    
    var id: String {
        switch self {
        case .terms_blisslink: return "terms"
        case .privacy_blisslink: return "privacy"
        case .eula_blisslink: return "eula"
        case .custom_blisslink(let title): return "custom_\(title)"
        }
    }
    
    var title_blisslink: String {
        switch self {
        case .terms_blisslink: return "Terms of Service"
        case .privacy_blisslink: return "Privacy Policy"
        case .eula_blisslink: return "EULA"
        case .custom_blisslink(let title): return title
        }
    }
}

// MARK: - 协议文本配置

/// 协议文本配置结构体
struct ProtocolTextConfig_blisslink {
    var textColor_blisslink: Color = .gray
    var linkColor_blisslink: Color = .black
    var fontSize_blisslink: CGFloat = 12
    var fontWeight_blisslink: Font.Weight = .regular
    var hasUnderline_blisslink: Bool = true
    var prefixText_blisslink: String = "By continuing you agree with "
    var separatorText_blisslink: String = " & "
    
    static func light_blisslink() -> Self {
        Self(textColor_blisslink: Color.black.opacity(0.6), linkColor_blisslink: .black)
    }
    
    static func dark_blisslink() -> Self {
        Self(textColor_blisslink: Color.white.opacity(0.6), linkColor_blisslink: .white)
    }
}

// MARK: - 协议文本视图

/// 协议文本视图
struct ProtocolTextView_blisslink: View {
    
    let firstProtocol_blisslink: ProtocolType_blisslink
    let firstContent_blisslink: String
    let secondProtocol_blisslink: ProtocolType_blisslink
    let secondContent_blisslink: String
    let config_blisslink: ProtocolTextConfig_blisslink
    
    @State private var activeProtocol_blisslink: ProtocolType_blisslink?
    
    init(
        firstProtocol_blisslink: ProtocolType_blisslink = .terms_blisslink,
        firstContent_blisslink: String,
        secondProtocol_blisslink: ProtocolType_blisslink = .privacy_blisslink,
        secondContent_blisslink: String,
        config_blisslink: ProtocolTextConfig_blisslink = .light_blisslink()
    ) {
        self.firstProtocol_blisslink = firstProtocol_blisslink
        self.firstContent_blisslink = firstContent_blisslink
        self.secondProtocol_blisslink = secondProtocol_blisslink
        self.secondContent_blisslink = secondContent_blisslink
        self.config_blisslink = config_blisslink
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(config_blisslink.prefixText_blisslink)
                .protocolTextStyle_blisslink(config: config_blisslink)
            
            protocolButton_blisslink(
                protocol_blisslink: firstProtocol_blisslink,
                suffix_blisslink: ""
            )
            
            Text(config_blisslink.separatorText_blisslink)
                .protocolTextStyle_blisslink(config: config_blisslink)
            
            protocolButton_blisslink(
                protocol_blisslink: secondProtocol_blisslink,
                suffix_blisslink: "."
            )
        }
        .multilineTextAlignment(.center)
        .sheet(item: $activeProtocol_blisslink) { protocol_blisslink in
            protocolSheet_blisslink(for: protocol_blisslink)
        }
    }
    
    // MARK: - 辅助视图
    
    /// 协议按钮
    private func protocolButton_blisslink(
        protocol_blisslink: ProtocolType_blisslink,
        suffix_blisslink: String
    ) -> some View {
        Button {
            activeProtocol_blisslink = protocol_blisslink
        } label: {
            Text(protocol_blisslink.title_blisslink + suffix_blisslink)
                .protocolTextStyle_blisslink(config: config_blisslink, isLink: true)
        }
    }
    
    /// 协议弹窗
    private func protocolSheet_blisslink(for protocol_blisslink: ProtocolType_blisslink) -> some View {
        NavigationStack {
            ProtocolContentView_blisslink(
                type_blisslink: protocol_blisslink,
                content_blisslink: contentFor_blisslink(protocol_blisslink)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        activeProtocol_blisslink = nil
                    }
                }
            }
        }
    }
    
    /// 获取协议内容
    private func contentFor_blisslink(_ protocol_blisslink: ProtocolType_blisslink) -> String {
        switch protocol_blisslink.id {
        case firstProtocol_blisslink.id:
            return firstContent_blisslink
        default:
            return secondContent_blisslink
        }
    }
}

// MARK: - 协议内容视图

/// 协议内容视图
struct ProtocolContentView_blisslink: View {
    
    let type_blisslink: ProtocolType_blisslink
    let content_blisslink: String
    
    var body: some View {
        contentView_blisslink
            .navigationTitle(type_blisslink.title_blisslink)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var contentView_blisslink: some View {
        if content_blisslink.hasPrefix("http") {
            WebView_blisslink(urlString_blisslink: content_blisslink)
        } else if content_blisslink.hasSuffix(".png") || 
                    content_blisslink.hasSuffix(".jpg") || 
                    content_blisslink.hasSuffix(".jpeg") {
            imageView_blisslink
        } else {
            textView_blisslink
        }
    }
    
    private var imageView_blisslink: some View {
        ScrollView {
            if let image = UIImage(named: content_blisslink) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Image not found")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var textView_blisslink: some View {
        ScrollView {
            Text(content_blisslink)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .padding()
        }
    }
}

// MARK: - WebView 包装器

/// WebView 包装器
struct WebView_blisslink: UIViewRepresentable {
    
    let urlString_blisslink: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString_blisslink) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("🌐 开始加载网页")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ 网页加载完成")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ 网页加载失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - View 扩展

extension View {
    
    /// 协议文本样式修饰符
    fileprivate func protocolTextStyle_blisslink(
        config: ProtocolTextConfig_blisslink,
        isLink: Bool = false
    ) -> some View {
        self
            .font(.system(size: config.fontSize_blisslink, weight: config.fontWeight_blisslink))
            .foregroundColor(isLink ? config.linkColor_blisslink : config.textColor_blisslink)
            .underline(isLink && config.hasUnderline_blisslink)
    }
}
