import Foundation
import UIKit
import SnapKit

// MARK: - 发现页（重构版）

/// 发现页视图控制器
/// 核心作用：Pinterest 风格非规则瀑布流展示所有帖子，支持分类筛选、点赞和举报/删除
/// 设计思路：全图覆盖式卡片 + 渐变文字层叠 + 底部作者/点赞栏，配合横向滑动过滤标签栏
class Discover_Sylva: UIViewController {

    // MARK: - 私有属性

    /// 顶部容器（标题行 + 过滤标签行）
    private let headerContainerView_Sylva = UIView()

    /// 主标题标签
    private let titleLabel_Sylva = UILabel()

    /// 帖子数量副标题
    private let subtitleLabel_Sylva = UILabel()

    /// 过滤标签横向滚动区
    private let filterScrollView_Sylva = UIScrollView()

    /// 过滤标签排列容器
    private let filterStackView_Sylva = UIStackView()

    /// 帖子列表（CollectionView）
    private var collectionView_Sylva: UICollectionView!

    /// 瀑布流布局
    private let waterfallLayout_Sylva = WaterfallLayout_Sylva()

    /// 当前展示的帖子（过滤后）
    private var displayedPosts_Sylva: [TitleModel_Sylva] = []

    /// 当前选中的过滤标签索引
    private var selectedFilterIndex_Sylva: Int = 0

    /// 过滤标签配置：(显示名称, 搜索关键词)
    private let filterConfigs_Sylva: [(String, String)] = [
        ("All", ""),
        ("Trees", "tree,sapling,oak,maple,plant"),
        ("Forest", "forest,reforest,wildfire,woodland,woods"),
        ("Wildlife", "wildlife,animal,bird,species,creature"),
        ("Garden", "garden,seed,grow,bloom,flower,soil"),
        ("Tips", "tip,guide,how,learn,urban,community")
    ]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        setupHeader_Sylva()
        setupFilterBar_Sylva()
        setupCollectionView_Sylva()
        observeNotifications_Sylva()
        reloadData_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建顶部标题行
    private func setupHeader_Sylva() {
        headerContainerView_Sylva.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        view.addSubview(headerContainerView_Sylva)
        headerContainerView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }

        // 主标题（先加入视图层级，供 dotView 约束引用）
        titleLabel_Sylva.text = "Discover"
        titleLabel_Sylva.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        titleLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        headerContainerView_Sylva.addSubview(titleLabel_Sylva)

        // 绿色点缀竖条（此时 titleLabel_Sylva 已在同一视图层级中）
        let dotView_sylva = UIView()
        dotView_sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
        dotView_sylva.layer.cornerRadius = 3
        headerContainerView_Sylva.addSubview(dotView_sylva)
        dotView_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(titleLabel_Sylva)
            make.width.equalTo(6)
            make.height.equalTo(22)
        }

        titleLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(dotView_sylva.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
        }

        // 副标题（帖子数量）
        subtitleLabel_Sylva.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        headerContainerView_Sylva.addSubview(subtitleLabel_Sylva)
        subtitleLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Sylva)
            make.top.equalTo(titleLabel_Sylva.snp.bottom).offset(2)
        }

        // 底部分割线
        let divider_sylva = UIView()
        divider_sylva.backgroundColor = ColorConfig_Sylva.divider_Sylva
        headerContainerView_Sylva.addSubview(divider_sylva)
        divider_sylva.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    /// 搭建横向过滤标签栏
    private func setupFilterBar_Sylva() {
        filterScrollView_Sylva.showsHorizontalScrollIndicator = false
        filterScrollView_Sylva.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        filterScrollView_Sylva.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(filterScrollView_Sylva)
        filterScrollView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView_Sylva.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }

        filterStackView_Sylva.axis = .horizontal
        filterStackView_Sylva.spacing = 8
        filterStackView_Sylva.alignment = .center
        filterScrollView_Sylva.addSubview(filterStackView_Sylva)
        filterStackView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 生成过滤标签按钮
        for (index_sylva, config_sylva) in filterConfigs_Sylva.enumerated() {
            let chip_sylva = buildFilterChip_Sylva(
                title_sylva: config_sylva.0,
                index_sylva: index_sylva,
                isSelected_sylva: index_sylva == 0
            )
            filterStackView_Sylva.addArrangedSubview(chip_sylva)
        }
    }

    /// 构建单个过滤标签按钮
    /// - Parameters:
    ///   - title_sylva: 标签文字
    ///   - index_sylva: 标签索引（用于点击事件识别）
    ///   - isSelected_sylva: 是否为选中状态
    /// - Returns: 配置好的 UIButton
    private func buildFilterChip_Sylva(title_sylva: String, index_sylva: Int, isSelected_sylva: Bool) -> UIButton {
        let btn_sylva = UIButton(type: .system)
        btn_sylva.setTitle(title_sylva, for: .normal)
        btn_sylva.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_sylva.layer.cornerRadius = 16
        btn_sylva.contentEdgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
        btn_sylva.tag = index_sylva
        applyFilterChipStyle_Sylva(btn_sylva, isSelected_sylva: isSelected_sylva)
        btn_sylva.addTarget(self, action: #selector(onFilterChipTapped_Sylva(_:)), for: .touchUpInside)
        return btn_sylva
    }

    /// 设置标签按钮的样式（选中/未选中）
    private func applyFilterChipStyle_Sylva(_ btn_sylva: UIButton, isSelected_sylva: Bool) {
        if isSelected_sylva {
            btn_sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
            btn_sylva.setTitleColor(.white, for: .normal)
            btn_sylva.layer.borderWidth = 0
        } else {
            btn_sylva.backgroundColor = .white
            btn_sylva.setTitleColor(ColorConfig_Sylva.textSecondary_Sylva, for: .normal)
            btn_sylva.layer.borderWidth = 1
            btn_sylva.layer.borderColor = ColorConfig_Sylva.border_Sylva.cgColor
        }
    }

    /// 搭建瀑布流集合视图
    private func setupCollectionView_Sylva() {
        waterfallLayout_Sylva.columnCount_Sylva = 2
        waterfallLayout_Sylva.minimumColumnSpacing_Sylva = 10
        waterfallLayout_Sylva.minimumInteritemSpacing_Sylva = 10
        waterfallLayout_Sylva.sectionInset_Sylva = UIEdgeInsets(top: 12, left: 14, bottom: 30, right: 14)
        waterfallLayout_Sylva.delegate_Sylva = self

        collectionView_Sylva = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout_Sylva)
        collectionView_Sylva.backgroundColor = .clear
        collectionView_Sylva.showsVerticalScrollIndicator = false
        collectionView_Sylva.dataSource = self
        collectionView_Sylva.delegate = self
        collectionView_Sylva.register(
            DiscoverCell_Sylva.self,
            forCellWithReuseIdentifier: DiscoverCell_Sylva.reuseId_Sylva
        )

        // 底部内边距 100pt：CollectionView 铺满全屏，但内容可以滚动到距屏幕底部 100pt 处
        collectionView_Sylva.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        collectionView_Sylva.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        view.addSubview(collectionView_Sylva)
        collectionView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(filterScrollView_Sylva.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    /// 重新加载并刷新帖子数据（根据当前选中过滤器）
    private func reloadData_Sylva() {
        let keyword_sylva = filterConfigs_Sylva[selectedFilterIndex_Sylva].1
        displayedPosts_Sylva = TitleViewModel_Sylva.shared_Sylva.getFilteredPosts_Sylva(keyword_sylva: keyword_sylva)
        let count_sylva = TitleViewModel_Sylva.shared_Sylva.getPosts_Sylva().count
        subtitleLabel_Sylva.text = "Explore nature stories · \(count_sylva) posts"
        collectionView_Sylva.reloadData()
    }

    // MARK: - 事件处理

    /// 过滤标签被点击
    @objc private func onFilterChipTapped_Sylva(_ sender: UIButton) {
        let newIndex_sylva = sender.tag
        guard newIndex_sylva != selectedFilterIndex_Sylva else { return }

        // 更新旧标签样式
        if let oldChip_sylva = filterStackView_Sylva.arrangedSubviews[selectedFilterIndex_Sylva] as? UIButton {
            applyFilterChipStyle_Sylva(oldChip_sylva, isSelected_sylva: false)
        }
        // 更新新标签样式
        applyFilterChipStyle_Sylva(sender, isSelected_sylva: true)
        sender.animatePulse_Sylva()

        selectedFilterIndex_Sylva = newIndex_sylva
        reloadData_Sylva()
    }

    // MARK: - 通知监听

    /// 注册帖子状态变化通知
    private func observeNotifications_Sylva() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChanged_Sylva),
            name: TitleViewModel_Sylva.titleStateDidChangeNotification_Sylva,
            object: nil
        )
    }

    @objc private func onTitleStateChanged_Sylva() {
        reloadData_Sylva()
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Sylva: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPosts_Sylva.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_sylva = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverCell_Sylva.reuseId_Sylva,
            for: indexPath
        ) as? DiscoverCell_Sylva else {
            return UICollectionViewCell()
        }

        let post_sylva = displayedPosts_Sylva[indexPath.item]
        let isLiked_sylva = TitleViewModel_Sylva.shared_Sylva.isLikedPost_Sylva(post_sylva: post_sylva)

        cell_sylva.configure_Sylva(
            post_sylva: post_sylva,
            isLiked_sylva: isLiked_sylva,
            animationDelay_sylva: Double(indexPath.item % 6) * 0.05
        )

        // 点赞回调
        cell_sylva.onLikeTapped_Sylva = { [weak self] post_sylva in
            TitleViewModel_Sylva.shared_Sylva.likePost_Sylva(post_sylva: post_sylva)
        }

        // 举报/删除回调
        cell_sylva.onMoreTapped_Sylva = { [weak self] post_sylva in
            guard let self_sylva = self else { return }
            let isMyPost_sylva = UserViewModel_Sylva.shared_Sylva.isCurrentUser_Sylva(
                userId_sylva: post_sylva.titleUserId_Sylva
            )
            if isMyPost_sylva {
                ReportDeleteHelper_Sylva.delete_Sylva(
                    post_Sylva: post_sylva,
                    from: self_sylva,
                    completion_Sylva: nil
                )
            } else {
                ReportDeleteHelper_Sylva.report_Sylva(
                    post_Sylva: post_sylva,
                    from: self_sylva,
                    completion_Sylva: nil
                )
            }
        }

        // 头像点击进入用户中心
        cell_sylva.onAvatarTapped_Sylva = { post_sylva in
            let user_sylva = UserViewModel_Sylva.shared_Sylva.getUserById_Sylva(
                userId_sylva: post_sylva.titleUserId_Sylva
            )
            Navigation_Sylva.toUserInfo_Sylva(with: user_sylva)
        }

        return cell_sylva
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Sylva: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_sylva = displayedPosts_Sylva[indexPath.item]
        Navigation_Sylva.toTitleDetail_Sylva(titleModel_sylva: post_sylva)
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Sylva: WaterfallLayoutDelegate_Sylva {

    /// 根据帖子内容动态计算卡片总高度
    func collectionView_Sylva(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        columnWidth: CGFloat
    ) -> CGFloat {
        // 图片比例随索引交错变化，营造瀑布流错落感
        let ratios_sylva: [CGFloat] = [1.1, 0.78, 0.95, 1.25, 0.72, 1.05]
        let ratio_sylva = ratios_sylva[indexPath.item % ratios_sylva.count]
        let imageHeight_sylva = columnWidth * ratio_sylva
        // 底部作者/点赞行固定高度 + 上下内边距
        let footerHeight_sylva: CGFloat = 46
        return imageHeight_sylva + footerHeight_sylva
    }
}

// MARK: - 瀑布流布局代理协议

/// 瀑布流布局代理协议
/// 功能：由外部提供每个 item 的动态高度
protocol WaterfallLayoutDelegate_Sylva: AnyObject {
    /// 返回指定 IndexPath 对应 item 的高度
    func collectionView_Sylva(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        columnWidth: CGFloat
    ) -> CGFloat
}

// MARK: - 自定义瀑布流布局

/// Pinterest 风格非规则瀑布流布局
/// 功能：多列独立高度追踪，自动将新 item 填入当前最矮列，实现错落有致效果
class WaterfallLayout_Sylva: UICollectionViewLayout {

    // MARK: 配置属性

    /// 列数（默认 2）
    var columnCount_Sylva: Int = 2
    /// 列间距
    var minimumColumnSpacing_Sylva: CGFloat = 10
    /// 行间距
    var minimumInteritemSpacing_Sylva: CGFloat = 10
    /// 分区内边距
    var sectionInset_Sylva: UIEdgeInsets = .zero
    /// 代理（提供 item 高度）
    weak var delegate_Sylva: WaterfallLayoutDelegate_Sylva?

    // MARK: 私有属性

    private var cache_Sylva: [UICollectionViewLayoutAttributes] = []
    private var contentHeight_Sylva: CGFloat = 0
    private var contentWidth_Sylva: CGFloat {
        guard let cv_sylva = collectionView else { return 0 }
        return cv_sylva.bounds.width - cv_sylva.contentInset.left - cv_sylva.contentInset.right
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth_Sylva, height: contentHeight_Sylva)
    }

    override func prepare() {
        guard cache_Sylva.isEmpty, let cv_sylva = collectionView else { return }

        let columnWidth_sylva = (
            contentWidth_Sylva
            - sectionInset_Sylva.left
            - sectionInset_Sylva.right
            - CGFloat(columnCount_Sylva - 1) * minimumColumnSpacing_Sylva
        ) / CGFloat(columnCount_Sylva)

        // 各列起始 X 坐标
        var xOffset_sylva: [CGFloat] = (0..<columnCount_Sylva).map { col_sylva in
            sectionInset_Sylva.left + CGFloat(col_sylva) * (columnWidth_sylva + minimumColumnSpacing_Sylva)
        }
        // 各列当前高度
        var yOffset_sylva = [CGFloat](repeating: sectionInset_Sylva.top, count: columnCount_Sylva)

        let count_sylva = cv_sylva.numberOfItems(inSection: 0)
        for item_sylva in 0..<count_sylva {
            let indexPath_sylva = IndexPath(item: item_sylva, section: 0)

            // 找最矮列
            let col_sylva = yOffset_sylva.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0

            let itemHeight_sylva = delegate_Sylva?.collectionView_Sylva(
                cv_sylva,
                heightForItemAt: indexPath_sylva,
                columnWidth: columnWidth_sylva
            ) ?? 200

            let frame_sylva = CGRect(
                x: xOffset_sylva[col_sylva],
                y: yOffset_sylva[col_sylva],
                width: columnWidth_sylva,
                height: itemHeight_sylva
            )

            let attr_sylva = UICollectionViewLayoutAttributes(forCellWith: indexPath_sylva)
            attr_sylva.frame = frame_sylva
            cache_Sylva.append(attr_sylva)

            yOffset_sylva[col_sylva] += itemHeight_sylva + minimumInteritemSpacing_Sylva
        }

        contentHeight_Sylva = (yOffset_sylva.max() ?? 0) + sectionInset_Sylva.bottom
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache_Sylva.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache_Sylva[safe_Sylva: indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        cache_Sylva.removeAll()
        return true
    }
}

// MARK: - Array 安全下标

private extension Array {
    subscript(safe_Sylva index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - 发现页帖子卡片

/// 发现页帖子卡片
/// 核心作用：全图覆盖式卡片，图片底部渐变层叠标题，卡片底部展示作者头像 + 点赞按钮
/// 设计思路：图片区 + 渐变遮罩 + 标题 + 更多按钮 组合为一体，底部独立作者行
/// 关键属性：onLikeTapped_Sylva / onMoreTapped_Sylva 回调供 VC 处理逻辑
class DiscoverCell_Sylva: UICollectionViewCell {

    static let reuseId_Sylva = "DiscoverCell_Sylva"

    // MARK: UI 组件

    /// 媒体图片视图（全卡片上方）
    private let mediaView_Sylva = MediaDisplayView_Sylva()

    /// 图片底部渐变遮罩
    private let gradientOverlay_Sylva = CAGradientLayer()

    /// 覆盖在图片上的标题标签
    private let overlayTitleLabel_Sylva = UILabel()

    /// 更多操作按钮（右上角）
    private let moreButton_Sylva = UIButton(type: .system)

    /// 底部作者头像
    private let avatarView_Sylva = UserAvatarView_Sylva()

    /// 作者名称标签
    private let authorLabel_Sylva = UILabel()

    /// 点赞按钮（心形图标）
    private let likeButton_Sylva = UIButton(type: .system)

    /// 点赞数量标签
    private let likeCountLabel_Sylva = UILabel()

    // MARK: 数据属性

    /// 当前绑定的帖子
    private var currentPost_Sylva: TitleModel_Sylva?

    /// 点赞状态
    private var isLiked_Sylva: Bool = false

    // MARK: 回调

    /// 点赞按钮被点击的回调（由 VC 调用 ViewModel）
    var onLikeTapped_Sylva: ((TitleModel_Sylva) -> Void)?

    /// 更多/举报按钮被点击的回调
    var onMoreTapped_Sylva: ((TitleModel_Sylva) -> Void)?

    /// 头像被点击的回调（由 VC 导航至用户中心）
    var onAvatarTapped_Sylva: ((TitleModel_Sylva) -> Void)?

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sylva()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI 搭建

    private func setupUI_Sylva() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 18
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.clipsToBounds = false

        setupMediaArea_Sylva()
        setupFooterArea_Sylva()
    }

    /// 搭建图片区域（含渐变遮罩、标题覆盖、更多按钮）
    private func setupMediaArea_Sylva() {
        // 媒体视图
        mediaView_Sylva.layer.cornerRadius = 18
        mediaView_Sylva.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                               .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        mediaView_Sylva.clipsToBounds = true
        contentView.addSubview(mediaView_Sylva)
        mediaView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 底部留给 footer 行，footer 高度 46
            make.bottom.equalToSuperview().offset(-46)
        }

        // 底部渐变遮罩（在 layoutSubviews 中设置 frame）
        gradientOverlay_Sylva.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        gradientOverlay_Sylva.locations = [0.35, 1.0]
        gradientOverlay_Sylva.cornerRadius = 18
        mediaView_Sylva.layer.addSublayer(gradientOverlay_Sylva)

        // 覆盖标题（底部）
        overlayTitleLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        overlayTitleLabel_Sylva.textColor = .white
        overlayTitleLabel_Sylva.numberOfLines = 2
        overlayTitleLabel_Sylva.lineBreakMode = .byTruncatingTail
        contentView.addSubview(overlayTitleLabel_Sylva)
        overlayTitleLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-36)
            make.bottom.equalTo(mediaView_Sylva.snp.bottom).offset(-10)
        }

        // 更多操作按钮（图片右上角）
        let iconConfig_sylva = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        moreButton_Sylva.setImage(UIImage(systemName: "ellipsis", withConfiguration: iconConfig_sylva), for: .normal)
        moreButton_Sylva.tintColor = .white
        moreButton_Sylva.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        moreButton_Sylva.layer.cornerRadius = 13
        contentView.addSubview(moreButton_Sylva)
        moreButton_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(26)
        }
        moreButton_Sylva.addTarget(self, action: #selector(onMoreButtonTapped_Sylva), for: .touchUpInside)
    }

    /// 搭建底部作者/点赞行
    private func setupFooterArea_Sylva() {
        // ---- 第一步：将所有视图加入层级，再统一设置约束 ----

        // 作者头像（可点击进入用户中心）
        avatarView_Sylva.layer.cornerRadius = 12
        avatarView_Sylva.layer.masksToBounds = true
        avatarView_Sylva.isUserInteractionEnabled = true
        let avatarTap_sylva = UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped_Sylva_action))
        avatarView_Sylva.addGestureRecognizer(avatarTap_sylva)
        contentView.addSubview(avatarView_Sylva)

        // 作者名称
        authorLabel_Sylva.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        authorLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        authorLabel_Sylva.numberOfLines = 1
        contentView.addSubview(authorLabel_Sylva)

        // 点赞按钮（先加入层级，供 authorLabel 约束引用）
        let likeIconConfig_sylva = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        likeButton_Sylva.setImage(
            UIImage(systemName: "heart", withConfiguration: likeIconConfig_sylva),
            for: .normal
        )
        likeButton_Sylva.tintColor = ColorConfig_Sylva.textSecondary_Sylva
        contentView.addSubview(likeButton_Sylva)
        likeButton_Sylva.addTarget(self, action: #selector(onLikeButtonTapped_Sylva), for: .touchUpInside)

        // 点赞数量
        likeCountLabel_Sylva.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        likeCountLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        contentView.addSubview(likeCountLabel_Sylva)

        // ---- 第二步：所有视图已在同一层级，统一设置约束 ----

        avatarView_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(24)
        }

        likeButton_Sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-28)
            make.centerY.equalTo(avatarView_Sylva)
            make.width.height.equalTo(24)
        }

        likeCountLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(likeButton_Sylva.snp.trailing).offset(2)
            make.centerY.equalTo(likeButton_Sylva)
            make.trailing.equalToSuperview().offset(-8)
        }

        // authorLabel 的 trailing 引用 likeButton，此时两者均已在层级中
        authorLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_Sylva.snp.trailing).offset(5)
            make.centerY.equalTo(avatarView_Sylva)
            make.trailing.lessThanOrEqualTo(likeButton_Sylva.snp.leading).offset(-4)
        }
    }

    // MARK: 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        // 同步渐变遮罩 frame 至媒体视图
        let mediaFrame_sylva = mediaView_Sylva.frame
        gradientOverlay_Sylva.frame = mediaFrame_sylva
        // 确保 shadowPath 跟随圆角更新（避免离屏渲染性能问题）
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: contentView.bounds,
            cornerRadius: 18
        ).cgPath
    }

    // MARK: 配置

    /// 配置卡片数据及入场动画
    /// - Parameters:
    ///   - post_sylva: 帖子数据模型
    ///   - isLiked_sylva: 当前用户是否已点赞
    ///   - animationDelay_sylva: 入场动画延迟（用于错落效果）
    func configure_Sylva(
        post_sylva: TitleModel_Sylva,
        isLiked_sylva: Bool,
        animationDelay_sylva: TimeInterval = 0
    ) {
        currentPost_Sylva = post_sylva
        isLiked_Sylva = isLiked_sylva

        // 媒体
        if let media_sylva = post_sylva.titleMeidas_Sylva.first {
            mediaView_Sylva.configure_Sylva(mediaPath_Sylva: media_sylva)
        }

        // 标题覆盖
        overlayTitleLabel_Sylva.text = post_sylva.title_Sylva

        // 作者信息
        avatarView_Sylva.configure_Sylva(userId_Sylva: post_sylva.titleUserId_Sylva)
        authorLabel_Sylva.text = post_sylva.titleUserName_Sylva

        // 更多按钮图标（自己的帖子显示删除图标）
        let isMyPost_sylva = UserViewModel_Sylva.shared_Sylva.isCurrentUser_Sylva(
            userId_sylva: post_sylva.titleUserId_Sylva
        )
        let iconName_sylva = isMyPost_sylva ? "trash" : "ellipsis"
        let iconConfig_sylva = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        moreButton_Sylva.setImage(UIImage(systemName: iconName_sylva, withConfiguration: iconConfig_sylva), for: .normal)

        // 点赞状态
        updateLikeAppearance_Sylva(isLiked_sylva: isLiked_sylva)
        likeCountLabel_Sylva.text = post_sylva.likes_Sylva > 0 ? "\(post_sylva.likes_Sylva)" : ""

        // 入场动画（错落淡入）
        if animationDelay_sylva > 0 {
            alpha = 0
            transform = CGAffineTransform(translationX: 0, y: 12)
            UIView.animate(
                withDuration: AnimationConfig_Sylva.durationSpring_Sylva,
                delay: animationDelay_sylva,
                usingSpringWithDamping: AnimationConfig_Sylva.springDampingNormal_Sylva,
                initialSpringVelocity: AnimationConfig_Sylva.springVelocity_Sylva,
                options: [.curveEaseOut, .allowUserInteraction],
                animations: {
                    self.alpha = 1
                    self.transform = .identity
                }
            )
        } else {
            alpha = 1
            transform = .identity
        }
    }

    /// 更新点赞按钮外观
    private func updateLikeAppearance_Sylva(isLiked_sylva: Bool) {
        let iconConfig_sylva = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let iconName_sylva = isLiked_sylva ? "heart.fill" : "heart"
        likeButton_Sylva.setImage(UIImage(systemName: iconName_sylva, withConfiguration: iconConfig_sylva), for: .normal)
        likeButton_Sylva.tintColor = isLiked_sylva
            ? UIColor(hexstring_Sylva: "#E53E3E")
            : ColorConfig_Sylva.textSecondary_Sylva
        likeCountLabel_Sylva.textColor = isLiked_sylva
            ? UIColor(hexstring_Sylva: "#E53E3E")
            : ColorConfig_Sylva.textSecondary_Sylva
    }

    // MARK: 事件响应

    /// 点赞按钮点击
    @objc private func onLikeButtonTapped_Sylva() {
        guard let post_sylva = currentPost_Sylva else { return }
        isLiked_Sylva.toggle()
        updateLikeAppearance_Sylva(isLiked_sylva: isLiked_Sylva)
        // 点赞弹跳动画
        likeButton_Sylva.animateSpringScaleIn_Sylva()
        onLikeTapped_Sylva?(post_sylva)
    }

    /// 更多操作按钮点击
    @objc private func onMoreButtonTapped_Sylva() {
        guard let post_sylva = currentPost_Sylva else { return }
        moreButton_Sylva.animatePulse_Sylva()
        onMoreTapped_Sylva?(post_sylva)
    }

    /// 头像点击事件
    @objc private func onAvatarTapped_Sylva_action() {
        guard let post_sylva = currentPost_Sylva else { return }
        avatarView_Sylva.animatePulse_Sylva()
        onAvatarTapped_Sylva?(post_sylva)
    }

    // MARK: Cell 复用重置

    override func prepareForReuse() {
        super.prepareForReuse()
        onLikeTapped_Sylva  = nil
        onMoreTapped_Sylva  = nil
        onAvatarTapped_Sylva = nil
        currentPost_Sylva = nil
        overlayTitleLabel_Sylva.text = nil
        authorLabel_Sylva.text = nil
        likeCountLabel_Sylva.text = nil
        alpha = 1
        transform = .identity
    }
}
