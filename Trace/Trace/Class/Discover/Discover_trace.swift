import UIKit
import SnapKit

// MARK: - 发现页 Section 类型

/// 发现页集合视图分区枚举
private enum DiscoverSectionType_Trace: Int, CaseIterable {
    case search_trace     = 0
    case users_trace      = 1
    case challenges_trace = 2
    case categories_trace = 3   // 分类过滤选项卡（挑战区下方、帖子区上方）
    case community_trace  = 4
}

// MARK: - 发现页

/// 发现页视图控制器
/// 核心作用：「共鸣广场」—— 搜索帖子、浏览挑战、探索创作者与社区内容
/// 设计思路：UICollectionView Compositional Layout 四分区：搜索栏 / 创作者 / 挑战 / 社区帖子
/// 关键属性：filteredPosts_Trace（搜索过滤后帖子），searchText_Trace（搜索关键词）
class Discover_Trace: UIViewController {
    
    // MARK: - 常量

    /// 分类标签列表（All 表示不过滤）
    private let categories_Trace = ["All", "Life", "Moments", "Night", "Nature", "Memory", "Stars", "Warmth", "Friends"]

    /// 分类对应 SF Symbol 图标名
    private let categoryIcons_Trace = ["square.grid.2x2", "sun.max.fill", "sparkles",
                                       "moon.stars.fill", "leaf.fill", "clock.fill",
                                       "star.fill", "flame.fill", "person.2.fill"]

    // MARK: - 私有属性
    
    /// 当前搜索过滤后的帖子列表
    private var filteredPosts_Trace: [TitleModel_Trace] = []
    
    /// 搜索关键词
    private var searchText_Trace: String = ""

    /// 当前选中的分类（nil 表示 All，不过滤）
    private var selectedCategory_Trace: String? = nil
    
    /// 所有用户列表
    private var users_Trace: [PrewUserModel_Trace] = []

    /// 轻量挑战列表
    private var challenges_Trace: [ChallengeModel_Trace] = []
    
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
        cv_Trace.register(DiscoverSearchCell_Trace.self, forCellWithReuseIdentifier: DiscoverSearchCell_Trace.reuseId_Trace)
        cv_Trace.register(DiscoverUsersContainerCell_Trace.self, forCellWithReuseIdentifier: DiscoverUsersContainerCell_Trace.reuseId_Trace)
        cv_Trace.register(DiscoverChallengesContainerCell_Trace.self, forCellWithReuseIdentifier: DiscoverChallengesContainerCell_Trace.reuseId_Trace)
        cv_Trace.register(DiscoverCategoryContainerCell_Trace.self, forCellWithReuseIdentifier: DiscoverCategoryContainerCell_Trace.reuseId_Trace)
        cv_Trace.register(DiscoverPostCell_Trace.self, forCellWithReuseIdentifier: DiscoverPostCell_Trace.reuseId_Trace)
        cv_Trace.register(DiscoverEmptyCell_Trace.self, forCellWithReuseIdentifier: DiscoverEmptyCell_Trace.reuseId_Trace)
        return cv_Trace
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        subscribeNotifications_Trace()
        loadData_Trace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 统一使用 setNavigationBarHidden 维护 UINavigationController 内部状态
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - UI 配置
    
    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        view.addSubview(collectionView_Trace)
        collectionView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - 数据加载
    
    /// 初始化数据
    private func loadData_Trace() {
        users_Trace = LocalData_Trace.shared_Trace.userList_Trace
        challenges_Trace = LocalData_Trace.shared_Trace.challengeList_Trace
        applySearch_Trace()
    }
    
    /// 应用搜索关键词 + 分类双重过滤，更新 filteredPosts_Trace
    private func applySearch_Trace() {
        var posts_Trace = TitleViewModel_Trace.shared_Trace.getPosts_Trace()
        // 搜索关键词过滤（标题或内容包含关键词）
        if !searchText_Trace.isEmpty {
            let keyword_Trace = searchText_Trace.lowercased()
            posts_Trace = posts_Trace.filter {
                $0.title_Trace.lowercased().contains(keyword_Trace) ||
                $0.titleContent_Trace.lowercased().contains(keyword_Trace)
            }
        }
        // 分类标签过滤（nil 表示 All，不过滤）
        if let category_Trace = selectedCategory_Trace {
            posts_Trace = posts_Trace.filter { $0.titleTag_Trace == category_Trace }
        }
        filteredPosts_Trace = posts_Trace
    }

    /// 处理分类选中，更新过滤并刷新社区帖子分区
    /// - Parameter index_trace: 选中分类在 categories_Trace 中的下标
    private func selectCategory_Trace(at index_trace: Int) {
        let category_Trace = categories_Trace[index_trace]
        selectedCategory_Trace = (category_Trace == "All") ? nil : category_Trace
        applySearch_Trace()
        // 社区帖子布局受空状态影响需整体重建
        collectionView_Trace.collectionViewLayout.invalidateLayout()
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet(integer: DiscoverSectionType_Trace.community_trace.rawValue))
        }
    }
    
    // MARK: - 通知订阅
    
    private func subscribeNotifications_Trace() {
        // 帖子数据变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostsStateChange_Trace),
            name: TitleViewModel_Trace.titleStateDidChangeNotification_Trace,
            object: nil
        )
        // 用户状态变化（举报/拉黑后异步移除完成）→ 重载创作者列表
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Trace),
            name: UserViewModel_Trace.userStateDidChangeNotification_Trace,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Compositional Layout 构建
    
    /// 创建发现页 Compositional Layout
    private func createLayout_Trace() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex_trace, _ in
            guard let self = self,
                  let section_trace = DiscoverSectionType_Trace(rawValue: sectionIndex_trace) else {
                return nil
            }
            switch section_trace {
            case .search_trace:      return self.createSearchSection_Trace()
            case .users_trace:       return self.createUsersSection_Trace()
            case .challenges_trace:  return self.createChallengesSection_Trace()
            case .categories_trace:  return self.createCategoriesSection_Trace()
            case .community_trace:   return self.createCommunitySection_Trace()
            }
        }
    }
    
    /// 搜索栏分区（全宽，60pt）
    private func createSearchSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(60))
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(60)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        return section_Trace
    }
    
    /// 用户聚光灯分区（横向滚动，130pt，容纳双行用户名）
    private func createUsersSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(130))
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(130)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        return section_Trace
    }
    
    /// 轻量挑战分区（全宽容器，210pt）
    private func createChallengesSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(210))
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(210)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        return section_Trace
    }

    /// 分类选项卡分区（横向滚动，56pt 高，与首页一致）
    private func createCategoriesSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(56))
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(56)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        return section_Trace
    }

    /// 社区帖子分区（双列网格）
    private func createCommunitySection_Trace() -> NSCollectionLayoutSection {
        // 空状态时显示单列占满
        if filteredPosts_Trace.isEmpty {
            let item_Trace = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(120))
            )
            let group_Trace = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(120)),
                subitems: [item_Trace]
            )
            let section_Trace = NSCollectionLayoutSection(group: group_Trace)
            section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 20, bottom: 16, trailing: 20)
            return section_Trace
        }
        
        let itemSize_Trace = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                     heightDimension: .estimated(280))
        let item_Trace = NSCollectionLayoutItem(layoutSize: itemSize_Trace)
        item_Trace.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        
        let groupSize_Trace = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(280))
        let group_Trace = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize_Trace, subitems: [item_Trace, item_Trace])
        
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 14, bottom: 16, trailing: 14)
        section_Trace.interGroupSpacing = 12
        return section_Trace
    }
    
    // MARK: - 事件处理
    
    @objc private func handlePostsStateChange_Trace() {
        applySearch_Trace()
        collectionView_Trace.collectionViewLayout.invalidateLayout()
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet(integer: DiscoverSectionType_Trace.community_trace.rawValue))
        }
    }
    
    /// 用户状态变化（举报/拉黑后触发），从本地重新加载创作者列表并刷新对应分区
    @objc private func handleUserStateChange_Trace() {
        users_Trace = LocalData_Trace.shared_Trace.userList_Trace
        UIView.performWithoutAnimation {
            self.collectionView_Trace.reloadSections(IndexSet(integer: DiscoverSectionType_Trace.users_trace.rawValue))
        }
    }
    
    /// 搜索文字变化（与分类过滤同时生效）
    private func handleSearchChange_Trace(text_trace: String) {
        searchText_Trace = text_trace
        applySearch_Trace()
        // 社区内容需要重建布局（空/非空切换影响 section 布局）
        collectionView_Trace.collectionViewLayout.invalidateLayout()
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet(integer: DiscoverSectionType_Trace.community_trace.rawValue))
        }
    }
    
    /// 点击挑战卡片：跳转到挑战详情页
    /// - Parameter challenge_trace: 被点击的挑战模型
    private func handleChallengeTapped_Trace(challenge_trace: ChallengeModel_Trace) {
        Navigation_Trace.toChallengeDetail_Trace(challenge_trace: challenge_trace)
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Trace: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DiscoverSectionType_Trace.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType_Trace = DiscoverSectionType_Trace(rawValue: section) else { return 0 }
        switch sectionType_Trace {
        case .search_trace:      return 1
        case .users_trace:       return 1
        case .challenges_trace:  return 1
        case .categories_trace:  return 1
        case .community_trace:   return filteredPosts_Trace.isEmpty ? 1 : filteredPosts_Trace.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType_Trace = DiscoverSectionType_Trace(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType_Trace {
            
        case .search_trace:
            let cell_Trace = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiscoverSearchCell_Trace.reuseId_Trace, for: indexPath
            ) as! DiscoverSearchCell_Trace
            cell_Trace.onTextChanged_Trace = { [weak self] text_trace in
                self?.handleSearchChange_Trace(text_trace: text_trace)
            }
            return cell_Trace
            
        case .users_trace:
            let cell_Trace = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiscoverUsersContainerCell_Trace.reuseId_Trace, for: indexPath
            ) as! DiscoverUsersContainerCell_Trace
            cell_Trace.configure_Trace(users_trace: users_Trace)
            cell_Trace.onUserTapped_Trace = { user_trace in
                Navigation_Trace.toUserInfo_Trace(with: user_trace)
            }
            return cell_Trace
            
        case .challenges_trace:
            let cell_Trace = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiscoverChallengesContainerCell_Trace.reuseId_Trace, for: indexPath
            ) as! DiscoverChallengesContainerCell_Trace
            cell_Trace.configure_Trace(challenges_trace: challenges_Trace)
            cell_Trace.onChallengeTapped_Trace = { [weak self] challenge_trace in
                self?.handleChallengeTapped_Trace(challenge_trace: challenge_trace)
            }
            return cell_Trace

        case .categories_trace:
            let cell_Trace = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiscoverCategoryContainerCell_Trace.reuseId_Trace, for: indexPath
            ) as! DiscoverCategoryContainerCell_Trace
            cell_Trace.configure_Trace(
                categories_trace: categories_Trace,
                icons_trace: categoryIcons_Trace,
                selectedCategory_trace: selectedCategory_Trace
            )
            cell_Trace.onCategorySelected_Trace = { [weak self] index_trace in
                guard let self = self else { return }
                self.selectCategory_Trace(at: index_trace)
                cell_Trace.updateSelectedIndex_Trace(index_trace)
            }
            return cell_Trace

        case .community_trace:
            if filteredPosts_Trace.isEmpty {
                let cell_Trace = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DiscoverEmptyCell_Trace.reuseId_Trace, for: indexPath
                ) as! DiscoverEmptyCell_Trace
                return cell_Trace
            }
            
            let cell_Trace = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiscoverPostCell_Trace.reuseId_Trace, for: indexPath
            ) as! DiscoverPostCell_Trace
            let post_Trace = filteredPosts_Trace[indexPath.item]
            let isLiked_Trace = TitleViewModel_Trace.shared_Trace.isLikedPost_Trace(post_trace: post_Trace)
            cell_Trace.configure_Trace(post_trace: post_Trace, isLiked_trace: isLiked_Trace)
            cell_Trace.onLikeTapped_Trace = {
                TitleViewModel_Trace.shared_Trace.likePost_Trace(post_trace: post_Trace)
            }
            cell_Trace.onTapped_Trace = {
                Navigation_Trace.toTitleDetail_Trace(titleModel_trace: post_Trace)
            }
            // 举报/删除：由 VC 持有弱引用，通过 ReportDeleteHelper_Trace 弹出操作菜单
            cell_Trace.onReportTapped_Trace = { [weak self] post_trace in
                guard let self = self else { return }
                let isMyPost_trace = UserViewModel_Trace.shared_Trace.isCurrentUser_Trace(userId_trace: post_trace.titleUserId_Trace)
                if isMyPost_trace {
                    ReportDeleteHelper_Trace.delete_Trace(post_Trace: post_trace, from: self)
                } else {
                    ReportDeleteHelper_Trace.report_Trace(post_Trace: post_trace, from: self)
                }
            }
            // 入场淡入动画
            let delay_Trace = Double(indexPath.item % 6) * AnimationConfig_Trace.delayShort_Trace
            cell_Trace.contentView.alpha = 0
            UIView.animate(
                withDuration: AnimationConfig_Trace.durationNormal_Trace,
                delay: delay_Trace,
                options: [.curveEaseOut, .allowUserInteraction]
            ) {
                cell_Trace.contentView.alpha = 1
            }
            return cell_Trace
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Trace: UICollectionViewDelegate {}

// MARK: - 搜索栏 Cell

/// 发现页搜索栏 Cell
/// 功能：展示圆角搜索框，聚焦时显示渐变边框动画，输入时实时回调
private class DiscoverSearchCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "DiscoverSearchCell_Trace"
    
    var onTextChanged_Trace: ((String) -> Void)?
    
    private let containerView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 22
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_Trace.layer.shadowRadius = 8
        v_Trace.layer.shadowOpacity = 0.07
        return v_Trace
    }()
    
    private let searchIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv_Trace.image = UIImage(systemName: "magnifyingglass", withConfiguration: config_Trace)
        iv_Trace.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    private let searchField_Trace: UITextField = {
        let tf_Trace = UITextField()
        tf_Trace.placeholder = "Search traces..."
        tf_Trace.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        tf_Trace.returnKeyType = .search
        tf_Trace.clearButtonMode = .whileEditing
        return tf_Trace
    }()
    
    /// 聚焦状态渐变边框图层
    private let focusBorderLayer_Trace = CAGradientLayer()
    private let focusMaskLayer_Trace = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFocusBorder_Trace()
    }
    
    private func setupUI_Trace() {
        contentView.addSubview(containerView_Trace)
        containerView_Trace.addSubview(searchIcon_Trace)
        containerView_Trace.addSubview(searchField_Trace)
        
        containerView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        searchIcon_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        searchField_Trace.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Trace.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        searchField_Trace.addTarget(self, action: #selector(handleTextChange_Trace), for: .editingChanged)
        searchField_Trace.delegate = self
        
        // 聚焦边框渐变层（默认透明）
        focusBorderLayer_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        focusBorderLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        focusBorderLayer_Trace.endPoint = CGPoint(x: 1, y: 0)
        focusBorderLayer_Trace.opacity = 0
        containerView_Trace.layer.insertSublayer(focusBorderLayer_Trace, at: 0)
    }
    
    private func updateFocusBorder_Trace() {
        let bounds_Trace = containerView_Trace.bounds
        focusBorderLayer_Trace.frame = bounds_Trace
        let path_Trace = UIBezierPath(roundedRect: bounds_Trace, cornerRadius: 22)
        let innerPath_Trace = UIBezierPath(roundedRect: bounds_Trace.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 21)
        path_Trace.append(innerPath_Trace)
        path_Trace.usesEvenOddFillRule = true
        focusMaskLayer_Trace.path = path_Trace.cgPath
        focusMaskLayer_Trace.fillRule = .evenOdd
        focusBorderLayer_Trace.mask = focusMaskLayer_Trace
    }
    
    @objc private func handleTextChange_Trace() {
        onTextChanged_Trace?(searchField_Trace.text ?? "")
    }
}

extension DiscoverSearchCell_Trace: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 聚焦动画：渐变边框淡入
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationConfig_Trace.durationNormal_Trace)
        focusBorderLayer_Trace.opacity = 1
        CATransaction.commit()
        
        UIView.animate(withDuration: AnimationConfig_Trace.durationFast_Trace) {
            self.containerView_Trace.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        } completion: { _ in
            UIView.animate(withDuration: AnimationConfig_Trace.durationFast_Trace) {
                self.containerView_Trace.transform = .identity
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationConfig_Trace.durationNormal_Trace)
        focusBorderLayer_Trace.opacity = 0
        CATransaction.commit()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - 用户聚光灯 Container Cell

/// 发现页用户聚光灯横向滑动 Cell
/// 功能：横向展示所有用户头像+名称，点击跳转用户信息页
private class DiscoverUsersContainerCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "DiscoverUsersContainerCell_Trace"
    
    var onUserTapped_Trace: ((PrewUserModel_Trace) -> Void)?
    
    private let titleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Creators"
        lbl_Trace.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl_Trace
    }()
    
    private let scrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsHorizontalScrollIndicator = false
        sv_Trace.clipsToBounds = false
        return sv_Trace
    }()
    
    private let stackView_Trace: UIStackView = {
        let sv_Trace = UIStackView()
        sv_Trace.axis = .horizontal
        sv_Trace.spacing = 16
        sv_Trace.alignment = .top
        return sv_Trace
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel_Trace)
        contentView.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(stackView_Trace)
        
        titleLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        scrollView_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        stackView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    /// 配置用户列表
    func configure_Trace(users_trace: [PrewUserModel_Trace]) {
        stackView_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let loggedUserId_Trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace().userId_Trace ?? 0
        
        for user_Trace in users_trace {
            let card_Trace = makeUserCard_Trace(user_trace: user_Trace, isLoggedUser_trace: user_Trace.userId_Trace == loggedUserId_Trace)
            stackView_Trace.addArrangedSubview(card_Trace)
        }
    }
    
    /// 创建单个用户卡片视图
    /// - Parameters:
    ///   - user_trace: 用户数据模型
    ///   - isLoggedUser_trace: 是否为当前登录用户（显示渐变光环）
    private func makeUserCard_Trace(user_trace: PrewUserModel_Trace, isLoggedUser_trace: Bool) -> UIView {
        let container_Trace = UIView()
        container_Trace.isUserInteractionEnabled = true

        // 外圈容器（登录用户显示渐变光环）
        let avatarContainer_Trace = UIView()
        avatarContainer_Trace.layer.masksToBounds = false

        if isLoggedUser_trace {
            let ringLayer_Trace = CAGradientLayer()
            ringLayer_Trace.colors = [
                ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
                ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
            ]
            ringLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
            ringLayer_Trace.endPoint   = CGPoint(x: 1, y: 1)
            ringLayer_Trace.cornerRadius = 33
            ringLayer_Trace.frame = CGRect(x: -3, y: -3, width: 66, height: 66)
            avatarContainer_Trace.layer.insertSublayer(ringLayer_Trace, at: 0)
        }

        // 使用 UserAvatarView_Trace 替代手工 UIImageView，支持真实头像加载
        let avatarView_Trace = UserAvatarView_Trace()
        avatarView_Trace.configure_Trace(userId_Trace: user_trace.userId_Trace ?? 0)

        // 用户名（最多 2 行，防止截断）
        let nameLabel_Trace = UILabel()
        nameLabel_Trace.text = user_trace.userName_Trace ?? "User"
        nameLabel_Trace.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        nameLabel_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        nameLabel_Trace.textAlignment = .center
        nameLabel_Trace.numberOfLines = 2
        nameLabel_Trace.lineBreakMode = .byWordWrapping

        avatarContainer_Trace.addSubview(avatarView_Trace)
        container_Trace.addSubview(avatarContainer_Trace)
        container_Trace.addSubview(nameLabel_Trace)

        avatarContainer_Trace.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        // avatarView 铺满外圈容器
        avatarView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }
        // 名称标签横向撑满容器，最多双行显示，不再截断
        nameLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Trace.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(2)
            make.bottom.equalToSuperview()
        }
        container_Trace.snp.makeConstraints { make in
            make.width.equalTo(72)
        }

        let tap_Trace = UserCardTapRecognizer_Trace(target: self, action: #selector(handleUserTap_Trace(_:)))
        tap_Trace.user_Trace = user_trace
        container_Trace.addGestureRecognizer(tap_Trace)

        return container_Trace
    }
    
    @objc private func handleUserTap_Trace(_ gesture: UserCardTapRecognizer_Trace) {
        guard let user_Trace = gesture.user_Trace else { return }
        gesture.view?.animatePressDown_Trace {
            gesture.view?.animatePressUp_Trace()
        }
        onUserTapped_Trace?(user_Trace)
    }
}

// MARK: - 用户卡片点击识别器（携带用户数据）

/// 带用户数据的 UITapGestureRecognizer 子类
private class UserCardTapRecognizer_Trace: UITapGestureRecognizer {
    var user_Trace: PrewUserModel_Trace?
}

// MARK: - 社区帖子 Cell

/// 发现页社区帖子单元 Cell（包装 TracePostCard_Trace，右上角附加举报/删除按钮）
/// 核心作用：双列帖子卡片，支持点赞、跳转详情、举报/删除操作
/// 关键属性：onReportTapped_Trace（举报回调，传递当前帖子给外部 VC 处理）
private class DiscoverPostCell_Trace: UICollectionViewCell {

    static let reuseId_Trace = "DiscoverPostCell_Trace"

    private let postCard_Trace = TracePostCard_Trace(mode_trace: .grid_trace)

    /// 右上角举报/删除按钮（半透明圆形胶囊，叠于媒体区右上角）
    private let reportButton_Trace: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        return btn
    }()

    var onLikeTapped_Trace: (() -> Void)?
    var onTapped_Trace: (() -> Void)?
    /// 举报/删除回调（由 VC 负责调用 ReportDeleteHelper_Trace 弹出菜单）
    var onReportTapped_Trace: ((TitleModel_Trace) -> Void)?

    private var currentPost_Trace: TitleModel_Trace?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(postCard_Trace)
        contentView.addSubview(reportButton_Trace)

        postCard_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 举报按钮叠于卡片右上角，尺寸 24×24
        reportButton_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }

        postCard_Trace.onLikeTapped_Trace = { [weak self] in self?.onLikeTapped_Trace?() }
        postCard_Trace.onTapped_Trace = { [weak self] in self?.onTapped_Trace?() }
        reportButton_Trace.addTarget(self, action: #selector(handleReportTap_Trace), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置帖子数据并同步更新举报按钮图标
    func configure_Trace(post_trace: TitleModel_Trace, isLiked_trace: Bool) {
        currentPost_Trace = post_trace
        postCard_Trace.configure_Trace(post_trace: post_trace, isLiked_trace: isLiked_trace)
        // 自己的帖子显示删除图标，他人帖子显示举报图标
        let isMyPost_trace = UserViewModel_Trace.shared_Trace.isCurrentUser_Trace(userId_trace: post_trace.titleUserId_Trace)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        let iconName_trace = isMyPost_trace ? "trash" : "ellipsis"
        reportButton_Trace.setImage(UIImage(systemName: iconName_trace, withConfiguration: cfg), for: .normal)
    }

    /// 举报按钮点击，将帖子数据回传给 VC
    @objc private func handleReportTap_Trace() {
        guard let post_Trace = currentPost_Trace else { return }
        onReportTapped_Trace?(post_Trace)
    }
}

// MARK: - 空状态 Cell

/// 搜索/过滤结果为空时展示的提示 Cell
private class DiscoverEmptyCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "DiscoverEmptyCell_Trace"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let iconView_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iconView_Trace.image = UIImage(systemName: "magnifyingglass", withConfiguration: config_Trace)
        iconView_Trace.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        iconView_Trace.contentMode = .scaleAspectFit
        
        let label_Trace = UILabel()
        label_Trace.text = "No traces found"
        label_Trace.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label_Trace.textColor = ColorConfig_Trace.textPlaceholder_Trace
        label_Trace.textAlignment = .center
        
        contentView.addSubview(iconView_Trace)
        contentView.addSubview(label_Trace)
        
        iconView_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }
        label_Trace.snp.makeConstraints { make in
            make.top.equalTo(iconView_Trace.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 挑战 Container Cell

/// 发现页轻量挑战横向滑动容器 Cell
/// 核心作用：展示官方与用户发起的极简记录挑战卡片列表，支持横向滑动，点击「Join」参与挑战
/// 设计思路：每张卡片为渐变背景卡，顶部徽标区分官方/社区，突出表情+标题，底部展示参与人数与加入按钮
private class DiscoverChallengesContainerCell_Trace: UICollectionViewCell {

    static let reuseId_Trace = "DiscoverChallengesContainerCell_Trace"

    /// 点击挑战卡片（或 Join 按钮）回调，传递对应挑战模型
    var onChallengeTapped_Trace: ((ChallengeModel_Trace) -> Void)?

    private var challenges_Trace: [ChallengeModel_Trace] = []

    // MARK: - 区域标题行

    private let titleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Challenges"
        lbl_Trace.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl_Trace
    }()

    private let subtitleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Drop a trace, leave a mark"
        lbl_Trace.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl_Trace
    }()

    // MARK: - 横向滚动

    private let scrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsHorizontalScrollIndicator = false
        sv_Trace.clipsToBounds = false
        return sv_Trace
    }()

    private let stackView_Trace: UIStackView = {
        let sv_Trace = UIStackView()
        sv_Trace.axis = .horizontal
        sv_Trace.spacing = 14
        sv_Trace.alignment = .fill
        return sv_Trace
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildLayout_Trace()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - 布局搭建

    private func buildLayout_Trace() {
        contentView.addSubview(titleLabel_Trace)
        contentView.addSubview(subtitleLabel_Trace)
        contentView.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(stackView_Trace)

        titleLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        subtitleLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Trace)
            make.trailing.equalToSuperview().offset(-20)
        }
        scrollView_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        stackView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
    }

    // MARK: - 数据配置

    /// 传入挑战列表并重建卡片
    func configure_Trace(challenges_trace: [ChallengeModel_Trace]) {
        self.challenges_Trace = challenges_trace
        stackView_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for challenge_Trace in challenges_trace {
            let card_Trace = makeChallengeCard_Trace(challenge_trace: challenge_Trace)
            stackView_Trace.addArrangedSubview(card_Trace)
        }
    }

    // MARK: - 挑战卡片构建

    /// 构建单张挑战卡片
    /// - Parameter challenge_trace: 挑战数据
    /// - Returns: 完整卡片视图
    private func makeChallengeCard_Trace(challenge_trace: ChallengeModel_Trace) -> UIView {
        let cardWidth_Trace: CGFloat = 200
        let cardHeight_Trace: CGFloat = 162

        // 根容器
        let card_Trace = UIView()
        card_Trace.layer.cornerRadius = 18
        card_Trace.layer.masksToBounds = true
        card_Trace.snp.makeConstraints { make in
            make.width.equalTo(cardWidth_Trace)
            make.height.equalTo(cardHeight_Trace)
        }

        // 渐变背景层
        let gradLayer_Trace = CAGradientLayer()
        gradLayer_Trace.colors = [
            UIColor(hexstring_Trace: challenge_trace.gradientStart_Trace).cgColor,
            UIColor(hexstring_Trace: challenge_trace.gradientEnd_Trace).cgColor
        ]
        gradLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        gradLayer_Trace.frame = CGRect(x: 0, y: 0, width: cardWidth_Trace, height: cardHeight_Trace)
        card_Trace.layer.insertSublayer(gradLayer_Trace, at: 0)

        // 半透明噪点蒙版（增加质感）
        let overlayView_Trace = UIView()
        overlayView_Trace.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card_Trace.addSubview(overlayView_Trace)
        overlayView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 官方 / 社区徽标
        let badgeLabel_Trace = UILabel()
        let badgeText_Trace = challenge_trace.isOfficial_Trace ? "OFFICIAL" : "COMMUNITY"
        badgeLabel_Trace.text = badgeText_Trace
        badgeLabel_Trace.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        badgeLabel_Trace.textColor = .white
        badgeLabel_Trace.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        badgeLabel_Trace.layer.cornerRadius = 8
        badgeLabel_Trace.layer.masksToBounds = true
        badgeLabel_Trace.textAlignment = .center
        card_Trace.addSubview(badgeLabel_Trace)
        badgeLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.height.equalTo(18)
            make.width.equalTo(challenge_trace.isOfficial_Trace ? 58 : 76)
        }

        // 星形装饰（官方专属）
        if challenge_trace.isOfficial_Trace {
            let starIcon_Trace = UIImageView()
            let starCfg_Trace = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
            starIcon_Trace.image = UIImage(systemName: "star.fill", withConfiguration: starCfg_Trace)
            starIcon_Trace.tintColor = UIColor.white.withAlphaComponent(0.9)
            starIcon_Trace.contentMode = .scaleAspectFit
            card_Trace.addSubview(starIcon_Trace)
            starIcon_Trace.snp.makeConstraints { make in
                make.centerY.equalTo(badgeLabel_Trace)
                make.trailing.equalToSuperview().offset(-14)
                make.width.height.equalTo(14)
            }
        }

        // 表情 + 标题区
        let emojiLabel_Trace = UILabel()
        emojiLabel_Trace.text = challenge_trace.emoji_Trace
        emojiLabel_Trace.font = UIFont.systemFont(ofSize: 32)
        card_Trace.addSubview(emojiLabel_Trace)
        emojiLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(badgeLabel_Trace.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
        }

        let titleLabel_Trace = UILabel()
        titleLabel_Trace.text = challenge_trace.title_Trace
        titleLabel_Trace.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel_Trace.textColor = .white
        titleLabel_Trace.numberOfLines = 2
        card_Trace.addSubview(titleLabel_Trace)
        titleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel_Trace.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        let descLabel_Trace = UILabel()
        descLabel_Trace.text = challenge_trace.description_Trace
        descLabel_Trace.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        descLabel_Trace.textColor = UIColor.white.withAlphaComponent(0.75)
        descLabel_Trace.numberOfLines = 2
        card_Trace.addSubview(descLabel_Trace)
        descLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        // 底部：参与人数 + 「Join」按钮
        let participantIcon_Trace = UIImageView()
        let pCfg_Trace = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        participantIcon_Trace.image = UIImage(systemName: "person.2.fill", withConfiguration: pCfg_Trace)
        participantIcon_Trace.tintColor = UIColor.white.withAlphaComponent(0.8)
        participantIcon_Trace.contentMode = .scaleAspectFit
        card_Trace.addSubview(participantIcon_Trace)

        let countLabel_Trace = UILabel()
        countLabel_Trace.text = "\(challenge_trace.participants_Trace) joining"
        countLabel_Trace.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        countLabel_Trace.textColor = UIColor.white.withAlphaComponent(0.8)
        card_Trace.addSubview(countLabel_Trace)

        participantIcon_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(14)
        }
        countLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalTo(participantIcon_Trace)
            make.leading.equalTo(participantIcon_Trace.snp.trailing).offset(4)
        }

        let joinBtn_Trace = UIButton(type: .custom)
        joinBtn_Trace.setTitle("Join →", for: .normal)
        joinBtn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        joinBtn_Trace.setTitleColor(UIColor(hexstring_Trace: challenge_trace.gradientStart_Trace), for: .normal)
        joinBtn_Trace.backgroundColor = .white
        joinBtn_Trace.layer.cornerRadius = 12
        joinBtn_Trace.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        card_Trace.addSubview(joinBtn_Trace)
        joinBtn_Trace.snp.makeConstraints { make in
            make.centerY.equalTo(participantIcon_Trace)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(26)
        }

        // 「Join」点击事件（携带挑战模型）
        let recognizer_Trace = ChallengeTapRecognizer_Trace(target: self, action: #selector(handleJoinTap_Trace(_:)))
        recognizer_Trace.challenge_Trace = challenge_trace
        joinBtn_Trace.addGestureRecognizer(recognizer_Trace)

        // 卡片整体点击也触发
        let cardTap_Trace = ChallengeTapRecognizer_Trace(target: self, action: #selector(handleJoinTap_Trace(_:)))
        cardTap_Trace.challenge_Trace = challenge_trace
        card_Trace.addGestureRecognizer(cardTap_Trace)

        return card_Trace
    }

    // MARK: - 事件处理

    /// 处理「Join」点击，触发弹性缩放动画后回调
    @objc private func handleJoinTap_Trace(_ gesture: ChallengeTapRecognizer_Trace) {
        guard let challenge_Trace = gesture.challenge_Trace else { return }
        UIView.animate(
            withDuration: AnimationConfig_Trace.durationFast_Trace,
            animations: {
                gesture.view?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: { _ in
                UIView.animate(withDuration: AnimationConfig_Trace.durationFast_Trace) {
                    gesture.view?.transform = .identity
                }
                self.onChallengeTapped_Trace?(challenge_Trace)
            }
        )
        let generator_Trace = UIImpactFeedbackGenerator(style: .light)
        generator_Trace.impactOccurred()
    }
}

// MARK: - 挑战点击识别器（携带挑战数据）

/// 带挑战数据的 UITapGestureRecognizer 子类
private class ChallengeTapRecognizer_Trace: UITapGestureRecognizer {
    /// 关联的挑战模型
    var challenge_Trace: ChallengeModel_Trace?
}

// MARK: - 发现页分类选项卡 Cell

/// 发现页分类过滤选项卡 Cell
/// 核心作用：横向可滚动的分类胶囊选项卡，过滤社区帖子内容，与首页分类设计保持一致
/// 设计思路：UIScrollView + UIStackView 承载可变数量的胶囊按钮；选中态渐变填充，未选中态白色描边
/// 关键方法：configure_Trace（初始化按钮）、updateSelectedIndex_Trace（外部更新选中态）
private class DiscoverCategoryContainerCell_Trace: UICollectionViewCell {

    static let reuseId_Trace = "DiscoverCategoryContainerCell_Trace"

    // MARK: - 私有属性

    private var categories_Trace: [String] = []
    private var icons_Trace: [String] = []
    private var selectedIndex_Trace: Int = 0
    private var tabButtons_Trace: [UIButton] = []

    /// 分类选中回调，返回选中项下标
    var onCategorySelected_Trace: ((Int) -> Void)?

    // MARK: - UI 组件

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

    // MARK: - 初始化

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

    // MARK: - 公共方法

    /// 配置分类列表
    /// - Parameters:
    ///   - categories_trace: 分类标签数组
    ///   - icons_trace: 对应 SF Symbol 名数组
    ///   - selectedCategory_trace: 当前选中分类字符串（nil 表示 All）
    func configure_Trace(categories_trace: [String], icons_trace: [String], selectedCategory_trace: String?) {
        self.categories_Trace = categories_trace
        self.icons_Trace = icons_trace
        selectedIndex_Trace = selectedCategory_trace.flatMap { categories_trace.firstIndex(of: $0) } ?? 0
        buildButtons_Trace()
        updateButtonStates_Trace()
    }

    /// 外部更新选中下标（配合 onCategorySelected_Trace 回调使用）
    /// - Parameter index_trace: 新的选中下标
    func updateSelectedIndex_Trace(_ index_trace: Int) {
        selectedIndex_Trace = index_trace
        updateButtonStates_Trace()
    }

    // MARK: - 私有方法

    /// 根据 categories_Trace 重建所有胶囊按钮
    private func buildButtons_Trace() {
        stackView_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabButtons_Trace.removeAll()
        for (index_Trace, category_Trace) in categories_Trace.enumerated() {
            let btn_Trace = makeTabButton_Trace(
                title_trace: category_Trace,
                icon_trace: icons_Trace[index_Trace],
                index_trace: index_Trace
            )
            tabButtons_Trace.append(btn_Trace)
            stackView_Trace.addArrangedSubview(btn_Trace)
        }
    }

    /// 创建单个胶囊选项卡按钮
    /// - Parameters:
    ///   - title_trace: 显示标题
    ///   - icon_trace: SF Symbol 名称
    ///   - index_trace: 在列表中的下标（写入 tag 用于事件识别）
    /// - Returns: 配置好的 UIButton
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

    /// 刷新所有按钮的选中/未选中外观
    private func updateButtonStates_Trace() {
        for (index_Trace, btn_Trace) in tabButtons_Trace.enumerated() {
            // 移除旧的渐变层，避免重复叠加
            btn_Trace.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            if index_Trace == selectedIndex_Trace {
                // 选中态：渐变填充 + 白色文字
                let grad_Trace = CAGradientLayer()
                grad_Trace.colors = [
                    ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
                    ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
                ]
                grad_Trace.startPoint = CGPoint(x: 0, y: 0)
                grad_Trace.endPoint = CGPoint(x: 1, y: 1)
                grad_Trace.cornerRadius = 18
                btn_Trace.layer.insertSublayer(grad_Trace, at: 0)
                btn_Trace.setTitleColor(.white, for: .normal)
                btn_Trace.tintColor = .white
                btn_Trace.layer.borderWidth = 0
                // 延迟一帧确保 frame 已布局完成
                DispatchQueue.main.async { grad_Trace.frame = btn_Trace.bounds }
            } else {
                // 未选中态：白色背景 + 灰色描边
                btn_Trace.backgroundColor = .white
                btn_Trace.setTitleColor(ColorConfig_Trace.textSecondary_Trace, for: .normal)
                btn_Trace.tintColor = ColorConfig_Trace.textSecondary_Trace
                btn_Trace.layer.borderWidth = 1
                btn_Trace.layer.borderColor = ColorConfig_Trace.border_Trace.cgColor
            }
        }
    }

    // MARK: - 事件处理

    /// 胶囊按钮点击，触发弹性动画后回调选中下标
    @objc private func handleTabTap_Trace(_ sender: UIButton) {
        selectedIndex_Trace = sender.tag
        sender.animatePressDown_Trace { sender.animatePressUp_Trace() }
        updateButtonStates_Trace()
        onCategorySelected_Trace?(sender.tag)
    }
}
