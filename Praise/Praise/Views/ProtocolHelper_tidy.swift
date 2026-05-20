import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Tidy {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Tidy {
        case terms_Tidy       // 服务条款
        case privacy_Tidy     // 隐私政策
        case eula_Tidy        // 最终用户许可协议
        case custom_Tidy(String) // 自定义协议
        
        /// 获取协议标题
        var title_Tidy: String {
            switch self {
            case .terms_Tidy:
                return "Terms of Service"
            case .privacy_Tidy:
                return "Privacy Policy"
            case .eula_Tidy:
                return "EULA"
            case .custom_Tidy(let title_Tidy):
                return title_Tidy
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Tidy {
        /// 普通文本颜色
        var textColor_Tidy: UIColor
        /// 链接文本颜色
        var linkColor_Tidy: UIColor
        /// 字体大小
        var fontSize_Tidy: CGFloat
        /// 字体粗细
        var fontWeight_Tidy: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Tidy: Bool
        /// 前缀文本
        var prefixText_Tidy: String
        /// 分隔符文本
        var separatorText_Tidy: String
        
        /// 默认初始化
        init(
            textColor_Tidy: UIColor = UIColor.gray,
            linkColor_Tidy: UIColor = UIColor.black,
            fontSize_Tidy: CGFloat = 12,
            fontWeight_Tidy: UIFont.Weight = .regular,
            hasUnderline_Tidy: Bool = true,
            prefixText_Tidy: String = "By continuing you agree with ",
            separatorText_Tidy: String = " & "
        ) {
            self.textColor_Tidy = textColor_Tidy
            self.linkColor_Tidy = linkColor_Tidy
            self.fontSize_Tidy = fontSize_Tidy
            self.fontWeight_Tidy = fontWeight_Tidy
            self.hasUnderline_Tidy = hasUnderline_Tidy
            self.prefixText_Tidy = prefixText_Tidy
            self.separatorText_Tidy = separatorText_Tidy
        }
        
        /// 浅色主题配置
        static func light_Tidy() -> ProtocolTextConfig_Tidy {
            return ProtocolTextConfig_Tidy(
                textColor_Tidy: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Tidy: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Tidy() -> ProtocolTextConfig_Tidy {
            return ProtocolTextConfig_Tidy(
                textColor_Tidy: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Tidy: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Tidy: 协议类型
    ///   - content_Tidy: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Tidy: 当前视图控制器
    static func showProtocol_Tidy(
        type_Tidy: ProtocolType_Tidy,
        content_Tidy: String,
        from viewController_Tidy: UIViewController
    ) {
        let protocolVC_Tidy = ProtocolViewController_Tidy(
            type_Tidy: type_Tidy,
            content_Tidy: content_Tidy
        )
        viewController_Tidy.navigationController?.pushViewController(
            protocolVC_Tidy,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Tidy: 第一个协议类型
    ///   - firstContent_Tidy: 第一个协议内容
    ///   - secondProtocol_Tidy: 第二个协议类型
    ///   - secondContent_Tidy: 第二个协议内容
    ///   - config_Tidy: 文本配置
    ///   - viewController_Tidy: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Tidy(
        firstProtocol_Tidy: ProtocolType_Tidy = .terms_Tidy,
        firstContent_Tidy: String,
        secondProtocol_Tidy: ProtocolType_Tidy = .privacy_Tidy,
        secondContent_Tidy: String,
        config_Tidy: ProtocolTextConfig_Tidy = .light_Tidy(),
        from viewController_Tidy: UIViewController
    ) -> UILabel {
        let label_Tidy = UILabel()
        label_Tidy.numberOfLines = 0
        label_Tidy.textAlignment = .center
        label_Tidy.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Tidy = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Tidy: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Tidy.fontSize_Tidy, weight: config_Tidy.fontWeight_Tidy),
            .foregroundColor: config_Tidy.textColor_Tidy
        ]
        attributedString_Tidy.append(NSAttributedString(
            string: config_Tidy.prefixText_Tidy,
            attributes: prefixAttributes_Tidy
        ))
        
        // 第一个协议链接
        var linkAttributes_Tidy: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Tidy.fontSize_Tidy, weight: config_Tidy.fontWeight_Tidy),
            .foregroundColor: config_Tidy.linkColor_Tidy
        ]
        if config_Tidy.hasUnderline_Tidy {
            linkAttributes_Tidy[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Tidy[.underlineColor] = config_Tidy.linkColor_Tidy
        }
        
        let firstProtocolString_Tidy = NSAttributedString(
            string: firstProtocol_Tidy.title_Tidy,
            attributes: linkAttributes_Tidy
        )
        attributedString_Tidy.append(firstProtocolString_Tidy)
        
        // 分隔符
        attributedString_Tidy.append(NSAttributedString(
            string: config_Tidy.separatorText_Tidy,
            attributes: prefixAttributes_Tidy
        ))
        
        // 第二个协议链接
        let secondProtocolString_Tidy = NSAttributedString(
            string: secondProtocol_Tidy.title_Tidy + ".",
            attributes: linkAttributes_Tidy
        )
        attributedString_Tidy.append(secondProtocolString_Tidy)
        
        label_Tidy.attributedText = attributedString_Tidy
        
        // 添加点击手势
        let tapGesture_Tidy = ProtocolTextTapGesture_Tidy(
            firstProtocol_Tidy: firstProtocol_Tidy,
            firstContent_Tidy: firstContent_Tidy,
            secondProtocol_Tidy: secondProtocol_Tidy,
            secondContent_Tidy: secondContent_Tidy,
            prefixLength_Tidy: config_Tidy.prefixText_Tidy.count,
            firstTitleLength_Tidy: firstProtocol_Tidy.title_Tidy.count,
            separatorLength_Tidy: config_Tidy.separatorText_Tidy.count,
            secondTitleLength_Tidy: secondProtocol_Tidy.title_Tidy.count + 1,
            viewController_Tidy: viewController_Tidy
        )
        label_Tidy.addGestureRecognizer(tapGesture_Tidy)
        
        return label_Tidy
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Tidy: UITapGestureRecognizer {
    
    private let firstProtocol_Tidy: ProtocolHelper_Tidy.ProtocolType_Tidy
    private let firstContent_Tidy: String
    private let secondProtocol_Tidy: ProtocolHelper_Tidy.ProtocolType_Tidy
    private let secondContent_Tidy: String
    private let prefixLength_Tidy: Int
    private let firstTitleLength_Tidy: Int
    private let separatorLength_Tidy: Int
    private let secondTitleLength_Tidy: Int
    private weak var viewController_Tidy: UIViewController?
    
    init(
        firstProtocol_Tidy: ProtocolHelper_Tidy.ProtocolType_Tidy,
        firstContent_Tidy: String,
        secondProtocol_Tidy: ProtocolHelper_Tidy.ProtocolType_Tidy,
        secondContent_Tidy: String,
        prefixLength_Tidy: Int,
        firstTitleLength_Tidy: Int,
        separatorLength_Tidy: Int,
        secondTitleLength_Tidy: Int,
        viewController_Tidy: UIViewController
    ) {
        self.firstProtocol_Tidy = firstProtocol_Tidy
        self.firstContent_Tidy = firstContent_Tidy
        self.secondProtocol_Tidy = secondProtocol_Tidy
        self.secondContent_Tidy = secondContent_Tidy
        self.prefixLength_Tidy = prefixLength_Tidy
        self.firstTitleLength_Tidy = firstTitleLength_Tidy
        self.separatorLength_Tidy = separatorLength_Tidy
        self.secondTitleLength_Tidy = secondTitleLength_Tidy
        self.viewController_Tidy = viewController_Tidy
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Tidy(_:)))
    }
    
    @objc private func handleTap_Tidy(_ gesture: UITapGestureRecognizer) {
        guard let label_Tidy = gesture.view as? UILabel,
              let attributedText_Tidy = label_Tidy.attributedText,
              let viewController_Tidy = viewController_Tidy else { return }
        
        // 计算点击位置
        let location_Tidy = gesture.location(in: label_Tidy)
        
        // 创建文本容器和布局管理器
        let textStorage_Tidy = NSTextStorage(attributedString: attributedText_Tidy)
        let layoutManager_Tidy = NSLayoutManager()
        let textContainer_Tidy = NSTextContainer(size: label_Tidy.bounds.size)
        
        layoutManager_Tidy.addTextContainer(textContainer_Tidy)
        textStorage_Tidy.addLayoutManager(layoutManager_Tidy)
        
        textContainer_Tidy.lineFragmentPadding = 0
        textContainer_Tidy.maximumNumberOfLines = label_Tidy.numberOfLines
        textContainer_Tidy.lineBreakMode = label_Tidy.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Tidy = layoutManager_Tidy.characterIndex(
            for: location_Tidy,
            in: textContainer_Tidy,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Tidy = prefixLength_Tidy
        let firstLinkEnd_Tidy = firstLinkStart_Tidy + firstTitleLength_Tidy
        
        let secondLinkStart_Tidy = firstLinkEnd_Tidy + separatorLength_Tidy
        let secondLinkEnd_Tidy = secondLinkStart_Tidy + secondTitleLength_Tidy
        
        if characterIndex_Tidy >= firstLinkStart_Tidy && characterIndex_Tidy < firstLinkEnd_Tidy {
            // 点击第一个协议
            ProtocolHelper_Tidy.showProtocol_Tidy(
                type_Tidy: firstProtocol_Tidy,
                content_Tidy: firstContent_Tidy,
                from: viewController_Tidy
            )
        } else if characterIndex_Tidy >= secondLinkStart_Tidy && characterIndex_Tidy < secondLinkEnd_Tidy {
            // 点击第二个协议
            ProtocolHelper_Tidy.showProtocol_Tidy(
                type_Tidy: secondProtocol_Tidy,
                content_Tidy: secondContent_Tidy,
                from: viewController_Tidy
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Tidy: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Tidy: ProtocolHelper_Tidy.ProtocolType_Tidy
    private let content_Tidy: String
    
    private var webView_Tidy: WKWebView?
    private var scrollView_Tidy: UIScrollView?
    private var activityIndicator_Tidy: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Tidy: Bool {
        return content_Tidy.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Tidy: Bool {
        return content_Tidy.hasSuffix(".png") || 
               content_Tidy.hasSuffix(".jpg") || 
               content_Tidy.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Tidy: ProtocolHelper_Tidy.ProtocolType_Tidy, content_Tidy: String) {
        self.protocolType_Tidy = type_Tidy
        self.content_Tidy = content_Tidy
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Tidy()
        loadContent_Tidy()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 确保覆盖 isHidden 直接赋值的状态
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // 配置导航栏外观（白色背景 + 深色文字）
        let appearance_Tidy = UINavigationBarAppearance()
        appearance_Tidy.configureWithOpaqueBackground()
        appearance_Tidy.backgroundColor = .white
        appearance_Tidy.shadowColor = .clear
        appearance_Tidy.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1),
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance   = appearance_Tidy
        navigationController?.navigationBar.scrollEdgeAppearance = appearance_Tidy
        navigationController?.navigationBar.tintColor = UIColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 1)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 离开协议页时重新隐藏导航栏，还原登录/注册页的全屏效果
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - UI设置

    private func setupUI_Tidy() {
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1)
        title = protocolType_Tidy.title_Tidy

        // 返回按钮（系统箭头 + 文字）
        let backBtn_Tidy = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left", withConfiguration:
                UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
            style: .plain,
            target: self,
            action: #selector(backTapped_Tidy)
        )
        navigationItem.leftBarButtonItem = backBtn_Tidy
        
        if isRemoteURL_Tidy {
            setupWebView_Tidy()
            setupActivityIndicator_Tidy()
        } else {
            setupScrollView_Tidy()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Tidy() {
        let webView_Tidy = WKWebView()
        webView_Tidy.navigationDelegate = self
        view.addSubview(webView_Tidy)
        // 使用 safeAreaLayoutGuide 避免被导航栏遮挡
        webView_Tidy.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        self.webView_Tidy = webView_Tidy
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Tidy() {
        let scrollView_Tidy = UIScrollView()
        scrollView_Tidy.showsVerticalScrollIndicator = true
        scrollView_Tidy.alwaysBounceVertical = true
        view.addSubview(scrollView_Tidy)
        
        scrollView_Tidy.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Tidy = scrollView_Tidy
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Tidy() {
        let indicator_Tidy = UIActivityIndicatorView(style: .large)
        indicator_Tidy.color = .gray
        view.addSubview(indicator_Tidy)
        
        indicator_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Tidy = indicator_Tidy
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Tidy() {
        if isRemoteURL_Tidy {
            loadWebContent_Tidy()
        } else if isImage_Tidy {
            loadImageContent_Tidy()
        } else {
            loadTextContent_Tidy()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Tidy() {
        guard let url_Tidy = URL(string: content_Tidy) else { return }
        
        activityIndicator_Tidy?.startAnimating()
        
        let request_Tidy = URLRequest(url: url_Tidy)
        webView_Tidy?.load(request_Tidy)
    }
    
    /// 加载图片内容
    private func loadImageContent_Tidy() {
        guard let scrollView_Tidy = scrollView_Tidy,
              let image_Tidy = UIImage(named: content_Tidy) else { return }
        
        let imageView_Tidy = UIImageView()
        imageView_Tidy.contentMode = .scaleAspectFit
        imageView_Tidy.image = image_Tidy
        scrollView_Tidy.addSubview(imageView_Tidy)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Tidy = view.bounds.width
        let imageRatio_Tidy = image_Tidy.size.height / image_Tidy.size.width
        let displayHeight_Tidy = screenWidth_Tidy * imageRatio_Tidy
        
        imageView_Tidy.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Tidy)
            make.height.equalTo(displayHeight_Tidy)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Tidy() {
        guard let scrollView_Tidy = scrollView_Tidy else { return }
        
        let textLabel_Tidy = UILabel()
        textLabel_Tidy.text = content_Tidy
        textLabel_Tidy.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Tidy.textColor = .black
        textLabel_Tidy.numberOfLines = 0
        scrollView_Tidy.addSubview(textLabel_Tidy)
        
        textLabel_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Tidy() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Tidy: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Tidy?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Tidy?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Tidy?.stopAnimating()
        Utils_Tidy.showError_Tidy(message_Tidy: "Failed to load content")
    }
}
