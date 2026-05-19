import Foundation
import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页视图控制器
/// 核心作用：以双列不等高瀑布流展示帖子，支持搜索、分类筛选、举报/删除，空结果居中缺省图
/// 设计思路：
///   - 顶栏采用暗色"胶片负片"风格（深暗底色 + 左右穿孔条 + 琥珀金配色），与首页暖橙形成互补
///   - 分类标签真实驱动关键词过滤，搜索与分类可叠加
///   - 无数据时显示居中缺省视图
/// 关键属性：
///   - posts_Lumia: 全量帖子缓存
///   - filteredPosts_Lumia: 当前展示的过滤后帖子
///   - currentCategory_Lumia: 当前选中分类名
///   - searchKeyword_Lumia: 当前搜索关键词
class Discover_Lumia: UIViewController {

    // MARK: - 私有属性

    private var posts_Lumia: [TitleModel_Lumia] = []
    private var filteredPosts_Lumia: [TitleModel_Lumia] = []

    /// 当前选中分类（"All" 表示全部）
    private var currentCategory_Lumia: String = "All"

    /// 当前搜索关键词（小写）
    private var searchKeyword_Lumia: String = ""

    /// 分类关键词映射表（用于在标题+内容中匹配分类）
    private let categoryKeywords_Lumia: [String: [String]] = [
        "All":       [],
        "Portrait":  ["portrait", "portra", "skin", "medium format", "mamiya", "face"],
        "Landscape": ["landscape", "autumn", "velvia", "golden hour", "nature", "lomography"],
        "Street":    ["street", "rain", "architecture", "hp5", "city", "sidewalk"],
        "Night":     ["night", "midnight", "3200", "dark"],
        "Film":      ["darkroom", "expired", "ektachrome", "light leak", "roll", "negative", "tray"]
    ]

    private let waterfallLayout_Lumia = WaterfallLayout_Lumia()

    private lazy var collectionView_Lumia: UICollectionView = {
        let cv_Lumia = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout_Lumia)
        cv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")
        cv_Lumia.showsVerticalScrollIndicator = false
        cv_Lumia.contentInset = UIEdgeInsets(top: 10, left: 12, bottom: 100, right: 12)
        return cv_Lumia
    }()

    /// 空结果缺省视图（搜索或分类无数据时居中展示）
    private let emptyStateView_Lumia = DiscoverEmptyView_Lumia()

    private let topBar_Lumia = DiscoverTopBar_Lumia()
    private let categoryBar_Lumia = DiscoverCategoryBar_Lumia()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        setupObservers_Lumia()
        loadData_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")

        view.addSubview(topBar_Lumia)
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        topBar_Lumia.onSearchChanged_Lumia = { [weak self] keyword_Lumia in
            self?.searchKeyword_Lumia = keyword_Lumia.lowercased()
            self?.applyFilters_Lumia()
        }

        view.addSubview(categoryBar_Lumia)
        categoryBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        categoryBar_Lumia.configure_Lumia(
            categories_Lumia: ["All", "Portrait", "Landscape", "Street", "Night", "Film"]
        )
        categoryBar_Lumia.onCategorySelected_Lumia = { [weak self] index_Lumia in
            let names_Lumia = ["All", "Portrait", "Landscape", "Street", "Night", "Film"]
            guard index_Lumia < names_Lumia.count else { return }
            self?.currentCategory_Lumia = names_Lumia[index_Lumia]
            self?.applyFilters_Lumia()
        }

        view.addSubview(collectionView_Lumia)
        collectionView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(categoryBar_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 空结果缺省视图——居中于 collectionView 所在区域
        view.addSubview(emptyStateView_Lumia)
        emptyStateView_Lumia.snp.makeConstraints { make in
            make.center.equalTo(collectionView_Lumia)
            make.width.equalTo(220)
        }
        emptyStateView_Lumia.isHidden = true

        waterfallLayout_Lumia.delegate_Lumia = self
        waterfallLayout_Lumia.numberOfColumns_Lumia = 2
        waterfallLayout_Lumia.cellPadding_Lumia = 6

        collectionView_Lumia.delegate = self
        collectionView_Lumia.dataSource = self
        collectionView_Lumia.register(
            DiscoverPostCell_Lumia.self,
            forCellWithReuseIdentifier: DiscoverPostCell_Lumia.reuseId_Lumia
        )
    }

    // MARK: - 数据

    private func loadData_Lumia() {
        posts_Lumia = TitleViewModel_Lumia.shared_Lumia.getPosts_Lumia()
        applyFilters_Lumia()
        triggerEntryAnimation_Lumia()
    }

    private func reloadData_Lumia() {
        posts_Lumia = TitleViewModel_Lumia.shared_Lumia.getPosts_Lumia()
        applyFilters_Lumia()
    }

    /// 同时应用分类过滤 + 搜索关键词过滤，二者叠加生效
    private func applyFilters_Lumia() {
        var result_Lumia = posts_Lumia

        // 分类过滤（All 时跳过）
        if currentCategory_Lumia != "All",
           let keywords_Lumia = categoryKeywords_Lumia[currentCategory_Lumia],
           !keywords_Lumia.isEmpty {
            result_Lumia = result_Lumia.filter { post_Lumia in
                let haystack_Lumia = (post_Lumia.title_Lumia + " " + post_Lumia.titleContent_Lumia).lowercased()
                return keywords_Lumia.contains { haystack_Lumia.contains($0) }
            }
        }

        // 搜索关键词过滤
        if !searchKeyword_Lumia.isEmpty {
            result_Lumia = result_Lumia.filter {
                $0.title_Lumia.lowercased().contains(searchKeyword_Lumia) ||
                $0.titleContent_Lumia.lowercased().contains(searchKeyword_Lumia) ||
                $0.titleUserName_Lumia.lowercased().contains(searchKeyword_Lumia)
            }
        }

        filteredPosts_Lumia = result_Lumia
        waterfallLayout_Lumia.invalidateLayout()
        collectionView_Lumia.reloadData()
        updateEmptyState_Lumia()
    }

    /// 根据过滤结果切换空状态视图与列表视图的显示
    private func updateEmptyState_Lumia() {
        let isEmpty_Lumia = filteredPosts_Lumia.isEmpty
        emptyStateView_Lumia.isHidden = !isEmpty_Lumia
        collectionView_Lumia.isHidden = isEmpty_Lumia
        if !isEmpty_Lumia { triggerEntryAnimation_Lumia() }
    }

    /// 卡片入场弹簧缩放动画
    private func triggerEntryAnimation_Lumia() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            for (idx_Lumia, cell_Lumia) in self.collectionView_Lumia.visibleCells.enumerated() {
                cell_Lumia.alpha = 0
                cell_Lumia.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
                UIView.animate(
                    withDuration: 0.55,
                    delay: Double(idx_Lumia) * 0.065,
                    usingSpringWithDamping: 0.78,
                    initialSpringVelocity: 0.4,
                    options: .curveEaseOut
                ) {
                    cell_Lumia.alpha = 1
                    cell_Lumia.transform = .identity
                }
            }
        }
    }

    // MARK: - 通知

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleChange_Lumia),
            name: TitleViewModel_Lumia.titleStateDidChangeNotification_Lumia, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUserChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleTitleChange_Lumia() { reloadData_Lumia() }
    @objc private func handleUserChange_Lumia() { reloadData_Lumia() }
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UICollectionViewDelegate & DataSource

extension Discover_Lumia: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPosts_Lumia.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Lumia = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverPostCell_Lumia.reuseId_Lumia,
            for: indexPath
        ) as! DiscoverPostCell_Lumia
        let post_Lumia = filteredPosts_Lumia[indexPath.item]
        cell_Lumia.configure_Lumia(post: post_Lumia, from: self)
        cell_Lumia.onUserTapped_Lumia = { userId_Lumia in
            let user_Lumia = UserViewModel_Lumia.shared_Lumia.getUserById_Lumia(userId_lumia: userId_Lumia)
            Navigation_Lumia.toUserInfo_Lumia(with: user_Lumia)
        }
        return cell_Lumia
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Lumia.toTitleDetail_Lumia(titleModel_lumia: filteredPosts_Lumia[indexPath.item])
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Lumia: WaterfallLayoutDelegate_Lumia {

    func collectionView_Lumia(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat {
        let post_Lumia = filteredPosts_Lumia[indexPath.item]
        let mediaHeight_Lumia: CGFloat = indexPath.item % 3 == 0 ? 185 : (indexPath.item % 3 == 1 ? 145 : 165)
        let extraHeight_Lumia: CGFloat = post_Lumia.titleContent_Lumia.count > 80 ? 18 : 0
        return mediaHeight_Lumia + 112 + extraHeight_Lumia
    }
}

// MARK: - 发现页顶部栏

/// 发现页顶部栏
/// 核心作用：展示品牌标题、副标题、EXIF 风格统计数据及搜索入口
/// 设计思路：
///   - 参考发布页风格：饱和渐变色背景 + 底部圆角，简洁无边框
///   - 紫色 → 蓝色主渐变（与首页橙色形成冷暖互补）
///   - 全白文字，搜索框半透明白色（与发布页关闭按钮同样处理）
///   - 搜索框底部 + 下边距约束到视图底部，驱动自适应高度
private class DiscoverTopBar_Lumia: UIView {

    var onSearchChanged_Lumia: ((String) -> Void)?

    /// 背景渐变图层
    private var bgGradient_Lumia: CAGradientLayer?

    // 相机光圈图标（白色）
    private let apertureIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "camera.aperture")
        iv_Lumia.tintColor = .white
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    // 主标题 DISCOVER
    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Discover"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 26) ?? UIFont.boldSystemFont(ofSize: 26)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    // 副标题（白色，低透明度）
    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Explore extraordinary shots on film"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.75)
        lbl_Lumia.adjustsFontSizeToFitWidth = true
        lbl_Lumia.minimumScaleFactor = 0.8
        return lbl_Lumia
    }()

    // EXIF 风格统计标签（等宽字体，白色低透明度）
    private let exifLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 10.5, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.70)
        return lbl_Lumia
    }()

    // 搜索框容器（半透明白色，与发布页关闭按钮同款处理）
    private let searchContainer_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_Lumia.layer.cornerRadius = 22
        v_Lumia.layer.borderWidth = 1
        v_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return v_Lumia
    }()

    private let searchIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "magnifyingglass")
        iv_Lumia.tintColor = UIColor.white.withAlphaComponent(0.80)
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let searchField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.font = UIFont.systemFont(ofSize: 14)
        tf_Lumia.backgroundColor = .clear
        tf_Lumia.textColor = .white
        tf_Lumia.returnKeyType = .search
        tf_Lumia.tintColor = .white
        tf_Lumia.attributedPlaceholder = NSAttributedString(
            string: "Search posts, creators...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.52)]
        )
        return tf_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgGradient_Lumia?.frame = bounds
    }

    /// 更新 EXIF 风格统计数据
    /// - Parameters:
    ///   - postCount_Lumia: 帖子数量
    ///   - creatorCount_Lumia: 创作者数量
    func updateStats_Lumia(postCount_Lumia: Int, creatorCount_Lumia: Int) {
        exifLabel_Lumia.text = "◉ \(postCount_Lumia) SHOTS  ·  \(creatorCount_Lumia) CREATORS  ·  35mm"
    }

    private func setupUI_Lumia() {
        // 与发布页完全一致的橙→珊瑚红渐变
        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F6A623").cgColor,
            UIColor(hexstring_Lumia: "#D4654E").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient_Lumia, at: 0)
        bgGradient_Lumia = gradient_Lumia

        // 底部两侧大圆角，与发布页（cornerRadius 24）及首页风格统一
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 24
        clipsToBounds = true

        // ── 图标 + 标题（同行）──
        addSubview(apertureIcon_Lumia)
        apertureIcon_Lumia.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(apertureIcon_Lumia)
            make.leading.equalTo(apertureIcon_Lumia.snp.trailing).offset(10)
        }

        // ── 副标题 ──
        addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(apertureIcon_Lumia.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // ── EXIF 风格统计 ──
        addSubview(exifLabel_Lumia)
        exifLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Lumia.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        updateStats_Lumia(postCount_Lumia: 248, creatorCount_Lumia: 32)

        // ── 搜索框（底部约束到 view 底部，驱动 topBar 自适应高度）──
        addSubview(searchContainer_Lumia)
        searchContainer_Lumia.snp.makeConstraints { make in
            make.top.equalTo(exifLabel_Lumia.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-18)
        }
        searchContainer_Lumia.addSubview(searchIcon_Lumia)
        searchIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        searchContainer_Lumia.addSubview(searchField_Lumia)
        searchField_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Lumia.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        searchField_Lumia.addTarget(self, action: #selector(searchChanged_Lumia), for: .editingChanged)
    }

    @objc private func searchChanged_Lumia() {
        onSearchChanged_Lumia?(searchField_Lumia.text ?? "")
    }
}

// MARK: - 空结果缺省视图

/// 搜索或分类过滤无结果时居中展示的缺省视图
/// 核心作用：给用户明确的无数据反馈，通过相机图标 + 文案引导
private class DiscoverEmptyView_Lumia: UIView {

    private let iconView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "camera.filters")
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#B794F6", alpha_Lumia: 0.55)
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "No Shots Found"
        lbl_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#4A3580")
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Try a different keyword\nor switch to another category"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#8C7CB8")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Lumia() {
        addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconView_Lumia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - 分类标签横条

/// 发现页分类标签横向滚动条
/// 核心作用：横向滚动分类标签，选中态渐变填充，未选中态淡紫透明，点击触发数据过滤
private class DiscoverCategoryBar_Lumia: UIView {

    var onCategorySelected_Lumia: ((Int) -> Void)?

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsHorizontalScrollIndicator = false
        sv_Lumia.alwaysBounceHorizontal = true
        return sv_Lumia
    }()

    private let stackView_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .horizontal
        sv_Lumia.spacing = 10
        sv_Lumia.alignment = .center
        return sv_Lumia
    }()

    private var categoryButtons_Lumia: [UIButton] = []

    private let categoryIcons_Lumia = [
        "square.grid.2x2.fill",
        "person.crop.rectangle",
        "photo.on.rectangle",
        "figure.walk",
        "moon.stars.fill",
        "film.stack"
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")

        let line_Lumia = UIView()
        line_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#C4B8E8")
        addSubview(line_Lumia)
        line_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(line_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        scrollView_Lumia.addSubview(stackView_Lumia)
        stackView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalToSuperview()
        }
    }

    func configure_Lumia(categories_Lumia: [String]) {
        stackView_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }
        categoryButtons_Lumia.removeAll()

        for (idx_Lumia, title_Lumia) in categories_Lumia.enumerated() {
            let iconName_Lumia = idx_Lumia < categoryIcons_Lumia.count ? categoryIcons_Lumia[idx_Lumia] : "tag"
            let btn_Lumia = makeCategoryButton_Lumia(
                title_Lumia: title_Lumia, iconName_Lumia: iconName_Lumia, index_Lumia: idx_Lumia
            )
            stackView_Lumia.addArrangedSubview(btn_Lumia)
            categoryButtons_Lumia.append(btn_Lumia)
        }
        updateSelection_Lumia(index: 0)
    }

    private func makeCategoryButton_Lumia(title_Lumia: String, iconName_Lumia: String, index_Lumia: Int) -> UIButton {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let icon_Lumia = UIImage(systemName: iconName_Lumia, withConfiguration: cfg_Lumia)

        var config_Lumia = UIButton.Configuration.plain()
        config_Lumia.title = title_Lumia
        config_Lumia.image = icon_Lumia
        config_Lumia.imagePadding = 5
        config_Lumia.imagePlacement = .leading
        config_Lumia.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return outgoing
        }
        config_Lumia.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
        btn_Lumia.configuration = config_Lumia
        btn_Lumia.layer.cornerRadius = 16
        btn_Lumia.tag = index_Lumia
        btn_Lumia.addTarget(self, action: #selector(categoryTapped_Lumia(_:)), for: .touchUpInside)
        return btn_Lumia
    }

    private func updateSelection_Lumia(index: Int) {
        for (idx_Lumia, btn_Lumia) in categoryButtons_Lumia.enumerated() {
            btn_Lumia.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            if idx_Lumia == index {
                btn_Lumia.tintColor = .white
                btn_Lumia.configuration?.baseForegroundColor = .white
                btn_Lumia.backgroundColor = .clear
                let gradient_Lumia = CAGradientLayer()
                gradient_Lumia.colors = [
                    UIColor(hexstring_Lumia: "#6A40C0").cgColor,
                    UIColor(hexstring_Lumia: "#3A7ED8").cgColor
                ]
                gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
                gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
                gradient_Lumia.cornerRadius = 16
                btn_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
                DispatchQueue.main.async { gradient_Lumia.frame = btn_Lumia.bounds }
            } else {
                btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#6A40C0")
                btn_Lumia.configuration?.baseForegroundColor = UIColor(hexstring_Lumia: "#6A40C0")
                btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#6A40C0", alpha_Lumia: 0.10)
            }
        }
    }

    @objc private func categoryTapped_Lumia(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        updateSelection_Lumia(index: sender.tag)
        onCategorySelected_Lumia?(sender.tag)
    }
}

// MARK: - 发现页帖子 Cell

/// 发现页帖子卡片 Cell
/// 核心作用：精美卡片展示帖子，含顶部渐变色条、媒体区、悬浮头像、互动行
class DiscoverPostCell_Lumia: UICollectionViewCell {

    static let reuseId_Lumia = "DiscoverPostCell_Lumia"
    var onUserTapped_Lumia: ((Int) -> Void)?

    private var currentPost_Lumia: TitleModel_Lumia?
    private weak var fromVC_Lumia: UIViewController?

    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#3A1A78").cgColor
        v_Lumia.layer.shadowOpacity = 0.13
        v_Lumia.layer.shadowRadius = 16
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_Lumia.clipsToBounds = false
        return v_Lumia
    }()

    // 顶部渐变色条（3pt）
    private let topAccentView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Lumia.layer.cornerRadius = 20
        return v_Lumia
    }()
    private var topAccentGradient_Lumia: CAGradientLayer?

    private let mediaView_Lumia: MediaDisplayView_Lumia = {
        let mv_Lumia = MediaDisplayView_Lumia()
        mv_Lumia.layer.cornerRadius = 20
        mv_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mv_Lumia.clipsToBounds = true
        return mv_Lumia
    }()

    // 媒体区底部渐变遮罩
    private let mediaInnerFade_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }()
    private var innerFadeGradient_Lumia: CAGradientLayer?

    // 头像边框环（悬浮叠加）
    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 17
        v_Lumia.layer.borderWidth = 2.5
        v_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#6A40C0").cgColor
        v_Lumia.backgroundColor = .white
        return v_Lumia
    }()

    private let avatarView_Lumia = UserAvatarView_Lumia()

    private let userNameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10.5, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#5A3FA0")
        return lbl_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let contentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let actionRow_Lumia = UIView()

    private let heartIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "heart.fill")
        iv_Lumia.tintColor = ColorConfig_Lumia.secondaryGradientStart_Lumia
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let likeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        return lbl_Lumia
    }()

    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = ColorConfig_Lumia.textSecondary_Lumia
        return btn_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topAccentGradient_Lumia?.frame = topAccentView_Lumia.bounds
        innerFadeGradient_Lumia?.frame = mediaInnerFade_Lumia.bounds
    }

    private func setupUI_Lumia() {
        backgroundColor = .clear
        contentView.addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 顶部渐变色条
        cardView_Lumia.addSubview(topAccentView_Lumia)
        topAccentView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
        let accentGrad_Lumia = CAGradientLayer()
        accentGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#6A40C0").cgColor,
            UIColor(hexstring_Lumia: "#3A7ED8").cgColor
        ]
        accentGrad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        accentGrad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        accentGrad_Lumia.cornerRadius = 20
        topAccentView_Lumia.layer.insertSublayer(accentGrad_Lumia, at: 0)
        topAccentGradient_Lumia = accentGrad_Lumia

        // 媒体视图
        cardView_Lumia.addSubview(mediaView_Lumia)
        mediaView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.56)
        }

        // 媒体区底部渐变遮罩
        mediaView_Lumia.addSubview(mediaInnerFade_Lumia)
        mediaInnerFade_Lumia.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        let fadeGrad_Lumia = CAGradientLayer()
        fadeGrad_Lumia.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.55).cgColor
        ]
        fadeGrad_Lumia.startPoint = CGPoint(x: 0.5, y: 0)
        fadeGrad_Lumia.endPoint = CGPoint(x: 0.5, y: 1)
        mediaInnerFade_Lumia.layer.insertSublayer(fadeGrad_Lumia, at: 0)
        innerFadeGradient_Lumia = fadeGrad_Lumia

        // 头像环（悬浮叠加媒体底部）
        cardView_Lumia.addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Lumia.snp.bottom).offset(-12)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(34)
        }
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(2.5) }
        avatarView_Lumia.layer.cornerRadius = 13
        avatarView_Lumia.clipsToBounds = true

        let avatarTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Lumia))
        avatarRing_Lumia.addGestureRecognizer(avatarTap_Lumia)
        avatarRing_Lumia.isUserInteractionEnabled = true

        cardView_Lumia.addSubview(userNameLabel_Lumia)
        userNameLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRing_Lumia).offset(6)
            make.leading.equalTo(avatarRing_Lumia.snp.trailing).offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        cardView_Lumia.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Lumia.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        cardView_Lumia.addSubview(contentLabel_Lumia)
        contentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel_Lumia)
        }

        cardView_Lumia.addSubview(actionRow_Lumia)
        actionRow_Lumia.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(26)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        actionRow_Lumia.addSubview(heartIcon_Lumia)
        heartIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        actionRow_Lumia.addSubview(likeLabel_Lumia)
        likeLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(heartIcon_Lumia.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        actionRow_Lumia.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)
    }

    func configure_Lumia(post: TitleModel_Lumia, from vc: UIViewController) {
        currentPost_Lumia = post
        fromVC_Lumia = vc
        avatarView_Lumia.configure_Lumia(userId_Lumia: post.titleUserId_Lumia)
        userNameLabel_Lumia.text = post.titleUserName_Lumia
        mediaView_Lumia.configure_Lumia(mediaPath_Lumia: post.titleMeidas_Lumia.first)
        titleLabel_Lumia.text = post.title_Lumia
        contentLabel_Lumia.text = post.titleContent_Lumia
        likeLabel_Lumia.text = "\(post.likes_Lumia)"
    }

    @objc private func handleReport_Lumia() {
        guard let post_Lumia = currentPost_Lumia, let vc_Lumia = fromVC_Lumia else { return }
        let isMyPost_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(userId_lumia: post_Lumia.titleUserId_Lumia)
        if isMyPost_Lumia {
            ReportDeleteHelper_Lumia.delete_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        } else {
            ReportDeleteHelper_Lumia.report_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        }
    }

    @objc private func handleAvatarTap_Lumia() {
        guard let post_Lumia = currentPost_Lumia else { return }
        onUserTapped_Lumia?(post_Lumia.titleUserId_Lumia)
    }
}

// MARK: - 瀑布流布局

/// 瀑布流布局代理协议
protocol WaterfallLayoutDelegate_Lumia: AnyObject {
    func collectionView_Lumia(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat
}

/// 不等高双列瀑布流布局
class WaterfallLayout_Lumia: UICollectionViewLayout {

    weak var delegate_Lumia: WaterfallLayoutDelegate_Lumia?
    var numberOfColumns_Lumia: Int = 2
    var cellPadding_Lumia: CGFloat = 6

    private var cache_Lumia: [UICollectionViewLayoutAttributes] = []
    private var contentHeight_Lumia: CGFloat = 0
    private var contentWidth_Lumia: CGFloat {
        guard let cv_Lumia = collectionView else { return 0 }
        let insets_Lumia = cv_Lumia.contentInset
        return cv_Lumia.bounds.width - insets_Lumia.left - insets_Lumia.right
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth_Lumia, height: contentHeight_Lumia)
    }

    override func prepare() {
        guard cache_Lumia.isEmpty, let cv_Lumia = collectionView else { return }

        let columnWidth_Lumia = contentWidth_Lumia / CGFloat(numberOfColumns_Lumia)
        var xOffsets_Lumia = (0..<numberOfColumns_Lumia).map { CGFloat($0) * columnWidth_Lumia }
        var yOffsets_Lumia = [CGFloat](repeating: 0, count: numberOfColumns_Lumia)
        var column_Lumia = 0

        for item_Lumia in 0..<cv_Lumia.numberOfItems(inSection: 0) {
            let indexPath_Lumia = IndexPath(item: item_Lumia, section: 0)
            let width_Lumia = columnWidth_Lumia - cellPadding_Lumia * 2
            let height_Lumia = delegate_Lumia?.collectionView_Lumia(
                cv_Lumia, heightForItemAt: indexPath_Lumia, withWidth: width_Lumia
            ) ?? 200
            let frame_Lumia = CGRect(
                x: xOffsets_Lumia[column_Lumia] + cellPadding_Lumia,
                y: yOffsets_Lumia[column_Lumia] + cellPadding_Lumia,
                width: width_Lumia,
                height: height_Lumia
            )
            let attrs_Lumia = UICollectionViewLayoutAttributes(forCellWith: indexPath_Lumia)
            attrs_Lumia.frame = frame_Lumia
            cache_Lumia.append(attrs_Lumia)

            contentHeight_Lumia = max(contentHeight_Lumia, frame_Lumia.maxY)
            yOffsets_Lumia[column_Lumia] += height_Lumia + cellPadding_Lumia * 2
            column_Lumia = yOffsets_Lumia[0] < yOffsets_Lumia[1] ? 0 : 1
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache_Lumia.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache_Lumia[safe_Lumia: indexPath.item]
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache_Lumia.removeAll()
        contentHeight_Lumia = 0
    }
}

// MARK: - Array 安全下标扩展

private extension Array {
    subscript(safe_Lumia index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
