import Foundation
import UIKit
import SnapKit

// MARK: - 首页

/// 春季搭配技巧首页
/// 核心功能：展示特色搭配卡片、调色盘工作台、一键发布春日穿搭、穿搭日历与贴纸 Tips
/// 设计思路：以樱花粉、薄雾蓝为主色，结合花瓣粒子动画营造春日氛围
/// 逻辑与UI严格解耦，数据操作均通过 TitleViewModel_Clara 完成
class Home_Clara: UIViewController, UIColorPickerViewControllerDelegate, UITextViewDelegate {

    // MARK: - 分类枚举（兼容保留，不在首页展示）

    enum StyleCategory_Clara: Int, CaseIterable {
        case all_clara = 0
        case floral_clara
        case pastel_clara
        case layering_clara
        case accessories_clara

        var title_Clara: String {
            switch self {
            case .all_clara:         return "All"
            case .floral_clara:      return "Floral"
            case .pastel_clara:      return "Pastel"
            case .layering_clara:    return "Layering"
            case .accessories_clara: return "Accessories"
            }
        }

        var icon_Clara: String {
            switch self {
            case .all_clara:         return "sparkles"
            case .floral_clara:      return "leaf.fill"
            case .pastel_clara:      return "paintpalette.fill"
            case .layering_clara:    return "square.3.layers.3d.top.filled"
            case .accessories_clara: return "crown.fill"
            }
        }
    }
    
    // MARK: - UI 组件
    
    /// 主滚动视图
    private lazy var scrollView_Clara: UIScrollView = {
        let sv_Clara = UIScrollView()
        sv_Clara.showsVerticalScrollIndicator = false
        sv_Clara.backgroundColor = ColorConfig_Clara.springCreamWhite_Clara
        sv_Clara.contentInsetAdjustmentBehavior = .never
        return sv_Clara
    }()
    
    /// 滚动内容容器
    private lazy var contentView_Clara: UIView = {
        let v_Clara = UIView()
        v_Clara.backgroundColor = ColorConfig_Clara.springCreamWhite_Clara
        return v_Clara
    }()
    
    /// 顶部 Banner 容器
    private lazy var bannerView_Clara: UIView = {
        let v_Clara = UIView()
        v_Clara.clipsToBounds = true
        return v_Clara
    }()
    
    /// Banner 渐变图层
    private var bannerGradientLayer_Clara: CAGradientLayer?
    
    /// 花瓣粒子发射图层
    private var petalEmitterLayer_Clara: CAEmitterLayer?
    
    /// Banner 标题
    private lazy var bannerTitleLabel_Clara: UILabel = {
        let lbl_Clara = UILabel()
        lbl_Clara.text = "Spring Style"
        lbl_Clara.font = UIFont.systemFont(ofSize: 36, weight: .black)
        lbl_Clara.textColor = .white
        lbl_Clara.textAlignment = .center
        return lbl_Clara
    }()
    
    /// Banner 副标题
    private lazy var bannerSubtitleLabel_Clara: UILabel = {
        let lbl_Clara = UILabel()
        lbl_Clara.text = "Bloom Into Spring ✦"
        lbl_Clara.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl_Clara.textColor = UIColor.white.withAlphaComponent(0.9)
        lbl_Clara.textAlignment = .center
        return lbl_Clara
    }()
    
    /// Banner 装饰角标
    private lazy var bannerBadgeLabel_Clara: UILabel = {
        let lbl_Clara = UILabel()
        lbl_Clara.text = "2025 Collection"
        lbl_Clara.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Clara.textColor = ColorConfig_Clara.springCherryBlossom_Clara
        lbl_Clara.backgroundColor = .white
        lbl_Clara.textAlignment = .center
        lbl_Clara.layer.cornerRadius = 10
        lbl_Clara.layer.masksToBounds = true
        return lbl_Clara
    }()
    
    /// 特色搭配标题
    private lazy var featuredTitleLabel_Clara: UILabel = {
        let lbl_Clara = UILabel()
        lbl_Clara.text = "Featured Looks"
        lbl_Clara.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Clara.textColor = ColorConfig_Clara.textPrimary_Clara
        return lbl_Clara
    }()
    
    /// 特色搭配更多按钮
    private lazy var featuredMoreButton_Clara: UIButton = {
        let btn_Clara = UIButton(type: .system)
        btn_Clara.setTitle("See All", for: .normal)
        btn_Clara.setTitleColor(ColorConfig_Clara.springCherryBlossom_Clara, for: .normal)
        btn_Clara.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn_Clara.addTarget(self, action: #selector(seeAllFeaturedTapped_Clara), for: .touchUpInside)
        return btn_Clara
    }()
    
    /// 特色搭配卡片水平滚动视图
    private lazy var featuredScrollView_Clara: UIScrollView = {
        let sv_Clara = UIScrollView()
        sv_Clara.showsHorizontalScrollIndicator = false
        sv_Clara.isPagingEnabled = false
        sv_Clara.decelerationRate = .fast
        sv_Clara.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sv_Clara.delegate = self
        return sv_Clara
    }()
    
    /// 特色卡片容器
    private lazy var featuredCardsStack_Clara: UIStackView = {
        let sv_Clara = UIStackView()
        sv_Clara.axis = .horizontal
        sv_Clara.spacing = 14
        sv_Clara.alignment = .fill
        return sv_Clara
    }()

    // 旧版组件（保留仅用于兼容方法，不再挂载到页面）
    private lazy var categoryScrollView_Clara = UIScrollView()
    private lazy var categoryStackView_Clara = UIStackView()
    private lazy var trendingTitleLabel_Clara = UILabel()
    private lazy var trendingStackView_Clara: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    private lazy var paletteTitleLabel_Clara = UILabel()
    private lazy var paletteStackView_Clara: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        return sv
    }()

    /// 调色盘工作台容器
    private let paletteStudioCard_Clara = UIView()
    private let palettePreviewPrimary_Clara = UIView()
    private let palettePreviewAccent_Clara = UIView()
    private let palettePreviewMixed_Clara = UIView()
    private let paletteNamePrimary_Clara = UILabel()
    private let paletteNameAccent_Clara = UILabel()
    private let paletteNameMixed_Clara = UILabel()
    private let paletteTableLabel_Clara = UILabel()
    private let paletteButtonsRow1_Clara = UIStackView()
    private let paletteButtonsRow2_Clara = UIStackView()
    private let pickPrimaryColorButton_Clara = UIButton(type: .system)
    private let pickAccentColorButton_Clara = UIButton(type: .system)

    /// 一键发布与穿搭日历容器
    private let dailyOutfitCard_Clara = UIView()
    private let publishTodayButton_Clara = UIButton(type: .custom)
    private let weatherTagLabel_Clara = UILabel()
    private let filterTagLabel_Clara = UILabel()
    private let calendarGrid_Clara = UIStackView()
    private let outfitPreviewImageView_Clara = UIImageView()
    private let uploadOutfitButton_Clara = UIButton(type: .system)
    private let outfitDescriptionView_Clara = UITextView()

    /// 贴纸 Tips 容器
    private let tipsCard_Clara = UIView()
    private let tipsStack_Clara = UIStackView()
    
    // MARK: - 数据属性

    /// 首页展示帖子列表
    private var filteredPosts_Clara: [TitleModel_Clara] = []

    // 旧版状态（保留仅用于兼容方法，不再驱动首页）
    private var selectedCategory_Clara: StyleCategory_Clara = .all_clara
    private var categoryButtons_Clara: [UIButton] = []

    /// 调色盘主色/辅助色
    private var selectedPrimaryColor_Clara: UIColor = ColorConfig_Clara.springCherryBlossom_Clara
    private var selectedAccentColor_Clara: UIColor = ColorConfig_Clara.springMistBlue_Clara

    /// 穿搭日历：本月已发布日期集合
    private var publishedOutfitDays_Clara: Set<Int> = []
    /// 穿搭日历：按日期索引发布记录
    private var dailyOutfitPostsByDay_Clara: [Int: [TitleModel_Clara]] = [:]
    /// 一键发布选择的图片
    private var selectedOutfitImage_Clara: UIImage?

    /// 调色盘当前拾色目标
    private enum ColorTarget_Clara {
        case primary_clara
        case accent_clara
    }
    private var currentColorTarget_Clara: ColorTarget_Clara = .primary_clara
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView_Clara()
        setupBanner_Clara()
        setupFeaturedSection_Clara()
        setupPaletteStudioSection_Clara()
        setupDailyOutfitSection_Clara()
        setupTipsSection_Clara()
        loadData_Clara()
        observeStateChange_Clara()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变和粒子图层的 frame
        updateBannerLayerFrames_Clara()
        view.updateThemeBackgroundFrame_Clara()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 监听通知
    
    /// 监听帖子状态变化通知，刷新数据
    private func observeStateChange_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChanged_Clara),
            name: TitleViewModel_Clara.titleStateDidChangeNotification_Clara,
            object: nil
        )
    }
    
    @objc private func onTitleStateChanged_Clara() {
        loadData_Clara()
    }
    
    // MARK: - UI 搭建：滚动视图
    
    /// 搭建主滚动视图布局
    private func setupScrollView_Clara() {
        view.applyThemeBackground_Clara()
        view.addSubview(scrollView_Clara)
        scrollView_Clara.addSubview(contentView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        scrollView_Clara.backgroundColor = .clear
        contentView_Clara.backgroundColor = .clear
        scrollView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    // MARK: - UI 搭建：Banner
    
    /// 搭建顶部春季 Banner（含花瓣粒子动画）
    private func setupBanner_Clara() {
        contentView_Clara.addSubview(bannerView_Clara)
        bannerView_Clara.addSubview(bannerTitleLabel_Clara)
        bannerView_Clara.addSubview(bannerSubtitleLabel_Clara)
        bannerView_Clara.addSubview(bannerBadgeLabel_Clara)
        
        bannerView_Clara.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(228)
        }
        
        bannerBadgeLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(120)
        }
        
        bannerTitleLabel_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        bannerSubtitleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(bannerTitleLabel_Clara.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    /// 更新 Banner 渐变图层和粒子图层的 frame
    private func updateBannerLayerFrames_Clara() {
        let bannerBounds = bannerView_Clara.bounds
        guard bannerBounds.width > 0 else { return }
        
        // 渐变图层
        if bannerGradientLayer_Clara == nil {
            let gradient_Clara = UIColor.createSpringGradientLayer_Clara(frame_Clara: bannerBounds)
            bannerView_Clara.layer.insertSublayer(gradient_Clara, at: 0)
            bannerGradientLayer_Clara = gradient_Clara
            startPetalAnimation_Clara()
        } else {
            bannerGradientLayer_Clara?.frame = bannerBounds
        }
    }
    
    // MARK: - UI 搭建：分类标签栏
    
    /// 搭建分类标签横向滚动栏
    private func setupCategoryBar_Clara() {
        contentView_Clara.addSubview(categoryScrollView_Clara)
        categoryScrollView_Clara.addSubview(categoryStackView_Clara)
        
        categoryScrollView_Clara.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Clara.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        categoryStackView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // 生成分类标签按钮
        for category_Clara in StyleCategory_Clara.allCases {
            let btn_Clara = buildCategoryButton_Clara(category_Clara: category_Clara)
            categoryStackView_Clara.addArrangedSubview(btn_Clara)
            categoryButtons_Clara.append(btn_Clara)
            btn_Clara.snp.makeConstraints { make in
                make.height.equalTo(36)
            }
        }
        
        // 默认选中 All
        updateCategorySelection_Clara(selected_Clara: .all_clara)
    }
    
    // MARK: - UI 搭建：特色搭配区
    
    /// 搭建特色搭配区（水平卡片滚动）
    private func setupFeaturedSection_Clara() {
        let headerView_Clara = UIView()
        contentView_Clara.addSubview(headerView_Clara)
        headerView_Clara.addSubview(featuredTitleLabel_Clara)
        headerView_Clara.addSubview(featuredMoreButton_Clara)
        contentView_Clara.addSubview(featuredScrollView_Clara)
        featuredScrollView_Clara.addSubview(featuredCardsStack_Clara)
        
        headerView_Clara.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Clara.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        
        featuredTitleLabel_Clara.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        featuredMoreButton_Clara.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
        
        featuredScrollView_Clara.snp.makeConstraints { make in
            make.top.equalTo(headerView_Clara.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        featuredCardsStack_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    // MARK: - UI 搭建：调色盘工作台

    /// 搭建特色卡片下方的调色盘工作台
    private func setupPaletteStudioSection_Clara() {
        paletteStudioCard_Clara.backgroundColor = .white
        paletteStudioCard_Clara.layer.cornerRadius = 20
        paletteStudioCard_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        paletteStudioCard_Clara.layer.shadowOffset = CGSize(width: 0, height: 4)
        paletteStudioCard_Clara.layer.shadowOpacity = 1
        paletteStudioCard_Clara.layer.shadowRadius = 12
        contentView_Clara.addSubview(paletteStudioCard_Clara)
        paletteStudioCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(featuredScrollView_Clara.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Color Lab"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        paletteStudioCard_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(18)
        }

        let subLabel = UILabel()
        subLabel.text = "Pick two tones and blend spring combinations"
        subLabel.font = UIFont.systemFont(ofSize: 12)
        subLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        paletteStudioCard_Clara.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalTo(titleLabel)
        }

        for preview in [palettePreviewPrimary_Clara, palettePreviewAccent_Clara, palettePreviewMixed_Clara] {
            preview.layer.cornerRadius = 14
            preview.layer.shadowColor = UIColor.black.cgColor
            preview.layer.shadowOffset = CGSize(width: 0, height: 3)
            preview.layer.shadowOpacity = 0.12
            preview.layer.shadowRadius = 6
            paletteStudioCard_Clara.addSubview(preview)
        }
        palettePreviewPrimary_Clara.backgroundColor = selectedPrimaryColor_Clara
        palettePreviewAccent_Clara.backgroundColor = selectedAccentColor_Clara
        palettePreviewMixed_Clara.backgroundColor = mixColor_Clara(first_Clara: selectedPrimaryColor_Clara, second_Clara: selectedAccentColor_Clara)

        palettePreviewPrimary_Clara.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(18)
            make.width.equalToSuperview().multipliedBy(0.28)
            make.height.equalTo(64)
        }
        palettePreviewAccent_Clara.snp.makeConstraints { make in
            make.top.equalTo(palettePreviewPrimary_Clara)
            make.left.equalTo(palettePreviewPrimary_Clara.snp.right).offset(10)
            make.width.equalTo(palettePreviewPrimary_Clara)
            make.height.equalTo(64)
        }
        palettePreviewMixed_Clara.snp.makeConstraints { make in
            make.top.equalTo(palettePreviewPrimary_Clara)
            make.left.equalTo(palettePreviewAccent_Clara.snp.right).offset(10)
            make.right.equalToSuperview().inset(18)
            make.height.equalTo(64)
        }

        for label in [paletteNamePrimary_Clara, paletteNameAccent_Clara, paletteNameMixed_Clara] {
            label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            label.textAlignment = .center
            label.textColor = ColorConfig_Clara.textSecondary_Clara
            paletteStudioCard_Clara.addSubview(label)
        }
        paletteNamePrimary_Clara.snp.makeConstraints { make in
            make.top.equalTo(palettePreviewPrimary_Clara.snp.bottom).offset(6)
            make.centerX.equalTo(palettePreviewPrimary_Clara)
        }
        paletteNameAccent_Clara.snp.makeConstraints { make in
            make.top.equalTo(palettePreviewAccent_Clara.snp.bottom).offset(6)
            make.centerX.equalTo(palettePreviewAccent_Clara)
        }
        paletteNameMixed_Clara.snp.makeConstraints { make in
            make.top.equalTo(palettePreviewMixed_Clara.snp.bottom).offset(6)
            make.centerX.equalTo(palettePreviewMixed_Clara)
        }

        paletteButtonsRow1_Clara.axis = .horizontal
        paletteButtonsRow1_Clara.spacing = 10
        paletteButtonsRow1_Clara.distribution = .fillEqually
        paletteButtonsRow2_Clara.axis = .horizontal
        paletteButtonsRow2_Clara.spacing = 10
        paletteButtonsRow2_Clara.distribution = .fillEqually
        paletteStudioCard_Clara.addSubview(paletteButtonsRow1_Clara)
        paletteStudioCard_Clara.addSubview(paletteButtonsRow2_Clara)
        paletteButtonsRow1_Clara.snp.makeConstraints { make in
            make.top.equalTo(paletteNamePrimary_Clara.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(34)
        }
        paletteButtonsRow2_Clara.snp.makeConstraints { make in
            make.top.equalTo(paletteButtonsRow1_Clara.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(34)
        }

        pickPrimaryColorButton_Clara.setTitle("Pick Primary", for: .normal)
        pickPrimaryColorButton_Clara.setTitleColor(.white, for: .normal)
        pickPrimaryColorButton_Clara.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        pickPrimaryColorButton_Clara.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara
        pickPrimaryColorButton_Clara.layer.cornerRadius = 10
        pickPrimaryColorButton_Clara.addTarget(self, action: #selector(pickPrimaryColorTapped_Clara), for: .touchUpInside)

        pickAccentColorButton_Clara.setTitle("Pick Accent", for: .normal)
        pickAccentColorButton_Clara.setTitleColor(.white, for: .normal)
        pickAccentColorButton_Clara.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        pickAccentColorButton_Clara.backgroundColor = ColorConfig_Clara.primaryGradientEnd_Clara
        pickAccentColorButton_Clara.layer.cornerRadius = 10
        pickAccentColorButton_Clara.addTarget(self, action: #selector(pickAccentColorTapped_Clara), for: .touchUpInside)
        paletteStudioCard_Clara.addSubview(pickPrimaryColorButton_Clara)
        paletteStudioCard_Clara.addSubview(pickAccentColorButton_Clara)
        pickPrimaryColorButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(paletteButtonsRow2_Clara.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(18)
            make.width.equalTo(120)
            make.height.equalTo(32)
        }
        pickAccentColorButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(pickPrimaryColorButton_Clara)
            make.left.equalTo(pickPrimaryColorButton_Clara.snp.right).offset(8)
            make.width.equalTo(120)
            make.height.equalTo(32)
        }

        let colorPool: [UIColor] = [
            ColorConfig_Clara.springCherryBlossom_Clara,
            ColorConfig_Clara.springMistBlue_Clara,
            ColorConfig_Clara.springFreshGreen_Clara,
            ColorConfig_Clara.springLavender_Clara,
            ColorConfig_Clara.springWarmApricot_Clara,
            ColorConfig_Clara.primaryGradientStart_Clara,
            ColorConfig_Clara.primaryGradientEnd_Clara,
            UIColor(hexstring_Clara: "#8EC5FC")
        ]
        for (index, color) in colorPool.enumerated() {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = color
            btn.layer.cornerRadius = 10
            btn.tag = index
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.white.cgColor
            btn.addTarget(self, action: #selector(colorChipTapped_Clara(_:)), for: .touchUpInside)
            if index < 4 {
                paletteButtonsRow1_Clara.addArrangedSubview(btn)
            } else {
                paletteButtonsRow2_Clara.addArrangedSubview(btn)
            }
        }

        paletteTableLabel_Clara.font = UIFont.systemFont(ofSize: 12)
        paletteTableLabel_Clara.textColor = ColorConfig_Clara.textSecondary_Clara
        paletteTableLabel_Clara.numberOfLines = 0
        paletteStudioCard_Clara.addSubview(paletteTableLabel_Clara)
        paletteTableLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(pickPrimaryColorButton_Clara.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
        }

        refreshPaletteStudio_Clara()
    }

    // MARK: - UI 搭建：一键发布 + 穿搭日历

    /// 搭建一键发布与春季穿搭日历区域
    private func setupDailyOutfitSection_Clara() {
        dailyOutfitCard_Clara.backgroundColor = .white
        dailyOutfitCard_Clara.layer.cornerRadius = 20
        dailyOutfitCard_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        dailyOutfitCard_Clara.layer.shadowOffset = CGSize(width: 0, height: 4)
        dailyOutfitCard_Clara.layer.shadowOpacity = 1
        dailyOutfitCard_Clara.layer.shadowRadius = 12
        contentView_Clara.addSubview(dailyOutfitCard_Clara)
        dailyOutfitCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(paletteStudioCard_Clara.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Daily Outfit Boost"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        dailyOutfitCard_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(18)
        }

        weatherTagLabel_Clara.text = "Weather: Mild · 18°C"
        weatherTagLabel_Clara.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        weatherTagLabel_Clara.textColor = .white
        weatherTagLabel_Clara.backgroundColor = ColorConfig_Clara.springFreshGreen_Clara
        weatherTagLabel_Clara.textAlignment = .center
        weatherTagLabel_Clara.layer.cornerRadius = 10
        weatherTagLabel_Clara.clipsToBounds = true
        dailyOutfitCard_Clara.addSubview(weatherTagLabel_Clara)
        weatherTagLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel)
            make.height.equalTo(22)
            make.width.equalTo(130)
        }

        filterTagLabel_Clara.text = "Spring Filter: Bloom Glow"
        filterTagLabel_Clara.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        filterTagLabel_Clara.textColor = .white
        filterTagLabel_Clara.backgroundColor = ColorConfig_Clara.springCherryBlossom_Clara
        filterTagLabel_Clara.textAlignment = .center
        filterTagLabel_Clara.layer.cornerRadius = 10
        filterTagLabel_Clara.clipsToBounds = true
        dailyOutfitCard_Clara.addSubview(filterTagLabel_Clara)
        filterTagLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(weatherTagLabel_Clara)
            make.left.equalTo(weatherTagLabel_Clara.snp.right).offset(8)
            make.height.equalTo(22)
            make.width.equalTo(170)
        }

        publishTodayButton_Clara.setTitle("One-Tap Publish Today Outfit", for: .normal)
        publishTodayButton_Clara.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        publishTodayButton_Clara.setTitleColor(.white, for: .normal)
        publishTodayButton_Clara.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara
        publishTodayButton_Clara.layer.cornerRadius = 14
        publishTodayButton_Clara.addTarget(self, action: #selector(oneTapPublishTapped_Clara), for: .touchUpInside)
        dailyOutfitCard_Clara.addSubview(publishTodayButton_Clara)
        publishTodayButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(weatherTagLabel_Clara.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(46)
        }

        let uploadWrap = UIView()
        uploadWrap.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        uploadWrap.layer.cornerRadius = 14
        dailyOutfitCard_Clara.addSubview(uploadWrap)
        uploadWrap.snp.makeConstraints { make in
            make.top.equalTo(publishTodayButton_Clara.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(18)
        }

        outfitPreviewImageView_Clara.backgroundColor = UIColor.white
        outfitPreviewImageView_Clara.layer.cornerRadius = 10
        outfitPreviewImageView_Clara.clipsToBounds = true
        outfitPreviewImageView_Clara.contentMode = .center
        outfitPreviewImageView_Clara.image = UIImage(systemName: "photo")
        outfitPreviewImageView_Clara.tintColor = ColorConfig_Clara.textPlaceholder_Clara
        uploadWrap.addSubview(outfitPreviewImageView_Clara)
        outfitPreviewImageView_Clara.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(10)
            make.width.height.equalTo(84)
        }

        uploadOutfitButton_Clara.setTitle("Upload Outfit Image", for: .normal)
        uploadOutfitButton_Clara.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        uploadOutfitButton_Clara.setTitleColor(.white, for: .normal)
        uploadOutfitButton_Clara.backgroundColor = ColorConfig_Clara.springMistBlue_Clara
        uploadOutfitButton_Clara.layer.cornerRadius = 10
        uploadOutfitButton_Clara.addTarget(self, action: #selector(uploadOutfitImageTapped_Clara), for: .touchUpInside)
        uploadWrap.addSubview(uploadOutfitButton_Clara)
        uploadOutfitButton_Clara.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(outfitPreviewImageView_Clara.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(32)
        }

        outfitDescriptionView_Clara.font = UIFont.systemFont(ofSize: 13)
        outfitDescriptionView_Clara.textColor = ColorConfig_Clara.textPlaceholder_Clara
        outfitDescriptionView_Clara.backgroundColor = UIColor.white
        outfitDescriptionView_Clara.layer.cornerRadius = 10
        outfitDescriptionView_Clara.text = "Describe your outfit..."
        outfitDescriptionView_Clara.delegate = self
        uploadWrap.addSubview(outfitDescriptionView_Clara)
        outfitDescriptionView_Clara.snp.makeConstraints { make in
            make.top.equalTo(uploadOutfitButton_Clara.snp.bottom).offset(8)
            make.left.equalTo(outfitPreviewImageView_Clara.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(10)
        }

        let calendarTitle = UILabel()
        calendarTitle.text = "Spring Outfit Calendar"
        calendarTitle.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        calendarTitle.textColor = ColorConfig_Clara.textPrimary_Clara
        dailyOutfitCard_Clara.addSubview(calendarTitle)
        calendarTitle.snp.makeConstraints { make in
            make.top.equalTo(uploadWrap.snp.bottom).offset(14)
            make.left.equalTo(titleLabel)
        }

        calendarGrid_Clara.axis = .vertical
        calendarGrid_Clara.spacing = 6
        dailyOutfitCard_Clara.addSubview(calendarGrid_Clara)
        calendarGrid_Clara.snp.makeConstraints { make in
            make.top.equalTo(calendarTitle.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
        }
    }

    // MARK: - UI 搭建：贴纸 Tips

    /// 搭建每日贴纸 Tips 速递区域（点击模态弹窗展示描述）
    private func setupTipsSection_Clara() {
        tipsCard_Clara.backgroundColor = .white
        tipsCard_Clara.layer.cornerRadius = 20
        tipsCard_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        tipsCard_Clara.layer.shadowOffset = CGSize(width: 0, height: 4)
        tipsCard_Clara.layer.shadowOpacity = 1
        tipsCard_Clara.layer.shadowRadius = 12
        contentView_Clara.addSubview(tipsCard_Clara)
        tipsCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(dailyOutfitCard_Clara.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-120)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Daily Sticker Tips Express"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        tipsCard_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(18)
        }

        tipsStack_Clara.axis = .vertical
        tipsStack_Clara.spacing = 10
        tipsStack_Clara.distribution = .fillEqually
        tipsCard_Clara.addSubview(tipsStack_Clara)
        tipsStack_Clara.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(14)
            make.height.equalTo(188)
            make.bottom.equalToSuperview().inset(18)
        }

        let tipItems: [(String, String)] = [
            ("🌸", "Floral"),
            ("☀️", "Sunny"),
            ("🍃", "Fresh"),
            ("🧣", "Layer"),
            ("👖", "Denim"),
            ("👟", "Sneaker"),
            ("🎒", "Accessory"),
            ("☔️", "Rainy")
        ]
        var currentIndex = 0
        for _ in 0..<2 {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.distribution = .fillEqually
            for _ in 0..<4 {
                let item = tipItems[currentIndex]
                let btn = UIButton(type: .custom)
                btn.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
                btn.layer.cornerRadius = 14
                btn.tag = currentIndex
                btn.setTitle("\(item.0)\n\(item.1)", for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                btn.titleLabel?.numberOfLines = 2
                btn.titleLabel?.textAlignment = .center
                btn.setTitleColor(ColorConfig_Clara.textPrimary_Clara, for: .normal)
                btn.addTarget(self, action: #selector(tipStickerTapped_Clara(_:)), for: .touchUpInside)
                row.addArrangedSubview(btn)
                currentIndex += 1
            }
            tipsStack_Clara.addArrangedSubview(row)
        }
    }
    
    // MARK: - UI 搭建：热门帖子区
    
    /// 搭建热门帖子区（垂直卡片列表）
    private func setupTrendingSection_Clara() {
        contentView_Clara.addSubview(trendingTitleLabel_Clara)
        contentView_Clara.addSubview(trendingStackView_Clara)
        
        trendingTitleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(featuredScrollView_Clara.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        trendingStackView_Clara.snp.makeConstraints { make in
            make.top.equalTo(trendingTitleLabel_Clara.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    // MARK: - UI 搭建：春季色卡区
    
    /// 搭建春季色卡区域
    private func setupPaletteSection_Clara() {
        let wrapView_Clara = UIView()
        wrapView_Clara.backgroundColor = .white
        wrapView_Clara.layer.cornerRadius = 20
        wrapView_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        wrapView_Clara.layer.shadowOffset = CGSize(width: 0, height: 4)
        wrapView_Clara.layer.shadowOpacity = 1
        wrapView_Clara.layer.shadowRadius = 12
        
        contentView_Clara.addSubview(wrapView_Clara)
        wrapView_Clara.addSubview(paletteTitleLabel_Clara)
        wrapView_Clara.addSubview(paletteStackView_Clara)
        
        wrapView_Clara.snp.makeConstraints { make in
            make.top.equalTo(trendingStackView_Clara.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-120)
        }
        
        paletteTitleLabel_Clara.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        paletteStackView_Clara.snp.makeConstraints { make in
            make.top.equalTo(paletteTitleLabel_Clara.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(72)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 春季五色卡数据
        let paletteData_Clara: [(UIColor, String)] = [
            (ColorConfig_Clara.springCherryBlossom_Clara, "Cherry"),
            (ColorConfig_Clara.springFreshGreen_Clara,    "Green"),
            (ColorConfig_Clara.springMistBlue_Clara,      "Mist"),
            (ColorConfig_Clara.springLavender_Clara,      "Lavender"),
            (ColorConfig_Clara.springWarmApricot_Clara,   "Apricot"),
        ]
        
        for (color_Clara, name_Clara) in paletteData_Clara {
            let colorBlock_Clara = buildColorBlock_Clara(color_Clara: color_Clara, name_Clara: name_Clara)
            paletteStackView_Clara.addArrangedSubview(colorBlock_Clara)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载并过滤帖子数据，刷新各区域 UI
    private func loadData_Clara() {
        let allPosts_Clara = TitleViewModel_Clara.shared_Clara.getPosts_Clara()
        filteredPosts_Clara = allPosts_Clara
            .sorted { $0.titleId_Clara > $1.titleId_Clara }
        refreshFeaturedCards_Clara()
        refreshPaletteStudio_Clara()
        refreshOutfitCalendar_Clara()
    }
    
    // MARK: - 刷新 UI
    
    /// 刷新特色搭配卡片区域
    private func refreshFeaturedCards_Clara() {
        featuredCardsStack_Clara.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let featuredPosts_Clara = Array(filteredPosts_Clara.prefix(5))
        
        if featuredPosts_Clara.isEmpty {
            let emptyLabel_Clara = UILabel()
            emptyLabel_Clara.text = "No looks yet in this category"
            emptyLabel_Clara.textColor = ColorConfig_Clara.textSecondary_Clara
            emptyLabel_Clara.font = UIFont.systemFont(ofSize: 14)
            emptyLabel_Clara.snp.makeConstraints { make in make.width.equalTo(220) }
            featuredCardsStack_Clara.addArrangedSubview(emptyLabel_Clara)
            return
        }
        
        for post_Clara in featuredPosts_Clara {
            let card_Clara = buildFeaturedCard_Clara(post_Clara: post_Clara)
            featuredCardsStack_Clara.addArrangedSubview(card_Clara)
            card_Clara.snp.makeConstraints { make in
                make.width.equalTo(160)
            }
        }
    }
    
    /// 刷新热门帖子列表
    private func refreshTrendingList_Clara() {
        trendingStackView_Clara.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 按点赞数排序，取前 4 条
        let trending_Clara = filteredPosts_Clara
            .sorted { $0.likes_Clara > $1.likes_Clara }
            .prefix(4)
        
        for post_Clara in trending_Clara {
            let row_Clara = buildTrendingRow_Clara(post_Clara: post_Clara)
            trendingStackView_Clara.addArrangedSubview(row_Clara)
        }
        
        if trending_Clara.isEmpty {
            let emptyLabel_Clara = UILabel()
            emptyLabel_Clara.text = "No trending posts yet"
            emptyLabel_Clara.textColor = ColorConfig_Clara.textSecondary_Clara
            emptyLabel_Clara.font = UIFont.systemFont(ofSize: 14)
            emptyLabel_Clara.textAlignment = .center
            trendingStackView_Clara.addArrangedSubview(emptyLabel_Clara)
        }
    }
    
    // MARK: - 组件构建
    
    /// 构建分类标签按钮
    /// - Parameter category_Clara: 对应的分类枚举
    /// - Returns: 已配置的 UIButton
    private func buildCategoryButton_Clara(category_Clara: StyleCategory_Clara) -> UIButton {
        let btn_Clara = UIButton(type: .custom)
        
        var config_Clara = UIButton.Configuration.filled()
        config_Clara.title = category_Clara.title_Clara
        config_Clara.image = UIImage(systemName: category_Clara.icon_Clara)
        config_Clara.imagePadding = 5
        config_Clara.imagePlacement = .leading
        config_Clara.baseForegroundColor = ColorConfig_Clara.textSecondary_Clara
        config_Clara.baseBackgroundColor = .white
        config_Clara.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        config_Clara.cornerStyle = .capsule
        config_Clara.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var a_Clara = attr
            a_Clara.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            return a_Clara
        }
        btn_Clara.configuration = config_Clara
        btn_Clara.tag = category_Clara.rawValue
        btn_Clara.layer.cornerRadius = 18
        btn_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        btn_Clara.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn_Clara.layer.shadowOpacity = 1
        btn_Clara.layer.shadowRadius = 6
        btn_Clara.addTarget(self, action: #selector(categoryButtonTapped_Clara(_:)), for: .touchUpInside)
        return btn_Clara
    }
    
    /// 构建特色搭配卡片
    /// - Parameter post_Clara: 帖子数据模型
    /// - Returns: 卡片视图
    private func buildFeaturedCard_Clara(post_Clara: TitleModel_Clara) -> UIView {
        let card_Clara = UIView()
        card_Clara.backgroundColor = .white
        card_Clara.layer.cornerRadius = 18
        card_Clara.clipsToBounds = true
        card_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        card_Clara.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Clara.layer.shadowOpacity = 1
        card_Clara.layer.shadowRadius = 10
        
        // 媒体展示区
        let mediaView_Clara = MediaDisplayView_Clara()
        mediaView_Clara.layer.cornerRadius = 18
        let mediaPath_Clara = post_Clara.titleMeidas_Clara.first
        let isVideo_Clara = isVideoMediaPath_Clara(mediaPath_Clara: mediaPath_Clara)
        mediaView_Clara.configure_Clara(mediaPath_Clara: mediaPath_Clara, isVideo_Clara: isVideo_Clara)
        
        // 标题
        let titleLabel_Clara = UILabel()
        titleLabel_Clara.text = post_Clara.title_Clara
        titleLabel_Clara.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLabel_Clara.textColor = ColorConfig_Clara.textPrimary_Clara
        titleLabel_Clara.numberOfLines = 2
        
        // 点赞按钮
        let likeButton_Clara = buildLikeButton_Clara(post_Clara: post_Clara)

        // 举报 / 删除按钮
        let actionButton_Clara = ReportDeleteHelper_Clara.createPostReportButton_Clara(
            post_Clara: post_Clara,
            size_Clara: 13,
            color_Clara: .white,
            from: self,
            completion_Clara: { [weak self] in
                self?.loadData_Clara()
            }
        )
        actionButton_Clara.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        actionButton_Clara.layer.cornerRadius = 14
        
        card_Clara.addSubview(mediaView_Clara)
        card_Clara.addSubview(titleLabel_Clara)
        card_Clara.addSubview(likeButton_Clara)
        card_Clara.addSubview(actionButton_Clara)
        
        mediaView_Clara.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        actionButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Clara.snp.top).offset(8)
            make.right.equalTo(mediaView_Clara.snp.right).offset(-8)
            make.width.height.equalTo(28)
        }
        
        titleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Clara.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        likeButton_Clara.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(28)
        }
        
        // 点击卡片跳转详情
        let tap_Clara = UITapGestureRecognizer(target: self, action: #selector(featuredCardTapped_Clara(_:)))
        card_Clara.addGestureRecognizer(tap_Clara)
        card_Clara.isUserInteractionEnabled = true
        card_Clara.tag = post_Clara.titleId_Clara
        
        return card_Clara
    }

    /// 判断媒体路径是否为视频
    /// 功能：通过媒体路径后缀快速识别视频资源，供首页特色卡片统一配置媒体组件
    /// 参数：
    /// - mediaPath_Clara: 媒体路径或资源名
    /// 返回值：Bool - 视频返回 `true`，其余情况返回 `false`
    private func isVideoMediaPath_Clara(mediaPath_Clara: String?) -> Bool {
        guard let mediaPath_Clara = mediaPath_Clara?.lowercased(), !mediaPath_Clara.isEmpty else {
            return false
        }
        return mediaPath_Clara.hasSuffix(".mp4")
        || mediaPath_Clara.hasSuffix(".mov")
        || mediaPath_Clara.hasSuffix(".m4v")
    }
    
    /// 构建热门帖子行卡片
    /// - Parameter post_Clara: 帖子数据模型
    /// - Returns: 行卡片视图
    private func buildTrendingRow_Clara(post_Clara: TitleModel_Clara) -> UIView {
        let card_Clara = UIView()
        card_Clara.backgroundColor = .white
        card_Clara.layer.cornerRadius = 16
        card_Clara.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        card_Clara.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_Clara.layer.shadowOpacity = 1
        card_Clara.layer.shadowRadius = 8
        
        // 左侧彩色竖条
        let accentBar_Clara = UIView()
        let barColors_Clara: [UIColor] = [
            ColorConfig_Clara.springCherryBlossom_Clara,
            ColorConfig_Clara.springFreshGreen_Clara,
            ColorConfig_Clara.springMistBlue_Clara,
            ColorConfig_Clara.springLavender_Clara,
        ]
        accentBar_Clara.backgroundColor = barColors_Clara[post_Clara.titleId_Clara % 4]
        accentBar_Clara.layer.cornerRadius = 3
        
        // 标题
        let titleLabel_Clara = UILabel()
        titleLabel_Clara.text = post_Clara.title_Clara
        titleLabel_Clara.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel_Clara.textColor = ColorConfig_Clara.textPrimary_Clara
        titleLabel_Clara.numberOfLines = 1
        
        // 内容摘要
        let contentLabel_Clara = UILabel()
        contentLabel_Clara.text = post_Clara.titleContent_Clara
        contentLabel_Clara.font = UIFont.systemFont(ofSize: 13)
        contentLabel_Clara.textColor = ColorConfig_Clara.textSecondary_Clara
        contentLabel_Clara.numberOfLines = 2
        
        // 底部信息行（用户名 + 点赞数）
        let infoRow_Clara = UIStackView()
        infoRow_Clara.axis = .horizontal
        infoRow_Clara.spacing = 8
        infoRow_Clara.alignment = .center
        
        let userLabel_Clara = UILabel()
        userLabel_Clara.text = "by \(post_Clara.titleUserName_Clara)"
        userLabel_Clara.font = UIFont.systemFont(ofSize: 12)
        userLabel_Clara.textColor = ColorConfig_Clara.textPlaceholder_Clara
        
        let spacer_Clara = UIView()
        spacer_Clara.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let likeButton_Clara = buildLikeButton_Clara(post_Clara: post_Clara)
        
        infoRow_Clara.addArrangedSubview(userLabel_Clara)
        infoRow_Clara.addArrangedSubview(spacer_Clara)
        infoRow_Clara.addArrangedSubview(likeButton_Clara)
        
        card_Clara.addSubview(accentBar_Clara)
        card_Clara.addSubview(titleLabel_Clara)
        card_Clara.addSubview(contentLabel_Clara)
        card_Clara.addSubview(infoRow_Clara)
        
        accentBar_Clara.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.equalTo(4)
        }
        
        titleLabel_Clara.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(accentBar_Clara.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Clara.snp.bottom).offset(6)
            make.leading.equalTo(accentBar_Clara.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        infoRow_Clara.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Clara.snp.bottom).offset(8)
            make.leading.equalTo(accentBar_Clara.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        // 点击行卡片跳转详情
        let tap_Clara = UITapGestureRecognizer(target: self, action: #selector(trendingRowTapped_Clara(_:)))
        card_Clara.addGestureRecognizer(tap_Clara)
        card_Clara.isUserInteractionEnabled = true
        card_Clara.tag = post_Clara.titleId_Clara
        
        return card_Clara
    }
    
    /// 构建点赞按钮
    /// - Parameter post_Clara: 帖子模型（用于确定点赞状态和数量）
    /// - Returns: 配置好的点赞按钮
    private func buildLikeButton_Clara(post_Clara: TitleModel_Clara) -> UIButton {
        let isLiked_Clara = TitleViewModel_Clara.shared_Clara.isLikedPost_Clara(post_clara: post_Clara)
        
        let btn_Clara = UIButton(type: .custom)
        var config_Clara = UIButton.Configuration.plain()
        let heartIcon_Clara = isLiked_Clara ? "heart.fill" : "heart"
        let iconConfig_Clara = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        config_Clara.image = UIImage(systemName: heartIcon_Clara, withConfiguration: iconConfig_Clara)
        config_Clara.title = "\(post_Clara.likes_Clara)"
        config_Clara.imagePadding = 4
        config_Clara.baseForegroundColor = isLiked_Clara
            ? ColorConfig_Clara.springCherryBlossom_Clara
            : ColorConfig_Clara.textSecondary_Clara
        config_Clara.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        config_Clara.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var a_Clara = attr
            a_Clara.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            return a_Clara
        }
        btn_Clara.configuration = config_Clara
        btn_Clara.backgroundColor = isLiked_Clara
            ? ColorConfig_Clara.springCherryBlossom_Clara.withAlphaComponent(0.12)
            : ColorConfig_Clara.backgroundPrimary_Clara
        btn_Clara.layer.cornerRadius = 12
        
        // 绑定帖子 ID 到 tag，点击时在 action 中查找对应帖子
        btn_Clara.tag = post_Clara.titleId_Clara
        btn_Clara.addTarget(self, action: #selector(likeButtonTapped_Clara(_:)), for: .touchUpInside)
        return btn_Clara
    }

    // MARK: - 调色盘逻辑

    /// 更新调色盘预览、颜色名和搭配表文案
    private func refreshPaletteStudio_Clara() {
        let mixedColor = mixColor_Clara(first_Clara: selectedPrimaryColor_Clara, second_Clara: selectedAccentColor_Clara)
        palettePreviewPrimary_Clara.backgroundColor = selectedPrimaryColor_Clara
        palettePreviewAccent_Clara.backgroundColor = selectedAccentColor_Clara
        palettePreviewMixed_Clara.backgroundColor = mixedColor

        let primaryName = colorName_Clara(color_Clara: selectedPrimaryColor_Clara)
        let accentName = colorName_Clara(color_Clara: selectedAccentColor_Clara)
        let mixedName = colorName_Clara(color_Clara: mixedColor)

        paletteNamePrimary_Clara.text = primaryName
        paletteNameAccent_Clara.text = accentName
        paletteNameMixed_Clara.text = mixedName

        let primaryHex = colorHex_Clara(color_Clara: selectedPrimaryColor_Clara)
        let accentHex = colorHex_Clara(color_Clara: selectedAccentColor_Clara)
        let mixedHex = colorHex_Clara(color_Clara: mixedColor)
        paletteTableLabel_Clara.text =
            "Color Match Table\n" +
            "• Base: \(primaryName) (\(primaryHex))\n" +
            "• Accent: \(accentName) (\(accentHex))\n" +
            "• Mix: \(mixedName) (\(mixedHex))\n" +
            "• Suggestion: Top in \(primaryName), accessory in \(accentName), shoe/detail in \(mixedName)."
    }

    /// 混合两种颜色（按 RGB 均值）
    private func mixColor_Clara(first_Clara: UIColor, second_Clara: UIColor) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        first_Clara.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        second_Clara.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(
            red: (r1 + r2) / 2,
            green: (g1 + g2) / 2,
            blue: (b1 + b2) / 2,
            alpha: 1
        )
    }

    /// 生成颜色名（简化映射）
    private func colorName_Clara(color_Clara: UIColor) -> String {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color_Clara.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if s < 0.15 { return "Soft Gray" }
        switch h {
        case 0.00..<0.05, 0.95...1.0: return "Rose Red"
        case 0.05..<0.12: return "Warm Apricot"
        case 0.12..<0.22: return "Sunny Amber"
        case 0.22..<0.42: return "Fresh Green"
        case 0.42..<0.56: return "Mint Blue"
        case 0.56..<0.72: return "Sky Blue"
        case 0.72..<0.84: return "Lavender"
        default: return "Cherry Pink"
        }
    }

    /// 颜色转十六进制字符串
    private func colorHex_Clara(color_Clara: UIColor) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color_Clara.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    // MARK: - 穿搭日历逻辑

    /// 刷新穿搭日历（当前月份）
    private func refreshOutfitCalendar_Clara() {
        calendarGrid_Clara.arrangedSubviews.forEach { $0.removeFromSuperview() }
        publishedOutfitDays_Clara.removeAll()
        dailyOutfitPostsByDay_Clara.removeAll()

        let currentUserId = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara().userId_Clara ?? -1
        let posts = TitleViewModel_Clara.shared_Clara.getPosts_Clara().filter { $0.titleUserId_Clara == currentUserId }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        for post in posts where post.title_Clara.contains("[Daily Outfit]") {
            if let dateText = post.titleContent_Clara.components(separatedBy: "Date: ").last?.components(separatedBy: "\n").first,
               let date = formatter.date(from: dateText) {
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                let day = calendar.component(.day, from: date)
                if month == currentMonth && year == currentYear {
                    publishedOutfitDays_Clara.insert(day)
                    dailyOutfitPostsByDay_Clara[day, default: []].append(post)
                }
            }
        }

        let weekHeader = UIStackView()
        weekHeader.axis = .horizontal
        weekHeader.spacing = 6
        weekHeader.distribution = .fillEqually
        let symbols = ["M", "T", "W", "T", "F", "S", "S"]
        for s in symbols {
            let label = UILabel()
            label.text = s
            label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            label.textColor = ColorConfig_Clara.textPlaceholder_Clara
            label.textAlignment = .center
            weekHeader.addArrangedSubview(label)
        }
        calendarGrid_Clara.addArrangedSubview(weekHeader)

        let range = calendar.range(of: .day, in: .month, for: today) ?? 1..<31
        let totalDays = range.count
        var day = 1
        while day <= totalDays {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 6
            row.distribution = .fillEqually
            for _ in 0..<7 {
                let cell = UIButton(type: .custom)
                cell.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
                cell.layer.cornerRadius = 9
                cell.clipsToBounds = true
                if day <= totalDays {
                    cell.setTitle("\(day)", for: .normal)
                    cell.tag = day
                    cell.addTarget(self, action: #selector(calendarDateTapped_Clara(_:)), for: .touchUpInside)
                    if publishedOutfitDays_Clara.contains(day) {
                        cell.backgroundColor = ColorConfig_Clara.springCherryBlossom_Clara.withAlphaComponent(0.22)
                        cell.setTitleColor(ColorConfig_Clara.springCherryBlossom_Clara, for: .normal)
                        cell.layer.borderWidth = 1
                        cell.layer.borderColor = ColorConfig_Clara.springCherryBlossom_Clara.withAlphaComponent(0.6).cgColor
                    } else {
                        cell.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
                        cell.setTitleColor(ColorConfig_Clara.textSecondary_Clara, for: .normal)
                        cell.layer.borderWidth = 0
                    }
                    day += 1
                } else {
                    cell.setTitle("", for: .normal)
                    cell.backgroundColor = .clear
                    cell.isUserInteractionEnabled = false
                }
                row.addArrangedSubview(cell)
            }
            calendarGrid_Clara.addArrangedSubview(row)
        }
    }

    /// 保存图片到临时目录，返回可用路径
    private func saveImageToTemp_Clara(image_Clara: UIImage) -> String {
        let fileName = "daily_outfit_\(Int(Date().timeIntervalSince1970)).jpg"
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(fileName)
        if let data = image_Clara.jpegData(compressionQuality: 0.9) {
            try? data.write(to: URL(fileURLWithPath: filePath))
        }
        return filePath
    }

    /// 展示某日期的穿搭发布记录（无记录时展示空态）
    private func showDailyOutfitRecordsModal_Clara(day_Clara: Int, records_Clara: [TitleModel_Clara]) {
        dismissCustomModalIfNeeded_Clara(tag_Clara: 92001)

        let hostView = modalHostView_Clara()
        let overlay = createHalfModalOverlay_Clara(tag_Clara: 92001)
        hostView.addSubview(overlay)
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let cardParts_Clara = createHalfModalCardContainer_Clara(tag_Clara: 92101)
        let card = cardParts_Clara.container_Clara
        let cardContent = cardParts_Clara.content_Clara
        overlay.addSubview(card)
        card.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
            make.top.greaterThanOrEqualTo(hostView.safeAreaLayoutGuide.snp.top).offset(88)
            make.height.lessThanOrEqualTo(hostView.snp.height).multipliedBy(0.74)
        }

        let indicator = createHalfModalIndicator_Clara()
        cardContent.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }

        let badgeButton = createHalfModalBadgeButton_Clara(
            title_Clara: "Outfit Calendar",
            titleColor_Clara: ColorConfig_Clara.primaryGradientStart_Clara,
            backgroundColor_Clara: ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.10)
        )
        cardContent.addSubview(badgeButton)
        badgeButton.snp.makeConstraints { make in
            make.top.equalTo(indicator.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(18)
            make.height.equalTo(28)
        }

        let closeButton = createHalfModalCloseButton_Clara(tag_Clara: 92001)
        cardContent.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(badgeButton)
            make.right.equalToSuperview().offset(-18)
            make.width.height.equalTo(34)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Records on Day \(day_Clara)"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        cardContent.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(badgeButton.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(18)
            make.right.equalTo(closeButton.snp.left).offset(-12)
        }

        let subtitleLabel = UILabel()
        subtitleLabel.text = records_Clara.isEmpty
        ? "No look has been saved for this day yet."
        : "\(records_Clara.count) look record\(records_Clara.count > 1 ? "s" : "") saved for this day."
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        subtitleLabel.numberOfLines = 0
        cardContent.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(18)
        }

        let divider = UIView()
        divider.backgroundColor = ColorConfig_Clara.divider_Clara
        cardContent.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(1)
        }

        if records_Clara.isEmpty {
            let emptyStateView = createHalfModalEmptyStateView_Clara(
                iconName_Clara: "calendar",
                title_Clara: "No Outfit Record",
                subtitle_Clara: "Publish a spring look and it will appear here for quick review."
            )
            cardContent.addSubview(emptyStateView)
            emptyStateView.snp.makeConstraints { make in
                make.top.equalTo(divider.snp.bottom).offset(26)
                make.left.right.equalToSuperview().inset(18)
                make.bottom.equalToSuperview().offset(-max(hostView.safeAreaInsets.bottom, 16) - 22)
            }
            presentHalfModal_Clara(overlay_Clara: overlay, card_Clara: card)
            return
        }

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: max(hostView.safeAreaInsets.bottom, 16) + 14, right: 0)
        cardContent.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(14)
            make.left.right.bottom.equalToSuperview()
        }

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        scrollView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
            make.width.equalTo(scrollView.snp.width).offset(-36)
        }

        for post in records_Clara {
            let itemCard = UIView()
            itemCard.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
            itemCard.layer.cornerRadius = 18
            itemCard.layer.borderWidth = 1
            itemCard.layer.borderColor = UIColor.white.withAlphaComponent(0.72).cgColor
            itemCard.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
            itemCard.layer.shadowOffset = CGSize(width: 0, height: 8)
            itemCard.layer.shadowOpacity = 1
            itemCard.layer.shadowRadius = 16
            stack.addArrangedSubview(itemCard)

            let titleIconView = UIImageView(image: UIImage(systemName: "sparkles"))
            titleIconView.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
            titleIconView.contentMode = .scaleAspectFit
            itemCard.addSubview(titleIconView)
            titleIconView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(14)
                make.left.equalToSuperview().offset(14)
                make.width.height.equalTo(16)
            }

            let nameLabel = UILabel()
            nameLabel.text = post.title_Clara
            nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            nameLabel.textColor = ColorConfig_Clara.textPrimary_Clara
            nameLabel.numberOfLines = 2
            itemCard.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.centerY.equalTo(titleIconView)
                make.left.equalTo(titleIconView.snp.right).offset(8)
                make.right.equalToSuperview().offset(-58)
            }

            let deleteButton = UIButton(type: .system)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.tintColor = ColorConfig_Clara.springCherryBlossom_Clara
            deleteButton.backgroundColor = ColorConfig_Clara.springCherryBlossom_Clara.withAlphaComponent(0.12)
            deleteButton.layer.cornerRadius = 14
            deleteButton.tag = post.titleId_Clara
            deleteButton.addTarget(self, action: #selector(deleteDailyRecordTapped_Clara(_:)), for: .touchUpInside)
            itemCard.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-12)
                make.width.height.equalTo(28)
            }

            let contentLabel = UILabel()
            contentLabel.text = post.titleContent_Clara
            contentLabel.font = UIFont.systemFont(ofSize: 13)
            contentLabel.textColor = ColorConfig_Clara.textSecondary_Clara
            contentLabel.numberOfLines = 3
            itemCard.addSubview(contentLabel)
            contentLabel.snp.makeConstraints { make in
                make.top.equalTo(titleIconView.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(14)
                make.right.equalToSuperview().offset(-14)
                make.bottom.equalToSuperview().offset(-14)
            }
        }
        presentHalfModal_Clara(overlay_Clara: overlay, card_Clara: card)
    }

    /// 展示贴纸描述模态弹窗
    private func showTipModal_Clara(title_Clara: String, description_Clara: String) {
        dismissCustomModalIfNeeded_Clara(tag_Clara: 92002)

        let hostView = modalHostView_Clara()
        let overlay = createHalfModalOverlay_Clara(tag_Clara: 92002)
        hostView.addSubview(overlay)
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let cardParts_Clara = createHalfModalCardContainer_Clara(tag_Clara: 92102)
        let card = cardParts_Clara.container_Clara
        let cardContent = cardParts_Clara.content_Clara
        overlay.addSubview(card)
        card.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
            make.top.greaterThanOrEqualTo(hostView.safeAreaLayoutGuide.snp.top).offset(190)
            make.height.lessThanOrEqualTo(hostView.snp.height).multipliedBy(0.54)
        }

        let indicator = createHalfModalIndicator_Clara()
        cardContent.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }

        let closeButton = createHalfModalCloseButton_Clara(tag_Clara: 92002)
        cardContent.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(indicator.snp.bottom).offset(12)
            make.right.equalToSuperview().offset(-18)
            make.width.height.equalTo(34)
        }

        let heroView = UIView()
        heroView.backgroundColor = ColorConfig_Clara.springMistBlue_Clara.withAlphaComponent(0.16)
        heroView.layer.cornerRadius = 20
        cardContent.addSubview(heroView)
        heroView.snp.makeConstraints { make in
            make.top.equalTo(indicator.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(18)
            make.right.equalTo(closeButton.snp.left).offset(-12)
        }

        let heroIconWrap = UIView()
        heroIconWrap.backgroundColor = .white
        heroIconWrap.layer.cornerRadius = 20
        heroView.addSubview(heroIconWrap)
        heroIconWrap.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(14)
            make.width.height.equalTo(40)
        }

        let heroIcon = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
        heroIcon.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        heroIcon.contentMode = .scaleAspectFit
        heroIconWrap.addSubview(heroIcon)
        heroIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        let badgeButton = createHalfModalBadgeButton_Clara(
            title_Clara: "Sticker Tips",
            titleColor_Clara: ColorConfig_Clara.primaryGradientStart_Clara,
            backgroundColor_Clara: UIColor.white.withAlphaComponent(0.82)
        )
        heroView.addSubview(badgeButton)
        badgeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(heroIconWrap.snp.right).offset(12)
            make.height.equalTo(28)
        }

        let titleLabel = UILabel()
        titleLabel.text = title_Clara
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        titleLabel.numberOfLines = 2
        heroView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(badgeButton.snp.bottom).offset(10)
            make.left.equalTo(heroIconWrap.snp.right).offset(12)
            make.right.equalToSuperview().offset(-14)
        }

        let heroSubtitleLabel = UILabel()
        heroSubtitleLabel.text = "Quick styling note for today"
        heroSubtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        heroSubtitleLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        heroView.addSubview(heroSubtitleLabel)
        heroSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-16)
        }

        let descWrapView = UIView()
        descWrapView.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        descWrapView.layer.cornerRadius = 18
        cardContent.addSubview(descWrapView)
        descWrapView.snp.makeConstraints { make in
            make.top.equalTo(heroView.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(18)
        }

        let descLabel = UILabel()
        descLabel.text = description_Clara
        descLabel.font = UIFont.systemFont(ofSize: 15)
        descLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        descLabel.numberOfLines = 0
        descLabel.setContentHuggingPriority(.required, for: .vertical)
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descWrapView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        let hintLabel = UILabel()
        hintLabel.text = "Tap outside or use the button below to dismiss."
        hintLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        hintLabel.textColor = ColorConfig_Clara.textPlaceholder_Clara
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        cardContent.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(descWrapView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(24)
        }

        let button = UIButton(type: .system)
        button.setTitle("Got it", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara
        button.layer.cornerRadius = 14
        button.tag = 92002
        button.addTarget(self, action: #selector(closeModalByButton_Clara(_:)), for: .touchUpInside)
        cardContent.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-max(hostView.safeAreaInsets.bottom, 16) - 16)
        }
        presentHalfModal_Clara(overlay_Clara: overlay, card_Clara: card)
    }

    /// 删除当前模态弹层
    private func dismissCustomModalIfNeeded_Clara(tag_Clara: Int) {
        modalHostView_Clara().viewWithTag(tag_Clara)?.removeFromSuperview()
    }

    /// 获取半模态承载视图（优先 TabBar 容器）
    private func modalHostView_Clara() -> UIView {
        if let tabHostView = tabBarController?.view {
            return tabHostView
        }
        return self.view
    }

    /// 创建半模态遮罩视图
    /// 功能：统一半模态遮罩层的透明度、点击关闭行为与 tag 管理
    /// 参数：
    /// - tag_Clara: 遮罩视图唯一标识
    /// 返回值：UIControl - 配置完成的遮罩视图
    private func createHalfModalOverlay_Clara(tag_Clara: Int) -> UIControl {
        let overlay = UIControl()
        overlay.tag = tag_Clara
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        overlay.addTarget(self, action: #selector(dismissAnyModalOverlay_Clara(_:)), for: .touchUpInside)
        return overlay
    }

    /// 创建半模态卡片容器
    /// 功能：构建带阴影的外层容器与真正承载内容的圆角白色卡片
    /// 参数：
    /// - tag_Clara: 外层动画容器的唯一标识
    /// 返回值：(container_Clara: UIView, content_Clara: UIView) - 外层容器与内容容器
    private func createHalfModalCardContainer_Clara(tag_Clara: Int) -> (container_Clara: UIView, content_Clara: UIView) {
        let containerView = UIView()
        containerView.tag = tag_Clara
        containerView.backgroundColor = .clear
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: -6)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 24

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 28
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        containerView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return (containerView, contentView)
    }

    /// 创建半模态顶部拖拽指示器
    /// 功能：统一半模态顶部把手样式，增强可拖拽视觉暗示
    /// 返回值：UIView - 指示器视图
    private func createHalfModalIndicator_Clara() -> UIView {
        let indicator = UIView()
        indicator.backgroundColor = ColorConfig_Clara.textPlaceholder_Clara.withAlphaComponent(0.32)
        indicator.layer.cornerRadius = 2.5
        indicator.snp.makeConstraints { make in
            make.width.equalTo(46)
            make.height.equalTo(5)
        }
        return indicator
    }

    /// 创建半模态头部胶囊标签
    /// 功能：复用半模态中的信息标签，统一色彩、圆角和留白表现
    /// 参数：
    /// - title_Clara: 标签文本
    /// - titleColor_Clara: 文本颜色
    /// - backgroundColor_Clara: 背景颜色
    /// 返回值：UIButton - 仅作展示用途的胶囊标签按钮
    private func createHalfModalBadgeButton_Clara(
        title_Clara: String,
        titleColor_Clara: UIColor,
        backgroundColor_Clara: UIColor
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = false
        button.setTitle(title_Clara, for: .normal)
        button.setTitleColor(titleColor_Clara, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        button.backgroundColor = backgroundColor_Clara
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return button
    }

    /// 创建半模态关闭按钮
    /// 功能：提供统一的关闭按钮样式，避免不同弹层的退出入口割裂
    /// 参数：
    /// - tag_Clara: 对应遮罩层的标识，用于关闭指定弹层
    /// 返回值：UIButton - 配置完成的关闭按钮
    private func createHalfModalCloseButton_Clara(tag_Clara: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag_Clara
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = ColorConfig_Clara.textSecondary_Clara
        button.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(closeModalByButton_Clara(_:)), for: .touchUpInside)
        return button
    }

    /// 创建半模态空态视图
    /// 功能：统一空态图标、标题和说明文案的层级结构
    /// 参数：
    /// - iconName_Clara: SF Symbols 图标名称
    /// - title_Clara: 空态标题
    /// - subtitle_Clara: 空态描述
    /// 返回值：UIView - 完整空态视图
    private func createHalfModalEmptyStateView_Clara(
        iconName_Clara: String,
        title_Clara: String,
        subtitle_Clara: String
    ) -> UIView {
        let containerView = UIView()

        let iconWrapView = UIView()
        iconWrapView.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.10)
        iconWrapView.layer.cornerRadius = 34
        containerView.addSubview(iconWrapView)
        iconWrapView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(68)
        }

        let iconView = UIImageView(image: UIImage(systemName: iconName_Clara))
        iconView.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        iconView.contentMode = .scaleAspectFit
        iconWrapView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        let titleLabel = UILabel()
        titleLabel.text = title_Clara
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = ColorConfig_Clara.textPrimary_Clara
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconWrapView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle_Clara
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = ColorConfig_Clara.textSecondary_Clara
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        containerView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }

        return containerView
    }

    /// 半模态弹窗展示动画（遮罩淡入 + 卡片上滑）
    private func presentHalfModal_Clara(overlay_Clara: UIControl, card_Clara: UIView) {
        overlay_Clara.alpha = 0
        card_Clara.transform = CGAffineTransform(translationX: 0, y: 420)
        UIView.animate(
            withDuration: 0.26,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.3,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            overlay_Clara.alpha = 1
            card_Clara.transform = .identity
        }
    }

    /// 半模态关闭动画（卡片下滑 + 遮罩淡出）
    private func dismissHalfModal_Clara(overlay_Clara: UIControl) {
        let card_Clara = overlay_Clara.viewWithTag(92101) ?? overlay_Clara.viewWithTag(92102)
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
            overlay_Clara.alpha = 0
            card_Clara?.transform = CGAffineTransform(translationX: 0, y: 420)
        } completion: { _ in
            overlay_Clara.removeFromSuperview()
        }
    }
    
    /// 构建色卡色块
    /// - Parameters:
    ///   - color_Clara: 色块颜色
    ///   - name_Clara: 颜色名称
    /// - Returns: 色块视图
    private func buildColorBlock_Clara(color_Clara: UIColor, name_Clara: String) -> UIView {
        let container_Clara = UIView()
        
        let colorView_Clara = UIView()
        colorView_Clara.backgroundColor = color_Clara
        colorView_Clara.layer.cornerRadius = 14
        colorView_Clara.layer.shadowColor = color_Clara.cgColor
        colorView_Clara.layer.shadowOffset = CGSize(width: 0, height: 4)
        colorView_Clara.layer.shadowOpacity = 0.4
        colorView_Clara.layer.shadowRadius = 6
        
        let nameLabel_Clara = UILabel()
        nameLabel_Clara.text = name_Clara
        nameLabel_Clara.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        nameLabel_Clara.textColor = ColorConfig_Clara.textSecondary_Clara
        nameLabel_Clara.textAlignment = .center
        
        container_Clara.addSubview(colorView_Clara)
        container_Clara.addSubview(nameLabel_Clara)
        
        colorView_Clara.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        nameLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(colorView_Clara.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return container_Clara
    }
    
    // MARK: - 花瓣动画
    
    /// 启动 Banner 花瓣粒子动画
    private func startPetalAnimation_Clara() {
        let emitter_Clara = CAEmitterLayer()
        emitter_Clara.emitterPosition = CGPoint(x: bannerView_Clara.bounds.width / 2, y: -10)
        emitter_Clara.emitterShape = .line
        emitter_Clara.emitterSize = CGSize(width: bannerView_Clara.bounds.width, height: 1)
        
        // 花瓣粒子单元
        let cell_Clara = CAEmitterCell()
        cell_Clara.contents = createPetalImage_Clara()?.cgImage
        cell_Clara.birthRate = 3
        cell_Clara.lifetime = 5
        cell_Clara.velocity = 40
        cell_Clara.velocityRange = 20
        cell_Clara.emissionLongitude = .pi
        cell_Clara.emissionRange = .pi / 6
        cell_Clara.spin = 1
        cell_Clara.spinRange = 2
        cell_Clara.scale = 0.04
        cell_Clara.scaleRange = 0.02
        cell_Clara.alphaSpeed = -0.15
        
        // 淡粉和淡白两种花瓣
        let cell2_Clara = CAEmitterCell()
        cell2_Clara.contents = createPetalImage_Clara(isWhite_Clara: true)?.cgImage
        cell2_Clara.birthRate = 2
        cell2_Clara.lifetime = 6
        cell2_Clara.velocity = 30
        cell2_Clara.velocityRange = 15
        cell2_Clara.emissionLongitude = .pi
        cell2_Clara.emissionRange = .pi / 5
        cell2_Clara.spin = 0.8
        cell2_Clara.spinRange = 1.5
        cell2_Clara.scale = 0.03
        cell2_Clara.scaleRange = 0.015
        cell2_Clara.alphaSpeed = -0.1
        
        emitter_Clara.emitterCells = [cell_Clara, cell2_Clara]
        bannerView_Clara.layer.addSublayer(emitter_Clara)
        petalEmitterLayer_Clara = emitter_Clara
    }
    
    /// 生成花瓣图片（用 CoreGraphics 绘制椭圆形花瓣）
    /// - Parameter isWhite_Clara: 是否为白色花瓣，默认粉色
    /// - Returns: 花瓣 UIImage
    private func createPetalImage_Clara(isWhite_Clara: Bool = false) -> UIImage? {
        let size_Clara = CGSize(width: 200, height: 150)
        UIGraphicsBeginImageContextWithOptions(size_Clara, false, 0)
        guard let ctx_Clara = UIGraphicsGetCurrentContext() else { return nil }
        
        let color_Clara = isWhite_Clara
            ? UIColor.white.withAlphaComponent(0.8)
            : ColorConfig_Clara.springCherryBlossom_Clara.withAlphaComponent(0.9)
        ctx_Clara.setFillColor(color_Clara.cgColor)
        
        // 绘制椭圆形花瓣
        let petalPath_Clara = UIBezierPath(
            ovalIn: CGRect(x: 20, y: 30, width: 160, height: 90)
        )
        petalPath_Clara.fill()
        
        let image_Clara = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Clara
    }
    
    // MARK: - 分类选中状态更新
    
    /// 更新分类标签选中状态
    /// - Parameter selected_Clara: 选中的分类枚举
    private func updateCategorySelection_Clara(selected_Clara: StyleCategory_Clara) {
        for btn_Clara in categoryButtons_Clara {
            let isSelected_Clara = btn_Clara.tag == selected_Clara.rawValue
            UIView.animate(withDuration: AnimationConfig_Clara.durationNormal_Clara,
                           delay: 0,
                           usingSpringWithDamping: AnimationConfig_Clara.springDampingLight_Clara,
                           initialSpringVelocity: AnimationConfig_Clara.springVelocity_Clara) {
                var cfg_Clara = btn_Clara.configuration
                cfg_Clara?.baseForegroundColor = isSelected_Clara ? .white : ColorConfig_Clara.textSecondary_Clara
                cfg_Clara?.baseBackgroundColor = isSelected_Clara
                    ? ColorConfig_Clara.springCherryBlossom_Clara
                    : .white
                btn_Clara.configuration = cfg_Clara
                btn_Clara.transform = isSelected_Clara
                    ? CGAffineTransform(scaleX: 1.05, y: 1.05)
                    : .identity
            }
        }
    }
    
    // MARK: - 事件响应

    /// 调色盘色块点击事件
    @objc private func colorChipTapped_Clara(_ sender: UIButton) {
        guard let color = sender.backgroundColor else { return }
        if sender.tag % 2 == 0 {
            selectedPrimaryColor_Clara = color
        } else {
            selectedAccentColor_Clara = color
        }
        refreshPaletteStudio_Clara()
    }

    /// 打开主色任意取色器
    @objc private func pickPrimaryColorTapped_Clara() {
        currentColorTarget_Clara = .primary_clara
        let picker = UIColorPickerViewController()
        picker.selectedColor = selectedPrimaryColor_Clara
        picker.delegate = self
        present(picker, animated: true)
    }

    /// 打开辅色任意取色器
    @objc private func pickAccentColorTapped_Clara() {
        currentColorTarget_Clara = .accent_clara
        let picker = UIColorPickerViewController()
        picker.selectedColor = selectedAccentColor_Clara
        picker.delegate = self
        present(picker, animated: true)
    }

    /// 上传当日穿搭图片
    @objc private func uploadOutfitImageTapped_Clara() {
        MediaPickerHelper_Clara.pickImage_Clara(from: self) { [weak self] image in
            guard let self = self, let image = image else { return }
            self.selectedOutfitImage_Clara = image
            self.outfitPreviewImageView_Clara.image = image
            self.outfitPreviewImageView_Clara.contentMode = .scaleAspectFill
        }
    }

    /// 一键发布当日穿搭（自动附加春日滤镜与天气标签）
    @objc private func oneTapPublishTapped_Clara() {
        guard let selectedImage = selectedOutfitImage_Clara else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please upload an outfit image first.")
            return
        }
        let description = outfitDescriptionView_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !description.isEmpty, description != "Describe your outfit..." else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please add an outfit description.")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateText = formatter.string(from: Date())
        let weatherPool = ["Sunny 18°C", "Cloudy 16°C", "Light Rain 14°C", "Breezy 17°C"]
        let weather = weatherPool[Int.random(in: 0..<weatherPool.count)]
        weatherTagLabel_Clara.text = "Weather: \(weather)"
        let title = "[Daily Outfit] Spring Day \(dateText)"
        let content =
            "Description: \(description)\n" +
            "Spring filter: Bloom Glow\n" +
            "Weather tag: \(weather)\n" +
            "Date: \(dateText)\n" +
            "Palette: \(paletteNamePrimary_Clara.text ?? "") + \(paletteNameAccent_Clara.text ?? "")"
        let mediaPath = saveImageToTemp_Clara(image_Clara: selectedImage)
        TitleViewModel_Clara.shared_Clara.releasePost_Clara(
            title_clara: title,
            content_clara: content,
            media_clara: mediaPath
        )
        outfitDescriptionView_Clara.text = "Describe your outfit..."
        outfitDescriptionView_Clara.textColor = ColorConfig_Clara.textPlaceholder_Clara
        selectedOutfitImage_Clara = nil
        outfitPreviewImageView_Clara.image = UIImage(systemName: "photo")
        outfitPreviewImageView_Clara.contentMode = .center
        refreshOutfitCalendar_Clara()
    }

    /// 日历日期点击事件
    @objc private func calendarDateTapped_Clara(_ sender: UIButton) {
        let day = sender.tag
        let records = dailyOutfitPostsByDay_Clara[day] ?? []
        showDailyOutfitRecordsModal_Clara(day_Clara: day, records_Clara: records)
    }

    /// 贴纸 Tips 点击事件（模态弹窗）
    @objc private func tipStickerTapped_Clara(_ sender: UIButton) {
        let details: [(String, String)] = [
            ("Floral Tip", "Use one floral statement piece with two solid colors to keep the look clean and fresh. Pair small flower prints with simple accessories for better visual balance."),
            ("Sunny Tip", "On bright days, choose breathable layers and a soft color transition from top to bottom. Add light fabric textures to avoid heavy spring styling."),
            ("Fresh Tip", "Green tones work best with neutral shoes and a small pastel bag. Keep makeup and jewelry minimal to let color harmony stand out."),
            ("Layer Tip", "Use a light cardigan or shirt jacket as the middle layer. Keep inner and outer tones within the same temperature range for a polished spring outfit."),
            ("Denim Tip", "Pair washed denim with warm tops and pastel accents. Keep one denim item as the focus and avoid heavy color blocking."),
            ("Sneaker Tip", "Choose clean white or cream sneakers with soft socks. This keeps spring outfits lively but still effortless for daily movement."),
            ("Accessory Tip", "Pick one statement accessory only, such as a scarf or mini bag. Too many focal points can weaken your spring silhouette."),
            ("Rainy Tip", "In light rain, add a water-resistant outer layer and keep colors brighter in your inner outfit for a fresh and uplifting mood.")
        ]
        let item = details[min(sender.tag, details.count - 1)]
        showTipModal_Clara(title_Clara: item.0, description_Clara: item.1)
    }

    /// 点击遮罩关闭弹窗
    @objc private func dismissAnyModalOverlay_Clara(_ sender: UIControl) {
        dismissHalfModal_Clara(overlay_Clara: sender)
    }

    /// 点击按钮关闭弹窗
    @objc private func closeModalByButton_Clara(_ sender: UIButton) {
        if let overlay = modalHostView_Clara().viewWithTag(sender.tag) as? UIControl {
            dismissHalfModal_Clara(overlay_Clara: overlay)
        }
    }

    /// 删除穿搭记录按钮点击
    @objc private func deleteDailyRecordTapped_Clara(_ sender: UIButton) {
        let postId = sender.tag
        let allPosts = TitleViewModel_Clara.shared_Clara.getPosts_Clara()
        guard let targetPost = allPosts.first(where: { $0.titleId_Clara == postId }) else { return }
        let alert = UIAlertController(
            title: "Delete this record?",
            message: "This outfit record will be removed from your calendar.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            TitleViewModel_Clara.shared_Clara.deletePost_Clara(post_clara: targetPost, isDelete_clara: true)
            self?.dismissCustomModalIfNeeded_Clara(tag_Clara: 92001)
            self?.loadData_Clara()
        }))
        present(alert, animated: true)
    }
    
    /// 分类标签点击事件
    /// - Parameter sender: 被点击的分类按钮
    @objc private func categoryButtonTapped_Clara(_ sender: UIButton) {
        guard let category_Clara = StyleCategory_Clara(rawValue: sender.tag) else { return }
        selectedCategory_Clara = category_Clara
        updateCategorySelection_Clara(selected_Clara: category_Clara)
        loadData_Clara()
        
        // 按钮弹性动画
        UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        } completion: { _ in
            UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara,
                           delay: 0,
                           usingSpringWithDamping: AnimationConfig_Clara.springDampingLight_Clara,
                           initialSpringVelocity: AnimationConfig_Clara.springVelocity_Clara) {
                sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        }
    }
    
    /// 特色卡片点击事件
    @objc private func featuredCardTapped_Clara(_ sender: UITapGestureRecognizer) {
        guard let view_Clara = sender.view else { return }
        let postId_Clara = view_Clara.tag
        let post_Clara = filteredPosts_Clara.first { $0.titleId_Clara == postId_Clara }
        guard let post_Clara else { return }
        
        UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
            view_Clara.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        } completion: { _ in
            UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
                view_Clara.transform = .identity
            }
            Navigation_Clara.toTitleDetail_Clara(titleModel_clara: post_Clara)
        }
    }
    
    /// 热门行卡片点击事件
    @objc private func trendingRowTapped_Clara(_ sender: UITapGestureRecognizer) {
        guard let view_Clara = sender.view else { return }
        let postId_Clara = view_Clara.tag
        let allPosts_Clara = TitleViewModel_Clara.shared_Clara.getPosts_Clara()
        guard let post_Clara = allPosts_Clara.first(where: { $0.titleId_Clara == postId_Clara }) else { return }
        
        UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
            view_Clara.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        } completion: { _ in
            UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
                view_Clara.transform = .identity
            }
            Navigation_Clara.toTitleDetail_Clara(titleModel_clara: post_Clara)
        }
    }
    
    /// 点赞按钮点击事件
    /// - Parameter sender: 被点击的点赞按钮（tag 为帖子 ID）
    @objc private func likeButtonTapped_Clara(_ sender: UIButton) {
        let postId_Clara = sender.tag
        let allPosts_Clara = TitleViewModel_Clara.shared_Clara.getPosts_Clara()
        guard let post_Clara = allPosts_Clara.first(where: { $0.titleId_Clara == postId_Clara }) else { return }
        
        // 弹性动画
        UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara) {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            UIView.animate(withDuration: AnimationConfig_Clara.durationFast_Clara,
                           delay: 0,
                           usingSpringWithDamping: AnimationConfig_Clara.springDampingLight_Clara,
                           initialSpringVelocity: AnimationConfig_Clara.springVelocity_Clara) {
                sender.transform = .identity
            }
        }
        
        TitleViewModel_Clara.shared_Clara.likePost_Clara(post_clara: post_Clara)
    }
    
    /// 查看全部特色搭配按钮点击
    @objc private func seeAllFeaturedTapped_Clara() {
        // 触发 Tabbar 切换到发现页（index 1）
        tabBarController?.selectedIndex = 1
    }
}

// MARK: - UIColorPickerViewControllerDelegate

extension Home_Clara {

    /// 实时响应取色器颜色变化
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        switch currentColorTarget_Clara {
        case .primary_clara:
            selectedPrimaryColor_Clara = viewController.selectedColor
        case .accent_clara:
            selectedAccentColor_Clara = viewController.selectedColor
        }
        refreshPaletteStudio_Clara()
    }
}

// MARK: - UITextViewDelegate

extension Home_Clara {

    /// 输入框开始编辑时清理占位文案
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == outfitDescriptionView_Clara else { return }
        if textView.text == "Describe your outfit..." {
            textView.text = ""
            textView.textColor = ColorConfig_Clara.textPrimary_Clara
        }
    }

    /// 输入框结束编辑时恢复占位文案
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == outfitDescriptionView_Clara else { return }
        let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            textView.text = "Describe your outfit..."
            textView.textColor = ColorConfig_Clara.textPlaceholder_Clara
        }
    }
}

// MARK: - UIScrollViewDelegate

extension Home_Clara: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 仅处理特色卡片水平滚动视图的吸附效果
        guard scrollView == featuredScrollView_Clara else { return }
        let cardWidth_Clara: CGFloat = 160 + 14 // 卡片宽度 + 间距
        let offset_Clara = targetContentOffset.pointee.x + scrollView.contentInset.left
        let index_Clara = (offset_Clara / cardWidth_Clara).rounded()
        let targetX_Clara = index_Clara * cardWidth_Clara - scrollView.contentInset.left
        targetContentOffset.pointee = CGPoint(x: max(targetX_Clara, -scrollView.contentInset.left), y: 0)
    }
}
