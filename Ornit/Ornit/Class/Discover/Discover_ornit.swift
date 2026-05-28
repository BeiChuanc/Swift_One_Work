import UIKit
import SnapKit

// MARK: 发现页主控制器

/// 发现页
/// 功能：以双列瀑布流形式展示所有观鸟帖子，支持分类排序与关键字搜索
/// 设计：顶部森林绿渐变 Header（含统计数量气泡）+ 横向分类过滤栏 + 悬浮搜索框 + 瀑布流列表
class Discover_Ornit: UIViewController {

    // MARK: - 数据属性

    /// 全部帖子原始数据
    private var allPosts_Ornit: [TitleModel_Ornit] = []

    /// 经过搜索 + 分类过滤后的展示数据
    private var filteredPosts_Ornit: [TitleModel_Ornit] = []

    /// 当前选中的分类索引（0 = All）
    private var selectedCategory_Ornit: Int = 0

    // MARK: - Header 相关组件

    /// 顶部渐变 Header 容器
    private let headerView_Ornit = UIView()

    /// Header 渐变图层（在 viewDidLayoutSubviews 中更新 frame）
    private var headerGradient_Ornit: CAGradientLayer?

    /// 主标题标签
    private let titleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Discover"
        label_ornit.font = UIFont.systemFont(ofSize: 34, weight: .black)
        label_ornit.textColor = .white
        return label_ornit
    }()

    /// 副标题标签
    private let subtitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Explore birdwatching sightings"
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_ornit.textColor = UIColor.white.withValues(alpha: 0.75)
        return label_ornit
    }()

    /// 统计数量气泡容器
    private let statsBubble_Ornit = UIView()

    /// 统计数量标签（展示帖子总数）
    private let statsLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_ornit.textColor = .white
        return label_ornit
    }()

    // MARK: - 搜索栏组件

    /// 搜索框外层容器（白色悬浮卡片样式）
    private let searchContainer_Ornit = UIView()

    /// 搜索输入框
    private let searchField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Search sightings..."
        tf_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.backgroundColor = .clear
        tf_ornit.returnKeyType = .search
        return tf_ornit
    }()

    /// 搜索图标
    private let searchIcon_Ornit: UIImageView = {
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let iv_ornit = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config_ornit))
        iv_ornit.tintColor = ColorConfig_Ornit.naturePrimary_Ornit
        iv_ornit.contentMode = .scaleAspectFit
        return iv_ornit
    }()

    /// 清空搜索按钮（有输入内容时显示）
    private let clearButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .system)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        btn_ornit.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config_ornit), for: .normal)
        btn_ornit.tintColor = ColorConfig_Ornit.textPlaceholder_Ornit
        btn_ornit.isHidden = true
        return btn_ornit
    }()

    // MARK: - 分类过滤栏组件

    /// 分类横向滚动视图
    private let categoryScrollView_Ornit: UIScrollView = {
        let sv_ornit = UIScrollView()
        sv_ornit.showsHorizontalScrollIndicator = false
        sv_ornit.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv_ornit
    }()

    /// 分类按钮水平堆叠视图
    private let categoryStack_Ornit: UIStackView = {
        let sv_ornit = UIStackView()
        sv_ornit.axis = .horizontal
        sv_ornit.spacing = 10
        sv_ornit.alignment = .center
        return sv_ornit
    }()

    /// 分类数据（SF Symbol 图标名 + 展示文字）
    private let categories_Ornit: [(icon: String, title: String)] = [
        ("leaf.fill", "All"),
        ("flame.fill", "Trending"),
        ("clock.fill", "Recent"),
        ("star.fill", "Popular")
    ]

    /// 分类按钮引用数组（用于统一更新选中状态）
    private var categoryButtons_Ornit: [UIButton] = []

    // MARK: - 内容区组件

    /// 瀑布流 CollectionView
    private lazy var collectionView_Ornit: UICollectionView = {
        let layout_ornit = WaterfallLayout_Ornit()
        layout_ornit.delegate_Ornit = self
        layout_ornit.numberOfColumns_Ornit = 2
        layout_ornit.cellPadding_Ornit = 9
        layout_ornit.contentInset_Ornit = UIEdgeInsets(top: 14, left: 14, bottom: 28, right: 14)

        let cv_ornit = UICollectionView(frame: .zero, collectionViewLayout: layout_ornit)
        cv_ornit.backgroundColor = .clear
        cv_ornit.showsVerticalScrollIndicator = false
        cv_ornit.register(
            DiscoverPostCell_Ornit.self,
            forCellWithReuseIdentifier: DiscoverPostCell_Ornit.reuseId_Ornit
        )
        return cv_ornit
    }()

    /// 空状态视图（无数据时显示）
    private let emptyView_Ornit = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundNature_Ornit
        setupHeaderView_Ornit()
        setupSearchBar_Ornit()
        setupCategoryFilter_Ornit()
        setupCollectionView_Ornit()
        setupEmptyView_Ornit()
        setupNotifications_Ornit()
        loadData_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
    }

    // MARK: - 通知监听

    /// 注册帖子状态变更通知，数据变化时刷新列表
    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Ornit),
            name: TitleViewModel_Ornit.titleStateDidChangeNotification_Ornit,
            object: nil
        )
    }

    @objc private func handleTitleStateChange_Ornit() {
        loadData_Ornit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 数据处理

    /// 从 ViewModel 加载全量帖子数据并应用过滤
    private func loadData_Ornit() {
        allPosts_Ornit = TitleViewModel_Ornit.shared_Ornit.getPosts_Ornit()
        statsLabel_Ornit.text = "\(allPosts_Ornit.count) Sightings"
        applyFilter_Ornit()
    }

    /// 综合当前搜索关键字和分类条件，过滤并排序帖子数据
    private func applyFilter_Ornit() {
        let keyword_ornit = searchField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""
        var result_ornit = allPosts_Ornit

        // 关键字过滤：匹配标题或正文内容
        if !keyword_ornit.isEmpty {
            result_ornit = result_ornit.filter { post_ornit in
                post_ornit.title_Ornit.lowercased().contains(keyword_ornit.lowercased()) ||
                post_ornit.titleContent_Ornit.lowercased().contains(keyword_ornit.lowercased())
            }
        }

        // 分类排序策略
        switch selectedCategory_Ornit {
        case 1: // Trending - 按点赞数从高到低
            result_ornit.sort { $0.likes_Ornit > $1.likes_Ornit }
        case 2: // Recent - 按帖子 ID 从大到小（模拟时间倒序）
            result_ornit.sort { $0.titleId_Ornit > $1.titleId_Ornit }
        case 3: // Popular - 点赞数 + 评论数综合排序
            result_ornit.sort {
                ($0.likes_Ornit + $0.reviews_Ornit.count) > ($1.likes_Ornit + $1.reviews_Ornit.count)
            }
        default:
            break
        }

        filteredPosts_Ornit = result_ornit

        // 重置布局高度缓存，确保数据变化后重新计算
        if let layout_ornit = collectionView_Ornit.collectionViewLayout as? WaterfallLayout_Ornit {
            layout_ornit.resetCache_Ornit()
        }
        collectionView_Ornit.reloadData()

        let hasData_ornit = !filteredPosts_Ornit.isEmpty
        emptyView_Ornit.isHidden = hasData_ornit
        collectionView_Ornit.isHidden = !hasData_ornit
    }

    // MARK: - UI 搭建

    /// 构建顶部渐变 Header 区域（森林绿渐变 + 装饰圆圈 + 鸟图标 + 统计气泡）
    private func setupHeaderView_Ornit() {
        view.addSubview(headerView_Ornit)
        headerView_Ornit.layer.cornerRadius = 28
        headerView_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Ornit.clipsToBounds = true

        // 森林绿 → 青绿色渐变
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.discoverGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.discoverGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit

        // 右上角装饰大圆
        let deco1_ornit = UIView()
        deco1_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        deco1_ornit.layer.cornerRadius = 72
        headerView_Ornit.addSubview(deco1_ornit)

        // 右下角装饰小圆
        let deco2_ornit = UIView()
        deco2_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        deco2_ornit.layer.cornerRadius = 44
        headerView_Ornit.addSubview(deco2_ornit)

        // 左侧装饰小圆（营造层次感）
        let deco3_ornit = UIView()
        deco3_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.04)
        deco3_ornit.layer.cornerRadius = 28
        headerView_Ornit.addSubview(deco3_ornit)

        headerView_Ornit.addSubview(titleLabel_Ornit)
        headerView_Ornit.addSubview(subtitleLabel_Ornit)

        // 装饰鸟图标（半透明背景装饰）
        let birdConfig_ornit = UIImage.SymbolConfiguration(pointSize: 42, weight: .thin)
        let birdIcon_ornit = UIImageView(image: UIImage(systemName: "bird.fill", withConfiguration: birdConfig_ornit))
        birdIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.16)
        headerView_Ornit.addSubview(birdIcon_ornit)

        // 统计数量气泡（毛玻璃风格）
        statsBubble_Ornit.backgroundColor = UIColor.white.withValues(alpha: 0.18)
        statsBubble_Ornit.layer.cornerRadius = 14
        statsBubble_Ornit.layer.borderWidth = 1
        statsBubble_Ornit.layer.borderColor = UIColor.white.withValues(alpha: 0.28).cgColor
        headerView_Ornit.addSubview(statsBubble_Ornit)
        statsBubble_Ornit.addSubview(statsLabel_Ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            // 高度留出底部空白，避免悬浮搜索框遮挡内容
            make_ornit.height.equalTo(182)
        }

        deco1_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(52)
            make_ornit.top.equalToSuperview().offset(-28)
            make_ornit.width.height.equalTo(144)
        }

        deco2_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-55)
            make_ornit.bottom.equalToSuperview().offset(28)
            make_ornit.width.height.equalTo(88)
        }

        deco3_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-16)
            make_ornit.top.equalToSuperview().offset(30)
            make_ornit.width.height.equalTo(56)
        }

        titleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalToSuperview().offset(56)
        }

        subtitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalTo(titleLabel_Ornit.snp.bottom).offset(4)
        }

        birdIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-18)
            make_ornit.centerY.equalTo(titleLabel_Ornit).offset(-2)
            make_ornit.width.height.equalTo(56)
        }

        // 统计气泡紧跟副标题下方，确保搜索框悬浮区域不与内容重叠
        statsBubble_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalTo(subtitleLabel_Ornit.snp.bottom).offset(10)
            make_ornit.height.equalTo(28)
        }

        statsLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerY.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview().inset(12)
        }
    }

    /// 构建悬浮搜索框（与 Header 底部重叠，产生浮起效果）
    private func setupSearchBar_Ornit() {
        searchContainer_Ornit.backgroundColor = .white
        searchContainer_Ornit.layer.cornerRadius = 16
        searchContainer_Ornit.layer.shadowColor = ColorConfig_Ornit.discoverGradientStart_Ornit.withValues(alpha: 0.2).cgColor
        searchContainer_Ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        searchContainer_Ornit.layer.shadowOpacity = 1
        searchContainer_Ornit.layer.shadowRadius = 12

        view.addSubview(searchContainer_Ornit)
        searchContainer_Ornit.addSubview(searchIcon_Ornit)
        searchContainer_Ornit.addSubview(searchField_Ornit)
        searchContainer_Ornit.addSubview(clearButton_Ornit)

        searchContainer_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(-24)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(50)
        }

        searchIcon_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(18)
        }

        searchField_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(searchIcon_Ornit.snp.trailing).offset(10)
            make_ornit.trailing.equalTo(clearButton_Ornit.snp.leading).offset(-4)
            make_ornit.centerY.equalToSuperview()
        }

        clearButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(20)
        }

        searchField_Ornit.delegate = self
        searchField_Ornit.addTarget(self, action: #selector(searchTextChanged_Ornit), for: .editingChanged)
        clearButton_Ornit.addTarget(self, action: #selector(clearSearch_Ornit), for: .touchUpInside)
    }

    /// 构建横向滚动分类过滤栏
    private func setupCategoryFilter_Ornit() {
        view.addSubview(categoryScrollView_Ornit)
        categoryScrollView_Ornit.addSubview(categoryStack_Ornit)

        categoryScrollView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(searchContainer_Ornit.snp.bottom).offset(14)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(42)
        }

        categoryStack_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.bottom.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalToSuperview()
        }

        // 批量创建分类按钮
        for (index_ornit, category_ornit) in categories_Ornit.enumerated() {
            let btn_ornit = makeCategoryButton_Ornit(
                icon_Ornit: category_ornit.icon,
                title_Ornit: category_ornit.title,
                index_Ornit: index_ornit
            )
            categoryStack_Ornit.addArrangedSubview(btn_ornit)
            categoryButtons_Ornit.append(btn_ornit)
        }

        updateCategorySelection_Ornit(selectedIndex_Ornit: 0)
    }

    /// 创建单个分类过滤按钮
    /// - Parameters:
    ///   - icon_Ornit: SF Symbol 图标名称
    ///   - title_Ornit: 按钮展示文字
    ///   - index_Ornit: 按钮在数组中的索引（用于 tag 记录）
    /// - Returns: 配置完成的 UIButton
    private func makeCategoryButton_Ornit(icon_Ornit: String, title_Ornit: String, index_Ornit: Int) -> UIButton {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.tag = index_Ornit
        btn_ornit.layer.cornerRadius = 21
        btn_ornit.clipsToBounds = true

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        btn_ornit.setImage(UIImage(systemName: icon_Ornit, withConfiguration: iconConfig_ornit), for: .normal)
        btn_ornit.setTitle("  \(title_Ornit)", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_ornit.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 16)
        btn_ornit.addTarget(self, action: #selector(categoryTapped_Ornit(_:)), for: .touchUpInside)

        return btn_ornit
    }

    /// 更新所有分类按钮的选中与未选中视觉状态
    /// - Parameter selectedIndex_Ornit: 当前选中按钮的索引
    private func updateCategorySelection_Ornit(selectedIndex_Ornit: Int) {
        for (index_ornit, btn_ornit) in categoryButtons_Ornit.enumerated() {
            if index_ornit == selectedIndex_Ornit {
                btn_ornit.backgroundColor = ColorConfig_Ornit.naturePrimary_Ornit
                btn_ornit.setTitleColor(.white, for: .normal)
                btn_ornit.tintColor = .white
            } else {
                btn_ornit.backgroundColor = ColorConfig_Ornit.tagBackground_Ornit
                btn_ornit.setTitleColor(ColorConfig_Ornit.textSecondary_Ornit, for: .normal)
                btn_ornit.tintColor = ColorConfig_Ornit.textSecondary_Ornit
            }
        }
    }

    /// 构建瀑布流 CollectionView
    private func setupCollectionView_Ornit() {
        view.addSubview(collectionView_Ornit)
        collectionView_Ornit.dataSource = self
        collectionView_Ornit.delegate = self

        // 底部额外留出 Tab Bar 高度 + 安全距离，确保最后一行内容能完整滚动出来
        collectionView_Ornit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        collectionView_Ornit.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        collectionView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(categoryScrollView_Ornit.snp.bottom).offset(6)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
    }

    /// 构建无数据时的空状态视图（双图标 + 标题 + 说明文字）
    private func setupEmptyView_Ornit() {
        emptyView_Ornit.isHidden = true
        view.addSubview(emptyView_Ornit)

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 56, weight: .thin)
        let emptyIcon_ornit = UIImageView(
            image: UIImage(systemName: "binoculars", withConfiguration: iconConfig_ornit)
        )
        emptyIcon_ornit.tintColor = ColorConfig_Ornit.natureTeal_Ornit.withValues(alpha: 0.35)
        emptyView_Ornit.addSubview(emptyIcon_ornit)

        let emptyTitle_ornit = UILabel()
        emptyTitle_ornit.text = "No sightings found"
        emptyTitle_ornit.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        emptyTitle_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        emptyTitle_ornit.textAlignment = .center
        emptyView_Ornit.addSubview(emptyTitle_ornit)

        let emptyHint_ornit = UILabel()
        emptyHint_ornit.text = "Try a different keyword or category"
        emptyHint_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        emptyHint_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        emptyHint_ornit.textAlignment = .center
        emptyHint_ornit.numberOfLines = 2
        emptyView_Ornit.addSubview(emptyHint_ornit)

        emptyView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalTo(collectionView_Ornit)
            make_ornit.width.equalTo(240)
        }

        emptyIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.centerX.equalToSuperview()
            make_ornit.width.height.equalTo(72)
        }

        emptyTitle_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(emptyIcon_ornit.snp.bottom).offset(18)
            make_ornit.centerX.equalToSuperview()
        }

        emptyHint_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(emptyTitle_ornit.snp.bottom).offset(8)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
    }

    // MARK: - 事件响应

    /// 搜索框文本变化时触发过滤，并控制清除按钮显隐
    @objc private func searchTextChanged_Ornit() {
        let text_ornit = searchField_Ornit.text ?? ""
        clearButton_Ornit.isHidden = text_ornit.isEmpty
        applyFilter_Ornit()
    }

    /// 清空搜索内容并收起键盘
    @objc private func clearSearch_Ornit() {
        searchField_Ornit.text = ""
        clearButton_Ornit.isHidden = true
        searchField_Ornit.resignFirstResponder()
        applyFilter_Ornit()
    }

    /// 分类按钮点击，更新选中态并重新执行过滤排序
    @objc private func categoryTapped_Ornit(_ sender_ornit: UIButton) {
        selectedCategory_Ornit = sender_ornit.tag
        updateCategorySelection_Ornit(selectedIndex_Ornit: sender_ornit.tag)
        applyFilter_Ornit()
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension Discover_Ornit: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPosts_Ornit.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_ornit = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverPostCell_Ornit.reuseId_Ornit,
            for: indexPath
        ) as! DiscoverPostCell_Ornit
        cell_ornit.configure_Ornit(post_ornit: filteredPosts_Ornit[indexPath.item], viewController_ornit: self)
        return cell_ornit
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Ornit.toTitleDetail_Ornit(titleModel_ornit: filteredPosts_Ornit[indexPath.item])
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Ornit: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Ornit: WaterfallLayoutDelegate_Ornit {

    /// 计算指定位置 Cell 的期望高度
    /// 由媒体预览区固定高度 + 文字内容动态高度 + 底部用户信息行高度三部分组成
    /// - Parameters:
    ///   - collectionView: 目标 CollectionView
    ///   - indexPath: Cell 的索引路径
    ///   - width: 当前列宽
    /// - Returns: Cell 期望总高度（CGFloat）
    func collectionView_Ornit(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat {
        guard indexPath.item < filteredPosts_Ornit.count else { return 230 }
        let post_ornit = filteredPosts_Ornit[indexPath.item]

        // 媒体预览区：奇偶行交替高度，天然形成错落的瀑布流效果
        let mediaHeight_ornit: CGFloat = indexPath.item % 2 == 0 ? 108 : 84

        // 标题区估算高度（最多 2 行，每行约 18pt + 间距）
        let titleHeight_ornit: CGFloat = 42

        // 内容文字区动态高度（基于内容字数，上限 3 行约 80pt）
        let contentLen_ornit = CGFloat(min(post_ornit.titleContent_Ornit.count, 90))
        let contentHeight_ornit: CGFloat = 22 + contentLen_ornit * 0.28

        // 底部用户信息行（头像 + 昵称 + 评论数）
        let bottomHeight_ornit: CGFloat = 48

        return mediaHeight_ornit + titleHeight_ornit + contentHeight_ornit + bottomHeight_ornit
    }
}

// MARK: - 瀑布流布局代理协议

/// 瀑布流布局高度代理协议
/// 布局对象通过此协议向外部询问每个 Cell 的高度，实现不等高瀑布流
protocol WaterfallLayoutDelegate_Ornit: AnyObject {

    /// 返回指定 Cell 在给定列宽下的期望高度
    /// - Parameters:
    ///   - collectionView: 目标 CollectionView
    ///   - indexPath: Cell 的索引路径
    ///   - width: 当前列的可用宽度
    /// - Returns: Cell 的期望高度（CGFloat）
    func collectionView_Ornit(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat
}

// MARK: - 自定义瀑布流布局

/// 双列不等高瀑布流布局（Pinterest 风格）
/// 功能：通过代理协议获取每个 Cell 高度，按最矮列优先填充策略排列 Cell
/// 关键属性：delegate_Ornit（高度代理）、numberOfColumns_Ornit（列数）、cellPadding_Ornit（间距）
class WaterfallLayout_Ornit: UICollectionViewLayout {

    // MARK: - 配置属性

    /// 布局高度代理
    weak var delegate_Ornit: WaterfallLayoutDelegate_Ornit?

    /// 列数（默认 2 列）
    var numberOfColumns_Ornit: Int = 2

    /// Cell 之间的间距（水平和垂直统一）
    var cellPadding_Ornit: CGFloat = 8

    /// 内容区域内边距
    var contentInset_Ornit: UIEdgeInsets = .zero

    // MARK: - 私有属性

    /// 布局属性缓存（避免每次访问重复计算）
    private var cache_Ornit: [UICollectionViewLayoutAttributes] = []

    /// 内容总高度（用于 collectionViewContentSize）
    private var contentHeight_Ornit: CGFloat = 0

    /// 可用内容宽度（扣除左右内边距）
    private var contentWidth_Ornit: CGFloat {
        guard let cv_ornit = collectionView else { return 0 }
        return cv_ornit.bounds.width - contentInset_Ornit.left - contentInset_Ornit.right
    }

    /// 重置高度缓存（数据源变化后必须调用，否则布局不更新）
    func resetCache_Ornit() {
        cache_Ornit = []
        contentHeight_Ornit = 0
    }

    // MARK: - 布局计算

    override func prepare() {
        guard let cv_ornit = collectionView, cache_Ornit.isEmpty else { return }

        contentHeight_Ornit = 0

        // 计算每列宽度：总宽度 - (列数-1) 个间距，再均分
        let columnWidth_ornit = (contentWidth_Ornit - CGFloat(numberOfColumns_Ornit - 1) * cellPadding_Ornit)
            / CGFloat(numberOfColumns_Ornit)

        // 各列当前纵向偏移（初始值为顶部内边距）
        var yOffsets_ornit = Array(repeating: contentInset_Ornit.top, count: numberOfColumns_Ornit)

        // 各列的横向起始 X 坐标
        let xOffsets_ornit = (0..<numberOfColumns_Ornit).map { col_ornit in
            contentInset_Ornit.left + CGFloat(col_ornit) * (columnWidth_ornit + cellPadding_Ornit)
        }

        let count_ornit = cv_ornit.numberOfItems(inSection: 0)

        for item_ornit in 0..<count_ornit {
            let indexPath_ornit = IndexPath(item: item_ornit, section: 0)

            // 选取当前纵向偏移最小的列（最矮列优先）
            let col_ornit = yOffsets_ornit.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0

            let height_ornit = delegate_Ornit?.collectionView_Ornit(
                cv_ornit,
                heightForItemAt: indexPath_ornit,
                withWidth: columnWidth_ornit
            ) ?? 200

            let frame_ornit = CGRect(
                x: xOffsets_ornit[col_ornit],
                y: yOffsets_ornit[col_ornit],
                width: columnWidth_ornit,
                height: height_ornit
            )

            let attrs_ornit = UICollectionViewLayoutAttributes(forCellWith: indexPath_ornit)
            attrs_ornit.frame = frame_ornit
            cache_Ornit.append(attrs_ornit)

            contentHeight_Ornit = max(contentHeight_Ornit, frame_ornit.maxY + contentInset_Ornit.bottom)
            yOffsets_ornit[col_ornit] += height_ornit + cellPadding_Ornit
        }
    }

    override var collectionViewContentSize: CGSize {
        CGSize(
            width: contentWidth_Ornit + contentInset_Ornit.left + contentInset_Ornit.right,
            height: contentHeight_Ornit
        )
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache_Ornit.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache_Ornit[safeIndex_Ornit: indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv_ornit = collectionView else { return false }
        return newBounds.width != cv_ornit.bounds.width
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache_Ornit = []
        contentHeight_Ornit = 0
    }
}

// MARK: - Array 安全下标扩展

private extension Array {
    /// 安全下标访问，索引越界时返回 nil 而非崩溃
    subscript(safeIndex_Ornit index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - 发现页帖子卡片 Cell

/// 发现页帖子卡片 Cell
/// 功能：展示帖子的渐变媒体预览区（含点赞气泡）、标题、内容摘要、发布者信息及互动数据
/// 设计：顶部渐变媒体区 → 文字内容区 → 分割线 → 底部用户信息行
class DiscoverPostCell_Ornit: UICollectionViewCell {

    static let reuseId_Ornit = "DiscoverPostCell_Ornit"

    // MARK: - UI 组件

    /// 卡片主容器（白色背景、大圆角、青绿阴影）
    private let cardView_Ornit = UIView()

    /// 媒体展示视图（自动处理图片/视频/占位符，替代原渐变+图标方案）
    private let mediaDisplayView_Ornit = MediaDisplayView_Ornit()

    /// 右下角点赞数气泡
    private let likesBadge_Ornit = UIView()

    /// 点赞气泡内文字（"♥ N"格式）
    private let likesBadgeLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label_ornit.textColor = .white
        return label_ornit
    }()

    /// 帖子标题（最多 2 行）
    private let titleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        label_ornit.numberOfLines = 2
        return label_ornit
    }()

    /// 帖子内容摘要（最多 3 行）
    private let contentLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        label_ornit.numberOfLines = 3
        return label_ornit
    }()

    /// 内容区与用户信息行之间的分割线
    private let divider_Ornit: UIView = {
        let v_ornit = UIView()
        v_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        return v_ornit
    }()

    /// 发布者头像
    private let avatarView_Ornit = UserAvatarView_Ornit()

    /// 发布者昵称
    private let nameLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        return label_ornit
    }()

    /// 评论气泡图标
    private let commentIcon_Ornit: UIImageView = {
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let iv_ornit = UIImageView(
            image: UIImage(systemName: "bubble.left.fill", withConfiguration: config_ornit)
        )
        iv_ornit.tintColor = ColorConfig_Ornit.natureTeal_Ornit.withValues(alpha: 0.55)
        iv_ornit.contentMode = .scaleAspectFit
        return iv_ornit
    }()

    /// 评论数标签
    private let commentCountLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        return label_ornit
    }()

    /// 举报 / 删除按钮（每次 configure 时重建，防止复用数据错位）
    private var reportButton_Ornit: UIButton?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Ornit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // MediaDisplayView_Ornit 内部自动处理 layoutSubviews，无需额外同步渐变 frame
    }

    // MARK: - UI 搭建

    private func setupUI_Ornit() {
        contentView.backgroundColor = .clear

        // 卡片容器：白色背景 + 大圆角 + 青绿色阴影
        cardView_Ornit.backgroundColor = .white
        cardView_Ornit.layer.cornerRadius = 18
        cardView_Ornit.layer.shadowColor = ColorConfig_Ornit.natureTeal_Ornit.withValues(alpha: 0.15).cgColor
        cardView_Ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView_Ornit.layer.shadowOpacity = 1
        cardView_Ornit.layer.shadowRadius = 10
        contentView.addSubview(cardView_Ornit)

        // 媒体展示区：使用 MediaDisplayView_Ornit 自动处理图片/视频/占位
        mediaDisplayView_Ornit.layer.cornerRadius = 18
        mediaDisplayView_Ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mediaDisplayView_Ornit.clipsToBounds = true

        // 点赞气泡叠加在媒体区右下角
        likesBadge_Ornit.backgroundColor = UIColor.black.withValues(alpha: 0.26)
        likesBadge_Ornit.layer.cornerRadius = 10
        mediaDisplayView_Ornit.addSubview(likesBadge_Ornit)
        likesBadge_Ornit.addSubview(likesBadgeLabel_Ornit)

        cardView_Ornit.addSubview(mediaDisplayView_Ornit)
        cardView_Ornit.addSubview(titleLabel_Ornit)
        cardView_Ornit.addSubview(contentLabel_Ornit)
        cardView_Ornit.addSubview(divider_Ornit)
        cardView_Ornit.addSubview(avatarView_Ornit)
        cardView_Ornit.addSubview(nameLabel_Ornit)
        cardView_Ornit.addSubview(commentIcon_Ornit)
        cardView_Ornit.addSubview(commentCountLabel_Ornit)

        cardView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }

        // 媒体区固定高度（与 heightForItemAt 中的 mediaHeight 保持一致）
        mediaDisplayView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(95)
        }

        likesBadge_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-8)
            make_ornit.bottom.equalToSuperview().offset(-8)
            make_ornit.height.equalTo(20)
        }

        likesBadgeLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerY.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview().inset(7)
        }

        titleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(mediaDisplayView_Ornit.snp.bottom).offset(10)
            make_ornit.leading.trailing.equalToSuperview().inset(12)
        }

        contentLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleLabel_Ornit.snp.bottom).offset(5)
            make_ornit.leading.trailing.equalToSuperview().inset(12)
        }

        // 分割线固定在底部上方 40pt
        divider_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.equalToSuperview().inset(12)
            make_ornit.bottom.equalToSuperview().offset(-40)
            make_ornit.height.equalTo(0.5)
        }

        avatarView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(12)
            make_ornit.bottom.equalToSuperview().offset(-12)
            make_ornit.width.height.equalTo(22)
        }

        nameLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(avatarView_Ornit.snp.trailing).offset(5)
            make_ornit.centerY.equalTo(avatarView_Ornit)
            make_ornit.trailing.lessThanOrEqualTo(commentIcon_Ornit.snp.leading).offset(-6)
        }

        commentIcon_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalTo(commentCountLabel_Ornit.snp.leading).offset(-3)
            make_ornit.centerY.equalTo(avatarView_Ornit)
            make_ornit.width.height.equalTo(12)
        }

        commentCountLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.centerY.equalTo(avatarView_Ornit)
        }
    }

    // MARK: - 数据配置

    /// 配置 Cell 显示内容
    /// - Parameters:
    ///   - post_ornit: 帖子数据模型
    ///   - viewController_ornit: 当前所在视图控制器（用于举报 / 删除弹窗）
    func configure_Ornit(post_ornit: TitleModel_Ornit, viewController_ornit: UIViewController) {
        avatarView_Ornit.configure_Ornit(userId_Ornit: post_ornit.titleUserId_Ornit)
        nameLabel_Ornit.text = post_ornit.titleUserName_Ornit
        titleLabel_Ornit.text = post_ornit.title_Ornit
        contentLabel_Ornit.text = post_ornit.titleContent_Ornit
        likesBadgeLabel_Ornit.text = "♥ \(post_ornit.likes_Ornit)"
        commentCountLabel_Ornit.text = "\(post_ornit.reviews_Ornit.count)"

        // 配置媒体展示（MediaDisplayView_Ornit 自动处理图片/视频/占位，覆盖所有媒体类型）
        mediaDisplayView_Ornit.configure_Ornit(mediaPath_Ornit: post_ornit.titleMeidas_Ornit.first)

        // 移除旧举报按钮，防止 Cell 复用时残留上一条数据的按钮
        reportButton_Ornit?.removeFromSuperview()

        let btn_ornit = ReportDeleteHelper_Ornit.createPostReportButton_Ornit(
            post_Ornit: post_ornit,
            size_Ornit: 13,
            color_Ornit: UIColor.white.withValues(alpha: 0.72),
            from: viewController_ornit
        )
        mediaDisplayView_Ornit.addSubview(btn_ornit)
        btn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-8)
            make_ornit.top.equalToSuperview().offset(8)
            make_ornit.width.height.equalTo(24)
        }
        reportButton_Ornit = btn_ornit
    }
}
