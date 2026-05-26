import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Niche {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Niche {
        case terms_Niche       // 服务条款
        case privacy_Niche     // 隐私政策
        case eula_Niche        // 最终用户许可协议
        case custom_Niche(String) // 自定义协议
        
        /// 获取协议标题
        var title_Niche: String {
            switch self {
            case .terms_Niche:
                return "Terms of Service"
            case .privacy_Niche:
                return "Privacy Policy"
            case .eula_Niche:
                return "EULA"
            case .custom_Niche(let title_Niche):
                return title_Niche
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Niche {
        /// 普通文本颜色
        var textColor_Niche: UIColor
        /// 链接文本颜色
        var linkColor_Niche: UIColor
        /// 字体大小
        var fontSize_Niche: CGFloat
        /// 字体粗细
        var fontWeight_Niche: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Niche: Bool
        /// 前缀文本
        var prefixText_Niche: String
        /// 分隔符文本
        var separatorText_Niche: String
        
        /// 默认初始化
        init(
            textColor_Niche: UIColor = UIColor.gray,
            linkColor_Niche: UIColor = UIColor.black,
            fontSize_Niche: CGFloat = 12,
            fontWeight_Niche: UIFont.Weight = .regular,
            hasUnderline_Niche: Bool = true,
            prefixText_Niche: String = "By continuing you agree with ",
            separatorText_Niche: String = " & "
        ) {
            self.textColor_Niche = textColor_Niche
            self.linkColor_Niche = linkColor_Niche
            self.fontSize_Niche = fontSize_Niche
            self.fontWeight_Niche = fontWeight_Niche
            self.hasUnderline_Niche = hasUnderline_Niche
            self.prefixText_Niche = prefixText_Niche
            self.separatorText_Niche = separatorText_Niche
        }
        
        /// 浅色主题配置
        static func light_Niche() -> ProtocolTextConfig_Niche {
            return ProtocolTextConfig_Niche(
                textColor_Niche: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Niche: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Niche() -> ProtocolTextConfig_Niche {
            return ProtocolTextConfig_Niche(
                textColor_Niche: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Niche: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Niche: 协议类型
    ///   - content_Niche: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Niche: 当前视图控制器
    static func showProtocol_Niche(
        type_Niche: ProtocolType_Niche,
        content_Niche: String,
        from viewController_Niche: UIViewController
    ) {
        let protocolVC_Niche = ProtocolViewController_Niche(
            type_Niche: type_Niche,
            content_Niche: content_Niche
        )
        viewController_Niche.navigationController?.pushViewController(
            protocolVC_Niche,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Niche: 第一个协议类型
    ///   - firstContent_Niche: 第一个协议内容
    ///   - secondProtocol_Niche: 第二个协议类型
    ///   - secondContent_Niche: 第二个协议内容
    ///   - config_Niche: 文本配置
    ///   - viewController_Niche: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Niche(
        firstProtocol_Niche: ProtocolType_Niche = .terms_Niche,
        firstContent_Niche: String,
        secondProtocol_Niche: ProtocolType_Niche = .privacy_Niche,
        secondContent_Niche: String,
        config_Niche: ProtocolTextConfig_Niche = .light_Niche(),
        from viewController_Niche: UIViewController
    ) -> UILabel {
        let label_Niche = UILabel()
        label_Niche.numberOfLines = 0
        label_Niche.textAlignment = .center
        label_Niche.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Niche = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Niche: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Niche.fontSize_Niche, weight: config_Niche.fontWeight_Niche),
            .foregroundColor: config_Niche.textColor_Niche
        ]
        attributedString_Niche.append(NSAttributedString(
            string: config_Niche.prefixText_Niche,
            attributes: prefixAttributes_Niche
        ))
        
        // 第一个协议链接
        var linkAttributes_Niche: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Niche.fontSize_Niche, weight: config_Niche.fontWeight_Niche),
            .foregroundColor: config_Niche.linkColor_Niche
        ]
        if config_Niche.hasUnderline_Niche {
            linkAttributes_Niche[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Niche[.underlineColor] = config_Niche.linkColor_Niche
        }
        
        let firstProtocolString_Niche = NSAttributedString(
            string: firstProtocol_Niche.title_Niche,
            attributes: linkAttributes_Niche
        )
        attributedString_Niche.append(firstProtocolString_Niche)
        
        // 分隔符
        attributedString_Niche.append(NSAttributedString(
            string: config_Niche.separatorText_Niche,
            attributes: prefixAttributes_Niche
        ))
        
        // 第二个协议链接
        let secondProtocolString_Niche = NSAttributedString(
            string: secondProtocol_Niche.title_Niche + ".",
            attributes: linkAttributes_Niche
        )
        attributedString_Niche.append(secondProtocolString_Niche)
        
        label_Niche.attributedText = attributedString_Niche
        
        // 添加点击手势
        let tapGesture_Niche = ProtocolTextTapGesture_Niche(
            firstProtocol_Niche: firstProtocol_Niche,
            firstContent_Niche: firstContent_Niche,
            secondProtocol_Niche: secondProtocol_Niche,
            secondContent_Niche: secondContent_Niche,
            prefixLength_Niche: config_Niche.prefixText_Niche.count,
            firstTitleLength_Niche: firstProtocol_Niche.title_Niche.count,
            separatorLength_Niche: config_Niche.separatorText_Niche.count,
            secondTitleLength_Niche: secondProtocol_Niche.title_Niche.count + 1,
            viewController_Niche: viewController_Niche
        )
        label_Niche.addGestureRecognizer(tapGesture_Niche)
        
        return label_Niche
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Niche: UITapGestureRecognizer {
    
    private let firstProtocol_Niche: ProtocolHelper_Niche.ProtocolType_Niche
    private let firstContent_Niche: String
    private let secondProtocol_Niche: ProtocolHelper_Niche.ProtocolType_Niche
    private let secondContent_Niche: String
    private let prefixLength_Niche: Int
    private let firstTitleLength_Niche: Int
    private let separatorLength_Niche: Int
    private let secondTitleLength_Niche: Int
    private weak var viewController_Niche: UIViewController?
    
    init(
        firstProtocol_Niche: ProtocolHelper_Niche.ProtocolType_Niche,
        firstContent_Niche: String,
        secondProtocol_Niche: ProtocolHelper_Niche.ProtocolType_Niche,
        secondContent_Niche: String,
        prefixLength_Niche: Int,
        firstTitleLength_Niche: Int,
        separatorLength_Niche: Int,
        secondTitleLength_Niche: Int,
        viewController_Niche: UIViewController
    ) {
        self.firstProtocol_Niche = firstProtocol_Niche
        self.firstContent_Niche = firstContent_Niche
        self.secondProtocol_Niche = secondProtocol_Niche
        self.secondContent_Niche = secondContent_Niche
        self.prefixLength_Niche = prefixLength_Niche
        self.firstTitleLength_Niche = firstTitleLength_Niche
        self.separatorLength_Niche = separatorLength_Niche
        self.secondTitleLength_Niche = secondTitleLength_Niche
        self.viewController_Niche = viewController_Niche
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Niche(_:)))
    }
    
    @objc private func handleTap_Niche(_ gesture: UITapGestureRecognizer) {
        guard let label_Niche = gesture.view as? UILabel,
              let attributedText_Niche = label_Niche.attributedText,
              let viewController_Niche = viewController_Niche else { return }
        
        // 计算点击位置
        let location_Niche = gesture.location(in: label_Niche)
        
        // 创建文本容器和布局管理器
        let textStorage_Niche = NSTextStorage(attributedString: attributedText_Niche)
        let layoutManager_Niche = NSLayoutManager()
        let textContainer_Niche = NSTextContainer(size: label_Niche.bounds.size)
        
        layoutManager_Niche.addTextContainer(textContainer_Niche)
        textStorage_Niche.addLayoutManager(layoutManager_Niche)
        
        textContainer_Niche.lineFragmentPadding = 0
        textContainer_Niche.maximumNumberOfLines = label_Niche.numberOfLines
        textContainer_Niche.lineBreakMode = label_Niche.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Niche = layoutManager_Niche.characterIndex(
            for: location_Niche,
            in: textContainer_Niche,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Niche = prefixLength_Niche
        let firstLinkEnd_Niche = firstLinkStart_Niche + firstTitleLength_Niche
        
        let secondLinkStart_Niche = firstLinkEnd_Niche + separatorLength_Niche
        let secondLinkEnd_Niche = secondLinkStart_Niche + secondTitleLength_Niche
        
        if characterIndex_Niche >= firstLinkStart_Niche && characterIndex_Niche < firstLinkEnd_Niche {
            // 点击第一个协议
            ProtocolHelper_Niche.showProtocol_Niche(
                type_Niche: firstProtocol_Niche,
                content_Niche: firstContent_Niche,
                from: viewController_Niche
            )
        } else if characterIndex_Niche >= secondLinkStart_Niche && characterIndex_Niche < secondLinkEnd_Niche {
            // 点击第二个协议
            ProtocolHelper_Niche.showProtocol_Niche(
                type_Niche: secondProtocol_Niche,
                content_Niche: secondContent_Niche,
                from: viewController_Niche
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Niche: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Niche: ProtocolHelper_Niche.ProtocolType_Niche
    private let content_Niche: String
    
    private var webView_Niche: WKWebView?
    private var scrollView_Niche: UIScrollView?
    private var activityIndicator_Niche: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Niche: Bool {
        return content_Niche.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Niche: Bool {
        return content_Niche.hasSuffix(".png") || 
               content_Niche.hasSuffix(".jpg") || 
               content_Niche.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Niche: ProtocolHelper_Niche.ProtocolType_Niche, content_Niche: String) {
        self.protocolType_Niche = type_Niche
        self.content_Niche = content_Niche
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        loadContent_Niche()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Niche() {
        view.backgroundColor = .white
        title = protocolType_Niche.title_Niche
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Niche)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Niche {
            setupWebView_Niche()
            setupActivityIndicator_Niche()
        } else {
            setupScrollView_Niche()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Niche() {
        let webView_Niche = WKWebView()
        webView_Niche.navigationDelegate = self
        view.addSubview(webView_Niche)
        
        webView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Niche = webView_Niche
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Niche() {
        let scrollView_Niche = UIScrollView()
        scrollView_Niche.showsVerticalScrollIndicator = true
        scrollView_Niche.alwaysBounceVertical = true
        view.addSubview(scrollView_Niche)
        
        scrollView_Niche.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Niche = scrollView_Niche
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Niche() {
        let indicator_Niche = UIActivityIndicatorView(style: .large)
        indicator_Niche.color = .gray
        view.addSubview(indicator_Niche)
        
        indicator_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Niche = indicator_Niche
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Niche() {
        if isRemoteURL_Niche {
            loadWebContent_Niche()
        } else if isImage_Niche {
            loadImageContent_Niche()
        } else {
            loadTextContent_Niche()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Niche() {
        guard let url_Niche = URL(string: content_Niche) else { return }
        
        activityIndicator_Niche?.startAnimating()
        
        let request_Niche = URLRequest(url: url_Niche)
        webView_Niche?.load(request_Niche)
    }
    
    /// 加载图片内容
    private func loadImageContent_Niche() {
        guard let scrollView_Niche = scrollView_Niche,
              let image_Niche = UIImage(named: content_Niche) else { return }
        
        let imageView_Niche = UIImageView()
        imageView_Niche.contentMode = .scaleAspectFit
        imageView_Niche.image = image_Niche
        scrollView_Niche.addSubview(imageView_Niche)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Niche = view.bounds.width
        let imageRatio_Niche = image_Niche.size.height / image_Niche.size.width
        let displayHeight_Niche = screenWidth_Niche * imageRatio_Niche
        
        imageView_Niche.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Niche)
            make.height.equalTo(displayHeight_Niche)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Niche() {
        guard let scrollView_Niche = scrollView_Niche else { return }
        
        let textLabel_Niche = UILabel()
        textLabel_Niche.text = content_Niche
        textLabel_Niche.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Niche.textColor = .black
        textLabel_Niche.numberOfLines = 0
        scrollView_Niche.addSubview(textLabel_Niche)
        
        textLabel_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Niche() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Niche: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Niche?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Niche?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Niche?.stopAnimating()
        Utils_Niche.showError_Niche(message_Niche: "Failed to load content")
    }
}
