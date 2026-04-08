import Foundation
import UIKit
import SnapKit

// MARK: - 我的页面

/// 我的页面
/// 核心作用：无论是否登录均完整展示个人主页；登录状态显示真实数据，游客显示占位数据
/// 设计思路：沉浸式渐变封面（菱形纹理 + 浮动粒子） + 三层头像环 + 白色内容区三栏统计卡片 + 定制分段 + 帖子列表
/// 关键方法：refreshUI_Somnia / refreshPostList_Somnia / switchSegment_Somnia
class Me_Somnia: UIViewController {

    // MARK: - 公共属性

    var meModel_Somnia: LoginUserModel_Somnia?

    // MARK: - 私有属性

    /// 当前选中分段（0 = Posts，1 = Liked）
    private var selectedSegment_Somnia: Int = 0

    // MARK: - UI — 滚动容器

    private let scrollView_Somnia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Somnia = UIView()

    // MARK: - UI — 封面

    private let coverView_Somnia: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var coverGradient_Somnia: CAGradientLayer?

    /// 浮动粒子集合
    private var particles_Somnia: [UIView] = []

    // MARK: - UI — 顶部操作按钮（始终显示）

    private let editButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 19
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        btn.layer.borderWidth = 1
        return btn
    }()

    private let settingButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 19
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        btn.layer.borderWidth = 1
        return btn
    }()

    /// VIP 入口按钮（vip_btn 图片资源），位于封面左上角，仅展示图标
    private let vipButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "vip_btn"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    // MARK: - UI — 头像区域

    /// 最外层：彩色渐变光圈
    private let avatarOuterRing_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 56
        return v
    }()

    private var avatarRingGradient_Somnia: CAGradientLayer?

    /// 中层：白色间隔环
    private let avatarWhiteBorder_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        v.layer.cornerRadius = 50
        return v
    }()

    /// 内层：头像（登录状态）
    private let avatarView_Somnia = CurrentUserAvatarView_Somnia()

    /// 内层：游客占位头像
    private let guestAvatarBg_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 44
        v.isHidden = true
        return v
    }()

    private var guestAvatarGradient_Somnia: CAGradientLayer?

    private let guestAvatarSymbol_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 36, weight: .ultraLight)
        iv.image = UIImage(systemName: "person.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.9)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI — 个人信息

    /// 昵称行：前缀"Nickname"与内容内联同行
    private let nameLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0, height: 1)
        lbl.layer.shadowOpacity = 0.12
        lbl.layer.shadowRadius = 3
        return lbl
    }()

    /// 简介行：前缀"Bio"与内容内联同行
    private let bioLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    // MARK: - UI — 白色内容卡片（托起统计 + 帖子）

    private let contentCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    // MARK: - UI — 三栏统计（独立卡片）

    private let statsContainer_Somnia = UIView()

    private let postsStatCard_Somnia  = MeStatCard_Somnia(title_Somnia: "Posts",     icon_Somnia: "doc.text.fill")
    private let likedStatCard_Somnia  = MeStatCard_Somnia(title_Somnia: "Liked",     icon_Somnia: "heart.fill")
    private let followStatCard_Somnia = MeStatCard_Somnia(title_Somnia: "Following", icon_Somnia: "person.2.fill")

    // MARK: - UI — 自定义分段选择器

    private let segmentContainer_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Somnia: "#E8EDF4")
        v.layer.cornerRadius = 16
        return v
    }()

    /// 渐变滑块
    private let segmentIndicator_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor(hexstring_Somnia: "#B794F6").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 0.22
        return v
    }()

    private var segmentIndicatorGradient_Somnia: CAGradientLayer?

    private let postsSegBtn_Somnia: UIButton  = Me_Somnia.makeSegBtn_Somnia(title_Somnia: "Posts",  icon_Somnia: "doc.text")
    private let likedSegBtn_Somnia: UIButton  = Me_Somnia.makeSegBtn_Somnia(title_Somnia: "Liked",  icon_Somnia: "heart")

    // MARK: - UI — 帖子列表

    private let tableView_Somnia: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.isScrollEnabled = false
        return tv
    }()

    // MARK: - UI — 空状态

    /// 底部撑高占位：确保 ScrollView contentSize 足够容纳空状态内容
    private let contentBottomPin_Somnia = UIView()

    private let emptyView_Somnia: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyCircle_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 44
        return v
    }()

    private var emptyCircleGradient_Somnia: CAGradientLayer?

    private let emptyEmojiLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 34)
        lbl.textAlignment = .center
        return lbl
    }()

    private let emptyTitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        lbl.textAlignment = .center
        return lbl
    }()

    private let emptySubLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshUI_Somnia()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        setupUI_Somnia()
        setupActions_Somnia()
        setupNotifications_Somnia()
        refreshUI_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients_Somnia()
        updateTableHeight_Somnia()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知

    private func setupNotifications_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserChange_Somnia),
            name: UserViewModel_Somnia.userStateDidChangeNotification_Somnia,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleChange_Somnia),
            name: TitleViewModel_Somnia.titleStateDidChangeNotification_Somnia,
            object: nil
        )
    }

    @objc private func handleUserChange_Somnia() { refreshUI_Somnia() }
    @objc private func handleTitleChange_Somnia() { refreshPostList_Somnia() }

    // MARK: - 数据刷新

    /// 刷新整页数据；登录/游客均可正常展示
    private func refreshUI_Somnia() {
        let isLoggedIn_Somnia = UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia
        let user_Somnia       = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()

        // 头像切换
        avatarView_Somnia.isHidden   = !isLoggedIn_Somnia
        guestAvatarBg_Somnia.isHidden = isLoggedIn_Somnia

        // 基本信息（前缀与内容同行）
        let nickName_Somnia = isLoggedIn_Somnia ? (user_Somnia.userName_Somnia ?? "User") : "Guest"
        let bioText_Somnia  = isLoggedIn_Somnia
            ? (user_Somnia.userIntroduce_Somnia?.isEmpty == false ? user_Somnia.userIntroduce_Somnia! : "Dreamer & Explorer ✨")
            : "Dreamer & Explorer 🌙"
        nameLabel_Somnia.attributedText = makeInlineLabel_Somnia(prefix_Somnia: "Nickname", content_Somnia: nickName_Somnia, contentSize_Somnia: 22)
        bioLabel_Somnia.attributedText  = makeInlineLabel_Somnia(prefix_Somnia: "Bio", content_Somnia: bioText_Somnia, contentSize_Somnia: 13)

        // 统计数字
        postsStatCard_Somnia.update_Somnia(count_Somnia: isLoggedIn_Somnia ? user_Somnia.userPosts_Somnia.count : 0)
        likedStatCard_Somnia.update_Somnia(count_Somnia: isLoggedIn_Somnia ? user_Somnia.userLike_Somnia.count : 0)
        followStatCard_Somnia.update_Somnia(count_Somnia: isLoggedIn_Somnia ? user_Somnia.userFollow_Somnia.count : 0)

        refreshPostList_Somnia()
    }

    /// 构建前缀与内容内联同行的 NSAttributedString
    /// - Parameters:
    ///   - prefix_Somnia: 前缀描述文字（如 "Nickname"、"Bio"）
    ///   - content_Somnia: 正文内容
    ///   - contentSize_Somnia: 正文字号
    /// - Returns: 前缀半透明小字 + 空格 + 正文粗体白字的 attributed string
    private func makeInlineLabel_Somnia(prefix_Somnia: String, content_Somnia: String, contentSize_Somnia: CGFloat) -> NSAttributedString {
        let prefixAttr_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: contentSize_Somnia, weight: .bold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.55)
        ]
        let contentAttr_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: contentSize_Somnia, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let result_Somnia = NSMutableAttributedString(string: "\(prefix_Somnia):  ", attributes: prefixAttr_Somnia)
        result_Somnia.append(NSAttributedString(string: content_Somnia, attributes: contentAttr_Somnia))
        return result_Somnia
    }

    /// 刷新帖子列表与空状态
    private func refreshPostList_Somnia() {
        tableView_Somnia.reloadData()
        updateTableHeight_Somnia()

        let isEmpty_Somnia = currentPosts_Somnia().isEmpty
        emptyView_Somnia.isHidden = !isEmpty_Somnia
        tableView_Somnia.isHidden = isEmpty_Somnia

        if isEmpty_Somnia {
            if selectedSegment_Somnia == 0 {
                emptyEmojiLabel_Somnia.text  = "✍️"
                emptyTitleLabel_Somnia.text  = "No posts yet"
                emptySubLabel_Somnia.text    = "Share your first dream with the world"
            } else {
                emptyEmojiLabel_Somnia.text  = "💫"
                emptyTitleLabel_Somnia.text  = "Nothing liked yet"
                emptySubLabel_Somnia.text    = "Explore and tap ♡ on content you love"
            }
            emptyView_Somnia.animateSpringScaleIn_Somnia(delay_Somnia: 0.05)
        }
    }

    /// 动态更新 TableView 高度（外部 ScrollView 自适应）
    private func updateTableHeight_Somnia() {
        let h_Somnia = CGFloat(currentPosts_Somnia().count) * 120
        tableView_Somnia.snp.updateConstraints { make in
            make.height.equalTo(h_Somnia)
        }
    }

    private func currentPosts_Somnia() -> [TitleModel_Somnia] {
        let user_Somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        return selectedSegment_Somnia == 0
            ? user_Somnia.userPosts_Somnia
            : user_Somnia.userLike_Somnia
    }

    // MARK: - UI 搭建

    private func setupUI_Somnia() {
        view.addSubview(scrollView_Somnia)
        scrollView_Somnia.addSubview(contentView_Somnia)

        // 封面（仅渐变背景 + 操作按钮，不含文字）
        contentView_Somnia.addSubview(coverView_Somnia)
        coverView_Somnia.addSubview(editButton_Somnia)
        coverView_Somnia.addSubview(settingButton_Somnia)
        coverView_Somnia.addSubview(vipButton_Somnia)

        // 白色内容卡片
        contentView_Somnia.addSubview(contentCard_Somnia)

        // 头像环（在 contentView 中，覆盖在封面顶部区域）
        contentView_Somnia.addSubview(avatarOuterRing_Somnia)
        avatarOuterRing_Somnia.addSubview(avatarWhiteBorder_Somnia)
        avatarWhiteBorder_Somnia.addSubview(avatarView_Somnia)
        avatarWhiteBorder_Somnia.addSubview(guestAvatarBg_Somnia)
        guestAvatarBg_Somnia.addSubview(guestAvatarSymbol_Somnia)

        // 昵称 + 简介（前缀与内容内联同行）
        contentView_Somnia.addSubview(nameLabel_Somnia)
        contentView_Somnia.addSubview(bioLabel_Somnia)

        // 统计卡片
        contentCard_Somnia.addSubview(statsContainer_Somnia)
        statsContainer_Somnia.addSubview(postsStatCard_Somnia)
        statsContainer_Somnia.addSubview(likedStatCard_Somnia)
        statsContainer_Somnia.addSubview(followStatCard_Somnia)

        // 分段选择器
        contentCard_Somnia.addSubview(segmentContainer_Somnia)
        segmentContainer_Somnia.addSubview(segmentIndicator_Somnia)
        segmentContainer_Somnia.addSubview(postsSegBtn_Somnia)
        segmentContainer_Somnia.addSubview(likedSegBtn_Somnia)

        // 帖子列表
        contentCard_Somnia.addSubview(tableView_Somnia)

        // 空状态
        contentCard_Somnia.addSubview(emptyView_Somnia)

        // 底部撑高占位
        contentCard_Somnia.addSubview(contentBottomPin_Somnia)
        emptyView_Somnia.addSubview(emptyCircle_Somnia)
        emptyCircle_Somnia.addSubview(emptyEmojiLabel_Somnia)
        emptyView_Somnia.addSubview(emptyTitleLabel_Somnia)
        emptyView_Somnia.addSubview(emptySubLabel_Somnia)

        setupConstraints_Somnia()
        setupParticles_Somnia()

        tableView_Somnia.delegate   = self
        tableView_Somnia.dataSource = self
        tableView_Somnia.register(MePostCell_Somnia.self, forCellReuseIdentifier: "MePostCell_Somnia")
    }

    private func setupConstraints_Somnia() {
        // 封面高度：容纳头像 + 昵称 + 简介，留少量底部余量
        let coverH_somnia: CGFloat      = 310
        let avatarSize_somnia: CGFloat  = 112  // 外圈直径
        // 头像顶部距封面顶部（对齐 safeArea 下方 ~44pt）
        let avatarTopInCover_somnia: CGFloat = 78

        scrollView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // 封面（渐变背景，仅提供视觉底色）
        coverView_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(coverH_somnia)
        }

        // 操作按钮（始终可见，右上角）
        settingButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(38)
        }

        editButton_Somnia.snp.makeConstraints { make in
            make.centerY.equalTo(settingButton_Somnia)
            make.right.equalTo(settingButton_Somnia.snp.left).offset(-10)
            make.width.height.equalTo(38)
        }

        // VIP 按钮：高度与设置按钮相同，宽度50，位于封面最左侧
        vipButton_Somnia.snp.makeConstraints { make in
            make.centerY.equalTo(settingButton_Somnia)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(50)
            make.height.equalTo(38)
        }

        // ─── 头像（封面内顶部，不再悬浮于边界）───
        avatarOuterRing_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(avatarTopInCover_somnia)
            make.width.height.equalTo(avatarSize_somnia)
        }

        avatarWhiteBorder_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }

        avatarView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(90)
        }

        guestAvatarBg_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(90)
        }

        guestAvatarSymbol_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }

        // ─── 昵称行（头像正下方，前缀与内容同行）───
        nameLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(avatarOuterRing_Somnia.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
        }

        // ─── 简介行（昵称下方，前缀与内容同行）───
        bioLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Somnia.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(36)
        }

        // ─── 白色内容卡片（从封面底部，圆角顶部）───
        contentCard_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(coverH_somnia - 28)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // ─── 统计卡片（内容卡片顶部，无头像悬浮偏移）───
        statsContainer_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(76)
        }

        postsStatCard_Somnia.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0 / 3.0).offset(-5)
        }

        likedStatCard_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(postsStatCard_Somnia)
        }

        followStatCard_Somnia.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(postsStatCard_Somnia)
        }

        // ─── 分段选择器 ───
        segmentContainer_Somnia.snp.makeConstraints { make in
            make.top.equalTo(statsContainer_Somnia.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }

        segmentIndicator_Somnia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.equalToSuperview().offset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }

        postsSegBtn_Somnia.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        likedSegBtn_Somnia.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        // ─── 帖子列表（高度动态更新，不固定底部）───
        tableView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Somnia.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }

        // ─── 空状态（不再固定 bottom，依靠子视图自然撑开高度）───
        emptyView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Somnia.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
        }

        emptyCircle_Somnia.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }

        emptyEmojiLabel_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyTitleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptyCircle_Somnia.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }

        emptySubLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Somnia.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // ─── 底部撑高占位：contentCard 的 bottom 由此确定 ───
        // 使用 greaterThanOrEqualTo 确保撑到 tableView 或 emptyView 以下
        contentBottomPin_Somnia.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
            make.top.greaterThanOrEqualTo(tableView_Somnia.snp.bottom).offset(20)
            make.top.greaterThanOrEqualTo(emptyView_Somnia.snp.bottom).offset(20)
        }
    }

    // MARK: - 渐变层更新

    private func updateGradients_Somnia() {
        // 封面渐变
        if coverGradient_Somnia == nil {
            let g_somnia = CAGradientLayer()
            g_somnia.colors = [
                UIColor(hexstring_Somnia: "#C4B5FD").cgColor,
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            g_somnia.locations = [0.0, 0.45, 1.0]
            g_somnia.startPoint = CGPoint(x: 0.1, y: 0)
            g_somnia.endPoint   = CGPoint(x: 0.9, y: 1)
            coverView_Somnia.layer.insertSublayer(g_somnia, at: 0)
            coverGradient_Somnia = g_somnia
        }
        coverGradient_Somnia?.frame = coverView_Somnia.bounds

        // 头像外圈渐变
        if avatarRingGradient_Somnia == nil {
            let g_somnia = CAGradientLayer()
            g_somnia.colors = [
                ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            g_somnia.startPoint   = CGPoint(x: 0, y: 0)
            g_somnia.endPoint     = CGPoint(x: 1, y: 1)
            g_somnia.cornerRadius = avatarOuterRing_Somnia.layer.cornerRadius
            avatarOuterRing_Somnia.layer.insertSublayer(g_somnia, at: 0)
            avatarRingGradient_Somnia = g_somnia
        }
        avatarRingGradient_Somnia?.frame = avatarOuterRing_Somnia.bounds

        // 游客头像渐变
        if guestAvatarGradient_Somnia == nil {
            let g_somnia = CAGradientLayer()
            g_somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.7).cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.withAlphaComponent(0.7).cgColor
            ]
            g_somnia.startPoint   = CGPoint(x: 0, y: 0)
            g_somnia.endPoint     = CGPoint(x: 1, y: 1)
            g_somnia.cornerRadius = guestAvatarBg_Somnia.layer.cornerRadius
            guestAvatarBg_Somnia.layer.insertSublayer(g_somnia, at: 0)
            guestAvatarGradient_Somnia = g_somnia
        }
        guestAvatarGradient_Somnia?.frame = guestAvatarBg_Somnia.bounds

        // 分段指示器渐变
        if segmentIndicatorGradient_Somnia == nil {
            let g_somnia = CAGradientLayer()
            g_somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            g_somnia.startPoint   = CGPoint(x: 0, y: 0)
            g_somnia.endPoint     = CGPoint(x: 1, y: 0)
            g_somnia.cornerRadius = 12
            segmentIndicator_Somnia.layer.insertSublayer(g_somnia, at: 0)
            segmentIndicatorGradient_Somnia = g_somnia
        }
        segmentIndicatorGradient_Somnia?.frame = segmentIndicator_Somnia.bounds

        // 空状态圆圈渐变
        if emptyCircleGradient_Somnia == nil, !emptyCircle_Somnia.bounds.isEmpty {
            let g_somnia = CAGradientLayer()
            g_somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.15).cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.withAlphaComponent(0.1).cgColor
            ]
            g_somnia.startPoint   = CGPoint(x: 0, y: 0)
            g_somnia.endPoint     = CGPoint(x: 1, y: 1)
            g_somnia.cornerRadius = 44
            emptyCircle_Somnia.layer.insertSublayer(g_somnia, at: 0)
            emptyCircleGradient_Somnia = g_somnia
        }
        emptyCircleGradient_Somnia?.frame = emptyCircle_Somnia.bounds
    }

    // MARK: - 粒子装饰

    private func setupParticles_Somnia() {
        // (xFactor, yFactor, size, delay) — x/y 为相对于 coverView 宽高的比例因子
        let configs_somnia: [(CGFloat, CGFloat, CGFloat, TimeInterval)] = [
            (0.82, 0.14, 28, 0.0),
            (0.12, 0.22, 18, 0.6),
            (0.90, 0.50, 10, 1.1),
            (0.28, 0.65, 20, 0.3),
            (0.60, 0.44, 8,  0.9),
            (0.48, 0.80, 14, 0.5),
            (0.70, 0.72, 6,  1.4),
        ]

        for (xF_somnia, yF_somnia, size_somnia, delay_somnia) in configs_somnia {
            let p_somnia = UIView()
            p_somnia.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            p_somnia.layer.cornerRadius = size_somnia / 2
            coverView_Somnia.addSubview(p_somnia)

            p_somnia.snp.makeConstraints { make in
                make.width.height.equalTo(size_somnia)
                make.centerX.equalToSuperview().multipliedBy(xF_somnia * 2)
                make.centerY.equalToSuperview().multipliedBy(yF_somnia * 2)
            }

            particles_Somnia.append(p_somnia)
            floatAnimate_Somnia(view_somnia: p_somnia, delay_somnia: delay_somnia)
        }
    }

    /// 单粒子无限浮动动画
    private func floatAnimate_Somnia(view_somnia: UIView, delay_somnia: TimeInterval) {
        UIView.animate(
            withDuration: 2.6,
            delay: delay_somnia,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                view_somnia.transform = CGAffineTransform(translationX: 0, y: -14)
                    .concatenating(CGAffineTransform(scaleX: 1.25, y: 1.25))
            },
            completion: nil
        )
    }

    // MARK: - 按钮事件

    private func setupActions_Somnia() {
        editButton_Somnia.addAction(UIAction { _ in
            Navigation_Somnia.toEditInfo_Somnia(style_somnia: .push_somnia)
        }, for: .touchUpInside)

        settingButton_Somnia.addAction(UIAction { _ in
            Navigation_Somnia.toSetting_Somnia(style_somnia: .push_somnia)
        }, for: .touchUpInside)

        // 点击 VIP 按钮跳转到 VIP 订阅页面
        vipButton_Somnia.addAction(UIAction { _ in
            Navigation_Somnia.toVIPSubscription_Somnia(style_somnia: .push_somnia)
        }, for: .touchUpInside)

        postsSegBtn_Somnia.addAction(UIAction { [weak self] _ in
            self?.switchSegment_Somnia(index_somnia: 0)
        }, for: .touchUpInside)

        likedSegBtn_Somnia.addAction(UIAction { [weak self] _ in
            self?.switchSegment_Somnia(index_somnia: 1)
        }, for: .touchUpInside)
    }

    /// 切换分段，带弹性滑块动画
    /// - Parameter index_somnia: 目标分段索引（0 = Posts，1 = Liked）
    private func switchSegment_Somnia(index_somnia: Int) {
        guard index_somnia != selectedSegment_Somnia else { return }
        selectedSegment_Somnia = index_somnia

        let toLeft_somnia      = index_somnia == 0
        let halfWidth_somnia   = segmentContainer_Somnia.bounds.width / 2

        UIView.animate(
            withDuration: AnimationConfig_Somnia.durationNormal_Somnia,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Somnia.springDampingNormal_Somnia,
            initialSpringVelocity: AnimationConfig_Somnia.springVelocity_Somnia,
            options: [.curveEaseOut]
        ) { [weak self] in
            guard let self = self else { return }
            self.segmentIndicator_Somnia.transform = toLeft_somnia
                ? .identity
                : CGAffineTransform(translationX: halfWidth_somnia, y: 0)
            self.postsSegBtn_Somnia.setTitleColor(
                toLeft_somnia ? .white : ColorConfig_Somnia.textSecondary_Somnia, for: .normal)
            self.likedSegBtn_Somnia.setTitleColor(
                toLeft_somnia ? ColorConfig_Somnia.textSecondary_Somnia : .white, for: .normal)
        }

        refreshPostList_Somnia()
    }
}

// MARK: - 静态工厂

private extension Me_Somnia {

    /// 创建分段按钮（图标 + 文字）
    /// - Parameters:
    ///   - title_Somnia: 按钮文字
    ///   - icon_Somnia: SF Symbol 图标名称
    static func makeSegBtn_Somnia(title_Somnia: String, icon_Somnia: String) -> UIButton {
        var config_somnia = UIButton.Configuration.plain()
        config_somnia.title            = title_Somnia
        config_somnia.image            = UIImage(systemName: icon_Somnia)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
        config_somnia.imagePlacement   = .leading
        config_somnia.imagePadding     = 5
        config_somnia.baseForegroundColor = ColorConfig_Somnia.textSecondary_Somnia
        config_somnia.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var a = attr
            a.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            return a
        }
        let btn_somnia = UIButton(configuration: config_somnia)
        return btn_somnia
    }
}

// MARK: - UITableViewDataSource / Delegate

extension Me_Somnia: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPosts_Somnia().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell_Somnia = tableView.dequeueReusableCell(
            withIdentifier: "MePostCell_Somnia", for: indexPath) as! MePostCell_Somnia
        let posts_Somnia = currentPosts_Somnia()
        guard indexPath.row < posts_Somnia.count else { return cell_Somnia }
        cell_Somnia.configure_Somnia(post_Somnia: posts_Somnia[indexPath.row], from: self) { [weak self] in
            self?.refreshUI_Somnia()
        }
        return cell_Somnia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 120 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let posts_Somnia = currentPosts_Somnia()
        guard indexPath.row < posts_Somnia.count else { return }
        Navigation_Somnia.toTitleDetail_Somnia(titleModel_somnia: posts_Somnia[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: 24)
        cell.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Somnia.durationSpring_Somnia,
            delay: Double(indexPath.row) * AnimationConfig_Somnia.delayShort_Somnia,
            usingSpringWithDamping: AnimationConfig_Somnia.springDampingNormal_Somnia,
            initialSpringVelocity: AnimationConfig_Somnia.springVelocity_Somnia,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            cell.transform = .identity
            cell.alpha = 1
        }
    }
}

// MARK: - 统计卡片组件

/// 个人主页独立统计卡片：数字 + 标题 + 小图标，白色卡片背景
class MeStatCard_Somnia: UIView {

    private let iconView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        return iv
    }()

    private let countLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.7
        return lbl
    }()

    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.textAlignment = .center
        return lbl
    }()

    /// 初始化统计卡片
    /// - Parameters:
    ///   - title_Somnia: 底部标题文字
    ///   - icon_Somnia: SF Symbol 图标名
    init(title_Somnia: String, icon_Somnia: String) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.06

        let cfg_somnia = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iconView_Somnia.image = UIImage(systemName: icon_Somnia, withConfiguration: cfg_somnia)
        titleLabel_Somnia.text = title_Somnia

        setupLayout_Somnia()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout_Somnia() {
        addSubview(iconView_Somnia)
        addSubview(countLabel_Somnia)
        addSubview(titleLabel_Somnia)

        iconView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(16)
        }
        countLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(iconView_Somnia.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(4)
        }
        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(countLabel_Somnia.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(4)
        }
    }

    /// 更新统计数字（>=1000 自动转为 k 格式）
    func update_Somnia(count_Somnia: Int) {
        countLabel_Somnia.text = count_Somnia >= 1000
            ? String(format: "%.1fk", Double(count_Somnia) / 1000.0)
            : "\(count_Somnia)"
    }
}

// MARK: - MeStatItem_Somnia（兼容其他页面，保留）

/// 统计项组件（供 UserInfo 等页面复用）
class MeStatItem_Somnia: UIView {

    private let countLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.78)
        lbl.textAlignment = .center
        return lbl
    }()

    init(title_Somnia: String, icon_Somnia: String) {
        super.init(frame: .zero)
        titleLabel_Somnia.text = title_Somnia
        addSubview(countLabel_Somnia)
        addSubview(titleLabel_Somnia)
        countLabel_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview()
        }
        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(countLabel_Somnia.snp.bottom).offset(3)
            make.left.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func update_Somnia(count_Somnia: Int) {
        countLabel_Somnia.text = count_Somnia >= 1000
            ? String(format: "%.1fk", Double(count_Somnia) / 1000.0)
            : "\(count_Somnia)"
    }
}

// MARK: - 帖子列表单元格

/// 我的页面帖子列表单元格
/// 功能：展示帖子缩略图、标题、内容摘要、点赞数，右上角挂载举报/删除按钮
class MePostCell_Somnia: UITableViewCell {

    private let cardView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.06
        return v
    }()

    private let mediaView_Somnia = MediaDisplayView_Somnia()

    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        lbl.numberOfLines = 2
        return lbl
    }()

    private let contentLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.numberOfLines = 1
        return lbl
    }()

    private let likeStack_Somnia: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
    }()

    private let likeIconView_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        iv.image = UIImage(systemName: "heart", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Somnia.textSecondary_Somnia
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likesCountLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        return lbl
    }()

    private var actionButton_Somnia: UIButton?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        actionButton_Somnia?.removeFromSuperview()
        actionButton_Somnia = nil
    }

    private func setupUI_Somnia() {
        contentView.addSubview(cardView_Somnia)
        cardView_Somnia.addSubview(mediaView_Somnia)
        cardView_Somnia.addSubview(titleLabel_Somnia)
        cardView_Somnia.addSubview(contentLabel_Somnia)
        cardView_Somnia.addSubview(likeStack_Somnia)
        likeStack_Somnia.addArrangedSubview(likeIconView_Somnia)
        likeStack_Somnia.addArrangedSubview(likesCountLabel_Somnia)

        cardView_Somnia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.left.right.equalToSuperview().inset(20)
        }
        mediaView_Somnia.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(80)
        }
        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(mediaView_Somnia.snp.right).offset(12)
            make.right.equalToSuperview().offset(-44)
        }
        contentLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(5)
            make.left.equalTo(mediaView_Somnia.snp.right).offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        likeStack_Somnia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalTo(mediaView_Somnia.snp.right).offset(12)
        }
        likeIconView_Somnia.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
    }

    /// 配置帖子单元格
    /// - Parameters:
    ///   - post_Somnia: 帖子数据模型
    ///   - from: 所在视图控制器（弹出操作菜单用）
    ///   - completion_Somnia: 操作完成后的回调
    func configure_Somnia(
        post_Somnia: TitleModel_Somnia,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        mediaView_Somnia.configure_Somnia(mediaPath_Somnia: post_Somnia.titleMeidas_Somnia.first)
        titleLabel_Somnia.text       = post_Somnia.title_Somnia
        contentLabel_Somnia.text     = post_Somnia.titleContent_Somnia
        likesCountLabel_Somnia.text  = "\(post_Somnia.likes_Somnia)"

        let btn_Somnia = ReportDeleteHelper_Somnia.createPostReportButton_Somnia(
            post_Somnia: post_Somnia,
            size_Somnia: 18,
            color_Somnia: ColorConfig_Somnia.textSecondary_Somnia,
            from: viewController_Somnia,
            completion_Somnia: completion_Somnia
        )
        cardView_Somnia.addSubview(btn_Somnia)
        btn_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
        actionButton_Somnia = btn_Somnia
    }
}
