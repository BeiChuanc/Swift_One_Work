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
///   - userModel_Base_one：目标用户（由外部注入）
///   - loadUserPosts_Base_one()：拉取该用户的帖子数据
///   - followTapped_Base_one()：关注/取消关注
///   - chatTapped_Base_one()：以 Replace 方式进入聊天页
class UserInfo_Base_one: UIViewController {

    // MARK: - 公开属性

    /// 目标用户模型（由导航层注入）
    var userModel_Base_one: PrewUserModel_Base_one?

    // MARK: - 私有数据属性

    /// 当前分段：0=Posts  1=Liked
    private var currentSegment_Base_one: Int = 0

    /// 当前展示的帖子列表
    private var displayPosts_Base_one: [TitleModel_Base_one] = []

    /// 该用户发布的帖子
    private var userPosts_Base_one: [TitleModel_Base_one] = []

    /// 该用户喜欢的帖子
    private var likedPosts_Base_one: [TitleModel_Base_one] = []

    /// 帖子网格布局参数
    private let columns_Base_one: CGFloat = 2
    private let gridSpacing_Base_one: CGFloat = 12
    private let gridPadding_Base_one: CGFloat = 16

    // MARK: - UI 组件 - 主滚动容器

    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Base_one = UIView()

    // MARK: - UI 组件 - 头部渐变区

    /// 渐变头部容器（底部双圆角）
    private let headerView_Base_one: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradient_Base_one = CAGradientLayer()

    /// 装饰气泡 1
    private let decoBubble1_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 70
        return v
    }()

    /// 装饰气泡 2
    private let decoBubble2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 装饰气泡 3（小光晕）
    private let decoBubble3_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 30
        return v
    }()

    // MARK: - UI 组件 - 顶部导航行

    /// 返回按钮
    private let backBtn_Base_one = BackButton_Base_one()

    /// 右上角举报按钮（使用助手类创建）
    private let reportBtn_Base_one = ReportDeleteHelper_Base_one.createUserReportButton_Base_one(
        size_Base_one: 36,
        backgroundColor_Base_one: UIColor.white.withAlphaComponent(0.20),
        tintColor_Base_one: .white,
        withShadow_Base_one: false
    )

    // MARK: - UI 组件 - 用户信息区

    /// 头像外圈渐变光环
    private let avatarRingView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 46
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGradient_Base_one: CAGradientLayer?

    /// 用户头像
    private let avatarView_Base_one: UserAvatarView_Base_one = {
        let v = UserAvatarView_Base_one()
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        return v
    }()

    private let nameLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let bioLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.80)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI 组件 - 统计数据行

    private let statsRow_Base_one = UIView()

    // MARK: - UI 组件 - 操作按钮行

    private let actionRow_Base_one = UIView()

    /// 关注按钮（Follow / Followed）
    private let followBtn_Base_one: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        return btn
    }()

    /// 进入聊天按钮（Chat）
    private let chatBtn_Base_one: UIButton = {
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

    private var chatGradient_Base_one: CAGradientLayer?

    // MARK: - UI 组件 - 分段控制

    private let segmentContainer_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        return v
    }()

    private let segmentControl_Base_one: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Posts", "Liked"])
        seg.selectedSegmentIndex = 0
        seg.selectedSegmentTintColor = ColorConfig_Base_one.tidyMint_Base_one
        seg.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Base_one.textSecondary_Base_one,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        return seg
    }()

    // MARK: - UI 组件 - 帖子网格

    private var postsCollectionView_Base_one: UICollectionView!
    private var collectionViewHeightConstraint_Base_one: Constraint?

    // MARK: - UI 组件 - 空状态

    private let emptyView_Base_one: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return iv
    }()

    private let emptyLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
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
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        setupScrollView_Base_one()
        setupHeader_Base_one()
        setupStats_Base_one()
        setupActionRow_Base_one()
        setupSegment_Base_one()
        setupPostsGrid_Base_one()
        setupEmptyView_Base_one()
        bindActions_Base_one()
        configureUserInfo_Base_one()
        loadUserPosts_Base_one()
        observeNotifications_Base_one()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderGradient_Base_one()
        updateAvatarRing_Base_one()
        updateChatButtonGradient_Base_one()
    }

    // MARK: - UI 搭建

    /// 搭建主滚动视图和内容容器
    private func setupScrollView_Base_one() {
        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentView_Base_one)

        scrollView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Base_one)
        }
    }

    /// 搭建渐变头部区域
    private func setupHeader_Base_one() {
        contentView_Base_one.addSubview(headerView_Base_one)
        headerView_Base_one.addSubview(decoBubble1_Base_one)
        headerView_Base_one.addSubview(decoBubble2_Base_one)
        headerView_Base_one.addSubview(decoBubble3_Base_one)
        headerView_Base_one.addSubview(avatarRingView_Base_one)
        avatarRingView_Base_one.addSubview(avatarView_Base_one)
        headerView_Base_one.addSubview(nameLabel_Base_one)
        headerView_Base_one.addSubview(bioLabel_Base_one)
        headerView_Base_one.addSubview(backBtn_Base_one)
        headerView_Base_one.addSubview(reportBtn_Base_one)

        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        headerView_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 280)
        }
        decoBubble1_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(180)
        }
        decoBubble2_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(40)
            make.width.height.equalTo(140)
        }
        decoBubble3_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(60)
            make.top.equalToSuperview().offset(safeTop + 30)
            make.width.height.equalTo(70)
        }
        backBtn_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(safeTop + 6)
            make.width.height.equalTo(40)
        }
        reportBtn_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(backBtn_Base_one)
            make.width.height.equalTo(36)
        }
        avatarRingView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(safeTop + 54)
            make.width.height.equalTo(92)
        }
        avatarView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        nameLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Base_one.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        bioLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Base_one.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    /// 搭建统计数据行（帖子数 / 关注数 / 粉丝数）
    private func setupStats_Base_one() {
        contentView_Base_one.addSubview(statsRow_Base_one)
        statsRow_Base_one.snp.makeConstraints { make in
            make.top.equalTo(headerView_Base_one.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }

        let statsData_Base_one: [(String, String)] = [
            ("Posts", "\(userModel_Base_one?.userId_Base_one ?? 0)"),
            ("Following", "\(userModel_Base_one?.userFollow_Base_one ?? 0)"),
            ("Fans", "\(userModel_Base_one?.userFans_Base_one ?? 0)")
        ]

        var lastItem_Base_one: UIView? = nil
        for (index_Base_one, stat_Base_one) in statsData_Base_one.enumerated() {
            let item_Base_one = buildStatItem_Base_one(value: stat_Base_one.1, label: stat_Base_one.0)
            statsRow_Base_one.addSubview(item_Base_one)
            item_Base_one.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalToSuperview().dividedBy(3)
                if let last = lastItem_Base_one {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            if index_Base_one < statsData_Base_one.count - 1 {
                let divider_Base_one = UIView()
                divider_Base_one.backgroundColor = ColorConfig_Base_one.divider_Base_one
                statsRow_Base_one.addSubview(divider_Base_one)
                divider_Base_one.snp.makeConstraints { make in
                    make.width.equalTo(1)
                    make.height.equalTo(28)
                    make.centerY.equalToSuperview()
                    make.leading.equalTo(item_Base_one.snp.trailing)
                }
            }
            lastItem_Base_one = item_Base_one
        }
    }

    /// 搭建操作按钮行（Follow + Chat）
    private func setupActionRow_Base_one() {
        contentView_Base_one.addSubview(actionRow_Base_one)
        actionRow_Base_one.addSubview(followBtn_Base_one)
        actionRow_Base_one.addSubview(chatBtn_Base_one)

        actionRow_Base_one.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Base_one.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
        }
        followBtn_Base_one.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(chatBtn_Base_one.snp.leading).offset(-12)
            make.width.equalTo(chatBtn_Base_one)
        }
        chatBtn_Base_one.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
        }

        updateFollowButton_Base_one()
    }

    /// 搭建分段控制（Posts / Liked）
    private func setupSegment_Base_one() {
        contentView_Base_one.addSubview(segmentContainer_Base_one)
        segmentContainer_Base_one.addSubview(segmentControl_Base_one)

        segmentContainer_Base_one.snp.makeConstraints { make in
            make.top.equalTo(actionRow_Base_one.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        segmentControl_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }

    /// 搭建帖子网格 CollectionView
    private func setupPostsGrid_Base_one() {
        let layout_Base_one = UICollectionViewFlowLayout()
        layout_Base_one.scrollDirection = .vertical
        layout_Base_one.minimumInteritemSpacing = gridSpacing_Base_one
        layout_Base_one.minimumLineSpacing = gridSpacing_Base_one

        postsCollectionView_Base_one = UICollectionView(frame: .zero, collectionViewLayout: layout_Base_one)
        postsCollectionView_Base_one.register(UserInfoPostCell_Base_one.self,
                                               forCellWithReuseIdentifier: UserInfoPostCell_Base_one.reuseId_Base_one)
        postsCollectionView_Base_one.backgroundColor = .clear
        postsCollectionView_Base_one.isScrollEnabled = false
        postsCollectionView_Base_one.showsVerticalScrollIndicator = false
        postsCollectionView_Base_one.delegate = self
        postsCollectionView_Base_one.dataSource = self

        contentView_Base_one.addSubview(postsCollectionView_Base_one)
        postsCollectionView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Base_one.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(gridPadding_Base_one)
            make.bottom.equalToSuperview().offset(-24)
            collectionViewHeightConstraint_Base_one = make.height.equalTo(0).constraint
        }
    }

    /// 搭建空状态视图
    private func setupEmptyView_Base_one() {
        contentView_Base_one.addSubview(emptyView_Base_one)
        emptyView_Base_one.addSubview(emptyIconView_Base_one)
        emptyView_Base_one.addSubview(emptyLabel_Base_one)

        emptyView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Base_one.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        emptyIconView_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        emptyLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Base_one.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 渐变更新

    /// 更新头部渐变图层（viewDidLayoutSubviews 后调用）
    private func updateHeaderGradient_Base_one() {
        guard headerView_Base_one.bounds.width > 0 else { return }
        if headerGradient_Base_one.superlayer == nil {
            headerGradient_Base_one.colors = [
                ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
                ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor,
                ColorConfig_Base_one.tidyMintDeep_Base_one.cgColor
            ]
            headerGradient_Base_one.startPoint = CGPoint(x: 0, y: 0)
            headerGradient_Base_one.endPoint = CGPoint(x: 1, y: 1)
            headerView_Base_one.layer.insertSublayer(headerGradient_Base_one, at: 0)
        }
        headerGradient_Base_one.frame = headerView_Base_one.bounds
    }

    /// 更新头像光环渐变（viewDidLayoutSubviews 后调用）
    private func updateAvatarRing_Base_one() {
        guard avatarRingView_Base_one.bounds.width > 0, avatarRingGradient_Base_one == nil else { return }
        let grad_Base_one = UIColor.createSecondaryGradientLayer_Base_one(frame_Base_one: avatarRingView_Base_one.bounds)
        grad_Base_one.cornerRadius = 46
        avatarRingView_Base_one.layer.insertSublayer(grad_Base_one, at: 0)
        avatarRingGradient_Base_one = grad_Base_one
    }

    /// 更新 Chat 按钮渐变（viewDidLayoutSubviews 后调用）
    private func updateChatButtonGradient_Base_one() {
        guard chatBtn_Base_one.bounds.width > 0 else { return }
        if chatGradient_Base_one == nil {
            let grad_Base_one = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: chatBtn_Base_one.bounds)
            grad_Base_one.cornerRadius = 20
            chatBtn_Base_one.layer.insertSublayer(grad_Base_one, at: 0)
            chatGradient_Base_one = grad_Base_one
        } else {
            chatGradient_Base_one?.frame = chatBtn_Base_one.bounds
        }
    }

    // MARK: - 操作绑定

    /// 绑定所有按钮事件
    private func bindActions_Base_one() {
        backBtn_Base_one.onTapped_Base_one = { Navigation_Base_one.pop_Base_one() }
        reportBtn_Base_one.addTarget(self, action: #selector(reportUserTapped_Base_one), for: .touchUpInside)
        followBtn_Base_one.addTarget(self, action: #selector(followTapped_Base_one), for: .touchUpInside)
        chatBtn_Base_one.addTarget(self, action: #selector(chatTapped_Base_one), for: .touchUpInside)
        segmentControl_Base_one.addTarget(self, action: #selector(segmentChanged_Base_one(_:)), for: .valueChanged)
    }

    // MARK: - 数据加载与配置

    /// 根据注入的用户模型配置页面显示信息
    private func configureUserInfo_Base_one() {
        guard let user_Base_one = userModel_Base_one else { return }
        nameLabel_Base_one.text = user_Base_one.userName_Base_one ?? "Unknown"
        bioLabel_Base_one.text = user_Base_one.userIntroduce_Base_one ?? "No bio yet."
        if let userId_Base_one = user_Base_one.userId_Base_one {
            avatarView_Base_one.configure_Base_one(userId_Base_one: userId_Base_one)
        }
        updateFollowButton_Base_one()
        updateStatsLabels_Base_one()
    }

    /// 加载该用户的帖子数据并刷新网格
    /// 对 Liked 列表额外过滤：排除已被举报/删除的帖子（保证 UI 与 ViewModel 数据一致）
    private func loadUserPosts_Base_one() {
        guard let user_Base_one = userModel_Base_one else { return }
        userPosts_Base_one = TitleViewModel_Base_one.shared_Base_one.getUserPosts_Base_one(user_base_one: user_Base_one)
        let activeIds_Base_one = Set(
            TitleViewModel_Base_one.shared_Base_one.getPosts_Base_one().map { $0.titleId_Base_one }
        )
        likedPosts_Base_one = user_Base_one.userLike_Base_one.filter { activeIds_Base_one.contains($0.titleId_Base_one) }
        switchSegment_Base_one(to: currentSegment_Base_one)
    }

    /// 切换分段并刷新帖子列表
    /// - Parameter index_Base_one: 分段下标（0=Posts, 1=Liked）
    private func switchSegment_Base_one(to index_Base_one: Int) {
        currentSegment_Base_one = index_Base_one
        displayPosts_Base_one = index_Base_one == 0 ? userPosts_Base_one : likedPosts_Base_one
        postsCollectionView_Base_one.reloadData()
        updateCollectionViewHeight_Base_one()
        let isEmpty_Base_one = displayPosts_Base_one.isEmpty
        emptyView_Base_one.isHidden = !isEmpty_Base_one
        postsCollectionView_Base_one.isHidden = isEmpty_Base_one
        emptyIconView_Base_one.image = UIImage(systemName: index_Base_one == 0 ? "square.grid.2x2" : "heart")
        emptyLabel_Base_one.text = index_Base_one == 0 ? "No posts yet" : "No liked posts"
    }

    /// 更新统计数据标签（Posts 数量从实时数据中获取）
    private func updateStatsLabels_Base_one() {
        guard let user_Base_one = userModel_Base_one else { return }
        let postsCount_Base_one = TitleViewModel_Base_one.shared_Base_one
            .getUserPosts_Base_one(user_base_one: user_Base_one).count
        // 重建统计行
        statsRow_Base_one.subviews.forEach { $0.removeFromSuperview() }
        let statsData_Base_one: [(String, String)] = [
            ("Posts", "\(postsCount_Base_one)"),
            ("Following", "\(user_Base_one.userFollow_Base_one ?? 0)"),
            ("Fans", "\(user_Base_one.userFans_Base_one ?? 0)")
        ]
        var lastItem_Base_one: UIView? = nil
        for (index_Base_one, stat_Base_one) in statsData_Base_one.enumerated() {
            let item_Base_one = buildStatItem_Base_one(value: stat_Base_one.1, label: stat_Base_one.0)
            statsRow_Base_one.addSubview(item_Base_one)
            item_Base_one.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalToSuperview().dividedBy(3)
                if let last = lastItem_Base_one {
                    make.leading.equalTo(last.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            if index_Base_one < statsData_Base_one.count - 1 {
                let divider_Base_one = UIView()
                divider_Base_one.backgroundColor = ColorConfig_Base_one.divider_Base_one
                statsRow_Base_one.addSubview(divider_Base_one)
                divider_Base_one.snp.makeConstraints { make in
                    make.width.equalTo(1)
                    make.height.equalTo(28)
                    make.centerY.equalToSuperview()
                    make.leading.equalTo(item_Base_one.snp.trailing)
                }
            }
            lastItem_Base_one = item_Base_one
        }
    }

    /// 更新 CollectionView 的高度约束，使 ScrollView 能自适应帖子总高度
    private func updateCollectionViewHeight_Base_one() {
        let screenWidth_Base_one = UIScreen.main.bounds.width
        let totalHorizontalInset_Base_one = gridPadding_Base_one * 2
        let totalSpacing_Base_one = gridSpacing_Base_one * (columns_Base_one - 1)
        let itemWidth_Base_one = (screenWidth_Base_one - totalHorizontalInset_Base_one - totalSpacing_Base_one) / columns_Base_one
        let itemHeight_Base_one = itemWidth_Base_one * 1.35

        let rowCount_Base_one = ceil(CGFloat(displayPosts_Base_one.count) / columns_Base_one)
        let totalHeight_Base_one = rowCount_Base_one * itemHeight_Base_one + max(0, rowCount_Base_one - 1) * gridSpacing_Base_one
        collectionViewHeightConstraint_Base_one?.update(offset: totalHeight_Base_one)
    }

    // MARK: - 通知监听

    /// 订阅帖子变化和用户状态变化通知
    private func observeNotifications_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleChanged_Base_one),
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserChanged_Base_one),
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one, object: nil
        )
    }

    @objc private func onTitleChanged_Base_one() {
        loadUserPosts_Base_one()
    }

    @objc private func onUserChanged_Base_one() {
        // 关注状态变化时同步刷新按钮样式与统计数字（粉丝数随之变化）
        updateFollowButton_Base_one()
        updateStatsLabels_Base_one()
    }

    // MARK: - 事件处理

    /// 点击举报按钮（拉黑用户）
    @objc private func reportUserTapped_Base_one() {
        guard let user_Base_one = userModel_Base_one else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.reportBtn_Base_one.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.reportBtn_Base_one.transform = .identity }
        })
        // 等待 ActionSheet dismiss 动画完成（约 0.3s）后再 pop，
        // 避免 pop 与 modal 收起动画并发导致生命周期乱序、导航栏状态异常
        ReportDeleteHelper_Base_one.block_Base_one(user_Base_one: user_Base_one, from: self) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    /// 点击关注按钮
    @objc private func followTapped_Base_one() {
        guard let user_Base_one = userModel_Base_one else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.followBtn_Base_one.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.followBtn_Base_one.transform = .identity }
        })
        UserViewModel_Base_one.shared_Base_one.followUser_Base_one(user_base_one: user_Base_one)
        updateFollowButton_Base_one()
    }

    /// 点击聊天按钮
    /// 流程：未登录 → 跳转登录页；未关注 → 提示先关注；已关注 → 弹出确认底部弹窗
    @objc private func chatTapped_Base_one() {
        guard let user_Base_one = userModel_Base_one else { return }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.chatBtn_Base_one.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.chatBtn_Base_one.transform = .identity }
        })

        // 第一步：检查是否已登录
        guard UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one else {
            Navigation_Base_one.toLogin_Base_one()
            return
        }

        // 第二步：检查是否已关注该用户
        let isFollowing_Base_one = UserViewModel_Base_one.shared_Base_one.isFollowing_Base_one(user_base_one: user_Base_one)
        guard isFollowing_Base_one else {
            Utils_Base_one.showBanner_Base_one(
                title_Base_one: "Follow Required",
                message_Base_one: "Please follow this user before starting a chat"
            )
            return
        }

        // 第三步：弹出确认底部弹窗，确认后进入聊天页
        showChatConfirmSheet_Base_one(user_Base_one: user_Base_one)
    }

    /// 展示聊天确认底部弹窗
    /// - Parameter user_Base_one: 目标用户模型
    private func showChatConfirmSheet_Base_one(user_Base_one: PrewUserModel_Base_one) {
        guard let window_Base_one = view.window else { return }
        let sheet_Base_one = ChatConfirmSheet_Base_one(userModel_Base_one: user_Base_one)
        sheet_Base_one.onConfirm_Base_one = { [weak self] in
            guard self != nil else { return }
            Navigation_Base_one.toMessageUser_Base_one(with: user_Base_one, style_base_one: .replace_base_one)
        }
        sheet_Base_one.present_Base_one(in: window_Base_one)
    }

    /// 分段切换
    @objc private func segmentChanged_Base_one(_ sender: UISegmentedControl) {
        switchSegment_Base_one(to: sender.selectedSegmentIndex)
    }

    // MARK: - UI 状态刷新

    /// 更新关注按钮的状态和样式
    private func updateFollowButton_Base_one() {
        guard let user_Base_one = userModel_Base_one else { return }
        let isFollowing_Base_one = UserViewModel_Base_one.shared_Base_one.isFollowing_Base_one(user_base_one: user_Base_one)
        if isFollowing_Base_one {
            followBtn_Base_one.setTitle("Followed", for: .normal)
            followBtn_Base_one.setTitleColor(ColorConfig_Base_one.textSecondary_Base_one, for: .normal)
            followBtn_Base_one.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
            followBtn_Base_one.layer.borderColor = ColorConfig_Base_one.divider_Base_one.cgColor
            followBtn_Base_one.tintColor = ColorConfig_Base_one.textSecondary_Base_one
        } else {
            followBtn_Base_one.setTitle("Follow", for: .normal)
            followBtn_Base_one.setTitleColor(.white, for: .normal)
            followBtn_Base_one.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one
            followBtn_Base_one.layer.borderColor = UIColor.clear.cgColor
            followBtn_Base_one.tintColor = .white
        }
    }

    // MARK: - 辅助构建

    /// 构建统计项视图（数值 + 标题竖向排列）
    /// - Parameters:
    ///   - value_Base_one: 数值字符串
    ///   - label_Base_one: 标题（英文）
    /// - Returns: 组合视图
    private func buildStatItem_Base_one(value: String, label: String) -> UIView {
        let container_Base_one = UIView()

        let valueLabel_Base_one = UILabel()
        valueLabel_Base_one.text = value
        valueLabel_Base_one.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel_Base_one.textColor = ColorConfig_Base_one.textPrimary_Base_one
        valueLabel_Base_one.textAlignment = .center

        let titleLabel_Base_one = UILabel()
        titleLabel_Base_one.text = label
        titleLabel_Base_one.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel_Base_one.textColor = ColorConfig_Base_one.textSecondary_Base_one
        titleLabel_Base_one.textAlignment = .center

        container_Base_one.addSubview(valueLabel_Base_one)
        container_Base_one.addSubview(titleLabel_Base_one)

        valueLabel_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
        }
        titleLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Base_one.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
        }
        return container_Base_one
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension UserInfo_Base_one: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Base_one.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Base_one = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserInfoPostCell_Base_one.reuseId_Base_one,
            for: indexPath
        ) as! UserInfoPostCell_Base_one

        let post_Base_one = displayPosts_Base_one[indexPath.item]
        cell_Base_one.configure_Base_one(post: post_Base_one)

        // 注入举报/删除按钮（使用助手类）
        cell_Base_one.actionContainer_Base_one.subviews.forEach { $0.removeFromSuperview() }
        let actionBtn_Base_one = ReportDeleteHelper_Base_one.createPostReportButton_Base_one(
            post_Base_one: post_Base_one,
            size_Base_one: 22,
            color_Base_one: .white,
            from: self
        ) { [weak self] in
            self?.loadUserPosts_Base_one()
        }
        cell_Base_one.actionContainer_Base_one.addSubview(actionBtn_Base_one)
        actionBtn_Base_one.snp.makeConstraints { make in make.edges.equalToSuperview() }

        return cell_Base_one
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth_Base_one = UIScreen.main.bounds.width
        let totalHorizontalInset_Base_one = gridPadding_Base_one * 2
        let totalSpacing_Base_one = gridSpacing_Base_one * (columns_Base_one - 1)
        let itemWidth_Base_one = (screenWidth_Base_one - totalHorizontalInset_Base_one - totalSpacing_Base_one) / columns_Base_one
        return CGSize(width: itemWidth_Base_one, height: itemWidth_Base_one * 1.35)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Base_one = displayPosts_Base_one[indexPath.item]
        Navigation_Base_one.toTitleDetail_Base_one(titleModel_base_one: post_Base_one)
    }
}

// MARK: - 帖子卡片 Cell

/// 用户中心帖子网格单元格
/// 功能：展示帖子封面图、标题、点赞数，右上角预留举报/删除按钮容器
/// 关键属性：actionContainer_Base_one（外部注入举报按钮）
class UserInfoPostCell_Base_one: UICollectionViewCell {

    static let reuseId_Base_one = "UserInfoPostCell_Base_one"

    // MARK: - UI 组件

    /// 封面媒体展示（复用 MediaDisplayView）
    private let mediaView_Base_one: MediaDisplayView_Base_one = {
        let v = MediaDisplayView_Base_one()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    /// 底部渐变蒙层（提升文字可读性）
    private let gradientOverlay_Base_one: UIView = {
        let v = UIView()
        return v
    }()

    private let gradientLayer_Base_one = CAGradientLayer()

    private let titleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        l.shadowColor = UIColor.black.withAlphaComponent(0.3)
        l.shadowOffset = CGSize(width: 0, height: 1)
        return l
    }()

    private let likeIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.fill")
        iv.tintColor = UIColor(hexstring_Base_one: "#FBB6CE")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likeLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = .white
        l.shadowColor = UIColor.black.withAlphaComponent(0.3)
        l.shadowOffset = CGSize(width: 0, height: 1)
        return l
    }()

    /// 举报/删除按钮容器（由外部注入实际按钮）
    let actionContainer_Base_one = UIView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 14
        gradientLayer_Base_one.frame = gradientOverlay_Base_one.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        actionContainer_Base_one.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 14
        contentView.backgroundColor = ColorConfig_Base_one.cardBackground_Base_one

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 8
        layer.masksToBounds = false

        contentView.addSubview(mediaView_Base_one)
        contentView.addSubview(gradientOverlay_Base_one)
        contentView.addSubview(titleLabel_Base_one)
        contentView.addSubview(likeIconView_Base_one)
        contentView.addSubview(likeLabel_Base_one)
        contentView.addSubview(actionContainer_Base_one)

        gradientLayer_Base_one.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.60).cgColor]
        gradientLayer_Base_one.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer_Base_one.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay_Base_one.layer.addSublayer(gradientLayer_Base_one)

        mediaView_Base_one.snp.makeConstraints { make in make.edges.equalToSuperview() }
        gradientOverlay_Base_one.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        actionContainer_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        titleLabel_Base_one.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalTo(likeIconView_Base_one.snp.top).offset(-4)
        }
        likeIconView_Base_one.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(12)
        }
        likeLabel_Base_one.snp.makeConstraints { make in
            make.left.equalTo(likeIconView_Base_one.snp.right).offset(4)
            make.centerY.equalTo(likeIconView_Base_one)
        }
    }

    // MARK: - 配置

    /// 用帖子数据配置单元格
    /// - Parameter post_Base_one: 帖子数据模型
    func configure_Base_one(post post_Base_one: TitleModel_Base_one) {
        titleLabel_Base_one.text = post_Base_one.title_Base_one
        likeLabel_Base_one.text = "\(post_Base_one.likes_Base_one)"
        mediaView_Base_one.configure_Base_one(
            mediaPath_Base_one: post_Base_one.titleMeidas_Base_one.first,
            isVideo_Base_one: false
        )
    }
}
