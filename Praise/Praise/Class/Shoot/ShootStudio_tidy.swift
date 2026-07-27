import Foundation
import UIKit
import SnapKit

// MARK: - 拍摄工具箱主工具页

/// 拍摄工具箱主工具页
/// 核心作用：整合"多模板构图网格 + 拍摄参数记忆 + 快门参数模拟器 + 胶片滤镜组 + 渐变滤镜"六项能力，
///           基于相册选图叠加预览，替代真实相机取景
/// 设计思路：
///   顶部选图/预览区叠加构图网格；底部四个工具分栏（Grid/Filter/Gradient/Exposure）
///   切换不同参数调节面板；所有当前参数组合可通过"Save Preset"一键保存，
///   或通过"Presets"按钮打开历史预设列表一键还原（拍摄参数记忆闭环）。
/// 关键属性/方法：
///   - currentGridType_Tidy / currentGridOpacity_Tidy：当前构图网格状态
///   - currentFilterPresetId_Tidy / currentGradientConfig_Tidy：当前滤镜/渐变状态
///   - refreshPreview_Tidy：根据当前滤镜与渐变配置重新渲染预览图
///   - applyPreset_Tidy：从已保存预设中一键还原全部参数
class ShootStudio_Tidy: UIViewController {

    /// 工具分栏类型
    private enum ToolTab_Tidy: Int, CaseIterable {
        case grid_tidy = 0
        case filter_tidy
        case gradient_tidy
        case exposure_tidy

        var title_Tidy: String {
            switch self {
            case .grid_tidy:     return "Grid"
            case .filter_tidy:   return "Filter"
            case .gradient_tidy: return "Gradient"
            case .exposure_tidy: return "Exposure"
            }
        }
        var iconName_Tidy: String {
            switch self {
            case .grid_tidy:     return "grid"
            case .filter_tidy:   return "camera.filters"
            case .gradient_tidy: return "circle.lefthalf.filled"
            case .exposure_tidy: return "camera.aperture"
            }
        }
    }

    // MARK: - 状态数据

    /// 原始选取的图片（用于滤镜/渐变重新渲染，不叠加任何效果）
    private var originalImage_Tidy: UIImage?
    /// 当前构图网格类型
    private var currentGridType_Tidy: GridTemplateType_Tidy = .ruleOfThirds_tidy
    /// 当前构图网格透明度
    private var currentGridOpacity_Tidy: Float = 0.85
    /// 当前应用的胶片滤镜预设 ID
    private var currentFilterPresetId_Tidy: String?
    /// 当前应用的渐变滤镜配置
    private var currentGradientConfig_Tidy: GradientFilterConfig_Tidy?
    /// 当前选中的工具分栏
    private var currentTool_Tidy: ToolTab_Tidy = .grid_tidy
    /// 图像处理任务代际标记，避免异步渲染结果乱序覆盖
    private var renderGeneration_Tidy = 0

    // MARK: - 顶部导航

    private let backButton_Tidy = BackButton_Tidy()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Composition Studio"
        lb.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lb.textColor = .white
        return lb
    }()
    /// "Presets" 入口按钮（图标 + 文案，取代纯图标以提升可发现性）
    private let presetsButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        var config_tidy = UIButton.Configuration.plain()
        config_tidy.image = UIImage(systemName: "list.bullet.rectangle.portrait",
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config_tidy.title = "Presets"
        config_tidy.imagePadding = 5
        config_tidy.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12)
        config_tidy.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return a
        }
        btn.configuration = config_tidy
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        btn.layer.cornerRadius = 16
        return btn
    }()
    /// 已保存预设数量徽章（悬浮在 presetsButton_Tidy 右上角，数量为 0 时隐藏）
    private let presetsBadge_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.backgroundColor = ColorConfig_Tidy.tidyWarm_Tidy
        lb.layer.cornerRadius = 8
        lb.clipsToBounds = true
        lb.isHidden = true
        return lb
    }()

    // MARK: - 预览区

    private let previewContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#101318")
        v.clipsToBounds = true
        return v
    }()
    private let imageView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let gridOverlay_Tidy = CompositionGridOverlayView_Tidy()
    private let placeholderView_Tidy = UIView()
    /// 占位图标圆形底衬（增加层次感，替代直接悬浮的裸图标）
    private let placeholderIconBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 48
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        return v
    }()
    private let placeholderIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.on.rectangle.angled",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .light))
        iv.tintColor = UIColor.white.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let placeholderTitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "No Photo Selected"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()
    private let placeholderSubtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Pick a photo to preview grids, filters & gradients"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.45)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    private let selectPhotoButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Select Photo", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        btn.layer.cornerRadius = 20
        btn.contentEdgeInsets = UIEdgeInsets(top: 11, left: 26, bottom: 11, right: 26)
        return btn
    }()
    private let rePickButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "arrow.triangle.2.circlepath",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
                     for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        btn.layer.cornerRadius = 16
        btn.isHidden = true
        return btn
    }()
    private let processingIndicator_Tidy: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.color = .white
        v.hidesWhenStopped = true
        return v
    }()

    // MARK: - 底部工具分栏

    private let toolBarContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#181C24")
        return v
    }()
    private let toolTabsStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 6
        return sv
    }()
    private var toolTabButtons_Tidy: [UIButton] = []

    /// Save Preset 按钮
    private let savePresetButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Save Preset", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        btn.layer.cornerRadius = 16
        return btn
    }()

    // MARK: - 各工具面板容器

    private let panelContainer_Tidy = UIView()

    // Grid 面板
    private let gridChipsScroll_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    private let gridChipsStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        return sv
    }()
    private let gridOpacitySlider_Tidy = LabeledSliderView_Tidy()
    private var gridChipButtons_Tidy: [UIButton] = []

    // Filter 面板
    private let filterChipsScroll_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    private let filterChipsStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        return sv
    }()
    private var filterChipButtons_Tidy: [UIButton] = []

    // Gradient 面板
    private let gradientTypeSegment_Tidy = UISegmentedControl(items: ["Radial", "Linear"])
    private let gradientModeSegment_Tidy = UISegmentedControl(items: ["Darken Sky", "Brighten Fg"])
    private let gradientEnableSwitch_Tidy: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = ColorConfig_Tidy.tidyMint_Tidy
        return sw
    }()
    private let gradientEnableLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Enable Gradient"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lb.textColor = .white
        return lb
    }()
    /// 渐变类型 + 模式动态预览图标（形状随 Radial/Linear 变化，颜色随 Darken/Brighten 变化）
    private let gradientPreviewIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Tidy.tidyMint_Tidy
        return iv
    }()
    private let gradientIntensitySlider_Tidy = LabeledSliderView_Tidy()

    // Exposure 面板
    private let sceneSegment_Tidy = UISegmentedControl(items: SceneType_Tidy.allCases.map { $0.displayName_Tidy })
    private let exposureCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 14
        return v
    }()
    private let exposureIsoIcon_Tidy = ShootStudio_Tidy.makeExposureIcon_Tidy(systemName_tidy: "dial.low.fill")
    private let exposureShutterIcon_Tidy = ShootStudio_Tidy.makeExposureIcon_Tidy(systemName_tidy: "timer")
    private let exposureApertureIcon_Tidy = ShootStudio_Tidy.makeExposureIcon_Tidy(systemName_tidy: "camera.aperture")
    private let exposureIsoLabel_Tidy = ShootStudio_Tidy.makeExposureValueLabel_Tidy()
    private let exposureShutterLabel_Tidy = ShootStudio_Tidy.makeExposureValueLabel_Tidy()
    private let exposureApertureLabel_Tidy = ShootStudio_Tidy.makeExposureValueLabel_Tidy()
    private let exposureTipLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11.5, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.7)
        lb.numberOfLines = 3
        lb.textAlignment = .center
        return lb
    }()

    /// 静态工厂：创建曝光参数数值标签（ISO/快门/光圈通用样式）
    private static func makeExposureValueLabel_Tidy() -> UILabel {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lb.textColor = ColorConfig_Tidy.tidyMint_Tidy
        lb.textAlignment = .center
        return lb
    }

    /// 静态工厂：创建曝光参数图标（ISO/快门/光圈通用样式）
    private static func makeExposureIcon_Tidy(systemName_tidy: String) -> UIImageView {
        let iv = UIImageView()
        iv.image = UIImage(systemName: systemName_tidy,
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        iv.tintColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.85)
        iv.contentMode = .scaleAspectFit
        return iv
    }

    /// 底部工具条各区域高度常量，用于精确计算 toolBarContainer_Tidy 总高度，避免与安全区底部内边距产生歧义
    private enum ToolBarMetrics_Tidy {
        static let panelTopOffset: CGFloat = 14
        // 面板高度需覆盖内容最高的 Gradient 面板（Enable行 + 两个分段控件 + 强度滑杆 ≈ 156pt），
        // 之前固定 128pt 会导致 Gradient / Exposure 面板内容溢出并与下方 Save Preset 按钮重叠
        static let panelHeight: CGFloat = 170
        static let gapAfterPanel: CGFloat = 10
        static let saveButtonHeight: CGFloat = 32
        static let gapAfterSaveButton: CGFloat = 10
        static let tabsHeight: CGFloat = 52
        static let gapBeforeSafeArea: CGFloat = 4
    }

    /// 从当前 WindowScene 获取真实底部安全区高度（Home 指示条），供计算工具条总高度使用
    private var windowSafeBottom_Tidy: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom }
            .first ?? 34
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Tidy: "#0B0D11")
        // 网格概览层始终展示（即便尚未选图，或在未选图状态下还原预设），不再受"是否已选图"这一状态限制，
        // 这样切换网格类型 / 还原预设时始终有可见的视觉反馈
        setupTopBar_Tidy()
        setupToolBar_Tidy()
        setupPreviewArea_Tidy()
        setupPanels_Tidy()
        switchTool_Tidy(.grid_tidy)
        updateExposureRecommendation_Tidy(scene_tidy: .portrait_tidy)
        setupPresetsNotification_Tidy()
        updatePresetsBadge_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updatePresetsBadge_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gridOverlay_Tidy.frame = previewContainer_Tidy.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Presets 入口徽章

    /// 监听预设数据变更通知，实时刷新右上角入口的数量徽章，并做脉冲动画提示"保存成功后可在此查看"
    private func setupPresetsNotification_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onPresetsChanged_Tidy),
            name: ShootViewModel_Tidy.shootPresetsDidChangeNotification_Tidy, object: nil
        )
    }

    @objc private func onPresetsChanged_Tidy() {
        updatePresetsBadge_Tidy()
        presetsButton_Tidy.animatePulse_Tidy()
    }

    /// 根据当前已保存预设数量更新徽章展示
    private func updatePresetsBadge_Tidy() {
        let count_tidy = ShootViewModel_Tidy.shared_Tidy.getAllPresets_Tidy().count
        presetsBadge_Tidy.isHidden = count_tidy == 0
        presetsBadge_Tidy.text = count_tidy > 99 ? "99+" : "  \(count_tidy)  "
    }

    // MARK: - 顶部导航搭建

    private func setupTopBar_Tidy() {
        view.addSubview(backButton_Tidy)
        view.addSubview(titleLabel_Tidy)
        view.addSubview(presetsButton_Tidy)
        view.addSubview(presetsBadge_Tidy)

        backButton_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.width.height.equalTo(44)
        }
        presetsButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backButton_Tidy)
            make.height.equalTo(32)
        }
        presetsBadge_Tidy.snp.makeConstraints { make in
            make.top.equalTo(presetsButton_Tidy.snp.top).offset(-6)
            make.trailing.equalTo(presetsButton_Tidy.snp.trailing).offset(6)
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(16)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Tidy)
            make.leading.greaterThanOrEqualTo(backButton_Tidy.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(presetsButton_Tidy.snp.leading).offset(-8)
            make.centerX.equalToSuperview()
        }

        backButton_Tidy.onTapped_Tidy = { [weak self] in
            Navigation_Tidy.pop_Tidy(from: self)
        }
        presetsButton_Tidy.addTarget(self, action: #selector(onPresetsTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 预览区搭建

    private func setupPreviewArea_Tidy() {
        view.addSubview(previewContainer_Tidy)
        previewContainer_Tidy.addSubview(imageView_Tidy)
        previewContainer_Tidy.addSubview(gridOverlay_Tidy)
        previewContainer_Tidy.addSubview(placeholderView_Tidy)
        previewContainer_Tidy.addSubview(rePickButton_Tidy)
        previewContainer_Tidy.addSubview(processingIndicator_Tidy)
        placeholderView_Tidy.addSubview(placeholderIconBg_Tidy)
        placeholderIconBg_Tidy.addSubview(placeholderIcon_Tidy)
        placeholderView_Tidy.addSubview(placeholderTitleLabel_Tidy)
        placeholderView_Tidy.addSubview(placeholderSubtitleLabel_Tidy)
        placeholderView_Tidy.addSubview(selectPhotoButton_Tidy)

        previewContainer_Tidy.snp.makeConstraints { make in
            make.top.equalTo(backButton_Tidy.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(toolBarContainer_Tidy.snp.top)
        }
        imageView_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
        // 显式约束 leading/trailing（而非仅 centerX），确保容器自身宽度不产生 Auto Layout 歧义。
        // 若父容器宽度歧义，会被解算为 0 宽度：子视图因自身尺寸约束仍能正确显示在屏幕上，
        // 但父容器的命中测试区域随之退化为 0，导致按钮"看起来能点却点不到"。
        placeholderView_Tidy.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        placeholderIconBg_Tidy.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(96)
        }
        placeholderIcon_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        placeholderTitleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(placeholderIconBg_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        placeholderSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(placeholderTitleLabel_Tidy.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
        selectPhotoButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(placeholderSubtitleLabel_Tidy.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        rePickButton_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }
        processingIndicator_Tidy.snp.makeConstraints { make in make.center.equalToSuperview() }

        selectPhotoButton_Tidy.addTarget(self, action: #selector(onSelectPhotoTapped_Tidy), for: .touchUpInside)
        rePickButton_Tidy.addTarget(self, action: #selector(onSelectPhotoTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 底部工具条搭建

    private func setupToolBar_Tidy() {
        view.addSubview(toolBarContainer_Tidy)
        toolBarContainer_Tidy.addSubview(panelContainer_Tidy)
        toolBarContainer_Tidy.addSubview(savePresetButton_Tidy)
        toolBarContainer_Tidy.addSubview(toolTabsStack_Tidy)

        // 容器总高度按各区域精确累加 + 真实底部安全区计算，避免"固定高度"与"安全区自适应约束"
        // 两套体系互相冲突（前者会把后者的可用空间挤压到只剩几像素，导致底部分栏被压扁裁切）
        let toolBarHeight_tidy = ToolBarMetrics_Tidy.panelTopOffset
            + ToolBarMetrics_Tidy.panelHeight
            + ToolBarMetrics_Tidy.gapAfterPanel
            + ToolBarMetrics_Tidy.saveButtonHeight
            + ToolBarMetrics_Tidy.gapAfterSaveButton
            + ToolBarMetrics_Tidy.tabsHeight
            + ToolBarMetrics_Tidy.gapBeforeSafeArea
            + windowSafeBottom_Tidy

        toolBarContainer_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(toolBarHeight_tidy)
        }
        panelContainer_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(ToolBarMetrics_Tidy.panelTopOffset)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(ToolBarMetrics_Tidy.panelHeight)
        }
        savePresetButton_Tidy.snp.makeConstraints { make in
            make.top.equalTo(panelContainer_Tidy.snp.bottom).offset(ToolBarMetrics_Tidy.gapAfterPanel)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(ToolBarMetrics_Tidy.saveButtonHeight)
        }
        toolTabsStack_Tidy.snp.makeConstraints { make in
            // 仅用 top + 显式 height 两个约束确定尺寸，不再叠加 bottom-to-safeArea 约束，
            // 避免与上方 toolBarHeight_tidy 的精确计算产生冗余冲突
            make.top.equalTo(savePresetButton_Tidy.snp.bottom).offset(ToolBarMetrics_Tidy.gapAfterSaveButton)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(ToolBarMetrics_Tidy.tabsHeight)
        }

        for tab_tidy in ToolTab_Tidy.allCases {
            let btn_tidy = makeToolTabButton_Tidy(tab_tidy: tab_tidy)
            toolTabsStack_Tidy.addArrangedSubview(btn_tidy)
            toolTabButtons_Tidy.append(btn_tidy)
        }
        savePresetButton_Tidy.addTarget(self, action: #selector(onSavePresetTapped_Tidy), for: .touchUpInside)
    }

    /// 创建底部工具分栏按钮（图标 + 文字上下排列）
    private func makeToolTabButton_Tidy(tab_tidy: ToolTab_Tidy) -> UIButton {
        let btn_tidy = UIButton(type: .custom)
        btn_tidy.tag = tab_tidy.rawValue
        var config_tidy = UIButton.Configuration.plain()
        config_tidy.image = UIImage(systemName: tab_tidy.iconName_Tidy,
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        config_tidy.title = tab_tidy.title_Tidy
        config_tidy.imagePlacement = .top
        config_tidy.imagePadding = 4
        config_tidy.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            return a
        }
        btn_tidy.configuration = config_tidy
        btn_tidy.tintColor = UIColor.white.withAlphaComponent(0.4)
        btn_tidy.layer.cornerRadius = 14
        btn_tidy.addTarget(self, action: #selector(onToolTabTapped_Tidy(_:)), for: .touchUpInside)
        return btn_tidy
    }

    // MARK: - 工具面板搭建

    private func setupPanels_Tidy() {
        setupGridPanel_Tidy()
        setupFilterPanel_Tidy()
        setupGradientPanel_Tidy()
        setupExposurePanel_Tidy()
    }

    private func setupGridPanel_Tidy() {
        panelContainer_Tidy.addSubview(gridChipsScroll_Tidy)
        gridChipsScroll_Tidy.addSubview(gridChipsStack_Tidy)
        panelContainer_Tidy.addSubview(gridOpacitySlider_Tidy)

        gridChipsScroll_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        gridChipsStack_Tidy.snp.makeConstraints { make in
            make.edges.equalTo(gridChipsScroll_Tidy.contentLayoutGuide)
            make.height.equalTo(gridChipsScroll_Tidy.frameLayoutGuide)
        }
        gridOpacitySlider_Tidy.snp.makeConstraints { make in
            make.top.equalTo(gridChipsScroll_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
        }
        gridOpacitySlider_Tidy.configure_Tidy(title_tidy: "Opacity", value_tidy: currentGridOpacity_Tidy)
        gridOpacitySlider_Tidy.onValueChanged_Tidy = { [weak self] value_tidy in
            self?.currentGridOpacity_Tidy = value_tidy
            self?.gridOverlay_Tidy.gridOpacity_Tidy = CGFloat(value_tidy)
        }

        for gridType_tidy in GridTemplateType_Tidy.allCases {
            let tag_tidy = GridTemplateType_Tidy.allCases.firstIndex(of: gridType_tidy) ?? 0
            let chip_tidy = makeChipButton_Tidy(
                title_tidy: gridType_tidy.displayName_Tidy,
                iconName_tidy: gridType_tidy.iconName_Tidy,
                tag_tidy: tag_tidy
            )
            chip_tidy.addTarget(self, action: #selector(onGridChipTapped_Tidy(_:)), for: .touchUpInside)
            gridChipsStack_Tidy.addArrangedSubview(chip_tidy)
            gridChipButtons_Tidy.append(chip_tidy)
        }
        updateGridChipSelection_Tidy()
    }

    private func setupFilterPanel_Tidy() {
        panelContainer_Tidy.addSubview(filterChipsScroll_Tidy)
        filterChipsScroll_Tidy.addSubview(filterChipsStack_Tidy)
        filterChipsScroll_Tidy.isHidden = true

        filterChipsScroll_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        filterChipsStack_Tidy.snp.makeConstraints { make in
            make.edges.equalTo(filterChipsScroll_Tidy.contentLayoutGuide)
            make.height.equalTo(filterChipsScroll_Tidy.frameLayoutGuide)
        }

        // "None" 选项：取消当前滤镜
        let noneChip_tidy = makeChipButton_Tidy(title_tidy: "None", iconName_tidy: "circle.slash", tag_tidy: -1)
        noneChip_tidy.addTarget(self, action: #selector(onFilterChipTapped_Tidy(_:)), for: .touchUpInside)
        filterChipsStack_Tidy.addArrangedSubview(noneChip_tidy)
        filterChipButtons_Tidy.append(noneChip_tidy)

        let presets_tidy = ShootViewModel_Tidy.shared_Tidy.getFilmFilterPresets_Tidy()
        for (index_tidy, preset_tidy) in presets_tidy.enumerated() {
            let chip_tidy = makeChipButton_Tidy(
                title_tidy: preset_tidy.name_Tidy, iconName_tidy: "camera.filters", tag_tidy: index_tidy
            )
            chip_tidy.addTarget(self, action: #selector(onFilterChipTapped_Tidy(_:)), for: .touchUpInside)
            filterChipsStack_Tidy.addArrangedSubview(chip_tidy)
            filterChipButtons_Tidy.append(chip_tidy)
        }
        updateFilterChipSelection_Tidy()
    }

    private func setupGradientPanel_Tidy() {
        panelContainer_Tidy.addSubview(gradientPreviewIcon_Tidy)
        panelContainer_Tidy.addSubview(gradientEnableLabel_Tidy)
        panelContainer_Tidy.addSubview(gradientEnableSwitch_Tidy)
        panelContainer_Tidy.addSubview(gradientTypeSegment_Tidy)
        panelContainer_Tidy.addSubview(gradientModeSegment_Tidy)
        panelContainer_Tidy.addSubview(gradientIntensitySlider_Tidy)
        [gradientPreviewIcon_Tidy, gradientEnableLabel_Tidy, gradientEnableSwitch_Tidy, gradientTypeSegment_Tidy,
         gradientModeSegment_Tidy, gradientIntensitySlider_Tidy].forEach { $0.isHidden = true }

        gradientPreviewIcon_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(gradientEnableLabel_Tidy)
            make.width.height.equalTo(16)
        }
        gradientEnableLabel_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(gradientPreviewIcon_Tidy.snp.trailing).offset(6)
        }
        gradientEnableSwitch_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(gradientEnableLabel_Tidy)
            make.trailing.equalToSuperview()
        }
        gradientTypeSegment_Tidy.snp.makeConstraints { make in
            make.top.equalTo(gradientEnableLabel_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        gradientModeSegment_Tidy.snp.makeConstraints { make in
            make.top.equalTo(gradientTypeSegment_Tidy.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        gradientIntensitySlider_Tidy.snp.makeConstraints { make in
            make.top.equalTo(gradientModeSegment_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
        }

        gradientTypeSegment_Tidy.selectedSegmentIndex = 0
        gradientModeSegment_Tidy.selectedSegmentIndex = 0
        gradientIntensitySlider_Tidy.configure_Tidy(title_tidy: "Intensity", value_tidy: 0.6)
        updateGradientPreviewIcon_Tidy()
        [gradientTypeSegment_Tidy, gradientModeSegment_Tidy].forEach { segment_tidy in
            segment_tidy.selectedSegmentTintColor = ColorConfig_Tidy.tidyMint_Tidy
            segment_tidy.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            segment_tidy.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.6)], for: .normal)
            segment_tidy.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        }

        gradientEnableSwitch_Tidy.addTarget(self, action: #selector(onGradientChanged_Tidy), for: .valueChanged)
        gradientTypeSegment_Tidy.addTarget(self, action: #selector(onGradientChanged_Tidy), for: .valueChanged)
        gradientModeSegment_Tidy.addTarget(self, action: #selector(onGradientChanged_Tidy), for: .valueChanged)
        gradientIntensitySlider_Tidy.onValueChanged_Tidy = { [weak self] _ in self?.onGradientChanged_Tidy() }
    }

    private func setupExposurePanel_Tidy() {
        panelContainer_Tidy.addSubview(sceneSegment_Tidy)
        panelContainer_Tidy.addSubview(exposureCard_Tidy)
        exposureCard_Tidy.addSubview(exposureIsoIcon_Tidy)
        exposureCard_Tidy.addSubview(exposureShutterIcon_Tidy)
        exposureCard_Tidy.addSubview(exposureApertureIcon_Tidy)
        exposureCard_Tidy.addSubview(exposureIsoLabel_Tidy)
        exposureCard_Tidy.addSubview(exposureShutterLabel_Tidy)
        exposureCard_Tidy.addSubview(exposureApertureLabel_Tidy)
        exposureCard_Tidy.addSubview(exposureTipLabel_Tidy)
        [sceneSegment_Tidy, exposureCard_Tidy].forEach { $0.isHidden = true }

        sceneSegment_Tidy.selectedSegmentTintColor = ColorConfig_Tidy.tidyMint_Tidy
        sceneSegment_Tidy.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sceneSegment_Tidy.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.6)], for: .normal)
        sceneSegment_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        sceneSegment_Tidy.selectedSegmentIndex = 0

        sceneSegment_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        exposureCard_Tidy.snp.makeConstraints { make in
            make.top.equalTo(sceneSegment_Tidy.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        exposureIsoIcon_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(16)
        }
        exposureIsoLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(exposureIsoIcon_Tidy)
            make.top.equalTo(exposureIsoIcon_Tidy.snp.bottom).offset(4)
        }
        exposureShutterIcon_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(16)
        }
        exposureShutterLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(exposureShutterIcon_Tidy)
            make.top.equalTo(exposureShutterIcon_Tidy.snp.bottom).offset(4)
        }
        exposureApertureIcon_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(16)
        }
        exposureApertureLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalTo(exposureApertureIcon_Tidy)
            make.top.equalTo(exposureApertureIcon_Tidy.snp.bottom).offset(4)
        }
        exposureTipLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(exposureIsoLabel_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }

        sceneSegment_Tidy.addTarget(self, action: #selector(onSceneChanged_Tidy), for: .valueChanged)
    }

    /// 创建统一样式的横向 Chip 选择按钮
    private func makeChipButton_Tidy(title_tidy: String, iconName_tidy: String, tag_tidy: Int) -> UIButton {
        let btn_tidy = UIButton(type: .custom)
        btn_tidy.tag = tag_tidy
        var config_tidy = UIButton.Configuration.plain()
        config_tidy.image = UIImage(systemName: iconName_tidy,
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        config_tidy.title = title_tidy
        config_tidy.imagePadding = 6
        config_tidy.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        config_tidy.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return a
        }
        btn_tidy.configuration = config_tidy
        btn_tidy.tintColor = .white
        btn_tidy.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        btn_tidy.layer.cornerRadius = 16
        return btn_tidy
    }

    // MARK: - 工具分栏切换

    /// 切换底部工具分栏，展示对应参数面板
    /// 参数：
    /// - tool_tidy: 目标工具分栏
    private func switchTool_Tidy(_ tool_tidy: ToolTab_Tidy) {
        currentTool_Tidy = tool_tidy
        for (index_tidy, btn_tidy) in toolTabButtons_Tidy.enumerated() {
            let selected_tidy = index_tidy == tool_tidy.rawValue
            btn_tidy.tintColor = selected_tidy
                ? ColorConfig_Tidy.tidyMint_Tidy
                : UIColor.white.withAlphaComponent(0.4)
            btn_tidy.backgroundColor = selected_tidy
                ? ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.14)
                : .clear
        }
        gridChipsScroll_Tidy.isHidden = tool_tidy != .grid_tidy
        gridOpacitySlider_Tidy.isHidden = tool_tidy != .grid_tidy
        filterChipsScroll_Tidy.isHidden = tool_tidy != .filter_tidy
        [gradientPreviewIcon_Tidy, gradientEnableLabel_Tidy, gradientEnableSwitch_Tidy, gradientTypeSegment_Tidy,
         gradientModeSegment_Tidy, gradientIntensitySlider_Tidy].forEach {
            $0.isHidden = tool_tidy != .gradient_tidy
        }
        [sceneSegment_Tidy, exposureCard_Tidy].forEach { $0.isHidden = tool_tidy != .exposure_tidy }
    }

    // MARK: - 事件响应：顶部导航 / 选图

    @objc private func onPresetsTapped_Tidy() {
        let sheet_tidy = PresetListSheet_Tidy()
        sheet_tidy.onPresetSelected_Tidy = { [weak self] preset_tidy in
            self?.applyPreset_Tidy(preset_tidy)
        }
        if let sheetPC_tidy = sheet_tidy.sheetPresentationController {
            sheetPC_tidy.detents = [.medium()]
            sheetPC_tidy.prefersGrabberVisible = false
            sheetPC_tidy.preferredCornerRadius = 24
        }
        Navigation_Tidy.present_Tidy(viewController: sheet_tidy, from: self)
    }

    @objc private func onSelectPhotoTapped_Tidy() {
        MediaPickerHelper_Tidy.pickImage_Tidy(from: self) { [weak self] image_tidy in
            guard let self, let image_tidy else { return }
            self.originalImage_Tidy = image_tidy
            self.placeholderView_Tidy.isHidden = true
            self.rePickButton_Tidy.isHidden = false
            self.refreshPreview_Tidy()
        }
    }

    // MARK: - 事件响应：网格面板

    @objc private func onGridChipTapped_Tidy(_ sender: UIButton) {
        guard sender.tag >= 0, sender.tag < GridTemplateType_Tidy.allCases.count else { return }
        currentGridType_Tidy = GridTemplateType_Tidy.allCases[sender.tag]
        gridOverlay_Tidy.gridType_Tidy = currentGridType_Tidy
        updateGridChipSelection_Tidy()
        sender.animatePulse_Tidy()
    }

    /// 刷新构图网格 Chip 选中态样式（每种网格类型使用各自主题色，未选中态为低透明度着色，强化类型辨识度）
    private func updateGridChipSelection_Tidy() {
        for (index_tidy, btn_tidy) in gridChipButtons_Tidy.enumerated() {
            let gridType_tidy = GridTemplateType_Tidy.allCases[index_tidy]
            let color_tidy = gridType_tidy.themeColor_Tidy
            let selected_tidy = gridType_tidy == currentGridType_Tidy
            btn_tidy.backgroundColor = selected_tidy ? color_tidy : color_tidy.withAlphaComponent(0.16)
            btn_tidy.tintColor = selected_tidy ? .white : color_tidy
        }
    }

    // MARK: - 事件响应：滤镜面板

    @objc private func onFilterChipTapped_Tidy(_ sender: UIButton) {
        let presets_tidy = ShootViewModel_Tidy.shared_Tidy.getFilmFilterPresets_Tidy()
        currentFilterPresetId_Tidy = sender.tag >= 0 && sender.tag < presets_tidy.count
            ? presets_tidy[sender.tag].id_Tidy : nil
        updateFilterChipSelection_Tidy()
        sender.animatePulse_Tidy()
        refreshPreview_Tidy()
    }

    /// 刷新胶片滤镜 Chip 选中态样式（按滤镜所属分组主题色着色，"None" 保持中性灰白配色）
    private func updateFilterChipSelection_Tidy() {
        let presets_tidy = ShootViewModel_Tidy.shared_Tidy.getFilmFilterPresets_Tidy()
        for (index_tidy, btn_tidy) in filterChipButtons_Tidy.enumerated() {
            guard index_tidy > 0 else {
                // "None" 选项：中性配色，不代表任何胶片分组
                let selected_tidy = currentFilterPresetId_Tidy == nil
                btn_tidy.backgroundColor = selected_tidy ? UIColor.white.withAlphaComponent(0.30) : UIColor.white.withAlphaComponent(0.10)
                btn_tidy.tintColor = .white
                continue
            }
            let preset_tidy = presets_tidy[index_tidy - 1]
            let color_tidy = preset_tidy.group_Tidy.themeColor_Tidy
            let selected_tidy = preset_tidy.id_Tidy == currentFilterPresetId_Tidy
            btn_tidy.backgroundColor = selected_tidy ? color_tidy : color_tidy.withAlphaComponent(0.16)
            btn_tidy.tintColor = selected_tidy ? .white : color_tidy
        }
    }

    // MARK: - 事件响应：渐变面板

    @objc private func onGradientChanged_Tidy() {
        if gradientEnableSwitch_Tidy.isOn {
            currentGradientConfig_Tidy = GradientFilterConfig_Tidy(
                type_Tidy: gradientTypeSegment_Tidy.selectedSegmentIndex == 0 ? .radial_tidy : .linear_tidy,
                mode_Tidy: gradientModeSegment_Tidy.selectedSegmentIndex == 0 ? .darkenSky_tidy : .brightenForeground_tidy,
                intensity_Tidy: gradientIntensitySlider_Tidy.currentValue_Tidy
            )
        } else {
            currentGradientConfig_Tidy = nil
        }
        updateGradientPreviewIcon_Tidy()
        refreshPreview_Tidy()
    }

    /// 根据当前渐变类型 / 模式更新预览图标的形状与配色：
    /// 径向用圆形符号、线性用矩形符号；压暗天空用镜头蓝、提亮前景用暖橙色
    private func updateGradientPreviewIcon_Tidy() {
        let isRadial_tidy = gradientTypeSegment_Tidy.selectedSegmentIndex == 0
        let isDarkenSky_tidy = gradientModeSegment_Tidy.selectedSegmentIndex == 0
        gradientPreviewIcon_Tidy.image = UIImage(
            systemName: isRadial_tidy ? "circle.dashed" : "rectangle.dashed",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        )
        gradientPreviewIcon_Tidy.tintColor = isDarkenSky_tidy
            ? ColorConfig_Tidy.tidyMint_Tidy
            : ColorConfig_Tidy.tidyWarm_Tidy
    }

    // MARK: - 事件响应：曝光面板

    @objc private func onSceneChanged_Tidy() {
        let scene_tidy = SceneType_Tidy.allCases[sceneSegment_Tidy.selectedSegmentIndex]
        updateExposureRecommendation_Tidy(scene_tidy: scene_tidy)
    }

    /// 更新曝光推荐卡片展示内容
    private func updateExposureRecommendation_Tidy(scene_tidy: SceneType_Tidy) {
        let rec_tidy = ShootViewModel_Tidy.shared_Tidy.getExposureRecommendation_Tidy(scene_tidy: scene_tidy)
        [exposureIsoLabel_Tidy, exposureShutterLabel_Tidy, exposureApertureLabel_Tidy].forEach {
            $0.numberOfLines = 2
            $0.textAlignment = .center
        }
        exposureIsoLabel_Tidy.text = "ISO\n\(rec_tidy.iso_Tidy)"
        exposureShutterLabel_Tidy.text = "Shutter\n\(rec_tidy.shutterSpeed_Tidy)"
        exposureApertureLabel_Tidy.text = "Aperture\n\(rec_tidy.aperture_Tidy)"
        exposureTipLabel_Tidy.text = rec_tidy.tip_Tidy
    }

    @objc private func onToolTabTapped_Tidy(_ sender: UIButton) {
        guard let tab_tidy = ToolTab_Tidy(rawValue: sender.tag) else { return }
        switchTool_Tidy(tab_tidy)
        sender.animatePulse_Tidy()
    }

    // MARK: - 预览渲染

    /// 根据当前滤镜与渐变配置重新渲染预览图（异步处理，避免阻塞主线程）
    private func refreshPreview_Tidy() {
        guard let original_tidy = originalImage_Tidy else { return }
        renderGeneration_Tidy += 1
        let generation_tidy = renderGeneration_Tidy
        // 先在主线程（ShootViewModel_Tidy 为 @MainActor）解析出具体预设值，
        // 避免在后台队列闭包中跨线程访问 MainActor 隔离的单例
        let filterPreset_tidy = currentFilterPresetId_Tidy.flatMap {
            ShootViewModel_Tidy.shared_Tidy.getFilmFilterPreset_Tidy(id_tidy: $0)
        }
        let gradientConfig_tidy = currentGradientConfig_Tidy

        processingIndicator_Tidy.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            var result_tidy = original_tidy
            if let preset_tidy = filterPreset_tidy,
               let filtered_tidy = FilmFilterEngine_Tidy.shared_Tidy.applyFilmFilter_Tidy(preset_tidy: preset_tidy, to: result_tidy) {
                result_tidy = filtered_tidy
            }
            if let gradientConfig_tidy,
               let gradientResult_tidy = FilmFilterEngine_Tidy.shared_Tidy.applyGradientFilter_Tidy(config_tidy: gradientConfig_tidy, to: result_tidy) {
                result_tidy = gradientResult_tidy
            }
            DispatchQueue.main.async { [weak self] in
                guard let self, generation_tidy == self.renderGeneration_Tidy else { return }
                self.imageView_Tidy.image = result_tidy
                self.processingIndicator_Tidy.stopAnimating()
            }
        }
    }

    // MARK: - 预设保存与还原

    @objc private func onSavePresetTapped_Tidy() {
        guard originalImage_Tidy != nil else {
            Utils_Tidy.showWarning_Tidy(message_Tidy: "Select a photo before saving a preset.")
            return
        }
        let alert_tidy = UIAlertController(title: "Save Preset", message: "Name this shooting setup", preferredStyle: .alert)
        alert_tidy.addTextField { tf in tf.placeholder = "e.g. Sunset Portrait" }
        alert_tidy.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_tidy.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert_tidy] _ in
            guard let self else { return }
            let name_tidy = alert_tidy?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces)
            let finalName_tidy = (name_tidy?.isEmpty ?? true) ? "Untitled Preset" : (name_tidy ?? "Untitled Preset")
            ShootViewModel_Tidy.shared_Tidy.savePreset_Tidy(
                name_tidy: finalName_tidy,
                gridType_tidy: self.currentGridType_Tidy,
                gridOpacity_tidy: self.currentGridOpacity_Tidy,
                filterPresetId_tidy: self.currentFilterPresetId_Tidy,
                gradientConfig_tidy: self.currentGradientConfig_Tidy,
                image_tidy: self.originalImage_Tidy
            )
        })
        Navigation_Tidy.present_Tidy(viewController: alert_tidy, from: self)
    }

    /// 从预设中还原全部参数（网格类型/透明度/滤镜/渐变/照片）并刷新界面
    /// 参数：
    /// - preset_tidy: 待还原的拍摄预设
    private func applyPreset_Tidy(_ preset_tidy: ShootPreset_Tidy) {
        currentGridType_Tidy = preset_tidy.gridType_Tidy
        currentGridOpacity_Tidy = preset_tidy.gridOpacity_Tidy
        currentFilterPresetId_Tidy = preset_tidy.filterPresetId_Tidy
        currentGradientConfig_Tidy = preset_tidy.gradientConfig_Tidy

        // 若预设保存时关联了照片，优先还原为该照片，让"拍摄参数记忆"真正带回当时的画面，
        // 而不只是网格/滤镜/渐变的参数配置
        if let imageFileName_tidy = preset_tidy.imageFileName_Tidy,
           let restoredImage_tidy = ShootViewModel_Tidy.shared_Tidy.loadPresetImage_Tidy(fileName_tidy: imageFileName_tidy) {
            originalImage_Tidy = restoredImage_tidy
            placeholderView_Tidy.isHidden = true
            rePickButton_Tidy.isHidden = false
        }

        gridOverlay_Tidy.gridType_Tidy = currentGridType_Tidy
        gridOverlay_Tidy.gridOpacity_Tidy = CGFloat(currentGridOpacity_Tidy)
        gridOpacitySlider_Tidy.configure_Tidy(title_tidy: "Opacity", value_tidy: currentGridOpacity_Tidy)
        updateGridChipSelection_Tidy()
        updateFilterChipSelection_Tidy()

        if let gradientConfig_tidy = currentGradientConfig_Tidy {
            gradientEnableSwitch_Tidy.isOn = true
            gradientTypeSegment_Tidy.selectedSegmentIndex = gradientConfig_tidy.type_Tidy == .radial_tidy ? 0 : 1
            gradientModeSegment_Tidy.selectedSegmentIndex = gradientConfig_tidy.mode_Tidy == .darkenSky_tidy ? 0 : 1
            gradientIntensitySlider_Tidy.configure_Tidy(title_tidy: "Intensity", value_tidy: gradientConfig_tidy.intensity_Tidy)
        } else {
            gradientEnableSwitch_Tidy.isOn = false
        }
        updateGradientPreviewIcon_Tidy()

        switchTool_Tidy(.grid_tidy)
        refreshPreview_Tidy()
        Utils_Tidy.showSuccess_Tidy(message_Tidy: "Preset applied 🎯")
    }
}
