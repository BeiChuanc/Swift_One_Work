import Foundation
import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页面
/// 核心功能：展示非规则瀑布流帖子列表，举报/删除、跳转详情与用户信息
/// 设计思路：顶部渐变 Banner + 自定义双列瀑布流布局（WaterfallLayout_Clara），每列高度动态分配
/// 逻辑与UI严格解耦，所有数据操作通过 TitleViewModel_Clara 和 ReportDeleteHelper_Clara 完成
class Discover_Clara: UIViewController {

    // MARK: - UI 组件

    /// 顶部渐变 Banner
    private let bannerView_Clara = UIView()

    /// Banner 渐变图层
    private var bannerGl_Clara: CAGradientLayer?

    /// 搜索栏容器
    private lazy var searchContainer_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 22
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.9
        v.layer.shadowRadius = 10
        return v
    }()

    /// 搜索输入框
    private lazy var searchTextField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search posts..."
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .search
        tf.borderStyle = .none
        tf.addTarget(self, action: #selector(searchTextChanged_Clara(_:)), for: .editingChanged)
        return tf
    }()

    /// 帖子瀑布流 CollectionView
    private lazy var collectionView_Clara: UICollectionView = {
        let layout_Clara = WaterfallLayout_Clara()
        layout_Clara.delegate_Clara = self
        layout_Clara.columnCount_Clara = 2
        layout_Clara.columnSpacing_Clara = 12
        layout_Clara.rowSpacing_Clara = 12
        layout_Clara.sectionInset_Clara = UIEdgeInsets(top: 12, left: 16, bottom: 120, right: 16)
        
        let cv_Clara = UICollectionView(frame: .zero, collectionViewLayout: layout_Clara)
        cv_Clara.backgroundColor = ColorConfig_Clara.springCreamWhite_Clara
        cv_Clara.showsVerticalScrollIndicator = false
        cv_Clara.keyboardDismissMode = .onDrag
        cv_Clara.dataSource = self
        cv_Clara.delegate = self
        cv_Clara.register(DiscoverPostCell_Clara.self, forCellWithReuseIdentifier: DiscoverPostCell_Clara.reuseId_Clara)
        return cv_Clara
    }()
    
    /// 空态视图
    private lazy var emptyView_Clara: UIView = {
        let v_Clara = UIView()
        v_Clara.isHidden = true
        
        let iconView_Clara = UIImageView()
        let config_Clara = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        iconView_Clara.image = UIImage(systemName: "magnifyingglass", withConfiguration: config_Clara)
        iconView_Clara.tintColor = ColorConfig_Clara.springCherryBlossom_Clara.withAlphaComponent(0.5)
        iconView_Clara.contentMode = .scaleAspectFit
        
        let label_Clara = UILabel()
        label_Clara.text = "No posts found"
        label_Clara.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label_Clara.textColor = ColorConfig_Clara.textSecondary_Clara
        label_Clara.textAlignment = .center
        
        let subLabel_Clara = UILabel()
        subLabel_Clara.text = "Try a different keyword"
        subLabel_Clara.font = UIFont.systemFont(ofSize: 13)
        subLabel_Clara.textColor = ColorConfig_Clara.textPlaceholder_Clara
        subLabel_Clara.textAlignment = .center
        
        v_Clara.addSubview(iconView_Clara)
        v_Clara.addSubview(label_Clara)
        v_Clara.addSubview(subLabel_Clara)
        
        iconView_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(72)
        }
        label_Clara.snp.makeConstraints { make in
            make.top.equalTo(iconView_Clara.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        subLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(label_Clara.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return v_Clara
    }()
    
    // MARK: - 数据属性

    /// 全量帖子列表（搜索前）
    private var allPosts_Clara: [TitleModel_Clara] = []

    /// 当前展示帖子列表（搜索过滤后）
    private var filteredPosts_Clara: [TitleModel_Clara] = []

    /// 当前搜索关键词
    private var searchKeyword_Clara: String = ""
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupBanner_Clara()
        setupSearchBar_Clara()
        setupCollectionView_Clara()
        loadData_Clara()
        observeStateChange_Clara()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 与 Home/Me 保持一致，完全隐藏导航栏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gl = bannerGl_Clara {
            gl.frame = bannerView_Clara.bounds
        } else if bannerView_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: bannerView_Clara.bounds)
            bannerView_Clara.layer.insertSublayer(gl, at: 0)
            bannerGl_Clara = gl
        }
        view.updateThemeBackgroundFrame_Clara()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 通知监听
    
    /// 监听帖子状态变化（举报/删除/发布后刷新）
    private func observeStateChange_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChanged_Clara),
            name: TitleViewModel_Clara.titleStateDidChangeNotification_Clara,
            object: nil
        )
    }
    
    @objc private func onTitleStateChanged_Clara() {
        loadData_Clara()
    }
    
    // MARK: - UI 搭建

    /// 搭建顶部渐变 Banner（标题 + 副标题 + 装饰元素）
    private func setupBanner_Clara() {
        view.addSubview(bannerView_Clara)
        bannerView_Clara.layer.cornerRadius = 28
        bannerView_Clara.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bannerView_Clara.clipsToBounds = true
        // 高度：安全区 + 88pt（标题 + 副标题两行）
        bannerView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(88)
        }

        // 右上大装饰圆
        let bigCircle = UIView()
        bigCircle.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        bigCircle.layer.cornerRadius = 55
        bannerView_Clara.addSubview(bigCircle)
        bigCircle.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.right.equalToSuperview().inset(-22)
            make.top.equalToSuperview().inset(-22)
        }

        // 左下小装饰圆
        let smallCircle = UIView()
        smallCircle.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        smallCircle.layer.cornerRadius = 34
        bannerView_Clara.addSubview(smallCircle)
        smallCircle.snp.makeConstraints { make in
            make.width.height.equalTo(68)
            make.left.equalToSuperview().inset(-18)
            make.bottom.equalToSuperview().inset(-20)
        }

        // 右侧装饰图标
        let iconView = UIImageView()
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iconView.image = UIImage(systemName: "sparkles", withConfiguration: iconCfg)
        iconView.tintColor = UIColor.white.withAlphaComponent(0.65)
        bannerView_Clara.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.width.height.equalTo(28)
        }

        // 主标题
        let titleLabel = UILabel()
        titleLabel.text = "Discover"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = .white
        bannerView_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(72)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
        }

        // 副标题描述
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Explore what's trending around you"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.80)
        bannerView_Clara.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
    }

    /// 搭建搜索栏（位于 Banner 下方）
    private func setupSearchBar_Clara() {
        view.addSubview(searchContainer_Clara)
        searchContainer_Clara.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Clara.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        let searchIcon = UIImageView()
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        searchIcon.image = UIImage(systemName: "magnifyingglass", withConfiguration: iconCfg)
        searchIcon.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        searchContainer_Clara.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(17)
        }

        searchContainer_Clara.addSubview(searchTextField_Clara)
        searchTextField_Clara.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(8)
            make.right.equalToSuperview().inset(14)
            make.top.bottom.equalToSuperview()
        }
    }

    /// 搭建瀑布流 CollectionView
    private func setupCollectionView_Clara() {
        view.addSubview(collectionView_Clara)
        view.addSubview(emptyView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        collectionView_Clara.backgroundColor = .clear
        collectionView_Clara.snp.makeConstraints { make in
            make.top.equalTo(searchContainer_Clara.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView_Clara.snp.makeConstraints { make in
            make.center.equalTo(collectionView_Clara)
            make.width.equalTo(200)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载帖子数据
    private func loadData_Clara() {
        allPosts_Clara = TitleViewModel_Clara.shared_Clara.getPosts_Clara()
        applySearchFilter_Clara()
    }

    /// 根据关键词执行过滤，并同步空态
    private func applySearchFilter_Clara() {
        if searchKeyword_Clara.isEmpty {
            filteredPosts_Clara = allPosts_Clara
        } else {
            let keywordLower = searchKeyword_Clara.lowercased()
            filteredPosts_Clara = allPosts_Clara.filter {
                $0.title_Clara.lowercased().contains(keywordLower)
                || $0.titleContent_Clara.lowercased().contains(keywordLower)
                || $0.titleUserName_Clara.lowercased().contains(keywordLower)
            }
        }
        emptyView_Clara.isHidden = !filteredPosts_Clara.isEmpty
        collectionView_Clara.isHidden = filteredPosts_Clara.isEmpty
        // 重置瀑布流布局缓存并刷新
        if let layout_Clara = collectionView_Clara.collectionViewLayout as? WaterfallLayout_Clara {
            layout_Clara.resetCache_Clara()
        }
        collectionView_Clara.reloadData()
    }

    /// 搜索输入变化事件
    /// - Parameter sender: 搜索输入框
    @objc private func searchTextChanged_Clara(_ sender: UITextField) {
        searchKeyword_Clara = sender.text ?? ""
        applySearchFilter_Clara()
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Clara: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPosts_Clara.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Clara = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverPostCell_Clara.reuseId_Clara,
            for: indexPath
        ) as! DiscoverPostCell_Clara
        
        let post_Clara = filteredPosts_Clara[indexPath.item]
        cell_Clara.configure_Clara(post_Clara: post_Clara, from_Clara: self) { [weak self] in
            self?.loadData_Clara()
        }
        return cell_Clara
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Clara: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Clara = filteredPosts_Clara[indexPath.item]
        
        // 点击动画
        if let cell_Clara = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
                cell_Clara.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            } completion: { _ in
                UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
                    cell_Clara.transform = .identity
                }
                Navigation_Clara.toTitleDetail_Clara(titleModel_clara: post_Clara)
            }
        } else {
            Navigation_Clara.toTitleDetail_Clara(titleModel_clara: post_Clara)
        }
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Clara: WaterfallLayoutDelegate_Clara {
    
    /// 提供每个 Cell 的高度（根据内容长度动态计算）
    /// - Parameters:
    ///   - collectionView_Clara: 目标 CollectionView
    ///   - layout_Clara: 瀑布流布局实例
    ///   - indexPath_Clara: item 索引
    ///   - itemWidth_Clara: item 宽度（布局已计算好）
    /// - Returns: Cell 高度
    func waterfallLayout_Clara(
        _ collectionView_Clara: UICollectionView,
        layout_Clara: WaterfallLayout_Clara,
        heightForItemAt indexPath_Clara: IndexPath,
        itemWidth_Clara: CGFloat
    ) -> CGFloat {
        let post_Clara = filteredPosts_Clara[indexPath_Clara.item]
        return DiscoverPostCell_Clara.calculateHeight_Clara(post_Clara: post_Clara, width_Clara: itemWidth_Clara)
    }
}


// MARK: - 瀑布流布局 Delegate 协议

/// 瀑布流布局代理协议
/// 功能：为布局提供动态高度计算的回调接口
protocol WaterfallLayoutDelegate_Clara: AnyObject {
    
    /// 返回指定 item 的高度
    /// - Parameters:
    ///   - collectionView_Clara: 目标 CollectionView
    ///   - layout_Clara: 布局实例
    ///   - indexPath_Clara: item 的 IndexPath
    ///   - itemWidth_Clara: item 的宽度（布局内已计算）
    /// - Returns: item 高度（CGFloat）
    func waterfallLayout_Clara(
        _ collectionView_Clara: UICollectionView,
        layout_Clara: WaterfallLayout_Clara,
        heightForItemAt indexPath_Clara: IndexPath,
        itemWidth_Clara: CGFloat
    ) -> CGFloat
}


// MARK: - 自定义瀑布流布局

/// 双列非规则瀑布流布局
/// 功能：通过贪心算法将 item 分配到高度较小的列，实现左右高度交错的视觉效果
/// 关键属性：delegate_Clara（高度回调）、columnCount_Clara（列数）、缓存机制
class WaterfallLayout_Clara: UICollectionViewLayout {
    
    // MARK: - 配置属性
    
    /// 布局代理（提供 item 高度）
    weak var delegate_Clara: WaterfallLayoutDelegate_Clara?
    
    /// 列数（默认 2 列）
    var columnCount_Clara: Int = 2
    
    /// 列间距
    var columnSpacing_Clara: CGFloat = 12
    
    /// 行间距
    var rowSpacing_Clara: CGFloat = 12
    
    /// 分区内边距
    var sectionInset_Clara: UIEdgeInsets = .zero
    
    // MARK: - 私有属性
    
    /// 布局属性缓存
    private var cache_Clara: [UICollectionViewLayoutAttributes] = []
    
    /// 内容总高度
    private var contentHeight_Clara: CGFloat = 0
    
    /// 各列当前高度
    private var columnHeights_Clara: [CGFloat] = []
    
    /// 内容总宽度（CollectionView 宽度）
    private var contentWidth_Clara: CGFloat {
        guard let cv_Clara = collectionView else { return 0 }
        return cv_Clara.bounds.width - (sectionInset_Clara.left + sectionInset_Clara.right)
    }
    
    // MARK: - 公开方法
    
    /// 重置布局缓存（数据刷新时调用）
    func resetCache_Clara() {
        cache_Clara.removeAll()
        contentHeight_Clara = 0
        columnHeights_Clara.removeAll()
    }
    
    // MARK: - 布局计算
    
    override func prepare() {
        guard let cv_Clara = collectionView,
              cache_Clara.isEmpty else { return }
        
        // 初始化各列起始高度
        columnHeights_Clara = Array(repeating: sectionInset_Clara.top, count: columnCount_Clara)
        
        // 计算每列宽度
        let totalSpacing_Clara = columnSpacing_Clara * CGFloat(columnCount_Clara - 1)
        let itemWidth_Clara = (contentWidth_Clara - totalSpacing_Clara) / CGFloat(columnCount_Clara)
        
        let itemCount_Clara = cv_Clara.numberOfItems(inSection: 0)
        
        for i_Clara in 0..<itemCount_Clara {
            let indexPath_Clara = IndexPath(item: i_Clara, section: 0)
            
            // 找到高度最小的列
            let shortestColumn_Clara = columnHeights_Clara.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            
            // 向代理查询 item 高度
            let itemHeight_Clara = delegate_Clara?.waterfallLayout_Clara(
                cv_Clara,
                layout_Clara: self,
                heightForItemAt: indexPath_Clara,
                itemWidth_Clara: itemWidth_Clara
            ) ?? 180
            
            // 计算 item 的 frame
            let x_Clara = sectionInset_Clara.left + CGFloat(shortestColumn_Clara) * (itemWidth_Clara + columnSpacing_Clara)
            let y_Clara = columnHeights_Clara[shortestColumn_Clara]
            
            let attrs_Clara = UICollectionViewLayoutAttributes(forCellWith: indexPath_Clara)
            attrs_Clara.frame = CGRect(x: x_Clara, y: y_Clara, width: itemWidth_Clara, height: itemHeight_Clara)
            cache_Clara.append(attrs_Clara)
            
            // 更新该列高度
            columnHeights_Clara[shortestColumn_Clara] = y_Clara + itemHeight_Clara + rowSpacing_Clara
        }
        
        contentHeight_Clara = (columnHeights_Clara.max() ?? 0) + sectionInset_Clara.bottom
    }
    
    override var collectionViewContentSize: CGSize {
        guard let cv_Clara = collectionView else { return .zero }
        return CGSize(width: cv_Clara.bounds.width, height: contentHeight_Clara)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache_Clara.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache_Clara.first { $0.indexPath == indexPath }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv_Clara = collectionView else { return false }
        return newBounds.width != cv_Clara.bounds.width
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache_Clara.removeAll()
        contentHeight_Clara = 0
        columnHeights_Clara.removeAll()
    }
}


// MARK: - 发现页帖子 Cell

/// 发现页瀑布流帖子卡片 Cell
/// 功能：用 MediaDisplayView 展示媒体、头像点击跳转用户中心、右上角举报/删除浮层
/// 设计思路：圆角卡片 + 阴影，媒体区高度基于帖子 ID 错落（120/150/180），营造瀑布流层次感
class DiscoverPostCell_Clara: UICollectionViewCell {

    /// Cell 复用标识符
    static let reuseId_Clara = "DiscoverPostCell_Clara"

    // MARK: - UI 组件

    /// 卡片容器（含圆角阴影）
    private let cardView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 8
        return v
    }()

    /// 媒体展示组件（图片/视频/占位）
    private let mediaDisplayView_Clara: MediaDisplayView_Clara = {
        let v = MediaDisplayView_Clara()
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// 媒体区高度约束（configure 时动态更新）
    private var mediaHeightConstraint_Clara: Constraint?

    /// 右上角举报/删除按钮（覆盖于媒体区右上角）
    private var actionButton_Clara: UIButton?

    /// 用户头像（可点击进入用户中心）
    private let avatarView_Clara: UserAvatarView_Clara = {
        let v = UserAvatarView_Clara()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 用户名标签
    private let userNameLabel_Clara: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = ColorConfig_Clara.textSecondary_Clara
        lbl.numberOfLines = 1
        return lbl
    }()

    /// 帖子标题
    private let titleLabel_Clara: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl.textColor = ColorConfig_Clara.textPrimary_Clara
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 帖子内容（最多 2 行截断）
    private let contentLabel_Clara: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = ColorConfig_Clara.textSecondary_Clara
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    // MARK: - 私有属性

    /// 当前绑定的帖子模型
    private var post_Clara: TitleModel_Clara?

    /// 来源视图控制器（弱引用，用于举报/删除弹框）
    private weak var fromVC_Clara: UIViewController?

    /// 举报/删除后的回调
    private var actionCompletion_Clara: (() -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Clara()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI 搭建

    /// 搭建 Cell 内部布局
    private func setupUI_Clara() {
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView_Clara)
        cardView_Clara.addSubview(mediaDisplayView_Clara)
        cardView_Clara.addSubview(avatarView_Clara)
        cardView_Clara.addSubview(userNameLabel_Clara)
        cardView_Clara.addSubview(titleLabel_Clara)
        cardView_Clara.addSubview(contentLabel_Clara)

        cardView_Clara.snp.makeConstraints { make in make.edges.equalToSuperview() }

        mediaDisplayView_Clara.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            mediaHeightConstraint_Clara = make.height.equalTo(120).constraint
        }

        avatarView_Clara.snp.makeConstraints { make in
            make.top.equalTo(mediaDisplayView_Clara.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(28)
        }

        userNameLabel_Clara.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_Clara.snp.trailing).offset(6)
            make.centerY.equalTo(avatarView_Clara)
            make.trailing.equalToSuperview().inset(10)
        }

        titleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Clara.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        contentLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Clara.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(12)
        }

        // 头像点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Clara))
        avatarView_Clara.addGestureRecognizer(tap)
    }

    // MARK: - 配置

    /// 配置 Cell 数据
    /// - Parameters:
    ///   - post_Clara: 帖子数据模型
    ///   - from_Clara: 来源视图控制器（举报/删除弹框所需）
    ///   - completion_Clara: 举报或删除完成后的回调（刷新列表用）
    func configure_Clara(
        post_Clara: TitleModel_Clara,
        from_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        self.post_Clara = post_Clara
        self.fromVC_Clara = from_Clara
        self.actionCompletion_Clara = completion_Clara

        // 用户信息
        avatarView_Clara.configure_Clara(userId_Clara: post_Clara.titleUserId_Clara)
        userNameLabel_Clara.text = post_Clara.titleUserName_Clara

        // 帖子内容
        titleLabel_Clara.text = post_Clara.title_Clara
        contentLabel_Clara.text = post_Clara.titleContent_Clara

        // 媒体展示（有真实媒体时传入路径）
        let mediaPath = post_Clara.titleMeidas_Clara.first
        let isVideo = mediaPath?.hasSuffix(".mp4") == true || mediaPath?.hasSuffix(".mov") == true
        mediaDisplayView_Clara.configure_Clara(mediaPath_Clara: mediaPath, isVideo_Clara: isVideo)

        // 媒体区高度错落（基于 titleId 变化，营造瀑布流高度差异）
        let mediaHeight: CGFloat = CGFloat(120 + (post_Clara.titleId_Clara % 3) * 30)
        mediaHeightConstraint_Clara?.update(offset: mediaHeight)

        // 更新右上角举报/删除浮层按钮
        updateActionButton_Clara(post_Clara: post_Clara, from_Clara: from_Clara)
    }

    /// 创建/更新媒体区右上角举报/删除按钮
    /// - Parameters:
    ///   - post_Clara: 帖子数据模型
    ///   - from_Clara: 来源视图控制器
    private func updateActionButton_Clara(post_Clara: TitleModel_Clara, from_Clara: UIViewController) {
        actionButton_Clara?.removeFromSuperview()
        let btn = ReportDeleteHelper_Clara.createPostReportButton_Clara(
            post_Clara: post_Clara,
            size_Clara: 13,
            color_Clara: .white,
            from: from_Clara,
            completion_Clara: actionCompletion_Clara
        )
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn.layer.cornerRadius = 12
        // 浮于媒体区右上角
        cardView_Clara.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(mediaDisplayView_Clara.snp.top).offset(8)
            make.trailing.equalTo(mediaDisplayView_Clara.snp.trailing).inset(8)
            make.width.height.equalTo(24)
        }
        actionButton_Clara = btn
    }

    // MARK: - 事件

    /// 点击头像跳转用户中心（非当前登录用户则跳转 UserInfo）
    @objc private func avatarTapped_Clara() {
        guard let post = post_Clara else { return }
        let user = UserViewModel_Clara.shared_Clara.getUserById_Clara(userId_clara: post.titleUserId_Clara)
        Navigation_Clara.toUserInfo_Clara(with: user)
    }

    // MARK: - 高度计算

    /// 根据帖子内容预估 Cell 高度（供瀑布流布局使用）
    /// - Parameters:
    ///   - post_Clara: 帖子数据模型
    ///   - width_Clara: Cell 宽度
    /// - Returns: 预估 Cell 高度
    static func calculateHeight_Clara(post_Clara: TitleModel_Clara, width_Clara: CGFloat) -> CGFloat {
        let innerWidth = width_Clara - 20

        // 媒体区高度基于 titleId 错落
        let mediaHeight = CGFloat(120 + (post_Clara.titleId_Clara % 3) * 30)

        // 用户信息行（头像高 + 上下间距）
        let userRowHeight: CGFloat = 28 + 10 + 10

        // 标题高度（最多 2 行）
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let titleHeight = min(
            (post_Clara.title_Clara as NSString).boundingRect(
                with: CGSize(width: innerWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: titleFont], context: nil
            ).height,
            titleFont.lineHeight * 2
        ) + 8

        // 内容高度（最多 2 行）
        let contentFont = UIFont.systemFont(ofSize: 12)
        let contentHeight = min(
            (post_Clara.titleContent_Clara as NSString).boundingRect(
                with: CGSize(width: innerWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: contentFont], context: nil
            ).height,
            contentFont.lineHeight * 2
        ) + 12

        return mediaHeight + userRowHeight + titleHeight + contentHeight
    }

    // MARK: - 复用清理

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel_Clara.text = nil
        contentLabel_Clara.text = nil
        userNameLabel_Clara.text = nil
        mediaDisplayView_Clara.configure_Clara(mediaPath_Clara: nil, isVideo_Clara: false)
        mediaHeightConstraint_Clara?.update(offset: 120)
        actionButton_Clara?.removeFromSuperview()
        actionButton_Clara = nil
    }

    // MARK: - 触摸动画

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
            self.cardView_Clara.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(
            withDuration: AnimationConfig_Clara.durationFast_Clara,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Clara.springDampingLight_Clara,
            initialSpringVelocity: AnimationConfig_Clara.springVelocity_Clara
        ) { self.cardView_Clara.transform = .identity }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
            self.cardView_Clara.transform = .identity
        }
    }
}
