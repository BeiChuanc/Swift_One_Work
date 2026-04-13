import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页面

/// 用户中心页面
/// 核心作用：展示预置用户的个人信息、帖子网格，支持关注、进入聊天及举报操作
/// 设计思路：
///   渐变大头部（头像 + 名称 + 简介 + 统计）→ 操作按钮行（Follow / Chat）→
///   分段 Tab（Posts / Liked）→ 2 列帖子网格（每项右上角附举报/删除按钮）
/// 关键属性/方法：
///   - userModel_Tidy：目标用户（由外部注入）
///   - loadUserPosts_Tidy()：拉取该用户的帖子数据
///   - followTapped_Tidy()：关注/取消关注
///   - chatTapped_Tidy()：以 Replace 方式进入聊天页
class UserInfo_Tidy: UIViewController {

    // MARK: - 公开属性

    /// 目标用户模型（由导航层注入）
    var userModel_Tidy: PrewUserModel_Tidy?

    // MARK: - 私有数据属性

    /// 当前分段：0=Posts  1=Liked
    private var currentSegment_Tidy: Int = 0

    /// 当前展示的帖子列表
    private var displayPosts_Tidy: [TitleModel_Tidy] = []

    /// 该用户发布的帖子
    private var userPosts_Tidy: [TitleModel_Tidy] = []

    /// 该用户喜欢的帖子
    private var likedPosts_Tidy: [TitleModel_Tidy] = []

    /// 帖子网格布局参数
    private let columns_Tidy: CGFloat = 2
    private let gridSpacing_Tidy: CGFloat = 12
    private let gridPadding_Tidy: CGFloat = 16

    // MARK: - UI 组件 - 主滚动容器

    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Tidy = UIView()

    // MARK: - UI 组件 - 头部渐变区

    /// 渐变头部容器（底部双圆角）
    private let headerView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradient_Tidy = CAGradientLayer()

    /// 装饰气泡 1
    private let decoBubble1_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 70
        return v
    }()

    /// 装饰气泡 2
    private let decoBubble2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 装饰气泡 3（小光晕）
    private let decoBubble3_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 30
        return v
    }()

    // MARK: - UI 组件 - 顶部导航行

    /// 返回按钮
    private let backBtn_Tidy = BackButton_Tidy()

    /// 右上角举报按钮（使用助手类创建）
    private let reportBtn_Tidy = ReportDeleteHelper_Tidy.createUserReportButton_Tidy(
        size_Tidy: 36,
        backgroundColor_Tidy: UIColor.white.withAlphaComponent(0.20),
        tintColor_Tidy: .white,
        withShadow_Tidy: false
    )

    // MARK: - UI 组件 - 用户信息区

    /// 头像外圈渐变光环
    private let avatarRingView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 46
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGradient_Tidy: CAGradientLayer?

    /// 用户头像
    private let avatarView_Tidy: UserAvatarView_Tidy = {
        let v = UserAvatarView_Tidy()
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        return v
    }()

    private let nameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let bioLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.80)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI 组件 - 统计数据行

    private let statsRow_Tidy = UIView()

    // MARK: - UI 组件 - 操作按钮行

    private let actionRow_Tidy = UIView()

    /// 关注按钮（Follow / Followed）
    private let followBtn_Tidy: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        return btn
    }()

    /// 进入聊天按钮（Chat）
    private let chatBtn_Tidy: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Chat", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 20
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "bubble.left.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        return btn
    }()

    private var chatGradient_Tidy: CAGradientLayer?

    // MARK: - UI 组件 - 分段控制

    private let segmentContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        return v
    }()

    private let segmentControl_Tidy: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Posts", "Liked"])
        seg.selectedSegmentIndex = 0
        seg.selectedSegmentTintColor = ColorConfig_Tidy.tidyMint_Tidy
        seg.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Tidy.textSecondary_Tidy,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        return seg
    }()

    // MARK: - UI 组件 - 帖子网格

    private var postsCollectionView_Tidy: UICollectionView!
    private var collectionViewHeightConstraint_Tidy: Constraint?

    // MARK: - UI 组件 - 空状态

    private let emptyView_Tidy: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return iv
    }()

    private let emptyLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    /// 状态栏使用白色文字，与渐变头部一致
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 无论是初始 push 进来还是从 modal 返回，都保持导航栏隐藏
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // iOS 13+ 非全屏 modal 弹出时也会触发 viewWillDisappear
        // 只有当页面真正从导航栈 pop 走时才恢复导航栏，避免 alert 弹出导致导航栏状态错乱
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupScrollView_Tidy()
        setupHeader_Tidy()
        setupStats_Tidy()
        setupActionRow_Tidy()
        setupSegment_Tidy()
        setupPostsGrid_Tidy()
        setupEmptyView_Tidy()
        bindActions_Tidy()
        configureUserInfo_Tidy()
        loadUserPosts_Tidy()
        observeNotifications_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderGradient_Tidy()
        updateAvatarRing_Tidy()
        updateChatButtonGradient_Tidy()
    }

    // MARK: - UI 搭建

    /// 搭建主滚动视图和内容容器
    private func setupScrollView_Tidy() {
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentView_Tidy)

        scrollView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Tidy)
        }
    }

    /// 搭建渐变头部区域
    private func setupHeader_Tidy() {
        nameLabel_Tidy.textAlignment = .left
        bioLabel_Tidy.textAlignment = .left
        bioLabel_Tidy.numberOfLines = 3
        contentView_Tidy.addSubview(headerView_Tidy)
        headerView_Tidy.addSubview(decoBubble1_Tidy)
        headerView_Tidy.addSubview(decoBubble2_Tidy)
        headerView_Tidy.addSubview(decoBubble3_Tidy)
        headerView_Tidy.addSubview(avatarRingView_Tidy)
        avatarRingView_Tidy.addSubview(avatarView_Tidy)
        headerView_Tidy.addSubview(nameLabel_Tidy)
        headerView_Tidy.addSubview(bioLabel_Tidy)
        headerView_Tidy.addSubview(backBtn_Tidy)
        headerView_Tidy.addSubview(reportBtn_Tidy)

        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        headerView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 248)
        }
        decoBubble1_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(34)
            make.top.equalToSuperview().offset(-26)
            make.width.height.equalTo(180)
        }
        decoBubble2_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(44)
            make.width.height.equalTo(140)
        }
        decoBubble3_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(safeTop + 26)
            make.width.height.equalTo(70)
        }
        backBtn_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(safeTop + 8)
            make.width.height.equalTo(40)
        }
        reportBtn_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backBtn_Tidy)
            make.width.height.equalTo(36)
        }
        avatarRingView_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(safeTop + 62)
            make.width.height.equalTo(96)
        }
        avatarView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(84)
        }
        nameLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(avatarRingView_Tidy.snp.trailing).offset(18)
            make.trailing.equalToSuperview().offset(-22)
            make.top.equalTo(avatarRingView_Tidy).offset(8)
        }
        bioLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Tidy.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel_Tidy)
            make.trailing.equalToSuperview().offset(-22)
            make.bottom.lessThanOrEqualToSuperview().offset(-76)
        }
    }

    /// 搭建统计数据行（帖子数 / 关注数 / 粉丝数）
    private func setupStats_Tidy() {
        contentView_Tidy.addSubview(statsRow_Tidy)
        statsRow_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.96)
        statsRow_Tidy.layer.cornerRadius = 22
        statsRow_Tidy.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        statsRow_Tidy.layer.shadowOffset = CGSize(width: 0, height: 12)
        statsRow_Tidy.layer.shadowRadius = 24
        statsRow_Tidy.layer.shadowOpacity = 1
        statsRow_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerView_Tidy.snp.bottom).offset(-30)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(82)
        }

        let statsData_Tidy: [(String, String)] = [
            ("Posts", "\(userModel_Tidy?.userId_Tidy ?? 0)"),
            ("Following", "\(userModel_Tidy?.userFollow_Tidy ?? 0)"),
            ("Fans", "\(userModel_Tidy?.userFans_Tidy ?? 0)")
        ]

        var lastItem_Tidy: UIView? = nil
        for (index_Tidy, stat_Tidy) in statsData_Tidy.enumerated() {
            let item_Tidy = buildStatItem_Tidy(value: stat_Tidy.1, label: stat_Tidy.0)
            statsRow_Tidy.addSubview(item_Tidy)
            item_Tidy.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalToSuperview().dividedBy(3)
                if let last = lastItem_Tidy {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            if index_Tidy < statsData_Tidy.count - 1 {
                let divider_Tidy = UIView()
                divider_Tidy.backgroundColor = ColorConfig_Tidy.divider_Tidy
                statsRow_Tidy.addSubview(divider_Tidy)
                divider_Tidy.snp.makeConstraints { make in
                    make.width.equalTo(1)
                    make.height.equalTo(28)
                    make.centerY.equalToSuperview()
                    make.leading.equalTo(item_Tidy.snp.trailing)
                }
            }
            lastItem_Tidy = item_Tidy
        }
    }

    /// 搭建操作按钮行（Follow + Chat）
    private func setupActionRow_Tidy() {
        contentView_Tidy.addSubview(actionRow_Tidy)
        actionRow_Tidy.addSubview(followBtn_Tidy)
        actionRow_Tidy.addSubview(chatBtn_Tidy)

        actionRow_Tidy.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        followBtn_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(chatBtn_Tidy.snp.leading).offset(-12)
            make.width.equalTo(chatBtn_Tidy.snp.width).multipliedBy(1.15)
        }
        chatBtn_Tidy.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
        }

        updateFollowButton_Tidy()
    }

    /// 搭建分段控制（Posts / Liked）
    private func setupSegment_Tidy() {
        contentView_Tidy.addSubview(segmentContainer_Tidy)
        segmentContainer_Tidy.addSubview(segmentControl_Tidy)

        segmentContainer_Tidy.snp.makeConstraints { make in
            make.top.equalTo(actionRow_Tidy.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        segmentControl_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }

    /// 搭建帖子网格 CollectionView
    private func setupPostsGrid_Tidy() {
        let layout_Tidy = UICollectionViewFlowLayout()
        layout_Tidy.scrollDirection = .vertical
        layout_Tidy.minimumInteritemSpacing = gridSpacing_Tidy
        layout_Tidy.minimumLineSpacing = gridSpacing_Tidy

        postsCollectionView_Tidy = UICollectionView(frame: .zero, collectionViewLayout: layout_Tidy)
        postsCollectionView_Tidy.register(UserInfoPostCell_Tidy.self,
                                               forCellWithReuseIdentifier: UserInfoPostCell_Tidy.reuseId_Tidy)
        postsCollectionView_Tidy.backgroundColor = .clear
        postsCollectionView_Tidy.isScrollEnabled = false
        postsCollectionView_Tidy.showsVerticalScrollIndicator = false
        postsCollectionView_Tidy.delegate = self
        postsCollectionView_Tidy.dataSource = self

        contentView_Tidy.addSubview(postsCollectionView_Tidy)
        postsCollectionView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Tidy.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(gridPadding_Tidy)
            make.bottom.equalToSuperview().offset(-24)
            collectionViewHeightConstraint_Tidy = make.height.equalTo(0).constraint
        }
    }

    /// 搭建空状态视图
    private func setupEmptyView_Tidy() {
        contentView_Tidy.addSubview(emptyView_Tidy)
        emptyView_Tidy.addSubview(emptyIconView_Tidy)
        emptyView_Tidy.addSubview(emptyLabel_Tidy)

        emptyView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        emptyIconView_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        emptyLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Tidy.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 渐变更新

    /// 更新头部渐变图层（viewDidLayoutSubviews 后调用）
    private func updateHeaderGradient_Tidy() {
        guard headerView_Tidy.bounds.width > 0 else { return }
        if headerGradient_Tidy.superlayer == nil {
            headerGradient_Tidy.colors = [
                ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
                ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor,
                ColorConfig_Tidy.tidyMintDeep_Tidy.cgColor
            ]
            headerGradient_Tidy.startPoint = CGPoint(x: 0, y: 0)
            headerGradient_Tidy.endPoint = CGPoint(x: 1, y: 1)
            headerView_Tidy.layer.insertSublayer(headerGradient_Tidy, at: 0)
        }
        headerGradient_Tidy.frame = headerView_Tidy.bounds
    }

    /// 更新头像光环渐变（viewDidLayoutSubviews 后调用）
    private func updateAvatarRing_Tidy() {
        guard avatarRingView_Tidy.bounds.width > 0, avatarRingGradient_Tidy == nil else { return }
        let grad_Tidy = UIColor.createSecondaryGradientLayer_Tidy(frame_Tidy: avatarRingView_Tidy.bounds)
        grad_Tidy.cornerRadius = 46
        avatarRingView_Tidy.layer.insertSublayer(grad_Tidy, at: 0)
        avatarRingGradient_Tidy = grad_Tidy
    }

    /// 更新 Chat 按钮渐变（viewDidLayoutSubviews 后调用）
    private func updateChatButtonGradient_Tidy() {
        guard chatBtn_Tidy.bounds.width > 0 else { return }
        if chatGradient_Tidy == nil {
            let grad_Tidy = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: chatBtn_Tidy.bounds)
            grad_Tidy.cornerRadius = 20
            chatBtn_Tidy.layer.insertSublayer(grad_Tidy, at: 0)
            chatGradient_Tidy = grad_Tidy
        } else {
            chatGradient_Tidy?.frame = chatBtn_Tidy.bounds
        }
    }

    // MARK: - 操作绑定

    /// 绑定所有按钮事件
    private func bindActions_Tidy() {
        backBtn_Tidy.onTapped_Tidy = { Navigation_Tidy.pop_Tidy() }
        reportBtn_Tidy.addTarget(self, action: #selector(reportUserTapped_Tidy), for: .touchUpInside)
        followBtn_Tidy.addTarget(self, action: #selector(followTapped_Tidy), for: .touchUpInside)
        chatBtn_Tidy.addTarget(self, action: #selector(chatTapped_Tidy), for: .touchUpInside)
        segmentControl_Tidy.addTarget(self, action: #selector(segmentChanged_Tidy(_:)), for: .valueChanged)
    }

    // MARK: - 数据加载与配置

    /// 根据注入的用户模型配置页面显示信息
    private func configureUserInfo_Tidy() {
        guard let user_Tidy = userModel_Tidy else { return }
        nameLabel_Tidy.text = user_Tidy.userName_Tidy ?? "Unknown"
        bioLabel_Tidy.text = user_Tidy.userIntroduce_Tidy ?? "No bio yet."
        if let userId_Tidy = user_Tidy.userId_Tidy {
            avatarView_Tidy.configure_Tidy(userId_Tidy: userId_Tidy)
        }
        updateFollowButton_Tidy()
        updateStatsLabels_Tidy()
    }

    /// 加载该用户的帖子数据并刷新网格
    /// 对 Liked 列表额外过滤：排除已被举报/删除的帖子（保证 UI 与 ViewModel 数据一致）
    private func loadUserPosts_Tidy() {
        guard let user_Tidy = userModel_Tidy else { return }
        userPosts_Tidy = TitleViewModel_Tidy.shared_Tidy.getUserPosts_Tidy(user_tidy: user_Tidy)
        let activeIds_Tidy = Set(
            TitleViewModel_Tidy.shared_Tidy.getPosts_Tidy().map { $0.titleId_Tidy }
        )
        likedPosts_Tidy = user_Tidy.userLike_Tidy.filter { activeIds_Tidy.contains($0.titleId_Tidy) }
        switchSegment_Tidy(to: currentSegment_Tidy)
    }

    /// 切换分段并刷新帖子列表
    /// - Parameter index_Tidy: 分段下标（0=Posts, 1=Liked）
    private func switchSegment_Tidy(to index_Tidy: Int) {
        currentSegment_Tidy = index_Tidy
        displayPosts_Tidy = index_Tidy == 0 ? userPosts_Tidy : likedPosts_Tidy
        postsCollectionView_Tidy.reloadData()
        updateCollectionViewHeight_Tidy()
        let isEmpty_Tidy = displayPosts_Tidy.isEmpty
        emptyView_Tidy.isHidden = !isEmpty_Tidy
        postsCollectionView_Tidy.isHidden = isEmpty_Tidy
        emptyIconView_Tidy.image = UIImage(systemName: index_Tidy == 0 ? "square.grid.2x2" : "heart")
        emptyLabel_Tidy.text = index_Tidy == 0 ? "No posts yet" : "No liked posts"
    }

    /// 更新统计数据标签（Posts 数量从实时数据中获取）
    private func updateStatsLabels_Tidy() {
        guard let user_Tidy = userModel_Tidy else { return }
        let postsCount_Tidy = TitleViewModel_Tidy.shared_Tidy
            .getUserPosts_Tidy(user_tidy: user_Tidy).count
        // 重建统计行
        statsRow_Tidy.subviews.forEach { $0.removeFromSuperview() }
        let statsData_Tidy: [(String, String)] = [
            ("Posts", "\(postsCount_Tidy)"),
            ("Following", "\(user_Tidy.userFollow_Tidy ?? 0)"),
            ("Fans", "\(user_Tidy.userFans_Tidy ?? 0)")
        ]
        var lastItem_Tidy: UIView? = nil
        for (index_Tidy, stat_Tidy) in statsData_Tidy.enumerated() {
            let item_Tidy = buildStatItem_Tidy(value: stat_Tidy.1, label: stat_Tidy.0)
            statsRow_Tidy.addSubview(item_Tidy)
            item_Tidy.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalToSuperview().dividedBy(3)
                if let last = lastItem_Tidy {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            if index_Tidy < statsData_Tidy.count - 1 {
                let divider_Tidy = UIView()
                divider_Tidy.backgroundColor = ColorConfig_Tidy.divider_Tidy
                statsRow_Tidy.addSubview(divider_Tidy)
                divider_Tidy.snp.makeConstraints { make in
                    make.width.equalTo(1)
                    make.height.equalTo(28)
                    make.centerY.equalToSuperview()
                    make.leading.equalTo(item_Tidy.snp.trailing)
                }
            }
            lastItem_Tidy = item_Tidy
        }
    }

    /// 更新 CollectionView 的高度约束，使 ScrollView 能自适应帖子总高度
    private func updateCollectionViewHeight_Tidy() {
        let screenWidth_Tidy = UIScreen.main.bounds.width
        let totalHorizontalInset_Tidy = gridPadding_Tidy * 2
        let totalSpacing_Tidy = gridSpacing_Tidy * (columns_Tidy - 1)
        let itemWidth_Tidy = (screenWidth_Tidy - totalHorizontalInset_Tidy - totalSpacing_Tidy) / columns_Tidy
        let itemHeight_Tidy = itemWidth_Tidy * 1.35

        let rowCount_Tidy = ceil(CGFloat(displayPosts_Tidy.count) / columns_Tidy)
        let totalHeight_Tidy = rowCount_Tidy * itemHeight_Tidy + max(0, rowCount_Tidy - 1) * gridSpacing_Tidy
        collectionViewHeightConstraint_Tidy?.update(offset: totalHeight_Tidy)
    }

    // MARK: - 通知监听

    /// 订阅帖子变化和用户状态变化通知
    private func observeNotifications_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleChanged_Tidy),
            name: TitleViewModel_Tidy.titleStateDidChangeNotification_Tidy, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserChanged_Tidy),
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy, object: nil
        )
    }

    @objc private func onTitleChanged_Tidy() {
        loadUserPosts_Tidy()
    }

    @objc private func onUserChanged_Tidy() {
        // 关注状态变化时同步刷新按钮样式与统计数字（粉丝数随之变化）
        updateFollowButton_Tidy()
        updateStatsLabels_Tidy()
    }

    // MARK: - 事件处理

    /// 点击举报按钮（拉黑用户）
    @objc private func reportUserTapped_Tidy() {
        guard let user_Tidy = userModel_Tidy else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.reportBtn_Tidy.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.reportBtn_Tidy.transform = .identity }
        })
        // 等待 ActionSheet dismiss 动画完成（约 0.3s）后再 pop，
        // 避免 pop 与 modal 收起动画并发导致生命周期乱序、导航栏状态异常
        ReportDeleteHelper_Tidy.block_Tidy(user_Tidy: user_Tidy, from: self) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    /// 点击关注按钮
    @objc private func followTapped_Tidy() {
        guard let user_Tidy = userModel_Tidy else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.followBtn_Tidy.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.followBtn_Tidy.transform = .identity }
        })
        UserViewModel_Tidy.shared_Tidy.followUser_Tidy(user_tidy: user_Tidy)
        updateFollowButton_Tidy()
    }

    /// 点击聊天按钮
    /// 流程：未登录 → 跳转登录页；未关注 → 提示先关注；已关注 → 弹出确认底部弹窗
    @objc private func chatTapped_Tidy() {
        guard let user_Tidy = userModel_Tidy else { return }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.chatBtn_Tidy.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.chatBtn_Tidy.transform = .identity }
        })

        // 第一步：检查是否已登录
        guard UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy else {
            Navigation_Tidy.toLogin_Tidy()
            return
        }

        // 第二步：检查是否已关注该用户
        let isFollowing_Tidy = UserViewModel_Tidy.shared_Tidy.isFollowing_Tidy(user_tidy: user_Tidy)
        guard isFollowing_Tidy else {
            Utils_Tidy.showBanner_Tidy(
                title_Tidy: "Follow Required",
                message_Tidy: "Please follow this user before starting a chat"
            )
            return
        }

        // 第三步：弹出确认底部弹窗，确认后进入聊天页
        showChatConfirmSheet_Tidy(user_Tidy: user_Tidy)
    }

    /// 展示聊天确认底部弹窗
    /// - Parameter user_Tidy: 目标用户模型
    private func showChatConfirmSheet_Tidy(user_Tidy: PrewUserModel_Tidy) {
        guard let window_Tidy = view.window else { return }
        let sheet_Tidy = ChatConfirmSheet_Tidy(userModel_Tidy: user_Tidy)
        sheet_Tidy.onConfirm_Tidy = { [weak self] in
            guard self != nil else { return }
            Navigation_Tidy.toMessageUser_Tidy(with: user_Tidy, style_tidy: .replace_tidy)
        }
        sheet_Tidy.present_Tidy(in: window_Tidy)
    }

    /// 分段切换
    @objc private func segmentChanged_Tidy(_ sender: UISegmentedControl) {
        switchSegment_Tidy(to: sender.selectedSegmentIndex)
    }

    // MARK: - UI 状态刷新

    /// 更新关注按钮的状态和样式
    private func updateFollowButton_Tidy() {
        guard let user_Tidy = userModel_Tidy else { return }
        let isFollowing_Tidy = UserViewModel_Tidy.shared_Tidy.isFollowing_Tidy(user_tidy: user_Tidy)
        if isFollowing_Tidy {
            followBtn_Tidy.setTitle("Followed", for: .normal)
            followBtn_Tidy.setTitleColor(ColorConfig_Tidy.textSecondary_Tidy, for: .normal)
            followBtn_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
            followBtn_Tidy.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
            followBtn_Tidy.tintColor = ColorConfig_Tidy.textSecondary_Tidy
        } else {
            followBtn_Tidy.setTitle("Follow", for: .normal)
            followBtn_Tidy.setTitleColor(.white, for: .normal)
            followBtn_Tidy.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
            followBtn_Tidy.layer.borderColor = UIColor.clear.cgColor
            followBtn_Tidy.tintColor = .white
        }
    }

    // MARK: - 辅助构建

    /// 构建统计项视图（数值 + 标题竖向排列）
    /// - Parameters:
    ///   - value_Tidy: 数值字符串
    ///   - label_Tidy: 标题（英文）
    /// - Returns: 组合视图
    private func buildStatItem_Tidy(value: String, label: String) -> UIView {
        let container_Tidy = UIView()

        let valueLabel_Tidy = UILabel()
        valueLabel_Tidy.text = value
        valueLabel_Tidy.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel_Tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy
        valueLabel_Tidy.textAlignment = .center

        let titleLabel_Tidy = UILabel()
        titleLabel_Tidy.text = label
        titleLabel_Tidy.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel_Tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        titleLabel_Tidy.textAlignment = .center

        container_Tidy.addSubview(valueLabel_Tidy)
        container_Tidy.addSubview(titleLabel_Tidy)

        valueLabel_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Tidy.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
        }
        return container_Tidy
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension UserInfo_Tidy: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Tidy.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Tidy = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserInfoPostCell_Tidy.reuseId_Tidy,
            for: indexPath
        ) as! UserInfoPostCell_Tidy

        let post_Tidy = displayPosts_Tidy[indexPath.item]
        cell_Tidy.configure_Tidy(post: post_Tidy)

        // 注入举报/删除按钮（使用助手类）
        cell_Tidy.actionContainer_Tidy.subviews.forEach { $0.removeFromSuperview() }
        let actionBtn_Tidy = ReportDeleteHelper_Tidy.createPostReportButton_Tidy(
            post_Tidy: post_Tidy,
            size_Tidy: 22,
            color_Tidy: .white,
            from: self
        ) { [weak self] in
            self?.loadUserPosts_Tidy()
        }
        cell_Tidy.actionContainer_Tidy.addSubview(actionBtn_Tidy)
        actionBtn_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }

        return cell_Tidy
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth_Tidy = UIScreen.main.bounds.width
        let totalHorizontalInset_Tidy = gridPadding_Tidy * 2
        let totalSpacing_Tidy = gridSpacing_Tidy * (columns_Tidy - 1)
        let itemWidth_Tidy = (screenWidth_Tidy - totalHorizontalInset_Tidy - totalSpacing_Tidy) / columns_Tidy
        return CGSize(width: itemWidth_Tidy, height: itemWidth_Tidy * 1.35)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Tidy = displayPosts_Tidy[indexPath.item]
        Navigation_Tidy.toTitleDetail_Tidy(titleModel_tidy: post_Tidy)
    }
}

// MARK: - 帖子卡片 Cell

/// 用户中心帖子网格单元格
/// 功能：展示帖子封面图、标题、点赞数，右上角预留举报/删除按钮容器
/// 关键属性：actionContainer_Tidy（外部注入举报按钮）
class UserInfoPostCell_Tidy: UICollectionViewCell {

    static let reuseId_Tidy = "UserInfoPostCell_Tidy"

    // MARK: - UI 组件

    /// 封面媒体展示（复用 MediaDisplayView）
    private let mediaView_Tidy: MediaDisplayView_Tidy = {
        let v = MediaDisplayView_Tidy()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    /// 底部渐变蒙层（提升文字可读性）
    private let gradientOverlay_Tidy: UIView = {
        let v = UIView()
        return v
    }()

    private let gradientLayer_Tidy = CAGradientLayer()

    private let titleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        l.shadowColor = UIColor.black.withAlphaComponent(0.3)
        l.shadowOffset = CGSize(width: 0, height: 1)
        return l
    }()

    private let likeIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.fill")
        iv.tintColor = ColorConfig_Tidy.secondaryGradientStart_Tidy
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likeLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = .white
        l.shadowColor = UIColor.black.withAlphaComponent(0.3)
        l.shadowOffset = CGSize(width: 0, height: 1)
        return l
    }()

    /// 举报/删除按钮容器（由外部注入实际按钮）
    let actionContainer_Tidy = UIView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 14
        gradientLayer_Tidy.frame = gradientOverlay_Tidy.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        actionContainer_Tidy.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 14
        contentView.backgroundColor = ColorConfig_Tidy.cardBackground_Tidy

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 8
        layer.masksToBounds = false

        contentView.addSubview(mediaView_Tidy)
        contentView.addSubview(gradientOverlay_Tidy)
        contentView.addSubview(titleLabel_Tidy)
        contentView.addSubview(likeIconView_Tidy)
        contentView.addSubview(likeLabel_Tidy)
        contentView.addSubview(actionContainer_Tidy)

        gradientLayer_Tidy.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.60).cgColor]
        gradientLayer_Tidy.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer_Tidy.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay_Tidy.layer.addSublayer(gradientLayer_Tidy)

        mediaView_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
        gradientOverlay_Tidy.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        actionContainer_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalTo(likeIconView_Tidy.snp.top).offset(-4)
        }
        likeIconView_Tidy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(12)
        }
        likeLabel_Tidy.snp.makeConstraints { make in
            make.left.equalTo(likeIconView_Tidy.snp.right).offset(4)
            make.centerY.equalTo(likeIconView_Tidy)
        }
    }

    // MARK: - 配置

    /// 用帖子数据配置单元格
    /// - Parameter post_Tidy: 帖子数据模型
    func configure_Tidy(post post_Tidy: TitleModel_Tidy) {
        titleLabel_Tidy.text = post_Tidy.title_Tidy
        likeLabel_Tidy.text = "\(post_Tidy.likes_Tidy)"
        mediaView_Tidy.configure_Tidy(
            mediaPath_Tidy: post_Tidy.titleMeidas_Tidy.first,
            isVideo_Tidy: false
        )
    }
}
