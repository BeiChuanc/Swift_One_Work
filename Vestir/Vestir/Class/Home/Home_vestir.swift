import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页
/// 功能：
///   1. 日常 OOTD 打卡主线（今日打卡卡片 + 连续签到天数）
///   2. 本周穿搭日历（7 格可视化日历，已打卡显示缩略图）
///   3. 穿搭挑战社群（官方主题挑战列表，点击进入详情讨论区）
class Home_Vestir: UIViewController {

    // MARK: - 渐变头部

    private let headerView_Vestir = HomeHeaderCard_Vestir()

    private let greetingLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Vestir.textColor = UIColor.white.withAlphaComponent(0.82)
        return lbl_Vestir
    }()

    private let nameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl_Vestir.textColor = .white
        return lbl_Vestir
    }()

    private let avatarView_Vestir: CurrentUserAvatarView_Vestir = {
        let av_Vestir = CurrentUserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 22
        av_Vestir.clipsToBounds = true
        av_Vestir.layer.borderWidth = 2
        av_Vestir.layer.borderColor = UIColor(white: 1.0, alpha: 0.75).cgColor
        return av_Vestir
    }()

    /// 头部装饰圆 1（右上，白色 10% alpha）
    private let headerDecoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        v_Vestir.layer.cornerRadius = 52
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 头部装饰圆 2（左下，天蓝 20% alpha）
    private let headerDecoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#93C5FD", alpha_Vestir: 0.18)
        v_Vestir.layer.cornerRadius = 34
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 头部副标语
    private let headerTaglineLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Your Style · Your Story  ✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.55)
        return lbl_Vestir
    }()

    // MARK: - 滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        sv_Vestir.alwaysBounceVertical = true
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    // MARK: - ① 每日 OOTD 打卡区块

    /// 打卡区域标题行
    private let checkInSectionRow_Vestir: UIView = UIView()

    private let checkInDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#E11D48")
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    private let checkInSectionTitle_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Daily OOTD"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 连续签到天数胶囊
    private let streakBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Vestir.textColor = UIColor(hexstring_Vestir: "#E11D48")
        lbl_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FFF1F2")
        lbl_Vestir.layer.cornerRadius = 10
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 打卡按钮（未打卡：渐变背景；已打卡：灰色）
    private lazy var checkInActionBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.layer.cornerRadius = 14
        btn_Vestir.clipsToBounds = true
        btn_Vestir.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        btn_Vestir.addTarget(self, action: #selector(checkInCardTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    private let checkInActionGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#E11D48").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor
        ]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        g_Vestir.cornerRadius = 14
        return g_Vestir
    }()

    /// 打卡记录列表
    private let checkInListStack_Vestir: UIStackView = {
        let sv_Vestir = UIStackView()
        sv_Vestir.axis = .vertical
        sv_Vestir.spacing = 10
        return sv_Vestir
    }()

    // MARK: - ② 本周穿搭日历

    private let calendarSectionRow_Vestir: UIView = UIView()
    private let calendarDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.primaryGradientEnd_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()
    private let calendarTitle_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "This Week"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 7 个日历格子容器
    private let calendarRow_Vestir: UIStackView = {
        let sv_Vestir = UIStackView()
        sv_Vestir.axis = .horizontal
        sv_Vestir.distribution = .fillEqually
        sv_Vestir.spacing = 6
        return sv_Vestir
    }()

    // MARK: - ⓪ 热门推荐轮播

    /// 轮播分区标题行
    private let bannerSectionRow_Vestir: UIView = UIView()
    private let bannerDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#D97706")
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()
    private let bannerSectionTitle_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Hot Picks  🔥"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 轮播容器（圆角阴影卡）
    private let bannerContainer_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 18
        v_Vestir.clipsToBounds = false
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#D97706").cgColor
        v_Vestir.layer.shadowOpacity = 0.18
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_Vestir.layer.shadowRadius = 14
        return v_Vestir
    }()

    /// 水平分页滚动视图
    private let bannerScrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.isPagingEnabled = true
        sv_Vestir.showsHorizontalScrollIndicator = false
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.clipsToBounds = true
        sv_Vestir.layer.cornerRadius = 18
        return sv_Vestir
    }()

    /// 轮播页码指示器
    private let bannerPageControl_Vestir: UIPageControl = {
        let pc_Vestir = UIPageControl()
        pc_Vestir.currentPageIndicatorTintColor = .white
        pc_Vestir.pageIndicatorTintColor = UIColor(white: 1.0, alpha: 0.40)
        pc_Vestir.hidesForSinglePage = true
        return pc_Vestir
    }()

    private var bannerPosts_Vestir: [TitleModel_Vestir] = []
    private var bannerCurrentIndex_Vestir = 0
    private var bannerTimer_Vestir: Timer?

    // MARK: - ③ 穿搭挑战社群

    private let challengeSectionRow_Vestir: UIView = UIView()
    private let challengeDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.heartColor_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()
    private let challengeTitle_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Style Challenges"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    private let challengeStack_Vestir: UIStackView = {
        let sv_Vestir = UIStackView()
        sv_Vestir.axis = .vertical
        sv_Vestir.spacing = 12
        return sv_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        bindNotifications_Vestir()
        loadAll_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadAll_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步打卡按钮渐变 frame
        checkInActionGradLayer_Vestir.frame = checkInActionBtn_Vestir.bounds
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerView_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 104)
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        // 头部
        view.addSubview(headerView_Vestir)
        // 装饰圆先加（z 轴最低，在文字层后面）
        headerView_Vestir.addSubview(headerDecoCircle1_Vestir)
        headerView_Vestir.addSubview(headerDecoCircle2_Vestir)
        headerView_Vestir.addSubview(greetingLabel_Vestir)
        headerView_Vestir.addSubview(nameLabel_Vestir)
        headerView_Vestir.addSubview(headerTaglineLabel_Vestir)
        headerView_Vestir.addSubview(avatarView_Vestir)

        // 滚动内容
        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)

        // ⓪ 热门推荐轮播
        contentView_Vestir.addSubview(bannerSectionRow_Vestir)
        bannerSectionRow_Vestir.addSubview(bannerDot_Vestir)
        bannerSectionRow_Vestir.addSubview(bannerSectionTitle_Vestir)
        contentView_Vestir.addSubview(bannerContainer_Vestir)
        bannerContainer_Vestir.addSubview(bannerScrollView_Vestir)
        bannerContainer_Vestir.addSubview(bannerPageControl_Vestir)
        bannerScrollView_Vestir.delegate = self

        // ① 打卡区块（标题行 + 记录列表）
        contentView_Vestir.addSubview(checkInSectionRow_Vestir)
        checkInSectionRow_Vestir.addSubview(checkInDot_Vestir)
        checkInSectionRow_Vestir.addSubview(checkInSectionTitle_Vestir)
        checkInSectionRow_Vestir.addSubview(streakBadge_Vestir)
        checkInSectionRow_Vestir.addSubview(checkInActionBtn_Vestir)
        checkInActionBtn_Vestir.layer.insertSublayer(checkInActionGradLayer_Vestir, at: 0)
        contentView_Vestir.addSubview(checkInListStack_Vestir)

        // ② 周日历
        contentView_Vestir.addSubview(calendarSectionRow_Vestir)
        calendarSectionRow_Vestir.addSubview(calendarDot_Vestir)
        calendarSectionRow_Vestir.addSubview(calendarTitle_Vestir)
        contentView_Vestir.addSubview(calendarRow_Vestir)

        // ③ 挑战社群
        contentView_Vestir.addSubview(challengeSectionRow_Vestir)
        challengeSectionRow_Vestir.addSubview(challengeDot_Vestir)
        challengeSectionRow_Vestir.addSubview(challengeTitle_Vestir)
        contentView_Vestir.addSubview(challengeStack_Vestir)

        // 头像点击 → 直接切换 TabBar 到「我的」tab（index 4），无需登录判断
        avatarView_Vestir.onTapped_Vestir = { [weak self] in
            self?.tabBarController?.selectedIndex = 4
        }
    }

    private func setupConstraints_Vestir() {
        // 头部
        headerView_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 104)
        }
        // 装饰圆约束
        headerDecoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(104)
            make.trailing.equalToSuperview().offset(26)
            make.top.equalToSuperview().offset(-26)
        }
        headerDecoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(68)
            make.leading.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(18)
        }
        avatarView_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(nameLabel_Vestir)
            make.width.height.equalTo(46)
        }
        greetingLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalTo(nameLabel_Vestir.snp.top).offset(-3)
        }
        nameLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-28)
            make.trailing.lessThanOrEqualTo(avatarView_Vestir.snp.leading).offset(-12)
        }
        headerTaglineLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalTo(nameLabel_Vestir.snp.bottom).offset(3)
        }

        // 滚动容器
        scrollView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(headerView_Vestir.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // ⓪ 热门推荐轮播
        bannerSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(20)
        }
        bannerDot_Vestir.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        bannerSectionTitle_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(bannerDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        bannerContainer_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bannerSectionRow_Vestir.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(180)
        }
        bannerScrollView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bannerPageControl_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }

        // ① 打卡标题行 + 记录列表
        checkInSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bannerContainer_Vestir.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(30)
        }
        checkInDot_Vestir.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        checkInSectionTitle_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(checkInDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        streakBadge_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(checkInSectionTitle_Vestir.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        checkInActionBtn_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
        checkInListStack_Vestir.snp.makeConstraints { make in
            make.top.equalTo(checkInSectionRow_Vestir.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // ② 周日历
        calendarSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(checkInListStack_Vestir.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(20)
        }
        calendarDot_Vestir.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        calendarTitle_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(calendarDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        calendarRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(calendarSectionRow_Vestir.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(74)
        }

        // ③ 挑战社群
        challengeSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(calendarRow_Vestir.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(20)
        }
        challengeDot_Vestir.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        challengeTitle_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(challengeDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        challengeStack_Vestir.snp.makeConstraints { make in
            make.top.equalTo(challengeSectionRow_Vestir.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            // 底部留白 = Tab Bar 高度(~80pt) + 安全区(~34pt) + 呼吸感(26pt) = 140pt
            make.bottom.equalToSuperview().offset(-140)
        }
    }

    // MARK: - 全量数据加载

    private func loadAll_Vestir() {
        loadUserInfo_Vestir()
        loadBanner_Vestir()
        loadCheckIn_Vestir()
        loadCalendar_Vestir()
        loadChallenges_Vestir()
    }

    // MARK: 热门推荐轮播

    /// 加载热门帖子轮播（按点赞数降序取前 5）
    private func loadBanner_Vestir() {
        bannerPosts_Vestir = Array(
            TitleViewModel_Vestir.shared_Vestir.getPosts_Vestir()
                .sorted { $0.likes_Vestir > $1.likes_Vestir }
                .prefix(5)
        )

        // 清理旧内容
        bannerScrollView_Vestir.subviews.forEach { $0.removeFromSuperview() }
        bannerTimer_Vestir?.invalidate()

        guard !bannerPosts_Vestir.isEmpty else { return }

        bannerPageControl_Vestir.numberOfPages = bannerPosts_Vestir.count
        bannerPageControl_Vestir.currentPage = 0
        bannerCurrentIndex_Vestir = 0

        let bannerWidth_Vestir = UIScreen.main.bounds.width - 32  // 左右各 16pt 内边距
        let bannerH_Vestir: CGFloat = 180

        for (idx_Vestir, post_Vestir) in bannerPosts_Vestir.enumerated() {
            let cell_Vestir = buildBannerCell_Vestir(
                post_vestir: post_Vestir,
                index_vestir: idx_Vestir,
                width_vestir: bannerWidth_Vestir,
                height_vestir: bannerH_Vestir
            )
            bannerScrollView_Vestir.addSubview(cell_Vestir)
            cell_Vestir.frame = CGRect(
                x: CGFloat(idx_Vestir) * bannerWidth_Vestir,
                y: 0,
                width: bannerWidth_Vestir,
                height: bannerH_Vestir
            )
        }
        bannerScrollView_Vestir.contentSize = CGSize(
            width: bannerWidth_Vestir * CGFloat(bannerPosts_Vestir.count),
            height: bannerH_Vestir
        )

        // 启动自动滚动（每 3.5 秒切换一张）
        bannerTimer_Vestir = Timer.scheduledTimer(
            withTimeInterval: 3.5, repeats: true
        ) { [weak self] _ in
            self?.scrollBannerToNext_Vestir()
        }
        RunLoop.current.add(bannerTimer_Vestir!, forMode: .common)
    }

    /// 构建单张轮播 Cell（背景图 + 渐变遮罩 + 标题 + 作者）
    private func buildBannerCell_Vestir(
        post_vestir: TitleModel_Vestir,
        index_vestir: Int,
        width_vestir: CGFloat,
        height_vestir: CGFloat
    ) -> UIView {
        let cell_Vestir = UIView()
        cell_Vestir.clipsToBounds = true

        // 背景媒体图
        let media_Vestir = MediaDisplayView_Vestir()
        media_Vestir.customPlaceholderColors_Vestir = DiscoverCell_Vestir.cardGradients_Vestir[
            index_vestir % DiscoverCell_Vestir.cardGradients_Vestir.count
        ]
        media_Vestir.configure_Vestir(mediaPath_Vestir: post_vestir.titleMeidas_Vestir.first)
        cell_Vestir.addSubview(media_Vestir)
        media_Vestir.frame = CGRect(x: 0, y: 0, width: width_vestir, height: height_vestir)

        // 底部渐变遮罩
        let overlayLayer_Vestir = CAGradientLayer()
        overlayLayer_Vestir.frame = CGRect(
            x: 0, y: height_vestir * 0.45,
            width: width_vestir, height: height_vestir * 0.55
        )
        overlayLayer_Vestir.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 0, alpha: 0.70).cgColor
        ]
        overlayLayer_Vestir.locations = [0, 1.0]
        cell_Vestir.layer.addSublayer(overlayLayer_Vestir)

        // 标题
        let titleLbl_Vestir = UILabel()
        titleLbl_Vestir.text = post_vestir.title_Vestir
        titleLbl_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLbl_Vestir.textColor = .white
        titleLbl_Vestir.numberOfLines = 2
        titleLbl_Vestir.layer.shadowColor = UIColor.black.cgColor
        titleLbl_Vestir.layer.shadowOpacity = 0.4
        titleLbl_Vestir.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleLbl_Vestir.layer.shadowRadius = 3

        // 作者名 + 点赞数
        let metaLbl_Vestir = UILabel()
        metaLbl_Vestir.text = "\(post_vestir.titleUserName_Vestir)  ♥ \(post_vestir.likes_Vestir)"
        metaLbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        metaLbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.82)

        cell_Vestir.addSubview(metaLbl_Vestir)
        cell_Vestir.addSubview(titleLbl_Vestir)

        // frame-based 布局（bannerScrollView 内无 Auto Layout）
        let pad_Vestir: CGFloat = 14
        metaLbl_Vestir.frame = CGRect(
            x: pad_Vestir,
            y: height_vestir - 36,
            width: width_vestir - pad_Vestir * 2,
            height: 18
        )
        titleLbl_Vestir.frame = CGRect(
            x: pad_Vestir,
            y: height_vestir - 72,
            width: width_vestir - pad_Vestir * 2,
            height: 42
        )

        // 举报/删除按钮（右上角，磨砂黑圆形背景）
        let reportBtn_Vestir = ReportDeleteHelper_Vestir.createPostReportButton_Vestir(
            post_Vestir: post_vestir,
            size_Vestir: 15,
            color_Vestir: UIColor(white: 1.0, alpha: 0.90),
            from: self
        ) { [weak self] in
            self?.loadBanner_Vestir()
        }
        reportBtn_Vestir.backgroundColor = UIColor(white: 0, alpha: 0.32)
        reportBtn_Vestir.layer.cornerRadius = 16
        reportBtn_Vestir.clipsToBounds = true
        reportBtn_Vestir.frame = CGRect(
            x: width_vestir - 44,
            y: 10,
            width: 32,
            height: 32
        )
        cell_Vestir.addSubview(reportBtn_Vestir)

        // 点击跳转帖子详情
        let postId_Vestir = post_vestir.titleId_Vestir
        let tap_Vestir = UITapGestureRecognizer(target: self, action: #selector(bannerCellTapped_Vestir(_:)))
        cell_Vestir.isUserInteractionEnabled = true
        cell_Vestir.tag = postId_Vestir
        cell_Vestir.addGestureRecognizer(tap_Vestir)

        return cell_Vestir
    }

    /// 自动滚动到下一张
    private func scrollBannerToNext_Vestir() {
        guard !bannerPosts_Vestir.isEmpty else { return }
        let next_Vestir = (bannerCurrentIndex_Vestir + 1) % bannerPosts_Vestir.count
        let bannerWidth_Vestir = UIScreen.main.bounds.width - 32
        bannerScrollView_Vestir.setContentOffset(
            CGPoint(x: CGFloat(next_Vestir) * bannerWidth_Vestir, y: 0),
            animated: true
        )
        bannerCurrentIndex_Vestir = next_Vestir
        bannerPageControl_Vestir.currentPage = next_Vestir
    }

    // MARK: 用户信息

    private func loadUserInfo_Vestir() {
        let user_Vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
        let hour_Vestir = Calendar.current.component(.hour, from: Date())
        greetingLabel_Vestir.text = hour_Vestir < 12 ? "Good Morning ☀️"
            : (hour_Vestir < 18 ? "Good Afternoon 🌤" : "Good Evening 🌙")
        nameLabel_Vestir.text = user_Vestir.userId_Vestir == 0
            ? "Trendsetter"
            : (user_Vestir.userName_Vestir ?? "Trendsetter")
    }

    // MARK: 打卡状态 + 记录列表

    private func loadCheckIn_Vestir() {
        let vm_Vestir = CheckInViewModel_Vestir.shared_Vestir

        // 连续天数徽章
        let streak_Vestir = vm_Vestir.streakCount_Vestir
        streakBadge_Vestir.text = "  🔥 \(streak_Vestir) day\(streak_Vestir == 1 ? "" : "s")  "
        streakBadge_Vestir.isHidden = streak_Vestir == 0

        // 打卡按钮状态
        if vm_Vestir.isCheckedInToday_Vestir {
            checkInActionBtn_Vestir.setTitle("✓  Done", for: .normal)
            checkInActionGradLayer_Vestir.opacity = 0
            checkInActionBtn_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir
            checkInActionBtn_Vestir.setTitleColor(ColorConfig_Vestir.textSecondary_Vestir, for: .normal)
            checkInActionBtn_Vestir.isUserInteractionEnabled = false
        } else {
            checkInActionBtn_Vestir.setTitle("+ Check In", for: .normal)
            checkInActionGradLayer_Vestir.opacity = 1
            checkInActionBtn_Vestir.backgroundColor = .clear
            checkInActionBtn_Vestir.setTitleColor(.white, for: .normal)
            checkInActionBtn_Vestir.isUserInteractionEnabled = true
        }

        // 重建记录列表（按日期降序）
        rebuildCheckInList_Vestir()
    }

    /// 重建打卡记录卡片列表
    private func rebuildCheckInList_Vestir() {
        checkInListStack_Vestir.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let records_Vestir = CheckInViewModel_Vestir.shared_Vestir.getAllCheckIns_Vestir()

        if records_Vestir.isEmpty {
            let emptyLbl_Vestir = UILabel()
            emptyLbl_Vestir.text = "No check-ins yet. Start your OOTD streak today! ✨"
            emptyLbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            emptyLbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
            emptyLbl_Vestir.textAlignment = .center
            emptyLbl_Vestir.numberOfLines = 2
            checkInListStack_Vestir.addArrangedSubview(emptyLbl_Vestir)
            return
        }

        for record_Vestir in records_Vestir {
            let card_Vestir = buildCheckInRecord_Vestir(checkIn_vestir: record_Vestir)
            checkInListStack_Vestir.addArrangedSubview(card_Vestir)
        }
    }

    /// 构建单条打卡记录卡片
    /// 设计：左侧玫瑰色条 + 缩略图 + 日期（含 Today 徽章）+ 标签 + 删除按钮
    private func buildCheckInRecord_Vestir(checkIn_vestir: DailyCheckIn_Vestir) -> UIView {
        let isToday_Vestir = (checkIn_vestir.date_Vestir == CheckInViewModel_Vestir.shared_Vestir.todayString_Vestir)

        let card_Vestir = UIView()
        card_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        card_Vestir.layer.cornerRadius = 18
        card_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#E11D48").cgColor
        card_Vestir.layer.shadowOpacity = isToday_Vestir ? 0.18 : 0.10
        card_Vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Vestir.layer.shadowRadius = 12
        card_Vestir.clipsToBounds = false
        card_Vestir.isUserInteractionEnabled = true

        // 左侧渐变色条（玫瑰色）
        let accentBar_Vestir = UIView()
        accentBar_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#E11D48")
        accentBar_Vestir.layer.cornerRadius = 2

        // 内容容器（clip = true，避免色条超出圆角）
        let innerCard_Vestir = UIView()
        innerCard_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        innerCard_Vestir.layer.cornerRadius = 18
        innerCard_Vestir.clipsToBounds = true

        card_Vestir.addSubview(innerCard_Vestir)
        innerCard_Vestir.addSubview(accentBar_Vestir)
        innerCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        accentBar_Vestir.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        // 左侧缩略图
        let thumb_Vestir = MediaDisplayView_Vestir()
        thumb_Vestir.layer.cornerRadius = 12
        thumb_Vestir.clipsToBounds = true
        thumb_Vestir.customPlaceholderColors_Vestir = [
            UIColor(hexstring_Vestir: "#FECDD3").cgColor,
            UIColor(hexstring_Vestir: "#FDE68A").cgColor
        ]
        thumb_Vestir.configure_Vestir(mediaPath_Vestir: checkIn_vestir.mediaPath_Vestir)

        // 日期标签 + Today 徽章
        let dateRow_Vestir = UIView()
        let dateLbl_Vestir = UILabel()
        dateLbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        dateLbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        dateLbl_Vestir.text = formatDateForDisplay_Vestir(checkIn_vestir.date_Vestir)

        let todayBadge_Vestir = UILabel()
        todayBadge_Vestir.text = "  Today  "
        todayBadge_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        todayBadge_Vestir.textColor = UIColor(hexstring_Vestir: "#E11D48")
        todayBadge_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FFF1F2")
        todayBadge_Vestir.layer.cornerRadius = 8
        todayBadge_Vestir.clipsToBounds = true
        todayBadge_Vestir.isHidden = !isToday_Vestir

        dateRow_Vestir.addSubview(dateLbl_Vestir)
        dateRow_Vestir.addSubview(todayBadge_Vestir)
        dateLbl_Vestir.snp.makeConstraints { make in make.leading.centerY.equalToSuperview() }
        todayBadge_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(dateLbl_Vestir.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
            make.trailing.lessThanOrEqualToSuperview()
        }

        // 标签行（小圆点分隔）
        let tagsLbl_Vestir = UILabel()
        tagsLbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        tagsLbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        var tags_Vestir: [String] = []
        if let o = checkIn_vestir.occasion_Vestir { tags_Vestir.append(o) }
        if let b = checkIn_vestir.brand_Vestir, !b.isEmpty { tags_Vestir.append(b) }
        if let t = checkIn_vestir.temperature_Vestir, !t.isEmpty { tags_Vestir.append(t) }
        tagsLbl_Vestir.text = tags_Vestir.isEmpty ? "OOTD ✦" : tags_Vestir.joined(separator: "  ·  ")

        // 右侧删除按钮
        let deleteBtn_Vestir = UIButton(type: .system)
        let delCfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        deleteBtn_Vestir.setImage(
            UIImage(systemName: "trash", withConfiguration: delCfg_Vestir), for: .normal
        )
        deleteBtn_Vestir.tintColor = ColorConfig_Vestir.textPlaceholder_Vestir
        let date_Vestir = checkIn_vestir.date_Vestir
        deleteBtn_Vestir.addAction(UIAction { [weak self] _ in
            self?.confirmDeleteCheckIn_Vestir(dateString_vestir: date_Vestir)
        }, for: .touchUpInside)

        innerCard_Vestir.addSubview(thumb_Vestir)
        innerCard_Vestir.addSubview(dateRow_Vestir)
        innerCard_Vestir.addSubview(tagsLbl_Vestir)
        innerCard_Vestir.addSubview(deleteBtn_Vestir)

        thumb_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(72)
            make.height.equalTo(72)
        }
        deleteBtn_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }
        dateRow_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(thumb_Vestir.snp.trailing).offset(12)
            make.top.equalTo(thumb_Vestir.snp.top).offset(8)
            make.trailing.lessThanOrEqualTo(deleteBtn_Vestir.snp.leading).offset(-6)
            make.height.equalTo(20)
        }
        tagsLbl_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(thumb_Vestir.snp.trailing).offset(12)
            make.top.equalTo(dateRow_Vestir.snp.bottom).offset(6)
            make.trailing.lessThanOrEqualTo(deleteBtn_Vestir.snp.leading).offset(-6)
        }

        // 点击卡片 → 底部弹窗展示详情
        let tap_Vestir = UITapGestureRecognizer(target: self, action: #selector(checkInRecordTapped_Vestir(_:)))
        card_Vestir.addGestureRecognizer(tap_Vestir)
        card_Vestir.tag = abs(date_Vestir.hashValue) % 100000  // 简单 tag，通过 sender view 获取

        // 将打卡记录存到 accessibilityLabel 以便点击时检索（不影响无障碍，仅内部使用）
        card_Vestir.accessibilityLabel = date_Vestir

        return card_Vestir
    }

    /// 格式化日期用于显示（yyyy-MM-dd → Jun 5, 2026）
    private func formatDateForDisplay_Vestir(_ dateString_vestir: String) -> String {
        let f1_Vestir = DateFormatter()
        f1_Vestir.dateFormat = "yyyy-MM-dd"
        guard let date_Vestir = f1_Vestir.date(from: dateString_vestir) else { return dateString_vestir }
        let f2_Vestir = DateFormatter()
        f2_Vestir.dateStyle = .medium
        return f2_Vestir.string(from: date_Vestir)
    }

    /// 确认删除打卡记录弹窗
    private func confirmDeleteCheckIn_Vestir(dateString_vestir: String) {
        let alert_Vestir = UIAlertController(
            title: "Delete Check-in",
            message: "Remove this outfit check-in? This cannot be undone.",
            preferredStyle: .alert
        )
        alert_Vestir.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { @MainActor in
                CheckInViewModel_Vestir.shared_Vestir.deleteCheckIn_Vestir(
                    dateString_vestir: dateString_vestir
                )
            }
        })
        alert_Vestir.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Vestir, animated: true)
    }

    /// 点击打卡记录卡片 → 底部弹窗展示详情
    @objc private func checkInRecordTapped_Vestir(_ gesture: UITapGestureRecognizer) {
        guard let view_Vestir = gesture.view,
              let dateString_Vestir = view_Vestir.accessibilityLabel,
              let record_Vestir = CheckInViewModel_Vestir.shared_Vestir.getCheckIn_Vestir(
                  for: dateString_Vestir
              )
        else { return }

        view_Vestir.animatePressDown_Vestir { view_Vestir.animatePressUp_Vestir() }

        let detailSheet_Vestir = CheckInDetailSheet_Vestir()
        detailSheet_Vestir.checkIn_Vestir = record_Vestir
        detailSheet_Vestir.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet_Vestir = detailSheet_Vestir.sheetPresentationController {
                sheet_Vestir.detents = [.large()]
                sheet_Vestir.prefersGrabberVisible = true
                sheet_Vestir.preferredCornerRadius = 24
            }
        }
        present(detailSheet_Vestir, animated: true)
    }

    // MARK: 周日历

    private func loadCalendar_Vestir() {
        calendarRow_Vestir.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let vm_Vestir = CheckInViewModel_Vestir.shared_Vestir
        let today_Vestir = vm_Vestir.todayString_Vestir
        let dates_Vestir = vm_Vestir.currentWeekDates_Vestir()

        for date_Vestir in dates_Vestir {
            let isToday_Vestir = (date_Vestir == today_Vestir)
            let checkIn_Vestir = vm_Vestir.getCheckIn_Vestir(for: date_Vestir)
            let cell_Vestir = buildCalendarCell_Vestir(
                dateString_vestir: date_Vestir,
                isToday_vestir: isToday_Vestir,
                checkIn_vestir: checkIn_Vestir
            )
            calendarRow_Vestir.addArrangedSubview(cell_Vestir)
        }
    }

    /// 构建单个日历格子
    /// 设计：今日渐变背景 + 白色数字；已打卡缩略图 + 绿色边框；未打卡虚线圆
    private func buildCalendarCell_Vestir(
        dateString_vestir: String,
        isToday_vestir: Bool,
        checkIn_vestir: DailyCheckIn_Vestir?
    ) -> UIView {
        let vm_Vestir = CheckInViewModel_Vestir.shared_Vestir
        let isCheckedIn_Vestir = checkIn_vestir != nil

        // 外层阴影容器
        let shadow_Vestir = UIView()
        shadow_Vestir.backgroundColor = .clear
        shadow_Vestir.layer.shadowColor = isToday_vestir
            ? ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
            : UIColor.black.cgColor
        shadow_Vestir.layer.shadowOpacity = isToday_vestir ? 0.22 : 0.07
        shadow_Vestir.layer.shadowOffset = CGSize(width: 0, height: 3)
        shadow_Vestir.layer.shadowRadius = isToday_vestir ? 8 : 5

        // 格子主体
        let cell_Vestir = UIView()
        cell_Vestir.layer.cornerRadius = 14
        cell_Vestir.clipsToBounds = true

        // 今日用自管理渐变背景
        if isToday_vestir {
            let todayCard_Vestir = CalendarTodayCell_Vestir()
            cell_Vestir.addSubview(todayCard_Vestir)
            todayCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        } else {
            cell_Vestir.backgroundColor = isCheckedIn_Vestir
                ? UIColor(hexstring_Vestir: "#F0FDF4")   // 已打卡：淡绿
                : ColorConfig_Vestir.backgroundSecondary_Vestir
            if isCheckedIn_Vestir {
                cell_Vestir.layer.borderWidth = 1.5
                cell_Vestir.layer.borderColor = UIColor(hexstring_Vestir: "#22C55E").cgColor
            }
        }

        shadow_Vestir.addSubview(cell_Vestir)
        cell_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 星期缩写（顶部）
        let dayLabel_Vestir = UILabel()
        dayLabel_Vestir.text = vm_Vestir.dayAbbr_Vestir(from: dateString_vestir)
        dayLabel_Vestir.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        dayLabel_Vestir.textColor = isToday_vestir
            ? UIColor(white: 1.0, alpha: 0.78)
            : (isCheckedIn_Vestir ? UIColor(hexstring_Vestir: "#15803D") : ColorConfig_Vestir.textPlaceholder_Vestir)
        dayLabel_Vestir.textAlignment = .center

        // 日期数字（中）
        let dateLabel_Vestir = UILabel()
        dateLabel_Vestir.text = vm_Vestir.dayNumber_Vestir(from: dateString_vestir)
        dateLabel_Vestir.font = UIFont.systemFont(ofSize: 14, weight: isToday_vestir ? .heavy : .semibold)
        dateLabel_Vestir.textColor = isToday_vestir
            ? .white
            : (isCheckedIn_Vestir ? UIColor(hexstring_Vestir: "#15803D") : ColorConfig_Vestir.textPrimary_Vestir)
        dateLabel_Vestir.textAlignment = .center

        // 打卡指示器（顶部小图/圆点）
        let indicator_Vestir = UIView()
        if let ci_Vestir = checkIn_vestir, let path_Vestir = ci_Vestir.mediaPath_Vestir {
            let thumb_Vestir = MediaDisplayView_Vestir()
            thumb_Vestir.layer.cornerRadius = 7
            thumb_Vestir.clipsToBounds = true
            thumb_Vestir.configure_Vestir(mediaPath_Vestir: path_Vestir)
            indicator_Vestir.addSubview(thumb_Vestir)
            thumb_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        } else if isCheckedIn_Vestir {
            indicator_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#22C55E")
            indicator_Vestir.layer.cornerRadius = 4
        } else {
            indicator_Vestir.layer.cornerRadius = 4
            indicator_Vestir.layer.borderWidth = 1
            indicator_Vestir.layer.borderColor = isToday_vestir
                ? UIColor(white: 1.0, alpha: 0.40).cgColor
                : ColorConfig_Vestir.divider_Vestir.cgColor
        }

        cell_Vestir.addSubview(indicator_Vestir)
        cell_Vestir.addSubview(dateLabel_Vestir)
        cell_Vestir.addSubview(dayLabel_Vestir)

        indicator_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(isCheckedIn_Vestir ? 28 : 8)
        }
        dateLabel_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(dayLabel_Vestir.snp.top).offset(-1)
        }
        dayLabel_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
        }

        return shadow_Vestir
    }

    // MARK: 挑战列表

    private func loadChallenges_Vestir() {
        challengeStack_Vestir.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let challenges_Vestir = LocalData_Vestir.shared_Vestir.challengeList_Vestir
        for (idx_Vestir, challenge_Vestir) in challenges_Vestir.enumerated() {
            let card_Vestir = buildChallengeCard_Vestir(
                challenge_vestir: challenge_Vestir,
                index_vestir: idx_Vestir
            )
            card_Vestir.alpha = 0
            challengeStack_Vestir.addArrangedSubview(card_Vestir)
            card_Vestir.animateSlideInFromBottom_Vestir(
                offset_Vestir: 30, delay_Vestir: Double(idx_Vestir) * 0.08
            )
        }
    }

    // MARK: - 挑战卡片颜色矩阵（每张卡片独立调色，循环使用）

    private static let challengeColors_Vestir: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Vestir: "#6B21A8"), UIColor(hexstring_Vestir: "#9333EA")),  // 紫罗兰
        (UIColor(hexstring_Vestir: "#D97706"), UIColor(hexstring_Vestir: "#F59E0B")),  // 琥珀橙
        (UIColor(hexstring_Vestir: "#0F766E"), UIColor(hexstring_Vestir: "#0D9488")),  // 青绿
    ]

    /// 构建挑战卡片
    /// 设计：顶部渐变色条 + 渐变圆形图标 + 标题/徽章/箭头 + 描述 + 彩色统计胶囊
    private func buildChallengeCard_Vestir(
        challenge_vestir: OutfitChallenge_Vestir,
        index_vestir: Int
    ) -> UIView {
        let colorPair_Vestir = Self.challengeColors_Vestir[
            index_vestir % Self.challengeColors_Vestir.count
        ]
        let primaryColor_Vestir = colorPair_Vestir.0
        let secondaryColor_Vestir = colorPair_Vestir.1

        // ─── 阴影容器（不裁剪）───
        let card_Vestir = UIView()
        card_Vestir.backgroundColor = .clear
        card_Vestir.isUserInteractionEnabled = true

        // ─── 内容卡片（裁剪圆角）───
        let innerCard_Vestir = UIView()
        innerCard_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        innerCard_Vestir.layer.cornerRadius = 20
        innerCard_Vestir.clipsToBounds = true
        innerCard_Vestir.layer.shadowColor = primaryColor_Vestir.cgColor
        innerCard_Vestir.layer.shadowOpacity = 0.16
        innerCard_Vestir.layer.shadowOffset = CGSize(width: 0, height: 5)
        innerCard_Vestir.layer.shadowRadius = 14
        card_Vestir.addSubview(innerCard_Vestir)
        innerCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // ─── 顶部渐变色条（水平渐变，5pt 高）───
        let stripView_Vestir = UIView()
        let cardW_Vestir = UIScreen.main.bounds.width - 32
        let stripGrad_Vestir = CAGradientLayer()
        stripGrad_Vestir.colors = [primaryColor_Vestir.cgColor, secondaryColor_Vestir.cgColor]
        stripGrad_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        stripGrad_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        stripGrad_Vestir.frame = CGRect(x: 0, y: 0, width: cardW_Vestir, height: 5)
        stripView_Vestir.layer.insertSublayer(stripGrad_Vestir, at: 0)
        innerCard_Vestir.addSubview(stripView_Vestir)
        stripView_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(5)
        }

        // ─── 渐变圆形图标（52pt）───
        let circleSize_Vestir: CGFloat = 52
        let iconCircle_Vestir = UIView()
        iconCircle_Vestir.layer.cornerRadius = circleSize_Vestir / 2
        iconCircle_Vestir.clipsToBounds = true
        let circleGrad_Vestir = CAGradientLayer()
        circleGrad_Vestir.colors = [primaryColor_Vestir.cgColor, secondaryColor_Vestir.cgColor]
        circleGrad_Vestir.startPoint = CGPoint(x: 0, y: 0)
        circleGrad_Vestir.endPoint = CGPoint(x: 1, y: 1)
        circleGrad_Vestir.frame = CGRect(x: 0, y: 0, width: circleSize_Vestir, height: circleSize_Vestir)
        iconCircle_Vestir.layer.insertSublayer(circleGrad_Vestir, at: 0)

        let iconView_Vestir = UIImageView()
        let iconCfg_Vestir = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iconView_Vestir.image = UIImage(
            systemName: challenge_vestir.badgeIcon_Vestir,
            withConfiguration: iconCfg_Vestir
        )
        iconView_Vestir.tintColor = .white
        iconView_Vestir.contentMode = .scaleAspectFit
        iconCircle_Vestir.addSubview(iconView_Vestir)
        iconView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        innerCard_Vestir.addSubview(iconCircle_Vestir)
        iconCircle_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(stripView_Vestir.snp.bottom).offset(16)
            make.width.height.equalTo(circleSize_Vestir)
        }

        // ─── 标题 ───
        let titleLabel_Vestir = UILabel()
        titleLabel_Vestir.text = challenge_vestir.title_Vestir
        titleLabel_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        titleLabel_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        titleLabel_Vestir.numberOfLines = 1

        // ─── 热门徽章（用主题色背景）───
        let hotBadge_Vestir = UILabel()
        hotBadge_Vestir.text = " 🔥 Hot "
        hotBadge_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        hotBadge_Vestir.textColor = .white
        hotBadge_Vestir.backgroundColor = primaryColor_Vestir
        hotBadge_Vestir.layer.cornerRadius = 9
        hotBadge_Vestir.clipsToBounds = true
        hotBadge_Vestir.isHidden = !challenge_vestir.isHot_Vestir

        // ─── 箭头（主题色半透明）───
        let arrowView_Vestir = UIImageView()
        arrowView_Vestir.image = UIImage(systemName: "chevron.right")
        arrowView_Vestir.tintColor = primaryColor_Vestir.withAlphaComponent(0.55)
        arrowView_Vestir.contentMode = .scaleAspectFit

        // ─── 细分隔线 ───
        let separator_Vestir = UIView()
        separator_Vestir.backgroundColor = ColorConfig_Vestir.divider_Vestir

        // ─── 描述文字 ───
        let descLabel_Vestir = UILabel()
        descLabel_Vestir.text = challenge_vestir.desc_Vestir
        descLabel_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLabel_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        descLabel_Vestir.numberOfLines = 2

        // ─── 统计胶囊（参与人数 + 剩余天数）───
        let count_Vestir = challenge_vestir.participantCount_Vestir
        let countText_Vestir = count_Vestir >= 1000
            ? String(format: "  👥  %.1fK joined  ", Double(count_Vestir) / 1000.0)
            : "  👥  \(count_Vestir) joined  "

        let participantPill_Vestir = UILabel()
        participantPill_Vestir.text = countText_Vestir
        participantPill_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        participantPill_Vestir.textColor = primaryColor_Vestir
        participantPill_Vestir.backgroundColor = primaryColor_Vestir.withAlphaComponent(0.10)
        participantPill_Vestir.layer.cornerRadius = 10
        participantPill_Vestir.clipsToBounds = true

        let dayPill_Vestir = UILabel()
        dayPill_Vestir.text = "  ⏳  \(challenge_vestir.daysRemaining_Vestir)d left  "
        dayPill_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        dayPill_Vestir.textColor = UIColor(hexstring_Vestir: "#B45309")
        dayPill_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FFF7ED")
        dayPill_Vestir.layer.cornerRadius = 10
        dayPill_Vestir.clipsToBounds = true

        let statsStack_Vestir = UIStackView(arrangedSubviews: [participantPill_Vestir, dayPill_Vestir])
        statsStack_Vestir.axis = .horizontal
        statsStack_Vestir.spacing = 8
        statsStack_Vestir.alignment = .center

        // 添加子视图
        innerCard_Vestir.addSubview(titleLabel_Vestir)
        innerCard_Vestir.addSubview(hotBadge_Vestir)
        innerCard_Vestir.addSubview(arrowView_Vestir)
        innerCard_Vestir.addSubview(separator_Vestir)
        innerCard_Vestir.addSubview(descLabel_Vestir)
        innerCard_Vestir.addSubview(statsStack_Vestir)

        // 约束
        arrowView_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(iconCircle_Vestir)
            make.width.height.equalTo(14)
        }
        titleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(iconCircle_Vestir.snp.trailing).offset(12)
            make.top.equalTo(iconCircle_Vestir).offset(4)
            make.trailing.lessThanOrEqualTo(arrowView_Vestir.snp.leading).offset(-8)
        }
        hotBadge_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(iconCircle_Vestir.snp.trailing).offset(12)
            make.top.equalTo(titleLabel_Vestir.snp.bottom).offset(6)
            make.height.equalTo(20)
        }
        separator_Vestir.snp.makeConstraints { make in
            make.top.equalTo(iconCircle_Vestir.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        descLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(separator_Vestir.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        statsStack_Vestir.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Vestir.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        [participantPill_Vestir, dayPill_Vestir].forEach {
            $0.snp.makeConstraints { make in make.height.equalTo(24) }
        }

        // 点击进入挑战详情
        let tap_Vestir = UITapGestureRecognizer(target: self, action: #selector(challengeTapped_Vestir(_:)))
        card_Vestir.addGestureRecognizer(tap_Vestir)
        card_Vestir.tag = challenge_vestir.challengeId_Vestir

        return card_Vestir
    }

    // MARK: - 通知绑定

    private func bindNotifications_Vestir() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChanged_Vestir),
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onCheckInChanged_Vestir),
            name: CheckInViewModel_Vestir.checkInStateDidChangeNotification_Vestir, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onPostsChanged_Vestir),
            name: TitleViewModel_Vestir.titleStateDidChangeNotification_Vestir, object: nil
        )
    }

    @objc private func onDataChanged_Vestir() { loadUserInfo_Vestir() }

    @objc private func onCheckInChanged_Vestir() {
        loadCheckIn_Vestir()
        loadCalendar_Vestir()
    }

    @objc private func onPostsChanged_Vestir() { loadBanner_Vestir() }

    // 页面消失时暂停轮播，出现时恢复
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bannerTimer_Vestir?.invalidate()
        bannerTimer_Vestir = nil
    }

    // MARK: - 事件处理

    /// 点击打卡卡片 → 打开打卡表单
    @objc private func bannerCellTapped_Vestir(_ gesture: UITapGestureRecognizer) {
        guard let view_Vestir = gesture.view,
              let post_Vestir = TitleViewModel_Vestir.shared_Vestir.getPosts_Vestir()
                .first(where: { $0.titleId_Vestir == view_Vestir.tag })
        else { return }
        Navigation_Vestir.toTitleDetail_Vestir(titleModel_vestir: post_Vestir)
    }

    @objc private func checkInCardTapped_Vestir() {
        if CheckInViewModel_Vestir.shared_Vestir.isCheckedInToday_Vestir { return }
        if !UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir {
            Navigation_Vestir.toLogin_Vestir(style_vestir: .present_vestir)
            return
        }
        let sheet_Vestir = CheckInSheet_Vestir()
        sheet_Vestir.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet_Vestir = sheet_Vestir.sheetPresentationController {
                sheet_Vestir.detents = [.large()]
                sheet_Vestir.prefersGrabberVisible = true
            }
        }
        present(sheet_Vestir, animated: true)
    }

    /// 点击挑战卡片 → 进入挑战详情
    @objc private func challengeTapped_Vestir(_ gesture: UITapGestureRecognizer) {
        guard let view_Vestir = gesture.view,
              let challenge_Vestir = LocalData_Vestir.shared_Vestir.challengeList_Vestir.first(
                  where: { $0.challengeId_Vestir == view_Vestir.tag }
              ) else { return }

        view_Vestir.animatePressDown_Vestir {
            view_Vestir.animatePressUp_Vestir {
                let detailVC_Vestir = ChallengeDetail_Vestir()
                detailVC_Vestir.challenge_Vestir = challenge_Vestir
                Navigation_Vestir.push_Vestir(to: detailVC_Vestir)
            }
        }
    }
}

// MARK: - 轮播 UIScrollViewDelegate（同步页码指示器）

extension Home_Vestir: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === bannerScrollView_Vestir else { return }
        let bannerWidth_Vestir = UIScreen.main.bounds.width - 32
        guard bannerWidth_Vestir > 0 else { return }
        let page_Vestir = Int((scrollView.contentOffset.x + bannerWidth_Vestir / 2) / bannerWidth_Vestir)
        bannerCurrentIndex_Vestir = max(0, min(page_Vestir, bannerPosts_Vestir.count - 1))
        bannerPageControl_Vestir.currentPage = bannerCurrentIndex_Vestir
    }
}

// MARK: - UIView 触感反馈扩展

extension UIView {
    func animatePulseFeedback_Vestir() {
        let generator_Vestir = UIImpactFeedbackGenerator(style: .medium)
        generator_Vestir.impactOccurred()
        animatePulse_Vestir()
    }
}

// MARK: - 打卡表单（底部弹出 Sheet）

/// 打卡表单页
/// 功能：选择穿搭图片、标注场景/品牌/温度，完成今日打卡
class CheckInSheet_Vestir: UIViewController {

    private var selectedImage_Vestir: UIImage?
    private var selectedOccasion_Vestir: String?

    // 媒体预览
    private let mediaBg_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        v_Vestir.layer.cornerRadius = 16
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()
    private let mediaPreview_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        iv_Vestir.contentMode = .scaleAspectFill
        iv_Vestir.clipsToBounds = true
        return iv_Vestir
    }()
    private let mediaPlaceholderIcon_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        iv_Vestir.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_Vestir)
        iv_Vestir.tintColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        iv_Vestir.contentMode = .scaleAspectFit
        return iv_Vestir
    }()
    private let mediaPlaceholderLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Tap to add today's outfit"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    // 场景选择
    private static let occasions_Vestir = ["Commuting", "Casual", "Date", "Sports"]
    private var occasionBtns_Vestir: [UIButton] = []

    // 品牌输入
    private let brandField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Brand (optional)"
        tf_Vestir.font = UIFont.systemFont(ofSize: 14)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 12
        tf_Vestir.setLeftPadding_Vestir(icon: "tag.fill",
                                        tintColor: ColorConfig_Vestir.primaryGradientStart_Vestir)
        return tf_Vestir
    }()

    // 温度输入
    private let tempField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Temperature (e.g. 25°C)"
        tf_Vestir.font = UIFont.systemFont(ofSize: 14)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 12
        tf_Vestir.setLeftPadding_Vestir(icon: "thermometer.medium",
                                        tintColor: ColorConfig_Vestir.primaryGradientEnd_Vestir)
        return tf_Vestir
    }()

    // 确认按钮
    private let confirmBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.setTitle("Complete Check-in ✓", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.layer.cornerRadius = 26
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private let confirmGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#E11D48").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        g_Vestir.cornerRadius = 26
        return g_Vestir
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        setupSheet_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmGradLayer_Vestir.frame = confirmBtn_Vestir.bounds
    }

    private func setupSheet_Vestir() {
        // 标题
        let titleLbl_Vestir = UILabel()
        titleLbl_Vestir.text = "Today's OOTD Check-in"
        titleLbl_Vestir.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        titleLbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir

        // 场景标签容器
        let occasionRow_Vestir = UIStackView()
        occasionRow_Vestir.axis = .horizontal
        occasionRow_Vestir.spacing = 8
        occasionRow_Vestir.distribution = .fillProportionally

        for occasion_Vestir in CheckInSheet_Vestir.occasions_Vestir {
            let btn_Vestir = UIButton(type: .system)
            btn_Vestir.setTitle(occasion_Vestir, for: .normal)
            btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            btn_Vestir.setTitleColor(ColorConfig_Vestir.tagPillText_Vestir, for: .normal)
            btn_Vestir.backgroundColor = ColorConfig_Vestir.tagPill_Vestir
            btn_Vestir.layer.cornerRadius = 14
            btn_Vestir.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            btn_Vestir.addTarget(self, action: #selector(occasionTapped_Vestir(_:)), for: .touchUpInside)
            occasionRow_Vestir.addArrangedSubview(btn_Vestir)
            occasionBtns_Vestir.append(btn_Vestir)
        }

        view.addSubview(titleLbl_Vestir)
        view.addSubview(mediaBg_Vestir)
        mediaBg_Vestir.addSubview(mediaPreview_Vestir)
        mediaBg_Vestir.addSubview(mediaPlaceholderIcon_Vestir)
        mediaBg_Vestir.addSubview(mediaPlaceholderLabel_Vestir)
        view.addSubview(occasionRow_Vestir)
        view.addSubview(brandField_Vestir)
        view.addSubview(tempField_Vestir)
        view.addSubview(confirmBtn_Vestir)
        confirmBtn_Vestir.layer.insertSublayer(confirmGradLayer_Vestir, at: 0)

        titleLbl_Vestir.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        mediaBg_Vestir.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Vestir.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(160)
        }
        mediaPreview_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaPlaceholderIcon_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(40)
        }
        mediaPlaceholderLabel_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mediaPlaceholderIcon_Vestir.snp.bottom).offset(8)
        }
        occasionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaBg_Vestir.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        brandField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(occasionRow_Vestir.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        tempField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(brandField_Vestir.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        confirmBtn_Vestir.snp.makeConstraints { make in
            make.top.equalTo(tempField_Vestir.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        let mediaTap_Vestir = UITapGestureRecognizer(target: self, action: #selector(pickMedia_Vestir))
        mediaBg_Vestir.addGestureRecognizer(mediaTap_Vestir)
        mediaBg_Vestir.isUserInteractionEnabled = true

        confirmBtn_Vestir.addTarget(self, action: #selector(confirmTapped_Vestir), for: .touchUpInside)
    }

    @objc private func pickMedia_Vestir() {
        MediaPickerHelper_Vestir.pickImage_Vestir(from: self) { [weak self] img_Vestir in
            guard let self = self, let img_Vestir = img_Vestir else { return }
            self.selectedImage_Vestir = img_Vestir
            self.mediaPreview_Vestir.image = img_Vestir
            self.mediaPlaceholderIcon_Vestir.isHidden = true
            self.mediaPlaceholderLabel_Vestir.isHidden = true
        }
    }

    @objc private func occasionTapped_Vestir(_ sender: UIButton) {
        let title_Vestir = sender.title(for: .normal) ?? ""
        selectedOccasion_Vestir = selectedOccasion_Vestir == title_Vestir ? nil : title_Vestir

        for btn_Vestir in occasionBtns_Vestir {
            let isSelected_Vestir = (btn_Vestir.title(for: .normal) == selectedOccasion_Vestir)
            UIView.animate(withDuration: 0.18) {
                btn_Vestir.backgroundColor = isSelected_Vestir
                    ? ColorConfig_Vestir.primaryGradientStart_Vestir
                    : ColorConfig_Vestir.tagPill_Vestir
                btn_Vestir.setTitleColor(
                    isSelected_Vestir ? .white : ColorConfig_Vestir.tagPillText_Vestir,
                    for: .normal
                )
            }
        }
    }

    @objc private func confirmTapped_Vestir() {
        guard let img_Vestir = selectedImage_Vestir else {
            mediaBg_Vestir.animateShake_Vestir()
            Utils_Vestir.showWarning_Vestir(message_Vestir: "Please add a photo")
            return
        }

        // 保存图片
        var mediaPath_Vestir = ""
        if let data_Vestir = img_Vestir.jpegData(compressionQuality: 0.8) {
            let fileName_Vestir = "checkin_\(Date().timeIntervalSince1970).jpg"
            let url_Vestir = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            )[0].appendingPathComponent(fileName_Vestir)
            try? data_Vestir.write(to: url_Vestir)
            mediaPath_Vestir = fileName_Vestir
        }

        Task { @MainActor in
            CheckInViewModel_Vestir.shared_Vestir.performCheckIn_Vestir(
                mediaPath_vestir: mediaPath_Vestir,
                brand_vestir: self.brandField_Vestir.text,
                colorTheme_vestir: nil,
                outfitStyle_vestir: nil,
                occasion_vestir: self.selectedOccasion_Vestir,
                temperature_vestir: self.tempField_Vestir.text
            )
        }

        Utils_Vestir.showSuccess_Vestir(message_Vestir: "Checked in! 🎉")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - Home 头部渐变（深紫→靛蓝→湛蓝）

fileprivate final class HomeHeaderCard_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g.locations = [0, 0.52, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 26
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}

// MARK: - 打卡详情底部弹窗

/// 打卡记录详情底部 Sheet
/// 功能：展示打卡全图 + 日期 + 标签胶囊
/// 设计：
///   • 顶部渐变标题卡（日期 Heavy + "OOTD Check-in" 副标题）
///   • 全宽照片区（圆角 20pt，aspect fill）
///   • 标签区：横向可滚动胶囊行（按内容自然宽度显示，不拉伸）
class CheckInDetailSheet_Vestir: UIViewController {

    var checkIn_Vestir: DailyCheckIn_Vestir?

    // MARK: - 子视图

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        buildDetail_Vestir()
    }

    // MARK: - 构建布局

    private func buildDetail_Vestir() {
        guard let ci_Vestir = checkIn_Vestir else { return }

        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)
        scrollView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // ─── 1. 渐变标题卡 ───
        let headerCard_Vestir = CheckInDetailHeaderCard_Vestir()
        let dateLabel_Vestir = UILabel()
        let f1_Vestir = DateFormatter()
        f1_Vestir.dateFormat = "yyyy-MM-dd"
        let f2_Vestir = DateFormatter()
        f2_Vestir.dateStyle = .full
        dateLabel_Vestir.text = f1_Vestir.date(from: ci_Vestir.date_Vestir)
            .map { f2_Vestir.string(from: $0) } ?? ci_Vestir.date_Vestir
        dateLabel_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        dateLabel_Vestir.textColor = .white

        let subLabel_Vestir = UILabel()
        subLabel_Vestir.text = "OOTD Check-in  ✦"
        subLabel_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subLabel_Vestir.textColor = UIColor(white: 1.0, alpha: 0.70)

        contentView_Vestir.addSubview(headerCard_Vestir)
        headerCard_Vestir.addSubview(subLabel_Vestir)
        headerCard_Vestir.addSubview(dateLabel_Vestir)

        headerCard_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        subLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(18)
        }
        dateLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(subLabel_Vestir.snp.bottom).offset(4)
        }

        // ─── 2. 照片区 ───
        let photoCard_Vestir = UIView()
        photoCard_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        photoCard_Vestir.layer.cornerRadius = 20
        photoCard_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#E11D48").cgColor
        photoCard_Vestir.layer.shadowOpacity = 0.14
        photoCard_Vestir.layer.shadowOffset = CGSize(width: 0, height: 6)
        photoCard_Vestir.layer.shadowRadius = 16

        let photoView_Vestir = MediaDisplayView_Vestir()
        photoView_Vestir.layer.cornerRadius = 20
        photoView_Vestir.clipsToBounds = true
        photoView_Vestir.customPlaceholderColors_Vestir = [
            UIColor(hexstring_Vestir: "#FECDD3").cgColor,
            UIColor(hexstring_Vestir: "#FDE68A").cgColor
        ]
        photoView_Vestir.configure_Vestir(mediaPath_Vestir: ci_Vestir.mediaPath_Vestir)

        contentView_Vestir.addSubview(photoCard_Vestir)
        photoCard_Vestir.addSubview(photoView_Vestir)

        photoCard_Vestir.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Vestir.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(270)
        }
        photoView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // ─── 3. 标签区 ───
        let tagPairs_Vestir: [(String, String, UIColor, UIColor)] = [
            ("📍  Occasion", ci_Vestir.occasion_Vestir ?? "",
             UIColor(hexstring_Vestir: "#F3EEFF"), UIColor(hexstring_Vestir: "#7C3AED")),
            ("🏷  Brand", ci_Vestir.brand_Vestir ?? "",
             UIColor(hexstring_Vestir: "#FFF1F2"), UIColor(hexstring_Vestir: "#BE185D")),
            ("🎨  Color", ci_Vestir.colorTheme_Vestir ?? "",
             UIColor(hexstring_Vestir: "#EFF6FF"), UIColor(hexstring_Vestir: "#1D4ED8")),
            ("✦  Style", ci_Vestir.outfitStyle_Vestir ?? "",
             UIColor(hexstring_Vestir: "#FFFBEB"), UIColor(hexstring_Vestir: "#B45309")),
            ("🌡  Temp", ci_Vestir.temperature_Vestir ?? "",
             UIColor(hexstring_Vestir: "#F0FDF4"), UIColor(hexstring_Vestir: "#15803D"))
        ].filter { !$0.1.isEmpty }

        var lastAnchor_Vestir = photoCard_Vestir.snp.bottom

        if !tagPairs_Vestir.isEmpty {
            // 分区标题行
            let tagSectionRow_Vestir = UIView()
            let tagDot_Vestir = UIView()
            tagDot_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#E11D48")
            tagDot_Vestir.layer.cornerRadius = 4
            let tagSectionTitle_Vestir = UILabel()
            tagSectionTitle_Vestir.text = "Style Tags"
            tagSectionTitle_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            tagSectionTitle_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir

            contentView_Vestir.addSubview(tagSectionRow_Vestir)
            tagSectionRow_Vestir.addSubview(tagDot_Vestir)
            tagSectionRow_Vestir.addSubview(tagSectionTitle_Vestir)

            tagSectionRow_Vestir.snp.makeConstraints { make in
                make.top.equalTo(photoCard_Vestir.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(18)
                make.trailing.equalToSuperview().offset(-18)
                make.height.equalTo(20)
            }
            tagDot_Vestir.snp.makeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.width.height.equalTo(8)
            }
            tagSectionTitle_Vestir.snp.makeConstraints { make in
                make.leading.equalTo(tagDot_Vestir.snp.trailing).offset(7)
                make.centerY.equalToSuperview()
            }

            // 标签横向滚动（每个 pill 按内容自然宽度，不拉伸）
            let tagsScroll_Vestir = UIScrollView()
            tagsScroll_Vestir.showsHorizontalScrollIndicator = false
            tagsScroll_Vestir.showsVerticalScrollIndicator = false

            let tagsContainer_Vestir = UIView()
            contentView_Vestir.addSubview(tagsScroll_Vestir)
            tagsScroll_Vestir.addSubview(tagsContainer_Vestir)

            tagsScroll_Vestir.snp.makeConstraints { make in
                make.top.equalTo(tagSectionRow_Vestir.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(38)
            }
            tagsContainer_Vestir.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalToSuperview()
            }

            // 逐个创建 pill，水平排列
            var pillLeading_Vestir = tagsContainer_Vestir.snp.leading
            var firstPillOffset_Vestir = 20  // 首个 pill 左边距
            for (idx_Vestir, (labelText_Vestir, valueText_Vestir, bg_Vestir, fg_Vestir)) in tagPairs_Vestir.enumerated() {
                let pill_Vestir = buildTagPill_Vestir(
                    label_vestir: labelText_Vestir,
                    value_vestir: valueText_Vestir,
                    bg_vestir: bg_Vestir,
                    fg_vestir: fg_Vestir
                )
                tagsContainer_Vestir.addSubview(pill_Vestir)
                pill_Vestir.snp.makeConstraints { make in
                    if idx_Vestir == 0 {
                        make.leading.equalTo(pillLeading_Vestir).offset(firstPillOffset_Vestir)
                    } else {
                        make.leading.equalTo(pillLeading_Vestir).offset(8)
                    }
                    make.centerY.equalToSuperview()
                    make.height.equalTo(32)
                    if idx_Vestir == tagPairs_Vestir.count - 1 {
                        make.trailing.equalToSuperview().offset(-20)
                    }
                }
                pillLeading_Vestir = pill_Vestir.snp.trailing
                firstPillOffset_Vestir = 0
            }

            lastAnchor_Vestir = tagsScroll_Vestir.snp.bottom
        }

        contentView_Vestir.snp.makeConstraints { make in
            make.bottom.equalTo(lastAnchor_Vestir).offset(40)
        }
    }

    /// 构建标签胶囊：上方小标签文字 + 下方值（两行合一个 pill）
    private func buildTagPill_Vestir(
        label_vestir: String,
        value_vestir: String,
        bg_vestir: UIColor,
        fg_vestir: UIColor
    ) -> UIView {
        let pill_Vestir = UIView()
        pill_Vestir.backgroundColor = bg_vestir
        pill_Vestir.layer.cornerRadius = 14
        pill_Vestir.clipsToBounds = true

        let stack_Vestir = UIStackView()
        stack_Vestir.axis = .vertical
        stack_Vestir.spacing = 1
        stack_Vestir.alignment = .center

        let labelLbl_Vestir = UILabel()
        labelLbl_Vestir.text = label_vestir
        labelLbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        labelLbl_Vestir.textColor = fg_vestir.withAlphaComponent(0.65)

        let valueLbl_Vestir = UILabel()
        valueLbl_Vestir.text = value_vestir
        valueLbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        valueLbl_Vestir.textColor = fg_vestir

        stack_Vestir.addArrangedSubview(labelLbl_Vestir)
        stack_Vestir.addArrangedSubview(valueLbl_Vestir)
        pill_Vestir.addSubview(stack_Vestir)

        stack_Vestir.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(14)
        }

        return pill_Vestir
    }
}

// MARK: - 打卡详情头部渐变（玫瑰→紫罗兰）

fileprivate final class CheckInDetailHeaderCard_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#E11D48").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g.locations = [0, 0.52, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 0
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}

private extension UIStackView {
    var flexibleWrap_Vestir: Bool {
        get { false }
        set { if newValue { alignment = .leading } }
    }
}

// MARK: - 打卡卡片渐变（玫瑰→紫罗兰→靛蓝）

fileprivate final class CheckInCardGradient_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#E11D48").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g.locations = [0, 0.52, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}

// MARK: - 今日日历格子渐变（紫→靛蓝）

/// 日历格子中「今日」专用渐变背景
fileprivate final class CalendarTodayCell_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#7C3AED").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}
