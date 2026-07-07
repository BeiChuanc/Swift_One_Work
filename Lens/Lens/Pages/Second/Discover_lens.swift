import Foundation
import UIKit
import SnapKit

// MARK: - 瀑布流布局协议

/// 瀑布流布局高度代理协议
/// 布局在计算每个 Cell 的 frame 时，通过此协议询问高度
protocol WaterfallLayoutDelegate_Lens: AnyObject {
    /// 返回指定 indexPath 处 Cell 的高度
    /// - Parameters:
    ///   - collectionView: 所属集合视图
    ///   - indexPath: 目标 Cell 的 indexPath
    ///   - columnWidth_Lens: 当前列宽
    /// - Returns: Cell 高度（pt）
    func collectionView(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        columnWidth columnWidth_Lens: CGFloat
    ) -> CGFloat
}

// MARK: - 自定义瀑布流布局

/// 双列不规则瀑布流布局
/// 核心作用：根据内容动态计算每个 Cell 的高度，两列分别追踪总高度，每次将新 Cell 放入较短的列
/// 设计思路：
///   - prepare() 每次被调用时完整重算所有 Cell 的 frame 并缓存
///   - layoutAttributesForElements(in:) 直接返回缓存中与可视区域相交的属性
class WaterfallLayout_Lens: UICollectionViewLayout {

    // MARK: - 可配置参数

    /// 列数，默认 2
    var columnCount_Lens: Int = 2

    /// 左右外边距
    var horizontalPadding_Lens: CGFloat = 12

    /// 列间距
    var columnSpacing_Lens: CGFloat = 10

    /// 行间距（Cell 之间的纵向间隙）
    var rowSpacing_Lens: CGFloat = 10

    /// 顶部内边距
    var topPadding_Lens: CGFloat = 12

    /// 底部内边距
    var bottomPadding_Lens: CGFloat = 24

    /// 布局代理（提供 Cell 高度）
    weak var delegate_Lens: WaterfallLayoutDelegate_Lens?

    // MARK: - 私有缓存

    /// 布局属性缓存
    private var cache_Lens: [UICollectionViewLayoutAttributes] = []

    /// 每列当前累积高度
    private var columnHeights_Lens: [CGFloat] = []

    /// 内容总高度
    private var contentHeight_Lens: CGFloat = 0

    /// 可用内容宽度（不含 padding）
    private var contentWidth_Lens: CGFloat {
        guard let cv_Lens = collectionView else { return 0 }
        let insets_Lens = cv_Lens.contentInset
        return cv_Lens.bounds.width - insets_Lens.left - insets_Lens.right
            - 2 * horizontalPadding_Lens
    }

    /// 单列宽度
    private var columnWidth_Lens: CGFloat {
        (contentWidth_Lens - CGFloat(columnCount_Lens - 1) * columnSpacing_Lens) / CGFloat(columnCount_Lens)
    }

    // MARK: - UICollectionViewLayout 重写

    override var collectionViewContentSize: CGSize {
        CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight_Lens)
    }

    /// 每次布局前重算所有 Cell 的位置
    override func prepare() {
        cache_Lens = []
        contentHeight_Lens = 0
        columnHeights_Lens = Array(repeating: topPadding_Lens, count: columnCount_Lens)

        guard let cv_Lens = collectionView, let delegate_Lens else { return }

        let cw_Lens = columnWidth_Lens
        let itemCount_Lens = cv_Lens.numberOfItems(inSection: 0)

        for index_Lens in 0..<itemCount_Lens {
            let indexPath_Lens = IndexPath(item: index_Lens, section: 0)
            let height_Lens = delegate_Lens.collectionView(cv_Lens, heightForItemAt: indexPath_Lens, columnWidth: cw_Lens)
            let shortestCol_Lens = columnHeights_Lens.enumerated()
                .min(by: { $0.element < $1.element })?.offset ?? 0
            let xOffset_Lens = horizontalPadding_Lens
                + CGFloat(shortestCol_Lens) * (cw_Lens + columnSpacing_Lens)
            let yOffset_Lens = columnHeights_Lens[shortestCol_Lens]
            let frame_Lens = CGRect(x: xOffset_Lens, y: yOffset_Lens, width: cw_Lens, height: height_Lens)
            let attrs_Lens = UICollectionViewLayoutAttributes(forCellWith: indexPath_Lens)
            attrs_Lens.frame = frame_Lens
            cache_Lens.append(attrs_Lens)
            columnHeights_Lens[shortestCol_Lens] += height_Lens + rowSpacing_Lens
        }

        contentHeight_Lens = (columnHeights_Lens.max() ?? topPadding_Lens) + bottomPadding_Lens
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache_Lens.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cache_Lens.count else { return nil }
        return cache_Lens[indexPath.item]
    }

    /// 宽度变化时重新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv_Lens = collectionView else { return false }
        return cv_Lens.bounds.width != newBounds.width
    }
}

// MARK: - 发现页分类枚举

/// 发现页内容筛选分类
/// 核心作用：定义发现页顶部分类标签的选项，控制数据过滤/排序逻辑
enum DiscoverCategory_Lens: Int, CaseIterable {

    /// 全部内容
    case all_lens = 0
    /// 图片类帖子
    case photos_lens = 1
    /// 视频类帖子
    case videos_lens = 2
    /// 热门帖子（按点赞数降序）
    case popular_lens = 3

    /// 分类显示标题（英文）
    var displayTitle_Lens: String {
        switch self {
        case .all_lens:     return "All"
        case .photos_lens:  return "Photos"
        case .videos_lens:  return "Videos"
        case .popular_lens: return "Popular"
        }
    }
}

// MARK: - 发现页帖子卡片 Cell（重构版）

/// 发现页帖子卡片 Cell
/// 核心作用：以媒体内容为主体，标题浮层展示，呈现更沉浸式的视觉效果
/// 设计思路：
///   - 媒体区占据卡片上方大部分，底部叠加渐变遮罩，标题文字浮于遮罩上
///   - 媒体区高度根据标题长度动态变化，增强瀑布流的不规则美感
///   - 作者行展示彩色光圈头像、用户名和点赞数统计
///   - 视频帖子左上角显示播放标识，多图帖子右上角显示数量标识
///   - 卡片外层携带阴影，圆角 18pt，整体背景 #1C1C35
class DiscoverCell_Lens: UICollectionViewCell {

    // MARK: - 静态标识

    static let reuseId_Lens = "DiscoverCell_Lens"

    // MARK: - 私有属性

    /// 举报/删除按钮引用（配置时重新创建）
    private var reportButton_Lens: UIButton?

    // MARK: - UI 组件：卡片骨架

    /// 外层阴影容器（不 clipsToBounds，承载外投影）
    private let shadowContainer_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.38
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 12
        return v
    }()

    /// 卡片主体（clipsToBounds，展示内容）
    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    // MARK: - UI 组件：媒体区

    /// 媒体视图
    private let mediaView_Lens: MediaDisplayView_Lens = {
        let v = MediaDisplayView_Lens()
        v.clipsToBounds = true
        return v
    }()

    /// 媒体区底部渐变遮罩（承载标题，增强文字可读性）
    private let mediaGradientView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 浮层标题（叠加在渐变遮罩上）
    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOpacity = 0.5
        l.layer.shadowRadius = 3
        l.layer.shadowOffset = CGSize(width: 0, height: 1)
        return l
    }()

    /// 视频标识 Badge（左上角，仅视频帖子显示）
    private let videoBadge_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.55)
        v.layer.cornerRadius = 11
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()

    /// 视频 Badge 内的播放图标
    private let videoBadgeIcon_Lens: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "play.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 多图数量 Badge（右上角，图片数 > 1 时显示）
    private let countBadge_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.55)
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()

    /// 多图数量文字（如 "1/3"）
    private let countLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件：作者行

    /// 媒体区与作者行之间的分隔线
    private let dividerLine_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        return v
    }()

    /// 作者行容器
    private let authorRow_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 头像彩色渐变光圈容器
    private let avatarRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    /// 作者头像
    private let authorAvatar_Lens: UserAvatarView_Lens = {
        let v = UserAvatarView_Lens()
        return v
    }()

    /// 作者昵称
    private let authorNameLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.6)
        return l
    }()

    /// 点赞图标
    private let likeIcon_Lens: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv.tintColor = UIColor(hexstring_Lens: "#FF6B6B")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 点赞数标签
    private let likeCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新阴影路径（避免实时计算，提升滚动性能）
        shadowContainer_Lens.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainer_Lens.bounds,
            cornerRadius: 18
        ).cgPath
        // 同步媒体渐变层尺寸
        if let gradientLayer_Lens = mediaGradientView_Lens.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer_Lens.frame = mediaGradientView_Lens.bounds
        }
        // 同步头像光圈渐变层尺寸
        if let ringLayer_Lens = avatarRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = avatarRingView_Lens.bounds
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        contentView.addSubview(shadowContainer_Lens)
        shadowContainer_Lens.addSubview(cardView_Lens)

        // 媒体区
        cardView_Lens.addSubview(mediaView_Lens)
        cardView_Lens.addSubview(mediaGradientView_Lens)
        cardView_Lens.addSubview(titleLabel_Lens)

        // Badge
        cardView_Lens.addSubview(videoBadge_Lens)
        videoBadge_Lens.addSubview(videoBadgeIcon_Lens)
        cardView_Lens.addSubview(countBadge_Lens)
        countBadge_Lens.addSubview(countLabel_Lens)

        // 作者行
        cardView_Lens.addSubview(dividerLine_Lens)
        cardView_Lens.addSubview(authorRow_Lens)
        authorRow_Lens.addSubview(avatarRingView_Lens)
        avatarRingView_Lens.addSubview(authorAvatar_Lens)
        authorRow_Lens.addSubview(authorNameLabel_Lens)
        authorRow_Lens.addSubview(likeIcon_Lens)
        authorRow_Lens.addSubview(likeCountLabel_Lens)

        setupMediaGradientLayer_Lens()
        setupAvatarRingGradient_Lens()
        setupConstraints_Lens()
    }

    /// 构建媒体区底部渐变遮罩层（透明 → 深色）
    private func setupMediaGradientLayer_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor.clear.cgColor,
            UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.85).cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0.5, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 0.5, y: 1)
        mediaGradientView_Lens.layer.addSublayer(gradient_Lens)
    }

    /// 构建头像彩色渐变光圈（紫→蓝→粉）
    private func setupAvatarRingGradient_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#C77DFF").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradient_Lens.cornerRadius = 14
        avatarRingView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
    }

    /// 建立内部约束
    private func setupConstraints_Lens() {
        shadowContainer_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        cardView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 作者行固定在卡片底部
        authorRow_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(28)
        }

        // 分隔线位于作者行上方
        dividerLine_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(authorRow_Lens.snp.top).offset(-6)
            $0.height.equalTo(0.5)
        }

        // 媒体区从顶部延伸到分隔线（高度由外部 Cell frame 决定）
        mediaView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(dividerLine_Lens.snp.top)
        }

        // 渐变遮罩覆盖媒体区底部 90pt
        mediaGradientView_Lens.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(mediaView_Lens)
            $0.height.equalTo(90)
        }

        // 标题浮于渐变遮罩，底部对齐媒体区底部
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(mediaView_Lens.snp.bottom).inset(10)
        }

        // 视频 Badge（左上角）
        videoBadge_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(22)
        }
        videoBadgeIcon_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(10)
        }

        // 多图数量 Badge（右上角）
        countBadge_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(32)
        }
        countLabel_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6))
        }

        // 头像光圈（带 2pt 间距作为边框效果）
        avatarRingView_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        authorAvatar_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }

        // 作者昵称
        authorNameLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(avatarRingView_Lens.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
        }

        // 点赞区（右侧，图标 + 数字）
        likeCountLabel_Lens.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
        likeIcon_Lens.snp.makeConstraints {
            $0.trailing.equalTo(likeCountLabel_Lens.snp.leading).offset(-3)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(11)
        }
    }

    // MARK: - 配置

    /// 配置 Cell 展示内容
    /// - Parameters:
    ///   - post_Lens: 帖子数据模型
    ///   - viewController_Lens: 发起举报/删除操作的页面引用
    func configure_Lens(post_Lens: TitleModel_Lens, from viewController_Lens: UIViewController) {
        titleLabel_Lens.text = post_Lens.title_Lens
        authorNameLabel_Lens.text = post_Lens.titleUserName_Lens
        likeCountLabel_Lens.text = formatCount_Lens(post_Lens.likes_Lens)

        // 配置媒体（判断视频/图片）
        let mediaPath_Lens = post_Lens.titleMeidas_Lens.first
        let isVideo_Lens: Bool
        if let p_Lens = mediaPath_Lens {
            let ext_Lens = (p_Lens as NSString).pathExtension.lowercased()
            isVideo_Lens = ["mp4", "mov", "m4v", "m3u8"].contains(ext_Lens)
        } else {
            isVideo_Lens = false
        }
        mediaView_Lens.configure_Lens(mediaPath_Lens: mediaPath_Lens, isVideo_Lens: isVideo_Lens)

        // 视频标识 Badge
        videoBadge_Lens.isHidden = !isVideo_Lens

        // 多图数量 Badge
        let mediaCount_Lens = post_Lens.titleMeidas_Lens.count
        if mediaCount_Lens > 1 {
            countBadge_Lens.isHidden = false
            countLabel_Lens.text = "1/\(mediaCount_Lens)"
        } else {
            countBadge_Lens.isHidden = true
        }

        // 配置头像
        authorAvatar_Lens.configure_Lens(userId_Lens: post_Lens.titleUserId_Lens)

        // 创建举报/删除按钮（每次 configure 时重建，防止 reuse 残留）
        reportButton_Lens?.removeFromSuperview()
        let btn_Lens = ReportDeleteHelper_Lens.createPostReportButton_Lens(
            post_Lens: post_Lens,
            size_Lens: 14,
            color_Lens: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.6),
            from: viewController_Lens
        )
        cardView_Lens.addSubview(btn_Lens)
        btn_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().inset(4)
            $0.width.height.equalTo(26)
        }
        reportButton_Lens = btn_Lens
    }

    /// 格式化数量显示（大于 999 转换为 k 单位）
    /// - Parameter count_Lens: 原始数量
    /// - Returns: 格式化字符串（如 "1.2k"）
    private func formatCount_Lens(_ count_Lens: Int) -> String {
        count_Lens >= 1000 ? String(format: "%.1fk", Double(count_Lens) / 1000.0) : "\(count_Lens)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel_Lens.text = nil
        authorNameLabel_Lens.text = nil
        likeCountLabel_Lens.text = nil
        videoBadge_Lens.isHidden = true
        countBadge_Lens.isHidden = true
        mediaView_Lens.configure_Lens(mediaPath_Lens: nil)
        reportButton_Lens?.removeFromSuperview()
        reportButton_Lens = nil
    }
}

// MARK: - 空状态视图

/// 发现页空状态视图
/// 核心作用：当筛选后无帖子时，向用户展示友好的引导提示
/// 设计思路：居中图标 + 主标题 + 副标题，低饱和度颜色融入暗色背景
class DiscoverEmptyView_Lens: UIView {

    // MARK: - UI 组件

    private let iconView_Lens: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "photo.stack"))
        iv.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Nothing here yet"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        l.textAlignment = .center
        return l
    }()

    private let emptySubtitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Be the first to share something amazing"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        addSubview(iconView_Lens)
        addSubview(emptyTitleLabel_Lens)
        addSubview(emptySubtitleLabel_Lens)

        iconView_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-24)
            $0.width.height.equalTo(56)
        }
        emptyTitleLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(iconView_Lens.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
        }
        emptySubtitleLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel_Lens.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }
}

// MARK: - 发现页（重构版）

/// 发现页面（重构版）
/// 核心作用：以双列不规则瀑布流展示帖子，支持分类筛选、下拉刷新、空状态展示
/// 设计思路：
///   - 顶部毛玻璃导航栏集成彩虹光谱条、标题、副标题和分类标签横向滚动栏
///   - 页面背景叠加多层径向光晕渐变（紫+蓝），营造镜头棱镜效果
///   - 分类筛选在本地数据上进行，支持全部/图片/视频/热门四种模式
///   - WaterfallLayout_Lens 负责布局，Discover_Lens 提供动态 Cell 高度
class Discover_Lens: UIViewController {

    // MARK: - 私有数据

    /// 帖子全量数据（来自 TitleViewModel）
    private var posts_Lens: [TitleModel_Lens] = []

    /// 当前选中的分类标签
    private var selectedCategory_Lens: DiscoverCategory_Lens = .all_lens

    /// 分类标签按钮数组（与 DiscoverCategory_Lens.allCases 顺序对应）
    private var categoryButtons_Lens: [UIButton] = []

    /// 根据当前分类过滤/排序后的展示数据
    private var displayPosts_Lens: [TitleModel_Lens] {
        switch selectedCategory_Lens {
        case .all_lens:
            return posts_Lens
        case .photos_lens:
            // 过滤出至少包含一张图片媒体的帖子
            return posts_Lens.filter { post_Lens in
                post_Lens.titleMeidas_Lens.contains {
                    let ext_Lens = ($0 as NSString).pathExtension.lowercased()
                    return !["mp4", "mov", "m4v", "m3u8"].contains(ext_Lens)
                }
            }
        case .videos_lens:
            // 过滤出至少包含一个视频的帖子
            return posts_Lens.filter { post_Lens in
                post_Lens.titleMeidas_Lens.contains {
                    let ext_Lens = ($0 as NSString).pathExtension.lowercased()
                    return ["mp4", "mov", "m4v", "m3u8"].contains(ext_Lens)
                }
            }
        case .popular_lens:
            // 按点赞数降序排列
            return posts_Lens.sorted { $0.likes_Lens > $1.likes_Lens }
        }
    }

    // MARK: - UI 组件：背景

    /// 多层径向光晕渐变背景装饰（不响应触摸）
    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：导航栏

    /// 导航栏容器（毛玻璃效果，浮在 collectionView 上方）
    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 导航栏毛玻璃背景层
    private let navBlurView_Lens: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        return blur
    }()

    /// 导航栏底部微渐变分隔线
    private let navBottomLine_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 彩虹光谱装饰条（棱镜主题标识）
    private let spectrumBarView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    /// 页面大标题 "Discover"
    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Discover"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        return l
    }()

    /// 副标题（独立一行，动态展示分类描述和帖子数量）
    private let navSubtitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Explore amazing content"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        return l
    }()

    /// 分类标签横向滚动容器
    private let categoryScrollView_Lens: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    /// 分类标签横向排列 StackView
    private let categoryStackView_Lens: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    // MARK: - UI 组件：内容区

    /// 瀑布流 CollectionView
    private lazy var collectionView_Lens: UICollectionView = {
        let layout_Lens = WaterfallLayout_Lens()
        layout_Lens.delegate_Lens = self
        layout_Lens.horizontalPadding_Lens = 12
        layout_Lens.columnSpacing_Lens = 10
        layout_Lens.rowSpacing_Lens = 12
        layout_Lens.topPadding_Lens = 12
        layout_Lens.bottomPadding_Lens = 30
        let cv_Lens = UICollectionView(frame: .zero, collectionViewLayout: layout_Lens)
        cv_Lens.backgroundColor = .clear
        cv_Lens.showsVerticalScrollIndicator = false
        // 禁止系统自动叠加安全区到 contentInset，避免与手动设置的 navH 重复计算产生多余空隙
        cv_Lens.contentInsetAdjustmentBehavior = .never
        cv_Lens.register(DiscoverCell_Lens.self, forCellWithReuseIdentifier: DiscoverCell_Lens.reuseId_Lens)
        return cv_Lens
    }()

    /// 下拉刷新控件
    private let refreshControl_Lens: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = UIColor(hexstring_Lens: "#7B2FF7")
        return rc
    }()

    /// 空状态视图（懒加载，首次需要时才创建）
    private lazy var emptyView_Lens = DiscoverEmptyView_Lens()

    // MARK: - 生命周期

    /// 是否已完成首次布局刷新
    private var hasInitialLayoutReload_Lens = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadData_Lens()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasInitialLayoutReload_Lens else { return }
        hasInitialLayoutReload_Lens = true
        reloadCollectionView_Lens()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        setupConstraints_Lens()
        bindActions_Lens()
        bindNotifications_Lens()
        loadData_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步所有 CAGradientLayer 尺寸
        backgroundGlowView_Lens.layer.sublayers?.forEach { $0.frame = $0.frame }
        navBottomLine_Lens.layer.sublayers?.forEach { $0.frame = navBottomLine_Lens.bounds }
        spectrumBarView_Lens.layer.sublayers?.forEach { $0.frame = spectrumBarView_Lens.bounds }

        // 更新导航栏高度（safeAreaInsets 确定后同步）
        // 布局计算：彩虹条top(12) + 彩虹条高(4) + 间距(6) + 标题高(~34) + 间距(3) + 副标题高(~17) + 间距(10) + 分类区高(40) + 底部(9) = 135
        let navH_Lens = view.safeAreaInsets.top + 135
        navBar_Lens.snp.updateConstraints { $0.height.equalTo(navH_Lens) }

        // 更新瀑布流顶部缩进（留出导航栏高度）
        if collectionView_Lens.contentInset.top != navH_Lens {
            collectionView_Lens.contentInset.top = navH_Lens
            collectionView_Lens.scrollIndicatorInsets.top = navH_Lens
            collectionView_Lens.collectionViewLayout.invalidateLayout()
        }

        // 更新底部缩进（.never 模式下需手动加入安全区 + 额外 100pt 间距）
        let bottomInset_Lens = view.safeAreaInsets.bottom + 100
        if collectionView_Lens.contentInset.bottom != bottomInset_Lens {
            collectionView_Lens.contentInset.bottom = bottomInset_Lens
            collectionView_Lens.scrollIndicatorInsets.bottom = bottomInset_Lens
            collectionView_Lens.collectionViewLayout.invalidateLayout()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")

        // 最底层：背景光晕
        view.addSubview(backgroundGlowView_Lens)
        setupBackgroundGlows_Lens()

        // 中间层：瀑布流
        view.addSubview(collectionView_Lens)
        collectionView_Lens.dataSource = self
        collectionView_Lens.delegate = self
        collectionView_Lens.refreshControl = refreshControl_Lens

        // 顶层：导航栏（毛玻璃浮层）
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(navBlurView_Lens)
        navBar_Lens.addSubview(navBottomLine_Lens)
        navBar_Lens.addSubview(spectrumBarView_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        navBar_Lens.addSubview(navSubtitleLabel_Lens)
        navBar_Lens.addSubview(categoryScrollView_Lens)
        categoryScrollView_Lens.addSubview(categoryStackView_Lens)

        setupSpectrumBar_Lens()
        setupNavBottomLine_Lens()
        setupCategoryButtons_Lens()
    }

    /// 构建页面背景多层径向光晕（左上紫色 + 右侧蓝色）
    private func setupBackgroundGlows_Lens() {
        // 左上角主光晕（紫色，棱镜主色调）
        let purpleGlow_Lens = CAGradientLayer()
        purpleGlow_Lens.type = .radial
        purpleGlow_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.3).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purpleGlow_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purpleGlow_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purpleGlow_Lens.frame = CGRect(x: -80, y: -60, width: 320, height: 320)
        backgroundGlowView_Lens.layer.addSublayer(purpleGlow_Lens)

        // 右侧辅助光晕（蓝色，棱镜折射感）
        let blueGlow_Lens = CAGradientLayer()
        blueGlow_Lens.type = .radial
        blueGlow_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.2).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blueGlow_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blueGlow_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        let screenW_Lens = UIScreen.main.bounds.width
        blueGlow_Lens.frame = CGRect(x: screenW_Lens - 50, y: 60, width: 200, height: 200)
        backgroundGlowView_Lens.layer.addSublayer(blueGlow_Lens)
    }

    /// 构建彩虹光谱装饰条渐变（红→橙→黄→绿→蓝→紫）
    private func setupSpectrumBar_Lens() {
        let colors_Lens: [UIColor] = [
            UIColor(hexstring_Lens: "#FF6B6B"),
            UIColor(hexstring_Lens: "#FFB347"),
            UIColor(hexstring_Lens: "#FFD93D"),
            UIColor(hexstring_Lens: "#6BCB77"),
            UIColor(hexstring_Lens: "#4D96FF"),
            UIColor(hexstring_Lens: "#C77DFF")
        ]
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = colors_Lens.map { $0.cgColor }
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        gradient_Lens.cornerRadius = 2
        spectrumBarView_Lens.layer.addSublayer(gradient_Lens)
    }

    /// 构建导航栏底部微渐变分隔线（中间亮、两侧淡）
    private func setupNavBottomLine_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0).cgColor,
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1).cgColor,
            UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0).cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        navBottomLine_Lens.layer.addSublayer(gradient_Lens)
    }

    /// 构建全部分类标签按钮并添加到 StackView
    private func setupCategoryButtons_Lens() {
        categoryButtons_Lens.removeAll()
        categoryStackView_Lens.arrangedSubviews.forEach { $0.removeFromSuperview() }

        DiscoverCategory_Lens.allCases.forEach { category_Lens in
            let btn_Lens = makeCategoryButton_Lens(
                title_Lens: category_Lens.displayTitle_Lens,
                tag_Lens: category_Lens.rawValue
            )
            categoryStackView_Lens.addArrangedSubview(btn_Lens)
            categoryButtons_Lens.append(btn_Lens)
        }
        updateCategoryUI_Lens()
    }

    /// 创建单个分类标签按钮
    /// - Parameters:
    ///   - title_Lens: 按钮标题（英文）
    ///   - tag_Lens: 与 DiscoverCategory_Lens.rawValue 对应的标签值
    /// - Returns: 配置好的分类按钮
    private func makeCategoryButton_Lens(title_Lens: String, tag_Lens: Int) -> UIButton {
        let btn_Lens = UIButton(type: .custom)
        btn_Lens.setTitle(title_Lens, for: .normal)
        btn_Lens.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn_Lens.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5), for: .normal)
        btn_Lens.setTitleColor(.white, for: .selected)
        btn_Lens.layer.cornerRadius = 16
        btn_Lens.clipsToBounds = true
        btn_Lens.layer.borderWidth = 1
        btn_Lens.contentEdgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
        btn_Lens.tag = tag_Lens
        btn_Lens.addTarget(self, action: #selector(categoryButtonTapped_Lens(_:)), for: .touchUpInside)
        return btn_Lens
    }

    /// 根据当前选中分类，同步所有按钮的选中/未选中视觉状态
    private func updateCategoryUI_Lens() {
        for (index_Lens, btn_Lens) in categoryButtons_Lens.enumerated() {
            let isSelected_Lens = index_Lens == selectedCategory_Lens.rawValue
            btn_Lens.isSelected = isSelected_Lens
            if isSelected_Lens {
                // 选中：紫色背景，无描边
                btn_Lens.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
                btn_Lens.layer.borderColor = UIColor.clear.cgColor
            } else {
                // 未选中：半透明背景，细描边
                btn_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08)
                btn_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12).cgColor
            }
        }
    }

    // MARK: - 约束

    private func setupConstraints_Lens() {
        // 背景光晕固定在顶部区域
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }

        // 导航栏（初始高度，viewDidLayoutSubviews 更新）
        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(120)
        }

        navBlurView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        navBottomLine_Lens.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        // 彩虹光谱条（紧贴安全区顶部下方 12pt）
        spectrumBarView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.width.equalTo(40)
            $0.height.equalTo(4)
        }

        // 大标题
        navTitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(spectrumBarView_Lens.snp.bottom).offset(6)
        }

        // 副标题（标题下方独立一行，带左侧间距）
        navSubtitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(navTitleLabel_Lens.snp.bottom).offset(3)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        // 分类标签区（副标题下方 10pt，高 40pt）
        categoryScrollView_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navSubtitleLabel_Lens.snp.bottom).offset(10)
            $0.height.equalTo(40)
        }

        categoryStackView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(categoryScrollView_Lens.snp.height)
        }

        // 瀑布流全屏铺满（顶部 contentInset 避让导航栏）
        collectionView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Lens() {
        refreshControl_Lens.addTarget(self, action: #selector(handleRefresh_Lens), for: .valueChanged)
    }

    private func bindNotifications_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChanged_Lens),
            name: TitleViewModel_Lens.titleStateDidChangeNotification_Lens,
            object: nil
        )
    }

    // MARK: - 数据

    /// 从 TitleViewModel 加载帖子数据并刷新页面
    private func loadData_Lens() {
        posts_Lens = TitleViewModel_Lens.shared_Lens.getPosts_Lens()
        reloadCollectionView_Lens()
    }

    /// 刷新瀑布流布局、数据和空状态
    private func reloadCollectionView_Lens() {
        collectionView_Lens.collectionViewLayout.invalidateLayout()
        collectionView_Lens.reloadData()
        // 根据数据量同步空状态视图和副标题
        let count_Lens = displayPosts_Lens.count
        collectionView_Lens.backgroundView = count_Lens == 0 ? emptyView_Lens : nil
        navSubtitleLabel_Lens.attributedText = makeSubtitleText_Lens(count_Lens: count_Lens)
    }

    /// 根据当前分类和数量，生成富文本副标题（数量高亮 + 描述文字）
    /// - Parameter count_Lens: 当前展示的帖子数量
    /// - Returns: 带颜色差异的 NSAttributedString
    private func makeSubtitleText_Lens(count_Lens: Int) -> NSAttributedString {
        // 数量部分（亮色）
        let countStr_Lens: String
        // 描述部分（根据分类和数量变化）
        let descStr_Lens: String

        if count_Lens == 0 {
            let attr_Lens = NSAttributedString(
                string: "No content in this category",
                attributes: [.font: UIFont.systemFont(ofSize: 13),
                             .foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)]
            )
            return attr_Lens
        }

        switch selectedCategory_Lens {
        case .all_lens:
            countStr_Lens = "\(count_Lens) posts"
            descStr_Lens = "  ·  Explore amazing content"
        case .photos_lens:
            countStr_Lens = "\(count_Lens) photos"
            descStr_Lens = "  ·  Visual stories"
        case .videos_lens:
            countStr_Lens = "\(count_Lens) videos"
            descStr_Lens = "  ·  Watch & discover"
        case .popular_lens:
            countStr_Lens = "\(count_Lens) posts"
            descStr_Lens = "  ·  Sorted by popularity"
        }

        let result_Lens = NSMutableAttributedString(
            string: countStr_Lens,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor(hexstring_Lens: "#C77DFF", alpha_Lens: 0.9)
            ]
        )
        result_Lens.append(NSAttributedString(
            string: descStr_Lens,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
            ]
        ))
        return result_Lens
    }

    @objc private func handleRefresh_Lens() {
        loadData_Lens()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.refreshControl_Lens.endRefreshing()
        }
    }

    @objc private func onTitleStateChanged_Lens() {
        loadData_Lens()
    }

    /// 分类标签点击事件
    @objc private func categoryButtonTapped_Lens(_ sender: UIButton) {
        guard let category_Lens = DiscoverCategory_Lens(rawValue: sender.tag),
              category_Lens != selectedCategory_Lens else { return }
        // 触觉反馈增强交互感
        let generator_Lens = UIImpactFeedbackGenerator(style: .light)
        generator_Lens.impactOccurred()
        selectedCategory_Lens = category_Lens
        updateCategoryUI_Lens()
        reloadCollectionView_Lens()
    }

    // MARK: - 高度计算

    /// 根据帖子标题长度动态计算 Cell 高度
    /// 媒体区高度根据标题字符数分三档变化，制造瀑布流高低错落感
    /// - Parameters:
    ///   - post_Lens: 帖子数据
    ///   - columnWidth_Lens: 当前列宽（由布局传入）
    /// - Returns: Cell 总高度（约 194.5 ~ 239.5pt）
    func calculateCellHeight_Lens(post_Lens: TitleModel_Lens, columnWidth_Lens: CGFloat) -> CGFloat {
        let titleLen_Lens = post_Lens.title_Lens.count
        let mediaH_Lens: CGFloat
        switch titleLen_Lens {
        case 0...8:  mediaH_Lens = 150   // 短标题：紧凑型
        case 9...18: mediaH_Lens = 170   // 中等标题：标准型
        default:     mediaH_Lens = 195   // 长标题：宽松型
        }
        // 总高 = 媒体区 + 分隔线(0.5) + 作者行上间距(6) + 作者行高(28) + 底部inset(10)
        return mediaH_Lens + 44.5
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Lens: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayPosts_Lens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Lens = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverCell_Lens.reuseId_Lens,
            for: indexPath
        ) as? DiscoverCell_Lens else {
            return UICollectionViewCell()
        }
        cell_Lens.configure_Lens(post_Lens: displayPosts_Lens[indexPath.item], from: self)
        return cell_Lens
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Lens: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Lens = displayPosts_Lens[indexPath.item]
        Navigation_Lens.toTitleDetail_Lens(titleModel_lens: post_Lens)
    }
}

// MARK: - WaterfallLayoutDelegate_Lens

extension Discover_Lens: WaterfallLayoutDelegate_Lens {

    func collectionView(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        columnWidth columnWidth_Lens: CGFloat
    ) -> CGFloat {
        guard indexPath.item < displayPosts_Lens.count else { return 220 }
        return calculateCellHeight_Lens(
            post_Lens: displayPosts_Lens[indexPath.item],
            columnWidth_Lens: columnWidth_Lens
        )
    }
}
