import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页面（预制用户）

/// 用户中心页面
/// 核心作用：展示指定预制用户的头像、昵称、简介、统计信息及其发布帖子列表，
///          支持对帖子举报/删除，右上角可举报/拉黑该用户，数据变动自动刷新
/// 设计思路：沉浸式渐变头部（双层渐变 + 多装饰元素）+ 悬浮统计卡（负偏移叠在头部底边）；
///          Posts 区头带渐变背景；双列帖子瀑布网格；精美空态卡片
/// 关键属性：
/// - userModel_Pane:  外部注入的预制用户模型
/// - userId_Pane:     通过 userId 快速注入（自动查找 userModel）
/// - posts_Pane:      该用户发布的帖子列表（实时从 TitleViewModel 取）
class UserInfo_Pane: UIViewController {

    // MARK: - 属性

    /// 外部传入的用户模型
    var userModel_Pane: PrewUserModel_Pane?

    /// 通过 userId 快速注入：自动从 LocalData 查找对应 PrewUserModel
    var userId_Pane: Int = 0 {
        didSet {
            userModel_Pane = LocalData_Pane.shared_Pane.userList_Pane.first {
                $0.userId_Pane == userId_Pane
            }
        }
    }

    /// 该用户发布的帖子列表（实时从 ViewModel 获取）
    private var posts_Pane: [TitleModel_Pane] {
        guard let u_pane = userModel_Pane else { return [] }
        return TitleViewModel_Pane.shared_Pane.getUserPosts_Pane(user_pane: u_pane)
    }

    /// 帖子网格高度约束（KVO 动态调整）
    private var postsCVHeightCon_Pane: Constraint?

    /// KVO 注册标志位：防止未注册时 deinit 崩溃
    private var isKVORegistered_Pane = false

    // MARK: - UI · 外层滚动

    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Pane = UIView()

    // MARK: - UI · 沉浸式头部

    private let headerCard_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    /// 主渐变（薰衣草紫 → 天空蓝，斜向）
    private var headerGradient_Pane: CAGradientLayer?

    /// 副渐变叠层（玫瑰粉 → 珊瑚橙，从右下角扩散，低不透明度营造"双色光晕"）
    private var headerOverlayGL_Pane: CAGradientLayer?

    /// 装饰圆 — 左上超大半透明圆（营造景深感）
    private let decorBigCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 90
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆 — 右上中圆
    private let decorMidCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        v.layer.cornerRadius = 52
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆 — 右中小圆
    private let decorSmCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 32
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆 — 左下微圆
    private let decorTinyCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 20
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 顶部细横线点缀（头像上方）
    private let topAccentLine_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        v.layer.cornerRadius = 1.5
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 底部横线点缀
    private let bottomAccentLine_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v.layer.cornerRadius = 1
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI · 头像区

    /// 头像最外层 "光晕" 容器（通过 shadow 营造发光感）
    private let avatarGlowView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = .clear
        v.layer.shadowColor  = UIColor(hexstring_Pane: "#B794F6").cgColor
        v.layer.shadowRadius = 18
        v.layer.shadowOpacity = 0.55
        v.layer.shadowOffset = .zero
        return v
    }()

    /// 头像渐变光环（套在头像外，比头像大 10pt）
    private let avatarRingView_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 54
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGL_Pane: CAGradientLayer?

    /// 头像本体
    private let avatarView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode       = .scaleAspectFill
        iv.clipsToBounds     = true
        iv.layer.cornerRadius = 46
        iv.backgroundColor   = UIColor.white.withAlphaComponent(0.25)
        iv.layer.borderWidth  = 3
        iv.layer.borderColor  = UIColor.white.cgColor
        return iv
    }()

    /// 在线绿点徽章
    private let onlineBadge_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor(hexstring_Pane: "#68D391")
        v.layer.cornerRadius = 8
        v.layer.borderWidth  = 2.5
        v.layer.borderColor  = UIColor.white.cgColor
        v.layer.shadowColor  = UIColor(hexstring_Pane: "#68D391").cgColor
        v.layer.shadowRadius = 4
        v.layer.shadowOpacity = 0.6
        v.layer.shadowOffset = .zero
        return v
    }()

    /// 用户名称
    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 23, weight: .heavy)
        l.textColor     = .white
        l.textAlignment = .center
        l.layer.shadowColor   = UIColor.black.withAlphaComponent(0.2).cgColor
        l.layer.shadowRadius  = 4
        l.layer.shadowOpacity = 1
        l.layer.shadowOffset  = CGSize(width: 0, height: 1)
        return l
    }()

    /// 用户简介
    private let introLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 13)
        l.textColor     = UIColor.white.withAlphaComponent(0.88)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI · 悬浮统计卡（叠在 header 底边）

    /// 悬浮统计卡，渐变背景（紫→蓝），通过负 top offset 叠在头部底边
    private let statsCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = .clear
        v.layer.cornerRadius = 24
        v.clipsToBounds      = false
        v.layer.shadowColor  = UIColor(hexstring_Pane: "#B794F6").withAlphaComponent(0.35).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius  = 18
        v.layer.shadowOffset  = CGSize(width: 0, height: 8)
        return v
    }()

    /// 统计卡渐变背景层容器（带 clipsToBounds 圆角）
    private let statsCardBg_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private var statsCardGL_Pane: CAGradientLayer?

    // MARK: - UI · Posts 区头

    private let postsSectionCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.cardBackground_Pane
        v.layer.shadowColor  = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius  = 8
        v.layer.shadowOffset  = CGSize(width: 0, height: 2)
        return v
    }()

    private let sectionAccentBar_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2.5
        return v
    }()

    private var sectionAccentGL_Pane: CAGradientLayer?

    private let sectionTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Posts"
        l.font      = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    private let sectionSubLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Latest creations"
        l.font      = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    private let postCountBadge_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    private var postCountBadgeGL_Pane: CAGradientLayer?

    private let postCountLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 帖子网格

    private lazy var postsCollectionView_Pane: UICollectionView = {
        let gap_pane: CGFloat = 10
        let side_pane: CGFloat = 14
        let w_pane = (UIScreen.main.bounds.width - gap_pane - side_pane * 2) / 2
        let layout_pane = UICollectionViewFlowLayout()
        layout_pane.itemSize                = CGSize(width: w_pane, height: w_pane * 1.35)
        layout_pane.minimumInteritemSpacing = gap_pane
        layout_pane.minimumLineSpacing      = gap_pane
        layout_pane.sectionInset = UIEdgeInsets(
            top: 12, left: side_pane, bottom: 20, right: side_pane
        )
        let cv_pane = UICollectionView(frame: .zero, collectionViewLayout: layout_pane)
        cv_pane.backgroundColor = .clear
        cv_pane.isScrollEnabled = false
        cv_pane.register(
            UserInfoPostCell_Pane.self,
            forCellWithReuseIdentifier: UserInfoPostCell_Pane.reuseId_Pane
        )
        return cv_pane
    }()

    // MARK: - UI · 空态占位卡

    private let emptyCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 24
        v.layer.borderWidth  = 1
        v.layer.borderColor  = ColorConfig_Pane.border_Pane.cgColor
        v.layer.shadowColor  = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius  = 14
        v.layer.shadowOffset  = CGSize(width: 0, height: 6)
        return v
    }()

    private let emptyIconView_Pane: UIImageView = {
        let iv = UIImageView()
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 40, weight: .ultraLight)
        iv.image       = UIImage(systemName: "rectangle.stack.badge.plus", withConfiguration: cfg_pane)
        iv.tintColor   = ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text          = "No Posts Yet"
        l.font          = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor     = ColorConfig_Pane.textSecondary_Pane
        l.textAlignment = .center
        return l
    }()

    private let emptySubLabel_Pane: UILabel = {
        let l = UILabel()
        l.text          = "This user hasn't shared anything yet.\nCheck back later!"
        l.font          = .systemFont(ofSize: 12)
        l.textColor     = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI · 导航栏

    private let navBar_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor          = .white
        b.backgroundColor    = UIColor.black.withAlphaComponent(0.25)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.3).cgColor
        return b
    }()

    private let reportButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        b.setImage(
            UIImage(systemName: "ellipsis", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor          = .white
        b.backgroundColor    = UIColor.black.withAlphaComponent(0.25)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.3).cgColor
        return b
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupActions_Pane()
        setupNotifications_Pane()
        fillHeader_Pane()
        reloadPosts_Pane()
        observePostsHeight_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Pane?.frame     = headerCard_Pane.bounds
        headerOverlayGL_Pane?.frame    = headerCard_Pane.bounds
        avatarRingGL_Pane?.frame       = avatarRingView_Pane.bounds
        // 更新统计卡主渐变及所有 sublayer frame
        if let bg_pane = statsCardBg_Pane.layer.sublayers {
            bg_pane.forEach { $0.frame = statsCardBg_Pane.bounds }
        }
        sectionAccentGL_Pane?.frame    = sectionAccentBar_Pane.bounds
        postCountBadgeGL_Pane?.frame   = postCountBadge_Pane.bounds
        applyHeaderCurvedBottom_Pane()
    }

    deinit {
        if isKVORegistered_Pane {
            postsCollectionView_Pane.removeObserver(self, forKeyPath: "contentSize")
        }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - KVO

    private func observePostsHeight_Pane() {
        postsCollectionView_Pane.addObserver(
            self, forKeyPath: "contentSize", options: [.new], context: nil
        )
        isKVORegistered_Pane = true
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "contentSize",
           let size_pane = change?[.newKey] as? CGSize {
            postsCVHeightCon_Pane?.update(offset: max(size_pane.height, 1))
            contentView_Pane.layoutIfNeeded()
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane

        view.addSubview(scrollView_Pane)
        scrollView_Pane.addSubview(contentView_Pane)

        // ── 头部 ──
        contentView_Pane.addSubview(headerCard_Pane)
        headerCard_Pane.addSubview(decorBigCircle_Pane)
        headerCard_Pane.addSubview(decorMidCircle_Pane)
        headerCard_Pane.addSubview(decorSmCircle_Pane)
        headerCard_Pane.addSubview(decorTinyCircle_Pane)
        headerCard_Pane.addSubview(topAccentLine_Pane)
        headerCard_Pane.addSubview(bottomAccentLine_Pane)
        // 头像层级：glow → ring → avatar → badge
        headerCard_Pane.addSubview(avatarGlowView_Pane)
        avatarGlowView_Pane.addSubview(avatarRingView_Pane)
        avatarRingView_Pane.addSubview(avatarView_Pane)
        headerCard_Pane.addSubview(onlineBadge_Pane)
        headerCard_Pane.addSubview(nameLabel_Pane)
        headerCard_Pane.addSubview(introLabel_Pane)
        setupHeaderGradients_Pane()
        setupAvatarRing_Pane()

        // ── 悬浮统计卡 ──
        contentView_Pane.addSubview(statsCard_Pane)
        statsCard_Pane.addSubview(statsCardBg_Pane)
        setupStatsCardGradient_Pane()
        buildStatsRow_Pane()

        // ── Posts 区头 ──
        contentView_Pane.addSubview(postsSectionCard_Pane)
        postsSectionCard_Pane.addSubview(sectionAccentBar_Pane)
        postsSectionCard_Pane.addSubview(sectionTitleLabel_Pane)
        postsSectionCard_Pane.addSubview(sectionSubLabel_Pane)
        postsSectionCard_Pane.addSubview(postCountBadge_Pane)
        postCountBadge_Pane.addSubview(postCountLabel_Pane)
        setupSectionHeader_Pane()

        // ── 帖子网格 ──
        contentView_Pane.addSubview(postsCollectionView_Pane)
        postsCollectionView_Pane.dataSource = self
        postsCollectionView_Pane.delegate   = self

        // ── 空态 ──
        contentView_Pane.addSubview(emptyCard_Pane)
        emptyCard_Pane.addSubview(emptyIconView_Pane)
        emptyCard_Pane.addSubview(emptyTitleLabel_Pane)
        emptyCard_Pane.addSubview(emptySubLabel_Pane)

        // ── 导航栏（最上层） ──
        view.addSubview(navBar_Pane)
        navBar_Pane.addSubview(backButton_Pane)
        navBar_Pane.addSubview(reportButton_Pane)

        setupConstraints_Pane()
    }

    /// 头部双层渐变：主渐变（斜向）+ 副渐变叠层（粉橙，右下角放射）
    private func setupHeaderGradients_Pane() {
        // 主渐变
        let main_pane = CAGradientLayer()
        main_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        main_pane.startPoint = CGPoint(x: 0, y: 0)
        main_pane.endPoint   = CGPoint(x: 1, y: 1)
        headerCard_Pane.layer.insertSublayer(main_pane, at: 0)
        headerGradient_Pane = main_pane

        // 副渐变叠层（右下角粉橙，低透明度）
        let overlay_pane = CAGradientLayer()
        overlay_pane.colors = [
            UIColor.clear.cgColor,
            ColorConfig_Pane.secondaryGradientEnd_Pane.withAlphaComponent(0.35).cgColor
        ]
        overlay_pane.startPoint = CGPoint(x: 0.2, y: 0)
        overlay_pane.endPoint   = CGPoint(x: 1,   y: 1)
        headerCard_Pane.layer.insertSublayer(overlay_pane, at: 1)
        headerOverlayGL_Pane = overlay_pane
    }

    /// 头像外环渐变光圈
    private func setupAvatarRing_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            UIColor.white.cgColor,
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.secondaryGradientStart_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        avatarRingView_Pane.layer.insertSublayer(gl_pane, at: 0)
        avatarRingGL_Pane = gl_pane
    }

    /// 统计卡渐变背景（紫 → 蓝 斜向）+ 右下粉橙叠层
    private func setupStatsCardGradient_Pane() {
        let main_pane = CAGradientLayer()
        main_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        main_pane.startPoint = CGPoint(x: 0, y: 0)
        main_pane.endPoint   = CGPoint(x: 1, y: 1)
        statsCardBg_Pane.layer.insertSublayer(main_pane, at: 0)
        statsCardGL_Pane = main_pane

        // 副叠层：右下角粉橙暖光
        let overlay_pane = CAGradientLayer()
        overlay_pane.colors = [
            UIColor.clear.cgColor,
            ColorConfig_Pane.secondaryGradientEnd_Pane.withAlphaComponent(0.3).cgColor
        ]
        overlay_pane.startPoint = CGPoint(x: 0, y: 0)
        overlay_pane.endPoint   = CGPoint(x: 1, y: 1)
        statsCardBg_Pane.layer.addSublayer(overlay_pane)

        // frame 在 layoutSubviews 中更新，此处先设为 zero
        overlay_pane.frame = .zero
    }

    /// Posts 区头辅助渐变（竖条 + 数量徽章）
    private func setupSectionHeader_Pane() {
        let bar_pane = CAGradientLayer()
        bar_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        bar_pane.startPoint = CGPoint(x: 0, y: 0)
        bar_pane.endPoint   = CGPoint(x: 0, y: 1)
        sectionAccentBar_Pane.layer.insertSublayer(bar_pane, at: 0)
        sectionAccentGL_Pane = bar_pane

        let badge_pane = CAGradientLayer()
        badge_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        badge_pane.startPoint = CGPoint(x: 0, y: 0)
        badge_pane.endPoint   = CGPoint(x: 1, y: 0)
        postCountBadge_Pane.layer.insertSublayer(badge_pane, at: 0)
        postCountBadgeGL_Pane = badge_pane
    }

    /// 构建悬浮统计卡三列（Posts / Fans / Following）
    private func buildStatsRow_Pane() {
        let items_pane: [(String, String, String)] = [
            ("square.grid.2x2.fill", "\(posts_Pane.count)", "Posts"),
            ("heart.fill",           "\(userModel_Pane?.userFans_Pane ?? 0)", "Fans"),
            ("person.2.fill",        "\(userModel_Pane?.userFollow_Pane ?? 0)", "Following")
        ]
        let stack_pane = UIStackView()
        stack_pane.axis         = .horizontal
        stack_pane.distribution = .fillEqually
        stack_pane.alignment    = .center
        // 添加到渐变背景容器
        statsCardBg_Pane.addSubview(stack_pane)
        stack_pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        for (idx_pane, (icon_pane, val_pane, title_pane)) in items_pane.enumerated() {
            let col_pane = makeStatCol_Pane(icon: icon_pane, value: val_pane, title: title_pane)
            stack_pane.addArrangedSubview(col_pane)
            if idx_pane < items_pane.count - 1 {
                let div_pane = UIView()
                div_pane.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                div_pane.snp.makeConstraints {
                    $0.width.equalTo(0.5)
                    $0.height.equalTo(36)
                }
                stack_pane.addArrangedSubview(div_pane)
            }
        }
    }

    /// 生成统计列（图标 + 数值 + 标题）
    /// - Parameters:
    ///   - icon_pane:  SF Symbol 图标名
    ///   - value_pane: 数值文本
    ///   - title_pane: 标题文本
    private func makeStatCol_Pane(icon: String, value: String, title: String) -> UIView {
        let col_pane = UIView()

        let iv_pane = UIImageView()
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv_pane.image     = UIImage(systemName: icon, withConfiguration: cfg_pane)
        iv_pane.tintColor = UIColor.white.withAlphaComponent(0.9)
        iv_pane.contentMode = .scaleAspectFit

        let valLbl_pane = UILabel()
        valLbl_pane.text          = value
        valLbl_pane.font          = .systemFont(ofSize: 20, weight: .heavy)
        valLbl_pane.textColor     = .white
        valLbl_pane.textAlignment = .center

        let titleLbl_pane = UILabel()
        titleLbl_pane.text          = title
        titleLbl_pane.font          = .systemFont(ofSize: 10, weight: .medium)
        titleLbl_pane.textColor     = UIColor.white.withAlphaComponent(0.72)
        titleLbl_pane.textAlignment = .center

        col_pane.addSubview(iv_pane)
        col_pane.addSubview(valLbl_pane)
        col_pane.addSubview(titleLbl_pane)

        iv_pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(14)
            $0.width.height.equalTo(16)
        }
        valLbl_pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(iv_pane.snp.bottom).offset(4)
        }
        titleLbl_pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(valLbl_pane.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-14)
        }
        return col_pane
    }

    /// 为头部底边应用大圆角遮罩，形成柔和弧形底边
    private func applyHeaderCurvedBottom_Pane() {
        guard headerCard_Pane.bounds.width > 0 else { return }
        let path_pane = UIBezierPath(
            roundedRect: headerCard_Pane.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 40, height: 40)
        )
        let mask_pane = CAShapeLayer()
        mask_pane.path = path_pane.cgPath
        headerCard_Pane.layer.mask = mask_pane
    }

    // MARK: - 约束

    private func setupConstraints_Pane() {
        scrollView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // ── 头部 ──
        headerCard_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        decorBigCircle_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-30)
            $0.leading.equalToSuperview().offset(-30)
            $0.width.height.equalTo(180)
        }
        decorMidCircle_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-20)
            $0.trailing.equalToSuperview().offset(20)
            $0.width.height.equalTo(104)
        }
        decorSmCircle_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.height.equalTo(64)
        }
        decorTinyCircle_Pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(40)
        }
        topAccentLine_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(3)
        }
        bottomAccentLine_Pane.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-22)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(64)
            $0.height.equalTo(2)
        }

        // ── 头像 ──
        avatarGlowView_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.width.height.equalTo(108)
        }
        avatarRingView_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(108)
        }
        avatarView_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(92)
        }
        onlineBadge_Pane.snp.makeConstraints {
            $0.trailing.equalTo(avatarGlowView_Pane.snp.trailing).offset(-2)
            $0.bottom.equalTo(avatarGlowView_Pane.snp.bottom).offset(-2)
            $0.width.height.equalTo(16)
        }

        // ── 名称 / 简介 ──
        nameLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(avatarGlowView_Pane.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        introLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Pane.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
            // 简介底部给统计卡留出悬浮露出空间
            $0.bottom.equalToSuperview().offset(-52)
        }

        // ── 悬浮统计卡（叠在 header 底边 -36pt）──
        statsCard_Pane.snp.makeConstraints {
            $0.top.equalTo(headerCard_Pane.snp.bottom).offset(-36)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        statsCardBg_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // ── Posts 区头 ──
        postsSectionCard_Pane.snp.makeConstraints {
            $0.top.equalTo(statsCard_Pane.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        sectionAccentBar_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(5)
            $0.height.equalTo(22)
        }
        sectionTitleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(sectionAccentBar_Pane.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(11)
        }
        sectionSubLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(sectionTitleLabel_Pane)
            $0.top.equalTo(sectionTitleLabel_Pane.snp.bottom).offset(2)
        }
        postCountBadge_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-18)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }
        postCountLabel_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }

        // ── 帖子网格 ──
        postsCollectionView_Pane.snp.makeConstraints {
            $0.top.equalTo(postsSectionCard_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            postsCVHeightCon_Pane = $0.height.equalTo(1).constraint
            $0.bottom.equalToSuperview()
        }

        // ── 空态 ──
        emptyCard_Pane.snp.makeConstraints {
            $0.top.equalTo(postsSectionCard_Pane.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().offset(-40)
        }
        emptyIconView_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
            $0.width.height.equalTo(56)
        }
        emptyTitleLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(emptyIconView_Pane.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        emptySubLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel_Pane.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-40)
        }

        // ── 导航栏 ──
        navBar_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        reportButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
    }

    // MARK: - 数据填充

    private func fillHeader_Pane() {
        guard let u_pane = userModel_Pane else { return }
        nameLabel_Pane.text  = u_pane.userName_Pane ?? "—"
        introLabel_Pane.text = (u_pane.userIntroduce_Pane?.isEmpty == false)
            ? u_pane.userIntroduce_Pane
            : "No intro yet."
        if let head_pane = u_pane.userHead_Pane {
            avatarView_Pane.image = UIImage(named: head_pane)
        }
    }

    private func reloadPosts_Pane() {
        let hasPost_pane             = !posts_Pane.isEmpty
        emptyCard_Pane.isHidden      = hasPost_pane
        postsCollectionView_Pane.isHidden = !hasPost_pane
        postCountLabel_Pane.text     = "\(posts_Pane.count)"
        postsCollectionView_Pane.reloadData()
    }

    // MARK: - 通知

    private func setupNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Pane),
            name: TitleViewModel_Pane.titleStateDidChangeNotification_Pane,
            object: nil
        )
    }

    @objc private func onDataChanged_Pane() { reloadPosts_Pane() }

    // MARK: - 事件

    private func setupActions_Pane() {
        backButton_Pane.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)
        reportButton_Pane.addTarget(self, action: #selector(reportTapped_Pane), for: .touchUpInside)
    }

    @objc private func backTapped_Pane() {
        navigationController?.popViewController(animated: true)
    }

    /// 举报/拉黑该用户，操作完成后自动返回上一页
    @objc private func reportTapped_Pane() {
        guard let user_pane = userModel_Pane else { return }
        UIView.animate(withDuration: 0.1, animations: {
            self.reportButton_Pane.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        }) { _ in
            UIView.animate(withDuration: 0.14) {
                self.reportButton_Pane.transform = .identity
            }
        }
        ReportDeleteHelper_Pane.block_Pane(user_Pane: user_pane, from: self) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension UserInfo_Pane: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int { posts_Pane.count }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell_pane = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserInfoPostCell_Pane.reuseId_Pane, for: indexPath
        ) as! UserInfoPostCell_Pane
        let post_pane = posts_Pane[indexPath.item]
        cell_pane.configure_Pane(post_pane: post_pane, from: self) { [weak self] in
            self?.reloadPosts_Pane()
        }
        return cell_pane
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let post_pane = posts_Pane[indexPath.item]
        let detail_pane = Detail_Pane()
        detail_pane.titleModel_Pane = post_pane
        Navigation_Pane.push_Pane(to: detail_pane, from: self)
    }
}

// MARK: - UserInfoPostCell_Pane

/// 用户中心帖子 Cell
/// 核心作用：圆角卡片展示帖子（全幅媒体 + 底部渐变遮罩信息区），右上角操作按钮
/// 设计思路：媒体全覆盖 + 三层底部渐变 + 主题胶囊标签 + 点赞行；卡片带阴影浮起感
private class UserInfoPostCell_Pane: UICollectionViewCell {

    static let reuseId_Pane = "UserInfoPostCell_Pane"

    // MARK: - 子视图

    private let mediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.clipsToBounds = true
        return v
    }()

    private let infoOverlay_Pane = UIView()
    private var infoOverlayGL_Pane: CAGradientLayer?

    /// 左上主题胶囊
    private let themeChip_Pane: UILabel = {
        let l = UILabel()
        l.font               = .systemFont(ofSize: 9, weight: .bold)
        l.textColor          = .white
        l.backgroundColor    = UIColor(hexstring_Pane: "#B794F6").withAlphaComponent(0.75)
        l.layer.cornerRadius = 8
        l.clipsToBounds      = true
        l.textAlignment      = .center
        return l
    }()

    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = .white
        l.numberOfLines = 2
        l.layer.shadowColor   = UIColor.black.withAlphaComponent(0.4).cgColor
        l.layer.shadowRadius  = 2
        l.layer.shadowOpacity = 1
        l.layer.shadowOffset  = .zero
        return l
    }()

    private let likeRow_Pane = UIView()

    private let likeIconView_Pane: UIImageView = {
        let iv = UIImageView()
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 9, weight: .medium)
        iv.image     = UIImage(systemName: "heart.fill", withConfiguration: cfg_pane)
        iv.tintColor = UIColor(hexstring_Pane: "#FC8181")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likeCountLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.9)
        return l
    }()

    private var actionButton_Pane: UIButton?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        // 外层 cell 留 shadow 空间（clipsToBounds = false）
        layer.cornerRadius   = 14
        layer.shadowColor    = UIColor(hexstring_Pane: "#B794F6").withAlphaComponent(0.22).cgColor
        layer.shadowRadius   = 10
        layer.shadowOpacity  = 1
        layer.shadowOffset   = CGSize(width: 0, height: 5)

        contentView.clipsToBounds     = true
        contentView.layer.cornerRadius = 14
        contentView.backgroundColor   = ColorConfig_Pane.backgroundSecondary_Pane

        infoOverlay_Pane.isUserInteractionEnabled = false
        likeRow_Pane.isUserInteractionEnabled      = false

        contentView.addSubview(mediaView_Pane)
        contentView.addSubview(infoOverlay_Pane)
        contentView.addSubview(themeChip_Pane)
        contentView.addSubview(titleLabel_Pane)
        contentView.addSubview(likeRow_Pane)
        likeRow_Pane.addSubview(likeIconView_Pane)
        likeRow_Pane.addSubview(likeCountLabel_Pane)

        mediaView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        infoOverlay_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.55)
        }
        themeChip_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(16)
        }
        likeRow_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        likeIconView_Pane.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        likeCountLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(likeIconView_Pane.snp.trailing).offset(4)
            $0.centerY.trailing.equalToSuperview()
        }
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(likeRow_Pane.snp.top).offset(-6)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        infoOverlayGL_Pane?.frame = infoOverlay_Pane.bounds
        // 同步更新 shadow path 以获得准确阴影
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds, cornerRadius: 14
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        actionButton_Pane?.removeFromSuperview()
        actionButton_Pane = nil
        themeChip_Pane.isHidden = false
    }

    // MARK: - 配置

    /// 填充帖子数据并绑定操作按钮
    /// - Parameters:
    ///   - post_pane:            帖子模型
    ///   - viewController_pane: 来源 VC
    ///   - completion_pane:     操作完成刷新回调
    func configure_Pane(
        post_pane: TitleModel_Pane,
        from viewController_pane: UIViewController,
        completion_pane: (() -> Void)? = nil
    ) {
        titleLabel_Pane.text     = post_pane.title_Pane
        likeCountLabel_Pane.text = "\(post_pane.likes_Pane)"
        mediaView_Pane.configure_Pane(
            mediaPath_Pane: post_pane.titleMeidas_Pane.first,
            isVideo_Pane: false
        )

        // 主题胶囊
        if post_pane.titleTheme_Pane.isEmpty {
            themeChip_Pane.isHidden = true
        } else {
            themeChip_Pane.isHidden = false
            themeChip_Pane.text = " \(post_pane.titleTheme_Pane) "
        }

        // 三段底部渐变遮罩（仅创建一次）
        if infoOverlayGL_Pane == nil {
            let gl_pane = CAGradientLayer()
            gl_pane.colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.3).cgColor,
                UIColor.black.withAlphaComponent(0.78).cgColor
            ]
            gl_pane.locations  = [0, 0.4, 1]
            gl_pane.startPoint = CGPoint(x: 0.5, y: 0)
            gl_pane.endPoint   = CGPoint(x: 0.5, y: 1)
            infoOverlay_Pane.layer.insertSublayer(gl_pane, at: 0)
            infoOverlayGL_Pane = gl_pane
        }

        // 操作按钮
        actionButton_Pane?.removeFromSuperview()
        let btn_pane = ReportDeleteHelper_Pane.createPostReportButton_Pane(
            post_Pane: post_pane,
            size_Pane: 11,
            color_Pane: .white,
            from: viewController_pane,
            completion_Pane: completion_pane
        )
        btn_pane.backgroundColor    = UIColor.black.withAlphaComponent(0.38)
        btn_pane.layer.cornerRadius = 13
        btn_pane.clipsToBounds      = true
        contentView.addSubview(btn_pane)
        btn_pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.trailing.equalToSuperview().offset(-7)
            $0.width.height.equalTo(26)
        }
        actionButton_Pane = btn_pane
    }
}
