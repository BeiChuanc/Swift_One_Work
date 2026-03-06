import UIKit
import SnapKit
import FSPagerView

// MARK: - 首页 Section 类型

/// 首页集合视图分区枚举
private enum HomeSectionType_Trace: Int, CaseIterable {
    case inputBar_trace       = 0  // 极简输入条（融入滚动流）
    case header_trace         = 1
    case banner_trace         = 2
    case timelineHeader_trace = 3
    case records_trace        = 4
    case feed_trace           = 5  // 标签翻转帖子流（点击卡片翻转查看详情）
}

// MARK: - 时光记录查看周期

/// 时光归档查看周期枚举
private enum RecordPeriod_Trace: Int, CaseIterable {
    case day_trace = 0
    case week_trace = 1
    case month_trace = 2
    
    /// UI 显示标题
    var title_trace: String {
        switch self {
        case .day_trace:   return "Today"
        case .week_trace:  return "Week"
        case .month_trace: return "Month"
        }
    }
}

// MARK: - 首页

/// 首页视图控制器
/// 核心作用：「时光流」—— 极简输入条留存即时情绪，时光归档回溯生活轨迹，热门 Banner + 标签翻转帖子流
/// 设计思路：UICollectionView Compositional Layout 五分区，固定底部输入条，无 FAB
/// 关键属性：currentPeriod_Trace（当前归档周期），allPosts_Trace（所有帖子，双列翻转卡片展示）
class Home_Trace: UIViewController {

    // MARK: - 私有属性

    /// 当前帖子列表（无分类过滤，直接展示全部）
    private var allPosts_Trace: [TitleModel_Trace] = []

    /// Banner 帖子（取点赞数最高的前3条）
    private var bannerPosts_Trace: [TitleModel_Trace] = []
    
    /// 当前时光归档查看周期
    private var currentPeriod_Trace: RecordPeriod_Trace = .day_trace
    
    /// 当前周期内的时光记录
    private var currentPeriodRecords_Trace: [TraceRecord_Trace] = []
    
    // MARK: - UI 组件
    
    /// 主集合视图
    private lazy var collectionView_Trace: UICollectionView = {
        let cv_Trace = UICollectionView(frame: .zero, collectionViewLayout: createLayout_Trace())
        cv_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        cv_Trace.showsVerticalScrollIndicator = false
        cv_Trace.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        cv_Trace.dataSource = self
        cv_Trace.delegate = self
        cv_Trace.keyboardDismissMode = .onDrag
        cv_Trace.register(HomeInputBarCell_Trace.self, forCellWithReuseIdentifier: HomeInputBarCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeHeaderCell_Trace.self, forCellWithReuseIdentifier: HomeHeaderCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeBannerCell_Trace.self, forCellWithReuseIdentifier: HomeBannerCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeTimelineHeaderCell_Trace.self, forCellWithReuseIdentifier: HomeTimelineHeaderCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeRecordCell_Trace.self, forCellWithReuseIdentifier: HomeRecordCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeRecordEmptyCell_Trace.self, forCellWithReuseIdentifier: HomeRecordEmptyCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeFlipTagCell_Trace.self, forCellWithReuseIdentifier: HomeFlipTagCell_Trace.reuseId_Trace)
        return cv_Trace
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        setupPullToRefresh_Trace()
        subscribeNotifications_Trace()
        loadData_Trace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 统一使用 setNavigationBarHidden 维护 UINavigationController 内部状态
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        collectionView_Trace.contentInset.bottom = view.safeAreaInsets.bottom + 16
    }
    
    // MARK: - UI 配置
    
    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        view.addSubview(collectionView_Trace)
        collectionView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 配置下拉刷新
    private func setupPullToRefresh_Trace() {
        let refreshControl_Trace = UIRefreshControl()
        refreshControl_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        refreshControl_Trace.addTarget(self, action: #selector(handleRefresh_Trace(_:)), for: .valueChanged)
        collectionView_Trace.refreshControl = refreshControl_Trace
    }
    
    // MARK: - 数据加载
    
    private func loadData_Trace() {
        TitleViewModel_Trace.shared_Trace.initPosts_Trace()
        refreshData_Trace()
    }
    
    private func refreshData_Trace() {
        let posts_Trace = TitleViewModel_Trace.shared_Trace.getPosts_Trace()
        bannerPosts_Trace = Array(posts_Trace.sorted { $0.likes_Trace > $1.likes_Trace }.prefix(3))
        allPosts_Trace = posts_Trace
        updateCurrentPeriodRecords_Trace()
        collectionView_Trace.reloadData()
    }
    
    /// 根据当前周期更新时光记录列表
    private func updateCurrentPeriodRecords_Trace() {
        switch currentPeriod_Trace {
        case .day_trace:
            currentPeriodRecords_Trace = UserViewModel_Trace.shared_Trace.getTraceRecordsForDay_Trace()
        case .week_trace:
            currentPeriodRecords_Trace = UserViewModel_Trace.shared_Trace.getTraceRecordsForWeek_Trace()
        case .month_trace:
            currentPeriodRecords_Trace = UserViewModel_Trace.shared_Trace.getTraceRecordsForMonth_Trace()
        }
    }
    
    // MARK: - 通知订阅
    
    private func subscribeNotifications_Trace() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostsStateChange_Trace), name: TitleViewModel_Trace.titleStateDidChangeNotification_Trace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecordStateChange_Trace), name: UserViewModel_Trace.traceRecordDidChangeNotification_Trace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Trace(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Trace(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Compositional Layout 构建
    
    private func createLayout_Trace() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex_trace, _ in
            guard let self = self,
                  let section_trace = HomeSectionType_Trace(rawValue: sectionIndex_trace) else { return nil }
            switch section_trace {
            case .inputBar_trace:       return self.createInputBarSection_Trace()
            case .header_trace:         return self.createHeaderSection_Trace()
            case .banner_trace:         return self.createBannerSection_Trace()
            case .timelineHeader_trace: return self.createTimelineHeaderSection_Trace()
            case .records_trace:        return self.createRecordsSection_Trace()
            case .feed_trace:           return self.createFeedSection_Trace()
            }
        }
    }
    
    /// 极简输入条 section 布局
    private func createInputBarSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(58)))
        let group_Trace = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(58)), subitems: [item_Trace])
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16)
        return section_Trace
    }
    
    private func createHeaderSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)))
        let group_Trace = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)), subitems: [item_Trace])
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16)
        return section_Trace
    }
    
    private func createBannerSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220)))
        let group_Trace = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220)), subitems: [item_Trace])
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        // 左右各 16pt 水平间距
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        return section_Trace
    }
    
    private func createTimelineHeaderSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52)))
        let group_Trace = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52)), subitems: [item_Trace])
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 0, trailing: 16)
        return section_Trace
    }
    
    private func createRecordsSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(68)))
        let group_Trace = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(68)), subitems: [item_Trace])
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)
        section_Trace.interGroupSpacing = 8
        return section_Trace
    }
    
    /// 标签翻转帖子流布局（固定高度双列，保证翻转动画不受高度变化影响）
    private func createFeedSection_Trace() -> NSCollectionLayoutSection {
        let itemSize_Trace = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(175)
        )
        let item_Trace = NSCollectionLayoutItem(layoutSize: itemSize_Trace)
        item_Trace.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        let groupSize_Trace = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(175)
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize_Trace,
            subitems: [item_Trace, item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 14, bottom: 20, trailing: 14)
        section_Trace.interGroupSpacing = 12
        return section_Trace
    }
    
    // MARK: - 事件处理
    
    /// 发送时光记录（由 HomeInputBarCell_Trace 通过回调触发）
    /// - Parameter text_trace: 用户输入的文本内容
    private func handleSend_Trace(text_trace: String) {
        let content_Trace = text_trace.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content_Trace.isEmpty else { return }
        UserViewModel_Trace.shared_Trace.addTraceRecord_Trace(content_trace: content_Trace)
        let generator_Trace = UIImpactFeedbackGenerator(style: .medium)
        generator_Trace.impactOccurred()
    }
    
    @objc private func handleRefresh_Trace(_ refreshControl: UIRefreshControl) {
        TitleViewModel_Trace.shared_Trace.initPosts_Trace()
        refreshData_Trace()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            refreshControl.endRefreshing()
        }
    }
    
    @objc private func handlePostsStateChange_Trace() {
        refreshData_Trace()
    }
    
    @objc private func handleRecordStateChange_Trace() {
        updateCurrentPeriodRecords_Trace()
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet([
                HomeSectionType_Trace.timelineHeader_trace.rawValue,
                HomeSectionType_Trace.records_trace.rawValue
            ]))
        }
    }
    
    // MARK: - 键盘处理
    
    /// 键盘弹出时增大 collection view 底部 inset，防止内容被遮挡
    @objc private func keyboardWillShow_Trace(_ notification: Notification) {
        guard let keyboardFrame_Trace = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Trace = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let inset_Trace = keyboardFrame_Trace.height + 8
        UIView.animate(withDuration: duration_Trace) {
            self.collectionView_Trace.contentInset.bottom = inset_Trace
            self.collectionView_Trace.scrollIndicatorInsets.bottom = inset_Trace
        }
    }
    
    /// 键盘收起时恢复底部 inset
    @objc private func keyboardWillHide_Trace(_ notification: Notification) {
        guard let duration_Trace = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let defaultInset_Trace = view.safeAreaInsets.bottom + 16
        UIView.animate(withDuration: duration_Trace) {
            self.collectionView_Trace.contentInset.bottom = defaultInset_Trace
            self.collectionView_Trace.scrollIndicatorInsets.bottom = defaultInset_Trace
        }
    }
}

// MARK: - UICollectionViewDataSource

extension Home_Trace: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSectionType_Trace.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType_Trace = HomeSectionType_Trace(rawValue: section) else { return 0 }
        switch sectionType_Trace {
        case .inputBar_trace:       return 1
        case .header_trace:         return 1
        case .banner_trace:         return 1
        case .timelineHeader_trace: return 1
        case .records_trace:        return max(1, currentPeriodRecords_Trace.count)
        case .feed_trace:           return HomeFlipTagCell_Trace.lifeTips_Trace.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType_Trace = HomeSectionType_Trace(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType_Trace {
            
        case .inputBar_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeInputBarCell_Trace.reuseId_Trace, for: indexPath) as! HomeInputBarCell_Trace
            cell_Trace.onSend_Trace = { [weak self] text_trace in self?.handleSend_Trace(text_trace: text_trace) }
            // 未登录时拦截输入，跳转登录页
            cell_Trace.onNeedLogin_Trace = { Navigation_Trace.toLogin_Trace() }
            return cell_Trace
            
        case .header_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHeaderCell_Trace.reuseId_Trace, for: indexPath) as! HomeHeaderCell_Trace
            // 点击头像切换到底部 Tab 的「我的」页（index = 4）
            cell_Trace.onAvatarTapped_Trace = { Navigation_Trace.switchToTab_Trace(index: 4) }
            cell_Trace.onCheckInTapped_Trace = { Navigation_Trace.toCheckIn_Trace() }
            return cell_Trace
            
        case .banner_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBannerCell_Trace.reuseId_Trace, for: indexPath) as! HomeBannerCell_Trace
            cell_Trace.configure_Trace(posts_trace: bannerPosts_Trace)
            cell_Trace.onPostTapped_Trace = { post_trace in
                Navigation_Trace.toTitleDetail_Trace(titleModel_trace: post_trace)
            }
            return cell_Trace
            
        case .timelineHeader_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTimelineHeaderCell_Trace.reuseId_Trace, for: indexPath) as! HomeTimelineHeaderCell_Trace
            cell_Trace.configure_Trace(selectedPeriod_trace: currentPeriod_Trace, recordCount_trace: currentPeriodRecords_Trace.count)
            cell_Trace.onPeriodChanged_Trace = { [weak self] period_trace in
                guard let self = self else { return }
                self.currentPeriod_Trace = period_trace
                self.updateCurrentPeriodRecords_Trace()
                UIView.performWithoutAnimation {
                    collectionView.reloadSections(IndexSet(integer: HomeSectionType_Trace.records_trace.rawValue))
                }
            }
            return cell_Trace
            
        case .records_trace:
            if currentPeriodRecords_Trace.isEmpty {
                return collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecordEmptyCell_Trace.reuseId_Trace, for: indexPath)
            }
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecordCell_Trace.reuseId_Trace, for: indexPath) as! HomeRecordCell_Trace
            let record_Trace = currentPeriodRecords_Trace[indexPath.item]
            let showDate_Trace = (currentPeriod_Trace != .day_trace)
            cell_Trace.configure_Trace(record_trace: record_Trace, showDate_trace: showDate_Trace)
            return cell_Trace
            
        case .feed_trace:
            let cell_Trace = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeFlipTagCell_Trace.reuseId_Trace, for: indexPath
            ) as! HomeFlipTagCell_Trace
            let tip_Trace = HomeFlipTagCell_Trace.lifeTips_Trace[indexPath.item]
            cell_Trace.configure_Trace(tip_trace: tip_Trace)
            // 入场淡入动画（交错延迟）
            let delay_Trace = Double(indexPath.item % 8) * AnimationConfig_Trace.delayShort_Trace
            cell_Trace.alpha = 0
            cell_Trace.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            UIView.animate(
                withDuration: AnimationConfig_Trace.durationSpring_Trace,
                delay: delay_Trace,
                usingSpringWithDamping: AnimationConfig_Trace.springDampingNormal_Trace,
                initialSpringVelocity: AnimationConfig_Trace.springVelocity_Trace,
                options: [.curveEaseOut, .allowUserInteraction]
            ) {
                cell_Trace.alpha = 1
                cell_Trace.transform = .identity
            }
            return cell_Trace
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Home_Trace: UICollectionViewDelegate {
    
    /// 长按时光记录卡片显示删除菜单
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let section_Trace = HomeSectionType_Trace(rawValue: indexPath.section),
              section_Trace == .records_trace,
              !currentPeriodRecords_Trace.isEmpty,
              indexPath.item < currentPeriodRecords_Trace.count else { return nil }
        
        let record_Trace = currentPeriodRecords_Trace[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction_Trace = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                UserViewModel_Trace.shared_Trace.deleteTraceRecord_Trace(recordId_trace: record_Trace.recordId_Trace)
            }
            return UIMenu(title: "", children: [deleteAction_Trace])
        }
    }
}

// MARK: - 首页 Header Cell（问候 + 打卡按钮 + 头像）

/// 首页顶部问候栏 Cell
/// 功能：显示时间段问候语、当前日期，右侧有打卡按钮和用户头像
private class HomeHeaderCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "HomeHeaderCell_Trace"
    
    var onAvatarTapped_Trace: (() -> Void)?
    var onCheckInTapped_Trace: (() -> Void)?
    
    private let containerView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 20
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_Trace.layer.shadowRadius = 8
        v_Trace.layer.shadowOpacity = 0.06
        return v_Trace
    }()
    
    private let greetingLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl_Trace
    }()
    
    private let dateLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl_Trace
    }()
    
    /// 打卡按钮（日历图标）
    private let checkInButton_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn_Trace.setImage(UIImage(systemName: "calendar.badge.checkmark", withConfiguration: config_Trace), for: .normal)
        btn_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        btn_Trace.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.1)
        btn_Trace.layer.cornerRadius = 18
        btn_Trace.layer.masksToBounds = true
        return btn_Trace
    }()
    
    private let avatarButton_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.layer.cornerRadius = 18
        btn_Trace.layer.masksToBounds = true
        return btn_Trace
    }()
    
    private let avatarIconView_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 24, weight: .light)
        iv_Trace.image = UIImage(systemName: "person.circle.fill", withConfiguration: config_Trace)
        iv_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        iv_Trace.contentMode = .scaleAspectFill
        iv_Trace.isUserInteractionEnabled = false
        return iv_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Trace() {
        contentView.addSubview(containerView_Trace)
        containerView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        containerView_Trace.addSubview(greetingLabel_Trace)
        containerView_Trace.addSubview(dateLabel_Trace)
        containerView_Trace.addSubview(checkInButton_Trace)
        containerView_Trace.addSubview(avatarButton_Trace)
        avatarButton_Trace.addSubview(avatarIconView_Trace)
        
        avatarButton_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        avatarIconView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        checkInButton_Trace.snp.makeConstraints { make in
            make.trailing.equalTo(avatarButton_Trace.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        greetingLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(checkInButton_Trace.snp.leading).offset(-8)
        }
        dateLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(greetingLabel_Trace.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualTo(checkInButton_Trace.snp.leading).offset(-8)
        }
        
        checkInButton_Trace.addTarget(self, action: #selector(handleCheckInTap_Trace), for: .touchUpInside)
        avatarButton_Trace.addTarget(self, action: #selector(handleAvatarTap_Trace), for: .touchUpInside)
        
        updateGreeting_Trace()
    }
    
    private func updateGreeting_Trace() {
        let hour_Trace = Calendar.current.component(.hour, from: Date())
        let greeting_Trace: String
        switch hour_Trace {
        case 5..<12:  greeting_Trace = "Good morning ☀️"
        case 12..<18: greeting_Trace = "Good afternoon 🌤"
        default:      greeting_Trace = "Good evening 🌙"
        }
        greetingLabel_Trace.text = greeting_Trace
        
        let formatter_Trace = DateFormatter()
        formatter_Trace.dateFormat = "EEEE, MMM d"
        dateLabel_Trace.text = formatter_Trace.string(from: Date())
    }
    
    @objc private func handleCheckInTap_Trace() {
        checkInButton_Trace.animatePressDown_Trace { self.checkInButton_Trace.animatePressUp_Trace() }
        onCheckInTapped_Trace?()
    }
    
    @objc private func handleAvatarTap_Trace() {
        avatarButton_Trace.animatePressDown_Trace { self.avatarButton_Trace.animatePressUp_Trace() }
        onAvatarTapped_Trace?()
    }
}

// MARK: - 首页 Banner Cell（FSPagerView 轮播）

/// 首页 Banner 轮播 Cell（已含16pt左右内边距由 Section 控制）
private class HomeBannerCell_Trace: UICollectionViewCell, FSPagerViewDataSource, FSPagerViewDelegate {
    
    static let reuseId_Trace = "HomeBannerCell_Trace"
    
    private var posts_Trace: [TitleModel_Trace] = []
    var onPostTapped_Trace: ((TitleModel_Trace) -> Void)?
    
    private lazy var pagerView_Trace: FSPagerView = {
        let pv_Trace = FSPagerView()
        pv_Trace.dataSource = self
        pv_Trace.delegate = self
        pv_Trace.isInfinite = true
        pv_Trace.automaticSlidingInterval = 3.0
        pv_Trace.interitemSpacing = 12
        pv_Trace.decelerationDistance = FSPagerView.automaticDistance
        pv_Trace.register(HomeBannerPageCell_Trace.self, forCellWithReuseIdentifier: HomeBannerPageCell_Trace.reuseId_Trace)
        pv_Trace.transformer = FSPagerViewTransformer(type: .linear)
        return pv_Trace
    }()
    
    private let pageControl_Trace: FSPageControl = {
        let pc_Trace = FSPageControl()
        pc_Trace.contentHorizontalAlignment = .center
        pc_Trace.setFillColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        pc_Trace.setFillColor(.white, for: .selected)
        pc_Trace.itemSpacing = 8
        pc_Trace.interitemSpacing = 6
        return pc_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.addSubview(pagerView_Trace)
        contentView.addSubview(pageControl_Trace)
        pagerView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        pageControl_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Trace(posts_trace: [TitleModel_Trace]) {
        self.posts_Trace = posts_trace
        pageControl_Trace.numberOfPages = posts_trace.count
        pageControl_Trace.currentPage = 0
        pagerView_Trace.reloadData()
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int { return posts_Trace.count }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell_Trace = pagerView.dequeueReusableCell(withReuseIdentifier: HomeBannerPageCell_Trace.reuseId_Trace, at: index) as! HomeBannerPageCell_Trace
        cell_Trace.configure_Trace(post_trace: posts_Trace[index])
        return cell_Trace
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        guard index < posts_Trace.count else { return }
        onPostTapped_Trace?(posts_Trace[index])
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl_Trace.currentPage = pagerView.currentIndex
    }
}

// MARK: - Banner 内页 Cell

/// Banner 轮播内页 Cell
/// 核心作用：以 MediaDisplayView_Trace 作为背景媒体展示，底部渐变遮罩 + 标题/作者/点赞叠加
private class HomeBannerPageCell_Trace: FSPagerViewCell {

    static let reuseId_Trace = "HomeBannerPageCell_Trace"

    /// 媒体展示组件（全帧填充，圆角由 contentView 统一裁剪）
    private let mediaView_Trace: MediaDisplayView_Trace = {
        let v = MediaDisplayView_Trace()
        v.layer.cornerRadius = 0
        v.clipsToBounds = true
        return v
    }()

    /// 底部渐变遮罩（增强文字可读性）
    private let overlayLayer_Trace = CAGradientLayer()

    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        return lbl
    }()

    private let authorLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.85)
        return lbl
    }()

    private let likeLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.85)
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true

        // 媒体组件铺满
        contentView.addSubview(mediaView_Trace)
        mediaView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 底部渐变遮罩层（透明 → 半黑），叠在媒体上方
        overlayLayer_Trace.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.65).cgColor]
        overlayLayer_Trace.startPoint = CGPoint(x: 0.5, y: 0)
        overlayLayer_Trace.endPoint   = CGPoint(x: 0.5, y: 1)
        contentView.layer.addSublayer(overlayLayer_Trace)

        // 文字叠层
        contentView.addSubview(likeLabel_Trace)
        contentView.addSubview(authorLabel_Trace)
        contentView.addSubview(titleLabel_Trace)

        likeLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-18)
        }
        authorLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalTo(likeLabel_Trace.snp.top).offset(-4)
        }
        titleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.bottom.equalTo(authorLabel_Trace.snp.top).offset(-8)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayLayer_Trace.frame = contentView.bounds
    }

    /// 配置 Banner 内容
    /// - Parameter post_trace: 热门帖子数据（取第一张媒体作为背景）
    func configure_Trace(post_trace: TitleModel_Trace) {
        // 使用帖子首张媒体资源作为背景
        let mediaPath_Trace = post_trace.titleMeidas_Trace.first
        mediaView_Trace.configure_Trace(mediaPath_Trace: mediaPath_Trace)
        titleLabel_Trace.text  = post_trace.title_Trace
        authorLabel_Trace.text = "by \(post_trace.titleUserName_Trace)"
        likeLabel_Trace.text   = "♥ \(post_trace.likes_Trace) likes"
    }
}

// MARK: - 时光归档 Header Cell（周期选择）

/// 时光归档区 Header Cell
/// 功能：展示 "Life Traces" 标题、记录条数 badge、Today/Week/Month 周期切换按钮
private class HomeTimelineHeaderCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "HomeTimelineHeaderCell_Trace"
    
    var onPeriodChanged_Trace: ((RecordPeriod_Trace) -> Void)?
    
    private var currentPeriod_Trace: RecordPeriod_Trace = .day_trace
    private var periodButtons_Trace: [UIButton] = []
    
    private let titleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Life Traces"
        lbl_Trace.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl_Trace
    }()
    
    private let countBadge_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Trace.textColor = ColorConfig_Trace.primaryGradientStart_Trace
        lbl_Trace.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.1)
        lbl_Trace.textAlignment = .center
        lbl_Trace.layer.cornerRadius = 9
        lbl_Trace.layer.masksToBounds = true
        return lbl_Trace
    }()
    
    private let periodStackView_Trace: UIStackView = {
        let sv_Trace = UIStackView()
        sv_Trace.axis = .horizontal
        sv_Trace.spacing = 6
        sv_Trace.alignment = .center
        return sv_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Trace() {
        contentView.addSubview(titleLabel_Trace)
        contentView.addSubview(countBadge_Trace)
        contentView.addSubview(periodStackView_Trace)
        
        for period_Trace in RecordPeriod_Trace.allCases {
            let btn_Trace = makePeriodButton_Trace(period_trace: period_Trace)
            periodButtons_Trace.append(btn_Trace)
            periodStackView_Trace.addArrangedSubview(btn_Trace)
        }
        
        titleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        countBadge_Trace.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Trace.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(28)
        }
        periodStackView_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func makePeriodButton_Trace(period_trace: RecordPeriod_Trace) -> UIButton {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.tag = period_trace.rawValue
        btn_Trace.setTitle(period_trace.title_trace, for: .normal)
        btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn_Trace.layer.cornerRadius = 12
        btn_Trace.layer.masksToBounds = true
        btn_Trace.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        btn_Trace.addTarget(self, action: #selector(handlePeriodTap_Trace(_:)), for: .touchUpInside)
        btn_Trace.snp.makeConstraints { make in make.height.equalTo(24) }
        return btn_Trace
    }
    
    /// 配置时光归档 Header
    func configure_Trace(selectedPeriod_trace: RecordPeriod_Trace, recordCount_trace: Int) {
        currentPeriod_Trace = selectedPeriod_trace
        countBadge_Trace.text = "  \(recordCount_trace)  "
        updatePeriodButtonStates_Trace()
    }
    
    private func updatePeriodButtonStates_Trace() {
        for btn_Trace in periodButtons_Trace {
            btn_Trace.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            let isSelected_Trace = btn_Trace.tag == currentPeriod_Trace.rawValue
            if isSelected_Trace {
                let grad_Trace = CAGradientLayer()
                grad_Trace.colors = [
                    ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
                    ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
                ]
                grad_Trace.startPoint = CGPoint(x: 0, y: 0)
                grad_Trace.endPoint = CGPoint(x: 1, y: 1)
                grad_Trace.cornerRadius = 12
                btn_Trace.layer.insertSublayer(grad_Trace, at: 0)
                btn_Trace.setTitleColor(.white, for: .normal)
                DispatchQueue.main.async { grad_Trace.frame = btn_Trace.bounds }
            } else {
                btn_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
                btn_Trace.setTitleColor(ColorConfig_Trace.textSecondary_Trace, for: .normal)
            }
        }
    }
    
    @objc private func handlePeriodTap_Trace(_ sender: UIButton) {
        guard let period_Trace = RecordPeriod_Trace(rawValue: sender.tag) else { return }
        currentPeriod_Trace = period_Trace
        updatePeriodButtonStates_Trace()
        sender.animatePressDown_Trace { sender.animatePressUp_Trace() }
        onPeriodChanged_Trace?(period_Trace)
    }
}

// MARK: - 时光记录 Cell

/// 单条时光记录 Cell
/// 核心作用：以「内容为主、时间戳置底」的清晰卡片样式展示一条时光记录
/// 布局：左侧渐变竖条 → 右侧内容区（正文文本 + 底部时间行）
/// 关键属性：contentLabel_Trace（记录内容），timeLabel_Trace（时间戳），showDate_trace（是否显示日期）
private class HomeRecordCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "HomeRecordCell_Trace"
    
    // MARK: - UI 组件
    
    private let cardView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 14
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_Trace.layer.shadowRadius = 8
        v_Trace.layer.shadowOpacity = 0.06
        return v_Trace
    }()
    
    /// 左侧渐变竖条装饰
    private let accentBar_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.layer.cornerRadius = 2
        return v_Trace
    }()
    
    private let accentBarGrad_Trace = CAGradientLayer()
    
    /// 记录正文内容
    private let contentLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl_Trace.numberOfLines = 4
        return lbl_Trace
    }()
    
    /// 底部时间行：渐变圆点 + 时间文字
    private let timeDot_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.layer.cornerRadius = 4
        return v_Trace
    }()
    
    private let timeDotGrad_Trace = CAGradientLayer()
    
    private let timeLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl_Trace
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI_Trace() {
        contentView.addSubview(cardView_Trace)
        cardView_Trace.addSubview(accentBar_Trace)
        cardView_Trace.addSubview(contentLabel_Trace)
        cardView_Trace.addSubview(timeDot_Trace)
        cardView_Trace.addSubview(timeLabel_Trace)
        
        // 左侧竖条渐变（上→下）
        accentBarGrad_Trace.startPoint = CGPoint(x: 0, y: 0)
        accentBarGrad_Trace.endPoint = CGPoint(x: 0, y: 1)
        accentBarGrad_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        accentBarGrad_Trace.cornerRadius = 2
        accentBar_Trace.layer.insertSublayer(accentBarGrad_Trace, at: 0)
        
        // 时间圆点渐变
        timeDotGrad_Trace.startPoint = CGPoint(x: 0, y: 0)
        timeDotGrad_Trace.endPoint = CGPoint(x: 1, y: 1)
        timeDotGrad_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        timeDotGrad_Trace.cornerRadius = 4
        timeDot_Trace.layer.insertSublayer(timeDotGrad_Trace, at: 0)
        
        cardView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        accentBar_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.equalTo(3)
        }
        contentLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Trace.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
        timeDot_Trace.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel_Trace.snp.leading)
            make.top.equalTo(contentLabel_Trace.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(8)
            make.centerY.equalTo(timeLabel_Trace)
        }
        timeLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(timeDot_Trace.snp.trailing).offset(6)
            make.centerY.equalTo(timeDot_Trace)
            make.trailing.equalToSuperview().offset(-14)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accentBarGrad_Trace.frame = accentBar_Trace.bounds
        timeDotGrad_Trace.frame = timeDot_Trace.bounds
    }
    
    /// 配置记录数据
    /// - Parameters:
    ///   - record_trace: 时光记录模型
    ///   - showDate_trace: Week/Month 视图下为 true，在时间前附加日期
    func configure_Trace(record_trace: TraceRecord_Trace, showDate_trace: Bool) {
        contentLabel_Trace.text = record_trace.content_Trace
        timeLabel_Trace.text = showDate_trace
            ? "\(record_trace.shortDateString_Trace)  ·  \(record_trace.timeString_Trace)"
            : record_trace.timeString_Trace
    }
}

// MARK: - 时光记录空状态 Cell

/// 时光记录为空时的占位 Cell
private class HomeRecordEmptyCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "HomeRecordEmptyCell_Trace"
    
    private let iconView_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
        iv_Trace.image = UIImage(systemName: "pencil.and.sparkles", withConfiguration: config_Trace)
        iv_Trace.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    private let hintLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "No traces yet — capture your first moment below."
        lbl_Trace.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl_Trace.textAlignment = .center
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconView_Trace)
        contentView.addSubview(hintLabel_Trace)
        
        iconView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(28)
        }
        hintLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(iconView_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 生活记录技巧数据模型

/// 生活记录小技巧数据模型（静态内容，不依赖帖子数据）
private struct LifeTip_Trace {
    let emoji_trace: String
    let tag_trace: String
    let title_trace: String
    let body_trace: String
    let gradStart_trace: UIColor
    let gradEnd_trace: UIColor
}

// MARK: - 首页翻转卡片 Cell（生活记录小技巧，点击翻转查看正文）

/// 首页翻转式生活记录技巧卡 Cell
/// 核心作用：展示 6 条固定生活记录建议，正面简洁标题，背面完整说明，无帖子数据依赖
/// 设计思路：正面（渐变 + emoji + 标签 + 标题） ↔ 背面（白卡 + 渐变 badge + 完整正文）
/// 关键方法：configure_Trace（填充 LifeTip_Trace 静态数据）、handleTap_Trace（3D 翻转）
private class HomeFlipTagCell_Trace: UICollectionViewCell {

    static let reuseId_Trace = "HomeFlipTagCell_Trace"

    // MARK: - 静态技巧数据（6 条生活记录建议）
    static let lifeTips_Trace: [LifeTip_Trace] = [
        LifeTip_Trace(
            emoji_trace: "🌅", tag_trace: "CAPTURE",
            title_trace: "Snap Your First Smile",
            body_trace: "Capture the very first thing that makes you smile today — tiny moments build your best memories.",
            gradStart_trace: UIColor(hexstring_Trace: "#FF9A8B"),
            gradEnd_trace:   UIColor(hexstring_Trace: "#FF6A88")
        ),
        LifeTip_Trace(
            emoji_trace: "🌙", tag_trace: "MOOD",
            title_trace: "3-Word Feeling Check",
            body_trace: "Describe how you feel right now in exactly 3 words — no overthinking, just pure honest instinct.",
            gradStart_trace: UIColor(hexstring_Trace: "#2C3E50"),
            gradEnd_trace:   UIColor(hexstring_Trace: "#4CA1AF")
        ),
        LifeTip_Trace(
            emoji_trace: "✨", tag_trace: "GRATITUDE",
            title_trace: "One Thing Before Sleep",
            body_trace: "Every evening write one thing you're grateful for. Over time, it rewires your brain toward joy.",
            gradStart_trace: UIColor(hexstring_Trace: "#A18CD1"),
            gradEnd_trace:   UIColor(hexstring_Trace: "#FBC2EB")
        ),
        LifeTip_Trace(
            emoji_trace: "🔥", tag_trace: "WIN",
            title_trace: "Celebrate Small Wins",
            body_trace: "Acknowledge tiny victories every day — they are the building blocks of your life's bigger story.",
            gradStart_trace: UIColor(hexstring_Trace: "#FA709A"),
            gradEnd_trace:   UIColor(hexstring_Trace: "#FEE140")
        ),
        LifeTip_Trace(
            emoji_trace: "💫", tag_trace: "SENSES",
            title_trace: "Save a Sensory Detail",
            body_trace: "Note one sensory detail from today: a scent that stopped you, a color, or an unexpected sound.",
            gradStart_trace: UIColor(hexstring_Trace: "#4776E6"),
            gradEnd_trace:   UIColor(hexstring_Trace: "#8E54E9")
        ),
        LifeTip_Trace(
            emoji_trace: "🌿", tag_trace: "REFLECT",
            title_trace: "Write to Future You",
            body_trace: "Ask yourself: what would I tell my future self about today? Your answer is worth keeping forever.",
            gradStart_trace: UIColor(hexstring_Trace: "#56AB2F"),
            gradEnd_trace:   UIColor(hexstring_Trace: "#A8E063")
        ),
    ]

    // MARK: - 状态
    private var isFlipped_Trace = false

    // MARK: - 正面视图

    private let frontView_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = true
        v.isUserInteractionEnabled = true
        return v
    }()

    private let frontGradientLayer_Trace = CAGradientLayer()

    /// 正面顶部高光条（增强立体感）
    private let frontShineView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v.layer.cornerRadius = 2
        v.isUserInteractionEnabled = false
        return v
    }()

    private let tagEmojiLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 28)
        return lbl
    }()

    private let tagNameLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.75)
        return lbl
    }()

    private let frontTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl.textColor = .white
        lbl.numberOfLines = 3
        return lbl
    }()

    /// 正面右下角翻转提示图标
    private let flipHintIcon_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .light)
        iv.image = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.45)
        return iv
    }()

    // MARK: - 背面视图

    private let backView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = true
        v.isHidden = true
        v.isUserInteractionEnabled = true
        return v
    }()

    private let backTagBadge_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 9
        v.layer.masksToBounds = true
        return v
    }()
    private let backTagBadgeGrad_Trace = CAGradientLayer()

    private let backTagBadgeLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    private let backTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 背面技巧正文（最多 4 行，展示完整建议内容）
    private let backBodyLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textSecondary_Trace
        lbl.numberOfLines = 4
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.10
        layer.masksToBounds = false
        setupUI_Trace()
        setupGestures_Trace()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        frontGradientLayer_Trace.frame = frontView_Trace.bounds
        backTagBadgeGrad_Trace.frame   = backTagBadge_Trace.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // 复用时归位正面，避免翻转状态残留
        if isFlipped_Trace {
            frontView_Trace.isHidden = false
            backView_Trace.isHidden  = true
            isFlipped_Trace = false
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        // ---- 正面 ----
        contentView.addSubview(frontView_Trace)
        frontView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }

        frontGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        frontGradientLayer_Trace.endPoint   = CGPoint(x: 1, y: 1)
        frontGradientLayer_Trace.cornerRadius = 18
        frontView_Trace.layer.insertSublayer(frontGradientLayer_Trace, at: 0)

        frontView_Trace.addSubview(frontShineView_Trace)
        frontShineView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
            make.height.equalTo(3)
        }

        frontView_Trace.addSubview(tagEmojiLabel_Trace)
        tagEmojiLabel_Trace.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(14)
        }

        frontView_Trace.addSubview(tagNameLabel_Trace)
        tagNameLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(tagEmojiLabel_Trace.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(14)
            make.trailing.equalToSuperview().inset(8)
        }

        frontView_Trace.addSubview(frontTitleLabel_Trace)
        frontTitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(tagNameLabel_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(14)
        }

        frontView_Trace.addSubview(flipHintIcon_Trace)
        flipHintIcon_Trace.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(14)
        }

        // ---- 背面 ----
        contentView.addSubview(backView_Trace)
        backView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }

        backTagBadgeGrad_Trace.startPoint = CGPoint(x: 0, y: 0)
        backTagBadgeGrad_Trace.endPoint   = CGPoint(x: 1, y: 1)
        backTagBadgeGrad_Trace.cornerRadius = 9
        backTagBadge_Trace.layer.insertSublayer(backTagBadgeGrad_Trace, at: 0)

        backView_Trace.addSubview(backTagBadge_Trace)
        backTagBadge_Trace.addSubview(backTagBadgeLabel_Trace)
        backTagBadge_Trace.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
            make.height.equalTo(18)
        }
        backTagBadgeLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }

        backView_Trace.addSubview(backTitleLabel_Trace)
        backTitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(backTagBadge_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        backView_Trace.addSubview(backBodyLabel_Trace)
        backBodyLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(backTitleLabel_Trace.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }

    private func setupGestures_Trace() {
        let frontTap_Trace = UITapGestureRecognizer(target: self, action: #selector(handleTap_Trace))
        frontView_Trace.addGestureRecognizer(frontTap_Trace)
        let backTap_Trace = UITapGestureRecognizer(target: self, action: #selector(handleTap_Trace))
        backView_Trace.addGestureRecognizer(backTap_Trace)
    }

    // MARK: - 公共方法

    /// 填充生活记录技巧数据到正面和背面
    /// - Parameter tip_trace: 生活记录技巧静态数据模型
    func configure_Trace(tip_trace: LifeTip_Trace) {
        frontGradientLayer_Trace.colors  = [tip_trace.gradStart_trace.cgColor, tip_trace.gradEnd_trace.cgColor]
        tagEmojiLabel_Trace.text         = tip_trace.emoji_trace
        tagNameLabel_Trace.text          = tip_trace.tag_trace
        frontTitleLabel_Trace.text       = tip_trace.title_trace
        backTagBadgeGrad_Trace.colors    = [tip_trace.gradStart_trace.cgColor, tip_trace.gradEnd_trace.cgColor]
        backTagBadgeLabel_Trace.text     = "\(tip_trace.emoji_trace) \(tip_trace.tag_trace)"
        backTitleLabel_Trace.text        = tip_trace.title_trace
        backBodyLabel_Trace.text         = tip_trace.body_trace
        // 延迟一帧同步渐变 frame（layoutSubviews 会持续更新，此处作为补充保障）
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.frontGradientLayer_Trace.frame = self.frontView_Trace.bounds
            self.backTagBadgeGrad_Trace.frame   = self.backTagBadge_Trace.bounds
        }
    }

    // MARK: - 事件处理

    /// 点击卡片执行 3D 翻转动画（正面 ↔ 背面）
    @objc private func handleTap_Trace() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isFlipped_Trace.toggle()
        let fromView_Trace = isFlipped_Trace ? frontView_Trace : backView_Trace
        let toView_Trace   = isFlipped_Trace ? backView_Trace  : frontView_Trace
        UIView.transition(
            from: fromView_Trace,
            to: toView_Trace,
            duration: 0.45,
            options: [.transitionFlipFromRight, .showHideTransitionViews],
            completion: nil
        )
    }
}

// MARK: - 首页极简输入条 Cell

/// 首页极简输入条 Cell
/// 核心作用：融入滚动流的记录入口，风格与发现页搜索框一致
/// 设计思路：白色圆角卡 + 阴影 + 笔图标 + 聚焦时渐变描边动画 + 右侧渐变发送按钮
/// 关键方法：onSend_Trace 回调，将文本内容传递给 VC 处理
private class HomeInputBarCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "HomeInputBarCell_Trace"
    
    /// 发送回调，返回用户输入的非空文本
    var onSend_Trace: ((String) -> Void)?

    /// 未登录时尝试输入触发此回调（由外部负责跳转登录页）
    var onNeedLogin_Trace: (() -> Void)?
    
    // MARK: - UI 组件
    
    /// 白色圆角卡容器，承载所有子视图
    private let containerView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 22
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_Trace.layer.shadowRadius = 10
        v_Trace.layer.shadowOpacity = 0.07
        return v_Trace
    }()
    
    /// 聚焦状态渐变描边层（与发现页搜索框逻辑相同）
    private let focusBorderLayer_Trace = CAGradientLayer()
    private let focusBorderMask_Trace  = CAShapeLayer()
    
    /// 左侧笔形图标
    private let penIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let cfg_Trace = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv_Trace.image = UIImage(systemName: "pencil.line", withConfiguration: cfg_Trace)
        iv_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    /// 文本输入框
    private lazy var inputField_Trace: UITextField = {
        let tf_Trace = UITextField()
        tf_Trace.placeholder = "Record this moment..."
        tf_Trace.font = UIFont.systemFont(ofSize: 15)
        tf_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        tf_Trace.returnKeyType = .done
        tf_Trace.delegate = self
        return tf_Trace
    }()
    
    /// 右侧渐变发送按钮（32×32）
    private let sendBtn_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.layer.cornerRadius = 16
        btn_Trace.layer.masksToBounds = true
        return btn_Trace
    }()
    
    private let sendGrad_Trace = CAGradientLayer()
    
    /// 发送按钮内的箭头图标（叠在渐变层上方，避免被遮挡）
    private let sendIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let cfg_Trace = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        iv_Trace.image = UIImage(systemName: "arrow.up", withConfiguration: cfg_Trace)
        iv_Trace.tintColor = .white
        iv_Trace.contentMode = .scaleAspectFit
        iv_Trace.isUserInteractionEnabled = false
        return iv_Trace
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - 布局回调
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 渐变层跟随容器尺寸更新
        focusBorderLayer_Trace.frame = containerView_Trace.bounds
        focusBorderMask_Trace.path  = UIBezierPath(roundedRect: containerView_Trace.bounds, cornerRadius: 22).cgPath
        let inset_Trace: CGFloat = 1.2
        focusBorderMask_Trace.frame = containerView_Trace.bounds
        let innerRect_Trace = containerView_Trace.bounds.insetBy(dx: inset_Trace, dy: inset_Trace)
        let holePath_Trace = UIBezierPath(roundedRect: containerView_Trace.bounds, cornerRadius: 22)
        holePath_Trace.append(UIBezierPath(roundedRect: innerRect_Trace, cornerRadius: 22 - inset_Trace))
        holePath_Trace.usesEvenOddFillRule = true
        focusBorderMask_Trace.path = holePath_Trace.cgPath
        focusBorderMask_Trace.fillRule = .evenOdd
        sendGrad_Trace.frame = sendBtn_Trace.bounds
    }
    
    // MARK: - UI 配置
    
    /// 搭建输入条内部布局
    private func setupUI_Trace() {
        contentView.addSubview(containerView_Trace)
        containerView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        // 聚焦描边层（初始隐藏）
        focusBorderLayer_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        focusBorderLayer_Trace.startPoint = CGPoint(x: 0, y: 0.5)
        focusBorderLayer_Trace.endPoint   = CGPoint(x: 1, y: 0.5)
        focusBorderLayer_Trace.cornerRadius = 22
        focusBorderLayer_Trace.mask = focusBorderMask_Trace
        focusBorderLayer_Trace.opacity = 0
        containerView_Trace.layer.addSublayer(focusBorderLayer_Trace)
        
        // 笔图标
        containerView_Trace.addSubview(penIcon_Trace)
        penIcon_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 发送按钮（渐变 + 图标）
        containerView_Trace.addSubview(sendBtn_Trace)
        sendBtn_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        sendGrad_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        sendGrad_Trace.startPoint  = CGPoint(x: 0, y: 0)
        sendGrad_Trace.endPoint    = CGPoint(x: 1, y: 1)
        sendGrad_Trace.cornerRadius = 16
        sendBtn_Trace.layer.insertSublayer(sendGrad_Trace, at: 0)
        sendBtn_Trace.addSubview(sendIcon_Trace)
        sendIcon_Trace.snp.makeConstraints { make in make.center.equalToSuperview() }
        sendBtn_Trace.addTarget(self, action: #selector(handleSendTap_Trace), for: .touchUpInside)
        
        // 文本输入框
        containerView_Trace.addSubview(inputField_Trace)
        inputField_Trace.snp.makeConstraints { make in
            make.leading.equalTo(penIcon_Trace.snp.trailing).offset(10)
            make.trailing.equalTo(sendBtn_Trace.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - 事件处理
    
    /// 发送按钮点击，回调文本内容
    @objc private func handleSendTap_Trace() {
        submitText_Trace()
    }
    
    /// 统一提交逻辑：校验非空后回调并清空输入框
    private func submitText_Trace() {
        let text_Trace = inputField_Trace.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_Trace.isEmpty else { return }
        onSend_Trace?(text_Trace)
        inputField_Trace.text = ""
        inputField_Trace.resignFirstResponder()
        // 触感反馈
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // MARK: - 聚焦描边动画（与发现页搜索框保持一致）
    
    /// 显示渐变描边
    private func showFocusBorder_Trace() {
        let anim_Trace = CABasicAnimation(keyPath: "opacity")
        anim_Trace.fromValue = 0
        anim_Trace.toValue   = 1
        anim_Trace.duration  = AnimationConfig_Trace.durationNormal_Trace
        anim_Trace.fillMode  = .forwards
        anim_Trace.isRemovedOnCompletion = false
        focusBorderLayer_Trace.add(anim_Trace, forKey: "focusIn")
        focusBorderLayer_Trace.opacity = 1
    }
    
    /// 隐藏渐变描边
    private func hideFocusBorder_Trace() {
        let anim_Trace = CABasicAnimation(keyPath: "opacity")
        anim_Trace.fromValue = 1
        anim_Trace.toValue   = 0
        anim_Trace.duration  = AnimationConfig_Trace.durationNormal_Trace
        anim_Trace.fillMode  = .forwards
        anim_Trace.isRemovedOnCompletion = false
        focusBorderLayer_Trace.add(anim_Trace, forKey: "focusOut")
        focusBorderLayer_Trace.opacity = 0
    }
}

// MARK: - UITextFieldDelegate（HomeInputBarCell_Trace）

extension HomeInputBarCell_Trace: UITextFieldDelegate {
    
    /// 尝试开始编辑时校验登录状态，未登录则拦截并弹出登录页
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard UserViewModel_Trace.shared_Trace.isLoggedIn_Trace else {
            onNeedLogin_Trace?()
            return false
        }
        return true
    }

    /// 获得焦点时展示渐变描边
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showFocusBorder_Trace()
    }
    
    /// 失去焦点时隐藏渐变描边
    func textFieldDidEndEditing(_ textField: UITextField) {
        hideFocusBorder_Trace()
    }
    
    /// Return 键触发发送
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitText_Trace()
        return true
    }
}
