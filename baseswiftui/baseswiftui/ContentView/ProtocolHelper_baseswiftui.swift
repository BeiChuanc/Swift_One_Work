import SwiftUI
import WebKit

// MARK: - 协议助手
// 核心作用：提供协议相关的UI组件和配置
// 设计思路：模块化设计，支持多种协议类型和展示方式

/// 协议类型枚举
enum ProtocolType_baseswiftui: Identifiable {
    case terms_baseswiftui
    case privacy_baseswiftui
    case eula_baseswiftui
    case custom_baseswiftui(String)
    
    var id: String {
        switch self {
        case .terms_baseswiftui: return "terms"
        case .privacy_baseswiftui: return "privacy"
        case .eula_baseswiftui: return "eula"
        case .custom_baseswiftui(let title): return "custom_\(title)"
        }
    }
    
    var title_baseswiftui: String {
        switch self {
        case .terms_baseswiftui: return "Terms of Service"
        case .privacy_baseswiftui: return "Privacy Policy"
        case .eula_baseswiftui: return "EULA"
        case .custom_baseswiftui(let title): return title
        }
    }
}

// MARK: - 协议文本配置

/// 协议文本配置结构体
struct ProtocolTextConfig_baseswiftui {
    var textColor_baseswiftui: Color = .gray
    var linkColor_baseswiftui: Color = .black
    var fontSize_baseswiftui: CGFloat = 12
    var fontWeight_baseswiftui: Font.Weight = .regular
    var hasUnderline_baseswiftui: Bool = true
    var prefixText_baseswiftui: String = "By continuing you agree with "
    var separatorText_baseswiftui: String = " & "
    
    static func light_baseswiftui() -> Self {
        Self(textColor_baseswiftui: Color.black.opacity(0.6), linkColor_baseswiftui: .black)
    }
    
    static func dark_baseswiftui() -> Self {
        Self(textColor_baseswiftui: Color.white.opacity(0.6), linkColor_baseswiftui: .white)
    }
}

// MARK: - 协议文本视图

/// 协议文本视图
struct ProtocolTextView_baseswiftui: View {
    
    let firstProtocol_baseswiftui: ProtocolType_baseswiftui
    let firstContent_baseswiftui: String
    let secondProtocol_baseswiftui: ProtocolType_baseswiftui
    let secondContent_baseswiftui: String
    let config_baseswiftui: ProtocolTextConfig_baseswiftui
    
    @State private var activeProtocol_baseswiftui: ProtocolType_baseswiftui?
    
    init(
        firstProtocol_baseswiftui: ProtocolType_baseswiftui = .terms_baseswiftui,
        firstContent_baseswiftui: String,
        secondProtocol_baseswiftui: ProtocolType_baseswiftui = .privacy_baseswiftui,
        secondContent_baseswiftui: String,
        config_baseswiftui: ProtocolTextConfig_baseswiftui = .light_baseswiftui()
    ) {
        self.firstProtocol_baseswiftui = firstProtocol_baseswiftui
        self.firstContent_baseswiftui = firstContent_baseswiftui
        self.secondProtocol_baseswiftui = secondProtocol_baseswiftui
        self.secondContent_baseswiftui = secondContent_baseswiftui
        self.config_baseswiftui = config_baseswiftui
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(config_baseswiftui.prefixText_baseswiftui)
                .protocolTextStyle_baseswiftui(config: config_baseswiftui)
            
            protocolButton_baseswiftui(
                protocol_baseswiftui: firstProtocol_baseswiftui,
                suffix_baseswiftui: ""
            )
            
            Text(config_baseswiftui.separatorText_baseswiftui)
                .protocolTextStyle_baseswiftui(config: config_baseswiftui)
            
            protocolButton_baseswiftui(
                protocol_baseswiftui: secondProtocol_baseswiftui,
                suffix_baseswiftui: "."
            )
        }
        .multilineTextAlignment(.center)
        .sheet(item: $activeProtocol_baseswiftui) { protocol_baseswiftui in
            protocolSheet_baseswiftui(for: protocol_baseswiftui)
        }
    }
    
    // MARK: - 辅助视图
    
    /// 协议按钮
    private func protocolButton_baseswiftui(
        protocol_baseswiftui: ProtocolType_baseswiftui,
        suffix_baseswiftui: String
    ) -> some View {
        Button {
            activeProtocol_baseswiftui = protocol_baseswiftui
        } label: {
            Text(protocol_baseswiftui.title_baseswiftui + suffix_baseswiftui)
                .protocolTextStyle_baseswiftui(config: config_baseswiftui, isLink: true)
        }
    }
    
    /// 协议弹窗
    private func protocolSheet_baseswiftui(for protocol_baseswiftui: ProtocolType_baseswiftui) -> some View {
        NavigationStack {
            ProtocolContentView_baseswiftui(
                type_baseswiftui: protocol_baseswiftui,
                content_baseswiftui: contentFor_baseswiftui(protocol_baseswiftui)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        activeProtocol_baseswiftui = nil
                    }
                }
            }
        }
    }
    
    /// 获取协议内容
    private func contentFor_baseswiftui(_ protocol_baseswiftui: ProtocolType_baseswiftui) -> String {
        switch protocol_baseswiftui.id {
        case firstProtocol_baseswiftui.id:
            return firstContent_baseswiftui
        default:
            return secondContent_baseswiftui
        }
    }
}

// MARK: - 协议内容视图

/// 协议内容视图
struct ProtocolContentView_baseswiftui: View {
    
    let type_baseswiftui: ProtocolType_baseswiftui
    let content_baseswiftui: String
    
    var body: some View {
        contentView_baseswiftui
            .navigationTitle(type_baseswiftui.title_baseswiftui)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var contentView_baseswiftui: some View {
        if content_baseswiftui.hasPrefix("http") {
            WebView_baseswiftui(urlString_baseswiftui: content_baseswiftui)
        } else if content_baseswiftui.hasSuffix(".png") || 
                    content_baseswiftui.hasSuffix(".jpg") || 
                    content_baseswiftui.hasSuffix(".jpeg") {
            imageView_baseswiftui
        } else {
            textView_baseswiftui
        }
    }
    
    private var imageView_baseswiftui: some View {
        ScrollView {
            if let image = UIImage(named: content_baseswiftui) {
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
    
    private var textView_baseswiftui: some View {
        ScrollView {
            Text(content_baseswiftui)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .padding()
        }
    }
}

// MARK: - WebView 包装器

/// WebView 包装器
struct WebView_baseswiftui: UIViewRepresentable {
    
    let urlString_baseswiftui: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString_baseswiftui) else { return }
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
    fileprivate func protocolTextStyle_baseswiftui(
        config: ProtocolTextConfig_baseswiftui,
        isLink: Bool = false
    ) -> some View {
        self
            .font(.system(size: config.fontSize_baseswiftui, weight: config.fontWeight_baseswiftui))
            .foregroundColor(isLink ? config.linkColor_baseswiftui : config.textColor_baseswiftui)
            .underline(isLink && config.hasUnderline_baseswiftui)
    }
}
