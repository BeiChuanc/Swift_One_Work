import Foundation
import UIKit
import SnapKit

// MARK: - 统计数据项视图

/// 个人中心统计项视图
/// 核心作用：展示一个统计数值（帖子数/喜欢数/关注数）及对应标签，含 emoji 装饰
/// 关键属性：valueLabel_Trace（数值），titleLabel_Trace（标签文字），emojiLabel_Trace（表情装饰）
class StatItemView_Trace: UIView {

    // MARK: - UI 组件

    /// 顶部 emoji 装饰
    private let emojiLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .center
        return lbl
    }()

    /// 数值（粗体大字）
    private let valueLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    /// 标签文字
    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.72)
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        addSubview(emojiLabel_Trace)
        addSubview(valueLabel_Trace)
        addSubview(titleLabel_Trace)

        emojiLabel_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-22)
        }

        valueLabel_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emojiLabel_Trace.snp.bottom).offset(2)
        }

        titleLabel_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(valueLabel_Trace.snp.bottom).offset(3)
        }
    }

    // MARK: - 公共方法

    /// 配置初始数值、标签文字和 emoji
    /// - Parameters:
    ///   - value_trace: 显示的数值字符串
    ///   - label_trace: 标签文字
    ///   - emoji_trace: 装饰 emoji
    func configure_Trace(value_trace: String, label_trace: String, emoji_trace: String) {
        valueLabel_Trace.text = value_trace
        titleLabel_Trace.text = label_trace
        emojiLabel_Trace.text = emoji_trace
    }

    /// 刷新数值显示
    /// - Parameter value_trace: 新的数值字符串
    func updateValue_Trace(value_trace: String) {
        valueLabel_Trace.text = value_trace
    }
}

// MARK: - 帖子网格 Cell

/// 个人中心帖子网格卡片 Cell
/// 核心作用：以紧凑卡片形式展示帖子媒体封面（MediaDisplayView_Trace）、标签徽章、标题和点赞数
/// 关键属性：configure_Trace（配置帖子数据和点赞状态）
/// 关键方法：onReportTapped_Trace（非 nil 时右上角显示举报按钮，适用于他人主页场景）
class MePostCell_Trace: UICollectionViewCell {

    // MARK: - UI 组件

    /// 卡片白色容器（阴影 + 圆角）
    private let cardView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor(hexstring_Trace: "#B794F6").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.12
        v.layer.masksToBounds = false
        return v
    }()

    /// 媒体展示视图（顶部封面区域）
    private let mediaView_Trace: MediaDisplayView_Trace = {
        let v = MediaDisplayView_Trace()
        v.layer.cornerRadius = 14
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// Tag 徽章（悬浮在媒体区右下角）
    private let tagBadge_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        v.layer.cornerRadius = 7
        v.layer.masksToBounds = true
        return v
    }()

    private let tagBadgeLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    /// 举报按钮（右上角，onReportTapped_Trace 非 nil 时可见）
    /// 使用 createUserReportButton_Trace 统一图标样式，点击事件通过回调委托给外部 VC 处理
    private lazy var reportBtn_Trace: UIButton = {
        let btn = ReportDeleteHelper_Trace.createUserReportButton_Trace(
            size_Trace: 26,
            backgroundColor_Trace: UIColor.black.withAlphaComponent(0.35),
            tintColor_Trace: .white,
            withShadow_Trace: false
        )
        btn.addTarget(self, action: #selector(handleReportTap_Trace), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    /// 帖子标题
    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 点赞图标
    private let likeIconView_Trace: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.fill")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 点赞数量
    private let likeCountLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl
    }()

    // MARK: - 回调

    /// 举报按钮点击回调；设置后举报按钮自动显示，nil 时隐藏
    var onReportTapped_Trace: ((TitleModel_Trace) -> Void)? {
        didSet { reportBtn_Trace.isHidden = (onReportTapped_Trace == nil) }
    }

    // MARK: - 私有属性

    private var post_Trace: TitleModel_Trace?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        backgroundColor = .clear

        contentView.addSubview(cardView_Trace)
        cardView_Trace.addSubview(mediaView_Trace)
        // Tag 徽章覆盖在媒体视图右下角
        cardView_Trace.addSubview(tagBadge_Trace)
        tagBadge_Trace.addSubview(tagBadgeLabel_Trace)
        // 举报按钮覆盖在媒体视图右上角
        cardView_Trace.addSubview(reportBtn_Trace)
        cardView_Trace.addSubview(titleLabel_Trace)
        cardView_Trace.addSubview(likeIconView_Trace)
        cardView_Trace.addSubview(likeCountLabel_Trace)

        cardView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.52)
        }

        // Tag 徽章：媒体区右下角
        tagBadge_Trace.snp.makeConstraints { make in
            make.bottom.equalTo(mediaView_Trace.snp.bottom).offset(-6)
            make.trailing.equalToSuperview().offset(-7)
            make.height.equalTo(15)
        }

        tagBadgeLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
        }

        // 举报按钮：媒体区右上角
        reportBtn_Trace.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Trace.snp.top).offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.width.height.equalTo(26)
        }

        titleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Trace.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        likeIconView_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(12)
        }

        likeCountLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(likeIconView_Trace.snp.trailing).offset(3)
            make.centerY.equalTo(likeIconView_Trace)
        }
    }

    // MARK: - 配置

    /// 配置 Cell 展示数据
    /// - Parameters:
    ///   - post_trace: 帖子数据模型
    ///   - isLiked_trace: 当前用户是否已点赞
    func configure_Trace(post_trace: TitleModel_Trace, isLiked_trace: Bool) {
        post_Trace = post_trace

        // 媒体封面：取第一张媒体资源（图片优先）
        let mediaPath_trace = post_trace.titleMeidas_Trace.first
        mediaView_Trace.configure_Trace(mediaPath_Trace: mediaPath_trace, isVideo_Trace: false)

        tagBadgeLabel_Trace.text = post_trace.titleTag_Trace
        titleLabel_Trace.text = post_trace.title_Trace
        likeCountLabel_Trace.text = "\(post_trace.likes_Trace)"
        likeIconView_Trace.tintColor = isLiked_trace
            ? UIColor(hexstring_Trace: "#FC8181")
            : ColorConfig_Trace.textPlaceholder_Trace
    }

    // MARK: - 事件

    /// 举报按钮点击，将事件透传给外部 VC 处理
    @objc private func handleReportTap_Trace() {
        guard let post_Trace = post_Trace else { return }
        onReportTapped_Trace?(post_Trace)
    }
}

// MARK: - 个人中心主页

/// 个人中心页面
/// 核心作用：展示登录用户的头像、名称、简介、统计数据，以及发布/喜欢帖子切换网格
/// 设计思路：渐变紫蓝头部 + 浮岛式内容卡片 + 胶囊 Tab 切换 + 双列帖子网格
/// 关键属性：meModel_Trace（用户模型），currentTab_Trace（当前 Tab 0=Posts/1=Liked）
class Me_Trace: UIViewController {

    // MARK: - 属性

    var meModel_Trace: LoginUserModel_Trace?
    private var currentTab_Trace: Int = 0
    private var displayPosts_Trace: [TitleModel_Trace] = []

    // MARK: - UI 组件

    private let scrollView_Trace: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        return v
    }()

    // MARK: 渐变头部

    private let headerView_Trace: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private let headerGradientLayer_Trace = CAGradientLayer()

    /// 装饰圆（大）
    private let decorCircle1_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 90
        return v
    }()

    /// 装饰圆（中）
    private let decorCircle2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 65
        return v
    }()

    /// 装饰圆（小，右下）
    private let decorCircle3_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 40
        return v
    }()

    /// 头部顶部星点装饰（散落小点）
    private let dotPatternView_Trace: UIView = UIView()

    private let backButton_Trace = BackButton_Trace()

    private let settingButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        btn.layer.borderWidth = 1
        return btn
    }()

    // MARK: 头像区

    /// 头像外圈渐变环
    private let avatarRingView_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 56
        v.layer.masksToBounds = true
        return v
    }()

    private let avatarRingGradientLayer_Trace = CAGradientLayer()

    /// 头像白色内边框
    private let avatarBorderView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 53
        return v
    }()

    private let avatarView_Trace: CurrentUserAvatarView_Trace = {
        let v = CurrentUserAvatarView_Trace()
        return v
    }()

    private let nameLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    private let bioLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.82)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    private let editButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 17
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        btn.layer.borderWidth = 1.5
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        btn.setImage(UIImage(systemName: "pencil", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Edit Profile", for: .normal)
        btn.tintColor = .white
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return btn
    }()

    // MARK: 统计栏（毛玻璃）

    private let statsContainerView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        v.layer.cornerRadius = 22
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        v.layer.borderWidth = 1
        return v
    }()

    private let postsStatView_Trace = StatItemView_Trace()
    private let likedStatView_Trace = StatItemView_Trace()
    private let followingStatView_Trace = StatItemView_Trace()

    // MARK: 浮岛内容区（白色圆角覆盖层）

    private let contentIslandView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -4)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.06
        v.layer.masksToBounds = false
        return v
    }()

    // MARK: 胶囊 Tab 切换

    private let tabContainerView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Trace: "#EDE8FF")
        v.layer.cornerRadius = 14
        v.layer.masksToBounds = false
        return v
    }()

    /// 滑动胶囊（选中项背景）
    private let tabPillView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 10
        v.layer.shadowColor = UIColor(hexstring_Trace: "#B794F6").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 0.18
        v.layer.masksToBounds = false
        return v
    }()

    private let postsTabButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn.setImage(UIImage(systemName: "square.grid.2x2.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Posts", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn.setTitleColor(ColorConfig_Trace.primaryGradientStart_Trace, for: .normal)
        btn.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        btn.tag = 0
        return btn
    }()

    private let likedTabButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Liked", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        btn.setTitleColor(ColorConfig_Trace.textPlaceholder_Trace, for: .normal)
        btn.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        btn.tag = 1
        return btn
    }()

    // MARK: 帖子网格

    private lazy var postsCollectionView_Trace: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 14
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.register(MePostCell_Trace.self, forCellWithReuseIdentifier: "MePostCell_Trace")
        return cv
    }()

    // MARK: 空状态

    private let emptyView_Trace: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    /// 空状态渐变背景圆
    private let emptyIconBg_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 38
        v.layer.masksToBounds = true
        return v
    }()

    private let emptyIconBgGradient_Trace = CAGradientLayer()

    private let emptyIconView_Trace: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let emptyTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl.textAlignment = .center
        return lbl
    }()

    private let emptySubLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    private var collectionViewHeightConstraint_Trace: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        backButton_Trace.isHidden = (navigationController?.viewControllers.count ?? 0) <= 1
        refreshData_Trace()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        bindActions_Trace()
        registerNotifications_Trace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Trace.frame = headerView_Trace.bounds
        avatarRingGradientLayer_Trace.frame = avatarRingView_Trace.bounds
        emptyIconBgGradient_Trace.frame = emptyIconBg_Trace.bounds
        updateCollectionViewHeight_Trace()
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace

        // 头部渐变（紫 → 蓝绿）
        headerGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#4DB8D4").cgColor
        ]
        headerGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        headerView_Trace.layer.insertSublayer(headerGradientLayer_Trace, at: 0)

        // 头像彩色外环（渐变）
        avatarRingGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#FBB6CE").cgColor,
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#90CDF4").cgColor
        ]
        avatarRingGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        avatarRingGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        avatarRingGradientLayer_Trace.cornerRadius = 56
        avatarRingView_Trace.layer.insertSublayer(avatarRingGradientLayer_Trace, at: 0)

        // 空状态渐变背景
        emptyIconBgGradient_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").withAlphaComponent(0.25).cgColor,
            UIColor(hexstring_Trace: "#90CDF4").withAlphaComponent(0.15).cgColor
        ]
        emptyIconBgGradient_Trace.startPoint = CGPoint(x: 0, y: 0)
        emptyIconBgGradient_Trace.endPoint = CGPoint(x: 1, y: 1)
        emptyIconBg_Trace.layer.insertSublayer(emptyIconBgGradient_Trace, at: 0)

        // 层级组装
        view.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(contentView_Trace)

        contentView_Trace.addSubview(headerView_Trace)
        headerView_Trace.addSubview(decorCircle1_Trace)
        headerView_Trace.addSubview(decorCircle2_Trace)
        headerView_Trace.addSubview(decorCircle3_Trace)
        headerView_Trace.addSubview(dotPatternView_Trace)
        headerView_Trace.addSubview(backButton_Trace)
        headerView_Trace.addSubview(settingButton_Trace)
        headerView_Trace.addSubview(avatarRingView_Trace)
        avatarRingView_Trace.addSubview(avatarBorderView_Trace)
        avatarBorderView_Trace.addSubview(avatarView_Trace)
        headerView_Trace.addSubview(nameLabel_Trace)
        headerView_Trace.addSubview(bioLabel_Trace)
        headerView_Trace.addSubview(editButton_Trace)
        headerView_Trace.addSubview(statsContainerView_Trace)

        // 统计分隔线
        let divider1_trace = buildStatDivider_Trace()
        let divider2_trace = buildStatDivider_Trace()
        statsContainerView_Trace.addSubview(postsStatView_Trace)
        statsContainerView_Trace.addSubview(divider1_trace)
        statsContainerView_Trace.addSubview(likedStatView_Trace)
        statsContainerView_Trace.addSubview(divider2_trace)
        statsContainerView_Trace.addSubview(followingStatView_Trace)
        postsStatView_Trace.configure_Trace(value_trace: "0", label_trace: "Posts", emoji_trace: "📝")
        likedStatView_Trace.configure_Trace(value_trace: "0", label_trace: "Liked", emoji_trace: "❤️")
        followingStatView_Trace.configure_Trace(value_trace: "0", label_trace: "Following", emoji_trace: "👥")

        // 浮岛内容区
        contentView_Trace.addSubview(contentIslandView_Trace)

        // 胶囊 Tab（pill在按钮后面）
        contentIslandView_Trace.addSubview(tabContainerView_Trace)
        tabContainerView_Trace.addSubview(tabPillView_Trace)
        tabContainerView_Trace.addSubview(postsTabButton_Trace)
        tabContainerView_Trace.addSubview(likedTabButton_Trace)

        // 帖子网格
        contentIslandView_Trace.addSubview(postsCollectionView_Trace)
        postsCollectionView_Trace.delegate = self
        postsCollectionView_Trace.dataSource = self

        // 空状态
        contentIslandView_Trace.addSubview(emptyView_Trace)
        emptyView_Trace.addSubview(emptyIconBg_Trace)
        emptyIconBg_Trace.addSubview(emptyIconView_Trace)
        emptyView_Trace.addSubview(emptyTitleLabel_Trace)
        emptyView_Trace.addSubview(emptySubLabel_Trace)

        // 散点装饰
        addDotDecorations_Trace()

        buildConstraints_Trace(divider1: divider1_trace, divider2: divider2_trace)
    }

    /// 在头部添加随机散点装饰
    private func addDotDecorations_Trace() {
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (0.15, 0.2, 4), (0.35, 0.08, 3), (0.7, 0.15, 5),
            (0.85, 0.35, 3), (0.55, 0.72, 4), (0.2, 0.6, 3)
        ]
        for (rx, ry, size) in positions {
            let dot = UIView()
            dot.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            dot.layer.cornerRadius = size / 2
            dotPatternView_Trace.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.width.height.equalTo(size)
                make.leading.equalToSuperview().multipliedBy(rx)
                make.top.equalToSuperview().multipliedBy(ry)
            }
        }
    }

    private func buildStatDivider_Trace() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.32)
        return v
    }

    private func buildConstraints_Trace(divider1: UIView, divider2: UIView) {
        scrollView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        headerView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        decorCircle1_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.trailing.equalToSuperview().offset(50)
            make.width.height.equalTo(180)
        }

        decorCircle2_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(-40)
            make.width.height.equalTo(130)
        }

        decorCircle3_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.trailing.equalToSuperview().offset(-60)
            make.width.height.equalTo(80)
        }

        dotPatternView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.width.height.equalTo(44)
        }

        settingButton_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backButton_Trace)
            make.width.height.equalTo(36)
        }

        // 头像外环 → 白边框 → 头像
        avatarRingView_Trace.snp.makeConstraints { make in
            make.top.equalTo(backButton_Trace.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(112)
        }

        avatarBorderView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(106)
        }

        avatarView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }

        nameLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Trace.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        bioLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Trace.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(30)
        }

        editButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Trace.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
        }

        statsContainerView_Trace.snp.makeConstraints { make in
            make.top.equalTo(editButton_Trace.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(82)
            make.bottom.equalToSuperview().offset(-36)
        }

        postsStatView_Trace.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }

        divider1.snp.makeConstraints { make in
            make.leading.equalTo(postsStatView_Trace.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(36)
        }

        likedStatView_Trace.snp.makeConstraints { make in
            make.leading.equalTo(divider1.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }

        divider2.snp.makeConstraints { make in
            make.leading.equalTo(likedStatView_Trace.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(36)
        }

        followingStatView_Trace.snp.makeConstraints { make in
            make.leading.equalTo(divider2.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }

        // 浮岛覆盖头部底部 24pt
        contentIslandView_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerView_Trace.snp.bottom).offset(-24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 胶囊 Tab
        tabContainerView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        tabPillView_Trace.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalTo(postsTabButton_Trace.snp.leading).offset(4)
            make.trailing.equalTo(postsTabButton_Trace.snp.trailing).offset(-4)
        }

        postsTabButton_Trace.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }

        likedTabButton_Trace.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }

        // 帖子网格
        postsCollectionView_Trace.snp.makeConstraints { make in
            make.top.equalTo(tabContainerView_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            collectionViewHeightConstraint_Trace = make.height.equalTo(200).constraint
            make.bottom.equalToSuperview().offset(-30)
        }

        // 空状态（叠在 collectionView 区域上方）
        emptyView_Trace.snp.makeConstraints { make in
            make.top.equalTo(tabContainerView_Trace.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
        }

        emptyIconBg_Trace.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(76)
        }

        emptyIconView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(34)
        }

        emptyTitleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(emptyIconBg_Trace.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        emptySubLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Trace.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据刷新

    private func refreshData_Trace() {
        let user_trace = meModel_Trace ?? UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()
        meModel_Trace = user_trace

        if let userId_trace = user_trace.userId_Trace {
            avatarView_Trace.configure_Trace(userId_Trace: userId_trace)
        }

        nameLabel_Trace.text = user_trace.userName_Trace ?? "User"

        let intro_trace = user_trace.userIntroduce_Trace
        bioLabel_Trace.text = (intro_trace != nil && !intro_trace!.isEmpty)
            ? intro_trace
            : "Living my trace ✨"

        postsStatView_Trace.updateValue_Trace(value_trace: "\(user_trace.userPosts_Trace.count)")
        likedStatView_Trace.updateValue_Trace(value_trace: "\(user_trace.userLike_Trace.count)")
        followingStatView_Trace.updateValue_Trace(value_trace: "\(user_trace.userFollow_Trace.count)")

        reloadPostsDisplay_Trace()
    }

    private func reloadPostsDisplay_Trace() {
        guard let user_trace = meModel_Trace else { return }

        displayPosts_Trace = currentTab_Trace == 0
            ? user_trace.userPosts_Trace
            : user_trace.userLike_Trace

        postsCollectionView_Trace.reloadData()

        let isEmpty_trace = displayPosts_Trace.isEmpty
        emptyView_Trace.isHidden = !isEmpty_trace
        postsCollectionView_Trace.alpha = isEmpty_trace ? 0 : 1

        if isEmpty_trace {
            if currentTab_Trace == 0 {
                emptyIconView_Trace.image = UIImage(systemName: "square.and.pencil")
                emptyTitleLabel_Trace.text = "No posts yet"
                emptySubLabel_Trace.text = "Share a moment and let your story begin"
            } else {
                emptyIconView_Trace.image = UIImage(systemName: "heart.text.square")
                emptyTitleLabel_Trace.text = "Nothing liked yet"
                emptySubLabel_Trace.text = "Explore posts and tap ❤️ to save your favorites"
            }
        }

        updateCollectionViewHeight_Trace()
    }

    private func updateCollectionViewHeight_Trace() {
        if displayPosts_Trace.isEmpty {
            collectionViewHeightConstraint_Trace?.update(offset: 220)
            return
        }
        let cols: CGFloat = 2
        let spacing: CGFloat = 12
        let sideInset: CGFloat = 32
        let cellWidth_trace = (view.bounds.width - sideInset - spacing) / cols
        let cellHeight_trace = cellWidth_trace * 1.42
        let rows_trace = ceil(Double(displayPosts_Trace.count) / 2.0)
        let total_trace = CGFloat(rows_trace) * cellHeight_trace + (CGFloat(rows_trace) - 1) * 14
        collectionViewHeightConstraint_Trace?.update(offset: total_trace)
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        backButton_Trace.onTapped_Trace = {
            Navigation_Trace.pop_Trace()
        }
        settingButton_Trace.addTarget(self, action: #selector(handleSettingTap_Trace), for: .touchUpInside)
        editButton_Trace.addTarget(self, action: #selector(handleEditTap_Trace), for: .touchUpInside)
        postsTabButton_Trace.addTarget(self, action: #selector(handleTabSwitch_Trace(_:)), for: .touchUpInside)
        likedTabButton_Trace.addTarget(self, action: #selector(handleTabSwitch_Trace(_:)), for: .touchUpInside)
    }

    private func registerNotifications_Trace() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Trace),
            name: UserViewModel_Trace.userStateDidChangeNotification_Trace,
            object: nil
        )
    }

    // MARK: - 事件处理

    @objc private func handleSettingTap_Trace() {
        settingButton_Trace.animatePulse_Trace()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Trace.toSetting_Trace()
    }

    @objc private func handleEditTap_Trace() {
        editButton_Trace.animatePressDown_Trace {
            self.editButton_Trace.animatePressUp_Trace()
        }
        Navigation_Trace.toEditInfo_Trace()
    }

    @objc private func handleTabSwitch_Trace(_ sender: UIButton) {
        let newTab_trace = sender.tag
        guard newTab_trace != currentTab_Trace else { return }
        currentTab_Trace = newTab_trace

        // 胶囊滑动弹性动画
        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.4,
            options: [.curveEaseInOut]
        ) {
            let target_trace = newTab_trace == 0 ? self.postsTabButton_Trace : self.likedTabButton_Trace
            self.tabPillView_Trace.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.leading.equalTo(target_trace.snp.leading).offset(4)
                make.trailing.equalTo(target_trace.snp.trailing).offset(-4)
            }
            self.tabContainerView_Trace.layoutIfNeeded()
        }

        updateTabButtonStyle_Trace(selectedTab_trace: newTab_trace)
        reloadPostsDisplay_Trace()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func updateTabButtonStyle_Trace(selectedTab_trace: Int) {
        let activeColor = ColorConfig_Trace.primaryGradientStart_Trace
        let inactiveColor = ColorConfig_Trace.textPlaceholder_Trace

        postsTabButton_Trace.titleLabel?.font = UIFont.systemFont(
            ofSize: 13, weight: selectedTab_trace == 0 ? .bold : .regular
        )
        postsTabButton_Trace.setTitleColor(selectedTab_trace == 0 ? activeColor : inactiveColor, for: .normal)
        postsTabButton_Trace.tintColor = selectedTab_trace == 0 ? activeColor : inactiveColor

        likedTabButton_Trace.titleLabel?.font = UIFont.systemFont(
            ofSize: 13, weight: selectedTab_trace == 1 ? .bold : .regular
        )
        likedTabButton_Trace.setTitleColor(selectedTab_trace == 1 ? activeColor : inactiveColor, for: .normal)
        likedTabButton_Trace.tintColor = selectedTab_trace == 1 ? activeColor : inactiveColor
    }

    @objc private func handleUserStateChange_Trace() {
        meModel_Trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()
        refreshData_Trace()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension Me_Trace: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Trace.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell_trace = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MePostCell_Trace",
            for: indexPath
        ) as? MePostCell_Trace else {
            return UICollectionViewCell()
        }
        let post_trace = displayPosts_Trace[indexPath.item]
        let isLiked_trace = UserViewModel_Trace.shared_Trace.isLikedByCurrentUser_Trace(post_trace: post_trace)
        cell_trace.configure_Trace(post_trace: post_trace, isLiked_trace: isLiked_trace)
        return cell_trace
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cols: CGFloat = 2
        let spacing: CGFloat = 12
        let sideInset: CGFloat = 32
        let width_trace = (view.bounds.width - sideInset - spacing) / cols
        return CGSize(width: width_trace, height: width_trace * 1.18)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_trace = displayPosts_Trace[indexPath.item]
        Navigation_Trace.toTitleDetail_Trace(titleModel_trace: post_trace)
    }
}
