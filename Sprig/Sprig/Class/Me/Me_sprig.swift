import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 帖子展示 Tab 枚举
private enum MeContentTab_Sprig {
    /// 发布的帖子
    case posts_Sprig
    /// 喜欢的帖子
    case liked_Sprig
}

/// 我的页面
/// 功能：展示当前登录用户的个人信息（头像、昵称、简介、关注者/被关注人/帖子数统计），
///       支持切换查看发布帖子列表和喜欢帖子列表，每条帖子提供举报/删除操作
/// 设计：渐变头部 + 装饰圆 + 3项统计 + 胶囊式 Tab + 瀑布流网格卡片 + 空状态视图
class Me_Sprig: UIViewController {

    // MARK: - 属性

    /// 外部传入的登录用户模型（未传时从 UserViewModel 获取）
    var meModel_Sprig: LoginUserModel_Sprig?

    /// 当前展示 Tab
    private var currentTab_Sprig: MeContentTab_Sprig = .posts_Sprig

    /// 当前显示的帖子列表
    private var displayPosts_Sprig: [TitleModel_Sprig] = []

    // MARK: - UI 组件 - 头部

    private let headerContainer_Sprig = UIView()
    private let gradientLayer_Sprig = CAGradientLayer()
    private let settingsButton_Sprig = UIButton(type: .system)
    private let avatarView_Sprig = CurrentUserAvatarView_Sprig()
    private let nameLabel_Sprig = UILabel()
    private let bioLabel_Sprig = UILabel()
    private let editProfileButton_Sprig = UIButton(type: .system)

    /// 粉丝数统计组件
    private let followersStatView_Sprig = MeStatView_Sprig()
    /// 关注数统计组件
    private let followingStatView_Sprig = MeStatView_Sprig()
    /// 帖子数统计组件
    private let postsStatView_Sprig = MeStatView_Sprig()

    /// 头部装饰圆 1
    private let headerDecorCircle1_Sprig = UIView()
    /// 头部装饰圆 2
    private let headerDecorCircle2_Sprig = UIView()
    /// 头部装饰圆 3（小型）
    private let headerDecorCircle3_Sprig = UIView()

    // MARK: - UI 组件 - Tab 栏

    /// Tab 外层胶囊容器
    private let tabCapsuleContainer_Sprig = UIView()
    /// Posts 胶囊按钮
    private let postsTabBtn_Sprig = UIButton(type: .custom)
    /// Liked 胶囊按钮
    private let likedTabBtn_Sprig = UIButton(type: .custom)
    /// 滑动填充胶囊（选中态背景）
    private let tabActiveIndicator_Sprig = UIView()
    /// 选中态渐变层
    private let tabActivateGradient_Sprig = CAGradientLayer()

    // MARK: - UI 组件 - 列表

    private let collectionView_Sprig: UICollectionView

    /// 空状态视图
    private let emptyStateView_Sprig = UIView()

    // MARK: - 常量

    /// 头部内容区高度（不含状态栏/安全区）
    private let headerContentHeight_Sprig: CGFloat = 350

    /// 卡片间距
    private static let cardGap_Sprig: CGFloat = 12

    // MARK: - 初始化

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout_Sprig = UICollectionViewFlowLayout()
        layout_Sprig.minimumInteritemSpacing = Me_Sprig.cardGap_Sprig
        layout_Sprig.minimumLineSpacing = Me_Sprig.cardGap_Sprig
        collectionView_Sprig = UICollectionView(frame: .zero, collectionViewLayout: layout_Sprig)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        let layout_Sprig = UICollectionViewFlowLayout()
        layout_Sprig.minimumInteritemSpacing = Me_Sprig.cardGap_Sprig
        layout_Sprig.minimumLineSpacing = Me_Sprig.cardGap_Sprig
        collectionView_Sprig = UICollectionView(frame: .zero, collectionViewLayout: layout_Sprig)
        super.init(coder: coder)
    }

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Sprig()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Sprig()
        registerNotifications_Sprig()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变层尺寸
        gradientLayer_Sprig.frame = headerContainer_Sprig.bounds
        refreshCellSize_Sprig()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func buildUI_Sprig() {
        view.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        buildHeader_Sprig()
        buildTabBar_Sprig()
        buildCollectionView_Sprig()
        buildEmptyState_Sprig()
    }

    /// 搭建渐变头部区域（装饰圆 + 头像 + 昵称 + 简介 + 3项统计 + 编辑按钮）
    private func buildHeader_Sprig() {
        // 渐变背景（薰衣草紫 → 天空蓝）
        gradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        headerContainer_Sprig.layer.insertSublayer(gradientLayer_Sprig, at: 0)
        view.addSubview(headerContainer_Sprig)
        headerContainer_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(headerContentHeight_Sprig)
        }

        // 装饰圆 1（右上，较大）
        headerDecorCircle1_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        headerDecorCircle1_Sprig.layer.cornerRadius = 72
        headerContainer_Sprig.addSubview(headerDecorCircle1_Sprig)
        headerDecorCircle1_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(-28)
            make.width.height.equalTo(144)
        }

        // 装饰圆 2（左下，中型）
        headerDecorCircle2_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        headerDecorCircle2_Sprig.layer.cornerRadius = 50
        headerContainer_Sprig.addSubview(headerDecorCircle2_Sprig)
        headerDecorCircle2_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(20)
            make.width.height.equalTo(100)
        }

        // 装饰圆 3（中右，小型）
        headerDecorCircle3_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        headerDecorCircle3_Sprig.layer.cornerRadius = 24
        headerContainer_Sprig.addSubview(headerDecorCircle3_Sprig)
        headerDecorCircle3_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }

        // 设置齿轮按钮（右上角）
        let gearBg_Sprig = UIView()
        gearBg_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        gearBg_Sprig.layer.cornerRadius = 18
        headerContainer_Sprig.addSubview(gearBg_Sprig)
        gearBg_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        let gearConfig_Sprig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        settingsButton_Sprig.setImage(
            UIImage(systemName: "gearshape.fill", withConfiguration: gearConfig_Sprig), for: .normal
        )
        settingsButton_Sprig.tintColor = .white
        settingsButton_Sprig.addTarget(self, action: #selector(onSettingsTapped_Sprig), for: .touchUpInside)
        headerContainer_Sprig.addSubview(settingsButton_Sprig)
        settingsButton_Sprig.snp.makeConstraints { make in
            make.edges.equalTo(gearBg_Sprig)
        }

        // 头像外圈装饰环（双圈）
        let outerRing_Sprig = UIView()
        outerRing_Sprig.backgroundColor = .clear
        outerRing_Sprig.layer.borderWidth = 2
        outerRing_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        outerRing_Sprig.layer.cornerRadius = 54
        headerContainer_Sprig.addSubview(outerRing_Sprig)
        outerRing_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(108)
        }

        let innerRing_Sprig = UIView()
        innerRing_Sprig.backgroundColor = .clear
        innerRing_Sprig.layer.borderWidth = 2.5
        innerRing_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.60).cgColor
        innerRing_Sprig.layer.cornerRadius = 48
        headerContainer_Sprig.addSubview(innerRing_Sprig)
        innerRing_Sprig.snp.makeConstraints { make in
            make.center.equalTo(outerRing_Sprig)
            make.width.height.equalTo(96)
        }

        // 头像（禁用编辑按钮，仅展示）
        avatarView_Sprig.showEditButton_Sprig = false
        headerContainer_Sprig.addSubview(avatarView_Sprig)
        avatarView_Sprig.snp.makeConstraints { make in
            make.center.equalTo(outerRing_Sprig)
            make.width.height.equalTo(86)
        }

        // 昵称（带星形装饰图标）
        let nameStack_Sprig = UIStackView()
        nameStack_Sprig.axis = .horizontal
        nameStack_Sprig.spacing = 6
        nameStack_Sprig.alignment = .center

        let sparkleImg_Sprig = UIImageView()
        let sparkleCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        sparkleImg_Sprig.image = UIImage(systemName: "sparkles", withConfiguration: sparkleCfg_Sprig)
        sparkleImg_Sprig.tintColor = UIColor.white.withAlphaComponent(0.85)
        sparkleImg_Sprig.contentMode = .scaleAspectFit
        sparkleImg_Sprig.snp.makeConstraints { make in make.width.height.equalTo(16) }

        nameLabel_Sprig.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nameLabel_Sprig.textColor = .white
        nameLabel_Sprig.textAlignment = .center

        nameStack_Sprig.addArrangedSubview(sparkleImg_Sprig)
        nameStack_Sprig.addArrangedSubview(nameLabel_Sprig)
        headerContainer_Sprig.addSubview(nameStack_Sprig)
        nameStack_Sprig.snp.makeConstraints { make in
            make.top.equalTo(outerRing_Sprig.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }

        // 简介（斜体，半透明）
        bioLabel_Sprig.font = UIFont.italicSystemFont(ofSize: 13)
        bioLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.78)
        bioLabel_Sprig.textAlignment = .center
        bioLabel_Sprig.numberOfLines = 2
        headerContainer_Sprig.addSubview(bioLabel_Sprig)
        bioLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(nameStack_Sprig.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(32)
        }

        // 统计数据背景毛玻璃卡片（3项：Followers | Following | Posts）
        let statsCard_Sprig = UIView()
        statsCard_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        statsCard_Sprig.layer.cornerRadius = 18
        statsCard_Sprig.layer.borderWidth = 1
        statsCard_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor
        headerContainer_Sprig.addSubview(statsCard_Sprig)
        statsCard_Sprig.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Sprig.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(56)
        }

        // 竖线分隔符 1
        let divider1_Sprig = UIView()
        divider1_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        statsCard_Sprig.addSubview(divider1_Sprig)
        divider1_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-50)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }

        // 竖线分隔符 2
        let divider2_Sprig = UIView()
        divider2_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        statsCard_Sprig.addSubview(divider2_Sprig)
        divider2_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(50)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }

        // 粉丝数（Followers）
        statsCard_Sprig.addSubview(followersStatView_Sprig)
        followersStatView_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(divider1_Sprig.snp.left)
            make.top.bottom.equalToSuperview()
        }

        // 关注数（Following）
        statsCard_Sprig.addSubview(followingStatView_Sprig)
        followingStatView_Sprig.snp.makeConstraints { make in
            make.left.equalTo(divider1_Sprig.snp.right)
            make.right.equalTo(divider2_Sprig.snp.left)
            make.top.bottom.equalToSuperview()
        }

        // 帖子数（Posts）
        statsCard_Sprig.addSubview(postsStatView_Sprig)
        postsStatView_Sprig.snp.makeConstraints { make in
            make.left.equalTo(divider2_Sprig.snp.right)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        // 编辑资料按钮（带铅笔图标）
        editProfileButton_Sprig.setTitle("  Edit Profile", for: .normal)
        editProfileButton_Sprig.setTitleColor(.white, for: .normal)
        editProfileButton_Sprig.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let editCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        editProfileButton_Sprig.setImage(UIImage(systemName: "pencil.circle.fill", withConfiguration: editCfg_Sprig), for: .normal)
        editProfileButton_Sprig.tintColor = .white
        editProfileButton_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        editProfileButton_Sprig.layer.cornerRadius = 18
        editProfileButton_Sprig.layer.borderWidth = 1.5
        editProfileButton_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        editProfileButton_Sprig.addTarget(self, action: #selector(onEditProfileTapped_Sprig), for: .touchUpInside)
        headerContainer_Sprig.addSubview(editProfileButton_Sprig)
        editProfileButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Sprig.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(148)
            make.height.equalTo(36)
        }
    }

    /// 搭建胶囊式 Tab 栏（Posts / Liked）
    private func buildTabBar_Sprig() {
        // 外层灰色胶囊容器
        tabCapsuleContainer_Sprig.backgroundColor = UIColor(hexstring_Sprig: "#EDEEF2")
        tabCapsuleContainer_Sprig.layer.cornerRadius = 22
        view.addSubview(tabCapsuleContainer_Sprig)
        tabCapsuleContainer_Sprig.snp.makeConstraints { make in
            make.top.equalTo(headerContainer_Sprig.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(220)
            make.height.equalTo(44)
        }

        // 选中态渐变胶囊（位于按钮之下）
        tabActivateGradient_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        tabActivateGradient_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
        tabActivateGradient_Sprig.endPoint = CGPoint(x: 1, y: 0.5)
        tabActivateGradient_Sprig.cornerRadius = 19
        tabActiveIndicator_Sprig.layer.cornerRadius = 19
        tabActiveIndicator_Sprig.clipsToBounds = true
        tabActiveIndicator_Sprig.layer.insertSublayer(tabActivateGradient_Sprig, at: 0)
        // 阴影（让选中胶囊浮起来）
        tabActiveIndicator_Sprig.layer.shadowColor = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        tabActiveIndicator_Sprig.layer.shadowOffset = CGSize(width: 0, height: 3)
        tabActiveIndicator_Sprig.layer.shadowOpacity = 0.35
        tabActiveIndicator_Sprig.layer.shadowRadius = 6
        tabCapsuleContainer_Sprig.addSubview(tabActiveIndicator_Sprig)
        tabActiveIndicator_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-4)
        }

        // Posts 按钮（叠于指示器之上）
        postsTabBtn_Sprig.setTitle("Posts", for: .normal)
        postsTabBtn_Sprig.setTitleColor(.white, for: .normal)
        postsTabBtn_Sprig.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        postsTabBtn_Sprig.backgroundColor = .clear
        postsTabBtn_Sprig.addTarget(self, action: #selector(onPostsTabTapped_Sprig), for: .touchUpInside)
        tabCapsuleContainer_Sprig.addSubview(postsTabBtn_Sprig)
        postsTabBtn_Sprig.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        // Liked 按钮
        likedTabBtn_Sprig.setTitle("Liked", for: .normal)
        likedTabBtn_Sprig.setTitleColor(ColorConfig_Sprig.textSecondary_Sprig, for: .normal)
        likedTabBtn_Sprig.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        likedTabBtn_Sprig.backgroundColor = .clear
        likedTabBtn_Sprig.addTarget(self, action: #selector(onLikedTabTapped_Sprig), for: .touchUpInside)
        tabCapsuleContainer_Sprig.addSubview(likedTabBtn_Sprig)
        likedTabBtn_Sprig.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }

    /// 搭建帖子网格列表
    private func buildCollectionView_Sprig() {
        collectionView_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        collectionView_Sprig.delegate = self
        collectionView_Sprig.dataSource = self
        collectionView_Sprig.register(
            MePostCell_Sprig.self,
            forCellWithReuseIdentifier: MePostCell_Sprig.reuseId_Sprig
        )
        collectionView_Sprig.contentInset = UIEdgeInsets(
            top: Me_Sprig.cardGap_Sprig,
            left: Me_Sprig.cardGap_Sprig,
            bottom: Me_Sprig.cardGap_Sprig + 100,
            right: Me_Sprig.cardGap_Sprig
        )
        collectionView_Sprig.showsVerticalScrollIndicator = false
        view.addSubview(collectionView_Sprig)
        collectionView_Sprig.snp.makeConstraints { make in
            make.top.equalTo(tabCapsuleContainer_Sprig.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    /// 搭建空状态视图（无帖子时展示）
    private func buildEmptyState_Sprig() {
        emptyStateView_Sprig.isHidden = true
        view.addSubview(emptyStateView_Sprig)
        emptyStateView_Sprig.snp.makeConstraints { make in
            make.edges.equalTo(collectionView_Sprig)
        }

        // 图标
        let iconView_Sprig = UIImageView()
        let iconCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 52, weight: .thin)
        iconView_Sprig.image = UIImage(systemName: "rectangle.stack.badge.plus", withConfiguration: iconCfg_Sprig)
        iconView_Sprig.tintColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.5)
        iconView_Sprig.contentMode = .scaleAspectFit
        emptyStateView_Sprig.addSubview(iconView_Sprig)
        iconView_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(68)
        }

        // 主提示文字
        let emptyTitleLabel_Sprig = UILabel()
        emptyTitleLabel_Sprig.text = "Nothing here yet"
        emptyTitleLabel_Sprig.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        emptyTitleLabel_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        emptyTitleLabel_Sprig.textAlignment = .center
        emptyStateView_Sprig.addSubview(emptyTitleLabel_Sprig)
        emptyTitleLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(iconView_Sprig.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        // 副提示文字
        let emptySubLabel_Sprig = UILabel()
        emptySubLabel_Sprig.text = "Posts you publish or like\nwill appear here."
        emptySubLabel_Sprig.font = UIFont.systemFont(ofSize: 13)
        emptySubLabel_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        emptySubLabel_Sprig.textAlignment = .center
        emptySubLabel_Sprig.numberOfLines = 2
        emptyStateView_Sprig.addSubview(emptySubLabel_Sprig)
        emptySubLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Sprig.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        }
    }

    // MARK: - 数据加载

    /// 加载并刷新页面数据（头像、昵称、简介、3项统计、帖子列表）
    private func loadData_Sprig() {
        let user_Sprig = meModel_Sprig ?? UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig()

        // 个人信息
        nameLabel_Sprig.text = user_Sprig.userName_Sprig ?? "Sprigger"
        let bio_Sprig = user_Sprig.userIntroduce_Sprig ?? ""
        bioLabel_Sprig.text = bio_Sprig.isEmpty ? "No bio yet..." : bio_Sprig

        // 3项统计数据
        followersStatView_Sprig.configure_Sprig(count_Sprig: user_Sprig.userFansCount_Sprig, title_Sprig: "Followers")
        followingStatView_Sprig.configure_Sprig(count_Sprig: user_Sprig.userFollow_Sprig.count, title_Sprig: "Following")
        postsStatView_Sprig.configure_Sprig(count_Sprig: user_Sprig.userPosts_Sprig.count, title_Sprig: "Posts")

        // 帖子列表
        switch currentTab_Sprig {
        case .posts_Sprig:  displayPosts_Sprig = user_Sprig.userPosts_Sprig
        case .liked_Sprig:  displayPosts_Sprig = user_Sprig.userLike_Sprig
        }
        collectionView_Sprig.reloadData()

        // 空状态显示控制
        emptyStateView_Sprig.isHidden = !displayPosts_Sprig.isEmpty
    }

    // MARK: - 通知注册

    private func registerNotifications_Sprig() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onStateChanged_Sprig),
            name: UserViewModel_Sprig.userStateDidChangeNotification_Sprig, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onStateChanged_Sprig),
            name: TitleViewModel_Sprig.titleStateDidChangeNotification_Sprig, object: nil
        )
    }

    @objc private func onStateChanged_Sprig() {
        loadData_Sprig()
    }

    // MARK: - Tab 切换

    @objc private func onPostsTabTapped_Sprig() {
        guard currentTab_Sprig != .posts_Sprig else { return }
        currentTab_Sprig = .posts_Sprig
        updateTabAppearance_Sprig(isPostsSelected_Sprig: true)
        loadData_Sprig()
    }

    @objc private func onLikedTabTapped_Sprig() {
        guard currentTab_Sprig != .liked_Sprig else { return }
        currentTab_Sprig = .liked_Sprig
        updateTabAppearance_Sprig(isPostsSelected_Sprig: false)
        loadData_Sprig()
    }

    /// 更新 Tab 栏视觉状态：滑动渐变胶囊指示器并切换文字颜色 / 字重
    /// - Parameter isPostsSelected_Sprig: true 为 Posts 选中，false 为 Liked 选中
    private func updateTabAppearance_Sprig(isPostsSelected_Sprig: Bool) {
        // 文字颜色 & 字重
        postsTabBtn_Sprig.setTitleColor(
            isPostsSelected_Sprig ? .white : ColorConfig_Sprig.textSecondary_Sprig, for: .normal
        )
        postsTabBtn_Sprig.titleLabel?.font = UIFont.systemFont(
            ofSize: 14, weight: isPostsSelected_Sprig ? .semibold : .regular
        )
        likedTabBtn_Sprig.setTitleColor(
            isPostsSelected_Sprig ? ColorConfig_Sprig.textSecondary_Sprig : .white, for: .normal
        )
        likedTabBtn_Sprig.titleLabel?.font = UIFont.systemFont(
            ofSize: 14, weight: isPostsSelected_Sprig ? .regular : .semibold
        )

        // 重新约束选中胶囊位置（弹簧动画滑动）
        tabActiveIndicator_Sprig.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-4)
            if isPostsSelected_Sprig {
                make.left.equalToSuperview().offset(4)
            } else {
                make.right.equalToSuperview().offset(-4)
            }
        }
        UIView.animate(
            withDuration: 0.32, delay: 0,
            usingSpringWithDamping: 0.78, initialSpringVelocity: 0.6,
            options: [], animations: { self.tabCapsuleContainer_Sprig.layoutIfNeeded() }
        )
    }

    // MARK: - 按钮事件

    @objc private func onSettingsTapped_Sprig() {
        settingsButton_Sprig.animatePressDown_Sprig { self.settingsButton_Sprig.animatePressUp_Sprig() }
        Navigation_Sprig.toSetting_Sprig()
    }

    @objc private func onEditProfileTapped_Sprig() {
        editProfileButton_Sprig.animatePressDown_Sprig { self.editProfileButton_Sprig.animatePressUp_Sprig() }
        Navigation_Sprig.toEditInfo_Sprig()
    }

    // MARK: - 工具方法

    /// 根据可用宽度刷新 Cell 尺寸，并同步更新渐变层
    private func refreshCellSize_Sprig() {
        guard let layout_Sprig = collectionView_Sprig.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let gap_Sprig = Me_Sprig.cardGap_Sprig
        let availableWidth_Sprig = collectionView_Sprig.bounds.width - gap_Sprig * 3
        let cellWidth_Sprig = floor(availableWidth_Sprig / 2)
        let cellHeight_Sprig = cellWidth_Sprig * 1.38
        let newSize_Sprig = CGSize(width: cellWidth_Sprig, height: cellHeight_Sprig)
        if layout_Sprig.itemSize != newSize_Sprig {
            layout_Sprig.itemSize = newSize_Sprig
        }
        // 同步更新选中胶囊内渐变层尺寸
        tabActivateGradient_Sprig.frame = tabActiveIndicator_Sprig.bounds
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension Me_Sprig: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Sprig.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Sprig = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Sprig.reuseId_Sprig, for: indexPath
        ) as! MePostCell_Sprig
        let post_Sprig = displayPosts_Sprig[indexPath.item]
        cell_Sprig.configure_Sprig(post_Sprig: post_Sprig, vc_Sprig: self) { [weak self] in
            self?.loadData_Sprig()
        }
        return cell_Sprig
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Sprig = displayPosts_Sprig[indexPath.item]
        Navigation_Sprig.toTitleDetail_Sprig(titleModel_sprig: post_Sprig)
    }
}

// MARK: - 统计数据视图

/// 个人主页统计数据小组件
/// 功能：展示单项数据（如 Followers / Following / Posts）
/// 属性：数字 Label（粗体白色）+ 标题 Label（细体半透明白色）
class MeStatView_Sprig: UIView {

    // MARK: - UI 组件

    private let countLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_Sprig.textColor = .white
        label_Sprig.textAlignment = .center
        return label_Sprig
    }()

    private let titleLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label_Sprig.textColor = UIColor.white.withAlphaComponent(0.72)
        label_Sprig.textAlignment = .center
        return label_Sprig
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack_Sprig = UIStackView(arrangedSubviews: [countLabel_Sprig, titleLabel_Sprig])
        stack_Sprig.axis = .vertical
        stack_Sprig.alignment = .center
        stack_Sprig.spacing = 2
        addSubview(stack_Sprig)
        stack_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 配置

    /// 配置显示的数值和标题
    /// - Parameters:
    ///   - count_Sprig: 统计数量
    ///   - title_Sprig: 标题文字（英文）
    func configure_Sprig(count_Sprig: Int, title_Sprig: String) {
        // 超过 9999 时缩写显示（如 10K）
        if count_Sprig >= 10_000 {
            countLabel_Sprig.text = "\(count_Sprig / 1000)K"
        } else {
            countLabel_Sprig.text = "\(count_Sprig)"
        }
        titleLabel_Sprig.text = title_Sprig
    }
}

// MARK: - 帖子卡片单元格

/// 帖子卡片 Cell
/// 功能：展示帖子封面图、标题、点赞数；右上角提供举报/删除操作按钮
/// 设计：圆角白色卡片 + 渐变封面 + 左侧彩色边条 + 底部信息区
class MePostCell_Sprig: UICollectionViewCell {

    // MARK: - 复用标识

    static let reuseId_Sprig = "MePostCell_Sprig"

    // MARK: - UI 组件

    /// 内容卡片（负责圆角裁剪）
    private let cardView_Sprig: UIView = {
        let v_Sprig = UIView()
        v_Sprig.backgroundColor = .white
        v_Sprig.layer.cornerRadius = 16
        v_Sprig.clipsToBounds = true
        return v_Sprig
    }()

    /// 封面媒体展示视图（使用通用媒体组件，支持图片/视频/SF Symbol/占位符）
    private let coverMediaView_Sprig = MediaDisplayView_Sprig()

    /// 底部信息区
    private let infoView_Sprig = UIView()

    /// 帖子标题
    private let titleLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        label_Sprig.numberOfLines = 2
        return label_Sprig
    }()

    /// 点赞图标
    private let heartIconView_Sprig: UIImageView = {
        let iv_Sprig = UIImageView()
        let cfg_Sprig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        iv_Sprig.image = UIImage(systemName: "heart.fill", withConfiguration: cfg_Sprig)
        iv_Sprig.tintColor = ColorConfig_Sprig.secondaryGradientStart_Sprig
        iv_Sprig.contentMode = .scaleAspectFit
        return iv_Sprig
    }()

    /// 点赞数
    private let likeCountLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.font = UIFont.systemFont(ofSize: 11)
        label_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        return label_Sprig
    }()

    /// 操作按钮（举报 / 删除）
    private let actionBtn_Sprig: UIButton = {
        let btn_Sprig = UIButton(type: .system)
        let cfg_Sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn_Sprig.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Sprig), for: .normal)
        btn_Sprig.tintColor = .white
        btn_Sprig.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn_Sprig.layer.cornerRadius = 13
        return btn_Sprig
    }()

    // MARK: - 属性

    private var post_Sprig: TitleModel_Sprig?
    private weak var vc_Sprig: UIViewController?
    private var onAction_Sprig: (() -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Sprig()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // MediaDisplayView_Sprig 内部自行管理渐变层，此处只需更新外层阴影路径
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: bounds, cornerRadius: 16
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置媒体视图至占位状态
        coverMediaView_Sprig.configure_Sprig(mediaPath_Sprig: nil)
        post_Sprig = nil
        vc_Sprig = nil
        onAction_Sprig = nil
    }

    // MARK: - UI 搭建

    private func buildUI_Sprig() {
        // contentView 负责外层阴影（不裁切）
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale

        // 卡片（内层裁切圆角）
        contentView.addSubview(cardView_Sprig)
        cardView_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 封面区：使用 MediaDisplayView_Sprig 统一处理图片/视频/SF Symbol/占位符
        cardView_Sprig.addSubview(coverMediaView_Sprig)
        coverMediaView_Sprig.layer.cornerRadius = 0  // 圆角由 cardView_Sprig 统一控制
        coverMediaView_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.65)
        }

        // 操作按钮（右上角）
        cardView_Sprig.addSubview(actionBtn_Sprig)
        actionBtn_Sprig.snp.makeConstraints { make in
            make.top.equalTo(coverMediaView_Sprig).inset(8)
            make.right.equalTo(coverMediaView_Sprig).inset(8)
            make.width.height.equalTo(26)
        }

        // 底部信息区
        infoView_Sprig.backgroundColor = .white
        cardView_Sprig.addSubview(infoView_Sprig)
        infoView_Sprig.snp.makeConstraints { make in
            make.top.equalTo(coverMediaView_Sprig.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        // 帖子标题
        infoView_Sprig.addSubview(titleLabel_Sprig)
        titleLabel_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(10)
        }

        // 点赞图标
        infoView_Sprig.addSubview(heartIconView_Sprig)
        heartIconView_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-8)
            make.top.greaterThanOrEqualTo(titleLabel_Sprig.snp.bottom).offset(4)
            make.width.height.equalTo(12)
        }

        // 点赞数
        infoView_Sprig.addSubview(likeCountLabel_Sprig)
        likeCountLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(heartIconView_Sprig.snp.right).offset(3)
            make.centerY.equalTo(heartIconView_Sprig)
        }
    }

    // MARK: - 配置

    /// 配置帖子卡片数据
    /// - Parameters:
    ///   - post_Sprig: 帖子数据模型
    ///   - vc_Sprig: 当前页面控制器（用于弹出 Alert）
    ///   - onAction_Sprig: 操作完成后的刷新回调
    func configure_Sprig(
        post_Sprig: TitleModel_Sprig,
        vc_Sprig: UIViewController,
        onAction_Sprig: @escaping () -> Void
    ) {
        self.post_Sprig = post_Sprig
        self.vc_Sprig = vc_Sprig
        self.onAction_Sprig = onAction_Sprig

        titleLabel_Sprig.text = post_Sprig.title_Sprig
        likeCountLabel_Sprig.text = "\(post_Sprig.likes_Sprig)"

        // 使用 MediaDisplayView_Sprig 加载封面（自动处理图片/视频/SF Symbol/占位符）
        coverMediaView_Sprig.configure_Sprig(mediaPath_Sprig: post_Sprig.titleMeidas_Sprig.first)

        // 配置操作按钮：自己帖子显示删除图标，他人帖子显示举报图标
        let isOwner_Sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: post_Sprig.titleUserId_Sprig
        )
        let iconName_Sprig = isOwner_Sprig ? "trash" : "ellipsis"
        let btnCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        actionBtn_Sprig.setImage(
            UIImage(systemName: iconName_Sprig, withConfiguration: btnCfg_Sprig), for: .normal
        )

        // 绑定操作事件（移除旧绑定避免重用问题）
        actionBtn_Sprig.removeTarget(nil, action: nil, for: .allEvents)
        actionBtn_Sprig.addAction(UIAction { [weak self] _ in
            guard let self,
                  let post_Sprig = self.post_Sprig,
                  let vc_Sprig = self.vc_Sprig else { return }
            self.actionBtn_Sprig.animatePulse_Sprig()
            if isOwner_Sprig {
                ReportDeleteHelper_Sprig.delete_Sprig(post_Sprig: post_Sprig, from: vc_Sprig) {
                    self.onAction_Sprig?()
                }
            } else {
                ReportDeleteHelper_Sprig.report_Sprig(post_Sprig: post_Sprig, from: vc_Sprig) {
                    self.onAction_Sprig?()
                }
            }
        }, for: .touchUpInside)
    }
}
