import UIKit
import SnapKit

// MARK: 我的页面

/// 我的页面
/// 功能：展示当前登录用户信息，支持 Posts/Likes 两个 Tab 切换展示帖子列表
/// 设计：深紫渐变顶部卡片（含头像/统计数据）+ 自定义分段选择器 + 帖子二列网格
class Me_Ornit: UIViewController {

    // MARK: - 公共属性

    /// 指定展示的登录用户模型（nil 则使用当前登录用户）
    var meModel_Ornit: LoginUserModel_Ornit?

    // MARK: - 私有数据属性

    /// 当前展示的用户
    private var currentUser_Ornit: LoginUserModel_Ornit {
        return meModel_Ornit ?? UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit()
    }

    /// 当前 tab 索引（0=Posts, 1=Likes）
    private var selectedTabIndex_Ornit: Int = 0

    /// 当前展示的帖子列表
    private var displayPosts_Ornit: [TitleModel_Ornit] {
        if selectedTabIndex_Ornit == 0 {
            return TitleViewModel_Ornit.shared_Ornit.getUserPosts_Ornit(user_ornit: makePrewUser_Ornit())
        } else {
            return currentUser_Ornit.userLike_Ornit
        }
    }

    // MARK: - 容器组件

    private let scrollView_Ornit = UIScrollView()
    private let contentView_Ornit = UIView()

    // MARK: - Header 卡片组件

    /// 顶部渐变 Header 卡片
    private let headerCard_Ornit = UIView()

    /// Header 渐变图层
    private var headerGradient_Ornit: CAGradientLayer?

    /// 用户头像（带白色边框环）
    private lazy var avatarView_Ornit: UserAvatarView_Ornit = {
        let av_ornit = UserAvatarView_Ornit()
        av_ornit.layer.borderWidth = 4
        av_ornit.layer.borderColor = UIColor.white.cgColor
        av_ornit.isUserInteractionEnabled = true
        return av_ornit
    }()

    /// 用户名标签
    private let nameLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label_ornit.textColor = .white
        return label_ornit
    }()

    /// 用户简介标签
    private let bioLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_ornit.textColor = UIColor.white.withValues(alpha: 0.82)
        label_ornit.numberOfLines = 2
        label_ornit.textAlignment = .center
        return label_ornit
    }()

    /// 数据统计行（Posts / Following / Likes）
    private let statsRow_Ornit = UIStackView()

    /// 编辑资料按钮（白色背景 + 紫色文字）
    private let editButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .system)
        btn_ornit.setTitle("Edit Profile", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit
        btn_ornit.backgroundColor = .white
        btn_ornit.layer.cornerRadius = 17
        return btn_ornit
    }()

    /// VIP 入口按钮（vip_btn 原图，与 editButton 左对齐，高度一致）
    private let vipButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        if let img_ornit = UIImage(named: "vip_btn") {
            btn_ornit.setImage(img_ornit.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        btn_ornit.imageView?.contentMode = .scaleAspectFit
        btn_ornit.contentHorizontalAlignment = .fill
        btn_ornit.contentVerticalAlignment = .fill
        return btn_ornit
    }()

    /// 设置入口按钮（右上角齿轮，半透明圆形背景）
    private let settingButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .system)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_ornit.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config_ornit), for: .normal)
        btn_ornit.tintColor = .white
        btn_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.2)
        btn_ornit.layer.cornerRadius = 18
        return btn_ornit
    }()

    // MARK: - 分段选择器组件

    /// 自定义 Tab 选择背景条
    private let segmentBar_Ornit = UIView()

    /// "Posts" Tab 按钮
    private let postsTabButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.setTitle("Posts", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_ornit.setTitleColor(ColorConfig_Ornit.meAccent_Ornit, for: .normal)
        btn_ornit.tag = 0
        return btn_ornit
    }()

    /// "Likes" Tab 按钮
    private let likesTabButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.setTitle("Likes", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        btn_ornit.setTitleColor(ColorConfig_Ornit.textSecondary_Ornit, for: .normal)
        btn_ornit.tag = 1
        return btn_ornit
    }()

    /// Tab 选中下划线指示器
    private let tabIndicator_Ornit = UIView()

    // MARK: - 帖子网格组件

    /// 帖子二列网格容器
    private let postsGrid_Ornit: UIStackView = {
        let sv_ornit = UIStackView()
        sv_ornit.axis = .vertical
        sv_ornit.spacing = 12
        return sv_ornit
    }()

    /// 无帖子时的空状态视图
    private let emptyView_Ornit = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundMe_Ornit
        setupScrollView_Ornit()
        setupHeaderCard_Ornit()
        setupSegmentSection_Ornit()
        setupNotifications_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshUI_Ornit()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerCard_Ornit.bounds
        avatarView_Ornit.layer.cornerRadius = avatarView_Ornit.bounds.width / 2
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知监听

    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Ornit),
            name: UserViewModel_Ornit.userStateDidChangeNotification_Ornit,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Ornit),
            name: TitleViewModel_Ornit.titleStateDidChangeNotification_Ornit,
            object: nil
        )
    }

    @objc private func handleStateChange_Ornit() {
        refreshUI_Ornit()
    }

    // MARK: - 数据刷新

    /// 刷新整个页面 UI（头像、用户名、简介、统计、帖子网格）
    private func refreshUI_Ornit() {
        let user_ornit = currentUser_Ornit

        if let uid_ornit = user_ornit.userId_Ornit {
            avatarView_Ornit.configure_Ornit(userId_Ornit: uid_ornit)
        }
        nameLabel_Ornit.text = user_ornit.userName_Ornit ?? "Guest"
        bioLabel_Ornit.text = user_ornit.userIntroduce_Ornit ?? "Passionate birdwatcher 🐦"

        refreshStats_Ornit(user_ornit: user_ornit)
        refreshPostsGrid_Ornit()

        // 两个按钮均始终可见
        settingButton_Ornit.isHidden = false
        editButton_Ornit.isHidden = false
        vipButton_Ornit.isHidden = false
    }

    /// 刷新统计数据行（Posts / Following / Likes）
    private func refreshStats_Ornit(user_ornit: LoginUserModel_Ornit) {
        statsRow_Ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let postsCount_ornit = TitleViewModel_Ornit.shared_Ornit.getUserPosts_Ornit(
            user_ornit: makePrewUser_Ornit()
        ).count
        let followCount_ornit = user_ornit.userFollow_Ornit.count
        let likesCount_ornit = user_ornit.userLike_Ornit.count

        let items_ornit: [(String, Int)] = [
            ("Posts", postsCount_ornit),
            ("Following", followCount_ornit),
            ("Likes", likesCount_ornit)
        ]

        for (i_ornit, (title_ornit, count_ornit)) in items_ornit.enumerated() {
            statsRow_Ornit.addArrangedSubview(
                createStatItem_Ornit(title_ornit: title_ornit, count_ornit: count_ornit)
            )
            if i_ornit < items_ornit.count - 1 {
                let divider_ornit = UIView()
                divider_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.3)
                divider_ornit.snp.makeConstraints { make_ornit in
                    make_ornit.width.equalTo(1)
                }
                statsRow_Ornit.addArrangedSubview(divider_ornit)
            }
        }
    }

    /// 刷新帖子网格（两列布局，奇数补空位）
    private func refreshPostsGrid_Ornit() {
        postsGrid_Ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let posts_ornit = displayPosts_Ornit

        if posts_ornit.isEmpty {
            emptyView_Ornit.isHidden = false
            // 更新空状态文字
            if let label_ornit = emptyView_Ornit.subviews.compactMap({ $0 as? UILabel }).first {
                label_ornit.text = selectedTabIndex_Ornit == 0 ? "No posts yet" : "No liked posts yet"
            }
        } else {
            emptyView_Ornit.isHidden = true
            var rowIndex_ornit = 0
            while rowIndex_ornit < posts_ornit.count {
                let rowStack_ornit = UIStackView()
                rowStack_ornit.axis = .horizontal
                rowStack_ornit.spacing = 12
                rowStack_ornit.distribution = .fillEqually

                rowStack_ornit.addArrangedSubview(createPostCard_Ornit(post_ornit: posts_ornit[rowIndex_ornit]))

                if rowIndex_ornit + 1 < posts_ornit.count {
                    rowStack_ornit.addArrangedSubview(createPostCard_Ornit(post_ornit: posts_ornit[rowIndex_ornit + 1]))
                } else {
                    rowStack_ornit.addArrangedSubview(UIView())
                }

                postsGrid_Ornit.addArrangedSubview(rowStack_ornit)
                rowStack_ornit.snp.makeConstraints { make_ornit in
                    make_ornit.height.equalTo(170)
                }

                rowIndex_ornit += 2
            }
        }
    }

    // MARK: - UI 搭建

    /// 构建全页滚动容器，底部留出 Tab Bar 高度
    private func setupScrollView_Ornit() {
        scrollView_Ornit.showsVerticalScrollIndicator = false
        scrollView_Ornit.contentInsetAdjustmentBehavior = .never
        scrollView_Ornit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(contentView_Ornit)

        scrollView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }
        contentView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.width.equalToSuperview()
        }
    }

    /// 构建顶部渐变 Header 卡片（深紫渐变 + 头像 + 用户信息 + 统计数据 + 操作按钮）
    private func setupHeaderCard_Ornit() {
        contentView_Ornit.addSubview(headerCard_Ornit)

        // 深紫罗兰 → 鲜亮紫渐变
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerCard_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit

        headerCard_Ornit.layer.cornerRadius = 28
        headerCard_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerCard_Ornit.clipsToBounds = true

        // 右上角大装饰圆
        let deco1_ornit = UIView()
        deco1_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        deco1_ornit.layer.cornerRadius = 80
        headerCard_Ornit.addSubview(deco1_ornit)

        // 左下角装饰圆
        let deco2_ornit = UIView()
        deco2_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        deco2_ornit.layer.cornerRadius = 50
        headerCard_Ornit.addSubview(deco2_ornit)

        // 中下方装饰圆
        let deco3_ornit = UIView()
        deco3_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.04)
        deco3_ornit.layer.cornerRadius = 60
        headerCard_Ornit.addSubview(deco3_ornit)

        headerCard_Ornit.addSubview(settingButton_Ornit)
        headerCard_Ornit.addSubview(avatarView_Ornit)
        headerCard_Ornit.addSubview(editButton_Ornit)
        headerCard_Ornit.addSubview(vipButton_Ornit)
        headerCard_Ornit.addSubview(nameLabel_Ornit)
        headerCard_Ornit.addSubview(bioLabel_Ornit)

        // 统计数据横排
        statsRow_Ornit.axis = .horizontal
        statsRow_Ornit.alignment = .center
        statsRow_Ornit.spacing = 20
        statsRow_Ornit.distribution = .equalSpacing
        headerCard_Ornit.addSubview(statsRow_Ornit)

        // 统计行容器（带分割线的白色半透明背景条）
        let statsBg_ornit = UIView()
        statsBg_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.14)
        statsBg_ornit.layer.cornerRadius = 16
        headerCard_Ornit.insertSubview(statsBg_ornit, belowSubview: statsRow_Ornit)

        headerCard_Ornit.addSubview(editButton_Ornit)

        headerCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            // vipButton 额外增加 34+5=39pt，header 高度相应增至 340
            make_ornit.height.equalTo(340)
        }

        deco1_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(60)
            make_ornit.top.equalToSuperview().offset(-40)
            make_ornit.width.height.equalTo(160)
        }

        deco2_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-24)
            make_ornit.bottom.equalToSuperview().offset(30)
            make_ornit.width.height.equalTo(100)
        }

        deco3_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-80)
            make_ornit.bottom.equalToSuperview().offset(40)
            make_ornit.width.height.equalTo(120)
        }

        // Edit Profile 和齿轮设置按钮同行：左侧 editButton，右侧 settingButton
        editButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.equalTo(110)
            make_ornit.height.equalTo(34)
        }

        settingButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.centerY.equalTo(editButton_Ornit)
            make_ornit.width.height.equalTo(36)
        }

        // VIP 按钮：与 editButton 左对齐，间距 5pt，高度相同
        vipButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.top.equalTo(editButton_Ornit.snp.bottom).offset(5)
            make_ornit.width.equalTo(editButton_Ornit)
            make_ornit.height.equalTo(34)
        }

        avatarView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            // avatarView 跟随 vipButton 下方
            make_ornit.top.equalTo(vipButton_Ornit.snp.bottom).offset(10)
            make_ornit.width.height.equalTo(96)
        }

        nameLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalTo(avatarView_Ornit.snp.bottom).offset(12)
        }

        bioLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalTo(nameLabel_Ornit.snp.bottom).offset(5)
            make_ornit.leading.equalToSuperview().offset(36)
            make_ornit.trailing.equalToSuperview().offset(-36)
        }

        statsBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalTo(bioLabel_Ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.trailing.equalToSuperview().offset(-24)
            make_ornit.height.equalTo(58)
            make_ornit.bottom.equalToSuperview().offset(-16)
        }

        statsRow_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalTo(statsBg_ornit)
            make_ornit.leading.equalTo(statsBg_ornit).offset(20)
            make_ornit.trailing.equalTo(statsBg_ornit).offset(-20)
        }

        let avatarTap_ornit = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Ornit))
        avatarView_Ornit.addGestureRecognizer(avatarTap_ornit)

        settingButton_Ornit.addTarget(self, action: #selector(settingTapped_Ornit), for: .touchUpInside)
        editButton_Ornit.addTarget(self, action: #selector(editProfileTapped_Ornit), for: .touchUpInside)
        vipButton_Ornit.addTarget(self, action: #selector(vipButtonTapped_Ornit), for: .touchUpInside)
    }

    /// 构建自定义分段选择器 + 帖子网格区域
    private func setupSegmentSection_Ornit() {
        // 分段选择容器（白色背景条）
        segmentBar_Ornit.backgroundColor = .white
        segmentBar_Ornit.layer.shadowColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.08).cgColor
        segmentBar_Ornit.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentBar_Ornit.layer.shadowOpacity = 1
        segmentBar_Ornit.layer.shadowRadius = 6
        contentView_Ornit.addSubview(segmentBar_Ornit)

        segmentBar_Ornit.addSubview(postsTabButton_Ornit)
        segmentBar_Ornit.addSubview(likesTabButton_Ornit)

        // 下划线指示器（紫色）
        tabIndicator_Ornit.backgroundColor = ColorConfig_Ornit.meAccent_Ornit
        tabIndicator_Ornit.layer.cornerRadius = 1.5
        segmentBar_Ornit.addSubview(tabIndicator_Ornit)

        contentView_Ornit.addSubview(postsGrid_Ornit)

        // 空状态视图
        setupEmptyView_Ornit()
        contentView_Ornit.addSubview(emptyView_Ornit)

        segmentBar_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(headerCard_Ornit.snp.bottom).offset(0)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(48)
        }

        postsTabButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview()
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.equalToSuperview().multipliedBy(0.5)
            make_ornit.height.equalToSuperview()
        }

        likesTabButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview()
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.equalToSuperview().multipliedBy(0.5)
            make_ornit.height.equalToSuperview()
        }

        tabIndicator_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.bottom.equalToSuperview()
            make_ornit.leading.equalToSuperview()
            make_ornit.width.equalToSuperview().multipliedBy(0.5)
            make_ornit.height.equalTo(3)
        }

        postsGrid_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(segmentBar_Ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-20)
        }

        emptyView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(segmentBar_Ornit.snp.bottom).offset(60)
            make_ornit.centerX.equalToSuperview()
            make_ornit.width.equalTo(200)
        }

        postsTabButton_Ornit.addTarget(self, action: #selector(tabButtonTapped_Ornit(_:)), for: .touchUpInside)
        likesTabButton_Ornit.addTarget(self, action: #selector(tabButtonTapped_Ornit(_:)), for: .touchUpInside)
    }

    /// 构建空状态视图（图标 + 文字）
    private func setupEmptyView_Ornit() {
        emptyView_Ornit.isHidden = true

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 44, weight: .thin)
        let icon_ornit = UIImageView(
            image: UIImage(systemName: "tray", withConfiguration: iconConfig_ornit)
        )
        icon_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.3)
        icon_ornit.contentMode = .scaleAspectFit
        emptyView_Ornit.addSubview(icon_ornit)

        let label_ornit = UILabel()
        label_ornit.text = "No posts yet"
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .center
        emptyView_Ornit.addSubview(label_ornit)

        icon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.centerX.equalToSuperview()
            make_ornit.width.height.equalTo(56)
        }

        label_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(icon_ornit.snp.bottom).offset(12)
            make_ornit.centerX.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }
    }

    // MARK: - 辅助方法

    /// 创建单个统计项（数字 + 标题，上下排列，白色）
    /// - Parameters:
    ///   - title_ornit: 统计项名称
    ///   - count_ornit: 统计数量
    /// - Returns: 配置完成的 UIView
    private func createStatItem_Ornit(title_ornit: String, count_ornit: Int) -> UIView {
        let container_ornit = UIView()

        let countLabel_ornit = UILabel()
        countLabel_ornit.text = "\(count_ornit)"
        countLabel_ornit.font = UIFont.systemFont(ofSize: 20, weight: .black)
        countLabel_ornit.textColor = .white
        countLabel_ornit.textAlignment = .center
        container_ornit.addSubview(countLabel_ornit)

        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = title_ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.78)
        titleLabel_ornit.textAlignment = .center
        container_ornit.addSubview(titleLabel_ornit)

        countLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.centerX.equalToSuperview()
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(countLabel_ornit.snp.bottom).offset(2)
            make_ornit.centerX.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }

        return container_ornit
    }

    /// 创建帖子网格卡片（顶部紫色装饰条 + 标题 + 内容 + 底部点赞数）
    /// - Parameter post_ornit: 帖子模型
    /// - Returns: 可点击的帖子卡片 UIView
    private func createPostCard_Ornit(post_ornit: TitleModel_Ornit) -> UIView {
        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 16
        card_ornit.layer.shadowColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.12).cgColor
        card_ornit.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_ornit.layer.shadowOpacity = 1
        card_ornit.layer.shadowRadius = 8
        card_ornit.isUserInteractionEnabled = true
        card_ornit.tag = post_ornit.titleId_Ornit

        // 顶部紫色装饰条
        let topBar_ornit = UIView()
        topBar_ornit.backgroundColor = ColorConfig_Ornit.meGradientEnd_Ornit.withValues(alpha: 0.12)
        topBar_ornit.layer.cornerRadius = 16
        topBar_ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card_ornit.addSubview(topBar_ornit)

        // 装饰图标（顶部条内）
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .light)
        let cardIcon_ornit = UIImageView(
            image: UIImage(systemName: "bird", withConfiguration: iconConfig_ornit)
        )
        cardIcon_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.4)
        topBar_ornit.addSubview(cardIcon_ornit)

        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = post_ornit.title_Ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        titleLabel_ornit.numberOfLines = 2
        card_ornit.addSubview(titleLabel_ornit)

        let contentLabel_ornit = UILabel()
        contentLabel_ornit.text = post_ornit.titleContent_Ornit
        contentLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        contentLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        contentLabel_ornit.numberOfLines = 3
        card_ornit.addSubview(contentLabel_ornit)

        let likeLabel_ornit = UILabel()
        likeLabel_ornit.text = "♥ \(post_ornit.likes_Ornit)"
        likeLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        likeLabel_ornit.textColor = UIColor(hexstring_Ornit: "#EC4899")
        card_ornit.addSubview(likeLabel_ornit)

        let reportBtn_ornit = ReportDeleteHelper_Ornit.createPostReportButton_Ornit(
            post_Ornit: post_ornit,
            size_Ornit: 12,
            color_Ornit: ColorConfig_Ornit.textSecondary_Ornit,
            from: self,
            completion_Ornit: { [weak self] in
                self?.refreshPostsGrid_Ornit()
            }
        )
        card_ornit.addSubview(reportBtn_ornit)

        topBar_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(44)
        }

        cardIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-10)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(20)
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(topBar_ornit.snp.bottom).offset(8)
            make_ornit.leading.equalToSuperview().offset(10)
            make_ornit.trailing.equalToSuperview().offset(-28)
        }

        contentLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(4)
            make_ornit.leading.equalToSuperview().offset(10)
            make_ornit.trailing.equalToSuperview().offset(-10)
        }

        likeLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(10)
            make_ornit.bottom.equalToSuperview().offset(-10)
        }

        reportBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-6)
            make_ornit.top.equalTo(topBar_ornit.snp.bottom).offset(6)
            make_ornit.width.height.equalTo(20)
        }

        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(postCardTapped_Ornit(_:)))
        card_ornit.addGestureRecognizer(tap_ornit)

        return card_ornit
    }

    /// 从当前用户构建 PrewUserModel（供查询帖子使用）
    private func makePrewUser_Ornit() -> PrewUserModel_Ornit {
        let user_ornit = currentUser_Ornit
        let prewUser_ornit = PrewUserModel_Ornit()
        prewUser_ornit.userId_Ornit = user_ornit.userId_Ornit
        prewUser_ornit.userName_Ornit = user_ornit.userName_Ornit
        prewUser_ornit.userHead_Ornit = user_ornit.userHead_Ornit
        return prewUser_ornit
    }

    // MARK: - 事件处理

    /// Tab 按钮点击，切换 Posts/Likes 并移动下划线指示器
    @objc private func tabButtonTapped_Ornit(_ sender: UIButton) {
        selectedTabIndex_Ornit = sender.tag
        let isLeft_ornit = sender.tag == 0

        // 更新按钮字重与颜色
        postsTabButton_Ornit.titleLabel?.font = UIFont.systemFont(
            ofSize: 14, weight: isLeft_ornit ? .bold : .regular
        )
        likesTabButton_Ornit.titleLabel?.font = UIFont.systemFont(
            ofSize: 14, weight: isLeft_ornit ? .regular : .bold
        )
        postsTabButton_Ornit.setTitleColor(
            isLeft_ornit ? ColorConfig_Ornit.meAccent_Ornit : ColorConfig_Ornit.textSecondary_Ornit,
            for: .normal
        )
        likesTabButton_Ornit.setTitleColor(
            isLeft_ornit ? ColorConfig_Ornit.textSecondary_Ornit : ColorConfig_Ornit.meAccent_Ornit,
            for: .normal
        )

        // 下划线动画滑动
        let offset_ornit: CGFloat = isLeft_ornit ? 0 : segmentBar_Ornit.bounds.width / 2
        UIView.animate(withDuration: 0.22) {
            self.tabIndicator_Ornit.snp.updateConstraints { make_ornit in
                make_ornit.leading.equalToSuperview().offset(offset_ornit)
            }
            self.segmentBar_Ornit.layoutIfNeeded()
        }

        refreshPostsGrid_Ornit()
    }

    @objc private func avatarTapped_Ornit() {
        if UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit {
            Navigation_Ornit.toEditInfo_Ornit()
        } else {
            Navigation_Ornit.toLogin_Ornit()
        }
    }

    @objc private func editProfileTapped_Ornit() {
        Navigation_Ornit.toEditInfo_Ornit()
    }

    @objc private func settingTapped_Ornit() {
        Navigation_Ornit.toSetting_Ornit()
    }

    /// VIP 按钮点击，跳转 VIP 订阅页面
    @objc private func vipButtonTapped_Ornit() {
        let vipVC_ornit = VIPSubscription_Ornit()
        Navigation_Ornit.push_Ornit(to: vipVC_ornit)
    }

    @objc private func postCardTapped_Ornit(_ gesture: UITapGestureRecognizer) {
        guard let cardView_ornit = gesture.view else { return }
        let posts_ornit = displayPosts_Ornit
        if let post_ornit = posts_ornit.first(where: { $0.titleId_Ornit == cardView_ornit.tag }) {
            Navigation_Ornit.toTitleDetail_Ornit(titleModel_ornit: post_ornit)
        }
    }
}
