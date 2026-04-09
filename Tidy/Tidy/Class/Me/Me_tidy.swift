import Foundation
import UIKit
import SnapKit

// MARK: - 帖子卡片代理协议

/// 我的页面帖子卡片代理
/// 功能：将用户在卡片上的操作按钮点击事件回传给页面控制器
protocol MePostCellDelegate_Tidy: AnyObject {
    /// 点击帖子右上角操作按钮（举报/删除）
    func mePostCell_Tidy(didTapAction post_Tidy: TitleModel_Tidy)
}

// MARK: - 帖子卡片 Cell

/// 我的页面帖子卡片单元格
/// 功能：展示帖子封面图、标题、点赞数和操作按钮
/// 关键属性：delegate_Tidy（操作回调）、post_Tidy（绑定数据）
class MePostCell_Tidy: UICollectionViewCell {

    // MARK: - 复用标识

    static let reuseId_Tidy = "MePostCell_Tidy"

    // MARK: - UI 组件

    private let imageView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return iv
    }()

    /// 底部半透明蒙层（提升文字可读性）
    private let gradientOverlay_Tidy: UIView = {
        let v = UIView()
        return v
    }()

    private let gradientOverlayLayer_Tidy = CAGradientLayer()

    private let titleLabel_Tidy: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.shadowColor = UIColor.black.withAlphaComponent(0.3)
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    private let likeIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.fill")
        iv.tintColor = UIColor(hexstring_Tidy: "#FBB6CE")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likeLabel_Tidy: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.shadowColor = UIColor.black.withAlphaComponent(0.3)
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    /// 媒体类型图标（视频时展示播放图标）
    private let mediaTypeIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor.white.withAlphaComponent(0.9)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 操作按钮容器（举报/删除，由外部注入）
    let actionContainer_Tidy: UIView = {
        let v = UIView()
        return v
    }()

    // MARK: - 属性

    weak var delegate_Tidy: MePostCellDelegate_Tidy?
    private(set) var post_Tidy: TitleModel_Tidy?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 16
        gradientOverlayLayer_Tidy.frame = gradientOverlay_Tidy.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView_Tidy.image = nil
        imageView_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        mediaTypeIcon_Tidy.image = nil
        // 清空已注入的操作按钮
        actionContainer_Tidy.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = ColorConfig_Tidy.cardBackground_Tidy

        // 阴影需要设置在 contentView 的父 layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8
        layer.masksToBounds = false

        contentView.addSubview(imageView_Tidy)
        contentView.addSubview(gradientOverlay_Tidy)
        contentView.addSubview(titleLabel_Tidy)
        contentView.addSubview(likeIconView_Tidy)
        contentView.addSubview(likeLabel_Tidy)
        contentView.addSubview(mediaTypeIcon_Tidy)
        contentView.addSubview(actionContainer_Tidy)

        // 底部渐变
        gradientOverlayLayer_Tidy.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.65).cgColor
        ]
        gradientOverlayLayer_Tidy.startPoint = CGPoint(x: 0.5, y: 0)
        gradientOverlayLayer_Tidy.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay_Tidy.layer.addSublayer(gradientOverlayLayer_Tidy)

        imageView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        gradientOverlay_Tidy.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        actionContainer_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        mediaTypeIcon_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(16)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalTo(likeIconView_Tidy.snp.top).offset(-4)
        }
        likeIconView_Tidy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(12)
        }
        likeLabel_Tidy.snp.makeConstraints { make in
            make.left.equalTo(likeIconView_Tidy.snp.right).offset(4)
            make.centerY.equalTo(likeIconView_Tidy)
        }
    }

    // MARK: - 配置

    /// 用帖子数据配置单元格
    /// - Parameter post_Tidy: 帖子数据模型
    func configure_Tidy(post post_Tidy: TitleModel_Tidy) {
        self.post_Tidy = post_Tidy
        titleLabel_Tidy.text = post_Tidy.title_Tidy
        likeLabel_Tidy.text = "\(post_Tidy.likes_Tidy)"
        loadPostMedia_Tidy(medias: post_Tidy.titleMeidas_Tidy)
    }

    /// 加载帖子封面媒体
    /// - Parameter medias: 媒体路径数组
    private func loadPostMedia_Tidy(medias: [String]) {
        guard let firstMedia_Tidy = medias.first, !firstMedia_Tidy.isEmpty else {
            setPlaceholderBackground_Tidy()
            return
        }

        // 判断视频
        let isVideo_Tidy = firstMedia_Tidy.hasSuffix(".mp4") || firstMedia_Tidy.hasSuffix(".mov")
        mediaTypeIcon_Tidy.image = isVideo_Tidy
            ? UIImage(systemName: "play.circle.fill")
            : nil

        // 尝试 Assets → 本地文件
        if let image_Tidy = UIImage(named: firstMedia_Tidy) {
            imageView_Tidy.image = image_Tidy
        } else if !isVideo_Tidy, let image_Tidy = UIImage(contentsOfFile: firstMedia_Tidy) {
            imageView_Tidy.image = image_Tidy
        } else {
            setPlaceholderBackground_Tidy()
        }
    }

    /// 设置无媒体时的渐变占位背景
    private func setPlaceholderBackground_Tidy() {
        let colors_Tidy: [UIColor] = [
            ColorConfig_Tidy.primaryGradientStart_Tidy,
            ColorConfig_Tidy.primaryGradientEnd_Tidy,
            ColorConfig_Tidy.secondaryGradientStart_Tidy
        ]
        let idx_Tidy = (post_Tidy?.titleId_Tidy ?? 0) % colors_Tidy.count
        imageView_Tidy.backgroundColor = colors_Tidy[idx_Tidy].withAlphaComponent(0.4)
        mediaTypeIcon_Tidy.image = UIImage(systemName: "photo")
    }
}

// MARK: - 我的页面主控制器

/// 我的页面 — 个人中心
/// 功能：展示当前登录用户信息、发布帖子与喜欢帖子，支持切换查看、跳转编辑和设置
/// 设计：渐变大头部 + 统计数据行 + 分段 Tab + 2列帖子网格
class Me_Tidy: UIViewController {

    // MARK: - 属性

    /// 从外部传入的用户模型（优先于当前登录用户）
    var meModel_Tidy: LoginUserModel_Tidy?

    /// 当前分段：0=发布 1=喜欢
    private var currentSegment_Tidy: Int = 0

    /// 当前展示的帖子列表
    private var displayedPosts_Tidy: [TitleModel_Tidy] = []

    // 帖子网格每列数量
    private let columns_Tidy: CGFloat = 2
    private let gridSpacing_Tidy: CGFloat = 12
    private let gridPadding_Tidy: CGFloat = 16
    private var itemWidth_Tidy: CGFloat = 0
    private var itemHeight_Tidy: CGFloat = 0

    // MARK: - UI 组件

    // 顶层滚动容器
    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        // 禁用自动 inset，使内容从屏幕顶部开始，消除顶部色差
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Tidy = UIView()

    // ——— 头部渐变区 ———

    private let headerView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 30
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradientLayer_Tidy = CAGradientLayer()

    /// 装饰圆形背景（设计感）
    private let decorCircle1_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 80
        return v
    }()

    private let decorCircle2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 60
        return v
    }()

    /// 顶部 VIP 入口按钮（vip_btn 图标，171×44，位于设置按钮左侧10）
    private let vipButton_Tidy: UIButton = {
        let btn_Tidy = UIButton(type: .custom)
        btn_Tidy.setImage(
            UIImage(named: "vip_btn")?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        btn_Tidy.imageView?.contentMode = .scaleAspectFit
        btn_Tidy.clipsToBounds = true
        return btn_Tidy
    }()

    /// 右上角设置按钮
    private let settingsButton_Tidy: UIButton = {
        let button_Tidy = UIButton(type: .system)
        let config_Tidy = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button_Tidy.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config_Tidy), for: .normal)
        button_Tidy.tintColor = .white
        button_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        button_Tidy.layer.cornerRadius = 18
        return button_Tidy
    }()

    // 头像
    private let avatarView_Tidy: CurrentUserAvatarView_Tidy = {
        let v = CurrentUserAvatarView_Tidy()
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 12
        return v
    }()

    private let nameLabel_Tidy: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let bioLabel_Tidy: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // 统计数据行
    private let statsRow_Tidy = UIView()

    // ——— 操作按钮行 ———

    private let actionRow_Tidy = UIView()

    private let editProfileButton_Tidy: UIButton = {
        let button_Tidy = UIButton(type: .system)
        button_Tidy.setTitle("Edit Profile", for: .normal)
        button_Tidy.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button_Tidy.setTitleColor(.white, for: .normal)
        button_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        button_Tidy.layer.cornerRadius = 20
        button_Tidy.layer.borderWidth = 1.2
        button_Tidy.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return button_Tidy
    }()

    // ——— 分段控制 ———

    private let segmentContainer_Tidy = UIView()

    private let segmentControl_Tidy: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Posts", "Liked"])
        seg.selectedSegmentIndex = 0
        seg.selectedSegmentTintColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        seg.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Tidy.textSecondary_Tidy,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)
        return seg
    }()

    // ——— 帖子网格 ———

    private var postsCollectionView_Tidy: UICollectionView!
    private var collectionViewHeightConstraint_Tidy: Constraint?

    // ——— 空状态视图 ———

    private let emptyStateView_Tidy: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        return iv
    }()

    private let emptyLabel_Tidy: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        label.textAlignment = .center
        return label
    }()

    // MARK: - 生命周期

    /// 状态栏使用白色文字，与渐变头部配色一致
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        precalculateGridMetrics_Tidy()
        setupUI_Tidy()
        setupObservers_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Tidy.frame = headerView_Tidy.bounds
    }

    // MARK: - 预计算网格尺寸

    /// 在布局前计算帖子卡片宽高，避免多次计算
    private func precalculateGridMetrics_Tidy() {
        let screenWidth_Tidy = UIScreen.main.bounds.width
        let totalSpacing_Tidy = gridPadding_Tidy * 2 + gridSpacing_Tidy * (columns_Tidy - 1)
        itemWidth_Tidy = (screenWidth_Tidy - totalSpacing_Tidy) / columns_Tidy
        itemHeight_Tidy = itemWidth_Tidy * 1.3
    }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupScrollView_Tidy()
        setupHeaderView_Tidy()
        setupStatsRow_Tidy()
        setupActionRow_Tidy()
        setupSegmentControl_Tidy()
        setupPostsCollectionView_Tidy()
        setupEmptyStateView_Tidy()
    }

    // MARK: ScrollView

    private func setupScrollView_Tidy() {
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentView_Tidy)

        scrollView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Tidy)
        }
    }

    // MARK: 头部渐变

    private func setupHeaderView_Tidy() {
        headerGradientLayer_Tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        headerGradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        headerView_Tidy.layer.insertSublayer(headerGradientLayer_Tidy, at: 0)

        contentView_Tidy.addSubview(headerView_Tidy)
        headerView_Tidy.addSubview(decorCircle1_Tidy)
        headerView_Tidy.addSubview(decorCircle2_Tidy)
        headerView_Tidy.addSubview(vipButton_Tidy)
        headerView_Tidy.addSubview(settingsButton_Tidy)
        headerView_Tidy.addSubview(avatarView_Tidy)
        headerView_Tidy.addSubview(nameLabel_Tidy)
        headerView_Tidy.addSubview(bioLabel_Tidy)

        headerView_Tidy.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            // 固定高度，覆盖状态栏 + 用户信息区域，视觉紧凑
            make.height.equalTo(250)
        }
        decorCircle1_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(-10)
        }
        decorCircle2_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.bottom.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(-20)
        }
        settingsButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        /// VIP 按钮：与设置按钮垂直居中对齐，紧贴其左侧 10pt，宽171 高44
        vipButton_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(settingsButton_Tidy)
            make.right.equalTo(settingsButton_Tidy.snp.left).offset(-10)
            make.width.equalTo(83)
            make.height.equalTo(38)
        }
        avatarView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(80)
        }
        nameLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView_Tidy.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        bioLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel_Tidy.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }

        // 按钮事件
        settingsButton_Tidy.addTarget(self, action: #selector(settingsTapped_Tidy), for: .touchUpInside)
        vipButton_Tidy.addTarget(self, action: #selector(vipTapped_Tidy), for: .touchUpInside)
    }

    // MARK: 统计数据行

    private func setupStatsRow_Tidy() {
        contentView_Tidy.addSubview(statsRow_Tidy)
        statsRow_Tidy.backgroundColor = .white
        statsRow_Tidy.layer.cornerRadius = 18
        statsRow_Tidy.layer.shadowColor = UIColor.black.cgColor
        statsRow_Tidy.layer.shadowOffset = CGSize(width: 0, height: 4)
        statsRow_Tidy.layer.shadowOpacity = 0.08
        statsRow_Tidy.layer.shadowRadius = 10

        statsRow_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerView_Tidy.snp.bottom).offset(-20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(64)
        }
    }

    // MARK: 操作按钮行

    private func setupActionRow_Tidy() {
        contentView_Tidy.addSubview(editProfileButton_Tidy)

        editProfileButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Tidy.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(42)
        }

        // 编辑按钮渐变背景
        let btnGrad_Tidy = CAGradientLayer()
        btnGrad_Tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        btnGrad_Tidy.startPoint = CGPoint(x: 0, y: 0)
        btnGrad_Tidy.endPoint = CGPoint(x: 1, y: 0)
        btnGrad_Tidy.cornerRadius = 20
        editProfileButton_Tidy.layer.insertSublayer(btnGrad_Tidy, at: 0)
        editProfileButton_Tidy.backgroundColor = .clear

        // 延迟设置渐变 frame（等 layout 完成）
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            btnGrad_Tidy.frame = self.editProfileButton_Tidy.bounds
        }

        editProfileButton_Tidy.addTarget(self, action: #selector(editProfileTapped_Tidy), for: .touchUpInside)
    }

    // MARK: 分段控制

    private func setupSegmentControl_Tidy() {
        contentView_Tidy.addSubview(segmentContainer_Tidy)
        segmentContainer_Tidy.addSubview(segmentControl_Tidy)
        segmentContainer_Tidy.backgroundColor = .white

        segmentContainer_Tidy.snp.makeConstraints { make in
            make.top.equalTo(editProfileButton_Tidy.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        segmentControl_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(40)
        }

        segmentControl_Tidy.addTarget(self, action: #selector(segmentChanged_Tidy(_:)), for: .valueChanged)
    }

    // MARK: 帖子网格

    private func setupPostsCollectionView_Tidy() {
        let layout_Tidy = UICollectionViewFlowLayout()
        layout_Tidy.scrollDirection = .vertical
        layout_Tidy.minimumLineSpacing = gridSpacing_Tidy
        layout_Tidy.minimumInteritemSpacing = gridSpacing_Tidy
        layout_Tidy.itemSize = CGSize(width: itemWidth_Tidy, height: itemHeight_Tidy)
        layout_Tidy.sectionInset = UIEdgeInsets(
            top: gridPadding_Tidy,
            left: gridPadding_Tidy,
            bottom: gridPadding_Tidy,
            right: gridPadding_Tidy
        )

        postsCollectionView_Tidy = UICollectionView(frame: .zero, collectionViewLayout: layout_Tidy)
        postsCollectionView_Tidy.isScrollEnabled = false
        postsCollectionView_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        postsCollectionView_Tidy.dataSource = self
        postsCollectionView_Tidy.delegate = self
        postsCollectionView_Tidy.register(MePostCell_Tidy.self, forCellWithReuseIdentifier: MePostCell_Tidy.reuseId_Tidy)

        contentView_Tidy.addSubview(postsCollectionView_Tidy)
        postsCollectionView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Tidy.snp.bottom)
            make.left.right.equalToSuperview()
            collectionViewHeightConstraint_Tidy = make.height.equalTo(200).constraint
            make.bottom.equalToSuperview()
        }
    }

    // MARK: 空状态视图

    private func setupEmptyStateView_Tidy() {
        contentView_Tidy.addSubview(emptyStateView_Tidy)
        emptyStateView_Tidy.addSubview(emptyIconView_Tidy)
        emptyStateView_Tidy.addSubview(emptyLabel_Tidy)

        emptyStateView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Tidy.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(160)
        }
        emptyIconView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(48)
        }
        emptyLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyIconView_Tidy.snp.bottom).offset(12)
        }
    }

    // MARK: - 通知监听

    private func setupObservers_Tidy() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Tidy),
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Tidy),
            name: TitleViewModel_Tidy.titleStateDidChangeNotification_Tidy,
            object: nil
        )
    }

    @objc private func handleDataChange_Tidy() {
        loadData_Tidy()
    }

    // MARK: - 数据加载

    /// 加载当前用户数据并刷新界面
    private func loadData_Tidy() {
        let user_Tidy = meModel_Tidy ?? UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
        updateUserInfo_Tidy(user: user_Tidy)
        updatePostsData_Tidy(user: user_Tidy)
    }

    /// 更新用户信息展示区
    private func updateUserInfo_Tidy(user user_Tidy: LoginUserModel_Tidy) {
        nameLabel_Tidy.text = user_Tidy.userName_Tidy ?? "Guest"

        let intro_Tidy = user_Tidy.userIntroduce_Tidy ?? ""
        bioLabel_Tidy.text = intro_Tidy.isEmpty ? "No bio yet ✨" : intro_Tidy

        // 更新头像
        if let userId_Tidy = user_Tidy.userId_Tidy {
            avatarView_Tidy.configure_Tidy(userId_Tidy: userId_Tidy)
        }

        // 刷新统计数据
        let myPosts_Tidy = TitleViewModel_Tidy.shared_Tidy.getPosts_Tidy()
            .filter { $0.titleUserId_Tidy == user_Tidy.userId_Tidy }
        refreshStatsView_Tidy(
            postsCount: myPosts_Tidy.count,
            likedCount: user_Tidy.userLike_Tidy.count,
            followingCount: user_Tidy.userFollow_Tidy.count
        )
    }

    /// 刷新统计数据行内容
    /// - Note: 不使用 UIStackView 包含分隔线，因为 fillEqually 会将分隔线宽度等分放大
    ///   改为直接用 SnapKit 精确定位三列 + 两条 0.5pt 分隔线
    private func refreshStatsView_Tidy(postsCount: Int, likedCount: Int, followingCount: Int) {
        statsRow_Tidy.subviews.forEach { $0.removeFromSuperview() }

        let col1_Tidy = makeStatColumn_Tidy(value: "\(postsCount)", label: "Posts")
        let col2_Tidy = makeStatColumn_Tidy(value: "\(likedCount)", label: "Liked")
        let col3_Tidy = makeStatColumn_Tidy(value: "\(followingCount)", label: "Following")
        let div1_Tidy = makeStatDivider_Tidy()
        let div2_Tidy = makeStatDivider_Tidy()

        statsRow_Tidy.addSubview(col1_Tidy)
        statsRow_Tidy.addSubview(div1_Tidy)
        statsRow_Tidy.addSubview(col2_Tidy)
        statsRow_Tidy.addSubview(div2_Tidy)
        statsRow_Tidy.addSubview(col3_Tidy)

        // 三列等宽，分隔线精确 0.5pt
        col1_Tidy.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        div1_Tidy.snp.makeConstraints { make in
            make.left.equalTo(col1_Tidy.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(28)
        }
        col2_Tidy.snp.makeConstraints { make in
            make.left.equalTo(div1_Tidy.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        div2_Tidy.snp.makeConstraints { make in
            make.left.equalTo(col2_Tidy.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(28)
        }
        col3_Tidy.snp.makeConstraints { make in
            make.left.equalTo(div2_Tidy.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
    }

    /// 构建统计分隔线（精确细线，不参与 StackView 等宽分配）
    private func makeStatDivider_Tidy() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }

    /// 构建单个统计列（数值 + 标签）
    private func makeStatColumn_Tidy(value: String, label: String) -> UIView {
        let container_Tidy = UIView()
        let valueLabel_Tidy = UILabel()
        valueLabel_Tidy.text = value
        valueLabel_Tidy.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel_Tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy
        valueLabel_Tidy.textAlignment = .center

        let titleLabel_Tidy = UILabel()
        titleLabel_Tidy.text = label
        titleLabel_Tidy.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel_Tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        titleLabel_Tidy.textAlignment = .center

        container_Tidy.addSubview(valueLabel_Tidy)
        container_Tidy.addSubview(titleLabel_Tidy)
        valueLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(valueLabel_Tidy.snp.bottom).offset(2)
        }
        return container_Tidy
    }

    /// 根据当前分段更新帖子数据并刷新网格
    private func updatePostsData_Tidy(user user_Tidy: LoginUserModel_Tidy? = nil) {
        let currentUser_Tidy = user_Tidy
            ?? meModel_Tidy
            ?? UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()

        if currentSegment_Tidy == 0 {
            // 发布的帖子
            let allPosts_Tidy = TitleViewModel_Tidy.shared_Tidy.getPosts_Tidy()
            displayedPosts_Tidy = allPosts_Tidy.filter {
                $0.titleUserId_Tidy == currentUser_Tidy.userId_Tidy
            }
        } else {
            // 喜欢的帖子
            displayedPosts_Tidy = currentUser_Tidy.userLike_Tidy
        }

        reloadPostsGrid_Tidy()
    }

    /// 重新加载帖子网格并更新高度约束
    private func reloadPostsGrid_Tidy() {
        postsCollectionView_Tidy.reloadData()

        let isEmpty_Tidy = displayedPosts_Tidy.isEmpty

        // 空状态切换
        emptyStateView_Tidy.isHidden = !isEmpty_Tidy
        postsCollectionView_Tidy.isHidden = isEmpty_Tidy

        if isEmpty_Tidy {
            let icon_Tidy = currentSegment_Tidy == 0 ? "square.and.pencil" : "heart"
            let hint_Tidy = currentSegment_Tidy == 0 ? "No posts yet" : "No liked posts yet"
            emptyIconView_Tidy.image = UIImage(systemName: icon_Tidy)
            emptyLabel_Tidy.text = hint_Tidy
            collectionViewHeightConstraint_Tidy?.update(offset: 0)
        } else {
            // 动态计算 collection view 高度
            let rows_Tidy = ceil(CGFloat(displayedPosts_Tidy.count) / columns_Tidy)
            let totalHeight_Tidy = rows_Tidy * itemHeight_Tidy
                + (rows_Tidy - 1) * gridSpacing_Tidy
                + gridPadding_Tidy * 2
            collectionViewHeightConstraint_Tidy?.update(offset: totalHeight_Tidy)
        }

        UIView.animate(withDuration: 0.25) { self.contentView_Tidy.layoutIfNeeded() }
    }

    // MARK: - 事件处理

    @objc private func settingsTapped_Tidy() {
        settingsButton_Tidy.animatePressDown_Tidy {
            self.settingsButton_Tidy.animatePressUp_Tidy()
        }
        Navigation_Tidy.toSetting_Tidy()
    }

    /// 点击 VIP 入口按钮，跳转至 VIP 订阅页
    @objc private func vipTapped_Tidy() {
        vipButton_Tidy.animatePressDown_Tidy {
            self.vipButton_Tidy.animatePressUp_Tidy()
        }
        Navigation_Tidy.toVIPSubscription_Tidy()
    }

    @objc private func editProfileTapped_Tidy() {
        editProfileButton_Tidy.animatePressDown_Tidy {
            self.editProfileButton_Tidy.animatePressUp_Tidy()
        }
        Navigation_Tidy.toEditInfo_Tidy()
    }

    @objc private func segmentChanged_Tidy(_ sender: UISegmentedControl) {
        currentSegment_Tidy = sender.selectedSegmentIndex
        updatePostsData_Tidy()

        // 切换时弹性动画
        postsCollectionView_Tidy.animateSpringScaleIn_Tidy()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource

extension Me_Tidy: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPosts_Tidy.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Tidy = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Tidy.reuseId_Tidy,
            for: indexPath
        ) as! MePostCell_Tidy

        let post_Tidy = displayedPosts_Tidy[indexPath.item]
        cell_Tidy.configure_Tidy(post: post_Tidy)
        cell_Tidy.delegate_Tidy = self

        // 注入举报/删除按钮
        cell_Tidy.actionContainer_Tidy.subviews.forEach { $0.removeFromSuperview() }
        let actionBtn_Tidy = ReportDeleteHelper_Tidy.createPostReportButton_Tidy(
            post_Tidy: post_Tidy,
            size_Tidy: 14,
            color_Tidy: .white,
            from: self
        ) { [weak self] in
            self?.updatePostsData_Tidy()
        }
        cell_Tidy.actionContainer_Tidy.addSubview(actionBtn_Tidy)
        actionBtn_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 入场动画（交错延迟）
        cell_Tidy.alpha = 0
        cell_Tidy.animateFadeIn_Tidy(delay_Tidy: Double(indexPath.item) * 0.04)

        return cell_Tidy
    }
}

// MARK: - UICollectionViewDelegate

extension Me_Tidy: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Tidy = displayedPosts_Tidy[indexPath.item]
        Navigation_Tidy.toTitleDetail_Tidy(titleModel_tidy: post_Tidy)
    }
}

// MARK: - MePostCellDelegate_Tidy

extension Me_Tidy: MePostCellDelegate_Tidy {

    /// 帖子卡片操作按钮点击（此处委托给 ReportDeleteHelper 内部处理，无需额外逻辑）
    func mePostCell_Tidy(didTapAction post_Tidy: TitleModel_Tidy) {
        // 操作按钮已通过 ReportDeleteHelper.createPostReportButton 注入完整逻辑
    }
}
