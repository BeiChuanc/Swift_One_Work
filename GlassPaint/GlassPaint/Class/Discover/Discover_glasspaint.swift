import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页面
/// 功能：展示极简彩绘榜和一器多画轻挑战
/// 特性：分类排行榜、挑战列表、搜索功能
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
    
    /// 搜索按钮
    private let searchButton_Glasspaint = UIButton(type: .system)
    
    // 极简彩绘榜区域
    private let rankingContainer_Glasspaint = UIView()
    private let rankingTitleLabel_Glasspaint = UILabel()
    private let categorySegment_Glasspaint = UISegmentedControl(items: ["Scene", "Carrier", "Style"])
    private let rankingTableView_Glasspaint = UITableView()
    
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
    
    // MARK: - 数据属性
    
    /// 当前排行榜分类
    private var currentCategory_Glasspaint: RankingCategory_Glasspaint = .scene_glasspaint
    
    /// 排行榜作品列表
    private var rankingPosts_Glasspaint: [TitleModel_Glasspaint] = []
    
    /// 挑战列表
    private var challenges_Glasspaint: [ChallengeModel_Glasspaint] = []
    
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
        
        // 排行榜区域
        contentView_Glasspaint.addSubview(rankingContainer_Glasspaint)
        setupRankingSection_Glasspaint()
        
        // 挑战区域
        contentView_Glasspaint.addSubview(challengeContainer_Glasspaint)
        setupChallengeSection_Glasspaint()
        
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
        titleLabel_Glasspaint.text = "🔍 Discover"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 副标题
        titleContainer_glasspaint.addSubview(subtitleLabel_Glasspaint)
        subtitleLabel_Glasspaint.text = "Explore & Challenge"
        subtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        subtitleLabel_Glasspaint.alpha = 0.8
        
        // 搜索按钮容器（添加渐变背景）
        let searchContainer_glasspaint = UIView()
        navContainer_Glasspaint.addSubview(searchContainer_glasspaint)
        searchContainer_glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        searchContainer_glasspaint.layer.cornerRadius = 22
        
        searchContainer_glasspaint.addSubview(searchButton_Glasspaint)
        searchButton_Glasspaint.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        searchButton_Glasspaint.tintColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        searchButton_Glasspaint.addTarget(self, action: #selector(handleSearchTap_Glasspaint), for: .touchUpInside)
        
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
        
        searchContainer_glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        searchButton_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    /// 设置排行榜区域
    private func setupRankingSection_Glasspaint() {
        // 标题容器（添加图标）
        let titleContainer_glasspaint = UIView()
        rankingContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "chart.bar.fill"))
        titleContainer_glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.rankingGoldColor_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        titleContainer_glasspaint.addSubview(rankingTitleLabel_Glasspaint)
        rankingTitleLabel_Glasspaint.text = "Minimalist Ranking"
        rankingTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        rankingTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 分类切换器容器（美化）
        let segmentContainer_glasspaint = UIView()
        rankingContainer_Glasspaint.addSubview(segmentContainer_glasspaint)
        segmentContainer_glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        segmentContainer_glasspaint.layer.cornerRadius = 12
        segmentContainer_glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        segmentContainer_glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentContainer_glasspaint.layer.shadowRadius = 8
        segmentContainer_glasspaint.layer.shadowOpacity = 0.5
        
        segmentContainer_glasspaint.addSubview(categorySegment_Glasspaint)
        categorySegment_Glasspaint.selectedSegmentIndex = 0
        categorySegment_Glasspaint.addTarget(self, action: #selector(handleCategoryChange_Glasspaint), for: .valueChanged)
        
        // 美化分类切换器
        categorySegment_Glasspaint.backgroundColor = .clear
        categorySegment_Glasspaint.selectedSegmentTintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        categorySegment_Glasspaint.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Glasspaint.textSecondary_Glasspaint,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        categorySegment_Glasspaint.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ], for: .selected)
        
        // 表格视图
        rankingContainer_Glasspaint.addSubview(rankingTableView_Glasspaint)
        rankingTableView_Glasspaint.delegate = self
        rankingTableView_Glasspaint.dataSource = self
        rankingTableView_Glasspaint.backgroundColor = .clear
        rankingTableView_Glasspaint.separatorStyle = .none
        rankingTableView_Glasspaint.register(RankingCell_Glasspaint.self, forCellReuseIdentifier: "RankingCell")
        rankingTableView_Glasspaint.isScrollEnabled = false
        
        // 布局
        // 标题容器布局
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        rankingTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(8)
            make.centerY.top.bottom.right.equalToSuperview()
        }
        
        // 分类切换器容器
        segmentContainer_glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(titleContainer_glasspaint.snp.bottom).offset(20)
        }
        
        categorySegment_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
            make.height.equalTo(36)
        }
        
        rankingTableView_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(segmentContainer_glasspaint.snp.bottom).offset(20)
            make.height.equalTo(400) // 固定高度，显示5个
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置挑战区域
    private func setupChallengeSection_Glasspaint() {
        // 标题容器（添加图标）
        let titleContainer_glasspaint = UIView()
        challengeContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "trophy.fill"))
        titleContainer_glasspaint.addSubview(iconView_glasspaint)
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
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        challengeTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(8)
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
        
        rankingContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
        }
        
        challengeContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(rankingContainer_Glasspaint.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-32)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载数据
    private func loadData_Glasspaint() {
        loadRanking_Glasspaint()
        loadChallenges_Glasspaint()
    }
    
    /// 加载排行榜
    private func loadRanking_Glasspaint() {
        rankingPosts_Glasspaint = ChallengeViewModel_Glasspaint.shared_Glasspaint.getRankingByCategory_Glasspaint(
            category_glasspaint: currentCategory_Glasspaint
        )
        
        // 只取前5名
        if rankingPosts_Glasspaint.count > 5 {
            rankingPosts_Glasspaint = Array(rankingPosts_Glasspaint.prefix(5))
        }
        
        rankingTableView_Glasspaint.reloadData()
    }
    
    /// 加载挑战
    private func loadChallenges_Glasspaint() {
        challenges_Glasspaint = ChallengeViewModel_Glasspaint.shared_Glasspaint.getActiveChallenges_Glasspaint()
        challengeCollectionView_Glasspaint.reloadData()
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
    }
    
    @objc private func handleChallengeStateChange_Glasspaint() {
        loadChallenges_Glasspaint()
    }
    
    // MARK: - 交互
    
    @objc private func handleSearchTap_Glasspaint() {
        // 搜索功能（暂未实现）
        Utils_Glasspaint.showInfo_Glasspaint(message_Glasspaint: "Search feature coming soon")
    }
    
    @objc private func handleCategoryChange_Glasspaint() {
        switch categorySegment_Glasspaint.selectedSegmentIndex {
        case 0:
            currentCategory_Glasspaint = .scene_glasspaint
        case 1:
            currentCategory_Glasspaint = .carrier_glasspaint
        case 2:
            currentCategory_Glasspaint = .style_glasspaint
        default:
            break
        }
        
        loadRanking_Glasspaint()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableView Delegate & DataSource

extension Discover_Glasspaint: UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingPosts_Glasspaint.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_glasspaint = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingCell_Glasspaint
        
        let post_glasspaint = rankingPosts_Glasspaint[indexPath.row]
        cell_glasspaint.configure_Glasspaint(with_glasspaint: post_glasspaint, rank_glasspaint: indexPath.row + 1)
        
        return cell_glasspaint
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post_glasspaint = rankingPosts_Glasspaint[indexPath.row]
        Navigation_Glasspaint.toTitleDetail_Glasspaint(titleModel_glasspaint: post_glasspaint)
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension Discover_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challenges_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChallengeCardCell",
            for: indexPath
        ) as! ChallengeCardCell_Glasspaint
        
        let challenge_glasspaint = challenges_Glasspaint[indexPath.item]
        cell_glasspaint.configure_Glasspaint(with_glasspaint: challenge_glasspaint)
        
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let challenge_glasspaint = challenges_Glasspaint[indexPath.item]
        ChallengeViewModel_Glasspaint.shared_Glasspaint.joinChallenge_Glasspaint(challenge_glasspaint: challenge_glasspaint)
    }
}

// MARK: - 排行榜单元格

/// 排行榜单元格
class RankingCell_Glasspaint: UITableViewCell {
    
    private let rankBadge_Glasspaint = UILabel()
    private let artworkImageView_Glasspaint = UIImageView()
    private let titleLabel_Glasspaint = UILabel()
    private let authorLabel_Glasspaint = UILabel()
    private let progressBar_Glasspaint = ReplicationProgressBar_Glasspaint()
    private let statsLabel_Glasspaint = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Glasspaint() {
        backgroundColor = .clear
        selectionStyle = .none
        
        let container_glasspaint = UIView()
        contentView.addSubview(container_glasspaint)
        container_glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        container_glasspaint.layer.cornerRadius = 12
        
        container_glasspaint.addSubview(rankBadge_Glasspaint)
        rankBadge_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        rankBadge_Glasspaint.textAlignment = .center
        
        container_glasspaint.addSubview(artworkImageView_Glasspaint)
        artworkImageView_Glasspaint.contentMode = .scaleAspectFill
        artworkImageView_Glasspaint.layer.cornerRadius = 8
        artworkImageView_Glasspaint.layer.masksToBounds = true
        
        container_glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        container_glasspaint.addSubview(authorLabel_Glasspaint)
        authorLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        authorLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        container_glasspaint.addSubview(progressBar_Glasspaint)
        
        container_glasspaint.addSubview(statsLabel_Glasspaint)
        statsLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        statsLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        container_glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }
        
        rankBadge_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }
        
        artworkImageView_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(rankBadge_Glasspaint.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(artworkImageView_Glasspaint.snp.right).offset(12)
            make.top.equalTo(artworkImageView_Glasspaint).offset(4)
            make.right.equalToSuperview().offset(-12)
        }
        
        authorLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Glasspaint)
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(4)
        }
        
        progressBar_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Glasspaint)
            make.right.equalTo(statsLabel_Glasspaint.snp.left).offset(-8)
            make.bottom.equalTo(artworkImageView_Glasspaint).offset(-4)
            make.height.equalTo(6)
        }
        
        statsLabel_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(progressBar_Glasspaint)
        }
    }
    
    func configure_Glasspaint(with_glasspaint post_glasspaint: TitleModel_Glasspaint, rank_glasspaint: Int) {
        // 排名徽章
        rankBadge_Glasspaint.text = "#\(rank_glasspaint)"
        
        if rank_glasspaint == 1 {
            rankBadge_Glasspaint.textColor = ColorConfig_Glasspaint.rankingGoldColor_Glasspaint
        } else if rank_glasspaint == 2 {
            rankBadge_Glasspaint.textColor = ColorConfig_Glasspaint.rankingSilverColor_Glasspaint
        } else if rank_glasspaint == 3 {
            rankBadge_Glasspaint.textColor = ColorConfig_Glasspaint.rankingBronzeColor_Glasspaint
        } else {
            rankBadge_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        }
        
        // 图片
        if let mediaUrl_glasspaint = post_glasspaint.titleMeidas_Glasspaint.first {
            artworkImageView_Glasspaint.image = UIImage(named: mediaUrl_glasspaint) ?? UIImage(systemName: "photo")
        }
        
        // 标题和作者
        titleLabel_Glasspaint.text = post_glasspaint.title_Glasspaint
        authorLabel_Glasspaint.text = "by \(post_glasspaint.titleUserName_Glasspaint)"
        
        // 复刻率
        progressBar_Glasspaint.setProgress_Glasspaint(progress_glasspaint: post_glasspaint.replicationRate_Glasspaint, animated_glasspaint: false)
        
        // 统计数据
        statsLabel_Glasspaint.text = "❤️ \(post_glasspaint.likes_Glasspaint)"
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
    
    /// 监听滚动，实现导航栏毛玻璃效果
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset_glasspaint = scrollView.contentOffset.y
        let alpha_glasspaint = min(1, max(0, offset_glasspaint / 50))
        navBlurEffect_Glasspaint.alpha = alpha_glasspaint
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
