import UIKit
import SnapKit

// MARK: - 用户帖子网格单元格

/// 用户中心帖子网格单元格
/// 功能：展示帖子封面媒体与标题，右上角自动呈现举报/删除按钮
class UserInfoPostCell_Hush: UICollectionViewCell {

    static let reuseId_Hush = "UserInfoPostCell_Hush"

    private let cardView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 1
        return v
    }()

    private let clipView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let mediaView_Hush = MediaDisplayView_Hush()

    private let overlayView_Hush = UIView()

    private let titleLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        return lbl
    }()

    private let reportContainer_Hush = UIView()
    private var overlayGradient_Hush: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayGradient_Hush?.frame = overlayView_Hush.bounds
    }

    private func setupUI_Hush() {
        contentView.addSubview(cardView_Hush)
        cardView_Hush.addSubview(clipView_Hush)
        clipView_Hush.addSubview(mediaView_Hush)
        clipView_Hush.addSubview(overlayView_Hush)
        clipView_Hush.addSubview(titleLabel_Hush)
        clipView_Hush.addSubview(reportContainer_Hush)

        cardView_Hush.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }
        clipView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }
        mediaView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }
        overlayView_Hush.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(72)
        }
        titleLabel_Hush.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        reportContainer_Hush.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(6)
            make.width.height.equalTo(28)
        }

        let grad = CAGradientLayer()
        grad.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.65).cgColor]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint = CGPoint(x: 0.5, y: 1)
        overlayView_Hush.layer.addSublayer(grad)
        overlayGradient_Hush = grad
    }

    /// 配置单元格内容
    /// - Parameters:
    ///   - post_hush: 帖子数据模型
    ///   - from_hush: 呈现举报弹窗的父视图控制器
    ///   - completion_hush: 举报/删除完成后刷新数据的回调
    func configure_Hush(post_hush: TitleModel_Hush, from_hush: UIViewController, completion_hush: (() -> Void)?) {
        let path = post_hush.titleMeidas_Hush.first
        let isVideo = path?.lowercased().hasSuffix(".mp4") == true || path?.lowercased().hasSuffix(".mov") == true
        mediaView_Hush.configure_Hush(mediaPath_Hush: path, isVideo_Hush: isVideo)
        titleLabel_Hush.text = post_hush.title_Hush

        reportContainer_Hush.subviews.forEach { $0.removeFromSuperview() }
        let btn = ReportDeleteHelper_Hush.createPostReportButton_Hush(
            post_Hush: post_hush,
            size_Hush: 18,
            color_Hush: .white,
            from: from_hush,
            completion_Hush: completion_hush
        )
        reportContainer_Hush.addSubview(btn)
        btn.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - 用户中心头部（CollectionView Supplementary Header）

/// 用户中心头部视图
/// 功能：展示用户头像、昵称、简介、关注/粉丝数，以及关注/消息操作按钮
/// 关键属性：onFollowTapped_Hush、onMessageTapped_Hush
class UserInfoHeaderView_Hush: UICollectionReusableView {

    static let reuseId_Hush = "UserInfoHeaderView_Hush"

    // MARK: - 回调

    var onFollowTapped_Hush: (() -> Void)?
    var onMessageTapped_Hush: (() -> Void)?

    // MARK: - UI 组件

    /// 顶部英雄横幅
    private let heroBanner_Hush = UIView()
    private var heroBannerGradient_Hush: CAGradientLayer?

    /// 横幅装饰图标
    private let bannerAperture_Hush = UIImageView()

    /// 头像最外层白色环（与背景隔离）
    private let avatarOuterRing_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        v.layer.cornerRadius = 58
        return v
    }()

    private let avatarRingView_Hush: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 53
        v.clipsToBounds = false
        return v
    }()
    private var ringGradient_Hush: CAGradientLayer?

    private let avatarView_Hush: UserAvatarView_Hush = {
        let v = UserAvatarView_Hush()
        v.layer.cornerRadius = 44
        v.clipsToBounds = true
        return v
    }()

    private let nameLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .black)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        lbl.textAlignment = .center
        return lbl
    }()

    private let bioLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = ColorConfig_Hush.textSecondary_Hush
        lbl.textAlignment = .center
        lbl.numberOfLines = 3
        return lbl
    }()

    private let statsStack_Hush: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 0
        return sv
    }()

    private lazy var followingStatView_Hush = makeStatView_Hush(title: "Following")
    private lazy var fansStatView_Hush = makeStatView_Hush(title: "Fans")

    /// 关注按钮（根据关注状态动态切换样式）
    let followButton_Hush: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    private var followGradient_Hush: CAGradientLayer?

    /// 消息按钮（fromChat 为 true 时隐藏）
    let messageButton_Hush: UIButton = {
        let btn = UIButton()
        btn.setTitle("Message", for: .normal)
        btn.setTitleColor(ColorConfig_Hush.primaryGradientStart_Hush, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        btn.backgroundColor = .white
        btn.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal)
        btn.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
        return btn
    }()

    private let buttonStack_Hush: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private let divider_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.divider_Hush
        return v
    }()

    private let postsTitle_Hush: UILabel = {
        let lbl = UILabel()
        lbl.text = "Posts"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        heroBannerGradient_Hush?.frame = heroBanner_Hush.bounds
        ringGradient_Hush?.frame = avatarRingView_Hush.bounds
        followGradient_Hush?.frame = followButton_Hush.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush

        // 英雄横幅（橙→红→深红）
        addSubview(heroBanner_Hush)
        let heroGrad_Hush = CAGradientLayer()
        heroGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
            UIColor(hexstring_Hush: "#6B1515").cgColor
        ]
        heroGrad_Hush.locations = [0, 0.6, 1]
        heroGrad_Hush.startPoint = CGPoint(x: 0, y: 0)
        heroGrad_Hush.endPoint = CGPoint(x: 1, y: 1)
        heroBanner_Hush.layer.addSublayer(heroGrad_Hush)
        heroBannerGradient_Hush = heroGrad_Hush

        // 横幅装饰光圈
        let apertureConfig_Hush = UIImage.SymbolConfiguration(pointSize: 70, weight: .ultraLight)
        bannerAperture_Hush.image = UIImage(systemName: "camera.aperture", withConfiguration: apertureConfig_Hush)
        bannerAperture_Hush.tintColor = UIColor.white.withAlphaComponent(0.12)
        bannerAperture_Hush.contentMode = .scaleAspectFit
        heroBanner_Hush.addSubview(bannerAperture_Hush)

        // 头像三层结构（白环 → 渐变环 → 头像）
        addSubview(avatarOuterRing_Hush)
        avatarOuterRing_Hush.addSubview(avatarRingView_Hush)
        avatarRingView_Hush.addSubview(avatarView_Hush)

        addSubview(nameLabel_Hush)
        addSubview(bioLabel_Hush)
        statsStack_Hush.addArrangedSubview(followingStatView_Hush)
        statsStack_Hush.addArrangedSubview(fansStatView_Hush)
        addSubview(statsStack_Hush)

        buttonStack_Hush.addArrangedSubview(followButton_Hush)
        buttonStack_Hush.addArrangedSubview(messageButton_Hush)
        addSubview(buttonStack_Hush)

        addSubview(divider_Hush)
        addSubview(postsTitle_Hush)

        followButton_Hush.addTarget(self, action: #selector(handleFollowTapped_Hush), for: .touchUpInside)
        messageButton_Hush.addTarget(self, action: #selector(handleMessageTapped_Hush), for: .touchUpInside)

        // 约束
        heroBanner_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        bannerAperture_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(-8)
            make.centerY.equalToSuperview().offset(8)
            make.width.height.equalTo(96)
        }
        avatarOuterRing_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(heroBanner_Hush.snp.bottom)
            make.width.height.equalTo(116)
        }
        avatarRingView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(106)
        }
        avatarView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }
        nameLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(avatarOuterRing_Hush.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bioLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Hush.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        statsStack_Hush.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Hush.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(52)
        }
        buttonStack_Hush.snp.makeConstraints { make in
            make.top.equalTo(statsStack_Hush.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        divider_Hush.snp.makeConstraints { make in
            make.top.equalTo(buttonStack_Hush.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        postsTitle_Hush.snp.makeConstraints { make in
            make.top.equalTo(divider_Hush.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(8)
        }

        // 头像渐变环（主色：橙→红）
        let ringGrad = CAGradientLayer()
        ringGrad.colors = [ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
                           ColorConfig_Hush.primaryGradientEnd_Hush.cgColor]
        ringGrad.startPoint = CGPoint(x: 0, y: 0)
        ringGrad.endPoint = CGPoint(x: 1, y: 1)
        ringGrad.cornerRadius = 53
        avatarRingView_Hush.layer.insertSublayer(ringGrad, at: 0)
        ringGradient_Hush = ringGrad

        // 关注按钮渐变（初始状态）
        let followGrad = CAGradientLayer()
        followGrad.colors = [ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
                             ColorConfig_Hush.primaryGradientEnd_Hush.cgColor]
        followGrad.startPoint = CGPoint(x: 0, y: 0.5)
        followGrad.endPoint = CGPoint(x: 1, y: 0.5)
        followGrad.cornerRadius = 20
        followButton_Hush.layer.insertSublayer(followGrad, at: 0)
        followGradient_Hush = followGrad
    }

    /// 构建统计数据视图
    private func makeStatView_Hush(title: String) -> UIView {
        let container = UIView()
        let valueLabel = UILabel()
        valueLabel.text = "0"
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = ColorConfig_Hush.textPrimary_Hush
        valueLabel.textAlignment = .center
        valueLabel.tag = 101

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = ColorConfig_Hush.textSecondary_Hush
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.center.equalToSuperview() }
        return container
    }

    private func updateStat_Hush(view: UIView, value: String) {
        (view.viewWithTag(101) as? UILabel)?.text = value
    }

    // MARK: - 数据配置

    /// 配置头部视图数据
    /// - Parameters:
    ///   - user_hush: 目标用户数据
    ///   - isFollowing_hush: 当前登录用户是否已关注目标用户
    ///   - fromChat_hush: 是否从聊天页进入（决定是否显示消息按钮）
    func configure_Hush(user_hush: PrewUserModel_Hush, isFollowing_hush: Bool, fromChat_hush: Bool) {
        if let userId = user_hush.userId_Hush {
            avatarView_Hush.configure_Hush(userId_Hush: userId)
        }
        nameLabel_Hush.text = user_hush.userName_Hush ?? "User"
        bioLabel_Hush.text = user_hush.userIntroduce_Hush?.isEmpty == false
            ? user_hush.userIntroduce_Hush
            : "No bio yet"
        updateStat_Hush(view: followingStatView_Hush, value: "\(user_hush.userFollow_Hush ?? 0)")
        updateStat_Hush(view: fansStatView_Hush, value: "\(user_hush.userFans_Hush ?? 0)")
        updateFollowButtonStyle_Hush(isFollowing: isFollowing_hush)

        // fromChat 时消息按钮隐藏，关注按钮独占整行
        messageButton_Hush.isHidden = fromChat_hush
        if fromChat_hush {
            buttonStack_Hush.distribution = .fill
            followButton_Hush.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    /// 更新关注按钮样式（已关注：描边样式；未关注：渐变填充）
    func updateFollowButtonStyle_Hush(isFollowing: Bool) {
        if isFollowing {
            followGradient_Hush?.isHidden = true
            followButton_Hush.setTitle("Followed", for: .normal)
            followButton_Hush.setTitleColor(ColorConfig_Hush.primaryGradientStart_Hush, for: .normal)
            followButton_Hush.layer.borderWidth = 1.5
            followButton_Hush.layer.borderColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
            followButton_Hush.backgroundColor = .white
        } else {
            followGradient_Hush?.isHidden = false
            followButton_Hush.setTitle("Follow", for: .normal)
            followButton_Hush.setTitleColor(.white, for: .normal)
            followButton_Hush.layer.borderWidth = 0
            followButton_Hush.backgroundColor = .clear
        }
    }

    // MARK: - 事件处理

    @objc private func handleFollowTapped_Hush() {
        followButton_Hush.animatePressDown_Hush {
            self.followButton_Hush.animatePressUp_Hush {
                self.onFollowTapped_Hush?()
            }
        }
    }

    @objc private func handleMessageTapped_Hush() {
        messageButton_Hush.animatePressDown_Hush {
            self.messageButton_Hush.animatePressUp_Hush {
                self.onMessageTapped_Hush?()
            }
        }
    }
}

// MARK: - 用户中心视图控制器

/// 用户中心页面
/// 功能：展示目标用户信息及其发布的帖子，支持关注/取消关注、发消息（带确认弹窗）、举报拉黑
/// 设计：UICollectionView + 自定义头部，监听用户/帖子状态通知实时刷新
/// 关键属性：
///   - userModel_Hush：目标用户模型（必须设置）
///   - fromChat_Hush：是否从聊天页进入（影响按钮布局）
///   - onUnfollowInChatContext_Hush：从聊天进入时取消关注的回调
class UserInfo_Hush: UIViewController {

    // MARK: - 外部属性

    var userModel_Hush: PrewUserModel_Hush?
    var fromChat_Hush: Bool = false
    var onUnfollowInChatContext_Hush: (() -> Void)?

    // MARK: - 私有属性

    private var displayPosts_Hush: [TitleModel_Hush] = []

    // 确认进入聊天弹窗的遮罩与卡片
    private var _sheetOverlay_Hush: UIView?
    private var _sheetCard_Hush: UIView?
    private var _sheetCardBottomConstraint_Hush: Constraint?

    // MARK: - UI 组件

    private let navBarView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        return v
    }()

    private let backButton_Hush = BackButton_Hush()

    private let navTitleLabel_Hush: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = ColorConfig_Hush.textPrimary_Hush
        return lbl
    }()

    /// 右上角拉黑按钮（举报/拉黑用户）
    private let blockButton_Hush: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        btn.tintColor = ColorConfig_Hush.textSecondary_Hush
        btn.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        btn.layer.cornerRadius = 18
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.layer.shadowOpacity = 1
        return btn
    }()

    private lazy var collectionView_Hush: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 24, right: 8)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(UserInfoPostCell_Hush.self, forCellWithReuseIdentifier: UserInfoPostCell_Hush.reuseId_Hush)
        cv.register(
            UserInfoHeaderView_Hush.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: UserInfoHeaderView_Hush.reuseId_Hush
        )
        return cv
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Hush()
        setupNotifications_Hush()
        updateData_Hush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏系统导航栏，使用自定义导航栏，避免双层导航栏叠加
        navigationController?.setNavigationBarHidden(true, animated: false)
        collectionView_Hush.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 离开时恢复系统导航栏（帖子详情等页面使用系统导航栏）
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush

        view.addSubview(navBarView_Hush)
        navBarView_Hush.addSubview(backButton_Hush)
        navBarView_Hush.addSubview(navTitleLabel_Hush)
        navBarView_Hush.addSubview(blockButton_Hush)

        navBarView_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        backButton_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        navTitleLabel_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        blockButton_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        backButton_Hush.onTapped_Hush = { [weak self] in
            Navigation_Hush.pop_Hush(from: self)
        }
        blockButton_Hush.addTarget(self, action: #selector(handleBlockTapped_Hush), for: .touchUpInside)

        navTitleLabel_Hush.text = userModel_Hush?.userName_Hush ?? "User"

        view.addSubview(collectionView_Hush)
        collectionView_Hush.snp.makeConstraints { make in
            make.top.equalTo(navBarView_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 通知监听

    private func setupNotifications_Hush() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Hush),
            name: UserViewModel_Hush.userStateDidChangeNotification_Hush,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Hush),
            name: TitleViewModel_Hush.titleStateDidChangeNotification_Hush,
            object: nil
        )
    }

    @objc private func handleStateChange_Hush() {
        updateData_Hush()
    }

    // MARK: - 数据更新

    private func updateData_Hush() {
        guard let userId = userModel_Hush?.userId_Hush else { return }
        // 从 LocalData 刷新最新用户数据，确保关注数/粉丝数实时更新
        let freshUser = UserViewModel_Hush.shared_Hush.getUserById_Hush(userId_hush: userId)
        userModel_Hush = freshUser
        displayPosts_Hush = TitleViewModel_Hush.shared_Hush.getUserPosts_Hush(user_hush: freshUser, type_hush: nil)
        collectionView_Hush.reloadData()
    }

    // MARK: - 事件处理

    /// 关注/取消关注操作
    private func handleFollowAction_Hush() {
        guard let user = userModel_Hush else { return }

        if !UserViewModel_Hush.shared_Hush.isLoggedIn_Hush {
            Navigation_Hush.toLogin_Hush(style_hush: .present_hush)
            return
        }

        let wasFollowing = UserViewModel_Hush.shared_Hush.isFollowing_Hush(user_hush: user)
        UserViewModel_Hush.shared_Hush.followUser_Hush(user_hush: user)

        // 如果是从聊天页进入且取消了关注，触发回调
        if wasFollowing && fromChat_Hush {
            onUnfollowInChatContext_Hush?()
        }
    }

    /// 点击消息按钮：已关注则弹出确认进入聊天弹窗，未关注提示先关注
    private func handleMessageAction_Hush() {
        guard let user = userModel_Hush else { return }

        if !UserViewModel_Hush.shared_Hush.isLoggedIn_Hush {
            Navigation_Hush.toLogin_Hush(style_hush: .present_hush)
            return
        }

        if UserViewModel_Hush.shared_Hush.isFollowing_Hush(user_hush: user) {
            presentConfirmChatSheet_hush(user: user)
        } else {
            Utils_Hush.showWarning_Hush(message_Hush: "Follow this user first to send a message.")
        }
    }

    @objc private func handleBlockTapped_Hush() {
        guard let user = userModel_Hush else { return }
        blockButton_Hush.animatePressDown_Hush {
            self.blockButton_Hush.animatePressUp_Hush {
                ReportDeleteHelper_Hush.block_Hush(user_Hush: user, from: self) { [weak self] in
                    guard let self = self else { return }
                    Navigation_Hush.popToSafeStateAfterBlock_Hush(from: self)
                }
            }
        }
    }

    // MARK: - 确认进入聊天弹窗

    /// 呈现底部弹窗，展示用户信息并确认是否进入聊天
    /// - Parameter user: 目标用户
    private func presentConfirmChatSheet_hush(user: PrewUserModel_Hush) {
        // 防止重复呈现
        guard _sheetOverlay_Hush == nil else { return }

        // 半透明遮罩
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.alpha = 0
        view.addSubview(overlay)
        overlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        _sheetOverlay_Hush = overlay

        // 底部卡片
        let card = UIView()
        card.backgroundColor = ColorConfig_Hush.backgroundSecondary_Hush
        card.layer.cornerRadius = 24
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            self._sheetCardBottomConstraint_Hush = make.bottom.equalToSuperview().offset(400).constraint
        }
        _sheetCard_Hush = card

        buildSheetContent_Hush(in: card, user: user)

        // 点击遮罩关闭弹窗
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissConfirmChatSheet_hush))
        overlay.addGestureRecognizer(tap)

        // 动画呈现
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            overlay.alpha = 1
            self._sheetCardBottomConstraint_Hush?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    /// 构建确认进入聊天弹窗内容
    private func buildSheetContent_Hush(in card: UIView, user: PrewUserModel_Hush) {
        let handleBar = UIView()
        handleBar.backgroundColor = ColorConfig_Hush.border_Hush
        handleBar.layer.cornerRadius = 2
        card.addSubview(handleBar)
        handleBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }

        // 用户头像
        let avatarView = UserAvatarView_Hush()
        avatarView.layer.cornerRadius = 36
        avatarView.clipsToBounds = true
        if let userId = user.userId_Hush {
            avatarView.configure_Hush(userId_Hush: userId)
        }

        // 渐变头像环
        let avatarRing = UIView()
        avatarRing.layer.cornerRadius = 42
        let ringGrad = CAGradientLayer()
        ringGrad.colors = [ColorConfig_Hush.secondaryGradientStart_Hush.cgColor,
                           ColorConfig_Hush.secondaryGradientEnd_Hush.cgColor]
        ringGrad.startPoint = CGPoint(x: 0, y: 0)
        ringGrad.endPoint = CGPoint(x: 1, y: 1)
        ringGrad.cornerRadius = 42
        avatarRing.layer.insertSublayer(ringGrad, at: 0)
        card.addSubview(avatarRing)
        avatarRing.addSubview(avatarView)

        avatarRing.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(84)
        }
        DispatchQueue.main.async { ringGrad.frame = avatarRing.bounds }
        avatarView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(72)
        }

        let nameLabel = UILabel()
        nameLabel.text = user.userName_Hush ?? "User"
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = ColorConfig_Hush.textPrimary_Hush
        nameLabel.textAlignment = .center
        card.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarRing.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        let bioLabel = UILabel()
        bioLabel.text = user.userIntroduce_Hush?.isEmpty == false ? user.userIntroduce_Hush : "Hey there! I'm using Hush."
        bioLabel.font = UIFont.systemFont(ofSize: 13)
        bioLabel.textColor = ColorConfig_Hush.textSecondary_Hush
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 3
        card.addSubview(bioLabel)
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        // Start Chat 按钮（渐变）
        let startChatBtn = UIButton()
        startChatBtn.setTitle("Start Chat", for: .normal)
        startChatBtn.setTitleColor(.white, for: .normal)
        startChatBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        startChatBtn.layer.cornerRadius = 24
        startChatBtn.clipsToBounds = true
        let chatGrad = CAGradientLayer()
        chatGrad.colors = [ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
                           ColorConfig_Hush.primaryGradientEnd_Hush.cgColor]
        chatGrad.startPoint = CGPoint(x: 0, y: 0.5)
        chatGrad.endPoint = CGPoint(x: 1, y: 0.5)
        chatGrad.cornerRadius = 24
        startChatBtn.layer.insertSublayer(chatGrad, at: 0)
        card.addSubview(startChatBtn)
        startChatBtn.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        DispatchQueue.main.async { chatGrad.frame = startChatBtn.bounds }

        // Cancel 按钮
        let cancelBtn = UIButton()
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(ColorConfig_Hush.textSecondary_Hush, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        card.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(startChatBtn.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalTo(card.safeAreaLayoutGuide).inset(16)
        }

        // 保存 user 引用，供按钮操作使用
        startChatBtn.tag = user.userId_Hush ?? 0
        startChatBtn.addTarget(self, action: #selector(handleStartChatConfirmed_Hush(_:)), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(dismissConfirmChatSheet_hush), for: .touchUpInside)
    }

    @objc private func handleStartChatConfirmed_Hush(_ sender: UIButton) {
        dismissConfirmChatSheet_hush()
        guard let user = userModel_Hush else { return }
        Navigation_Hush.toMessageUser_Hush(with: user, style_hush: .push_hush, animated_hush: true, completion_hush: nil)
    }

    @objc private func dismissConfirmChatSheet_hush() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self._sheetOverlay_Hush?.alpha = 0
            self._sheetCardBottomConstraint_Hush?.update(offset: 400)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self._sheetOverlay_Hush?.removeFromSuperview()
            self._sheetCard_Hush?.removeFromSuperview()
            self._sheetOverlay_Hush = nil
            self._sheetCard_Hush = nil
        }
    }
}

// MARK: - UICollectionView 数据源与布局

extension UserInfo_Hush: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Hush.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserInfoPostCell_Hush.reuseId_Hush,
            for: indexPath
        ) as! UserInfoPostCell_Hush
        let post = displayPosts_Hush[indexPath.item]
        cell.configure_Hush(post_hush: post, from_hush: self) { [weak self] in
            self?.updateData_Hush()
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: UserInfoHeaderView_Hush.reuseId_Hush,
            for: indexPath
        ) as! UserInfoHeaderView_Hush

        if let user = userModel_Hush {
            let isFollowing = UserViewModel_Hush.shared_Hush.isFollowing_Hush(user_hush: user)
            header.configure_Hush(user_hush: user, isFollowing_hush: isFollowing, fromChat_hush: fromChat_Hush)
        }

        header.onFollowTapped_Hush = { [weak self] in
            self?.handleFollowAction_Hush()
        }
        header.onMessageTapped_Hush = { [weak self] in
            self?.handleMessageAction_Hush()
        }
        return header
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing: CGFloat = 8 + 8 + 8
        let itemWidth = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: itemWidth, height: itemWidth * 1.25)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let header = UserInfoHeaderView_Hush()
        if let user = userModel_Hush {
            let isFollowing = UserViewModel_Hush.shared_Hush.isFollowing_Hush(user_hush: user)
            header.configure_Hush(user_hush: user, isFollowing_hush: isFollowing, fromChat_hush: fromChat_Hush)
        }
        let size = header.systemLayoutSizeFitting(
            CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: collectionView.bounds.width, height: size.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = displayPosts_Hush[indexPath.item]
        Navigation_Hush.toTitleDetail_Hush(titleModel_hush: post, style_hush: .push_hush, animated_hush: true)
    }
}
