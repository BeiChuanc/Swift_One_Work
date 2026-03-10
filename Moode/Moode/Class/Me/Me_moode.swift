import Foundation
import UIKit
import SnapKit

// MARK: - 我的页面
// 核心作用：展示登录用户的个人主页，包含头像、昵称、简介、统计数据（帖子/关注者/喜欢），
//           以及发布的帖子 / 喜欢的帖子两栏数据（分段切换）。
// 设计思路：渐变 Header + 浮动统计卡片（跨越 header/content 边界） + Tab + 瀑布流；
//           统计卡片使用白色阴影浮层，避免被 contentCard 遮盖。
// 关键属性：meModel_Moode（传入用户）、selectedTab_Moode（当前 Tab）、
//           displayPosts_Moode（当前展示帖子列表）

/// 我的主页控制器
class Me_Moode: UIViewController {

    // MARK: - 属性

    /// 外部传入的用户模型（nil 时取当前登录用户）
    var meModel_Moode: LoginUserModel_Moode?

    /// 当前选中的 Tab（0=我的帖子, 1=喜欢）
    private var selectedTab_Moode: Int = 0

    /// 当前展示的帖子列表
    private var displayPosts_Moode: [TitleModel_Moode] = []

    // MARK: - UI组件（滚动结构）

    /// 主滚动容器
    private let scrollView_Moode: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    /// 内容容器
    private let contentView_Moode = UIView()

    // MARK: Header

    /// 顶部渐变 Header
    private let headerBg_Moode: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    /// Header 渐变层
    private let headerGradient_Moode = CAGradientLayer()

    /// Header 底部波浪裁切层（clipsToBounds = true 的独立子层容器）
    private let headerClip_Moode: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    /// 装饰大圆（右上）
    private let decCircle1_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 80
        return v
    }()

    /// 装饰小圆（左下）
    private let decCircle2_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 装饰中圆（右下角）
    private let decCircle3_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 35
        return v
    }()

    /// 装饰浮动 emoji（左上角）
    private let decEmoji1_Moode: UILabel = {
        let l = UILabel()
        l.text = "✨"
        l.font = .systemFont(ofSize: 20)
        l.alpha = 0.7
        return l
    }()

    /// 装饰浮动 emoji（右中）
    private let decEmoji2_Moode: UILabel = {
        let l = UILabel()
        l.text = "🌙"
        l.font = .systemFont(ofSize: 16)
        l.alpha = 0.6
        return l
    }()

    /// 设置按钮（右上角）
    private let settingBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 编辑按钮（设置左侧）
    private let editBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn.setImage(UIImage(systemName: "pencil", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.setTitle("  Edit", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        return btn
    }()

    /// 头像外圈容器（用于绘制渐变环）
    private let avatarRingView_Moode = UIView()

    /// 用户头像
    private let avatarView_Moode = UserAvatarView_Moode()

    /// 用户名标签
    private let nameLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 用户 ID / 简介
    private let bioLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.82)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 情绪标签 badge（header 中）
    private let moodBadge_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 12
        return v
    }()

    private let moodBadgeLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "😊  Feeling good"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .white
        return l
    }()

    // MARK: 浮动统计卡片（跨越 header/content 边界，不被遮盖）

    /// 统计悬浮卡片
    private let statsCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Moode: "#7C6FF7").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.18
        v.layer.shadowRadius = 16
        return v
    }()

    /// 帖子数
    private let postsCountLbl_Moode = makeStatNumLbl_Moode()
    private let postsDescLbl_Moode  = makeStatDescLbl_Moode(text: "Posts")
    private let postsIconLbl_Moode  = makeStatIconLbl_Moode(text: "📝")

    /// 关注者数
    private let followCountLbl_Moode = makeStatNumLbl_Moode()
    private let followDescLbl_Moode  = makeStatDescLbl_Moode(text: "Followers")
    private let followIconLbl_Moode  = makeStatIconLbl_Moode(text: "👥")

    /// 喜欢数
    private let likesCountLbl_Moode = makeStatNumLbl_Moode()
    private let likesDescLbl_Moode  = makeStatDescLbl_Moode(text: "Liked")
    private let likesIconLbl_Moode  = makeStatIconLbl_Moode(text: "❤️")

    // MARK: 内容区

    /// 内容白卡
    private let contentCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    /// Tab 背景容器
    private let tabContainer_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        v.layer.cornerRadius = 14
        return v
    }()

    /// 我的帖子 Tab
    private let myPostsTab_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("My Posts", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.tag = 0
        return btn
    }()

    /// 喜欢 Tab
    private let likedTab_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Liked", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.tag = 1
        return btn
    }()

    /// Tab 选中滑块
    private let tabIndicator_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor(hexstring_Moode: "#7C6FF7").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 0.18
        v.layer.shadowRadius = 6
        return v
    }()

    /// 帖子 CollectionView
    private lazy var postsCV_Moode: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 10
        let w = (UIScreen.main.bounds.width - 48) / 2
        layout.itemSize = CGSize(width: w, height: w * 1.3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.register(MePostCell_Moode.self, forCellWithReuseIdentifier: MePostCell_Moode.reuseId_Moode)
        return cv
    }()

    /// 空状态容器
    private let emptyView_Moode: UIView = { let v = UIView(); v.isHidden = true; return v }()

    private let emptyEmoji_Moode: UILabel = {
        let l = UILabel(); l.text = "🌸"; l.font = .systemFont(ofSize: 44); l.textAlignment = .center
        return l
    }()

    private let emptyTitle_Moode: UILabel = {
        let l = UILabel()
        l.text = "Nothing here yet"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = UIColor(hexstring_Moode: "#7C6FF7")
        l.textAlignment = .center
        return l
    }()

    private let emptySubTitle_Moode: UILabel = {
        let l = UILabel()
        l.text = "Start sharing your mood with the world ✨"
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Moode: "#9E8EF5")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// CollectionView 高度约束
    private var cvHeightConstraint_Moode: Constraint?

    /// 统计卡片顶部约束（用于在 viewDidLayoutSubviews 中精确定位）
    private var statsCardTopConstraint_Moode: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Moode()
        bindData_Moode()
        observeNotifications_Moode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        bindData_Moode()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Moode.frame = headerClip_Moode.bounds
        updateAvatarRing_Moode()
        startFloatAnimation_Moode()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupUI_Moode() {
        view.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")

        view.addSubview(scrollView_Moode)
        scrollView_Moode.addSubview(contentView_Moode)

        scrollView_Moode.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Moode.contentLayoutGuide)
            make.width.equalTo(scrollView_Moode.frameLayoutGuide)
        }

        setupHeaderUI_Moode()
        setupStatsCard_Moode()
        setupContentCardUI_Moode()
    }

    /// 搭建顶部 Header（渐变背景 + 装饰 + 头像 + 名称 + 简介 + 情绪 badge）
    private func setupHeaderUI_Moode() {
        // headerBg 本身不裁切，便于统计卡片跨越边界显示
        contentView_Moode.addSubview(headerBg_Moode)
        headerBg_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(360)
        }

        // 渐变裁切容器（充满 headerBg）
        headerBg_Moode.addSubview(headerClip_Moode)
        headerClip_Moode.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 渐变层
        headerGradient_Moode.colors = [
            UIColor(hexstring_Moode: "#6A5FE8").cgColor,
            UIColor(hexstring_Moode: "#9B8BFC").cgColor,
            UIColor(hexstring_Moode: "#BFB3FF").cgColor
        ]
        headerGradient_Moode.locations = [0, 0.55, 1]
        headerGradient_Moode.startPoint = CGPoint(x: 0.1, y: 0)
        headerGradient_Moode.endPoint   = CGPoint(x: 0.9, y: 1)
        headerClip_Moode.layer.insertSublayer(headerGradient_Moode, at: 0)

        // 装饰圆
        headerClip_Moode.addSubview(decCircle1_Moode)
        decCircle1_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.top.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(40)
        }

        headerClip_Moode.addSubview(decCircle2_Moode)
        decCircle2_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.bottom.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(-20)
        }

        headerClip_Moode.addSubview(decCircle3_Moode)
        decCircle3_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.bottom.equalToSuperview().offset(-40)
            make.right.equalToSuperview().offset(-80)
        }

        // 浮动 emoji 装饰
        headerClip_Moode.addSubview(decEmoji1_Moode)
        decEmoji1_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.left.equalToSuperview().offset(22)
        }

        headerClip_Moode.addSubview(decEmoji2_Moode)
        decEmoji2_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-60)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
        }

        // 按钮行
        headerBg_Moode.addSubview(settingBtn_Moode)
        settingBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        settingBtn_Moode.addTarget(self, action: #selector(handleSetting_Moode), for: .touchUpInside)

        headerBg_Moode.addSubview(editBtn_Moode)
        editBtn_Moode.snp.makeConstraints { make in
            make.centerY.equalTo(settingBtn_Moode)
            make.right.equalTo(settingBtn_Moode.snp.left).offset(-10)
            make.height.equalTo(32)
        }
        editBtn_Moode.addTarget(self, action: #selector(handleEdit_Moode), for: .touchUpInside)

        // 头像环
        headerBg_Moode.addSubview(avatarRingView_Moode)
        avatarRingView_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(94)
            make.centerX.equalToSuperview()
            make.top.equalTo(settingBtn_Moode.snp.bottom).offset(16)
        }

        avatarRingView_Moode.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(84)
            make.center.equalToSuperview()
        }

        // 用户名
        headerBg_Moode.addSubview(nameLbl_Moode)
        nameLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Moode.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(28)
        }

        // 简介
        headerBg_Moode.addSubview(bioLbl_Moode)
        bioLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_Moode.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(36)
        }

        // 情绪 badge
        headerBg_Moode.addSubview(moodBadge_Moode)
        moodBadge_Moode.snp.makeConstraints { make in
            make.top.equalTo(bioLbl_Moode.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }
        moodBadge_Moode.addSubview(moodBadgeLbl_Moode)
        moodBadgeLbl_Moode.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(14)
        }
    }

    /// 搭建浮动统计卡片（跨越 header / content 边界）
    private func setupStatsCard_Moode() {
        // 加在 contentView 上，层级高于 headerBg 和 contentCard
        contentView_Moode.addSubview(statsCard_Moode)
        statsCard_Moode.snp.makeConstraints { make in
            // 卡片中心线对齐 header 底部（340+28 = 368 / 2 → 334 - 28 = 306...）
            // 更直接：顶部 = moodBadge 下方 20pt（约 header 末尾往上 54pt 左右）
            // 使用固定值：让卡片顶距离 header 顶约 310pt，底部自然超出 header
            make.top.equalToSuperview().offset(312)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(84)
        }

        // 三列统计（Posts / Followers / Liked）
        let divider1 = makeStatDivider_Moode()
        let divider2 = makeStatDivider_Moode()

        let postsCol  = buildStatCol_Moode(icon: postsIconLbl_Moode,  num: postsCountLbl_Moode,  desc: postsDescLbl_Moode)
        let followCol = buildStatCol_Moode(icon: followIconLbl_Moode, num: followCountLbl_Moode, desc: followDescLbl_Moode)
        let likesCol  = buildStatCol_Moode(icon: likesIconLbl_Moode,  num: likesCountLbl_Moode,  desc: likesDescLbl_Moode)

        statsCard_Moode.addSubview(postsCol)
        statsCard_Moode.addSubview(divider1)
        statsCard_Moode.addSubview(followCol)
        statsCard_Moode.addSubview(divider2)
        statsCard_Moode.addSubview(likesCol)

        postsCol.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
        }

        divider1.snp.makeConstraints { make in
            make.left.equalTo(postsCol.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(32)
        }

        followCol.snp.makeConstraints { make in
            make.left.equalTo(divider1.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
        }

        divider2.snp.makeConstraints { make in
            make.left.equalTo(followCol.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(32)
        }

        likesCol.snp.makeConstraints { make in
            make.left.equalTo(divider2.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
    }

    /// 搭建内容卡片（Tab + CollectionView + 空状态）
    private func setupContentCardUI_Moode() {
        contentView_Moode.addSubview(contentCard_Moode)
        // 内容卡片顶部 = statsCard 底部 + 16（统计卡片 top=312, height=84 → bottom=396；再加16 = 412）
        // 用 statsCard_Moode 锚点引用
        contentCard_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(396)
            make.left.right.bottom.equalToSuperview()
        }

        // Tab 切换
        contentCard_Moode.addSubview(tabContainer_Moode)
        tabContainer_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        tabContainer_Moode.addSubview(tabIndicator_Moode)
        tabContainer_Moode.addSubview(myPostsTab_Moode)
        tabContainer_Moode.addSubview(likedTab_Moode)

        myPostsTab_Moode.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-6)
        }
        likedTab_Moode.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-6)
        }

        myPostsTab_Moode.addTarget(self, action: #selector(handleTabTap_Moode(_:)), for: .touchUpInside)
        likedTab_Moode.addTarget(self, action: #selector(handleTabTap_Moode(_:)), for: .touchUpInside)

        updateTabAppearance_Moode()

        // 空状态
        contentCard_Moode.addSubview(emptyView_Moode)
        emptyView_Moode.addSubview(emptyEmoji_Moode)
        emptyView_Moode.addSubview(emptyTitle_Moode)
        emptyView_Moode.addSubview(emptySubTitle_Moode)

        emptyView_Moode.snp.makeConstraints { make in
            make.top.equalTo(tabContainer_Moode.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
            make.height.equalTo(130)
        }
        emptyEmoji_Moode.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        emptyTitle_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyEmoji_Moode.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        emptySubTitle_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle_Moode.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }

        // 帖子 CollectionView
        contentCard_Moode.addSubview(postsCV_Moode)
        postsCV_Moode.dataSource = self
        postsCV_Moode.delegate   = self

        postsCV_Moode.snp.makeConstraints { make in
            make.top.equalTo(tabContainer_Moode.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            cvHeightConstraint_Moode = make.height.equalTo(200).constraint
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 工厂方法

    /// 创建统计列（icon + 数字 + 描述竖排）
    private func buildStatCol_Moode(icon: UILabel, num: UILabel, desc: UILabel) -> UIView {
        let col = UIView()
        col.addSubview(icon)
        col.addSubview(num)
        col.addSubview(desc)

        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        num.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        desc.snp.makeConstraints { make in
            make.top.equalTo(num.snp.bottom).offset(1)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
        return col
    }

    /// 创建统计分隔线
    private func makeStatDivider_Moode() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        return v
    }

    /// 创建统计数字标签（工厂）
    private static func makeStatNumLbl_Moode() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .heavy)
        l.textColor = UIColor(hexstring_Moode: "#2D2D3A")
        l.textAlignment = .center
        return l
    }

    /// 创建统计描述标签（工厂）
    private static func makeStatDescLbl_Moode(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 10, weight: .medium)
        l.textColor = UIColor(hexstring_Moode: "#9E8EF5")
        l.textAlignment = .center
        return l
    }

    /// 创建统计 icon emoji 标签（工厂）
    private static func makeStatIconLbl_Moode(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .center
        return l
    }

    // MARK: - 头像渐变环

    /// 更新头像外圈渐变环（在 viewDidLayoutSubviews 中调用）
    private func updateAvatarRing_Moode() {
        avatarRingView_Moode.layer.sublayers?
            .filter { $0.name == "avatarRing_Moode" }
            .forEach { $0.removeFromSuperlayer() }

        let size = avatarRingView_Moode.bounds.size
        guard size.width > 0 else { return }

        let grad = CAGradientLayer()
        grad.name = "avatarRing_Moode"
        grad.colors = [UIColor.white.cgColor,
                       UIColor(hexstring_Moode: "#C4B5FD").cgColor,
                       UIColor(hexstring_Moode: "#F0ABFC").cgColor]
        grad.locations = [0, 0.5, 1]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.frame      = CGRect(origin: .zero, size: size)

        let ringW: CGFloat = 3.5
        let outer = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
        let inner = UIBezierPath(ovalIn: CGRect(x: ringW, y: ringW,
                                                width: size.width - ringW * 2,
                                                height: size.height - ringW * 2))
        outer.append(inner)
        let mask = CAShapeLayer()
        mask.path = outer.cgPath
        mask.fillRule = .evenOdd
        grad.mask = mask

        avatarRingView_Moode.layer.insertSublayer(grad, at: 0)
    }

    // MARK: - 浮动动画

    private var floatStarted_Moode = false

    /// 启动装饰 emoji 浮动动画（只执行一次）
    private func startFloatAnimation_Moode() {
        guard !floatStarted_Moode else { return }
        floatStarted_Moode = true

        UIView.animate(withDuration: 2.4, delay: 0,
                       options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.decEmoji1_Moode.transform = CGAffineTransform(translationX: 0, y: -7)
        }
        UIView.animate(withDuration: 3.0, delay: 0.6,
                       options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.decEmoji2_Moode.transform = CGAffineTransform(translationX: 0, y: -5)
        }
    }

    // MARK: - 数据绑定

    /// 将当前用户数据绑定到 UI
    private func bindData_Moode() {
        let user = meModel_Moode ?? UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()

        // 头像
        if let uid = user.userId_Moode {
            avatarView_Moode.configure_Moode(userId_Moode: uid)
        }

        // 用户名
        nameLbl_Moode.text = user.userName_Moode ?? "Mooder"

        // 简介
        let bio = user.userIntroduce_Moode
        bioLbl_Moode.text = (bio?.isEmpty == false) ? bio : "No bio yet · tap Edit to add one ✨"

        // 统计
        postsCountLbl_Moode.text  = "\(user.userPosts_Moode.count)"
        followCountLbl_Moode.text = "\(user.userFollow_Moode.count)"
        likesCountLbl_Moode.text  = "\(user.userLike_Moode.count)"

        refreshPosts_Moode()
    }

    /// 刷新帖子列表并动态更新 CollectionView 高度
    private func refreshPosts_Moode() {
        let user = meModel_Moode ?? UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        displayPosts_Moode = selectedTab_Moode == 0 ? user.userPosts_Moode : user.userLike_Moode

        let isEmpty = displayPosts_Moode.isEmpty
        emptyView_Moode.isHidden = !isEmpty
        postsCV_Moode.isHidden   = isEmpty
        postsCV_Moode.reloadData()

        // 动态计算高度
        let itemW    = (UIScreen.main.bounds.width - 48) / 2
        let rows     = ceil(Double(max(1, displayPosts_Moode.count)) / 2.0)
        let itemH    = itemW * 1.3
        let totalH   = isEmpty
            ? 160
            : CGFloat(rows) * itemH + CGFloat(max(0, rows - 1)) * 14 + 40
        cvHeightConstraint_Moode?.update(offset: totalH)
    }

    // MARK: - 通知

    private func observeNotifications_Moode() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserStateChanged_Moode),
            name: UserViewModel_Moode.userStateDidChangeNotification_Moode,
            object: nil
        )
    }

    // MARK: - Tab 外观

    /// 更新 Tab 选中滑块位置和颜色
    private func updateTabAppearance_Moode() {
        tabContainer_Moode.layoutIfNeeded()
        let targetBtn = selectedTab_Moode == 0 ? myPostsTab_Moode : likedTab_Moode
        UIView.animate(withDuration: 0.25, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.tabIndicator_Moode.frame = targetBtn.frame
        }
        myPostsTab_Moode.tintColor = selectedTab_Moode == 0
            ? UIColor(hexstring_Moode: "#7C6FF7")
            : UIColor(hexstring_Moode: "#BBAAEE")
        likedTab_Moode.tintColor = selectedTab_Moode == 1
            ? UIColor(hexstring_Moode: "#7C6FF7")
            : UIColor(hexstring_Moode: "#BBAAEE")
    }

    // MARK: - 事件

    @objc private func handleTabTap_Moode(_ sender: UIButton) {
        guard sender.tag != selectedTab_Moode else { return }
        selectedTab_Moode = sender.tag
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        updateTabAppearance_Moode()
        refreshPosts_Moode()
    }

    @objc private func handleSetting_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Moode.toSetting_Moode()
    }

    @objc private func handleEdit_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Moode.toEditInfo_Moode()
    }

    @objc private func onUserStateChanged_Moode() {
        bindData_Moode()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension Me_Moode: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Moode.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Moode.reuseId_Moode, for: indexPath
        ) as! MePostCell_Moode
        let post_moode = displayPosts_Moode[indexPath.item]
        cell.configure_Moode(post_moode: post_moode)

        // 注入举报/删除回调：自己的帖子→删除，他人的帖子→举报
        cell.onReportTapped_Moode = { [weak self] tappedPost_moode in
            guard let self = self else { return }
            let isMyPost_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
                userId_moode: tappedPost_moode.titleUserId_Moode
            )
            if isMyPost_moode {
                ReportDeleteHelper_Moode.delete_Moode(
                    post_Moode: tappedPost_moode,
                    from: self
                ) { [weak self] in
                    self?.refreshPosts_Moode()
                }
            } else {
                ReportDeleteHelper_Moode.report_Moode(
                    post_Moode: tappedPost_moode,
                    from: self
                ) { [weak self] in
                    self?.refreshPosts_Moode()
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        Navigation_Moode.toTitleDetail_Moode(titleModel_moode: displayPosts_Moode[indexPath.item])
    }
}

// MARK: - MePostCell_Moode

/// 我的帖子卡片 Cell
/// 功能：媒体封面（MediaDisplayView_Moode）+ 情绪 badge 覆盖层 + 右上角举报/删除按钮 + 标题 + 喜欢数
/// 设计：白色圆角卡片，封面由 MediaDisplayView 统一渲染（有图显示图，无图显示占位符）
/// 关键方法：configure_Moode 绑定数据；onReportTapped_Moode 举报/删除回调由外部 VC 注入
class MePostCell_Moode: UICollectionViewCell {

    static let reuseId_Moode = "MePostCell_Moode"

    // MARK: - 回调

    /// 举报/删除按钮回调，携带帖子模型，由外部 VC 区分自己/他人并处理
    var onReportTapped_Moode: ((TitleModel_Moode) -> Void)?

    // MARK: - 私有数据

    private var post_Moode: TitleModel_Moode?

    // MARK: - UI

    private let card_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = false
        v.layer.shadowColor   = UIColor(hexstring_Moode: "#7C6FF7").cgColor
        v.layer.shadowOffset  = CGSize(width: 0, height: 5)
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius  = 10
        return v
    }()

    /// 媒体封面（统一使用 MediaDisplayView_Moode，支持图片/视频/占位符）
    private let mediaView_Moode: MediaDisplayView_Moode = {
        let v = MediaDisplayView_Moode()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    /// 情绪名 badge（封面左下角覆盖层）
    private let moodBadge_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        v.layer.cornerRadius = 8
        return v
    }()

    private let moodBadgeLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 9, weight: .semibold)
        l.textColor = .white
        return l
    }()

    /// 右上角举报/删除按钮（覆盖在封面右上角）
    private let reportBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        btn.layer.cornerRadius = 13
        btn.clipsToBounds = true
        return btn
    }()

    private let titleLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Moode: "#2D2D3A")
        l.numberOfLines = 2
        return l
    }()

    private let likeRow_Moode = UIView()

    private let heartIcon_Moode: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "heart.fill", withConfiguration: cfg))
        iv.tintColor = UIColor(hexstring_Moode: "#FC8181")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likeLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor(hexstring_Moode: "#888")
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI搭建

    private func setupUI_Moode() {
        contentView.addSubview(card_Moode)
        card_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 2, bottom: 6, right: 2))
        }

        // 媒体封面（占据卡片顶部，高度与宽度成比例）
        card_Moode.addSubview(mediaView_Moode)
        mediaView_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(mediaView_Moode.snp.width).multipliedBy(0.88)
        }

        // 举报/删除按钮（封面右上角覆盖层，26×26pt）
        mediaView_Moode.addSubview(reportBtn_Moode)
        reportBtn_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.width.height.equalTo(26)
        }
        reportBtn_Moode.addTarget(self, action: #selector(handleReportTapped_Moode), for: .touchUpInside)

        // 情绪 badge（封面左下角覆盖层）
        mediaView_Moode.addSubview(moodBadge_Moode)
        moodBadge_Moode.addSubview(moodBadgeLbl_Moode)
        moodBadge_Moode.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(6)
        }
        moodBadgeLbl_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6))
        }

        // 标题
        card_Moode.addSubview(titleLbl_Moode)
        titleLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Moode.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(10)
        }

        // 喜欢行
        card_Moode.addSubview(likeRow_Moode)
        likeRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Moode.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(10)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }

        likeRow_Moode.addSubview(heartIcon_Moode)
        likeRow_Moode.addSubview(likeLbl_Moode)
        heartIcon_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        likeLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(heartIcon_Moode.snp.right).offset(4)
            make.centerY.right.equalToSuperview()
        }
    }

    // MARK: - 事件处理

    /// 举报/删除按钮点击
    @objc private func handleReportTapped_Moode() {
        guard let post_Moode = post_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onReportTapped_Moode?(post_Moode)
    }

    // MARK: - 数据配置

    /// 配置 Cell 展示数据
    /// - Parameter post_moode: 帖子数据模型
    func configure_Moode(post_moode: TitleModel_Moode) {
        post_Moode = post_moode
        titleLbl_Moode.text = post_moode.title_Moode
        likeLbl_Moode.text  = "\(post_moode.likes_Moode)"

        // 情绪 badge（仅情绪帖子显示）
        let isMoodPost_moode = post_moode.postType_Moode == .mood_moode
        moodBadge_Moode.isHidden = !isMoodPost_moode
        if isMoodPost_moode {
            moodBadgeLbl_Moode.text = post_moode.moodType_Moode.displayName_Moode
        }

        // 媒体封面（MediaDisplayView 统一处理有图/无图）
        mediaView_Moode.configure_Moode(mediaPath_Moode: post_moode.titleMeidas_Moode.first)

        // 根据是否为自己帖子切换按钮图标：自己→删除(trash)，他人→举报(ellipsis)
        let isMyPost_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
            userId_moode: post_moode.titleUserId_Moode
        )
        let cfg_moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let iconName_moode = isMyPost_moode ? "trash" : "ellipsis"
        reportBtn_Moode.setImage(UIImage(systemName: iconName_moode, withConfiguration: cfg_moode), for: .normal)
        reportBtn_Moode.tintColor = isMyPost_moode
            ? UIColor(hexstring_Moode: "#FF6B6B")
            : .white
        reportBtn_Moode.backgroundColor = isMyPost_moode
            ? UIColor(hexstring_Moode: "#FF6B6B").withAlphaComponent(0.28)
            : UIColor.black.withAlphaComponent(0.42)
    }

    // MARK: - 复用清理

    override func prepareForReuse() {
        super.prepareForReuse()
        post_Moode = nil
        onReportTapped_Moode = nil
        moodBadge_Moode.isHidden = false
    }
}
