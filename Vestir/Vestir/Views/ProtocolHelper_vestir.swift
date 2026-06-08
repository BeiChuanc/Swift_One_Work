import Foundation
import UIKit
import WebKit
import SnapKit

// MARK: - 协议助手类

/// 协议助手类
/// 功能：提供服务条款、隐私政策、EULA等协议的展示功能
/// 设计：支持 WebView、本地文本、本地图片三种展示方式
class ProtocolHelper_Vestir {
    
    // MARK: - 协议类型枚举
    
    /// 协议类型
    enum ProtocolType_Vestir {
        case terms_Vestir       // 服务条款
        case privacy_Vestir     // 隐私政策
        case eula_Vestir        // 最终用户许可协议
        case custom_Vestir(String) // 自定义协议
        
        /// 获取协议标题
        var title_Vestir: String {
            switch self {
            case .terms_Vestir:
                return "Terms of Service"
            case .privacy_Vestir:
                return "Privacy Policy"
            case .eula_Vestir:
                return "EULA"
            case .custom_Vestir(let title_Vestir):
                return title_Vestir
            }
        }
    }
    
    // MARK: - 协议文本配置
    
    /// 协议文本配置类
    /// 功能：配置协议文本的显示样式
    struct ProtocolTextConfig_Vestir {
        /// 普通文本颜色
        var textColor_Vestir: UIColor
        /// 链接文本颜色
        var linkColor_Vestir: UIColor
        /// 字体大小
        var fontSize_Vestir: CGFloat
        /// 字体粗细
        var fontWeight_Vestir: UIFont.Weight
        /// 链接是否有下划线
        var hasUnderline_Vestir: Bool
        /// 前缀文本
        var prefixText_Vestir: String
        /// 分隔符文本
        var separatorText_Vestir: String
        
        /// 默认初始化
        init(
            textColor_Vestir: UIColor = UIColor.gray,
            linkColor_Vestir: UIColor = UIColor.black,
            fontSize_Vestir: CGFloat = 12,
            fontWeight_Vestir: UIFont.Weight = .regular,
            hasUnderline_Vestir: Bool = true,
            prefixText_Vestir: String = "By continuing you agree with ",
            separatorText_Vestir: String = " & "
        ) {
            self.textColor_Vestir = textColor_Vestir
            self.linkColor_Vestir = linkColor_Vestir
            self.fontSize_Vestir = fontSize_Vestir
            self.fontWeight_Vestir = fontWeight_Vestir
            self.hasUnderline_Vestir = hasUnderline_Vestir
            self.prefixText_Vestir = prefixText_Vestir
            self.separatorText_Vestir = separatorText_Vestir
        }
        
        /// 浅色主题配置
        static func light_Vestir() -> ProtocolTextConfig_Vestir {
            return ProtocolTextConfig_Vestir(
                textColor_Vestir: UIColor(white: 0.2, alpha: 0.6),
                linkColor_Vestir: UIColor(white: 0.2, alpha: 1.0)
            )
        }
        
        /// 深色主题配置
        static func dark_Vestir() -> ProtocolTextConfig_Vestir {
            return ProtocolTextConfig_Vestir(
                textColor_Vestir: UIColor(white: 1.0, alpha: 0.6),
                linkColor_Vestir: UIColor(white: 1.0, alpha: 1.0)
            )
        }
    }
    
    // MARK: - 公共方法
    
    /// 显示协议页面
    /// - Parameters:
    ///   - type_Vestir: 协议类型
    ///   - content_Vestir: 协议内容（URL、本地文本或图片路径）
    ///   - viewController_Vestir: 当前视图控制器
    static func showProtocol_Vestir(
        type_Vestir: ProtocolType_Vestir,
        content_Vestir: String,
        from viewController_Vestir: UIViewController
    ) {
        let protocolVC_Vestir = ProtocolViewController_Vestir(
            type_Vestir: type_Vestir,
            content_Vestir: content_Vestir
        )
        viewController_Vestir.navigationController?.pushViewController(
            protocolVC_Vestir,
            animated: true
        )
    }
    
    /// 创建协议文本（带链接）
    /// - Parameters:
    ///   - firstProtocol_Vestir: 第一个协议类型
    ///   - firstContent_Vestir: 第一个协议内容
    ///   - secondProtocol_Vestir: 第二个协议类型
    ///   - secondContent_Vestir: 第二个协议内容
    ///   - config_Vestir: 文本配置
    ///   - viewController_Vestir: 当前视图控制器（用于跳转）
    /// - Returns: 富文本 Label
    static func createProtocolTextLabel_Vestir(
        firstProtocol_Vestir: ProtocolType_Vestir = .terms_Vestir,
        firstContent_Vestir: String,
        secondProtocol_Vestir: ProtocolType_Vestir = .privacy_Vestir,
        secondContent_Vestir: String,
        config_Vestir: ProtocolTextConfig_Vestir = .light_Vestir(),
        from viewController_Vestir: UIViewController
    ) -> UILabel {
        let label_Vestir = UILabel()
        label_Vestir.numberOfLines = 0
        label_Vestir.textAlignment = .center
        label_Vestir.isUserInteractionEnabled = true
        
        // 创建富文本
        let attributedString_Vestir = NSMutableAttributedString()
        
        // 前缀文本
        let prefixAttributes_Vestir: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Vestir.fontSize_Vestir, weight: config_Vestir.fontWeight_Vestir),
            .foregroundColor: config_Vestir.textColor_Vestir
        ]
        attributedString_Vestir.append(NSAttributedString(
            string: config_Vestir.prefixText_Vestir,
            attributes: prefixAttributes_Vestir
        ))
        
        // 第一个协议链接
        var linkAttributes_Vestir: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: config_Vestir.fontSize_Vestir, weight: config_Vestir.fontWeight_Vestir),
            .foregroundColor: config_Vestir.linkColor_Vestir
        ]
        if config_Vestir.hasUnderline_Vestir {
            linkAttributes_Vestir[.underlineStyle] = NSUnderlineStyle.single.rawValue
            linkAttributes_Vestir[.underlineColor] = config_Vestir.linkColor_Vestir
        }
        
        let firstProtocolString_Vestir = NSAttributedString(
            string: firstProtocol_Vestir.title_Vestir,
            attributes: linkAttributes_Vestir
        )
        attributedString_Vestir.append(firstProtocolString_Vestir)
        
        // 分隔符
        attributedString_Vestir.append(NSAttributedString(
            string: config_Vestir.separatorText_Vestir,
            attributes: prefixAttributes_Vestir
        ))
        
        // 第二个协议链接
        let secondProtocolString_Vestir = NSAttributedString(
            string: secondProtocol_Vestir.title_Vestir + ".",
            attributes: linkAttributes_Vestir
        )
        attributedString_Vestir.append(secondProtocolString_Vestir)
        
        label_Vestir.attributedText = attributedString_Vestir
        
        // 添加点击手势
        let tapGesture_Vestir = ProtocolTextTapGesture_Vestir(
            firstProtocol_Vestir: firstProtocol_Vestir,
            firstContent_Vestir: firstContent_Vestir,
            secondProtocol_Vestir: secondProtocol_Vestir,
            secondContent_Vestir: secondContent_Vestir,
            prefixLength_Vestir: config_Vestir.prefixText_Vestir.count,
            firstTitleLength_Vestir: firstProtocol_Vestir.title_Vestir.count,
            separatorLength_Vestir: config_Vestir.separatorText_Vestir.count,
            secondTitleLength_Vestir: secondProtocol_Vestir.title_Vestir.count + 1,
            viewController_Vestir: viewController_Vestir
        )
        label_Vestir.addGestureRecognizer(tapGesture_Vestir)
        
        return label_Vestir
    }
}

// MARK: - 协议文本点击手势

/// 协议文本点击手势识别器
/// 功能：识别点击的是哪个协议链接并跳转
class ProtocolTextTapGesture_Vestir: UITapGestureRecognizer {
    
    private let firstProtocol_Vestir: ProtocolHelper_Vestir.ProtocolType_Vestir
    private let firstContent_Vestir: String
    private let secondProtocol_Vestir: ProtocolHelper_Vestir.ProtocolType_Vestir
    private let secondContent_Vestir: String
    private let prefixLength_Vestir: Int
    private let firstTitleLength_Vestir: Int
    private let separatorLength_Vestir: Int
    private let secondTitleLength_Vestir: Int
    private weak var viewController_Vestir: UIViewController?
    
    init(
        firstProtocol_Vestir: ProtocolHelper_Vestir.ProtocolType_Vestir,
        firstContent_Vestir: String,
        secondProtocol_Vestir: ProtocolHelper_Vestir.ProtocolType_Vestir,
        secondContent_Vestir: String,
        prefixLength_Vestir: Int,
        firstTitleLength_Vestir: Int,
        separatorLength_Vestir: Int,
        secondTitleLength_Vestir: Int,
        viewController_Vestir: UIViewController
    ) {
        self.firstProtocol_Vestir = firstProtocol_Vestir
        self.firstContent_Vestir = firstContent_Vestir
        self.secondProtocol_Vestir = secondProtocol_Vestir
        self.secondContent_Vestir = secondContent_Vestir
        self.prefixLength_Vestir = prefixLength_Vestir
        self.firstTitleLength_Vestir = firstTitleLength_Vestir
        self.separatorLength_Vestir = separatorLength_Vestir
        self.secondTitleLength_Vestir = secondTitleLength_Vestir
        self.viewController_Vestir = viewController_Vestir
        
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Vestir(_:)))
    }
    
    @objc private func handleTap_Vestir(_ gesture: UITapGestureRecognizer) {
        guard let label_Vestir = gesture.view as? UILabel,
              let attributedText_Vestir = label_Vestir.attributedText,
              let viewController_Vestir = viewController_Vestir else { return }
        
        // 计算点击位置
        let location_Vestir = gesture.location(in: label_Vestir)
        
        // 创建文本容器和布局管理器
        let textStorage_Vestir = NSTextStorage(attributedString: attributedText_Vestir)
        let layoutManager_Vestir = NSLayoutManager()
        let textContainer_Vestir = NSTextContainer(size: label_Vestir.bounds.size)
        
        layoutManager_Vestir.addTextContainer(textContainer_Vestir)
        textStorage_Vestir.addLayoutManager(layoutManager_Vestir)
        
        textContainer_Vestir.lineFragmentPadding = 0
        textContainer_Vestir.maximumNumberOfLines = label_Vestir.numberOfLines
        textContainer_Vestir.lineBreakMode = label_Vestir.lineBreakMode
        
        // 获取点击的字符索引
        let characterIndex_Vestir = layoutManager_Vestir.characterIndex(
            for: location_Vestir,
            in: textContainer_Vestir,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 判断点击的是哪个链接
        let firstLinkStart_Vestir = prefixLength_Vestir
        let firstLinkEnd_Vestir = firstLinkStart_Vestir + firstTitleLength_Vestir
        
        let secondLinkStart_Vestir = firstLinkEnd_Vestir + separatorLength_Vestir
        let secondLinkEnd_Vestir = secondLinkStart_Vestir + secondTitleLength_Vestir
        
        if characterIndex_Vestir >= firstLinkStart_Vestir && characterIndex_Vestir < firstLinkEnd_Vestir {
            // 点击第一个协议
            ProtocolHelper_Vestir.showProtocol_Vestir(
                type_Vestir: firstProtocol_Vestir,
                content_Vestir: firstContent_Vestir,
                from: viewController_Vestir
            )
        } else if characterIndex_Vestir >= secondLinkStart_Vestir && characterIndex_Vestir < secondLinkEnd_Vestir {
            // 点击第二个协议
            ProtocolHelper_Vestir.showProtocol_Vestir(
                type_Vestir: secondProtocol_Vestir,
                content_Vestir: secondContent_Vestir,
                from: viewController_Vestir
            )
        }
    }
}

// MARK: - 协议视图控制器

/// 协议视图控制器
/// 功能：展示协议内容（支持 WebView、本地图片、本地文本）
/// 设计：自定义导航栏（与应用其他页面一致，不依赖系统 NavigationBar 显隐状态）
class ProtocolViewController_Vestir: UIViewController {

    // MARK: - 属性

    private let protocolType_Vestir: ProtocolHelper_Vestir.ProtocolType_Vestir
    private let content_Vestir: String

    private var webView_Vestir: WKWebView?
    private var contentScrollView_Vestir: UIScrollView?
    private var activityIndicator_Vestir: UIActivityIndicatorView?

    /// 是否是远程 URL
    private var isRemoteURL_Vestir: Bool {
        return content_Vestir.hasPrefix("http")
    }

    // MARK: - 自定义导航栏组件

    /// 自定义导航栏容器（不依赖系统 NavigationBar，避免 hidden 状态干扰）
    private let customNavBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .white
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.08
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_Vestir.layer.shadowRadius = 10
        return v_Vestir
    }()

    /// 返回按钮
    private let backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let config_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: config_Vestir),
            for: .normal
        )
        btn_Vestir.tintColor = ColorConfig_Vestir.textPrimary_Vestir
        btn_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    /// 标题标签
    private let navTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 导航栏底部渐变分隔线
    private let navBottomLine_Vestir: UIView = UIView()

    // MARK: - 初始化

    init(type_Vestir: ProtocolHelper_Vestir.ProtocolType_Vestir, content_Vestir: String) {
        self.protocolType_Vestir = type_Vestir
        self.content_Vestir = content_Vestir
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar_Vestir()
        setupContentArea_Vestir()
        loadContent_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用自定义导航栏，隐藏系统 NavigationBar 保持一致
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshNavBottomLineGradient_Vestir()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        customNavBar_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 56)
        }
    }

    // MARK: - 自定义导航栏搭建

    /// 搭建自定义导航栏
    private func setupCustomNavBar_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        view.addSubview(customNavBar_Vestir)
        customNavBar_Vestir.addSubview(backBtn_Vestir)
        customNavBar_Vestir.addSubview(navTitleLabel_Vestir)
        customNavBar_Vestir.addSubview(navBottomLine_Vestir)

        navTitleLabel_Vestir.text = protocolType_Vestir.title_Vestir

        backBtn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)

        customNavBar_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 56)
        }

        backBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }

        navTitleLabel_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
        }

        navBottomLine_Vestir.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1.5)
        }
    }

    /// 刷新导航栏底部渐变分隔线
    private func refreshNavBottomLineGradient_Vestir() {
        navBottomLine_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        guard navBottomLine_Vestir.bounds.width > 0 else { return }

        let grad_Vestir = CAGradientLayer()
        grad_Vestir.frame = navBottomLine_Vestir.bounds
        grad_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor,
            UIColor.clear.cgColor
        ]
        grad_Vestir.locations = [0, 0.5, 1.0]
        grad_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        navBottomLine_Vestir.layer.addSublayer(grad_Vestir)
    }

    // MARK: - 内容区搭建

    /// 根据内容类型搭建内容区域
    private func setupContentArea_Vestir() {
        if isRemoteURL_Vestir {
            setupWebView_Vestir()
            setupActivityIndicator_Vestir()
        } else {
            setupScrollView_Vestir()
        }
    }

    private func setupWebView_Vestir() {
        let wv_Vestir = WKWebView()
        wv_Vestir.navigationDelegate = self
        view.addSubview(wv_Vestir)
        wv_Vestir.snp.makeConstraints { make in
            make.top.equalTo(customNavBar_Vestir.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        webView_Vestir = wv_Vestir
    }

    private func setupScrollView_Vestir() {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = true
        sv_Vestir.alwaysBounceVertical = true
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        view.addSubview(sv_Vestir)
        sv_Vestir.snp.makeConstraints { make in
            make.top.equalTo(customNavBar_Vestir.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentScrollView_Vestir = sv_Vestir
    }

    private func setupActivityIndicator_Vestir() {
        let ind_Vestir = UIActivityIndicatorView(style: .large)
        ind_Vestir.color = ColorConfig_Vestir.primaryGradientStart_Vestir
        view.addSubview(ind_Vestir)
        ind_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator_Vestir = ind_Vestir
    }

    // MARK: - 内容加载

    /// 加载内容：优先尝试 Assets 图片，其次远程 URL，最后显示说明文本
    private func loadContent_Vestir() {
        if isRemoteURL_Vestir {
            loadWebContent_Vestir()
        } else if let img_Vestir = UIImage(named: content_Vestir) {
            // 内容字符串对应 Assets 中的图片资源
            loadImageWithUIImage_Vestir(image_Vestir: img_Vestir)
        } else {
            // 无可用内容时显示友好提示
            loadFallbackText_Vestir()
        }
    }

    private func loadWebContent_Vestir() {
        guard let url_Vestir = URL(string: content_Vestir) else { return }
        activityIndicator_Vestir?.startAnimating()
        webView_Vestir?.load(URLRequest(url: url_Vestir))
    }

    /// 从 UIImage 对象加载图片内容
    private func loadImageWithUIImage_Vestir(image_Vestir: UIImage) {
        guard let sv_Vestir = contentScrollView_Vestir else { return }

        let imgView_Vestir = UIImageView()
        imgView_Vestir.contentMode = .scaleAspectFit
        imgView_Vestir.image = image_Vestir
        sv_Vestir.addSubview(imgView_Vestir)

        let screenWidth_Vestir = view.bounds.width
        let ratio_Vestir = image_Vestir.size.height / image_Vestir.size.width
        let displayHeight_Vestir = screenWidth_Vestir * ratio_Vestir

        imgView_Vestir.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(screenWidth_Vestir)
            make.height.equalTo(displayHeight_Vestir)
            make.bottom.equalToSuperview()
        }
    }

    /// 无内容时显示友好说明文字
    private func loadFallbackText_Vestir() {
        guard let sv_Vestir = contentScrollView_Vestir else { return }

        let card_Vestir = UIView()
        card_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        card_Vestir.layer.cornerRadius = 16
        card_Vestir.clipsToBounds = true
        sv_Vestir.addSubview(card_Vestir)

        let icon_Vestir = UIImageView()
        let iconConfig_Vestir = UIImage.SymbolConfiguration(pointSize: 36, weight: .thin)
        icon_Vestir.image = UIImage(
            systemName: "doc.text.fill", withConfiguration: iconConfig_Vestir
        )
        icon_Vestir.tintColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        icon_Vestir.contentMode = .scaleAspectFit

        let titleLbl_Vestir = UILabel()
        titleLbl_Vestir.text = protocolType_Vestir.title_Vestir
        titleLbl_Vestir.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        titleLbl_Vestir.textAlignment = .center

        let descLbl_Vestir = UILabel()
        descLbl_Vestir.text = "This document governs your use of the Vestir application.\n\nBy continuing to use the app, you agree to comply with all applicable terms.\n\nFor the complete agreement, please visit our website."
        descLbl_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descLbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        descLbl_Vestir.numberOfLines = 0
        descLbl_Vestir.textAlignment = .center

        card_Vestir.addSubview(icon_Vestir)
        card_Vestir.addSubview(titleLbl_Vestir)
        card_Vestir.addSubview(descLbl_Vestir)

        card_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
            make.width.equalTo(view).offset(-32)
        }

        icon_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }

        titleLbl_Vestir.snp.makeConstraints { make in
            make.top.equalTo(icon_Vestir.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        descLbl_Vestir.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Vestir.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Vestir() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ProtocolViewController_Vestir: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator_Vestir?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator_Vestir?.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator_Vestir?.stopAnimating()
        Utils_Vestir.showError_Vestir(message_Vestir: "Failed to load content")
    }
}
