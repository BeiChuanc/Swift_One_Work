import Foundation
import UIKit
import SnapKit

// MARK: - 胶片冲洗时长计算器页面

/// 胶片冲洗时长计算器页面
/// 核心作用：输入胶卷型号、药水类型、稀释比例、药水温度，自动输出显影/停显/定影时长；
///          支持将当前配方保存为本地记录，随时查看历史配方
/// 设计思路：
///   - 型号/药水/稀释比例均使用 PillTabBar_Lumia 选择，稀释比例随型号+药水联动刷新
///   - 温度使用滑块，实时按时间-温度换算公式重新计算三段时长
///   - 计算与持久化逻辑封装于 DevelopingRecipeViewModel_Lumia，与页面 UI 解耦
/// 关键属性：
///   - selectedFilmStock_Lumia / selectedDeveloper_Lumia / selectedDilution_Lumia: 当前选择
class DevelopingTimeCalculatorPage_Lumia: UIViewController {

    // MARK: - 私有属性

    private let viewModel_Lumia = DevelopingRecipeViewModel_Lumia.shared_Lumia

    private var selectedFilmStock_Lumia = DevelopingReferenceData_Lumia.filmStocks_Lumia.first ?? ""
    private var selectedDeveloper_Lumia = ""
    private var selectedDilution_Lumia = ""
    private var temperatureC_Lumia: Double = 20

    private let accent_Lumia = UIColor(hexstring_Lumia: "#3FA796")
    private let textColor_Lumia = UIColor.white.withAlphaComponent(0.85)

    private let backButton_Lumia = BackButton_Lumia()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Developing Time Calculator"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        return sv_Lumia
    }()

    private let contentStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 18
        return sv_Lumia
    }()

    private lazy var filmTabBar_Lumia = makeTabBar_Lumia()
    private lazy var developerTabBar_Lumia = makeTabBar_Lumia()
    private lazy var dilutionTabBar_Lumia = makeTabBar_Lumia()
    private lazy var temperatureRow_Lumia = LabeledSliderRow_Lumia(title_Lumia: "Chemical Temperature", titleColor_Lumia: textColor_Lumia, accentColor_Lumia: accent_Lumia)

    private let resultCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_Lumia.layer.cornerRadius = 14
        return v_Lumia
    }()
    private let developResultLabel_Lumia = DevelopingTimeCalculatorPage_Lumia.makeResultRow_Lumia()
    private let stopResultLabel_Lumia = DevelopingTimeCalculatorPage_Lumia.makeResultRow_Lumia()
    private let fixResultLabel_Lumia = DevelopingTimeCalculatorPage_Lumia.makeResultRow_Lumia()

    private let saveButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Save Recipe", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.layer.cornerRadius = 22
        return btn_Lumia
    }()

    private let savedListTitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "SAVED RECIPES"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.5)
        return lbl_Lumia
    }()

    private let savedListStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 8
        return sv_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#101A18")
        setupUI_Lumia()
        refreshDeveloperOptions_Lumia()
        reloadSavedRecipes_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UI设置

    private func makeTabBar_Lumia() -> PillTabBar_Lumia {
        return PillTabBar_Lumia(gradientStart_Lumia: accent_Lumia, gradientEnd_Lumia: accent_Lumia.withAlphaComponent(0.7), unselectedTint_Lumia: accent_Lumia)
    }

    private static func makeResultRow_Lumia() -> UILabel {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .bold)
        lbl_Lumia.textColor = .white
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
        view.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(72)
            make.trailing.equalToSuperview().offset(-20)
        }

        view.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Lumia)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

        scrollView_Lumia.addSubview(contentStack_Lumia)
        contentStack_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }

        contentStack_Lumia.addArrangedSubview(labeledSection_Lumia(title_Lumia: "FILM STOCK", tabBar_Lumia: filmTabBar_Lumia))
        contentStack_Lumia.addArrangedSubview(labeledSection_Lumia(title_Lumia: "DEVELOPER", tabBar_Lumia: developerTabBar_Lumia))
        contentStack_Lumia.addArrangedSubview(labeledSection_Lumia(title_Lumia: "DILUTION", tabBar_Lumia: dilutionTabBar_Lumia))

        filmTabBar_Lumia.configure_Lumia(titles_Lumia: DevelopingReferenceData_Lumia.filmStocks_Lumia)
        filmTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in
            self?.selectedFilmStock_Lumia = DevelopingReferenceData_Lumia.filmStocks_Lumia[idx_Lumia]
            self?.refreshDeveloperOptions_Lumia()
        }

        developerTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in
            guard let self = self else { return }
            self.selectedDeveloper_Lumia = self.availableDevelopers_Lumia()[idx_Lumia]
            self.refreshDilutionOptions_Lumia()
        }

        dilutionTabBar_Lumia.onSelected_Lumia = { [weak self] idx_Lumia in
            guard let self = self else { return }
            let options_Lumia = DevelopingReferenceData_Lumia.availableDilutions_Lumia(filmStock_Lumia: self.selectedFilmStock_Lumia, developer_Lumia: self.selectedDeveloper_Lumia)
            guard idx_Lumia < options_Lumia.count else { return }
            self.selectedDilution_Lumia = options_Lumia[idx_Lumia]
            self.updateResult_Lumia()
        }

        temperatureRow_Lumia.valueFormatter_Lumia = { value_Lumia in "\(Int(value_Lumia))°C" }
        temperatureRow_Lumia.configure_Lumia(minValue_Lumia: 15, maxValue_Lumia: 30, currentValue_Lumia: 20)
        temperatureRow_Lumia.onValueChanged_Lumia = { [weak self] value_Lumia in
            self?.temperatureC_Lumia = Double(value_Lumia)
            self?.updateResult_Lumia()
        }
        contentStack_Lumia.addArrangedSubview(labeledSection_Lumia(title_Lumia: "TEMPERATURE", tabBar_Lumia: nil, extraView_Lumia: temperatureRow_Lumia))

        resultCard_Lumia.addSubview(developResultLabel_Lumia)
        developResultLabel_Lumia.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview().inset(16) }
        resultCard_Lumia.addSubview(stopResultLabel_Lumia)
        stopResultLabel_Lumia.snp.makeConstraints { make in make.top.equalTo(developResultLabel_Lumia.snp.bottom).offset(10); make.leading.trailing.equalToSuperview().inset(16) }
        resultCard_Lumia.addSubview(fixResultLabel_Lumia)
        fixResultLabel_Lumia.snp.makeConstraints { make in make.top.equalTo(stopResultLabel_Lumia.snp.bottom).offset(10); make.leading.trailing.bottom.equalToSuperview().inset(16) }
        contentStack_Lumia.addArrangedSubview(resultCard_Lumia)

        saveButton_Lumia.backgroundColor = accent_Lumia
        saveButton_Lumia.addTarget(self, action: #selector(handleSaveRecipe_Lumia), for: .touchUpInside)
        contentStack_Lumia.addArrangedSubview(saveButton_Lumia)
        saveButton_Lumia.snp.makeConstraints { make in make.height.equalTo(44) }

        contentStack_Lumia.addArrangedSubview(savedListTitle_Lumia)
        contentStack_Lumia.addArrangedSubview(savedListStack_Lumia)
    }

    private func labeledSection_Lumia(title_Lumia: String, tabBar_Lumia: PillTabBar_Lumia?, extraView_Lumia: UIView? = nil) -> UIView {
        let container_Lumia = UIView()
        let label_Lumia = sectionLabel_Lumia(title_Lumia)
        container_Lumia.addSubview(label_Lumia)
        label_Lumia.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview() }

        if let tabBar_Lumia = tabBar_Lumia {
            container_Lumia.addSubview(tabBar_Lumia)
            tabBar_Lumia.snp.makeConstraints { make in
                make.top.equalTo(label_Lumia.snp.bottom).offset(8)
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(30)
            }
        } else if let extraView_Lumia = extraView_Lumia {
            container_Lumia.addSubview(extraView_Lumia)
            extraView_Lumia.snp.makeConstraints { make in
                make.top.equalTo(label_Lumia.snp.bottom).offset(8)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        return container_Lumia
    }

    // MARK: - 联动刷新

    private func availableDevelopers_Lumia() -> [String] {
        let developers_Lumia = DevelopingReferenceData_Lumia.timeTable_Lumia
            .filter { $0.filmStock_Lumia == selectedFilmStock_Lumia }
            .map { $0.developer_Lumia }
        var uniqueOrdered_Lumia: [String] = []
        for dev_Lumia in developers_Lumia where !uniqueOrdered_Lumia.contains(dev_Lumia) {
            uniqueOrdered_Lumia.append(dev_Lumia)
        }
        return uniqueOrdered_Lumia
    }

    private func refreshDeveloperOptions_Lumia() {
        let options_Lumia = availableDevelopers_Lumia()
        selectedDeveloper_Lumia = options_Lumia.first ?? ""
        developerTabBar_Lumia.configure_Lumia(titles_Lumia: options_Lumia)
        refreshDilutionOptions_Lumia()
    }

    private func refreshDilutionOptions_Lumia() {
        let options_Lumia = DevelopingReferenceData_Lumia.availableDilutions_Lumia(filmStock_Lumia: selectedFilmStock_Lumia, developer_Lumia: selectedDeveloper_Lumia)
        selectedDilution_Lumia = options_Lumia.first ?? ""
        dilutionTabBar_Lumia.configure_Lumia(titles_Lumia: options_Lumia)
        updateResult_Lumia()
    }

    // MARK: - 计算与展示

    private func updateResult_Lumia() {
        guard let entry_Lumia = DevelopingReferenceData_Lumia.lookup_Lumia(
            filmStock_Lumia: selectedFilmStock_Lumia, developer_Lumia: selectedDeveloper_Lumia, dilution_Lumia: selectedDilution_Lumia
        ) else {
            developResultLabel_Lumia.text = "Develop: --"
            stopResultLabel_Lumia.text = "Stop/Blix: --"
            fixResultLabel_Lumia.text = "Fix/Wash: --"
            return
        }
        let result_Lumia = viewModel_Lumia.computeTimes_Lumia(entry_Lumia: entry_Lumia, targetTempC_Lumia: temperatureC_Lumia)
        developResultLabel_Lumia.text = "🧪 Develop: \(DevelopingRecipeViewModel_Lumia.formatSeconds_Lumia(result_Lumia.developSeconds_Lumia))"
        stopResultLabel_Lumia.text = "⏸ Stop/Blix: \(DevelopingRecipeViewModel_Lumia.formatSeconds_Lumia(result_Lumia.stopSeconds_Lumia))"
        fixResultLabel_Lumia.text = "🧷 Fix/Wash: \(DevelopingRecipeViewModel_Lumia.formatSeconds_Lumia(result_Lumia.fixSeconds_Lumia))"
    }

    // MARK: - 保存配方

    @objc private func handleSaveRecipe_Lumia() {
        guard let entry_Lumia = DevelopingReferenceData_Lumia.lookup_Lumia(
            filmStock_Lumia: selectedFilmStock_Lumia, developer_Lumia: selectedDeveloper_Lumia, dilution_Lumia: selectedDilution_Lumia
        ) else { return }
        let result_Lumia = viewModel_Lumia.computeTimes_Lumia(entry_Lumia: entry_Lumia, targetTempC_Lumia: temperatureC_Lumia)
        viewModel_Lumia.saveRecipe_Lumia(
            filmStockName_Lumia: selectedFilmStock_Lumia, developerName_Lumia: selectedDeveloper_Lumia,
            dilution_Lumia: selectedDilution_Lumia, temperatureC_Lumia: temperatureC_Lumia,
            developTimeSec_Lumia: result_Lumia.developSeconds_Lumia, stopTimeSec_Lumia: result_Lumia.stopSeconds_Lumia,
            fixTimeSec_Lumia: result_Lumia.fixSeconds_Lumia
        )
        Utils_Lumia.showSuccess_Lumia(message_Lumia: "Recipe saved offline ✦")
        reloadSavedRecipes_Lumia()
    }

    private func reloadSavedRecipes_Lumia() {
        savedListStack_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let recipes_Lumia = viewModel_Lumia.getSavedRecipes_Lumia()
        if recipes_Lumia.isEmpty {
            let emptyLabel_Lumia = UILabel()
            emptyLabel_Lumia.text = "No saved recipes yet."
            emptyLabel_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            emptyLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.4)
            savedListStack_Lumia.addArrangedSubview(emptyLabel_Lumia)
            return
        }
        for recipe_Lumia in recipes_Lumia.reversed() {
            savedListStack_Lumia.addArrangedSubview(buildRecipeRow_Lumia(recipe_Lumia))
        }
    }

    private func buildRecipeRow_Lumia(_ recipe_Lumia: DevelopingRecipeModel_Lumia) -> UIView {
        let row_Lumia = UIView()
        row_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        row_Lumia.layer.cornerRadius = 10

        let titleLbl_Lumia = UILabel()
        titleLbl_Lumia.text = "\(recipe_Lumia.filmStockName_Lumia) · \(recipe_Lumia.developerName_Lumia) \(recipe_Lumia.dilution_Lumia)"
        titleLbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLbl_Lumia.textColor = .white
        titleLbl_Lumia.numberOfLines = 1
        row_Lumia.addSubview(titleLbl_Lumia)
        titleLbl_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }

        let subLbl_Lumia = UILabel()
        subLbl_Lumia.text = "\(Int(recipe_Lumia.temperatureC_Lumia))°C · Develop \(DevelopingRecipeViewModel_Lumia.formatSeconds_Lumia(recipe_Lumia.developTimeSec_Lumia))"
        subLbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subLbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.55)
        row_Lumia.addSubview(subLbl_Lumia)
        subLbl_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Lumia.snp.bottom).offset(3)
            make.leading.equalTo(titleLbl_Lumia)
            make.bottom.equalToSuperview().offset(-10)
        }

        let deleteBtn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        deleteBtn_Lumia.setImage(UIImage(systemName: "trash", withConfiguration: cfg_Lumia), for: .normal)
        deleteBtn_Lumia.tintColor = UIColor(hexstring_Lumia: "#E57373")
        row_Lumia.addSubview(deleteBtn_Lumia)
        deleteBtn_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        deleteBtn_Lumia.addAction(UIAction { [weak self] _ in
            self?.viewModel_Lumia.deleteRecipe_Lumia(recipeId_Lumia: recipe_Lumia.recipeId_Lumia)
            self?.reloadSavedRecipes_Lumia()
        }, for: .touchUpInside)

        return row_Lumia
    }
}

// MARK: 胶片冲洗配方 ViewModel

/// 胶片冲洗配方业务逻辑层
/// 核心作用：封装冲洗时长的时间-温度换算计算，以及用户自制配方的本地持久化
/// 设计思路：
///   - 时间-温度换算采用经验近似公式：温度每偏离参考温度 1℃，时长按约 11.5% 的比例反向缩放
///     （温度越高显影越快、时间越短；温度越低则时间越长），公式为 baseTime × 0.885^(Δ温度)
///   - 自制配方以 Codable JSON 形式存入 UserDefaults，纯本地存储，不依赖网络
@MainActor
class DevelopingRecipeViewModel_Lumia {

    static let shared_Lumia = DevelopingRecipeViewModel_Lumia()

    private static let recipesKey_Lumia = "DevelopingRecipeViewModel_SavedRecipes_Lumia"
    private static let nextIdKey_Lumia = "DevelopingRecipeViewModel_NextId_Lumia"

    /// 单次计算的三段时长结果（单位：秒）
    struct TimeResult_Lumia {
        let developSeconds_Lumia: Int
        let stopSeconds_Lumia: Int
        let fixSeconds_Lumia: Int
    }

    private init() {}

    /// 依据基准数据与目标温度计算显影/停显/定影时长（停显/定影时长不受温度补偿，仅显影时长换算）
    func computeTimes_Lumia(entry_Lumia: DevelopingTimeEntry_Lumia, targetTempC_Lumia: Double) -> TimeResult_Lumia {
        let deltaC_Lumia = targetTempC_Lumia - entry_Lumia.referenceTempC_Lumia
        let compensationFactor_Lumia = pow(0.885, deltaC_Lumia)
        let developSeconds_Lumia = Int((entry_Lumia.developMinutes_Lumia * 60 * compensationFactor_Lumia).rounded())
        let fixSeconds_Lumia = Int(entry_Lumia.fixMinutes_Lumia * 60)
        return TimeResult_Lumia(developSeconds_Lumia: developSeconds_Lumia, stopSeconds_Lumia: entry_Lumia.stopSeconds_Lumia, fixSeconds_Lumia: fixSeconds_Lumia)
    }

    /// 格式化秒数为 "mm:ss"
    static func formatSeconds_Lumia(_ totalSeconds_Lumia: Int) -> String {
        let minutes_Lumia = max(0, totalSeconds_Lumia) / 60
        let seconds_Lumia = max(0, totalSeconds_Lumia) % 60
        return String(format: "%d:%02d", minutes_Lumia, seconds_Lumia)
    }

    // MARK: - 自制配方持久化

    func getSavedRecipes_Lumia() -> [DevelopingRecipeModel_Lumia] {
        guard let data_Lumia = UserDefaults.standard.data(forKey: Self.recipesKey_Lumia),
              let decoded_Lumia = try? JSONDecoder().decode([DevelopingRecipeModel_Lumia].self, from: data_Lumia) else { return [] }
        return decoded_Lumia
    }

    @discardableResult
    func saveRecipe_Lumia(
        filmStockName_Lumia: String, developerName_Lumia: String, dilution_Lumia: String,
        temperatureC_Lumia: Double, developTimeSec_Lumia: Int, stopTimeSec_Lumia: Int, fixTimeSec_Lumia: Int
    ) -> DevelopingRecipeModel_Lumia {
        var recipes_Lumia = getSavedRecipes_Lumia()
        let nextId_Lumia = UserDefaults.standard.integer(forKey: Self.nextIdKey_Lumia)
        let newId_Lumia = max(nextId_Lumia, 1)
        let recipe_Lumia = DevelopingRecipeModel_Lumia(
            recipeId_Lumia: newId_Lumia, filmStockName_Lumia: filmStockName_Lumia, developerName_Lumia: developerName_Lumia,
            dilution_Lumia: dilution_Lumia, temperatureC_Lumia: temperatureC_Lumia,
            developTimeSec_Lumia: developTimeSec_Lumia, stopTimeSec_Lumia: stopTimeSec_Lumia, fixTimeSec_Lumia: fixTimeSec_Lumia
        )
        recipes_Lumia.append(recipe_Lumia)
        UserDefaults.standard.set(newId_Lumia + 1, forKey: Self.nextIdKey_Lumia)
        persist_Lumia(recipes_Lumia)
        return recipe_Lumia
    }

    func deleteRecipe_Lumia(recipeId_Lumia: Int) {
        var recipes_Lumia = getSavedRecipes_Lumia()
        recipes_Lumia.removeAll { $0.recipeId_Lumia == recipeId_Lumia }
        persist_Lumia(recipes_Lumia)
    }

    private func persist_Lumia(_ recipes_Lumia: [DevelopingRecipeModel_Lumia]) {
        guard let data_Lumia = try? JSONEncoder().encode(recipes_Lumia) else { return }
        UserDefaults.standard.set(data_Lumia, forKey: Self.recipesKey_Lumia)
    }
}
