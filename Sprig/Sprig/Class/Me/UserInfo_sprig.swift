import Foundation
import UIKit
import SnapKit

// MARK: 用户中心（预制用户）

/// 用户中心页面
/// 功能：展示指定预制用户的个人信息（头像、昵称、简介、Followers/Following/Posts 统计），
///       支持关注/取消关注、通过 Replace 方式进入聊天、右上角举报/拉黑用户；
///       帖子列表支持点击进入详情、帖子右上角提供举报/删除操作
/// 布局：辅助渐变头部（装饰圆 + 返回 + 举报 + 头像 + 统计）→ 操作按钮行 → 帖子网格
class UserInfo_Sprig: UIViewController {
    
    // MARK: - 公共属性

    /// 外部传入的用户模型
    var userModel_Sprig: PrewUserModel_Sprig?

    // MARK: - 私有属性

    /// 该用户的帖子列表
    private var userPosts_Sprig: [TitleModel_Sprig] = []

    // MARK: - UI 组件 - 头部

    private let headerContainer_Sprig = UIView()
    private let headerGradientLayer_Sprig = CAGradientLayer()

    /// 用户头像（公共头像组件）
    private let avatarView_Sprig = UserAvatarView_Sprig()

    /// 用户昵称
    private let nameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 用户简介
    private let bioLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .italicSystemFont(ofSize: 12)
        l.textColor = UIColor.white.withAlphaComponent(0.78)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    /// 粉丝数统计组件
    private let followersStatView_Sprig = MeStatView_Sprig()
    /// 关注数统计组件
    private let followingStatView_Sprig = MeStatView_Sprig()
    /// 帖子数统计组件
    private let postsStatView_Sprig = MeStatView_Sprig()

    // MARK: - UI 组件 - 操作按钮行

    /// 操作按钮容器行
    private let actionRow_Sprig = UIView()

    /// 关注按钮容器（负责阴影）
    private let followBtnContainer_Sprig = UIView()
    /// 关注按钮渐变层
    private let followBtnGradient_Sprig = CAGradientLayer()
    /// 关注按钮
    private let followButton_Sprig = UIButton(type: .custom)

    /// 进入聊天按钮容器（负责阴影）
    private let chatBtnContainer_Sprig = UIView()
    /// 进入聊天按钮渐变层
    private let chatBtnGradient_Sprig = CAGradientLayer()
    /// 进入聊天按钮
    private let chatButton_Sprig = UIButton(type: .custom)

    // MARK: - UI 组件 - 帖子网格

    private let collectionView_Sprig: UICollectionView
    /// 空状态视图
    private let emptyStateView_Sprig = UIView()

    // MARK: - 常量

    /// 头部内容区固定高度
    private let headerContentHeight_Sprig: CGFloat = 320
    /// 操作按钮行高度
    private let actionRowHeight_Sprig: CGFloat = 72
    /// 卡片间距
    private static let cardGap_Sprig: CGFloat = 12

    // MARK: - 初始化

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout_Sprig = UICollectionViewFlowLayout()
        layout_Sprig.minimumInteritemSpacing = UserInfo_Sprig.cardGap_Sprig
        layout_Sprig.minimumLineSpacing = UserInfo_Sprig.cardGap_Sprig
        collectionView_Sprig = UICollectionView(frame: .zero, collectionViewLayout: layout_Sprig)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        let layout_Sprig = UICollectionViewFlowLayout()
        layout_Sprig.minimumInteritemSpacing = UserInfo_Sprig.cardGap_Sprig
        layout_Sprig.minimumLineSpacing = UserInfo_Sprig.cardGap_Sprig
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
        // 同步各渐变图层尺寸
        headerGradientLayer_Sprig.frame = headerContainer_Sprig.bounds
        followBtnGradient_Sprig.frame = followBtnContainer_Sprig.bounds
        chatBtnGradient_Sprig.frame = chatBtnContainer_Sprig.bounds
        refreshCellSize_Sprig()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 数据加载

    /// 加载并刷新全部页面数据
    private func loadData_Sprig() {
        guard let user_sprig = userModel_Sprig else { return }

        // 基本信息
        nameLabel_Sprig.text = user_sprig.userName_Sprig ?? "User"
        bioLabel_Sprig.text = user_sprig.userIntroduce_Sprig.flatMap { $0.isEmpty ? nil : $0 } ?? "No bio yet."

        // 配置头像
        if let uid_sprig = user_sprig.userId_Sprig {
            avatarView_Sprig.configure_Sprig(userId_Sprig: uid_sprig)
        }

        // 获取帖子列表
        userPosts_Sprig = TitleViewModel_Sprig.shared_Sprig.getUserPosts_Sprig(user_sprig: user_sprig)

        // 统计数据
        followersStatView_Sprig.configure_Sprig(count_Sprig: user_sprig.userFans_Sprig ?? 0,    title_Sprig: "Followers")
        followingStatView_Sprig.configure_Sprig(count_Sprig: user_sprig.userFollow_Sprig ?? 0,  title_Sprig: "Following")
        postsStatView_Sprig.configure_Sprig(count_Sprig: userPosts_Sprig.count,                 title_Sprig: "Posts")

        // 更新关注按钮状态
        updateFollowButtonState_Sprig()

        // 刷新帖子列表
        emptyStateView_Sprig.isHidden = !userPosts_Sprig.isEmpty
        collectionView_Sprig.reloadData()
    }

    // MARK: - UI 搭建

    private func buildUI_Sprig() {
        view.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        buildHeader_Sprig()
        buildActionRow_Sprig()
        buildCollectionView_Sprig()
        buildEmptyState_Sprig()
    }

    /// 搭建渐变头部（辅助渐变 + 装饰圆 + 返回/举报按钮 + 头像双环 + 昵称/简介 + 统计卡片）
    private func buildHeader_Sprig() {
        // 辅助渐变（玫瑰粉 → 珊瑚橙），区别于登录用户页的主色渐变
        headerGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.secondaryGradientEnd_Sprig.cgColor
        ]
        headerGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Sprig.endPoint   = CGPoint(x: 1, y: 1)
        headerContainer_Sprig.layer.insertSublayer(headerGradientLayer_Sprig, at: 0)

        view.addSubview(headerContainer_Sprig)
        headerContainer_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(headerContentHeight_Sprig)
        }

        // 装饰圆 1（右上，较大）
        let circle1_Sprig = makeDecoCircle_Sprig(alpha_Sprig: 0.10, radius_Sprig: 72)
        headerContainer_Sprig.addSubview(circle1_Sprig)
        circle1_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(-28)
            make.width.height.equalTo(144)
        }

        // 装饰圆 2（左下，中型）
        let circle2_Sprig = makeDecoCircle_Sprig(alpha_Sprig: 0.07, radius_Sprig: 50)
        headerContainer_Sprig.addSubview(circle2_Sprig)
        circle2_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(24)
            make.width.height.equalTo(100)
        }

        // 装饰圆 3（中右，小型）
        let circle3_Sprig = makeDecoCircle_Sprig(alpha_Sprig: 0.07, radius_Sprig: 26)
        headerContainer_Sprig.addSubview(circle3_Sprig)
        circle3_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-28)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }

        // 返回按钮（左上角，毛玻璃风格）
        let backBg_Sprig = makeGlassBtn_Sprig()
        headerContainer_Sprig.addSubview(backBg_Sprig)
        backBg_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        let backBtn_Sprig = UIButton(type: .system)
        let backCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        backBtn_Sprig.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_Sprig), for: .normal)
        backBtn_Sprig.tintColor = .white
        backBtn_Sprig.addTarget(self, action: #selector(onBackTapped_Sprig), for: .touchUpInside)
        headerContainer_Sprig.addSubview(backBtn_Sprig)
        backBtn_Sprig.snp.makeConstraints { make in make.edges.equalTo(backBg_Sprig) }

        // 举报按钮（右上角，毛玻璃风格）
        let reportBg_Sprig = makeGlassBtn_Sprig()
        headerContainer_Sprig.addSubview(reportBg_Sprig)
        reportBg_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        let reportBtn_Sprig = UIButton(type: .system)
        let reportCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        // 图标与帖子项右上角举报按钮保持一致，使用 ellipsis
        reportBtn_Sprig.setImage(UIImage(systemName: "ellipsis", withConfiguration: reportCfg_Sprig), for: .normal)
        reportBtn_Sprig.tintColor = .white
        reportBtn_Sprig.addTarget(self, action: #selector(onReportTapped_Sprig), for: .touchUpInside)
        headerContainer_Sprig.addSubview(reportBtn_Sprig)
        reportBtn_Sprig.snp.makeConstraints { make in make.edges.equalTo(reportBg_Sprig) }

        // 头像外圈装饰（双环）
        let outerRing_Sprig = UIView()
        outerRing_Sprig.backgroundColor = .clear
        outerRing_Sprig.layer.borderWidth = 2
        outerRing_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        outerRing_Sprig.layer.cornerRadius = 50
        headerContainer_Sprig.addSubview(outerRing_Sprig)
        outerRing_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        let innerRing_Sprig = UIView()
        innerRing_Sprig.backgroundColor = .clear
        innerRing_Sprig.layer.borderWidth = 2.5
        innerRing_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.60).cgColor
        innerRing_Sprig.layer.cornerRadius = 44
        headerContainer_Sprig.addSubview(innerRing_Sprig)
        innerRing_Sprig.snp.makeConstraints { make in
            make.center.equalTo(outerRing_Sprig)
            make.width.height.equalTo(88)
        }

        // 用户头像
        avatarView_Sprig.layer.cornerRadius = 40
        avatarView_Sprig.clipsToBounds = true
        headerContainer_Sprig.addSubview(avatarView_Sprig)
        avatarView_Sprig.snp.makeConstraints { make in
            make.center.equalTo(outerRing_Sprig)
            make.width.height.equalTo(80)
        }

        // 昵称（带闪光图标）
        let nameStack_Sprig = UIStackView()
        nameStack_Sprig.axis = .horizontal
        nameStack_Sprig.spacing = 6
        nameStack_Sprig.alignment = .center

        let sparkle_Sprig = UIImageView()
        let sparkleCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        sparkle_Sprig.image = UIImage(systemName: "sparkles", withConfiguration: sparkleCfg_Sprig)
        sparkle_Sprig.tintColor = UIColor.white.withAlphaComponent(0.85)
        sparkle_Sprig.contentMode = .scaleAspectFit
        sparkle_Sprig.snp.makeConstraints { make in make.width.height.equalTo(16) }

        nameStack_Sprig.addArrangedSubview(sparkle_Sprig)
        nameStack_Sprig.addArrangedSubview(nameLabel_Sprig)
        headerContainer_Sprig.addSubview(nameStack_Sprig)
        nameStack_Sprig.snp.makeConstraints { make in
            make.top.equalTo(outerRing_Sprig.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }

        // 简介（斜体，半透明白色）
        headerContainer_Sprig.addSubview(bioLabel_Sprig)
        bioLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(nameStack_Sprig.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(32)
        }

        // 统计数据毛玻璃卡片（Followers | Following | Posts）
        let statsCard_Sprig = UIView()
        statsCard_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        statsCard_Sprig.layer.cornerRadius = 18
        statsCard_Sprig.layer.borderWidth  = 1
        statsCard_Sprig.layer.borderColor  = UIColor.white.withAlphaComponent(0.22).cgColor
        headerContainer_Sprig.addSubview(statsCard_Sprig)
        statsCard_Sprig.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Sprig.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(56)
        }

        // 竖线分隔符 1
        let div1_Sprig = UIView()
        div1_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        statsCard_Sprig.addSubview(div1_Sprig)
        div1_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-50)
            make.centerY.equalToSuperview()
            make.width.equalTo(1); make.height.equalTo(28)
        }

        // 竖线分隔符 2
        let div2_Sprig = UIView()
        div2_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        statsCard_Sprig.addSubview(div2_Sprig)
        div2_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(50)
            make.centerY.equalToSuperview()
            make.width.equalTo(1); make.height.equalTo(28)
        }

        // 三项统计组件
        statsCard_Sprig.addSubview(followersStatView_Sprig)
        statsCard_Sprig.addSubview(followingStatView_Sprig)
        statsCard_Sprig.addSubview(postsStatView_Sprig)
        followersStatView_Sprig.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview(); make.right.equalTo(div1_Sprig.snp.left)
        }
        followingStatView_Sprig.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(div1_Sprig.snp.right); make.right.equalTo(div2_Sprig.snp.left)
        }
        postsStatView_Sprig.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(div2_Sprig.snp.right); make.right.equalToSuperview()
        }
    }

    /// 搭建操作按钮行（关注 + 进入聊天，白色背景区）
    private func buildActionRow_Sprig() {
        actionRow_Sprig.backgroundColor = .white

        // 顶部分割线
        let topLine_Sprig = UIView()
        topLine_Sprig.backgroundColor = ColorConfig_Sprig.divider_Sprig

        view.addSubview(actionRow_Sprig)
        actionRow_Sprig.snp.makeConstraints { make in
            make.top.equalTo(headerContainer_Sprig.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(actionRowHeight_Sprig)
        }

        actionRow_Sprig.addSubview(topLine_Sprig)
        topLine_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        // 关注按钮（主色渐变：薰衣草紫 → 天空蓝）
        followBtnContainer_Sprig.layer.cornerRadius = 22
        followBtnContainer_Sprig.layer.masksToBounds = false
        followBtnContainer_Sprig.layer.shadowColor   = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        followBtnContainer_Sprig.layer.shadowOffset  = CGSize(width: 0, height: 4)
        followBtnContainer_Sprig.layer.shadowRadius  = 10
        followBtnContainer_Sprig.layer.shadowOpacity = 0.28

        followBtnGradient_Sprig.colors      = [ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor, ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor]
        followBtnGradient_Sprig.startPoint  = CGPoint(x: 0, y: 0)
        followBtnGradient_Sprig.endPoint    = CGPoint(x: 1, y: 0)
        followBtnGradient_Sprig.cornerRadius = 22
        followBtnContainer_Sprig.layer.insertSublayer(followBtnGradient_Sprig, at: 0)

        let followSym_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        followButton_Sprig.setImage(UIImage(systemName: "person.badge.plus", withConfiguration: followSym_Sprig), for: .normal)
        followButton_Sprig.setTitle("  Follow", for: .normal)
        followButton_Sprig.tintColor = .white
        followButton_Sprig.setTitleColor(.white, for: .normal)
        followButton_Sprig.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        followButton_Sprig.addTarget(self, action: #selector(onFollowTapped_Sprig), for: .touchUpInside)
        followBtnContainer_Sprig.addSubview(followButton_Sprig)
        followButton_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 进入聊天按钮（辅助渐变：玫瑰粉 → 珊瑚橙）
        chatBtnContainer_Sprig.layer.cornerRadius = 22
        chatBtnContainer_Sprig.layer.masksToBounds = false
        chatBtnContainer_Sprig.layer.shadowColor   = ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor
        chatBtnContainer_Sprig.layer.shadowOffset  = CGSize(width: 0, height: 4)
        chatBtnContainer_Sprig.layer.shadowRadius  = 10
        chatBtnContainer_Sprig.layer.shadowOpacity = 0.28

        chatBtnGradient_Sprig.colors      = [ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor, ColorConfig_Sprig.secondaryGradientEnd_Sprig.cgColor]
        chatBtnGradient_Sprig.startPoint  = CGPoint(x: 0, y: 0)
        chatBtnGradient_Sprig.endPoint    = CGPoint(x: 1, y: 0)
        chatBtnGradient_Sprig.cornerRadius = 22
        chatBtnContainer_Sprig.layer.insertSublayer(chatBtnGradient_Sprig, at: 0)

        let chatSym_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chatButton_Sprig.setImage(UIImage(systemName: "bubble.left.fill", withConfiguration: chatSym_Sprig), for: .normal)
        chatButton_Sprig.setTitle("  Message", for: .normal)
        chatButton_Sprig.tintColor = .white
        chatButton_Sprig.setTitleColor(.white, for: .normal)
        chatButton_Sprig.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        chatButton_Sprig.addTarget(self, action: #selector(onChatTapped_Sprig), for: .touchUpInside)
        chatBtnContainer_Sprig.addSubview(chatButton_Sprig)
        chatButton_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        actionRow_Sprig.addSubview(followBtnContainer_Sprig)
        actionRow_Sprig.addSubview(chatBtnContainer_Sprig)
        followBtnContainer_Sprig.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(actionRow_Sprig.snp.centerX).offset(-8)
            make.height.equalTo(44)
        }
        chatBtnContainer_Sprig.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(actionRow_Sprig.snp.centerX).offset(8)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        // 底部分割线
        let bottomLine_Sprig = UIView()
        bottomLine_Sprig.backgroundColor = ColorConfig_Sprig.divider_Sprig
        actionRow_Sprig.addSubview(bottomLine_Sprig)
        bottomLine_Sprig.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    /// 搭建帖子网格 CollectionView
    private func buildCollectionView_Sprig() {
        collectionView_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        collectionView_Sprig.showsVerticalScrollIndicator = false
        collectionView_Sprig.contentInset = UIEdgeInsets(
            top: 12,
            left: UserInfo_Sprig.cardGap_Sprig,
            bottom: 24,
            right: UserInfo_Sprig.cardGap_Sprig
        )
        collectionView_Sprig.register(MePostCell_Sprig.self, forCellWithReuseIdentifier: MePostCell_Sprig.reuseId_Sprig)
        collectionView_Sprig.delegate   = self
        collectionView_Sprig.dataSource = self

        view.addSubview(collectionView_Sprig)
        collectionView_Sprig.snp.makeConstraints { make in
            make.top.equalTo(actionRow_Sprig.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    /// 搭建空状态视图（无帖子时显示）
    private func buildEmptyState_Sprig() {
        let iconView_Sprig = UIImageView()
        let iconCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        iconView_Sprig.image = UIImage(systemName: "newspaper", withConfiguration: iconCfg_Sprig)
        iconView_Sprig.tintColor = ColorConfig_Sprig.secondaryGradientStart_Sprig.withAlphaComponent(0.45)
        iconView_Sprig.contentMode = .scaleAspectFit

        let tipLabel_Sprig = UILabel()
        tipLabel_Sprig.text = "No posts yet 🌸"
        tipLabel_Sprig.font = .systemFont(ofSize: 14)
        tipLabel_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        tipLabel_Sprig.textAlignment = .center

        emptyStateView_Sprig.addSubview(iconView_Sprig)
        emptyStateView_Sprig.addSubview(tipLabel_Sprig)
        iconView_Sprig.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        tipLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(iconView_Sprig.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        collectionView_Sprig.addSubview(emptyStateView_Sprig)
        emptyStateView_Sprig.snp.makeConstraints { make in
            make.center.equalTo(collectionView_Sprig.frameLayoutGuide)
        }
        emptyStateView_Sprig.isHidden = true
    }

    // MARK: - 通知

    /// 注册状态变更通知
    private func registerNotifications_Sprig() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChanged_Sprig),
            name: TitleViewModel_Sprig.titleStateDidChangeNotification_Sprig,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserStateChanged_Sprig),
            name: UserViewModel_Sprig.userStateDidChangeNotification_Sprig,
            object: nil
        )
    }

    /// 帖子状态变更时刷新列表
    @objc private func onTitleStateChanged_Sprig() { loadData_Sprig() }

    /// 用户状态变更时刷新关注按钮及统计数据
    @objc private func onUserStateChanged_Sprig() { loadData_Sprig() }

    // MARK: - 关注按钮状态更新

    /// 根据当前关注关系刷新关注按钮图标、文案及渐变色
    private func updateFollowButtonState_Sprig() {
        guard let user_sprig = userModel_Sprig else { return }
        let isFollowing_sprig = UserViewModel_Sprig.shared_Sprig.isFollowing_Sprig(user_sprig: user_sprig)

        let symbol_sprig = isFollowing_sprig ? "person.badge.checkmark" : "person.badge.plus"
        let title_sprig  = isFollowing_sprig ? "  Followed"            : "  Follow"
        let symCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        followButton_Sprig.setImage(UIImage(systemName: symbol_sprig, withConfiguration: symCfg_Sprig), for: .normal)
        followButton_Sprig.setTitle(title_sprig, for: .normal)

        // 已关注：灰色调；未关注：主色渐变
        if isFollowing_sprig {
            followBtnGradient_Sprig.colors = [
                UIColor(hexstring_Sprig: "#A0AEC0").cgColor,
                UIColor(hexstring_Sprig: "#CBD5E0").cgColor
            ]
            followBtnContainer_Sprig.layer.shadowColor = UIColor(hexstring_Sprig: "#A0AEC0").cgColor
        } else {
            followBtnGradient_Sprig.colors = [
                ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
                ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
            ]
            followBtnContainer_Sprig.layer.shadowColor = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        }
    }

    // MARK: - 按钮事件

    /// 返回上一页
    @objc private func onBackTapped_Sprig() {
        Navigation_Sprig.pop_Sprig()
    }

    /// 举报/拉黑该用户
    /// 参数：无
    /// 说明：调用 ReportDeleteHelper 的 block 方法，成功后自动返回
    @objc private func onReportTapped_Sprig() {
        guard let user_sprig = userModel_Sprig else { return }
        ReportDeleteHelper_Sprig.block_Sprig(user_Sprig: user_sprig, from: self) {
            Navigation_Sprig.pop_Sprig()
        }
    }

    /// 关注/取消关注该用户
    @objc private func onFollowTapped_Sprig() {
        guard let user_sprig = userModel_Sprig else { return }
        followButton_Sprig.animatePulse_Sprig()
        UserViewModel_Sprig.shared_Sprig.followUser_Sprig(user_sprig: user_sprig)
    }

    /// 进入聊天页（Replace 方式，替换当前用户中心页）
    @objc private func onChatTapped_Sprig() {
        guard let user_sprig = userModel_Sprig else { return }
        chatButton_Sprig.animatePulse_Sprig()
        Navigation_Sprig.toMessageUser_Sprig(with: user_sprig, style_sprig: .replace_sprig)
    }

    // MARK: - 私有工具方法

    /// 创建装饰圆视图
    /// - Parameters:
    ///   - alpha_Sprig: 白色透明度
    ///   - radius_Sprig: 圆角半径
    /// - Returns: 配置好的 UIView
    private func makeDecoCircle_Sprig(alpha_Sprig: CGFloat, radius_Sprig: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha_Sprig)
        v.layer.cornerRadius = radius_Sprig
        v.isUserInteractionEnabled = false
        return v
    }

    /// 创建毛玻璃风格按钮背景视图（白色半透明圆形）
    /// - Returns: 配置好的 UIView
    private func makeGlassBtn_Sprig() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        v.layer.cornerRadius = 18
        v.layer.borderWidth  = 1
        v.layer.borderColor  = UIColor.white.withAlphaComponent(0.38).cgColor
        v.isUserInteractionEnabled = false
        return v
    }

    /// 根据可用宽度刷新 CollectionView Cell 尺寸
    private func refreshCellSize_Sprig() {
        guard let layout_Sprig = collectionView_Sprig.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let gap_Sprig           = UserInfo_Sprig.cardGap_Sprig
        let availableWidth_Sprig = collectionView_Sprig.bounds.width - gap_Sprig * 3
        let cellWidth_Sprig     = floor(availableWidth_Sprig / 2)
        let cellHeight_Sprig    = cellWidth_Sprig * 1.38
        let newSize_Sprig       = CGSize(width: cellWidth_Sprig, height: cellHeight_Sprig)
        if layout_Sprig.itemSize != newSize_Sprig {
            layout_Sprig.itemSize = newSize_Sprig
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension UserInfo_Sprig: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts_Sprig.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Sprig = collectionView.dequeueReusableCell(
            withReuseIdentifier: MePostCell_Sprig.reuseId_Sprig, for: indexPath
        ) as! MePostCell_Sprig
        let post_Sprig = userPosts_Sprig[indexPath.item]
        cell_Sprig.configure_Sprig(post_Sprig: post_Sprig, vc_Sprig: self) { [weak self] in
            self?.loadData_Sprig()
        }
        return cell_Sprig
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Sprig.toTitleDetail_Sprig(titleModel_sprig: userPosts_Sprig[indexPath.item])
    }
}
