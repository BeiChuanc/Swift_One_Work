import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Trace {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Trace {
        case terms_Trace       // 服务条款
        case privacy_Trace     // 隐私政策
        case eula_Trace        // 最终用户许可协议
        case custom_Trace(String) // 自定义协议
        
        /// 获取协议标题
        var title_Trace: String {
            switch self {
            case .terms_Trace:
                return "Terms of Service"
            case .privacy_Trace:
                return "Privacy Policy"
            case .eula_Trace:
                return "EULA"
            case .custom_Trace(let title_Trace):
                return title_Trace
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Trace {
        /// 普通文本颜色
        var textColor_Trace: UIColor
        /// 链接文本颜色
        var linkColor_Trace: UIColor
        /// 字体大小
        var fontSize_Trace: CGFloat
        /// 字体粗细
        var fontWeight_Trace: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Trace: Bool
        /// 前缀文本
        var prefixText_Trace: String
        /// 分隔符文本
        var separatorText_Trace: String
        
        /// 默认初始化
        init(
            textColor_Trace: UIColor = UIColor.gray,
            linkColor_Trace: UIColor = UIColor.black,
            fontSize_Trace: CGFloat = 12,
            fontWeight_Trace: UIFont.Weight = .regular,
            hasUnderline_Trace: Bool = true,
            prefixText_Trace: String = "By continuing you agree with ",
            separatorText_Trace: String = " & "
        ) {
            self.textColor_Trace = textColor_Trace
            self.linkColor_Trace = linkColor_Trace
            self.fontSize_Trace = fontSize_Trace
            self.fontWeight_Trace = fontWeight_Trace
            self.hasUnderline_Trace = hasUnderline_Trace
            self.prefixText_Trace = prefixText_Trace
            self.separatorText_Trace = separatorText_Trace
        }
        
        /// 浅色主题配置
        static func light_Trace() -> ProtocolTextConfig_Trace {
            return ProtocolTextConfig_Trace(
                textColor_Trace: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Trace: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Trace() -> ProtocolTextConfig_Trace {
            return ProtocolTextConfig_Trace(
                textColor_Trace: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Trace: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Trace: 协议类型
    ///   - content_Trace: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Trace: 当前视图控制器
    static func showProtocol_Trace(
        type_Trace: ProtocolType_Trace,
        content_Trace: String,
        from viewController_Trace: UIViewController
    ) {
        let protocolVC_Trace = ProtocolViewController_Trace(
            type_Trace: type_Trace,
            content_Trace: content_Trace
        )
        viewController_Trace.navigationController?.pushViewController(
            protocolVC_Trace,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Trace: 第一个协议类型
    ///   - firstContent_Trace: 第一个协议内容
    ///   - secondProtocol_Trace: 第二个协议类型
    ///   - secondContent_Trace: 第二个协议内容
    ///   - config_Trace: 文本配置
    ///   - viewController_Trace: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Trace(
        firstProtocol_Trace: ProtocolType_Trace = .terms_Trace,
        firstContent_Trace: String,
        secondProtocol_Trace: ProtocolType_Trace = .privacy_Trace,
        secondContent_Trace: String,
        config_Trace: ProtocolTextConfig_Trace = .light_Trace(),
        from viewController_Trace: UIViewController
    ) -> UILabel {
        let label_Trace = UILabel()
        label_Trace.numberOfLines = 0
        label_Trace.textAlignment = .center
        label_Trace.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Trace = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Trace: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Trace.fontSize_Trace, weight: config_Trace.fontWeight_Trace),
            .foregroundColor: config_Trace.textColor_Trace
        ]
        attributedString_Trace.append(NSAttributedString(
            string: config_Trace.prefixText_Trace,
            attributes: prefixAttributes_Trace
        ))
        
        // 第一个协议链接
        var linkAttributes_Trace: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Trace.fontSize_Trace, weight: config_Trace.fontWeight_Trace),
            .foregroundColor: config_Trace.linkColor_Trace
        ]
        if config_Trace.hasUnderline_Trace {
            linkAttributes_Trace[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Trace[.underlineColor] = config_Trace.linkColor_Trace
        }
        
        let firstProtocolString_Trace = NSAttributedString(
            string: firstProtocol_Trace.title_Trace,
            attributes: linkAttributes_Trace
        )
        attributedString_Trace.append(firstProtocolString_Trace)
        
        // 分隔符
        attributedString_Trace.append(NSAttributedString(
            string: config_Trace.separatorText_Trace,
            attributes: prefixAttributes_Trace
        ))
        
        // 第二个协议链接
        let secondProtocolString_Trace = NSAttributedString(
            string: secondProtocol_Trace.title_Trace + ".",
            attributes: linkAttributes_Trace
        )
        attributedString_Trace.append(secondProtocolString_Trace)
        
        label_Trace.attributedText = attributedString_Trace
        
        // 添加点击手势
        let tapGesture_Trace = ProtocolTextTapGesture_Trace(
            firstProtocol_Trace: firstProtocol_Trace,
            firstContent_Trace: firstContent_Trace,
            secondProtocol_Trace: secondProtocol_Trace,
            secondContent_Trace: secondContent_Trace,
            prefixLength_Trace: config_Trace.prefixText_Trace.count,
            firstTitleLength_Trace: firstProtocol_Trace.title_Trace.count,
            separatorLength_Trace: config_Trace.separatorText_Trace.count,
            secondTitleLength_Trace: secondProtocol_Trace.title_Trace.count + 1,
            viewController_Trace: viewController_Trace
        )
        label_Trace.addGestureRecognizer(tapGesture_Trace)
        
        return label_Trace
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Trace: UITapGestureRecognizer {
    
    private let firstProtocol_Trace: ProtocolHelper_Trace.ProtocolType_Trace
    private let firstContent_Trace: String
    private let secondProtocol_Trace: ProtocolHelper_Trace.ProtocolType_Trace
    private let secondContent_Trace: String
    private let prefixLength_Trace: Int
    private let firstTitleLength_Trace: Int
    private let separatorLength_Trace: Int
    private let secondTitleLength_Trace: Int
    private weak var viewController_Trace: UIViewController?
    
    init(
        firstProtocol_Trace: ProtocolHelper_Trace.ProtocolType_Trace,
        firstContent_Trace: String,
        secondProtocol_Trace: ProtocolHelper_Trace.ProtocolType_Trace,
        secondContent_Trace: String,
        prefixLength_Trace: Int,
        firstTitleLength_Trace: Int,
        separatorLength_Trace: Int,
        secondTitleLength_Trace: Int,
        viewController_Trace: UIViewController
    ) {
        self.firstProtocol_Trace = firstProtocol_Trace
        self.firstContent_Trace = firstContent_Trace
        self.secondProtocol_Trace = secondProtocol_Trace
        self.secondContent_Trace = secondContent_Trace
        self.prefixLength_Trace = prefixLength_Trace
        self.firstTitleLength_Trace = firstTitleLength_Trace
        self.separatorLength_Trace = separatorLength_Trace
        self.secondTitleLength_Trace = secondTitleLength_Trace
        self.viewController_Trace = viewController_Trace
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Trace(_:)))
    }
    
    @objc private func handleTap_Trace(_ gesture: UITapGestureRecognizer) {
        guard let label_Trace = gesture.view as? UILabel,
              let attributedText_Trace = label_Trace.attributedText,
              let viewController_Trace = viewController_Trace else { return }
        
        // 计算点击位置
        let location_Trace = gesture.location(in: label_Trace)
        
        // 创建文本容器和布局管理器
        let textStorage_Trace = NSTextStorage(attributedString: attributedText_Trace)
        let layoutManager_Trace = NSLayoutManager()
        let textContainer_Trace = NSTextContainer(size: label_Trace.bounds.size)
        
        layoutManager_Trace.addTextContainer(textContainer_Trace)
        textStorage_Trace.addLayoutManager(layoutManager_Trace)
        
        textContainer_Trace.lineFragmentPadding = 0
        textContainer_Trace.maximumNumberOfLines = label_Trace.numberOfLines
        textContainer_Trace.lineBreakMode = label_Trace.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Trace = layoutManager_Trace.characterIndex(
            for: location_Trace,
            in: textContainer_Trace,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Trace = prefixLength_Trace
        let firstLinkEnd_Trace = firstLinkStart_Trace + firstTitleLength_Trace
        
        let secondLinkStart_Trace = firstLinkEnd_Trace + separatorLength_Trace
        let secondLinkEnd_Trace = secondLinkStart_Trace + secondTitleLength_Trace
        
        if characterIndex_Trace >= firstLinkStart_Trace && characterIndex_Trace < firstLinkEnd_Trace {
            // 点击第一个协议
            ProtocolHelper_Trace.showProtocol_Trace(
                type_Trace: firstProtocol_Trace,
                content_Trace: firstContent_Trace,
                from: viewController_Trace
            )
        } else if characterIndex_Trace >= secondLinkStart_Trace && characterIndex_Trace < secondLinkEnd_Trace {
            // 点击第二个协议
            ProtocolHelper_Trace.showProtocol_Trace(
                type_Trace: secondProtocol_Trace,
                content_Trace: secondContent_Trace,
                from: viewController_Trace
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Trace: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Trace: ProtocolHelper_Trace.ProtocolType_Trace
    private let content_Trace: String
    
    private var webView_Trace: WKWebView?
    private var scrollView_Trace: UIScrollView?
    private var activityIndicator_Trace: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Trace: Bool {
        return content_Trace.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Trace: Bool {
        return content_Trace.hasSuffix(".png") || 
               content_Trace.hasSuffix(".jpg") || 
               content_Trace.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Trace: ProtocolHelper_Trace.ProtocolType_Trace, content_Trace: String) {
        self.protocolType_Trace = type_Trace
        self.content_Trace = content_Trace
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        loadContent_Trace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Trace() {
        view.backgroundColor = .white
        title = protocolType_Trace.title_Trace
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Trace)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Trace {
            setupWebView_Trace()
            setupActivityIndicator_Trace()
        } else {
            setupScrollView_Trace()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Trace() {
        let webView_Trace = WKWebView()
        webView_Trace.navigationDelegate = self
        view.addSubview(webView_Trace)
        
        webView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Trace = webView_Trace
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Trace() {
        let scrollView_Trace = UIScrollView()
        scrollView_Trace.showsVerticalScrollIndicator = true
        scrollView_Trace.alwaysBounceVertical = true
        view.addSubview(scrollView_Trace)
        
        scrollView_Trace.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Trace = scrollView_Trace
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Trace() {
        let indicator_Trace = UIActivityIndicatorView(style: .large)
        indicator_Trace.color = .gray
        view.addSubview(indicator_Trace)
        
        indicator_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Trace = indicator_Trace
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Trace() {
        if isRemoteURL_Trace {
            loadWebContent_Trace()
        } else if isImage_Trace {
            loadImageContent_Trace()
        } else {
            loadTextContent_Trace()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Trace() {
        guard let url_Trace = URL(string: content_Trace) else { return }
        
        activityIndicator_Trace?.startAnimating()
        
        let request_Trace = URLRequest(url: url_Trace)
        webView_Trace?.load(request_Trace)
    }
    
    /// 加载图片内容
    private func loadImageContent_Trace() {
        guard let scrollView_Trace = scrollView_Trace,
              let image_Trace = UIImage(named: content_Trace) else { return }
        
        let imageView_Trace = UIImageView()
        imageView_Trace.contentMode = .scaleAspectFit
        imageView_Trace.image = image_Trace
        scrollView_Trace.addSubview(imageView_Trace)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Trace = view.bounds.width
        let imageRatio_Trace = image_Trace.size.height / image_Trace.size.width
        let displayHeight_Trace = screenWidth_Trace * imageRatio_Trace
        
        imageView_Trace.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Trace)
            make.height.equalTo(displayHeight_Trace)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Trace() {
        guard let scrollView_Trace = scrollView_Trace else { return }
        
        let textLabel_Trace = UILabel()
        textLabel_Trace.text = content_Trace
        textLabel_Trace.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Trace.textColor = .black
        textLabel_Trace.numberOfLines = 0
        scrollView_Trace.addSubview(textLabel_Trace)
        
        textLabel_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Trace() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Trace: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Trace?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Trace?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Trace?.stopAnimating()
        Utils_Trace.showError_Trace(message_Trace: "Failed to load content")
    }
}
