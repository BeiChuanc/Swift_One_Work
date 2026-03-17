import UIKit
import SnapKit
import FSPagerView

// MARK: 精选轮播单条目 Cell（FSPagerView 内部使用）

/// 精选轮播内部条目 Cell
/// 核心作用：作为 FSPagerView 的单项，展示帖子封面、标题和作者名
/// 设计：全高图片 + 底部渐变遮罩 + 窗框圆角边框
private class FeaturedPageCell_Pane: FSPagerViewCell {

    // MARK: - UI组件

    /// 媒体封面（铺满）
    let coverMedia_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.layer.cornerRadius = 0
        v.clipsToBounds = true
        return v
    }()

    /// 底部渐变遮罩
    private let gradientView_Pane = UIView()
    private var gradientLayer_Pane: CAGradientLayer?

    /// 帖子标题
    let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    /// 作者标签（附带人物图标）
    let authorContainer_Pane: UIView = UIView()

    private let authorIcon_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.85)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let authorLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        return l
    }()

    /// 窗框装饰边框（细白描边）
    private let frameBorder_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.borderWidth  = 1.2
        v.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Pane?.frame = gradientView_Pane.bounds
    }

    // MARK: - UI布局

    private func setupUI_Pane() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        // 媒体封面
        contentView.addSubview(coverMedia_Pane)
        coverMedia_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 底部渐变（占 55%）
        contentView.addSubview(gradientView_Pane)
        gradientView_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.55)
        }

        let gl = CAGradientLayer()
        gl.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.80).cgColor
        ]
        gl.startPoint = CGPoint(x: 0.5, y: 0)
        gl.endPoint   = CGPoint(x: 0.5, y: 1)
        gradientView_Pane.layer.addSublayer(gl)
        gradientLayer_Pane = gl

        // 标题
        contentView.addSubview(titleLabel_Pane)
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-44)
        }

        // 作者区域
        contentView.addSubview(authorContainer_Pane)
        authorContainer_Pane.addSubview(authorIcon_Pane)
        authorContainer_Pane.addSubview(authorLabel_Pane)

        authorContainer_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(22)
        }

        authorIcon_Pane.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }

        authorLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(authorIcon_Pane.snp.trailing).offset(5)
            $0.centerY.trailing.equalToSuperview()
        }

        // 窗框装饰（覆盖整个 contentView，不遮挡交互）
        contentView.addSubview(frameBorder_Pane)
        frameBorder_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 数据配置

    /// 配置条目内容
    /// - Parameter post_pane: 帖子数据模型
    func configure_Pane(post_pane: TitleModel_Pane) {
        coverMedia_Pane.configure_Pane(mediaPath_Pane: post_pane.titleMeidas_Pane.first)
        titleLabel_Pane.text  = post_pane.title_Pane
        authorLabel_Pane.text = post_pane.titleUserName_Pane
    }
}

// MARK: - 精选轮播容器 Cell（UICollectionView Section 0 使用）

/// 首页精选轮播容器 Cell
/// 核心作用：封装 FSPagerView，作为首页第 0 个 Section 的单一 Cell，展示精选帖子自动轮播
/// 设计理念：卡片式轮播，卡片间带间距，支持无限循环和自动滑动
/// 关键方法：configure_Pane(posts:) - 外部传入帖子数组刷新轮播内容
class HomeFeaturedCell_Pane: UICollectionViewCell, FSPagerViewDataSource, FSPagerViewDelegate {

    // MARK: - 静态常量

    /// Cell 复用标识符
    static let reuseId_Pane = "HomeFeaturedCell_Pane"

    /// 内部 FSPagerViewCell 复用标识符
    private static let innerCellId_Pane = "FeaturedPageCell_Pane"

    // MARK: - UI组件

    /// 核心轮播视图
    private let pagerView_Pane: FSPagerView = {
        let pager = FSPagerView()
        pager.isInfinite          = true
        pager.automaticSlidingInterval = 3.5
        pager.interitemSpacing    = 12
        pager.decelerationDistance = FSPagerView.automaticDistance
        return pager
    }()

    /// 底部页码指示器
    private let pageControl_Pane: FSPageControl = {
        let pc = FSPageControl()
        pc.hidesForSinglePage     = true
        pc.setFillColor(ColorConfig_Pane.primaryGradientStart_Pane, for: .selected)
        pc.setFillColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
        pc.itemSpacing            = 6
        pc.interitemSpacing       = 6
        return pc
    }()

    // MARK: - 属性

    /// 当前展示的帖子数组（最多 5 条）
    private var posts_Pane: [TitleModel_Pane] = []

    /// 帖子点击回调，由外部 VC 处理导航
    var onPostTapped_Pane: ((TitleModel_Pane) -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPagerView_Pane()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 轮播视图宽度计算（两侧露出相邻卡片边缘）
        pagerView_Pane.itemSize = CGSize(
            width:  contentView.bounds.width - 60,
            height: contentView.bounds.height - 10
        )
    }

    // MARK: - UI布局

    private func setupPagerView_Pane() {
        // 注册内部 Cell
        pagerView_Pane.register(
            FeaturedPageCell_Pane.self,
            forCellWithReuseIdentifier: Self.innerCellId_Pane
        )
        pagerView_Pane.dataSource = self
        pagerView_Pane.delegate   = self

        contentView.addSubview(pagerView_Pane)
        pagerView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }

        contentView.addSubview(pageControl_Pane)
        pageControl_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-4)
            $0.height.equalTo(16)
        }
    }

    // MARK: - 数据配置

    /// 配置轮播内容
    /// - Parameter posts_pane: 帖子数组，取前 5 条展示
    func configure_Pane(posts_pane: [TitleModel_Pane]) {
        posts_Pane = Array(posts_pane.prefix(5))
        pageControl_Pane.numberOfPages = posts_Pane.count
        pageControl_Pane.currentPage   = 0
        // reloadData 会自动重置到第一页，不需要额外调用 scrollToItem
        // 在 reloadData 完成前调用 scrollToItem 会导致索引越界崩溃
        pagerView_Pane.reloadData()
    }

    // MARK: - FSPagerViewDataSource

    /// 返回轮播总条目数
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return posts_Pane.count
    }

    /// 返回指定索引的轮播条目 Cell
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell_pane = pagerView.dequeueReusableCell(
            withReuseIdentifier: Self.innerCellId_Pane,
            at: index
        ) as? FeaturedPageCell_Pane else {
            return pagerView.dequeueReusableCell(
                withReuseIdentifier: Self.innerCellId_Pane,
                at: index
            )
        }
        cell_pane.configure_Pane(post_pane: posts_Pane[index])
        return cell_pane
    }

    // MARK: - FSPagerViewDelegate

    /// 用户点击轮播条目后触发导航回调
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        guard index < posts_Pane.count else { return }
        onPostTapped_Pane?(posts_Pane[index])
    }

    /// 轮播翻页时同步更新页码指示器
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl_Pane.currentPage = pagerView.currentIndex
    }
}
