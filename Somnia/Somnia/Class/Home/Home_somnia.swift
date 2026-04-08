import Foundation
import UIKit
import SnapKit

// MARK: - 首页

/// 首页视图控制器
/// 核心功能：展示四大梦境模块 —— 我的梦境册、近期梦境（含梦痕水印）、梦物图腾收集、噩梦监测
/// 设计理念：薰衣草紫 / 天空蓝渐变 Header + 白色卡片流，强调梦境的神秘感与个人专属性
/// 数据来源：DreamViewModel_Somnia，通知驱动刷新
class Home_Somnia: UIViewController {

    // MARK: - 私有 UI 属性

    private let bgView_Somnia = UIView()

    /// 顶部渐变 Header
    private let headerView_Somnia = UIView()
    private var headerGradient_Somnia: CAGradientLayer?

    /// 品牌 Logo
    private let logoIcon_Somnia   = UIImageView()
    private let brandLabel_Somnia = UILabel()
    private let sloganLabel_Somnia = UILabel()

    /// 右侧消息按钮
    private let messageBt_Somnia = UIButton(type: .custom)

    /// 主滚动视图
    private let scrollView_Somnia    = UIScrollView()
    private let contentView_Somnia   = UIView()

    // MARK: - 每日打卡 Banner（位于「我的梦境册」区域正上方 10pt）

    /// 打卡 Banner 容器（渐变背景卡片）
    private let checkInBanner_Somnia      = UIView()
    private var checkInBannerGrad_Somnia: CAGradientLayer?
    /// 左侧🔥连续天数标签
    private let checkInStreakLabel_Somnia = UILabel()
    /// 中间文案
    private let checkInTitleLabel_Somnia  = UILabel()
    /// 右侧打卡按钮
    private let checkInButton_Somnia      = UIButton(type: .custom)

    // MARK: - 梦境册区域

    private let bookSectionTitle_Somnia  = UILabel()
    private let bookScrollView_Somnia    = UIScrollView()
    private let bookStackView_Somnia     = UIStackView()

    // MARK: - 近期梦境区域

    private let dreamSectionHeader_Somnia = UIView()
    private let dreamSectionTitle_Somnia  = UILabel()
    private let addDreamBt_Somnia         = UIButton(type: .custom)
    private let dreamTableView_Somnia     = UITableView()

    // MARK: - 梦物图腾区域

    /// 梦物图腾标题行（提升为属性，便于整体控制显隐）
    private let totemHeaderView_Somnia    = UIView()
    private let totemSectionTitle_Somnia  = UILabel()
    private let totemScrollView_Somnia    = UIScrollView()
    private let totemStackView_Somnia     = UIStackView()
    private let addTotemBt_Somnia         = UIButton(type: .custom)

    // MARK: - 噩梦监测区域（仅有噩梦时显示）

    private let nightmareCard_Somnia       = UIView()
    private var nightmareGradient_Somnia: CAGradientLayer?
    private let nightmareIcon_Somnia       = UIImageView()
    private let nightmareTitle_Somnia      = UILabel()
    private let nightmareCount_Somnia      = UILabel()
    private let nightmareSuggestion_Somnia = UILabel()

    // MARK: - 底部固定间距（确保 Dream Totems 区域距屏幕底部 100pt）

    /// 内容区末尾固定占位视图，高度 100pt，始终锚定在 contentView 最底部
    private let contentFooter_Somnia = UIView()

    // MARK: - 整页空状态视图（所有数据为空时全覆盖展示）

    /// 整页空状态容器
    private let pageEmptyView_Somnia       = UIView()
    /// 大月亮图标
    private let emptyMoonIcon_Somnia       = UIImageView()
    /// 主标题
    private let emptyTitleLbl_Somnia       = UILabel()
    /// 副标题
    private let emptySubLbl_Somnia         = UILabel()
    /// 创建梦境册按钮（主操作）
    private let emptyCreateBookBt_Somnia   = UIButton(type: .custom)
    private var emptyBookGradLayer_Somnia: CAGradientLayer?
    /// 记录梦境按钮（次操作）
    private let emptyRecordDreamBt_Somnia  = UIButton(type: .custom)

    // 各区域空状态在 reload 时动态创建卡片，不再使用静态标签属性

    // MARK: - 数据

    private var recentRecords_Somnia: [DreamRecordModel_Somnia] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        headerGradient_Somnia?.frame    = headerView_Somnia.bounds
        nightmareGradient_Somnia?.frame = nightmareCard_Somnia.bounds
        emptyBookGradLayer_Somnia?.frame = emptyCreateBookBt_Somnia.bounds
        checkInBannerGrad_Somnia?.frame = checkInBanner_Somnia.bounds
        updateDreamTableHeight_Somnia()
    }

    // MARK: - UI 构建

    /// 初始化所有子视图
    private func setupUI_Somnia() {
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia

        bgView_Somnia.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        view.addSubview(bgView_Somnia)

        // --- Header ---
        headerView_Somnia.clipsToBounds = true
        view.addSubview(headerView_Somnia)

        let grad_Somnia = UIColor.createPrimaryGradientLayer_Somnia(frame_Somnia: .zero)
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        headerGradient_Somnia = grad_Somnia
        headerView_Somnia.layer.cornerRadius = 28
        headerView_Somnia.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        logoIcon_Somnia.image = UIImage(systemName: "moon.stars.fill")
        logoIcon_Somnia.tintColor = .white
        logoIcon_Somnia.contentMode = .scaleAspectFit
        headerView_Somnia.addSubview(logoIcon_Somnia)

        brandLabel_Somnia.text = "Somnia"
        brandLabel_Somnia.font = UIFont(name: "AvenirNext-Bold", size: 26) ?? UIFont.systemFont(ofSize: 26, weight: .bold)
        brandLabel_Somnia.textColor = .white
        headerView_Somnia.addSubview(brandLabel_Somnia)

        sloganLabel_Somnia.text = "Dream · Record · Discover"
        sloganLabel_Somnia.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        sloganLabel_Somnia.textColor = UIColor.white.withAlphaComponent(0.75)
        headerView_Somnia.addSubview(sloganLabel_Somnia)

        messageBt_Somnia.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        messageBt_Somnia.tintColor = .white
        messageBt_Somnia.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        messageBt_Somnia.layer.cornerRadius = 18
        messageBt_Somnia.addTarget(self, action: #selector(messageTapped_Somnia), for: .touchUpInside)
        headerView_Somnia.addSubview(messageBt_Somnia)

        // --- 主滚动视图 ---
        scrollView_Somnia.showsVerticalScrollIndicator = false
        scrollView_Somnia.alwaysBounceVertical = true
        scrollView_Somnia.backgroundColor = .clear
        view.addSubview(scrollView_Somnia)

        contentView_Somnia.backgroundColor = .clear
        scrollView_Somnia.addSubview(contentView_Somnia)

        setupCheckInBanner_Somnia()
        setupBookSection_Somnia()
        setupDreamSection_Somnia()
        setupTotemSection_Somnia()
        setupNightmareCard_Somnia()
        setupContentFooter_Somnia()
        setupPageEmptyView_Somnia()
    }

    /// 构建整页空状态视图：当梦境册和梦境记录均为空时全覆盖展示
    private func setupPageEmptyView_Somnia() {
        pageEmptyView_Somnia.backgroundColor = .clear
        pageEmptyView_Somnia.isHidden = true
        contentView_Somnia.addSubview(pageEmptyView_Somnia)

        // 大月亮图标
        emptyMoonIcon_Somnia.image = UIImage(systemName: "moon.stars.fill")
        emptyMoonIcon_Somnia.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        emptyMoonIcon_Somnia.contentMode = .scaleAspectFit
        pageEmptyView_Somnia.addSubview(emptyMoonIcon_Somnia)

        // 主标题
        emptyTitleLbl_Somnia.text = "Your Dream Journey Awaits"
        emptyTitleLbl_Somnia.font = UIFont(name: "AvenirNext-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
        emptyTitleLbl_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        emptyTitleLbl_Somnia.textAlignment = .center
        pageEmptyView_Somnia.addSubview(emptyTitleLbl_Somnia)

        // 副标题
        emptySubLbl_Somnia.text = "Create a dream book and start\nrecording your nightly adventures"
        emptySubLbl_Somnia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        emptySubLbl_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        emptySubLbl_Somnia.textAlignment = .center
        emptySubLbl_Somnia.numberOfLines = 2
        pageEmptyView_Somnia.addSubview(emptySubLbl_Somnia)

        // 「创建梦境册」主按钮（渐变背景）
        let gradLayer = CAGradientLayer()
        gradLayer.colors = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint   = CGPoint(x: 1, y: 1)
        gradLayer.cornerRadius = 22
        emptyCreateBookBt_Somnia.layer.insertSublayer(gradLayer, at: 0)
        emptyBookGradLayer_Somnia = gradLayer

        emptyCreateBookBt_Somnia.setTitle("Create Dream Book", for: .normal)
        emptyCreateBookBt_Somnia.setTitleColor(.white, for: .normal)
        emptyCreateBookBt_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        emptyCreateBookBt_Somnia.layer.cornerRadius = 22
        emptyCreateBookBt_Somnia.layer.shadowColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.4).cgColor
        emptyCreateBookBt_Somnia.layer.shadowOffset = CGSize(width: 0, height: 6)
        emptyCreateBookBt_Somnia.layer.shadowRadius = 10
        emptyCreateBookBt_Somnia.layer.shadowOpacity = 1
        emptyCreateBookBt_Somnia.addTarget(self, action: #selector(emptyCreateBookTapped_Somnia), for: .touchUpInside)
        pageEmptyView_Somnia.addSubview(emptyCreateBookBt_Somnia)

        // 「记录梦境」次按钮（描边样式）
        emptyRecordDreamBt_Somnia.setTitle("Record a Dream", for: .normal)
        emptyRecordDreamBt_Somnia.setTitleColor(ColorConfig_Somnia.primaryGradientStart_Somnia, for: .normal)
        emptyRecordDreamBt_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        emptyRecordDreamBt_Somnia.layer.cornerRadius = 22
        emptyRecordDreamBt_Somnia.layer.borderWidth = 1.5
        emptyRecordDreamBt_Somnia.layer.borderColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.5).cgColor
        emptyRecordDreamBt_Somnia.backgroundColor = .clear
        emptyRecordDreamBt_Somnia.addTarget(self, action: #selector(emptyRecordDreamTapped_Somnia), for: .touchUpInside)
        pageEmptyView_Somnia.addSubview(emptyRecordDreamBt_Somnia)

        // 约束
        pageEmptyView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.height).offset(-120)
        }
        emptyMoonIcon_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
            make.width.height.equalTo(80)
        }
        emptyTitleLbl_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptyMoonIcon_Somnia.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        emptySubLbl_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLbl_Somnia.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        emptyCreateBookBt_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptySubLbl_Somnia.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.width.equalTo(220)
            make.height.equalTo(48)
        }
        emptyRecordDreamBt_Somnia.snp.makeConstraints { make in
            make.top.equalTo(emptyCreateBookBt_Somnia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(220)
            make.height.equalTo(48)
        }
    }

    /// 初始化内容区底部固定占位视图
    private func setupContentFooter_Somnia() {
        contentFooter_Somnia.backgroundColor = .clear
        contentView_Somnia.addSubview(contentFooter_Somnia)
    }

    // MARK: - 每日打卡 Banner 构建

    /// 构建位于「我的梦境册」正上方 10pt 的全局每日打卡 Banner
    /// Banner 展示连续打卡天数和今日打卡按钮，高度固定 64pt
    private func setupCheckInBanner_Somnia() {
        // 渐变背景（紫→蓝，与主题一致）
        let grad = CAGradientLayer()
        grad.colors = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.cornerRadius = 18
        checkInBanner_Somnia.layer.insertSublayer(grad, at: 0)
        checkInBannerGrad_Somnia = grad

        checkInBanner_Somnia.layer.cornerRadius = 18
        checkInBanner_Somnia.layer.shadowColor  = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.35).cgColor
        checkInBanner_Somnia.layer.shadowOffset = CGSize(width: 0, height: 6)
        checkInBanner_Somnia.layer.shadowRadius = 12
        checkInBanner_Somnia.layer.shadowOpacity = 1
        checkInBanner_Somnia.layer.masksToBounds = false
        contentView_Somnia.addSubview(checkInBanner_Somnia)

        // 🔥 连续天数（左侧）
        checkInStreakLabel_Somnia.font      = UIFont.systemFont(ofSize: 26, weight: .heavy)
        checkInStreakLabel_Somnia.textColor = .white
        checkInStreakLabel_Somnia.textAlignment = .center
        checkInBanner_Somnia.addSubview(checkInStreakLabel_Somnia)

        // 打卡文案（中间）
        checkInTitleLabel_Somnia.font          = UIFont.systemFont(ofSize: 13, weight: .semibold)
        checkInTitleLabel_Somnia.textColor     = UIColor.white.withAlphaComponent(0.9)
        checkInTitleLabel_Somnia.numberOfLines = 2
        checkInBanner_Somnia.addSubview(checkInTitleLabel_Somnia)

        // 打卡按钮（右侧）
        checkInButton_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        checkInButton_Somnia.backgroundColor  = UIColor.white.withAlphaComponent(0.25)
        checkInButton_Somnia.layer.cornerRadius = 14
        checkInButton_Somnia.layer.masksToBounds = true
        checkInButton_Somnia.addTarget(self, action: #selector(checkInTapped_Somnia), for: .touchUpInside)
        checkInBanner_Somnia.addSubview(checkInButton_Somnia)

        // 约束
        checkInStreakLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.equalTo(52)
        }
        checkInTitleLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(checkInStreakLabel_Somnia.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(checkInButton_Somnia.snp.leading).offset(-10)
        }
        checkInButton_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(100)
        }
    }

    // MARK: - 梦境册区域构建

    /// 构建「我的梦境册」横向滚动区域
    private func setupBookSection_Somnia() {
        bookSectionTitle_Somnia.text = "My Dream Books"
        bookSectionTitle_Somnia.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        bookSectionTitle_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        contentView_Somnia.addSubview(bookSectionTitle_Somnia)

        bookScrollView_Somnia.showsHorizontalScrollIndicator = false
        bookScrollView_Somnia.alwaysBounceHorizontal = true
        bookScrollView_Somnia.backgroundColor = .clear
        contentView_Somnia.addSubview(bookScrollView_Somnia)

        bookStackView_Somnia.axis = .horizontal
        bookStackView_Somnia.spacing = 14
        bookStackView_Somnia.alignment = .fill
        bookScrollView_Somnia.addSubview(bookStackView_Somnia)
    }

    // MARK: - 近期梦境区域构建

    /// 构建「近期梦境」列表区域（含新增按钮）
    private func setupDreamSection_Somnia() {
        // 区域 Header（标题 + 添加按钮）
        contentView_Somnia.addSubview(dreamSectionHeader_Somnia)

        dreamSectionTitle_Somnia.text = "Recent Dreams"
        dreamSectionTitle_Somnia.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        dreamSectionTitle_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        dreamSectionHeader_Somnia.addSubview(dreamSectionTitle_Somnia)

        addDreamBt_Somnia.setTitle("+ Record", for: .normal)
        addDreamBt_Somnia.setTitleColor(ColorConfig_Somnia.primaryGradientStart_Somnia, for: .normal)
        addDreamBt_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        addDreamBt_Somnia.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.1)
        addDreamBt_Somnia.layer.cornerRadius = 14
        addDreamBt_Somnia.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        addDreamBt_Somnia.addTarget(self, action: #selector(addDreamTapped_Somnia), for: .touchUpInside)
        dreamSectionHeader_Somnia.addSubview(addDreamBt_Somnia)

        // TableView（嵌入 ScrollView，禁用自身滚动）
        dreamTableView_Somnia.backgroundColor = .clear
        dreamTableView_Somnia.separatorStyle = .none
        dreamTableView_Somnia.isScrollEnabled = false
        dreamTableView_Somnia.register(DreamRecordCell_Somnia.self, forCellReuseIdentifier: DreamRecordCell_Somnia.reuseId_Somnia)
        dreamTableView_Somnia.delegate   = self
        dreamTableView_Somnia.dataSource = self
        dreamTableView_Somnia.estimatedRowHeight = 130
        dreamTableView_Somnia.rowHeight = UITableView.automaticDimension
        contentView_Somnia.addSubview(dreamTableView_Somnia)
    }

    // MARK: - 梦物图腾区域构建

    /// 构建「我的梦物」横向滚动区域（使用类属性 totemHeaderView_Somnia）
    private func setupTotemSection_Somnia() {
        contentView_Somnia.addSubview(totemHeaderView_Somnia)

        totemSectionTitle_Somnia.text = "Dream Totems"
        totemSectionTitle_Somnia.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totemSectionTitle_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        totemHeaderView_Somnia.addSubview(totemSectionTitle_Somnia)

        addTotemBt_Somnia.setTitle("+ Mark", for: .normal)
        addTotemBt_Somnia.setTitleColor(ColorConfig_Somnia.primaryGradientEnd_Somnia, for: .normal)
        addTotemBt_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        addTotemBt_Somnia.backgroundColor = ColorConfig_Somnia.primaryGradientEnd_Somnia.withAlphaComponent(0.1)
        addTotemBt_Somnia.layer.cornerRadius = 14
        addTotemBt_Somnia.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        addTotemBt_Somnia.addTarget(self, action: #selector(addTotemTapped_Somnia), for: .touchUpInside)
        totemHeaderView_Somnia.addSubview(addTotemBt_Somnia)

        totemScrollView_Somnia.showsHorizontalScrollIndicator = false
        totemScrollView_Somnia.alwaysBounceHorizontal = true
        totemScrollView_Somnia.backgroundColor = .clear
        contentView_Somnia.addSubview(totemScrollView_Somnia)

        totemStackView_Somnia.axis = .horizontal
        totemStackView_Somnia.spacing = 16
        totemStackView_Somnia.alignment = .top
        totemScrollView_Somnia.addSubview(totemStackView_Somnia)

        totemHeaderView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(dreamTableView_Somnia.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalTo(34)
        }
        totemSectionTitle_Somnia.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        addTotemBt_Somnia.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
        totemScrollView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(totemHeaderView_Somnia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        totemStackView_Somnia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalToSuperview()
        }
    }

    // MARK: - 噩梦监测卡片构建

    /// 构建噩梦监测信息卡片（仅在有噩梦记录时显示）
    private func setupNightmareCard_Somnia() {
        nightmareCard_Somnia.layer.cornerRadius = 20
        nightmareCard_Somnia.clipsToBounds = true
        nightmareCard_Somnia.layer.shadowColor = UIColor(hexstring_Somnia: "#FC8181").withAlphaComponent(0.2).cgColor
        nightmareCard_Somnia.layer.shadowOffset = CGSize(width: 0, height: 6)
        nightmareCard_Somnia.layer.shadowRadius = 14
        nightmareCard_Somnia.layer.shadowOpacity = 1
        contentView_Somnia.addSubview(nightmareCard_Somnia)

        let nightGrad_Somnia = CAGradientLayer()
        nightGrad_Somnia.colors = [
            UIColor(hexstring_Somnia: "#553C9A").cgColor,
            UIColor(hexstring_Somnia: "#2D3748").cgColor
        ]
        nightGrad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        nightGrad_Somnia.endPoint   = CGPoint(x: 1, y: 1)
        nightmareCard_Somnia.layer.insertSublayer(nightGrad_Somnia, at: 0)
        nightmareGradient_Somnia = nightGrad_Somnia

        nightmareIcon_Somnia.image = UIImage(systemName: "moon.zzz.fill")
        nightmareIcon_Somnia.tintColor = UIColor(hexstring_Somnia: "#FC8181")
        nightmareIcon_Somnia.contentMode = .scaleAspectFit
        nightmareCard_Somnia.addSubview(nightmareIcon_Somnia)

        nightmareTitle_Somnia.text = "Nightmare Alert"
        nightmareTitle_Somnia.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        nightmareTitle_Somnia.textColor = .white
        nightmareCard_Somnia.addSubview(nightmareTitle_Somnia)

        nightmareCount_Somnia.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nightmareCount_Somnia.textColor = UIColor.white.withAlphaComponent(0.75)
        nightmareCard_Somnia.addSubview(nightmareCount_Somnia)

        nightmareSuggestion_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        nightmareSuggestion_Somnia.textColor = UIColor.white.withAlphaComponent(0.88)
        nightmareSuggestion_Somnia.numberOfLines = 0
        nightmareCard_Somnia.addSubview(nightmareSuggestion_Somnia)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 主约束（totemSection / nightmareCard 约束在各自方法内设置）
    private func setupConstraints_Somnia() {
        bgView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // --- Header ---
        headerView_Somnia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(110)
        }
        logoIcon_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-16)
            make.width.height.equalTo(30)
        }
        brandLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(logoIcon_Somnia.snp.trailing).offset(8)
            make.centerY.equalTo(logoIcon_Somnia)
        }
        sloganLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(logoIcon_Somnia.snp.leading)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(14)
        }
        messageBt_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(logoIcon_Somnia)
            make.width.height.equalTo(36)
        }

        // --- 主 ScrollView ---
        scrollView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(headerView_Somnia.snp.bottom).offset(-10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Somnia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }

        // --- 每日打卡 Banner ---
        checkInBanner_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalTo(68)
        }

        // --- 梦境册区域（Banner 下方 10pt）---
        bookSectionTitle_Somnia.snp.makeConstraints { make in
            make.top.equalTo(checkInBanner_Somnia.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(22)
        }
        bookScrollView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(bookSectionTitle_Somnia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(144)
        }
        bookStackView_Somnia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalToSuperview().offset(-8)
        }

        // --- 近期梦境区域 ---
        dreamSectionHeader_Somnia.snp.makeConstraints { make in
            make.top.equalTo(bookScrollView_Somnia.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalTo(34)
        }
        dreamSectionTitle_Somnia.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        addDreamBt_Somnia.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
        dreamTableView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(dreamSectionHeader_Somnia.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(10)
        }

        // --- 噩梦监测卡片（不再锚定 contentView 底部，由 contentFooter 控制最终底距）---
        nightmareCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(totemScrollView_Somnia.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
        }

        // --- 内容区底部固定占位（100pt），确保 Dream Totems 区域距屏幕底部 100pt ---
        contentFooter_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nightmareCard_Somnia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
            make.bottom.equalToSuperview()
        }
        nightmareIcon_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(28)
        }
        nightmareTitle_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(nightmareIcon_Somnia.snp.trailing).offset(10)
            make.centerY.equalTo(nightmareIcon_Somnia)
        }
        nightmareCount_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nightmareIcon_Somnia.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
        }
        nightmareSuggestion_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nightmareCount_Somnia.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-18)
        }
    }

    // MARK: - 数据绑定

    /// 订阅 DreamViewModel 数据变更通知
    private func bindViewModel_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Somnia),
            name: DreamViewModel_Somnia.dreamStateDidChangeNotification_Somnia,
            object: nil
        )
    }

    /// 数据变更回调
    @objc private func onDataChanged_Somnia() {
        loadData_Somnia()
    }

    /// 加载数据并刷新各模块 UI
    private func loadData_Somnia() {
        // 先判断整页状态：全空时展示引导页，否则正常填充各模块
        updatePageState_Somnia()
        reloadCheckInBanner_Somnia()
        reloadBookSection_Somnia()
        reloadDreamSection_Somnia()
        reloadTotemSection_Somnia()
        reloadNightmareCard_Somnia()
        animateEntrance_Somnia()
    }

    /// 各区域均有独立内联空状态卡片，整页遮罩始终关闭，所有 section 保持可见
    private func updatePageState_Somnia() {
        pageEmptyView_Somnia.isHidden = true
    }

    // MARK: - 各模块刷新

    /// 刷新梦境册横向滚动区域
    /// 无梦境册时：展示内嵌「+ New Book」按钮的专属空状态卡片，按钮直接可见无需滚动
    /// 有梦境册时：正常展示书卡列表 + 末尾「新建」卡片
    private func reloadBookSection_Somnia() {
        bookStackView_Somnia.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let books = DreamViewModel_Somnia.shared_Somnia.getAllBooks_Somnia()

        if books.isEmpty {
            let emptyCard = makeBookEmptyCard_Somnia()
            emptyCard.snp.makeConstraints { make in
                make.width.equalTo(view.bounds.width - 44)
                make.height.equalTo(136)
            }
            bookStackView_Somnia.addArrangedSubview(emptyCard)
            return
        }

        for book in books {
            let card = DreamBookCardView_Somnia()
            card.configure_Somnia(book_somnia: book)
            card.snp.makeConstraints { make in
                make.width.equalTo(130)
            }
            card.onTapped_Somnia = { [weak self] tappedBook in
                self?.showBookRecords_Somnia(book_somnia: tappedBook)
            }
            bookStackView_Somnia.addArrangedSubview(card)
        }

        // 有数据时末尾追加「新建」卡片
        let newCard = DreamBookNewCardView_Somnia()
        newCard.snp.makeConstraints { make in
            make.width.equalTo(100)
        }
        newCard.onTapped_Somnia = { [weak self] in
            self?.presentCreateBookSheet_Somnia()
        }
        bookStackView_Somnia.addArrangedSubview(newCard)
    }

    /// 构建梦境册区域专属空状态卡片
    /// 内嵌渐变「＋ New Book」按钮，确保无数据时 CTA 醒目可见，无需横向滚动
    private func makeBookEmptyCard_Somnia() -> UIView {
        let card = UIView()
        card.backgroundColor = ColorConfig_Somnia.cardBackground_Somnia
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 10
        card.layer.shadowOpacity = 1

        // 左侧图标背景圆
        let iconBg = UIView()
        iconBg.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.1)
        iconBg.layer.cornerRadius = 24
        card.addSubview(iconBg)

        let iconView = UIImageView(image: UIImage(systemName: "moon.fill"))
        iconView.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        iconView.contentMode = .scaleAspectFit
        iconBg.addSubview(iconView)

        // 主文案
        let titleLbl = UILabel()
        titleLbl.text = "No dream books yet"
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        card.addSubview(titleLbl)

        // 副文案
        let subLbl = UILabel()
        subLbl.text = "Organize your dream journey\nwith a personal book"
        subLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subLbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        subLbl.numberOfLines = 2
        card.addSubview(subLbl)

        // 渐变「＋ New Book」按钮（右侧，醒目）
        let createBt = UIButton(type: .custom)
        createBt.setTitle("＋  New Book", for: .normal)
        createBt.setTitleColor(.white, for: .normal)
        createBt.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        createBt.layer.cornerRadius = 16
        createBt.layer.masksToBounds = true
        createBt.addTarget(self, action: #selector(bookEmptyCreateTapped_Somnia), for: .touchUpInside)

        // 渐变背景层
        let grad = CAGradientLayer()
        grad.colors = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.cornerRadius = 16
        createBt.layer.insertSublayer(grad, at: 0)
        card.addSubview(createBt)

        // 约束
        iconBg.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleLbl.snp.makeConstraints { make in
            make.leading.equalTo(iconBg.snp.trailing).offset(14)
            make.top.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-14)
        }
        subLbl.snp.makeConstraints { make in
            make.leading.equalTo(titleLbl)
            make.top.equalTo(titleLbl.snp.bottom).offset(5)
            make.trailing.equalToSuperview().offset(-14)
        }
        createBt.snp.makeConstraints { make in
            make.leading.equalTo(titleLbl)
            make.top.equalTo(subLbl.snp.bottom).offset(14)
            make.height.equalTo(32)
            make.width.equalTo(130)
        }

        // 渐变层需在 layout 后更新 frame，延迟到下一 runloop
        DispatchQueue.main.async {
            grad.frame = createBt.bounds
        }

        return card
    }

    /// 刷新近期梦境列表
    /// 无记录时：TableView 不隐藏，固定高度 116pt，通过 backgroundView 展示样式化空状态卡片
    /// 有记录时：清除 backgroundView，高度自适应 contentSize
    private func reloadDreamSection_Somnia() {
        recentRecords_Somnia = DreamViewModel_Somnia.shared_Somnia.getRecentRecords_Somnia(limit_somnia: 5)
        let isEmpty = recentRecords_Somnia.isEmpty

        if isEmpty {
            dreamTableView_Somnia.backgroundView = makeSectionEmptyBgView_Somnia(
                icon_somnia: "moon.zzz.fill",
                title_somnia: "No dreams recorded yet",
                subtitle_somnia: "Tap + Record to begin your journey"
            )
            dreamTableView_Somnia.snp.updateConstraints { make in
                make.height.equalTo(116)
            }
        } else {
            dreamTableView_Somnia.backgroundView = nil
            dreamTableView_Somnia.reloadData()
            updateDreamTableHeight_Somnia()
        }
    }

    /// 刷新梦物图腾横向区域
    /// 无梦物时展示样式化空状态卡片（撑满横向宽度）；有梦物时展示图腾卡片列表
    private func reloadTotemSection_Somnia() {
        totemStackView_Somnia.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let totems = DreamViewModel_Somnia.shared_Somnia.getAllTotems_Somnia()
        if totems.isEmpty {
            let card = makeSectionEmptyCard_Somnia(
                icon_somnia: "sparkles",
                title_somnia: "No dream totems yet",
                subtitle_somnia: "Record dreams to auto-collect your personal totems"
            )
            card.snp.makeConstraints { make in
                make.width.equalTo(view.bounds.width - 44)
                make.height.equalTo(96)
            }
            totemStackView_Somnia.addArrangedSubview(card)
        } else {
            for totem in totems.prefix(10) {
                let cell = DreamTotemCell_Somnia()
                cell.configure_Somnia(totem_somnia: totem)
                cell.snp.makeConstraints { make in
                    make.width.equalTo(80)
                }
                cell.onTapped_Somnia = { [weak self] tappedTotem in
                    self?.showTotemDetail_Somnia(totem_somnia: tappedTotem)
                }
                totemStackView_Somnia.addArrangedSubview(cell)
            }
        }
    }

    /// 刷新噩梦监测卡片（无噩梦时隐藏）
    private func reloadNightmareCard_Somnia() {
        let count = DreamViewModel_Somnia.shared_Somnia.getRecentNightmareCount_Somnia(days_somnia: 7)
        if count == 0 {
            nightmareCard_Somnia.isHidden = true
            return
        }
        nightmareCard_Somnia.isHidden = false
        nightmareCount_Somnia.text = "\(count) nightmare\(count > 1 ? "s" : "") in the past 7 days"
        nightmareSuggestion_Somnia.text = DreamViewModel_Somnia.shared_Somnia.getNightmareSuggestion_Somnia()
    }

    /// 更新 dreamTableView 高度（嵌入式 TableView 自适应）
    private func updateDreamTableHeight_Somnia() {
        dreamTableView_Somnia.layoutIfNeeded()
        let h = dreamTableView_Somnia.contentSize.height
        if h > 0 {
            dreamTableView_Somnia.snp.updateConstraints { make in
                make.height.equalTo(h)
            }
        }
    }

    // MARK: - 空状态卡片构建

    /// 构建用于 UITableView.backgroundView 的空状态容器视图
    /// backgroundView 自动填充 tableView 尺寸，内部用 SnapKit 布局样式卡片
    /// - Parameters:
    ///   - icon_somnia: SF Symbol 名称
    ///   - title_somnia: 主文案
    ///   - subtitle_somnia: 副文案
    /// - Returns: 配置好的容器视图
    private func makeSectionEmptyBgView_Somnia(icon_somnia: String, title_somnia: String, subtitle_somnia: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        let card = makeSectionEmptyCard_Somnia(
            icon_somnia: icon_somnia,
            title_somnia: title_somnia,
            subtitle_somnia: subtitle_somnia
        )
        container.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-8)
        }
        return container
    }

    /// 构建通用空状态卡片视图（白底圆角卡片，含图标 + 主副文案）
    /// - Parameters:
    ///   - icon_somnia: SF Symbol 名称
    ///   - title_somnia: 主文案（加粗）
    ///   - subtitle_somnia: 副文案（常规）
    /// - Returns: 样式化 UIView 卡片
    private func makeSectionEmptyCard_Somnia(icon_somnia: String, title_somnia: String, subtitle_somnia: String) -> UIView {
        let card = UIView()
        card.backgroundColor = ColorConfig_Somnia.cardBackground_Somnia
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 8
        card.layer.shadowOpacity = 1

        let iconBg = UIView()
        iconBg.backgroundColor = ColorConfig_Somnia.primaryGradientStart_Somnia.withAlphaComponent(0.1)
        iconBg.layer.cornerRadius = 22
        card.addSubview(iconBg)

        let iconView = UIImageView(image: UIImage(systemName: icon_somnia))
        iconView.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        iconView.contentMode = .scaleAspectFit
        iconBg.addSubview(iconView)

        let titleLbl = UILabel()
        titleLbl.text = title_somnia
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        card.addSubview(titleLbl)

        let subLbl = UILabel()
        subLbl.text = subtitle_somnia
        subLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subLbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        subLbl.numberOfLines = 0
        card.addSubview(subLbl)

        iconBg.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleLbl.snp.makeConstraints { make in
            make.leading.equalTo(iconBg.snp.trailing).offset(14)
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-16)
        }
        subLbl.snp.makeConstraints { make in
            make.leading.equalTo(titleLbl)
            make.top.equalTo(titleLbl.snp.bottom).offset(5)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        return card
    }

    // MARK: - 入场动画

    private var hasAnimated_Somnia = false

    /// 首次加载时执行级联入场动画
    private func animateEntrance_Somnia() {
        guard !hasAnimated_Somnia else { return }
        hasAnimated_Somnia = true
        bookScrollView_Somnia.animateSlideInFromBottom_Somnia(offset_Somnia: 40, delay_Somnia: 0.1)
        dreamSectionHeader_Somnia.animateFadeIn_Somnia(delay_Somnia: 0.2)
        totemScrollView_Somnia.animateSlideInFromBottom_Somnia(offset_Somnia: 30, delay_Somnia: 0.3)
        nightmareCard_Somnia.animateFadeIn_Somnia(delay_Somnia: 0.4)
    }

    // MARK: - 事件响应

    /// 消息按钮点击 → 通过通知切换到消息列表 Tab（索引 3），不 push 新页面
    @objc private func messageTapped_Somnia() {
        messageBt_Somnia.animatePressDown_Somnia {
            self.messageBt_Somnia.animatePressUp_Somnia()
        }
        NotificationCenter.default.post(
            name: Notification.Name("SwitchToMessage_Somnia"),
            object: nil
        )
    }

    /// 整页空状态「Create Dream Book」按钮点击
    @objc private func emptyCreateBookTapped_Somnia() {
        emptyCreateBookBt_Somnia.animatePressDown_Somnia {
            self.emptyCreateBookBt_Somnia.animatePressUp_Somnia()
        }
        presentCreateBookSheet_Somnia()
    }

    /// 整页空状态「Record a Dream」按钮点击
    @objc private func emptyRecordDreamTapped_Somnia() {
        emptyRecordDreamBt_Somnia.animatePressDown_Somnia {
            self.emptyRecordDreamBt_Somnia.animatePressUp_Somnia()
        }
        presentRecordDreamSheet_Somnia(parentRecord_somnia: nil)
    }

    /// 「+ Record」按钮点击 → 弹出新增梦境表单
    @objc private func addDreamTapped_Somnia() {
        addDreamBt_Somnia.animatePulse_Somnia()
        presentRecordDreamSheet_Somnia(parentRecord_somnia: nil)
    }

    /// 「+ Mark」梦物按钮点击 → 弹出添加梦物表单
    @objc private func addTotemTapped_Somnia() {
        addTotemBt_Somnia.animatePulse_Somnia()
        presentAddTotemAlert_Somnia()
    }

    // MARK: - 新增梦境 Sheet

    /// 弹出「记录新梦境」输入弹窗
    /// - Parameter parentRecord_somnia: 续梦时传入源记录，nil 表示新记录
    private func presentRecordDreamSheet_Somnia(parentRecord_somnia: DreamRecordModel_Somnia?) {
        let books = DreamViewModel_Somnia.shared_Somnia.getAllBooks_Somnia()
        guard !books.isEmpty else {
            showToast_Somnia(message_somnia: "Please create a Dream Book first!")
            return
        }

        let title = parentRecord_somnia == nil ? "Record New Dream" : "Continue This Dream"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Describe your dream..."
        }
        alert.addTextField { tf in
            tf.placeholder = "Emotion keyword (e.g. freedom, fear)"
        }
        alert.addTextField { tf in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            tf.text = formatter.string(from: Date())
            tf.placeholder = "Sleep time (HH:mm)"
        }
        alert.addTextField { tf in
            tf.placeholder = "Dream totems, separated by commas"
        }

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let content   = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
            let emotion   = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces) ?? "平静"
            let sleepTime = alert.textFields?[2].text?.trimmingCharacters(in: .whitespaces) ?? "23:00"
            let tagsRaw   = alert.textFields?[3].text?.trimmingCharacters(in: .whitespaces) ?? ""
            let tags      = tagsRaw.isEmpty ? [] : tagsRaw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard !content.isEmpty else { return }

            DreamViewModel_Somnia.shared_Somnia.addRecord_Somnia(
                bookId_somnia: books[0].bookId_Somnia,
                content_somnia: content,
                sleepTime_somnia: sleepTime,
                emotionKeyword_somnia: emotion,
                isNightmare_somnia: false,
                isDontDream_somnia: false,
                totemTags_somnia: tags as [String],
                parentRecordId_somnia: parentRecord_somnia?.recordId_Somnia
            )
        }))

        // 额外操作：标记噩梦 / 不想再梦
        alert.addAction(UIAlertAction(title: "Save as Nightmare 😱", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            let content   = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
            let emotion   = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces) ?? "恐惧"
            let sleepTime = alert.textFields?[2].text?.trimmingCharacters(in: .whitespaces) ?? "23:00"
            let tagsRaw   = alert.textFields?[3].text?.trimmingCharacters(in: .whitespaces) ?? ""
            let tags      = tagsRaw.isEmpty ? [] : tagsRaw.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard !content.isEmpty else { return }

            DreamViewModel_Somnia.shared_Somnia.addRecord_Somnia(
                bookId_somnia: books[0].bookId_Somnia,
                content_somnia: content,
                sleepTime_somnia: sleepTime,
                emotionKeyword_somnia: emotion,
                isNightmare_somnia: true,
                isDontDream_somnia: true,
                totemTags_somnia: tags as [String],
                parentRecordId_somnia: parentRecord_somnia?.recordId_Somnia
            )
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - 新建梦境册 Sheet

    /// 空状态卡片内「＋ New Book」按钮的 @objc 入口，直接复用创建弹窗逻辑
    @objc private func bookEmptyCreateTapped_Somnia() {
        presentCreateBookSheet_Somnia()
    }

    /// 每日打卡按钮点击
    /// 调用 ViewModel 记录全局打卡，成功后刷新 Banner 并展示 Toast
    @objc private func checkInTapped_Somnia() {
        let success = DreamViewModel_Somnia.shared_Somnia.checkInToday_Somnia()
        reloadCheckInBanner_Somnia()
        if success {
            let streak = DreamViewModel_Somnia.shared_Somnia.getDailyCheckInStreak_Somnia()
            let msg = streak > 1
                ? "🔥 \(streak) days streak! Keep dreaming!"
                : "✓ Dream check-in recorded!"
            showToast_Somnia(message_somnia: msg)
        }
    }

    /// 刷新打卡 Banner 显示内容（连续天数 + 按钮状态）
    func reloadCheckInBanner_Somnia() {
        let vm     = DreamViewModel_Somnia.shared_Somnia
        let streak = vm.getDailyCheckInStreak_Somnia()
        let done   = vm.isDailyCheckedInToday_Somnia()

        // 🔥 天数或「0」
        checkInStreakLabel_Somnia.text = streak > 0 ? "🔥\(streak)" : "🔥0"

        // 中间文案
        if done {
            checkInTitleLabel_Somnia.text = "Today's check-in done!\nKeep the streak going"
        } else {
            let streakHint = streak > 0 ? "\(streak)-day streak · " : ""
            checkInTitleLabel_Somnia.text = "\(streakHint)Check in for today's\ndream journal"
        }

        // 按钮状态
        if done {
            checkInButton_Somnia.setTitle("✓  Done", for: .normal)
            checkInButton_Somnia.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            checkInButton_Somnia.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            checkInButton_Somnia.isUserInteractionEnabled = false
        } else {
            checkInButton_Somnia.setTitle("Check In", for: .normal)
            checkInButton_Somnia.backgroundColor = UIColor.white.withAlphaComponent(0.28)
            checkInButton_Somnia.setTitleColor(.white, for: .normal)
            checkInButton_Somnia.isUserInteractionEnabled = true
        }
    }

    /// 弹出「新建梦境册」输入弹窗
    private func presentCreateBookSheet_Somnia() {
        let alert = UIAlertController(title: "Create Dream Book", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Book name (e.g. Healing Dreams)"
        }

        // 图标与颜色选项（简化：固定几种主题）
        let presets: [(String, String, String)] = [
            ("sparkles", "#B794F6", "✨ Inspiration"),
            ("heart.fill", "#FBB6CE", "💖 Healing"),
            ("moon.fill", "#90CDF4", "🌙 Midnight"),
            ("leaf.fill", "#68D391", "🌿 Nature"),
            ("flame.fill", "#FED7AA", "🔥 Adventure"),
        ]

        for preset in presets {
            alert.addAction(UIAlertAction(title: preset.2, style: .default, handler: { [weak self] _ in
                let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
                guard !name.isEmpty else { return }
                DreamViewModel_Somnia.shared_Somnia.createBook_Somnia(
                    title_somnia: name,
                    icon_somnia: preset.0,
                    colorHex_somnia: preset.1
                )
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - 添加梦物 Alert

    /// 弹出「标记梦物」输入弹窗
    private func presentAddTotemAlert_Somnia() {
        let alert = UIAlertController(title: "Mark Dream Totem", message: "What appears in your dreams?", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "Name (e.g. White Cat)" }
        alert.addTextField { tf in tf.placeholder = "Emoji icon (e.g. 🐱)" }

        let types: [(DreamTotemType_Somnia, String)] = [
            (.person_Somnia, "Person 👤"),
            (.animal_Somnia, "Animal 🐾"),
            (.object_Somnia, "Object ✨"),
            (.scene_Somnia,  "Scene 🏞️"),
        ]
        for (type, label) in types {
            alert.addAction(UIAlertAction(title: label, style: .default, handler: { [weak self] _ in
                let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces) ?? ""
                let icon = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces) ?? "✨"
                guard !name.isEmpty else { return }
                DreamViewModel_Somnia.shared_Somnia.addTotem_Somnia(
                    name_somnia: name,
                    type_somnia: type,
                    icon_somnia: icon.isEmpty ? "✨" : icon
                )
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - 跳转/展示交互

    /// 展示梦境册下的记录（通过 Toast 简要提示，完整列表可扩展为详情页）
    private func showBookRecords_Somnia(book_somnia: DreamBookModel_Somnia) {
        showToast_Somnia(message_somnia: "\(book_somnia.bookTitle_Somnia)：\(book_somnia.dreamCount_Somnia) dreams collected")
    }

    /// 展示梦物详情 Toast
    private func showTotemDetail_Somnia(totem_somnia: DreamTotemModel_Somnia) {
        let typeMap: [DreamTotemType_Somnia: String] = [
            .person_Somnia: "Person",
            .animal_Somnia: "Animal",
            .object_Somnia: "Object",
            .scene_Somnia:  "Scene",
        ]
        let type = typeMap[totem_somnia.type_Somnia] ?? "Unknown"
        showToast_Somnia(message_somnia: "\(totem_somnia.icon_Somnia) \(totem_somnia.name_Somnia) · \(type) · ×\(totem_somnia.appearCount_Somnia) times")
    }

    // MARK: - Toast 提示

    /// 显示轻量 Toast 提示
    /// - Parameter message_somnia: 提示文字
    private func showToast_Somnia(message_somnia: String) {
        let toast = UILabel()
        toast.text = message_somnia
        toast.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        toast.textColor = .white
        toast.backgroundColor = ColorConfig_Somnia.textPrimary_Somnia.withAlphaComponent(0.88)
        toast.textAlignment = .center
        toast.numberOfLines = 2
        toast.layer.cornerRadius = 14
        toast.clipsToBounds = true
        toast.alpha = 0

        view.addSubview(toast)
        toast.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }

        UIView.animate(withDuration: 0.3, animations: { toast.alpha = 1 }, completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 1.8, options: [], animations: {
                toast.alpha = 0
            }, completion: { _ in
                toast.removeFromSuperview()
            })
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDelegate & DataSource（近期梦境列表）

extension Home_Somnia: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentRecords_Somnia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DreamRecordCell_Somnia.reuseId_Somnia,
            for: indexPath
        ) as? DreamRecordCell_Somnia else {
            return UITableViewCell()
        }
        let record = recentRecords_Somnia[indexPath.row]
        cell.configure_Somnia(record_somnia: record)

        // 续梦回调：弹出续梦输入弹窗
        cell.onContinueDream_Somnia = { [weak self] sourceRecord in
            self?.presentRecordDreamSheet_Somnia(parentRecord_somnia: sourceRecord)
        }

        // 分段入场动画
        let delay = Double(indexPath.row) * AnimationConfig_Somnia.delayShort_Somnia
        cell.alpha = 0
        UIView.animate(
            withDuration: AnimationConfig_Somnia.durationNormal_Somnia,
            delay: delay,
            options: [.curveEaseOut],
            animations: { cell.alpha = 1 }
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateDreamTableHeight_Somnia()
    }
}
