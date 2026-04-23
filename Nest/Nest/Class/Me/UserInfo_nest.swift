import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页面
/// 核心作用：展示指定用户的公开信息、关注/消息操作及其发布的帖子
/// 设计思路：
///   - 沉浸式辅助渐变 Header（紧贴屏幕顶部，波浪底边 + 装饰气泡）
///   - 头像悬浮于 Header 底边中央（渐变双环 + 在线指示点）
///   - 用户名 + 简介 + 浮动统计卡片（Following / Fans + 渐变数字）
///   - 关注 / 消息双按钮行（渐变 + 描边风格，按压弹性动画）
///   - 帖子列表，每张卡片左侧 MediaDisplayView 展示首条媒体 + 统计 + 举报入口
///   - 丰富空态：浮动图标 + 双行提示
/// 关键属性：
///   - userModel_Nest: 要展示的目标用户
///   - isFromChat_Nest: 是否从聊天页进入（取消关注后联动返回）
///   - hideMessageBtn_Nest: 是否隐藏消息按钮
class UserInfo_Nest: UIViewController {

    // MARK: - 外部注入

    /// 展示的目标用户
    var userModel_Nest: PrewUserModel_Nest?

    /// 是否从聊天页进入，取消关注时需联动返回
    var isFromChat_Nest: Bool = false

    /// 是否隐藏消息按钮（从聊天页进入时为 true）
    var hideMessageBtn_Nest: Bool = false

    /// 取消关注后的联动回调（由 MessageUser 注入）
    var onUnfollowed_Nest: (() -> Void)?

    // MARK: - 私有状态

    private var userPosts_Nest: [TitleModel_Nest] = []
    /// 页面打开时的初始关注状态（用于计算粉丝数增减）
    private var initialFollowState_Nest: Bool? = nil
    /// userModel_Nest 中记录的基础粉丝数
    private var baseFansCount_Nest: Int = 0

    // MARK: - UI 组件

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.alwaysBounceVertical = true
        sv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        sv_Nest.contentInsetAdjustmentBehavior = .never
        return sv_Nest
    }()

    private let contentView_Nest = UIView()

    /// 沉浸式渐变 Header
    private let headerView_Nest = UserInfoHeaderView_Nest()

    /// 头像外环（渐变色，凸出 Header 底边）
    private let avatarOuterRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 50
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var avatarRingGradient_Nest: CAGradientLayer?

    /// 白色间隔环
    private let avatarInnerWhite_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        v_Nest.layer.cornerRadius = 46
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    /// 真实头像
    private let avatarView_Nest = UserAvatarView_Nest()

    /// 在线指示圆点
    private let onlineDot_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#48BB78")
        v_Nest.layer.cornerRadius = 7
        v_Nest.layer.borderWidth = 2.5
        v_Nest.layer.borderColor = UIColor.white.cgColor
        return v_Nest
    }()

    /// 用户名
    private let nameLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    /// 简介
    private let bioLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.textAlignment = .center
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    // MARK: - 统计卡片

    /// 浮动统计卡片
    private let statsCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 20
        v_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v_Nest.layer.shadowRadius  = 14
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    private let postsCountLabel_Nest  = UILabel()
    private let followCountLabel_Nest = UILabel()
    private let fansCountLabel_Nest   = UILabel()

    // MARK: - 按钮行

    private let btnRow_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .horizontal
        sv_Nest.spacing = 14
        sv_Nest.distribution = .fillEqually
        return sv_Nest
    }()

    private let followBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setTitle("Follow", for: .normal)
        btn_Nest.setTitleColor(.white, for: .normal)
        btn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_Nest.layer.cornerRadius = 24
        return btn_Nest
    }()

    private var followBtnGradient_Nest: CAGradientLayer?

    private let messageBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setTitle("Message", for: .normal)
        btn_Nest.setTitleColor(ColorConfig_Nest.secondaryGradientStart_Nest, for: .normal)
        btn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_Nest.backgroundColor = .white
        btn_Nest.layer.cornerRadius = 24
        btn_Nest.layer.borderWidth = 1.5
        btn_Nest.layer.borderColor = ColorConfig_Nest.secondaryGradientStart_Nest.cgColor
        return btn_Nest
    }()

    // MARK: - 帖子区域

    private let postsSectionView_Nest = UserInfoPostsSectionHeader_Nest()

    private let postsStack_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .vertical
        sv_Nest.spacing = 14
        return sv_Nest
    }()

    /// 丰富空态视图
    private let emptyView_Nest = UserInfoEmptyView_Nest()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        setupScrollView_Nest()
        buildHeader_Nest()
        buildAvatar_Nest()
        buildUserInfo_Nest()
        buildStatsCard_Nest()
        buildButtons_Nest()
        buildPostsSection_Nest()
        setupNotifications_Nest()
        loadData_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView_Nest.updateCurvedMask_Nest()
        followBtnGradient_Nest?.frame = followBtn_Nest.bounds
        avatarRingGradient_Nest?.frame = avatarOuterRing_Nest.bounds
    }

    // MARK: - 布局搭建

    private func setupScrollView_Nest() {
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)
        scrollView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
        }
    }

    /// 构建沉浸式 Header
    private func buildHeader_Nest() {
        contentView_Nest.addSubview(headerView_Nest)
        headerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(200)
        }
        headerView_Nest.onBack_Nest = { [weak self] in Navigation_Nest.pop_Nest(from: self) }
        headerView_Nest.onReport_Nest = { [weak self] in self?.onReportTapped_Nest() }
    }

    /// 构建悬浮头像
    private func buildAvatar_Nest() {
        let gl_Nest = CAGradientLayer()
        gl_Nest.colors = [
            ColorConfig_Nest.secondaryGradientStart_Nest.cgColor,
            ColorConfig_Nest.secondaryGradientEnd_Nest.cgColor
        ]
        gl_Nest.startPoint = CGPoint(x: 0, y: 0)
        gl_Nest.endPoint   = CGPoint(x: 1, y: 1)
        avatarOuterRing_Nest.layer.insertSublayer(gl_Nest, at: 0)
        avatarRingGradient_Nest = gl_Nest

        avatarOuterRing_Nest.addSubview(avatarInnerWhite_Nest)
        avatarInnerWhite_Nest.addSubview(avatarView_Nest)

        contentView_Nest.addSubview(avatarOuterRing_Nest)
        contentView_Nest.addSubview(onlineDot_Nest)

        avatarOuterRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerX.equalToSuperview()
            make_Nest.top.equalTo(headerView_Nest.snp.bottom).offset(-42)
            make_Nest.width.height.equalTo(100)
        }
        avatarInnerWhite_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(92)
        }
        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(84)
        }
        onlineDot_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalTo(avatarOuterRing_Nest).offset(-4)
            make_Nest.bottom.equalTo(avatarOuterRing_Nest).offset(-4)
            make_Nest.width.height.equalTo(14)
        }
    }

    /// 构建用户名 + 简介
    private func buildUserInfo_Nest() {
        contentView_Nest.addSubview(nameLabel_Nest)
        contentView_Nest.addSubview(bioLabel_Nest)

        nameLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(avatarOuterRing_Nest.snp.bottom).offset(10)
            make_Nest.centerX.equalToSuperview()
            make_Nest.leading.greaterThanOrEqualToSuperview().offset(20)
            make_Nest.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        bioLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLabel_Nest.snp.bottom).offset(4)
            make_Nest.leading.equalToSuperview().offset(30)
            make_Nest.trailing.equalToSuperview().offset(-30)
        }
    }

    /// 构建统计卡片
    private func buildStatsCard_Nest() {
        contentView_Nest.addSubview(statsCard_Nest)
        statsCard_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(bioLabel_Nest.snp.bottom).offset(16)
            make_Nest.leading.equalToSuperview().offset(24)
            make_Nest.trailing.equalToSuperview().offset(-24)
            make_Nest.height.equalTo(84)
        }

        let postsCol_Nest  = makeStatColumn_Nest(numLabel: postsCountLabel_Nest, title: "Posts")
        let divider1_Nest  = makeVerticalDivider_Nest()
        let followCol_Nest = makeStatColumn_Nest(numLabel: followCountLabel_Nest, title: "Following")
        let divider2_Nest  = makeVerticalDivider_Nest()
        let fansCol_Nest   = makeStatColumn_Nest(numLabel: fansCountLabel_Nest, title: "Fans")

        let stack_Nest = UIStackView(arrangedSubviews: [postsCol_Nest, divider1_Nest, followCol_Nest, divider2_Nest, fansCol_Nest])
        stack_Nest.axis = .horizontal
        stack_Nest.distribution = .equalCentering
        stack_Nest.alignment = .center

        statsCard_Nest.addSubview(stack_Nest)
        stack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.bottom.equalToSuperview().inset(16)
            make_Nest.leading.equalToSuperview().offset(24)
            make_Nest.trailing.equalToSuperview().offset(-24)
        }
    }

    /// 构建按钮行
    private func buildButtons_Nest() {
        // 关注按钮渐变
        let btnGrad_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        btnGrad_Nest.cornerRadius = 24
        followBtn_Nest.layer.insertSublayer(btnGrad_Nest, at: 0)
        followBtnGradient_Nest = btnGrad_Nest
        followBtn_Nest.addTarget(self, action: #selector(onFollowTapped_Nest), for: .touchUpInside)

        // 消息按钮图标
        let msgIcon_Nest = UIImage(systemName: "paperplane.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        messageBtn_Nest.setImage(msgIcon_Nest, for: .normal)
        messageBtn_Nest.tintColor = ColorConfig_Nest.secondaryGradientStart_Nest
        messageBtn_Nest.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        messageBtn_Nest.addTarget(self, action: #selector(onMessageTapped_Nest), for: .touchUpInside)

        if hideMessageBtn_Nest {
            btnRow_Nest.addArrangedSubview(followBtn_Nest)
        } else {
            btnRow_Nest.addArrangedSubview(followBtn_Nest)
            btnRow_Nest.addArrangedSubview(messageBtn_Nest)
        }

        contentView_Nest.addSubview(btnRow_Nest)
        btnRow_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(statsCard_Nest.snp.bottom).offset(18)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(48)
        }
        followBtn_Nest.snp.makeConstraints { make_Nest in make_Nest.height.equalTo(48) }
        messageBtn_Nest.snp.makeConstraints { make_Nest in make_Nest.height.equalTo(48) }
    }

    /// 构建帖子区域
    private func buildPostsSection_Nest() {
        contentView_Nest.addSubview(postsSectionView_Nest)
        contentView_Nest.addSubview(postsStack_Nest)
        contentView_Nest.addSubview(emptyView_Nest)

        postsSectionView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(btnRow_Nest.snp.bottom).offset(24)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(28)
        }
        postsStack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(postsSectionView_Nest.snp.bottom).offset(12)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.bottom.equalToSuperview().offset(-30)
        }
        emptyView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(postsSectionView_Nest.snp.bottom).offset(30)
            make_Nest.centerX.equalToSuperview()
            make_Nest.width.equalTo(240)
        }
        emptyView_Nest.isHidden = true
    }

    // MARK: - 统计列构建

    /// 创建统计数字列（渐变数字 + 标题）
    private func makeStatColumn_Nest(numLabel: UILabel, title: String) -> UIView {
        let col_Nest = UIView()

        numLabel.text = "0"
        numLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        numLabel.textColor = ColorConfig_Nest.secondaryGradientStart_Nest
        numLabel.textAlignment = .center

        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = title
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        titleLbl_Nest.textAlignment = .center

        col_Nest.addSubview(numLabel)
        col_Nest.addSubview(titleLbl_Nest)

        numLabel.snp.makeConstraints { make_Nest in
            make_Nest.top.centerX.equalToSuperview()
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(numLabel.snp.bottom).offset(2)
            make_Nest.centerX.equalToSuperview()
            make_Nest.bottom.equalToSuperview()
            make_Nest.width.greaterThanOrEqualTo(60)
        }
        return col_Nest
    }

    /// 创建竖分割线
    private func makeVerticalDivider_Nest() -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.divider_Nest
        v_Nest.snp.makeConstraints { make_Nest in
            make_Nest.width.equalTo(1)
            make_Nest.height.equalTo(32)
        }
        return v_Nest
    }

    // MARK: - 通知

    private func setupNotifications_Nest() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onStateChanged_Nest),
            name: UserViewModel_Nest.userStateDidChangeNotification_Nest, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onStateChanged_Nest),
            name: TitleViewModel_Nest.titleStateDidChangeNotification_Nest, object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 数据加载

    private func loadData_Nest() {
        guard let user_Nest = userModel_Nest else { return }

        avatarView_Nest.configure_Nest(userId_Nest: user_Nest.userId_Nest ?? 0)
        nameLabel_Nest.text = user_Nest.userName_Nest ?? "User"
        bioLabel_Nest.text = (user_Nest.userIntroduce_Nest?.isEmpty == false)
            ? user_Nest.userIntroduce_Nest
            : "No bio"

        followCountLabel_Nest.text = "\(user_Nest.userFollow_Nest ?? 0)"

        // 首次加载时记录基础粉丝数和初始关注状态，后续通过关注操作动态调整展示值
        if initialFollowState_Nest == nil {
            baseFansCount_Nest      = user_Nest.userFans_Nest ?? 0
            initialFollowState_Nest = UserViewModel_Nest.shared_Nest.isFollowing_Nest(user_nest: user_Nest)
        }

        // 帖子数
        let uid_Nest_pre = user_Nest.userId_Nest ?? 0
        postsCountLabel_Nest.text = "\(TitleViewModel_Nest.shared_Nest.getUserPostsById_Nest(userId_nest: uid_Nest_pre).count)"

        updateFollowBtnUI_Nest()

        let uid_Nest = user_Nest.userId_Nest ?? 0
        userPosts_Nest = TitleViewModel_Nest.shared_Nest.getUserPostsById_Nest(userId_nest: uid_Nest)
        postsSectionView_Nest.updateCount_Nest(userPosts_Nest.count)
        buildPostCards_Nest()
    }

    /// 更新关注按钮外观，并同步刷新粉丝数
    private func updateFollowBtnUI_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        let isNowFollowing_Nest = UserViewModel_Nest.shared_Nest.isFollowing_Nest(user_nest: user_Nest)

        // 按钮样式
        if isNowFollowing_Nest {
            followBtn_Nest.setTitle("Followed", for: .normal)
            followBtn_Nest.setTitleColor(ColorConfig_Nest.textSecondary_Nest, for: .normal)
            followBtnGradient_Nest?.isHidden = true
            followBtn_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
            followBtn_Nest.layer.borderWidth = 1.5
            followBtn_Nest.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        } else {
            followBtn_Nest.setTitle("Follow", for: .normal)
            followBtn_Nest.setTitleColor(.white, for: .normal)
            followBtnGradient_Nest?.isHidden = false
            followBtn_Nest.backgroundColor = .clear
            followBtn_Nest.layer.borderWidth = 0
        }

        // 动态计算粉丝数：相对初始状态加减 1
        let initial_Nest = initialFollowState_Nest ?? isNowFollowing_Nest
        let delta_Nest   = (isNowFollowing_Nest ? 1 : 0) - (initial_Nest ? 1 : 0)
        fansCountLabel_Nest.text = "\(max(0, baseFansCount_Nest + delta_Nest))"
    }

    // MARK: - 帖子卡片

    private func buildPostCards_Nest() {
        postsStack_Nest.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if userPosts_Nest.isEmpty {
            emptyView_Nest.isHidden = false
            return
        }
        emptyView_Nest.isHidden = true

        for (i_Nest, post_Nest) in userPosts_Nest.enumerated() {
            let card_Nest = makePostCard_Nest(post: post_Nest)
            postsStack_Nest.addArrangedSubview(card_Nest)
            card_Nest.animateSlideInFromBottom_Nest(
                offset_Nest: 30,
                delay_Nest: TimeInterval(i_Nest) * AnimationConfig_Nest.delayShort_Nest
            )
        }
    }

    /// 构建帖子卡片（左媒体 + 右文字 + 底部统计）
    /// 参数 `post`：列表中的帖子；左侧媒体 `MediaDisplayView_Nest` 取首项 `titleMeidas` 与项目内统一展示逻辑
    private func makePostCard_Nest(post: TitleModel_Nest) -> UIView {
        let card_Nest = UIView()
        card_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        card_Nest.layer.cornerRadius = 18
        card_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        card_Nest.layer.shadowOffset  = CGSize(width: 0, height: 3)
        card_Nest.layer.shadowRadius  = 10
        card_Nest.layer.shadowOpacity = 1

        // 左侧媒体：与发现页等一致，支持 Assets/网络/文档/Bundle 视频缩略
        let mediaView_Nest = MediaDisplayView_Nest()
        mediaView_Nest.configure_Nest(
            mediaPath_Nest: post.titleMeidas_Nest.first,
            isVideo_Nest: false
        )

        // 文本区域
        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = post.title_Nest
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        titleLbl_Nest.numberOfLines = 1

        let contentLbl_Nest = UILabel()
        contentLbl_Nest.text = post.titleContent_Nest
        contentLbl_Nest.font = UIFont.systemFont(ofSize: 13)
        contentLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        contentLbl_Nest.numberOfLines = 2

        // 底部统计
        let likeIcon_Nest = UIImageView(image: UIImage(systemName: "heart.fill"))
        likeIcon_Nest.tintColor = ColorConfig_Nest.secondaryGradientStart_Nest
        likeIcon_Nest.contentMode = .scaleAspectFit
        let likeLbl_Nest = UILabel()
        likeLbl_Nest.text = "\(post.likes_Nest)"
        likeLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        likeLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest

        let commentIcon_Nest = UIImageView(image: UIImage(systemName: "bubble.left.fill"))
        commentIcon_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        commentIcon_Nest.contentMode = .scaleAspectFit
        let commentLbl_Nest = UILabel()
        commentLbl_Nest.text = "\(post.reviews_Nest.count)"
        commentLbl_Nest.font = UIFont.systemFont(ofSize: 12)
        commentLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest

        // 举报按钮
        let reportBtn_Nest = ReportDeleteHelper_Nest.createPostReportButton_Nest(
            post_Nest: post, size_Nest: 16,
            color_Nest: ColorConfig_Nest.textPlaceholder_Nest, from: self
        )

        card_Nest.addSubview(mediaView_Nest)
        card_Nest.addSubview(titleLbl_Nest)
        card_Nest.addSubview(contentLbl_Nest)
        card_Nest.addSubview(likeIcon_Nest)
        card_Nest.addSubview(likeLbl_Nest)
        card_Nest.addSubview(commentIcon_Nest)
        card_Nest.addSubview(commentLbl_Nest)
        card_Nest.addSubview(reportBtn_Nest)

        // 固定 72×72 且垂直居中，避免与卡片 bottom/栈布局形成循环依赖导致媒体被竖向拉成「无限高」
        mediaView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(14)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(72)
        }
        reportBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(10)
            make_Nest.trailing.equalToSuperview().offset(-10)
            make_Nest.width.height.equalTo(30)
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(14)
            make_Nest.leading.equalTo(mediaView_Nest.snp.trailing).offset(12)
            make_Nest.trailing.equalTo(reportBtn_Nest.snp.leading).offset(-6)
        }
        contentLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLbl_Nest.snp.bottom).offset(4)
            make_Nest.leading.equalTo(titleLbl_Nest)
            make_Nest.trailing.equalToSuperview().offset(-14)
        }
        likeIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(contentLbl_Nest.snp.bottom).offset(8)
            make_Nest.leading.equalTo(titleLbl_Nest)
            make_Nest.width.height.equalTo(14)
            make_Nest.bottom.equalToSuperview().offset(-14)
        }
        likeLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerY.equalTo(likeIcon_Nest)
            make_Nest.leading.equalTo(likeIcon_Nest.snp.trailing).offset(4)
        }
        commentIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerY.equalTo(likeIcon_Nest)
            make_Nest.leading.equalTo(likeLbl_Nest.snp.trailing).offset(14)
            make_Nest.width.height.equalTo(14)
        }
        commentLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerY.equalTo(likeIcon_Nest)
            make_Nest.leading.equalTo(commentIcon_Nest.snp.trailing).offset(4)
        }

        card_Nest.isUserInteractionEnabled = true
        card_Nest.tag = post.titleId_Nest
        card_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onPostCardTapped_Nest(_:)))
        )
        return card_Nest
    }

    // MARK: - 事件处理

    @objc private func onFollowTapped_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        followBtn_Nest.animatePulse_Nest()

        let wasFollowing_Nest = UserViewModel_Nest.shared_Nest.isFollowing_Nest(user_nest: user_Nest)
        UserViewModel_Nest.shared_Nest.followUser_Nest(user_nest: user_Nest)
        updateFollowBtnUI_Nest()

        if wasFollowing_Nest && isFromChat_Nest {
            if let uid_Nest = user_Nest.userId_Nest {
                MessageViewModel_Nest.shared_Nest.deleteUserMessages_Nest(userId_nest: uid_Nest)
            }
            onUnfollowed_Nest?()
            Navigation_Nest.pop_Nest(from: self)
        }
    }

    @objc private func onMessageTapped_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if !UserViewModel_Nest.shared_Nest.isFollowing_Nest(user_nest: user_Nest) {
            let alert_Nest = UIAlertController(
                title: "Follow Required",
                message: "You need to follow \(user_Nest.userName_Nest ?? "this user") before sending a message.",
                preferredStyle: .alert
            )
            alert_Nest.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_Nest, animated: true)
        } else {
            showMessageConfirmModal_Nest(user: user_Nest)
        }
    }

    private func showMessageConfirmModal_Nest(user: PrewUserModel_Nest) {
        let sheet_Nest = UserChatConfirmSheet_Nest(user: user)
        sheet_Nest.modalPresentationStyle = .overFullScreen
        sheet_Nest.modalTransitionStyle = .crossDissolve
        sheet_Nest.onConfirm_Nest = { [weak self] in
            guard let self else { return }
            Navigation_Nest.toMessageUser_Nest(with: user)
        }
        present(sheet_Nest, animated: true)
    }

    private func onReportTapped_Nest() {
        guard let user_Nest = userModel_Nest else { return }
        ReportDeleteHelper_Nest.block_Nest(user_Nest: user_Nest, from: self) { [weak self] in
            Navigation_Nest.pop_Nest(from: self)
        }
    }

    @objc private func onPostCardTapped_Nest(_ gesture: UITapGestureRecognizer) {
        guard let view_Nest = gesture.view else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        view_Nest.animatePressDown_Nest { view_Nest.animatePressUp_Nest() }
        let tid_Nest = view_Nest.tag
        if let post_Nest = userPosts_Nest.first(where: { $0.titleId_Nest == tid_Nest }) {
            Navigation_Nest.toTitleDetail_Nest(titleModel_nest: post_Nest)
        }
    }

    @objc private func onStateChanged_Nest() {
        loadData_Nest()
    }
}

// MARK: - UserInfoHeaderView_Nest
/// 用户信息页沉浸式渐变 Header
/// 设计：紧贴屏幕顶部、波浪底边、装饰气泡、返回 + 举报按钮
private class UserInfoHeaderView_Nest: UIView {

    var onBack_Nest:   (() -> Void)?
    var onReport_Nest: (() -> Void)?

    private var gradientLayer_Nest: CAGradientLayer?

    private let bubble1_Nest = UserInfoHeaderView_Nest.makeBubble_Nest(size: 130, alpha: 0.07)
    private let bubble2_Nest = UserInfoHeaderView_Nest.makeBubble_Nest(size: 75,  alpha: 0.09)
    private let bubble3_Nest = UserInfoHeaderView_Nest.makeBubble_Nest(size: 50,  alpha: 0.12)

    private let backBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()

    private let backIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "chevron.left"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let reportBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()

    private let reportIcon_Nest: UIImageView = {
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let iv_Nest  = UIImageView(image: UIImage(systemName: "ellipsis", withConfiguration: cfg_Nest))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

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
        let gl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    private func setupSubviews_Nest() {
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(bubble3_Nest)

        backBtn_Nest.addSubview(backIcon_Nest)
        reportBtn_Nest.addSubview(reportIcon_Nest)
        addSubview(backBtn_Nest)
        addSubview(reportBtn_Nest)

        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-25)
            make_Nest.trailing.equalToSuperview().offset(25)
            make_Nest.width.height.equalTo(130)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(50)
            make_Nest.trailing.equalToSuperview().offset(-60)
            make_Nest.width.height.equalTo(75)
        }
        bubble3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(15)
            make_Nest.leading.equalToSuperview().offset(30)
            make_Nest.width.height.equalTo(50)
        }

        backBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(54)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.width.height.equalTo(36)
        }
        backIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(16)
        }
        reportBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.centerY.equalTo(backBtn_Nest)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.width.height.equalTo(36)
        }
        reportIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.equalTo(26)
            make_Nest.height.equalTo(22)
        }

        backBtn_Nest.isUserInteractionEnabled = true
        backBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped_Nest)))
        reportBtn_Nest.isUserInteractionEnabled = true
        reportBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportTapped_Nest)))
    }

    /// 刷新渐变 frame 与波浪底边蒙版
    func updateCurvedMask_Nest() {
        gradientLayer_Nest?.frame = bounds
        let path_Nest = UIBezierPath()
        path_Nest.move(to: .zero)
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: 0))
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 16))
        path_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: bounds.height - 16),
            controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height + 22)
        )
        path_Nest.close()
        let mask_Nest = CAShapeLayer()
        mask_Nest.path = path_Nest.cgPath
        layer.mask = mask_Nest
    }

    @objc private func backTapped_Nest() {
        backBtn_Nest.animatePressDown_Nest { self.backBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onBack_Nest?()
    }

    @objc private func reportTapped_Nest() {
        reportBtn_Nest.animatePressDown_Nest { self.reportBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onReport_Nest?()
    }
}

// MARK: - UserInfoPostsSectionHeader_Nest
/// 帖子区域标题行：渐变圆点 + "Posts" + 数量胶囊
private class UserInfoPostsSectionHeader_Nest: UIView {

    private var gradientDotLayer_Nest: CAGradientLayer?

    private let dotView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 4
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Posts"
        lbl_Nest.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let countBadge_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.secondaryGradientStart_Nest
        lbl_Nest.backgroundColor = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.12)
        lbl_Nest.textAlignment = .center
        lbl_Nest.layer.cornerRadius = 10
        lbl_Nest.clipsToBounds = true
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews_Nest() {
        let gl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        dotView_Nest.layer.insertSublayer(gl_Nest, at: 0)
        gradientDotLayer_Nest = gl_Nest

        addSubview(dotView_Nest)
        addSubview(titleLabel_Nest)
        addSubview(countBadge_Nest)

        dotView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(8)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(dotView_Nest.snp.trailing).offset(8)
            make_Nest.centerY.equalToSuperview()
        }
        countBadge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(titleLabel_Nest.snp.trailing).offset(8)
            make_Nest.centerY.equalToSuperview()
            make_Nest.height.equalTo(20)
            make_Nest.width.greaterThanOrEqualTo(30)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientDotLayer_Nest?.frame = dotView_Nest.bounds
    }

    /// 更新帖子数
    func updateCount_Nest(_ count: Int) {
        countBadge_Nest.text = "  \(count)  "
    }
}

// MARK: - UserInfoEmptyView_Nest
/// 空态视图：浮动图标 + 双行提示
private class UserInfoEmptyView_Nest: UIView {

    private let iconContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.08)
        v_Nest.layer.cornerRadius = 28
        return v_Nest
    }()

    private let iconView_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "doc.text.magnifyingglass"))
        iv_Nest.tintColor = ColorConfig_Nest.secondaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "No Posts Yet"
        lbl_Nest.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let subtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "This user hasn't shared anything yet."
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.textAlignment = .center
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconContainer_Nest)
        iconContainer_Nest.addSubview(iconView_Nest)
        addSubview(titleLabel_Nest)
        addSubview(subtitleLabel_Nest)

        iconContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.centerX.equalToSuperview()
            make_Nest.width.height.equalTo(56)
        }
        iconView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(28)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(iconContainer_Nest.snp.bottom).offset(14)
            make_Nest.centerX.equalToSuperview()
        }
        subtitleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(6)
            make_Nest.leading.trailing.bottom.equalToSuperview()
        }

        startFloating_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 图标轻微上下浮动动画
    private func startFloating_Nest() {
        UIView.animate(
            withDuration: 2.4,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: { self.iconContainer_Nest.transform = CGAffineTransform(translationX: 0, y: -6) }
        )
    }
}

// MARK: - UserChatConfirmSheet_Nest
/// 确认开始聊天的半屏弹窗
/// 设计：模糊遮罩 + 圆角卡片 + 头像渐变环 + 用户名简介 + 渐变确认按钮
private class UserChatConfirmSheet_Nest: UIViewController {

    var onConfirm_Nest: (() -> Void)?
    private let user_Nest: PrewUserModel_Nest

    init(user: PrewUserModel_Nest) {
        self.user_Nest = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 确认按钮容器（纯色背景，避免 CAGradientLayer 时序问题）
    private let confirmGradientView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.secondaryGradientStart_Nest
        v_Nest.layer.cornerRadius = 24
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildSheetUI_Nest()
    }

    private let confirmBtn_Nest = UIButton(type: .custom)

    private func buildSheetUI_Nest() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)

        // 背景点击关闭
        let bgTap_Nest = UITapGestureRecognizer(target: self, action: #selector(onCancelBtnTapped_Nest))
        view.addGestureRecognizer(bgTap_Nest)

        let card_Nest = UIView()
        card_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        card_Nest.layer.cornerRadius = 28
        card_Nest.layer.shadowColor   = UIColor.black.withAlphaComponent(0.15).cgColor
        card_Nest.layer.shadowOffset  = CGSize(width: 0, height: 8) 
        card_Nest.layer.shadowRadius  = 20
        card_Nest.layer.shadowOpacity = 1
        view.addSubview(card_Nest)
        card_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.center.equalToSuperview()
        }

        // 头像渐变环
        let avatarRing_Nest = UIView()
        avatarRing_Nest.layer.cornerRadius = 42
        avatarRing_Nest.clipsToBounds = true
        let ringGl_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: CGRect(x: 0, y: 0, width: 84, height: 84))
        avatarRing_Nest.layer.insertSublayer(ringGl_Nest, at: 0)

        let whiteInner_Nest = UIView()
        whiteInner_Nest.backgroundColor = .white
        whiteInner_Nest.layer.cornerRadius = 38
        whiteInner_Nest.clipsToBounds = true
        avatarRing_Nest.addSubview(whiteInner_Nest)

        let avatar_Nest = UserAvatarView_Nest()
        avatar_Nest.configure_Nest(userId_Nest: user_Nest.userId_Nest ?? 0)
        whiteInner_Nest.addSubview(avatar_Nest)

        let nameLbl_Nest = UILabel()
        nameLbl_Nest.text = user_Nest.userName_Nest
        nameLbl_Nest.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        nameLbl_Nest.textAlignment = .center

        let bioLbl_Nest = UILabel()
        bioLbl_Nest.text = user_Nest.userIntroduce_Nest ?? "No bio"
        bioLbl_Nest.font = UIFont.systemFont(ofSize: 13)
        bioLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        bioLbl_Nest.textAlignment = .center
        bioLbl_Nest.numberOfLines = 2

        // 确认按钮（button 直接叠加在纯色容器上，白色文字清晰可见）
        confirmBtn_Nest.setTitle("Start Chat", for: .normal)
        confirmBtn_Nest.setTitleColor(.white, for: .normal)
        confirmBtn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        confirmBtn_Nest.backgroundColor = .clear
        confirmGradientView_Nest.addSubview(confirmBtn_Nest)
        confirmBtn_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }
        confirmBtn_Nest.addTarget(self, action: #selector(onConfirmBtnTapped_Nest), for: .touchUpInside)

        let cancelBtn_Nest = UIButton(type: .custom)
        cancelBtn_Nest.setTitle("Cancel", for: .normal)
        cancelBtn_Nest.setTitleColor(ColorConfig_Nest.textSecondary_Nest, for: .normal)
        cancelBtn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelBtn_Nest.addTarget(self, action: #selector(onCancelBtnTapped_Nest), for: .touchUpInside)

        card_Nest.addSubview(avatarRing_Nest)
        card_Nest.addSubview(nameLbl_Nest)
        card_Nest.addSubview(bioLbl_Nest)
        card_Nest.addSubview(confirmGradientView_Nest)
        card_Nest.addSubview(cancelBtn_Nest)

        avatarRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(28)
            make_Nest.centerX.equalToSuperview()
            make_Nest.width.height.equalTo(84)
        }
        whiteInner_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(76)
        }
        avatar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(68)
        }
        nameLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(avatarRing_Nest.snp.bottom).offset(14)
            make_Nest.leading.trailing.equalToSuperview().inset(20)
        }
        bioLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLbl_Nest.snp.bottom).offset(6)
            make_Nest.leading.trailing.equalToSuperview().inset(20)
        }
        confirmGradientView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(bioLbl_Nest.snp.bottom).offset(22)
            make_Nest.leading.trailing.equalToSuperview().inset(20)
            make_Nest.height.equalTo(48)
        }
        cancelBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(confirmGradientView_Nest.snp.bottom).offset(10)
            make_Nest.centerX.equalToSuperview()
            make_Nest.bottom.equalToSuperview().offset(-22)
        }

        // 弹入动画
        card_Nest.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        card_Nest.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Nest.durationSpring_Nest,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Nest.springDampingNormal_Nest,
            initialSpringVelocity: AnimationConfig_Nest.springVelocity_Nest,
            options: .curveEaseOut,
            animations: {
                card_Nest.transform = .identity
                card_Nest.alpha = 1
            }
        )
    }

    @objc private func onConfirmBtnTapped_Nest() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss(animated: true) { [weak self] in
            self?.onConfirm_Nest?()
        }
    }

    @objc private func onCancelBtnTapped_Nest() {
        dismiss(animated: true)
    }
}
