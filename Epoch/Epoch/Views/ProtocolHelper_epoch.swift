import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Epoch {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Epoch {
        case terms_Epoch       // 服务条款
        case privacy_Epoch     // 隐私政策
        case eula_Epoch        // 最终用户许可协议
        case custom_Epoch(String) // 自定义协议
        
        /// 获取协议标题
        var title_Epoch: String {
            switch self {
            case .terms_Epoch:
                return "Terms of Service"
            case .privacy_Epoch:
                return "Privacy Policy"
            case .eula_Epoch:
                return "EULA"
            case .custom_Epoch(let title_Epoch):
                return title_Epoch
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Epoch {
        /// 普通文本颜色
        var textColor_Epoch: UIColor
        /// 链接文本颜色
        var linkColor_Epoch: UIColor
        /// 字体大小
        var fontSize_Epoch: CGFloat
        /// 字体粗细
        var fontWeight_Epoch: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Epoch: Bool
        /// 前缀文本
        var prefixText_Epoch: String
        /// 分隔符文本
        var separatorText_Epoch: String
        
        /// 默认初始化
        init(
            textColor_Epoch: UIColor = UIColor.gray,
            linkColor_Epoch: UIColor = UIColor.black,
            fontSize_Epoch: CGFloat = 12,
            fontWeight_Epoch: UIFont.Weight = .regular,
            hasUnderline_Epoch: Bool = true,
            prefixText_Epoch: String = "By continuing you agree with ",
            separatorText_Epoch: String = " & "
        ) {
            self.textColor_Epoch = textColor_Epoch
            self.linkColor_Epoch = linkColor_Epoch
            self.fontSize_Epoch = fontSize_Epoch
            self.fontWeight_Epoch = fontWeight_Epoch
            self.hasUnderline_Epoch = hasUnderline_Epoch
            self.prefixText_Epoch = prefixText_Epoch
            self.separatorText_Epoch = separatorText_Epoch
        }
        
        /// 浅色主题配置
        static func light_Epoch() -> ProtocolTextConfig_Epoch {
            return ProtocolTextConfig_Epoch(
                textColor_Epoch: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Epoch: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Epoch() -> ProtocolTextConfig_Epoch {
            return ProtocolTextConfig_Epoch(
                textColor_Epoch: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Epoch: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Epoch: 协议类型
    ///   - content_Epoch: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Epoch: 当前视图控制器
    static func showProtocol_Epoch(
        type_Epoch: ProtocolType_Epoch,
        content_Epoch: String,
        from viewController_Epoch: UIViewController
    ) {
        let protocolVC_Epoch = ProtocolViewController_Epoch(
            type_Epoch: type_Epoch,
            content_Epoch: content_Epoch
        )
        viewController_Epoch.navigationController?.pushViewController(
            protocolVC_Epoch,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Epoch: 第一个协议类型
    ///   - firstContent_Epoch: 第一个协议内容
    ///   - secondProtocol_Epoch: 第二个协议类型
    ///   - secondContent_Epoch: 第二个协议内容
    ///   - config_Epoch: 文本配置
    ///   - viewController_Epoch: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Epoch(
        firstProtocol_Epoch: ProtocolType_Epoch = .terms_Epoch,
        firstContent_Epoch: String,
        secondProtocol_Epoch: ProtocolType_Epoch = .privacy_Epoch,
        secondContent_Epoch: String,
        config_Epoch: ProtocolTextConfig_Epoch = .light_Epoch(),
        from viewController_Epoch: UIViewController
    ) -> UILabel {
        let label_Epoch = UILabel()
        label_Epoch.numberOfLines = 0
        label_Epoch.textAlignment = .center
        label_Epoch.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Epoch = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Epoch: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Epoch.fontSize_Epoch, weight: config_Epoch.fontWeight_Epoch),
            .foregroundColor: config_Epoch.textColor_Epoch
        ]
        attributedString_Epoch.append(NSAttributedString(
            string: config_Epoch.prefixText_Epoch,
            attributes: prefixAttributes_Epoch
        ))
        
        // 第一个协议链接
        var linkAttributes_Epoch: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Epoch.fontSize_Epoch, weight: config_Epoch.fontWeight_Epoch),
            .foregroundColor: config_Epoch.linkColor_Epoch
        ]
        if config_Epoch.hasUnderline_Epoch {
            linkAttributes_Epoch[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Epoch[.underlineColor] = config_Epoch.linkColor_Epoch
        }
        
        let firstProtocolString_Epoch = NSAttributedString(
            string: firstProtocol_Epoch.title_Epoch,
            attributes: linkAttributes_Epoch
        )
        attributedString_Epoch.append(firstProtocolString_Epoch)
        
        // 分隔符
        attributedString_Epoch.append(NSAttributedString(
            string: config_Epoch.separatorText_Epoch,
            attributes: prefixAttributes_Epoch
        ))
        
        // 第二个协议链接
        let secondProtocolString_Epoch = NSAttributedString(
            string: secondProtocol_Epoch.title_Epoch + ".",
            attributes: linkAttributes_Epoch
        )
        attributedString_Epoch.append(secondProtocolString_Epoch)
        
        label_Epoch.attributedText = attributedString_Epoch
        
        // 添加点击手势
        let tapGesture_Epoch = ProtocolTextTapGesture_Epoch(
            firstProtocol_Epoch: firstProtocol_Epoch,
            firstContent_Epoch: firstContent_Epoch,
            secondProtocol_Epoch: secondProtocol_Epoch,
            secondContent_Epoch: secondContent_Epoch,
            prefixLength_Epoch: config_Epoch.prefixText_Epoch.count,
            firstTitleLength_Epoch: firstProtocol_Epoch.title_Epoch.count,
            separatorLength_Epoch: config_Epoch.separatorText_Epoch.count,
            secondTitleLength_Epoch: secondProtocol_Epoch.title_Epoch.count + 1,
            viewController_Epoch: viewController_Epoch
        )
        label_Epoch.addGestureRecognizer(tapGesture_Epoch)
        
        return label_Epoch
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Epoch: UITapGestureRecognizer {
    
    private let firstProtocol_Epoch: ProtocolHelper_Epoch.ProtocolType_Epoch
    private let firstContent_Epoch: String
    private let secondProtocol_Epoch: ProtocolHelper_Epoch.ProtocolType_Epoch
    private let secondContent_Epoch: String
    private let prefixLength_Epoch: Int
    private let firstTitleLength_Epoch: Int
    private let separatorLength_Epoch: Int
    private let secondTitleLength_Epoch: Int
    private weak var viewController_Epoch: UIViewController?
    
    init(
        firstProtocol_Epoch: ProtocolHelper_Epoch.ProtocolType_Epoch,
        firstContent_Epoch: String,
        secondProtocol_Epoch: ProtocolHelper_Epoch.ProtocolType_Epoch,
        secondContent_Epoch: String,
        prefixLength_Epoch: Int,
        firstTitleLength_Epoch: Int,
        separatorLength_Epoch: Int,
        secondTitleLength_Epoch: Int,
        viewController_Epoch: UIViewController
    ) {
        self.firstProtocol_Epoch = firstProtocol_Epoch
        self.firstContent_Epoch = firstContent_Epoch
        self.secondProtocol_Epoch = secondProtocol_Epoch
        self.secondContent_Epoch = secondContent_Epoch
        self.prefixLength_Epoch = prefixLength_Epoch
        self.firstTitleLength_Epoch = firstTitleLength_Epoch
        self.separatorLength_Epoch = separatorLength_Epoch
        self.secondTitleLength_Epoch = secondTitleLength_Epoch
        self.viewController_Epoch = viewController_Epoch
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Epoch(_:)))
    }
    
    @objc private func handleTap_Epoch(_ gesture: UITapGestureRecognizer) {
        guard let label_Epoch = gesture.view as? UILabel,
              let attributedText_Epoch = label_Epoch.attributedText,
              let viewController_Epoch = viewController_Epoch else { return }
        
        // 计算点击位置
        let location_Epoch = gesture.location(in: label_Epoch)
        
        // 创建文本容器和布局管理器
        let textStorage_Epoch = NSTextStorage(attributedString: attributedText_Epoch)
        let layoutManager_Epoch = NSLayoutManager()
        let textContainer_Epoch = NSTextContainer(size: label_Epoch.bounds.size)
        
        layoutManager_Epoch.addTextContainer(textContainer_Epoch)
        textStorage_Epoch.addLayoutManager(layoutManager_Epoch)
        
        textContainer_Epoch.lineFragmentPadding = 0
        textContainer_Epoch.maximumNumberOfLines = label_Epoch.numberOfLines
        textContainer_Epoch.lineBreakMode = label_Epoch.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Epoch = layoutManager_Epoch.characterIndex(
            for: location_Epoch,
            in: textContainer_Epoch,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Epoch = prefixLength_Epoch
        let firstLinkEnd_Epoch = firstLinkStart_Epoch + firstTitleLength_Epoch
        
        let secondLinkStart_Epoch = firstLinkEnd_Epoch + separatorLength_Epoch
        let secondLinkEnd_Epoch = secondLinkStart_Epoch + secondTitleLength_Epoch
        
        if characterIndex_Epoch >= firstLinkStart_Epoch && characterIndex_Epoch < firstLinkEnd_Epoch {
            // 点击第一个协议
            ProtocolHelper_Epoch.showProtocol_Epoch(
                type_Epoch: firstProtocol_Epoch,
                content_Epoch: firstContent_Epoch,
                from: viewController_Epoch
            )
        } else if characterIndex_Epoch >= secondLinkStart_Epoch && characterIndex_Epoch < secondLinkEnd_Epoch {
            // 点击第二个协议
            ProtocolHelper_Epoch.showProtocol_Epoch(
                type_Epoch: secondProtocol_Epoch,
                content_Epoch: secondContent_Epoch,
                from: viewController_Epoch
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、本地图片）
class ProtocolViewController_Epoch: UIViewController {
    
    // MARK: - 属性
    
    private let protocolType_Epoch: ProtocolHelper_Epoch.ProtocolType_Epoch
    private let content_Epoch: String
    
    private var webView_Epoch: WKWebView?
    private var scrollView_Epoch: UIScrollView?
    private var activityIndicator_Epoch: UIActivityIndicatorView?
    
    /// 是否是远程 URL
    private var isRemoteURL_Epoch: Bool {
        return content_Epoch.hasPrefix("http")
    }
    
    /// 是否是图片
    private var isImage_Epoch: Bool {
        return content_Epoch.hasSuffix(".png") || 
               content_Epoch.hasSuffix(".jpg") || 
               content_Epoch.hasSuffix(".jpeg")
    }
    
    // MARK: - 初始化
    
    init(type_Epoch: ProtocolHelper_Epoch.ProtocolType_Epoch, content_Epoch: String) {
        self.protocolType_Epoch = type_Epoch
        self.content_Epoch = content_Epoch
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        loadContent_Epoch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI设置
    
    private func setupUI_Epoch() {
        view.backgroundColor = .white
        title = protocolType_Epoch.title_Epoch
        
        // 设置返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Epoch)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        if isRemoteURL_Epoch {
            setupWebView_Epoch()
            setupActivityIndicator_Epoch()
        } else {
            setupScrollView_Epoch()
        }
    }
    
    /// 设置 WebView
    private func setupWebView_Epoch() {
        let webView_Epoch = WKWebView()
        webView_Epoch.navigationDelegate = self
        view.addSubview(webView_Epoch)
        
        webView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.webView_Epoch = webView_Epoch
    }
    
    /// 设置 ScrollView（用于文本和图片）
    private func setupScrollView_Epoch() {
        let scrollView_Epoch = UIScrollView()
        scrollView_Epoch.showsVerticalScrollIndicator = true
        scrollView_Epoch.alwaysBounceVertical = true
        view.addSubview(scrollView_Epoch)
        
        scrollView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.scrollView_Epoch = scrollView_Epoch
    }
    
    /// 设置加载指示器
    private func setupActivityIndicator_Epoch() {
        let indicator_Epoch = UIActivityIndicatorView(style: .large)
        indicator_Epoch.color = .gray
        view.addSubview(indicator_Epoch)
        
        indicator_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.activityIndicator_Epoch = indicator_Epoch
    }
    
    // MARK: - 加载内容
    
    private func loadContent_Epoch() {
        if isRemoteURL_Epoch {
            loadWebContent_Epoch()
        } else if isImage_Epoch {
            loadImageContent_Epoch()
        } else {
            loadTextContent_Epoch()
        }
    }
    
    /// 加载网页内容
    private func loadWebContent_Epoch() {
        guard let url_Epoch = URL(string: content_Epoch) else { return }
        
        activityIndicator_Epoch?.startAnimating()
        
        let request_Epoch = URLRequest(url: url_Epoch)
        webView_Epoch?.load(request_Epoch)
    }
    
    /// 加载图片内容
    private func loadImageContent_Epoch() {
        guard let scrollView_Epoch = scrollView_Epoch,
              let image_Epoch = UIImage(named: content_Epoch) else { return }
        
        let imageView_Epoch = UIImageView()
        imageView_Epoch.contentMode = .scaleAspectFit
        imageView_Epoch.image = image_Epoch
        scrollView_Epoch.addSubview(imageView_Epoch)
        
        // 计算图片显示高度（按屏幕宽度缩放）
        let screenWidth_Epoch = view.bounds.width
        let imageRatio_Epoch = image_Epoch.size.height / image_Epoch.size.width
        let displayHeight_Epoch = screenWidth_Epoch * imageRatio_Epoch
        
        imageView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Epoch)
            make.height.equalTo(displayHeight_Epoch)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 加载文本内容
    private func loadTextContent_Epoch() {
        guard let scrollView_Epoch = scrollView_Epoch else { return }
        
        let textLabel_Epoch = UILabel()
        textLabel_Epoch.text = content_Epoch
        textLabel_Epoch.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel_Epoch.textColor = .black
        textLabel_Epoch.numberOfLines = 0
        scrollView_Epoch.addSubview(textLabel_Epoch)
        
        textLabel_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func backTapped_Epoch() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Epoch: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Epoch?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Epoch?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Epoch?.stopAnimating()
        Utils_Epoch.showError_Epoch(message_Epoch: "Failed to load content")
    }
}
