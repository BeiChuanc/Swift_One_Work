import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心页面
/// 功能：展示他人信息、关注/取消关注、进入聊天（需先关注）、举报用户；展示帖子网格
/// 设计亮点：
///   • 靛蓝→青绿渐变头部（自管理 CAGradientLayer + 装饰圆，区别于其他页面）
///   • 渐变白色外环头像（90pt，层次感）
///   • 磨砂统计行（Posts / Followers / Following 三列）
///   • 关注/消息按钮：白色磨砂卡片样式
///   • 帖子网格：玫瑰调阴影 + 8 色渐变占位
class UserInfo_Vestir: UIViewController {

    // MARK: - 属性

    var userModel_Vestir: PrewUserModel_Vestir?
    var hideMessageButton_Vestir: Bool = false
    var onUnfollowFromChat_Vestir: (() -> Void)?

    // MARK: - 渐变头部（靛蓝→青绿，自管理）

    private let headerShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#3730A3").cgColor
        v_Vestir.layer.shadowOpacity = 0.32
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 10)
        v_Vestir.layer.shadowRadius = 22
        return v_Vestir
    }()

    private let headerCard_Vestir = UserInfoHeaderCard_Vestir()

    /// 装饰圆 1（右上，白色 10% alpha）
    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        v_Vestir.layer.cornerRadius = 56
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 装饰圆 2（左下，青绿 20% alpha）
    private let decoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#6EE7B7", alpha_Vestir: 0.22)
        v_Vestir.layer.cornerRadius = 38
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    // MARK: - 导航元素

    private lazy var backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Vestir),
            for: .normal
        )
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    private var reportUserBtn_Vestir: UIButton?

    // MARK: - 头像（渐变外环）

    private let avatarRing_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 47
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let avatarRingGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(white: 1.0, alpha: 0.92).cgColor,
            UIColor(white: 1.0, alpha: 0.45).cgColor
        ]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    private let avatarView_Vestir: UserAvatarView_Vestir = {
        let av_Vestir = UserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 41
        av_Vestir.clipsToBounds = true
        return av_Vestir
    }()

    // MARK: - 用户信息文字

    private let userNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        lbl_Vestir.textColor = .white
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let bioLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.78)
        lbl_Vestir.textAlignment = .center
        lbl_Vestir.numberOfLines = 2
        return lbl_Vestir
    }()

    // MARK: - 磨砂统计行

    private let statsStrip_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.16)
        v_Vestir.layer.cornerRadius = 14
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let postsCountLabel_Vestir: UILabel = makeStatCountLabel_Vestir()
    private let postsDescLabel_Vestir: UILabel = makeStatDescLabel_Vestir(text: "Posts")
    private let statDiv1_Vestir: UIView = makeStatDivider_Vestir()
    private let followersCountLabel_Vestir: UILabel = makeStatCountLabel_Vestir()
    private let followersDescLabel_Vestir: UILabel = makeStatDescLabel_Vestir(text: "Followers")
    private let statDiv2_Vestir: UIView = makeStatDivider_Vestir()
    private let followingCountLabel_Vestir: UILabel = makeStatCountLabel_Vestir()
    private let followingDescLabel_Vestir: UILabel = makeStatDescLabel_Vestir(text: "Following")

    private static func makeStatCountLabel_Vestir() -> UILabel {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl_Vestir.textColor = .white
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }

    private static func makeStatDescLabel_Vestir(text: String) -> UILabel {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = text
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.70)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }

    private static func makeStatDivider_Vestir() -> UIView {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        return v_Vestir
    }

    // MARK: - 操作按钮（关注 / 消息）

    private let followBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_Vestir.layer.cornerRadius = 18
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private let messageBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn_Vestir.setImage(
            UIImage(systemName: "bubble.right.fill", withConfiguration: cfg_Vestir),
            for: .normal
        )
        btn_Vestir.setTitle("  Message", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.18)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.layer.cornerRadius = 18
        btn_Vestir.layer.borderWidth = 1.5
        btn_Vestir.layer.borderColor = UIColor(white: 1.0, alpha: 0.38).cgColor
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    // MARK: - 滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        // 禁用自动 contentInset 补偿，防止顶部出现间隙
        sv_Vestir.contentInsetAdjustmentBehavior = .never
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    // MARK: - 帖子区块

    private let postsSectionRow_Vestir: UIView = UIView()

    private let postsDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#3730A3")
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    private let postsSectionTitle_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Posts"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    private let postsGrid_Vestir: UIStackView = {
        let sv_Vestir = UIStackView()
        sv_Vestir.axis = .vertical
        sv_Vestir.spacing = 12
        return sv_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        bindNotifications_Vestir()
        loadData_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        updateFollowButtonState_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarRingGradLayer_Vestir.frame = avatarRing_Vestir.bounds
        avatarRingGradLayer_Vestir.cornerRadius = avatarRing_Vestir.layer.cornerRadius
        if headerShadow_Vestir.bounds.width > 0 {
            headerShadow_Vestir.layer.shadowPath = UIBezierPath(
                roundedRect: headerShadow_Vestir.bounds, cornerRadius: 0
            ).cgPath
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerShadow_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + CGFloat(hideMessageButton_Vestir ? 290 : 310))
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        // 头部
        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)

        contentView_Vestir.addSubview(headerShadow_Vestir)
        headerShadow_Vestir.addSubview(headerCard_Vestir)
        headerCard_Vestir.addSubview(decoCircle1_Vestir)
        headerCard_Vestir.addSubview(decoCircle2_Vestir)
        headerCard_Vestir.addSubview(backBtn_Vestir)
        headerCard_Vestir.addSubview(statsStrip_Vestir)
        statsStrip_Vestir.addSubview(postsCountLabel_Vestir)
        statsStrip_Vestir.addSubview(postsDescLabel_Vestir)
        statsStrip_Vestir.addSubview(statDiv1_Vestir)
        statsStrip_Vestir.addSubview(followersCountLabel_Vestir)
        statsStrip_Vestir.addSubview(followersDescLabel_Vestir)
        statsStrip_Vestir.addSubview(statDiv2_Vestir)
        statsStrip_Vestir.addSubview(followingCountLabel_Vestir)
        statsStrip_Vestir.addSubview(followingDescLabel_Vestir)
        headerCard_Vestir.addSubview(followBtn_Vestir)

        // 头像：后加入（z 轴高于 headerCard，确保可见）
        contentView_Vestir.addSubview(avatarRing_Vestir)
        avatarRing_Vestir.layer.insertSublayer(avatarRingGradLayer_Vestir, at: 0)
        avatarRing_Vestir.addSubview(avatarView_Vestir)
        headerCard_Vestir.addSubview(userNameLabel_Vestir)
        headerCard_Vestir.addSubview(bioLabel_Vestir)

        if !hideMessageButton_Vestir {
            headerCard_Vestir.addSubview(messageBtn_Vestir)
        }

        // 举报按钮
        let reportBtn_vestir = ReportDeleteHelper_Vestir.createUserReportButton_Vestir(
            size_Vestir: 32,
            tintColor_Vestir: .white,
            withShadow_Vestir: false
        )
        reportBtn_vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.20)
        reportBtn_vestir.layer.cornerRadius = 16
        reportBtn_vestir.clipsToBounds = true
        reportBtn_vestir.addAction(UIAction { [weak self] _ in
            guard let self = self, let user_vestir = self.userModel_Vestir else { return }
            ReportDeleteHelper_Vestir.block_Vestir(user_Vestir: user_vestir, from: self) {
                Navigation_Vestir.pop_Vestir()
            }
        }, for: UIControl.Event.touchUpInside)
        headerCard_Vestir.addSubview(reportBtn_vestir)
        reportUserBtn_Vestir = reportBtn_vestir

        // 帖子区块
        contentView_Vestir.addSubview(postsSectionRow_Vestir)
        postsSectionRow_Vestir.addSubview(postsDot_Vestir)
        postsSectionRow_Vestir.addSubview(postsSectionTitle_Vestir)
        contentView_Vestir.addSubview(postsGrid_Vestir)

        followBtn_Vestir.addTarget(self, action: #selector(followTapped_Vestir), for: .touchUpInside)
        messageBtn_Vestir.addTarget(self, action: #selector(messageTapped_Vestir), for: .touchUpInside)
    }

    private func setupConstraints_Vestir() {
        scrollView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        let headerH_Vestir: CGFloat = hideMessageButton_Vestir ? 290 : 310

        headerShadow_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + headerH_Vestir)
        }
        headerCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(112)
            make.trailing.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-28)
        }
        decoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(76)
            make.leading.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(20)
        }

        backBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(32)
        }
        reportUserBtn_Vestir?.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(32)
        }

        // 头像：中心位于 headerShadow 高度的约 1/3 处
        avatarRing_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.width.height.equalTo(94)
        }
        avatarView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(82)
        }

        userNameLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Vestir.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bioLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Vestir.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        // 磨砂统计行
        statsStrip_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Vestir.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }

        // 三列统计（使用 centerX multipliedBy 定位）
        statDiv1_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(0.667)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        statDiv2_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(1.334)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        postsCountLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalTo(statDiv1_Vestir.snp.leading).offset(-4)
        }
        postsDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Vestir.snp.bottom).offset(2)
            make.leading.trailing.equalTo(postsCountLabel_Vestir)
        }
        followersCountLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Vestir)
            make.leading.equalTo(statDiv1_Vestir.snp.trailing).offset(4)
            make.trailing.equalTo(statDiv2_Vestir.snp.leading).offset(-4)
        }
        followersDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(followersCountLabel_Vestir.snp.bottom).offset(2)
            make.leading.trailing.equalTo(followersCountLabel_Vestir)
        }
        followingCountLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Vestir)
            make.leading.equalTo(statDiv2_Vestir.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-8)
        }
        followingDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(followingCountLabel_Vestir.snp.bottom).offset(2)
            make.leading.trailing.equalTo(followingCountLabel_Vestir)
        }

        // 操作按钮
        if hideMessageButton_Vestir {
            followBtn_Vestir.snp.makeConstraints { make in
                make.top.equalTo(statsStrip_Vestir.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.width.equalTo(160)
                make.height.equalTo(40)
            }
        } else {
            followBtn_Vestir.snp.makeConstraints { make in
                make.top.equalTo(statsStrip_Vestir.snp.bottom).offset(16)
                make.trailing.equalTo(headerCard_Vestir.snp.centerX).offset(-8)
                make.width.equalTo(130)
                make.height.equalTo(40)
            }
            messageBtn_Vestir.snp.makeConstraints { make in
                make.top.equalTo(statsStrip_Vestir.snp.bottom).offset(16)
                make.leading.equalTo(headerCard_Vestir.snp.centerX).offset(8)
                make.width.equalTo(130)
                make.height.equalTo(40)
            }
        }

        // 帖子区块
        postsSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(headerShadow_Vestir.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(22)
        }
        postsDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        postsSectionTitle_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(postsDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        postsGrid_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsSectionRow_Vestir.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 数据加载

    private func loadData_Vestir() {
        guard let user_vestir = userModel_Vestir else { return }
        avatarView_Vestir.configure_Vestir(userId_Vestir: user_vestir.userId_Vestir ?? 0)
        userNameLabel_Vestir.text = user_vestir.userName_Vestir ?? "User"
        bioLabel_Vestir.text = user_vestir.userIntroduce_Vestir ?? "Fashion lover ✦"

        // 统计数据（从 LocalData 获取关注数）
        let posts_vestir = TitleViewModel_Vestir.shared_Vestir.getUserPosts_Vestir(user_vestir: user_vestir)
        postsCountLabel_Vestir.text = "\(posts_vestir.count)"
        followersCountLabel_Vestir.text = "\(user_vestir.userFans_Vestir ?? 0)"
        followingCountLabel_Vestir.text = "\(user_vestir.userFollow_Vestir ?? 0)"

        updateFollowButtonState_Vestir()
        rebuildPostsGrid_Vestir()
    }

    private func updateFollowButtonState_Vestir() {
        guard let user_vestir = userModel_Vestir else { return }
        let isFollowing_vestir = UserViewModel_Vestir.shared_Vestir.isFollowing_Vestir(user_vestir: user_vestir)
        if isFollowing_vestir {
            followBtn_Vestir.setTitle("Followed", for: .normal)
            followBtn_Vestir.setTitleColor(.white, for: .normal)
            followBtn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
            followBtn_Vestir.layer.borderWidth = 1.5
            followBtn_Vestir.layer.borderColor = UIColor(white: 1.0, alpha: 0.45).cgColor
        } else {
            followBtn_Vestir.setTitle("Follow", for: .normal)
            followBtn_Vestir.setTitleColor(UIColor(hexstring_Vestir: "#3730A3"), for: .normal)
            followBtn_Vestir.backgroundColor = .white
            followBtn_Vestir.layer.borderWidth = 0
        }
    }

    private func rebuildPostsGrid_Vestir() {
        postsGrid_Vestir.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let user_vestir = userModel_Vestir else { return }
        let posts_vestir = TitleViewModel_Vestir.shared_Vestir.getUserPosts_Vestir(user_vestir: user_vestir)

        if posts_vestir.isEmpty {
            let emptyLabel_vestir = UILabel()
            emptyLabel_vestir.text = "No posts yet."
            emptyLabel_vestir.font = UIFont.systemFont(ofSize: 14)
            emptyLabel_vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
            emptyLabel_vestir.textAlignment = .center
            postsGrid_Vestir.addArrangedSubview(emptyLabel_vestir)
            return
        }

        var row_vestir: UIStackView?
        for (idx_vestir, post_vestir) in posts_vestir.enumerated() {
            if idx_vestir % 2 == 0 {
                let rowStack_vestir = UIStackView()
                rowStack_vestir.axis = .horizontal
                rowStack_vestir.spacing = 12
                rowStack_vestir.distribution = .fillEqually
                postsGrid_Vestir.addArrangedSubview(rowStack_vestir)
                row_vestir = rowStack_vestir
            }
            let cell_vestir = buildPostCell_Vestir(post_vestir: post_vestir, index_vestir: idx_vestir)
            cell_vestir.alpha = 0
            row_vestir?.addArrangedSubview(cell_vestir)
            cell_vestir.animateSpringScaleIn_Vestir(delay_Vestir: Double(idx_vestir) * 0.05)
        }
        if posts_vestir.count % 2 == 1 {
            row_vestir?.addArrangedSubview(UIView())
        }
    }

    private func buildPostCell_Vestir(post_vestir: TitleModel_Vestir, index_vestir: Int) -> UIView {
        let cell_vestir = UIView()
        cell_vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        cell_vestir.layer.cornerRadius = 18
        cell_vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#3730A3").cgColor
        cell_vestir.layer.shadowOpacity = 0.12
        cell_vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell_vestir.layer.shadowRadius = 12

        let mediaView_vestir = MediaDisplayView_Vestir()
        mediaView_vestir.layer.cornerRadius = 14
        mediaView_vestir.clipsToBounds = true
        // 8 色渐变占位色板
        mediaView_vestir.customPlaceholderColors_Vestir = DiscoverCell_Vestir.cardGradients_Vestir[
            index_vestir % DiscoverCell_Vestir.cardGradients_Vestir.count
        ]
        mediaView_vestir.configure_Vestir(mediaPath_Vestir: post_vestir.titleMeidas_Vestir.first)

        let titleLabel_vestir = UILabel()
        titleLabel_vestir.text = post_vestir.title_Vestir
        titleLabel_vestir.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel_vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        titleLabel_vestir.numberOfLines = 1

        let likePillLbl_vestir = UILabel()
        likePillLbl_vestir.text = "♥ \(post_vestir.likes_Vestir)"
        likePillLbl_vestir.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        likePillLbl_vestir.textColor = ColorConfig_Vestir.heartColor_Vestir

        let reportBtn_vestir = ReportDeleteHelper_Vestir.createPostReportButton_Vestir(
            post_Vestir: post_vestir,
            size_Vestir: 13,
            color_Vestir: ColorConfig_Vestir.textSecondary_Vestir,
            from: self
        ) { [weak self] in self?.rebuildPostsGrid_Vestir() }

        cell_vestir.addSubview(mediaView_vestir)
        cell_vestir.addSubview(titleLabel_vestir)
        cell_vestir.addSubview(likePillLbl_vestir)
        cell_vestir.addSubview(reportBtn_vestir)

        mediaView_vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(120)
        }
        titleLabel_vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaView_vestir.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-34)
        }
        likePillLbl_vestir.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_vestir.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(9)
            make.bottom.equalToSuperview().offset(-8)
        }
        reportBtn_vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }

        let tap_vestir = UITapGestureRecognizer(target: self, action: #selector(postCellTapped_Vestir(_:)))
        cell_vestir.addGestureRecognizer(tap_vestir)
        cell_vestir.tag = post_vestir.titleId_Vestir
        cell_vestir.isUserInteractionEnabled = true
        return cell_vestir
    }

    // MARK: - 通知绑定

    private func bindNotifications_Vestir() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChanged_Vestir),
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChanged_Vestir),
            name: TitleViewModel_Vestir.titleStateDidChangeNotification_Vestir, object: nil
        )
    }

    /// 数据变更通知：全量刷新按钮状态与统计数字
    @objc private func onDataChanged_Vestir() {
        updateFollowButtonState_Vestir()
        // 同步刷新帖子数统计（关注/举报后帖子数可能变化）
        if let user_vestir = userModel_Vestir {
            let posts_vestir = TitleViewModel_Vestir.shared_Vestir.getUserPosts_Vestir(user_vestir: user_vestir)
            postsCountLabel_Vestir.text = "\(posts_vestir.count)"
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Vestir() { Navigation_Vestir.pop_Vestir() }

    @objc private func followTapped_Vestir() {
        guard let user_vestir = userModel_Vestir else { return }
        followBtn_Vestir.animatePulseFeedback_Vestir()
        let wasFollowing_vestir = UserViewModel_Vestir.shared_Vestir.isFollowing_Vestir(user_vestir: user_vestir)
        Task { @MainActor in
            UserViewModel_Vestir.shared_Vestir.followUser_Vestir(user_vestir: user_vestir)
            // followUser_Vestir 执行完毕后立即刷新按钮状态
            self.updateFollowButtonState_Vestir()
            // 同步调整粉丝数（本地实时反馈，无需等待通知）
            self.adjustFollowersCount_Vestir(wasFollowing_vestir: wasFollowing_vestir)
        }
        if hideMessageButton_Vestir && wasFollowing_vestir { onUnfollowFromChat_Vestir?() }
    }

    /// 关注/取消关注后实时调整粉丝数显示
    /// 参数：
    /// - wasFollowing_vestir: 点击前是否已关注
    private func adjustFollowersCount_Vestir(wasFollowing_vestir: Bool) {
        let current_Vestir = Int(followersCountLabel_Vestir.text ?? "0") ?? 0
        followersCountLabel_Vestir.text = wasFollowing_vestir
            ? "\(max(0, current_Vestir - 1))"
            : "\(current_Vestir + 1)"
    }

    @objc private func messageTapped_Vestir() {
        guard let user_vestir = userModel_Vestir else { return }
        let isFollowing_vestir = UserViewModel_Vestir.shared_Vestir.isFollowing_Vestir(user_vestir: user_vestir)
        if !isFollowing_vestir {
            let alert_vestir = UIAlertController(
                title: "Follow Required",
                message: "Follow \(user_vestir.userName_Vestir ?? "this user") to start chatting.",
                preferredStyle: .alert
            )
            alert_vestir.addAction(UIAlertAction(title: "Follow Now", style: .default) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    UserViewModel_Vestir.shared_Vestir.followUser_Vestir(user_vestir: user_vestir)
                }
            })
            alert_vestir.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert_vestir, animated: true)
            return
        }
        showChatConfirmSheet_Vestir(user_vestir: user_vestir)
    }

    private func showChatConfirmSheet_Vestir(user_vestir: PrewUserModel_Vestir) {
        let sheet_vestir = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let infoMsg_vestir = "\(user_vestir.userName_Vestir ?? "User")\n\(user_vestir.userIntroduce_Vestir ?? "Fashion lover")\n\nStart a conversation?"
        sheet_vestir.message = infoMsg_vestir
        sheet_vestir.addAction(UIAlertAction(title: "Start Chatting", style: .default) { [weak self] _ in
            guard let self = self else { return }
            Navigation_Vestir.toMessageUser_Vestir(with: user_vestir, style_vestir: .push_vestir)
        })
        sheet_vestir.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet_vestir, animated: true)
    }

    @objc private func postCellTapped_Vestir(_ gesture: UITapGestureRecognizer) {
        guard let v_vestir = gesture.view,
              let post_vestir = TitleViewModel_Vestir.shared_Vestir.getPosts_Vestir()
                .first(where: { $0.titleId_Vestir == v_vestir.tag })
        else { return }
        Navigation_Vestir.toTitleDetail_Vestir(titleModel_vestir: post_vestir)
    }
}

// MARK: - 用户中心头部渐变背景（靛蓝→青绿）

/// 自管理渐变的用户中心头部（靛蓝 #3730A3 → 蓝绿 #0F766E，下方双角圆角 28pt）
fileprivate final class UserInfoHeaderCard_Vestir: UIView {

    private let gradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#3730A3").cgColor,  // 深靛蓝
            UIColor(hexstring_Vestir: "#1D4ED8").cgColor,  // 蓝
            UIColor(hexstring_Vestir: "#0F766E").cgColor   // 青绿
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradLayer_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 28
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Vestir.frame = bounds
    }
}
