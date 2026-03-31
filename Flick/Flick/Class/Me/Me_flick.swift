import UIKit
import SnapKit
import Kingfisher

// MARK: - 我的页面控制器

/// 我的页面控制器
/// 功能：展示当前登录用户的个人信息、发布帖子与喜欢帖子
/// 设计：波浪渐变头部 + 渐变头像环 + Pill 统计卡 + 胶囊 Tab 选择器 + 2 列网格帖子
class Me_Flick: UIViewController {

    // MARK: - 属性

    /// 外部传入的登录用户模型，未传时取当前登录用户
    var meModel_Flick: LoginUserModel_Flick?

    /// 当前激活的 Tab 索引：0 = Posts，1 = Likes
    private var activeTab_Flick: Int = 0

    // MARK: - UI 组件

    private lazy var collectionView_Flick: UICollectionView = {
        let layout = buildLayout_Flick()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        // 禁止自动追加安全区 inset，确保渐变头部从屏幕顶部开始
        cv.contentInsetAdjustmentBehavior = .never
        cv.delegate = self
        cv.dataSource = self
        cv.register(MeHeaderCell_Flick.self,  forCellWithReuseIdentifier: MeHeaderCell_Flick.reuseId_Flick)
        cv.register(MeTabBarCell_Flick.self,  forCellWithReuseIdentifier: MeTabBarCell_Flick.reuseId_Flick)
        cv.register(MePostCell_Flick.self,    forCellWithReuseIdentifier: MePostCell_Flick.reuseId_Flick)
        cv.register(MeEmptyCell_Flick.self,   forCellWithReuseIdentifier: MeEmptyCell_Flick.reuseId_Flick)
        return cv
    }()

    // MARK: - 计算属性

    private var user_Flick: LoginUserModel_Flick {
        meModel_Flick ?? UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
    }

    private var currentPosts_Flick: [TitleModel_Flick] {
        activeTab_Flick == 0 ? user_Flick.userPosts_Flick : user_Flick.userLike_Flick
    }

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        syncUserData_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // viewWillAppear 时 collectionView.bounds 尚未由 AutoLayout 赋值（宽度为0），
        // Cell 的 layoutSubviews 中 guard b.width > 0 命中返回，导致渐变/mask 未建立。
        // viewDidAppear 时 View 已完成首次布局，此处补触发一次 layout，使渐变正常渲染。
        collectionView_Flick.visibleCells.forEach {
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        bindNotifications_Flick()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        view.addSubview(collectionView_Flick)
        collectionView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 通知

    private func bindNotifications_Flick() {
        [UserViewModel_Flick.userStateDidChangeNotification_Flick,
         TitleViewModel_Flick.titleStateDidChangeNotification_Flick].forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(syncUserData_Flick), name: $0, object: nil)
        }
    }

    @objc private func syncUserData_Flick() {
        meModel_Flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
        collectionView_Flick.reloadData()
    }

    // MARK: - CompositionalLayout

    private func buildLayout_Flick() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIdx, _ in
            guard let self else { return nil }
            switch sectionIdx {
            case 0:
                let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(360))
                return NSCollectionLayoutSection(group: .horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)]))
            case 1:
                let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(56))
                let section = NSCollectionLayoutSection(group: .horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)]))
                section.contentInsets = .init(top: 0, leading: 0, bottom: 8, trailing: 0)
                return section
            default:
                if self.currentPosts_Flick.isEmpty {
                    let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(260))
                    return NSCollectionLayoutSection(group: .horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)]))
                }
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.62))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 5, leading: 6, bottom: 5, trailing: 6)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.62))
                let section = NSCollectionLayoutSection(group: .horizontal(layoutSize: groupSize, subitems: [item]))
                section.contentInsets = .init(top: 4, leading: 6, bottom: 40, trailing: 6)
                return section
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension Me_Flick: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 1
        default: return max(1, currentPosts_Flick.count)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeHeaderCell_Flick.reuseId_Flick, for: indexPath) as! MeHeaderCell_Flick
            cell.configure_Flick(user: user_Flick)
            cell.onEditTapped_Flick    = { Navigation_Flick.toEditInfo_Flick() }
            cell.onSettingTapped_Flick = { Navigation_Flick.toSetting_Flick() }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeTabBarCell_Flick.reuseId_Flick, for: indexPath) as! MeTabBarCell_Flick
            cell.configure_Flick(activeIdx: activeTab_Flick)
            cell.onTabChanged_Flick = { [weak self] idx in
                guard let self, self.activeTab_Flick != idx else { return }
                self.activeTab_Flick = idx
                self.collectionView_Flick.performBatchUpdates {
                    self.collectionView_Flick.reloadSections(IndexSet(integer: 2))
                }
            }
            return cell
        default:
            let posts = currentPosts_Flick
            if posts.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeEmptyCell_Flick.reuseId_Flick, for: indexPath) as! MeEmptyCell_Flick
                cell.configure_Flick(isLiked: activeTab_Flick == 1)
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MePostCell_Flick.reuseId_Flick, for: indexPath) as! MePostCell_Flick
            cell.configure_Flick(post: posts[indexPath.item], from: self) { [weak self] in self?.syncUserData_Flick() }
            return cell
        }
    }
}

extension Me_Flick: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 2 else { return }
        let posts = currentPosts_Flick
        guard !posts.isEmpty, indexPath.item < posts.count else { return }
        Navigation_Flick.toTitleDetail_Flick(titleModel_flick: posts[indexPath.item])
    }
}

// MARK: - 用户信息头部 Cell

/// 我的页面 - 用户信息头部 Cell
/// 功能：波浪渐变背景、渐变头像环、昵称/简介、三项 Pill 统计卡（Posts/Follows/Likes）、编辑与设置按钮
class MeHeaderCell_Flick: UICollectionViewCell {

    static let reuseId_Flick = "MeHeaderCell_Flick"

    var onEditTapped_Flick: (() -> Void)?
    var onSettingTapped_Flick: (() -> Void)?

    // MARK: - UI

    /// 渐变头部（带波浪下边缘）
    private let gradientBg_Flick = UIView()
    private var gradientLayer_Flick: CAGradientLayer?
    private var waveMask_Flick: CAShapeLayer?

    /// 星点装饰
    private var starLayers_Flick: [CALayer] = []

    /// 设置按钮
    private let settingBtn_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withValues(alpha: 0.2)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withValues(alpha: 0.3).cgColor
        return btn
    }()

    /// 渐变头像环（在头像后层）
    private let avatarRingView_Flick = UIView()
    private var ringGradient_Flick: CAGradientLayer?
    private var ringMask_Flick: CAShapeLayer?

    /// 头像
    private let avatarView_Flick: CurrentUserAvatarView_Flick = {
        let v = CurrentUserAvatarView_Flick()
        v.layer.cornerRadius = 44
        v.clipsToBounds = false
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 用户名 + 徽章
    private let nameLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 21, weight: .bold)
        lbl.textColor = ColorConfig_Flick.textPrimary_Flick
        lbl.textAlignment = .center
        return lbl
    }()

    /// 闪光徽章（✦）
    private let badgeLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "✦"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = ColorConfig_Flick.primaryGradientStart_Flick
        return lbl
    }()

    /// 简介
    private let bioLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Flick.textSecondary_Flick
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 三项统计卡容器
    private let statsCard_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Flick: "#B794F6").withValues(alpha: 0.15).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 12
        return v
    }()

    private let postsValueLabel_Flick  = MeHeaderCell_Flick.makeStatVal_Flick()
    private let followsValueLabel_Flick = MeHeaderCell_Flick.makeStatVal_Flick()
    private let likesValueLabel_Flick  = MeHeaderCell_Flick.makeStatVal_Flick()

    /// Edit Profile 按钮（渐变填充）
    /// 使用 .custom 类型，避免 .system 在渐变层之上绘制系统底色
    private let editBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn.setImage(UIImage(systemName: "pencil", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.setTitle("  Edit Profile", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    private var editBtnGradient_Flick: CAGradientLayer?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Flick?.frame = gradientBg_Flick.bounds
        applyWaveMask_Flick()
        updateAvatarRing_Flick()
        updateEditGradient_Flick()
    }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        backgroundColor = .clear

        // 渐变背景
        contentView.addSubview(gradientBg_Flick)
        gradientBg_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(172)
        }
        let grad = UIColor.createPrimaryGradientLayer_Flick(
            frame_Flick: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 172)
        )
        gradientBg_Flick.layer.insertSublayer(grad, at: 0)
        gradientLayer_Flick = grad

        // 波浪遮罩在 applyWaveMask_Flick() 中懒创建，此处不提前设置
        // 未设置 mask 时内容完全可见，避免空 path 导致渐变被遮盖

        // 装饰圆 + 星点
        addDecorElements_Flick()

        // 设置按钮
        contentView.addSubview(settingBtn_Flick)
        settingBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(12)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
        settingBtn_Flick.addTarget(self, action: #selector(settingTapped_Flick_), for: .touchUpInside)

        // 渐变头像环
        contentView.addSubview(avatarRingView_Flick)
        avatarRingView_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(114)
            make.width.height.equalTo(106)
        }
        setupAvatarRing_Flick()

        // 头像（位于环内，稍小）
        contentView.addSubview(avatarView_Flick)
        avatarView_Flick.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Flick)
            make.width.height.equalTo(92)
        }

        // 用户名行（名字 + 徽章水平排列）
        let nameRow = UIStackView(arrangedSubviews: [nameLabel_Flick, badgeLabel_Flick])
        nameRow.axis = .horizontal
        nameRow.spacing = 5
        nameRow.alignment = .center
        contentView.addSubview(nameRow)
        nameRow.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Flick.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().inset(24)
            make.right.lessThanOrEqualToSuperview().inset(24)
        }

        // 简介
        contentView.addSubview(bioLabel_Flick)
        bioLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(nameRow.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }

        // 三项统计卡
        setupStatsCard_Flick()

        // Edit 按钮
        contentView.addSubview(editBtn_Flick)
        editBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Flick.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(20)
        }
        editBtn_Flick.addTarget(self, action: #selector(editTapped_Flick_), for: .touchUpInside)
    }

    // MARK: - 装饰元素

    private func addDecorElements_Flick() {
        // 半透明装饰圆
        let circles: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-25, -25, 110, 55, 0.1),
            (1.0, 35, 150, 75, 0.07),  // right edge (offset added in constraints)
            (60, 10, 60, 30, 0.05)
        ]
        for (idx, c) in circles.enumerated() {
            let v = UIView()
            v.backgroundColor = UIColor.white.withValues(alpha: c.4)
            v.layer.cornerRadius = c.2 / 2
            gradientBg_Flick.addSubview(v)
            v.snp.makeConstraints { make in
                make.width.height.equalTo(c.2)
                if idx == 0 {
                    make.left.equalToSuperview().offset(c.0)
                    make.top.equalToSuperview().offset(c.1)
                } else if idx == 1 {
                    make.right.equalToSuperview().offset(30)
                    make.bottom.equalToSuperview().offset(30)
                } else {
                    make.centerX.equalToSuperview().offset(c.3)
                    make.top.equalToSuperview().offset(c.1)
                }
            }
        }

        // 小星星点缀
        let starPositions: [(CGFloat, CGFloat)] = [(50, 18), (160, 35), (280, 12), (310, 55), (80, 60)]
        for pos in starPositions {
            let star = UILabel()
            star.text = "✦"
            star.font = .systemFont(ofSize: CGFloat.random(in: 8...13))
            star.textColor = UIColor.white.withValues(alpha: CGFloat.random(in: 0.3...0.6))
            gradientBg_Flick.addSubview(star)
            star.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(pos.0)
                make.top.equalToSuperview().offset(pos.1)
            }
        }
    }

    // MARK: - 渐变头像环

    private func setupAvatarRing_Flick() {
        let g = CAGradientLayer()
        g.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.secondaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint   = CGPoint(x: 1, y: 1)
        avatarRingView_Flick.layer.addSublayer(g)
        ringGradient_Flick = g
        // 甜甜圈遮罩在 updateAvatarRing_Flick 中懒创建，避免空 path 遮盖渐变
    }

    private func updateAvatarRing_Flick() {
        let b = avatarRingView_Flick.bounds
        guard b.width > 0 else { return }
        ringGradient_Flick?.frame = b

        // 懒初始化：bounds 有效时才创建并挂载甜甜圈遮罩
        if ringMask_Flick == nil {
            let mask = CAShapeLayer()
            mask.fillRule  = .evenOdd
            mask.fillColor = UIColor.black.cgColor
            avatarRingView_Flick.layer.mask = mask
            ringMask_Flick = mask
        }
        let outer = UIBezierPath(ovalIn: b)
        let inner = UIBezierPath(ovalIn: b.insetBy(dx: 4, dy: 4))
        outer.append(inner.reversing())
        ringMask_Flick?.path = outer.cgPath
    }

    // MARK: - 三项统计卡

    private func setupStatsCard_Flick() {
        contentView.addSubview(statsCard_Flick)
        statsCard_Flick.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Flick.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(72)
        }

        let postsItem   = buildStatItem_Flick(valueLabel: postsValueLabel_Flick,   title: "Posts")
        let followsItem = buildStatItem_Flick(valueLabel: followsValueLabel_Flick, title: "Follows")
        let likesItem   = buildStatItem_Flick(valueLabel: likesValueLabel_Flick,   title: "Likes")

        let sep1 = makeSeparator_Flick()
        let sep2 = makeSeparator_Flick()

        let stack = UIStackView(arrangedSubviews: [postsItem, sep1, followsItem, sep2, likesItem])
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.alignment = .center
        [sep1, sep2].forEach { $0.snp.makeConstraints { m in m.width.equalTo(1); m.height.equalTo(36) } }

        statsCard_Flick.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)) }
    }

    private func buildStatItem_Flick(valueLabel: UILabel, title: String) -> UIView {
        let container = UIView()
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 11, weight: .medium)
        titleLbl.textColor = ColorConfig_Flick.textSecondary_Flick
        titleLbl.textAlignment = .center
        container.addSubview(valueLabel)
        container.addSubview(titleLbl)
        valueLabel.snp.makeConstraints { make in make.top.centerX.equalToSuperview() }
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(3)
            make.centerX.bottom.equalToSuperview()
        }
        return container
    }

    private func makeSeparator_Flick() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.divider_Flick
        return v
    }

    private static func makeStatVal_Flick() -> UILabel {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = ColorConfig_Flick.textPrimary_Flick
        lbl.textAlignment = .center
        lbl.text = "0"
        return lbl
    }

    // MARK: - Edit 按钮渐变

    /// 渐变层仅在首次布局时创建并插入，后续只更新 frame，避免反复移除/添加导致渲染闪烁
    private func updateEditGradient_Flick() {
        guard editBtn_Flick.bounds.width > 0 else { return }
        if let existing = editBtnGradient_Flick {
            existing.frame = editBtn_Flick.bounds
            return
        }
        let g = UIColor.createPrimaryGradientLayer_Flick(frame_Flick: editBtn_Flick.bounds)
        g.cornerRadius = 20
        editBtn_Flick.layer.insertSublayer(g, at: 0)
        editBtnGradient_Flick = g
    }

    // MARK: - 波浪遮罩

    /// bounds 有效时懒创建 CAShapeLayer mask 并挂载，避免提前挂载空 path 遮罩导致渐变不可见
    private func applyWaveMask_Flick() {
        let b = gradientBg_Flick.bounds
        guard b.width > 0 else { return }
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: b.width, y: 0))
        path.addLine(to: CGPoint(x: b.width, y: b.height - 22))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: b.height - 22),
            controlPoint: CGPoint(x: b.width / 2, y: b.height + 22)
        )
        path.close()
        // 懒初始化：首次有效 bounds 时才创建 mask 并挂载
        if waveMask_Flick == nil {
            let mask = CAShapeLayer()
            mask.fillColor = UIColor.black.cgColor
            gradientBg_Flick.layer.mask = mask
            waveMask_Flick = mask
        }
        waveMask_Flick?.path = path.cgPath
    }

    // MARK: - 数据绑定

    func configure_Flick(user: LoginUserModel_Flick) {
        nameLabel_Flick.text = user.userName_Flick ?? "User"
        bioLabel_Flick.text = (user.userIntroduce_Flick?.isEmpty == false)
            ? user.userIntroduce_Flick
            : "Sharing beautiful moments ✨"
        postsValueLabel_Flick.text   = "\(user.userPosts_Flick.count)"
        followsValueLabel_Flick.text = "\(user.userFollow_Flick.count)"
        likesValueLabel_Flick.text   = "\(user.userLike_Flick.count)"
    }

    // MARK: - 事件

    @objc private func editTapped_Flick_() {
        editBtn_Flick.animatePressDown_Flick { [weak self] in self?.editBtn_Flick.animatePressUp_Flick() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onEditTapped_Flick?()
    }

    @objc private func settingTapped_Flick_() {
        settingBtn_Flick.animatePressDown_Flick { [weak self] in self?.settingBtn_Flick.animatePressUp_Flick() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSettingTapped_Flick?()
    }
}

// MARK: - Tab 切换栏 Cell

/// 我的页面 - 胶囊 Tab 选择器 Cell
/// 功能：Posts（网格图标）/ Likes（心形图标）切换，滑动胶囊背景跟随
class MeTabBarCell_Flick: UICollectionViewCell {

    static let reuseId_Flick = "MeTabBarCell_Flick"
    var onTabChanged_Flick: ((Int) -> Void)?

    // MARK: - UI

    /// 灰色整体背景胶囊
    private let bgCapsule_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Flick: "#EDF2F7")
        v.layer.cornerRadius = 20
        return v
    }()

    /// 滑动活跃胶囊（白色）
    private let activePill_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor(hexstring_Flick: "#B794F6").withValues(alpha: 0.2).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        return v
    }()

    private let postsBtn_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "square.grid.2x2.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Posts", for: .normal)
        btn.tintColor = ColorConfig_Flick.primaryGradientStart_Flick
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(ColorConfig_Flick.primaryGradientStart_Flick, for: .normal)
        return btn
    }()

    private let likesBtn_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Likes", for: .normal)
        btn.tintColor = ColorConfig_Flick.textSecondary_Flick
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(ColorConfig_Flick.textSecondary_Flick, for: .normal)
        return btn
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Flick() {
        backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        contentView.addSubview(bgCapsule_Flick)
        bgCapsule_Flick.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }

        bgCapsule_Flick.addSubview(activePill_Flick)
        activePill_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(4)
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-6)
        }

        bgCapsule_Flick.addSubview(postsBtn_Flick)
        postsBtn_Flick.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(bgCapsule_Flick.snp.centerX)
        }

        bgCapsule_Flick.addSubview(likesBtn_Flick)
        likesBtn_Flick.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(bgCapsule_Flick.snp.centerX)
        }

        postsBtn_Flick.addTarget(self, action: #selector(postsBtnTapped_Flick), for: .touchUpInside)
        likesBtn_Flick.addTarget(self, action: #selector(likesBtnTapped_Flick), for: .touchUpInside)
    }

    func configure_Flick(activeIdx: Int) {
        updateAppearance_Flick(to: activeIdx, animated: false)
    }

    private func updateAppearance_Flick(to idx: Int, animated: Bool) {
        let isFirst = idx == 0
        postsBtn_Flick.tintColor     = isFirst ? ColorConfig_Flick.primaryGradientStart_Flick : ColorConfig_Flick.textSecondary_Flick
        postsBtn_Flick.titleLabel?.font = .systemFont(ofSize: 14, weight: isFirst ? .bold : .medium)
        postsBtn_Flick.setTitleColor(isFirst ? ColorConfig_Flick.primaryGradientStart_Flick : ColorConfig_Flick.textSecondary_Flick, for: .normal)
        likesBtn_Flick.tintColor     = isFirst ? ColorConfig_Flick.textSecondary_Flick : ColorConfig_Flick.primaryGradientStart_Flick
        likesBtn_Flick.titleLabel?.font = .systemFont(ofSize: 14, weight: isFirst ? .medium : .bold)
        likesBtn_Flick.setTitleColor(isFirst ? ColorConfig_Flick.textSecondary_Flick : ColorConfig_Flick.primaryGradientStart_Flick, for: .normal)

        activePill_Flick.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-6)
            if isFirst {
                make.left.equalToSuperview().inset(4)
            } else {
                make.right.equalToSuperview().inset(4)
            }
        }

        if animated {
            UIView.animate(
                withDuration: AnimationConfig_Flick.durationNormal_Flick,
                delay: 0,
                usingSpringWithDamping: AnimationConfig_Flick.springDampingNormal_Flick,
                initialSpringVelocity: AnimationConfig_Flick.springVelocity_Flick
            ) { self.bgCapsule_Flick.layoutIfNeeded() }
        } else {
            bgCapsule_Flick.layoutIfNeeded()
        }
    }

    @objc private func postsBtnTapped_Flick() {
        updateAppearance_Flick(to: 0, animated: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTabChanged_Flick?(0)
    }

    @objc private func likesBtnTapped_Flick() {
        updateAppearance_Flick(to: 1, animated: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTabChanged_Flick?(1)
    }
}

// MARK: - 帖子卡片 Cell

/// 我的页面 - 帖子卡片 Cell
/// 功能：封面图、底部渐变遮罩、标题、♥点赞数 + 💬评论数，右上角举报/删除按钮
class MePostCell_Flick: UICollectionViewCell {

    static let reuseId_Flick = "MePostCell_Flick"

    private let cardView_Flick: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.1).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 5)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 10
        v.clipsToBounds = false
        return v
    }()

    private let mediaView_Flick: MediaDisplayView_Flick = {
        let v = MediaDisplayView_Flick()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    /// 底部信息区（半透明磨砂卡）
    private let infoBar_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withValues(alpha: 0.45)
        v.layer.cornerRadius = 18
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let titleLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 点赞 + 评论数行
    private let metaRow_Flick: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()
    private let likesLabel_Flick  = MePostCell_Flick.makeMetaLabel_Flick()
    private let commentsLabel_Flick = MePostCell_Flick.makeMetaLabel_Flick()

    private var actionBtn_Flick: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Flick() {
        contentView.addSubview(cardView_Flick)
        cardView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }

        cardView_Flick.addSubview(mediaView_Flick)
        mediaView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }

        cardView_Flick.addSubview(infoBar_Flick)
        infoBar_Flick.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.48)
        }

        infoBar_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(10)
        }

        // ♥ 图标
        let heartIcon = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartIcon.tintColor = UIColor(hexstring_Flick: "#FBB6CE")
        heartIcon.snp.makeConstraints { $0.width.height.equalTo(11) }

        let chatIcon = UIImageView(image: UIImage(systemName: "bubble.right.fill"))
        chatIcon.tintColor = UIColor(hexstring_Flick: "#90CDF4")
        chatIcon.snp.makeConstraints { $0.width.height.equalTo(11) }

        metaRow_Flick.addArrangedSubview(heartIcon)
        metaRow_Flick.addArrangedSubview(likesLabel_Flick)
        metaRow_Flick.addArrangedSubview(chatIcon)
        metaRow_Flick.addArrangedSubview(commentsLabel_Flick)

        infoBar_Flick.addSubview(metaRow_Flick)
        metaRow_Flick.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(10)
        }
    }

    private static func makeMetaLabel_Flick() -> UILabel {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = UIColor.white.withValues(alpha: 0.9)
        return lbl
    }

    func configure_Flick(post: TitleModel_Flick, from vc: UIViewController, completion: (() -> Void)?) {
        titleLabel_Flick.text   = post.title_Flick
        likesLabel_Flick.text   = "\(post.likes_Flick)"
        commentsLabel_Flick.text = "\(post.reviews_Flick.count)"
        mediaView_Flick.configure_Flick(mediaPath_Flick: post.titleMeidas_Flick.first)

        actionBtn_Flick?.removeFromSuperview()
        let btn = ReportDeleteHelper_Flick.createPostReportButton_Flick(
            post_Flick: post, size_Flick: 12, color_Flick: .white,
            from: vc, completion_Flick: completion
        )
        btn.backgroundColor = UIColor.black.withValues(alpha: 0.35)
        btn.layer.cornerRadius = 11
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.white.withValues(alpha: 0.3).cgColor
        cardView_Flick.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8)
            make.width.height.equalTo(26)
        }
        actionBtn_Flick = btn
    }
}

// MARK: - 空状态 Cell

/// 帖子列表为空时的占位 Cell
/// 功能：虚线圆框 + 图标 + 文案提示 + 操作引导文字
class MeEmptyCell_Flick: UICollectionViewCell {

    static let reuseId_Flick = "MeEmptyCell_Flick"

    /// 虚线圆形边框容器
    private let dashedCircle_Flick = UIView()
    private var dashedBorder_Flick: CAShapeLayer?

    private let iconLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 44)
        lbl.textAlignment = .center
        return lbl
    }()

    private let titleLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = ColorConfig_Flick.textPrimary_Flick
        lbl.textAlignment = .center
        return lbl
    }()

    private let subtitleLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Flick.textSecondary_Flick
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateDashedBorder_Flick()
    }

    private func setupUI_Flick() {
        contentView.addSubview(dashedCircle_Flick)
        dashedCircle_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
            make.width.height.equalTo(100)
        }

        dashedCircle_Flick.addSubview(iconLabel_Flick)
        iconLabel_Flick.snp.makeConstraints { $0.center.equalToSuperview() }

        contentView.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(dashedCircle_Flick.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        contentView.addSubview(subtitleLabel_Flick)
        subtitleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Flick.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }
    }

    private func updateDashedBorder_Flick() {
        dashedBorder_Flick?.removeFromSuperlayer()
        let bounds = dashedCircle_Flick.bounds
        guard bounds.width > 0 else { return }
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 2, dy: 2)).cgPath
        shape.strokeColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.4).cgColor
        shape.fillColor   = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.06).cgColor
        shape.lineWidth   = 2
        shape.lineDashPattern = [6, 4]
        dashedCircle_Flick.layer.addSublayer(shape)
        dashedBorder_Flick = shape
    }

    func configure_Flick(isLiked: Bool) {
        iconLabel_Flick.text    = isLiked ? "🤍" : "✨"
        titleLabel_Flick.text   = isLiked ? "No Likes Yet"    : "No Posts Yet"
        subtitleLabel_Flick.text = isLiked
            ? "Explore feed and like posts\nyou enjoy!"
            : "Share your first moment\nwith the world!"
    }
}
