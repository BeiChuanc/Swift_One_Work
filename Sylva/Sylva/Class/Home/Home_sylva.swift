import Foundation
import UIKit
import SnapKit

// MARK: - 首页（生态公益主题）

/// 首页视图控制器
/// 核心作用：展示每日打卡、生态任务、环保知识、热门帖子推荐，激励用户参与公益行动
/// 设计思路：渐变 Hero + 打卡卡片 + 横向任务滑动 + 知识横向滑动 + 热门帖子列表
class Home_Sylva: UIViewController {

    // MARK: - 私有属性

    private let scrollView_Sylva  = UIScrollView()
    private let contentView_Sylva = UIView()

    /// Hero 渐变层
    private let heroView_Sylva      = UIView()
    private let heroGradient_Sylva  = CAGradientLayer()
    private let heroGradMask_Sylva  = CAShapeLayer()

    /// 环保值标签（Hero 右侧）
    private let ecoPointsLabel_Sylva = UILabel()

    /// 任务横向滚动
    private let tasksScrollView_Sylva = UIScrollView()
    private let tasksStack_Sylva      = UIStackView()

    /// 知识横向滚动
    private let knowledgeScrollView_Sylva = UIScrollView()
    private let knowledgeStack_Sylva      = UIStackView()

    /// 热门帖子轮播
    private var hotPostsCarousel_Sylva: UICollectionView!
    private let hotPageControl_Sylva  = UIPageControl()
    private var hotPosts_Sylva: [TitleModel_Sylva] = []

    /// 打卡按钮（需动态更新）
    private let checkInButton_Sylva = UIButton(type: .system)
    /// 打卡连续天数进度条容器
    private let streakContainer_Sylva = UIView()

    /// 环保知识静态数据
    private let knowledgeData_Sylva: [(String, String, String, UIColor)] = [
        ("leaf.fill",          "Trees & CO₂",
         "A mature tree absorbs ~48 lbs of CO₂ per year — equal to driving 26 miles.",
         UIColor(hexstring_Sylva: "#2D6A4F")),
        ("drop.fill",          "Water Cycle",
         "One large tree transpires 100+ gallons of water daily, cooling the local air.",
         UIColor(hexstring_Sylva: "#0096C7")),
        ("wind",               "Air Quality",
         "An acre of trees produces enough oxygen for 18 people every single day.",
         UIColor(hexstring_Sylva: "#4A0E8F")),
        ("globe.americas.fill","Biodiversity",
         "A single oak tree supports 500+ species of insects, birds, and mammals.",
         UIColor(hexstring_Sylva: "#B45309")),
        ("flame.fill",         "Wildfire Defense",
         "Green firebreaks of native trees reduce wildfire spread by up to 70%.",
         UIColor(hexstring_Sylva: "#C2410C")),
    ]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        setupScrollView_Sylva()
        setupHero_Sylva()
        setupCheckInCard_Sylva()
        setupTasksSection_Sylva()
        setupKnowledgeSection_Sylva()
        setupHotPostsSection_Sylva()
        observeNotifications_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshAll_Sylva()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradient_Sylva.frame = heroView_Sylva.bounds
        let path_sylva = UIBezierPath(
            roundedRect: heroView_Sylva.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 28, height: 28)
        )
        heroGradMask_Sylva.path = path_sylva.cgPath
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupScrollView_Sylva() {
        scrollView_Sylva.showsVerticalScrollIndicator = false
        scrollView_Sylva.contentInsetAdjustmentBehavior = .never
        scrollView_Sylva.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(contentView_Sylva)
        scrollView_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
    }

    /// 搭建渐变 Hero 头部（含标题、用户头像、环保值）
    private func setupHero_Sylva() {
        heroGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#40916C").cgColor
        ]
        heroGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        heroGradient_Sylva.endPoint   = CGPoint(x: 1, y: 1)
        heroGradient_Sylva.mask       = heroGradMask_Sylva
        heroView_Sylva.layer.insertSublayer(heroGradient_Sylva, at: 0)
        contentView_Sylva.addSubview(heroView_Sylva)
        heroView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }

        // 装饰圆
        let deco_sylva = UIView()
        deco_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        deco_sylva.layer.cornerRadius = 55
        heroView_Sylva.addSubview(deco_sylva)
        deco_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(110)
        }

        // 叶子图标
        let leafIcon_sylva = UIImageView(image: UIImage(systemName: "leaf.fill"))
        leafIcon_sylva.tintColor = UIColor.white.withAlphaComponent(0.9)
        leafIcon_sylva.contentMode = .scaleAspectFit
        heroView_Sylva.addSubview(leafIcon_sylva)

        // 标题
        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Sylva"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        titleLabel_sylva.textColor = .white
        heroView_Sylva.addSubview(titleLabel_sylva)

        // 环保值 chip
        let chipView_sylva = UIView()
        chipView_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        chipView_sylva.layer.cornerRadius = 14
        heroView_Sylva.addSubview(chipView_sylva)

        let leafChip_sylva = UIImageView(image: UIImage(systemName: "leaf.circle.fill"))
        leafChip_sylva.tintColor = UIColor(hexstring_Sylva: "#95D5B2")
        leafChip_sylva.contentMode = .scaleAspectFit
        chipView_sylva.addSubview(leafChip_sylva)

        ecoPointsLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        ecoPointsLabel_Sylva.textColor = .white
        chipView_sylva.addSubview(ecoPointsLabel_Sylva)

        // 用户头像（右上角）
        let avatarView_sylva = CurrentUserAvatarView_Sylva()
        avatarView_sylva.layer.cornerRadius = 20
        avatarView_sylva.layer.masksToBounds = true
        avatarView_sylva.layer.borderWidth = 2
        avatarView_sylva.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        avatarView_sylva.onTapped_Sylva = { [weak self] in
            // Me 页在 TabBar 索引 4
            self?.tabBarController?.selectedIndex = 4
        }
        heroView_Sylva.addSubview(avatarView_sylva)

        // 统一约束（所有视图已加入 heroView）
        leafIcon_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        titleLabel_sylva.snp.makeConstraints { make in
            make.leading.equalTo(leafIcon_sylva.snp.trailing).offset(8)
            make.centerY.equalTo(leafIcon_sylva)
        }
        avatarView_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(leafIcon_sylva)
            make.width.height.equalTo(40)
        }
        chipView_sylva.snp.makeConstraints { make in
            make.trailing.equalTo(avatarView_sylva.snp.leading).offset(-10)
            make.centerY.equalTo(avatarView_sylva)
            make.height.equalTo(28)
        }
        leafChip_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        ecoPointsLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(leafChip_sylva.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
        }
    }

    /// 搭建每日打卡卡片
    private func setupCheckInCard_Sylva() {
        let card_sylva = UIView()
        card_sylva.backgroundColor = .white
        card_sylva.layer.cornerRadius = 20
        card_sylva.layer.shadowColor  = UIColor.black.cgColor
        card_sylva.layer.shadowOpacity = 0.07
        card_sylva.layer.shadowRadius  = 10
        card_sylva.layer.shadowOffset  = CGSize(width: 0, height: 4)
        contentView_Sylva.addSubview(card_sylva)
        card_sylva.snp.makeConstraints { make in
            make.top.equalTo(heroView_Sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 标题行
        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Daily Check-In"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        card_sylva.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        // 倍率标签
        let multiplierLabel_Sylva = UILabel()
        multiplierLabel_Sylva.tag = 500
        multiplierLabel_Sylva.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        multiplierLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#52B788")
        card_sylva.addSubview(multiplierLabel_Sylva)
        multiplierLabel_Sylva.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_sylva)
            make.leading.equalTo(titleLabel_sylva.snp.trailing).offset(8)
        }

        // 7/14 天进度点
        card_sylva.addSubview(streakContainer_Sylva)
        streakContainer_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_sylva.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }

        // 打卡按钮
        checkInButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        checkInButton_Sylva.layer.cornerRadius = 16
        checkInButton_Sylva.addTarget(self, action: #selector(checkInTapped_Sylva), for: .touchUpInside)
        card_sylva.addSubview(checkInButton_Sylva)
        checkInButton_Sylva.snp.makeConstraints { make in
            make.top.equalTo(streakContainer_Sylva.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(42)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    /// 搭建每日任务横向滑动区
    private func setupTasksSection_Sylva() {
        let titleLabel_sylva = makeSectionTitle_Sylva("Daily Tasks", icon: "checkmark.seal.fill")
        contentView_Sylva.addSubview(titleLabel_sylva)

        let prevCard_sylva = contentView_Sylva.subviews.last(where: { $0.layer.cornerRadius == 20 })
        titleLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(prevCard_sylva?.snp.bottom ?? heroView_Sylva.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        tasksScrollView_Sylva.showsHorizontalScrollIndicator = false
        tasksScrollView_Sylva.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        contentView_Sylva.addSubview(tasksScrollView_Sylva)
        tasksScrollView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_sylva.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }

        tasksStack_Sylva.axis = .horizontal
        tasksStack_Sylva.spacing = 12
        tasksScrollView_Sylva.addSubview(tasksStack_Sylva)
        tasksStack_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    /// 搭建环保知识横向滑动区
    private func setupKnowledgeSection_Sylva() {
        let titleLabel_sylva = makeSectionTitle_Sylva("Green Knowledge", icon: "book.fill")
        contentView_Sylva.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(tasksScrollView_Sylva.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        knowledgeScrollView_Sylva.showsHorizontalScrollIndicator = false
        knowledgeScrollView_Sylva.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        contentView_Sylva.addSubview(knowledgeScrollView_Sylva)
        knowledgeScrollView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_sylva.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }

        knowledgeStack_Sylva.axis = .horizontal
        knowledgeStack_Sylva.spacing = 12
        knowledgeScrollView_Sylva.addSubview(knowledgeStack_Sylva)
        knowledgeStack_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        for (idx_sylva, data_sylva) in knowledgeData_Sylva.enumerated() {
            let card_sylva = makeKnowledgeCard_Sylva(
                icon_sylva: data_sylva.0,
                title_sylva: data_sylva.1,
                content_sylva: data_sylva.2,
                color_sylva: data_sylva.3
            )
            card_sylva.tag = 600 + idx_sylva
            // 绑定点击手势（index 通过 tag 反查知识数据）
            let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(knowledgeTapped_Sylva(_:)))
            card_sylva.addGestureRecognizer(tap_sylva)
            knowledgeStack_Sylva.addArrangedSubview(card_sylva)
            card_sylva.snp.makeConstraints { make in make.width.equalTo(220) }
            card_sylva.animateSpringScaleIn_Sylva(delay_Sylva: 0.06 * Double(idx_sylva))
        }
        let trail_sylva = UIView()
        trail_sylva.snp.makeConstraints { make in make.width.equalTo(4) }
        knowledgeStack_Sylva.addArrangedSubview(trail_sylva)
    }

    /// 搭建热门帖子轮播区（横向分页 CollectionView + PageControl 点）
    private func setupHotPostsSection_Sylva() {
        let titleLabel_sylva = makeSectionTitle_Sylva("Trending Stories", icon: "flame.fill")
        contentView_Sylva.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(knowledgeScrollView_Sylva.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 横向分页 CollectionView
        let layout_sylva = UICollectionViewFlowLayout()
        layout_sylva.scrollDirection = .horizontal
        layout_sylva.minimumLineSpacing = 0
        let cardW_sylva = APPSCREEN_Sylva.WIDTH_Sylva - 32
        layout_sylva.itemSize = CGSize(width: cardW_sylva, height: 110)

        hotPostsCarousel_Sylva = UICollectionView(frame: .zero, collectionViewLayout: layout_sylva)
        hotPostsCarousel_Sylva.backgroundColor = .clear
        hotPostsCarousel_Sylva.isPagingEnabled = true
        hotPostsCarousel_Sylva.showsHorizontalScrollIndicator = false
        hotPostsCarousel_Sylva.dataSource = self
        hotPostsCarousel_Sylva.delegate   = self
        hotPostsCarousel_Sylva.register(
            HotPostCarouselCell_Sylva.self,
            forCellWithReuseIdentifier: HotPostCarouselCell_Sylva.reuseId_Sylva
        )
        contentView_Sylva.addSubview(hotPostsCarousel_Sylva)
        hotPostsCarousel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_sylva.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(110)
        }

        // 分页点
        hotPageControl_Sylva.currentPageIndicatorTintColor = UIColor(hexstring_Sylva: "#40916C")
        hotPageControl_Sylva.pageIndicatorTintColor        = UIColor(hexstring_Sylva: "#B7E4C7")
        hotPageControl_Sylva.hidesForSinglePage = true
        contentView_Sylva.addSubview(hotPageControl_Sylva)
        hotPageControl_Sylva.snp.makeConstraints { make in
            make.top.equalTo(hotPostsCarousel_Sylva.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 辅助构建方法

    /// 构建区块标题行（图标 + 标题）
    private func makeSectionTitle_Sylva(_ title: String, icon: String) -> UIView {
        let container_sylva = UIView()
        let cfg_sylva = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let iconView_sylva = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg_sylva))
        iconView_sylva.tintColor = UIColor(hexstring_Sylva: "#40916C")
        iconView_sylva.contentMode = .scaleAspectFit
        let label_sylva = UILabel()
        label_sylva.text = title
        label_sylva.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")

        container_sylva.addSubview(iconView_sylva)
        container_sylva.addSubview(label_sylva)
        iconView_sylva.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(18)
        }
        label_sylva.snp.makeConstraints { make in
            make.leading.equalTo(iconView_sylva.snp.trailing).offset(7)
            make.centerY.equalTo(iconView_sylva)
            make.trailing.equalToSuperview()
        }
        return container_sylva
    }

    /// 构建任务卡片
    private func makeTaskCard_Sylva(task_sylva: EcoTask_Sylva) -> UIView {
        let card_sylva = UIView()
        card_sylva.backgroundColor = task_sylva.isCompleted_Sylva
            ? UIColor(hexstring_Sylva: "#D8F3DC")
            : .white
        card_sylva.layer.cornerRadius = 16
        card_sylva.layer.shadowColor   = UIColor.black.cgColor
        card_sylva.layer.shadowOpacity = 0.05
        card_sylva.layer.shadowRadius  = 8
        card_sylva.layer.shadowOffset  = CGSize(width: 0, height: 2)

        // 难度徽章
        let diffColors_sylva: [UIColor] = [
            UIColor(hexstring_Sylva: "#52B788"),
            UIColor(hexstring_Sylva: "#F59E0B"),
            UIColor(hexstring_Sylva: "#EF4444")
        ]
        let diffLabels_sylva = ["Easy", "Medium", "Hard"]
        let diffIdx_sylva = task_sylva.difficulty_Sylva.rawValue - 1
        let badge_sylva = UIView()
        badge_sylva.backgroundColor = diffColors_sylva[diffIdx_sylva].withAlphaComponent(0.15)
        badge_sylva.layer.cornerRadius = 8
        card_sylva.addSubview(badge_sylva)

        let badgeLbl_sylva = UILabel()
        badgeLbl_sylva.text = diffLabels_sylva[diffIdx_sylva]
        badgeLbl_sylva.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        badgeLbl_sylva.textColor = diffColors_sylva[diffIdx_sylva]
        badge_sylva.addSubview(badgeLbl_sylva)

        // 图标
        let iconCfg_sylva = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let iconView_sylva = UIImageView(image: UIImage(systemName: task_sylva.iconName_Sylva, withConfiguration: iconCfg_sylva))
        iconView_sylva.tintColor = task_sylva.isCompleted_Sylva
            ? UIColor(hexstring_Sylva: "#40916C")
            : ColorConfig_Sylva.textSecondary_Sylva
        iconView_sylva.contentMode = .scaleAspectFit
        card_sylva.addSubview(iconView_sylva)

        // 标题
        let titleLbl_sylva = UILabel()
        titleLbl_sylva.text = task_sylva.taskTitle_Sylva
        titleLbl_sylva.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLbl_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        card_sylva.addSubview(titleLbl_sylva)

        // 进度条背景
        let progressBg_sylva = UIView()
        progressBg_sylva.backgroundColor = UIColor(hexstring_Sylva: "#E2E8F0")
        progressBg_sylva.layer.cornerRadius = 3
        card_sylva.addSubview(progressBg_sylva)

        // 进度条填充
        let progressFill_sylva = UIView()
        progressFill_sylva.backgroundColor = task_sylva.isCompleted_Sylva
            ? UIColor(hexstring_Sylva: "#40916C")
            : UIColor(hexstring_Sylva: "#74C69D")
        progressFill_sylva.layer.cornerRadius = 3
        progressBg_sylva.addSubview(progressFill_sylva)

        // 进度文字
        let progressLbl_sylva = UILabel()
        progressLbl_sylva.text = "\(task_sylva.currentCount_Sylva)/\(task_sylva.requiredCount_Sylva)"
        progressLbl_sylva.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        progressLbl_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        card_sylva.addSubview(progressLbl_sylva)

        // 奖励分值
        let pointsLbl_sylva = UILabel()
        let bonus_sylva = UserViewModel_Sylva.shared_Sylva.getCheckInRecord_Sylva().bonusMultiplier_Sylva
        let earned_sylva = Int(Double(task_sylva.ecoPoints_Sylva) * bonus_sylva)
        pointsLbl_sylva.text = "+\(earned_sylva) pts"
        pointsLbl_sylva.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        pointsLbl_sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        card_sylva.addSubview(pointsLbl_sylva)

        // 完成勾
        if task_sylva.isCompleted_Sylva {
            let checkIcon_sylva = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            checkIcon_sylva.tintColor = UIColor(hexstring_Sylva: "#40916C")
            checkIcon_sylva.contentMode = .scaleAspectFit
            card_sylva.addSubview(checkIcon_sylva)
            checkIcon_sylva.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-10)
                make.top.equalToSuperview().offset(10)
                make.width.height.equalTo(18)
            }
        }

        // 统一约束
        badge_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(18)
        }
        badgeLbl_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        iconView_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(28)
        }
        titleLbl_sylva.snp.makeConstraints { make in
            make.top.equalTo(iconView_sylva.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-10)
        }
        progressBg_sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_sylva.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(5)
        }
        progressFill_sylva.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(task_sylva.progress_Sylva)
        }
        progressLbl_sylva.snp.makeConstraints { make in
            make.top.equalTo(progressBg_sylva.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-10)
        }
        pointsLbl_sylva.snp.makeConstraints { make in
            make.centerY.equalTo(progressLbl_sylva)
            make.trailing.equalToSuperview().offset(-14)
        }

        return card_sylva
    }

    /// 构建知识卡片
    private func makeKnowledgeCard_Sylva(icon_sylva: String, title_sylva: String, content_sylva: String, color_sylva: UIColor) -> UIView {
        let card_sylva = UIView()
        card_sylva.backgroundColor = color_sylva
        card_sylva.layer.cornerRadius = 18
        card_sylva.isUserInteractionEnabled = true

        let cfg_sylva = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        let iconView_sylva = UIImageView(image: UIImage(systemName: icon_sylva, withConfiguration: cfg_sylva))
        iconView_sylva.tintColor = UIColor.white.withAlphaComponent(0.85)
        iconView_sylva.contentMode = .scaleAspectFit
        card_sylva.addSubview(iconView_sylva)

        let titleLbl_sylva = UILabel()
        titleLbl_sylva.text = title_sylva
        titleLbl_sylva.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLbl_sylva.textColor = .white
        card_sylva.addSubview(titleLbl_sylva)

        let contentLbl_sylva = UILabel()
        contentLbl_sylva.text = content_sylva
        contentLbl_sylva.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        contentLbl_sylva.textColor = UIColor.white.withAlphaComponent(0.85)
        contentLbl_sylva.numberOfLines = 4
        card_sylva.addSubview(contentLbl_sylva)

        iconView_sylva.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(32)
        }
        titleLbl_sylva.snp.makeConstraints { make in
            make.top.equalTo(iconView_sylva.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
        contentLbl_sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_sylva.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }

        return card_sylva
    }

    /// 构建热门帖子行
    private func makeHotPostRow_Sylva(post_sylva: TitleModel_Sylva, rank_sylva: Int) -> UIView {
        let card_sylva = UIView()
        card_sylva.backgroundColor = .white
        card_sylva.layer.cornerRadius = 16
        card_sylva.layer.shadowColor   = UIColor.black.cgColor
        card_sylva.layer.shadowOpacity = 0.05
        card_sylva.layer.shadowRadius  = 8
        card_sylva.layer.shadowOffset  = CGSize(width: 0, height: 2)
        card_sylva.isUserInteractionEnabled = true

        // 排名徽章
        let rankColors_sylva = [
            UIColor(hexstring_Sylva: "#F59E0B"),
            UIColor(hexstring_Sylva: "#94A3B8"),
            UIColor(hexstring_Sylva: "#B45309")
        ]
        let rankBadge_sylva = UIView()
        rankBadge_sylva.backgroundColor = (rank_sylva <= 3 ? rankColors_sylva[rank_sylva - 1] : UIColor(hexstring_Sylva: "#40916C"))
            .withAlphaComponent(0.15)
        rankBadge_sylva.layer.cornerRadius = 14
        card_sylva.addSubview(rankBadge_sylva)

        let rankLbl_sylva = UILabel()
        rankLbl_sylva.text = "#\(rank_sylva)"
        rankLbl_sylva.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        rankLbl_sylva.textColor = rank_sylva <= 3
            ? rankColors_sylva[rank_sylva - 1]
            : UIColor(hexstring_Sylva: "#40916C")
        rankLbl_sylva.textAlignment = .center
        rankBadge_sylva.addSubview(rankLbl_sylva)

        // 媒体缩略图
        let mediaView_sylva = MediaDisplayView_Sylva()
        mediaView_sylva.layer.cornerRadius = 10
        mediaView_sylva.clipsToBounds = true
        card_sylva.addSubview(mediaView_sylva)
        if let media_sylva = post_sylva.titleMeidas_Sylva.first {
            mediaView_sylva.configure_Sylva(mediaPath_Sylva: media_sylva)
        }

        // 标题
        let titleLbl_sylva = UILabel()
        titleLbl_sylva.text = post_sylva.title_Sylva
        titleLbl_sylva.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLbl_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        titleLbl_sylva.numberOfLines = 1
        card_sylva.addSubview(titleLbl_sylva)

        // 作者 + 点赞数
        let authorLbl_sylva = UILabel()
        authorLbl_sylva.text = post_sylva.titleUserName_Sylva
        authorLbl_sylva.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        authorLbl_sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        card_sylva.addSubview(authorLbl_sylva)

        let heartIcon_sylva = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartIcon_sylva.tintColor = UIColor(hexstring_Sylva: "#52B788")
        heartIcon_sylva.contentMode = .scaleAspectFit
        card_sylva.addSubview(heartIcon_sylva)

        let likesLbl_sylva = UILabel()
        likesLbl_sylva.text = "\(post_sylva.likes_Sylva)"
        likesLbl_sylva.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        likesLbl_sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        card_sylva.addSubview(likesLbl_sylva)

        // 约束
        rankBadge_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        rankLbl_sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_sylva.snp.makeConstraints { make in
            make.leading.equalTo(rankBadge_sylva.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
        titleLbl_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(mediaView_sylva.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
        }
        authorLbl_sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_sylva.snp.bottom).offset(4)
            make.leading.equalTo(titleLbl_sylva)
            make.bottom.equalToSuperview().offset(-14)
        }
        likesLbl_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(authorLbl_sylva)
        }
        heartIcon_sylva.snp.makeConstraints { make in
            make.trailing.equalTo(likesLbl_sylva.snp.leading).offset(-4)
            make.centerY.equalTo(likesLbl_sylva)
            make.width.height.equalTo(13)
        }

        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(hotPostTapped_Sylva(_:)))
        card_sylva.addGestureRecognizer(tap_sylva)
        // 绑定帖子数据
        objc_setAssociatedObject(card_sylva, &HomeAssocKeys_Sylva.postKey, post_sylva, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return card_sylva
    }

    // MARK: - 数据刷新

    private func refreshAll_Sylva() {
        refreshEcoPoints_Sylva()
        refreshCheckIn_Sylva()
        refreshTasks_Sylva()
        refreshHotPosts_Sylva()
    }

    private func refreshEcoPoints_Sylva() {
        let pts_sylva = UserViewModel_Sylva.shared_Sylva.getTotalEcoPoints_Sylva()
        ecoPointsLabel_Sylva.text = "\(pts_sylva) pts"
    }

    private func refreshCheckIn_Sylva() {
        let record_sylva = UserViewModel_Sylva.shared_Sylva.getCheckInRecord_Sylva()

        // 更新倍率标签
        if let lbl_sylva = contentView_Sylva.viewWithTag(500) as? UILabel {
            lbl_sylva.text = record_sylva.multiplierText_Sylva
        }

        // 更新打卡按钮状态
        let canCheckIn_sylva = !record_sylva.hasCheckedInToday_Sylva
        checkInButton_Sylva.setTitle(canCheckIn_sylva ? "Check In Today (+5 pts)" : "Checked In ✓", for: .normal)
        checkInButton_Sylva.setTitleColor(canCheckIn_sylva ? .white : UIColor(hexstring_Sylva: "#40916C"), for: .normal)
        checkInButton_Sylva.backgroundColor = canCheckIn_sylva
            ? UIColor(hexstring_Sylva: "#40916C")
            : UIColor(hexstring_Sylva: "#D8F3DC")
        checkInButton_Sylva.isEnabled = canCheckIn_sylva

        // 更新连续打卡进度点：每个圆点固定 14×14，SnapKit 链式横向排列，不溢出也不变形
        streakContainer_Sylva.subviews.forEach { $0.removeFromSuperview() }
        let days_sylva    = min(record_sylva.consecutiveDays_Sylva, 14)
        let dotSize_sylva: CGFloat = 14   // 每个点直径
        let dotGap_sylva:  CGFloat = 3    // 点间距
        // 14×14 + 13×3 = 196+39 = 235pt，远小于容器宽（≈326pt）

        // streak 文字标签（先加入，trailing 锚点）
        let streakLbl_sylva = UILabel()
        streakLbl_sylva.text = "\(record_sylva.consecutiveDays_Sylva) day streak"
        streakLbl_sylva.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        streakLbl_sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        streakContainer_Sylva.addSubview(streakLbl_sylva)
        streakLbl_sylva.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }

        // 依次添加 14 个圆点，每个固定大小，用 SnapKit 链式横向排列
        var prevDot_sylva: UIView? = nil
        for i_sylva in 0..<14 {
            let dot_sylva = UIView()
            let filled_sylva   = i_sylva < days_sylva
            let isMile7_sylva  = (i_sylva == 6)
            let isMile14_sylva = (i_sylva == 13)

            dot_sylva.layer.cornerRadius = dotSize_sylva / 2
            dot_sylva.backgroundColor = filled_sylva
                ? UIColor(hexstring_Sylva: "#40916C")
                : UIColor(hexstring_Sylva: "#CBD5E0")  // 未打卡用较深的灰，白底可见

            if isMile7_sylva || isMile14_sylva {
                dot_sylva.layer.borderWidth = 1.5
                dot_sylva.layer.borderColor = UIColor(hexstring_Sylva: "#F59E0B").cgColor
                let mileLbl_sylva = UILabel()
                mileLbl_sylva.text = isMile7_sylva ? "7" : "14"
                mileLbl_sylva.font = UIFont.systemFont(ofSize: 6, weight: .heavy)
                mileLbl_sylva.textColor = filled_sylva ? .white : UIColor(hexstring_Sylva: "#F59E0B")
                mileLbl_sylva.textAlignment = .center
                dot_sylva.addSubview(mileLbl_sylva)
                mileLbl_sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
            }

            streakContainer_Sylva.addSubview(dot_sylva)
            dot_sylva.snp.makeConstraints { make in
                make.width.height.equalTo(dotSize_sylva)
                make.centerY.equalToSuperview()
                if let prev_sylva = prevDot_sylva {
                    make.leading.equalTo(prev_sylva.snp.trailing).offset(dotGap_sylva)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            prevDot_sylva = dot_sylva
        }
    }

    private func refreshTasks_Sylva() {
        tasksStack_Sylva.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let tasks_sylva = UserViewModel_Sylva.shared_Sylva.getEcoTasks_Sylva()
        for task_sylva in tasks_sylva {
            let card_sylva = makeTaskCard_Sylva(task_sylva: task_sylva)
            tasksStack_Sylva.addArrangedSubview(card_sylva)
            card_sylva.snp.makeConstraints { make in make.width.equalTo(160) }
        }
        let trail_sylva = UIView()
        trail_sylva.snp.makeConstraints { make in make.width.equalTo(4) }
        tasksStack_Sylva.addArrangedSubview(trail_sylva)
    }

    private func refreshHotPosts_Sylva() {
        hotPosts_Sylva = Array(
            TitleViewModel_Sylva.shared_Sylva.getPosts_Sylva()
                .sorted { $0.likes_Sylva > $1.likes_Sylva }
                .prefix(5)
        )
        hotPageControl_Sylva.numberOfPages = hotPosts_Sylva.count
        hotPageControl_Sylva.currentPage   = 0
        hotPostsCarousel_Sylva?.reloadData()
    }

    // MARK: - 通知

    private func observeNotifications_Sylva() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserStateChanged_Sylva),
            name: UserViewModel_Sylva.userStateDidChangeNotification_Sylva, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleStateChanged_Sylva),
            name: TitleViewModel_Sylva.titleStateDidChangeNotification_Sylva, object: nil
        )
    }

    @objc private func onUserStateChanged_Sylva()  { refreshAll_Sylva() }
    @objc private func onTitleStateChanged_Sylva()  { refreshHotPosts_Sylva() }

    // MARK: - 事件

    @objc private func checkInTapped_Sylva() {
        guard UserViewModel_Sylva.shared_Sylva.isLoggedIn_Sylva else {
            Navigation_Sylva.toLogin_Sylva()
            return
        }
        let success_sylva = UserViewModel_Sylva.shared_Sylva.checkIn_Sylva()
        if success_sylva {
            checkInButton_Sylva.animatePulse_Sylva()
            Utils_Sylva.showSuccess_Sylva(
                message_Sylva: "Checked in! +5 pts earned",
                image_Sylva: UIImage(systemName: "leaf.circle.fill")
            )
        }
    }

    @objc private func knowledgeTapped_Sylva(_ gesture: UITapGestureRecognizer) {
        guard let card_sylva = gesture.view else { return }
        let idx_sylva = card_sylva.tag - 600
        guard idx_sylva >= 0 && idx_sylva < knowledgeData_Sylva.count else { return }
        let data_sylva = knowledgeData_Sylva[idx_sylva]
        card_sylva.animatePulse_Sylva()
        let alert_sylva = UIAlertController(
            title: data_sylva.1,
            message: data_sylva.2,
            preferredStyle: .alert
        )
        alert_sylva.addAction(UIAlertAction(title: "Got it!", style: .default))
        present(alert_sylva, animated: true)
    }

    @objc private func hotPostTapped_Sylva(_ gesture: UITapGestureRecognizer) {
        guard let card_sylva = gesture.view,
              let post_sylva = objc_getAssociatedObject(card_sylva, &HomeAssocKeys_Sylva.postKey) as? TitleModel_Sylva
        else { return }
        card_sylva.animatePressDown_Sylva { card_sylva.animatePressUp_Sylva() }
        Navigation_Sylva.toTitleDetail_Sylva(titleModel_sylva: post_sylva)
    }
}

// MARK: - 热门帖子轮播 DataSource & Delegate

extension Home_Sylva: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotPosts_Sylva.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_sylva = collectionView.dequeueReusableCell(
            withReuseIdentifier: HotPostCarouselCell_Sylva.reuseId_Sylva,
            for: indexPath
        ) as? HotPostCarouselCell_Sylva else { return UICollectionViewCell() }
        cell_sylva.configure_Sylva(post_sylva: hotPosts_Sylva[indexPath.item], rank_sylva: indexPath.item + 1)
        return cell_sylva
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Sylva.toTitleDetail_Sylva(titleModel_sylva: hotPosts_Sylva[indexPath.item])
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === hotPostsCarousel_Sylva else { return }
        let page_sylva = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        hotPageControl_Sylva.currentPage = page_sylva
    }
}

// MARK: - 热门帖子轮播 Cell

/// 热门帖子轮播单元格
/// 功能：展示排名徽章、媒体缩略图、标题、作者、点赞数
class HotPostCarouselCell_Sylva: UICollectionViewCell {

    static let reuseId_Sylva = "HotPostCarouselCell_Sylva"

    private let rankBadge_Sylva  = UIView()
    private let rankLabel_Sylva  = UILabel()
    private let mediaView_Sylva  = MediaDisplayView_Sylva()
    private let titleLabel_Sylva = UILabel()
    private let authorLabel_Sylva = UILabel()
    private let heartIcon_Sylva  = UIImageView()
    private let likesLabel_Sylva = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sylva()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Sylva() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 18
        contentView.layer.shadowColor   = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowRadius  = 10
        contentView.layer.shadowOffset  = CGSize(width: 0, height: 3)
        contentView.clipsToBounds = false

        rankBadge_Sylva.layer.cornerRadius = 14
        contentView.addSubview(rankBadge_Sylva)

        rankLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
        rankLabel_Sylva.textAlignment = .center
        rankBadge_Sylva.addSubview(rankLabel_Sylva)

        mediaView_Sylva.layer.cornerRadius = 10
        mediaView_Sylva.clipsToBounds = true
        contentView.addSubview(mediaView_Sylva)

        titleLabel_Sylva.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        titleLabel_Sylva.numberOfLines = 1
        contentView.addSubview(titleLabel_Sylva)

        authorLabel_Sylva.font = UIFont.systemFont(ofSize: 12)
        authorLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        contentView.addSubview(authorLabel_Sylva)

        heartIcon_Sylva.image = UIImage(systemName: "heart.fill")
        heartIcon_Sylva.tintColor = UIColor(hexstring_Sylva: "#52B788")
        heartIcon_Sylva.contentMode = .scaleAspectFit
        contentView.addSubview(heartIcon_Sylva)

        likesLabel_Sylva.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        likesLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        contentView.addSubview(likesLabel_Sylva)

        // 约束
        rankBadge_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        rankLabel_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(rankBadge_Sylva.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(68)
        }
        titleLabel_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(mediaView_Sylva.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        authorLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Sylva.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel_Sylva)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }
        likesLabel_Sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(authorLabel_Sylva)
        }
        heartIcon_Sylva.snp.makeConstraints { make in
            make.trailing.equalTo(likesLabel_Sylva.snp.leading).offset(-4)
            make.centerY.equalTo(likesLabel_Sylva)
            make.width.height.equalTo(13)
        }
    }

    /// 配置轮播 Cell 内容及排名样式
    func configure_Sylva(post_sylva: TitleModel_Sylva, rank_sylva: Int) {
        if let media_sylva = post_sylva.titleMeidas_Sylva.first {
            mediaView_Sylva.configure_Sylva(mediaPath_Sylva: media_sylva)
        }
        titleLabel_Sylva.text  = post_sylva.title_Sylva
        authorLabel_Sylva.text = post_sylva.titleUserName_Sylva
        likesLabel_Sylva.text  = "\(post_sylva.likes_Sylva)"
        rankLabel_Sylva.text   = "#\(rank_sylva)"

        let rankColors_sylva = [
            UIColor(hexstring_Sylva: "#F59E0B"),
            UIColor(hexstring_Sylva: "#94A3B8"),
            UIColor(hexstring_Sylva: "#B45309")
        ]
        let color_sylva = rank_sylva <= 3
            ? rankColors_sylva[rank_sylva - 1]
            : UIColor(hexstring_Sylva: "#40916C")
        rankBadge_Sylva.backgroundColor = color_sylva.withAlphaComponent(0.15)
        rankLabel_Sylva.textColor = color_sylva
    }
}

// MARK: - 关联对象 Key

private enum HomeAssocKeys_Sylva {
    static var postKey = "homePostKey_Sylva"
}
