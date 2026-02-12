import SwiftUI
import WebKit

// MARK: - 协议助手
// 核心作用：提供协议相关的UI组件和配置
// 设计思路：模块化设计，支持多种协议类型和展示方式

/// 协议类型枚举
enum ProtocolType_platbell: Identifiable {
    case terms_platbell
    case privacy_platbell
    case eula_platbell
    case custom_platbell(String)
    
    var id: String {
        switch self {
        case .terms_platbell: return "terms"
        case .privacy_platbell: return "privacy"
        case .eula_platbell: return "eula"
        case .custom_platbell(let title): return "custom_\(title)"
        }
    }
    
    var title_platbell: String {
        switch self {
        case .terms_platbell: return "Terms of Service"
        case .privacy_platbell: return "Privacy Policy"
        case .eula_platbell: return "EULA"
        case .custom_platbell(let title): return title
        }
    }
}

// MARK: - 协议文本配置

/// 协议文本配置结构体
struct ProtocolTextConfig_platbell {
    var textColor_platbell: Color = .gray
    var linkColor_platbell: Color = .black
    var fontSize_platbell: CGFloat = 12
    var fontWeight_platbell: Font.Weight = .regular
    var hasUnderline_platbell: Bool = true
    var prefixText_platbell: String = "By continuing you agree with "
    var separatorText_platbell: String = " & "
    
    static func light_platbell() -> Self {
        Self(textColor_platbell: Color.black.opacity(0.6), linkColor_platbell: .black)
    }
    
    static func dark_platbell() -> Self {
        Self(textColor_platbell: Color.white.opacity(0.6), linkColor_platbell: .white)
    }
}

// MARK: - 协议文本视图

/// 协议文本视图
struct ProtocolTextView_platbell: View {
    
    let firstProtocol_platbell: ProtocolType_platbell
    let firstContent_platbell: String
    let secondProtocol_platbell: ProtocolType_platbell
    let secondContent_platbell: String
    let config_platbell: ProtocolTextConfig_platbell
    
    @State private var activeProtocol_platbell: ProtocolType_platbell?
    
    init(
        firstProtocol_platbell: ProtocolType_platbell = .terms_platbell,
        firstContent_platbell: String,
        secondProtocol_platbell: ProtocolType_platbell = .privacy_platbell,
        secondContent_platbell: String,
        config_platbell: ProtocolTextConfig_platbell = .light_platbell()
    ) {
        self.firstProtocol_platbell = firstProtocol_platbell
        self.firstContent_platbell = firstContent_platbell
        self.secondProtocol_platbell = secondProtocol_platbell
        self.secondContent_platbell = secondContent_platbell
        self.config_platbell = config_platbell
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(config_platbell.prefixText_platbell)
                .protocolTextStyle_platbell(config: config_platbell)
            
            protocolButton_platbell(
                protocol_platbell: firstProtocol_platbell,
                suffix_platbell: ""
            )
            
            Text(config_platbell.separatorText_platbell)
                .protocolTextStyle_platbell(config: config_platbell)
            
            protocolButton_platbell(
                protocol_platbell: secondProtocol_platbell,
                suffix_platbell: "."
            )
        }
        .multilineTextAlignment(.center)
        .sheet(item: $activeProtocol_platbell) { protocol_platbell in
            protocolSheet_platbell(for: protocol_platbell)
        }
    }
    
    // MARK: - 辅助视图
    
    /// 协议按钮
    private func protocolButton_platbell(
        protocol_platbell: ProtocolType_platbell,
        suffix_platbell: String
    ) -> some View {
        Button {
            activeProtocol_platbell = protocol_platbell
        } label: {
            Text(protocol_platbell.title_platbell + suffix_platbell)
                .protocolTextStyle_platbell(config: config_platbell, isLink: true)
        }
    }
    
    /// 协议弹窗
    private func protocolSheet_platbell(for protocol_platbell: ProtocolType_platbell) -> some View {
        NavigationStack {
            ProtocolContentView_platbell(
                type_platbell: protocol_platbell,
                content_platbell: contentFor_platbell(protocol_platbell)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        activeProtocol_platbell = nil
                    }
                }
            }
        }
    }
    
    /// 获取协议内容
    private func contentFor_platbell(_ protocol_platbell: ProtocolType_platbell) -> String {
        switch protocol_platbell.id {
        case firstProtocol_platbell.id:
            return firstContent_platbell
        default:
            return secondContent_platbell
        }
    }
}

// MARK: - 协议内容视图

/// 协议内容视图
struct ProtocolContentView_platbell: View {
    
    let type_platbell: ProtocolType_platbell
    let content_platbell: String
    
    var body: some View {
        contentView_platbell
            .navigationTitle(type_platbell.title_platbell)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var contentView_platbell: some View {
        if content_platbell.hasPrefix("http") {
            WebView_platbell(urlString_platbell: content_platbell)
        } else if content_platbell.hasSuffix(".png") || 
                    content_platbell.hasSuffix(".jpg") || 
                    content_platbell.hasSuffix(".jpeg") {
            imageView_platbell
        } else {
            textView_platbell
        }
    }
    
    private var imageView_platbell: some View {
        ScrollView {
            if let image = UIImage(named: content_platbell) {
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
    
    private var textView_platbell: some View {
        ScrollView {
            Text(content_platbell)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .padding()
        }
    }
}

// MARK: - WebView 包装器

/// WebView 包装器
struct WebView_platbell: UIViewRepresentable {
    
    let urlString_platbell: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString_platbell) else { return }
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
    fileprivate func protocolTextStyle_platbell(
        config: ProtocolTextConfig_platbell,
        isLink: Bool = false
    ) -> some View {
        self
            .font(.system(size: config.fontSize_platbell, weight: config.fontWeight_platbell))
            .foregroundColor(isLink ? config.linkColor_platbell : config.textColor_platbell)
            .underline(isLink && config.hasUnderline_platbell)
    }
}
