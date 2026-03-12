import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Doze {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Doze {
        case terms_Doze       // 服务条款
        case privacy_Doze     // 隐私政策
        case eula_Doze        // 最终用户许可协议
        case custom_Doze(String) // 自定义协议
        
        /// 获取协议标题
        var title_Doze: String {
            switch self {
            case .terms_Doze:
                return "Terms of Service"
            case .privacy_Doze:
                return "Privacy Policy"
            case .eula_Doze:
                return "EULA"
            case .custom_Doze(let title_Doze):
                return title_Doze
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Doze {
        /// 普通文本颜色
        var textColor_Doze: UIColor
        /// 链接文本颜色
        var linkColor_Doze: UIColor
        /// 字体大小
        var fontSize_Doze: CGFloat
        /// 字体粗细
        var fontWeight_Doze: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Doze: Bool
        /// 前缀文本
        var prefixText_Doze: String
        /// 分隔符文本
        var separatorText_Doze: String
        
        /// 默认初始化
        init(
            textColor_Doze: UIColor = UIColor.gray,
            linkColor_Doze: UIColor = UIColor.black,
            fontSize_Doze: CGFloat = 12,
            fontWeight_Doze: UIFont.Weight = .regular,
            hasUnderline_Doze: Bool = true,
            prefixText_Doze: String = "By continuing you agree with ",
            separatorText_Doze: String = " & "
        ) {
            self.textColor_Doze = textColor_Doze
            self.linkColor_Doze = linkColor_Doze
            self.fontSize_Doze = fontSize_Doze
            self.fontWeight_Doze = fontWeight_Doze
            self.hasUnderline_Doze = hasUnderline_Doze
            self.prefixText_Doze = prefixText_Doze
            self.separatorText_Doze = separatorText_Doze
        }
        
        /// 浅色主题配置
        static func light_Doze() -> ProtocolTextConfig_Doze {
            return ProtocolTextConfig_Doze(
                textColor_Doze: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Doze: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Doze() -> ProtocolTextConfig_Doze {
            return ProtocolTextConfig_Doze(
                textColor_Doze: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Doze: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Doze: 协议类型
    ///   - content_Doze: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Doze: 当前视图控制器
    static func showProtocol_Doze(
        type_Doze: ProtocolType_Doze,
        content_Doze: String,
        from viewController_Doze: UIViewController
    ) {
        let protocolVC_Doze = ProtocolViewController_Doze(
            type_Doze: type_Doze,
            content_Doze: content_Doze
        )
        viewController_Doze.navigationController?.pushViewController(
            protocolVC_Doze,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Doze: 第一个协议类型
    ///   - firstContent_Doze: 第一个协议内容
    ///   - secondProtocol_Doze: 第二个协议类型
    ///   - secondContent_Doze: 第二个协议内容
    ///   - config_Doze: 文本配置
    ///   - viewController_Doze: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Doze(
        firstProtocol_Doze: ProtocolType_Doze = .terms_Doze,
        firstContent_Doze: String,
        secondProtocol_Doze: ProtocolType_Doze = .privacy_Doze,
        secondContent_Doze: String,
        config_Doze: ProtocolTextConfig_Doze = .light_Doze(),
        from viewController_Doze: UIViewController
    ) -> UILabel {
        let label_Doze = UILabel()
        label_Doze.numberOfLines = 0
        label_Doze.textAlignment = .center
        label_Doze.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Doze = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Doze: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Doze.fontSize_Doze, weight: config_Doze.fontWeight_Doze),
            .foregroundColor: config_Doze.textColor_Doze
        ]
        attributedString_Doze.append(NSAttributedString(
            string: config_Doze.prefixText_Doze,
            attributes: prefixAttributes_Doze
        ))
        
        // 第一个协议链接
        var linkAttributes_Doze: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Doze.fontSize_Doze, weight: config_Doze.fontWeight_Doze),
            .foregroundColor: config_Doze.linkColor_Doze
        ]
        if config_Doze.hasUnderline_Doze {
            linkAttributes_Doze[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Doze[.underlineColor] = config_Doze.linkColor_Doze
        }
        
        let firstProtocolString_Doze = NSAttributedString(
            string: firstProtocol_Doze.title_Doze,
            attributes: linkAttributes_Doze
        )
        attributedString_Doze.append(firstProtocolString_Doze)
        
        // 分隔符
        attributedString_Doze.append(NSAttributedString(
            string: config_Doze.separatorText_Doze,
            attributes: prefixAttributes_Doze
        ))
        
        // 第二个协议链接
        let secondProtocolString_Doze = NSAttributedString(
            string: secondProtocol_Doze.title_Doze + ".",
            attributes: linkAttributes_Doze
        )
        attributedString_Doze.append(secondProtocolString_Doze)
        
        label_Doze.attributedText = attributedString_Doze
        
        // 添加点击手势
        let tapGesture_Doze = ProtocolTextTapGesture_Doze(
            firstProtocol_Doze: firstProtocol_Doze,
            firstContent_Doze: firstContent_Doze,
            secondProtocol_Doze: secondProtocol_Doze,
            secondContent_Doze: secondContent_Doze,
            prefixLength_Doze: config_Doze.prefixText_Doze.count,
            firstTitleLength_Doze: firstProtocol_Doze.title_Doze.count,
            separatorLength_Doze: config_Doze.separatorText_Doze.count,
            secondTitleLength_Doze: secondProtocol_Doze.title_Doze.count + 1,
            viewController_Doze: viewController_Doze
        )
        label_Doze.addGestureRecognizer(tapGesture_Doze)
        
        return label_Doze
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Doze: UITapGestureRecognizer {
    
    private let firstProtocol_Doze: ProtocolHelper_Doze.ProtocolType_Doze
    private let firstContent_Doze: String
    private let secondProtocol_Doze: ProtocolHelper_Doze.ProtocolType_Doze
    private let secondContent_Doze: String
    private let prefixLength_Doze: Int
    private let firstTitleLength_Doze: Int
    private let separatorLength_Doze: Int
    private let secondTitleLength_Doze: Int
    private weak var viewController_Doze: UIViewController?
    
    init(
        firstProtocol_Doze: ProtocolHelper_Doze.ProtocolType_Doze,
        firstContent_Doze: String,
        secondProtocol_Doze: ProtocolHelper_Doze.ProtocolType_Doze,
        secondContent_Doze: String,
        prefixLength_Doze: Int,
        firstTitleLength_Doze: Int,
        separatorLength_Doze: Int,
        secondTitleLength_Doze: Int,
        viewController_Doze: UIViewController
    ) {
        self.firstProtocol_Doze = firstProtocol_Doze
        self.firstContent_Doze = firstContent_Doze
        self.secondProtocol_Doze = secondProtocol_Doze
        self.secondContent_Doze = secondContent_Doze
        self.prefixLength_Doze = prefixLength_Doze
        self.firstTitleLength_Doze = firstTitleLength_Doze
        self.separatorLength_Doze = separatorLength_Doze
        self.secondTitleLength_Doze = secondTitleLength_Doze
        self.viewController_Doze = viewController_Doze
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Doze(_:)))
    }
    
    @objc private func handleTap_Doze(_ gesture: UITapGestureRecognizer) {
        guard let label_Doze = gesture.view as? UILabel,
              let attributedText_Doze = label_Doze.attributedText,
              let viewController_Doze = viewController_Doze else { return }
        
        // 计算点击位置
        let location_Doze = gesture.location(in: label_Doze)
        
        // 创建文本容器和布局管理器
        let textStorage_Doze = NSTextStorage(attributedString: attributedText_Doze)
        let layoutManager_Doze = NSLayoutManager()
        let textContainer_Doze = NSTextContainer(size: label_Doze.bounds.size)
        
        layoutManager_Doze.addTextContainer(textContainer_Doze)
        textStorage_Doze.addLayoutManager(layoutManager_Doze)
        
        textContainer_Doze.lineFragmentPadding = 0
        textContainer_Doze.maximumNumberOfLines = label_Doze.numberOfLines
        textContainer_Doze.lineBreakMode = label_Doze.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Doze = layoutManager_Doze.characterIndex(
            for: location_Doze,
            in: textContainer_Doze,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Doze = prefixLength_Doze
        let firstLinkEnd_Doze = firstLinkStart_Doze + firstTitleLength_Doze
        
        let secondLinkStart_Doze = firstLinkEnd_Doze + separatorLength_Doze
        let secondLinkEnd_Doze = secondLinkStart_Doze + secondTitleLength_Doze
        
        if characterIndex_Doze >= firstLinkStart_Doze && characterIndex_Doze < firstLinkEnd_Doze {
            // 点击第一个协议
            ProtocolHelper_Doze.showProtocol_Doze(
                type_Doze: firstProtocol_Doze,
                content_Doze: firstContent_Doze,
                from: viewController_Doze
            )
        } else if characterIndex_Doze >= secondLinkStart_Doze && characterIndex_Doze < secondLinkEnd_Doze {
            // 点击第二个协议
            ProtocolHelper_Doze.showProtocol_Doze(
                type_Doze: secondProtocol_Doze,
                content_Doze: secondContent_Doze,
                from: viewController_Doze
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地文本、Assets 图片）
/// 设计：使用自定义导航栏（与项目其他页面一致），避免依赖系统导航栏隐显状态
class ProtocolViewController_Doze: UIViewController {

    // MARK: - 属性

    private let protocolType_Doze: ProtocolHelper_Doze.ProtocolType_Doze
    private let content_Doze: String

    private var webView_Doze: WKWebView?
    private var contentScrollView_Doze: UIScrollView?
    private var activityIndicator_Doze: UIActivityIndicatorView?

    /// 是否是远程 URL
    private var isRemoteURL_Doze: Bool { content_Doze.hasPrefix("http") }

    /// 是否可作为 Assets 图片加载（有扩展名或能在 Assets 中找到）
    private var isAssetImage_Doze: Bool {
        let hasImgExt = content_Doze.hasSuffix(".png")
            || content_Doze.hasSuffix(".jpg")
            || content_Doze.hasSuffix(".jpeg")
        return hasImgExt || UIImage(named: content_Doze) != nil
    }

    // MARK: - 自定义导航栏

    private let navBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        return v
    }()

    private let backButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Doze.textPrimary_Doze
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        btn.layer.cornerRadius = 18
        return btn
    }()

    private let navTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    // MARK: - 初始化

    init(type_Doze: ProtocolHelper_Doze.ProtocolType_Doze, content_Doze: String) {
        self.protocolType_Doze = type_Doze
        self.content_Doze = content_Doze
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        setupNavBar_Doze()
        setupContentArea_Doze()
        loadContent_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用自定义导航栏，始终隐藏系统导航栏
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - 自定义导航栏搭建

    private func setupNavBar_Doze() {
        navTitleLabel_Doze.text = protocolType_Doze.title_Doze

        view.addSubview(navBar_Doze)
        navBar_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        navBar_Doze.addSubview(backButton_Doze)
        backButton_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        backButton_Doze.addTarget(self, action: #selector(backTapped_Doze), for: .touchUpInside)

        navBar_Doze.addSubview(navTitleLabel_Doze)
        navTitleLabel_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - 内容区域搭建

    private func setupContentArea_Doze() {
        if isRemoteURL_Doze {
            setupWebView_Doze()
            setupActivityIndicator_Doze()
        } else {
            setupScrollView_Doze()
        }
    }

    /// 设置 WebView（远程 URL）
    private func setupWebView_Doze() {
        let webView_Doze = WKWebView()
        webView_Doze.navigationDelegate = self
        webView_Doze.backgroundColor = .white
        view.addSubview(webView_Doze)
        webView_Doze.snp.makeConstraints { make in
            make.top.equalTo(navBar_Doze.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.webView_Doze = webView_Doze
    }

    /// 设置 ScrollView（本地图片 / 文本）
    private func setupScrollView_Doze() {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        sv.layer.cornerRadius = 16
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(sv)
        sv.snp.makeConstraints { make in
            make.top.equalTo(navBar_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(0)
            make.bottom.equalToSuperview()
        }
        self.contentScrollView_Doze = sv
    }

    /// 设置加载指示器
    private func setupActivityIndicator_Doze() {
        let indicator_Doze = UIActivityIndicatorView(style: .large)
        indicator_Doze.color = ColorConfig_Doze.primaryGradientStart_Doze
        view.addSubview(indicator_Doze)
        indicator_Doze.snp.makeConstraints { make in make.center.equalToSuperview() }
        self.activityIndicator_Doze = indicator_Doze
    }

    // MARK: - 加载内容

    private func loadContent_Doze() {
        if isRemoteURL_Doze {
            loadWebContent_Doze()
        } else if isAssetImage_Doze {
            // Assets 图片（有扩展名或能被 UIImage(named:) 找到）
            loadImageContent_Doze()
        } else {
            loadTextContent_Doze()
        }
    }

    /// 加载网页内容
    private func loadWebContent_Doze() {
        guard let url_Doze = URL(string: content_Doze) else { return }
        activityIndicator_Doze?.startAnimating()
        webView_Doze?.load(URLRequest(url: url_Doze))
    }

    /// 加载 Assets 图片内容
    private func loadImageContent_Doze() {
        guard let sv = contentScrollView_Doze,
              let image_Doze = UIImage(named: content_Doze) else {
            // 图片不存在时退回文本显示
            loadTextContent_Doze()
            return
        }

        let imageView_Doze = UIImageView()
        imageView_Doze.contentMode = .scaleAspectFit
        imageView_Doze.image = image_Doze
        sv.addSubview(imageView_Doze)

        // 按屏幕宽度缩放，保持图片原始比例
        let screenWidth_Doze = UIScreen.main.bounds.width
        let ratio_Doze = image_Doze.size.height / max(image_Doze.size.width, 1)
        let displayHeight_Doze = screenWidth_Doze * ratio_Doze

        imageView_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Doze)
            make.height.equalTo(displayHeight_Doze)
            make.bottom.equalToSuperview()
        }
    }

    /// 加载纯文本内容
    private func loadTextContent_Doze() {
        guard let sv = contentScrollView_Doze else { return }

        let textLabel_Doze = UILabel()
        textLabel_Doze.text = content_Doze
        textLabel_Doze.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textLabel_Doze.textColor = ColorConfig_Doze.textPrimary_Doze
        textLabel_Doze.numberOfLines = 0
        sv.addSubview(textLabel_Doze)

        textLabel_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalTo(view.snp.width).offset(-40)
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.pop_Doze()
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Doze: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Doze?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Doze?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Doze?.stopAnimating()
        Utils_Doze.showError_Doze(message_Doze: "Failed to load content")
    }
}
