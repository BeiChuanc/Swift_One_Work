import Foundation
import UIKit
import SnapKit

// MARK: 发现页

/// 发现页（公园露营主题）
/// 核心作用：以非规则瀑布流呈现全部帖子，支持举报/删除并进入详情
/// 设计思路：UICollectionView + WaterfallLayout_Breeze，cell 复用 PostCardCell_Breeze；通知驱动刷新
/// 关键属性：collectionView_Breeze 瀑布流容器、posts_Breeze 数据源
class Discover_Breeze: UIViewController {
    
    // MARK: - 数据
    
    /// 帖子数据
    private var posts_Breeze: [TitleModel_Breeze] = []
    
    // MARK: - UI 组件
    
    /// 顶部标题
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Discover"
        label_breeze.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    /// 副标题
    private let subtitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Fresh finds from fellow campers"
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }()
    
    /// 瀑布流布局
    private let waterfallLayout_Breeze = WaterfallLayout_Breeze()
    
    /// 瀑布流容器
    private lazy var collectionView_Breeze: UICollectionView = {
        let collectionView_breeze = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout_Breeze)
        collectionView_breeze.backgroundColor = .clear
        collectionView_breeze.showsVerticalScrollIndicator = false
        collectionView_breeze.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        return collectionView_breeze
    }()
    
    /// 下拉刷新
    private let refreshControl_Breeze = UIRefreshControl()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
        reloadData_Breeze()
    }
    
    // MARK: - UI 设置
    
    /// 搭建发现页 UI
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        
        view.addSubview(titleLabel_Breeze)
        view.addSubview(subtitleLabel_Breeze)
        view.addSubview(collectionView_Breeze)
        
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
        }
        subtitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Breeze.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
        }
        collectionView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Breeze.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
        
        waterfallLayout_Breeze.delegate_Breeze = self
        collectionView_Breeze.dataSource = self
        collectionView_Breeze.delegate = self
        collectionView_Breeze.register(PostCardCell_Breeze.self, forCellWithReuseIdentifier: PostCardCell_Breeze.reuseId_Breeze)
        
        refreshControl_Breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        refreshControl_Breeze.addTarget(self, action: #selector(handleRefresh_Breeze), for: .valueChanged)
        collectionView_Breeze.refreshControl = refreshControl_Breeze
    }
    
    // MARK: - 通知
    
    /// 注册帖子状态变化通知
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData_Breeze),
            name: TitleViewModel_Breeze.titleStateDidChangeNotification_Breeze,
            object: nil
        )
    }
    
    // MARK: - 数据
    
    /// 重新加载数据
    @objc private func reloadData_Breeze() {
        posts_Breeze = TitleViewModel_Breeze.shared_Breeze.getPosts_Breeze()
        waterfallLayout_Breeze.invalidateLayout()
        collectionView_Breeze.reloadData()
    }
    
    /// 下拉刷新
    @objc private func handleRefresh_Breeze() {
        reloadData_Breeze()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.refreshControl_Breeze.endRefreshing()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension Discover_Breeze: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts_Breeze.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_breeze = collectionView.dequeueReusableCell(
            withReuseIdentifier: PostCardCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as? PostCardCell_Breeze else {
            return UICollectionViewCell()
        }
        
        let post_breeze = posts_Breeze[indexPath.item]
        let itemWidth_breeze = itemWidth_Breeze()
        cell_breeze.configure_Breeze(post_breeze: post_breeze, hostViewController_breeze: self, cardWidth_breeze: itemWidth_breeze)
        cell_breeze.onReportComplete_Breeze = { [weak self] in
            self?.reloadData_Breeze()
        }
        return cell_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Breeze.toTitleDetail_Breeze(titleModel_breeze: posts_Breeze[indexPath.item])
    }
    
    /// 计算单列宽度
    private func itemWidth_Breeze() -> CGFloat {
        let inset_breeze = waterfallLayout_Breeze.sectionInset_Breeze
        let totalSpacing_breeze = waterfallLayout_Breeze.columnSpacing_Breeze * CGFloat(waterfallLayout_Breeze.columnCount_Breeze - 1)
        let available_breeze = APPSCREEN_Breeze.WIDTH_Breeze - inset_breeze.left - inset_breeze.right - totalSpacing_breeze
        return available_breeze / CGFloat(waterfallLayout_Breeze.columnCount_Breeze)
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Breeze: WaterfallLayoutDelegate_Breeze {
    
    func waterfallLayout_Breeze(_ layout_breeze: WaterfallLayout_Breeze,
                                heightForItemAt indexPath_breeze: IndexPath,
                                itemWidth_breeze: CGFloat) -> CGFloat {
        let post_breeze = posts_Breeze[indexPath_breeze.item]
        return PostCardCell_Breeze.cellHeight_Breeze(width_breeze: itemWidth_breeze, post_breeze: post_breeze)
    }
}
