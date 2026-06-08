import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 我的页面
/// 功能：展示当前登录用户信息；切换「已发布帖子 / 喜欢帖子」；帖子右上角举报/删除
/// 设计亮点：
///   • 玫瑰→紫罗兰渐变头部（区别于全站其他页面的紫→蓝调色板）
///   • 头像悬浮在白色个人信息卡顶部，头像下半部嵌入卡片，营造层次感
///   • 个人信息卡内：用户名 + 时尚标签 + 统计数值双列
///   • 自定义胶囊 Tab（玫瑰色激活态 / 透明未激活态）
///   • 紫调阴影网格 + 8 色渐变占位
class Me_Vestir: UIViewController {

    // MARK: - 属性

    var meModel_Vestir: LoginUserModel_Vestir?

    private var currentUser_Vestir: LoginUserModel_Vestir {
        return meModel_Vestir ?? UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
    }

    private var selectedTab_Vestir: Int = 0

    // MARK: - 渐变头部（玫瑰→紫罗兰）

    private let headerShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#E11D48").cgColor
        v_Vestir.layer.shadowOpacity = 0.28
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 10)
        v_Vestir.layer.shadowRadius = 22
        return v_Vestir
    }()

    private let headerCard_Vestir = MeRoseVioletCard_Vestir()

    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        v_Vestir.layer.cornerRadius = 52
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let decoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FDA4AF", alpha_Vestir: 0.25)
        v_Vestir.layer.cornerRadius = 34
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 设置按钮（白色半透明，右上角）
    private let settingBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn_Vestir.setImage(
            UIImage(systemName: "gearshape.fill", withConfiguration: cfg_Vestir),
            for: .normal
        )
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    // MARK: - 悬浮头像（中心跨越头部与信息卡边界）

    private let avatarRing_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 48
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let avatarRingGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(white: 1.0, alpha: 0.95).cgColor,
            UIColor(white: 1.0, alpha: 0.50).cgColor
        ]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    private let avatarView_Vestir: CurrentUserAvatarView_Vestir = {
        let av_Vestir = CurrentUserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 42
        av_Vestir.clipsToBounds = true
        return av_Vestir
    }()

    private let avatarEditBadge_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#E11D48")
        v_Vestir.layer.cornerRadius = 13
        v_Vestir.clipsToBounds = true
        v_Vestir.layer.borderWidth = 2
        v_Vestir.layer.borderColor = UIColor.white.cgColor
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let avatarEditIcon_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        iv_Vestir.image = UIImage(systemName: "pencil", withConfiguration: cfg_Vestir)
        iv_Vestir.tintColor = .white
        iv_Vestir.contentMode = .scaleAspectFit
        iv_Vestir.isUserInteractionEnabled = false
        return iv_Vestir
    }()

    // MARK: - 悬浮个人信息卡（白色，头像嵌入顶部）

    private let profileCardShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#E11D48").cgColor
        v_Vestir.layer.shadowOpacity = 0.14
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_Vestir.layer.shadowRadius = 18
        return v_Vestir
    }()

    private let profileCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 26
        v_Vestir.clipsToBounds = false
        return v_Vestir
    }()

    private let userNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 时尚标签徽章（玫瑰色）
    private let fashionTagLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "  ✦ Fashion Creator  "
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Vestir.textColor = UIColor(hexstring_Vestir: "#E11D48")
        lbl_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FFE4E6")
        lbl_Vestir.layer.cornerRadius = 10
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 统计分隔线（竖向，16pt 高）
    private let statsDivider_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir
        return v_Vestir
    }()

    private let postsCountLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let postsDescLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Posts"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let likesCountLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let likesDescLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Liked"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 关注数量标签
    private let followingCountLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// "Following" 描述标签
    private let followingDescLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Following"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 统计区第二条竖向分隔线
    private let statsDivider2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir
        return v_Vestir
    }()

    /// 个人简介（二行，灰色，隐藏时 isHidden）
    private let bioLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        lbl_Vestir.textAlignment = .center
        lbl_Vestir.numberOfLines = 2
        lbl_Vestir.isHidden = true
        return lbl_Vestir
    }()

    // MARK: - 自定义胶囊 Tab（玫瑰激活 / 透明未激活）

    private let tabContainer_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 20
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#E11D48").cgColor
        v_Vestir.layer.shadowOpacity = 0.10
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Vestir.layer.shadowRadius = 12
        return v_Vestir
    }()

    private lazy var postsTabBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.setTitle("My Posts", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#E11D48")
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(postsTabTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    private lazy var likedTabBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.setTitle("Liked", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn_Vestir.setTitleColor(ColorConfig_Vestir.textSecondary_Vestir, for: .normal)
        btn_Vestir.backgroundColor = .clear
        // 确保选中时圆角与 postsTabBtn 一致
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(likedTabTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    // MARK: - 滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    private let postsGrid_Vestir: UIStackView = {
        let sv_Vestir = UIStackView()
        sv_Vestir.axis = .vertical
        sv_Vestir.spacing = 12
        return sv_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        bindNotifications_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadData_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarRingGradLayer_Vestir.frame = avatarRing_Vestir.bounds
        avatarRingGradLayer_Vestir.cornerRadius = 48
        if headerShadow_Vestir.bounds.width > 0 {
            headerShadow_Vestir.layer.shadowPath = UIBezierPath(
                roundedRect: headerShadow_Vestir.bounds, cornerRadius: 0
            ).cgPath
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerShadow_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 80)
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)

        // 渐变头部
        contentView_Vestir.addSubview(headerShadow_Vestir)
        headerShadow_Vestir.addSubview(headerCard_Vestir)
        headerCard_Vestir.addSubview(decoCircle1_Vestir)
        headerCard_Vestir.addSubview(decoCircle2_Vestir)
        headerCard_Vestir.addSubview(settingBtn_Vestir)

        // 个人信息卡（先加入，z 轴低于头像）
        contentView_Vestir.addSubview(profileCardShadow_Vestir)
        profileCardShadow_Vestir.addSubview(profileCard_Vestir)
        profileCard_Vestir.addSubview(userNameLabel_Vestir)
        profileCard_Vestir.addSubview(bioLabel_Vestir)
        profileCard_Vestir.addSubview(fashionTagLabel_Vestir)
        profileCard_Vestir.addSubview(statsDivider_Vestir)
        profileCard_Vestir.addSubview(statsDivider2_Vestir)
        profileCard_Vestir.addSubview(postsCountLabel_Vestir)
        profileCard_Vestir.addSubview(postsDescLabel_Vestir)
        profileCard_Vestir.addSubview(followingCountLabel_Vestir)
        profileCard_Vestir.addSubview(followingDescLabel_Vestir)
        profileCard_Vestir.addSubview(likesCountLabel_Vestir)
        profileCard_Vestir.addSubview(likesDescLabel_Vestir)

        // 悬浮头像（后加入，z 轴高于个人信息卡，确保头像不被遮住）
        contentView_Vestir.addSubview(avatarRing_Vestir)
        avatarRing_Vestir.layer.insertSublayer(avatarRingGradLayer_Vestir, at: 0)
        avatarRing_Vestir.addSubview(avatarView_Vestir)
        contentView_Vestir.addSubview(avatarEditBadge_Vestir)
        avatarEditBadge_Vestir.addSubview(avatarEditIcon_Vestir)

        // 自定义 Tab
        contentView_Vestir.addSubview(tabContainer_Vestir)
        tabContainer_Vestir.addSubview(postsTabBtn_Vestir)
        tabContainer_Vestir.addSubview(likedTabBtn_Vestir)

        contentView_Vestir.addSubview(postsGrid_Vestir)

        settingBtn_Vestir.addTarget(self, action: #selector(settingTapped_Vestir), for: .touchUpInside)

        avatarView_Vestir.onTapped_Vestir = {
            Navigation_Vestir.toEditInfo_Vestir(style_vestir: .push_vestir)
        }
    }

    private func setupConstraints_Vestir() {
        scrollView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 渐变头部
        headerShadow_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 80)
        }
        headerCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(104)
            make.trailing.equalToSuperview().offset(26)
            make.top.equalToSuperview().offset(-26)
        }
        decoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(68)
            make.leading.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(18)
        }

        settingBtn_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(32)
        }

        // 悬浮头像（中心与 headerShadow 底边对齐，形成"悬浮"效果）
        avatarRing_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(headerShadow_Vestir.snp.bottom)
            make.width.height.equalTo(96)
        }
        avatarView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(86)
        }
        avatarEditBadge_Vestir.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRing_Vestir.snp.trailing).offset(2)
            make.bottom.equalTo(avatarRing_Vestir.snp.bottom).offset(2)
            make.width.height.equalTo(26)
        }
        avatarEditIcon_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }

        // 个人信息卡（顶边与头像中心对齐）
        profileCardShadow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(headerShadow_Vestir.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        profileCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 信息卡内容（上方留 54pt 给头像下半部分）
        userNameLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // 个人简介（有内容时显示，无内容时隐藏不占空间）
        bioLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Vestir.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }

        fashionTagLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Vestir.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
        }

        // 统计区（三列：Posts | Following | Liked）
        // 第一条分隔线：宽 1pt，固定高 36pt，垂直居中于统计数值，位于卡片 1/3 处
        statsDivider_Vestir.snp.makeConstraints { make in
            make.top.equalTo(fashionTagLabel_Vestir.snp.bottom).offset(16)
            make.width.equalTo(1)
            make.height.equalTo(36)
            make.centerX.equalToSuperview().multipliedBy(0.667)
        }
        // 第二条分隔线：与第一条同样尺寸，位于卡片 2/3 处
        statsDivider2_Vestir.snp.makeConstraints { make in
            make.top.equalTo(statsDivider_Vestir)
            make.width.equalTo(1)
            make.height.equalTo(36)
            make.centerX.equalToSuperview().multipliedBy(1.334)
        }

        // Posts（左列：leading → 第一分隔线）
        postsCountLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(fashionTagLabel_Vestir.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalTo(statsDivider_Vestir.snp.leading).offset(-4)
        }
        postsDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Vestir.snp.bottom).offset(3)
            make.leading.trailing.equalTo(postsCountLabel_Vestir)
            make.bottom.equalToSuperview().offset(-20)
        }

        // Following（中列：第一分隔线 → 第二分隔线）
        followingCountLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Vestir)
            make.leading.equalTo(statsDivider_Vestir.snp.trailing).offset(4)
            make.trailing.equalTo(statsDivider2_Vestir.snp.leading).offset(-4)
        }
        followingDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(followingCountLabel_Vestir.snp.bottom).offset(3)
            make.leading.trailing.equalTo(followingCountLabel_Vestir)
        }

        // Liked（右列：第二分隔线 → trailing）
        likesCountLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsCountLabel_Vestir)
            make.leading.equalTo(statsDivider2_Vestir.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-8)
        }
        likesDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(likesCountLabel_Vestir.snp.bottom).offset(3)
            make.leading.trailing.equalTo(likesCountLabel_Vestir)
        }

        // 自定义 Tab
        tabContainer_Vestir.snp.makeConstraints { make in
            make.top.equalTo(profileCardShadow_Vestir.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        // 两个 Tab 等宽，中间留 4pt 间距
        postsTabBtn_Vestir.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(4)
            make.width.equalTo(likedTabBtn_Vestir)
        }
        likedTabBtn_Vestir.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(4)
            make.leading.equalTo(postsTabBtn_Vestir.snp.trailing).offset(4)
        }

        // 网格
        postsGrid_Vestir.snp.makeConstraints { make in
            make.top.equalTo(tabContainer_Vestir.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 数据

    private func loadData_Vestir() {
        let user_Vestir = currentUser_Vestir
        userNameLabel_Vestir.text = user_Vestir.userName_Vestir ?? "User"
        postsCountLabel_Vestir.text = "\(user_Vestir.userPosts_Vestir.count)"
        likesCountLabel_Vestir.text = "\(user_Vestir.userLike_Vestir.count)"
        followingCountLabel_Vestir.text = "\(user_Vestir.userFollow_Vestir.count)"

        // 从登录用户模型读取个人简介并展示
        if let intro_Vestir = user_Vestir.userIntroduce_Vestir, !intro_Vestir.isEmpty {
            bioLabel_Vestir.text = intro_Vestir
            bioLabel_Vestir.isHidden = false
        } else {
            bioLabel_Vestir.isHidden = true
        }

        rebuildGrid_Vestir()
    }

    private func rebuildGrid_Vestir() {
        postsGrid_Vestir.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let user_Vestir = currentUser_Vestir
        let posts_Vestir = (selectedTab_Vestir == 0) ? user_Vestir.userPosts_Vestir : user_Vestir.userLike_Vestir

        if posts_Vestir.isEmpty {
            let emptyLabel_Vestir = UILabel()
            emptyLabel_Vestir.text = selectedTab_Vestir == 0
                ? "No posts yet. Share your first OOTD!"
                : "No liked posts yet."
            emptyLabel_Vestir.font = UIFont.systemFont(ofSize: 14)
            emptyLabel_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
            emptyLabel_Vestir.textAlignment = .center
            emptyLabel_Vestir.numberOfLines = 0
            postsGrid_Vestir.addArrangedSubview(emptyLabel_Vestir)
            return
        }

        var row_Vestir: UIStackView?
        for (idx_Vestir, post_Vestir) in posts_Vestir.enumerated() {
            if idx_Vestir % 2 == 0 {
                let rowStack_Vestir = UIStackView()
                rowStack_Vestir.axis = .horizontal
                rowStack_Vestir.spacing = 12
                rowStack_Vestir.distribution = .fillEqually
                postsGrid_Vestir.addArrangedSubview(rowStack_Vestir)
                row_Vestir = rowStack_Vestir
            }
            let cell_Vestir = buildGridCell_Vestir(post_vestir: post_Vestir)
            cell_Vestir.alpha = 0
            row_Vestir?.addArrangedSubview(cell_Vestir)
            cell_Vestir.animateSpringScaleIn_Vestir(delay_Vestir: Double(idx_Vestir) * 0.05)
        }
        if posts_Vestir.count % 2 == 1 { row_Vestir?.addArrangedSubview(UIView()) }
    }

    private func buildGridCell_Vestir(post_vestir: TitleModel_Vestir) -> UIView {
        let cell_Vestir = UIView()
        cell_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        cell_Vestir.layer.cornerRadius = 18
        cell_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#E11D48").cgColor
        cell_Vestir.layer.shadowOpacity = 0.12
        cell_Vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell_Vestir.layer.shadowRadius = 12

        let mediaView_Vestir = MediaDisplayView_Vestir()
        mediaView_Vestir.layer.cornerRadius = 14
        mediaView_Vestir.clipsToBounds = true
        mediaView_Vestir.customPlaceholderColors_Vestir = DiscoverCell_Vestir.cardGradients_Vestir[
            post_vestir.titleId_Vestir % DiscoverCell_Vestir.cardGradients_Vestir.count
        ]
        mediaView_Vestir.configure_Vestir(mediaPath_Vestir: post_vestir.titleMeidas_Vestir.first)

        let titleLabel_Vestir = UILabel()
        titleLabel_Vestir.text = post_vestir.title_Vestir
        titleLabel_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        titleLabel_Vestir.numberOfLines = 1

        let likePill_Vestir = UILabel()
        likePill_Vestir.text = "♥ \(post_vestir.likes_Vestir)"
        likePill_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        likePill_Vestir.textColor = UIColor(hexstring_Vestir: "#E11D48")

        let reportBtn_Vestir = ReportDeleteHelper_Vestir.createPostReportButton_Vestir(
            post_Vestir: post_vestir,
            size_Vestir: 13,
            color_Vestir: ColorConfig_Vestir.textSecondary_Vestir,
            from: self
        ) { [weak self] in self?.loadData_Vestir() }

        cell_Vestir.addSubview(mediaView_Vestir)
        cell_Vestir.addSubview(titleLabel_Vestir)
        cell_Vestir.addSubview(likePill_Vestir)
        cell_Vestir.addSubview(reportBtn_Vestir)

        mediaView_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(130)
        }
        titleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Vestir.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-34)
        }
        likePill_Vestir.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Vestir.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(9)
            make.bottom.equalToSuperview().offset(-8)
        }
        reportBtn_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }

        let tap_Vestir = UITapGestureRecognizer(target: self, action: #selector(postCellTapped_Vestir(_:)))
        cell_Vestir.addGestureRecognizer(tap_Vestir)
        cell_Vestir.tag = post_vestir.titleId_Vestir
        cell_Vestir.isUserInteractionEnabled = true
        return cell_Vestir
    }

    private func bindNotifications_Vestir() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDataChanged_Vestir),
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDataChanged_Vestir),
            name: TitleViewModel_Vestir.titleStateDidChangeNotification_Vestir, object: nil)
    }

    @objc private func onDataChanged_Vestir() { loadData_Vestir() }

    // MARK: - 事件

    @objc private func settingTapped_Vestir() {
        settingBtn_Vestir.animatePressDown_Vestir { self.settingBtn_Vestir.animatePressUp_Vestir() }
        Navigation_Vestir.toSetting_Vestir(style_vestir: .push_vestir)
    }

    @objc private func postsTabTapped_Vestir() {
        selectedTab_Vestir = 0
        updateTabStyle_Vestir()
        rebuildGrid_Vestir()
    }

    @objc private func likedTabTapped_Vestir() {
        selectedTab_Vestir = 1
        updateTabStyle_Vestir()
        rebuildGrid_Vestir()
    }

    private func updateTabStyle_Vestir() {
        let isPost_Vestir = selectedTab_Vestir == 0
        UIView.animate(withDuration: 0.22) {
            self.postsTabBtn_Vestir.backgroundColor = isPost_Vestir
                ? UIColor(hexstring_Vestir: "#E11D48") : .clear
            self.postsTabBtn_Vestir.setTitleColor(
                isPost_Vestir ? .white : ColorConfig_Vestir.textSecondary_Vestir,
                for: .normal
            )
            self.likedTabBtn_Vestir.backgroundColor = isPost_Vestir
                ? .clear : UIColor(hexstring_Vestir: "#E11D48")
            self.likedTabBtn_Vestir.setTitleColor(
                isPost_Vestir ? ColorConfig_Vestir.textSecondary_Vestir : .white,
                for: .normal
            )
        }
    }

    @objc private func postCellTapped_Vestir(_ gesture: UITapGestureRecognizer) {
        guard let view_Vestir = gesture.view else { return }
        let id_Vestir = view_Vestir.tag
        let allPosts_Vestir = TitleViewModel_Vestir.shared_Vestir.getPosts_Vestir()
        if let post_Vestir = allPosts_Vestir.first(where: { $0.titleId_Vestir == id_Vestir })
            ?? currentUser_Vestir.userPosts_Vestir.first(where: { $0.titleId_Vestir == id_Vestir })
            ?? currentUser_Vestir.userLike_Vestir.first(where: { $0.titleId_Vestir == id_Vestir }) {
            Navigation_Vestir.toTitleDetail_Vestir(titleModel_vestir: post_Vestir)
        }
    }
}

// MARK: - 我的页面渐变背景（玫瑰→紫罗兰）

fileprivate final class MeRoseVioletCard_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#E11D48").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#7C3AED").cgColor
        ]
        g.locations = [0, 0.50, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 30
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}
