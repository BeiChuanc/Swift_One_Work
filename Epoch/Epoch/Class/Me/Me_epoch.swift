import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 我的页面
/// 核心作用：展示登录用户的横幅资料卡、数据统计、操作按钮和帖子列表
/// 设计思路：用 UITableView + tableHeaderView 承载全部个人信息区域，使整体页面可统一滚动；
///          顶部横幅卡片加渐变背景、光斑装饰、渐变环头像；统计区使用带图标的自定义数据块；
///          分段切换替换为带动画渐变下划线的自定义控件
class Me_Epoch: UIViewController {

    // MARK: - 状态

    var meModel_Epoch: LoginUserModel_Epoch?

    /// 当前展示分类索引（0=Posts，1=Saved）
    private var selectedSegmentIndex_Epoch = 0

    /// 当前展示帖子列表
    private var currentPosts_Epoch: [TitleModel_Epoch] {
        let user_epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        return selectedSegmentIndex_Epoch == 0 ? user_epoch.userPosts_Epoch : user_epoch.userLike_Epoch
    }

    // MARK: - 背景

    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    // MARK: - 表格

    private let tableView_Epoch: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 360
        tv.showsVerticalScrollIndicator = false
        return tv
    }()

    /// 表头容器
    private let headerContainerView_Epoch = UIView()

    // MARK: - 横幅卡片

    /// 横幅个人卡片（带渐变背景）
    private let profileBannerView_Epoch: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    /// 横幅渐变图层
    private var bannerGradientLayer_Epoch: CAGradientLayer?

    /// 横幅右上装饰光斑（暖粉）
    private let bannerGlowTopRight_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.32)
        v.layer.cornerRadius = 72
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 横幅左下装饰光斑（冷蓝）
    private let bannerGlowBottomLeft_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientEnd_Epoch.withAlphaComponent(0.22)
        v.layer.cornerRadius = 60
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 头像渐变环容器
    private let avatarRingView_Epoch: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    /// 渐变环图层
    private var avatarRingGradientLayer_Epoch: CAGradientLayer?

    /// 头像白色间隔层
    private let avatarSepView_Epoch: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    /// 头像组件
    private let avatarView_Epoch = CurrentUserAvatarView_Epoch()

    /// 创作者角标
    private let creatorBadgeLabel_Epoch: PaddingLabel_Epoch = {
        let l = PaddingLabel_Epoch()
        l.text = "CREATOR"
        l.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        l.textColor = ColorConfig_Epoch.textOnDark_Epoch
        l.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.horizontalInset_Epoch = 8
        l.verticalInset_Epoch = 4
        return l
    }()

    /// 用户名（衬线艺术字体）
    private let nameLabel_Epoch: UILabel = {
        let l = UILabel()
        let baseDesc_epoch = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let serifDesc_epoch = baseDesc_epoch.withDesign(.serif) ?? baseDesc_epoch
        let boldDesc_epoch = serifDesc_epoch.withSymbolicTraits(.traitBold) ?? serifDesc_epoch
        l.font = UIFont(descriptor: boldDesc_epoch, size: 26)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 用户简介
    private let introLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - 统计区

    private let postsStatView_Epoch = MeStatItemView_Epoch()
    private let savedStatView_Epoch = MeStatItemView_Epoch()
    private let followStatView_Epoch = MeStatItemView_Epoch()

    // MARK: - 操作按钮

    private let editButton_Epoch = PrimaryActionButton_Epoch(title_Epoch: "Edit Profile")

    /// 设置图标按钮
    private let settingButton_Epoch: UIButton = {
        let btn = UIButton(type: .system)
        let config_epoch = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config_epoch), for: .normal)
        btn.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        btn.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 26
        btn.layer.borderWidth = 1
        btn.layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
        return btn
    }()

    // MARK: - 分段切换

    private let segmentSwitchView_Epoch = MeTabSwitchView_Epoch()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Epoch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        setupNotifications_Epoch()
        reloadData_Epoch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderLayout_Epoch()
        // 渐变环随布局同步
        avatarRingGradientLayer_Epoch?.frame = avatarRingView_Epoch.bounds
        avatarRingView_Epoch.layer.cornerRadius = avatarRingView_Epoch.bounds.width / 2
        avatarSepView_Epoch.layer.cornerRadius = avatarSepView_Epoch.bounds.width / 2
        // 横幅渐变随布局同步
        bannerGradientLayer_Epoch?.frame = profileBannerView_Epoch.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 界面搭建

    /// 构建整体界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(tableView_Epoch)

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupHeaderView_Epoch()

        tableView_Epoch.register(PostTableViewCell_Epoch.self, forCellReuseIdentifier: "PostTableViewCell_Epoch")
        tableView_Epoch.register(MeEmptyPostCell_Epoch.self, forCellReuseIdentifier: "MeEmptyPostCell_Epoch")
        tableView_Epoch.dataSource = self
        tableView_Epoch.delegate = self
        tableView_Epoch.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        segmentSwitchView_Epoch.onTabChanged_Epoch = { [weak self] index_epoch in
            self?.selectedSegmentIndex_Epoch = index_epoch
            self?.tableView_Epoch.reloadData()
        }
        editButton_Epoch.addTarget(self, action: #selector(editTapped_Epoch), for: .touchUpInside)
        settingButton_Epoch.addTarget(self, action: #selector(settingTapped_Epoch), for: .touchUpInside)
        avatarView_Epoch.onTapped_Epoch = { [weak self] in
            self?.openEdit_Epoch()
        }
    }

    /// 搭建表头视图（横幅 + 统计 + 按钮 + 分段切换）
    private func setupHeaderView_Epoch() {
        tableView_Epoch.tableHeaderView = headerContainerView_Epoch
        headerContainerView_Epoch.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 480)

        // 横幅卡片渐变背景（浅紫→浅粉→极白）
        let bannerGrad_epoch = CAGradientLayer()
        bannerGrad_epoch.colors = [
            UIColor(hexstring_Epoch: "#F0EAFF").cgColor,
            UIColor(hexstring_Epoch: "#FFF0F8").cgColor,
            UIColor(hexstring_Epoch: "#FAFAFA").cgColor
        ]
        bannerGrad_epoch.startPoint = CGPoint(x: 0, y: 0)
        bannerGrad_epoch.endPoint = CGPoint(x: 1, y: 1)
        profileBannerView_Epoch.layer.insertSublayer(bannerGrad_epoch, at: 0)
        bannerGradientLayer_Epoch = bannerGrad_epoch

        // 头像渐变环（紫→粉→蓝）
        let ringGrad_epoch = CAGradientLayer()
        ringGrad_epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.accentPink_Epoch.cgColor,
            ColorConfig_Epoch.primaryGradientEnd_Epoch.cgColor
        ]
        ringGrad_epoch.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_epoch.endPoint = CGPoint(x: 1, y: 1)
        avatarRingView_Epoch.layer.insertSublayer(ringGrad_epoch, at: 0)
        avatarRingGradientLayer_Epoch = ringGrad_epoch

        // 间隔层背景色 = 横幅渐变起始色，使其融入卡片
        avatarSepView_Epoch.backgroundColor = UIColor(hexstring_Epoch: "#F0EAFF")

        // 添加视图层级
        headerContainerView_Epoch.addSubview(profileBannerView_Epoch)
        profileBannerView_Epoch.addSubview(bannerGlowTopRight_Epoch)
        profileBannerView_Epoch.addSubview(bannerGlowBottomLeft_Epoch)
        profileBannerView_Epoch.addSubview(avatarRingView_Epoch)
        avatarRingView_Epoch.addSubview(avatarSepView_Epoch)
        avatarSepView_Epoch.addSubview(avatarView_Epoch)
        profileBannerView_Epoch.addSubview(creatorBadgeLabel_Epoch)
        profileBannerView_Epoch.addSubview(nameLabel_Epoch)
        profileBannerView_Epoch.addSubview(introLabel_Epoch)

        let statStack_epoch = UIStackView(arrangedSubviews: [postsStatView_Epoch, savedStatView_Epoch, followStatView_Epoch])
        statStack_epoch.axis = .horizontal
        statStack_epoch.spacing = 12
        statStack_epoch.distribution = .fillEqually
        headerContainerView_Epoch.addSubview(statStack_epoch)

        let actionStack_epoch = UIStackView(arrangedSubviews: [editButton_Epoch, settingButton_Epoch])
        actionStack_epoch.axis = .horizontal
        actionStack_epoch.spacing = 12
        headerContainerView_Epoch.addSubview(actionStack_epoch)

        headerContainerView_Epoch.addSubview(segmentSwitchView_Epoch)

        // MARK: 约束

        let topInset_epoch = view.safeAreaInsets.top + 14

        profileBannerView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topInset_epoch)
            make.left.right.equalToSuperview().inset(16)
        }

        bannerGlowTopRight_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-36)
            make.right.equalToSuperview().offset(36)
            make.width.height.equalTo(144)
        }

        bannerGlowBottomLeft_Epoch.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(36)
            make.left.equalToSuperview().offset(-36)
            make.width.height.equalTo(120)
        }

        avatarRingView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }

        avatarSepView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }

        creatorBadgeLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Epoch.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        nameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(creatorBadgeLabel_Epoch.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }

        introLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Epoch.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-26)
        }

        statStack_epoch.snp.makeConstraints { make in
            make.top.equalTo(profileBannerView_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(86)
        }

        editButton_Epoch.snp.makeConstraints { make in
            make.height.equalTo(52)
        }

        settingButton_Epoch.snp.makeConstraints { make in
            make.width.height.equalTo(52)
        }

        actionStack_epoch.snp.makeConstraints { make in
            make.top.equalTo(statStack_epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        segmentSwitchView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(actionStack_epoch.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(46)
            make.bottom.equalToSuperview().offset(-4)
        }
    }

    /// 自适应表头高度
    private func updateHeaderLayout_Epoch() {
        guard let header_epoch = tableView_Epoch.tableHeaderView else { return }
        let targetSize_epoch = CGSize(width: tableView_Epoch.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let fittingH_epoch = header_epoch.systemLayoutSizeFitting(
            targetSize_epoch,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        guard abs(header_epoch.frame.height - fittingH_epoch) > 1 else { return }
        header_epoch.frame.size.height = fittingH_epoch
        tableView_Epoch.tableHeaderView = header_epoch
    }

    // MARK: - 通知

    private func setupNotifications_Epoch() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Epoch),
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Epoch),
            name: TitleViewModel_Epoch.titleStateDidChangeNotification_Epoch, object: nil
        )
    }

    // MARK: - 数据刷新

    /// 刷新页面所有数据
    private func reloadData_Epoch() {
        let user_epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        meModel_Epoch = user_epoch

        nameLabel_Epoch.text = user_epoch.userName_Epoch ?? "Unknown"
        let bio_epoch = user_epoch.userIntroduce_Epoch ?? ""
        introLabel_Epoch.text = bio_epoch.isEmpty ? "No bio yet — tap Edit Profile to add one." : bio_epoch

        postsStatView_Epoch.configure_Epoch(
            iconName_Epoch: "doc.text.fill",
            value_Epoch: "\(user_epoch.userPosts_Epoch.count)",
            title_Epoch: "Posts"
        )
        savedStatView_Epoch.configure_Epoch(
            iconName_Epoch: "heart.fill",
            value_Epoch: "\(user_epoch.userLike_Epoch.count)",
            title_Epoch: "Liked"
        )
        followStatView_Epoch.configure_Epoch(
            iconName_Epoch: "person.2.fill",
            value_Epoch: "\(user_epoch.userFollow_Epoch.count)",
            title_Epoch: "Following"
        )

        tableView_Epoch.reloadData()
        updateHeaderLayout_Epoch()
    }

    /// 打开编辑资料页
    private func openEdit_Epoch() {
        Navigation_Epoch.toEditInfo_Epoch(style_epoch: .push_epoch)
    }

    @objc private func handleStateChange_Epoch() {
        reloadData_Epoch()
    }

    @objc private func editTapped_Epoch() {
        openEdit_Epoch()
    }

    @objc private func settingTapped_Epoch() {
        Navigation_Epoch.toSetting_Epoch(style_epoch: .push_epoch)
    }
}

// MARK: - UITableViewDataSource

extension Me_Epoch: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPosts_Epoch.isEmpty ? 1 : currentPosts_Epoch.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentPosts_Epoch.isEmpty {
            guard let cell_epoch = tableView.dequeueReusableCell(
                withIdentifier: "MeEmptyPostCell_Epoch",
                for: indexPath
            ) as? MeEmptyPostCell_Epoch else { return UITableViewCell() }

            cell_epoch.configure_Epoch(tabIndex_Epoch: selectedSegmentIndex_Epoch)
            return cell_epoch
        }

        guard let cell_epoch = tableView.dequeueReusableCell(
            withIdentifier: "PostTableViewCell_Epoch",
            for: indexPath
        ) as? PostTableViewCell_Epoch else { return UITableViewCell() }

        let post_epoch = currentPosts_Epoch[indexPath.row]
        cell_epoch.postCardView_Epoch.configure_Epoch(post_epoch: post_epoch, hostViewController_Epoch: self)
        cell_epoch.postCardView_Epoch.onPostTapped_Epoch = {
            Navigation_Epoch.toTitleDetail_Epoch(titleModel_epoch: post_epoch)
        }
        cell_epoch.postCardView_Epoch.onUserTapped_Epoch = { [weak self] in
            self?.openEdit_Epoch()
        }
        cell_epoch.postCardView_Epoch.onLikeTapped_Epoch = { [weak self] in
            TitleViewModel_Epoch.shared_Epoch.likePost_Epoch(post_epoch: post_epoch)
            self?.reloadData_Epoch()
        }
        return cell_epoch
    }
}

// MARK: - UITableViewDelegate

extension Me_Epoch: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return currentPosts_Epoch.isEmpty ? 280 : UITableView.automaticDimension
    }
}

// MARK: - 统计数据卡片

/// 个人中心统计数据卡片
/// 核心作用：展示单项统计的图标、数值和字段名
/// 设计思路：图标 + 渐变紫数值 + 字段名三层竖排，卡片有轻阴影和紫色边框
final class MeStatItemView_Epoch: UIView {

    /// 图标视图
    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Epoch.primaryGradientStart_Epoch
        return iv
    }()

    /// 数值标签
    private let valueLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = ColorConfig_Epoch.accentPurple_Epoch
        l.textAlignment = .center
        return l
    }()

    /// 字段名标签
    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.88)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
        layer.shadowColor = ColorConfig_Epoch.shadowColor_Epoch.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.10
        layer.shadowRadius = 10
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置统计数据
    /// - Parameters:
    ///   - iconName_Epoch: SF Symbol 图标名
    ///   - value_Epoch: 数值文本
    ///   - title_Epoch: 字段名
    func configure_Epoch(iconName_Epoch: String, value_Epoch: String, title_Epoch: String) {
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)
        valueLabel_Epoch.text = value_Epoch
        titleLabel_Epoch.text = title_Epoch
    }

    private func setupUI_Epoch() {
        addSubview(iconImageView_Epoch)
        addSubview(valueLabel_Epoch)
        addSubview(titleLabel_Epoch)

        iconImageView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(18)
        }

        valueLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(iconImageView_Epoch.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(6)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(valueLabel_Epoch.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
}

// MARK: - 自定义分段切换

/// 自定义分段切换控件
/// 核心作用：替代 UISegmentedControl，提供 Posts / Saved 两个 Tab 的动画渐变下划线切换
/// 设计思路：渐变下划线随选中 Tab 位置弹性滑动，字重同步加粗，底部加分割线
final class MeTabSwitchView_Epoch: UIView {

    /// Tab 切换回调（传入新选中索引）
    var onTabChanged_Epoch: ((Int) -> Void)?

    private let tabTitles_Epoch = ["Posts", "Saved"]
    private var tabButtons_Epoch: [UIButton] = []
    private var currentIndex_Epoch = 0

    /// 渐变下划线指示器
    private let indicatorView_Epoch: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()

    private var indicatorGradientLayer_Epoch: CAGradientLayer?

    /// 底部分割线
    private let dividerView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.divider_Epoch
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorGradientLayer_Epoch?.frame = indicatorView_Epoch.bounds
        updateIndicatorPosition_Epoch(animated: false)
    }

    private func setupUI_Epoch() {
        addSubview(dividerView_Epoch)
        dividerView_Epoch.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        // 渐变下划线
        let grad_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: .zero)
        grad_epoch.cornerRadius = 2
        indicatorView_Epoch.layer.addSublayer(grad_epoch)
        indicatorGradientLayer_Epoch = grad_epoch
        addSubview(indicatorView_Epoch)

        let stackView_epoch = UIStackView()
        stackView_epoch.axis = .horizontal
        stackView_epoch.distribution = .fillEqually
        addSubview(stackView_epoch)
        stackView_epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(dividerView_Epoch.snp.top)
        }

        tabTitles_Epoch.enumerated().forEach { idx_epoch, title_epoch in
            let btn_epoch = UIButton(type: .system)
            btn_epoch.setTitle(title_epoch, for: .normal)
            btn_epoch.tag = idx_epoch
            btn_epoch.addTarget(self, action: #selector(tabTapped_Epoch(_:)), for: .touchUpInside)
            tabButtons_Epoch.append(btn_epoch)
            stackView_epoch.addArrangedSubview(btn_epoch)
        }

        refreshTabAppearance_Epoch()
    }

    private func refreshTabAppearance_Epoch() {
        tabButtons_Epoch.enumerated().forEach { idx_epoch, btn_epoch in
            let selected_epoch = idx_epoch == currentIndex_Epoch
            btn_epoch.setTitleColor(
                selected_epoch ? ColorConfig_Epoch.accentPurple_Epoch : ColorConfig_Epoch.textPlaceholder_Epoch,
                for: .normal
            )
            btn_epoch.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: selected_epoch ? .bold : .medium)
        }
    }

    private func updateIndicatorPosition_Epoch(animated: Bool) {
        guard !tabButtons_Epoch.isEmpty, bounds.width > 0 else { return }
        let tabW_epoch = bounds.width / CGFloat(tabTitles_Epoch.count)
        let indicW_epoch: CGFloat = 44
        let x_epoch = tabW_epoch * CGFloat(currentIndex_Epoch) + (tabW_epoch - indicW_epoch) / 2
        let y_epoch = bounds.height - 3
        let newFrame_epoch = CGRect(x: x_epoch, y: y_epoch, width: indicW_epoch, height: 3)

        if animated {
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
                self.indicatorView_Epoch.frame = newFrame_epoch
                self.indicatorGradientLayer_Epoch?.frame = self.indicatorView_Epoch.bounds
            }
        } else {
            indicatorView_Epoch.frame = newFrame_epoch
            indicatorGradientLayer_Epoch?.frame = indicatorView_Epoch.bounds
        }
    }

    /// Tab 点击事件
    @objc private func tabTapped_Epoch(_ sender: UIButton) {
        guard sender.tag != currentIndex_Epoch else { return }
        currentIndex_Epoch = sender.tag
        refreshTabAppearance_Epoch()
        updateIndicatorPosition_Epoch(animated: true)
        onTabChanged_Epoch?(currentIndex_Epoch)
    }
}

// MARK: - 空状态单元格

/// 个人中心帖子空状态单元格
/// 核心作用：在无帖子或未登录时展示引导信息
/// 设计思路：卡片内嵌图标圆形背景 + 标题 + 副标题 + 可选操作按钮
final class MeEmptyPostCell_Epoch: UITableViewCell {

    /// 卡片容器
    private let cardView_Epoch = SurfaceCardView_Epoch()

    /// 图标背景
    private let iconBgView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.12)
        v.layer.cornerRadius = 36
        return v
    }()

    /// 图标
    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 标题
    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        l.textAlignment = .center
        return l
    }()

    /// 副标题
    private let subtitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    /// 操作按钮
    private let actionButton_Epoch = PrimaryActionButton_Epoch(title_Epoch: "")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置空状态内容
    /// - Parameter tabIndex_Epoch: 当前分类索引（0=Posts，1=Saved）
    func configure_Epoch(tabIndex_Epoch: Int) {
        if tabIndex_Epoch == 0 {
            iconImageView_Epoch.image = UIImage(systemName: "square.stack.3d.up")
            titleLabel_Epoch.text = "No posts yet"
            subtitleLabel_Epoch.text = "Your published posts will appear here."
        } else {
            iconImageView_Epoch.image = UIImage(systemName: "heart.slash")
            titleLabel_Epoch.text = "Nothing saved yet"
            subtitleLabel_Epoch.text = "Posts you like will be saved here."
        }
        actionButton_Epoch.isHidden = true
    }

    private func setupUI_Epoch() {
        contentView.addSubview(cardView_Epoch)
        cardView_Epoch.addSubview(iconBgView_Epoch)
        iconBgView_Epoch.addSubview(iconImageView_Epoch)
        cardView_Epoch.addSubview(titleLabel_Epoch)
        cardView_Epoch.addSubview(subtitleLabel_Epoch)
        cardView_Epoch.addSubview(actionButton_Epoch)

        cardView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16))
        }

        iconBgView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(iconBgView_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        subtitleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(24)
        }

        actionButton_Epoch.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Epoch.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

}
