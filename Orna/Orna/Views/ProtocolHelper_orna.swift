import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA 等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Orna {

    // MARK: - 协议类型枚举

    /// 协议类型
    enum ProtocolType_Orna {
        case terms_Orna
        case privacy_Orna
        case eula_Orna
        case custom_Orna(String)

        /// 协议标题
        var title_Orna: String {
            switch self {
            case .terms_Orna:   return "Terms of Service"
            case .privacy_Orna: return "Privacy Policy"
            case .eula_Orna:    return "EULA"
            case .custom_Orna(let title_Orna): return title_Orna
            }
        }
    }

    // MARK: - 协议文本配置

    /// 协议文本展示样式配置
    struct ProtocolTextConfig_Orna {
        var textColor_Orna: UIColor
        var linkColor_Orna: UIColor
        var fontSize_Orna: CGFloat
        var fontWeight_Orna: UIFont.Weight
        var hasUnderline_Orna: Bool
        var prefixText_Orna: String
        var separatorText_Orna: String

        init(
            textColor_Orna: UIColor = UIColor.gray,
            linkColor_Orna: UIColor = UIColor.black,
            fontSize_Orna: CGFloat = 12,
            fontWeight_Orna: UIFont.Weight = .regular,
            hasUnderline_Orna: Bool = true,
            prefixText_Orna: String = "By continuing you agree with ",
            separatorText_Orna: String = " & "
        ) {
            self.textColor_Orna = textColor_Orna
            self.linkColor_Orna = linkColor_Orna
            self.fontSize_Orna = fontSize_Orna
            self.fontWeight_Orna = fontWeight_Orna
            self.hasUnderline_Orna = hasUnderline_Orna
            self.prefixText_Orna = prefixText_Orna
            self.separatorText_Orna = separatorText_Orna
        }

        /// 浅色主题配置
        static func light_Orna() -> ProtocolTextConfig_Orna {
            ProtocolTextConfig_Orna(
                textColor_Orna: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Orna: UIColor(white: 0.2, alpha: 1.0)
            )
        }

        /// 深色主题配置
        static func dark_Orna() -> ProtocolTextConfig_Orna {
            ProtocolTextConfig_Orna(
                textColor_Orna: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Orna: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }

    // MARK: - 公共方法

    /// 跳转到协议详情页
    /// 参数：
    /// - type_Orna: 协议类型
    /// - content_Orna: 协议内容（URL、本地文本或图片路径）
    /// - viewController_Orna: 发起跳转的视图控制器
    static func showProtocol_Orna(
        type_Orna: ProtocolType_Orna,
        content_Orna: String,
        from viewController_Orna: UIViewController
    ) {
        let vc_Orna = ProtocolViewController_Orna(type_Orna: type_Orna, content_Orna: content_Orna)
        viewController_Orna.navigationController?.pushViewController(vc_Orna, animated: true)
    }

    /// 创建带可点击协议链接的富文本 Label
    /// 参数：
    /// - firstProtocol_Orna: 第一个协议类型，默认服务条款
    /// - firstContent_Orna: 第一个协议内容
    /// - secondProtocol_Orna: 第二个协议类型，默认隐私政策
    /// - secondContent_Orna: 第二个协议内容
    /// - config_Orna: 文本样式配置，默认浅色
    /// - viewController_Orna: 点击跳转的目标控制器
    /// 返回值：配置好手势的富文本 UILabel
    static func createProtocolTextLabel_Orna(
        firstProtocol_Orna: ProtocolType_Orna = .terms_Orna,
        firstContent_Orna: String,
        secondProtocol_Orna: ProtocolType_Orna = .privacy_Orna,
        secondContent_Orna: String,
        config_Orna: ProtocolTextConfig_Orna = .light_Orna(),
        from viewController_Orna: UIViewController
    ) -> UILabel {
        let label_Orna = UILabel()
        label_Orna.numberOfLines = 0
        label_Orna.textAlignment = .center
        label_Orna.isUserInteractionEnabled = true

        // 共享字体（前缀、分隔符、链接均使用同一字体）
        let font_Orna = UIFont.systemFont(ofSize: config_Orna.fontSize_Orna, weight: config_Orna.fontWeight_Orna)

        let prefixAttrs_Orna: [NSAttributedString.Key: Any] = [
            .font: font_Orna,
            .foregroundColor: config_Orna.textColor_Orna
        ]

        var linkAttrs_Orna: [NSAttributedString.Key: Any] = [
            .font: font_Orna,
            .foregroundColor: config_Orna.linkColor_Orna
        ]
        if config_Orna.hasUnderline_Orna {
            linkAttrs_Orna[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttrs_Orna[.underlineColor] = config_Orna.linkColor_Orna
        }

        let text_Orna = NSMutableAttributedString()
        text_Orna.append(NSAttributedString(string: config_Orna.prefixText_Orna, attributes: prefixAttrs_Orna))
        text_Orna.append(NSAttributedString(string: firstProtocol_Orna.title_Orna, attributes: linkAttrs_Orna))
        text_Orna.append(NSAttributedString(string: config_Orna.separatorText_Orna, attributes: prefixAttrs_Orna))
        text_Orna.append(NSAttributedString(string: secondProtocol_Orna.title_Orna + ".", attributes: linkAttrs_Orna))
        label_Orna.attributedText = text_Orna

        label_Orna.addGestureRecognizer(ProtocolTextTapGesture_Orna(
            firstProtocol_Orna: firstProtocol_Orna,
            firstContent_Orna: firstContent_Orna,
            secondProtocol_Orna: secondProtocol_Orna,
            secondContent_Orna: secondContent_Orna,
            prefixLength_Orna: config_Orna.prefixText_Orna.count,
            firstTitleLength_Orna: firstProtocol_Orna.title_Orna.count,
            separatorLength_Orna: config_Orna.separatorText_Orna.count,
            secondTitleLength_Orna: secondProtocol_Orna.title_Orna.count + 1,
            viewController_Orna: viewController_Orna
        ))
        return label_Orna
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击位置所属的协议链接并跳转到对应详情页
class ProtocolTextTapGesture_Orna: UITapGestureRecognizer {

    private let firstProtocol_Orna: ProtocolHelper_Orna.ProtocolType_Orna
    private let firstContent_Orna: String
    private let secondProtocol_Orna: ProtocolHelper_Orna.ProtocolType_Orna
    private let secondContent_Orna: String
    private let prefixLength_Orna: Int
    private let firstTitleLength_Orna: Int
    private let separatorLength_Orna: Int
    private let secondTitleLength_Orna: Int
    private weak var viewController_Orna: UIViewController?

    init(
        firstProtocol_Orna: ProtocolHelper_Orna.ProtocolType_Orna,
        firstContent_Orna: String,
        secondProtocol_Orna: ProtocolHelper_Orna.ProtocolType_Orna,
        secondContent_Orna: String,
        prefixLength_Orna: Int,
        firstTitleLength_Orna: Int,
        separatorLength_Orna: Int,
        secondTitleLength_Orna: Int,
        viewController_Orna: UIViewController
    ) {
        self.firstProtocol_Orna = firstProtocol_Orna
        self.firstContent_Orna = firstContent_Orna
        self.secondProtocol_Orna = secondProtocol_Orna
        self.secondContent_Orna = secondContent_Orna
        self.prefixLength_Orna = prefixLength_Orna
        self.firstTitleLength_Orna = firstTitleLength_Orna
        self.separatorLength_Orna = separatorLength_Orna
        self.secondTitleLength_Orna = secondTitleLength_Orna
        self.viewController_Orna = viewController_Orna
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Orna(_:)))
    }

    @objc private func handleTap_Orna(_ gesture: UITapGestureRecognizer) {
        guard let label_Orna = gesture.view as? UILabel,
              let attrText_Orna = label_Orna.attributedText,
              let vc_Orna = viewController_Orna else { return }

        // 构建文本布局以确定点击字符索引
        let storage_Orna = NSTextStorage(attributedString: attrText_Orna)
        let layoutManager_Orna = NSLayoutManager()
        let container_Orna = NSTextContainer(size: label_Orna.bounds.size)
        container_Orna.lineFragmentPadding = 0
        container_Orna.maximumNumberOfLines = label_Orna.numberOfLines
        container_Orna.lineBreakMode = label_Orna.lineBreakMode
        layoutManager_Orna.addTextContainer(container_Orna)
        storage_Orna.addLayoutManager(layoutManager_Orna)

        let charIndex_Orna = layoutManager_Orna.characterIndex(
            for: gesture.location(in: label_Orna),
            in: container_Orna,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        let firstStart_Orna  = prefixLength_Orna
        let firstEnd_Orna    = firstStart_Orna + firstTitleLength_Orna
        let secondStart_Orna = firstEnd_Orna + separatorLength_Orna
        let secondEnd_Orna   = secondStart_Orna + secondTitleLength_Orna

        if (firstStart_Orna..<firstEnd_Orna).contains(charIndex_Orna) {
            ProtocolHelper_Orna.showProtocol_Orna(
                type_Orna: firstProtocol_Orna,
                content_Orna: firstContent_Orna,
                from: vc_Orna
            )
        } else if (secondStart_Orna..<secondEnd_Orna).contains(charIndex_Orna) {
            ProtocolHelper_Orna.showProtocol_Orna(
                type_Orna: secondProtocol_Orna,
                content_Orna: secondContent_Orna,
                from: vc_Orna
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容，根据 content 自动判断展示方式（WebView / 图片 / 文本）
/// 设计：与全 App 其他页面一致，隐藏系统导航栏，改用自定义悬浮返回按钮 + 顶部标题，
///       避免因其他页面各自控制系统导航栏隐藏状态而导致标题与返回按钮显示不稳定
class ProtocolViewController_Orna: UIViewController {

    // MARK: - 属性

    private let protocolType_Orna: ProtocolHelper_Orna.ProtocolType_Orna
    private let content_Orna: String

    private var webView_Orna: WKWebView?
    private var scrollView_Orna: UIScrollView?
    private var activityIndicator_Orna: UIActivityIndicatorView?

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.15
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 8
        return b
    }()

    private let headerTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    /// 是否为远程 URL
    private var isRemoteURL_Orna: Bool { content_Orna.hasPrefix("http") }

    /// 是否为图片路径
    private var isImage_Orna: Bool {
        ["png", "jpg", "jpeg"].contains { content_Orna.hasSuffix(".\($0)") }
    }

    // MARK: - 初始化

    init(type_Orna: ProtocolHelper_Orna.ProtocolType_Orna, content_Orna: String) {
        self.protocolType_Orna = type_Orna
        self.content_Orna = content_Orna
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Orna()
        setupConstraints_Orna()
        loadContent_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 与全 App 其他页面保持一致，统一隐藏系统导航栏，改用自定义悬浮返回按钮 + 标题展示，
        // 避免因其他页面各自对系统导航栏隐藏状态的控制互相干扰，导致标题/返回按钮无法正确显示
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UI设置

    private func setupUI_Orna() {
        view.backgroundColor = .white
        headerTitleLabel_Orna.text = protocolType_Orna.title_Orna

        view.addSubview(backButton_Orna)
        view.addSubview(headerTitleLabel_Orna)
        backButton_Orna.addTarget(self, action: #selector(backTapped_Orna), for: .touchUpInside)

        if isRemoteURL_Orna {
            setupWebView_Orna()
            setupActivityIndicator_Orna()
        } else {
            setupScrollView_Orna()
        }
    }

    private func setupConstraints_Orna() {
        backButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        headerTitleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.centerX.equalToSuperview()
        }
    }

    /// 设置 WebView
    private func setupWebView_Orna() {
        let wv_Orna = WKWebView()
        wv_Orna.navigationDelegate = self
        view.addSubview(wv_Orna)
        wv_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        webView_Orna = wv_Orna
    }

    /// 设置 ScrollView（文本和图片共用）
    private func setupScrollView_Orna() {
        let sv_Orna = UIScrollView()
        sv_Orna.showsVerticalScrollIndicator = true
        sv_Orna.alwaysBounceVertical = true
        view.addSubview(sv_Orna)
        sv_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        scrollView_Orna = sv_Orna
    }

    /// 设置加载指示器
    private func setupActivityIndicator_Orna() {
        let indicator_Orna = UIActivityIndicatorView(style: .large)
        indicator_Orna.color = .gray
        view.addSubview(indicator_Orna)
        indicator_Orna.snp.makeConstraints { $0.center.equalToSuperview() }
        activityIndicator_Orna = indicator_Orna
    }

    // MARK: - 加载内容

    private func loadContent_Orna() {
        if isRemoteURL_Orna {
            loadWebContent_Orna()
        } else if isImage_Orna {
            loadImageContent_Orna()
        } else {
            loadTextContent_Orna()
        }
    }

    /// 加载远程网页
    private func loadWebContent_Orna() {
        guard let url_Orna = URL(string: content_Orna) else { return }
        activityIndicator_Orna?.startAnimating()
        webView_Orna?.load(URLRequest(url: url_Orna))
    }

    /// 加载本地图片（按屏幕宽度等比缩放）
    private func loadImageContent_Orna() {
        guard let sv_Orna = scrollView_Orna,
              let img_Orna = UIImage(named: content_Orna) else { return }

        let iv_Orna = UIImageView()
        iv_Orna.contentMode = .scaleAspectFit
        iv_Orna.image = img_Orna
        sv_Orna.addSubview(iv_Orna)

        let screenWidth_Orna = view.bounds.width
        let displayHeight_Orna = screenWidth_Orna * img_Orna.size.height / img_Orna.size.width
        iv_Orna.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.width.equalTo(screenWidth_Orna)
            $0.height.equalTo(displayHeight_Orna)
            $0.bottom.equalToSuperview()
        }
    }

    /// 加载本地文本
    private func loadTextContent_Orna() {
        guard let sv_Orna = scrollView_Orna else { return }

        let label_Orna = UILabel()
        label_Orna.text = content_Orna
        label_Orna.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label_Orna.textColor = .black
        label_Orna.numberOfLines = 0
        sv_Orna.addSubview(label_Orna)
        label_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalTo(view.snp.width).offset(-40)
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Orna() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Orna: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Orna?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Orna?.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Orna?.stopAnimating()
        Load_Orna.showError_Orna(message_Orna: "Failed to load content")
    }
}
