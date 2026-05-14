import Foundation
import UIKit
import SnapKit

// MARK: 发现页
// 设计思路：
//   顶部采用深紫-靛蓝渐变 Header（含真实搜索框），下方为横向可滚动的分类标签筛选器，
//   核心内容区为非规则双列瀑布流。支持实时搜索（按标题/内容/作者名过滤）与分类筛选
//   双重过滤联动；切换分类或输入搜索词时均重置高度缓存并刷新列表。
// 关键属性：
//   categories_Echd         — 分类标签数组（第 0 项为 "All"，不过滤）
//   currentSearchText_Echd  — 当前搜索关键词，空字符串时不过滤
//   selectedCategoryIndex   — 当前选中分类下标，0 = All
//   cardAccentColors_Echd   — 卡片 accentColor 循环数组

/// 发现页视图控制器
class Discover_Echd: UIViewController {

    // MARK: - 分类标签数据

    /// 分类标签列表（index 0 = All，其余为具体分类）
    private let categories_Echd = ["All", "Trending", "New", "Art", "Life", "Tech", "Food"]

    /// 当前选中的分类下标（0 = 全部）
    private var selectedCategoryIndex_Echd: Int = 0

    /// 当前搜索关键词（空字符串表示不搜索）
    private var currentSearchText_Echd: String = ""

    // MARK: - UI组件

    /// 顶部渐变 Header 容器（延伸至状态栏背后）
    private let headerContainer_Echd = UIView()

    /// Header 渐变图层（深紫 → 靛蓝）
    private var headerGradient_Echd: CAGradientLayer?

    /// 页面大标题
    private let titleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Discover"
        label_Echd.font = UIFont.systemFont(ofSize: 34, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    /// 副标题
    private let subTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Find your spark ✦"
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.75)
        return label_Echd
    }()

    /// 搜索栏容器（毛玻璃风格）
    private let searchContainer_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view_Echd.layer.cornerRadius = 14
        return view_Echd
    }()

    /// 搜索图标
    private let searchIcon_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let config_Echd = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv_Echd.image = UIImage(systemName: "magnifyingglass", withConfiguration: config_Echd)
        iv_Echd.tintColor = UIColor.white.withAlphaComponent(0.8)
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    /// 真实搜索输入框（实时过滤帖子）
    private let searchTextField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.attributedPlaceholder = NSAttributedString(
            string: "Search posts, people...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        tf_Echd.font = UIFont.systemFont(ofSize: 14)
        tf_Echd.textColor = .white
        tf_Echd.tintColor = .white
        tf_Echd.autocorrectionType = .no
        tf_Echd.autocapitalizationType = .none
        tf_Echd.returnKeyType = .search
        // 去掉系统自带的边框
        tf_Echd.borderStyle = .none
        tf_Echd.backgroundColor = .clear
        return tf_Echd
    }()

    /// 清除搜索按钮（出现在有文字时）
    private let clearSearchButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .system)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn_Echd.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.tintColor = UIColor.white.withAlphaComponent(0.7)
        btn_Echd.isHidden = true
        return btn_Echd
    }()

    /// 分类标签横向滚动视图
    private let categoryScrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsHorizontalScrollIndicator = false
        sv_Echd.alwaysBounceHorizontal = true
        sv_Echd.backgroundColor = .clear
        return sv_Echd
    }()

    /// 分类标签 StackView
    private let categoryStack_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .horizontal
        sv_Echd.spacing = 10
        sv_Echd.alignment = .center
        return sv_Echd
    }()

    /// 主内容滚动视图
    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        return sv_Echd
    }()

    /// 瀑布流左列容器
    private let leftColumnStackView_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 14
        sv_Echd.alignment = .fill
        return sv_Echd
    }()

    /// 瀑布流右列容器
    private let rightColumnStackView_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 14
        sv_Echd.alignment = .fill
        return sv_Echd
    }()

    /// 双列容器
    private let columnsContainerView_Echd = UIView()

    /// 滚动视图内容容器
    private let contentView_Echd = UIView()

    /// 空状态容器（浮于滚动区正中，有内容时隐藏）
    private let emptyStateContainerView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.isHidden = true
        return view_Echd
    }()

    // MARK: - 私有属性

    /// 左列当前累计高度（决定新卡片放哪列）
    private var leftColumnHeight_Echd: CGFloat = 0

    /// 右列当前累计高度
    private var rightColumnHeight_Echd: CGFloat = 0

    /// 预生成的卡片随机高度（key: postId，保证同帖子高度稳定）
    private var cardHeightMap_Echd: [Int: CGFloat] = [:]

    /// 卡片 accent 颜色循环数组（影响阴影色与角标色）
    private let cardAccentColors_Echd: [UIColor] = [
        UIColor(hexstring_Echd: "#8B5CF6"),  // 深紫
        UIColor(hexstring_Echd: "#EC4899"),  // 玫瑰粉
        UIColor(hexstring_Echd: "#10B981"),  // 祖母绿
        UIColor(hexstring_Echd: "#F59E0B"),  // 琥珀
        UIColor(hexstring_Echd: "#6366F1"),  // 靛蓝
        UIColor(hexstring_Echd: "#F43F5E")   // 玫瑰红
    ]

    /// 分类按钮引用（切换选中样式用）
    private var categoryButtons_Echd: [UIButton] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshPosts_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        buildCategoryTags_Echd()
        observeNotifications_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerContainer_Echd.bounds
        applyHeaderArcMask_Echd()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI设置

    /// 添加子视图、配置渐变和搜索输入框
    private func setupUI_Echd() {
        // --- Header 区域 ---
        headerContainer_Echd.clipsToBounds = true
        view.addSubview(headerContainer_Echd)

        // 深紫 → 靛蓝渐变
        let gradient_Echd = CAGradientLayer()
        gradient_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        gradient_Echd.startPoint = CGPoint(x: 0, y: 0)
        gradient_Echd.endPoint = CGPoint(x: 1, y: 1)
        headerContainer_Echd.layer.insertSublayer(gradient_Echd, at: 0)
        headerGradient_Echd = gradient_Echd

        headerContainer_Echd.addSubview(titleLabel_Echd)
        headerContainer_Echd.addSubview(subTitleLabel_Echd)
        headerContainer_Echd.addSubview(searchContainer_Echd)
        searchContainer_Echd.addSubview(searchIcon_Echd)
        searchContainer_Echd.addSubview(searchTextField_Echd)
        searchContainer_Echd.addSubview(clearSearchButton_Echd)

        // 搜索框事件
        searchTextField_Echd.delegate = self
        searchTextField_Echd.addTarget(self, action: #selector(searchTextChanged_Echd), for: .editingChanged)
        clearSearchButton_Echd.addTarget(self, action: #selector(clearSearch_Echd), for: .touchUpInside)

        // 点击页面空白区域收起键盘
        let bgTap_Echd = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Echd))
        bgTap_Echd.cancelsTouchesInView = false
        view.addGestureRecognizer(bgTap_Echd)

        // --- 分类标签区 ---
        view.addSubview(categoryScrollView_Echd)
        categoryScrollView_Echd.addSubview(categoryStack_Echd)

        // --- 瀑布流区 ---
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)
        contentView_Echd.addSubview(columnsContainerView_Echd)
        columnsContainerView_Echd.addSubview(leftColumnStackView_Echd)
        columnsContainerView_Echd.addSubview(rightColumnStackView_Echd)

        // 空态容器浮于滚动区正中（不在滚动视图内，避免只在左上角显示）
        view.addSubview(emptyStateContainerView_Echd)
    }

    /// Header 底部圆弧遮罩
    private func applyHeaderArcMask_Echd() {
        let w_Echd = headerContainer_Echd.bounds.width
        let h_Echd = headerContainer_Echd.bounds.height
        let arcDepth_Echd: CGFloat = 22

        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - arcDepth_Echd))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - arcDepth_Echd),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + arcDepth_Echd)
        )
        path_Echd.close()

        let maskLayer_Echd = CAShapeLayer()
        maskLayer_Echd.path = path_Echd.cgPath
        headerContainer_Echd.layer.mask = maskLayer_Echd
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let screenWidth_Echd = UIScreen.main.bounds.width
        let columnWidth_Echd = (screenWidth_Echd - 16 * 2 - 10) / 2

        headerContainer_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }

        // 标题不再与 filterButton 对齐，直接铺开至右边
        titleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
        }

        subTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Echd.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(22)
        }

        searchContainer_Echd.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel_Echd.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }

        searchIcon_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        clearSearchButton_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        searchTextField_Echd.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Echd.snp.trailing).offset(8)
            make.trailing.equalTo(clearSearchButton_Echd.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
        }

        // 分类标签区
        categoryScrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerContainer_Echd.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        categoryStack_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 主内容区
        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView_Echd.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenWidth_Echd)
        }

        columnsContainerView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }

        leftColumnStackView_Echd.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(columnWidth_Echd)
        }

        rightColumnStackView_Echd.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalTo(columnWidth_Echd)
        }

        // 空态容器：紧贴分类标签下方直到底部，内容在视图正中展示
        emptyStateContainerView_Echd.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView_Echd.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 分类标签构建

    private func buildCategoryTags_Echd() {
        categoryButtons_Echd.removeAll()
        categoryStack_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index_Echd, category_Echd) in categories_Echd.enumerated() {
            let btn_Echd = UIButton(type: .custom)
            btn_Echd.setTitle(category_Echd, for: .normal)
            btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            btn_Echd.layer.cornerRadius = 16
            btn_Echd.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            btn_Echd.tag = index_Echd
            btn_Echd.addTarget(self, action: #selector(categoryTapped_Echd(_:)), for: .touchUpInside)
            applyCategoryStyle_Echd(btn: btn_Echd, selected: index_Echd == selectedCategoryIndex_Echd)
            categoryStack_Echd.addArrangedSubview(btn_Echd)
            categoryButtons_Echd.append(btn_Echd)
        }
    }

    /// 应用分类按钮选中/未选中样式
    private func applyCategoryStyle_Echd(btn: UIButton, selected: Bool) {
        if selected {
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
            btn.layer.borderWidth = 0
        } else {
            btn.setTitleColor(UIColor(hexstring_Echd: "#6B7280"), for: .normal)
            btn.backgroundColor = .white
            btn.layer.borderWidth = 1.2
            btn.layer.borderColor = UIColor(hexstring_Echd: "#E5E7EB").cgColor
        }
    }

    // MARK: - 数据过滤

    /// 根据当前分类和搜索词过滤帖子列表
    /// - Returns: 过滤后的帖子数组
    private func getFilteredPosts_Echd() -> [TitleModel_Echd] {
        var posts_Echd = TitleViewModel_Echd.shared_Echd.getPosts_Echd()

        // 分类过滤：index 0 = All，不过滤；其余按帖子 titleId 映射到分类
        if selectedCategoryIndex_Echd > 0 {
            posts_Echd = posts_Echd.filter { post_Echd in
                let mappedIndex_Echd = (post_Echd.titleId_Echd % (categories_Echd.count - 1)) + 1
                return mappedIndex_Echd == selectedCategoryIndex_Echd
            }
        }

        // 关键词搜索过滤：匹配标题、内容、作者名（不区分大小写）
        let query_Echd = currentSearchText_Echd.trimmingCharacters(in: .whitespaces).lowercased()
        if !query_Echd.isEmpty {
            posts_Echd = posts_Echd.filter { post_Echd in
                post_Echd.title_Echd.lowercased().contains(query_Echd) ||
                post_Echd.titleContent_Echd.lowercased().contains(query_Echd) ||
                post_Echd.titleUserName_Echd.lowercased().contains(query_Echd)
            }
        }

        return posts_Echd
    }

    // MARK: - 数据刷新

    /// 刷新瀑布流（使用当前分类+搜索过滤后的帖子）
    private func refreshPosts_Echd() {
        leftColumnStackView_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightColumnStackView_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }
        leftColumnHeight_Echd = 0
        rightColumnHeight_Echd = 0

        let posts_Echd = getFilteredPosts_Echd()

        for (index_Echd, post_Echd) in posts_Echd.enumerated() {
            // 用 postId 为 key 缓存高度，保证同帖子高度稳定，切换分类后新帖子才重新随机
            if cardHeightMap_Echd[post_Echd.titleId_Echd] == nil {
                cardHeightMap_Echd[post_Echd.titleId_Echd] = CGFloat.random(in: 165...255)
            }
            let mediaH_Echd = cardHeightMap_Echd[post_Echd.titleId_Echd] ?? 210
            let accent_Echd = cardAccentColors_Echd[index_Echd % cardAccentColors_Echd.count]
            let card_Echd = buildPostCard_Echd(post: post_Echd, mediaHeight: mediaH_Echd, accentColor: accent_Echd)

            if leftColumnHeight_Echd <= rightColumnHeight_Echd {
                leftColumnStackView_Echd.addArrangedSubview(card_Echd)
                leftColumnHeight_Echd += mediaH_Echd + 104 + 14
            } else {
                rightColumnStackView_Echd.addArrangedSubview(card_Echd)
                rightColumnHeight_Echd += mediaH_Echd + 104 + 14
            }

            // 级联入场动画
            card_Echd.alpha = 0
            card_Echd.transform = CGAffineTransform(translationX: 0, y: 28)
            UIView.animate(
                withDuration: AnimationConfig_Echd.durationNormal_Echd,
                delay: AnimationConfig_Echd.delayShort_Echd * Double(index_Echd),
                usingSpringWithDamping: AnimationConfig_Echd.springDampingNormal_Echd,
                initialSpringVelocity: AnimationConfig_Echd.springVelocity_Echd,
                options: [],
                animations: {
                    card_Echd.alpha = 1
                    card_Echd.transform = .identity
                }
            )
        }

        // 有帖子时隐藏空态视图；无帖子时构建并居中展示
        if posts_Echd.isEmpty {
            emptyStateContainerView_Echd.isHidden = false
            showEmptyState_Echd()
        } else {
            emptyStateContainerView_Echd.isHidden = true
        }
    }

    /// 构建单个帖子卡片
    /// - Parameters:
    ///   - post: 帖子数据模型
    ///   - mediaHeight: 媒体区域高度
    ///   - accentColor: 卡片主调色（阴影色与角标色）
    private func buildPostCard_Echd(post: TitleModel_Echd, mediaHeight: CGFloat, accentColor: UIColor) -> UIView {
        let cardView_Echd = UIView()
        cardView_Echd.backgroundColor = .white
        cardView_Echd.layer.cornerRadius = 20
        cardView_Echd.layer.shadowColor = accentColor.withAlphaComponent(0.3).cgColor
        cardView_Echd.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView_Echd.layer.shadowRadius = 16
        cardView_Echd.layer.shadowOpacity = 1
        cardView_Echd.clipsToBounds = false

        // 内部圆角裁剪容器
        let innerView_Echd = UIView()
        innerView_Echd.backgroundColor = .white
        innerView_Echd.layer.cornerRadius = 20
        innerView_Echd.clipsToBounds = true
        cardView_Echd.addSubview(innerView_Echd)

        // 媒体视图
        let mediaView_Echd = MediaDisplayView_Echd()
        innerView_Echd.addSubview(mediaView_Echd)
        mediaView_Echd.configure_Echd(mediaPath_Echd: post.titleMeidas_Echd.first)

        // 媒体底部渐变蒙版
        let gradientMask_Echd = DiscoverGradientOverlay_Echd()
        innerView_Echd.addSubview(gradientMask_Echd)

        // 分类角标（左上角）
        let tagLabel_Echd = UILabel()
        let tagIndex_Echd = (post.titleId_Echd % (categories_Echd.count - 1)) + 1
        tagLabel_Echd.text = "  \(categories_Echd[tagIndex_Echd])  "
        tagLabel_Echd.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        tagLabel_Echd.textColor = .white
        tagLabel_Echd.backgroundColor = accentColor
        tagLabel_Echd.layer.cornerRadius = 9
        tagLabel_Echd.clipsToBounds = true
        tagLabel_Echd.textAlignment = .center
        innerView_Echd.addSubview(tagLabel_Echd)

        // 举报/删除按钮（右上角，添加至 cardView 避免被裁切）
        let reportBtn_Echd = ReportDeleteHelper_Echd.createPostReportButton_Echd(
            post_Echd: post,
            size_Echd: 11,
            color_Echd: .white,
            from: self,
            completion_Echd: { [weak self] in self?.refreshPosts_Echd() }
        )
        reportBtn_Echd.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        reportBtn_Echd.layer.cornerRadius = 13
        cardView_Echd.addSubview(reportBtn_Echd)

        // 点赞按钮（视觉装饰，不拦截点击）
        let likeBtn_Echd = UIButton(type: .custom)
        let heartCfg_Echd = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        likeBtn_Echd.setImage(UIImage(systemName: "heart.fill", withConfiguration: heartCfg_Echd), for: .normal)
        likeBtn_Echd.tintColor = UIColor(hexstring_Echd: "#F43F5E")
        likeBtn_Echd.backgroundColor = .white
        likeBtn_Echd.layer.cornerRadius = 15
        likeBtn_Echd.isUserInteractionEnabled = false
        innerView_Echd.addSubview(likeBtn_Echd)

        // 点赞数量
        let likeCnt_Echd = UILabel()
        likeCnt_Echd.text = "\((post.titleId_Echd * 23 + 57) % 999)"
        likeCnt_Echd.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        likeCnt_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        likeCnt_Echd.textAlignment = .center
        innerView_Echd.addSubview(likeCnt_Echd)

        // 发布者信息区域
        let infoView_Echd = UIView()
        infoView_Echd.backgroundColor = .white
        innerView_Echd.addSubview(infoView_Echd)

        let avatar_Echd = UserAvatarView_Echd()
        avatar_Echd.configure_Echd(userId_Echd: post.titleUserId_Echd)
        infoView_Echd.addSubview(avatar_Echd)

        let nameLabel_Echd = UILabel()
        nameLabel_Echd.text = post.titleUserName_Echd
        nameLabel_Echd.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        nameLabel_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        infoView_Echd.addSubview(nameLabel_Echd)

        // 在线状态绿点
        let onlineDot_Echd = UIView()
        onlineDot_Echd.backgroundColor = UIColor(hexstring_Echd: "#10B981")
        onlineDot_Echd.layer.cornerRadius = 3.5
        infoView_Echd.addSubview(onlineDot_Echd)

        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = post.title_Echd
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLbl_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        titleLbl_Echd.numberOfLines = 1
        infoView_Echd.addSubview(titleLbl_Echd)

        let contentLbl_Echd = UILabel()
        contentLbl_Echd.text = post.titleContent_Echd
        contentLbl_Echd.font = UIFont.systemFont(ofSize: 11)
        contentLbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        contentLbl_Echd.numberOfLines = 2
        infoView_Echd.addSubview(contentLbl_Echd)

        // MARK: 约束
        innerView_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(mediaHeight)
        }
        gradientMask_Echd.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(mediaView_Echd)
            make.height.equalTo(70)
        }
        tagLabel_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        reportBtn_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        likeBtn_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalTo(mediaView_Echd.snp.bottom).offset(-10)
            make.width.height.equalTo(30)
        }
        likeCnt_Echd.snp.makeConstraints { make in
            make.centerX.equalTo(likeBtn_Echd)
            make.top.equalTo(likeBtn_Echd.snp.bottom).offset(2)
            make.width.equalTo(30)
        }
        infoView_Echd.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Echd.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        avatar_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(22)
        }
        nameLabel_Echd.snp.makeConstraints { make in
            make.leading.equalTo(avatar_Echd.snp.trailing).offset(5)
            make.centerY.equalTo(avatar_Echd)
            make.trailing.lessThanOrEqualTo(onlineDot_Echd.snp.leading).offset(-4)
        }
        onlineDot_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(avatar_Echd)
            make.width.height.equalTo(7)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(avatar_Echd.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        contentLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }

        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(postCardTapped_Echd(_:)))
        cardView_Echd.addGestureRecognizer(tap_Echd)
        cardView_Echd.tag = post.titleId_Echd

        return cardView_Echd
    }

    /// 构建空状态内容并展示在容器正中
    /// 每次调用前清除旧内容，保证搜索词变更后文案同步更新
    private func showEmptyState_Echd() {
        // 清除上次内容
        emptyStateContainerView_Echd.subviews.forEach { $0.removeFromSuperview() }

        // 内容包裹视图（用于整体居中）
        let wrap_Echd = UIView()
        emptyStateContainerView_Echd.addSubview(wrap_Echd)

        let circleBg_Echd = UIView()
        circleBg_Echd.backgroundColor = UIColor(hexstring_Echd: "#8B5CF6").withAlphaComponent(0.08)
        circleBg_Echd.layer.cornerRadius = 52
        wrap_Echd.addSubview(circleBg_Echd)

        let iconIV_Echd = UIImageView()
        let iconName_Echd = currentSearchText_Echd.isEmpty ? "sparkles.slash" : "magnifyingglass"
        iconIV_Echd.image = UIImage(systemName: iconName_Echd)
        iconIV_Echd.tintColor = UIColor(hexstring_Echd: "#8B5CF6").withAlphaComponent(0.5)
        iconIV_Echd.contentMode = .scaleAspectFit
        wrap_Echd.addSubview(iconIV_Echd)

        let emptyLabel_Echd = UILabel()
        emptyLabel_Echd.text = currentSearchText_Echd.isEmpty
            ? "No posts yet.\nBe the first to share a spark!"
            : "No results for \"\(currentSearchText_Echd)\".\nTry different keywords."
        emptyLabel_Echd.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        emptyLabel_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        emptyLabel_Echd.textAlignment = .center
        emptyLabel_Echd.numberOfLines = 0
        wrap_Echd.addSubview(emptyLabel_Echd)

        // wrap 内部约束
        circleBg_Echd.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }
        iconIV_Echd.snp.makeConstraints { make in
            make.center.equalTo(circleBg_Echd)
            make.width.height.equalTo(46)
        }
        emptyLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(circleBg_Echd.snp.bottom).offset(18)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // wrap 在容器中垂直居中（稍微偏上，让视觉感更舒适）
        wrap_Echd.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
    }

    // MARK: - 事件处理

    /// 分类标签点击：切换选中态，重置高度缓存并刷新（真实过滤帖子）
    /// - Parameter sender: 被点击的分类按钮
    @objc private func categoryTapped_Echd(_ sender: UIButton) {
        let index_Echd = sender.tag
        guard index_Echd != selectedCategoryIndex_Echd else { return }

        applyCategoryStyle_Echd(btn: categoryButtons_Echd[selectedCategoryIndex_Echd], selected: false)
        selectedCategoryIndex_Echd = index_Echd
        applyCategoryStyle_Echd(btn: categoryButtons_Echd[selectedCategoryIndex_Echd], selected: true)

        sender.animatePressDown_Echd { sender.animatePressUp_Echd() }
        // 切换分类后立即刷新，getFilteredPosts_Echd() 会按新 selectedCategoryIndex 过滤
        refreshPosts_Echd()
    }

    /// 搜索文本实时变化：更新 currentSearchText 并刷新
    @objc private func searchTextChanged_Echd() {
        currentSearchText_Echd = searchTextField_Echd.text ?? ""
        clearSearchButton_Echd.isHidden = currentSearchText_Echd.isEmpty
        refreshPosts_Echd()
    }

    /// 点击清除按钮
    @objc private func clearSearch_Echd() {
        searchTextField_Echd.text = nil
        currentSearchText_Echd = ""
        clearSearchButton_Echd.isHidden = true
        searchTextField_Echd.resignFirstResponder()
        refreshPosts_Echd()
    }

    /// 点击空白收起键盘
    @objc private func dismissKeyboard_Echd() {
        searchTextField_Echd.resignFirstResponder()
    }

    /// 帖子卡片点击，跳转详情
    @objc private func postCardTapped_Echd(_ gesture: UITapGestureRecognizer) {
        guard let cardView_Echd = gesture.view else { return }
        let postId_Echd = cardView_Echd.tag
        let posts_Echd = TitleViewModel_Echd.shared_Echd.getPosts_Echd()

        if let post_Echd = posts_Echd.first(where: { $0.titleId_Echd == postId_Echd }) {
            cardView_Echd.animatePressDown_Echd { cardView_Echd.animatePressUp_Echd() }
            Navigation_Echd.toTitleDetail_Echd(titleModel_echd: post_Echd, style_echd: .push_echd)
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Echd),
            name: TitleViewModel_Echd.titleStateDidChangeNotification_Echd,
            object: nil
        )
    }

    @objc private func handleTitleStateChange_Echd() {
        refreshPosts_Echd()
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Echd: UITextFieldDelegate {

    /// 点击搜索键收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - 媒体底部渐变蒙版视图

/// 媒体区底部渐变蒙版（透明 → 轻度黑色半透明），提升信息区可读性
private class DiscoverGradientOverlay_Echd: UIView {

    private let gradLayer_Echd = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        gradLayer_Echd.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.18).cgColor
        ]
        gradLayer_Echd.startPoint = CGPoint(x: 0.5, y: 0)
        gradLayer_Echd.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradLayer_Echd, at: 0)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Echd.frame = bounds
    }
}
