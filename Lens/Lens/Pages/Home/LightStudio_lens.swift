import UIKit
import SnapKit

// MARK: - 光源工作室

/// LightStudio_Lens
/// 功能：12 种真实光源模式，360° 角度与强度调节，专属光影照片提取
class LightStudio_Lens: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var modes_Lens: [LightModeType_Lens] = []
    private var currentLight_Lens: LightEnvironmentModel_Lens?
    /// 缓存原图，避免每次滤镜都从磁盘读取
    private var cachedOriginalImage_Lens: UIImage?
    private var cachedReferencePath_Lens: String?
    /// 滤镜任务序号，用于丢弃过期结果
    private var filterGeneration_Lens: UInt64 = 0
    /// 拖动预览防抖任务
    private var filterDebounceWorkItem_Lens: DispatchWorkItem?
    /// 是否正在拖动滑块
    private var isSliderDragging_Lens = false

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
        l.text = "Light Studio"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let previewView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        return v
    }()

    private let previewGradient_Lens = CAGradientLayer()

    private let angleSlider_Lens = StudioSliderRow_Lens(title_Lens: "Light Angle (360°)")
    private let intensitySlider_Lens = StudioSliderRow_Lens(title_Lens: "Intensity")

    private let exclusiveButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Upload Photo", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.titleLabel?.numberOfLines = 1
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.85
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
        b.layer.cornerRadius = 22
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return b
    }()

    private let recordTimelineButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Record to Timeline", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.titleLabel?.numberOfLines = 1
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.85
        b.setTitleColor(UIColor(hexstring_Lens: "#FFD93D"), for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#FFD93D", alpha_Lens: 0.12)
        b.layer.cornerRadius = 22
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hexstring_Lens: "#FFD93D", alpha_Lens: 0.3).cgColor
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return b
    }()

    private let actionStack_Lens: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        s.distribution = .fillEqually
        return s
    }()

    private let modeTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "12 LIGHT MODES"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    private let currentModeLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .white
        l.textAlignment = .right
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    private let filterHintLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Color Filter"
        l.font = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.85)
        l.backgroundColor = UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.35)
        l.textAlignment = .center
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.isHidden = true
        return l
    }()

    private let referenceMediaView_Lens = MediaDisplayView_Lens()

    private lazy var collectionView_Lens: UICollectionView = {
        let layout_Lens = UICollectionViewFlowLayout()
        layout_Lens.minimumInteritemSpacing = 10
        layout_Lens.minimumLineSpacing = 10
        let cv_Lens = UICollectionView(frame: .zero, collectionViewLayout: layout_Lens)
        cv_Lens.backgroundColor = .clear
        cv_Lens.dataSource = self
        cv_Lens.delegate = self
        cv_Lens.register(LightModeCell_Lens.self, forCellWithReuseIdentifier: LightModeCell_Lens.reuseId_Lens)
        return cv_Lens
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        modes_Lens = StudioViewModel_Lens.shared_Lens.getAllLightModes_Lens()
        setupUI_Lens()
        bindSliders_Lens()
        reloadLight_Lens()
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadLight_Lens),
            name: StudioViewModel_Lens.studioStateDidChangeNotification_Lens, object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func setupUI_Lens() {
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        view.addSubview(previewView_Lens)
        previewView_Lens.addSubview(referenceMediaView_Lens)
        previewView_Lens.addSubview(filterHintLabel_Lens)
        previewView_Lens.layer.addSublayer(previewGradient_Lens)
        view.addSubview(angleSlider_Lens)
        view.addSubview(intensitySlider_Lens)
        actionStack_Lens.addArrangedSubview(exclusiveButton_Lens)
        actionStack_Lens.addArrangedSubview(recordTimelineButton_Lens)
        view.addSubview(actionStack_Lens)
        view.addSubview(modeTitleLabel_Lens)
        view.addSubview(currentModeLabel_Lens)
        view.addSubview(collectionView_Lens)

        backButton_Lens.addTarget(self, action: #selector(backTapped_Lens), for: .touchUpInside)
        exclusiveButton_Lens.addTarget(self, action: #selector(uploadPhotoTapped_Lens), for: .touchUpInside)
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
            $0.height.equalTo(200)
        }
        referenceMediaView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        filterHintLabel_Lens.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(10)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(72)
        }
        referenceMediaView_Lens.layer.cornerRadius = 20
        referenceMediaView_Lens.clipsToBounds = true
        referenceMediaView_Lens.isHidden = true
        angleSlider_Lens.snp.makeConstraints {
            $0.top.equalTo(previewView_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        intensitySlider_Lens.snp.makeConstraints {
            $0.top.equalTo(angleSlider_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(angleSlider_Lens)
            $0.height.equalTo(48)
        }
        actionStack_Lens.snp.makeConstraints {
            $0.top.equalTo(intensitySlider_Lens.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        exclusiveButton_Lens.snp.makeConstraints { $0.height.equalTo(44) }
        recordTimelineButton_Lens.snp.makeConstraints { $0.height.equalTo(44) }
        modeTitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(actionStack_Lens.snp.bottom).offset(16)
            $0.trailing.lessThanOrEqualTo(currentModeLabel_Lens.snp.leading).offset(-12)
        }
        currentModeLabel_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(modeTitleLabel_Lens)
            $0.width.lessThanOrEqualTo(160)
        }
        collectionView_Lens.snp.makeConstraints {
            $0.top.equalTo(modeTitleLabel_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func bindSliders_Lens() {
        angleSlider_Lens.onValueChanged_Lens = { [weak self] val_Lens in
            guard let self_Lens = self, let light_Lens = self_Lens.currentLight_Lens else { return }
            self_Lens.isSliderDragging_Lens = true
            StudioViewModel_Lens.shared_Lens.updateLightParams_Lens(
                angle_Lens: Double(val_Lens * 360),
                intensity_Lens: light_Lens.intensity_Lens,
                persist_Lens: false
            )
            self_Lens.currentLight_Lens = StudioViewModel_Lens.shared_Lens.getCurrentLight_Lens()
            self_Lens.updatePreview_Lens()
            self_Lens.scheduleFilteredPreview_Lens(quality_Lens: .preview_Lens)
        }
        angleSlider_Lens.onValueEnded_Lens = { [weak self] val_Lens in
            guard let self_Lens = self, let light_Lens = self_Lens.currentLight_Lens else { return }
            self_Lens.isSliderDragging_Lens = false
            StudioViewModel_Lens.shared_Lens.updateLightParams_Lens(
                angle_Lens: Double(val_Lens * 360),
                intensity_Lens: light_Lens.intensity_Lens,
                persist_Lens: true
            )
            self_Lens.currentLight_Lens = StudioViewModel_Lens.shared_Lens.getCurrentLight_Lens()
            self_Lens.scheduleFilteredPreview_Lens(quality_Lens: .full_Lens, immediate_Lens: true)
        }
        intensitySlider_Lens.onValueChanged_Lens = { [weak self] val_Lens in
            guard let self_Lens = self, let light_Lens = self_Lens.currentLight_Lens else { return }
            self_Lens.isSliderDragging_Lens = true
            StudioViewModel_Lens.shared_Lens.updateLightParams_Lens(
                angle_Lens: light_Lens.angle_Lens,
                intensity_Lens: Double(val_Lens),
                persist_Lens: false
            )
            self_Lens.currentLight_Lens = StudioViewModel_Lens.shared_Lens.getCurrentLight_Lens()
            self_Lens.updatePreview_Lens()
            self_Lens.scheduleFilteredPreview_Lens(quality_Lens: .preview_Lens)
        }
        intensitySlider_Lens.onValueEnded_Lens = { [weak self] val_Lens in
            guard let self_Lens = self, let light_Lens = self_Lens.currentLight_Lens else { return }
            self_Lens.isSliderDragging_Lens = false
            StudioViewModel_Lens.shared_Lens.updateLightParams_Lens(
                angle_Lens: light_Lens.angle_Lens,
                intensity_Lens: Double(val_Lens),
                persist_Lens: true
            )
            self_Lens.currentLight_Lens = StudioViewModel_Lens.shared_Lens.getCurrentLight_Lens()
            self_Lens.scheduleFilteredPreview_Lens(quality_Lens: .full_Lens, immediate_Lens: true)
        }
    }

    @objc private func reloadLight_Lens() {
        currentLight_Lens = StudioViewModel_Lens.shared_Lens.getCurrentLight_Lens()
        guard let light_Lens = currentLight_Lens else { return }
        if !isSliderDragging_Lens {
            angleSlider_Lens.setValue_Lens(Float(light_Lens.angle_Lens / 360.0))
            intensitySlider_Lens.setValue_Lens(Float(light_Lens.intensity_Lens))
        }
        updatePreview_Lens()
        loadReferencePhoto_Lens()
        currentModeLabel_Lens.text = light_Lens.mode_Lens.displayTitle_Lens
        collectionView_Lens.reloadData()
    }

    /// 更新光源预览渐变（有参考图时半透明叠加）
    private func updatePreview_Lens() {
        let colors_Lens = StudioViewModel_Lens.shared_Lens.buildLightPreviewColors_Lens()
        previewGradient_Lens.colors = colors_Lens
        previewGradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        previewGradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        if let light_Lens = currentLight_Lens {
            let rad_Lens = light_Lens.angle_Lens * .pi / 180
            previewGradient_Lens.startPoint = CGPoint(x: 0.5 - cos(rad_Lens) * 0.5, y: 0.5 - sin(rad_Lens) * 0.5)
            previewGradient_Lens.endPoint = CGPoint(x: 0.5 + cos(rad_Lens) * 0.5, y: 0.5 + sin(rad_Lens) * 0.5)
        }
        previewGradient_Lens.opacity = referenceMediaView_Lens.isHidden ? 1.0 : 0.52
    }

    /// 加载参考图并应用光源滤镜
    private func loadReferencePhoto_Lens() {
        guard let light_Lens = currentLight_Lens,
              let path_Lens = light_Lens.referencePhotoPath_Lens else {
            cachedOriginalImage_Lens = nil
            cachedReferencePath_Lens = nil
            referenceMediaView_Lens.isHidden = true
            filterHintLabel_Lens.isHidden = true
            updatePreview_Lens()
            return
        }

        if cachedReferencePath_Lens != path_Lens || cachedOriginalImage_Lens == nil {
            cachedReferencePath_Lens = path_Lens
            cachedOriginalImage_Lens = LightPhotoFilterHelper_Lens.loadLocalImage_Lens(path_Lens: path_Lens)
        }

        guard cachedOriginalImage_Lens != nil else {
            referenceMediaView_Lens.isHidden = true
            filterHintLabel_Lens.isHidden = true
            updatePreview_Lens()
            return
        }

        referenceMediaView_Lens.isHidden = false
        filterHintLabel_Lens.isHidden = false
        scheduleFilteredPreview_Lens(quality_Lens: .full_Lens, immediate_Lens: true)
    }

    /// 防抖调度滤镜预览（后台渲染，主线程更新 UI）
    private func scheduleFilteredPreview_Lens(
        quality_Lens: LightPhotoFilterHelper_Lens.FilterQuality_Lens,
        immediate_Lens: Bool = false
    ) {
        filterDebounceWorkItem_Lens?.cancel()
        guard let light_Lens = currentLight_Lens,
              let original_Lens = cachedOriginalImage_Lens else { return }

        let lightSnapshot_Lens = light_Lens
        var workItem_Lens: DispatchWorkItem!
        workItem_Lens = DispatchWorkItem { [weak self] in
            guard let self_Lens = self else { return }
            self_Lens.filterGeneration_Lens += 1
            let generation_Lens = self_Lens.filterGeneration_Lens
            LightPhotoFilterHelper_Lens.applyLightFilterAsync_Lens(
                image_Lens: original_Lens,
                light_Lens: lightSnapshot_Lens,
                quality_Lens: quality_Lens,
                generation_Lens: generation_Lens,
                isLatestGeneration_Lens: { [weak self] gen_Lens in
                    self?.filterGeneration_Lens == gen_Lens
                },
                completion_Lens: { [weak self] filtered_Lens in
                    guard let self_Lens = self else { return }
                    self_Lens.referenceMediaView_Lens.configureWithImage_Lens(image_Lens: filtered_Lens)
                    self_Lens.updatePreview_Lens()
                }
            )
        }
        filterDebounceWorkItem_Lens = workItem_Lens
        let delay_Lens = immediate_Lens ? 0 : (quality_Lens == .preview_Lens ? 0.05 : 0.08)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_Lens, execute: workItem_Lens)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewGradient_Lens.frame = previewView_Lens.bounds
        previewGradient_Lens.cornerRadius = 20
    }

    @objc private func backTapped_Lens() { Navigation_Lens.pop_Lens() }

    /// 上传照片提取专属光影并自动调整光线参数
    @objc private func uploadPhotoTapped_Lens() {
        MediaPickerHelper_Lens.pickImage_Lens(from: self) { [weak self] image_Lens in
            guard let self_Lens = self, let image_Lens else { return }
            StudioViewModel_Lens.shared_Lens.applyExclusiveLightFromPhoto_Lens(image_Lens: image_Lens)
            Load_Lens.showSuccess_Lens(message_Lens: "Light extracted from photo!")
            self_Lens.reloadLight_Lens()
        }
    }

    /// 记录光源调整到创作时间线（需登录）
    @objc private func recordTimelineTapped_Lens() {
        if StudioViewModel_Lens.shared_Lens.recordLightSessionToTimeline_Lens() {
            Load_Lens.showSuccess_Lens(message_Lens: "Light session recorded!")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        modes_Lens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Lens = collectionView.dequeueReusableCell(
            withReuseIdentifier: LightModeCell_Lens.reuseId_Lens, for: indexPath
        ) as? LightModeCell_Lens else { return UICollectionViewCell() }
        let mode_Lens = modes_Lens[indexPath.item]
        let isSelected_Lens = currentLight_Lens?.mode_Lens == mode_Lens
        cell_Lens.configure_Lens(mode_Lens: mode_Lens, isSelected_Lens: isSelected_Lens)
        return cell_Lens
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mode_Lens = modes_Lens[indexPath.item]
        if mode_Lens == .exclusiveLight_Lens {
            uploadPhotoTapped_Lens()
            return
        }
        StudioViewModel_Lens.shared_Lens.setLightMode_Lens(mode_Lens: mode_Lens)
        currentLight_Lens = StudioViewModel_Lens.shared_Lens.getCurrentLight_Lens()
        guard let light_Lens = currentLight_Lens else { return }
        currentModeLabel_Lens.text = light_Lens.mode_Lens.displayTitle_Lens
        updatePreview_Lens()
        scheduleFilteredPreview_Lens(quality_Lens: .full_Lens, immediate_Lens: true)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w_Lens = (collectionView.bounds.width - 20) / 3
        return CGSize(width: w_Lens, height: 72)
    }
}

// MARK: - 光源模式 Cell

class LightModeCell_Lens: UICollectionViewCell {
    static let reuseId_Lens = "LightModeCell_Lens"

    private let card_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 12
        return v
    }()

    private let iconView_Lens: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(card_Lens)
        card_Lens.addSubview(iconView_Lens)
        card_Lens.addSubview(titleLabel_Lens)
        card_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        iconView_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(22)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.top.equalTo(iconView_Lens.snp.bottom).offset(4)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure_Lens(mode_Lens: LightModeType_Lens, isSelected_Lens: Bool) {
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView_Lens.image = UIImage(systemName: mode_Lens.iconName_Lens, withConfiguration: cfg_Lens)
        iconView_Lens.tintColor = UIColor(hexstring_Lens: mode_Lens.defaultTintHex_Lens)
        titleLabel_Lens.text = mode_Lens.displayTitle_Lens
        card_Lens.layer.borderWidth = isSelected_Lens ? 1.5 : 0
        card_Lens.layer.borderColor = isSelected_Lens
            ? UIColor(hexstring_Lens: "#FFD93D").cgColor
            : UIColor.clear.cgColor
    }
}
