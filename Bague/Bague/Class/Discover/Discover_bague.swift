import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 发现页

/// 发现页视图控制器
/// 功能：非规则双列瀑布流展示所有帖子，含发布者信息、举报/删除按钮、点击进入详情、搜索过滤
/// 设计：沉浸式三色渐变头部（无返回按钮）、右上角帖子计数徽章、实时搜索、丰富卡片视觉、调和配色体系
class Discover_Bague: UIViewController {

    // MARK: - UI 组件

    private let headerView_Bague = UIView()
    private var headerGrad_Bague: CAGradientLayer?

    /// 头部大标题
    private let headerTitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Discover"
        label.font = UIFont.systemFont(ofSize: 34, weight: .black)
        label.textColor = .white
        return label
    }()

    /// 头部副标题
    private let headerSubtitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Explore the bag universe"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        return label
    }()

    /// 帖子数量胶囊徽章（放在右上角，与标题同行，避免遮挡搜索栏）
    private let postsCountBadge_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 13
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v
    }()

    /// 帖子数量文字
    private let postsCountLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    /// 头部装饰：大闪光图标（右侧中央）
    private let headerDecorLarge_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = UIColor.white.withAlphaComponent(0.18)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 头部装饰：半透明大圆（右上角），增加层次感
    private let headerDecorCircle_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 头部装饰：小星形图标
    private let headerDecorStar_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.14)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 搜索栏外层容器
    private let searchBarContainer_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.38).cgColor
        return v
    }()

    /// 搜索图标
    private let searchIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv.image = UIImage(systemName: "magnifyingglass", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.8)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 搜索输入框（实际可输入，承担过滤逻辑）
    private let searchField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search bags, styles..."
        tf.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tf.textColor = .white
        tf.returnKeyType = .search
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        // 设置 placeholder 颜色为半透明白
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search bags, styles...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        // 设置清除按钮图标颜色为白色
        tf.tintColor = .white
        return tf
    }()

    /// 瀑布流 CollectionView
    private var collectionView_Bague: UICollectionView!
    private var waterfallLayout_Bague: DiscoverWaterfallLayout_Bague!

    // MARK: - 搜索空状态视图

    /// 搜索无结果时的空状态容器
    private let emptyStateView_Bague: UIView = {
        let v = UIView()
        v.isHidden = true
        v.alpha = 0
        return v
    }()

    /// 空状态插图图标
    private let emptyIconView_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 56, weight: .light)
        iv.image = UIImage(systemName: "magnifyingglass", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Bague.primaryGradientStart_Bague.withAlphaComponent(0.35)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 空状态主标题
    private let emptyTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "No Results Found"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        label.textAlignment = .center
        return label
    }()

    /// 空状态提示副文字（动态展示搜索词）
    private let emptySubLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // MARK: - 数据

    /// 全量帖子列表（原始数据）
    private var allPosts_Bague: [TitleModel_Bague] = []
    /// 当前展示的帖子列表（搜索过滤后）
    private var posts_Bague: [TitleModel_Bague] = []
    /// 当前搜索关键词
    private var searchKeyword_Bague: String = ""

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupBindings_Bague()
        loadData_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        // 头部区域（无返回按钮）
        view.addSubview(headerView_Bague)
        headerView_Bague.addSubview(headerDecorCircle_Bague)
        headerView_Bague.addSubview(headerDecorLarge_Bague)
        headerView_Bague.addSubview(headerDecorStar_Bague)
        headerView_Bague.addSubview(headerTitle_Bague)
        headerView_Bague.addSubview(headerSubtitle_Bague)
        headerView_Bague.addSubview(postsCountBadge_Bague)
        postsCountBadge_Bague.addSubview(postsCountLabel_Bague)
        headerView_Bague.addSubview(searchBarContainer_Bague)
        searchBarContainer_Bague.addSubview(searchIcon_Bague)
        searchBarContainer_Bague.addSubview(searchField_Bague)

        // 搜索框事件
        searchField_Bague.delegate = self
        searchField_Bague.addTarget(self, action: #selector(searchTextChanged_Bague), for: .editingChanged)

        // 点击空白区域收起键盘
        let tapGesture_bague = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Bague))
        tapGesture_bague.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture_bague)

        // 瀑布流初始化
        waterfallLayout_Bague = DiscoverWaterfallLayout_Bague()
        waterfallLayout_Bague.delegate_Bague = self

        collectionView_Bague = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout_Bague)
        collectionView_Bague.backgroundColor = .clear
        collectionView_Bague.showsVerticalScrollIndicator = false
        collectionView_Bague.contentInset = UIEdgeInsets(top: 16, left: 12, bottom: 100, right: 12)
        collectionView_Bague.keyboardDismissMode = .onDrag
        collectionView_Bague.dataSource = self
        collectionView_Bague.delegate = self
        collectionView_Bague.register(DiscoverCell_Bague.self, forCellWithReuseIdentifier: DiscoverCell_Bague.reuseId_Bague)
        view.addSubview(collectionView_Bague)

        // 空状态视图（叠加在 collectionView 上方）
        view.addSubview(emptyStateView_Bague)
        emptyStateView_Bague.addSubview(emptyIconView_Bague)
        emptyStateView_Bague.addSubview(emptyTitleLabel_Bague)
        emptyStateView_Bague.addSubview(emptySubLabel_Bague)
    }

    private func setupConstraints_Bague() {
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
        }
        // 右上角装饰圆（超出边界增加层次感）
        headerDecorCircle_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(-15)
            make.width.height.equalTo(100)
        }
        // 大闪光装饰，放在副标题右侧区域
        headerDecorLarge_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(66)
        }
        // 小星形装饰
        headerDecorStar_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-96)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.width.height.equalTo(20)
        }
        // 主标题（左侧）
        headerTitle_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        // 帖子计数徽章（右侧，与标题垂直居中对齐，不占用搜索栏空间）
        postsCountBadge_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(headerTitle_Bague)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(26)
        }
        postsCountLabel_Bague.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        // 副标题
        headerSubtitle_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerTitle_Bague.snp.bottom).offset(5)
            make.leading.equalTo(headerTitle_Bague)
            make.trailing.lessThanOrEqualTo(postsCountBadge_Bague.snp.leading).offset(-8)
        }
        // 搜索栏（独占一行，底部对齐）
        searchBarContainer_Bague.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        searchIcon_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        searchField_Bague.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Bague.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        // 瀑布流
        collectionView_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerView_Bague.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        // 空状态视图（与 collectionView 区域对齐，垂直居中偏上）
        emptyStateView_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerView_Bague.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyIconView_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(80)
        }
        emptyTitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        emptySubLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Bague.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }

    // MARK: - 渐变

    /// 更新头部三色斜角渐变：深紫 → 天空蓝 → 薄荷绿，底边圆角
    private func updateGradient_Bague() {
        headerGrad_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = headerView_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        grad_bague.locations = [0.0, 0.55, 1.0]
        grad_bague.startPoint = CGPoint(x: 0.0, y: 0.0)
        grad_bague.endPoint = CGPoint(x: 1.0, y: 1.0)
        grad_bague.cornerRadius = 28
        grad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(grad_bague, at: 0)
        headerGrad_Bague = grad_bague
    }

    // MARK: - 数据绑定

    private func setupBindings_Bague() {
        [TitleViewModel_Bague.titleStateDidChangeNotification_Bague,
         UserViewModel_Bague.userStateDidChangeNotification_Bague].forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(dataChanged_Bague),
                name: $0,
                object: nil
            )
        }
    }

    @objc private func dataChanged_Bague() { loadData_Bague() }

    /// 加载全量数据并根据当前关键词过滤
    private func loadData_Bague() {
        allPosts_Bague = TitleViewModel_Bague.shared_Bague.getPosts_Bague()
        postsCountLabel_Bague.text = "✦ \(allPosts_Bague.count)"
        applyFilter_Bague()
    }

    // MARK: - 搜索过滤

    /// 根据关键词过滤帖子并刷新列表，无结果时展示空状态视图
    /// - 匹配范围：帖子标题、内容、发布者名称
    private func applyFilter_Bague() {
        let trimmed_bague = searchKeyword_Bague.trimmingCharacters(in: .whitespaces)
        if trimmed_bague.isEmpty {
            posts_Bague = allPosts_Bague
        } else {
            let keyword_bague = trimmed_bague.lowercased()
            posts_Bague = allPosts_Bague.filter { post_bague in
                post_bague.title_Bague.lowercased().contains(keyword_bague)
                || post_bague.titleContent_Bague.lowercased().contains(keyword_bague)
                || post_bague.titleUserName_Bague.lowercased().contains(keyword_bague)
            }
        }
        waterfallLayout_Bague.invalidateLayout()
        collectionView_Bague.reloadData()
        updateEmptyState_Bague(keyword_bague: trimmed_bague)
    }

    /// 控制空状态视图的显示与隐藏（带淡入淡出动画）
    /// - Parameter keyword_bague: 当前搜索词，用于更新提示文案
    private func updateEmptyState_Bague(keyword_bague: String) {
        // 仅在有搜索词且结果为空时展示
        let shouldShow_bague = !keyword_bague.isEmpty && posts_Bague.isEmpty
        if shouldShow_bague {
            emptySubLabel_Bague.text = "No posts matching \"\(keyword_bague)\"\nTry a different keyword."
            emptyStateView_Bague.isHidden = false
            UIView.animate(withDuration: 0.28) {
                self.emptyStateView_Bague.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.emptyStateView_Bague.alpha = 0
            } completion: { _ in
                self.emptyStateView_Bague.isHidden = true
            }
        }
    }

    // MARK: - 事件处理

    /// 搜索框内容变化时实时过滤
    @objc private func searchTextChanged_Bague() {
        searchKeyword_Bague = searchField_Bague.text ?? ""
        applyFilter_Bague()
    }

    @objc private func dismissKeyboard_Bague() {
        view.endEditing(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Bague: UITextFieldDelegate {
    /// 点击键盘 Search 键收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension Discover_Bague: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts_Bague.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_bague = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverCell_Bague.reuseId_Bague,
            for: indexPath
        ) as! DiscoverCell_Bague
        let post_bague = posts_Bague[indexPath.item]
        // 传入原始索引以保持配色方案稳定
        let originalIndex_bague = allPosts_Bague.firstIndex(where: { $0.titleId_Bague == post_bague.titleId_Bague }) ?? indexPath.item
        cell_bague.configure_Bague(post_bague: post_bague, index_bague: originalIndex_bague, viewController_bague: self)
        return cell_bague
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_bague = posts_Bague[indexPath.item]
        Navigation_Bague.toTitleDetail_Bague(titleModel_bague: post_bague)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 24)
        UIView.animate(
            withDuration: 0.42,
            delay: Double(indexPath.item % 6) * 0.045,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut]
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Bague: DiscoverWaterfallLayoutDelegate_Bague {
    func collectionView_Bague(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let post_bague = posts_Bague[indexPath.item]
        // 根据内容长度产生不同高度（非规则布局关键）
        let baseHeight: CGFloat = 230
        let textBonus: CGFloat = CGFloat(min(post_bague.titleContent_Bague.count, 100)) * 0.3
        return baseHeight + textBonus
    }
}

// MARK: - 发现页 Cell

/// 发现页单元格
/// 功能：展示帖子封面图（含渐变遮罩）、作者信息、标题、内容摘要、点赞数
/// 设计：白色卡片、圆角、彩色调和渐变占位图（在 layoutSubviews 中刷新 frame）、彩色色条、柔和阴影
class DiscoverCell_Bague: UICollectionViewCell {

    static let reuseId_Bague = "DiscoverCell_Bague"

    // MARK: - 封面图区域

    private let mediaIV_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return iv
    }()

    /// 封面图底部渐变遮罩，提升文字可读性
    private let gradOverlay_Bague = UIView()
    private var overlayGrad_Bague: CAGradientLayer?

    /// 占位渐变图层（在 layoutSubviews 中更新 frame，解决初始 bounds 为零的问题）
    private var placeholderGrad_Bague: CAGradientLayer?

    // MARK: - 彩色顶部色条

    /// 顶部细色条，每张卡片使用不同调和色，增加活泼感
    private let accentBar_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    // MARK: - 作者行

    private let avatarView_Bague = UserAvatarView_Bague()

    private let authorLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        return label
    }()

    // MARK: - 内容区

    private let titleLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        label.numberOfLines = 2
        return label
    }()

    private let contentLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.numberOfLines = 3
        return label
    }()

    // MARK: - 点赞徽章

    private let likesChip_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        return v
    }()

    private let likesLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        return label
    }()

    private var actionBtn_Bague: UIButton?

    // MARK: - 配色缓存（用于 layoutSubviews 刷新占位渐变 frame）

    private var currentAccentIndex_Bague: Int = 0
    private var isShowingPlaceholder_Bague: Bool = false

    /// 调和配色方案：6 组渐变色，用于占位图背景和色条
    static let accentPalette_Bague: [(start: UIColor, end: UIColor)] = [
        (UIColor(hexstring_Bague: "#EDD9FF"), UIColor(hexstring_Bague: "#C4ABFF")), // 浅紫
        (UIColor(hexstring_Bague: "#D0EDFF"), UIColor(hexstring_Bague: "#A0D4F5")), // 浅蓝
        (UIColor(hexstring_Bague: "#FFD9EE"), UIColor(hexstring_Bague: "#FFB3D1")), // 浅粉
        (UIColor(hexstring_Bague: "#D4F7ED"), UIColor(hexstring_Bague: "#A0E8D4")), // 薄荷
        (UIColor(hexstring_Bague: "#FFF0D0"), UIColor(hexstring_Bague: "#FFD89A")), // 米橙
        (UIColor(hexstring_Bague: "#FFE4D9"), UIColor(hexstring_Bague: "#FFBCAA")), // 珊瑚
    ]

    static let accentTints_Bague: [UIColor] = [
        UIColor(hexstring_Bague: "#9B72F5"),
        UIColor(hexstring_Bague: "#5AADEC"),
        UIColor(hexstring_Bague: "#F07DAD"),
        UIColor(hexstring_Bague: "#3DC9A6"),
        UIColor(hexstring_Bague: "#F5A623"),
        UIColor(hexstring_Bague: "#F07060"),
    ]

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 更新封面图底部渐变遮罩
        overlayGrad_Bague?.removeFromSuperlayer()
        let overlay_bague = CAGradientLayer()
        overlay_bague.frame = gradOverlay_Bague.bounds
        overlay_bague.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.35).cgColor]
        overlay_bague.startPoint = CGPoint(x: 0, y: 0.4)
        overlay_bague.endPoint = CGPoint(x: 0, y: 1)
        gradOverlay_Bague.layer.insertSublayer(overlay_bague, at: 0)
        overlayGrad_Bague = overlay_bague

        // 占位渐变 frame 刷新（解决 configure 时 bounds 为零的核心问题）
        if isShowingPlaceholder_Bague {
            placeholderGrad_Bague?.frame = mediaIV_Bague.bounds
        }
    }

    private func buildUI_Bague() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 18
        contentView.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowOpacity = 0.13
        contentView.layer.shadowRadius = 12
        contentView.clipsToBounds = false

        contentView.addSubview(mediaIV_Bague)
        mediaIV_Bague.addSubview(gradOverlay_Bague)
        contentView.addSubview(accentBar_Bague)
        contentView.addSubview(avatarView_Bague)
        contentView.addSubview(authorLabel_Bague)
        contentView.addSubview(titleLabel_Bague)
        contentView.addSubview(contentLabel_Bague)
        contentView.addSubview(likesChip_Bague)
        likesChip_Bague.addSubview(likesLabel_Bague)

        mediaIV_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.52)
        }
        gradOverlay_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }

        accentBar_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaIV_Bague.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(28)
            make.height.equalTo(3)
        }
        avatarView_Bague.snp.makeConstraints { make in
            make.top.equalTo(accentBar_Bague.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        authorLabel_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Bague)
            make.leading.equalTo(avatarView_Bague.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-10)
        }
        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Bague.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        contentLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Bague.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        likesChip_Bague.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Bague.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        likesLabel_Bague.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
    }

    /// 配置单元格内容
    /// - Parameters:
    ///   - post_bague: 帖子数据模型
    ///   - index_bague: 原始序号，用于从调色盘取色（保持配色稳定）
    ///   - viewController_bague: 所属视图控制器（用于举报菜单弹出）
    func configure_Bague(post_bague: TitleModel_Bague, index_bague: Int, viewController_bague: UIViewController) {
        currentAccentIndex_Bague = index_bague % DiscoverCell_Bague.accentPalette_Bague.count
        let palette_bague = DiscoverCell_Bague.accentPalette_Bague[currentAccentIndex_Bague]
        let tint_bague = DiscoverCell_Bague.accentTints_Bague[currentAccentIndex_Bague]

        titleLabel_Bague.text = post_bague.title_Bague
        contentLabel_Bague.text = post_bague.titleContent_Bague
        authorLabel_Bague.text = post_bague.titleUserName_Bague
        avatarView_Bague.configure_Bague(userId_Bague: post_bague.titleUserId_Bague)

        // 色条与点赞徽章使用对应调和色
        accentBar_Bague.backgroundColor = tint_bague
        likesChip_Bague.backgroundColor = tint_bague.withAlphaComponent(0.12)
        likesLabel_Bague.textColor = tint_bague
        likesLabel_Bague.text = "♥ \(post_bague.likes_Bague)"

        // 封面图处理
        let media_bague = post_bague.titleMeidas_Bague.first ?? ""
        if let img_bague = UIImage(named: media_bague) {
            // 有真实图片：清除占位状态
            isShowingPlaceholder_Bague = false
            removePlaceholderGrad_Bague()
            mediaIV_Bague.image = img_bague
            mediaIV_Bague.contentMode = .scaleAspectFill
            mediaIV_Bague.backgroundColor = nil
        } else {
            // 无图片：使用渐变占位（frame 在 layoutSubviews 中会自动刷新）
            isShowingPlaceholder_Bague = true
            mediaIV_Bague.image = UIImage(systemName: "bag.fill")
            mediaIV_Bague.tintColor = tint_bague.withAlphaComponent(0.55)
            mediaIV_Bague.contentMode = .scaleAspectFit
            mediaIV_Bague.backgroundColor = palette_bague.start

            // 创建渐变图层并插入到最底层（bounds 为零时 layoutSubviews 会更新 frame）
            removePlaceholderGrad_Bague()
            let grad_bague = CAGradientLayer()
            grad_bague.frame = mediaIV_Bague.bounds
            grad_bague.colors = [palette_bague.start.cgColor, palette_bague.end.cgColor]
            grad_bague.startPoint = CGPoint(x: 0, y: 0)
            grad_bague.endPoint = CGPoint(x: 1, y: 1)
            mediaIV_Bague.layer.insertSublayer(grad_bague, at: 0)
            placeholderGrad_Bague = grad_bague
        }

        // 移除旧举报按钮
        actionBtn_Bague?.removeFromSuperview()

        // 新建举报/删除按钮（右上角）
        let btn_bague = ReportDeleteHelper_Bague.createPostReportButton_Bague(
            post_Bague: post_bague,
            size_Bague: 13,
            color_Bague: .white,
            from: viewController_bague
        )
        btn_bague.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        btn_bague.layer.cornerRadius = 12
        contentView.addSubview(btn_bague)
        btn_bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }
        actionBtn_Bague = btn_bague
    }

    /// 移除占位渐变图层
    private func removePlaceholderGrad_Bague() {
        placeholderGrad_Bague?.removeFromSuperlayer()
        placeholderGrad_Bague = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isShowingPlaceholder_Bague = false
        removePlaceholderGrad_Bague()
        mediaIV_Bague.image = nil
        mediaIV_Bague.backgroundColor = nil
    }
}

// MARK: - 瀑布流布局

/// 瀑布流布局委托协议
protocol DiscoverWaterfallLayoutDelegate_Bague: AnyObject {
    func collectionView_Bague(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
}

/// 自定义双列非规则瀑布流布局
class DiscoverWaterfallLayout_Bague: UICollectionViewLayout {

    weak var delegate_Bague: DiscoverWaterfallLayoutDelegate_Bague?

    private let numberOfColumns_Bague = 2
    private let cellPadding_Bague: CGFloat = 6

    private var cache_Bague: [UICollectionViewLayoutAttributes] = []
    private var contentHeight_Bague: CGFloat = 0

    private var contentWidth_Bague: CGFloat {
        guard let cv_bague = collectionView else { return 0 }
        let insets_bague = cv_bague.contentInset
        return cv_bague.bounds.width - insets_bague.left - insets_bague.right
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth_Bague, height: contentHeight_Bague)
    }

    override func prepare() {
        guard let cv_bague = collectionView, let delegate_bague = delegate_Bague else { return }

        cache_Bague.removeAll()
        contentHeight_Bague = 0

        let colW_bague = contentWidth_Bague / CGFloat(numberOfColumns_Bague)
        var xOffsets_bague = (0..<numberOfColumns_Bague).map { CGFloat($0) * colW_bague }
        var yOffsets_bague = [CGFloat](repeating: 0, count: numberOfColumns_Bague)

        var col_bague = 0
        for item_bague in 0..<cv_bague.numberOfItems(inSection: 0) {
            let indexPath_bague = IndexPath(item: item_bague, section: 0)

            let cellH_bague = delegate_bague.collectionView_Bague(cv_bague, heightForItemAt: indexPath_bague)
            let totalH_bague = cellPadding_Bague * 2 + cellH_bague

            let frame_bague = CGRect(
                x: xOffsets_bague[col_bague] + cellPadding_Bague,
                y: yOffsets_bague[col_bague] + cellPadding_Bague,
                width: colW_bague - cellPadding_Bague * 2,
                height: cellH_bague
            )

            let attrs_bague = UICollectionViewLayoutAttributes(forCellWith: indexPath_bague)
            attrs_bague.frame = frame_bague
            cache_Bague.append(attrs_bague)

            contentHeight_Bague = max(contentHeight_Bague, frame_bague.maxY)
            yOffsets_bague[col_bague] += totalH_bague

            // 选择高度最小的列放置下一个 cell
            col_bague = yOffsets_bague.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache_Bague.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cache_Bague.count else { return nil }
        return cache_Bague[indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv_bague = collectionView else { return false }
        return newBounds.width != cv_bague.bounds.width
    }
}
