import Foundation
import UIKit
import SnapKit

// MARK: 我的

/// 我的页面 - 个人中心
/// 功能：展示用户信息、统计数据、发布内容
/// 设计：现代化卡片、渐变背景、丰富视觉元素
class Me_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    var meModel_Wanderbell: LoginUserModel_Wanderbell?
    
    // MARK: - UI组件
    
    /// 页面标题
    private lazy var pageTitleView_Wanderbell: PageHeaderView_Wanderbell = {
        return PageHeaderView_Wanderbell(
            title_wanderbell: "Profile",
            subtitle_wanderbell: "Your emotional space",
            iconName_wanderbell: "person.crop.circle.fill",
            iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#B794F6")
        )
    }()
    
    /// 滚动容器
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        return scrollView_wanderbell
    }()
    
    private let contentView_Wanderbell = UIView()
    
    /// 用户信息卡片
    private let userInfoCard_Wanderbell = UserInfoCard_Wanderbell()
    
    /// 统计卡片
    private let statsCard_Wanderbell = UserStatsCard_Wanderbell()
    
    /// 内容切换器
    private let contentSwitcher_Wanderbell = ContentSwitcher_Wanderbell()
    
    /// 内容容器（帖子或情绪记录）
    private let contentContainer_Wanderbell = UIView()
    
    /// 帖子列表
    private let postsStackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .vertical
        stack_wanderbell.spacing = 16
        stack_wanderbell.alignment = .fill
        stack_wanderbell.distribution = .fill  // 使用fill，让每个子视图保持自己的内在大小
        return stack_wanderbell
    }()
    
    /// 情绪记录列表
    private let emotionsStackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .vertical
        stack_wanderbell.spacing = 16
        stack_wanderbell.alignment = .fill
        stack_wanderbell.distribution = .fill  // 使用fill，让每个子视图保持自己的内在大小
        return stack_wanderbell
    }()
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        loadUserData_Wanderbell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupCallbacks_Wanderbell()
        observeUserState_Wanderbell()
        
        // 启动动画
        pageTitleView_Wanderbell.startBreathingAnimation_Wanderbell()
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        // 设置个人中心渐变背景
        view.addProfileBackgroundGradient_Wanderbell()
        
        view.addSubview(pageTitleView_Wanderbell)
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        contentContainer_Wanderbell.addSubview(postsStackView_Wanderbell)
        contentContainer_Wanderbell.addSubview(emotionsStackView_Wanderbell)
        
        contentView_Wanderbell.addSubview(userInfoCard_Wanderbell)
        contentView_Wanderbell.addSubview(statsCard_Wanderbell)
        contentView_Wanderbell.addSubview(contentSwitcher_Wanderbell)
        contentView_Wanderbell.addSubview(contentContainer_Wanderbell)
        
        // 初始显示帖子
        emotionsStackView_Wanderbell.isHidden = true
    }
    
    private func setupConstraints_Wanderbell() {
        pageTitleView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(90)
        }
        
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(pageTitleView_Wanderbell.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
        
        userInfoCard_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(200)  // 使用最小高度而不是固定高度
        }
        
        statsCard_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(userInfoCard_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(120)
        }
        
        contentSwitcher_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        contentContainer_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(contentSwitcher_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-120)  // 设置底部边距，让 contentView 可以根据内容自动扩展
        }
        
        postsStackView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()  // 使用 lessThanOrEqualTo 让内容自适应
        }
        
        emotionsStackView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()  // 使用 lessThanOrEqualTo 让内容自适应
        }
    }
    
    private func setupCallbacks_Wanderbell() {
        // 设置按钮回调
        userInfoCard_Wanderbell.onSettingsTapped_Wanderbell = { [weak self] in
            self?.openSettings_Wanderbell()
        }
        
        // 编辑按钮回调
        userInfoCard_Wanderbell.onEditTapped_Wanderbell = { [weak self] in
            self?.openEditInfo_Wanderbell()
        }
        
        // 内容切换回调
        contentSwitcher_Wanderbell.onSwitchChanged_Wanderbell = { [weak self] showPosts_wanderbell in
            self?.switchContent_Wanderbell(showPosts_wanderbell: showPosts_wanderbell)
        }
    }
    
    /// 监听用户状态
    private func observeUserState_Wanderbell() {
        // 监听用户状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Wanderbell),
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
            object: nil
        )
        
        // 监听情绪状态变化（当删除情绪记录时会触发）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEmotionStateChange_Wanderbell),
            name: EmotionViewModel_Wanderbell.emotionStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    // MARK: - 数据加载
    
    private func loadUserData_Wanderbell() {
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        userInfoCard_Wanderbell.configure_Wanderbell(user_wanderbell: currentUser_wanderbell)
        statsCard_Wanderbell.configure_Wanderbell(user_wanderbell: currentUser_wanderbell)
        
        // 加载内容
        loadPosts_Wanderbell()
        loadEmotions_Wanderbell()
    }
    
    private func loadPosts_Wanderbell() {
        postsStackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let posts_wanderbell = currentUser_wanderbell.userPosts_Wanderbell
        
        if posts_wanderbell.isEmpty {
            let emptyView_wanderbell = createEmptyView_Wanderbell(
                icon_wanderbell: "doc.text",
                message_wanderbell: "No posts yet\nShare your emotions with the community!"
            )
            postsStackView_Wanderbell.addArrangedSubview(emptyView_wanderbell)
        } else {
            // 使用和用户中心一样的帖子卡片样式
            for post_wanderbell in posts_wanderbell {
                let postCard_wanderbell = createPostCard_Wanderbell(post: post_wanderbell)
                postsStackView_Wanderbell.addArrangedSubview(postCard_wanderbell)
            }
        }
    }
    
    private func loadEmotions_Wanderbell() {
        emotionsStackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let emotions_wanderbell = currentUser_wanderbell.userEmotionRecords_Wanderbell
            .sorted { $0.timestamp_Wanderbell > $1.timestamp_Wanderbell }
        
        if emotions_wanderbell.isEmpty {
            let emptyView_wanderbell = createEmptyView_Wanderbell(
                icon_wanderbell: "heart.text.square",
                message_wanderbell: "No emotion records yet\nTap + to start recording!"
            )
            emotionsStackView_Wanderbell.addArrangedSubview(emptyView_wanderbell)
        } else {
            for emotion_wanderbell in emotions_wanderbell {
                let cell_wanderbell = EmotionRecordCell_Wanderbell()
                cell_wanderbell.configure_Wanderbell(with: emotion_wanderbell)
                // 设置删除回调，删除后自动刷新列表
                cell_wanderbell.onDelete_Wanderbell = { [weak self] in
                    self?.loadEmotions_Wanderbell()
                }
                emotionsStackView_Wanderbell.addArrangedSubview(cell_wanderbell)
            }
        }
    }
    
    /// 创建帖子卡片
    /// 功能：创建单个帖子的卡片视图（使用和用户中心一样的样式）
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
            
            // 添加删除按钮（在图片上方）
            let deleteButton_wanderbell = ReportDeleteHelper_Wanderbell.createPostReportButton_Wanderbell(
                post_wanderbell: post,
                size_wanderbell: 30,
                color_wanderbell: .white,
                from: self
            ) { [weak self] in
                // 操作完成后刷新数据
                self?.loadPosts_Wanderbell()
            }
            
            // 添加按钮背景
            let buttonContainer_wanderbell = UIView()
            buttonContainer_wanderbell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            buttonContainer_wanderbell.layer.cornerRadius = 18
            cardView_wanderbell.addSubview(buttonContainer_wanderbell)
            buttonContainer_wanderbell.addSubview(deleteButton_wanderbell)
            
            buttonContainer_wanderbell.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.width.height.equalTo(36)
            }
            
            deleteButton_wanderbell.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(30)
            }
        } else {
            // 没有图片时，标题从卡片顶部开始
            titleTopAnchor_wanderbell = cardView_wanderbell.snp.top
            titleTopOffset_wanderbell = 50  // 为删除按钮留出空间
            
            // 添加删除按钮到卡片右上角
            let deleteButton_wanderbell = ReportDeleteHelper_Wanderbell.createPostReportButton_Wanderbell(
                post_wanderbell: post,
                size_wanderbell: 30,
                color_wanderbell: ColorConfig_Wanderbell.textSecondary_Wanderbell,
                from: self
            ) { [weak self] in
                // 操作完成后刷新数据
                self?.loadPosts_Wanderbell()
            }
            
            cardView_wanderbell.addSubview(deleteButton_wanderbell)
            
            deleteButton_wanderbell.snp.makeConstraints { make in
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
        
        print("📝 创建帖子卡片 - 标题: \(post.title_Wanderbell), 内容: \(post.titleContent_Wanderbell), 媒体: \(post.titleMeidas_Wanderbell.first ?? "无")")
        
        return cardView_wanderbell
    }
    
    private func createEmptyView_Wanderbell(icon_wanderbell: String, message_wanderbell: String) -> UIView {
        let container_wanderbell = UIView()
        container_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        container_wanderbell.layer.cornerRadius = 20
        
        let iconView_wanderbell = UIImageView()
        iconView_wanderbell.image = UIImage(systemName: icon_wanderbell)
        iconView_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        iconView_wanderbell.contentMode = .scaleAspectFit
        
        let label_wanderbell = UILabel()
        label_wanderbell.text = message_wanderbell
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        label_wanderbell.numberOfLines = 0
        
        container_wanderbell.addSubview(iconView_wanderbell)
        container_wanderbell.addSubview(label_wanderbell)
        
        iconView_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.height.equalTo(60)
        }
        
        label_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView_wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        container_wanderbell.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        return container_wanderbell
    }
    
    // MARK: - 事件处理
    
    private func openSettings_Wanderbell() {
        Navigation_Wanderbell.toSetting_Wanderbell(style_wanderbell: .push_wanderbell)
    }
    
    private func openEditInfo_Wanderbell() {
        Navigation_Wanderbell.toEditInfo_Wanderbell(style_wanderbell: .push_wanderbell)
    }
    
    private func switchContent_Wanderbell(showPosts_wanderbell: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.postsStackView_Wanderbell.alpha = showPosts_wanderbell ? 1 : 0
            self.emotionsStackView_Wanderbell.alpha = showPosts_wanderbell ? 0 : 1
        }
        
        postsStackView_Wanderbell.isHidden = !showPosts_wanderbell
        emotionsStackView_Wanderbell.isHidden = showPosts_wanderbell
    }
    
    @objc private func handleUserStateChange_Wanderbell() {
        loadUserData_Wanderbell()
    }
    
    /// 处理情绪状态变化
    /// 功能：当情绪记录被删除或修改时，自动刷新情绪记录列表
    @objc private func handleEmotionStateChange_Wanderbell() {
        loadEmotions_Wanderbell()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
