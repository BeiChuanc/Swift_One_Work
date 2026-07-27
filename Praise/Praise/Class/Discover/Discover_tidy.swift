import Foundation
import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页面
/// 功能：固定悬停的渐变 Header（标题 + 真实统计文案 + 内嵌搜索栏）+ 分类胶囊 Tab 栏
///      + 轻量结果摘要行 + 双列帖子网格 + 空状态
/// 设计思路：Header 与搜索栏合并为同一固定区块（不再使用悬浮重叠卡片技巧），层级关系更简单、
///           约束更稳健；分类 Tab 区采用彩色胶囊样式，每个分类有独立色彩，选中态带渐变填充 +
///           弹性缩放；结果摘要行去除多余卡片包裹层，直接展示当前筛选维度与帖子数量；
///           整体配色清新活泼、层次分明
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
    private let postsGridSectionView_Tidy = UIView()
    private let postsRowsStackView_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - Header（渐变 + 装饰圆 + 标题 + 真实统计文案 + 内嵌搜索栏）

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
        lb.font = UIFont.systemFont(ofSize: 22, weight: .heavy)  // 由 32→22，避免排版过大
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

    /// 头部说明文案下方的数据摘要（如 "128 frames · 7 topics ready to explore"），
    /// 取代原来悬浮在 Header 边界上的 "CURATED" 预览卡，减少 Header 复杂度的同时保留真实统计信息
    private let headerStatsLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        lb.numberOfLines = 1
        return lb
    }()

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
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth  = 1.2
        btn.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn
    }()

    // MARK: - 搜索栏（现内嵌于 Header 内部，随 Header 一起固定悬停）

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

    // MARK: - 结果摘要条（白色卡片样式，带阴影）

    private let resultStrip_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return v
    }()
    private let resultDot_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        v.layer.cornerRadius = 4
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
        buildHeader_Tidy()  // 搜索栏已内化在 buildHeader_Tidy 内部搭建
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

    /// 搭建结果摘要条（去除多余卡片包裹层，圆点 + 文字直接铺在页面背景上，更轻量）
    private func buildResultStrip_Tidy() {
        resultStrip_Tidy.addSubview(resultDot_Tidy)
        resultStrip_Tidy.addSubview(resultCategoryLabel_Tidy)
        resultStrip_Tidy.addSubview(resultCountLabel_Tidy)
        resultStrip_Tidy.addSubview(resultModeBadge_Tidy)

        pageContentView_Tidy.addSubview(resultStrip_Tidy)

        resultDot_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        resultCategoryLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(resultDot_Tidy.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        resultCountLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(resultCategoryLabel_Tidy.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(resultModeBadge_Tidy.snp.leading).offset(-10)
        }
        resultModeBadge_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(80)
        }
        // top 约束在 buildCategoryIconTabs 里设置
        resultStrip_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
    }

    /// 搭建分类 Pill 胶囊 Tab 栏（紧凑版，取代原图标圆圈样式）
    /// 设计：透明背景容器 + 横向滚动 StackView + 选中态渐变胶囊 + 未选中白色边框胶囊
    private func buildCategoryIconTabs_Tidy() {
        pageContentView_Tidy.addSubview(tabAreaBg_Tidy)
        tabAreaBg_Tidy.addSubview(tabScrollView_Tidy)
        tabScrollView_Tidy.addSubview(tabStackView_Tidy)

        // 重置为透明背景（无卡片阴影），依靠各 Pill 自身的阴影提供层次感
        tabAreaBg_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        tabAreaBg_Tidy.layer.cornerRadius = 0
        tabAreaBg_Tidy.layer.shadowOpacity = 0

        tabStackView_Tidy.spacing = 8

        createTabItems_Tidy()

        tabAreaBg_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        tabScrollView_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        tabStackView_Tidy.snp.makeConstraints { make in
            make.edges.equalTo(tabScrollView_Tidy.contentLayoutGuide)
            make.height.equalTo(tabScrollView_Tidy.frameLayoutGuide)
        }

        // 结果摘要条紧贴 Tab 区下方
        resultStrip_Tidy.snp.makeConstraints { make in
            make.top.equalTo(tabAreaBg_Tidy.snp.bottom).offset(4)
        }
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

    /// 批量创建 Pill 胶囊 Tab 项（icon + text 横排，紧凑高度 40pt）
    private func createTabItems_Tidy() {
        for (idx, cat) in categories_Tidy.enumerated() {
            let catColor_tidy = ColorConfig_Tidy.colorForCategory_Tidy(cat.id_Tidy)

            // 整体可点击容器
            let container_tidy = UIView()
            container_tidy.isUserInteractionEnabled = true

            // 胶囊背景（未选中态：白色 + 彩色描边）
            let pillBg_tidy = UIView()
            pillBg_tidy.layer.cornerRadius = 20
            pillBg_tidy.clipsToBounds = false
            pillBg_tidy.backgroundColor = .white
            pillBg_tidy.layer.borderWidth = 1.5
            pillBg_tidy.layer.borderColor = catColor_tidy.withAlphaComponent(0.22).cgColor
            pillBg_tidy.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
            pillBg_tidy.layer.shadowOffset = CGSize(width: 0, height: 2)
            pillBg_tidy.layer.shadowRadius = 6
            pillBg_tidy.layer.shadowOpacity = 1

            // 图标
            let iconView_tidy = UIImageView()
            let cfg_tidy = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            iconView_tidy.image = UIImage(systemName: cat.iconName_Tidy, withConfiguration: cfg_tidy)
            iconView_tidy.tintColor = catColor_tidy
            iconView_tidy.contentMode = .scaleAspectFit

            // 分类名称
            let nameLabel_tidy = UILabel()
            nameLabel_tidy.text = cat.name_Tidy
            nameLabel_tidy.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            nameLabel_tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy

            container_tidy.addSubview(pillBg_tidy)
            container_tidy.addSubview(iconView_tidy)
            container_tidy.addSubview(nameLabel_tidy)

            pillBg_tidy.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            iconView_tidy.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(12)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(16)
            }
            nameLabel_tidy.snp.makeConstraints { make in
                make.leading.equalTo(iconView_tidy.snp.trailing).offset(6)
                make.trailing.equalToSuperview().offset(-14)
                make.centerY.equalToSuperview()
            }

            // 胶囊宽度：自适应文字（"All" 最小宽，其他根据文字宽度）
            let estimatedW_tidy = cat.id_Tidy == "all" ? 72 : 116
            container_tidy.snp.makeConstraints { make in
                make.width.equalTo(estimatedW_tidy)
                make.height.equalTo(40)
            }

            let tap_tidy = UITapGestureRecognizer(target: self,
                                                  action: #selector(onTabItemTapped_Tidy(_:)))
            container_tidy.addGestureRecognizer(tap_tidy)
            container_tidy.tag = idx

            tabStackView_Tidy.addArrangedSubview(container_tidy)

            let bundle_tidy = TabBundle_Tidy(
                container: container_tidy,
                circleBg: pillBg_tidy,
                iconView: iconView_tidy,
                nameLabel: nameLabel_tidy,
                category: cat
            )
            tabBundles_Tidy.append(bundle_tidy)
        }
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

        // 标题区：主标题 + 真实数据统计文案（取代原悬浮 CURATED 预览卡）
        headerView_Tidy.addSubview(pageTitleLabel_Tidy)
        headerView_Tidy.addSubview(headerStatsLabel_Tidy)
        headerView_Tidy.addSubview(pageSubtitleLabel_Tidy)

        pageTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
        }
        headerStatsLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(pageTitleLabel_Tidy.snp.trailing).offset(10)
            make.centerY.equalTo(pageTitleLabel_Tidy)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        pageSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(pageTitleLabel_Tidy)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
            make.top.equalTo(pageTitleLabel_Tidy.snp.bottom).offset(4)
        }

        // 搜索栏内化到 Header 内部（不再作为悬浮重叠卡片），布局关系更简单直接
        buildInlineSearchBar_Tidy()

        // Header 底部紧随搜索栏，不再需要为悬浮卡片预留额外留白
        headerView_Tidy.snp.makeConstraints { make in
            make.bottom.equalTo(searchCard_Tidy.snp.bottom).offset(18)
        }

        // 同步 shadow 载体高度
        headerShadow_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(headerView_Tidy)
        }

        // 下方滚动内容紧贴 Header 底部，Header 固定悬停、内容独立滚动
        pageScrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerView_Tidy.snp.bottom)
        }
    }

    /// 搭建 Header 内嵌搜索栏（图标 + 输入框 + 排序按钮）
    /// 设计思路：直接铺在渐变 Header 内部，随 Header 一起固定悬停，
    /// 取代旧版"卡片悬浮在 Header 边界上"的重叠技巧，层级关系更清晰、约束更稳健
    private func buildInlineSearchBar_Tidy() {
        headerView_Tidy.addSubview(searchCard_Tidy)
        searchCard_Tidy.addSubview(searchIcon_Tidy)
        searchCard_Tidy.addSubview(searchTextField_Tidy)
        searchCard_Tidy.addSubview(filterButton_Tidy)

        searchCard_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(pageSubtitleLabel_Tidy.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
        searchIcon_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(17)
        }
        searchTextField_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Tidy.snp.trailing).offset(8)
            make.trailing.equalTo(filterButton_Tidy.snp.leading).offset(-10)
            make.centerY.equalTo(searchIcon_Tidy)
        }
        filterButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.centerY.equalTo(searchIcon_Tidy)
            make.width.height.equalTo(36)
        }

        filterButton_Tidy.addTarget(self, action: #selector(onFilterTapped_Tidy), for: .touchUpInside)
        updateSortButtonAppearance_Tidy(animated_Tidy: false)
        searchTextField_Tidy.delegate = self
        searchTextField_Tidy.addTarget(self, action: #selector(onSearchTextChanged_Tidy(_:)),
                                           for: .editingChanged)
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

        // 卡片重构后封面图加高、点赞信息移入图内浮层，整卡高度相应增加
        let cardHeight_Tidy: CGFloat = 234
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
            ? "Try another angle, keyword, or category."
            : "Curated ideas for \(catName.lowercased()) scenes."

        // Header 数据摘要文案（真实统计，取代原悬浮预览卡）
        let topicsCount = max(categories_Tidy.count - 1, 0)
        headerStatsLabel_Tidy.text = "\(count) frame\(count == 1 ? "" : "s") · \(topicsCount) topics"

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
                // 选中态：渐变背景胶囊 + 白色图标/文字 + 彩色光晕
                bundle.circleGrad?.removeFromSuperlayer()
                let sz_tidy = bundle.circleBg.bounds.isEmpty
                    ? CGRect(x: 0, y: 0, width: 110, height: 40)
                    : bundle.circleBg.bounds
                let grad_tidy = CAGradientLayer()
                grad_tidy.frame       = sz_tidy
                grad_tidy.colors      = [catColor.cgColor,
                                          catColor.withAlphaComponent(0.78).cgColor]
                grad_tidy.startPoint  = CGPoint(x: 0, y: 0)
                grad_tidy.endPoint    = CGPoint(x: 1, y: 1)
                grad_tidy.cornerRadius = sz_tidy.height / 2
                bundle.circleBg.layer.insertSublayer(grad_tidy, at: 0)
                bundle.circleGrad = grad_tidy
                bundle.circleBg.backgroundColor = .clear
                bundle.circleBg.layer.borderWidth  = 0
                bundle.circleBg.layer.shadowColor  = catColor.cgColor
                bundle.circleBg.layer.shadowOffset = CGSize(width: 0, height: 4)
                bundle.circleBg.layer.shadowRadius = 10
                bundle.circleBg.layer.shadowOpacity = 0.25

                bundle.iconView.tintColor  = .white
                bundle.nameLabel.textColor = .white
                bundle.nameLabel.font      = UIFont.systemFont(ofSize: 13, weight: .bold)
                bundle.container.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } else {
                // 未选中态：白色胶囊 + 彩色描边 + 彩色图标
                bundle.circleGrad?.removeFromSuperlayer()
                bundle.circleGrad = nil
                bundle.circleBg.backgroundColor    = .white
                bundle.circleBg.layer.borderWidth  = 1.5
                bundle.circleBg.layer.borderColor  = catColor.withAlphaComponent(0.22).cgColor
                bundle.circleBg.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
                bundle.circleBg.layer.shadowOffset = CGSize(width: 0, height: 2)
                bundle.circleBg.layer.shadowRadius = 6
                bundle.circleBg.layer.shadowOpacity = 1

                bundle.iconView.tintColor  = catColor
                bundle.nameLabel.textColor = ColorConfig_Tidy.textPrimary_Tidy
                bundle.nameLabel.font      = UIFont.systemFont(ofSize: 13, weight: .semibold)
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
