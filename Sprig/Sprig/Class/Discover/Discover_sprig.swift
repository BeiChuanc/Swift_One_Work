import UIKit
import SnapKit

// MARK: 发现页

/// 发现页视图控制器
/// 功能：搜索帖子、标签筛选、横向花卉百科（含底部详情浮层）、热门帖子
/// 布局：TableView.contentInsetAdjustmentBehavior = .never，Header Cell 从 y=0 开始无顶部间隙
/// 动画：标签选中弹性、花卉卡片缩放、底部 sheet 弹出遮盖 TabBar
class Discover_Sprig: UIViewController {

    // MARK: - 数据属性

    private var allFlowers_Sprig: [FlowerModel_Sprig] = []
    private var allTags_Sprig: [FlowerTagModel_Sprig] = []
    private var displayPosts_Sprig: [TitleModel_Sprig] = []
    private var selectedTagIndex_Sprig: Int? = nil
    private var isSearching_Sprig = false
    private var searchKeyword_Sprig = ""

    // MARK: - 花卉详情浮层（window 层）

    // 注意：onDismiss_Sprig 回调不在 lazy 闭包内配置，避免在 deinit 首次触发 lazy 初始化时
    // 闭包中的 [weak self] 对正在析构的 self 建立弱引用，导致 "Cannot form weak reference" 崩溃
    private lazy var flowerSheetView_Sprig: FlowerDetailSheet_Sprig = FlowerDetailSheet_Sprig()
    private var isSheetVisible_Sprig = false

    // MARK: - 安全区域辅助属性

    /// 顶部安全区域高度（状态栏 + 刘海/动态岛），与首页保持一致
    private var safeTop_Sprig: CGFloat {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 44
    }

    // MARK: - Header 引用（与首页保持一致，使用 tableHeaderView 方式）

    /// 顶部渐变背景层（在 viewDidLayoutSubviews 中更新 frame）
    private let discoverGradientLayer_Sprig = CAGradientLayer()
    /// 顶部渐变 Header UIView（safeTop + 88，通过 tableHeaderView 无缝置顶）
    private lazy var discoverHeaderView_Sprig: UIView = buildDiscoverHeaderView_Sprig()

    // MARK: - UI 组件

    private lazy var tableView_Sprig: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        // .never → 第一个 Cell 从 y=0 开始，消除顶部灰色间隙
        tv.contentInsetAdjustmentBehavior = .never
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    private lazy var searchBar_Sprig: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search flowers, tips & posts..."
        sb.backgroundImage = UIImage()
        sb.searchBarStyle = .minimal
        if let tf_sprig = sb.value(forKey: "searchField") as? UITextField {
            tf_sprig.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            tf_sprig.layer.cornerRadius = 14
            tf_sprig.clipsToBounds = true
            tf_sprig.font = .systemFont(ofSize: 14)
        }
        return sb
    }()

    // 标签 CollectionView
    private lazy var tagCollectionView_Sprig: UICollectionView = {
        let layout_sprig = UICollectionViewFlowLayout()
        layout_sprig.scrollDirection = .horizontal
        layout_sprig.minimumInteritemSpacing = 8
        layout_sprig.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout_sprig.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv_sprig = UICollectionView(frame: .zero, collectionViewLayout: layout_sprig)
        cv_sprig.backgroundColor = .clear
        cv_sprig.showsHorizontalScrollIndicator = false
        cv_sprig.register(TagFilterCell_Sprig.self,
                          forCellWithReuseIdentifier: TagFilterCell_Sprig.reuseId_Sprig)
        return cv_sprig
    }()

    // 花卉百科 CollectionView（横向单行）
    private lazy var flowerCollectionView_Sprig: UICollectionView = {
        let layout_sprig = UICollectionViewFlowLayout()
        layout_sprig.scrollDirection = .horizontal
        layout_sprig.itemSize = CGSize(width: 150, height: 185)
        layout_sprig.minimumInteritemSpacing = 12
        layout_sprig.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv_sprig = UICollectionView(frame: .zero, collectionViewLayout: layout_sprig)
        cv_sprig.backgroundColor = .clear
        cv_sprig.showsHorizontalScrollIndicator = false
        cv_sprig.register(FlowerGridCell_Sprig.self,
                          forCellWithReuseIdentifier: FlowerGridCell_Sprig.reuseId_Sprig)
        return cv_sprig
    }()

    // 遮罩层（window 层）
    // 注意：手势不在 lazy 闭包中绑定，避免 UIGestureRecognizer 在闭包内以 ObjC weak 引用
    // 持有 self 时，若 self 处于释放流程则触发 "Cannot form weak reference" 崩溃
    private lazy var overlayView_Sprig: UIView = {
        let v_sprig = UIView()
        v_sprig.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v_sprig.alpha = 0
        return v_sprig
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        // 允许视图延伸至不透明 Bar（状态栏/导航栏）后方，消除顶部白色间隙
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        // view 背景用渐变起始色填充，防止任何残余间隙透出白色
        view.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        setupTableView_Sprig()
        // 在 viewDidLoad 中集中完成所有需要 [weak self] 的配置：
        // 此时 self 完全初始化，ObjC 运行时可安全建立弱引用；
        // 同时强制触发 lazy var 的初始化，确保 deinit 中访问时不再执行首次初始化
        setupOverlayGesture_Sprig()
        setupFlowerSheet_Sprig()
        loadData_Sprig()
        registerNotifications_Sprig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - 搭建 UI

    /// 为遮罩层绑定点击手势
    /// 说明：在 viewDidLoad 中调用，self 完全初始化后再建立 target-action 关系，
    ///       同时强制触发 overlayView_Sprig 的 lazy 初始化，deinit 不再首次初始化该属性
    private func setupOverlayGesture_Sprig() {
        let tap_sprig = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap_Sprig))
        overlayView_Sprig.addGestureRecognizer(tap_sprig)
    }

    /// 配置花卉详情浮层的关闭回调
    /// 说明：在 viewDidLoad 中调用，此时 self 安全可建立弱引用；
    ///       同时强制触发 flowerSheetView_Sprig 的 lazy 初始化，
    ///       确保 deinit 中调用 removeFromSuperview() 时不再执行首次初始化（不再产生 [weak self] 弱引用）
    private func setupFlowerSheet_Sprig() {
        flowerSheetView_Sprig.onDismiss_Sprig = { [weak self] in
            self?.hideFlowerSheet_Sprig()
        }
    }

    private func setupTableView_Sprig() {
        view.addSubview(tableView_Sprig)
        tableView_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        tableView_Sprig.delegate   = self
        tableView_Sprig.dataSource = self
        tableView_Sprig.register(UITableViewCell.self, forCellReuseIdentifier: "BaseCell_Sprig")
        tableView_Sprig.register(PostCardTableCell_Sprig.self,
                                 forCellReuseIdentifier: PostCardTableCell_Sprig.reuseId_Sprig)

        tagCollectionView_Sprig.delegate    = self
        tagCollectionView_Sprig.dataSource  = self
        flowerCollectionView_Sprig.delegate  = self
        flowerCollectionView_Sprig.dataSource = self
        searchBar_Sprig.delegate = self

        // 与首页对齐：使用 tableHeaderView 让渐变头从 y=0 无间距置顶
        tableView_Sprig.tableHeaderView = discoverHeaderView_Sprig
        // iOS 15+ 消除 section 顶部默认内边距，防止出现额外间距
        if #available(iOS 15.0, *) {
            tableView_Sprig.sectionHeaderTopPadding = 0
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 保持渐变层 frame 与 header 尺寸同步
        discoverGradientLayer_Sprig.frame = discoverHeaderView_Sprig.bounds
    }

    // MARK: - 数据加载

    private func loadData_Sprig() {
        allFlowers_Sprig  = DiscoverViewModel_Sprig.shared_Sprig.getAllFlowers_Sprig()
        allTags_Sprig     = DiscoverViewModel_Sprig.shared_Sprig.getAllTags_Sprig()
        displayPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
        tableView_Sprig.reloadData()
    }

    private func registerNotifications_Sprig() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleStateChanged_Sprig),
            name: TitleViewModel_Sprig.titleStateDidChangeNotification_Sprig,
            object: nil
        )
    }

    @objc private func onTitleStateChanged_Sprig() { reloadPosts_Sprig() }

    // MARK: - 数据更新

    private func reloadPosts_Sprig() {
        if isSearching_Sprig {
            displayPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig
                .searchPosts_Sprig(keyword_sprig: searchKeyword_Sprig)
            // 搜索模式：结果在 section 0
            tableView_Sprig.reloadSections(IndexSet(integer: 0), with: .automatic)
        } else if let idx_sprig = selectedTagIndex_Sprig {
            displayPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig
                .getPostsByTag_Sprig(tag_sprig: allTags_Sprig[idx_sprig])
            // 正常模式：帖子在 section 2
            tableView_Sprig.reloadSections(IndexSet(integer: 2), with: .automatic)
        } else {
            displayPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
            tableView_Sprig.reloadSections(IndexSet(integer: 2), with: .automatic)
        }
    }

    // MARK: - 花卉详情浮层（window 层）

    private func setupWindowOverlay_Sprig() {
        guard let kw_sprig = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first,
              overlayView_Sprig.superview == nil else { return }
        kw_sprig.addSubview(overlayView_Sprig)
        overlayView_Sprig.frame = kw_sprig.bounds
        kw_sprig.addSubview(flowerSheetView_Sprig)
        flowerSheetView_Sprig.frame = CGRect(x: 0, y: kw_sprig.bounds.height,
                                             width: kw_sprig.bounds.width, height: 440)
    }

    private func showFlowerSheet_Sprig(flower_sprig: FlowerModel_Sprig) {
        guard !isSheetVisible_Sprig else { return }
        isSheetVisible_Sprig = true
        setupWindowOverlay_Sprig()
        guard let kw_sprig = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        let h_sprig: CGFloat = 440
        let desc_sprig = DiscoverViewModel_Sprig.shared_Sprig
            .bloomMonthsDescription_Sprig(months_sprig: flower_sprig.bloomMonths_Sprig)
        flowerSheetView_Sprig.configure_Sprig(flower_sprig: flower_sprig, bloomDesc_sprig: desc_sprig)
        kw_sprig.bringSubviewToFront(overlayView_Sprig)
        kw_sprig.bringSubviewToFront(flowerSheetView_Sprig)
        UIView.animate(withDuration: AnimationConfig_Sprig.durationSpring_Sprig, delay: 0,
                       usingSpringWithDamping: AnimationConfig_Sprig.springDampingNormal_Sprig,
                       initialSpringVelocity: AnimationConfig_Sprig.springVelocity_Sprig,
                       options: .curveEaseOut) {
            self.overlayView_Sprig.alpha = 1
            self.flowerSheetView_Sprig.frame = CGRect(x: 0, y: kw_sprig.bounds.height - h_sprig,
                                                      width: kw_sprig.bounds.width, height: h_sprig)
        }
    }

    private func hideFlowerSheet_Sprig() {
        guard isSheetVisible_Sprig else { return }
        isSheetVisible_Sprig = false
        guard let kw_sprig = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        UIView.animate(withDuration: AnimationConfig_Sprig.durationNormal_Sprig, delay: 0,
                       options: .curveEaseIn) {
            self.overlayView_Sprig.alpha = 0
            self.flowerSheetView_Sprig.frame.origin.y = kw_sprig.bounds.height
        }
    }

    @objc private func handleOverlayTap_Sprig() { hideFlowerSheet_Sprig() }

    deinit {
        NotificationCenter.default.removeObserver(self)
        overlayView_Sprig.removeFromSuperview()
        flowerSheetView_Sprig.removeFromSuperview()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension Discover_Sprig: UITableViewDataSource, UITableViewDelegate {

    /// 三个 section（渐变 header 已迁移至 tableHeaderView，与首页保持一致）
    /// 正常模式：0=标签筛选(searchBar 作 section header), 1=花卉百科, 2=帖子
    /// 搜索模式：0=搜索结果, 1=空, 2=空

    func numberOfSections(in tableView: UITableView) -> Int { return 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return isSearching_Sprig ? displayPosts_Sprig.count : 1
        case 1: return isSearching_Sprig ? 0 : 1
        case 2: return isSearching_Sprig ? 0 : displayPosts_Sprig.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // 搜索模式展示帖子结果；正常模式展示标签筛选
            if isSearching_Sprig { return buildPostCell_Sprig(tableView: tableView, indexPath: indexPath) }
            return buildTagFilterCell_Sprig(tableView: tableView)
        case 1: return buildFlowerHorizontalCell_Sprig(tableView: tableView)
        case 2: return buildPostCell_Sprig(tableView: tableView, indexPath: indexPath)
        default: return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return isSearching_Sprig ? UITableView.automaticDimension : 58
        case 1: return isSearching_Sprig ? 0 : (44 + 4 + 185 + 8)
        case 2: return UITableView.automaticDimension
        default: return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            // 搜索框常驻于标签筛选（或搜索结果）上方，10pt 间距
            return buildSearchBarHeaderView_Sprig()
        case 2:
            if isSearching_Sprig { return nil }
            return buildPostSectionHeader_Sprig(
                title_sprig: selectedTagIndex_Sprig != nil
                    ? "\(allTags_Sprig[selectedTagIndex_Sprig!].tagName_Sprig) Posts 🌿"
                    : "Hot Posts 🔥",
                count_sprig: displayPosts_Sprig.count
            )
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 64   // 搜索框高度：10(top) + 44(searchBar) + 10(bottom)
        case 2: return isSearching_Sprig ? 0 : 48
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 搜索模式帖子在 section 0，正常模式在 section 2
        let isPostSection_sprig = indexPath.section == (isSearching_Sprig ? 0 : 2)
        if isPostSection_sprig {
            cell.alpha = 0
            cell.animateSlideInFromBottom_Sprig(offset_Sprig: 30,
                                                delay_Sprig: Double(indexPath.row % 4) * 0.06)
        }
    }

    // MARK: - Header 视图构建（仿首页 tableHeaderView 方式）

    /// 发现页顶部渐变 Header UIView
    /// 高度 = safeTop + 88，与首页保持一致；渐变层在 viewDidLayoutSubviews 中动态更新 frame
    private func buildDiscoverHeaderView_Sprig() -> UIView {
        let safeTop_sprig = safeTop_Sprig
        let h_sprig: CGFloat = safeTop_sprig + 88
        let container_sprig = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: APPSCREEN_Sprig.WIDTH_Sprig,
                                                   height: h_sprig))
        container_sprig.backgroundColor = .clear

        // 渐变背景（frame 在 viewDidLayoutSubviews 更新）
        discoverGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        discoverGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        discoverGradientLayer_Sprig.endPoint   = CGPoint(x: 1, y: 1)
        container_sprig.layer.insertSublayer(discoverGradientLayer_Sprig, at: 0)

        // 装饰圆 右上
        let decorTR_sprig = UIView()
        decorTR_sprig.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        decorTR_sprig.layer.cornerRadius = 55
        container_sprig.addSubview(decorTR_sprig)
        decorTR_sprig.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(28)
        }

        // 装饰圆 左下
        let decorBL_sprig = UIView()
        decorBL_sprig.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        decorBL_sprig.layer.cornerRadius = 30
        container_sprig.addSubview(decorBL_sprig)
        decorBL_sprig.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.bottom.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(60)
        }

        // 装饰花点（与首页风格一致）
        let petalData_sprig: [(String, CGFloat, CGFloat)] = [
            ("✿", 265, safeTop_sprig + 28),
            ("🌸", 312, safeTop_sprig + 52),
            ("🌼", 235, safeTop_sprig + 62)
        ]
        for (emoji_sprig, x_sprig, y_sprig) in petalData_sprig {
            let el_sprig = UILabel()
            el_sprig.text = emoji_sprig
            el_sprig.font = .systemFont(ofSize: 16)
            el_sprig.alpha = 0.3
            container_sprig.addSubview(el_sprig)
            el_sprig.frame = CGRect(x: x_sprig, y: y_sprig, width: 24, height: 24)
        }

        // 大标题（safeTop + 10，对齐首页 safeTop + 8 风格，紧贴状态栏下方）
        let titleL_sprig = UILabel()
        titleL_sprig.text = "Discover 🌸"
        titleL_sprig.font = .systemFont(ofSize: 28, weight: .bold)
        titleL_sprig.textColor = .white
        container_sprig.addSubview(titleL_sprig)
        titleL_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_sprig + 10)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }

        // 副标题
        let subL_sprig = UILabel()
        subL_sprig.text = "Explore flowers, care tips & more"
        subL_sprig.font = .systemFont(ofSize: 13)
        subL_sprig.textColor = UIColor.white.withAlphaComponent(0.85)
        container_sprig.addSubview(subL_sprig)
        subL_sprig.snp.makeConstraints { make in
            make.top.equalTo(titleL_sprig.snp.bottom).offset(3)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }

        return container_sprig
    }

    // MARK: - Cell 构建

    /// 搜索栏 Header 视图（常驻于标签筛选上方，10pt 间距）
    /// 参数无，返回包含 searchBar 的容器视图
    private func buildSearchBarHeaderView_Sprig() -> UIView {
        let container_sprig = UIView()
        container_sprig.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig
        container_sprig.addSubview(searchBar_Sprig)
        searchBar_Sprig.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-10)
        }
        return container_sprig
    }

    /// 标签筛选行
    private func buildTagFilterCell_Sprig(tableView: UITableView) -> UITableViewCell {
        let cell_sprig = UITableViewCell(style: .default, reuseIdentifier: "TagFilterCell")
        cell_sprig.selectionStyle = .none
        cell_sprig.backgroundColor = .clear
        cell_sprig.contentView.addSubview(tagCollectionView_Sprig)
        tagCollectionView_Sprig.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
        return cell_sprig
    }

    /// 花卉百科横向行
    private func buildFlowerHorizontalCell_Sprig(tableView: UITableView) -> UITableViewCell {
        let cell_sprig = UITableViewCell(style: .default, reuseIdentifier: "FlowerHorizontalCell")
        cell_sprig.selectionStyle = .none
        cell_sprig.backgroundColor = .clear

        let header_sprig = buildEncycHeader_Sprig()
        cell_sprig.contentView.addSubview(header_sprig)
        header_sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        cell_sprig.contentView.addSubview(flowerCollectionView_Sprig)
        flowerCollectionView_Sprig.snp.remakeConstraints { make in
            make.top.equalTo(header_sprig.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(185)
            make.bottom.equalToSuperview().offset(-8)
        }
        return cell_sprig
    }

    /// 帖子行
    private func buildPostCell_Sprig(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell_sprig = tableView.dequeueReusableCell(
            withIdentifier: PostCardTableCell_Sprig.reuseId_Sprig,
            for: indexPath
        ) as! PostCardTableCell_Sprig
        if indexPath.row < displayPosts_Sprig.count {
            cell_sprig.configure_Sprig(post_sprig: displayPosts_Sprig[indexPath.row])
            cell_sprig.cardView_Sprig.delegate_Sprig = self
            // 传入 VC 以支持举报/删除 Alert
            cell_sprig.cardView_Sprig.viewController_Sprig = self
        }
        cell_sprig.selectionStyle = .none
        return cell_sprig
    }

    // MARK: - Section Header 视图

    /// 花卉百科区标题（带渐变徽章和计数）
    private func buildEncycHeader_Sprig() -> UIView {
        let v_sprig = UIView()
        v_sprig.backgroundColor = .clear

        let accent_sprig = UIView()
        accent_sprig.backgroundColor = ColorConfig_Sprig.petalPink_Sprig
        accent_sprig.layer.cornerRadius = 2
        v_sprig.addSubview(accent_sprig)
        accent_sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(18)
        }

        let label_sprig = UILabel()
        label_sprig.text = "Flower Encyclopedia 🌺"
        label_sprig.font = .systemFont(ofSize: 16, weight: .bold)
        label_sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        v_sprig.addSubview(label_sprig)
        label_sprig.snp.makeConstraints { make in
            make.left.equalTo(accent_sprig.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        let countBadge_sprig = UILabel()
        countBadge_sprig.text = "  \(allFlowers_Sprig.count) types  "
        countBadge_sprig.font = .systemFont(ofSize: 10, weight: .semibold)
        countBadge_sprig.textColor = ColorConfig_Sprig.petalPink_Sprig
        countBadge_sprig.backgroundColor = ColorConfig_Sprig.petalPink_Sprig.withAlphaComponent(0.12)
        countBadge_sprig.layer.cornerRadius = 8
        countBadge_sprig.clipsToBounds = true
        v_sprig.addSubview(countBadge_sprig)
        countBadge_sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        return v_sprig
    }

    /// 帖子区 Section Header（带标题 + 计数徽章）
    private func buildPostSectionHeader_Sprig(title_sprig: String, count_sprig: Int) -> UIView {
        let v_sprig = UIView()
        v_sprig.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig

        let accent_sprig = UIView()
        accent_sprig.backgroundColor = ColorConfig_Sprig.bloomOrange_Sprig
        accent_sprig.layer.cornerRadius = 2
        v_sprig.addSubview(accent_sprig)
        accent_sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(18)
        }

        let label_sprig = UILabel()
        label_sprig.text = title_sprig
        label_sprig.font = .systemFont(ofSize: 16, weight: .bold)
        label_sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        v_sprig.addSubview(label_sprig)
        label_sprig.snp.makeConstraints { make in
            make.left.equalTo(accent_sprig.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        let countL_sprig = UILabel()
        countL_sprig.text = "  \(count_sprig) posts  "
        countL_sprig.font = .systemFont(ofSize: 10, weight: .semibold)
        countL_sprig.textColor = ColorConfig_Sprig.bloomOrange_Sprig
        countL_sprig.backgroundColor = ColorConfig_Sprig.bloomOrange_Sprig.withAlphaComponent(0.12)
        countL_sprig.layer.cornerRadius = 8
        countL_sprig.clipsToBounds = true
        v_sprig.addSubview(countL_sprig)
        countL_sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        return v_sprig
    }
}

// MARK: - CollectionView DataSource & Delegate

extension Discover_Sprig: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === tagCollectionView_Sprig    { return allTags_Sprig.count }
        if collectionView === flowerCollectionView_Sprig { return allFlowers_Sprig.count }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === tagCollectionView_Sprig {
            let cell_sprig = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagFilterCell_Sprig.reuseId_Sprig,
                for: indexPath
            ) as! TagFilterCell_Sprig
            cell_sprig.configure_Sprig(tag_sprig: allTags_Sprig[indexPath.item],
                                       isSelected_sprig: selectedTagIndex_Sprig == indexPath.item)
            return cell_sprig
        }
        let cell_sprig = collectionView.dequeueReusableCell(
            withReuseIdentifier: FlowerGridCell_Sprig.reuseId_Sprig,
            for: indexPath
        ) as! FlowerGridCell_Sprig
        let flower_sprig = allFlowers_Sprig[indexPath.item]
        let desc_sprig = DiscoverViewModel_Sprig.shared_Sprig
            .bloomMonthsDescription_Sprig(months_sprig: flower_sprig.bloomMonths_Sprig)
        cell_sprig.configure_Sprig(flower_sprig: flower_sprig, bloomDesc_sprig: desc_sprig)
        return cell_sprig
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === tagCollectionView_Sprig {
            (collectionView.cellForItem(at: indexPath) as? TagFilterCell_Sprig)?.animateTap_Sprig()
            if selectedTagIndex_Sprig == indexPath.item {
                selectedTagIndex_Sprig = nil
                displayPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
            } else {
                selectedTagIndex_Sprig = indexPath.item
                displayPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig
                    .getPostsByTag_Sprig(tag_sprig: allTags_Sprig[indexPath.item])
            }
            tagCollectionView_Sprig.reloadData()
            // 帖子现在在 section 2（原 section 3 已移除）
            tableView_Sprig.reloadSections(IndexSet(integer: 2), with: .fade)
            return
        }
        if collectionView === flowerCollectionView_Sprig {
            (collectionView.cellForItem(at: indexPath) as? FlowerGridCell_Sprig)?.animateTap_Sprig()
            showFlowerSheet_Sprig(flower_sprig: allFlowers_Sprig[indexPath.item])
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if collectionView === flowerCollectionView_Sprig {
            cell.alpha = 0
            cell.animateSpringScaleIn_Sprig(delay_Sprig: Double(indexPath.item % 6) * 0.05)
        }
    }
}

// MARK: - UISearchBarDelegate

extension Discover_Sprig: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard !isSearching_Sprig else { return }
        isSearching_Sprig = true
        searchBar_Sprig.setShowsCancelButton(true, animated: true)
        // tableHeaderView（渐变 header）始终不动，只刷新 section 0-2
        tableView_Sprig.reloadSections(IndexSet(integersIn: 0...2), with: .fade)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKeyword_Sprig = searchText
        displayPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.searchPosts_Sprig(keyword_sprig: searchText)
        // 搜索模式下结果在 section 0
        tableView_Sprig.reloadSections(IndexSet(integer: 0), with: .none)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { exitSearch_Sprig() }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { searchBar.resignFirstResponder() }

    private func exitSearch_Sprig() {
        isSearching_Sprig = false
        searchKeyword_Sprig = ""
        searchBar_Sprig.text = ""
        searchBar_Sprig.setShowsCancelButton(false, animated: true)
        searchBar_Sprig.resignFirstResponder()
        displayPosts_Sprig = selectedTagIndex_Sprig != nil
            ? DiscoverViewModel_Sprig.shared_Sprig.getPostsByTag_Sprig(tag_sprig: allTags_Sprig[selectedTagIndex_Sprig!])
            : DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
        tableView_Sprig.reloadSections(IndexSet(integersIn: 0...2), with: .fade)
    }
}

// MARK: - PostCardDelegate

extension Discover_Sprig: PostCardDelegate_Sprig {

    func postCard_Sprig(_ card_sprig: PostCardView_Sprig, didTapCard_sprig post_sprig: TitleModel_Sprig) {
        Navigation_Sprig.toTitleDetail_Sprig(titleModel_sprig: post_sprig)
    }
    func postCard_Sprig(_ card_sprig: PostCardView_Sprig, didTapUser_sprig post_sprig: TitleModel_Sprig) {
        Navigation_Sprig.toUserInfo_Sprig(with: UserViewModel_Sprig.shared_Sprig
            .getUserById_Sprig(userId_sprig: post_sprig.titleUserId_Sprig))
    }
    func postCard_Sprig(_ card_sprig: PostCardView_Sprig, didTapLike_sprig post_sprig: TitleModel_Sprig) {
        Task { @MainActor in TitleViewModel_Sprig.shared_Sprig.likePost_Sprig(post_sprig: post_sprig) }
    }
}

// MARK: - 标签筛选 Cell

/// 标签筛选横向 CollectionView Cell
class TagFilterCell_Sprig: UICollectionViewCell {

    static let reuseId_Sprig = "TagFilterCell_Sprig"

    private let bgView_Sprig = UIView()
    private let iconView_Sprig = UIImageView()
    private let nameLabel_Sprig = UILabel()

    override init(frame: CGRect) { super.init(frame: frame); setupUI_Sprig() }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI_Sprig() }

    private func setupUI_Sprig() {
        bgView_Sprig.layer.cornerRadius = 16
        contentView.addSubview(bgView_Sprig)
        bgView_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        iconView_Sprig.contentMode = .scaleAspectFit
        bgView_Sprig.addSubview(iconView_Sprig)
        iconView_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        nameLabel_Sprig.font = .systemFont(ofSize: 13, weight: .semibold)
        bgView_Sprig.addSubview(nameLabel_Sprig)
        nameLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(iconView_Sprig.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func configure_Sprig(tag_sprig: FlowerTagModel_Sprig, isSelected_sprig: Bool) {
        nameLabel_Sprig.text = tag_sprig.tagName_Sprig
        iconView_Sprig.image = UIImage(systemName: tag_sprig.tagIcon_Sprig)
        if isSelected_sprig {
            bgView_Sprig.backgroundColor = UIColor(hexstring_Sprig: tag_sprig.tagHexColor_Sprig)
            nameLabel_Sprig.textColor = .white
            iconView_Sprig.tintColor  = .white
            // 选中时轻微阴影
            bgView_Sprig.layer.shadowColor = UIColor(hexstring_Sprig: tag_sprig.tagHexColor_Sprig).cgColor
            bgView_Sprig.layer.shadowOpacity = 0.3
            bgView_Sprig.layer.shadowRadius  = 6
            bgView_Sprig.layer.shadowOffset  = CGSize(width: 0, height: 3)
        } else {
            bgView_Sprig.backgroundColor = ColorConfig_Sprig.tagBackground_Sprig
            nameLabel_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
            iconView_Sprig.tintColor  = UIColor(hexstring_Sprig: tag_sprig.tagHexColor_Sprig)
            bgView_Sprig.layer.shadowOpacity = 0
        }
    }

    func animateTap_Sprig() {
        animatePressDown_Sprig { self.animatePressUp_Sprig() }
    }
}

// MARK: - 花卉详情底部 Sheet（window 层）

/// 花卉详情底部 Sheet
private class FlowerDetailSheet_Sprig: UIView {

    var onDismiss_Sprig: (() -> Void)?

    private let handleBar_Sprig: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.systemGray4; v.layer.cornerRadius = 2.5; return v
    }()
    private let gradientLayer_Sprig = CAGradientLayer()
    private let emojiLabel_Sprig: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 52); l.textAlignment = .center; return l
    }()
    private let nameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white; l.textAlignment = .center; return l
    }()
    private let cnNameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.8); l.textAlignment = .center; return l
    }()
    private let infoStack_Sprig: UIStackView = {
        let sv = UIStackView(); sv.axis = .horizontal; sv.distribution = .fillEqually; sv.spacing = 8
        return sv
    }()
    private let tipTitleLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = ColorConfig_Sprig.textPrimary_Sprig; l.text = "Care Tips"; return l
    }()
    private let tipContentLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Sprig.textSecondary_Sprig; l.numberOfLines = 0; return l
    }()
    private let monthsStack_Sprig: UIStackView = {
        let sv = UIStackView(); sv.axis = .horizontal; sv.distribution = .fillEqually; sv.spacing = 3
        return sv
    }()
    private let closeButton_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9); return btn
    }()

    override init(frame: CGRect) { super.init(frame: frame); setupUI_Sprig() }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI_Sprig() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Sprig.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 150)
    }

    private func setupUI_Sprig() {
        backgroundColor = .white
        layer.cornerRadius = 24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -4)
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.15

        let topBg_sprig = UIView()
        topBg_sprig.clipsToBounds = true
        gradientLayer_Sprig.colors = [ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
                                      ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint   = CGPoint(x: 1, y: 1)
        topBg_sprig.layer.insertSublayer(gradientLayer_Sprig, at: 0)
        addSubview(topBg_sprig)
        topBg_sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview(); make.height.equalTo(150)
        }

        addSubview(handleBar_Sprig)
        handleBar_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8); make.centerX.equalToSuperview()
            make.width.equalTo(36); make.height.equalTo(5)
        }
        addSubview(closeButton_Sprig)
        closeButton_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14); make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(28)
        }
        closeButton_Sprig.addTarget(self, action: #selector(handleClose_Sprig), for: .touchUpInside)

        topBg_sprig.addSubview(emojiLabel_Sprig)
        emojiLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview(); make.top.equalToSuperview().offset(22)
        }
        topBg_sprig.addSubview(nameLabel_Sprig)
        nameLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview(); make.top.equalTo(emojiLabel_Sprig.snp.bottom).offset(5)
        }
        topBg_sprig.addSubview(cnNameLabel_Sprig)
        cnNameLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview(); make.top.equalTo(nameLabel_Sprig.snp.bottom).offset(2)
        }

        addSubview(monthsStack_Sprig)
        monthsStack_Sprig.snp.makeConstraints { make in
            make.top.equalTo(topBg_sprig.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16); make.height.equalTo(28)
        }
        addSubview(infoStack_Sprig)
        infoStack_Sprig.snp.makeConstraints { make in
            make.top.equalTo(monthsStack_Sprig.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16); make.height.equalTo(60)
        }
        addSubview(tipTitleLabel_Sprig)
        tipTitleLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(infoStack_Sprig.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
        }
        addSubview(tipContentLabel_Sprig)
        tipContentLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(tipTitleLabel_Sprig.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        let pan_sprig = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Sprig(_:)))
        addGestureRecognizer(pan_sprig)
    }

    func configure_Sprig(flower_sprig: FlowerModel_Sprig, bloomDesc_sprig: String) {
        emojiLabel_Sprig.text    = flower_sprig.flowerEmoji_Sprig
        nameLabel_Sprig.text     = flower_sprig.flowerName_Sprig
        cnNameLabel_Sprig.text   = flower_sprig.flowerCnName_Sprig
        tipContentLabel_Sprig.text = flower_sprig.tipText_Sprig

        let base_sprig = UIColor(hexstring_Sprig: flower_sprig.flowerHexColor_Sprig)
        gradientLayer_Sprig.colors = [base_sprig.withAlphaComponent(0.7).cgColor, base_sprig.cgColor]

        monthsStack_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let months_sprig = ["J","F","M","A","M","J","J","A","S","O","N","D"]
        for i_sprig in 1...12 {
            let mv_sprig = UIView()
            let bloom_sprig = flower_sprig.bloomMonths_Sprig.contains(i_sprig)
            mv_sprig.backgroundColor = bloom_sprig ? base_sprig : ColorConfig_Sprig.tagBackground_Sprig
            mv_sprig.layer.cornerRadius = 6
            let ml_sprig = UILabel()
            ml_sprig.text = months_sprig[i_sprig - 1]
            ml_sprig.font = .systemFont(ofSize: 9, weight: bloom_sprig ? .bold : .regular)
            ml_sprig.textColor = bloom_sprig ? .white : ColorConfig_Sprig.textPlaceholder_Sprig
            ml_sprig.textAlignment = .center
            mv_sprig.addSubview(ml_sprig)
            ml_sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }
            monthsStack_Sprig.addArrangedSubview(mv_sprig)
        }

        infoStack_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let infos_sprig: [(String, String, String)] = [
            ("drop.fill",  "Every \(flower_sprig.waterDays_Sprig)d", "Watering"),
            ("star.fill",  String(repeating: "★", count: flower_sprig.careLevel_Sprig)
             + String(repeating: "☆", count: 3 - flower_sprig.careLevel_Sprig), "Difficulty"),
            ("house.fill", flower_sprig.placement_Sprig, "Placement"),
        ]
        for info_sprig in infos_sprig {
            infoStack_Sprig.addArrangedSubview(
                makeInfoCard_Sprig(icon_sprig: info_sprig.0, value_sprig: info_sprig.1,
                                   label_sprig: info_sprig.2, color_sprig: base_sprig)
            )
        }
    }

    private func makeInfoCard_Sprig(icon_sprig: String, value_sprig: String,
                                    label_sprig: String, color_sprig: UIColor) -> UIView {
        let card_sprig = UIView()
        card_sprig.backgroundColor = color_sprig.withAlphaComponent(0.1)
        card_sprig.layer.cornerRadius = 12
        let iv_sprig = UIImageView(image: UIImage(systemName: icon_sprig))
        iv_sprig.tintColor = color_sprig; iv_sprig.contentMode = .scaleAspectFit
        let vL_sprig = UILabel()
        vL_sprig.text = value_sprig; vL_sprig.font = .systemFont(ofSize: 13, weight: .bold)
        vL_sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig; vL_sprig.textAlignment = .center
        let lL_sprig = UILabel()
        lL_sprig.text = label_sprig; lL_sprig.font = .systemFont(ofSize: 10)
        lL_sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig; lL_sprig.textAlignment = .center
        let stack_sprig = UIStackView(arrangedSubviews: [iv_sprig, vL_sprig, lL_sprig])
        stack_sprig.axis = .vertical; stack_sprig.spacing = 2; stack_sprig.alignment = .center
        card_sprig.addSubview(stack_sprig)
        iv_sprig.snp.makeConstraints { make in make.width.height.equalTo(16) }
        stack_sprig.snp.makeConstraints { make in
            make.center.equalToSuperview(); make.left.right.equalToSuperview().inset(4)
        }
        return card_sprig
    }

    @objc private func handleClose_Sprig() { onDismiss_Sprig?() }

    @objc private func handlePan_Sprig(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended && gesture.translation(in: self).y > 60 { onDismiss_Sprig?() }
    }
}
