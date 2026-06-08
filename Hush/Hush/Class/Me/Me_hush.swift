import UIKit
import SnapKit

// MARK: - 帖子网格单元格

/// 个人中心帖子网格单元格
/// 功能：全出血媒体封面 + 底部渐变标题遮罩 + 举报/删除按钮
/// 设计：大圆角卡片、深色底部渐变保证文字可读、阴影强调层次
class MePostCell_Hush: UICollectionViewCell {

    static let reuseId_Hush = "MePostCell_Hush"

    // MARK: - UI 组件

    /// 外层阴影容器（不裁剪）
    private let shadowView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.12
        v.layer.masksToBounds = false
        return v
    }()

    /// 内容裁剪容器（圆角裁剪）
    private let clipView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        v.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        return v
    }()

    private let mediaView_Hush = MediaDisplayView_Hush()

    /// 底部渐变遮罩
    private let overlayView_Hush = UIView()
    private var overlayGradient_Hush: CAGradientLayer?

    private let titleLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 举报/删除按钮容器
    private let reportContainer_Hush = UIView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayGradient_Hush?.frame = overlayView_Hush.bounds
        shadowView_Hush.layer.shadowPath = UIBezierPath(
            roundedRect: shadowView_Hush.bounds, cornerRadius: 18
        ).cgPath
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        contentView.addSubview(shadowView_Hush)
        shadowView_Hush.addSubview(clipView_Hush)
        clipView_Hush.addSubview(mediaView_Hush)
        clipView_Hush.addSubview(overlayView_Hush)
        clipView_Hush.addSubview(titleLabel_Hush)
        clipView_Hush.addSubview(reportContainer_Hush)

        shadowView_Hush.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }
        clipView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }
        mediaView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }

        overlayView_Hush.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        titleLabel_Hush.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        reportContainer_Hush.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.width.height.equalTo(28)
        }

        let grad = CAGradientLayer()
        grad.colors = [UIColor.clear.cgColor,
                       UIColor(hexstring_Hush: "#1A1B25").withAlphaComponent(0.80).cgColor]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint = CGPoint(x: 0.5, y: 1)
        overlayView_Hush.layer.addSublayer(grad)
        overlayGradient_Hush = grad
    }

    // MARK: - 数据配置

    func configure_Hush(post_hush: TitleModel_Hush, from_hush: UIViewController, completion_hush: (() -> Void)?) {
        let path = post_hush.titleMeidas_Hush.first
        let isVideo = path?.lowercased().hasSuffix(".mp4") == true
                   || path?.lowercased().hasSuffix(".mov") == true
        mediaView_Hush.configure_Hush(mediaPath_Hush: path, isVideo_Hush: isVideo)
        titleLabel_Hush.text = post_hush.title_Hush

        reportContainer_Hush.subviews.forEach { $0.removeFromSuperview() }
        let btn = ReportDeleteHelper_Hush.createPostReportButton_Hush(
            post_Hush: post_hush,
            size_Hush: 17,
            color_Hush: .white,
            from: from_hush,
            completion_Hush: completion_hush
        )
        reportContainer_Hush.addSubview(btn)
        btn.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - 个人中心 Header

/// 个人中心可滚动头部视图
/// 设计：顶部橙红英雄横幅 + 大号渐变环头像（跨越横幅） + 用户名 + 简介 + 三项统计卡片 + 编辑按钮 + 自定义分段 Tab
/// 关键方法：configure_Hush 更新所有数据；onSegmentChanged_Hush / onEditTapped_Hush 事件回调
class MeHeaderView_Hush: UICollectionReusableView {

    static let reuseId_Hush = "MeHeaderView_Hush"

    // MARK: - 回调

    var onSegmentChanged_Hush: ((Int) -> Void)?
    var onEditTapped_Hush: (() -> Void)?

    // MARK: - 英雄横幅组件

    /// 顶部渐变横幅（橙→红）
    private let heroBanner_Hush = UIView()
    private var bannerGradient_Hush: CAGradientLayer?

    /// 横幅装饰光圈（低透明度）
    private let bannerAperture_Hush = UIImageView()

    // MARK: - 头像组件

    /// 最外层白色环（隔离渐变与背景）
    private let avatarOuterRing_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        v.layer.cornerRadius = 58
        return v
    }()

    /// 渐变环
    private let avatarRingView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 53
        return v
    }()
    private var ringGradient_Hush: CAGradientLayer?

    /// 头像组件（自动监听通知刷新）
    private let avatarView_Hush: CurrentUserAvatarView_Hush = {
        let v = CurrentUserAvatarView_Hush()
        v.layer.cornerRadius = 46
        v.clipsToBounds = true
        return v
    }()

    // MARK: - 用户信息组件

    private let nameLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .black)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        lbl.textAlignment = .center
        return lbl
    }()

    private let bioLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.italicSystemFont(ofSize: 13)
        lbl.textColor = ColorConfig_Hush.textSecondary_Hush
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    // MARK: - 统计数据组件（3 张小卡片）

    private let statsRow_Hush = UIStackView()

    // tag 101 = 数值 label，tag 102 = 说明 label
    private lazy var postsCard_Hush  = makeStatCard_Hush(icon: "camera.fill",   title: "Posts")
    private lazy var followCard_Hush = makeStatCard_Hush(icon: "person.2.fill",  title: "Following")
    private lazy var fansCard_Hush   = makeStatCard_Hush(icon: "heart.fill",     title: "Fans")

    // MARK: - 编辑按钮

    private let editButton_Hush: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = false
        btn.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.30
        btn.layer.shadowRadius = 8
        return btn
    }()
    private var editGradient_Hush: CAGradientLayer?

    // MARK: - 自定义分段 Tab

    private let tabContainer_Hush = UIView()
    private let tabIndicator_Hush = UIView()  // 滑动指示器
    private var tabIndicatorGradient_Hush: CAGradientLayer?
    private let tabPostsBtn_Hush = UIButton(type: .system)
    private let tabLikesBtn_Hush = UIButton(type: .system)

    private var selectedTabIndex_Hush: Int = 0

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        bannerGradient_Hush?.frame = heroBanner_Hush.bounds
        ringGradient_Hush?.frame = avatarRingView_Hush.bounds
        editGradient_Hush?.frame = editButton_Hush.bounds
        tabIndicatorGradient_Hush?.frame = tabIndicator_Hush.bounds
        editButton_Hush.layer.shadowPath = UIBezierPath(
            roundedRect: editButton_Hush.bounds, cornerRadius: 22
        ).cgPath
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        setupHeroBanner_Hush()
        setupAvatar_Hush()
        setupUserInfo_Hush()
        setupStatsRow_Hush()
        setupEditButton_Hush()
        setupSegmentTabs_Hush()
        setupConstraints_Hush()
    }

    /// 搭建顶部橙红英雄横幅（含装饰光圈）
    private func setupHeroBanner_Hush() {
        heroBanner_Hush.layer.cornerRadius = 0
        addSubview(heroBanner_Hush)

        let grad_Hush = CAGradientLayer()
        grad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
            UIColor(hexstring_Hush: "#6B1515").cgColor
        ]
        grad_Hush.locations = [0, 0.6, 1]
        grad_Hush.startPoint = CGPoint(x: 0, y: 0)
        grad_Hush.endPoint = CGPoint(x: 1, y: 1)
        heroBanner_Hush.layer.addSublayer(grad_Hush)
        bannerGradient_Hush = grad_Hush

        let apertureConfig_Hush = UIImage.SymbolConfiguration(pointSize: 80, weight: .ultraLight)
        bannerAperture_Hush.image = UIImage(systemName: "camera.aperture", withConfiguration: apertureConfig_Hush)
        bannerAperture_Hush.tintColor = UIColor.white.withAlphaComponent(0.12)
        bannerAperture_Hush.contentMode = .scaleAspectFit
        heroBanner_Hush.addSubview(bannerAperture_Hush)
    }

    /// 搭建头像（三层结构：背景白环 → 渐变环 → 头像）
    private func setupAvatar_Hush() {
        addSubview(avatarOuterRing_Hush)
        avatarOuterRing_Hush.addSubview(avatarRingView_Hush)
        avatarRingView_Hush.addSubview(avatarView_Hush)

        let ringGrad_Hush = CAGradientLayer()
        ringGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        ringGrad_Hush.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Hush.endPoint = CGPoint(x: 1, y: 1)
        ringGrad_Hush.cornerRadius = 53
        avatarRingView_Hush.layer.insertSublayer(ringGrad_Hush, at: 0)
        ringGradient_Hush = ringGrad_Hush
    }

    /// 搭建用户名和简介
    private func setupUserInfo_Hush() {
        addSubview(nameLabel_Hush)
        addSubview(bioLabel_Hush)
    }

    /// 搭建三栏统计数据行（卡片样式）
    private func setupStatsRow_Hush() {
        statsRow_Hush.axis = .horizontal
        statsRow_Hush.distribution = .fillEqually
        statsRow_Hush.spacing = 10
        statsRow_Hush.addArrangedSubview(postsCard_Hush)
        statsRow_Hush.addArrangedSubview(followCard_Hush)
        statsRow_Hush.addArrangedSubview(fansCard_Hush)
        addSubview(statsRow_Hush)
    }

    /// 搭建编辑按钮（渐变背景 + 图标 + 文字）
    /// 使用传统 setTitle/setImage 避免 UIButton.Configuration 与渐变层的层级冲突
    private func setupEditButton_Hush() {
        addSubview(editButton_Hush)

        // 渐变背景层
        let editGrad_Hush = CAGradientLayer()
        editGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        editGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        editGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        editGrad_Hush.cornerRadius = 22
        editButton_Hush.layer.insertSublayer(editGrad_Hush, at: 0)
        editGradient_Hush = editGrad_Hush

        // 使用传统方式设置图标 + 文字，确保渲染在渐变层之上
        let pencilCfg_Hush = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        editButton_Hush.setImage(UIImage(systemName: "pencil", withConfiguration: pencilCfg_Hush), for: .normal)
        editButton_Hush.setTitle("  Edit Profile", for: .normal)
        editButton_Hush.setTitleColor(.white, for: .normal)
        editButton_Hush.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        editButton_Hush.tintColor = .white

        editButton_Hush.addTarget(self, action: #selector(handleEditTapped_Hush), for: .touchUpInside)
    }

    /// 搭建自定义分段 Tab（Posts / Likes）
    private func setupSegmentTabs_Hush() {
        tabContainer_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        addSubview(tabContainer_Hush)

        // 细线分割（Tab 上方）
        let divider_Hush = UIView()
        divider_Hush.backgroundColor = ColorConfig_Hush.divider_Hush
        tabContainer_Hush.addSubview(divider_Hush)
        divider_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        // 滑动指示器（橙色主色背景 + 渐变层，frame 在 layoutSubviews 同步）
        tabIndicator_Hush.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush
        tabIndicator_Hush.layer.cornerRadius = 1.5
        tabContainer_Hush.addSubview(tabIndicator_Hush)
        let indGrad_Hush = CAGradientLayer()
        indGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        indGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        indGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        indGrad_Hush.cornerRadius = 1.5
        tabIndicator_Hush.layer.addSublayer(indGrad_Hush)
        tabIndicatorGradient_Hush = indGrad_Hush

        // Posts 按钮
        setupTabButton_Hush(
            button: tabPostsBtn_Hush,
            icon: "camera.fill", title: "Posts",
            tag: 0
        )
        // Likes 按钮
        setupTabButton_Hush(
            button: tabLikesBtn_Hush,
            icon: "heart.fill", title: "Likes",
            tag: 1
        )

        tabContainer_Hush.addSubview(tabPostsBtn_Hush)
        tabContainer_Hush.addSubview(tabLikesBtn_Hush)

        tabPostsBtn_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().dividedBy(2)
        }
        tabLikesBtn_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().dividedBy(2)
        }
        tabIndicator_Hush.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(3)
            make.width.equalToSuperview().dividedBy(2)
            make.leading.equalToSuperview()
        }
    }

    /// 配置单个 Tab 按钮（图标 + 文字）
    private func setupTabButton_Hush(button: UIButton, icon: String, title: String, tag: Int) {
        var config_Hush = UIButton.Configuration.plain()
        config_Hush.image = UIImage(
            systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        config_Hush.imagePadding = 5
        config_Hush.imagePlacement = .leading
        config_Hush.title = title
        config_Hush.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
            var a = $0; a.font = .systemFont(ofSize: 13, weight: .semibold); return a
        }
        config_Hush.baseForegroundColor = tag == 0
            ? ColorConfig_Hush.primaryGradientStart_Hush
            : ColorConfig_Hush.textPlaceholder_Hush
        button.configuration = config_Hush
        button.tag = tag
        button.addTarget(self, action: #selector(handleTabTapped_Hush(_:)), for: .touchUpInside)
    }

    /// 更新 Tab 选中外观
    private func updateTabAppearance_Hush() {
        [tabPostsBtn_Hush, tabLikesBtn_Hush].forEach { btn_Hush in
            let isSelected_Hush = btn_Hush.tag == selectedTabIndex_Hush
            var config_Hush = btn_Hush.configuration ?? UIButton.Configuration.plain()
            config_Hush.baseForegroundColor = isSelected_Hush
                ? ColorConfig_Hush.primaryGradientStart_Hush
                : ColorConfig_Hush.textPlaceholder_Hush
            btn_Hush.configuration = config_Hush
        }
        // 移动指示器（弹性滑动动画）
        tabIndicator_Hush.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(3)
            make.width.equalToSuperview().dividedBy(2)
            if selectedTabIndex_Hush == 0 {
                make.leading.equalToSuperview()
            } else {
                make.trailing.equalToSuperview()
            }
        }
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 5) {
            self.tabContainer_Hush.layoutIfNeeded()
        }
    }

    /// 构建单个统计数据卡片（图标 + 数值 + 说明）
    private func makeStatCard_Hush(icon: String, title: String) -> UIView {
        let card_Hush = UIView()
        card_Hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        card_Hush.layer.cornerRadius = 14
        card_Hush.layer.shadowColor = UIColor.black.cgColor
        card_Hush.layer.shadowOffset = CGSize(width: 0, height: 2)
        card_Hush.layer.shadowRadius = 6
        card_Hush.layer.shadowOpacity = 0.06

        let iconCfg_Hush = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let iconView_Hush = UIImageView(
            image: UIImage(systemName: icon, withConfiguration: iconCfg_Hush)
        )
        iconView_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
        iconView_Hush.contentMode = .scaleAspectFit
        card_Hush.addSubview(iconView_Hush)

        let valueLabel_Hush = UILabel()
        valueLabel_Hush.text = "0"
        valueLabel_Hush.font = UIFont.systemFont(ofSize: 20, weight: .black)
        valueLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        valueLabel_Hush.textAlignment = .center
        valueLabel_Hush.tag = 101
        card_Hush.addSubview(valueLabel_Hush)

        let titleLabel_Hush = UILabel()
        titleLabel_Hush.text = title
        titleLabel_Hush.font = UIFont.systemFont(ofSize: 11)
        titleLabel_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        titleLabel_Hush.textAlignment = .center
        card_Hush.addSubview(titleLabel_Hush)

        iconView_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(16)
        }
        valueLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(iconView_Hush.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }
        titleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Hush.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(12)
        }

        return card_Hush
    }

    // MARK: - 约束

    private func setupConstraints_Hush() {
        heroBanner_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        bannerAperture_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(-10)
            make.centerY.equalToSuperview().offset(10)
            make.width.height.equalTo(110)
        }
        // 头像外环：垂直居中于横幅底边
        avatarOuterRing_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(heroBanner_Hush.snp.bottom)
            make.width.height.equalTo(116)
        }
        avatarRingView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(106)
        }
        avatarView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(92)
        }
        nameLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(avatarOuterRing_Hush.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bioLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Hush.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        statsRow_Hush.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Hush.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(88)
        }
        editButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Hush.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        tabContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(editButton_Hush.snp.bottom).offset(18)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(46)
        }
    }

    // MARK: - 数据配置

    /// 配置头部视图数据
    func configure_Hush(user_hush: LoginUserModel_Hush, postsCount_hush: Int) {
        nameLabel_Hush.text = user_hush.userName_Hush ?? "Photographer"
        bioLabel_Hush.text = "\"Capturing the world, one shot at a time.\""
        updateStatCard_Hush(postsCard_Hush, value: "\(postsCount_hush)")
        updateStatCard_Hush(followCard_Hush, value: "\(user_hush.userFollow_Hush.count)")
        updateStatCard_Hush(fansCard_Hush, value: "\(user_hush.userLike_Hush.count)")
        if let userId = user_hush.userId_Hush {
            avatarView_Hush.configure_Hush(userId_Hush: userId)
        }
    }

    /// 更新统计卡片数值
    private func updateStatCard_Hush(_ card: UIView, value: String) {
        (card.viewWithTag(101) as? UILabel)?.text = value
    }

    // MARK: - 事件处理

    @objc private func handleEditTapped_Hush() {
        editButton_Hush.animatePressDown_Hush {
            self.editButton_Hush.animatePressUp_Hush {
                self.onEditTapped_Hush?()
            }
        }
    }

    @objc private func handleTabTapped_Hush(_ sender: UIButton) {
        guard sender.tag != selectedTabIndex_Hush else { return }
        selectedTabIndex_Hush = sender.tag
        updateTabAppearance_Hush()
        onSegmentChanged_Hush?(sender.tag)
    }
}

// MARK: - 个人中心视图控制器

/// 个人中心页面
/// 功能：展示当前登录用户头像、昵称、统计数据，支持 Posts/Likes 帖子网格切换
/// 设计：橙红渐变顶部色条 + 集合视图（可滚动头部 + 帖子网格）
/// 关键属性：meModel_Hush（可外部传入，默认使用当前登录用户）
class Me_Hush: UIViewController {

    // MARK: - 外部属性

    var meModel_Hush: LoginUserModel_Hush?

    // MARK: - 私有属性

    private var currentUser_Hush: LoginUserModel_Hush {
        meModel_Hush ?? UserViewModel_Hush.shared_Hush.getCurrentUser_Hush()
    }

    private var segmentIndex_Hush: Int = 0
    private var displayPosts_Hush: [TitleModel_Hush] = []

    // MARK: - 导航栏组件

    private let navBarView_Hush = UIView()

    /// 顶部橙红渐变色条
    private let navTopBand_Hush = UIView()
    private var navTopBandGrad_Hush: CAGradientLayer?

    private let backButton_Hush = BackButton_Hush()

    private let navTitleLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.text = "Profile"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        return lbl
    }()

    /// 设置按钮（橙色主色调）
    private let settingsButton_Hush: UIButton = {
        let btn = UIButton()
        let cfg_Hush = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg_Hush), for: .normal)
        btn.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
        btn.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.10)
        btn.layer.cornerRadius = 19
        btn.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 6
        btn.layer.shadowOpacity = 0.20
        return btn
    }()

    /// VIP 入口按钮（左侧导航位，vip_btn 图标，高度与设置按钮一致，宽度自适应）
    private let vipButton_Hush: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "vip_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - 集合视图

    private lazy var collectionView_Hush: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 100, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(MePostCell_Hush.self, forCellWithReuseIdentifier: MePostCell_Hush.reuseId_Hush)
        cv.register(
            MeHeaderView_Hush.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MeHeaderView_Hush.reuseId_Hush
        )
        return cv
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Hush()
        setupNotifications_Hush()
        updateData_Hush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData_Hush()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navTopBandGrad_Hush?.frame = navTopBand_Hush.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        setupNavBar_Hush()
        view.addSubview(collectionView_Hush)
        collectionView_Hush.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 搭建导航栏（顶部色条 + 标题 + 设置按钮）
    private func setupNavBar_Hush() {
        navBarView_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view.addSubview(navBarView_Hush)

        // 顶部橙红渐变色条
        navBarView_Hush.addSubview(navTopBand_Hush)
        let bandGrad_Hush = CAGradientLayer()
        bandGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        bandGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        bandGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        navTopBand_Hush.layer.addSublayer(bandGrad_Hush)
        navTopBandGrad_Hush = bandGrad_Hush

        navBarView_Hush.addSubview(backButton_Hush)
        navBarView_Hush.addSubview(navTitleLabel_Hush)
        navBarView_Hush.addSubview(vipButton_Hush)
        navBarView_Hush.addSubview(settingsButton_Hush)

        navBarView_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(54)
        }
        navTopBand_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(4)
        }
        backButton_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(36)
        }
        navTitleLabel_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(settingsButton_Hush)
        }
        // VIP 按钮：左侧，高度与设置按钮一致，宽度自适应内容
        vipButton_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(settingsButton_Hush)
            make.height.equalTo(38)
        }
        settingsButton_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(38)
        }

        let showBack = (navigationController?.viewControllers.count ?? 0) > 1
        backButton_Hush.isHidden = !showBack
        backButton_Hush.onTapped_Hush = { [weak self] in
            Navigation_Hush.pop_Hush(from: self)
        }
        vipButton_Hush.addTarget(self, action: #selector(handleVIPTapped_Hush), for: .touchUpInside)
        settingsButton_Hush.addTarget(self, action: #selector(handleSettingsTapped_Hush), for: .touchUpInside)
    }

    // MARK: - 通知监听

    private func setupNotifications_Hush() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Hush),
            name: UserViewModel_Hush.userStateDidChangeNotification_Hush, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Hush),
            name: TitleViewModel_Hush.titleStateDidChangeNotification_Hush, object: nil
        )
    }

    @objc private func handleStateChange_Hush() {
        updateData_Hush()
    }

    // MARK: - 数据更新

    private func updateData_Hush() {
        let isLoggedIn = UserViewModel_Hush.shared_Hush.isLoggedIn_Hush
        let user = currentUser_Hush
        let userId = user.userId_Hush ?? 0

        switch segmentIndex_Hush {
        case 0:
            displayPosts_Hush = isLoggedIn
                ? TitleViewModel_Hush.shared_Hush.getPosts_Hush().filter { $0.titleUserId_Hush == userId }
                : []
        default:
            displayPosts_Hush = isLoggedIn ? user.userLike_Hush : []
        }

        collectionView_Hush.reloadData()
    }

    // MARK: - 事件处理

    /// 点击 VIP 按钮，跳转至 VIP 订阅页
    @objc private func handleVIPTapped_Hush() {
        vipButton_Hush.animatePressDown_Hush {
            self.vipButton_Hush.animatePressUp_Hush {
                Navigation_Hush.toVIPSubscription_Hush(style_hush: .push_hush, animated_hush: true)
            }
        }
    }

    @objc private func handleSettingsTapped_Hush() {
        settingsButton_Hush.animatePressDown_Hush {
            self.settingsButton_Hush.animatePressUp_Hush {
                Navigation_Hush.toSetting_Hush(style_hush: .push_hush, animated_hush: true)
            }
        }
    }
}

// MARK: - UICollectionView 数据源与布局

extension Me_Hush: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayPosts_Hush.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Hush.reuseId_Hush,
            for: indexPath
        ) as! MePostCell_Hush
        let post = displayPosts_Hush[indexPath.item]
        cell.configure_Hush(post_hush: post, from_hush: self) { [weak self] in
            self?.updateData_Hush()
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MeHeaderView_Hush.reuseId_Hush,
            for: indexPath
        ) as! MeHeaderView_Hush

        let user = currentUser_Hush
        let postsCount = TitleViewModel_Hush.shared_Hush.getPosts_Hush().filter {
            $0.titleUserId_Hush == (user.userId_Hush ?? 0)
        }.count
        header.configure_Hush(user_hush: user, postsCount_hush: postsCount)

        header.onSegmentChanged_Hush = { [weak self] index in
            self?.segmentIndex_Hush = index
            self?.updateData_Hush()
        }
        header.onEditTapped_Hush = {
            Navigation_Hush.toEditInfo_Hush(style_hush: .push_hush, animated_hush: true)
        }
        return header
    }

    /// 2 列网格，宽高比 1:1.3
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing: CGFloat = 10 + 10 + 8
        let itemWidth = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: itemWidth, height: itemWidth * 1.3)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let header = MeHeaderView_Hush()
        header.configure_Hush(user_hush: currentUser_Hush, postsCount_hush: displayPosts_Hush.count)
        let size = header.systemLayoutSizeFitting(
            CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: collectionView.bounds.width, height: size.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = displayPosts_Hush[indexPath.item]
        Navigation_Hush.toTitleDetail_Hush(titleModel_hush: post, style_hush: .push_hush, animated_hush: true)
    }
}
