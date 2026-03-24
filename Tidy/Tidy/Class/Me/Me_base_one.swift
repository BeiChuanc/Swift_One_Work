import Foundation
import UIKit
import SnapKit

// MARK: - 帖子卡片代理协议

/// 我的页面帖子卡片代理
/// 功能：将用户在卡片上的操作按钮点击事件回传给页面控制器
protocol MePostCellDelegate_Base_one: AnyObject {
    /// 点击帖子右上角操作按钮（举报/删除）
    func mePostCell_Base_one(didTapAction post_Base_one: TitleModel_Base_one)
}

// MARK: - 帖子卡片 Cell

/// 我的页面帖子卡片单元格
/// 功能：展示帖子封面图、标题、点赞数和操作按钮
/// 关键属性：delegate_Base_one（操作回调）、post_Base_one（绑定数据）
class MePostCell_Base_one: UICollectionViewCell {

    // MARK: - 复用标识

    static let reuseId_Base_one = "MePostCell_Base_one"

    // MARK: - UI 组件

    private let imageView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        return iv
    }()

    /// 底部半透明蒙层（提升文字可读性）
    private let gradientOverlay_Base_one: UIView = {
        let v = UIView()
        return v
    }()

    private let gradientOverlayLayer_Base_one = CAGradientLayer()

    private let titleLabel_Base_one: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.shadowColor = UIColor.black.withAlphaComponent(0.3)
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    private let likeIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.fill")
        iv.tintColor = UIColor(hexstring_Base_one: "#FBB6CE")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likeLabel_Base_one: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.shadowColor = UIColor.black.withAlphaComponent(0.3)
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    /// 媒体类型图标（视频时展示播放图标）
    private let mediaTypeIcon_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor.white.withAlphaComponent(0.9)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 操作按钮容器（举报/删除，由外部注入）
    let actionContainer_Base_one: UIView = {
        let v = UIView()
        return v
    }()

    // MARK: - 属性

    weak var delegate_Base_one: MePostCellDelegate_Base_one?
    private(set) var post_Base_one: TitleModel_Base_one?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 16
        gradientOverlayLayer_Base_one.frame = gradientOverlay_Base_one.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView_Base_one.image = nil
        imageView_Base_one.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        mediaTypeIcon_Base_one.image = nil
        // 清空已注入的操作按钮
        actionContainer_Base_one.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = ColorConfig_Base_one.cardBackground_Base_one

        // 阴影需要设置在 contentView 的父 layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8
        layer.masksToBounds = false

        contentView.addSubview(imageView_Base_one)
        contentView.addSubview(gradientOverlay_Base_one)
        contentView.addSubview(titleLabel_Base_one)
        contentView.addSubview(likeIconView_Base_one)
        contentView.addSubview(likeLabel_Base_one)
        contentView.addSubview(mediaTypeIcon_Base_one)
        contentView.addSubview(actionContainer_Base_one)

        // 底部渐变
        gradientOverlayLayer_Base_one.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.65).cgColor
        ]
        gradientOverlayLayer_Base_one.startPoint = CGPoint(x: 0.5, y: 0)
        gradientOverlayLayer_Base_one.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay_Base_one.layer.addSublayer(gradientOverlayLayer_Base_one)

        imageView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        gradientOverlay_Base_one.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        actionContainer_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        mediaTypeIcon_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(16)
        }
        titleLabel_Base_one.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalTo(likeIconView_Base_one.snp.top).offset(-4)
        }
        likeIconView_Base_one.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(12)
        }
        likeLabel_Base_one.snp.makeConstraints { make in
            make.left.equalTo(likeIconView_Base_one.snp.right).offset(4)
            make.centerY.equalTo(likeIconView_Base_one)
        }
    }

    // MARK: - 配置

    /// 用帖子数据配置单元格
    /// - Parameter post_Base_one: 帖子数据模型
    func configure_Base_one(post post_Base_one: TitleModel_Base_one) {
        self.post_Base_one = post_Base_one
        titleLabel_Base_one.text = post_Base_one.title_Base_one
        likeLabel_Base_one.text = "\(post_Base_one.likes_Base_one)"
        loadPostMedia_Base_one(medias: post_Base_one.titleMeidas_Base_one)
    }

    /// 加载帖子封面媒体
    /// - Parameter medias: 媒体路径数组
    private func loadPostMedia_Base_one(medias: [String]) {
        guard let firstMedia_Base_one = medias.first, !firstMedia_Base_one.isEmpty else {
            setPlaceholderBackground_Base_one()
            return
        }

        // 判断视频
        let isVideo_Base_one = firstMedia_Base_one.hasSuffix(".mp4") || firstMedia_Base_one.hasSuffix(".mov")
        mediaTypeIcon_Base_one.image = isVideo_Base_one
            ? UIImage(systemName: "play.circle.fill")
            : nil

        // 尝试 Assets → 本地文件
        if let image_Base_one = UIImage(named: firstMedia_Base_one) {
            imageView_Base_one.image = image_Base_one
        } else if !isVideo_Base_one, let image_Base_one = UIImage(contentsOfFile: firstMedia_Base_one) {
            imageView_Base_one.image = image_Base_one
        } else {
            setPlaceholderBackground_Base_one()
        }
    }

    /// 设置无媒体时的渐变占位背景
    private func setPlaceholderBackground_Base_one() {
        let colors_Base_one: [UIColor] = [
            ColorConfig_Base_one.primaryGradientStart_Base_one,
            ColorConfig_Base_one.primaryGradientEnd_Base_one,
            ColorConfig_Base_one.secondaryGradientStart_Base_one
        ]
        let idx_Base_one = (post_Base_one?.titleId_Base_one ?? 0) % colors_Base_one.count
        imageView_Base_one.backgroundColor = colors_Base_one[idx_Base_one].withAlphaComponent(0.4)
        mediaTypeIcon_Base_one.image = UIImage(systemName: "photo")
    }
}

// MARK: - 我的页面主控制器

/// 我的页面 — 个人中心
/// 功能：展示当前登录用户信息、发布帖子与喜欢帖子，支持切换查看、跳转编辑和设置
/// 设计：渐变大头部 + 统计数据行 + 分段 Tab + 2列帖子网格
class Me_Base_one: UIViewController {

    // MARK: - 属性

    /// 从外部传入的用户模型（优先于当前登录用户）
    var meModel_Base_one: LoginUserModel_Base_one?

    /// 当前分段：0=发布 1=喜欢
    private var currentSegment_Base_one: Int = 0

    /// 当前展示的帖子列表
    private var displayedPosts_Base_one: [TitleModel_Base_one] = []

    // 帖子网格每列数量
    private let columns_Base_one: CGFloat = 2
    private let gridSpacing_Base_one: CGFloat = 12
    private let gridPadding_Base_one: CGFloat = 16
    private var itemWidth_Base_one: CGFloat = 0
    private var itemHeight_Base_one: CGFloat = 0

    // MARK: - UI 组件

    // 顶层滚动容器
    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        // 禁用自动 inset，使内容从屏幕顶部开始，消除顶部色差
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Base_one = UIView()

    // ——— 头部渐变区 ———

    private let headerView_Base_one: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 30
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradientLayer_Base_one = CAGradientLayer()

    /// 装饰圆形背景（设计感）
    private let decorCircle1_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 80
        return v
    }()

    private let decorCircle2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 60
        return v
    }()

    /// 顶部 VIP 入口按钮（vip_btn 图标，171×44，位于设置按钮左侧10）
    private let vipButton_Base_one: UIButton = {
        let btn_Base_one = UIButton(type: .custom)
        btn_Base_one.setImage(
            UIImage(named: "vip_btn")?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        btn_Base_one.imageView?.contentMode = .scaleAspectFit
        btn_Base_one.clipsToBounds = true
        return btn_Base_one
    }()

    /// 右上角设置按钮
    private let settingsButton_Base_one: UIButton = {
        let button_Base_one = UIButton(type: .system)
        let config_Base_one = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button_Base_one.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config_Base_one), for: .normal)
        button_Base_one.tintColor = .white
        button_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        button_Base_one.layer.cornerRadius = 18
        return button_Base_one
    }()

    // 头像
    private let avatarView_Base_one: CurrentUserAvatarView_Base_one = {
        let v = CurrentUserAvatarView_Base_one()
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 12
        return v
    }()

    private let nameLabel_Base_one: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let bioLabel_Base_one: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // 统计数据行
    private let statsRow_Base_one = UIView()

    // ——— 操作按钮行 ———

    private let actionRow_Base_one = UIView()

    private let editProfileButton_Base_one: UIButton = {
        let button_Base_one = UIButton(type: .system)
        button_Base_one.setTitle("Edit Profile", for: .normal)
        button_Base_one.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button_Base_one.setTitleColor(.white, for: .normal)
        button_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        button_Base_one.layer.cornerRadius = 20
        button_Base_one.layer.borderWidth = 1.2
        button_Base_one.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return button_Base_one
    }()

    // ——— 分段控制 ———

    private let segmentContainer_Base_one = UIView()

    private let segmentControl_Base_one: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Posts", "Liked"])
        seg.selectedSegmentIndex = 0
        seg.selectedSegmentTintColor = ColorConfig_Base_one.primaryGradientStart_Base_one
        seg.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Base_one.textSecondary_Base_one,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)
        return seg
    }()

    // ——— 帖子网格 ———

    private var postsCollectionView_Base_one: UICollectionView!
    private var collectionViewHeightConstraint_Base_one: Constraint?

    // ——— 空状态视图 ———

    private let emptyStateView_Base_one: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        return iv
    }()

    private let emptyLabel_Base_one: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        label.textAlignment = .center
        return label
    }()

    // MARK: - 生命周期

    /// 状态栏使用白色文字，与渐变头部配色一致
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        precalculateGridMetrics_Base_one()
        setupUI_Base_one()
        setupObservers_Base_one()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Base_one()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Base_one.frame = headerView_Base_one.bounds
    }

    // MARK: - 预计算网格尺寸

    /// 在布局前计算帖子卡片宽高，避免多次计算
    private func precalculateGridMetrics_Base_one() {
        let screenWidth_Base_one = UIScreen.main.bounds.width
        let totalSpacing_Base_one = gridPadding_Base_one * 2 + gridSpacing_Base_one * (columns_Base_one - 1)
        itemWidth_Base_one = (screenWidth_Base_one - totalSpacing_Base_one) / columns_Base_one
        itemHeight_Base_one = itemWidth_Base_one * 1.3
    }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        setupScrollView_Base_one()
        setupHeaderView_Base_one()
        setupStatsRow_Base_one()
        setupActionRow_Base_one()
        setupSegmentControl_Base_one()
        setupPostsCollectionView_Base_one()
        setupEmptyStateView_Base_one()
    }

    // MARK: ScrollView

    private func setupScrollView_Base_one() {
        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentView_Base_one)

        scrollView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Base_one)
        }
    }

    // MARK: 头部渐变

    private func setupHeaderView_Base_one() {
        headerGradientLayer_Base_one.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor
        ]
        headerGradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        headerView_Base_one.layer.insertSublayer(headerGradientLayer_Base_one, at: 0)

        contentView_Base_one.addSubview(headerView_Base_one)
        headerView_Base_one.addSubview(decorCircle1_Base_one)
        headerView_Base_one.addSubview(decorCircle2_Base_one)
        headerView_Base_one.addSubview(vipButton_Base_one)
        headerView_Base_one.addSubview(settingsButton_Base_one)
        headerView_Base_one.addSubview(avatarView_Base_one)
        headerView_Base_one.addSubview(nameLabel_Base_one)
        headerView_Base_one.addSubview(bioLabel_Base_one)

        headerView_Base_one.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            // 固定高度，覆盖状态栏 + 用户信息区域，视觉紧凑
            make.height.equalTo(250)
        }
        decorCircle1_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(-10)
        }
        decorCircle2_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.bottom.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(-20)
        }
        settingsButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        /// VIP 按钮：与设置按钮垂直居中对齐，紧贴其左侧 10pt，宽171 高44
        vipButton_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(settingsButton_Base_one)
            make.right.equalTo(settingsButton_Base_one.snp.left).offset(-10)
            make.width.equalTo(83)
            make.height.equalTo(38)
        }
        avatarView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(80)
        }
        nameLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView_Base_one.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        bioLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel_Base_one.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }

        // 按钮事件
        settingsButton_Base_one.addTarget(self, action: #selector(settingsTapped_Base_one), for: .touchUpInside)
        vipButton_Base_one.addTarget(self, action: #selector(vipTapped_Base_one), for: .touchUpInside)
    }

    // MARK: 统计数据行

    private func setupStatsRow_Base_one() {
        contentView_Base_one.addSubview(statsRow_Base_one)
        statsRow_Base_one.backgroundColor = .white
        statsRow_Base_one.layer.cornerRadius = 18
        statsRow_Base_one.layer.shadowColor = UIColor.black.cgColor
        statsRow_Base_one.layer.shadowOffset = CGSize(width: 0, height: 4)
        statsRow_Base_one.layer.shadowOpacity = 0.08
        statsRow_Base_one.layer.shadowRadius = 10

        statsRow_Base_one.snp.makeConstraints { make in
            make.top.equalTo(headerView_Base_one.snp.bottom).offset(-20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(64)
        }
    }

    // MARK: 操作按钮行

    private func setupActionRow_Base_one() {
        contentView_Base_one.addSubview(editProfileButton_Base_one)

        editProfileButton_Base_one.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Base_one.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(42)
        }

        // 编辑按钮渐变背景
        let btnGrad_Base_one = CAGradientLayer()
        btnGrad_Base_one.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor
        ]
        btnGrad_Base_one.startPoint = CGPoint(x: 0, y: 0)
        btnGrad_Base_one.endPoint = CGPoint(x: 1, y: 0)
        btnGrad_Base_one.cornerRadius = 20
        editProfileButton_Base_one.layer.insertSublayer(btnGrad_Base_one, at: 0)
        editProfileButton_Base_one.backgroundColor = .clear

        // 延迟设置渐变 frame（等 layout 完成）
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            btnGrad_Base_one.frame = self.editProfileButton_Base_one.bounds
        }

        editProfileButton_Base_one.addTarget(self, action: #selector(editProfileTapped_Base_one), for: .touchUpInside)
    }

    // MARK: 分段控制

    private func setupSegmentControl_Base_one() {
        contentView_Base_one.addSubview(segmentContainer_Base_one)
        segmentContainer_Base_one.addSubview(segmentControl_Base_one)
        segmentContainer_Base_one.backgroundColor = .white

        segmentContainer_Base_one.snp.makeConstraints { make in
            make.top.equalTo(editProfileButton_Base_one.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        segmentControl_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(40)
        }

        segmentControl_Base_one.addTarget(self, action: #selector(segmentChanged_Base_one(_:)), for: .valueChanged)
    }

    // MARK: 帖子网格

    private func setupPostsCollectionView_Base_one() {
        let layout_Base_one = UICollectionViewFlowLayout()
        layout_Base_one.scrollDirection = .vertical
        layout_Base_one.minimumLineSpacing = gridSpacing_Base_one
        layout_Base_one.minimumInteritemSpacing = gridSpacing_Base_one
        layout_Base_one.itemSize = CGSize(width: itemWidth_Base_one, height: itemHeight_Base_one)
        layout_Base_one.sectionInset = UIEdgeInsets(
            top: gridPadding_Base_one,
            left: gridPadding_Base_one,
            bottom: gridPadding_Base_one,
            right: gridPadding_Base_one
        )

        postsCollectionView_Base_one = UICollectionView(frame: .zero, collectionViewLayout: layout_Base_one)
        postsCollectionView_Base_one.isScrollEnabled = false
        postsCollectionView_Base_one.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        postsCollectionView_Base_one.dataSource = self
        postsCollectionView_Base_one.delegate = self
        postsCollectionView_Base_one.register(MePostCell_Base_one.self, forCellWithReuseIdentifier: MePostCell_Base_one.reuseId_Base_one)

        contentView_Base_one.addSubview(postsCollectionView_Base_one)
        postsCollectionView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Base_one.snp.bottom)
            make.left.right.equalToSuperview()
            collectionViewHeightConstraint_Base_one = make.height.equalTo(200).constraint
            make.bottom.equalToSuperview()
        }
    }

    // MARK: 空状态视图

    private func setupEmptyStateView_Base_one() {
        contentView_Base_one.addSubview(emptyStateView_Base_one)
        emptyStateView_Base_one.addSubview(emptyIconView_Base_one)
        emptyStateView_Base_one.addSubview(emptyLabel_Base_one)

        emptyStateView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Base_one.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(160)
        }
        emptyIconView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(48)
        }
        emptyLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyIconView_Base_one.snp.bottom).offset(12)
        }
    }

    // MARK: - 通知监听

    private func setupObservers_Base_one() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Base_one),
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Base_one),
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one,
            object: nil
        )
    }

    @objc private func handleDataChange_Base_one() {
        loadData_Base_one()
    }

    // MARK: - 数据加载

    /// 加载当前用户数据并刷新界面
    private func loadData_Base_one() {
        let user_Base_one = meModel_Base_one ?? UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        updateUserInfo_Base_one(user: user_Base_one)
        updatePostsData_Base_one(user: user_Base_one)
    }

    /// 更新用户信息展示区
    private func updateUserInfo_Base_one(user user_Base_one: LoginUserModel_Base_one) {
        nameLabel_Base_one.text = user_Base_one.userName_Base_one ?? "Guest"

        let intro_Base_one = user_Base_one.userIntroduce_Base_one ?? ""
        bioLabel_Base_one.text = intro_Base_one.isEmpty ? "No bio yet ✨" : intro_Base_one

        // 更新头像
        if let userId_Base_one = user_Base_one.userId_Base_one {
            avatarView_Base_one.configure_Base_one(userId_Base_one: userId_Base_one)
        }

        // 刷新统计数据
        let myPosts_Base_one = TitleViewModel_Base_one.shared_Base_one.getPosts_Base_one()
            .filter { $0.titleUserId_Base_one == user_Base_one.userId_Base_one }
        refreshStatsView_Base_one(
            postsCount: myPosts_Base_one.count,
            likedCount: user_Base_one.userLike_Base_one.count,
            followingCount: user_Base_one.userFollow_Base_one.count
        )
    }

    /// 刷新统计数据行内容
    /// - Note: 不使用 UIStackView 包含分隔线，因为 fillEqually 会将分隔线宽度等分放大
    ///   改为直接用 SnapKit 精确定位三列 + 两条 0.5pt 分隔线
    private func refreshStatsView_Base_one(postsCount: Int, likedCount: Int, followingCount: Int) {
        statsRow_Base_one.subviews.forEach { $0.removeFromSuperview() }

        let col1_Base_one = makeStatColumn_Base_one(value: "\(postsCount)", label: "Posts")
        let col2_Base_one = makeStatColumn_Base_one(value: "\(likedCount)", label: "Liked")
        let col3_Base_one = makeStatColumn_Base_one(value: "\(followingCount)", label: "Following")
        let div1_Base_one = makeStatDivider_Base_one()
        let div2_Base_one = makeStatDivider_Base_one()

        statsRow_Base_one.addSubview(col1_Base_one)
        statsRow_Base_one.addSubview(div1_Base_one)
        statsRow_Base_one.addSubview(col2_Base_one)
        statsRow_Base_one.addSubview(div2_Base_one)
        statsRow_Base_one.addSubview(col3_Base_one)

        // 三列等宽，分隔线精确 0.5pt
        col1_Base_one.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        div1_Base_one.snp.makeConstraints { make in
            make.left.equalTo(col1_Base_one.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(28)
        }
        col2_Base_one.snp.makeConstraints { make in
            make.left.equalTo(div1_Base_one.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        div2_Base_one.snp.makeConstraints { make in
            make.left.equalTo(col2_Base_one.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(28)
        }
        col3_Base_one.snp.makeConstraints { make in
            make.left.equalTo(div2_Base_one.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
    }

    /// 构建统计分隔线（精确细线，不参与 StackView 等宽分配）
    private func makeStatDivider_Base_one() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }

    /// 构建单个统计列（数值 + 标签）
    private func makeStatColumn_Base_one(value: String, label: String) -> UIView {
        let container_Base_one = UIView()
        let valueLabel_Base_one = UILabel()
        valueLabel_Base_one.text = value
        valueLabel_Base_one.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel_Base_one.textColor = ColorConfig_Base_one.textPrimary_Base_one
        valueLabel_Base_one.textAlignment = .center

        let titleLabel_Base_one = UILabel()
        titleLabel_Base_one.text = label
        titleLabel_Base_one.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel_Base_one.textColor = ColorConfig_Base_one.textSecondary_Base_one
        titleLabel_Base_one.textAlignment = .center

        container_Base_one.addSubview(valueLabel_Base_one)
        container_Base_one.addSubview(titleLabel_Base_one)
        valueLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }
        titleLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(valueLabel_Base_one.snp.bottom).offset(2)
        }
        return container_Base_one
    }

    /// 根据当前分段更新帖子数据并刷新网格
    private func updatePostsData_Base_one(user user_Base_one: LoginUserModel_Base_one? = nil) {
        let currentUser_Base_one = user_Base_one
            ?? meModel_Base_one
            ?? UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()

        if currentSegment_Base_one == 0 {
            // 发布的帖子
            let allPosts_Base_one = TitleViewModel_Base_one.shared_Base_one.getPosts_Base_one()
            displayedPosts_Base_one = allPosts_Base_one.filter {
                $0.titleUserId_Base_one == currentUser_Base_one.userId_Base_one
            }
        } else {
            // 喜欢的帖子
            displayedPosts_Base_one = currentUser_Base_one.userLike_Base_one
        }

        reloadPostsGrid_Base_one()
    }

    /// 重新加载帖子网格并更新高度约束
    private func reloadPostsGrid_Base_one() {
        postsCollectionView_Base_one.reloadData()

        let isEmpty_Base_one = displayedPosts_Base_one.isEmpty

        // 空状态切换
        emptyStateView_Base_one.isHidden = !isEmpty_Base_one
        postsCollectionView_Base_one.isHidden = isEmpty_Base_one

        if isEmpty_Base_one {
            let icon_Base_one = currentSegment_Base_one == 0 ? "square.and.pencil" : "heart"
            let hint_Base_one = currentSegment_Base_one == 0 ? "No posts yet" : "No liked posts yet"
            emptyIconView_Base_one.image = UIImage(systemName: icon_Base_one)
            emptyLabel_Base_one.text = hint_Base_one
            collectionViewHeightConstraint_Base_one?.update(offset: 0)
        } else {
            // 动态计算 collection view 高度
            let rows_Base_one = ceil(CGFloat(displayedPosts_Base_one.count) / columns_Base_one)
            let totalHeight_Base_one = rows_Base_one * itemHeight_Base_one
                + (rows_Base_one - 1) * gridSpacing_Base_one
                + gridPadding_Base_one * 2
            collectionViewHeightConstraint_Base_one?.update(offset: totalHeight_Base_one)
        }

        UIView.animate(withDuration: 0.25) { self.contentView_Base_one.layoutIfNeeded() }
    }

    // MARK: - 事件处理

    @objc private func settingsTapped_Base_one() {
        settingsButton_Base_one.animatePressDown_Base_one {
            self.settingsButton_Base_one.animatePressUp_Base_one()
        }
        Navigation_Base_one.toSetting_Base_one()
    }

    /// 点击 VIP 入口按钮，跳转至 VIP 订阅页
    @objc private func vipTapped_Base_one() {
        vipButton_Base_one.animatePressDown_Base_one {
            self.vipButton_Base_one.animatePressUp_Base_one()
        }
        Navigation_Base_one.toVIPSubscription_Base_one()
    }

    @objc private func editProfileTapped_Base_one() {
        editProfileButton_Base_one.animatePressDown_Base_one {
            self.editProfileButton_Base_one.animatePressUp_Base_one()
        }
        Navigation_Base_one.toEditInfo_Base_one()
    }

    @objc private func segmentChanged_Base_one(_ sender: UISegmentedControl) {
        currentSegment_Base_one = sender.selectedSegmentIndex
        updatePostsData_Base_one()

        // 切换时弹性动画
        postsCollectionView_Base_one.animateSpringScaleIn_Base_one()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource

extension Me_Base_one: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPosts_Base_one.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Base_one = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Base_one.reuseId_Base_one,
            for: indexPath
        ) as! MePostCell_Base_one

        let post_Base_one = displayedPosts_Base_one[indexPath.item]
        cell_Base_one.configure_Base_one(post: post_Base_one)
        cell_Base_one.delegate_Base_one = self

        // 注入举报/删除按钮
        cell_Base_one.actionContainer_Base_one.subviews.forEach { $0.removeFromSuperview() }
        let actionBtn_Base_one = ReportDeleteHelper_Base_one.createPostReportButton_Base_one(
            post_Base_one: post_Base_one,
            size_Base_one: 14,
            color_Base_one: .white,
            from: self
        ) { [weak self] in
            self?.updatePostsData_Base_one()
        }
        cell_Base_one.actionContainer_Base_one.addSubview(actionBtn_Base_one)
        actionBtn_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 入场动画（交错延迟）
        cell_Base_one.alpha = 0
        cell_Base_one.animateFadeIn_Base_one(delay_Base_one: Double(indexPath.item) * 0.04)

        return cell_Base_one
    }
}

// MARK: - UICollectionViewDelegate

extension Me_Base_one: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Base_one = displayedPosts_Base_one[indexPath.item]
        Navigation_Base_one.toTitleDetail_Base_one(titleModel_base_one: post_Base_one)
    }
}

// MARK: - MePostCellDelegate_Base_one

extension Me_Base_one: MePostCellDelegate_Base_one {

    /// 帖子卡片操作按钮点击（此处委托给 ReportDeleteHelper 内部处理，无需额外逻辑）
    func mePostCell_Base_one(didTapAction post_Base_one: TitleModel_Base_one) {
        // 操作按钮已通过 ReportDeleteHelper.createPostReportButton 注入完整逻辑
    }
}
