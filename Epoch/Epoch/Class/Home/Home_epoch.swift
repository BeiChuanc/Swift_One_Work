import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页
/// 核心作用：聚合展示当前登录用户的贴纸照片墙、场景 Tips 与热门推荐轮播，帮助用户快速管理与浏览仪式灵感
/// 设计思路：去掉冗余顶部概览信息，仅保留上传入口，并通过轮播和半模态让首页交互更轻量
/// 关键属性 / 方法：
/// - reloadData_Epoch: 刷新首页全部展示数据
/// - reloadTips_Epoch: 重建可点击的场景 Tips 列表
/// - presentTipDetail_Epoch: 以底部半模态展示 Tips 详情
class Home_Epoch: UIViewController {

    /// 贴纸墙帖子
    private var momentPosts_Epoch: [TitleModel_Epoch] = []

    /// 场景贴士
    private var sceneTips_Epoch: [HomeSceneTipModel_Epoch] = []

    /// 热门轮播数据
    private var featuredItems_Epoch: [HomeFeaturedWorkItem_Epoch] = []

    /// 背景装饰
    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    /// 顶部问候横幅
    private let greetingBannerView_Epoch = HomeGreetingBannerView_Epoch()

    /// 外层滚动视图
    private let scrollView_Epoch: UIScrollView = {
        let scrollView_Epoch = UIScrollView()
        scrollView_Epoch.showsVerticalScrollIndicator = false
        scrollView_Epoch.alwaysBounceVertical = true
        return scrollView_Epoch
    }()

    /// 滚动内容容器
    private let contentView_Epoch = UIView()

    /// 贴纸墙区块标题
    private let stickerSectionTitleView_Epoch = HomeSectionTitleView_Epoch()

    /// 贴纸墙视图
    private let stickerWallView_Epoch = HomeStickerWallView_Epoch()

    /// Tips 区块标题
    private let tipsSectionTitleView_Epoch = HomeSectionTitleView_Epoch()

    /// Tips 横向滚动容器
    private let tipsScrollView_Epoch: UIScrollView = {
        let scrollView_Epoch = UIScrollView()
        scrollView_Epoch.showsHorizontalScrollIndicator = false
        scrollView_Epoch.alwaysBounceHorizontal = true
        return scrollView_Epoch
    }()

    /// Tips 横向栈
    private let tipsStackView_Epoch: UIStackView = {
        let stackView_Epoch = UIStackView()
        stackView_Epoch.axis = .horizontal
        stackView_Epoch.spacing = 12
        stackView_Epoch.alignment = .fill
        return stackView_Epoch
    }()

    /// 热门区块标题
    private let hotSectionTitleView_Epoch = HomeSectionTitleView_Epoch()

    /// 热门轮播视图
    private let hotCarouselView_Epoch = HomeHotCarouselView_Epoch()

    /// 贴纸墙高度约束（动态更新）
    private var stickerWallHeightConstraint_Epoch: Constraint?

    /// 页面即将显示时刷新状态
    /// - Parameter animated: 是否使用系统动画
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Epoch()
    }

    /// 页面加载完成后初始化视图和通知
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        setupActions_Epoch()
        setupNotifications_Epoch()
        reloadData_Epoch()
    }

    /// 页面销毁时移除通知监听
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 构建界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(greetingBannerView_Epoch)
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)

        contentView_Epoch.addSubview(stickerSectionTitleView_Epoch)
        contentView_Epoch.addSubview(stickerWallView_Epoch)
        contentView_Epoch.addSubview(tipsSectionTitleView_Epoch)
        contentView_Epoch.addSubview(tipsScrollView_Epoch)
        tipsScrollView_Epoch.addSubview(tipsStackView_Epoch)
        contentView_Epoch.addSubview(hotSectionTitleView_Epoch)
        contentView_Epoch.addSubview(hotCarouselView_Epoch)

        configureStaticContent_Epoch()

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        greetingBannerView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
        }

        scrollView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(greetingBannerView_Epoch.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        contentView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Epoch.contentLayoutGuide)
            make.width.equalTo(scrollView_Epoch.frameLayoutGuide)
        }

        stickerSectionTitleView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        stickerWallView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(stickerSectionTitleView_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            // 初始为空状态高度，数据加载后动态更新
            stickerWallHeightConstraint_Epoch = make.height.equalTo(HomeStickerWallView_Epoch.emptyStateHeight_Epoch).constraint
        }

        tipsSectionTitleView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(stickerWallView_Epoch.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
        }

        tipsScrollView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(tipsSectionTitleView_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(194)
        }

        tipsStackView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(tipsScrollView_Epoch.contentLayoutGuide).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalTo(tipsScrollView_Epoch.frameLayoutGuide)
        }

        hotSectionTitleView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(tipsScrollView_Epoch.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
        }

        hotCarouselView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(hotSectionTitleView_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(390)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    /// 配置静态文案
    private func configureStaticContent_Epoch() {
        stickerSectionTitleView_Epoch.configure_Epoch(
            title_Epoch: "My Sticker Wall",
            dotColor_Epoch: ColorConfig_Epoch.accentPurple_Epoch
        )
        tipsSectionTitleView_Epoch.configure_Epoch(
            title_Epoch: "Scene Tips",
            dotColor_Epoch: ColorConfig_Epoch.accentPink_Epoch,
            actionText_Epoch: "7 scenes"
        )
        hotSectionTitleView_Epoch.configure_Epoch(
            title_Epoch: "Hot Picks",
            dotColor_Epoch: ColorConfig_Epoch.accentGold_Epoch,
            actionText_Epoch: "Live ranking"
        )
    }

    /// 注册按钮与回调
    private func setupActions_Epoch() {
        greetingBannerView_Epoch.onAddTapped_Epoch = { [weak self] in
            self?.createPostTapped_Epoch()
        }

        stickerWallView_Epoch.onPostTapped_Epoch = { [weak self] post_epoch in
            self?.openPostDetail_Epoch(post_epoch: post_epoch)
        }
        stickerWallView_Epoch.onDeletePost_Epoch = { [weak self] post_epoch in
            guard let self = self else { return }
            ReportDeleteHelper_Epoch.delete_Epoch(post_Epoch: post_epoch, from: self) { [weak self] in
                self?.reloadData_Epoch()
            }
        }
        stickerWallView_Epoch.onAddTapped_Epoch = { [weak self] in
            self?.createPostTapped_Epoch()
        }
        stickerWallView_Epoch.onHeightChanged_Epoch = { [weak self] newHeight_epoch in
            guard let self = self else { return }
            self.stickerWallHeightConstraint_Epoch?.update(offset: newHeight_epoch)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.contentView_Epoch.layoutIfNeeded()
            }
        }

        hotCarouselView_Epoch.onCardTapped_Epoch = { [weak self] post_epoch in
            self?.openPostDetail_Epoch(post_epoch: post_epoch)
        }
        hotCarouselView_Epoch.onAuthorTapped_Epoch = { [weak self] post_epoch in
            self?.openUserInfo_Epoch(post_epoch: post_epoch)
        }
        hotCarouselView_Epoch.onLikeTapped_Epoch = { [weak self] post_epoch in
            TitleViewModel_Epoch.shared_Epoch.likePost_Epoch(post_epoch: post_epoch)
            self?.reloadData_Epoch()
        }
        hotCarouselView_Epoch.onReportTapped_Epoch = { [weak self] post_epoch in
            guard let self = self else { return }
            ReportDeleteHelper_Epoch.report_Epoch(post_Epoch: post_epoch, from: self)
        }
    }

    /// 注册通知
    private func setupNotifications_Epoch() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: TitleViewModel_Epoch.titleStateDidChangeNotification_Epoch,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch,
            object: nil
        )
    }

    /// 刷新首页数据
    private func reloadData_Epoch() {
        let titleViewModel_epoch = TitleViewModel_Epoch.shared_Epoch

        greetingBannerView_Epoch.refreshUser_Epoch()
        momentPosts_Epoch = UserViewModel_Epoch.shared_Epoch.getHomeMomentPosts_Epoch(limit_epoch: 5)
        sceneTips_Epoch = LocalData_Epoch.shared_Epoch.getHomeSceneTips_Epoch()

        let topLikedPost_epoch = titleViewModel_epoch.getMostLikedPost_Epoch()
        let mostPopularPost_epoch = titleViewModel_epoch.getMostPopularPost_Epoch(
            excludingTitleId_epoch: topLikedPost_epoch?.titleId_Epoch
        ) ?? titleViewModel_epoch.getMostPopularPost_Epoch()

        featuredItems_Epoch = []

        if let topLikedPost_epoch = topLikedPost_epoch {
            featuredItems_Epoch.append(
                HomeFeaturedWorkItem_Epoch(
                    badgeTitle_Epoch: "TOP LIKED",
                    badgeTintColor_Epoch: ColorConfig_Epoch.accentPink_Epoch,
                    post_Epoch: topLikedPost_epoch,
                    emptyTitle_Epoch: "No top liked work yet.",
                    emptySubtitle_Epoch: "Publish a new decor story to start collecting reactions."
                )
            )
        }

        if let mostPopularPost_epoch = mostPopularPost_epoch {
            featuredItems_Epoch.append(
                HomeFeaturedWorkItem_Epoch(
                    badgeTitle_Epoch: "MOST POPULAR",
                    badgeTintColor_Epoch: ColorConfig_Epoch.accentGold_Epoch,
                    post_Epoch: mostPopularPost_epoch,
                    emptyTitle_Epoch: "No popular work yet.",
                    emptySubtitle_Epoch: "Once posts gather likes and comments, the hottest reference will appear here."
                )
            )
        }

        if featuredItems_Epoch.isEmpty {
            featuredItems_Epoch = [
                HomeFeaturedWorkItem_Epoch(
                    badgeTitle_Epoch: "HOT PICKS",
                    badgeTintColor_Epoch: ColorConfig_Epoch.accentPurple_Epoch,
                    post_Epoch: nil,
                    emptyTitle_Epoch: "No hot work yet.",
                    emptySubtitle_Epoch: "Add your first decor story to start the carousel."
                )
            ]
        }

        stickerWallView_Epoch.configure_Epoch(posts_Epoch: momentPosts_Epoch)
        reloadTips_Epoch()
        hotCarouselView_Epoch.configure_Epoch(featuredItems_Epoch: featuredItems_Epoch)
    }

    /// 重建 Tips 列表
    private func reloadTips_Epoch() {
        tipsStackView_Epoch.arrangedSubviews.forEach { subview_epoch in
            tipsStackView_Epoch.removeArrangedSubview(subview_epoch)
            subview_epoch.removeFromSuperview()
        }

        for (index_epoch, tip_epoch) in sceneTips_Epoch.enumerated() {
            let tipCardView_epoch = HomeTipCardView_Epoch()
            tipCardView_epoch.configure_Epoch(tipModel_Epoch: tip_epoch, index_Epoch: index_epoch)
            tipCardView_epoch.onTapTip_Epoch = { [weak self] tappedTip_epoch in
                self?.presentTipDetail_Epoch(tipModel_Epoch: tappedTip_epoch)
            }
            tipsStackView_Epoch.addArrangedSubview(tipCardView_epoch)
            tipCardView_epoch.snp.makeConstraints { make in
                make.width.equalTo(150)
            }
        }
    }

    /// 展示 Tips 半模态详情
    /// - Parameter tipModel_Epoch: 点击的贴士模型
    private func presentTipDetail_Epoch(tipModel_Epoch: HomeSceneTipModel_Epoch) {
        let detailViewController_epoch = HomeTipDetailSheetViewController_Epoch(tipModel_Epoch: tipModel_Epoch)
        Navigation_Epoch.present_Epoch(viewController: detailViewController_epoch, from: self)
    }

    /// 打开帖子详情
    /// - Parameter post_epoch: 目标帖子
    private func openPostDetail_Epoch(post_epoch: TitleModel_Epoch) {
        Navigation_Epoch.toTitleDetail_Epoch(titleModel_epoch: post_epoch)
    }

    /// 打开用户信息页
    /// - Parameter post_epoch: 目标帖子
    private func openUserInfo_Epoch(post_epoch: TitleModel_Epoch) {
        let user_epoch = UserViewModel_Epoch.shared_Epoch.getUserById_Epoch(userId_epoch: post_epoch.titleUserId_Epoch)
        Navigation_Epoch.toUserInfo_Epoch(with: user_epoch)
    }

    /// 处理状态变化
    @objc private func handleStateChange_Epoch() {
        reloadData_Epoch()
    }

    /// 处理发布按钮点击：未登录先跳转登录页，已登录则弹出照片墙专用上传模态
    @objc private func createPostTapped_Epoch() {
        guard UserViewModel_Epoch.shared_Epoch.isLoggedIn_Epoch else {
            Navigation_Epoch.toLogin_Epoch(style_epoch: .present_epoch)
            return
        }
        let sheet_epoch = HomeAddStickerSheetViewController_Epoch()
        sheet_epoch.onStickerAdded_Epoch = { [weak self] in
            self?.reloadData_Epoch()
        }
        if let sheetPc_epoch = sheet_epoch.sheetPresentationController {
            // large 优先，确保提交按钮始终在可交互区域内
            sheetPc_epoch.detents = [.large(), .medium()]
            sheetPc_epoch.prefersGrabberVisible = true
            sheetPc_epoch.preferredCornerRadius = 24
        }
        present(sheet_epoch, animated: true)
    }
}

// MARK: - 首页问候横幅

/// 首页顶部个性化问候横幅
/// 核心作用：展示当前登录用户的头像、时间感知问候语及日期，并承载贴纸添加入口
/// 设计思路：渐变背景条 + 左侧用户信息 + 右侧 + 按钮，保持轻量不占高度
class HomeGreetingBannerView_Epoch: UIView {

    /// 渐变背景底板
    private let gradientBackView_Epoch = UIView()

    /// 用户头像
    private let avatarView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.contentMode = .scaleAspectFill
        imageView_Epoch.layer.cornerRadius = 22
        imageView_Epoch.clipsToBounds = true
        imageView_Epoch.layer.borderWidth = 2
        imageView_Epoch.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        imageView_Epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch.withAlphaComponent(0.18)
        return imageView_Epoch
    }()

    /// 头像占位图标
    private let avatarPlaceholderView_Epoch: UIImageView = {
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "person.fill", withConfiguration: config_Epoch))
        imageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch.withAlphaComponent(0.55)
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 问候语标签（"Good morning"等）
    private let greetingLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        return label_Epoch
    }()

    /// 用户名标签
    private let nameLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 日期标签
    private let dateLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        return label_Epoch
    }()

    /// 添加贴纸按钮
    private let addButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        button_Epoch.setImage(UIImage(systemName: "plus", withConfiguration: config_Epoch), for: .normal)
        button_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        button_Epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch.withAlphaComponent(0.12)
        button_Epoch.layer.cornerRadius = 22
        return button_Epoch
    }()

    /// 底部细分割线
    private let dividerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.accentBorder_Epoch.withAlphaComponent(0.6)
        return view_Epoch
    }()

    /// 点击添加回调
    var onAddTapped_Epoch: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient_Epoch()
    }

    /// 刷新当前用户信息与时间问候语
    func refreshUser_Epoch() {
        let user_epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        nameLabel_Epoch.text = user_epoch.userName_Epoch!.isEmpty ? "Explorer" : user_epoch.userName_Epoch
        greetingLabel_Epoch.text = buildGreeting_Epoch()
        dateLabel_Epoch.text = buildDateString_Epoch()

        let head_epoch = user_epoch.userHead_Epoch ?? ""
        if !head_epoch.isEmpty {
            avatarPlaceholderView_Epoch.isHidden = true
            avatarView_Epoch.image = UIImage(systemName: head_epoch)
            avatarView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch.withAlphaComponent(0.6)
        } else {
            avatarPlaceholderView_Epoch.isHidden = false
        }
    }

    /// 生成基于时间的问候语
    private func buildGreeting_Epoch() -> String {
        let hour_epoch = Calendar.current.component(.hour, from: Date())
        switch hour_epoch {
        case 5..<12: return "Good morning ☀️"
        case 12..<18: return "Good afternoon 🌤"
        case 18..<22: return "Good evening 🌙"
        default: return "Late night vibes 🌃"
        }
    }

    /// 生成当前日期字符串
    private func buildDateString_Epoch() -> String {
        let formatter_epoch = DateFormatter()
        formatter_epoch.dateFormat = "EEEE, MMMM d"
        return formatter_epoch.string(from: Date())
    }

    /// 绘制渐变背景
    private func applyGradient_Epoch() {
        gradientBackView_Epoch.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        guard gradientBackView_Epoch.bounds.size != .zero else { return }
        let gradient_epoch = CAGradientLayer()
        gradient_epoch.frame = gradientBackView_Epoch.bounds
        gradient_epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.10).cgColor,
            UIColor.clear.cgColor
        ]
        gradient_epoch.startPoint = CGPoint(x: 0, y: 0)
        gradient_epoch.endPoint = CGPoint(x: 1, y: 1)
        gradientBackView_Epoch.layer.insertSublayer(gradient_epoch, at: 0)
    }

    /// 构建视图
    private func setupUI_Epoch() {
        backgroundColor = .clear
        addSubview(gradientBackView_Epoch)
        addSubview(avatarView_Epoch)
        avatarView_Epoch.addSubview(avatarPlaceholderView_Epoch)
        addSubview(greetingLabel_Epoch)
        addSubview(nameLabel_Epoch)
        addSubview(dateLabel_Epoch)
        addSubview(addButton_Epoch)
        addSubview(dividerView_Epoch)

        gradientBackView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(dividerView_Epoch.snp.top).offset(-14)
            make.width.height.equalTo(44)
        }

        avatarPlaceholderView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        greetingLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Epoch.snp.right).offset(12)
            make.bottom.equalTo(nameLabel_Epoch.snp.top).offset(-2)
        }

        nameLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Epoch.snp.right).offset(12)
            make.centerY.equalTo(avatarView_Epoch).offset(8)
            make.right.equalTo(addButton_Epoch.snp.left).offset(-10)
        }

        dateLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Epoch.snp.right).offset(12)
            make.top.equalTo(nameLabel_Epoch.snp.bottom).offset(3)
        }

        addButton_Epoch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(avatarView_Epoch)
            make.width.height.equalTo(44)
        }

        dividerView_Epoch.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        addButton_Epoch.addTarget(self, action: #selector(addTapped_Epoch), for: .touchUpInside)
        refreshUser_Epoch()
    }

    /// 处理添加按钮点击
    @objc private func addTapped_Epoch() {
        UIView.animate(withDuration: 0.15, animations: {
            self.addButton_Epoch.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }, completion: { _ in
            UIView.animate(withDuration: 0.16) {
                self.addButton_Epoch.transform = .identity
            }
        })
        onAddTapped_Epoch?()
    }
}

// MARK: - 首页区块标题行

/// 首页紧凑区块标题行
/// 核心作用：以轻量单行形式分隔并标识各内容区块，减少视觉噪音
/// 设计思路：左侧彩色圆点 + 粗体标题 + 细分割线，右侧可选文字标签
class HomeSectionTitleView_Epoch: UIView {

    /// 左侧彩色圆点
    private let dotView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.layer.cornerRadius = 4
        return view_Epoch
    }()

    /// 主标题
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 右侧辅助文字标签
    private let actionLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.isHidden = true
        return label_Epoch
    }()

    /// 底部细分割线
    private let lineView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.accentBorder_Epoch.withAlphaComponent(0.5)
        return view_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置区块标题
    /// - Parameters:
    ///   - title_Epoch: 标题文字
    ///   - dotColor_Epoch: 圆点颜色
    ///   - actionText_Epoch: 右侧文字，传 nil 则隐藏
    func configure_Epoch(title_Epoch: String, dotColor_Epoch: UIColor, actionText_Epoch: String? = nil) {
        titleLabel_Epoch.text = title_Epoch
        dotView_Epoch.backgroundColor = dotColor_Epoch
        lineView_Epoch.backgroundColor = dotColor_Epoch.withAlphaComponent(0.18)
        if let actionText_Epoch = actionText_Epoch {
            actionLabel_Epoch.text = actionText_Epoch
            actionLabel_Epoch.isHidden = false
        } else {
            actionLabel_Epoch.isHidden = true
        }
    }

    /// 构建布局
    private func setupUI_Epoch() {
        backgroundColor = .clear
        addSubview(dotView_Epoch)
        addSubview(titleLabel_Epoch)
        addSubview(actionLabel_Epoch)
        addSubview(lineView_Epoch)

        dotView_Epoch.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(titleLabel_Epoch)
            make.width.height.equalTo(8)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(dotView_Epoch.snp.right).offset(10)
        }

        actionLabel_Epoch.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(titleLabel_Epoch)
        }

        lineView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - 首页贴纸墙

/// 首页贴纸墙视图
/// 核心作用：以不规则照片墙形式承载用户上传的布置作品，强化“贴纸记录瞬间”的首页感知
/// 设计思路：使用预设布局与轻微旋转制造手工拼贴效果，并在卡片四角叠加胶条装饰
class HomeStickerWallView_Epoch: UIView {

    /// 有数据时的完整高度
    static let preferredHeight_Epoch: CGFloat = 560

    /// 空状态时的紧凑高度（横向 banner 样式，不遮盖下方内容）
    static let emptyStateHeight_Epoch: CGFloat = 120

    /// 最大贴纸数量
    private let maxStickerCount_Epoch = 5

    /// 当前帖子
    private var posts_Epoch: [TitleModel_Epoch] = []

    /// 贴纸卡片数组
    private var stickerCardViews_Epoch: [HomeStickerCardView_Epoch] = []

    /// 空状态容器（严格裁剪，不溢出到下方区域）
    private let emptyStateView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.isHidden = true
        view_Epoch.clipsToBounds = true
        return view_Epoch
    }()

    /// 幽灵贴纸卡片（3 张，仿真实布局但半透明）
    private var ghostStickerViews_Epoch: [UIView] = []

    /// 邀请卡片外层（白色圆角卡，带阴影）
    private let inviteCardView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = UIColor.white
        view_Epoch.layer.cornerRadius = 28
        view_Epoch.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        view_Epoch.layer.shadowOffset = CGSize(width: 0, height: 8)
        view_Epoch.layer.shadowRadius = 24
        view_Epoch.layer.shadowOpacity = 1
        return view_Epoch
    }()

    /// 邀请卡片顶部渐变背景
    private let inviteGradientWrapView_Epoch = UIView()

    /// 邀请区图标背景圆
    private let inviteIconBubbleView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        view_Epoch.layer.cornerRadius = 26
        return view_Epoch
    }()

    /// 邀请区图标
    private let inviteIconImageView_Epoch: UIImageView = {
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "plus.viewfinder", withConfiguration: config_Epoch))
        imageView_Epoch.tintColor = UIColor.white
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 邀请区装饰星星
    private let inviteSparkleView_Epoch: UIImageView = {
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: config_Epoch))
        imageView_Epoch.tintColor = UIColor.white.withAlphaComponent(0.65)
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 邀请标题（紧凑横向布局）
    private let inviteTitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.textAlignment = .left
        label_Epoch.text = "Pin your first moment"
        return label_Epoch
    }()

    /// 邀请副标题（紧凑横向布局，单行）
    private let inviteSubLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.textAlignment = .left
        label_Epoch.numberOfLines = 1
        label_Epoch.text = "Add a photo & caption to get started"
        return label_Epoch
    }()

    /// 步骤提示行
    private let stepRowView_Epoch = UIView()

    /// 步骤点 1
    private let step1DotView_Epoch = UIView()

    /// 步骤文字 1
    private let step1Label_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.text = "Tap  +  to add a sticker"
        return label_Epoch
    }()

    /// 步骤点 2
    private let step2DotView_Epoch = UIView()

    /// 步骤文字 2
    private let step2Label_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.text = "Share a photo & caption"
        return label_Epoch
    }()

    /// 空状态添加按钮（紧凑胶囊样式，白色文字适配渐变背景）
    private let emptyAddButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        button_Epoch.setTitle("Start →", for: .normal)
        button_Epoch.setTitleColor(.white, for: .normal)
        button_Epoch.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button_Epoch.layer.cornerRadius = 18
        button_Epoch.layer.borderWidth = 1
        button_Epoch.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return button_Epoch
    }()

    /// 点击贴纸回调
    var onPostTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 长按贴纸触发删除回调
    var onDeletePost_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击空状态添加按钮回调
    var onAddTapped_Epoch: (() -> Void)?

    /// 高度变化回调（父视图据此更新约束）
    var onHeightChanged_Epoch: ((CGFloat) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCards_Epoch()
        layoutEmptyState_Epoch()
    }

    /// 配置贴纸墙内容；无帖子时展示空状态并通知父视图收缩高度
    /// - Parameter posts_Epoch: 帖子列表
    func configure_Epoch(posts_Epoch: [TitleModel_Epoch]) {
        self.posts_Epoch = Array(posts_Epoch.prefix(maxStickerCount_Epoch))
        let isEmpty_epoch = self.posts_Epoch.isEmpty

        emptyStateView_Epoch.isHidden = !isEmpty_epoch
        stickerCardViews_Epoch.forEach { $0.isHidden = isEmpty_epoch }

        // 通知父视图动态调整高度
        let targetHeight_epoch = isEmpty_epoch
            ? HomeStickerWallView_Epoch.emptyStateHeight_Epoch
            : HomeStickerWallView_Epoch.preferredHeight_Epoch
        onHeightChanged_Epoch?(targetHeight_epoch)

        guard !isEmpty_epoch else { return }

        for (index_epoch, cardView_epoch) in stickerCardViews_Epoch.enumerated() {
            if index_epoch < self.posts_Epoch.count {
                let post_epoch = self.posts_Epoch[index_epoch]
                cardView_epoch.isHidden = false
                cardView_epoch.configure_Epoch(post_Epoch: post_epoch)
                cardView_epoch.onTapPost_Epoch = { [weak self] tappedPost_epoch in
                    self?.onPostTapped_Epoch?(tappedPost_epoch)
                }
                cardView_epoch.onDeleteTapped_Epoch = { [weak self] tappedPost_epoch in
                    self?.onDeletePost_Epoch?(tappedPost_epoch)
                }
            } else {
                cardView_epoch.isHidden = true
            }
        }
        setNeedsLayout()
    }

    /// 初始化贴纸墙与空状态
    private func setupUI_Epoch() {
        backgroundColor = .clear

        for _ in 0..<maxStickerCount_Epoch {
            let stickerCardView_epoch = HomeStickerCardView_Epoch()
            stickerCardViews_Epoch.append(stickerCardView_epoch)
            addSubview(stickerCardView_epoch)
        }

        addSubview(emptyStateView_Epoch)
        emptyStateView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupCompactEmptyBanner_Epoch()
    }

    /// 构建紧凑横向空状态 banner
    /// 设计：渐变圆角卡 + 左侧图标圆 + 中间标题/副标题 + 右侧胶囊按钮，严格控制在 emptyStateHeight 内不溢出
    private func setupCompactEmptyBanner_Epoch() {
        // 外层容器（渐变背景 = inviteGradientWrapView）
        emptyStateView_Epoch.addSubview(inviteCardView_Epoch)
        inviteCardView_Epoch.backgroundColor = .clear
        inviteCardView_Epoch.layer.cornerRadius = 20
        inviteCardView_Epoch.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        inviteCardView_Epoch.layer.shadowOffset = CGSize(width: 0, height: 4)
        inviteCardView_Epoch.layer.shadowRadius = 12
        inviteCardView_Epoch.layer.shadowOpacity = 1

        // 渐变填充整个卡片背景
        inviteCardView_Epoch.addSubview(inviteGradientWrapView_Epoch)
        inviteGradientWrapView_Epoch.layer.cornerRadius = 20
        inviteGradientWrapView_Epoch.clipsToBounds = true

        // 左侧图标区
        inviteCardView_Epoch.addSubview(inviteIconBubbleView_Epoch)
        inviteIconBubbleView_Epoch.addSubview(inviteIconImageView_Epoch)

        // 中间文字
        inviteCardView_Epoch.addSubview(inviteTitleLabel_Epoch)
        inviteCardView_Epoch.addSubview(inviteSubLabel_Epoch)

        // 右侧按钮
        inviteCardView_Epoch.addSubview(emptyAddButton_Epoch)

        // 外卡片填满 emptyStateView（留 8pt 竖向边距给阴影）
        inviteCardView_Epoch.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview()
        }

        // 渐变背景填满卡片
        inviteGradientWrapView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 左侧图标圆（52×52，垂直居中）
        inviteIconBubbleView_Epoch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }

        inviteIconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        // 右侧按钮（小胶囊，垂直居中）
        emptyAddButton_Epoch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(36)
        }
        emptyAddButton_Epoch.layer.cornerRadius = 18

        // 中间文字区（夹在图标和按钮之间）
        inviteTitleLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(inviteIconBubbleView_Epoch.snp.right).offset(14)
            make.right.equalTo(emptyAddButton_Epoch.snp.left).offset(-10)
            make.bottom.equalTo(inviteCardView_Epoch.snp.centerY).offset(-2)
        }

        inviteSubLabel_Epoch.snp.makeConstraints { make in
            make.left.right.equalTo(inviteTitleLabel_Epoch)
            make.top.equalTo(inviteTitleLabel_Epoch.snp.bottom).offset(4)
        }

        emptyAddButton_Epoch.addTarget(self, action: #selector(emptyAddTapped_Epoch), for: .touchUpInside)
    }

    /// 在 layout 阶段更新空状态 banner 的渐变层尺寸
    private func layoutEmptyState_Epoch() {
        guard emptyStateView_Epoch.bounds.width > 0 else { return }
        applyInviteGradient_Epoch()
        applyAddButtonGradient_Epoch()
    }

    /// 为 banner 背景绘制左→右轻柔渐变
    private func applyInviteGradient_Epoch() {
        inviteGradientWrapView_Epoch.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        guard inviteGradientWrapView_Epoch.bounds.size != .zero else { return }
        let gradient_epoch = CAGradientLayer()
        gradient_epoch.frame = inviteGradientWrapView_Epoch.bounds
        gradient_epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.85).cgColor,
            ColorConfig_Epoch.primaryGradientEnd_Epoch.withAlphaComponent(0.72).cgColor
        ]
        gradient_epoch.startPoint = CGPoint(x: 0, y: 0)
        gradient_epoch.endPoint = CGPoint(x: 1, y: 1)
        gradient_epoch.cornerRadius = 20
        inviteGradientWrapView_Epoch.layer.insertSublayer(gradient_epoch, at: 0)
    }

    /// 为添加按钮绘制白色半透明背景（横向 banner 上用白色按钮更清晰）
    private func applyAddButtonGradient_Epoch() {
        emptyAddButton_Epoch.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        guard emptyAddButton_Epoch.bounds.size != .zero else { return }
        let gradient_epoch = CAGradientLayer()
        gradient_epoch.frame = emptyAddButton_Epoch.bounds
        gradient_epoch.colors = [
            UIColor.white.withAlphaComponent(0.30).cgColor,
            UIColor.white.withAlphaComponent(0.22).cgColor
        ]
        gradient_epoch.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_epoch.endPoint = CGPoint(x: 1, y: 0.5)
        gradient_epoch.cornerRadius = 18
        emptyAddButton_Epoch.layer.insertSublayer(gradient_epoch, at: 0)
    }

    // 已废弃，保留方法签名避免编译报错（layoutEmptyState_Epoch 中不再调用）
    private func layoutGhostStickers_Epoch() {
        let width_epoch = emptyStateView_Epoch.bounds.width
        guard width_epoch > 0 else { return }

        let frames_epoch: [CGRect] = [
            CGRect(x: 6, y: 18, width: width_epoch * 0.38, height: 180),
            CGRect(x: width_epoch * 0.55, y: 8, width: width_epoch * 0.38, height: 155),
            CGRect(x: width_epoch * 0.60, y: 390, width: width_epoch * 0.34, height: 160)
        ]

        for (index_epoch, ghost_epoch) in ghostStickerViews_Epoch.enumerated() {
            guard index_epoch < frames_epoch.count else { continue }
            ghost_epoch.frame = frames_epoch[index_epoch]
        }
    }

    /// 处理空状态添加点击
    @objc private func emptyAddTapped_Epoch() {
        onAddTapped_Epoch?()
    }

    /// 计算不规则贴纸布局
    private func layoutCards_Epoch() {
        guard bounds.width > 0 else { return }

        let width_epoch = bounds.width
        let layoutFrames_epoch: [CGRect] = [
            CGRect(x: 4, y: 14, width: width_epoch * 0.42, height: 214),
            CGRect(x: width_epoch * 0.49, y: 0, width: width_epoch * 0.43, height: 180),
            CGRect(x: width_epoch * 0.09, y: 230, width: width_epoch * 0.33, height: 150),
            CGRect(x: width_epoch * 0.53, y: 206, width: width_epoch * 0.36, height: 220),
            CGRect(x: width_epoch * 0.20, y: 392, width: width_epoch * 0.46, height: 154)
        ]
        let rotationAngles_epoch: [CGFloat] = [-0.08, 0.07, 0.05, -0.06, 0.06]

        for (index_epoch, cardView_epoch) in stickerCardViews_Epoch.enumerated() {
            guard index_epoch < layoutFrames_epoch.count else { continue }
            cardView_epoch.frame = layoutFrames_epoch[index_epoch]
            cardView_epoch.applyRotation_Epoch(angle_Epoch: rotationAngles_epoch[index_epoch])
            bringSubviewToFront(cardView_epoch)
        }
    }
}

// MARK: - 首页贴纸卡片

/// 首页贴纸卡片
/// 核心作用：展示单个布置成果的图片、标题和描述，并以胶条样式强调手工贴纸氛围
/// 设计思路：卡片本体使用纸张质感与圆角阴影，四角胶条通过半透明小块实现，保证视觉层次与点击区域清晰
class HomeStickerCardView_Epoch: UIControl {

    /// 卡片内容容器
    private let paperView_Epoch = UIView()

    /// 媒体视图
    private let mediaView_Epoch = MediaDisplayView_Epoch()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 作者标签
    private let authorLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.accentPurple_Epoch
        return label_Epoch
    }()

    /// 描述标签
    private let detailLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 左上胶条
    private let topLeftTapeView_Epoch = UIView()

    /// 右上胶条
    private let topRightTapeView_Epoch = UIView()

    /// 左下胶条
    private let bottomLeftTapeView_Epoch = UIView()

    /// 右下胶条
    private let bottomRightTapeView_Epoch = UIView()

    /// 右上角删除按钮（圆形胶囊，始终显示在卡片外部）
    private let deleteButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        button_Epoch.setImage(UIImage(systemName: "xmark", withConfiguration: config_Epoch), for: .normal)
        button_Epoch.tintColor = UIColor.white
        button_Epoch.backgroundColor = UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1.0)
        button_Epoch.layer.cornerRadius = 13
        button_Epoch.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        button_Epoch.layer.shadowOffset = CGSize(width: 0, height: 2)
        button_Epoch.layer.shadowRadius = 4
        button_Epoch.layer.shadowOpacity = 1
        return button_Epoch
    }()

    /// 当前帖子
    private var postModel_Epoch: TitleModel_Epoch?

    /// 点击贴纸回调
    var onTapPost_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击删除按钮回调
    var onDeleteTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 22).cgPath
    }

    /// 绑定贴纸数据
    /// - Parameter post_Epoch: 帖子模型
    func configure_Epoch(post_Epoch: TitleModel_Epoch) {
        postModel_Epoch = post_Epoch
        titleLabel_Epoch.text = post_Epoch.title_Epoch
        authorLabel_Epoch.text = "@\(post_Epoch.titleUserName_Epoch)"
        detailLabel_Epoch.text = post_Epoch.titleContent_Epoch
        mediaView_Epoch.configure_Epoch(
            mediaPath_Epoch: post_Epoch.titleMeidas_Epoch.first,
            isVideo_Epoch: isVideoMedia_Epoch(post_Epoch.titleMeidas_Epoch.first)
        )
    }

    /// 应用贴纸旋转角度
    /// - Parameter angle_Epoch: 旋转弧度
    func applyRotation_Epoch(angle_Epoch: CGFloat) {
        transform = CGAffineTransform(rotationAngle: angle_Epoch)
    }

    /// 构建贴纸卡片
    private func setupUI_Epoch() {
        backgroundColor = .clear
        layer.shadowColor = ColorConfig_Epoch.shadowColor_Epoch.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 14)
        layer.shadowOpacity = 0.14
        layer.shadowRadius = 24

        paperView_Epoch.backgroundColor = UIColor.white
        paperView_Epoch.layer.cornerRadius = 22
        paperView_Epoch.layer.borderWidth = 1
        paperView_Epoch.layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
        paperView_Epoch.clipsToBounds = true

        [topLeftTapeView_Epoch, topRightTapeView_Epoch, bottomLeftTapeView_Epoch, bottomRightTapeView_Epoch].forEach { tapeView_epoch in
            tapeView_epoch.backgroundColor = UIColor.white.withAlphaComponent(0.82)
            tapeView_epoch.layer.cornerRadius = 6
            tapeView_epoch.layer.borderWidth = 1
            tapeView_epoch.layer.borderColor = ColorConfig_Epoch.border_Epoch.withAlphaComponent(0.28).cgColor
            addSubview(tapeView_epoch)
        }

        addSubview(paperView_Epoch)
        paperView_Epoch.addSubview(mediaView_Epoch)
        paperView_Epoch.addSubview(authorLabel_Epoch)
        paperView_Epoch.addSubview(titleLabel_Epoch)
        paperView_Epoch.addSubview(detailLabel_Epoch)

        paperView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
            make.height.equalToSuperview().multipliedBy(0.56)
        }

        authorLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(14)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(authorLabel_Epoch.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(14)
        }

        detailLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview().inset(14)
        }

        layoutTapeView_Epoch(
            tapeView_Epoch: topLeftTapeView_Epoch,
            topOffset_Epoch: -8,
            leftOffset_Epoch: 14,
            angle_Epoch: -.pi / 10
        )
        layoutTapeView_Epoch(
            tapeView_Epoch: topRightTapeView_Epoch,
            topOffset_Epoch: -8,
            rightOffset_Epoch: 14,
            angle_Epoch: .pi / 12
        )
        layoutTapeView_Epoch(
            tapeView_Epoch: bottomLeftTapeView_Epoch,
            bottomOffset_Epoch: -8,
            leftOffset_Epoch: 18,
            angle_Epoch: .pi / 18
        )
        layoutTapeView_Epoch(
            tapeView_Epoch: bottomRightTapeView_Epoch,
            bottomOffset_Epoch: -8,
            rightOffset_Epoch: 18,
            angle_Epoch: -.pi / 12
        )

        // 删除按钮叠加在卡片右上角（需在 paperView 之后添加，确保显示在最上层）
        addSubview(deleteButton_Epoch)
        deleteButton_Epoch.snp.makeConstraints { make in
            make.width.height.equalTo(26)
            make.top.equalToSuperview().offset(-8)
            make.right.equalToSuperview().offset(8)
        }
        deleteButton_Epoch.addTarget(self, action: #selector(deleteTapped_Epoch), for: .touchUpInside)

        addTarget(self, action: #selector(touchDown_Epoch), for: .touchDown)
        addTarget(self, action: #selector(touchEnd_Epoch), for: [.touchCancel, .touchDragExit, .touchUpOutside])
        addTarget(self, action: #selector(tapped_Epoch), for: .touchUpInside)
    }

    /// 布置胶条视图
    /// - Parameters:
    ///   - tapeView_Epoch: 胶条视图
    ///   - topOffset_Epoch: 顶部偏移
    ///   - bottomOffset_Epoch: 底部偏移
    ///   - leftOffset_Epoch: 左侧偏移
    ///   - rightOffset_Epoch: 右侧偏移
    ///   - angle_Epoch: 旋转角度
    private func layoutTapeView_Epoch(
        tapeView_Epoch: UIView,
        topOffset_Epoch: CGFloat? = nil,
        bottomOffset_Epoch: CGFloat? = nil,
        leftOffset_Epoch: CGFloat? = nil,
        rightOffset_Epoch: CGFloat? = nil,
        angle_Epoch: CGFloat
    ) {
        tapeView_Epoch.transform = CGAffineTransform(rotationAngle: angle_Epoch)
        tapeView_Epoch.snp.makeConstraints { make in
            if let topOffset_Epoch = topOffset_Epoch {
                make.top.equalToSuperview().offset(topOffset_Epoch)
            }
            if let bottomOffset_Epoch = bottomOffset_Epoch {
                make.bottom.equalToSuperview().offset(bottomOffset_Epoch)
            }
            if let leftOffset_Epoch = leftOffset_Epoch {
                make.left.equalToSuperview().offset(leftOffset_Epoch)
            }
            if let rightOffset_Epoch = rightOffset_Epoch {
                make.right.equalToSuperview().offset(-rightOffset_Epoch)
            }
            make.width.equalTo(42)
            make.height.equalTo(18)
        }
    }

    /// 判断媒体是否为视频
    /// - Parameter mediaPath_Epoch: 媒体路径
    /// - Returns: 是否为视频
    private func isVideoMedia_Epoch(_ mediaPath_Epoch: String?) -> Bool {
        guard let mediaPath_Epoch = mediaPath_Epoch?.lowercased() else { return false }
        return mediaPath_Epoch.hasSuffix(".mov")
            || mediaPath_Epoch.hasSuffix(".mp4")
            || mediaPath_Epoch.hasSuffix(".m4v")
            || mediaPath_Epoch.contains("video")
    }

    /// 处理按下态
    @objc private func touchDown_Epoch() {
        UIView.animate(withDuration: 0.18) {
            self.alpha = 0.92
        }
    }

    /// 处理按压结束
    @objc private func touchEnd_Epoch() {
        UIView.animate(withDuration: 0.18) {
            self.alpha = 1.0
        }
    }

    /// 处理点击事件
    @objc private func tapped_Epoch() {
        UIView.animate(withDuration: 0.18) {
            self.alpha = 1.0
        }
        guard let postModel_Epoch else { return }
        onTapPost_Epoch?(postModel_Epoch)
    }

    /// 处理右上角删除按钮点击
    @objc private func deleteTapped_Epoch() {
        guard let postModel_Epoch else { return }
        onDeleteTapped_Epoch?(postModel_Epoch)
    }
}

// MARK: - 首页场景 Tips 卡片

/// 顶部渐变区自管理视图
/// 核心作用：在自身 layoutSubviews 中维护 CAGradientLayer，确保 bounds 可用时渐变正确绘制
private class HomeTipGradientTopView_Epoch: UIView {

    private let gradientLayer_Epoch = CAGradientLayer()

    /// 渐变色对，赋值后立即更新 colors
    var gradientColors_Epoch: (UIColor, UIColor) = (.clear, .clear) {
        didSet { updateGradient_Epoch() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        gradientLayer_Epoch.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Epoch.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer_Epoch, at: 0)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Epoch.frame = bounds
    }

    private func updateGradient_Epoch() {
        gradientLayer_Epoch.colors = [gradientColors_Epoch.0.cgColor, gradientColors_Epoch.1.cgColor]
    }
}

/// 首页场景 Tips 卡片
/// 核心作用：以全彩顶部图标区 + 白色底部信息区展示单个仪式场景贴士
/// 设计思路：顶部渐变区承载大图标，使卡片在横向列表中具有强烈视觉辨识度；底部仅呈现名称和操作提示
class HomeTipCardView_Epoch: UIView {

    /// 外层容器（圆角卡，阴影）
    private let cardView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = .white
        view_Epoch.layer.cornerRadius = 24
        view_Epoch.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        view_Epoch.layer.shadowOffset = CGSize(width: 0, height: 6)
        view_Epoch.layer.shadowRadius = 16
        view_Epoch.layer.shadowOpacity = 1
        return view_Epoch
    }()

    /// 顶部彩色渐变区（自管理渐变）
    private let colorTopView_Epoch = HomeTipGradientTopView_Epoch()

    /// 场景名胶囊（叠加在顶部区左上角）
    private let sceneBadgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_Epoch.textColor = .white
        label_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.26)
        label_Epoch.horizontalInset_Epoch = 8
        label_Epoch.verticalInset_Epoch = 4
        label_Epoch.layer.cornerRadius = 9
        label_Epoch.clipsToBounds = true
        return label_Epoch
    }()

    /// 大图标（居中于顶部区）
    private let iconImageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.tintColor = .white
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 图标圆形底板（轻柔半透明圆）
    private let iconCircleView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        view_Epoch.layer.cornerRadius = 30
        return view_Epoch
    }()

    /// 场景标题
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 底部"查看"行
    private let viewHintLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Epoch.text = "Tap to explore →"
        return label_Epoch
    }()

    /// 当前 Tips 模型
    private var tipModel_Epoch: HomeSceneTipModel_Epoch?

    /// 点击回调
    var onTapTip_Epoch: ((HomeSceneTipModel_Epoch) -> Void)?

    /// 场景色调映射（7 种渐变配色）
    private static let sceneGradients_Epoch: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Epoch: "#F093FB"), UIColor(hexstring_Epoch: "#F5576C")),
        (UIColor(hexstring_Epoch: "#FDB99B"), UIColor(hexstring_Epoch: "#F06B3C")),
        (UIColor(hexstring_Epoch: "#B794F6"), UIColor(hexstring_Epoch: "#667EEA")),
        (UIColor(hexstring_Epoch: "#63B3ED"), UIColor(hexstring_Epoch: "#4299E1")),
        (UIColor(hexstring_Epoch: "#81E6D9"), UIColor(hexstring_Epoch: "#38B2AC")),
        (UIColor(hexstring_Epoch: "#FBD786"), UIColor(hexstring_Epoch: "#F7797D")),
        (UIColor(hexstring_Epoch: "#C3CFE2"), UIColor(hexstring_Epoch: "#9FA8DA"))
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView_Epoch.layer.shadowPath = UIBezierPath(roundedRect: cardView_Epoch.bounds, cornerRadius: 24).cgPath
    }

    /// 绑定 Tips 数据
    /// - Parameters:
    ///   - tipModel_Epoch: 贴士模型
    ///   - index_Epoch: 列表索引，用于分配渐变色
    func configure_Epoch(tipModel_Epoch: HomeSceneTipModel_Epoch, index_Epoch: Int = 0) {
        self.tipModel_Epoch = tipModel_Epoch
        let gradientPair_epoch = HomeTipCardView_Epoch.sceneGradients_Epoch[index_Epoch % HomeTipCardView_Epoch.sceneGradients_Epoch.count]

        // 直接赋值触发自管理渐变视图更新
        colorTopView_Epoch.gradientColors_Epoch = gradientPair_epoch
        viewHintLabel_Epoch.textColor = gradientPair_epoch.0

        sceneBadgeLabel_Epoch.text = tipModel_Epoch.sceneName_Epoch
        titleLabel_Epoch.text = tipModel_Epoch.tipTitle_Epoch
        let iconConfig_epoch = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iconImageView_Epoch.image = UIImage(systemName: tipModel_Epoch.iconName_Epoch,
                                            withConfiguration: iconConfig_epoch)
    }

    /// 构建 Tips 卡片布局
    private func setupUI_Epoch() {
        backgroundColor = .clear
        addSubview(cardView_Epoch)
        cardView_Epoch.addSubview(colorTopView_Epoch)
        colorTopView_Epoch.addSubview(iconCircleView_Epoch)
        iconCircleView_Epoch.addSubview(iconImageView_Epoch)
        colorTopView_Epoch.addSubview(sceneBadgeLabel_Epoch)
        cardView_Epoch.addSubview(titleLabel_Epoch)
        cardView_Epoch.addSubview(viewHintLabel_Epoch)

        cardView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0))
        }

        colorTopView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(100)
        }

        iconCircleView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }

        sceneBadgeLabel_Epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(colorTopView_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(14)
        }

        viewHintLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().inset(14)
        }

        let tapGesture_epoch = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Epoch))
        addGestureRecognizer(tapGesture_epoch)
    }

    /// 处理 Tips 点击
    @objc private func cardTapped_Epoch() {
        UIView.animate(withDuration: 0.14, animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.16) { self.transform = .identity }
        })
        guard let tipModel_Epoch = tipModel_Epoch else { return }
        onTapTip_Epoch?(tipModel_Epoch)
    }
}

// MARK: - 首页热门轮播模型

/// 首页热门轮播数据模型
/// 核心作用：统一描述轮播中的标签样式、帖子实体和空状态文案
struct HomeFeaturedWorkItem_Epoch {

    /// 标签标题
    let badgeTitle_Epoch: String

    /// 标签强调色
    let badgeTintColor_Epoch: UIColor

    /// 关联帖子
    let post_Epoch: TitleModel_Epoch?

    /// 空状态标题
    let emptyTitle_Epoch: String

    /// 空状态说明
    let emptySubtitle_Epoch: String
}

// MARK: - 首页热门轮播

/// 首页热门轮播视图
/// 核心作用：以横向分页轮播展示首页热门推荐作品
/// 设计思路：使用分页集合视图与页码指示器承载热门卡片，并在多条数据时自动轮播
class HomeHotCarouselView_Epoch: UIView {

    /// 热门数据
    private var featuredItems_Epoch: [HomeFeaturedWorkItem_Epoch] = []

    /// 轮播定时器
    private var autoScrollTimer_Epoch: Timer?

    /// 集合视图
    private lazy var collectionView_Epoch: UICollectionView = {
        let layout_epoch = UICollectionViewFlowLayout()
        layout_epoch.scrollDirection = .horizontal
        layout_epoch.minimumLineSpacing = 0
        layout_epoch.minimumInteritemSpacing = 0
        let collectionView_epoch = UICollectionView(frame: .zero, collectionViewLayout: layout_epoch)
        collectionView_epoch.backgroundColor = .clear
        collectionView_epoch.showsHorizontalScrollIndicator = false
        collectionView_epoch.isPagingEnabled = true
        collectionView_epoch.decelerationRate = .fast
        return collectionView_epoch
    }()

    /// 页码指示器
    private let pageControl_Epoch: UIPageControl = {
        let pageControl_Epoch = UIPageControl()
        pageControl_Epoch.currentPageIndicatorTintColor = ColorConfig_Epoch.accentPurple_Epoch
        pageControl_Epoch.pageIndicatorTintColor = ColorConfig_Epoch.border_Epoch.withAlphaComponent(0.6)
        pageControl_Epoch.hidesForSinglePage = true
        return pageControl_Epoch
    }()

    /// 点击整卡进详情回调
    var onCardTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击作者回调
    var onAuthorTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击点赞回调
    var onLikeTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击举报按钮回调
    var onReportTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopAutoScroll_Epoch()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout_epoch = collectionView_Epoch.collectionViewLayout as? UICollectionViewFlowLayout {
            layout_epoch.itemSize = collectionView_Epoch.bounds.size
        }
    }

    /// 绑定轮播数据
    /// - Parameter featuredItems_Epoch: 热门轮播列表
    func configure_Epoch(featuredItems_Epoch: [HomeFeaturedWorkItem_Epoch]) {
        self.featuredItems_Epoch = featuredItems_Epoch
        pageControl_Epoch.numberOfPages = featuredItems_Epoch.count
        pageControl_Epoch.currentPage = 0
        collectionView_Epoch.setContentOffset(.zero, animated: false)
        collectionView_Epoch.reloadData()
        restartAutoScroll_Epoch()
    }

    /// 构建轮播界面
    private func setupUI_Epoch() {
        backgroundColor = .clear
        addSubview(collectionView_Epoch)
        addSubview(pageControl_Epoch)

        collectionView_Epoch.dataSource = self
        collectionView_Epoch.delegate = self
        collectionView_Epoch.register(HomeHotCarouselCell_Epoch.self, forCellWithReuseIdentifier: "HomeHotCarouselCell_Epoch")

        collectionView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(360)
        }

        pageControl_Epoch.snp.makeConstraints { make in
            make.top.equalTo(collectionView_Epoch.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    /// 重启自动轮播
    private func restartAutoScroll_Epoch() {
        stopAutoScroll_Epoch()
        guard featuredItems_Epoch.count > 1 else { return }
        autoScrollTimer_Epoch = Timer.scheduledTimer(
            timeInterval: 3.8,
            target: self,
            selector: #selector(handleAutoScroll_Epoch),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(autoScrollTimer_Epoch!, forMode: .common)
    }

    /// 停止自动轮播
    private func stopAutoScroll_Epoch() {
        autoScrollTimer_Epoch?.invalidate()
        autoScrollTimer_Epoch = nil
    }

    /// 处理自动轮播
    @objc private func handleAutoScroll_Epoch() {
        guard featuredItems_Epoch.count > 1 else { return }
        let nextIndex_epoch = (pageControl_Epoch.currentPage + 1) % featuredItems_Epoch.count
        let targetIndexPath_epoch = IndexPath(item: nextIndex_epoch, section: 0)
        collectionView_Epoch.scrollToItem(at: targetIndexPath_epoch, at: .centeredHorizontally, animated: true)
        pageControl_Epoch.currentPage = nextIndex_epoch
    }
}

extension HomeHotCarouselView_Epoch: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredItems_Epoch.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_epoch = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeHotCarouselCell_Epoch", for: indexPath) as? HomeHotCarouselCell_Epoch else {
            return UICollectionViewCell()
        }
        let featuredItem_epoch = featuredItems_Epoch[indexPath.item]
        cell_epoch.hotCardView_Epoch.configure_Epoch(featuredItem_Epoch: featuredItem_epoch)
        cell_epoch.hotCardView_Epoch.onCardTapped_Epoch = { [weak self] post_epoch in
            self?.onCardTapped_Epoch?(post_epoch)
        }
        cell_epoch.hotCardView_Epoch.onAuthorTapped_Epoch = { [weak self] post_epoch in
            self?.onAuthorTapped_Epoch?(post_epoch)
        }
        cell_epoch.hotCardView_Epoch.onLikeTapped_Epoch = { [weak self] post_epoch in
            self?.onLikeTapped_Epoch?(post_epoch)
        }
        cell_epoch.hotCardView_Epoch.onReportTapped_Epoch = { [weak self] post_epoch in
            self?.onReportTapped_Epoch?(post_epoch)
        }
        return cell_epoch
    }
}

extension HomeHotCarouselView_Epoch: UICollectionViewDelegate, UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll_Epoch()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCurrentPage_Epoch(scrollView_Epoch: scrollView)
            restartAutoScroll_Epoch()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage_Epoch(scrollView_Epoch: scrollView)
        restartAutoScroll_Epoch()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPage_Epoch(scrollView_Epoch: scrollView)
    }

    /// 更新当前页码
    /// - Parameter scrollView_Epoch: 滚动视图
    private func updateCurrentPage_Epoch(scrollView_Epoch: UIScrollView) {
        guard scrollView_Epoch.bounds.width > 0 else { return }
        let page_epoch = Int(round(scrollView_Epoch.contentOffset.x / scrollView_Epoch.bounds.width))
        pageControl_Epoch.currentPage = max(0, min(page_epoch, featuredItems_Epoch.count - 1))
    }
}

/// 首页热门轮播单元格
/// 核心作用：承载单页热门卡片内容
class HomeHotCarouselCell_Epoch: UICollectionViewCell {

    /// 热门卡片
    let hotCardView_Epoch = HomeHotCardView_Epoch()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(hotCardView_Epoch)
        hotCardView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 首页热门卡片

/// 首页热门卡片
/// 核心作用：展示首页实时热门作品，媒体封面全宽铺满顶部，叠加标签胶囊与举报按钮，整卡点击进入帖子详情
/// 设计思路：移除独立"Open"按钮，整卡设置点击手势以获得更大触发区域；举报按钮复用 ReportDeleteHelper
/// 关键属性 / 方法：
/// - configure_Epoch: 绑定轮播数据或空状态
/// - onCardTapped_Epoch / onAuthorTapped_Epoch / onLikeTapped_Epoch / onReportTapped_Epoch: 各交互回调
class HomeHotCardView_Epoch: UIView {

    /// 内容容器
    private let containerView_Epoch = SurfaceCardView_Epoch()

    /// 媒体封面（全宽顶部，使用 MediaDisplayView）
    private let mediaView_Epoch: MediaDisplayView_Epoch = {
        let view_Epoch = MediaDisplayView_Epoch()
        view_Epoch.layer.cornerRadius = 20
        view_Epoch.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view_Epoch.clipsToBounds = true
        return view_Epoch
    }()

    /// 媒体底部渐变遮罩
    private let mediaGradientView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.isUserInteractionEnabled = false
        return view_Epoch
    }()

    /// 标签胶囊（叠加在媒体左上角）
    private let badgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Epoch.horizontalInset_Epoch = 12
        label_Epoch.verticalInset_Epoch = 7
        label_Epoch.layer.cornerRadius = 13
        label_Epoch.clipsToBounds = true
        return label_Epoch
    }()

    /// 举报按钮（叠加在媒体右上角）
    private let reportButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        button_Epoch.setImage(UIImage(systemName: "ellipsis", withConfiguration: config_Epoch), for: .normal)
        button_Epoch.tintColor = .white
        button_Epoch.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        button_Epoch.layer.cornerRadius = 15
        return button_Epoch
    }()

    /// 空状态占位容器
    private let emptyContainerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.isHidden = true
        return view_Epoch
    }()

    /// 空状态图标
    private let emptyIconView_Epoch: UIImageView = {
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: config_Epoch))
        imageView_Epoch.tintColor = ColorConfig_Epoch.textPlaceholder_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 空状态标题
    private let emptyTitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        label_Epoch.textAlignment = .center
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 1
        return label_Epoch
    }()

    /// 摘要标签
    private let summaryLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 互动底部行
    private let bottomRowView_Epoch = UIView()

    /// 作者按钮
    private let authorButton_Epoch = UIButton(type: .system)

    /// 点赞按钮
    private let likeButton_Epoch = UIButton(type: .system)

    /// 当前帖子
    private var postModel_Epoch: TitleModel_Epoch?

    /// 点击整卡进详情回调
    var onCardTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击作者回调
    var onAuthorTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击点赞回调
    var onLikeTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    /// 点击举报按钮回调（由外部 VC 调用 ReportDeleteHelper 处理）
    var onReportTapped_Epoch: ((TitleModel_Epoch) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyMediaGradient_Epoch()
    }

    /// 绑定热门轮播数据
    /// - Parameter featuredItem_Epoch: 热门轮播项
    func configure_Epoch(featuredItem_Epoch: HomeFeaturedWorkItem_Epoch) {
        postModel_Epoch = featuredItem_Epoch.post_Epoch
        badgeLabel_Epoch.text = featuredItem_Epoch.badgeTitle_Epoch
        badgeLabel_Epoch.textColor = featuredItem_Epoch.badgeTintColor_Epoch
        badgeLabel_Epoch.backgroundColor = featuredItem_Epoch.badgeTintColor_Epoch.withAlphaComponent(0.18)

        guard let post_Epoch = featuredItem_Epoch.post_Epoch else {
            mediaView_Epoch.isHidden = true
            mediaGradientView_Epoch.isHidden = true
            reportButton_Epoch.isHidden = true
            emptyContainerView_Epoch.isHidden = false
            badgeLabel_Epoch.isHidden = true
            titleLabel_Epoch.isHidden = true
            summaryLabel_Epoch.isHidden = true
            bottomRowView_Epoch.isHidden = true
            emptyTitleLabel_Epoch.text = featuredItem_Epoch.emptyTitle_Epoch
            return
        }

        mediaView_Epoch.isHidden = false
        mediaGradientView_Epoch.isHidden = false
        reportButton_Epoch.isHidden = false
        emptyContainerView_Epoch.isHidden = true
        badgeLabel_Epoch.isHidden = false
        titleLabel_Epoch.isHidden = false
        summaryLabel_Epoch.isHidden = false
        bottomRowView_Epoch.isHidden = false

        titleLabel_Epoch.text = post_Epoch.title_Epoch
        summaryLabel_Epoch.text = post_Epoch.titleContent_Epoch
        authorButton_Epoch.setTitle("@\(post_Epoch.titleUserName_Epoch)", for: .normal)
        mediaView_Epoch.configure_Epoch(
            mediaPath_Epoch: post_Epoch.titleMeidas_Epoch.first,
            isVideo_Epoch: isVideoMedia_Epoch(post_Epoch.titleMeidas_Epoch.first)
        )
        refreshLikeState_Epoch()
    }

    /// 刷新点赞按钮状态
    private func refreshLikeState_Epoch() {
        guard let postModel_Epoch = postModel_Epoch else { return }
        let isLiked_epoch = UserViewModel_Epoch.shared_Epoch.isLikedByCurrentUser_Epoch(post_epoch: postModel_Epoch)
        let heartName_epoch = isLiked_epoch ? "heart.fill" : "heart"
        let heartConfig_epoch = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        likeButton_Epoch.setImage(UIImage(systemName: heartName_epoch, withConfiguration: heartConfig_epoch), for: .normal)
        likeButton_Epoch.tintColor = isLiked_epoch ? UIColor(hexstring_Epoch: "#F56565") : ColorConfig_Epoch.textSecondary_Epoch
        likeButton_Epoch.setTitle("  \(postModel_Epoch.likes_Epoch)", for: .normal)
    }

    /// 在媒体底部叠加渐变蒙层
    private func applyMediaGradient_Epoch() {
        mediaGradientView_Epoch.layer.sublayers?.removeAll()
        guard mediaGradientView_Epoch.bounds.size != .zero else { return }
        let gradientLayer_epoch = CAGradientLayer()
        gradientLayer_epoch.frame = mediaGradientView_Epoch.bounds
        gradientLayer_epoch.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.30).cgColor]
        gradientLayer_epoch.startPoint = CGPoint(x: 0, y: 0.4)
        gradientLayer_epoch.endPoint = CGPoint(x: 0, y: 1)
        mediaGradientView_Epoch.layer.addSublayer(gradientLayer_epoch)
    }

    /// 构建热门卡片
    private func setupUI_Epoch() {
        backgroundColor = .clear
        addSubview(containerView_Epoch)

        containerView_Epoch.addSubview(mediaView_Epoch)
        containerView_Epoch.addSubview(mediaGradientView_Epoch)
        containerView_Epoch.addSubview(badgeLabel_Epoch)
        containerView_Epoch.addSubview(reportButton_Epoch)
        containerView_Epoch.addSubview(emptyContainerView_Epoch)
        emptyContainerView_Epoch.addSubview(emptyIconView_Epoch)
        emptyContainerView_Epoch.addSubview(emptyTitleLabel_Epoch)
        containerView_Epoch.addSubview(titleLabel_Epoch)
        containerView_Epoch.addSubview(summaryLabel_Epoch)
        containerView_Epoch.addSubview(bottomRowView_Epoch)
        bottomRowView_Epoch.addSubview(authorButton_Epoch)
        bottomRowView_Epoch.addSubview(likeButton_Epoch)

        authorButton_Epoch.setTitleColor(ColorConfig_Epoch.accentPurple_Epoch, for: .normal)
        authorButton_Epoch.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        authorButton_Epoch.contentHorizontalAlignment = .left

        likeButton_Epoch.setTitleColor(ColorConfig_Epoch.textSecondary_Epoch, for: .normal)
        likeButton_Epoch.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }

        mediaGradientView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(mediaView_Epoch)
        }

        badgeLabel_Epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(14)
        }

        reportButton_Epoch.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(14)
            make.width.height.equalTo(30)
        }

        emptyContainerView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }

        emptyIconView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }

        emptyTitleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
        }

        summaryLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(16)
        }

        bottomRowView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }

        authorButton_Epoch.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }

        likeButton_Epoch.snp.makeConstraints { make in
            make.left.equalTo(authorButton_Epoch.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }

        // 整卡点击手势
        let tap_epoch = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Epoch))
        containerView_Epoch.addGestureRecognizer(tap_epoch)
        containerView_Epoch.isUserInteractionEnabled = true

        authorButton_Epoch.addTarget(self, action: #selector(authorTapped_Epoch), for: .touchUpInside)
        likeButton_Epoch.addTarget(self, action: #selector(likeTapped_Epoch), for: .touchUpInside)
        reportButton_Epoch.addTarget(self, action: #selector(reportTapped_Epoch), for: .touchUpInside)
    }

    /// 判断媒体是否为视频
    /// - Parameter mediaPath_Epoch: 媒体路径
    /// - Returns: 是否为视频
    private func isVideoMedia_Epoch(_ mediaPath_Epoch: String?) -> Bool {
        guard let mediaPath_Epoch = mediaPath_Epoch?.lowercased() else { return false }
        return mediaPath_Epoch.hasSuffix(".mov")
            || mediaPath_Epoch.hasSuffix(".mp4")
            || mediaPath_Epoch.hasSuffix(".m4v")
            || mediaPath_Epoch.contains("video")
    }

    /// 处理整卡点击
    @objc private func cardTapped_Epoch() {
        guard let postModel_Epoch = postModel_Epoch else { return }
        UIView.animate(withDuration: 0.08, animations: {
            self.containerView_Epoch.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.08) {
                self.containerView_Epoch.transform = .identity
            }
        }
        onCardTapped_Epoch?(postModel_Epoch)
    }

    /// 处理作者点击
    @objc private func authorTapped_Epoch() {
        guard let postModel_Epoch = postModel_Epoch else { return }
        onAuthorTapped_Epoch?(postModel_Epoch)
    }

    /// 处理点赞点击
    @objc private func likeTapped_Epoch() {
        guard let postModel_Epoch = postModel_Epoch else { return }
        onLikeTapped_Epoch?(postModel_Epoch)
    }

    /// 处理举报按钮点击
    @objc private func reportTapped_Epoch() {
        guard let postModel_Epoch = postModel_Epoch else { return }
        UIView.animate(withDuration: 0.1, animations: {
            self.reportButton_Epoch.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.reportButton_Epoch.transform = .identity
            }
        }
        onReportTapped_Epoch?(postModel_Epoch)
    }
}

// MARK: - 首页 Tips 半模态详情

/// 首页 Tips 半模态详情页
/// 核心作用：以底部半模态方式展示单个场景 Tips 的详细说明与执行清单
/// 设计思路：使用 pageSheet 与滚动内容保证信息更完整，同时保持首页的轻量浏览节奏
class HomeTipDetailSheetViewController_Epoch: UIViewController {

    /// Tips 模型
    private let tipModel_Epoch: HomeSceneTipModel_Epoch

    /// 滚动视图
    private let scrollView_Epoch: UIScrollView = {
        let scrollView_Epoch = UIScrollView()
        scrollView_Epoch.showsVerticalScrollIndicator = false
        return scrollView_Epoch
    }()

    /// 内容容器
    private let contentView_Epoch = UIView()

    /// 场景标签
    private let sceneBadgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.accentBlue_Epoch
        label_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientEnd_Epoch.withAlphaComponent(0.16)
        label_Epoch.horizontalInset_Epoch = 12
        label_Epoch.verticalInset_Epoch = 7
        label_Epoch.layer.cornerRadius = 13
        label_Epoch.clipsToBounds = true
        return label_Epoch
    }()

    /// 图标容器
    private let iconWrapView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.18)
        view_Epoch.layer.cornerRadius = 26
        return view_Epoch
    }()

    /// 图标视图
    private let iconImageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.contentMode = .scaleAspectFit
        imageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        return imageView_Epoch
    }()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 摘要标签
    private let summaryLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 扩展说明标签
    private let extendedLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 清单标题
    private let checklistTitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.text = "Checklist"
        return label_Epoch
    }()

    /// 清单栈
    private let checklistStackView_Epoch: UIStackView = {
        let stackView_Epoch = UIStackView()
        stackView_Epoch.axis = .vertical
        stackView_Epoch.spacing = 10
        return stackView_Epoch
    }()

    /// 关闭按钮
    private let closeButton_Epoch = UIButton(type: .system)

    /// 初始化详情页
    /// - Parameter tipModel_Epoch: 场景贴士模型
    init(tipModel_Epoch: HomeSceneTipModel_Epoch) {
        self.tipModel_Epoch = tipModel_Epoch
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheet_Epoch()
        setupUI_Epoch()
        bindData_Epoch()
    }

    /// 配置半模态样式
    private func setupSheet_Epoch() {
        if let sheetPresentationController_Epoch = sheetPresentationController {
            if #available(iOS 15.0, *) {
                sheetPresentationController_Epoch.detents = [.medium(), .large()]
                sheetPresentationController_Epoch.selectedDetentIdentifier = .medium
                sheetPresentationController_Epoch.prefersGrabberVisible = true
                sheetPresentationController_Epoch.preferredCornerRadius = 28
            }
        }
    }

    /// 构建界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        view.addSubview(closeButton_Epoch)
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)

        contentView_Epoch.addSubview(sceneBadgeLabel_Epoch)
        contentView_Epoch.addSubview(iconWrapView_Epoch)
        iconWrapView_Epoch.addSubview(iconImageView_Epoch)
        contentView_Epoch.addSubview(titleLabel_Epoch)
        contentView_Epoch.addSubview(summaryLabel_Epoch)
        contentView_Epoch.addSubview(extendedLabel_Epoch)
        contentView_Epoch.addSubview(checklistTitleLabel_Epoch)
        contentView_Epoch.addSubview(checklistStackView_Epoch)

        closeButton_Epoch.setTitle("Done", for: .normal)
        closeButton_Epoch.setTitleColor(ColorConfig_Epoch.accentPurple_Epoch, for: .normal)
        closeButton_Epoch.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        closeButton_Epoch.addTarget(self, action: #selector(closeTapped_Epoch), for: .touchUpInside)

        closeButton_Epoch.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(24)
        }

        scrollView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(closeButton_Epoch.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }

        contentView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Epoch.contentLayoutGuide)
            make.width.equalTo(scrollView_Epoch.frameLayoutGuide)
        }

        sceneBadgeLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
        }

        iconWrapView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(sceneBadgeLabel_Epoch.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(52)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(iconWrapView_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
        }

        summaryLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        extendedLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
        }

        checklistTitleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(extendedLabel_Epoch.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
        }

        checklistStackView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(checklistTitleLabel_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    /// 绑定详情数据
    private func bindData_Epoch() {
        sceneBadgeLabel_Epoch.text = tipModel_Epoch.sceneName_Epoch
        iconImageView_Epoch.image = UIImage(systemName: tipModel_Epoch.iconName_Epoch)
        titleLabel_Epoch.text = tipModel_Epoch.tipTitle_Epoch
        summaryLabel_Epoch.text = tipModel_Epoch.tipDetail_Epoch
        extendedLabel_Epoch.text = tipModel_Epoch.tipExtendedDetail_Epoch

        checklistStackView_Epoch.arrangedSubviews.forEach { subview_epoch in
            checklistStackView_Epoch.removeArrangedSubview(subview_epoch)
            subview_epoch.removeFromSuperview()
        }

        tipModel_Epoch.tipChecklist_Epoch.forEach { item_epoch in
            let rowView_epoch = HomeTipChecklistRowView_Epoch()
            rowView_epoch.configure_Epoch(text_Epoch: item_epoch)
            checklistStackView_Epoch.addArrangedSubview(rowView_epoch)
        }
    }

    /// 关闭半模态
    @objc private func closeTapped_Epoch() {
        dismiss(animated: true)
    }
}

/// Tips 清单行
/// 核心作用：展示单条可执行建议
class HomeTipChecklistRowView_Epoch: UIView {

    /// 圆点视图
    private let bulletView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        view_Epoch.layer.cornerRadius = 4
        return view_Epoch
    }()

    /// 文本标签
    private let textLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 绑定清单文本
    /// - Parameter text_Epoch: 清单内容
    func configure_Epoch(text_Epoch: String) {
        textLabel_Epoch.text = text_Epoch
    }

    /// 构建清单行
    private func setupUI_Epoch() {
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor

        addSubview(bulletView_Epoch)
        addSubview(textLabel_Epoch)

        bulletView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(8)
        }

        textLabel_Epoch.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.left.equalTo(bulletView_Epoch.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
        }
    }
}

// MARK: - 照片墙添加贴纸模态

/// 照片墙专用上传模态
/// 核心作用：以底部模态的形式让用户选取本地照片、填写标题与描述，然后将内容存入当前登录用户的 userMomentWall
/// 设计思路：独立于发布页，流程简化为"选图 + 填字 + 提交"，提交后通过 onStickerAdded_Epoch 回调通知首页刷新
/// 关键属性 / 方法：
/// - onStickerAdded_Epoch: 成功添加后的回调
/// - confirmTapped_Epoch: 构建 TitleModel 并调用 addPostToCurrentUser_Epoch
import PhotosUI

class HomeAddStickerSheetViewController_Epoch: UIViewController {

    // MARK: - 回调

    /// 成功添加贴纸后的回调
    var onStickerAdded_Epoch: (() -> Void)?

    // MARK: - 数据

    /// 用户选取的图片（可选）
    private var pickedImage_Epoch: UIImage?

    /// 保存到文档目录后的文件名（作为媒体路径）
    private var savedImageName_Epoch: String?

    // MARK: - UI 组件

    /// 顶部拖拽把手
    private let handleView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = UIColor.systemGray4
        view_Epoch.layer.cornerRadius = 2.5
        return view_Epoch
    }()

    /// 页面标题
    private let pageTitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.text = "Add to My Sticker Wall"
        label_Epoch.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 关闭按钮
    private let closeButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        button_Epoch.setImage(UIImage(systemName: "xmark", withConfiguration: config_Epoch), for: .normal)
        button_Epoch.tintColor = ColorConfig_Epoch.textSecondary_Epoch
        button_Epoch.backgroundColor = ColorConfig_Epoch.backgroundSecondary_Epoch
        button_Epoch.layer.cornerRadius = 15
        return button_Epoch
    }()

    /// 图片预览区（使用 MediaDisplayView）
    private let mediaPreviewView_Epoch: MediaDisplayView_Epoch = {
        let view_Epoch = MediaDisplayView_Epoch()
        view_Epoch.layer.cornerRadius = 20
        view_Epoch.clipsToBounds = true
        view_Epoch.backgroundColor = ColorConfig_Epoch.backgroundSecondary_Epoch
        return view_Epoch
    }()

    /// 选择图片按钮（浮于预览区中心）
    private let pickPhotoButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        var config_Epoch = UIButton.Configuration.filled()
        config_Epoch.title = "Choose Photo"
        config_Epoch.image = UIImage(systemName: "photo.on.rectangle.angled",
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        config_Epoch.imagePadding = 8
        config_Epoch.baseForegroundColor = .white
        config_Epoch.baseBackgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        config_Epoch.cornerStyle = .capsule
        button_Epoch.configuration = config_Epoch
        return button_Epoch
    }()

    /// 更换图片按钮（图片选中后显示，位于预览右上角）
    private let changePhotoButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        button_Epoch.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: config_Epoch), for: .normal)
        button_Epoch.tintColor = .white
        button_Epoch.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        button_Epoch.layer.cornerRadius = 15
        button_Epoch.isHidden = true
        return button_Epoch
    }()

    /// 标题输入框
    private let titleTextField_Epoch: UITextField = {
        let field_Epoch = UITextField()
        field_Epoch.placeholder = "Give it a title..."
        field_Epoch.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        field_Epoch.backgroundColor = ColorConfig_Epoch.backgroundSecondary_Epoch
        field_Epoch.layer.cornerRadius = 14
        field_Epoch.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field_Epoch.leftViewMode = .always
        field_Epoch.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field_Epoch.rightViewMode = .always
        field_Epoch.returnKeyType = .next
        return field_Epoch
    }()

    /// 描述输入框背景容器
    private let captionContainerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.backgroundSecondary_Epoch
        view_Epoch.layer.cornerRadius = 14
        return view_Epoch
    }()

    /// 描述输入框
    private let captionTextView_Epoch: UITextView = {
        let tv_Epoch = UITextView()
        tv_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tv_Epoch.backgroundColor = .clear
        tv_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        tv_Epoch.returnKeyType = .done
        return tv_Epoch
    }()

    /// 描述输入占位符
    private let captionPlaceholderLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.text = "Share a moment or feeling..."
        label_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_Epoch.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        return label_Epoch
    }()

    /// 提交按钮
    private let confirmButton_Epoch: UIButton = {
        let button_Epoch = UIButton(type: .system)
        button_Epoch.setTitle("Add to Wall", for: .normal)
        button_Epoch.setTitleColor(.white, for: .normal)
        button_Epoch.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button_Epoch.layer.cornerRadius = 26
        button_Epoch.clipsToBounds = true
        return button_Epoch
    }()

    /// 提交按钮渐变层
    private let confirmGradient_Epoch = CAGradientLayer()

    /// 可滚动内容区（承载媒体预览和输入框）
    private let scrollView_Epoch: UIScrollView = {
        let sv_Epoch = UIScrollView()
        sv_Epoch.showsVerticalScrollIndicator = false
        sv_Epoch.keyboardDismissMode = .interactive
        return sv_Epoch
    }()

    /// 滚动内容容器
    private let scrollContentView_Epoch = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        setupUI_Epoch()
        setupActions_Epoch()
        setupKeyboardDismiss_Epoch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmGradient_Epoch.frame = confirmButton_Epoch.bounds
    }

    // MARK: - 布局

    /// 构建界面
    /// 布局策略：Header 固定顶部，confirmButton 固定底部 safeArea，中间 scrollView 承载可变内容
    /// 解决 medium detent 下按钮位于 view.bounds 外导致 hit-test 命中不到的问题
    private func setupUI_Epoch() {
        // Header（固定顶部，不随滚动移动）
        view.addSubview(handleView_Epoch)
        view.addSubview(pageTitleLabel_Epoch)
        view.addSubview(closeButton_Epoch)

        // 提交按钮（固定底部，始终在 safeArea 内可点击）
        view.addSubview(confirmButton_Epoch)

        // 可滚动中间区域
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(scrollContentView_Epoch)
        scrollContentView_Epoch.addSubview(mediaPreviewView_Epoch)
        mediaPreviewView_Epoch.addSubview(pickPhotoButton_Epoch)
        mediaPreviewView_Epoch.addSubview(changePhotoButton_Epoch)
        scrollContentView_Epoch.addSubview(titleTextField_Epoch)
        scrollContentView_Epoch.addSubview(captionContainerView_Epoch)
        captionContainerView_Epoch.addSubview(captionTextView_Epoch)
        captionContainerView_Epoch.addSubview(captionPlaceholderLabel_Epoch)

        // 渐变提交按钮
        confirmGradient_Epoch.colors = [
            ColorConfig_Epoch.accentPurple_Epoch.cgColor,
            ColorConfig_Epoch.primaryGradientEnd_Epoch.cgColor
        ]
        confirmGradient_Epoch.startPoint = CGPoint(x: 0, y: 0.5)
        confirmGradient_Epoch.endPoint = CGPoint(x: 1, y: 0.5)
        confirmButton_Epoch.layer.insertSublayer(confirmGradient_Epoch, at: 0)

        // — Header 约束 —
        handleView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        pageTitleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(24)
        }

        closeButton_Epoch.snp.makeConstraints { make in
            make.centerY.equalTo(pageTitleLabel_Epoch)
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }

        // — 提交按钮固定底部 —
        confirmButton_Epoch.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
            make.height.equalTo(52)
        }

        // — ScrollView 填充 Header 与 Button 之间 —
        scrollView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmButton_Epoch.snp.top).offset(-12)
        }

        scrollContentView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Epoch)
        }

        // — 滚动内容约束 —
        mediaPreviewView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }

        pickPhotoButton_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        changePhotoButton_Epoch.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.width.height.equalTo(30)
        }

        titleTextField_Epoch.snp.makeConstraints { make in
            make.top.equalTo(mediaPreviewView_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        captionContainerView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleTextField_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
            // bottom 约束锁定 scrollContent 高度
            make.bottom.equalToSuperview().inset(20)
        }

        captionTextView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }

        captionPlaceholderLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
        }
    }

    // MARK: - 交互注册

    /// 绑定按钮事件与文本委托
    private func setupActions_Epoch() {
        closeButton_Epoch.addTarget(self, action: #selector(closeTapped_Epoch), for: .touchUpInside)
        pickPhotoButton_Epoch.addTarget(self, action: #selector(pickPhotoTapped_Epoch), for: .touchUpInside)
        changePhotoButton_Epoch.addTarget(self, action: #selector(pickPhotoTapped_Epoch), for: .touchUpInside)
        confirmButton_Epoch.addTarget(self, action: #selector(confirmTapped_Epoch), for: .touchUpInside)
        captionTextView_Epoch.delegate = self
        titleTextField_Epoch.delegate = self
    }

    /// 点击空白收起键盘
    private func setupKeyboardDismiss_Epoch() {
        let tap_epoch = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Epoch))
        tap_epoch.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_epoch)
    }

    // MARK: - 事件处理

    /// 关闭模态
    @objc private func closeTapped_Epoch() {
        dismiss(animated: true)
    }

    /// 弹出系统相册选图
    @objc private func pickPhotoTapped_Epoch() {
        var config_Epoch = PHPickerConfiguration()
        config_Epoch.selectionLimit = 1
        config_Epoch.filter = .images
        let picker_Epoch = PHPickerViewController(configuration: config_Epoch)
        picker_Epoch.delegate = self
        present(picker_Epoch, animated: true)
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Epoch() {
        view.endEditing(true)
    }

    /// 提交贴纸：构建 TitleModel 并存入当前用户的 userMomentWall，保存后立即触发首页刷新再关闭模态
    @objc private func confirmTapped_Epoch() {
        let titleText_epoch = titleTextField_Epoch.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !titleText_epoch.isEmpty else {
            shakeView_Epoch(view: titleTextField_Epoch)
            return
        }

        let vm_epoch = UserViewModel_Epoch.shared_Epoch
        let user_epoch = vm_epoch.getCurrentUser_Epoch()
        let captionText_epoch = captionTextView_Epoch.text?.trimmingCharacters(in: .whitespaces) ?? ""

        // 构建媒体路径数组
        var medias_epoch: [String] = []
        if let imageName_epoch = savedImageName_Epoch {
            medias_epoch = [imageName_epoch]
        }

        let post_epoch = TitleModel_Epoch(
            titleId_Epoch: Int(Date().timeIntervalSince1970),
            titleUserId_Epoch: user_epoch.userId_Epoch ?? 0,
            titleUserName_Epoch: user_epoch.userName_Epoch ?? "Me",
            titleMeidas_Epoch: medias_epoch,
            title_Epoch: titleText_epoch,
            titleContent_Epoch: captionText_epoch,
            reviews_Epoch: [],
            likes_Epoch: 0
        )

        // 保存到当前用户的 momentWall（内部同步触发 notification，首页立即刷新）
        vm_epoch.addPostToCurrentUser_Epoch(post_epoch: post_epoch)

        // 额外通过 callback 再次通知首页刷新，确保无论通知是否及时收到界面都能更新
        onStickerAdded_Epoch?()

        // 按钮反馈动画后关闭模态
        confirmButton_Epoch.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1, animations: {
            self.confirmButton_Epoch.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.confirmButton_Epoch.transform = .identity
            } completion: { _ in
                self.dismiss(animated: true)
            }
        }
    }

    // MARK: - 辅助方法

    /// 将 UIImage 保存到文档目录，返回文件名
    /// - Parameter image_Epoch: 要保存的图片
    /// - Returns: 保存成功的文件名，失败返回 nil
    private func saveImageToDocuments_Epoch(image_Epoch: UIImage) -> String? {
        guard let data_epoch = image_Epoch.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_epoch = "sticker_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_epoch = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_epoch)
        do {
            try data_epoch.write(to: url_epoch)
            print("贴纸图片已保存：\(fileName_epoch)")
            return fileName_epoch
        } catch {
            print("贴纸图片保存失败：\(error.localizedDescription)")
            return nil
        }
    }

    /// 输入框抖动提示
    /// - Parameter view: 要抖动的视图
    private func shakeView_Epoch(view: UIView) {
        let animation_epoch = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_epoch.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_epoch.duration = 0.4
        animation_epoch.values = [-8, 8, -6, 6, -4, 4, 0]
        view.layer.add(animation_epoch, forKey: "shake")
    }
}

// MARK: - PHPickerViewControllerDelegate

extension HomeAddStickerSheetViewController_Epoch: PHPickerViewControllerDelegate {

    /// 处理用户选图结果
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result_epoch = results.first else { return }
        result_epoch.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object_epoch, error_epoch in
            guard let image_epoch = object_epoch as? UIImage else {
                print("选图加载失败：\(error_epoch?.localizedDescription ?? "未知错误")")
                return
            }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.pickedImage_Epoch = image_epoch
                self.savedImageName_Epoch = self.saveImageToDocuments_Epoch(image_Epoch: image_epoch)
                self.mediaPreviewView_Epoch.configureWithImage_Epoch(image_Epoch: image_epoch)
                self.pickPhotoButton_Epoch.isHidden = true
                self.changePhotoButton_Epoch.isHidden = false
            }
        }
    }
}

// MARK: - UITextViewDelegate / UITextFieldDelegate

extension HomeAddStickerSheetViewController_Epoch: UITextViewDelegate, UITextFieldDelegate {

    func textViewDidChange(_ textView: UITextView) {
        captionPlaceholderLabel_Epoch.isHidden = !textView.text.isEmpty
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 回车键收起键盘
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionTextView_Epoch.becomeFirstResponder()
        return true
    }
}
