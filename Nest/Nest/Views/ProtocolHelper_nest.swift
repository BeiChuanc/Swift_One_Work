import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Nest {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Nest {
        case terms_Nest       // 服务条款
        case privacy_Nest     // 隐私政策
        case eula_Nest        // 最终用户许可协议
        case custom_Nest(String) // 自定义协议
        
        /// 获取协议标题
        var title_Nest: String {
            switch self {
            case .terms_Nest:
                return "Terms of Service"
            case .privacy_Nest:
                return "Privacy Policy"
            case .eula_Nest:
                return "EULA"
            case .custom_Nest(let title_Nest):
                return title_Nest
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Nest {
        /// 普通文本颜色
        var textColor_Nest: UIColor
        /// 链接文本颜色
        var linkColor_Nest: UIColor
        /// 字体大小
        var fontSize_Nest: CGFloat
        /// 字体粗细
        var fontWeight_Nest: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Nest: Bool
        /// 前缀文本
        var prefixText_Nest: String
        /// 分隔符文本
        var separatorText_Nest: String
        
        /// 默认初始化
        init(
            textColor_Nest: UIColor = UIColor.gray,
            linkColor_Nest: UIColor = UIColor.black,
            fontSize_Nest: CGFloat = 12,
            fontWeight_Nest: UIFont.Weight = .regular,
            hasUnderline_Nest: Bool = true,
            prefixText_Nest: String = "By continuing you agree with ",
            separatorText_Nest: String = " & "
        ) {
            self.textColor_Nest = textColor_Nest
            self.linkColor_Nest = linkColor_Nest
            self.fontSize_Nest = fontSize_Nest
            self.fontWeight_Nest = fontWeight_Nest
            self.hasUnderline_Nest = hasUnderline_Nest
            self.prefixText_Nest = prefixText_Nest
            self.separatorText_Nest = separatorText_Nest
        }
        
        /// 浅色主题配置
        static func light_Nest() -> ProtocolTextConfig_Nest {
            return ProtocolTextConfig_Nest(
                textColor_Nest: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Nest: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Nest() -> ProtocolTextConfig_Nest {
            return ProtocolTextConfig_Nest(
                textColor_Nest: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Nest: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Nest: 协议类型
    ///   - content_Nest: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Nest: 当前视图控制器
    static func showProtocol_Nest(
        type_Nest: ProtocolType_Nest,
        content_Nest: String,
        from viewController_Nest: UIViewController
    ) {
        let protocolVC_Nest = ProtocolViewController_Nest(
            type_Nest: type_Nest,
            content_Nest: content_Nest
        )
        viewController_Nest.navigationController?.pushViewController(
            protocolVC_Nest,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Nest: 第一个协议类型
    ///   - firstContent_Nest: 第一个协议内容
    ///   - secondProtocol_Nest: 第二个协议类型
    ///   - secondContent_Nest: 第二个协议内容
    ///   - config_Nest: 文本配置
    ///   - viewController_Nest: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Nest(
        firstProtocol_Nest: ProtocolType_Nest = .terms_Nest,
        firstContent_Nest: String,
        secondProtocol_Nest: ProtocolType_Nest = .privacy_Nest,
        secondContent_Nest: String,
        config_Nest: ProtocolTextConfig_Nest = .light_Nest(),
        from viewController_Nest: UIViewController
    ) -> UILabel {
        let label_Nest = UILabel()
        label_Nest.numberOfLines = 0
        label_Nest.textAlignment = .center
        label_Nest.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Nest = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Nest: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Nest.fontSize_Nest, weight: config_Nest.fontWeight_Nest),
            .foregroundColor: config_Nest.textColor_Nest
        ]
        attributedString_Nest.append(NSAttributedString(
            string: config_Nest.prefixText_Nest,
            attributes: prefixAttributes_Nest
        ))
        
        // 第一个协议链接
        var linkAttributes_Nest: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Nest.fontSize_Nest, weight: config_Nest.fontWeight_Nest),
            .foregroundColor: config_Nest.linkColor_Nest
        ]
        if config_Nest.hasUnderline_Nest {
            linkAttributes_Nest[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Nest[.underlineColor] = config_Nest.linkColor_Nest
        }
        
        let firstProtocolString_Nest = NSAttributedString(
            string: firstProtocol_Nest.title_Nest,
            attributes: linkAttributes_Nest
        )
        attributedString_Nest.append(firstProtocolString_Nest)
        
        // 分隔符
        attributedString_Nest.append(NSAttributedString(
            string: config_Nest.separatorText_Nest,
            attributes: prefixAttributes_Nest
        ))
        
        // 第二个协议链接
        let secondProtocolString_Nest = NSAttributedString(
            string: secondProtocol_Nest.title_Nest + ".",
            attributes: linkAttributes_Nest
        )
        attributedString_Nest.append(secondProtocolString_Nest)
        
        label_Nest.attributedText = attributedString_Nest
        
        // 添加点击手势
        let tapGesture_Nest = ProtocolTextTapGesture_Nest(
            firstProtocol_Nest: firstProtocol_Nest,
            firstContent_Nest: firstContent_Nest,
            secondProtocol_Nest: secondProtocol_Nest,
            secondContent_Nest: secondContent_Nest,
            prefixLength_Nest: config_Nest.prefixText_Nest.count,
            firstTitleLength_Nest: firstProtocol_Nest.title_Nest.count,
            separatorLength_Nest: config_Nest.separatorText_Nest.count,
            secondTitleLength_Nest: secondProtocol_Nest.title_Nest.count + 1,
            viewController_Nest: viewController_Nest
        )
        label_Nest.addGestureRecognizer(tapGesture_Nest)
        
        return label_Nest
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Nest: UITapGestureRecognizer {
    
    private let firstProtocol_Nest: ProtocolHelper_Nest.ProtocolType_Nest
    private let firstContent_Nest: String
    private let secondProtocol_Nest: ProtocolHelper_Nest.ProtocolType_Nest
    private let secondContent_Nest: String
    private let prefixLength_Nest: Int
    private let firstTitleLength_Nest: Int
    private let separatorLength_Nest: Int
    private let secondTitleLength_Nest: Int
    private weak var viewController_Nest: UIViewController?
    
    init(
        firstProtocol_Nest: ProtocolHelper_Nest.ProtocolType_Nest,
        firstContent_Nest: String,
        secondProtocol_Nest: ProtocolHelper_Nest.ProtocolType_Nest,
        secondContent_Nest: String,
        prefixLength_Nest: Int,
        firstTitleLength_Nest: Int,
        separatorLength_Nest: Int,
        secondTitleLength_Nest: Int,
        viewController_Nest: UIViewController
    ) {
        self.firstProtocol_Nest = firstProtocol_Nest
        self.firstContent_Nest = firstContent_Nest
        self.secondProtocol_Nest = secondProtocol_Nest
        self.secondContent_Nest = secondContent_Nest
        self.prefixLength_Nest = prefixLength_Nest
        self.firstTitleLength_Nest = firstTitleLength_Nest
        self.separatorLength_Nest = separatorLength_Nest
        self.secondTitleLength_Nest = secondTitleLength_Nest
        self.viewController_Nest = viewController_Nest
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Nest(_:)))
    }
    
    @objc private func handleTap_Nest(_ gesture: UITapGestureRecognizer) {
        guard let label_Nest = gesture.view as? UILabel,
              let attributedText_Nest = label_Nest.attributedText,
              let viewController_Nest = viewController_Nest else { return }
        
        // 计算点击位置
        let location_Nest = gesture.location(in: label_Nest)
        
        // 创建文本容器和布局管理器
        let textStorage_Nest = NSTextStorage(attributedString: attributedText_Nest)
        let layoutManager_Nest = NSLayoutManager()
        let textContainer_Nest = NSTextContainer(size: label_Nest.bounds.size)
        
        layoutManager_Nest.addTextContainer(textContainer_Nest)
        textStorage_Nest.addLayoutManager(layoutManager_Nest)
        
        textContainer_Nest.lineFragmentPadding = 0
        textContainer_Nest.maximumNumberOfLines = label_Nest.numberOfLines
        textContainer_Nest.lineBreakMode = label_Nest.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Nest = layoutManager_Nest.characterIndex(
            for: location_Nest,
            in: textContainer_Nest,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Nest = prefixLength_Nest
        let firstLinkEnd_Nest = firstLinkStart_Nest + firstTitleLength_Nest
        
        let secondLinkStart_Nest = firstLinkEnd_Nest + separatorLength_Nest
        let secondLinkEnd_Nest = secondLinkStart_Nest + secondTitleLength_Nest
        
        if characterIndex_Nest >= firstLinkStart_Nest && characterIndex_Nest < firstLinkEnd_Nest {
            // 点击第一个协议
            ProtocolHelper_Nest.showProtocol_Nest(
                type_Nest: firstProtocol_Nest,
                content_Nest: firstContent_Nest,
                from: viewController_Nest
            )
        } else if characterIndex_Nest >= secondLinkStart_Nest && characterIndex_Nest < secondLinkEnd_Nest {
            // 点击第二个协议
            ProtocolHelper_Nest.showProtocol_Nest(
                type_Nest: secondProtocol_Nest,
                content_Nest: secondContent_Nest,
                from: viewController_Nest
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Nest: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Nest: ProtocolHelper_Nest.ProtocolType_Nest
    private let content_Nest: String
    
    private var webView_Nest: WKWebView?
    private var scrollView_Nest: UIScrollView?
    private var activityIndicator_Nest: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Nest: Bool {
        return content_Nest.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Nest: Bool {
        return content_Nest.hasSuffix(".png") || 
               content_Nest.hasSuffix(".jpg") || 
               content_Nest.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Nest: ProtocolHelper_Nest.ProtocolType_Nest, content_Nest: String) {
        self.protocolType_Nest = type_Nest
        self.content_Nest = content_Nest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Nest()
        loadContent_Nest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Nest() {
        view.backgroundColor = .white
        title = protocolType_Nest.title_Nest
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Nest)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Nest {
            setupWebView_Nest()
            setupActivityIndicator_Nest()
        } else {
            setupScrollView_Nest()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Nest() {
        let webView_Nest = WKWebView()
        webView_Nest.navigationDelegate = self
        view.addSubview(webView_Nest)
        
        webView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Nest = webView_Nest
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Nest() {
        let scrollView_Nest = UIScrollView()
        scrollView_Nest.showsVerticalScrollIndicator = true
        scrollView_Nest.alwaysBounceVertical = true
        view.addSubview(scrollView_Nest)
        
        scrollView_Nest.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Nest = scrollView_Nest
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Nest() {
        let indicator_Nest = UIActivityIndicatorView(style: .large)
        indicator_Nest.color = .gray
        view.addSubview(indicator_Nest)
        
        indicator_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Nest = indicator_Nest
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Nest() {
        if isRemoteURL_Nest {
            loadWebContent_Nest()
        } else if isImage_Nest {
            loadImageContent_Nest()
        } else {
            loadTextContent_Nest()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Nest() {
        guard let url_Nest = URL(string: content_Nest) else { return }
        
        activityIndicator_Nest?.startAnimating()
        
        let request_Nest = URLRequest(url: url_Nest)
        webView_Nest?.load(request_Nest)
    }
    
    /// 加载图片内容
    private func loadImageContent_Nest() {
        guard let scrollView_Nest = scrollView_Nest,
              let image_Nest = UIImage(named: content_Nest) else { return }
        
        let imageView_Nest = UIImageView()
        imageView_Nest.contentMode = .scaleAspectFit
        imageView_Nest.image = image_Nest
        scrollView_Nest.addSubview(imageView_Nest)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Nest = view.bounds.width
        let imageRatio_Nest = image_Nest.size.height / image_Nest.size.width
        let displayHeight_Nest = screenWidth_Nest * imageRatio_Nest
        
        imageView_Nest.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Nest)
            make.height.equalTo(displayHeight_Nest)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Nest() {
        guard let scrollView_Nest = scrollView_Nest else { return }
        
        let textLabel_Nest = UILabel()
        textLabel_Nest.text = content_Nest
        textLabel_Nest.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Nest.textColor = .black
        textLabel_Nest.numberOfLines = 0
        scrollView_Nest.addSubview(textLabel_Nest)
        
        textLabel_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Nest() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Nest: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Nest?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Nest?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Nest?.stopAnimating()
        Utils_Nest.showError_Nest(message_Nest: "Failed to load content")
    }
}
