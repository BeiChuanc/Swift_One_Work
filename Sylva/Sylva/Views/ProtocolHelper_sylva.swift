import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Sylva {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Sylva {
        case terms_Sylva       // 服务条款
        case privacy_Sylva     // 隐私政策
        case eula_Sylva        // 最终用户许可协议
        case custom_Sylva(String) // 自定义协议
        
        /// 获取协议标题
        var title_Sylva: String {
            switch self {
            case .terms_Sylva:
                return "Terms of Service"
            case .privacy_Sylva:
                return "Privacy Policy"
            case .eula_Sylva:
                return "EULA"
            case .custom_Sylva(let title_Sylva):
                return title_Sylva
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Sylva {
        /// 普通文本颜色
        var textColor_Sylva: UIColor
        /// 链接文本颜色
        var linkColor_Sylva: UIColor
        /// 字体大小
        var fontSize_Sylva: CGFloat
        /// 字体粗细
        var fontWeight_Sylva: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Sylva: Bool
        /// 前缀文本
        var prefixText_Sylva: String
        /// 分隔符文本
        var separatorText_Sylva: String
        
        /// 默认初始化
        init(
            textColor_Sylva: UIColor = UIColor.gray,
            linkColor_Sylva: UIColor = UIColor.black,
            fontSize_Sylva: CGFloat = 12,
            fontWeight_Sylva: UIFont.Weight = .regular,
            hasUnderline_Sylva: Bool = true,
            prefixText_Sylva: String = "By continuing you agree with ",
            separatorText_Sylva: String = " & "
        ) {
            self.textColor_Sylva = textColor_Sylva
            self.linkColor_Sylva = linkColor_Sylva
            self.fontSize_Sylva = fontSize_Sylva
            self.fontWeight_Sylva = fontWeight_Sylva
            self.hasUnderline_Sylva = hasUnderline_Sylva
            self.prefixText_Sylva = prefixText_Sylva
            self.separatorText_Sylva = separatorText_Sylva
        }
        
        /// 浅色主题配置
        static func light_Sylva() -> ProtocolTextConfig_Sylva {
            return ProtocolTextConfig_Sylva(
                textColor_Sylva: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Sylva: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Sylva() -> ProtocolTextConfig_Sylva {
            return ProtocolTextConfig_Sylva(
                textColor_Sylva: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Sylva: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Sylva: 协议类型
    ///   - content_Sylva: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Sylva: 当前视图控制器
    static func showProtocol_Sylva(
        type_Sylva: ProtocolType_Sylva,
        content_Sylva: String,
        from viewController_Sylva: UIViewController
    ) {
        let protocolVC_Sylva = ProtocolViewController_Sylva(
            type_Sylva: type_Sylva,
            content_Sylva: content_Sylva
        )
        viewController_Sylva.navigationController?.pushViewController(
            protocolVC_Sylva,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Sylva: 第一个协议类型
    ///   - firstContent_Sylva: 第一个协议内容
    ///   - secondProtocol_Sylva: 第二个协议类型
    ///   - secondContent_Sylva: 第二个协议内容
    ///   - config_Sylva: 文本配置
    ///   - viewController_Sylva: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Sylva(
        firstProtocol_Sylva: ProtocolType_Sylva = .terms_Sylva,
        firstContent_Sylva: String,
        secondProtocol_Sylva: ProtocolType_Sylva = .privacy_Sylva,
        secondContent_Sylva: String,
        config_Sylva: ProtocolTextConfig_Sylva = .light_Sylva(),
        from viewController_Sylva: UIViewController
    ) -> UILabel {
        let label_Sylva = UILabel()
        label_Sylva.numberOfLines = 0
        label_Sylva.textAlignment = .center
        label_Sylva.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Sylva = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Sylva: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Sylva.fontSize_Sylva, weight: config_Sylva.fontWeight_Sylva),
            .foregroundColor: config_Sylva.textColor_Sylva
        ]
        attributedString_Sylva.append(NSAttributedString(
            string: config_Sylva.prefixText_Sylva,
            attributes: prefixAttributes_Sylva
        ))
        
        // 第一个协议链接
        var linkAttributes_Sylva: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Sylva.fontSize_Sylva, weight: config_Sylva.fontWeight_Sylva),
            .foregroundColor: config_Sylva.linkColor_Sylva
        ]
        if config_Sylva.hasUnderline_Sylva {
            linkAttributes_Sylva[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Sylva[.underlineColor] = config_Sylva.linkColor_Sylva
        }
        
        let firstProtocolString_Sylva = NSAttributedString(
            string: firstProtocol_Sylva.title_Sylva,
            attributes: linkAttributes_Sylva
        )
        attributedString_Sylva.append(firstProtocolString_Sylva)
        
        // 分隔符
        attributedString_Sylva.append(NSAttributedString(
            string: config_Sylva.separatorText_Sylva,
            attributes: prefixAttributes_Sylva
        ))
        
        // 第二个协议链接
        let secondProtocolString_Sylva = NSAttributedString(
            string: secondProtocol_Sylva.title_Sylva + ".",
            attributes: linkAttributes_Sylva
        )
        attributedString_Sylva.append(secondProtocolString_Sylva)
        
        label_Sylva.attributedText = attributedString_Sylva
        
        // 添加点击手势
        let tapGesture_Sylva = ProtocolTextTapGesture_Sylva(
            firstProtocol_Sylva: firstProtocol_Sylva,
            firstContent_Sylva: firstContent_Sylva,
            secondProtocol_Sylva: secondProtocol_Sylva,
            secondContent_Sylva: secondContent_Sylva,
            prefixLength_Sylva: config_Sylva.prefixText_Sylva.count,
            firstTitleLength_Sylva: firstProtocol_Sylva.title_Sylva.count,
            separatorLength_Sylva: config_Sylva.separatorText_Sylva.count,
            secondTitleLength_Sylva: secondProtocol_Sylva.title_Sylva.count + 1,
            viewController_Sylva: viewController_Sylva
        )
        label_Sylva.addGestureRecognizer(tapGesture_Sylva)
        
        return label_Sylva
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Sylva: UITapGestureRecognizer {
    
    private let firstProtocol_Sylva: ProtocolHelper_Sylva.ProtocolType_Sylva
    private let firstContent_Sylva: String
    private let secondProtocol_Sylva: ProtocolHelper_Sylva.ProtocolType_Sylva
    private let secondContent_Sylva: String
    private let prefixLength_Sylva: Int
    private let firstTitleLength_Sylva: Int
    private let separatorLength_Sylva: Int
    private let secondTitleLength_Sylva: Int
    private weak var viewController_Sylva: UIViewController?
    
    init(
        firstProtocol_Sylva: ProtocolHelper_Sylva.ProtocolType_Sylva,
        firstContent_Sylva: String,
        secondProtocol_Sylva: ProtocolHelper_Sylva.ProtocolType_Sylva,
        secondContent_Sylva: String,
        prefixLength_Sylva: Int,
        firstTitleLength_Sylva: Int,
        separatorLength_Sylva: Int,
        secondTitleLength_Sylva: Int,
        viewController_Sylva: UIViewController
    ) {
        self.firstProtocol_Sylva = firstProtocol_Sylva
        self.firstContent_Sylva = firstContent_Sylva
        self.secondProtocol_Sylva = secondProtocol_Sylva
        self.secondContent_Sylva = secondContent_Sylva
        self.prefixLength_Sylva = prefixLength_Sylva
        self.firstTitleLength_Sylva = firstTitleLength_Sylva
        self.separatorLength_Sylva = separatorLength_Sylva
        self.secondTitleLength_Sylva = secondTitleLength_Sylva
        self.viewController_Sylva = viewController_Sylva
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Sylva(_:)))
    }
    
    @objc private func handleTap_Sylva(_ gesture: UITapGestureRecognizer) {
        guard let label_Sylva = gesture.view as? UILabel,
              let attributedText_Sylva = label_Sylva.attributedText,
              let viewController_Sylva = viewController_Sylva else { return }
        
        // 计算点击位置
        let location_Sylva = gesture.location(in: label_Sylva)
        
        // 创建文本容器和布局管理器
        let textStorage_Sylva = NSTextStorage(attributedString: attributedText_Sylva)
        let layoutManager_Sylva = NSLayoutManager()
        let textContainer_Sylva = NSTextContainer(size: label_Sylva.bounds.size)
        
        layoutManager_Sylva.addTextContainer(textContainer_Sylva)
        textStorage_Sylva.addLayoutManager(layoutManager_Sylva)
        
        textContainer_Sylva.lineFragmentPadding = 0
        textContainer_Sylva.maximumNumberOfLines = label_Sylva.numberOfLines
        textContainer_Sylva.lineBreakMode = label_Sylva.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Sylva = layoutManager_Sylva.characterIndex(
            for: location_Sylva,
            in: textContainer_Sylva,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Sylva = prefixLength_Sylva
        let firstLinkEnd_Sylva = firstLinkStart_Sylva + firstTitleLength_Sylva
        
        let secondLinkStart_Sylva = firstLinkEnd_Sylva + separatorLength_Sylva
        let secondLinkEnd_Sylva = secondLinkStart_Sylva + secondTitleLength_Sylva
        
        if characterIndex_Sylva >= firstLinkStart_Sylva && characterIndex_Sylva < firstLinkEnd_Sylva {
            // 点击第一个协议
            ProtocolHelper_Sylva.showProtocol_Sylva(
                type_Sylva: firstProtocol_Sylva,
                content_Sylva: firstContent_Sylva,
                from: viewController_Sylva
            )
        } else if characterIndex_Sylva >= secondLinkStart_Sylva && characterIndex_Sylva < secondLinkEnd_Sylva {
            // 点击第二个协议
            ProtocolHelper_Sylva.showProtocol_Sylva(
                type_Sylva: secondProtocol_Sylva,
                content_Sylva: secondContent_Sylva,
                from: viewController_Sylva
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Sylva: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Sylva: ProtocolHelper_Sylva.ProtocolType_Sylva
    private let content_Sylva: String
    
    private var webView_Sylva: WKWebView?
    private var scrollView_Sylva: UIScrollView?
    private var activityIndicator_Sylva: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Sylva: Bool {
        return content_Sylva.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Sylva: Bool {
        return content_Sylva.hasSuffix(".png") || 
               content_Sylva.hasSuffix(".jpg") || 
               content_Sylva.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Sylva: ProtocolHelper_Sylva.ProtocolType_Sylva, content_Sylva: String) {
        self.protocolType_Sylva = type_Sylva
        self.content_Sylva = content_Sylva
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Sylva()
        loadContent_Sylva()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Sylva() {
        view.backgroundColor = .white
        title = protocolType_Sylva.title_Sylva
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Sylva)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Sylva {
            setupWebView_Sylva()
            setupActivityIndicator_Sylva()
        } else {
            setupScrollView_Sylva()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Sylva() {
        let webView_Sylva = WKWebView()
        webView_Sylva.navigationDelegate = self
        view.addSubview(webView_Sylva)
        
        webView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Sylva = webView_Sylva
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Sylva() {
        let scrollView_Sylva = UIScrollView()
        scrollView_Sylva.showsVerticalScrollIndicator = true
        scrollView_Sylva.alwaysBounceVertical = true
        view.addSubview(scrollView_Sylva)
        
        scrollView_Sylva.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Sylva = scrollView_Sylva
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Sylva() {
        let indicator_Sylva = UIActivityIndicatorView(style: .large)
        indicator_Sylva.color = .gray
        view.addSubview(indicator_Sylva)
        
        indicator_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Sylva = indicator_Sylva
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Sylva() {
        if isRemoteURL_Sylva {
            loadWebContent_Sylva()
        } else if isImage_Sylva {
            loadImageContent_Sylva()
        } else {
            loadTextContent_Sylva()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Sylva() {
        guard let url_Sylva = URL(string: content_Sylva) else { return }
        
        activityIndicator_Sylva?.startAnimating()
        
        let request_Sylva = URLRequest(url: url_Sylva)
        webView_Sylva?.load(request_Sylva)
    }
    
    /// 加载图片内容
    private func loadImageContent_Sylva() {
        guard let scrollView_Sylva = scrollView_Sylva,
              let image_Sylva = UIImage(named: content_Sylva) else { return }
        
        let imageView_Sylva = UIImageView()
        imageView_Sylva.contentMode = .scaleAspectFit
        imageView_Sylva.image = image_Sylva
        scrollView_Sylva.addSubview(imageView_Sylva)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Sylva = view.bounds.width
        let imageRatio_Sylva = image_Sylva.size.height / image_Sylva.size.width
        let displayHeight_Sylva = screenWidth_Sylva * imageRatio_Sylva
        
        imageView_Sylva.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Sylva)
            make.height.equalTo(displayHeight_Sylva)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Sylva() {
        guard let scrollView_Sylva = scrollView_Sylva else { return }
        
        let textLabel_Sylva = UILabel()
        textLabel_Sylva.text = content_Sylva
        textLabel_Sylva.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Sylva.textColor = .black
        textLabel_Sylva.numberOfLines = 0
        scrollView_Sylva.addSubview(textLabel_Sylva)
        
        textLabel_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Sylva() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Sylva: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Sylva?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Sylva?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Sylva?.stopAnimating()
        Utils_Sylva.showError_Sylva(message_Sylva: "Failed to load content")
    }
}
