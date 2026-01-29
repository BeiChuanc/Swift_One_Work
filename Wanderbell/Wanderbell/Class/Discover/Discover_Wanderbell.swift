import Foundation
import UIKit
import SnapKit
import CHTCollectionViewWaterfallLayout

// MARK: 发现页

/// 发现页面 - 情绪分享瀑布流
/// 功能：展示所有用户的情绪记录，支持搜索和筛选
/// 设计：瀑布流布局、搜索栏、标签筛选
class Discover_Wanderbell: UIViewController {
    
    // MARK: - UI组件
    
    /// 页面标题
    private lazy var pageTitleView_Wanderbell: PageHeaderView_Wanderbell = {
        return PageHeaderView_Wanderbell(
            title_wanderbell: "Discover",
            subtitle_wanderbell: "Explore emotions from the community",
            iconName_wanderbell: "sparkle.magnifyingglass",
            iconColor_wanderbell: ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        )
    }()
    
    /// 搜索栏
    private let searchBar_Wanderbell = DiscoverSearchBar_Wanderbell()
    
    /// 筛选栏
    private let filterBar_Wanderbell = EmotionFilterBar_Wanderbell()
    
    /// 瀑布流CollectionView
    private lazy var collectionView_Wanderbell: UICollectionView = {
        let layout_wanderbell = CHTCollectionViewWaterfallLayout()
        layout_wanderbell.columnCount = 2
        layout_wanderbell.minimumColumnSpacing = 12
        layout_wanderbell.minimumInteritemSpacing = 12
        
        let collectionView_wanderbell = UICollectionView(frame: .zero, collectionViewLayout: layout_wanderbell)
        collectionView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        collectionView_wanderbell.delegate = self
        collectionView_wanderbell.dataSource = self
        collectionView_wanderbell.register(EmotionShareCard_Wanderbell.self, forCellWithReuseIdentifier: EmotionShareCard_Wanderbell.reuseIdentifier_Wanderbell)
        collectionView_wanderbell.showsVerticalScrollIndicator = false
        collectionView_wanderbell.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 100, right: 12)
        return collectionView_wanderbell
    }()
    
    // MARK: - 数据
    
    /// 当前展示的帖子（心情记录）
    private var displayedPosts_Wanderbell: [TitleModel_Wanderbell] = []
    
    /// 所有帖子
    private var allPosts_Wanderbell: [TitleModel_Wanderbell] = []
    
    /// 当前搜索关键词
    private var currentSearchText_Wanderbell: String = ""
    
    /// 当前筛选的情绪类型
    private var currentFilterEmotions_Wanderbell: [EmotionType_Wanderbell] = []
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupCallbacks_Wanderbell()
        loadData_Wanderbell()
        observeEmotionState_Wanderbell()
        
        // 启动标题图标动画
        pageTitleView_Wanderbell.startBreathingAnimation_Wanderbell()
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        // 设置发现页渐变背景
        view.addDiscoverBackgroundGradient_Wanderbell()
        
        view.addSubview(pageTitleView_Wanderbell)
        view.addSubview(searchBar_Wanderbell)
        view.addSubview(filterBar_Wanderbell)
        view.addSubview(collectionView_Wanderbell)
    }
    
    private func setupConstraints_Wanderbell() {
        pageTitleView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(90)
        }
        
        searchBar_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(pageTitleView_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        filterBar_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(searchBar_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        collectionView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(filterBar_Wanderbell.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupCallbacks_Wanderbell() {
        // 搜索栏回调
        searchBar_Wanderbell.onSearchTextChanged_Wanderbell = { [weak self] text_wanderbell in
            self?.currentSearchText_Wanderbell = text_wanderbell
            self?.applyFilters_Wanderbell()
        }
        
        // 筛选栏回调
        filterBar_Wanderbell.onFilterChanged_Wanderbell = { [weak self] emotions_wanderbell in
            self?.currentFilterEmotions_Wanderbell = emotions_wanderbell
            self?.applyFilters_Wanderbell()
        }
    }
    
    /// 监听帖子状态变化
    private func observeEmotionState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEmotionStateChange_Wanderbell),
            name: TitleViewModel_Wanderbell.titleStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    // MARK: - 数据加载
    
    private func loadData_Wanderbell() {
        allPosts_Wanderbell = TitleViewModel_Wanderbell.shared_Wanderbell.getPosts_Wanderbell()
        displayedPosts_Wanderbell = allPosts_Wanderbell
        collectionView_Wanderbell.reloadData()
    }
    
    /// 应用筛选
    private func applyFilters_Wanderbell() {
        var filteredPosts_wanderbell = allPosts_Wanderbell
        
        // 应用搜索
        if !currentSearchText_Wanderbell.isEmpty {
            let keyword_wanderbell = currentSearchText_Wanderbell.lowercased()
            filteredPosts_wanderbell = filteredPosts_wanderbell.filter { post_wanderbell in
                post_wanderbell.title_Wanderbell.lowercased().contains(keyword_wanderbell) ||
                post_wanderbell.titleContent_Wanderbell.lowercased().contains(keyword_wanderbell) ||
                post_wanderbell.titleUserName_Wanderbell.lowercased().contains(keyword_wanderbell)
            }
        }
        
        // 应用情绪类型筛选（基于内容推测）
        if !currentFilterEmotions_Wanderbell.isEmpty {
            filteredPosts_wanderbell = filteredPosts_wanderbell.filter { post_wanderbell in
                let inferredEmotion_wanderbell = inferEmotionFromPost_Wanderbell(post_wanderbell: post_wanderbell)
                return currentFilterEmotions_Wanderbell.contains(inferredEmotion_wanderbell)
            }
        }
        
        displayedPosts_Wanderbell = filteredPosts_wanderbell
        collectionView_Wanderbell.reloadData()
    }
    
    /// 从帖子推测情绪类型
    private func inferEmotionFromPost_Wanderbell(post_wanderbell: TitleModel_Wanderbell) -> EmotionType_Wanderbell {
        let title_wanderbell = post_wanderbell.title_Wanderbell.lowercased()
        let content_wanderbell = post_wanderbell.titleContent_Wanderbell.lowercased()
        let text_wanderbell = title_wanderbell + " " + content_wanderbell
        
        if text_wanderbell.contains("sunshine") || text_wanderbell.contains("joy") || text_wanderbell.contains("smiling") {
            return .happy_wanderbell
        }
        if text_wanderbell.contains("calm") || text_wanderbell.contains("peace") {
            return .calm_wanderbell
        }
        if text_wanderbell.contains("sad") || text_wanderbell.contains("heavy") {
            return .sad_wanderbell
        }
        if text_wanderbell.contains("anxiety") || text_wanderbell.contains("worry") {
            return .anxious_wanderbell
        }
        if text_wanderbell.contains("anger") || text_wanderbell.contains("fire") || text_wanderbell.contains("frustration") {
            return .angry_wanderbell
        }
        if text_wanderbell.contains("excitement") || text_wanderbell.contains("energy") {
            return .excited_wanderbell
        }
        if text_wanderbell.contains("tired") || text_wanderbell.contains("exhausted") {
            return .tired_wanderbell
        }
        
        return .calm_wanderbell
    }
    
    @objc private func handleEmotionStateChange_Wanderbell() {
        loadData_Wanderbell()
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Wanderbell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPosts_Wanderbell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_wanderbell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmotionShareCard_Wanderbell.reuseIdentifier_Wanderbell,
            for: indexPath
        ) as! EmotionShareCard_Wanderbell
        
        let post_wanderbell = displayedPosts_Wanderbell[indexPath.item]
        cell_wanderbell.configure_Wanderbell(with: post_wanderbell)
        
        // 设置点赞按钮回调
        cell_wanderbell.onLikeButtonTapped_Wanderbell = { [weak self] tappedPost_wanderbell in
            // 调用 TitleViewModel 的点赞逻辑
            TitleViewModel_Wanderbell.shared_Wanderbell.likePost_Wanderbell(post_wanderbell: tappedPost_wanderbell)
            
            // 刷新当前 cell
            if let updatedPost_wanderbell = TitleViewModel_Wanderbell.shared_Wanderbell.getPostById_Wanderbell(
                postId_wanderbell: tappedPost_wanderbell.titleId_Wanderbell
            ) {
                cell_wanderbell.configure_Wanderbell(with: updatedPost_wanderbell)
            }
        }
        
        // 设置头像点击回调
        cell_wanderbell.onAvatarTapped_Wanderbell = { [weak self] tappedPost_wanderbell in
            // 获取作者用户信息
            let authorUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getUserById_Wanderbell(
                userId_wanderbell: tappedPost_wanderbell.titleUserId_Wanderbell
            )
            
            // 跳转到用户中心
            Navigation_Wanderbell.toUserInfo_Wanderbell(
                with: authorUser_wanderbell,
                style_wanderbell: .push_wanderbell
            )
        }
        
        // 添加入场动画
        cell_wanderbell.animateFadeIn_Wanderbell(delay_wanderbell: TimeInterval(indexPath.item % 10) * 0.05)
        
        return cell_wanderbell
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Wanderbell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_wanderbell = displayedPosts_Wanderbell[indexPath.item]
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
        
        // 跳转到帖子详情页
        Navigation_Wanderbell.toTitleDetail_Wanderbell(
            titleModel_wanderbell: post_wanderbell,
            style_wanderbell: .push_wanderbell
        )
    }
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout

extension Discover_Wanderbell: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post_wanderbell = displayedPosts_Wanderbell[indexPath.item]
        let contentLength_wanderbell = post_wanderbell.titleContent_Wanderbell.count
        
        // 计算各部分高度
        let userInfoHeight_wanderbell: CGFloat = 32 + 12  // 用户信息 + 间距
        let mediaHeight_wanderbell: CGFloat = 180 + 12    // 媒体 + 间距
        let emotionTagHeight_wanderbell: CGFloat = 24 + 8 // 情绪标签 + 间距
        let titleHeight_wanderbell: CGFloat = 50          // 标题（最多2行）
        let toolbarHeight_wanderbell: CGFloat = 32 + 12 + 12 // 工具栏 + 上下间距
        
        // 根据内容长度动态计算内容区域高度
        let contentHeight_wanderbell: CGFloat = max(60, CGFloat(contentLength_wanderbell / 40) * 20)
        
        // 总高度
        let totalHeight_wanderbell = userInfoHeight_wanderbell + 
                                     mediaHeight_wanderbell + 
                                     emotionTagHeight_wanderbell + 
                                     titleHeight_wanderbell + 
                                     contentHeight_wanderbell + 
                                     toolbarHeight_wanderbell + 
                                     24 // 上下padding
        
        let columnWidth_wanderbell = (collectionView.bounds.width - 36) / 2 // 36 = left(12) + right(12) + spacing(12)
        return CGSize(width: columnWidth_wanderbell, height: min(totalHeight_wanderbell, 550))
    }
}
