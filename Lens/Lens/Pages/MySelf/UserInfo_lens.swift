import UIKit
import SnapKit

// MARK: - 用户中心页面（重构版）

/// 用户中心页面视图控制器（重构版）
/// 核心作用：展示指定用户的个人信息、帖子列表，支持关注/取关、发起消息、举报操作
/// 设计思路：
///   - 自定义顶部导航栏 + 背景径向光晕
///   - 彩虹头像光圈 + 渐变头部区域
///   - 统计与操作按钮统一圆角卡片
///   - 帖子区渐变区块标题 + 阴影卡片 Cell
/// 关键属性：userModel_Lens（展示目标用户），fromChat_Lens（是否由聊天页进入）
class UserInfo_Lens: UIViewController {

    // MARK: - 属性

    /// 目标用户模型，由外部注入
    var userModel_Lens: PrewUserModel_Lens?

    /// 是否由聊天页进入（true：隐藏消息按钮，关注按钮居中）
    var fromChat_Lens: Bool = false

    /// 目标用户发布的帖子列表
    private var userPosts_Lens: [TitleModel_Lens] = []

    /// 操作区高度约束（当前用户时折叠）
    private var actionHeightConstraint_Lens: Constraint?

    /// 头部渐变图层（布局时同步尺寸）
    private var headerGradientLayer_Lens: CAGradientLayer?

    /// 集合视图高度约束
    private var collectionHeightConstraint_Lens: Constraint?

    /// 空状态视图高度约束（有帖子时置 0，避免与 collectionView 争抢布局）
    private var emptyViewHeightConstraint_Lens: Constraint?

    /// 是否已完成首次布局刷新
    private var hasInitialLayoutReload_Lens = false

    // MARK: - UI 组件：背景装饰

    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：自定义导航栏（透明浮层，融入头部渐变）

    private let navOverlay_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Profile"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let reportNavBtn_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        b.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    // MARK: - UI 组件：滚动内容

    private let scrollView_Lens = UIScrollView()
    private let contentView_Lens = UIView()

    /// 顶部渐变背景
    private let headerView_Lens = UIView()

    /// 头像彩虹光圈
    private let avatarRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 47
        v.clipsToBounds = true
        return v
    }()

    /// 用户头像组件
    private let avatarView_Lens = UserAvatarView_Lens()

    /// 用户昵称标签
    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF")
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    /// 用户自我介绍标签
    private let bioLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.72)
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    /// 统计 + 操作统一圆角卡片
    private let infoCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.28
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 16
        v.clipsToBounds = false
        return v
    }()

    /// 卡片内容容器（裁剪圆角）
    private let infoCardContent_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    /// 统计数据容器
    private let statsView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 关注数标签
    private let followCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#C77DFF")
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    /// 粉丝数标签
    private let fansCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#C77DFF")
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    /// 帖子数标签
    private let postCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#C77DFF")
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    /// 操作按钮容器（关注按钮 + 消息按钮）
    private let actionView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 关注/取关按钮
    private let followBtn_Lens: UIButton = {
        let btn_Lens = UIButton(type: .custom)
        btn_Lens.setTitle("Follow", for: .normal)
        btn_Lens.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF"), for: .normal)
        btn_Lens.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn_Lens.layer.cornerRadius = 20
        btn_Lens.clipsToBounds = true
        return btn_Lens
    }()

    private let followGradientLayer_Lens: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1, y: 0.5)
        g.cornerRadius = 20
        return g
    }()

    /// 发消息按钮
    private let messageBtn_Lens: UIButton = {
        let btn_Lens = UIButton(type: .system)
        btn_Lens.setTitle("Message", for: .normal)
        btn_Lens.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF"), for: .normal)
        btn_Lens.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        btn_Lens.layer.cornerRadius = 20
        btn_Lens.layer.borderWidth = 1
        btn_Lens.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
        return btn_Lens
    }()

    /// 帖子双列集合视图
    private lazy var collectionView_Lens: UICollectionView = {
        let layout_Lens = UICollectionViewFlowLayout()
        let spacing_Lens: CGFloat = 10
        let itemWidth_Lens = (UIScreen.main.bounds.width - 16 * 2 - spacing_Lens) / 2
        layout_Lens.itemSize = CGSize(width: itemWidth_Lens, height: itemWidth_Lens * 1.28)
        layout_Lens.minimumInteritemSpacing = spacing_Lens
        layout_Lens.minimumLineSpacing = spacing_Lens
        layout_Lens.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        let cv_Lens = UICollectionView(frame: .zero, collectionViewLayout: layout_Lens)
        cv_Lens.backgroundColor = .clear
        cv_Lens.isScrollEnabled = false
        cv_Lens.dataSource = self
        cv_Lens.delegate = self
        cv_Lens.register(UserPostCell_Lens.self, forCellWithReuseIdentifier: UserPostCell_Lens.reuseId_Lens)
        return cv_Lens
    }()

    /// 空帖子占位视图
    private let emptyView_Lens: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData_Lens()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasInitialLayoutReload_Lens else { return }
        hasInitialLayoutReload_Lens = true
        refreshData_Lens()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Lens()
        setupScrollContent_Lens()
        observeNotifications_Lens()
        refreshData_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let ringLayer_Lens = avatarRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = avatarRingView_Lens.bounds
        }
        followGradientLayer_Lens.frame = followBtn_Lens.bounds
        headerGradientLayer_Lens?.frame = headerView_Lens.bounds
        infoCardView_Lens.layer.shadowPath = UIBezierPath(
            roundedRect: infoCardView_Lens.bounds,
            cornerRadius: 20
        ).cgPath
        let navH_Lens = view.safeAreaInsets.top + 44
        navOverlay_Lens.snp.updateConstraints { $0.height.equalTo(navH_Lens) }
    }

    // MARK: - 布局搭建

    /// 配置视图基础属性
    private func setupView_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        view.insertSubview(backgroundGlowView_Lens, at: 0)
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        setupBackgroundGlows_Lens()
    }

    /// 构建背景多层径向光晕
    private func setupBackgroundGlows_Lens() {
        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.22).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purple_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purple_Lens.frame = CGRect(x: -60, y: -40, width: 280, height: 280)
        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)

        let blue_Lens = CAGradientLayer()
        blue_Lens.type = .radial
        blue_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.15).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blue_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blue_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        let sw_Lens = UIScreen.main.bounds.width
        blue_Lens.frame = CGRect(x: sw_Lens - 80, y: 40, width: 200, height: 200)
        backgroundGlowView_Lens.layer.addSublayer(blue_Lens)
    }

    /// 搭建自定义顶部导航栏（透明浮层，按钮与标题对齐）
    private func setupCustomNavigation_Lens() {
        headerView_Lens.addSubview(navOverlay_Lens)
        navOverlay_Lens.addSubview(backButton_Lens)
        navOverlay_Lens.addSubview(navTitleLabel_Lens)
        navOverlay_Lens.addSubview(reportNavBtn_Lens)
        backButton_Lens.addTarget(self, action: #selector(onBackTap_Lens), for: .touchUpInside)
        reportNavBtn_Lens.addTarget(self, action: #selector(onReportTap_Lens), for: .touchUpInside)

        navOverlay_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(8)
            $0.width.height.equalTo(36)
        }
        reportNavBtn_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(backButton_Lens)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
            $0.leading.greaterThanOrEqualTo(backButton_Lens.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(reportNavBtn_Lens.snp.leading).offset(-8)
        }
    }

    @objc private func onBackTap_Lens() {
        Navigation_Lens.pop_Lens(from: self)
    }

    /// 搭建主滚动内容
    private func setupScrollContent_Lens() {
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)
        scrollView_Lens.showsVerticalScrollIndicator = false
        scrollView_Lens.contentInsetAdjustmentBehavior = .never
        scrollView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        setupHeaderSection_Lens()
        setupInfoCardSection_Lens()
        setupPostsSection_Lens()
    }

    /// 搭建顶部头像 + 昵称 + 简介区域
    private func setupHeaderSection_Lens() {
        headerView_Lens.backgroundColor = .clear
        contentView_Lens.addSubview(headerView_Lens)
        headerView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        let headerGrad_Lens = CAGradientLayer()
        headerGrad_Lens.colors = [
            UIColor(hexstring_Lens: "#4A28A8").cgColor,
            UIColor(hexstring_Lens: "#1E4FA8").cgColor,
            UIColor(hexstring_Lens: "#0D0D1A").cgColor
        ]
        headerGrad_Lens.locations = [0, 0.52, 1]
        headerGrad_Lens.startPoint = CGPoint(x: 0, y: 0)
        headerGrad_Lens.endPoint = CGPoint(x: 1, y: 1)
        headerView_Lens.layer.insertSublayer(headerGrad_Lens, at: 0)
        headerGradientLayer_Lens = headerGrad_Lens

        setupCustomNavigation_Lens()
        setupAvatarRingGradient_Lens()

        avatarView_Lens.layer.cornerRadius = 44
        avatarView_Lens.clipsToBounds = true
        headerView_Lens.addSubview(avatarRingView_Lens)
        avatarRingView_Lens.addSubview(avatarView_Lens)
        headerView_Lens.addSubview(nameLabel_Lens)
        headerView_Lens.addSubview(bioLabel_Lens)

        avatarRingView_Lens.snp.makeConstraints {
            $0.top.equalTo(navOverlay_Lens.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(94)
        }
        avatarView_Lens.snp.makeConstraints { $0.edges.equalToSuperview().inset(3) }
        nameLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(avatarRingView_Lens.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        bioLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Lens.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(32)
        }
        headerView_Lens.bringSubviewToFront(navOverlay_Lens)
    }

    /// 构建头像彩虹渐变光圈
    private func setupAvatarRingGradient_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradient_Lens.cornerRadius = 47
        gradient_Lens.frame = CGRect(x: 0, y: 0, width: 94, height: 94)
        avatarRingView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
    }

    /// 搭建统计 + 操作按钮统一卡片
    private func setupInfoCardSection_Lens() {
        contentView_Lens.addSubview(infoCardView_Lens)
        infoCardView_Lens.addSubview(infoCardContent_Lens)
        infoCardContent_Lens.addSubview(statsView_Lens)
        infoCardContent_Lens.addSubview(actionView_Lens)
        infoCardView_Lens.snp.makeConstraints {
            $0.top.equalTo(headerView_Lens.snp.bottom).offset(-12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        infoCardContent_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        setupStatsSection_Lens()
        setupActionSection_Lens()
    }

    /// 搭建统计数据区（关注数 / 粉丝数 / 帖子数）
    private func setupStatsSection_Lens() {
        statsView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(68)
        }

        let statTitles_Lens = ["Following", "Fans", "Posts"]
        let statCounts_Lens = [followCountLabel_Lens, fansCountLabel_Lens, postCountLabel_Lens]
        var prevStack_Lens: UIStackView?
        for (idx_Lens, title_Lens) in statTitles_Lens.enumerated() {
            let titleLbl_Lens = UILabel()
            titleLbl_Lens.text = title_Lens
            titleLbl_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
            titleLbl_Lens.font = UIFont.systemFont(ofSize: 12)
            titleLbl_Lens.textAlignment = .center

            let stack_Lens = UIStackView(arrangedSubviews: [statCounts_Lens[idx_Lens], titleLbl_Lens])
            stack_Lens.axis = .vertical
            stack_Lens.alignment = .center
            stack_Lens.spacing = 3
            statsView_Lens.addSubview(stack_Lens)
            stack_Lens.snp.makeConstraints { make_Lens in
                make_Lens.centerY.equalToSuperview()
                make_Lens.width.equalToSuperview().dividedBy(3)
                if let prev_Lens = prevStack_Lens {
                    make_Lens.leading.equalTo(prev_Lens.snp.trailing)
                } else {
                    make_Lens.leading.equalToSuperview()
                }
                if idx_Lens == statTitles_Lens.count - 1 {
                    make_Lens.trailing.equalToSuperview()
                }
            }
            prevStack_Lens = stack_Lens
        }

        // 渐变竖条分隔
        for xFrac_Lens in [CGFloat(1) / 3, CGFloat(2) / 3] {
            let divider_Lens = UIView()
            divider_Lens.isUserInteractionEnabled = false
            statsView_Lens.addSubview(divider_Lens)
            divider_Lens.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.height.equalTo(28)
                $0.width.equalTo(1)
                $0.centerX.equalToSuperview().multipliedBy(xFrac_Lens * 2)
            }
            let divGrad_Lens = CAGradientLayer()
            divGrad_Lens.colors = [
                UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor,
                UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.45).cgColor,
                UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
            ]
            divGrad_Lens.startPoint = CGPoint(x: 0.5, y: 0)
            divGrad_Lens.endPoint = CGPoint(x: 0.5, y: 1)
            divGrad_Lens.frame = CGRect(x: 0, y: 0, width: 1, height: 28)
            divider_Lens.layer.addSublayer(divGrad_Lens)
        }

        let divider_Lens = UIView()
        divider_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        statsView_Lens.addSubview(divider_Lens)
        divider_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    /// 搭建操作按钮区（关注 + 消息）
    private func setupActionSection_Lens() {
        actionView_Lens.snp.makeConstraints {
            $0.top.equalTo(statsView_Lens.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            actionHeightConstraint_Lens = $0.height.equalTo(64).constraint
        }

        followBtn_Lens.layer.insertSublayer(followGradientLayer_Lens, at: 0)
        followBtn_Lens.addTarget(self, action: #selector(onFollowTap_Lens), for: .touchUpInside)
        messageBtn_Lens.addTarget(self, action: #selector(onMessageTap_Lens), for: .touchUpInside)
        actionView_Lens.addSubview(followBtn_Lens)
        actionView_Lens.addSubview(messageBtn_Lens)

        if fromChat_Lens {
            messageBtn_Lens.isHidden = true
            followBtn_Lens.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(180)
                $0.height.equalTo(40)
            }
        } else {
            followBtn_Lens.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().inset(16)
                $0.trailing.equalTo(actionView_Lens.snp.centerX).offset(-5)
                $0.height.equalTo(40)
            }
            messageBtn_Lens.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(actionView_Lens.snp.centerX).offset(5)
                $0.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(40)
            }
        }
    }

    /// 搭建帖子集合视图区
    private func setupPostsSection_Lens() {
        let sectionHeader_Lens = UIView()
        contentView_Lens.addSubview(sectionHeader_Lens)
        sectionHeader_Lens.snp.makeConstraints {
            $0.top.equalTo(infoCardView_Lens.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }

        let accentBar_Lens = UIView()
        accentBar_Lens.layer.cornerRadius = 1.5
        let barGrad_Lens = CAGradientLayer()
        barGrad_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor
        ]
        barGrad_Lens.startPoint = CGPoint(x: 0.5, y: 0)
        barGrad_Lens.endPoint = CGPoint(x: 0.5, y: 1)
        barGrad_Lens.cornerRadius = 1.5
        barGrad_Lens.frame = CGRect(x: 0, y: 0, width: 3, height: 14)
        accentBar_Lens.layer.addSublayer(barGrad_Lens)

        let sectionLabel_Lens = UILabel()
        sectionLabel_Lens.text = "POSTS"
        sectionLabel_Lens.textColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.85)
        sectionLabel_Lens.font = UIFont.systemFont(ofSize: 11, weight: .bold)

        sectionHeader_Lens.addSubview(accentBar_Lens)
        sectionHeader_Lens.addSubview(sectionLabel_Lens)
        accentBar_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.equalTo(3)
            $0.height.equalTo(14)
        }
        sectionLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(accentBar_Lens.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        contentView_Lens.addSubview(collectionView_Lens)
        collectionView_Lens.snp.makeConstraints {
            $0.top.equalTo(sectionHeader_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            collectionHeightConstraint_Lens = $0.height.equalTo(200).constraint
        }

        let emptyIcon_Lens = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled"))
        emptyIcon_Lens.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        emptyIcon_Lens.contentMode = .scaleAspectFit
        let emptyLabel_Lens = UILabel()
        emptyLabel_Lens.text = "No posts yet"
        emptyLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        emptyLabel_Lens.font = UIFont.systemFont(ofSize: 15)
        emptyView_Lens.addSubview(emptyIcon_Lens)
        emptyView_Lens.addSubview(emptyLabel_Lens)
        emptyIcon_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(30)
            $0.width.height.equalTo(56)
        }
        emptyLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(emptyIcon_Lens.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        contentView_Lens.addSubview(emptyView_Lens)
        emptyView_Lens.snp.makeConstraints {
            $0.top.equalTo(sectionHeader_Lens.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            emptyViewHeightConstraint_Lens = $0.height.equalTo(150).constraint
        }
    }

    // MARK: - 数据刷新

    /// 注册通知监听
    private func observeNotifications_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStateChange_Lens),
            name: UserViewModel_Lens.userStateDidChangeNotification_Lens,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStateChange_Lens),
            name: TitleViewModel_Lens.titleStateDidChangeNotification_Lens,
            object: nil
        )
    }

    @objc private func onStateChange_Lens() {
        refreshData_Lens()
    }

    /// 刷新用户信息、统计数据与帖子列表
    private func refreshData_Lens() {
        if let userId_Lens = userModel_Lens?.userId_Lens,
           let latestUser_Lens = LocalData_Lens.shared_Lens.userList_Lens.first(where: { $0.userId_Lens == userId_Lens }) {
            userModel_Lens = latestUser_Lens
        }
        guard let user_Lens = userModel_Lens else { return }

        // 头像
        if let userId_Lens = user_Lens.userId_Lens {
            avatarView_Lens.configure_Lens(userId_Lens: userId_Lens)
        }
        nameLabel_Lens.text = user_Lens.userName_Lens ?? "User"
        bioLabel_Lens.text = user_Lens.userIntroduce_Lens ?? ""
        followCountLabel_Lens.text = "\(user_Lens.userFollow_Lens ?? 0)"
        fansCountLabel_Lens.text = "\(user_Lens.userFans_Lens ?? 0)"

        // 帖子列表
        userPosts_Lens = TitleViewModel_Lens.shared_Lens.getUserPosts_Lens(user_lens: user_Lens)
        postCountLabel_Lens.text = "\(userPosts_Lens.count)"

        let isEmpty_Lens = userPosts_Lens.isEmpty
        emptyView_Lens.isHidden = !isEmpty_Lens
        collectionView_Lens.isHidden = isEmpty_Lens
        emptyViewHeightConstraint_Lens?.update(offset: isEmpty_Lens ? 150 : 0)
        collectionView_Lens.reloadData()
        updateCollectionHeight_Lens()

        // 更新关注按钮状态
        updateFollowButtonState_Lens()

        // 如果是当前登录用户：隐藏关注和消息按钮
        let isSelf_Lens: Bool
        if let userId_Lens = user_Lens.userId_Lens,
           UserViewModel_Lens.shared_Lens.isCurrentUser_Lens(userId_lens: userId_Lens) {
            isSelf_Lens = true
        } else {
            isSelf_Lens = false
        }
        actionView_Lens.isHidden = isSelf_Lens
        actionHeightConstraint_Lens?.update(offset: isSelf_Lens ? 0 : 64)
        reportNavBtn_Lens.isHidden = isSelf_Lens
    }

    /// 更新关注按钮文字与样式
    private func updateFollowButtonState_Lens() {
        guard let user_Lens = userModel_Lens else { return }
        let isFollowing_Lens = UserViewModel_Lens.shared_Lens.isFollowing_Lens(user_lens: user_Lens)
        if isFollowing_Lens {
            followBtn_Lens.setTitle("Following", for: .normal)
            followGradientLayer_Lens.isHidden = true
            followBtn_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
            followBtn_Lens.layer.borderWidth = 1
            followBtn_Lens.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
        } else {
            followBtn_Lens.setTitle("Follow", for: .normal)
            followGradientLayer_Lens.isHidden = false
            followBtn_Lens.backgroundColor = .clear
            followBtn_Lens.layer.borderWidth = 0
        }
    }

    /// 动态更新集合视图高度约束
    private func updateCollectionHeight_Lens() {
        guard !userPosts_Lens.isEmpty else {
            // 空态时保留占位高度，由 emptyView 展示内容
            collectionHeightConstraint_Lens?.update(offset: 150)
            return
        }
        let layout_Lens = collectionView_Lens.collectionViewLayout as? UICollectionViewFlowLayout
        let itemH_Lens = layout_Lens?.itemSize.height ?? 150
        let lineSpacing_Lens = layout_Lens?.minimumLineSpacing ?? 10
        let sectionInset_Lens = layout_Lens?.sectionInset ?? .zero
        let rows_Lens = Int(ceil(Double(userPosts_Lens.count) / 2.0))
        let totalH_Lens = CGFloat(rows_Lens) * itemH_Lens
            + CGFloat(max(0, rows_Lens - 1)) * lineSpacing_Lens
            + sectionInset_Lens.top + sectionInset_Lens.bottom
        collectionHeightConstraint_Lens?.update(offset: totalH_Lens)
        view.layoutIfNeeded()
    }

    // MARK: - 事件响应

    /// 关注/取关按钮点击
    @objc private func onFollowTap_Lens() {
        guard let user_Lens = userModel_Lens else { return }
        UserViewModel_Lens.shared_Lens.followUser_Lens(user_lens: user_Lens)
        updateFollowButtonState_Lens()
    }

    /// 消息按钮点击：检查关注状态，弹出用户信息底部弹窗
    @objc private func onMessageTap_Lens() {
        guard let user_Lens = userModel_Lens else { return }

        // 未关注时给出提示，不展示弹窗
        guard UserViewModel_Lens.shared_Lens.isFollowing_Lens(user_lens: user_Lens) else {
            Load_Lens.showWarning_Lens(message_Lens: "Please follow this user first to start chatting")
            return
        }

        // 展示底部确认弹窗
        let sheetVC_Lens = UserMessageSheetVC_Lens(user_Lens: user_Lens)
        sheetVC_Lens.onConfirm_Lens = { [weak self] in
            guard let self, let u = self.userModel_Lens else { return }
            DispatchQueue.main.async {
                Navigation_Lens.toMessageUser_Lens(with: u, from: self)
            }
        }
        sheetVC_Lens.modalPresentationStyle = .overFullScreen
        sheetVC_Lens.modalTransitionStyle = .crossDissolve
        present(sheetVC_Lens, animated: true)
    }

    /// 右上角举报按钮点击：弹出举报弹窗，确认后执行拉黑并安全导航
    @objc private func onReportTap_Lens() {
        guard let user_Lens = userModel_Lens else { return }
        ReportDeleteHelper_Lens.block_Lens(user_Lens: user_Lens, from: self) { [weak self] in
            guard let self else { return }
            Navigation_Lens.popToSafeStateAfterBlock_Lens(from: self)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension UserInfo_Lens: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        userPosts_Lens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Lens = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserPostCell_Lens.reuseId_Lens,
            for: indexPath
        ) as! UserPostCell_Lens
        cell_Lens.configure_Lens(post_Lens: userPosts_Lens[indexPath.item], from_Lens: self) { [weak self] in
            self?.refreshData_Lens()
        }
        return cell_Lens
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Lens.toTitleDetail_Lens(titleModel_lens: userPosts_Lens[indexPath.item])
    }
}

// MARK: - 用户帖子 Cell（重构版）

/// 用户中心帖子 Cell（重构版）
/// 核心作用：展示媒体封面、浮层标题以及右上角举报/删除按钮
/// 设计思路：全图展示 + 底部渐变遮罩标题，与 Discover 卡片风格统一
class UserPostCell_Lens: UICollectionViewCell {

    // MARK: - 静态常量

    static let reuseId_Lens = "UserPostCell_Lens"

    // MARK: - UI 组件

    private let shadowContainer_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.32
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }()

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.clipsToBounds = true
        return v
    }()

    private let mediaView_Lens: MediaDisplayView_Lens = {
        let v = MediaDisplayView_Lens()
        v.clipsToBounds = true
        return v
    }()

    /// 媒体底部渐变遮罩
    private let mediaGradientView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.numberOfLines = 2
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOpacity = 0.45
        l.layer.shadowRadius = 2
        l.layer.shadowOffset = CGSize(width: 0, height: 1)
        return l
    }()

    private let reportContainer_Lens = UIView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius_Lens: CGFloat = 14
        shadowContainer_Lens.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainer_Lens.bounds, cornerRadius: cornerRadius_Lens
        ).cgPath
        cardView_Lens.layer.cornerRadius = cornerRadius_Lens
        cardView_Lens.clipsToBounds = true
        if let gradientLayer_Lens = mediaGradientView_Lens.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer_Lens.frame = mediaGradientView_Lens.bounds
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel_Lens.text = nil
        mediaView_Lens.configure_Lens(mediaPath_Lens: nil)
        reportContainer_Lens.subviews.forEach { $0.removeFromSuperview() }
    }

    private func setupUI_Lens() {
        contentView.addSubview(shadowContainer_Lens)
        shadowContainer_Lens.addSubview(cardView_Lens)
        cardView_Lens.addSubview(mediaView_Lens)
        cardView_Lens.addSubview(mediaGradientView_Lens)
        cardView_Lens.addSubview(titleLabel_Lens)
        cardView_Lens.addSubview(reportContainer_Lens)

        setupMediaGradientLayer_Lens()

        shadowContainer_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        cardView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        mediaView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        mediaGradientView_Lens.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(72)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
        }
        reportContainer_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().inset(6)
            $0.width.height.equalTo(28)
        }
    }

    /// 构建媒体底部渐变遮罩
    private func setupMediaGradientLayer_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor.clear.cgColor,
            UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.82).cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0.5, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 0.5, y: 1)
        mediaGradientView_Lens.layer.addSublayer(gradient_Lens)
    }

    /// 配置 Cell 数据
    /// 参数：
    /// - post_Lens: 帖子模型
    /// - from_Lens: 所属视图控制器
    /// - completion_Lens: 操作完成后刷新回调
    func configure_Lens(post_Lens: TitleModel_Lens, from_Lens: UIViewController, completion_Lens: (() -> Void)? = nil) {
        mediaView_Lens.applyDisplayCornerRadius_Lens(14)
        mediaView_Lens.configure_Lens(mediaPath_Lens: post_Lens.titleMeidas_Lens.first)
        titleLabel_Lens.text = post_Lens.title_Lens
        reportContainer_Lens.subviews.forEach { $0.removeFromSuperview() }
        let btn_Lens = ReportDeleteHelper_Lens.createPostReportButton_Lens(
            post_Lens: post_Lens,
            size_Lens: 14,
            color_Lens: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.85),
            from: from_Lens,
            completion_Lens: completion_Lens
        )
        reportContainer_Lens.addSubview(btn_Lens)
        btn_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - 用户消息确认底部弹窗

/// 发消息前的用户信息确认底部弹窗
/// 功能：展示目标用户头像、昵称、简介，提供 Confirm / Cancel 操作
/// 设计：半透明遮罩 + 底部卡片上滑动画
class UserMessageSheetVC_Lens: UIViewController {

    // MARK: - 属性

    /// 目标用户模型
    private let user_Lens: PrewUserModel_Lens

    /// 点击 Confirm 后的回调
    var onConfirm_Lens: (() -> Void)?

    // MARK: - UI 组件

    private let maskView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        return v
    }()

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1A1A2E")
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let avatarView_Lens = UserAvatarView_Lens()

    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF")
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private let bioLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF").withAlphaComponent(0.6)
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - 初始化

    /// 初始化底部弹窗
    /// 参数：
    /// - user_Lens: 目标用户信息
    init(user_Lens: PrewUserModel_Lens) {
        self.user_Lens = user_Lens
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        fillData_Lens()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn_Lens()
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        view.addSubview(maskView_Lens)
        view.addSubview(cardView_Lens)

        maskView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 点击遮罩关闭
        let tap_Lens = UITapGestureRecognizer(target: self, action: #selector(onMaskTap_Lens))
        maskView_Lens.addGestureRecognizer(tap_Lens)

        cardView_Lens.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(320)
        }

        // 顶部抓手
        let handle_Lens = UIView()
        handle_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF").withAlphaComponent(0.2)
        handle_Lens.layer.cornerRadius = 2.5
        cardView_Lens.addSubview(handle_Lens)
        handle_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }

        // 头像
        avatarView_Lens.layer.cornerRadius = 36
        avatarView_Lens.clipsToBounds = true
        cardView_Lens.addSubview(avatarView_Lens)
        avatarView_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(72)
        }

        cardView_Lens.addSubview(nameLabel_Lens)
        cardView_Lens.addSubview(bioLabel_Lens)
        nameLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(avatarView_Lens.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(24)
        }
        bioLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Lens.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(32)
        }

        // Confirm 按钮
        let confirmBtn_Lens = UIButton(type: .system)
        confirmBtn_Lens.setTitle("Confirm", for: .normal)
        confirmBtn_Lens.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF"), for: .normal)
        confirmBtn_Lens.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        confirmBtn_Lens.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
        confirmBtn_Lens.layer.cornerRadius = 22
        confirmBtn_Lens.addTarget(self, action: #selector(onConfirmTap_Lens), for: .touchUpInside)
        cardView_Lens.addSubview(confirmBtn_Lens)
        confirmBtn_Lens.snp.makeConstraints {
            $0.top.equalTo(bioLabel_Lens.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        // Cancel 按钮
        let cancelBtn_Lens = UIButton(type: .system)
        cancelBtn_Lens.setTitle("Cancel", for: .normal)
        cancelBtn_Lens.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF").withAlphaComponent(0.6), for: .normal)
        cancelBtn_Lens.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelBtn_Lens.addTarget(self, action: #selector(onMaskTap_Lens), for: .touchUpInside)
        cardView_Lens.addSubview(cancelBtn_Lens)
        cancelBtn_Lens.snp.makeConstraints {
            $0.top.equalTo(confirmBtn_Lens.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(44)
        }

        // 初始位置在屏幕外（上滑动画用）
        cardView_Lens.transform = CGAffineTransform(translationX: 0, y: 320)
        maskView_Lens.alpha = 0
    }

    /// 填充用户数据
    private func fillData_Lens() {
        if let userId_Lens = user_Lens.userId_Lens {
            avatarView_Lens.configure_Lens(userId_Lens: userId_Lens)
        }
        nameLabel_Lens.text = user_Lens.userName_Lens ?? "User"
        bioLabel_Lens.text = user_Lens.userIntroduce_Lens ?? ""
    }

    /// 上滑入场动画
    private func animateIn_Lens() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.cardView_Lens.transform = .identity
            self.maskView_Lens.alpha = 1
        }
    }

    /// 下滑退场动画后 dismiss
    private func animateOut_Lens(completion_Lens: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25) {
            self.cardView_Lens.transform = CGAffineTransform(translationX: 0, y: 320)
            self.maskView_Lens.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false) {
                completion_Lens?()
            }
        }
    }

    // MARK: - 事件响应

    /// 点击遮罩关闭
    @objc private func onMaskTap_Lens() {
        animateOut_Lens()
    }

    /// 点击 Confirm 关闭弹窗并执行回调
    @objc private func onConfirmTap_Lens() {
        animateOut_Lens { [weak self] in
            self?.onConfirm_Lens?()
        }
    }
}
