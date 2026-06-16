import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Retrs {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Retrs {
        case terms_Retrs       // 服务条款
        case privacy_Retrs     // 隐私政策
        case eula_Retrs        // 最终用户许可协议
        case custom_Retrs(String) // 自定义协议
        
        /// 获取协议标题
        var title_Retrs: String {
            switch self {
            case .terms_Retrs:
                return "Terms of Service"
            case .privacy_Retrs:
                return "Privacy Policy"
            case .eula_Retrs:
                return "EULA"
            case .custom_Retrs(let title_Retrs):
                return title_Retrs
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Retrs {
        /// 普通文本颜色
        var textColor_Retrs: UIColor
        /// 链接文本颜色
        var linkColor_Retrs: UIColor
        /// 字体大小
        var fontSize_Retrs: CGFloat
        /// 字体粗细
        var fontWeight_Retrs: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Retrs: Bool
        /// 前缀文本
        var prefixText_Retrs: String
        /// 分隔符文本
        var separatorText_Retrs: String
        
        /// 默认初始化
        init(
            textColor_Retrs: UIColor = UIColor.gray,
            linkColor_Retrs: UIColor = UIColor.black,
            fontSize_Retrs: CGFloat = 12,
            fontWeight_Retrs: UIFont.Weight = .regular,
            hasUnderline_Retrs: Bool = true,
            prefixText_Retrs: String = "By continuing you agree with ",
            separatorText_Retrs: String = " & "
        ) {
            self.textColor_Retrs = textColor_Retrs
            self.linkColor_Retrs = linkColor_Retrs
            self.fontSize_Retrs = fontSize_Retrs
            self.fontWeight_Retrs = fontWeight_Retrs
            self.hasUnderline_Retrs = hasUnderline_Retrs
            self.prefixText_Retrs = prefixText_Retrs
            self.separatorText_Retrs = separatorText_Retrs
        }
        
        /// 浅色主题配置
        static func light_Retrs() -> ProtocolTextConfig_Retrs {
            return ProtocolTextConfig_Retrs(
                textColor_Retrs: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Retrs: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Retrs() -> ProtocolTextConfig_Retrs {
            return ProtocolTextConfig_Retrs(
                textColor_Retrs: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Retrs: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Retrs: 协议类型
    ///   - content_Retrs: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Retrs: 当前视图控制器
    static func showProtocol_Retrs(
        type_Retrs: ProtocolType_Retrs,
        content_Retrs: String,
        from viewController_Retrs: UIViewController
    ) {
        let protocolVC_Retrs = ProtocolViewController_Retrs(
            type_Retrs: type_Retrs,
            content_Retrs: content_Retrs
        )
        viewController_Retrs.navigationController?.pushViewController(
            protocolVC_Retrs,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Retrs: 第一个协议类型
    ///   - firstContent_Retrs: 第一个协议内容
    ///   - secondProtocol_Retrs: 第二个协议类型
    ///   - secondContent_Retrs: 第二个协议内容
    ///   - config_Retrs: 文本配置
    ///   - viewController_Retrs: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Retrs(
        firstProtocol_Retrs: ProtocolType_Retrs = .terms_Retrs,
        firstContent_Retrs: String,
        secondProtocol_Retrs: ProtocolType_Retrs = .privacy_Retrs,
        secondContent_Retrs: String,
        config_Retrs: ProtocolTextConfig_Retrs = .light_Retrs(),
        from viewController_Retrs: UIViewController
    ) -> UILabel {
        let label_Retrs = UILabel()
        label_Retrs.numberOfLines = 0
        label_Retrs.textAlignment = .center
        label_Retrs.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Retrs = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Retrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Retrs.fontSize_Retrs, weight: config_Retrs.fontWeight_Retrs),
            .foregroundColor: config_Retrs.textColor_Retrs
        ]
        attributedString_Retrs.append(NSAttributedString(
            string: config_Retrs.prefixText_Retrs,
            attributes: prefixAttributes_Retrs
        ))
        
        // 第一个协议链接
        var linkAttributes_Retrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Retrs.fontSize_Retrs, weight: config_Retrs.fontWeight_Retrs),
            .foregroundColor: config_Retrs.linkColor_Retrs
        ]
        if config_Retrs.hasUnderline_Retrs {
            linkAttributes_Retrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Retrs[.underlineColor] = config_Retrs.linkColor_Retrs
        }
        
        let firstProtocolString_Retrs = NSAttributedString(
            string: firstProtocol_Retrs.title_Retrs,
            attributes: linkAttributes_Retrs
        )
        attributedString_Retrs.append(firstProtocolString_Retrs)
        
        // 分隔符
        attributedString_Retrs.append(NSAttributedString(
            string: config_Retrs.separatorText_Retrs,
            attributes: prefixAttributes_Retrs
        ))
        
        // 第二个协议链接
        let secondProtocolString_Retrs = NSAttributedString(
            string: secondProtocol_Retrs.title_Retrs + ".",
            attributes: linkAttributes_Retrs
        )
        attributedString_Retrs.append(secondProtocolString_Retrs)
        
        label_Retrs.attributedText = attributedString_Retrs
        
        // 添加点击手势
        let tapGesture_Retrs = ProtocolTextTapGesture_Retrs(
            firstProtocol_Retrs: firstProtocol_Retrs,
            firstContent_Retrs: firstContent_Retrs,
            secondProtocol_Retrs: secondProtocol_Retrs,
            secondContent_Retrs: secondContent_Retrs,
            prefixLength_Retrs: config_Retrs.prefixText_Retrs.count,
            firstTitleLength_Retrs: firstProtocol_Retrs.title_Retrs.count,
            separatorLength_Retrs: config_Retrs.separatorText_Retrs.count,
            secondTitleLength_Retrs: secondProtocol_Retrs.title_Retrs.count + 1,
            viewController_Retrs: viewController_Retrs
        )
        label_Retrs.addGestureRecognizer(tapGesture_Retrs)
        
        return label_Retrs
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Retrs: UITapGestureRecognizer {
    
    private let firstProtocol_Retrs: ProtocolHelper_Retrs.ProtocolType_Retrs
    private let firstContent_Retrs: String
    private let secondProtocol_Retrs: ProtocolHelper_Retrs.ProtocolType_Retrs
    private let secondContent_Retrs: String
    private let prefixLength_Retrs: Int
    private let firstTitleLength_Retrs: Int
    private let separatorLength_Retrs: Int
    private let secondTitleLength_Retrs: Int
    private weak var viewController_Retrs: UIViewController?
    
    init(
        firstProtocol_Retrs: ProtocolHelper_Retrs.ProtocolType_Retrs,
        firstContent_Retrs: String,
        secondProtocol_Retrs: ProtocolHelper_Retrs.ProtocolType_Retrs,
        secondContent_Retrs: String,
        prefixLength_Retrs: Int,
        firstTitleLength_Retrs: Int,
        separatorLength_Retrs: Int,
        secondTitleLength_Retrs: Int,
        viewController_Retrs: UIViewController
    ) {
        self.firstProtocol_Retrs = firstProtocol_Retrs
        self.firstContent_Retrs = firstContent_Retrs
        self.secondProtocol_Retrs = secondProtocol_Retrs
        self.secondContent_Retrs = secondContent_Retrs
        self.prefixLength_Retrs = prefixLength_Retrs
        self.firstTitleLength_Retrs = firstTitleLength_Retrs
        self.separatorLength_Retrs = separatorLength_Retrs
        self.secondTitleLength_Retrs = secondTitleLength_Retrs
        self.viewController_Retrs = viewController_Retrs
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Retrs(_:)))
    }
    
    @objc private func handleTap_Retrs(_ gesture: UITapGestureRecognizer) {
        guard let label_Retrs = gesture.view as? UILabel,
              let attributedText_Retrs = label_Retrs.attributedText,
              let viewController_Retrs = viewController_Retrs else { return }
        
        // 计算点击位置
        let location_Retrs = gesture.location(in: label_Retrs)
        
        // 创建文本容器和布局管理器
        let textStorage_Retrs = NSTextStorage(attributedString: attributedText_Retrs)
        let layoutManager_Retrs = NSLayoutManager()
        let textContainer_Retrs = NSTextContainer(size: label_Retrs.bounds.size)
        
        layoutManager_Retrs.addTextContainer(textContainer_Retrs)
        textStorage_Retrs.addLayoutManager(layoutManager_Retrs)
        
        textContainer_Retrs.lineFragmentPadding = 0
        textContainer_Retrs.maximumNumberOfLines = label_Retrs.numberOfLines
        textContainer_Retrs.lineBreakMode = label_Retrs.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Retrs = layoutManager_Retrs.characterIndex(
            for: location_Retrs,
            in: textContainer_Retrs,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Retrs = prefixLength_Retrs
        let firstLinkEnd_Retrs = firstLinkStart_Retrs + firstTitleLength_Retrs
        
        let secondLinkStart_Retrs = firstLinkEnd_Retrs + separatorLength_Retrs
        let secondLinkEnd_Retrs = secondLinkStart_Retrs + secondTitleLength_Retrs
        
        if characterIndex_Retrs >= firstLinkStart_Retrs && characterIndex_Retrs < firstLinkEnd_Retrs {
            // 点击第一个协议
            ProtocolHelper_Retrs.showProtocol_Retrs(
                type_Retrs: firstProtocol_Retrs,
                content_Retrs: firstContent_Retrs,
                from: viewController_Retrs
            )
        } else if characterIndex_Retrs >= secondLinkStart_Retrs && characterIndex_Retrs < secondLinkEnd_Retrs {
            // 点击第二个协议
            ProtocolHelper_Retrs.showProtocol_Retrs(
                type_Retrs: secondProtocol_Retrs,
                content_Retrs: secondContent_Retrs,
                from: viewController_Retrs
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Retrs: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Retrs: ProtocolHelper_Retrs.ProtocolType_Retrs
    private let content_Retrs: String
    
    private var webView_Retrs: WKWebView?
    private var scrollView_Retrs: UIScrollView?
    private var activityIndicator_Retrs: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Retrs: Bool {
        return content_Retrs.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Retrs: Bool {
        return content_Retrs.hasSuffix(".png") || 
               content_Retrs.hasSuffix(".jpg") || 
               content_Retrs.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Retrs: ProtocolHelper_Retrs.ProtocolType_Retrs, content_Retrs: String) {
        self.protocolType_Retrs = type_Retrs
        self.content_Retrs = content_Retrs
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Retrs()
        loadContent_Retrs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Retrs() {
        view.backgroundColor = .white
        title = protocolType_Retrs.title_Retrs
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Retrs)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Retrs {
            setupWebView_Retrs()
            setupActivityIndicator_Retrs()
        } else {
            setupScrollView_Retrs()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Retrs() {
        let webView_Retrs = WKWebView()
        webView_Retrs.navigationDelegate = self
        view.addSubview(webView_Retrs)
        
        webView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Retrs = webView_Retrs
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Retrs() {
        let scrollView_Retrs = UIScrollView()
        scrollView_Retrs.showsVerticalScrollIndicator = true
        scrollView_Retrs.alwaysBounceVertical = true
        view.addSubview(scrollView_Retrs)
        
        scrollView_Retrs.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Retrs = scrollView_Retrs
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Retrs() {
        let indicator_Retrs = UIActivityIndicatorView(style: .large)
        indicator_Retrs.color = .gray
        view.addSubview(indicator_Retrs)
        
        indicator_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Retrs = indicator_Retrs
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Retrs() {
        if isRemoteURL_Retrs {
            loadWebContent_Retrs()
        } else if isImage_Retrs {
            loadImageContent_Retrs()
        } else {
            loadTextContent_Retrs()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Retrs() {
        guard let url_Retrs = URL(string: content_Retrs) else { return }
        
        activityIndicator_Retrs?.startAnimating()
        
        let request_Retrs = URLRequest(url: url_Retrs)
        webView_Retrs?.load(request_Retrs)
    }
    
    /// 加载图片内容
    private func loadImageContent_Retrs() {
        guard let scrollView_Retrs = scrollView_Retrs,
              let image_Retrs = UIImage(named: content_Retrs) else { return }
        
        let imageView_Retrs = UIImageView()
        imageView_Retrs.contentMode = .scaleAspectFit
        imageView_Retrs.image = image_Retrs
        scrollView_Retrs.addSubview(imageView_Retrs)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Retrs = view.bounds.width
        let imageRatio_Retrs = image_Retrs.size.height / image_Retrs.size.width
        let displayHeight_Retrs = screenWidth_Retrs * imageRatio_Retrs
        
        imageView_Retrs.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Retrs)
            make.height.equalTo(displayHeight_Retrs)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Retrs() {
        guard let scrollView_Retrs = scrollView_Retrs else { return }
        
        let textLabel_Retrs = UILabel()
        textLabel_Retrs.text = content_Retrs
        textLabel_Retrs.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Retrs.textColor = .black
        textLabel_Retrs.numberOfLines = 0
        scrollView_Retrs.addSubview(textLabel_Retrs)
        
        textLabel_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Retrs() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Retrs: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Retrs?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Retrs?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Retrs?.stopAnimating()
        Utils_Retrs.showError_Retrs(message_Retrs: "Failed to load content")
    }
}
