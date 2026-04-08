import Foundation
import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页视图控制器
/// 核心功能：关键字搜索、标签分类过滤、双列瀑布流帖子展示（含举报/删除）
/// 设计理念：顶部渐变 Header + 内嵌搜索框 + 分类标签 + 瀑布流帖子网格
/// 数据来源：TitleViewModel_Somnia（帖子搜索/过滤）、ReportDeleteHelper_Somnia（举报/删除）
class Discover_Somnia: UIViewController {

    // MARK: - 私有属性

    /// 当前搜索关键字
    private var searchKeyword_Somnia: String = ""

    /// 当前选中分类
    private var selectedCategory_Somnia: TitleViewModel_Somnia.DiscoverCategory_Somnia = .all_somnia

    /// 当前展示的帖子列表
    private var displayPosts_Somnia: [TitleModel_Somnia] = []

    /// 上一次计算的帖子列表高度（防止重复设置相同高度触发布局循环）
    private var lastPostsHeight_Somnia: CGFloat = -1

    // MARK: - 私有 UI 属性

    /// 顶部渐变 Header
    private let headerView_Somnia = UIView()
    private var headerGradLayer_Somnia: CAGradientLayer?

    /// 页面标题
    private let titleLabel_Somnia = UILabel()

    /// 副标题
    private let subTitleLabel_Somnia = UILabel()

    /// 搜索框容器（位于 ScrollView 内容区顶部）
    private let searchContainer_Somnia = UIView()

    /// 搜索图标
    private let searchIcon_Somnia = UIImageView()

    /// 搜索输入框
    private let searchField_Somnia = UITextField()

    /// 清空按钮
    private let clearButton_Somnia = UIButton(type: .custom)

    /// 主滚动视图
    private let scrollView_Somnia = UIScrollView()
    private let contentView_Somnia = UIView()

    /// 分类标签滚动区域标题
    private let categoryLabel_Somnia = UILabel()

    /// 分类标签滚动栏
    private let categoryScrollView_Somnia = UIScrollView()
    private let categoryStack_Somnia = UIStackView()
    private var categoryButtons_Somnia: [UIButton] = []

    /// 帖子区标题
    private let postsLabel_Somnia = UILabel()

    /// 帖子双列 CollectionView（瀑布流）
    private let postsCollectionView_Somnia: UICollectionView = {
        let layout_Somnia = WaterfallLayout_Somnia()
        layout_Somnia.columnCount_Somnia = 2
        layout_Somnia.columnSpacing_Somnia = 12
        layout_Somnia.rowSpacing_Somnia = 12
        layout_Somnia.sectionInset_Somnia = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        return UICollectionView(frame: .zero, collectionViewLayout: layout_Somnia)
    }()

    /// 空状态视图
    private let emptyView_Somnia = UIView()
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        // 从子页面（用户中心 / 聊天）pop 回来时，CollectionView 可能因后台通知触发刷新时
        // bounds 未就绪导致高度约束被设为 0。每次显示时强制重置缓存高度并重新计算，
        // 保证帖子列表在任何导航路径返回后都能正常展示
        lastPostsHeight_Somnia = -1
        filterAndReload_Somnia()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupConstraints_Somnia()
        bindViewModel_Somnia()
        loadData_Somnia()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Somnia?.frame = headerView_Somnia.bounds
    }
    
    // MARK: - UI 构建
    
    /// 初始化所有子视图
    private func setupUI_Somnia() {
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia

        // Header 渐变区（底部左右圆角，渐变图层承载圆角避免裁切子视图）
        headerView_Somnia.clipsToBounds = false
        view.addSubview(headerView_Somnia)

        let headerGrad_Somnia = UIColor.createSecondaryGradientLayer_Somnia(frame_Somnia: .zero)
        headerGrad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        headerGrad_Somnia.endPoint = CGPoint(x: 1, y: 1)
        headerGrad_Somnia.cornerRadius = 28
        headerGrad_Somnia.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Somnia.layer.insertSublayer(headerGrad_Somnia, at: 0)
        headerGradLayer_Somnia = headerGrad_Somnia

        // 页面主标题
        titleLabel_Somnia.text = "Discover"
        titleLabel_Somnia.font = UIFont(name: "AvenirNext-Bold", size: 30)
            ?? UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel_Somnia.textColor = .white
        headerView_Somnia.addSubview(titleLabel_Somnia)

        // 副标题
        subTitleLabel_Somnia.text = "Explore the world of dreams"
        subTitleLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitleLabel_Somnia.textColor = UIColor.white.withAlphaComponent(0.75)
        headerView_Somnia.addSubview(subTitleLabel_Somnia)

        // 主滚动视图（紧接 Header 底部开始）
        scrollView_Somnia.showsVerticalScrollIndicator = false
        scrollView_Somnia.alwaysBounceVertical = true
        scrollView_Somnia.backgroundColor = .clear
        scrollView_Somnia.keyboardDismissMode = .onDrag
        scrollView_Somnia.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Somnia)

        contentView_Somnia.backgroundColor = .clear
        scrollView_Somnia.addSubview(contentView_Somnia)

        // 搜索框（位于 contentView 顶部，处于描述文字下方）
        searchContainer_Somnia.backgroundColor = .white
        searchContainer_Somnia.layer.cornerRadius = 22
        searchContainer_Somnia.layer.shadowColor = UIColor(hexstring_Somnia: "#FBB6CE", alpha_Somnia: 0.3).cgColor
        searchContainer_Somnia.layer.shadowOffset = CGSize(width: 0, height: 6)
        searchContainer_Somnia.layer.shadowRadius = 16
        searchContainer_Somnia.layer.shadowOpacity = 1
        contentView_Somnia.addSubview(searchContainer_Somnia)

        // 搜索图标
        searchIcon_Somnia.image = UIImage(systemName: "magnifyingglass")
        searchIcon_Somnia.tintColor = ColorConfig_Somnia.secondaryGradientStart_Somnia
        searchIcon_Somnia.contentMode = .scaleAspectFit
        searchContainer_Somnia.addSubview(searchIcon_Somnia)

        // 搜索输入框
        searchField_Somnia.placeholder = "Search dreams..."
        searchField_Somnia.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        searchField_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        searchField_Somnia.borderStyle = .none
        searchField_Somnia.returnKeyType = .search
        searchField_Somnia.delegate = self
        searchField_Somnia.addTarget(self, action: #selector(searchTextChanged_Somnia), for: .editingChanged)
        searchContainer_Somnia.addSubview(searchField_Somnia)

        // 清空按钮
        clearButton_Somnia.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton_Somnia.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
        clearButton_Somnia.isHidden = true
        clearButton_Somnia.addTarget(self, action: #selector(clearSearch_Somnia), for: .touchUpInside)
        searchContainer_Somnia.addSubview(clearButton_Somnia)

        // 分类标签标题
        categoryLabel_Somnia.text = "Categories"
        categoryLabel_Somnia.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        categoryLabel_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        contentView_Somnia.addSubview(categoryLabel_Somnia)

        // 分类标签滚动
        categoryScrollView_Somnia.showsHorizontalScrollIndicator = false
        categoryScrollView_Somnia.backgroundColor = .clear
        contentView_Somnia.addSubview(categoryScrollView_Somnia)

        categoryStack_Somnia.axis = .horizontal
        categoryStack_Somnia.spacing = 10
        categoryStack_Somnia.alignment = .center
        categoryScrollView_Somnia.addSubview(categoryStack_Somnia)
        buildCategoryButtons_Somnia()

        // 帖子区标题
        postsLabel_Somnia.text = "All Stories"
        postsLabel_Somnia.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        postsLabel_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        contentView_Somnia.addSubview(postsLabel_Somnia)

        // 帖子双列 CollectionView
        postsCollectionView_Somnia.backgroundColor = .clear
        postsCollectionView_Somnia.showsVerticalScrollIndicator = false
        postsCollectionView_Somnia.isScrollEnabled = false
        postsCollectionView_Somnia.register(
            PostGridCell_Somnia.self,
            forCellWithReuseIdentifier: PostGridCell_Somnia.reuseId_Somnia
        )
        postsCollectionView_Somnia.delegate = self
        postsCollectionView_Somnia.dataSource = self
        if let layout_Somnia = postsCollectionView_Somnia.collectionViewLayout as? WaterfallLayout_Somnia {
            layout_Somnia.delegate_Somnia = self
        }
        contentView_Somnia.addSubview(postsCollectionView_Somnia)

        // 空状态视图
        setupEmptyView_Somnia()
    }
    
    /// 构建分类标签按钮
    private func buildCategoryButtons_Somnia() {
        categoryButtons_Somnia.forEach { $0.removeFromSuperview() }
        categoryButtons_Somnia.removeAll()
        
        let leftPadding_Somnia = UIView()
        leftPadding_Somnia.snp.makeConstraints { $0.width.equalTo(20) }
        categoryStack_Somnia.addArrangedSubview(leftPadding_Somnia)
        
        for (i_Somnia, cat_Somnia) in TitleViewModel_Somnia.DiscoverCategory_Somnia.allCases.enumerated() {
            let btn_Somnia = UIButton(type: .custom)
            btn_Somnia.setTitle(cat_Somnia.rawValue, for: .normal)
            btn_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            btn_Somnia.layer.cornerRadius = 16
            btn_Somnia.contentEdgeInsets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
            btn_Somnia.tag = i_Somnia
            btn_Somnia.addTarget(self, action: #selector(categoryTapped_Somnia(_:)), for: .touchUpInside)
            
            updateCategoryButtonStyle_Somnia(btn_Somnia, isSelected: i_Somnia == 0)
            
            categoryStack_Somnia.addArrangedSubview(btn_Somnia)
            categoryButtons_Somnia.append(btn_Somnia)
        }
        
        let rightPadding_Somnia = UIView()
        rightPadding_Somnia.snp.makeConstraints { $0.width.equalTo(20) }
        categoryStack_Somnia.addArrangedSubview(rightPadding_Somnia)
    }
    
    /// 更新分类按钮样式
    private func updateCategoryButtonStyle_Somnia(_ btn_Somnia: UIButton, isSelected_Somnia: Bool) {
        if isSelected_Somnia {
            btn_Somnia.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia
            btn_Somnia.setTitleColor(.white, for: .normal)
            btn_Somnia.layer.shadowColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.4).cgColor
            btn_Somnia.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn_Somnia.layer.shadowRadius = 8
            btn_Somnia.layer.shadowOpacity = 1
        } else {
            btn_Somnia.backgroundColor = .white
            btn_Somnia.setTitleColor(ColorConfig_Somnia.textSecondary_Somnia, for: .normal)
            btn_Somnia.layer.shadowOpacity = 0
        }
    }
    
    /// 重载 updateCategoryButtonStyle 以接受 Bool 字面量（避免参数标签混淆）
    private func updateCategoryButtonStyle_Somnia(_ btn_Somnia: UIButton, isSelected: Bool) {
        updateCategoryButtonStyle_Somnia(btn_Somnia, isSelected_Somnia: isSelected)
    }
    
    /// 构建空状态视图
    private func setupEmptyView_Somnia() {
        emptyView_Somnia.isHidden = true
        contentView_Somnia.addSubview(emptyView_Somnia)
        
        let icon_Somnia = UIImageView(image: UIImage(systemName: "moon.zzz"))
        icon_Somnia.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.4)
        icon_Somnia.contentMode = .scaleAspectFit
        emptyView_Somnia.addSubview(icon_Somnia)
        
        let label_Somnia = UILabel()
        label_Somnia.text = "No dreams found"
        label_Somnia.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label_Somnia.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        label_Somnia.textAlignment = .center
        emptyView_Somnia.addSubview(label_Somnia)
        
        let sub_Somnia = UILabel()
        sub_Somnia.text = "Try different keywords or categories"
        sub_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        sub_Somnia.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        sub_Somnia.textAlignment = .center
        emptyView_Somnia.addSubview(sub_Somnia)
        
        icon_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        label_Somnia.snp.makeConstraints { make in
            make.top.equalTo(icon_Somnia.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        sub_Somnia.snp.makeConstraints { make in
            make.top.equalTo(label_Somnia.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 约束布局
    
    /// 设置所有 SnapKit 约束
    private func setupConstraints_Somnia() {
        // Header：仅含标题和副标题
        headerView_Somnia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }

        titleLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-24)
        }

        subTitleLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Somnia)
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(4)
        }

        // ScrollView 紧接 Header 底部（contentInsetAdjustmentBehavior = .never）
        scrollView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(headerView_Somnia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 四边全部锚定 scrollView.contentLayoutGuide，确保 contentSize 被正确推导
        // width 固定为 frameLayoutGuide 宽度，height 由子视图约束链决定
        contentView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }

        // 搜索框：contentView 顶部，视觉上衔接 Header 下方
        searchContainer_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

        searchIcon_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        searchField_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Somnia.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(clearButton_Somnia.snp.leading).offset(-6)
        }

        clearButton_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        // 分类标签标题
        categoryLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(searchContainer_Somnia.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
        }

        // 分类标签滚动区
        categoryScrollView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel_Somnia.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        categoryStack_Somnia.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        // 帖子区标题（直接跟在分类标签后，无推荐用户区）
        postsLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView_Somnia.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
        }

        // height 初始为 0，由 updatePostsCollectionHeight_Somnia 在布局完成后动态更新
        // bottom 锚定 contentView 底部（= scrollView.contentLayoutGuide.bottom），驱动 contentSize
        postsCollectionView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(postsLabel_Somnia.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-100)
        }

        emptyView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(postsLabel_Somnia.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - 数据绑定
    
    /// 订阅 ViewModel 通知
    private func bindViewModel_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Somnia),
            name: TitleViewModel_Somnia.titleStateDidChangeNotification_Somnia,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Somnia),
            name: UserViewModel_Somnia.userStateDidChangeNotification_Somnia,
            object: nil
        )
        // 从首页跳转发现页通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSwitchToDiscover_Somnia),
            name: Notification.Name("SwitchToDiscover_Somnia"),
            object: nil
        )
    }
    
    /// 通知回调 - 数据变更时刷新
    @objc private func onDataChanged_Somnia() {
        loadData_Somnia()
    }
    
    /// 接收切换到发现页的通知（由首页 Trending / Following 触发）
    @objc private func handleSwitchToDiscover_Somnia() {
        tabBarController?.selectedIndex = 1
    }
    
    /// 加载并刷新数据
    private func loadData_Somnia() {
        filterAndReload_Somnia()
        animateEntrance_Somnia()
    }
    
    /// 执行搜索过滤并刷新帖子列表
    private func filterAndReload_Somnia() {
        displayPosts_Somnia = TitleViewModel_Somnia.shared_Somnia.searchPosts_Somnia(
            keyword_somnia: searchKeyword_Somnia,
            category_somnia: selectedCategory_Somnia
        )
        
        let isEmpty_Somnia = displayPosts_Somnia.isEmpty
        emptyView_Somnia.isHidden = !isEmpty_Somnia
        postsCollectionView_Somnia.isHidden = isEmpty_Somnia
        
        postsCollectionView_Somnia.reloadData()
        
        // 更新帖子区标题
        if selectedCategory_Somnia == .all_somnia && searchKeyword_Somnia.isEmpty {
            postsLabel_Somnia.text = "All Stories"
        } else {
            postsLabel_Somnia.text = "\(displayPosts_Somnia.count) Results"
        }
        
        // 延迟到下一 runloop，确保 Auto Layout 已完成首次 resolve（bounds.width 有效）
        // 再从 WaterfallLayout 读取真实 contentSize，更新 height 约束并同步 scrollView.contentSize
        DispatchQueue.main.async { [weak self] in
            self?.updatePostsCollectionHeight_Somnia()
        }
    }
    
    /// 更新帖子 CollectionView 高度约束
    /// 必须在 Auto Layout 首次 resolve 后（main.async）调用，否则 bounds.width=0 导致计算错误
    private func updatePostsCollectionHeight_Somnia() {
        let h_Somnia = postsCollectionView_Somnia.collectionViewLayout.collectionViewContentSize.height

        // 数据非空时，若计算高度为 0 说明视图尚在后台未完成布局，跳过本次更新
        // 避免后台通知触发刷新时将高度约束错误归零，导致回到页面后帖子"消失"
        if !displayPosts_Somnia.isEmpty && h_Somnia < 1 { return }

        guard abs(h_Somnia - lastPostsHeight_Somnia) > 0.5 else { return }
        lastPostsHeight_Somnia = h_Somnia

        postsCollectionView_Somnia.snp.updateConstraints { make in
            make.height.equalTo(h_Somnia)
        }
        // 强制父视图立即布局，scrollView.contentSize 在此次 layoutIfNeeded 后同步更新
        view.layoutIfNeeded()
    }
    
    // MARK: - 入场动画
    
    /// 首次进入的入场动画
    private var hasAnimated_Somnia = false
    private func animateEntrance_Somnia() {
        guard !hasAnimated_Somnia else { return }
        hasAnimated_Somnia = true
        searchContainer_Somnia.animateSlideInFromBottom_Somnia(offset_Somnia: 30, delay_Somnia: 0.1)
        categoryScrollView_Somnia.animateFadeIn_Somnia(delay_Somnia: 0.2)
        postsCollectionView_Somnia.animateFadeIn_Somnia(delay_Somnia: 0.3)
    }
    
    // MARK: - 事件响应
    
    /// 搜索文字变化
    @objc private func searchTextChanged_Somnia() {
        searchKeyword_Somnia = searchField_Somnia.text ?? ""
        clearButton_Somnia.isHidden = searchKeyword_Somnia.isEmpty
        filterAndReload_Somnia()
    }
    
    /// 清空搜索
    @objc private func clearSearch_Somnia() {
        searchField_Somnia.text = ""
        searchKeyword_Somnia = ""
        clearButton_Somnia.isHidden = true
        filterAndReload_Somnia()
        searchField_Somnia.resignFirstResponder()
    }
    
    /// 分类标签点击
    @objc private func categoryTapped_Somnia(_ sender: UIButton) {
        let all_Somnia = TitleViewModel_Somnia.DiscoverCategory_Somnia.allCases
        guard sender.tag < all_Somnia.count else { return }
        
        selectedCategory_Somnia = all_Somnia[sender.tag]
        
        // 更新按钮样式
        for (i_Somnia, btn_Somnia) in categoryButtons_Somnia.enumerated() {
            let isSelected_Somnia = i_Somnia == sender.tag
            UIView.animate(withDuration: AnimationConfig_Somnia.durationFast_Somnia) {
                self.updateCategoryButtonStyle_Somnia(btn_Somnia, isSelected: isSelected_Somnia)
            }
        }
        
        // 按压反馈
        sender.animatePressDown_Somnia {
            sender.animatePressUp_Somnia()
        }
        
        filterAndReload_Somnia()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Somnia: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension Discover_Somnia: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Somnia.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < displayPosts_Somnia.count,
              let cell_Somnia = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostGridCell_Somnia.reuseId_Somnia,
                for: indexPath
              ) as? PostGridCell_Somnia else {
            return UICollectionViewCell()
        }

        let post_Somnia = displayPosts_Somnia[indexPath.item]
        let isLiked_Somnia = TitleViewModel_Somnia.shared_Somnia.isLikedPost_Somnia(post_somnia: post_Somnia)
        cell_Somnia.configure_Somnia(post_Somnia: post_Somnia, isLiked_Somnia: isLiked_Somnia)

        // 点赞回调
        cell_Somnia.onLikeTapped_Somnia = { [weak self] in
            TitleViewModel_Somnia.shared_Somnia.likePost_Somnia(post_somnia: post_Somnia)
        }

        // 举报/删除回调：通过 ReportDeleteHelper 处理，完成后刷新列表
        cell_Somnia.onReportTapped_Somnia = { [weak self] in
            guard let self = self else { return }
            ReportDeleteHelper_Somnia.report_Somnia(post_Somnia: post_Somnia, from: self) { [weak self] in
                self?.filterAndReload_Somnia()
            }
        }

        // 头像点击回调：查找作者并跳转用户中心（非登录用户）
        cell_Somnia.onAvatarTapped_Somnia = { [weak self] in
            guard let self = self else { return }
            let currentId_Somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia().userId_Somnia
            // 仅允许跳转非当前登录用户的主页
            guard post_Somnia.titleUserId_Somnia != currentId_Somnia else { return }
            let user_Somnia = UserViewModel_Somnia.shared_Somnia.getUserById_Somnia(userId_somnia: post_Somnia.titleUserId_Somnia)
            Navigation_Somnia.toUserInfo_Somnia(with: user_Somnia)
        }

        return cell_Somnia
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < displayPosts_Somnia.count else { return }
        let post_Somnia = displayPosts_Somnia[indexPath.item]
        Navigation_Somnia.toTitleDetail_Somnia(titleModel_somnia: post_Somnia)
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Somnia: WaterfallLayoutDelegate_Somnia {
    
    /// 瀑布流每个 Cell 的高度（奇偶交替实现错落感）
    func collectionView_Somnia(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat {
        // 偶数格高度 200，奇数格高度 240，形成错落感
        return indexPath.item % 2 == 0 ? 200 : 240
    }
}

// MARK: - 瀑布流 Layout（自定义）

/// 瀑布流布局 Delegate 协议
protocol WaterfallLayoutDelegate_Somnia: AnyObject {
    /// 返回指定位置 Cell 的高度
    func collectionView_Somnia(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat
}

/// 双列瀑布流布局
/// 功能：实现双列错落高度的瀑布流，列数/间距可配置
class WaterfallLayout_Somnia: UICollectionViewLayout {
    
    // MARK: - 配置属性
    
    /// 列数
    var columnCount_Somnia: Int = 2
    
    /// 列间距
    var columnSpacing_Somnia: CGFloat = 12
    
    /// 行间距
    var rowSpacing_Somnia: CGFloat = 12
    
    /// 区域 inset
    var sectionInset_Somnia: UIEdgeInsets = .zero
    
    /// Delegate（用于获取 Cell 高度）
    weak var delegate_Somnia: WaterfallLayoutDelegate_Somnia?
    
    // MARK: - 私有缓存
    
    private var cache_Somnia: [UICollectionViewLayoutAttributes] = []
    private var contentHeight_Somnia: CGFloat = 0
    private var contentWidth_Somnia: CGFloat {
        guard let cv_Somnia = collectionView else { return 0 }
        return cv_Somnia.bounds.width - sectionInset_Somnia.left - sectionInset_Somnia.right
    }
    
    // MARK: - Layout 计算
    
    override func prepare() {
        guard let cv_Somnia = collectionView, cache_Somnia.isEmpty else { return }
        
        let columnWidth_Somnia = (contentWidth_Somnia - CGFloat(columnCount_Somnia - 1) * columnSpacing_Somnia) / CGFloat(columnCount_Somnia)
        
        // 每列当前最大 Y 值
        var columnY_Somnia = [CGFloat](repeating: sectionInset_Somnia.top, count: columnCount_Somnia)
        
        for item_Somnia in 0..<cv_Somnia.numberOfItems(inSection: 0) {
            let indexPath_Somnia = IndexPath(item: item_Somnia, section: 0)
            
            // 找最短列
            let shortestCol_Somnia = columnY_Somnia.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            
            let xOffset_Somnia = sectionInset_Somnia.left + CGFloat(shortestCol_Somnia) * (columnWidth_Somnia + columnSpacing_Somnia)
            let yOffset_Somnia = columnY_Somnia[shortestCol_Somnia]
            
            let height_Somnia = delegate_Somnia?.collectionView_Somnia(
                cv_Somnia,
                heightForItemAt: indexPath_Somnia,
                withWidth: columnWidth_Somnia
            ) ?? 200
            
            let frame_Somnia = CGRect(x: xOffset_Somnia, y: yOffset_Somnia, width: columnWidth_Somnia, height: height_Somnia)
            let attrs_Somnia = UICollectionViewLayoutAttributes(forCellWith: indexPath_Somnia)
            attrs_Somnia.frame = frame_Somnia
            cache_Somnia.append(attrs_Somnia)
            
            columnY_Somnia[shortestCol_Somnia] = yOffset_Somnia + height_Somnia + rowSpacing_Somnia
        }
        
        contentHeight_Somnia = (columnY_Somnia.max() ?? 0) + sectionInset_Somnia.bottom
    }
    
    override var collectionViewContentSize: CGSize {
        guard let cv_Somnia = collectionView else { return .zero }
        return CGSize(width: cv_Somnia.bounds.width, height: contentHeight_Somnia)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache_Somnia.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache_Somnia.first { $0.indexPath == indexPath }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache_Somnia.removeAll()
        contentHeight_Somnia = 0
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv_Somnia = collectionView else { return false }
        return newBounds.width != cv_Somnia.bounds.width
    }
}
