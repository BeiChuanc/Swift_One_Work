import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Ornit {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Ornit {
        case terms_Ornit       // 服务条款
        case privacy_Ornit     // 隐私政策
        case eula_Ornit        // 最终用户许可协议
        case custom_Ornit(String) // 自定义协议
        
        /// 获取协议标题
        var title_Ornit: String {
            switch self {
            case .terms_Ornit:
                return "Terms of Service"
            case .privacy_Ornit:
                return "Privacy Policy"
            case .eula_Ornit:
                return "EULA"
            case .custom_Ornit(let title_Ornit):
                return title_Ornit
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Ornit {
        /// 普通文本颜色
        var textColor_Ornit: UIColor
        /// 链接文本颜色
        var linkColor_Ornit: UIColor
        /// 字体大小
        var fontSize_Ornit: CGFloat
        /// 字体粗细
        var fontWeight_Ornit: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Ornit: Bool
        /// 前缀文本
        var prefixText_Ornit: String
        /// 分隔符文本
        var separatorText_Ornit: String
        
        /// 默认初始化
        init(
            textColor_Ornit: UIColor = UIColor.gray,
            linkColor_Ornit: UIColor = UIColor.black,
            fontSize_Ornit: CGFloat = 12,
            fontWeight_Ornit: UIFont.Weight = .regular,
            hasUnderline_Ornit: Bool = true,
            prefixText_Ornit: String = "By continuing you agree with ",
            separatorText_Ornit: String = " & "
        ) {
            self.textColor_Ornit = textColor_Ornit
            self.linkColor_Ornit = linkColor_Ornit
            self.fontSize_Ornit = fontSize_Ornit
            self.fontWeight_Ornit = fontWeight_Ornit
            self.hasUnderline_Ornit = hasUnderline_Ornit
            self.prefixText_Ornit = prefixText_Ornit
            self.separatorText_Ornit = separatorText_Ornit
        }
        
        /// 浅色主题配置
        static func light_Ornit() -> ProtocolTextConfig_Ornit {
            return ProtocolTextConfig_Ornit(
                textColor_Ornit: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Ornit: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Ornit() -> ProtocolTextConfig_Ornit {
            return ProtocolTextConfig_Ornit(
                textColor_Ornit: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Ornit: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Ornit: 协议类型
    ///   - content_Ornit: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Ornit: 当前视图控制器
    static func showProtocol_Ornit(
        type_Ornit: ProtocolType_Ornit,
        content_Ornit: String,
        from viewController_Ornit: UIViewController
    ) {
        let protocolVC_Ornit = ProtocolViewController_Ornit(
            type_Ornit: type_Ornit,
            content_Ornit: content_Ornit
        )
        viewController_Ornit.navigationController?.pushViewController(
            protocolVC_Ornit,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Ornit: 第一个协议类型
    ///   - firstContent_Ornit: 第一个协议内容
    ///   - secondProtocol_Ornit: 第二个协议类型
    ///   - secondContent_Ornit: 第二个协议内容
    ///   - config_Ornit: 文本配置
    ///   - viewController_Ornit: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Ornit(
        firstProtocol_Ornit: ProtocolType_Ornit = .terms_Ornit,
        firstContent_Ornit: String,
        secondProtocol_Ornit: ProtocolType_Ornit = .privacy_Ornit,
        secondContent_Ornit: String,
        config_Ornit: ProtocolTextConfig_Ornit = .light_Ornit(),
        from viewController_Ornit: UIViewController
    ) -> UILabel {
        let label_Ornit = UILabel()
        label_Ornit.numberOfLines = 0
        label_Ornit.textAlignment = .center
        label_Ornit.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Ornit = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Ornit: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Ornit.fontSize_Ornit, weight: config_Ornit.fontWeight_Ornit),
            .foregroundColor: config_Ornit.textColor_Ornit
        ]
        attributedString_Ornit.append(NSAttributedString(
            string: config_Ornit.prefixText_Ornit,
            attributes: prefixAttributes_Ornit
        ))
        
        // 第一个协议链接
        var linkAttributes_Ornit: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Ornit.fontSize_Ornit, weight: config_Ornit.fontWeight_Ornit),
            .foregroundColor: config_Ornit.linkColor_Ornit
        ]
        if config_Ornit.hasUnderline_Ornit {
            linkAttributes_Ornit[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Ornit[.underlineColor] = config_Ornit.linkColor_Ornit
        }
        
        let firstProtocolString_Ornit = NSAttributedString(
            string: firstProtocol_Ornit.title_Ornit,
            attributes: linkAttributes_Ornit
        )
        attributedString_Ornit.append(firstProtocolString_Ornit)
        
        // 分隔符
        attributedString_Ornit.append(NSAttributedString(
            string: config_Ornit.separatorText_Ornit,
            attributes: prefixAttributes_Ornit
        ))
        
        // 第二个协议链接
        let secondProtocolString_Ornit = NSAttributedString(
            string: secondProtocol_Ornit.title_Ornit + ".",
            attributes: linkAttributes_Ornit
        )
        attributedString_Ornit.append(secondProtocolString_Ornit)
        
        label_Ornit.attributedText = attributedString_Ornit
        
        // 添加点击手势
        let tapGesture_Ornit = ProtocolTextTapGesture_Ornit(
            firstProtocol_Ornit: firstProtocol_Ornit,
            firstContent_Ornit: firstContent_Ornit,
            secondProtocol_Ornit: secondProtocol_Ornit,
            secondContent_Ornit: secondContent_Ornit,
            prefixLength_Ornit: config_Ornit.prefixText_Ornit.count,
            firstTitleLength_Ornit: firstProtocol_Ornit.title_Ornit.count,
            separatorLength_Ornit: config_Ornit.separatorText_Ornit.count,
            secondTitleLength_Ornit: secondProtocol_Ornit.title_Ornit.count + 1,
            viewController_Ornit: viewController_Ornit
        )
        label_Ornit.addGestureRecognizer(tapGesture_Ornit)
        
        return label_Ornit
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Ornit: UITapGestureRecognizer {
    
    private let firstProtocol_Ornit: ProtocolHelper_Ornit.ProtocolType_Ornit
    private let firstContent_Ornit: String
    private let secondProtocol_Ornit: ProtocolHelper_Ornit.ProtocolType_Ornit
    private let secondContent_Ornit: String
    private let prefixLength_Ornit: Int
    private let firstTitleLength_Ornit: Int
    private let separatorLength_Ornit: Int
    private let secondTitleLength_Ornit: Int
    private weak var viewController_Ornit: UIViewController?
    
    init(
        firstProtocol_Ornit: ProtocolHelper_Ornit.ProtocolType_Ornit,
        firstContent_Ornit: String,
        secondProtocol_Ornit: ProtocolHelper_Ornit.ProtocolType_Ornit,
        secondContent_Ornit: String,
        prefixLength_Ornit: Int,
        firstTitleLength_Ornit: Int,
        separatorLength_Ornit: Int,
        secondTitleLength_Ornit: Int,
        viewController_Ornit: UIViewController
    ) {
        self.firstProtocol_Ornit = firstProtocol_Ornit
        self.firstContent_Ornit = firstContent_Ornit
        self.secondProtocol_Ornit = secondProtocol_Ornit
        self.secondContent_Ornit = secondContent_Ornit
        self.prefixLength_Ornit = prefixLength_Ornit
        self.firstTitleLength_Ornit = firstTitleLength_Ornit
        self.separatorLength_Ornit = separatorLength_Ornit
        self.secondTitleLength_Ornit = secondTitleLength_Ornit
        self.viewController_Ornit = viewController_Ornit
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Ornit(_:)))
    }
    
    @objc private func handleTap_Ornit(_ gesture: UITapGestureRecognizer) {
        guard let label_Ornit = gesture.view as? UILabel,
              let attributedText_Ornit = label_Ornit.attributedText,
              let viewController_Ornit = viewController_Ornit else { return }
        
        // 计算点击位置
        let location_Ornit = gesture.location(in: label_Ornit)
        
        // 创建文本容器和布局管理器
        let textStorage_Ornit = NSTextStorage(attributedString: attributedText_Ornit)
        let layoutManager_Ornit = NSLayoutManager()
        let textContainer_Ornit = NSTextContainer(size: label_Ornit.bounds.size)
        
        layoutManager_Ornit.addTextContainer(textContainer_Ornit)
        textStorage_Ornit.addLayoutManager(layoutManager_Ornit)
        
        textContainer_Ornit.lineFragmentPadding = 0
        textContainer_Ornit.maximumNumberOfLines = label_Ornit.numberOfLines
        textContainer_Ornit.lineBreakMode = label_Ornit.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Ornit = layoutManager_Ornit.characterIndex(
            for: location_Ornit,
            in: textContainer_Ornit,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Ornit = prefixLength_Ornit
        let firstLinkEnd_Ornit = firstLinkStart_Ornit + firstTitleLength_Ornit
        
        let secondLinkStart_Ornit = firstLinkEnd_Ornit + separatorLength_Ornit
        let secondLinkEnd_Ornit = secondLinkStart_Ornit + secondTitleLength_Ornit
        
        if characterIndex_Ornit >= firstLinkStart_Ornit && characterIndex_Ornit < firstLinkEnd_Ornit {
            // 点击第一个协议
            ProtocolHelper_Ornit.showProtocol_Ornit(
                type_Ornit: firstProtocol_Ornit,
                content_Ornit: firstContent_Ornit,
                from: viewController_Ornit
            )
        } else if characterIndex_Ornit >= secondLinkStart_Ornit && characterIndex_Ornit < secondLinkEnd_Ornit {
            // 点击第二个协议
            ProtocolHelper_Ornit.showProtocol_Ornit(
                type_Ornit: secondProtocol_Ornit,
                content_Ornit: secondContent_Ornit,
                from: viewController_Ornit
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Ornit: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Ornit: ProtocolHelper_Ornit.ProtocolType_Ornit
    private let content_Ornit: String
    
    private var webView_Ornit: WKWebView?
    private var scrollView_Ornit: UIScrollView?
    private var activityIndicator_Ornit: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Ornit: Bool {
        return content_Ornit.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Ornit: Bool {
        return content_Ornit.hasSuffix(".png") || 
               content_Ornit.hasSuffix(".jpg") || 
               content_Ornit.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Ornit: ProtocolHelper_Ornit.ProtocolType_Ornit, content_Ornit: String) {
        self.protocolType_Ornit = type_Ornit
        self.content_Ornit = content_Ornit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Ornit()
        loadContent_Ornit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Ornit() {
        view.backgroundColor = .white
        title = protocolType_Ornit.title_Ornit
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Ornit)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Ornit {
            setupWebView_Ornit()
            setupActivityIndicator_Ornit()
        } else {
            setupScrollView_Ornit()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Ornit() {
        let webView_Ornit = WKWebView()
        webView_Ornit.navigationDelegate = self
        view.addSubview(webView_Ornit)
        
        webView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Ornit = webView_Ornit
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Ornit() {
        let scrollView_Ornit = UIScrollView()
        scrollView_Ornit.showsVerticalScrollIndicator = true
        scrollView_Ornit.alwaysBounceVertical = true
        view.addSubview(scrollView_Ornit)
        
        scrollView_Ornit.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Ornit = scrollView_Ornit
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Ornit() {
        let indicator_Ornit = UIActivityIndicatorView(style: .large)
        indicator_Ornit.color = .gray
        view.addSubview(indicator_Ornit)
        
        indicator_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Ornit = indicator_Ornit
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Ornit() {
        if isRemoteURL_Ornit {
            loadWebContent_Ornit()
        } else if isImage_Ornit {
            loadImageContent_Ornit()
        } else {
            loadTextContent_Ornit()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Ornit() {
        guard let url_Ornit = URL(string: content_Ornit) else { return }
        
        activityIndicator_Ornit?.startAnimating()
        
        let request_Ornit = URLRequest(url: url_Ornit)
        webView_Ornit?.load(request_Ornit)
    }
    
    /// 加载图片内容
    private func loadImageContent_Ornit() {
        guard let scrollView_Ornit = scrollView_Ornit,
              let image_Ornit = UIImage(named: content_Ornit) else { return }
        
        let imageView_Ornit = UIImageView()
        imageView_Ornit.contentMode = .scaleAspectFit
        imageView_Ornit.image = image_Ornit
        scrollView_Ornit.addSubview(imageView_Ornit)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Ornit = view.bounds.width
        let imageRatio_Ornit = image_Ornit.size.height / image_Ornit.size.width
        let displayHeight_Ornit = screenWidth_Ornit * imageRatio_Ornit
        
        imageView_Ornit.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Ornit)
            make.height.equalTo(displayHeight_Ornit)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Ornit() {
        guard let scrollView_Ornit = scrollView_Ornit else { return }
        
        let textLabel_Ornit = UILabel()
        textLabel_Ornit.text = content_Ornit
        textLabel_Ornit.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Ornit.textColor = .black
        textLabel_Ornit.numberOfLines = 0
        scrollView_Ornit.addSubview(textLabel_Ornit)
        
        textLabel_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Ornit() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Ornit: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Ornit?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Ornit?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Ornit?.stopAnimating()
        Utils_Ornit.showError_Ornit(message_Ornit: "Failed to load content")
    }
}
