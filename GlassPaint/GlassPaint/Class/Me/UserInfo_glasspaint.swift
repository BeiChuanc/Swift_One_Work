import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 用户中心（预制用户）

/// 用户中心页面
/// 功能：展示其他用户的个人信息和发布的帖子
/// 设计：现代化、动感、富有创意的个人主页，融入玻璃形态设计
class UserInfo_Glasspaint: UIViewController {
    
    // MARK: - 数据属性
    
    /// 用户模型
    var userModel_Glasspaint: PrewUserModel_Glasspaint?
    
    /// 用户帖子列表
    private var userPosts_Glasspaint: [TitleModel_Glasspaint] = []
    
    /// 是否已关注
    private var isFollowing_Glasspaint: Bool = false
    
    // MARK: - UI组件
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 背景装饰
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    private let decorCircle1_Glasspaint = UIView()
    private let decorCircle2_Glasspaint = UIView()
    private let decorCircle3_Glasspaint = UIView()
    
    // 顶部栏
    private let topBar_Glasspaint = UIView()
    private let backButton_Glasspaint = UIButton(type: .system)
    private let moreButton_Glasspaint = UIButton(type: .system)
    
    // 用户信息卡片
    private let profileCard_Glasspaint = UIView()
    private let profileGradientLayer_Glasspaint = CAGradientLayer()
    private let avatarContainer_Glasspaint = UIView()
    private let avatarView_Glasspaint = UserAvatarView_Glasspaint()
    private let avatarRingLayer_Glasspaint = CAShapeLayer()
    private let userNameLabel_Glasspaint = UILabel()
    private let userBioLabel_Glasspaint = UILabel()
    
    // 统计信息容器
    private let statsContainer_Glasspaint = UIView()
    private let postsStatView_Glasspaint = UIView()
    private let postsCountLabel_Glasspaint = UILabel()
    private let postsTextLabel_Glasspaint = UILabel()
    private let followersStatView_Glasspaint = UIView()
    private let followersCountLabel_Glasspaint = UILabel()
    private let followersTextLabel_Glasspaint = UILabel()
    private let followingStatView_Glasspaint = UIView()
    private let followingCountLabel_Glasspaint = UILabel()
    private let followingTextLabel_Glasspaint = UILabel()
    
    // 操作按钮
    private let actionButtonsContainer_Glasspaint = UIView()
    private let followButton_Glasspaint = UIButton(type: .system)
    private let followButtonGradient_Glasspaint = CAGradientLayer()
    private let messageButton_Glasspaint = UIButton(type: .system)
    
    // 标签容器（显示用户偏好）
    private let tagsContainer_Glasspaint = UIView()
    private let tagsScrollView_Glasspaint = UIScrollView()
    private let tagsStackView_Glasspaint = UIStackView()
    
    // 分隔线
    private let dividerView_Glasspaint = UIView()
    
    // 帖子网格标题
    private let postsHeaderView_Glasspaint = UIView()
    private let postsHeaderLabel_Glasspaint = UILabel()
    private let postsHeaderIcon_Glasspaint = UIImageView()
    
    // 帖子网格
    private let postsCollectionView_Glasspaint: UICollectionView = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .vertical
        layout_glasspaint.minimumLineSpacing = 12
        layout_glasspaint.minimumInteritemSpacing = 12
        let itemWidth_glasspaint = (UIScreen.main.bounds.width - 52) / 2
        layout_glasspaint.itemSize = CGSize(width: itemWidth_glasspaint, height: itemWidth_glasspaint * 1.3)
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        collectionView_glasspaint.showsVerticalScrollIndicator = false
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        collectionView_glasspaint.isScrollEnabled = false
        return collectionView_glasspaint
    }()
    
    // 空状态视图
    private let emptyStateView_Glasspaint = UIView()
    private let emptyIconView_Glasspaint = UIImageView()
    private let emptyTitleLabel_Glasspaint = UILabel()
    private let emptySubtitleLabel_Glasspaint = UILabel()
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        loadData_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
        profileGradientLayer_Glasspaint.frame = profileCard_Glasspaint.bounds
        followButtonGradient_Glasspaint.frame = followButton_Glasspaint.bounds
        updateAvatarRing_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变和装饰
        setupBackground_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 顶部栏
        view.addSubview(topBar_Glasspaint)
        setupTopBar_Glasspaint()
        
        // 用户信息卡片
        contentView_Glasspaint.addSubview(profileCard_Glasspaint)
        setupProfileCard_Glasspaint()
        
        // 统计信息
        contentView_Glasspaint.addSubview(statsContainer_Glasspaint)
        setupStatsContainer_Glasspaint()
        
        // 操作按钮
        contentView_Glasspaint.addSubview(actionButtonsContainer_Glasspaint)
        setupActionButtons_Glasspaint()
        
        // 标签容器
        contentView_Glasspaint.addSubview(tagsContainer_Glasspaint)
        setupTagsContainer_Glasspaint()
        
        // 分隔线
        contentView_Glasspaint.addSubview(dividerView_Glasspaint)
        dividerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.divider_Glasspaint
        
        // 帖子标题
        contentView_Glasspaint.addSubview(postsHeaderView_Glasspaint)
        setupPostsHeader_Glasspaint()
        
        // 帖子网格
        contentView_Glasspaint.addSubview(postsCollectionView_Glasspaint)
        setupPostsCollection_Glasspaint()
        
        // 空状态
        contentView_Glasspaint.addSubview(emptyStateView_Glasspaint)
        setupEmptyState_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
    }
    
    /// 设置背景和装饰
    private func setupBackground_Glasspaint() {
        // 背景渐变
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            UIColor(hexstring_Glasspaint: "#EDF2F7").cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0, 1]
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
        
        // 装饰圆圈1 - 左上角
        view.addSubview(decorCircle1_Glasspaint)
        decorCircle1_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08)
        decorCircle1_Glasspaint.layer.cornerRadius = 100
        
        // 装饰圆圈2 - 右上角
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientEnd_Glasspaint.withAlphaComponent(0.06)
        decorCircle2_Glasspaint.layer.cornerRadius = 80
        
        // 装饰圆圈3 - 中间偏右
        view.addSubview(decorCircle3_Glasspaint)
        decorCircle3_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.05)
        decorCircle3_Glasspaint.layer.cornerRadius = 60
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.left.equalToSuperview().offset(-50)
            make.top.equalToSuperview().offset(-50)
        }
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.right.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(100)
        }
        
        decorCircle3_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.right.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(350)
        }
    }
    
    /// 设置顶部栏
    private func setupTopBar_Glasspaint() {
        topBar_Glasspaint.backgroundColor = .clear
        
        // 返回按钮
        topBar_Glasspaint.addSubview(backButton_Glasspaint)
        let backConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        backButton_Glasspaint.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig_glasspaint), for: .normal)
        backButton_Glasspaint.tintColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        backButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint.withAlphaComponent(0.9)
        backButton_Glasspaint.layer.cornerRadius = 20
        backButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        backButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton_Glasspaint.layer.shadowRadius = 8
        backButton_Glasspaint.layer.shadowOpacity = 0.15
        backButton_Glasspaint.addTarget(self, action: #selector(handleBackTap_Glasspaint), for: .touchUpInside)
        
        // 更多按钮
        topBar_Glasspaint.addSubview(moreButton_Glasspaint)
        let moreConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        moreButton_Glasspaint.setImage(UIImage(systemName: "ellipsis", withConfiguration: moreConfig_glasspaint), for: .normal)
        moreButton_Glasspaint.tintColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        moreButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint.withAlphaComponent(0.9)
        moreButton_Glasspaint.layer.cornerRadius = 20
        moreButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        moreButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        moreButton_Glasspaint.layer.shadowRadius = 8
        moreButton_Glasspaint.layer.shadowOpacity = 0.15
        moreButton_Glasspaint.addTarget(self, action: #selector(handleMoreTap_Glasspaint), for: .touchUpInside)
        
        backButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        moreButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    /// 设置用户信息卡片
    private func setupProfileCard_Glasspaint() {
        profileCard_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        profileCard_Glasspaint.layer.cornerRadius = 24
        profileCard_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        profileCard_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        profileCard_Glasspaint.layer.shadowRadius = 16
        profileCard_Glasspaint.layer.shadowOpacity = 0.12
        
        // 渐变背景
        profileGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.05).cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.02).cgColor
        ]
        profileGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        profileGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        profileCard_Glasspaint.layer.insertSublayer(profileGradientLayer_Glasspaint, at: 0)
        
        // 头像容器
        profileCard_Glasspaint.addSubview(avatarContainer_Glasspaint)
        avatarContainer_Glasspaint.addSubview(avatarView_Glasspaint)
        
        // 头像环形边框
        avatarRingLayer_Glasspaint.fillColor = UIColor.clear.cgColor
        avatarRingLayer_Glasspaint.strokeColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        avatarRingLayer_Glasspaint.lineWidth = 3
        avatarContainer_Glasspaint.layer.addSublayer(avatarRingLayer_Glasspaint)
        
        // 用户名
        profileCard_Glasspaint.addSubview(userNameLabel_Glasspaint)
        userNameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        userNameLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        userNameLabel_Glasspaint.textAlignment = .center
        
        // 用户简介
        profileCard_Glasspaint.addSubview(userBioLabel_Glasspaint)
        userBioLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        userBioLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        userBioLabel_Glasspaint.textAlignment = .center
        userBioLabel_Glasspaint.numberOfLines = 2
        
        avatarContainer_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(100)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(92)
        }
        
        userNameLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        userBioLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    /// 更新头像环形边框
    private func updateAvatarRing_Glasspaint() {
        let ringPath_glasspaint = UIBezierPath(
            arcCenter: CGPoint(x: avatarContainer_Glasspaint.bounds.midX, y: avatarContainer_Glasspaint.bounds.midY),
            radius: 50,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        avatarRingLayer_Glasspaint.path = ringPath_glasspaint.cgPath
    }
    
    /// 设置统计信息容器
    private func setupStatsContainer_Glasspaint() {
        statsContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        statsContainer_Glasspaint.layer.cornerRadius = 20
        statsContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        statsContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsContainer_Glasspaint.layer.shadowRadius = 12
        statsContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // 帖子统计
        statsContainer_Glasspaint.addSubview(postsStatView_Glasspaint)
        setupStatView_Glasspaint(
            container_glasspaint: postsStatView_Glasspaint,
            countLabel_glasspaint: postsCountLabel_Glasspaint,
            textLabel_glasspaint: postsTextLabel_Glasspaint,
            text_glasspaint: "Posts"
        )
        
        // 粉丝统计
        statsContainer_Glasspaint.addSubview(followersStatView_Glasspaint)
        setupStatView_Glasspaint(
            container_glasspaint: followersStatView_Glasspaint,
            countLabel_glasspaint: followersCountLabel_Glasspaint,
            textLabel_glasspaint: followersTextLabel_Glasspaint,
            text_glasspaint: "Followers"
        )
        
        // 关注统计
        statsContainer_Glasspaint.addSubview(followingStatView_Glasspaint)
        setupStatView_Glasspaint(
            container_glasspaint: followingStatView_Glasspaint,
            countLabel_glasspaint: followingCountLabel_Glasspaint,
            textLabel_glasspaint: followingTextLabel_Glasspaint,
            text_glasspaint: "Following"
        )
        
        postsStatView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview().inset(16)
            make.width.equalTo(followersStatView_Glasspaint)
        }
        
        followersStatView_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(postsStatView_Glasspaint.snp.right).offset(12)
            make.top.bottom.equalToSuperview().inset(16)
            make.width.equalTo(followingStatView_Glasspaint)
        }
        
        followingStatView_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(followersStatView_Glasspaint.snp.right).offset(12)
            make.right.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview().inset(16)
        }
    }
    
    /// 设置单个统计视图
    private func setupStatView_Glasspaint(
        container_glasspaint: UIView,
        countLabel_glasspaint: UILabel,
        textLabel_glasspaint: UILabel,
        text_glasspaint: String
    ) {
        container_glasspaint.addSubview(countLabel_glasspaint)
        container_glasspaint.addSubview(textLabel_glasspaint)
        
        countLabel_glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        countLabel_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        countLabel_glasspaint.textAlignment = .center
        countLabel_glasspaint.text = "0"
        
        textLabel_glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        textLabel_glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        textLabel_glasspaint.textAlignment = .center
        textLabel_glasspaint.text = text_glasspaint
        
        countLabel_glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        textLabel_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(countLabel_glasspaint.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置操作按钮
    private func setupActionButtons_Glasspaint() {
        // 关注按钮
        actionButtonsContainer_Glasspaint.addSubview(followButton_Glasspaint)
        followButton_Glasspaint.setTitle("Follow", for: .normal)
        followButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        followButton_Glasspaint.setTitleColor(.white, for: .normal)
        followButton_Glasspaint.layer.cornerRadius = 24
        followButton_Glasspaint.layer.masksToBounds = true
        followButton_Glasspaint.addTarget(self, action: #selector(handleFollowTap_Glasspaint), for: .touchUpInside)
        
        // 关注按钮渐变
        followButtonGradient_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor
        ]
        followButtonGradient_Glasspaint.startPoint = CGPoint(x: 0, y: 0.5)
        followButtonGradient_Glasspaint.endPoint = CGPoint(x: 1, y: 0.5)
        followButton_Glasspaint.layer.insertSublayer(followButtonGradient_Glasspaint, at: 0)
        
        // 消息按钮
        actionButtonsContainer_Glasspaint.addSubview(messageButton_Glasspaint)
        let messageConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        messageButton_Glasspaint.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: messageConfig_glasspaint), for: .normal)
        messageButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        messageButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        messageButton_Glasspaint.layer.cornerRadius = 24
        messageButton_Glasspaint.layer.borderWidth = 2
        messageButton_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        messageButton_Glasspaint.addTarget(self, action: #selector(handleMessageTap_Glasspaint), for: .touchUpInside)
        
        followButton_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(messageButton_Glasspaint.snp.left).offset(-12)
            make.height.equalTo(48)
        }
        
        messageButton_Glasspaint.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(48)
        }
    }
    
    /// 设置标签容器
    private func setupTagsContainer_Glasspaint() {
        tagsContainer_Glasspaint.addSubview(tagsScrollView_Glasspaint)
        tagsScrollView_Glasspaint.showsHorizontalScrollIndicator = false
        tagsScrollView_Glasspaint.addSubview(tagsStackView_Glasspaint)
        
        tagsStackView_Glasspaint.axis = .horizontal
        tagsStackView_Glasspaint.spacing = 8
        tagsStackView_Glasspaint.alignment = .center
        
        tagsScrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tagsStackView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    /// 设置帖子标题
    private func setupPostsHeader_Glasspaint() {
        postsHeaderView_Glasspaint.addSubview(postsHeaderIcon_Glasspaint)
        postsHeaderView_Glasspaint.addSubview(postsHeaderLabel_Glasspaint)
        
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        postsHeaderIcon_Glasspaint.image = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: iconConfig_glasspaint)
        postsHeaderIcon_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        postsHeaderIcon_Glasspaint.contentMode = .scaleAspectFit
        
        postsHeaderLabel_Glasspaint.text = "Gallery"
        postsHeaderLabel_Glasspaint.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        postsHeaderLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        postsHeaderIcon_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        postsHeaderLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(postsHeaderIcon_Glasspaint.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 设置帖子网格
    private func setupPostsCollection_Glasspaint() {
        postsCollectionView_Glasspaint.delegate = self
        postsCollectionView_Glasspaint.dataSource = self
        postsCollectionView_Glasspaint.register(UserPostCell_Glasspaint.self, forCellWithReuseIdentifier: "UserPostCell")
    }
    
    /// 设置空状态
    private func setupEmptyState_Glasspaint() {
        emptyStateView_Glasspaint.isHidden = true
        emptyStateView_Glasspaint.addSubview(emptyIconView_Glasspaint)
        emptyStateView_Glasspaint.addSubview(emptyTitleLabel_Glasspaint)
        emptyStateView_Glasspaint.addSubview(emptySubtitleLabel_Glasspaint)
        
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        emptyIconView_Glasspaint.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: iconConfig_glasspaint)
        emptyIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.4)
        emptyIconView_Glasspaint.contentMode = .scaleAspectFit
        
        emptyTitleLabel_Glasspaint.text = "No Posts Yet"
        emptyTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        emptyTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        emptyTitleLabel_Glasspaint.textAlignment = .center
        
        emptySubtitleLabel_Glasspaint.text = "This user hasn't shared\nany posts yet"
        emptySubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        emptySubtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPlaceholder_Glasspaint
        emptySubtitleLabel_Glasspaint.textAlignment = .center
        emptySubtitleLabel_Glasspaint.numberOfLines = 2
        
        emptyIconView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(60)
            make.width.height.equalTo(100)
        }
        
        emptyTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        emptySubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(30)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        topBar_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        profileCard_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.left.right.equalToSuperview().inset(20)
        }
        
        statsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(profileCard_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        actionButtonsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(statsContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        tagsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(actionButtonsContainer_Glasspaint.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        dividerView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(tagsContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        postsHeaderView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Glasspaint.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        postsCollectionView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(postsHeaderView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        emptyStateView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(postsHeaderView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载数据
    private func loadData_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint else { return }
        
        // 更新用户信息
        if let userId_glasspaint = user_glasspaint.userId_Glasspaint {
            avatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: userId_glasspaint)
        }
        userNameLabel_Glasspaint.text = user_glasspaint.userName_Glasspaint
        userBioLabel_Glasspaint.text = user_glasspaint.userIntroduce_Glasspaint ?? "Glass painting enthusiast"
        
        // 获取用户帖子（从TitleViewModel获取，确保已举报的帖子被过滤）
        userPosts_Glasspaint = TitleViewModel_Glasspaint.shared_Glasspaint.getUserPosts_Glasspaint(user_glasspaint: user_glasspaint)
        
        // 更新统计
        postsCountLabel_Glasspaint.text = "\(userPosts_Glasspaint.count)"
        followersCountLabel_Glasspaint.text = "\(user_glasspaint.userFans_Glasspaint ?? 0)"
        followingCountLabel_Glasspaint.text = "\(user_glasspaint.userFollow_Glasspaint ?? 0)"
        
        // 更新关注状态
        updateFollowState_Glasspaint()
        
        // 添加标签
        addUserTags_Glasspaint()
        
        // 刷新列表
        updatePostsDisplay_Glasspaint()
    }
    
    /// 更新关注状态
    private func updateFollowState_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint else { return }
        isFollowing_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.isFollowing_Glasspaint(user_glasspaint: user_glasspaint)
        
        UIView.animate(withDuration: 0.3) {
            if self.isFollowing_Glasspaint {
                self.followButton_Glasspaint.setTitle("Followed", for: .normal)
                self.followButton_Glasspaint.alpha = 0.7
            } else {
                self.followButton_Glasspaint.setTitle("Follow", for: .normal)
                self.followButton_Glasspaint.alpha = 1.0
            }
        }
    }
    
    /// 添加用户标签
    private func addUserTags_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint else { return }
        
        // 清空现有标签
        tagsStackView_Glasspaint.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 添加等级标签
        if let level_glasspaint = user_glasspaint.paintingLevel_Glasspaint {
            let levelColor_glasspaint: UIColor
            switch level_glasspaint {
            case .beginner_glasspaint:
                levelColor_glasspaint = ColorConfig_Glasspaint.levelBeginnerColor_Glasspaint
            case .intermediate_glasspaint:
                levelColor_glasspaint = ColorConfig_Glasspaint.levelIntermediateColor_Glasspaint
            case .advanced_glasspaint:
                levelColor_glasspaint = ColorConfig_Glasspaint.levelAdvancedColor_Glasspaint
            }
            
            let levelTag_glasspaint = createTag_Glasspaint(
                text_glasspaint: level_glasspaint.rawValue,
                color_glasspaint: levelColor_glasspaint
            )
            tagsStackView_Glasspaint.addArrangedSubview(levelTag_glasspaint)
        }
        
        // 添加风格标签
        if let styles_glasspaint = user_glasspaint.preferredStyles_Glasspaint, !styles_glasspaint.isEmpty {
            for style_glasspaint in styles_glasspaint.prefix(3) {
                let styleColor_glasspaint: UIColor
                switch style_glasspaint {
                case .minimalist_glasspaint:
                    styleColor_glasspaint = ColorConfig_Glasspaint.styleMinimalistColor_Glasspaint
                case .retro_glasspaint:
                    styleColor_glasspaint = ColorConfig_Glasspaint.styleRetroColor_Glasspaint
                case .cute_glasspaint:
                    styleColor_glasspaint = ColorConfig_Glasspaint.styleCuteColor_Glasspaint
                case .modern_glasspaint:
                    styleColor_glasspaint = ColorConfig_Glasspaint.styleModernColor_Glasspaint
                case .artistic_glasspaint:
                    styleColor_glasspaint = ColorConfig_Glasspaint.styleArtisticColor_Glasspaint
                }
                
                let styleTag_glasspaint = createTag_Glasspaint(
                    text_glasspaint: style_glasspaint.rawValue,
                    color_glasspaint: styleColor_glasspaint
                )
                tagsStackView_Glasspaint.addArrangedSubview(styleTag_glasspaint)
            }
        }
    }
    
    /// 创建标签
    private func createTag_Glasspaint(text_glasspaint: String, color_glasspaint: UIColor) -> UIView {
        let container_glasspaint = UIView()
        container_glasspaint.backgroundColor = color_glasspaint.withAlphaComponent(0.15)
        container_glasspaint.layer.cornerRadius = 12
        
        let label_glasspaint = UILabel()
        label_glasspaint.text = text_glasspaint
        label_glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_glasspaint.textColor = color_glasspaint
        
        container_glasspaint.addSubview(label_glasspaint)
        label_glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }
        
        return container_glasspaint
    }
    
    /// 更新帖子显示
    private func updatePostsDisplay_Glasspaint() {
        if userPosts_Glasspaint.isEmpty {
            postsCollectionView_Glasspaint.isHidden = true
            emptyStateView_Glasspaint.isHidden = false
        } else {
            postsCollectionView_Glasspaint.isHidden = false
            emptyStateView_Glasspaint.isHidden = true
            
            // 更新CollectionView高度
            let itemWidth_glasspaint = (UIScreen.main.bounds.width - 54) / 2
            let itemHeight_glasspaint = itemWidth_glasspaint * 1.3
            let rows_glasspaint = ceil(Double(userPosts_Glasspaint.count) / 2.0)
            let totalHeight_glasspaint = CGFloat(rows_glasspaint) * itemHeight_glasspaint + CGFloat(rows_glasspaint - 1) * 12 + 20
            
            postsCollectionView_Glasspaint.snp.updateConstraints { make in
                make.height.equalTo(totalHeight_glasspaint)
            }
        }
        
        postsCollectionView_Glasspaint.reloadData()
    }
    
    // MARK: - 事件处理
    
    /// 处理返回按钮
    @objc private func handleBackTap_Glasspaint() {
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .light)
        generator_glasspaint.impactOccurred()
        
        // 动画
        UIView.animate(withDuration: 0.1, animations: {
            self.backButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.backButton_Glasspaint.transform = .identity
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    /// 处理更多按钮
    @objc private func handleMoreTap_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint else { return }
        
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 动画
        UIView.animate(withDuration: 0.1, animations: {
            self.moreButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.moreButton_Glasspaint.transform = .identity
            }
        }
        
        // 显示操作菜单
        ReportDeleteHelper_Glasspaint.block_Glasspaint(
            user_Glasspaint: user_glasspaint,
            from: self
        ) {
            // 拉黑后返回上一页
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 处理关注按钮
    @objc private func handleFollowTap_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint else { return }
        
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 动画
        UIView.animate(withDuration: 0.2, animations: {
            self.followButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.followButton_Glasspaint.transform = .identity
            }
        }
        
        // 记录关注前的状态
        let wasFollowing_glasspaint = isFollowing_Glasspaint
        
        // 切换关注状态
        UserViewModel_Glasspaint.shared_Glasspaint.followUser_Glasspaint(user_glasspaint: user_glasspaint)
        updateFollowState_Glasspaint()
        
        // 更新粉丝数（根据之前的状态判断）
        if !wasFollowing_glasspaint && isFollowing_Glasspaint {
            // 从未关注变为关注，粉丝数+1
            if let currentCount_glasspaint = Int(followersCountLabel_Glasspaint.text ?? "0") {
                followersCountLabel_Glasspaint.text = "\(currentCount_glasspaint + 1)"
            }
        } else if wasFollowing_glasspaint && !isFollowing_Glasspaint {
            // 从关注变为未关注，粉丝数-1
            if let currentCount_glasspaint = Int(followersCountLabel_Glasspaint.text ?? "0"), currentCount_glasspaint > 0 {
                followersCountLabel_Glasspaint.text = "\(currentCount_glasspaint - 1)"
            }
        }
    }
    
    /// 处理消息按钮
    @objc private func handleMessageTap_Glasspaint() {
        guard let user_glasspaint = userModel_Glasspaint else { return }
        
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 动画
        UIView.animate(withDuration: 0.2, animations: {
            self.messageButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.messageButton_Glasspaint.transform = .identity
            }
        }
        
        // 使用Navigation跳转到聊天页面
        Navigation_Glasspaint.toMessageUser_Glasspaint(
            with: user_glasspaint,
            style_glasspaint: .replace_glasspaint
        )
    }
    
    /// 打开帖子详情
    private func openPostDetail_Glasspaint(_ post_glasspaint: TitleModel_Glasspaint) {
        let detailVC_glasspaint = Detail_Glasspaint()
        detailVC_glasspaint.titleModel_Glasspaint = post_glasspaint
        detailVC_glasspaint.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC_glasspaint, animated: true)
    }
}

// MARK: - UICollectionView代理

extension UserInfo_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPostCell", for: indexPath) as! UserPostCell_Glasspaint
        let post_glasspaint = userPosts_Glasspaint[indexPath.item]
        cell_glasspaint.configure_Glasspaint(with: post_glasspaint)
        
        // 设置举报回调
        cell_glasspaint.onReport_Glasspaint = { [weak self] in
            guard let self = self else { return }
            ReportDeleteHelper_Glasspaint.report_Glasspaint(
                post_Glasspaint: post_glasspaint,
                from: self
            ) {
                // 举报成功后重新加载数据
                self.loadData_Glasspaint()
            }
        }
        
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_glasspaint = userPosts_Glasspaint[indexPath.item]
        
        // 选中动画
        if let cell_glasspaint = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell_glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell_glasspaint.transform = .identity
                }
            }
        }
        
        openPostDetail_Glasspaint(post_glasspaint)
    }
}

// MARK: - 用户帖子Cell

/// 用户帖子Cell
/// 设计：简洁卡片式布局，展示媒体和基本信息
class UserPostCell_Glasspaint: UICollectionViewCell {
    
    private let containerView_Glasspaint = UIView()
    private let mediaImageView_Glasspaint = UIImageView()
    private let overlayGradient_Glasspaint = CAGradientLayer()
    private let likeIconView_Glasspaint = UIImageView()
    private let likeCountLabel_Glasspaint = UILabel()
    private let reportButton_Glasspaint = UIButton(type: .system)
    
    var onReport_Glasspaint: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mediaImageView_Glasspaint.image = nil
        onReport_Glasspaint = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayGradient_Glasspaint.frame = mediaImageView_Glasspaint.bounds
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        contentView.addSubview(containerView_Glasspaint)
        containerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        containerView_Glasspaint.layer.cornerRadius = 16
        containerView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        containerView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView_Glasspaint.layer.shadowRadius = 8
        containerView_Glasspaint.layer.shadowOpacity = 0.1
        
        // 媒体图片
        containerView_Glasspaint.addSubview(mediaImageView_Glasspaint)
        mediaImageView_Glasspaint.contentMode = .scaleAspectFill
        mediaImageView_Glasspaint.layer.cornerRadius = 16
        mediaImageView_Glasspaint.clipsToBounds = true
        mediaImageView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
        
        // 渐变遮罩
        overlayGradient_Glasspaint.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        overlayGradient_Glasspaint.locations = [0.5, 1.0]
        mediaImageView_Glasspaint.layer.addSublayer(overlayGradient_Glasspaint)
        
        // 喜欢图标
        containerView_Glasspaint.addSubview(likeIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        likeIconView_Glasspaint.image = UIImage(systemName: "heart.fill", withConfiguration: iconConfig_glasspaint)
        likeIconView_Glasspaint.tintColor = UIColor.systemPink
        likeIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 喜欢数
        containerView_Glasspaint.addSubview(likeCountLabel_Glasspaint)
        likeCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        likeCountLabel_Glasspaint.textColor = .white
        likeCountLabel_Glasspaint.shadowColor = UIColor.black.withAlphaComponent(0.3)
        likeCountLabel_Glasspaint.shadowOffset = CGSize(width: 0, height: 1)
        
        // 举报按钮
        containerView_Glasspaint.addSubview(reportButton_Glasspaint)
        let reportConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        reportButton_Glasspaint.setImage(UIImage(systemName: "ellipsis", withConfiguration: reportConfig_glasspaint), for: .normal)
        reportButton_Glasspaint.tintColor = .white
        reportButton_Glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        reportButton_Glasspaint.layer.cornerRadius = 14
        reportButton_Glasspaint.addTarget(self, action: #selector(handleReportTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        containerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mediaImageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        likeIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(14)
        }
        
        likeCountLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(likeIconView_Glasspaint.snp.right).offset(5)
            make.centerY.equalTo(likeIconView_Glasspaint)
        }
        
        reportButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8)
            make.width.height.equalTo(28)
        }
    }
    
    /// 处理举报按钮点击
    @objc private func handleReportTap_Glasspaint() {
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self.reportButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.reportButton_Glasspaint.transform = .identity
            }
        }
        
        onReport_Glasspaint?()
    }
    
    /// 配置Cell
    func configure_Glasspaint(with post_glasspaint: TitleModel_Glasspaint) {
        likeCountLabel_Glasspaint.text = "\(post_glasspaint.likes_Glasspaint)"
        
        // 加载媒体
        if !post_glasspaint.titleMeidas_Glasspaint.isEmpty {
            let mediaPath_glasspaint = post_glasspaint.titleMeidas_Glasspaint[0]
            
            if mediaPath_glasspaint.hasPrefix("http") {
                if let url_glasspaint = URL(string: mediaPath_glasspaint) {
                    mediaImageView_Glasspaint.kf.setImage(
                        with: url_glasspaint,
                        placeholder: UIImage(systemName: "photo"),
                        options: [.transition(.fade(0.2))]
                    )
                }
            } else if let localImage_glasspaint = UIImage(contentsOfFile: mediaPath_glasspaint) {
                mediaImageView_Glasspaint.image = localImage_glasspaint
            } else if let assetImage_glasspaint = UIImage(named: mediaPath_glasspaint) {
                mediaImageView_Glasspaint.image = assetImage_glasspaint
            } else {
                let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
                mediaImageView_Glasspaint.image = UIImage(systemName: "photo", withConfiguration: config_glasspaint)
                mediaImageView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.3)
            }
        }
    }
}

