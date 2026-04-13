import Foundation
import UIKit
import SnapKit

// MARK: - 我的页面

/// 我的页面
/// 核心功能：展示当前登录用户的个人信息、统计数据、发布帖子与喜欢帖子列表
/// 设计思路：顶部渐变头部卡片（头像光环 + 用户名 + Bio + 编辑按钮）→ 浮出统计栏（Posts/Following/Liked）
///           → 自定义胶囊式滑动 Tab → 三列帖子网格（含视频标记）
/// 关键属性：
/// - currentPosts_Clara: 当前展示的帖子列表（随 Tab 切换更新）
/// - currentTab_Clara: 当前激活的 Tab（0=发布 1=喜欢）
/// 关键方法：
/// - refreshData_Clara: 刷新用户信息与统计数据
/// - switchTab_Clara: 切换 Tab 并驱动胶囊指示器弹性动画
class Me_Clara: UIViewController {

    var meModel_Clara: LoginUserModel_Clara?

    // MARK: - UI 组件

    /// 外层滚动视图
    private let scrollView_Clara: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    /// 滚动内容容器
    private let contentView_Clara = UIView()

    /// 渐变头部容器
    private let headerView_Clara = UIView()

    /// 渐变图层
    private var gradientLayer_Clara: CAGradientLayer?

    /// 头像光环外圈（渐变色边框效果）
    private let avatarRingView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 头像光环渐变图层
    private var avatarRingGl_Clara: CAGradientLayer?

    /// 头像白色底衬
    private let avatarWhiteBg_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        v.layer.cornerRadius = 47
        return v
    }()

    /// 头像组件
    private let avatarView_Clara: CurrentUserAvatarView_Clara = {
        let v = CurrentUserAvatarView_Clara()
        v.layer.cornerRadius = 42
        v.clipsToBounds = true
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 用户名标签
    private let nameLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 用户简介标签
    private let bioLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.82)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 编辑资料按钮
    private let editButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn.setImage(UIImage(systemName: "pencil", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.setTitle("  Edit Profile", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1.2
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
        return btn
    }()

    /// 设置按钮（右上角）
    private let settingButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: - 统计栏

    /// 统计卡片（浮于 Header 底部）
    private let statsCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 22
        v.layer.shadowColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.18).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 16
        return v
    }()

    /// 发帖数量标签
    private let postsCountLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.textColor = ColorConfig_Clara.primaryGradientStart_Clara
        l.text = "0"
        return l
    }()

    /// 关注数量标签
    private let followingCountLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.textColor = ColorConfig_Clara.primaryGradientEnd_Clara
        l.text = "0"
        return l
    }()

    /// 喜欢数量标签
    private let likedCountLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.textColor = ColorConfig_Clara.secondaryGradientStart_Clara
        l.text = "0"
        return l
    }()

    // MARK: - 自定义 Tab

    /// Tab 容器卡片
    private let tabCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 14
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 6
        return v
    }()

    /// 滑动胶囊指示器
    private let tabPill_Clara: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        return v
    }()

    /// 胶囊渐变图层
    private var tabPillGl_Clara: CAGradientLayer?

    /// Posts 按钮
    private let postsBtn_Clara: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Posts", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.tintColor = .white
        btn.tag = 0
        return btn
    }()

    /// Liked 按钮
    private let likedBtn_Clara: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Liked", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.tintColor = ColorConfig_Clara.textSecondary_Clara
        btn.tag = 1
        return btn
    }()

    // MARK: - 帖子集合

    /// 帖子集合视图
    private lazy var collectionView_Clara: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        cv.isScrollEnabled = false
        cv.register(MePostCell_Clara.self, forCellWithReuseIdentifier: MePostCell_Clara.reuseId_Clara)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    /// 空状态视图
    private let emptyView_Clara: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 数据属性

    /// 当前展示的帖子列表
    private var currentPosts_Clara: [TitleModel_Clara] = []

    /// 当前激活 Tab（0=发布, 1=喜欢）
    private var currentTab_Clara = 0

    /// 集合视图高度约束（动态更新）
    private var collectionHeightConstraint_Clara: Constraint?

    /// Tab 胶囊左侧偏移约束（动画用）
    private var tabPillLeftConstraint_Clara: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshData_Clara()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupScrollView_Clara()
        setupHeader_Clara()
        setupStatsCard_Clara()
        setupCustomTab_Clara()
        setupGrid_Clara()
        setupEmptyView_Clara()
        setupNotifications_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientLayer_Clara()
        updateTabPillGl_Clara()
        view.updateThemeBackgroundFrame_Clara()
    }

    // MARK: - UI 搭建

    /// 搭建外层滚动视图
    private func setupScrollView_Clara() {
        view.addSubview(scrollView_Clara)
        scrollView_Clara.addSubview(contentView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        scrollView_Clara.backgroundColor = .clear
        contentView_Clara.backgroundColor = .clear
        scrollView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    /// 搭建渐变头部区域（含头像光环、用户名、简介、编辑按钮、设置按钮）
    private func setupHeader_Clara() {
        contentView_Clara.addSubview(headerView_Clara)
        headerView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(300)
        }

        // 头部装饰小圆圈
        let decCircle1 = UIView()
        decCircle1.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        decCircle1.layer.cornerRadius = 55
        headerView_Clara.addSubview(decCircle1)
        decCircle1.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.right.equalToSuperview().inset(-24)
            make.top.equalToSuperview().inset(-24)
        }

        let decCircle2 = UIView()
        decCircle2.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        decCircle2.layer.cornerRadius = 40
        headerView_Clara.addSubview(decCircle2)
        decCircle2.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.left.equalToSuperview().inset(-20)
            make.bottom.equalToSuperview().inset(-10)
        }

        // 设置按钮
        headerView_Clara.addSubview(settingButton_Clara)
        settingButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.right.equalToSuperview().inset(18)
            make.width.height.equalTo(36)
        }
        settingButton_Clara.addTarget(self, action: #selector(settingTapped_Clara), for: .touchUpInside)

        // 头像光环
        headerView_Clara.addSubview(avatarRingView_Clara)
        avatarRingView_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.width.height.equalTo(94)
        }

        headerView_Clara.addSubview(avatarWhiteBg_Clara)
        avatarWhiteBg_Clara.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Clara)
            make.width.height.equalTo(94)
        }

        headerView_Clara.addSubview(avatarView_Clara)
        avatarView_Clara.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Clara)
            make.width.height.equalTo(84)
        }

        // 用户名
        headerView_Clara.addSubview(nameLabel_Clara)
        nameLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Clara.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
        }

        // 简介
        headerView_Clara.addSubview(bioLabel_Clara)
        bioLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Clara.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(32)
        }

        // 编辑按钮
        headerView_Clara.addSubview(editButton_Clara)
        editButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Clara.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(136)
            make.height.equalTo(34)
        }
        editButton_Clara.addTarget(self, action: #selector(editTapped_Clara), for: .touchUpInside)
    }

    /// 搭建浮出统计卡片（Posts / Following / Liked）
    private func setupStatsCard_Clara() {
        contentView_Clara.addSubview(statsCard_Clara)
        statsCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(headerView_Clara.snp.bottom).offset(-22)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(70)
        }

        let stats: [(label: UILabel, title: String)] = [
            (postsCountLabel_Clara, "Posts"),
            (followingCountLabel_Clara, "Following"),
            (likedCountLabel_Clara, "Liked")
        ]

        var prevView: UIView? = nil
        for (i, item) in stats.enumerated() {
            let container = UIView()
            statsCard_Clara.addSubview(container)
            container.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(stats.count)
                if let prev = prevView {
                    make.left.equalTo(prev.snp.right)
                } else {
                    make.left.equalToSuperview()
                }
            }

            let titleLbl = UILabel()
            titleLbl.text = item.title
            titleLbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            titleLbl.textColor = ColorConfig_Clara.textSecondary_Clara
            titleLbl.textAlignment = .center

            container.addSubview(item.label)
            container.addSubview(titleLbl)
            item.label.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(12)
            }
            titleLbl.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(item.label.snp.bottom).offset(3)
            }

            // 分割线（非最后一项）
            if i < stats.count - 1 {
                let divider = UIView()
                divider.backgroundColor = ColorConfig_Clara.divider_Clara
                statsCard_Clara.addSubview(divider)
                divider.snp.makeConstraints { make in
                    make.right.equalTo(container.snp.right)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(0.8)
                    make.height.equalTo(26)
                }
            }
            prevView = container
        }
    }

    /// 搭建自定义胶囊滑动 Tab
    private func setupCustomTab_Clara() {
        contentView_Clara.addSubview(tabCard_Clara)
        tabCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Clara.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        // 胶囊指示器
        tabCard_Clara.addSubview(tabPill_Clara)
        tabPill_Clara.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            tabPillLeftConstraint_Clara = make.left.equalToSuperview().offset(4).constraint
            make.width.equalToSuperview().dividedBy(2).offset(-4)
        }

        // Posts 按钮
        tabCard_Clara.addSubview(postsBtn_Clara)
        postsBtn_Clara.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        postsBtn_Clara.addTarget(self, action: #selector(tabBtnTapped_Clara(_:)), for: .touchUpInside)

        // Liked 按钮
        tabCard_Clara.addSubview(likedBtn_Clara)
        likedBtn_Clara.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        likedBtn_Clara.addTarget(self, action: #selector(tabBtnTapped_Clara(_:)), for: .touchUpInside)
    }

    /// 搭建帖子集合视图
    private func setupGrid_Clara() {
        contentView_Clara.addSubview(collectionView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        collectionView_Clara.backgroundColor = .clear
        collectionView_Clara.snp.makeConstraints { make in
            make.top.equalTo(tabCard_Clara.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            collectionHeightConstraint_Clara = make.height.equalTo(400).constraint
            make.bottom.equalToSuperview().inset(20)
        }
    }

    /// 搭建空状态视图
    private func setupEmptyView_Clara() {
        contentView_Clara.addSubview(emptyView_Clara)
        emptyView_Clara.snp.makeConstraints { make in
            make.top.equalTo(tabCard_Clara.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }

        let bgCircle = UIView()
        bgCircle.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.08)
        bgCircle.layer.cornerRadius = 44
        emptyView_Clara.addSubview(bgCircle)
        bgCircle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(88)
        }

        let iconView = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iconView.image = UIImage(systemName: "square.grid.2x2", withConfiguration: cfg)
        iconView.tintColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.5)
        iconView.contentMode = .scaleAspectFit
        bgCircle.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }

        let msgLabel = UILabel()
        msgLabel.text = "No posts yet"
        msgLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        msgLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        msgLabel.textAlignment = .center

        let subLabel = UILabel()
        subLabel.text = "Tap + to share your first moment"
        subLabel.font = UIFont.systemFont(ofSize: 12)
        subLabel.textColor = ColorConfig_Clara.textPlaceholder_Clara
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 2

        emptyView_Clara.addSubview(msgLabel)
        emptyView_Clara.addSubview(subLabel)
        msgLabel.snp.makeConstraints { make in
            make.top.equalTo(bgCircle.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(msgLabel.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - 渐变图层更新

    /// 更新头部渐变图层与头像光环
    private func updateGradientLayer_Clara() {
        if let existing = gradientLayer_Clara {
            existing.frame = headerView_Clara.bounds
        } else if headerView_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: headerView_Clara.bounds)
            headerView_Clara.layer.insertSublayer(gl, at: 0)
            gradientLayer_Clara = gl
        }
        // 头像光环渐变边框
        if avatarRingGl_Clara == nil && avatarRingView_Clara.bounds.width > 0 {
            let ringBounds = avatarRingView_Clara.bounds
            let gl = CAGradientLayer()
            gl.frame = ringBounds
            gl.colors = [
                UIColor.white.withAlphaComponent(0.85).cgColor,
                ColorConfig_Clara.secondaryGradientStart_Clara.withAlphaComponent(0.7).cgColor
            ]
            gl.startPoint = CGPoint(x: 0, y: 0)
            gl.endPoint = CGPoint(x: 1, y: 1)
            gl.cornerRadius = ringBounds.width / 2
            avatarRingView_Clara.layer.insertSublayer(gl, at: 0)
            avatarRingGl_Clara = gl
        }
    }

    /// 更新胶囊 Tab 的渐变图层
    private func updateTabPillGl_Clara() {
        if tabPillGl_Clara == nil && tabPill_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: tabPill_Clara.bounds)
            gl.cornerRadius = 10
            tabPill_Clara.layer.insertSublayer(gl, at: 0)
            tabPillGl_Clara = gl
        } else if let gl = tabPillGl_Clara {
            gl.frame = tabPill_Clara.bounds
        }
    }

    // MARK: - 数据刷新

    /// 刷新用户信息与帖子数据
    private func refreshData_Clara() {
        let user = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara()
        nameLabel_Clara.text = user.userName_Clara ?? "User"
        bioLabel_Clara.text = UserViewModel_Clara.shared_Clara.isLoggedIn_Clara
            ? ((user.userIntroduce_Clara?.isEmpty == false) ? user.userIntroduce_Clara : "Write your profile bio")
            : "Sign in to share your moments"

        // 更新统计数
        postsCountLabel_Clara.text = "\(user.userPosts_Clara.count)"
        followingCountLabel_Clara.text = "\(user.userFollow_Clara.count)"
        likedCountLabel_Clara.text = "\(user.userLike_Clara.count)"

        currentPosts_Clara = currentTab_Clara == 0 ? user.userPosts_Clara : user.userLike_Clara
        emptyView_Clara.isHidden = !currentPosts_Clara.isEmpty
        collectionView_Clara.isHidden = currentPosts_Clara.isEmpty
        collectionView_Clara.reloadData()

        // 动态更新集合视图高度
        let cols: CGFloat = 3
        let cellW = (UIScreen.main.bounds.width - 6) / cols
        let rows = ceil(CGFloat(currentPosts_Clara.count) / cols)
        let cvH = max(rows * (cellW + 3), 400)
        collectionHeightConstraint_Clara?.update(offset: cvH)
        scrollView_Clara.layoutIfNeeded()
    }

    // MARK: - 通知监听

    /// 注册状态变更通知
    private func setupNotifications_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Clara),
            name: UserViewModel_Clara.userStateDidChangeNotification_Clara,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Clara),
            name: TitleViewModel_Clara.titleStateDidChangeNotification_Clara,
            object: nil
        )
    }

    @objc private func handleStateChange_Clara() {
        refreshData_Clara()
    }

    // MARK: - 事件响应

    @objc private func editTapped_Clara() {
        Navigation_Clara.toEditInfo_Clara()
    }

    @objc private func settingTapped_Clara() {
        Navigation_Clara.toSetting_Clara()
    }

    /// Tab 按钮点击
    @objc private func tabBtnTapped_Clara(_ sender: UIButton) {
        let newTab = sender.tag
        guard newTab != currentTab_Clara else { return }
        currentTab_Clara = newTab
        switchTab_Clara(to: newTab)
        refreshData_Clara()
    }

    /// 切换 Tab：驱动胶囊弹性动画并更新按钮颜色/字重
    private func switchTab_Clara(to index: Int) {
        let containerW = tabCard_Clara.bounds.width
        let pillW = containerW / 2 - 4
        let targetX: CGFloat = index == 0 ? 4 : pillW + 4

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 0.5) {
            self.tabPillLeftConstraint_Clara?.update(offset: targetX)
            self.tabCard_Clara.layoutIfNeeded()
        }

        postsBtn_Clara.tintColor = index == 0 ? .white : ColorConfig_Clara.textSecondary_Clara
        postsBtn_Clara.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: index == 0 ? .semibold : .medium)
        likedBtn_Clara.tintColor = index == 1 ? .white : ColorConfig_Clara.textSecondary_Clara
        likedBtn_Clara.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: index == 1 ? .semibold : .medium)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionView 代理

extension Me_Clara: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPosts_Clara.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Clara.reuseId_Clara,
            for: indexPath
        ) as! MePostCell_Clara
        let post = currentPosts_Clara[indexPath.item]
        cell.configure_Clara(post_Clara: post, viewController_Clara: self) { [weak self] in
            self?.refreshData_Clara()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (collectionView.bounds.width - 6) / 3
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = currentPosts_Clara[indexPath.item]
        Navigation_Clara.toTitleDetail_Clara(titleModel_clara: post)
    }
}

// MARK: - 帖子缩略图 Cell

/// 我的页面帖子缩略图单元格
/// 功能：展示帖子媒体缩略图，右上角提供举报/删除按钮，左下角展示视频标记徽标
class MePostCell_Clara: UICollectionViewCell {

    static let reuseId_Clara = "MePostCell_Clara"

    // MARK: - UI

    /// 媒体展示视图
    private let mediaView_Clara = MediaDisplayView_Clara()

    /// 视频类型标记
    private let videoTagView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.52)
        v.layer.cornerRadius = 8
        v.isHidden = true
        return v
    }()

    private let videoTagIcon_Clara: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 8, weight: .semibold)
        iv.image = UIImage(systemName: "play.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 举报/删除按钮（弱引用）
    private weak var actionButton_Clara: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true

        contentView.addSubview(mediaView_Clara)
        mediaView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mediaView_Clara.layer.cornerRadius = 0

        contentView.addSubview(videoTagView_Clara)
        videoTagView_Clara.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().inset(6)
            make.width.height.equalTo(22)
        }
        videoTagView_Clara.addSubview(videoTagIcon_Clara)
        videoTagIcon_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置单元格内容
    /// - Parameters:
    ///   - post_Clara: 帖子模型
    ///   - viewController_Clara: 所在页面（用于弹出 Alert）
    ///   - completion_Clara: 帖子被删除/举报后的刷新回调
    func configure_Clara(
        post_Clara: TitleModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        let mediaPath = post_Clara.titleMeidas_Clara.first
        let isVideo = mediaPath?.hasSuffix(".mp4") == true || mediaPath?.hasSuffix(".mov") == true
        mediaView_Clara.configure_Clara(mediaPath_Clara: mediaPath, isVideo_Clara: isVideo)
        videoTagView_Clara.isHidden = !isVideo

        actionButton_Clara?.removeFromSuperview()
        let btn = ReportDeleteHelper_Clara.createPostReportButton_Clara(
            post_Clara: post_Clara,
            size_Clara: 14,
            color_Clara: .white,
            from: viewController_Clara,
            completion_Clara: completion_Clara
        )
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        btn.layer.cornerRadius = 11
        contentView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().inset(6)
            make.width.height.equalTo(26)
        }
        actionButton_Clara = btn
    }
}
