import UIKit
import SnapKit

// MARK: - 亚克力分层工作室

/// AcrylicStudio_Lens
/// 功能：模拟亚克力板分层创作，支持每层独立调节透明度、饱和度、笔触厚度与边缘光泽
class AcrylicStudio_Lens: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var layers_Lens: [AcrylicLayerModel_Lens] = []
    private var selectedLayerId_Lens: Int?

    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Acrylic Layers"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let previewView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        v.clipsToBounds = true
        return v
    }()

    private let refractionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Refraction Preview"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }()

    private let blendSwatch_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.15).cgColor
        return v
    }()

    private let blendHexLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        return l
    }()

    private let saveTestButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save Test", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.titleLabel?.numberOfLines = 1
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.85
        b.setTitleColor(UIColor(hexstring_Lens: "#C77DFF"), for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#C77DFF", alpha_Lens: 0.12)
        b.layer.cornerRadius = 18
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return b
    }()

    private let recordTimelineButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Record to Timeline", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.titleLabel?.numberOfLines = 1
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.8
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
        b.layer.cornerRadius = 18
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return b
    }()

    private let actionStack_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        s.distribution = .fillEqually
        return s
    }()

    private let addLayerButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+ Add Layer", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.setTitleColor(UIColor(hexstring_Lens: "#C77DFF"), for: .normal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()

    private let metaRow_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 8
        return s
    }()

    private let blendRow_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 8
        return s
    }()

    private lazy var tableView_Lens: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.separatorStyle = .none
        t.dataSource = self
        t.delegate = self
        t.register(AcrylicLayerCell_Lens.self, forCellReuseIdentifier: AcrylicLayerCell_Lens.reuseId_Lens)
        return t
    }()

    private let sliderPanel_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 18
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let opacitySlider_Lens = StudioSliderRow_Lens(title_Lens: "Opacity")
    private let saturationSlider_Lens = StudioSliderRow_Lens(title_Lens: "Saturation")
    private let thicknessSlider_Lens = StudioSliderRow_Lens(title_Lens: "Brush Thickness")
    private let glossSlider_Lens = StudioSliderRow_Lens(title_Lens: "Edge Gloss")

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        setupUI_Lens()
        bindSliders_Lens()
        reloadData_Lens()
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadData_Lens),
            name: StudioViewModel_Lens.studioStateDidChangeNotification_Lens, object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func setupUI_Lens() {
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        view.addSubview(previewView_Lens)
        metaRow_Lens.addArrangedSubview(refractionLabel_Lens)
        metaRow_Lens.addArrangedSubview(UIView())
        metaRow_Lens.addArrangedSubview(addLayerButton_Lens)
        blendRow_Lens.addArrangedSubview(UIView())
        blendRow_Lens.addArrangedSubview(blendHexLabel_Lens)
        blendRow_Lens.addArrangedSubview(blendSwatch_Lens)
        view.addSubview(metaRow_Lens)
        view.addSubview(blendRow_Lens)
        actionStack_Lens.addArrangedSubview(saveTestButton_Lens)
        actionStack_Lens.addArrangedSubview(recordTimelineButton_Lens)
        view.addSubview(actionStack_Lens)
        view.addSubview(tableView_Lens)
        view.addSubview(sliderPanel_Lens)
        sliderPanel_Lens.addSubview(opacitySlider_Lens)
        sliderPanel_Lens.addSubview(saturationSlider_Lens)
        sliderPanel_Lens.addSubview(thicknessSlider_Lens)
        sliderPanel_Lens.addSubview(glossSlider_Lens)

        backButton_Lens.addTarget(self, action: #selector(backTapped_Lens), for: .touchUpInside)
        addLayerButton_Lens.addTarget(self, action: #selector(addLayerTapped_Lens), for: .touchUpInside)
        saveTestButton_Lens.addTarget(self, action: #selector(saveTestTapped_Lens), for: .touchUpInside)
        recordTimelineButton_Lens.addTarget(self, action: #selector(recordTimelineTapped_Lens), for: .touchUpInside)

        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(52)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(8)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
        }
        previewView_Lens.snp.makeConstraints {
            $0.top.equalTo(navBar_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(170)
        }
        metaRow_Lens.snp.makeConstraints {
            $0.leading.trailing.equalTo(previewView_Lens)
            $0.top.equalTo(previewView_Lens.snp.bottom).offset(10)
            $0.height.equalTo(24)
        }
        blendRow_Lens.snp.makeConstraints {
            $0.leading.trailing.equalTo(previewView_Lens)
            $0.top.equalTo(metaRow_Lens.snp.bottom).offset(6)
            $0.height.equalTo(24)
        }
        blendSwatch_Lens.snp.makeConstraints {
            $0.width.height.equalTo(22)
        }
        actionStack_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(blendRow_Lens.snp.bottom).offset(12)
        }
        saveTestButton_Lens.snp.makeConstraints { $0.height.equalTo(40) }
        recordTimelineButton_Lens.snp.makeConstraints { $0.height.equalTo(40) }
        sliderPanel_Lens.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(280)
        }
        tableView_Lens.snp.makeConstraints {
            $0.top.equalTo(actionStack_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(sliderPanel_Lens.snp.top)
        }
        opacitySlider_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        saturationSlider_Lens.snp.makeConstraints {
            $0.top.equalTo(opacitySlider_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(opacitySlider_Lens)
            $0.height.equalTo(48)
        }
        thicknessSlider_Lens.snp.makeConstraints {
            $0.top.equalTo(saturationSlider_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(opacitySlider_Lens)
            $0.height.equalTo(48)
        }
        glossSlider_Lens.snp.makeConstraints {
            $0.top.equalTo(thicknessSlider_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(opacitySlider_Lens)
            $0.height.equalTo(48)
        }
    }

    /// 绑定滑块值变化回调
    private func bindSliders_Lens() {
        opacitySlider_Lens.onValueChanged_Lens = { [weak self] val_Lens in
            self?.updateSelectedLayer_Lens { StudioViewModel_Lens.shared_Lens.updateLayer_Lens(layerId_Lens: $0, opacity_Lens: Double(val_Lens)) }
        }
        saturationSlider_Lens.onValueChanged_Lens = { [weak self] val_Lens in
            self?.updateSelectedLayer_Lens { StudioViewModel_Lens.shared_Lens.updateLayer_Lens(layerId_Lens: $0, saturation_Lens: Double(val_Lens)) }
        }
        thicknessSlider_Lens.onValueChanged_Lens = { [weak self] val_Lens in
            self?.updateSelectedLayer_Lens { StudioViewModel_Lens.shared_Lens.updateLayer_Lens(layerId_Lens: $0, brushThickness_Lens: Double(0.5 + val_Lens * 7.5)) }
        }
        glossSlider_Lens.onValueChanged_Lens = { [weak self] val_Lens in
            self?.updateSelectedLayer_Lens { StudioViewModel_Lens.shared_Lens.updateLayer_Lens(layerId_Lens: $0, edgeGloss_Lens: Double(val_Lens)) }
        }
    }

    private func updateSelectedLayer_Lens(action_Lens: (Int) -> Void) {
        guard let id_Lens = selectedLayerId_Lens else { return }
        action_Lens(id_Lens)
        updatePreview_Lens()
    }

    @objc private func reloadData_Lens() {
        layers_Lens = StudioViewModel_Lens.shared_Lens.getLayers_Lens()
        if selectedLayerId_Lens == nil { selectedLayerId_Lens = layers_Lens.first?.layerId_Lens }
        tableView_Lens.reloadData()
        syncSliders_Lens()
        updatePreview_Lens()
    }

    /// 同步当前选中层的滑块数值
    private func syncSliders_Lens() {
        guard let layer_Lens = layers_Lens.first(where: { $0.layerId_Lens == selectedLayerId_Lens }) else { return }
        opacitySlider_Lens.setValue_Lens(Float(layer_Lens.opacity_Lens))
        saturationSlider_Lens.setValue_Lens(Float(layer_Lens.saturation_Lens))
        thicknessSlider_Lens.setValue_Lens(Float((layer_Lens.brushThickness_Lens - 0.5) / 7.5))
        glossSlider_Lens.setValue_Lens(Float(layer_Lens.edgeGloss_Lens))
    }

    /// 刷新折射预览（多层叠加可视化）
    private func updatePreview_Lens() {
        previewView_Lens.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let sorted_Lens = layers_Lens.sorted { $0.stackOrder_Lens < $1.stackOrder_Lens }
        let h_Lens: CGFloat = 160
        let layerH_Lens = h_Lens / CGFloat(max(sorted_Lens.count, 1))

        for (idx_Lens, layer_Lens) in sorted_Lens.enumerated() {
            let layerView_Lens = CALayer()
            layerView_Lens.frame = CGRect(x: 12, y: 12 + layerH_Lens * CGFloat(idx_Lens), width: previewView_Lens.bounds.width - 24, height: layerH_Lens - 4)
            if layerView_Lens.frame.width <= 0 { layerView_Lens.frame.size.width = UIScreen.main.bounds.width - 64 }
            let color_Lens = UIColor(hexstring_Lens: layer_Lens.tintHex_Lens)
                .withAlphaComponent(CGFloat(layer_Lens.opacity_Lens))
            layerView_Lens.backgroundColor = color_Lens.cgColor
            layerView_Lens.cornerRadius = 10
            layerView_Lens.borderWidth = CGFloat(layer_Lens.edgeGloss_Lens) * 2
            layerView_Lens.borderColor = UIColor.white.withAlphaComponent(CGFloat(layer_Lens.edgeGloss_Lens) * 0.5).cgColor
            previewView_Lens.layer.addSublayer(layerView_Lens)
        }

        let blend_Lens = StudioViewModel_Lens.shared_Lens.getCurrentRefractionColor_Lens()
        previewView_Lens.backgroundColor = blend_Lens.withAlphaComponent(0.25)
        blendSwatch_Lens.backgroundColor = blend_Lens
        var r_Lens: CGFloat = 0, g_Lens: CGFloat = 0, b_Lens: CGFloat = 0, a_Lens: CGFloat = 0
        blend_Lens.getRed(&r_Lens, green: &g_Lens, blue: &b_Lens, alpha: &a_Lens)
        blendHexLabel_Lens.text = String(format: "#%02X%02X%02X", Int(r_Lens * 255), Int(g_Lens * 255), Int(b_Lens * 255))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreview_Lens()
    }

    @objc private func backTapped_Lens() { Navigation_Lens.pop_Lens() }

    @objc private func addLayerTapped_Lens() {
        StudioViewModel_Lens.shared_Lens.addLayer_Lens(name_Lens: "Test Layer \(layers_Lens.count + 1)")
    }

    /// 保存色彩测试快照（需登录）
    @objc private func saveTestTapped_Lens() {
        if StudioViewModel_Lens.shared_Lens.saveColorTestSnapshot_Lens() {
            Load_Lens.showSuccess_Lens(message_Lens: "Color test saved!")
        }
    }

    /// 记录到创作时间线（需登录）
    @objc private func recordTimelineTapped_Lens() {
        if StudioViewModel_Lens.shared_Lens.recordAcrylicTestToTimeline_Lens() {
            Load_Lens.showSuccess_Lens(message_Lens: "Recorded to timeline!")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { layers_Lens.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Lens = tableView.dequeueReusableCell(
            withIdentifier: AcrylicLayerCell_Lens.reuseId_Lens, for: indexPath
        ) as? AcrylicLayerCell_Lens else { return UITableViewCell() }
        let layer_Lens = layers_Lens[indexPath.row]
        cell_Lens.configure_Lens(
            layer_Lens: layer_Lens,
            isSelected_Lens: layer_Lens.layerId_Lens == selectedLayerId_Lens
        )
        return cell_Lens
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLayerId_Lens = layers_Lens[indexPath.row].layerId_Lens
        tableView.reloadData()
        syncSliders_Lens()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 64 }
}

// MARK: - 亚克力层 Cell

class AcrylicLayerCell_Lens: UITableViewCell {
    static let reuseId_Lens = "AcrylicLayerCell_Lens"

    private let card_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 14
        return v
    }()

    private let swatch_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8
        return v
    }()

    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .white
        return l
    }()

    private let metaLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(card_Lens)
        card_Lens.addSubview(swatch_Lens)
        card_Lens.addSubview(nameLabel_Lens)
        card_Lens.addSubview(metaLabel_Lens)
        card_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        swatch_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        nameLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(swatch_Lens.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(12)
        }
        metaLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(nameLabel_Lens)
            $0.top.equalTo(nameLabel_Lens.snp.bottom).offset(4)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure_Lens(layer_Lens: AcrylicLayerModel_Lens, isSelected_Lens: Bool) {
        swatch_Lens.backgroundColor = UIColor(hexstring_Lens: layer_Lens.tintHex_Lens)
            .withAlphaComponent(CGFloat(layer_Lens.opacity_Lens))
        nameLabel_Lens.text = layer_Lens.layerName_Lens
        metaLabel_Lens.text = String(format: "Opacity %.0f%% · Gloss %.0f%%", layer_Lens.opacity_Lens * 100, layer_Lens.edgeGloss_Lens * 100)
        card_Lens.layer.borderWidth = isSelected_Lens ? 1.5 : 0
        card_Lens.layer.borderColor = isSelected_Lens
            ? UIColor(hexstring_Lens: "#C77DFF").cgColor
            : UIColor.clear.cgColor
    }
}

// MARK: - 通用滑块行

/// StudioSliderRow_Lens：带标题与数值的滑块行组件
class StudioSliderRow_Lens: UIView {
    var onValueChanged_Lens: ((Float) -> Void)?
    /// 滑块结束拖动回调
    var onValueEnded_Lens: ((Float) -> Void)?

    private let titleLabel_Lens = UILabel()
    private let valueLabel_Lens = UILabel()
    private let slider_Lens = UISlider()

    init(title_Lens: String) {
        super.init(frame: .zero)
        titleLabel_Lens.text = title_Lens
        titleLabel_Lens.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.6)
        titleLabel_Lens.numberOfLines = 1
        titleLabel_Lens.lineBreakMode = .byTruncatingTail
        titleLabel_Lens.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        valueLabel_Lens.font = .systemFont(ofSize: 12, weight: .semibold)
        valueLabel_Lens.textColor = UIColor(hexstring_Lens: "#4D96FF")
        slider_Lens.minimumTrackTintColor = UIColor(hexstring_Lens: "#7B2FF7")
        slider_Lens.maximumTrackTintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12)
        slider_Lens.addTarget(self, action: #selector(sliderChanged_Lens), for: .valueChanged)
        slider_Lens.addTarget(self, action: #selector(sliderEnded_Lens), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        addSubview(titleLabel_Lens)
        addSubview(valueLabel_Lens)
        addSubview(slider_Lens)
        titleLabel_Lens.snp.makeConstraints { $0.leading.top.equalToSuperview() }
        valueLabel_Lens.snp.makeConstraints { $0.trailing.top.equalToSuperview() }
        slider_Lens.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(6)
            $0.height.equalTo(28)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }

    func setValue_Lens(_ value_Lens: Float) {
        slider_Lens.value = value_Lens
        valueLabel_Lens.text = String(format: "%.0f%%", value_Lens * 100)
    }

    @objc private func sliderChanged_Lens() {
        valueLabel_Lens.text = String(format: "%.0f%%", slider_Lens.value * 100)
        onValueChanged_Lens?(slider_Lens.value)
    }

    /// 滑块结束拖动
    @objc private func sliderEnded_Lens() {
        onValueEnded_Lens?(slider_Lens.value)
    }
}
