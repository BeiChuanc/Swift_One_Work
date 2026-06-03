import Foundation
import UIKit
import SnapKit
import FSPagerView

// MARK: 首页

/// 首页视图控制器
/// 功能：孤品速览轮播、轻弹幕流、我的藏包册、中古故事馆
/// 设计：三色渐变头部、无缝循环弹幕、功能特色入口卡片
class Home_Bague: UIViewController {

    // MARK: - UI 组件（滚动容器）

    private let outerScrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let outerContentView_Bague = UIView()

    // MARK: - 头部（渐变 + 孤品速览）

    private let headerCard_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds = true
        return v
    }()

    private var headerGrad_Bague: CAGradientLayer?

    private let logoLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Bague ✦"
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.textColor = .white
        return label
    }()

    private let taglineLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Discover niche bag picks daily"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        return label
    }()

    private let searchBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    private let notifyBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn.setImage(UIImage(systemName: "bell.badge.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    private let bannerView_Bague: FSPagerView = {
        let pv = FSPagerView()
        pv.automaticSlidingInterval = 4.0
        pv.isInfinite = true
        pv.layer.cornerRadius = 20
        pv.clipsToBounds = true
        pv.interitemSpacing = 16
        pv.decelerationDistance = FSPagerView.automaticDistance
        return pv
    }()

    private let pageControl_Bague: FSPageControl = {
        let pc = FSPageControl()
        pc.contentHorizontalAlignment = .center
        pc.setFillColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
        pc.setFillColor(.white, for: .selected)
        pc.itemSpacing = 8
        return pc
    }()

    // MARK: - 轻弹幕流

    /// 弹幕条带容器
    private let barrageView_Bague = HomeBarrageView_Bague()

    // MARK: - 功能入口卡片

    /// 功能区段标题行
    private let featureSectionRow_Bague: UIView = {
        let container_bague = UIView()
        // 左侧彩色装饰条
        let bar_bague = UIView()
        bar_bague.backgroundColor = UIColor(hexstring_Bague: "#9B72F5")
        bar_bague.layer.cornerRadius = 2
        // 区段主标题
        let title_bague = UILabel()
        title_bague.text = "Explore Features"
        title_bague.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        title_bague.textColor = ColorConfig_Bague.textPrimary_Bague
        // 区段副标题
        let sub_bague = UILabel()
        sub_bague.text = "Curated tools for bag lovers"
        sub_bague.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        sub_bague.textColor = ColorConfig_Bague.textSecondary_Bague
        container_bague.addSubview(bar_bague)
        container_bague.addSubview(title_bague)
        container_bague.addSubview(sub_bague)
        bar_bague.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(36)
        }
        title_bague.snp.makeConstraints { make in
            make.leading.equalTo(bar_bague.snp.trailing).offset(10)
            make.top.equalToSuperview()
        }
        sub_bague.snp.makeConstraints { make in
            make.leading.equalTo(title_bague)
            make.top.equalTo(title_bague.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
        }
        return container_bague
    }()

    /// 我的藏包册入口卡片
    private let collectionBookCard_Bague = HomeFeatureCard_Bague(
        icon: "book.pages.fill",
        title: "My Collection Book",
        subtitle: "Upload your bag & build a personal niche collection guide",
        gradStart: UIColor(hexstring_Bague: "#9B72F5"),
        gradEnd: UIColor(hexstring_Bague: "#C4ABFF"),
        badge: nil
    )

    /// 中古故事馆入口卡片
    private let vintageStoryCard_Bague = HomeFeatureCard_Bague(
        icon: "clock.fill",
        title: "Vintage Story Hall",
        subtitle: "Share the timeless story behind your old bags",
        gradStart: UIColor(hexstring_Bague: "#F07DAD"),
        gradEnd: UIColor(hexstring_Bague: "#FFA07A"),
        badge: "✦ Official Featured"
    )

    // MARK: - 数据

    private var bannerPosts_Bague: [TitleModel_Bague] = []

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
        // 每次布局后同步底部内边距（Tab Bar 高度 + Home Indicator），确保内容可完整滚动
        let bottomInset_bague = view.safeAreaInsets.bottom
        if outerScrollView_Bague.contentInset.bottom != bottomInset_bague {
            outerScrollView_Bague.contentInset.bottom = bottomInset_bague
            outerScrollView_Bague.verticalScrollIndicatorInsets.bottom = bottomInset_bague
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        outerScrollView_Bague.contentInset.bottom = view.safeAreaInsets.bottom
        outerScrollView_Bague.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        barrageView_Bague.startScroll_Bague()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barrageView_Bague.stopScroll_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(outerScrollView_Bague)
        outerScrollView_Bague.addSubview(outerContentView_Bague)

        // 头部
        outerContentView_Bague.addSubview(headerCard_Bague)
        headerCard_Bague.addSubview(logoLabel_Bague)
        headerCard_Bague.addSubview(taglineLabel_Bague)
        headerCard_Bague.addSubview(searchBtn_Bague)
        headerCard_Bague.addSubview(notifyBtn_Bague)
        headerCard_Bague.addSubview(bannerView_Bague)
        headerCard_Bague.addSubview(pageControl_Bague)
        searchBtn_Bague.addTarget(self, action: #selector(searchTapped_Bague), for: .touchUpInside)
        notifyBtn_Bague.addTarget(self, action: #selector(notifyTapped_Bague), for: .touchUpInside)
        bannerView_Bague.register(HomeBannerCell_Bague.self, forCellWithReuseIdentifier: HomeBannerCell_Bague.reuseId_Bague)
        bannerView_Bague.dataSource = self
        bannerView_Bague.delegate = self

        // 轻弹幕流（内嵌输入框，onSendTapped 直接处理发送逻辑）
        outerContentView_Bague.addSubview(barrageView_Bague)
        barrageView_Bague.onSendTapped_Bague = { [weak self] in
            self?.handleBarrageSend_Bague()
        }

        // 功能入口卡片（区段标题 + 两张卡片）
        outerContentView_Bague.addSubview(featureSectionRow_Bague)
        outerContentView_Bague.addSubview(collectionBookCard_Bague)
        outerContentView_Bague.addSubview(vintageStoryCard_Bague)
        collectionBookCard_Bague.onTap_Bague = {
            Navigation_Bague.toCollectionBook_Bague()
        }
        vintageStoryCard_Bague.onTap_Bague = {
            Navigation_Bague.toVintageStory_Bague()
        }
    }

    private func setupConstraints_Bague() {
        outerScrollView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        outerContentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        // 头部（顶部延伸到状态栏下方）
        headerCard_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(340)
        }
        searchBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        notifyBtn_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(searchBtn_Bague)
            make.trailing.equalTo(searchBtn_Bague.snp.leading).offset(-10)
            make.width.height.equalTo(36)
        }
        logoLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(22)
        }
        taglineLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(logoLabel_Bague.snp.bottom).offset(4)
            make.leading.equalTo(logoLabel_Bague)
        }
        bannerView_Bague.snp.makeConstraints { make in
            make.top.equalTo(taglineLabel_Bague.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-36)
        }
        pageControl_Bague.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        // 弹幕区（4行弹幕 + 底部输入行）
        // 高度 = 10(padTop) + 4行*(42+6) - 6 + 6(gap) + 40(input) + 6(bottom) = 248pt
        barrageView_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Bague.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(248)
        }
        // 功能区段标题（弹幕下方 20pt）
        featureSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(barrageView_Bague.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        // 功能入口卡片（标题下方 14pt）
        collectionBookCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(featureSectionRow_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        vintageStoryCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(collectionBookCard_Bague.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 渐变

    private func updateGradient_Bague() {
        headerGrad_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = headerCard_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        grad_bague.locations = [0.0, 0.55, 1.0]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        headerCard_Bague.layer.insertSublayer(grad_bague, at: 0)
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

    private func loadData_Bague() {
        let all_bague = TitleViewModel_Bague.shared_Bague.getPosts_Bague()
        bannerPosts_Bague = Array(all_bague.sorted { $0.likes_Bague > $1.likes_Bague }.prefix(3))
        pageControl_Bague.numberOfPages = bannerPosts_Bague.count
        bannerView_Bague.reloadData()
    }

    // MARK: - 弹幕发送处理

    /// 处理弹幕发送（由弹幕视图内嵌输入框的 Send 按钮或回车触发）
    private func handleBarrageSend_Bague() {
        guard UserViewModel_Bague.shared_Bague.isLoggedIn_Bague else {
            Navigation_Bague.toLogin_Bague(style_bague: .present_bague)
            return
        }
        guard let text_bague = barrageView_Bague.currentInputText_Bague(),
              !text_bague.isEmpty else { return }
        let trimmed_bague = String(text_bague.prefix(20))
        let userName_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague().userName_Bague ?? "User"
        barrageView_Bague.addUserBarrage_Bague(text: trimmed_bague, author: userName_bague)
        barrageView_Bague.clearInput_Bague()
    }

    // MARK: - 事件处理

    @objc private func searchTapped_Bague() {
        searchBtn_Bague.animatePulse_Bague()
        Navigation_Bague.toDiscover_Bague(style_bague: .push_bague)
    }

    @objc private func notifyTapped_Bague() {
        notifyBtn_Bague.animatePulse_Bague()
        Utils_Bague.showInfo_Bague(message_Bague: "No new notifications")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - FSPagerViewDataSource & Delegate

extension Home_Bague: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return max(1, bannerPosts_Bague.count)
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell_bague = pagerView.dequeueReusableCell(
            withReuseIdentifier: HomeBannerCell_Bague.reuseId_Bague,
            at: index
        ) as! HomeBannerCell_Bague
        if index < bannerPosts_Bague.count {
            cell_bague.configure_Bague(post_bague: bannerPosts_Bague[index])
        }
        return cell_bague
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        guard index < bannerPosts_Bague.count else { return }
        Navigation_Bague.toTitleDetail_Bague(titleModel_bague: bannerPosts_Bague[index])
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl_Bague.currentPage = pagerView.currentIndex
    }

    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        pageControl_Bague.currentPage = pagerView.currentIndex
    }
}

// MARK: - 孤品速览轮播单元格

/// 首页轮播横幅单元格（孤品速览）
class HomeBannerCell_Bague: FSPagerViewCell {

    static let reuseId_Bague = "HomeBannerCell_Bague"

    private let mediaIV_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let overlay_Bague = UIView()
    private var overlayGrad_Bague: CAGradientLayer?

    private let rankBadge_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#FFD700")
        v.layer.cornerRadius = 12
        return v
    }()

    private let rankLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Bague: "#7B4A00")
        return l
    }()

    private let postTitle_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private let authorLbl_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.88)
        return label
    }()

    private let likesLbl_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI_Bague() {
        contentView.addSubview(mediaIV_Bague)
        contentView.addSubview(overlay_Bague)
        overlay_Bague.addSubview(postTitle_Bague)
        overlay_Bague.addSubview(authorLbl_Bague)
        overlay_Bague.addSubview(likesLbl_Bague)
        contentView.addSubview(rankBadge_Bague)
        rankBadge_Bague.addSubview(rankLabel_Bague)

        mediaIV_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        overlay_Bague.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(130)
        }
        postTitle_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(authorLbl_Bague.snp.top).offset(-6)
        }
        authorLbl_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        likesLbl_Bague.snp.makeConstraints { make in
            make.centerY.equalTo(authorLbl_Bague)
            make.trailing.equalToSuperview().offset(-16)
        }
        rankBadge_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
        }
        rankLabel_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayGrad_Bague?.removeFromSuperlayer()
        let g_bague = CAGradientLayer()
        g_bague.frame = overlay_Bague.bounds
        g_bague.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.78).cgColor]
        g_bague.startPoint = CGPoint(x: 0, y: 0)
        g_bague.endPoint = CGPoint(x: 0, y: 1)
        overlay_Bague.layer.insertSublayer(g_bague, at: 0)
        overlayGrad_Bague = g_bague
    }

    func configure_Bague(post_bague: TitleModel_Bague) {
        postTitle_Bague.text = post_bague.title_Bague
        authorLbl_Bague.text = "by \(post_bague.titleUserName_Bague)"
        likesLbl_Bague.text = "♥ \(post_bague.likes_Bague)"
        let media_bague = post_bague.titleMeidas_Bague.first ?? ""
        if let img_bague = UIImage(named: media_bague) {
            mediaIV_Bague.image = img_bague
            mediaIV_Bague.contentMode = .scaleAspectFill
        } else {
            mediaIV_Bague.image = UIImage(systemName: "bag.fill")
            mediaIV_Bague.tintColor = .white
            mediaIV_Bague.backgroundColor = UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.4)
            mediaIV_Bague.contentMode = .scaleAspectFit
        }
        rankLabel_Bague.text = "✦ Top Pick"
    }
}

// MARK: - 轻弹幕流视图

/// 弹幕数据模型（本地）
/// 功能：封装单条弹幕文字、发布者用户 ID/名称、唯一条目 ID
struct BarrageItem_Bague {
    /// 弹幕唯一 ID（用于删除）
    var itemId_Bague: Int
    /// 弹幕文字（≤20字）
    let text_Bague: String
    /// 发布者用户 ID（0 = 官方账号）
    let userId_Bague: Int
    /// 发布者昵称
    let author_Bague: String
}

/// 首页轻弹幕流视图
/// 功能：4 行独立横向滚动弹幕（头像+昵称+内容+删除/举报）+ 底部输入框和发送按钮
/// 设计：浅紫背景、富卡片式气泡（UserAvatarView + 文字 + 操作按钮）、每行 Timer 独立驱动
class HomeBarrageView_Bague: UIView {

    // MARK: - 回调

    var onSendTapped_Bague: (() -> Void)?

    // MARK: - 弹幕数据（用户发布的真实弹幕，官方置顶）
    // userId 对应 LocalData 中预制用户（ID 10-20），0 为官方

    var items_Bague: [BarrageItem_Bague] = [
        BarrageItem_Bague(itemId_Bague: 1,  text_Bague: "Topic: Your first niche bag find?",  userId_Bague: 11, author_Bague: "EmberSeeker"),
        BarrageItem_Bague(itemId_Bague: 2,  text_Bague: "My dream bag finally arrived!",       userId_Bague: 12, author_Bague: "ForestWhisper"),
        BarrageItem_Bague(itemId_Bague: 3,  text_Bague: "Vintage markets are pure gold",       userId_Bague: 13, author_Bague: "FlameJumper"),
        BarrageItem_Bague(itemId_Bague: 4,  text_Bague: "Niche leather is true luxury",        userId_Bague: 14, author_Bague: "AshesToArt"),
        BarrageItem_Bague(itemId_Bague: 5,  text_Bague: "Show off your Collection Book!",      userId_Bague: 15, author_Bague: "NightGlow"),
        BarrageItem_Bague(itemId_Bague: 6,  text_Bague: "The leather on this bag is insane",   userId_Bague: 16, author_Bague: "CedarMist"),
        BarrageItem_Bague(itemId_Bague: 7,  text_Bague: "Pre-loved Hermès > brand new",        userId_Bague: 17, author_Bague: "WildRose"),
        BarrageItem_Bague(itemId_Bague: 8,  text_Bague: "Found an amazing vintage tote!",      userId_Bague: 18, author_Bague: "StoneRiver"),
        BarrageItem_Bague(itemId_Bague: 9,  text_Bague: "Leather care really matters",         userId_Bague: 19, author_Bague: "MoonPetal"),
        BarrageItem_Bague(itemId_Bague: 10, text_Bague: "Japan vintage market is a treasure",  userId_Bague: 20, author_Bague: "SilverLeaf"),
        BarrageItem_Bague(itemId_Bague: 11, text_Bague: "Vintage Story Hall picks updated!",   userId_Bague: 11, author_Bague: "EmberSeeker"),
        BarrageItem_Bague(itemId_Bague: 12, text_Bague: "This bag has been with me 10 years",  userId_Bague: 12, author_Bague: "ForestWhisper"),
        BarrageItem_Bague(itemId_Bague: 13, text_Bague: "New strap transformed my old bag",    userId_Bague: 13, author_Bague: "FlameJumper"),
        BarrageItem_Bague(itemId_Bague: 14, text_Bague: "Hidden gem shops need more love",     userId_Bague: 14, author_Bague: "AshesToArt"),
        BarrageItem_Bague(itemId_Bague: 15, text_Bague: "Worn leather but I still love it",    userId_Bague: 15, author_Bague: "NightGlow"),
        BarrageItem_Bague(itemId_Bague: 16, text_Bague: "Scored a Margiela for steal price",   userId_Bague: 16, author_Bague: "CedarMist"),
    ]

    // MARK: - UI 组件

    /// 4 行弹幕滚动容器
    private var rowScrollViews_Bague: [UIScrollView] = []
    private var rowCardStacks_Bague: [UIStackView] = []

    /// 底部输入行
    private let inputRow_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Bague: "#D4C4FF").cgColor
        return v
    }()

    private let inputField_Bague: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tf.textColor = UIColor(hexstring_Bague: "#4A3080")
        tf.attributedPlaceholder = NSAttributedString(
            string: "Share your thought (max 20 chars)...",
            attributes: [.foregroundColor: UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.5)]
        )
        tf.tintColor = UIColor(hexstring_Bague: "#9B72F5")
        tf.returnKeyType = .send
        return tf
    }()

    private let sendBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Send", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.tintColor = UIColor(hexstring_Bague: "#9B72F5")
        btn.setTitleColor(UIColor(hexstring_Bague: "#9B72F5"), for: .normal)
        btn.backgroundColor = UIColor(hexstring_Bague: "#EDD9FF")
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return btn
    }()

    // MARK: - 滚动状态（每行独立速度/方向）

    private var scrollTimer_Bague: Timer?
    private var rowOffsets_Bague: [CGFloat] = [0, 0, 0, 0]
    private var rowGroupWidths_Bague: [CGFloat] = [0, 0, 0, 0]
    /// 每行滚动速度（正=向左，负=向右）
    private let rowSpeeds_Bague: [CGFloat] = [0.52, -0.42, 0.48, -0.55]

    // MARK: - 常量

    private let rowCount_Bague = 4
    private let rowHeight_Bague: CGFloat = 42
    private let rowSpacing_Bague: CGFloat = 6
    private let inputHeight_Bague: CGFloat = 40
    private let padH_Bague: CGFloat = 12
    private let padTop_Bague: CGFloat = 10

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI_Bague() {
        backgroundColor = UIColor(hexstring_Bague: "#F5F0FF")
        layer.cornerRadius = 20

        // 构建 4 行滚动区域
        let perRow_bague = Int(ceil(Double(items_Bague.count) / Double(rowCount_Bague)))
        for row_bague in 0..<rowCount_Bague {
            let sv_bague = UIScrollView()
            sv_bague.showsHorizontalScrollIndicator = false
            sv_bague.isUserInteractionEnabled = true
            sv_bague.clipsToBounds = true

            let stack_bague = UIStackView()
            stack_bague.axis = .horizontal
            stack_bague.spacing = 8
            stack_bague.alignment = .center

            sv_bague.addSubview(stack_bague)
            addSubview(sv_bague)
            rowScrollViews_Bague.append(sv_bague)
            rowCardStacks_Bague.append(stack_bague)

            let start_bague = row_bague * perRow_bague
            let end_bague = min(start_bague + perRow_bague, items_Bague.count)
            guard start_bague < items_Bague.count else { continue }
            let rowItems_bague = Array(items_Bague[start_bague..<end_bague])
            appendItemsToStack_Bague(stack: stack_bague, items: rowItems_bague)
        }

        // 底部输入行
        addSubview(inputRow_Bague)
        inputRow_Bague.addSubview(inputField_Bague)
        inputRow_Bague.addSubview(sendBtn_Bague)
        sendBtn_Bague.addTarget(self, action: #selector(sendTapped_Bague), for: .touchUpInside)
        inputField_Bague.delegate = self

        setupConstraints_Bague()
    }

    /// 向 stack 添加两组 items（实现无缝循环）
    private func appendItemsToStack_Bague(stack: UIStackView, items: [BarrageItem_Bague]) {
        (0..<2).forEach { _ in
            items.forEach { item in
                stack.addArrangedSubview(makeBarrageCard_Bague(item: item))
            }
        }
    }

    private func setupConstraints_Bague() {
        for (idx_bague, sv_bague) in rowScrollViews_Bague.enumerated() {
            let stack_bague = rowCardStacks_Bague[idx_bague]
            let top_bague = padTop_Bague + CGFloat(idx_bague) * (rowHeight_Bague + rowSpacing_Bague)
            sv_bague.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(top_bague)
                make.leading.equalToSuperview().offset(padH_Bague)
                make.trailing.equalToSuperview().offset(-padH_Bague)
                make.height.equalTo(rowHeight_Bague)
            }
            stack_bague.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(4)
                make.top.bottom.height.equalToSuperview()
            }
        }
        let inputTop_bague = padTop_Bague + CGFloat(rowCount_Bague) * (rowHeight_Bague + rowSpacing_Bague)
        inputRow_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(inputTop_bague)
            make.leading.equalToSuperview().offset(padH_Bague)
            make.trailing.equalToSuperview().offset(-padH_Bague)
            make.height.equalTo(inputHeight_Bague)
        }
        sendBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        inputField_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalTo(sendBtn_Bague.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 富卡片弹幕（统一白色样式：头像 + 昵称 + 内容 + 操作按钮）

    /// 创建单条弹幕富卡片视图
    /// - 所有弹幕统一白色卡片样式，无官方/用户区别
    /// - 操作按钮在点击时通过响应链找 VC，解决构建阶段无法找到宿主控制器的问题
    private func makeBarrageCard_Bague(item: BarrageItem_Bague) -> UIView {
        let card_bague = UIView()
        card_bague.layer.cornerRadius = 16
        card_bague.backgroundColor = .white
        card_bague.layer.borderWidth = 1
        card_bague.layer.borderColor = UIColor(hexstring_Bague: "#D4C4FF").cgColor

        // 头像
        let avatar_bague = UserAvatarView_Bague()
        avatar_bague.configure_Bague(userId_Bague: item.userId_Bague)
        card_bague.addSubview(avatar_bague)

        // 昵称
        let nameLbl_bague = UILabel()
        nameLbl_bague.text = item.author_Bague
        nameLbl_bague.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        nameLbl_bague.textColor = UIColor(hexstring_Bague: "#9B72F5")
        card_bague.addSubview(nameLbl_bague)

        // 内容
        let contentLbl_bague = UILabel()
        contentLbl_bague.text = item.text_Bague
        contentLbl_bague.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        contentLbl_bague.textColor = UIColor(hexstring_Bague: "#4A3080")
        contentLbl_bague.numberOfLines = 1
        card_bague.addSubview(contentLbl_bague)

        // 操作按钮（本人→trash 删除，他人→ellipsis 举报）
        // 关键：在点击回调里查找 VC，而非构建时查找，确保响应链已就绪
        let actionBtn_bague = UIButton(type: .system)
        let isOwn_bague = UserViewModel_Bague.shared_Bague.isCurrentUser_Bague(userId_bague: item.userId_Bague)
        let iconName_bague = isOwn_bague ? "trash" : "ellipsis"
        let iconCfg_bague = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        actionBtn_bague.setImage(UIImage(systemName: iconName_bague, withConfiguration: iconCfg_bague), for: .normal)
        actionBtn_bague.tintColor = UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.65)
        card_bague.addSubview(actionBtn_bague)

        let itemId_bague = item.itemId_Bague
        let userId_bague = item.userId_Bague
        actionBtn_bague.addAction(UIAction { [weak self, weak actionBtn_bague] _ in
            // 点击时通过响应链找到宿主 VC（此时视图已在层级，必然找到）
            var responder: UIResponder? = actionBtn_bague
            while let r_bague = responder {
                if let vc_bague = r_bague as? UIViewController {
                    if isOwn_bague {
                        // 本人弹幕：确认后从弹幕池删除并重建
                        let alert_bague = UIAlertController(
                            title: "Delete Barrage",
                            message: "Remove this barrage?",
                            preferredStyle: .alert
                        )
                        alert_bague.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                            self?.deleteBarrage_Bague(itemId: itemId_bague)
                        })
                        alert_bague.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        vc_bague.present(alert_bague, animated: true)
                    } else {
                        // 他人弹幕：举报/拉黑，同时从弹幕池移除该用户的所有弹幕
                        let user_bague = UserViewModel_Bague.shared_Bague.getUserById_Bague(userId_bague: userId_bague)
                        ReportDeleteHelper_Bague.block_Bague(user_Bague: user_bague, from: vc_bague) {
                            // block 确认后：移除该用户全部弹幕并重建
                            self?.removeBarragesByUser_Bague(userId: userId_bague)
                        }
                    }
                    break
                }
                responder = r_bague.next
            }
        }, for: .touchUpInside)

        // 约束
        avatar_bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        nameLbl_bague.snp.makeConstraints { make in
            make.leading.equalTo(avatar_bague.snp.trailing).offset(6)
            make.top.equalToSuperview().offset(7)
            make.trailing.lessThanOrEqualTo(actionBtn_bague.snp.leading).offset(-4)
        }
        contentLbl_bague.snp.makeConstraints { make in
            make.leading.equalTo(nameLbl_bague)
            make.top.equalTo(nameLbl_bague.snp.bottom).offset(1)
            make.trailing.equalTo(actionBtn_bague.snp.leading).offset(-4)
            make.bottom.equalToSuperview().inset(7)
        }
        actionBtn_bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        return card_bague
    }

    /// 删除指定 itemId 的弹幕，从池中移除后重建
    private func deleteBarrage_Bague(itemId: Int) {
        items_Bague.removeAll { $0.itemId_Bague == itemId }
        rebuildAllRows_Bague()
    }

    /// 移除指定用户的所有弹幕（举报/拉黑后调用）
    private func removeBarragesByUser_Bague(userId: Int) {
        items_Bague.removeAll { $0.userId_Bague == userId }
        rebuildAllRows_Bague()
    }

    /// 重建全部 4 行（删除/添加后调用）
    /// 重置行宽度缓存并强制触发 layout 更新，保证滚动宽度正确重算
    private func rebuildAllRows_Bague() {
        let perRow_bague = max(1, Int(ceil(Double(items_Bague.count) / Double(rowCount_Bague))))
        rowCardStacks_Bague.enumerated().forEach { rowIdx_bague, stack_bague in
            stack_bague.arrangedSubviews.forEach { $0.removeFromSuperview() }
            let start_bague = rowIdx_bague * perRow_bague
            guard start_bague < items_Bague.count else { return }
            let end_bague = min(start_bague + perRow_bague, items_Bague.count)
            appendItemsToStack_Bague(stack: stack_bague, items: Array(items_Bague[start_bague..<end_bague]))
            rowGroupWidths_Bague[rowIdx_bague] = 0
            // 滚动位置归零，避免超出新内容范围
            rowOffsets_Bague[rowIdx_bague] = 0
            rowScrollViews_Bague[safe: rowIdx_bague]?.contentOffset = .zero
        }
        // 强制触发 layoutSubviews 重新计算各行组宽度
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rowCardStacks_Bague.enumerated().forEach { idx_bague, stack_bague in
            stack_bague.layoutIfNeeded()
            if rowGroupWidths_Bague[idx_bague] == 0 && stack_bague.frame.width > 0 {
                rowGroupWidths_Bague[idx_bague] = stack_bague.frame.width / 2
            }
        }
    }

    // MARK: - 自动滚动（4 行独立方向和速度）

    func startScroll_Bague() {
        stopScroll_Bague()
        scrollTimer_Bague = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.scrollStep_Bague()
        }
        RunLoop.main.add(scrollTimer_Bague!, forMode: .common)
    }

    func stopScroll_Bague() {
        scrollTimer_Bague?.invalidate()
        scrollTimer_Bague = nil
    }

    private func scrollStep_Bague() {
        rowScrollViews_Bague.enumerated().forEach { idx_bague, sv_bague in
            let groupW_bague = rowGroupWidths_Bague[idx_bague]
            guard groupW_bague > 0 else { return }
            rowOffsets_Bague[idx_bague] += rowSpeeds_Bague[idx_bague]
            if rowOffsets_Bague[idx_bague] >= groupW_bague { rowOffsets_Bague[idx_bague] = 0 }
            else if rowOffsets_Bague[idx_bague] < 0 { rowOffsets_Bague[idx_bague] = groupW_bague - 1 }
            sv_bague.contentOffset.x = rowOffsets_Bague[idx_bague]
        }
    }

    // MARK: - 外部接口

    func currentInputText_Bague() -> String? {
        return inputField_Bague.text?.trimmingCharacters(in: .whitespaces)
    }

    func clearInput_Bague() {
        inputField_Bague.text = ""
        inputField_Bague.resignFirstResponder()
    }

    /// 添加用户发送的弹幕（插在最前面）
    func addUserBarrage_Bague(text: String, author: String) {
        let currentUser_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        let newId_bague = (items_Bague.max(by: { $0.itemId_Bague < $1.itemId_Bague })?.itemId_Bague ?? 0) + 1
        let item_bague = BarrageItem_Bague(
            itemId_Bague: newId_bague,
            text_Bague: text,
            userId_Bague: currentUser_bague.userId_Bague ?? 0,
            author_Bague: author
        )
        items_Bague.insert(item_bague, at: 0)
        rebuildAllRows_Bague()
    }

    @objc private func sendTapped_Bague() {
        sendBtn_Bague.animatePulse_Bague()
        onSendTapped_Bague?()
    }
}

// MARK: - Array 安全下标扩展（弹幕内部使用）

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

// MARK: - HomeBarrageView UITextFieldDelegate

extension HomeBarrageView_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text_bague = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !text_bague.isEmpty else { return false }
        onSendTapped_Bague?()
        return true
    }
}


// MARK: - 功能特色入口卡片

/// 首页功能入口卡片（我的藏包册 / 中古故事馆）
/// 功能：渐变背景 + 图标 + 标题 + 描述 + 可选徽章，点击触发回调
class HomeFeatureCard_Bague: UIView {

    var onTap_Bague: (() -> Void)?

    private var gradStart_Bague: UIColor
    private var gradEnd_Bague: UIColor
    private var gradLayer_Bague: CAGradientLayer?

    private let iconBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 22
        return v
    }()

    private let iconView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLbl_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let subtitleLbl_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.numberOfLines = 2
        return l
    }()

    private let badgeLbl_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        l.textColor = UIColor(hexstring_Bague: "#7B5800")
        l.backgroundColor = UIColor(hexstring_Bague: "#FFD700")
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        l.isHidden = true
        return l
    }()

    private let arrowIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.7)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(icon: String, title: String, subtitle: String, gradStart: UIColor, gradEnd: UIColor, badge: String?) {
        self.gradStart_Bague = gradStart
        self.gradEnd_Bague = gradEnd
        super.init(frame: .zero)

        let cfg_bague = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView_Bague.image = UIImage(systemName: icon, withConfiguration: cfg_bague)
        titleLbl_Bague.text = title
        subtitleLbl_Bague.text = subtitle

        if let badge_bague = badge {
            badgeLbl_Bague.text = "  \(badge_bague)  "
            badgeLbl_Bague.isHidden = false
        }

        buildUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI_Bague() {
        layer.cornerRadius = 20
        layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 12
        clipsToBounds = false

        addSubview(iconBg_Bague)
        iconBg_Bague.addSubview(iconView_Bague)
        addSubview(titleLbl_Bague)
        addSubview(subtitleLbl_Bague)
        addSubview(badgeLbl_Bague)
        addSubview(arrowIcon_Bague)

        iconBg_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        iconView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleLbl_Bague.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Bague.snp.trailing).offset(14)
            make.top.equalToSuperview().offset(18)
            make.trailing.equalTo(arrowIcon_Bague.snp.leading).offset(-8)
        }
        badgeLbl_Bague.snp.makeConstraints { make in
            make.leading.equalTo(titleLbl_Bague)
            make.top.equalTo(titleLbl_Bague.snp.bottom).offset(4)
        }
        subtitleLbl_Bague.snp.makeConstraints { make in
            make.leading.equalTo(titleLbl_Bague)
            make.top.equalTo(badgeLbl_Bague.isHidden ? titleLbl_Bague.snp.bottom : badgeLbl_Bague.snp.bottom).offset(4)
            make.trailing.equalTo(titleLbl_Bague)
        }
        arrowIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        let tap_bague = UITapGestureRecognizer(target: self, action: #selector(tapped_Bague))
        addGestureRecognizer(tap_bague)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Bague?.removeFromSuperlayer()
        let g_bague = CAGradientLayer()
        g_bague.frame = bounds
        g_bague.colors = [gradStart_Bague.cgColor, gradEnd_Bague.cgColor]
        g_bague.startPoint = CGPoint(x: 0, y: 0)
        g_bague.endPoint = CGPoint(x: 1, y: 1)
        g_bague.cornerRadius = 20
        layer.insertSublayer(g_bague, at: 0)
        gradLayer_Bague = g_bague
    }

    @objc private func tapped_Bague() {
        animatePressDown_Bague { self.animatePressUp_Bague { self.onTap_Bague?() } }
    }
}

