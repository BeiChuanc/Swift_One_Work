import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Clara {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Clara {
        case terms_Clara       // 服务条款
        case privacy_Clara     // 隐私政策
        case eula_Clara        // 最终用户许可协议
        case custom_Clara(String) // 自定义协议
        
        /// 获取协议标题
        var title_Clara: String {
            switch self {
            case .terms_Clara:
                return "Terms of Service"
            case .privacy_Clara:
                return "Privacy Policy"
            case .eula_Clara:
                return "EULA"
            case .custom_Clara(let title_Clara):
                return title_Clara
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Clara {
        /// 普通文本颜色
        var textColor_Clara: UIColor
        /// 链接文本颜色
        var linkColor_Clara: UIColor
        /// 字体大小
        var fontSize_Clara: CGFloat
        /// 字体粗细
        var fontWeight_Clara: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Clara: Bool
        /// 前缀文本
        var prefixText_Clara: String
        /// 分隔符文本
        var separatorText_Clara: String
        
        /// 默认初始化
        init(
            textColor_Clara: UIColor = UIColor.gray,
            linkColor_Clara: UIColor = UIColor.black,
            fontSize_Clara: CGFloat = 12,
            fontWeight_Clara: UIFont.Weight = .regular,
            hasUnderline_Clara: Bool = true,
            prefixText_Clara: String = "By continuing you agree with ",
            separatorText_Clara: String = " & "
        ) {
            self.textColor_Clara = textColor_Clara
            self.linkColor_Clara = linkColor_Clara
            self.fontSize_Clara = fontSize_Clara
            self.fontWeight_Clara = fontWeight_Clara
            self.hasUnderline_Clara = hasUnderline_Clara
            self.prefixText_Clara = prefixText_Clara
            self.separatorText_Clara = separatorText_Clara
        }
        
        /// 浅色主题配置
        static func light_Clara() -> ProtocolTextConfig_Clara {
            return ProtocolTextConfig_Clara(
                textColor_Clara: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Clara: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Clara() -> ProtocolTextConfig_Clara {
            return ProtocolTextConfig_Clara(
                textColor_Clara: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Clara: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Clara: 协议类型
    ///   - content_Clara: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Clara: 当前视图控制器
    static func showProtocol_Clara(
        type_Clara: ProtocolType_Clara,
        content_Clara: String,
        from viewController_Clara: UIViewController
    ) {
        let protocolVC_Clara = ProtocolViewController_Clara(
            type_Clara: type_Clara,
            content_Clara: content_Clara
        )
        viewController_Clara.navigationController?.pushViewController(
            protocolVC_Clara,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Clara: 第一个协议类型
    ///   - firstContent_Clara: 第一个协议内容
    ///   - secondProtocol_Clara: 第二个协议类型
    ///   - secondContent_Clara: 第二个协议内容
    ///   - config_Clara: 文本配置
    ///   - viewController_Clara: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Clara(
        firstProtocol_Clara: ProtocolType_Clara = .terms_Clara,
        firstContent_Clara: String,
        secondProtocol_Clara: ProtocolType_Clara = .privacy_Clara,
        secondContent_Clara: String,
        config_Clara: ProtocolTextConfig_Clara = .light_Clara(),
        from viewController_Clara: UIViewController
    ) -> UILabel {
        let label_Clara = UILabel()
        label_Clara.numberOfLines = 0
        label_Clara.textAlignment = .center
        label_Clara.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Clara = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Clara: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Clara.fontSize_Clara, weight: config_Clara.fontWeight_Clara),
            .foregroundColor: config_Clara.textColor_Clara
        ]
        attributedString_Clara.append(NSAttributedString(
            string: config_Clara.prefixText_Clara,
            attributes: prefixAttributes_Clara
        ))
        
        // 第一个协议链接
        var linkAttributes_Clara: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Clara.fontSize_Clara, weight: config_Clara.fontWeight_Clara),
            .foregroundColor: config_Clara.linkColor_Clara
        ]
        if config_Clara.hasUnderline_Clara {
            linkAttributes_Clara[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Clara[.underlineColor] = config_Clara.linkColor_Clara
        }
        
        let firstProtocolString_Clara = NSAttributedString(
            string: firstProtocol_Clara.title_Clara,
            attributes: linkAttributes_Clara
        )
        attributedString_Clara.append(firstProtocolString_Clara)
        
        // 分隔符
        attributedString_Clara.append(NSAttributedString(
            string: config_Clara.separatorText_Clara,
            attributes: prefixAttributes_Clara
        ))
        
        // 第二个协议链接
        let secondProtocolString_Clara = NSAttributedString(
            string: secondProtocol_Clara.title_Clara + ".",
            attributes: linkAttributes_Clara
        )
        attributedString_Clara.append(secondProtocolString_Clara)
        
        label_Clara.attributedText = attributedString_Clara
        
        // 添加点击手势
        let tapGesture_Clara = ProtocolTextTapGesture_Clara(
            firstProtocol_Clara: firstProtocol_Clara,
            firstContent_Clara: firstContent_Clara,
            secondProtocol_Clara: secondProtocol_Clara,
            secondContent_Clara: secondContent_Clara,
            prefixLength_Clara: config_Clara.prefixText_Clara.count,
            firstTitleLength_Clara: firstProtocol_Clara.title_Clara.count,
            separatorLength_Clara: config_Clara.separatorText_Clara.count,
            secondTitleLength_Clara: secondProtocol_Clara.title_Clara.count + 1,
            viewController_Clara: viewController_Clara
        )
        label_Clara.addGestureRecognizer(tapGesture_Clara)
        
        return label_Clara
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Clara: UITapGestureRecognizer {
    
    private let firstProtocol_Clara: ProtocolHelper_Clara.ProtocolType_Clara
    private let firstContent_Clara: String
    private let secondProtocol_Clara: ProtocolHelper_Clara.ProtocolType_Clara
    private let secondContent_Clara: String
    private let prefixLength_Clara: Int
    private let firstTitleLength_Clara: Int
    private let separatorLength_Clara: Int
    private let secondTitleLength_Clara: Int
    private weak var viewController_Clara: UIViewController?
    
    init(
        firstProtocol_Clara: ProtocolHelper_Clara.ProtocolType_Clara,
        firstContent_Clara: String,
        secondProtocol_Clara: ProtocolHelper_Clara.ProtocolType_Clara,
        secondContent_Clara: String,
        prefixLength_Clara: Int,
        firstTitleLength_Clara: Int,
        separatorLength_Clara: Int,
        secondTitleLength_Clara: Int,
        viewController_Clara: UIViewController
    ) {
        self.firstProtocol_Clara = firstProtocol_Clara
        self.firstContent_Clara = firstContent_Clara
        self.secondProtocol_Clara = secondProtocol_Clara
        self.secondContent_Clara = secondContent_Clara
        self.prefixLength_Clara = prefixLength_Clara
        self.firstTitleLength_Clara = firstTitleLength_Clara
        self.separatorLength_Clara = separatorLength_Clara
        self.secondTitleLength_Clara = secondTitleLength_Clara
        self.viewController_Clara = viewController_Clara
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Clara(_:)))
    }
    
    @objc private func handleTap_Clara(_ gesture: UITapGestureRecognizer) {
        guard let label_Clara = gesture.view as? UILabel,
              let attributedText_Clara = label_Clara.attributedText,
              let viewController_Clara = viewController_Clara else { return }
        
        // 计算点击位置
        let location_Clara = gesture.location(in: label_Clara)
        
        // 创建文本容器和布局管理器
        let textStorage_Clara = NSTextStorage(attributedString: attributedText_Clara)
        let layoutManager_Clara = NSLayoutManager()
        let textContainer_Clara = NSTextContainer(size: label_Clara.bounds.size)
        
        layoutManager_Clara.addTextContainer(textContainer_Clara)
        textStorage_Clara.addLayoutManager(layoutManager_Clara)
        
        textContainer_Clara.lineFragmentPadding = 0
        textContainer_Clara.maximumNumberOfLines = label_Clara.numberOfLines
        textContainer_Clara.lineBreakMode = label_Clara.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Clara = layoutManager_Clara.characterIndex(
            for: location_Clara,
            in: textContainer_Clara,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Clara = prefixLength_Clara
        let firstLinkEnd_Clara = firstLinkStart_Clara + firstTitleLength_Clara
        
        let secondLinkStart_Clara = firstLinkEnd_Clara + separatorLength_Clara
        let secondLinkEnd_Clara = secondLinkStart_Clara + secondTitleLength_Clara
        
        if characterIndex_Clara >= firstLinkStart_Clara && characterIndex_Clara < firstLinkEnd_Clara {
            // 点击第一个协议
            ProtocolHelper_Clara.showProtocol_Clara(
                type_Clara: firstProtocol_Clara,
                content_Clara: firstContent_Clara,
                from: viewController_Clara
            )
        } else if characterIndex_Clara >= secondLinkStart_Clara && characterIndex_Clara < secondLinkEnd_Clara {
            // 点击第二个协议
            ProtocolHelper_Clara.showProtocol_Clara(
                type_Clara: secondProtocol_Clara,
                content_Clara: secondContent_Clara,
                from: viewController_Clara
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Clara: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Clara: ProtocolHelper_Clara.ProtocolType_Clara
    private let content_Clara: String
    
    private var webView_Clara: WKWebView?
    private var scrollView_Clara: UIScrollView?
    private var activityIndicator_Clara: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Clara: Bool {
        return content_Clara.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Clara: Bool {
        return content_Clara.hasSuffix(".png") || 
               content_Clara.hasSuffix(".jpg") || 
               content_Clara.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Clara: ProtocolHelper_Clara.ProtocolType_Clara, content_Clara: String) {
        self.protocolType_Clara = type_Clara
        self.content_Clara = content_Clara
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Clara()
        loadContent_Clara()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Clara() {
        view.backgroundColor = .white
        title = protocolType_Clara.title_Clara
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Clara)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Clara {
            setupWebView_Clara()
            setupActivityIndicator_Clara()
        } else {
            setupScrollView_Clara()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Clara() {
        let webView_Clara = WKWebView()
        webView_Clara.navigationDelegate = self
        view.addSubview(webView_Clara)
        
        webView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Clara = webView_Clara
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Clara() {
        let scrollView_Clara = UIScrollView()
        scrollView_Clara.showsVerticalScrollIndicator = true
        scrollView_Clara.alwaysBounceVertical = true
        view.addSubview(scrollView_Clara)
        
        scrollView_Clara.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Clara = scrollView_Clara
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Clara() {
        let indicator_Clara = UIActivityIndicatorView(style: .large)
        indicator_Clara.color = .gray
        view.addSubview(indicator_Clara)
        
        indicator_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Clara = indicator_Clara
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Clara() {
        if isRemoteURL_Clara {
            loadWebContent_Clara()
        } else if isImage_Clara {
            loadImageContent_Clara()
        } else {
            loadTextContent_Clara()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Clara() {
        guard let url_Clara = URL(string: content_Clara) else { return }
        
        activityIndicator_Clara?.startAnimating()
        
        let request_Clara = URLRequest(url: url_Clara)
        webView_Clara?.load(request_Clara)
    }
    
    /// 加载图片内容
    private func loadImageContent_Clara() {
        guard let scrollView_Clara = scrollView_Clara,
              let image_Clara = UIImage(named: content_Clara) else { return }
        
        let imageView_Clara = UIImageView()
        imageView_Clara.contentMode = .scaleAspectFit
        imageView_Clara.image = image_Clara
        scrollView_Clara.addSubview(imageView_Clara)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Clara = view.bounds.width
        let imageRatio_Clara = image_Clara.size.height / image_Clara.size.width
        let displayHeight_Clara = screenWidth_Clara * imageRatio_Clara
        
        imageView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Clara)
            make.height.equalTo(displayHeight_Clara)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Clara() {
        guard let scrollView_Clara = scrollView_Clara else { return }
        
        let textLabel_Clara = UILabel()
        textLabel_Clara.text = content_Clara
        textLabel_Clara.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Clara.textColor = .black
        textLabel_Clara.numberOfLines = 0
        scrollView_Clara.addSubview(textLabel_Clara)
        
        textLabel_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Clara: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Clara?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Clara?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Clara?.stopAnimating()
        Utils_Clara.showError_Clara(message_Clara: "Failed to load content")
    }
}
