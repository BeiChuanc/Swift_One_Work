import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Hush {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Hush {
        case terms_Hush       // 服务条款
        case privacy_Hush     // 隐私政策
        case eula_Hush        // 最终用户许可协议
        case custom_Hush(String) // 自定义协议
        
        /// 获取协议标题
        var title_Hush: String {
            switch self {
            case .terms_Hush:
                return "Terms of Service"
            case .privacy_Hush:
                return "Privacy Policy"
            case .eula_Hush:
                return "EULA"
            case .custom_Hush(let title_Hush):
                return title_Hush
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Hush {
        /// 普通文本颜色
        var textColor_Hush: UIColor
        /// 链接文本颜色
        var linkColor_Hush: UIColor
        /// 字体大小
        var fontSize_Hush: CGFloat
        /// 字体粗细
        var fontWeight_Hush: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Hush: Bool
        /// 前缀文本
        var prefixText_Hush: String
        /// 分隔符文本
        var separatorText_Hush: String
        
        /// 默认初始化
        init(
            textColor_Hush: UIColor = UIColor.gray,
            linkColor_Hush: UIColor = UIColor.black,
            fontSize_Hush: CGFloat = 12,
            fontWeight_Hush: UIFont.Weight = .regular,
            hasUnderline_Hush: Bool = true,
            prefixText_Hush: String = "By continuing you agree with ",
            separatorText_Hush: String = " & "
        ) {
            self.textColor_Hush = textColor_Hush
            self.linkColor_Hush = linkColor_Hush
            self.fontSize_Hush = fontSize_Hush
            self.fontWeight_Hush = fontWeight_Hush
            self.hasUnderline_Hush = hasUnderline_Hush
            self.prefixText_Hush = prefixText_Hush
            self.separatorText_Hush = separatorText_Hush
        }
        
        /// 浅色主题配置
        static func light_Hush() -> ProtocolTextConfig_Hush {
            return ProtocolTextConfig_Hush(
                textColor_Hush: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Hush: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Hush() -> ProtocolTextConfig_Hush {
            return ProtocolTextConfig_Hush(
                textColor_Hush: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Hush: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Hush: 协议类型
    ///   - content_Hush: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Hush: 当前视图控制器
    static func showProtocol_Hush(
        type_Hush: ProtocolType_Hush,
        content_Hush: String,
        from viewController_Hush: UIViewController
    ) {
        let protocolVC_Hush = ProtocolViewController_Hush(
            type_Hush: type_Hush,
            content_Hush: content_Hush
        )
        viewController_Hush.navigationController?.pushViewController(
            protocolVC_Hush,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Hush: 第一个协议类型
    ///   - firstContent_Hush: 第一个协议内容
    ///   - secondProtocol_Hush: 第二个协议类型
    ///   - secondContent_Hush: 第二个协议内容
    ///   - config_Hush: 文本配置
    ///   - viewController_Hush: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Hush(
        firstProtocol_Hush: ProtocolType_Hush = .terms_Hush,
        firstContent_Hush: String,
        secondProtocol_Hush: ProtocolType_Hush = .privacy_Hush,
        secondContent_Hush: String,
        config_Hush: ProtocolTextConfig_Hush = .light_Hush(),
        from viewController_Hush: UIViewController
    ) -> UILabel {
        let label_Hush = UILabel()
        label_Hush.numberOfLines = 0
        label_Hush.textAlignment = .center
        label_Hush.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Hush = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Hush: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Hush.fontSize_Hush, weight: config_Hush.fontWeight_Hush),
            .foregroundColor: config_Hush.textColor_Hush
        ]
        attributedString_Hush.append(NSAttributedString(
            string: config_Hush.prefixText_Hush,
            attributes: prefixAttributes_Hush
        ))
        
        // 第一个协议链接
        var linkAttributes_Hush: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Hush.fontSize_Hush, weight: config_Hush.fontWeight_Hush),
            .foregroundColor: config_Hush.linkColor_Hush
        ]
        if config_Hush.hasUnderline_Hush {
            linkAttributes_Hush[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Hush[.underlineColor] = config_Hush.linkColor_Hush
        }
        
        let firstProtocolString_Hush = NSAttributedString(
            string: firstProtocol_Hush.title_Hush,
            attributes: linkAttributes_Hush
        )
        attributedString_Hush.append(firstProtocolString_Hush)
        
        // 分隔符
        attributedString_Hush.append(NSAttributedString(
            string: config_Hush.separatorText_Hush,
            attributes: prefixAttributes_Hush
        ))
        
        // 第二个协议链接
        let secondProtocolString_Hush = NSAttributedString(
            string: secondProtocol_Hush.title_Hush + ".",
            attributes: linkAttributes_Hush
        )
        attributedString_Hush.append(secondProtocolString_Hush)
        
        label_Hush.attributedText = attributedString_Hush
        
        // 添加点击手势
        let tapGesture_Hush = ProtocolTextTapGesture_Hush(
            firstProtocol_Hush: firstProtocol_Hush,
            firstContent_Hush: firstContent_Hush,
            secondProtocol_Hush: secondProtocol_Hush,
            secondContent_Hush: secondContent_Hush,
            prefixLength_Hush: config_Hush.prefixText_Hush.count,
            firstTitleLength_Hush: firstProtocol_Hush.title_Hush.count,
            separatorLength_Hush: config_Hush.separatorText_Hush.count,
            secondTitleLength_Hush: secondProtocol_Hush.title_Hush.count + 1,
            viewController_Hush: viewController_Hush
        )
        label_Hush.addGestureRecognizer(tapGesture_Hush)
        
        return label_Hush
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Hush: UITapGestureRecognizer {
    
    private let firstProtocol_Hush: ProtocolHelper_Hush.ProtocolType_Hush
    private let firstContent_Hush: String
    private let secondProtocol_Hush: ProtocolHelper_Hush.ProtocolType_Hush
    private let secondContent_Hush: String
    private let prefixLength_Hush: Int
    private let firstTitleLength_Hush: Int
    private let separatorLength_Hush: Int
    private let secondTitleLength_Hush: Int
    private weak var viewController_Hush: UIViewController?
    
    init(
        firstProtocol_Hush: ProtocolHelper_Hush.ProtocolType_Hush,
        firstContent_Hush: String,
        secondProtocol_Hush: ProtocolHelper_Hush.ProtocolType_Hush,
        secondContent_Hush: String,
        prefixLength_Hush: Int,
        firstTitleLength_Hush: Int,
        separatorLength_Hush: Int,
        secondTitleLength_Hush: Int,
        viewController_Hush: UIViewController
    ) {
        self.firstProtocol_Hush = firstProtocol_Hush
        self.firstContent_Hush = firstContent_Hush
        self.secondProtocol_Hush = secondProtocol_Hush
        self.secondContent_Hush = secondContent_Hush
        self.prefixLength_Hush = prefixLength_Hush
        self.firstTitleLength_Hush = firstTitleLength_Hush
        self.separatorLength_Hush = separatorLength_Hush
        self.secondTitleLength_Hush = secondTitleLength_Hush
        self.viewController_Hush = viewController_Hush
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Hush(_:)))
    }
    
    @objc private func handleTap_Hush(_ gesture: UITapGestureRecognizer) {
        guard let label_Hush = gesture.view as? UILabel,
              let attributedText_Hush = label_Hush.attributedText,
              let viewController_Hush = viewController_Hush else { return }
        
        // 计算点击位置
        let location_Hush = gesture.location(in: label_Hush)
        
        // 创建文本容器和布局管理器
        let textStorage_Hush = NSTextStorage(attributedString: attributedText_Hush)
        let layoutManager_Hush = NSLayoutManager()
        let textContainer_Hush = NSTextContainer(size: label_Hush.bounds.size)
        
        layoutManager_Hush.addTextContainer(textContainer_Hush)
        textStorage_Hush.addLayoutManager(layoutManager_Hush)
        
        textContainer_Hush.lineFragmentPadding = 0
        textContainer_Hush.maximumNumberOfLines = label_Hush.numberOfLines
        textContainer_Hush.lineBreakMode = label_Hush.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Hush = layoutManager_Hush.characterIndex(
            for: location_Hush,
            in: textContainer_Hush,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Hush = prefixLength_Hush
        let firstLinkEnd_Hush = firstLinkStart_Hush + firstTitleLength_Hush
        
        let secondLinkStart_Hush = firstLinkEnd_Hush + separatorLength_Hush
        let secondLinkEnd_Hush = secondLinkStart_Hush + secondTitleLength_Hush
        
        if characterIndex_Hush >= firstLinkStart_Hush && characterIndex_Hush < firstLinkEnd_Hush {
            // 点击第一个协议
            ProtocolHelper_Hush.showProtocol_Hush(
                type_Hush: firstProtocol_Hush,
                content_Hush: firstContent_Hush,
                from: viewController_Hush
            )
        } else if characterIndex_Hush >= secondLinkStart_Hush && characterIndex_Hush < secondLinkEnd_Hush {
            // 点击第二个协议
            ProtocolHelper_Hush.showProtocol_Hush(
                type_Hush: secondProtocol_Hush,
                content_Hush: secondContent_Hush,
                from: viewController_Hush
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Hush: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Hush: ProtocolHelper_Hush.ProtocolType_Hush
    private let content_Hush: String
    
    private var webView_Hush: WKWebView?
    private var scrollView_Hush: UIScrollView?
    private var activityIndicator_Hush: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Hush: Bool {
        return content_Hush.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Hush: Bool {
        return content_Hush.hasSuffix(".png") || 
               content_Hush.hasSuffix(".jpg") || 
               content_Hush.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Hush: ProtocolHelper_Hush.ProtocolType_Hush, content_Hush: String) {
        self.protocolType_Hush = type_Hush
        self.content_Hush = content_Hush
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Hush()
        loadContent_Hush()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Hush() {
        view.backgroundColor = .white
        title = protocolType_Hush.title_Hush
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Hush)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Hush {
            setupWebView_Hush()
            setupActivityIndicator_Hush()
        } else {
            setupScrollView_Hush()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Hush() {
        let webView_Hush = WKWebView()
        webView_Hush.navigationDelegate = self
        view.addSubview(webView_Hush)
        
        webView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Hush = webView_Hush
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Hush() {
        let scrollView_Hush = UIScrollView()
        scrollView_Hush.showsVerticalScrollIndicator = true
        scrollView_Hush.alwaysBounceVertical = true
        view.addSubview(scrollView_Hush)
        
        scrollView_Hush.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Hush = scrollView_Hush
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Hush() {
        let indicator_Hush = UIActivityIndicatorView(style: .large)
        indicator_Hush.color = .gray
        view.addSubview(indicator_Hush)
        
        indicator_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Hush = indicator_Hush
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Hush() {
        if isRemoteURL_Hush {
            loadWebContent_Hush()
        } else if isImage_Hush {
            loadImageContent_Hush()
        } else {
            loadTextContent_Hush()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Hush() {
        guard let url_Hush = URL(string: content_Hush) else { return }
        
        activityIndicator_Hush?.startAnimating()
        
        let request_Hush = URLRequest(url: url_Hush)
        webView_Hush?.load(request_Hush)
    }
    
    /// 加载图片内容
    private func loadImageContent_Hush() {
        guard let scrollView_Hush = scrollView_Hush,
              let image_Hush = UIImage(named: content_Hush) else { return }
        
        let imageView_Hush = UIImageView()
        imageView_Hush.contentMode = .scaleAspectFit
        imageView_Hush.image = image_Hush
        scrollView_Hush.addSubview(imageView_Hush)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Hush = view.bounds.width
        let imageRatio_Hush = image_Hush.size.height / image_Hush.size.width
        let displayHeight_Hush = screenWidth_Hush * imageRatio_Hush
        
        imageView_Hush.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Hush)
            make.height.equalTo(displayHeight_Hush)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Hush() {
        guard let scrollView_Hush = scrollView_Hush else { return }
        
        let textLabel_Hush = UILabel()
        textLabel_Hush.text = content_Hush
        textLabel_Hush.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Hush.textColor = .black
        textLabel_Hush.numberOfLines = 0
        scrollView_Hush.addSubview(textLabel_Hush)
        
        textLabel_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Hush() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Hush: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Hush?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Hush?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Hush?.stopAnimating()
        Utils_Hush.showError_Hush(message_Hush: "Failed to load content")
    }
}
