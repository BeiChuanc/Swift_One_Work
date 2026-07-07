import UIKit
import SnapKit

// MARK: - 我的页面（重构版）

/// 我的页面视图控制器（重构版）
/// 核心作用：展示当前用户的个人信息、发布帖子和喜欢帖子列表
/// 设计思路：
///   - 头部区域使用多层径向光晕背景 + 彩虹渐变头像光圈 + "Edit Profile" 入口按钮
///   - 统计区三列数据采用紫色数字高亮，列间渐变竖条分隔
///   - 自定义分段（Posts/Liked）带紫蓝渐变滑动指示条，替代系统 UISegmentedControl
///   - 帖子卡片带外投影增强层次感
/// 关键属性：meModel_Lens（外部注入的用户模型），displayPosts_Lens（当前展示的帖子列表）
class Me_Lens: UIViewController {

    // MARK: - 属性

    /// 外部可注入的用户模型，未设置时读取当前登录用户
    var meModel_Lens: LoginUserModel_Lens?

    /// 当前展示的帖子列表
    private var displayPosts_Lens: [TitleModel_Lens] = []

    /// 当前选中分段（0=Posts, 1=Liked）
    private var selectedSegment_Lens: Int = 0

    // MARK: - UI 组件：背景装饰

    /// 多层径向光晕背景装饰（不响应触摸）
    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：滚动内容

    private let scrollView_Lens = UIScrollView()
    private let contentView_Lens = UIView()

    // MARK: - UI 组件：头部区域

    private let headerView_Lens = UIView()

    /// 头像彩虹渐变光圈容器（94pt，clipsToBounds）
    private let avatarRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 47
        v.clipsToBounds = true
        return v
    }()

    /// 当前用户头像（可点击进入编辑页）
    private let avatarView_Lens = CurrentUserAvatarView_Lens()

    /// 用户昵称
    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        return l
    }()

    /// 用户自我介绍
    private let bioLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.7)
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 顶部自定义设置按钮（直接放在 header 内，不依赖 navigationItem）
    private let settingHeaderBtn_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        b.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12)
        b.layer.cornerRadius = 17
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.18).cgColor
        return b
    }()

    /// 编辑资料入口按钮（胶囊样式）
    private let editProfileBtn_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Edit Profile", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.22).cgColor
        b.contentEdgeInsets = UIEdgeInsets(top: 7, left: 22, bottom: 7, right: 22)
        return b
    }()

    // MARK: - UI 组件：统计区

    /// 统计 + 分段统一圆角卡片容器
    private let statsCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        v.clipsToBounds = true
        return v
    }()

    private let statsView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let followCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#C77DFF")
        l.font = .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        return l
    }()

    private let followTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Following"
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        l.font = .systemFont(ofSize: 12)
        l.textAlignment = .center
        return l
    }()

    private let likeCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#C77DFF")
        l.font = .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        return l
    }()

    private let likeTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Liked"
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        l.font = .systemFont(ofSize: 12)
        l.textAlignment = .center
        return l
    }()

    private let postCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hexstring_Lens: "#C77DFF")
        l.font = .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        return l
    }()

    private let postTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Posts"
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        l.font = .systemFont(ofSize: 12)
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件：自定义分段

    /// 分段容器
    private let segContainerView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// "Posts" 分段按钮
    private let postsTabBtn_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Posts", for: .normal)
        b.setTitleColor(.white, for: .selected)
        b.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.tag = 0
        b.isSelected = true
        return b
    }()

    /// "Liked" 分段按钮
    private let likedTabBtn_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Liked", for: .normal)
        b.setTitleColor(.white, for: .selected)
        b.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.tag = 1
        return b
    }()

    /// 渐变滑动指示条（胶囊形）
    private let segIndicatorView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    // MARK: - UI 组件：内容区

    private lazy var collectionView_Lens: UICollectionView = {
        let layout_Lens = UICollectionViewFlowLayout()
        let spacing_Lens: CGFloat = 10
        let itemWidth_Lens = (UIScreen.main.bounds.width - 16 * 2 - spacing_Lens) / 2
        layout_Lens.itemSize = CGSize(width: itemWidth_Lens, height: itemWidth_Lens * 1.35)
        layout_Lens.minimumInteritemSpacing = spacing_Lens
        layout_Lens.minimumLineSpacing = spacing_Lens
        layout_Lens.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        let cv_Lens = UICollectionView(frame: .zero, collectionViewLayout: layout_Lens)
        cv_Lens.backgroundColor = .clear
        cv_Lens.isScrollEnabled = false
        cv_Lens.dataSource = self
        cv_Lens.delegate = self
        cv_Lens.register(MePostCell_Lens.self, forCellWithReuseIdentifier: MePostCell_Lens.reuseId_Lens)
        return cv_Lens
    }()

    private let emptyPostsView_Lens: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData_Lens()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Lens()
        setupNavigation_Lens()
        setupScrollContent_Lens()
        observeNotifications_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步头像光圈渐变层
        if let ringLayer_Lens = avatarRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = avatarRingView_Lens.bounds
        }
        // 同步分段指示条渐变层
        if let indicatorLayer_Lens = segIndicatorView_Lens.layer.sublayers?.first as? CAGradientLayer {
            indicatorLayer_Lens.frame = segIndicatorView_Lens.bounds
            indicatorLayer_Lens.cornerRadius = segIndicatorView_Lens.bounds.height / 2
        }
    }

    // MARK: - 布局搭建

    private func setupView_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")

        // 背景光晕装饰
        view.insertSubview(backgroundGlowView_Lens, at: 0)
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        setupBackgroundGlows_Lens()
    }

    /// 构建背景多层径向光晕
    private func setupBackgroundGlows_Lens() {
        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.35).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purple_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purple_Lens.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: -50, width: 300, height: 300)
        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)

        let blue_Lens = CAGradientLayer()
        blue_Lens.type = .radial
        blue_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.2).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blue_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blue_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        blue_Lens.frame = CGRect(x: -60, y: 50, width: 220, height: 220)
        backgroundGlowView_Lens.layer.addSublayer(blue_Lens)
    }

    /// Me 页作为 Tab 子页，navigationItem 不生效，此方法仅保留空实现
    private func setupNavigation_Lens() {
        // Me 页由 TabBar 直接承载，设置按钮通过 settingHeaderBtn_Lens 在 header 中实现
    }

    /// 搭建主滚动内容区
    private func setupScrollContent_Lens() {
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)
        scrollView_Lens.showsVerticalScrollIndicator = false
        scrollView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        setupHeaderSection_Lens()
        setupStatsSection_Lens()
        setupSegmentSection_Lens()
        setupCollectionSection_Lens()
    }

    /// 搭建头部：光晕背景 + 彩虹头像圆圈 + 昵称 + 简介 + 编辑按钮
    private func setupHeaderSection_Lens() {
        headerView_Lens.backgroundColor = .clear
        contentView_Lens.addSubview(headerView_Lens)
        // header 高度 = safeArea 补偿(64) + 头像(94) + 间距 + 文字 + 按钮 + 底部留白
        headerView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(310)
        }

        // 头部渐变背景（紫→蓝→深色，向下淡出至页面背景色）
        let headerGrad_Lens = CAGradientLayer()
        headerGrad_Lens.colors = [
            UIColor(hexstring_Lens: "#3D1870").cgColor,
            UIColor(hexstring_Lens: "#1A2E6A").cgColor,
            UIColor(hexstring_Lens: "#0D0D1A").cgColor
        ]
        headerGrad_Lens.locations = [0, 0.5, 1]
        headerGrad_Lens.startPoint = CGPoint(x: 0, y: 0)
        headerGrad_Lens.endPoint = CGPoint(x: 1, y: 1)
        headerGrad_Lens.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 310)
        headerView_Lens.layer.insertSublayer(headerGrad_Lens, at: 0)

        // 彩虹渐变光圈
        setupAvatarRingGradient_Lens()

        // 自定义设置按钮（顶部右侧，替代 navigationItem，使用 view.safeAreaLayoutGuide 定位）
        headerView_Lens.addSubview(settingHeaderBtn_Lens)
        settingHeaderBtn_Lens.addTarget(self, action: #selector(onSettingTap_Lens), for: .touchUpInside)
        settingHeaderBtn_Lens.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(34)
        }

        headerView_Lens.addSubview(avatarRingView_Lens)
        avatarRingView_Lens.addSubview(avatarView_Lens)
        headerView_Lens.addSubview(nameLabel_Lens)
        headerView_Lens.addSubview(bioLabel_Lens)
        headerView_Lens.addSubview(editProfileBtn_Lens)

        editProfileBtn_Lens.addTarget(self, action: #selector(onEditProfileTap_Lens), for: .touchUpInside)
        avatarView_Lens.onTapped_Lens = { [weak self] in
            self?.goEditInfo_Lens()
        }

        // 头像顶部偏移加大：弥补无导航栏时内容过于靠顶的问题
        // 实际屏幕位置 = content_y + adjustedContentInset.top(≈safeAreaInsets.top)
        // 64 + 59 = 123pt，相当于有导航栏时的合理位置
        avatarRingView_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(94)
        }
        avatarView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(3)
        }
        nameLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(avatarRingView_Lens.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        bioLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Lens.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        editProfileBtn_Lens.snp.makeConstraints {
            $0.top.equalTo(bioLabel_Lens.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }

    /// 构建头像彩虹渐变光圈（七色循环）
    private func setupAvatarRingGradient_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#FFB347").cgColor,
            UIColor(hexstring_Lens: "#FF6B6B").cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradient_Lens.cornerRadius = 47
        gradient_Lens.frame = CGRect(x: 0, y: 0, width: 94, height: 94)
        avatarRingView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
    }

    /// 搭建统计区（关注 / 喜欢 / 发布），紫色数字 + 渐变竖条分隔
    private func setupStatsSection_Lens() {
        contentView_Lens.addSubview(statsCardView_Lens)
        statsCardView_Lens.addSubview(statsView_Lens)
        statsCardView_Lens.snp.makeConstraints {
            $0.top.equalTo(headerView_Lens.snp.bottom).offset(-8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        statsView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(74)
        }

        let items_Lens: [(count: UILabel, title: UILabel)] = [
            (followCountLabel_Lens, followTitleLabel_Lens),
            (likeCountLabel_Lens, likeTitleLabel_Lens),
            (postCountLabel_Lens, postTitleLabel_Lens)
        ]

        var prevStack_Lens: UIStackView?
        for (idx_Lens, item_Lens) in items_Lens.enumerated() {
            let stack_Lens = UIStackView(arrangedSubviews: [item_Lens.count, item_Lens.title])
            stack_Lens.axis = .vertical
            stack_Lens.alignment = .center
            stack_Lens.spacing = 3
            statsView_Lens.addSubview(stack_Lens)
            stack_Lens.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.width.equalToSuperview().dividedBy(3)
                if let prev_Lens = prevStack_Lens {
                    $0.leading.equalTo(prev_Lens.snp.trailing)
                } else {
                    $0.leading.equalToSuperview()
                }
                if idx_Lens == items_Lens.count - 1 {
                    $0.trailing.equalToSuperview()
                }
            }
            prevStack_Lens = stack_Lens
        }

        // 渐变竖条分隔（两条）
        for xFrac_Lens in [CGFloat(1) / 3, CGFloat(2) / 3] {
            let divider_Lens = UIView()
            divider_Lens.isUserInteractionEnabled = false
            statsView_Lens.addSubview(divider_Lens)
            divider_Lens.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.height.equalTo(28)
                $0.width.equalTo(1)
                $0.centerX.equalToSuperview().multipliedBy(xFrac_Lens * 2)
            }
            let divGrad_Lens = CAGradientLayer()
            divGrad_Lens.colors = [
                UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor,
                UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.45).cgColor,
                UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
            ]
            divGrad_Lens.startPoint = CGPoint(x: 0.5, y: 0)
            divGrad_Lens.endPoint = CGPoint(x: 0.5, y: 1)
            divGrad_Lens.frame = CGRect(x: 0, y: 0, width: 1, height: 28)
            divider_Lens.layer.addSublayer(divGrad_Lens)
        }

        // 底部分隔线
        let bottomLine_Lens = UIView()
        bottomLine_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        statsView_Lens.addSubview(bottomLine_Lens)
        bottomLine_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    /// 搭建自定义分段（Posts / Liked）+ 渐变滑动指示条
    private func setupSegmentSection_Lens() {
        statsCardView_Lens.addSubview(segContainerView_Lens)
        segContainerView_Lens.snp.makeConstraints {
            $0.top.equalTo(statsView_Lens.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(52)
        }

        segContainerView_Lens.addSubview(postsTabBtn_Lens)
        segContainerView_Lens.addSubview(likedTabBtn_Lens)
        segContainerView_Lens.addSubview(segIndicatorView_Lens)

        postsTabBtn_Lens.addTarget(self, action: #selector(onTabTap_Lens(_:)), for: .touchUpInside)
        likedTabBtn_Lens.addTarget(self, action: #selector(onTabTap_Lens(_:)), for: .touchUpInside)

        postsTabBtn_Lens.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
        }
        likedTabBtn_Lens.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
        }

        // 指示条初始位于 Posts（胶囊形）
        segIndicatorView_Lens.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(4)
            $0.width.equalTo(56)
            $0.centerX.equalTo(postsTabBtn_Lens)
        }

        // 指示条紫蓝渐变
        let indicatorGrad_Lens = CAGradientLayer()
        indicatorGrad_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor
        ]
        indicatorGrad_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        indicatorGrad_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        indicatorGrad_Lens.cornerRadius = 2
        indicatorGrad_Lens.frame = CGRect(x: 0, y: 0, width: 56, height: 4)
        segIndicatorView_Lens.layer.addSublayer(indicatorGrad_Lens)

        // 分段容器顶部分隔线
        let topLine_Lens = UIView()
        topLine_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        segContainerView_Lens.addSubview(topLine_Lens)
        topLine_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(0.5)
        }
    }

    /// 搭建帖子集合视图区（含空占位视图）
    private func setupCollectionSection_Lens() {
        contentView_Lens.addSubview(collectionView_Lens)
        collectionView_Lens.snp.makeConstraints {
            $0.top.equalTo(statsCardView_Lens.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(200)
        }

        let emptyIcon_Lens = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled"))
        emptyIcon_Lens.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        emptyIcon_Lens.contentMode = .scaleAspectFit
        let emptyLabel_Lens = UILabel()
        emptyLabel_Lens.text = "No posts yet"
        emptyLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        emptyLabel_Lens.font = .systemFont(ofSize: 15)
        emptyPostsView_Lens.addSubview(emptyIcon_Lens)
        emptyPostsView_Lens.addSubview(emptyLabel_Lens)
        // 图标从顶部偏移 40pt，避免紧贴分段栏
        emptyIcon_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
            $0.width.height.equalTo(56)
        }
        emptyLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emptyIcon_Lens.snp.bottom).offset(14)
        }

        contentView_Lens.addSubview(emptyPostsView_Lens)
        emptyPostsView_Lens.snp.makeConstraints {
            $0.top.equalTo(statsCardView_Lens.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据刷新

    private func observeNotifications_Lens() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onStateChange_Lens),
            name: UserViewModel_Lens.userStateDidChangeNotification_Lens, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onStateChange_Lens),
            name: TitleViewModel_Lens.titleStateDidChangeNotification_Lens, object: nil
        )
    }

    @objc private func onStateChange_Lens() { refreshData_Lens() }

    /// 刷新页面数据（统计 + 帖子列表）
    private func refreshData_Lens() {
        let user_Lens = meModel_Lens ?? UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        nameLabel_Lens.text = user_Lens.userName_Lens ?? "User"
        bioLabel_Lens.text = user_Lens.userIntroduce_Lens ?? ""
        followCountLabel_Lens.text = "\(user_Lens.userFollow_Lens.count)"
        likeCountLabel_Lens.text = "\(user_Lens.userLike_Lens.count)"
        postCountLabel_Lens.text = "\(user_Lens.userPosts_Lens.count)"

        displayPosts_Lens = selectedSegment_Lens == 0 ? user_Lens.userPosts_Lens : user_Lens.userLike_Lens
        let isEmpty_Lens = displayPosts_Lens.isEmpty
        emptyPostsView_Lens.isHidden = !isEmpty_Lens
        collectionView_Lens.isHidden = isEmpty_Lens
        collectionView_Lens.reloadData()
        updateCollectionHeight_Lens()
    }

    private func updateCollectionHeight_Lens() {
        guard !displayPosts_Lens.isEmpty else {
            collectionView_Lens.snp.updateConstraints { $0.height.equalTo(0) }
            return
        }
        let layout_Lens = collectionView_Lens.collectionViewLayout as? UICollectionViewFlowLayout
        let itemH_Lens = layout_Lens?.itemSize.height ?? 150
        let lineSpacing_Lens = layout_Lens?.minimumLineSpacing ?? 10
        let rows_Lens = Int(ceil(Double(displayPosts_Lens.count) / 2.0))
        let totalH_Lens = CGFloat(rows_Lens) * itemH_Lens + CGFloat(rows_Lens - 1) * lineSpacing_Lens + 12 + 24
        collectionView_Lens.snp.updateConstraints { $0.height.equalTo(totalH_Lens) }
    }

    // MARK: - 事件响应

    @objc private func onSettingTap_Lens() {
        Navigation_Lens.toSetting_Lens()
    }

    @objc private func onEditProfileTap_Lens() {
        goEditInfo_Lens()
    }

    private func goEditInfo_Lens() {
        Navigation_Lens.toEditInfo_Lens()
    }

    /// 自定义分段切换（带滑动动画）
    @objc private func onTabTap_Lens(_ sender: UIButton) {
        guard sender.tag != selectedSegment_Lens else { return }
        let generator_Lens = UIImpactFeedbackGenerator(style: .light)
        generator_Lens.impactOccurred()
        selectedSegment_Lens = sender.tag

        postsTabBtn_Lens.isSelected = selectedSegment_Lens == 0
        likedTabBtn_Lens.isSelected = selectedSegment_Lens == 1

        let targetBtn_Lens = selectedSegment_Lens == 0 ? postsTabBtn_Lens : likedTabBtn_Lens
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.segIndicatorView_Lens.snp.remakeConstraints {
                $0.bottom.equalToSuperview().inset(10)
                $0.height.equalTo(4)
                $0.width.equalTo(56)
                $0.centerX.equalTo(targetBtn_Lens)
            }
            self.segContainerView_Lens.layoutIfNeeded()
        }
        refreshData_Lens()
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension Me_Lens: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayPosts_Lens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Lens = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Lens.reuseId_Lens, for: indexPath
        ) as! MePostCell_Lens
        cell_Lens.configure_Lens(post_Lens: displayPosts_Lens[indexPath.item], from_Lens: self) { [weak self] in
            self?.refreshData_Lens()
        }
        return cell_Lens
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Lens.toTitleDetail_Lens(titleModel_lens: displayPosts_Lens[indexPath.item])
    }
}

// MARK: - 帖子 Cell（重构版）

/// 我的页面帖子 Cell（重构版）
/// 核心作用：展示媒体封面、帖子标题以及右上角操作按钮
/// 设计思路：外层阴影容器 + 内部深色卡片（圆角 14pt）
class MePostCell_Lens: UICollectionViewCell {

    static let reuseId_Lens = "MePostCell_Lens"

    // MARK: - UI 组件

    private let shadowContainer_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.3
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        return v
    }()

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    private let mediaView_Lens = MediaDisplayView_Lens()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.numberOfLines = 2
        return l
    }()

    private let reportContainer_Lens = UIView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowContainer_Lens.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainer_Lens.bounds, cornerRadius: 14
        ).cgPath
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        contentView.addSubview(shadowContainer_Lens)
        shadowContainer_Lens.addSubview(cardView_Lens)
        cardView_Lens.addSubview(mediaView_Lens)
        cardView_Lens.addSubview(titleLabel_Lens)
        cardView_Lens.addSubview(reportContainer_Lens)

        shadowContainer_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        cardView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        mediaView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(cardView_Lens.snp.width).multipliedBy(0.78)
        }
        reportContainer_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().inset(6)
            $0.width.height.equalTo(28)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(mediaView_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }

    // MARK: - 数据配置

    /// 配置 Cell 数据
    /// - Parameters:
    ///   - post_Lens: 帖子数据模型
    ///   - from_Lens: 所属视图控制器
    ///   - completion_Lens: 操作完成后刷新回调
    func configure_Lens(post_Lens: TitleModel_Lens, from_Lens: UIViewController, completion_Lens: (() -> Void)? = nil) {
        mediaView_Lens.configure_Lens(mediaPath_Lens: post_Lens.titleMeidas_Lens.first)
        titleLabel_Lens.text = post_Lens.title_Lens

        reportContainer_Lens.subviews.forEach { $0.removeFromSuperview() }
        let btn_Lens = ReportDeleteHelper_Lens.createPostReportButton_Lens(
            post_Lens: post_Lens, size_Lens: 15,
            color_Lens: .white, from: from_Lens,
            completion_Lens: completion_Lens
        )
        reportContainer_Lens.addSubview(btn_Lens)
        btn_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
