import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页（露营探索主题）
/// 核心作用：渐变头部 + 搜索框 + 分类 Chips 筛选 + 瀑布流帖子列表，支持举报/删除与详情跳转
/// 设计思路：固定渐变头部（标题 + 装饰圆 + 可输入搜索框）+ 分类 Chips 横向滚动 + UICollectionView 瀑布流
/// 关键属性：collectionView_Breeze 瀑布流、posts_Breeze 过滤结果、selectedCategory_Breeze 当前分类、currentKeyword_Breeze 搜索词
class Discover_Breeze: UIViewController {
    
    // MARK: - 数据
    
    /// 当前选中的分类（默认全部）
    private var selectedCategory_Breeze: PostCategory_Breeze = .all_breeze
    
    /// 当前搜索关键词（空串表示不过滤）
    private var currentKeyword_Breeze: String = ""
    
    /// 按分类 + 关键词过滤后的帖子列表
    private var posts_Breeze: [TitleModel_Breeze] = []
    
    // MARK: - UI：头部渐变区
    
    /// 头部渐变容器（标题 + 搜索栏）
    private let headerView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 头部渐变图层（青绿 → 天空蓝）
    private var headerGradientLayer_Breeze: CAGradientLayer?
    
    /// 装饰圆 - 右上角大圆（营造空气感）
    private let decorLargeCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view_breeze.layer.cornerRadius = 85
        return view_breeze
    }()
    
    /// 装饰圆 - 右侧中圆
    private let decorMedCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view_breeze.layer.cornerRadius = 54
        return view_breeze
    }()
    
    /// 装饰圆 - 左下小圆
    private let decorSmallCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        view_breeze.layer.cornerRadius = 32
        return view_breeze
    }()
    
    /// 主标题
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Discover"
        label_breeze.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        label_breeze.textColor = UIColor.white
        return label_breeze
    }()
    
    /// 副标题
    private let subtitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Explore campsite stories & adventures"
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        return label_breeze
    }()
    
    /// 搜索栏容器
    private let searchBar_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view_breeze.layer.cornerRadius = 16
        view_breeze.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_breeze.layer.shadowRadius = 10
        view_breeze.layer.shadowOpacity = 1.0
        return view_breeze
    }()
    
    /// 搜索图标
    private let searchIcon_Breeze: UIImageView = {
        let imageView_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        imageView_breeze.image = UIImage(systemName: "magnifyingglass", withConfiguration: config_breeze)
        imageView_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        imageView_breeze.contentMode = .scaleAspectFit
        return imageView_breeze
    }()
    
    /// 搜索输入框（实时过滤帖子）
    private let searchTextField_Breeze: UITextField = {
        let field_breeze = UITextField()
        field_breeze.placeholder = "Search trails, spots & moments..."
        field_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        field_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        field_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        field_breeze.borderStyle = .none
        field_breeze.backgroundColor = .clear
        field_breeze.returnKeyType = .search
        field_breeze.clearButtonMode = .whileEditing
        field_breeze.autocorrectionType = .no
        field_breeze.autocapitalizationType = .none
        // 占位符颜色通过 attributedPlaceholder 设置
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]
        field_breeze.attributedPlaceholder = NSAttributedString(
            string: "Search trails, spots & moments...",
            attributes: attrs_breeze
        )
        return field_breeze
    }()
    
    // MARK: - UI：分类筛选区
    
    /// 分类区底色容器
    private let categoryContainer_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        return view_breeze
    }()
    
    /// 分类横向滚动视图
    private lazy var categoryScrollView_Breeze: UIScrollView = {
        let scrollView_breeze = UIScrollView()
        scrollView_breeze.showsHorizontalScrollIndicator = false
        scrollView_breeze.backgroundColor = .clear
        scrollView_breeze.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return scrollView_breeze
    }()
    
    /// 分类 Chip 横向堆叠容器
    private let categoryStack_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .horizontal
        stack_breeze.spacing = 10
        stack_breeze.alignment = .center
        return stack_breeze
    }()
    
    /// 已生成的分类 Chip 按钮列表
    private var categoryChips_Breeze: [UIButton] = []
    
    // MARK: - UI：空态视图
    
    /// 无数据空态容器（搜索 / 筛选结果为空时居中展示）
    private let emptyView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.isHidden = true
        return view_breeze
    }()
    
    /// 空态图标
    private let emptyIconView_Breeze: UIImageView = {
        let imageView_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 52, weight: .thin)
        imageView_breeze.image = UIImage(systemName: "doc.text.magnifyingglass",
                                         withConfiguration: config_breeze)
        imageView_breeze.tintColor = ColorConfig_Breeze.textPlaceholder_Breeze
        imageView_breeze.contentMode = .scaleAspectFit
        return imageView_breeze
    }()
    
    /// 空态主文案
    private let emptyTitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "No results found"
        label_breeze.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    /// 空态副文案
    private let emptySubtitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Try different keywords or switch to another category"
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.textAlignment = .center
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    // MARK: - UI：帖子列表区
    
    /// 瀑布流布局
    private let waterfallLayout_Breeze = WaterfallLayout_Breeze()
    
    /// 瀑布流集合视图
    private lazy var collectionView_Breeze: UICollectionView = {
        let collectionView_breeze = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout_Breeze)
        collectionView_breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        collectionView_breeze.showsVerticalScrollIndicator = false
        collectionView_breeze.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 120, right: 0)
        return collectionView_breeze
    }()
    
    /// 下拉刷新控件
    private let refreshControl_Breeze = UIRefreshControl()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
        reloadData_Breeze()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 布局完成后更新渐变图层尺寸
        refreshHeaderGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    /// 主入口：依次搭建头部、分类区、列表区，并绑定搜索事件
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeaderView_Breeze()
        bindSearchTextField_Breeze()
        setupCategorySection_Breeze()
        setupCollectionView_Breeze()
    }
    
    // MARK: - 头部渐变区搭建
    
    /// 搭建渐变头部（装饰圆 + 标题 + 搜索栏）
    private func setupHeaderView_Breeze() {
        view.addSubview(headerView_Breeze)
        headerView_Breeze.addSubview(decorLargeCircle_Breeze)
        headerView_Breeze.addSubview(decorMedCircle_Breeze)
        headerView_Breeze.addSubview(decorSmallCircle_Breeze)
        headerView_Breeze.addSubview(titleLabel_Breeze)
        headerView_Breeze.addSubview(subtitleLabel_Breeze)
        headerView_Breeze.addSubview(searchBar_Breeze)
        searchBar_Breeze.addSubview(searchIcon_Breeze)
        searchBar_Breeze.addSubview(searchTextField_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        // 装饰圆：右上角大圆
        decorLargeCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(170)
            make.right.equalToSuperview().offset(48)
            make.top.equalToSuperview().offset(-36)
        }
        
        // 装饰圆：右侧中圆
        decorMedCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(108)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(decorLargeCircle_Breeze.snp.bottom).offset(-8)
        }
        
        // 装饰圆：左下小圆（平衡构图）
        decorSmallCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.left.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(12)
        }
        
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.left.equalToSuperview().offset(22)
        }
        
        subtitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Breeze.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(22)
            make.right.equalTo(decorLargeCircle_Breeze.snp.left).offset(-4)
        }
        
        searchBar_Breeze.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Breeze.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-22)
        }
        
        searchIcon_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        searchTextField_Breeze.snp.makeConstraints { make in
            make.left.equalTo(searchIcon_Breeze.snp.right).offset(10)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 绑定搜索输入框事件（在 setupHeaderView_Breeze 末尾调用）
    private func bindSearchTextField_Breeze() {
        searchTextField_Breeze.delegate = self
        searchTextField_Breeze.addTarget(self,
                                         action: #selector(onSearchTextChanged_Breeze(_:)),
                                         for: .editingChanged)
    }
    
    /// 刷新头部渐变图层（viewDidLayoutSubviews 中调用）
    private func refreshHeaderGradient_Breeze() {
        headerGradientLayer_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: headerView_Breeze.bounds)
        headerView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradientLayer_Breeze = gradient_breeze
    }
    
    // MARK: - 分类区搭建
    
    /// 搭建分类 Chips 横向滚动区
    private func setupCategorySection_Breeze() {
        view.addSubview(categoryContainer_Breeze)
        categoryContainer_Breeze.addSubview(categoryScrollView_Breeze)
        categoryScrollView_Breeze.addSubview(categoryStack_Breeze)
        
        categoryContainer_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        categoryScrollView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        categoryStack_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(38)
        }
        
        // 按枚举顺序生成 Chip
        for (index_breeze, category_breeze) in PostCategory_Breeze.allCases.enumerated() {
            let chip_breeze = makeCategoryChip_Breeze(category_breeze: category_breeze, tag_breeze: index_breeze)
            categoryStack_Breeze.addArrangedSubview(chip_breeze)
            categoryChips_Breeze.append(chip_breeze)
        }
        
        // 默认高亮 "All"
        applyCategoryChipStyle_Breeze(activeIndex_breeze: 0)
    }
    
    /// 构建单个分类 Chip 按钮
    /// - Parameters:
    ///   - category_breeze: 对应的帖子分类
    ///   - tag_breeze: 按钮 tag，用于识别点击事件中的分类下标
    /// - Returns: 配置完整的 UIButton
    private func makeCategoryChip_Breeze(category_breeze: PostCategory_Breeze, tag_breeze: Int) -> UIButton {
        let button_breeze = UIButton(type: .system)
        button_breeze.tag = tag_breeze
        button_breeze.layer.cornerRadius = 19
        button_breeze.layer.borderWidth = 1.5
        button_breeze.clipsToBounds = true
        
        var config_breeze = UIButton.Configuration.plain()
        config_breeze.imagePadding = 5
        config_breeze.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
        
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        config_breeze.image = UIImage(systemName: category_breeze.iconName_Breeze, withConfiguration: iconConf_breeze)
        config_breeze.title = category_breeze.rawValue
        config_breeze.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var mutable_breeze = attr
            mutable_breeze.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            return mutable_breeze
        }
        button_breeze.configuration = config_breeze
        
        button_breeze.snp.makeConstraints { make in
            make.height.equalTo(38)
        }
        
        button_breeze.addTarget(self, action: #selector(onCategoryTap_Breeze(_:)), for: .touchUpInside)
        return button_breeze
    }
    
    /// 更新所有 Chip 的选中 / 非选中样式
    /// - Parameter activeIndex_breeze: 当前选中 Chip 的下标
    private func applyCategoryChipStyle_Breeze(activeIndex_breeze: Int) {
        for (index_breeze, chip_breeze) in categoryChips_Breeze.enumerated() {
            if index_breeze == activeIndex_breeze {
                // 选中态：主渐变色填充，白色图标文字
                chip_breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
                chip_breeze.tintColor = .white
                chip_breeze.layer.borderColor = UIColor.clear.cgColor
                var conf_breeze = chip_breeze.configuration
                conf_breeze?.baseForegroundColor = .white
                chip_breeze.configuration = conf_breeze
            } else {
                // 非选中态：白色背景，次级文字色
                chip_breeze.backgroundColor = .white
                chip_breeze.tintColor = ColorConfig_Breeze.textSecondary_Breeze
                chip_breeze.layer.borderColor = ColorConfig_Breeze.divider_Breeze.cgColor
                var conf_breeze = chip_breeze.configuration
                conf_breeze?.baseForegroundColor = ColorConfig_Breeze.textSecondary_Breeze
                chip_breeze.configuration = conf_breeze
            }
        }
    }
    
    // MARK: - 列表区搭建
    
    /// 搭建瀑布流集合视图并注册下拉刷新
    private func setupCollectionView_Breeze() {
        view.addSubview(collectionView_Breeze)
        
        collectionView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(categoryContainer_Breeze.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        waterfallLayout_Breeze.delegate_Breeze = self
        collectionView_Breeze.dataSource = self
        collectionView_Breeze.delegate = self
        collectionView_Breeze.register(PostCardCell_Breeze.self,
                                       forCellWithReuseIdentifier: PostCardCell_Breeze.reuseId_Breeze)
        
        refreshControl_Breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        refreshControl_Breeze.addTarget(self, action: #selector(onPullRefresh_Breeze), for: .valueChanged)
        collectionView_Breeze.refreshControl = refreshControl_Breeze
        
        setupEmptyView_Breeze()
    }
    
    /// 搭建空态视图并添加到列表区中央
    private func setupEmptyView_Breeze() {
        view.addSubview(emptyView_Breeze)
        emptyView_Breeze.addSubview(emptyIconView_Breeze)
        emptyView_Breeze.addSubview(emptyTitleLabel_Breeze)
        emptyView_Breeze.addSubview(emptySubtitleLabel_Breeze)
        
        // 空态视图居中于 categoryContainer 底部到屏幕底部之间的区域
        emptyView_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.centerY.equalTo(collectionView_Breeze)
        }
        
        emptyIconView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        
        emptyTitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Breeze.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
        }
        
        emptySubtitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Breeze.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 通知监听
    
    /// 注册帖子状态变化通知
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData_Breeze),
            name: TitleViewModel_Breeze.titleStateDidChangeNotification_Breeze,
            object: nil
        )
    }
    
    // MARK: - 数据刷新
    
    /// 按当前分类 + 关键词重新加载数据并刷新布局；无数据时展示空态视图
    @objc private func reloadData_Breeze() {
        posts_Breeze = TitleViewModel_Breeze.shared_Breeze.searchPosts_Breeze(
            keyword_breeze: currentKeyword_Breeze,
            category_breeze: selectedCategory_Breeze
        )
        waterfallLayout_Breeze.invalidateLayout()
        collectionView_Breeze.reloadData()
        updateEmptyState_Breeze()
    }
    
    /// 根据帖子列表是否为空切换空态视图的可见状态（带淡入淡出动画）
    private func updateEmptyState_Breeze() {
        let isEmpty_breeze = posts_Breeze.isEmpty
        guard emptyView_Breeze.isHidden == isEmpty_breeze else { return }
        
        if isEmpty_breeze {
            emptyView_Breeze.alpha = 0
            emptyView_Breeze.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.emptyView_Breeze.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.emptyView_Breeze.alpha = 0
            } completion: { _ in
                self.emptyView_Breeze.isHidden = true
            }
        }
    }
    
    /// 下拉刷新处理
    @objc private func onPullRefresh_Breeze() {
        reloadData_Breeze()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.refreshControl_Breeze.endRefreshing()
        }
    }
    
    /// 分类 Chip 点击处理
    /// - Parameter sender: 被点击的 Chip 按钮（tag 对应 allCases 下标）
    @objc private func onCategoryTap_Breeze(_ sender: UIButton) {
        let index_breeze = sender.tag
        let cases_breeze = PostCategory_Breeze.allCases
        guard index_breeze < cases_breeze.count else { return }
        
        selectedCategory_Breeze = cases_breeze[index_breeze]
        applyCategoryChipStyle_Breeze(activeIndex_breeze: index_breeze)
        reloadData_Breeze()
        
        let feedback_breeze = UIImpactFeedbackGenerator(style: .light)
        feedback_breeze.impactOccurred()
    }
    
    /// 搜索输入框文字变化处理（实时过滤）
    /// - Parameter sender: 触发事件的 UITextField
    @objc private func onSearchTextChanged_Breeze(_ sender: UITextField) {
        currentKeyword_Breeze = sender.text ?? ""
        reloadData_Breeze()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension Discover_Breeze: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return posts_Breeze.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_breeze = collectionView.dequeueReusableCell(
            withReuseIdentifier: PostCardCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as? PostCardCell_Breeze else {
            return UICollectionViewCell()
        }
        
        let post_breeze = posts_Breeze[indexPath.item]
        cell_breeze.configure_Breeze(post_breeze: post_breeze,
                                     hostViewController_breeze: self,
                                     cardWidth_breeze: itemWidth_Breeze())
        cell_breeze.onReportComplete_Breeze = { [weak self] in
            self?.reloadData_Breeze()
        }
        // 点击作者头像/昵称 → 跳转用户中心
        cell_breeze.onAvatarTap_Breeze = { [weak self] userId_breeze in
            guard self != nil else { return }
            let user_breeze = UserViewModel_Breeze.shared_Breeze.getUserById_Breeze(userId_breeze: userId_breeze)
            Navigation_Breeze.toUserInfo_Breeze(with: user_breeze)
        }
        return cell_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        Navigation_Breeze.toTitleDetail_Breeze(titleModel_breeze: posts_Breeze[indexPath.item])
    }
    
    /// 计算瀑布流单列宽度
    private func itemWidth_Breeze() -> CGFloat {
        let inset_breeze = waterfallLayout_Breeze.sectionInset_Breeze
        let spacing_breeze = waterfallLayout_Breeze.columnSpacing_Breeze * CGFloat(waterfallLayout_Breeze.columnCount_Breeze - 1)
        let available_breeze = APPSCREEN_Breeze.WIDTH_Breeze - inset_breeze.left - inset_breeze.right - spacing_breeze
        return available_breeze / CGFloat(waterfallLayout_Breeze.columnCount_Breeze)
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Breeze: WaterfallLayoutDelegate_Breeze {
    
    func waterfallLayout_Breeze(_ layout_breeze: WaterfallLayout_Breeze,
                                heightForItemAt indexPath_breeze: IndexPath,
                                itemWidth_breeze: CGFloat) -> CGFloat {
        let post_breeze = posts_Breeze[indexPath_breeze.item]
        return PostCardCell_Breeze.cellHeight_Breeze(width_breeze: itemWidth_breeze, post_breeze: post_breeze)
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Breeze: UITextFieldDelegate {
    
    /// 点击键盘 Return 键时收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIScrollViewDelegate

extension Discover_Breeze: UIScrollViewDelegate {
    
    /// 列表开始滚动时收起键盘，避免遮挡内容
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField_Breeze.resignFirstResponder()
    }
}
