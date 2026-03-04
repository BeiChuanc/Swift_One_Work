import UIKit
import SnapKit

// MARK: - 发现页 Section 类型

/// 发现页集合视图分区枚举
private enum DiscoverSectionType_Trace: Int, CaseIterable {
    case search_trace   = 0
    case users_trace    = 1
    case tags_trace     = 2
    case community_trace = 3
}

// MARK: - 发现页

/// 发现页视图控制器
/// 核心作用：「共鸣广场」—— 搜索帖子、标签过滤、浏览社区内容、探索创作者
/// 设计思路：UICollectionView Compositional Layout 四分区，实时搜索 + Tag 多选过滤
/// 关键属性：filteredPosts_Trace（过滤后帖子），searchText_Trace（搜索关键词），selectedTags_Trace（选中标签集合）
class Discover_Trace: UIViewController {
    
    // MARK: - 常量
    
    /// 所有可选标签
    private let allTags_Trace = ["Life", "Moments", "Night", "Nature", "Memory", "Stars", "Warmth", "Friends"]
    
    /// 标签对应渐变色（起始色, 结束色）
    private let tagGradients_Trace: [(String, String)] = [
        ("#B794F6", "#90CDF4"),
        ("#FBB6CE", "#FED7AA"),
        ("#553C9A", "#6B46C1"),
        ("#68D391", "#38B2AC"),
        ("#F6AD55", "#ED8936"),
        ("#F6E05E", "#ECC94B"),
        ("#FC8181", "#F6AD55"),
        ("#76E4F7", "#4299E1")
    ]
    
    // MARK: - 私有属性
    
    /// 当前过滤后的帖子列表
    private var filteredPosts_Trace: [TitleModel_Trace] = []
    
    /// 搜索关键词
    private var searchText_Trace: String = ""
    
    /// 当前选中的标签集合（空集合表示不过滤）
    private var selectedTags_Trace: Set<String> = []
    
    /// 所有用户列表
    private var users_Trace: [PrewUserModel_Trace] = []
    
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
        cv_Trace.register(DiscoverTagsContainerCell_Trace.self, forCellWithReuseIdentifier: DiscoverTagsContainerCell_Trace.reuseId_Trace)
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
        navigationController?.navigationBar.isHidden = true
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
        applyFilters_Trace()
    }
    
    /// 应用搜索和标签过滤，更新 filteredPosts_Trace
    private func applyFilters_Trace() {
        var posts_Trace = TitleViewModel_Trace.shared_Trace.getPosts_Trace()
        
        // 搜索过滤（标题或内容包含关键词）
        if !searchText_Trace.isEmpty {
            let keyword_Trace = searchText_Trace.lowercased()
            posts_Trace = posts_Trace.filter {
                $0.title_Trace.lowercased().contains(keyword_Trace) ||
                $0.titleContent_Trace.lowercased().contains(keyword_Trace)
            }
        }
        
        // 标签过滤（选中集合非空时过滤）
        if !selectedTags_Trace.isEmpty {
            posts_Trace = posts_Trace.filter { selectedTags_Trace.contains($0.titleTag_Trace) }
        }
        
        filteredPosts_Trace = posts_Trace
    }
    
    // MARK: - 通知订阅
    
    private func subscribeNotifications_Trace() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostsStateChange_Trace),
            name: TitleViewModel_Trace.titleStateDidChangeNotification_Trace,
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
            case .search_trace:    return self.createSearchSection_Trace()
            case .users_trace:     return self.createUsersSection_Trace()
            case .tags_trace:      return self.createTagsSection_Trace()
            case .community_trace: return self.createCommunitySection_Trace()
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
    
    /// 用户聚光灯分区（横向滚动，100pt）
    private func createUsersSection_Trace() -> NSCollectionLayoutSection {
        let item_Trace = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(100))
        )
        let group_Trace = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(100)),
            subitems: [item_Trace]
        )
        let section_Trace = NSCollectionLayoutSection(group: group_Trace)
        section_Trace.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
        return section_Trace
    }
    
    /// 标签分区（全宽，56pt）
    private func createTagsSection_Trace() -> NSCollectionLayoutSection {
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
        applyFilters_Trace()
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet(integer: DiscoverSectionType_Trace.community_trace.rawValue))
        }
    }
    
    /// 搜索文字变化
    private func handleSearchChange_Trace(text_trace: String) {
        searchText_Trace = text_trace
        applyFilters_Trace()
        // 社区内容需要重建布局（空/非空切换影响 section 布局）
        collectionView_Trace.collectionViewLayout.invalidateLayout()
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet(integer: DiscoverSectionType_Trace.community_trace.rawValue))
        }
    }
    
    /// 标签选中/取消
    private func handleTagToggle_Trace(tag_trace: String) {
        if selectedTags_Trace.contains(tag_trace) {
            selectedTags_Trace.remove(tag_trace)
        } else {
            selectedTags_Trace.insert(tag_trace)
        }
        applyFilters_Trace()
        collectionView_Trace.collectionViewLayout.invalidateLayout()
        UIView.performWithoutAnimation {
            collectionView_Trace.reloadSections(IndexSet(integer: DiscoverSectionType_Trace.community_trace.rawValue))
        }
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
        case .search_trace:    return 1
        case .users_trace:     return 1
        case .tags_trace:      return 1
        case .community_trace: return filteredPosts_Trace.isEmpty ? 1 : filteredPosts_Trace.count
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
            
        case .tags_trace:
            let cell_Trace = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiscoverTagsContainerCell_Trace.reuseId_Trace, for: indexPath
            ) as! DiscoverTagsContainerCell_Trace
            cell_Trace.configure_Trace(
                tags_trace: allTags_Trace,
                gradients_trace: tagGradients_Trace,
                selectedTags_trace: selectedTags_Trace
            )
            cell_Trace.onTagToggled_Trace = { [weak self] tag_trace in
                self?.handleTagToggle_Trace(tag_trace: tag_trace)
                cell_Trace.updateSelectedTags_Trace(self?.selectedTags_Trace ?? [])
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
    private func makeUserCard_Trace(user_trace: PrewUserModel_Trace, isLoggedUser_trace: Bool) -> UIView {
        let container_Trace = UIView()
        container_Trace.isUserInteractionEnabled = true
        
        // 头像圆圈
        let avatarContainer_Trace = UIView()
        avatarContainer_Trace.layer.cornerRadius = 30
        avatarContainer_Trace.layer.masksToBounds = false
        
        // 登录用户添加渐变光环
        if isLoggedUser_trace {
            let ringLayer_Trace = CAGradientLayer()
            ringLayer_Trace.colors = [
                ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
                ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
            ]
            ringLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
            ringLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
            ringLayer_Trace.cornerRadius = 33
            ringLayer_Trace.frame = CGRect(x: -3, y: -3, width: 66, height: 66)
            avatarContainer_Trace.layer.insertSublayer(ringLayer_Trace, at: 0)
        }
        
        let avatarIcon_Trace = UIImageView()
        avatarIcon_Trace.layer.cornerRadius = 28
        avatarIcon_Trace.layer.masksToBounds = true
        avatarIcon_Trace.contentMode = .scaleAspectFill
        
        let avatarColors_Trace = UserAvatarView_Trace.defaultAvatarColors_Trace
        let colorIndex_Trace = (user_trace.userId_Trace ?? 0) % avatarColors_Trace.count
        avatarIcon_Trace.backgroundColor = avatarColors_Trace[colorIndex_Trace].withAlphaComponent(0.15)
        
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 26, weight: .light)
        avatarIcon_Trace.image = UIImage(systemName: "person.circle.fill", withConfiguration: config_Trace)
        avatarIcon_Trace.tintColor = avatarColors_Trace[colorIndex_Trace]
        
        // 用户名
        let nameLabel_Trace = UILabel()
        nameLabel_Trace.text = user_trace.userName_Trace ?? "User"
        nameLabel_Trace.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        nameLabel_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        nameLabel_Trace.textAlignment = .center
        nameLabel_Trace.numberOfLines = 1
        
        avatarContainer_Trace.addSubview(avatarIcon_Trace)
        container_Trace.addSubview(avatarContainer_Trace)
        container_Trace.addSubview(nameLabel_Trace)
        
        avatarContainer_Trace.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        avatarIcon_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }
        nameLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Trace.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(70)
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

// MARK: - 标签 Container Cell

/// 发现页标签横向滑动 Cell
/// 功能：展示彩色标签 Pill，支持多选切换，选中状态渐变填充
private class DiscoverTagsContainerCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "DiscoverTagsContainerCell_Trace"
    
    var onTagToggled_Trace: ((String) -> Void)?
    
    private var tags_Trace: [String] = []
    private var gradients_Trace: [(String, String)] = []
    private var selectedTags_Trace: Set<String> = []
    private var tagButtons_Trace: [UIButton] = []
    private var tagGradientLayers_Trace: [CAGradientLayer] = []
    
    private let scrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsHorizontalScrollIndicator = false
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
        
        scrollView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    /// 配置标签列表
    func configure_Trace(tags_trace: [String], gradients_trace: [(String, String)], selectedTags_trace: Set<String>) {
        self.tags_Trace = tags_trace
        self.gradients_Trace = gradients_trace
        self.selectedTags_Trace = selectedTags_trace
        buildButtons_Trace()
    }
    
    /// 外部更新选中集合
    func updateSelectedTags_Trace(_ selected_trace: Set<String>) {
        selectedTags_Trace = selected_trace
        refreshButtonStates_Trace()
    }
    
    private func buildButtons_Trace() {
        stackView_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tagButtons_Trace.removeAll()
        tagGradientLayers_Trace.removeAll()
        
        for (index_Trace, tag_Trace) in tags_Trace.enumerated() {
            let gradPair_Trace = index_Trace < gradients_Trace.count ? gradients_Trace[index_Trace] : ("#B794F6", "#90CDF4")
            let (btn_Trace, grad_Trace) = makeTagButton_Trace(tag_trace: tag_Trace, gradPair_trace: gradPair_Trace)
            tagButtons_Trace.append(btn_Trace)
            tagGradientLayers_Trace.append(grad_Trace)
            stackView_Trace.addArrangedSubview(btn_Trace)
        }
        refreshButtonStates_Trace()
    }
    
    private func makeTagButton_Trace(tag_trace: String, gradPair_trace: (String, String)) -> (UIButton, CAGradientLayer) {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.setTitle(tag_trace, for: .normal)
        btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Trace.layer.cornerRadius = 16
        btn_Trace.layer.masksToBounds = true
        btn_Trace.contentEdgeInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
        
        let grad_Trace = CAGradientLayer()
        grad_Trace.colors = [
            UIColor(hexstring_Trace: gradPair_trace.0).cgColor,
            UIColor(hexstring_Trace: gradPair_trace.1).cgColor
        ]
        grad_Trace.startPoint = CGPoint(x: 0, y: 0)
        grad_Trace.endPoint = CGPoint(x: 1, y: 0)
        grad_Trace.cornerRadius = 16
        btn_Trace.layer.insertSublayer(grad_Trace, at: 0)
        
        btn_Trace.addTarget(self, action: #selector(handleTagTap_Trace(_:)), for: .touchUpInside)
        btn_Trace.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
        
        return (btn_Trace, grad_Trace)
    }
    
    private func refreshButtonStates_Trace() {
        for (index_Trace, btn_Trace) in tagButtons_Trace.enumerated() {
            let tag_Trace = tags_Trace[index_Trace]
            let isSelected_Trace = selectedTags_Trace.contains(tag_Trace)
            let grad_Trace = tagGradientLayers_Trace[index_Trace]
            
            DispatchQueue.main.async {
                grad_Trace.frame = btn_Trace.bounds
            }
            
            if isSelected_Trace {
                grad_Trace.opacity = 1
                btn_Trace.setTitleColor(.white, for: .normal)
                btn_Trace.layer.borderWidth = 0
            } else {
                grad_Trace.opacity = 0
                btn_Trace.backgroundColor = .white
                btn_Trace.setTitleColor(ColorConfig_Trace.textSecondary_Trace, for: .normal)
                btn_Trace.layer.borderWidth = 1
                let gradPair_Trace = index_Trace < gradients_Trace.count ? gradients_Trace[index_Trace] : ("#B794F6", "#90CDF4")
                btn_Trace.layer.borderColor = UIColor(hexstring_Trace: gradPair_Trace.0).cgColor
            }
        }
    }
    
    @objc private func handleTagTap_Trace(_ sender: UIButton) {
        guard let title_Trace = sender.title(for: .normal) else { return }
        sender.animatePulse_Trace()
        let generator_Trace = UIImpactFeedbackGenerator(style: .light)
        generator_Trace.impactOccurred()
        onTagToggled_Trace?(title_Trace)
    }
}

// MARK: - 社区帖子 Cell

/// 发现页社区帖子单元 Cell（包装 TracePostCard_Trace）
private class DiscoverPostCell_Trace: UICollectionViewCell {
    
    static let reuseId_Trace = "DiscoverPostCell_Trace"
    
    private let postCard_Trace = TracePostCard_Trace(mode_trace: .grid_trace)
    
    var onLikeTapped_Trace: (() -> Void)?
    var onTapped_Trace: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(postCard_Trace)
        postCard_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        postCard_Trace.onLikeTapped_Trace = { [weak self] in
            self?.onLikeTapped_Trace?()
        }
        postCard_Trace.onTapped_Trace = { [weak self] in
            self?.onTapped_Trace?()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Trace(post_trace: TitleModel_Trace, isLiked_trace: Bool) {
        postCard_Trace.configure_Trace(post_trace: post_trace, isLiked_trace: isLiked_trace)
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
