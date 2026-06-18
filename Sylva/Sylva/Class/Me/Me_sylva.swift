import Foundation
import UIKit
import SnapKit

// MARK: - 我的页面（Premium 重构版）

/// 我的页视图控制器
/// 核心作用：展示登录用户个人信息、统计数据及帖子/喜欢列表
/// 设计思路：沉浸式渐变 Hero（渐变 mask 仅裁渐变层）+ 自定义 Pill Tab + 丰化帖子卡片
class Me_Sylva: UIViewController {

    // MARK: - 公开属性

    var meModel_Sylva: LoginUserModel_Sylva?

    // MARK: - 私有属性

    private let scrollView_Sylva = UIScrollView()
    private let contentView_Sylva = UIView()

    /// Hero 头部
    private let headerView_Sylva     = UIView()
    private let headerGradient_Sylva = CAGradientLayer()
    private let headerGradMask_Sylva = CAShapeLayer()

    /// 用户信息
    private let avatarView_Sylva      = CurrentUserAvatarView_Sylva()
    private let nameLabel_Sylva       = UILabel()
    private let introduceLabel_Sylva  = UILabel()
    private let statsRow_Sylva        = UIView()

    /// 自定义分段 Tab
    private let tabContainer_Sylva    = UIView()
    private let tabIndicator_Sylva    = UIView()
    private let postsTabBtn_Sylva     = UIButton(type: .system)
    private let likedTabBtn_Sylva     = UIButton(type: .system)
    private var selectedSegment_Sylva = 0

    /// 帖子列表
    private var postListView_Sylva: UITableView!
    private var displayPosts_Sylva: [TitleModel_Sylva] = []
    /// 帖子空状态视图
    private let emptyPostView_Sylva = UIView()

    private var isLoggedIn_Sylva: Bool { UserViewModel_Sylva.shared_Sylva.isLoggedIn_Sylva }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        setupScrollView_Sylva()
        setupHeaderView_Sylva()
        setupTabBar_Sylva()
        setupPostList_Sylva()
        observeNotifications_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshAll_Sylva()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds_sylva = headerView_Sylva.bounds
        headerGradient_Sylva.frame = bounds_sylva
        // 只对渐变层做底部圆角 mask，子视图不被裁切
        let path_sylva = UIBezierPath(
            roundedRect: bounds_sylva,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 30, height: 30)
        )
        headerGradMask_Sylva.path = path_sylva.cgPath
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupScrollView_Sylva() {
        scrollView_Sylva.showsVerticalScrollIndicator = false
        scrollView_Sylva.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(contentView_Sylva)
        scrollView_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
    }

    /// 搭建渐变 Hero 头部
    private func setupHeaderView_Sylva() {
        // 渐变：深绿 → 中绿
        headerGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#40916C").cgColor
        ]
        headerGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Sylva.endPoint   = CGPoint(x: 1, y: 1)
        headerGradient_Sylva.mask       = headerGradMask_Sylva
        headerView_Sylva.layer.insertSublayer(headerGradient_Sylva, at: 0)
        contentView_Sylva.addSubview(headerView_Sylva)
        headerView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 固定高度覆盖所有机型安全区（Dynamic Island 约 59pt，此处用 360 确保内容不顶进状态栏）
            make.height.equalTo(360)
        }

        // 装饰圆（几何感）
        let decoBig_sylva = UIView()
        decoBig_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        decoBig_sylva.layer.cornerRadius = 70
        headerView_Sylva.addSubview(decoBig_sylva)
        decoBig_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-30)
            make.leading.equalToSuperview().offset(-30)
            make.width.height.equalTo(140)
        }

        let decoSmall_sylva = UIView()
        decoSmall_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        decoSmall_sylva.layer.cornerRadius = 50
        headerView_Sylva.addSubview(decoSmall_sylva)
        decoSmall_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(20)
            make.width.height.equalTo(100)
        }

        // 设置按钮：直接加在 view 上（而非 scrollView 内部），用 safeAreaLayoutGuide 定位
        // 这样无论安全区高度如何变化，按钮始终在正确位置且可点击
        let settingBtn_sylva = UIButton(type: .system)
        let settingCfg_sylva = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        settingBtn_sylva.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: settingCfg_sylva), for: .normal)
        settingBtn_sylva.tintColor = .white
        settingBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        settingBtn_sylva.layer.cornerRadius = 18
        settingBtn_sylva.addTarget(self, action: #selector(settingTapped_Sylva), for: .touchUpInside)
        view.addSubview(settingBtn_sylva)
        settingBtn_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }

        // 头像（白色圆环 + 阴影）
        avatarView_Sylva.layer.cornerRadius = 46
        avatarView_Sylva.layer.masksToBounds = true
        avatarView_Sylva.layer.borderWidth = 3.5
        avatarView_Sylva.layer.borderColor = UIColor.white.cgColor
        avatarView_Sylva.onTapped_Sylva = { Navigation_Sylva.toEditInfo_Sylva() }
        headerView_Sylva.addSubview(avatarView_Sylva)
        avatarView_Sylva.snp.makeConstraints { make in
            // 固定 72pt 偏移，确保头像在所有机型安全区（Dynamic Island/刘海）下方
            make.top.equalToSuperview().offset(72)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }

        // 用户名
        nameLabel_Sylva.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        nameLabel_Sylva.textColor = .white
        nameLabel_Sylva.textAlignment = .center
        headerView_Sylva.addSubview(nameLabel_Sylva)
        nameLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Sylva.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 简介
        introduceLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        introduceLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#95D5B2")
        introduceLabel_Sylva.textAlignment = .center
        introduceLabel_Sylva.numberOfLines = 2
        headerView_Sylva.addSubview(introduceLabel_Sylva)
        introduceLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Sylva.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }

        // 统计数据行
        setupStatsRow_Sylva()

        // Edit Profile 按钮（白色边框胶囊）
        let editBtn_sylva = UIButton(type: .system)
        editBtn_sylva.setTitle("Edit Profile", for: .normal)
        editBtn_sylva.setTitleColor(.white, for: .normal)
        editBtn_sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        editBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        editBtn_sylva.layer.cornerRadius = 17
        editBtn_sylva.layer.borderWidth = 1.5
        editBtn_sylva.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        editBtn_sylva.addTarget(self, action: #selector(editProfileTapped_Sylva), for: .touchUpInside)
        headerView_Sylva.addSubview(editBtn_sylva)
        editBtn_sylva.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Sylva.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(148)
            make.height.equalTo(34)
        }
    }

    /// 搭建统计数据行（关注/喜欢/帖子，带竖线分隔）
    private func setupStatsRow_Sylva() {
        headerView_Sylva.addSubview(statsRow_Sylva)
        statsRow_Sylva.snp.makeConstraints { make in
            make.top.equalTo(introduceLabel_Sylva.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(54)
        }

        // 半透明背景
        let statsBg_sylva = UIView()
        statsBg_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        statsBg_sylva.layer.cornerRadius = 16
        statsRow_Sylva.addSubview(statsBg_sylva)
        statsBg_sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let configs_sylva = [(0, "Following"), (0, "Liked"), (0, "Posts")]
        let stack_sylva = UIStackView()
        stack_sylva.axis = .horizontal
        stack_sylva.distribution = .fillEqually
        statsRow_Sylva.addSubview(stack_sylva)
        stack_sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        for (i_sylva, cfg_sylva) in configs_sylva.enumerated() {
            let item_sylva = UIView()
            let numLabel_sylva = UILabel()
            numLabel_sylva.text = "0"
            numLabel_sylva.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
            numLabel_sylva.textColor = .white
            numLabel_sylva.textAlignment = .center
            numLabel_sylva.tag = 100 + i_sylva
            item_sylva.addSubview(numLabel_sylva)
            numLabel_sylva.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.centerX.equalToSuperview()
            }
            let titleLabel_sylva = UILabel()
            titleLabel_sylva.text = cfg_sylva.1
            titleLabel_sylva.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            titleLabel_sylva.textColor = UIColor.white.withAlphaComponent(0.65)
            titleLabel_sylva.textAlignment = .center
            item_sylva.addSubview(titleLabel_sylva)
            titleLabel_sylva.snp.makeConstraints { make in
                make.top.equalTo(numLabel_sylva.snp.bottom).offset(3)
                make.centerX.equalToSuperview()
            }
            stack_sylva.addArrangedSubview(item_sylva)

            // 竖线分隔
            if i_sylva < configs_sylva.count - 1 {
                let divider_sylva = UIView()
                divider_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                statsRow_Sylva.addSubview(divider_sylva)
                divider_sylva.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.width.equalTo(1)
                    make.height.equalToSuperview().multipliedBy(0.5)
                    // 竖线定位到分区边界
                    make.leading.equalToSuperview()
                        .offset(CGFloat(i_sylva + 1) * (view.bounds.width - 48) / 3)
                }
            }
        }
    }

    /// 搭建自定义 Pill 分段 Tab
    private func setupTabBar_Sylva() {
        tabContainer_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#D8F3DC")
        tabContainer_Sylva.layer.cornerRadius = 14
        contentView_Sylva.addSubview(tabContainer_Sylva)
        tabContainer_Sylva.snp.makeConstraints { make in
            make.top.equalTo(headerView_Sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        // 滑动指示器（白色 pill）
        tabIndicator_Sylva.backgroundColor = .white
        tabIndicator_Sylva.layer.cornerRadius = 11
        tabIndicator_Sylva.layer.shadowColor = UIColor.black.cgColor
        tabIndicator_Sylva.layer.shadowOpacity = 0.08
        tabIndicator_Sylva.layer.shadowRadius = 4
        tabIndicator_Sylva.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabContainer_Sylva.addSubview(tabIndicator_Sylva)
        tabIndicator_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalToSuperview().offset(4)
            make.width.equalToSuperview().dividedBy(2).offset(-6)
        }

        // Posts 按钮
        postsTabBtn_Sylva.setTitle("Posts", for: .normal)
        postsTabBtn_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#1B4332"), for: .normal)
        postsTabBtn_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        postsTabBtn_Sylva.addTarget(self, action: #selector(postsTabTapped_Sylva), for: .touchUpInside)
        tabContainer_Sylva.addSubview(postsTabBtn_Sylva)
        postsTabBtn_Sylva.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }

        // Liked 按钮
        likedTabBtn_Sylva.setTitle("Liked", for: .normal)
        likedTabBtn_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#40916C"), for: .normal)
        likedTabBtn_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        likedTabBtn_Sylva.addTarget(self, action: #selector(likedTabTapped_Sylva), for: .touchUpInside)
        tabContainer_Sylva.addSubview(likedTabBtn_Sylva)
        likedTabBtn_Sylva.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
    }

    /// 搭建帖子列表及空状态
    private func setupPostList_Sylva() {
        postListView_Sylva = UITableView()
        postListView_Sylva.backgroundColor = .clear
        postListView_Sylva.separatorStyle = .none
        postListView_Sylva.isScrollEnabled = false
        postListView_Sylva.dataSource = self
        postListView_Sylva.delegate   = self
        postListView_Sylva.register(MePostCell_Sylva.self, forCellReuseIdentifier: MePostCell_Sylva.reuseId_Sylva)
        contentView_Sylva.addSubview(postListView_Sylva)
        postListView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(tabContainer_Sylva.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-20)
        }

        // 空状态卡片（无帖子时显示）
        emptyPostView_Sylva.backgroundColor = .white
        emptyPostView_Sylva.layer.cornerRadius = 18
        emptyPostView_Sylva.layer.shadowColor  = UIColor.black.cgColor
        emptyPostView_Sylva.layer.shadowOpacity = 0.05
        emptyPostView_Sylva.layer.shadowRadius  = 10
        emptyPostView_Sylva.layer.shadowOffset  = CGSize(width: 0, height: 3)
        emptyPostView_Sylva.isHidden = true
        contentView_Sylva.addSubview(emptyPostView_Sylva)
        emptyPostView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(tabContainer_Sylva.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(150)
            make.bottom.equalToSuperview().offset(-20)
        }

        // 空状态图标
        let emptyIcon_sylva = UIImageView(image: UIImage(systemName: "tray"))
        emptyIcon_sylva.tintColor = UIColor(hexstring_Sylva: "#B7E4C7")
        emptyIcon_sylva.contentMode = .scaleAspectFit
        emptyPostView_Sylva.addSubview(emptyIcon_sylva)
        emptyIcon_sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(36)
        }

        // 空状态标题（由 refreshPosts 动态更新 tag=200）
        let emptyTitle_sylva = UILabel()
        emptyTitle_sylva.tag = 200
        emptyTitle_sylva.text = "No posts yet"
        emptyTitle_sylva.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        emptyTitle_sylva.textColor = UIColor(hexstring_Sylva: "#2D6A4F")
        emptyTitle_sylva.textAlignment = .center
        emptyPostView_Sylva.addSubview(emptyTitle_sylva)
        emptyTitle_sylva.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_sylva.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 空状态副标题
        let emptySubTitle_sylva = UILabel()
        emptySubTitle_sylva.text = "Share your first green story!"
        emptySubTitle_sylva.font = UIFont.systemFont(ofSize: 12)
        emptySubTitle_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        emptySubTitle_sylva.textAlignment = .center
        emptyPostView_Sylva.addSubview(emptySubTitle_sylva)
        emptySubTitle_sylva.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle_sylva.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 数据刷新

    private func refreshAll_Sylva() {
        // 不做登录判断，直接展示当前用户数据（无数据则显示空）
        let user_sylva = meModel_Sylva ?? UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
        nameLabel_Sylva.text = user_sylva.userName_Sylva ?? "Tree Planter"
        introduceLabel_Sylva.text = user_sylva.userIntroduce_Sylva ?? "Plant a tree, grow a future. 🌱"

        let counts_sylva = [
            user_sylva.userFollow_Sylva.count,
            user_sylva.userLike_Sylva.count,
            user_sylva.userPosts_Sylva.count
        ]
        if let stack_sylva = statsRow_Sylva.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            for (i_sylva, sub_sylva) in stack_sylva.arrangedSubviews.enumerated() {
                if let label_sylva = sub_sylva.viewWithTag(100 + i_sylva) as? UILabel {
                    label_sylva.text = "\(counts_sylva[i_sylva])"
                }
            }
        }
        refreshPosts_Sylva()
    }

    private func refreshPosts_Sylva() {
        let user_sylva = meModel_Sylva ?? UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
        displayPosts_Sylva = selectedSegment_Sylva == 0 ? user_sylva.userPosts_Sylva : user_sylva.userLike_Sylva

        let isEmpty_sylva = displayPosts_Sylva.isEmpty

        // 切换列表与空状态视图的显示
        postListView_Sylva.isHidden   = isEmpty_sylva
        emptyPostView_Sylva.isHidden  = !isEmpty_sylva

        // 动态更新空状态标题文案（Posts / Liked 不同文案）
        if isEmpty_sylva {
            let titleText_sylva = selectedSegment_Sylva == 0
                ? "No posts yet"
                : "No liked posts yet"
            (emptyPostView_Sylva.viewWithTag(200) as? UILabel)?.text = titleText_sylva
        }

        postListView_Sylva.reloadData()
        let h_sylva = isEmpty_sylva ? 0 : CGFloat(displayPosts_Sylva.count) * 120
        postListView_Sylva.snp.updateConstraints { make in make.height.equalTo(h_sylva) }
    }

    private func showLoginPrompt_Sylva() {
        contentView_Sylva.subviews.forEach { if $0.tag == 999 { $0.removeFromSuperview() } }
        let card_sylva = UIView()
        card_sylva.tag = 999
        card_sylva.backgroundColor = .white
        card_sylva.layer.cornerRadius = 20
        card_sylva.layer.shadowOpacity = 0.08
        card_sylva.layer.shadowRadius = 10
        contentView_Sylva.addSubview(card_sylva)
        card_sylva.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(180)
            make.bottom.equalToSuperview().offset(-40)
        }
        let icon_sylva = UIImageView(image: UIImage(systemName: "person.crop.circle.badge.questionmark"))
        icon_sylva.tintColor = UIColor(hexstring_Sylva: "#52B788")
        icon_sylva.contentMode = .scaleAspectFit
        card_sylva.addSubview(icon_sylva)
        icon_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }
        let title_sylva = UILabel()
        title_sylva.text = "Sign in to view your profile"
        title_sylva.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        title_sylva.textColor = ColorConfig_Sylva.textPrimary_Sylva
        title_sylva.textAlignment = .center
        card_sylva.addSubview(title_sylva)
        title_sylva.snp.makeConstraints { make in
            make.top.equalTo(icon_sylva.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        let btn_sylva = UIButton(type: .system)
        btn_sylva.setTitle("Sign In", for: .normal)
        btn_sylva.setTitleColor(.white, for: .normal)
        btn_sylva.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
        btn_sylva.layer.cornerRadius = 16
        btn_sylva.addTarget(self, action: #selector(loginPromptTapped_Sylva), for: .touchUpInside)
        card_sylva.addSubview(btn_sylva)
        btn_sylva.snp.makeConstraints { make in
            make.top.equalTo(title_sylva.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(40)
        }
    }

    // MARK: - 通知

    private func observeNotifications_Sylva() {
        NotificationCenter.default.addObserver(self, selector: #selector(onUserStateChanged_Sylva),
            name: UserViewModel_Sylva.userStateDidChangeNotification_Sylva, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTitleStateChanged_Sylva),
            name: TitleViewModel_Sylva.titleStateDidChangeNotification_Sylva, object: nil)
    }

    @objc private func onUserStateChanged_Sylva()  { refreshAll_Sylva() }
    @objc private func onTitleStateChanged_Sylva()  { refreshPosts_Sylva() }

    // MARK: - 事件

    @objc private func settingTapped_Sylva()      { Navigation_Sylva.toSetting_Sylva() }
    @objc private func editProfileTapped_Sylva()  { Navigation_Sylva.toEditInfo_Sylva() }
    @objc private func loginPromptTapped_Sylva()  { Navigation_Sylva.toLogin_Sylva() }

    @objc private func postsTabTapped_Sylva() {
        guard selectedSegment_Sylva != 0 else { return }
        selectedSegment_Sylva = 0
        UIView.animate(withDuration: 0.28, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.3, options: [.curveEaseOut]) {
            self.tabIndicator_Sylva.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
                make.leading.equalToSuperview().offset(4)
                make.width.equalToSuperview().dividedBy(2).offset(-6)
            }
            self.tabContainer_Sylva.layoutIfNeeded()
        }
        postsTabBtn_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#1B4332"), for: .normal)
        postsTabBtn_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        likedTabBtn_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#40916C"), for: .normal)
        likedTabBtn_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        refreshPosts_Sylva()
    }

    @objc private func likedTabTapped_Sylva() {
        guard selectedSegment_Sylva != 1 else { return }
        selectedSegment_Sylva = 1
        UIView.animate(withDuration: 0.28, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.3, options: [.curveEaseOut]) {
            self.tabIndicator_Sylva.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
                make.trailing.equalToSuperview().offset(-4)
                make.width.equalToSuperview().dividedBy(2).offset(-6)
            }
            self.tabContainer_Sylva.layoutIfNeeded()
        }
        likedTabBtn_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#1B4332"), for: .normal)
        likedTabBtn_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        postsTabBtn_Sylva.setTitleColor(UIColor(hexstring_Sylva: "#40916C"), for: .normal)
        postsTabBtn_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        refreshPosts_Sylva()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension Me_Sylva: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayPosts_Sylva.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_sylva = tableView.dequeueReusableCell(
            withIdentifier: MePostCell_Sylva.reuseId_Sylva, for: indexPath
        ) as? MePostCell_Sylva else { return UITableViewCell() }
        cell_sylva.configure_Sylva(post_sylva: displayPosts_Sylva[indexPath.row], viewController_sylva: self) { [weak self] in
            self?.refreshPosts_Sylva()
        }
        return cell_sylva
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 112 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Sylva.toTitleDetail_Sylva(titleModel_sylva: displayPosts_Sylva[indexPath.row])
    }
}

// MARK: - 我的帖子 Cell（强化版）

/// 我的帖子列表单元格
/// 功能：白卡 + 绿色左竖条 + 媒体缩略图 + 标题/摘要 + 操作按钮
class MePostCell_Sylva: UITableViewCell {

    static let reuseId_Sylva = "MePostCell_Sylva"

    private let cardView_Sylva     = UIView()
    private let accentBar_Sylva    = UIView()
    private let mediaView_Sylva    = MediaDisplayView_Sylva()
    private let titleLabel_Sylva   = UILabel()
    private let contentLabel_Sylva = UILabel()
    private let actionButton_Sylva = UIButton(type: .system)
    private let likesLabel_Sylva   = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI_Sylva()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Sylva() {
        cardView_Sylva.backgroundColor    = .white
        cardView_Sylva.layer.cornerRadius = 16
        cardView_Sylva.layer.shadowColor  = UIColor.black.cgColor
        cardView_Sylva.layer.shadowOpacity = 0.05
        cardView_Sylva.layer.shadowRadius  = 8
        cardView_Sylva.layer.shadowOffset  = CGSize(width: 0, height: 2)
        contentView.addSubview(cardView_Sylva)
        cardView_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 绿色左竖条
        accentBar_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
        accentBar_Sylva.layer.cornerRadius = 3
        cardView_Sylva.addSubview(accentBar_Sylva)

        // 媒体缩略图
        mediaView_Sylva.layer.cornerRadius = 12
        mediaView_Sylva.clipsToBounds = true
        cardView_Sylva.addSubview(mediaView_Sylva)

        // 标题
        titleLabel_Sylva.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        titleLabel_Sylva.numberOfLines = 1
        cardView_Sylva.addSubview(titleLabel_Sylva)

        // 摘要
        contentLabel_Sylva.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        contentLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        contentLabel_Sylva.numberOfLines = 2
        cardView_Sylva.addSubview(contentLabel_Sylva)

        // 点赞数
        likesLabel_Sylva.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        likesLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#52B788")
        cardView_Sylva.addSubview(likesLabel_Sylva)

        // 操作按钮
        let iconConfig_sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        actionButton_Sylva.setImage(UIImage(systemName: "ellipsis", withConfiguration: iconConfig_sylva), for: .normal)
        actionButton_Sylva.tintColor = ColorConfig_Sylva.textSecondary_Sylva
        cardView_Sylva.addSubview(actionButton_Sylva)

        // 统一约束
        accentBar_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalToSuperview().multipliedBy(0.55)
        }
        mediaView_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(72)
        }
        actionButton_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
        titleLabel_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(mediaView_Sylva.snp.trailing).offset(12)
            make.trailing.equalTo(actionButton_Sylva.snp.leading).offset(-4)
        }
        contentLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Sylva.snp.bottom).offset(5)
            make.leading.trailing.equalTo(titleLabel_Sylva)
        }
        likesLabel_Sylva.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.leading.equalTo(titleLabel_Sylva)
        }
    }

    func configure_Sylva(post_sylva: TitleModel_Sylva, viewController_sylva: UIViewController, completion_sylva: (() -> Void)? = nil) {
        if let media_sylva = post_sylva.titleMeidas_Sylva.first {
            mediaView_Sylva.configure_Sylva(mediaPath_Sylva: media_sylva)
        }
        titleLabel_Sylva.text   = post_sylva.title_Sylva
        contentLabel_Sylva.text = post_sylva.titleContent_Sylva
        likesLabel_Sylva.text   = post_sylva.likes_Sylva > 0 ? "♥ \(post_sylva.likes_Sylva)" : ""

        let isMyPost_sylva = UserViewModel_Sylva.shared_Sylva.isCurrentUser_Sylva(userId_sylva: post_sylva.titleUserId_Sylva)
        let iconName_sylva = isMyPost_sylva ? "trash" : "ellipsis"
        let iconConfig_sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        actionButton_Sylva.setImage(UIImage(systemName: iconName_sylva, withConfiguration: iconConfig_sylva), for: .normal)
        actionButton_Sylva.tintColor = isMyPost_sylva ? UIColor.systemRed.withAlphaComponent(0.8) : ColorConfig_Sylva.textSecondary_Sylva
        accentBar_Sylva.backgroundColor = isMyPost_sylva
            ? UIColor(hexstring_Sylva: "#40916C")
            : UIColor(hexstring_Sylva: "#74C69D")

        actionButton_Sylva.removeTarget(nil, action: nil, for: .allEvents)
        actionButton_Sylva.addAction(UIAction { [weak viewController_sylva] _ in
            guard let vc_sylva = viewController_sylva else { return }
            if isMyPost_sylva {
                ReportDeleteHelper_Sylva.delete_Sylva(post_Sylva: post_sylva, from: vc_sylva, completion_Sylva: completion_sylva)
            } else {
                ReportDeleteHelper_Sylva.report_Sylva(post_Sylva: post_sylva, from: vc_sylva, completion_Sylva: completion_sylva)
            }
        }, for: .touchUpInside)
    }
}
