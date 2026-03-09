import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Moode {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Moode {
        case terms_Moode       // 服务条款
        case privacy_Moode     // 隐私政策
        case eula_Moode        // 最终用户许可协议
        case custom_Moode(String) // 自定义协议
        
        /// 获取协议标题
        var title_Moode: String {
            switch self {
            case .terms_Moode:
                return "Terms of Service"
            case .privacy_Moode:
                return "Privacy Policy"
            case .eula_Moode:
                return "EULA"
            case .custom_Moode(let title_Moode):
                return title_Moode
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Moode {
        /// 普通文本颜色
        var textColor_Moode: UIColor
        /// 链接文本颜色
        var linkColor_Moode: UIColor
        /// 字体大小
        var fontSize_Moode: CGFloat
        /// 字体粗细
        var fontWeight_Moode: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Moode: Bool
        /// 前缀文本
        var prefixText_Moode: String
        /// 分隔符文本
        var separatorText_Moode: String
        
        /// 默认初始化
        init(
            textColor_Moode: UIColor = UIColor.gray,
            linkColor_Moode: UIColor = UIColor.black,
            fontSize_Moode: CGFloat = 12,
            fontWeight_Moode: UIFont.Weight = .regular,
            hasUnderline_Moode: Bool = true,
            prefixText_Moode: String = "By continuing you agree with ",
            separatorText_Moode: String = " & "
        ) {
            self.textColor_Moode = textColor_Moode
            self.linkColor_Moode = linkColor_Moode
            self.fontSize_Moode = fontSize_Moode
            self.fontWeight_Moode = fontWeight_Moode
            self.hasUnderline_Moode = hasUnderline_Moode
            self.prefixText_Moode = prefixText_Moode
            self.separatorText_Moode = separatorText_Moode
        }
        
        /// 浅色主题配置
        static func light_Moode() -> ProtocolTextConfig_Moode {
            return ProtocolTextConfig_Moode(
                textColor_Moode: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Moode: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Moode() -> ProtocolTextConfig_Moode {
            return ProtocolTextConfig_Moode(
                textColor_Moode: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Moode: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Moode: 协议类型
    ///   - content_Moode: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Moode: 当前视图控制器
    static func showProtocol_Moode(
        type_Moode: ProtocolType_Moode,
        content_Moode: String,
        from viewController_Moode: UIViewController
    ) {
        let protocolVC_Moode = ProtocolViewController_Moode(
            type_Moode: type_Moode,
            content_Moode: content_Moode
        )
        viewController_Moode.navigationController?.pushViewController(
            protocolVC_Moode,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Moode: 第一个协议类型
    ///   - firstContent_Moode: 第一个协议内容
    ///   - secondProtocol_Moode: 第二个协议类型
    ///   - secondContent_Moode: 第二个协议内容
    ///   - config_Moode: 文本配置
    ///   - viewController_Moode: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Moode(
        firstProtocol_Moode: ProtocolType_Moode = .terms_Moode,
        firstContent_Moode: String,
        secondProtocol_Moode: ProtocolType_Moode = .privacy_Moode,
        secondContent_Moode: String,
        config_Moode: ProtocolTextConfig_Moode = .light_Moode(),
        from viewController_Moode: UIViewController
    ) -> UILabel {
        let label_Moode = UILabel()
        label_Moode.numberOfLines = 0
        label_Moode.textAlignment = .center
        label_Moode.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Moode = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Moode: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Moode.fontSize_Moode, weight: config_Moode.fontWeight_Moode),
            .foregroundColor: config_Moode.textColor_Moode
        ]
        attributedString_Moode.append(NSAttributedString(
            string: config_Moode.prefixText_Moode,
            attributes: prefixAttributes_Moode
        ))
        
        // 第一个协议链接
        var linkAttributes_Moode: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Moode.fontSize_Moode, weight: config_Moode.fontWeight_Moode),
            .foregroundColor: config_Moode.linkColor_Moode
        ]
        if config_Moode.hasUnderline_Moode {
            linkAttributes_Moode[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Moode[.underlineColor] = config_Moode.linkColor_Moode
        }
        
        let firstProtocolString_Moode = NSAttributedString(
            string: firstProtocol_Moode.title_Moode,
            attributes: linkAttributes_Moode
        )
        attributedString_Moode.append(firstProtocolString_Moode)
        
        // 分隔符
        attributedString_Moode.append(NSAttributedString(
            string: config_Moode.separatorText_Moode,
            attributes: prefixAttributes_Moode
        ))
        
        // 第二个协议链接
        let secondProtocolString_Moode = NSAttributedString(
            string: secondProtocol_Moode.title_Moode + ".",
            attributes: linkAttributes_Moode
        )
        attributedString_Moode.append(secondProtocolString_Moode)
        
        label_Moode.attributedText = attributedString_Moode
        
        // 添加点击手势
        let tapGesture_Moode = ProtocolTextTapGesture_Moode(
            firstProtocol_Moode: firstProtocol_Moode,
            firstContent_Moode: firstContent_Moode,
            secondProtocol_Moode: secondProtocol_Moode,
            secondContent_Moode: secondContent_Moode,
            prefixLength_Moode: config_Moode.prefixText_Moode.count,
            firstTitleLength_Moode: firstProtocol_Moode.title_Moode.count,
            separatorLength_Moode: config_Moode.separatorText_Moode.count,
            secondTitleLength_Moode: secondProtocol_Moode.title_Moode.count + 1,
            viewController_Moode: viewController_Moode
        )
        label_Moode.addGestureRecognizer(tapGesture_Moode)
        
        return label_Moode
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Moode: UITapGestureRecognizer {
    
    private let firstProtocol_Moode: ProtocolHelper_Moode.ProtocolType_Moode
    private let firstContent_Moode: String
    private let secondProtocol_Moode: ProtocolHelper_Moode.ProtocolType_Moode
    private let secondContent_Moode: String
    private let prefixLength_Moode: Int
    private let firstTitleLength_Moode: Int
    private let separatorLength_Moode: Int
    private let secondTitleLength_Moode: Int
    private weak var viewController_Moode: UIViewController?
    
    init(
        firstProtocol_Moode: ProtocolHelper_Moode.ProtocolType_Moode,
        firstContent_Moode: String,
        secondProtocol_Moode: ProtocolHelper_Moode.ProtocolType_Moode,
        secondContent_Moode: String,
        prefixLength_Moode: Int,
        firstTitleLength_Moode: Int,
        separatorLength_Moode: Int,
        secondTitleLength_Moode: Int,
        viewController_Moode: UIViewController
    ) {
        self.firstProtocol_Moode = firstProtocol_Moode
        self.firstContent_Moode = firstContent_Moode
        self.secondProtocol_Moode = secondProtocol_Moode
        self.secondContent_Moode = secondContent_Moode
        self.prefixLength_Moode = prefixLength_Moode
        self.firstTitleLength_Moode = firstTitleLength_Moode
        self.separatorLength_Moode = separatorLength_Moode
        self.secondTitleLength_Moode = secondTitleLength_Moode
        self.viewController_Moode = viewController_Moode
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Moode(_:)))
    }
    
    @objc private func handleTap_Moode(_ gesture: UITapGestureRecognizer) {
        guard let label_Moode = gesture.view as? UILabel,
              let attributedText_Moode = label_Moode.attributedText,
              let viewController_Moode = viewController_Moode else { return }
        
        // 计算点击位置
        let location_Moode = gesture.location(in: label_Moode)
        
        // 创建文本容器和布局管理器
        let textStorage_Moode = NSTextStorage(attributedString: attributedText_Moode)
        let layoutManager_Moode = NSLayoutManager()
        let textContainer_Moode = NSTextContainer(size: label_Moode.bounds.size)
        
        layoutManager_Moode.addTextContainer(textContainer_Moode)
        textStorage_Moode.addLayoutManager(layoutManager_Moode)
        
        textContainer_Moode.lineFragmentPadding = 0
        textContainer_Moode.maximumNumberOfLines = label_Moode.numberOfLines
        textContainer_Moode.lineBreakMode = label_Moode.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Moode = layoutManager_Moode.characterIndex(
            for: location_Moode,
            in: textContainer_Moode,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Moode = prefixLength_Moode
        let firstLinkEnd_Moode = firstLinkStart_Moode + firstTitleLength_Moode
        
        let secondLinkStart_Moode = firstLinkEnd_Moode + separatorLength_Moode
        let secondLinkEnd_Moode = secondLinkStart_Moode + secondTitleLength_Moode
        
        if characterIndex_Moode >= firstLinkStart_Moode && characterIndex_Moode < firstLinkEnd_Moode {
            // 点击第一个协议
            ProtocolHelper_Moode.showProtocol_Moode(
                type_Moode: firstProtocol_Moode,
                content_Moode: firstContent_Moode,
                from: viewController_Moode
            )
        } else if characterIndex_Moode >= secondLinkStart_Moode && characterIndex_Moode < secondLinkEnd_Moode {
            // 点击第二个协议
            ProtocolHelper_Moode.showProtocol_Moode(
                type_Moode: secondProtocol_Moode,
                content_Moode: secondContent_Moode,
                from: viewController_Moode
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Moode: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Moode: ProtocolHelper_Moode.ProtocolType_Moode
    private let content_Moode: String
    
    private var webView_Moode: WKWebView?
    private var scrollView_Moode: UIScrollView?
    private var activityIndicator_Moode: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Moode: Bool {
        return content_Moode.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Moode: Bool {
        return content_Moode.hasSuffix(".png") || 
               content_Moode.hasSuffix(".jpg") || 
               content_Moode.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Moode: ProtocolHelper_Moode.ProtocolType_Moode, content_Moode: String) {
        self.protocolType_Moode = type_Moode
        self.content_Moode = content_Moode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Moode()
        loadContent_Moode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Moode() {
        view.backgroundColor = .white
        title = protocolType_Moode.title_Moode
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Moode)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Moode {
            setupWebView_Moode()
            setupActivityIndicator_Moode()
        } else {
            setupScrollView_Moode()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Moode() {
        let webView_Moode = WKWebView()
        webView_Moode.navigationDelegate = self
        view.addSubview(webView_Moode)
        
        webView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Moode = webView_Moode
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Moode() {
        let scrollView_Moode = UIScrollView()
        scrollView_Moode.showsVerticalScrollIndicator = true
        scrollView_Moode.alwaysBounceVertical = true
        view.addSubview(scrollView_Moode)
        
        scrollView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Moode = scrollView_Moode
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Moode() {
        let indicator_Moode = UIActivityIndicatorView(style: .large)
        indicator_Moode.color = .gray
        view.addSubview(indicator_Moode)
        
        indicator_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Moode = indicator_Moode
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Moode() {
        if isRemoteURL_Moode {
            loadWebContent_Moode()
        } else if isImage_Moode {
            loadImageContent_Moode()
        } else {
            loadTextContent_Moode()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Moode() {
        guard let url_Moode = URL(string: content_Moode) else { return }
        
        activityIndicator_Moode?.startAnimating()
        
        let request_Moode = URLRequest(url: url_Moode)
        webView_Moode?.load(request_Moode)
    }
    
    /// 加载图片内容
    private func loadImageContent_Moode() {
        guard let scrollView_Moode = scrollView_Moode,
              let image_Moode = UIImage(named: content_Moode) else { return }
        
        let imageView_Moode = UIImageView()
        imageView_Moode.contentMode = .scaleAspectFit
        imageView_Moode.image = image_Moode
        scrollView_Moode.addSubview(imageView_Moode)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Moode = view.bounds.width
        let imageRatio_Moode = image_Moode.size.height / image_Moode.size.width
        let displayHeight_Moode = screenWidth_Moode * imageRatio_Moode
        
        imageView_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Moode)
            make.height.equalTo(displayHeight_Moode)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Moode() {
        guard let scrollView_Moode = scrollView_Moode else { return }
        
        let textLabel_Moode = UILabel()
        textLabel_Moode.text = content_Moode
        textLabel_Moode.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Moode.textColor = .black
        textLabel_Moode.numberOfLines = 0
        scrollView_Moode.addSubview(textLabel_Moode)
        
        textLabel_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Moode() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Moode: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Moode?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Moode?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Moode?.stopAnimating()
        Utils_Moode.showError_Moode(message_Moode: "Failed to load content")
    }
}
