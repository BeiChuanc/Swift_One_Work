import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页
/// 核心作用：聚合四季主题露营专区、个人相册入口、热门帖子轮播三大模块
/// 设计思路：渐变问候头部 + UIScrollView 纵向堆叠三个 Section；通知驱动刷新
/// 关键属性：seasonTipsSection_Breeze 季节专区、albumSection_Breeze 相册入口、hotPostsSection_Breeze 热门轮播
class Home_Breeze: UIViewController {
    
    // MARK: - 数据
    
    /// 当前季节 Tips（当季过滤）
    private var currentTips_Breeze: [SeasonalTip_Breeze] = []
    
    /// 热门帖子（点赞排序前 8）
    private var hotPosts_Breeze: [TitleModel_Breeze] = []
    
    /// 用户相册条目（最近 4 张）
    private var recentAlbumItems_Breeze: [CampingAlbumItem_Breeze] = []
    
    // MARK: - UI：渐变头部
    
    private let heroView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    
    private var heroGradient_Breeze: CAGradientLayer?
    
    private let decorCircle_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v_breeze.layer.cornerRadius = 70
        return v_breeze
    }()
    
    private let greetingLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.85)
        return label_breeze
    }()
    
    private let heroTitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Breeze"
        label_breeze.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    private let seasonBadge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_breeze.layer.cornerRadius = 12
        return v_breeze
    }()
    
    private let seasonBadgeLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    private let seasonBadgeIcon_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        iv_breeze.tintColor = .white
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    // MARK: - UI：主滚动区
    
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsVerticalScrollIndicator = false
        sv_breeze.backgroundColor = .clear
        sv_breeze.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        return sv_breeze
    }()
    
    private let contentStack_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .vertical
        stack_breeze.spacing = 0
        return stack_breeze
    }()
    
    // MARK: - UI：三个 Section（延迟初始化，避免循环引用）
    
    private lazy var seasonTipsSection_Breeze = SeasonTipsSection_Breeze()
    private lazy var albumSection_Breeze = AlbumEntrySection_Breeze()
    private lazy var hotPostsSection_Breeze = HotPostsSection_Breeze()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupSectionCallbacks_Breeze()
        setupObservers_Breeze()
        reloadData_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Breeze()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeroGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeroView_Breeze()
        setupScrollContent_Breeze()
    }
    
    private func setupHeroView_Breeze() {
        view.addSubview(heroView_Breeze)
        heroView_Breeze.addSubview(decorCircle_Breeze)
        heroView_Breeze.addSubview(greetingLabel_Breeze)
        heroView_Breeze.addSubview(heroTitleLabel_Breeze)
        heroView_Breeze.addSubview(seasonBadge_Breeze)
        seasonBadge_Breeze.addSubview(seasonBadgeIcon_Breeze)
        seasonBadge_Breeze.addSubview(seasonBadgeLabel_Breeze)
        
        heroView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        decorCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.right.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(-30)
        }
        
        greetingLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.equalToSuperview().offset(22)
        }
        heroTitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel_Breeze.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(22)
        }
        seasonBadge_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroTitleLabel_Breeze.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(22)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-18)
        }
        seasonBadgeIcon_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        seasonBadgeLabel_Breeze.snp.makeConstraints { make in
            make.left.equalTo(seasonBadgeIcon_Breeze.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    private func refreshHeroGradient_Breeze() {
        heroGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: heroView_Breeze.bounds)
        heroView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        heroGradient_Breeze = gradient_breeze
    }
    
    private func setupScrollContent_Breeze() {
        view.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(contentStack_Breeze)
        
        scrollView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroView_Breeze.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        contentStack_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentStack_Breeze.addArrangedSubview(seasonTipsSection_Breeze)
        contentStack_Breeze.addArrangedSubview(albumSection_Breeze)
        contentStack_Breeze.addArrangedSubview(hotPostsSection_Breeze)
    }
    
    /// 绑定各 Section 的跳转回调
    private func setupSectionCallbacks_Breeze() {
        seasonTipsSection_Breeze.onSeeAll_Breeze = { [weak self] in
            self?.showAllSeasonTips_Breeze()
        }
        // 点击单张 Tip 卡片 → 弹出详情 Sheet
        seasonTipsSection_Breeze.onCardTap_Breeze = { [weak self] tip_breeze in
            self?.showTipDetail_Breeze(tip_breeze: tip_breeze)
        }
        albumSection_Breeze.onOpenAlbum_Breeze = { [weak self] in
            Navigation_Breeze.toAlbumPage_Breeze()
        }
        albumSection_Breeze.onAddPhoto_Breeze = { [weak self] in
            self?.addAlbumPhoto_Breeze()
        }
        hotPostsSection_Breeze.onPostTap_Breeze = { [weak self] post_breeze in
            Navigation_Breeze.toTitleDetail_Breeze(titleModel_breeze: post_breeze)
        }
    }
    
    // MARK: - 通知
    
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData_Breeze),
                                               name: TitleViewModel_Breeze.titleStateDidChangeNotification_Breeze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData_Breeze),
                                               name: UserViewModel_Breeze.userStateDidChangeNotification_Breeze, object: nil)
    }
    
    // MARK: - 数据刷新
    
    @objc private func reloadData_Breeze() {
        updateHeroGreeting_Breeze()
        
        // 当季 Tips（取前 4 条）
        let season_breeze = Season_Breeze.current_Breeze
        currentTips_Breeze = LocalData_Breeze.shared_Breeze.seasonalTips_Breeze
            .filter { $0.season_Breeze == season_breeze }
        seasonTipsSection_Breeze.configure_Breeze(season_breeze: season_breeze, tips_breeze: currentTips_Breeze)
        
        // 相册最近 4 张
        recentAlbumItems_Breeze = Array(UserViewModel_Breeze.shared_Breeze.getAlbumItems_Breeze().prefix(4))
        albumSection_Breeze.configure_Breeze(items_breeze: recentAlbumItems_Breeze)
        
        // 热门帖子（点赞倒序前 8）
        hotPosts_Breeze = Array(TitleViewModel_Breeze.shared_Breeze.getPosts_Breeze()
            .sorted { $0.likes_Breeze > $1.likes_Breeze }.prefix(8))
        hotPostsSection_Breeze.configure_Breeze(posts_breeze: hotPosts_Breeze)
    }
    
    /// 更新头部问候语和季节标签
    private func updateHeroGreeting_Breeze() {
        let hour_breeze = Calendar.current.component(.hour, from: Date())
        let greeting_breeze: String
        switch hour_breeze {
        case 5..<12:  greeting_breeze = "Good Morning ☀️"
        case 12..<17: greeting_breeze = "Good Afternoon 🌤"
        case 17..<21: greeting_breeze = "Good Evening 🌅"
        default:      greeting_breeze = "Good Night 🌙"
        }
        greetingLabel_Breeze.text = greeting_breeze
        
        let season_breeze = Season_Breeze.current_Breeze
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        seasonBadgeIcon_Breeze.image = UIImage(systemName: season_breeze.iconName_Breeze, withConfiguration: iconConf_breeze)
        seasonBadgeLabel_Breeze.text = "\(season_breeze.rawValue) Camping Season"
    }
    
    // MARK: - 事件
    
    /// 弹出单条 Tip 详情 Sheet
    private func showTipDetail_Breeze(tip_breeze: SeasonalTip_Breeze) {
        let vc_breeze = TipDetailSheet_Breeze()
        vc_breeze.tip_Breeze = tip_breeze
        vc_breeze.modalPresentationStyle = .pageSheet
        if let sheet_breeze = vc_breeze.sheetPresentationController {
            sheet_breeze.detents = [.medium(), .large()]
            sheet_breeze.prefersGrabberVisible = true
        }
        present(vc_breeze, animated: true)
    }
    
    /// 展示全部当季 Tips（底部弹窗）
    private func showAllSeasonTips_Breeze() {
        let vc_breeze = SeasonTipsDetailPage_Breeze()
        vc_breeze.season_Breeze = Season_Breeze.current_Breeze
        vc_breeze.tips_Breeze = LocalData_Breeze.shared_Breeze.seasonalTips_Breeze
            .filter { $0.season_Breeze == Season_Breeze.current_Breeze }
        vc_breeze.modalPresentationStyle = .pageSheet
        if let sheet_breeze = vc_breeze.sheetPresentationController {
            sheet_breeze.detents = [.medium(), .large()]
            sheet_breeze.prefersGrabberVisible = true
        }
        present(vc_breeze, animated: true)
    }
    
    /// 首页相册 + 按钮：仅支持选取图片（不含视频），直接存入相册
    private func addAlbumPhoto_Breeze() {
        // pickImage_Breeze 限定只选图片，不允许视频
        MediaPickerHelper_Breeze.pickImage_Breeze(from: self) { [weak self] image_breeze in
            guard let self, let image_breeze else { return }
            if let path_breeze = MediaPickerHelper_Breeze.saveImageToDocuments_Breeze(image_breeze: image_breeze) {
                UserViewModel_Breeze.shared_Breeze.addAlbumItem_Breeze(
                    imagePath_breeze: path_breeze
                )
                Utils_Breeze.showSuccess_Breeze(message_Breeze: "Added to your album!")
            }
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}
