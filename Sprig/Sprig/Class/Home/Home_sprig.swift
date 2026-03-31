import UIKit
import SnapKit
import FSPagerView

// MARK: 首页

/// 首页视图控制器
/// 功能：顶部渐变 Header（问候 + 花期统计）/ 独立轮播区 / 每日贴士 / 养花轨迹 / 时光胶囊
/// 布局：TableView.contentInsetAdjustmentBehavior = .never，Header 从 y=0 开始，无顶部间隙
/// 动画：卡片弹性入场、FSPagerView linear 轮播、时间线入场
class Home_Sprig: UIViewController {

    // MARK: - 数据属性

    /// 推荐帖子（轮播展示）
    private var recommendedPosts_Sprig: [TitleModel_Sprig] = []
    private var journeyRecords_Sprig: [FlowerStatusRecord_Sprig] = []
    private var capsules_Sprig: [FlowerCapsule_Sprig] = []
    private var isAnimatingEntrance_Sprig = true

    // MARK: - 安全区高度（动态读取）

    private var safeTop_Sprig: CGFloat {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 44
    }
    private var safeBottom_Sprig: CGFloat {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.bottom ?? 34
    }

    // MARK: - UI 组件

    private lazy var tableView_Sprig: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        // .never → header从y=0开始，彻底消除顶部灰色间隙
        tv.contentInsetAdjustmentBehavior = .never
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        return tv
    }()

    private lazy var refreshControl_Sprig: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = ColorConfig_Sprig.leafGreen_Sprig
        rc.attributedTitle = NSAttributedString(
            string: "Refreshing blooms...",
            attributes: [.foregroundColor: ColorConfig_Sprig.textPlaceholder_Sprig,
                         .font: UIFont.systemFont(ofSize: 13)]
        )
        return rc
    }()

    // MARK: - Header 引用（通过属性访问确保唯一）

    private let headerGradientLayer_Sprig = CAGradientLayer()
    private lazy var headerView_Sprig: UIView = buildHeaderView_Sprig()

    private let greetingLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()
    private let bloomSummaryLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.88)
        return l
    }()

    // MARK: - FSPagerView

    private lazy var pagerView_Sprig: FSPagerView = {
        let pv = FSPagerView(frame: .zero)
        pv.register(HomePostBannerCell_Sprig.self,
                    forCellWithReuseIdentifier: HomePostBannerCell_Sprig.reuseId_Sprig)
        // 高度需覆盖 BloomBannerCell 全部内容：emoji(72)+name(24)+bloom(16)+water(15)+badge(20)+间距≈201pt，给出 210pt
        pv.itemSize = CGSize(width: APPSCREEN_Sprig.WIDTH_Sprig - 64, height: 210)
        pv.interitemSpacing = 12
        pv.isInfinite = true
        pv.automaticSlidingInterval = 4.5
        pv.decelerationDistance = FSPagerView.automaticDistance
        pv.transformer = FSPagerViewTransformer(type: .linear)
        pv.backgroundColor = .clear
        return pv
    }()

    // MARK: - 胶囊 CollectionView

    private lazy var capsuleCollectionView_Sprig: UICollectionView = {
        let layout_sprig = UICollectionViewFlowLayout()
        layout_sprig.scrollDirection = .horizontal
        layout_sprig.itemSize = CGSize(width: 160, height: 130)
        layout_sprig.minimumInteritemSpacing = 12
        layout_sprig.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout_sprig)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(CapsuleCell_Sprig.self, forCellWithReuseIdentifier: CapsuleCell_Sprig.reuseId_Sprig)
        return cv
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
        loadData_Sprig()
        registerNotifications_Sprig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView_Sprig.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Sprig.frame = headerView_Sprig.bounds
    }

    // MARK: - TableView 搭建

    private func setupTableView_Sprig() {
        view.addSubview(tableView_Sprig)
        tableView_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        tableView_Sprig.delegate   = self
        tableView_Sprig.dataSource = self
        tableView_Sprig.register(UITableViewCell.self, forCellReuseIdentifier: "BaseCell_Sprig")

        capsuleCollectionView_Sprig.delegate   = self
        capsuleCollectionView_Sprig.dataSource = self

        refreshControl_Sprig.addTarget(self, action: #selector(handleRefresh_Sprig), for: .valueChanged)
        tableView_Sprig.refreshControl = refreshControl_Sprig
        tableView_Sprig.tableHeaderView = headerView_Sprig
    }

    // MARK: - 紧凑 Header（仅问候 + 花期统计，不含轮播）

    /// 顶部渐变 Header
    /// 高度 = safeArea.top + 88，内容紧贴状态栏下方，无多余间距
    private func buildHeaderView_Sprig() -> UIView {
        let safeTop_sprig = safeTop_Sprig
        let h_sprig: CGFloat = safeTop_sprig + 88
        let container_sprig = UIView(frame: CGRect(x: 0, y: 0,
                                                   width: APPSCREEN_Sprig.WIDTH_Sprig,
                                                   height: h_sprig))
        container_sprig.backgroundColor = .clear

        // 渐变背景
        headerGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        headerGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Sprig.endPoint   = CGPoint(x: 1, y: 1)
        container_sprig.layer.insertSublayer(headerGradientLayer_Sprig, at: 0)

        // 装饰圆 - 右上
        let decorTR_sprig = UIView()
        decorTR_sprig.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        decorTR_sprig.layer.cornerRadius = 55
        container_sprig.addSubview(decorTR_sprig)
        decorTR_sprig.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(28)
        }

        // 装饰圆 - 左下（小）
        let decorBL_sprig = UIView()
        decorBL_sprig.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        decorBL_sprig.layer.cornerRadius = 30
        container_sprig.addSubview(decorBL_sprig)
        decorBL_sprig.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.bottom.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(60)
        }

        // 装饰小花点（随机位置 emoji）
        let petals_sprig = ["🌸", "🌼", "🌺"]
        let petalPositions_sprig: [(CGFloat, CGFloat)] = [(260, safeTop_sprig + 30), (310, safeTop_sprig + 60), (230, safeTop_sprig + 65)]
        for (i_sprig, emoji_sprig) in petals_sprig.enumerated() {
            let el_sprig = UILabel()
            el_sprig.text = emoji_sprig
            el_sprig.font = .systemFont(ofSize: 16)
            el_sprig.alpha = 0.35
            container_sprig.addSubview(el_sprig)
            el_sprig.frame = CGRect(x: petalPositions_sprig[i_sprig].0,
                                    y: petalPositions_sprig[i_sprig].1,
                                    width: 24, height: 24)
        }

        // 消息按钮（圆形背景，点击切换到 Tab 3 消息列表）
        let msgBg_sprig = UIView()
        msgBg_sprig.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        msgBg_sprig.layer.cornerRadius = 18
        container_sprig.addSubview(msgBg_sprig)
        msgBg_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_sprig + 8)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        let msgBtn_sprig = UIButton(type: .system)
        let cfg_sprig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        msgBtn_sprig.setImage(UIImage(systemName: "bell.badge", withConfiguration: cfg_sprig), for: .normal)
        msgBtn_sprig.tintColor = .white
        msgBg_sprig.addSubview(msgBtn_sprig)
        msgBtn_sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }
        msgBtn_sprig.addTarget(self, action: #selector(handleMsgTap_Sprig), for: .touchUpInside)

        // 叶片图标（紧贴状态栏下方 8pt）
        let leafIV_sprig = UIImageView(image: UIImage(systemName: "leaf.fill"))
        leafIV_sprig.tintColor = UIColor.white.withAlphaComponent(0.9)
        leafIV_sprig.contentMode = .scaleAspectFit
        container_sprig.addSubview(leafIV_sprig)
        leafIV_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_sprig + 8)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(18)
        }

        // 问候语
        greetingLabel_Sprig.text = HomeViewModel_Sprig.shared_Sprig.getGreeting_Sprig()
        container_sprig.addSubview(greetingLabel_Sprig)
        greetingLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(leafIV_sprig.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-64)
        }

        // 花期统计（带花苞 emoji）
        let summaryRow_sprig = UIView()
        container_sprig.addSubview(summaryRow_sprig)
        summaryRow_sprig.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel_Sprig.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        bloomSummaryLabel_Sprig.text = HomeViewModel_Sprig.shared_Sprig.getMonthBloomSummary_Sprig()
        summaryRow_sprig.addSubview(bloomSummaryLabel_Sprig)
        bloomSummaryLabel_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        return container_sprig
    }

    // MARK: - 数据加载

    private func loadData_Sprig() {
        recommendedPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
        journeyRecords_Sprig   = HomeViewModel_Sprig.shared_Sprig.getJourneyRecords_Sprig()
        capsules_Sprig         = HomeViewModel_Sprig.shared_Sprig.getCapsules_Sprig()
        pagerView_Sprig.reloadData()
        tableView_Sprig.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.playEntranceAnimations_Sprig()
        }
    }

    // MARK: - 通知

    private func registerNotifications_Sprig() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onHomeStateChanged_Sprig),
            name: HomeViewModel_Sprig.homeStateDidChangeNotification_Sprig,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleStateChanged_Sprig),
            name: TitleViewModel_Sprig.titleStateDidChangeNotification_Sprig,
            object: nil
        )
    }

    /// 帖子状态变化时刷新推荐帖子轮播
    @objc private func onTitleStateChanged_Sprig() {
        recommendedPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
        pagerView_Sprig.reloadData()
    }

    @objc private func onHomeStateChanged_Sprig() {
        journeyRecords_Sprig = HomeViewModel_Sprig.shared_Sprig.getJourneyRecords_Sprig()
        capsules_Sprig       = HomeViewModel_Sprig.shared_Sprig.getCapsules_Sprig()
        tableView_Sprig.reloadSections(IndexSet([2, 3]), with: .automatic)
        capsuleCollectionView_Sprig.reloadData()
    }

    // MARK: - 入场动画

    private func playEntranceAnimations_Sprig() {
        let cells_sprig = tableView_Sprig.visibleCells
        for (i_sprig, cell_sprig) in cells_sprig.enumerated() {
            cell_sprig.alpha = 0
            cell_sprig.animateSlideInFromBottom_Sprig(
                offset_Sprig: 36,
                delay_Sprig: Double(i_sprig) * AnimationConfig_Sprig.delayLong_Sprig
            )
        }
        let delay_sprig = Double(cells_sprig.count) * AnimationConfig_Sprig.delayLong_Sprig
            + AnimationConfig_Sprig.durationSpring_Sprig
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_sprig) {
            self.isAnimatingEntrance_Sprig = false
        }
    }

    // MARK: - 刷新

    @objc private func handleRefresh_Sprig() {
        Task { @MainActor in
            await withCheckedContinuation { cont_sprig in
                HomeViewModel_Sprig.shared_Sprig.refresh_Sprig { cont_sprig.resume() }
            }
            recommendedPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
            journeyRecords_Sprig   = HomeViewModel_Sprig.shared_Sprig.getJourneyRecords_Sprig()
            capsules_Sprig         = HomeViewModel_Sprig.shared_Sprig.getCapsules_Sprig()
            pagerView_Sprig.reloadData()
            tableView_Sprig.reloadData()
            capsuleCollectionView_Sprig.reloadData()
            refreshControl_Sprig.endRefreshing()
        }
    }

    // MARK: - 按钮响应

    /// 点击消息铃铛 → 切换到消息 Tab（index 3），不 push
    @objc private func handleMsgTap_Sprig() {
        if let tabBar_sprig = tabBarController as? TabBar_Sprig {
            tabBar_sprig.selectPage_Sprig(index: 3)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension Home_Sprig: UITableViewDataSource, UITableViewDelegate {

    /// Section：0=轮播区, 1=每日贴士, 2=养花轨迹, 3=时光胶囊
    func numberOfSections(in tableView: UITableView) -> Int { return 4 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return max(1, journeyRecords_Sprig.count)
        case 3: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return buildPagerCell_Sprig(tableView: tableView)
        case 1: return buildTipCell_Sprig(tableView: tableView)
        case 2: return buildJourneyCell_Sprig(tableView: tableView, indexPath: indexPath)
        case 3: return buildCapsuleRowCell_Sprig(tableView: tableView)
        default: return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 242  // card 上下各留 10/4pt → 可用 228pt，item 210pt 完整显示
        case 1: return 118
        case 2:
            return journeyRecords_Sprig.isEmpty ? 100 : UITableView.automaticDimension
        case 3: return 158
        default: return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return buildInlineHeader_Sprig(
                title_sprig: "Trending Posts ✨",
                subtitleColor_sprig: ColorConfig_Sprig.primaryGradientStart_Sprig,
                action_sprig: nil, actionLabel_sprig: nil
            )
        case 2:
            return buildInlineHeader_Sprig(
                title_sprig: "My Bloom Journey 🌱",
                subtitleColor_sprig: ColorConfig_Sprig.leafGreen_Sprig,
                action_sprig: #selector(handleAddJourney_Sprig), actionLabel_sprig: nil
            )
        case 3:
            return buildInlineHeader_Sprig(
                title_sprig: "Time Capsules 🔮",
                subtitleColor_sprig: UIColor(hexstring_Sprig: "#9F7AEA"),
                action_sprig: #selector(handleAddCapsule_Sprig), actionLabel_sprig: nil
            )
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 2, 3: return 44
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isAnimatingEntrance_Sprig && indexPath.section == 2 && !journeyRecords_Sprig.isEmpty {
            cell.alpha = 0
            cell.animateSlideInFromBottom_Sprig(offset_Sprig: 20,
                                                delay_Sprig: Double(indexPath.row % 6) * 0.05)
        }
    }

    // MARK: - 轮播 Cell（独立在 Header 下方 10pt 位置）

    /// FSPagerView 轮播区 Cell
    /// 功能：包含渐变浅色背景卡片和 FSPagerView，与上方 Header 有 10pt 间隔
    private func buildPagerCell_Sprig(tableView: UITableView) -> UITableViewCell {
        let cell_sprig = UITableViewCell(style: .default, reuseIdentifier: "PagerCell_Sprig")
        cell_sprig.selectionStyle = .none
        cell_sprig.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig

        // 轮播容器卡片（带柔和投影）
        let card_sprig = UIView()
        card_sprig.backgroundColor = .clear
        cell_sprig.contentView.addSubview(card_sprig)
        card_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)  // 距 Header 10pt
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
        }

        pagerView_Sprig.dataSource = self
        pagerView_Sprig.delegate   = self
        card_sprig.addSubview(pagerView_Sprig)
        pagerView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return cell_sprig
    }

    // MARK: - 每日贴士 Cell

    private func buildTipCell_Sprig(tableView: UITableView) -> UITableViewCell {
        let cell_sprig = UITableViewCell(style: .default, reuseIdentifier: "TipCell_Sprig")
        cell_sprig.selectionStyle = .none
        cell_sprig.backgroundColor = .clear

        let tip_sprig = HomeViewModel_Sprig.shared_Sprig.getDailyTip_Sprig()

        let card_sprig = UIView()
        card_sprig.backgroundColor = .white
        card_sprig.layer.cornerRadius = 18
        card_sprig.layer.shadowColor = UIColor(hexstring_Sprig: "#8B5CF6").cgColor
        card_sprig.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_sprig.layer.shadowRadius = 12
        card_sprig.layer.shadowOpacity = 0.08
        cell_sprig.contentView.addSubview(card_sprig)
        card_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-4)
        }

        // 渐变圆形图标
        let iconBg_sprig = UIView()
        iconBg_sprig.layer.cornerRadius = 24
        iconBg_sprig.clipsToBounds = true
        let g_sprig = UIColor.createPrimaryGradientLayer_Sprig(
            frame_Sprig: CGRect(x: 0, y: 0, width: 48, height: 48)
        )
        iconBg_sprig.layer.insertSublayer(g_sprig, at: 0)
        let iconIV_sprig = UIImageView(image: UIImage(systemName: tip_sprig.icon))
        iconIV_sprig.tintColor = .white
        iconIV_sprig.contentMode = .scaleAspectFit
        iconBg_sprig.addSubview(iconIV_sprig)
        card_sprig.addSubview(iconBg_sprig)
        iconBg_sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        iconIV_sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        // "Daily Tip" 胶囊标签
        let tag_sprig = buildPillLabel_Sprig(
            text_sprig: "✦ Daily Tip",
            bgColor_sprig: ColorConfig_Sprig.softGreen_Sprig,
            textColor_sprig: ColorConfig_Sprig.leafGreen_Sprig
        )
        card_sprig.addSubview(tag_sprig)
        tag_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(iconBg_sprig.snp.right).offset(12)
            make.height.equalTo(20)
        }

        let titleL_sprig = UILabel()
        titleL_sprig.text = tip_sprig.title
        titleL_sprig.font = .systemFont(ofSize: 15, weight: .bold)
        titleL_sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        card_sprig.addSubview(titleL_sprig)
        titleL_sprig.snp.makeConstraints { make in
            make.top.equalTo(tag_sprig.snp.bottom).offset(4)
            make.left.equalTo(iconBg_sprig.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
        }

        let contentL_sprig = UILabel()
        contentL_sprig.text = tip_sprig.text
        contentL_sprig.font = .systemFont(ofSize: 12)
        contentL_sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        contentL_sprig.numberOfLines = 2
        card_sprig.addSubview(contentL_sprig)
        contentL_sprig.snp.makeConstraints { make in
            make.top.equalTo(titleL_sprig.snp.bottom).offset(3)
            make.left.equalTo(iconBg_sprig.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
        return cell_sprig
    }

    // MARK: - 养花轨迹 Cell（时间线）

    private func buildJourneyCell_Sprig(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell_sprig = UITableViewCell(style: .default, reuseIdentifier: "JourneyCell_Sprig")
        cell_sprig.selectionStyle = .none
        cell_sprig.backgroundColor = .clear

        if journeyRecords_Sprig.isEmpty {
            let emptyL_sprig = UILabel()
            emptyL_sprig.text = "Tap ＋ to record your first bloom moment 🌷"
            emptyL_sprig.font = .systemFont(ofSize: 13)
            emptyL_sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
            emptyL_sprig.textAlignment = .center
            emptyL_sprig.numberOfLines = 2
            cell_sprig.contentView.addSubview(emptyL_sprig)
            emptyL_sprig.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24))
            }
            return cell_sprig
        }

        let record_sprig = journeyRecords_Sprig[indexPath.row]
        let milestone_sprig = record_sprig.milestone_Sprig
        let milestoneColor_sprig = UIColor(hexstring_Sprig: milestone_sprig.hexColor_Sprig)
        let isLast_sprig = indexPath.row == journeyRecords_Sprig.count - 1

        // 时间线竖线
        if !isLast_sprig {
            let line_sprig = UIView()
            line_sprig.backgroundColor = milestoneColor_sprig.withAlphaComponent(0.2)
            cell_sprig.contentView.addSubview(line_sprig)
            line_sprig.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(34)
                make.top.equalToSuperview().offset(52)
                make.width.equalTo(2)
                make.bottom.equalToSuperview()
            }
        }

        // 节点圆圈
        let dot_sprig = UIView()
        dot_sprig.backgroundColor = milestoneColor_sprig
        dot_sprig.layer.cornerRadius = 11
        dot_sprig.layer.borderWidth = 3
        dot_sprig.layer.borderColor = UIColor.white.cgColor
        dot_sprig.layer.shadowColor = milestoneColor_sprig.cgColor
        dot_sprig.layer.shadowOffset = .zero
        dot_sprig.layer.shadowRadius = 5
        dot_sprig.layer.shadowOpacity = 0.45
        cell_sprig.contentView.addSubview(dot_sprig)
        dot_sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(22)
        }

        let dotIcon_sprig = UIImageView(image: UIImage(systemName: milestone_sprig.icon_Sprig))
        dotIcon_sprig.tintColor = .white
        dotIcon_sprig.contentMode = .scaleAspectFit
        dot_sprig.addSubview(dotIcon_sprig)
        dotIcon_sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }

        // 卡片
        let card_sprig = UIView()
        card_sprig.backgroundColor = .white
        card_sprig.layer.cornerRadius = 14
        card_sprig.layer.shadowColor = milestoneColor_sprig.cgColor
        card_sprig.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_sprig.layer.shadowRadius = 8
        card_sprig.layer.shadowOpacity = 0.1
        cell_sprig.contentView.addSubview(card_sprig)
        card_sprig.snp.makeConstraints { make in
            make.left.equalTo(dot_sprig.snp.right).offset(12)
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }

        // 左侧颜色条
        let bar_sprig = UIView()
        bar_sprig.backgroundColor = milestoneColor_sprig
        bar_sprig.layer.cornerRadius = 3
        card_sprig.addSubview(bar_sprig)
        bar_sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(4)
        }

        // 节点徽章（仅显示英文名称）
        let badge_sprig = buildPillLabel_Sprig(
            text_sprig: milestone_sprig.subtitle_Sprig,
            bgColor_sprig: milestoneColor_sprig.withAlphaComponent(0.12),
            textColor_sprig: milestoneColor_sprig
        )
        card_sprig.addSubview(badge_sprig)
        badge_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(bar_sprig.snp.right).offset(10)
            make.height.equalTo(20)
        }

        // 日期标签
        let dateL_sprig = UILabel()
        let fmt_sprig = DateFormatter()
        fmt_sprig.dateFormat = "MMM d, HH:mm"
        dateL_sprig.text = fmt_sprig.string(from: record_sprig.createdAt_Sprig)
        dateL_sprig.font = .systemFont(ofSize: 10)
        dateL_sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        card_sprig.addSubview(dateL_sprig)
        dateL_sprig.snp.makeConstraints { make in
            make.centerY.equalTo(badge_sprig)
            make.right.equalToSuperview().offset(-40)
        }

        // 删除按钮（右上角）
        let deleteBtn_sprig = UIButton(type: .system)
        let delCfg_sprig = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        deleteBtn_sprig.setImage(UIImage(systemName: "xmark", withConfiguration: delCfg_sprig), for: .normal)
        deleteBtn_sprig.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        card_sprig.addSubview(deleteBtn_sprig)
        deleteBtn_sprig.snp.makeConstraints { make in
            make.centerY.equalTo(badge_sprig)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        let recordId_sprig = record_sprig.recordId_Sprig
        deleteBtn_sprig.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let alert_sprig = UIAlertController(
                title: "Delete Record",
                message: "Are you sure you want to delete this bloom record?",
                preferredStyle: .alert
            )
            alert_sprig.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                HomeViewModel_Sprig.shared_Sprig.deleteJourneyRecord_Sprig(recordId_sprig: recordId_sprig)
            })
            alert_sprig.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert_sprig, animated: true)
        }, for: .touchUpInside)

        // 备注文字
        let notesL_sprig = UILabel()
        notesL_sprig.text = record_sprig.notes_Sprig.isEmpty ? "No notes added." : record_sprig.notes_Sprig
        notesL_sprig.font = .systemFont(ofSize: 13)
        notesL_sprig.textColor = record_sprig.notes_Sprig.isEmpty
            ? ColorConfig_Sprig.textPlaceholder_Sprig
            : ColorConfig_Sprig.textPrimary_Sprig
        notesL_sprig.numberOfLines = 3
        card_sprig.addSubview(notesL_sprig)
        notesL_sprig.snp.makeConstraints { make in
            make.top.equalTo(badge_sprig.snp.bottom).offset(6)
            make.left.equalTo(bar_sprig.snp.right).offset(10)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        return cell_sprig
    }

    // MARK: - 时光胶囊容器 Cell

    private func buildCapsuleRowCell_Sprig(tableView: UITableView) -> UITableViewCell {
        let cell_sprig = UITableViewCell(style: .default, reuseIdentifier: "CapsuleRowCell_Sprig")
        cell_sprig.selectionStyle = .none
        cell_sprig.backgroundColor = .clear
        cell_sprig.contentView.addSubview(capsuleCollectionView_Sprig)
        capsuleCollectionView_Sprig.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(130)
            make.bottom.equalToSuperview().offset(-8)
        }
        return cell_sprig
    }

    // MARK: - Section Header（内联，带加号按钮）

    private func buildInlineHeader_Sprig(title_sprig: String,
                                         subtitleColor_sprig: UIColor,
                                         action_sprig: Selector?,
                                         actionLabel_sprig: String?) -> UIView {
        let v_sprig = UIView()
        v_sprig.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig

        // 左侧竖色条
        let accent_sprig = UIView()
        accent_sprig.backgroundColor = subtitleColor_sprig
        accent_sprig.layer.cornerRadius = 2
        v_sprig.addSubview(accent_sprig)
        accent_sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(18)
        }

        let titleL_sprig = UILabel()
        titleL_sprig.text = title_sprig
        titleL_sprig.font = .systemFont(ofSize: 16, weight: .bold)
        titleL_sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        v_sprig.addSubview(titleL_sprig)
        titleL_sprig.snp.makeConstraints { make in
            make.left.equalTo(accent_sprig.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        if let action_sprig = action_sprig {
            let addBtn_sprig = UIButton(type: .system)
            let cfg_sprig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            addBtn_sprig.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: cfg_sprig), for: .normal)
            addBtn_sprig.tintColor = subtitleColor_sprig
            addBtn_sprig.addTarget(self, action: action_sprig, for: .touchUpInside)
            v_sprig.addSubview(addBtn_sprig)
            addBtn_sprig.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(32)
            }
        } else if let label_sprig = actionLabel_sprig {
            let seeAll_sprig = UILabel()
            seeAll_sprig.text = label_sprig
            seeAll_sprig.font = .systemFont(ofSize: 12, weight: .medium)
            seeAll_sprig.textColor = subtitleColor_sprig
            v_sprig.addSubview(seeAll_sprig)
            seeAll_sprig.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
        }
        return v_sprig
    }

    // MARK: - 胶囊徽章构建工具

    private func buildPillLabel_Sprig(text_sprig: String, bgColor_sprig: UIColor, textColor_sprig: UIColor) -> UILabel {
        let l_sprig = UILabel()
        l_sprig.text = text_sprig
        l_sprig.font = .systemFont(ofSize: 10, weight: .semibold)
        l_sprig.textColor = textColor_sprig
        l_sprig.backgroundColor = bgColor_sprig
        l_sprig.layer.cornerRadius = 8
        l_sprig.clipsToBounds = true
        l_sprig.textAlignment = .center
        l_sprig.setContentHuggingPriority(.required, for: .horizontal)
        l_sprig.layoutMargins = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        // 通过约束控制内边距
        let wrapper_sprig = UILabel()
        // 直接用 padding 字符
        l_sprig.text = "  \(text_sprig)  "
        return l_sprig
    }
}

// MARK: - FSPagerView DataSource & Delegate

extension Home_Sprig: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return max(1, recommendedPosts_Sprig.count)
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell_sprig = pagerView.dequeueReusableCell(
            withReuseIdentifier: HomePostBannerCell_Sprig.reuseId_Sprig,
            at: index
        ) as! HomePostBannerCell_Sprig
        guard !recommendedPosts_Sprig.isEmpty else { return cell_sprig }
        let post_sprig = recommendedPosts_Sprig[index]
        cell_sprig.viewController_Sprig = self
        cell_sprig.configure_Sprig(post_sprig: post_sprig)
        // 点击头像 → 进入用户中心（非登录用户）
        cell_sprig.onAvatarTap_Sprig = { [weak self] in
            guard self != nil else { return }
            let author_sprig = UserViewModel_Sprig.shared_Sprig
                .getUserById_Sprig(userId_sprig: post_sprig.titleUserId_Sprig)
            Navigation_Sprig.toUserInfo_Sprig(with: author_sprig)
        }
        // 右上角举报/删除
        cell_sprig.onActionTap_Sprig = { [weak self] vc in
            guard let self, let vc else { return }
            let isOwner_sprig = post_sprig.titleUserId_Sprig ==
                UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig().userId_Sprig
            if isOwner_sprig {
                ReportDeleteHelper_Sprig.delete_Sprig(post_Sprig: post_sprig, from: vc) { [weak self] in
                    self?.recommendedPosts_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getHotPosts_Sprig()
                    self?.pagerView_Sprig.reloadData()
                }
            } else {
                ReportDeleteHelper_Sprig.report_Sprig(post_Sprig: post_sprig, from: vc)
            }
        }
        return cell_sprig
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        guard !recommendedPosts_Sprig.isEmpty else { return }
        Navigation_Sprig.toTitleDetail_Sprig(titleModel_sprig: recommendedPosts_Sprig[index])
    }
}

// MARK: - CollectionView（时光胶囊）

extension Home_Sprig: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(1, capsules_Sprig.count)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_sprig = collectionView.dequeueReusableCell(
            withReuseIdentifier: CapsuleCell_Sprig.reuseId_Sprig,
            for: indexPath
        ) as! CapsuleCell_Sprig
        if capsules_Sprig.isEmpty {
            cell_sprig.configureEmpty_Sprig()
            cell_sprig.onDelete_Sprig = nil
        } else {
            let capsule_sprig = capsules_Sprig[indexPath.item]
            cell_sprig.configure_Sprig(capsule_sprig: capsule_sprig)
            let capsuleId_sprig = capsule_sprig.capsuleId_Sprig
            cell_sprig.onDelete_Sprig = { [weak self] in
                guard let self else { return }
                let alert_sprig = UIAlertController(
                    title: "Delete Capsule",
                    message: "Are you sure you want to delete this time capsule?",
                    preferredStyle: .alert
                )
                alert_sprig.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    HomeViewModel_Sprig.shared_Sprig.deleteCapsule_Sprig(capsuleId_sprig: capsuleId_sprig)
                })
                alert_sprig.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert_sprig, animated: true)
            }
        }
        return cell_sprig
    }
}

// MARK: - 新增操作

extension Home_Sprig {

    @objc private func handleAddJourney_Sprig() {
        guard UserViewModel_Sprig.shared_Sprig.isLoggedIn_Sprig else {
            showLoginAlert_Sprig(); return
        }
        showMilestoneSelector_Sprig()
    }

    @objc private func handleAddCapsule_Sprig() {
        guard UserViewModel_Sprig.shared_Sprig.isLoggedIn_Sprig else {
            showLoginAlert_Sprig(); return
        }
        showCapsuleCreator_Sprig()
    }

    private func showMilestoneSelector_Sprig() {
        let sheet_sprig = UIAlertController(
            title: "Select Milestone",
            message: "Choose the current bloom stage",
            preferredStyle: .actionSheet
        )
        for m_sprig in FlowerMilestone_Sprig.allCases {
            // 仅展示英文名称
            sheet_sprig.addAction(UIAlertAction(
                title: m_sprig.subtitle_Sprig,
                style: .default
            ) { [weak self] _ in self?.showNotesInput_Sprig(milestone_sprig: m_sprig) })
        }
        sheet_sprig.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet_sprig, animated: true)
    }

    private func showNotesInput_Sprig(milestone_sprig: FlowerMilestone_Sprig) {
        let alert_sprig = UIAlertController(
            title: milestone_sprig.subtitle_Sprig,
            message: "Add your care notes (optional)",
            preferredStyle: .alert
        )
        alert_sprig.addTextField { tf_sprig in
            tf_sprig.placeholder = "e.g. watered today, first bud spotted..."
            tf_sprig.font = .systemFont(ofSize: 14)
        }
        alert_sprig.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let notes_sprig = alert_sprig.textFields?.first?.text ?? ""
            Task { @MainActor in
                HomeViewModel_Sprig.shared_Sprig.addJourneyRecord_Sprig(
                    milestone_sprig: milestone_sprig,
                    notes_sprig: notes_sprig
                )
            }
        })
        alert_sprig.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_sprig, animated: true)
    }

    private func showCapsuleCreator_Sprig() {
        let alert_sprig = UIAlertController(
            title: "Create Time Capsule 🔮",
            message: "Write your care notes, then choose unlock time",
            preferredStyle: .alert
        )
        alert_sprig.addTextField { tf_sprig in
            tf_sprig.placeholder = "e.g. This rose bloomed perfectly today..."
        }
        alert_sprig.addAction(UIAlertAction(title: "Unlock in 1 Year", style: .default) { [weak self] _ in
            self?.saveCapsule_Sprig(notes_sprig: alert_sprig.textFields?.first?.text ?? "", years_sprig: 1)
        })
        alert_sprig.addAction(UIAlertAction(title: "Unlock in 3 Years", style: .default) { [weak self] _ in
            self?.saveCapsule_Sprig(notes_sprig: alert_sprig.textFields?.first?.text ?? "", years_sprig: 3)
        })
        alert_sprig.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_sprig, animated: true)
    }

    private func saveCapsule_Sprig(notes_sprig: String, years_sprig: Int) {
        Task { @MainActor in
            HomeViewModel_Sprig.shared_Sprig.addCapsule_Sprig(notes_sprig: notes_sprig, unlockYears_sprig: years_sprig)
        }
    }

    /// 跳转登录页（养花轨迹/时光胶囊需要登录状态才能操作）
    private func showLoginAlert_Sprig() {
        Navigation_Sprig.toLogin_Sprig(style_sprig: .present_sprig)
    }
}

// MARK: - 时光胶囊 Cell

/// 时光胶囊卡片 Cell
class CapsuleCell_Sprig: UICollectionViewCell {

    static let reuseId_Sprig = "CapsuleCell_Sprig"

    /// 删除回调：点击确认删除后触发
    var onDelete_Sprig: (() -> Void)?

    private let gradLayer_Sprig = CAGradientLayer()
    private let lockIcon_Sprig  = UIImageView()
    private let statusLabel_Sprig   = UILabel()
    private let dateLabel_Sprig     = UILabel()
    private let countdownLabel_Sprig = UILabel()
    private let notesLabel_Sprig    = UILabel()
    /// 删除按钮（右上角）
    private let deleteBtn_Sprig = UIButton(type: .system)

    override init(frame: CGRect) { super.init(frame: frame); setupUI_Sprig() }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI_Sprig() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Sprig.frame = contentView.bounds
    }

    private func setupUI_Sprig() {
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)

        gradLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Sprig.endPoint   = CGPoint(x: 1, y: 1)
        gradLayer_Sprig.cornerRadius = 18
        contentView.layer.insertSublayer(gradLayer_Sprig, at: 0)

        lockIcon_Sprig.contentMode = .scaleAspectFit
        lockIcon_Sprig.tintColor = .white
        contentView.addSubview(lockIcon_Sprig)
        lockIcon_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(22)
        }

        statusLabel_Sprig.font = .systemFont(ofSize: 11, weight: .bold)
        statusLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.9)
        contentView.addSubview(statusLabel_Sprig)
        statusLabel_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(lockIcon_Sprig)
            make.left.equalTo(lockIcon_Sprig.snp.right).offset(6)
        }

        dateLabel_Sprig.font = .systemFont(ofSize: 10)
        dateLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.72)
        contentView.addSubview(dateLabel_Sprig)
        dateLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(lockIcon_Sprig.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(14)
        }

        countdownLabel_Sprig.font = .systemFont(ofSize: 22, weight: .bold)
        countdownLabel_Sprig.textColor = .white
        contentView.addSubview(countdownLabel_Sprig)
        countdownLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(dateLabel_Sprig.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(14)
        }

        notesLabel_Sprig.font = .systemFont(ofSize: 11)
        notesLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.85)
        notesLabel_Sprig.numberOfLines = 2
        contentView.addSubview(notesLabel_Sprig)
        notesLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(countdownLabel_Sprig.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(14)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        // 右上角删除按钮
        let delCfg_sprig = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        deleteBtn_Sprig.setImage(UIImage(systemName: "xmark", withConfiguration: delCfg_sprig), for: .normal)
        deleteBtn_Sprig.tintColor = UIColor.white.withAlphaComponent(0.75)
        contentView.addSubview(deleteBtn_Sprig)
        deleteBtn_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }
        deleteBtn_Sprig.addTarget(self, action: #selector(handleDelete_Sprig), for: .touchUpInside)
    }

    /// 点击删除按钮，向上层抛出回调由 VC 弹确认
    @objc private func handleDelete_Sprig() {
        onDelete_Sprig?()
    }

    func configure_Sprig(capsule_sprig: FlowerCapsule_Sprig) {
        if capsule_sprig.isUnlocked_Sprig {
            gradLayer_Sprig.colors = [
                UIColor(hexstring_Sprig: "#48BB78").withAlphaComponent(0.85).cgColor,
                UIColor(hexstring_Sprig: "#276749").cgColor
            ]
            lockIcon_Sprig.image = UIImage(systemName: "lock.open.fill")
            statusLabel_Sprig.text = "Unlocked"
            countdownLabel_Sprig.text = "🌸 Open"
            notesLabel_Sprig.text = capsule_sprig.notes_Sprig.isEmpty ? "(no notes)" : capsule_sprig.notes_Sprig
        } else {
            gradLayer_Sprig.colors = [
                UIColor(hexstring_Sprig: "#B794F4").cgColor,
                UIColor(hexstring_Sprig: "#6B46C1").cgColor
            ]
            lockIcon_Sprig.image = UIImage(systemName: "lock.fill")
            statusLabel_Sprig.text = "Sealed"
            countdownLabel_Sprig.text = "\(capsule_sprig.daysToUnlock_Sprig)d"
            let fmt_sprig = DateFormatter()
            fmt_sprig.dateFormat = "MMM yyyy"
            notesLabel_Sprig.text = "Unlocks \(fmt_sprig.string(from: capsule_sprig.unlockDate_Sprig))"
        }
        let fmt_sprig = DateFormatter()
        fmt_sprig.dateFormat = "MMM d, yyyy"
        dateLabel_Sprig.text = "Sealed · \(fmt_sprig.string(from: capsule_sprig.createDate_Sprig))"
    }

    func configureEmpty_Sprig() {
        gradLayer_Sprig.colors = [UIColor.systemGray5.cgColor, UIColor.systemGray4.cgColor]
        lockIcon_Sprig.image = UIImage(systemName: "plus.circle.dashed")
        lockIcon_Sprig.tintColor = UIColor.systemGray3
        statusLabel_Sprig.text = ""
        dateLabel_Sprig.text = ""
        countdownLabel_Sprig.text = ""
        notesLabel_Sprig.text = "Tap ＋ to create\nyour first capsule"
        notesLabel_Sprig.textColor = UIColor.systemGray2
    }
}

// MARK: - 首页推荐帖子轮播 Banner Cell

/// 首页推荐帖子轮播 Banner Cell
/// 功能：以媒体大图为背景，底部渐变遮罩上显示作者头像、用户名和帖子标题
/// 右上角提供举报/删除按钮（非本人帖子举报，本人帖子删除）
/// 头像点击 → 进入用户中心（非登录用户），卡片点击 → 进入帖子详情
class HomePostBannerCell_Sprig: FSPagerViewCell {

    static let reuseId_Sprig = "HomePostBannerCell_Sprig"

    // MARK: - UI 组件

    /// 媒体展示组件（支持图片/视频封面）
    private let mediaView_Sprig = MediaDisplayView_Sprig()

    /// 底部暗色渐变遮罩，使文字在任意媒体背景上清晰可读
    private let gradientOverlay_Sprig = CAGradientLayer()

    /// 用户头像（通用头像组件）
    private let avatarView_Sprig = UserAvatarView_Sprig()

    /// 用户名
    private let userNameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        return l
    }()

    /// 帖子标题
    private let titleLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    /// 右上角举报/删除按钮
    private let actionBtn_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        btn.layer.cornerRadius = 14
        return btn
    }()

    // MARK: - 回调

    /// 点击头像回调
    var onAvatarTap_Sprig: (() -> Void)?

    /// 点击操作按钮回调（传入 VC 供弹框使用）
    var onActionTap_Sprig: ((UIViewController?) -> Void)?

    /// 外部传入的 VC，供 Alert 使用
    weak var viewController_Sprig: UIViewController?

    // MARK: - 初始化

    override init(frame: CGRect) { super.init(frame: frame); setupUI_Sprig() }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI_Sprig() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientOverlay_Sprig.frame = contentView.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Sprig() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        // 媒体背景（全铺）
        contentView.addSubview(mediaView_Sprig)
        mediaView_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 底部渐变遮罩
        gradientOverlay_Sprig.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.72).cgColor
        ]
        gradientOverlay_Sprig.locations = [0.35, 1.0]
        contentView.layer.addSublayer(gradientOverlay_Sprig)

        // 头像（左下角）
        contentView.addSubview(avatarView_Sprig)
        avatarView_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(30)
        }
        avatarView_Sprig.isUserInteractionEnabled = true
        let avatarTap_sprig = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Sprig))
        avatarView_Sprig.addGestureRecognizer(avatarTap_sprig)

        // 用户名（头像右侧，底部对齐）
        contentView.addSubview(userNameLabel_Sprig)
        userNameLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Sprig.snp.right).offset(7)
            make.bottom.equalTo(avatarView_Sprig)
            make.right.equalToSuperview().offset(-44)
        }

        // 帖子标题（用户名上方）
        contentView.addSubview(titleLabel_Sprig)
        titleLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Sprig)
            make.right.equalToSuperview().offset(-44)
            make.bottom.equalTo(userNameLabel_Sprig.snp.top).offset(-4)
        }

        // 右上角操作按钮
        contentView.addSubview(actionBtn_Sprig)
        actionBtn_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        actionBtn_Sprig.addTarget(self, action: #selector(handleActionTap_Sprig), for: .touchUpInside)
    }

    // MARK: - 事件处理

    @objc private func handleAvatarTap_Sprig() { onAvatarTap_Sprig?() }

    @objc private func handleActionTap_Sprig() { onActionTap_Sprig?(viewController_Sprig) }

    // MARK: - 数据填充

    /// 配置帖子数据
    /// - Parameter post_sprig: 帖子模型
    func configure_Sprig(post_sprig: TitleModel_Sprig) {
        // 媒体展示
        let mediaPaths_sprig = post_sprig.titleMeidas_Sprig
        mediaView_Sprig.configure_Sprig(
            mediaPath_Sprig: mediaPaths_sprig.first,
            isVideo_Sprig: false
        )
        // 作者信息
        let author_sprig = UserViewModel_Sprig.shared_Sprig
            .getUserById_Sprig(userId_sprig: post_sprig.titleUserId_Sprig)
        avatarView_Sprig.configure_Sprig(userId_Sprig: post_sprig.titleUserId_Sprig)
        userNameLabel_Sprig.text = author_sprig.userName_Sprig
        titleLabel_Sprig.text = post_sprig.title_Sprig

        // 操作按钮：自己的帖子显示删除，他人的显示举报
        let isOwner_sprig = post_sprig.titleUserId_Sprig ==
            UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig().userId_Sprig
        let iconName_sprig = isOwner_sprig ? "trash" : "ellipsis"
        let cfg_sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        actionBtn_Sprig.setImage(UIImage(systemName: iconName_sprig, withConfiguration: cfg_sprig), for: .normal)
    }
}
