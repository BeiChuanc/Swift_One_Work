import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Lumia {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Lumia {
        case terms_Lumia       // 服务条款
        case privacy_Lumia     // 隐私政策
        case eula_Lumia        // 最终用户许可协议
        case custom_Lumia(String) // 自定义协议
        
        /// 获取协议标题
        var title_Lumia: String {
            switch self {
            case .terms_Lumia:
                return "Terms of Service"
            case .privacy_Lumia:
                return "Privacy Policy"
            case .eula_Lumia:
                return "EULA"
            case .custom_Lumia(let title_Lumia):
                return title_Lumia
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Lumia {
        /// 普通文本颜色
        var textColor_Lumia: UIColor
        /// 链接文本颜色
        var linkColor_Lumia: UIColor
        /// 字体大小
        var fontSize_Lumia: CGFloat
        /// 字体粗细
        var fontWeight_Lumia: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Lumia: Bool
        /// 前缀文本
        var prefixText_Lumia: String
        /// 分隔符文本
        var separatorText_Lumia: String
        
        /// 默认初始化
        init(
            textColor_Lumia: UIColor = UIColor.gray,
            linkColor_Lumia: UIColor = UIColor.black,
            fontSize_Lumia: CGFloat = 12,
            fontWeight_Lumia: UIFont.Weight = .regular,
            hasUnderline_Lumia: Bool = true,
            prefixText_Lumia: String = "By continuing you agree with ",
            separatorText_Lumia: String = " & "
        ) {
            self.textColor_Lumia = textColor_Lumia
            self.linkColor_Lumia = linkColor_Lumia
            self.fontSize_Lumia = fontSize_Lumia
            self.fontWeight_Lumia = fontWeight_Lumia
            self.hasUnderline_Lumia = hasUnderline_Lumia
            self.prefixText_Lumia = prefixText_Lumia
            self.separatorText_Lumia = separatorText_Lumia
        }
        
        /// 浅色主题配置
        static func light_Lumia() -> ProtocolTextConfig_Lumia {
            return ProtocolTextConfig_Lumia(
                textColor_Lumia: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Lumia: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Lumia() -> ProtocolTextConfig_Lumia {
            return ProtocolTextConfig_Lumia(
                textColor_Lumia: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Lumia: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Lumia: 协议类型
    ///   - content_Lumia: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Lumia: 当前视图控制器
    static func showProtocol_Lumia(
        type_Lumia: ProtocolType_Lumia,
        content_Lumia: String,
        from viewController_Lumia: UIViewController
    ) {
        let protocolVC_Lumia = ProtocolViewController_Lumia(
            type_Lumia: type_Lumia,
            content_Lumia: content_Lumia
        )
        viewController_Lumia.navigationController?.pushViewController(
            protocolVC_Lumia,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Lumia: 第一个协议类型
    ///   - firstContent_Lumia: 第一个协议内容
    ///   - secondProtocol_Lumia: 第二个协议类型
    ///   - secondContent_Lumia: 第二个协议内容
    ///   - config_Lumia: 文本配置
    ///   - viewController_Lumia: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Lumia(
        firstProtocol_Lumia: ProtocolType_Lumia = .terms_Lumia,
        firstContent_Lumia: String,
        secondProtocol_Lumia: ProtocolType_Lumia = .privacy_Lumia,
        secondContent_Lumia: String,
        config_Lumia: ProtocolTextConfig_Lumia = .light_Lumia(),
        from viewController_Lumia: UIViewController
    ) -> UILabel {
        let label_Lumia = UILabel()
        label_Lumia.numberOfLines = 0
        label_Lumia.textAlignment = .center
        label_Lumia.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Lumia = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Lumia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Lumia.fontSize_Lumia, weight: config_Lumia.fontWeight_Lumia),
            .foregroundColor: config_Lumia.textColor_Lumia
        ]
        attributedString_Lumia.append(NSAttributedString(
            string: config_Lumia.prefixText_Lumia,
            attributes: prefixAttributes_Lumia
        ))
        
        // 第一个协议链接
        var linkAttributes_Lumia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Lumia.fontSize_Lumia, weight: config_Lumia.fontWeight_Lumia),
            .foregroundColor: config_Lumia.linkColor_Lumia
        ]
        if config_Lumia.hasUnderline_Lumia {
            linkAttributes_Lumia[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Lumia[.underlineColor] = config_Lumia.linkColor_Lumia
        }
        
        let firstProtocolString_Lumia = NSAttributedString(
            string: firstProtocol_Lumia.title_Lumia,
            attributes: linkAttributes_Lumia
        )
        attributedString_Lumia.append(firstProtocolString_Lumia)
        
        // 分隔符
        attributedString_Lumia.append(NSAttributedString(
            string: config_Lumia.separatorText_Lumia,
            attributes: prefixAttributes_Lumia
        ))
        
        // 第二个协议链接
        let secondProtocolString_Lumia = NSAttributedString(
            string: secondProtocol_Lumia.title_Lumia + ".",
            attributes: linkAttributes_Lumia
        )
        attributedString_Lumia.append(secondProtocolString_Lumia)
        
        label_Lumia.attributedText = attributedString_Lumia
        
        // 添加点击手势
        let tapGesture_Lumia = ProtocolTextTapGesture_Lumia(
            firstProtocol_Lumia: firstProtocol_Lumia,
            firstContent_Lumia: firstContent_Lumia,
            secondProtocol_Lumia: secondProtocol_Lumia,
            secondContent_Lumia: secondContent_Lumia,
            prefixLength_Lumia: config_Lumia.prefixText_Lumia.count,
            firstTitleLength_Lumia: firstProtocol_Lumia.title_Lumia.count,
            separatorLength_Lumia: config_Lumia.separatorText_Lumia.count,
            secondTitleLength_Lumia: secondProtocol_Lumia.title_Lumia.count + 1,
            viewController_Lumia: viewController_Lumia
        )
        label_Lumia.addGestureRecognizer(tapGesture_Lumia)
        
        return label_Lumia
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Lumia: UITapGestureRecognizer {
    
    private let firstProtocol_Lumia: ProtocolHelper_Lumia.ProtocolType_Lumia
    private let firstContent_Lumia: String
    private let secondProtocol_Lumia: ProtocolHelper_Lumia.ProtocolType_Lumia
    private let secondContent_Lumia: String
    private let prefixLength_Lumia: Int
    private let firstTitleLength_Lumia: Int
    private let separatorLength_Lumia: Int
    private let secondTitleLength_Lumia: Int
    private weak var viewController_Lumia: UIViewController?
    
    init(
        firstProtocol_Lumia: ProtocolHelper_Lumia.ProtocolType_Lumia,
        firstContent_Lumia: String,
        secondProtocol_Lumia: ProtocolHelper_Lumia.ProtocolType_Lumia,
        secondContent_Lumia: String,
        prefixLength_Lumia: Int,
        firstTitleLength_Lumia: Int,
        separatorLength_Lumia: Int,
        secondTitleLength_Lumia: Int,
        viewController_Lumia: UIViewController
    ) {
        self.firstProtocol_Lumia = firstProtocol_Lumia
        self.firstContent_Lumia = firstContent_Lumia
        self.secondProtocol_Lumia = secondProtocol_Lumia
        self.secondContent_Lumia = secondContent_Lumia
        self.prefixLength_Lumia = prefixLength_Lumia
        self.firstTitleLength_Lumia = firstTitleLength_Lumia
        self.separatorLength_Lumia = separatorLength_Lumia
        self.secondTitleLength_Lumia = secondTitleLength_Lumia
        self.viewController_Lumia = viewController_Lumia
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Lumia(_:)))
    }
    
    @objc private func handleTap_Lumia(_ gesture: UITapGestureRecognizer) {
        guard let label_Lumia = gesture.view as? UILabel,
              let attributedText_Lumia = label_Lumia.attributedText,
              let viewController_Lumia = viewController_Lumia else { return }
        
        // 计算点击位置
        let location_Lumia = gesture.location(in: label_Lumia)
        
        // 创建文本容器和布局管理器
        let textStorage_Lumia = NSTextStorage(attributedString: attributedText_Lumia)
        let layoutManager_Lumia = NSLayoutManager()
        let textContainer_Lumia = NSTextContainer(size: label_Lumia.bounds.size)
        
        layoutManager_Lumia.addTextContainer(textContainer_Lumia)
        textStorage_Lumia.addLayoutManager(layoutManager_Lumia)
        
        textContainer_Lumia.lineFragmentPadding = 0
        textContainer_Lumia.maximumNumberOfLines = label_Lumia.numberOfLines
        textContainer_Lumia.lineBreakMode = label_Lumia.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Lumia = layoutManager_Lumia.characterIndex(
            for: location_Lumia,
            in: textContainer_Lumia,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Lumia = prefixLength_Lumia
        let firstLinkEnd_Lumia = firstLinkStart_Lumia + firstTitleLength_Lumia
        
        let secondLinkStart_Lumia = firstLinkEnd_Lumia + separatorLength_Lumia
        let secondLinkEnd_Lumia = secondLinkStart_Lumia + secondTitleLength_Lumia
        
        if characterIndex_Lumia >= firstLinkStart_Lumia && characterIndex_Lumia < firstLinkEnd_Lumia {
            // 点击第一个协议
            ProtocolHelper_Lumia.showProtocol_Lumia(
                type_Lumia: firstProtocol_Lumia,
                content_Lumia: firstContent_Lumia,
                from: viewController_Lumia
            )
        } else if characterIndex_Lumia >= secondLinkStart_Lumia && characterIndex_Lumia < secondLinkEnd_Lumia {
            // 点击第二个协议
            ProtocolHelper_Lumia.showProtocol_Lumia(
                type_Lumia: secondProtocol_Lumia,
                content_Lumia: secondContent_Lumia,
                from: viewController_Lumia
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Lumia: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Lumia: ProtocolHelper_Lumia.ProtocolType_Lumia
    private let content_Lumia: String
    
    private var webView_Lumia: WKWebView?
    private var scrollView_Lumia: UIScrollView?
    private var activityIndicator_Lumia: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Lumia: Bool {
        return content_Lumia.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Lumia: Bool {
        return content_Lumia.hasSuffix(".png") || 
               content_Lumia.hasSuffix(".jpg") || 
               content_Lumia.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Lumia: ProtocolHelper_Lumia.ProtocolType_Lumia, content_Lumia: String) {
        self.protocolType_Lumia = type_Lumia
        self.content_Lumia = content_Lumia
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        loadContent_Lumia()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Lumia() {
        view.backgroundColor = .white
        title = protocolType_Lumia.title_Lumia
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Lumia)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Lumia {
            setupWebView_Lumia()
            setupActivityIndicator_Lumia()
        } else {
            setupScrollView_Lumia()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Lumia() {
        let webView_Lumia = WKWebView()
        webView_Lumia.navigationDelegate = self
        view.addSubview(webView_Lumia)
        
        webView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Lumia = webView_Lumia
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Lumia() {
        let scrollView_Lumia = UIScrollView()
        scrollView_Lumia.showsVerticalScrollIndicator = true
        scrollView_Lumia.alwaysBounceVertical = true
        view.addSubview(scrollView_Lumia)
        
        scrollView_Lumia.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Lumia = scrollView_Lumia
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Lumia() {
        let indicator_Lumia = UIActivityIndicatorView(style: .large)
        indicator_Lumia.color = .gray
        view.addSubview(indicator_Lumia)
        
        indicator_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Lumia = indicator_Lumia
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Lumia() {
        if isRemoteURL_Lumia {
            loadWebContent_Lumia()
        } else if isImage_Lumia {
            loadImageContent_Lumia()
        } else {
            loadTextContent_Lumia()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Lumia() {
        guard let url_Lumia = URL(string: content_Lumia) else { return }
        
        activityIndicator_Lumia?.startAnimating()
        
        let request_Lumia = URLRequest(url: url_Lumia)
        webView_Lumia?.load(request_Lumia)
    }
    
    /// 加载图片内容
    private func loadImageContent_Lumia() {
        guard let scrollView_Lumia = scrollView_Lumia,
              let image_Lumia = UIImage(named: content_Lumia) else { return }
        
        let imageView_Lumia = UIImageView()
        imageView_Lumia.contentMode = .scaleAspectFit
        imageView_Lumia.image = image_Lumia
        scrollView_Lumia.addSubview(imageView_Lumia)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Lumia = view.bounds.width
        let imageRatio_Lumia = image_Lumia.size.height / image_Lumia.size.width
        let displayHeight_Lumia = screenWidth_Lumia * imageRatio_Lumia
        
        imageView_Lumia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Lumia)
            make.height.equalTo(displayHeight_Lumia)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Lumia() {
        guard let scrollView_Lumia = scrollView_Lumia else { return }
        
        let textLabel_Lumia = UILabel()
        textLabel_Lumia.text = content_Lumia
        textLabel_Lumia.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Lumia.textColor = .black
        textLabel_Lumia.numberOfLines = 0
        scrollView_Lumia.addSubview(textLabel_Lumia)
        
        textLabel_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Lumia() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Lumia: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Lumia?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Lumia?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Lumia?.stopAnimating()
        Utils_Lumia.showError_Lumia(message_Lumia: "Failed to load content")
    }
}
