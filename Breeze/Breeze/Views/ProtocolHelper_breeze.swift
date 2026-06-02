import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Breeze {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Breeze {
        case terms_Breeze       // 服务条款
        case privacy_Breeze     // 隐私政策
        case eula_Breeze        // 最终用户许可协议
        case custom_Breeze(String) // 自定义协议
        
        /// 获取协议标题
        var title_Breeze: String {
            switch self {
            case .terms_Breeze:
                return "Terms of Service"
            case .privacy_Breeze:
                return "Privacy Policy"
            case .eula_Breeze:
                return "EULA"
            case .custom_Breeze(let title_Breeze):
                return title_Breeze
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Breeze {
        /// 普通文本颜色
        var textColor_Breeze: UIColor
        /// 链接文本颜色
        var linkColor_Breeze: UIColor
        /// 字体大小
        var fontSize_Breeze: CGFloat
        /// 字体粗细
        var fontWeight_Breeze: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Breeze: Bool
        /// 前缀文本
        var prefixText_Breeze: String
        /// 分隔符文本
        var separatorText_Breeze: String
        
        /// 默认初始化
        init(
            textColor_Breeze: UIColor = UIColor.gray,
            linkColor_Breeze: UIColor = UIColor.black,
            fontSize_Breeze: CGFloat = 12,
            fontWeight_Breeze: UIFont.Weight = .regular,
            hasUnderline_Breeze: Bool = true,
            prefixText_Breeze: String = "By continuing you agree with ",
            separatorText_Breeze: String = " & "
        ) {
            self.textColor_Breeze = textColor_Breeze
            self.linkColor_Breeze = linkColor_Breeze
            self.fontSize_Breeze = fontSize_Breeze
            self.fontWeight_Breeze = fontWeight_Breeze
            self.hasUnderline_Breeze = hasUnderline_Breeze
            self.prefixText_Breeze = prefixText_Breeze
            self.separatorText_Breeze = separatorText_Breeze
        }
        
        /// 浅色主题配置
        static func light_Breeze() -> ProtocolTextConfig_Breeze {
            return ProtocolTextConfig_Breeze(
                textColor_Breeze: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Breeze: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Breeze() -> ProtocolTextConfig_Breeze {
            return ProtocolTextConfig_Breeze(
                textColor_Breeze: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Breeze: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Breeze: 协议类型
    ///   - content_Breeze: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Breeze: 当前视图控制器
    static func showProtocol_Breeze(
        type_Breeze: ProtocolType_Breeze,
        content_Breeze: String,
        from viewController_Breeze: UIViewController
    ) {
        let protocolVC_Breeze = ProtocolViewController_Breeze(
            type_Breeze: type_Breeze,
            content_Breeze: content_Breeze
        )
        viewController_Breeze.navigationController?.pushViewController(
            protocolVC_Breeze,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Breeze: 第一个协议类型
    ///   - firstContent_Breeze: 第一个协议内容
    ///   - secondProtocol_Breeze: 第二个协议类型
    ///   - secondContent_Breeze: 第二个协议内容
    ///   - config_Breeze: 文本配置
    ///   - viewController_Breeze: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Breeze(
        firstProtocol_Breeze: ProtocolType_Breeze = .terms_Breeze,
        firstContent_Breeze: String,
        secondProtocol_Breeze: ProtocolType_Breeze = .privacy_Breeze,
        secondContent_Breeze: String,
        config_Breeze: ProtocolTextConfig_Breeze = .light_Breeze(),
        from viewController_Breeze: UIViewController
    ) -> UILabel {
        let label_Breeze = UILabel()
        label_Breeze.numberOfLines = 0
        label_Breeze.textAlignment = .center
        label_Breeze.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Breeze = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Breeze: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Breeze.fontSize_Breeze, weight: config_Breeze.fontWeight_Breeze),
            .foregroundColor: config_Breeze.textColor_Breeze
        ]
        attributedString_Breeze.append(NSAttributedString(
            string: config_Breeze.prefixText_Breeze,
            attributes: prefixAttributes_Breeze
        ))
        
        // 第一个协议链接
        var linkAttributes_Breeze: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Breeze.fontSize_Breeze, weight: config_Breeze.fontWeight_Breeze),
            .foregroundColor: config_Breeze.linkColor_Breeze
        ]
        if config_Breeze.hasUnderline_Breeze {
            linkAttributes_Breeze[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Breeze[.underlineColor] = config_Breeze.linkColor_Breeze
        }
        
        let firstProtocolString_Breeze = NSAttributedString(
            string: firstProtocol_Breeze.title_Breeze,
            attributes: linkAttributes_Breeze
        )
        attributedString_Breeze.append(firstProtocolString_Breeze)
        
        // 分隔符
        attributedString_Breeze.append(NSAttributedString(
            string: config_Breeze.separatorText_Breeze,
            attributes: prefixAttributes_Breeze
        ))
        
        // 第二个协议链接
        let secondProtocolString_Breeze = NSAttributedString(
            string: secondProtocol_Breeze.title_Breeze + ".",
            attributes: linkAttributes_Breeze
        )
        attributedString_Breeze.append(secondProtocolString_Breeze)
        
        label_Breeze.attributedText = attributedString_Breeze
        
        // 添加点击手势
        let tapGesture_Breeze = ProtocolTextTapGesture_Breeze(
            firstProtocol_Breeze: firstProtocol_Breeze,
            firstContent_Breeze: firstContent_Breeze,
            secondProtocol_Breeze: secondProtocol_Breeze,
            secondContent_Breeze: secondContent_Breeze,
            prefixLength_Breeze: config_Breeze.prefixText_Breeze.count,
            firstTitleLength_Breeze: firstProtocol_Breeze.title_Breeze.count,
            separatorLength_Breeze: config_Breeze.separatorText_Breeze.count,
            secondTitleLength_Breeze: secondProtocol_Breeze.title_Breeze.count + 1,
            viewController_Breeze: viewController_Breeze
        )
        label_Breeze.addGestureRecognizer(tapGesture_Breeze)
        
        return label_Breeze
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Breeze: UITapGestureRecognizer {
    
    private let firstProtocol_Breeze: ProtocolHelper_Breeze.ProtocolType_Breeze
    private let firstContent_Breeze: String
    private let secondProtocol_Breeze: ProtocolHelper_Breeze.ProtocolType_Breeze
    private let secondContent_Breeze: String
    private let prefixLength_Breeze: Int
    private let firstTitleLength_Breeze: Int
    private let separatorLength_Breeze: Int
    private let secondTitleLength_Breeze: Int
    private weak var viewController_Breeze: UIViewController?
    
    init(
        firstProtocol_Breeze: ProtocolHelper_Breeze.ProtocolType_Breeze,
        firstContent_Breeze: String,
        secondProtocol_Breeze: ProtocolHelper_Breeze.ProtocolType_Breeze,
        secondContent_Breeze: String,
        prefixLength_Breeze: Int,
        firstTitleLength_Breeze: Int,
        separatorLength_Breeze: Int,
        secondTitleLength_Breeze: Int,
        viewController_Breeze: UIViewController
    ) {
        self.firstProtocol_Breeze = firstProtocol_Breeze
        self.firstContent_Breeze = firstContent_Breeze
        self.secondProtocol_Breeze = secondProtocol_Breeze
        self.secondContent_Breeze = secondContent_Breeze
        self.prefixLength_Breeze = prefixLength_Breeze
        self.firstTitleLength_Breeze = firstTitleLength_Breeze
        self.separatorLength_Breeze = separatorLength_Breeze
        self.secondTitleLength_Breeze = secondTitleLength_Breeze
        self.viewController_Breeze = viewController_Breeze
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Breeze(_:)))
    }
    
    @objc private func handleTap_Breeze(_ gesture: UITapGestureRecognizer) {
        guard let label_Breeze = gesture.view as? UILabel,
              let attributedText_Breeze = label_Breeze.attributedText,
              let viewController_Breeze = viewController_Breeze else { return }
        
        // 计算点击位置
        let location_Breeze = gesture.location(in: label_Breeze)
        
        // 创建文本容器和布局管理器
        let textStorage_Breeze = NSTextStorage(attributedString: attributedText_Breeze)
        let layoutManager_Breeze = NSLayoutManager()
        let textContainer_Breeze = NSTextContainer(size: label_Breeze.bounds.size)
        
        layoutManager_Breeze.addTextContainer(textContainer_Breeze)
        textStorage_Breeze.addLayoutManager(layoutManager_Breeze)
        
        textContainer_Breeze.lineFragmentPadding = 0
        textContainer_Breeze.maximumNumberOfLines = label_Breeze.numberOfLines
        textContainer_Breeze.lineBreakMode = label_Breeze.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Breeze = layoutManager_Breeze.characterIndex(
            for: location_Breeze,
            in: textContainer_Breeze,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Breeze = prefixLength_Breeze
        let firstLinkEnd_Breeze = firstLinkStart_Breeze + firstTitleLength_Breeze
        
        let secondLinkStart_Breeze = firstLinkEnd_Breeze + separatorLength_Breeze
        let secondLinkEnd_Breeze = secondLinkStart_Breeze + secondTitleLength_Breeze
        
        if characterIndex_Breeze >= firstLinkStart_Breeze && characterIndex_Breeze < firstLinkEnd_Breeze {
            // 点击第一个协议
            ProtocolHelper_Breeze.showProtocol_Breeze(
                type_Breeze: firstProtocol_Breeze,
                content_Breeze: firstContent_Breeze,
                from: viewController_Breeze
            )
        } else if characterIndex_Breeze >= secondLinkStart_Breeze && characterIndex_Breeze < secondLinkEnd_Breeze {
            // 点击第二个协议
            ProtocolHelper_Breeze.showProtocol_Breeze(
                type_Breeze: secondProtocol_Breeze,
                content_Breeze: secondContent_Breeze,
                from: viewController_Breeze
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Breeze: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Breeze: ProtocolHelper_Breeze.ProtocolType_Breeze
    private let content_Breeze: String
    
    private var webView_Breeze: WKWebView?
    private var scrollView_Breeze: UIScrollView?
    private var activityIndicator_Breeze: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Breeze: Bool {
        return content_Breeze.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Breeze: Bool {
        return content_Breeze.hasSuffix(".png") || 
               content_Breeze.hasSuffix(".jpg") || 
               content_Breeze.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Breeze: ProtocolHelper_Breeze.ProtocolType_Breeze, content_Breeze: String) {
        self.protocolType_Breeze = type_Breeze
        self.content_Breeze = content_Breeze
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        loadContent_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Breeze() {
        view.backgroundColor = .white
        title = protocolType_Breeze.title_Breeze
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Breeze)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Breeze {
            setupWebView_Breeze()
            setupActivityIndicator_Breeze()
        } else {
            setupScrollView_Breeze()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Breeze() {
        let webView_Breeze = WKWebView()
        webView_Breeze.navigationDelegate = self
        view.addSubview(webView_Breeze)
        
        webView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Breeze = webView_Breeze
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Breeze() {
        let scrollView_Breeze = UIScrollView()
        scrollView_Breeze.showsVerticalScrollIndicator = true
        scrollView_Breeze.alwaysBounceVertical = true
        view.addSubview(scrollView_Breeze)
        
        scrollView_Breeze.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Breeze = scrollView_Breeze
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Breeze() {
        let indicator_Breeze = UIActivityIndicatorView(style: .large)
        indicator_Breeze.color = .gray
        view.addSubview(indicator_Breeze)
        
        indicator_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Breeze = indicator_Breeze
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Breeze() {
        if isRemoteURL_Breeze {
            loadWebContent_Breeze()
        } else if isImage_Breeze {
            loadImageContent_Breeze()
        } else {
            loadTextContent_Breeze()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Breeze() {
        guard let url_Breeze = URL(string: content_Breeze) else { return }
        
        activityIndicator_Breeze?.startAnimating()
        
        let request_Breeze = URLRequest(url: url_Breeze)
        webView_Breeze?.load(request_Breeze)
    }
    
    /// 加载图片内容
    private func loadImageContent_Breeze() {
        guard let scrollView_Breeze = scrollView_Breeze,
              let image_Breeze = UIImage(named: content_Breeze) else { return }
        
        let imageView_Breeze = UIImageView()
        imageView_Breeze.contentMode = .scaleAspectFit
        imageView_Breeze.image = image_Breeze
        scrollView_Breeze.addSubview(imageView_Breeze)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Breeze = view.bounds.width
        let imageRatio_Breeze = image_Breeze.size.height / image_Breeze.size.width
        let displayHeight_Breeze = screenWidth_Breeze * imageRatio_Breeze
        
        imageView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Breeze)
            make.height.equalTo(displayHeight_Breeze)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Breeze() {
        guard let scrollView_Breeze = scrollView_Breeze else { return }
        
        let textLabel_Breeze = UILabel()
        textLabel_Breeze.text = content_Breeze
        textLabel_Breeze.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Breeze.textColor = .black
        textLabel_Breeze.numberOfLines = 0
        scrollView_Breeze.addSubview(textLabel_Breeze)
        
        textLabel_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Breeze() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Breeze: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Breeze?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Breeze?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Breeze?.stopAnimating()
        Utils_Breeze.showError_Breeze(message_Breeze: "Failed to load content")
    }
}
