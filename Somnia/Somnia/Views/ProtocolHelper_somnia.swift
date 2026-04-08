import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Somnia {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Somnia {
        case terms_Somnia       // 服务条款
        case privacy_Somnia     // 隐私政策
        case eula_Somnia        // 最终用户许可协议
        case custom_Somnia(String) // 自定义协议
        
        /// 获取协议标题
        var title_Somnia: String {
            switch self {
            case .terms_Somnia:
                return "Terms of Service"
            case .privacy_Somnia:
                return "Privacy Policy"
            case .eula_Somnia:
                return "EULA"
            case .custom_Somnia(let title_Somnia):
                return title_Somnia
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Somnia {
        /// 普通文本颜色
        var textColor_Somnia: UIColor
        /// 链接文本颜色
        var linkColor_Somnia: UIColor
        /// 字体大小
        var fontSize_Somnia: CGFloat
        /// 字体粗细
        var fontWeight_Somnia: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Somnia: Bool
        /// 前缀文本
        var prefixText_Somnia: String
        /// 分隔符文本
        var separatorText_Somnia: String
        
        /// 默认初始化
        init(
            textColor_Somnia: UIColor = UIColor.gray,
            linkColor_Somnia: UIColor = UIColor.black,
            fontSize_Somnia: CGFloat = 12,
            fontWeight_Somnia: UIFont.Weight = .regular,
            hasUnderline_Somnia: Bool = true,
            prefixText_Somnia: String = "By continuing you agree with ",
            separatorText_Somnia: String = " & "
        ) {
            self.textColor_Somnia = textColor_Somnia
            self.linkColor_Somnia = linkColor_Somnia
            self.fontSize_Somnia = fontSize_Somnia
            self.fontWeight_Somnia = fontWeight_Somnia
            self.hasUnderline_Somnia = hasUnderline_Somnia
            self.prefixText_Somnia = prefixText_Somnia
            self.separatorText_Somnia = separatorText_Somnia
        }
        
        /// 浅色主题配置
        static func light_Somnia() -> ProtocolTextConfig_Somnia {
            return ProtocolTextConfig_Somnia(
                textColor_Somnia: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Somnia: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Somnia() -> ProtocolTextConfig_Somnia {
            return ProtocolTextConfig_Somnia(
                textColor_Somnia: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Somnia: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Somnia: 协议类型
    ///   - content_Somnia: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Somnia: 当前视图控制器
    static func showProtocol_Somnia(
        type_Somnia: ProtocolType_Somnia,
        content_Somnia: String,
        from viewController_Somnia: UIViewController
    ) {
        let protocolVC_Somnia = ProtocolViewController_Somnia(
            type_Somnia: type_Somnia,
            content_Somnia: content_Somnia
        )
        viewController_Somnia.navigationController?.pushViewController(
            protocolVC_Somnia,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Somnia: 第一个协议类型
    ///   - firstContent_Somnia: 第一个协议内容
    ///   - secondProtocol_Somnia: 第二个协议类型
    ///   - secondContent_Somnia: 第二个协议内容
    ///   - config_Somnia: 文本配置
    ///   - viewController_Somnia: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Somnia(
        firstProtocol_Somnia: ProtocolType_Somnia = .terms_Somnia,
        firstContent_Somnia: String,
        secondProtocol_Somnia: ProtocolType_Somnia = .privacy_Somnia,
        secondContent_Somnia: String,
        config_Somnia: ProtocolTextConfig_Somnia = .light_Somnia(),
        from viewController_Somnia: UIViewController
    ) -> UILabel {
        let label_Somnia = UILabel()
        label_Somnia.numberOfLines = 0
        label_Somnia.textAlignment = .center
        label_Somnia.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Somnia = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Somnia.fontSize_Somnia, weight: config_Somnia.fontWeight_Somnia),
            .foregroundColor: config_Somnia.textColor_Somnia
        ]
        attributedString_Somnia.append(NSAttributedString(
            string: config_Somnia.prefixText_Somnia,
            attributes: prefixAttributes_Somnia
        ))
        
        // 第一个协议链接
        var linkAttributes_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Somnia.fontSize_Somnia, weight: config_Somnia.fontWeight_Somnia),
            .foregroundColor: config_Somnia.linkColor_Somnia
        ]
        if config_Somnia.hasUnderline_Somnia {
            linkAttributes_Somnia[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Somnia[.underlineColor] = config_Somnia.linkColor_Somnia
        }
        
        let firstProtocolString_Somnia = NSAttributedString(
            string: firstProtocol_Somnia.title_Somnia,
            attributes: linkAttributes_Somnia
        )
        attributedString_Somnia.append(firstProtocolString_Somnia)
        
        // 分隔符
        attributedString_Somnia.append(NSAttributedString(
            string: config_Somnia.separatorText_Somnia,
            attributes: prefixAttributes_Somnia
        ))
        
        // 第二个协议链接
        let secondProtocolString_Somnia = NSAttributedString(
            string: secondProtocol_Somnia.title_Somnia + ".",
            attributes: linkAttributes_Somnia
        )
        attributedString_Somnia.append(secondProtocolString_Somnia)
        
        label_Somnia.attributedText = attributedString_Somnia
        
        // 添加点击手势
        let tapGesture_Somnia = ProtocolTextTapGesture_Somnia(
            firstProtocol_Somnia: firstProtocol_Somnia,
            firstContent_Somnia: firstContent_Somnia,
            secondProtocol_Somnia: secondProtocol_Somnia,
            secondContent_Somnia: secondContent_Somnia,
            prefixLength_Somnia: config_Somnia.prefixText_Somnia.count,
            firstTitleLength_Somnia: firstProtocol_Somnia.title_Somnia.count,
            separatorLength_Somnia: config_Somnia.separatorText_Somnia.count,
            secondTitleLength_Somnia: secondProtocol_Somnia.title_Somnia.count + 1,
            viewController_Somnia: viewController_Somnia
        )
        label_Somnia.addGestureRecognizer(tapGesture_Somnia)
        
        return label_Somnia
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Somnia: UITapGestureRecognizer {
    
    private let firstProtocol_Somnia: ProtocolHelper_Somnia.ProtocolType_Somnia
    private let firstContent_Somnia: String
    private let secondProtocol_Somnia: ProtocolHelper_Somnia.ProtocolType_Somnia
    private let secondContent_Somnia: String
    private let prefixLength_Somnia: Int
    private let firstTitleLength_Somnia: Int
    private let separatorLength_Somnia: Int
    private let secondTitleLength_Somnia: Int
    private weak var viewController_Somnia: UIViewController?
    
    init(
        firstProtocol_Somnia: ProtocolHelper_Somnia.ProtocolType_Somnia,
        firstContent_Somnia: String,
        secondProtocol_Somnia: ProtocolHelper_Somnia.ProtocolType_Somnia,
        secondContent_Somnia: String,
        prefixLength_Somnia: Int,
        firstTitleLength_Somnia: Int,
        separatorLength_Somnia: Int,
        secondTitleLength_Somnia: Int,
        viewController_Somnia: UIViewController
    ) {
        self.firstProtocol_Somnia = firstProtocol_Somnia
        self.firstContent_Somnia = firstContent_Somnia
        self.secondProtocol_Somnia = secondProtocol_Somnia
        self.secondContent_Somnia = secondContent_Somnia
        self.prefixLength_Somnia = prefixLength_Somnia
        self.firstTitleLength_Somnia = firstTitleLength_Somnia
        self.separatorLength_Somnia = separatorLength_Somnia
        self.secondTitleLength_Somnia = secondTitleLength_Somnia
        self.viewController_Somnia = viewController_Somnia
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Somnia(_:)))
    }
    
    @objc private func handleTap_Somnia(_ gesture: UITapGestureRecognizer) {
        guard let label_Somnia = gesture.view as? UILabel,
              let attributedText_Somnia = label_Somnia.attributedText,
              let viewController_Somnia = viewController_Somnia else { return }
        
        // 计算点击位置
        let location_Somnia = gesture.location(in: label_Somnia)
        
        // 创建文本容器和布局管理器
        let textStorage_Somnia = NSTextStorage(attributedString: attributedText_Somnia)
        let layoutManager_Somnia = NSLayoutManager()
        let textContainer_Somnia = NSTextContainer(size: label_Somnia.bounds.size)
        
        layoutManager_Somnia.addTextContainer(textContainer_Somnia)
        textStorage_Somnia.addLayoutManager(layoutManager_Somnia)
        
        textContainer_Somnia.lineFragmentPadding = 0
        textContainer_Somnia.maximumNumberOfLines = label_Somnia.numberOfLines
        textContainer_Somnia.lineBreakMode = label_Somnia.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Somnia = layoutManager_Somnia.characterIndex(
            for: location_Somnia,
            in: textContainer_Somnia,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Somnia = prefixLength_Somnia
        let firstLinkEnd_Somnia = firstLinkStart_Somnia + firstTitleLength_Somnia
        
        let secondLinkStart_Somnia = firstLinkEnd_Somnia + separatorLength_Somnia
        let secondLinkEnd_Somnia = secondLinkStart_Somnia + secondTitleLength_Somnia
        
        if characterIndex_Somnia >= firstLinkStart_Somnia && characterIndex_Somnia < firstLinkEnd_Somnia {
            // 点击第一个协议
            ProtocolHelper_Somnia.showProtocol_Somnia(
                type_Somnia: firstProtocol_Somnia,
                content_Somnia: firstContent_Somnia,
                from: viewController_Somnia
            )
        } else if characterIndex_Somnia >= secondLinkStart_Somnia && characterIndex_Somnia < secondLinkEnd_Somnia {
            // 点击第二个协议
            ProtocolHelper_Somnia.showProtocol_Somnia(
                type_Somnia: secondProtocol_Somnia,
                content_Somnia: secondContent_Somnia,
                from: viewController_Somnia
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Somnia: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Somnia: ProtocolHelper_Somnia.ProtocolType_Somnia
    private let content_Somnia: String
    
    private var webView_Somnia: WKWebView?
    private var scrollView_Somnia: UIScrollView?
    private var activityIndicator_Somnia: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Somnia: Bool {
        return content_Somnia.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Somnia: Bool {
        return content_Somnia.hasSuffix(".png") || 
               content_Somnia.hasSuffix(".jpg") || 
               content_Somnia.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Somnia: ProtocolHelper_Somnia.ProtocolType_Somnia, content_Somnia: String) {
        self.protocolType_Somnia = type_Somnia
        self.content_Somnia = content_Somnia
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        loadContent_Somnia()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Somnia() {
        view.backgroundColor = .white
        title = protocolType_Somnia.title_Somnia
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Somnia)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Somnia {
            setupWebView_Somnia()
            setupActivityIndicator_Somnia()
        } else {
            setupScrollView_Somnia()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Somnia() {
        let webView_Somnia = WKWebView()
        webView_Somnia.navigationDelegate = self
        view.addSubview(webView_Somnia)
        
        webView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Somnia = webView_Somnia
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Somnia() {
        let scrollView_Somnia = UIScrollView()
        scrollView_Somnia.showsVerticalScrollIndicator = true
        scrollView_Somnia.alwaysBounceVertical = true
        view.addSubview(scrollView_Somnia)
        
        scrollView_Somnia.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Somnia = scrollView_Somnia
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Somnia() {
        let indicator_Somnia = UIActivityIndicatorView(style: .large)
        indicator_Somnia.color = .gray
        view.addSubview(indicator_Somnia)
        
        indicator_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Somnia = indicator_Somnia
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Somnia() {
        if isRemoteURL_Somnia {
            loadWebContent_Somnia()
        } else if isImage_Somnia {
            loadImageContent_Somnia()
        } else {
            loadTextContent_Somnia()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Somnia() {
        guard let url_Somnia = URL(string: content_Somnia) else { return }
        
        activityIndicator_Somnia?.startAnimating()
        
        let request_Somnia = URLRequest(url: url_Somnia)
        webView_Somnia?.load(request_Somnia)
    }
    
    /// 加载图片内容
    private func loadImageContent_Somnia() {
        guard let scrollView_Somnia = scrollView_Somnia,
              let image_Somnia = UIImage(named: content_Somnia) else { return }
        
        let imageView_Somnia = UIImageView()
        imageView_Somnia.contentMode = .scaleAspectFit
        imageView_Somnia.image = image_Somnia
        scrollView_Somnia.addSubview(imageView_Somnia)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Somnia = view.bounds.width
        let imageRatio_Somnia = image_Somnia.size.height / image_Somnia.size.width
        let displayHeight_Somnia = screenWidth_Somnia * imageRatio_Somnia
        
        imageView_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Somnia)
            make.height.equalTo(displayHeight_Somnia)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Somnia() {
        guard let scrollView_Somnia = scrollView_Somnia else { return }
        
        let textLabel_Somnia = UILabel()
        textLabel_Somnia.text = content_Somnia
        textLabel_Somnia.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Somnia.textColor = .black
        textLabel_Somnia.numberOfLines = 0
        scrollView_Somnia.addSubview(textLabel_Somnia)
        
        textLabel_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Somnia() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Somnia: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Somnia?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Somnia?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Somnia?.stopAnimating()
        Utils_Somnia.showError_Somnia(message_Somnia: "Failed to load content")
    }
}
