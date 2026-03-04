import UIKit
import SnapKit
import FSPagerView

// MARK: - 首页 Section 类型

/// 首页集合视图分区枚举
private enum HomeSectionType_Trace: Int, CaseIterable {
    case header_trace = 0
    case banner_trace = 1
    case timelineHeader_trace = 2
    case records_trace = 3
    case categories_trace = 4
    case feed_trace = 5
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
/// 核心作用：「时光流」—— 极简输入条留存即时情绪，时光归档回溯生活轨迹，热门 Banner + 分类帖子流
/// 设计思路：UICollectionView Compositional Layout 六分区，固定底部输入条，无 FAB
/// 关键属性：currentPeriod_Trace（当前归档周期），filteredPosts_Trace（当前帖子列表）
class Home_Trace: UIViewController {
    
    // MARK: - 常量
    
    /// 分类列表（All 表示不过滤）
    private let categories_Trace = ["All", "Life", "Moments", "Night", "Nature", "Memory", "Stars", "Warmth", "Friends"]
    
    /// 分类对应图标
    private let categoryIcons_Trace = ["square.grid.2x2", "sun.max.fill", "sparkles",
                                        "moon.stars.fill", "leaf.fill", "clock.fill",
                                        "star.fill", "flame.fill", "person.2.fill"]
    
    /// 输入条内容区高度
    private let inputBarContentHeight_Trace: CGFloat = 56
    
    // MARK: - 私有属性
    
    /// 当前显示的帖子列表（经分类过滤后）
    private var filteredPosts_Trace: [TitleModel_Trace] = []
    
    /// 当前选中的分类（nil 表示 All）
    private var selectedCategory_Trace: String? = nil
    
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
        cv_Trace.contentInset = UIEdgeInsets(top: inputBarContentHeight_Trace + 8, left: 0, bottom: 100, right: 0)
        cv_Trace.dataSource = self
        cv_Trace.delegate = self
        cv_Trace.register(HomeHeaderCell_Trace.self, forCellWithReuseIdentifier: HomeHeaderCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeBannerCell_Trace.self, forCellWithReuseIdentifier: HomeBannerCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeTimelineHeaderCell_Trace.self, forCellWithReuseIdentifier: HomeTimelineHeaderCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeRecordCell_Trace.self, forCellWithReuseIdentifier: HomeRecordCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeRecordEmptyCell_Trace.self, forCellWithReuseIdentifier: HomeRecordEmptyCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeCategoryContainerCell_Trace.self, forCellWithReuseIdentifier: HomeCategoryContainerCell_Trace.reuseId_Trace)
        cv_Trace.register(HomeFeedCell_Trace.self, forCellWithReuseIdentifier: HomeFeedCell_Trace.reuseId_Trace)
        return cv_Trace
    }()
    
    /// 顶部输入条外层容器
    private let inputBarContainer_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_Trace.layer.shadowRadius = 10
        v_Trace.layer.shadowOpacity = 0.07
        return v_Trace
    }()
    
    /// 输入框圆角容器
    private let inputFieldContainer_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = UIColor(hexstring_Trace: "#F4F4F8")
        v_Trace.layer.cornerRadius = 20
        v_Trace.layer.masksToBounds = true
        return v_Trace
    }()
    
    /// 极简输入框
    private lazy var inputField_Trace: UITextField = {
        let tf_Trace = UITextField()
        tf_Trace.placeholder = "Record this moment..."
        tf_Trace.font = UIFont.systemFont(ofSize: 15)
        tf_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        tf_Trace.returnKeyType = .done
        tf_Trace.delegate = self
        return tf_Trace
    }()
    
    /// 发送按钮（独立于输入框容器外）
    private lazy var sendButton_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Trace.setImage(UIImage(systemName: "arrow.up", withConfiguration: config_Trace), for: .normal)
        btn_Trace.tintColor = .white
        btn_Trace.layer.cornerRadius = 20
        btn_Trace.layer.masksToBounds = true
        btn_Trace.addTarget(self, action: #selector(handleSend_Trace), for: .touchUpInside)
        return btn_Trace
    }()
    
    private let sendGradientLayer_Trace = CAGradientLayer()
    
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
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendGradientLayer_Trace.frame = sendButton_Trace.bounds
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // 顶部为输入条高度 + 安全区域 top，底部预留 tab bar 空间
        collectionView_Trace.contentInset = UIEdgeInsets(
            top: inputBarContentHeight_Trace + 8,
            left: 0,
            bottom: view.safeAreaInsets.bottom + 16,
            right: 0
        )
    }
    
    // MARK: - UI 配置
    
    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        
        view.addSubview(collectionView_Trace)
        collectionView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupInputBar_Trace()
    }
    
    /// 搭建顶部极简输入条（常驻于安全区域顶部）
    /// 布局：[16pt] [输入框 flex] [10pt] [发送按钮 40x40] [16pt]
    private func setupInputBar_Trace() {
        view.addSubview(inputBarContainer_Trace)
        // 发送按钮独立挂在外层容器，与输入框平级
        inputBarContainer_Trace.addSubview(inputFieldContainer_Trace)
        inputBarContainer_Trace.addSubview(sendButton_Trace)
        inputFieldContainer_Trace.addSubview(inputField_Trace)
        
        inputBarContainer_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(inputBarContentHeight_Trace)
        }
        
        // 发送按钮：右侧 16pt，垂直居中，40×40 圆形渐变
        sendButton_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        // 输入框容器：左 16pt，右紧靠发送按钮左侧 10pt gap，高度 40
        inputFieldContainer_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton_Trace.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        inputField_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        
        // 输入框容器样式：边框 + 圆角
        inputFieldContainer_Trace.layer.cornerRadius = 20
        inputFieldContainer_Trace.layer.borderWidth = 1
        inputFieldContainer_Trace.layer.borderColor = ColorConfig_Trace.border_Trace.cgColor
        inputFieldContainer_Trace.backgroundColor = .white
        
        // 发送按钮渐变
        sendGradientLayer_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        sendGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        sendGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        sendGradientLayer_Trace.cornerRadius = 20
        sendButton_Trace.layer.insertSublayer(sendGradientLayer_Trace, at: 0)
        
        // 点击空白区域收起键盘
        let tapGesture_Trace = UITapGestureRecognizer(target: self, action: #selector(handleViewTap_Trace))
        tapGesture_Trace.cancelsTouchesInView = false
        collectionView_Trace.addGestureRecognizer(tapGesture_Trace)
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
        let allPosts_Trace = TitleViewModel_Trace.shared_Trace.getPosts_Trace()
        bannerPosts_Trace = Array(allPosts_Trace.sorted { $0.likes_Trace > $1.likes_Trace }.prefix(3))
        
        if let category_Trace = selectedCategory_Trace {
            filteredPosts_Trace = allPosts_Trace.filter { $0.titleTag_Trace == category_Trace }
        } else {
            filteredPosts_Trace = allPosts_Trace
        }
        
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
            case .header_trace:         return self.createHeaderSection_Trace()
            case .banner_trace:         return self.createBannerSection_Trace()
            case .timelineHeader_trace: return self.createTimelineHeaderSection_Trace()
            case .records_trace:        return self.createRecordsSection_Trace()
            case .categories_trace:     return self.createCategoriesSection_Trace()
            case .feed_trace:           return self.createFeedSection_Trace()
            }
        }
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
    
    private func createCategoriesSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(56)))
        let group_Trace = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(56)), subitems: [item_Trace])
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        return section_Trace
    }
    
    private func createFeedSection_Trace() -> NSCollectionLayoutSection {
        let itemSize_Trace = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(280))
        let item_Trace = NSCollectionLayoutItem(layoutSize: itemSize_Trace)
        item_Trace.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        let groupSize_Trace = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(280))
        let group_Trace = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize_Trace, subitems: [item_Trace, item_Trace])
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 14, bottom: 16, trailing: 14)
        section_Trace.interGroupSpacing = 12
        return section_Trace
    }
    
    // MARK: - 事件处理
    
    /// 发送时光记录
    @objc private func handleSend_Trace() {
        guard let text_Trace = inputField_Trace.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text_Trace.isEmpty else { return }
        
        inputField_Trace.text = ""
        inputField_Trace.resignFirstResponder()
        
        UserViewModel_Trace.shared_Trace.addTraceRecord_Trace(content_trace: text_Trace)
        
        let generator_Trace = UIImpactFeedbackGenerator(style: .medium)
        generator_Trace.impactOccurred()
        sendButton_Trace.animatePulse_Trace()
    }
    
    /// 点击空白区域收起键盘
    @objc private func handleViewTap_Trace() {
        inputField_Trace.resignFirstResponder()
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
    
    /// 分类选中处理
    private func selectCategory_Trace(at index_trace: Int) {
        let category_Trace = categories_Trace[index_trace]
        selectedCategory_Trace = (category_Trace == "All") ? nil : category_Trace
        
        let allPosts_Trace = TitleViewModel_Trace.shared_Trace.getPosts_Trace()
        if let category = selectedCategory_Trace {
            filteredPosts_Trace = allPosts_Trace.filter { $0.titleTag_Trace == category }
        } else {
            filteredPosts_Trace = allPosts_Trace
        }
        
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet(integer: HomeSectionType_Trace.feed_trace.rawValue))
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
        case .header_trace:         return 1
        case .banner_trace:         return 1
        case .timelineHeader_trace: return 1
        case .records_trace:        return max(1, currentPeriodRecords_Trace.count) // 最少1个（空状态）
        case .categories_trace:     return 1
        case .feed_trace:           return filteredPosts_Trace.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType_Trace = HomeSectionType_Trace(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType_Trace {
            
        case .header_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHeaderCell_Trace.reuseId_Trace, for: indexPath) as! HomeHeaderCell_Trace
            cell_Trace.onAvatarTapped_Trace = { Navigation_Trace.toMe_Trace() }
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
            
        case .categories_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCategoryContainerCell_Trace.reuseId_Trace, for: indexPath) as! HomeCategoryContainerCell_Trace
            cell_Trace.configure_Trace(categories_trace: categories_Trace, icons_trace: categoryIcons_Trace, selectedCategory_trace: selectedCategory_Trace)
            cell_Trace.onCategorySelected_Trace = { [weak self] index_trace in
                self?.selectCategory_Trace(at: index_trace)
                cell_Trace.updateSelectedIndex_Trace(index_trace)
            }
            return cell_Trace
            
        case .feed_trace:
            let cell_Trace = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFeedCell_Trace.reuseId_Trace, for: indexPath) as! HomeFeedCell_Trace
            let post_Trace = filteredPosts_Trace[indexPath.item]
            let isLiked_Trace = TitleViewModel_Trace.shared_Trace.isLikedPost_Trace(post_trace: post_Trace)
            cell_Trace.configure_Trace(post_trace: post_Trace, isLiked_trace: isLiked_Trace)
            cell_Trace.onLikeTapped_Trace = {
                TitleViewModel_Trace.shared_Trace.likePost_Trace(post_trace: post_Trace)
            }
            cell_Trace.onTapped_Trace = {
                Navigation_Trace.toTitleDetail_Trace(titleModel_trace: post_Trace)
            }
            // 入场动画（交错延迟）
            let delay_Trace = Double(indexPath.item % 6) * AnimationConfig_Trace.delayShort_Trace
            cell_Trace.contentView.alpha = 0
            cell_Trace.contentView.transform = CGAffineTransform(translationX: 0, y: 24)
            UIView.animate(withDuration: AnimationConfig_Trace.durationSpring_Trace, delay: delay_Trace, usingSpringWithDamping: AnimationConfig_Trace.springDampingNormal_Trace, initialSpringVelocity: AnimationConfig_Trace.springVelocity_Trace, options: [.curveEaseOut, .allowUserInteraction]) {
                cell_Trace.contentView.alpha = 1
                cell_Trace.contentView.transform = .identity
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

// MARK: - UITextFieldDelegate

extension Home_Trace: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Trace()
        return true
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

private class HomeBannerPageCell_Trace: FSPagerViewCell {
    
    static let reuseId_Trace = "HomeBannerPageCell_Trace"
    
    private let gradientLayer_Trace = CAGradientLayer()
    
    private let iconView_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        iv_Trace.contentMode = .scaleAspectFit
        iv_Trace.tintColor = UIColor.white.withAlphaComponent(0.85)
        return iv_Trace
    }()
    
    private let titleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl_Trace.textColor = .white
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()
    
    private let authorLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl_Trace.textColor = UIColor.white.withAlphaComponent(0.8)
        return lbl_Trace
    }()
    
    private let likeLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Trace.textColor = UIColor.white.withAlphaComponent(0.8)
        return lbl_Trace
    }()
    
    private static let tagGradientMap_Trace: [String: (String, String)] = [
        "Life": ("#B794F6", "#90CDF4"), "Moments": ("#FBB6CE", "#FED7AA"),
        "Night": ("#553C9A", "#6B46C1"), "Nature": ("#68D391", "#38B2AC"),
        "Memory": ("#F6AD55", "#ED8936"), "Stars": ("#F6E05E", "#ECC94B"),
        "Warmth": ("#FC8181", "#F6AD55"), "Friends": ("#76E4F7", "#4299E1")
    ]
    
    private static let tagIconMap_Trace: [String: String] = [
        "Life": "sun.max.fill", "Moments": "sparkles", "Night": "moon.stars.fill",
        "Nature": "leaf.fill", "Memory": "clock.fill", "Stars": "star.fill",
        "Warmth": "flame.fill", "Friends": "person.2.fill"
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.insertSublayer(gradientLayer_Trace, at: 0)
        contentView.addSubview(iconView_Trace)
        contentView.addSubview(titleLabel_Trace)
        contentView.addSubview(authorLabel_Trace)
        contentView.addSubview(likeLabel_Trace)
        
        iconView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(48)
        }
        titleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(iconView_Trace.snp.leading).offset(-8)
            make.bottom.equalTo(authorLabel_Trace.snp.top).offset(-8)
        }
        authorLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(likeLabel_Trace.snp.top).offset(-4)
        }
        likeLabel_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Trace.frame = contentView.bounds
    }
    
    func configure_Trace(post_trace: TitleModel_Trace) {
        let tag_Trace = post_trace.titleTag_Trace
        let colors_Trace = Self.tagGradientMap_Trace[tag_Trace] ?? ("#B794F6", "#90CDF4")
        gradientLayer_Trace.colors = [UIColor(hexstring_Trace: colors_Trace.0).cgColor, UIColor(hexstring_Trace: colors_Trace.1).cgColor]
        gradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        
        let iconName_Trace = Self.tagIconMap_Trace[tag_Trace] ?? "sparkles"
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        iconView_Trace.image = UIImage(systemName: iconName_Trace, withConfiguration: config_Trace)
        
        titleLabel_Trace.text = post_trace.title_Trace
        authorLabel_Trace.text = "by \(post_trace.titleUserName_Trace)"
        likeLabel_Trace.text = "♥ \(post_trace.likes_Trace) likes"
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

// MARK: - 首页分类 Tab Container Cell

private class HomeCategoryContainerCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "HomeCategoryContainerCell_Trace"
    
    private var categories_Trace: [String] = []
    private var icons_Trace: [String] = []
    private var selectedIndex_Trace: Int = 0
    private var tabButtons_Trace: [UIButton] = []
    var onCategorySelected_Trace: ((Int) -> Void)?
    
    private let scrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsHorizontalScrollIndicator = false
        sv_Trace.clipsToBounds = false
        return sv_Trace
    }()
    
    private let stackView_Trace: UIStackView = {
        let sv_Trace = UIStackView()
        sv_Trace.axis = .horizontal
        sv_Trace.spacing = 10
        sv_Trace.alignment = .center
        return sv_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(stackView_Trace)
        scrollView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        stackView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Trace(categories_trace: [String], icons_trace: [String], selectedCategory_trace: String?) {
        self.categories_Trace = categories_trace
        self.icons_Trace = icons_trace
        selectedIndex_Trace = selectedCategory_trace.flatMap { categories_trace.firstIndex(of: $0) } ?? 0
        buildButtons_Trace()
        updateButtonStates_Trace()
    }
    
    func updateSelectedIndex_Trace(_ index_trace: Int) {
        selectedIndex_Trace = index_trace
        updateButtonStates_Trace()
    }
    
    private func buildButtons_Trace() {
        stackView_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabButtons_Trace.removeAll()
        for (index_Trace, category_Trace) in categories_Trace.enumerated() {
            let btn_Trace = makeTabButton_Trace(title_trace: category_Trace, icon_trace: icons_Trace[index_Trace], index_trace: index_Trace)
            tabButtons_Trace.append(btn_Trace)
            stackView_Trace.addArrangedSubview(btn_Trace)
        }
    }
    
    private func makeTabButton_Trace(title_trace: String, icon_trace: String, index_trace: Int) -> UIButton {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.tag = index_trace
        btn_Trace.layer.cornerRadius = 18
        btn_Trace.layer.masksToBounds = true
        btn_Trace.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        btn_Trace.setImage(UIImage(systemName: icon_trace, withConfiguration: config_Trace), for: .normal)
        btn_Trace.setTitle("  \(title_trace)", for: .normal)
        btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Trace.addTarget(self, action: #selector(handleTabTap_Trace(_:)), for: .touchUpInside)
        btn_Trace.snp.makeConstraints { make in make.height.equalTo(36) }
        return btn_Trace
    }
    
    private func updateButtonStates_Trace() {
        for (index_Trace, btn_Trace) in tabButtons_Trace.enumerated() {
            btn_Trace.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            if index_Trace == selectedIndex_Trace {
                let grad_Trace = CAGradientLayer()
                grad_Trace.colors = [ColorConfig_Trace.primaryGradientStart_Trace.cgColor, ColorConfig_Trace.primaryGradientEnd_Trace.cgColor]
                grad_Trace.startPoint = CGPoint(x: 0, y: 0)
                grad_Trace.endPoint = CGPoint(x: 1, y: 1)
                grad_Trace.cornerRadius = 18
                btn_Trace.layer.insertSublayer(grad_Trace, at: 0)
                btn_Trace.setTitleColor(.white, for: .normal)
                btn_Trace.tintColor = .white
                btn_Trace.layer.borderWidth = 0
                DispatchQueue.main.async { grad_Trace.frame = btn_Trace.bounds }
            } else {
                btn_Trace.backgroundColor = .white
                btn_Trace.setTitleColor(ColorConfig_Trace.textSecondary_Trace, for: .normal)
                btn_Trace.tintColor = ColorConfig_Trace.textSecondary_Trace
                btn_Trace.layer.borderWidth = 1
                btn_Trace.layer.borderColor = ColorConfig_Trace.border_Trace.cgColor
            }
        }
    }
    
    @objc private func handleTabTap_Trace(_ sender: UIButton) {
        selectedIndex_Trace = sender.tag
        sender.animatePressDown_Trace { sender.animatePressUp_Trace() }
        updateButtonStates_Trace()
        onCategorySelected_Trace?(sender.tag)
    }
}

// MARK: - 首页 Feed Cell（帖子卡片包装）

private class HomeFeedCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "HomeFeedCell_Trace"
    
    private let postCard_Trace = TracePostCard_Trace(mode_trace: .grid_trace)
    var onLikeTapped_Trace: (() -> Void)?
    var onTapped_Trace: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(postCard_Trace)
        postCard_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        postCard_Trace.onLikeTapped_Trace = { [weak self] in self?.onLikeTapped_Trace?() }
        postCard_Trace.onTapped_Trace = { [weak self] in self?.onTapped_Trace?() }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Trace(post_trace: TitleModel_Trace, isLiked_trace: Bool) {
        postCard_Trace.configure_Trace(post_trace: post_trace, isLiked_trace: isLiked_trace)
    }
}
