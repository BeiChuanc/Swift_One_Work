import Foundation
import UIKit
import SnapKit

// MARK: 我的页面
// 设计思路：
//   顶部采用与 Discover/Release/Messages 统一的深紫-靛蓝渐变 Header（圆弧底部裁切），
//   内含大头像（白色环边框 + 相机覆盖层）、用户名、简介、帖子/点赞统计横条；
//   Header 下方为 Posts/Liked 自定义段选控件（带滑动指示器），
//   内容区采用与 Discover 一致的 accent 着色帖子卡片。
//   当作为 TabBar 子页面时隐藏返回按钮；作为 push 页面时显示返回按钮。
// 关键属性：
//   meModel_Echd          — 外部传入的用户模型（可选）
//   selectedTab_Echd      — 0=Posts 1=Liked
//   headerGradient_Echd   — Header 渐变图层

/// 我的页面视图控制器
class Me_Echd: UIViewController {

    // MARK: - 外部属性

    /// 外部传入的用户模型（可选，不传时取当前登录用户）
    var meModel_Echd: LoginUserModel_Echd?

    /// 当前展示类型：0=Posts，1=Liked
    private var selectedTab_Echd: Int = 0

    // MARK: - UI组件 / 导航栏

    /// 返回按钮（作为 push 页面时显示）
    private let backButton_Echd = BackButton_Echd()

    /// 设置按钮（浮于 Header 右上角）
    private let settingButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .system)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        btn_Echd.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.tintColor = .white
        btn_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn_Echd.layer.cornerRadius = 21
        return btn_Echd
    }()

    /// VIP 订阅按钮（位于设置按钮同行最左侧，使用 vip_btn 图标，高度与设置按钮一致，宽度自适应）
    private let vipButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setImage(UIImage(named: "vip_btn"), for: .normal)
        btn_Echd.imageView?.contentMode = .scaleAspectFit
        btn_Echd.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn_Echd.layer.cornerRadius = 21
        btn_Echd.layer.masksToBounds = true
        return btn_Echd
    }()

    // MARK: - UI组件 / Header

    /// 顶部渐变 Header 容器（延伸至状态栏背后）
    private let headerView_Echd = UIView()

    /// Header 渐变图层
    private var headerGradient_Echd: CAGradientLayer?

    /// 头像外环（白色描边提供视觉分隔）
    private let avatarRingView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .clear
        view_Echd.layer.cornerRadius = 46
        view_Echd.layer.borderWidth = 3.5
        view_Echd.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        return view_Echd
    }()

    /// 用户头像
    private let avatarView_Echd = CurrentUserAvatarView_Echd()

    /// 编辑头像覆盖层（相机图标）
    private let editAvatarOverlay_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        view_Echd.layer.cornerRadius = 40
        view_Echd.clipsToBounds = true
        let camIV_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        camIV_Echd.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_Echd)
        camIV_Echd.tintColor = .white
        camIV_Echd.contentMode = .scaleAspectFit
        view_Echd.addSubview(camIV_Echd)
        camIV_Echd.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(20) }
        return view_Echd
    }()

    /// 用户名
    private let userNameLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 用户简介
    private let userBioLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.78)
        label_Echd.textAlignment = .center
        label_Echd.numberOfLines = 2
        return label_Echd
    }()

    /// 统计横条容器（Posts 数量 / Liked 数量）
    private let statsRow_Echd = UIView()

    /// Posts 统计数字
    private let postsCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 20, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// Posts 统计标题
    private let postsStatTitle_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Posts"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.7)
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 竖向分隔线（Posts | Following）
    private let statsDivider_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view_Echd
    }()

    /// Following 统计数字
    private let followingCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 20, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// Following 统计标题
    private let followingStatTitle_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Following"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.7)
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 竖向分隔线（Following | Liked）
    private let statsDivider2_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view_Echd
    }()

    /// Liked 统计数字
    private let likedCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 20, weight: .black)
        label_Echd.textColor = .white
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// Liked 统计标题
    private let likedStatTitle_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Liked"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.7)
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// Edit Profile 按钮（与设置按钮同行、同高，白色毛玻璃胶囊样式）
    private let editButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .system)
        btn_Echd.setTitle("Edit Profile", for: .normal)
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn_Echd.layer.cornerRadius = 21
        btn_Echd.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        btn_Echd.layer.borderWidth = 1
        btn_Echd.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn_Echd
    }()

    // MARK: - UI组件 / 分段选择器

    /// 分段容器（Posts / Liked）
    private let segmentContainer_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 18
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.1).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Echd.layer.shadowRadius = 12
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 滑动指示器（选中态底衬，紫色渐变）
    private let segmentIndicator_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 14
        return view_Echd
    }()

    /// 指示器渐变图层
    private var indicatorGradient_Echd: CAGradientLayer?

    /// Posts 段按钮
    private let postsTabButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setTitle("Posts", for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return btn_Echd
    }()

    /// Liked 段按钮
    private let likedTabButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setTitle("Liked", for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return btn_Echd
    }()

    // MARK: - UI组件 / 帖子列表

    /// 主滚动视图
    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        return sv_Echd
    }()

    /// 滚动内容容器
    private let contentView_Echd = UIView()

    /// 帖子 StackView
    private let postsStackView_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 16
        return sv_Echd
    }()

    /// 空状态容器
    private let emptyView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.isHidden = true
        return view_Echd
    }()

    // MARK: - 私有属性

    /// accent 颜色循环数组（与 Discover 一致）
    private let accentColors_Echd: [UIColor] = [
        UIColor(hexstring_Echd: "#7C3AED"),
        UIColor(hexstring_Echd: "#EC4899"),
        UIColor(hexstring_Echd: "#10B981"),
        UIColor(hexstring_Echd: "#F59E0B"),
        UIColor(hexstring_Echd: "#6366F1"),
        UIColor(hexstring_Echd: "#F43F5E")
    ]

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        // 作为 TabBar 子页面时无返回栈，隐藏返回按钮
        let isPushed_Echd = (navigationController != nil) &&
                            (navigationController?.viewControllers.count ?? 0) > 1
        backButton_Echd.isHidden = !isPushed_Echd
        refreshUI_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        setupEmptyView_Echd()
        observeNotifications_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerView_Echd.bounds
        applyHeaderArc_Echd()
        indicatorGradient_Echd?.frame = segmentIndicator_Echd.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // --- Header ---
        headerView_Echd.clipsToBounds = true
        view.addSubview(headerView_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        headerView_Echd.layer.insertSublayer(grad_Echd, at: 0)
        headerGradient_Echd = grad_Echd

        // 导航按钮（浮于 header 之上）
        view.addSubview(backButton_Echd)
        view.addSubview(vipButton_Echd)
        view.addSubview(settingButton_Echd)
        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }
        settingButton_Echd.addTarget(self, action: #selector(settingTapped_Echd), for: .touchUpInside)
        vipButton_Echd.addTarget(self, action: #selector(vipTapped_Echd), for: .touchUpInside)

        // Header 内容（不添加 editAvatarOverlay，头像纯净展示）
        headerView_Echd.addSubview(avatarRingView_Echd)
        headerView_Echd.addSubview(avatarView_Echd)
        headerView_Echd.addSubview(userNameLabel_Echd)
        headerView_Echd.addSubview(userBioLabel_Echd)
        headerView_Echd.addSubview(statsRow_Echd)
        // editButton 浮于 header 上方，与 settingButton 同行
        view.addSubview(editButton_Echd)

        // 统计横条子视图（Posts | Following | Liked）
        statsRow_Echd.addSubview(postsCountLabel_Echd)
        statsRow_Echd.addSubview(postsStatTitle_Echd)
        statsRow_Echd.addSubview(statsDivider_Echd)
        statsRow_Echd.addSubview(followingCountLabel_Echd)
        statsRow_Echd.addSubview(followingStatTitle_Echd)
        statsRow_Echd.addSubview(statsDivider2_Echd)
        statsRow_Echd.addSubview(likedCountLabel_Echd)
        statsRow_Echd.addSubview(likedStatTitle_Echd)

        // 头像点击进入编辑
        let avatarTap_Echd = UITapGestureRecognizer(target: self, action: #selector(editProfileTapped_Echd))
        avatarView_Echd.addGestureRecognizer(avatarTap_Echd)
        avatarView_Echd.isUserInteractionEnabled = true
        editButton_Echd.addTarget(self, action: #selector(editProfileTapped_Echd), for: .touchUpInside)

        // --- 分段选择器 ---
        view.addSubview(segmentContainer_Echd)
        segmentContainer_Echd.addSubview(segmentIndicator_Echd)
        segmentContainer_Echd.addSubview(postsTabButton_Echd)
        segmentContainer_Echd.addSubview(likedTabButton_Echd)

        let indGrad_Echd = CAGradientLayer()
        indGrad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        indGrad_Echd.startPoint = CGPoint(x: 0, y: 0.5)
        indGrad_Echd.endPoint = CGPoint(x: 1, y: 0.5)
        segmentIndicator_Echd.layer.insertSublayer(indGrad_Echd, at: 0)
        segmentIndicator_Echd.layer.masksToBounds = true
        indicatorGradient_Echd = indGrad_Echd

        postsTabButton_Echd.addTarget(self, action: #selector(postsTabTapped_Echd), for: .touchUpInside)
        likedTabButton_Echd.addTarget(self, action: #selector(likedTabTapped_Echd), for: .touchUpInside)
        updateSegmentUI_Echd(animated: false)

        // --- 帖子滚动区 ---
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)
        contentView_Echd.addSubview(postsStackView_Echd)
        contentView_Echd.addSubview(emptyView_Echd)
    }

    /// Header 底部圆弧遮罩
    private func applyHeaderArc_Echd() {
        let w_Echd = headerView_Echd.bounds.width
        let h_Echd = headerView_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 20))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 20),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 20)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer()
        mask_Echd.path = path_Echd.cgPath
        headerView_Echd.layer.mask = mask_Echd
    }

    /// 配置空状态视图
    private func setupEmptyView_Echd() {
        let circleBg_Echd = UIView()
        circleBg_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.07)
        circleBg_Echd.layer.cornerRadius = 52
        emptyView_Echd.addSubview(circleBg_Echd)

        let iconIV_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 34, weight: .thin)
        iconIV_Echd.image = UIImage(systemName: "sparkles", withConfiguration: cfg_Echd)
        iconIV_Echd.tintColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.4)
        iconIV_Echd.contentMode = .scaleAspectFit
        emptyView_Echd.addSubview(iconIV_Echd)

        let titleLbl_Echd = UILabel()
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLbl_Echd.textColor = UIColor(hexstring_Echd: "#374151")
        titleLbl_Echd.textAlignment = .center
        emptyView_Echd.addSubview(titleLbl_Echd)
        titleLbl_Echd.tag = 901

        let descLbl_Echd = UILabel()
        descLbl_Echd.font = UIFont.systemFont(ofSize: 13)
        descLbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        descLbl_Echd.textAlignment = .center
        descLbl_Echd.numberOfLines = 0
        emptyView_Echd.addSubview(descLbl_Echd)
        descLbl_Echd.tag = 902

        circleBg_Echd.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }
        iconIV_Echd.snp.makeConstraints { make in
            make.center.equalTo(circleBg_Echd)
            make.width.height.equalTo(44)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(circleBg_Echd.snp.bottom).offset(18)
            make.centerX.leading.trailing.equalToSuperview()
        }
        descLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(8)
            make.leading.trailing.centerX.bottom.equalToSuperview()
        }
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width

        // Header 延伸至状态栏背后
        headerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(310)
        }

        // 导航按钮浮于 Header 上方
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        settingButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(42)
        }
        // Edit Profile 与设置按钮同行、同高，胶囊样式
        editButton_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(settingButton_Echd)
            make.trailing.equalTo(settingButton_Echd.snp.leading).offset(-10)
            make.height.equalTo(42)
        }
        // VIP 订阅按钮：最左侧，高度与设置按钮一致，宽度自适应
        vipButton_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(settingButton_Echd)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(42)
        }

        // 头像环 & 头像
        avatarRingView_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }
        avatarView_Echd.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Echd)
            make.width.height.equalTo(80)
        }

        // 名字与简介
        userNameLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Echd.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        userBioLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Echd.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        // 统计横条：三列布局 Posts | Following | Liked
        statsRow_Echd.snp.makeConstraints { make in
            make.top.equalTo(userBioLabel_Echd.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-28)
        }
        // Posts 列（左）
        postsCountLabel_Echd.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.equalTo(80)
        }
        postsStatTitle_Echd.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Echd.snp.bottom).offset(2)
            make.centerX.equalTo(postsCountLabel_Echd)
        }
        // 第一条分隔线
        statsDivider_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(80)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        // Following 列（中）
        followingCountLabel_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
        }
        followingStatTitle_Echd.snp.makeConstraints { make in
            make.top.equalTo(followingCountLabel_Echd.snp.bottom).offset(2)
            make.centerX.equalTo(followingCountLabel_Echd)
        }
        // 第二条分隔线
        statsDivider2_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-80)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        // Liked 列（右）
        likedCountLabel_Echd.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.width.equalTo(80)
        }
        likedStatTitle_Echd.snp.makeConstraints { make in
            make.top.equalTo(likedCountLabel_Echd.snp.bottom).offset(2)
            make.centerX.equalTo(likedCountLabel_Echd)
        }

        // 分段选择器
        segmentContainer_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerView_Echd.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(46)
        }
        segmentIndicator_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }
        postsTabButton_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }
        likedTabButton_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }

        // 帖子滚动区
        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer_Echd.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }
        postsStackView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-30)
        }
        emptyView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    // MARK: - 数据刷新

    /// 刷新整体 UI
    private func refreshUI_Echd() {
        let user_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        userNameLabel_Echd.text = user_Echd.userName_Echd ?? "Guest"
        userBioLabel_Echd.text = "Time drifts, sparks remain ✨"
        postsCountLabel_Echd.text = "\(user_Echd.userPosts_Echd.count)"
        followingCountLabel_Echd.text = "\(user_Echd.userFollow_Echd.count)"
        likedCountLabel_Echd.text = "\(user_Echd.userLike_Echd.count)"
        refreshPostsList_Echd()
    }

    /// 刷新帖子列表
    private func refreshPostsList_Echd() {
        postsStackView_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let user_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        let posts_Echd = selectedTab_Echd == 0 ? user_Echd.userPosts_Echd : user_Echd.userLike_Echd

        if posts_Echd.isEmpty {
            emptyView_Echd.isHidden = false
            postsStackView_Echd.isHidden = true
            // 更新空态文案
            if let t_Echd = emptyView_Echd.viewWithTag(901) as? UILabel {
                t_Echd.text = selectedTab_Echd == 0 ? "No posts yet" : "No liked posts yet"
            }
            if let d_Echd = emptyView_Echd.viewWithTag(902) as? UILabel {
                d_Echd.text = selectedTab_Echd == 0
                    ? "Share your first spark on the\nPublish tab! 🔥"
                    : "Go explore and like something\nthat moves you ✨"
            }
        } else {
            emptyView_Echd.isHidden = true
            postsStackView_Echd.isHidden = false
            for (idx_Echd, post_Echd) in posts_Echd.enumerated() {
                let accent_Echd = accentColors_Echd[idx_Echd % accentColors_Echd.count]
                postsStackView_Echd.addArrangedSubview(buildPostCard_Echd(post: post_Echd, accent: accent_Echd))
            }
        }
    }

    // MARK: - 卡片构建

    /// 构建帖子卡片
    /// - Parameters:
    ///   - post: 帖子数据
    ///   - accent: 卡片主调色（阴影色与左侧竖条色）
    private func buildPostCard_Echd(post: TitleModel_Echd, accent: UIColor) -> UIView {
        let cardView_Echd = UIView()
        cardView_Echd.backgroundColor = .white
        cardView_Echd.layer.cornerRadius = 18
        cardView_Echd.layer.shadowColor = accent.withAlphaComponent(0.2).cgColor
        cardView_Echd.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView_Echd.layer.shadowRadius = 14
        cardView_Echd.layer.shadowOpacity = 1
        cardView_Echd.clipsToBounds = false

        // 内部圆角裁剪容器
        let innerView_Echd = UIView()
        innerView_Echd.backgroundColor = .white
        innerView_Echd.layer.cornerRadius = 18
        innerView_Echd.clipsToBounds = true
        cardView_Echd.addSubview(innerView_Echd)

        // 媒体视图
        let mediaView_Echd = MediaDisplayView_Echd()
        innerView_Echd.addSubview(mediaView_Echd)
        mediaView_Echd.configure_Echd(mediaPath_Echd: post.titleMeidas_Echd.first)

        // 媒体底部渐变蒙版
        let gradMask_Echd = MeGradientOverlay_Echd()
        innerView_Echd.addSubview(gradMask_Echd)

        // 举报/删除按钮（添加至 cardView 避免被裁切）
        let reportBtn_Echd = ReportDeleteHelper_Echd.createPostReportButton_Echd(
            post_Echd: post,
            size_Echd: 12,
            color_Echd: .white,
            from: self,
            completion_Echd: { [weak self] in self?.refreshPostsList_Echd() }
        )
        reportBtn_Echd.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        reportBtn_Echd.layer.cornerRadius = 13
        cardView_Echd.addSubview(reportBtn_Echd)

        // 信息区
        let infoView_Echd = UIView()
        infoView_Echd.backgroundColor = .white
        innerView_Echd.addSubview(infoView_Echd)

        // 左侧 accent 竖条
        let bar_Echd = UIView()
        bar_Echd.backgroundColor = accent
        bar_Echd.layer.cornerRadius = 2
        infoView_Echd.addSubview(bar_Echd)

        // 标题
        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = post.title_Echd
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLbl_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        titleLbl_Echd.numberOfLines = 1
        infoView_Echd.addSubview(titleLbl_Echd)

        // 内容预览
        let contentLbl_Echd = UILabel()
        contentLbl_Echd.text = post.titleContent_Echd
        contentLbl_Echd.font = UIFont.systemFont(ofSize: 12)
        contentLbl_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        contentLbl_Echd.numberOfLines = 2
        infoView_Echd.addSubview(contentLbl_Echd)

        // 点赞数
        let likeRow_Echd = UIView()
        infoView_Echd.addSubview(likeRow_Echd)

        let heartIV_Echd = UIImageView()
        let hCfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        heartIV_Echd.image = UIImage(systemName: "flame.fill", withConfiguration: hCfg_Echd)
        heartIV_Echd.tintColor = UIColor(hexstring_Echd: "#F43F5E")
        likeRow_Echd.addSubview(heartIV_Echd)

        let likeCnt_Echd = UILabel()
        likeCnt_Echd.text = "\(post.likes_Echd)"
        likeCnt_Echd.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        likeCnt_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        likeRow_Echd.addSubview(likeCnt_Echd)

        // MARK: 约束
        innerView_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(170)
        }
        gradMask_Echd.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(mediaView_Echd)
            make.height.equalTo(60)
        }
        reportBtn_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        infoView_Echd.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Echd.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        bar_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(4)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
        }
        contentLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(4)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
        }
        likeRow_Echd.snp.makeConstraints { make in
            make.top.equalTo(contentLbl_Echd.snp.bottom).offset(8)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(16)
        }
        heartIV_Echd.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        likeCnt_Echd.snp.makeConstraints { make in
            make.leading.equalTo(heartIV_Echd.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        // 点击进入详情
        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(postCardTapped_Echd(_:)))
        cardView_Echd.addGestureRecognizer(tap_Echd)
        cardView_Echd.tag = post.titleId_Echd

        return cardView_Echd
    }

    // MARK: - 分段选择器样式更新

    /// 更新分段选择器的视觉状态
    /// - Parameter animated: 是否带动画
    private func updateSegmentUI_Echd(animated: Bool) {
        let targetX_Echd: CGFloat = selectedTab_Echd == 0
            ? segmentContainer_Echd.bounds.minX + 4
            : segmentContainer_Echd.bounds.midX + 4

        let updateBlock_Echd = {
            let halfW_Echd = (UIScreen.main.bounds.width - 32) / 2 - 8
            self.segmentIndicator_Echd.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.width.equalTo(halfW_Echd)
                if self.selectedTab_Echd == 0 {
                    make.leading.equalToSuperview().offset(4)
                } else {
                    make.trailing.equalToSuperview().offset(-4)
                }
            }
            self.segmentContainer_Echd.layoutIfNeeded()

            // 按钮文字颜色
            self.postsTabButton_Echd.setTitleColor(
                self.selectedTab_Echd == 0 ? .white : UIColor(hexstring_Echd: "#6B7280"),
                for: .normal
            )
            self.postsTabButton_Echd.titleLabel?.font = UIFont.systemFont(
                ofSize: 14, weight: self.selectedTab_Echd == 0 ? .bold : .medium
            )
            self.likedTabButton_Echd.setTitleColor(
                self.selectedTab_Echd == 1 ? .white : UIColor(hexstring_Echd: "#6B7280"),
                for: .normal
            )
            self.likedTabButton_Echd.titleLabel?.font = UIFont.systemFont(
                ofSize: 14, weight: self.selectedTab_Echd == 1 ? .bold : .medium
            )
        }

        // 忽略 targetX_Echd 未使用的警告（保留变量供未来扩展帧动画）
        _ = targetX_Echd

        if animated {
            UIView.animate(withDuration: AnimationConfig_Echd.durationFast_Echd, delay: 0.5,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: updateBlock_Echd)
        } else {
            updateBlock_Echd()
        }
    }

    // MARK: - 事件处理

    @objc private func settingTapped_Echd() {
        Navigation_Echd.toSetting_Echd(style_echd: .push_echd)
    }

    /// 点击 VIP 订阅按钮，跳转到 VIP 订阅页面
    @objc private func vipTapped_Echd() {
        Navigation_Echd.toVIPSubscription_Echd(style_echd: .push_echd)
    }

    @objc private func editProfileTapped_Echd() {
        Navigation_Echd.toEditInfo_Echd(style_echd: .push_echd)
    }

    @objc private func postsTabTapped_Echd() {
        guard selectedTab_Echd != 0 else { return }
        selectedTab_Echd = 0
        updateSegmentUI_Echd(animated: true)
        refreshPostsList_Echd()
    }

    @objc private func likedTabTapped_Echd() {
        guard selectedTab_Echd != 1 else { return }
        selectedTab_Echd = 1
        updateSegmentUI_Echd(animated: true)
        refreshPostsList_Echd()
    }

    @objc private func postCardTapped_Echd(_ gesture: UITapGestureRecognizer) {
        guard let card_Echd = gesture.view else { return }
        let allPosts_Echd = TitleViewModel_Echd.shared_Echd.getPosts_Echd()
        if let post_Echd = allPosts_Echd.first(where: { $0.titleId_Echd == card_Echd.tag }) {
            card_Echd.animatePressDown_Echd { card_Echd.animatePressUp_Echd() }
            Navigation_Echd.toTitleDetail_Echd(titleModel_echd: post_Echd, style_echd: .push_echd)
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        [UserViewModel_Echd.userStateDidChangeNotification_Echd,
         TitleViewModel_Echd.titleStateDidChangeNotification_Echd].forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleStateChange_Echd),
                name: $0,
                object: nil
            )
        }
    }

    @objc private func handleStateChange_Echd() {
        refreshUI_Echd()
    }
}

// MARK: - 媒体底部渐变蒙版（Me 页专用）

/// Me 页帖子卡片媒体区底部渐变蒙版，防止与外部 GradientOverlayView 命名冲突
private class MeGradientOverlay_Echd: UIView {
    private let grad_Echd = CAGradientLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        grad_Echd.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.15).cgColor]
        grad_Echd.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Echd.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(grad_Echd, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        grad_Echd.frame = bounds
    }
}
