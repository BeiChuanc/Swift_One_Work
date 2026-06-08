import Foundation
import UIKit
import SnapKit

// MARK: - 我的页面

/// 我的页面视图控制器
/// 核心作用：展示当前登录用户个人信息、帖子列表及点赞列表
/// 设计思路：
///   - 头部：暖橙渐变大卡（240pt）+ 装饰气泡 + 大头像环 + 白色悬浮统计卡（Posts|Likes|Following）
///   - 自定义 Tab：渐变选中/描边未选中，替代系统 UISegmentedControl
///   - 帖子卡片：渐变左竖条 + 大缩略图 + 心形/评论双统计
///   - 背景：暖杏白 #FFF8F2，与渐变头部自然延续
class Me_Lumia: UIViewController {

    // MARK: - 公开属性

    var meModel_Lumia: LoginUserModel_Lumia?

    // MARK: - 私有属性

    private var displayPosts_Lumia: [TitleModel_Lumia] = []
    private var selectedTab_Lumia: Int = 0

    // MARK: - UI组件

    private lazy var tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .plain)
        tv_Lumia.separatorStyle = .none
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FFF8F2")
        tv_Lumia.showsVerticalScrollIndicator = false
        tv_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        // 关闭自动 SafeArea 内容偏移，使 tableHeaderView 从屏幕顶部 y=0 开始，消除顶部空隙
        tv_Lumia.contentInsetAdjustmentBehavior = .never
        return tv_Lumia
    }()

    private let profileHeader_Lumia = MeProfileHeader_Lumia()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        setupObservers_Lumia()
        loadData_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#FFF8F2")
        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(MePostCell_Lumia.self, forCellReuseIdentifier: MePostCell_Lumia.reuseId_Lumia)
        setupTableHeader_Lumia()
    }

    private func setupTableHeader_Lumia() {
        profileHeader_Lumia.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 380)
        profileHeader_Lumia.onSettingsTapped_Lumia = { Navigation_Lumia.toSetting_Lumia() }
        profileHeader_Lumia.onEditTapped_Lumia = { Navigation_Lumia.toEditInfo_Lumia() }
        profileHeader_Lumia.onVIPTapped_Lumia = { [weak self] in
            guard let self else { return }
            let vipVC_Lumia = VIPSubscription_Lumia()
            Navigation_Lumia.push_Lumia(to: vipVC_Lumia, from: self)
        }
        profileHeader_Lumia.onTabChanged_Lumia = { [weak self] idx_Lumia in
            self?.selectedTab_Lumia = idx_Lumia
            self?.loadData_Lumia()
        }
        tableView_Lumia.tableHeaderView = profileHeader_Lumia
    }

    // MARK: - 数据加载

    private func loadData_Lumia() {
        let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()
        profileHeader_Lumia.configure_Lumia(user: user_Lumia)
        displayPosts_Lumia = selectedTab_Lumia == 0 ? user_Lumia.userPosts_Lumia : user_Lumia.userLike_Lumia
        tableView_Lumia.reloadData()
        tableView_Lumia.tableHeaderView?.frame.size.height = 380
        tableView_Lumia.tableHeaderView = tableView_Lumia.tableHeaderView
    }

    // MARK: - 通知监听

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTitleChange_Lumia),
            name: TitleViewModel_Lumia.titleStateDidChangeNotification_Lumia, object: nil)
    }

    @objc private func handleUserChange_Lumia() { loadData_Lumia() }
    @objc private func handleTitleChange_Lumia() { loadData_Lumia() }
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITableViewDelegate & DataSource

extension Me_Lumia: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayPosts_Lumia.isEmpty ? 1 : displayPosts_Lumia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayPosts_Lumia.isEmpty {
            return makeEmptyCell_Lumia(tableView, indexPath)
        }
        let cell_Lumia = tableView.dequeueReusableCell(
            withIdentifier: MePostCell_Lumia.reuseId_Lumia, for: indexPath
        ) as! MePostCell_Lumia
        cell_Lumia.configure_Lumia(post: displayPosts_Lumia[indexPath.row], from: self)
        return cell_Lumia
    }

    /// 构建空状态 Cell
    private func makeEmptyCell_Lumia(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = UITableViewCell()
        cell_Lumia.backgroundColor = .clear
        cell_Lumia.selectionStyle = .none

        let iconView_Lumia = UIImageView()
        iconView_Lumia.image = UIImage(systemName: selectedTab_Lumia == 0 ? "camera.on.rectangle" : "heart.circle")
        iconView_Lumia.tintColor = UIColor(hexstring_Lumia: "#F6A623", alpha_Lumia: 0.45)
        iconView_Lumia.contentMode = .scaleAspectFit
        cell_Lumia.contentView.addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }

        let label_Lumia = UILabel()
        label_Lumia.text = selectedTab_Lumia == 0
            ? "No posts yet.\nShare your first film moment!"
            : "No liked posts yet."
        label_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_Lumia.textColor = UIColor(hexstring_Lumia: "#C08060")
        label_Lumia.textAlignment = .center
        label_Lumia.numberOfLines = 0
        cell_Lumia.contentView.addSubview(label_Lumia)
        label_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconView_Lumia.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-30)
        }
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return displayPosts_Lumia.isEmpty ? UITableView.automaticDimension : 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !displayPosts_Lumia.isEmpty else { return }
        Navigation_Lumia.toTitleDetail_Lumia(titleModel_lumia: displayPosts_Lumia[indexPath.row])
    }
}

// MARK: - 我的页面 Profile Header

/// 我的页面头部视图
/// 核心作用：展示头像、用户名、简介、统计数据、编辑入口及分段 Tab
/// 设计思路：
///   - 暖橙→珊瑚红大渐变背景（240pt）+ 右侧装饰气泡，视觉层次丰富
///   - 头像：100pt + 白色渐变光环 + 白色底色圆圈，立体感强
///   - 白色悬浮统计卡（Posts | Likes | Following）叠在渐变与白底交界处
///   - 自定义 Tab：渐变填充选中 / 描边未选中，替代系统 UISegmentedControl
private class MeProfileHeader_Lumia: UIView {

    // MARK: - 回调

    var onSettingsTapped_Lumia: (() -> Void)?
    var onEditTapped_Lumia: (() -> Void)?
    var onVIPTapped_Lumia: (() -> Void)?
    var onTabChanged_Lumia: ((Int) -> Void)?

    // MARK: - UI组件

    private let bgView_Lumia = UIView()
    private var gradientLayer_Lumia: CAGradientLayer?

    /// 设置按钮（半透明白色圆形）
    private let settingsButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_Lumia.layer.cornerRadius = 19
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn_Lumia
    }()

    /// 头像外层白色光环
    private let avatarRingView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .clear
        v_Lumia.layer.cornerRadius = 56
        v_Lumia.layer.borderWidth = 3.5
        v_Lumia.layer.borderColor = UIColor.white.cgColor
        v_Lumia.layer.shadowColor = UIColor.black.cgColor
        v_Lumia.layer.shadowOpacity = 0.18
        v_Lumia.layer.shadowRadius = 12
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v_Lumia
    }()

    private let avatarView_Lumia: CurrentUserAvatarView_Lumia = {
        let v_Lumia = CurrentUserAvatarView_Lumia(frame: .zero)
        v_Lumia.layer.cornerRadius = 50
        v_Lumia.clipsToBounds = true
        return v_Lumia
    }()

    private let userNameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        lbl_Lumia.textColor = .white
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let introLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.78)
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    /// Edit Profile 按钮（与设置按钮同款：半透明白底 + 白色描边 + 白色文字）
    private let editButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "pencil", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.setTitle("  Edit", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_Lumia.layer.cornerRadius = 19
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn_Lumia
    }()

    /// VIP 按钮：使用 Assets 中的 vip_btn 图片，宽度随图片自适应，高度与 Edit 按钮保持一致
    private let vipButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setImage(UIImage(named: "vip_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn_Lumia.imageView?.contentMode = .scaleAspectFit
        btn_Lumia.contentMode = .scaleAspectFit
        btn_Lumia.layer.cornerRadius = 19
        btn_Lumia.clipsToBounds = true
        return btn_Lumia
    }()

    /// 悬浮统计卡（白色，叠在渐变底部）
    private let statsCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#F6A623").cgColor
        v_Lumia.layer.shadowOpacity = 0.15
        v_Lumia.layer.shadowRadius = 16
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v_Lumia
    }()

    private let postsStatView_Lumia = MeStatItem_Lumia(label: "Posts")
    private let likesStatView_Lumia = MeStatItem_Lumia(label: "Likes")
    private let followStatView_Lumia = MeStatItem_Lumia(label: "Following")

    /// 自定义 Tab 控制
    private let tabContainer_Lumia = UIView()
    private let postsTabBtn_Lumia = UIButton(type: .custom)
    private let likedTabBtn_Lumia = UIButton(type: .custom)
    private var postsTabGradient_Lumia: CAGradientLayer?
    private var likedTabGradient_Lumia: CAGradientLayer?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 从 KeyWindow 读取实际顶部安全区域高度（适配刘海/灵动岛/无刘海机型）
    private var topSafeArea_Lumia: CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.safeAreaInsets.top ?? 44
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Lumia?.frame = bgView_Lumia.bounds
        updateTabGradients_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#FFF8F2")
        setupBgView_Lumia()
        setupAvatarArea_Lumia()
        setupStatsCard_Lumia()
        setupTabControl_Lumia()
    }

    /// 配置渐变背景区（含装饰气泡、设置按钮）
    private func setupBgView_Lumia() {
        addSubview(bgView_Lumia)
        bgView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
        bgView_Lumia.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bgView_Lumia.layer.cornerRadius = 30
        bgView_Lumia.clipsToBounds = true

        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F6A623").cgColor,
            UIColor(hexstring_Lumia: "#E8614A").cgColor,
            UIColor(hexstring_Lumia: "#C54E8A").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        bgView_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        gradientLayer_Lumia = gradient_Lumia

        // 右侧大装饰气泡
        let b1_Lumia = makeDecoBubble_Lumia(size: 120, alpha: 0.09)
        bgView_Lumia.addSubview(b1_Lumia)
        b1_Lumia.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: -40, width: 120, height: 120)

        let b2_Lumia = makeDecoBubble_Lumia(size: 70, alpha: 0.12)
        bgView_Lumia.addSubview(b2_Lumia)
        b2_Lumia.frame = CGRect(x: UIScreen.main.bounds.width - 95, y: 70, width: 70, height: 70)

        let b3_Lumia = makeDecoBubble_Lumia(size: 44, alpha: 0.08)
        bgView_Lumia.addSubview(b3_Lumia)
        b3_Lumia.frame = CGRect(x: -20, y: 80, width: 44, height: 44)

        // 设置按钮（使用窗口实际安全区域高度定位，避免 safeAreaLayoutGuide 在 tableHeaderView 中失效）
        bgView_Lumia.addSubview(settingsButton_Lumia)
        settingsButton_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topSafeArea_Lumia + 10)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(38)
        }
        settingsButton_Lumia.addTarget(self, action: #selector(handleSettings_Lumia), for: .touchUpInside)

        // Edit 按钮：同款样式，位于设置按钮左侧 10pt，垂直居中对齐
        bgView_Lumia.addSubview(editButton_Lumia)
        editButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(settingsButton_Lumia)
            make.trailing.equalTo(settingsButton_Lumia.snp.leading).offset(-10)
            make.height.equalTo(38)
            make.width.greaterThanOrEqualTo(38)
        }
        editButton_Lumia.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        editButton_Lumia.addTarget(self, action: #selector(handleEdit_Lumia), for: .touchUpInside)

        // VIP 按钮：位于 Edit/Settings 按钮正下方 10pt，紧贴右边缘，宽度由 vip_btn 图片自适应
        bgView_Lumia.addSubview(vipButton_Lumia)
        vipButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(settingsButton_Lumia.snp.bottom).offset(10)
            make.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        vipButton_Lumia.addTarget(self, action: #selector(handleVIP_Lumia), for: .touchUpInside)
    }

    /// 创建装饰气泡
    private func makeDecoBubble_Lumia(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Lumia.layer.cornerRadius = size / 2
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }

    /// 配置头像 + 用户名 + 简介 + 编辑按钮
    private func setupAvatarArea_Lumia() {
        // 头像光环（同样使用窗口安全区域高度，确保与设置按钮对齐）
        bgView_Lumia.addSubview(avatarRingView_Lumia)
        avatarRingView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topSafeArea_Lumia + 12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(112)
        }

        avatarRingView_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }

        bgView_Lumia.addSubview(userNameLabel_Lumia)
        userNameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Lumia.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        bgView_Lumia.addSubview(introLabel_Lumia)
        introLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Lumia.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    /// 配置悬浮统计卡（叠在渐变底部）
    private func setupStatsCard_Lumia() {
        addSubview(statsCard_Lumia)
        statsCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(bgView_Lumia.snp.bottom).offset(-22)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(68)
        }

        let divider1_Lumia = makeStatDivider_Lumia()
        let divider2_Lumia = makeStatDivider_Lumia()

        let stack_Lumia = UIStackView(arrangedSubviews: [postsStatView_Lumia, divider1_Lumia, likesStatView_Lumia, divider2_Lumia, followStatView_Lumia])
        stack_Lumia.axis = .horizontal
        stack_Lumia.distribution = .fill
        stack_Lumia.alignment = .center

        statsCard_Lumia.addSubview(stack_Lumia)
        stack_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }

        divider1_Lumia.snp.makeConstraints { make in make.width.equalTo(1); make.height.equalTo(32) }
        divider2_Lumia.snp.makeConstraints { make in make.width.equalTo(1); make.height.equalTo(32) }
        postsStatView_Lumia.snp.makeConstraints { make in make.width.equalTo(followStatView_Lumia) }
        likesStatView_Lumia.snp.makeConstraints { make in make.width.equalTo(followStatView_Lumia) }
    }

    /// 竖向分隔线
    private func makeStatDivider_Lumia() -> UIView {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F0D8C8")
        return v_Lumia
    }

    /// 配置自定义 Tab 按钮（渐变选中 / 描边未选中）
    private func setupTabControl_Lumia() {
        addSubview(tabContainer_Lumia)
        tabContainer_Lumia.backgroundColor = .clear
        tabContainer_Lumia.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Lumia.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-8)
        }

        // Posts Tab
        postsTabBtn_Lumia.setTitle("My Posts", for: .normal)
        postsTabBtn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        postsTabBtn_Lumia.layer.cornerRadius = 20
        postsTabBtn_Lumia.tag = 0
        postsTabBtn_Lumia.addTarget(self, action: #selector(handleTabTap_Lumia(_:)), for: .touchUpInside)

        // Liked Tab
        likedTabBtn_Lumia.setTitle("Liked", for: .normal)
        likedTabBtn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        likedTabBtn_Lumia.layer.cornerRadius = 20
        likedTabBtn_Lumia.tag = 1
        likedTabBtn_Lumia.addTarget(self, action: #selector(handleTabTap_Lumia(_:)), for: .touchUpInside)

        tabContainer_Lumia.addSubview(postsTabBtn_Lumia)
        tabContainer_Lumia.addSubview(likedTabBtn_Lumia)

        postsTabBtn_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-4)
        }
        likedTabBtn_Lumia.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-4)
        }

        updateTabStyle_Lumia(selected: 0)
    }

    /// 更新 Tab 选中样式
    private func updateTabStyle_Lumia(selected: Int) {
        [postsTabBtn_Lumia, likedTabBtn_Lumia].forEach { btn_Lumia in
            let isSelected_Lumia = btn_Lumia.tag == selected
            btn_Lumia.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

            if isSelected_Lumia {
                btn_Lumia.setTitleColor(.white, for: .normal)
                btn_Lumia.backgroundColor = .clear
                btn_Lumia.layer.borderWidth = 0
                let grad_Lumia = CAGradientLayer()
                grad_Lumia.colors = [
                    UIColor(hexstring_Lumia: "#F6A623").cgColor,
                    UIColor(hexstring_Lumia: "#E8614A").cgColor
                ]
                grad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
                grad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
                grad_Lumia.cornerRadius = 20
                btn_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
                DispatchQueue.main.async { grad_Lumia.frame = btn_Lumia.bounds }
            } else {
                btn_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#C08060"), for: .normal)
                btn_Lumia.backgroundColor = .white
                btn_Lumia.layer.borderWidth = 1.5
                btn_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#F0C898").cgColor
            }
        }
    }

    /// 延迟刷新 Tab 渐变 frame
    private func updateTabGradients_Lumia() {
        [postsTabBtn_Lumia, likedTabBtn_Lumia].forEach { btn_Lumia in
            btn_Lumia.layer.sublayers?.compactMap { $0 as? CAGradientLayer }.forEach { $0.frame = btn_Lumia.bounds }
        }
    }

    // MARK: - 数据绑定

    /// 配置用户信息与统计数据
    /// - Parameter user: 当前登录用户模型
    func configure_Lumia(user: LoginUserModel_Lumia) {
        let isLoggedIn_Lumia = UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia
        userNameLabel_Lumia.text = isLoggedIn_Lumia ? (user.userName_Lumia ?? "User") : "Guest"
        // 优先展示用户填写的简介，未填则用默认引导文案
        if isLoggedIn_Lumia {
            let intro_Lumia = user.userIntroduce_Lumia ?? ""
            introLabel_Lumia.text = intro_Lumia.isEmpty ? "Film diary explorer ✦" : intro_Lumia
        } else {
            introLabel_Lumia.text = "Login to share your film moments"
        }
        postsStatView_Lumia.setValue_Lumia("\(user.userPosts_Lumia.count)")
        likesStatView_Lumia.setValue_Lumia("\(user.userLike_Lumia.count)")
        followStatView_Lumia.setValue_Lumia("\(user.userFollow_Lumia.count)")
    }

    // MARK: - 事件

    @objc private func handleSettings_Lumia() { onSettingsTapped_Lumia?() }
    @objc private func handleEdit_Lumia() { onEditTapped_Lumia?() }
    @objc private func handleVIP_Lumia() { onVIPTapped_Lumia?() }

    @objc private func handleTabTap_Lumia(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        updateTabStyle_Lumia(selected: sender.tag)
        onTabChanged_Lumia?(sender.tag)
    }
}

// MARK: - 统计数据项 View

/// 个人主页统计数据单项（大数字 + 小标签）
private class MeStatItem_Lumia: UIView {

    private let valueLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#3A1A08")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.text = "0"
        return lbl_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C08060")
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    /// 初始化统计项
    /// - Parameter label: 标签文字（如 "Posts"、"Likes"）
    init(label: String) {
        super.init(frame: .zero)
        titleLabel_Lumia.text = label
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Lumia() {
        addSubview(valueLabel_Lumia)
        addSubview(titleLabel_Lumia)
        valueLabel_Lumia.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
            make.leading.trailing.equalToSuperview()
        }
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Lumia.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    /// 更新数字显示
    /// - Parameter value_Lumia: 要显示的数字字符串
    func setValue_Lumia(_ value_Lumia: String) {
        valueLabel_Lumia.text = value_Lumia
    }
}

// MARK: - 帖子 Cell

/// 我的页面帖子卡片 Cell
/// 核心作用：以横向布局展示单条帖子，含渐变左条、方形缩略图、标题、统计双行
/// 设计思路：
///   - 卡片背景：白色 + 暖橙调阴影
///   - 左侧 4pt 渐变色条（橙→红）作为视觉节奏标记
///   - 缩略图：100pt 等宽正方形
///   - 右侧：标题（粗）+ 内容摘要（灰）+ 点赞/评论双统计行
class MePostCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "MePostCell_Lumia"

    private var currentPost_Lumia: TitleModel_Lumia?
    private weak var fromVC_Lumia: UIViewController?

    // MARK: - UI 组件

    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 16
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#F6A623").cgColor
        v_Lumia.layer.shadowOpacity = 0.13
        v_Lumia.layer.shadowRadius = 12
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Lumia.clipsToBounds = false
        return v_Lumia
    }()

    /// 左侧渐变色条（橙→红）
    private let accentBar_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 2
        v_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return v_Lumia
    }()
    private var accentGradient_Lumia: CAGradientLayer?

    /// 方形缩略图
    private let thumbView_Lumia: MediaDisplayView_Lumia = {
        let mv_Lumia = MediaDisplayView_Lumia()
        mv_Lumia.layer.cornerRadius = 12
        mv_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        mv_Lumia.clipsToBounds = true
        return mv_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1008")
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let contentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A07858")
        lbl_Lumia.numberOfLines = 1
        return lbl_Lumia
    }()

    /// 点赞统计
    private let likeIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "heart.fill")
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#F5576C")
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let likeCountLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A07858")
        return lbl_Lumia
    }()

    /// 评论统计
    private let commentIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "bubble.left.fill")
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#F6A623")
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let commentCountLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#A07858")
        return lbl_Lumia
    }()

    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#C0A080")
        return btn_Lumia
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        accentGradient_Lumia?.frame = accentBar_Lumia.bounds
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        contentView.addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }

        // 左侧渐变色条
        cardView_Lumia.addSubview(accentBar_Lumia)
        accentBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        let accentGrad_Lumia = CAGradientLayer()
        accentGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F6A623").cgColor,
            UIColor(hexstring_Lumia: "#E8614A").cgColor
        ]
        accentGrad_Lumia.startPoint = CGPoint(x: 0.5, y: 0)
        accentGrad_Lumia.endPoint = CGPoint(x: 0.5, y: 1)
        accentGrad_Lumia.cornerRadius = 2
        accentBar_Lumia.layer.insertSublayer(accentGrad_Lumia, at: 0)
        accentGradient_Lumia = accentGrad_Lumia

        // 缩略图（正方形，左侧）
        cardView_Lumia.addSubview(thumbView_Lumia)
        thumbView_Lumia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(accentBar_Lumia.snp.trailing)
            make.width.equalTo(100)
        }

        // 举报按钮
        cardView_Lumia.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)

        // 标题
        cardView_Lumia.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(thumbView_Lumia.snp.trailing).offset(12)
            make.trailing.equalTo(reportButton_Lumia.snp.leading).offset(-4)
        }

        // 内容摘要
        cardView_Lumia.addSubview(contentLabel_Lumia)
        contentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(5)
            make.leading.trailing.equalTo(titleLabel_Lumia)
        }

        // 点赞图标 + 数字
        cardView_Lumia.addSubview(likeIcon_Lumia)
        likeIcon_Lumia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.leading.equalTo(titleLabel_Lumia)
            make.width.height.equalTo(13)
        }
        cardView_Lumia.addSubview(likeCountLabel_Lumia)
        likeCountLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(likeIcon_Lumia.snp.trailing).offset(4)
        }

        // 评论图标 + 数字
        cardView_Lumia.addSubview(commentIcon_Lumia)
        commentIcon_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(likeCountLabel_Lumia.snp.trailing).offset(14)
            make.width.height.equalTo(13)
        }
        cardView_Lumia.addSubview(commentCountLabel_Lumia)
        commentCountLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeIcon_Lumia)
            make.leading.equalTo(commentIcon_Lumia.snp.trailing).offset(4)
        }
    }

    // MARK: - 数据绑定

    /// 配置 Cell 数据
    func configure_Lumia(post: TitleModel_Lumia, from vc: UIViewController) {
        currentPost_Lumia = post
        fromVC_Lumia = vc
        thumbView_Lumia.configure_Lumia(mediaPath_Lumia: post.titleMeidas_Lumia.first)
        titleLabel_Lumia.text = post.title_Lumia
        contentLabel_Lumia.text = post.titleContent_Lumia
        likeCountLabel_Lumia.text = "\(post.likes_Lumia)"
        commentCountLabel_Lumia.text = "\(post.reviews_Lumia.count)"
    }

    @objc private func handleReport_Lumia() {
        guard let post_Lumia = currentPost_Lumia, let vc_Lumia = fromVC_Lumia else { return }
        let isMyPost_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(userId_lumia: post_Lumia.titleUserId_Lumia)
        if isMyPost_Lumia {
            ReportDeleteHelper_Lumia.delete_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        } else {
            ReportDeleteHelper_Lumia.report_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        }
    }
}
