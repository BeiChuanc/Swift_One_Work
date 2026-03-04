import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页面
/// 功能：展示一器多画轻挑战和社区帖子
/// 特性：挑战列表、帖子展示
class Discover_Glasspaint: UIViewController {
    
    // MARK: - UI属性
    
    /// 主滚动视图
    private let scrollView_Glasspaint = UIScrollView()
    
    /// 内容容器
    private let contentView_Glasspaint = UIView()
    
    /// 背景渐变层
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    
    /// 装饰圆圈1
    private let decorCircle1_Glasspaint = UIView()
    
    /// 装饰圆圈2
    private let decorCircle2_Glasspaint = UIView()
    
    /// 导航栏容器
    private let navContainer_Glasspaint = UIView()
    
    /// 导航栏毛玻璃效果
    private let navBlurEffect_Glasspaint = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    /// 标题标签
    private let titleLabel_Glasspaint = UILabel()
    
    /// 副标题标签
    private let subtitleLabel_Glasspaint = UILabel()
    
    /// 添加时间胶囊按钮
    private let addCapsuleButton_Glasspaint = UIButton(type: .system)
    private let addCapsuleGradientLayer_Glasspaint = CAGradientLayer()
    
    // 一器多画轻挑战区域
    private let challengeContainer_Glasspaint = UIView()
    private let challengeTitleLabel_Glasspaint = UILabel()
    private let challengeCollectionView_Glasspaint: UICollectionView = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .horizontal
        layout_glasspaint.minimumLineSpacing = 16
        layout_glasspaint.itemSize = CGSize(width: 260, height: 280)
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        collectionView_glasspaint.showsHorizontalScrollIndicator = false
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView_glasspaint
    }()
    
    // 社区内容区域
    private let communityContainer_Glasspaint = UIView()
    private let communityTitleLabel_Glasspaint = UILabel()
    
    /// 内容类型切换器（帖子/时间胶囊）
    private let contentTypeSegment_Glasspaint: UISegmentedControl = {
        let segment_glasspaint = UISegmentedControl(items: ["", ""])
        
        // Posts 图标
        let postsConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let postsImage_glasspaint = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: postsConfig_glasspaint)
        segment_glasspaint.setImage(postsImage_glasspaint, forSegmentAt: 0)
        
        // Capsules 图标  
        let capsulesConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let capsulesImage_glasspaint = UIImage(systemName: "timer", withConfiguration: capsulesConfig_glasspaint)
        segment_glasspaint.setImage(capsulesImage_glasspaint, forSegmentAt: 1)
        
        return segment_glasspaint
    }()
    
    private let postsCollectionView_Glasspaint: UICollectionView = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .vertical
        layout_glasspaint.minimumLineSpacing = 12
        layout_glasspaint.minimumInteritemSpacing = 12
        let itemWidth_glasspaint = (UIScreen.main.bounds.width - 52) / 2  // 左右边距20 + 中间间距12
        layout_glasspaint.itemSize = CGSize(width: itemWidth_glasspaint, height: itemWidth_glasspaint + 100)
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        collectionView_glasspaint.showsVerticalScrollIndicator = false
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView_glasspaint.isScrollEnabled = false
        return collectionView_glasspaint
    }()
    
    // MARK: - 数据属性
    
    /// 挑战列表
    private var challenges_Glasspaint: [ChallengeModel_Glasspaint] = []
    
    /// 帖子列表
    private var posts_Glasspaint: [TitleModel_Glasspaint] = []
    
    /// 时间胶囊列表
    private var timeCapsules_Glasspaint: [TimeCapsulePost_Glasspaint] = []
    
    /// 当前展示的内容类型（0=帖子，1=时间胶囊）
    private var currentContentType_Glasspaint: Int = 0
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        loadData_Glasspaint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupNotifications_Glasspaint()
        loadData_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变层
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 主滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        scrollView_Glasspaint.delegate = self
        
        // 内容容器
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 导航栏
        contentView_Glasspaint.addSubview(navContainer_Glasspaint)
        setupNavigationBar_Glasspaint()
        
        // 挑战区域
        contentView_Glasspaint.addSubview(challengeContainer_Glasspaint)
        setupChallengeSection_Glasspaint()
        
        // 社区内容区域
        contentView_Glasspaint.addSubview(communityContainer_Glasspaint)
        setupPostsSection_Glasspaint()
        
        // 布局
        setupConstraints_Glasspaint()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        // 毛玻璃背景
        navContainer_Glasspaint.insertSubview(navBlurEffect_Glasspaint, at: 0)
        navBlurEffect_Glasspaint.alpha = 0
        
        // 标题容器
        let titleContainer_glasspaint = UIView()
        navContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 主标题
        titleContainer_glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.text = "🎨 Discover"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 副标题
        titleContainer_glasspaint.addSubview(subtitleLabel_Glasspaint)
        subtitleLabel_Glasspaint.text = "Challenge & Create"
        subtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        subtitleLabel_Glasspaint.alpha = 0.8
        
        // 添加时间胶囊按钮（优化样式）
        navContainer_Glasspaint.addSubview(addCapsuleButton_Glasspaint)
        
        // 配置按钮样式
        addCapsuleButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15)
        addCapsuleButton_Glasspaint.layer.cornerRadius = 22
        addCapsuleButton_Glasspaint.layer.borderWidth = 2
        addCapsuleButton_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        addCapsuleButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        addCapsuleButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        addCapsuleButton_Glasspaint.layer.shadowRadius = 6
        addCapsuleButton_Glasspaint.layer.shadowOpacity = 0.3
        
        // 配置图标
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image_glasspaint = UIImage(systemName: "plus.circle.fill", withConfiguration: config_glasspaint)
        addCapsuleButton_Glasspaint.setImage(image_glasspaint, for: .normal)
        addCapsuleButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        addCapsuleButton_Glasspaint.imageView?.contentMode = .scaleAspectFit
        addCapsuleButton_Glasspaint.contentVerticalAlignment = .fill
        addCapsuleButton_Glasspaint.contentHorizontalAlignment = .fill
        addCapsuleButton_Glasspaint.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        addCapsuleButton_Glasspaint.addTarget(self, action: #selector(handleAddCapsuleTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        navBlurEffect_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        subtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        addCapsuleButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置社区内容区域
    private func setupPostsSection_Glasspaint() {
        // 顶部容器（包含标题和分段控制器）
        let topContainer_glasspaint = UIView()
        communityContainer_Glasspaint.addSubview(topContainer_glasspaint)
        
        // 标题容器
        let titleContainer_glasspaint = UIView()
        topContainer_glasspaint.addSubview(titleContainer_glasspaint)
        
        // 图标背景容器
        let iconBackground_glasspaint = UIView()
        titleContainer_glasspaint.addSubview(iconBackground_glasspaint)
        iconBackground_glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15)
        iconBackground_glasspaint.layer.cornerRadius = 20
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "photo.stack.fill"))
        iconBackground_glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        titleContainer_glasspaint.addSubview(communityTitleLabel_Glasspaint)
        communityTitleLabel_Glasspaint.text = "Community"
        communityTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        communityTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 分段控制器容器（美化）
        let segmentContainer_glasspaint = UIView()
        topContainer_glasspaint.addSubview(segmentContainer_glasspaint)
        segmentContainer_glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        segmentContainer_glasspaint.layer.cornerRadius = 12
        segmentContainer_glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        segmentContainer_glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentContainer_glasspaint.layer.shadowRadius = 8
        segmentContainer_glasspaint.layer.shadowOpacity = 0.1
        
        segmentContainer_glasspaint.addSubview(contentTypeSegment_Glasspaint)
        contentTypeSegment_Glasspaint.selectedSegmentIndex = 0
        contentTypeSegment_Glasspaint.addTarget(self, action: #selector(handleContentTypeChange_Glasspaint), for: .valueChanged)
        contentTypeSegment_Glasspaint.backgroundColor = .clear
        contentTypeSegment_Glasspaint.selectedSegmentTintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        contentTypeSegment_Glasspaint.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Glasspaint.textSecondary_Glasspaint,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        contentTypeSegment_Glasspaint.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ], for: .selected)
        
        // 集合视图
        communityContainer_Glasspaint.addSubview(postsCollectionView_Glasspaint)
        postsCollectionView_Glasspaint.delegate = self
        postsCollectionView_Glasspaint.dataSource = self
        postsCollectionView_Glasspaint.register(PostCardCell_Glasspaint.self, forCellWithReuseIdentifier: "PostCardCell")
        postsCollectionView_Glasspaint.register(TimeCapsuleCardCell_Glasspaint.self, forCellWithReuseIdentifier: "TimeCapsuleCardCell")
        
        // 布局
        topContainer_glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
        
        iconBackground_glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        communityTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconBackground_glasspaint.snp.right).offset(12)
            make.centerY.top.bottom.right.equalToSuperview()
        }
        
        segmentContainer_glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(titleContainer_glasspaint.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
        
        contentTypeSegment_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
            make.height.equalTo(36)
        }
        
        postsCollectionView_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topContainer_glasspaint.snp.bottom).offset(16)
            make.height.equalTo(400)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置挑战区域
    private func setupChallengeSection_Glasspaint() {
        // 标题容器
        let titleContainer_glasspaint = UIView()
        challengeContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 渐变背景容器
        let iconBackground_glasspaint = UIView()
        titleContainer_glasspaint.addSubview(iconBackground_glasspaint)
        iconBackground_glasspaint.backgroundColor = ColorConfig_Glasspaint.carrierGlassCupColor_Glasspaint.withAlphaComponent(0.15)
        iconBackground_glasspaint.layer.cornerRadius = 20
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "trophy.fill"))
        iconBackground_glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.carrierGlassCupColor_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        titleContainer_glasspaint.addSubview(challengeTitleLabel_Glasspaint)
        challengeTitleLabel_Glasspaint.text = "One Vessel Challenge"
        challengeTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        challengeTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 集合视图
        challengeContainer_Glasspaint.addSubview(challengeCollectionView_Glasspaint)
        challengeCollectionView_Glasspaint.delegate = self
        challengeCollectionView_Glasspaint.dataSource = self
        challengeCollectionView_Glasspaint.register(ChallengeCardCell_Glasspaint.self, forCellWithReuseIdentifier: "ChallengeCardCell")
        
        // 布局
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
        
        iconBackground_glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        challengeTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconBackground_glasspaint.snp.right).offset(12)
            make.centerY.top.bottom.right.equalToSuperview()
        }
        
        challengeCollectionView_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleContainer_glasspaint.snp.bottom).offset(20)
            make.height.equalTo(280)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置布局约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        navContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        challengeContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
        }
        
        communityContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(challengeContainer_Glasspaint.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载数据
    private func loadData_Glasspaint() {
        loadChallenges_Glasspaint()
        loadPosts_Glasspaint()
    }
    
    /// 加载挑战
    private func loadChallenges_Glasspaint() {
        challenges_Glasspaint = ChallengeViewModel_Glasspaint.shared_Glasspaint.getActiveChallenges_Glasspaint()
        challengeCollectionView_Glasspaint.reloadData()
    }
    
    /// 加载帖子
    private func loadPosts_Glasspaint() {
        // 获取普通帖子
        posts_Glasspaint = TitleViewModel_Glasspaint.shared_Glasspaint.getPosts_Glasspaint()
        
        // 检查并自动解锁到期的时间胶囊
        UserViewModel_Glasspaint.shared_Glasspaint.checkAndUnlockTimeCapsules_Glasspaint()
        
        // 获取所有时间胶囊（包括未解锁和已解锁的）
        timeCapsules_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getAllPublicTimeCapsules_Glasspaint()
        
        // 更新集合视图
        updateCollectionHeight_Glasspaint()
        postsCollectionView_Glasspaint.reloadData()
    }
    
    /// 更新集合视图高度
    private func updateCollectionHeight_Glasspaint() {
        let itemWidth_glasspaint = (UIScreen.main.bounds.width - 52) / 2
        let itemHeight_glasspaint = itemWidth_glasspaint + 100
        
        let itemCount_glasspaint = currentContentType_Glasspaint == 0 ? posts_Glasspaint.count : timeCapsules_Glasspaint.count
        let rows_glasspaint = ceil(Double(itemCount_glasspaint) / 2.0)
        let totalHeight_glasspaint = max(400, CGFloat(rows_glasspaint) * itemHeight_glasspaint + CGFloat(max(0, rows_glasspaint - 1)) * 12)
        
        postsCollectionView_Glasspaint.snp.updateConstraints { make in
            make.height.equalTo(totalHeight_glasspaint)
        }
    }
    
    /// 切换内容类型
    @objc private func handleContentTypeChange_Glasspaint() {
        currentContentType_Glasspaint = contentTypeSegment_Glasspaint.selectedSegmentIndex
        updateCollectionHeight_Glasspaint()
        postsCollectionView_Glasspaint.reloadData()
    }
    
    /// 添加时间胶囊
    @objc private func handleAddCapsuleTap_Glasspaint() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.addCapsuleButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addCapsuleButton_Glasspaint.transform = .identity
            }
        }
        
        // 检查是否登录
        if !UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                Navigation_Glasspaint.toLogin_Glasspaint(style_glasspaint: .present_glasspaint)
            }
            return
        }
        
        // 跳转到时间胶囊创建页面
        Navigation_Glasspaint.toAddTimeCapsule_Glasspaint()
    }
    
    // MARK: - 通知
    
    /// 设置通知监听
    private func setupNotifications_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChallengeStateChange_Glasspaint),
            name: ChallengeViewModel_Glasspaint.challengeStateDidChangeNotification_Glasspaint,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Glasspaint),
            name: TitleViewModel_Glasspaint.titleStateDidChangeNotification_Glasspaint,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Glasspaint),
            name: UserViewModel_Glasspaint.userStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    @objc private func handleChallengeStateChange_Glasspaint() {
        loadChallenges_Glasspaint()
    }
    
    @objc private func handleTitleStateChange_Glasspaint() {
        loadPosts_Glasspaint()
    }
    
    @objc private func handleUserStateChange_Glasspaint() {
        loadPosts_Glasspaint()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIScrollView Delegate

extension Discover_Glasspaint: UIScrollViewDelegate {
    
    /// 监听滚动，实现导航栏毛玻璃效果
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset_glasspaint = scrollView.contentOffset.y
        let alpha_glasspaint = min(1, max(0, offset_glasspaint / 50))
        navBlurEffect_Glasspaint.alpha = alpha_glasspaint
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension Discover_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == challengeCollectionView_Glasspaint {
            return challenges_Glasspaint.count
        } else {
            return currentContentType_Glasspaint == 0 ? posts_Glasspaint.count : timeCapsules_Glasspaint.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == challengeCollectionView_Glasspaint {
            let cell_glasspaint = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ChallengeCardCell",
                for: indexPath
            ) as! ChallengeCardCell_Glasspaint
            
            let challenge_glasspaint = challenges_Glasspaint[indexPath.item]
            cell_glasspaint.configure_Glasspaint(with_glasspaint: challenge_glasspaint)
            
            return cell_glasspaint
        } else {
            if currentContentType_Glasspaint == 0 {
                // 显示帖子
                let cell_glasspaint = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PostCardCell",
                    for: indexPath
                ) as! PostCardCell_Glasspaint
                
                let post_glasspaint = posts_Glasspaint[indexPath.item]
                cell_glasspaint.configure_Glasspaint(with_glasspaint: post_glasspaint)
                cell_glasspaint.onLike_Glasspaint = { [weak self] in
                    self?.handlePostLike_Glasspaint(post_glasspaint: post_glasspaint)
                }
                cell_glasspaint.onReport_Glasspaint = { [weak self] in
                    guard let self = self else { return }
                    ReportDeleteHelper_Glasspaint.report_Glasspaint(
                        post_Glasspaint: post_glasspaint,
                        from: self
                    ) {
                        // 重新加载帖子数据并刷新界面
                        self.loadPosts_Glasspaint()
                        self.postsCollectionView_Glasspaint.reloadData()
                    }
                }
                cell_glasspaint.onAvatarTap_Glasspaint = { [weak self] in
                    self?.openUserProfile_Glasspaint(userId_glasspaint: post_glasspaint.titleUserId_Glasspaint)
                }
                
                return cell_glasspaint
            } else {
                // 显示时间胶囊
                let cell_glasspaint = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "TimeCapsuleCardCell",
                    for: indexPath
                ) as! TimeCapsuleCardCell_Glasspaint
                
                let capsule_glasspaint = timeCapsules_Glasspaint[indexPath.item]
                cell_glasspaint.configure_Glasspaint(with_glasspaint: capsule_glasspaint)
                cell_glasspaint.onReport_Glasspaint = { [weak self] in
                    guard let self = self else { return }
                    ReportDeleteHelper_Glasspaint.report_Glasspaint(
                        capsule_Glasspaint: capsule_glasspaint,
                        from: self
                    ) {
                        // 重新加载数据并刷新界面
                        self.loadPosts_Glasspaint()
                        self.postsCollectionView_Glasspaint.reloadData()
                    }
                }
                cell_glasspaint.onAvatarTap_Glasspaint = { [weak self] in
                    self?.openUserProfile_Glasspaint(userId_glasspaint: capsule_glasspaint.userId_Glasspaint)
                }
                
                return cell_glasspaint
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 添加选中动画效果
        if let cell_glasspaint = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell_glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell_glasspaint.transform = .identity
                }
            }
        }
        
        if collectionView == challengeCollectionView_Glasspaint {
            let challenge_glasspaint = challenges_Glasspaint[indexPath.item]
            // 跳转到挑战评论讨论区
            let discussionVC_glasspaint = ChallengeDiscussionViewController_Glasspaint(challenge_glasspaint: challenge_glasspaint)
            navigationController?.pushViewController(discussionVC_glasspaint, animated: true)
        } else {
            if currentContentType_Glasspaint == 0 {
                let post_glasspaint = posts_Glasspaint[indexPath.item]
                Navigation_Glasspaint.toTitleDetail_Glasspaint(titleModel_glasspaint: post_glasspaint)
            } else {
                // 点击时间胶囊
                let capsule_glasspaint = timeCapsules_Glasspaint[indexPath.item]
                
                // 检查是否已解锁
                if capsule_glasspaint.status_Glasspaint == .unlocked_glasspaint {
                    showTimeCapsuleDetail_Glasspaint(capsule_glasspaint: capsule_glasspaint)
                } else {
                    // 未解锁，显示提示
                    showLockedCapsuleAlert_Glasspaint(capsule_glasspaint: capsule_glasspaint)
                }
            }
        }
    }
    
    /// 处理帖子点赞
    private func handlePostLike_Glasspaint(post_glasspaint: TitleModel_Glasspaint) {
        TitleViewModel_Glasspaint.shared_Glasspaint.likePost_Glasspaint(post_glasspaint: post_glasspaint)
        postsCollectionView_Glasspaint.reloadData()
    }
    
    /// 打开用户中心
    /// 参数：
    /// - userId_glasspaint: 用户ID
    private func openUserProfile_Glasspaint(userId_glasspaint: Int) {
        // 检查是否是当前登录用户
        if UserViewModel_Glasspaint.shared_Glasspaint.isCurrentUser_Glasspaint(userId_glasspaint: userId_glasspaint) {
            return
        }
        
        // 查找用户模型
        if let user_glasspaint = LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint.first(where: { $0.userId_Glasspaint == userId_glasspaint }) {
            let userInfoVC_glasspaint = UserInfo_Glasspaint()
            userInfoVC_glasspaint.userModel_Glasspaint = user_glasspaint
            userInfoVC_glasspaint.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(userInfoVC_glasspaint, animated: true)
        }
    }
    
    /// 显示时间胶囊详情（弹窗）
    private func showTimeCapsuleDetail_Glasspaint(capsule_glasspaint: TimeCapsulePost_Glasspaint) {
        // 创建弹窗视图控制器
        let detailVC_glasspaint = TimeCapsuleDetailViewController_Glasspaint(capsule_glasspaint: capsule_glasspaint)
        detailVC_glasspaint.modalPresentationStyle = .pageSheet
        
        // 设置弹窗高度
        if let sheet_glasspaint = detailVC_glasspaint.sheetPresentationController {
            sheet_glasspaint.detents = [.medium(), .large()]
            sheet_glasspaint.preferredCornerRadius = 20
            sheet_glasspaint.prefersGrabberVisible = true
        }
        
        present(detailVC_glasspaint, animated: true)
    }
    
    /// 显示未解锁时间胶囊提示
    private func showLockedCapsuleAlert_Glasspaint(capsule_glasspaint: TimeCapsulePost_Glasspaint) {
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateStyle = .long
        formatter_glasspaint.timeStyle = .none
        
        let unlockDateStr_glasspaint = formatter_glasspaint.string(from: capsule_glasspaint.unlockDate_Glasspaint)
        
        let alert_glasspaint = UIAlertController(
            title: "🔒 Time Capsule Locked",
            message: "This time capsule will unlock on \(unlockDateStr_glasspaint). Please wait for the unlock date to view its contents.",
            preferredStyle: .alert
        )
        
        alert_glasspaint.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert_glasspaint, animated: true)
    }
    
    
    /// 格式化日期
    private func formatDate_Glasspaint(_ date_glasspaint: Date) -> String {
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateStyle = .medium
        formatter_glasspaint.timeStyle = .none
        return formatter_glasspaint.string(from: date_glasspaint)
    }
}

// MARK: - 帖子卡片单元格

/// 帖子卡片单元格
/// 功能：展示社区帖子卡片，优化的UI设计
class PostCardCell_Glasspaint: UICollectionViewCell {
    
    private let cardContainer_Glasspaint = UIView()
    private let mediaView_Glasspaint = MediaDisplayView_Glasspaint()
    private let gradientOverlay_Glasspaint = CAGradientLayer()
    
    // 媒体底部作者信息（叠加在媒体上）
    private let authorOverlayContainer_Glasspaint = UIView()
    private let authorAvatarView_Glasspaint = UserAvatarView_Glasspaint()
    private let authorNameLabel_Glasspaint = UILabel()
    
    private let infoContainer_Glasspaint = UIView()
    
    // 标题区域
    private let titleContainer_Glasspaint = UIView()
    private let titleIconView_Glasspaint = UIImageView()
    private let titleLabel_Glasspaint = UILabel()
    
    // 内容标签
    private let contentLabel_Glasspaint = UILabel()
    
    // 标签容器
    private let tagsContainer_Glasspaint = UIView()
    private let categoryBadge_Glasspaint = UILabel()
    private let levelBadge_Glasspaint = UILabel()
    
    // 底部信息栏
    private let bottomContainer_Glasspaint = UIView()
    private let likeButton_Glasspaint = UIButton(type: .system)
    private let commentIconView_Glasspaint = UIImageView()
    private let commentLabel_Glasspaint = UILabel()
    
    // 举报按钮
    private let reportButton_Glasspaint: UIButton = {
        let button_glasspaint = UIButton(type: .system)
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image_glasspaint = UIImage(systemName: "ellipsis", withConfiguration: config_glasspaint)
        button_glasspaint.setImage(image_glasspaint, for: .normal)
        button_glasspaint.tintColor = .white
        button_glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button_glasspaint.layer.cornerRadius = 16
        return button_glasspaint
    }()
    
    var onLike_Glasspaint: (() -> Void)?
    var onReport_Glasspaint: (() -> Void)?
    var onAvatarTap_Glasspaint: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
        setupGestures_Glasspaint()
    }
    
    /// 设置手势
    private func setupGestures_Glasspaint() {
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Glasspaint))
        authorAvatarView_Glasspaint.isUserInteractionEnabled = true
        authorAvatarView_Glasspaint.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    /// 处理头像点击
    @objc private func handleAvatarTap_Glasspaint() {
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .light)
        generator_glasspaint.impactOccurred()
        
        // 缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self.authorAvatarView_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.authorAvatarView_Glasspaint.transform = .identity
            }
        }
        
        onAvatarTap_Glasspaint?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 卡片容器
        contentView.addSubview(cardContainer_Glasspaint)
        cardContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        cardContainer_Glasspaint.layer.cornerRadius = 16
        cardContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        cardContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainer_Glasspaint.layer.shadowRadius = 12
        cardContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        // 媒体视图
        cardContainer_Glasspaint.addSubview(mediaView_Glasspaint)
        mediaView_Glasspaint.layer.cornerRadius = 16
        mediaView_Glasspaint.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 举报按钮
        cardContainer_Glasspaint.addSubview(reportButton_Glasspaint)
        reportButton_Glasspaint.addTarget(self, action: #selector(handleReportTap_Glasspaint), for: .touchUpInside)
        
        // 渐变遮罩（从中间到底部加深）
        mediaView_Glasspaint.layer.addSublayer(gradientOverlay_Glasspaint)
        gradientOverlay_Glasspaint.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradientOverlay_Glasspaint.locations = [0.5, 1.0]
        
        // 作者信息容器（叠加在媒体底部）
        cardContainer_Glasspaint.addSubview(authorOverlayContainer_Glasspaint)
        
        // 作者头像
        authorOverlayContainer_Glasspaint.addSubview(authorAvatarView_Glasspaint)
        authorAvatarView_Glasspaint.layer.borderWidth = 2
        authorAvatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        // 作者昵称
        authorOverlayContainer_Glasspaint.addSubview(authorNameLabel_Glasspaint)
        authorNameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        authorNameLabel_Glasspaint.textColor = .white
        authorNameLabel_Glasspaint.shadowColor = UIColor.black.withAlphaComponent(0.5)
        authorNameLabel_Glasspaint.shadowOffset = CGSize(width: 0, height: 1)
        
        // 信息容器
        cardContainer_Glasspaint.addSubview(infoContainer_Glasspaint)
        infoContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        infoContainer_Glasspaint.layer.cornerRadius = 16
        infoContainer_Glasspaint.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        infoContainer_Glasspaint.layer.masksToBounds = true
        
        // 标题容器
        infoContainer_Glasspaint.addSubview(titleContainer_Glasspaint)
        
        titleContainer_Glasspaint.addSubview(titleIconView_Glasspaint)
        titleIconView_Glasspaint.image = UIImage(systemName: "paintbrush.fill")
        titleIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        titleIconView_Glasspaint.contentMode = .scaleAspectFit
        
        titleContainer_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.numberOfLines = 1
        
        // 内容
        infoContainer_Glasspaint.addSubview(contentLabel_Glasspaint)
        contentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        contentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        contentLabel_Glasspaint.numberOfLines = 2
        
        // 标签容器
        infoContainer_Glasspaint.addSubview(tagsContainer_Glasspaint)
        
        tagsContainer_Glasspaint.addSubview(categoryBadge_Glasspaint)
        categoryBadge_Glasspaint.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        categoryBadge_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        categoryBadge_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        categoryBadge_Glasspaint.layer.cornerRadius = 9
        categoryBadge_Glasspaint.layer.masksToBounds = true
        categoryBadge_Glasspaint.textAlignment = .center
        
        tagsContainer_Glasspaint.addSubview(levelBadge_Glasspaint)
        levelBadge_Glasspaint.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        levelBadge_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        levelBadge_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        levelBadge_Glasspaint.layer.cornerRadius = 9
        levelBadge_Glasspaint.layer.masksToBounds = true
        levelBadge_Glasspaint.textAlignment = .center
        
        // 底部容器
        infoContainer_Glasspaint.addSubview(bottomContainer_Glasspaint)
        bottomContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.withAlphaComponent(0.3)
        bottomContainer_Glasspaint.layer.cornerRadius = 8
        
        // 评论图标
        bottomContainer_Glasspaint.addSubview(commentIconView_Glasspaint)
        commentIconView_Glasspaint.image = UIImage(systemName: "bubble.right.fill")
        commentIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        commentIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 评论数
        bottomContainer_Glasspaint.addSubview(commentLabel_Glasspaint)
        commentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        commentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 点赞按钮
        bottomContainer_Glasspaint.addSubview(likeButton_Glasspaint)
        likeButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        likeButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.textSecondary_Glasspaint, for: .normal)
        likeButton_Glasspaint.addTarget(self, action: #selector(handleLikeTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        cardContainer_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        
        mediaView_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(120)
        }
        
        reportButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }
        
        // 作者信息叠加层（在媒体底部）
        authorOverlayContainer_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalTo(mediaView_Glasspaint).inset(8)
            make.bottom.equalTo(mediaView_Glasspaint).offset(-8)
            make.height.equalTo(32)
        }
        
        authorAvatarView_Glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        authorNameLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(authorAvatarView_Glasspaint.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }
        
        infoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Glasspaint.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        titleContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        
        titleIconView_Glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(titleIconView_Glasspaint.snp.right).offset(6)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        contentLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleContainer_Glasspaint.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(10)
        }
        
        tagsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Glasspaint.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        
        categoryBadge_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(45)
        }
        
        levelBadge_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(categoryBadge_Glasspaint.snp.right).offset(4)
            make.top.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(45)
        }
        
        bottomContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(tagsContainer_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(28)
        }
        
        commentIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        commentLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(commentIconView_Glasspaint.snp.right).offset(3)
            make.centerY.equalToSuperview()
        }
        
        likeButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientOverlay_Glasspaint.frame = mediaView_Glasspaint.bounds
    }
    
    @objc private func handleReportTap_Glasspaint() {
        onReport_Glasspaint?()
    }
    
    @objc private func handleLikeTap_Glasspaint() {
        onLike_Glasspaint?()
    }
    
    /// 配置数据
    func configure_Glasspaint(with_glasspaint post_glasspaint: TitleModel_Glasspaint) {
        // 媒体
        if let mediaUrl_glasspaint = post_glasspaint.titleMeidas_Glasspaint.first {
            mediaView_Glasspaint.configure_Glasspaint(mediaPath_Glasspaint: mediaUrl_glasspaint)
        } else {
            mediaView_Glasspaint.configure_Glasspaint(mediaPath_Glasspaint: nil)
        }
        
        // 作者信息（叠加在媒体底部）
        authorNameLabel_Glasspaint.text = post_glasspaint.titleUserName_Glasspaint
        
        // 配置作者头像
        authorAvatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: post_glasspaint.titleUserId_Glasspaint)
        
        // 标题
        titleLabel_Glasspaint.text = post_glasspaint.title_Glasspaint
        
        // 内容
        contentLabel_Glasspaint.text = post_glasspaint.titleContent_Glasspaint
        
        // 分类标签
        categoryBadge_Glasspaint.text = " \(post_glasspaint.scene_Glasspaint) "
        
        // 难度标签
        levelBadge_Glasspaint.text = " \(post_glasspaint.paintingLevel_Glasspaint.rawValue) "
        
        // 评论数
        commentLabel_Glasspaint.text = "\(post_glasspaint.reviews_Glasspaint.count)"
        
        // 点赞状态和数量
        let isLiked_glasspaint = TitleViewModel_Glasspaint.shared_Glasspaint.isLikedPost_Glasspaint(post_glasspaint: post_glasspaint)
        let likeIcon_glasspaint = isLiked_glasspaint ? "❤️" : "🤍"
        likeButton_Glasspaint.setTitle("\(likeIcon_glasspaint) \(post_glasspaint.likes_Glasspaint)", for: .normal)
    }
}

// MARK: - 背景和装饰扩展

extension Discover_Glasspaint {
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        // 渐变层设置（橙色调主题）
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            UIColor(hexstring_Glasspaint: "#FFF5E6").cgColor,
            ColorConfig_Glasspaint.backgroundSecondary_Glasspaint.cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        // 装饰圆圈1（右上角 - 橙色系）
        view.addSubview(decorCircle1_Glasspaint)
        decorCircle1_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.08)
        decorCircle1_Glasspaint.layer.cornerRadius = 140
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-70)
            make.right.equalToSuperview().offset(70)
            make.width.height.equalTo(280)
        }
        
        // 装饰圆圈2（左下角 - 蓝绿色系）
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = ColorConfig_Glasspaint.carrierGlassCupColor_Glasspaint.withAlphaComponent(0.06)
        decorCircle2_Glasspaint.layer.cornerRadius = 110
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(55)
            make.left.equalToSuperview().offset(-55)
            make.width.height.equalTo(220)
        }
        
        // 添加旋转动画
        animateDecorationCircles_Glasspaint()
    }
    
    /// 装饰圆圈动画
    private func animateDecorationCircles_Glasspaint() {
        // 圆圈1旋转动画
        let rotation1_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation1_glasspaint.fromValue = 0
        rotation1_glasspaint.toValue = Double.pi * 2
        rotation1_glasspaint.duration = 50
        rotation1_glasspaint.repeatCount = .infinity
        decorCircle1_Glasspaint.layer.add(rotation1_glasspaint, forKey: "rotation1")
        
        // 圆圈2反向旋转
        let rotation2_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation2_glasspaint.fromValue = 0
        rotation2_glasspaint.toValue = -Double.pi * 2
        rotation2_glasspaint.duration = 70
        rotation2_glasspaint.repeatCount = .infinity
        decorCircle2_Glasspaint.layer.add(rotation2_glasspaint, forKey: "rotation2")
        
        // 脉冲效果
        UIView.animate(withDuration: 2.5, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.decorCircle1_Glasspaint.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.decorCircle2_Glasspaint.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
    }
    
    /// 布局更新
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变层大小
        backgroundGradientLayer_Glasspaint.frame = view.bounds
    }
}

// MARK: - 挑战卡片单元格

/// 挑战卡片单元格
class ChallengeCardCell_Glasspaint: UICollectionViewCell {
    
    private let cardView_Glasspaint = ChallengeCard_Glasspaint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView_Glasspaint)
        cardView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure_Glasspaint(with_glasspaint challenge_glasspaint: ChallengeModel_Glasspaint) {
        cardView_Glasspaint.configure_Glasspaint(with_glasspaint: challenge_glasspaint)
    }
}

// MARK: - 时间胶囊卡片单元格

/// 时间胶囊卡片单元格
/// 功能：展示已解锁的时间胶囊，优化的UI设计
class TimeCapsuleCardCell_Glasspaint: UICollectionViewCell {
    
    private let cardContainer_Glasspaint = UIView()
    private let mediaView_Glasspaint = MediaDisplayView_Glasspaint()
    private let gradientOverlay_Glasspaint = CAGradientLayer()
    private let shimmerLayer_Glasspaint = CAGradientLayer()
    
    // 解锁徽章容器（右上角）
    private let unlockBadgeContainer_Glasspaint = UIView()
    private let unlockIconView_Glasspaint = UIImageView()
    private let unlockLabel_Glasspaint = UILabel()
    
    // 作者信息叠加层（媒体底部）
    private let authorOverlayContainer_Glasspaint = UIView()
    private let authorAvatarView_Glasspaint = UserAvatarView_Glasspaint()
    private let authorNameLabel_Glasspaint = UILabel()
    
    // 信息容器
    private let infoContainer_Glasspaint = UIView()
    
    // 标题容器
    private let titleContainer_Glasspaint = UIView()
    private let capsuleIconView_Glasspaint = UIImageView()
    private let titleLabel_Glasspaint = UILabel()
    
    // 时间信息容器
    private let timeInfoContainer_Glasspaint = UIView()
    private let createdIconView_Glasspaint = UIImageView()
    private let createdLabel_Glasspaint = UILabel()
    private let unlockIconView2_Glasspaint = UIImageView()
    private let unlockDateLabel_Glasspaint = UILabel()
    
    // 底部信息栏
    private let bottomContainer_Glasspaint = UIView()
    private let viewIconView_Glasspaint = UIImageView()
    private let viewLabel_Glasspaint = UILabel()
    
    // 举报按钮
    private let reportButton_Glasspaint: UIButton = {
        let button_glasspaint = UIButton(type: .system)
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image_glasspaint = UIImage(systemName: "ellipsis", withConfiguration: config_glasspaint)
        button_glasspaint.setImage(image_glasspaint, for: .normal)
        button_glasspaint.tintColor = .white
        button_glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button_glasspaint.layer.cornerRadius = 16
        return button_glasspaint
    }()
    
    var onReport_Glasspaint: (() -> Void)?
    var onAvatarTap_Glasspaint: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
        setupAnimation_Glasspaint()
        setupGestures_Glasspaint()
    }
    
    /// 设置手势
    private func setupGestures_Glasspaint() {
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Glasspaint))
        authorAvatarView_Glasspaint.isUserInteractionEnabled = true
        authorAvatarView_Glasspaint.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    /// 处理头像点击
    @objc private func handleAvatarTap_Glasspaint() {
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .light)
        generator_glasspaint.impactOccurred()
        
        // 缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self.authorAvatarView_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.authorAvatarView_Glasspaint.transform = .identity
            }
        }
        
        onAvatarTap_Glasspaint?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 卡片容器
        contentView.addSubview(cardContainer_Glasspaint)
        cardContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        cardContainer_Glasspaint.layer.cornerRadius = 16
        cardContainer_Glasspaint.layer.shadowColor = UIColor(hexstring_Glasspaint: "#FFB84D").cgColor
        cardContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainer_Glasspaint.layer.shadowRadius = 16
        cardContainer_Glasspaint.layer.shadowOpacity = 0.15
        
        // 媒体视图
        cardContainer_Glasspaint.addSubview(mediaView_Glasspaint)
        mediaView_Glasspaint.layer.cornerRadius = 16
        mediaView_Glasspaint.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 举报按钮
        cardContainer_Glasspaint.addSubview(reportButton_Glasspaint)
        reportButton_Glasspaint.addTarget(self, action: #selector(handleReportTap_Glasspaint), for: .touchUpInside)
        
        // 渐变遮罩（从中间到底部加深）
        mediaView_Glasspaint.layer.addSublayer(gradientOverlay_Glasspaint)
        gradientOverlay_Glasspaint.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradientOverlay_Glasspaint.locations = [0.5, 1.0]
        
        // 闪光效果层
        mediaView_Glasspaint.layer.addSublayer(shimmerLayer_Glasspaint)
        shimmerLayer_Glasspaint.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        shimmerLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer_Glasspaint.locations = [0, 0.5, 1]
        
        // 解锁徽章容器（右上角）
        cardContainer_Glasspaint.addSubview(unlockBadgeContainer_Glasspaint)
        unlockBadgeContainer_Glasspaint.backgroundColor = UIColor(hexstring_Glasspaint: "#FFD700").withAlphaComponent(0.95)
        unlockBadgeContainer_Glasspaint.layer.cornerRadius = 12
        unlockBadgeContainer_Glasspaint.layer.shadowColor = UIColor(hexstring_Glasspaint: "#FFD700").cgColor
        unlockBadgeContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        unlockBadgeContainer_Glasspaint.layer.shadowRadius = 8
        unlockBadgeContainer_Glasspaint.layer.shadowOpacity = 0.4
        
        unlockBadgeContainer_Glasspaint.addSubview(unlockIconView_Glasspaint)
        unlockIconView_Glasspaint.image = UIImage(systemName: "lock.open.fill")
        unlockIconView_Glasspaint.tintColor = .white
        unlockIconView_Glasspaint.contentMode = .scaleAspectFit
        
        unlockBadgeContainer_Glasspaint.addSubview(unlockLabel_Glasspaint)
        unlockLabel_Glasspaint.text = "UNLOCKED"
        unlockLabel_Glasspaint.font = UIFont.systemFont(ofSize: 10, weight: .black)
        unlockLabel_Glasspaint.textColor = .white
        
        // 作者信息容器（叠加在媒体底部）
        cardContainer_Glasspaint.addSubview(authorOverlayContainer_Glasspaint)
        
        // 作者头像
        authorOverlayContainer_Glasspaint.addSubview(authorAvatarView_Glasspaint)
        authorAvatarView_Glasspaint.layer.borderWidth = 2
        authorAvatarView_Glasspaint.layer.borderColor = UIColor(hexstring_Glasspaint: "#FFD700").cgColor
        
        // 作者昵称
        authorOverlayContainer_Glasspaint.addSubview(authorNameLabel_Glasspaint)
        authorNameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        authorNameLabel_Glasspaint.textColor = .white
        authorNameLabel_Glasspaint.shadowColor = UIColor.black.withAlphaComponent(0.5)
        authorNameLabel_Glasspaint.shadowOffset = CGSize(width: 0, height: 1)
        
        // 信息容器
        cardContainer_Glasspaint.addSubview(infoContainer_Glasspaint)
        infoContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        infoContainer_Glasspaint.layer.cornerRadius = 16
        infoContainer_Glasspaint.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        infoContainer_Glasspaint.layer.masksToBounds = true
        
        // 标题容器
        infoContainer_Glasspaint.addSubview(titleContainer_Glasspaint)
        
        titleContainer_Glasspaint.addSubview(capsuleIconView_Glasspaint)
        capsuleIconView_Glasspaint.image = UIImage(systemName: "sparkles")
        capsuleIconView_Glasspaint.tintColor = UIColor(hexstring_Glasspaint: "#FFB84D")
        capsuleIconView_Glasspaint.contentMode = .scaleAspectFit
        
        titleContainer_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.numberOfLines = 2
        
        // 时间信息容器
        infoContainer_Glasspaint.addSubview(timeInfoContainer_Glasspaint)
        timeInfoContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.withAlphaComponent(0.5)
        timeInfoContainer_Glasspaint.layer.cornerRadius = 8
        
        // 创建时间
        timeInfoContainer_Glasspaint.addSubview(createdIconView_Glasspaint)
        createdIconView_Glasspaint.image = UIImage(systemName: "calendar.badge.plus")
        createdIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        createdIconView_Glasspaint.contentMode = .scaleAspectFit
        
        timeInfoContainer_Glasspaint.addSubview(createdLabel_Glasspaint)
        createdLabel_Glasspaint.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        createdLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 解锁时间
        timeInfoContainer_Glasspaint.addSubview(unlockIconView2_Glasspaint)
        unlockIconView2_Glasspaint.image = UIImage(systemName: "clock.badge.checkmark")
        unlockIconView2_Glasspaint.tintColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        unlockIconView2_Glasspaint.contentMode = .scaleAspectFit
        
        timeInfoContainer_Glasspaint.addSubview(unlockDateLabel_Glasspaint)
        unlockDateLabel_Glasspaint.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        unlockDateLabel_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        
        // 底部容器
        infoContainer_Glasspaint.addSubview(bottomContainer_Glasspaint)
        bottomContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.withAlphaComponent(0.3)
        bottomContainer_Glasspaint.layer.cornerRadius = 8
        
        // 查看图标
        bottomContainer_Glasspaint.addSubview(viewIconView_Glasspaint)
        viewIconView_Glasspaint.image = UIImage(systemName: "eye.fill")
        viewIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        viewIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 查看提示
        bottomContainer_Glasspaint.addSubview(viewLabel_Glasspaint)
        viewLabel_Glasspaint.text = "Tap to view"
        viewLabel_Glasspaint.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        viewLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        // 布局
        cardContainer_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        
        mediaView_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(120)
        }
        
        reportButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }
        
        unlockBadgeContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Glasspaint).offset(8)
            make.right.equalTo(mediaView_Glasspaint).offset(-50)
            make.height.equalTo(24)
        }
        
        unlockIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        unlockLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(unlockIconView_Glasspaint.snp.right).offset(4)
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        
        // 作者信息叠加层（在媒体底部）
        authorOverlayContainer_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalTo(mediaView_Glasspaint).inset(8)
            make.bottom.equalTo(mediaView_Glasspaint).offset(-8)
            make.height.equalTo(32)
        }
        
        authorAvatarView_Glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        authorNameLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(authorAvatarView_Glasspaint.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }
        
        infoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Glasspaint.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        titleContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        
        capsuleIconView_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(capsuleIconView_Glasspaint.snp.right).offset(6)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        timeInfoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleContainer_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(24)
        }
        
        createdIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(11)
        }
        
        createdLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(createdIconView_Glasspaint.snp.right).offset(3)
            make.centerY.equalToSuperview()
        }
        
        unlockIconView2_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(createdLabel_Glasspaint.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(11)
        }
        
        unlockDateLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(unlockIconView2_Glasspaint.snp.right).offset(3)
            make.centerY.equalToSuperview()
        }
        
        bottomContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(timeInfoContainer_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(32)
        }
        
        viewIconView_Glasspaint.snp.makeConstraints { make in
            make.right.equalTo(bottomContainer_Glasspaint.snp.centerX).offset(-2)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        viewLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(viewIconView_Glasspaint.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }
    }
    
    /// 设置动画
    private func setupAnimation_Glasspaint() {
        // 添加闪光动画
        let animation_glasspaint = CABasicAnimation(keyPath: "locations")
        animation_glasspaint.fromValue = [-1.0, -0.5, 0.0]
        animation_glasspaint.toValue = [1.0, 1.5, 2.0]
        animation_glasspaint.duration = 2.5
        animation_glasspaint.repeatCount = .infinity
        shimmerLayer_Glasspaint.add(animation_glasspaint, forKey: "shimmer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientOverlay_Glasspaint.frame = mediaView_Glasspaint.bounds
        shimmerLayer_Glasspaint.frame = mediaView_Glasspaint.bounds
    }
    
    @objc private func handleReportTap_Glasspaint() {
        onReport_Glasspaint?()
    }
    
    /// 配置数据
    func configure_Glasspaint(with_glasspaint capsule_glasspaint: TimeCapsulePost_Glasspaint) {
        // 媒体
        if let mediaUrl_glasspaint = capsule_glasspaint.imagePaths_Glasspaint.first {
            mediaView_Glasspaint.configure_Glasspaint(mediaPath_Glasspaint: mediaUrl_glasspaint)
        } else {
            mediaView_Glasspaint.configure_Glasspaint(mediaPath_Glasspaint: nil)
        }
        
        // 作者信息（叠加在媒体底部）
        authorNameLabel_Glasspaint.text = capsule_glasspaint.userName_Glasspaint
        
        // 配置作者头像
        authorAvatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: capsule_glasspaint.userId_Glasspaint)
        
        // 标题
        titleLabel_Glasspaint.text = capsule_glasspaint.title_Glasspaint
        
        // 创建日期
        let createdFormatter_glasspaint = DateFormatter()
        createdFormatter_glasspaint.dateFormat = "MMM d"
        createdLabel_Glasspaint.text = createdFormatter_glasspaint.string(from: capsule_glasspaint.createdDate_Glasspaint)
        
        // 解锁日期
        let unlockFormatter_glasspaint = DateFormatter()
        unlockFormatter_glasspaint.dateFormat = "MMM d, yyyy"
        unlockDateLabel_Glasspaint.text = unlockFormatter_glasspaint.string(from: capsule_glasspaint.unlockDate_Glasspaint)
        
        // 根据解锁状态配置UI
        let isUnlocked_glasspaint = capsule_glasspaint.status_Glasspaint == .unlocked_glasspaint
        
        if isUnlocked_glasspaint {
            // 已解锁状态
            unlockBadgeContainer_Glasspaint.isHidden = false
            unlockBadgeContainer_Glasspaint.backgroundColor = UIColor(hexstring_Glasspaint: "#FFD700").withAlphaComponent(0.95)
            unlockIconView_Glasspaint.image = UIImage(systemName: "lock.open.fill")
            unlockLabel_Glasspaint.text = "UNLOCKED"
            viewLabel_Glasspaint.text = "Tap to view"
            mediaView_Glasspaint.alpha = 1.0
        } else {
            // 未解锁状态
            unlockBadgeContainer_Glasspaint.isHidden = false
            unlockBadgeContainer_Glasspaint.backgroundColor = UIColor.systemGray.withAlphaComponent(0.95)
            unlockIconView_Glasspaint.image = UIImage(systemName: "lock.fill")
            unlockLabel_Glasspaint.text = "LOCKED"
            viewLabel_Glasspaint.text = "Unlock on \(unlockFormatter_glasspaint.string(from: capsule_glasspaint.unlockDate_Glasspaint))"
            mediaView_Glasspaint.alpha = 0.6
        }
    }
}

// MARK: - 时间胶囊详情弹窗

/// 时间胶囊详情弹窗
/// 功能：以弹窗形式展示已解锁的时间胶囊完整内容
class TimeCapsuleDetailViewController_Glasspaint: UIViewController {
    
    private let capsule_Glasspaint: TimeCapsulePost_Glasspaint
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 媒体展示
    private let mediaView_Glasspaint = MediaDisplayView_Glasspaint()
    
    // 标题区域
    private let titleContainer_Glasspaint = UIView()
    private let titleLabel_Glasspaint = UILabel()
    private let unlockBadge_Glasspaint = UIView()
    private let unlockLabel_Glasspaint = UILabel()
    
    // 作者信息
    private let authorContainer_Glasspaint = UIView()
    private let authorAvatar_Glasspaint = UserAvatarView_Glasspaint()
    private let authorLabel_Glasspaint = UILabel()
    private let dateLabel_Glasspaint = UILabel()
    
    // 内容区域
    private let thoughtsContainer_Glasspaint = UIView()
    private let thoughtsTitleLabel_Glasspaint = UILabel()
    private let thoughtsContentLabel_Glasspaint = UILabel()
    
    private let storyContainer_Glasspaint = UIView()
    private let storyTitleLabel_Glasspaint = UILabel()
    private let storyContentLabel_Glasspaint = UILabel()
    
    // 时间线信息
    private let timelineContainer_Glasspaint = UIView()
    private let createdLabel_Glasspaint = UILabel()
    private let unlockedLabel_Glasspaint = UILabel()
    
    init(capsule_glasspaint: TimeCapsulePost_Glasspaint) {
        self.capsule_Glasspaint = capsule_glasspaint
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        configureData_Glasspaint()
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 媒体展示
        contentView_Glasspaint.addSubview(mediaView_Glasspaint)
        mediaView_Glasspaint.layer.cornerRadius = 16
        mediaView_Glasspaint.layer.masksToBounds = true
        
        // 标题容器
        contentView_Glasspaint.addSubview(titleContainer_Glasspaint)
        
        titleContainer_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.numberOfLines = 0
        
        titleContainer_Glasspaint.addSubview(unlockBadge_Glasspaint)
        unlockBadge_Glasspaint.backgroundColor = UIColor(hexstring_Glasspaint: "#FFD700").withAlphaComponent(0.2)
        unlockBadge_Glasspaint.layer.cornerRadius = 12
        
        unlockBadge_Glasspaint.addSubview(unlockLabel_Glasspaint)
        unlockLabel_Glasspaint.text = "🔓 UNLOCKED"
        unlockLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .black)
        unlockLabel_Glasspaint.textColor = UIColor(hexstring_Glasspaint: "#FFD700")
        
        // 作者信息容器
        contentView_Glasspaint.addSubview(authorContainer_Glasspaint)
        authorContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        authorContainer_Glasspaint.layer.cornerRadius = 12
        
        authorContainer_Glasspaint.addSubview(authorAvatar_Glasspaint)
        
        authorContainer_Glasspaint.addSubview(authorLabel_Glasspaint)
        authorLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        authorLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        authorContainer_Glasspaint.addSubview(dateLabel_Glasspaint)
        dateLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 创作心得容器
        contentView_Glasspaint.addSubview(thoughtsContainer_Glasspaint)
        thoughtsContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        thoughtsContainer_Glasspaint.layer.cornerRadius = 12
        
        thoughtsContainer_Glasspaint.addSubview(thoughtsTitleLabel_Glasspaint)
        thoughtsTitleLabel_Glasspaint.text = "💭 Creative Thoughts"
        thoughtsTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        thoughtsTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        thoughtsContainer_Glasspaint.addSubview(thoughtsContentLabel_Glasspaint)
        thoughtsContentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        thoughtsContentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        thoughtsContentLabel_Glasspaint.numberOfLines = 0
        
        // 背后故事容器
        contentView_Glasspaint.addSubview(storyContainer_Glasspaint)
        storyContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        storyContainer_Glasspaint.layer.cornerRadius = 12
        
        storyContainer_Glasspaint.addSubview(storyTitleLabel_Glasspaint)
        storyTitleLabel_Glasspaint.text = "📖 Behind the Story"
        storyTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        storyTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        
        storyContainer_Glasspaint.addSubview(storyContentLabel_Glasspaint)
        storyContentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        storyContentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        storyContentLabel_Glasspaint.numberOfLines = 0
        
        // 时间线容器
        contentView_Glasspaint.addSubview(timelineContainer_Glasspaint)
        timelineContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
        timelineContainer_Glasspaint.layer.cornerRadius = 12
        
        timelineContainer_Glasspaint.addSubview(createdLabel_Glasspaint)
        createdLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        createdLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        createdLabel_Glasspaint.numberOfLines = 0
        
        timelineContainer_Glasspaint.addSubview(unlockedLabel_Glasspaint)
        unlockedLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        unlockedLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        unlockedLabel_Glasspaint.numberOfLines = 0
        
        // 布局
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        mediaView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(250)
        }
        
        titleContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        unlockBadge_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(8)
            make.left.bottom.equalToSuperview()
            make.height.equalTo(28)
        }
        
        unlockLabel_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }
        
        authorContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        authorAvatar_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        authorLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(authorAvatar_Glasspaint.snp.right).offset(12)
            make.top.equalTo(authorAvatar_Glasspaint)
            make.right.equalToSuperview().offset(-12)
        }
        
        dateLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(authorLabel_Glasspaint)
            make.bottom.equalTo(authorAvatar_Glasspaint)
            make.right.equalTo(authorLabel_Glasspaint)
        }
        
        thoughtsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(authorContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        thoughtsTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        thoughtsContentLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(thoughtsTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        
        storyContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(thoughtsContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        storyTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        storyContentLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(storyTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        
        timelineContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(storyContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        createdLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        unlockedLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(createdLabel_Glasspaint.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
    }
    
    /// 配置数据
    private func configureData_Glasspaint() {
        // 媒体
        if let mediaPath_glasspaint = capsule_Glasspaint.imagePaths_Glasspaint.first {
            mediaView_Glasspaint.configure_Glasspaint(mediaPath_Glasspaint: mediaPath_glasspaint)
        }
        
        // 标题
        titleLabel_Glasspaint.text = capsule_Glasspaint.title_Glasspaint
        
        // 作者
        authorLabel_Glasspaint.text = capsule_Glasspaint.userName_Glasspaint
        
        // 配置头像
        authorAvatar_Glasspaint.configure_Glasspaint(userId_Glasspaint: capsule_Glasspaint.userId_Glasspaint)
        
        // 日期
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateStyle = .medium
        dateLabel_Glasspaint.text = "Unlocked on \(formatter_glasspaint.string(from: capsule_Glasspaint.unlockDate_Glasspaint))"
        
        // 创作心得
        thoughtsContentLabel_Glasspaint.text = capsule_Glasspaint.creativeThoughts_Glasspaint
        
        // 背后故事
        storyContentLabel_Glasspaint.text = capsule_Glasspaint.story_Glasspaint
        
        // 时间线
        let createdFormatter_glasspaint = DateFormatter()
        createdFormatter_glasspaint.dateStyle = .long
        createdLabel_Glasspaint.text = "📅 Created: \(createdFormatter_glasspaint.string(from: capsule_Glasspaint.createdDate_Glasspaint))"
        
        let unlockFormatter_glasspaint = DateFormatter()
        unlockFormatter_glasspaint.dateStyle = .long
        unlockedLabel_Glasspaint.text = "🔓 Unlocked: \(unlockFormatter_glasspaint.string(from: capsule_Glasspaint.unlockDate_Glasspaint))"
    }
}

