import Foundation
import UIKit
import SnapKit

// MARK: 发现页

// MARK: - Section 分组头视图

/// 发现页 Section 分组标题头部视图
/// 核心作用：显示分组标题、数量徽章，附带左侧渐变竖条装饰
/// 设计理念：主色渐变竖条 + 加粗标题 + 右侧数量胶囊标签
class DiscoverSectionHeaderView_Pane: UICollectionReusableView {

    static let reuseId_Pane = "DiscoverSectionHeaderView_Pane"

    // MARK: UI

    private let accentBar_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()
    private var accentGL_Pane: CAGradientLayer?

    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .heavy)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 数量胶囊标签
    private let countChip_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Pane: "#EDF2F7")
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        return v
    }()

    private let countLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        accentGL_Pane?.frame = accentBar_Pane.bounds
    }

    private func setupUI_Pane() {
        backgroundColor = .clear

        addSubview(accentBar_Pane)
        accentBar_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(4)
            $0.height.equalTo(22)
        }
        let gl = UIColor.createPrimaryGradientLayer_Pane(frame_Pane: .zero)
        gl.cornerRadius = 2
        accentBar_Pane.layer.addSublayer(gl)
        accentGL_Pane = gl

        addSubview(titleLabel_Pane)
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(accentBar_Pane.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }

        countChip_Pane.addSubview(countLabel_Pane)
        countLabel_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(3)
        }

        addSubview(countChip_Pane)
        countChip_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleLabel_Pane.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: 配置

    /// 配置标题和数量
    /// - Parameters:
    ///   - title_pane: 分组标题（含 emoji，由外部决定）
    ///   - count_pane: 数量，传 nil 则隐藏胶囊
    func configure_Pane(title_pane: String, count_pane: Int?) {
        titleLabel_Pane.text = title_pane
        if let count_pane = count_pane {
            countLabel_Pane.text = "\(count_pane)"
            countChip_Pane.isHidden = false
        } else {
            countChip_Pane.isHidden = true
        }
    }
}

// MARK: - 发现页空状态视图

/// 发现页空状态视图（搜索无结果时展示）
/// 核心作用：在搜索结果为空时给予友好提示
private class DiscoverEmptyView_Pane: UIView {

    private let iconView_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = ColorConfig_Pane.textPlaceholder_Pane
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "No Results Found"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Try different keywords to find windows or explorers"
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Pane() {
        addSubview(iconView_Pane)
        addSubview(titleLabel_Pane)
        addSubview(subtitleLabel_Pane)

        iconView_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
            $0.width.height.equalTo(48)
        }
        titleLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(iconView_Pane.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        subtitleLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel_Pane.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
}

// MARK: - 发现页 ViewController

/// 发现页面
/// 核心作用：双列瀑布流帖子列表（含举报/删除）+ 搜索功能
/// 设计理念：渐变头部 + 搜索栏 + 双列瀑布流帖子
/// 关键方法：loadData_Pane() - 加载数据；performSearch_Pane() - 切换到搜索模式
class Discover_Pane: UIViewController {

    // MARK: - Section 标识

    private enum Section_Pane: Int, CaseIterable {
        case posts_pane = 0  // 帖子双列瀑布流（含举报/删除）
    }

    // MARK: - UI组件

    /// 顶部标题栏
    private let headerView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private var headerGradientLayer_Pane: CAGradientLayer?

    /// 左侧渐变竖线装饰（对齐 Home 页风格）
    private let headerAccentBar_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()
    private var headerAccentGL_Pane: CAGradientLayer?

    private let pageTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Discover"
        l.font = UIFont(name: "Georgia-Bold", size: 26) ?? .systemFont(ofSize: 26, weight: .black)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    private let pageSubtitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Windows & Explorers"
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    /// 右侧指南针图标装饰
    private let compassIcon_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "safari.fill"))
        iv.tintColor = ColorConfig_Pane.primaryGradientStart_Pane
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: 搜索栏

    private let searchBarContainer_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor  = UIColor.black.withAlphaComponent(0.08).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 10
        return v
    }()

    private var searchBarBorderLayer_Pane: CAGradientLayer?

    private let searchIcon_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = ColorConfig_Pane.primaryGradientStart_Pane
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let searchField_Pane: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search windows, explorers..."
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = ColorConfig_Pane.textPrimary_Pane
        tf.returnKeyType = .search
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private let cancelButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(ColorConfig_Pane.primaryGradientStart_Pane, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.alpha = 0
        btn.isUserInteractionEnabled = false
        return btn
    }()

    // MARK: CollectionView

    /// 瀑布流自定义布局（Section 0 双列帖子）
    private lazy var waterfallLayout_Pane: DiscoverCollectionLayout_Pane = {
        let layout = DiscoverCollectionLayout_Pane()
        layout.delegate_Pane = self
        return layout
    }()

    private lazy var collectionView_Pane: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout_Pane)
        cv.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        cv.showsVerticalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 100, right: 0)
        cv.keyboardDismissMode = .onDrag
        cv.dataSource = self
        cv.delegate   = self
        return cv
    }()

    private let emptyView_Pane = DiscoverEmptyView_Pane()

    // MARK: - 数据属性

    /// 全量帖子列表（双列瀑布流，非搜索态使用）
    private var allPosts_Pane:      [TitleModel_Pane] = []
    private var searchedPosts_Pane: [TitleModel_Pane] = []
    private var isSearching_Pane:   Bool   = false
    private var searchKeyword_Pane: String = ""

    /// 当前帖子列表（搜索态用搜索结果，非搜索态用全量）
    private var currentPosts_Pane: [TitleModel_Pane] {
        return isSearching_Pane ? searchedPosts_Pane : allPosts_Pane
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Pane()
        setupHeader_Pane()
        setupSearchBar_Pane()
        setupCollectionView_Pane()
        registerNotifications_Pane()
        loadData_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        collectionView_Pane.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateUserCells_Pane()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Pane?.frame  = headerView_Pane.bounds
        headerAccentGL_Pane?.frame       = headerAccentBar_Pane.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 初始化

    private func setupView_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
    }

    /// 构建顶部标题栏（渐变背景 + 左侧装饰竖线 + 标题/副标题 + 指南针图标）
    private func setupHeader_Pane() {
        view.addSubview(headerView_Pane)
        headerView_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        // 头部背景渐变
        let hgl = CAGradientLayer()
        hgl.colors = [
            ColorConfig_Pane.backgroundPrimary_Pane.withAlphaComponent(0.98).cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.withAlphaComponent(0.95).cgColor
        ]
        hgl.startPoint = CGPoint(x: 0, y: 0)
        hgl.endPoint   = CGPoint(x: 0, y: 1)
        headerView_Pane.layer.addSublayer(hgl)
        headerGradientLayer_Pane = hgl

        // 左侧渐变装饰竖线
        headerView_Pane.addSubview(headerAccentBar_Pane)
        headerAccentBar_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview().offset(-2)
            $0.width.equalTo(4)
            $0.height.equalTo(30)
        }
        let agl = UIColor.createPrimaryGradientLayer_Pane(frame_Pane: .zero)
        agl.cornerRadius = 2
        headerAccentBar_Pane.layer.addSublayer(agl)
        headerAccentGL_Pane = agl

        // 标题
        headerView_Pane.addSubview(pageTitleLabel_Pane)
        pageTitleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(headerAccentBar_Pane.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(8)
        }

        headerView_Pane.addSubview(pageSubtitleLabel_Pane)
        pageSubtitleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(pageTitleLabel_Pane)
            $0.top.equalTo(pageTitleLabel_Pane.snp.bottom).offset(0)
        }

        // 右侧指南针图标
        headerView_Pane.addSubview(compassIcon_Pane)
        compassIcon_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }

        // 底部分割线
        let sep = UIView()
        sep.backgroundColor = ColorConfig_Pane.divider_Pane
        headerView_Pane.addSubview(sep)
        sep.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    /// 构建搜索栏
    private func setupSearchBar_Pane() {
        view.addSubview(searchBarContainer_Pane)
        searchBarContainer_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(46)
        }

        searchBarContainer_Pane.addSubview(searchIcon_Pane)
        searchIcon_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }

        searchBarContainer_Pane.addSubview(searchField_Pane)
        searchField_Pane.snp.makeConstraints {
            $0.leading.equalTo(searchIcon_Pane.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
        searchField_Pane.delegate = self
        searchField_Pane.addTarget(self, action: #selector(handleSearchTextChange_Pane), for: .editingChanged)

        view.addSubview(cancelButton_Pane)
        cancelButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(searchBarContainer_Pane)
            $0.width.equalTo(60)
        }
        cancelButton_Pane.addTarget(self, action: #selector(handleCancelSearch_Pane), for: .touchUpInside)
    }

    /// 配置 CollectionView
    private func setupCollectionView_Pane() {
        collectionView_Pane.register(
            DiscoverPostCell_Pane.self,
            forCellWithReuseIdentifier: DiscoverPostCell_Pane.reuseId_Pane
        )
        collectionView_Pane.register(
            DiscoverSectionHeaderView_Pane.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DiscoverSectionHeaderView_Pane.reuseId_Pane
        )

        view.addSubview(collectionView_Pane)
        collectionView_Pane.snp.makeConstraints {
            $0.top.equalTo(searchBarContainer_Pane.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 空状态视图
        view.addSubview(emptyView_Pane)
        emptyView_Pane.snp.makeConstraints {
            $0.top.equalTo(searchBarContainer_Pane.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    private func loadData_Pane() {
        // 全量帖子供双列瀑布流展示（按点赞数降序，最多 50 条）
        allPosts_Pane = TitleViewModel_Pane.shared_Pane.getPosts_Pane()
            .sorted { $0.likes_Pane > $1.likes_Pane }
            .prefix(50)
            .map { $0 }
        collectionView_Pane.reloadData()
        updateEmptyState_Pane()
    }

    /// 更新空状态视图的显示/隐藏（搜索结果为空时展示）
    private func updateEmptyState_Pane() {
        let isEmpty_pane         = isSearching_Pane && searchedPosts_Pane.isEmpty
        emptyView_Pane.isHidden      = !isEmpty_pane
        collectionView_Pane.isHidden = isEmpty_pane
    }

    // MARK: - 搜索逻辑

    private func performSearch_Pane(keyword_pane: String) {
        searchKeyword_Pane = keyword_pane
        isSearching_Pane   = !keyword_pane.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        searchedPosts_Pane = TitleViewModel_Pane.shared_Pane.searchPosts_Pane(keyword_pane: keyword_pane)
        collectionView_Pane.reloadData()
        updateEmptyState_Pane()
    }

    private func activateSearchUI_Pane() {
        UIView.animate(
            withDuration: AnimationConfig_Pane.durationNormal_Pane,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Pane.springDampingNormal_Pane,
            initialSpringVelocity: AnimationConfig_Pane.springVelocity_Pane,
            options: [.curveEaseOut]
        ) {
            self.searchBarContainer_Pane.snp.updateConstraints {
                $0.trailing.equalToSuperview().offset(-82)
            }
            self.cancelButton_Pane.alpha = 1
            self.cancelButton_Pane.isUserInteractionEnabled = true
            // 激活时搜索栏加主色描边
            self.searchBarContainer_Pane.layer.borderWidth = 1.5
            self.searchBarContainer_Pane.layer.borderColor = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
            self.view.layoutIfNeeded()
        }
    }

    private func deactivateSearchUI_Pane() {
        UIView.animate(
            withDuration: AnimationConfig_Pane.durationNormal_Pane,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Pane.springDampingNormal_Pane,
            initialSpringVelocity: AnimationConfig_Pane.springVelocity_Pane,
            options: [.curveEaseOut]
        ) {
            self.searchBarContainer_Pane.snp.updateConstraints {
                $0.trailing.equalToSuperview().offset(-16)
            }
            self.cancelButton_Pane.alpha = 0
            self.cancelButton_Pane.isUserInteractionEnabled = false
            self.searchBarContainer_Pane.layer.borderWidth = 0
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 通知

    private func registerNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Pane),
            name: TitleViewModel_Pane.titleStateDidChangeNotification_Pane, object: nil
        )
    }

    @objc private func handleStateChange_Pane() {
        loadData_Pane()
        if isSearching_Pane { performSearch_Pane(keyword_pane: searchKeyword_Pane) }
    }

    // MARK: - 动画

    private func animateUserCells_Pane() {
        // 帖子与用户列表入场弹簧动画
        let indexPaths_pane = collectionView_Pane.indexPathsForVisibleItems
        indexPaths_pane.sorted { $0.item < $1.item }.enumerated().forEach { idx_pane, ip_pane in
            guard let cell_pane = collectionView_Pane.cellForItem(at: ip_pane) else { return }
            cell_pane.animateSpringScaleIn_Pane(delay_Pane: Double(idx_pane) * 0.05)
        }
    }

    // MARK: - 事件处理

    @objc private func handleSearchTextChange_Pane() {
        performSearch_Pane(keyword_pane: searchField_Pane.text ?? "")
    }

    @objc private func handleCancelSearch_Pane() {
        searchField_Pane.text = ""
        searchField_Pane.resignFirstResponder()
        isSearching_Pane = false
        deactivateSearchUI_Pane()
        loadData_Pane()
    }
}

// MARK: - UICollectionViewDataSource

extension Discover_Pane: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section_Pane.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section_Pane(rawValue: section) {
        case .posts_pane: return currentPosts_Pane.count
        default:          return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section_Pane(rawValue: indexPath.section) {

        case .posts_pane:
            let cell_pane = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiscoverPostCell_Pane.reuseId_Pane, for: indexPath
            ) as! DiscoverPostCell_Pane
            let posts_pane = currentPosts_Pane
            if indexPath.item < posts_pane.count {
                let post_pane = posts_pane[indexPath.item]
                cell_pane.configure_Pane(post_pane: post_pane)
                // 操作按钮回调：由 VC 调用 ReportDeleteHelper_Pane 处理举报/删除
                cell_pane.onMenuTapped_Pane = { [weak self] in
                    guard let self = self else { return }
                    let isMyPost_pane = UserViewModel_Pane.shared_Pane.isCurrentUser_Pane(
                        userId_pane: post_pane.titleUserId_Pane
                    )
                    if isMyPost_pane {
                        ReportDeleteHelper_Pane.delete_Pane(
                            post_Pane: post_pane,
                            from: self
                        ) { [weak self] in self?.loadData_Pane() }
                    } else {
                        ReportDeleteHelper_Pane.report_Pane(
                            post_Pane: post_pane,
                            from: self
                        ) { [weak self] in self?.loadData_Pane() }
                    }
                }
                // 头像点击：跳转到帖子作者的用户中心页面
                cell_pane.onAvatarTapped_Pane = { [weak self] userId_pane in
                    guard let self = self else { return }
                    let vc_pane = UserInfo_Pane()
                    vc_pane.userId_Pane = userId_pane
                    Navigation_Pane.push_Pane(to: vc_pane, from: self)
                }
            }
            return cell_pane

        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        let header_pane = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: DiscoverSectionHeaderView_Pane.reuseId_Pane,
            for: indexPath
        ) as! DiscoverSectionHeaderView_Pane

        let title_pane = isSearching_Pane ? "Posts" : "📋 All Posts"
        header_pane.configure_Pane(title_pane: title_pane, count_pane: currentPosts_Pane.count)
        return header_pane
    }
}

// MARK: - UICollectionViewDelegate

extension Discover_Pane: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < currentPosts_Pane.count else { return }
        Navigation_Pane.toTitleDetail_Pane(titleModel_pane: currentPosts_Pane[indexPath.item])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        cell.animateFadeIn_Pane(duration_Pane: 0.25)
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Pane: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activateSearchUI_Pane()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        performSearch_Pane(keyword_pane: "")
        return true
    }
}

// MARK: - 瀑布流布局高度委托

extension Discover_Pane: DiscoverCollectionLayoutDelegate_Pane {

    /// 返回指定帖子 Cell 的高度（由 DiscoverPostCell_Pane 静态方法计算）
    /// - Parameters:
    ///   - layout_pane:      当前自定义布局实例
    ///   - indexPath_pane:   帖子在 Section 0 中的 IndexPath
    ///   - columnWidth_pane: 双列中当前列的宽度
    /// - Returns: 预计 Cell 高度
    func discoverLayout_Pane(
        _ layout_pane: DiscoverCollectionLayout_Pane,
        heightForPostAt indexPath_pane: IndexPath,
        columnWidth_pane: CGFloat
    ) -> CGFloat {
        guard indexPath_pane.item < currentPosts_Pane.count else { return 220 }
        return DiscoverPostCell_Pane.estimatedHeight_Pane(
            post_pane: currentPosts_Pane[indexPath_pane.item],
            width_pane: columnWidth_pane
        )
    }
}

// MARK: - 双列瀑布流布局委托协议

/// 发现页布局委托：提供帖子 Cell 的动态高度
protocol DiscoverCollectionLayoutDelegate_Pane: AnyObject {

    /// 获取帖子 Cell 高度
    /// - Parameters:
    ///   - layout_pane:      布局实例
    ///   - indexPath_pane:   帖子 IndexPath（Section 0）
    ///   - columnWidth_pane: 列宽（双列布局的单列宽度）
    /// - Returns: Cell 精确高度
    func discoverLayout_Pane(
        _ layout_pane: DiscoverCollectionLayout_Pane,
        heightForPostAt indexPath_pane: IndexPath,
        columnWidth_pane: CGFloat
    ) -> CGFloat
}

// MARK: - 发现页自定义瀑布流布局

/// 发现页专用布局管理器
/// 核心作用：Section 0（帖子）双列瀑布流，各列独立累积高度实现真正错落效果
/// 设计思路：在 prepare() 中一次性计算全部 LayoutAttributes 并缓存，
///          layoutAttributesForElements 通过矩形裁剪提高滚动性能
class DiscoverCollectionLayout_Pane: UICollectionViewLayout {

    // MARK: - 委托

    /// 委托：提供帖子 Cell 高度
    weak var delegate_Pane: DiscoverCollectionLayoutDelegate_Pane?

    // MARK: - 配置参数

    /// 帖子区列间距
    private let postColumnSpacing_Pane: CGFloat = 10
    /// 帖子区外边距
    private let postInset_Pane = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
    /// 帖子行间距
    private let postRowSpacing_Pane: CGFloat = 10
    /// Section Header 高度
    private let headerHeight_Pane: CGFloat = 48

    // MARK: - 缓存

    private var cellCache_Pane:   [UICollectionViewLayoutAttributes] = []
    private var headerCache_Pane: [UICollectionViewLayoutAttributes] = []
    private var contentHeight_Pane: CGFloat = 0

    // MARK: - 布局计算

    /// 预计算所有布局属性（reloadData / invalidateLayout 触发）
    override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }

        cellCache_Pane.removeAll()
        headerCache_Pane.removeAll()
        contentHeight_Pane = 0

        let totalW_pane = cv.bounds.width
        var yOffset_pane: CGFloat = 0

        // ── Section 0: 帖子双列瀑布流 ──
        let postCount_pane = cv.numberOfSections > 0 ? cv.numberOfItems(inSection: 0) : 0

        let postHeader_pane = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            with: IndexPath(item: 0, section: 0)
        )
        postHeader_pane.frame = CGRect(x: 0, y: yOffset_pane, width: totalW_pane, height: headerHeight_Pane)
        headerCache_Pane.append(postHeader_pane)
        yOffset_pane += headerHeight_Pane + postInset_Pane.top

        // 列宽 = (总宽 - 左右边距 - 列间距) / 2
        let colW_pane = (totalW_pane - postInset_Pane.left - postInset_Pane.right - postColumnSpacing_Pane) / 2.0
        // 各列当前累积高度（从 yOffset 起）
        var colTops_pane = [CGFloat](repeating: yOffset_pane, count: 2)

        for i in 0..<postCount_pane {
            // 选取最短的列放置下一个 Cell
            let col_pane     = colTops_pane[0] <= colTops_pane[1] ? 0 : 1
            let xOffset_pane = postInset_Pane.left + CGFloat(col_pane) * (colW_pane + postColumnSpacing_Pane)
            let ip_pane      = IndexPath(item: i, section: 0)
            let cellH_pane: CGFloat = delegate_Pane?.discoverLayout_Pane(
                self, heightForPostAt: ip_pane, columnWidth_pane: colW_pane
            ) ?? 220

            let attr_pane = UICollectionViewLayoutAttributes(forCellWith: ip_pane)
            attr_pane.frame = CGRect(
                x: xOffset_pane,
                y: colTops_pane[col_pane],
                width: colW_pane,
                height: cellH_pane
            )
            cellCache_Pane.append(attr_pane)
            colTops_pane[col_pane] += cellH_pane + postRowSpacing_Pane
        }

        contentHeight_Pane = (colTops_pane.max() ?? yOffset_pane) + postInset_Pane.bottom
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight_Pane)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let all_pane = cellCache_Pane + headerCache_Pane
        return all_pane.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cellCache_Pane.first { $0.indexPath == indexPath }
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        headerCache_Pane.first { $0.indexPath == indexPath }
    }

    /// 横竖屏旋转（宽度变化）时需要重新计算布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        newBounds.width != collectionView?.bounds.width
    }
}
