import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 我的页面
/// 核心作用：展示当前登录用户资料与统计，并分段展示发布/喜欢的帖子，支持举报删除与编辑/设置入口
/// 设计思路：CollectionView 两列网格 + 区头资料卡；顶部固定渐变填充层覆盖状态栏；通知驱动刷新
/// 关键属性：selectedSegment_Breeze 当前分段、displayedPosts_Breeze 当前展示帖子、topFillView_Breeze 状态栏渐变层
class Me_Breeze: UIViewController {
    
    var meModel_Breeze: LoginUserModel_Breeze?
    
    // MARK: - 数据
    
    private var selectedSegment_Breeze: Int = 0
    private var displayedPosts_Breeze: [TitleModel_Breeze] = []
    
    // MARK: - UI：状态栏渐变填充（修复顶部未铺满问题）
    
    /// 覆盖状态栏区域的固定填充视图（纯色 = 渐变起点色），消除顶部色差白边
    private let topFillView_Breeze = UIView()
    
    // MARK: - UI：CollectionView
    
    private let flowLayout_Breeze: UICollectionViewFlowLayout = {
        let layout_breeze = UICollectionViewFlowLayout()
        layout_breeze.minimumLineSpacing = 12
        layout_breeze.minimumInteritemSpacing = 12
        layout_breeze.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 120, right: 16)
        return layout_breeze
    }()
    
    private lazy var collectionView_Breeze: UICollectionView = {
        let cv_breeze = UICollectionView(frame: .zero, collectionViewLayout: flowLayout_Breeze)
        cv_breeze.backgroundColor = .clear
        cv_breeze.showsVerticalScrollIndicator = false
        return cv_breeze
    }()
    
    // MARK: - UI：空态视图
    
    /// 空态容器（图标 + 主标题 + 副标题，居中显示于帖子内容区）
    private let emptyView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.isHidden = true
        return v_breeze
    }()
    
    private let emptyIconView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        iv_breeze.contentMode = .scaleAspectFit
        iv_breeze.tintColor = ColorConfig_Breeze.textPlaceholder_Breeze
        return iv_breeze
    }()
    
    private let emptyTitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    private let emptySubtitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.textAlignment = .center
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Breeze()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 布局完成后刷新状态栏渐变填充（高度 = safeAreaInsets.top）
        refreshTopFill_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        
        // CollectionView 铺满全屏
        view.addSubview(collectionView_Breeze)
        collectionView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView_Breeze.dataSource = self
        collectionView_Breeze.delegate = self
        collectionView_Breeze.register(ProfileGridCell_Breeze.self,
                                        forCellWithReuseIdentifier: ProfileGridCell_Breeze.reuseId_Breeze)
        collectionView_Breeze.register(
            MeHeaderView_Breeze.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MeHeaderView_Breeze.reuseId_Breeze
        )
        
        // 空态视图（叠加在 collectionView 上方，不影响滚动）
        view.addSubview(emptyView_Breeze)
        emptyView_Breeze.addSubview(emptyIconView_Breeze)
        emptyView_Breeze.addSubview(emptyTitleLabel_Breeze)
        emptyView_Breeze.addSubview(emptySubtitleLabel_Breeze)
        
        // 空态视图定位：水平居中，垂直偏移约 header(348) + 内容区中间
        emptyView_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(420)
            make.left.right.equalToSuperview().inset(40)
        }
        
        emptyIconView_Breeze.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        
        emptyTitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Breeze.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        
        emptySubtitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Breeze.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        
        emptySubtitleLabel_Breeze.snp.remakeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Breeze.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 状态栏渐变填充层（固定在顶部，遮住 CollectionView 内容调整产生的空白）
        view.addSubview(topFillView_Breeze)
        topFillView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    /// 刷新状态栏填充色（使用渐变起点纯色，与 Header 渐变左上角完美衔接）
    private func refreshTopFill_Breeze() {
        // 渐变起点纯色 = Header 渐变 (0,0) 处颜色，消除色差断层
        topFillView_Breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
    }
    
    // MARK: - 通知
    
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData_Breeze),
                                               name: UserViewModel_Breeze.userStateDidChangeNotification_Breeze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData_Breeze),
                                               name: TitleViewModel_Breeze.titleStateDidChangeNotification_Breeze, object: nil)
    }
    
    // MARK: - 数据
    
    @objc private func reloadData_Breeze() {
        let currentUser_breeze = UserViewModel_Breeze.shared_Breeze.getCurrentUser_Breeze()
        
        if selectedSegment_Breeze == 0 {
            let prew_breeze = PrewUserModel_Breeze()
            prew_breeze.userId_Breeze = currentUser_breeze.userId_Breeze
            displayedPosts_Breeze = TitleViewModel_Breeze.shared_Breeze.getUserPosts_Breeze(user_breeze: prew_breeze)
        } else {
            displayedPosts_Breeze = currentUser_breeze.userLike_Breeze
        }
        
        updateEmptyState_Breeze()
        collectionView_Breeze.reloadData()
    }
    
    /// 根据帖子内容更新空态视图（纯无数据状态，不含任何登录相关逻辑）
    private func updateEmptyState_Breeze() {
        guard displayedPosts_Breeze.isEmpty else {
            hideEmptyState_Breeze()
            return
        }
        
        if selectedSegment_Breeze == 0 {
            showEmptyState_Breeze(
                iconName_breeze: "photo.on.rectangle.angled",
                iconSize_breeze: 60,
                title_breeze: "No Posts Yet",
                subtitle_breeze: "Share your first outdoor story with the community"
            )
        } else {
            showEmptyState_Breeze(
                iconName_breeze: "heart.slash",
                iconSize_breeze: 56,
                title_breeze: "Nothing Liked Yet",
                subtitle_breeze: "Explore posts and tap the heart to save them here"
            )
        }
    }
    
    /// 显示空态视图并配置内容
    private func showEmptyState_Breeze(iconName_breeze: String,
                                        iconSize_breeze: CGFloat,
                                        title_breeze: String,
                                        subtitle_breeze: String) {
        let config_breeze = UIImage.SymbolConfiguration(pointSize: iconSize_breeze, weight: .thin)
        emptyIconView_Breeze.image = UIImage(systemName: iconName_breeze, withConfiguration: config_breeze)
        emptyTitleLabel_Breeze.text = title_breeze
        emptySubtitleLabel_Breeze.text = subtitle_breeze
        
        guard emptyView_Breeze.isHidden else { return }
        emptyView_Breeze.alpha = 0
        emptyView_Breeze.isHidden = false
        UIView.animate(withDuration: 0.25) { self.emptyView_Breeze.alpha = 1 }
    }
    
    /// 隐藏空态视图
    private func hideEmptyState_Breeze() {
        guard !emptyView_Breeze.isHidden else { return }
        UIView.animate(withDuration: 0.2) { self.emptyView_Breeze.alpha = 0 } completion: { _ in
            self.emptyView_Breeze.isHidden = true
        }
    }
    
    // MARK: - 事件
    
    private func openSetting_Breeze() { Navigation_Breeze.toSetting_Breeze() }
    private func openEdit_Breeze() { Navigation_Breeze.toEditInfo_Breeze() }
    
    private func switchSegment_Breeze(index_breeze: Int) {
        guard index_breeze != selectedSegment_Breeze else { return }
        selectedSegment_Breeze = index_breeze
        reloadData_Breeze()
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UICollectionViewDataSource / Delegate / FlowLayout

extension Me_Breeze: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPosts_Breeze.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_breeze = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileGridCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as? ProfileGridCell_Breeze else { return UICollectionViewCell() }
        cell_breeze.configure_Breeze(post_breeze: displayedPosts_Breeze[indexPath.item], host_breeze: self)
        cell_breeze.onReportComplete_Breeze = { [weak self] in self?.reloadData_Breeze() }
        return cell_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Breeze.toTitleDetail_Breeze(titleModel_breeze: displayedPosts_Breeze[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header_breeze = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MeHeaderView_Breeze.reuseId_Breeze,
                for: indexPath
              ) as? MeHeaderView_Breeze else {
            return UICollectionReusableView()
        }
        header_breeze.configure_Breeze(selectedSegment_breeze: selectedSegment_Breeze)
        header_breeze.onSettings_Breeze = { [weak self] in self?.openSetting_Breeze() }
        header_breeze.onEdit_Breeze    = { [weak self] in self?.openEdit_Breeze() }
        header_breeze.onAvatarTap_Breeze = { [weak self] in self?.openEdit_Breeze() }
        header_breeze.onSegmentChange_Breeze = { [weak self] idx_breeze in
            self?.switchSegment_Breeze(index_breeze: idx_breeze)
        }
        return header_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 348)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing_breeze: CGFloat = 16 * 2 + 12
        let width_breeze = (collectionView.bounds.width - spacing_breeze) / 2
        return CGSize(width: width_breeze, height: ProfileGridCell_Breeze.cellHeight_Breeze(width_breeze: width_breeze))
    }
}
