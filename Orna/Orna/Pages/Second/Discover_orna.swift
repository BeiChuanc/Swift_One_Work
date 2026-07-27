import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页视图控制器
/// 核心作用：以不规则瀑布流展示全站帖子，支持按热度/时间筛选、举报删除与作者信息展示
/// 设计思路：
///   - 顶部渐变横幅呼应首页"桌面摆件"主题的紫粉配色，营造统一的品牌视觉基调
///   - 胶囊分段控件（All / Trending / Newest）复用 PillSegmentControl_Orna，实现真实的排序切换闭环
///   - 双列瀑布流：使用两个纵向 UIStackView 模拟不规则高度的 Masonry 布局，
///     每次插入卡片时选择当前累计高度较小的一列，媒体高度按帖子ID取模形成错落效果
///   - 帖子卡片复用 PostCardView_Orna，并按索引轮换主题色带 + 高赞帖子叠加"热门"标签，丰富色彩层次
///   - 数据随 TitleViewModel_Orna 状态变化响应式刷新
class Discover_Orna: UIViewController {

    /// 瀑布流媒体高度候选池（按帖子ID取模形成错落效果）
    private static let mediaHeightPool_Orna: [CGFloat] = [130, 175, 150, 200, 160, 190]

    /// 卡片主题色候选池（与首页摆件稀有度/强调色呼应，营造统一又丰富的色彩节奏）
    private static let accentColorPool_Orna: [String] = ["#7B61FF", "#FF6B9D", "#FF9A6C", "#5B8DEF", "#B794F6"]

    /// 排序方式
    private enum SortMode_Orna: Int { case all_Orna = 0, trending_Orna = 1, newest_Orna = 2 }

    private var sortMode_Orna: SortMode_Orna = .all_Orna

    // MARK: - UI · 顶部渐变横幅

    private let heroCardView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 16
        return v
    }()

    private var heroGradientLayer_Orna: CAGradientLayer?

    private let heroIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let heroTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Discover"
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let heroSubtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Explore cozy desks from the community"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        return l
    }()

    // MARK: - UI · 排序分段控件

    private lazy var filterControl_Orna: PillSegmentControl_Orna = {
        let control_orna = PillSegmentControl_Orna(titles_Orna: ["All", "Trending", "Newest"])
        control_orna.onSelectionChanged_Orna = { [weak self] index_orna in
            self?.sortMode_Orna = SortMode_Orna(rawValue: index_orna) ?? .all_Orna
            self?.refreshAll_Orna()
        }
        return control_orna
    }()

    // MARK: - UI · 瀑布流容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    private let columnsRow_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 14
        sv.alignment = .top
        sv.distribution = .fillEqually
        return sv
    }()

    private let leftColumn_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    private let rightColumn_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    private let emptyLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "No posts yet. Be the first to share your desk!"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        observeStateChanges_Orna()
        refreshAll_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAll_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradientLayer_Orna?.frame = heroCardView_Orna.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(heroCardView_Orna)
        heroCardView_Orna.addSubview(heroIconView_Orna)
        heroCardView_Orna.addSubview(heroTitleLabel_Orna)
        heroCardView_Orna.addSubview(heroSubtitleLabel_Orna)
        setupHeroGradient_Orna()

        view.addSubview(filterControl_Orna)

        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        contentView_Orna.addSubview(columnsRow_Orna)
        columnsRow_Orna.addArrangedSubview(leftColumn_Orna)
        columnsRow_Orna.addArrangedSubview(rightColumn_Orna)
        contentView_Orna.addSubview(emptyLabel_Orna)
    }

    /// 搭建横幅紫粉渐变，呼应首页签到卡片的强调色系
    private func setupHeroGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor,
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 24
        heroCardView_Orna.layer.insertSublayer(layer_orna, at: 0)
        heroGradientLayer_Orna = layer_orna
    }

    private func setupConstraints_Orna() {
        heroCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(92)
        }
        heroIconView_Orna.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
        heroTitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
        }
        heroSubtitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(heroTitleLabel_Orna)
            $0.top.equalTo(heroTitleLabel_Orna.snp.bottom).offset(6)
            $0.trailing.lessThanOrEqualTo(heroIconView_Orna.snp.leading).offset(-12)
        }

        filterControl_Orna.snp.makeConstraints {
            $0.top.equalTo(heroCardView_Orna.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(220)
            $0.height.equalTo(38)
        }

        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(filterControl_Orna.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        columnsRow_Orna.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            // 底部预留悬浮导航栏遮挡高度，确保内容可以完全滚动到导航栏上方，不被其遮盖
            $0.bottom.equalToSuperview().offset(-TabBar_Orna.floatingBarClearance_Orna)
        }
        emptyLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    // MARK: - 状态监听

    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: TitleViewModel_Orna.titleStateDidChangeNotification_Orna, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna, object: nil
        )
    }

    // MARK: - 数据刷新

    /// 重新构建双列瀑布流：按当前排序方式排列帖子，并按累计高度较小的列依次插入帖子卡片
    @objc private func refreshAll_Orna() {
        leftColumn_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightColumn_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let allPosts_orna = TitleViewModel_Orna.shared_Orna.getPosts_Orna().reversed().map { $0 }
        let posts_orna = sortedPosts_Orna(allPosts_orna)
        emptyLabel_Orna.isHidden = !posts_orna.isEmpty

        // 取点赞数前三视为热门，叠加"热门"标签强调
        let hotIds_orna = Set(
            allPosts_orna.sorted { $0.likes_Orna > $1.likes_Orna }
                .prefix(3)
                .filter { $0.likes_Orna > 0 }
                .map { $0.titleId_Orna }
        )

        var leftHeight_orna: CGFloat = 0
        var rightHeight_orna: CGFloat = 0

        for (index_orna, post_orna) in posts_orna.enumerated() {
            let mediaHeight_orna = Self.mediaHeightPool_Orna[abs(post_orna.titleId_Orna) % Self.mediaHeightPool_Orna.count]
            let estimatedCardHeight_orna = mediaHeight_orna + 130
            let accentColor_orna = Self.accentColorPool_Orna[index_orna % Self.accentColorPool_Orna.count]

            let card_orna = PostCardView_Orna()
            card_orna.configure_Orna(
                post_orna: post_orna,
                from: self,
                showAuthor_orna: true,
                showContentPreview_orna: true,
                mediaHeight_orna: mediaHeight_orna,
                accentColorHex_orna: accentColor_orna,
                isHot_orna: hotIds_orna.contains(post_orna.titleId_Orna)
            ) { [weak self] in
                self?.refreshAll_Orna()
            }

            if leftHeight_orna <= rightHeight_orna {
                leftColumn_Orna.addArrangedSubview(card_orna)
                leftHeight_orna += estimatedCardHeight_orna
            } else {
                rightColumn_Orna.addArrangedSubview(card_orna)
                rightHeight_orna += estimatedCardHeight_orna
            }
        }
    }

    /// 依据当前排序方式对帖子重新排序
    /// 参数：
    /// - posts_orna: 原始帖子列表（已按最新发布在前排列）
    /// 返回：排序后的帖子列表
    private func sortedPosts_Orna(_ posts_orna: [TitleModel_Orna]) -> [TitleModel_Orna] {
        switch sortMode_Orna {
        case .all_Orna:
            return posts_orna
        case .trending_Orna:
            return posts_orna.sorted { $0.likes_Orna > $1.likes_Orna }
        case .newest_Orna:
            return posts_orna.sorted { $0.titleId_Orna > $1.titleId_Orna }
        }
    }
}
