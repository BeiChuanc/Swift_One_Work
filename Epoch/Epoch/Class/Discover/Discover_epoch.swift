import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页
/// 核心作用：以更有氛围感的发现页头部和瀑布流内容承载帖子浏览
/// 设计思路：通过整页滚动容器、艺术化文字层级、精选卡片和双列瀑布流形成更完整的发现体验
class Discover_Epoch: UIViewController {

    /// 帖子数据
    private var posts_Epoch: [TitleModel_Epoch] = []

    /// 背景装饰
    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    /// 外层滚动视图
    private let scrollView_Epoch: UIScrollView = {
        let scrollView_Epoch = UIScrollView()
        scrollView_Epoch.showsVerticalScrollIndicator = false
        scrollView_Epoch.alwaysBounceVertical = true
        return scrollView_Epoch
    }()

    /// 滚动内容容器
    private let contentView_Epoch = UIView()

    /// 页面主标题区域
    private let heroHeaderView_Epoch = DiscoverHeaderBlockView_Epoch()

    /// 主题标签容器
    private let topicTagsStackView_Epoch: UIStackView = {
        let stackView_Epoch = UIStackView()
        stackView_Epoch.axis = .horizontal
        stackView_Epoch.spacing = 10
        stackView_Epoch.alignment = .fill
        stackView_Epoch.distribution = .fillEqually
        return stackView_Epoch
    }()

    /// 主题标签一
    private let ritualTagView_Epoch = DiscoverTagView_Epoch()

    /// 主题标签二
    private let ambientTagView_Epoch = DiscoverTagView_Epoch()

    /// 主题标签三
    private let creatorsTagView_Epoch = DiscoverTagView_Epoch()

    /// 指标容器
    private let metricsStackView_Epoch: UIStackView = {
        let stackView_Epoch = UIStackView()
        stackView_Epoch.axis = .horizontal
        stackView_Epoch.spacing = 12
        stackView_Epoch.distribution = .fillEqually
        return stackView_Epoch
    }()

    /// 帖子数量指标
    private let postsMetricView_Epoch = DiscoverMetricView_Epoch()

    /// 创作者数量指标
    private let creatorsMetricView_Epoch = DiscoverMetricView_Epoch()

    /// 互动热度指标
    private let interactionMetricView_Epoch = DiscoverMetricView_Epoch()

    /// 内容分组标题
    private let feedHeaderView_Epoch = DiscoverHeaderBlockView_Epoch()

    /// 内容容器
    private let feedContainerView_Epoch = UIView()

    /// 内容容器高度约束
    private var feedContainerHeightConstraint_Epoch: Constraint?

    /// 当前内容区高度缓存
    private var feedContainerHeightValue_Epoch: CGFloat = 0

    /// 瀑布流布局
    private lazy var layout_Epoch: DiscoverMasonryLayout_Epoch = {
        let layout_Epoch = DiscoverMasonryLayout_Epoch()
        layout_Epoch.delegate_Epoch = self
        return layout_Epoch
    }()

    /// 集合视图
    private lazy var collectionView_Epoch: UICollectionView = {
        let collectionView_Epoch = UICollectionView(frame: .zero, collectionViewLayout: layout_Epoch)
        collectionView_Epoch.backgroundColor = .clear
        collectionView_Epoch.showsVerticalScrollIndicator = false
        collectionView_Epoch.alwaysBounceVertical = false
        collectionView_Epoch.isScrollEnabled = false
        return collectionView_Epoch
    }()

    /// 空状态视图
    private let emptyStateView_Epoch = EmptyStateView_Epoch()

    /// 页面即将出现时刷新数据
    /// - Parameter animated: 是否使用系统动画
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Epoch()
    }

    /// 页面加载完成后初始化界面和通知
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        setupNotifications_Epoch()
        reloadData_Epoch()
    }

    /// 布局完成后同步瀑布流高度
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFeedContainerHeight_Epoch(forceUpdate_epoch: false)
    }

    /// 页面销毁时移除通知观察
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 构建界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)

        contentView_Epoch.addSubview(heroHeaderView_Epoch)
        contentView_Epoch.addSubview(topicTagsStackView_Epoch)
        contentView_Epoch.addSubview(metricsStackView_Epoch)
        contentView_Epoch.addSubview(feedHeaderView_Epoch)
        contentView_Epoch.addSubview(feedContainerView_Epoch)

        feedContainerView_Epoch.addSubview(collectionView_Epoch)
        feedContainerView_Epoch.addSubview(emptyStateView_Epoch)

        heroHeaderView_Epoch.configure_Epoch(
            badge_Epoch: "DISCOVER",
            title_Epoch: "Find ritual stories with a softer mood",
            subtitle_Epoch: "Move through curated visuals, expressive creators and warm little moments in one flowing canvas."
        )
        ritualTagView_Epoch.configure_Epoch(iconName_Epoch: "sparkles", title_Epoch: "Ritual mood")
        ambientTagView_Epoch.configure_Epoch(iconName_Epoch: "moon.stars.fill", title_Epoch: "Soft ambient")
        creatorsTagView_Epoch.configure_Epoch(iconName_Epoch: "person.3.fill", title_Epoch: "Creative circle")
        feedHeaderView_Epoch.configure_Epoch(
            badge_Epoch: "LIVE FEED",
            title_Epoch: "Curated wall",
            subtitle_Epoch: "A cascading mix of visual stories, intimate details and lively reactions."
        )

        topicTagsStackView_Epoch.addArrangedSubview(ritualTagView_Epoch)
        topicTagsStackView_Epoch.addArrangedSubview(ambientTagView_Epoch)
        topicTagsStackView_Epoch.addArrangedSubview(creatorsTagView_Epoch)

        metricsStackView_Epoch.addArrangedSubview(postsMetricView_Epoch)
        metricsStackView_Epoch.addArrangedSubview(creatorsMetricView_Epoch)
        metricsStackView_Epoch.addArrangedSubview(interactionMetricView_Epoch)

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Epoch.contentLayoutGuide)
            make.width.equalTo(scrollView_Epoch.frameLayoutGuide)
        }

        heroHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(contentView_Epoch.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        topicTagsStackView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroHeaderView_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        metricsStackView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(topicTagsStackView_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(92)
        }

        feedHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(metricsStackView_Epoch.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
        }

        feedContainerView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(feedHeaderView_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            self.feedContainerHeightConstraint_Epoch = make.height.equalTo(0).constraint
        }

        collectionView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyStateView_Epoch.configure_Epoch(
            iconName_Epoch: "square.grid.2x2",
            title_Epoch: "Nothing to discover",
            subtitle_Epoch: "Create new ritual content to make this wall come alive.",
            buttonTitle_Epoch: "Create post"
        )
        emptyStateView_Epoch.actionHandler_Epoch = {
            Navigation_Epoch.toRelease_Epoch(style_epoch: .present_epoch)
        }
        emptyStateView_Epoch.isHidden = true
        emptyStateView_Epoch.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-18)
            make.left.right.equalToSuperview().inset(32)
        }

        collectionView_Epoch.register(PostCollectionViewCell_Epoch.self, forCellWithReuseIdentifier: "PostCollectionViewCell_Epoch")
        collectionView_Epoch.dataSource = self
        collectionView_Epoch.delegate = self
        collectionView_Epoch.contentInset = UIEdgeInsets(top: 6, left: 16, bottom: 28, right: 16)
    }

    /// 注册通知
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

    /// 刷新数据
    private func reloadData_Epoch() {
        posts_Epoch = TitleViewModel_Epoch.shared_Epoch.getPosts_Epoch()
        refreshOverview_Epoch()
        emptyStateView_Epoch.isHidden = !posts_Epoch.isEmpty
        collectionView_Epoch.isHidden = posts_Epoch.isEmpty
        layout_Epoch.invalidateLayout()
        collectionView_Epoch.reloadData()
        updateFeedContainerHeight_Epoch(forceUpdate_epoch: true)
    }

    /// 处理状态变化
    @objc private func handleStateChange_Epoch() {
        reloadData_Epoch()
    }

    /// 刷新顶部概览信息
    /// 功能：根据当前帖子数据更新精选卡片和指标数据
    private func refreshOverview_Epoch() {
        let creatorsCount_epoch = Set(posts_Epoch.map { $0.titleUserId_Epoch }).count
        let interactionCount_epoch = posts_Epoch.reduce(0) { partialResult_epoch, post_epoch in
            partialResult_epoch + post_epoch.likes_Epoch + post_epoch.reviews_Epoch.count
        }
        let averageInteraction_epoch = posts_Epoch.isEmpty ? 0 : interactionCount_epoch / posts_Epoch.count

        postsMetricView_Epoch.configure_Epoch(
            iconName_Epoch: "square.grid.2x2.fill",
            value_Epoch: "\(posts_Epoch.count)",
            title_Epoch: "Posts",
            tintColor_Epoch: ColorConfig_Epoch.accentPurple_Epoch
        )
        creatorsMetricView_Epoch.configure_Epoch(
            iconName_Epoch: "person.2.fill",
            value_Epoch: "\(creatorsCount_epoch)",
            title_Epoch: "Creators",
            tintColor_Epoch: ColorConfig_Epoch.accentBlue_Epoch
        )
        interactionMetricView_Epoch.configure_Epoch(
            iconName_Epoch: "sparkles",
            value_Epoch: "\(averageInteraction_epoch)",
            title_Epoch: "Avg heat",
            tintColor_Epoch: ColorConfig_Epoch.accentGold_Epoch
        )
    }

    /// 更新内容容器高度
    /// - Parameter forceUpdate_epoch: 是否强制刷新高度
    private func updateFeedContainerHeight_Epoch(forceUpdate_epoch: Bool) {
        let targetHeight_epoch: CGFloat

        if posts_Epoch.isEmpty {
            targetHeight_epoch = 320
        } else {
            collectionView_Epoch.layoutIfNeeded()
            layout_Epoch.invalidateLayout()
            collectionView_Epoch.collectionViewLayout.invalidateLayout()
            collectionView_Epoch.layoutIfNeeded()
            targetHeight_epoch = layout_Epoch.collectionViewContentSize.height
                + collectionView_Epoch.contentInset.top
                + collectionView_Epoch.contentInset.bottom
        }

        guard forceUpdate_epoch || abs(feedContainerHeightValue_Epoch - targetHeight_epoch) > 1 else {
            return
        }

        feedContainerHeightValue_Epoch = targetHeight_epoch
        feedContainerHeightConstraint_Epoch?.update(offset: targetHeight_epoch)
        view.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Epoch: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts_Epoch.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_epoch = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell_Epoch", for: indexPath) as? PostCollectionViewCell_Epoch else {
            return UICollectionViewCell()
        }
        let post_epoch = posts_Epoch[indexPath.item]
        cell_epoch.postCardView_Epoch.configure_Epoch(post_epoch: post_epoch, hostViewController_Epoch: self)
        cell_epoch.postCardView_Epoch.onPostTapped_Epoch = {
            Navigation_Epoch.toTitleDetail_Epoch(titleModel_epoch: post_epoch)
        }
        cell_epoch.postCardView_Epoch.onUserTapped_Epoch = {
            let user_epoch = UserViewModel_Epoch.shared_Epoch.getUserById_Epoch(userId_epoch: post_epoch.titleUserId_Epoch)
            Navigation_Epoch.toUserInfo_Epoch(with: user_epoch)
        }
        cell_epoch.postCardView_Epoch.onLikeTapped_Epoch = { [weak self] in
            TitleViewModel_Epoch.shared_Epoch.likePost_Epoch(post_epoch: post_epoch)
            self?.reloadData_Epoch()
        }
        return cell_epoch
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Epoch: UICollectionViewDelegate {}

// MARK: - 发现页字体方案

/// 发现页字体方案
/// 核心作用：统一提供发现页的艺术化字体风格
/// 设计思路：标题优先使用衬线设计，说明与标签优先使用圆角设计，保证艺术感和可读性平衡
enum DiscoverFontPalette_Epoch {

    /// 返回发现页字体
    /// - Parameters:
    ///   - size_Epoch: 字体大小
    ///   - weight_Epoch: 字体粗细
    ///   - design_Epoch: 字体设计风格
    /// - Returns: 适配后的字体对象
    static func font_Epoch(
        size_Epoch: CGFloat,
        weight_Epoch: UIFont.Weight,
        design_Epoch: UIFontDescriptor.SystemDesign
    ) -> UIFont {
        let baseFont_Epoch = UIFont.systemFont(ofSize: size_Epoch, weight: weight_Epoch)
        guard let descriptor_Epoch = baseFont_Epoch.fontDescriptor.withDesign(design_Epoch) else {
            return baseFont_Epoch
        }
        return UIFont(descriptor: descriptor_Epoch, size: size_Epoch)
    }
}

// MARK: - 发现页标题块

/// 发现页标题块
/// 核心作用：统一承载发现页中的标签、标题和说明文案
/// 设计思路：通过艺术化字体、字距和轻量排版，让标题区域更具视觉情绪
class DiscoverHeaderBlockView_Epoch: UIView {

    /// 标签胶囊
    private let badgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.font = DiscoverFontPalette_Epoch.font_Epoch(size_Epoch: 11, weight_Epoch: .bold, design_Epoch: .rounded)
        label_Epoch.textColor = ColorConfig_Epoch.accentPurple_Epoch
        label_Epoch.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.16)
        label_Epoch.layer.cornerRadius = 12
        label_Epoch.clipsToBounds = true
        label_Epoch.horizontalInset_Epoch = 10
        label_Epoch.verticalInset_Epoch = 6
        return label_Epoch
    }()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = DiscoverFontPalette_Epoch.font_Epoch(size_Epoch: 32, weight_Epoch: .bold, design_Epoch: .serif)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 副标题标签
    private let subtitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = DiscoverFontPalette_Epoch.font_Epoch(size_Epoch: 15, weight_Epoch: .medium, design_Epoch: .rounded)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 绑定标题内容
    /// - Parameters:
    ///   - badge_Epoch: 标签文案
    ///   - title_Epoch: 标题文案
    ///   - subtitle_Epoch: 副标题文案
    func configure_Epoch(badge_Epoch: String, title_Epoch: String, subtitle_Epoch: String) {
        badgeLabel_Epoch.text = badge_Epoch
        titleLabel_Epoch.text = title_Epoch
        subtitleLabel_Epoch.text = subtitle_Epoch
    }

    /// 构建标题块界面
    private func setupUI_Epoch() {
        let stackView_Epoch = UIStackView(arrangedSubviews: [badgeLabel_Epoch, titleLabel_Epoch, subtitleLabel_Epoch])
        stackView_Epoch.axis = .vertical
        stackView_Epoch.spacing = 10
        stackView_Epoch.alignment = .leading
        addSubview(stackView_Epoch)

        stackView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - 发现页标签胶囊

/// 发现页标签胶囊
/// 核心作用：展示发现页主题关键词，丰富头部视觉元素
/// 设计思路：使用轻面板、图标和圆角文字块强化内容氛围
class DiscoverTagView_Epoch: UIView {

    /// 背景面板
    private let containerView_Epoch = SurfaceCardView_Epoch()

    /// 图标背景
    private let iconBackgroundView_Epoch = UIView()

    /// 图标视图
    private let iconImageView_Epoch = UIImageView()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = DiscoverFontPalette_Epoch.font_Epoch(size_Epoch: 11, weight_Epoch: .semibold, design_Epoch: .rounded)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 2
        label_Epoch.textAlignment = .center
        label_Epoch.lineBreakMode = .byWordWrapping
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置标签内容
    /// - Parameters:
    ///   - iconName_Epoch: 系统图标名称
    ///   - title_Epoch: 标签标题
    func configure_Epoch(iconName_Epoch: String, title_Epoch: String) {
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)
        iconImageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iconBackgroundView_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        titleLabel_Epoch.text = title_Epoch
    }

    /// 构建标签界面
    private func setupUI_Epoch() {
        addSubview(containerView_Epoch)
        containerView_Epoch.addSubview(iconBackgroundView_Epoch)
        iconBackgroundView_Epoch.addSubview(iconImageView_Epoch)
        containerView_Epoch.addSubview(titleLabel_Epoch)

        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(74)
        }

        iconBackgroundView_Epoch.layer.cornerRadius = 16
        iconBackgroundView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(32)
        }

        iconImageView_Epoch.contentMode = .scaleAspectFit
        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(15)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundView_Epoch.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - 发现页指标卡片

/// 发现页指标卡片
/// 核心作用：统一展示发现页中的数量型信息
/// 设计思路：使用轻量面板承载图标、数值和标题，增强头部信息密度
class DiscoverMetricView_Epoch: UIView {

    /// 内容面板
    private let containerView_Epoch = SurfaceCardView_Epoch()

    /// 图标背景
    private let iconBackgroundView_Epoch = UIView()

    /// 图标视图
    private let iconImageView_Epoch = UIImageView()

    /// 数值标签
    private let valueLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = DiscoverFontPalette_Epoch.font_Epoch(size_Epoch: 23, weight_Epoch: .bold, design_Epoch: .serif)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = DiscoverFontPalette_Epoch.font_Epoch(size_Epoch: 12, weight_Epoch: .semibold, design_Epoch: .rounded)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 绑定指标内容
    /// - Parameters:
    ///   - iconName_Epoch: 系统图标名称
    ///   - value_Epoch: 指标值文案
    ///   - title_Epoch: 指标标题文案
    ///   - tintColor_Epoch: 图标强调色
    func configure_Epoch(
        iconName_Epoch: String,
        value_Epoch: String,
        title_Epoch: String,
        tintColor_Epoch: UIColor
    ) {
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)
        iconImageView_Epoch.tintColor = tintColor_Epoch
        iconBackgroundView_Epoch.backgroundColor = tintColor_Epoch.withAlphaComponent(0.14)
        valueLabel_Epoch.text = value_Epoch
        titleLabel_Epoch.text = title_Epoch
    }

    /// 构建指标卡片界面
    private func setupUI_Epoch() {
        backgroundColor = .clear
        addSubview(containerView_Epoch)
        containerView_Epoch.addSubview(iconBackgroundView_Epoch)
        iconBackgroundView_Epoch.addSubview(iconImageView_Epoch)

        let textStackView_epoch = UIStackView(arrangedSubviews: [valueLabel_Epoch, titleLabel_Epoch])
        textStackView_epoch.axis = .vertical
        textStackView_epoch.spacing = 4
        containerView_Epoch.addSubview(textStackView_epoch)

        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconBackgroundView_Epoch.layer.cornerRadius = 20
        iconBackgroundView_Epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.width.height.equalTo(40)
        }

        iconImageView_Epoch.contentMode = .scaleAspectFit
        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        textStackView_epoch.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}

// MARK: - DiscoverMasonryLayoutDelegate_Epoch

extension Discover_Epoch: DiscoverMasonryLayoutDelegate_Epoch {

    func collectionView(_ collectionView: UICollectionView, layout: DiscoverMasonryLayout_Epoch, heightForItemAt indexPath: IndexPath, itemWidth_Epoch: CGFloat) -> CGFloat {
        let post_epoch = posts_Epoch[indexPath.item]
        let baseHeight_epoch: CGFloat = indexPath.item.isMultiple(of: 2) ? 320 : 360
        let titleExtra_epoch = CGFloat(min(post_epoch.title_Epoch.count, 24)) * 1.1
        let contentExtra_epoch = CGFloat(min(post_epoch.titleContent_Epoch.count, 120)) * 0.45
        return baseHeight_epoch + titleExtra_epoch + contentExtra_epoch
    }
}

// MARK: - 瀑布流布局代理

/// 瀑布流布局代理
protocol DiscoverMasonryLayoutDelegate_Epoch: AnyObject {
    /// 返回指定位置的项目高度
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - layout: 当前布局
    ///   - indexPath: 位置
    ///   - itemWidth_Epoch: 当前项目宽度
    /// - Returns: 项目高度
    func collectionView(_ collectionView: UICollectionView, layout: DiscoverMasonryLayout_Epoch, heightForItemAt indexPath: IndexPath, itemWidth_Epoch: CGFloat) -> CGFloat
}

// MARK: - 非规则瀑布流布局

/// 非规则瀑布流布局
/// 核心作用：实现两列高低错落的卡片排布
/// 设计思路：按照最短列优先的方式放置元素，形成稳定且自然的瀑布流效果
class DiscoverMasonryLayout_Epoch: UICollectionViewLayout {

    /// 布局缓存
    private var cache_Epoch: [UICollectionViewLayoutAttributes] = []

    /// 内容高度
    private var contentHeight_Epoch: CGFloat = 0

    /// 列数
    private let numberOfColumns_Epoch = 2

    /// 间距
    private let cellPadding_Epoch: CGFloat = 8

    /// 布局代理
    weak var delegate_Epoch: DiscoverMasonryLayoutDelegate_Epoch?

    private var contentWidth_Epoch: CGFloat {
        guard let collectionView_Epoch = collectionView else { return 0 }
        let insets_epoch = collectionView_Epoch.contentInset
        return collectionView_Epoch.bounds.width - (insets_epoch.left + insets_epoch.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth_Epoch, height: contentHeight_Epoch)
    }

    override func prepare() {
        guard cache_Epoch.isEmpty, let collectionView_Epoch = collectionView else { return }

        let columnWidth_epoch = contentWidth_Epoch / CGFloat(numberOfColumns_Epoch)
        var xOffset_epoch: [CGFloat] = []
        for column_epoch in 0..<numberOfColumns_Epoch {
            xOffset_epoch.append(CGFloat(column_epoch) * columnWidth_epoch)
        }

        var columnHeights_epoch = Array(repeating: CGFloat(0), count: numberOfColumns_Epoch)

        for item_epoch in 0..<collectionView_Epoch.numberOfItems(inSection: 0) {
            let indexPath_epoch = IndexPath(item: item_epoch, section: 0)
            let itemWidth_epoch = columnWidth_epoch - cellPadding_Epoch * 2
            let itemHeight_epoch = delegate_Epoch?.collectionView(
                collectionView_Epoch,
                layout: self,
                heightForItemAt: indexPath_epoch,
                itemWidth_Epoch: itemWidth_epoch
            ) ?? 320

            let targetColumn_epoch = columnHeights_epoch.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let frame_epoch = CGRect(
                x: xOffset_epoch[targetColumn_epoch],
                y: columnHeights_epoch[targetColumn_epoch],
                width: columnWidth_epoch,
                height: itemHeight_epoch + cellPadding_Epoch * 2
            )
            let insetFrame_epoch = frame_epoch.insetBy(dx: cellPadding_Epoch, dy: cellPadding_Epoch)

            let attributes_epoch = UICollectionViewLayoutAttributes(forCellWith: indexPath_epoch)
            attributes_epoch.frame = insetFrame_epoch
            cache_Epoch.append(attributes_epoch)

            contentHeight_Epoch = max(contentHeight_Epoch, frame_epoch.maxY)
            columnHeights_epoch[targetColumn_epoch] = frame_epoch.maxY
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache_Epoch.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache_Epoch.first { $0.indexPath == indexPath }
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache_Epoch.removeAll()
        contentHeight_Epoch = 0
    }
}
