import Foundation
import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页面
/// 功能：彩色品牌 Header + 悬浮搜索卡片 + 图标圆圈分类 Tab 栏 + 结果摘要条 + 双列帖子瀑布流 + 空状态
/// 设计思路：顶部渐变 Header 圆弧底部增强品牌感；分类 Tab 区采用彩色图标圆圈样式，
///           每个分类有独立色彩，选中态带渐变填充圆形 + 弹性缩放；结果摘要条
///           展示当前筛选维度与帖子数量；整体配色清新活泼、层次丰富
class Discover_Tidy: UIViewController {

    // MARK: - 分类 Tab 视图包（管理图标圆圈 Tab 的各子视图引用）
    private final class TabBundle_Tidy {
        let container: UIView            // 可点击整体区域
        let circleBg: UIView             // 圆形背景（选中时渐变）
        var circleGrad: CAGradientLayer? // 选中渐变层
        let iconView: UIImageView        // 分类图标
        let nameLabel: UILabel           // 分类名称
        let category: HomeCategory_Tidy

        init(container: UIView, circleBg: UIView,
             iconView: UIImageView, nameLabel: UILabel,
             category: HomeCategory_Tidy) {
            self.container  = container
            self.circleBg   = circleBg
            self.iconView   = iconView
            self.nameLabel  = nameLabel
            self.category   = category
        }
    }

    // MARK: - 数据属性
    private var searchKeyword_Tidy  = ""
    private var selectedCategoryId_Tidy = "all"
    private var categories_Tidy: [HomeCategory_Tidy] = []
    private var displayPosts_Tidy: [TitleModel_Tidy]  = []
    private var searchDebounceTimer_Tidy: Timer?
    private var sortByLikes_Tidy = false
    private var tabBundles_Tidy: [TabBundle_Tidy] = []
    private let pageScrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    private let pageContentView_Tidy = UIView()
    private var postsCollectionHeightConstraint_Tidy: Constraint?
    private let postsGridSectionView_Tidy = UIView()
    private let postsRowsStackView_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - Header（渐变 + 装饰圆 + 标题 + 统计徽章 + 过滤按钮）

    /// Header 阴影载体（在渐变层下方，负责投影，避免 clipsToBounds 冲突）
    private let headerShadow_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.shadowColor  = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.40).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 12)
        v.layer.shadowRadius = 24
        v.layer.shadowOpacity = 1
        return v
    }()

    /// Header 可视容器（裁剪圆角、容纳渐变和内容）
    private let headerView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private var headerGradient_Tidy: CAGradientLayer?

    // --- 装饰圆（提升 alpha，更有视觉冲击力）---
    private let deco1_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        v.layer.cornerRadius = 90
        return v
    }()
    private let deco2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 56
        return v
    }()
    private let deco3_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 36
        return v
    }()
    private let deco4_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 20
        return v
    }()
    // 新增描边环装饰
    private let decoRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 40
        return v
    }()

    // --- 标题 ---
    private let pageTitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Shot Lab"
        lb.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        lb.textColor = .white
        return lb
    }()

    private let pageSubtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.75)
        lb.numberOfLines = 2
        return lb
    }()

    // --- 统计徽章容器（帖子数量 · 分类数量） ---
    private let statsRowView_Tidy: UIView = {
        let v = UIView()
        return v
    }()
    /// 头部右侧预览卡，强化“摄影实验室”氛围
    private let headerPreviewCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 22
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor
        return v
    }()
    private let headerPreviewBadge_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "CURATED"
        lb.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.backgroundColor = UIColor.black.withAlphaComponent(0.16)
        lb.layer.cornerRadius = 8
        lb.clipsToBounds = true
        return lb
    }()
    private let headerPreviewTitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Light + Pose"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        lb.textColor = .white
        return lb
    }()
    private let headerPreviewSubtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Find frames worth saving"
        lb.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.78)
        lb.numberOfLines = 2
        return lb
    }()
    private let statFramesCard_Tidy = UIView()
    private let statCategoriesCard_Tidy = UIView()
    private let statFramesValueLabel_Tidy = UILabel()
    private let statFramesTitleLabel_Tidy = UILabel()
    private let statCategoriesValueLabel_Tidy = UILabel()
    private let statCategoriesTitleLabel_Tidy = UILabel()
    private let statSortValueLabel_Tidy = UILabel()
    private let statSortTitleLabel_Tidy = UILabel()
    private let statSortCard_Tidy = UIView()

    // --- 过滤/排序按钮 ---
    private let filterButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.up.arrow.down",
                             withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.circle.fill",
                             withConfiguration: cfg), for: .selected)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 19
        btn.layer.borderWidth  = 1.2
        btn.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn
    }()

    // MARK: - 搜索卡片（独立浮层，z-order 最高）

    private let searchCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor  = ColorConfig_Tidy.tidyMintDeep_Tidy.withAlphaComponent(0.22).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 18
        v.layer.shadowOpacity = 1
        return v
    }()
    private let searchIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        iv.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let searchTextField_Tidy: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search lighting, pose, edits..."
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.returnKeyType = .search
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    private let searchHintLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "CONTROL CENTER"
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        return lb
    }()

    // MARK: - 分类图标圆圈 Tab 栏

    /// Tab 栏外层背景（白色卡片，带底部阴影线）
    private let tabAreaBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    /// Tab 横向滚动视图
    private let tabScrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.backgroundColor = .clear
        sv.clipsToBounds = true
        return sv
    }()

    /// Tab 项水平排列的 StackView
    private let tabStackView_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.distribution = .fill   // 每个 item 有固定宽度，fill 不强制均分
        return sv
    }()

    /// Tab 区底部分隔线
    private let tabDivider_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }()

    // MARK: - 结果摘要条（白色卡片样式，带阴影）

    private let resultStrip_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return v
    }()
    /// 摘要内容容器（白色小卡片）
    private let resultCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 10
        v.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.layer.shadowOpacity = 1
        return v
    }()
    private let resultDot_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        v.layer.cornerRadius = 5
        return v
    }()
    private let resultCategoryLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let resultCountLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()
    private let resultModeBadge_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textAlignment = .center
        lb.textColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        lb.backgroundColor = UIColor.white
        lb.layer.cornerRadius = 10
        lb.layer.borderWidth = 1
        lb.layer.borderColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.12).cgColor
        lb.clipsToBounds = true
        return lb
    }()

    // MARK: - 帖子网格
    private var postsCollectionView_Tidy: UICollectionView!

    // MARK: - 空状态视图
    private let emptyStateView_Tidy: UIView = { let v = UIView(); v.isHidden = true; return v }()
    private let emptyBgCircle_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.06)
        v.layer.cornerRadius = 72
        return v
    }()
    private let emptyIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "square.stack.3d.up.slash",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 36, weight: .light))
        iv.tintColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.55)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let emptyTitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Nothing found"
        lb.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        lb.textAlignment = .center
        return lb
    }()
    private let emptySubLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Try another shooting keyword or category"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    private let emptyClearButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Clear Search", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        btn.layer.cornerRadius = 20
        btn.contentEdgeInsets = UIEdgeInsets(top: 11, left: 28, bottom: 11, right: 28)
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        loadCategories_Tidy()
        setupPageScrollContainer_Tidy()
        // 搭建顺序决定 z-order，越晚添加越在上层
        buildPostsGrid_Tidy()
        buildEmptyState_Tidy()
        buildResultStrip_Tidy()
        buildCategoryIconTabs_Tidy()
        buildHeaderShadow_Tidy()
        buildHeader_Tidy()
        buildSearchCard_Tidy()  // 最后添加，z-order 最高
        loadPosts_Tidy()
        listenNotifications_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 而非直接赋值，保证 UINavigationController 内部状态同步
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadPosts_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Tidy?.frame = headerView_Tidy.bounds
        // 更新 tab 圆形渐变尺寸
        tabBundles_Tidy.forEach { bundle in
            bundle.circleGrad?.frame = bundle.circleBg.bounds
        }
        updatePostsCollectionHeight_Tidy()
    }

    // MARK: - 数据加载

    private func loadCategories_Tidy() {
        categories_Tidy = TitleViewModel_Tidy.shared_Tidy.getCategories_Tidy()
    }

    /// 根据关键词、分类、排序状态刷新帖子列表
    private func loadPosts_Tidy() {
        var result = TitleViewModel_Tidy.shared_Tidy.filterPosts_Tidy(
            keyword_tidy: searchKeyword_Tidy,
            category_tidy: selectedCategoryId_Tidy
        )
        if sortByLikes_Tidy {
            result = result.sorted { $0.likes_Tidy > $1.likes_Tidy }
        }
        displayPosts_Tidy = result
        refreshDisplay_Tidy(animated: true)
    }

    // MARK: - 通知

    private func listenNotifications_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleDataChanged_Tidy),
            name: TitleViewModel_Tidy.titleStateDidChangeNotification_Tidy, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onHomeCategoryPicked_Tidy(_:)),
            name: Notification.Name("HomeDidSelectCategory_Tidy"), object: nil
        )
    }

    @objc private func onTitleDataChanged_Tidy() { loadPosts_Tidy() }

    @objc private func onHomeCategoryPicked_Tidy(_ n: Notification) {
        guard let id = n.object as? String else { return }
        selectedCategoryId_Tidy = id
        loadPosts_Tidy()
        refreshAllTabStates_Tidy(animated: true)
        // 滚动到选中 Tab
        if let bundle = tabBundles_Tidy.first(where: { $0.category.id_Tidy == id }) {
            let containerFrame = tabScrollView_Tidy.convert(
                bundle.container.frame, from: tabStackView_Tidy
            )
            tabScrollView_Tidy.scrollRectToVisible(containerFrame, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        searchDebounceTimer_Tidy?.invalidate()
    }

    // MARK: - UI 搭建

    /// 搭建内容滚动容器
    /// 功能：固定顶部头图与搜索卡，仅让下方内容层独立滚动
    /// 参数：无
    /// 返回值：无
    private func setupPageScrollContainer_Tidy() {
        view.addSubview(pageScrollView_Tidy)
        pageScrollView_Tidy.addSubview(pageContentView_Tidy)

        let refresh_Tidy = UIRefreshControl()
        refresh_Tidy.tintColor = ColorConfig_Tidy.tidyMint_Tidy
        refresh_Tidy.addTarget(self, action: #selector(onPullRefresh_Tidy(_:)), for: .valueChanged)
        pageScrollView_Tidy.refreshControl = refresh_Tidy

        pageScrollView_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        pageContentView_Tidy.snp.makeConstraints { make in
            make.edges.equalTo(pageScrollView_Tidy.contentLayoutGuide)
            make.width.equalTo(pageScrollView_Tidy.frameLayoutGuide)
        }
    }

    /// 搭建帖子双列网格（最底层）
    private func buildPostsGrid_Tidy() {
        pageContentView_Tidy.addSubview(postsGridSectionView_Tidy)
        postsGridSectionView_Tidy.addSubview(postsRowsStackView_Tidy)

        postsRowsStackView_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
        }
    }

    /// 搭建空状态视图
    private func buildEmptyState_Tidy() {
        pageContentView_Tidy.addSubview(emptyStateView_Tidy)
        emptyStateView_Tidy.addSubview(emptyBgCircle_Tidy)
        emptyStateView_Tidy.addSubview(emptyIconView_Tidy)
        emptyStateView_Tidy.addSubview(emptyTitleLabel_Tidy)
        emptyStateView_Tidy.addSubview(emptySubLabel_Tidy)
        emptyStateView_Tidy.addSubview(emptyClearButton_Tidy)

        emptyStateView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(postsGridSectionView_Tidy).offset(40)
            make.width.equalToSuperview().multipliedBy(0.72)
        }
        emptyBgCircle_Tidy.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(144)
        }
        emptyIconView_Tidy.snp.makeConstraints { make in
            make.center.equalTo(emptyBgCircle_Tidy)
            make.width.height.equalTo(52)
        }
        emptyTitleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(emptyBgCircle_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        emptySubLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Tidy.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
        emptyClearButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(emptySubLabel_Tidy.snp.bottom).offset(22)
            make.centerX.bottom.equalToSuperview()
        }
        emptyClearButton_Tidy.addTarget(self, action: #selector(onClearSearch_Tidy),
                                            for: .touchUpInside)
    }

    /// 搭建结果摘要条（白色小卡片内嵌分类色圆点 + 文字）
    private func buildResultStrip_Tidy() {
        resultCard_Tidy.addSubview(resultDot_Tidy)
        resultCard_Tidy.addSubview(resultCategoryLabel_Tidy)
        resultCard_Tidy.addSubview(resultCountLabel_Tidy)
        resultStrip_Tidy.addSubview(resultCard_Tidy)
        resultStrip_Tidy.addSubview(resultModeBadge_Tidy)

        pageContentView_Tidy.addSubview(resultStrip_Tidy)

        resultCard_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(34)
            make.trailing.lessThanOrEqualTo(resultModeBadge_Tidy.snp.leading).offset(-10)
        }
        resultModeBadge_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.greaterThanOrEqualTo(88)
        }
        resultDot_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }
        resultCategoryLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(resultDot_Tidy.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        resultCountLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(resultCategoryLabel_Tidy.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }
        // top 约束在 buildCategoryIconTabs 里设置
        resultStrip_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }

    /// 搭建分类图标圆圈 Tab 栏
    private func buildCategoryIconTabs_Tidy() {
        pageContentView_Tidy.addSubview(tabAreaBg_Tidy)
        tabAreaBg_Tidy.addSubview(tabScrollView_Tidy)
        tabAreaBg_Tidy.addSubview(tabDivider_Tidy)
        tabScrollView_Tidy.addSubview(tabStackView_Tidy)

        tabAreaBg_Tidy.layer.cornerRadius = 24
        tabAreaBg_Tidy.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        tabAreaBg_Tidy.layer.shadowOffset = CGSize(width: 0, height: 12)
        tabAreaBg_Tidy.layer.shadowRadius = 22
        tabAreaBg_Tidy.layer.shadowOpacity = 1

        // 创建每个分类的图标 Tab 项
        createTabItems_Tidy()

        tabAreaBg_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(84)
        }
        tabScrollView_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        tabDivider_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-1)
            make.height.equalTo(1)
        }

        // 使用内容布局导向约束横向内容，避免标签宽度超出时从两侧溢出显示
        tabStackView_Tidy.snp.makeConstraints { make in
            make.edges.equalTo(tabScrollView_Tidy.contentLayoutGuide)
            make.height.equalTo(tabScrollView_Tidy.frameLayoutGuide)
        }

        // 结果摘要条紧贴 Tab 区下方
        resultStrip_Tidy.snp.makeConstraints { make in
            make.top.equalTo(tabAreaBg_Tidy.snp.bottom).offset(6)
        }
        // 更新帖子网格 top = resultStrip.bottom（稍后在 buildSearchCard 中设置最终约束）
        postsGridSectionView_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(resultStrip_Tidy.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyStateView_Tidy.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(postsGridSectionView_Tidy).offset(20)
            make.width.equalToSuperview().multipliedBy(0.72)
        }
    }

    /// 批量创建分类图标 Tab 项并加入 StackView
    private func createTabItems_Tidy() {
        for (idx, cat) in categories_Tidy.enumerated() {
            let catColor = ColorConfig_Tidy.colorForCategory_Tidy(cat.id_Tidy)

            // 可点击整体区域
            let container = UIView()
            container.isUserInteractionEnabled = true

            // 胶片标签底板
            let circleBg = UIView()
            circleBg.layer.cornerRadius = 22
            circleBg.clipsToBounds = false
            circleBg.backgroundColor = UIColor(hexstring_Tidy: "#EEF2FF")

            // 图标
            let iconView = UIImageView()
            let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            iconView.image = UIImage(systemName: cat.iconName_Tidy, withConfiguration: cfg)
            iconView.tintColor = catColor
            iconView.contentMode = .scaleAspectFit

            // 分类名称
            let nameLabel = UILabel()
            nameLabel.text = cat.name_Tidy
            nameLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            nameLabel.textColor = ColorConfig_Tidy.textSecondary_Tidy
            nameLabel.textAlignment = .center
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.8

            container.addSubview(circleBg)
            container.addSubview(iconView)
            container.addSubview(nameLabel)

            circleBg.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(48)
            }
            iconView.snp.makeConstraints { make in
                make.leading.equalTo(circleBg).offset(12)
                make.centerY.equalTo(circleBg)
                make.width.height.equalTo(18)
            }
            nameLabel.snp.makeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(8)
                make.trailing.equalTo(circleBg).offset(-12)
                make.centerY.equalTo(circleBg)
            }
            let itemWidth_tidy = cat.id_Tidy == "all" ? 88 : 132
            container.snp.makeConstraints { make in
                make.width.equalTo(itemWidth_tidy)
                make.height.equalTo(66)
            }

            // 绑定点击手势，用 tag 标记 index
            let tap = UITapGestureRecognizer(target: self,
                                             action: #selector(onTabItemTapped_Tidy(_:)))
            container.addGestureRecognizer(tap)
            container.tag = idx

            tabStackView_Tidy.addArrangedSubview(container)

            let bundle = TabBundle_Tidy(
                container: container,
                circleBg: circleBg,
                iconView: iconView,
                nameLabel: nameLabel,
                category: cat
            )
            tabBundles_Tidy.append(bundle)
        }
        // 延迟一帧更新初始选中态（等布局完成）
        DispatchQueue.main.async { [weak self] in
            self?.refreshAllTabStates_Tidy(animated: false)
        }
    }

    /// 搭建 Header 阴影载体（z-order 在 headerView 下方）
    private func buildHeaderShadow_Tidy() {
        view.addSubview(headerShadow_Tidy)
        headerShadow_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }

    /// 搭建顶部渐变 Header（三色对角渐变，视觉更活泼）
    private func buildHeader_Tidy() {
        view.addSubview(headerView_Tidy)
        headerView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        // 多色斜向渐变：镜头蓝 → 深夜蓝 → 暮光紫（增强摄影氛围）
        let grad = CAGradientLayer()
        grad.colors = [
            ColorConfig_Tidy.tidyMint_Tidy.cgColor,
            ColorConfig_Tidy.tidyMintDeep_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor
        ]
        grad.locations = [0.0, 0.58, 1.0]
        grad.startPoint = CGPoint(x: 0.0, y: 0.0)
        grad.endPoint   = CGPoint(x: 1.0, y: 1.0)
        headerView_Tidy.layer.insertSublayer(grad, at: 0)
        headerGradient_Tidy = grad

        // 装饰圆和描边环
        headerView_Tidy.addSubview(deco1_Tidy)
        deco1_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(54)
            make.width.height.equalTo(180)
        }
        headerView_Tidy.addSubview(deco2_Tidy)
        deco2_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(112)
        }
        headerView_Tidy.addSubview(deco3_Tidy)
        deco3_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.width.height.equalTo(72)
        }
        headerView_Tidy.addSubview(deco4_Tidy)
        deco4_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(78)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.width.height.equalTo(40)
        }
        headerView_Tidy.addSubview(decoRing_Tidy)
        decoRing_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(44)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
            make.width.height.equalTo(80)
        }

        // 标题区
        headerView_Tidy.addSubview(pageTitleLabel_Tidy)
        headerView_Tidy.addSubview(pageSubtitleLabel_Tidy)
        headerView_Tidy.addSubview(headerPreviewCard_Tidy)
        headerView_Tidy.addSubview(statsRowView_Tidy)

        headerPreviewCard_Tidy.addSubview(headerPreviewBadge_Tidy)
        headerPreviewCard_Tidy.addSubview(headerPreviewTitleLabel_Tidy)
        headerPreviewCard_Tidy.addSubview(headerPreviewSubtitleLabel_Tidy)

        [statFramesCard_Tidy, statCategoriesCard_Tidy, statSortCard_Tidy].forEach {
            statsRowView_Tidy.addSubview($0)
        }
        setupHeaderStatCard_Tidy(
            card_Tidy: statFramesCard_Tidy,
            valueLabel_Tidy: statFramesValueLabel_Tidy,
            titleLabel_Tidy: statFramesTitleLabel_Tidy
        )
        setupHeaderStatCard_Tidy(
            card_Tidy: statCategoriesCard_Tidy,
            valueLabel_Tidy: statCategoriesValueLabel_Tidy,
            titleLabel_Tidy: statCategoriesTitleLabel_Tidy
        )
        setupHeaderStatCard_Tidy(
            card_Tidy: statSortCard_Tidy,
            valueLabel_Tidy: statSortValueLabel_Tidy,
            titleLabel_Tidy: statSortTitleLabel_Tidy
        )

        pageTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.trailing.lessThanOrEqualTo(headerPreviewCard_Tidy.snp.leading).offset(-12)
        }
        pageSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(pageTitleLabel_Tidy)
            make.top.equalTo(pageTitleLabel_Tidy.snp.bottom).offset(6)
            make.trailing.lessThanOrEqualTo(headerPreviewCard_Tidy.snp.leading).offset(-12)
        }
        headerPreviewCard_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.width.equalTo(146)
            make.height.equalTo(104)
        }
        headerPreviewBadge_Tidy.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(12)
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(56)
        }
        headerPreviewTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalTo(headerPreviewSubtitleLabel_Tidy.snp.top).offset(-5)
        }
        headerPreviewSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(headerPreviewTitleLabel_Tidy)
            make.trailing.equalTo(headerPreviewTitleLabel_Tidy)
            make.bottom.equalToSuperview().offset(-14)
        }
        statsRowView_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(headerPreviewCard_Tidy.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-34)
            make.height.equalTo(60)
        }
        statFramesCard_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        statCategoriesCard_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(statFramesCard_Tidy.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(statFramesCard_Tidy)
        }
        statSortCard_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(statCategoriesCard_Tidy.snp.trailing).offset(10)
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(statFramesCard_Tidy)
        }

        // 同步 shadow 载体高度
        headerShadow_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(headerView_Tidy)
        }
    }

    /// 搭建悬浮搜索卡片（最后添加，z-order 最高）
    /// centerY 对齐 headerView 底边，形成跨区悬浮效果
    private func buildSearchCard_Tidy() {
        searchCard_Tidy.addSubview(searchHintLabel_Tidy)
        searchCard_Tidy.addSubview(searchIcon_Tidy)
        searchCard_Tidy.addSubview(searchTextField_Tidy)
        searchCard_Tidy.addSubview(filterButton_Tidy)
        view.addSubview(searchCard_Tidy)

        searchHintLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
        }
        searchIcon_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(17)
        }
        searchTextField_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Tidy.snp.trailing).offset(8)
            make.trailing.equalTo(filterButton_Tidy.snp.leading).offset(-10)
            make.centerY.equalTo(searchIcon_Tidy)
        }
        filterButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(searchIcon_Tidy)
            make.width.height.equalTo(40)
        }
        searchCard_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(headerView_Tidy.snp.bottom)
            make.height.equalTo(72)
        }

        // Tab 区紧在搜索卡片下方
        tabAreaBg_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
        }

        pageScrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(searchCard_Tidy.snp.bottom).offset(12)
        }

        filterButton_Tidy.addTarget(self, action: #selector(onFilterTapped_Tidy), for: .touchUpInside)
        updateSortButtonAppearance_Tidy(animated_Tidy: false)
        searchTextField_Tidy.delegate = self
        searchTextField_Tidy.addTarget(self, action: #selector(onSearchTextChanged_Tidy(_:)),
                                           for: .editingChanged)
    }

    /// 配置头部统计卡片样式
    /// 参数：
    /// - card_Tidy: 统计卡片容器
    /// - valueLabel_Tidy: 数值标签
    /// - titleLabel_Tidy: 标题标签
    /// 返回值：无
    private func setupHeaderStatCard_Tidy(card_Tidy: UIView,
                                          valueLabel_Tidy: UILabel,
                                          titleLabel_Tidy: UILabel) {
        card_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        card_Tidy.layer.cornerRadius = 18
        card_Tidy.layer.borderWidth = 1
        card_Tidy.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor

        valueLabel_Tidy.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        valueLabel_Tidy.textColor = .white
        valueLabel_Tidy.textAlignment = .center

        titleLabel_Tidy.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        titleLabel_Tidy.textColor = UIColor.white.withAlphaComponent(0.74)
        titleLabel_Tidy.textAlignment = .center

        card_Tidy.addSubview(valueLabel_Tidy)
        card_Tidy.addSubview(titleLabel_Tidy)
        valueLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.top.equalTo(valueLabel_Tidy.snp.bottom).offset(2)
        }
    }

    /// 更新排序按钮视觉状态
    /// 参数：
    /// - animated_Tidy: 是否使用动画切换
    /// 返回值：无
    private func updateSortButtonAppearance_Tidy(animated_Tidy: Bool) {
        let updateBlock_Tidy = {
            self.filterButton_Tidy.isSelected = self.sortByLikes_Tidy
            self.filterButton_Tidy.tintColor = self.sortByLikes_Tidy ? .white : ColorConfig_Tidy.primaryGradientStart_Tidy
            self.filterButton_Tidy.backgroundColor = self.sortByLikes_Tidy
                ? ColorConfig_Tidy.primaryGradientStart_Tidy
                : UIColor(hexstring_Tidy: "#F4F7FF")
            self.filterButton_Tidy.layer.borderColor = self.sortByLikes_Tidy
                ? ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor
                : ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.14).cgColor
        }
        guard animated_Tidy else {
            updateBlock_Tidy()
            return
        }
        UIView.animate(withDuration: 0.22, animations: updateBlock_Tidy)
    }

    /// 同步帖子列表高度到内容尺寸
    /// 功能：关闭 CollectionView 自身滚动后，使用内容高度驱动整页滚动
    /// 参数：无
    /// 返回值：无
    private func updatePostsCollectionHeight_Tidy() {
        // 整页滚动模式下帖子区改为静态网格，不再依赖 CollectionView 高度联动
    }

    /// 渲染整页滚动模式下的帖子双列网格
    /// 功能：将帖子数据转为静态双列卡片布局，避免嵌套滚动导致的高度与遮盖问题
    /// 参数：无
    /// 返回值：无
    private func renderPostsGrid_Tidy() {
        postsRowsStackView_Tidy.arrangedSubviews.forEach { row_Tidy in
            postsRowsStackView_Tidy.removeArrangedSubview(row_Tidy)
            row_Tidy.removeFromSuperview()
        }

        guard !displayPosts_Tidy.isEmpty else { return }

        let cardHeight_Tidy: CGFloat = 198
        var index_Tidy = 0
        while index_Tidy < displayPosts_Tidy.count {
            let rowView_Tidy = UIView()
            rowView_Tidy.snp.makeConstraints { make in
                make.height.equalTo(cardHeight_Tidy)
            }

            let leftCard_Tidy = PostCardCell_Tidy(frame: .zero)
            configurePostCardCell_Tidy(cell_Tidy: leftCard_Tidy, post_Tidy: displayPosts_Tidy[index_Tidy])
            rowView_Tidy.addSubview(leftCard_Tidy)

            leftCard_Tidy.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.top.bottom.equalToSuperview()
            }

            let rightHolder_Tidy: UIView
            if index_Tidy + 1 < displayPosts_Tidy.count {
                let rightCard_Tidy = PostCardCell_Tidy(frame: .zero)
                configurePostCardCell_Tidy(cell_Tidy: rightCard_Tidy, post_Tidy: displayPosts_Tidy[index_Tidy + 1])
                rowView_Tidy.addSubview(rightCard_Tidy)
                rightHolder_Tidy = rightCard_Tidy
                rightCard_Tidy.snp.makeConstraints { make in
                    make.leading.equalTo(leftCard_Tidy.snp.trailing).offset(12)
                    make.trailing.equalToSuperview().offset(-16)
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(leftCard_Tidy)
                }
            } else {
                let spacerView_Tidy = UIView()
                spacerView_Tidy.backgroundColor = .clear
                rowView_Tidy.addSubview(spacerView_Tidy)
                rightHolder_Tidy = spacerView_Tidy
                spacerView_Tidy.snp.makeConstraints { make in
                    make.leading.equalTo(leftCard_Tidy.snp.trailing).offset(12)
                    make.trailing.equalToSuperview().offset(-16)
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(leftCard_Tidy)
                }
            }

            leftCard_Tidy.snp.makeConstraints { make in
                make.trailing.equalTo(rightHolder_Tidy.snp.leading).offset(-12)
            }

            postsRowsStackView_Tidy.addArrangedSubview(rowView_Tidy)
            rowView_Tidy.animateSlideInFromBottom_Tidy(
                offset_Tidy: 24,
                delay_Tidy: Double(index_Tidy % 4) * AnimationConfig_Tidy.delayShort_Tidy
            )
            index_Tidy += 2
        }
    }

    /// 配置帖子卡片交互和数据
    /// 参数：
    /// - cell_Tidy: 待配置的帖子卡片
    /// - post_Tidy: 帖子数据模型
    /// 返回值：无
    private func configurePostCardCell_Tidy(cell_Tidy: PostCardCell_Tidy, post_Tidy: TitleModel_Tidy) {
        cell_Tidy.configure_Tidy(post_tidy: post_Tidy, style_tidy: .discoverStyle_tidy)
        cell_Tidy.onLikeTapped_Tidy = {
            guard UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy else {
                Navigation_Tidy.toLogin_Tidy(style_tidy: .present_tidy)
                return
            }
            Task { @MainActor in
                TitleViewModel_Tidy.shared_Tidy.likePost_Tidy(post_tidy: post_Tidy)
            }
        }
        cell_Tidy.onCardTapped_Tidy = {
            Navigation_Tidy.toTitleDetail_Tidy(titleModel_tidy: post_Tidy)
        }
        cell_Tidy.onAvatarTapped_Tidy = { userId_tidy in
            guard !UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(userId_tidy: userId_tidy) else { return }
            let userModel_tidy = UserViewModel_Tidy.shared_Tidy.getUserById_Tidy(userId_tidy: userId_tidy)
            Navigation_Tidy.toUserInfo_Tidy(with: userModel_tidy)
        }
        cell_Tidy.onMoreTapped_Tidy = { [weak self] postModel_tidy in
            guard let self = self else { return }
            let isMyPost_tidy = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
                userId_tidy: postModel_tidy.titleUserId_Tidy
            )
            if isMyPost_tidy {
                ReportDeleteHelper_Tidy.delete_Tidy(post_Tidy: postModel_tidy, from: self) { [weak self] in
                    self?.loadPosts_Tidy()
                }
            } else {
                ReportDeleteHelper_Tidy.report_Tidy(post_Tidy: postModel_tidy, from: self) { [weak self] in
                    self?.loadPosts_Tidy()
                }
            }
        }
    }

    // MARK: - 数据展示刷新

    /// 刷新帖子列表与空状态（animated: 是否淡入动画）
    private func refreshDisplay_Tidy(animated: Bool) {
        let empty = displayPosts_Tidy.isEmpty
        let count = displayPosts_Tidy.count
        let catName = categories_Tidy.first(where: {
            $0.id_Tidy == selectedCategoryId_Tidy
        })?.name_Tidy ?? "All"
        let catColor = ColorConfig_Tidy.colorForCategory_Tidy(selectedCategoryId_Tidy)

        // 副标题
        pageSubtitleLabel_Tidy.text = empty
            ? "Try another angle,\nkeyword, or category."
            : "\(count) frame\(count == 1 ? "" : "s") ready for your next shot plan."

        headerPreviewTitleLabel_Tidy.text = selectedCategoryId_Tidy == "all" ? "Light + Pose" : "\(catName) Focus"
        headerPreviewSubtitleLabel_Tidy.text = empty
            ? "Reset filters to unlock more inspiration."
            : "Curated ideas for \(catName.lowercased()) scenes."
        statFramesValueLabel_Tidy.text = "\(count)"
        statFramesTitleLabel_Tidy.text = "Frames"
        statCategoriesValueLabel_Tidy.text = "\(max(categories_Tidy.count - 1, 0))"
        statCategoriesTitleLabel_Tidy.text = "Topics"
        statSortValueLabel_Tidy.text = sortByLikes_Tidy ? "Hot First" : "Curated"
        statSortTitleLabel_Tidy.text = "Sorting"

        // 结果摘要条
        resultDot_Tidy.backgroundColor = catColor
        resultCategoryLabel_Tidy.text = catName
        resultCountLabel_Tidy.text = "·  \(count) frame\(count == 1 ? "" : "s")"
        resultModeBadge_Tidy.text = sortByLikes_Tidy ? "HOT FIRST" : "CURATED"
        resultModeBadge_Tidy.textColor = sortByLikes_Tidy ? .white : ColorConfig_Tidy.primaryGradientStart_Tidy
        resultModeBadge_Tidy.backgroundColor = sortByLikes_Tidy
            ? ColorConfig_Tidy.primaryGradientStart_Tidy
            : UIColor.white
        resultModeBadge_Tidy.layer.borderColor = (sortByLikes_Tidy
            ? ColorConfig_Tidy.primaryGradientStart_Tidy
            : ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.12)).cgColor

        renderPostsGrid_Tidy()
        if empty {
            emptyStateView_Tidy.isHidden = false
            emptyStateView_Tidy.animateSpringScaleIn_Tidy()
        } else {
            emptyStateView_Tidy.isHidden = true
            if animated { postsGridSectionView_Tidy.animateFadeIn_Tidy(duration_Tidy: 0.22) }
        }
    }

    /// 刷新所有 Tab 的选中 / 非选中视觉状态
    private func refreshAllTabStates_Tidy(animated: Bool) {
        for bundle in tabBundles_Tidy {
            let selected = bundle.category.id_Tidy == selectedCategoryId_Tidy
            applyTabState_Tidy(bundle: bundle, isSelected: selected, animated: animated)
        }
    }

    /// 为单个 Tab 应用选中或未选中样式
    /// 参数：
    /// - bundle: Tab 视图组合
    /// - isSelected: 是否选中
    /// - animated: 是否动画
    private func applyTabState_Tidy(bundle: TabBundle_Tidy,
                                        isSelected: Bool,
                                        animated: Bool) {
        let catColor = ColorConfig_Tidy.colorForCategory_Tidy(bundle.category.id_Tidy)

        let block = {
            if isSelected {
                // 移除旧渐变，添加新渐变
                bundle.circleGrad?.removeFromSuperlayer()
                let grad = CAGradientLayer()
                let sz = bundle.circleBg.bounds.isEmpty
                    ? CGRect(x: 0, y: 0, width: 120, height: 44)
                    : bundle.circleBg.bounds
                grad.frame = sz
                grad.colors = [catColor.cgColor,
                               catColor.withAlphaComponent(0.75).cgColor]
                grad.startPoint = CGPoint(x: 0.1, y: 0)
                grad.endPoint   = CGPoint(x: 1, y: 1)
                grad.cornerRadius = sz.height / 2
                bundle.circleBg.layer.insertSublayer(grad, at: 0)
                bundle.circleGrad = grad
                bundle.circleBg.backgroundColor = .clear
                // 选中态：清除边框，加光晕阴影
                bundle.circleBg.layer.borderWidth  = 0
                bundle.circleBg.layer.shadowColor  = catColor.cgColor
                bundle.circleBg.layer.shadowOffset = CGSize(width: 0, height: 6)
                bundle.circleBg.layer.shadowRadius = 12
                bundle.circleBg.layer.shadowOpacity = 0.22

                bundle.iconView.tintColor = .white
                bundle.nameLabel.textColor = .white
                bundle.nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                bundle.container.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } else {
                bundle.circleGrad?.removeFromSuperlayer()
                bundle.circleGrad = nil
                // 未选中态：浅色标签 + 柔和描边
                bundle.circleBg.backgroundColor = UIColor.white
                bundle.circleBg.layer.borderWidth  = 1
                bundle.circleBg.layer.borderColor  = catColor.withAlphaComponent(0.18).cgColor
                bundle.circleBg.layer.shadowOpacity = 0

                bundle.iconView.tintColor = catColor
                bundle.nameLabel.textColor = ColorConfig_Tidy.textSecondary_Tidy
                bundle.nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                bundle.container.transform = .identity
            }
        }

        if animated {
            UIView.animate(
                withDuration: AnimationConfig_Tidy.durationSpring_Tidy,
                delay: 0,
                usingSpringWithDamping: AnimationConfig_Tidy.springDampingNormal_Tidy,
                initialSpringVelocity: AnimationConfig_Tidy.springVelocity_Tidy,
                options: [.curveEaseOut],
                animations: block
            )
        } else {
            block()
        }
    }

    // MARK: - 用户交互事件

    /// 分类 Tab 点击（通过 container.tag 定位 index）
    @objc private func onTabItemTapped_Tidy(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view else { return }
        let idx = container.tag
        guard idx < categories_Tidy.count else { return }
        let cat = categories_Tidy[idx]
        guard cat.id_Tidy != selectedCategoryId_Tidy else { return }

        view.endEditing(true)
        selectedCategoryId_Tidy = cat.id_Tidy
        loadPosts_Tidy()
        refreshAllTabStates_Tidy(animated: true)

        // 点击动画反馈
        let bundle = tabBundles_Tidy[idx]
        bundle.container.animatePressDown_Tidy { [weak bundle] in
            bundle?.container.animatePressUp_Tidy()
        }

    }

    /// 过滤/排序按钮切换（按点赞数排序）
    @objc private func onFilterTapped_Tidy() {
        sortByLikes_Tidy.toggle()
        filterButton_Tidy.animatePulse_Tidy()
        updateSortButtonAppearance_Tidy(animated_Tidy: true)
        loadPosts_Tidy()
    }

    /// 搜索框内容变化（防抖 0.28s 触发）
    @objc private func onSearchTextChanged_Tidy(_ tf: UITextField) {
        searchDebounceTimer_Tidy?.invalidate()
        searchDebounceTimer_Tidy = Timer.scheduledTimer(withTimeInterval: 0.28,
                                                            repeats: false) { [weak self] _ in
            guard let self else { return }
            self.searchKeyword_Tidy = tf.text ?? ""
            self.loadPosts_Tidy()
        }
        let hasText = !(tf.text?.isEmpty ?? true)
        UIView.animate(withDuration: 0.18) {
            self.searchIcon_Tidy.tintColor = hasText
                ? ColorConfig_Tidy.tidyMint_Tidy
                : ColorConfig_Tidy.textPlaceholder_Tidy
        }
    }

    @objc private func onPullRefresh_Tidy(_ sender: UIRefreshControl) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            loadPosts_Tidy()
            sender.endRefreshing()
        }
    }

    @objc private func onClearSearch_Tidy() {
        searchTextField_Tidy.text = ""
        searchKeyword_Tidy = ""
        searchTextField_Tidy.resignFirstResponder()
        loadPosts_Tidy()
        emptyClearButton_Tidy.animatePressDown_Tidy { [weak self] in
            self?.emptyClearButton_Tidy.animatePressUp_Tidy()
        }
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Tidy: UITextFieldDelegate {

    func textFieldShouldReturn(_ tf: UITextField) -> Bool {
        tf.resignFirstResponder(); return true
    }

    func textFieldDidBeginEditing(_ tf: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Tidy.durationFast_Tidy) {
            self.searchCard_Tidy.layer.shadowColor =
                ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.32).cgColor
            self.searchCard_Tidy.layer.shadowRadius = 22
            self.searchCard_Tidy.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
        }
    }

    func textFieldDidEndEditing(_ tf: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Tidy.durationFast_Tidy) {
            self.searchCard_Tidy.layer.shadowColor =
                ColorConfig_Tidy.tidyMintDeep_Tidy.withAlphaComponent(0.22).cgColor
            self.searchCard_Tidy.layer.shadowRadius = 18
            self.searchCard_Tidy.transform = .identity
        }
    }
}

// MARK: - CollectionView DataSource & Delegate（帖子网格）

extension Discover_Tidy: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayPosts_Tidy.count
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: "PostCard", for: indexPath
        ) as! PostCardCell_Tidy
        let post = displayPosts_Tidy[indexPath.item]
        cell.configure_Tidy(post_tidy: post, style_tidy: .discoverStyle_tidy)
        cell.onLikeTapped_Tidy = {
            /// 点赞前先验证登录状态，未登录则跳转登录页
            guard UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy else {
                Navigation_Tidy.toLogin_Tidy(style_tidy: .present_tidy)
                return
            }
            Task { @MainActor in
                TitleViewModel_Tidy.shared_Tidy.likePost_Tidy(post_tidy: post)
            }
        }
        cell.onCardTapped_Tidy = {
            Navigation_Tidy.toTitleDetail_Tidy(titleModel_tidy: post)
        }
        /// 点击作者头像：非当前用户则进入用户中心页
        cell.onAvatarTapped_Tidy = { userId_tidy in
            guard !UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(userId_tidy: userId_tidy) else { return }
            let userModel_tidy = UserViewModel_Tidy.shared_Tidy.getUserById_Tidy(userId_tidy: userId_tidy)
            Navigation_Tidy.toUserInfo_Tidy(with: userModel_tidy)
        }
        // 举报/删除完成后重新拉取数据，刷新帖子列表
        cell.onMoreTapped_Tidy = { [weak self] post_tidy in
            guard let self = self else { return }
            let isMyPost_tidy = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
                userId_tidy: post_tidy.titleUserId_Tidy
            )
            if isMyPost_tidy {
                ReportDeleteHelper_Tidy.delete_Tidy(post_Tidy: post_tidy, from: self) { [weak self] in
                    self?.loadPosts_Tidy()
                }
            } else {
                ReportDeleteHelper_Tidy.report_Tidy(post_Tidy: post_tidy, from: self) { [weak self] in
                    self?.loadPosts_Tidy()
                }
            }
        }
        return cell
    }

    func collectionView(_ cv: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.animateSlideInFromBottom_Tidy(
            offset_Tidy: 24,
            delay_Tidy: Double(indexPath.item % 4) * AnimationConfig_Tidy.delayShort_Tidy
        )
    }
}
