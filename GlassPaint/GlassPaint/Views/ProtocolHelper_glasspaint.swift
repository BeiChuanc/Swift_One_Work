import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Glasspaint {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Glasspaint {
        case terms_Glasspaint       // 服务条款
        case privacy_Glasspaint     // 隐私政策
        case eula_Glasspaint        // 最终用户许可协议
        case custom_Glasspaint(String) // 自定义协议
        
        /// 获取协议标题
        var title_Glasspaint: String {
            switch self {
            case .terms_Glasspaint:
                return "Terms of Service"
            case .privacy_Glasspaint:
                return "Privacy Policy"
            case .eula_Glasspaint:
                return "EULA"
            case .custom_Glasspaint(let title_Glasspaint):
                return title_Glasspaint
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Glasspaint {
        /// 普通文本颜色
        var textColor_Glasspaint: UIColor
        /// 链接文本颜色
        var linkColor_Glasspaint: UIColor
        /// 字体大小
        var fontSize_Glasspaint: CGFloat
        /// 字体粗细
        var fontWeight_Glasspaint: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Glasspaint: Bool
        /// 前缀文本
        var prefixText_Glasspaint: String
        /// 分隔符文本
        var separatorText_Glasspaint: String
        
        /// 默认初始化
        init(
            textColor_Glasspaint: UIColor = UIColor.gray,
            linkColor_Glasspaint: UIColor = UIColor.black,
            fontSize_Glasspaint: CGFloat = 12,
            fontWeight_Glasspaint: UIFont.Weight = .regular,
            hasUnderline_Glasspaint: Bool = true,
            prefixText_Glasspaint: String = "By continuing you agree with ",
            separatorText_Glasspaint: String = " & "
        ) {
            self.textColor_Glasspaint = textColor_Glasspaint
            self.linkColor_Glasspaint = linkColor_Glasspaint
            self.fontSize_Glasspaint = fontSize_Glasspaint
            self.fontWeight_Glasspaint = fontWeight_Glasspaint
            self.hasUnderline_Glasspaint = hasUnderline_Glasspaint
            self.prefixText_Glasspaint = prefixText_Glasspaint
            self.separatorText_Glasspaint = separatorText_Glasspaint
        }
        
        /// 浅色主题配置
        static func light_Glasspaint() -> ProtocolTextConfig_Glasspaint {
            return ProtocolTextConfig_Glasspaint(
                textColor_Glasspaint: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Glasspaint: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Glasspaint() -> ProtocolTextConfig_Glasspaint {
            return ProtocolTextConfig_Glasspaint(
                textColor_Glasspaint: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Glasspaint: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Glasspaint: 协议类型
    ///   - content_Glasspaint: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Glasspaint: 当前视图控制器
    static func showProtocol_Glasspaint(
        type_Glasspaint: ProtocolType_Glasspaint,
        content_Glasspaint: String,
        from viewController_Glasspaint: UIViewController
    ) {
        let protocolVC_Glasspaint = ProtocolViewController_Glasspaint(
            type_Glasspaint: type_Glasspaint,
            content_Glasspaint: content_Glasspaint
        )
        viewController_Glasspaint.navigationController?.pushViewController(
            protocolVC_Glasspaint,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Glasspaint: 第一个协议类型
    ///   - firstContent_Glasspaint: 第一个协议内容
    ///   - secondProtocol_Glasspaint: 第二个协议类型
    ///   - secondContent_Glasspaint: 第二个协议内容
    ///   - config_Glasspaint: 文本配置
    ///   - viewController_Glasspaint: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Glasspaint(
        firstProtocol_Glasspaint: ProtocolType_Glasspaint = .terms_Glasspaint,
        firstContent_Glasspaint: String,
        secondProtocol_Glasspaint: ProtocolType_Glasspaint = .privacy_Glasspaint,
        secondContent_Glasspaint: String,
        config_Glasspaint: ProtocolTextConfig_Glasspaint = .light_Glasspaint(),
        from viewController_Glasspaint: UIViewController
    ) -> UILabel {
        let label_Glasspaint = UILabel()
        label_Glasspaint.numberOfLines = 0
        label_Glasspaint.textAlignment = .center
        label_Glasspaint.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Glasspaint = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Glasspaint: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Glasspaint.fontSize_Glasspaint, weight: config_Glasspaint.fontWeight_Glasspaint),
            .foregroundColor: config_Glasspaint.textColor_Glasspaint
        ]
        attributedString_Glasspaint.append(NSAttributedString(
            string: config_Glasspaint.prefixText_Glasspaint,
            attributes: prefixAttributes_Glasspaint
        ))
        
        // 第一个协议链接
        var linkAttributes_Glasspaint: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Glasspaint.fontSize_Glasspaint, weight: config_Glasspaint.fontWeight_Glasspaint),
            .foregroundColor: config_Glasspaint.linkColor_Glasspaint
        ]
        if config_Glasspaint.hasUnderline_Glasspaint {
            linkAttributes_Glasspaint[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Glasspaint[.underlineColor] = config_Glasspaint.linkColor_Glasspaint
        }
        
        let firstProtocolString_Glasspaint = NSAttributedString(
            string: firstProtocol_Glasspaint.title_Glasspaint,
            attributes: linkAttributes_Glasspaint
        )
        attributedString_Glasspaint.append(firstProtocolString_Glasspaint)
        
        // 分隔符
        attributedString_Glasspaint.append(NSAttributedString(
            string: config_Glasspaint.separatorText_Glasspaint,
            attributes: prefixAttributes_Glasspaint
        ))
        
        // 第二个协议链接
        let secondProtocolString_Glasspaint = NSAttributedString(
            string: secondProtocol_Glasspaint.title_Glasspaint + ".",
            attributes: linkAttributes_Glasspaint
        )
        attributedString_Glasspaint.append(secondProtocolString_Glasspaint)
        
        label_Glasspaint.attributedText = attributedString_Glasspaint
        
        // 添加点击手势
        let tapGesture_Glasspaint = ProtocolTextTapGesture_Glasspaint(
            firstProtocol_Glasspaint: firstProtocol_Glasspaint,
            firstContent_Glasspaint: firstContent_Glasspaint,
            secondProtocol_Glasspaint: secondProtocol_Glasspaint,
            secondContent_Glasspaint: secondContent_Glasspaint,
            prefixLength_Glasspaint: config_Glasspaint.prefixText_Glasspaint.count,
            firstTitleLength_Glasspaint: firstProtocol_Glasspaint.title_Glasspaint.count,
            separatorLength_Glasspaint: config_Glasspaint.separatorText_Glasspaint.count,
            secondTitleLength_Glasspaint: secondProtocol_Glasspaint.title_Glasspaint.count + 1,
            viewController_Glasspaint: viewController_Glasspaint
        )
        label_Glasspaint.addGestureRecognizer(tapGesture_Glasspaint)
        
        return label_Glasspaint
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Glasspaint: UITapGestureRecognizer {
    
    private let firstProtocol_Glasspaint: ProtocolHelper_Glasspaint.ProtocolType_Glasspaint
    private let firstContent_Glasspaint: String
    private let secondProtocol_Glasspaint: ProtocolHelper_Glasspaint.ProtocolType_Glasspaint
    private let secondContent_Glasspaint: String
    private let prefixLength_Glasspaint: Int
    private let firstTitleLength_Glasspaint: Int
    private let separatorLength_Glasspaint: Int
    private let secondTitleLength_Glasspaint: Int
    private weak var viewController_Glasspaint: UIViewController?
    
    init(
        firstProtocol_Glasspaint: ProtocolHelper_Glasspaint.ProtocolType_Glasspaint,
        firstContent_Glasspaint: String,
        secondProtocol_Glasspaint: ProtocolHelper_Glasspaint.ProtocolType_Glasspaint,
        secondContent_Glasspaint: String,
        prefixLength_Glasspaint: Int,
        firstTitleLength_Glasspaint: Int,
        separatorLength_Glasspaint: Int,
        secondTitleLength_Glasspaint: Int,
        viewController_Glasspaint: UIViewController
    ) {
        self.firstProtocol_Glasspaint = firstProtocol_Glasspaint
        self.firstContent_Glasspaint = firstContent_Glasspaint
        self.secondProtocol_Glasspaint = secondProtocol_Glasspaint
        self.secondContent_Glasspaint = secondContent_Glasspaint
        self.prefixLength_Glasspaint = prefixLength_Glasspaint
        self.firstTitleLength_Glasspaint = firstTitleLength_Glasspaint
        self.separatorLength_Glasspaint = separatorLength_Glasspaint
        self.secondTitleLength_Glasspaint = secondTitleLength_Glasspaint
        self.viewController_Glasspaint = viewController_Glasspaint
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Glasspaint(_:)))
    }
    
    @objc private func handleTap_Glasspaint(_ gesture: UITapGestureRecognizer) {
        guard let label_Glasspaint = gesture.view as? UILabel,
              let attributedText_Glasspaint = label_Glasspaint.attributedText,
              let viewController_Glasspaint = viewController_Glasspaint else { return }
        
        // 计算点击位置
        let location_Glasspaint = gesture.location(in: label_Glasspaint)
        
        // 创建文本容器和布局管理器
        let textStorage_Glasspaint = NSTextStorage(attributedString: attributedText_Glasspaint)
        let layoutManager_Glasspaint = NSLayoutManager()
        let textContainer_Glasspaint = NSTextContainer(size: label_Glasspaint.bounds.size)
        
        layoutManager_Glasspaint.addTextContainer(textContainer_Glasspaint)
        textStorage_Glasspaint.addLayoutManager(layoutManager_Glasspaint)
        
        textContainer_Glasspaint.lineFragmentPadding = 0
        textContainer_Glasspaint.maximumNumberOfLines = label_Glasspaint.numberOfLines
        textContainer_Glasspaint.lineBreakMode = label_Glasspaint.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Glasspaint = layoutManager_Glasspaint.characterIndex(
            for: location_Glasspaint,
            in: textContainer_Glasspaint,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Glasspaint = prefixLength_Glasspaint
        let firstLinkEnd_Glasspaint = firstLinkStart_Glasspaint + firstTitleLength_Glasspaint
        
        let secondLinkStart_Glasspaint = firstLinkEnd_Glasspaint + separatorLength_Glasspaint
        let secondLinkEnd_Glasspaint = secondLinkStart_Glasspaint + secondTitleLength_Glasspaint
        
        if characterIndex_Glasspaint >= firstLinkStart_Glasspaint && characterIndex_Glasspaint < firstLinkEnd_Glasspaint {
            // 点击第一个协议
            ProtocolHelper_Glasspaint.showProtocol_Glasspaint(
                type_Glasspaint: firstProtocol_Glasspaint,
                content_Glasspaint: firstContent_Glasspaint,
                from: viewController_Glasspaint
            )
        } else if characterIndex_Glasspaint >= secondLinkStart_Glasspaint && characterIndex_Glasspaint < secondLinkEnd_Glasspaint {
            // 点击第二个协议
            ProtocolHelper_Glasspaint.showProtocol_Glasspaint(
                type_Glasspaint: secondProtocol_Glasspaint,
                content_Glasspaint: secondContent_Glasspaint,
                from: viewController_Glasspaint
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Glasspaint: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Glasspaint: ProtocolHelper_Glasspaint.ProtocolType_Glasspaint
    private let content_Glasspaint: String
    
    private var webView_Glasspaint: WKWebView?
    private var scrollView_Glasspaint: UIScrollView?
    private var activityIndicator_Glasspaint: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Glasspaint: Bool {
        return content_Glasspaint.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Glasspaint: Bool {
        return content_Glasspaint.hasSuffix(".png") || 
               content_Glasspaint.hasSuffix(".jpg") || 
               content_Glasspaint.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Glasspaint: ProtocolHelper_Glasspaint.ProtocolType_Glasspaint, content_Glasspaint: String) {
        self.protocolType_Glasspaint = type_Glasspaint
        self.content_Glasspaint = content_Glasspaint
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        loadContent_Glasspaint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Glasspaint() {
        view.backgroundColor = .white
        title = protocolType_Glasspaint.title_Glasspaint
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Glasspaint)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Glasspaint {
            setupWebView_Glasspaint()
            setupActivityIndicator_Glasspaint()
        } else {
            setupScrollView_Glasspaint()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Glasspaint() {
        let webView_Glasspaint = WKWebView()
        webView_Glasspaint.navigationDelegate = self
        view.addSubview(webView_Glasspaint)
        
        webView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Glasspaint = webView_Glasspaint
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Glasspaint() {
        let scrollView_Glasspaint = UIScrollView()
        scrollView_Glasspaint.showsVerticalScrollIndicator = true
        scrollView_Glasspaint.alwaysBounceVertical = true
        view.addSubview(scrollView_Glasspaint)
        
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Glasspaint = scrollView_Glasspaint
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Glasspaint() {
        let indicator_Glasspaint = UIActivityIndicatorView(style: .large)
        indicator_Glasspaint.color = .gray
        view.addSubview(indicator_Glasspaint)
        
        indicator_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Glasspaint = indicator_Glasspaint
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Glasspaint() {
        if isRemoteURL_Glasspaint {
            loadWebContent_Glasspaint()
        } else if isImage_Glasspaint {
            loadImageContent_Glasspaint()
        } else {
            loadTextContent_Glasspaint()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Glasspaint() {
        guard let url_Glasspaint = URL(string: content_Glasspaint) else { return }
        
        activityIndicator_Glasspaint?.startAnimating()
        
        let request_Glasspaint = URLRequest(url: url_Glasspaint)
        webView_Glasspaint?.load(request_Glasspaint)
    }
    
    /// 加载图片内容
    private func loadImageContent_Glasspaint() {
        guard let scrollView_Glasspaint = scrollView_Glasspaint,
              let image_Glasspaint = UIImage(named: content_Glasspaint) else { return }
        
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.contentMode = .scaleAspectFit
        imageView_Glasspaint.image = image_Glasspaint
        scrollView_Glasspaint.addSubview(imageView_Glasspaint)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Glasspaint = view.bounds.width
        let imageRatio_Glasspaint = image_Glasspaint.size.height / image_Glasspaint.size.width
        let displayHeight_Glasspaint = screenWidth_Glasspaint * imageRatio_Glasspaint
        
        imageView_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Glasspaint)
            make.height.equalTo(displayHeight_Glasspaint)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Glasspaint() {
        guard let scrollView_Glasspaint = scrollView_Glasspaint else { return }
        
        let textLabel_Glasspaint = UILabel()
        textLabel_Glasspaint.text = content_Glasspaint
        textLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Glasspaint.textColor = .black
        textLabel_Glasspaint.numberOfLines = 0
        scrollView_Glasspaint.addSubview(textLabel_Glasspaint)
        
        textLabel_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Glasspaint() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Glasspaint: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Glasspaint?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Glasspaint?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Glasspaint?.stopAnimating()
        Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Failed to load content")
    }
}
