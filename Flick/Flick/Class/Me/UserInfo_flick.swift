import UIKit
import SnapKit

// MARK: - 用户中心页

/// 用户中心页面控制器
/// 功能：展示预制用户的个人信息、关注/粉丝统计、关注与聊天操作、帖子列表
/// 设计：波浪渐变头部 + UICollectionView 双栏帖子网格
/// 数据：通过 NotificationCenter 监听状态变更自动刷新
class UserInfo_Flick: UIViewController {

    // MARK: - 属性

    /// 外部传入的用户模型
    var userModel_Flick: PrewUserModel_Flick?

    /// 该用户的帖子列表（从 TitleViewModel 查询）
    private var userPosts_Flick: [TitleModel_Flick] {
        guard let user = userModel_Flick else { return [] }
        return TitleViewModel_Flick.shared_Flick.getUserPosts_Flick(user_flick: user)
    }

    // MARK: - UI

    private lazy var collectionView_Flick: UICollectionView = {
        let layout = buildLayout_Flick()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        // 禁止自动 inset，确保渐变头部贴顶
        cv.contentInsetAdjustmentBehavior = .never
        cv.delegate   = self
        cv.dataSource = self
        cv.register(UserInfoHeaderCell_Flick.self,
                    forCellWithReuseIdentifier: UserInfoHeaderCell_Flick.reuseId_Flick)
        cv.register(MePostCell_Flick.self,
                    forCellWithReuseIdentifier: MePostCell_Flick.reuseId_Flick)
        cv.register(MeEmptyCell_Flick.self,
                    forCellWithReuseIdentifier: MeEmptyCell_Flick.reuseId_Flick)
        return cv
    }()

    /// 顶部悬浮返回按钮（不随 collectionView 滚动）
    private let backBtn_Flick = BackButton_Flick()

    /// 右上角举报按钮
    private let reportBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withValues(alpha: 0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        bindNotifications_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 首次出现后补触发 Cell 布局，确保 CALayer 渐变在有效 bounds 下渲染
        collectionView_Flick.visibleCells.forEach { $0.setNeedsLayout(); $0.layoutIfNeeded() }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        view.addSubview(collectionView_Flick)
        collectionView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 顶部悬浮栏（返回 + 举报）
        let topBar = UIView()
        topBar.isUserInteractionEnabled = true
        view.addSubview(topBar)
        topBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(88)
        }

        topBar.addSubview(backBtn_Flick)
        backBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(topBar.safeAreaLayoutGuide.snp.top).offset(8)
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }
        backBtn_Flick.onTapped_Flick = { [weak self] in
            Navigation_Flick.pop_Flick(from: self)
        }

        topBar.addSubview(reportBtn_Flick)
        reportBtn_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Flick)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
        reportBtn_Flick.addTarget(self, action: #selector(reportBtnTapped_Flick), for: .touchUpInside)
    }

    // MARK: - CompositionalLayout

    private func buildLayout_Flick() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIdx, _ in
            guard let self else { return nil }
            switch sectionIdx {
            case 0:
                // 头部：自适应高度
                let size = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(400)
                )
                return NSCollectionLayoutSection(
                    group: .horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)])
                )
            default:
                if self.userPosts_Flick.isEmpty {
                    // 空状态：单列全宽
                    let size = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(240)
                    )
                    return NSCollectionLayoutSection(
                        group: .horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)])
                    )
                }
                // 帖子网格：双栏
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalWidth(0.62)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 5, leading: 6, bottom: 5, trailing: 6)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(0.62)
                )
                let section = NSCollectionLayoutSection(
                    group: .horizontal(layoutSize: groupSize, subitems: [item])
                )
                section.contentInsets = .init(top: 4, leading: 6, bottom: 40, trailing: 6)
                return section
            }
        }
    }

    // MARK: - 通知绑定

    private func bindNotifications_Flick() {
        [UserViewModel_Flick.userStateDidChangeNotification_Flick,
         TitleViewModel_Flick.titleStateDidChangeNotification_Flick].forEach {
            NotificationCenter.default.addObserver(self,
                selector: #selector(onDataChanged_Flick), name: $0, object: nil)
        }
    }

    @objc private func onDataChanged_Flick() {
        if let id_flick = userModel_Flick?.userId_Flick {
            userModel_Flick = UserViewModel_Flick.shared_Flick.getUserById_Flick(userId_flick: id_flick)
        }
        collectionView_Flick.reloadData()
    }

    // MARK: - 事件处理

    /// 举报/拉黑用户，完成后返回上一页
    @objc private func reportBtnTapped_Flick() {
        guard let user = userModel_Flick else { return }
        ReportDeleteHelper_Flick.block_Flick(user_Flick: user, from: self) { [weak self] in
            Navigation_Flick.pop_Flick(from: self)
        }
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension UserInfo_Flick: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        // 空状态也需要展示 1 个占位 cell
        return max(1, userPosts_Flick.count)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserInfoHeaderCell_Flick.reuseId_Flick, for: indexPath
            ) as! UserInfoHeaderCell_Flick
            if let user = userModel_Flick {
                cell.configure_Flick(user: user, from: self)
            }
            return cell
        }

        // 空状态 Cell
        if userPosts_Flick.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MeEmptyCell_Flick.reuseId_Flick, for: indexPath
            ) as! MeEmptyCell_Flick
            cell.configure_Flick(isLiked: false)
            return cell
        }

        // 帖子 Cell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Flick.reuseId_Flick, for: indexPath
        ) as! MePostCell_Flick
        let post = userPosts_Flick[indexPath.item]
        cell.configure_Flick(post: post, from: self) { [weak self] in
            self?.collectionView_Flick.reloadData()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1, !userPosts_Flick.isEmpty else { return }
        let post = userPosts_Flick[indexPath.item]
        Navigation_Flick.toTitleDetail_Flick(titleModel_flick: post)
    }
}

// MARK: - 用户中心头部 Cell

/// 用户中心头部 Cell
/// 功能：波浪渐变背景、渐变头像环、UserAvatarView、用户名/简介、
///        关注/粉丝统计卡、关注按钮（渐变）、聊天按钮（Replace 导航）、帖子区标题
/// 设计：所有 CALayer 懒初始化，避免空 path 遮盖渐变
private class UserInfoHeaderCell_Flick: UICollectionViewCell {

    static let reuseId_Flick = "UserInfoHeaderCell_Flick"

    // MARK: - 渐变背景

    private let gradientBg_Flick = UIView()
    private var gradLayer_Flick: CAGradientLayer?
    private var waveMask_Flick: CAShapeLayer?

    // MARK: - 头像环

    private let avatarRing_Flick = UIView()
    private var ringGrad_Flick: CAGradientLayer?
    private var ringMask_Flick: CAShapeLayer?

    // MARK: - 头像

    private let avatarView_Flick: UserAvatarView_Flick = {
        let v = UserAvatarView_Flick()
        v.layer.cornerRadius = 44
        v.clipsToBounds = false
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    // MARK: - 用户信息

    private let nameLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        l.textAlignment = .center
        return l
    }()
    private let bioLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Flick.textSecondary_Flick
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - 统计卡

    private let statsCard_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor  = UIColor(hexstring_Flick: "#B794F6").withValues(alpha: 0.12).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius  = 10
        return v
    }()
    private let followsValLabel_Flick = UserInfoHeaderCell_Flick.makeStatValLabel_Flick()
    private let fansValLabel_Flick    = UserInfoHeaderCell_Flick.makeStatValLabel_Flick()

    // MARK: - 操作按钮行

    private let buttonRow_Flick = UIView()

    /// 关注/已关注按钮（渐变 → 未关注 / 边框线 → 已关注）
    private let followBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Follow", for: .normal)
        btn.setTitle("Followed", for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(ColorConfig_Flick.primaryGradientStart_Flick, for: .selected)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth  = 1.5
        btn.layer.borderColor  = ColorConfig_Flick.primaryGradientStart_Flick.cgColor
        btn.clipsToBounds = true
        return btn
    }()
    private var followGrad_Flick: CAGradientLayer?

    /// 聊天按钮（使用 Replace 方式跳转，替换当前页为聊天页）
    private let chatBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "message.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Message", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.tintColor = ColorConfig_Flick.primaryGradientStart_Flick
        btn.setTitleColor(ColorConfig_Flick.primaryGradientStart_Flick, for: .normal)
        btn.backgroundColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.09)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth  = 1.5
        btn.layer.borderColor  = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.3).cgColor
        return btn
    }()

    // MARK: - 帖子区标题

    private let postsSectionLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Posts"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        return l
    }()

    // MARK: - 弱引用 VC（用于导航）

    private weak var vcRef_Flick: UIViewController?
    private var userRef_Flick: PrewUserModel_Flick?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Flick?.frame = gradientBg_Flick.bounds
        applyWaveMask_Flick()
        updateAvatarRing_Flick()
        updateFollowGradient_Flick()
    }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        backgroundColor = .clear

        // 渐变背景
        contentView.addSubview(gradientBg_Flick)
        gradientBg_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(158)
        }
        let g = UIColor.createPrimaryGradientLayer_Flick(
            frame_Flick: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 158)
        )
        gradientBg_Flick.layer.insertSublayer(g, at: 0)
        gradLayer_Flick = g

        // 装饰星点
        for (txt, x, y, sz, alpha) in [("✦", 40.0, 38.0, 13.0, 0.4),
                                        ("✦", 285.0, 62.0, 9.0,  0.3),
                                        ("✦", 335.0, 26.0, 8.0,  0.5)] {
            let lbl = UILabel()
            lbl.text = txt
            lbl.font = .systemFont(ofSize: CGFloat(sz))
            lbl.textColor = UIColor.white.withValues(alpha: CGFloat(alpha))
            gradientBg_Flick.addSubview(lbl)
            lbl.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
            }
        }

        // 头像渐变环
        contentView.addSubview(avatarRing_Flick)
        avatarRing_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(105)
            make.width.height.equalTo(100)
        }
        setupAvatarRing_Flick()

        // 头像
        contentView.addSubview(avatarView_Flick)
        avatarView_Flick.snp.makeConstraints { make in
            make.center.equalTo(avatarRing_Flick)
            make.width.height.equalTo(88)
        }

        // 用户名
        contentView.addSubview(nameLabel_Flick)
        nameLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Flick.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }

        // 简介
        contentView.addSubview(bioLabel_Flick)
        bioLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Flick.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }

        // 统计卡
        setupStatsCard_Flick()

        // 操作按钮行
        setupButtonRow_Flick()

        // 帖子区标题（帖子网格的分区标题）
        contentView.addSubview(postsSectionLabel_Flick)
        postsSectionLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(buttonRow_Flick.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    /// 统计卡（关注数 / 粉丝数）
    private func setupStatsCard_Flick() {
        contentView.addSubview(statsCard_Flick)
        statsCard_Flick.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Flick.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(66)
        }

        let followsItem = buildStatItem_Flick(valueLabel: followsValLabel_Flick, title: "Follows")
        let sep         = makeSeparator_Flick()
        let fansItem    = buildStatItem_Flick(valueLabel: fansValLabel_Flick,    title: "Fans")

        let stack = UIStackView(arrangedSubviews: [followsItem, sep, fansItem])
        stack.axis         = .horizontal
        stack.distribution = .equalCentering
        stack.alignment    = .center
        sep.snp.makeConstraints { m in m.width.equalTo(1); m.height.equalTo(32) }

        statsCard_Flick.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
        }
    }

    /// 操作按钮行（关注 + 聊天）
    private func setupButtonRow_Flick() {
        contentView.addSubview(buttonRow_Flick)
        buttonRow_Flick.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Flick.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        buttonRow_Flick.addSubview(followBtn_Flick)
        followBtn_Flick.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(buttonRow_Flick.snp.centerX).offset(-8)
        }
        followBtn_Flick.addTarget(self, action: #selector(followBtnTapped_Flick), for: .touchUpInside)

        buttonRow_Flick.addSubview(chatBtn_Flick)
        chatBtn_Flick.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(buttonRow_Flick.snp.centerX).offset(8)
        }
        chatBtn_Flick.addTarget(self, action: #selector(chatBtnTapped_Flick), for: .touchUpInside)
    }

    // MARK: - 头像渐变环

    private func setupAvatarRing_Flick() {
        let g = CAGradientLayer()
        g.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.secondaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint   = CGPoint(x: 1, y: 1)
        avatarRing_Flick.layer.addSublayer(g)
        ringGrad_Flick = g
    }

    /// bounds 有效时懒初始化甜甜圈遮罩
    private func updateAvatarRing_Flick() {
        let b = avatarRing_Flick.bounds
        guard b.width > 0 else { return }
        ringGrad_Flick?.frame = b
        if ringMask_Flick == nil {
            let mask = CAShapeLayer()
            mask.fillRule  = .evenOdd
            mask.fillColor = UIColor.black.cgColor
            avatarRing_Flick.layer.mask = mask
            ringMask_Flick = mask
        }
        let outer = UIBezierPath(ovalIn: b)
        let inner = UIBezierPath(ovalIn: b.insetBy(dx: 4, dy: 4))
        outer.append(inner.reversing())
        ringMask_Flick?.path = outer.cgPath
    }

    // MARK: - 波浪遮罩

    private func applyWaveMask_Flick() {
        let b = gradientBg_Flick.bounds
        guard b.width > 0 else { return }
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: b.width, y: 0))
        path.addLine(to: CGPoint(x: b.width, y: b.height - 20))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: b.height - 20),
            controlPoint: CGPoint(x: b.width / 2, y: b.height + 18)
        )
        path.close()
        if waveMask_Flick == nil {
            let mask = CAShapeLayer()
            mask.fillColor = UIColor.black.cgColor
            gradientBg_Flick.layer.mask = mask
            waveMask_Flick = mask
        }
        waveMask_Flick?.path = path.cgPath
    }

    // MARK: - 关注按钮渐变

    /// 未关注时显示渐变填充，已关注时移除渐变显示边框线样式
    private func updateFollowGradient_Flick() {
        guard followBtn_Flick.bounds.width > 0 else { return }
        if followBtn_Flick.isSelected {
            followGrad_Flick?.removeFromSuperlayer()
            followGrad_Flick = nil
            followBtn_Flick.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
            return
        }
        followBtn_Flick.backgroundColor = .clear
        if let g = followGrad_Flick { g.frame = followBtn_Flick.bounds; return }
        let g = UIColor.createPrimaryGradientLayer_Flick(frame_Flick: followBtn_Flick.bounds)
        g.cornerRadius = 20
        followBtn_Flick.layer.insertSublayer(g, at: 0)
        followGrad_Flick = g
    }

    // MARK: - 辅助构建方法

    private static func makeStatValLabel_Flick() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        l.textAlignment = .center
        l.text = "0"
        return l
    }

    private func buildStatItem_Flick(valueLabel: UILabel, title: String) -> UIView {
        let v = UIView()
        let t = UILabel()
        t.text = title
        t.font = .systemFont(ofSize: 11, weight: .medium)
        t.textColor = ColorConfig_Flick.textSecondary_Flick
        t.textAlignment = .center
        v.addSubview(valueLabel)
        v.addSubview(t)
        valueLabel.snp.makeConstraints { make in make.top.centerX.equalToSuperview() }
        t.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(2)
            make.centerX.bottom.equalToSuperview()
        }
        return v
    }

    private func makeSeparator_Flick() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.divider_Flick
        return v
    }

    // MARK: - 数据绑定

    /// 绑定用户数据到所有 UI 元素
    /// - Parameters:
    ///   - user: 预制用户模型
    ///   - vc: 宿主 ViewController（用于关注/聊天导航）
    func configure_Flick(user: PrewUserModel_Flick, from vc: UIViewController) {
        vcRef_Flick  = vc
        userRef_Flick = user

        // 头像（通过 userId 加载）
        if let uid = user.userId_Flick {
            avatarView_Flick.configure_Flick(userId_Flick: uid)
        }

        nameLabel_Flick.text = user.userName_Flick ?? "User"
        bioLabel_Flick.text  = (user.userIntroduce_Flick?.isEmpty == false)
            ? user.userIntroduce_Flick
            : "Hello, I'm using Flick 👋"

        followsValLabel_Flick.text = "\(user.userFollow_Flick ?? 0)"
        fansValLabel_Flick.text    = "\(user.userFans_Flick ?? 0)"

        // 关注状态
        let isFollowing = UserViewModel_Flick.shared_Flick.isFollowing_Flick(user_flick: user)
        followBtn_Flick.isSelected = isFollowing

        setNeedsLayout()
    }

    // MARK: - 事件

    /// 关注 / 取消关注
    @objc private func followBtnTapped_Flick() {
        guard let user = userRef_Flick else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UserViewModel_Flick.shared_Flick.followUser_Flick(user_flick: user)
        let isFollowing = UserViewModel_Flick.shared_Flick.isFollowing_Flick(user_flick: user)
        followBtn_Flick.isSelected = isFollowing
        // 触发渐变更新
        setNeedsLayout()
        layoutIfNeeded()
    }

    /// 进入聊天（Replace 方式替换当前页，避免导航栈叠加）
    @objc private func chatBtnTapped_Flick() {
        guard let user = userRef_Flick, let vc = vcRef_Flick else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let chatVC = MessageUser_Flick()
        chatVC.userModel_Flick = user
        Navigation_Flick.replace_Flick(to: chatVC, from: vc)
    }
}
