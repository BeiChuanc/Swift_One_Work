import Foundation
import UIKit
import SnapKit

// MARK: - 模拟胶片硬件特效页面

/// 模拟胶片硬件特效页面
/// 核心作用：模拟漏光（暖色/冷色/多彩/边缘渐变/随机光斑）、镜头瑕疵（色散/眩光/鬼影/柔化/球面畸变）、
///          底片瑕疵（灰尘/划痕/水痕/霉斑/针孔）、相纸边框（135/120/宝丽来/半格/双反方形/一次性相机白边，
///          支持自定义边框厚度、齿孔、编号水印），全部基于 FilmEffectsEngine_Lumia 本地实时渲染预览
/// 设计思路：
///   - 顶部预览图 + 选取照片入口，与手动调节面板一致的交互习惯
///   - 顶部主分类标签栏切换四大特效类别，下方切换对应的风格选择与强度/边框控制区
///   - 渲染统一通过 DebouncedImageRenderer_Lumia 在后台队列执行，避免拖动滑块时卡顿
/// 关键属性：
///   - params_Lumia: 当前硬件特效参数集合，任意控件变化都会触发重新渲染预览
class FilmHardwareEffectsPage_Lumia: UIViewController {

    // MARK: - 私有属性

    private var sourceImage_Lumia: UIImage?
    private var previewBaseImage_Lumia: UIImage?
    private var params_Lumia = HardwareEffectParams_Lumia()
    private let renderer_Lumia = DebouncedImageRenderer_Lumia<HardwareEffectParams_Lumia>()

    private let accent_Lumia = UIColor(hexstring_Lumia: "#D4654E")
    private let textColor_Lumia = UIColor.white.withAlphaComponent(0.85)

    private let backButton_Lumia = BackButton_Lumia()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Hardware Effects"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let changePhotoButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Lumia.setImage(UIImage(systemName: "photo.badge.plus", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#F6A623")
        return btn_Lumia
    }()

    private let previewContainer_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#0E0A08")
        v_Lumia.layer.cornerRadius = 16
        v_Lumia.clipsToBounds = true
        return v_Lumia
    }()

    private let previewImageView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let previewPlaceholder_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Tap \"Choose Photo\" to preview hardware effects"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.45)
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private lazy var categoryTabBar_Lumia = PillTabBar_Lumia(
        gradientStart_Lumia: UIColor(hexstring_Lumia: "#F6A623"),
        gradientEnd_Lumia: UIColor(hexstring_Lumia: "#D4654E"),
        unselectedTint_Lumia: UIColor(hexstring_Lumia: "#8A7060")
    )

    private let sectionContainer_Lumia = UIView()

    private lazy var lightLeakSection_Lumia = HardwareEffectStyleSection_Lumia(
        accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia,
        styleTitles_Lumia: LightLeakStyle_Lumia.allCases.map { $0.rawValue }, sliderTitle_Lumia: "Intensity"
    )
    private lazy var lensFlawSection_Lumia = HardwareEffectStyleSection_Lumia(
        accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia,
        styleTitles_Lumia: LensFlawStyle_Lumia.allCases.map { $0.rawValue }, sliderTitle_Lumia: "Intensity"
    )
    private lazy var negativeFlawSection_Lumia = HardwareEffectStyleSection_Lumia(
        accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia,
        styleTitles_Lumia: NegativeFlawStyle_Lumia.allCases.map { $0.rawValue }, sliderTitle_Lumia: "Density"
    )
    private lazy var borderSection_Lumia = BorderEffectSection_Lumia(accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#1C1410")
        setupUI_Lumia()
        updatePreview_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(72)
        }

        view.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Lumia)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        view.addSubview(changePhotoButton_Lumia)
        changePhotoButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Lumia)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
        changePhotoButton_Lumia.addTarget(self, action: #selector(handleChoosePhoto_Lumia), for: .touchUpInside)

        view.addSubview(previewContainer_Lumia)
        previewContainer_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(190)
        }
        previewContainer_Lumia.addSubview(previewImageView_Lumia)
        previewImageView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        previewContainer_Lumia.addSubview(previewPlaceholder_Lumia)
        previewPlaceholder_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        previewContainer_Lumia.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChoosePhoto_Lumia)))
        previewContainer_Lumia.isUserInteractionEnabled = true

        view.addSubview(categoryTabBar_Lumia)
        categoryTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(previewContainer_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        categoryTabBar_Lumia.configure_Lumia(titles_Lumia: ["Light Leak", "Lens Flaws", "Negative Flaws", "Border"])
        categoryTabBar_Lumia.onSelected_Lumia = { [weak self] index_Lumia in
            self?.showSection_Lumia(index_Lumia)
        }

        view.addSubview(sectionContainer_Lumia)
        sectionContainer_Lumia.snp.makeConstraints { make in
            make.top.equalTo(categoryTabBar_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        [lightLeakSection_Lumia, lensFlawSection_Lumia, negativeFlawSection_Lumia, borderSection_Lumia].forEach {
            sectionContainer_Lumia.addSubview($0)
            $0.snp.makeConstraints { make in make.edges.equalToSuperview() }
        }

        lightLeakSection_Lumia.onStyleSelected_Lumia = { [weak self] idx_Lumia in
            self?.params_Lumia.lightLeakStyle_Lumia = LightLeakStyle_Lumia.allCases[idx_Lumia]
            self?.updatePreview_Lumia()
        }
        lightLeakSection_Lumia.onIntensityChanged_Lumia = { [weak self] value_Lumia in
            self?.params_Lumia.lightLeakIntensity_Lumia = Double(value_Lumia)
            self?.updatePreview_Lumia()
        }

        lensFlawSection_Lumia.onStyleSelected_Lumia = { [weak self] idx_Lumia in
            self?.params_Lumia.lensFlawStyle_Lumia = LensFlawStyle_Lumia.allCases[idx_Lumia]
            self?.updatePreview_Lumia()
        }
        lensFlawSection_Lumia.onIntensityChanged_Lumia = { [weak self] value_Lumia in
            self?.params_Lumia.lensFlawIntensity_Lumia = Double(value_Lumia)
            self?.updatePreview_Lumia()
        }

        negativeFlawSection_Lumia.onStyleSelected_Lumia = { [weak self] idx_Lumia in
            self?.params_Lumia.negativeFlawStyle_Lumia = NegativeFlawStyle_Lumia.allCases[idx_Lumia]
            self?.updatePreview_Lumia()
        }
        negativeFlawSection_Lumia.onIntensityChanged_Lumia = { [weak self] value_Lumia in
            self?.params_Lumia.negativeFlawIntensity_Lumia = Double(value_Lumia)
            self?.updatePreview_Lumia()
        }

        borderSection_Lumia.onStyleSelected_Lumia = { [weak self] idx_Lumia in
            self?.params_Lumia.borderStyle_Lumia = FilmBorderStyle_Lumia.allCases[idx_Lumia]
            self?.updatePreview_Lumia()
        }
        borderSection_Lumia.onThicknessChanged_Lumia = { [weak self] value_Lumia in
            self?.params_Lumia.borderThickness_Lumia = Double(value_Lumia)
            self?.updatePreview_Lumia()
        }
        borderSection_Lumia.onPerforationsChanged_Lumia = { [weak self] isOn_Lumia in
            self?.params_Lumia.showPerforations_Lumia = isOn_Lumia
            self?.updatePreview_Lumia()
        }
        borderSection_Lumia.onWatermarkChanged_Lumia = { [weak self] text_Lumia in
            self?.params_Lumia.watermarkText_Lumia = text_Lumia
            self?.updatePreview_Lumia()
        }

        showSection_Lumia(0)
    }

    private func showSection_Lumia(_ index_Lumia: Int) {
        [lightLeakSection_Lumia, lensFlawSection_Lumia, negativeFlawSection_Lumia, borderSection_Lumia].enumerated().forEach { idx_Lumia, view_Lumia in
            view_Lumia.isHidden = idx_Lumia != index_Lumia
        }
    }

    // MARK: - 事件处理

    @objc private func handleChoosePhoto_Lumia() {
        MediaPickerHelper_Lumia.pickImage_Lumia(from: self) { [weak self] image_Lumia in
            guard let self = self, let image_Lumia = image_Lumia else { return }
            self.sourceImage_Lumia = image_Lumia
            self.previewBaseImage_Lumia = FilmAdjustmentPanelPage_Lumia.downscale_Lumia(image_Lumia)
            self.updatePreview_Lumia()
        }
    }

    // MARK: - 预览渲染

    private func updatePreview_Lumia() {
        guard let base_Lumia = previewBaseImage_Lumia else {
            previewImageView_Lumia.image = nil
            previewPlaceholder_Lumia.isHidden = false
            return
        }
        previewPlaceholder_Lumia.isHidden = true
        renderer_Lumia.request_Lumia(
            params_Lumia: params_Lumia,
            render_Lumia: { params_Lumia in
                FilmEffectsEngine_Lumia.applyHardwareEffects_Lumia(to: base_Lumia, params_Lumia: params_Lumia)
            },
            completion_Lumia: { [weak self] image_Lumia in
                self?.previewImageView_Lumia.image = image_Lumia
            }
        )
    }
}

// MARK: - 风格选择 + 强度滑块 组合区块

/// 风格选择 + 强度滑块组合区块
/// 核心作用：漏光/镜头瑕疵/底片瑕疵三大特效类别共用的控制区块（风格胶囊选择 + 强度滑块）
private class HardwareEffectStyleSection_Lumia: UIView {

    var onStyleSelected_Lumia: ((Int) -> Void)?
    var onIntensityChanged_Lumia: ((Float) -> Void)?

    private lazy var styleTabBar_Lumia = PillTabBar_Lumia(
        gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7),
        unselectedTint_Lumia: accent_Lumia
    )
    private lazy var intensityRow_Lumia = LabeledSliderRow_Lumia(title_Lumia: sliderTitle_Lumia, titleColor_Lumia: textColor_Lumia, accentColor_Lumia: accent_Lumia)

    private let accent_Lumia: UIColor
    private let textColor_Lumia: UIColor
    private let styleTitles_Lumia: [String]
    private let sliderTitle_Lumia: String

    init(accent_Lumia: UIColor, textColor_Lumia: UIColor, styleTitles_Lumia: [String], sliderTitle_Lumia: String) {
        self.accent_Lumia = accent_Lumia
        self.textColor_Lumia = textColor_Lumia
        self.styleTitles_Lumia = styleTitles_Lumia
        self.sliderTitle_Lumia = sliderTitle_Lumia
        super.init(frame: .zero)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        addSubview(styleTabBar_Lumia)
        styleTabBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        styleTabBar_Lumia.configure_Lumia(titles_Lumia: styleTitles_Lumia)
        styleTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.onStyleSelected_Lumia?(idx_Lumia) }

        addSubview(intensityRow_Lumia)
        intensityRow_Lumia.configure_Lumia(minValue_Lumia: 0, maxValue_Lumia: 1, currentValue_Lumia: 0.5)
        intensityRow_Lumia.onValueChanged_Lumia = { [weak self] value_Lumia in self?.onIntensityChanged_Lumia?(value_Lumia) }
        intensityRow_Lumia.snp.makeConstraints { make in
            make.top.equalTo(styleTabBar_Lumia.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - 相纸边框控制区块

/// 相纸边框控制区块
/// 核心作用：边框风格选择 + 厚度滑块 + 齿孔开关 + 编号水印输入
private class BorderEffectSection_Lumia: UIView {

    var onStyleSelected_Lumia: ((Int) -> Void)?
    var onThicknessChanged_Lumia: ((Float) -> Void)?
    var onPerforationsChanged_Lumia: ((Bool) -> Void)?
    var onWatermarkChanged_Lumia: ((String) -> Void)?

    private lazy var styleTabBar_Lumia = PillTabBar_Lumia(
        gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7),
        unselectedTint_Lumia: accent_Lumia
    )
    private lazy var thicknessRow_Lumia = LabeledSliderRow_Lumia(title_Lumia: "Border Thickness", titleColor_Lumia: textColor_Lumia, accentColor_Lumia: accent_Lumia)

    private let perforationsLabel_Lumia: UILabel
    private let perforationsSwitch_Lumia = UISwitch()
    private let watermarkField_Lumia: UITextField

    private let accent_Lumia: UIColor
    private let textColor_Lumia: UIColor

    init(accent_Lumia: UIColor, textColor_Lumia: UIColor) {
        self.accent_Lumia = accent_Lumia
        self.textColor_Lumia = textColor_Lumia
        let label_Lumia = UILabel()
        label_Lumia.text = "Negative Perforations"
        label_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_Lumia.textColor = textColor_Lumia
        self.perforationsLabel_Lumia = label_Lumia

        let field_Lumia = UITextField()
        field_Lumia.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        field_Lumia.textColor = textColor_Lumia
        field_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        field_Lumia.layer.cornerRadius = 8
        field_Lumia.attributedPlaceholder = NSAttributedString(
            string: "Frame No. Watermark (optional)",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.35)]
        )
        self.watermarkField_Lumia = field_Lumia

        super.init(frame: .zero)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        addSubview(styleTabBar_Lumia)
        styleTabBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        styleTabBar_Lumia.configure_Lumia(titles_Lumia: FilmBorderStyle_Lumia.allCases.map { $0.rawValue })
        styleTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.onStyleSelected_Lumia?(idx_Lumia) }

        addSubview(thicknessRow_Lumia)
        thicknessRow_Lumia.configure_Lumia(minValue_Lumia: 0, maxValue_Lumia: 1, currentValue_Lumia: 0.4)
        thicknessRow_Lumia.onValueChanged_Lumia = { [weak self] value_Lumia in self?.onThicknessChanged_Lumia?(value_Lumia) }
        thicknessRow_Lumia.snp.makeConstraints { make in
            make.top.equalTo(styleTabBar_Lumia.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }

        addSubview(perforationsLabel_Lumia)
        perforationsLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(thicknessRow_Lumia.snp.bottom).offset(20)
            make.leading.equalToSuperview()
        }
        perforationsSwitch_Lumia.onTintColor = accent_Lumia
        perforationsSwitch_Lumia.addTarget(self, action: #selector(handlePerforationsChanged_Lumia), for: .valueChanged)
        addSubview(perforationsSwitch_Lumia)
        perforationsSwitch_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(perforationsLabel_Lumia)
            make.trailing.equalToSuperview()
        }

        addSubview(watermarkField_Lumia)
        watermarkField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(perforationsLabel_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        watermarkField_Lumia.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        watermarkField_Lumia.leftViewMode = .always
        watermarkField_Lumia.addTarget(self, action: #selector(handleWatermarkChanged_Lumia), for: .editingChanged)
    }

    @objc private func handlePerforationsChanged_Lumia() {
        onPerforationsChanged_Lumia?(perforationsSwitch_Lumia.isOn)
    }

    @objc private func handleWatermarkChanged_Lumia() {
        onWatermarkChanged_Lumia?(watermarkField_Lumia.text ?? "")
    }
}
