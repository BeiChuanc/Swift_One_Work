import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Echd {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Echd {
        case terms_Echd       // 服务条款
        case privacy_Echd     // 隐私政策
        case eula_Echd        // 最终用户许可协议
        case custom_Echd(String) // 自定义协议
        
        /// 获取协议标题
        var title_Echd: String {
            switch self {
            case .terms_Echd:
                return "Terms of Service"
            case .privacy_Echd:
                return "Privacy Policy"
            case .eula_Echd:
                return "EULA"
            case .custom_Echd(let title_Echd):
                return title_Echd
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Echd {
        /// 普通文本颜色
        var textColor_Echd: UIColor
        /// 链接文本颜色
        var linkColor_Echd: UIColor
        /// 字体大小
        var fontSize_Echd: CGFloat
        /// 字体粗细
        var fontWeight_Echd: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Echd: Bool
        /// 前缀文本
        var prefixText_Echd: String
        /// 分隔符文本
        var separatorText_Echd: String
        
        /// 默认初始化
        init(
            textColor_Echd: UIColor = UIColor.gray,
            linkColor_Echd: UIColor = UIColor.black,
            fontSize_Echd: CGFloat = 12,
            fontWeight_Echd: UIFont.Weight = .regular,
            hasUnderline_Echd: Bool = true,
            prefixText_Echd: String = "By continuing you agree with ",
            separatorText_Echd: String = " & "
        ) {
            self.textColor_Echd = textColor_Echd
            self.linkColor_Echd = linkColor_Echd
            self.fontSize_Echd = fontSize_Echd
            self.fontWeight_Echd = fontWeight_Echd
            self.hasUnderline_Echd = hasUnderline_Echd
            self.prefixText_Echd = prefixText_Echd
            self.separatorText_Echd = separatorText_Echd
        }
        
        /// 浅色主题配置
        static func light_Echd() -> ProtocolTextConfig_Echd {
            return ProtocolTextConfig_Echd(
                textColor_Echd: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Echd: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Echd() -> ProtocolTextConfig_Echd {
            return ProtocolTextConfig_Echd(
                textColor_Echd: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Echd: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Echd: 协议类型
    ///   - content_Echd: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Echd: 当前视图控制器
    static func showProtocol_Echd(
        type_Echd: ProtocolType_Echd,
        content_Echd: String,
        from viewController_Echd: UIViewController
    ) {
        let protocolVC_Echd = ProtocolViewController_Echd(
            type_Echd: type_Echd,
            content_Echd: content_Echd
        )
        viewController_Echd.navigationController?.pushViewController(
            protocolVC_Echd,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Echd: 第一个协议类型
    ///   - firstContent_Echd: 第一个协议内容
    ///   - secondProtocol_Echd: 第二个协议类型
    ///   - secondContent_Echd: 第二个协议内容
    ///   - config_Echd: 文本配置
    ///   - viewController_Echd: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Echd(
        firstProtocol_Echd: ProtocolType_Echd = .terms_Echd,
        firstContent_Echd: String,
        secondProtocol_Echd: ProtocolType_Echd = .privacy_Echd,
        secondContent_Echd: String,
        config_Echd: ProtocolTextConfig_Echd = .light_Echd(),
        from viewController_Echd: UIViewController
    ) -> UILabel {
        let label_Echd = UILabel()
        label_Echd.numberOfLines = 0
        label_Echd.textAlignment = .center
        label_Echd.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Echd = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Echd: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Echd.fontSize_Echd, weight: config_Echd.fontWeight_Echd),
            .foregroundColor: config_Echd.textColor_Echd
        ]
        attributedString_Echd.append(NSAttributedString(
            string: config_Echd.prefixText_Echd,
            attributes: prefixAttributes_Echd
        ))
        
        // 第一个协议链接
        var linkAttributes_Echd: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Echd.fontSize_Echd, weight: config_Echd.fontWeight_Echd),
            .foregroundColor: config_Echd.linkColor_Echd
        ]
        if config_Echd.hasUnderline_Echd {
            linkAttributes_Echd[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Echd[.underlineColor] = config_Echd.linkColor_Echd
        }
        
        let firstProtocolString_Echd = NSAttributedString(
            string: firstProtocol_Echd.title_Echd,
            attributes: linkAttributes_Echd
        )
        attributedString_Echd.append(firstProtocolString_Echd)
        
        // 分隔符
        attributedString_Echd.append(NSAttributedString(
            string: config_Echd.separatorText_Echd,
            attributes: prefixAttributes_Echd
        ))
        
        // 第二个协议链接
        let secondProtocolString_Echd = NSAttributedString(
            string: secondProtocol_Echd.title_Echd + ".",
            attributes: linkAttributes_Echd
        )
        attributedString_Echd.append(secondProtocolString_Echd)
        
        label_Echd.attributedText = attributedString_Echd
        
        // 添加点击手势
        let tapGesture_Echd = ProtocolTextTapGesture_Echd(
            firstProtocol_Echd: firstProtocol_Echd,
            firstContent_Echd: firstContent_Echd,
            secondProtocol_Echd: secondProtocol_Echd,
            secondContent_Echd: secondContent_Echd,
            prefixLength_Echd: config_Echd.prefixText_Echd.count,
            firstTitleLength_Echd: firstProtocol_Echd.title_Echd.count,
            separatorLength_Echd: config_Echd.separatorText_Echd.count,
            secondTitleLength_Echd: secondProtocol_Echd.title_Echd.count + 1,
            viewController_Echd: viewController_Echd
        )
        label_Echd.addGestureRecognizer(tapGesture_Echd)
        
        return label_Echd
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Echd: UITapGestureRecognizer {
    
    private let firstProtocol_Echd: ProtocolHelper_Echd.ProtocolType_Echd
    private let firstContent_Echd: String
    private let secondProtocol_Echd: ProtocolHelper_Echd.ProtocolType_Echd
    private let secondContent_Echd: String
    private let prefixLength_Echd: Int
    private let firstTitleLength_Echd: Int
    private let separatorLength_Echd: Int
    private let secondTitleLength_Echd: Int
    private weak var viewController_Echd: UIViewController?
    
    init(
        firstProtocol_Echd: ProtocolHelper_Echd.ProtocolType_Echd,
        firstContent_Echd: String,
        secondProtocol_Echd: ProtocolHelper_Echd.ProtocolType_Echd,
        secondContent_Echd: String,
        prefixLength_Echd: Int,
        firstTitleLength_Echd: Int,
        separatorLength_Echd: Int,
        secondTitleLength_Echd: Int,
        viewController_Echd: UIViewController
    ) {
        self.firstProtocol_Echd = firstProtocol_Echd
        self.firstContent_Echd = firstContent_Echd
        self.secondProtocol_Echd = secondProtocol_Echd
        self.secondContent_Echd = secondContent_Echd
        self.prefixLength_Echd = prefixLength_Echd
        self.firstTitleLength_Echd = firstTitleLength_Echd
        self.separatorLength_Echd = separatorLength_Echd
        self.secondTitleLength_Echd = secondTitleLength_Echd
        self.viewController_Echd = viewController_Echd
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Echd(_:)))
    }
    
    @objc private func handleTap_Echd(_ gesture: UITapGestureRecognizer) {
        guard let label_Echd = gesture.view as? UILabel,
              let attributedText_Echd = label_Echd.attributedText,
              let viewController_Echd = viewController_Echd else { return }
        
        // 计算点击位置
        let location_Echd = gesture.location(in: label_Echd)
        
        // 创建文本容器和布局管理器
        let textStorage_Echd = NSTextStorage(attributedString: attributedText_Echd)
        let layoutManager_Echd = NSLayoutManager()
        let textContainer_Echd = NSTextContainer(size: label_Echd.bounds.size)
        
        layoutManager_Echd.addTextContainer(textContainer_Echd)
        textStorage_Echd.addLayoutManager(layoutManager_Echd)
        
        textContainer_Echd.lineFragmentPadding = 0
        textContainer_Echd.maximumNumberOfLines = label_Echd.numberOfLines
        textContainer_Echd.lineBreakMode = label_Echd.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Echd = layoutManager_Echd.characterIndex(
            for: location_Echd,
            in: textContainer_Echd,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Echd = prefixLength_Echd
        let firstLinkEnd_Echd = firstLinkStart_Echd + firstTitleLength_Echd
        
        let secondLinkStart_Echd = firstLinkEnd_Echd + separatorLength_Echd
        let secondLinkEnd_Echd = secondLinkStart_Echd + secondTitleLength_Echd
        
        if characterIndex_Echd >= firstLinkStart_Echd && characterIndex_Echd < firstLinkEnd_Echd {
            // 点击第一个协议
            ProtocolHelper_Echd.showProtocol_Echd(
                type_Echd: firstProtocol_Echd,
                content_Echd: firstContent_Echd,
                from: viewController_Echd
            )
        } else if characterIndex_Echd >= secondLinkStart_Echd && characterIndex_Echd < secondLinkEnd_Echd {
            // 点击第二个协议
            ProtocolHelper_Echd.showProtocol_Echd(
                type_Echd: secondProtocol_Echd,
                content_Echd: secondContent_Echd,
                from: viewController_Echd
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Echd: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Echd: ProtocolHelper_Echd.ProtocolType_Echd
    private let content_Echd: String
    
    private var webView_Echd: WKWebView?
    private var scrollView_Echd: UIScrollView?
    private var activityIndicator_Echd: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Echd: Bool {
        return content_Echd.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Echd: Bool {
        return content_Echd.hasSuffix(".png") || 
               content_Echd.hasSuffix(".jpg") || 
               content_Echd.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Echd: ProtocolHelper_Echd.ProtocolType_Echd, content_Echd: String) {
        self.protocolType_Echd = type_Echd
        self.content_Echd = content_Echd
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Echd()
        loadContent_Echd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Echd() {
        view.backgroundColor = .white
        title = protocolType_Echd.title_Echd
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Echd)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Echd {
            setupWebView_Echd()
            setupActivityIndicator_Echd()
        } else {
            setupScrollView_Echd()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Echd() {
        let webView_Echd = WKWebView()
        webView_Echd.navigationDelegate = self
        view.addSubview(webView_Echd)
        
        webView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Echd = webView_Echd
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Echd() {
        let scrollView_Echd = UIScrollView()
        scrollView_Echd.showsVerticalScrollIndicator = true
        scrollView_Echd.alwaysBounceVertical = true
        view.addSubview(scrollView_Echd)
        
        scrollView_Echd.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Echd = scrollView_Echd
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Echd() {
        let indicator_Echd = UIActivityIndicatorView(style: .large)
        indicator_Echd.color = .gray
        view.addSubview(indicator_Echd)
        
        indicator_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Echd = indicator_Echd
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Echd() {
        if isRemoteURL_Echd {
            loadWebContent_Echd()
        } else if isImage_Echd {
            loadImageContent_Echd()
        } else {
            loadTextContent_Echd()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Echd() {
        guard let url_Echd = URL(string: content_Echd) else { return }
        
        activityIndicator_Echd?.startAnimating()
        
        let request_Echd = URLRequest(url: url_Echd)
        webView_Echd?.load(request_Echd)
    }
    
    /// 加载图片内容
    private func loadImageContent_Echd() {
        guard let scrollView_Echd = scrollView_Echd,
              let image_Echd = UIImage(named: content_Echd) else { return }
        
        let imageView_Echd = UIImageView()
        imageView_Echd.contentMode = .scaleAspectFit
        imageView_Echd.image = image_Echd
        scrollView_Echd.addSubview(imageView_Echd)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Echd = view.bounds.width
        let imageRatio_Echd = image_Echd.size.height / image_Echd.size.width
        let displayHeight_Echd = screenWidth_Echd * imageRatio_Echd
        
        imageView_Echd.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Echd)
            make.height.equalTo(displayHeight_Echd)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Echd() {
        guard let scrollView_Echd = scrollView_Echd else { return }
        
        let textLabel_Echd = UILabel()
        textLabel_Echd.text = content_Echd
        textLabel_Echd.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Echd.textColor = .black
        textLabel_Echd.numberOfLines = 0
        scrollView_Echd.addSubview(textLabel_Echd)
        
        textLabel_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Echd() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Echd: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Echd?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Echd?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Echd?.stopAnimating()
        Utils_Echd.showError_Echd(message_Echd: "Failed to load content")
    }
}
