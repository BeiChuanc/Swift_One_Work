import Foundation
import UIKit
import SnapKit

// MARK: - 我的页面

/// 我的页面
/// 核心作用：展示登录用户的个人信息、已发布帖子（My Posts）或喜欢帖子（Liked）
/// 设计思路：暖色渐变头部（头像/昵称/简介/统计）+ Segment 切换 + 2 列帖子瀑布网格；
///          帖子项右上角含举报/删除按钮，媒体使用 MediaDisplayView_Pane 展示
/// 关键属性：
/// - meModel_Pane: 外部注入的登录用户模型，为 nil 时自动取当前登录用户
/// - selectedTab_Pane: 当前选中的 Segment（0=My Posts / 1=Liked）
class Me_Pane: UIViewController {

    // MARK: - 属性

    /// 外部传入的登录用户模型（可为空，为空时使用当前登录用户）
    var meModel_Pane: LoginUserModel_Pane?

    /// 当前展示的用户数据（优先 meModel_Pane，否则取 ViewModel 当前用户）
    private var currentUser_Pane: LoginUserModel_Pane {
        meModel_Pane ?? UserViewModel_Pane.shared_Pane.getCurrentUser_Pane()
    }

    /// 当前选中 Segment（0 = My Posts, 1 = Liked）
    private var selectedTab_Pane: Int = 0

    /// 当前展示的帖子列表
    private var displayedPosts_Pane: [TitleModel_Pane] {
        selectedTab_Pane == 0 ? currentUser_Pane.userPosts_Pane : currentUser_Pane.userLike_Pane
    }

    /// 帖子列表集合视图高度约束
    private var postsCVHeightCon_Pane: Constraint?

    /// KVO 注册标志位：只有成功 addObserver 后才允许 removeObserver，防止 deinit 崩溃
    private var isKVORegistered_Pane = false

    // MARK: - UI · 外层滚动

    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        // 关闭自动 SafeArea 偏移，让渐变头部可以从屏幕最顶端开始渲染
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Pane = UIView()

    // MARK: - UI · 头部卡片

    /// 头部渐变卡片
    private let headerCard_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 0
        v.clipsToBounds = false
        return v
    }()

    private var headerGradient_Pane: CAGradientLayer?

    /// 右上装饰圆 — 大
    private let decorCircle1_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 55
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 右上装饰圆 — 小
    private let decorCircle2_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 36
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 左下装饰圆 — 微
    private let decorCircle3_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 24
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 头像下方在线徽章（绿点）
    private let onlineBadge_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Pane: "#48BB78")
        v.layer.cornerRadius = 8
        v.layer.borderWidth  = 2.5
        v.layer.borderColor  = UIColor.white.cgColor
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 斜向光晕线（装饰）
    private let shimmerLine_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 2
        v.isUserInteractionEnabled = false
        v.transform = CGAffineTransform(rotationAngle: .pi / 6)
        return v
    }()

    /// 设置按钮（右上角）
    private let settingsButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        b.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg_pane)?
            .withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    /// VIP 订阅按钮（设置按钮左侧），点击跳转 VIP 订阅页
    private let vipButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_btn"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 22
        return b
    }()

    /// 用户头像
    private let avatarView_Pane: CurrentUserAvatarView_Pane = {
        let v = CurrentUserAvatarView_Pane()
        v.layer.cornerRadius = 44
        v.clipsToBounds = true
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 昵称
    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 简介
    private let introLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 统计行
    private let statsRow_Pane = UIView()

    /// 编辑按钮
    private let editButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("✏️  Edit Profile", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.setTitleColor(ColorConfig_Pane.primaryGradientStart_Pane, for: .normal)
        b.backgroundColor = .white
        b.layer.cornerRadius = 16
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        return b
    }()

    // MARK: - UI · Segment

    private let segmentContainer_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        // 底部微阴影，与帖子列表区分
        v.layer.shadowColor   = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 2)
        v.layer.shadowRadius  = 4
        return v
    }()

    private let segmentControl_Pane: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["My Posts", "Liked"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = ColorConfig_Pane.primaryGradientStart_Pane
        sc.setTitleTextAttributes(
            [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .semibold)],
            for: .selected
        )
        sc.setTitleTextAttributes(
            [.foregroundColor: ColorConfig_Pane.textSecondary_Pane, .font: UIFont.systemFont(ofSize: 13)],
            for: .normal
        )
        sc.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        return sc
    }()

    // MARK: - UI · 帖子列表

    private lazy var postsCV_Pane: UICollectionView = {
        let layout_pane = UICollectionViewFlowLayout()
        layout_pane.minimumInteritemSpacing = 10
        layout_pane.minimumLineSpacing      = 10
        layout_pane.sectionInset            = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        let cv_pane = UICollectionView(frame: .zero, collectionViewLayout: layout_pane)
        cv_pane.backgroundColor    = .clear
        cv_pane.isScrollEnabled    = false
        cv_pane.register(MePostCell_Pane.self, forCellWithReuseIdentifier: MePostCell_Pane.reuseId_Pane)
        return cv_pane
    }()

    /// 帖子为空时的空状态视图
    private let emptyPostsView_Pane: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyPostsIcon_Pane: UILabel = {
        let l = UILabel()
        l.text = "🪟"
        l.font = .systemFont(ofSize: 48)
        l.textAlignment = .center
        return l
    }()

    private let emptyPostsText_Pane: UILabel = {
        let l = UILabel()
        l.text = "No posts yet\nShare your window view!"
        l.font = .systemFont(ofSize: 14)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupActions_Pane()
        setupNotifications_Pane()
        refreshData_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData_Pane()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Pane?.frame = headerCard_Pane.bounds
        applyHeaderWaveBottom_Pane()
    }

    /// 给头部卡片裁剪波浪弧形底边（只圆角 bottomLeft / bottomRight）
    private func applyHeaderWaveBottom_Pane() {
        guard headerCard_Pane.bounds.height > 0 else { return }
        let path_pane = UIBezierPath(
            roundedRect: headerCard_Pane.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 30, height: 30)
        )
        let mask_pane = CAShapeLayer()
        mask_pane.path = path_pane.cgPath
        headerCard_Pane.layer.mask = mask_pane
    }

    deinit {
        // 仅在 KVO 已注册时才移除，避免因 viewDidLoad 未执行时 deinit 抛出 NSRangeException
        if isKVORegistered_Pane {
            postsCV_Pane.removeObserver(self, forKeyPath: "contentSize")
        }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane

        // 滚动容器
        view.addSubview(scrollView_Pane)
        scrollView_Pane.addSubview(contentView_Pane)

        // 头部卡片
        contentView_Pane.addSubview(headerCard_Pane)
        headerCard_Pane.addSubview(decorCircle1_Pane)
        headerCard_Pane.addSubview(decorCircle2_Pane)
        headerCard_Pane.addSubview(decorCircle3_Pane)
        headerCard_Pane.addSubview(shimmerLine_Pane)
        headerCard_Pane.addSubview(settingsButton_Pane)
        headerCard_Pane.addSubview(vipButton_Pane)
        headerCard_Pane.addSubview(avatarView_Pane)
        headerCard_Pane.addSubview(onlineBadge_Pane)
        headerCard_Pane.addSubview(nameLabel_Pane)
        headerCard_Pane.addSubview(introLabel_Pane)
        headerCard_Pane.addSubview(statsRow_Pane)
        headerCard_Pane.addSubview(editButton_Pane)
        buildStatsRow_Pane()

        // Segment
        contentView_Pane.addSubview(segmentContainer_Pane)
        segmentContainer_Pane.addSubview(segmentControl_Pane)

        // 帖子列表
        contentView_Pane.addSubview(postsCV_Pane)
        contentView_Pane.addSubview(emptyPostsView_Pane)
        emptyPostsView_Pane.addSubview(emptyPostsIcon_Pane)
        emptyPostsView_Pane.addSubview(emptyPostsText_Pane)

        setupHeaderGradient_Pane()
        setupConstraints_Pane()

        postsCV_Pane.dataSource = self
        postsCV_Pane.delegate   = self
        postsCV_Pane.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        isKVORegistered_Pane = true
    }

    /// 头部渐变（薰衣草紫 → 天空蓝）
    private func setupHeaderGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        headerCard_Pane.layer.insertSublayer(gl_pane, at: 0)
        headerGradient_Pane = gl_pane
    }

    /// 构建三列统计行（Posts / Liked / Following），列间加半透明白色分隔线
    private func buildStatsRow_Pane() {
        let items_pane: [(String, String)] = [
            ("\(currentUser_Pane.userPosts_Pane.count)", "Posts"),
            ("\(currentUser_Pane.userLike_Pane.count)",  "Liked"),
            ("\(currentUser_Pane.userFollow_Pane.count)", "Following")
        ]
        let stack_pane = UIStackView()
        stack_pane.axis         = .horizontal
        stack_pane.distribution = .fillEqually
        stack_pane.spacing      = 0
        statsRow_Pane.addSubview(stack_pane)
        stack_pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        for (idx_pane, (value_pane, label_pane)) in items_pane.enumerated() {
            let col_pane = UIView()

            // 分隔线（第 1、2 列右边）
            if idx_pane < items_pane.count - 1 {
                let sep_pane = UIView()
                sep_pane.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                col_pane.addSubview(sep_pane)
                sep_pane.snp.makeConstraints {
                    $0.trailing.equalToSuperview()
                    $0.centerY.equalToSuperview()
                    $0.width.equalTo(0.5)
                    $0.height.equalTo(28)
                }
            }

            let vLabel_pane = UILabel()
            vLabel_pane.text      = value_pane
            vLabel_pane.font      = .systemFont(ofSize: 20, weight: .bold)
            vLabel_pane.textColor = .white
            vLabel_pane.textAlignment = .center

            let kLabel_pane = UILabel()
            kLabel_pane.text      = label_pane
            kLabel_pane.font      = .systemFont(ofSize: 11)
            kLabel_pane.textColor = UIColor.white.withAlphaComponent(0.8)
            kLabel_pane.textAlignment = .center

            col_pane.addSubview(vLabel_pane)
            col_pane.addSubview(kLabel_pane)
            vLabel_pane.snp.makeConstraints {
                $0.top.equalToSuperview().offset(4)
                $0.centerX.equalToSuperview()
            }
            kLabel_pane.snp.makeConstraints {
                $0.top.equalTo(vLabel_pane.snp.bottom).offset(3)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-4)
            }
            stack_pane.addArrangedSubview(col_pane)
        }
    }

    /// 布局约束
    private func setupConstraints_Pane() {
        scrollView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView_Pane)
        }

        // 头部卡片
        headerCard_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        decorCircle1_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-15)
            $0.trailing.equalToSuperview().offset(25)
            $0.width.height.equalTo(110)
        }
        decorCircle2_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().offset(-55)
            $0.width.height.equalTo(72)
        }
        decorCircle3_Pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(-10)
            $0.width.height.equalTo(48)
        }
        shimmerLine_Pane.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(-20)
            $0.width.equalTo(180)
            $0.height.equalTo(3)
        }
        settingsButton_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(36)
        }
        vipButton_Pane.snp.makeConstraints {
            $0.centerY.equalTo(settingsButton_Pane)
            $0.trailing.equalTo(settingsButton_Pane.snp.leading).offset(-10)
            $0.width.height.equalTo(44)
        }
        avatarView_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(88)
        }
        onlineBadge_Pane.snp.makeConstraints {
            $0.trailing.equalTo(avatarView_Pane.snp.trailing).offset(-2)
            $0.bottom.equalTo(avatarView_Pane.snp.bottom).offset(-2)
            $0.width.height.equalTo(16)
        }
        nameLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(avatarView_Pane.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        introLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Pane.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        statsRow_Pane.snp.makeConstraints {
            $0.top.equalTo(introLabel_Pane.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        editButton_Pane.snp.makeConstraints {
            $0.top.equalTo(statsRow_Pane.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
            $0.bottom.equalToSuperview().offset(-20)
        }

        // Segment
        segmentContainer_Pane.snp.makeConstraints {
            $0.top.equalTo(headerCard_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        segmentControl_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(36)
        }

        // 帖子 CV
        postsCV_Pane.snp.makeConstraints {
            $0.top.equalTo(segmentContainer_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            postsCVHeightCon_Pane = $0.height.equalTo(200).constraint
            $0.bottom.equalToSuperview()
        }
        emptyPostsView_Pane.snp.makeConstraints {
            $0.top.equalTo(segmentContainer_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
        emptyPostsIcon_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-16)
        }
        emptyPostsText_Pane.snp.makeConstraints {
            $0.top.equalTo(emptyPostsIcon_Pane.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    // MARK: - 数据刷新

    /// 刷新用户信息 + 帖子列表
    private func refreshData_Pane() {
        let user_pane = currentUser_Pane
        nameLabel_Pane.text  = user_pane.userName_Pane ?? "Paner"
        introLabel_Pane.text = user_pane.userIntroduce_Pane ?? "Sharing window views ✨"

        postsCV_Pane.reloadData()
        let isEmpty_pane = displayedPosts_Pane.isEmpty
        emptyPostsView_Pane.isHidden = !isEmpty_pane
        postsCV_Pane.isHidden        = isEmpty_pane
    }

    // MARK: - contentSize 监听 → 动态更新 postsCV 高度

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "contentSize",
           let newSize_pane = change?[.newKey] as? CGSize {
            postsCVHeightCon_Pane?.update(offset: newSize_pane.height)
            view.layoutIfNeeded()
        }
    }

    // MARK: - 通知

    private func setupNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserStateChanged_Pane),
            name: UserViewModel_Pane.userStateDidChangeNotification_Pane,
            object: nil
        )
    }

    @objc private func onUserStateChanged_Pane() {
        refreshData_Pane()
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        settingsButton_Pane.addTarget(self, action: #selector(settingsTapped_Pane), for: .touchUpInside)
        vipButton_Pane.addTarget(self, action: #selector(vipTapped_Pane), for: .touchUpInside)
        editButton_Pane.addTarget(self, action: #selector(editTapped_Pane), for: .touchUpInside)
        segmentControl_Pane.addTarget(self, action: #selector(segmentChanged_Pane(_:)), for: .valueChanged)
    }

    @objc private func settingsTapped_Pane() {
        Navigation_Pane.toSetting_Pane()
    }

    /// 点击 VIP 订阅按钮：跳转到 VIP 订阅页
    @objc private func vipTapped_Pane() {
        Navigation_Pane.toVIPSubscription_Pane()
    }

    @objc private func editTapped_Pane() {
        Navigation_Pane.toEditInfo_Pane()
    }

    @objc private func segmentChanged_Pane(_ sender: UISegmentedControl) {
        selectedTab_Pane = sender.selectedSegmentIndex
        refreshData_Pane()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension Me_Pane: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPosts_Pane.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_pane = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Pane.reuseId_Pane,
            for: indexPath
        ) as! MePostCell_Pane
        let post_pane = displayedPosts_Pane[indexPath.item]
        cell_pane.configure_Pane(post_pane: post_pane)
        cell_pane.onMenuTapped_Pane = { [weak self] in
            guard let self = self else { return }
            let btn_pane = ReportDeleteHelper_Pane.createPostReportButton_Pane(
                post_Pane: post_pane,
                from: self
            ) { [weak self] in
                self?.refreshData_Pane()
            }
            btn_pane.sendActions(for: .touchUpInside)
        }
        return cell_pane
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let inset_pane: CGFloat = 16
        let spacing_pane: CGFloat = 10
        let colW_pane = (view.bounds.width - inset_pane * 2 - spacing_pane) / 2
        return CGSize(width: colW_pane, height: colW_pane * 1.45)
    }
}

// MARK: - MePostCell_Pane

/// 我的页面帖子卡片 Cell
/// 核心作用：展示帖子封面（MediaDisplayView_Pane）、标题、点赞数；
///          右上角提供举报/删除入口（通过 onMenuTapped_Pane 回调触发）
private class MePostCell_Pane: UICollectionViewCell {

    static let reuseId_Pane = "MePostCell_Pane"

    /// 举报/删除菜单点击回调（由外部注入业务逻辑）
    var onMenuTapped_Pane: (() -> Void)?

    /// 媒体展示组件
    private let mediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    /// 举报/删除按钮
    private let menuButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        b.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_pane)?
            .withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 12
        return b
    }()

    /// 帖子标题
    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        l.numberOfLines = 2
        return l
    }()

    /// 点赞数
    private let likesLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        contentView.layer.cornerRadius = 14
        contentView.layer.shadowColor  = ColorConfig_Pane.shadowColor_Pane.cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset  = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius  = 6
        contentView.clipsToBounds = false

        contentView.addSubview(mediaView_Pane)
        contentView.addSubview(menuButton_Pane)
        contentView.addSubview(titleLabel_Pane)
        contentView.addSubview(likesLabel_Pane)

        mediaView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(contentView.snp.width).multipliedBy(0.85)
        }
        menuButton_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(24)
        }
        titleLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(mediaView_Pane.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        likesLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Pane.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.lessThanOrEqualToSuperview().offset(-8)
        }

        menuButton_Pane.addTarget(self, action: #selector(menuTapped_Pane), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置帖子数据
    /// - Parameter post_pane: 帖子模型
    func configure_Pane(post_pane: TitleModel_Pane) {
        titleLabel_Pane.text  = post_pane.title_Pane
        likesLabel_Pane.text  = "♥ \(post_pane.likes_Pane)"
        let media_pane        = post_pane.titleMeidas_Pane.first
        mediaView_Pane.configure_Pane(mediaPath_Pane: media_pane)
    }

    @objc private func menuTapped_Pane() {
        onMenuTapped_Pane?()
    }
}
