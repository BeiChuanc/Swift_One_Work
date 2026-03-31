import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页视图控制器
/// 核心作用：提供搜索、热门话题标签和热门帖子双列网格，形成完整发现闭环。
/// 设计思路：渐变装饰顶栏 + 搜索栏点击展开动画 + 话题标签流式布局 + 媒体网格帖子。
/// 关键方法：enterSearchMode_Flick（激活搜索）、exitSearchMode_Flick（退出搜索）
class Discover_Flick: UIViewController {
    
    // MARK: - 数据
    
    /// 热门帖子列表（用于网格）
    private var hotPosts_Flick: [TitleModel_Flick] = []
    
    /// 搜索结果帖子列表
    private var searchResults_Flick: [TitleModel_Flick] = []
    
    /// 是否处于搜索模式
    private var isSearching_Flick: Bool = false
    
    /// 热门话题标签
    private let topicTags_Flick = [
        "#Bonfire", "#Night", "#Art", "#Life", "#Nature",
        "#Stories", "#Fire", "#Friends", "#Memory", "#Glow"
    ]
    
    // MARK: - 顶栏 UI（渐变装饰设计）
    
    /// 顶栏背景（渐变紫→蓝）
    private let topBarView_Flick: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()
    
    private var topBarGradientLayer_Flick: CAGradientLayer?
    
    /// 左上装饰大圆（半透明）
    private let decorCircle1_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        v.isUserInteractionEnabled = false
        return v
    }()
    
    /// 右上装饰圆（半透明）
    private let decorCircle2_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        v.isUserInteractionEnabled = false
        return v
    }()
    
    /// 右上装饰图标一
    private let decorSparkle1_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = UIColor.white.withValues(alpha: 0.25)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    /// 右上装饰图标二
    private let decorSparkle2_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor.white.withValues(alpha: 0.15)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    /// 页面主标题
    private let titleLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Discover Ideas"
        l.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        l.textColor = .white
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOffset = CGSize(width: 0, height: 1)
        l.layer.shadowRadius = 4
        l.layer.shadowOpacity = 0.15
        return l
    }()
    
    /// 副标题
    private let subtitleLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "✦  Where your curiosity leads you"
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withValues(alpha: 0.8)
        return l
    }()
    
    /// 统计 Pill 容器
    private let pillStackView_Flick: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()
    
    // MARK: - 搜索栏 UI
    
    /// 搜索栏容器（悬浮在顶栏底部，视觉上跨越顶栏与内容区）
    private let searchBarContainer_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.12
        return v
    }()
    
    /// 搜索图标
    private let searchIcon_Flick: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass")
        iv.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 搜索输入框
    private let searchField_Flick: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search ideas, people..."
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = ColorConfig_Flick.textPrimary_Flick
        tf.returnKeyType = .search
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    /// 取消搜索按钮
    private let cancelSearchButton_Flick: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Cancel", for: .normal)
        b.setTitleColor(ColorConfig_Flick.primaryGradientStart_Flick, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        b.alpha = 0
        b.isHidden = true
        return b
    }()
    
    // MARK: - 主内容区 UI
    
    /// 主滚动容器（非搜索态）
    private let scrollView_Flick: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        return sv
    }()
    
    private let contentStack_Flick: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()
    
    // - 话题区
    private let topicTagsView_Flick = TopicTagsFlowView_Flick()
    
    // - 热门帖子区
    private let postCollectionView_Flick: UICollectionView = {
        let layout_Flick = UICollectionViewFlowLayout()
        layout_Flick.scrollDirection = .vertical
        layout_Flick.minimumInteritemSpacing = 12
        layout_Flick.minimumLineSpacing = 12
        layout_Flick.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout_Flick)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()
    
    // MARK: - 搜索结果区 UI
    
    private let searchResultTableView_Flick: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        tv.showsVerticalScrollIndicator = false
        tv.alpha = 0
        tv.isHidden = true
        tv.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 20, right: 0)
        return tv
    }()
    
    /// 搜索无结果视图
    private let noResultView_Flick: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()
    
    private let noResultIcon_Flick: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "doc.text.magnifyingglass")
        iv.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let noResultLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "No ideas found"
        l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = ColorConfig_Flick.textPlaceholder_Flick
        l.textAlignment = .center
        return l
    }()
    
    // MARK: - 搜索栏约束引用
    
    private var searchContainerRightConstraint_Flick: Constraint?
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData_Flick()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        setupCollectionView_Flick()
        setupSearchResultTable_Flick()
        bindNotifications_Flick()
        loadData_Flick()
        animateEntrance_Flick()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBarGradientLayer_Flick?.frame = topBarView_Flick.bounds
        decorCircle1_Flick.layer.cornerRadius = decorCircle1_Flick.bounds.width / 2
        decorCircle2_Flick.layer.cornerRadius = decorCircle2_Flick.bounds.width / 2
        updatePostCollectionHeight_Flick()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        
        setupTopBar_Flick()
        setupSearchBar_Flick()
        setupScrollContent_Flick()
        setupSearchResultViews_Flick()
    }
    
    // MARK: 顶栏搭建（渐变装饰设计）
    
    /// 搭建渐变顶栏及所有装饰元素
    private func setupTopBar_Flick() {
        view.addSubview(topBarView_Flick)
        topBarView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(safeAreaTopHeight_Flick() + 152)
        }
        
        // 渐变图层
        let grad_Flick = CAGradientLayer()
        grad_Flick.colors = [
            UIColor(hexstring_Flick: "#9B72E8").cgColor,
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        grad_Flick.locations = [0, 0.5, 1]
        grad_Flick.startPoint = CGPoint(x: 0, y: 0)
        grad_Flick.endPoint = CGPoint(x: 1, y: 1)
        topBarView_Flick.layer.addSublayer(grad_Flick)
        topBarGradientLayer_Flick = grad_Flick
        
        // 底部圆角（仅左右下角）
        topBarView_Flick.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topBarView_Flick.layer.cornerRadius = 28
        
        // 装饰大圆 1（左上，背景圆斑）
        topBarView_Flick.addSubview(decorCircle1_Flick)
        decorCircle1_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.left.equalToSuperview().offset(-30)
            make.width.height.equalTo(140)
        }
        
        // 装饰大圆 2（右上）
        topBarView_Flick.addSubview(decorCircle2_Flick)
        decorCircle2_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(20)
            make.width.height.equalTo(100)
        }
        
        // 装饰 Sparkles 图标 1（右上）
        topBarView_Flick.addSubview(decorSparkle1_Flick)
        decorSparkle1_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaTopHeight_Flick() + 8)
            make.right.equalToSuperview().offset(-18)
            make.width.height.equalTo(28)
        }
        
        // 装饰图标 2（右上偏下）
        topBarView_Flick.addSubview(decorSparkle2_Flick)
        decorSparkle2_Flick.snp.makeConstraints { make in
            make.top.equalTo(decorSparkle1_Flick.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-36)
            make.width.height.equalTo(16)
        }
        
        // 主标题
        topBarView_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaTopHeight_Flick() + 14)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualTo(decorSparkle1_Flick.snp.left).offset(-10)
        }
        
        // 副标题
        topBarView_Flick.addSubview(subtitleLabel_Flick)
        subtitleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Flick.snp.bottom).offset(4)
            make.left.equalTo(titleLabel_Flick)
        }
        
        // 统计 Pill 行
        topBarView_Flick.addSubview(pillStackView_Flick)
        pillStackView_Flick.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Flick.snp.bottom).offset(12)
            make.left.equalTo(titleLabel_Flick)
        }
        
        // 添加两个 pill 标签
        let ideaPill_Flick = makeStatPill_Flick(icon_Flick: "lightbulb.fill", text_Flick: "Ideas")
        let trendPill_Flick = makeStatPill_Flick(icon_Flick: "flame.fill", text_Flick: "Trending Now")
        pillStackView_Flick.addArrangedSubview(ideaPill_Flick)
        pillStackView_Flick.addArrangedSubview(trendPill_Flick)
    }
    
    /// 创建统计 Pill 标签
    /// - Parameters:
    ///   - icon_Flick: SF Symbol 图标名
    ///   - text_Flick: 显示文字
    /// - Returns: 配置好的 UIView Pill
    private func makeStatPill_Flick(icon_Flick: String, text_Flick: String) -> UIView {
        let pill_Flick = UIView()
        pill_Flick.backgroundColor = UIColor.white.withValues(alpha: 0.18)
        pill_Flick.layer.cornerRadius = 12
        pill_Flick.layer.borderWidth = 1
        pill_Flick.layer.borderColor = UIColor.white.withValues(alpha: 0.25).cgColor
        
        let iconIV_Flick = UIImageView(image: UIImage(systemName: icon_Flick))
        iconIV_Flick.tintColor = .white
        iconIV_Flick.contentMode = .scaleAspectFit
        
        let label_Flick = UILabel()
        label_Flick.text = text_Flick
        label_Flick.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_Flick.textColor = .white
        
        let stack_Flick = UIStackView(arrangedSubviews: [iconIV_Flick, label_Flick])
        stack_Flick.axis = .horizontal
        stack_Flick.spacing = 4
        stack_Flick.alignment = .center
        
        pill_Flick.addSubview(stack_Flick)
        stack_Flick.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.left.right.equalToSuperview().inset(10)
        }
        iconIV_Flick.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
        
        return pill_Flick
    }
    
    // MARK: 搜索栏搭建（悬浮样式）
    
    /// 搭建悬浮搜索栏（视觉上跨越顶栏底边）
    private func setupSearchBar_Flick() {
        view.addSubview(cancelSearchButton_Flick)
        view.addSubview(searchBarContainer_Flick)
        
        searchBarContainer_Flick.snp.makeConstraints { make in
            make.top.equalTo(topBarView_Flick.snp.bottom).offset(-22)
            make.left.equalToSuperview().offset(16)
            searchContainerRightConstraint_Flick = make.right.equalToSuperview().offset(-16).constraint
            make.height.equalTo(44)
        }
        
        cancelSearchButton_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(searchBarContainer_Flick)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(56)
        }
        
        searchBarContainer_Flick.addSubview(searchIcon_Flick)
        searchIcon_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        searchBarContainer_Flick.addSubview(searchField_Flick)
        searchField_Flick.snp.makeConstraints { make in
            make.left.equalTo(searchIcon_Flick.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        searchField_Flick.delegate = self
        searchField_Flick.addTarget(self, action: #selector(handleSearchTextChange_Flick), for: .editingChanged)
        
        let tapSearch_Flick = UITapGestureRecognizer(target: self, action: #selector(handleSearchBarTap_Flick))
        searchBarContainer_Flick.addGestureRecognizer(tapSearch_Flick)
        cancelSearchButton_Flick.addTarget(self, action: #selector(handleCancelSearch_Flick), for: .touchUpInside)
    }
    
    // MARK: 主内容区搭建
    
    /// 搭建主滚动视图及各内容区
    private func setupScrollContent_Flick() {
        view.addSubview(scrollView_Flick)
        scrollView_Flick.snp.makeConstraints { make in
            make.top.equalTo(searchBarContainer_Flick.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
        
        scrollView_Flick.addSubview(contentStack_Flick)
        contentStack_Flick.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(scrollView_Flick)
        }
        
        buildTopicSection_Flick()
        buildHotPostsSection_Flick()
    }
    
    /// 搭建话题区（标题 + 流式标签）
    private func buildTopicSection_Flick() {
        let sectionLabel_Flick = makeSectionTitle_Flick(text_Flick: "🔥 Trending Topics")
        
        let topicWrapper_Flick = UIView()
        topicWrapper_Flick.backgroundColor = .clear
        
        topicWrapper_Flick.addSubview(sectionLabel_Flick)
        sectionLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        topicWrapper_Flick.addSubview(topicTagsView_Flick)
        topicTagsView_Flick.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_Flick.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        topicTagsView_Flick.tags_Flick = topicTags_Flick
        topicTagsView_Flick.onTagTapped_Flick = { [weak self] tag_Flick in
            self?.handleTopicTap_Flick(topic_Flick: tag_Flick)
        }
        
        contentStack_Flick.addArrangedSubview(topicWrapper_Flick)
        
        // 分割线
        let divider_Flick = UIView()
        divider_Flick.backgroundColor = ColorConfig_Flick.divider_Flick
        divider_Flick.snp.makeConstraints { make in make.height.equalTo(0.5) }
        contentStack_Flick.addArrangedSubview(divider_Flick)
    }
    
    /// 搭建热门帖子区（标题 + 双列网格）
    private func buildHotPostsSection_Flick() {
        let sectionLabel_Flick = makeSectionTitle_Flick(text_Flick: "📌 Popular Ideas")
        
        let hotWrapper_Flick = UIView()
        hotWrapper_Flick.backgroundColor = .clear
        
        hotWrapper_Flick.addSubview(sectionLabel_Flick)
        sectionLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        hotWrapper_Flick.addSubview(postCollectionView_Flick)
        postCollectionView_Flick.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_Flick.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(400)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        contentStack_Flick.addArrangedSubview(hotWrapper_Flick)
    }
    
    /// 配置热门帖子 CollectionView
    private func setupCollectionView_Flick() {
        postCollectionView_Flick.delegate = self
        postCollectionView_Flick.dataSource = self
        postCollectionView_Flick.register(
            PostGridCell_Flick.self,
            forCellWithReuseIdentifier: PostGridCell_Flick.reuseId_Flick
        )
    }
    
    /// 配置搜索结果 TableView 及无结果视图
    private func setupSearchResultViews_Flick() {
        view.addSubview(searchResultTableView_Flick)
        searchResultTableView_Flick.snp.makeConstraints { make in
            make.top.equalTo(searchBarContainer_Flick.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        
        view.addSubview(noResultView_Flick)
        noResultView_Flick.snp.makeConstraints { make in
            make.center.equalTo(searchResultTableView_Flick)
            make.width.equalTo(200)
        }
        
        noResultView_Flick.addSubview(noResultIcon_Flick)
        noResultIcon_Flick.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        noResultView_Flick.addSubview(noResultLabel_Flick)
        noResultLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(noResultIcon_Flick.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
        
        setupSearchResultTable_Flick()
    }
    
    /// 配置搜索结果 TableView delegate/dataSource
    private func setupSearchResultTable_Flick() {
        searchResultTableView_Flick.delegate = self
        searchResultTableView_Flick.dataSource = self
        searchResultTableView_Flick.register(
            PostCardCell_Flick.self,
            forCellReuseIdentifier: PostCardCell_Flick.reuseId_Flick
        )
    }
    
    // MARK: - 数据加载
    
    /// 加载热门帖子数据并刷新网格
    /// 加载热门帖并合并当前登录用户发布的帖子（避免「我的帖子」因点赞数未进前十而不展示）
    private func loadData_Flick() {
        var merged_flick = TitleViewModel_Flick.shared_Flick.getHotPosts_Flick(count_flick: 10)
        let myId_flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick().userId_Flick ?? 0
        if myId_flick > 0 {
            let mine_flick = TitleViewModel_Flick.shared_Flick.getPosts_Flick().filter { $0.titleUserId_Flick == myId_flick }
            for p_flick in mine_flick where !merged_flick.contains(where: { $0.titleId_Flick == p_flick.titleId_Flick }) {
                merged_flick.insert(p_flick, at: 0)
            }
        }
        hotPosts_Flick = merged_flick
        postCollectionView_Flick.reloadData()
        updatePostCollectionHeight_Flick()
    }
    
    /// 动态更新热门帖子 CollectionView 的高度约束（双列瀑布流）
    private func updatePostCollectionHeight_Flick() {
        let itemWidth_Flick = (APPSCREEN_Flick.WIDTH_Flick - 32 - 12) / 2
        let itemHeight_Flick: CGFloat = itemWidth_Flick * 1.35
        let rows_Flick = ceil(Double(hotPosts_Flick.count) / 2.0)
        let totalHeight_Flick = CGFloat(rows_Flick) * (itemHeight_Flick + 12) + 16
        
        if let layout_Flick = postCollectionView_Flick.collectionViewLayout as? UICollectionViewFlowLayout {
            layout_Flick.itemSize = CGSize(width: itemWidth_Flick, height: itemHeight_Flick)
        }
        
        postCollectionView_Flick.snp.updateConstraints { make in
            make.height.equalTo(totalHeight_Flick)
        }
    }
    
    // MARK: - 通知监听
    
    private func bindNotifications_Flick() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Flick),
            name: TitleViewModel_Flick.titleStateDidChangeNotification_Flick,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Flick),
            name: UserViewModel_Flick.userStateDidChangeNotification_Flick,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 搜索模式切换
    
    /// 进入搜索模式（搜索栏展开 + 主内容淡出 + 结果区淡入）
    private func enterSearchMode_Flick() {
        guard !isSearching_Flick else { return }
        isSearching_Flick = true
        
        searchContainerRightConstraint_Flick?.update(offset: -80)
        cancelSearchButton_Flick.isHidden = false
        
        UIView.animate(
            withDuration: AnimationConfig_Flick.durationNormal_Flick,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingLight_Flick,
            initialSpringVelocity: AnimationConfig_Flick.springVelocity_Flick,
            options: [.curveEaseOut],
            animations: {
                self.view.layoutIfNeeded()
                self.cancelSearchButton_Flick.alpha = 1
                self.searchBarContainer_Flick.layer.shadowOpacity = 0.2
                self.searchIcon_Flick.tintColor = ColorConfig_Flick.primaryGradientStart_Flick
                self.scrollView_Flick.alpha = 0
            }
        )
        
        searchResultTableView_Flick.isHidden = false
        searchResultTableView_Flick.animateFadeIn_Flick(delay_Flick: 0.1)
    }
    
    /// 退出搜索模式（收起搜索栏 + 清空搜索内容）
    private func exitSearchMode_Flick() {
        guard isSearching_Flick else { return }
        isSearching_Flick = false
        searchField_Flick.text = nil
        searchField_Flick.resignFirstResponder()
        searchResults_Flick = []
        noResultView_Flick.isHidden = true
        
        searchContainerRightConstraint_Flick?.update(offset: -16)
        
        UIView.animate(
            withDuration: AnimationConfig_Flick.durationNormal_Flick,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingLight_Flick,
            initialSpringVelocity: AnimationConfig_Flick.springVelocity_Flick,
            options: [.curveEaseOut],
            animations: {
                self.view.layoutIfNeeded()
                self.cancelSearchButton_Flick.alpha = 0
                self.searchBarContainer_Flick.layer.shadowOpacity = 0.12
                self.searchIcon_Flick.tintColor = ColorConfig_Flick.textPlaceholder_Flick
                self.scrollView_Flick.alpha = 1
            },
            completion: { _ in
                self.cancelSearchButton_Flick.isHidden = true
                self.searchResultTableView_Flick.isHidden = true
                self.searchResultTableView_Flick.alpha = 0
            }
        )
    }
    
    // MARK: - 进场动画
    
    /// 页面进场动画：顶栏弹入 + 搜索栏 + 内容依次淡入
    private func animateEntrance_Flick() {
        topBarView_Flick.transform = CGAffineTransform(translationX: 0, y: -50)
        topBarView_Flick.alpha = 0
        searchBarContainer_Flick.alpha = 0
        scrollView_Flick.alpha = 0
        
        UIView.animate(
            withDuration: AnimationConfig_Flick.durationSpring_Flick,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingNormal_Flick,
            initialSpringVelocity: AnimationConfig_Flick.springVelocity_Flick,
            options: [.curveEaseOut],
            animations: {
                self.topBarView_Flick.transform = .identity
                self.topBarView_Flick.alpha = 1
            }
        )
        
        searchBarContainer_Flick.animateSlideInFromBottom_Flick(offset_Flick: 20, delay_Flick: 0.2)
        scrollView_Flick.animateFadeIn_Flick(delay_Flick: 0.3)
        
        // Pill 装饰弹入
        pillStackView_Flick.arrangedSubviews.enumerated().forEach { (i, v) in
            v.alpha = 0
            v.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(
                withDuration: AnimationConfig_Flick.durationSpring_Flick,
                delay: 0.25 + TimeInterval(i) * 0.08,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    v.alpha = 1
                    v.transform = .identity
                }
            )
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func handleSearchBarTap_Flick() {
        searchField_Flick.becomeFirstResponder()
        enterSearchMode_Flick()
    }
    
    @objc private func handleCancelSearch_Flick() {
        exitSearchMode_Flick()
    }
    
    /// 搜索文本实时变化 → 搜索帖子
    @objc private func handleSearchTextChange_Flick() {
        let keyword_Flick = searchField_Flick.text ?? ""
        
        if keyword_Flick.trimmingCharacters(in: .whitespaces).isEmpty {
            searchResults_Flick = []
            noResultView_Flick.isHidden = true
            searchResultTableView_Flick.reloadData()
            return
        }
        
        searchResults_Flick = TitleViewModel_Flick.shared_Flick.searchPosts_Flick(keyword_flick: keyword_Flick)
        
        let hasResults_Flick = !searchResults_Flick.isEmpty
        noResultView_Flick.isHidden = hasResults_Flick
        searchResultTableView_Flick.reloadData()
        
        if hasResults_Flick {
            searchResultTableView_Flick.visibleCells.enumerated().forEach { (i, cell) in
                cell.animateSlideInFromBottom_Flick(
                    offset_Flick: 20,
                    delay_Flick: TimeInterval(i) * AnimationConfig_Flick.delayShort_Flick
                )
            }
        }
    }
    
    /// 话题标签点击 → 自动触发关键词搜索
    private func handleTopicTap_Flick(topic_Flick: String) {
        let keyword_Flick = topic_Flick.replacingOccurrences(of: "#", with: "")
        searchField_Flick.text = keyword_Flick
        enterSearchMode_Flick()
        searchField_Flick.becomeFirstResponder()
        
        searchResults_Flick = TitleViewModel_Flick.shared_Flick.searchPosts_Flick(keyword_flick: keyword_Flick)
        let hasResults_Flick = !searchResults_Flick.isEmpty
        noResultView_Flick.isHidden = hasResults_Flick
        searchResultTableView_Flick.reloadData()
        searchResultTableView_Flick.isHidden = false
        searchResultTableView_Flick.alpha = 1
    }
    
    /// 帖子操作按钮点击处理（删除/举报）
    /// - Parameter post_flick: 目标帖子
    private func handlePostAction_Flick(post_flick: TitleModel_Flick) {
        let isMyPost_Flick = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(
            userId_flick: post_flick.titleUserId_Flick
        )
        if isMyPost_Flick {
            ReportDeleteHelper_Flick.delete_Flick(post_Flick: post_flick, from: self) { [weak self] in
                self?.loadData_Flick()
            }
        } else {
            ReportDeleteHelper_Flick.report_Flick(post_Flick: post_flick, from: self) { [weak self] in
                self?.loadData_Flick()
            }
        }
    }
    
    @objc private func handleStateChange_Flick() {
        loadData_Flick()
        if isSearching_Flick {
            handleSearchTextChange_Flick()
        }
    }
    
    // MARK: - 工具方法
    
    /// 获取安全区域顶部高度
    private func safeAreaTopHeight_Flick() -> CGFloat {
        if #available(iOS 15.0, *) {
            return view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 44
        }
        return UIApplication.shared.statusBarFrame.height
    }
    
    /// 创建区域标题 Label
    private func makeSectionTitle_Flick(text_Flick: String) -> UILabel {
        let l = UILabel()
        l.text = text_Flick
        l.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        return l
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource（热门帖子网格）

extension Discover_Flick: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotPosts_Flick.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Flick = collectionView.dequeueReusableCell(
            withReuseIdentifier: PostGridCell_Flick.reuseId_Flick,
            for: indexPath
        ) as? PostGridCell_Flick else {
            return UICollectionViewCell()
        }
        
        let post_Flick = hotPosts_Flick[indexPath.item]
        cell_Flick.configure_Flick(post_flick: post_Flick)
        
        // 操作按钮回调：由 VC 负责调用 ReportDeleteHelper
        cell_Flick.onActionTapped_Flick = { [weak self] in
            self?.handlePostAction_Flick(post_flick: post_Flick)
        }
        
        // 头像点击回调：非当前登录用户帖子才跳转用户中心（本人帖子头像按钮已隐藏，此守卫双重保险）
        cell_Flick.onAvatarTapped_Flick = {
            guard !UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(userId_flick: post_Flick.titleUserId_Flick) else { return }
            let user_Flick = UserViewModel_Flick.shared_Flick.getUserById_Flick(userId_flick: post_Flick.titleUserId_Flick)
            Navigation_Flick.toUserInfo_Flick(with: user_Flick)
        }
        
        return cell_Flick
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Flick = hotPosts_Flick[indexPath.item]
        Navigation_Flick.toTitleDetail_Flick(titleModel_flick: post_Flick)
    }
    
    /// Cell 将要显示时弹性进场动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.animateSpringScaleIn_Flick(
            delay_Flick: TimeInterval(indexPath.item % 6) * AnimationConfig_Flick.delayShort_Flick
        )
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource（搜索结果）

extension Discover_Flick: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults_Flick.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Flick = tableView.dequeueReusableCell(
            withIdentifier: PostCardCell_Flick.reuseId_Flick,
            for: indexPath
        ) as? PostCardCell_Flick else {
            return UITableViewCell()
        }
        
        let post_Flick = searchResults_Flick[indexPath.row]
        let isLiked_Flick = TitleViewModel_Flick.shared_Flick.isLikedPost_Flick(post_flick: post_Flick)
        cell_Flick.configure_Flick(post_flick: post_Flick, isLiked_flick: isLiked_Flick)
        
        cell_Flick.onLikeTapped_Flick = {
            TitleViewModel_Flick.shared_Flick.likePost_Flick(post_flick: post_Flick)
        }
        cell_Flick.onAvatarTapped_Flick = {
            // 仅非当前登录用户的帖子才跳转用户中心（本人帖子头像已禁用交互，此守卫作为双重保险）
            guard !UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(userId_flick: post_Flick.titleUserId_Flick) else { return }
            let user_Flick = UserViewModel_Flick.shared_Flick.getUserById_Flick(userId_flick: post_Flick.titleUserId_Flick)
            Navigation_Flick.toUserInfo_Flick(with: user_Flick)
        }
        return cell_Flick
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let post_Flick = searchResults_Flick[indexPath.row]
        Navigation_Flick.toTitleDetail_Flick(titleModel_flick: post_Flick)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.animateSlideInFromBottom_Flick(
            offset_Flick: 24,
            delay_Flick: TimeInterval(indexPath.row % 6) * AnimationConfig_Flick.delayShort_Flick
        )
    }
}

// MARK: - UITextFieldDelegate（搜索框）

extension Discover_Flick: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        enterSearchMode_Flick()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - 话题标签流式布局视图

/// 话题标签流式排列视图（内部私有组件）
/// 核心作用：自动换行展示话题标签，支持点击回调。
private class TopicTagsFlowView_Flick: UIView {
    
    /// 标签文字数组，赋值后自动重建
    var tags_Flick: [String] = [] {
        didSet { buildTags_Flick() }
    }
    
    /// 点击标签回调，参数为标签文字
    var onTagTapped_Flick: ((String) -> Void)?
    
    private var tagButtons_Flick: [UIButton] = []
    
    /// 高度约束引用（首次 makeConstraints 创建，后续 update(offset:) 更新，避免 updateConstraints 找不到约束崩溃）
    private var tagHeightConstraint_Flick: Constraint?
    
    private func buildTags_Flick() {
        tagButtons_Flick.forEach { $0.removeFromSuperview() }
        tagButtons_Flick.removeAll()
        
        for (index_flick, tag_flick) in tags_Flick.enumerated() {
            let btn_Flick = makeTagButton_Flick(title_Flick: tag_flick, index_Flick: index_flick)
            tagButtons_Flick.append(btn_Flick)
            addSubview(btn_Flick)
        }
        setNeedsLayout()
    }
    
    private func makeTagButton_Flick(title_Flick: String, index_Flick: Int) -> UIButton {
        let btn_Flick = UIButton(type: .custom)
        btn_Flick.setTitle(title_Flick, for: .normal)
        btn_Flick.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Flick.layer.cornerRadius = 14
        btn_Flick.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        btn_Flick.tag = index_Flick
        btn_Flick.addTarget(self, action: #selector(handleTagTap_Flick(_:)), for: .touchUpInside)
        
        let palettes_Flick: [(UIColor, UIColor, UIColor)] = [
            (UIColor(hexstring_Flick: "#B794F6").withValues(alpha: 0.15),
             ColorConfig_Flick.primaryGradientStart_Flick,
             ColorConfig_Flick.primaryGradientStart_Flick),
            (UIColor(hexstring_Flick: "#90CDF4").withValues(alpha: 0.15),
             UIColor(hexstring_Flick: "#2B6CB0"),
             UIColor(hexstring_Flick: "#2B6CB0")),
            (UIColor(hexstring_Flick: "#FBB6CE").withValues(alpha: 0.18),
             UIColor(hexstring_Flick: "#97266D"),
             UIColor(hexstring_Flick: "#97266D")),
            (UIColor(hexstring_Flick: "#FED7AA").withValues(alpha: 0.2),
             UIColor(hexstring_Flick: "#C05621"),
             UIColor(hexstring_Flick: "#C05621")),
            (UIColor(hexstring_Flick: "#C6F6D5").withValues(alpha: 0.2),
             UIColor(hexstring_Flick: "#276749"),
             UIColor(hexstring_Flick: "#276749")),
        ]
        let p_Flick = palettes_Flick[index_Flick % palettes_Flick.count]
        btn_Flick.backgroundColor = p_Flick.0
        btn_Flick.setTitleColor(p_Flick.1, for: .normal)
        btn_Flick.layer.borderWidth = 1
        btn_Flick.layer.borderColor = p_Flick.2.withValues(alpha: 0.3).cgColor
        
        return btn_Flick
    }
    
    /// 手动流式布局：逐个按钮计算 frame，自动换行
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let containerWidth_Flick = bounds.width
        guard containerWidth_Flick > 0 else { return }
        
        var xOffset_Flick: CGFloat = 0
        var yOffset_Flick: CGFloat = 0
        let rowHeight_Flick: CGFloat = 32
        let hSpacing_Flick: CGFloat = 8
        let vSpacing_Flick: CGFloat = 8
        
        for btn_Flick in tagButtons_Flick {
            btn_Flick.sizeToFit()
            let btnWidth_Flick = btn_Flick.frame.width
            
            if xOffset_Flick + btnWidth_Flick > containerWidth_Flick && xOffset_Flick > 0 {
                xOffset_Flick = 0
                yOffset_Flick += rowHeight_Flick + vSpacing_Flick
            }
            
            btn_Flick.frame = CGRect(x: xOffset_Flick, y: yOffset_Flick, width: btnWidth_Flick, height: rowHeight_Flick)
            xOffset_Flick += btnWidth_Flick + hSpacing_Flick
        }
        
        let totalHeight_Flick = tagButtons_Flick.last?.frame.maxY ?? 0
        guard totalHeight_Flick > 0 else { return }
        
        // 首次创建高度约束；后续只更新偏移量，避免 updateConstraints 找不到已有约束而崩溃
        if let existingConstraint_Flick = tagHeightConstraint_Flick {
            existingConstraint_Flick.update(offset: totalHeight_Flick)
        } else {
            snp.makeConstraints { make in
                tagHeightConstraint_Flick = make.height.equalTo(totalHeight_Flick).constraint
            }
        }
    }
    
    @objc private func handleTagTap_Flick(_ sender: UIButton) {
        sender.animatePulse_Flick()
        let generator_Flick = UIImpactFeedbackGenerator(style: .light)
        generator_Flick.impactOccurred()
        onTagTapped_Flick?(tags_Flick[sender.tag])
    }
}
