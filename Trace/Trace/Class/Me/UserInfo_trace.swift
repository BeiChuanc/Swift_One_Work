import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页面

/// 用户中心页面（预制用户/他人主页）
/// 核心作用：沉浸式展示他人的主页信息，包含头像、昵称、简介、统计数据及帖子网格
/// 设计思路：全屏渐变沉浸头部 + 浮动圆形导航按钮（返回/举报） + Sheet 式白色内容区 + 帖子网格
/// 关键方法：
///   - setupData_Trace()：填充用户信息到各 UI 组件
///   - reloadPosts_Trace()：从 TitleViewModel 拉取该用户帖子并刷新网格
///   - handleTitleStateChange_Trace()：响应帖子状态通知，自动更新帖子数量与网格
class UserInfo_Trace: UIViewController {

    // MARK: - 外部数据

    /// 外部传入的用户模型，在 viewDidLoad 前赋值
    var userModel_Trace: PrewUserModel_Trace?

    // MARK: - 私有数据

    /// 该用户的帖子列表
    private var posts_Trace: [TitleModel_Trace] = []

    // MARK: - 常量

    /// 帖子 Cell 复用 ID
    private let postCellId_Trace = "UserInfoPostCell_Trace"

    // MARK: - 浮动导航层（覆盖在渐变头部上方）

    private let navOverlayView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 返回按钮（白色半透明圆形）
    private let backBtn_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        btn.layer.cornerRadius = 18
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        btn.layer.borderWidth = 1
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 8
        btn.layer.shadowOpacity = 0.2
        btn.layer.masksToBounds = false
        return btn
    }()

    /// 举报/拉黑按钮（setupData 中创建并添加）
    private var reportBtn_Trace: UIButton?

    // MARK: - 主滚动区域

    private let scrollView_Trace: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        return sv
    }()

    private let contentView_Trace = UIView()

    // MARK: - 渐变头部

    /// 头部渐变容器（全屏宽，高度 260pt）
    private let headerView_Trace: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private let headerGradientLayer_Trace = CAGradientLayer()

    /// 装饰圆圈 1
    private let decorCircle1_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 65
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆圈 2
    private let decorCircle2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 45
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆圈 3（底部光晕）
    private let decorCircle3_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 80
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 底部渐变遮罩（头部→白色过渡）
    private let headerBottomGlowView_Trace: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private let headerBottomGlowLayer_Trace = CAGradientLayer()

    // MARK: 头像区（渐变外环 + 白边 + 头像）

    /// 渐变外环
    private let avatarOuterRingView_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 52
        v.layer.masksToBounds = true
        return v
    }()

    private let avatarRingGradientLayer_Trace = CAGradientLayer()

    /// 白色内边框
    private let avatarInnerBorderView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 46
        return v
    }()

    /// 头像视图
    private let avatarView_Trace: UserAvatarView_Trace = {
        let v = UserAvatarView_Trace()
        v.layer.cornerRadius = 43
        v.layer.masksToBounds = true
        return v
    }()

    /// 头像底部光晕阴影视图（悬浮感增强）
    private let avatarGlowView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 56
        v.layer.shadowColor = UIColor(hexstring_Trace: "#6a11cb").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 18
        v.layer.shadowOpacity = 0.38
        v.layer.masksToBounds = false
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - 信息内容卡片（Sheet 式上浮）

    private let infoSheetView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -6)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.07
        v.layer.masksToBounds = false
        return v
    }()

    /// 拖动指示条
    private let dragIndicatorView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Trace: "#CBD5E0")
        v.layer.cornerRadius = 2.5
        return v
    }()

    /// 用户昵称
    private let nameLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl.textAlignment = .center
        return lbl
    }()

    /// 用户简介
    private let introduceLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textSecondary_Trace
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    // MARK: 统计栏（帖子 / 粉丝 / 关注）

    private let statsContainerView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 18
        v.layer.borderColor = UIColor(hexstring_Trace: "#EEF2FF").cgColor
        v.layer.borderWidth = 1.2
        return v
    }()

    /// 统计栏背景渐变（浅蓝紫到白，与头部色系呼应）
    private let statsGradientLayer_Trace: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Trace: "#EEF2FF").cgColor,
            UIColor(hexstring_Trace: "#F0F9FF").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.cornerRadius = 18
        return g
    }()

    private let postsStatView_Trace = UserStatItemView_Trace()
    private let fansStatView_Trace = UserStatItemView_Trace()
    private let followingStatView_Trace = UserStatItemView_Trace()

    /// 统计栏分割线 1
    private let statsDivider1_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.divider_Trace
        return v
    }()

    /// 统计栏分割线 2
    private let statsDivider2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.divider_Trace
        return v
    }()

    // MARK: 操作按钮区（关注 + 前往聊天）

    /// 关注/取消关注按钮（渐变背景，文字随状态切换）
    private lazy var followBtn_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 22, bottom: 10, right: 22)
        return btn
    }()

    /// 关注按钮渐变背景层
    private let followBtnGradient_Trace: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Trace: "#4A00E0").cgColor,
            UIColor(hexstring_Trace: "#06B6D4").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 0)
        g.cornerRadius = 20
        return g
    }()

    /// 前往聊天按钮（描边风格）
    private lazy var chatBtn_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "bubble.left.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Message", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(UIColor(hexstring_Trace: "#4A00E0"), for: .normal)
        btn.tintColor = UIColor(hexstring_Trace: "#4A00E0")
        btn.backgroundColor = UIColor(hexstring_Trace: "#4A00E0").withAlphaComponent(0.08)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.layer.borderColor = UIColor(hexstring_Trace: "#4A00E0").withAlphaComponent(0.3).cgColor
        btn.layer.borderWidth = 1
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        return btn
    }()

    // MARK: 帖子区

    /// 帖子区标题行
    private let postsSectionView_Trace: UIView = {
        let v = UIView()
        return v
    }()

    /// 帖子版块左侧彩色装饰竖条
    private let postsAccentBar_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    /// 帖子版块装饰条渐变层
    private let postsAccentGradient_Trace: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Trace: "#4A00E0").cgColor,
            UIColor(hexstring_Trace: "#06B6D4").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 0, y: 1)
        g.cornerRadius = 2
        return g
    }()

    private let postsTitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl
    }()

    /// 帖子数量徽章
    private let postsCountBadge_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.12)
        v.layer.cornerRadius = 10
        return v
    }()

    private let postsCountBadgeLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = ColorConfig_Trace.primaryGradientStart_Trace
        return lbl
    }()

    /// 帖子网格（isScrollEnabled=false，高度由内容驱动）
    private lazy var postsCollectionView_Trace: UICollectionView = {
        let itemW_trace = (UIScreen.main.bounds.width - 48) / 2
        let layout_trace = UICollectionViewFlowLayout()
        layout_trace.itemSize = CGSize(width: itemW_trace, height: itemW_trace * 1.18)
        layout_trace.minimumLineSpacing = 12
        layout_trace.minimumInteritemSpacing = 12
        layout_trace.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout_trace)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    /// 帖子网格高度约束（数据加载后动态更新）
    private var postsHeightConstraint_Trace: Constraint?

    /// 空帖子提示
    private let emptyPostsView_Trace: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyPostsEmojiLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "✨"
        lbl.font = UIFont.systemFont(ofSize: 32)
        lbl.textAlignment = .center
        return lbl
    }()

    private let emptyPostsLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "No posts yet"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        setupData_Trace()
        registerNotifications_Trace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Trace.frame = headerView_Trace.bounds
        avatarRingGradientLayer_Trace.frame = avatarOuterRingView_Trace.bounds
        headerBottomGlowLayer_Trace.frame = headerBottomGlowView_Trace.bounds
        statsGradientLayer_Trace.frame = statsContainerView_Trace.bounds
        postsAccentGradient_Trace.frame = postsAccentBar_Trace.bounds
        // 关注按钮渐变层随按钮尺寸同步
        followBtnGradient_Trace.frame = followBtn_Trace.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace

        // ---- 渐变头部（深紫 → 靛蓝 → 电光蓝，三色对角渐变，视觉更深邃）
        headerGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#4A00E0").cgColor,
            UIColor(hexstring_Trace: "#3B82F6").cgColor,
            UIColor(hexstring_Trace: "#06B6D4").cgColor
        ]
        headerGradientLayer_Trace.locations = [0.0, 0.6, 1.0]
        headerGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        headerView_Trace.layer.insertSublayer(headerGradientLayer_Trace, at: 0)

        // 头部底部渐变过渡（更强的白色晕光，过渡到白色卡片）
        headerBottomGlowLayer_Trace.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.22).cgColor
        ]
        headerBottomGlowLayer_Trace.startPoint = CGPoint(x: 0.5, y: 0)
        headerBottomGlowLayer_Trace.endPoint = CGPoint(x: 0.5, y: 1)
        headerBottomGlowView_Trace.layer.addSublayer(headerBottomGlowLayer_Trace)

        // 头像外环渐变（白色高光环 + 蓝紫色调，贴合头部主色系）
        avatarRingGradientLayer_Trace.colors = [
            UIColor.white.cgColor,
            UIColor(hexstring_Trace: "#A5B4FC").cgColor
        ]
        avatarRingGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        avatarRingGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        avatarOuterRingView_Trace.layer.insertSublayer(avatarRingGradientLayer_Trace, at: 0)

        // 统计栏渐变背景插入最底层
        statsContainerView_Trace.layer.insertSublayer(statsGradientLayer_Trace, at: 0)

        // 注册 CollectionView Cell
        postsCollectionView_Trace.register(MePostCell_Trace.self, forCellWithReuseIdentifier: postCellId_Trace)
        postsCollectionView_Trace.dataSource = self
        postsCollectionView_Trace.delegate = self

        // ---- 视图层级 ----
        view.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(contentView_Trace)

        // 头部（头部仅包含装饰层，不含头像，避免 clipsToBounds 裁切溢出部分）
        contentView_Trace.addSubview(headerView_Trace)
        headerView_Trace.addSubview(decorCircle1_Trace)
        headerView_Trace.addSubview(decorCircle2_Trace)
        headerView_Trace.addSubview(decorCircle3_Trace)
        headerView_Trace.addSubview(headerBottomGlowView_Trace)

        // 信息卡片（先添加，z 轴低于头像，避免遮盖头像）
        contentView_Trace.addSubview(infoSheetView_Trace)

        // 头像光晕（在头像下方渲染，制造悬浮感；比 avatarOuterRingView 先添加，z 轴在下）
        contentView_Trace.addSubview(avatarGlowView_Trace)

        // 头像（后添加到 contentView，z 轴位于信息卡片上层，不受 headerView.clipsToBounds 约束）
        contentView_Trace.addSubview(avatarOuterRingView_Trace)
        avatarOuterRingView_Trace.addSubview(avatarInnerBorderView_Trace)
        avatarInnerBorderView_Trace.addSubview(avatarView_Trace)
        infoSheetView_Trace.addSubview(dragIndicatorView_Trace)
        infoSheetView_Trace.addSubview(nameLabel_Trace)
        infoSheetView_Trace.addSubview(introduceLabel_Trace)

        // 统计栏
        statsContainerView_Trace.addSubview(postsStatView_Trace)
        statsContainerView_Trace.addSubview(statsDivider1_Trace)
        statsContainerView_Trace.addSubview(fansStatView_Trace)
        statsContainerView_Trace.addSubview(statsDivider2_Trace)
        statsContainerView_Trace.addSubview(followingStatView_Trace)
        infoSheetView_Trace.addSubview(statsContainerView_Trace)

        // 操作按钮区
        followBtn_Trace.layer.insertSublayer(followBtnGradient_Trace, at: 0)
        infoSheetView_Trace.addSubview(followBtn_Trace)
        infoSheetView_Trace.addSubview(chatBtn_Trace)

        // 帖子区
        postsAccentBar_Trace.layer.insertSublayer(postsAccentGradient_Trace, at: 0)
        postsSectionView_Trace.addSubview(postsAccentBar_Trace)
        postsSectionView_Trace.addSubview(postsTitleLabel_Trace)
        postsCountBadge_Trace.addSubview(postsCountBadgeLabel_Trace)
        postsSectionView_Trace.addSubview(postsCountBadge_Trace)
        contentView_Trace.addSubview(postsSectionView_Trace)
        contentView_Trace.addSubview(postsCollectionView_Trace)
        emptyPostsView_Trace.addSubview(emptyPostsEmojiLabel_Trace)
        emptyPostsView_Trace.addSubview(emptyPostsLabel_Trace)
        contentView_Trace.addSubview(emptyPostsView_Trace)

        // 浮动导航层（最顶层）
        view.addSubview(navOverlayView_Trace)
        navOverlayView_Trace.addSubview(backBtn_Trace)

        buildConstraints_Trace()
        bindActions_Trace()
    }

    private func buildConstraints_Trace() {
        let headerH_trace: CGFloat = 260

        // 滚动区（全屏）
        scrollView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 头部
        headerView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerH_trace)
        }

        decorCircle1_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-30)
            make.trailing.equalToSuperview().offset(40)
            make.width.height.equalTo(130)
        }

        decorCircle2_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(-20)
            make.width.height.equalTo(90)
        }

        decorCircle3_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-50)
            make.width.height.equalTo(160)
        }

        headerBottomGlowView_Trace.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }

        // 信息卡片（从头部底边上方 32pt 开始，为头像骑跨区域留出视觉空间）
        infoSheetView_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerView_Trace.snp.bottom).offset(-32)
            make.leading.trailing.equalToSuperview()
        }

        dragIndicatorView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(4)
        }

        // 头像光晕（与外环同中心，尺寸稍大，形成光晕扩散效果）
        avatarGlowView_Trace.snp.makeConstraints { make in
            make.center.equalTo(avatarOuterRingView_Trace)
            make.width.height.equalTo(112)
        }

        // 头像外环：中心点贴合 header 底边，骑跨 header 与信息卡片之间，z 轴在卡片之上
        avatarOuterRingView_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(headerView_Trace.snp.bottom)
            make.width.height.equalTo(112)
        }

        avatarInnerBorderView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(98)
        }

        avatarView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(86)
        }

        // 昵称（头像中心在 infoSheet.top + 32pt，头像半径 56pt，底边在 infoSheet.top + 88pt，再加 12pt 间距）
        nameLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        introduceLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Trace.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(28)
        }

        // 统计栏（bottom 由操作按钮区接管，此处不设置）
        statsContainerView_Trace.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel_Trace.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(72)
        }

        // 关注按钮（左侧，占可用宽度约一半）
        followBtn_Trace.snp.makeConstraints { make in
            make.top.equalTo(statsContainerView_Trace.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(22)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-20)
        }

        // 聊天按钮（紧贴关注按钮右侧，等高）
        chatBtn_Trace.snp.makeConstraints { make in
            make.leading.equalTo(followBtn_Trace.snp.trailing).offset(12)
            make.centerY.equalTo(followBtn_Trace)
            make.height.equalTo(40)
        }

        postsStatView_Trace.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }

        statsDivider1_Trace.snp.makeConstraints { make in
            make.leading.equalTo(postsStatView_Trace.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalToSuperview().multipliedBy(0.5)
        }

        fansStatView_Trace.snp.makeConstraints { make in
            make.leading.equalTo(statsDivider1_Trace.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }

        statsDivider2_Trace.snp.makeConstraints { make in
            make.leading.equalTo(fansStatView_Trace.snp.trailing)
            make.centerY.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalToSuperview().multipliedBy(0.5)
        }

        followingStatView_Trace.snp.makeConstraints { make in
            make.leading.equalTo(statsDivider2_Trace.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }

        // 帖子区标题行
        postsSectionView_Trace.snp.makeConstraints { make in
            make.top.equalTo(infoSheetView_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }

        // 左侧渐变装饰竖条
        postsAccentBar_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(20)
        }

        postsTitleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(postsAccentBar_Trace.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        postsCountBadge_Trace.snp.makeConstraints { make in
            make.leading.equalTo(postsTitleLabel_Trace.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }

        postsCountBadgeLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        // 帖子网格（高度由数据驱动）
        postsCollectionView_Trace.snp.makeConstraints { make in
            make.top.equalTo(postsSectionView_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            postsHeightConstraint_Trace = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview()
        }

        // 空状态视图（与网格同位置）
        emptyPostsView_Trace.snp.makeConstraints { make in
            make.top.equalTo(postsSectionView_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        emptyPostsEmojiLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        emptyPostsLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(emptyPostsEmojiLabel_Trace.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        // 浮动导航层
        navOverlayView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(62)
        }

        backBtn_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 数据填充

    private func setupData_Trace() {
        guard let user_trace = userModel_Trace else { return }

        // 头像
        if let userId_trace = user_trace.userId_Trace {
            avatarView_Trace.configure_Trace(userId_Trace: userId_trace)
        }

        // 昵称与简介
        nameLabel_Trace.text = user_trace.userName_Trace ?? "Anonymous"
        introduceLabel_Trace.text = (user_trace.userIntroduce_Trace?.isEmpty == false)
            ? user_trace.userIntroduce_Trace
            : "This user hasn't written an introduction yet."
        introduceLabel_Trace.isHidden = false

        // 帖子数稍后在 reloadPosts 中更新
        posts_Trace = TitleViewModel_Trace.shared_Trace.getUserPosts_Trace(user_trace: user_trace)
        postsStatView_Trace.configure_Trace(
            value_trace: "\(posts_Trace.count)",
            label_trace: "Posts",
            emoji_trace: "📝"
        )
        fansStatView_Trace.configure_Trace(
            value_trace: "\(user_trace.userFans_Trace ?? 0)",
            label_trace: "Fans",
            emoji_trace: "🌟"
        )
        followingStatView_Trace.configure_Trace(
            value_trace: "\(user_trace.userFollow_Trace ?? 0)",
            label_trace: "Following",
            emoji_trace: "💫"
        )

        // 举报/拉黑按钮（创建后添加至浮动导航层）
        setupReportButton_Trace(user_trace: user_trace)

        // 当前用户查看自己的主页时隐藏操作按钮
        let isSelf_trace = UserViewModel_Trace.shared_Trace.isCurrentUser_Trace(userId_trace: user_trace.userId_Trace ?? -1)
        followBtn_Trace.isHidden = isSelf_trace
        chatBtn_Trace.isHidden = isSelf_trace

        // 更新关注按钮初始状态
        updateFollowButtonState_Trace()

        // 加载帖子网格
        reloadPosts_Trace()
    }

    /// 创建并配置举报/拉黑按钮，添加至浮动导航层
    /// - Parameter user_trace: 目标用户数据
    private func setupReportButton_Trace(user_trace: PrewUserModel_Trace) {
        let btn_trace = ReportDeleteHelper_Trace.createUserReportButton_Trace(
            size_Trace: 36,
            tintColor_Trace: .white,
            withShadow_Trace: false
        )
        btn_trace.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        btn_trace.layer.cornerRadius = 18
        btn_trace.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        btn_trace.layer.borderWidth = 1
        btn_trace.layer.shadowColor = UIColor.black.cgColor
        btn_trace.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn_trace.layer.shadowRadius = 8
        btn_trace.layer.shadowOpacity = 0.2
        btn_trace.layer.masksToBounds = false

        btn_trace.addAction(UIAction { [weak self] _ in
            guard let self_trace = self else { return }
            // 拉黑确认后自动返回上一页
            ReportDeleteHelper_Trace.block_Trace(user_Trace: user_trace, from: self_trace) {
                Navigation_Trace.pop_Trace()
            }
        }, for: .touchUpInside)

        navOverlayView_Trace.addSubview(btn_trace)
        reportBtn_Trace = btn_trace

        btn_trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backBtn_Trace)
            make.width.height.equalTo(36)
        }
    }

    /// 刷新帖子网格
    private func reloadPosts_Trace() {
        guard let user_trace = userModel_Trace else { return }
        posts_Trace = TitleViewModel_Trace.shared_Trace.getUserPosts_Trace(user_trace: user_trace)

        let isEmpty_trace = posts_Trace.isEmpty
        postsCollectionView_Trace.isHidden = isEmpty_trace
        emptyPostsView_Trace.isHidden = !isEmpty_trace

        // 更新帖子数量标题
        postsTitleLabel_Trace.text = "📖  Posts"
        postsCountBadgeLabel_Trace.text = "\(posts_Trace.count)"
        postsCountBadge_Trace.isHidden = isEmpty_trace
        postsStatView_Trace.updateValue_Trace(value_trace: "\(posts_Trace.count)")

        postsCollectionView_Trace.reloadData()

        // 计算并更新网格高度约束
        if !isEmpty_trace {
            let itemW_trace = (UIScreen.main.bounds.width - 48) / 2
            let itemH_trace = itemW_trace * 1.18
            let rowCount_trace = ceil(Double(posts_Trace.count) / 2.0)
            let totalH_trace = rowCount_trace * Double(itemH_trace) + (rowCount_trace - 1) * 12 + 16
            postsHeightConstraint_Trace?.update(offset: totalH_trace)
        } else {
            postsHeightConstraint_Trace?.update(offset: 0)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        backBtn_Trace.addTarget(self, action: #selector(handleBackTap_Trace), for: .touchUpInside)
        followBtn_Trace.addTarget(self, action: #selector(handleFollowTap_Trace), for: .touchUpInside)
        chatBtn_Trace.addTarget(self, action: #selector(handleChatTap_Trace), for: .touchUpInside)
    }

    // MARK: - 通知注册

    private func registerNotifications_Trace() {
        // 帖子数据变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Trace),
            name: TitleViewModel_Trace.titleStateDidChangeNotification_Trace,
            object: nil
        )
        // 用户状态变化（关注/取消关注后刷新按钮状态）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Trace),
            name: UserViewModel_Trace.userStateDidChangeNotification_Trace,
            object: nil
        )
    }

    // MARK: - 关注按钮状态更新

    /// 根据当前关注状态刷新关注按钮的外观
    private func updateFollowButtonState_Trace() {
        guard let user_trace = userModel_Trace else { return }
        let isFollowing_trace = UserViewModel_Trace.shared_Trace.isFollowing_Trace(user_trace: user_trace)
        if isFollowing_trace {
            // 已关注：白色背景 + 描边 + 彩色文字
            followBtnGradient_Trace.isHidden = true
            followBtn_Trace.backgroundColor = .white
            followBtn_Trace.layer.borderColor = UIColor(hexstring_Trace: "#4A00E0").withAlphaComponent(0.3).cgColor
            followBtn_Trace.layer.borderWidth = 1
            followBtn_Trace.setTitle("Followed", for: .normal)
            followBtn_Trace.setTitleColor(UIColor(hexstring_Trace: "#4A00E0"), for: .normal)
        } else {
            // 未关注：渐变背景 + 白色文字
            followBtnGradient_Trace.isHidden = false
            followBtn_Trace.backgroundColor = .clear
            followBtn_Trace.layer.borderWidth = 0
            followBtn_Trace.setTitle("Follow", for: .normal)
            followBtn_Trace.setTitleColor(.white, for: .normal)
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTap_Trace() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Trace.pop_Trace()
    }

    /// 关注/取消关注按钮点击
    @objc private func handleFollowTap_Trace() {
        guard let user_trace = userModel_Trace else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        followBtn_Trace.animatePressDown_Trace { self.followBtn_Trace.animatePressUp_Trace() }
        // 调用 UserViewModel 执行关注/取消关注（内部已处理未登录拦截）
        UserViewModel_Trace.shared_Trace.followUser_Trace(user_trace: user_trace)
    }

    /// 前往聊天按钮点击：以 replace 方式跳转聊天页
    /// replace 样式替换当前 UserInfo 页，返回时直接回到来源页，避免栈中累积多余层级
    @objc private func handleChatTap_Trace() {
        guard let user_trace = userModel_Trace else { return }
        chatBtn_Trace.animatePressDown_Trace { self.chatBtn_Trace.animatePressUp_Trace() }
        Navigation_Trace.toMessageUser_Trace(with: user_trace, style_trace: .replace_trace)
    }

    /// 帖子数据变化时自动更新网格与统计数量
    @objc private func handleTitleStateChange_Trace() {
        reloadPosts_Trace()
    }

    /// 用户状态变化时刷新关注按钮状态
    @objc private func handleUserStateChange_Trace() {
        updateFollowButtonState_Trace()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension UserInfo_Trace: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts_Trace.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_trace = collectionView.dequeueReusableCell(
            withReuseIdentifier: postCellId_Trace,
            for: indexPath
        ) as! MePostCell_Trace
        let post_trace = posts_Trace[indexPath.item]
        let isLiked_trace = TitleViewModel_Trace.shared_Trace.isLikedPost_Trace(post_trace: post_trace)
        cell_trace.configure_Trace(post_trace: post_trace, isLiked_trace: isLiked_trace)
        // 他人主页：绑定举报回调，举报按钮自动显示
        cell_trace.onReportTapped_Trace = { [weak self] reportPost_trace in
            guard let self = self else { return }
            ReportDeleteHelper_Trace.report_Trace(
                post_Trace: reportPost_trace,
                from: self
            ) { [weak self] in
                // 举报成功后从列表移除并刷新网格
                self?.reloadPosts_Trace()
            }
        }
        return cell_trace
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_trace = posts_Trace[indexPath.item]
        let detailVC_trace = Detail_Trace()
        detailVC_trace.titleModel_Trace = post_trace
        Navigation_Trace.push_Trace(to: detailVC_trace)
    }
}

// MARK: - 用户中心统计项视图

/// 用户中心统计项（帖子数/粉丝/关注数）
/// 核心作用：展示单项统计数据（数值 + 标签 + emoji 装饰），用于用户中心统计栏
/// 关键方法：configure_Trace、updateValue_Trace
class UserStatItemView_Trace: UIView {

    // MARK: - UI 组件

    private let emojiLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textAlignment = .center
        return lbl
    }()

    private let valueLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 19, weight: .heavy)
        lbl.textColor = UIColor(hexstring_Trace: "#4A00E0")
        lbl.textAlignment = .center
        return lbl
    }()

    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
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
            make.top.equalToSuperview().offset(10)
        }

        valueLabel_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emojiLabel_Trace.snp.bottom).offset(2)
        }

        titleLabel_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(valueLabel_Trace.snp.bottom).offset(2)
        }
    }

    // MARK: - 公共方法

    /// 配置统计项数据
    /// - Parameters:
    ///   - value_trace: 数值字符串
    ///   - label_trace: 标签文字
    ///   - emoji_trace: 装饰 emoji
    func configure_Trace(value_trace: String, label_trace: String, emoji_trace: String) {
        emojiLabel_Trace.text = emoji_trace
        valueLabel_Trace.text = value_trace
        titleLabel_Trace.text = label_trace
    }

    /// 更新数值
    /// - Parameter value_trace: 新数值字符串
    func updateValue_Trace(value_trace: String) {
        valueLabel_Trace.text = value_trace
    }
}
