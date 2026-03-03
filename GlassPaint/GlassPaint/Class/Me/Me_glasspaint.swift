import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 我的

/// 我的页面
/// 功能：展示用户信息、发布的帖子和喜欢的帖子
/// 设计：现代化个人主页，支持切换帖子/喜欢列表，参考首页和发现页的现代化布局
class Me_Glasspaint: UIViewController {
    
    // MARK: - 数据属性
    
    var meModel_Glasspaint: LoginUserModel_Glasspaint?
    
    /// 内容类型（0=发布的帖子，1=喜欢的帖子）
    private var currentContentType_Glasspaint: Int = 0
    
    /// 发布的帖子列表
    private var myPosts_Glasspaint: [TitleModel_Glasspaint] = []
    
    /// 喜欢的帖子列表
    private var likedPosts_Glasspaint: [TitleModel_Glasspaint] = []
    
    // MARK: - UI组件
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 背景装饰
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    private let decorCircle1_Glasspaint = UIView()
    private let decorCircle2_Glasspaint = UIView()
    
    // 导航栏
    private let navContainer_Glasspaint = UIView()
    private let navBlurEffect_Glasspaint = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let titleLabel_Glasspaint = UILabel()
    private let subtitleLabel_Glasspaint = UILabel()
    private let settingButton_Glasspaint = UIButton(type: .system)
    
    // 用户信息卡片
    private let userInfoCard_Glasspaint = UIView()
    private let userInfoGradientLayer_Glasspaint = CAGradientLayer()
    private let avatarView_Glasspaint = CurrentUserAvatarView_Glasspaint()
    private let editInfoButton_Glasspaint = UIButton(type: .system)
    private let userNameLabel_Glasspaint = UILabel()
    private let userBioLabel_Glasspaint = UILabel()
    private let statsContainer_Glasspaint = UIView()
    private let postsCountLabel_Glasspaint = UILabel()
    private let postsTextLabel_Glasspaint = UILabel()
    private let likesCountLabel_Glasspaint = UILabel()
    private let likesTextLabel_Glasspaint = UILabel()
    private let followsCountLabel_Glasspaint = UILabel()
    private let followsTextLabel_Glasspaint = UILabel()
    
    // 内容区域
    private let contentTypeSegment_Glasspaint: UISegmentedControl = {
        let segment_glasspaint = UISegmentedControl(items: ["My Posts", "Liked"])
        segment_glasspaint.selectedSegmentIndex = 0
        return segment_glasspaint
    }()
    
    private let postsCollectionView_Glasspaint: UICollectionView = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .vertical
        layout_glasspaint.minimumLineSpacing = 16
        layout_glasspaint.minimumInteritemSpacing = 14
        let itemWidth_glasspaint = (UIScreen.main.bounds.width - 54) / 2
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
        loadData_Glasspaint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupNotifications_Glasspaint()
        loadData_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
        userInfoGradientLayer_Glasspaint.frame = userInfoCard_Glasspaint.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        scrollView_Glasspaint.delegate = self
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 导航栏
        contentView_Glasspaint.addSubview(navContainer_Glasspaint)
        setupNavigationBar_Glasspaint()
        
        // 用户信息卡片
        contentView_Glasspaint.addSubview(userInfoCard_Glasspaint)
        setupUserInfoCard_Glasspaint()
        
        // 内容类型切换
        contentView_Glasspaint.addSubview(contentTypeSegment_Glasspaint)
        setupSegmentControl_Glasspaint()
        
        // 帖子列表
        contentView_Glasspaint.addSubview(postsCollectionView_Glasspaint)
        setupPostsCollection_Glasspaint()
        
        // 空状态视图
        contentView_Glasspaint.addSubview(emptyStateView_Glasspaint)
        setupEmptyState_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
    }
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            UIColor(hexstring_Glasspaint: "#F0F4F8").cgColor,
            ColorConfig_Glasspaint.backgroundSecondary_Glasspaint.cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        // 装饰圆圈1
        view.addSubview(decorCircle1_Glasspaint)
        decorCircle1_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08)
        decorCircle1_Glasspaint.layer.cornerRadius = 150
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-80)
            make.right.equalToSuperview().offset(80)
            make.width.height.equalTo(300)
        }
        
        // 装饰圆圈2
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.06)
        decorCircle2_Glasspaint.layer.cornerRadius = 120
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(-60)
            make.width.height.equalTo(240)
        }
        
        // 旋转动画
        let rotation1_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation1_glasspaint.fromValue = 0
        rotation1_glasspaint.toValue = Double.pi * 2
        rotation1_glasspaint.duration = 60
        rotation1_glasspaint.repeatCount = .infinity
        decorCircle1_Glasspaint.layer.add(rotation1_glasspaint, forKey: "rotation1")
        
        let rotation2_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation2_glasspaint.fromValue = 0
        rotation2_glasspaint.toValue = -Double.pi * 2
        rotation2_glasspaint.duration = 80
        rotation2_glasspaint.repeatCount = .infinity
        decorCircle2_Glasspaint.layer.add(rotation2_glasspaint, forKey: "rotation2")
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
        titleLabel_Glasspaint.text = "👤 Profile"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 副标题
        titleContainer_glasspaint.addSubview(subtitleLabel_Glasspaint)
        subtitleLabel_Glasspaint.text = "Your Creative Space"
        subtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        subtitleLabel_Glasspaint.alpha = 0.8
        
        // 设置按钮
        navContainer_Glasspaint.addSubview(settingButton_Glasspaint)
        let settingConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        settingButton_Glasspaint.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: settingConfig_glasspaint), for: .normal)
        settingButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        settingButton_Glasspaint.addTarget(self, action: #selector(handleSettingTap_Glasspaint), for: .touchUpInside)
        
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
            make.left.right.bottom.equalToSuperview()
        }
        
        settingButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置用户信息卡片
    private func setupUserInfoCard_Glasspaint() {
        userInfoCard_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        userInfoCard_Glasspaint.layer.cornerRadius = 24
        userInfoCard_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        userInfoCard_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        userInfoCard_Glasspaint.layer.shadowRadius = 16
        userInfoCard_Glasspaint.layer.shadowOpacity = 0.12
        
        // 渐变背景
        userInfoGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1).cgColor,
            ColorConfig_Glasspaint.cardBackground_Glasspaint.cgColor
        ]
        userInfoGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        userInfoGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        userInfoGradientLayer_Glasspaint.cornerRadius = 24
        userInfoCard_Glasspaint.layer.insertSublayer(userInfoGradientLayer_Glasspaint, at: 0)
        
        // 头像
        userInfoCard_Glasspaint.addSubview(avatarView_Glasspaint)
        avatarView_Glasspaint.showEditButton_Glasspaint = true
        avatarView_Glasspaint.layer.masksToBounds = true
        avatarView_Glasspaint.layer.borderWidth = 3
        avatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        // 编辑信息按钮
        userInfoCard_Glasspaint.addSubview(editInfoButton_Glasspaint)
        let editConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        editInfoButton_Glasspaint.setImage(UIImage(systemName: "pencil.circle.fill", withConfiguration: editConfig_glasspaint), for: .normal)
        editInfoButton_Glasspaint.setTitle(" Edit Profile", for: .normal)
        editInfoButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        editInfoButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.12)
        editInfoButton_Glasspaint.layer.cornerRadius = 20
        editInfoButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        editInfoButton_Glasspaint.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        editInfoButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        editInfoButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        editInfoButton_Glasspaint.layer.shadowRadius = 6
        editInfoButton_Glasspaint.layer.shadowOpacity = 0.2
        editInfoButton_Glasspaint.addTarget(self, action: #selector(handleEditInfoTap_Glasspaint), for: .touchUpInside)
        
        // 用户名
        userInfoCard_Glasspaint.addSubview(userNameLabel_Glasspaint)
        userNameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        userNameLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        userNameLabel_Glasspaint.textAlignment = .center
        
        // 简介
        userInfoCard_Glasspaint.addSubview(userBioLabel_Glasspaint)
        userBioLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        userBioLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        userBioLabel_Glasspaint.textAlignment = .center
        userBioLabel_Glasspaint.numberOfLines = 0
        
        // 统计数据容器
        userInfoCard_Glasspaint.addSubview(statsContainer_Glasspaint)
        
        // 发布数
        let postsStack_glasspaint = UIStackView()
        postsStack_glasspaint.axis = .vertical
        postsStack_glasspaint.alignment = .center
        postsStack_glasspaint.spacing = 4
        statsContainer_Glasspaint.addSubview(postsStack_glasspaint)
        
        postsStack_glasspaint.addArrangedSubview(postsCountLabel_Glasspaint)
        postsCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        postsCountLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        postsStack_glasspaint.addArrangedSubview(postsTextLabel_Glasspaint)
        postsTextLabel_Glasspaint.text = "Posts"
        postsTextLabel_Glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        postsTextLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 喜欢数
        let likesStack_glasspaint = UIStackView()
        likesStack_glasspaint.axis = .vertical
        likesStack_glasspaint.alignment = .center
        likesStack_glasspaint.spacing = 4
        statsContainer_Glasspaint.addSubview(likesStack_glasspaint)
        
        likesStack_glasspaint.addArrangedSubview(likesCountLabel_Glasspaint)
        likesCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        likesCountLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        likesStack_glasspaint.addArrangedSubview(likesTextLabel_Glasspaint)
        likesTextLabel_Glasspaint.text = "Likes"
        likesTextLabel_Glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        likesTextLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 关注数
        let followsStack_glasspaint = UIStackView()
        followsStack_glasspaint.axis = .vertical
        followsStack_glasspaint.alignment = .center
        followsStack_glasspaint.spacing = 4
        statsContainer_Glasspaint.addSubview(followsStack_glasspaint)
        
        followsStack_glasspaint.addArrangedSubview(followsCountLabel_Glasspaint)
        followsCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        followsCountLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        followsStack_glasspaint.addArrangedSubview(followsTextLabel_Glasspaint)
        followsTextLabel_Glasspaint.text = "Following"
        followsTextLabel_Glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        followsTextLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 布局
        postsStack_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        }
        
        likesStack_glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        followsStack_glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 设置分段控制器
    private func setupSegmentControl_Glasspaint() {
        contentTypeSegment_Glasspaint.selectedSegmentTintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        contentTypeSegment_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        contentTypeSegment_Glasspaint.layer.cornerRadius = 12
        contentTypeSegment_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        contentTypeSegment_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentTypeSegment_Glasspaint.layer.shadowRadius = 8
        contentTypeSegment_Glasspaint.layer.shadowOpacity = 0.08
        
        let normalAttributes_glasspaint: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Glasspaint.textSecondary_Glasspaint,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        let selectedAttributes_glasspaint: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)
        ]
        contentTypeSegment_Glasspaint.setTitleTextAttributes(normalAttributes_glasspaint, for: .normal)
        contentTypeSegment_Glasspaint.setTitleTextAttributes(selectedAttributes_glasspaint, for: .selected)
        contentTypeSegment_Glasspaint.addTarget(self, action: #selector(handleContentTypeChange_Glasspaint), for: .valueChanged)
    }
    
    /// 设置帖子列表
    private func setupPostsCollection_Glasspaint() {
        postsCollectionView_Glasspaint.delegate = self
        postsCollectionView_Glasspaint.dataSource = self
        postsCollectionView_Glasspaint.register(PostCell_Glasspaint.self, forCellWithReuseIdentifier: "PostCell")
    }
    
    /// 设置空状态视图
    private func setupEmptyState_Glasspaint() {
        emptyStateView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        emptyStateView_Glasspaint.layer.cornerRadius = 24
        emptyStateView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        emptyStateView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        emptyStateView_Glasspaint.layer.shadowRadius = 12
        emptyStateView_Glasspaint.layer.shadowOpacity = 0.1
        emptyStateView_Glasspaint.isHidden = true
        
        // 图标
        emptyStateView_Glasspaint.addSubview(emptyIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        emptyIconView_Glasspaint.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: iconConfig_glasspaint)
        emptyIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.6)
        emptyIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        emptyStateView_Glasspaint.addSubview(emptyTitleLabel_Glasspaint)
        emptyTitleLabel_Glasspaint.text = "No Posts Yet"
        emptyTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        emptyTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        emptyTitleLabel_Glasspaint.textAlignment = .center
        
        // 副标题
        emptyStateView_Glasspaint.addSubview(emptySubtitleLabel_Glasspaint)
        emptySubtitleLabel_Glasspaint.text = "Share your creative works\nwith the community"
        emptySubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        emptySubtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        emptySubtitleLabel_Glasspaint.textAlignment = .center
        emptySubtitleLabel_Glasspaint.numberOfLines = 0
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // 导航栏
        navContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        // 用户信息卡片
        userInfoCard_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.width.height.equalTo(90)
        }
        
        editInfoButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        userNameLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }
        
        userBioLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(32)
        }
        
        statsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userBioLabel_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        // 分段控制器
        contentTypeSegment_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userInfoCard_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // 帖子列表
        postsCollectionView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(contentTypeSegment_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 空状态视图
        emptyStateView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(contentTypeSegment_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(240)
        }
        
        emptyIconView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(80)
        }
        
        emptyTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        emptySubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载数据
    private func loadData_Glasspaint() {
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        meModel_Glasspaint = currentUser_glasspaint
        
        // 更新用户信息
        userNameLabel_Glasspaint.text = currentUser_glasspaint.userName_Glasspaint
        userBioLabel_Glasspaint.text = currentUser_glasspaint.userIntroduce_Glasspaint ?? "Glass painting enthusiast"
        
        // 加载帖子数据
        myPosts_Glasspaint = currentUser_glasspaint.userPosts_Glasspaint
        likedPosts_Glasspaint = currentUser_glasspaint.userLike_Glasspaint
        
        // 更新统计数据
        postsCountLabel_Glasspaint.text = "\(myPosts_Glasspaint.count)"
        likesCountLabel_Glasspaint.text = "\(likedPosts_Glasspaint.count)"
        followsCountLabel_Glasspaint.text = "\(currentUser_glasspaint.userFollow_Glasspaint.count)"
        
        // 刷新列表
        updateContentDisplay_Glasspaint()
    }
    
    /// 更新内容显示
    private func updateContentDisplay_Glasspaint() {
        let posts_glasspaint = currentContentType_Glasspaint == 0 ? myPosts_Glasspaint : likedPosts_Glasspaint
        
        if posts_glasspaint.isEmpty {
            postsCollectionView_Glasspaint.isHidden = true
            emptyStateView_Glasspaint.isHidden = false
            
            // 更新空状态文本
            if currentContentType_Glasspaint == 0 {
                emptyTitleLabel_Glasspaint.text = "No Posts Yet"
                emptySubtitleLabel_Glasspaint.text = "Share your creative works\nwith the community"
                let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
                emptyIconView_Glasspaint.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: iconConfig_glasspaint)
            } else {
                emptyTitleLabel_Glasspaint.text = "No Liked Posts"
                emptySubtitleLabel_Glasspaint.text = "Explore and like posts\nthat inspire you"
                let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
                emptyIconView_Glasspaint.image = UIImage(systemName: "heart.circle", withConfiguration: iconConfig_glasspaint)
            }
        } else {
            postsCollectionView_Glasspaint.isHidden = false
            emptyStateView_Glasspaint.isHidden = true
            
            // 更新CollectionView高度
            let itemWidth_glasspaint = (UIScreen.main.bounds.width - 54) / 2
            let itemHeight_glasspaint = itemWidth_glasspaint * 1.3
            let rows_glasspaint = ceil(Double(posts_glasspaint.count) / 2.0)
            let totalHeight_glasspaint = CGFloat(rows_glasspaint) * itemHeight_glasspaint + CGFloat(rows_glasspaint - 1) * 16 + 20
            
            postsCollectionView_Glasspaint.snp.updateConstraints { make in
                make.height.equalTo(totalHeight_glasspaint)
            }
        }
        
        postsCollectionView_Glasspaint.reloadData()
    }
    
    /// 设置通知
    private func setupNotifications_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Glasspaint),
            name: UserViewModel_Glasspaint.userStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    /// 处理用户状态变化
    @objc private func handleUserStateChange_Glasspaint() {
        loadData_Glasspaint()
    }
    
    /// 处理内容类型变化
    @objc private func handleContentTypeChange_Glasspaint() {
        currentContentType_Glasspaint = contentTypeSegment_Glasspaint.selectedSegmentIndex
        
        // 切换动画
        UIView.animate(withDuration: 0.3) {
            self.updateContentDisplay_Glasspaint()
        }
    }
    
    /// 处理设置按钮点击
    @objc private func handleSettingTap_Glasspaint() {
        let settingVC_glasspaint = Setting_Glasspaint()
        settingVC_glasspaint.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingVC_glasspaint, animated: true)
    }
    
    /// 处理编辑信息按钮点击
    @objc private func handleEditInfoTap_Glasspaint() {
        let editVC_glasspaint = EditInfo_Glasspaint()
        editVC_glasspaint.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editVC_glasspaint, animated: true)
    }
    
    /// 打开帖子详情
    /// 参数：
    /// - post_glasspaint: 帖子数据
    private func openPostDetail_Glasspaint(_ post_glasspaint: TitleModel_Glasspaint) {
        // 这里可以跳转到帖子详情页面
        // 暂时使用一个简单的提示
        Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Post: \(post_glasspaint.title_Glasspaint)")
    }
}

// MARK: - UIScrollViewDelegate

extension Me_Glasspaint: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset_glasspaint = scrollView.contentOffset.y
        let threshold_glasspaint: CGFloat = 60
        
        if offset_glasspaint > threshold_glasspaint {
            let alpha_glasspaint = min((offset_glasspaint - threshold_glasspaint) / 40, 1.0)
            navBlurEffect_Glasspaint.alpha = alpha_glasspaint
        } else {
            navBlurEffect_Glasspaint.alpha = 0
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension Me_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentContentType_Glasspaint == 0 ? myPosts_Glasspaint.count : likedPosts_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell_Glasspaint
        let post_glasspaint = currentContentType_Glasspaint == 0 ? myPosts_Glasspaint[indexPath.item] : likedPosts_Glasspaint[indexPath.item]
        
        // 判断是否为自己的帖子（在"我的帖子"标签页中都是自己的帖子）
        let isOwnPost_glasspaint = currentContentType_Glasspaint == 0
        cell_glasspaint.configure_Glasspaint(with: post_glasspaint, isOwnPost_glasspaint: isOwnPost_glasspaint)
        
        // 设置举报/删除回调
        cell_glasspaint.onReport_Glasspaint = { [weak self] in
            guard let self = self else { return }
            ReportDeleteHelper_Glasspaint.report_Glasspaint(
                post_Glasspaint: post_glasspaint,
                from: self
            ) {
                // 删除完成后刷新数据
                self.loadData_Glasspaint()
            }
        }
        
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_glasspaint = currentContentType_Glasspaint == 0 ? myPosts_Glasspaint[indexPath.item] : likedPosts_Glasspaint[indexPath.item]
        
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

// MARK: - 帖子Cell

/// 帖子Cell
/// 设计：卡片式布局，媒体预览，标题和统计信息
class PostCell_Glasspaint: UICollectionViewCell {
    
    private let containerView_Glasspaint = UIView()
    private let mediaImageView_Glasspaint = UIImageView()
    private let overlayGradient_Glasspaint = CAGradientLayer()
    private let titleLabel_Glasspaint = UILabel()
    private let likeIconView_Glasspaint = UIImageView()
    private let likeCountLabel_Glasspaint = UILabel()
    private let actionButton_Glasspaint = UIButton(type: .system)
    
    var onReport_Glasspaint: (() -> Void)?
    private var currentPost_Glasspaint: TitleModel_Glasspaint?
    private var isOwnPost_Glasspaint: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentPost_Glasspaint = nil
        onReport_Glasspaint = nil
        mediaImageView_Glasspaint.image = nil
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
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        overlayGradient_Glasspaint.locations = [0.4, 1.0]
        mediaImageView_Glasspaint.layer.addSublayer(overlayGradient_Glasspaint)
        
        // 操作按钮（举报/删除）
        containerView_Glasspaint.addSubview(actionButton_Glasspaint)
        actionButton_Glasspaint.tintColor = .white
        actionButton_Glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        actionButton_Glasspaint.layer.cornerRadius = 16
        actionButton_Glasspaint.addTarget(self, action: #selector(handleActionTap_Glasspaint), for: .touchUpInside)
        
        // 标题
        containerView_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel_Glasspaint.textColor = .white
        titleLabel_Glasspaint.numberOfLines = 2
        titleLabel_Glasspaint.shadowColor = UIColor.black.withAlphaComponent(0.3)
        titleLabel_Glasspaint.shadowOffset = CGSize(width: 0, height: 1)
        
        // 喜欢图标
        containerView_Glasspaint.addSubview(likeIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        likeIconView_Glasspaint.image = UIImage(systemName: "heart.fill", withConfiguration: iconConfig_glasspaint)
        likeIconView_Glasspaint.tintColor = UIColor.systemPink
        likeIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 喜欢数
        containerView_Glasspaint.addSubview(likeCountLabel_Glasspaint)
        likeCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        likeCountLabel_Glasspaint.textColor = .white
        likeCountLabel_Glasspaint.shadowColor = UIColor.black.withAlphaComponent(0.3)
        likeCountLabel_Glasspaint.shadowOffset = CGSize(width: 0, height: 1)
        
        // 布局
        containerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mediaImageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        actionButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        likeIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(15)
        }
        
        likeCountLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(likeIconView_Glasspaint.snp.right).offset(6)
            make.centerY.equalTo(likeIconView_Glasspaint)
        }
    }
    
    /// 处理操作按钮点击（举报/删除）
    @objc private func handleActionTap_Glasspaint() {
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self.actionButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.actionButton_Glasspaint.transform = .identity
            }
        }
        
        onReport_Glasspaint?()
    }
    
    /// 更新操作按钮显示
    /// 参数：
    /// - isOwnPost_glasspaint: 是否为自己的帖子
    private func updateActionButton_Glasspaint(isOwnPost_glasspaint: Bool) {
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let iconName_glasspaint = isOwnPost_glasspaint ? "trash.fill" : "ellipsis"
        let image_glasspaint = UIImage(systemName: iconName_glasspaint, withConfiguration: config_glasspaint)
        actionButton_Glasspaint.setImage(image_glasspaint, for: .normal)
        actionButton_Glasspaint.tintColor = isOwnPost_glasspaint ? UIColor.systemRed : .white
    }
    
    /// 配置Cell
    /// 参数：
    /// - post_glasspaint: 帖子数据
    /// - isOwnPost_glasspaint: 是否为自己的帖子
    func configure_Glasspaint(with post_glasspaint: TitleModel_Glasspaint, isOwnPost_glasspaint: Bool = false) {
        currentPost_Glasspaint = post_glasspaint
        isOwnPost_Glasspaint = isOwnPost_glasspaint
        titleLabel_Glasspaint.text = post_glasspaint.title_Glasspaint
        likeCountLabel_Glasspaint.text = "\(post_glasspaint.likes_Glasspaint)"
        
        // 更新操作按钮显示
        updateActionButton_Glasspaint(isOwnPost_glasspaint: isOwnPost_glasspaint)
        
        // 加载媒体（使用第一张图片）
        if !post_glasspaint.titleMeidas_Glasspaint.isEmpty {
            let mediaPath_glasspaint = post_glasspaint.titleMeidas_Glasspaint[0]
            
            print("📸 加载媒体 - 标题: \(post_glasspaint.title_Glasspaint)")
            print("📸 媒体路径: \(mediaPath_glasspaint)")
            
            if mediaPath_glasspaint.hasPrefix("http") {
                // 网络图片
                if let url_glasspaint = URL(string: mediaPath_glasspaint) {
                    print("📸 使用Kingfisher加载网络图片")
                    mediaImageView_Glasspaint.kf.setImage(
                        with: url_glasspaint,
                        placeholder: UIImage(systemName: "photo"),
                        options: [.transition(.fade(0.2))]
                    )
                } else {
                    print("⚠️ 无法创建URL")
                    let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
                    mediaImageView_Glasspaint.image = UIImage(systemName: "photo", withConfiguration: config_glasspaint)
                    mediaImageView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.3)
                }
            } else if let localImage_glasspaint = UIImage(contentsOfFile: mediaPath_glasspaint) {
                // 本地图片
                print("📸 成功加载本地图片")
                mediaImageView_Glasspaint.image = localImage_glasspaint
            } else {
                // 尝试作为资源名称加载
                print("📸 尝试从Assets加载: \(mediaPath_glasspaint)")
                if let assetImage_glasspaint = UIImage(named: mediaPath_glasspaint) {
                    mediaImageView_Glasspaint.image = assetImage_glasspaint
                    print("✅ 从Assets成功加载")
                } else {
                    print("⚠️ 无法加载图片，显示占位图")
                    let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
                    mediaImageView_Glasspaint.image = UIImage(systemName: "photo", withConfiguration: config_glasspaint)
                    mediaImageView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.3)
                }
            }
        } else {
            // 无媒体，显示占位图
            print("⚠️ 无媒体数据")
            let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
            mediaImageView_Glasspaint.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: config_glasspaint)
            mediaImageView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.3)
        }
    }
}
