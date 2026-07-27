import Foundation
import UIKit
import SnapKit

// MARK: - 曝光计算工具页面

/// 曝光计算工具页面
/// 核心作用：提供快门/光圈/ISO 曝光三角互算、阳光十六法则一键估算、闪光指数 GN 计算器三大子工具
/// 设计思路：
///   - 顶部主标签栏切换三个子工具，复用 PillTabBar_Lumia 承载所有离散选项选择（避免引入 UIPickerView）
///   - 所有计算逻辑封装于 ExposureMath_Lumia（纯函数，与 UI 完全解耦，便于复用与验证）
/// 关键属性：
///   - originalShutterIdx_Lumia / originalApertureIdx_Lumia / originalIsoIdx_Lumia: 曝光三角"原始设置"下标
class ExposureCalculatorPage_Lumia: UIViewController {

    // MARK: - 私有属性

    private let accent_Lumia = UIColor(hexstring_Lumia: "#4A90D9")
    private let textColor_Lumia = UIColor.white.withAlphaComponent(0.85)

    private let backButton_Lumia = BackButton_Lumia()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Exposure Calculator"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private lazy var modeTabBar_Lumia = PillTabBar_Lumia(
        gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: UIColor(hexstring_Lumia: "#7B5CD6"),
        unselectedTint_Lumia: UIColor(hexstring_Lumia: "#8AA0C0")
    )

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        return sv_Lumia
    }()

    private lazy var triangleSection_Lumia = ExposureTriangleSection_Lumia(accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia)
    private lazy var sunny16Section_Lumia = Sunny16Section_Lumia(accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia)
    private lazy var flashGNSection_Lumia = FlashGNSection_Lumia(accent_Lumia: accent_Lumia, textColor_Lumia: textColor_Lumia)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#141A24")
        setupUI_Lumia()
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

        view.addSubview(modeTabBar_Lumia)
        modeTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        modeTabBar_Lumia.configure_Lumia(titles_Lumia: ["Exposure Triangle", "Sunny 16", "Flash GN"])
        modeTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.showSection_Lumia(idx_Lumia) }

        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(modeTabBar_Lumia.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)

        [triangleSection_Lumia, sunny16Section_Lumia, flashGNSection_Lumia].forEach {
            scrollView_Lumia.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalTo(view).offset(20)
                make.trailing.equalTo(view).offset(-20)
                make.bottom.lessThanOrEqualToSuperview()
            }
        }

        showSection_Lumia(0)
    }

    private func showSection_Lumia(_ index_Lumia: Int) {
        [triangleSection_Lumia, sunny16Section_Lumia, flashGNSection_Lumia].enumerated().forEach { idx_Lumia, view_Lumia in
            view_Lumia.isHidden = idx_Lumia != index_Lumia
        }
    }
}

// MARK: - 曝光三角计算区块

/// 曝光三角计算区块
/// 核心作用：设定原始快门/光圈/ISO，指定其中一项的新值后，自动计算另一项应如何补偿以维持等量曝光
private class ExposureTriangleSection_Lumia: UIView {

    private let accent_Lumia: UIColor
    private let textColor_Lumia: UIColor

    private let shutterTitles_Lumia = ExposureScale_Lumia.shutterSpeeds_Lumia.map { ExposureMath_Lumia.formatShutter_Lumia($0) }
    private let apertureTitles_Lumia = ExposureScale_Lumia.apertures_Lumia.map { ExposureMath_Lumia.formatAperture_Lumia($0) }
    private let isoTitles_Lumia = ExposureScale_Lumia.isoValues_Lumia.map { ExposureMath_Lumia.formatISO_Lumia($0) }

    private var originalShutterIdx_Lumia = 6   // 1/60s
    private var originalApertureIdx_Lumia = 4  // f/5.6
    private var originalIsoIdx_Lumia = 2       // ISO 100

    private var changingParamIdx_Lumia = 0     // 0=Shutter 1=Aperture 2=ISO
    private var newValueIdx_Lumia = 8
    private var solveForParamIdx_Lumia = 0     // 在剩余两项中选择（下标基于 remainingParamNames_Lumia）

    private lazy var shutterTabBar_Lumia = makeTabBar_Lumia()
    private lazy var apertureTabBar_Lumia = makeTabBar_Lumia()
    private lazy var isoTabBar_Lumia = makeTabBar_Lumia()
    private lazy var changingTabBar_Lumia = makeTabBar_Lumia()
    private lazy var newValueTabBar_Lumia = makeTabBar_Lumia()
    private lazy var solveForTabBar_Lumia = makeTabBar_Lumia()

    private let resultCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_Lumia.layer.cornerRadius = 14
        return v_Lumia
    }()
    private let resultLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl_Lumia.textColor = .white
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()
    private let resultSubLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()

    init(accent_Lumia: UIColor, textColor_Lumia: UIColor) {
        self.accent_Lumia = accent_Lumia
        self.textColor_Lumia = textColor_Lumia
        super.init(frame: .zero)
        setupUI_Lumia()
        updateResult_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeTabBar_Lumia() -> PillTabBar_Lumia {
        return PillTabBar_Lumia(gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7), unselectedTint_Lumia: accent_Lumia)
    }

    private func sectionLabel_Lumia(_ text_Lumia: String) -> UILabel {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = text_Lumia
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = textColor_Lumia.withAlphaComponent(0.55)
        return lbl_Lumia
    }

    private func setupUI_Lumia() {
        let originalTitle_Lumia = sectionLabel_Lumia("ORIGINAL EXPOSURE")
        addSubview(originalTitle_Lumia)
        originalTitle_Lumia.snp.makeConstraints { make in make.top.leading.equalToSuperview() }

        addSubview(shutterTabBar_Lumia)
        shutterTabBar_Lumia.configure_Lumia(titles_Lumia: shutterTitles_Lumia, selectedIndex_Lumia: originalShutterIdx_Lumia)
        shutterTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.originalShutterIdx_Lumia = idx_Lumia; self?.updateResult_Lumia() }
        shutterTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(originalTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        addSubview(apertureTabBar_Lumia)
        apertureTabBar_Lumia.configure_Lumia(titles_Lumia: apertureTitles_Lumia, selectedIndex_Lumia: originalApertureIdx_Lumia)
        apertureTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.originalApertureIdx_Lumia = idx_Lumia; self?.updateResult_Lumia() }
        apertureTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(shutterTabBar_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        addSubview(isoTabBar_Lumia)
        isoTabBar_Lumia.configure_Lumia(titles_Lumia: isoTitles_Lumia, selectedIndex_Lumia: originalIsoIdx_Lumia)
        isoTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.originalIsoIdx_Lumia = idx_Lumia; self?.updateResult_Lumia() }
        isoTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(apertureTabBar_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        let changeTitle_Lumia = sectionLabel_Lumia("CHANGING PARAMETER")
        addSubview(changeTitle_Lumia)
        changeTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(isoTabBar_Lumia.snp.bottom).offset(20)
            make.leading.equalToSuperview()
        }

        addSubview(changingTabBar_Lumia)
        changingTabBar_Lumia.configure_Lumia(titles_Lumia: ["Shutter", "Aperture", "ISO"], selectedIndex_Lumia: changingParamIdx_Lumia)
        changingTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in
            self?.changingParamIdx_Lumia = idx_Lumia
            self?.newValueIdx_Lumia = 0
            self?.solveForParamIdx_Lumia = 0
            self?.refreshDynamicTabBars_Lumia()
        }
        changingTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(changeTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        let newValueTitle_Lumia = sectionLabel_Lumia("NEW VALUE")
        addSubview(newValueTitle_Lumia)
        newValueTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(changingTabBar_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview()
        }
        addSubview(newValueTabBar_Lumia)
        newValueTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.newValueIdx_Lumia = idx_Lumia; self?.updateResult_Lumia() }
        newValueTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(newValueTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        let solveTitle_Lumia = sectionLabel_Lumia("COMPENSATE WITH")
        addSubview(solveTitle_Lumia)
        solveTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(newValueTabBar_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview()
        }
        addSubview(solveForTabBar_Lumia)
        solveForTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.solveForParamIdx_Lumia = idx_Lumia; self?.updateResult_Lumia() }
        solveForTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(solveTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        addSubview(resultCard_Lumia)
        resultCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(solveForTabBar_Lumia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        resultCard_Lumia.addSubview(resultLabel_Lumia)
        resultLabel_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        resultCard_Lumia.addSubview(resultSubLabel_Lumia)
        resultSubLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(resultLabel_Lumia.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        refreshDynamicTabBars_Lumia()
    }

    /// 参数名称固定顺序：Shutter / Aperture / ISO
    private let paramNames_Lumia = ["Shutter", "Aperture", "ISO"]

    private func remainingParamIndices_Lumia() -> [Int] {
        return [0, 1, 2].filter { $0 != changingParamIdx_Lumia }
    }

    private func valueTitles_Lumia(for paramIdx_Lumia: Int) -> [String] {
        switch paramIdx_Lumia {
        case 0: return shutterTitles_Lumia
        case 1: return apertureTitles_Lumia
        default: return isoTitles_Lumia
        }
    }

    private func originalIdx_Lumia(for paramIdx_Lumia: Int) -> Int {
        switch paramIdx_Lumia {
        case 0: return originalShutterIdx_Lumia
        case 1: return originalApertureIdx_Lumia
        default: return originalIsoIdx_Lumia
        }
    }

    /// 切换"正在改变的参数"后，重新构建"新值"与"补偿项"两个动态标签栏
    private func refreshDynamicTabBars_Lumia() {
        newValueTabBar_Lumia.configure_Lumia(titles_Lumia: valueTitles_Lumia(for: changingParamIdx_Lumia), selectedIndex_Lumia: newValueIdx_Lumia)
        let remaining_Lumia = remainingParamIndices_Lumia()
        solveForTabBar_Lumia.configure_Lumia(titles_Lumia: remaining_Lumia.map { paramNames_Lumia[$0] }, selectedIndex_Lumia: solveForParamIdx_Lumia)
        updateResult_Lumia()
    }

    private func updateResult_Lumia() {
        let remaining_Lumia = remainingParamIndices_Lumia()
        guard solveForParamIdx_Lumia < remaining_Lumia.count else { return }
        let solveParam_Lumia = remaining_Lumia[solveForParamIdx_Lumia]
        let pinnedParam_Lumia = remaining_Lumia.first { $0 != solveParam_Lumia } ?? solveParam_Lumia

        // 1. 计算"改变的参数"引入的曝光级数变化
        let oldValueRaw_Lumia = rawValue_Lumia(for: changingParamIdx_Lumia, index_Lumia: originalIdx_Lumia(for: changingParamIdx_Lumia))
        let newValueRaw_Lumia = rawValue_Lumia(for: changingParamIdx_Lumia, index_Lumia: newValueIdx_Lumia)
        let stopsChanged_Lumia = ExposureMath_Lumia.stops_Lumia(paramIdx_Lumia: changingParamIdx_Lumia, from_Lumia: oldValueRaw_Lumia, to_Lumia: newValueRaw_Lumia)

        // 2. 用补偿项抵消该级数变化，被"钉住"的第三项保持原值不变
        let solveBaseRaw_Lumia = rawValue_Lumia(for: solveParam_Lumia, index_Lumia: originalIdx_Lumia(for: solveParam_Lumia))
        let solvedValueRaw_Lumia = ExposureMath_Lumia.valueAfterStops_Lumia(paramIdx_Lumia: solveParam_Lumia, base_Lumia: solveBaseRaw_Lumia, stops_Lumia: -stopsChanged_Lumia)
        let solvedDisplay_Lumia = displayString_Lumia(for: solveParam_Lumia, rawValue_Lumia: solvedValueRaw_Lumia)
        let pinnedDisplay_Lumia = valueTitles_Lumia(for: pinnedParam_Lumia)[originalIdx_Lumia(for: pinnedParam_Lumia)]

        let stopsText_Lumia = String(format: "%+.2f", stopsChanged_Lumia)
        resultLabel_Lumia.text = "New \(paramNames_Lumia[solveParam_Lumia]): \(solvedDisplay_Lumia)"
        resultSubLabel_Lumia.text = "Changing \(paramNames_Lumia[changingParamIdx_Lumia]) shifts exposure by \(stopsText_Lumia) stops. \(paramNames_Lumia[pinnedParam_Lumia]) stays at \(pinnedDisplay_Lumia) to keep equivalent exposure."
    }

    private func rawValue_Lumia(for paramIdx_Lumia: Int, index_Lumia: Int) -> Double {
        switch paramIdx_Lumia {
        case 0: return ExposureScale_Lumia.shutterSpeeds_Lumia[index_Lumia]
        case 1: return ExposureScale_Lumia.apertures_Lumia[index_Lumia]
        default: return ExposureScale_Lumia.isoValues_Lumia[index_Lumia]
        }
    }

    private func displayString_Lumia(for paramIdx_Lumia: Int, rawValue_Lumia: Double) -> String {
        switch paramIdx_Lumia {
        case 0: return ExposureMath_Lumia.formatShutter_Lumia(rawValue_Lumia)
        case 1: return ExposureMath_Lumia.formatAperture_Lumia(rawValue_Lumia)
        default: return ExposureMath_Lumia.formatISO_Lumia(rawValue_Lumia)
        }
    }
}

// MARK: - 阳光十六法则区块

/// 阳光十六法则区块
/// 核心作用：根据光照条件与 ISO 一键估算推荐光圈与快门组合
private class Sunny16Section_Lumia: UIView {

    private let accent_Lumia: UIColor
    private let textColor_Lumia: UIColor

    private var conditionIdx_Lumia = 0
    private var isoIdx_Lumia = 2

    private lazy var conditionTabBar_Lumia = PillTabBar_Lumia(gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7), unselectedTint_Lumia: accent_Lumia)
    private lazy var isoTabBar_Lumia = PillTabBar_Lumia(gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7), unselectedTint_Lumia: accent_Lumia)

    private let resultCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_Lumia.layer.cornerRadius = 14
        return v_Lumia
    }()
    private let resultLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl_Lumia.textColor = .white
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()
    private let resultSubLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()

    init(accent_Lumia: UIColor, textColor_Lumia: UIColor) {
        self.accent_Lumia = accent_Lumia
        self.textColor_Lumia = textColor_Lumia
        super.init(frame: .zero)
        setupUI_Lumia()
        updateResult_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func sectionLabel_Lumia(_ text_Lumia: String) -> UILabel {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = text_Lumia
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = textColor_Lumia.withAlphaComponent(0.55)
        return lbl_Lumia
    }

    private func setupUI_Lumia() {
        let conditionTitle_Lumia = sectionLabel_Lumia("LIGHTING CONDITION")
        addSubview(conditionTitle_Lumia)
        conditionTitle_Lumia.snp.makeConstraints { make in make.top.leading.equalToSuperview() }

        addSubview(conditionTabBar_Lumia)
        conditionTabBar_Lumia.configure_Lumia(titles_Lumia: ExposureMath_Lumia.sunny16Conditions_Lumia.map { $0.0 })
        conditionTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.conditionIdx_Lumia = idx_Lumia; self?.updateResult_Lumia() }
        conditionTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(conditionTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        let isoTitle_Lumia = sectionLabel_Lumia("ISO")
        addSubview(isoTitle_Lumia)
        isoTitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(conditionTabBar_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview()
        }
        addSubview(isoTabBar_Lumia)
        isoTabBar_Lumia.configure_Lumia(titles_Lumia: ExposureScale_Lumia.isoValues_Lumia.map { ExposureMath_Lumia.formatISO_Lumia($0) }, selectedIndex_Lumia: isoIdx_Lumia)
        isoTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.isoIdx_Lumia = idx_Lumia; self?.updateResult_Lumia() }
        isoTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(isoTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        addSubview(resultCard_Lumia)
        resultCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(isoTabBar_Lumia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        resultCard_Lumia.addSubview(resultLabel_Lumia)
        resultLabel_Lumia.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview().inset(16) }
        resultCard_Lumia.addSubview(resultSubLabel_Lumia)
        resultSubLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(resultLabel_Lumia.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    private func updateResult_Lumia() {
        let (conditionName_Lumia, aperture_Lumia) = ExposureMath_Lumia.sunny16Conditions_Lumia[conditionIdx_Lumia]
        let iso_Lumia = ExposureScale_Lumia.isoValues_Lumia[isoIdx_Lumia]
        let shutter_Lumia = ExposureMath_Lumia.nearestStandardShutter_Lumia(1 / iso_Lumia)
        resultLabel_Lumia.text = "f/\(ExposureMath_Lumia.trim_Lumia(aperture_Lumia))  ·  \(ExposureMath_Lumia.formatShutter_Lumia(shutter_Lumia))  ·  ISO \(ExposureMath_Lumia.trim_Lumia(iso_Lumia))"
        resultSubLabel_Lumia.text = "\(conditionName_Lumia): meter-free baseline is shutter ≈ 1/ISO at the listed aperture."
    }
}

// MARK: - 闪光指数计算区块

/// 闪光指数（Guide Number）计算区块
/// 核心作用：在闪光指数 GN、闪光距离、光圈三者间互算，并根据 ISO 做感光度修正
private class FlashGNSection_Lumia: UIView {

    private let accent_Lumia: UIColor
    private let textColor_Lumia: UIColor

    private var solveForIdx_Lumia = 0 // 0=Aperture 1=Distance 2=Guide Number
    private var isoIdx_Lumia = 2

    private lazy var solveForTabBar_Lumia = PillTabBar_Lumia(gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7), unselectedTint_Lumia: accent_Lumia)
    private lazy var isoTabBar_Lumia = PillTabBar_Lumia(gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7), unselectedTint_Lumia: accent_Lumia)

    private let gnField_Lumia = FlashGNSection_Lumia.makeField_Lumia(placeholder_Lumia: "e.g. 32")
    private let distanceField_Lumia = FlashGNSection_Lumia.makeField_Lumia(placeholder_Lumia: "e.g. 4")
    private let apertureField_Lumia = FlashGNSection_Lumia.makeField_Lumia(placeholder_Lumia: "e.g. 8")

    private let gnLabel_Lumia = FlashGNSection_Lumia.makeFieldLabel_Lumia("Guide Number (GN)")
    private let distanceLabel_Lumia = FlashGNSection_Lumia.makeFieldLabel_Lumia("Distance (meters)")
    private let apertureLabel_Lumia = FlashGNSection_Lumia.makeFieldLabel_Lumia("Aperture (f-number)")

    private let calculateButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Calculate", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.layer.cornerRadius = 22
        return btn_Lumia
    }()

    private let resultLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl_Lumia.textColor = .white
        lbl_Lumia.numberOfLines = 0
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    init(accent_Lumia: UIColor, textColor_Lumia: UIColor) {
        self.accent_Lumia = accent_Lumia
        self.textColor_Lumia = textColor_Lumia
        super.init(frame: .zero)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private static func makeField_Lumia(placeholder_Lumia: String) -> UITextField {
        let tf_Lumia = UITextField()
        tf_Lumia.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        tf_Lumia.textColor = .white
        tf_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf_Lumia.layer.cornerRadius = 8
        tf_Lumia.keyboardType = .decimalPad
        tf_Lumia.attributedPlaceholder = NSAttributedString(string: placeholder_Lumia, attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.35)])
        let padding_Lumia = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf_Lumia.leftView = padding_Lumia
        tf_Lumia.leftViewMode = .always
        return tf_Lumia
    }

    private static func makeFieldLabel_Lumia(_ text_Lumia: String) -> UILabel {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = text_Lumia
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return lbl_Lumia
    }

    private func sectionLabel_Lumia(_ text_Lumia: String) -> UILabel {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = text_Lumia
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = textColor_Lumia.withAlphaComponent(0.55)
        return lbl_Lumia
    }

    private func setupUI_Lumia() {
        [gnLabel_Lumia, distanceLabel_Lumia, apertureLabel_Lumia].forEach { $0.textColor = textColor_Lumia }

        let solveTitle_Lumia = sectionLabel_Lumia("SOLVE FOR")
        addSubview(solveTitle_Lumia)
        solveTitle_Lumia.snp.makeConstraints { make in make.top.leading.equalToSuperview() }

        addSubview(solveForTabBar_Lumia)
        solveForTabBar_Lumia.configure_Lumia(titles_Lumia: ["Aperture", "Distance", "Guide Number"])
        solveForTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in
            self?.solveForIdx_Lumia = idx_Lumia
            self?.updateFieldStates_Lumia()
        }
        solveForTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(solveTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        addSubview(gnLabel_Lumia)
        gnLabel_Lumia.snp.makeConstraints { make in make.top.equalTo(solveForTabBar_Lumia.snp.bottom).offset(18); make.leading.equalToSuperview() }
        addSubview(gnField_Lumia)
        gnField_Lumia.snp.makeConstraints { make in make.top.equalTo(gnLabel_Lumia.snp.bottom).offset(6); make.leading.trailing.equalToSuperview(); make.height.equalTo(40) }

        addSubview(distanceLabel_Lumia)
        distanceLabel_Lumia.snp.makeConstraints { make in make.top.equalTo(gnField_Lumia.snp.bottom).offset(14); make.leading.equalToSuperview() }
        addSubview(distanceField_Lumia)
        distanceField_Lumia.snp.makeConstraints { make in make.top.equalTo(distanceLabel_Lumia.snp.bottom).offset(6); make.leading.trailing.equalToSuperview(); make.height.equalTo(40) }

        addSubview(apertureLabel_Lumia)
        apertureLabel_Lumia.snp.makeConstraints { make in make.top.equalTo(distanceField_Lumia.snp.bottom).offset(14); make.leading.equalToSuperview() }
        addSubview(apertureField_Lumia)
        apertureField_Lumia.snp.makeConstraints { make in make.top.equalTo(apertureLabel_Lumia.snp.bottom).offset(6); make.leading.trailing.equalToSuperview(); make.height.equalTo(40) }

        let isoTitle_Lumia = sectionLabel_Lumia("ISO (base 100)")
        addSubview(isoTitle_Lumia)
        isoTitle_Lumia.snp.makeConstraints { make in make.top.equalTo(apertureField_Lumia.snp.bottom).offset(18); make.leading.equalToSuperview() }
        addSubview(isoTabBar_Lumia)
        isoTabBar_Lumia.configure_Lumia(titles_Lumia: ExposureScale_Lumia.isoValues_Lumia.map { ExposureMath_Lumia.formatISO_Lumia($0) }, selectedIndex_Lumia: isoIdx_Lumia)
        isoTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in self?.isoIdx_Lumia = idx_Lumia }
        isoTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(isoTitle_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        calculateButton_Lumia.backgroundColor = accent_Lumia
        calculateButton_Lumia.addTarget(self, action: #selector(handleCalculate_Lumia), for: .touchUpInside)
        addSubview(calculateButton_Lumia)
        calculateButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(isoTabBar_Lumia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        addSubview(resultLabel_Lumia)
        resultLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(calculateButton_Lumia.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }

        updateFieldStates_Lumia()
    }

    /// 根据"求解目标"锁定对应输入框（求解项禁止手动输入）
    private func updateFieldStates_Lumia() {
        let fields_Lumia = [apertureField_Lumia, distanceField_Lumia, gnField_Lumia]
        for (idx_Lumia, field_Lumia) in fields_Lumia.enumerated() {
            let isSolveTarget_Lumia = idx_Lumia == solveForIdx_Lumia
            field_Lumia.isEnabled = !isSolveTarget_Lumia
            field_Lumia.alpha = isSolveTarget_Lumia ? 0.4 : 1.0
            field_Lumia.text = isSolveTarget_Lumia ? "" : field_Lumia.text
        }
    }

    @objc private func handleCalculate_Lumia() {
        let iso_Lumia = ExposureScale_Lumia.isoValues_Lumia[isoIdx_Lumia]
        let gn_Lumia = Double(gnField_Lumia.text ?? "") ?? 0
        let distance_Lumia = Double(distanceField_Lumia.text ?? "") ?? 0
        let aperture_Lumia = Double(apertureField_Lumia.text ?? "") ?? 0

        switch solveForIdx_Lumia {
        case 0:
            guard distance_Lumia > 0 else { showError_Lumia("Enter a valid distance."); return }
            let result_Lumia = ExposureMath_Lumia.apertureFromGN_Lumia(gn_Lumia: gn_Lumia, distance_Lumia: distance_Lumia, iso_Lumia: iso_Lumia)
            apertureField_Lumia.text = ExposureMath_Lumia.trim_Lumia(result_Lumia)
            resultLabel_Lumia.text = "Recommended Aperture: f/\(ExposureMath_Lumia.trim_Lumia(result_Lumia))"
        case 1:
            guard aperture_Lumia > 0 else { showError_Lumia("Enter a valid aperture."); return }
            let result_Lumia = ExposureMath_Lumia.distanceFromGN_Lumia(gn_Lumia: gn_Lumia, aperture_Lumia: aperture_Lumia, iso_Lumia: iso_Lumia)
            distanceField_Lumia.text = ExposureMath_Lumia.trim_Lumia(result_Lumia)
            resultLabel_Lumia.text = "Max Flash Distance: \(ExposureMath_Lumia.trim_Lumia(result_Lumia)) m"
        default:
            guard aperture_Lumia > 0, distance_Lumia > 0 else { showError_Lumia("Enter valid aperture and distance."); return }
            let result_Lumia = ExposureMath_Lumia.gnFromApertureDistance_Lumia(aperture_Lumia: aperture_Lumia, distance_Lumia: distance_Lumia, iso_Lumia: iso_Lumia)
            gnField_Lumia.text = ExposureMath_Lumia.trim_Lumia(result_Lumia)
            resultLabel_Lumia.text = "Guide Number: \(ExposureMath_Lumia.trim_Lumia(result_Lumia))"
        }
    }

    private func showError_Lumia(_ message_Lumia: String) {
        resultLabel_Lumia.text = message_Lumia
    }
}

// MARK: 曝光计算数学工具

/// 曝光计算数学工具
/// 核心作用：封装曝光三角、阳光十六法则、闪光指数计算所需的全部纯函数计算逻辑，与 UI 完全解耦
struct ExposureMath_Lumia {

    /// 阳光十六法则条件表 (条件描述, 推荐光圈值)
    static let sunny16Conditions_Lumia: [(String, Double)] = [
        ("Full Sun (f/16)", 16),
        ("Slight Overcast (f/11)", 11),
        ("Overcast (f/8)", 8),
        ("Heavy Overcast / Sunset (f/5.6)", 5.6)
    ]

    /// 格式化快门速度（秒）为常见摄影表示（如 "1/125" 或 "2\""）
    static func formatShutter_Lumia(_ seconds_Lumia: Double) -> String {
        if seconds_Lumia >= 1 {
            return "\(trim_Lumia(seconds_Lumia))\""
        }
        let denominator_Lumia = 1 / seconds_Lumia
        return "1/\(Int(denominator_Lumia.rounded()))"
    }

    /// 格式化光圈值为 "f/X" 形式
    static func formatAperture_Lumia(_ fNumber_Lumia: Double) -> String {
        return "f/\(trim_Lumia(fNumber_Lumia))"
    }

    /// 格式化 ISO 值
    static func formatISO_Lumia(_ iso_Lumia: Double) -> String {
        return "ISO \(trim_Lumia(iso_Lumia))"
    }

    /// 去除多余小数位（整数时不显示小数点）
    static func trim_Lumia(_ value_Lumia: Double) -> String {
        if value_Lumia == value_Lumia.rounded() {
            return String(Int(value_Lumia))
        }
        return String(format: "%.1f", value_Lumia)
    }

    /// 计算某一参数从旧值变到新值所引入的曝光级数变化（正值=进光量增加）
    static func stops_Lumia(paramIdx_Lumia: Int, from_Lumia: Double, to_Lumia: Double) -> Double {
        switch paramIdx_Lumia {
        case 0: return log2(to_Lumia / from_Lumia)                 // 快门：时间越长，进光越多
        case 1: return 2 * log2(from_Lumia / to_Lumia)              // 光圈：f 数越小，进光越多（每档 √2 倍）
        default: return log2(to_Lumia / from_Lumia)                 // ISO：感光度越高，等效进光越多
        }
    }

    /// 计算某一参数在补偿指定曝光级数后的新数值
    static func valueAfterStops_Lumia(paramIdx_Lumia: Int, base_Lumia: Double, stops_Lumia: Double) -> Double {
        switch paramIdx_Lumia {
        case 0: return base_Lumia * pow(2, stops_Lumia)
        case 1: return base_Lumia * pow(2, -stops_Lumia / 2)
        default: return base_Lumia * pow(2, stops_Lumia)
        }
    }

    /// 将任意快门时间吸附到最接近的标准快门级数
    static func nearestStandardShutter_Lumia(_ seconds_Lumia: Double) -> Double {
        return ExposureScale_Lumia.shutterSpeeds_Lumia.min(by: { abs($0 - seconds_Lumia) < abs($1 - seconds_Lumia) }) ?? seconds_Lumia
    }

    // MARK: - 闪光指数 GN 计算（GN = 光圈 × 距离，以 ISO 100 为基准，效果随 √(ISO/100) 缩放）

    private static func isoFactor_Lumia(_ iso_Lumia: Double) -> Double {
        return sqrt(iso_Lumia / 100)
    }

    /// 已知 GN 与距离，求推荐光圈
    static func apertureFromGN_Lumia(gn_Lumia: Double, distance_Lumia: Double, iso_Lumia: Double) -> Double {
        guard distance_Lumia > 0 else { return 0 }
        return (gn_Lumia * isoFactor_Lumia(iso_Lumia)) / distance_Lumia
    }

    /// 已知 GN 与光圈，求最大可用闪光距离
    static func distanceFromGN_Lumia(gn_Lumia: Double, aperture_Lumia: Double, iso_Lumia: Double) -> Double {
        guard aperture_Lumia > 0 else { return 0 }
        return (gn_Lumia * isoFactor_Lumia(iso_Lumia)) / aperture_Lumia
    }

    /// 已知光圈与距离，求所需闪光指数 GN
    static func gnFromApertureDistance_Lumia(aperture_Lumia: Double, distance_Lumia: Double, iso_Lumia: Double) -> Double {
        let factor_Lumia = isoFactor_Lumia(iso_Lumia)
        guard factor_Lumia > 0 else { return 0 }
        return (aperture_Lumia * distance_Lumia) / factor_Lumia
    }
}
