import Foundation
import UIKit
import SnapKit
import FSPagerView

// MARK: - 首页视图控制器

/// 首页视图控制器
/// 功能：展示"每日一语"、热门DIY作品轮播、"手作时光胶囊"入口、"旧料改造"灵感推荐、"成长阶梯"手作技艺可视化五大模块
/// 设计：UIScrollView 容器串联各模块卡片；渐变/图标区分不同板块的视觉主题色
/// 逻辑：轮播数据来自 TitleViewModel_Maki；胶囊/旧料/成长数据来自 CapsuleViewModel_Maki；
///       首页出现时若存在已解锁未查看的胶囊，弹窗提醒用户回看
class Home_Maki: UIViewController {

    // MARK: - 私有常量枚举

    private enum K_Maki {
        static let cardRadius: CGFloat = 18
        static let bannerHeight: CGFloat = 190

        /// 配色 - 琥珀暖橙系（主题色）与胶囊模块专属紫色
        static let bgColor      = UIColor(hexstring_Maki: "#FFFBF4")   // 暖象牙白
        static let primaryColor = UIColor(hexstring_Maki: "#FF8C00")   // 深琥珀橙
        static let tp           = UIColor(hexstring_Maki: "#1A0A00")   // 深棕黑
        static let ts           = UIColor(hexstring_Maki: "#8B7355")   // 暖棕灰
        static let capsuleColor = UIColor(hexstring_Maki: "#9B59B6")   // 胶囊模块紫色

        static let bannerCellId = "HomeBannerCell_Maki"
    }

    // MARK: - UI 属性 / 主滚动容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.alwaysBounceVertical = true
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 顶部导航区

    private let navArea_Maki = UIView()
    private let navGrad_Maki = CAGradientLayer()
    private let navBubble1_Maki = UIView()
    private let navBubble2_Maki = UIView()

    // MARK: - UI 属性 / 每日一语区

    private let quoteCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.layer.cornerRadius = K_Maki.cardRadius
        v_maki.layer.masksToBounds = false
        v_maki.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.18).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_maki.layer.shadowRadius = 14
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    private let quoteCardInner_Maki: UIView = {
        let v_maki = UIView()
        v_maki.layer.cornerRadius = K_Maki.cardRadius
        v_maki.clipsToBounds = true
        return v_maki
    }()
    private let quoteGradient_Maki = CAGradientLayer()
    private let quoteDecoBar_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        v_maki.layer.cornerRadius = 2.5
        return v_maki
    }()
    private let quoteEmojiLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "✨"
        lb_maki.font = UIFont.systemFont(ofSize: 24)
        return lb_maki
    }()
    private let quoteTextLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.numberOfLines = 0
        lb_maki.font = UIFont(name: "Georgia-Italic", size: 15) ?? UIFont.italicSystemFont(ofSize: 15)
        lb_maki.textColor = UIColor(hexstring_Maki: "#3D1A00")
        return lb_maki
    }()
    private let quoteDateLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()

    // MARK: - UI 属性 / 热门DIY轮播区

    private let bannerHeader_Maki = UIView()
    private let bannerView_Maki: FSPagerView = {
        let pv_maki = FSPagerView()
        pv_maki.automaticSlidingInterval = 3.5
        pv_maki.isInfinite = true
        pv_maki.decelerationDistance = FSPagerView.automaticDistance
        pv_maki.clipsToBounds = false
        return pv_maki
    }()
    private let pageControl_Maki: UIPageControl = {
        let pc_maki = UIPageControl()
        pc_maki.currentPageIndicatorTintColor = K_Maki.primaryColor
        pc_maki.pageIndicatorTintColor        = K_Maki.primaryColor.withAlphaComponent(0.3)
        pc_maki.hidesForSinglePage = true
        return pc_maki
    }()

    // MARK: - UI 属性 / 手作时光胶囊区

    private let capsuleHeader_Maki = UIView()
    private let capsuleCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 20
        v_maki.layer.shadowColor  = K_Maki.capsuleColor.withAlphaComponent(0.16).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 5)
        v_maki.layer.shadowRadius = 12
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    private let capsuleStatsLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 12, weight: .medium)
        lb_maki.textColor = K_Maki.ts
        return lb_maki
    }()
    private let capsuleCountdownLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 12, weight: .semibold)
        lb_maki.textColor = K_Maki.capsuleColor
        lb_maki.numberOfLines = 1
        return lb_maki
    }()
    private let capsuleReadyBadge_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        v_maki.layer.cornerRadius = 9
        v_maki.isHidden = true
        return v_maki
    }()

    // MARK: - UI 属性 / 旧料改造区

    private let reuseHeader_Maki = UIView()
    private let reuseScrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsHorizontalScrollIndicator = false
        sv_maki.alwaysBounceHorizontal = true
        return sv_maki
    }()
    private let reuseStack_Maki: UIStackView = {
        let sv_maki = UIStackView()
        sv_maki.axis = .horizontal
        sv_maki.spacing = 12
        sv_maki.alignment = .top
        return sv_maki
    }()

    // MARK: - UI 属性 / 成长阶梯区

    private let growthHeader_Maki = UIView()
    private let growthCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 20
        v_maki.layer.shadowColor  = K_Maki.primaryColor.withAlphaComponent(0.14).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 5)
        v_maki.layer.shadowRadius = 12
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    private let growthLevelLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 15, weight: .bold)
        lb_maki.textColor = K_Maki.tp
        return lb_maki
    }()
    private let growthProgressLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 12)
        lb_maki.textColor = K_Maki.ts
        lb_maki.numberOfLines = 1
        return lb_maki
    }()
    private var growthStepCircles_Maki: [UIView] = []

    // MARK: - 逻辑引用
    private let vm_Maki = HomeViewModel_Maki.shared_Maki

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bgColor
        buildUI_Maki()
        buildConstraints_Maki()
        bindNotifications_Maki()
        reloadAll_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        reloadAll_Maki()
        presentCapsuleReminderIfNeeded_Maki()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntrance_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGrad_Maki.frame = navArea_Maki.bounds
        quoteGradient_Maki.frame = quoteCardInner_Maki.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UI 构建

extension Home_Maki {

    /// 构建全部 UI 元素并加入视图层级
    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)

        buildNavArea_Maki()
        buildQuoteArea_Maki()
        buildBannerArea_Maki()
        buildCapsuleArea_Maki()
        buildReuseArea_Maki()
        buildGrowthArea_Maki()
    }

    /// 构建顶部渐变导航区：渐变背景 + 装饰气泡 + 品牌标题 + 描述文字
    private func buildNavArea_Maki() {
        // 渐变背景（深琥珀 → 橙金，与其他页面保持统一）
        navGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#E8650A").cgColor,
            UIColor(hexstring_Maki: "#FF9F1C").cgColor
        ]
        navGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        navGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        navArea_Maki.layer.insertSublayer(navGrad_Maki, at: 0)
        contentView_Maki.addSubview(navArea_Maki)

        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        navArea_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(132 + statusH_maki)
        }

        // 右上角装饰气泡（大）
        navBubble1_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        navBubble1_Maki.layer.cornerRadius = 55
        navArea_Maki.addSubview(navBubble1_Maki)
        navBubble1_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.trailing.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(-22)
        }

        // 左下角装饰气泡（小）
        navBubble2_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        navBubble2_Maki.layer.cornerRadius = 35
        navArea_Maki.addSubview(navBubble2_Maki)
        navBubble2_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.leading.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(18)
        }

        // 星号装饰符
        let starLb_maki = UILabel()
        starLb_maki.text = "✦"
        starLb_maki.font = .systemFont(ofSize: 17, weight: .bold)
        starLb_maki.textColor = UIColor.white.withAlphaComponent(0.88)
        navArea_Maki.addSubview(starLb_maki)
        starLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(statusH_maki + 14)
        }

        // 品牌主标题
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Maki"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 26)
            ?? .systemFont(ofSize: 26, weight: .bold)
        titleLb_maki.textColor = .white
        navArea_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(starLb_maki.snp.trailing).offset(8)
            make.centerY.equalTo(starLb_maki)
        }

        // 描述副标题
        let subLb_maki = UILabel()
        subLb_maki.text = "Craft, capsule, and grow — all in one place"
        subLb_maki.font = .systemFont(ofSize: 12, weight: .light)
        subLb_maki.textColor = UIColor.white.withAlphaComponent(0.8)
        navArea_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalTo(titleLb_maki.snp.bottom).offset(4)
        }

        // 底部圆角过渡条（平滑衔接背景色）
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bgColor
        decoBar_maki.layer.cornerRadius = 22
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navArea_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(28)
        }
    }

    /// 构建每日一语区：渐变卡片 + 竖线装饰 + 引用文字
    private func buildQuoteArea_Maki() {
        quoteGradient_Maki.colors = [
            UIColor(hexstring_Maki: "#FFF3E0").cgColor,
            UIColor(hexstring_Maki: "#FFE0B2").cgColor
        ]
        quoteGradient_Maki.startPoint = CGPoint(x: 0, y: 0)
        quoteGradient_Maki.endPoint   = CGPoint(x: 1, y: 1)
        quoteCardInner_Maki.layer.insertSublayer(quoteGradient_Maki, at: 0)

        quoteCard_Maki.addSubview(quoteCardInner_Maki)
        quoteCardInner_Maki.addSubview(quoteDecoBar_Maki)
        quoteCardInner_Maki.addSubview(quoteEmojiLabel_Maki)
        quoteCardInner_Maki.addSubview(quoteTextLabel_Maki)
        quoteCardInner_Maki.addSubview(quoteDateLabel_Maki)
        contentView_Maki.addSubview(quoteCard_Maki)

        let fmt_maki = DateFormatter()
        fmt_maki.dateFormat = "MMMM d, yyyy"
        quoteDateLabel_Maki.text = fmt_maki.string(from: Date())
    }

    /// 构建热门DIY轮播区：区块标题 + FSPagerView + 页码指示器
    private func buildBannerArea_Maki() {
        let header_maki = buildSectionHeader_Maki(icon_maki: "flame.fill", title_maki: "Hot DIY Creations")
        bannerHeader_Maki.addSubview(header_maki)
        header_maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.addSubview(bannerHeader_Maki)

        bannerView_Maki.register(HomeBannerCell_Maki.self, forCellWithReuseIdentifier: K_Maki.bannerCellId)
        bannerView_Maki.dataSource  = self
        bannerView_Maki.delegate    = self
        bannerView_Maki.transformer = FSPagerViewTransformer(type: .linear)
        bannerView_Maki.itemSize    = CGSize(width: APPSCREEN_Maki.WIDTH_Maki - 40, height: K_Maki.bannerHeight)
        bannerView_Maki.interitemSpacing = 14
        contentView_Maki.addSubview(bannerView_Maki)
        contentView_Maki.addSubview(pageControl_Maki)
    }

    /// 构建手作时光胶囊入口区：图标 + 说明 + 统计 + 倒计时 + 操作按钮
    private func buildCapsuleArea_Maki() {
        let header_maki = buildSectionHeader_Maki(
            icon_maki: "shippingbox.fill",
            title_maki: "Time Capsule",
            subtitle_maki: "Seal today's creation for future you",
            iconColor_maki: K_Maki.capsuleColor
        )
        capsuleHeader_Maki.addSubview(header_maki)
        header_maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.addSubview(capsuleHeader_Maki)

        contentView_Maki.addSubview(capsuleCard_Maki)

        // 左上角图标徽章
        let iconWrap_maki = UIView()
        iconWrap_maki.backgroundColor = K_Maki.capsuleColor.withAlphaComponent(0.12)
        iconWrap_maki.layer.cornerRadius = 22
        let iconLb_maki = UILabel()
        iconLb_maki.text = "⏳"
        iconLb_maki.font = .systemFont(ofSize: 22)
        iconLb_maki.textAlignment = .center
        iconWrap_maki.addSubview(iconLb_maki)
        iconLb_maki.snp.makeConstraints { $0.center.equalToSuperview() }
        capsuleCard_Maki.addSubview(iconWrap_maki)
        iconWrap_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }

        // "准备开启"角标
        capsuleCard_Maki.addSubview(capsuleReadyBadge_Maki)
        let readyLb_maki = UILabel()
        readyLb_maki.text = "1 READY!"
        readyLb_maki.font = .systemFont(ofSize: 10, weight: .bold)
        readyLb_maki.textColor = .white
        capsuleReadyBadge_Maki.addSubview(readyLb_maki)
        readyLb_maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        capsuleReadyBadge_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(18)
            make.height.equalTo(20)
        }

        // 统计文字 + 倒计时
        capsuleCard_Maki.addSubview(capsuleStatsLb_Maki)
        capsuleStatsLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(iconWrap_maki.snp.trailing).offset(12)
            make.top.equalTo(iconWrap_maki.snp.top).offset(2)
            make.trailing.equalTo(capsuleReadyBadge_Maki.snp.leading).offset(-8)
        }
        capsuleCard_Maki.addSubview(capsuleCountdownLb_Maki)
        capsuleCountdownLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(capsuleStatsLb_Maki)
            make.top.equalTo(capsuleStatsLb_Maki.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 操作按钮行
        let viewAllBtn_maki = UIButton(type: .system)
        viewAllBtn_maki.setTitle("📦 My Capsules", for: .normal)
        viewAllBtn_maki.setTitleColor(K_Maki.capsuleColor, for: .normal)
        viewAllBtn_maki.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        viewAllBtn_maki.backgroundColor = K_Maki.capsuleColor.withAlphaComponent(0.1)
        viewAllBtn_maki.layer.cornerRadius = 14
        viewAllBtn_maki.addTarget(self, action: #selector(onViewCapsules_Maki), for: .touchUpInside)

        let newBtn_maki = UIButton(type: .system)
        newBtn_maki.setTitle("+ Seal New", for: .normal)
        newBtn_maki.setTitleColor(.white, for: .normal)
        newBtn_maki.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        newBtn_maki.backgroundColor = K_Maki.capsuleColor
        newBtn_maki.layer.cornerRadius = 14
        newBtn_maki.addTarget(self, action: #selector(onNewCapsule_Maki), for: .touchUpInside)

        let btnRow_maki = UIStackView(arrangedSubviews: [viewAllBtn_maki, newBtn_maki])
        btnRow_maki.axis = .horizontal
        btnRow_maki.spacing = 10
        btnRow_maki.distribution = .fillEqually
        capsuleCard_Maki.addSubview(btnRow_maki)
        btnRow_maki.snp.makeConstraints { make in
            make.top.equalTo(iconWrap_maki.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(38)
            make.bottom.equalToSuperview().offset(-18)
        }
    }

    /// 构建旧料改造推荐区：区块标题 + 横向卡片滚动
    private func buildReuseArea_Maki() {
        let header_maki = buildSectionHeader_Maki(
            icon_maki: "arrow.3.trianglepath",
            title_maki: "Upcycling Ideas",
            subtitle_maki: "Give your leftover materials new life"
        )
        reuseHeader_Maki.addSubview(header_maki)
        header_maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.addSubview(reuseHeader_Maki)

        contentView_Maki.addSubview(reuseScrollView_Maki)
        reuseScrollView_Maki.addSubview(reuseStack_Maki)
        reuseStack_Maki.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalToSuperview()
        }

        for idea_maki in CapsuleViewModel_Maki.shared_Maki.getReuseIdeas_Maki() {
            let card_maki = buildReuseIdeaCard_Maki(idea_maki: idea_maki)
            reuseStack_Maki.addArrangedSubview(card_maki)
            card_maki.snp.makeConstraints { $0.width.equalTo(158) }
        }
    }

    /// 构建单个旧料改造灵感卡片
    private func buildReuseIdeaCard_Maki(idea_maki: MaterialReuseIdeaModel_Maki) -> UIView {
        let card_maki = UIView()
        card_maki.backgroundColor = .white
        card_maki.layer.cornerRadius = 16
        card_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
        card_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_maki.layer.shadowRadius = 8
        card_maki.layer.shadowOpacity = 1

        let innerClip_maki = UIView()
        innerClip_maki.layer.cornerRadius = 16
        innerClip_maki.clipsToBounds = true
        card_maki.addSubview(innerClip_maki)
        innerClip_maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        let imageIV_maki = UIImageView()
        imageIV_maki.image = UIImage(named: idea_maki.coverImage_Maki) ?? UIImage(systemName: "photo.fill")
        imageIV_maki.tintColor = K_Maki.primaryColor
        imageIV_maki.contentMode = .scaleAspectFill
        imageIV_maki.clipsToBounds = true
        imageIV_maki.backgroundColor = UIColor(hexstring_Maki: "#E8F5E9")
        innerClip_maki.addSubview(imageIV_maki)
        imageIV_maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }

        // 难度星级角标
        let starLb_maki = UILabel()
        starLb_maki.text = String(repeating: "★", count: idea_maki.difficulty_Maki)
        starLb_maki.font = .systemFont(ofSize: 9, weight: .bold)
        starLb_maki.textColor = .white
        let starBadge_maki = UIView()
        starBadge_maki.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        starBadge_maki.layer.cornerRadius = 8
        starBadge_maki.addSubview(starLb_maki)
        starLb_maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
        }
        innerClip_maki.addSubview(starBadge_maki)
        starBadge_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.top.equalToSuperview().offset(6)
            make.height.equalTo(16)
        }

        let beforeLb_maki = UILabel()
        beforeLb_maki.text = idea_maki.beforeMaterial_Maki
        beforeLb_maki.font = .systemFont(ofSize: 10, weight: .medium)
        beforeLb_maki.textColor = K_Maki.ts
        beforeLb_maki.numberOfLines = 1

        let afterLb_maki = UILabel()
        afterLb_maki.text = "→ \(idea_maki.afterCreation_Maki)"
        afterLb_maki.font = .systemFont(ofSize: 12, weight: .semibold)
        afterLb_maki.textColor = K_Maki.tp
        afterLb_maki.numberOfLines = 2

        innerClip_maki.addSubview(beforeLb_maki)
        innerClip_maki.addSubview(afterLb_maki)
        beforeLb_maki.snp.makeConstraints { make in
            make.top.equalTo(imageIV_maki.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        afterLb_maki.snp.makeConstraints { make in
            make.top.equalTo(beforeLb_maki.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        let tap_maki = UITapGestureRecognizer(target: self, action: #selector(onReuseIdeaTap_Maki(_:)))
        card_maki.isUserInteractionEnabled = true
        card_maki.tag = idea_maki.ideaId_Maki
        card_maki.addGestureRecognizer(tap_maki)

        return card_maki
    }

    /// 构建成长阶梯区：区块标题 + 迷你阶梯 + 进度文字 + 查看按钮
    private func buildGrowthArea_Maki() {
        let header_maki = buildSectionHeader_Maki(icon_maki: "chart.line.uptrend.xyaxis", title_maki: "Your Craft Journey")
        growthHeader_Maki.addSubview(header_maki)
        header_maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.addSubview(growthHeader_Maki)

        contentView_Maki.addSubview(growthCard_Maki)

        // 迷你三步阶梯（新手 → 进阶 → 大师）
        let stepsRow_maki = UIStackView()
        stepsRow_maki.axis = .horizontal
        stepsRow_maki.distribution = .equalSpacing
        stepsRow_maki.alignment = .center
        growthCard_Maki.addSubview(stepsRow_maki)
        stepsRow_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(46)
        }

        growthStepCircles_Maki.removeAll()
        for level_maki in CraftLevel_Maki.allCases {
            let circle_maki = UIView()
            circle_maki.layer.cornerRadius = 20
            let iconIV_maki = UIImageView(image: UIImage(systemName: level_maki.icon_Maki))
            iconIV_maki.contentMode = .scaleAspectFit
            circle_maki.addSubview(iconIV_maki)
            iconIV_maki.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(18)
            }
            circle_maki.snp.makeConstraints { make in
                make.width.height.equalTo(40)
            }
            circle_maki.tag = level_maki.rawValue
            stepsRow_maki.addArrangedSubview(circle_maki)
            growthStepCircles_Maki.append(circle_maki)

            // 连接线（除最后一个）
            if level_maki != CraftLevel_Maki.allCases.last {
                let line_maki = UIView()
                line_maki.backgroundColor = UIColor(hexstring_Maki: "#F0EDE6")
                stepsRow_maki.addArrangedSubview(line_maki)
                line_maki.snp.makeConstraints { make in
                    make.width.equalTo(36)
                    make.height.equalTo(2)
                }
            }
        }

        growthCard_Maki.addSubview(growthLevelLb_Maki)
        growthLevelLb_Maki.textAlignment = .center
        growthLevelLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(stepsRow_maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        growthCard_Maki.addSubview(growthProgressLb_Maki)
        growthProgressLb_Maki.textAlignment = .center
        growthProgressLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(growthLevelLb_Maki.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        let journeyBtn_maki = UIButton(type: .system)
        journeyBtn_maki.setTitle("View Full Journey & Poster", for: .normal)
        journeyBtn_maki.setTitleColor(.white, for: .normal)
        journeyBtn_maki.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        journeyBtn_maki.backgroundColor = K_Maki.primaryColor
        journeyBtn_maki.layer.cornerRadius = 14
        journeyBtn_maki.addTarget(self, action: #selector(onViewGrowth_Maki), for: .touchUpInside)
        growthCard_Maki.addSubview(journeyBtn_maki)
        journeyBtn_maki.snp.makeConstraints { make in
            make.top.equalTo(growthProgressLb_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-18)
        }
    }

    /// 构建通用区块标题（图标 + 标题 + 可选副标题）
    /// - Parameters:
    ///   - icon_maki: SF Symbol 图标名
    ///   - title_maki: 主标题
    ///   - subtitle_maki: 副标题（可选）
    ///   - iconColor_maki: 图标颜色，默认橙色主题
    private func buildSectionHeader_Maki(
        icon_maki: String,
        title_maki: String,
        subtitle_maki: String? = nil,
        iconColor_maki: UIColor = K_Maki.primaryColor
    ) -> UIView {
        let wrap_maki = UIView()
        let iconIV_maki = UIImageView(image: UIImage(systemName: icon_maki))
        iconIV_maki.tintColor = iconColor_maki
        iconIV_maki.contentMode = .scaleAspectFit
        let titleLb_maki = UILabel()
        titleLb_maki.text = title_maki
        titleLb_maki.font = .systemFont(ofSize: 18, weight: .bold)
        titleLb_maki.textColor = K_Maki.tp

        wrap_maki.addSubview(iconIV_maki)
        wrap_maki.addSubview(titleLb_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(20)
        }
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(8)
            make.centerY.equalTo(iconIV_maki)
            make.trailing.equalToSuperview()
        }

        if let subtitle_maki {
            let subLb_maki = UILabel()
            subLb_maki.text = subtitle_maki
            subLb_maki.font = .systemFont(ofSize: 12)
            subLb_maki.textColor = K_Maki.ts
            wrap_maki.addSubview(subLb_maki)
            subLb_maki.snp.makeConstraints { make in
                make.leading.equalTo(titleLb_maki)
                make.top.equalTo(titleLb_maki.snp.bottom).offset(3)
                make.trailing.bottom.equalToSuperview()
            }
        } else {
            titleLb_maki.snp.makeConstraints { $0.bottom.equalToSuperview() }
        }
        return wrap_maki
    }
}

// MARK: - 约束布局

extension Home_Maki {

    /// 统一建立所有 SnapKit 约束（自上而下依次串联各模块）
    private func buildConstraints_Maki() {
        scrollView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }

        // 每日一语区（衔接在顶部导航区下方，均相对 contentView_Maki 内部完成约束链）
        quoteCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(navArea_Maki.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        quoteCardInner_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        quoteDecoBar_Maki.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(4)
        }
        quoteEmojiLabel_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(14)
        }
        quoteTextLabel_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(quoteDecoBar_Maki.snp.trailing).offset(12)
            make.trailing.equalTo(quoteEmojiLabel_Maki.snp.leading).offset(-8)
        }
        quoteDateLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(quoteTextLabel_Maki.snp.bottom).offset(8)
            make.leading.equalTo(quoteTextLabel_Maki)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 热门DIY轮播区
        bannerHeader_Maki.snp.makeConstraints { make in
            make.top.equalTo(quoteCard_Maki.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bannerView_Maki.snp.makeConstraints { make in
            make.top.equalTo(bannerHeader_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(K_Maki.bannerHeight)
        }
        pageControl_Maki.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Maki.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
        }

        // 手作时光胶囊区
        capsuleHeader_Maki.snp.makeConstraints { make in
            make.top.equalTo(pageControl_Maki.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        capsuleCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(capsuleHeader_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // 旧料改造区
        reuseHeader_Maki.snp.makeConstraints { make in
            make.top.equalTo(capsuleCard_Maki.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        reuseScrollView_Maki.snp.makeConstraints { make in
            make.top.equalTo(reuseHeader_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }

        // 成长阶梯区
        growthHeader_Maki.snp.makeConstraints { make in
            make.top.equalTo(reuseScrollView_Maki.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        growthCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(growthHeader_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-130)
        }
    }
}

// MARK: - 数据刷新

extension Home_Maki {

    /// 刷新全部页面数据
    private func reloadAll_Maki() {
        quoteTextLabel_Maki.text = "\u{201C}\(vm_Maki.todayQuote_Maki)\u{201D}"

        let bannerCount_maki = TitleViewModel_Maki.shared_Maki.getPosts_Maki()
            .sorted { $0.likes_Maki > $1.likes_Maki }
            .prefix(5).count
        pageControl_Maki.numberOfPages = bannerCount_maki
        bannerView_Maki.reloadData()

        reloadCapsuleArea_Maki()
        reloadGrowthArea_Maki()
    }

    /// 刷新时光胶囊卡片：统计数量、待开启角标、最近倒计时
    private func reloadCapsuleArea_Maki() {
        let capsuleVM_maki = CapsuleViewModel_Maki.shared_Maki
        let capsules_maki  = capsuleVM_maki.getCapsules_Maki()
        capsuleStatsLb_Maki.text = capsules_maki.isEmpty
            ? "No capsules sealed yet"
            : "\(capsules_maki.count) capsule\(capsules_maki.count == 1 ? "" : "s") sealed"

        if let ready_maki = capsuleVM_maki.getReadyToOpenCapsule_Maki() {
            capsuleReadyBadge_Maki.isHidden = false
            capsuleCountdownLb_Maki.text = "🎁 \"\(ready_maki.mood_Maki)\" capsule is ready to open!"
        } else {
            capsuleReadyBadge_Maki.isHidden = true
            if let next_maki = capsuleVM_maki.getNextLockedCapsule_Maki() {
                let days_maki = max(1, Calendar.current.dateComponents([.day], from: Date(), to: next_maki.openDate_Maki).day ?? 1)
                capsuleCountdownLb_Maki.text = "Next capsule opens in \(days_maki) day\(days_maki == 1 ? "" : "s")"
            } else {
                capsuleCountdownLb_Maki.text = "Seal your first creation today!"
            }
        }
    }

    /// 刷新成长阶梯卡片：当前等级高亮、进度文字
    private func reloadGrowthArea_Maki() {
        let capsuleVM_maki = CapsuleViewModel_Maki.shared_Maki
        let level_maki = capsuleVM_maki.currentLevel_Maki()
        let toNext_maki = capsuleVM_maki.postsToNextLevel_Maki()

        for circle_maki in growthStepCircles_Maki {
            let isAchieved_maki = circle_maki.tag <= level_maki.rawValue
            let isCurrent_maki  = circle_maki.tag == level_maki.rawValue
            circle_maki.backgroundColor = isAchieved_maki
                ? K_Maki.primaryColor.withAlphaComponent(0.15)
                : UIColor(hexstring_Maki: "#F5F1EA")
            circle_maki.layer.borderWidth = isCurrent_maki ? 2.5 : 0
            circle_maki.layer.borderColor = K_Maki.primaryColor.cgColor
            if let iconIV_maki = circle_maki.subviews.first as? UIImageView {
                iconIV_maki.tintColor = isAchieved_maki ? K_Maki.primaryColor : UIColor(hexstring_Maki: "#C0B4A0")
            }
        }

        growthLevelLb_Maki.text = "\(level_maki.title_Maki) · \(capsuleVM_maki.postsCount_Maki()) creations"
        growthProgressLb_Maki.text = toNext_maki > 0
            ? "\(toNext_maki) more to level up!"
            : "You've reached the top tier! 👑"
    }
}

// MARK: - 胶囊提醒弹窗

extension Home_Maki {

    /// 若存在已解锁但未查看的胶囊，弹窗提醒用户回看
    private func presentCapsuleReminderIfNeeded_Maki() {
        guard presentedViewController == nil,
              let ready_maki = CapsuleViewModel_Maki.shared_Maki.getReadyToOpenCapsule_Maki() else { return }

        let alert_maki = UIAlertController(
            title: "🎁 A Time Capsule Awaits!",
            message: "Your capsule sealed with mood \(ready_maki.mood_Maki) is ready to open. Take a look back at your creation!",
            preferredStyle: .alert
        )
        alert_maki.addAction(UIAlertAction(title: "Later", style: .cancel))
        alert_maki.addAction(UIAlertAction(title: "Open Now", style: .default) { _ in
            Navigation_Maki.toCapsuleDetail_Maki(with: ready_maki)
        })
        present(alert_maki, animated: true)
    }
}

// MARK: - 动画

extension Home_Maki {

    /// 页面进场动画：各模块依次从下方弹性滑入
    private func playEntrance_Maki() {
        let targets_maki: [UIView] = [
            quoteCard_Maki, bannerView_Maki, capsuleCard_Maki, reuseScrollView_Maki, growthCard_Maki
        ]
        for (i_maki, v_maki) in targets_maki.enumerated() {
            v_maki.transform = CGAffineTransform(translationX: 0, y: 40)
            v_maki.alpha = 0
            UIView.animate(
                withDuration: 0.5,
                delay: 0.08 + Double(i_maki) * 0.08,
                usingSpringWithDamping: 0.72,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    v_maki.transform = .identity
                    v_maki.alpha = 1
                }
            )
        }
    }

    /// 触觉反馈
    private func haptic_Maki(_ style_maki: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style_maki).impactOccurred()
    }
}

// MARK: - 事件响应

extension Home_Maki {

    @objc private func onViewCapsules_Maki() {
        haptic_Maki()
        Navigation_Maki.toCapsuleList_Maki()
    }

    @objc private func onNewCapsule_Maki() {
        haptic_Maki()
        Navigation_Maki.toCreateCapsule_Maki()
    }

    @objc private func onViewGrowth_Maki() {
        haptic_Maki()
        Navigation_Maki.toGrowthLadder_Maki()
    }

    /// 点击旧料改造卡片，展示方案详情
    @objc private func onReuseIdeaTap_Maki(_ gesture: UITapGestureRecognizer) {
        guard let ideaId_maki = gesture.view?.tag else { return }
        guard let idea_maki = CapsuleViewModel_Maki.shared_Maki.getReuseIdeas_Maki()
            .first(where: { $0.ideaId_Maki == ideaId_maki }) else { return }
        haptic_Maki()

        let alert_maki = UIAlertController(
            title: "\(idea_maki.beforeMaterial_Maki) → \(idea_maki.afterCreation_Maki)",
            message: idea_maki.description_Maki,
            preferredStyle: .alert
        )
        alert_maki.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert_maki, animated: true)
    }
}

// MARK: - FSPagerViewDataSource & Delegate

extension Home_Maki: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        TitleViewModel_Maki.shared_Maki.getPosts_Maki()
            .sorted { $0.likes_Maki > $1.likes_Maki }
            .prefix(5).count
    }

    /// 轮播展示的热门帖子（按点赞数排序取前5）
    private var hotPosts_Maki: [TitleModel_Maki] {
        Array(TitleViewModel_Maki.shared_Maki.getPosts_Maki().sorted { $0.likes_Maki > $1.likes_Maki }.prefix(5))
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell_maki = pagerView.dequeueReusableCell(
            withReuseIdentifier: K_Maki.bannerCellId,
            at: index
        ) as! HomeBannerCell_Maki
        guard index < hotPosts_Maki.count else { return cell_maki }
        cell_maki.configure_Maki(post_maki: hotPosts_Maki[index])
        return cell_maki
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        guard index < hotPosts_Maki.count else { return }
        haptic_Maki()
        Navigation_Maki.toTitleDetail_Maki(titleModel_maki: hotPosts_Maki[index])
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl_Maki.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl_Maki.currentPage = pagerView.currentIndex
    }
}

// MARK: - 通知绑定

extension Home_Maki {

    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChange_Maki),
            name: TitleViewModel_Maki.titleStateDidChangeNotification_Maki, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChange_Maki),
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChange_Maki),
            name: CapsuleViewModel_Maki.capsuleStateDidChangeNotification_Maki, object: nil
        )
    }

    @objc private func onDataChange_Maki() { reloadAll_Maki() }
}

// MARK: - HomeBannerCell_Maki（热门DIY轮播 Cell）

/// 热门DIY帖子轮播 Cell
/// 功能：以全幅图片 + 底部渐变叠加 + 标题 / 作者 / 点赞角标展示帖子
final class HomeBannerCell_Maki: FSPagerViewCell {

    // MARK: UI 子视图

    private let mediaImageView_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.contentMode = .scaleAspectFill
        iv_maki.clipsToBounds = true
        iv_maki.backgroundColor = UIColor(hexstring_Maki: "#FFF3E0")
        return iv_maki
    }()

    private let gradientView_Maki = UIView()
    private let gradientLayer_Maki = CAGradientLayer()

    private let titleLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lb_maki.textColor = .white
        lb_maki.numberOfLines = 2
        lb_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        lb_maki.layer.shadowOffset = CGSize(width: 0, height: 1)
        lb_maki.layer.shadowRadius = 3
        lb_maki.layer.shadowOpacity = 1
        return lb_maki
    }()

    private let authorLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lb_maki.textColor = UIColor.white.withAlphaComponent(0.88)
        return lb_maki
    }()

    private let likesBadge_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_maki.layer.cornerRadius = 13
        v_maki.layer.borderWidth = 1
        v_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        return v_maki
    }()

    private let likesLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lb_maki.textColor = .white
        return lb_maki
    }()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Maki()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Maki.frame = gradientView_Maki.bounds
    }

    // MARK: UI 搭建

    private func setupUI_Maki() {
        layer.cornerRadius = 18
        clipsToBounds = true

        contentView.addSubview(mediaImageView_Maki)
        mediaImageView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        gradientLayer_Maki.colors = [
            UIColor.clear.cgColor,
            UIColor(hexstring_Maki: "#000000").withAlphaComponent(0.72).cgColor
        ]
        gradientLayer_Maki.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer_Maki.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradientView_Maki.layer.insertSublayer(gradientLayer_Maki, at: 0)
        contentView.addSubview(gradientView_Maki)
        gradientView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(titleLabel_Maki)
        titleLabel_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-42)
        }

        contentView.addSubview(authorLabel_Maki)
        authorLabel_Maki.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Maki)
            make.top.equalTo(titleLabel_Maki.snp.bottom).offset(5)
        }

        contentView.addSubview(likesBadge_Maki)
        likesBadge_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(26)
        }
        likesBadge_Maki.addSubview(likesLabel_Maki)
        likesLabel_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }

    // MARK: 配置方法

    /// 配置轮播 Cell 数据
    /// - Parameter post_maki: 帖子模型
    func configure_Maki(post_maki: TitleModel_Maki) {
        if let mediaName_maki = post_maki.titleMeidas_Maki.first {
            let img_maki = UIImage(named: mediaName_maki)
            mediaImageView_Maki.image = img_maki ?? UIImage(systemName: "photo.on.rectangle.angled")
            if img_maki == nil {
                mediaImageView_Maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
                mediaImageView_Maki.backgroundColor = UIColor(hexstring_Maki: "#FFF3E0")
            }
        }
        titleLabel_Maki.text  = post_maki.title_Maki
        authorLabel_Maki.text = "by  \(post_maki.titleUserName_Maki)"
        likesLabel_Maki.text  = "🔥 \(post_maki.likes_Maki)"
    }
}
