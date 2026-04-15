import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心页面
/// 核心作用：展示其他用户资料、关注状态和该用户的帖子内容
/// 设计思路：ScrollView 从 view.top 起始，透明导航栏与 Banner 渐变无缝融合；
///          Banner 覆盖状态栏 + 导航栏区域，包含多层装饰（光球 + 闪光图标 + 纹理标签）；
///          Banner 底部悬浮头像环，下方白底区（名称 + 角标 + 简介 + 统计 + 操作按钮）；
///          底部帖子列表 / 空状态，contentInsetAdjustmentBehavior = .never 保证布局精确
class UserInfo_Epoch: UIViewController {

    // MARK: - 公开属性

    /// 用户模型
    var userModel_Epoch: PrewUserModel_Epoch?

    /// 入口来源
    var entrySource_Epoch: UserInfoEntrySource_Epoch = .normal_epoch

    // MARK: - 布局容器

    private let scrollView_Epoch   = UIScrollView()
    private let contentView_Epoch  = UIView()

    // MARK: - Banner 区

    private let bannerView_Epoch             = UIView()
    private let bannerGradient_Epoch         = CAGradientLayer()
    private let bannerGlowTopRight_Epoch     = UIView()
    private let bannerGlowBottomLeft_Epoch   = UIView()
    private let bannerGlowCenter_Epoch       = UIView()
    /// 记录 Banner 高度约束，viewDidLayoutSubviews 中按安全区修正
    private var bannerHeightConstraint_Epoch: Constraint?

    // MARK: - 悬浮头像（跨 Banner / 信息区）

    private let avatarRingView_Epoch  = UIView()
    private let avatarRingGrad_Epoch  = CAGradientLayer()
    private let avatarSep_Epoch       = UIView()
    private let avatarView_Epoch      = UserAvatarView_Epoch()

    // MARK: - 名称 & 角标（Banner 下方）

    private let nameLabel_Epoch   = UILabel()
    private let creatorBadge_Epoch = PaddingLabel_Epoch()

    // MARK: - 信息卡（简介 + 统计 + 操作）

    private let infoCard_Epoch      = SurfaceCardView_Epoch()
    private let introLabel_Epoch    = UILabel()
    private let statStackView_Epoch = UIStackView()
    private let dividerLine_Epoch   = UIView()
    private let followButton_Epoch  = PrimaryActionButton_Epoch(title_Epoch: "Follow")
    private let messageButton_Epoch = UIButton(type: .system)

    // MARK: - 帖子区

    private let postsSectionView_Epoch  = UIView()
    private let postsCountBadge_Epoch   = PaddingLabel_Epoch()
    private let postsStackView_Epoch    = UIStackView()
    private let emptyStateView_Epoch    = EmptyStateView_Epoch()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        applyTransparentNavBar_Epoch()
        reloadData_Epoch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreNavBar_Epoch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        setupScrollView_Epoch()
        setupBanner_Epoch()
        setupAvatarRing_Epoch()
        setupNameArea_Epoch()
        setupInfoCard_Epoch()
        setupPostsSection_Epoch()
        setupNavigation_Epoch()
        setupNotifications_Epoch()
        reloadData_Epoch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 根据安全区动态修正 Banner 高度（覆盖状态栏 + 导航栏）
        let topInset_epoch = view.safeAreaInsets.top
        let navHeight_epoch: CGFloat = navigationController?.navigationBar.frame.height ?? 44
        bannerHeightConstraint_Epoch?.update(offset: topInset_epoch + navHeight_epoch + 52)
        // 更新渐变 frame
        bannerGradient_Epoch.frame = bannerView_Epoch.bounds
        avatarRingGrad_Epoch.frame = avatarRingView_Epoch.bounds
        // 圆形裁剪
        avatarRingView_Epoch.layer.cornerRadius   = avatarRingView_Epoch.bounds.width / 2
        avatarSep_Epoch.layer.cornerRadius        = avatarSep_Epoch.bounds.width / 2
        bannerGlowTopRight_Epoch.layer.cornerRadius   = bannerGlowTopRight_Epoch.bounds.width / 2
        bannerGlowBottomLeft_Epoch.layer.cornerRadius = bannerGlowBottomLeft_Epoch.bounds.width / 2
        bannerGlowCenter_Epoch.layer.cornerRadius     = bannerGlowCenter_Epoch.bounds.width / 2
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 当前用户帖子

    private var userPosts_Epoch: [TitleModel_Epoch] {
        guard let userModel_Epoch = userModel_Epoch else { return [] }
        return TitleViewModel_Epoch.shared_Epoch.getUserPosts_Epoch(user_epoch: userModel_Epoch)
    }

    // MARK: - 界面搭建

    /// 搭建 ScrollView 和 contentView（从 view.top 起始，Banner 覆盖透明导航栏区域）
    private func setupScrollView_Epoch() {
        scrollView_Epoch.showsVerticalScrollIndicator = false
        scrollView_Epoch.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        // 禁止系统自动添加安全区 inset，Banner 需要自己延伸到顶部
        scrollView_Epoch.contentInsetAdjustmentBehavior = .never
        // 关闭触摸延迟，确保 UIControl / UIButton 等子视图能立即响应点击
        scrollView_Epoch.delaysContentTouches = false
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)
        scrollView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Epoch.contentLayoutGuide)
            make.width.equalTo(scrollView_Epoch.frameLayoutGuide)
        }
    }

    /// 搭建顶部渐变 Banner（含多层装饰：光球 + 闪光图标 + 纹理标签）
    private func setupBanner_Epoch() {
        // 四色斜向渐变（深紫 → 紫 → 薰衣草 → 玫瑰粉）
        bannerGradient_Epoch.colors = [
            UIColor(hexstring_Epoch: "#4C1D95").cgColor,
            UIColor(hexstring_Epoch: "#7C3AED").cgColor,
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.secondaryGradientStart_Epoch.cgColor
        ]
        bannerGradient_Epoch.locations = [0.0, 0.28, 0.62, 1.0]
        bannerGradient_Epoch.startPoint = CGPoint(x: 0.05, y: 0)
        bannerGradient_Epoch.endPoint   = CGPoint(x: 0.95, y: 1)
        bannerView_Epoch.layer.insertSublayer(bannerGradient_Epoch, at: 0)
        bannerView_Epoch.clipsToBounds = true
        contentView_Epoch.addSubview(bannerView_Epoch)
        bannerView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            // 初始高度 280，viewDidLayoutSubviews 中根据安全区修正
            bannerHeightConstraint_Epoch = make.height.equalTo(200).constraint
        }

        // 右上大光球（白色半透明）
        bannerGlowTopRight_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        bannerGlowTopRight_Epoch.isUserInteractionEnabled = false
        bannerView_Epoch.addSubview(bannerGlowTopRight_Epoch)
        bannerGlowTopRight_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(50)
            make.width.height.equalTo(220)
        }

        // 左下粉色光球
        bannerGlowBottomLeft_Epoch.backgroundColor = ColorConfig_Epoch.accentPink_Epoch.withAlphaComponent(0.22)
        bannerGlowBottomLeft_Epoch.isUserInteractionEnabled = false
        bannerView_Epoch.addSubview(bannerGlowBottomLeft_Epoch)
        bannerGlowBottomLeft_Epoch.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(-50)
            make.width.height.equalTo(180)
        }

        // 中部偏右蓝色光球
        bannerGlowCenter_Epoch.backgroundColor = ColorConfig_Epoch.accentBlue_Epoch.withAlphaComponent(0.14)
        bannerGlowCenter_Epoch.isUserInteractionEnabled = false
        bannerView_Epoch.addSubview(bannerGlowCenter_Epoch)
        bannerGlowCenter_Epoch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(120)
        }

        // 闪光装饰图标组（散布在 Banner 中）
        addBannerSparkles_Epoch()

        // 左下角 "EPOCH" 品牌水印
        let watermark_epoch = UILabel()
        watermark_epoch.text = "EPOCH"
        let wDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption1)
        let wSerif_epoch = (wDesc_epoch.withDesign(.serif) ?? wDesc_epoch)
            .withSymbolicTraits(.traitBold) ?? wDesc_epoch
        watermark_epoch.font = UIFont(descriptor: wSerif_epoch, size: 11)
        watermark_epoch.textColor = UIColor.white.withAlphaComponent(0.25)
        watermark_epoch.isUserInteractionEnabled = false
        bannerView_Epoch.addSubview(watermark_epoch)
        watermark_epoch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-52)
        }
    }

    /// 在 Banner 内散布闪光/星形装饰图标
    private func addBannerSparkles_Epoch() {
        let icons_epoch = ["sparkles", "star.fill", "sparkle", "star.circle.fill"]
        let positions_epoch: [(CGFloat, CGFloat, CGFloat)] = [
            // (x offset, y offset, size)
            (28,  60, 14),
            (60,  30, 10),
            (120, 50, 12),
            (260, 40, 10),
            (320, 80, 14),
            (340, 28, 9),
            (70, 130, 10),
            (200, 20, 11)
        ]
        for (idx_epoch, pos_epoch) in positions_epoch.enumerated() {
            let icon_epoch = UIImageView(image: UIImage(systemName: icons_epoch[idx_epoch % icons_epoch.count]))
            icon_epoch.tintColor = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.15...0.30))
            icon_epoch.contentMode = .scaleAspectFit
            icon_epoch.isUserInteractionEnabled = false
            bannerView_Epoch.addSubview(icon_epoch)
            icon_epoch.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(pos_epoch.0)
                make.top.equalToSuperview().offset(pos_epoch.1)
                make.width.height.equalTo(pos_epoch.2)
            }
        }
    }

    /// 搭建悬浮头像环（中心在 Banner 底部边缘）
    private func setupAvatarRing_Epoch() {
        // 三色渐变环
        avatarRingGrad_Epoch.colors = [
            ColorConfig_Epoch.accentPink_Epoch.cgColor,
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.accentBlue_Epoch.cgColor
        ]
        avatarRingGrad_Epoch.startPoint = CGPoint(x: 0, y: 0)
        avatarRingGrad_Epoch.endPoint   = CGPoint(x: 1, y: 1)
        avatarRingView_Epoch.layer.insertSublayer(avatarRingGrad_Epoch, at: 0)
        avatarRingView_Epoch.clipsToBounds = true
        contentView_Epoch.addSubview(avatarRingView_Epoch)

        // 白色分隔圈
        avatarSep_Epoch.backgroundColor = .white
        avatarSep_Epoch.clipsToBounds = true
        avatarRingView_Epoch.addSubview(avatarSep_Epoch)

        // 头像
        avatarView_Epoch.clipsToBounds = true
        avatarSep_Epoch.addSubview(avatarView_Epoch)

        // 头像环中心与 Banner 底部对齐（半进 Banner，半出 Banner）
        avatarRingView_Epoch.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(bannerView_Epoch.snp.bottom)
            make.width.height.equalTo(96)
        }
        avatarSep_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(86)
        }
        avatarView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
    }

    /// 搭建名称 + 角标区（头像下方）
    private func setupNameArea_Epoch() {
        let baseDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let serifDesc_epoch = (baseDesc_epoch.withDesign(.serif) ?? baseDesc_epoch)
            .withSymbolicTraits(.traitBold) ?? baseDesc_epoch
        nameLabel_Epoch.font = UIFont(descriptor: serifDesc_epoch, size: 24)
        nameLabel_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        nameLabel_Epoch.textAlignment = .center
        contentView_Epoch.addSubview(nameLabel_Epoch)

        creatorBadge_Epoch.text = "CREATOR"
        creatorBadge_Epoch.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        creatorBadge_Epoch.textColor = .white
        creatorBadge_Epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        creatorBadge_Epoch.layer.cornerRadius = 10
        creatorBadge_Epoch.clipsToBounds = true
        creatorBadge_Epoch.horizontalInset_Epoch = 8
        creatorBadge_Epoch.verticalInset_Epoch = 4
        contentView_Epoch.addSubview(creatorBadge_Epoch)

        nameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        creatorBadge_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Epoch.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建信息卡（简介 + 统计行 + 操作按钮）
    private func setupInfoCard_Epoch() {
        contentView_Epoch.addSubview(infoCard_Epoch)
        infoCard_Epoch.snp.makeConstraints { make in
            make.top.equalTo(creatorBadge_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        // 简介
        introLabel_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        introLabel_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        introLabel_Epoch.numberOfLines = 0
        introLabel_Epoch.textAlignment = .center
        infoCard_Epoch.addSubview(introLabel_Epoch)

        // 统计行容器
        statStackView_Epoch.axis = .horizontal
        statStackView_Epoch.distribution = .fillEqually
        statStackView_Epoch.spacing = 0
        infoCard_Epoch.addSubview(statStackView_Epoch)

        // 分割线
        dividerLine_Epoch.backgroundColor = ColorConfig_Epoch.divider_Epoch
        infoCard_Epoch.addSubview(dividerLine_Epoch)

        // 操作按钮区
        setupActionButtons_Epoch()

        // 约束
        introLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        statStackView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        dividerLine_Epoch.snp.makeConstraints { make in
            make.top.equalTo(statStackView_Epoch.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
    }

    /// 搭建操作按钮（Follow + Message）
    private func setupActionButtons_Epoch() {
        followButton_Epoch.addTarget(self, action: #selector(followTapped_Epoch), for: .touchUpInside)

        // Message 按钮（轮廓样式）
        let msgIcon_epoch = UIImageView(image: UIImage(systemName: "bubble.left.fill"))
        msgIcon_epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        msgIcon_epoch.contentMode = .scaleAspectFit

        messageButton_Epoch.setTitle("Message", for: .normal)
        messageButton_Epoch.setTitleColor(ColorConfig_Epoch.accentPurple_Epoch, for: .normal)
        messageButton_Epoch.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        messageButton_Epoch.backgroundColor = ColorConfig_Epoch.accentBorder_Epoch
        messageButton_Epoch.layer.cornerRadius = 16
        messageButton_Epoch.addTarget(self, action: #selector(messageTapped_Epoch), for: .touchUpInside)

        let actionStack_epoch = UIStackView(arrangedSubviews: [followButton_Epoch, messageButton_Epoch])
        actionStack_epoch.axis = .horizontal
        actionStack_epoch.spacing = 12
        actionStack_epoch.distribution = .fillEqually
        infoCard_Epoch.addSubview(actionStack_epoch)

        actionStack_epoch.snp.makeConstraints { make in
            make.top.equalTo(dividerLine_Epoch.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
    }

    /// 搭建帖子区（标题行 + 帖子卡片栈 + 空状态）
    private func setupPostsSection_Epoch() {
        contentView_Epoch.addSubview(postsSectionView_Epoch)
        postsSectionView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(infoCard_Epoch.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
        }

        // 渐变左边条
        let accentLine_epoch = UIView()
        accentLine_epoch.clipsToBounds = true
        accentLine_epoch.layer.cornerRadius = 2
        let lineGrad_epoch = CAGradientLayer()
        lineGrad_epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.accentPink_Epoch.cgColor
        ]
        lineGrad_epoch.startPoint = CGPoint(x: 0, y: 0)
        lineGrad_epoch.endPoint   = CGPoint(x: 0, y: 1)
        lineGrad_epoch.frame = CGRect(x: 0, y: 0, width: 4, height: 22)
        accentLine_epoch.layer.insertSublayer(lineGrad_epoch, at: 0)

        // 标题
        let sectionTitle_epoch = UILabel()
        sectionTitle_epoch.text = "Posts"
        let rDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
        let bDesc_epoch = (rDesc_epoch.withDesign(.rounded) ?? rDesc_epoch)
            .withSymbolicTraits(.traitBold) ?? rDesc_epoch
        sectionTitle_epoch.font = UIFont(descriptor: bDesc_epoch, size: 18)
        sectionTitle_epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch

        // 帖子数角标
        postsCountBadge_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        postsCountBadge_Epoch.textColor = .white
        postsCountBadge_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch
        postsCountBadge_Epoch.layer.cornerRadius = 10
        postsCountBadge_Epoch.clipsToBounds = true
        postsCountBadge_Epoch.horizontalInset_Epoch = 8
        postsCountBadge_Epoch.verticalInset_Epoch = 3

        let headerRow_epoch = UIStackView(arrangedSubviews: [accentLine_epoch, sectionTitle_epoch, postsCountBadge_Epoch, UIView()])
        headerRow_epoch.axis = .horizontal
        headerRow_epoch.spacing = 8
        headerRow_epoch.alignment = .center
        postsSectionView_Epoch.addSubview(headerRow_epoch)

        // 帖子栈
        postsStackView_Epoch.axis = .vertical
        postsStackView_Epoch.spacing = 14
        postsSectionView_Epoch.addSubview(postsStackView_Epoch)

        // 空状态
        emptyStateView_Epoch.configure_Epoch(
            iconName_Epoch: "rectangle.stack.person.crop",
            title_Epoch: "No posts yet",
            subtitle_Epoch: "This creator has not shared a ritual moment yet."
        )
        emptyStateView_Epoch.isHidden = true
        postsSectionView_Epoch.addSubview(emptyStateView_Epoch)

        accentLine_epoch.snp.makeConstraints { make in make.width.equalTo(4); make.height.equalTo(22) }
        headerRow_epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        postsStackView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(headerRow_epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyStateView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(headerRow_epoch.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }

        // 底部间距
        let spacer_epoch = UIView()
        contentView_Epoch.addSubview(spacer_epoch)
        spacer_epoch.snp.makeConstraints { make in
            make.top.equalTo(postsSectionView_Epoch.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 导航

    private func setupNavigation_Epoch() {
        // 标题先置空，reloadData_Epoch 时更新为用户名
        title = ""

        // 返回按钮（圆形半透明白色背景）
        let backWrap_epoch = UIButton(type: .system)
        backWrap_epoch.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backWrap_epoch.tintColor = .white
        backWrap_epoch.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backWrap_epoch.layer.cornerRadius = 16
        backWrap_epoch.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        backWrap_epoch.addTarget(self, action: #selector(backTapped_Epoch), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backWrap_epoch)

        // 举报按钮：外层圆形容器保证背景始终显示为圆形
        let reportIconBtn_epoch = ReportDeleteHelper_Epoch.createUserReportButton_Epoch(
            size_Epoch: 22,
            backgroundColor_Epoch: .clear,
            tintColor_Epoch: .white,
            withShadow_Epoch: false
        )
        reportIconBtn_epoch.addTarget(self, action: #selector(reportTapped_Epoch), for: .touchUpInside)
        // 圆形背景容器（固定 38×38）
        let reportWrap_epoch = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        reportWrap_epoch.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        reportWrap_epoch.layer.cornerRadius = 19
        reportWrap_epoch.clipsToBounds = true
        reportWrap_epoch.addSubview(reportIconBtn_epoch)
        reportIconBtn_epoch.frame = CGRect(x: 7, y: 7, width: 24, height: 24)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportWrap_epoch)
    }

    /// 应用透明导航栏（与 Banner 渐变融合，按钮和标题显示为白色）
    private func applyTransparentNavBar_Epoch() {
        let appearance_epoch = UINavigationBarAppearance()
        appearance_epoch.configureWithTransparentBackground()
        appearance_epoch.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance   = appearance_epoch
        navigationController?.navigationBar.scrollEdgeAppearance = appearance_epoch
        navigationController?.navigationBar.compactAppearance    = appearance_epoch
        navigationController?.navigationBar.tintColor = .white
    }

    /// 离开页面时恢复默认导航栏样式
    private func restoreNavBar_Epoch() {
        let appearance_epoch = UINavigationBarAppearance()
        appearance_epoch.configureWithDefaultBackground()
        appearance_epoch.titleTextAttributes = [
            .foregroundColor: ColorConfig_Epoch.textPrimary_Epoch
        ]
        navigationController?.navigationBar.standardAppearance   = appearance_epoch
        navigationController?.navigationBar.scrollEdgeAppearance = appearance_epoch
        navigationController?.navigationBar.compactAppearance    = appearance_epoch
        navigationController?.navigationBar.tintColor = ColorConfig_Epoch.textPrimary_Epoch
    }

    // MARK: - 通知

    private func setupNotifications_Epoch() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: TitleViewModel_Epoch.titleStateDidChangeNotification_Epoch,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch,
            object: nil
        )
    }

    // MARK: - 数据刷新

    /// 刷新全页数据
    private func reloadData_Epoch() {
        guard let currentUser_epoch = userModel_Epoch else { return }
        if let userId_epoch = currentUser_epoch.userId_Epoch {
            userModel_Epoch = UserViewModel_Epoch.shared_Epoch.getUserById_Epoch(userId_epoch: userId_epoch)
        }
        guard let userModel_Epoch = userModel_Epoch else { return }

        // 导航栏标题显示用户名
        title = userModel_Epoch.userName_Epoch ?? "Profile"
        nameLabel_Epoch.text = userModel_Epoch.userName_Epoch
        introLabel_Epoch.text = userModel_Epoch.userIntroduce_Epoch ?? "—"
        if let userId_epoch = userModel_Epoch.userId_Epoch {
            avatarView_Epoch.configure_Epoch(userId_Epoch: userId_epoch)
        }

        // 重建统计行
        statStackView_Epoch.arrangedSubviews.forEach {
            statStackView_Epoch.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let postStat_epoch = UserInfoStatItem_Epoch(
            icon_Epoch: "doc.text.fill",
            value_Epoch: "\(userPosts_Epoch.count)",
            label_Epoch: "Posts"
        )
        let fansStat_epoch = UserInfoStatItem_Epoch(
            icon_Epoch: "person.2.fill",
            value_Epoch: "\(userModel_Epoch.userFans_Epoch ?? 0)",
            label_Epoch: "Fans"
        )
        let savedStat_epoch = UserInfoStatItem_Epoch(
            icon_Epoch: "heart.fill",
            value_Epoch: "\(userModel_Epoch.userLike_Epoch.count)",
            label_Epoch: "Saved"
        )
        [postStat_epoch, fansStat_epoch, savedStat_epoch].forEach {
            statStackView_Epoch.addArrangedSubview($0)
        }

        // 更新帖子数角标
        postsCountBadge_Epoch.text = "\(userPosts_Epoch.count)"

        // 关注状态
        let isFollowing_epoch = UserViewModel_Epoch.shared_Epoch.isFollowing_Epoch(user_epoch: userModel_Epoch)
        followButton_Epoch.setTitle(isFollowing_epoch ? "Followed" : "Follow", for: .normal)

        // 消息按钮可见性
        let isMessageMode_epoch = entrySource_Epoch != .normal_epoch
        messageButton_Epoch.isHidden = isMessageMode_epoch

        reloadPosts_Epoch()
    }

    /// 刷新帖子区
    private func reloadPosts_Epoch() {
        postsStackView_Epoch.arrangedSubviews.forEach {
            postsStackView_Epoch.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let hasPosts_epoch = !userPosts_Epoch.isEmpty
        emptyStateView_Epoch.isHidden = hasPosts_epoch
        postsStackView_Epoch.isHidden = !hasPosts_epoch

        for post_epoch in userPosts_Epoch {
            let card_epoch = PostCardView_Epoch(style_Epoch: .home_epoch)
            card_epoch.configure_Epoch(post_epoch: post_epoch, hostViewController_Epoch: self)
            // 隐藏 Open 按钮，整张卡片点击直接进入详情
            card_epoch.setOpenButtonHidden_Epoch(true)
            card_epoch.onPostTapped_Epoch = {
                Navigation_Epoch.toTitleDetail_Epoch(titleModel_epoch: post_epoch)
            }
            card_epoch.onUserTapped_Epoch = {}
            card_epoch.onLikeTapped_Epoch = { [weak self] in
                TitleViewModel_Epoch.shared_Epoch.likePost_Epoch(post_epoch: post_epoch)
                self?.reloadData_Epoch()
            }
            postsStackView_Epoch.addArrangedSubview(card_epoch)
        }
    }

    // MARK: - 业务逻辑

    /// 显示发起聊天确认弹窗
    private func showMessageConfirm_Epoch(user_epoch: PrewUserModel_Epoch) {
        let info_epoch = "\(user_epoch.userName_Epoch ?? "Creator")\n\n\(user_epoch.userIntroduce_Epoch ?? "No bio")"
        let alert_epoch = UIAlertController(title: "Start chat", message: info_epoch, preferredStyle: .alert)
        alert_epoch.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_epoch.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            guard let userId_epoch = user_epoch.userId_Epoch else { return }
            MessageViewModel_Epoch.shared_Epoch.startConversationIfNeeded_Epoch(userId_epoch: userId_epoch)
            Navigation_Epoch.toMessageUser_Epoch(with: user_epoch)
        })
        present(alert_epoch, animated: true)
    }

    // MARK: - @objc

    @objc private func backTapped_Epoch() {
        Navigation_Epoch.pop_Epoch()
    }

    @objc private func reportTapped_Epoch() {
        guard let userModel_Epoch = userModel_Epoch else { return }
        ReportDeleteHelper_Epoch.block_Epoch(user_Epoch: userModel_Epoch, from: self) {
            Navigation_Epoch.popToRoot_Epoch()
        }
    }

    @objc private func followTapped_Epoch() {
        guard let userModel_Epoch = userModel_Epoch else { return }
        let nowFollowing_epoch = UserViewModel_Epoch.shared_Epoch.followUser_Epoch(user_epoch: userModel_Epoch)
        reloadData_Epoch()
        if !nowFollowing_epoch && entrySource_Epoch != .normal_epoch, let userId_epoch = userModel_Epoch.userId_Epoch {
            MessageViewModel_Epoch.shared_Epoch.deleteUserMessages_Epoch(userId_epoch: userId_epoch)
            Navigation_Epoch.switchToTabbar_Epoch(animated: true, selectedIndex_epoch: 3)
        }
    }

    @objc private func messageTapped_Epoch() {
        guard let userModel_Epoch = userModel_Epoch else { return }
        if !UserViewModel_Epoch.shared_Epoch.isFollowing_Epoch(user_epoch: userModel_Epoch) {
            let alert_epoch = UIAlertController(
                title: "Follow first",
                message: "Follow this creator before sending a message.",
                preferredStyle: .alert
            )
            alert_epoch.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_epoch, animated: true)
            return
        }
        showMessageConfirm_Epoch(user_epoch: userModel_Epoch)
    }

    @objc private func handleStateChange_Epoch() {
        reloadData_Epoch()
    }
}

// MARK: - 用户信息统计项

/// 用户中心统计项（图标 + 数值 + 标签）
/// 核心作用：在用户信息卡中展示单项数据统计（帖子数、粉丝数、收藏数）
/// 设计思路：竖排布局，图标 + 粗体数字 + 小标签，与卡片等宽平分
final class UserInfoStatItem_Epoch: UIView {

    /// 初始化统计项
    /// - Parameters:
    ///   - icon_Epoch: 系统图标名称
    ///   - value_Epoch: 数值文本
    ///   - label_Epoch: 标签文本
    init(icon_Epoch: String, value_Epoch: String, label_Epoch: String) {
        super.init(frame: .zero)
        setupUI_Epoch(icon_Epoch: icon_Epoch, value_Epoch: value_Epoch, label_Epoch: label_Epoch)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Epoch(icon_Epoch: String, value_Epoch: String, label_Epoch: String) {
        let iconView_epoch = UIImageView(image: UIImage(systemName: icon_Epoch))
        iconView_epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iconView_epoch.contentMode = .scaleAspectFit

        let valueLabel_epoch = UILabel()
        valueLabel_epoch.text = value_Epoch
        valueLabel_epoch.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel_epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        valueLabel_epoch.textAlignment = .center

        let titleLabel_epoch = UILabel()
        titleLabel_epoch.text = label_Epoch
        titleLabel_epoch.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel_epoch.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        titleLabel_epoch.textAlignment = .center

        let stack_epoch = UIStackView(arrangedSubviews: [iconView_epoch, valueLabel_epoch, titleLabel_epoch])
        stack_epoch.axis = .vertical
        stack_epoch.alignment = .center
        stack_epoch.spacing = 3
        addSubview(stack_epoch)

        iconView_epoch.snp.makeConstraints { make in make.width.height.equalTo(16) }
        stack_epoch.snp.makeConstraints { make in make.center.equalToSuperview() }
    }
}
