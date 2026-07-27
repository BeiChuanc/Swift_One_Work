import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 我的页面视图控制器
/// 功能：展示当前登录用户信息、发布帖子列表、喜欢帖子列表，支持举报/删除操作
/// 设计：三色渐变头部+胶囊操作按钮、头像渐变环、彩色数据统计、帖子彩色口音条卡片
class Me_Bague: UIViewController {

    // MARK: - 属性

    /// 外部传入的用户数据（可选，默认使用当前登录用户）
    var meModel_Bague: LoginUserModel_Bague?

    // MARK: - UI 组件（头部）

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        // 禁止自动添加 safeArea 内边距，让头部渐变紧贴屏幕顶端
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Bague = UIView()

    private let headerView_Bague = UIView()
    private var headerGradient_Bague: CAGradientLayer?

    /// 头部装饰：半透明大圆
    private let headerDecorCircle_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 55
        return v
    }()

    /// 头部装饰：大闪光图标
    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = UIColor.white.withAlphaComponent(0.16)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 设置按钮（半透明胶囊）
    private let settingBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    /// 编辑按钮（半透明胶囊）
    private let editBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    /// VIP 按钮（vip_btn 图标，宽度自适应）
    private let vipBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let img = UIImage(named: "vip_btn")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - UI 组件（用户信息区）

    /// 头像外环（渐变色边框）
    private let avatarRing_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 52
        return v
    }()

    private var avatarRingGradient_Bague: CAGradientLayer?

    private let avatarContainerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 46
        return v
    }()

    private let avatarView_Bague = CurrentUserAvatarView_Bague()

    private let nameLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        label.textAlignment = .center
        return label
    }()

    private let bioLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    /// 数据统计行
    private let statsCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    private let statsRow_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        return sv
    }()

    // MARK: - UI 组件（分段 & 帖子）

    private let segmentCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 10
        return v
    }()

    private let segmentControl_Bague: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["My Posts", "Liked"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = UIColor(hexstring_Bague: "#9B72F5")
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        sc.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Bague.textSecondary_Bague,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        return sc
    }()

    private let postsContainer_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()

    // MARK: - 空状态视图

    private let emptyView_Bague: UIView = {
        let v = UIView()
        v.isHidden = true
        v.alpha = 0
        return v
    }()

    private let emptyIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        iv.image = UIImage(systemName: "tray.fill", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Bague.primaryGradientStart_Bague.withAlphaComponent(0.35)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "No posts yet"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        return label
    }()

    // MARK: - 数据

    private var currentSegment_Bague = 0

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Bague()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupBindings_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient_Bague()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // contentInsetAdjustmentBehavior = .never 时手动补充底部安全区，保证内容可完整滚动
        scrollView_Bague.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView_Bague.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)
        contentView_Bague.addSubview(headerView_Bague)

        // 头部装饰与按钮
        headerView_Bague.addSubview(headerDecorCircle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        headerView_Bague.addSubview(settingBtn_Bague)
        headerView_Bague.addSubview(editBtn_Bague)
        headerView_Bague.addSubview(vipBtn_Bague)
        settingBtn_Bague.addTarget(self, action: #selector(settingTapped_Bague), for: .touchUpInside)
        editBtn_Bague.addTarget(self, action: #selector(editTapped_Bague), for: .touchUpInside)
        vipBtn_Bague.addTarget(self, action: #selector(vipBtnTapped_Bague), for: .touchUpInside)

        // 头像（渐变环）
        contentView_Bague.addSubview(avatarRing_Bague)
        avatarRing_Bague.addSubview(avatarContainerView_Bague)
        avatarContainerView_Bague.addSubview(avatarView_Bague)
        avatarView_Bague.onTapped_Bague = { [weak self] in
            Navigation_Bague.toEditInfo_Bague()
        }

        // 用户信息
        contentView_Bague.addSubview(nameLabel_Bague)
        contentView_Bague.addSubview(bioLabel_Bague)

        // 统计卡片
        contentView_Bague.addSubview(statsCard_Bague)
        statsCard_Bague.addSubview(statsRow_Bague)
        setupStatsRow_Bague()

        // 分段控制器
        contentView_Bague.addSubview(segmentCard_Bague)
        segmentCard_Bague.addSubview(segmentControl_Bague)
        segmentControl_Bague.addTarget(self, action: #selector(segmentChanged_Bague(_:)), for: .valueChanged)

        // 帖子列表
        contentView_Bague.addSubview(postsContainer_Bague)

        // 空状态
        contentView_Bague.addSubview(emptyView_Bague)
        emptyView_Bague.addSubview(emptyIcon_Bague)
        emptyView_Bague.addSubview(emptyLabel_Bague)
    }

    private func setupStatsRow_Bague() {
        let items_bague: [(String, String, UIColor)] = [
            ("Posts", "0", UIColor(hexstring_Bague: "#9B72F5")),
            ("Followers", "0", UIColor(hexstring_Bague: "#5AADEC")),
            ("Following", "0", UIColor(hexstring_Bague: "#3DC9A6"))
        ]
        items_bague.forEach { (title, value, color) in
            let statView_bague = MeStatView_Bague(title_bague: title, value_bague: value, accentColor_bague: color)
            statsRow_Bague.addArrangedSubview(statView_bague)
        }
    }

    private func setupConstraints_Bague() {
        scrollView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        headerDecorCircle_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(-15)
            make.width.height.equalTo(110)
        }
        headerDecorIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
            make.width.height.equalTo(70)
        }
        settingBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }
        editBtn_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(settingBtn_Bague)
            make.trailing.equalTo(settingBtn_Bague.snp.leading).offset(-10)
            make.width.height.equalTo(36)
        }
        vipBtn_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(settingBtn_Bague)
            make.trailing.equalTo(editBtn_Bague.snp.leading).offset(-10)
            make.height.equalTo(36)
        }

        // 头像渐变环
        avatarRing_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerView_Bague.snp.bottom).offset(-44)
            make.width.height.equalTo(100)
        }
        avatarContainerView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }
        avatarView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }

        nameLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        bioLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Bague.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        // 统计卡片
        statsCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Bague.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(72)
        }
        statsRow_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        // 分段控制器
        segmentCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        segmentControl_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }

        // 帖子列表
        postsContainer_Bague.snp.makeConstraints { make in
            make.top.equalTo(segmentCard_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-100)
        }

        // 空状态
        emptyView_Bague.snp.makeConstraints { make in
            make.top.equalTo(segmentCard_Bague.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
        }
        emptyIcon_Bague.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        emptyLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Bague.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 渐变

    private func updateGradient_Bague() {
        // 头部三色斜角渐变
        headerGradient_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = headerView_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        grad_bague.locations = [0.0, 0.55, 1.0]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        grad_bague.cornerRadius = 28
        grad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(grad_bague, at: 0)
        headerGradient_Bague = grad_bague

        // 头像渐变环：紫→蓝
        avatarRingGradient_Bague?.removeFromSuperlayer()
        let ring_bague = CAGradientLayer()
        ring_bague.frame = avatarRing_Bague.bounds
        ring_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor
        ]
        ring_bague.startPoint = CGPoint(x: 0, y: 0)
        ring_bague.endPoint = CGPoint(x: 1, y: 1)
        ring_bague.cornerRadius = 52
        avatarRing_Bague.layer.insertSublayer(ring_bague, at: 0)
        avatarRingGradient_Bague = ring_bague
    }

    // MARK: - 数据绑定

    private func setupBindings_Bague() {
        [UserViewModel_Bague.userStateDidChangeNotification_Bague,
         TitleViewModel_Bague.titleStateDidChangeNotification_Bague].forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(dataChanged_Bague),
                name: $0,
                object: nil
            )
        }
    }

    @objc private func dataChanged_Bague() { reloadData_Bague() }

    // MARK: - 数据刷新

    private func reloadData_Bague() {
        let currentUser_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        let user_bague = meModel_Bague ?? currentUser_bague

        if !UserViewModel_Bague.shared_Bague.isLoggedIn_Bague {
            nameLabel_Bague.text = "Guest"
            bioLabel_Bague.text = "Sign in to view your profile"
            updateStats_Bague(posts: 0, followers: 0, following: 0)
            refreshPostList_Bague(posts: [])
            return
        }

        nameLabel_Bague.text = user_bague.userName_Bague ?? "Unknown"
        bioLabel_Bague.text = user_bague.userIntroduce_Bague ?? "No bio yet"

        let allPosts_bague = TitleViewModel_Bague.shared_Bague.getPosts_Bague()
        let myPosts_bague = allPosts_bague.filter { $0.titleUserId_Bague == user_bague.userId_Bague }
        updateStats_Bague(
            posts: myPosts_bague.count,
            followers: user_bague.userFollow_Bague.count,
            following: user_bague.userFollow_Bague.count
        )

        let showPosts_bague = currentSegment_Bague == 0 ? myPosts_bague : user_bague.userLike_Bague
        refreshPostList_Bague(posts: showPosts_bague)
    }

    private func updateStats_Bague(posts: Int, followers: Int, following: Int) {
        let values_bague = [posts, followers, following]
        statsRow_Bague.arrangedSubviews.enumerated().forEach { idx, view in
            (view as? MeStatView_Bague)?.updateValue_Bague(String(values_bague[idx]))
        }
    }

    private func refreshPostList_Bague(posts: [TitleModel_Bague]) {
        postsContainer_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if posts.isEmpty {
            emptyView_Bague.isHidden = false
            UIView.animate(withDuration: 0.25) { self.emptyView_Bague.alpha = 1 }
        } else {
            UIView.animate(withDuration: 0.15) { self.emptyView_Bague.alpha = 0 } completion: { _ in
                self.emptyView_Bague.isHidden = true
            }
            posts.prefix(20).enumerated().forEach { idx, post in
                let card_bague = MePostCard_Bague(post_bague: post, index_bague: idx, viewController_bague: self)
                postsContainer_Bague.addArrangedSubview(card_bague)
                card_bague.alpha = 0
                UIView.animate(withDuration: 0.3, delay: Double(idx) * 0.04) {
                    card_bague.alpha = 1
                }
            }
        }
    }

    // MARK: - 事件处理

    @objc private func settingTapped_Bague() {
        settingBtn_Bague.animatePulse_Bague()
        Navigation_Bague.toSetting_Bague()
    }

    @objc private func editTapped_Bague() {
        editBtn_Bague.animatePulse_Bague()
        Navigation_Bague.toEditInfo_Bague()
    }

    /// 点击 VIP 按钮，跳转到 VIP 订阅页
    @objc private func vipBtnTapped_Bague() {
        vipBtn_Bague.animatePulse_Bague()
        Navigation_Bague.toVIPSubscription_Bague()
    }

    @objc private func segmentChanged_Bague(_ sender: UISegmentedControl) {
        currentSegment_Bague = sender.selectedSegmentIndex
        reloadData_Bague()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 统计数字视图

/// 用户数据统计视图（帖子数、粉丝数等），带彩色强调数字
class MeStatView_Bague: UIView {

    private let valueLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        return label
    }()

    /// 分隔线（除最后一项外展示）
    private let separator_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        return v
    }()

    init(title_bague: String, value_bague: String, accentColor_bague: UIColor) {
        super.init(frame: .zero)
        titleLabel_Bague.text = title_bague
        valueLabel_Bague.text = value_bague
        valueLabel_Bague.textColor = accentColor_bague

        addSubview(valueLabel_Bague)
        addSubview(titleLabel_Bague)
        addSubview(separator_Bague)

        valueLabel_Bague.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Bague.snp.bottom).offset(3)
            make.centerX.bottom.equalToSuperview()
        }
        separator_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func updateValue_Bague(_ value: String) {
        valueLabel_Bague.text = value
    }
}

// MARK: - 帖子卡片视图

/// 我的页面帖子卡片（带彩色口音条和调和配色渐变占位）
class MePostCard_Bague: UIView {

    private let post_Bague: TitleModel_Bague
    private weak var vc_Bague: UIViewController?

    /// 调和配色（6组，与发现页统一）
    private static let accentTints_Bague: [UIColor] = [
        UIColor(hexstring_Bague: "#9B72F5"),
        UIColor(hexstring_Bague: "#5AADEC"),
        UIColor(hexstring_Bague: "#F07DAD"),
        UIColor(hexstring_Bague: "#3DC9A6"),
        UIColor(hexstring_Bague: "#F5A623"),
        UIColor(hexstring_Bague: "#F07060"),
    ]

    private static let accentBg_Bague: [UIColor] = [
        UIColor(hexstring_Bague: "#EDD9FF"),
        UIColor(hexstring_Bague: "#D0EDFF"),
        UIColor(hexstring_Bague: "#FFD9EE"),
        UIColor(hexstring_Bague: "#D4F7ED"),
        UIColor(hexstring_Bague: "#FFF0D0"),
        UIColor(hexstring_Bague: "#FFE4D9"),
    ]

    private let card_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    private let mediaView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return iv
    }()

    /// 左侧彩色口音条
    private let accentBar_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return v
    }()

    private let titleLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        label.numberOfLines = 1
        return label
    }()

    private let contentLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.numberOfLines = 2
        return label
    }()

    /// 点赞徽章
    private let likesChip_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        return v
    }()

    private let likesLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return label
    }()

    private var reportBtn_Bague: UIButton?

    init(post_bague: TitleModel_Bague, index_bague: Int, viewController_bague: UIViewController) {
        self.post_Bague = post_bague
        self.vc_Bague = viewController_bague
        super.init(frame: .zero)
        setupUI_Bague(index_bague: index_bague)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Bague(index_bague: Int) {
        let colorIdx_bague = index_bague % MePostCard_Bague.accentTints_Bague.count
        let tint_bague = MePostCard_Bague.accentTints_Bague[colorIdx_bague]
        let bgColor_bague = MePostCard_Bague.accentBg_Bague[colorIdx_bague]

        addSubview(card_Bague)
        card_Bague.addSubview(mediaView_Bague)
        card_Bague.addSubview(accentBar_Bague)
        card_Bague.addSubview(titleLabel_Bague)
        card_Bague.addSubview(contentLabel_Bague)
        card_Bague.addSubview(likesChip_Bague)
        likesChip_Bague.addSubview(likesLabel_Bague)

        accentBar_Bague.backgroundColor = tint_bague
        likesChip_Bague.backgroundColor = tint_bague.withAlphaComponent(0.12)
        likesLabel_Bague.textColor = tint_bague
        likesLabel_Bague.text = "♥ \(post_Bague.likes_Bague)"

        // 举报/删除按钮
        if let vc_bague = vc_Bague {
            let btn_bague = ReportDeleteHelper_Bague.createPostReportButton_Bague(
                post_Bague: post_Bague,
                size_Bague: 14,
                color_Bague: ColorConfig_Bague.textSecondary_Bague,
                from: vc_bague,
                completion_Bague: nil
            )
            card_Bague.addSubview(btn_bague)
            btn_bague.snp.makeConstraints { make in
                make.top.equalTo(mediaView_Bague.snp.bottom).offset(12)
                make.trailing.equalToSuperview().offset(-12)
                make.width.height.equalTo(26)
            }
            reportBtn_Bague = btn_bague
        }

        // 媒体
        let mediaName_bague = post_Bague.titleMeidas_Bague.first ?? ""
        if let img_bague = UIImage(named: mediaName_bague) {
            mediaView_Bague.image = img_bague
            mediaView_Bague.contentMode = .scaleAspectFill
        } else {
            mediaView_Bague.backgroundColor = bgColor_bague
            mediaView_Bague.image = UIImage(systemName: "bag.fill")
            mediaView_Bague.tintColor = tint_bague.withAlphaComponent(0.55)
            mediaView_Bague.contentMode = .scaleAspectFit
        }

        titleLabel_Bague.text = post_Bague.title_Bague
        contentLabel_Bague.text = post_Bague.titleContent_Bague

        // 约束
        card_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }
        accentBar_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Bague.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Bague.snp.bottom).offset(12)
            make.leading.equalTo(accentBar_Bague.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-44)
        }
        contentLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Bague.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
        likesChip_Bague.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Bague.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(20)
        }
        likesLabel_Bague.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }

        // 点击进入详情
        let tap_bague = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Bague))
        card_Bague.addGestureRecognizer(tap_bague)
        card_Bague.isUserInteractionEnabled = true
    }

    @objc private func cardTapped_Bague() {
        animatePressDown_Bague {
            self.animatePressUp_Bague {
                Navigation_Bague.toTitleDetail_Bague(titleModel_bague: self.post_Bague)
            }
        }
    }
}
