import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页帖子排序枚举
/// - all_hush: 默认顺序
/// - popular_hush: 按点赞数降序
/// - recent_hush: 按帖子 ID 降序（最新）
enum DiscoverSortMode_Hush {
    case all_hush
    case popular_hush
    case recent_hush
}

/// 发现页面
/// 功能：以非规则瀑布流（两列）展示所有帖子，支持关键词搜索与排序筛选
/// 设计：富有编辑感的大标题区 + 多态搜索框 + 排序标签行 + 瀑布流集合视图
/// 关键属性：_filteredPosts_Hush（当前展示列表）、_sortMode_Hush（当前排序方式）
class Discover_Hush: UIViewController {

    // MARK: - 数据属性

    private var _allPosts_Hush: [TitleModel_Hush] = []
    private var _filteredPosts_Hush: [TitleModel_Hush] = []
    private var _searchKeyword_Hush: String = ""
    private var _sortMode_Hush: DiscoverSortMode_Hush = .all_hush

    // MARK: - 标题区组件

    /// 光圈装饰容器（带渐变环 + 半透明图标）
    private let _apertureContainer_Hush = UIView()

    /// 光圈图标
    private let _apertureIcon_Hush = UIImageView()

    /// 光圈渐变环图层
    private var _apertureRingGradient_Hush: CAGradientLayer?

    /// 页面大标题
    private let _titleLabel_Hush = UILabel()

    /// 副标题（富文本）
    private let _subtitleLabel_Hush = UILabel()

    /// 标题区底部渐变分割线
    private let _headerDivider_Hush = UIView()
    private var _headerDividerGradient_Hush: CAGradientLayer?

    // MARK: - 搜索框组件

    /// 搜索框外层容器
    private let _searchContainer_Hush = UIView()

    /// 搜索框渐变边框（获焦时激活）
    private var _searchBorderGradient_Hush: CAGradientLayer?

    /// 搜索图标
    private let _searchIcon_Hush = UIImageView()

    /// 搜索文本框
    private let _searchField_Hush = UITextField()

    /// 清空按钮
    private let _clearSearchBtn_Hush = UIButton(type: .system)

    /// 排序活跃指示点（非默认排序时亮起）
    private let _sortIndicatorDot_Hush = UIView()

    // MARK: - 排序标签组件

    private let _pillsScrollView_Hush = UIScrollView()
    private let _pillsStack_Hush = UIStackView()
    private var _pillButtons_Hush: [UIButton] = []
    private let _pillTitles_Hush = ["All", "Popular", "New"]

    // MARK: - 集合视图与空状态

    private var _collectionView_Hush: UICollectionView!
    private let _emptyView_Hush = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI_Hush()
        _setupNotifications_Hush()
        _loadData_Hush()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 渐变层需在布局完成后同步尺寸
        _headerDividerGradient_Hush?.frame = _headerDivider_Hush.bounds
        _searchBorderGradient_Hush?.frame = _searchContainer_Hush.bounds
        _apertureRingGradient_Hush?.frame = _apertureContainer_Hush.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func _setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        _setupHeader_Hush()
        _setupSearchBar_Hush()
        _setupSortPills_Hush()
        _setupCollectionView_Hush()
        _setupEmptyView_Hush()
        _setupConstraints_Hush()
    }

    // MARK: 标题区域搭建

    /// 搭建富有层次感的顶部标题区域
    /// 包含：渐变环光圈装饰容器、大标题、富文本副标题、渐变分割线
    private func _setupHeader_Hush() {
        // 光圈装饰容器（72×72，带渐变圆环 + 内圆镂空 + 半透明图标）
        view.addSubview(_apertureContainer_Hush)

        // 渐变圆环背景（橙→红，对角渐变）
        let ringGrad_Hush = CAGradientLayer()
        ringGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.55).cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.withAlphaComponent(0.55).cgColor
        ]
        ringGrad_Hush.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Hush.endPoint = CGPoint(x: 1, y: 1)
        ringGrad_Hush.cornerRadius = 36
        _apertureContainer_Hush.layer.addSublayer(ringGrad_Hush)
        _apertureRingGradient_Hush = ringGrad_Hush

        // 内圆（背景同色，制造镂空环形视觉）
        let innerCircle_Hush = UIView()
        innerCircle_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        innerCircle_Hush.layer.cornerRadius = 28
        _apertureContainer_Hush.addSubview(innerCircle_Hush)
        innerCircle_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }

        // 光圈图标（居中，主色40%透明）
        let apertureConfig_Hush = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        _apertureIcon_Hush.image = UIImage(systemName: "camera.aperture", withConfiguration: apertureConfig_Hush)
        _apertureIcon_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.7)
        _apertureIcon_Hush.contentMode = .scaleAspectFit
        _apertureContainer_Hush.addSubview(_apertureIcon_Hush)
        _apertureIcon_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(34)
        }

        // 大标题
        _titleLabel_Hush.text = "Discover"
        _titleLabel_Hush.font = .systemFont(ofSize: 36, weight: .black)
        _titleLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        view.addSubview(_titleLabel_Hush)

        // 副标题（带橙色竖线前缀 + 灰色文字）
        let attrs_Hush = NSMutableAttributedString()
        attrs_Hush.append(NSAttributedString(
            string: "▌ ",
            attributes: [
                .foregroundColor: ColorConfig_Hush.primaryGradientStart_Hush,
                .font: UIFont.systemFont(ofSize: 12, weight: .black)
            ]
        ))
        attrs_Hush.append(NSAttributedString(
            string: "Street stories, unposed.",
            attributes: [
                .foregroundColor: ColorConfig_Hush.textSecondary_Hush,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .kern: 0.3
            ]
        ))
        _subtitleLabel_Hush.attributedText = attrs_Hush
        view.addSubview(_subtitleLabel_Hush)

        // 渐变分割线（橙→红→透明，水平渐隐）
        view.addSubview(_headerDivider_Hush)
        let divGrad_Hush = CAGradientLayer()
        divGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
            UIColor.clear.cgColor
        ]
        divGrad_Hush.locations = [0, 0.5, 1]
        divGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        divGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        _headerDivider_Hush.layer.addSublayer(divGrad_Hush)
        _headerDividerGradient_Hush = divGrad_Hush
    }

    // MARK: 搜索框搭建

    /// 搭建搜索框
    /// 设计：默认细边框白底，获焦时渐变边框高亮 + 图标变色
    private func _setupSearchBar_Hush() {
        _searchContainer_Hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        _searchContainer_Hush.layer.cornerRadius = 16
        _searchContainer_Hush.layer.masksToBounds = false
        _searchContainer_Hush.layer.shadowColor = UIColor.black.cgColor
        _searchContainer_Hush.layer.shadowOffset = CGSize(width: 0, height: 3)
        _searchContainer_Hush.layer.shadowOpacity = 0.07
        _searchContainer_Hush.layer.shadowRadius = 10
        view.addSubview(_searchContainer_Hush)

        // 默认细灰边框（sublayer，便于后续渐变切换）
        let borderLayer_Hush = CALayer()
        borderLayer_Hush.borderColor = ColorConfig_Hush.border_Hush.cgColor
        borderLayer_Hush.borderWidth = 1
        borderLayer_Hush.cornerRadius = 16
        borderLayer_Hush.name = "borderLayer"
        _searchContainer_Hush.layer.addSublayer(borderLayer_Hush)
        DispatchQueue.main.async {
            borderLayer_Hush.frame = self._searchContainer_Hush.bounds
        }

        // 搜索图标
        let searchConfig_Hush = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        _searchIcon_Hush.image = UIImage(systemName: "magnifyingglass", withConfiguration: searchConfig_Hush)
        _searchIcon_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        _searchIcon_Hush.contentMode = .scaleAspectFit
        _searchContainer_Hush.addSubview(_searchIcon_Hush)

        // 搜索文本框
        _searchField_Hush.placeholder = "Search shots, stories..."
        _searchField_Hush.font = .systemFont(ofSize: 14, weight: .regular)
        _searchField_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _searchField_Hush.backgroundColor = .clear
        _searchField_Hush.returnKeyType = .search
        _searchField_Hush.clearButtonMode = .never
        _searchField_Hush.delegate = self
        _searchField_Hush.addTarget(self, action: #selector(_searchTextChanged_Hush(_:)), for: .editingChanged)
        _searchContainer_Hush.addSubview(_searchField_Hush)

        // 清空按钮
        let clearConfig_Hush = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        _clearSearchBtn_Hush.setImage(
            UIImage(systemName: "xmark.circle.fill", withConfiguration: clearConfig_Hush),
            for: .normal
        )
        _clearSearchBtn_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        _clearSearchBtn_Hush.isHidden = true
        _clearSearchBtn_Hush.addTarget(self, action: #selector(_clearSearch_Hush), for: .touchUpInside)
        _searchContainer_Hush.addSubview(_clearSearchBtn_Hush)

        // 排序活跃指示点（非默认排序时显示橙色小点）
        _sortIndicatorDot_Hush.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush
        _sortIndicatorDot_Hush.layer.cornerRadius = 4
        _sortIndicatorDot_Hush.isHidden = true
        _searchContainer_Hush.addSubview(_sortIndicatorDot_Hush)
    }

    // MARK: 排序标签搭建

    /// 搭建排序标签横向滚动行
    private func _setupSortPills_Hush() {
        _pillsScrollView_Hush.showsHorizontalScrollIndicator = false
        _pillsScrollView_Hush.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(_pillsScrollView_Hush)

        _pillsStack_Hush.axis = .horizontal
        _pillsStack_Hush.spacing = 8
        _pillsStack_Hush.alignment = .center
        _pillsScrollView_Hush.addSubview(_pillsStack_Hush)
        _pillsStack_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 排序图标标签（All 前加相机图标）
        let pillIcons_Hush = ["", "flame", "sparkles"]
        for (index_hush, title_hush) in _pillTitles_Hush.enumerated() {
            let btn_hush = UIButton()
            var config = UIButton.Configuration.plain()
            config.title = title_hush
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
                return outgoing
            }
            let iconName = pillIcons_Hush[index_hush]
            if !iconName.isEmpty {
                config.image = UIImage(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
                config.imagePadding = 5
                config.imagePlacement = .leading
            }
            config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16)
            btn_hush.configuration = config
            btn_hush.layer.cornerRadius = 16
            btn_hush.tag = index_hush
            btn_hush.addTarget(self, action: #selector(_pillTapped_Hush(_:)), for: .touchUpInside)
            _pillsStack_Hush.addArrangedSubview(btn_hush)
            _pillButtons_Hush.append(btn_hush)
        }
        _updatePillAppearance_Hush()
    }

    /// 更新排序标签选中外观
    private func _updatePillAppearance_Hush() {
        let activeIndex_hush: Int
        switch _sortMode_Hush {
        case .all_hush:     activeIndex_hush = 0
        case .popular_hush: activeIndex_hush = 1
        case .recent_hush:  activeIndex_hush = 2
        }
        for (index_hush, btn_hush) in _pillButtons_Hush.enumerated() {
            var config = btn_hush.configuration ?? UIButton.Configuration.plain()
            if index_hush == activeIndex_hush {
                config.baseForegroundColor = .white
                btn_hush.configuration = config
                btn_hush.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush
                btn_hush.layer.borderWidth = 0
                btn_hush.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
                btn_hush.layer.shadowOffset = CGSize(width: 0, height: 3)
                btn_hush.layer.shadowOpacity = 0.35
                btn_hush.layer.shadowRadius = 6
            } else {
                config.baseForegroundColor = ColorConfig_Hush.textSecondary_Hush
                btn_hush.configuration = config
                btn_hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
                btn_hush.layer.borderWidth = 1
                btn_hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
                btn_hush.layer.shadowOpacity = 0
            }
        }
        // 排序指示点：非默认排序时亮起
        _sortIndicatorDot_Hush.isHidden = (_sortMode_Hush == .all_hush)
    }

    // MARK: 集合视图搭建

    private func _setupCollectionView_Hush() {
        let layout_Hush = WaterfallLayout_Hush()
        layout_Hush.delegate_Hush = self
        layout_Hush.numberOfColumns_Hush = 2
        layout_Hush.cellPadding_Hush = 7

        _collectionView_Hush = UICollectionView(frame: .zero, collectionViewLayout: layout_Hush)
        _collectionView_Hush.backgroundColor = .clear
        _collectionView_Hush.showsVerticalScrollIndicator = false
        _collectionView_Hush.alwaysBounceVertical = true
        // 底部留出 100pt 避免内容被浮动底栏遮挡
        _collectionView_Hush.contentInset = UIEdgeInsets(top: 8, left: 12, bottom: 100, right: 12)
        _collectionView_Hush.keyboardDismissMode = .onDrag
        _collectionView_Hush.dataSource = self
        _collectionView_Hush.delegate = self
        _collectionView_Hush.register(
            DiscoverPostCell_Hush.self,
            forCellWithReuseIdentifier: DiscoverPostCell_Hush.reuseId_Hush
        )
        view.addSubview(_collectionView_Hush)
    }

    // MARK: 空状态搭建

    private func _setupEmptyView_Hush() {
        _emptyView_Hush.isHidden = true
        view.addSubview(_emptyView_Hush)

        let iconConfig_Hush = UIImage.SymbolConfiguration(pointSize: 48, weight: .thin)
        let emptyIcon_Hush = UIImageView(
            image: UIImage(systemName: "camera.aperture", withConfiguration: iconConfig_Hush)
        )
        emptyIcon_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        emptyIcon_Hush.contentMode = .scaleAspectFit
        _emptyView_Hush.addSubview(emptyIcon_Hush)

        let emptyTitle_Hush = UILabel()
        emptyTitle_Hush.text = "No shots found"
        emptyTitle_Hush.font = .systemFont(ofSize: 16, weight: .semibold)
        emptyTitle_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        emptyTitle_Hush.textAlignment = .center
        _emptyView_Hush.addSubview(emptyTitle_Hush)

        let emptyHint_Hush = UILabel()
        emptyHint_Hush.text = "Try different keywords or filters"
        emptyHint_Hush.font = .systemFont(ofSize: 13)
        emptyHint_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        emptyHint_Hush.textAlignment = .center
        _emptyView_Hush.addSubview(emptyHint_Hush)

        emptyIcon_Hush.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(66)
        }
        emptyTitle_Hush.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Hush.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        emptyHint_Hush.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle_Hush.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: 约束

    private func _setupConstraints_Hush() {
        _apertureContainer_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(_titleLabel_Hush)
            make.width.height.equalTo(72)
        }
        _titleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualTo(_apertureIcon_Hush.snp.leading).offset(-8)
        }
        _subtitleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_titleLabel_Hush.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(20)
        }
        _headerDivider_Hush.snp.makeConstraints { make in
            make.top.equalTo(_subtitleLabel_Hush.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.55)
            make.height.equalTo(1.5)
        }
        _searchContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(_headerDivider_Hush.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        _searchIcon_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        _clearSearchBtn_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        _sortIndicatorDot_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(8)
        }
        _searchField_Hush.snp.makeConstraints { make in
            make.leading.equalTo(_searchIcon_Hush.snp.trailing).offset(8)
            make.trailing.equalTo(_clearSearchBtn_Hush.snp.leading).offset(-4)
            make.centerY.equalToSuperview()
        }
        _pillsScrollView_Hush.snp.makeConstraints { make in
            make.top.equalTo(_searchContainer_Hush.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        _collectionView_Hush.snp.makeConstraints { make in
            make.top.equalTo(_pillsScrollView_Hush.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        _emptyView_Hush.snp.makeConstraints { make in
            make.center.equalTo(_collectionView_Hush)
            make.width.equalTo(220)
        }
    }

    // MARK: - 通知监听

    private func _setupNotifications_Hush() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_dataDidChange_Hush),
            name: TitleViewModel_Hush.titleStateDidChangeNotification_Hush,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_dataDidChange_Hush),
            name: UserViewModel_Hush.userStateDidChangeNotification_Hush,
            object: nil
        )
    }

    // MARK: - 数据处理

    private func _loadData_Hush() {
        _allPosts_Hush = TitleViewModel_Hush.shared_Hush.getPosts_Hush()
        _applyFilter_Hush()
    }

    /// 综合应用关键词过滤与排序，刷新集合视图
    private func _applyFilter_Hush() {
        var result_hush = _allPosts_Hush

        if !_searchKeyword_Hush.isEmpty {
            let kw_hush = _searchKeyword_Hush.lowercased()
            result_hush = result_hush.filter {
                $0.title_Hush.lowercased().contains(kw_hush) ||
                $0.titleContent_Hush.lowercased().contains(kw_hush)
            }
        }

        switch _sortMode_Hush {
        case .all_hush:     break
        case .popular_hush: result_hush.sort { $0.likes_Hush > $1.likes_Hush }
        case .recent_hush:  result_hush.sort { $0.titleId_Hush > $1.titleId_Hush }
        }

        _filteredPosts_Hush = result_hush

        if let layout_hush = _collectionView_Hush.collectionViewLayout as? WaterfallLayout_Hush {
            layout_hush.invalidateLayout()
        }
        _collectionView_Hush.reloadData()

        _emptyView_Hush.isHidden = !_filteredPosts_Hush.isEmpty
        _collectionView_Hush.isHidden = _filteredPosts_Hush.isEmpty
    }

    // MARK: - 事件处理

    @objc private func _searchTextChanged_Hush(_ textField: UITextField) {
        _searchKeyword_Hush = textField.text ?? ""
        _clearSearchBtn_Hush.isHidden = _searchKeyword_Hush.isEmpty
        _applyFilter_Hush()
    }

    @objc private func _clearSearch_Hush() {
        _searchField_Hush.text = nil
        _searchKeyword_Hush = ""
        _clearSearchBtn_Hush.isHidden = true
        _searchField_Hush.resignFirstResponder()
        _applyFilter_Hush()
    }

    /// 排序标签点击，切换排序方式并刷新
    @objc private func _pillTapped_Hush(_ sender: UIButton) {
        switch sender.tag {
        case 1:  _sortMode_Hush = .popular_hush
        case 2:  _sortMode_Hush = .recent_hush
        default: _sortMode_Hush = .all_hush
        }
        _updatePillAppearance_Hush()
        _applyFilter_Hush()

        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.91, y: 0.91)
        }) { _ in
            UIView.animate(withDuration: 0.14, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6) {
                sender.transform = .identity
            }
        }
    }

    @objc private func _dataDidChange_Hush() {
        _loadData_Hush()
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Hush: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _filteredPosts_Hush.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Hush = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverPostCell_Hush.reuseId_Hush,
            for: indexPath
        ) as! DiscoverPostCell_Hush

        let post_Hush = _filteredPosts_Hush[indexPath.item]
        cell_Hush.configure_Hush(post_Hush: post_Hush, viewController_Hush: self)
        cell_Hush.onUserTapped_Hush = { [weak self] userId_Hush in
            guard let self = self else { return }
            let user_Hush = UserViewModel_Hush.shared_Hush.getUserById_Hush(userId_hush: userId_Hush)
            Navigation_Hush.toUserInfo_Hush(
                with: user_Hush,
                fromChat_hush: false,
                style_hush: .push_hush,
                animated_hush: true
            )
        }
        return cell_Hush
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Hush: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Hush = _filteredPosts_Hush[indexPath.item]
        Navigation_Hush.toTitleDetail_Hush(titleModel_hush: post_Hush, style_hush: .push_hush, animated_hush: true)
    }
}

// MARK: - WaterfallLayoutDelegate_Hush

extension Discover_Hush: WaterfallLayoutDelegate_Hush {

    /// 根据帖子内容长度动态计算卡片高度（基础 275，最大 335）
    /// 底部信息栏固定 30px，媒体区 58%，内容区须容纳标题 + 摘要 + 底部栏
    func collectionView_Hush(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let post_Hush = _filteredPosts_Hush[indexPath.item]
        let extra_hush = min(CGFloat(post_Hush.titleContent_Hush.count) / 10.0, 60)
        return 275 + extra_hush
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Hush: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /// 获焦：搜索框边框变为橙红主色，图标同步变色
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.22) {
            self._searchContainer_Hush.layer.sublayers?
                .first(where: { $0.name == "borderLayer" })?
                .borderColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        }
        _searchIcon_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
        UIView.animate(withDuration: 0.18) {
            self._searchContainer_Hush.layer.shadowOpacity = 0.12
            self._searchContainer_Hush.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        }
    }

    /// 失焦：恢复搜索框默认外观
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.22) {
            self._searchContainer_Hush.layer.sublayers?
                .first(where: { $0.name == "borderLayer" })?
                .borderColor = ColorConfig_Hush.border_Hush.cgColor
        }
        _searchIcon_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        UIView.animate(withDuration: 0.18) {
            self._searchContainer_Hush.layer.shadowOpacity = 0.07
            self._searchContainer_Hush.layer.shadowColor = UIColor.black.cgColor
        }
    }
}

// MARK: - 瀑布流布局代理协议

/// 瀑布流布局代理协议
/// 功能：为 WaterfallLayout_Hush 提供每个 item 的动态高度
protocol WaterfallLayoutDelegate_Hush: AnyObject {
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - indexPath: 目标位置
    /// - Returns: cell 高度（CGFloat）
    func collectionView_Hush(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
}

// MARK: - 自定义瀑布流布局

/// 自定义两列非规则瀑布流布局
/// 功能：将 cell 依次放入当前最矮的列，实现真正的参差瀑布效果
class WaterfallLayout_Hush: UICollectionViewLayout {

    var numberOfColumns_Hush: Int = 2
    var cellPadding_Hush: CGFloat = 7
    weak var delegate_Hush: WaterfallLayoutDelegate_Hush?

    private var _cache_Hush: [UICollectionViewLayoutAttributes] = []
    private var _contentHeight_Hush: CGFloat = 0
    private var _contentWidth_Hush: CGFloat {
        guard let cv = collectionView else { return 0 }
        let insets = cv.contentInset
        return cv.bounds.width - insets.left - insets.right
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: _contentWidth_Hush, height: _contentHeight_Hush)
    }

    override func prepare() {
        guard _cache_Hush.isEmpty, let cv = collectionView else { return }

        var colHeights_Hush = Array(repeating: CGFloat(0), count: numberOfColumns_Hush)
        let colWidth_Hush = (_contentWidth_Hush - CGFloat(numberOfColumns_Hush - 1) * cellPadding_Hush) / CGFloat(numberOfColumns_Hush)

        for item_Hush in 0..<cv.numberOfItems(inSection: 0) {
            let indexPath_Hush = IndexPath(item: item_Hush, section: 0)
            let minCol_Hush = colHeights_Hush.indices.min(by: { colHeights_Hush[$0] < colHeights_Hush[$1] }) ?? 0
            let xOffset_Hush = CGFloat(minCol_Hush) * (colWidth_Hush + cellPadding_Hush)
            let yOffset_Hush = colHeights_Hush[minCol_Hush]
            let itemH_Hush = delegate_Hush?.collectionView_Hush(cv, heightForItemAt: indexPath_Hush) ?? 260

            let frame_Hush = CGRect(x: xOffset_Hush, y: yOffset_Hush, width: colWidth_Hush, height: itemH_Hush)
            let insetFrame_Hush = frame_Hush.insetBy(dx: cellPadding_Hush / 2, dy: cellPadding_Hush / 2)

            let attrs_Hush = UICollectionViewLayoutAttributes(forCellWith: indexPath_Hush)
            attrs_Hush.frame = insetFrame_Hush
            _cache_Hush.append(attrs_Hush)

            colHeights_Hush[minCol_Hush] = yOffset_Hush + itemH_Hush
        }
        _contentHeight_Hush = colHeights_Hush.max() ?? 0
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        _cache_Hush.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        _cache_Hush.first { $0.indexPath == indexPath }
    }

    override func invalidateLayout() {
        _cache_Hush.removeAll()
        _contentHeight_Hush = 0
        super.invalidateLayout()
    }
}

// MARK: - 发现页帖子卡片 Cell

/// 发现页帖子卡片 Cell
/// 功能：全出血媒体图 + 渐变作者信息浮层（含点赞数）+ 左侧渐变色条 + 标题 + 内容预览 + 举报按钮
/// 设计：外层提供阴影，内层 clipsToBounds 圆角裁剪；作者/点赞叠加于媒体上方，编辑风格左色条强调层次
class DiscoverPostCell_Hush: UICollectionViewCell {

    static let reuseId_Hush = "DiscoverPostCell_Hush"

    // MARK: - UI 组件

    /// 可裁剪的卡片内容容器（圆角 + clipsToBounds）
    private let _cardView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    /// 媒体展示区域（全出血，占卡片 58% 高度）
    private let _mediaView_Hush = MediaDisplayView_Hush()

    /// 媒体底部渐变浮层（作者 + 点赞）
    private let _authorOverlay_Hush = UIView()
    private var _overlayGradient_Hush: CAGradientLayer?

    /// 作者头像（浮层内）
    private let _avatarView_Hush = UserAvatarView_Hush()

    /// 作者昵称（浮层内）
    private let _userNameLabel_Hush = UILabel()

    /// 内容区左侧渐变色条（编辑风格强调线）
    private let _accentStrip_Hush = UIView()
    private var _accentStripGradient_Hush: CAGradientLayer?

    /// 帖子标题
    private let _titleLabel_Hush = UILabel()

    /// 帖子内容预览
    private let _contentLabel_Hush = UILabel()

    /// 卡片底部信息栏（评论数 + 点赞按钮 + 阅读箭头）
    private let _bottomBar_Hush = UIView()

    /// 评论图标（较大）
    private let _commentIcon_Hush = UIImageView()

    /// 评论数文字
    private let _commentCountLabel_Hush = UILabel()

    /// 点赞容器（可点击）
    private let _likeBtnContainer_Hush = UIView()

    /// 点赞图标（底部栏，较大）
    private let _likeIconInBar_Hush = UIImageView()

    /// 点赞数（底部栏）
    private let _likeCountInBar_Hush = UILabel()

    /// 阅读更多箭头
    private let _readArrow_Hush = UIImageView()

    /// 当前帖子数据（用于点赞操作）
    private var _currentPost_Hush: TitleModel_Hush?

    /// 举报/删除按钮（每次 configure 重建）
    private var _reportButton_Hush: UIButton?

    // MARK: - 外部回调与状态

    var onUserTapped_Hush: ((Int) -> Void)?
    private var _currentUserId_Hush: Int = 0

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI_Hush()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _overlayGradient_Hush?.frame = _authorOverlay_Hush.bounds
        _accentStripGradient_Hush?.frame = _accentStrip_Hush.bounds
        // 更新阴影路径（性能优化）
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    // MARK: - UI 搭建

    private func _setupUI_Hush() {
        // 外层阴影（不裁剪，确保阴影可见）
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.10
        layer.masksToBounds = false

        contentView.addSubview(_cardView_Hush)
        _cardView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 媒体区（顶部全出血，58% 高度）
        _cardView_Hush.addSubview(_mediaView_Hush)
        _mediaView_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.58)
        }

        // 作者信息渐变浮层（叠加在媒体底部，72px）
        _cardView_Hush.addSubview(_authorOverlay_Hush)
        _authorOverlay_Hush.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(_mediaView_Hush.snp.bottom)
            make.height.equalTo(72)
        }
        _authorOverlay_Hush.isUserInteractionEnabled = true
        _authorOverlay_Hush.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(_userTapped_Hush))
        )

        // 渐变层（透明→深炭）
        let grad_Hush = CAGradientLayer()
        grad_Hush.colors = [
            UIColor.clear.cgColor,
            UIColor(hexstring_Hush: "#1A1B25").withAlphaComponent(0.82).cgColor
        ]
        grad_Hush.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Hush.endPoint = CGPoint(x: 0.5, y: 1)
        _authorOverlay_Hush.layer.addSublayer(grad_Hush)
        _overlayGradient_Hush = grad_Hush

        // 头像（浮层左侧）
        _avatarView_Hush.layer.cornerRadius = 11
        _avatarView_Hush.clipsToBounds = true
        _avatarView_Hush.layer.borderWidth = 1.5
        _avatarView_Hush.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
        _avatarView_Hush.isUserInteractionEnabled = false
        _authorOverlay_Hush.addSubview(_avatarView_Hush)
        _avatarView_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(11)
            make.width.height.equalTo(22)
        }

        // 昵称（浮层内，头像右侧，可延伸至右边缘）
        _userNameLabel_Hush.font = .systemFont(ofSize: 11, weight: .semibold)
        _userNameLabel_Hush.textColor = .white
        _authorOverlay_Hush.addSubview(_userNameLabel_Hush)
        _userNameLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(_avatarView_Hush.snp.trailing).offset(7)
            make.centerY.equalTo(_avatarView_Hush)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
        }

        // 左侧渐变色条（编辑感强调，3px 宽）
        _cardView_Hush.addSubview(_accentStrip_Hush)
        _accentStrip_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(_mediaView_Hush.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        let stripGrad_Hush = CAGradientLayer()
        stripGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        stripGrad_Hush.startPoint = CGPoint(x: 0.5, y: 0)
        stripGrad_Hush.endPoint = CGPoint(x: 0.5, y: 1)
        _accentStrip_Hush.layer.addSublayer(stripGrad_Hush)
        _accentStripGradient_Hush = stripGrad_Hush

        // 帖子标题（色条右侧）
        _titleLabel_Hush.font = .systemFont(ofSize: 13, weight: .bold)
        _titleLabel_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _titleLabel_Hush.numberOfLines = 2
        _cardView_Hush.addSubview(_titleLabel_Hush)
        _titleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_mediaView_Hush.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-12)
        }

        // 内容预览（撑满标题到底部信息栏之间的全部空间，多行展示更多内容）
        _contentLabel_Hush.font = .systemFont(ofSize: 11, weight: .regular)
        _contentLabel_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        _contentLabel_Hush.numberOfLines = 0
        _contentLabel_Hush.lineBreakMode = .byTruncatingTail
        _cardView_Hush.addSubview(_contentLabel_Hush)
        _contentLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_titleLabel_Hush.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-12)
            // 固定底部：紧贴底部信息栏上方（底部栏36 + 间距6 = 42），完全填充空间消除留白
            make.bottom.equalToSuperview().inset(42)
        }

        // 底部信息栏（始终占据卡片底部，填充空白，展示评论数与阅读箭头）
        _bottomBar_Hush.backgroundColor = UIColor(hexstring_Hush: "#F5F2EE")
        _cardView_Hush.addSubview(_bottomBar_Hush)
        _bottomBar_Hush.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(36)
        }

        // 评论气泡图标（加大至 17pt）
        let commentConfig_Hush = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
        _commentIcon_Hush.image = UIImage(systemName: "bubble.left.fill", withConfiguration: commentConfig_Hush)
        _commentIcon_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        _commentIcon_Hush.contentMode = .scaleAspectFit
        _bottomBar_Hush.addSubview(_commentIcon_Hush)
        _commentIcon_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        // 评论数
        _commentCountLabel_Hush.font = .systemFont(ofSize: 13, weight: .semibold)
        _commentCountLabel_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        _bottomBar_Hush.addSubview(_commentCountLabel_Hush)
        _commentCountLabel_Hush.snp.makeConstraints { make in
            make.leading.equalTo(_commentIcon_Hush.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }

        // 点赞容器（可点击，心形图标 + 点赞数）
        _bottomBar_Hush.addSubview(_likeBtnContainer_Hush)
        _likeBtnContainer_Hush.isUserInteractionEnabled = true
        _likeBtnContainer_Hush.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(_handleLikeTapped_Hush))
        )
        _likeBtnContainer_Hush.snp.makeConstraints { make in
            make.leading.equalTo(_commentCountLabel_Hush.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 点赞心形图标（加大至 17pt）
        let heartConfig_Hush = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
        _likeIconInBar_Hush.image = UIImage(systemName: "heart.fill", withConfiguration: heartConfig_Hush)
        _likeIconInBar_Hush.contentMode = .scaleAspectFit
        _likeBtnContainer_Hush.addSubview(_likeIconInBar_Hush)
        _likeIconInBar_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        // 点赞数
        _likeCountInBar_Hush.font = .systemFont(ofSize: 13, weight: .semibold)
        _likeBtnContainer_Hush.addSubview(_likeCountInBar_Hush)
        _likeCountInBar_Hush.snp.makeConstraints { make in
            make.leading.equalTo(_likeIconInBar_Hush.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        // 阅读箭头（右侧，主色调，12pt）
        let arrowConfig_Hush = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        _readArrow_Hush.image = UIImage(systemName: "arrow.right", withConfiguration: arrowConfig_Hush)
        _readArrow_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.6)
        _readArrow_Hush.contentMode = .scaleAspectFit
        _bottomBar_Hush.addSubview(_readArrow_Hush)
        _readArrow_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
    }

    // MARK: - 数据配置

    /// 配置 Cell 数据
    /// - Parameters:
    ///   - post_Hush: 帖子数据模型
    ///   - viewController_Hush: 当前视图控制器（举报/删除弹窗的定位锚点）
    func configure_Hush(post_Hush: TitleModel_Hush, viewController_Hush: UIViewController) {
        _currentUserId_Hush = post_Hush.titleUserId_Hush

        let firstMedia_hush = post_Hush.titleMeidas_Hush.first
        let isVideo_hush = firstMedia_hush?.lowercased().hasSuffix(".mp4") == true
                        || firstMedia_hush?.lowercased().hasSuffix(".mov") == true
        _mediaView_Hush.configure_Hush(mediaPath_Hush: firstMedia_hush, isVideo_Hush: isVideo_hush)

        _currentPost_Hush = post_Hush

        _avatarView_Hush.configure_Hush(userId_Hush: post_Hush.titleUserId_Hush)
        _userNameLabel_Hush.text = post_Hush.titleUserName_Hush
        _titleLabel_Hush.text = post_Hush.title_Hush
        _contentLabel_Hush.text = post_Hush.titleContent_Hush
        _commentCountLabel_Hush.text = "\(post_Hush.reviews_Hush.count)"
        _likeCountInBar_Hush.text = "\(post_Hush.likes_Hush)"

        // 根据当前用户是否已点赞，更新心形图标颜色
        _updateLikeAppearance_Hush(isLiked_hush: TitleViewModel_Hush.shared_Hush.isLikedPost_Hush(post_hush: post_Hush))

        // 举报/删除按钮（定位在媒体右上角，每次重建确保数据最新）
        _reportButton_Hush?.removeFromSuperview()
        let reportBtn_Hush = ReportDeleteHelper_Hush.createPostReportButton_Hush(
            post_Hush: post_Hush,
            size_Hush: 17,
            color_Hush: UIColor.white.withAlphaComponent(0.95),
            from: viewController_Hush
        )
        _cardView_Hush.addSubview(reportBtn_Hush)
        reportBtn_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        _reportButton_Hush = reportBtn_Hush
    }

    // MARK: - 事件处理

    @objc private func _userTapped_Hush() {
        onUserTapped_Hush?(_currentUserId_Hush)
    }

    /// 点赞按钮点击处理
    /// 功能：调用 TitleViewModel 点赞/取消点赞，并立即更新本地 UI 状态
    @objc private func _handleLikeTapped_Hush() {
        guard let post_hush = _currentPost_Hush else { return }

        // 弹性缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self._likeBtnContainer_Hush.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
        }) { _ in
            UIView.animate(withDuration: 0.14, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 8) {
                self._likeBtnContainer_Hush.transform = .identity
            }
        }

        // 执行点赞/取消点赞（ViewModel 内部已处理登录校验）
        TitleViewModel_Hush.shared_Hush.likePost_Hush(post_hush: post_hush)
    }

    /// 更新点赞图标外观
    /// - Parameter isLiked_hush: 当前用户是否已点赞
    private func _updateLikeAppearance_Hush(isLiked_hush: Bool) {
        if isLiked_hush {
            _likeIconInBar_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
            _likeCountInBar_Hush.textColor = ColorConfig_Hush.primaryGradientStart_Hush
        } else {
            _likeIconInBar_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
            _likeCountInBar_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _reportButton_Hush?.removeFromSuperview()
        _reportButton_Hush = nil
        onUserTapped_Hush = nil
        _currentPost_Hush = nil
    }
}
