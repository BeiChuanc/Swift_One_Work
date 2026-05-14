import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页
// 设计思路：
//   顶部采用与全局统一的深紫-靛蓝渐变 Header（圆弧底部），延伸至状态栏背后；
//   Header 内：大头像（白色环边框）、用户名、简介、三栏统计（Posts / Following / Followers）、
//   关注+消息操作按钮行；返回/举报按钮浮于 Header 上方；
//   帖子列表区采用与 Me 页一致的 accent 着色卡片设计（左侧彩色竖条）。
// 关键属性：
//   userModel_Echd  — 目标用户数据（由外部传入）
//   isFromChat_Echd — 是否来自聊天页（影响消息按钮可见性）

/// 用户中心页视图控制器
class UserInfo_Echd: UIViewController {

    // MARK: - 属性

    /// 目标用户数据模型
    var userModel_Echd: PrewUserModel_Echd?

    /// 是否来自聊天页（来自聊天时隐藏消息按钮）
    var isFromChat_Echd: Bool = false

    // MARK: - UI组件 / 悬浮导航

    /// 返回按钮（浮于 Header 上方，不随滚动）
    private let backButton_Echd = BackButton_Echd()

    /// 举报按钮（浮于 Header 右上角）
    private let reportButton_Echd: UIButton = {
        let btn_Echd = ReportDeleteHelper_Echd.createUserReportButton_Echd(
            size_Echd: 36,
            backgroundColor_Echd: UIColor.white.withAlphaComponent(0.18),
            tintColor_Echd: .white
        )
        btn_Echd.layer.cornerRadius = 18
        return btn_Echd
    }()

    // MARK: - UI组件 / Header

    /// 顶部渐变 Header 容器
    private let headerView_Echd = UIView()

    /// Header 渐变图层
    private var headerGradient_Echd: CAGradientLayer?

    /// 头像外环（白色描边）
    private let avatarRingView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 46
        view_Echd.layer.borderWidth = 3
        view_Echd.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        return view_Echd
    }()

    /// 用户头像
    private let avatarView_Echd = UserAvatarView_Echd()

    /// 在线状态绿点
    private let onlineDot_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#10B981")
        view_Echd.layer.cornerRadius = 7
        view_Echd.layer.borderWidth = 2
        view_Echd.layer.borderColor = UIColor.white.cgColor
        return view_Echd
    }()

    /// 用户名
    private let userNameLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 用户简介
    private let userBioLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.78)
        label_Echd.textAlignment = .center
        label_Echd.numberOfLines = 2
        return label_Echd
    }()

    // MARK: - UI组件 / 统计行（3栏）

    /// 统计行容器
    private let statsRow_Echd = UIView()

    /// Posts 数字
    private let postsCountLabel_Echd: UILabel = makeStat_Label()

    /// Posts 标题
    private let postsStatTitle_Echd: UILabel = makeStatTitle_Label(text: "Posts")

    /// 第一条分隔线
    private let statDiv1_Echd = makeStatDivider()

    /// Following 数字
    private let followCountLabel_Echd: UILabel = makeStat_Label()

    /// Following 标题
    private let followStatTitle_Echd: UILabel = makeStatTitle_Label(text: "Following")

    /// 第二条分隔线
    private let statDiv2_Echd = makeStatDivider()

    /// Followers 数字
    private let fansCountLabel_Echd: UILabel = makeStat_Label()

    /// Followers 标题
    private let fansStatTitle_Echd: UILabel = makeStatTitle_Label(text: "Followers")

    // MARK: - UI组件 / 操作按钮

    /// 关注按钮
    private let followButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_Echd.layer.cornerRadius = 20
        btn_Echd.layer.borderWidth = 1.5
        return btn_Echd
    }()

    /// 消息按钮
    private let messageButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn_Echd.setImage(UIImage(systemName: "bubble.left.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.setTitle("  Message", for: .normal)
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.tintColor = .white
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_Echd.layer.cornerRadius = 20
        btn_Echd.layer.borderWidth = 1.5
        btn_Echd.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
        return btn_Echd
    }()

    // MARK: - UI组件 / 帖子列表

    /// 主滚动视图（仅展示帖子部分）
    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        return sv_Echd
    }()

    /// 滚动内容容器
    private let contentView_Echd = UIView()

    /// Posts 区 Section 标题行
    private let postsSectionRow_Echd = UIView()

    /// Posts 标签
    private let postsSectionLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Posts"
        label_Echd.font = UIFont.systemFont(ofSize: 17, weight: .black)
        label_Echd.textColor = UIColor(hexstring_Echd: "#111827")
        return label_Echd
    }()

    /// Posts 数量气泡
    private let postsCountBadge_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        label_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
        label_Echd.layer.cornerRadius = 10
        label_Echd.clipsToBounds = true
        return label_Echd
    }()

    /// 帖子卡片容器
    private let postsStackView_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 16
        return sv_Echd
    }()

    /// 空状态容器
    private let emptyView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.isHidden = true
        return view_Echd
    }()

    // MARK: - 私有常量

    /// 卡片 accent 颜色循环
    private let accentColors_Echd: [UIColor] = [
        UIColor(hexstring_Echd: "#7C3AED"),
        UIColor(hexstring_Echd: "#EC4899"),
        UIColor(hexstring_Echd: "#10B981"),
        UIColor(hexstring_Echd: "#F59E0B"),
        UIColor(hexstring_Echd: "#6366F1"),
        UIColor(hexstring_Echd: "#F43F5E")
    ]

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshUI_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        setupEmptyView_Echd()
        observeNotifications_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerView_Echd.bounds
        applyHeaderArc_Echd()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 工厂方法（静态，避免在懒属性中用 self）

    private static func makeStat_Label() -> UILabel {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 20, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }

    private static func makeStatTitle_Label(text: String) -> UILabel {
        let label_Echd = UILabel()
        label_Echd.text = text
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.7)
        label_Echd.textAlignment = .center
        return label_Echd
    }

    private static func makeStatDivider() -> UIView {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view_Echd
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // Header
        headerView_Echd.clipsToBounds = true
        view.addSubview(headerView_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        headerView_Echd.layer.insertSublayer(grad_Echd, at: 0)
        headerGradient_Echd = grad_Echd

        // 头像
        headerView_Echd.addSubview(avatarRingView_Echd)
        avatarRingView_Echd.addSubview(avatarView_Echd)
        headerView_Echd.addSubview(onlineDot_Echd)
        headerView_Echd.addSubview(userNameLabel_Echd)
        headerView_Echd.addSubview(userBioLabel_Echd)

        // 统计行
        headerView_Echd.addSubview(statsRow_Echd)
        statsRow_Echd.addSubview(postsCountLabel_Echd)
        statsRow_Echd.addSubview(postsStatTitle_Echd)
        statsRow_Echd.addSubview(statDiv1_Echd)
        statsRow_Echd.addSubview(followCountLabel_Echd)
        statsRow_Echd.addSubview(followStatTitle_Echd)
        statsRow_Echd.addSubview(statDiv2_Echd)
        statsRow_Echd.addSubview(fansCountLabel_Echd)
        statsRow_Echd.addSubview(fansStatTitle_Echd)

        // 操作按钮
        headerView_Echd.addSubview(followButton_Echd)
        followButton_Echd.addTarget(self, action: #selector(followTapped_Echd), for: .touchUpInside)

        if !isFromChat_Echd {
            headerView_Echd.addSubview(messageButton_Echd)
            messageButton_Echd.addTarget(self, action: #selector(messageTapped_Echd), for: .touchUpInside)
        }

        // 浮层导航按钮
        view.addSubview(backButton_Echd)
        view.addSubview(reportButton_Echd)
        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }
        reportButton_Echd.addAction(UIAction { [weak self] _ in
            guard let self = self, let user_Echd = self.userModel_Echd else { return }
            ReportDeleteHelper_Echd.block_Echd(user_Echd: user_Echd, from: self) {
                Navigation_Echd.popToRoot_Echd()
            }
        }, for: .touchUpInside)

        // 帖子滚动区
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)

        contentView_Echd.addSubview(postsSectionRow_Echd)
        postsSectionRow_Echd.addSubview(postsSectionLabel_Echd)
        postsSectionRow_Echd.addSubview(postsCountBadge_Echd)
        contentView_Echd.addSubview(postsStackView_Echd)
        contentView_Echd.addSubview(emptyView_Echd)
    }

    /// Header 底部圆弧遮罩
    private func applyHeaderArc_Echd() {
        let w_Echd = headerView_Echd.bounds.width
        let h_Echd = headerView_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 20))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 20),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 20)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer()
        mask_Echd.path = path_Echd.cgPath
        headerView_Echd.layer.mask = mask_Echd
    }

    /// 配置空状态视图
    private func setupEmptyView_Echd() {
        let circleBg_Echd = UIView()
        circleBg_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.07)
        circleBg_Echd.layer.cornerRadius = 52
        emptyView_Echd.addSubview(circleBg_Echd)

        let icon_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 34, weight: .thin)
        icon_Echd.image = UIImage(systemName: "sparkles", withConfiguration: cfg_Echd)
        icon_Echd.tintColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.4)
        icon_Echd.contentMode = .scaleAspectFit
        emptyView_Echd.addSubview(icon_Echd)

        let lbl_Echd = UILabel()
        lbl_Echd.text = "No posts yet."
        lbl_Echd.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        lbl_Echd.textAlignment = .center
        emptyView_Echd.addSubview(lbl_Echd)

        circleBg_Echd.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }
        icon_Echd.snp.makeConstraints { make in
            make.center.equalTo(circleBg_Echd)
            make.width.height.equalTo(44)
        }
        lbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(circleBg_Echd.snp.bottom).offset(16)
            make.centerX.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width
        let colW_Echd = (sw_Echd - 64) / 3  // 三栏等宽

        // Header 延伸至状态栏背后
        headerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(360)
        }

        // 浮层导航
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        reportButton_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Echd)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }

        // 头像
        avatarRingView_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }
        avatarView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        onlineDot_Echd.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRingView_Echd.snp.trailing).offset(2)
            make.bottom.equalTo(avatarRingView_Echd.snp.bottom).offset(2)
            make.width.height.equalTo(14)
        }

        // 名字、简介
        userNameLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Echd.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        userBioLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Echd.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        // 统计行（3 列等宽）
        statsRow_Echd.snp.makeConstraints { make in
            make.top.equalTo(userBioLabel_Echd.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        // Posts 列（左）
        postsCountLabel_Echd.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(colW_Echd)
        }
        postsStatTitle_Echd.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Echd.snp.bottom).offset(2)
            make.centerX.equalTo(postsCountLabel_Echd)
        }
        // 分隔线1
        statDiv1_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(colW_Echd)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        // Following 列（中）
        followCountLabel_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(colW_Echd)
        }
        followStatTitle_Echd.snp.makeConstraints { make in
            make.top.equalTo(followCountLabel_Echd.snp.bottom).offset(2)
            make.centerX.equalTo(followCountLabel_Echd)
        }
        // 分隔线2
        statDiv2_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-colW_Echd)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        // Followers 列（右）
        fansCountLabel_Echd.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalTo(colW_Echd)
        }
        fansStatTitle_Echd.snp.makeConstraints { make in
            make.top.equalTo(fansCountLabel_Echd.snp.bottom).offset(2)
            make.centerX.equalTo(fansCountLabel_Echd)
        }

        // 操作按钮
        if !isFromChat_Echd {
            followButton_Echd.snp.makeConstraints { make in
                make.top.equalTo(statsRow_Echd.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(20)
                make.height.equalTo(44)
                make.trailing.equalTo(headerView_Echd.snp.centerX).offset(-6)
                make.bottom.equalToSuperview().offset(-28)
            }
            messageButton_Echd.snp.makeConstraints { make in
                make.top.equalTo(statsRow_Echd.snp.bottom).offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(44)
                make.leading.equalTo(headerView_Echd.snp.centerX).offset(6)
            }
        } else {
            followButton_Echd.snp.makeConstraints { make in
                make.top.equalTo(statsRow_Echd.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.height.equalTo(44)
                make.width.equalTo(200)
                make.bottom.equalToSuperview().offset(-28)
            }
        }

        // 帖子滚动区
        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerView_Echd.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }
        postsSectionRow_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(28)
        }
        postsSectionLabel_Echd.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        postsCountBadge_Echd.snp.makeConstraints { make in
            make.leading.equalTo(postsSectionLabel_Echd.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(20)
        }
        postsStackView_Echd.snp.makeConstraints { make in
            make.top.equalTo(postsSectionRow_Echd.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-30)
        }
        emptyView_Echd.snp.makeConstraints { make in
            make.top.equalTo(postsSectionRow_Echd.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    // MARK: - 数据刷新

    /// 刷新整体 UI
    private func refreshUI_Echd() {
        guard let user_Echd = userModel_Echd else { return }

        avatarView_Echd.configure_Echd(userId_Echd: user_Echd.userId_Echd ?? 0)
        userNameLabel_Echd.text = user_Echd.userName_Echd ?? "Unknown"
        userBioLabel_Echd.text = user_Echd.userIntroduce_Echd?.isEmpty == false
            ? user_Echd.userIntroduce_Echd
            : "No bio yet ✦"

        // 统计数据
        let userPosts_Echd = TitleViewModel_Echd.shared_Echd.getUserPosts_Echd(user_echd: user_Echd)
        postsCountLabel_Echd.text = "\(userPosts_Echd.count)"
        followCountLabel_Echd.text = "\(user_Echd.userFollow_Echd ?? 0)"
        fansCountLabel_Echd.text = "\(user_Echd.userFans_Echd ?? 0)"

        // 帖子数量气泡
        let pCount_Echd = userPosts_Echd.count
        postsCountBadge_Echd.text = "  \(pCount_Echd)  "
        postsCountBadge_Echd.isHidden = pCount_Echd == 0

        updateFollowButton_Echd()
        refreshUserPosts_Echd()
    }

    /// 更新关注按钮样式
    private func updateFollowButton_Echd() {
        guard let user_Echd = userModel_Echd else { return }
        let isFollowing_Echd = UserViewModel_Echd.shared_Echd.isFollowing_Echd(user_echd: user_Echd)

        UIView.animate(withDuration: 0.2) {
            if isFollowing_Echd {
                // 已关注：半透明白色
                self.followButton_Echd.setTitle("Following ✓", for: .normal)
                self.followButton_Echd.setTitleColor(UIColor.white.withAlphaComponent(0.9), for: .normal)
                self.followButton_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.18)
                self.followButton_Echd.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            } else {
                // 未关注：实白色 + 紫色文字
                self.followButton_Echd.setTitle("+ Follow", for: .normal)
                self.followButton_Echd.setTitleColor(UIColor(hexstring_Echd: "#7C3AED"), for: .normal)
                self.followButton_Echd.backgroundColor = .white
                self.followButton_Echd.layer.borderColor = UIColor.white.cgColor
            }
        }
    }

    /// 刷新该用户帖子列表
    private func refreshUserPosts_Echd() {
        postsStackView_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let user_Echd = userModel_Echd else { return }

        let posts_Echd = TitleViewModel_Echd.shared_Echd.getUserPosts_Echd(user_echd: user_Echd)

        if posts_Echd.isEmpty {
            emptyView_Echd.isHidden = false
            postsStackView_Echd.isHidden = true
        } else {
            emptyView_Echd.isHidden = true
            postsStackView_Echd.isHidden = false
            for (idx_Echd, post_Echd) in posts_Echd.enumerated() {
                let accent_Echd = accentColors_Echd[idx_Echd % accentColors_Echd.count]
                postsStackView_Echd.addArrangedSubview(buildPostCard_Echd(post: post_Echd, accent: accent_Echd))
            }
        }
    }

    /// 构建帖子卡片（与 Me 页风格统一）
    /// - Parameters:
    ///   - post: 帖子数据
    ///   - accent: 卡片主调色（阴影色 + 左侧竖条色）
    private func buildPostCard_Echd(post: TitleModel_Echd, accent: UIColor) -> UIView {
        let cardView_Echd = UIView()
        cardView_Echd.backgroundColor = .white
        cardView_Echd.layer.cornerRadius = 18
        cardView_Echd.layer.shadowColor = accent.withAlphaComponent(0.2).cgColor
        cardView_Echd.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView_Echd.layer.shadowRadius = 14
        cardView_Echd.layer.shadowOpacity = 1
        cardView_Echd.clipsToBounds = false

        // 内部圆角裁剪容器（保证媒体圆角）
        let inner_Echd = UIView()
        inner_Echd.backgroundColor = .white
        inner_Echd.layer.cornerRadius = 18
        inner_Echd.clipsToBounds = true
        cardView_Echd.addSubview(inner_Echd)

        // 媒体视图
        let mediaView_Echd = MediaDisplayView_Echd()
        inner_Echd.addSubview(mediaView_Echd)
        mediaView_Echd.configure_Echd(mediaPath_Echd: post.titleMeidas_Echd.first)

        // 媒体底部渐变蒙版
        let grad_Echd = UserInfoGradOverlay_Echd()
        inner_Echd.addSubview(grad_Echd)

        // 举报/删除按钮（添加至 cardView 避免被裁切）
        let reportBtn_Echd = ReportDeleteHelper_Echd.createPostReportButton_Echd(
            post_Echd: post,
            size_Echd: 12,
            color_Echd: .white,
            from: self,
            completion_Echd: { [weak self] in self?.refreshUserPosts_Echd() }
        )
        reportBtn_Echd.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        reportBtn_Echd.layer.cornerRadius = 13
        cardView_Echd.addSubview(reportBtn_Echd)

        // 信息区
        let infoView_Echd = UIView()
        infoView_Echd.backgroundColor = .white
        inner_Echd.addSubview(infoView_Echd)

        // 左侧 accent 竖条
        let bar_Echd = UIView()
        bar_Echd.backgroundColor = accent
        bar_Echd.layer.cornerRadius = 2
        infoView_Echd.addSubview(bar_Echd)

        // 帖子标题
        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = post.title_Echd
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLbl_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        titleLbl_Echd.numberOfLines = 1
        infoView_Echd.addSubview(titleLbl_Echd)

        // 帖子内容预览
        let contentLbl_Echd = UILabel()
        contentLbl_Echd.text = post.titleContent_Echd
        contentLbl_Echd.font = UIFont.systemFont(ofSize: 12)
        contentLbl_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        contentLbl_Echd.numberOfLines = 2
        infoView_Echd.addSubview(contentLbl_Echd)

        // 点赞数行
        let likeRow_Echd = UIView()
        infoView_Echd.addSubview(likeRow_Echd)
        let heartIV_Echd = UIImageView()
        let hCfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        heartIV_Echd.image = UIImage(systemName: "flame.fill", withConfiguration: hCfg_Echd)
        heartIV_Echd.tintColor = UIColor(hexstring_Echd: "#F43F5E")
        likeRow_Echd.addSubview(heartIV_Echd)
        let likeCnt_Echd = UILabel()
        likeCnt_Echd.text = "\(post.likes_Echd)"
        likeCnt_Echd.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        likeCnt_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        likeRow_Echd.addSubview(likeCnt_Echd)

        // 约束
        inner_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        grad_Echd.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(mediaView_Echd)
            make.height.equalTo(60)
        }
        reportBtn_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        infoView_Echd.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Echd.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        bar_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(4)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
        }
        contentLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(4)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
        }
        likeRow_Echd.snp.makeConstraints { make in
            make.top.equalTo(contentLbl_Echd.snp.bottom).offset(8)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(16)
        }
        heartIV_Echd.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        likeCnt_Echd.snp.makeConstraints { make in
            make.leading.equalTo(heartIV_Echd.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        // 点击进入详情
        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(postCardTapped_Echd(_:)))
        cardView_Echd.addGestureRecognizer(tap_Echd)
        cardView_Echd.tag = post.titleId_Echd
        return cardView_Echd
    }

    // MARK: - 事件处理

    /// 关注按钮点击
    @objc private func followTapped_Echd() {
        guard let user_Echd = userModel_Echd else { return }
        followButton_Echd.animatePulse_Echd()
        let wasFollowing_Echd = UserViewModel_Echd.shared_Echd.isFollowing_Echd(user_echd: user_Echd)
        Task { @MainActor in
            UserViewModel_Echd.shared_Echd.followUser_Echd(user_echd: user_Echd)
        }
        if isFromChat_Echd && wasFollowing_Echd {
            if let uid_Echd = user_Echd.userId_Echd {
                Task { @MainActor in
                    MessageViewModel_Echd.shared_Echd.deleteUserMessages_Echd(userId_echd: uid_Echd)
                }
            }
            Navigation_Echd.toMessageList_Echd(style_echd: .replace_echd)
        }
    }

    /// 消息按钮点击（带弹窗确认）
    @objc private func messageTapped_Echd() {
        guard let user_Echd = userModel_Echd else { return }
        let isFollowing_Echd = UserViewModel_Echd.shared_Echd.isFollowing_Echd(user_echd: user_Echd)
        if !isFollowing_Echd {
            Utils_Echd.showInfo_Echd(message_Echd: "Follow this user to start chatting 💬")
            return
        }
        let alert_Echd = UIAlertController(
            title: "Start Chat?",
            message: "Chat with \(user_Echd.userName_Echd ?? "this user"). Say hi!",
            preferredStyle: .actionSheet
        )
        alert_Echd.addAction(UIAlertAction(title: "Start Chat 🔥", style: .default) { _ in
            Navigation_Echd.toMessageUser_Echd(with: user_Echd, style_echd: .push_echd)
        })
        alert_Echd.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Echd, animated: true)
    }

    /// 帖子卡片点击
    @objc private func postCardTapped_Echd(_ gesture: UITapGestureRecognizer) {
        guard let card_Echd = gesture.view else { return }
        let posts_Echd = TitleViewModel_Echd.shared_Echd.getPosts_Echd()
        if let post_Echd = posts_Echd.first(where: { $0.titleId_Echd == card_Echd.tag }) {
            card_Echd.animatePressDown_Echd { card_Echd.animatePressUp_Echd() }
            Navigation_Echd.toTitleDetail_Echd(titleModel_echd: post_Echd, style_echd: .push_echd)
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        [UserViewModel_Echd.userStateDidChangeNotification_Echd,
         TitleViewModel_Echd.titleStateDidChangeNotification_Echd].forEach {
            NotificationCenter.default.addObserver(
                self, selector: #selector(handleStateChange_Echd), name: $0, object: nil
            )
        }
    }

    @objc private func handleStateChange_Echd() {
        updateFollowButton_Echd()
        refreshUserPosts_Echd()
    }
}

// MARK: - 媒体底部渐变蒙版（UserInfo 页专用）

/// UserInfo 帖子卡片媒体区底部渐变蒙版，防止与其他页面私有类名冲突
private class UserInfoGradOverlay_Echd: UIView {
    private let grad_Echd = CAGradientLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        grad_Echd.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.15).cgColor]
        grad_Echd.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Echd.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(grad_Echd, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        grad_Echd.frame = bounds
    }
}
