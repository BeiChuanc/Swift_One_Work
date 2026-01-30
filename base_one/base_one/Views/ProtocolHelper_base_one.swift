import Foundation
import UIKit
import WebKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Base_one {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Base_one {
        case terms_Base_one       // 服务条款
        case privacy_Base_one     // 隐私政策
        case eula_Base_one        // 最终用户许可协议
        case custom_Base_one(String) // 自定义协议
        
        /// 获取协议标题
        var title_Base_one: String {
            switch self {
            case .terms_Base_one:
                return "Terms of Service"
            case .privacy_Base_one:
                return "Privacy Policy"
            case .eula_Base_one:
                return "EULA"
            case .custom_Base_one(let title_Base_one):
                return title_Base_one
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Base_one {
        /// 普通文本颜色
        var textColor_Base_one: UIColor
        /// 链接文本颜色
        var linkColor_Base_one: UIColor
        /// 字体大小
        var fontSize_Base_one: CGFloat
        /// 字体粗细
        var fontWeight_Base_one: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Base_one: Bool
        /// 前缀文本
        var prefixText_Base_one: String
        /// 分隔符文本
        var separatorText_Base_one: String
        
        /// 默认初始化
        init(
            textColor_Base_one: UIColor = UIColor.gray,
            linkColor_Base_one: UIColor = UIColor.black,
            fontSize_Base_one: CGFloat = 12,
            fontWeight_Base_one: UIFont.Weight = .regular,
            hasUnderline_Base_one: Bool = true,
            prefixText_Base_one: String = "By continuing you agree with ",
            separatorText_Base_one: String = " & "
        ) {
            self.textColor_Base_one = textColor_Base_one
            self.linkColor_Base_one = linkColor_Base_one
            self.fontSize_Base_one = fontSize_Base_one
            self.fontWeight_Base_one = fontWeight_Base_one
            self.hasUnderline_Base_one = hasUnderline_Base_one
            self.prefixText_Base_one = prefixText_Base_one
            self.separatorText_Base_one = separatorText_Base_one
        }
        
        /// 浅色主题配置
        static func light_Base_one() -> ProtocolTextConfig_Base_one {
            return ProtocolTextConfig_Base_one(
                textColor_Base_one: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Base_one: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Base_one() -> ProtocolTextConfig_Base_one {
            return ProtocolTextConfig_Base_one(
                textColor_Base_one: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Base_one: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Base_one: 协议类型
    ///   - content_Base_one: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Base_one: 当前视图控制器
    static func showProtocol_Base_one(
        type_Base_one: ProtocolType_Base_one,
        content_Base_one: String,
        from viewController_Base_one: UIViewController
    ) {
        let protocolVC_Base_one = ProtocolViewController_Base_one(
            type_Base_one: type_Base_one,
            content_Base_one: content_Base_one
        )
        viewController_Base_one.navigationController?.pushViewController(
            protocolVC_Base_one,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Base_one: 第一个协议类型
    ///   - firstContent_Base_one: 第一个协议内容
    ///   - secondProtocol_Base_one: 第二个协议类型
    ///   - secondContent_Base_one: 第二个协议内容
    ///   - config_Base_one: 文本配置
    ///   - viewController_Base_one: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Base_one(
        firstProtocol_Base_one: ProtocolType_Base_one = .terms_Base_one,
        firstContent_Base_one: String,
        secondProtocol_Base_one: ProtocolType_Base_one = .privacy_Base_one,
        secondContent_Base_one: String,
        config_Base_one: ProtocolTextConfig_Base_one = .light_Base_one(),
        from viewController_Base_one: UIViewController
    ) -> UILabel {
        let label_Base_one = UILabel()
        label_Base_one.numberOfLines = 0
        label_Base_one.textAlignment = .center
        label_Base_one.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Base_one = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Base_one: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Base_one.fontSize_Base_one, weight: config_Base_one.fontWeight_Base_one),
            .foregroundColor: config_Base_one.textColor_Base_one
        ]
        attributedString_Base_one.append(NSAttributedString(
            string: config_Base_one.prefixText_Base_one,
            attributes: prefixAttributes_Base_one
        ))
        
        // 第一个协议链接
        var linkAttributes_Base_one: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Base_one.fontSize_Base_one, weight: config_Base_one.fontWeight_Base_one),
            .foregroundColor: config_Base_one.linkColor_Base_one
        ]
        if config_Base_one.hasUnderline_Base_one {
            linkAttributes_Base_one[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Base_one[.underlineColor] = config_Base_one.linkColor_Base_one
        }
        
        let firstProtocolString_Base_one = NSAttributedString(
            string: firstProtocol_Base_one.title_Base_one,
            attributes: linkAttributes_Base_one
        )
        attributedString_Base_one.append(firstProtocolString_Base_one)
        
        // 分隔符
        attributedString_Base_one.append(NSAttributedString(
            string: config_Base_one.separatorText_Base_one,
            attributes: prefixAttributes_Base_one
        ))
        
        // 第二个协议链接
        let secondProtocolString_Base_one = NSAttributedString(
            string: secondProtocol_Base_one.title_Base_one + ".",
            attributes: linkAttributes_Base_one
        )
        attributedString_Base_one.append(secondProtocolString_Base_one)
        
        label_Base_one.attributedText = attributedString_Base_one
        
        // 添加点击手势
        let tapGesture_Base_one = ProtocolTextTapGesture_Base_one(
            firstProtocol_Base_one: firstProtocol_Base_one,
            firstContent_Base_one: firstContent_Base_one,
            secondProtocol_Base_one: secondProtocol_Base_one,
            secondContent_Base_one: secondContent_Base_one,
            prefixLength_Base_one: config_Base_one.prefixText_Base_one.count,
            firstTitleLength_Base_one: firstProtocol_Base_one.title_Base_one.count,
            separatorLength_Base_one: config_Base_one.separatorText_Base_one.count,
            secondTitleLength_Base_one: secondProtocol_Base_one.title_Base_one.count + 1,
            viewController_Base_one: viewController_Base_one
        )
        label_Base_one.addGestureRecognizer(tapGesture_Base_one)
        
        return label_Base_one
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Base_one: UITapGestureRecognizer {
    
    private let firstProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one
    private let firstContent_Base_one: String
    private let secondProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one
    private let secondContent_Base_one: String
    private let prefixLength_Base_one: Int
    private let firstTitleLength_Base_one: Int
    private let separatorLength_Base_one: Int
    private let secondTitleLength_Base_one: Int
    private weak var viewController_Base_one: UIViewController?
    
    init(
        firstProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one,
        firstContent_Base_one: String,
        secondProtocol_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one,
        secondContent_Base_one: String,
        prefixLength_Base_one: Int,
        firstTitleLength_Base_one: Int,
        separatorLength_Base_one: Int,
        secondTitleLength_Base_one: Int,
        viewController_Base_one: UIViewController
    ) {
        self.firstProtocol_Base_one = firstProtocol_Base_one
        self.firstContent_Base_one = firstContent_Base_one
        self.secondProtocol_Base_one = secondProtocol_Base_one
        self.secondContent_Base_one = secondContent_Base_one
        self.prefixLength_Base_one = prefixLength_Base_one
        self.firstTitleLength_Base_one = firstTitleLength_Base_one
        self.separatorLength_Base_one = separatorLength_Base_one
        self.secondTitleLength_Base_one = secondTitleLength_Base_one
        self.viewController_Base_one = viewController_Base_one
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Base_one(_:)))
    }
    
    @objc private func handleTap_Base_one(_ gesture: UITapGestureRecognizer) {
        guard let label_Base_one = gesture.view as? UILabel,
              let attributedText_Base_one = label_Base_one.attributedText,
              let viewController_Base_one = viewController_Base_one else { return }
        
        // 计算点击位置
        let location_Base_one = gesture.location(in: label_Base_one)
        
        // 创建文本容器和布局管理器
        let textStorage_Base_one = NSTextStorage(attributedString: attributedText_Base_one)
        let layoutManager_Base_one = NSLayoutManager()
        let textContainer_Base_one = NSTextContainer(size: label_Base_one.bounds.size)
        
        layoutManager_Base_one.addTextContainer(textContainer_Base_one)
        textStorage_Base_one.addLayoutManager(layoutManager_Base_one)
        
        textContainer_Base_one.lineFragmentPadding = 0
        textContainer_Base_one.maximumNumberOfLines = label_Base_one.numberOfLines
        textContainer_Base_one.lineBreakMode = label_Base_one.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Base_one = layoutManager_Base_one.characterIndex(
            for: location_Base_one,
            in: textContainer_Base_one,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Base_one = prefixLength_Base_one
        let firstLinkEnd_Base_one = firstLinkStart_Base_one + firstTitleLength_Base_one
        
        let secondLinkStart_Base_one = firstLinkEnd_Base_one + separatorLength_Base_one
        let secondLinkEnd_Base_one = secondLinkStart_Base_one + secondTitleLength_Base_one
        
        if characterIndex_Base_one >= firstLinkStart_Base_one && characterIndex_Base_one < firstLinkEnd_Base_one {
            // 点击第一个协议
            ProtocolHelper_Base_one.showProtocol_Base_one(
                type_Base_one: firstProtocol_Base_one,
                content_Base_one: firstContent_Base_one,
                from: viewController_Base_one
            )
        } else if characterIndex_Base_one >= secondLinkStart_Base_one && characterIndex_Base_one < secondLinkEnd_Base_one {
            // 点击第二个协议
            ProtocolHelper_Base_one.showProtocol_Base_one(
                type_Base_one: secondProtocol_Base_one,
                content_Base_one: secondContent_Base_one,
                from: viewController_Base_one
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Base_one: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one
    private let content_Base_one: String
    
    private var webView_Base_one: WKWebView?
    private var scrollView_Base_one: UIScrollView?
    private var activityIndicator_Base_one: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Base_one: Bool {
        return content_Base_one.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Base_one: Bool {
        return content_Base_one.hasSuffix(".png") || 
               content_Base_one.hasSuffix(".jpg") || 
               content_Base_one.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Base_one: ProtocolHelper_Base_one.ProtocolType_Base_one, content_Base_one: String) {
        self.protocolType_Base_one = type_Base_one
        self.content_Base_one = content_Base_one
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Base_one()
        loadContent_Base_one()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Base_one() {
        view.backgroundColor = .white
        title = protocolType_Base_one.title_Base_one
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Base_one)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Base_one {
            setupWebView_Base_one()
            setupActivityIndicator_Base_one()
        } else {
            setupScrollView_Base_one()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Base_one() {
        let webView_Base_one = WKWebView()
        webView_Base_one.navigationDelegate = self
        view.addSubview(webView_Base_one)
        
        webView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Base_one = webView_Base_one
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Base_one() {
        let scrollView_Base_one = UIScrollView()
        scrollView_Base_one.showsVerticalScrollIndicator = true
        scrollView_Base_one.alwaysBounceVertical = true
        view.addSubview(scrollView_Base_one)
        
        scrollView_Base_one.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Base_one = scrollView_Base_one
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Base_one() {
        let indicator_Base_one = UIActivityIndicatorView(style: .large)
        indicator_Base_one.color = .gray
        view.addSubview(indicator_Base_one)
        
        indicator_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Base_one = indicator_Base_one
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Base_one() {
        if isRemoteURL_Base_one {
            loadWebContent_Base_one()
        } else if isImage_Base_one {
            loadImageContent_Base_one()
        } else {
            loadTextContent_Base_one()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Base_one() {
        guard let url_Base_one = URL(string: content_Base_one) else { return }
        
        activityIndicator_Base_one?.startAnimating()
        
        let request_Base_one = URLRequest(url: url_Base_one)
        webView_Base_one?.load(request_Base_one)
    }
    
    /// 加载图片内容
    private func loadImageContent_Base_one() {
        guard let scrollView_Base_one = scrollView_Base_one,
              let image_Base_one = UIImage(named: content_Base_one) else { return }
        
        let imageView_Base_one = UIImageView()
        imageView_Base_one.contentMode = .scaleAspectFit
        imageView_Base_one.image = image_Base_one
        scrollView_Base_one.addSubview(imageView_Base_one)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Base_one = view.bounds.width
        let imageRatio_Base_one = image_Base_one.size.height / image_Base_one.size.width
        let displayHeight_Base_one = screenWidth_Base_one * imageRatio_Base_one
        
        imageView_Base_one.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Base_one)
            make.height.equalTo(displayHeight_Base_one)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Base_one() {
        guard let scrollView_Base_one = scrollView_Base_one else { return }
        
        let textLabel_Base_one = UILabel()
        textLabel_Base_one.text = content_Base_one
        textLabel_Base_one.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Base_one.textColor = .black
        textLabel_Base_one.numberOfLines = 0
        scrollView_Base_one.addSubview(textLabel_Base_one)
        
        textLabel_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Base_one() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Base_one: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Base_one?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Base_one?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Base_one?.stopAnimating()
        Utils_Base_one.showError_Base_one(message_Base_one: "Failed to load content")
    }
}
