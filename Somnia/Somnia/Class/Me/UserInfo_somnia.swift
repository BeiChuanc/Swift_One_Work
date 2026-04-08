import Foundation
import UIKit
import SnapKit

// MARK: 用户中心（预制用户）

/// 用户中心页面
/// 核心作用：展示指定用户的个人信息及帖子列表（两列瀑布流），提供关注/消息/举报入口
/// 设计思路：渐变头部 + 装饰浮球 + 渐变头像环 + 三项数据统计 + 两列帖子格栅
/// 关键属性：userModel_Somnia（目标用户）、isFromMessageChat_Somnia（是否从聊天进入）
class UserInfo_Somnia: UIViewController {

    // MARK: - 属性

    /// 目标用户模型
    var userModel_Somnia: PrewUserModel_Somnia?

    /// 是否从聊天页进入（隐藏消息按钮，取消关注时返回消息列表）
    var isFromMessageChat_Somnia: Bool = false

    // MARK: - 私有属性

    private var _posts_Somnia: [TitleModel_Somnia] = []

    /// 头部渐变图层
    private var _headerGradient_Somnia: CAGradientLayer?

    /// 头像外环渐变图层
    private var _avatarRingGradient_Somnia: CAGradientLayer?

    // MARK: - UI 滚动容器

    private let scrollView_Somnia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Somnia = UIView()

    // MARK: - 头部区域

    private let headerView_Somnia: UIView = {
        let v = UIView()
        // 不裁切子视图（避免按钮被圆角剪掉），圆角直接应用在渐变图层上
        v.clipsToBounds = false
        return v
    }()

    /// 返回按钮
    private let backButton_Somnia = BackButton_Somnia()

    /// 右上角举报按钮（圆形毛玻璃）
    private let reportButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 20
        return btn
    }()

    // MARK: - 头像（渐变外环 + 白色内边框 + 头像组件）

    /// 渐变外环（最外层，96pt）
    private let avatarRingView_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 48
        v.clipsToBounds = false
        return v
    }()

    /// 白色内边框（88pt）
    private let avatarBorderView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 44
        v.clipsToBounds = true
        return v
    }()

    /// 头像组件（80pt，使用 UserAvatarView_Somnia）
    private let avatarView_Somnia = UserAvatarView_Somnia()

    // MARK: - 用户信息文本

    private let nameLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0, height: 1)
        lbl.layer.shadowRadius = 4
        lbl.layer.shadowOpacity = 0.15
        return lbl
    }()

    private let introLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.85)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    // MARK: - 数据统计卡片（Following / Posts / Fans 三项）

    private let statsCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v.layer.cornerRadius = 20
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        v.layer.borderWidth = 1
        return v
    }()

    private let followStatView_Somnia = MeStatItem_Somnia(title_Somnia: "Following", icon_Somnia: "person.2.fill")
    private let postsStatView_Somnia  = MeStatItem_Somnia(title_Somnia: "Posts",     icon_Somnia: "square.grid.2x2.fill")
    private let fansStatView_Somnia   = MeStatItem_Somnia(title_Somnia: "Fans",      icon_Somnia: "heart.fill")

    // MARK: - 按钮行（关注 + 消息）

    private let buttonStack_Somnia: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 14
        sv.distribution = .fillEqually
        return sv
    }()

    private let followButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Follow", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor.white.cgColor
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        return btn
    }()

    private let messageButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Message", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(ColorConfig_Somnia.primaryGradientStart_Somnia, for: .normal)
        btn.layer.cornerRadius = 22
        btn.backgroundColor = .white
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 8
        btn.layer.shadowOpacity = 0.1
        return btn
    }()

    // MARK: - 帖子区（两列格栅 CollectionView）

    /// 帖子区头部标签行（白色卡片式，含左侧渐变强调条）
    private let postsSectionView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Somnia: "#7C3AED").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.layer.shadowOpacity = 0.05
        return v
    }()

    /// POSTS 左侧渐变强调竖条
    private let postsAccentBar_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()
    private var postsAccentBarGrad_Somnia: CAGradientLayer?

    private let postsSectionLabel_Somnia: UILabel = {
        let lbl = UILabel()
        let attr = NSMutableAttributedString(
            string: "POSTS",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .black),
                .foregroundColor: ColorConfig_Somnia.textPrimary_Somnia,
                .kern: 2.0
            ]
        )
        lbl.attributedText = attr
        return lbl
    }()

    private let postsCountBadge_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        lbl.textAlignment = .center
        // 使用品牌色软色填充，避免渐变层导致的 toggle 外观
        lbl.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.14)
        lbl.layer.cornerRadius = 10
        lbl.clipsToBounds = true
        return lbl
    }()

    /// 两列帖子格栅
    private lazy var collectionView_Somnia: UICollectionView = {
        let layout_Somnia = UICollectionViewFlowLayout()
        layout_Somnia.minimumLineSpacing = 12
        layout_Somnia.minimumInteritemSpacing = 12
        layout_Somnia.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout_Somnia)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.isScrollEnabled = false
        return cv
    }()

    /// 帖子空状态视图
    private let emptyStateView_Somnia: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshUI_Somnia()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupActions_Somnia()
        setupNotifications_Somnia()
        loadPosts_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _headerGradient_Somnia?.frame = headerView_Somnia.bounds
        updateAvatarRingGradient_Somnia()
        updateFollowButtonGradient_Somnia()
        updatePostsAccentBarGradient_Somnia()
        updateCollectionHeight_Somnia()
    }

    // MARK: - 私有方法 - UI设置

    private func setupUI_Somnia() {
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia

        // 禁止自动添加安全区内边距，确保头部渐变贴顶
        scrollView_Somnia.contentInsetAdjustmentBehavior = .never

        view.addSubview(scrollView_Somnia)
        scrollView_Somnia.addSubview(contentView_Somnia)
        contentView_Somnia.addSubview(headerView_Somnia)

        // 头部渐变背景（3色：#C4B5FD → primaryStart → primaryEnd）
        // 圆角直接设置在渐变图层，避免 clipsToBounds 裁切底部按钮
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.colors = [
            UIColor(hexstring_Somnia: "#C4B5FD").cgColor,
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        grad_Somnia.locations = [0, 0.5, 1]
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 1, y: 1)
        grad_Somnia.cornerRadius = 28
        grad_Somnia.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        _headerGradient_Somnia = grad_Somnia

        // 装饰浮球
        addDecorOrbs_Somnia()

        // 导航元素
        headerView_Somnia.addSubview(backButton_Somnia)
        headerView_Somnia.addSubview(reportButton_Somnia)

        // 头像层级
        headerView_Somnia.addSubview(avatarRingView_Somnia)
        avatarRingView_Somnia.addSubview(avatarBorderView_Somnia)
        avatarBorderView_Somnia.addSubview(avatarView_Somnia)

        // 文本 & 统计
        headerView_Somnia.addSubview(nameLabel_Somnia)
        headerView_Somnia.addSubview(introLabel_Somnia)
        headerView_Somnia.addSubview(statsCard_Somnia)

        // 统计三项 + 分隔线
        statsCard_Somnia.addSubview(followStatView_Somnia)
        statsCard_Somnia.addSubview(postsStatView_Somnia)
        statsCard_Somnia.addSubview(fansStatView_Somnia)
        let div1_Somnia = makeDivider_Somnia()
        let div2_Somnia = makeDivider_Somnia()
        statsCard_Somnia.addSubview(div1_Somnia)
        statsCard_Somnia.addSubview(div2_Somnia)

        // 按钮行
        headerView_Somnia.addSubview(buttonStack_Somnia)

        // 帖子区
        contentView_Somnia.addSubview(postsSectionView_Somnia)
        postsSectionView_Somnia.addSubview(postsAccentBar_Somnia)
        postsSectionView_Somnia.addSubview(postsSectionLabel_Somnia)
        postsSectionView_Somnia.addSubview(postsCountBadge_Somnia)
        contentView_Somnia.addSubview(collectionView_Somnia)
        contentView_Somnia.addSubview(emptyStateView_Somnia)
        setupEmptyState_Somnia()

        collectionView_Somnia.delegate   = self
        collectionView_Somnia.dataSource = self
        collectionView_Somnia.register(UserInfoPostCell_Somnia.self, forCellWithReuseIdentifier: "UserInfoPostCell_Somnia")

        setupConstraints_Somnia(div1: div1_Somnia, div2: div2_Somnia)
        updateButtonLayout_Somnia()
    }

    /// 创建统计卡片内分隔线
    private func makeDivider_Somnia() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        return v
    }

    /// 添加头部装饰浮球（三个半透明圆形）
    private func addDecorOrbs_Somnia() {
        let configs_Somnia: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (0.08, -50, -40, 180),
            (0.06, 1.0, -30, 140),
            (0.05, 0.3, 200, 120)
        ]
        for (alpha_Somnia, xMul_Somnia, yOff_Somnia, size_Somnia) in configs_Somnia {
            let orb_Somnia = UIView()
            orb_Somnia.backgroundColor = UIColor.white.withAlphaComponent(alpha_Somnia)
            orb_Somnia.layer.cornerRadius = size_Somnia / 2
            headerView_Somnia.addSubview(orb_Somnia)
            orb_Somnia.snp.makeConstraints { make in
                if xMul_Somnia <= 0 {
                    make.left.equalToSuperview().offset(xMul_Somnia)
                } else if xMul_Somnia >= 1 {
                    make.right.equalToSuperview().offset(CGFloat(30))
                } else {
                    make.centerX.equalToSuperview().multipliedBy(xMul_Somnia)
                }
                make.top.equalToSuperview().offset(yOff_Somnia)
                make.width.height.equalTo(size_Somnia)
            }
        }
    }

    /// 配置空状态视图（图标 + 文字）
    private func setupEmptyState_Somnia() {
        let iconView_Somnia = UIImageView()
        let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        iconView_Somnia.image = UIImage(systemName: "square.grid.2x2", withConfiguration: cfg_Somnia)
        iconView_Somnia.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
        iconView_Somnia.contentMode = .scaleAspectFit

        let titleLbl_Somnia = UILabel()
        titleLbl_Somnia.text = "No posts yet"
        titleLbl_Somnia.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLbl_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        titleLbl_Somnia.textAlignment = .center

        let subLbl_Somnia = UILabel()
        subLbl_Somnia.text = "This user hasn't shared anything yet ✨"
        subLbl_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subLbl_Somnia.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        subLbl_Somnia.textAlignment = .center

        emptyStateView_Somnia.addSubview(iconView_Somnia)
        emptyStateView_Somnia.addSubview(titleLbl_Somnia)
        emptyStateView_Somnia.addSubview(subLbl_Somnia)

        iconView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48)
        }
        titleLbl_Somnia.snp.makeConstraints { make in
            make.top.equalTo(iconView_Somnia.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(30)
        }
        subLbl_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Somnia.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    /// 设置所有布局约束
    private func setupConstraints_Somnia(div1: UIView, div2: UIView) {

        scrollView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // ── 头部 ──
        headerView_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            // 增加高度确保按钮行完全在头部区域内（按钮底部约 414pt + 26pt 底部留白）
            make.height.equalTo(440)
        }

        backButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(52)
        }

        reportButton_Somnia.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Somnia)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }

        // 头像三层
        avatarRingView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(backButton_Somnia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(96)
        }
        avatarBorderView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }
        avatarView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }

        nameLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Somnia.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        introLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Somnia.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
        }

        // 统计卡片（3列等宽）
        statsCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Somnia.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(64)
        }
        // 三栏等宽：Following | Posts | Fans，分隔线仅高 28pt
        followStatView_Somnia.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        div1.snp.makeConstraints { make in
            make.left.equalTo(followStatView_Somnia.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        postsStatView_Somnia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(followStatView_Somnia.snp.right)
            make.width.equalToSuperview().dividedBy(3)
        }
        div2.snp.makeConstraints { make in
            make.left.equalTo(postsStatView_Somnia.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        fansStatView_Somnia.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }

        // 按钮行（bottom 约束确保按钮不溢出 headerView）
        buttonStack_Somnia.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Somnia.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview().offset(-24)
        }

        // ── 帖子区 ──
        postsSectionView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(headerView_Somnia.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        // 左侧渐变强调竖条（距左 16pt，高 22pt，宽 4pt）
        postsAccentBar_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(22)
        }
        postsSectionLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(postsAccentBar_Somnia.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        postsCountBadge_Somnia.snp.makeConstraints { make in
            make.left.equalTo(postsSectionLabel_Somnia.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(28)
        }

        collectionView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(postsSectionView_Somnia.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview()
        }

        emptyStateView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(postsSectionView_Somnia.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }

    /// 根据 isFromMessageChat_Somnia 调整按钮布局
    private func updateButtonLayout_Somnia() {
        buttonStack_Somnia.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if isFromMessageChat_Somnia {
            buttonStack_Somnia.addArrangedSubview(followButton_Somnia)
            followButton_Somnia.snp.makeConstraints { make in make.width.equalTo(160) }
        } else {
            buttonStack_Somnia.addArrangedSubview(followButton_Somnia)
            buttonStack_Somnia.addArrangedSubview(messageButton_Somnia)
            followButton_Somnia.snp.makeConstraints { make in make.width.equalTo(130) }
            messageButton_Somnia.snp.makeConstraints { make in make.width.equalTo(130) }
        }
    }

    private func setupActions_Somnia() {
        backButton_Somnia.onTapped_Somnia = {
            Navigation_Somnia.pop_Somnia()
        }
        reportButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleReport_Somnia()
        }, for: .touchUpInside)
        followButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleFollow_Somnia()
        }, for: .touchUpInside)
        messageButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleMessage_Somnia()
        }, for: .touchUpInside)
    }

    private func setupNotifications_Somnia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUserChange_Somnia),
            name: UserViewModel_Somnia.userStateDidChangeNotification_Somnia, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleChange_Somnia),
            name: TitleViewModel_Somnia.titleStateDidChangeNotification_Somnia, object: nil
        )
    }

    // MARK: - 私有方法 - 渐变更新

    /// 更新头像外环渐变
    private func updateAvatarRingGradient_Somnia() {
        guard avatarRingView_Somnia.bounds.width > 0 else { return }
        if _avatarRingGradient_Somnia == nil {
            let grad_Somnia = CAGradientLayer()
            grad_Somnia.colors = [
                UIColor(hexstring_Somnia: "#C4B5FD").cgColor,
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            grad_Somnia.locations = [0, 0.5, 1]
            grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            grad_Somnia.endPoint = CGPoint(x: 1, y: 1)
            grad_Somnia.frame = avatarRingView_Somnia.bounds
            grad_Somnia.cornerRadius = 48
            avatarRingView_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
            _avatarRingGradient_Somnia = grad_Somnia
        } else {
            _avatarRingGradient_Somnia?.frame = avatarRingView_Somnia.bounds
        }
    }

    /// 更新 POSTS 左侧强调竖条渐变（从品牌紫到品牌蓝，纵向）
    private func updatePostsAccentBarGradient_Somnia() {
        guard postsAccentBar_Somnia.bounds.height > 0 else { return }
        if postsAccentBarGrad_Somnia != nil { return }
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.frame = postsAccentBar_Somnia.bounds
        grad_Somnia.colors = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 0, y: 1)
        postsAccentBar_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        postsAccentBarGrad_Somnia = grad_Somnia
    }

    /// 更新关注按钮渐变（未关注状态显示品牌渐变背景）
    private func updateFollowButtonGradient_Somnia() {
        guard followButton_Somnia.bounds.width > 0 else { return }
        // 已有渐变层则不重复添加
        if followButton_Somnia.layer.sublayers?.contains(where: { $0.name == "followGrad_Somnia" }) == true { return }
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.name = "followGrad_Somnia"
        grad_Somnia.frame = followButton_Somnia.bounds
        grad_Somnia.colors = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.55).cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.withAlphaComponent(0.55).cgColor
        ]
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 1, y: 1)
        grad_Somnia.cornerRadius = 22
        followButton_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
    }

    // MARK: - 私有方法 - 数据

    private func loadPosts_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }
        _posts_Somnia = TitleViewModel_Somnia.shared_Somnia.getUserPosts_Somnia(user_somnia: user_Somnia)
        postsCountBadge_Somnia.text = "  \(_posts_Somnia.count)  "
        postsStatView_Somnia.update_Somnia(count_Somnia: _posts_Somnia.count)
        collectionView_Somnia.reloadData()
        updateCollectionHeight_Somnia()
    }

    private func refreshUI_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }

        if let userId_Somnia = user_Somnia.userId_Somnia {
            avatarView_Somnia.configure_Somnia(userId_Somnia: userId_Somnia)
        }

        nameLabel_Somnia.text = user_Somnia.userName_Somnia ?? "User"
        introLabel_Somnia.text = user_Somnia.userIntroduce_Somnia?.isEmpty == false
            ? user_Somnia.userIntroduce_Somnia
            : "Living in the moment 🌙"

        followStatView_Somnia.update_Somnia(count_Somnia: user_Somnia.userFollow_Somnia ?? 0)
        fansStatView_Somnia.update_Somnia(count_Somnia: user_Somnia.userFans_Somnia ?? 0)

        updateFollowButtonState_Somnia()
        loadPosts_Somnia()
    }

    private func updateFollowButtonState_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }
        let isFollowing_Somnia = checkIsFollowing_Somnia(user_Somnia: user_Somnia)
        followButton_Somnia.setTitle(isFollowing_Somnia ? "Followed ✓" : "Follow", for: .normal)
        followButton_Somnia.backgroundColor = isFollowing_Somnia
            ? UIColor.white.withAlphaComponent(0.45)
            : UIColor.white.withAlphaComponent(0.25)
    }

    private func checkIsFollowing_Somnia(user_Somnia: PrewUserModel_Somnia) -> Bool {
        let current_Somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        return current_Somnia.userFollow_Somnia.contains { $0.userId_Somnia == user_Somnia.userId_Somnia }
    }

    /// 动态更新 CollectionView 高度
    private func updateCollectionHeight_Somnia() {
        let count_Somnia = _posts_Somnia.count
        emptyStateView_Somnia.isHidden = count_Somnia > 0
        if count_Somnia == 0 {
            collectionView_Somnia.snp.updateConstraints { make in make.height.equalTo(0) }
            return
        }
        let screenW_Somnia = UIScreen.main.bounds.width
        let cellW_Somnia = (screenW_Somnia - 16 - 16 - 12) / 2
        let cellH_Somnia = cellW_Somnia * 1.1
        let rows_Somnia = Int(ceil(Double(count_Somnia) / 2.0))
        let total_Somnia = CGFloat(rows_Somnia) * (cellH_Somnia + 12) - 12 + 20
        collectionView_Somnia.snp.updateConstraints { make in make.height.equalTo(total_Somnia) }
    }

    // MARK: - 私有方法 - 事件处理

    private func handleReport_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }
        ReportDeleteHelper_Somnia.block_Somnia(user_Somnia: user_Somnia, from: self) { [weak self] in
            Navigation_Somnia.popToSafeStateAfterBlock_Somnia(from: self ?? UIViewController())
        }
    }

    private func handleFollow_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }
        guard UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia else {
            Navigation_Somnia.toLogin_Somnia(style_somnia: .present_somnia)
            return
        }
        let wasFollowing_Somnia = checkIsFollowing_Somnia(user_Somnia: user_Somnia)
        Task { @MainActor in
            UserViewModel_Somnia.shared_Somnia.followUser_Somnia(user_somnia: user_Somnia)
        }
        if wasFollowing_Somnia && isFromMessageChat_Somnia {
            if let userId_Somnia = user_Somnia.userId_Somnia {
                Task { @MainActor in
                    MessageViewModel_Somnia.shared_Somnia.deleteUserMessages_Somnia(userId_somnia: userId_Somnia)
                }
            }
            if let navCtrl_Somnia = navigationController {
                if let listVC_Somnia = navCtrl_Somnia.viewControllers.first(where: { $0 is MessageList_Somnia }) {
                    navCtrl_Somnia.popToViewController(listVC_Somnia, animated: true)
                } else {
                    navCtrl_Somnia.popToRootViewController(animated: true)
                }
            }
            return
        }
        updateFollowButtonState_Somnia()
    }

    private func handleMessage_Somnia() {
        guard let user_Somnia = userModel_Somnia else { return }
        guard UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia else {
            Navigation_Somnia.toLogin_Somnia(style_somnia: .present_somnia)
            return
        }
        if checkIsFollowing_Somnia(user_Somnia: user_Somnia) {
            showEnterChatConfirm_Somnia(user_Somnia: user_Somnia)
        } else {
            Utils_Somnia.showInfo_Somnia(
                message_Somnia: "Follow \(user_Somnia.userName_Somnia ?? "this user") first to send messages"
            )
        }
    }

    private func showEnterChatConfirm_Somnia(user_Somnia: PrewUserModel_Somnia) {
        let name_Somnia = user_Somnia.userName_Somnia ?? "User"
        let intro_Somnia = user_Somnia.userIntroduce_Somnia ?? "No bio"
        let alert_Somnia = UIAlertController(
            title: "Chat with \(name_Somnia)",
            message: "\(intro_Somnia)\n\nEnter the conversation?",
            preferredStyle: .alert
        )
        alert_Somnia.addAction(UIAlertAction(title: "Enter", style: .default) { [weak self] _ in
            Navigation_Somnia.toMessageUser_Somnia(with: user_Somnia, style_somnia: .push_somnia)
        })
        alert_Somnia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Somnia, animated: true)
    }

    @objc private func handleUserChange_Somnia()  { refreshUI_Somnia() }
    @objc private func handleTitleChange_Somnia() { loadPosts_Somnia() }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UICollectionViewDataSource / Delegate

extension UserInfo_Somnia: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _posts_Somnia.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Somnia = collectionView.dequeueReusableCell(
            withReuseIdentifier: "UserInfoPostCell_Somnia", for: indexPath
        ) as! UserInfoPostCell_Somnia
        if indexPath.item < _posts_Somnia.count {
            let post_Somnia = _posts_Somnia[indexPath.item]
            cell_Somnia.configure_Somnia(post_Somnia: post_Somnia)
            // 设置举报回调：由 VC 持有引用，避免循环引用
            cell_Somnia.onReportTapped_Somnia = { [weak self] in
                guard let self = self else { return }
                ReportDeleteHelper_Somnia.report_Somnia(post_Somnia: post_Somnia, from: self) { [weak self] in
                    self?.loadPosts_Somnia()
                }
            }
        }
        return cell_Somnia
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenW_Somnia = UIScreen.main.bounds.width
        let cellW_Somnia = (screenW_Somnia - 16 - 16 - 12) / 2
        return CGSize(width: cellW_Somnia, height: cellW_Somnia * 1.1)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < _posts_Somnia.count else { return }
        Navigation_Somnia.toTitleDetail_Somnia(titleModel_somnia: _posts_Somnia[indexPath.item])
    }
}

// MARK: - 帖子两列格栅单元格

/// 用户中心帖子格栅单元格
/// 核心作用：以方形卡片形式展示单条帖子的媒体缩略图及标题
/// 设计思路：渐变占位背景 + 圆角卡片 + 左上角 "Post" 角标 + 底部标题遮罩
private class UserInfoPostCell_Somnia: UICollectionViewCell {

    // MARK: - UI组件

    /// 媒体缩略图
    private let mediaImageView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = ColorConfig_Somnia.divider_Somnia
        return iv
    }()

    /// 媒体占位渐变图层
    private var mediaGradient_Somnia: CAGradientLayer?

    /// 媒体占位图标（无媒体时展示）
    private let placeholderIcon_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        iv.image = UIImage(systemName: "photo", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 底部标题渐变遮罩
    private let bottomMask_Somnia: UIView = {
        let v = UIView()
        return v
    }()
    private var bottomMaskGrad_Somnia: CAGradientLayer?

    /// 帖子标题
    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    /// 左上角 "Post" 角标（白底品牌色文字，含左右内边距）
    private let postBadge_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "  Post  "
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        lbl.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        lbl.layer.cornerRadius = 8
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0, height: 1)
        lbl.layer.shadowRadius = 3
        lbl.layer.shadowOpacity = 0.12
        lbl.clipsToBounds = false
        lbl.textAlignment = .center
        return lbl
    }()

    /// 右上角举报按钮
    private let reportBtn_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        btn.layer.cornerRadius = 13
        btn.clipsToBounds = true
        return btn
    }()

    /// 举报点击回调（由外部 VC 设置）
    var onReportTapped_Somnia: (() -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        mediaGradient_Somnia?.frame = mediaImageView_Somnia.bounds
        bottomMaskGrad_Somnia?.frame = bottomMask_Somnia.bounds
    }

    // MARK: - UI设置

    private func setupUI_Somnia() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        // 卡片阴影：品牌紫色调 + 稍强不透明度
        layer.shadowColor = UIColor(hexstring_Somnia: "#7C3AED").cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 14
        layer.shadowOpacity = 0.12

        contentView.addSubview(mediaImageView_Somnia)
        contentView.addSubview(placeholderIcon_Somnia)
        contentView.addSubview(bottomMask_Somnia)
        bottomMask_Somnia.addSubview(titleLabel_Somnia)
        contentView.addSubview(postBadge_Somnia)
        contentView.addSubview(reportBtn_Somnia)

        reportBtn_Somnia.addAction(UIAction { [weak self] _ in
            self?.onReportTapped_Somnia?()
        }, for: .touchUpInside)

        mediaImageView_Somnia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        placeholderIcon_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        bottomMask_Somnia.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(64)
        }
        titleLabel_Somnia.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        postBadge_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(36)
        }
        reportBtn_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(26)
        }
    }

    // MARK: - 配置

    /// 配置帖子单元格
    /// - Parameter post_Somnia: 帖子数据模型
    func configure_Somnia(post_Somnia: TitleModel_Somnia) {
        titleLabel_Somnia.text = post_Somnia.title_Somnia

        let mediaPath_Somnia = post_Somnia.titleMeidas_Somnia.first ?? ""
        loadMedia_Somnia(path_Somnia: mediaPath_Somnia)
    }

    /// 加载媒体缩略图（assets → 本地文件 → 占位）
    private func loadMedia_Somnia(path_Somnia: String) {
        placeholderIcon_Somnia.isHidden = false
        setupMediaGradient_Somnia()
        setupBottomMaskGradient_Somnia()

        guard !path_Somnia.isEmpty else { return }

        // Assets 图片
        if let img_Somnia = UIImage(named: path_Somnia) {
            mediaImageView_Somnia.image = img_Somnia
            placeholderIcon_Somnia.isHidden = true
            mediaGradient_Somnia?.removeFromSuperlayer()
            mediaGradient_Somnia = nil
            return
        }
        // 本地文件
        if let img_Somnia = UIImage(contentsOfFile: path_Somnia) {
            mediaImageView_Somnia.image = img_Somnia
            placeholderIcon_Somnia.isHidden = true
            mediaGradient_Somnia?.removeFromSuperlayer()
            mediaGradient_Somnia = nil
            return
        }
        // 视频类型：显示播放图标
        let isVideo_Somnia = path_Somnia.hasSuffix(".mp4") || path_Somnia.hasSuffix(".mov")
        if isVideo_Somnia {
            let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
            placeholderIcon_Somnia.image = UIImage(systemName: "play.circle", withConfiguration: cfg_Somnia)
        }
    }

    /// 媒体占位渐变背景（紫→蓝）
    private func setupMediaGradient_Somnia() {
        guard mediaGradient_Somnia == nil else { return }
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.frame = mediaImageView_Somnia.bounds
        grad_Somnia.colors = [
            UIColor(hexstring_Somnia: "#C4B5FD").withAlphaComponent(0.6).cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.withAlphaComponent(0.4).cgColor
        ]
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 1, y: 1)
        mediaImageView_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        mediaGradient_Somnia = grad_Somnia
    }

    /// 底部标题遮罩渐变（透明→黑色）
    private func setupBottomMaskGradient_Somnia() {
        guard bottomMaskGrad_Somnia == nil else { return }
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.frame = bottomMask_Somnia.bounds
        grad_Somnia.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 0, y: 1)
        bottomMask_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        bottomMaskGrad_Somnia = grad_Somnia
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaImageView_Somnia.image = nil
        placeholderIcon_Somnia.isHidden = false
        let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        placeholderIcon_Somnia.image = UIImage(systemName: "photo", withConfiguration: cfg_Somnia)
        mediaGradient_Somnia?.removeFromSuperlayer()
        mediaGradient_Somnia = nil
        bottomMaskGrad_Somnia?.removeFromSuperlayer()
        bottomMaskGrad_Somnia = nil
    }
}
