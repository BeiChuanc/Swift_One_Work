import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Bague {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Bague {
        case terms_Bague       // 服务条款
        case privacy_Bague     // 隐私政策
        case eula_Bague        // 最终用户许可协议
        case custom_Bague(String) // 自定义协议
        
        /// 获取协议标题
        var title_Bague: String {
            switch self {
            case .terms_Bague:
                return "Terms of Service"
            case .privacy_Bague:
                return "Privacy Policy"
            case .eula_Bague:
                return "EULA"
            case .custom_Bague(let title_Bague):
                return title_Bague
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Bague {
        /// 普通文本颜色
        var textColor_Bague: UIColor
        /// 链接文本颜色
        var linkColor_Bague: UIColor
        /// 字体大小
        var fontSize_Bague: CGFloat
        /// 字体粗细
        var fontWeight_Bague: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Bague: Bool
        /// 前缀文本
        var prefixText_Bague: String
        /// 分隔符文本
        var separatorText_Bague: String
        
        /// 默认初始化
        init(
            textColor_Bague: UIColor = UIColor.gray,
            linkColor_Bague: UIColor = UIColor.black,
            fontSize_Bague: CGFloat = 12,
            fontWeight_Bague: UIFont.Weight = .regular,
            hasUnderline_Bague: Bool = true,
            prefixText_Bague: String = "By continuing you agree with ",
            separatorText_Bague: String = " & "
        ) {
            self.textColor_Bague = textColor_Bague
            self.linkColor_Bague = linkColor_Bague
            self.fontSize_Bague = fontSize_Bague
            self.fontWeight_Bague = fontWeight_Bague
            self.hasUnderline_Bague = hasUnderline_Bague
            self.prefixText_Bague = prefixText_Bague
            self.separatorText_Bague = separatorText_Bague
        }
        
        /// 浅色主题配置
        static func light_Bague() -> ProtocolTextConfig_Bague {
            return ProtocolTextConfig_Bague(
                textColor_Bague: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Bague: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Bague() -> ProtocolTextConfig_Bague {
            return ProtocolTextConfig_Bague(
                textColor_Bague: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Bague: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Bague: 协议类型
    ///   - content_Bague: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Bague: 当前视图控制器
    static func showProtocol_Bague(
        type_Bague: ProtocolType_Bague,
        content_Bague: String,
        from viewController_Bague: UIViewController
    ) {
        let protocolVC_Bague = ProtocolViewController_Bague(
            type_Bague: type_Bague,
            content_Bague: content_Bague
        )
        viewController_Bague.navigationController?.pushViewController(
            protocolVC_Bague,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Bague: 第一个协议类型
    ///   - firstContent_Bague: 第一个协议内容
    ///   - secondProtocol_Bague: 第二个协议类型
    ///   - secondContent_Bague: 第二个协议内容
    ///   - config_Bague: 文本配置
    ///   - viewController_Bague: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Bague(
        firstProtocol_Bague: ProtocolType_Bague = .terms_Bague,
        firstContent_Bague: String,
        secondProtocol_Bague: ProtocolType_Bague = .privacy_Bague,
        secondContent_Bague: String,
        config_Bague: ProtocolTextConfig_Bague = .light_Bague(),
        from viewController_Bague: UIViewController
    ) -> UILabel {
        let label_Bague = UILabel()
        label_Bague.numberOfLines = 0
        label_Bague.textAlignment = .center
        label_Bague.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Bague = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Bague: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Bague.fontSize_Bague, weight: config_Bague.fontWeight_Bague),
            .foregroundColor: config_Bague.textColor_Bague
        ]
        attributedString_Bague.append(NSAttributedString(
            string: config_Bague.prefixText_Bague,
            attributes: prefixAttributes_Bague
        ))
        
        // 第一个协议链接
        var linkAttributes_Bague: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Bague.fontSize_Bague, weight: config_Bague.fontWeight_Bague),
            .foregroundColor: config_Bague.linkColor_Bague
        ]
        if config_Bague.hasUnderline_Bague {
            linkAttributes_Bague[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Bague[.underlineColor] = config_Bague.linkColor_Bague
        }
        
        let firstProtocolString_Bague = NSAttributedString(
            string: firstProtocol_Bague.title_Bague,
            attributes: linkAttributes_Bague
        )
        attributedString_Bague.append(firstProtocolString_Bague)
        
        // 分隔符
        attributedString_Bague.append(NSAttributedString(
            string: config_Bague.separatorText_Bague,
            attributes: prefixAttributes_Bague
        ))
        
        // 第二个协议链接
        let secondProtocolString_Bague = NSAttributedString(
            string: secondProtocol_Bague.title_Bague + ".",
            attributes: linkAttributes_Bague
        )
        attributedString_Bague.append(secondProtocolString_Bague)
        
        label_Bague.attributedText = attributedString_Bague
        
        // 添加点击手势
        let tapGesture_Bague = ProtocolTextTapGesture_Bague(
            firstProtocol_Bague: firstProtocol_Bague,
            firstContent_Bague: firstContent_Bague,
            secondProtocol_Bague: secondProtocol_Bague,
            secondContent_Bague: secondContent_Bague,
            prefixLength_Bague: config_Bague.prefixText_Bague.count,
            firstTitleLength_Bague: firstProtocol_Bague.title_Bague.count,
            separatorLength_Bague: config_Bague.separatorText_Bague.count,
            secondTitleLength_Bague: secondProtocol_Bague.title_Bague.count + 1,
            viewController_Bague: viewController_Bague
        )
        label_Bague.addGestureRecognizer(tapGesture_Bague)
        
        return label_Bague
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Bague: UITapGestureRecognizer {
    
    private let firstProtocol_Bague: ProtocolHelper_Bague.ProtocolType_Bague
    private let firstContent_Bague: String
    private let secondProtocol_Bague: ProtocolHelper_Bague.ProtocolType_Bague
    private let secondContent_Bague: String
    private let prefixLength_Bague: Int
    private let firstTitleLength_Bague: Int
    private let separatorLength_Bague: Int
    private let secondTitleLength_Bague: Int
    private weak var viewController_Bague: UIViewController?
    
    init(
        firstProtocol_Bague: ProtocolHelper_Bague.ProtocolType_Bague,
        firstContent_Bague: String,
        secondProtocol_Bague: ProtocolHelper_Bague.ProtocolType_Bague,
        secondContent_Bague: String,
        prefixLength_Bague: Int,
        firstTitleLength_Bague: Int,
        separatorLength_Bague: Int,
        secondTitleLength_Bague: Int,
        viewController_Bague: UIViewController
    ) {
        self.firstProtocol_Bague = firstProtocol_Bague
        self.firstContent_Bague = firstContent_Bague
        self.secondProtocol_Bague = secondProtocol_Bague
        self.secondContent_Bague = secondContent_Bague
        self.prefixLength_Bague = prefixLength_Bague
        self.firstTitleLength_Bague = firstTitleLength_Bague
        self.separatorLength_Bague = separatorLength_Bague
        self.secondTitleLength_Bague = secondTitleLength_Bague
        self.viewController_Bague = viewController_Bague
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Bague(_:)))
    }
    
    @objc private func handleTap_Bague(_ gesture: UITapGestureRecognizer) {
        guard let label_Bague = gesture.view as? UILabel,
              let attributedText_Bague = label_Bague.attributedText,
              let viewController_Bague = viewController_Bague else { return }
        
        // 计算点击位置
        let location_Bague = gesture.location(in: label_Bague)
        
        // 创建文本容器和布局管理器
        let textStorage_Bague = NSTextStorage(attributedString: attributedText_Bague)
        let layoutManager_Bague = NSLayoutManager()
        let textContainer_Bague = NSTextContainer(size: label_Bague.bounds.size)
        
        layoutManager_Bague.addTextContainer(textContainer_Bague)
        textStorage_Bague.addLayoutManager(layoutManager_Bague)
        
        textContainer_Bague.lineFragmentPadding = 0
        textContainer_Bague.maximumNumberOfLines = label_Bague.numberOfLines
        textContainer_Bague.lineBreakMode = label_Bague.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Bague = layoutManager_Bague.characterIndex(
            for: location_Bague,
            in: textContainer_Bague,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Bague = prefixLength_Bague
        let firstLinkEnd_Bague = firstLinkStart_Bague + firstTitleLength_Bague
        
        let secondLinkStart_Bague = firstLinkEnd_Bague + separatorLength_Bague
        let secondLinkEnd_Bague = secondLinkStart_Bague + secondTitleLength_Bague
        
        if characterIndex_Bague >= firstLinkStart_Bague && characterIndex_Bague < firstLinkEnd_Bague {
            // 点击第一个协议
            ProtocolHelper_Bague.showProtocol_Bague(
                type_Bague: firstProtocol_Bague,
                content_Bague: firstContent_Bague,
                from: viewController_Bague
            )
        } else if characterIndex_Bague >= secondLinkStart_Bague && characterIndex_Bague < secondLinkEnd_Bague {
            // 点击第二个协议
            ProtocolHelper_Bague.showProtocol_Bague(
                type_Bague: secondProtocol_Bague,
                content_Bague: secondContent_Bague,
                from: viewController_Bague
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Bague: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Bague: ProtocolHelper_Bague.ProtocolType_Bague
    private let content_Bague: String
    
    private var webView_Bague: WKWebView?
    private var scrollView_Bague: UIScrollView?
    private var activityIndicator_Bague: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Bague: Bool {
        return content_Bague.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Bague: Bool {
        return content_Bague.hasSuffix(".png") || 
               content_Bague.hasSuffix(".jpg") || 
               content_Bague.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Bague: ProtocolHelper_Bague.ProtocolType_Bague, content_Bague: String) {
        self.protocolType_Bague = type_Bague
        self.content_Bague = content_Bague
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        loadContent_Bague()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Bague() {
        view.backgroundColor = .white
        title = protocolType_Bague.title_Bague
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Bague)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Bague {
            setupWebView_Bague()
            setupActivityIndicator_Bague()
        } else {
            setupScrollView_Bague()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Bague() {
        let webView_Bague = WKWebView()
        webView_Bague.navigationDelegate = self
        view.addSubview(webView_Bague)
        
        webView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Bague = webView_Bague
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Bague() {
        let scrollView_Bague = UIScrollView()
        scrollView_Bague.showsVerticalScrollIndicator = true
        scrollView_Bague.alwaysBounceVertical = true
        view.addSubview(scrollView_Bague)
        
        scrollView_Bague.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Bague = scrollView_Bague
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Bague() {
        let indicator_Bague = UIActivityIndicatorView(style: .large)
        indicator_Bague.color = .gray
        view.addSubview(indicator_Bague)
        
        indicator_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Bague = indicator_Bague
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Bague() {
        if isRemoteURL_Bague {
            loadWebContent_Bague()
        } else if isImage_Bague {
            loadImageContent_Bague()
        } else {
            loadTextContent_Bague()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Bague() {
        guard let url_Bague = URL(string: content_Bague) else { return }
        
        activityIndicator_Bague?.startAnimating()
        
        let request_Bague = URLRequest(url: url_Bague)
        webView_Bague?.load(request_Bague)
    }
    
    /// 加载图片内容
    private func loadImageContent_Bague() {
        guard let scrollView_Bague = scrollView_Bague,
              let image_Bague = UIImage(named: content_Bague) else { return }
        
        let imageView_Bague = UIImageView()
        imageView_Bague.contentMode = .scaleAspectFit
        imageView_Bague.image = image_Bague
        scrollView_Bague.addSubview(imageView_Bague)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Bague = view.bounds.width
        let imageRatio_Bague = image_Bague.size.height / image_Bague.size.width
        let displayHeight_Bague = screenWidth_Bague * imageRatio_Bague
        
        imageView_Bague.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Bague)
            make.height.equalTo(displayHeight_Bague)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Bague() {
        guard let scrollView_Bague = scrollView_Bague else { return }
        
        let textLabel_Bague = UILabel()
        textLabel_Bague.text = content_Bague
        textLabel_Bague.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Bague.textColor = .black
        textLabel_Bague.numberOfLines = 0
        scrollView_Bague.addSubview(textLabel_Bague)
        
        textLabel_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Bague() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Bague: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Bague?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Bague?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Bague?.stopAnimating()
        Utils_Bague.showError_Bague(message_Bague: "Failed to load content")
    }
}
