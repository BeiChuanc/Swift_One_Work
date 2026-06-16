import Foundation
import UIKit
import SnapKit

// MARK: 发现页 - 重构版

/// 发现页控制器
/// 核心作用：以双列瀑布流展示社区帖子，支持分类筛选、搜索、举报/删除、跳转帖子详情
/// 设计思路：紫蓝渐变头部 + 磨砂玻璃搜索框 + 分类标签横向滚动 + 高度错落的双列卡片
/// 关键属性：allPosts_Retrs 全量帖子，filteredPosts_Retrs 过滤后帖子，currentCategory_Retrs 当前分类
class Discover_Retrs: UIViewController {

    // MARK: - 枚举

    /// 发现页内容分类
    private enum DiscoverCategory_Retrs: String, CaseIterable {
        case all_Retrs      = "All"
        case photo_Retrs    = "Photos"
        case video_Retrs    = "Videos"
        case popular_Retrs  = "Popular"
        case latest_Retrs   = "Latest"
    }

    // MARK: - 属性

    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs

    /// 主滚动视图
    private let scrollView_Retrs    = UIScrollView()
    private let contentView_Retrs   = UIView()

    /// 渐变头部区域
    private let headerView_Retrs            = UIView()
    private let headerGradLayer_Retrs       = CAGradientLayer()
    private let headerTitleLabel_Retrs      = UILabel()
    private let headerSubLabel_Retrs        = UILabel()
    private let searchContainer_Retrs       = UIView()
    private let searchIconView_Retrs        = UIImageView()
    private let searchField_Retrs           = UITextField()

    /// 分类标签横向滚动栏
    private let categoryScrollView_Retrs    = UIScrollView()
    private let categoryStack_Retrs         = UIStackView()
    private var categoryBtns_Retrs: [UIButton] = []

    /// 瀑布流双列容器
    private let columnsWrap_Retrs   = UIView()
    private let leftColumn_Retrs    = UIStackView()
    private let rightColumn_Retrs   = UIStackView()

    /// 数据
    private var allPosts_Retrs: [TitleModel_Retrs]      = []
    private var filteredPosts_Retrs: [TitleModel_Retrs] = []
    private var currentCategory_Retrs: DiscoverCategory_Retrs = .all_Retrs
    private var searchText_Retrs: String = ""

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData_Retrs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Retrs: "#F7FAFC")
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        setupCategoryBar_Retrs()
        setupColumns_Retrs()
        setupConstraints_Retrs()
        observeNotifications_Retrs()
        reloadData_Retrs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerView_Retrs.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 主滚动视图
    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.backgroundColor = .clear
        // 禁止自动添加 SafeArea 偏移，让头部渐变紧贴屏幕顶边
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
        contentView_Retrs.backgroundColor = .clear
    }

    /// 渐变头部区域：标题 + 副标题 + 磨砂搜索框 + 装饰气泡
    private func setupHeaderView_Retrs() {
        // 紫色渐变背景
        headerGradLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#B794F6").cgColor,
            UIColor(hexstring_Retrs: "#90CDF4").cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerView_Retrs.layer.cornerRadius = 30
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡 — 右上角大圆
        let bubble1_Retrs = makeDecorBubble_Retrs(alpha_Retrs: 0.13, size_Retrs: 140)
        headerView_Retrs.addSubview(bubble1_Retrs)
        bubble1_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(40)
            make.width.height.equalTo(140)
        }

        // 装饰气泡 — 左下角小圆
        let bubble2_Retrs = makeDecorBubble_Retrs(alpha_Retrs: 0.09, size_Retrs: 90)
        headerView_Retrs.addSubview(bubble2_Retrs)
        bubble2_Retrs.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(-20)
            make.width.height.equalTo(90)
        }

        // 装饰气泡 — 右下角中圆
        let bubble3_Retrs = makeDecorBubble_Retrs(alpha_Retrs: 0.07, size_Retrs: 60)
        headerView_Retrs.addSubview(bubble3_Retrs)
        bubble3_Retrs.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-30)
            make.width.height.equalTo(60)
        }

        // 主标题
        headerTitleLabel_Retrs.text = "Discover"
        headerTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 32, weight: .black)
        headerTitleLabel_Retrs.textColor = .white
        headerView_Retrs.addSubview(headerTitleLabel_Retrs)

        // 副标题
        headerSubLabel_Retrs.text = "Explore CCD moments"
        headerSubLabel_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        headerSubLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.78)
        headerView_Retrs.addSubview(headerSubLabel_Retrs)

        // 磨砂搜索框容器
        searchContainer_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        searchContainer_Retrs.layer.cornerRadius = 18
        searchContainer_Retrs.layer.borderWidth = 1
        searchContainer_Retrs.layer.borderColor = UIColor.white.withAlphaComponent(0.38).cgColor
        headerView_Retrs.addSubview(searchContainer_Retrs)

        // 搜索图标
        searchIconView_Retrs.image = UIImage(systemName: "magnifyingglass")
        searchIconView_Retrs.tintColor = UIColor.white.withAlphaComponent(0.85)
        searchIconView_Retrs.contentMode = .scaleAspectFit
        searchContainer_Retrs.addSubview(searchIconView_Retrs)

        // 搜索输入框
        searchField_Retrs.font = UIFont.systemFont(ofSize: 14)
        searchField_Retrs.textColor = .white
        searchField_Retrs.tintColor = .white
        searchField_Retrs.returnKeyType = .search
        searchField_Retrs.attributedPlaceholder = NSAttributedString(
            string: "Search moments...",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.55),
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )
        searchField_Retrs.delegate = self
        searchField_Retrs.addTarget(self, action: #selector(onSearchTextChanged_Retrs), for: .editingChanged)
        searchContainer_Retrs.addSubview(searchField_Retrs)
    }

    /// 创建装饰气泡视图
    /// - Parameters:
    ///   - alpha_Retrs: 白色透明度
    ///   - size_Retrs: 气泡直径
    /// - Returns: 配置好的圆形 UIView
    private func makeDecorBubble_Retrs(alpha_Retrs: CGFloat, size_Retrs: CGFloat) -> UIView {
        let view_Retrs = UIView()
        view_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha_Retrs)
        view_Retrs.layer.cornerRadius = size_Retrs / 2
        return view_Retrs
    }

    /// 分类标签横向滚动栏
    private func setupCategoryBar_Retrs() {
        categoryScrollView_Retrs.showsHorizontalScrollIndicator = false
        categoryScrollView_Retrs.backgroundColor = .clear
        contentView_Retrs.addSubview(categoryScrollView_Retrs)

        categoryStack_Retrs.axis = .horizontal
        categoryStack_Retrs.spacing = 10
        categoryStack_Retrs.alignment = .center
        categoryScrollView_Retrs.addSubview(categoryStack_Retrs)

        for (idx_Retrs, cat_Retrs) in DiscoverCategory_Retrs.allCases.enumerated() {
            let btn_Retrs = makeCategoryBtn_Retrs(title_Retrs: cat_Retrs.rawValue, isSelected_Retrs: idx_Retrs == 0)
            btn_Retrs.tag = idx_Retrs
            btn_Retrs.addTarget(self, action: #selector(onCategoryTapped_Retrs(_:)), for: .touchUpInside)
            categoryStack_Retrs.addArrangedSubview(btn_Retrs)
            categoryBtns_Retrs.append(btn_Retrs)
        }
    }

    /// 创建单个分类标签按钮
    /// - Parameters:
    ///   - title_Retrs: 按钮标题
    ///   - isSelected_Retrs: 是否选中状态
    /// - Returns: 配置好的 UIButton
    private func makeCategoryBtn_Retrs(title_Retrs: String, isSelected_Retrs: Bool) -> UIButton {
        let btn_Retrs = UIButton(type: .custom)
        btn_Retrs.setTitle(title_Retrs, for: .normal)
        btn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Retrs.contentEdgeInsets = UIEdgeInsets(top: 9, left: 20, bottom: 9, right: 20)
        btn_Retrs.layer.cornerRadius = 18
        applyCategoryBtnStyle_Retrs(btn: btn_Retrs, isSelected: isSelected_Retrs)
        return btn_Retrs
    }

    /// 应用分类按钮样式
    /// - Parameters:
    ///   - btn: 目标按钮
    ///   - isSelected: 是否选中
    private func applyCategoryBtnStyle_Retrs(btn: UIButton, isSelected: Bool) {
        if isSelected {
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor(hexstring_Retrs: "#B794F6")
            btn.layer.shadowColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.45).cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowOpacity = 1
            btn.layer.shadowRadius = 8
        } else {
            btn.setTitleColor(UIColor(hexstring_Retrs: "#7B6F8A"), for: .normal)
            btn.backgroundColor = .white
            btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 2)
            btn.layer.shadowOpacity = 1
            btn.layer.shadowRadius = 4
        }
    }

    /// 双列瀑布流容器
    private func setupColumns_Retrs() {
        columnsWrap_Retrs.backgroundColor = .clear
        contentView_Retrs.addSubview(columnsWrap_Retrs)

        leftColumn_Retrs.axis = .vertical
        leftColumn_Retrs.spacing = 14
        leftColumn_Retrs.alignment = .fill
        columnsWrap_Retrs.addSubview(leftColumn_Retrs)

        rightColumn_Retrs.axis = .vertical
        rightColumn_Retrs.spacing = 14
        rightColumn_Retrs.alignment = .fill
        columnsWrap_Retrs.addSubview(rightColumn_Retrs)
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        let colW_Retrs = (screenW_Retrs - 16 * 2 - 12) / 2

        scrollView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }

        // 头部：高度 = 安全区顶部 + 内容区高度，标题从安全区顶端下方开始
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop_Retrs + 144)
        }
        headerTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 12)
            make.leading.equalToSuperview().offset(22)
        }
        headerSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Retrs.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }
        searchContainer_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerSubLabel_Retrs.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(46)
        }
        searchIconView_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        searchField_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(searchIconView_Retrs.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }

        // 分类栏
        categoryScrollView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerView_Retrs.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(46)
        }
        categoryStack_Retrs.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(46)
        }

        // 瀑布流
        columnsWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView_Retrs.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        leftColumn_Retrs.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(colW_Retrs)
            make.bottom.lessThanOrEqualToSuperview()
        }
        rightColumn_Retrs.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalTo(colW_Retrs)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    /// 重新加载全量数据并应用过滤
    private func reloadData_Retrs() {
        allPosts_Retrs = titleVM_Retrs.getPosts_Retrs()
        applyFilter_Retrs()
    }

    /// 应用分类 + 搜索文本双重过滤，重建瀑布流
    private func applyFilter_Retrs() {
        var result_Retrs = allPosts_Retrs

        // 搜索文本过滤
        if !searchText_Retrs.isEmpty {
            let keyword_Retrs = searchText_Retrs.lowercased()
            result_Retrs = result_Retrs.filter {
                $0.title_Retrs.lowercased().contains(keyword_Retrs) ||
                $0.titleContent_Retrs.lowercased().contains(keyword_Retrs)
            }
        }

        // 分类过滤
        switch currentCategory_Retrs {
        case .all_Retrs:
            break
        case .photo_Retrs:
            result_Retrs = result_Retrs.filter { post_Retrs in
                post_Retrs.titleMeidas_Retrs.contains { !isVideoPath_Retrs($0) }
            }
        case .video_Retrs:
            result_Retrs = result_Retrs.filter { post_Retrs in
                post_Retrs.titleMeidas_Retrs.contains { isVideoPath_Retrs($0) }
            }
        case .popular_Retrs:
            result_Retrs = result_Retrs.sorted { $0.likes_Retrs > $1.likes_Retrs }
        case .latest_Retrs:
            result_Retrs = result_Retrs.sorted { $0.titleId_Retrs > $1.titleId_Retrs }
        }

        filteredPosts_Retrs = result_Retrs
        rebuildWaterfall_Retrs()
    }

    /// 判断媒体路径是否为视频文件
    /// - Parameter path_Retrs: 媒体文件路径
    /// - Returns: 是否为视频
    private func isVideoPath_Retrs(_ path_Retrs: String) -> Bool {
        let lower_Retrs = path_Retrs.lowercased()
        return lower_Retrs.hasSuffix(".mp4") || lower_Retrs.hasSuffix(".mov") || lower_Retrs.hasSuffix(".m4v")
    }

    /// 清空旧卡片，重新构建双列瀑布流
    private func rebuildWaterfall_Retrs() {
        leftColumn_Retrs.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightColumn_Retrs.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if filteredPosts_Retrs.isEmpty {
            leftColumn_Retrs.addArrangedSubview(buildEmptyView_Retrs())
            return
        }

        // 高度序列制造视觉节奏感
        let imgHeights_Retrs: [CGFloat] = [200, 250, 175, 270, 215, 245, 185, 260]
        for (idx_Retrs, post_Retrs) in filteredPosts_Retrs.enumerated() {
            let imgH_Retrs = imgHeights_Retrs[idx_Retrs % imgHeights_Retrs.count]
            let card_Retrs = buildCard_Retrs(post_Retrs: post_Retrs, imageHeight_Retrs: imgH_Retrs)
            if idx_Retrs % 2 == 0 {
                leftColumn_Retrs.addArrangedSubview(card_Retrs)
            } else {
                rightColumn_Retrs.addArrangedSubview(card_Retrs)
            }
        }
    }

    // MARK: - 卡片构建

    /// 构建单个帖子卡片
    /// - Parameters:
    ///   - post_Retrs: 帖子数据模型
    ///   - imageHeight_Retrs: 媒体区域高度（产生高度错落效果）
    /// - Returns: 配置好的卡片 UIView
    private func buildCard_Retrs(post_Retrs: TitleModel_Retrs, imageHeight_Retrs: CGFloat) -> UIView {
        let card_Retrs = UIView()
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 20
        card_Retrs.clipsToBounds = false
        // 带紫色调的立体阴影
        card_Retrs.layer.shadowColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.16).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 6)
        card_Retrs.layer.shadowOpacity = 1.0
        card_Retrs.layer.shadowRadius = 16

        // 媒体容器（顶部双角圆角）
        let mediaWrap_Retrs = UIView()
        mediaWrap_Retrs.clipsToBounds = true
        mediaWrap_Retrs.layer.cornerRadius = 20
        mediaWrap_Retrs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card_Retrs.addSubview(mediaWrap_Retrs)
        mediaWrap_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageHeight_Retrs)
        }

        // 媒体视图
        let mediaView_Retrs = MediaDisplayView_Retrs()
        mediaWrap_Retrs.addSubview(mediaView_Retrs)
        mediaView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Retrs.configure_Retrs(mediaPath_Retrs: post_Retrs.titleMeidas_Retrs.first)

        // 底部渐变遮罩（透明→黑）
        let overlayView_Retrs = GradientOverlayView_Retrs(
            colors_Retrs: [UIColor.clear, UIColor.black.withAlphaComponent(0.52)],
            startPoint_Retrs: CGPoint(x: 0.5, y: 0),
            endPoint_Retrs: CGPoint(x: 0.5, y: 1)
        )
        mediaWrap_Retrs.addSubview(overlayView_Retrs)
        overlayView_Retrs.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(90)
        }

        // 点赞数展示（图片左下角）
        let likeRow_Retrs = buildLikeRow_Retrs(count_Retrs: post_Retrs.likes_Retrs)
        mediaWrap_Retrs.addSubview(likeRow_Retrs)
        likeRow_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 评论数展示（点赞右侧）
        let commentRow_Retrs = buildStatRow_Retrs(icon_Retrs: "bubble.right.fill",
                                                   count_Retrs: post_Retrs.reviews_Retrs.count,
                                                   color_Retrs: UIColor(hexstring_Retrs: "#90CDF4"))
        mediaWrap_Retrs.addSubview(commentRow_Retrs)
        commentRow_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(likeRow_Retrs.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 视频标识（右上角，仅视频帖子显示）
        let hasVideo_Retrs = post_Retrs.titleMeidas_Retrs.contains { isVideoPath_Retrs($0) }
        if hasVideo_Retrs {
            let videoBadge_Retrs = buildVideoBadge_Retrs()
            mediaWrap_Retrs.addSubview(videoBadge_Retrs)
            videoBadge_Retrs.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.leading.equalToSuperview().offset(10)
                make.height.equalTo(22)
                make.width.equalTo(44)
            }
        }

        // 举报/删除按钮（右上角）
        let menuBtn_Retrs = ReportDeleteHelper_Retrs.createPostReportButton_Retrs(
            post_Retrs: post_Retrs,
            size_Retrs: 14,
            color_Retrs: .white,
            from: self,
            completion_Retrs: { [weak self] in self?.reloadData_Retrs() }
        )
        menuBtn_Retrs.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        menuBtn_Retrs.layer.cornerRadius = 12
        mediaWrap_Retrs.addSubview(menuBtn_Retrs)
        menuBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(24)
        }

        // 用户信息行
        let infoRow_Retrs = buildUserInfoRow_Retrs(post_Retrs: post_Retrs)
        card_Retrs.addSubview(infoRow_Retrs)
        infoRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(mediaWrap_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(26)
        }

        // 帖子标题
        let titleLabel_Retrs = UILabel()
        titleLabel_Retrs.text = post_Retrs.title_Retrs
        titleLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        titleLabel_Retrs.numberOfLines = 2
        card_Retrs.addSubview(titleLabel_Retrs)
        titleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(infoRow_Retrs.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        // 帖子内容摘要
        let contentLabel_Retrs = UILabel()
        contentLabel_Retrs.text = post_Retrs.titleContent_Retrs
        contentLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        contentLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        contentLabel_Retrs.numberOfLines = 2
        card_Retrs.addSubview(contentLabel_Retrs)
        contentLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Retrs.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-12)
        }

        // 点击整张卡片跳转详情
        let tap_Retrs = BlockTapGesture_Retrs { [weak self] in
            guard let self else { return }
            Navigation_Retrs.toTitleDetail_Retrs(titleModel_retrs: post_Retrs)
        }
        card_Retrs.addGestureRecognizer(tap_Retrs)
        card_Retrs.isUserInteractionEnabled = true

        return card_Retrs
    }

    /// 构建点赞数行（心形图标 + 数量）
    /// - Parameter count_Retrs: 点赞数
    /// - Returns: 组合的行视图
    private func buildLikeRow_Retrs(count_Retrs: Int) -> UIView {
        buildStatRow_Retrs(
            icon_Retrs: "heart.fill",
            count_Retrs: count_Retrs,
            color_Retrs: UIColor(hexstring_Retrs: "#FF6B9D")
        )
    }

    /// 构建通用统计行（图标 + 数量）
    /// - Parameters:
    ///   - icon_Retrs: SF Symbol 图标名称
    ///   - count_Retrs: 数量
    ///   - color_Retrs: 图标颜色
    /// - Returns: 组合的行视图
    private func buildStatRow_Retrs(icon_Retrs: String, count_Retrs: Int, color_Retrs: UIColor) -> UIView {
        let row_Retrs = UIView()
        let iconView_Retrs = UIImageView(image: UIImage(systemName: icon_Retrs))
        iconView_Retrs.tintColor = color_Retrs
        iconView_Retrs.contentMode = .scaleAspectFit
        row_Retrs.addSubview(iconView_Retrs)
        iconView_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        let countLabel_Retrs = UILabel()
        countLabel_Retrs.text = formatCount_Retrs(count_Retrs)
        countLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        countLabel_Retrs.textColor = .white
        row_Retrs.addSubview(countLabel_Retrs)
        countLabel_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Retrs.snp.trailing).offset(3)
            make.centerY.trailing.equalToSuperview()
        }
        return row_Retrs
    }

    /// 构建视频标识徽章
    /// - Returns: 配置好的视频徽章视图
    private func buildVideoBadge_Retrs() -> UIView {
        let badge_Retrs = UIView()
        badge_Retrs.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        badge_Retrs.layer.cornerRadius = 11
        let playIcon_Retrs = UIImageView(image: UIImage(systemName: "play.fill"))
        playIcon_Retrs.tintColor = .white
        playIcon_Retrs.contentMode = .scaleAspectFit
        badge_Retrs.addSubview(playIcon_Retrs)
        playIcon_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(10)
        }
        return badge_Retrs
    }

    /// 构建用户信息行（头像 + 昵称）
    /// - Parameter post_Retrs: 帖子数据
    /// - Returns: 用户信息行视图
    private func buildUserInfoRow_Retrs(post_Retrs: TitleModel_Retrs) -> UIView {
        let row_Retrs = UIView()
        let avatar_Retrs = UserAvatarView_Retrs()
        row_Retrs.addSubview(avatar_Retrs)
        avatar_Retrs.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(26)
        }
        avatar_Retrs.configure_Retrs(userId_Retrs: post_Retrs.titleUserId_Retrs)

        let nameLabel_Retrs = UILabel()
        nameLabel_Retrs.text = post_Retrs.titleUserName_Retrs
        nameLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        nameLabel_Retrs.textColor = UIColor(hexstring_Retrs: "#B794F6")
        nameLabel_Retrs.numberOfLines = 1
        row_Retrs.addSubview(nameLabel_Retrs)
        nameLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatar_Retrs.snp.trailing).offset(6)
            make.trailing.equalToSuperview()
        }
        return row_Retrs
    }

    /// 数字格式化：超过1000显示为 x.xk
    /// - Parameter count_Retrs: 原始数字
    /// - Returns: 格式化字符串
    private func formatCount_Retrs(_ count_Retrs: Int) -> String {
        count_Retrs >= 1000 ? String(format: "%.1fk", Double(count_Retrs) / 1000.0) : "\(count_Retrs)"
    }

    /// 构建空状态视图（无帖子时显示）
    /// - Returns: 配置好的空状态 UIView
    private func buildEmptyView_Retrs() -> UIView {
        let empty_Retrs = UIView()

        let gradIconBg_Retrs = GradientOverlayView_Retrs(
            colors_Retrs: [UIColor(hexstring_Retrs: "#B794F6"), UIColor(hexstring_Retrs: "#90CDF4")],
            startPoint_Retrs: CGPoint(x: 0, y: 0),
            endPoint_Retrs: CGPoint(x: 1, y: 1)
        )
        gradIconBg_Retrs.layer.cornerRadius = 36
        gradIconBg_Retrs.clipsToBounds = true
        empty_Retrs.addSubview(gradIconBg_Retrs)
        gradIconBg_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.height.equalTo(72)
        }

        let iconView_Retrs = UIImageView(image: UIImage(systemName: "sparkles"))
        iconView_Retrs.tintColor = .white
        iconView_Retrs.contentMode = .scaleAspectFit
        gradIconBg_Retrs.addSubview(iconView_Retrs)
        iconView_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(34)
        }

        let titleLabel_Retrs = UILabel()
        titleLabel_Retrs.text = "No posts found"
        titleLabel_Retrs.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel_Retrs.textColor = UIColor(hexstring_Retrs: "#8B6BA8")
        titleLabel_Retrs.textAlignment = .center
        empty_Retrs.addSubview(titleLabel_Retrs)
        titleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(gradIconBg_Retrs.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        let subLabel_Retrs = UILabel()
        subLabel_Retrs.text = "Try a different category"
        subLabel_Retrs.font = UIFont.systemFont(ofSize: 12)
        subLabel_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        subLabel_Retrs.textAlignment = .center
        empty_Retrs.addSubview(subLabel_Retrs)
        subLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Retrs.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }

        return empty_Retrs
    }

    // MARK: - 交互事件

    /// 分类标签被点击
    @objc private func onCategoryTapped_Retrs(_ sender: UIButton) {
        let allCases_Retrs = DiscoverCategory_Retrs.allCases
        guard sender.tag < allCases_Retrs.count else { return }
        currentCategory_Retrs = allCases_Retrs[sender.tag]
        refreshCategoryBtnsStyle_Retrs(selectedIndex_Retrs: sender.tag)
        applyFilter_Retrs()
    }

    /// 搜索文本变化
    @objc private func onSearchTextChanged_Retrs(_ sender: UITextField) {
        searchText_Retrs = sender.text ?? ""
        applyFilter_Retrs()
    }

    /// 刷新所有分类按钮的选中样式
    /// - Parameter selectedIndex_Retrs: 当前选中下标
    private func refreshCategoryBtnsStyle_Retrs(selectedIndex_Retrs: Int) {
        for (idx_Retrs, btn_Retrs) in categoryBtns_Retrs.enumerated() {
            applyCategoryBtnStyle_Retrs(btn: btn_Retrs, isSelected: idx_Retrs == selectedIndex_Retrs)
        }
    }

    // MARK: - 通知

    private func observeNotifications_Retrs() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStateChange_Retrs),
            name: TitleViewModel_Retrs.titleStateDidChangeNotification_Retrs,
            object: nil
        )
    }

    @objc private func onStateChange_Retrs() {
        reloadData_Retrs()
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Retrs: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - 渐变层辅助视图

/// 自动追踪父视图尺寸的渐变 UIView
/// 解决 CAGradientLayer 在 Auto Layout 场景下 frame 不更新的问题
private class GradientOverlayView_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    /// 初始化渐变视图
    /// - Parameters:
    ///   - colors_Retrs: 渐变颜色数组
    ///   - startPoint_Retrs: 渐变起始点
    ///   - endPoint_Retrs: 渐变结束点
    init(colors_Retrs: [UIColor], startPoint_Retrs: CGPoint, endPoint_Retrs: CGPoint) {
        super.init(frame: .zero)
        gradLayer_Retrs.colors = colors_Retrs.map { $0.cgColor }
        gradLayer_Retrs.startPoint = startPoint_Retrs
        gradLayer_Retrs.endPoint = endPoint_Retrs
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
    }
}

// MARK: - 带闭包回调的点击手势（内部辅助类）

/// 支持闭包回调的点击手势识别器
private class BlockTapGesture_Retrs: UITapGestureRecognizer {

    private var action_Retrs: () -> Void

    init(action_Retrs: @escaping () -> Void) {
        self.action_Retrs = action_Retrs
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Retrs))
    }

    @objc private func handleTap_Retrs() {
        action_Retrs()
    }
}
