import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA 等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Maki {

    // MARK: - 协议类型枚举

    /// 协议类型
    enum ProtocolType_Maki {
        case terms_Maki
        case privacy_Maki
        case eula_Maki
        case custom_Maki(String)

        /// 协议标题
        var title_Maki: String {
            switch self {
            case .terms_Maki:   return "Terms of Service"
            case .privacy_Maki: return "Privacy Policy"
            case .eula_Maki:    return "EULA"
            case .custom_Maki(let title_Maki): return title_Maki
            }
        }
    }

    // MARK: - 协议文本配置

    /// 协议文本展示样式配置
    struct ProtocolTextConfig_Maki {
        var textColor_Maki: UIColor
        var linkColor_Maki: UIColor
        var fontSize_Maki: CGFloat
        var fontWeight_Maki: UIFont.Weight
        var hasUnderline_Maki: Bool
        var prefixText_Maki: String
        var separatorText_Maki: String

        init(
            textColor_Maki: UIColor = UIColor.gray,
            linkColor_Maki: UIColor = UIColor.black,
            fontSize_Maki: CGFloat = 12,
            fontWeight_Maki: UIFont.Weight = .regular,
            hasUnderline_Maki: Bool = true,
            prefixText_Maki: String = "By continuing you agree with ",
            separatorText_Maki: String = " & "
        ) {
            self.textColor_Maki = textColor_Maki
            self.linkColor_Maki = linkColor_Maki
            self.fontSize_Maki = fontSize_Maki
            self.fontWeight_Maki = fontWeight_Maki
            self.hasUnderline_Maki = hasUnderline_Maki
            self.prefixText_Maki = prefixText_Maki
            self.separatorText_Maki = separatorText_Maki
        }

        /// 浅色主题配置
        static func light_Maki() -> ProtocolTextConfig_Maki {
            ProtocolTextConfig_Maki(
                textColor_Maki: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Maki: UIColor(white: 0.2, alpha: 1.0)
            )
        }

        /// 深色主题配置
        static func dark_Maki() -> ProtocolTextConfig_Maki {
            ProtocolTextConfig_Maki(
                textColor_Maki: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Maki: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }

    // MARK: - 公共方法

    /// 跳转到协议详情页
    /// 参数：
    /// - type_Maki: 协议类型
    /// - content_Maki: 协议内容（URL、本地文本或图片路径）
    /// - viewController_Maki: 发起跳转的视图控制器
    static func showProtocol_Maki(
        type_Maki: ProtocolType_Maki,
        content_Maki: String,
        from viewController_Maki: UIViewController
    ) {
        let vc_Maki = ProtocolViewController_Maki(type_Maki: type_Maki, content_Maki: content_Maki)
        viewController_Maki.navigationController?.pushViewController(vc_Maki, animated: true)
    }

    /// 创建带可点击协议链接的富文本 Label
    /// 参数：
    /// - firstProtocol_Maki: 第一个协议类型，默认服务条款
    /// - firstContent_Maki: 第一个协议内容
    /// - secondProtocol_Maki: 第二个协议类型，默认隐私政策
    /// - secondContent_Maki: 第二个协议内容
    /// - config_Maki: 文本样式配置，默认浅色
    /// - viewController_Maki: 点击跳转的目标控制器
    /// 返回值：配置好手势的富文本 UILabel
    static func createProtocolTextLabel_Maki(
        firstProtocol_Maki: ProtocolType_Maki = .terms_Maki,
        firstContent_Maki: String,
        secondProtocol_Maki: ProtocolType_Maki = .privacy_Maki,
        secondContent_Maki: String,
        config_Maki: ProtocolTextConfig_Maki = .light_Maki(),
        from viewController_Maki: UIViewController
    ) -> UILabel {
        let label_Maki = UILabel()
        label_Maki.numberOfLines = 0
        label_Maki.textAlignment = .center
        label_Maki.isUserInteractionEnabled = true

        // 共享字体（前缀、分隔符、链接均使用同一字体）
        let font_Maki = UIFont.systemFont(ofSize: config_Maki.fontSize_Maki, weight: config_Maki.fontWeight_Maki)

        let prefixAttrs_Maki: [NSAttributedString.Key: Any] = [
            .font: font_Maki,
            .foregroundColor: config_Maki.textColor_Maki
        ]

        var linkAttrs_Maki: [NSAttributedString.Key: Any] = [
            .font: font_Maki,
            .foregroundColor: config_Maki.linkColor_Maki
        ]
        if config_Maki.hasUnderline_Maki {
            linkAttrs_Maki[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttrs_Maki[.underlineColor] = config_Maki.linkColor_Maki
        }

        let text_Maki = NSMutableAttributedString()
        text_Maki.append(NSAttributedString(string: config_Maki.prefixText_Maki, attributes: prefixAttrs_Maki))
        text_Maki.append(NSAttributedString(string: firstProtocol_Maki.title_Maki, attributes: linkAttrs_Maki))
        text_Maki.append(NSAttributedString(string: config_Maki.separatorText_Maki, attributes: prefixAttrs_Maki))
        text_Maki.append(NSAttributedString(string: secondProtocol_Maki.title_Maki + ".", attributes: linkAttrs_Maki))
        label_Maki.attributedText = text_Maki

        label_Maki.addGestureRecognizer(ProtocolTextTapGesture_Maki(
            firstProtocol_Maki: firstProtocol_Maki,
            firstContent_Maki: firstContent_Maki,
            secondProtocol_Maki: secondProtocol_Maki,
            secondContent_Maki: secondContent_Maki,
            prefixLength_Maki: config_Maki.prefixText_Maki.count,
            firstTitleLength_Maki: firstProtocol_Maki.title_Maki.count,
            separatorLength_Maki: config_Maki.separatorText_Maki.count,
            secondTitleLength_Maki: secondProtocol_Maki.title_Maki.count + 1,
            viewController_Maki: viewController_Maki
        ))
        return label_Maki
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击位置所属的协议链接并跳转到对应详情页
class ProtocolTextTapGesture_Maki: UITapGestureRecognizer {

    private let firstProtocol_Maki: ProtocolHelper_Maki.ProtocolType_Maki
    private let firstContent_Maki: String
    private let secondProtocol_Maki: ProtocolHelper_Maki.ProtocolType_Maki
    private let secondContent_Maki: String
    private let prefixLength_Maki: Int
    private let firstTitleLength_Maki: Int
    private let separatorLength_Maki: Int
    private let secondTitleLength_Maki: Int
    private weak var viewController_Maki: UIViewController?

    init(
        firstProtocol_Maki: ProtocolHelper_Maki.ProtocolType_Maki,
        firstContent_Maki: String,
        secondProtocol_Maki: ProtocolHelper_Maki.ProtocolType_Maki,
        secondContent_Maki: String,
        prefixLength_Maki: Int,
        firstTitleLength_Maki: Int,
        separatorLength_Maki: Int,
        secondTitleLength_Maki: Int,
        viewController_Maki: UIViewController
    ) {
        self.firstProtocol_Maki = firstProtocol_Maki
        self.firstContent_Maki = firstContent_Maki
        self.secondProtocol_Maki = secondProtocol_Maki
        self.secondContent_Maki = secondContent_Maki
        self.prefixLength_Maki = prefixLength_Maki
        self.firstTitleLength_Maki = firstTitleLength_Maki
        self.separatorLength_Maki = separatorLength_Maki
        self.secondTitleLength_Maki = secondTitleLength_Maki
        self.viewController_Maki = viewController_Maki
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Maki(_:)))
    }

    @objc private func handleTap_Maki(_ gesture: UITapGestureRecognizer) {
        guard let label_Maki = gesture.view as? UILabel,
              let attrText_Maki = label_Maki.attributedText,
              let vc_Maki = viewController_Maki else { return }

        // 构建文本布局以确定点击字符索引
        let storage_Maki = NSTextStorage(attributedString: attrText_Maki)
        let layoutManager_Maki = NSLayoutManager()
        let container_Maki = NSTextContainer(size: label_Maki.bounds.size)
        container_Maki.lineFragmentPadding = 0
        container_Maki.maximumNumberOfLines = label_Maki.numberOfLines
        container_Maki.lineBreakMode = label_Maki.lineBreakMode
        layoutManager_Maki.addTextContainer(container_Maki)
        storage_Maki.addLayoutManager(layoutManager_Maki)

        let charIndex_Maki = layoutManager_Maki.characterIndex(
            for: gesture.location(in: label_Maki),
            in: container_Maki,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        let firstStart_Maki  = prefixLength_Maki
        let firstEnd_Maki    = firstStart_Maki + firstTitleLength_Maki
        let secondStart_Maki = firstEnd_Maki + separatorLength_Maki
        let secondEnd_Maki   = secondStart_Maki + secondTitleLength_Maki

        if (firstStart_Maki..<firstEnd_Maki).contains(charIndex_Maki) {
            ProtocolHelper_Maki.showProtocol_Maki(
                type_Maki: firstProtocol_Maki,
                content_Maki: firstContent_Maki,
                from: vc_Maki
            )
        } else if (secondStart_Maki..<secondEnd_Maki).contains(charIndex_Maki) {
            ProtocolHelper_Maki.showProtocol_Maki(
                type_Maki: secondProtocol_Maki,
                content_Maki: secondContent_Maki,
                from: vc_Maki
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容，根据 content 自动判断展示方式（WebView / 图片 / 文本）
class ProtocolViewController_Maki: UIViewController {

    // MARK: - 属性

    private let protocolType_Maki: ProtocolHelper_Maki.ProtocolType_Maki
    private let content_Maki: String

    private var webView_Maki: WKWebView?
    private var scrollView_Maki: UIScrollView?
    private var activityIndicator_Maki: UIActivityIndicatorView?

    /// 是否为远程 URL
    private var isRemoteURL_Maki: Bool { content_Maki.hasPrefix("http") }

    /// 是否为图片路径
    private var isImage_Maki: Bool {
        ["png", "jpg", "jpeg"].contains { content_Maki.hasSuffix(".\($0)") }
    }

    // MARK: - 初始化

    init(type_Maki: ProtocolHelper_Maki.ProtocolType_Maki, content_Maki: String) {
        self.protocolType_Maki = type_Maki
        self.content_Maki = content_Maki
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Maki()
        loadContent_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - UI设置

    private func setupUI_Maki() {
        view.backgroundColor = .white
        title = protocolType_Maki.title_Maki
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Maki)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black

        if isRemoteURL_Maki {
            setupWebView_Maki()
            setupActivityIndicator_Maki()
        } else {
            setupScrollView_Maki()
        }
    }

    /// 设置 WebView
    private func setupWebView_Maki() {
        let wv_Maki = WKWebView()
        wv_Maki.navigationDelegate = self
        view.addSubview(wv_Maki)
        wv_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        webView_Maki = wv_Maki
    }

    /// 设置 ScrollView（文本和图片共用）
    private func setupScrollView_Maki() {
        let sv_Maki = UIScrollView()
        sv_Maki.showsVerticalScrollIndicator = true
        sv_Maki.alwaysBounceVertical = true
        view.addSubview(sv_Maki)
        sv_Maki.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        scrollView_Maki = sv_Maki
    }

    /// 设置加载指示器
    private func setupActivityIndicator_Maki() {
        let indicator_Maki = UIActivityIndicatorView(style: .large)
        indicator_Maki.color = .gray
        view.addSubview(indicator_Maki)
        indicator_Maki.snp.makeConstraints { $0.center.equalToSuperview() }
        activityIndicator_Maki = indicator_Maki
    }

    // MARK: - 加载内容

    private func loadContent_Maki() {
        if isRemoteURL_Maki {
            loadWebContent_Maki()
        } else if isImage_Maki {
            loadImageContent_Maki()
        } else {
            loadTextContent_Maki()
        }
    }

    /// 加载远程网页
    private func loadWebContent_Maki() {
        guard let url_Maki = URL(string: content_Maki) else { return }
        activityIndicator_Maki?.startAnimating()
        webView_Maki?.load(URLRequest(url: url_Maki))
    }

    /// 加载本地图片（按屏幕宽度等比缩放）
    private func loadImageContent_Maki() {
        guard let sv_Maki = scrollView_Maki,
              let img_Maki = UIImage(named: content_Maki) else { return }

        let iv_Maki = UIImageView()
        iv_Maki.contentMode = .scaleAspectFit
        iv_Maki.image = img_Maki
        sv_Maki.addSubview(iv_Maki)

        let screenWidth_Maki = view.bounds.width
        let displayHeight_Maki = screenWidth_Maki * img_Maki.size.height / img_Maki.size.width
        iv_Maki.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.width.equalTo(screenWidth_Maki)
            $0.height.equalTo(displayHeight_Maki)
            $0.bottom.equalToSuperview()
        }
    }

    /// 加载本地文本
    private func loadTextContent_Maki() {
        guard let sv_Maki = scrollView_Maki else { return }

        let label_Maki = UILabel()
        label_Maki.text = content_Maki
        label_Maki.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label_Maki.textColor = .black
        label_Maki.numberOfLines = 0
        sv_Maki.addSubview(label_Maki)
        label_Maki.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalTo(view.snp.width).offset(-40)
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Maki() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Maki: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Maki?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Maki?.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Maki?.stopAnimating()
        Load_Maki.showError_Maki(message_Maki: "Failed to load content")
    }
}
