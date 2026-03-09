import Foundation
import UIKit
import SnapKit

// MARK: - 设置页面
// 核心作用：展示应用设置项，包含 Terms of Service、Privacy Policy 协议浏览，
//           以及登出与删除账号两个危险操作入口。
// 设计思路：渐变 Header + 分组白卡列表；
//           协议项通过 ProtocolHelper_Moode 展示 Assets 中对应图片；
//           危险操作通过 UIAlertController 二次确认后调用 UserViewModel 处理。
// 关键属性：所有业务逻辑均调用 UserViewModel_Moode.shared_Moode，界面不持有状态。

/// 设置页控制器
class Setting_Moode: UIViewController {
    
    // MARK: - UI组件
    
    /// 主滚动容器
    private let scrollView_Moode: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    /// 内容容器
    private let contentView_Moode = UIView()
    
    /// 顶部渐变 Header
    private let headerBg_Moode: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    
    /// Header 渐变层
    private let headerGradient_Moode = CAGradientLayer()
    
    /// 装饰圆1
    private let decCircle1_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 60
        return v
    }()
    
    /// 装饰圆2
    private let decCircle2_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 45
        return v
    }()
    
    /// 返回按钮
    private let backBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()
    
    /// 页面标题
    private let pageTitleLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "Settings"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        lbl.textColor = .white
        return lbl
    }()

    /// 页面副标题
    private let pageSubLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "Manage your account & preferences"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.78)
        return lbl
    }()
    
    /// 装饰 emoji
    private let decEmoji_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "⚙️"
        lbl.font = UIFont.systemFont(ofSize: 30)
        lbl.alpha = 0.5
        return lbl
    }()
    
    /// 内容白背景卡片区域
    private let contentCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    // MARK: 协议分组卡片
    
    /// 协议分组标题
    private let legalTitle_Moode = makeGroupTitle_Moode(text: "Legal")
    
    /// 协议组卡片
    private let legalCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Moode: "#7C6FF7").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 10
        return v
    }()
    
    /// Terms of Service 行
    private let termsRow_Moode = SettingRow_Moode(
        icon_moode: "doc.text.fill",
        iconColor_moode: UIColor(hexstring_Moode: "#7C6FF7"),
        title_moode: "Terms of Service",
        showArrow_moode: true,
        dangerStyle_moode: false
    )
    
    /// 分隔线
    private let legalDivider_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        return v
    }()
    
    /// Privacy Policy 行
    private let privacyRow_Moode = SettingRow_Moode(
        icon_moode: "hand.raised.fill",
        iconColor_moode: UIColor(hexstring_Moode: "#9F8BFC"),
        title_moode: "Privacy Policy",
        showArrow_moode: true,
        dangerStyle_moode: false
    )
    
    // MARK: 账号分组卡片
    
    /// 账号分组标题
    private let accountTitle_Moode = makeGroupTitle_Moode(text: "Account")
    
    /// 账号操作卡片
    private let accountCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Moode: "#7C6FF7").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 10
        return v
    }()
    
    /// 登出行
    private let logoutRow_Moode = SettingRow_Moode(
        icon_moode: "arrow.right.square.fill",
        iconColor_moode: UIColor(hexstring_Moode: "#F6AD55"),
        title_moode: "Log Out",
        showArrow_moode: false,
        dangerStyle_moode: false
    )
    
    /// 分隔线2
    private let accountDivider_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        return v
    }()
    
    /// 删除账号行
    private let deleteRow_Moode = SettingRow_Moode(
        icon_moode: "trash.fill",
        iconColor_moode: UIColor(hexstring_Moode: "#FC8181"),
        title_moode: "Delete Account",
        showArrow_moode: false,
        dangerStyle_moode: true
    )
    
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Moode()
        bindActions_Moode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Moode.frame = headerBg_Moode.bounds
        startDecorAnimation_Moode()
    }
    
    // MARK: - UI 搭建
    
    /// 搭建全部 UI
    private func setupUI_Moode() {
        view.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        
        view.addSubview(scrollView_Moode)
        scrollView_Moode.addSubview(contentView_Moode)
        
        scrollView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Moode.contentLayoutGuide)
            make.width.equalTo(scrollView_Moode.frameLayoutGuide)
        }
        
        setupHeaderUI_Moode()
        setupBodyUI_Moode()
    }
    
    /// 搭建 Header（与 EditInfo 保持一致的紧凑导航栏风格）
    private func setupHeaderUI_Moode() {
        contentView_Moode.addSubview(headerBg_Moode)
        headerBg_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(130)
        }

        headerGradient_Moode.colors = [
            UIColor(hexstring_Moode: "#7C6FF7").cgColor,
            UIColor(hexstring_Moode: "#A78BFA").cgColor,
            UIColor(hexstring_Moode: "#C4B5FD").cgColor
        ]
        headerGradient_Moode.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Moode.endPoint   = CGPoint(x: 1, y: 1)
        headerBg_Moode.layer.insertSublayer(headerGradient_Moode, at: 0)

        // 装饰圆
        headerBg_Moode.addSubview(decCircle1_Moode)
        decCircle1_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(30)
        }

        headerBg_Moode.addSubview(decCircle2_Moode)
        decCircle2_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.bottom.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(-20)
        }

        // 装饰 emoji（右侧，不挤占标题区域）
        headerBg_Moode.addSubview(decEmoji_Moode)
        decEmoji_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 返回按钮（安全区顶部对齐）
        headerBg_Moode.addSubview(backBtn_Moode)
        backBtn_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.width.height.equalTo(36)
        }
        backBtn_Moode.addTarget(self, action: #selector(handleBack_Moode), for: .touchUpInside)

        // 标题：返回按钮垂直中心上方
        headerBg_Moode.addSubview(pageTitleLbl_Moode)
        pageTitleLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(backBtn_Moode.snp.right).offset(12)
            make.bottom.equalTo(backBtn_Moode.snp.centerY).offset(-1)
            make.right.lessThanOrEqualTo(decEmoji_Moode.snp.left).offset(-8)
        }

        // 副标题：返回按钮垂直中心下方
        headerBg_Moode.addSubview(pageSubLbl_Moode)
        pageSubLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(backBtn_Moode.snp.right).offset(12)
            make.top.equalTo(backBtn_Moode.snp.centerY).offset(2)
            make.right.lessThanOrEqualTo(decEmoji_Moode.snp.left).offset(-8)
        }
    }
    
    /// 搭建主体内容
    private func setupBodyUI_Moode() {
        contentView_Moode.addSubview(contentCard_Moode)
        contentCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(headerBg_Moode.snp.bottom).offset(-16)
            make.left.right.bottom.equalToSuperview()
        }
        
        // MARK: 协议分组
        contentCard_Moode.addSubview(legalTitle_Moode)
        legalTitle_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
        }
        
        contentCard_Moode.addSubview(legalCard_Moode)
        legalCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(legalTitle_Moode.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        legalCard_Moode.addSubview(termsRow_Moode)
        termsRow_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        legalCard_Moode.addSubview(legalDivider_Moode)
        legalDivider_Moode.snp.makeConstraints { make in
            make.top.equalTo(termsRow_Moode.snp.bottom)
            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        legalCard_Moode.addSubview(privacyRow_Moode)
        privacyRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(legalDivider_Moode.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        
        // MARK: 账号分组
        contentCard_Moode.addSubview(accountTitle_Moode)
        accountTitle_Moode.snp.makeConstraints { make in
            make.top.equalTo(legalCard_Moode.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(24)
        }
        
        contentCard_Moode.addSubview(accountCard_Moode)
        accountCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(accountTitle_Moode.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        accountCard_Moode.addSubview(logoutRow_Moode)
        logoutRow_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        accountCard_Moode.addSubview(accountDivider_Moode)
        accountDivider_Moode.snp.makeConstraints { make in
            make.top.equalTo(logoutRow_Moode.snp.bottom)
            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        accountCard_Moode.addSubview(deleteRow_Moode)
        deleteRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(accountDivider_Moode.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        
        // accountCard 作为内容区最后一个元素，补充底部约束
        accountCard_Moode.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    // MARK: - 工厂方法
    
    /// 创建分组标题标签
    /// - Parameter text_moode: 标题文字
    /// - Returns: 配置好的 UILabel
    private static func makeGroupTitle_Moode(text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text.uppercased()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .heavy)
        lbl.textColor = UIColor(hexstring_Moode: "#9E8EF5")
        lbl.letterSpacing_Moode(spacing_moode: 1.2)
        return lbl
    }
    
    // MARK: - 绑定事件
    
    /// 绑定所有行的点击事件
    private func bindActions_Moode() {
        termsRow_Moode.onTap_Moode = { [weak self] in
            self?.handleTerms_Moode()
        }
        privacyRow_Moode.onTap_Moode = { [weak self] in
            self?.handlePrivacy_Moode()
        }
        logoutRow_Moode.onTap_Moode = { [weak self] in
            self?.handleLogout_Moode()
        }
        deleteRow_Moode.onTap_Moode = { [weak self] in
            self?.handleDeleteAccount_Moode()
        }
    }
    
    // MARK: - 装饰动画
    
    private var decorAnimStarted_Moode = false
    
    /// 启动装饰 emoji 浮动动画（仅执行一次）
    private func startDecorAnimation_Moode() {
        guard !decorAnimStarted_Moode else { return }
        decorAnimStarted_Moode = true
        UIView.animate(withDuration: 2.5, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.decEmoji_Moode.transform = CGAffineTransform(translationX: 0, y: -8)
        }
    }
    
    // MARK: - 事件处理
    
    /// 点击返回
    @objc private func handleBack_Moode() {
        Navigation_Moode.pop_Moode(from: self)
    }
    
    /// 点击 Terms of Service
    private func handleTerms_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ProtocolHelper_Moode.showProtocol_Moode(
            type_Moode: .terms_Moode,
            content_Moode: "terms.png",
            from: self
        )
    }
    
    /// 点击 Privacy Policy
    private func handlePrivacy_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ProtocolHelper_Moode.showProtocol_Moode(
            type_Moode: .privacy_Moode,
            content_Moode: "privacy.png",
            from: self
        )
    }
    
    /// 点击登出
    private func handleLogout_Moode() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            UserViewModel_Moode.shared_Moode.logout_Moode(logoutType_moode: .logout_moode)
        })
        present(alert, animated: true)
    }
    
    /// 点击删除账号
    private func handleDeleteAccount_Moode() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Your account will be permanently deleted after 24 hours. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            UserViewModel_Moode.shared_Moode.logout_Moode(logoutType_moode: .delete_moode)
        })
        present(alert, animated: true)
    }
}

// MARK: - SettingRow_Moode

/// 设置列表行组件
/// 功能：可复用的设置项行，包含图标、标题、可选箭头；
///       支持普通样式和危险操作（红色）样式
class SettingRow_Moode: UIView {
    
    // MARK: - 属性
    
    /// 点击回调
    var onTap_Moode: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 图标背景容器
    private let iconBg_Moode: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        return v
    }()
    
    /// 图标视图
    private let iconView_Moode: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 标题标签
    private let titleLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return lbl
    }()
    
    /// 右侧箭头
    private let arrowView_Moode: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: cfg))
        iv.tintColor = UIColor(hexstring_Moode: "#BBAAEE")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // MARK: - 初始化
    
    /// 初始化设置行
    /// - Parameters:
    ///   - icon_moode: SF Symbol 图标名
    ///   - iconColor_moode: 图标主色
    ///   - title_moode: 标题文字
    ///   - showArrow_moode: 是否显示右箭头
    ///   - dangerStyle_moode: 是否使用危险（红色）样式
    init(icon_moode: String,
         iconColor_moode: UIColor,
         title_moode: String,
         showArrow_moode: Bool,
         dangerStyle_moode: Bool) {
        super.init(frame: .zero)
        
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iconView_Moode.image = UIImage(systemName: icon_moode, withConfiguration: cfg)
        iconView_Moode.tintColor = .white
        iconBg_Moode.backgroundColor = iconColor_moode
        
        titleLbl_Moode.text = title_moode
        titleLbl_Moode.textColor = dangerStyle_moode
            ? UIColor(hexstring_Moode: "#FC8181")
            : UIColor(hexstring_Moode: "#2D2D3A")
        
        arrowView_Moode.isHidden = !showArrow_moode
        
        setupRowUI_Moode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI搭建
    
    /// 搭建行内部 UI
    private func setupRowUI_Moode() {
        addSubview(iconBg_Moode)
        iconBg_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }
        
        iconBg_Moode.addSubview(iconView_Moode)
        iconView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(17)
        }
        
        addSubview(titleLbl_Moode)
        titleLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(iconBg_Moode.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }
        
        addSubview(arrowView_Moode)
        arrowView_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        // 点击手势 + 按下反馈
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Moode))
        addGestureRecognizer(tap)
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Moode() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.55
        } completion: { _ in
            UIView.animate(withDuration: 0.15) { self.alpha = 1 }
        }
        onTap_Moode?()
    }
}

// MARK: - UILabel 字间距扩展辅助

private extension UILabel {
    /// 设置字间距
    /// - Parameter spacing_moode: 字间距值
    func letterSpacing_Moode(spacing_moode: CGFloat) {
        guard let text = text else { return }
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.kern, value: spacing_moode, range: NSRange(location: 0, length: attr.length))
        attributedText = attr
    }
}
