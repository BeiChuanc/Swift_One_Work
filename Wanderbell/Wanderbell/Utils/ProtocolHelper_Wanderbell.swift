import Foundation
import UIKit
import WebKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Wanderbell {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Wanderbell {
        case terms_Wanderbell       // 服务条款
        case privacy_Wanderbell     // 隐私政策
        case eula_Wanderbell        // 最终用户许可协议
        case custom_Wanderbell(String) // 自定义协议
        
        /// 获取协议标题
        var title_Wanderbell: String {
            switch self {
            case .terms_Wanderbell:
                return "Terms of Service"
            case .privacy_Wanderbell:
                return "Privacy Policy"
            case .eula_Wanderbell:
                return "EULA"
            case .custom_Wanderbell(let title_wanderbell):
                return title_wanderbell
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Wanderbell {
        /// 普通文本颜色
        var textColor_Wanderbell: UIColor
        /// 链接文本颜色
        var linkColor_Wanderbell: UIColor
        /// 字体大小
        var fontSize_Wanderbell: CGFloat
        /// 字体粗细
        var fontWeight_Wanderbell: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Wanderbell: Bool
        /// 前缀文本
        var prefixText_Wanderbell: String
        /// 分隔符文本
        var separatorText_Wanderbell: String
        
        /// 默认初始化
        init(
            textColor_Wanderbell: UIColor = UIColor.gray,
            linkColor_Wanderbell: UIColor = UIColor.black,
            fontSize_Wanderbell: CGFloat = 12,
            fontWeight_Wanderbell: UIFont.Weight = .regular,
            hasUnderline_Wanderbell: Bool = true,
            prefixText_Wanderbell: String = "By continuing you agree with ",
            separatorText_Wanderbell: String = " & "
        ) {
            self.textColor_Wanderbell = textColor_Wanderbell
            self.linkColor_Wanderbell = linkColor_Wanderbell
            self.fontSize_Wanderbell = fontSize_Wanderbell
            self.fontWeight_Wanderbell = fontWeight_Wanderbell
            self.hasUnderline_Wanderbell = hasUnderline_Wanderbell
            self.prefixText_Wanderbell = prefixText_Wanderbell
            self.separatorText_Wanderbell = separatorText_Wanderbell
        }
        
        /// 浅色主题配置
        static func light_Wanderbell() -> ProtocolTextConfig_Wanderbell {
            return ProtocolTextConfig_Wanderbell(
                textColor_Wanderbell: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Wanderbell: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Wanderbell() -> ProtocolTextConfig_Wanderbell {
            return ProtocolTextConfig_Wanderbell(
                textColor_Wanderbell: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Wanderbell: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_wanderbell: 协议类型
    ///   - content_wanderbell: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_wanderbell: 当前视图控制器
    static func showProtocol_Wanderbell(
        type_wanderbell: ProtocolType_Wanderbell,
        content_wanderbell: String,
        from viewController_wanderbell: UIViewController
    ) {
        let protocolVC_wanderbell = ProtocolViewController_Wanderbell(
            type_wanderbell: type_wanderbell,
            content_wanderbell: content_wanderbell
        )
        viewController_wanderbell.navigationController?.pushViewController(
            protocolVC_wanderbell,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_wanderbell: 第一个协议类型
    ///   - firstContent_wanderbell: 第一个协议内容
    ///   - secondProtocol_wanderbell: 第二个协议类型
    ///   - secondContent_wanderbell: 第二个协议内容
    ///   - config_wanderbell: 文本配置
    ///   - viewController_wanderbell: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Wanderbell(
        firstProtocol_wanderbell: ProtocolType_Wanderbell = .terms_Wanderbell,
        firstContent_wanderbell: String,
        secondProtocol_wanderbell: ProtocolType_Wanderbell = .privacy_Wanderbell,
        secondContent_wanderbell: String,
        config_wanderbell: ProtocolTextConfig_Wanderbell = .light_Wanderbell(),
        from viewController_wanderbell: UIViewController
    ) -> UILabel {
        let label_wanderbell = UILabel()
        label_wanderbell.numberOfLines = 0
        label_wanderbell.textAlignment = .center
        label_wanderbell.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_wanderbell = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_wanderbell: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_wanderbell.fontSize_Wanderbell, weight: config_wanderbell.fontWeight_Wanderbell),
            .foregroundColor: config_wanderbell.textColor_Wanderbell
        ]
        attributedString_wanderbell.append(NSAttributedString(
            string: config_wanderbell.prefixText_Wanderbell,
            attributes: prefixAttributes_wanderbell
        ))
        
        // 第一个协议链接
        var linkAttributes_wanderbell: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_wanderbell.fontSize_Wanderbell, weight: config_wanderbell.fontWeight_Wanderbell),
            .foregroundColor: config_wanderbell.linkColor_Wanderbell
        ]
        if config_wanderbell.hasUnderline_Wanderbell {
            linkAttributes_wanderbell[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_wanderbell[.underlineColor] = config_wanderbell.linkColor_Wanderbell
        }
        
        let firstProtocolString_wanderbell = NSAttributedString(
            string: firstProtocol_wanderbell.title_Wanderbell,
            attributes: linkAttributes_wanderbell
        )
        attributedString_wanderbell.append(firstProtocolString_wanderbell)
        
        // 分隔符
        attributedString_wanderbell.append(NSAttributedString(
            string: config_wanderbell.separatorText_Wanderbell,
            attributes: prefixAttributes_wanderbell
        ))
        
        // 第二个协议链接
        let secondProtocolString_wanderbell = NSAttributedString(
            string: secondProtocol_wanderbell.title_Wanderbell + ".",
            attributes: linkAttributes_wanderbell
        )
        attributedString_wanderbell.append(secondProtocolString_wanderbell)
        
        label_wanderbell.attributedText = attributedString_wanderbell
        
        // 添加点击手势
        let tapGesture_wanderbell = ProtocolTextTapGesture_Wanderbell(
            firstProtocol_wanderbell: firstProtocol_wanderbell,
            firstContent_wanderbell: firstContent_wanderbell,
            secondProtocol_wanderbell: secondProtocol_wanderbell,
            secondContent_wanderbell: secondContent_wanderbell,
            prefixLength_wanderbell: config_wanderbell.prefixText_Wanderbell.count,
            firstTitleLength_wanderbell: firstProtocol_wanderbell.title_Wanderbell.count,
            separatorLength_wanderbell: config_wanderbell.separatorText_Wanderbell.count,
            secondTitleLength_wanderbell: secondProtocol_wanderbell.title_Wanderbell.count + 1,
            viewController_wanderbell: viewController_wanderbell
        )
        label_wanderbell.addGestureRecognizer(tapGesture_wanderbell)
        
        return label_wanderbell
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Wanderbell: UITapGestureRecognizer {
    
    private let firstProtocol_Wanderbell: ProtocolHelper_Wanderbell.ProtocolType_Wanderbell
    private let firstContent_Wanderbell: String
    private let secondProtocol_Wanderbell: ProtocolHelper_Wanderbell.ProtocolType_Wanderbell
    private let secondContent_Wanderbell: String
    private let prefixLength_Wanderbell: Int
    private let firstTitleLength_Wanderbell: Int
    private let separatorLength_Wanderbell: Int
    private let secondTitleLength_Wanderbell: Int
    private weak var viewController_Wanderbell: UIViewController?
    
    init(
        firstProtocol_wanderbell: ProtocolHelper_Wanderbell.ProtocolType_Wanderbell,
        firstContent_wanderbell: String,
        secondProtocol_wanderbell: ProtocolHelper_Wanderbell.ProtocolType_Wanderbell,
        secondContent_wanderbell: String,
        prefixLength_wanderbell: Int,
        firstTitleLength_wanderbell: Int,
        separatorLength_wanderbell: Int,
        secondTitleLength_wanderbell: Int,
        viewController_wanderbell: UIViewController
    ) {
        self.firstProtocol_Wanderbell = firstProtocol_wanderbell
        self.firstContent_Wanderbell = firstContent_wanderbell
        self.secondProtocol_Wanderbell = secondProtocol_wanderbell
        self.secondContent_Wanderbell = secondContent_wanderbell
        self.prefixLength_Wanderbell = prefixLength_wanderbell
        self.firstTitleLength_Wanderbell = firstTitleLength_wanderbell
        self.separatorLength_Wanderbell = separatorLength_wanderbell
        self.secondTitleLength_Wanderbell = secondTitleLength_wanderbell
        self.viewController_Wanderbell = viewController_wanderbell
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Wanderbell(_:)))
    }
    
    @objc private func handleTap_Wanderbell(_ gesture: UITapGestureRecognizer) {
        guard let label_wanderbell = gesture.view as? UILabel,
              let attributedText_wanderbell = label_wanderbell.attributedText,
              let viewController_wanderbell = viewController_Wanderbell else { return }
        
        // 计算点击位置
        let location_wanderbell = gesture.location(in: label_wanderbell)
        
        // 创建文本容器和布局管理器
        let textStorage_wanderbell = NSTextStorage(attributedString: attributedText_wanderbell)
        let layoutManager_wanderbell = NSLayoutManager()
        let textContainer_wanderbell = NSTextContainer(size: label_wanderbell.bounds.size)
        
        layoutManager_wanderbell.addTextContainer(textContainer_wanderbell)
        textStorage_wanderbell.addLayoutManager(layoutManager_wanderbell)
        
        textContainer_wanderbell.lineFragmentPadding = 0
        textContainer_wanderbell.maximumNumberOfLines = label_wanderbell.numberOfLines
        textContainer_wanderbell.lineBreakMode = label_wanderbell.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_wanderbell = layoutManager_wanderbell.characterIndex(
            for: location_wanderbell,
            in: textContainer_wanderbell,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_wanderbell = prefixLength_Wanderbell
        let firstLinkEnd_wanderbell = firstLinkStart_wanderbell + firstTitleLength_Wanderbell
        
        let secondLinkStart_wanderbell = firstLinkEnd_wanderbell + separatorLength_Wanderbell
        let secondLinkEnd_wanderbell = secondLinkStart_wanderbell + secondTitleLength_Wanderbell
        
        if characterIndex_wanderbell >= firstLinkStart_wanderbell && characterIndex_wanderbell < firstLinkEnd_wanderbell {
            // 点击第一个协议
            ProtocolHelper_Wanderbell.showProtocol_Wanderbell(
                type_wanderbell: firstProtocol_Wanderbell,
                content_wanderbell: firstContent_Wanderbell,
                from: viewController_wanderbell
            )
        } else if characterIndex_wanderbell >= secondLinkStart_wanderbell && characterIndex_wanderbell < secondLinkEnd_wanderbell {
            // 点击第二个协议
            ProtocolHelper_Wanderbell.showProtocol_Wanderbell(
                type_wanderbell: secondProtocol_Wanderbell,
                content_wanderbell: secondContent_Wanderbell,
                from: viewController_wanderbell
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Wanderbell: ProtocolHelper_Wanderbell.ProtocolType_Wanderbell
    private let content_Wanderbell: String
    
    private var webView_Wanderbell: WKWebView?
    private var scrollView_Wanderbell: UIScrollView?
    private var activityIndicator_Wanderbell: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Wanderbell: Bool {
        return content_Wanderbell.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Wanderbell: Bool {
        return content_Wanderbell.hasSuffix(".png") || 
               content_Wanderbell.hasSuffix(".jpg") || 
               content_Wanderbell.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_wanderbell: ProtocolHelper_Wanderbell.ProtocolType_Wanderbell, content_wanderbell: String) {
        self.protocolType_Wanderbell = type_wanderbell
        self.content_Wanderbell = content_wanderbell
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        loadContent_Wanderbell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        view.backgroundColor = .white
        title = protocolType_Wanderbell.title_Wanderbell
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Wanderbell)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Wanderbell {
            setupWebView_Wanderbell()
            setupActivityIndicator_Wanderbell()
        } else {
            setupScrollView_Wanderbell()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Wanderbell() {
        let webView_wanderbell = WKWebView()
        webView_wanderbell.navigationDelegate = self
        view.addSubview(webView_wanderbell)
        
        webView_wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Wanderbell = webView_wanderbell
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Wanderbell() {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = true
        scrollView_wanderbell.alwaysBounceVertical = true
        view.addSubview(scrollView_wanderbell)
        
        scrollView_wanderbell.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Wanderbell = scrollView_wanderbell
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Wanderbell() {
        let indicator_wanderbell = UIActivityIndicatorView(style: .large)
        indicator_wanderbell.color = .gray
        view.addSubview(indicator_wanderbell)
        
        indicator_wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Wanderbell = indicator_wanderbell
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Wanderbell() {
        if isRemoteURL_Wanderbell {
            loadWebContent_Wanderbell()
        } else if isImage_Wanderbell {
            loadImageContent_Wanderbell()
        } else {
            loadTextContent_Wanderbell()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Wanderbell() {
        guard let url_wanderbell = URL(string: content_Wanderbell) else { return }
        
        activityIndicator_Wanderbell?.startAnimating()
        
        let request_wanderbell = URLRequest(url: url_wanderbell)
        webView_Wanderbell?.load(request_wanderbell)
    }
    
    /// 加载图片内容
    private func loadImageContent_Wanderbell() {
        guard let scrollView_wanderbell = scrollView_Wanderbell,
              let image_wanderbell = UIImage(named: content_Wanderbell) else { return }
        
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        imageView_wanderbell.image = image_wanderbell
        scrollView_wanderbell.addSubview(imageView_wanderbell)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_wanderbell = view.bounds.width
        let imageRatio_wanderbell = image_wanderbell.size.height / image_wanderbell.size.width
        let displayHeight_wanderbell = screenWidth_wanderbell * imageRatio_wanderbell
        
        imageView_wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_wanderbell)
            make.height.equalTo(displayHeight_wanderbell)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Wanderbell() {
        guard let scrollView_wanderbell = scrollView_Wanderbell else { return }
        
        let textLabel_wanderbell = UILabel()
        textLabel_wanderbell.text = content_Wanderbell
        textLabel_wanderbell.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_wanderbell.textColor = .black
        textLabel_wanderbell.numberOfLines = 0
        scrollView_wanderbell.addSubview(textLabel_wanderbell)
        
        textLabel_wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Wanderbell() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Wanderbell: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Wanderbell?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Wanderbell?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Wanderbell?.stopAnimating()
        Utils_Wanderbell.showError_Wanderbell(message_wanderbell: "Failed to load content")
    }
}
