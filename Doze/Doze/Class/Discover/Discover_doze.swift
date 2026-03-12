import UIKit
import SnapKit

// MARK: 发现页

/// 发现页视图控制器
/// 功能：关键词搜索、宠物类别筛选、非规则双列瀑布流展示宠物睡眠社区帖子
/// 设计：浅色主题 + 深色渐变英雄 Header（带装饰层）+ 卡片彩色口音 + 流畅入场动画
/// 逻辑由 DiscoverLogic_Doze 处理，UI/逻辑完全解耦
class Discover_Doze: UIViewController {

    // MARK: - 逻辑层

    private let logic_Doze = DiscoverLogic_Doze.shared_Doze

    // MARK: - 状态

    private var displayPosts_Doze: [TitleModel_Doze] = []
    private var isSearching_Doze = false

    /// 每列卡片宽度：(屏幕宽 - 左右inset×2 - 列间距) / 2
    private var cardWidth_Doze: CGFloat {
        (UIScreen.main.bounds.width - 32 - 12) / 2
    }

    // MARK: - Header（深色渐变英雄区）

    private let headerBgView_Doze: UIView = {
        let v = UIView()
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.cornerRadius = 32
        v.clipsToBounds = true
        return v
    }()

    private let headerGradientLayer_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#2D1B69").cgColor,
            UIColor(hexstring_Doze: "#1A3A6E").cgColor,
            UIColor(hexstring_Doze: "#0E2A5A").cgColor
        ]
        gl.locations = [0, 0.6, 1.0]
        gl.startPoint = CGPoint(x: 0.1, y: 0)
        gl.endPoint = CGPoint(x: 0.9, y: 1)
        return gl
    }()

    /// Header 右上角大装饰圆（低透明度氛围光）
    private let headerDecoDot1_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#B794F6").withAlphaComponent(0.18)
        v.layer.cornerRadius = 70
        v.isUserInteractionEnabled = false
        return v
    }()

    /// Header 左下角小装饰圆
    private let headerDecoDot2_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#90CDF4").withAlphaComponent(0.15)
        v.layer.cornerRadius = 45
        v.isUserInteractionEnabled = false
        return v
    }()

    /// Header 右侧月亮图标装饰
    private let headerMoonIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 44, weight: .ultraLight)
        iv.image = UIImage(systemName: "moon.stars.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.12)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// Header 右侧爪印装饰
    private let headerPawIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .ultraLight)
        iv.image = UIImage(systemName: "pawprint.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.1)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    private let pageTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Discover"
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        lbl.textColor = .white
        return lbl
    }()

    private let pageSubtitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Explore pet sleep stories"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.65)
        return lbl
    }()

    /// 帖子数量角标（Header 右侧）
    private let postCountBadge_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        return v
    }()

    private let postCountLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 搜索栏

    private let searchContainer_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1.0
        return v
    }()

    private let searchIconView_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv.image = UIImage(systemName: "magnifyingglass", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let searchTextField_Doze: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search sleep logs...",
            attributes: [.foregroundColor: ColorConfig_Doze.textPlaceholder_Doze]
        )
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = ColorConfig_Doze.textPrimary_Doze
        tf.returnKeyType = .search
        tf.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    // MARK: - 主滚动区

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .clear
        return sv
    }()

    private let scrollContent_Doze = UIView()

    // MARK: - 分类筛选

    private let categoryScrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        sv.backgroundColor = .clear
        return sv
    }()

    private let categoryStackView_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private var activeCategoryButton_Doze: UIButton?
    private var activeCategoryGradient_Doze: CAGradientLayer?

    // MARK: - 版块标题行

    private let sectionHeaderView_Doze = UIView()

    private let sectionTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "For You"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    private let sectionCountLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        return lbl
    }()

    // MARK: - 瀑布流（双列 StackView）

    private let masonryContainer_Doze = UIView()

    private let leftColumnStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.alignment = .fill
        return sv
    }()

    private let rightColumnStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.alignment = .fill
        return sv
    }()

    // MARK: - 图片高度序列（非规则错落感）

    private let imageHeightCycle_Doze: [CGFloat] = [
        155, 108, 145, 175, 100, 132, 120, 165, 110, 150
    ]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Doze.backgroundPrimary_Doze
        setupHeader_Doze()
        setupScrollView_Doze()
        setupCategoryFilter_Doze()
        setupSectionHeader_Doze()
        setupMasonryContainer_Doze()
        loadData_Doze()
        observeNotifications_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Doze.frame = headerBgView_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Header 搭建

    private func setupHeader_Doze() {
        view.addSubview(headerBgView_Doze)
        headerBgView_Doze.layer.addSublayer(headerGradientLayer_Doze)
        headerBgView_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(195)
        }

        // 右上角大氛围光圆
        headerBgView_Doze.addSubview(headerDecoDot1_Doze)
        headerDecoDot1_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-30)
            make.width.height.equalTo(140)
        }

        // 左下角小氛围光圆
        headerBgView_Doze.addSubview(headerDecoDot2_Doze)
        headerDecoDot2_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(20)
            make.width.height.equalTo(90)
        }

        // 右侧月亮装饰
        headerBgView_Doze.addSubview(headerMoonIcon_Doze)
        headerMoonIcon_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview().offset(10)
            make.width.height.equalTo(80)
        }

        // 月亮旁爪印装饰
        headerBgView_Doze.addSubview(headerPawIcon_Doze)
        headerPawIcon_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(70)
            make.width.height.equalTo(24)
        }

        // 主标题
        headerBgView_Doze.addSubview(pageTitleLabel_Doze)
        pageTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(66)
        }

        // 副标题
        headerBgView_Doze.addSubview(pageSubtitleLabel_Doze)
        pageSubtitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(pageTitleLabel_Doze.snp.bottom).offset(5)
        }

        // 帖子数量角标
        headerBgView_Doze.addSubview(postCountBadge_Doze)
        postCountBadge_Doze.addSubview(postCountLabel_Doze)
        postCountBadge_Doze.snp.makeConstraints { make in
            make.left.equalTo(pageSubtitleLabel_Doze.snp.right).offset(10)
            make.centerY.equalTo(pageSubtitleLabel_Doze)
            make.height.equalTo(22)
        }
        postCountLabel_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
        }

        // 搜索栏浮在 Header 底部
        view.addSubview(searchContainer_Doze)
        searchContainer_Doze.snp.makeConstraints { make in
            make.top.equalTo(headerBgView_Doze.snp.bottom).offset(-22)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(46)
        }

        searchContainer_Doze.addSubview(searchIconView_Doze)
        searchIconView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        searchContainer_Doze.addSubview(searchTextField_Doze)
        searchTextField_Doze.snp.makeConstraints { make in
            make.left.equalTo(searchIconView_Doze.snp.right).offset(8)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }

        searchTextField_Doze.delegate = self
        searchTextField_Doze.addTarget(self, action: #selector(searchTextChanged_Doze), for: .editingChanged)
    }

    // MARK: - ScrollView 搭建

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(searchContainer_Doze.snp.bottom).offset(14)
            make.left.right.bottom.equalToSuperview()
        }

        scrollView_Doze.addSubview(scrollContent_Doze)
        scrollContent_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        scrollView_Doze.delegate = self
    }

    // MARK: - 分类筛选搭建

    private func setupCategoryFilter_Doze() {
        scrollContent_Doze.addSubview(categoryScrollView_Doze)
        categoryScrollView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }

        categoryScrollView_Doze.addSubview(categoryStackView_Doze)
        categoryStackView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        for (i, category) in PetCategory_Doze.allCases.enumerated() {
            let btn = makeCategoryButton_Doze(category_doze: category)
            btn.tag = i
            btn.addTarget(self, action: #selector(categoryButtonTapped_Doze(_:)), for: .touchUpInside)
            categoryStackView_Doze.addArrangedSubview(btn)
            if category == .all_doze { setActiveCategoryButton_Doze(btn) }
        }
    }

    /// 构建分类胶囊按钮（图标 + 文字，带投影）
    private func makeCategoryButton_Doze(category_doze: PetCategory_Doze) -> UIButton {
        let btn = UIButton(type: .custom)
        let icon = UIImage(systemName: category_doze.iconName_Doze)?
            .withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.setTitle("  \(category_doze.rawValue)", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.setTitleColor(ColorConfig_Doze.textSecondary_Doze, for: .normal)
        btn.tintColor = ColorConfig_Doze.textSecondary_Doze
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 15
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 6
        btn.layer.shadowOpacity = 1.0
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 14)
        btn.snp.makeConstraints { make in make.height.equalTo(32) }
        return btn
    }

    /// 切换激活分类按钮样式（渐变填充）
    private func setActiveCategoryButton_Doze(_ button_doze: UIButton) {
        // 重置旧选中按钮
        activeCategoryGradient_Doze?.removeFromSuperlayer()
        activeCategoryGradient_Doze = nil
        activeCategoryButton_Doze?.backgroundColor = .white
        activeCategoryButton_Doze?.setTitleColor(ColorConfig_Doze.textSecondary_Doze, for: .normal)
        activeCategoryButton_Doze?.tintColor = ColorConfig_Doze.textSecondary_Doze
        activeCategoryButton_Doze?.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor

        // 激活新按钮（渐变背景）
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        gl.cornerRadius = 15
        button_doze.layer.insertSublayer(gl, at: 0)
        activeCategoryGradient_Doze = gl
        button_doze.setTitleColor(.white, for: .normal)
        button_doze.tintColor = .white
        button_doze.layer.shadowColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.35).cgColor
        button_doze.layer.shadowRadius = 8
        button_doze.animatePulse_Doze()
        activeCategoryButton_Doze = button_doze

        DispatchQueue.main.async {
            gl.frame = button_doze.bounds
        }
    }

    // MARK: - 版块标题行搭建

    private func setupSectionHeader_Doze() {
        scrollContent_Doze.addSubview(sectionHeaderView_Doze)
        sectionHeaderView_Doze.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(26)
        }

        // 左侧渐变色竖条
        let accentBar = UIView()
        accentBar.layer.cornerRadius = 2
        let barGl = CAGradientLayer()
        barGl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        barGl.startPoint = CGPoint(x: 0, y: 0)
        barGl.endPoint = CGPoint(x: 0, y: 1)
        barGl.cornerRadius = 2
        accentBar.layer.insertSublayer(barGl, at: 0)
        sectionHeaderView_Doze.addSubview(accentBar)
        accentBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        DispatchQueue.main.async { barGl.frame = accentBar.bounds }

        sectionHeaderView_Doze.addSubview(sectionTitleLabel_Doze)
        sectionTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(accentBar.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        sectionHeaderView_Doze.addSubview(sectionCountLabel_Doze)
        sectionCountLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(sectionTitleLabel_Doze.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 瀑布流容器搭建

    private func setupMasonryContainer_Doze() {
        scrollContent_Doze.addSubview(masonryContainer_Doze)
        masonryContainer_Doze.snp.makeConstraints { make in
            make.top.equalTo(sectionHeaderView_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-120)
        }

        masonryContainer_Doze.addSubview(leftColumnStack_Doze)
        masonryContainer_Doze.addSubview(rightColumnStack_Doze)

        // 两列均不设 bottom 约束，由各自内容决定高度，避免较短列被强制拉伸
        leftColumnStack_Doze.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        rightColumnStack_Doze.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.left.equalTo(leftColumnStack_Doze.snp.right).offset(12)
            make.width.equalTo(leftColumnStack_Doze)
        }

        // 不可见底部锚点：保证容器高度 = 较高一列的高度
        let bottomAnchor_Doze = UIView()
        bottomAnchor_Doze.isHidden = true
        masonryContainer_Doze.addSubview(bottomAnchor_Doze)
        bottomAnchor_Doze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.top.greaterThanOrEqualTo(leftColumnStack_Doze.snp.bottom)
            make.top.greaterThanOrEqualTo(rightColumnStack_Doze.snp.bottom)
        }
    }

    // MARK: - 数据加载

    private func loadData_Doze() {
        displayPosts_Doze = logic_Doze.getAllFilteredPosts_Doze()
        updateSectionCount_Doze()
        rebuildMasonryLayout_Doze()
        animateEntrance_Doze()
    }

    /// 更新版块计数标签和帖子数量角标
    private func updateSectionCount_Doze() {
        let count = displayPosts_Doze.count
        sectionCountLabel_Doze.text = "\(count) stories"
        postCountLabel_Doze.text = "\(count) posts"
        // 更新角标宽度适应文字
        postCountBadge_Doze.setNeedsLayout()
    }

    /// 重建双列瀑布流：偶数索引→左列，奇数索引→右列
    private func rebuildMasonryLayout_Doze() {
        leftColumnStack_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightColumnStack_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (i, post) in displayPosts_Doze.enumerated() {
            let imgH = imageHeightCycle_Doze[i % imageHeightCycle_Doze.count]
            let card = makePostCard_Doze(post_doze: post, imageHeight_doze: imgH)
            if i % 2 == 0 {
                leftColumnStack_Doze.addArrangedSubview(card)
            } else {
                rightColumnStack_Doze.addArrangedSubview(card)
            }
        }

        // 无结果时显示空状态
        if displayPosts_Doze.isEmpty {
            showEmptyState_Doze()
        }
    }

    // MARK: - 空状态视图

    private func showEmptyState_Doze() {
        let emptyView = UIView()
        leftColumnStack_Doze.addArrangedSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width - 32)
        }

        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        iv.image = UIImage(systemName: "moon.zzz", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.textPlaceholder_Doze
        iv.contentMode = .scaleAspectFit
        emptyView.addSubview(iv)

        let lbl = UILabel()
        lbl.text = "No sleep stories found"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.textAlignment = .center
        emptyView.addSubview(lbl)

        iv.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        lbl.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - 卡片构建

    /// 构建帖子卡片
    /// - Parameters:
    ///   - post_doze: 帖子数据
    ///   - imageHeight_doze: 封面图高度（循环序列赋值形成非规则错落感）
    /// - Returns: 已布局完成的 UIView 卡片
    private func makePostCard_Doze(post_doze: TitleModel_Doze, imageHeight_doze: CGFloat) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        card.layer.shadowOpacity = 1.0
        card.snp.makeConstraints { make in
            make.width.equalTo(cardWidth_Doze)
        }
        card.alpha = 0

        let (accentColor, accentColor2) = categoryAccentColors_Doze(post_doze.petCategory_Doze)

        // ── 封面图容器（裁剪，仅上圆角）──
        let coverContainer = UIView()
        coverContainer.clipsToBounds = true
        coverContainer.layer.cornerRadius = 18
        coverContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.addSubview(coverContainer)
        coverContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageHeight_doze)
        }

        // 封面图或渐变占位
        let coverPaths = post_doze.titleMeidas_Doze
        if let firstPath = coverPaths.first {
            let mdv = MediaDisplayView_Doze()
            mdv.configure_Doze(mediaPath_Doze: firstPath, isVideo_Doze: false)
            coverContainer.addSubview(mdv)
            mdv.snp.makeConstraints { make in make.edges.equalToSuperview() }
        } else {
            let gradBg = CAGradientLayer()
            gradBg.colors = [accentColor.withAlphaComponent(0.28).cgColor,
                             accentColor2.withAlphaComponent(0.14).cgColor]
            gradBg.startPoint = CGPoint(x: 0, y: 0)
            gradBg.endPoint = CGPoint(x: 1, y: 1)
            gradBg.frame = CGRect(x: 0, y: 0, width: cardWidth_Doze, height: imageHeight_doze)
            coverContainer.layer.addSublayer(gradBg)

            let iconPH = UIImageView()
            iconPH.image = UIImage(systemName: categoryIcon_Doze(post_doze.petCategory_Doze))
            iconPH.tintColor = accentColor.withAlphaComponent(0.45)
            iconPH.contentMode = .scaleAspectFit
            coverContainer.addSubview(iconPH)
            iconPH.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(36)
            }
        }

        // 封面图底部渐变遮罩（提升角标可读性）
        let fadeMask = CAGradientLayer()
        fadeMask.colors = [UIColor.clear.cgColor,
                           UIColor.black.withAlphaComponent(0.30).cgColor]
        fadeMask.startPoint = CGPoint(x: 0.5, y: 0.4)
        fadeMask.endPoint = CGPoint(x: 0.5, y: 1)
        fadeMask.frame = CGRect(x: 0, y: 0, width: cardWidth_Doze, height: imageHeight_doze)
        coverContainer.layer.addSublayer(fadeMask)

        // 类别角标（封面图左下角）
        let categoryBadge = UILabel()
        categoryBadge.text = " \(post_doze.petCategory_Doze.rawValue) "
        categoryBadge.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        categoryBadge.textColor = .white
        categoryBadge.backgroundColor = accentColor.withAlphaComponent(0.9)
        categoryBadge.layer.cornerRadius = 8
        categoryBadge.clipsToBounds = true
        coverContainer.addSubview(categoryBadge)
        categoryBadge.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(17)
        }

        // ── 右上角操作按钮：本人帖子显示删除，他人帖子显示举报 ──
        let isOwner_doze = UserViewModel_Doze.shared_Doze.isCurrentUser_Doze(
            userId_doze: post_doze.titleUserId_Doze
        )
        let reportBtn = UIButton(type: .custom)
        let actionIcon_doze = isOwner_doze ? "trash" : "ellipsis"
        reportBtn.setImage(UIImage(systemName: actionIcon_doze), for: .normal)
        reportBtn.tintColor = UIColor.white.withAlphaComponent(0.9)
        reportBtn.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        reportBtn.layer.cornerRadius = 13
        reportBtn.tag = post_doze.titleId_Doze
        reportBtn.addTarget(self, action: #selector(handleReportTap_Doze(_:)), for: .touchUpInside)
        card.addSubview(reportBtn)
        reportBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(26)
        }

        // ── 卡片内容区底部颜色口音条（类别彩色装饰）──
        let accentStripe = UIView()
        accentStripe.backgroundColor = accentColor.withAlphaComponent(0.12)
        accentStripe.layer.cornerRadius = 18
        accentStripe.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        card.addSubview(accentStripe)
        accentStripe.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(46)
        }

        // ── 标题（封面图下方）──
        let titleLbl = UILabel()
        titleLbl.text = post_doze.title_Doze
        titleLbl.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLbl.textColor = ColorConfig_Doze.textPrimary_Doze
        titleLbl.numberOfLines = 2
        titleLbl.lineBreakMode = .byTruncatingTail
        card.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(coverContainer.snp.bottom).offset(9)
            make.left.right.equalToSuperview().inset(10)
        }

        // ── 底部用户信息行（位于口音条内）──
        let bottomRow = UIView()
        card.addSubview(bottomRow)
        bottomRow.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-12)
        }

        // UserAvatarView_Doze 头像
        let avatarView = UserAvatarView_Doze()
        avatarView.configure_Doze(userId_Doze: post_doze.titleUserId_Doze)
        bottomRow.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 头像点击按钮
        let avatarBtn = UIButton(type: .custom)
        avatarBtn.tag = post_doze.titleUserId_Doze
        avatarBtn.addTarget(self, action: #selector(handleAvatarTap_Doze(_:)), for: .touchUpInside)
        bottomRow.addSubview(avatarBtn)
        avatarBtn.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        // 用户名
        let usernameLbl = UILabel()
        usernameLbl.text = post_doze.titleUserName_Doze
        usernameLbl.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        usernameLbl.textColor = ColorConfig_Doze.textSecondary_Doze
        usernameLbl.numberOfLines = 1
        usernameLbl.lineBreakMode = .byTruncatingTail
        bottomRow.addSubview(usernameLbl)
        usernameLbl.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(bottomRow.snp.centerX).offset(10)
        }

        // 点赞数（先锚定右侧，保证完整显示）
        let likesLbl = UILabel()
        likesLbl.text = "\(post_doze.likes_Doze)"
        likesLbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        likesLbl.textColor = accentColor
        likesLbl.setContentHuggingPriority(.required, for: .horizontal)
        likesLbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        bottomRow.addSubview(likesLbl)
        likesLbl.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
        }

        // 点赞图标（位于数字左侧，尺寸放大）
        let heartIv = UIImageView()
        let heartCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        heartIv.image = UIImage(systemName: "heart.fill", withConfiguration: heartCfg)
        heartIv.tintColor = accentColor
        heartIv.contentMode = .scaleAspectFit
        bottomRow.addSubview(heartIv)
        heartIv.snp.makeConstraints { make in
            make.right.equalTo(likesLbl.snp.left).offset(-3)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        // 透明点赞按钮：覆盖图标与数字区域，tag 为帖子 ID
        let likeBtn = UIButton(type: .custom)
        likeBtn.tag = post_doze.titleId_Doze
        likeBtn.addTarget(self, action: #selector(handleLikeTap_Doze(_:)), for: .touchUpInside)
        bottomRow.addSubview(likeBtn)
        likeBtn.snp.makeConstraints { make in
            make.left.equalTo(heartIv)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        // 卡片点击（跳转帖子详情）
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Doze(_:)))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        card.tag = post_doze.titleId_Doze

        return card
    }

    // MARK: - 类别辅助方法

    /// 返回类别对应渐变色对
    private func categoryAccentColors_Doze(_ category: PetCategory_Doze) -> (UIColor, UIColor) {
        switch category {
        case .cat_doze:    return (UIColor(hexstring_Doze: "#B794F6"), UIColor(hexstring_Doze: "#90CDF4"))
        case .dog_doze:    return (UIColor(hexstring_Doze: "#4299E1"), UIColor(hexstring_Doze: "#68D391"))
        case .rabbit_doze: return (UIColor(hexstring_Doze: "#ED64A6"), UIColor(hexstring_Doze: "#F6AD55"))
        case .bird_doze:   return (UIColor(hexstring_Doze: "#48BB78"), UIColor(hexstring_Doze: "#4299E1"))
        case .all_doze:    return (UIColor(hexstring_Doze: "#F6AD55"), UIColor(hexstring_Doze: "#FBB6CE"))
        }
    }

    /// 返回类别对应占位 SF Symbol
    private func categoryIcon_Doze(_ category: PetCategory_Doze) -> String {
        switch category {
        case .cat_doze:    return "cat.fill"
        case .dog_doze:    return "dog.fill"
        case .rabbit_doze: return "hare.fill"
        case .bird_doze:   return "bird.fill"
        case .all_doze:    return "pawprint.fill"
        }
    }

    // MARK: - 入场动画

    private func animateEntrance_Doze() {
        // 固定元素依次浮入
        let baseViews: [UIView] = [headerBgView_Doze, searchContainer_Doze, categoryScrollView_Doze, sectionHeaderView_Doze]
        for (i, v) in baseViews.enumerated() {
            v.alpha = 0
            v.transform = CGAffineTransform(translationX: 0, y: 18)
            UIView.animate(withDuration: 0.44, delay: Double(i) * 0.07,
                           usingSpringWithDamping: 0.82, initialSpringVelocity: 0.4,
                           options: [.curveEaseOut]) {
                v.alpha = 1; v.transform = .identity
            }
        }

        // 左列卡片从左侧浮入，右列从右侧浮入
        for (i, card) in leftColumnStack_Doze.arrangedSubviews.enumerated() {
            card.transform = CGAffineTransform(translationX: -16, y: 10)
            UIView.animate(withDuration: 0.42, delay: 0.18 + Double(i) * 0.05,
                           usingSpringWithDamping: 0.86, initialSpringVelocity: 0.3,
                           options: [.curveEaseOut]) {
                card.alpha = 1; card.transform = .identity
            }
        }
        for (i, card) in rightColumnStack_Doze.arrangedSubviews.enumerated() {
            card.transform = CGAffineTransform(translationX: 16, y: 10)
            UIView.animate(withDuration: 0.42, delay: 0.22 + Double(i) * 0.05,
                           usingSpringWithDamping: 0.86, initialSpringVelocity: 0.3,
                           options: [.curveEaseOut]) {
                card.alpha = 1; card.transform = .identity
            }
        }
    }

    // MARK: - 事件处理

    /// 搜索文字变化
    @objc private func searchTextChanged_Doze() {
        let keyword = searchTextField_Doze.text ?? ""
        isSearching_Doze = !keyword.trimmingCharacters(in: .whitespaces).isEmpty
        displayPosts_Doze = isSearching_Doze
            ? logic_Doze.searchPosts_Doze(keyword_doze: keyword)
            : logic_Doze.getAllFilteredPosts_Doze()
        updateSectionCount_Doze()
        rebuildMasonryLayout_Doze()
        showAllCardsImmediately_Doze()
    }

    /// 分类切换
    @objc private func categoryButtonTapped_Doze(_ sender: UIButton) {
        let categories = PetCategory_Doze.allCases
        guard sender.tag < categories.count else { return }
        setActiveCategoryButton_Doze(sender)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        displayPosts_Doze = logic_Doze.filterByCategory_Doze(category_doze: categories[sender.tag])
        updateSectionCount_Doze()
        masonryContainer_Doze.transform = CGAffineTransform(translationX: 20, y: 0)
        masonryContainer_Doze.alpha = 0
        rebuildMasonryLayout_Doze()
        UIView.animate(withDuration: 0.32, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            self.masonryContainer_Doze.transform = .identity
            self.masonryContainer_Doze.alpha = 1
        }
        showAllCardsImmediately_Doze()
    }

    /// 点赞图标点击 → 调用 TitleViewModel 点赞/取消点赞
    /// - Parameter sender: tag 为帖子 ID 的透明按钮
    @objc private func handleLikeTap_Doze(_ sender: UIButton) {
        guard let post = displayPosts_Doze.first(where: { $0.titleId_Doze == sender.tag }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        TitleViewModel_Doze.shared_Doze.likePost_Doze(post_doze: post)
    }

    /// 卡片点击 → 帖子详情
    @objc private func handleCardTap_Doze(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view,
              let post = displayPosts_Doze.first(where: { $0.titleId_Doze == card.tag }) else { return }
        card.animatePressDown_Doze { card.animatePressUp_Doze() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.toTitleDetail_Doze(titleModel_doze: post)
    }

    /// 头像点击 → 用户中心
    @objc private func handleAvatarTap_Doze(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let userId = sender.tag
        if UserViewModel_Doze.shared_Doze.isCurrentUser_Doze(userId_doze: userId) {
            Navigation_Doze.toMe_Doze()
        } else {
            let user = UserViewModel_Doze.shared_Doze.getUserById_Doze(userId_doze: userId)
            Navigation_Doze.toUserInfo_Doze(with: user)
        }
    }

    /// 举报按钮点击
    /// 右上角操作按钮点击：本人帖子 → 删除，他人帖子 → 举报
    @objc private func handleReportTap_Doze(_ sender: UIButton) {
        guard let post = displayPosts_Doze.first(where: { $0.titleId_Doze == sender.tag }) else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let isOwner = UserViewModel_Doze.shared_Doze.isCurrentUser_Doze(userId_doze: post.titleUserId_Doze)
        if isOwner {
            ReportDeleteHelper_Doze.delete_Doze(post_Doze: post, from: self)
        } else {
            ReportDeleteHelper_Doze.report_Doze(post_Doze: post, from: self)
        }
    }

    /// 立即显示所有卡片（搜索/切换分类时跳过入场动画）
    private func showAllCardsImmediately_Doze() {
        let allCards = leftColumnStack_Doze.arrangedSubviews + rightColumnStack_Doze.arrangedSubviews
        allCards.forEach { $0.alpha = 1; $0.transform = .identity }
    }

    // MARK: - 通知监听

    private func observeNotifications_Doze() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleStateChange_Doze),
            name: TitleViewModel_Doze.titleStateDidChangeNotification_Doze, object: nil
        )
    }

    @objc private func handleTitleStateChange_Doze() {
        guard !isSearching_Doze else { return }
        displayPosts_Doze = logic_Doze.getAllFilteredPosts_Doze()
        updateSectionCount_Doze()
        rebuildMasonryLayout_Doze()
        showAllCardsImmediately_Doze()
    }
}

// MARK: - UITextField 代理

extension Discover_Doze: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearching_Doze = false
        displayPosts_Doze = logic_Doze.getAllFilteredPosts_Doze()
        updateSectionCount_Doze()
        rebuildMasonryLayout_Doze()
        showAllCardsImmediately_Doze()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.searchContainer_Doze.layer.shadowColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.25).cgColor
            self.searchContainer_Doze.layer.shadowRadius = 16
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.searchContainer_Doze.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
            self.searchContainer_Doze.layer.shadowRadius = 12
        }
    }
}

// MARK: - UIScrollView 代理（Header 弹性回弹 + 视差）

extension Discover_Doze: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView_Doze else { return }
        let offset = scrollView.contentOffset.y
        if offset < 0 {
            // 下拉时 Header 轻微放大
            let scale = 1 + (-offset / 600)
            headerBgView_Doze.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            headerBgView_Doze.transform = .identity
        }
    }
}
