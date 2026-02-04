import SwiftUI
import WebKit

// MARK: - 协议助手
// 核心作用：提供协议相关的UI组件和配置
// 设计思路：模块化设计，支持多种协议类型和展示方式

/// 协议类型枚举
enum ProtocolType_lite: Identifiable {
    case terms_lite
    case privacy_lite
    case eula_lite
    case custom_lite(String)
    
    var id: String {
        switch self {
        case .terms_lite: return "terms"
        case .privacy_lite: return "privacy"
        case .eula_lite: return "eula"
        case .custom_lite(let title): return "custom_\(title)"
        }
    }
    
    var title_lite: String {
        switch self {
        case .terms_lite: return "Terms of Service"
        case .privacy_lite: return "Privacy Policy"
        case .eula_lite: return "EULA"
        case .custom_lite(let title): return title
        }
    }
}

// MARK: - 协议文本配置

/// 协议文本配置结构体
struct ProtocolTextConfig_lite {
    var textColor_lite: Color = .gray
    var linkColor_lite: Color = .black
    var fontSize_lite: CGFloat = 12
    var fontWeight_lite: Font.Weight = .regular
    var hasUnderline_lite: Bool = true
    var prefixText_lite: String = "By continuing you agree with "
    var separatorText_lite: String = " & "
    
    static func light_lite() -> Self {
        Self(textColor_lite: Color.black.opacity(0.6), linkColor_lite: .black)
    }
    
    static func dark_lite() -> Self {
        Self(textColor_lite: Color.white.opacity(0.6), linkColor_lite: .white)
    }
}

// MARK: - 协议文本视图

/// 协议文本视图
struct ProtocolTextView_lite: View {
    
    let firstProtocol_lite: ProtocolType_lite
    let firstContent_lite: String
    let secondProtocol_lite: ProtocolType_lite
    let secondContent_lite: String
    let config_lite: ProtocolTextConfig_lite
    
    @State private var activeProtocol_lite: ProtocolType_lite?
    
    init(
        firstProtocol_lite: ProtocolType_lite = .terms_lite,
        firstContent_lite: String,
        secondProtocol_lite: ProtocolType_lite = .privacy_lite,
        secondContent_lite: String,
        config_lite: ProtocolTextConfig_lite = .light_lite()
    ) {
        self.firstProtocol_lite = firstProtocol_lite
        self.firstContent_lite = firstContent_lite
        self.secondProtocol_lite = secondProtocol_lite
        self.secondContent_lite = secondContent_lite
        self.config_lite = config_lite
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(config_lite.prefixText_lite)
                .protocolTextStyle_lite(config: config_lite)
            
            protocolButton_lite(
                protocol_lite: firstProtocol_lite,
                suffix_lite: ""
            )
            
            Text(config_lite.separatorText_lite)
                .protocolTextStyle_lite(config: config_lite)
            
            protocolButton_lite(
                protocol_lite: secondProtocol_lite,
                suffix_lite: "."
            )
        }
        .multilineTextAlignment(.center)
        .sheet(item: $activeProtocol_lite) { protocol_lite in
            protocolSheet_lite(for: protocol_lite)
        }
    }
    
    // MARK: - 辅助视图
    
    /// 协议按钮
    private func protocolButton_lite(
        protocol_lite: ProtocolType_lite,
        suffix_lite: String
    ) -> some View {
        Button {
            activeProtocol_lite = protocol_lite
        } label: {
            Text(protocol_lite.title_lite + suffix_lite)
                .protocolTextStyle_lite(config: config_lite, isLink: true)
        }
    }
    
    /// 协议弹窗
    private func protocolSheet_lite(for protocol_lite: ProtocolType_lite) -> some View {
        NavigationStack {
            ProtocolContentView_lite(
                type_lite: protocol_lite,
                content_lite: contentFor_lite(protocol_lite)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        activeProtocol_lite = nil
                    }
                }
            }
        }
    }
    
    /// 获取协议内容
    private func contentFor_lite(_ protocol_lite: ProtocolType_lite) -> String {
        switch protocol_lite.id {
        case firstProtocol_lite.id:
            return firstContent_lite
        default:
            return secondContent_lite
        }
    }
}

// MARK: - 协议内容视图

/// 协议内容视图
struct ProtocolContentView_lite: View {
    
    let type_lite: ProtocolType_lite
    let content_lite: String
    
    var body: some View {
        contentView_lite
            .navigationTitle(type_lite.title_lite)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var contentView_lite: some View {
        if content_lite.hasPrefix("http") {
            WebView_lite(urlString_lite: content_lite)
        } else if content_lite.hasSuffix(".png") || 
                    content_lite.hasSuffix(".jpg") || 
                    content_lite.hasSuffix(".jpeg") {
            imageView_lite
        } else {
            textView_lite
        }
    }
    
    private var imageView_lite: some View {
        ScrollView {
            if let image = UIImage(named: content_lite) {
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
    
    private var textView_lite: some View {
        ScrollView {
            Text(content_lite)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .padding()
        }
    }
}

// MARK: - WebView 包装器

/// WebView 包装器
struct WebView_lite: UIViewRepresentable {
    
    let urlString_lite: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString_lite) else { return }
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
    fileprivate func protocolTextStyle_lite(
        config: ProtocolTextConfig_lite,
        isLink: Bool = false
    ) -> some View {
        self
            .font(.system(size: config.fontSize_lite, weight: config.fontWeight_lite))
            .foregroundColor(isLink ? config.linkColor_lite : config.textColor_lite)
            .underline(isLink && config.hasUnderline_lite)
    }
}
