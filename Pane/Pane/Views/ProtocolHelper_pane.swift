import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Pane {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Pane {
        case terms_Pane       // 服务条款
        case privacy_Pane     // 隐私政策
        case eula_Pane        // 最终用户许可协议
        case custom_Pane(String) // 自定义协议
        
        /// 获取协议标题
        var title_Pane: String {
            switch self {
            case .terms_Pane:
                return "Terms of Service"
            case .privacy_Pane:
                return "Privacy Policy"
            case .eula_Pane:
                return "EULA"
            case .custom_Pane(let title_Pane):
                return title_Pane
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Pane {
        /// 普通文本颜色
        var textColor_Pane: UIColor
        /// 链接文本颜色
        var linkColor_Pane: UIColor
        /// 字体大小
        var fontSize_Pane: CGFloat
        /// 字体粗细
        var fontWeight_Pane: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Pane: Bool
        /// 前缀文本
        var prefixText_Pane: String
        /// 分隔符文本
        var separatorText_Pane: String
        
        /// 默认初始化
        init(
            textColor_Pane: UIColor = UIColor.gray,
            linkColor_Pane: UIColor = UIColor.black,
            fontSize_Pane: CGFloat = 12,
            fontWeight_Pane: UIFont.Weight = .regular,
            hasUnderline_Pane: Bool = true,
            prefixText_Pane: String = "By continuing you agree with ",
            separatorText_Pane: String = " & "
        ) {
            self.textColor_Pane = textColor_Pane
            self.linkColor_Pane = linkColor_Pane
            self.fontSize_Pane = fontSize_Pane
            self.fontWeight_Pane = fontWeight_Pane
            self.hasUnderline_Pane = hasUnderline_Pane
            self.prefixText_Pane = prefixText_Pane
            self.separatorText_Pane = separatorText_Pane
        }
        
        /// 浅色主题配置
        static func light_Pane() -> ProtocolTextConfig_Pane {
            return ProtocolTextConfig_Pane(
                textColor_Pane: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Pane: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Pane() -> ProtocolTextConfig_Pane {
            return ProtocolTextConfig_Pane(
                textColor_Pane: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Pane: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Pane: 协议类型
    ///   - content_Pane: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Pane: 当前视图控制器
    /// 优先 push（已有导航控制器），否则包裹导航控制器后 present
    static func showProtocol_Pane(
        type_Pane: ProtocolType_Pane,
        content_Pane: String,
        from viewController_Pane: UIViewController
    ) {
        let protocolVC_Pane = ProtocolViewController_Pane(
            type_Pane: type_Pane,
            content_Pane: content_Pane
        )
        if let nav_Pane = viewController_Pane.navigationController {
            // 已在导航栈内，直接 push
            nav_Pane.pushViewController(protocolVC_Pane, animated: true)
        } else {
            // modal 场景：包裹导航控制器后 present，确保返回按钮可见
            let nav_Pane = UINavigationController(rootViewController: protocolVC_Pane)
            nav_Pane.modalPresentationStyle = .fullScreen
            viewController_Pane.present(nav_Pane, animated: true)
        }
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Pane: 第一个协议类型
    ///   - firstContent_Pane: 第一个协议内容
    ///   - secondProtocol_Pane: 第二个协议类型
    ///   - secondContent_Pane: 第二个协议内容
    ///   - config_Pane: 文本配置
    ///   - viewController_Pane: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Pane(
        firstProtocol_Pane: ProtocolType_Pane = .terms_Pane,
        firstContent_Pane: String,
        secondProtocol_Pane: ProtocolType_Pane = .privacy_Pane,
        secondContent_Pane: String,
        config_Pane: ProtocolTextConfig_Pane = .light_Pane(),
        from viewController_Pane: UIViewController
    ) -> UILabel {
        let label_Pane = UILabel()
        label_Pane.numberOfLines = 0
        label_Pane.textAlignment = .center
        label_Pane.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Pane = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Pane: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Pane.fontSize_Pane, weight: config_Pane.fontWeight_Pane),
            .foregroundColor: config_Pane.textColor_Pane
        ]
        attributedString_Pane.append(NSAttributedString(
            string: config_Pane.prefixText_Pane,
            attributes: prefixAttributes_Pane
        ))
        
        // 第一个协议链接
        var linkAttributes_Pane: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Pane.fontSize_Pane, weight: config_Pane.fontWeight_Pane),
            .foregroundColor: config_Pane.linkColor_Pane
        ]
        if config_Pane.hasUnderline_Pane {
            linkAttributes_Pane[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Pane[.underlineColor] = config_Pane.linkColor_Pane
        }
        
        let firstProtocolString_Pane = NSAttributedString(
            string: firstProtocol_Pane.title_Pane,
            attributes: linkAttributes_Pane
        )
        attributedString_Pane.append(firstProtocolString_Pane)
        
        // 分隔符
        attributedString_Pane.append(NSAttributedString(
            string: config_Pane.separatorText_Pane,
            attributes: prefixAttributes_Pane
        ))
        
        // 第二个协议链接
        let secondProtocolString_Pane = NSAttributedString(
            string: secondProtocol_Pane.title_Pane + ".",
            attributes: linkAttributes_Pane
        )
        attributedString_Pane.append(secondProtocolString_Pane)
        
        label_Pane.attributedText = attributedString_Pane
        
        // 添加点击手势
        let tapGesture_Pane = ProtocolTextTapGesture_Pane(
            firstProtocol_Pane: firstProtocol_Pane,
            firstContent_Pane: firstContent_Pane,
            secondProtocol_Pane: secondProtocol_Pane,
            secondContent_Pane: secondContent_Pane,
            prefixLength_Pane: config_Pane.prefixText_Pane.count,
            firstTitleLength_Pane: firstProtocol_Pane.title_Pane.count,
            separatorLength_Pane: config_Pane.separatorText_Pane.count,
            secondTitleLength_Pane: secondProtocol_Pane.title_Pane.count + 1,
            viewController_Pane: viewController_Pane
        )
        label_Pane.addGestureRecognizer(tapGesture_Pane)
        
        return label_Pane
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Pane: UITapGestureRecognizer {
    
    private let firstProtocol_Pane: ProtocolHelper_Pane.ProtocolType_Pane
    private let firstContent_Pane: String
    private let secondProtocol_Pane: ProtocolHelper_Pane.ProtocolType_Pane
    private let secondContent_Pane: String
    private let prefixLength_Pane: Int
    private let firstTitleLength_Pane: Int
    private let separatorLength_Pane: Int
    private let secondTitleLength_Pane: Int
    private weak var viewController_Pane: UIViewController?
    
    init(
        firstProtocol_Pane: ProtocolHelper_Pane.ProtocolType_Pane,
        firstContent_Pane: String,
        secondProtocol_Pane: ProtocolHelper_Pane.ProtocolType_Pane,
        secondContent_Pane: String,
        prefixLength_Pane: Int,
        firstTitleLength_Pane: Int,
        separatorLength_Pane: Int,
        secondTitleLength_Pane: Int,
        viewController_Pane: UIViewController
    ) {
        self.firstProtocol_Pane = firstProtocol_Pane
        self.firstContent_Pane = firstContent_Pane
        self.secondProtocol_Pane = secondProtocol_Pane
        self.secondContent_Pane = secondContent_Pane
        self.prefixLength_Pane = prefixLength_Pane
        self.firstTitleLength_Pane = firstTitleLength_Pane
        self.separatorLength_Pane = separatorLength_Pane
        self.secondTitleLength_Pane = secondTitleLength_Pane
        self.viewController_Pane = viewController_Pane
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Pane(_:)))
    }
    
    @objc private func handleTap_Pane(_ gesture: UITapGestureRecognizer) {
        guard let label_Pane = gesture.view as? UILabel,
              let attributedText_Pane = label_Pane.attributedText,
              let viewController_Pane = viewController_Pane else { return }
        
        // 计算点击位置
        let location_Pane = gesture.location(in: label_Pane)
        
        // 创建文本容器和布局管理器
        let textStorage_Pane = NSTextStorage(attributedString: attributedText_Pane)
        let layoutManager_Pane = NSLayoutManager()
        let textContainer_Pane = NSTextContainer(size: label_Pane.bounds.size)
        
        layoutManager_Pane.addTextContainer(textContainer_Pane)
        textStorage_Pane.addLayoutManager(layoutManager_Pane)
        
        textContainer_Pane.lineFragmentPadding = 0
        textContainer_Pane.maximumNumberOfLines = label_Pane.numberOfLines
        textContainer_Pane.lineBreakMode = label_Pane.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Pane = layoutManager_Pane.characterIndex(
            for: location_Pane,
            in: textContainer_Pane,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Pane = prefixLength_Pane
        let firstLinkEnd_Pane = firstLinkStart_Pane + firstTitleLength_Pane
        
        let secondLinkStart_Pane = firstLinkEnd_Pane + separatorLength_Pane
        let secondLinkEnd_Pane = secondLinkStart_Pane + secondTitleLength_Pane
        
        if characterIndex_Pane >= firstLinkStart_Pane && characterIndex_Pane < firstLinkEnd_Pane {
            // 点击第一个协议
            ProtocolHelper_Pane.showProtocol_Pane(
                type_Pane: firstProtocol_Pane,
                content_Pane: firstContent_Pane,
                from: viewController_Pane
            )
        } else if characterIndex_Pane >= secondLinkStart_Pane && characterIndex_Pane < secondLinkEnd_Pane {
            // 点击第二个协议
            ProtocolHelper_Pane.showProtocol_Pane(
                type_Pane: secondProtocol_Pane,
                content_Pane: secondContent_Pane,
                from: viewController_Pane
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Pane: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Pane: ProtocolHelper_Pane.ProtocolType_Pane
    private let content_Pane: String
    
    private var webView_Pane: WKWebView?
    private var scrollView_Pane: UIScrollView?
    private var activityIndicator_Pane: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Pane: Bool {
        return content_Pane.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Pane: Bool {
        return content_Pane.hasSuffix(".png") || 
               content_Pane.hasSuffix(".jpg") || 
               content_Pane.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Pane: ProtocolHelper_Pane.ProtocolType_Pane, content_Pane: String) {
        self.protocolType_Pane = type_Pane
        self.content_Pane = content_Pane
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        loadContent_Pane()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Pane() {
        view.backgroundColor = .white
        title = protocolType_Pane.title_Pane
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Pane)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Pane {
            setupWebView_Pane()
            setupActivityIndicator_Pane()
        } else {
            setupScrollView_Pane()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Pane() {
        let webView_Pane = WKWebView()
        webView_Pane.navigationDelegate = self
        view.addSubview(webView_Pane)
        
        webView_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Pane = webView_Pane
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Pane() {
        let scrollView_Pane = UIScrollView()
        scrollView_Pane.showsVerticalScrollIndicator = true
        scrollView_Pane.alwaysBounceVertical = true
        view.addSubview(scrollView_Pane)
        
        scrollView_Pane.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Pane = scrollView_Pane
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Pane() {
        let indicator_Pane = UIActivityIndicatorView(style: .large)
        indicator_Pane.color = .gray
        view.addSubview(indicator_Pane)
        
        indicator_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Pane = indicator_Pane
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Pane() {
        if isRemoteURL_Pane {
            loadWebContent_Pane()
        } else if isImage_Pane {
            loadImageContent_Pane()
        } else {
            loadTextContent_Pane()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Pane() {
        guard let url_Pane = URL(string: content_Pane) else { return }
        
        activityIndicator_Pane?.startAnimating()
        
        let request_Pane = URLRequest(url: url_Pane)
        webView_Pane?.load(request_Pane)
    }
    
    /// 加载图片内容
    private func loadImageContent_Pane() {
        guard let scrollView_Pane = scrollView_Pane,
              let image_Pane = UIImage(named: content_Pane) else { return }
        
        let imageView_Pane = UIImageView()
        imageView_Pane.contentMode = .scaleAspectFit
        imageView_Pane.image = image_Pane
        scrollView_Pane.addSubview(imageView_Pane)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Pane = view.bounds.width
        let imageRatio_Pane = image_Pane.size.height / image_Pane.size.width
        let displayHeight_Pane = screenWidth_Pane * imageRatio_Pane
        
        imageView_Pane.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Pane)
            make.height.equalTo(displayHeight_Pane)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Pane() {
        guard let scrollView_Pane = scrollView_Pane else { return }
        
        let textLabel_Pane = UILabel()
        textLabel_Pane.text = content_Pane
        textLabel_Pane.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Pane.textColor = .black
        textLabel_Pane.numberOfLines = 0
        scrollView_Pane.addSubview(textLabel_Pane)
        
        textLabel_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Pane() {
        // push 场景：出栈；modal 场景：关闭当前导航控制器
        if let nav_Pane = navigationController, nav_Pane.viewControllers.count > 1 {
            nav_Pane.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Pane: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Pane?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Pane?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Pane?.stopAnimating()
        Utils_Pane.showError_Pane(message_Pane: "Failed to load content")
    }
}
