import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Posture {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Posture {
        case terms_Posture       // 服务条款
        case privacy_Posture     // 隐私政策
        case eula_Posture        // 最终用户许可协议
        case custom_Posture(String) // 自定义协议
        
        /// 获取协议标题
        var title_Posture: String {
            switch self {
            case .terms_Posture:
                return "Terms of Service"
            case .privacy_Posture:
                return "Privacy Policy"
            case .eula_Posture:
                return "EULA"
            case .custom_Posture(let title_Posture):
                return title_Posture
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Posture {
        /// 普通文本颜色
        var textColor_Posture: UIColor
        /// 链接文本颜色
        var linkColor_Posture: UIColor
        /// 字体大小
        var fontSize_Posture: CGFloat
        /// 字体粗细
        var fontWeight_Posture: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Posture: Bool
        /// 前缀文本
        var prefixText_Posture: String
        /// 分隔符文本
        var separatorText_Posture: String
        
        /// 默认初始化
        init(
            textColor_Posture: UIColor = UIColor.gray,
            linkColor_Posture: UIColor = UIColor.black,
            fontSize_Posture: CGFloat = 12,
            fontWeight_Posture: UIFont.Weight = .regular,
            hasUnderline_Posture: Bool = true,
            prefixText_Posture: String = "By continuing you agree with ",
            separatorText_Posture: String = " & "
        ) {
            self.textColor_Posture = textColor_Posture
            self.linkColor_Posture = linkColor_Posture
            self.fontSize_Posture = fontSize_Posture
            self.fontWeight_Posture = fontWeight_Posture
            self.hasUnderline_Posture = hasUnderline_Posture
            self.prefixText_Posture = prefixText_Posture
            self.separatorText_Posture = separatorText_Posture
        }
        
        /// 浅色主题配置
        static func light_Posture() -> ProtocolTextConfig_Posture {
            return ProtocolTextConfig_Posture(
                textColor_Posture: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Posture: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Posture() -> ProtocolTextConfig_Posture {
            return ProtocolTextConfig_Posture(
                textColor_Posture: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Posture: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Posture: 协议类型
    ///   - content_Posture: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Posture: 当前视图控制器
    static func showProtocol_Posture(
        type_Posture: ProtocolType_Posture,
        content_Posture: String,
        from viewController_Posture: UIViewController
    ) {
        let protocolVC_Posture = ProtocolViewController_Posture(
            type_Posture: type_Posture,
            content_Posture: content_Posture
        )
        viewController_Posture.navigationController?.pushViewController(
            protocolVC_Posture,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Posture: 第一个协议类型
    ///   - firstContent_Posture: 第一个协议内容
    ///   - secondProtocol_Posture: 第二个协议类型
    ///   - secondContent_Posture: 第二个协议内容
    ///   - config_Posture: 文本配置
    ///   - viewController_Posture: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Posture(
        firstProtocol_Posture: ProtocolType_Posture = .terms_Posture,
        firstContent_Posture: String,
        secondProtocol_Posture: ProtocolType_Posture = .privacy_Posture,
        secondContent_Posture: String,
        config_Posture: ProtocolTextConfig_Posture = .light_Posture(),
        from viewController_Posture: UIViewController
    ) -> UILabel {
        let label_Posture = UILabel()
        label_Posture.numberOfLines = 0
        label_Posture.textAlignment = .center
        label_Posture.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Posture = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Posture: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Posture.fontSize_Posture, weight: config_Posture.fontWeight_Posture),
            .foregroundColor: config_Posture.textColor_Posture
        ]
        attributedString_Posture.append(NSAttributedString(
            string: config_Posture.prefixText_Posture,
            attributes: prefixAttributes_Posture
        ))
        
        // 第一个协议链接
        var linkAttributes_Posture: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Posture.fontSize_Posture, weight: config_Posture.fontWeight_Posture),
            .foregroundColor: config_Posture.linkColor_Posture
        ]
        if config_Posture.hasUnderline_Posture {
            linkAttributes_Posture[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Posture[.underlineColor] = config_Posture.linkColor_Posture
        }
        
        let firstProtocolString_Posture = NSAttributedString(
            string: firstProtocol_Posture.title_Posture,
            attributes: linkAttributes_Posture
        )
        attributedString_Posture.append(firstProtocolString_Posture)
        
        // 分隔符
        attributedString_Posture.append(NSAttributedString(
            string: config_Posture.separatorText_Posture,
            attributes: prefixAttributes_Posture
        ))
        
        // 第二个协议链接
        let secondProtocolString_Posture = NSAttributedString(
            string: secondProtocol_Posture.title_Posture + ".",
            attributes: linkAttributes_Posture
        )
        attributedString_Posture.append(secondProtocolString_Posture)
        
        label_Posture.attributedText = attributedString_Posture
        
        // 添加点击手势
        let tapGesture_Posture = ProtocolTextTapGesture_Posture(
            firstProtocol_Posture: firstProtocol_Posture,
            firstContent_Posture: firstContent_Posture,
            secondProtocol_Posture: secondProtocol_Posture,
            secondContent_Posture: secondContent_Posture,
            prefixLength_Posture: config_Posture.prefixText_Posture.count,
            firstTitleLength_Posture: firstProtocol_Posture.title_Posture.count,
            separatorLength_Posture: config_Posture.separatorText_Posture.count,
            secondTitleLength_Posture: secondProtocol_Posture.title_Posture.count + 1,
            viewController_Posture: viewController_Posture
        )
        label_Posture.addGestureRecognizer(tapGesture_Posture)
        
        return label_Posture
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Posture: UITapGestureRecognizer {
    
    private let firstProtocol_Posture: ProtocolHelper_Posture.ProtocolType_Posture
    private let firstContent_Posture: String
    private let secondProtocol_Posture: ProtocolHelper_Posture.ProtocolType_Posture
    private let secondContent_Posture: String
    private let prefixLength_Posture: Int
    private let firstTitleLength_Posture: Int
    private let separatorLength_Posture: Int
    private let secondTitleLength_Posture: Int
    private weak var viewController_Posture: UIViewController?
    
    init(
        firstProtocol_Posture: ProtocolHelper_Posture.ProtocolType_Posture,
        firstContent_Posture: String,
        secondProtocol_Posture: ProtocolHelper_Posture.ProtocolType_Posture,
        secondContent_Posture: String,
        prefixLength_Posture: Int,
        firstTitleLength_Posture: Int,
        separatorLength_Posture: Int,
        secondTitleLength_Posture: Int,
        viewController_Posture: UIViewController
    ) {
        self.firstProtocol_Posture = firstProtocol_Posture
        self.firstContent_Posture = firstContent_Posture
        self.secondProtocol_Posture = secondProtocol_Posture
        self.secondContent_Posture = secondContent_Posture
        self.prefixLength_Posture = prefixLength_Posture
        self.firstTitleLength_Posture = firstTitleLength_Posture
        self.separatorLength_Posture = separatorLength_Posture
        self.secondTitleLength_Posture = secondTitleLength_Posture
        self.viewController_Posture = viewController_Posture
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Posture(_:)))
    }
    
    @objc private func handleTap_Posture(_ gesture: UITapGestureRecognizer) {
        guard let label_Posture = gesture.view as? UILabel,
              let attributedText_Posture = label_Posture.attributedText,
              let viewController_Posture = viewController_Posture else { return }
        
        // 计算点击位置
        let location_Posture = gesture.location(in: label_Posture)
        
        // 创建文本容器和布局管理器
        let textStorage_Posture = NSTextStorage(attributedString: attributedText_Posture)
        let layoutManager_Posture = NSLayoutManager()
        let textContainer_Posture = NSTextContainer(size: label_Posture.bounds.size)
        
        layoutManager_Posture.addTextContainer(textContainer_Posture)
        textStorage_Posture.addLayoutManager(layoutManager_Posture)
        
        textContainer_Posture.lineFragmentPadding = 0
        textContainer_Posture.maximumNumberOfLines = label_Posture.numberOfLines
        textContainer_Posture.lineBreakMode = label_Posture.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Posture = layoutManager_Posture.characterIndex(
            for: location_Posture,
            in: textContainer_Posture,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Posture = prefixLength_Posture
        let firstLinkEnd_Posture = firstLinkStart_Posture + firstTitleLength_Posture
        
        let secondLinkStart_Posture = firstLinkEnd_Posture + separatorLength_Posture
        let secondLinkEnd_Posture = secondLinkStart_Posture + secondTitleLength_Posture
        
        if characterIndex_Posture >= firstLinkStart_Posture && characterIndex_Posture < firstLinkEnd_Posture {
            // 点击第一个协议
            ProtocolHelper_Posture.showProtocol_Posture(
                type_Posture: firstProtocol_Posture,
                content_Posture: firstContent_Posture,
                from: viewController_Posture
            )
        } else if characterIndex_Posture >= secondLinkStart_Posture && characterIndex_Posture < secondLinkEnd_Posture {
            // 点击第二个协议
            ProtocolHelper_Posture.showProtocol_Posture(
                type_Posture: secondProtocol_Posture,
                content_Posture: secondContent_Posture,
                from: viewController_Posture
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Posture: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Posture: ProtocolHelper_Posture.ProtocolType_Posture
    private let content_Posture: String
    
    private var webView_Posture: WKWebView?
    private var scrollView_Posture: UIScrollView?
    private var activityIndicator_Posture: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Posture: Bool {
        return content_Posture.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Posture: Bool {
        return content_Posture.hasSuffix(".png") || 
               content_Posture.hasSuffix(".jpg") || 
               content_Posture.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Posture: ProtocolHelper_Posture.ProtocolType_Posture, content_Posture: String) {
        self.protocolType_Posture = type_Posture
        self.content_Posture = content_Posture
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        loadContent_Posture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 整个 App 统一隐藏系统 navigationBar，使用自定义顶栏
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI设置
    
    /// 搭建协议页 UI（自定义顶栏 + 内容区）
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        // ── 自定义顶栏 ──────────────────────────────────
        let navBar_Posture = UIView()
        navBar_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        let backButton_Posture = UIButton(type: .system)
        backButton_Posture.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton_Posture.tintColor = ColorConfig_Posture.textPrimary_Posture
        backButton_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        backButton_Posture.layer.cornerRadius = 22
        backButton_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        backButton_Posture.layer.shadowOpacity = 1
        backButton_Posture.layer.shadowRadius  = 8
        backButton_Posture.layer.shadowOffset  = CGSize(width: 0, height: 4)
        backButton_Posture.addAction(UIAction { [weak self] _ in self?.backTapped_Posture() }, for: .touchUpInside)

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = protocolType_Posture.title_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 协议类型徽章（颜色根据类型区分）
        let badgeColor_Posture: UIColor
        let badgeIcon_Posture: String
        switch protocolType_Posture {
        case .terms_Posture:
            badgeColor_Posture = ColorConfig_Posture.accentIndigo_Posture
            badgeIcon_Posture  = "doc.text.fill"
        case .privacy_Posture:
            badgeColor_Posture = ColorConfig_Posture.accentTeal_Posture
            badgeIcon_Posture  = "lock.shield.fill"
        case .eula_Posture:
            badgeColor_Posture = ColorConfig_Posture.accentAmber_Posture
            badgeIcon_Posture  = "checkmark.seal.fill"
        case .custom_Posture:
            badgeColor_Posture = ColorConfig_Posture.primaryGradientStart_Posture
            badgeIcon_Posture  = "doc.fill"
        }

        let badgeView_Posture = UIView()
        badgeView_Posture.backgroundColor = badgeColor_Posture.withAlphaComponent(0.14)
        badgeView_Posture.layer.cornerRadius = 20

        let badgeIconView_Posture = UIImageView(image: UIImage(systemName: badgeIcon_Posture))
        badgeIconView_Posture.tintColor = badgeColor_Posture
        badgeIconView_Posture.contentMode = .scaleAspectFit
        badgeView_Posture.addSubview(badgeIconView_Posture)
        badgeIconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        view.addSubview(navBar_Posture)
        navBar_Posture.addSubview(backButton_Posture)
        navBar_Posture.addSubview(titleLabel_Posture)
        navBar_Posture.addSubview(badgeView_Posture)

        navBar_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        backButton_Posture.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
        badgeView_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Posture)
            make.leading.equalTo(backButton_Posture.snp.trailing).offset(12)
            make.width.height.equalTo(40)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Posture)
            make.leading.equalTo(badgeView_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(18)
        }

        // ── 内容区（自定义顶栏以下）─────────────────────
        if isRemoteURL_Posture {
            setupWebView_Posture(topAnchor: navBar_Posture.snp.bottom)
            setupActivityIndicator_Posture()
        } else {
            setupScrollView_Posture(topAnchor: navBar_Posture.snp.bottom)
        }
    }
    
    /// 设置 WebView
    /// - Parameter topAnchor: 内容区顶部约束锚点（自定义导航栏底部）
    /// - Returns: Void
    /// - Throws: 无
    private func setupWebView_Posture(topAnchor: ConstraintRelatableTarget) {
        let webView_Posture = WKWebView()
        webView_Posture.navigationDelegate = self
        view.addSubview(webView_Posture)
        
        webView_Posture.snp.makeConstraints { make in
            make.top.equalTo(topAnchor)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.webView_Posture = webView_Posture
    }
    
    /// 设置 ScrollView（用于文本和图片）
    /// - Parameter topAnchor: 内容区顶部约束锚点（自定义导航栏底部）
    /// - Returns: Void
    /// - Throws: 无
    private func setupScrollView_Posture(topAnchor: ConstraintRelatableTarget) {
        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsVerticalScrollIndicator = true
        scrollView_Posture.alwaysBounceVertical = true
        scrollView_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        view.addSubview(scrollView_Posture)
        
        scrollView_Posture.snp.makeConstraints { make in
            make.top.equalTo(topAnchor)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.scrollView_Posture = scrollView_Posture
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Posture() {
        let indicator_Posture = UIActivityIndicatorView(style: .large)
        indicator_Posture.color = .gray
        view.addSubview(indicator_Posture)
        
        indicator_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Posture = indicator_Posture
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Posture() {
        if isRemoteURL_Posture {
            loadWebContent_Posture()
        } else if isImage_Posture {
            loadImageContent_Posture()
        } else {
            loadTextContent_Posture()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Posture() {
        guard let url_Posture = URL(string: content_Posture) else { return }
        
        activityIndicator_Posture?.startAnimating()
        
        let request_Posture = URLRequest(url: url_Posture)
        webView_Posture?.load(request_Posture)
    }
    
    /// 加载图片内容
    private func loadImageContent_Posture() {
        guard let scrollView_Posture = scrollView_Posture,
              let image_Posture = UIImage(named: content_Posture) else { return }
        
        let imageView_Posture = UIImageView()
        imageView_Posture.contentMode = .scaleAspectFit
        imageView_Posture.image = image_Posture
        scrollView_Posture.addSubview(imageView_Posture)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Posture = view.bounds.width
        let imageRatio_Posture = image_Posture.size.height / image_Posture.size.width
        let displayHeight_Posture = screenWidth_Posture * imageRatio_Posture
        
        imageView_Posture.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Posture)
            make.height.equalTo(displayHeight_Posture)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Posture() {
        guard let scrollView_Posture = scrollView_Posture else { return }
        
        let textLabel_Posture = UILabel()
        textLabel_Posture.text = content_Posture
        textLabel_Posture.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Posture.textColor = .black
        textLabel_Posture.numberOfLines = 0
        scrollView_Posture.addSubview(textLabel_Posture)
        
        textLabel_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    /// 返回上一页
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func backTapped_Posture() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Posture: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Posture?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Posture?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Posture?.stopAnimating()
        Utils_Posture.showError_Posture(message_Posture: "Failed to load content")
    }
}
