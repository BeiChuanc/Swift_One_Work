import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页控制器
/// 核心作用：以非规则瀑布流展示社区帖子，支持查看详情、点赞、举报或删除。
/// 设计思路：页面通过自定义 `DiscoverWaterfallLayout_Posture` 计算瀑布流布局，帖子状态来自 `TitleViewModel_Posture`。
/// 关键属性：`collectionView_Posture` 展示帖子流，`posts_Posture` 保存当前数据，`layout_Posture` 控制瀑布流排版。
/// 关键方法：`reloadPosts_Posture()` 刷新数据，`collectionView(_:cellForItemAt:)` 绑定卡片内容。
@MainActor
class Discover_Posture: UIViewController {

    /// 瀑布流布局
    private let layout_Posture = DiscoverWaterfallLayout_Posture()

    /// 发现页集合视图
    private lazy var collectionView_Posture: UICollectionView = {
        let collectionView_Posture = UICollectionView(frame: .zero, collectionViewLayout: layout_Posture)
        collectionView_Posture.backgroundColor = .clear
        collectionView_Posture.showsVerticalScrollIndicator = false
        collectionView_Posture.showsHorizontalScrollIndicator = false
        collectionView_Posture.alwaysBounceHorizontal = false
        collectionView_Posture.isDirectionalLockEnabled = true
        collectionView_Posture.contentInsetAdjustmentBehavior = .never
        collectionView_Posture.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        collectionView_Posture.dataSource = self
        collectionView_Posture.delegate = self
        collectionView_Posture.register(DiscoverPostCell_Posture.self, forCellWithReuseIdentifier: DiscoverPostCell_Posture.reuseIdentifier_Posture)
        return collectionView_Posture
    }()

    /// 顶部柔光装饰
    private let topGlowView_Posture = UIView()

    /// 侧边柔光装饰
    private let sideGlowView_Posture = UIView()

    /// 顶部标题容器
    private let headerView_Posture = UIView()

    /// 每日教学视频推荐区块（插在 headerView 与瀑布流之间）
    private let dailyVideoSection_Posture = UIView()

    /// 瀑布流高度约束（KVO 动态更新，实现外层 ScrollView 统一滚动）
    private var collectionViewHeightConstraint_Posture: Constraint?

    /// contentSize KVO 观察者令牌
    private var collectionViewSizeObserver_Posture: NSKeyValueObservation?

    /// 当前发现页帖子数据（全量）
    private var posts_Posture: [TitleModel_Posture] = []

    /// 当前搜索关键词
    private var searchQuery_Posture: String = ""

    /// 搜索框（固定在顶部 headerView 内）
    private let searchField_Posture = UITextField()

    /// 按关键词过滤后的帖子列表；无关键词时返回全量
    private var filteredPosts_Posture: [TitleModel_Posture] {
        let trimmed_Posture = searchQuery_Posture.trimmingCharacters(in: .whitespaces)
        guard !trimmed_Posture.isEmpty else { return posts_Posture }
        let query_Posture = trimmed_Posture.lowercased()
        return posts_Posture.filter {
            $0.title_Posture.lowercased().contains(query_Posture) ||
            $0.titleContent_Posture.lowercased().contains(query_Posture) ||
            (($0.titleUserName_Posture ?? "").lowercased().contains(query_Posture))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPosts_Posture()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        observePostState_Posture()
        reloadPosts_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        collectionViewSizeObserver_Posture?.invalidate()
    }

    // MARK: - UI设置

    /// 搭建发现页 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        layout_Posture.delegate_Posture = self

        setupBackgroundDecorations_Posture()

        // 外层主滚动容器，承载所有内容（标题区、视频区块、搜索栏、帖子流）实现统一滚动
        let mainScroll_Posture = UIScrollView()
        mainScroll_Posture.showsVerticalScrollIndicator = false
        // .automatic 让 scrollView 自动处理安全区域 inset，无需在子视图中引用 view.safeAreaLayoutGuide
        mainScroll_Posture.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(mainScroll_Posture)
        mainScroll_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let scrollContent_Posture = UIView()
        mainScroll_Posture.addSubview(scrollContent_Posture)
        scrollContent_Posture.snp.makeConstraints { make in
            make.edges.equalTo(mainScroll_Posture.contentLayoutGuide)
            make.width.equalTo(mainScroll_Posture.frameLayoutGuide)
            // 高度由子视图约束链自动确定（不手动设置），scrollView 可滚动区域随内容撑开
        }

        // 所有子视图放入 scrollContent，实现统一滚动
        scrollContent_Posture.addSubview(headerView_Posture)
        setupHeaderView_Posture()

        let videoContent_Posture = buildDailyVideoSection_Posture()
        dailyVideoSection_Posture.addSubview(videoContent_Posture)
        videoContent_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        scrollContent_Posture.addSubview(dailyVideoSection_Posture)

        let searchBarView_Posture = buildSearchBar_Posture()
        scrollContent_Posture.addSubview(searchBarView_Posture)

        // collectionView 禁用独立滚动，由外层 UIScrollView 统一接管
        collectionView_Posture.isScrollEnabled = false
        collectionView_Posture.contentInset = .zero
        scrollContent_Posture.addSubview(collectionView_Posture)

        // 底部占位视图：唯一持有 make.bottom.equalToSuperview() 的视图，明确定义 scrollContent 的底部边界
        let bottomSpacer_Posture = UIView()
        scrollContent_Posture.addSubview(bottomSpacer_Posture)

        // 约束链（全部相对 scrollContent，避免跨层级约束）：
        //   scrollContent.top → headerView → videoSection → searchBar → collectionView → bottomSpacer → scrollContent.bottom
        headerView_Posture.snp.makeConstraints { make in
            // 相对 scrollContent 顶部偏移 12；安全区由 contentInsetAdjustmentBehavior 自动添加
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        dailyVideoSection_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerView_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        searchBarView_Posture.snp.makeConstraints { make in
            make.top.equalTo(dailyVideoSection_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(46)
        }
        collectionView_Posture.snp.makeConstraints { make in
            make.top.equalTo(searchBarView_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            // 只设 height（KVO 动态更新），不设 bottom，避免与 height 冲突
            collectionViewHeightConstraint_Posture = make.height.equalTo(2000).constraint
        }
        // bottomSpacer 是底部边界的唯一定义者
        bottomSpacer_Posture.snp.makeConstraints { make in
            make.top.equalTo(collectionView_Posture.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
            make.bottom.equalToSuperview()   // ← 此约束确定 scrollContent 高度，使 scrollView 可滚动
        }

        // KVO 监听瀑布流 contentSize 变化，同步更新 collectionView 高度约束
        collectionViewSizeObserver_Posture = collectionView_Posture.observe(
            \.contentSize, options: [.new, .initial]
        ) { [weak self] cv, _ in
            DispatchQueue.main.async {
                guard cv.contentSize.height > 0 else { return }
                self?.collectionViewHeightConstraint_Posture?.update(offset: cv.contentSize.height)
            }
        }
    }

    /// 搭建发现页背景装饰
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupBackgroundDecorations_Posture() {
        // 使用调色盘中前几个颜色分布多个光晕，制造丰富的背景层次
        let glowConfigs_Posture: [(UIColor, CGFloat, CGFloat, CGFloat, Bool)] = [
            (ColorConfig_Posture.glowPalette_Posture[0], -60, -40, 200, false),   // 左上 靛蓝
            (ColorConfig_Posture.glowPalette_Posture[1],  52, 160, 160, true),    // 右中 青蓝
            (ColorConfig_Posture.glowPalette_Posture[2], -40, 340, 140, false),   // 左下 玫瑰
            (ColorConfig_Posture.glowPalette_Posture[3],  44, 480, 120, true),    // 右下 琥珀
        ]

        glowConfigs_Posture.forEach { config_Posture in
            let blob_Posture = UIView()
            blob_Posture.backgroundColor = config_Posture.0
            blob_Posture.layer.cornerRadius = config_Posture.4 ? config_Posture.2 / 2 : config_Posture.4 == false ? config_Posture.2 / 2 : 0
            blob_Posture.layer.cornerRadius = config_Posture.2 / 2
            blob_Posture.isUserInteractionEnabled = false
            view.insertSubview(blob_Posture, at: 0)
            blob_Posture.snp.makeConstraints { make in
                if config_Posture.4 {
                    make.trailing.equalToSuperview().offset(config_Posture.1)
                } else {
                    make.leading.equalToSuperview().offset(config_Posture.1)
                }
                make.top.equalToSuperview().offset(config_Posture.3)
                make.width.height.equalTo(config_Posture.2)
            }
        }
    }

    /// 搭建顶部标题区（标题 → 副标题 → 主题胶囊，搜索栏已移至视频区块下方）
    private func setupHeaderView_Posture() {
        headerView_Posture.backgroundColor = .clear

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Discover"
        titleLabel_Posture.font = .systemFont(ofSize: 34, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        let subTitleLabel_Posture = UILabel()
        subTitleLabel_Posture.text = "Alignment"
        subTitleLabel_Posture.font = .systemFont(ofSize: 34, weight: .heavy)
        subTitleLabel_Posture.textColor = ColorConfig_Posture.primaryGradientStart_Posture

        let titleStack_Posture = UIStackView(arrangedSubviews: [titleLabel_Posture, subTitleLabel_Posture])
        titleStack_Posture.axis = .horizontal
        titleStack_Posture.spacing = 8
        titleStack_Posture.alignment = .firstBaseline

        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "Posture wins and tiny habits from real people."
        subtitleLabel_Posture.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        subtitleLabel_Posture.numberOfLines = 2

        let chipStack_Posture = UIStackView()
        chipStack_Posture.axis = .horizontal
        chipStack_Posture.spacing = 8
        chipStack_Posture.distribution = .fillProportionally
        [
            ("Desk Reset",  "chair",                0),
            ("Neck Ease",   "figure.cooldown",      1),
            ("Core Flow",   "figure.core.training", 2)
        ].forEach { chip_Posture in
            chipStack_Posture.addArrangedSubview(
                makeHeaderChip_Posture(title_Posture: chip_Posture.0, icon_Posture: chip_Posture.1, colorIndex_Posture: chip_Posture.2)
            )
        }

        headerView_Posture.addSubview(titleStack_Posture)
        headerView_Posture.addSubview(subtitleLabel_Posture)
        headerView_Posture.addSubview(chipStack_Posture)

        titleStack_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleStack_Posture.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
        // chipStack 作为 headerView 底部锚点
        chipStack_Posture.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(12)
            make.height.equalTo(36)
        }
    }

    /// 构建独立搜索栏视图（插在视频推荐区块下方）
    /// - Parameters: 无
    /// - Returns: UIView - 搜索栏容器
    /// - Throws: 无
    private func buildSearchBar_Posture() -> UIView {
        let container_Posture = UIView()
        container_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        container_Posture.layer.cornerRadius = 22
        container_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        container_Posture.layer.shadowOpacity = 1
        container_Posture.layer.shadowRadius = 10
        container_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)

        let searchIcon_Posture = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        searchIcon_Posture.contentMode = .scaleAspectFit

        searchField_Posture.placeholder = "Search posture stories..."
        searchField_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        searchField_Posture.borderStyle = .none
        searchField_Posture.clearButtonMode = .whileEditing
        searchField_Posture.returnKeyType = .search
        searchField_Posture.delegate = self
        searchField_Posture.addTarget(self, action: #selector(searchTextChanged_Posture), for: .editingChanged)

        container_Posture.addSubview(searchIcon_Posture)
        container_Posture.addSubview(searchField_Posture)

        searchIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        searchField_Posture.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        return container_Posture
    }

    /// 创建主题胶囊（带轻描边、浅色背景）
    /// - Parameters:
    ///   - title_Posture: 胶囊标题
    ///   - icon_Posture: SF Symbol 图标名
    ///   - colorIndex_Posture: 调色盘索引
    /// - Returns: UIView
    private func makeHeaderChip_Posture(title_Posture: String, icon_Posture: String, colorIndex_Posture: Int = 0) -> UIView {
        let colors_Posture = ColorConfig_Posture.chipColors_Posture(at: colorIndex_Posture)
        let container_Posture = UIView()
        container_Posture.backgroundColor = colors_Posture.bg
        container_Posture.layer.cornerRadius = 18
        container_Posture.layer.borderWidth = 1
        container_Posture.layer.borderColor = colors_Posture.tint.withAlphaComponent(0.25).cgColor

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon_Posture))
        iconView_Posture.tintColor = colors_Posture.tint
        iconView_Posture.contentMode = .scaleAspectFit

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = title_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel_Posture.textColor = colors_Posture.tint

        container_Posture.addSubview(iconView_Posture)
        container_Posture.addSubview(titleLabel_Posture)

        iconView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Posture.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        return container_Posture
    }

    // MARK: - 每日视频推荐区块

    /// 构建每日教学视频推荐区块
    /// 设计：卡片背景 + 渐变标题栏 + 三个视频卡片横向均分（间距10）
    /// 视频数据：media_one / media_two / media_three（Bundle 资源）
    /// - Parameters: 无
    /// - Returns: UIView - 完整区块视图
    /// - Throws: 无
    private func buildDailyVideoSection_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 24
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 16
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 8)

        // 左侧渐变装饰条：cornerRadius 与卡片左侧圆角一致（24pt），使其融入边框
        let accentStripe_Posture = UIView()
        accentStripe_Posture.layer.cornerRadius = 24
        accentStripe_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        accentStripe_Posture.clipsToBounds = true

        let stripeGradient_Posture = CAGradientLayer()
        stripeGradient_Posture.colors = [
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.accentTeal_Posture.cgColor
        ]
        stripeGradient_Posture.startPoint = CGPoint(x: 0, y: 0)
        stripeGradient_Posture.endPoint   = CGPoint(x: 0, y: 1)
        accentStripe_Posture.layer.insertSublayer(stripeGradient_Posture, at: 0)

        // 图标容器
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.12)
        iconBg_Posture.layer.cornerRadius = 14

        let iconView_Posture = UIImageView(image: UIImage(systemName: "play.rectangle.fill"))
        iconView_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        iconView_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        // 标题（移除 See All 按钮，标题区更简洁）
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Today's Lessons"
        titleLabel_Posture.font = .systemFont(ofSize: 16, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 副标题
        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "3 daily micro-lessons · 19 min total"
        subtitleLabel_Posture.font = .systemFont(ofSize: 11, weight: .medium)
        subtitleLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        // 三个视频卡片（均分横向空间，间距10）
        let lessonData_Posture: [(String, String, String, String, Int)] = [
            ("media_one",   "Morning Alignment",  "5 min", "Beginner",     0),
            ("media_two",   "Desk Stretch Flow",  "8 min", "Intermediate", 1),
            ("media_three", "Core Activation",    "6 min", "All Levels",   2),
        ]

        let cardStack_Posture = UIStackView()
        cardStack_Posture.axis = .horizontal
        cardStack_Posture.spacing = 10
        cardStack_Posture.distribution = .fillEqually
        cardStack_Posture.alignment = .fill

        lessonData_Posture.forEach { data_Posture in
            let lessonCard_Posture = DailyLessonCard_Posture()
            lessonCard_Posture.configure_Posture(
                videoName_Posture:   data_Posture.0,
                title_Posture:       data_Posture.1,
                duration_Posture:    data_Posture.2,
                level_Posture:       data_Posture.3,
                colorIndex_Posture:  data_Posture.4
            )
            cardStack_Posture.addArrangedSubview(lessonCard_Posture)
        }

        card_Posture.addSubview(accentStripe_Posture)
        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(subtitleLabel_Posture)
        card_Posture.addSubview(cardStack_Posture)

        accentStripe_Posture.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }
        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(accentStripe_Posture.snp.trailing).offset(14)
            make.width.height.equalTo(30)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(iconBg_Posture)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(14)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(4)
            make.leading.equalTo(iconBg_Posture)
        }
        cardStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(12)
            make.leading.equalTo(accentStripe_Posture.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(14)
        }

        // 渐变条在布局完成后更新 frame
        DispatchQueue.main.async {
            stripeGradient_Posture.frame = accentStripe_Posture.bounds
        }

        return card_Posture
    }

    // MARK: - 数据刷新

    /// 监听帖子状态变化
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func observePostState_Posture() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostStateChange_Posture),
            name: TitleViewModel_Posture.titleStateDidChangeNotification_Posture,
            object: nil
        )
    }

    /// 响应帖子状态通知
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func handlePostStateChange_Posture() {
        reloadPosts_Posture()
    }

    /// 拉取帖子数据并刷新瀑布流
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func reloadPosts_Posture() {
        posts_Posture = TitleViewModel_Posture.shared_Posture.getPosts_Posture()
        layout_Posture.invalidateLayout()
        collectionView_Posture.reloadData()
    }

    /// 搜索框文字变化时实时过滤并刷新瀑布流
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func searchTextChanged_Posture() {
        searchQuery_Posture = searchField_Posture.text ?? ""
        layout_Posture.invalidateLayout()
        collectionView_Posture.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Posture: UICollectionViewDataSource {

    /// 返回帖子数量
    /// - Parameters:
    ///   - collectionView_posture: 集合视图
    ///   - section_posture: 分区索引
    /// - Returns: Int - 当前分区帖子数量
    /// - Throws: 无
    func collectionView(_ collectionView_posture: UICollectionView, numberOfItemsInSection section_posture: Int) -> Int {
        return filteredPosts_Posture.count
    }

    /// 创建并配置帖子卡片
    /// - Parameters:
    ///   - collectionView_posture: 集合视图
    ///   - indexPath_posture: 位置索引
    /// - Returns: UICollectionViewCell - 已配置的瀑布流卡片
    /// - Throws: 无
    func collectionView(_ collectionView_posture: UICollectionView, cellForItemAt indexPath_posture: IndexPath) -> UICollectionViewCell {
        guard let cell_Posture = collectionView_posture.dequeueReusableCell(withReuseIdentifier: DiscoverPostCell_Posture.reuseIdentifier_Posture, for: indexPath_posture) as? DiscoverPostCell_Posture else {
            return UICollectionViewCell()
        }

        let post_Posture = filteredPosts_Posture[indexPath_posture.item]
        cell_Posture.configure_Posture(post_posture: post_Posture, parentViewController_posture: self, index_posture: indexPath_posture.item)
        cell_Posture.onLike_Posture = { likedPost_posture in
            TitleViewModel_Posture.shared_Posture.likePost_Posture(post_posture: likedPost_posture)
        }
        return cell_Posture
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Posture: UICollectionViewDelegate {

    /// 处理帖子点击并进入详情
    /// - Parameters:
    ///   - collectionView_posture: 集合视图
    ///   - indexPath_posture: 被点击位置
    /// - Returns: Void
    /// - Throws: 无
    func collectionView(_ collectionView_posture: UICollectionView, didSelectItemAt indexPath_posture: IndexPath) {
        let post_Posture = filteredPosts_Posture[indexPath_posture.item]
        Navigation_Posture.toTitleDetail_Posture(titleModel_posture: post_Posture)
    }
}

// MARK: - 瀑布流高度代理

extension Discover_Posture: DiscoverWaterfallLayoutDelegate_Posture {

    /// 返回瀑布流卡片高度
    /// - Parameters:
    ///   - collectionView_posture: 集合视图
    ///   - indexPath_posture: 卡片索引
    ///   - itemWidth_posture: 卡片宽度
    /// - Returns: CGFloat - 当前卡片高度
    /// - Throws: 无
    func collectionView_Posture(_ collectionView_posture: UICollectionView, heightForItemAt indexPath_posture: IndexPath, itemWidth_posture: CGFloat) -> CGFloat {
        let post_Posture = filteredPosts_Posture[indexPath_posture.item]

        // 固定区块（严格对应约束链）：
        //   cardInset(10) + media(120) + mediaToAvatar(12) + avatar(28)
        //   + avatarToTitle(12) + titleToContent(8) + contentToStats(10) + stats(20) + statsBottom(12)
        // = 232pt
        let fixedBlock_Posture: CGFloat = 232

        // 标题行数估算（16pt bold，卡片约147pt内容宽，每行约16字符；最多2行）
        let titleLines_Posture = min(2, max(1, post_Posture.title_Posture.count / 16))
        let titleH_Posture = CGFloat(titleLines_Posture) * 21

        // 内容行数估算（13pt regular，每行约20字符；最多3行；内容为空则0行）
        let contentLines_Posture: Int
        if post_Posture.titleContent_Posture.isEmpty {
            contentLines_Posture = 0
        } else {
            contentLines_Posture = min(3, max(1, post_Posture.titleContent_Posture.count / 20))
        }
        let contentH_Posture = CGFloat(contentLines_Posture) * 18

        // +16 安全余量，防止字符估算不足时统计行被截断
        return fixedBlock_Posture + titleH_Posture + contentH_Posture + 16
    }
}

// MARK: - 发现页帖子卡片

/// 发现页帖子卡片
/// 核心作用：展示瀑布流中的单条帖子，包含媒体、作者、标题、内容、统计与操作按钮。
/// 设计思路：卡片只负责内容展示，点赞通过闭包回传给页面，举报/删除复用 `ReportDeleteHelper_Posture`。
/// 关键属性：`mediaView_Posture` 负责媒体展示，`avatarView_Posture` 负责作者头像，`likeButton_Posture` 负责点赞入口。
/// 关键方法：`configure_Posture(post_posture:parentViewController_posture:)` 绑定帖子数据。
@MainActor
private class DiscoverPostCell_Posture: UICollectionViewCell {

    /// 复用标识
    static let reuseIdentifier_Posture = "DiscoverPostCell_Posture"

    /// 卡片容器
    private let cardView_Posture = UIView()

    /// 媒体展示
    private let mediaView_Posture = MediaDisplayView_Posture()

    /// 作者头像
    private let avatarView_Posture = UserAvatarView_Posture()

    /// 作者名
    private let authorLabel_Posture = UILabel()

    /// 标题
    private let titleLabel_Posture = UILabel()

    /// 内容
    private let contentLabel_Posture = UILabel()

    /// 统计信息
    private let statLabel_Posture = UILabel()

    /// 主题标签
    private let tagLabel_Posture = UILabel()

    /// 卡片序号标签
    private let badgeLabel_Posture = UILabel()

    /// 点赞按钮
    private let likeButton_Posture = UIButton(type: .system)

    /// 顶部装饰色条（引用以便 configure 时更新颜色）
    private let topAccentView_Card_Posture = UIView()

    /// 举报或删除按钮
    private var reportButton_Posture: UIButton?

    /// 当前帖子
    private var post_Posture: TitleModel_Posture?

    /// 当前卡片在列表中的 index（用于调色盘取色）
    private var cardIndex_Posture: Int = 0

    /// 点赞回调
    var onLike_Posture: ((TitleModel_Posture) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reportButton_Posture?.removeFromSuperview()
        reportButton_Posture = nil
        onLike_Posture = nil
    }

    /// 搭建卡片 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        contentView.addSubview(cardView_Posture)
        cardView_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        cardView_Posture.layer.cornerRadius = 26
        cardView_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        cardView_Posture.layer.shadowOpacity = 1
        cardView_Posture.layer.shadowRadius = 16
        cardView_Posture.layer.shadowOffset = CGSize(width: 0, height: 10)

        topAccentView_Card_Posture.layer.cornerRadius = 18

        titleLabel_Posture.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 2

        contentLabel_Posture.font = .systemFont(ofSize: 13, weight: .regular)
        contentLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        // 减少行数，避免与底部统计区重叠
        contentLabel_Posture.numberOfLines = 3

        authorLabel_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        authorLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        authorLabel_Posture.numberOfLines = 1

        statLabel_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        statLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        // 提高抗压缩优先级，保证"x comments"文字不被点赞按钮挤压
        statLabel_Posture.setContentCompressionResistancePriority(.required, for: .horizontal)

        tagLabel_Posture.font = .systemFont(ofSize: 10, weight: .heavy)
        tagLabel_Posture.textColor = ColorConfig_Posture.primaryGradientStart_Posture
        tagLabel_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        tagLabel_Posture.textAlignment = .center
        tagLabel_Posture.layer.cornerRadius = 12
        tagLabel_Posture.clipsToBounds = true

        badgeLabel_Posture.font = .systemFont(ofSize: 10, weight: .heavy)
        badgeLabel_Posture.textColor = .white
        badgeLabel_Posture.textAlignment = .center
        badgeLabel_Posture.backgroundColor = ColorConfig_Posture.secondaryGradientStart_Posture
        badgeLabel_Posture.layer.cornerRadius = 14
        badgeLabel_Posture.clipsToBounds = true

        likeButton_Posture.tintColor = ColorConfig_Posture.secondaryGradientStart_Posture
        likeButton_Posture.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        likeButton_Posture.addAction(UIAction { [weak self] _ in
            self?.handleLikeTap_Posture()
        }, for: .touchUpInside)

        cardView_Posture.addSubview(topAccentView_Card_Posture)
        cardView_Posture.addSubview(mediaView_Posture)
        cardView_Posture.addSubview(tagLabel_Posture)
        cardView_Posture.addSubview(badgeLabel_Posture)
        cardView_Posture.addSubview(avatarView_Posture)
        cardView_Posture.addSubview(authorLabel_Posture)
        cardView_Posture.addSubview(titleLabel_Posture)
        cardView_Posture.addSubview(contentLabel_Posture)
        cardView_Posture.addSubview(statLabel_Posture)
        cardView_Posture.addSubview(likeButton_Posture)

        cardView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        topAccentView_Card_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(42)
        }

        mediaView_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            // 固定高度，避免比例计算导致内容区空间不足
            make.height.equalTo(120)
        }

        tagLabel_Posture.snp.makeConstraints { make in
            make.leading.top.equalTo(mediaView_Posture).offset(10)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(68)
        }

        badgeLabel_Posture.snp.makeConstraints { make in
            make.trailing.top.equalTo(mediaView_Posture).inset(10)
            make.width.height.equalTo(28)
        }

        avatarView_Posture.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Posture.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(28)
        }

        authorLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Posture)
            make.leading.equalTo(avatarView_Posture.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(42)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        contentLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        // 统计行跟随内容向下流，不再底部锚定，避免内容重叠
        // 不设 bottom 约束，防止卡片高度估算略小时强行压缩统计行
        statLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Posture.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(12)
            make.trailing.lessThanOrEqualTo(likeButton_Posture.snp.leading).offset(-8)
        }

        likeButton_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(statLabel_Posture)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(28)
            // 保证点赞按钮有足够宽度展示图标和数字，不挤压左侧评论数
            make.width.greaterThanOrEqualTo(50)
        }
    }

    /// 绑定帖子数据
    /// - Parameters:
    ///   - post_posture: 帖子模型
    ///   - parentViewController_posture: 用于弹窗展示的页面
    /// - Returns: Void
    /// - Throws: 无
    func configure_Posture(post_posture: TitleModel_Posture, parentViewController_posture: UIViewController, index_posture: Int = 0) {
        post_Posture = post_posture
        cardIndex_Posture = index_posture

        // 根据 index 从调色盘取色，让每张卡片拥有独立色调
        let palette_Posture   = ColorConfig_Posture.cardAccentPalette_Posture[index_posture % ColorConfig_Posture.cardAccentPalette_Posture.count]
        let tagCategory_Posture = categoryTitle_Posture(post_Posture: post_posture)
        let tagColors_Posture = ColorConfig_Posture.tagColors_Posture(for: tagCategory_Posture)

        // 顶部装饰条用调色盘浅色
        topAccentView_Card_Posture.backgroundColor = palette_Posture.light

        // 标签颜色按分类取色
        tagLabel_Posture.backgroundColor = tagColors_Posture.bg
        tagLabel_Posture.textColor       = tagColors_Posture.text

        // 徽章用调色盘主色
        badgeLabel_Posture.backgroundColor = palette_Posture.main

        // 点赞按钮和阴影用调色盘主色
        likeButton_Posture.tintColor = palette_Posture.main
        likeButton_Posture.setTitleColor(palette_Posture.main, for: .normal)
        cardView_Posture.layer.shadowColor = palette_Posture.shadow.cgColor

        mediaView_Posture.configure_Posture(mediaPath_Posture: post_posture.titleMeidas_Posture.first)
        avatarView_Posture.configure_Posture(userId_Posture: post_posture.titleUserId_Posture)
        authorLabel_Posture.text = post_posture.titleUserName_Posture
        titleLabel_Posture.text = post_posture.title_Posture
        contentLabel_Posture.text = post_posture.titleContent_Posture
        statLabel_Posture.text = "\(post_posture.reviews_Posture.count) comments"
        tagLabel_Posture.text = "  \(tagCategory_Posture)  "
        badgeLabel_Posture.text = "\(post_posture.titleId_Posture % 100)"

        let liked_Posture = TitleViewModel_Posture.shared_Posture.isLikedPost_Posture(post_posture: post_posture)
        likeButton_Posture.setImage(UIImage(systemName: liked_Posture ? "heart.fill" : "heart"), for: .normal)
        likeButton_Posture.setTitle(" \(post_posture.likes_Posture)", for: .normal)

        reportButton_Posture?.removeFromSuperview()
        let button_Posture = ReportDeleteHelper_Posture.createPostReportButton_Posture(
            post_Posture: post_posture,
            size_Posture: 16,
            color_Posture: ColorConfig_Posture.textSecondary_Posture,
            from: parentViewController_posture
        )
        cardView_Posture.addSubview(button_Posture)
        button_Posture.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Posture.snp.bottom).offset(11)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(28)
        }
        reportButton_Posture = button_Posture
    }

    /// 根据帖子内容生成主题标签
    /// - Parameter post_Posture: 帖子模型
    /// - Returns: String - 主题标签文本
    /// - Throws: 无
    private func categoryTitle_Posture(post_Posture: TitleModel_Posture) -> String {
        let source_Posture = "\(post_Posture.title_Posture) \(post_Posture.titleContent_Posture)".lowercased()
        if source_Posture.contains("neck") {
            return "NECK"
        }
        if source_Posture.contains("core") {
            return "CORE"
        }
        if source_Posture.contains("desk") {
            return "DESK"
        }
        if source_Posture.contains("walk") {
            return "WALK"
        }
        return "POSTURE"
    }

    /// 处理点赞点击
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func handleLikeTap_Posture() {
        guard let post_Posture else { return }
        likeButton_Posture.animatePulse_Posture()
        onLike_Posture?(post_Posture)
    }
}

// MARK: - 每日教学视频卡片

/// 每日教学视频单卡片
/// 核心作用：展示单个教学视频，包含封面缩略图、时长标签、标题、等级胶囊和播放入口。
/// 设计思路：封面使用 MediaDisplayView 自动提取视频第一帧，顶层覆盖播放按钮和时长标签，下方展示元信息。
/// 关键属性：`mediaView_Posture` 显示封面，`onTap_Posture` 回调由外部处理播放跳转。
/// 关键方法：`configure_Posture(...)` 一次性绑定全部数据。
@MainActor
private class DailyLessonCard_Posture: UIView {

    // MARK: - 子视图

    /// 封面媒体视图
    private let mediaView_Posture = MediaDisplayView_Posture()

    /// 半透明播放按钮蒙层
    private let playOverlay_Posture = UIView()

    /// 播放图标
    private let playIcon_Posture = UIImageView()

    /// 时长角标（覆盖在封面右下角）
    private let durationBadge_Posture = UILabel()

    /// 难度胶囊（封面左上角，带主题色）
    private let levelBadge_Posture = UILabel()

    /// 视频标题
    private let titleLabel_Posture = UILabel()

    /// 底部信息行（类别图标 + 分钟数）
    private let infoRow_Posture = UIView()

    /// 类别图标
    private let categoryIcon_Posture = UIImageView()

    /// 分钟数标签
    private let minutesLabel_Posture = UILabel()

    /// 当前视频文件名（点击时传给播放器）
    private var currentVideoName_Posture: String = ""

    /// 点击回调（外部可扩展，内部默认导航到播放器）
    var onTap_Posture: (() -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI搭建

    /// 搭建卡片 UI 结构
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        layer.cornerRadius = 16
        layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        // 封面（圆角裁剪由自身 cornerRadius 控制）
        mediaView_Posture.layer.cornerRadius = 12
        mediaView_Posture.clipsToBounds = true

        // 播放蒙层（半圆按钮，覆盖封面中心）
        playOverlay_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        playOverlay_Posture.layer.cornerRadius = 20
        playIcon_Posture.image = UIImage(systemName: "play.fill")
        playIcon_Posture.tintColor = .white
        playIcon_Posture.contentMode = .scaleAspectFit
        playOverlay_Posture.addSubview(playIcon_Posture)

        // 时长角标
        durationBadge_Posture.font = .systemFont(ofSize: 10, weight: .heavy)
        durationBadge_Posture.textColor = .white
        durationBadge_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.52)
        durationBadge_Posture.layer.cornerRadius = 8
        durationBadge_Posture.clipsToBounds = true
        durationBadge_Posture.textAlignment = .center

        // 难度胶囊
        levelBadge_Posture.font = .systemFont(ofSize: 9, weight: .heavy)
        levelBadge_Posture.textAlignment = .center
        levelBadge_Posture.layer.cornerRadius = 8
        levelBadge_Posture.clipsToBounds = true

        // 标题
        titleLabel_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 2

        // 信息行
        categoryIcon_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        categoryIcon_Posture.contentMode = .scaleAspectFit
        minutesLabel_Posture.font = .systemFont(ofSize: 10, weight: .semibold)
        minutesLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        infoRow_Posture.addSubview(categoryIcon_Posture)
        infoRow_Posture.addSubview(minutesLabel_Posture)

        addSubview(mediaView_Posture)
        addSubview(playOverlay_Posture)
        addSubview(durationBadge_Posture)
        addSubview(levelBadge_Posture)
        addSubview(titleLabel_Posture)
        addSubview(infoRow_Posture)

        // 封面
        mediaView_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(88)
        }
        // 播放蒙层（封面中心）
        playOverlay_Posture.snp.makeConstraints { make in
            make.center.equalTo(mediaView_Posture)
            make.width.height.equalTo(40)
        }
        playIcon_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        // 时长角标（封面右下角）
        durationBadge_Posture.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(mediaView_Posture).inset(6)
            make.height.equalTo(18)
        }
        // 难度胶囊（封面左上角）
        levelBadge_Posture.snp.makeConstraints { make in
            make.leading.top.equalTo(mediaView_Posture).inset(6)
            make.height.equalTo(18)
        }
        // 标题
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        // 信息行
        categoryIcon_Posture.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(11)
        }
        minutesLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(categoryIcon_Posture.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        infoRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(14)
        }

        // 点击手势
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap_Posture)))
    }

    // MARK: - 数据绑定

    /// 绑定视频卡片数据（颜色按 colorIndex 从调色盘取）
    /// - Parameters:
    ///   - videoName_Posture: Bundle 内视频文件名（不含扩展名）
    ///   - title_Posture: 视频标题
    ///   - duration_Posture: 时长文字（如 "5 min"）
    ///   - level_Posture: 难度描述（如 "Beginner"）
    ///   - colorIndex_Posture: 调色盘取色索引
    /// - Returns: Void
    /// - Throws: 无
    func configure_Posture(videoName_Posture: String, title_Posture: String,
                           duration_Posture: String, level_Posture: String,
                           colorIndex_Posture: Int) {
        currentVideoName_Posture = videoName_Posture
        mediaView_Posture.configure_Posture(mediaPath_Posture: videoName_Posture, isVideo_Posture: true)
        titleLabel_Posture.text = title_Posture
        durationBadge_Posture.text = "  \(duration_Posture)  "
        minutesLabel_Posture.text = duration_Posture

        let palette_Posture = ColorConfig_Posture.chipColors_Posture(at: colorIndex_Posture)
        levelBadge_Posture.text = "  \(level_Posture)  "
        levelBadge_Posture.textColor = palette_Posture.tint
        levelBadge_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.88)

        // 根据序号选不同图标
        let icons_Posture = ["sunrise.fill", "desktopcomputer", "figure.core.training"]
        let iconName_Posture = icons_Posture[colorIndex_Posture % icons_Posture.count]
        categoryIcon_Posture.image = UIImage(systemName: iconName_Posture)
        categoryIcon_Posture.tintColor = palette_Posture.tint
    }

    // MARK: - 事件

    /// 处理卡片点击
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func handleTap_Posture() {
        animatePressDown_Posture { [weak self] in
            self?.animatePressUp_Posture()
            if let callback_Posture = self?.onTap_Posture {
                // 外部指定了回调则执行回调
                callback_Posture()
            } else {
                // 默认行为：全屏播放视频
                guard let name_Posture = self?.currentVideoName_Posture, !name_Posture.isEmpty else { return }
                Navigation_Posture.toMediaPlayer_Posture(
                    mediaPath_posture: name_Posture,
                    isVideo_posture: true
                )
            }
        }
    }
}

// MARK: - 瀑布流布局代理

/// 发现页瀑布流布局代理
/// 核心作用：由页面按帖子内容返回每个卡片高度。
/// 设计思路：布局类不直接读取业务数据，只通过代理获取尺寸，保持布局与数据解耦。
/// 关键方法：`collectionView_Posture(_:heightForItemAt:itemWidth_posture:)` 返回卡片高度。
private protocol DiscoverWaterfallLayoutDelegate_Posture: AnyObject {
    /// 返回瀑布流卡片高度
    /// - Parameters:
    ///   - collectionView_posture: 集合视图
    ///   - indexPath_posture: 索引位置
    ///   - itemWidth_posture: 卡片宽度
    /// - Returns: CGFloat - 卡片高度
    /// - Throws: 无
    func collectionView_Posture(_ collectionView_posture: UICollectionView, heightForItemAt indexPath_posture: IndexPath, itemWidth_posture: CGFloat) -> CGFloat
}

// MARK: - 瀑布流布局

/// 双列瀑布流布局
/// 核心作用：按当前较短列放置帖子卡片，形成非规则瀑布流效果。
/// 设计思路：预计算所有 item 的 frame，并缓存布局属性提升滚动性能。
/// 关键属性：`delegate_Posture` 提供高度，`layoutAttributes_Posture` 缓存布局结果。
/// 关键方法：`prepare()` 计算布局，`layoutAttributesForElements(in:)` 返回可见区域属性。
private class DiscoverWaterfallLayout_Posture: UICollectionViewLayout {

    /// 布局代理
    weak var delegate_Posture: DiscoverWaterfallLayoutDelegate_Posture?

    /// 列数
    private let columnCount_Posture = 2

    /// 列间距
    private let columnSpacing_Posture: CGFloat = 12

    /// 行间距
    private let rowSpacing_Posture: CGFloat = 14

    /// 顶部预留区域，标题区已脱离列表所以只保留呼吸间距
    private let topSpacing_Posture: CGFloat = 4

    /// 左右安全边距，避免使用 collectionView 的横向 contentInset 造成横向拖动
    private let horizontalSpacing_Posture: CGFloat = 18

    /// 缓存的布局属性
    private var layoutAttributes_Posture: [UICollectionViewLayoutAttributes] = []

    /// 内容高度
    private var contentHeight_Posture: CGFloat = 0

    override var collectionViewContentSize: CGSize {
        guard let collectionView_Posture = collectionView else { return .zero }
        return CGSize(width: collectionView_Posture.bounds.width, height: contentHeight_Posture + collectionView_Posture.adjustedContentInset.bottom)
    }

    /// 计算瀑布流布局
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    override func prepare() {
        super.prepare()
        guard let collectionView_Posture = collectionView else { return }

        layoutAttributes_Posture.removeAll()
        contentHeight_Posture = 0

        let availableWidth_Posture = collectionView_Posture.bounds.width - horizontalSpacing_Posture * 2
        let itemWidth_Posture = (availableWidth_Posture - CGFloat(columnCount_Posture - 1) * columnSpacing_Posture) / CGFloat(columnCount_Posture)
        var columnHeights_Posture = Array(repeating: topSpacing_Posture, count: columnCount_Posture)

        let itemCount_Posture = collectionView_Posture.numberOfItems(inSection: 0)
        for item_Posture in 0..<itemCount_Posture {
            let indexPath_Posture = IndexPath(item: item_Posture, section: 0)
            let targetColumn_Posture = columnHeights_Posture.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let x_Posture = horizontalSpacing_Posture + CGFloat(targetColumn_Posture) * (itemWidth_Posture + columnSpacing_Posture)
            let y_Posture = columnHeights_Posture[targetColumn_Posture]
            let height_Posture = delegate_Posture?.collectionView_Posture(collectionView_Posture, heightForItemAt: indexPath_Posture, itemWidth_posture: itemWidth_Posture) ?? 300

            let attributes_Posture = UICollectionViewLayoutAttributes(forCellWith: indexPath_Posture)
            attributes_Posture.frame = CGRect(x: x_Posture, y: y_Posture, width: itemWidth_Posture, height: height_Posture)
            layoutAttributes_Posture.append(attributes_Posture)

            columnHeights_Posture[targetColumn_Posture] = y_Posture + height_Posture + rowSpacing_Posture
            contentHeight_Posture = max(contentHeight_Posture, columnHeights_Posture[targetColumn_Posture])
        }
    }

    /// 返回可见区域内的布局属性
    /// - Parameter rect: 当前可见区域
    /// - Returns: [UICollectionViewLayoutAttributes]? - 可见元素布局
    /// - Throws: 无
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes_Posture.filter { $0.frame.intersects(rect) }
    }

    /// 返回指定元素的布局属性
    /// - Parameter indexPath: 元素索引
    /// - Returns: UICollectionViewLayoutAttributes? - 对应布局属性
    /// - Throws: 无
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes_Posture.first { $0.indexPath == indexPath }
    }

    /// 判断尺寸变化时是否需要重新布局
    /// - Parameter newBounds: 新边界
    /// - Returns: Bool - 是否重新布局
    /// - Throws: 无
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Posture: UITextFieldDelegate {

    /// 按下搜索/回车键时收起键盘
    /// - Parameter textField: 搜索输入框
    /// - Returns: Bool - 是否处理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /// 清空输入框（点击系统 × 按钮）时同步重置过滤状态
    /// - Parameter textField: 搜索输入框
    /// - Returns: Bool - 是否允许清空
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchQuery_Posture = ""
        layout_Posture.invalidateLayout()
        collectionView_Posture.reloadData()
        return true
    }
}
