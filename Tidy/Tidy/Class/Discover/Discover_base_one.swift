import Foundation
import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页面
/// 功能：彩色品牌 Header + 悬浮搜索卡片 + 图标圆圈分类 Tab 栏 + 结果摘要条 + 双列帖子瀑布流 + 空状态
/// 设计思路：顶部渐变 Header 圆弧底部增强品牌感；分类 Tab 区采用彩色图标圆圈样式，
///           每个分类有独立色彩，选中态带渐变填充圆形 + 弹性缩放；结果摘要条
///           展示当前筛选维度与帖子数量；整体配色清新活泼、层次丰富
class Discover_Base_one: UIViewController {

    // MARK: - 分类 Tab 视图包（管理图标圆圈 Tab 的各子视图引用）
    private final class TabBundle_Base_one {
        let container: UIView            // 可点击整体区域
        let circleBg: UIView             // 圆形背景（选中时渐变）
        var circleGrad: CAGradientLayer? // 选中渐变层
        let iconView: UIImageView        // 分类图标
        let nameLabel: UILabel           // 分类名称
        let category: HomeCategory_Base_one

        init(container: UIView, circleBg: UIView,
             iconView: UIImageView, nameLabel: UILabel,
             category: HomeCategory_Base_one) {
            self.container  = container
            self.circleBg   = circleBg
            self.iconView   = iconView
            self.nameLabel  = nameLabel
            self.category   = category
        }
    }

    // MARK: - 数据属性
    private var searchKeyword_Base_one  = ""
    private var selectedCategoryId_Base_one = "all"
    private var categories_Base_one: [HomeCategory_Base_one] = []
    private var displayPosts_Base_one: [TitleModel_Base_one]  = []
    private var searchDebounceTimer_Base_one: Timer?
    private var sortByLikes_Base_one = false
    private var tabBundles_Base_one: [TabBundle_Base_one] = []

    // MARK: - Header（渐变 + 装饰圆 + 标题 + 统计徽章 + 过滤按钮）

    /// Header 阴影载体（在渐变层下方，负责投影，避免 clipsToBounds 冲突）
    private let headerShadow_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.shadowColor  = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.40).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 12)
        v.layer.shadowRadius = 24
        v.layer.shadowOpacity = 1
        return v
    }()

    /// Header 可视容器（裁剪圆角、容纳渐变和内容）
    private let headerView_Base_one: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private var headerGradient_Base_one: CAGradientLayer?

    // --- 装饰圆（提升 alpha，更有视觉冲击力）---
    private let deco1_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        v.layer.cornerRadius = 90
        return v
    }()
    private let deco2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 56
        return v
    }()
    private let deco3_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 36
        return v
    }()
    private let deco4_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 20
        return v
    }()
    // 新增描边环装饰
    private let decoRing_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 40
        return v
    }()

    // --- 标题 ---
    private let pageTitleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Discover"
        lb.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        lb.textColor = .white
        return lb
    }()

    private let pageSubtitleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.75)
        return lb
    }()

    // --- 统计徽章容器（帖子数量 · 分类数量） ---
    private let statsRowView_Base_one: UIView = {
        UIView()
    }()

    // --- 过滤/排序按钮 ---
    private let filterButton_Base_one: UIButton = {
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

    private let searchCard_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor  = UIColor(hexstring_Base_one: "#38B2AC").withAlphaComponent(0.22).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 18
        v.layer.shadowOpacity = 1
        return v
    }()
    private let searchIcon_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        iv.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let searchTextField_Base_one: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search rooms, tips, items..."
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.returnKeyType = .search
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    // MARK: - 分类图标圆圈 Tab 栏

    /// Tab 栏外层背景（白色卡片，带底部阴影线）
    private let tabAreaBg_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    /// Tab 横向滚动视图
    private let tabScrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.backgroundColor = .clear
        sv.clipsToBounds = false
        return sv
    }()

    /// Tab 项水平排列的 StackView
    private let tabStackView_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fill   // 每个 item 有固定宽度，fill 不强制均分
        return sv
    }()

    /// Tab 区底部分隔线
    private let tabDivider_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }()

    // MARK: - 结果摘要条（白色卡片样式，带阴影）

    private let resultStrip_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        return v
    }()
    /// 摘要内容容器（白色小卡片）
    private let resultCard_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 10
        v.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.layer.shadowOpacity = 1
        return v
    }()
    private let resultDot_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one
        v.layer.cornerRadius = 5
        return v
    }()
    private let resultCategoryLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }()
    private let resultCountLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb
    }()

    // MARK: - 帖子网格
    private var postsCollectionView_Base_one: UICollectionView!

    // MARK: - 空状态视图
    private let emptyStateView_Base_one: UIView = { let v = UIView(); v.isHidden = true; return v }()
    private let emptyBgCircle_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.06)
        v.layer.cornerRadius = 72
        return v
    }()
    private let emptyIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "square.stack.3d.up.slash",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 36, weight: .light))
        iv.tintColor = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.55)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let emptyTitleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Nothing found"
        lb.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        lb.textAlignment = .center
        return lb
    }()
    private let emptySubLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Try another keyword or category"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    private let emptyClearButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Clear Search", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one
        btn.layer.cornerRadius = 20
        btn.contentEdgeInsets = UIEdgeInsets(top: 11, left: 28, bottom: 11, right: 28)
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        loadCategories_Base_one()
        // 搭建顺序决定 z-order，越晚添加越在上层
        buildPostsGrid_Base_one()
        buildEmptyState_Base_one()
        buildResultStrip_Base_one()
        buildCategoryIconTabs_Base_one()
        buildHeaderShadow_Base_one()
        buildHeader_Base_one()
        buildSearchCard_Base_one()  // 最后添加，z-order 最高
        loadPosts_Base_one()
        listenNotifications_Base_one()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 而非直接赋值，保证 UINavigationController 内部状态同步
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadPosts_Base_one()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Base_one?.frame = headerView_Base_one.bounds
        // 更新 tab 圆形渐变尺寸
        tabBundles_Base_one.forEach { bundle in
            bundle.circleGrad?.frame = bundle.circleBg.bounds
        }
    }

    // MARK: - 数据加载

    private func loadCategories_Base_one() {
        categories_Base_one = TitleViewModel_Base_one.shared_Base_one.getCategories_Base_one()
    }

    /// 根据关键词、分类、排序状态刷新帖子列表
    private func loadPosts_Base_one() {
        var result = TitleViewModel_Base_one.shared_Base_one.filterPosts_Base_one(
            keyword_base_one: searchKeyword_Base_one,
            category_base_one: selectedCategoryId_Base_one
        )
        if sortByLikes_Base_one {
            result = result.sorted { $0.likes_Base_one > $1.likes_Base_one }
        }
        displayPosts_Base_one = result
        refreshDisplay_Base_one(animated: true)
    }

    // MARK: - 通知

    private func listenNotifications_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleDataChanged_Base_one),
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onHomeCategoryPicked_Base_one(_:)),
            name: Notification.Name("HomeDidSelectCategory_Base_one"), object: nil
        )
    }

    @objc private func onTitleDataChanged_Base_one() { loadPosts_Base_one() }

    @objc private func onHomeCategoryPicked_Base_one(_ n: Notification) {
        guard let id = n.object as? String else { return }
        selectedCategoryId_Base_one = id
        loadPosts_Base_one()
        refreshAllTabStates_Base_one(animated: true)
        // 滚动到选中 Tab
        if let bundle = tabBundles_Base_one.first(where: { $0.category.id_Base_one == id }) {
            let containerFrame = tabScrollView_Base_one.convert(
                bundle.container.frame, from: tabStackView_Base_one
            )
            tabScrollView_Base_one.scrollRectToVisible(containerFrame, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        searchDebounceTimer_Base_one?.invalidate()
    }

    // MARK: - UI 搭建

    /// 搭建帖子双列网格（最底层）
    private func buildPostsGrid_Base_one() {
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

        postsCollectionView_Base_one = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(section: section)
        )
        postsCollectionView_Base_one.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        postsCollectionView_Base_one.showsVerticalScrollIndicator = false
        postsCollectionView_Base_one.contentInsetAdjustmentBehavior = .never
        postsCollectionView_Base_one.register(PostCardCell_Base_one.self, forCellWithReuseIdentifier: "PostCard")
        postsCollectionView_Base_one.dataSource = self
        postsCollectionView_Base_one.delegate   = self

        let refresh = UIRefreshControl()
        refresh.tintColor = ColorConfig_Base_one.tidyMint_Base_one
        refresh.addTarget(self, action: #selector(onPullRefresh_Base_one(_:)), for: .valueChanged)
        postsCollectionView_Base_one.refreshControl = refresh

        view.addSubview(postsCollectionView_Base_one)
        postsCollectionView_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    /// 搭建空状态视图
    private func buildEmptyState_Base_one() {
        view.addSubview(emptyStateView_Base_one)
        emptyStateView_Base_one.addSubview(emptyBgCircle_Base_one)
        emptyStateView_Base_one.addSubview(emptyIconView_Base_one)
        emptyStateView_Base_one.addSubview(emptyTitleLabel_Base_one)
        emptyStateView_Base_one.addSubview(emptySubLabel_Base_one)
        emptyStateView_Base_one.addSubview(emptyClearButton_Base_one)

        emptyStateView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(postsCollectionView_Base_one).offset(40)
            make.width.equalToSuperview().multipliedBy(0.72)
        }
        emptyBgCircle_Base_one.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(144)
        }
        emptyIconView_Base_one.snp.makeConstraints { make in
            make.center.equalTo(emptyBgCircle_Base_one)
            make.width.height.equalTo(52)
        }
        emptyTitleLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(emptyBgCircle_Base_one.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        emptySubLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Base_one.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
        emptyClearButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(emptySubLabel_Base_one.snp.bottom).offset(22)
            make.centerX.bottom.equalToSuperview()
        }
        emptyClearButton_Base_one.addTarget(self, action: #selector(onClearSearch_Base_one),
                                            for: .touchUpInside)
    }

    /// 搭建结果摘要条（白色小卡片内嵌分类色圆点 + 文字）
    private func buildResultStrip_Base_one() {
        resultCard_Base_one.addSubview(resultDot_Base_one)
        resultCard_Base_one.addSubview(resultCategoryLabel_Base_one)
        resultCard_Base_one.addSubview(resultCountLabel_Base_one)
        resultStrip_Base_one.addSubview(resultCard_Base_one)

        view.addSubview(resultStrip_Base_one)

        resultCard_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }
        resultDot_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        resultCategoryLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(resultDot_Base_one.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        resultCountLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(resultCategoryLabel_Base_one.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }
        // top 约束在 buildCategoryIconTabs 里设置
        resultStrip_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(42)
        }
    }

    /// 搭建分类图标圆圈 Tab 栏
    private func buildCategoryIconTabs_Base_one() {
        view.addSubview(tabAreaBg_Base_one)
        tabAreaBg_Base_one.addSubview(tabScrollView_Base_one)
        tabAreaBg_Base_one.addSubview(tabDivider_Base_one)
        tabScrollView_Base_one.addSubview(tabStackView_Base_one)

        // 创建每个分类的图标 Tab 项
        createTabItems_Base_one()

        tabAreaBg_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(92)   // 圆圈 48 + 文字 14 + 上下各 15
        }
        tabScrollView_Base_one.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        tabDivider_Base_one.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        // StackView 必须同时约束四边才能让 UIScrollView 正确计算 contentSize
        // height 固定到 scrollView frame 高度以禁止垂直滚动
        tabStackView_Base_one.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(tabScrollView_Base_one.snp.height)
        }

        // 结果摘要条紧贴 Tab 区下方
        resultStrip_Base_one.snp.makeConstraints { make in
            make.top.equalTo(tabAreaBg_Base_one.snp.bottom)
        }
        // 更新帖子网格 top = resultStrip.bottom（稍后在 buildSearchCard 中设置最终约束）
        postsCollectionView_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(resultStrip_Base_one.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyStateView_Base_one.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(postsCollectionView_Base_one).offset(30)
            make.width.equalToSuperview().multipliedBy(0.72)
        }
    }

    /// 批量创建分类图标 Tab 项并加入 StackView
    private func createTabItems_Base_one() {
        for (idx, cat) in categories_Base_one.enumerated() {
            let catColor = ColorConfig_Base_one.colorForCategory_Base_one(cat.id_Base_one)

            // 可点击整体区域
            let container = UIView()
            container.isUserInteractionEnabled = true

            // 圆形背景
            let circleBg = UIView()
            circleBg.layer.cornerRadius = 24
            circleBg.clipsToBounds = true
            circleBg.backgroundColor = UIColor(hexstring_Base_one: "#F1F5F9")

            // 图标
            let iconView = UIImageView()
            let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            iconView.image = UIImage(systemName: cat.iconName_Base_one, withConfiguration: cfg)
            iconView.tintColor = catColor
            iconView.contentMode = .scaleAspectFit

            // 分类名称
            let nameLabel = UILabel()
            nameLabel.text = cat.name_Base_one
            nameLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            nameLabel.textColor = ColorConfig_Base_one.textSecondary_Base_one
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
                                             action: #selector(onTabItemTapped_Base_one(_:)))
            container.addGestureRecognizer(tap)
            container.tag = idx

            tabStackView_Base_one.addArrangedSubview(container)

            let bundle = TabBundle_Base_one(
                container: container,
                circleBg: circleBg,
                iconView: iconView,
                nameLabel: nameLabel,
                category: cat
            )
            tabBundles_Base_one.append(bundle)
        }
        // 延迟一帧更新初始选中态（等布局完成）
        DispatchQueue.main.async { [weak self] in
            self?.refreshAllTabStates_Base_one(animated: false)
        }
    }

    /// 搭建 Header 阴影载体（z-order 在 headerView 下方）
    private func buildHeaderShadow_Base_one() {
        view.addSubview(headerShadow_Base_one)
        headerShadow_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }

    /// 搭建顶部渐变 Header（三色对角渐变，视觉更活泼）
    private func buildHeader_Base_one() {
        view.addSubview(headerView_Base_one)
        headerView_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        // 多色斜向渐变：薄荷绿 → 深蓝绿 → 微紫蓝（增加层次感和品牌辨识度）
        let grad = CAGradientLayer()
        grad.colors = [
            UIColor(hexstring_Base_one: "#4ECDC4").cgColor,
            UIColor(hexstring_Base_one: "#2C9E96").cgColor,
            UIColor(hexstring_Base_one: "#2D7DD2").cgColor
        ]
        grad.locations = [0.0, 0.58, 1.0]
        grad.startPoint = CGPoint(x: 0.0, y: 0.0)
        grad.endPoint   = CGPoint(x: 1.0, y: 1.0)
        headerView_Base_one.layer.insertSublayer(grad, at: 0)
        headerGradient_Base_one = grad

        // 装饰圆和描边环
        headerView_Base_one.addSubview(deco1_Base_one)
        deco1_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(54)
            make.width.height.equalTo(180)
        }
        headerView_Base_one.addSubview(deco2_Base_one)
        deco2_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(112)
        }
        headerView_Base_one.addSubview(deco3_Base_one)
        deco3_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.width.height.equalTo(72)
        }
        headerView_Base_one.addSubview(deco4_Base_one)
        deco4_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(78)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.width.height.equalTo(40)
        }
        headerView_Base_one.addSubview(decoRing_Base_one)
        decoRing_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(44)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
            make.width.height.equalTo(80)
        }

        // 标题区
        headerView_Base_one.addSubview(pageTitleLabel_Base_one)
        headerView_Base_one.addSubview(pageSubtitleLabel_Base_one)
        headerView_Base_one.addSubview(filterButton_Base_one)

        pageTitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
        }
        pageSubtitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(pageTitleLabel_Base_one)
            make.top.equalTo(pageTitleLabel_Base_one.snp.bottom).offset(3)
            // 底部留出空间让搜索卡片居中对齐 header 底边，约 30pt
            make.bottom.equalToSuperview().offset(-30)
        }
        filterButton_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(pageTitleLabel_Base_one)
            make.width.height.equalTo(38)
        }
        filterButton_Base_one.addTarget(self, action: #selector(onFilterTapped_Base_one), for: .touchUpInside)

        // 同步 shadow 载体高度
        headerShadow_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(headerView_Base_one)
        }
    }

    /// 搭建悬浮搜索卡片（最后添加，z-order 最高）
    /// centerY 对齐 headerView 底边，形成跨区悬浮效果
    private func buildSearchCard_Base_one() {
        searchCard_Base_one.addSubview(searchIcon_Base_one)
        searchCard_Base_one.addSubview(searchTextField_Base_one)
        view.addSubview(searchCard_Base_one)

        searchIcon_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        searchTextField_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Base_one.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        searchCard_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(headerView_Base_one.snp.bottom)
            make.height.equalTo(50)
        }

        // Tab 区紧在搜索卡片下方
        tabAreaBg_Base_one.snp.makeConstraints { make in
            make.top.equalTo(searchCard_Base_one.snp.bottom).offset(8)
        }

        searchTextField_Base_one.delegate = self
        searchTextField_Base_one.addTarget(self, action: #selector(onSearchTextChanged_Base_one(_:)),
                                           for: .editingChanged)
    }

    // MARK: - 数据展示刷新

    /// 刷新帖子列表与空状态（animated: 是否淡入动画）
    private func refreshDisplay_Base_one(animated: Bool) {
        let empty = displayPosts_Base_one.isEmpty
        let count = displayPosts_Base_one.count

        // 副标题
        pageSubtitleLabel_Base_one.text = empty
            ? "No results"
            : "\(count) post\(count == 1 ? "" : "s") found"

        // 结果摘要条
        let catName = categories_Base_one.first(where: {
            $0.id_Base_one == selectedCategoryId_Base_one
        })?.name_Base_one ?? "All"
        let catColor = ColorConfig_Base_one.colorForCategory_Base_one(selectedCategoryId_Base_one)
        resultDot_Base_one.backgroundColor = catColor
        resultCategoryLabel_Base_one.text = catName
        resultCountLabel_Base_one.text = "·  \(count) result\(count == 1 ? "" : "s")"

        postsCollectionView_Base_one.reloadData()
        if empty {
            emptyStateView_Base_one.isHidden = false
            emptyStateView_Base_one.animateSpringScaleIn_Base_one()
        } else {
            emptyStateView_Base_one.isHidden = true
            if animated { postsCollectionView_Base_one.animateFadeIn_Base_one(duration_Base_one: 0.22) }
        }
    }

    /// 刷新所有 Tab 的选中 / 非选中视觉状态
    private func refreshAllTabStates_Base_one(animated: Bool) {
        for bundle in tabBundles_Base_one {
            let selected = bundle.category.id_Base_one == selectedCategoryId_Base_one
            applyTabState_Base_one(bundle: bundle, isSelected: selected, animated: animated)
        }
    }

    /// 为单个 Tab 应用选中或未选中样式
    /// 参数：
    /// - bundle: Tab 视图组合
    /// - isSelected: 是否选中
    /// - animated: 是否动画
    private func applyTabState_Base_one(bundle: TabBundle_Base_one,
                                        isSelected: Bool,
                                        animated: Bool) {
        let catColor = ColorConfig_Base_one.colorForCategory_Base_one(bundle.category.id_Base_one)

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
                bundle.circleBg.backgroundColor = UIColor(hexstring_Base_one: "#F7FAFC")
                bundle.circleBg.layer.borderWidth  = 1.5
                bundle.circleBg.layer.borderColor  = catColor.withAlphaComponent(0.28).cgColor
                bundle.circleBg.layer.shadowOpacity = 0

                bundle.iconView.tintColor = catColor
                bundle.nameLabel.textColor = ColorConfig_Base_one.textSecondary_Base_one
                bundle.nameLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                bundle.container.transform = .identity
            }
        }

        if animated {
            UIView.animate(
                withDuration: AnimationConfig_Base_one.durationSpring_Base_one,
                delay: 0,
                usingSpringWithDamping: AnimationConfig_Base_one.springDampingNormal_Base_one,
                initialSpringVelocity: AnimationConfig_Base_one.springVelocity_Base_one,
                options: [.curveEaseOut],
                animations: block
            )
        } else {
            block()
        }
    }

    // MARK: - 用户交互事件

    /// 分类 Tab 点击（通过 container.tag 定位 index）
    @objc private func onTabItemTapped_Base_one(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view else { return }
        let idx = container.tag
        guard idx < categories_Base_one.count else { return }
        let cat = categories_Base_one[idx]
        guard cat.id_Base_one != selectedCategoryId_Base_one else { return }

        view.endEditing(true)
        selectedCategoryId_Base_one = cat.id_Base_one
        loadPosts_Base_one()
        refreshAllTabStates_Base_one(animated: true)

        // 点击动画反馈
        let bundle = tabBundles_Base_one[idx]
        bundle.container.animatePressDown_Base_one { [weak bundle] in
            bundle?.container.animatePressUp_Base_one()
        }

        if !displayPosts_Base_one.isEmpty {
            postsCollectionView_Base_one.scrollToItem(
                at: IndexPath(item: 0, section: 0), at: .top, animated: true
            )
        }
    }

    /// 过滤/排序按钮切换（按点赞数排序）
    @objc private func onFilterTapped_Base_one() {
        sortByLikes_Base_one.toggle()
        filterButton_Base_one.isSelected = sortByLikes_Base_one
        filterButton_Base_one.animatePulse_Base_one()
        UIView.animate(withDuration: 0.2) {
            self.filterButton_Base_one.backgroundColor = self.sortByLikes_Base_one
                ? UIColor.white.withAlphaComponent(0.38)
                : UIColor.white.withAlphaComponent(0.22)
        }
        loadPosts_Base_one()
    }

    /// 搜索框内容变化（防抖 0.28s 触发）
    @objc private func onSearchTextChanged_Base_one(_ tf: UITextField) {
        searchDebounceTimer_Base_one?.invalidate()
        searchDebounceTimer_Base_one = Timer.scheduledTimer(withTimeInterval: 0.28,
                                                            repeats: false) { [weak self] _ in
            guard let self else { return }
            self.searchKeyword_Base_one = tf.text ?? ""
            self.loadPosts_Base_one()
        }
        let hasText = !(tf.text?.isEmpty ?? true)
        UIView.animate(withDuration: 0.18) {
            self.searchIcon_Base_one.tintColor = hasText
                ? ColorConfig_Base_one.tidyMint_Base_one
                : ColorConfig_Base_one.textPlaceholder_Base_one
        }
    }

    @objc private func onPullRefresh_Base_one(_ sender: UIRefreshControl) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            loadPosts_Base_one()
            sender.endRefreshing()
        }
    }

    @objc private func onClearSearch_Base_one() {
        searchTextField_Base_one.text = ""
        searchKeyword_Base_one = ""
        searchTextField_Base_one.resignFirstResponder()
        loadPosts_Base_one()
        emptyClearButton_Base_one.animatePressDown_Base_one { [weak self] in
            self?.emptyClearButton_Base_one.animatePressUp_Base_one()
        }
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Base_one: UITextFieldDelegate {

    func textFieldShouldReturn(_ tf: UITextField) -> Bool {
        tf.resignFirstResponder(); return true
    }

    func textFieldDidBeginEditing(_ tf: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Base_one.durationFast_Base_one) {
            self.searchCard_Base_one.layer.shadowColor =
                ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.32).cgColor
            self.searchCard_Base_one.layer.shadowRadius = 22
            self.searchCard_Base_one.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
        }
    }

    func textFieldDidEndEditing(_ tf: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Base_one.durationFast_Base_one) {
            self.searchCard_Base_one.layer.shadowColor =
                UIColor(hexstring_Base_one: "#38B2AC").withAlphaComponent(0.22).cgColor
            self.searchCard_Base_one.layer.shadowRadius = 18
            self.searchCard_Base_one.transform = .identity
        }
    }
}

// MARK: - CollectionView DataSource & Delegate（帖子网格）

extension Discover_Base_one: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayPosts_Base_one.count
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: "PostCard", for: indexPath
        ) as! PostCardCell_Base_one
        let post = displayPosts_Base_one[indexPath.item]
        cell.configure_Base_one(post_base_one: post, style_base_one: .discoverStyle_base_one)
        cell.onLikeTapped_Base_one = {
            /// 点赞前先验证登录状态，未登录则跳转登录页
            guard UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one else {
                Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
                return
            }
            Task { @MainActor in
                TitleViewModel_Base_one.shared_Base_one.likePost_Base_one(post_base_one: post)
            }
        }
        cell.onCardTapped_Base_one = {
            Navigation_Base_one.toTitleDetail_Base_one(titleModel_base_one: post)
        }
        /// 点击作者头像：非当前用户则进入用户中心页
        cell.onAvatarTapped_Base_one = { userId_base_one in
            guard !UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(userId_base_one: userId_base_one) else { return }
            let userModel_base_one = UserViewModel_Base_one.shared_Base_one.getUserById_Base_one(userId_base_one: userId_base_one)
            Navigation_Base_one.toUserInfo_Base_one(with: userModel_base_one)
        }
        // 举报/删除完成后重新拉取数据，刷新帖子列表
        cell.onMoreTapped_Base_one = { [weak self] post_base_one in
            guard let self = self else { return }
            let isMyPost_base_one = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
                userId_base_one: post_base_one.titleUserId_Base_one
            )
            if isMyPost_base_one {
                ReportDeleteHelper_Base_one.delete_Base_one(post_Base_one: post_base_one, from: self) { [weak self] in
                    self?.loadPosts_Base_one()
                }
            } else {
                ReportDeleteHelper_Base_one.report_Base_one(post_Base_one: post_base_one, from: self) { [weak self] in
                    self?.loadPosts_Base_one()
                }
            }
        }
        return cell
    }

    func collectionView(_ cv: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.animateSlideInFromBottom_Base_one(
            offset_Base_one: 24,
            delay_Base_one: Double(indexPath.item % 4) * AnimationConfig_Base_one.delayShort_Base_one
        )
    }
}
