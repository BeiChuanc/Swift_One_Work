import Foundation
import UIKit
import SnapKit

// MARK: - 发现页
/// 核心作用：以非规则瀑布流（两列、高度不固定）形式展示所有帖子
/// 设计思路：UIScrollView 内嵌两列 UIStackView，每列交替添加卡片，
///           通过不同的媒体高度实现视觉上的"非规则"效果
/// 关键逻辑：
///   - 卡片点击 → Detail
///   - 头像/昵称点击 → UserInfo
///   - 每张卡片右上角举报/删除按钮
///   - 监听 titleStateDidChangeNotification_Nest 实时刷新
///   - 支持通过搜索框筛选标题、正文与作者
class Discover_Nest: UIViewController, UITextFieldDelegate {
    
    // MARK: - 数据
    private var allPosts_Nest: [TitleModel_Nest] = []
    private var displayPosts_Nest: [TitleModel_Nest] = []
    private var searchKeyword_Nest: String = ""
    
    // MARK: - UI 组件
    
    private let headerView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.clipsToBounds = true
        return v_Nest
    }()
    
    private var headerGradient_Nest: CAGradientLayer?
    
    private let headerTitle_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Discover"
        lbl_Nest.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()
    
    private let headerSubtitle_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Find fresh stories, trending sparks, and creators worth following every day."
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.92)
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()
    
    private let headerMetaLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Nest.textColor = .white
        lbl_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        lbl_Nest.layer.cornerRadius = 13
        lbl_Nest.layer.masksToBounds = true
        lbl_Nest.textAlignment = .center
        lbl_Nest.text = "0 posts ready to explore"
        return lbl_Nest
    }()
    
    private let searchContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 22
        v_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Nest.layer.shadowRadius = 12
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()
    
    private let searchIconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "magnifyingglass")
        iv_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()
    
    private let searchField_Nest: UITextField = {
        let tf_Nest = UITextField()
        tf_Nest.placeholder = "Search posts or creators..."
        tf_Nest.font = UIFont.systemFont(ofSize: 15)
        tf_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tf_Nest.returnKeyType = .search
        tf_Nest.clearButtonMode = .whileEditing
        return tf_Nest
    }()
    
    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        sv_Nest.alwaysBounceVertical = true
        sv_Nest.keyboardDismissMode = .onDrag
        sv_Nest.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return sv_Nest
    }()
    
    private let scrollContent_Nest = UIView()
    
    /// 左列
    private let leftColumn_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .vertical
        sv_Nest.spacing = 14
        return sv_Nest
    }()
    
    /// 右列
    private let rightColumn_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .vertical
        sv_Nest.spacing = 14
        return sv_Nest
    }()
    
    private let emptyView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.isHidden = true
        return v_Nest
    }()
    
    private let emptyIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "magnifyingglass")
        iv_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()
    
    private let emptyLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "No posts to discover yet"
        lbl_Nest.font = UIFont.systemFont(ofSize: 15)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Nest()
        setupConstraints_Nest()
        setupNotifications_Nest()
        loadData_Nest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Nest?.frame = headerView_Nest.bounds
    }
    
    // MARK: - UI 构建
    
    private func setupUI_Nest() {
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        
        let gradient_Nest = UIColor.createSecondaryGradientLayer_Nest(frame_Nest: .zero)
        headerView_Nest.layer.insertSublayer(gradient_Nest, at: 0)
        headerGradient_Nest = gradient_Nest
        headerView_Nest.addSubview(headerTitle_Nest)
        headerView_Nest.addSubview(headerSubtitle_Nest)
        headerView_Nest.addSubview(headerMetaLabel_Nest)
        view.addSubview(headerView_Nest)
        
        searchContainer_Nest.addSubview(searchIconView_Nest)
        searchContainer_Nest.addSubview(searchField_Nest)
        searchField_Nest.delegate = self
        searchField_Nest.addTarget(self, action: #selector(onSearchTextChanged_Nest(_:)), for: .editingChanged)
        view.addSubview(searchContainer_Nest)
        
        scrollContent_Nest.addSubview(leftColumn_Nest)
        scrollContent_Nest.addSubview(rightColumn_Nest)
        scrollView_Nest.addSubview(scrollContent_Nest)
        view.addSubview(scrollView_Nest)
        
        emptyView_Nest.addSubview(emptyIcon_Nest)
        emptyView_Nest.addSubview(emptyLabel_Nest)
        view.addSubview(emptyView_Nest)
    }
    
    private func setupConstraints_Nest() {
        headerView_Nest.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(164)
        }
        headerTitle_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(58)
        }
        headerSubtitle_Nest.snp.makeConstraints { make in
            make.top.equalTo(headerTitle_Nest.snp.bottom).offset(8)
            make.leading.equalTo(headerTitle_Nest)
            make.trailing.equalToSuperview().offset(-20)
        }
        headerMetaLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(headerSubtitle_Nest.snp.bottom).offset(12)
            make.leading.equalTo(headerTitle_Nest)
            make.height.equalTo(26)
            make.width.greaterThanOrEqualTo(164)
        }
        searchContainer_Nest.snp.makeConstraints { make in
            make.top.equalTo(headerView_Nest.snp.bottom).offset(-18)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        searchIconView_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        searchField_Nest.snp.makeConstraints { make in
            make.leading.equalTo(searchIconView_Nest.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        scrollView_Nest.snp.makeConstraints { make in
            make.top.equalTo(searchContainer_Nest.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollContent_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        leftColumn_Nest.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(12)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-18)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }
        rightColumn_Nest.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-12)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-18)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }
        
        // 确保 scrollContent_Nest 高度由两列中较高者决定
        scrollContent_Nest.snp.makeConstraints { make in
            make.bottom.equalTo(leftColumn_Nest.snp.bottom).offset(14).priority(.low)
            make.bottom.greaterThanOrEqualTo(rightColumn_Nest.snp.bottom).offset(14)
        }
        
        emptyView_Nest.snp.makeConstraints { make in
            make.center.equalTo(scrollView_Nest)
            make.width.equalTo(220)
        }
        emptyIcon_Nest.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        emptyLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Nest.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 通知
    
    private func setupNotifications_Nest() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStateChanged_Nest),
            name: TitleViewModel_Nest.titleStateDidChangeNotification_Nest,
            object: nil
        )
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    // MARK: - 数据加载
    
    /// 加载发现页原始数据并应用当前搜索条件
    /// 返回值：无
    private func loadData_Nest() {
        allPosts_Nest = TitleViewModel_Nest.shared_Nest.getPosts_Nest()
        applySearch_Nest()
    }
    
    /// 根据当前关键词刷新发现页展示列表
    /// 返回值：无
    private func applySearch_Nest() {
        displayPosts_Nest = TitleViewModel_Nest.shared_Nest.getDiscoverPosts_Nest(
            keyword_nest: searchKeyword_Nest
        )
        updateHeaderMeta_Nest()
        buildWaterfallLayout_Nest()
    }
    
    /// 更新顶部结果描述与空状态文案
    /// 返回值：无
    private func updateHeaderMeta_Nest() {
        let trimmedKeyword_Nest = searchKeyword_Nest.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKeyword_Nest.isEmpty {
            headerMetaLabel_Nest.text = "\(displayPosts_Nest.count) posts ready to explore"
            emptyLabel_Nest.text = "No posts to discover yet"
        } else {
            headerMetaLabel_Nest.text = "\(displayPosts_Nest.count) results for \"\(trimmedKeyword_Nest)\""
            emptyLabel_Nest.text = "No matching posts found"
        }
    }
    
    /// 构建双列瀑布流卡片
    private func buildWaterfallLayout_Nest() {
        leftColumn_Nest.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightColumn_Nest.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if displayPosts_Nest.isEmpty {
            emptyView_Nest.isHidden = false
            return
        }
        emptyView_Nest.isHidden = true
        
        for (idx_Nest, post_Nest) in displayPosts_Nest.enumerated() {
            // 偶数行放左列，奇数行放右列
            let isLeft_Nest = (idx_Nest % 2 == 0)
            // 根据 idx 变化媒体高度，制造不规则效果
            let mediaHeight_Nest: CGFloat = [120, 160, 100, 180, 140][idx_Nest % 5]
            let card_Nest = makeWaterfallCard_Nest(post: post_Nest, mediaHeight: mediaHeight_Nest, index: idx_Nest)
            
            if isLeft_Nest {
                leftColumn_Nest.addArrangedSubview(card_Nest)
            } else {
                rightColumn_Nest.addArrangedSubview(card_Nest)
            }
            
            card_Nest.animateFadeIn_Nest(delay_Nest: TimeInterval(idx_Nest) * AnimationConfig_Nest.delayShort_Nest)
        }
    }
    
    /// 创建瀑布流单卡片
    private func makeWaterfallCard_Nest(
        post: TitleModel_Nest,
        mediaHeight: CGFloat,
        index: Int
    ) -> UIView {
        let card_Nest = UIView()
        card_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        card_Nest.layer.cornerRadius = 16
        card_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        card_Nest.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Nest.layer.shadowRadius = 10
        card_Nest.layer.shadowOpacity = 1
        card_Nest.clipsToBounds = false
        card_Nest.tag = post.titleId_Nest
        
        // 媒体展示（取第一个资源，MediaDisplayView 自动识别图片或视频）
        let mediaView_Nest = MediaDisplayView_Nest()
        mediaView_Nest.configure_Nest(
            mediaPath_Nest: post.titleMeidas_Nest.first,
            isVideo_Nest: false
        )
        mediaView_Nest.clipsToBounds = true
        mediaView_Nest.layer.cornerRadius = 14
        mediaView_Nest.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 作者行
        let authorRow_Nest = UIView()
        authorRow_Nest.isUserInteractionEnabled = true
        let authorAvatar_Nest = UserAvatarView_Nest()
        authorAvatar_Nest.configure_Nest(userId_Nest: post.titleUserId_Nest)
        
        let author_Nest = LocalData_Nest.shared_Nest.userList_Nest
            .first(where: { $0.userId_Nest == post.titleUserId_Nest })
        let authorNameLbl_Nest = UILabel()
        authorNameLbl_Nest.text = author_Nest?.userName_Nest ?? "User"
        authorNameLbl_Nest.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        authorNameLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        authorNameLbl_Nest.numberOfLines = 1
        
        authorRow_Nest.addSubview(authorAvatar_Nest)
        authorRow_Nest.addSubview(authorNameLbl_Nest)
        
        authorAvatar_Nest.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(22)
        }
        authorNameLbl_Nest.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatar_Nest.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        // 标题
        let titleLbl_Nest = UILabel()
        titleLbl_Nest.text = post.title_Nest
        titleLbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        titleLbl_Nest.numberOfLines = 2
        
        // 内容摘要
        let contentLbl_Nest = UILabel()
        contentLbl_Nest.text = post.titleContent_Nest
        contentLbl_Nest.font = UIFont.systemFont(ofSize: 11)
        contentLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        contentLbl_Nest.numberOfLines = 2
        
        // 举报/删除按钮
        let reportBtn_Nest = ReportDeleteHelper_Nest.createPostReportButton_Nest(
            post_Nest: post,
            size_Nest: 13,
            color_Nest: ColorConfig_Nest.textPlaceholder_Nest,
            from: self
        )
        
        card_Nest.addSubview(mediaView_Nest)
        card_Nest.addSubview(authorRow_Nest)
        card_Nest.addSubview(titleLbl_Nest)
        card_Nest.addSubview(contentLbl_Nest)
        card_Nest.addSubview(reportBtn_Nest)
        
        mediaView_Nest.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(mediaHeight)
        }
        reportBtn_Nest.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Nest.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-6)
            make.width.height.equalTo(24)
        }
        authorRow_Nest.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Nest.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalTo(reportBtn_Nest.snp.leading).offset(-4)
            make.height.equalTo(22)
        }
        titleLbl_Nest.snp.makeConstraints { make in
            make.top.equalTo(authorRow_Nest.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        contentLbl_Nest.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Nest.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        // 整体点击 → Detail
        card_Nest.isUserInteractionEnabled = true
        card_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onCardTapped_Nest(_:)))
        )
        
        // 作者行点击 → UserInfo
        let postId_Nest = post.titleId_Nest
        let userId_Nest = post.titleUserId_Nest
        let authorTap_Nest = UITapGestureRecognizer(target: self, action: #selector(onAuthorTapped_Nest(_:)))
        authorRow_Nest.tag = userId_Nest
        authorRow_Nest.addGestureRecognizer(authorTap_Nest)
        // 阻止传递给卡片 tap
        authorTap_Nest.cancelsTouchesInView = true
        _ = postId_Nest // 避免未使用警告
        
        return card_Nest
    }
    
    // MARK: - 事件处理
    
    @objc private func onCardTapped_Nest(_ gesture: UITapGestureRecognizer) {
        let tid_Nest = gesture.view?.tag ?? 0
        if let post_Nest = displayPosts_Nest.first(where: { $0.titleId_Nest == tid_Nest }) {
            Navigation_Nest.toTitleDetail_Nest(titleModel_nest: post_Nest)
        }
    }
    
    @objc private func onAuthorTapped_Nest(_ gesture: UITapGestureRecognizer) {
        let uid_Nest = gesture.view?.tag ?? 0
        if let user_Nest = LocalData_Nest.shared_Nest.userList_Nest.first(where: { $0.userId_Nest == uid_Nest }) {
            Navigation_Nest.toUserInfo_Nest(with: user_Nest)
        }
    }
    
    /// 帖子状态变化后重新加载发现页数据
    /// 返回值：无
    @objc private func onStateChanged_Nest() {
        loadData_Nest()
    }
    
    /// 搜索框文字变化后实时刷新瀑布流
    /// - Parameter textField: 当前输入框
    @objc private func onSearchTextChanged_Nest(_ textField: UITextField) {
        searchKeyword_Nest = textField.text ?? ""
        applySearch_Nest()
    }
    
    /// 点击键盘搜索后收起键盘
    /// - Parameter textField: 当前输入框
    /// - Returns: 是否允许执行默认返回行为
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
