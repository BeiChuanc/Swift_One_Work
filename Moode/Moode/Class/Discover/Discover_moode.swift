import Foundation
import UIKit
import SnapKit
import FSPagerView

// MARK: - 发现页

/// 发现页视图控制器
/// 功能：探索全站情绪便签，支持关键词搜索、情绪挑战展示、情绪标签筛选、热门轮播、Popular 排行列表
/// 设计：渐变 Header → 搜索 → Trending 轮播 → 情绪挑战横滑区 → 情绪筛选 → Popular 列表
/// 数据来源：TitleViewModel_Moode + LocalData_Moode.challengeList_Moode
class Discover_Moode: UIViewController {

    // MARK: - 常量

    private let headerHeight_Moode: CGFloat = 124

    // MARK: - 主滚动容器

    private let scrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsVerticalScrollIndicator = false
        sv_Moode.backgroundColor = UIColor(hexstring_Moode: "#F5F6FA")
        sv_Moode.contentInsetAdjustmentBehavior = .never
        return sv_Moode
    }()

    private let contentView_Moode = UIView()

    // MARK: - 渐变 Header

    private let headerView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.clipsToBounds = true
        return v_Moode
    }()

    private var headerGradient_Moode: CAGradientLayer?
    private let headerWaveLayer_Moode = CAShapeLayer()

    private let headerBubble1_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v_Moode.layer.cornerRadius = 65
        return v_Moode
    }()

    private let headerBubble2_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v_Moode.layer.cornerRadius = 45
        return v_Moode
    }()

    private let headerBubble3_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_Moode.layer.cornerRadius = 28
        return v_Moode
    }()

    private let headerEmoji1_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "🔭"
        l_Moode.font = .systemFont(ofSize: 24)
        l_Moode.alpha = 0.75
        return l_Moode
    }()

    private let headerEmoji2_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "🌍"
        l_Moode.font = .systemFont(ofSize: 18)
        l_Moode.alpha = 0.6
        return l_Moode
    }()

    private let pageTitleLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.text = "Discover"
        label_Moode.font = .systemFont(ofSize: 30, weight: .heavy)
        label_Moode.textColor = .white
        return label_Moode
    }()

    private let pageSubtitleLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.text = "Explore moods around the world"
        label_Moode.font = .systemFont(ofSize: 13, weight: .medium)
        label_Moode.textColor = UIColor.white.withAlphaComponent(0.80)
        return label_Moode
    }()

    private let headerStatsBadge_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v_Moode.layer.cornerRadius = 14
        v_Moode.layer.borderWidth = 1
        v_Moode.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v_Moode
    }()

    private let headerStatsIcon_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        iv_Moode.image = UIImage(systemName: "flame.fill")
        iv_Moode.tintColor = .white
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let headerStatsLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11, weight: .semibold)
        l_Moode.textColor = .white
        return l_Moode
    }()

    private var headerHeightConstraint_Moode: Constraint?
    private var badgeTopConstraint_Moode: Constraint?

    // MARK: - 搜索栏

    private let searchContainer_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 22
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#9BB5F0").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Moode.layer.shadowRadius = 12
        v_Moode.layer.shadowOpacity = 0.15
        return v_Moode
    }()

    private let searchIconView_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        iv_Moode.image = UIImage(systemName: "magnifyingglass")
        iv_Moode.tintColor = ColorConfig_Moode.primaryGradientStart_Moode
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let searchField_Moode: UITextField = {
        let tf_Moode = UITextField()
        tf_Moode.placeholder = "Search moods, words, or users..."
        tf_Moode.font = .systemFont(ofSize: 14)
        tf_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        tf_Moode.backgroundColor = .clear
        tf_Moode.returnKeyType = .search
        return tf_Moode
    }()

    private let clearSearchBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        btn_Moode.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn_Moode.tintColor = ColorConfig_Moode.textPlaceholder_Moode
        btn_Moode.isHidden = true
        return btn_Moode
    }()

    // MARK: - Trending 轮播

    private let trendingSectionHeader_Moode = UIView()
    private let trendingAccentBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.layer.cornerRadius = 2
        v_Moode.clipsToBounds = true
        return v_Moode
    }()
    private var trendingAccentGradient_Moode: CAGradientLayer?

    private let trendingTitleLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.text = "Trending"
        label_Moode.font = .systemFont(ofSize: 19, weight: .bold)
        label_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        return label_Moode
    }()

    private let trendingSubtitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Most loved this week ✨"
        l_Moode.font = .systemFont(ofSize: 12)
        l_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return l_Moode
    }()

    private lazy var pagerView_Moode: FSPagerView = {
        let pager_Moode = FSPagerView()
        pager_Moode.register(
            DiscoverTrendingCell_Moode.self,
            forCellWithReuseIdentifier: DiscoverTrendingCell_Moode.reuseId_Moode
        )
        pager_Moode.automaticSlidingInterval = 3.5
        pager_Moode.isInfinite = true
        pager_Moode.interitemSpacing = 14
        pager_Moode.itemSize = CGSize(width: APPSCREEN_Moode.WIDTH_Moode - 56, height: 180)
        pager_Moode.transformer = FSPagerViewTransformer(type: .overlap)
        return pager_Moode
    }()

    private let pageControl_Moode: FSPageControl = {
        let pc_Moode = FSPageControl()
        pc_Moode.numberOfPages = 3
        pc_Moode.currentPage = 0
        pc_Moode.contentHorizontalAlignment = .center
        pc_Moode.setFillColor(ColorConfig_Moode.primaryGradientStart_Moode, for: .selected)
        pc_Moode.setFillColor(UIColor(hexstring_Moode: "#D8D0FF"), for: .normal)
        return pc_Moode
    }()

    // MARK: - 情绪挑战区

    private let challengeSectionHeader_Moode = UIView()
    private let challengeAccentBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.layer.cornerRadius = 2
        v_Moode.clipsToBounds = true
        return v_Moode
    }()
    private var challengeAccentGradient_Moode: CAGradientLayer?

    private let challengeTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Mood Challenges"
        l_Moode.font = .systemFont(ofSize: 19, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        return l_Moode
    }()

    private let challengeSubtitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Official & community-initiated themes"
        l_Moode.font = .systemFont(ofSize: 12)
        l_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return l_Moode
    }()

    /// 情绪挑战横向滚动容器
    private let challengeScrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsHorizontalScrollIndicator = false
        sv_Moode.backgroundColor = .clear
        return sv_Moode
    }()

    private let challengeStackView_Moode: UIStackView = {
        let sv_Moode = UIStackView()
        sv_Moode.axis = .horizontal
        sv_Moode.spacing = 12
        sv_Moode.alignment = .fill
        return sv_Moode
    }()

    // MARK: - 情绪筛选区（移至挑战区下方）

    // MARK: - Popular 列表

    private let popularSectionHeader_Moode = UIView()
    private let popularAccentBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.layer.cornerRadius = 2
        v_Moode.clipsToBounds = true
        return v_Moode
    }()
    private var popularAccentGradient_Moode: CAGradientLayer?

    private let popularTitleLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.text = "Posts"
        label_Moode.font = .systemFont(ofSize: 19, weight: .bold)
        label_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        return label_Moode
    }()

    private let popularCountBadge_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#EEE9FF")
        v_Moode.layer.cornerRadius = 11
        return v_Moode
    }()

    private let popularCountLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.primaryGradientStart_Moode
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private lazy var popularCollectionView_Moode: UICollectionView = {
        let layout_Moode = WaterfallLayout_Moode()
        let cv_Moode = UICollectionView(frame: .zero, collectionViewLayout: layout_Moode)
        cv_Moode.backgroundColor = .clear
        cv_Moode.isScrollEnabled = false
        cv_Moode.register(
            NormalPostCard_Moode.self,
            forCellWithReuseIdentifier: NormalPostCard_Moode.reuseId_Moode
        )
        return cv_Moode
    }()

    // MARK: - 空状态视图

    private let emptyStateView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.isHidden = true
        return v_Moode
    }()

    private let emptyIconLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "🔍"
        l_Moode.font = .systemFont(ofSize: 52)
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private let emptyTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "No moods found"
        l_Moode.font = .systemFont(ofSize: 17, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.textSecondary_Moode
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private let emptySubtitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Try a different keyword or mood filter"
        l_Moode.font = .systemFont(ofSize: 13)
        l_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        l_Moode.textAlignment = .center
        l_Moode.numberOfLines = 2
        return l_Moode
    }()

    // MARK: - 数据

    private var trendingPosts_Moode: [TitleModel_Moode] = []
    private var popularPosts_Moode: [TitleModel_Moode] = []
    private var searchKeyword_Moode: String = ""
    private var popularHeightConstraint_Moode: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Moode()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Moode: "#F5F6FA")
        setupScrollLayout_Moode()
        setupHeader_Moode()
        setupSearchBar_Moode()
        setupTrendingSection_Moode()
        setupChallengeSection_Moode()
        setupPopularSection_Moode()
        setupEmptyState_Moode()
        observeNotifications_Moode()
        reloadData_Moode()
        startHeaderAnimations_Moode()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset_Moode = view.safeAreaInsets.top
        if topInset_Moode > 0 {
            headerHeightConstraint_Moode?.update(offset: headerHeight_Moode + topInset_Moode)
            badgeTopConstraint_Moode?.update(offset: topInset_Moode + 16)
        }
        updateGradientLayers_Moode()
        updateHeaderWave_Moode()
    }

    // MARK: - 布局搭建

    private func setupScrollLayout_Moode() {
        view.addSubview(scrollView_Moode)
        scrollView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView_Moode.addSubview(contentView_Moode)
        contentView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Moode.contentLayoutGuide)
            make.width.equalTo(scrollView_Moode.frameLayoutGuide)
        }
    }

    private func setupHeader_Moode() {
        contentView_Moode.addSubview(headerView_Moode)
        headerView_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            headerHeightConstraint_Moode = make.height.equalTo(headerHeight_Moode).constraint
        }

        headerView_Moode.addSubview(headerBubble1_Moode)
        headerBubble1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-8)
            make.width.height.equalTo(130)
        }

        headerView_Moode.addSubview(headerBubble2_Moode)
        headerBubble2_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(10)
            make.width.height.equalTo(90)
        }

        headerView_Moode.addSubview(headerBubble3_Moode)
        headerBubble3_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-28)
            make.bottom.equalToSuperview().offset(-46)
            make.width.height.equalTo(56)
        }

        headerView_Moode.addSubview(headerEmoji1_Moode)
        headerEmoji1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-52)
            make.top.equalToSuperview().offset(64)
        }

        headerView_Moode.addSubview(headerEmoji2_Moode)
        headerEmoji2_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-58)
        }

        headerView_Moode.addSubview(headerStatsBadge_Moode)
        headerStatsBadge_Moode.addSubview(headerStatsIcon_Moode)
        headerStatsBadge_Moode.addSubview(headerStatsLabel_Moode)
        headerStatsBadge_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            badgeTopConstraint_Moode = make.top.equalToSuperview().offset(54).constraint
            make.height.equalTo(30)
        }
        headerStatsIcon_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        headerStatsLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(headerStatsIcon_Moode.snp.right).offset(4)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        headerView_Moode.addSubview(pageTitleLabel_Moode)
        pageTitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(headerStatsBadge_Moode.snp.bottom).offset(10)
        }

        headerView_Moode.addSubview(pageSubtitleLabel_Moode)
        pageSubtitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(pageTitleLabel_Moode.snp.bottom).offset(5)
        }
    }

    private func setupSearchBar_Moode() {
        contentView_Moode.addSubview(searchContainer_Moode)
        searchContainer_Moode.snp.makeConstraints { make in
            make.top.equalTo(headerView_Moode.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }

        searchContainer_Moode.addSubview(searchIconView_Moode)
        searchIconView_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        searchContainer_Moode.addSubview(clearSearchBtn_Moode)
        clearSearchBtn_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        searchContainer_Moode.addSubview(searchField_Moode)
        searchField_Moode.snp.makeConstraints { make in
            make.left.equalTo(searchIconView_Moode.snp.right).offset(10)
            make.right.equalTo(clearSearchBtn_Moode.snp.left).offset(-6)
            make.centerY.equalToSuperview()
        }

        searchField_Moode.delegate = self
        searchField_Moode.addTarget(self, action: #selector(handleSearchTextChanged_Moode), for: .editingChanged)
        clearSearchBtn_Moode.addTarget(self, action: #selector(handleClearSearch_Moode), for: .touchUpInside)
    }

    /// 搭建 Trending 轮播区（紧接搜索栏）
    private func setupTrendingSection_Moode() {
        contentView_Moode.addSubview(trendingSectionHeader_Moode)
        trendingSectionHeader_Moode.snp.makeConstraints { make in
            make.top.equalTo(searchContainer_Moode.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        trendingSectionHeader_Moode.addSubview(trendingAccentBar_Moode)
        trendingAccentBar_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(26)
        }

        trendingSectionHeader_Moode.addSubview(trendingTitleLabel_Moode)
        trendingTitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(trendingAccentBar_Moode.snp.right).offset(10)
            make.top.equalToSuperview()
        }

        trendingSectionHeader_Moode.addSubview(trendingSubtitleLabel_Moode)
        trendingSubtitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(trendingAccentBar_Moode.snp.right).offset(10)
            make.top.equalTo(trendingTitleLabel_Moode.snp.bottom).offset(2)
        }

        contentView_Moode.addSubview(pagerView_Moode)
        pagerView_Moode.snp.makeConstraints { make in
            make.top.equalTo(trendingSectionHeader_Moode.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(195)
        }

        contentView_Moode.addSubview(pageControl_Moode)
        pageControl_Moode.snp.makeConstraints { make in
            make.top.equalTo(pagerView_Moode.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
        }

        pagerView_Moode.dataSource = self
        pagerView_Moode.delegate = self
    }

    /// 搭建情绪挑战区（紧接轮播下方）
    private func setupChallengeSection_Moode() {
        contentView_Moode.addSubview(challengeSectionHeader_Moode)
        challengeSectionHeader_Moode.snp.makeConstraints { make in
            make.top.equalTo(pageControl_Moode.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        challengeSectionHeader_Moode.addSubview(challengeAccentBar_Moode)
        challengeAccentBar_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(26)
        }

        challengeSectionHeader_Moode.addSubview(challengeTitleLabel_Moode)
        challengeTitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(challengeAccentBar_Moode.snp.right).offset(10)
            make.top.equalToSuperview()
        }

        challengeSectionHeader_Moode.addSubview(challengeSubtitleLabel_Moode)
        challengeSubtitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(challengeAccentBar_Moode.snp.right).offset(10)
            make.top.equalTo(challengeTitleLabel_Moode.snp.bottom).offset(2)
        }

        contentView_Moode.addSubview(challengeScrollView_Moode)
        challengeScrollView_Moode.snp.makeConstraints { make in
            make.top.equalTo(challengeSectionHeader_Moode.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(158)
        }

        challengeScrollView_Moode.addSubview(challengeStackView_Moode)
        challengeStackView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }

        buildChallengCards_Moode()
    }

    private func setupPopularSection_Moode() {
        contentView_Moode.addSubview(popularSectionHeader_Moode)
        popularSectionHeader_Moode.snp.makeConstraints { make in
            make.top.equalTo(challengeScrollView_Moode.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(32)
        }

        popularSectionHeader_Moode.addSubview(popularAccentBar_Moode)
        popularAccentBar_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(22)
        }

        popularSectionHeader_Moode.addSubview(popularTitleLabel_Moode)
        popularTitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(popularAccentBar_Moode.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        popularSectionHeader_Moode.addSubview(popularCountBadge_Moode)
        popularCountBadge_Moode.addSubview(popularCountLabel_Moode)
        popularCountBadge_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(32)
        }
        popularCountLabel_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }

        contentView_Moode.addSubview(popularCollectionView_Moode)
        popularCollectionView_Moode.snp.makeConstraints { make in
            make.top.equalTo(popularSectionHeader_Moode.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-130)
            popularHeightConstraint_Moode = make.height.equalTo(600).constraint
        }

        popularCollectionView_Moode.dataSource = self
        popularCollectionView_Moode.delegate = self
        // 绑定瀑布流布局委托
        if let waterfall_Moode = popularCollectionView_Moode.collectionViewLayout as? WaterfallLayout_Moode {
            waterfall_Moode.delegate_Moode = self
        }
    }

    private func setupEmptyState_Moode() {
        contentView_Moode.addSubview(emptyStateView_Moode)
        emptyStateView_Moode.snp.makeConstraints { make in
            make.top.equalTo(challengeScrollView_Moode.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }

        emptyStateView_Moode.addSubview(emptyIconLabel_Moode)
        emptyIconLabel_Moode.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }

        emptyStateView_Moode.addSubview(emptyTitleLabel_Moode)
        emptyTitleLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyIconLabel_Moode.snp.bottom).offset(12)
            make.left.right.centerX.equalToSuperview()
        }

        emptyStateView_Moode.addSubview(emptySubtitleLabel_Moode)
        emptySubtitleLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Moode.snp.bottom).offset(8)
            make.left.right.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 挑战卡片构建

    /// 从本地数据构建情绪挑战卡片
    private func buildChallengCards_Moode() {
        challengeStackView_Moode.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let challenges_Moode = LocalData_Moode.shared_Moode.challengeList_Moode
        for challenge_Moode in challenges_Moode {
            let card_Moode = buildChallengeCard_Moode(challenge_moode: challenge_Moode)
            challengeStackView_Moode.addArrangedSubview(card_Moode)
        }
    }

    /// 创建单张情绪挑战卡片
    /// 参数：
    /// - challenge_moode: 挑战数据模型
    /// 返回值：配置好的卡片 UIView
    private func buildChallengeCard_Moode(challenge_moode: MoodChallenge_Moode) -> UIView {
        let card_Moode = ChallengCardView_Moode()
        card_Moode.configure_Moode(challenge_moode: challenge_moode)
        card_Moode.snp.makeConstraints { make in
            make.width.equalTo(190)
        }

        // 点击进入挑战详情页
        let tap_moode = ChallengeTapGesture_Moode(challenge_moode: challenge_moode)
        tap_moode.addTarget(self, action: #selector(handleChallengeTapped_Moode(_:)))
        card_Moode.addGestureRecognizer(tap_moode)
        card_Moode.isUserInteractionEnabled = true
        return card_Moode
    }

    /// 挑战卡片点击处理，跳转至挑战详情页
    @objc private func handleChallengeTapped_Moode(_ gesture_moode: ChallengeTapGesture_Moode) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Moode.toChallengeDetail_Moode(with: gesture_moode.challenge_Moode)
    }

    // MARK: - 筛选标签构建

    // MARK: - 渐变与波浪

    private func updateGradientLayers_Moode() {
        if headerGradient_Moode == nil {
            let grad_Moode = CAGradientLayer()
            grad_Moode.colors = [
                UIColor(hexstring_Moode: "#9BB5F0").cgColor,
                UIColor(hexstring_Moode: "#B794F6").cgColor,
                UIColor(hexstring_Moode: "#87CEF5").cgColor
            ]
            grad_Moode.locations = [0.0, 0.5, 1.0]
            grad_Moode.startPoint = CGPoint(x: 1, y: 0)
            grad_Moode.endPoint = CGPoint(x: 0, y: 1)
            headerView_Moode.layer.insertSublayer(grad_Moode, at: 0)
            headerGradient_Moode = grad_Moode
        }
        headerGradient_Moode?.frame = headerView_Moode.bounds

        setupAccentBarGradient_Moode(bar: trendingAccentBar_Moode, gradRef: &trendingAccentGradient_Moode)
        setupAccentBarGradient_Moode(bar: challengeAccentBar_Moode, gradRef: &challengeAccentGradient_Moode)
        setupAccentBarGradient_Moode(bar: popularAccentBar_Moode, gradRef: &popularAccentGradient_Moode)
    }

    private func setupAccentBarGradient_Moode(bar: UIView, gradRef: inout CAGradientLayer?) {
        if gradRef == nil {
            let grad_Moode = UIColor.createPrimaryGradientLayer_Moode(frame_Moode: bar.bounds)
            grad_Moode.startPoint = CGPoint(x: 0, y: 0)
            grad_Moode.endPoint = CGPoint(x: 0, y: 1)
            bar.layer.insertSublayer(grad_Moode, at: 0)
            gradRef = grad_Moode
        }
        gradRef?.frame = bar.bounds
    }

    private func updateHeaderWave_Moode() {
        let w_Moode = headerView_Moode.bounds.width
        let h_Moode = headerView_Moode.bounds.height
        guard w_Moode > 0, h_Moode > 0 else { return }
        let path_Moode = UIBezierPath()
        path_Moode.move(to: CGPoint(x: 0, y: 0))
        path_Moode.addLine(to: CGPoint(x: 0, y: h_Moode - 20))
        path_Moode.addCurve(
            to: CGPoint(x: w_Moode, y: h_Moode - 8),
            controlPoint1: CGPoint(x: w_Moode * 0.3, y: h_Moode + 12),
            controlPoint2: CGPoint(x: w_Moode * 0.7, y: h_Moode - 30)
        )
        path_Moode.addLine(to: CGPoint(x: w_Moode, y: 0))
        path_Moode.close()
        headerWaveLayer_Moode.path = path_Moode.cgPath
        headerWaveLayer_Moode.fillColor = UIColor.clear.cgColor
        if headerWaveLayer_Moode.superlayer == nil {
            headerView_Moode.layer.addSublayer(headerWaveLayer_Moode)
        }
    }

    // MARK: - 浮动动画

    private func startHeaderAnimations_Moode() {
        animateFloat_Moode(view_moode: headerEmoji1_Moode, delay_moode: 0, offset_moode: -7)
        animateFloat_Moode(view_moode: headerEmoji2_Moode, delay_moode: 0.7, offset_moode: -5)
    }

    private func animateFloat_Moode(view_moode: UIView, delay_moode: TimeInterval, offset_moode: CGFloat) {
        UIView.animate(withDuration: 2.4, delay: delay_moode,
                       options: [.autoreverse, .repeat, .curveEaseInOut]) {
            view_moode.transform = CGAffineTransform(translationX: 0, y: offset_moode)
        }
    }

    // MARK: - 数据刷新

    private func reloadData_Moode() {
        Task { @MainActor in
            let allPopular_Moode = TitleViewModel_Moode.shared_Moode.getPopularPosts_Moode()
            trendingPosts_Moode = Array(allPopular_Moode.prefix(3))
            pageControl_Moode.numberOfPages = trendingPosts_Moode.count
            pagerView_Moode.reloadData()

            // 发现页帖子列表只展示普通帖子，支持关键词搜索
            popularPosts_Moode = searchKeyword_Moode.isEmpty
                ? TitleViewModel_Moode.shared_Moode.getNormalPosts_Moode()
                : TitleViewModel_Moode.shared_Moode.searchNormalPosts_Moode(keyword_moode: searchKeyword_Moode)

            let moodTotal_Moode = TitleViewModel_Moode.shared_Moode.getMoodPosts_Moode().count
            headerStatsLabel_Moode.text = "\(moodTotal_Moode) moods"
            popularCountLabel_Moode.text = "\(popularPosts_Moode.count)"

            let isEmpty_Moode = popularPosts_Moode.isEmpty
            emptyStateView_Moode.isHidden = !isEmpty_Moode
            popularCollectionView_Moode.isHidden = isEmpty_Moode

            // 搜索时隐藏 Trending + Challenge 区
            let isSearching_Moode = !searchKeyword_Moode.isEmpty
            trendingSectionHeader_Moode.isHidden = isSearching_Moode
            pagerView_Moode.isHidden = isSearching_Moode
            pageControl_Moode.isHidden = isSearching_Moode
            challengeSectionHeader_Moode.isHidden = isSearching_Moode
            challengeScrollView_Moode.isHidden = isSearching_Moode

            popularTitleLabel_Moode.text = isSearching_Moode
                ? "Results for \"\(searchKeyword_Moode)\""
                : "Posts"

            // 预估瀑布流总高度：两列中取较长列（所有卡片均含媒体区域）
            let colW_Moode = (UIScreen.main.bounds.width - 12 - 12 - 8) / 2
            var col0_Moode: CGFloat = 0, col1_Moode: CGFloat = 0
            for post_Moode in popularPosts_Moode {
                let h_Moode = NormalPostCard_Moode.estimatedHeight_Moode(
                    for: post_Moode, columnWidth: colW_Moode, showImage_moode: true
                ) + 8
                if col0_Moode <= col1_Moode { col0_Moode += h_Moode } else { col1_Moode += h_Moode }
            }
            let totalH_Moode = isEmpty_Moode ? 180 : max(col0_Moode, col1_Moode) + 24
            popularHeightConstraint_Moode?.update(offset: totalH_Moode)

            // 失效瀑布流缓存，使其重新计算
            popularCollectionView_Moode.collectionViewLayout.invalidateLayout()
            popularCollectionView_Moode.reloadData()
            animatePopularCardsIn_Moode()
            contentView_Moode.layoutIfNeeded()
        }
    }

    private func animatePopularCardsIn_Moode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            for (i_Moode, cell_Moode) in self.popularCollectionView_Moode.visibleCells.enumerated() {
                cell_Moode.animateSlideInFromBottom_Moode(
                    offset_Moode: 30,
                    delay_Moode: TimeInterval(i_Moode) * AnimationConfig_Moode.delayShort_Moode
                )
            }
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Moode() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handlePostsChanged_Moode),
            name: TitleViewModel_Moode.titleStateDidChangeNotification_Moode, object: nil
        )
    }

    // MARK: - 事件处理

    @objc private func handleSearchTextChanged_Moode() {
        searchKeyword_Moode = searchField_Moode.text ?? ""
        clearSearchBtn_Moode.isHidden = searchKeyword_Moode.isEmpty
        reloadData_Moode()
    }

    @objc private func handleClearSearch_Moode() {
        searchField_Moode.text = ""
        searchKeyword_Moode = ""
        clearSearchBtn_Moode.isHidden = true
        searchField_Moode.resignFirstResponder()
        clearSearchBtn_Moode.animatePressDown_Moode { self.clearSearchBtn_Moode.animatePressUp_Moode() }
        reloadData_Moode()
    }

    @objc private func handlePostsChanged_Moode() {
        reloadData_Moode()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Array 安全下标

private extension Array {
    subscript(safe_Moode index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UITextFieldDelegate

extension Discover_Moode: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.searchContainer_Moode.layer.shadowOpacity = 0.28
            self.searchContainer_Moode.layer.shadowRadius = 16
            self.searchContainer_Moode.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.searchContainer_Moode.layer.shadowOpacity = 0.15
            self.searchContainer_Moode.layer.shadowRadius = 12
            self.searchContainer_Moode.transform = .identity
        }
    }
}

// MARK: - FSPagerView DataSource & Delegate

extension Discover_Moode: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return max(trendingPosts_Moode.count, 1)
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell_Moode = pagerView.dequeueReusableCell(
            withReuseIdentifier: DiscoverTrendingCell_Moode.reuseId_Moode, at: index
        ) as? DiscoverTrendingCell_Moode else { return FSPagerViewCell() }
        if index < trendingPosts_Moode.count {
            cell_Moode.configure_Moode(post_moode: trendingPosts_Moode[index])
        }
        return cell_Moode
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        guard index < trendingPosts_Moode.count else { return }
        Navigation_Moode.toTitleDetail_Moode(titleModel_moode: trendingPosts_Moode[index])
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl_Moode.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl_Moode.currentPage = pagerView.currentIndex
    }
}

// MARK: - UICollectionView DataSource & Delegate（普通帖子瀑布流）

extension Discover_Moode: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularPosts_Moode.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Moode = collectionView.dequeueReusableCell(
            withReuseIdentifier: NormalPostCard_Moode.reuseId_Moode, for: indexPath
        ) as? NormalPostCard_Moode else { return UICollectionViewCell() }

        let post_Moode = popularPosts_Moode[indexPath.item]
        let isLiked_Moode = TitleViewModel_Moode.shared_Moode.isLikedPost_Moode(post_moode: post_Moode)
        // 始终显示媒体区域（有媒体显示图片，无媒体显示占位符）
        cell_Moode.configure_Moode(post_moode: post_Moode, showImage_moode: true, isLiked_moode: isLiked_Moode)
        cell_Moode.onLikeTapped_Moode = { [weak self] post_moode in
            Task { @MainActor in
                TitleViewModel_Moode.shared_Moode.likePost_Moode(post_moode: post_moode)
                self?.reloadData_Moode()
            }
        }
        cell_Moode.onCardTapped_Moode = { post_moode in
            Navigation_Moode.toTitleDetail_Moode(titleModel_moode: post_moode)
        }

        // 头像点击：非登录用户才跳转用户中心
        cell_Moode.onAvatarTapped_Moode = { userId_moode in
            guard !UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(userId_moode: userId_moode) else { return }
            let userModel_moode = UserViewModel_Moode.shared_Moode.getUserById_Moode(userId_moode: userId_moode)
            Navigation_Moode.toUserInfo_Moode(with: userModel_moode)
        }

        // 举报/删除回调：自己的帖子走删除，他人帖子走举报
        cell_Moode.onReportTapped_Moode = { [weak self] post_moode in
            guard let self = self else { return }
            let isMyPost_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
                userId_moode: post_moode.titleUserId_Moode
            )
            if isMyPost_moode {
                ReportDeleteHelper_Moode.delete_Moode(post_Moode: post_moode, from: self) {
                    self.reloadData_Moode()
                }
            } else {
                ReportDeleteHelper_Moode.report_Moode(post_Moode: post_moode, from: self) {
                    self.reloadData_Moode()
                }
            }
        }
        return cell_Moode
    }
}

// MARK: - WaterfallLayoutDelegate（为瀑布流提供各卡片高度）

extension Discover_Moode: WaterfallLayoutDelegate_Moode {

    func waterfallLayout_Moode(
        _ layout_Moode: WaterfallLayout_Moode,
        heightForItemAt indexPath_Moode: IndexPath,
        columnWidth_Moode colW_Moode: CGFloat
    ) -> CGFloat {
        guard indexPath_Moode.item < popularPosts_Moode.count else { return 180 }
        let post_Moode = popularPosts_Moode[indexPath_Moode.item]
        // 始终包含媒体区域高度
        return NormalPostCard_Moode.estimatedHeight_Moode(
            for: post_Moode, columnWidth: colW_Moode, showImage_moode: true
        )
    }
}

// MARK: - 情绪挑战卡片视图

/// 情绪挑战单张卡片视图
/// 功能：展示一个情绪挑战主题，包含渐变背景、发起方 Badge、大号 Emoji 装饰、
///       挑战标题、1~2 条社区极简记录、参与人数
/// 设计：采用与 TrendingCell 相近的渐变卡片风格，但更轻量极简
class ChallengCardView_Moode: UIView {

    // MARK: - UI 组件

    private var gradientLayer_Moode: CAGradientLayer?

    /// 右上角大号装饰 Emoji（半透明）
    private let decorEmoji_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 52)
        l_Moode.alpha = 0.20
        return l_Moode
    }()

    /// 右下装饰圆
    private let decorCircle_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v_Moode.layer.cornerRadius = 40
        return v_Moode
    }()

    /// 发起方 Badge（Official / Community）
    private let sourceBadge_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_Moode.layer.cornerRadius = 9
        return v_Moode
    }()

    private let sourceBadgeLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 9, weight: .bold)
        l_Moode.textColor = .white
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    /// 挑战标题
    private let titleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 15, weight: .heavy)
        l_Moode.textColor = .white
        l_Moode.numberOfLines = 1
        return l_Moode
    }()

    /// 极简记录栈（1~2 条）
    private let recordsStack_Moode: UIStackView = {
        let sv_Moode = UIStackView()
        sv_Moode.axis = .vertical
        sv_Moode.spacing = 5
        sv_Moode.alignment = .fill
        return sv_Moode
    }()

    /// 底部分割线
    private let divider_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return v_Moode
    }()

    /// 参与人数图标
    private let participantIcon_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        iv_Moode.image = UIImage(systemName: "person.2.fill")
        iv_Moode.tintColor = UIColor.white.withAlphaComponent(0.85)
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let participantLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11, weight: .semibold)
        l_Moode.textColor = UIColor.white.withAlphaComponent(0.85)
        return l_Moode
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Moode?.frame = bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Moode() {
        layer.cornerRadius = 18
        clipsToBounds = true

        addSubview(decorCircle_Moode)
        decorCircle_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(20)
            make.width.height.equalTo(80)
        }

        addSubview(decorEmoji_Moode)
        decorEmoji_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.top.equalToSuperview().offset(8)
        }

        // 发起方 Badge
        addSubview(sourceBadge_Moode)
        sourceBadge_Moode.addSubview(sourceBadgeLabel_Moode)
        sourceBadge_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(18)
        }
        sourceBadgeLabel_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(7)
        }

        // 挑战标题
        addSubview(titleLabel_Moode)
        titleLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(sourceBadge_Moode.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }

        // 极简记录列表
        addSubview(recordsStack_Moode)
        recordsStack_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Moode.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }

        // 底部分割线
        addSubview(divider_Moode)
        divider_Moode.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-32)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(0.5)
        }

        // 先 addSubview，再从右到左约束
        addSubview(participantLabel_Moode)
        addSubview(participantIcon_Moode)

        participantLabel_Moode.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-11)
            make.left.equalTo(participantIcon_Moode.snp.right).offset(4)
        }
        participantIcon_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalTo(participantLabel_Moode)
            make.width.equalTo(16)
            make.height.equalTo(12)
        }
    }

    // MARK: - 数据绑定

    /// 绑定挑战数据
    /// 参数：
    /// - challenge_moode: 情绪挑战模型
    func configure_Moode(challenge_moode: MoodChallenge_Moode) {
        decorEmoji_Moode.text = challenge_moode.emoji_Moode
        titleLabel_Moode.text = challenge_moode.title_Moode
        sourceBadgeLabel_Moode.text = challenge_moode.isOfficial_Moode ? "✦ Official" : "◈ Community"

        // 格式化参与人数（千分位）
        let count_Moode = challenge_moode.participantCount_Moode
        participantLabel_Moode.text = count_Moode >= 1000
            ? String(format: "%.1fk joined", Double(count_Moode) / 1000)
            : "\(count_Moode) joined"

        // 构建极简记录条目
        recordsStack_Moode.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for record_Moode in challenge_moode.records_Moode.prefix(2) {
            let row_Moode = buildRecordRow_Moode(text_moode: record_Moode)
            recordsStack_Moode.addArrangedSubview(row_Moode)
        }

        // 渐变背景
        gradientLayer_Moode?.removeFromSuperlayer()
        let grad_Moode = challenge_moode.moodType_Moode.createGradientLayer_Moode(frame_Moode: bounds)
        layer.insertSublayer(grad_Moode, at: 0)
        gradientLayer_Moode = grad_Moode

        setNeedsLayout()
        layoutIfNeeded()
    }

    /// 构建单条极简记录行（圆点 + 文字）
    private func buildRecordRow_Moode(text_moode: String) -> UIView {
        let container_Moode = UIView()

        let dot_Moode = UIView()
        dot_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        dot_Moode.layer.cornerRadius = 3

        let label_Moode = UILabel()
        label_Moode.text = text_moode
        label_Moode.font = .systemFont(ofSize: 11)
        label_Moode.textColor = UIColor.white.withAlphaComponent(0.85)
        label_Moode.numberOfLines = 2
        label_Moode.lineBreakMode = .byTruncatingTail

        container_Moode.addSubview(dot_Moode)
        container_Moode.addSubview(label_Moode)

        dot_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(6)
        }
        label_Moode.snp.makeConstraints { make in
            make.left.equalTo(dot_Moode.snp.right).offset(6)
            make.right.top.bottom.equalToSuperview()
        }
        return container_Moode
    }
}

// MARK: - Trending 轮播卡片 Cell

/// Trending 轮播卡片 Cell
/// 功能：FSPagerView 中的热门帖子卡片，媒体背景（MediaDisplayView_Moode）+ 暗色遮罩 + 情绪渐变回退 + 文字覆盖层
/// 设计：有媒体时展示真实图片/视频封面，无媒体时回退为情绪渐变；底部暗梯度遮罩保证白色文字可读
class DiscoverTrendingCell_Moode: FSPagerViewCell {

    static let reuseId_Moode = "DiscoverTrendingCell_Moode"

    // MARK: - UI 组件

    /// 情绪渐变兜底层（无媒体时可见）
    private var gradientLayer_Moode: CAGradientLayer?

    /// 媒体背景视图（图片/视频封面，撑满 cell）
    private let mediaView_Moode: MediaDisplayView_Moode = {
        let v_Moode = MediaDisplayView_Moode()
        v_Moode.contentMode = .scaleAspectFill
        v_Moode.clipsToBounds = true
        return v_Moode
    }()

    /// 底部暗色渐变遮罩，确保文字在媒体上清晰可读
    private let dimOverlay_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.isUserInteractionEnabled = false
        return v_Moode
    }()

    private var dimGradientLayer_Moode: CAGradientLayer?

    private let decorCircle1_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_Moode.layer.cornerRadius = 55
        return v_Moode
    }()

    private let decorCircle2_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_Moode.layer.cornerRadius = 36
        return v_Moode
    }()

    private let moodBadge_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_Moode.layer.cornerRadius = 12
        v_Moode.layer.borderWidth = 1
        v_Moode.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v_Moode
    }()

    private let moodBadgeEmoji_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 14)
        return l_Moode
    }()

    private let moodBadgeName_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11, weight: .semibold)
        l_Moode.textColor = .white
        return l_Moode
    }()

    private let hotBadge_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#FF6B6B")
        v_Moode.layer.cornerRadius = 10
        v_Moode.isHidden = true
        return v_Moode
    }()

    private let hotLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "🔥 HOT"
        l_Moode.font = .systemFont(ofSize: 10, weight: .bold)
        l_Moode.textColor = .white
        return l_Moode
    }()

    private let titleLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 17, weight: .heavy)
        label_Moode.textColor = .white
        label_Moode.numberOfLines = 2
        return label_Moode
    }()

    private let contentLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 12)
        l_Moode.textColor = UIColor.white.withAlphaComponent(0.75)
        l_Moode.numberOfLines = 1
        l_Moode.lineBreakMode = .byTruncatingTail
        return l_Moode
    }()

    private let bottomDivider_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return v_Moode
    }()

    private let authorLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 11, weight: .medium)
        label_Moode.textColor = UIColor.white.withAlphaComponent(0.80)
        return label_Moode
    }()

    private let heartIcon_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        iv_Moode.image = UIImage(systemName: "heart.fill")
        iv_Moode.tintColor = UIColor.white.withAlphaComponent(0.9)
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let likeLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 12, weight: .bold)
        label_Moode.textColor = UIColor.white.withAlphaComponent(0.9)
        return label_Moode
    }()

    private let commentIcon_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        iv_Moode.image = UIImage(systemName: "bubble.left.fill")
        iv_Moode.tintColor = UIColor.white.withAlphaComponent(0.75)
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let commentLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 12, weight: .medium)
        l_Moode.textColor = UIColor.white.withAlphaComponent(0.75)
        return l_Moode
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTrendingCellUI_Moode()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Moode?.frame = contentView.bounds
        dimGradientLayer_Moode?.frame = dimOverlay_Moode.bounds
    }

    // MARK: - UI 搭建

    private func setupTrendingCellUI_Moode() {
        contentView.layer.cornerRadius = 22
        contentView.clipsToBounds = true

        // 媒体背景（最底层）
        contentView.addSubview(mediaView_Moode)
        mediaView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 暗色遮罩（媒体上方，确保文字可读）
        contentView.addSubview(dimOverlay_Moode)
        dimOverlay_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let dimGrad_Moode = CAGradientLayer()
        dimGrad_Moode.colors = [
            UIColor.black.withAlphaComponent(0.08).cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        dimGrad_Moode.startPoint = CGPoint(x: 0.5, y: 0)
        dimGrad_Moode.endPoint   = CGPoint(x: 0.5, y: 1)
        dimOverlay_Moode.layer.addSublayer(dimGrad_Moode)
        dimGradientLayer_Moode = dimGrad_Moode

        contentView.addSubview(decorCircle1_Moode)
        decorCircle1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-18)
            make.width.height.equalTo(110)
        }

        contentView.addSubview(decorCircle2_Moode)
        decorCircle2_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(14)
            make.width.height.equalTo(72)
        }

        contentView.addSubview(moodBadge_Moode)
        moodBadge_Moode.addSubview(moodBadgeEmoji_Moode)
        moodBadge_Moode.addSubview(moodBadgeName_Moode)
        moodBadge_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(24)
        }
        moodBadgeEmoji_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7)
            make.centerY.equalToSuperview()
        }
        moodBadgeName_Moode.snp.makeConstraints { make in
            make.left.equalTo(moodBadgeEmoji_Moode.snp.right).offset(4)
            make.right.equalToSuperview().offset(-7)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(hotBadge_Moode)
        hotBadge_Moode.addSubview(hotLabel_Moode)
        hotBadge_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        hotLabel_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(7)
        }

        contentView.addSubview(titleLabel_Moode)
        titleLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(moodBadge_Moode.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        contentView.addSubview(contentLabel_Moode)
        contentLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Moode.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        contentView.addSubview(bottomDivider_Moode)
        bottomDivider_Moode.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }

        contentView.addSubview(authorLabel_Moode)
        authorLabel_Moode.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(16)
        }

        // 先全部 addSubview，再从右到左约束，防止 common ancestor 崩溃
        contentView.addSubview(likeLabel_Moode)
        contentView.addSubview(heartIcon_Moode)
        contentView.addSubview(commentLabel_Moode)
        contentView.addSubview(commentIcon_Moode)

        likeLabel_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(authorLabel_Moode)
        }
        heartIcon_Moode.snp.makeConstraints { make in
            make.right.equalTo(likeLabel_Moode.snp.left).offset(-4)
            make.centerY.equalTo(authorLabel_Moode)
            make.width.height.equalTo(13)
        }
        commentLabel_Moode.snp.makeConstraints { make in
            make.right.equalTo(heartIcon_Moode.snp.left).offset(-12)
            make.centerY.equalTo(authorLabel_Moode)
        }
        commentIcon_Moode.snp.makeConstraints { make in
            make.right.equalTo(commentLabel_Moode.snp.left).offset(-4)
            make.centerY.equalTo(authorLabel_Moode)
            make.width.height.equalTo(11)
        }
    }

    // MARK: - 数据绑定

    /// 配置轮播卡片数据
    /// - Parameter post_moode: 帖子数据模型
    func configure_Moode(post_moode: TitleModel_Moode) {
        let mood_Moode = post_moode.moodType_Moode
        moodBadgeEmoji_Moode.text = mood_Moode.emoji_Moode
        moodBadgeName_Moode.text = mood_Moode.displayName_Moode
        titleLabel_Moode.text = post_moode.title_Moode
        contentLabel_Moode.text = post_moode.titleContent_Moode
        authorLabel_Moode.text = "by \(post_moode.titleUserName_Moode)"
        likeLabel_Moode.text = "\(post_moode.likes_Moode)"
        commentLabel_Moode.text = "\(post_moode.reviews_Moode.count)"
        hotBadge_Moode.isHidden = post_moode.likes_Moode < 80

        let firstMedia_Moode = post_moode.titleMeidas_Moode.first
        let hasMedia_Moode   = firstMedia_Moode != nil

        // 媒体背景：有媒体时展示图片，无媒体时隐藏（露出情绪渐变兜底层）
        mediaView_Moode.configure_Moode(mediaPath_Moode: firstMedia_Moode)
        mediaView_Moode.isHidden = !hasMedia_Moode
        // 无媒体时遮罩透明度加深以保证文字可读
        dimOverlay_Moode.alpha = hasMedia_Moode ? 1.0 : 0.45

        // 情绪渐变兜底（仅无媒体时插入，有媒体时不需要）
        gradientLayer_Moode?.removeFromSuperlayer()
        gradientLayer_Moode = nil
        if !hasMedia_Moode {
            let layer_Moode = mood_Moode.createGradientLayer_Moode(frame_Moode: contentView.bounds)
            contentView.layer.insertSublayer(layer_Moode, at: 0)
            gradientLayer_Moode = layer_Moode
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer_Moode?.removeFromSuperlayer()
        gradientLayer_Moode = nil
        mediaView_Moode.isHidden = false
        dimOverlay_Moode.alpha = 1.0
    }
}

// MARK: - WaterfallLayout（瀑布流/不规则网格布局）

/// 瀑布流布局委托协议
/// 外部通过实现该协议为每个 Item 提供对应行高
protocol WaterfallLayoutDelegate_Moode: AnyObject {
    /// 返回指定位置 Item 在给定列宽下的高度
    /// - Parameters:
    ///   - layout_Moode: 当前瀑布流布局实例
    ///   - indexPath_Moode: Item 位置
    ///   - colW_Moode: 当前列的宽度（已减去内边距）
    func waterfallLayout_Moode(
        _ layout_Moode: WaterfallLayout_Moode,
        heightForItemAt indexPath_Moode: IndexPath,
        columnWidth_Moode colW_Moode: CGFloat
    ) -> CGFloat
}

/// 双列不规则瀑布流 UICollectionViewLayout
/// 设计：始终向高度最小的列追加 Item，实现自然错落的瀑布效果
/// 关键属性：numberOfColumns_Moode（列数）、cellPadding_Moode（格间距）、sectionInset_Moode（区边距）
class WaterfallLayout_Moode: UICollectionViewLayout {

    // MARK: - 配置属性

    weak var delegate_Moode: WaterfallLayoutDelegate_Moode?

    /// 列数，默认 2
    var numberOfColumns_Moode: Int = 2
    /// Item 四边内边距（每个 Item 四周都有该间距）
    var cellPadding_Moode: CGFloat = 4
    /// 区域内边距
    var sectionInset_Moode = UIEdgeInsets(top: 6, left: 12, bottom: 12, right: 12)

    // MARK: - 私有属性

    /// 已缓存的 Layout 属性，避免重复计算
    private var cache_Moode: [UICollectionViewLayoutAttributes] = []
    /// 所有 Item 计算后的内容总高度
    private var contentHeight_Moode: CGFloat = 0
    /// 有效内容宽度（去除左右内边距后）
    private var contentWidth_Moode: CGFloat {
        guard let cv_Moode = collectionView else { return 0 }
        return cv_Moode.bounds.width - sectionInset_Moode.left - sectionInset_Moode.right
    }

    override var collectionViewContentSize: CGSize {
        let totalH_Moode = contentHeight_Moode + sectionInset_Moode.top + sectionInset_Moode.bottom
        return CGSize(width: contentWidth_Moode + sectionInset_Moode.left + sectionInset_Moode.right,
                      height: totalH_Moode)
    }

    // MARK: - 布局计算

    /// 准备布局：按"最短列优先"原则计算每个 Item 的 frame
    override func prepare() {
        guard cache_Moode.isEmpty, let cv_Moode = collectionView, cv_Moode.bounds.width > 0 else { return }

        // 每列宽度 = (有效宽度 - 列间间距总量) / 列数
        let gapTotal_Moode = CGFloat(numberOfColumns_Moode - 1) * cellPadding_Moode * 2
        let colWidth_Moode = (contentWidth_Moode - gapTotal_Moode) / CGFloat(numberOfColumns_Moode)

        // 每列的 X 起始坐标
        var xOffsets_Moode: [CGFloat] = (0..<numberOfColumns_Moode).map { col_Moode in
            sectionInset_Moode.left + CGFloat(col_Moode) * (colWidth_Moode + cellPadding_Moode * 2)
        }

        // 每列当前 Y 偏移（初始为 sectionInset.top）
        var yOffsets_Moode = [CGFloat](repeating: sectionInset_Moode.top, count: numberOfColumns_Moode)

        let count_Moode = cv_Moode.numberOfItems(inSection: 0)
        for item_Moode in 0..<count_Moode {
            let indexPath_Moode = IndexPath(item: item_Moode, section: 0)

            // 找出当前最短列
            let shortestCol_Moode = yOffsets_Moode.enumerated()
                .min(by: { $0.element < $1.element })?.offset ?? 0

            // 向委托询问 Item 高度
            let itemH_Moode = delegate_Moode?.waterfallLayout_Moode(
                self, heightForItemAt: indexPath_Moode, columnWidth_Moode: colWidth_Moode
            ) ?? 180

            let frame_Moode = CGRect(
                x: xOffsets_Moode[shortestCol_Moode],
                y: yOffsets_Moode[shortestCol_Moode],
                width: colWidth_Moode,
                height: itemH_Moode
            )

            let attributes_Moode = UICollectionViewLayoutAttributes(forCellWith: indexPath_Moode)
            attributes_Moode.frame = frame_Moode
            cache_Moode.append(attributes_Moode)

            contentHeight_Moode = max(contentHeight_Moode, frame_Moode.maxY)
            yOffsets_Moode[shortestCol_Moode] += itemH_Moode + cellPadding_Moode * 2
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache_Moode.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cache_Moode.count else { return nil }
        return cache_Moode[indexPath.item]
    }

    /// Bounds 变化（如屏幕旋转）时清除缓存并重新计算
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        cache_Moode.removeAll()
        contentHeight_Moode = 0
        return true
    }
}

// MARK: - NormalPostCard（普通帖子瀑布流卡片 Cell）

/// 普通帖子瀑布流卡片
/// 功能：展示帖子作者头像、昵称、标题、正文摘要、可选媒体缩略图、点赞/评论数
/// 设计：白色圆角卡片 + 顶部彩色强调条，偶数序号卡片显示媒体缩略图以制造高度差异
/// 关键方法：configure_Moode / estimatedHeight_Moode
class NormalPostCard_Moode: UICollectionViewCell {

    static let reuseId_Moode = "NormalPostCard_Moode"

    // MARK: - 回调
    var onCardTapped_Moode: ((TitleModel_Moode) -> Void)?
    var onLikeTapped_Moode: ((TitleModel_Moode) -> Void)?
    /// 头像点击回调（携带帖子作者 userId）
    var onAvatarTapped_Moode: ((Int) -> Void)?
    /// 举报/删除按钮回调（由外部 VC 注入）
    var onReportTapped_Moode: ((TitleModel_Moode) -> Void)?

    // MARK: - 私有状态
    private var post_Moode: TitleModel_Moode?
    private var isLiked_Moode = false
    private var showImage_Moode = false

    // MARK: - UI 组件

    /// 卡片底座（白色圆角 + 阴影）
    private let cardView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 14
        v_Moode.layer.shadowColor = UIColor.black.cgColor
        v_Moode.layer.shadowOpacity = 0.07
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_Moode.layer.shadowRadius = 8
        v_Moode.layer.masksToBounds = false
        return v_Moode
    }()

    /// 顶部彩色强调条（颜色基于帖子 ID 循环选取）
    private let accentBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.layer.cornerRadius = 2
        v_Moode.clipsToBounds = true
        return v_Moode
    }()

    /// 媒体缩略图容器（仅偶数序号卡片展示）
    private let imageContainer_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.clipsToBounds = true
        v_Moode.layer.cornerRadius = 10
        v_Moode.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_Moode
    }()
    private let mediaView_Moode = MediaDisplayView_Moode(frame: .zero)
    private var imageHeightConstraint_Moode: Constraint?

    /// 作者行：头像 + 昵称
    private let avatarContainer_Moode = UIView()
    private let avatarView_Moode = UserAvatarView_Moode(frame: .zero)
    private let nameLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 12, weight: .semibold)
        l_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        return l_Moode
    }()

    /// 标题
    private let titleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 14, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        l_Moode.numberOfLines = 2
        return l_Moode
    }()

    /// 正文摘要
    private let contentLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 12)
        l_Moode.textColor = ColorConfig_Moode.textSecondary_Moode
        l_Moode.numberOfLines = 3
        return l_Moode
    }()

    /// 操作行：点赞 + 评论数
    private let actionsRow_Moode = UIView()
    private let likeBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .system)
        btn_Moode.tintColor = ColorConfig_Moode.textPlaceholder_Moode
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        btn_Moode.setImage(UIImage(systemName: "heart", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg_Moode), for: .selected)
        return btn_Moode
    }()
    private let likeCountLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11)
        l_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return l_Moode
    }()
    private let commentIconView_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        iv_Moode.image = UIImage(systemName: "bubble.left", withConfiguration: cfg_Moode)
        iv_Moode.tintColor = ColorConfig_Moode.textPlaceholder_Moode
        return iv_Moode
    }()
    private let commentCountLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11)
        l_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return l_Moode
    }()

    /// 右上角举报/删除按钮（半透明圆形背景）
    private let reportBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .system)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        btn_Moode.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = UIColor(hexstring_Moode: "#666699")
        btn_Moode.backgroundColor = UIColor(hexstring_Moode: "#F0EEFF")
        btn_Moode.layer.cornerRadius = 11
        btn_Moode.clipsToBounds = true
        return btn_Moode
    }()

    // MARK: - 强调条颜色池（循环取色）
    private static let accentColors_Moode: [UIColor] = [
        UIColor(hexstring_Moode: "#6C5CE7"),
        UIColor(hexstring_Moode: "#00B894"),
        UIColor(hexstring_Moode: "#E17055"),
        UIColor(hexstring_Moode: "#0984E3"),
        UIColor(hexstring_Moode: "#FDCB6E"),
        UIColor(hexstring_Moode: "#E84393")
    ]

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Moode()
    }

    // MARK: - UI 搭建

    /// 搭建卡片内 UI 层级与约束
    private func setupUI_Moode() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView_Moode)
        cardView_Moode.snp.makeConstraints { make_Moode in
            make_Moode.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        }

        // 媒体缩略图区域（顶部，高度动态设置）
        cardView_Moode.addSubview(imageContainer_Moode)
        imageContainer_Moode.snp.makeConstraints { make_Moode in
            make_Moode.top.left.right.equalToSuperview()
            imageHeightConstraint_Moode = make_Moode.height.equalTo(0).constraint
        }
        imageContainer_Moode.addSubview(mediaView_Moode)
        mediaView_Moode.snp.makeConstraints { make_Moode in
            make_Moode.edges.equalToSuperview()
        }

        // 强调条（位于图片区域下方 / 顶部）
        cardView_Moode.addSubview(accentBar_Moode)
        accentBar_Moode.snp.makeConstraints { make_Moode in
            make_Moode.top.equalTo(imageContainer_Moode.snp.bottom).offset(12)
            make_Moode.left.equalToSuperview().offset(12)
            make_Moode.width.equalTo(24)
            make_Moode.height.equalTo(3)
        }

        // 作者行
        cardView_Moode.addSubview(avatarContainer_Moode)
        avatarContainer_Moode.snp.makeConstraints { make_Moode in
            make_Moode.top.equalTo(accentBar_Moode.snp.bottom).offset(8)
            make_Moode.left.equalToSuperview().offset(12)
            make_Moode.right.equalToSuperview().offset(-12)
            make_Moode.height.equalTo(28)
        }

        avatarContainer_Moode.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make_Moode in
            make_Moode.left.centerY.equalToSuperview()
            make_Moode.width.height.equalTo(24)
        }

        avatarContainer_Moode.addSubview(nameLabel_Moode)
        nameLabel_Moode.snp.makeConstraints { make_Moode in
            make_Moode.left.equalTo(avatarView_Moode.snp.right).offset(6)
            make_Moode.centerY.equalToSuperview()
            make_Moode.right.lessThanOrEqualToSuperview()
        }

        // 标题
        cardView_Moode.addSubview(titleLabel_Moode)
        titleLabel_Moode.snp.makeConstraints { make_Moode in
            make_Moode.top.equalTo(avatarContainer_Moode.snp.bottom).offset(8)
            make_Moode.left.equalToSuperview().offset(12)
            make_Moode.right.equalToSuperview().offset(-12)
        }

        // 正文摘要
        cardView_Moode.addSubview(contentLabel_Moode)
        contentLabel_Moode.snp.makeConstraints { make_Moode in
            make_Moode.top.equalTo(titleLabel_Moode.snp.bottom).offset(5)
            make_Moode.left.equalToSuperview().offset(12)
            make_Moode.right.equalToSuperview().offset(-12)
        }

        // 操作行
        cardView_Moode.addSubview(actionsRow_Moode)
        actionsRow_Moode.snp.makeConstraints { make_Moode in
            make_Moode.top.equalTo(contentLabel_Moode.snp.bottom).offset(8)
            make_Moode.left.equalToSuperview().offset(12)
            make_Moode.right.equalToSuperview().offset(-12)
            make_Moode.height.equalTo(24)
            make_Moode.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        actionsRow_Moode.addSubview(likeBtn_Moode)
        likeBtn_Moode.snp.makeConstraints { make_Moode in
            make_Moode.left.centerY.equalToSuperview()
            make_Moode.width.height.equalTo(24)
        }

        actionsRow_Moode.addSubview(likeCountLabel_Moode)
        likeCountLabel_Moode.snp.makeConstraints { make_Moode in
            make_Moode.left.equalTo(likeBtn_Moode.snp.right).offset(2)
            make_Moode.centerY.equalToSuperview()
        }

        actionsRow_Moode.addSubview(commentIconView_Moode)
        commentIconView_Moode.snp.makeConstraints { make_Moode in
            make_Moode.left.equalTo(likeCountLabel_Moode.snp.right).offset(10)
            make_Moode.centerY.equalToSuperview()
            make_Moode.width.height.equalTo(14)
        }

        actionsRow_Moode.addSubview(commentCountLabel_Moode)
        commentCountLabel_Moode.snp.makeConstraints { make_Moode in
            make_Moode.left.equalTo(commentIconView_Moode.snp.right).offset(2)
            make_Moode.centerY.equalToSuperview()
        }

        // 举报按钮（右上角，覆盖在卡片上层）
        cardView_Moode.addSubview(reportBtn_Moode)
        reportBtn_Moode.snp.makeConstraints { make_Moode in
            make_Moode.top.equalToSuperview().offset(8)
            make_Moode.right.equalToSuperview().offset(-8)
            make_Moode.width.height.equalTo(22)
        }
        reportBtn_Moode.addAction(UIAction { [weak self] _ in
            guard let self = self, let post_Moode = self.post_Moode else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.onReportTapped_Moode?(post_Moode)
        }, for: .touchUpInside)

        // 点赞按钮事件
        likeBtn_Moode.addAction(UIAction { [weak self] _ in
            guard let self = self, let post_Moode = self.post_Moode else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.onLikeTapped_Moode?(post_Moode)
        }, for: .touchUpInside)

        // 卡片点击事件
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Moode))
        cardView_Moode.addGestureRecognizer(tap_Moode)
        cardView_Moode.isUserInteractionEnabled = true

        // 头像点击事件（独立于卡片手势）
        avatarView_Moode.isUserInteractionEnabled = true
        let avatarTap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Moode))
        avatarView_Moode.addGestureRecognizer(avatarTap_Moode)
    }

    /// 处理头像点击，触发 onAvatarTapped_Moode 回调并携带作者 userId
    @objc private func handleAvatarTap_Moode() {
        guard let userId_Moode = post_Moode?.titleUserId_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAvatarTapped_Moode?(userId_Moode)
    }

    @objc private func handleCardTap_Moode() {
        guard let post_Moode = post_Moode else { return }
        UIView.animate(withDuration: 0.08, animations: {
            self.cardView_Moode.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.12) { self.cardView_Moode.transform = .identity }
        }
        onCardTapped_Moode?(post_Moode)
    }

    // MARK: - 数据绑定

    /// 绑定帖子数据
    /// - Parameters:
    ///   - post_moode: 帖子模型
    ///   - showImage_moode: 是否显示媒体缩略图（偶数序号卡片传 true 制造高度差异）
    ///   - isLiked_moode: 当前用户是否已点赞
    func configure_Moode(post_moode: TitleModel_Moode, showImage_moode: Bool, isLiked_moode: Bool) {
        post_Moode = post_moode
        isLiked_Moode = isLiked_moode
        showImage_Moode = showImage_moode

        // 强调条颜色（按帖子 ID 循环）
        let colorIdx_Moode = post_moode.titleId_Moode % NormalPostCard_Moode.accentColors_Moode.count
        accentBar_Moode.backgroundColor = NormalPostCard_Moode.accentColors_Moode[colorIdx_Moode]

        // 作者信息
        avatarView_Moode.configure_Moode(userId_Moode: post_moode.titleUserId_Moode)
        nameLabel_Moode.text = post_moode.titleUserName_Moode

        // 标题与正文
        titleLabel_Moode.text = post_moode.title_Moode
        contentLabel_Moode.numberOfLines = showImage_moode ? 2 : 3
        contentLabel_Moode.text = post_moode.titleContent_Moode

        // 媒体缩略图：始终展示媒体区域，无媒体时由 MediaDisplayView 渲染占位符
        imageContainer_Moode.isHidden = false
        imageHeightConstraint_Moode?.update(offset: 110)
        mediaView_Moode.configure_Moode(mediaPath_Moode: post_moode.titleMeidas_Moode.first)

        // 点赞
        likeBtn_Moode.isSelected = isLiked_moode
        likeBtn_Moode.tintColor = isLiked_moode
            ? UIColor(hexstring_Moode: "#E84393")
            : ColorConfig_Moode.textPlaceholder_Moode
        likeCountLabel_Moode.text = "\(post_moode.likes_Moode)"
        commentCountLabel_Moode.text = "\(post_moode.reviews_Moode.count)"

        // 根据是否为自己的帖子切换右上角按钮图标：自己→删除(trash)，他人→举报(ellipsis)
        let isMyPost_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
            userId_moode: post_moode.titleUserId_Moode
        )
        let reportCfg_moode = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let reportIcon_moode = isMyPost_moode ? "trash" : "ellipsis"
        reportBtn_Moode.setImage(UIImage(systemName: reportIcon_moode, withConfiguration: reportCfg_moode), for: .normal)
        reportBtn_Moode.tintColor = isMyPost_moode
            ? UIColor(hexstring_Moode: "#FF6B6B")
            : UIColor(hexstring_Moode: "#666699")
        reportBtn_Moode.backgroundColor = isMyPost_moode
            ? UIColor(hexstring_Moode: "#FF6B6B").withAlphaComponent(0.12)
            : UIColor(hexstring_Moode: "#F0EEFF")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        post_Moode = nil
        showImage_Moode = true
        onAvatarTapped_Moode = nil
        onReportTapped_Moode = nil
        // 保持媒体区域可见，等待新数据填充
        imageContainer_Moode.isHidden = false
        imageHeightConstraint_Moode?.update(offset: 110)
    }

    // MARK: - 静态高度估算

    /// 预估指定帖子在指定列宽下的卡片高度（供 WaterfallLayout 提前计算布局）
    /// - Parameters:
    ///   - post: 帖子模型
    ///   - columnWidth: 列宽（像素）
    ///   - showImage_moode: 保留参数以兼容调用方，内部始终包含媒体区域高度
    /// - Returns: 估算高度（向上取整）
    static func estimatedHeight_Moode(for post: TitleModel_Moode, columnWidth: CGFloat, showImage_moode: Bool) -> CGFloat {
        let textW_Moode = max(1, columnWidth - 24) // 左右各 12pt 内边距
        // 基础高度：卡片内边距 + 强调条 + 作者行 + 操作行
        var h_Moode: CGFloat = 4 + 3 + 8 + 28 + 8 + 24 + 10 // = 89

        // 所有卡片始终包含媒体区域（无媒体时显示占位符）
        h_Moode += 110 + 12

        // 标题行数（每行约 8.5pt/字符，最多 2 行）
        let titleCPL_Moode = max(1, Int(textW_Moode / 8.5))
        let titleLines_Moode = min(2, max(1, Int(ceil(Double(post.title_Moode.count) / Double(titleCPL_Moode)))))
        h_Moode += CGFloat(titleLines_Moode) * 20 + 8

        // 正文行数（每行约 7pt/字符，最多 2 行）
        let contentCPL_Moode = max(1, Int(textW_Moode / 7.0))
        let contentLines_Moode = min(2, max(1, Int(ceil(Double(post.titleContent_Moode.count) / Double(contentCPL_Moode)))))
        h_Moode += CGFloat(contentLines_Moode) * 17 + 5

        return ceil(h_Moode)
    }
}

// MARK: - 挑战点击手势（携带挑战数据）

/// 携带挑战模型的点击手势识别器，解决 UITapGestureRecognizer 无法直接传参的问题
class ChallengeTapGesture_Moode: UITapGestureRecognizer {
    /// 关联的挑战数据
    let challenge_Moode: MoodChallenge_Moode
    init(challenge_moode: MoodChallenge_Moode) {
        self.challenge_Moode = challenge_moode
        super.init(target: nil, action: nil)
    }
}
