import Foundation
import UIKit
import SnapKit

// MARK: - 胶片参数手动调节面板页面

/// 胶片参数手动调节面板页面
/// 核心作用：提供颗粒强度、灰雾、对比度、色温偏移、饱和度、RGB 分色、暗角强度、漏光程度、
///          划痕脏点密度等独立滑块，全部基于 FilmEffectsEngine_Lumia 本地实时渲染预览；
///          支持将当前参数保存为自制胶片预设配方（本地存储，不联网）
/// 设计思路：
///   - 顶部为预览图（等比缩小以保证实时渲染流畅），下方为可滚动的滑块列表
///   - 滑块变化时通过 DebouncedImageRenderer_Lumia 在后台队列渲染预览图，避免拖动时任务堆积卡顿，
///     渲染完成后仅在主线程更新 UI
/// 关键属性：
///   - sourceImage_Lumia: 原始图片（若初始化时未传入，页面会引导用户选取）
///   - params_Lumia: 当前调节参数（滑块变化时实时更新）
class FilmAdjustmentPanelPage_Lumia: UIViewController {

    // MARK: - 私有属性

    private var sourceImage_Lumia: UIImage?
    private var previewBaseImage_Lumia: UIImage?
    private var params_Lumia: FilmAdjustmentParams_Lumia
    private let renderer_Lumia = DebouncedImageRenderer_Lumia<FilmAdjustmentParams_Lumia>()

    private let backButton_Lumia = BackButton_Lumia()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Adjustment Panel"
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
        lbl_Lumia.text = "Tap \"Choose Photo\" to preview your adjustments"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.45)
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        return sv_Lumia
    }()

    private let slidersStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 18
        return sv_Lumia
    }()

    private let saveButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Save as Custom Preset", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623")
        btn_Lumia.layer.cornerRadius = 24
        return btn_Lumia
    }()

    private var rowMap_Lumia: [String: LabeledSliderRow_Lumia] = [:]

    // MARK: - 初始化

    /// 初始化调节面板
    /// - Parameters:
    ///   - sourceImage_Lumia: 起始预览图片（可为空，为空时引导用户选取）
    ///   - initialParams_Lumia: 起始调节参数（用于从预设「继续微调」的场景）
    init(sourceImage_Lumia: UIImage? = nil, initialParams_Lumia: FilmAdjustmentParams_Lumia = .neutral_Lumia) {
        self.sourceImage_Lumia = sourceImage_Lumia
        self.params_Lumia = initialParams_Lumia
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#1C1410")
        setupUI_Lumia()
        if let image_Lumia = sourceImage_Lumia {
            previewBaseImage_Lumia = FilmAdjustmentPanelPage_Lumia.downscale_Lumia(image_Lumia)
        }
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
            make.height.equalTo(220)
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

        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(previewContainer_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
        }

        scrollView_Lumia.addSubview(slidersStack_Lumia)
        slidersStack_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }

        buildSliderRows_Lumia()

        view.addSubview(saveButton_Lumia)
        saveButton_Lumia.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        saveButton_Lumia.addTarget(self, action: #selector(handleSavePreset_Lumia), for: .touchUpInside)

        scrollView_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
    }

    private func buildSliderRows_Lumia() {
        let accent_Lumia = UIColor(hexstring_Lumia: "#F6A623")
        let textColor_Lumia = UIColor.white.withAlphaComponent(0.85)

        addPercentRow_Lumia(key_Lumia: "grain", title_Lumia: "Grain Intensity", accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.grain_Lumia)
        addPercentRow_Lumia(key_Lumia: "fog", title_Lumia: "Fog", accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.fog_Lumia)
        addPercentRow_Lumia(key_Lumia: "contrast", title_Lumia: "Contrast", accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.contrast_Lumia)
        addSignedRow_Lumia(key_Lumia: "temp", title_Lumia: "Color Temperature Shift", accent_Lumia: UIColor(hexstring_Lumia: "#F0C060"), textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.tempShift_Lumia)
        addPercentRow_Lumia(key_Lumia: "saturation", title_Lumia: "Saturation", accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.saturation_Lumia)
        addSignedRow_Lumia(key_Lumia: "channelR", title_Lumia: "Red Channel", accent_Lumia: UIColor(hexstring_Lumia: "#E86A5C"), textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.channelR_Lumia)
        addSignedRow_Lumia(key_Lumia: "channelG", title_Lumia: "Green Channel", accent_Lumia: UIColor(hexstring_Lumia: "#6CBF7A"), textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.channelG_Lumia)
        addSignedRow_Lumia(key_Lumia: "channelB", title_Lumia: "Blue Channel", accent_Lumia: UIColor(hexstring_Lumia: "#5C9CE8"), textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.channelB_Lumia)
        addPercentRow_Lumia(key_Lumia: "vignette", title_Lumia: "Vignette Intensity", accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.vignette_Lumia)
        addPercentRow_Lumia(key_Lumia: "lightLeak", title_Lumia: "Light Leak", accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.lightLeak_Lumia)
        addPercentRow_Lumia(key_Lumia: "dustScratch", title_Lumia: "Scratches & Dust", accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia, value_Lumia: params_Lumia.dustScratch_Lumia)
    }

    private func addPercentRow_Lumia(key_Lumia: String, title_Lumia: String, accent_Lumia: UIColor, textColor_Lumia: UIColor, value_Lumia: Double) {
        let row_Lumia = LabeledSliderRow_Lumia(title_Lumia: title_Lumia, titleColor_Lumia: textColor_Lumia, accentColor_Lumia: accent_Lumia)
        row_Lumia.configure_Lumia(minValue_Lumia: 0, maxValue_Lumia: 1, currentValue_Lumia: Float(value_Lumia))
        row_Lumia.onValueChanged_Lumia = { [weak self] newValue_Lumia in
            self?.handleSliderChanged_Lumia(key_Lumia: key_Lumia, value_Lumia: Double(newValue_Lumia))
        }
        slidersStack_Lumia.addArrangedSubview(row_Lumia)
        rowMap_Lumia[key_Lumia] = row_Lumia
    }

    private func addSignedRow_Lumia(key_Lumia: String, title_Lumia: String, accent_Lumia: UIColor, textColor_Lumia: UIColor, value_Lumia: Double) {
        let row_Lumia = LabeledSliderRow_Lumia(title_Lumia: title_Lumia, titleColor_Lumia: textColor_Lumia, accentColor_Lumia: accent_Lumia)
        row_Lumia.valueFormatter_Lumia = { v_Lumia in
            let percent_Lumia = Int(v_Lumia * 100)
            return percent_Lumia > 0 ? "+\(percent_Lumia)%" : "\(percent_Lumia)%"
        }
        row_Lumia.configure_Lumia(minValue_Lumia: -1, maxValue_Lumia: 1, currentValue_Lumia: Float(value_Lumia))
        row_Lumia.onValueChanged_Lumia = { [weak self] newValue_Lumia in
            self?.handleSliderChanged_Lumia(key_Lumia: key_Lumia, value_Lumia: Double(newValue_Lumia))
        }
        slidersStack_Lumia.addArrangedSubview(row_Lumia)
        rowMap_Lumia[key_Lumia] = row_Lumia
    }

    // MARK: - 事件处理

    private func handleSliderChanged_Lumia(key_Lumia: String, value_Lumia: Double) {
        switch key_Lumia {
        case "grain": params_Lumia.grain_Lumia = value_Lumia
        case "fog": params_Lumia.fog_Lumia = value_Lumia
        case "contrast": params_Lumia.contrast_Lumia = value_Lumia
        case "temp": params_Lumia.tempShift_Lumia = value_Lumia
        case "saturation": params_Lumia.saturation_Lumia = value_Lumia
        case "channelR": params_Lumia.channelR_Lumia = value_Lumia
        case "channelG": params_Lumia.channelG_Lumia = value_Lumia
        case "channelB": params_Lumia.channelB_Lumia = value_Lumia
        case "vignette": params_Lumia.vignette_Lumia = value_Lumia
        case "lightLeak": params_Lumia.lightLeak_Lumia = value_Lumia
        case "dustScratch": params_Lumia.dustScratch_Lumia = value_Lumia
        default: break
        }
        updatePreview_Lumia()
    }

    @objc private func handleChoosePhoto_Lumia() {
        MediaPickerHelper_Lumia.pickImage_Lumia(from: self) { [weak self] image_Lumia in
            guard let self = self, let image_Lumia = image_Lumia else { return }
            self.sourceImage_Lumia = image_Lumia
            self.previewBaseImage_Lumia = FilmAdjustmentPanelPage_Lumia.downscale_Lumia(image_Lumia)
            self.updatePreview_Lumia()
        }
    }

    @objc private func handleSavePreset_Lumia() {
        let alert_Lumia = UIAlertController(title: "Save Custom Preset", message: "Give your recipe a name", preferredStyle: .alert)
        alert_Lumia.addTextField { tf_Lumia in tf_Lumia.placeholder = "Recipe name" }
        alert_Lumia.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let name_Lumia = alert_Lumia.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalName_Lumia = (name_Lumia?.isEmpty ?? true) ? "My Recipe" : name_Lumia!
            // 饱和度趋近于 0 时视为黑白配方，否则归为彩负配方；分类统一归入"颗粒风"标签，用户可在预设库中查看
            let inferredStock_Lumia: FilmStockType_Lumia = self.params_Lumia.saturation_Lumia < 0.05 ? .blackWhite_Lumia : .colorNegative_Lumia
            FilmPresetsViewModel_Lumia.shared_Lumia.saveCustomPreset_Lumia(
                filmName_Lumia: finalName_Lumia, stockType_Lumia: inferredStock_Lumia,
                category_Lumia: .grainy_Lumia, params_Lumia: self.params_Lumia
            )
            Utils_Lumia.showSuccess_Lumia(message_Lumia: "Recipe '\(finalName_Lumia)' saved offline ✦")
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
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
                FilmEffectsEngine_Lumia.applyAdjustments_Lumia(to: base_Lumia, params_Lumia: params_Lumia)
            },
            completion_Lumia: { [weak self] image_Lumia in
                self?.previewImageView_Lumia.image = image_Lumia
            }
        )
    }

    /// 将图片等比缩小到较小边长，保证滑块拖动时的本地实时渲染足够流畅
    static func downscale_Lumia(_ image_Lumia: UIImage, maxDimension_Lumia: CGFloat = 640) -> UIImage {
        let size_Lumia = image_Lumia.size
        let maxSide_Lumia = max(size_Lumia.width, size_Lumia.height)
        guard maxSide_Lumia > maxDimension_Lumia else { return image_Lumia }
        let scale_Lumia = maxDimension_Lumia / maxSide_Lumia
        let newSize_Lumia = CGSize(width: size_Lumia.width * scale_Lumia, height: size_Lumia.height * scale_Lumia)
        let renderer_Lumia = UIGraphicsImageRenderer(size: newSize_Lumia)
        return renderer_Lumia.image { _ in image_Lumia.draw(in: CGRect(origin: .zero, size: newSize_Lumia)) }
    }
}
