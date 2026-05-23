import UIKit
import SnapKit

// MARK: 首页控制器

/// 首页控制器
/// 功能：聚合展示四大核心模块——时间胶囊、今日灵感卡、季节限定挑战、技巧提示翻转卡
/// 设计：UIScrollView 纵向滚动，顶部沉浸式 Hero 头部 + 各功能卡片模块
/// 滚动修正：禁用 contentInsetAdjustmentBehavior，避免 TabBar 高度被重复计入底部
/// 关键方法：reloadAllSections_Hush()（统一刷新所有区块）
class Home_Hush: UIViewController {

    // MARK: - 私有数据属性

    /// 时间胶囊列表
    private var capsules_Hush: [TimeCapsuleModel_Hush] = []
    /// 热门帖子列表（按点赞数降序，取前3）
    private var hotPosts_Hush: [TitleModel_Hush] = []
    /// 当季挑战列表
    private var seasonChallenges_Hush: [SeasonChallengeModel_Hush] = []
    /// 技巧提示卡列表
    private var tipCards_Hush: [TipCardModel_Hush] = []

    // MARK: - UI 组件 - 主容器

    private let scrollView_Hush: UIScrollView = {
        let sv_hush = UIScrollView()
        sv_hush.showsVerticalScrollIndicator = false
        sv_hush.alwaysBounceVertical = true
        // 禁用自动 inset 调整，防止 TabBar 高度被重复叠加导致底部无法滚动到位
        sv_hush.contentInsetAdjustmentBehavior = .never
        return sv_hush
    }()

    private let contentView_Hush = UIView()

    // MARK: - UI 组件 - Hero 头部

    /// Hero 头部容器
    private let heroView_Hush = UIView()
    /// Hero 渐变背景层
    private var heroGradient_Hush: CAGradientLayer?
    /// Hero 顶部噪点纹理遮罩（模拟胶片质感）
    private let heroNoiseOverlay_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        return v_hush
    }()
    /// 当前日期显示
    private let dateLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.55)
        lb_hush.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lb_hush.letterSpacing_Hush(spacing_hush: 1.5)
        return lb_hush
    }()
    /// 问候语
    private let greetingLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.7)
        lb_hush.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return lb_hush
    }()
    /// 品牌大标题
    private let brandTitle_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "HUSH"
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 40, weight: .black)
        return lb_hush
    }()
    /// 品牌副标语
    private let brandTagline_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Street · Silent · Spontaneous"
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.45)
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb_hush.letterSpacing_Hush(spacing_hush: 0.8)
        return lb_hush
    }()
    /// Hero 右侧：当前登录用户头像（点击跳转个人中心）
    private let heroAvatarView_Hush = UserAvatarView_Hush()
    /// 头像外圈白色边框容器（增强在深色 Hero 背景上的可见度）
    private let heroAvatarRing_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = .clear
        v_hush.layer.cornerRadius = 30
        v_hush.layer.borderWidth = 2.5
        v_hush.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        v_hush.clipsToBounds = false
        return v_hush
    }()
    /// Hero 底部曲线装饰（白色圆角遮盖制造曲线感）
    private let heroCurveView_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        v_hush.layer.cornerRadius = 28
        v_hush.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_hush
    }()

    // MARK: - UI 组件 - 各区块

    /// 时间胶囊区块容器
    private let capsuleModule_Hush = UIView()
    /// 灵感卡区块容器
    private let inspirationModule_Hush = UIView()
    /// 季节挑战区块容器
    private let challengeModule_Hush = UIView()
    /// 技巧提示区块容器
    private let tipsModule_Hush = UIView()

    /// 时间胶囊横向集合视图
    private let capsuleCollectionView_Hush: UICollectionView = {
        let layout_hush = UICollectionViewFlowLayout()
        layout_hush.scrollDirection = .horizontal
        layout_hush.itemSize = CGSize(width: 172, height: 248)
        layout_hush.minimumLineSpacing = 14
        layout_hush.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv_hush = UICollectionView(frame: .zero, collectionViewLayout: layout_hush)
        cv_hush.showsHorizontalScrollIndicator = false
        cv_hush.backgroundColor = .clear
        return cv_hush
    }()

    /// 今日灵感横向集合视图
    private let inspirationCollectionView_Hush: UICollectionView = {
        let layout_hush = UICollectionViewFlowLayout()
        layout_hush.scrollDirection = .horizontal
        layout_hush.itemSize = CGSize(width: 185, height: 248)
        layout_hush.minimumLineSpacing = 14
        layout_hush.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv_hush = UICollectionView(frame: .zero, collectionViewLayout: layout_hush)
        cv_hush.showsHorizontalScrollIndicator = false
        cv_hush.backgroundColor = .clear
        return cv_hush
    }()

    /// 季节挑战纵向堆叠视图
    private let challengeStackView_Hush: UIStackView = {
        let sv_hush = UIStackView()
        sv_hush.axis = .vertical
        sv_hush.spacing = 12
        return sv_hush
    }()

    /// 技巧提示横向集合视图
    private let tipsCollectionView_Hush: UICollectionView = {
        let layout_hush = UICollectionViewFlowLayout()
        layout_hush.scrollDirection = .horizontal
        layout_hush.itemSize = CGSize(width: 156, height: 216)
        layout_hush.minimumLineSpacing = 14
        layout_hush.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv_hush = UICollectionView(frame: .zero, collectionViewLayout: layout_hush)
        cv_hush.showsHorizontalScrollIndicator = false
        cv_hush.backgroundColor = .clear
        return cv_hush
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        setupScrollView_Hush()
        setupHeroSection_Hush()
        setupCapsuleModule_Hush()
        setupInspirationModule_Hush()
        setupChallengeModule_Hush()
        setupTipsModule_Hush()
        registerNotifications_Hush()
        loadAllData_Hush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadCapsulesSection_Hush()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradient_Hush?.frame = heroView_Hush.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 布局 - 主 ScrollView

    /// 构建 ScrollView 与 contentView 基础约束
    /// 关键：scrollView 约束到 view.edges（非 safeArea），配合 contentInsetAdjustmentBehavior = .never
    /// 防止系统重复叠加 TabBar/NavigationBar 高度导致底部滚动缺失
    private func setupScrollView_Hush() {
        view.addSubview(scrollView_Hush)
        scrollView_Hush.addSubview(contentView_Hush)

        // 使用 view.edges 而非 safeAreaLayoutGuide，配合 contentInsetAdjustmentBehavior = .never
        scrollView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        contentView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
            make_hush.width.equalTo(view.snp.width)
        }
    }

    // MARK: - 布局 - Hero 头部

    /// 构建沉浸式 Hero 头部：渐变背景 + 品牌信息 + 快拍按钮 + 底部曲线过渡
    private func setupHeroSection_Hush() {
        contentView_Hush.addSubview(heroView_Hush)
        heroView_Hush.clipsToBounds = true

        // 渐变背景（深炭黑 → 街头橙红）
        let grad_hush = CAGradientLayer()
        grad_hush.colors = [
            UIColor(hexstring_Hush: "#1A1B25").cgColor,
            UIColor(hexstring_Hush: "#2C1810").cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.withAlphaComponent(0.85).cgColor,
        ]
        grad_hush.locations = [0.0, 0.6, 1.0]
        grad_hush.startPoint = CGPoint(x: 0, y: 0)
        grad_hush.endPoint = CGPoint(x: 1, y: 1)
        heroView_Hush.layer.insertSublayer(grad_hush, at: 0)
        heroGradient_Hush = grad_hush

        // 头像视图：圆形裁剪
        heroAvatarView_Hush.clipsToBounds = true
        heroAvatarView_Hush.layer.cornerRadius = 26
        // 点击头像跳转个人中心
        let avatarTap_hush = UITapGestureRecognizer(target: self, action: #selector(onAvatarTap_Hush))
        heroAvatarRing_Hush.addGestureRecognizer(avatarTap_hush)
        heroAvatarRing_Hush.isUserInteractionEnabled = true

        // 添加子视图
        heroView_Hush.addSubview(heroNoiseOverlay_Hush)
        heroView_Hush.addSubview(dateLabel_Hush)
        heroView_Hush.addSubview(greetingLabel_Hush)
        heroView_Hush.addSubview(brandTitle_Hush)
        heroView_Hush.addSubview(brandTagline_Hush)
        heroView_Hush.addSubview(heroAvatarRing_Hush)
        heroAvatarRing_Hush.addSubview(heroAvatarView_Hush)
        heroView_Hush.addSubview(heroCurveView_Hush)

        // 布局
        let topInset_hush = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        heroView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(200 + topInset_hush)
        }
        heroNoiseOverlay_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        dateLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(topInset_hush + 16)
            make_hush.left.equalToSuperview().offset(22)
        }
        greetingLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(dateLabel_Hush.snp.bottom).offset(6)
            make_hush.left.equalToSuperview().offset(22)
        }
        brandTitle_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(greetingLabel_Hush.snp.bottom).offset(6)
            make_hush.left.equalToSuperview().offset(20)
        }
        brandTagline_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(brandTitle_Hush.snp.bottom).offset(4)
            make_hush.left.equalToSuperview().offset(22)
        }
        heroAvatarRing_Hush.snp.makeConstraints { make_hush in
            make_hush.right.equalToSuperview().offset(-20)
            make_hush.centerY.equalTo(brandTitle_Hush)
            make_hush.width.height.equalTo(60)
        }
        heroAvatarView_Hush.snp.makeConstraints { make_hush in
            make_hush.center.equalToSuperview()
            make_hush.width.height.equalTo(52)
        }
        heroCurveView_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.bottom.equalToSuperview()
            make_hush.height.equalTo(36)
        }

        // 填充文字内容
        dateLabel_Hush.text = buildDateString_Hush().uppercased()
        greetingLabel_Hush.text = buildGreeting_Hush()

        // 加载当前用户头像
        refreshHeroAvatar_Hush()
    }

    /// 刷新 Hero 头像（登录状态变化时同步调用）
    private func refreshHeroAvatar_Hush() {
        let userId_hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush().userId_Hush ?? 0
        heroAvatarView_Hush.configure_Hush(userId_Hush: userId_hush)
    }

    // MARK: - 布局 - 各功能模块

    /// 构建功能区块的通用卡片容器（白色圆角背景 + 阴影）
    /// - Parameters:
    ///   - icon_hush: 区块图标（SF Symbol 名）
    ///   - title_hush: 区块主标题
    ///   - subtitle_hush: 区块副标题
    ///   - accentColor_hush: 图标圆底色
    ///   - actionTitle_hush: 操作按钮文字（nil 则不显示）
    ///   - action_hush: 操作按钮 selector
    /// - Returns: 配置好的 header 视图（height = 64）
    private func makeModuleHeader_Hush(icon_hush: String,
                                        title_hush: String,
                                        subtitle_hush: String,
                                        accentColor_hush: UIColor,
                                        actionTitle_hush: String? = nil,
                                        action_hush: Selector? = nil) -> UIView {
        let container_hush = UIView()

        // 图标圆底
        let iconBg_hush = UIView()
        iconBg_hush.backgroundColor = accentColor_hush.withAlphaComponent(0.12)
        iconBg_hush.layer.cornerRadius = 14
        container_hush.addSubview(iconBg_hush)

        let iconView_hush = UIImageView()
        let config_hush = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconView_hush.image = UIImage(systemName: icon_hush, withConfiguration: config_hush)
        iconView_hush.tintColor = accentColor_hush
        iconView_hush.contentMode = .scaleAspectFit
        iconBg_hush.addSubview(iconView_hush)

        // 文字
        let titleLb_hush = UILabel()
        titleLb_hush.text = title_hush
        titleLb_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        titleLb_hush.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        container_hush.addSubview(titleLb_hush)

        let subLb_hush = UILabel()
        subLb_hush.text = subtitle_hush
        subLb_hush.textColor = ColorConfig_Hush.textSecondary_Hush
        subLb_hush.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        container_hush.addSubview(subLb_hush)

        // 约束
        iconBg_hush.snp.makeConstraints { make_hush in
            make_hush.left.equalToSuperview().offset(18)
            make_hush.centerY.equalToSuperview()
            make_hush.width.height.equalTo(36)
        }
        iconView_hush.snp.makeConstraints { make_hush in
            make_hush.center.equalToSuperview()
            make_hush.width.height.equalTo(18)
        }
        titleLb_hush.snp.makeConstraints { make_hush in
            make_hush.left.equalTo(iconBg_hush.snp.right).offset(10)
            make_hush.top.equalToSuperview().offset(14)
        }
        subLb_hush.snp.makeConstraints { make_hush in
            make_hush.left.equalTo(titleLb_hush)
            make_hush.top.equalTo(titleLb_hush.snp.bottom).offset(2)
        }

        // 操作按钮
        if let actionTitle_hush = actionTitle_hush, let action_hush = action_hush {
            let bt_hush = UIButton(type: .system)
            bt_hush.setTitle(actionTitle_hush, for: .normal)
            bt_hush.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            bt_hush.tintColor = accentColor_hush
            bt_hush.backgroundColor = accentColor_hush.withAlphaComponent(0.1)
            bt_hush.layer.cornerRadius = 13
            bt_hush.layer.borderWidth = 1
            bt_hush.layer.borderColor = accentColor_hush.withAlphaComponent(0.2).cgColor
            bt_hush.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
            bt_hush.addTarget(self, action: action_hush, for: .touchUpInside)
            container_hush.addSubview(bt_hush)
            bt_hush.snp.makeConstraints { make_hush in
                make_hush.centerY.equalToSuperview()
                make_hush.right.equalToSuperview().offset(-18)
                make_hush.height.equalTo(28)
            }
        }

        return container_hush
    }

    /// 构建区块卡片容器（白色背景、圆角、阴影）
    private func makeModuleCard_Hush() -> UIView {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        v_hush.layer.cornerRadius = 20
        v_hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v_hush.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_hush.layer.shadowRadius = 14
        v_hush.layer.shadowOpacity = 1
        return v_hush
    }

    // MARK: - 时间胶囊区块

    /// 构建时间胶囊模块（卡片容器 + 横向 CollectionView）
    private func setupCapsuleModule_Hush() {
        let card_hush = makeModuleCard_Hush()
        let header_hush = makeModuleHeader_Hush(
            icon_hush: "hourglass",
            title_hush: "Time Capsule",
            subtitle_hush: "Sealed until the moment arrives",
            accentColor_hush: UIColor(hexstring_Hush: "#FF6B35"),
            actionTitle_hush: "+ Plant",
            action_hush: #selector(onAddCapsule_Hush)
        )

        contentView_Hush.addSubview(capsuleModule_Hush)
        capsuleModule_Hush.addSubview(card_hush)
        card_hush.addSubview(header_hush)
        card_hush.addSubview(capsuleCollectionView_Hush)

        capsuleModule_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(heroView_Hush.snp.bottom).offset(-10)
            make_hush.left.right.equalToSuperview().inset(16)
        }
        card_hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        header_hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(64)
        }

        // 区块标题装饰线（与 header 底部对齐）
        let divLine_hush = makeThinDivider_Hush()
        card_hush.addSubview(divLine_hush)
        divLine_hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(header_hush.snp.bottom)
            make_hush.left.right.equalToSuperview().inset(18)
            make_hush.height.equalTo(1)
        }

        capsuleCollectionView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(divLine_hush.snp.bottom).offset(14)
            make_hush.left.right.equalToSuperview()
            make_hush.height.equalTo(258)
            make_hush.bottom.equalToSuperview().offset(-16)
        }

        capsuleCollectionView_Hush.delegate = self
        capsuleCollectionView_Hush.dataSource = self
        capsuleCollectionView_Hush.register(TimeCapsuleCell_Hush.self, forCellWithReuseIdentifier: TimeCapsuleCell_Hush.reuseId_Hush)
        capsuleCollectionView_Hush.register(AddCapsuleCell_Hush.self, forCellWithReuseIdentifier: AddCapsuleCell_Hush.reuseId_Hush)
    }

    // MARK: - 今日灵感区块

    /// 构建今日灵感模块（卡片容器 + 横向 CollectionView）
    private func setupInspirationModule_Hush() {
        let card_hush = makeModuleCard_Hush()
        let header_hush = makeModuleHeader_Hush(
            icon_hush: "flame.fill",
            title_hush: "Hot Posts",
            subtitle_hush: "Top 3 most liked right now",
            accentColor_hush: UIColor(hexstring_Hush: "#FF6B35")
        )

        contentView_Hush.addSubview(inspirationModule_Hush)
        inspirationModule_Hush.addSubview(card_hush)
        card_hush.addSubview(header_hush)
        card_hush.addSubview(inspirationCollectionView_Hush)

        inspirationModule_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(capsuleModule_Hush.snp.bottom).offset(16)
            make_hush.left.right.equalToSuperview().inset(16)
        }
        card_hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        header_hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(64)
        }

        let divLine_hush = makeThinDivider_Hush()
        card_hush.addSubview(divLine_hush)
        divLine_hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(header_hush.snp.bottom)
            make_hush.left.right.equalToSuperview().inset(18)
            make_hush.height.equalTo(1)
        }

        inspirationCollectionView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(divLine_hush.snp.bottom).offset(14)
            make_hush.left.right.equalToSuperview()
            make_hush.height.equalTo(258)
            make_hush.bottom.equalToSuperview().offset(-16)
        }

        inspirationCollectionView_Hush.delegate = self
        inspirationCollectionView_Hush.dataSource = self
        inspirationCollectionView_Hush.register(InspirationCell_Hush.self, forCellWithReuseIdentifier: InspirationCell_Hush.reuseId_Hush)
    }

    // MARK: - 季节挑战区块

    /// 构建季节挑战模块（卡片容器 + 季节标签 + 纵向 StackView）
    private func setupChallengeModule_Hush() {
        let card_hush = makeModuleCard_Hush()
        let currentSeason_hush = SeasonUtil_Hush.currentSeason_Hush()
        let seasonColor_hush = seasonColor_Hush(season_hush: currentSeason_hush)
        let header_hush = makeModuleHeader_Hush(
            icon_hush: seasonIcon_Hush(season_hush: currentSeason_hush),
            title_hush: "\(currentSeason_hush) Challenge",
            subtitle_hush: "Quarterly · Limited themes",
            accentColor_hush: seasonColor_hush
        )

        contentView_Hush.addSubview(challengeModule_Hush)
        challengeModule_Hush.addSubview(card_hush)
        card_hush.addSubview(header_hush)
        card_hush.addSubview(challengeStackView_Hush)

        challengeModule_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(inspirationModule_Hush.snp.bottom).offset(16)
            make_hush.left.right.equalToSuperview().inset(16)
        }
        card_hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        header_hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(64)
        }

        let divLine_hush = makeThinDivider_Hush()
        card_hush.addSubview(divLine_hush)
        divLine_hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(header_hush.snp.bottom)
            make_hush.left.right.equalToSuperview().inset(18)
            make_hush.height.equalTo(1)
        }

        challengeStackView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(divLine_hush.snp.bottom).offset(14)
            make_hush.left.right.equalToSuperview().inset(16)
            make_hush.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - 技巧提示区块

    /// 构建技巧提示模块（卡片容器 + 横向 CollectionView）
    /// 注：此为 contentView 最后一个区块，通过 bottom 约束锚定 contentView 高度
    private func setupTipsModule_Hush() {
        let card_hush = makeModuleCard_Hush()
        let header_hush = makeModuleHeader_Hush(
            icon_hush: "lightbulb.fill",
            title_hush: "Shooting Tips",
            subtitle_hush: "Tap any card to flip & reveal",
            accentColor_hush: UIColor(hexstring_Hush: "#F9C784")
        )

        contentView_Hush.addSubview(tipsModule_Hush)
        tipsModule_Hush.addSubview(card_hush)
        card_hush.addSubview(header_hush)
        card_hush.addSubview(tipsCollectionView_Hush)

        tipsModule_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(challengeModule_Hush.snp.bottom).offset(16)
            make_hush.left.right.equalToSuperview().inset(16)
            // 锚定 contentView 底部，增加 120pt 底部安全间距（覆盖 TabBar + 额外留白）
            make_hush.bottom.equalToSuperview().offset(-120)
        }
        card_hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        header_hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(64)
        }

        let divLine_hush = makeThinDivider_Hush()
        card_hush.addSubview(divLine_hush)
        divLine_hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(header_hush.snp.bottom)
            make_hush.left.right.equalToSuperview().inset(18)
            make_hush.height.equalTo(1)
        }

        // 固定高度 + bottom 约束同时存在会导致布局冲突
        // 此处只用 bottom 锚定（内部 height 由父容器推导），去掉 height 约束
        tipsCollectionView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(divLine_hush.snp.bottom).offset(14)
            make_hush.left.right.equalToSuperview()
            make_hush.height.equalTo(226)
            make_hush.bottom.equalToSuperview().offset(-16)
        }

        tipsCollectionView_Hush.delegate = self
        tipsCollectionView_Hush.dataSource = self
        tipsCollectionView_Hush.register(TipFlipCell_Hush.self, forCellWithReuseIdentifier: TipFlipCell_Hush.reuseId_Hush)
    }

    // MARK: - 工厂方法

    /// 创建细分割线（1pt 高度，divider 颜色）
    private func makeThinDivider_Hush() -> UIView {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.divider_Hush
        return v_hush
    }

    /// 根据季节名返回对应主题色
    private func seasonColor_Hush(season_hush: String) -> UIColor {
        switch season_hush {
        case "Spring":  return UIColor(hexstring_Hush: "#A8D5A2")
        case "Summer":  return UIColor(hexstring_Hush: "#FF8C61")
        case "Autumn":  return UIColor(hexstring_Hush: "#D4845A")
        default:        return UIColor(hexstring_Hush: "#8FB3C9")
        }
    }

    /// 根据季节名返回对应 SF Symbol 图标名
    private func seasonIcon_Hush(season_hush: String) -> String {
        switch season_hush {
        case "Spring":  return "leaf.fill"
        case "Summer":  return "sun.max.fill"
        case "Autumn":  return "wind"
        default:        return "snowflake"
        }
    }

    // MARK: - 数据加载

    /// 一次性加载/刷新所有区块数据
    private func loadAllData_Hush() {
        capsules_Hush = UserViewModel_Hush.shared_Hush.getAllCapsules_Hush()
        hotPosts_Hush = LocalData_Hush.shared_Hush.getTopPosts_Hush(count_hush: 3)
        seasonChallenges_Hush = LocalData_Hush.shared_Hush.getCurrentSeasonChallenges_Hush()
        tipCards_Hush = LocalData_Hush.shared_Hush.tipCards_Hush
        reloadAllSections_Hush()
    }

    /// 仅刷新时间胶囊区（viewWillAppear 时调用）
    private func reloadCapsulesSection_Hush() {
        capsules_Hush = UserViewModel_Hush.shared_Hush.getAllCapsules_Hush()
        capsuleCollectionView_Hush.reloadData()
    }

    /// 刷新所有区块 UI
    private func reloadAllSections_Hush() {
        capsuleCollectionView_Hush.reloadData()
        inspirationCollectionView_Hush.reloadData()
        tipsCollectionView_Hush.reloadData()
        rebuildChallengeCards_Hush()
    }

    /// 重建季节挑战卡片（StackView 方式，支持依次滑入动画）
    private func rebuildChallengeCards_Hush() {
        challengeStackView_Hush.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if seasonChallenges_Hush.isEmpty {
            let emptyLabel_hush = makeEmptyStateLabel_Hush(text_hush: "No challenges this season yet.")
            challengeStackView_Hush.addArrangedSubview(emptyLabel_hush)
            return
        }

        for (index_hush, challenge_hush) in seasonChallenges_Hush.enumerated() {
            let cardView_hush = SeasonChallengeCardView_Hush()
            cardView_hush.configure_Hush(model_hush: challenge_hush)
            cardView_hush.snp.makeConstraints { make_hush in
                make_hush.height.equalTo(116)
            }
            let captured_hush = challenge_hush
            cardView_hush.tapAction_Hush = { [weak self] in
                self?.onChallengeTap_Hush(challenge_hush: captured_hush)
            }
            // 依次延迟滑入
            cardView_hush.alpha = 0
            challengeStackView_Hush.addArrangedSubview(cardView_hush)
            let delay_hush = AnimationConfig_Hush.delayLong_Hush * Double(index_hush + 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay_hush) {
                cardView_hush.slideInAnimate_Hush(direction_Hush: .right)
            }
        }
    }

    /// 生成空状态占位 Label
    private func makeEmptyStateLabel_Hush(text_hush: String) -> UILabel {
        let lb_hush = UILabel()
        lb_hush.text = text_hush
        lb_hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 13)
        lb_hush.textAlignment = .center
        lb_hush.snp.makeConstraints { make_hush in
            make_hush.height.equalTo(48)
        }
        return lb_hush
    }

    // MARK: - 通知

    private func registerNotifications_Hush() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onCapsuleStateChange_Hush),
            name: UserViewModel_Hush.capsuleStateDidChangeNotification_Hush, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserStateChange_Hush),
            name: UserViewModel_Hush.userStateDidChangeNotification_Hush, object: nil
        )
    }

    @objc private func onCapsuleStateChange_Hush() {
        capsules_Hush = UserViewModel_Hush.shared_Hush.getAllCapsules_Hush()
        capsuleCollectionView_Hush.reloadData()
    }

    @objc private func onUserStateChange_Hush() {
        capsules_Hush = UserViewModel_Hush.shared_Hush.getAllCapsules_Hush()
        capsuleCollectionView_Hush.reloadData()
        greetingLabel_Hush.text = buildGreeting_Hush()
        // 登录状态变化时刷新头像
        refreshHeroAvatar_Hush()
    }

    // MARK: - 操作响应

    /// 点击「+ Plant」按钮，跳转时间胶囊创建页
    @objc private func onAddCapsule_Hush() {
        Navigation_Hush.toTimeCapsuleCreate_Hush { [weak self] in
            self?.reloadCapsulesSection_Hush()
        }
    }

    /// 点击 Hero 头像，直接切换 TabBar 到「我的」Tab（index 4）
    @objc private func onAvatarTap_Hush() {
        heroAvatarRing_Hush.springScaleAnimate_Hush()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            if let tabBar_hush = self?.tabBarController as? TabBar_Hush {
                tabBar_hush.switchTab_Hush(to: 4)
            }
        }
    }

    /// 点击季节挑战卡片，进入评论详情页
    private func onChallengeTap_Hush(challenge_hush: SeasonChallengeModel_Hush) {
        Navigation_Hush.toSeasonChallengeDetail_Hush(challengeModel_hush: challenge_hush)
    }

    // MARK: - 工具方法

    /// 根据当前时间段返回问候语（含登录用户名）
    private func buildGreeting_Hush() -> String {
        let hour_hush = Calendar.current.component(.hour, from: Date())
        let name_hush = UserViewModel_Hush.shared_Hush.isLoggedIn_Hush
            ? (UserViewModel_Hush.shared_Hush.getCurrentUser_Hush().userName_Hush ?? "")
            : ""
        let word_hush: String
        switch hour_hush {
        case 5..<12:  word_hush = "Good morning"
        case 12..<18: word_hush = "Good afternoon"
        case 18..<22: word_hush = "Good evening"
        default:      word_hush = "Still shooting?"
        }
        return name_hush.isEmpty ? word_hush : "\(word_hush), \(name_hush)"
    }

    /// 生成当前日期字符串
    private func buildDateString_Hush() -> String {
        let formatter_hush = DateFormatter()
        formatter_hush.dateFormat = "EEEE · MMM d"
        return formatter_hush.string(from: Date())
    }

}

// MARK: - UILabel 字间距扩展（局部使用）

private extension UILabel {

    /// 设置字间距
    func letterSpacing_Hush(spacing_hush: CGFloat) {
        guard let text_hush = text else { return }
        let attr_hush = NSMutableAttributedString(string: text_hush)
        attr_hush.addAttribute(.kern, value: spacing_hush, range: NSRange(location: 0, length: text_hush.count))
        attributedText = attr_hush
    }
}

// MARK: - UICollectionViewDataSource

extension Home_Hush: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === capsuleCollectionView_Hush {
            return capsules_Hush.count + 1
        }
        if collectionView === inspirationCollectionView_Hush {
            return hotPosts_Hush.count
        }
        if collectionView === tipsCollectionView_Hush {
            return tipCards_Hush.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // MARK: 时间胶囊
        if collectionView === capsuleCollectionView_Hush {
            if indexPath.item == capsules_Hush.count {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: AddCapsuleCell_Hush.reuseId_Hush, for: indexPath
                ) as! AddCapsuleCell_Hush
            }
            let cell_hush = collectionView.dequeueReusableCell(
                withReuseIdentifier: TimeCapsuleCell_Hush.reuseId_Hush, for: indexPath
            ) as! TimeCapsuleCell_Hush
            let capsule_hush = capsules_Hush[indexPath.item]
            cell_hush.cardView_Hush.configure_Hush(model_hush: capsule_hush)
            cell_hush.cardView_Hush.deleteAction_Hush = { [weak self] in
                self?.showDeleteCapsuleAlert_Hush(capsule_hush: capsule_hush)
            }
            return cell_hush
        }

        // MARK: 热门帖子
        if collectionView === inspirationCollectionView_Hush {
            let cell_hush = collectionView.dequeueReusableCell(
                withReuseIdentifier: InspirationCell_Hush.reuseId_Hush, for: indexPath
            ) as! InspirationCell_Hush
            let post_hush = hotPosts_Hush[indexPath.item]
            // rank 从 1 开始
            cell_hush.cardView_Hush.configureAsHotPost_Hush(model_hush: post_hush, rank_hush: indexPath.item + 1)
            // 点击跳转帖子详情页
            cell_hush.cardView_Hush.tapAction_Hush = {
                Navigation_Hush.toTitleDetail_Hush(titleModel_hush: post_hush)
            }
            return cell_hush
        }

        // MARK: 技巧提示
        let cell_hush = collectionView.dequeueReusableCell(
            withReuseIdentifier: TipFlipCell_Hush.reuseId_Hush, for: indexPath
        ) as! TipFlipCell_Hush
        cell_hush.cardView_Hush.configure_Hush(model_hush: tipCards_Hush[indexPath.item], index_hush: indexPath.item)
        return cell_hush
    }
}

// MARK: - UICollectionViewDelegate

extension Home_Hush: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === capsuleCollectionView_Hush,
           indexPath.item == capsules_Hush.count {
            onAddCapsule_Hush()
        }
    }
}

// MARK: - 删除胶囊确认弹框

extension Home_Hush {

    /// 弹出删除时间胶囊二次确认弹框
    /// - Parameter capsule_hush: 待删除的胶囊
    private func showDeleteCapsuleAlert_Hush(capsule_hush: TimeCapsuleModel_Hush) {
        let alert_hush = UIAlertController(
            title: "Delete Capsule",
            message: "\(capsule_hush.capsuleTitle_Hush) will be permanently deleted. This cannot be undone.",
            preferredStyle: .alert
        )
        alert_hush.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_hush.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            UserViewModel_Hush.shared_Hush.deleteCapsule_Hush(capsuleId_hush: capsule_hush.capsuleId_Hush)
            self?.reloadCapsulesSection_Hush()
        })
        present(alert_hush, animated: true)
    }
}
