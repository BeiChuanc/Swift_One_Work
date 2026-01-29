import Foundation
import UIKit
import SnapKit

// MARK: 用户中心（其他用户）

/// 用户中心页面
/// 核心功能：展示其他用户的个人信息和帖子列表
/// 设计思路：现代化UI设计，包含头像、用户信息、关注按钮、私信按钮、帖子列表、举报按钮
/// 关键属性：
/// - userModel_Wanderbell: 用户模型
/// - postsList_Wanderbell: 用户帖子列表
/// 关键方法：
/// - followUser_Wanderbell: 关注/取消关注用户
/// - messageUser_Wanderbell: 给用户发私信
class UserInfo_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    /// 用户模型
    var userModel_Wanderbell: PrewUserModel_Wanderbell?
    
    /// 是否已关注
    private var isFollowing_Wanderbell: Bool = false
    
    /// 用户帖子列表
    private var userPosts_Wanderbell: [TitleModel_Wanderbell] = []
    
    // MARK: - UI组件
    
    /// 滚动视图
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        return scrollView_wanderbell
    }()
    
    /// 内容容器
    private let contentView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    /// 顶部背景视图
    private let headerBackgroundView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.clipsToBounds = true
        return view_wanderbell
    }()
    
    /// 渐变图层
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    /// 用户头像容器
    private let avatarContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 60
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 8)
        view_wanderbell.layer.shadowOpacity = 0.15
        view_wanderbell.layer.shadowRadius = 20
        return view_wanderbell
    }()
    
    /// 用户头像
    private let avatarImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        imageView_wanderbell.layer.cornerRadius = 55
        imageView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        return imageView_wanderbell
    }()
    
    /// 用户名标签
    private let usernameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title1_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 用户简介标签
    private let bioLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        label_wanderbell.numberOfLines = 0
        return label_wanderbell
    }()
    
    /// 统计容器
    private let statsContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_wanderbell.layer.shadowOpacity = 0.08
        view_wanderbell.layer.shadowRadius = 12
        return view_wanderbell
    }()
    
    /// 按钮容器
    private let buttonsContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    /// 关注按钮
    private let followButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button_wanderbell.setTitleColor(.white, for: .normal)
        button_wanderbell.layer.cornerRadius = 24
        button_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor
        button_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 4)
        button_wanderbell.layer.shadowOpacity = 0.3
        button_wanderbell.layer.shadowRadius = 8
        return button_wanderbell
    }()
    
    /// 私信按钮
    private let messageButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button_wanderbell.setTitle("Message", for: .normal)
        button_wanderbell.setTitleColor(ColorConfig_Wanderbell.primaryGradientStart_Wanderbell, for: .normal)
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.withAlphaComponent(0.1)
        button_wanderbell.layer.cornerRadius = 24
        button_wanderbell.layer.borderWidth = 2
        button_wanderbell.layer.borderColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor
        return button_wanderbell
    }()
    
    /// 帖子列表标题
    private let postsHeaderLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Posts"
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    /// 帖子列表容器
    private let postsContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    /// 空状态视图
    private let emptyStateView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 16
        return view_wanderbell
    }()
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        checkFollowStatus_Wanderbell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupActions_Wanderbell()
        loadUserData_Wanderbell()
        updateFollowButton_Wanderbell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Wanderbell?.frame = headerBackgroundView_Wanderbell.bounds
        updateFollowButtonGradient_Wanderbell()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        view.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        
        // 设置导航栏
        setupNavigationBar_Wanderbell()
        
        // 添加子视图
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        // 顶部背景
        contentView_Wanderbell.addSubview(headerBackgroundView_Wanderbell)
        setupHeaderGradient_Wanderbell()
        
        // 用户信息
        contentView_Wanderbell.addSubview(avatarContainerView_Wanderbell)
        avatarContainerView_Wanderbell.addSubview(avatarImageView_Wanderbell)
        contentView_Wanderbell.addSubview(usernameLabel_Wanderbell)
        contentView_Wanderbell.addSubview(bioLabel_Wanderbell)
        
        // 统计
        contentView_Wanderbell.addSubview(statsContainerView_Wanderbell)
        setupStatsView_Wanderbell()
        
        // 按钮
        contentView_Wanderbell.addSubview(buttonsContainerView_Wanderbell)
        buttonsContainerView_Wanderbell.addSubview(followButton_Wanderbell)
        buttonsContainerView_Wanderbell.addSubview(messageButton_Wanderbell)
        
        // 帖子列表
        contentView_Wanderbell.addSubview(postsHeaderLabel_Wanderbell)
        contentView_Wanderbell.addSubview(postsContainerView_Wanderbell)
        
        // 空状态
        setupEmptyState_Wanderbell()
        
        setupConstraints_Wanderbell()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Wanderbell() {
        title = "Profile"
        
        // 返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Wanderbell)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        
        // 右侧举报按钮
        let reportButton_wanderbell = UIButton(type: .system)
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image_wanderbell = UIImage(systemName: "ellipsis", withConfiguration: config_wanderbell)
        reportButton_wanderbell.setImage(image_wanderbell, for: .normal)
        reportButton_wanderbell.tintColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        reportButton_wanderbell.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        reportButton_wanderbell.addTarget(self, action: #selector(reportTapped_Wanderbell), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButton_wanderbell)
    }
    
    /// 设置顶部渐变
    private func setupHeaderGradient_Wanderbell() {
        let gradient_wanderbell = CAGradientLayer()
        gradient_wanderbell.colors = [
            ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.withAlphaComponent(0.2).cgColor,
            ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        gradient_wanderbell.locations = [0.0, 0.5, 1.0]
        headerBackgroundView_Wanderbell.layer.addSublayer(gradient_wanderbell)
        gradientLayer_Wanderbell = gradient_wanderbell
    }
    
    /// 设置统计视图
    private func setupStatsView_Wanderbell() {
        let stackView_wanderbell = UIStackView()
        stackView_wanderbell.axis = .horizontal
        stackView_wanderbell.distribution = .fillEqually
        stackView_wanderbell.tag = 1001 // 用于后续更新
        statsContainerView_Wanderbell.addSubview(stackView_wanderbell)
        
        stackView_wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        // 获取用户帖子数（需要在loadUserData之后才能获取）
        let postsCount_wanderbell = 0 // 初始为0，loadUserData后会更新
        let followingCount_wanderbell = userModel_Wanderbell?.userFollowCount_Wanderbell ?? 0
        let followersCount_wanderbell = userModel_Wanderbell?.userFollowers_Wanderbell ?? 0
        
        // 帖子数
        let postsStatView_wanderbell = createStatView_Wanderbell(
            count: "\(postsCount_wanderbell)",
            label: "Posts"
        )
        stackView_wanderbell.addArrangedSubview(postsStatView_wanderbell)
        
        // 关注数
        let followingStatView_wanderbell = createStatView_Wanderbell(
            count: formatCount_Wanderbell(followingCount_wanderbell),
            label: "Following"
        )
        stackView_wanderbell.addArrangedSubview(followingStatView_wanderbell)
        
        // 粉丝数
        let followersStatView_wanderbell = createStatView_Wanderbell(
            count: formatCount_Wanderbell(followersCount_wanderbell),
            label: "Followers"
        )
        stackView_wanderbell.addArrangedSubview(followersStatView_wanderbell)
    }
    
    /// 格式化数字显示
    /// 功能：将大数字格式化为K（千）显示
    /// 参数：
    /// - count_wanderbell: 数字
    /// 返回值：格式化后的字符串
    private func formatCount_Wanderbell(_ count_wanderbell: Int) -> String {
        if count_wanderbell >= 1000 {
            let kValue_wanderbell = Double(count_wanderbell) / 1000.0
            return String(format: "%.1fK", kValue_wanderbell)
        }
        return "\(count_wanderbell)"
    }
    
    /// 创建统计视图
    private func createStatView_Wanderbell(count: String, label: String) -> UIView {
        let container_wanderbell = UIView()
        
        let countLabel_wanderbell = UILabel()
        countLabel_wanderbell.text = count
        countLabel_wanderbell.font = FontConfig_Wanderbell.number_Wanderbell(size_wanderbell: 24)
        countLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        countLabel_wanderbell.textAlignment = .center
        
        let titleLabel_wanderbell = UILabel()
        titleLabel_wanderbell.text = label
        titleLabel_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        titleLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        titleLabel_wanderbell.textAlignment = .center
        
        container_wanderbell.addSubview(countLabel_wanderbell)
        container_wanderbell.addSubview(titleLabel_wanderbell)
        
        countLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        titleLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(countLabel_wanderbell.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return container_wanderbell
    }
    
    /// 设置空状态
    private func setupEmptyState_Wanderbell() {
        // 将空状态视图添加到 contentView，而不是 postsContainerView
        // 这样在清空 postsContainerView 时不会被删除
        contentView_Wanderbell.addSubview(emptyStateView_Wanderbell)
        
        // 图标
        let iconImageView_wanderbell = UIImageView()
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        iconImageView_wanderbell.image = UIImage(systemName: "doc.text", withConfiguration: config_wanderbell)
        iconImageView_wanderbell.tintColor = ColorConfig_Wanderbell.textSecondary_Wanderbell.withAlphaComponent(0.5)
        emptyStateView_Wanderbell.addSubview(iconImageView_wanderbell)
        
        // 文字
        let messageLabel_wanderbell = UILabel()
        messageLabel_wanderbell.text = "No posts yet"
        messageLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        messageLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        messageLabel_wanderbell.textAlignment = .center
        emptyStateView_Wanderbell.addSubview(messageLabel_wanderbell)
        
        iconImageView_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        
        messageLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(iconImageView_wanderbell.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        // 初始隐藏
        emptyStateView_Wanderbell.isHidden = true
    }
    
    /// 更新关注按钮渐变
    private func updateFollowButtonGradient_Wanderbell() {
        followButton_Wanderbell.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        if !isFollowing_Wanderbell {
            let gradient_wanderbell = CAGradientLayer()
            gradient_wanderbell.frame = followButton_Wanderbell.bounds
            gradient_wanderbell.colors = [
                ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor,
                ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.cgColor
            ]
            gradient_wanderbell.startPoint = CGPoint(x: 0, y: 0.5)
            gradient_wanderbell.endPoint = CGPoint(x: 1, y: 0.5)
            gradient_wanderbell.cornerRadius = 24
            followButton_Wanderbell.layer.insertSublayer(gradient_wanderbell, at: 0)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Wanderbell() {
        let screenWidth_wanderbell = UIScreen.main.bounds.width
        let horizontalPadding_wanderbell: CGFloat = 20
        
        // 滚动视图
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // 内容容器
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenWidth_wanderbell)
        }
        
        // 顶部背景
        headerBackgroundView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        // 头像容器
        avatarContainerView_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(120)
            make.width.height.equalTo(120)
        }
        
        // 头像
        avatarImageView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(110)
        }
        
        // 用户名
        usernameLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
        }
        
        // 简介
        bioLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
        }
        
        // 统计容器
        statsContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
        }
        
        // 按钮容器
        buttonsContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(statsContainerView_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
            make.height.equalTo(48)
        }
        
        // 关注按钮
        followButton_Wanderbell.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(buttonsContainerView_Wanderbell.snp.centerX).offset(-6)
        }
        
        // 私信按钮
        messageButton_Wanderbell.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(buttonsContainerView_Wanderbell.snp.centerX).offset(6)
        }
        
        // 帖子列表标题
        postsHeaderLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(buttonsContainerView_Wanderbell.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(horizontalPadding_wanderbell)
        }
        
        // 帖子列表容器
        postsContainerView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(postsHeaderLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        // 空状态视图（与帖子列表容器位置相同）
        emptyStateView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(postsHeaderLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(horizontalPadding_wanderbell)
            make.height.equalTo(200)
        }
    }
    
    /// 设置事件
    private func setupActions_Wanderbell() {
        followButton_Wanderbell.addTarget(self, action: #selector(followTapped_Wanderbell), for: .touchUpInside)
        messageButton_Wanderbell.addTarget(self, action: #selector(messageTapped_Wanderbell), for: .touchUpInside)
    }
    
    // MARK: - 数据加载
    
    /// 加载用户数据
    private func loadUserData_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell else { return }
        
        // 加载头像
        if let imageName_wanderbell = userModel_wanderbell.userHead_Wanderbell {
            avatarImageView_Wanderbell.image = UIImage(named: imageName_wanderbell)
        }
        
        // 加载用户名
        usernameLabel_Wanderbell.text = userModel_wanderbell.userName_Wanderbell
        
        // 加载简介
        if let bio_wanderbell = userModel_wanderbell.userIntroduce_Wanderbell, !bio_wanderbell.isEmpty {
            bioLabel_Wanderbell.text = bio_wanderbell
        } else {
            bioLabel_Wanderbell.text = "No bio yet"
        }
        
        // 加载用户帖子
        userPosts_Wanderbell = TitleViewModel_Wanderbell.shared_Wanderbell.getUserPosts_Wanderbell(user_wanderbell: userModel_wanderbell)
        
        // 更新统计显示
        updateStatsDisplay_Wanderbell()
        
        // 更新UI
        if userPosts_Wanderbell.isEmpty {
            // 清空旧的帖子卡片
            postsContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
            // 显示空状态
            emptyStateView_Wanderbell.isHidden = false
        } else {
            // 隐藏空状态，显示帖子列表
            emptyStateView_Wanderbell.isHidden = true
            displayUserPosts_Wanderbell()
        }
    }
    
    /// 展示用户帖子
    /// 功能：在容器中动态创建帖子卡片
    private func displayUserPosts_Wanderbell() {
        // 清空现有视图
        postsContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
        
        // 创建帖子卡片堆栈
        let stackView_wanderbell = UIStackView()
        stackView_wanderbell.axis = .vertical
        stackView_wanderbell.spacing = 16
        stackView_wanderbell.alignment = .fill
        stackView_wanderbell.distribution = .fill  // 使用fill，让每个子视图保持自己的内在大小
        postsContainerView_Wanderbell.addSubview(stackView_wanderbell)
        
        stackView_wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 遍历帖子，最多显示前6个
        let displayPosts_wanderbell = Array(userPosts_Wanderbell.prefix(6))
        for post_wanderbell in displayPosts_wanderbell {
            let postCard_wanderbell = createPostCard_Wanderbell(post: post_wanderbell)
            stackView_wanderbell.addArrangedSubview(postCard_wanderbell)
        }
    }
    
    /// 创建帖子卡片
    /// 功能：创建单个帖子的卡片视图
    /// 参数：
    /// - post: 帖子模型
    /// 返回值：帖子卡片视图
    private func createPostCard_Wanderbell(post: TitleModel_Wanderbell) -> UIView {
        let cardView_wanderbell = UIView()
        cardView_wanderbell.backgroundColor = .white
        cardView_wanderbell.layer.cornerRadius = 16
        cardView_wanderbell.layer.shadowColor = UIColor.black.cgColor
        cardView_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView_wanderbell.layer.shadowOpacity = 0.08
        cardView_wanderbell.layer.shadowRadius = 12
        
        // 标题和内容的 top 参考
        var titleTopAnchor_wanderbell: ConstraintItem!
        var titleTopOffset_wanderbell: CGFloat = 16
        
        // 帖子图片（如果有）
        if let firstMedia_wanderbell = post.titleMeidas_Wanderbell.first {
            // 使用媒体展示视图组件
            let mediaView_wanderbell = MediaDisplayView_Wanderbell()
            mediaView_wanderbell.configure_Wanderbell(
                mediaPath_wanderbell: firstMedia_wanderbell,
                isVideo_wanderbell: firstMedia_wanderbell.hasSuffix(".mp4") || firstMedia_wanderbell.hasSuffix(".mov")
            )
            cardView_wanderbell.addSubview(mediaView_wanderbell)
            
            mediaView_wanderbell.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.left.right.equalToSuperview().inset(12)
                make.height.equalTo(180)
            }
            
            // 标题在媒体下方
            titleTopAnchor_wanderbell = mediaView_wanderbell.snp.bottom
            titleTopOffset_wanderbell = 12
            
            // 添加举报按钮（在图片上方）
            let reportButton_wanderbell = ReportDeleteHelper_Wanderbell.createPostReportButton_Wanderbell(
                post_wanderbell: post,
                size_wanderbell: 30,
                color_wanderbell: .white,
                from: self
            ) { [weak self] in
                // 操作完成后刷新数据
                self?.loadUserData_Wanderbell()
            }
            
            // 添加按钮背景
            let buttonContainer_wanderbell = UIView()
            buttonContainer_wanderbell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            buttonContainer_wanderbell.layer.cornerRadius = 18
            cardView_wanderbell.addSubview(buttonContainer_wanderbell)
            buttonContainer_wanderbell.addSubview(reportButton_wanderbell)
            
            buttonContainer_wanderbell.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.width.height.equalTo(36)
            }
            
            reportButton_wanderbell.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(30)
            }
        } else {
            // 没有图片时，标题从卡片顶部开始
            titleTopAnchor_wanderbell = cardView_wanderbell.snp.top
            titleTopOffset_wanderbell = 50  // 为举报按钮留出空间
            
            // 添加举报按钮到卡片右上角
            let reportButton_wanderbell = ReportDeleteHelper_Wanderbell.createPostReportButton_Wanderbell(
                post_wanderbell: post,
                size_wanderbell: 30,
                color_wanderbell: ColorConfig_Wanderbell.textSecondary_Wanderbell,
                from: self
            ) { [weak self] in
                // 操作完成后刷新数据
                self?.loadUserData_Wanderbell()
            }
            
            cardView_wanderbell.addSubview(reportButton_wanderbell)
            
            reportButton_wanderbell.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-12)
                make.width.height.equalTo(30)
            }
        }
        
        // 帖子标题
        let titleLabel_wanderbell = UILabel()
        titleLabel_wanderbell.text = post.title_Wanderbell
        titleLabel_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        titleLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        titleLabel_wanderbell.numberOfLines = 0  // 完整显示所有行
        titleLabel_wanderbell.setContentCompressionResistancePriority(.required, for: .vertical)  // 防止被压缩
        titleLabel_wanderbell.setContentHuggingPriority(.required, for: .vertical)  // 紧贴内容
        cardView_wanderbell.addSubview(titleLabel_wanderbell)
        
        titleLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleTopAnchor_wanderbell).offset(titleTopOffset_wanderbell)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 帖子内容
        let contentLabel_wanderbell = UILabel()
        contentLabel_wanderbell.text = post.titleContent_Wanderbell
        contentLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        contentLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        contentLabel_wanderbell.numberOfLines = 0  // 完整显示所有行
        contentLabel_wanderbell.setContentCompressionResistancePriority(.required, for: .vertical)  // 防止被压缩
        contentLabel_wanderbell.setContentHuggingPriority(.required, for: .vertical)  // 紧贴内容
        cardView_wanderbell.addSubview(contentLabel_wanderbell)
        
        contentLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 点赞和评论信息
        let statsLabel_wanderbell = UILabel()
        statsLabel_wanderbell.text = "❤️ \(post.likes_Wanderbell)   💬 \(post.reviews_Wanderbell.count)"
        statsLabel_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        statsLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        statsLabel_wanderbell.setContentCompressionResistancePriority(.required, for: .vertical)  // 防止被压缩
        statsLabel_wanderbell.setContentHuggingPriority(.required, for: .vertical)  // 紧贴内容
        cardView_wanderbell.addSubview(statsLabel_wanderbell)
        
        statsLabel_wanderbell.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)  // 决定卡片的实际高度
        }
        
        return cardView_wanderbell
    }
    
    /// 检查关注状态
    private func checkFollowStatus_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell else { return }
        isFollowing_Wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.isFollowing_Wanderbell(user_wanderbell: userModel_wanderbell)
        updateFollowButton_Wanderbell()
    }
    
    /// 更新关注按钮
    private func updateFollowButton_Wanderbell() {
        if isFollowing_Wanderbell {
            followButton_Wanderbell.setTitle("Followed", for: .normal)
            followButton_Wanderbell.setTitleColor(ColorConfig_Wanderbell.textSecondary_Wanderbell, for: .normal)
            followButton_Wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
            followButton_Wanderbell.layer.borderWidth = 2
            followButton_Wanderbell.layer.borderColor = ColorConfig_Wanderbell.border_Wanderbell.cgColor
        } else {
            followButton_Wanderbell.setTitle("Follow", for: .normal)
            followButton_Wanderbell.setTitleColor(.white, for: .normal)
            followButton_Wanderbell.backgroundColor = .clear
            followButton_Wanderbell.layer.borderWidth = 0
        }
        updateFollowButtonGradient_Wanderbell()
    }
    
    // MARK: - 事件处理
    
    /// 返回按钮点击
    @objc private func backTapped_Wanderbell() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Wanderbell.block_Wanderbell(
            user_wanderbell: userModel_wanderbell,
            from: self
        ) { [weak self] in
            // 拉黑成功后返回
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 关注按钮点击
    @objc private func followTapped_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell else { return }
        
        // 优先判断是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            // 延迟跳转到登录页面
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
            }
            return
        }
        
        // 按钮动画
        UIView.animate(withDuration: 0.1, animations: {
            self.followButton_Wanderbell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.followButton_Wanderbell.transform = .identity
            }
        }
        
        // 切换关注状态
        UserViewModel_Wanderbell.shared_Wanderbell.followUser_Wanderbell(user_wanderbell: userModel_wanderbell)
        
        // 更新粉丝数
        if isFollowing_Wanderbell {
            // 取消关注，粉丝数-1
            userModel_wanderbell.userFollowers_Wanderbell = max(0, userModel_wanderbell.userFollowers_Wanderbell - 1)
        } else {
            // 关注，粉丝数+1
            userModel_wanderbell.userFollowers_Wanderbell += 1
        }
        
        // 更新UI
        isFollowing_Wanderbell = !isFollowing_Wanderbell
        updateFollowButton_Wanderbell()
        updateStatsDisplay_Wanderbell()
        
        // 显示提示
        let message_wanderbell = isFollowing_Wanderbell ? "Followed successfully" : "Unfollowed"
        Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: message_wanderbell, delay_wanderbell: 1.0)
    }
    
    /// 更新统计数据显示
    /// 功能：刷新统计卡片中的数字
    private func updateStatsDisplay_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell,
              let stackView_wanderbell = statsContainerView_Wanderbell.viewWithTag(1001) as? UIStackView else {
            return
        }
        
        // 获取最新数据
        let postsCount_wanderbell = userPosts_Wanderbell.count
        let followingCount_wanderbell = userModel_wanderbell.userFollowCount_Wanderbell
        let followersCount_wanderbell = userModel_wanderbell.userFollowers_Wanderbell
        
        // 更新每个统计视图
        if stackView_wanderbell.arrangedSubviews.count == 3 {
            // 更新帖子数
            updateStatView_Wanderbell(
                view: stackView_wanderbell.arrangedSubviews[0],
                count: "\(postsCount_wanderbell)"
            )
            
            // 更新关注数
            updateStatView_Wanderbell(
                view: stackView_wanderbell.arrangedSubviews[1],
                count: formatCount_Wanderbell(followingCount_wanderbell)
            )
            
            // 更新粉丝数
            updateStatView_Wanderbell(
                view: stackView_wanderbell.arrangedSubviews[2],
                count: formatCount_Wanderbell(followersCount_wanderbell)
            )
        }
    }
    
    /// 更新单个统计视图
    /// 功能：更新统计数字标签的文本
    /// 参数：
    /// - view: 统计视图容器
    /// - count: 新的数字
    private func updateStatView_Wanderbell(view: UIView, count: String) {
        // 找到数字标签（第一个子视图）
        if let countLabel_wanderbell = view.subviews.first as? UILabel {
            // 添加数字变化动画
            UIView.transition(
                with: countLabel_wanderbell,
                duration: 0.3,
                options: .transitionCrossDissolve
            ) {
                countLabel_wanderbell.text = count
            }
        }
    }
    
    /// 私信按钮点击
    @objc private func messageTapped_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell else { return }
        
        // 按钮动画
        UIView.animate(withDuration: 0.1, animations: {
            self.messageButton_Wanderbell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.messageButton_Wanderbell.transform = .identity
            }
        }
        
        // 跳转到聊天页面
        Navigation_Wanderbell.toMessageUser_Wanderbell(
            with: userModel_wanderbell,
            style_wanderbell: .replace_wanderbell,
            animated_wanderbell: true
        )
    }
}
