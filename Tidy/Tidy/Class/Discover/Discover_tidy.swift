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
        lb.text = "Discover"
        lb.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        lb.textColor = .white
        return lb
    }()

    private let pageSubtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.75)
        return lb
    }()

    // --- 统计徽章容器（帖子数量 · 分类数量） ---
    private let statsRowView_Tidy: UIView = {
        UIView()
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
        v.layer.shadowColor  = UIColor(hexstring_Tidy: "#38B2AC").withAlphaComponent(0.22).cgColor
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
        tf.placeholder = "Search rooms, tips, items..."
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
        sv.clipsToBounds = false
        return sv
    }()

    /// Tab 项水平排列的 StackView
    private let tabStackView_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
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
        lb.text = "Try another keyword or category"
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

    /// 搭建帖子双列网格（最底层）
    private func buildPostsGrid_Tidy() {
        let w = (UIScreen.main.bounds.width - 16 * 2 - 12) / 2
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .absolute(w), heightDimension: .estimated(220))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(220)),
            subitems: [item, item]
        )
        group.interItemSpacing = .fixed(12)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 12, leading: 16, bottom: 120, trailing: 16)
        section.interGroupSpacing = 14

        postsCollectionView_Tidy = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(section: section)
        )
        postsCollectionView_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        postsCollectionView_Tidy.showsVerticalScrollIndicator = false
        postsCollectionView_Tidy.contentInsetAdjustmentBehavior = .never
        postsCollectionView_Tidy.register(PostCardCell_Tidy.self, forCellWithReuseIdentifier: "PostCard")
        postsCollectionView_Tidy.dataSource = self
        postsCollectionView_Tidy.delegate   = self

        let refresh = UIRefreshControl()
        refresh.tintColor = ColorConfig_Tidy.tidyMint_Tidy
        refresh.addTarget(self, action: #selector(onPullRefresh_Tidy(_:)), for: .valueChanged)
        postsCollectionView_Tidy.refreshControl = refresh

        view.addSubview(postsCollectionView_Tidy)
        postsCollectionView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    /// 搭建空状态视图
    private func buildEmptyState_Tidy() {
        view.addSubview(emptyStateView_Tidy)
        emptyStateView_Tidy.addSubview(emptyBgCircle_Tidy)
        emptyStateView_Tidy.addSubview(emptyIconView_Tidy)
        emptyStateView_Tidy.addSubview(emptyTitleLabel_Tidy)
        emptyStateView_Tidy.addSubview(emptySubLabel_Tidy)
        emptyStateView_Tidy.addSubview(emptyClearButton_Tidy)

        emptyStateView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(postsCollectionView_Tidy).offset(40)
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

        view.addSubview(resultStrip_Tidy)

        resultCard_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }
        resultDot_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
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
            make.height.equalTo(42)
        }
    }

    /// 搭建分类图标圆圈 Tab 栏
    private func buildCategoryIconTabs_Tidy() {
        view.addSubview(tabAreaBg_Tidy)
        tabAreaBg_Tidy.addSubview(tabScrollView_Tidy)
        tabAreaBg_Tidy.addSubview(tabDivider_Tidy)
        tabScrollView_Tidy.addSubview(tabStackView_Tidy)

        // 创建每个分类的图标 Tab 项
        createTabItems_Tidy()

        tabAreaBg_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(92)   // 圆圈 48 + 文字 14 + 上下各 15
        }
        tabScrollView_Tidy.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        tabDivider_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        // StackView 必须同时约束四边才能让 UIScrollView 正确计算 contentSize
        // height 固定到 scrollView frame 高度以禁止垂直滚动
        tabStackView_Tidy.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(tabScrollView_Tidy.snp.height)
        }

        // 结果摘要条紧贴 Tab 区下方
        resultStrip_Tidy.snp.makeConstraints { make in
            make.top.equalTo(tabAreaBg_Tidy.snp.bottom)
        }
        // 更新帖子网格 top = resultStrip.bottom（稍后在 buildSearchCard 中设置最终约束）
        postsCollectionView_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(resultStrip_Tidy.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyStateView_Tidy.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(postsCollectionView_Tidy).offset(30)
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

            // 圆形背景
            let circleBg = UIView()
            circleBg.layer.cornerRadius = 24
            circleBg.clipsToBounds = true
            circleBg.backgroundColor = UIColor(hexstring_Tidy: "#F1F5F9")

            // 图标
            let iconView = UIImageView()
            let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            iconView.image = UIImage(systemName: cat.iconName_Tidy, withConfiguration: cfg)
            iconView.tintColor = catColor
            iconView.contentMode = .scaleAspectFit

            // 分类名称
            let nameLabel = UILabel()
            nameLabel.text = cat.name_Tidy
            nameLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            nameLabel.textColor = ColorConfig_Tidy.textSecondary_Tidy
            nameLabel.textAlignment = .center
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.8

            container.addSubview(circleBg)
            container.addSubview(iconView)
            container.addSubview(nameLabel)

            circleBg.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(10)
                make.width.height.equalTo(48)
            }
            iconView.snp.makeConstraints { make in
                make.center.equalTo(circleBg)
                make.width.height.equalTo(20)
            }
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(circleBg.snp.bottom).offset(5)
                make.leading.trailing.equalToSuperview().inset(2)
                make.bottom.lessThanOrEqualToSuperview().offset(-8)
            }
            container.snp.makeConstraints { make in make.width.equalTo(72) }

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

        // 多色斜向渐变：薄荷绿 → 深蓝绿 → 微紫蓝（增加层次感和品牌辨识度）
        let grad = CAGradientLayer()
        grad.colors = [
            UIColor(hexstring_Tidy: "#4ECDC4").cgColor,
            UIColor(hexstring_Tidy: "#2C9E96").cgColor,
            UIColor(hexstring_Tidy: "#2D7DD2").cgColor
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
        headerView_Tidy.addSubview(filterButton_Tidy)

        pageTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
        }
        pageSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(pageTitleLabel_Tidy)
            make.top.equalTo(pageTitleLabel_Tidy.snp.bottom).offset(3)
            // 底部留出空间让搜索卡片居中对齐 header 底边，约 30pt
            make.bottom.equalToSuperview().offset(-30)
        }
        filterButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(pageTitleLabel_Tidy)
            make.width.height.equalTo(38)
        }
        filterButton_Tidy.addTarget(self, action: #selector(onFilterTapped_Tidy), for: .touchUpInside)

        // 同步 shadow 载体高度
        headerShadow_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(headerView_Tidy)
        }
    }

    /// 搭建悬浮搜索卡片（最后添加，z-order 最高）
    /// centerY 对齐 headerView 底边，形成跨区悬浮效果
    private func buildSearchCard_Tidy() {
        searchCard_Tidy.addSubview(searchIcon_Tidy)
        searchCard_Tidy.addSubview(searchTextField_Tidy)
        view.addSubview(searchCard_Tidy)

        searchIcon_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        searchTextField_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Tidy.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        searchCard_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(headerView_Tidy.snp.bottom)
            make.height.equalTo(50)
        }

        // Tab 区紧在搜索卡片下方
        tabAreaBg_Tidy.snp.makeConstraints { make in
            make.top.equalTo(searchCard_Tidy.snp.bottom).offset(8)
        }

        searchTextField_Tidy.delegate = self
        searchTextField_Tidy.addTarget(self, action: #selector(onSearchTextChanged_Tidy(_:)),
                                           for: .editingChanged)
    }

    // MARK: - 数据展示刷新

    /// 刷新帖子列表与空状态（animated: 是否淡入动画）
    private func refreshDisplay_Tidy(animated: Bool) {
        let empty = displayPosts_Tidy.isEmpty
        let count = displayPosts_Tidy.count

        // 副标题
        pageSubtitleLabel_Tidy.text = empty
            ? "No results"
            : "\(count) post\(count == 1 ? "" : "s") found"

        // 结果摘要条
        let catName = categories_Tidy.first(where: {
            $0.id_Tidy == selectedCategoryId_Tidy
        })?.name_Tidy ?? "All"
        let catColor = ColorConfig_Tidy.colorForCategory_Tidy(selectedCategoryId_Tidy)
        resultDot_Tidy.backgroundColor = catColor
        resultCategoryLabel_Tidy.text = catName
        resultCountLabel_Tidy.text = "·  \(count) result\(count == 1 ? "" : "s")"

        postsCollectionView_Tidy.reloadData()
        if empty {
            emptyStateView_Tidy.isHidden = false
            emptyStateView_Tidy.animateSpringScaleIn_Tidy()
        } else {
            emptyStateView_Tidy.isHidden = true
            if animated { postsCollectionView_Tidy.animateFadeIn_Tidy(duration_Tidy: 0.22) }
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
                    ? CGRect(x: 0, y: 0, width: 48, height: 48)
                    : bundle.circleBg.bounds
                grad.frame = sz
                grad.colors = [catColor.cgColor,
                               catColor.withAlphaComponent(0.75).cgColor]
                grad.startPoint = CGPoint(x: 0.1, y: 0)
                grad.endPoint   = CGPoint(x: 1, y: 1)
                grad.cornerRadius = 24
                bundle.circleBg.layer.insertSublayer(grad, at: 0)
                bundle.circleGrad = grad
                bundle.circleBg.backgroundColor = .clear
                // 选中态：清除边框，加光晕阴影
                bundle.circleBg.layer.borderWidth  = 0
                bundle.circleBg.layer.shadowColor  = catColor.cgColor
                bundle.circleBg.layer.shadowOffset = CGSize(width: 0, height: 4)
                bundle.circleBg.layer.shadowRadius = 8
                bundle.circleBg.layer.shadowOpacity = 0.45

                bundle.iconView.tintColor = .white
                bundle.nameLabel.textColor = catColor
                bundle.nameLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                bundle.container.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
            } else {
                bundle.circleGrad?.removeFromSuperlayer()
                bundle.circleGrad = nil
                // 未选中态：浅灰背景 + 分类色描边
                bundle.circleBg.backgroundColor = UIColor(hexstring_Tidy: "#F7FAFC")
                bundle.circleBg.layer.borderWidth  = 1.5
                bundle.circleBg.layer.borderColor  = catColor.withAlphaComponent(0.28).cgColor
                bundle.circleBg.layer.shadowOpacity = 0

                bundle.iconView.tintColor = catColor
                bundle.nameLabel.textColor = ColorConfig_Tidy.textSecondary_Tidy
                bundle.nameLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
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

        if !displayPosts_Tidy.isEmpty {
            postsCollectionView_Tidy.scrollToItem(
                at: IndexPath(item: 0, section: 0), at: .top, animated: true
            )
        }
    }

    /// 过滤/排序按钮切换（按点赞数排序）
    @objc private func onFilterTapped_Tidy() {
        sortByLikes_Tidy.toggle()
        filterButton_Tidy.isSelected = sortByLikes_Tidy
        filterButton_Tidy.animatePulse_Tidy()
        UIView.animate(withDuration: 0.2) {
            self.filterButton_Tidy.backgroundColor = self.sortByLikes_Tidy
                ? UIColor.white.withAlphaComponent(0.38)
                : UIColor.white.withAlphaComponent(0.22)
        }
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
                UIColor(hexstring_Tidy: "#38B2AC").withAlphaComponent(0.22).cgColor
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
