import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA 等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Lens {

    // MARK: - 协议类型枚举

    /// 协议类型
    enum ProtocolType_Lens {
        case terms_Lens
        case privacy_Lens
        case eula_Lens
        case custom_Lens(String)

        /// 协议标题
        var title_Lens: String {
            switch self {
            case .terms_Lens:   return "Terms of Service"
            case .privacy_Lens: return "Privacy Policy"
            case .eula_Lens:    return "EULA"
            case .custom_Lens(let title_Lens): return title_Lens
            }
        }
    }

    // MARK: - 协议文本配置

    /// 协议文本展示样式配置
    struct ProtocolTextConfig_Lens {
        var textColor_Lens: UIColor
        var linkColor_Lens: UIColor
        var fontSize_Lens: CGFloat
        var fontWeight_Lens: UIFont.Weight
        var hasUnderline_Lens: Bool
        var prefixText_Lens: String
        var separatorText_Lens: String

        init(
            textColor_Lens: UIColor = UIColor.gray,
            linkColor_Lens: UIColor = UIColor.black,
            fontSize_Lens: CGFloat = 12,
            fontWeight_Lens: UIFont.Weight = .regular,
            hasUnderline_Lens: Bool = true,
            prefixText_Lens: String = "By continuing you agree with ",
            separatorText_Lens: String = " & "
        ) {
            self.textColor_Lens = textColor_Lens
            self.linkColor_Lens = linkColor_Lens
            self.fontSize_Lens = fontSize_Lens
            self.fontWeight_Lens = fontWeight_Lens
            self.hasUnderline_Lens = hasUnderline_Lens
            self.prefixText_Lens = prefixText_Lens
            self.separatorText_Lens = separatorText_Lens
        }

        /// 浅色主题配置
        static func light_Lens() -> ProtocolTextConfig_Lens {
            ProtocolTextConfig_Lens(
                textColor_Lens: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Lens: UIColor(white: 0.2, alpha: 1.0)
            )
        }

        /// 深色主题配置
        static func dark_Lens() -> ProtocolTextConfig_Lens {
            ProtocolTextConfig_Lens(
                textColor_Lens: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Lens: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }

    // MARK: - 公共方法

    /// 跳转到协议详情页
    /// 参数：
    /// - type_Lens: 协议类型
    /// - content_Lens: 协议内容（URL、本地文本或图片路径）
    /// - viewController_Lens: 发起跳转的视图控制器
    static func showProtocol_Lens(
        type_Lens: ProtocolType_Lens,
        content_Lens: String,
        from viewController_Lens: UIViewController
    ) {
        let vc_Lens = ProtocolViewController_Lens(type_Lens: type_Lens, content_Lens: content_Lens)
        viewController_Lens.navigationController?.pushViewController(vc_Lens, animated: true)
    }

    /// 创建带可点击协议链接的富文本 Label
    /// 参数：
    /// - firstProtocol_Lens: 第一个协议类型，默认服务条款
    /// - firstContent_Lens: 第一个协议内容
    /// - secondProtocol_Lens: 第二个协议类型，默认隐私政策
    /// - secondContent_Lens: 第二个协议内容
    /// - config_Lens: 文本样式配置，默认浅色
    /// - viewController_Lens: 点击跳转的目标控制器
    /// 返回值：配置好手势的富文本 UILabel
    static func createProtocolTextLabel_Lens(
        firstProtocol_Lens: ProtocolType_Lens = .terms_Lens,
        firstContent_Lens: String,
        secondProtocol_Lens: ProtocolType_Lens = .privacy_Lens,
        secondContent_Lens: String,
        config_Lens: ProtocolTextConfig_Lens = .light_Lens(),
        from viewController_Lens: UIViewController
    ) -> UILabel {
        let label_Lens = UILabel()
        label_Lens.numberOfLines = 0
        label_Lens.textAlignment = .center
        label_Lens.isUserInteractionEnabled = true

        // 共享字体（前缀、分隔符、链接均使用同一字体）
        let font_Lens = UIFont.systemFont(ofSize: config_Lens.fontSize_Lens, weight: config_Lens.fontWeight_Lens)

        let prefixAttrs_Lens: [NSAttributedString.Key: Any] = [
            .font: font_Lens,
            .foregroundColor: config_Lens.textColor_Lens
        ]

        var linkAttrs_Lens: [NSAttributedString.Key: Any] = [
            .font: font_Lens,
            .foregroundColor: config_Lens.linkColor_Lens
        ]
        if config_Lens.hasUnderline_Lens {
            linkAttrs_Lens[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttrs_Lens[.underlineColor] = config_Lens.linkColor_Lens
        }

        let text_Lens = NSMutableAttributedString()
        text_Lens.append(NSAttributedString(string: config_Lens.prefixText_Lens, attributes: prefixAttrs_Lens))
        text_Lens.append(NSAttributedString(string: firstProtocol_Lens.title_Lens, attributes: linkAttrs_Lens))
        text_Lens.append(NSAttributedString(string: config_Lens.separatorText_Lens, attributes: prefixAttrs_Lens))
        text_Lens.append(NSAttributedString(string: secondProtocol_Lens.title_Lens + ".", attributes: linkAttrs_Lens))
        label_Lens.attributedText = text_Lens

        label_Lens.addGestureRecognizer(ProtocolTextTapGesture_Lens(
            firstProtocol_Lens: firstProtocol_Lens,
            firstContent_Lens: firstContent_Lens,
            secondProtocol_Lens: secondProtocol_Lens,
            secondContent_Lens: secondContent_Lens,
            prefixLength_Lens: config_Lens.prefixText_Lens.count,
            firstTitleLength_Lens: firstProtocol_Lens.title_Lens.count,
            separatorLength_Lens: config_Lens.separatorText_Lens.count,
            secondTitleLength_Lens: secondProtocol_Lens.title_Lens.count + 1,
            viewController_Lens: viewController_Lens
        ))
        return label_Lens
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击位置所属的协议链接并跳转到对应详情页
class ProtocolTextTapGesture_Lens: UITapGestureRecognizer {

    private let firstProtocol_Lens: ProtocolHelper_Lens.ProtocolType_Lens
    private let firstContent_Lens: String
    private let secondProtocol_Lens: ProtocolHelper_Lens.ProtocolType_Lens
    private let secondContent_Lens: String
    private let prefixLength_Lens: Int
    private let firstTitleLength_Lens: Int
    private let separatorLength_Lens: Int
    private let secondTitleLength_Lens: Int
    private weak var viewController_Lens: UIViewController?

    init(
        firstProtocol_Lens: ProtocolHelper_Lens.ProtocolType_Lens,
        firstContent_Lens: String,
        secondProtocol_Lens: ProtocolHelper_Lens.ProtocolType_Lens,
        secondContent_Lens: String,
        prefixLength_Lens: Int,
        firstTitleLength_Lens: Int,
        separatorLength_Lens: Int,
        secondTitleLength_Lens: Int,
        viewController_Lens: UIViewController
    ) {
        self.firstProtocol_Lens = firstProtocol_Lens
        self.firstContent_Lens = firstContent_Lens
        self.secondProtocol_Lens = secondProtocol_Lens
        self.secondContent_Lens = secondContent_Lens
        self.prefixLength_Lens = prefixLength_Lens
        self.firstTitleLength_Lens = firstTitleLength_Lens
        self.separatorLength_Lens = separatorLength_Lens
        self.secondTitleLength_Lens = secondTitleLength_Lens
        self.viewController_Lens = viewController_Lens
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Lens(_:)))
    }

    @objc private func handleTap_Lens(_ gesture: UITapGestureRecognizer) {
        guard let label_Lens = gesture.view as? UILabel,
              let attrText_Lens = label_Lens.attributedText,
              let vc_Lens = viewController_Lens else { return }

        // 构建文本布局以确定点击字符索引
        let storage_Lens = NSTextStorage(attributedString: attrText_Lens)
        let layoutManager_Lens = NSLayoutManager()
        let container_Lens = NSTextContainer(size: label_Lens.bounds.size)
        container_Lens.lineFragmentPadding = 0
        container_Lens.maximumNumberOfLines = label_Lens.numberOfLines
        container_Lens.lineBreakMode = label_Lens.lineBreakMode
        layoutManager_Lens.addTextContainer(container_Lens)
        storage_Lens.addLayoutManager(layoutManager_Lens)

        let charIndex_Lens = layoutManager_Lens.characterIndex(
            for: gesture.location(in: label_Lens),
            in: container_Lens,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        let firstStart_Lens  = prefixLength_Lens
        let firstEnd_Lens    = firstStart_Lens + firstTitleLength_Lens
        let secondStart_Lens = firstEnd_Lens + separatorLength_Lens
        let secondEnd_Lens   = secondStart_Lens + secondTitleLength_Lens

        if (firstStart_Lens..<firstEnd_Lens).contains(charIndex_Lens) {
            ProtocolHelper_Lens.showProtocol_Lens(
                type_Lens: firstProtocol_Lens,
                content_Lens: firstContent_Lens,
                from: vc_Lens
            )
        } else if (secondStart_Lens..<secondEnd_Lens).contains(charIndex_Lens) {
            ProtocolHelper_Lens.showProtocol_Lens(
                type_Lens: secondProtocol_Lens,
                content_Lens: secondContent_Lens,
                from: vc_Lens
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容，根据 content 自动判断展示方式（WebView / 图片 / 文本）
class ProtocolViewController_Lens: UIViewController {

    // MARK: - 属性

    private let protocolType_Lens: ProtocolHelper_Lens.ProtocolType_Lens
    private let content_Lens: String

    private var webView_Lens: WKWebView?
    private var scrollView_Lens: UIScrollView?
    private var activityIndicator_Lens: UIActivityIndicatorView?

    /// 是否为远程 URL
    private var isRemoteURL_Lens: Bool { content_Lens.hasPrefix("http") }

    /// 是否为图片路径
    private var isImage_Lens: Bool {
        ["png", "jpg", "jpeg"].contains { content_Lens.hasSuffix(".\($0)") }
    }

    // MARK: - 初始化

    init(type_Lens: ProtocolHelper_Lens.ProtocolType_Lens, content_Lens: String) {
        self.protocolType_Lens = type_Lens
        self.content_Lens = content_Lens
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        loadContent_Lens()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - UI设置

    private func setupUI_Lens() {
        view.backgroundColor = .white
        title = protocolType_Lens.title_Lens
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Lens)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black

        if isRemoteURL_Lens {
            setupWebView_Lens()
            setupActivityIndicator_Lens()
        } else {
            setupScrollView_Lens()
        }
    }

    /// 设置 WebView
    private func setupWebView_Lens() {
        let wv_Lens = WKWebView()
        wv_Lens.navigationDelegate = self
        view.addSubview(wv_Lens)
        wv_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        webView_Lens = wv_Lens
    }

    /// 设置 ScrollView（文本和图片共用）
    private func setupScrollView_Lens() {
        let sv_Lens = UIScrollView()
        sv_Lens.showsVerticalScrollIndicator = true
        sv_Lens.alwaysBounceVertical = true
        view.addSubview(sv_Lens)
        sv_Lens.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        scrollView_Lens = sv_Lens
    }

    /// 设置加载指示器
    private func setupActivityIndicator_Lens() {
        let indicator_Lens = UIActivityIndicatorView(style: .large)
        indicator_Lens.color = .gray
        view.addSubview(indicator_Lens)
        indicator_Lens.snp.makeConstraints { $0.center.equalToSuperview() }
        activityIndicator_Lens = indicator_Lens
    }

    // MARK: - 加载内容

    private func loadContent_Lens() {
        if isRemoteURL_Lens {
            loadWebContent_Lens()
        } else if isImage_Lens {
            loadImageContent_Lens()
        } else {
            loadTextContent_Lens()
        }
    }

    /// 加载远程网页
    private func loadWebContent_Lens() {
        guard let url_Lens = URL(string: content_Lens) else { return }
        activityIndicator_Lens?.startAnimating()
        webView_Lens?.load(URLRequest(url: url_Lens))
    }

    /// 加载本地图片（按屏幕宽度等比缩放）
    private func loadImageContent_Lens() {
        guard let sv_Lens = scrollView_Lens,
              let img_Lens = UIImage(named: content_Lens) else { return }

        let iv_Lens = UIImageView()
        iv_Lens.contentMode = .scaleAspectFit
        iv_Lens.image = img_Lens
        sv_Lens.addSubview(iv_Lens)

        let screenWidth_Lens = view.bounds.width
        let displayHeight_Lens = screenWidth_Lens * img_Lens.size.height / img_Lens.size.width
        iv_Lens.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.width.equalTo(screenWidth_Lens)
            $0.height.equalTo(displayHeight_Lens)
            $0.bottom.equalToSuperview()
        }
    }

    /// 加载本地文本
    private func loadTextContent_Lens() {
        guard let sv_Lens = scrollView_Lens else { return }

        let label_Lens = UILabel()
        label_Lens.text = content_Lens
        label_Lens.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label_Lens.textColor = .black
        label_Lens.numberOfLines = 0
        sv_Lens.addSubview(label_Lens)
        label_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalTo(view.snp.width).offset(-40)
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Lens() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Lens: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Lens?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Lens?.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Lens?.stopAnimating()
        Load_Lens.showError_Lens(message_Lens: "Failed to load content")
    }
}
