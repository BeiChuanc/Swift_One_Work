import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页视图控制器
/// 核心作用：以"桌面趣味摆件"为主题的信息聚合首页，闭环覆盖签到解锁摆件、
///           摆件收藏管理、桌面摆放互动、纪念摆件成长记录与桌面小场景搭建
/// 设计思路：
///   - 顶部问候栏展示当前用户头像与昵称，头像背后叠加柔光光晕，点击头像进入"我的"页面
///   - 页面背景采用淡紫到近白的竖向渐变，并在四周点缀低透明度色块，
///     与"我的桌面""每日签到""摆件图鉴""记忆摆件""桌面场景"五大分区的主题色相互呼应，
///     统一通过 Palette_Orna 集中管理配色，保证视觉层次丰富又不失整体和谐
///   - "我的桌面"卡片以三段式木纹渐变呈现立体光泽的桌面场景，标题旁附带"已摆放/总槽位"徽标，
///     6个槽位可摆放已拥有摆件，摆件带悬浮呼吸动画
///   - "每日签到"卡片使用暖橙到蜜桃粉渐变并叠加装饰性光斑，记录连续签到天数，
///     签到成功随机解锁一件新摆件，形成收藏闭环
///   - "摆件图鉴"以浅蓝青主题卡片承载，标题旁展示"已解锁/总数"进度，横向滚动展示全部摆件，
///     未解锁显示锁定遮罩，已拥有的可一键上桌
///   - "记忆摆件"以浅薄荷绿主题卡片承载，横向预览恋爱纪念日/生日/毕业/旅行/宠物陪伴日与人物信物摆件，
///     纪念日临近时呈现微光提示，点击进入详情记录照片/随笔，随记录增多摆件外观逐步成长
///   - "桌面场景"入口采用紫色渐变徽标，进入自由摆放摆件、手写便签、迷你相框的微型回忆场景编辑器，
///     支持截图保存为纪念明信片
/// 关键属性：
///   - Palette_Orna: 首页统一配色方案，集中定义各分区主题色与公共文字色
///   - deskSlotViews_Orna: 桌面摆件槽位视图数组
///   - catalogItemViews_Orna: 摆件图鉴单元视图数组
/// 关键方法：
///   - refreshAll_Orna: 统一刷新问候信息、桌面摆件、签到状态、图鉴与记忆摆件预览
///   - handleSlotTapped_Orna: 处理桌面槽位点击
///   - handleCatalogItemTapped_Orna: 处理图鉴单元点击（上桌 / 解锁提示）
class Home_Orna: UIViewController {

    // MARK: - 配色方案

    /// 首页统一配色方案
    /// 设计说明：以品牌紫为基调，各分区搭配专属主题色（木质暖棕 / 蜜桃暖橙 / 天蓝青 / 薄荷绿），
    ///          既能让页面在视觉上呈现丰富层次，又通过统一的背景色与文字色保持整体协调
    private enum Palette_Orna {
        static let textPrimary_Orna = "#2D2A3D"
        static let textSecondary_Orna = "#8B87A0"

        static let bgTop_Orna = "#F5F1FF"
        static let bgBottom_Orna = "#FCFAFF"

        static let purple_Orna = "#7B61FF"
        static let purpleLight_Orna = "#B794F6"

        static let warmStart_Orna = "#FFB088"
        static let warmMid_Orna = "#FF9A6C"
        static let warmEnd_Orna = "#FF6B9D"

        static let woodHighlight_Orna = "#F8E8CC"
        static let woodStart_Orna = "#F3DDBB"
        static let woodEnd_Orna = "#C9986B"
        static let woodShadow_Orna = "#C9986B"

        static let tealStart_Orna = "#49C5F1"
        static let tealEnd_Orna = "#3FD9C7"
        static let tealTint_Orna = "#EAF7FF"

        static let mintStart_Orna = "#6FCF97"
        static let mintEnd_Orna = "#3EC6A0"
        static let mintTint_Orna = "#EBFBF4"
    }

    // MARK: - 数据

    /// 桌面槽位数量（与 UserViewModel 保持一致）
    private let slotCount_Orna = 6

    // MARK: - UI · 背景装饰

    /// 页面竖向渐变背景（淡紫 → 近白），比纯色背景更具层次感
    private let pageGradientLayer_Orna = CAGradientLayer()

    /// 右上角装饰色块，呼应品牌紫，固定于视图不随内容滚动
    private let decorBlobTop_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.purple_Orna).withAlphaComponent(0.08)
        v.layer.cornerRadius = 110
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 左下角装饰色块，呼应记忆摆件的薄荷绿主题
    private let decorBlobBottom_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.mintEnd_Orna).withAlphaComponent(0.08)
        v.layer.cornerRadius = 120
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI · 容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 问候栏

    /// 头像背后的柔光光晕，为问候栏增添质感
    private let avatarGlowView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.purple_Orna).withAlphaComponent(0.14)
        v.layer.cornerRadius = 30
        return v
    }()

    private lazy var avatarView_Orna: CurrentUserAvatarView_Orna = {
        let v = CurrentUserAvatarView_Orna()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        v.onTapped_Orna = {
            Navigation_Orna.toMe_Orna()
        }
        return v
    }()

    private let greetingTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textPrimary_Orna)
        return l
    }()

    private let greetingSubtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Welcome back to your little desk world"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textSecondary_Orna)
        return l
    }()

    // MARK: - UI · 我的桌面卡片

    private let deskCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Orna: Palette_Orna.woodShadow_Orna).cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 16
        return v
    }()

    private let deskTitleLabel_Orna: UILabel = Home_Orna.makeSectionTitle_Orna(text: "My Desk", icon: "🪄")

    /// "已摆放 / 总槽位" 徽标背景
    private let deskCountBadgeView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.woodEnd_Orna).withAlphaComponent(0.14)
        v.layer.cornerRadius = 10
        return v
    }()

    private let deskCountLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.woodEnd_Orna)
        return l
    }()

    private let deskSubtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Tap a slot to arrange your ornaments"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textSecondary_Orna)
        return l
    }()

    /// 木纹质感桌面背板
    private let deskSurfaceView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    private var deskGradientLayer_Orna: CAGradientLayer?

    /// 桌面槽位行容器
    private let deskRowsStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 14
        return sv
    }()

    /// 桌面槽位视图集合
    private var deskSlotViews_Orna: [DeskSlotView_Orna] = []

    // MARK: - UI · 每日签到卡片

    private let checkInCardView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private var checkInGradientLayer_Orna: CAGradientLayer?

    /// 装饰性光斑，为签到卡片增添层次（固定尺寸，创建时即可确定圆角）
    private let checkInDecorCircleBig_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 45
        return v
    }()

    private let checkInDecorCircleSmall_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 24
        return v
    }()

    private let checkInIconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "gift.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let checkInTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Daily Check-in"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let checkInStreakLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        return l
    }()

    private let checkInButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 18
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        b.backgroundColor = .white
        return b
    }()

    // MARK: - UI · 摆件图鉴（浅蓝青主题卡片）

    private let collectionCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.tealTint_Orna)
        v.layer.cornerRadius = 24
        return v
    }()

    private let collectionIconBadgeView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.tealStart_Orna).withAlphaComponent(0.18)
        v.layer.cornerRadius = 16
        return v
    }()

    private let collectionIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = UIColor(hexstring_Orna: Palette_Orna.tealEnd_Orna)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let collectionTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Ornament Collection"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textPrimary_Orna)
        return l
    }()

    /// "已解锁 / 总数" 进度提示
    private let collectionCountLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.tealEnd_Orna)
        return l
    }()

    private let collectionScrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let collectionStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 14
        sv.alignment = .top
        return sv
    }()

    // MARK: - UI · 记忆摆件（浅薄荷绿主题卡片）

    private let memoryCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.mintTint_Orna)
        v.layer.cornerRadius = 24
        return v
    }()

    private let memoryIconBadgeView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: Palette_Orna.mintStart_Orna).withAlphaComponent(0.20)
        v.layer.cornerRadius = 16
        return v
    }()

    private let memoryIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "leaf.fill"))
        iv.tintColor = UIColor(hexstring_Orna: Palette_Orna.mintEnd_Orna)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let memoryTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Memory Ornaments"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textPrimary_Orna)
        return l
    }()

    private let memorySeeAllButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        var config_orna = UIButton.Configuration.plain()
        config_orna.title = "See All"
        config_orna.image = UIImage(systemName: "chevron.right")
        config_orna.imagePlacement = .trailing
        config_orna.imagePadding = 3
        config_orna.baseForegroundColor = UIColor(hexstring_Orna: Palette_Orna.mintEnd_Orna)
        config_orna.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        config_orna.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }
        b.configuration = config_orna
        return b
    }()

    private let memoryScrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let memoryStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 14
        sv.alignment = .top
        return sv
    }()

    // MARK: - UI · 桌面场景入口

    private let deskSceneEntryView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Orna: Palette_Orna.purple_Orna).cgColor
        v.layer.shadowOpacity = 0.10
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }()

    private let deskSceneIconBadgeView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    /// 桌面场景徽标紫色渐变（固定 44x44 尺寸，可在创建时直接确定 frame）
    private let deskSceneIconGradientLayer_Orna: CAGradientLayer = {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: Palette_Orna.purple_Orna).cgColor,
            UIColor(hexstring_Orna: Palette_Orna.purpleLight_Orna).cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        return layer_orna
    }()

    private let deskSceneIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "photo.stack.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let deskSceneTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Desk Scenes"
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textPrimary_Orna)
        return l
    }()

    private let deskSceneSubtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Arrange ornaments, notes & photo frames into mini scenes"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textSecondary_Orna)
        l.numberOfLines = 2
        return l
    }()

    private let deskSceneChevronView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor(hexstring_Orna: "#C7C2DB")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        observeStateChanges_Orna()
        refreshAll_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAll_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageGradientLayer_Orna.frame = view.bounds
        deskGradientLayer_Orna?.frame = deskSurfaceView_Orna.bounds
        checkInGradientLayer_Orna?.frame = checkInCardView_Orna.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        setupPageBackground_Orna()

        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        // 问候栏
        contentView_Orna.addSubview(avatarGlowView_Orna)
        contentView_Orna.addSubview(avatarView_Orna)
        contentView_Orna.addSubview(greetingTitleLabel_Orna)
        contentView_Orna.addSubview(greetingSubtitleLabel_Orna)

        // 我的桌面
        contentView_Orna.addSubview(deskCardView_Orna)
        deskCardView_Orna.addSubview(deskTitleLabel_Orna)
        deskCardView_Orna.addSubview(deskCountBadgeView_Orna)
        deskCountBadgeView_Orna.addSubview(deskCountLabel_Orna)
        deskCardView_Orna.addSubview(deskSubtitleLabel_Orna)
        deskCardView_Orna.addSubview(deskSurfaceView_Orna)
        deskSurfaceView_Orna.addSubview(deskRowsStack_Orna)
        setupDeskGradient_Orna()
        buildDeskSlots_Orna()

        // 每日签到
        contentView_Orna.addSubview(checkInCardView_Orna)
        setupCheckInGradient_Orna()
        checkInCardView_Orna.addSubview(checkInDecorCircleBig_Orna)
        checkInCardView_Orna.addSubview(checkInDecorCircleSmall_Orna)
        checkInCardView_Orna.addSubview(checkInIconView_Orna)
        checkInCardView_Orna.addSubview(checkInTitleLabel_Orna)
        checkInCardView_Orna.addSubview(checkInStreakLabel_Orna)
        checkInCardView_Orna.addSubview(checkInButton_Orna)

        // 摆件图鉴
        contentView_Orna.addSubview(collectionCardView_Orna)
        collectionCardView_Orna.addSubview(collectionIconBadgeView_Orna)
        collectionIconBadgeView_Orna.addSubview(collectionIconView_Orna)
        collectionCardView_Orna.addSubview(collectionTitleLabel_Orna)
        collectionCardView_Orna.addSubview(collectionCountLabel_Orna)
        collectionCardView_Orna.addSubview(collectionScrollView_Orna)
        collectionScrollView_Orna.addSubview(collectionStack_Orna)
        buildCollectionItems_Orna()

        // 记忆摆件
        contentView_Orna.addSubview(memoryCardView_Orna)
        memoryCardView_Orna.addSubview(memoryIconBadgeView_Orna)
        memoryIconBadgeView_Orna.addSubview(memoryIconView_Orna)
        memoryCardView_Orna.addSubview(memoryTitleLabel_Orna)
        memoryCardView_Orna.addSubview(memorySeeAllButton_Orna)
        memoryCardView_Orna.addSubview(memoryScrollView_Orna)
        memoryScrollView_Orna.addSubview(memoryStack_Orna)
        buildMemoryOrnamentItems_Orna()

        // 桌面场景入口
        contentView_Orna.addSubview(deskSceneEntryView_Orna)
        deskSceneEntryView_Orna.addSubview(deskSceneIconBadgeView_Orna)
        deskSceneIconBadgeView_Orna.layer.addSublayer(deskSceneIconGradientLayer_Orna)
        deskSceneIconBadgeView_Orna.addSubview(deskSceneIconView_Orna)
        deskSceneEntryView_Orna.addSubview(deskSceneTitleLabel_Orna)
        deskSceneEntryView_Orna.addSubview(deskSceneSubtitleLabel_Orna)
        deskSceneEntryView_Orna.addSubview(deskSceneChevronView_Orna)
    }

    /// 页面背景：竖向渐变叠加两处低透明度色块装饰，营造柔和又有层次的氛围感
    private func setupPageBackground_Orna() {
        pageGradientLayer_Orna.colors = [
            UIColor(hexstring_Orna: Palette_Orna.bgTop_Orna).cgColor,
            UIColor(hexstring_Orna: Palette_Orna.bgBottom_Orna).cgColor
        ]
        pageGradientLayer_Orna.locations = [0, 0.55]
        view.layer.insertSublayer(pageGradientLayer_Orna, at: 0)

        view.addSubview(decorBlobTop_Orna)
        view.addSubview(decorBlobBottom_Orna)
        decorBlobTop_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-40)
            $0.trailing.equalToSuperview().offset(60)
            $0.width.height.equalTo(220)
        }
        decorBlobBottom_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(360)
            $0.leading.equalToSuperview().offset(-100)
            $0.width.height.equalTo(240)
        }
    }

    /// 桌面背板木纹渐变：暖金高光 → 木纹主色 → 深棕木纹，营造立体光泽感
    private func setupDeskGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: Palette_Orna.woodHighlight_Orna).cgColor,
            UIColor(hexstring_Orna: Palette_Orna.woodStart_Orna).cgColor,
            UIColor(hexstring_Orna: Palette_Orna.woodEnd_Orna).cgColor
        ]
        layer_orna.locations = [0, 0.45, 1]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        deskSurfaceView_Orna.layer.insertSublayer(layer_orna, at: 0)
        deskGradientLayer_Orna = layer_orna
    }

    /// 签到卡片暖色渐变：蜜桃橙 → 珊瑚橙 → 玫瑰粉，层次更细腻
    private func setupCheckInGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: Palette_Orna.warmStart_Orna).cgColor,
            UIColor(hexstring_Orna: Palette_Orna.warmMid_Orna).cgColor,
            UIColor(hexstring_Orna: Palette_Orna.warmEnd_Orna).cgColor
        ]
        layer_orna.locations = [0, 0.5, 1]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        checkInCardView_Orna.layer.insertSublayer(layer_orna, at: 0)
        checkInGradientLayer_Orna = layer_orna
    }

    /// 构建 2 行 x 3 列桌面槽位
    private func buildDeskSlots_Orna() {
        deskSlotViews_Orna.removeAll()
        deskRowsStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for row_orna in 0..<2 {
            let rowStack_orna = UIStackView()
            rowStack_orna.axis = .horizontal
            rowStack_orna.distribution = .fillEqually
            rowStack_orna.spacing = 14
            deskRowsStack_Orna.addArrangedSubview(rowStack_orna)

            for col_orna in 0..<3 {
                let index_orna = row_orna * 3 + col_orna
                let slot_orna = DeskSlotView_Orna()
                slot_orna.slotIndex_Orna = index_orna
                slot_orna.onTap_Orna = { [weak self] slotIndex_orna in
                    self?.handleSlotTapped_Orna(slotIndex_orna: slotIndex_orna)
                }
                rowStack_orna.addArrangedSubview(slot_orna)
                deskSlotViews_Orna.append(slot_orna)
            }
        }
    }

    /// 构建摆件图鉴横向单元
    private func buildCollectionItems_Orna() {
        collectionStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let entries_orna = UserViewModel_Orna.shared_Orna.getOrnamentCatalogWithOwnership_Orna()

        for entry_orna in entries_orna {
            let itemView_orna = OrnamentCatalogItemView_Orna()
            itemView_orna.configure_Orna(ornament_orna: entry_orna.ornament_orna, isOwned_orna: entry_orna.isOwned_orna)
            itemView_orna.onTap_Orna = { [weak self] ornament_orna, isOwned_orna in
                self?.handleCatalogItemTapped_Orna(ornament_orna: ornament_orna, isOwned_orna: isOwned_orna)
            }
            collectionStack_Orna.addArrangedSubview(itemView_orna)
        }

        let ownedCount_orna = entries_orna.filter { $0.isOwned_orna }.count
        collectionCountLabel_Orna.text = "\(ownedCount_orna)/\(entries_orna.count) unlocked"
    }

    /// 构建记忆摆件横向预览单元：已创建的摆件卡片 + 末尾"新建"卡片
    private func buildMemoryOrnamentItems_Orna() {
        memoryStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let memoryOrnaments_orna = UserViewModel_Orna.shared_Orna.getMemoryOrnaments_Orna()

        for ornament_orna in memoryOrnaments_orna.prefix(8) {
            let itemView_orna = MemoryOrnamentPreviewCell_Orna()
            itemView_orna.configure_Orna(ornament_orna: ornament_orna)
            itemView_orna.onTap_Orna = { [weak self] in
                self?.handleMemoryOrnamentTapped_Orna(ornament_orna: ornament_orna)
            }
            memoryStack_Orna.addArrangedSubview(itemView_orna)
        }

        let addCell_orna = MemoryOrnamentAddCell_Orna()
        addCell_orna.onTap_Orna = { [weak self] in
            self?.handleCreateMemoryOrnamentTapped_Orna()
        }
        memoryStack_Orna.addArrangedSubview(addCell_orna)
    }

    // MARK: - 约束

    private func setupConstraints_Orna() {
        scrollView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        avatarView_Orna.snp.makeConstraints {
            // 注意：顶部安全区锚点必须取自 contentView_Orna（滚动内容自身），而非 view（控制器根视图）。
            // 若跨越 UIScrollView 边界直接锚定到 view.safeAreaLayoutGuide，Auto Layout 会在每次布局时
            // 将该视图强制拉回相对屏幕的固定位置，导致 scrollView 内容整体无法真正滚动。
            $0.top.equalTo(contentView_Orna.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(48)
        }
        avatarGlowView_Orna.snp.makeConstraints {
            $0.center.equalTo(avatarView_Orna)
            $0.width.height.equalTo(60)
        }
        greetingTitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna)
            $0.leading.equalTo(avatarView_Orna.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-20)
        }
        greetingSubtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(greetingTitleLabel_Orna.snp.bottom).offset(2)
            $0.leading.equalTo(greetingTitleLabel_Orna)
            $0.trailing.equalToSuperview().offset(-20)
        }

        deskCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        deskTitleLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalToSuperview().offset(18)
        }
        deskCountBadgeView_Orna.snp.makeConstraints {
            $0.centerY.equalTo(deskTitleLabel_Orna)
            $0.leading.equalTo(deskTitleLabel_Orna.snp.trailing).offset(8)
            $0.height.equalTo(20)
        }
        deskCountLabel_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }
        deskSubtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(deskTitleLabel_Orna.snp.bottom).offset(2)
            $0.leading.equalTo(deskTitleLabel_Orna)
            $0.trailing.equalToSuperview().offset(-18)
        }
        deskSurfaceView_Orna.snp.makeConstraints {
            $0.top.equalTo(deskSubtitleLabel_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-18)
            $0.height.equalTo(196)
        }
        deskRowsStack_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }

        checkInCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(deskCardView_Orna.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(92)
        }
        checkInDecorCircleBig_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-24)
            $0.trailing.equalToSuperview().offset(20)
            $0.width.height.equalTo(90)
        }
        checkInDecorCircleSmall_Orna.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-46)
            $0.width.height.equalTo(48)
        }
        checkInIconView_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        checkInTitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(checkInIconView_Orna.snp.trailing).offset(14)
            $0.top.equalToSuperview().offset(20)
        }
        checkInStreakLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(checkInTitleLabel_Orna)
            $0.top.equalTo(checkInTitleLabel_Orna.snp.bottom).offset(4)
        }
        checkInButton_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
            $0.width.greaterThanOrEqualTo(96)
        }

        collectionCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(checkInCardView_Orna.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        collectionIconBadgeView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(32)
        }
        collectionIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        collectionTitleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(collectionIconBadgeView_Orna)
            $0.leading.equalTo(collectionIconBadgeView_Orna.snp.trailing).offset(10)
        }
        collectionCountLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(collectionIconBadgeView_Orna)
            $0.trailing.equalToSuperview().offset(-16)
        }
        collectionScrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(collectionIconBadgeView_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(104)
            $0.bottom.equalToSuperview().offset(-16)
        }
        collectionStack_Orna.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        memoryCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(collectionCardView_Orna.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        memoryIconBadgeView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(32)
        }
        memoryIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        memoryTitleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(memoryIconBadgeView_Orna)
            $0.leading.equalTo(memoryIconBadgeView_Orna.snp.trailing).offset(10)
        }
        memorySeeAllButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(memoryIconBadgeView_Orna)
            $0.trailing.equalToSuperview().offset(-16)
        }
        memoryScrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(memoryIconBadgeView_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(110)
            $0.bottom.equalToSuperview().offset(-16)
        }
        memoryStack_Orna.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        deskSceneEntryView_Orna.snp.makeConstraints {
            $0.top.equalTo(memoryCardView_Orna.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(84)
            // 底部预留悬浮导航栏遮挡高度，确保内容可以完全滚动到导航栏上方，不被其遮盖
            $0.bottom.equalToSuperview().offset(-TabBar_Orna.floatingBarClearance_Orna)
        }
        deskSceneIconBadgeView_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        deskSceneIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(22)
        }
        deskSceneChevronView_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        deskSceneTitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(deskSceneIconBadgeView_Orna.snp.trailing).offset(14)
            $0.trailing.equalTo(deskSceneChevronView_Orna.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(14)
        }
        deskSceneSubtitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(deskSceneTitleLabel_Orna)
            $0.trailing.equalTo(deskSceneChevronView_Orna.snp.leading).offset(-8)
            $0.top.equalTo(deskSceneTitleLabel_Orna.snp.bottom).offset(2)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        checkInButton_Orna.addTarget(self, action: #selector(handleCheckInTapped_Orna), for: .touchUpInside)
        memorySeeAllButton_Orna.addTarget(self, action: #selector(handleSeeAllMemoryTapped_Orna), for: .touchUpInside)

        let deskSceneTap_orna = UITapGestureRecognizer(target: self, action: #selector(handleDeskSceneEntryTapped_Orna))
        deskSceneEntryView_Orna.addGestureRecognizer(deskSceneTap_orna)
        deskSceneEntryView_Orna.isUserInteractionEnabled = true
    }

    /// 监听用户状态与帖子状态变化，实时刷新首页展示
    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAll_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAll_Orna),
            name: TitleViewModel_Orna.titleStateDidChangeNotification_Orna,
            object: nil
        )
    }

    // MARK: - 数据刷新

    /// 统一刷新问候信息、桌面摆件、签到状态、摆件图鉴与记忆摆件预览
    @objc private func refreshAll_Orna() {
        let currentUser_orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        let name_orna = (currentUser_orna.userName_Orna?.isEmpty == false) ? currentUser_orna.userName_Orna! : "Wanderer"
        greetingTitleLabel_Orna.text = "Hi, \(name_orna) 👋"

        let streak_orna = UserViewModel_Orna.shared_Orna.getCheckInStreak_Orna()
        greetingSubtitleLabel_Orna.text = streak_orna > 0
            ? "🔥 \(streak_orna)-day streak — your desk is thriving"
            : "Welcome back to your little desk world"

        refreshDesk_Orna()
        refreshCheckIn_Orna()
        buildCollectionItems_Orna()
        buildMemoryOrnamentItems_Orna()
    }

    /// 刷新桌面槽位内容
    private func refreshDesk_Orna() {
        let deskOrnaments_orna = UserViewModel_Orna.shared_Orna.getDeskOrnaments_Orna()
        for (index_orna, slotView_orna) in deskSlotViews_Orna.enumerated() {
            slotView_orna.configure_Orna(ornament_orna: index_orna < deskOrnaments_orna.count ? deskOrnaments_orna[index_orna] : nil)
        }
        let filledCount_orna = deskOrnaments_orna.compactMap { $0 }.count
        deskCountLabel_Orna.text = "\(filledCount_orna)/\(slotCount_Orna)"
    }

    /// 刷新签到卡片状态
    private func refreshCheckIn_Orna() {
        let streak_orna = UserViewModel_Orna.shared_Orna.getCheckInStreak_Orna()
        let checkedIn_orna = UserViewModel_Orna.shared_Orna.hasCheckedInToday_Orna()

        checkInStreakLabel_Orna.text = streak_orna > 0
            ? "🔥 \(streak_orna) day streak — keep it going!"
            : "Check in daily to collect new ornaments"

        let title_orna = checkedIn_orna ? "Checked In" : "Check In"
        checkInButton_Orna.setTitle(title_orna, for: .normal)
        checkInButton_Orna.setTitleColor(UIColor(hexstring_Orna: Palette_Orna.warmEnd_Orna), for: .normal)
        checkInButton_Orna.alpha = checkedIn_orna ? 0.7 : 1.0
        checkInButton_Orna.isEnabled = !checkedIn_orna
        checkInIconView_Orna.image = UIImage(systemName: checkedIn_orna ? "checkmark.seal.fill" : "gift.fill")
    }

    // MARK: - 事件处理

    /// 每日签到按钮点击
    @objc private func handleCheckInTapped_Orna() {
        UIView.animate(withDuration: 0.1, animations: {
            self.checkInButton_Orna.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.15) { self.checkInButton_Orna.transform = .identity }
        }
        UserViewModel_Orna.shared_Orna.checkIn_Orna()
    }

    /// 处理桌面槽位点击：空槽位弹出可摆放摆件选择，已摆放槽位弹出移除确认
    private func handleSlotTapped_Orna(slotIndex_orna: Int) {
        let deskOrnaments_orna = UserViewModel_Orna.shared_Orna.getDeskOrnaments_Orna()
        guard slotIndex_orna >= 0, slotIndex_orna < deskOrnaments_orna.count else { return }

        if let existing_orna = deskOrnaments_orna[slotIndex_orna] {
            showRemoveOrnamentSheet_Orna(slotIndex_orna: slotIndex_orna, ornament_orna: existing_orna)
        } else {
            showPlaceOrnamentSheet_Orna(slotIndex_orna: slotIndex_orna)
        }
    }

    /// 展示移除摆件确认弹窗
    private func showRemoveOrnamentSheet_Orna(slotIndex_orna: Int, ornament_orna: OrnamentModel_Orna) {
        let alert_orna = UIAlertController(title: ornament_orna.ornamentName_Orna, message: "Remove this ornament from your desk?", preferredStyle: .actionSheet)
        alert_orna.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            UserViewModel_Orna.shared_Orna.placeOrnamentOnDesk_Orna(slotIndex_orna: slotIndex_orna, ornamentId_orna: nil)
            self?.refreshDesk_Orna()
        })
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_orna, animated: true)
    }

    /// 展示摆放摆件选择弹窗（仅列出已拥有且未在桌面上的摆件）
    private func showPlaceOrnamentSheet_Orna(slotIndex_orna: Int) {
        let owned_orna = UserViewModel_Orna.shared_Orna.getOwnedOrnaments_Orna()
        let placedIds_orna = Set(UserViewModel_Orna.shared_Orna.getDeskOrnaments_Orna().compactMap { $0?.ornamentId_Orna })
        let available_orna = owned_orna.filter { !placedIds_orna.contains($0.ornamentId_Orna) }

        guard !available_orna.isEmpty else {
            Load_Orna.showInfo_Orna(message_Orna: "Check in daily to collect ornaments for your desk!")
            return
        }

        let alert_orna = UIAlertController(title: "Place an Ornament", message: nil, preferredStyle: .actionSheet)
        for ornament_orna in available_orna {
            alert_orna.addAction(UIAlertAction(title: ornament_orna.ornamentName_Orna, style: .default) { [weak self] _ in
                UserViewModel_Orna.shared_Orna.placeOrnamentOnDesk_Orna(slotIndex_orna: slotIndex_orna, ornamentId_orna: ornament_orna.ornamentId_Orna)
                self?.refreshDesk_Orna()
            })
        }
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_orna, animated: true)
    }

    /// 处理摆件图鉴单元点击：未拥有提示解锁方式，已拥有则自动上桌
    private func handleCatalogItemTapped_Orna(ornament_orna: OrnamentModel_Orna, isOwned_orna: Bool) {
        guard isOwned_orna else {
            Load_Orna.showInfo_Orna(message_Orna: "Check in daily to unlock \(ornament_orna.ornamentName_Orna)!")
            return
        }

        let deskOrnaments_orna = UserViewModel_Orna.shared_Orna.getDeskOrnaments_Orna()
        if deskOrnaments_orna.contains(where: { $0?.ornamentId_Orna == ornament_orna.ornamentId_Orna }) {
            Load_Orna.showInfo_Orna(message_Orna: "\(ornament_orna.ornamentName_Orna) is already on your desk.")
            return
        }
        if let emptySlotIndex_orna = deskOrnaments_orna.firstIndex(where: { $0 == nil }) {
            UserViewModel_Orna.shared_Orna.placeOrnamentOnDesk_Orna(slotIndex_orna: emptySlotIndex_orna, ornamentId_orna: ornament_orna.ornamentId_Orna)
            refreshDesk_Orna()
            Load_Orna.showSuccess_Orna(message_Orna: "\(ornament_orna.ornamentName_Orna) placed on your desk!")
        } else {
            Load_Orna.showWarning_Orna(message_Orna: "Your desk is full. Remove an ornament first.")
        }
    }

    /// 记忆摆件卡片点击：进入摆件详情页查看成长状态与记忆记录
    private func handleMemoryOrnamentTapped_Orna(ornament_orna: MemoryOrnamentModel_Orna) {
        Navigation_Orna.toMemoryOrnamentDetail_Orna(with: ornament_orna)
    }

    /// "新建摆件"卡片点击：弹出记忆摆件创建面板
    private func handleCreateMemoryOrnamentTapped_Orna() {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }
        let sheet_orna = MemoryOrnamentCreateSheet_Orna()
        sheet_orna.onCreated_Orna = { [weak self] in
            self?.buildMemoryOrnamentItems_Orna()
        }
        present(sheet_orna, animated: true)
    }

    /// "查看全部"按钮点击：进入记忆摆件完整列表页
    @objc private func handleSeeAllMemoryTapped_Orna() {
        Navigation_Orna.toMemoryOrnaments_Orna()
    }

    /// 桌面场景入口点击：进入桌面场景列表页
    @objc private func handleDeskSceneEntryTapped_Orna() {
        UIView.animate(withDuration: 0.1, animations: {
            self.deskSceneEntryView_Orna.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.deskSceneEntryView_Orna.transform = .identity }
        }
        Navigation_Orna.toDeskSceneList_Orna()
    }

    // MARK: - 工具方法

    /// 构建统一样式的分区标题（表情符号 + 文字）
    private static func makeSectionTitle_Orna(text: String, icon: String) -> UILabel {
        let l = UILabel()
        l.text = "\(icon) \(text)"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: Palette_Orna.textPrimary_Orna)
        return l
    }
}

// MARK: - 桌面槽位视图

/// 桌面摆件槽位视图
/// 核心作用：呈现单个桌面槽位，空槽位显示虚线占位，摆放摆件后展示图标与名称，并带有悬浮呼吸动画
private class DeskSlotView_Orna: UIView {

    /// 槽位下标
    var slotIndex_Orna: Int = 0

    /// 点击回调（回传槽位下标）
    var onTap_Orna: ((Int) -> Void)?

    private let borderLayer_Orna = CAShapeLayer()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#5A4632")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let plusLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "+"
        l.font = .systemFont(ofSize: 22, weight: .light)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        layer.cornerRadius = 14
        addSubview(iconView_Orna)
        addSubview(nameLabel_Orna)
        addSubview(plusLabel_Orna)

        iconView_Orna.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(26)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(iconView_Orna.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.bottom.lessThanOrEqualToSuperview().offset(-6)
        }
        plusLabel_Orna.snp.makeConstraints { $0.center.equalToSuperview() }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer_Orna.frame = bounds
        borderLayer_Orna.path = UIBezierPath(roundedRect: bounds, cornerRadius: 14).cgPath
    }

    /// 配置槽位展示内容
    /// 参数：
    /// - ornament_orna: 当前摆放的摆件，nil 表示空槽位
    func configure_Orna(ornament_orna: OrnamentModel_Orna?) {
        layer.removeAnimation(forKey: "floatAnim_Orna")
        transform = .identity

        if let ornament_orna {
            backgroundColor = UIColor(hexstring_Orna: ornament_orna.ornamentColorHex_Orna).withAlphaComponent(0.2)
            borderLayer_Orna.removeFromSuperlayer()
            iconView_Orna.isHidden = false
            nameLabel_Orna.isHidden = false
            plusLabel_Orna.isHidden = true
            iconView_Orna.image = UIImage(systemName: ornament_orna.ornamentIcon_Orna)
            iconView_Orna.tintColor = UIColor(hexstring_Orna: ornament_orna.ornamentColorHex_Orna)
            nameLabel_Orna.text = ornament_orna.ornamentName_Orna
            startFloatAnimation_Orna()
        } else {
            backgroundColor = UIColor.white.withAlphaComponent(0.18)
            iconView_Orna.isHidden = true
            nameLabel_Orna.isHidden = true
            plusLabel_Orna.isHidden = false
            if borderLayer_Orna.superlayer == nil {
                borderLayer_Orna.strokeColor = UIColor.white.withAlphaComponent(0.6).cgColor
                borderLayer_Orna.fillColor = UIColor.clear.cgColor
                borderLayer_Orna.lineDashPattern = [5, 4]
                borderLayer_Orna.lineWidth = 1.5
                layer.addSublayer(borderLayer_Orna)
            }
        }
    }

    /// 悬浮呼吸动画：轻微上下浮动
    private func startFloatAnimation_Orna() {
        let anim_orna = CABasicAnimation(keyPath: "transform.translation.y")
        anim_orna.fromValue = 0
        anim_orna.toValue = -4
        anim_orna.duration = 1.4 + Double(slotIndex_Orna % 3) * 0.2
        anim_orna.autoreverses = true
        anim_orna.repeatCount = .infinity
        anim_orna.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(anim_orna, forKey: "floatAnim_Orna")
    }

    @objc private func handleTap_Orna() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = self.transform.scaledBy(x: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.transform = CGAffineTransform.identity }
        }
        onTap_Orna?(slotIndex_Orna)
    }
}

// MARK: - 摆件图鉴单元视图

/// 摆件图鉴单元视图
/// 核心作用：展示单个摆件的图标、名称与拥有状态，未拥有时呈现锁定遮罩
private class OrnamentCatalogItemView_Orna: UIView {

    /// 点击回调（回传摆件模型与是否已拥有）
    var onTap_Orna: ((OrnamentModel_Orna, Bool) -> Void)?

    private var ornament_Orna: OrnamentModel_Orna?
    private var isOwned_Orna: Bool = false

    private let circleView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 30
        return v
    }()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let lockView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        v.layer.cornerRadius = 30
        return v
    }()

    private let lockIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        addSubview(circleView_Orna)
        circleView_Orna.addSubview(iconView_Orna)
        circleView_Orna.addSubview(lockView_Orna)
        lockView_Orna.addSubview(lockIconView_Orna)
        addSubview(nameLabel_Orna)

        snp.makeConstraints { $0.width.equalTo(68) }
        circleView_Orna.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        iconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        lockView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        lockIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(circleView_Orna.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    /// 配置摆件展示内容
    func configure_Orna(ornament_orna: OrnamentModel_Orna, isOwned_orna: Bool) {
        self.ornament_Orna = ornament_orna
        self.isOwned_Orna = isOwned_orna

        circleView_Orna.backgroundColor = UIColor(hexstring_Orna: ornament_orna.ornamentColorHex_Orna).withAlphaComponent(isOwned_orna ? 0.22 : 0.12)
        iconView_Orna.image = UIImage(systemName: ornament_orna.ornamentIcon_Orna)
        iconView_Orna.tintColor = UIColor(hexstring_Orna: ornament_orna.ornamentColorHex_Orna)
        nameLabel_Orna.text = ornament_orna.ornamentName_Orna
        lockView_Orna.isHidden = isOwned_orna
        alpha = isOwned_orna ? 1.0 : 0.85
    }

    @objc private func handleTap_Orna() {
        guard let ornament_orna = ornament_Orna else { return }
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.transform = .identity }
        }
        onTap_Orna?(ornament_orna, isOwned_Orna)
    }
}

// MARK: - 记忆摆件预览卡片

/// 记忆摆件预览卡片
/// 核心作用：以圆形徽标展示记忆摆件当前成长阶段图标，纪念日临近时叠加微光光环，
///           下方展示名称与副标题（纪念日倒计时 / 人物关系与记忆数）
private class MemoryOrnamentPreviewCell_Orna: UIView {

    /// 点击回调
    var onTap_Orna: (() -> Void)?

    private let glowRingView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 33
        v.layer.borderWidth = 2
        v.isHidden = true
        return v
    }()

    private let circleView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 30
        return v
    }()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let subtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 9, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        addSubview(glowRingView_Orna)
        addSubview(circleView_Orna)
        circleView_Orna.addSubview(iconView_Orna)
        addSubview(nameLabel_Orna)
        addSubview(subtitleLabel_Orna)

        snp.makeConstraints { $0.width.equalTo(72) }
        glowRingView_Orna.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(66)
        }
        circleView_Orna.snp.makeConstraints {
            $0.center.equalTo(glowRingView_Orna)
            $0.width.height.equalTo(60)
        }
        iconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(glowRingView_Orna.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
        subtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(1)
            $0.leading.trailing.equalToSuperview()
        }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    /// 配置摆件展示内容：成长阶段图标、光环提示与副标题
    func configure_Orna(ornament_orna: MemoryOrnamentModel_Orna) {
        let colorHex_orna = ornament_orna.colorHex_Orna
        circleView_Orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(0.2)
        iconView_Orna.image = UIImage(systemName: ornament_orna.currentGrowthIcon_Orna)
        iconView_Orna.tintColor = UIColor(hexstring_Orna: colorHex_orna)
        nameLabel_Orna.text = ornament_orna.customName_Orna

        let isGlowing_orna = ornament_orna.isGlowingNearAnniversary_Orna
        glowRingView_Orna.isHidden = !isGlowing_orna
        glowRingView_Orna.layer.borderColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(0.7).cgColor
        layer.removeAnimation(forKey: "glowPulse_Orna")
        if isGlowing_orna {
            startGlowAnimation_Orna()
        }

        if ornament_orna.kind_Orna.isAnniversaryType_Orna {
            if let days_orna = ornament_orna.daysUntilNextAnniversary_Orna {
                subtitleLabel_Orna.text = days_orna == 0 ? "Today! ✨" : "\(days_orna)d left"
            } else {
                subtitleLabel_Orna.text = ornament_orna.kind_Orna.categoryLabel_Orna
            }
        } else {
            subtitleLabel_Orna.text = "\(ornament_orna.entries_Orna.count) memories"
        }
    }

    /// 光环呼吸动画，提示该摆件正处于纪念日光效窗口期
    private func startGlowAnimation_Orna() {
        let anim_orna = CABasicAnimation(keyPath: "opacity")
        anim_orna.fromValue = 0.35
        anim_orna.toValue = 1.0
        anim_orna.duration = 1.1
        anim_orna.autoreverses = true
        anim_orna.repeatCount = .infinity
        anim_orna.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowRingView_Orna.layer.add(anim_orna, forKey: "glowPulse_Orna")
    }

    @objc private func handleTap_Orna() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.transform = .identity }
        }
        onTap_Orna?()
    }
}

// MARK: - 新建记忆摆件卡片

/// 新建记忆摆件卡片
/// 核心作用：呈现虚线圆形 "+" 占位，点击后弹出创建记忆摆件面板
private class MemoryOrnamentAddCell_Orna: UIView {

    /// 点击回调
    var onTap_Orna: (() -> Void)?

    private let borderLayer_Orna = CAShapeLayer()

    private let plusLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "+"
        l.font = .systemFont(ofSize: 24, weight: .light)
        l.textColor = UIColor(hexstring_Orna: "#7B61FF")
        l.textAlignment = .center
        return l
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "New"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        let circleContainer_orna = UIView()
        addSubview(circleContainer_orna)
        circleContainer_orna.addSubview(plusLabel_Orna)
        addSubview(nameLabel_Orna)

        snp.makeConstraints { $0.width.equalTo(72) }
        circleContainer_orna.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        plusLabel_Orna.snp.makeConstraints { $0.center.equalToSuperview() }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(circleContainer_orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }

        borderLayer_Orna.strokeColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.35).cgColor
        borderLayer_Orna.fillColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.06).cgColor
        borderLayer_Orna.lineDashPattern = [5, 4]
        borderLayer_Orna.lineWidth = 1.5
        circleContainer_orna.layer.addSublayer(borderLayer_Orna)
        circleContainer_orna.tag = 1

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let container_orna = subviews.first(where: { $0.tag == 1 }) else { return }
        borderLayer_Orna.frame = container_orna.bounds
        borderLayer_Orna.path = UIBezierPath(ovalIn: container_orna.bounds).cgPath
    }

    @objc private func handleTap_Orna() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.transform = .identity }
        }
        onTap_Orna?()
    }
}
