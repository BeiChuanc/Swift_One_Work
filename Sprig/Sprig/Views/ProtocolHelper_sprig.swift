import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Sprig {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Sprig {
        case terms_Sprig       // 服务条款
        case privacy_Sprig     // 隐私政策
        case eula_Sprig        // 最终用户许可协议
        case custom_Sprig(String) // 自定义协议
        
        /// 获取协议标题
        var title_Sprig: String {
            switch self {
            case .terms_Sprig:
                return "Terms of Service"
            case .privacy_Sprig:
                return "Privacy Policy"
            case .eula_Sprig:
                return "EULA"
            case .custom_Sprig(let title_Sprig):
                return title_Sprig
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Sprig {
        /// 普通文本颜色
        var textColor_Sprig: UIColor
        /// 链接文本颜色
        var linkColor_Sprig: UIColor
        /// 字体大小
        var fontSize_Sprig: CGFloat
        /// 字体粗细
        var fontWeight_Sprig: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Sprig: Bool
        /// 前缀文本
        var prefixText_Sprig: String
        /// 分隔符文本
        var separatorText_Sprig: String
        
        /// 默认初始化
        init(
            textColor_Sprig: UIColor = UIColor.gray,
            linkColor_Sprig: UIColor = UIColor.black,
            fontSize_Sprig: CGFloat = 12,
            fontWeight_Sprig: UIFont.Weight = .regular,
            hasUnderline_Sprig: Bool = true,
            prefixText_Sprig: String = "By continuing you agree with ",
            separatorText_Sprig: String = " & "
        ) {
            self.textColor_Sprig = textColor_Sprig
            self.linkColor_Sprig = linkColor_Sprig
            self.fontSize_Sprig = fontSize_Sprig
            self.fontWeight_Sprig = fontWeight_Sprig
            self.hasUnderline_Sprig = hasUnderline_Sprig
            self.prefixText_Sprig = prefixText_Sprig
            self.separatorText_Sprig = separatorText_Sprig
        }
        
        /// 浅色主题配置
        static func light_Sprig() -> ProtocolTextConfig_Sprig {
            return ProtocolTextConfig_Sprig(
                textColor_Sprig: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Sprig: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Sprig() -> ProtocolTextConfig_Sprig {
            return ProtocolTextConfig_Sprig(
                textColor_Sprig: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Sprig: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Sprig: 协议类型
    ///   - content_Sprig: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Sprig: 当前视图控制器
    static func showProtocol_Sprig(
        type_Sprig: ProtocolType_Sprig,
        content_Sprig: String,
        from viewController_Sprig: UIViewController
    ) {
        let protocolVC_Sprig = ProtocolViewController_Sprig(
            type_Sprig: type_Sprig,
            content_Sprig: content_Sprig
        )
        viewController_Sprig.navigationController?.pushViewController(
            protocolVC_Sprig,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Sprig: 第一个协议类型
    ///   - firstContent_Sprig: 第一个协议内容
    ///   - secondProtocol_Sprig: 第二个协议类型
    ///   - secondContent_Sprig: 第二个协议内容
    ///   - config_Sprig: 文本配置
    ///   - viewController_Sprig: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Sprig(
        firstProtocol_Sprig: ProtocolType_Sprig = .terms_Sprig,
        firstContent_Sprig: String,
        secondProtocol_Sprig: ProtocolType_Sprig = .privacy_Sprig,
        secondContent_Sprig: String,
        config_Sprig: ProtocolTextConfig_Sprig = .light_Sprig(),
        from viewController_Sprig: UIViewController
    ) -> UILabel {
        let label_Sprig = UILabel()
        label_Sprig.numberOfLines = 0
        label_Sprig.textAlignment = .center
        label_Sprig.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Sprig = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Sprig: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Sprig.fontSize_Sprig, weight: config_Sprig.fontWeight_Sprig),
            .foregroundColor: config_Sprig.textColor_Sprig
        ]
        attributedString_Sprig.append(NSAttributedString(
            string: config_Sprig.prefixText_Sprig,
            attributes: prefixAttributes_Sprig
        ))
        
        // 第一个协议链接
        var linkAttributes_Sprig: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Sprig.fontSize_Sprig, weight: config_Sprig.fontWeight_Sprig),
            .foregroundColor: config_Sprig.linkColor_Sprig
        ]
        if config_Sprig.hasUnderline_Sprig {
            linkAttributes_Sprig[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Sprig[.underlineColor] = config_Sprig.linkColor_Sprig
        }
        
        let firstProtocolString_Sprig = NSAttributedString(
            string: firstProtocol_Sprig.title_Sprig,
            attributes: linkAttributes_Sprig
        )
        attributedString_Sprig.append(firstProtocolString_Sprig)
        
        // 分隔符
        attributedString_Sprig.append(NSAttributedString(
            string: config_Sprig.separatorText_Sprig,
            attributes: prefixAttributes_Sprig
        ))
        
        // 第二个协议链接
        let secondProtocolString_Sprig = NSAttributedString(
            string: secondProtocol_Sprig.title_Sprig + ".",
            attributes: linkAttributes_Sprig
        )
        attributedString_Sprig.append(secondProtocolString_Sprig)
        
        label_Sprig.attributedText = attributedString_Sprig
        
        // 添加点击手势
        let tapGesture_Sprig = ProtocolTextTapGesture_Sprig(
            firstProtocol_Sprig: firstProtocol_Sprig,
            firstContent_Sprig: firstContent_Sprig,
            secondProtocol_Sprig: secondProtocol_Sprig,
            secondContent_Sprig: secondContent_Sprig,
            prefixLength_Sprig: config_Sprig.prefixText_Sprig.count,
            firstTitleLength_Sprig: firstProtocol_Sprig.title_Sprig.count,
            separatorLength_Sprig: config_Sprig.separatorText_Sprig.count,
            secondTitleLength_Sprig: secondProtocol_Sprig.title_Sprig.count + 1,
            viewController_Sprig: viewController_Sprig
        )
        label_Sprig.addGestureRecognizer(tapGesture_Sprig)
        
        return label_Sprig
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Sprig: UITapGestureRecognizer {
    
    private let firstProtocol_Sprig: ProtocolHelper_Sprig.ProtocolType_Sprig
    private let firstContent_Sprig: String
    private let secondProtocol_Sprig: ProtocolHelper_Sprig.ProtocolType_Sprig
    private let secondContent_Sprig: String
    private let prefixLength_Sprig: Int
    private let firstTitleLength_Sprig: Int
    private let separatorLength_Sprig: Int
    private let secondTitleLength_Sprig: Int
    private weak var viewController_Sprig: UIViewController?
    
    init(
        firstProtocol_Sprig: ProtocolHelper_Sprig.ProtocolType_Sprig,
        firstContent_Sprig: String,
        secondProtocol_Sprig: ProtocolHelper_Sprig.ProtocolType_Sprig,
        secondContent_Sprig: String,
        prefixLength_Sprig: Int,
        firstTitleLength_Sprig: Int,
        separatorLength_Sprig: Int,
        secondTitleLength_Sprig: Int,
        viewController_Sprig: UIViewController
    ) {
        self.firstProtocol_Sprig = firstProtocol_Sprig
        self.firstContent_Sprig = firstContent_Sprig
        self.secondProtocol_Sprig = secondProtocol_Sprig
        self.secondContent_Sprig = secondContent_Sprig
        self.prefixLength_Sprig = prefixLength_Sprig
        self.firstTitleLength_Sprig = firstTitleLength_Sprig
        self.separatorLength_Sprig = separatorLength_Sprig
        self.secondTitleLength_Sprig = secondTitleLength_Sprig
        self.viewController_Sprig = viewController_Sprig
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Sprig(_:)))
    }
    
    @objc private func handleTap_Sprig(_ gesture: UITapGestureRecognizer) {
        guard let label_Sprig = gesture.view as? UILabel,
              let attributedText_Sprig = label_Sprig.attributedText,
              let viewController_Sprig = viewController_Sprig else { return }
        
        // 计算点击位置
        let location_Sprig = gesture.location(in: label_Sprig)
        
        // 创建文本容器和布局管理器
        let textStorage_Sprig = NSTextStorage(attributedString: attributedText_Sprig)
        let layoutManager_Sprig = NSLayoutManager()
        let textContainer_Sprig = NSTextContainer(size: label_Sprig.bounds.size)
        
        layoutManager_Sprig.addTextContainer(textContainer_Sprig)
        textStorage_Sprig.addLayoutManager(layoutManager_Sprig)
        
        textContainer_Sprig.lineFragmentPadding = 0
        textContainer_Sprig.maximumNumberOfLines = label_Sprig.numberOfLines
        textContainer_Sprig.lineBreakMode = label_Sprig.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Sprig = layoutManager_Sprig.characterIndex(
            for: location_Sprig,
            in: textContainer_Sprig,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Sprig = prefixLength_Sprig
        let firstLinkEnd_Sprig = firstLinkStart_Sprig + firstTitleLength_Sprig
        
        let secondLinkStart_Sprig = firstLinkEnd_Sprig + separatorLength_Sprig
        let secondLinkEnd_Sprig = secondLinkStart_Sprig + secondTitleLength_Sprig
        
        if characterIndex_Sprig >= firstLinkStart_Sprig && characterIndex_Sprig < firstLinkEnd_Sprig {
            // 点击第一个协议
            ProtocolHelper_Sprig.showProtocol_Sprig(
                type_Sprig: firstProtocol_Sprig,
                content_Sprig: firstContent_Sprig,
                from: viewController_Sprig
            )
        } else if characterIndex_Sprig >= secondLinkStart_Sprig && characterIndex_Sprig < secondLinkEnd_Sprig {
            // 点击第二个协议
            ProtocolHelper_Sprig.showProtocol_Sprig(
                type_Sprig: secondProtocol_Sprig,
                content_Sprig: secondContent_Sprig,
                from: viewController_Sprig
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Sprig: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Sprig: ProtocolHelper_Sprig.ProtocolType_Sprig
    private let content_Sprig: String
    
    private var webView_Sprig: WKWebView?
    private var scrollView_Sprig: UIScrollView?
    private var activityIndicator_Sprig: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Sprig: Bool {
        return content_Sprig.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Sprig: Bool {
        return content_Sprig.hasSuffix(".png") || 
               content_Sprig.hasSuffix(".jpg") || 
               content_Sprig.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Sprig: ProtocolHelper_Sprig.ProtocolType_Sprig, content_Sprig: String) {
        self.protocolType_Sprig = type_Sprig
        self.content_Sprig = content_Sprig
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Sprig()
        loadContent_Sprig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Sprig() {
        view.backgroundColor = .white
        title = protocolType_Sprig.title_Sprig
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Sprig)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Sprig {
            setupWebView_Sprig()
            setupActivityIndicator_Sprig()
        } else {
            setupScrollView_Sprig()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Sprig() {
        let webView_Sprig = WKWebView()
        webView_Sprig.navigationDelegate = self
        view.addSubview(webView_Sprig)
        
        webView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Sprig = webView_Sprig
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Sprig() {
        let scrollView_Sprig = UIScrollView()
        scrollView_Sprig.showsVerticalScrollIndicator = true
        scrollView_Sprig.alwaysBounceVertical = true
        view.addSubview(scrollView_Sprig)
        
        scrollView_Sprig.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Sprig = scrollView_Sprig
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Sprig() {
        let indicator_Sprig = UIActivityIndicatorView(style: .large)
        indicator_Sprig.color = .gray
        view.addSubview(indicator_Sprig)
        
        indicator_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Sprig = indicator_Sprig
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Sprig() {
        if isRemoteURL_Sprig {
            loadWebContent_Sprig()
        } else if isImage_Sprig {
            loadImageContent_Sprig()
        } else {
            loadTextContent_Sprig()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Sprig() {
        guard let url_Sprig = URL(string: content_Sprig) else { return }
        
        activityIndicator_Sprig?.startAnimating()
        
        let request_Sprig = URLRequest(url: url_Sprig)
        webView_Sprig?.load(request_Sprig)
    }
    
    /// 加载图片内容
    private func loadImageContent_Sprig() {
        guard let scrollView_Sprig = scrollView_Sprig,
              let image_Sprig = UIImage(named: content_Sprig) else { return }
        
        let imageView_Sprig = UIImageView()
        imageView_Sprig.contentMode = .scaleAspectFit
        imageView_Sprig.image = image_Sprig
        scrollView_Sprig.addSubview(imageView_Sprig)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Sprig = view.bounds.width
        let imageRatio_Sprig = image_Sprig.size.height / image_Sprig.size.width
        let displayHeight_Sprig = screenWidth_Sprig * imageRatio_Sprig
        
        imageView_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Sprig)
            make.height.equalTo(displayHeight_Sprig)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Sprig() {
        guard let scrollView_Sprig = scrollView_Sprig else { return }
        
        let textLabel_Sprig = UILabel()
        textLabel_Sprig.text = content_Sprig
        textLabel_Sprig.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Sprig.textColor = .black
        textLabel_Sprig.numberOfLines = 0
        scrollView_Sprig.addSubview(textLabel_Sprig)
        
        textLabel_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Sprig() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Sprig: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Sprig?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Sprig?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Sprig?.stopAnimating()
        Utils_Sprig.showError_Sprig(message_Sprig: "Failed to load content")
    }
}
