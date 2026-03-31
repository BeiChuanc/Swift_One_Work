import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片；协议页使用页内顶栏（返回、标题），不依赖系统导航栏；无导航栈时全屏模态包一层导航控制器以便 dismiss
class ProtocolHelper_Flick {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Flick {
        case terms_Flick       // 服务条款
        case privacy_Flick     // 隐私政策
        case eula_Flick        // 最终用户许可协议
        case custom_Flick(String) // 自定义协议
        
        /// 获取协议标题
        var title_Flick: String {
            switch self {
            case .terms_Flick:
                return "Terms of Service"
            case .privacy_Flick:
                return "Privacy Policy"
            case .eula_Flick:
                return "EULA"
            case .custom_Flick(let title_Flick):
                return title_Flick
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Flick {
        /// 普通文本颜色
        var textColor_Flick: UIColor
        /// 链接文本颜色
        var linkColor_Flick: UIColor
        /// 字体大小
        var fontSize_Flick: CGFloat
        /// 字体粗细
        var fontWeight_Flick: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Flick: Bool
        /// 前缀文本
        var prefixText_Flick: String
        /// 分隔符文本
        var separatorText_Flick: String
        
        /// 默认初始化
        init(
            textColor_Flick: UIColor = UIColor.gray,
            linkColor_Flick: UIColor = UIColor.black,
            fontSize_Flick: CGFloat = 12,
            fontWeight_Flick: UIFont.Weight = .regular,
            hasUnderline_Flick: Bool = true,
            prefixText_Flick: String = "By continuing you agree with ",
            separatorText_Flick: String = " & "
        ) {
            self.textColor_Flick = textColor_Flick
            self.linkColor_Flick = linkColor_Flick
            self.fontSize_Flick = fontSize_Flick
            self.fontWeight_Flick = fontWeight_Flick
            self.hasUnderline_Flick = hasUnderline_Flick
            self.prefixText_Flick = prefixText_Flick
            self.separatorText_Flick = separatorText_Flick
        }
        
        /// 浅色主题配置
        static func light_Flick() -> ProtocolTextConfig_Flick {
            return ProtocolTextConfig_Flick(
                textColor_Flick: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Flick: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Flick() -> ProtocolTextConfig_Flick {
            return ProtocolTextConfig_Flick(
                textColor_Flick: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Flick: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Flick: 协议类型
    ///   - content_Flick: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Flick: 当前视图控制器；若不在导航栈内（如 Tab 根页），则全屏模态嵌入导航栏展示，与设置页推入后的展示一致
    static func showProtocol_Flick(
        type_Flick: ProtocolType_Flick,
        content_Flick: String,
        from viewController_Flick: UIViewController
    ) {
        let protocolVC_Flick = ProtocolViewController_Flick(
            type_Flick: type_Flick,
            content_Flick: content_Flick
        )
        if let nav_flick = viewController_Flick.navigationController {
            nav_flick.pushViewController(protocolVC_Flick, animated: true)
        } else {
            let wrapNav_flick = UINavigationController(rootViewController: protocolVC_Flick)
            wrapNav_flick.modalPresentationStyle = .fullScreen
            wrapNav_flick.setNavigationBarHidden(true, animated: false)
            viewController_Flick.present(wrapNav_flick, animated: true)
        }
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Flick: 第一个协议类型
    ///   - firstContent_Flick: 第一个协议内容
    ///   - secondProtocol_Flick: 第二个协议类型
    ///   - secondContent_Flick: 第二个协议内容
    ///   - config_Flick: 文本配置
    ///   - viewController_Flick: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Flick(
        firstProtocol_Flick: ProtocolType_Flick = .terms_Flick,
        firstContent_Flick: String,
        secondProtocol_Flick: ProtocolType_Flick = .privacy_Flick,
        secondContent_Flick: String,
        config_Flick: ProtocolTextConfig_Flick = .light_Flick(),
        from viewController_Flick: UIViewController
    ) -> UILabel {
        let label_Flick = UILabel()
        label_Flick.numberOfLines = 0
        label_Flick.textAlignment = .center
        label_Flick.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Flick = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Flick: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Flick.fontSize_Flick, weight: config_Flick.fontWeight_Flick),
            .foregroundColor: config_Flick.textColor_Flick
        ]
        attributedString_Flick.append(NSAttributedString(
            string: config_Flick.prefixText_Flick,
            attributes: prefixAttributes_Flick
        ))
        
        // 第一个协议链接
        var linkAttributes_Flick: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Flick.fontSize_Flick, weight: config_Flick.fontWeight_Flick),
            .foregroundColor: config_Flick.linkColor_Flick
        ]
        if config_Flick.hasUnderline_Flick {
            linkAttributes_Flick[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Flick[.underlineColor] = config_Flick.linkColor_Flick
        }
        
        let firstProtocolString_Flick = NSAttributedString(
            string: firstProtocol_Flick.title_Flick,
            attributes: linkAttributes_Flick
        )
        attributedString_Flick.append(firstProtocolString_Flick)
        
        // 分隔符
        attributedString_Flick.append(NSAttributedString(
            string: config_Flick.separatorText_Flick,
            attributes: prefixAttributes_Flick
        ))
        
        // 第二个协议链接
        let secondProtocolString_Flick = NSAttributedString(
            string: secondProtocol_Flick.title_Flick + ".",
            attributes: linkAttributes_Flick
        )
        attributedString_Flick.append(secondProtocolString_Flick)
        
        label_Flick.attributedText = attributedString_Flick
        
        // 添加点击手势
        let tapGesture_Flick = ProtocolTextTapGesture_Flick(
            firstProtocol_Flick: firstProtocol_Flick,
            firstContent_Flick: firstContent_Flick,
            secondProtocol_Flick: secondProtocol_Flick,
            secondContent_Flick: secondContent_Flick,
            prefixLength_Flick: config_Flick.prefixText_Flick.count,
            firstTitleLength_Flick: firstProtocol_Flick.title_Flick.count,
            separatorLength_Flick: config_Flick.separatorText_Flick.count,
            secondTitleLength_Flick: secondProtocol_Flick.title_Flick.count + 1,
            viewController_Flick: viewController_Flick
        )
        label_Flick.addGestureRecognizer(tapGesture_Flick)
        
        return label_Flick
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Flick: UITapGestureRecognizer {
    
    private let firstProtocol_Flick: ProtocolHelper_Flick.ProtocolType_Flick
    private let firstContent_Flick: String
    private let secondProtocol_Flick: ProtocolHelper_Flick.ProtocolType_Flick
    private let secondContent_Flick: String
    private let prefixLength_Flick: Int
    private let firstTitleLength_Flick: Int
    private let separatorLength_Flick: Int
    private let secondTitleLength_Flick: Int
    private weak var viewController_Flick: UIViewController?
    
    init(
        firstProtocol_Flick: ProtocolHelper_Flick.ProtocolType_Flick,
        firstContent_Flick: String,
        secondProtocol_Flick: ProtocolHelper_Flick.ProtocolType_Flick,
        secondContent_Flick: String,
        prefixLength_Flick: Int,
        firstTitleLength_Flick: Int,
        separatorLength_Flick: Int,
        secondTitleLength_Flick: Int,
        viewController_Flick: UIViewController
    ) {
        self.firstProtocol_Flick = firstProtocol_Flick
        self.firstContent_Flick = firstContent_Flick
        self.secondProtocol_Flick = secondProtocol_Flick
        self.secondContent_Flick = secondContent_Flick
        self.prefixLength_Flick = prefixLength_Flick
        self.firstTitleLength_Flick = firstTitleLength_Flick
        self.separatorLength_Flick = separatorLength_Flick
        self.secondTitleLength_Flick = secondTitleLength_Flick
        self.viewController_Flick = viewController_Flick
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Flick(_:)))
    }
    
    @objc private func handleTap_Flick(_ gesture: UITapGestureRecognizer) {
        guard let label_Flick = gesture.view as? UILabel,
              let attributedText_Flick = label_Flick.attributedText,
              let viewController_Flick = viewController_Flick else { return }
        
        // 计算点击位置
        let location_Flick = gesture.location(in: label_Flick)
        
        // 创建文本容器和布局管理器
        let textStorage_Flick = NSTextStorage(attributedString: attributedText_Flick)
        let layoutManager_Flick = NSLayoutManager()
        let textContainer_Flick = NSTextContainer(size: label_Flick.bounds.size)
        
        layoutManager_Flick.addTextContainer(textContainer_Flick)
        textStorage_Flick.addLayoutManager(layoutManager_Flick)
        
        textContainer_Flick.lineFragmentPadding = 0
        textContainer_Flick.maximumNumberOfLines = label_Flick.numberOfLines
        textContainer_Flick.lineBreakMode = label_Flick.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Flick = layoutManager_Flick.characterIndex(
            for: location_Flick,
            in: textContainer_Flick,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Flick = prefixLength_Flick
        let firstLinkEnd_Flick = firstLinkStart_Flick + firstTitleLength_Flick
        
        let secondLinkStart_Flick = firstLinkEnd_Flick + separatorLength_Flick
        let secondLinkEnd_Flick = secondLinkStart_Flick + secondTitleLength_Flick
        
        if characterIndex_Flick >= firstLinkStart_Flick && characterIndex_Flick < firstLinkEnd_Flick {
            // 点击第一个协议
            ProtocolHelper_Flick.showProtocol_Flick(
                type_Flick: firstProtocol_Flick,
                content_Flick: firstContent_Flick,
                from: viewController_Flick
            )
        } else if characterIndex_Flick >= secondLinkStart_Flick && characterIndex_Flick < secondLinkEnd_Flick {
            // 点击第二个协议
            ProtocolHelper_Flick.showProtocol_Flick(
                type_Flick: secondProtocol_Flick,
                content_Flick: secondContent_Flick,
                from: viewController_Flick
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
/// 设计：页内自建顶栏（返回、标题），不依赖 `UINavigationBar`，避免根导航全局隐藏或透明样式导致看不见返回与标题
class ProtocolViewController_Flick: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Flick: ProtocolHelper_Flick.ProtocolType_Flick
    private let content_Flick: String
    
    private var webView_Flick: WKWebView?
    private var scrollView_Flick: UIScrollView?
    private var activityIndicator_Flick: UIActivityIndicatorView?

    /// 自定顶栏容器
    private let headerView_Flick: UIView = {
        let v_flick = UIView()
        v_flick.backgroundColor = .white
        return v_flick
    }()

    private lazy var headerBackBtn_Flick: UIButton = {
        let b_flick = UIButton(type: .system)
        let img_flick = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        b_flick.setImage(img_flick, for: .normal)
        b_flick.tintColor = .black
        b_flick.accessibilityLabel = "Back"
        b_flick.addTarget(self, action: #selector(backTapped_Flick), for: .touchUpInside)
        return b_flick
    }()

    private let headerTitleLabel_Flick: UILabel = {
        let l_flick = UILabel()
        l_flick.font = .systemFont(ofSize: 17, weight: .semibold)
        l_flick.textColor = ColorConfig_Flick.textPrimary_Flick
        l_flick.textAlignment = .center
        l_flick.numberOfLines = 1
        return l_flick
    }()

    private let headerBottomLine_Flick: UIView = {
        let v_flick = UIView()
        v_flick.backgroundColor = UIColor.black.withValues(alpha: 0.08)
        return v_flick
    }()
    
    /// 是否是远程 URL
    private var isRemoteURL_Flick: Bool {
        return content_Flick.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Flick: Bool {
        return content_Flick.hasSuffix(".png") || 
               content_Flick.hasSuffix(".jpg") || 
               content_Flick.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Flick: ProtocolHelper_Flick.ProtocolType_Flick, content_Flick: String) {
        self.protocolType_Flick = type_Flick
        self.content_Flick = content_Flick
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        loadContent_Flick()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 仅使用页内顶栏；系统导航栏在根窗口常被全局隐藏，开启后仍可能不渲染
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 从发布等 Tab 子页 push 上来时栈为 [TabBar, 协议]；返回 Tab 后需恢复根导航隐藏，避免发布页顶栏异常
        guard isMovingFromParent,
              let nav_flick = navigationController,
              nav_flick.viewControllers.count == 2,
              nav_flick.viewControllers.first is TabBar_Flick else { return }
        nav_flick.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Flick() {
        view.backgroundColor = .white
        setupHeaderChrome_Flick()
        if isRemoteURL_Flick {
            setupWebView_Flick()
            setupActivityIndicator_Flick()
        } else {
            setupScrollView_Flick()
        }
    }

    /// 构建页内顶栏：返回、标题
    private func setupHeaderChrome_Flick() {
        headerTitleLabel_Flick.text = protocolType_Flick.title_Flick

        view.addSubview(headerView_Flick)
        headerView_Flick.addSubview(headerBackBtn_Flick)
        headerView_Flick.addSubview(headerTitleLabel_Flick)
        headerView_Flick.addSubview(headerBottomLine_Flick)

        headerView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        headerBackBtn_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
            make.width.height.equalTo(44)
        }
        headerTitleLabel_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(headerBackBtn_Flick)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(headerBackBtn_Flick.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        headerBottomLine_Flick.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Flick.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1.0 / max(UIScreen.main.scale, 1))
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Flick() {
        let webView_Flick = WKWebView()
        webView_Flick.navigationDelegate = self
        view.addSubview(webView_Flick)
        
        webView_Flick.snp.makeConstraints { make in
            make.top.equalTo(headerView_Flick.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.webView_Flick = webView_Flick
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Flick() {
        let scrollView_Flick = UIScrollView()
        scrollView_Flick.showsVerticalScrollIndicator = true
        scrollView_Flick.alwaysBounceVertical = true
        view.addSubview(scrollView_Flick)
        
        scrollView_Flick.snp.makeConstraints { make in
            make.top.equalTo(headerView_Flick.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.scrollView_Flick = scrollView_Flick
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Flick() {
        let indicator_Flick = UIActivityIndicatorView(style: .large)
        indicator_Flick.color = .gray
        view.addSubview(indicator_Flick)
        
        indicator_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Flick = indicator_Flick
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Flick() {
        if isRemoteURL_Flick {
            loadWebContent_Flick()
        } else if isImage_Flick {
            loadImageContent_Flick()
        } else {
            loadTextContent_Flick()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Flick() {
        guard let url_Flick = URL(string: content_Flick) else { return }
        
        activityIndicator_Flick?.startAnimating()
        
        let request_Flick = URLRequest(url: url_Flick)
        webView_Flick?.load(request_Flick)
    }
    
    /// 加载图片内容
    private func loadImageContent_Flick() {
        guard let scrollView_Flick = scrollView_Flick,
              let image_Flick = UIImage(named: content_Flick) else { return }
        
        let imageView_Flick = UIImageView()
        imageView_Flick.contentMode = .scaleAspectFit
        imageView_Flick.image = image_Flick
        scrollView_Flick.addSubview(imageView_Flick)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Flick = view.bounds.width
        let imageRatio_Flick = image_Flick.size.height / image_Flick.size.width
        let displayHeight_Flick = screenWidth_Flick * imageRatio_Flick
        
        imageView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Flick)
            make.height.equalTo(displayHeight_Flick)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Flick() {
        guard let scrollView_Flick = scrollView_Flick else { return }
        
        let textLabel_Flick = UILabel()
        textLabel_Flick.text = content_Flick
        textLabel_Flick.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Flick.textColor = .black
        textLabel_Flick.numberOfLines = 0
        scrollView_Flick.addSubview(textLabel_Flick)
        
        textLabel_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Flick() {
        guard let nav_flick = navigationController else {
            dismiss(animated: true)
            return
        }
        // 全屏模态仅包一层导航且根页即协议页时，pop 无上一级，应关掉整层导航
        if nav_flick.viewControllers.count <= 1 {
            nav_flick.dismiss(animated: true)
        } else {
            nav_flick.popViewController(animated: true)
        }
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Flick: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Flick?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Flick?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Flick?.stopAnimating()
        Utils_Flick.showError_Flick(message_Flick: "Failed to load content")
    }
}
