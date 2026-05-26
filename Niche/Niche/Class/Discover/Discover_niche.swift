import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 非规则瀑布流布局（Pinterest 风格）
/// 功能：实现 2 列不等高的 CollectionView 布局
/// 每次将新 item 插入高度较小的列，形成交错瀑布效果
class WaterfallLayout_Niche: UICollectionViewLayout {

    var columnCount_Niche: Int = 2
    var columnSpacing_Niche: CGFloat = 10
    var itemSpacing_Niche: CGFloat = 10
    var sectionInset_Niche: UIEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 30, right: 12)

    weak var delegate_Niche: WaterfallLayoutDelegate_Niche?

    private var _cache_niche: [UICollectionViewLayoutAttributes] = []
    private var _contentHeight_niche: CGFloat = 0
    private var _contentWidth_niche: CGFloat {
        guard let cv_niche = collectionView else { return 0 }
        return cv_niche.bounds.width - sectionInset_Niche.left - sectionInset_Niche.right
    }

    override var collectionViewContentSize: CGSize {
        CGSize(
            width: _contentWidth_niche + sectionInset_Niche.left + sectionInset_Niche.right,
            height: _contentHeight_niche + sectionInset_Niche.bottom
        )
    }

    override func prepare() {
        super.prepare()
        guard let cv_niche = collectionView else { return }
        _cache_niche.removeAll()
        _contentHeight_niche = sectionInset_Niche.top

        let colW_niche = (_contentWidth_niche - CGFloat(columnCount_Niche - 1) * columnSpacing_Niche) / CGFloat(columnCount_Niche)
        var colH_niche = Array(repeating: sectionInset_Niche.top, count: columnCount_Niche)

        for i_niche in 0..<cv_niche.numberOfItems(inSection: 0) {
            let ip_niche = IndexPath(item: i_niche, section: 0)
            let h_niche = delegate_Niche?.collectionView(cv_niche, heightForItemAt: ip_niche, columnWidth: colW_niche) ?? 220
            let col_niche = colH_niche.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let x_niche = sectionInset_Niche.left + CGFloat(col_niche) * (colW_niche + columnSpacing_Niche)
            let y_niche = colH_niche[col_niche]
            let attr_niche = UICollectionViewLayoutAttributes(forCellWith: ip_niche)
            attr_niche.frame = CGRect(x: x_niche, y: y_niche, width: colW_niche, height: h_niche)
            _cache_niche.append(attr_niche)
            colH_niche[col_niche] += h_niche + itemSpacing_Niche
            _contentHeight_niche = max(_contentHeight_niche, colH_niche[col_niche])
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        _cache_niche.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        _cache_niche[safe_niche: indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv_niche = collectionView else { return false }
        return newBounds.width != cv_niche.bounds.width
    }
}

/// WaterfallLayout 代理协议
protocol WaterfallLayoutDelegate_Niche: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat
}

// MARK: - 发现页视图控制器

/// 发现页视图控制器
/// 功能：非规则瀑布流展示帖子，支持分类过滤，入场弹性动画
/// 设计：装饰性头部（渐变光晕背景 + 装饰气泡） + 彩色分类胶囊 + 沉浸式媒体卡片
/// 卡片：全屏媒体 + 底部渐变叠字 + 玻璃拟态用户栏 + 热帖徽章 + 彩色阴影
class Discover_Niche: UIViewController {

    // MARK: - 分类配置

    /// 分类标签配置（emoji / 名称 / 关键词 / 主题色）
    private typealias CategoryItem_Niche = (emoji: String, name: String, keywords: [String], color: UIColor)

    private let _categories_niche: [CategoryItem_Niche] = [
        ("✦",  "All",      [],                                   UIColor(hexstring_Niche: "#B794F6")),
        ("🔥", "Hot",      [],                                   UIColor(hexstring_Niche: "#FF6B6B")),
        ("🌙", "Night",    ["night", "dark", "midnight"],        UIColor(hexstring_Niche: "#6C5CE7")),
        ("💫", "Stories",  ["stories", "story", "moment"],       UIColor(hexstring_Niche: "#FD79A8")),
        ("✨", "Magic",    ["magic", "magical", "glow", "stars"],UIColor(hexstring_Niche: "#FDCB6E")),
        ("🌿", "Peace",    ["peace", "quiet", "serenity"],       UIColor(hexstring_Niche: "#55EFC4")),
        ("💬", "Talk",     ["friends", "chat", "together"],      UIColor(hexstring_Niche: "#74B9FF"))
    ]

    /// 当前选中分类下标
    private var _selectedCategory_niche: Int = 0

    // MARK: - 卡片强调色

    private let _accentPalette_niche: [UIColor] = [
        UIColor(hexstring_Niche: "#B794F6"),
        UIColor(hexstring_Niche: "#FF6B9D"),
        UIColor(hexstring_Niche: "#4ECDC4"),
        UIColor(hexstring_Niche: "#FDCB6E"),
        UIColor(hexstring_Niche: "#74B9FF"),
        UIColor(hexstring_Niche: "#55EFC4"),
        UIColor(hexstring_Niche: "#A29BFE")
    ]

    // MARK: - 数据

    private var _allPosts_niche: [TitleModel_Niche] = []
    private var _posts_niche:    [TitleModel_Niche] = []

    // MARK: - 分类按钮缓存

    private var _categoryBtns_niche: [UIButton] = []

    // MARK: - UI 组件

    /// 整体背景（固定最底层）
    private let _bgView_niche = UIView()

    /// 顶部装饰区（含光晕气泡 + 标题）
    private let _headerBg_niche = UIView()

    /// 右上角装饰气泡（大）
    private let _blobLarge_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = ColorConfig_Niche.primaryGradientStart_Niche.withValues(alpha: 0.14)
        v_niche.layer.cornerRadius = 64
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    /// 左侧装饰气泡（小）
    private let _blobSmall_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = ColorConfig_Niche.primaryGradientEnd_Niche.withValues(alpha: 0.10)
        v_niche.layer.cornerRadius = 36
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    /// 底部装饰气泡（中）
    private let _blobMid_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = ColorConfig_Niche.secondaryGradientStart_Niche.withValues(alpha: 0.10)
        v_niche.layer.cornerRadius = 46
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    /// 顶部内容容器（标题 + 分类）
    private let _headerContent_niche = UIView()

    /// 大标题
    private let _titleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Discover"
        l_niche.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        l_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        return l_niche
    }()

    /// 标题旁装饰图标
    private let _titleDecorLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "✦"
        l_niche.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche
        return l_niche
    }()

    /// 帖子数量渐变胶囊
    private let _countPill_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        l_niche.layer.cornerRadius = 9
        l_niche.layer.masksToBounds = true
        return l_niche
    }()

    /// 副标题
    private let _subtitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        return l_niche
    }()

    /// 分类滚动区
    private let _catScrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsHorizontalScrollIndicator = false
        sv_niche.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv_niche
    }()

    private let _catStack_niche: UIStackView = {
        let sv_niche = UIStackView()
        sv_niche.axis = .horizontal
        sv_niche.spacing = 8
        sv_niche.alignment = .center
        return sv_niche
    }()

    /// 瀑布流 CollectionView
    private lazy var _collectionView_niche: UICollectionView = {
        let layout_niche = WaterfallLayout_Niche()
        layout_niche.delegate_Niche = self
        let cv_niche = UICollectionView(frame: .zero, collectionViewLayout: layout_niche)
        cv_niche.backgroundColor = .clear
        cv_niche.showsVerticalScrollIndicator = false
        cv_niche.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        cv_niche.register(DiscoverCell_Niche.self, forCellWithReuseIdentifier: DiscoverCell_Niche.reuseId_Niche)
        cv_niche.dataSource = self
        cv_niche.delegate = self
        return cv_niche
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        buildCategoryTags_Niche()
        setupObservers_Niche()
        loadAllData_Niche()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F0F2FF")

        // 背景（整页底色）
        view.addSubview(_bgView_niche)
        _bgView_niche.backgroundColor = UIColor(hexstring_Niche: "#F0F2FF")
        _bgView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 顶部装饰区背景
        view.addSubview(_headerBg_niche)
        _headerBg_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(210)
        }

        // 装饰气泡（右上大）
        _headerBg_niche.addSubview(_blobLarge_niche)
        _blobLarge_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview().offset(20)
            make.width.height.equalTo(128)
        }

        // 装饰气泡（左侧小）
        _headerBg_niche.addSubview(_blobSmall_niche)
        _blobSmall_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(-16)
            make.width.height.equalTo(72)
        }

        // 装饰气泡（右下中）
        _headerBg_niche.addSubview(_blobMid_niche)
        _blobMid_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-50)
            make.width.height.equalTo(92)
        }

        // 顶部内容（标题 + 分类）
        view.addSubview(_headerContent_niche)
        _headerContent_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.leading.trailing.equalToSuperview()
        }

        // 标题行（✦ + Discover + 胶囊）
        _headerContent_niche.addSubview(_titleDecorLabel_niche)
        _titleDecorLabel_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(14)
        }

        _headerContent_niche.addSubview(_titleLabel_niche)
        _titleLabel_niche.snp.makeConstraints { make in
            make.leading.equalTo(_titleDecorLabel_niche.snp.trailing).offset(6)
            make.centerY.equalTo(_titleDecorLabel_niche)
        }

        _headerContent_niche.addSubview(_countPill_niche)
        _countPill_niche.snp.makeConstraints { make in
            make.leading.equalTo(_titleLabel_niche.snp.trailing).offset(8)
            make.centerY.equalTo(_titleLabel_niche)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(30)
        }

        // 副标题
        _headerContent_niche.addSubview(_subtitleLabel_niche)
        _subtitleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_titleLabel_niche.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(18)
        }

        // 分类标签横向滚动
        _headerContent_niche.addSubview(_catScrollView_niche)
        _catScrollView_niche.snp.makeConstraints { make in
            make.top.equalTo(_subtitleLabel_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
            make.bottom.equalToSuperview().offset(-6)
        }

        _catScrollView_niche.addSubview(_catStack_niche)
        _catStack_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        // CollectionView（header 下方）
        view.addSubview(_collectionView_niche)
        _collectionView_niche.snp.makeConstraints { make in
            make.top.equalTo(_headerContent_niche.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        // 确保头部内容始终在 CollectionView 上层，防止滚动时被卡片遮挡
        view.bringSubviewToFront(_headerContent_niche)
    }

    /// 更新顶部装饰背景渐变
    private func refreshHeaderGradient_Niche() {
        _headerBg_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _headerBg_niche.bounds
        grad_niche.colors = [
            UIColor.white.cgColor,
            UIColor(hexstring_Niche: "#F0F2FF").cgColor
        ]
        grad_niche.startPoint = CGPoint(x: 0.5, y: 0)
        grad_niche.endPoint = CGPoint(x: 0.5, y: 1)
        _headerBg_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    // MARK: - 分类标签构建

    private func buildCategoryTags_Niche() {
        _categoryBtns_niche.removeAll()
        _catStack_niche.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (i_niche, item_niche) in _categories_niche.enumerated() {
            let btn_niche = makeCategoryBtn_Niche(item: item_niche, index: i_niche)
            _catStack_niche.addArrangedSubview(btn_niche)
            _categoryBtns_niche.append(btn_niche)
        }
        refreshCategoryStyle_Niche()
    }

    /// 构建单个分类按钮
    private func makeCategoryBtn_Niche(item: CategoryItem_Niche, index: Int) -> UIButton {
        let btn_niche = UIButton(type: .custom)
        btn_niche.tag = index
        btn_niche.layer.cornerRadius = 17
        btn_niche.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        btn_niche.setTitle("\(item.emoji)  \(item.name)", for: .normal)
        btn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn_niche.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
        btn_niche.addTarget(self, action: #selector(handleCategoryTap_Niche(_:)), for: .touchUpInside)
        return btn_niche
    }

    /// 刷新所有分类按钮的选中/未选中样式
    private func refreshCategoryStyle_Niche() {
        for (i_niche, btn_niche) in _categoryBtns_niche.enumerated() {
            let item_niche = _categories_niche[i_niche]
            btn_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

            if i_niche == _selectedCategory_niche {
                // 选中：渐变背景 + 白色文字 + 彩色阴影
                btn_niche.setTitleColor(.white, for: .normal)
                btn_niche.backgroundColor = .clear

                let grad_niche = CAGradientLayer()
                grad_niche.cornerRadius = 17
                grad_niche.colors = [item_niche.color.cgColor,
                                     item_niche.color.withValues(alpha: 0.7).cgColor]
                grad_niche.startPoint = CGPoint(x: 0, y: 0)
                grad_niche.endPoint = CGPoint(x: 1, y: 1)
                // 先获取一个估算 bounds（btn 可能还未布局）
                let estimatedW_niche = CGFloat(14 * 2 + item_niche.name.count * 8 + 30)
                grad_niche.frame = CGRect(x: 0, y: 0, width: estimatedW_niche, height: 34)
                btn_niche.layer.insertSublayer(grad_niche, at: 0)

                btn_niche.layer.shadowColor  = item_niche.color.cgColor
                btn_niche.layer.shadowOffset = CGSize(width: 0, height: 4)
                btn_niche.layer.shadowRadius = 10
                btn_niche.layer.shadowOpacity = 0.45
            } else {
                // 未选中：白色卡片背景 + 彩色文字
                btn_niche.setTitleColor(item_niche.color, for: .normal)
                btn_niche.backgroundColor = .white
                btn_niche.layer.shadowColor   = UIColor.black.withValues(alpha: 0.06).cgColor
                btn_niche.layer.shadowOffset  = CGSize(width: 0, height: 2)
                btn_niche.layer.shadowRadius  = 4
                btn_niche.layer.shadowOpacity = 1
            }
        }
    }

    // MARK: - 数据

    private func setupObservers_Niche() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Niche),
            name: TitleViewModel_Niche.titleStateDidChangeNotification_Niche,
            object: nil
        )
    }

    @objc private func handleDataChange_Niche() {
        loadAllData_Niche()
    }

    private func loadAllData_Niche() {
        _allPosts_niche = TitleViewModel_Niche.shared_Niche.getPosts_Niche()
        applyFilter_Niche()
    }

    private func applyFilter_Niche() {
        let item_niche = _categories_niche[_selectedCategory_niche]

        switch _selectedCategory_niche {
        case 0:
            _posts_niche = _allPosts_niche
        case 1:
            _posts_niche = _allPosts_niche.sorted { $0.likes_Niche > $1.likes_Niche }
        default:
            if item_niche.keywords.isEmpty {
                _posts_niche = _allPosts_niche
            } else {
                let filtered_niche = _allPosts_niche.filter { post_niche in
                    let combined_niche = (post_niche.title_Niche + " " + post_niche.titleContent_Niche).lowercased()
                    return item_niche.keywords.contains { combined_niche.contains($0) }
                }
                _posts_niche = filtered_niche.isEmpty ? _allPosts_niche : filtered_niche
            }
        }

        refreshCountPill_Niche()
        (_collectionView_niche.collectionViewLayout as? WaterfallLayout_Niche)?.invalidateLayout()
        _collectionView_niche.reloadData()
    }

    /// 更新计数胶囊（渐变背景 + 白色数字）
    private func refreshCountPill_Niche() {
        let count_niche = _posts_niche.count
        _countPill_niche.text = "  \(count_niche)  "
        _subtitleLabel_niche.text = "\(count_niche) stories in the tribe"

        _countPill_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let grad_niche = CAGradientLayer()
        grad_niche.cornerRadius = 9
        grad_niche.colors = [ColorConfig_Niche.primaryGradientStart_Niche.cgColor,
                             ColorConfig_Niche.primaryGradientEnd_Niche.cgColor]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint = CGPoint(x: 1, y: 0)
        grad_niche.frame = CGRect(x: 0, y: 0, width: 44, height: 18)
        _countPill_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    // MARK: - 事件

    @objc private func handleCategoryTap_Niche(_ sender: UIButton) {
        guard sender.tag != _selectedCategory_niche else { return }
        _selectedCategory_niche = sender.tag
        sender.animatePulse_Niche()
        refreshCategoryStyle_Niche()
        applyFilter_Niche()
        guard _posts_niche.count > 0 else { return }
        _collectionView_niche.scrollToItem(
            at: IndexPath(item: 0, section: 0),
            at: .top,
            animated: true
        )
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Niche: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _posts_niche.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_niche = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverCell_Niche.reuseId_Niche,
            for: indexPath
        ) as? DiscoverCell_Niche else {
            return UICollectionViewCell()
        }
        let post_niche   = _posts_niche[indexPath.item]
        let accent_niche = _accentPalette_niche[indexPath.item % _accentPalette_niche.count]
        cell_niche.configure_Niche(post: post_niche, accentColor: accent_niche, vc: self)
        cell_niche.onReportCompleted_Niche = { [weak self] in
            self?.loadAllData_Niche()
        }
        // 头像点击：导航到发布者的用户中心
        cell_niche.onAvatarTap_Niche = { [weak self] userId_niche in
            guard let self = self else { return }
            let user_niche = UserViewModel_Niche.shared_Niche.getUserById_Niche(userId_niche: userId_niche)
            Navigation_Niche.toUserInfo_Niche(with: user_niche)
        }
        return cell_niche
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Niche: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Niche.toTitleDetail_Niche(titleModel_niche: _posts_niche[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 弹性入场动画（从下方缩放淡入）
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 24).scaledBy(x: 0.94, y: 0.94)
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationSpring_Niche,
            delay: Double(indexPath.item % 3) * 0.06,
            usingSpringWithDamping: AnimationConfig_Niche.springDampingNormal_Niche,
            initialSpringVelocity: AnimationConfig_Niche.springVelocity_Niche,
            options: [.allowUserInteraction]
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}

// MARK: - WaterfallLayoutDelegate_Niche

extension Discover_Niche: WaterfallLayoutDelegate_Niche {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
        let post_niche = _posts_niche[indexPath.item]
        // 用帖子 ID + 行号产生 165~255 范围的不等高，形成真实瀑布感
        let seed_niche = abs(post_niche.titleId_Niche * 13 + indexPath.item * 11) % 90
        return CGFloat(165 + seed_niche)
    }
}

// MARK: - 发现页帖子卡片 Cell

/// 发现页帖子卡片单元格
/// 设计：全屏媒体 + 三段式渐变遮罩 + 玻璃拟态用户信息栏 + 热帖徽章 + 彩色阴影
/// 约束安全：所有子视图先 addSubview 后再设置跨视图约束，避免公共祖先崩溃
/// 按钮安全：使用 UIButton(type:.custom) + addTarget，避免 iOS 15 系统按钮崩溃
class DiscoverCell_Niche: UICollectionViewCell {

    static let reuseId_Niche = "DiscoverCell_Niche"

    var onReportCompleted_Niche: (() -> Void)?
    /// 头像点击回调，传出发布者用户 ID，由 VC 负责导航到用户中心
    var onAvatarTap_Niche: ((Int) -> Void)?

    // MARK: - 私有状态

    private var _currentPost_niche: TitleModel_Niche?
    private weak var _hostVC_niche: UIViewController?

    // MARK: - 子视图

    /// 全屏媒体视图
    private let _mediaView_niche = MediaDisplayView_Niche()

    /// 底部渐变遮罩容器（透明 → 深色，3段）
    private let _overlay_niche: UIView = {
        let v_niche = UIView()
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    private var _overlayGrad_niche: CAGradientLayer?

    /// 顶部彩色晕光（accent 色，极低透明度，营造氛围感）
    private let _topAura_niche: UIView = {
        let v_niche = UIView()
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    private var _auraGrad_niche: CAGradientLayer?

    /// 帖子标题（白色粗体）
    private let _titleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        l_niche.textColor = .white
        l_niche.numberOfLines = 2
        l_niche.isUserInteractionEnabled = false
        // 添加文字阴影增强可读性
        l_niche.layer.shadowColor   = UIColor.black.cgColor
        l_niche.layer.shadowOffset  = CGSize(width: 0, height: 1)
        l_niche.layer.shadowOpacity = 0.5
        l_niche.layer.shadowRadius  = 3
        return l_niche
    }()

    /// 玻璃拟态用户信息行（UIVisualEffectView 毛玻璃胶囊，启用交互使头像可点击）
    private let _glassRow_niche: UIVisualEffectView = {
        let blur_niche = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let v_niche = UIVisualEffectView(effect: blur_niche)
        v_niche.layer.cornerRadius = 14
        v_niche.layer.masksToBounds = true
        v_niche.isUserInteractionEnabled = true
        return v_niche
    }()

    private let _avatarView_niche = UserAvatarView_Niche()

    private let _userNameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.92)
        return l_niche
    }()

    private let _likeIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        iv_niche.image = UIImage(systemName: "heart.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = UIColor(hexstring_Niche: "#FF6B9D")
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    private let _likeCountLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.92)
        return l_niche
    }()

    /// 热帖徽章（点赞数 > 70 时显示）
    private let _hotBadge_niche: UIView = {
        let v_niche = UIView()
        v_niche.isHidden = true
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    private var _hotBadgeGrad_niche: CAGradientLayer?

    private let _hotBadgeLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "🔥 HOT"
        l_niche.font = UIFont.systemFont(ofSize: 9, weight: .heavy)
        l_niche.textColor = .white
        l_niche.isUserInteractionEnabled = false
        return l_niche
    }()

    /// 举报按钮（UIButton type .custom，避免 iOS 15 系统按钮崩溃）
    private let _reportBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_niche.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        btn_niche.backgroundColor = UIColor.black.withValues(alpha: 0.3)
        btn_niche.layer.cornerRadius = 15
        return btn_niche
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI_Niche()
        _reportBtn_niche.addTarget(self, action: #selector(handleReportTap_Niche), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 随 bounds 同步更新渐变图层尺寸
        _overlayGrad_niche?.frame = _overlay_niche.bounds
        _auraGrad_niche?.frame    = _topAura_niche.bounds
        _hotBadgeGrad_niche?.frame = _hotBadge_niche.bounds
    }

    // MARK: - UI 构建

    private func setupCellUI_Niche() {
        // 外层：彩色阴影，不裁切
        layer.cornerRadius  = 20
        layer.masksToBounds = false

        // contentView：圆角 + 裁切
        contentView.layer.cornerRadius  = 20
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(hexstring_Niche: "#0F0F1A")

        // ── 媒体（全屏铺满）──
        contentView.addSubview(_mediaView_niche)
        _mediaView_niche.layer.cornerRadius = 0
        _mediaView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // ── 顶部晕光（accent 色微弱渐变，后续在 configure 时更新颜色）──
        contentView.addSubview(_topAura_niche)
        _topAura_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        let auraGrad_niche = CAGradientLayer()
        auraGrad_niche.startPoint = CGPoint(x: 0.5, y: 0)
        auraGrad_niche.endPoint   = CGPoint(x: 0.5, y: 1)
        _topAura_niche.layer.insertSublayer(auraGrad_niche, at: 0)
        _auraGrad_niche = auraGrad_niche

        // ── 底部渐变遮罩（3 段，确保标题可读）──
        contentView.addSubview(_overlay_niche)
        _overlay_niche.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.68)
        }
        let overlayGrad_niche = CAGradientLayer()
        overlayGrad_niche.colors   = [UIColor.clear.cgColor,
                                       UIColor.black.withValues(alpha: 0.50).cgColor,
                                       UIColor.black.withValues(alpha: 0.85).cgColor]
        overlayGrad_niche.locations = [0, 0.45, 1.0]
        overlayGrad_niche.startPoint = CGPoint(x: 0.5, y: 0)
        overlayGrad_niche.endPoint   = CGPoint(x: 0.5, y: 1)
        _overlay_niche.layer.insertSublayer(overlayGrad_niche, at: 0)
        _overlayGrad_niche = overlayGrad_niche

        // ── 热帖徽章（左上角）──
        _hotBadge_niche.layer.cornerRadius = 9
        _hotBadge_niche.layer.masksToBounds = true
        contentView.addSubview(_hotBadge_niche)
        _hotBadge_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(9)
            make.height.equalTo(18)
        }

        let hotGrad_niche = CAGradientLayer()
        hotGrad_niche.colors     = [UIColor(hexstring_Niche: "#FF4444").cgColor,
                                     UIColor(hexstring_Niche: "#FF8C00").cgColor]
        hotGrad_niche.startPoint = CGPoint(x: 0, y: 0)
        hotGrad_niche.endPoint   = CGPoint(x: 1, y: 0)
        _hotBadge_niche.layer.insertSublayer(hotGrad_niche, at: 0)
        _hotBadgeGrad_niche = hotGrad_niche

        _hotBadge_niche.addSubview(_hotBadgeLabel_niche)
        _hotBadgeLabel_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
            make.centerY.equalToSuperview()
        }

        // ── 举报按钮（右上角）──
        contentView.addSubview(_reportBtn_niche)
        _reportBtn_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-9)
            make.width.equalTo(36)
            make.height.equalTo(30)
        }

        // ── 玻璃拟态用户行（贴底）──
        contentView.addSubview(_glassRow_niche)
        _glassRow_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-9)
            make.height.equalTo(32)
        }

        // 先全部 addSubview，再统一设置约束（避免跨层级约束崩溃）
        _glassRow_niche.contentView.addSubview(_avatarView_niche)
        _glassRow_niche.contentView.addSubview(_userNameLabel_niche)
        _glassRow_niche.contentView.addSubview(_likeCountLabel_niche)
        _glassRow_niche.contentView.addSubview(_likeIcon_niche)

        _avatarView_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        // 头像点击手势（点击后通过回调交由 VC 导航到用户中心）
        _avatarView_niche.isUserInteractionEnabled = true
        let avatarTap_niche = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Niche))
        _avatarView_niche.addGestureRecognizer(avatarTap_niche)

        _userNameLabel_niche.snp.makeConstraints { make in
            make.leading.equalTo(_avatarView_niche.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }

        _likeCountLabel_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }

        _likeIcon_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_likeCountLabel_niche.snp.leading).offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        // ── 帖子标题（玻璃行上方 7pt）──
        contentView.addSubview(_titleLabel_niche)
        _titleLabel_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-38)
            make.bottom.equalTo(_glassRow_niche.snp.top).offset(-7)
        }
    }

    // MARK: - 配置

    /// 配置卡片数据与风格
    /// - Parameters:
    ///   - post: 帖子模型
    ///   - accentColor: 当前卡片强调色（用于阴影 + 顶部晕光）
    ///   - vc: 宿主 VC
    func configure_Niche(post: TitleModel_Niche, accentColor: UIColor, vc: UIViewController) {
        _currentPost_niche = post
        _hostVC_niche      = vc

        // 媒体
        _mediaView_niche.configure_Niche(mediaPath_Niche: post.titleMeidas_Niche.first, isVideo_Niche: false)

        // 用户
        _avatarView_niche.configure_Niche(userId_Niche: post.titleUserId_Niche)
        _userNameLabel_niche.text  = "@\(post.titleUserName_Niche)"
        _likeCountLabel_niche.text = "\(post.likes_Niche)"
        _titleLabel_niche.text     = post.title_Niche

        // 顶部晕光（accent 色，极低不透明度）
        _auraGrad_niche?.colors = [accentColor.withValues(alpha: 0.18).cgColor,
                                    UIColor.clear.cgColor]

        // 彩色阴影
        layer.shadowColor   = accentColor.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 8)
        layer.shadowRadius  = 16
        layer.shadowOpacity = 0.30

        // 热帖徽章（点赞 > 70）
        let isHot_niche = post.likes_Niche > 70
        _hotBadge_niche.isHidden = !isHot_niche

        // 举报/删除按钮图标
        let isMine_niche   = UserViewModel_Niche.shared_Niche.isCurrentUser_Niche(userId_niche: post.titleUserId_Niche)
        let iconName_niche = isMine_niche ? "trash" : "ellipsis"
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        _reportBtn_niche.setImage(UIImage(systemName: iconName_niche, withConfiguration: cfg_niche), for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _currentPost_niche         = nil
        _hostVC_niche              = nil
        _titleLabel_niche.text     = nil
        _userNameLabel_niche.text  = nil
        _likeCountLabel_niche.text = nil
        _hotBadge_niche.isHidden   = true
    }

    // MARK: - 事件

    @objc private func handleAvatarTap_Niche() {
        guard let userId_niche = _currentPost_niche?.titleUserId_Niche else { return }
        onAvatarTap_Niche?(userId_niche)
    }

    @objc private func handleReportTap_Niche() {
        guard let post_niche = _currentPost_niche, let vc_niche = _hostVC_niche else { return }
        _reportBtn_niche.animatePulse_Niche()
        let isMine_niche = UserViewModel_Niche.shared_Niche.isCurrentUser_Niche(userId_niche: post_niche.titleUserId_Niche)
        if isMine_niche {
            ReportDeleteHelper_Niche.delete_Niche(post_Niche: post_niche, from: vc_niche) { [weak self] in
                self?.onReportCompleted_Niche?()
            }
        } else {
            ReportDeleteHelper_Niche.report_Niche(post_Niche: post_niche, from: vc_niche) { [weak self] in
                self?.onReportCompleted_Niche?()
            }
        }
    }
}

// MARK: - Array 安全下标扩展

private extension Array {
    /// 安全下标，越界返回 nil
    subscript(safe_niche index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
