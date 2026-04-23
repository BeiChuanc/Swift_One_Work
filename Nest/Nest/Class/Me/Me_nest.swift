import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 我的页面
/// 核心作用：展示当前登录用户的个人信息、数据统计、发帖与收藏
/// 设计思路：
///   - 沉浸式渐变 Header（波浪底边 + 装饰气泡 + 渐变头像环 + 设置/编辑按钮胶囊）
///   - 浮起统计卡片（Posts / Liked 双列数据）
///   - 自定义滑动下划线 Tab 选择器
///   - 富化帖子卡片（媒体缩略图 + 标题 + 摘要 + 互动数）
///   - 带动画的空态提示
/// 关键属性：
///   - meModel_Nest: 可由外部注入的用户模型（默认读取当前登录用户）
///   - segmentIndex_Nest: 0=My Posts, 1=Liked
class Me_Nest: UIViewController {

    // MARK: - 外部注入
    var meModel_Nest: LoginUserModel_Nest?

    // MARK: - 私有状态
    private var segmentIndex_Nest: Int = 0
    private var myPosts_Nest: [TitleModel_Nest] = []
    private var likedPosts_Nest: [TitleModel_Nest] = []

    // MARK: - UI 组件

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        sv_Nest.alwaysBounceVertical = true
        // 禁止系统自动添加 safeArea contentInset，防止顶部出现间隙
        sv_Nest.contentInsetAdjustmentBehavior = .never
        return sv_Nest
    }()

    private let contentView_Nest = UIView()

    private let headerView_Nest = MeHeaderView_Nest()

    /// 统计浮起卡片（从 header 向下浮出）
    private let statsCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 22
        v_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_Nest.layer.shadowRadius = 16
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    private let postsStatLabel_Nest    = MeStatView_Nest.makeNumber_Nest()
    private let followStatLabel_Nest   = MeStatView_Nest.makeNumber_Nest()
    private let likesStatLabel_Nest    = MeStatView_Nest.makeNumber_Nest()

    /// 自定义滑动 Tab 选择器
    private let tabBarView_Nest = MeTabBarView_Nest()

    /// 帖子卡片堆叠区
    private let postsStack_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .vertical
        sv_Nest.spacing = 14
        return sv_Nest
    }()

    /// 空态视图
    private let emptyView_Nest = MeEmptyView_Nest()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Nest()
        setupConstraints_Nest()
        setupNotifications_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Nest()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // viewDidAppear 时 tabBar frame 已完全确定，此处设置最可靠
        applyScrollBottomInset_Nest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView_Nest.updateLayout_Nest()
    }

    /// 补偿 tabBar 高度，确保最后一行内容不被遮挡可完整滚动到视野内
    private func applyScrollBottomInset_Nest() {
        // tabBar.frame.height 在有 home indicator 的设备上约 83pt，无 indicator 约 49pt
        let tabBarH_Nest = tabBarController?.tabBar.frame.height ?? 83
        let bottom_Nest  = tabBarH_Nest + 30
        scrollView_Nest.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: bottom_Nest, right: 0)
        scrollView_Nest.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottom_Nest, right: 0)
    }

    // MARK: - UI 构建

    private func setupUI_Nest() {
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)

        // Header
        headerView_Nest.onSettingTapped_Nest = { [weak self] in self?.onSettingTapped_Nest() }
        headerView_Nest.onEditTapped_Nest = { [weak self] in self?.onEditTapped_Nest() }
        contentView_Nest.addSubview(headerView_Nest)

        // 统计卡片内容
        buildStatsCard_Nest()
        contentView_Nest.addSubview(statsCard_Nest)

        // Tab 选择器
        tabBarView_Nest.onTabChanged_Nest = { [weak self] idx_Nest in
            guard let self_Nest = self else { return }
            self_Nest.segmentIndex_Nest = idx_Nest
            let posts_Nest = idx_Nest == 0 ? self_Nest.myPosts_Nest : self_Nest.likedPosts_Nest
            self_Nest.buildPostCards_Nest(posts_Nest)
        }
        contentView_Nest.addSubview(tabBarView_Nest)

        // 帖子区域
        contentView_Nest.addSubview(postsStack_Nest)
        contentView_Nest.addSubview(emptyView_Nest)
    }

    /// 构建统计卡片内部布局（三列：Posts / Following / Liked）
    private func buildStatsCard_Nest() {
        let postsCol_Nest  = MeStatView_Nest(number: postsStatLabel_Nest,  title: "Posts")
        let divider1_Nest  = makeStatDivider_Nest()
        let followCol_Nest = MeStatView_Nest(number: followStatLabel_Nest, title: "Following")
        let divider2_Nest  = makeStatDivider_Nest()
        let likesCol_Nest  = MeStatView_Nest(number: likesStatLabel_Nest,  title: "Liked")

        let stack_Nest = UIStackView(arrangedSubviews: [
            postsCol_Nest, divider1_Nest, followCol_Nest, divider2_Nest, likesCol_Nest
        ])
        stack_Nest.axis = .horizontal
        stack_Nest.distribution = .equalSpacing
        stack_Nest.alignment = .center

        statsCard_Nest.addSubview(stack_Nest)
        stack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.bottom.equalToSuperview().inset(20)
            make_Nest.leading.equalToSuperview().offset(32)
            make_Nest.trailing.equalToSuperview().offset(-32)
        }
        [divider1_Nest, divider2_Nest].forEach { div_Nest in
            div_Nest.snp.makeConstraints { make_Nest in
                make_Nest.width.equalTo(1)
                make_Nest.height.equalTo(38)
            }
        }
    }

    private func makeStatDivider_Nest() -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.divider_Nest
        return v_Nest
    }

    private func setupConstraints_Nest() {
        scrollView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
            // 最小高度 = 屏幕高度 + 120，保证空态时 contentSize 始终大于 frame，页面可滚动
            make_Nest.height.greaterThanOrEqualTo(view.snp.height).offset(120)
        }
        headerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(295)
        }
        statsCard_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(headerView_Nest.snp.bottom).offset(-28)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(92)
        }
        tabBarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(statsCard_Nest.snp.bottom).offset(18)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(44)
        }
        postsStack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(tabBarView_Nest.snp.bottom).offset(14)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.bottom.equalToSuperview().offset(-120)
        }
        emptyView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(tabBarView_Nest.snp.bottom).offset(40)
            make_Nest.centerX.equalToSuperview()
            make_Nest.width.equalTo(240)
        }
    }

    // MARK: - 通知

    private func setupNotifications_Nest() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStateChanged_Nest),
            name: TitleViewModel_Nest.titleStateDidChangeNotification_Nest,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStateChanged_Nest),
            name: UserViewModel_Nest.userStateDidChangeNotification_Nest,
            object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 数据加载

    private func loadData_Nest() {
        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else {
            headerView_Nest.configure_Nest(name_Nest: "Guest", bio_Nest: "Sign in to see your profile")
            postsStatLabel_Nest.text  = "0"
            followStatLabel_Nest.text = "0"
            likesStatLabel_Nest.text  = "0"
            buildPostCards_Nest([])
            return
        }

        let user_Nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()
        headerView_Nest.configure_Nest(
            name_Nest: user_Nest.userName_Nest ?? "User",
            bio_Nest: user_Nest.userBio_Nest?.isEmpty == false ? user_Nest.userBio_Nest! : "No bio yet"
        )

        let uid_Nest = user_Nest.userId_Nest ?? 0
        myPosts_Nest   = TitleViewModel_Nest.shared_Nest.getUserPostsById_Nest(userId_nest: uid_Nest)
        likedPosts_Nest = user_Nest.userLike_Nest

        postsStatLabel_Nest.text  = "\(myPosts_Nest.count)"
        followStatLabel_Nest.text = "\(user_Nest.userFollow_Nest.count)"
        likesStatLabel_Nest.text  = "\(likedPosts_Nest.count)"

        let current_Nest = segmentIndex_Nest == 0 ? myPosts_Nest : likedPosts_Nest
        buildPostCards_Nest(current_Nest)
    }

    /// 重建帖子卡片区域
    private func buildPostCards_Nest(_ posts: [TitleModel_Nest]) {
        postsStack_Nest.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if posts.isEmpty {
            emptyView_Nest.isHidden = false
            postsStack_Nest.isHidden = true
            return
        }
        emptyView_Nest.isHidden = true
        postsStack_Nest.isHidden = false

        for (i_Nest, post_Nest) in posts.enumerated() {
            let card_Nest = PostCard_Nest(post: post_Nest, from: self)
            postsStack_Nest.addArrangedSubview(card_Nest)
            card_Nest.animateSlideInFromBottom_Nest(
                offset_Nest: 28,
                delay_Nest: TimeInterval(i_Nest) * AnimationConfig_Nest.delayShort_Nest
            )
            // 点击跳转详情
            card_Nest.onTap_Nest = { [weak self] post in
                self?.navigateToDetail_Nest(post: post)
            }
        }
    }

    // MARK: - 事件

    private func onSettingTapped_Nest() {
        Navigation_Nest.toSetting_Nest()
    }

    private func onEditTapped_Nest() {
        Navigation_Nest.toEditInfo_Nest()
    }

    private func navigateToDetail_Nest(post: TitleModel_Nest) {
        Navigation_Nest.toTitleDetail_Nest(titleModel_nest: post)
    }

    @objc private func onStateChanged_Nest() { loadData_Nest() }
}

// MARK: - MeHeaderView_Nest
/// 个人中心顶部沉浸式渐变 Header
/// 设计要点：
///   - 波浪曲线底边（同 MessageList 风格保持统一）
///   - 顶部两个操作按钮胶囊（设置 / 编辑）
///   - 大尺寸渐变头像环（100px ring，80px 头像）
///   - 昵称 + 简介文字
///   - 三个半透明装饰气泡增加空间纵深
private class MeHeaderView_Nest: UIView {

    // MARK: 回调

    var onSettingTapped_Nest: (() -> Void)?
    var onEditTapped_Nest: (() -> Void)?

    // MARK: 渐变

    private var gradientLayer_Nest: CAGradientLayer?

    // MARK: 装饰气泡

    private let bubble1_Nest = MeHeaderView_Nest.makeBubble_Nest(size: 150, alpha: 0.07)
    private let bubble2_Nest = MeHeaderView_Nest.makeBubble_Nest(size: 90, alpha: 0.1)
    private let bubble3_Nest = MeHeaderView_Nest.makeBubble_Nest(size: 50, alpha: 0.12)

    // MARK: 操作按钮

    /// 设置按钮（胶囊形半透明背景）
    private let settingBtnContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v_Nest.layer.cornerRadius = 16
        return v_Nest
    }()

    private let settingBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        btn_Nest.tintColor = .white
        return btn_Nest
    }()

    /// 编辑按钮（胶囊形半透明背景）
    private let editBtnContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v_Nest.layer.cornerRadius = 16
        return v_Nest
    }()

    private let editBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn_Nest.tintColor = .white
        return btn_Nest
    }()

    // MARK: 头像渐变环

    private let ringView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 50
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var ringGradient_Nest: CAGradientLayer?

    private let avatarWrapper_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v_Nest.layer.cornerRadius = 42
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private let avatarView_Nest = CurrentUserAvatarView_Nest()

    // MARK: 文字

    private let nameLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl_Nest.textColor = .white
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let bioLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.78)
        lbl_Nest.textAlignment = .center
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGradient_Nest()
        setupSubviews_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func makeBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2
        return v_Nest
    }

    private func setupGradient_Nest() {
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    private func setupSubviews_Nest() {
        // 气泡（底层）
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(bubble3_Nest)

        // 按钮胶囊
        settingBtnContainer_Nest.addSubview(settingBtn_Nest)
        editBtnContainer_Nest.addSubview(editBtn_Nest)
        addSubview(settingBtnContainer_Nest)
        addSubview(editBtnContainer_Nest)

        // 头像
        avatarWrapper_Nest.addSubview(avatarView_Nest)
        ringView_Nest.addSubview(avatarWrapper_Nest)

        let rgl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        ringView_Nest.layer.insertSublayer(rgl_Nest, at: 0)
        ringGradient_Nest = rgl_Nest

        addSubview(ringView_Nest)
        addSubview(nameLabel_Nest)
        addSubview(bioLabel_Nest)

        // 绑定事件
        settingBtn_Nest.addTarget(self, action: #selector(settingTapped_Nest), for: .touchUpInside)
        editBtn_Nest.addTarget(self, action: #selector(editTapped_Nest), for: .touchUpInside)

        // 气泡布局
        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-30)
            make_Nest.leading.equalToSuperview().offset(-30)
            make_Nest.width.height.equalTo(150)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(20)
            make_Nest.width.height.equalTo(90)
        }
        bubble3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(50)
            make_Nest.trailing.equalToSuperview().offset(-50)
            make_Nest.width.height.equalTo(50)
        }

        // 设置按钮
        settingBtnContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.top.equalToSuperview().offset(54)
            make_Nest.width.height.equalTo(36)
        }
        settingBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(20)
        }

        // 编辑按钮
        editBtnContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalTo(settingBtnContainer_Nest.snp.leading).offset(-10)
            make_Nest.centerY.equalTo(settingBtnContainer_Nest)
            make_Nest.width.height.equalTo(36)
        }
        editBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(20)
        }

        // 头像环
        ringView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerX.equalToSuperview()
            make_Nest.top.equalToSuperview().offset(70)
            make_Nest.width.height.equalTo(100)
        }
        avatarWrapper_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(84)
        }
        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }

        // 名字 & 简介
        nameLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(ringView_Nest.snp.bottom).offset(12)
            make_Nest.centerX.equalToSuperview()
            make_Nest.leading.greaterThanOrEqualToSuperview().offset(24)
            make_Nest.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        bioLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLabel_Nest.snp.bottom).offset(6)
            make_Nest.leading.equalToSuperview().offset(32)
            make_Nest.trailing.equalToSuperview().offset(-32)
            // 保留足够底部空间（波浪深度约 46pt），避免文字被蒙版裁切
            make_Nest.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }

    // MARK: - 公共方法

    /// 刷新渐变 frame 与波浪底边蒙版
    func updateLayout_Nest() {
        gradientLayer_Nest?.frame = bounds
        ringGradient_Nest?.frame = ringView_Nest.bounds

        let path_Nest = UIBezierPath()
        path_Nest.move(to: .zero)
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: 0))
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 20))
        path_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: bounds.height - 20),
            controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height + 26)
        )
        path_Nest.close()

        let mask_Nest = CAShapeLayer()
        mask_Nest.path = path_Nest.cgPath
        layer.mask = mask_Nest
    }

    /// 更新昵称与简介文本
    /// - Parameters:
    ///   - name_Nest: 用户昵称
    ///   - bio_Nest: 用户简介
    func configure_Nest(name_Nest: String, bio_Nest: String) {
        nameLabel_Nest.text = name_Nest
        bioLabel_Nest.text = bio_Nest
    }

    // MARK: - 事件

    @objc private func settingTapped_Nest() {
        settingBtnContainer_Nest.animatePressDown_Nest {
            self.settingBtnContainer_Nest.animatePressUp_Nest()
        }
        onSettingTapped_Nest?()
    }

    @objc private func editTapped_Nest() {
        editBtnContainer_Nest.animatePressDown_Nest {
            self.editBtnContainer_Nest.animatePressUp_Nest()
        }
        onEditTapped_Nest?()
    }
}

// MARK: - MeStatView_Nest
/// 单列统计视图（数字 + 标题）
private class MeStatView_Nest: UIView {

    init(number: UILabel, title: String) {
        super.init(frame: .zero)
        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = title
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        titleLbl_Nest.textAlignment = .center

        addSubview(number)
        addSubview(titleLbl_Nest)

        number.snp.makeConstraints { make_Nest in
            make_Nest.top.centerX.equalToSuperview()
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(number.snp.bottom).offset(3)
            make_Nest.centerX.equalToSuperview()
            make_Nest.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 创建统计数字标签
    static func makeNumber_Nest() -> UILabel {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "0"
        lbl_Nest.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.primaryGradientStart_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }
}

// MARK: - MeTabBarView_Nest
/// 自定义滑动胶囊 Tab 选择器
/// 设计：浅灰色容器 + 白色滑动胶囊（带阴影）+ SF Symbol 图标 + 文字
/// 选中态：白色胶囊 + 渐变主题色文字；未选中：灰色文字透明背景
private class MeTabBarView_Nest: UIView {

    var onTabChanged_Nest: ((Int) -> Void)?

    /// 白色滑动胶囊（在选中 Tab 下方移动）
    private let pillView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = .white
        v_Nest.layer.cornerRadius = 12
        v_Nest.layer.shadowColor = UIColor.black.cgColor
        v_Nest.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_Nest.layer.shadowRadius = 6
        v_Nest.layer.shadowOpacity = 0.08
        return v_Nest
    }()

    private let tab1Btn_Nest = MeTabBarView_Nest.makeTabBtn_Nest("My Posts", icon: "square.grid.2x2.fill")
    private let tab2Btn_Nest = MeTabBarView_Nest.makeTabBtn_Nest("Liked",    icon: "heart.fill")

    private var pillLeading_Nest: Constraint?
    private var selectedIndex_Nest: Int = 0
    private var hasInitialPillLayout_Nest = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        // 浅灰色容器背景，圆角包裹整体
        backgroundColor = UIColor(hexstring_Nest: "#EDF2F7")
        layer.cornerRadius = 16
        clipsToBounds = false
        setupView_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 首次有真实 bounds 后定位胶囊，避免时序问题
        if !hasInitialPillLayout_Nest && bounds.width > 0 {
            hasInitialPillLayout_Nest = true
            updatePill_Nest(index: selectedIndex_Nest, animated: false)
        }
    }

    /// 创建带图标的 Tab 按钮
    /// - Parameters:
    ///   - title: 按钮标题文字
    ///   - icon: SF Symbol 图标名称
    private static func makeTabBtn_Nest(_ title: String, icon: String) -> UIButton {
        let btn_Nest = UIButton(type: .custom)

        let selectedColor_Nest = ColorConfig_Nest.primaryGradientStart_Nest
        let normalColor_Nest   = ColorConfig_Nest.textPlaceholder_Nest

        var config_Nest = UIButton.Configuration.plain()
        config_Nest.title = title
        config_Nest.image = UIImage(systemName: icon)
        config_Nest.imagePadding = 5
        config_Nest.imagePlacement = .leading
        config_Nest.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        // 清除 plain() 自带的高亮背景，防止与胶囊视图叠加出现重影
        config_Nest.background.backgroundColor = .clear
        config_Nest.background.visualEffect = nil
        btn_Nest.configuration = config_Nest

        btn_Nest.configurationUpdateHandler = { button_Nest in
            var cfg_Nest = button_Nest.configuration
            let color_Nest = button_Nest.isSelected ? selectedColor_Nest : normalColor_Nest
            cfg_Nest?.background.backgroundColor = .clear
            cfg_Nest?.baseForegroundColor = color_Nest
            cfg_Nest?.attributedTitle = AttributedString(
                title,
                attributes: AttributeContainer([
                    .font: UIFont.systemFont(ofSize: 14, weight: button_Nest.isSelected ? .bold : .medium),
                    .foregroundColor: color_Nest
                ])
            )
            button_Nest.configuration = cfg_Nest
        }
        return btn_Nest
    }

    private func setupView_Nest() {
        // 胶囊先加入，确保层级在按钮下方
        addSubview(pillView_Nest)
        addSubview(tab1Btn_Nest)
        addSubview(tab2Btn_Nest)

        tab1Btn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.bottom.equalToSuperview().inset(4)
            make_Nest.leading.equalToSuperview().offset(4)
            make_Nest.width.equalToSuperview().multipliedBy(0.5).offset(-4)
        }
        tab2Btn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.bottom.equalToSuperview().inset(4)
            make_Nest.trailing.equalToSuperview().offset(-4)
            make_Nest.width.equalToSuperview().multipliedBy(0.5).offset(-4)
        }
        // 胶囊大小始终对齐 tab1（两个 tab 等宽）；位置由 pillLeading 约束驱动
        pillView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(4)
            make_Nest.bottom.equalToSuperview().offset(-4)
            make_Nest.width.equalTo(tab1Btn_Nest)
            pillLeading_Nest = make_Nest.leading.equalToSuperview().offset(4).constraint
        }

        tab1Btn_Nest.isSelected = true
        tab1Btn_Nest.addTarget(self, action: #selector(onTab1_Nest), for: .touchUpInside)
        tab2Btn_Nest.addTarget(self, action: #selector(onTab2_Nest), for: .touchUpInside)
    }

    /// 将白色胶囊滑动到指定 Tab 的位置
    /// 使用目标按钮的实际 frame.minX 作为偏移，避免手动计算误差
    /// - Parameters:
    ///   - index: Tab 索引（0 或 1）
    ///   - animated: 是否执行弹性动画
    private func updatePill_Nest(index: Int, animated: Bool = true) {
        // 读取对应 tab 按钮的实际 leading 值，胶囊与其精确对齐
        let targetX_Nest = index == 0 ? tab1Btn_Nest.frame.minX : tab2Btn_Nest.frame.minX
        pillLeading_Nest?.update(offset: targetX_Nest)

        let block_Nest = { self.layoutIfNeeded() }
        if animated {
            UIView.animate(
                withDuration: AnimationConfig_Nest.durationNormal_Nest,
                delay: 0,
                usingSpringWithDamping: AnimationConfig_Nest.springDampingNormal_Nest,
                initialSpringVelocity: AnimationConfig_Nest.springVelocity_Nest,
                options: [.curveEaseOut],
                animations: block_Nest
            )
        } else {
            block_Nest()
        }
    }

    @objc private func onTab1_Nest() {
        guard selectedIndex_Nest != 0 else { return }
        selectedIndex_Nest = 0
        tab1Btn_Nest.isSelected = true
        tab2Btn_Nest.isSelected = false
        updatePill_Nest(index: 0)
        onTabChanged_Nest?(0)
    }

    @objc private func onTab2_Nest() {
        guard selectedIndex_Nest != 1 else { return }
        selectedIndex_Nest = 1
        tab1Btn_Nest.isSelected = false
        tab2Btn_Nest.isSelected = true
        updatePill_Nest(index: 1)
        onTabChanged_Nest?(1)
    }
}

// MARK: - PostCard_Nest
/// 帖子卡片组件
/// 设计要点：
///   - 左侧媒体缩略图（如有，72×72，圆角，覆盖填充）
///   - 右侧标题 + 内容摘要（2 行）
///   - 底部互动数：❤ 点赞 + 💬 评论
///   - 右上角举报/删除按钮
///   - 按压缩放反馈动画
private class PostCard_Nest: UIView {

    var onTap_Nest: ((TitleModel_Nest) -> Void)?

    private let post_Nest: TitleModel_Nest

    private let cardContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 18
        v_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_Nest.layer.shadowRadius = 10
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    /// 媒体缩略图（左侧，仅在有媒体时显示）
    private let thumbnailView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.contentMode = .scaleAspectFill
        iv_Nest.clipsToBounds = true
        iv_Nest.layer.cornerRadius = 12
        iv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        lbl_Nest.numberOfLines = 1
        return lbl_Nest
    }()

    private let contentLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    /// 互动数区域（点赞 + 评论数量）
    private let statsRow_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .horizontal
        sv_Nest.spacing = 14
        sv_Nest.alignment = .center
        return sv_Nest
    }()

    private let reportBtn_Nest: UIButton

    init(post: TitleModel_Nest, from vc: UIViewController) {
        self.post_Nest = post
        self.reportBtn_Nest = ReportDeleteHelper_Nest.createPostReportButton_Nest(
            post_Nest: post,
            size_Nest: 15,
            color_Nest: ColorConfig_Nest.textPlaceholder_Nest,
            from: vc
        )
        super.init(frame: .zero)
        setupCardUI_Nest()
        configure_Nest(post: post)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCardUI_Nest() {
        addSubview(cardContainer_Nest)
        cardContainer_Nest.addSubview(thumbnailView_Nest)
        cardContainer_Nest.addSubview(titleLabel_Nest)
        cardContainer_Nest.addSubview(contentLabel_Nest)
        cardContainer_Nest.addSubview(statsRow_Nest)
        cardContainer_Nest.addSubview(reportBtn_Nest)

        cardContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }

        // 缩略图（左侧固定尺寸）
        thumbnailView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(72)
        }

        // 举报按钮（右上角）
        reportBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(10)
            make_Nest.trailing.equalToSuperview().offset(-10)
            make_Nest.width.height.equalTo(28)
        }

        // 标题（缩略图右侧）
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(14)
            make_Nest.leading.equalTo(thumbnailView_Nest.snp.trailing).offset(12)
            make_Nest.trailing.equalTo(reportBtn_Nest.snp.leading).offset(-6)
        }

        contentLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(5)
            make_Nest.leading.equalTo(titleLabel_Nest)
            make_Nest.trailing.equalToSuperview().offset(-14)
        }

        statsRow_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(contentLabel_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalTo(titleLabel_Nest)
            make_Nest.bottom.equalToSuperview().offset(-14)
        }

        // 点击手势
        let tap_Nest = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Nest))
        cardContainer_Nest.isUserInteractionEnabled = true
        cardContainer_Nest.addGestureRecognizer(tap_Nest)
    }

    /// 填充帖子内容
    /// - Parameter post: 帖子模型
    private func configure_Nest(post: TitleModel_Nest) {
        titleLabel_Nest.text = post.title_Nest
        contentLabel_Nest.text = post.titleContent_Nest

        // 加载缩略图
        if let firstMedia_Nest = post.titleMeidas_Nest.first, !firstMedia_Nest.isEmpty {
            if let url_Nest = URL(string: firstMedia_Nest) {
                thumbnailView_Nest.kf.setImage(with: url_Nest, placeholder: makeThumbnailPlaceholder_Nest())
            } else if let img_Nest = UIImage(named: firstMedia_Nest) {
                thumbnailView_Nest.image = img_Nest
            } else {
                thumbnailView_Nest.image = makeThumbnailPlaceholder_Nest()
            }
        } else {
            thumbnailView_Nest.image = makeThumbnailPlaceholder_Nest()
        }

        // 互动统计标签
        statsRow_Nest.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statsRow_Nest.addArrangedSubview(makeStatChip_Nest(icon: "heart.fill", count: post.likes_Nest, color: UIColor(hexstring_Nest: "#FC8181")))
        statsRow_Nest.addArrangedSubview(makeStatChip_Nest(icon: "bubble.left.fill", count: post.reviews_Nest.count, color: ColorConfig_Nest.primaryGradientStart_Nest))
    }

    /// 创建互动数胶囊标签（图标 + 数量）
    private func makeStatChip_Nest(icon: String, count: Int, color: UIColor) -> UIView {
        let wrapper_Nest = UIView()
        let iv_Nest = UIImageView(image: UIImage(systemName: icon))
        iv_Nest.tintColor = color
        iv_Nest.contentMode = .scaleAspectFit

        let lbl_Nest = UILabel()
        lbl_Nest.text = "\(count)"
        lbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest

        wrapper_Nest.addSubview(iv_Nest)
        wrapper_Nest.addSubview(lbl_Nest)

        iv_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(13)
        }
        lbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(iv_Nest.snp.trailing).offset(4)
            make_Nest.centerY.equalToSuperview()
            make_Nest.trailing.equalToSuperview()
            make_Nest.top.bottom.equalToSuperview()
        }
        return wrapper_Nest
    }

    /// 生成缩略图占位图（浅色背景 + 图片图标）
    private func makeThumbnailPlaceholder_Nest() -> UIImage? {
        let size_Nest = CGSize(width: 72, height: 72)
        UIGraphicsBeginImageContextWithOptions(size_Nest, false, 0)
        ColorConfig_Nest.backgroundPrimary_Nest.setFill()
        UIRectFill(CGRect(origin: .zero, size: size_Nest))
        let icon_Nest = UIImage(systemName: "photo")?.withTintColor(ColorConfig_Nest.textPlaceholder_Nest, renderingMode: .alwaysOriginal)
        icon_Nest?.draw(in: CGRect(x: 22, y: 22, width: 28, height: 28))
        let img_Nest = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img_Nest
    }

    @objc private func cardTapped_Nest() {
        cardContainer_Nest.animatePressDown_Nest {
            self.cardContainer_Nest.animatePressUp_Nest()
        }
        onTap_Nest?(post_Nest)
    }
}

// MARK: - MeEmptyView_Nest
/// 空态提示视图（帖子列表为空时展示）
/// 展示：渐变圆形图标容器 + 浮动动画 + 标题 + 副标题
private class MeEmptyView_Nest: UIView {

    private let iconContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
        v_Nest.layer.cornerRadius = 38
        return v_Nest
    }()

    private let iconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "doc.text.fill")
        iv_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "No posts yet"
        lbl_Nest.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let subtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Share your first moment\nwith the community"
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.textAlignment = .center
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmptyUI_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { startFloat_Nest() }
    }

    private func setupEmptyUI_Nest() {
        addSubview(iconContainer_Nest)
        iconContainer_Nest.addSubview(iconView_Nest)
        addSubview(titleLabel_Nest)
        addSubview(subtitleLabel_Nest)

        iconContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.centerX.equalToSuperview()
            make_Nest.width.height.equalTo(76)
        }
        iconView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(36)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(iconContainer_Nest.snp.bottom).offset(18)
            make_Nest.centerX.equalToSuperview()
        }
        subtitleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(8)
            make_Nest.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func startFloat_Nest() {
        UIView.animate(
            withDuration: 1.8,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: { self.iconContainer_Nest.transform = CGAffineTransform(translationX: 0, y: -10) }
        )
    }
}
