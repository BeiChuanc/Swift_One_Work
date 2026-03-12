import Foundation
import UIKit
import SnapKit

// MARK: 我的

/// 我的页面
/// 设计风格：三色渐变头部横幅 + 头像信息卡 + Posts / Liked 双 Tab 帖子瀑布流
/// 布局层次：顶部 Header（头像 / 名字 / Bio / 数据统计 / 操作按钮）→ Tab 切换 → 帖子网格 ScrollView
/// 逻辑：监听 UserStateDidChange_Doze 通知刷新所有数据
class Me_Doze: UIViewController {

    // MARK: - 数据

    /// 外部传入的用户模型（可选，默认取当前登录用户）
    var meModel_Doze: LoginUserModel_Doze?

    /// 当前激活的 Tab（0 = Posts，1 = Liked）
    private var activeTab_Doze: Int = 0

    // MARK: - 顶部 Header

    private let headerBgView_Doze: UIView = {
        let v = UIView()
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.cornerRadius = 32
        v.clipsToBounds = true
        return v
    }()

    private let headerGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#4A1D96").cgColor,
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.locations = [0, 0.5, 1]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        return gl
    }()

    /// 头部右上装饰圆
    private let headerDeco1_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 55
        return v
    }()

    /// 头部左下装饰圆
    private let headerDeco2_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 38
        return v
    }()

    /// 头部左上爪印装饰
    private let headerPawIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 28, weight: .thin)
        iv.image = UIImage(systemName: "pawprint.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.12)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 头部右下月亮装饰
    private let headerMoonIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .thin)
        iv.image = UIImage(systemName: "moon.stars.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.15)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 设置按钮（右上角）
    private let settingButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 编辑按钮（设置按钮左侧）
    private let editButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn.setImage(UIImage(systemName: "pencil", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// Bio 下方 Pet Lover 标签行
    private let badgeRowStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .equalSpacing
        return sv
    }()

    /// 头像容器
    private let avatarContainer_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 46
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
        v.clipsToBounds = true
        return v
    }()

    private let avatarView_Doze: UserAvatarView_Doze = {
        let v = UserAvatarView_Doze()
        return v
    }()

    /// 用户名
    private let userNameLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    /// 用户简介
    private let bioLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.8)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 数据统计行（使用 .fill 分布，配合 stat item 等宽约束，防止分隔线被拉伸）
    private let statsRow_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()

    // MARK: - Tab 切换栏（胶囊卡片式）

    /// Tab 外层容器（浅背景区）
    private let tabBarBg_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        return v
    }()

    /// Tab 胶囊背景卡（白色圆角滑块轨道）
    private let tabBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#EAE6F5")
        v.layer.cornerRadius = 20
        return v
    }()

    private let postsTabBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Posts", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(ColorConfig_Doze.primaryGradientStart_Doze, for: .normal)
        btn.tag = 0
        return btn
    }()

    private let likedTabBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Liked", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(ColorConfig_Doze.textSecondary_Doze, for: .normal)
        btn.tag = 1
        return btn
    }()

    /// 激活 Tab 白色滑块
    private let tabIndicator_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 17
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.layer.shadowOpacity = 1
        return v
    }()

    /// Tab 指示滑块内渐变装饰（无需单独 CAGradientLayer 替换，用 view 背景即可，保留属性兼容 viewDidLayoutSubviews）
    private let tabIndicatorGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.15).cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.withAlphaComponent(0.05).cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        gl.cornerRadius = 17
        return gl
    }()

    // MARK: - 帖子区 ScrollView

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let gridContainer_Doze: UIView = UIView()

    // MARK: - 空状态
    private let emptyView_Doze: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        setupHeader_Doze()
        setupTabBar_Doze()
        setupScrollView_Doze()
        setupEmptyView_Doze()
        loadData_Doze()
        observeNotifications_Doze()
        animateEntrance_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadData_Doze()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Doze.frame = headerBgView_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Header 搭建

    private func setupHeader_Doze() {
        view.addSubview(headerBgView_Doze)
        headerBgView_Doze.layer.addSublayer(headerGradient_Doze)
        headerBgView_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(338)
        }

        // 装饰圆
        headerBgView_Doze.addSubview(headerDeco1_Doze)
        headerDeco1_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(110)
        }

        headerBgView_Doze.addSubview(headerDeco2_Doze)
        headerDeco2_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(16)
            make.width.height.equalTo(76)
        }

        // 爪印装饰图标（左上）
        headerBgView_Doze.addSubview(headerPawIcon_Doze)
        headerPawIcon_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(54)
            make.width.height.equalTo(36)
        }

        // 月亮装饰图标（底部右侧）
        headerBgView_Doze.addSubview(headerMoonIcon_Doze)
        headerMoonIcon_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-28)
            make.width.height.equalTo(30)
        }

        // 设置 & 编辑按钮（圆形胶囊背景）
        headerBgView_Doze.addSubview(settingButton_Doze)
        settingButton_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(56)
            make.width.height.equalTo(36)
        }
        settingButton_Doze.addTarget(self, action: #selector(handleSetting_Doze), for: .touchUpInside)

        headerBgView_Doze.addSubview(editButton_Doze)
        editButton_Doze.snp.makeConstraints { make in
            make.right.equalTo(settingButton_Doze.snp.left).offset(-10)
            make.centerY.equalTo(settingButton_Doze)
            make.width.height.equalTo(36)
        }
        editButton_Doze.addTarget(self, action: #selector(handleEdit_Doze), for: .touchUpInside)

        // 头像（加脉冲环）
        headerBgView_Doze.addSubview(avatarContainer_Doze)
        avatarContainer_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(96)
            make.width.height.equalTo(92)
        }
        avatarContainer_Doze.addSubview(avatarView_Doze)
        avatarView_Doze.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 用户名
        headerBgView_Doze.addSubview(userNameLabel_Doze)
        userNameLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Doze.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }

        // Bio
        headerBgView_Doze.addSubview(bioLabel_Doze)
        bioLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Doze.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(24)
        }

        // Badge 标签行（Pet Lover + Sleep Tracker）
        headerBgView_Doze.addSubview(badgeRowStack_Doze)
        badgeRowStack_Doze.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Doze.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        badgeRowStack_Doze.addArrangedSubview(makeHeaderBadge_Doze(icon: "heart.fill", text: "Pet Lover"))
        badgeRowStack_Doze.addArrangedSubview(makeHeaderBadge_Doze(icon: "moon.zzz.fill", text: "Sleep Tracker"))

        // 统计行
        headerBgView_Doze.addSubview(statsRow_Doze)
        statsRow_Doze.snp.makeConstraints { make in
            make.top.equalTo(badgeRowStack_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 构建头部小标签 chip（icon + text，半透明白色背景）
    private func makeHeaderBadge_Doze(icon: String, text: String) -> UIView {
        let chip = UIView()
        chip.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        chip.layer.cornerRadius = 12
        chip.layer.borderWidth = 0.8
        chip.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
        let iconIv = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconCfg))
        iconIv.tintColor = UIColor.white.withAlphaComponent(0.9)
        iconIv.contentMode = .scaleAspectFit

        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.9)

        chip.addSubview(iconIv)
        chip.addSubview(lbl)
        iconIv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(11)
        }
        lbl.snp.makeConstraints { make in
            make.left.equalTo(iconIv.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview().inset(5)
        }
        return chip
    }

    // MARK: - Tab 搭建（胶囊卡片式）

    private func setupTabBar_Doze() {
        // 外层浅色背景区
        view.addSubview(tabBarBg_Doze)
        tabBarBg_Doze.snp.makeConstraints { make in
            make.top.equalTo(headerBgView_Doze.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }

        // 内层胶囊轨道
        tabBarBg_Doze.addSubview(tabBar_Doze)
        tabBar_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(220)
            make.height.equalTo(40)
        }

        // 滑块（放在按钮下方渲染）
        tabBar_Doze.addSubview(tabIndicator_Doze)
        tabBar_Doze.addSubview(postsTabBtn_Doze)

        postsTabBtn_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        postsTabBtn_Doze.addTarget(self, action: #selector(tabTapped_Doze(_:)), for: .touchUpInside)

        tabBar_Doze.addSubview(likedTabBtn_Doze)
        likedTabBtn_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        likedTabBtn_Doze.addTarget(self, action: #selector(tabTapped_Doze(_:)), for: .touchUpInside)

        // 滑块约束（白色圆角滑块，占半宽内侧）
        tabIndicator_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(3)
            make.top.bottom.equalToSuperview().inset(3)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-3)
        }
    }

    // MARK: - ScrollView 搭建

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(tabBarBg_Doze.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview()
        }
        scrollView_Doze.addSubview(gridContainer_Doze)
        gridContainer_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - 空状态搭建

    private func setupEmptyView_Doze() {
        scrollView_Doze.addSubview(emptyView_Doze)
        emptyView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }

        let iconIv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 44, weight: .thin)
        iconIv.image = UIImage(systemName: "moon.zzz", withConfiguration: cfg)
        iconIv.tintColor = ColorConfig_Doze.textPlaceholder_Doze
        emptyView_Doze.addSubview(iconIv)
        iconIv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(56)
        }

        let lbl = UILabel()
        lbl.text = "No posts yet"
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.textAlignment = .center
        emptyView_Doze.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.top.equalTo(iconIv.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    private func loadData_Doze() {
        let user = meModel_Doze ?? UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        refreshHeader_Doze(user: user)
        refreshGrid_Doze(user: user)
    }

    /// 刷新头部用户信息
    private func refreshHeader_Doze(user: LoginUserModel_Doze) {
        avatarView_Doze.configure_Doze(userId_Doze: user.userId_Doze ?? 0)
        userNameLabel_Doze.text = user.userName_Doze ?? "Dozer"
        bioLabel_Doze.text = user.userIntroduce_Doze?.isEmpty == false
            ? user.userIntroduce_Doze
            : "No bio yet · Tap edit to add"

        // 重建统计行
        statsRow_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let postsCount = user.userPosts_Doze.count
        let likedCount = user.userLike_Doze.count
        let followCount = user.userFollow_Doze.count

        // 先创建 item 持有引用，用于后续添加等宽约束
        let item1 = makeStatItem_Doze(value: "\(postsCount)", label: "Posts", icon: "square.grid.2x2.fill")
        let item2 = makeStatItem_Doze(value: "\(likedCount)", label: "Liked", icon: "heart.fill")
        let item3 = makeStatItem_Doze(value: "\(followCount)", label: "Following", icon: "person.2.fill")

        statsRow_Doze.addArrangedSubview(item1)
        statsRow_Doze.addArrangedSubview(makeDivider_Doze())
        statsRow_Doze.addArrangedSubview(item2)
        statsRow_Doze.addArrangedSubview(makeDivider_Doze())
        statsRow_Doze.addArrangedSubview(item3)

        // 三列等宽：配合 .fill 分布使分隔线保持 1pt，不被拉伸
        item1.snp.makeConstraints { make in make.width.equalTo(item2) }
        item3.snp.makeConstraints { make in make.width.equalTo(item2) }
    }

    /// 构建统计数值项（含顶部小图标、数值、标签）
    private func makeStatItem_Doze(value: String, label: String, icon: String) -> UIView {
        let v = UIView()

        // 顶部小图标
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let iconIv = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconCfg))
        iconIv.tintColor = UIColor.white.withAlphaComponent(0.65)
        iconIv.contentMode = .scaleAspectFit

        let valLbl = UILabel()
        valLbl.text = value
        valLbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valLbl.textColor = .white
        valLbl.textAlignment = .center

        let nameLbl = UILabel()
        nameLbl.text = label
        nameLbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        nameLbl.textColor = UIColor.white.withAlphaComponent(0.75)
        nameLbl.textAlignment = .center

        v.addSubview(iconIv)
        v.addSubview(valLbl)
        v.addSubview(nameLbl)

        iconIv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(12)
        }
        valLbl.snp.makeConstraints { make in
            make.top.equalTo(iconIv.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        nameLbl.snp.makeConstraints { make in
            make.top.equalTo(valLbl.snp.bottom).offset(3)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return v
    }

    /// 构建统计行分隔线
    private func makeDivider_Doze() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        v.snp.makeConstraints { make in make.width.equalTo(1); make.height.equalTo(28) }
        return v
    }

    /// 刷新帖子网格
    @MainActor private func refreshGrid_Doze(user: LoginUserModel_Doze) {
        gridContainer_Doze.subviews.forEach { $0.removeFromSuperview() }

        let posts = activeTab_Doze == 0 ? user.userPosts_Doze : user.userLike_Doze

        if posts.isEmpty {
            emptyView_Doze.isHidden = false
            emptyView_Doze.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(60)
                make.width.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            return
        }

        emptyView_Doze.isHidden = true

        // 双列布局
        let colLeft_Doze = UIStackView()
        colLeft_Doze.axis = .vertical
        colLeft_Doze.spacing = 10

        let colRight_Doze = UIStackView()
        colRight_Doze.axis = .vertical
        colRight_Doze.spacing = 10

        let screenW = UIScreen.main.bounds.width
        let cardW = (screenW - 36) / 2

        for (idx, post) in posts.enumerated() {
            let card = makePostCard_Doze(post: post, width: cardW)
            if idx % 2 == 0 {
                colLeft_Doze.addArrangedSubview(card)
            } else {
                colRight_Doze.addArrangedSubview(card)
            }
        }

        gridContainer_Doze.addSubview(colLeft_Doze)
        gridContainer_Doze.addSubview(colRight_Doze)

        colLeft_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(cardW)
        }
        colRight_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(cardW)
        }

        // 底部撑开 gridContainer
        let anchor = UIView()
        gridContainer_Doze.addSubview(anchor)
        anchor.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(colLeft_Doze.snp.bottom)
            make.top.greaterThanOrEqualTo(colRight_Doze.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
    }

    /// 构建单个帖子卡片
    /// - Parameters:
    ///   - post: 帖子数据模型
    ///   - width: 卡片宽度
    /// - Returns: 组装好的卡片视图
    @MainActor private func makePostCard_Doze(post: TitleModel_Doze, width: CGFloat) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor(hexstring_Doze: "#8B5CF6").withAlphaComponent(0.10).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 10
        card.layer.shadowOpacity = 1
        card.snp.makeConstraints { make in make.width.equalTo(width) }

        // 使用 MediaDisplayView_Doze 展示媒体（内部已处理圆角/裁剪/占位）
        let mediaView = MediaDisplayView_Doze()
        mediaView.layer.cornerRadius = 14
        mediaView.configure_Doze(mediaPath_Doze: post.titleMeidas_Doze.first)
        card.addSubview(mediaView)
        mediaView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(width * 0.9)
        }

        // 媒体底部渐变遮罩（提升文字可读性）
        let overlayView = UIView()
        mediaView.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(width * 0.35)
        }
        let overlayGl = CAGradientLayer()
        overlayGl.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.28).cgColor]
        overlayGl.startPoint = CGPoint(x: 0.5, y: 0)
        overlayGl.endPoint = CGPoint(x: 0.5, y: 1)
        overlayView.layer.addSublayer(overlayGl)
        DispatchQueue.main.async { overlayGl.frame = overlayView.bounds }

        // 宠物类别 badge（左上角叠加在媒体上）
        let badge = UIView()
        badge.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        badge.layer.cornerRadius = 8
        let badgeLbl = UILabel()
        badgeLbl.text = post.petCategory_Doze.rawValue
        badgeLbl.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        badgeLbl.textColor = .white
        badge.addSubview(badgeLbl)
        badgeLbl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.left.right.equalToSuperview().inset(6)
        }
        mediaView.addSubview(badge)
        badge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
        }

        // 举报/删除按钮（右上角，本人帖子显示 trash，他人帖子显示 ellipsis）
        let reportBtn = ReportDeleteHelper_Doze.createPostReportButton_Doze(
            post_Doze: post,
            size_Doze: 13,
            color_Doze: .white,
            from: self
        ) { [weak self] in
            // 操作完成后刷新列表
            self?.loadData_Doze()
        }
        reportBtn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        reportBtn.layer.cornerRadius = 14
        mediaView.addSubview(reportBtn)
        reportBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }

        // 标题
        let titleLbl = UILabel()
        titleLbl.text = post.title_Doze
        titleLbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLbl.textColor = ColorConfig_Doze.textPrimary_Doze
        titleLbl.numberOfLines = 2
        card.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(mediaView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(10)
        }

        // 底部：点赞数
        let likeRow = UIStackView()
        likeRow.axis = .horizontal
        likeRow.spacing = 4
        likeRow.alignment = .center

        let heartIv = UIImageView()
        let hCfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        heartIv.image = UIImage(systemName: "heart.fill", withConfiguration: hCfg)
        heartIv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        heartIv.snp.makeConstraints { make in make.width.height.equalTo(12) }

        let likeLbl = UILabel()
        likeLbl.text = "\(post.likes_Doze)"
        likeLbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        likeLbl.textColor = ColorConfig_Doze.textSecondary_Doze

        likeRow.addArrangedSubview(heartIv)
        likeRow.addArrangedSubview(likeLbl)
        card.addSubview(likeRow)
        likeRow.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        return card
    }

    // MARK: - 通知监听

    private func observeNotifications_Doze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Doze),
            name: UserViewModel_Doze.userStateDidChangeNotification_Doze,
            object: nil
        )
    }

    @objc private func handleUserStateChange_Doze() {
        loadData_Doze()
    }

    // MARK: - 事件处理

    /// Tab 切换（滑动白色胶囊滑块）
    @objc private func tabTapped_Doze(_ sender: UIButton) {
        let idx = sender.tag
        guard idx != activeTab_Doze else { return }
        activeTab_Doze = idx
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let isLeft = idx == 0
        postsTabBtn_Doze.setTitleColor(isLeft ? ColorConfig_Doze.primaryGradientStart_Doze : ColorConfig_Doze.textSecondary_Doze, for: .normal)
        postsTabBtn_Doze.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: isLeft ? .semibold : .regular)
        likedTabBtn_Doze.setTitleColor(!isLeft ? ColorConfig_Doze.primaryGradientStart_Doze : ColorConfig_Doze.textSecondary_Doze, for: .normal)
        likedTabBtn_Doze.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: !isLeft ? .semibold : .regular)

        // 滑块滑动：左侧贴左，右侧贴右
        tabIndicator_Doze.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-3)
            if isLeft {
                make.left.equalToSuperview().offset(3)
            } else {
                make.right.equalToSuperview().offset(-3)
            }
        }
        UIView.animate(withDuration: 0.28, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            self.tabBar_Doze.layoutIfNeeded()
        }

        let user = meModel_Doze ?? UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        refreshGrid_Doze(user: user)
    }

    // MARK: - 入场动画

    /// 页面元素弹入入场动画
    private func animateEntrance_Doze() {
        let elements: [UIView] = [
            avatarContainer_Doze, userNameLabel_Doze, bioLabel_Doze,
            badgeRowStack_Doze, statsRow_Doze, tabBarBg_Doze
        ]
        elements.enumerated().forEach { idx, view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 22)
            UIView.animate(
                withDuration: 0.48,
                delay: Double(idx) * 0.06,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut]
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }

    /// 点击编辑按钮
    @objc private func handleEdit_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        editButton_Doze.animatePressDown_Doze { self.editButton_Doze.animatePressUp_Doze() }
        Navigation_Doze.toEditInfo_Doze()
    }

    /// 点击设置按钮
    @objc private func handleSetting_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        settingButton_Doze.animatePressDown_Doze { self.settingButton_Doze.animatePressUp_Doze() }
        Navigation_Doze.toSetting_Doze()
    }
}
