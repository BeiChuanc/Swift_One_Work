import Foundation
import UIKit
import SnapKit

// MARK: 我的页面 - 优化版

/// 我的页面控制器
/// 核心作用：展示登录用户信息（头像、昵称、简介、三项统计），可切换查看发布/喜欢帖子
/// 设计思路：圆角渐变头部（内容自适应高度）+ 三格统计卡片 + 滑动 Tab 分段 + 帖子列表 + 空状态
class Me_Retrs: UIViewController {

    // MARK: - 属性

    var meModel_Retrs: LoginUserModel_Retrs?

    private let userVM_Retrs  = UserViewModel_Retrs.shared_Retrs
    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs

    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 渐变头部
    private let headerView_Retrs      = UIView()
    private let headerGradLayer_Retrs = CAGradientLayer()
    private let settingBtn_Retrs      = UIButton(type: .system)
    private let vipBtn_Retrs          = UIButton(type: .custom)
    private let avatarView_Retrs      = CurrentUserAvatarView_Retrs()
    private let nameLabel_Retrs       = UILabel()
    private let introLabel_Retrs      = UILabel()
    private let editBtn_Retrs         = UIButton(type: .system)

    /// 三格统计卡片
    private let statsWrap_Retrs   = UIStackView()
    private let followLabel_Retrs = UILabel()
    private let likesLabel_Retrs  = UILabel()
    private let postsLabel_Retrs  = UILabel()

    /// 分段控制器（自定义：pill 滑动动画）
    private let segCard_Retrs       = UIView()
    private let segPill_Retrs       = UIView()       // 滑动胶囊（约束驱动动画）
    private let postsTabBtn_Retrs   = UIButton(type: .system)
    private let likedTabBtn_Retrs   = UIButton(type: .system)
    private var segPillLeading_Retrs: Constraint?    // 存储 leading 约束，用于动画
    private var currentSeg_Retrs    = 0

    /// 帖子列表
    private let tableView_Retrs     = UITableView()
    private var displayPosts_Retrs: [TitleModel_Retrs] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData_Retrs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        setupStatsRow_Retrs()
        setupSegControl_Retrs()
        setupTableView_Retrs()
        setupConstraints_Retrs()
        observeNotifications_Retrs()
        reloadData_Retrs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerView_Retrs.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 主滚动视图

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        // 禁止自动添加 SafeArea 偏移，让头部渐变紧贴屏幕顶边
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
    }

    // MARK: - 渐变头部

    /// 头部：薰衣草紫渐变 + 底部圆角 + 气泡装饰 + 头像 + 昵称 + 简介 + 编辑按钮
    private func setupHeaderView_Retrs() {
        // 渐变层
        headerGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        // 底部双圆角（与其他页头部保持一致）
        headerView_Retrs.layer.cornerRadius = 30
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡
        addBubble_Retrs(alpha: 0.12, size: 160, top: -50, trailing: -30)
        addBubble_Retrs(alpha: 0.08, size: 90,  bottom: -10, leading: -20)
        addBubble_Retrs(alpha: 0.06, size: 55,  bottom: 20, trailing: 30)

        // 设置按钮（右上角）
        settingBtn_Retrs.setImage(
            UIImage(systemName: "gearshape.fill",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)),
            for: .normal
        )
        settingBtn_Retrs.tintColor = UIColor.white.withAlphaComponent(0.9)
        settingBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        settingBtn_Retrs.layer.cornerRadius = 18
        settingBtn_Retrs.layer.borderWidth  = 1
        settingBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        settingBtn_Retrs.addTarget(self, action: #selector(settingTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(settingBtn_Retrs)

        // VIP 按钮（设置按钮同行最左边，使用 vip_btn 原图）
        vipBtn_Retrs.setImage(UIImage(named: "vip_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        vipBtn_Retrs.imageView?.contentMode = .scaleAspectFit
        vipBtn_Retrs.addTarget(self, action: #selector(vipBtnTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(vipBtn_Retrs)

        // 大头像（白色描边圆形）
        avatarView_Retrs.layer.borderWidth  = 4
        avatarView_Retrs.layer.borderColor  = UIColor.white.cgColor
        avatarView_Retrs.layer.cornerRadius = 48
        avatarView_Retrs.clipsToBounds = true
        avatarView_Retrs.onTapped_Retrs = { [weak self] in
            guard let self else { return }
            Navigation_Retrs.toEditInfo_Retrs()
        }
        headerView_Retrs.addSubview(avatarView_Retrs)

        // 昵称
        nameLabel_Retrs.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nameLabel_Retrs.textColor = .white
        nameLabel_Retrs.textAlignment = .center
        headerView_Retrs.addSubview(nameLabel_Retrs)

        // 简介
        introLabel_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        introLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.8)
        introLabel_Retrs.textAlignment = .center
        introLabel_Retrs.numberOfLines = 2
        headerView_Retrs.addSubview(introLabel_Retrs)

        // 编辑按钮（半透明胶囊）
        editBtn_Retrs.setTitle("Edit Profile", for: .normal)
        editBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        editBtn_Retrs.setTitleColor(.white, for: .normal)
        editBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        editBtn_Retrs.layer.cornerRadius = 16
        editBtn_Retrs.layer.borderWidth  = 1
        editBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.45).cgColor
        editBtn_Retrs.addTarget(self, action: #selector(editTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(editBtn_Retrs)
    }

    private func addBubble_Retrs(alpha: CGFloat, size: CGFloat,
                                  top: CGFloat? = nil, bottom: CGFloat? = nil,
                                  leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        let v_Retrs = UIView()
        v_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Retrs.layer.cornerRadius = size / 2
        headerView_Retrs.addSubview(v_Retrs)
        v_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size)
            if let t = top     { make.top.equalToSuperview().offset(t) }
            if let b = bottom  { make.bottom.equalToSuperview().offset(b) }
            if let l = leading { make.leading.equalToSuperview().offset(l) }
            if let r = trailing { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 三格统计卡片

    /// 三格统计卡片：Following / Liked / Posts，各为独立白色小卡
    private func setupStatsRow_Retrs() {
        statsWrap_Retrs.axis = .horizontal
        statsWrap_Retrs.spacing = 10
        statsWrap_Retrs.distribution = .fillEqually
        statsWrap_Retrs.alignment = .fill
        contentView_Retrs.addSubview(statsWrap_Retrs)

        let items_Retrs: [(UILabel, String, String)] = [
            (followLabel_Retrs, "Following", "person.2.fill"),
            (likesLabel_Retrs,  "Liked",     "heart.fill"),
            (postsLabel_Retrs,  "Posts",     "photo.fill")
        ]
        for item_Retrs in items_Retrs {
            statsWrap_Retrs.addArrangedSubview(
                buildStatCard_Retrs(numLabel_Retrs: item_Retrs.0,
                                    title_Retrs: item_Retrs.1,
                                    icon_Retrs: item_Retrs.2)
            )
        }
    }

    /// 构建单个统计卡片（白色圆角 + 渐变数字 + 图标 + 标题）
    private func buildStatCard_Retrs(numLabel_Retrs: UILabel, title_Retrs: String,
                                      icon_Retrs: String) -> UIView {
        let card_Retrs = UIView()
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 16
        card_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Retrs.layer.shadowOpacity = 1
        card_Retrs.layer.shadowRadius  = 10

        let iconIV_Retrs = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        )
        iconIV_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.5)
        iconIV_Retrs.contentMode = .scaleAspectFit
        card_Retrs.addSubview(iconIV_Retrs)
        iconIV_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(16)
        }

        numLabel_Retrs.font = UIFont.systemFont(ofSize: 20, weight: .black)
        numLabel_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        numLabel_Retrs.textAlignment = .center
        card_Retrs.addSubview(numLabel_Retrs)
        numLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(iconIV_Retrs.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs
        lbl_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        lbl_Retrs.textAlignment = .center
        card_Retrs.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(numLabel_Retrs.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
        }

        return card_Retrs
    }

    // MARK: - 自定义分段控制器（胶囊滑动）

    private func setupSegControl_Retrs() {
        // 外层背景卡片
        segCard_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        segCard_Retrs.layer.cornerRadius = 14
        contentView_Retrs.addSubview(segCard_Retrs)

        // 滑动胶囊（选中态背景）
        segPill_Retrs.backgroundColor = .white
        segPill_Retrs.layer.cornerRadius = 11
        segPill_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.12).cgColor
        segPill_Retrs.layer.shadowOffset = CGSize(width: 0, height: 2)
        segPill_Retrs.layer.shadowOpacity = 1
        segPill_Retrs.layer.shadowRadius  = 6
        segCard_Retrs.addSubview(segPill_Retrs)

        // Posts Tab
        postsTabBtn_Retrs.setTitle("  Posts", for: .normal)
        postsTabBtn_Retrs.setImage(
            UIImage(systemName: "photo.fill",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)),
            for: .normal
        )
        styleTabBtn_Retrs(postsTabBtn_Retrs, isSelected: true)
        postsTabBtn_Retrs.addTarget(self, action: #selector(postTabTapped_Retrs), for: .touchUpInside)
        segCard_Retrs.addSubview(postsTabBtn_Retrs)

        // Liked Tab
        likedTabBtn_Retrs.setTitle("  Liked", for: .normal)
        likedTabBtn_Retrs.setImage(
            UIImage(systemName: "heart.fill",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)),
            for: .normal
        )
        styleTabBtn_Retrs(likedTabBtn_Retrs, isSelected: false)
        likedTabBtn_Retrs.addTarget(self, action: #selector(likedTabTapped_Retrs), for: .touchUpInside)
        segCard_Retrs.addSubview(likedTabBtn_Retrs)
    }

    /// 应用 Tab 按钮样式（选中/未选中）
    private func styleTabBtn_Retrs(_ btn_Retrs: UIButton, isSelected: Bool) {
        btn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: isSelected ? .bold : .medium)
        let color_Retrs = isSelected
            ? ColorConfig_Retrs.primaryGradientStart_Retrs
            : ColorConfig_Retrs.textPlaceholder_Retrs
        btn_Retrs.setTitleColor(color_Retrs, for: .normal)
        btn_Retrs.tintColor = color_Retrs
    }

    // MARK: - 帖子列表

    private func setupTableView_Retrs() {
        tableView_Retrs.backgroundColor = .clear
        tableView_Retrs.separatorStyle  = .none
        tableView_Retrs.isScrollEnabled = false
        tableView_Retrs.register(MePostCell_Retrs.self, forCellReuseIdentifier: "MePostCell_Retrs")
        tableView_Retrs.dataSource = self
        tableView_Retrs.delegate   = self
        contentView_Retrs.addSubview(tableView_Retrs)
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44
        let pillW_Retrs   = (screenW_Retrs - 40 - 8) / 2   // 每个胶囊宽度（减去外边距和间隙）

        scrollView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }

        // 头部（高度由内容撑开）
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        settingBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        // VIP 按钮：在修改按钮下方 10pt，居中，高度自适应原图
        vipBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(editBtn_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)   // 与设置按钮等高
            make.bottom.equalToSuperview().offset(-24)   // 撑开 header 高度
        }
        avatarView_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 22)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(96)
        }
        nameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Retrs.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        introLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Retrs.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }
        editBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Retrs.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(130)
            make.height.equalTo(32)
        }

        // 三格统计卡片（从 header 向上重叠 20pt 形成层次）
        statsWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerView_Retrs.snp.bottom).offset(-12)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        // 分段控制器
        segCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(statsWrap_Retrs.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(46)
        }
        // 滑动胶囊（初始左侧）
        segPill_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.width.equalTo(pillW_Retrs)
            segPillLeading_Retrs = make.leading.equalToSuperview().offset(4).constraint
        }
        postsTabBtn_Retrs.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        likedTabBtn_Retrs.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        // 帖子列表
        tableView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(segCard_Retrs.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 数据加载

    private func reloadData_Retrs() {
        let currentUser_Retrs = userVM_Retrs.getCurrentUser_Retrs()
        if !userVM_Retrs.isLoggedIn_Retrs {
            nameLabel_Retrs.text   = "Guest"
            introLabel_Retrs.text  = "Sign in to explore more"
            followLabel_Retrs.text = "0"
            likesLabel_Retrs.text  = "0"
            postsLabel_Retrs.text  = "0"
            displayPosts_Retrs = []
            tableView_Retrs.reloadData()
            updateTableHeight_Retrs()
            return
        }
        nameLabel_Retrs.text   = currentUser_Retrs.userName_Retrs ?? "Wanderer"
        let preview_Retrs = userVM_Retrs.getUserById_Retrs(userId_retrs: currentUser_Retrs.userId_Retrs ?? 0)
        introLabel_Retrs.text  = preview_Retrs.userIntroduce_Retrs ?? "CCD Photography Enthusiast"
        followLabel_Retrs.text = "\(currentUser_Retrs.userFollow_Retrs.count)"
        likesLabel_Retrs.text  = "\(currentUser_Retrs.userLike_Retrs.count)"
        postsLabel_Retrs.text  = "\(currentUser_Retrs.userPosts_Retrs.count)"
        updateDisplayPosts_Retrs()
    }

    private func updateDisplayPosts_Retrs() {
        let user_Retrs = userVM_Retrs.getCurrentUser_Retrs()
        displayPosts_Retrs = currentSeg_Retrs == 0
            ? user_Retrs.userPosts_Retrs
            : user_Retrs.userLike_Retrs
        tableView_Retrs.reloadData()
        updateTableHeight_Retrs()
    }

    private func updateTableHeight_Retrs() {
        let rowH_Retrs: CGFloat = 100
        // 空状态固定 140pt；有内容则按行数撑开
        let h_Retrs = displayPosts_Retrs.isEmpty
            ? 140
            : CGFloat(displayPosts_Retrs.count) * rowH_Retrs
        tableView_Retrs.snp.updateConstraints { make in make.height.equalTo(h_Retrs) }
    }

    // MARK: - 通知

    private func observeNotifications_Retrs() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: UserViewModel_Retrs.userStateDidChangeNotification_Retrs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: TitleViewModel_Retrs.titleStateDidChangeNotification_Retrs, object: nil)
    }

    @objc private func onStateChange_Retrs() { reloadData_Retrs() }

    // MARK: - 事件

    @objc private func editTapped_Retrs() {
        Navigation_Retrs.toEditInfo_Retrs()
    }

    @objc private func settingTapped_Retrs() {
        Navigation_Retrs.toSetting_Retrs()
    }

    /// 点击 VIP 按钮
    @objc private func vipBtnTapped_Retrs() {
        Navigation_Retrs.toVIPSubscription_Retrs()
    }

    @objc private func postTabTapped_Retrs() {
        guard currentSeg_Retrs != 0 else { return }
        currentSeg_Retrs = 0
        styleTabBtn_Retrs(postsTabBtn_Retrs, isSelected: true)
        styleTabBtn_Retrs(likedTabBtn_Retrs, isSelected: false)
        slideSegPill_Retrs(toRight: false)
        updateDisplayPosts_Retrs()
    }

    @objc private func likedTabTapped_Retrs() {
        guard currentSeg_Retrs != 1 else { return }
        currentSeg_Retrs = 1
        styleTabBtn_Retrs(postsTabBtn_Retrs, isSelected: false)
        styleTabBtn_Retrs(likedTabBtn_Retrs, isSelected: true)
        slideSegPill_Retrs(toRight: true)
        updateDisplayPosts_Retrs()
    }

    /// 通过约束动画滑动分段胶囊
    /// - Parameter toRight_Retrs: true 滑到右侧，false 滑到左侧
    private func slideSegPill_Retrs(toRight: Bool) {
        let segW_Retrs = segCard_Retrs.bounds.width
        let pillW_Retrs = (segW_Retrs - 8) / 2
        let offset_Retrs: CGFloat = toRight ? (pillW_Retrs + 4) : 4
        segPillLeading_Retrs?.update(offset: offset_Retrs)
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) { [weak self] in
            self?.segCard_Retrs.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension Me_Retrs: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayPosts_Retrs.isEmpty ? 1 : displayPosts_Retrs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayPosts_Retrs.isEmpty {
            return MeEmptyCell_Retrs(style: .default, reuseIdentifier: nil)
        }
        let cell_Retrs = tableView.dequeueReusableCell(
            withIdentifier: "MePostCell_Retrs", for: indexPath) as! MePostCell_Retrs
        cell_Retrs.configure_Retrs(post_Retrs: displayPosts_Retrs[indexPath.row], from: self) { [weak self] in
            self?.reloadData_Retrs()
        }
        return cell_Retrs
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        displayPosts_Retrs.isEmpty ? 140 : 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !displayPosts_Retrs.isEmpty else { return }
        Navigation_Retrs.toTitleDetail_Retrs(titleModel_retrs: displayPosts_Retrs[indexPath.row])
    }
}

// MARK: - 帖子行单元格

/// 我的页面帖子行单元格
/// 功能：媒体缩略图 + 标题 + 内容摘要 + 点赞数 + 举报/删除菜单
class MePostCell_Retrs: UITableViewCell {

    private let cardView_Retrs     = UIView()
    private let thumbView_Retrs    = MediaDisplayView_Retrs()
    private let titleLabel_Retrs   = UILabel()
    private let contentLabel_Retrs = UILabel()
    private let likeLabel_Retrs    = UILabel()
    private var menuBtn_Retrs: UIButton?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        cardView_Retrs.backgroundColor = .white
        cardView_Retrs.layer.cornerRadius = 16
        cardView_Retrs.clipsToBounds = false
        cardView_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        cardView_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView_Retrs.layer.shadowOpacity = 1
        cardView_Retrs.layer.shadowRadius  = 10
        contentView.addSubview(cardView_Retrs)
        cardView_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        thumbView_Retrs.layer.cornerRadius = 12
        thumbView_Retrs.clipsToBounds = true
        cardView_Retrs.addSubview(thumbView_Retrs)
        thumbView_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(72)
        }

        titleLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        titleLabel_Retrs.numberOfLines = 1
        cardView_Retrs.addSubview(titleLabel_Retrs)
        titleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(thumbView_Retrs.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-44)
        }

        contentLabel_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        contentLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        contentLabel_Retrs.numberOfLines = 2
        cardView_Retrs.addSubview(contentLabel_Retrs)
        contentLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Retrs.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel_Retrs)
            make.trailing.equalTo(titleLabel_Retrs)
        }

        // 点赞行（心形 + 数字）
        let heartIV_Retrs = UIImageView(
            image: UIImage(systemName: "heart.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 10))
        )
        heartIV_Retrs.tintColor = UIColor(hexstring_Retrs: "#FC8181")
        heartIV_Retrs.contentMode = .scaleAspectFit
        cardView_Retrs.addSubview(heartIV_Retrs)
        heartIV_Retrs.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Retrs.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel_Retrs)
            make.width.height.equalTo(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        likeLabel_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        likeLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        cardView_Retrs.addSubview(likeLabel_Retrs)
        likeLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(heartIV_Retrs)
            make.leading.equalTo(heartIV_Retrs.snp.trailing).offset(4)
        }
    }

    func configure_Retrs(post_Retrs: TitleModel_Retrs, from vc_Retrs: UIViewController,
                          completion_Retrs: (() -> Void)?) {
        thumbView_Retrs.configure_Retrs(mediaPath_Retrs: post_Retrs.titleMeidas_Retrs.first)
        titleLabel_Retrs.text   = post_Retrs.title_Retrs
        contentLabel_Retrs.text = post_Retrs.titleContent_Retrs
        likeLabel_Retrs.text    = "\(post_Retrs.likes_Retrs)"

        menuBtn_Retrs?.removeFromSuperview()
        let btn_Retrs = ReportDeleteHelper_Retrs.createPostReportButton_Retrs(
            post_Retrs: post_Retrs, size_Retrs: 13,
            color_Retrs: ColorConfig_Retrs.textPlaceholder_Retrs,
            from: vc_Retrs, completion_Retrs: completion_Retrs
        )
        cardView_Retrs.addSubview(btn_Retrs)
        btn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(28)
        }
        menuBtn_Retrs = btn_Retrs
    }
}

// MARK: - 空状态单元格

/// 帖子列表空状态：渐变图标 + 提示文字
class MeEmptyCell_Retrs: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none

        let iconBg_Retrs = UIView()
        iconBg_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.1)
        iconBg_Retrs.layer.cornerRadius = 24
        contentView.addSubview(iconBg_Retrs)
        iconBg_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(48)
        }

        let iv_Retrs = UIImageView(
            image: UIImage(systemName: "photo.on.rectangle.angled",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        )
        iv_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        iv_Retrs.contentMode = .scaleAspectFit
        iconBg_Retrs.addSubview(iv_Retrs)
        iv_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }

        let lbl_Retrs = UILabel()
        lbl_Retrs.text = "No posts yet"
        lbl_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.7)
        lbl_Retrs.textAlignment = .center
        contentView.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Retrs.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 渐变填充辅助视图

/// 自动追踪父视图 bounds 的渐变 UIView
class MeGradView_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    init(colors_Retrs: [UIColor], start_Retrs: CGPoint, end_Retrs: CGPoint) {
        super.init(frame: .zero)
        gradLayer_Retrs.colors     = colors_Retrs.map { $0.cgColor }
        gradLayer_Retrs.startPoint = start_Retrs
        gradLayer_Retrs.endPoint   = end_Retrs
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
    }
}
