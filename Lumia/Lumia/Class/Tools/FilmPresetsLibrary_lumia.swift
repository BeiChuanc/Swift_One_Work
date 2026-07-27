import Foundation
import UIKit
import SnapKit

// MARK: - 胶片预设离线库页面

/// 胶片预设离线库页面
/// 核心作用：浏览柯达/富士/伊尔福/爱克发/宝丽来/乐凯等品牌的彩负/反转/黑白胶片预设，
///          按日光/室内/人像/风光/复古港风/日系/颗粒风分类筛选；支持标记"离线缓存"状态，
///          支持删除自制配方；点击预设可选取照片预览应用效果
/// 设计思路：
///   - 顶部悬浮返回按钮 + 标题，风格与其他二级页面一致
///   - PillTabBar_Lumia 承载分类筛选（All + 七大分类）
///   - 列表以行样式展示每个预设：品牌/胶卷名、类型、分类标签、离线缓存开关
/// 关键属性：
///   - viewModel_Lumia: 胶片预设业务逻辑层，负责预制+自制数据的读取与持久化
class FilmPresetsLibraryPage_Lumia: UIViewController {

    // MARK: - 私有属性

    private let viewModel_Lumia = FilmPresetsViewModel_Lumia.shared_Lumia
    private var allPresets_Lumia: [FilmPresetModel_Lumia] = []
    private var filteredPresets_Lumia: [FilmPresetModel_Lumia] = []
    private var currentCategoryFilter_Lumia: String = "All"

    private let backButton_Lumia = BackButton_Lumia()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Film Presets Library"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Cached offline · no network required"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.65)
        return lbl_Lumia
    }()

    private lazy var categoryTabBar_Lumia = PillTabBar_Lumia(
        gradientStart_Lumia: UIColor(hexstring_Lumia: "#F6A623"),
        gradientEnd_Lumia: UIColor(hexstring_Lumia: "#D4654E"),
        unselectedTint_Lumia: UIColor(hexstring_Lumia: "#8A7060")
    )

    private let tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .plain)
        tv_Lumia.backgroundColor = .clear
        tv_Lumia.separatorStyle = .none
        tv_Lumia.showsVerticalScrollIndicator = false
        tv_Lumia.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        return tv_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#1C1410")
        setupUI_Lumia()
        setupObservers_Lumia()
        reloadData_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(72)
            make.trailing.equalToSuperview().offset(-20)
        }

        view.addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(2)
            make.leading.trailing.equalTo(titleLabel_Lumia)
        }

        view.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Lumia)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        view.addSubview(categoryTabBar_Lumia)
        categoryTabBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        let categoryTitles_Lumia = ["All"] + FilmPresetCategory_Lumia.allCases.map { $0.rawValue }
        categoryTabBar_Lumia.configure_Lumia(titles_Lumia: categoryTitles_Lumia)
        categoryTabBar_Lumia.onSelected_Lumia = { [weak self] index_Lumia in
            self?.currentCategoryFilter_Lumia = categoryTitles_Lumia[index_Lumia]
            self?.applyFilter_Lumia()
        }

        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(categoryTabBar_Lumia.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(FilmPresetRowCell_Lumia.self, forCellReuseIdentifier: FilmPresetRowCell_Lumia.reuseId_Lumia)
    }

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handlePresetsChange_Lumia),
            name: FilmPresetsViewModel_Lumia.presetsDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handlePresetsChange_Lumia() { reloadData_Lumia() }

    // MARK: - 数据

    private func reloadData_Lumia() {
        allPresets_Lumia = viewModel_Lumia.getAllPresets_Lumia()
        applyFilter_Lumia()
    }

    private func applyFilter_Lumia() {
        if currentCategoryFilter_Lumia == "All" {
            filteredPresets_Lumia = allPresets_Lumia
        } else {
            filteredPresets_Lumia = allPresets_Lumia.filter { $0.category_Lumia.rawValue == currentCategoryFilter_Lumia }
        }
        tableView_Lumia.reloadData()
    }

    // MARK: - 事件处理

    /// 点击预设：选取一张照片后跳转手动调节面板，以该预设参数为初始值预览/继续微调
    private func handlePresetTapped_Lumia(_ preset_Lumia: FilmPresetModel_Lumia) {
        MediaPickerHelper_Lumia.pickImage_Lumia(from: self) { [weak self] image_Lumia in
            guard let self = self, let image_Lumia = image_Lumia else { return }
            let panel_Lumia = FilmAdjustmentPanelPage_Lumia(
                sourceImage_Lumia: image_Lumia,
                initialParams_Lumia: preset_Lumia.params_Lumia
            )
            Navigation_Lumia.push_Lumia(to: panel_Lumia, from: self)
        }
    }

    private func handleToggleCached_Lumia(_ preset_Lumia: FilmPresetModel_Lumia, isCached_Lumia: Bool) {
        viewModel_Lumia.setCached_Lumia(presetId_Lumia: preset_Lumia.presetId_Lumia, isCached_Lumia: isCached_Lumia)
    }

    private func handleDeleteCustom_Lumia(_ preset_Lumia: FilmPresetModel_Lumia) {
        let alert_Lumia = UIAlertController(
            title: "Delete Recipe",
            message: "Permanently delete your custom recipe '\(preset_Lumia.filmName_Lumia)'?",
            preferredStyle: .alert
        )
        alert_Lumia.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel_Lumia.deleteCustomPreset_Lumia(presetId_Lumia: preset_Lumia.presetId_Lumia)
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension FilmPresetsLibraryPage_Lumia: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPresets_Lumia.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 76 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = tableView.dequeueReusableCell(withIdentifier: FilmPresetRowCell_Lumia.reuseId_Lumia, for: indexPath) as! FilmPresetRowCell_Lumia
        let preset_Lumia = filteredPresets_Lumia[indexPath.row]
        cell_Lumia.configure_Lumia(preset: preset_Lumia)
        cell_Lumia.onCachedToggled_Lumia = { [weak self] isCached_Lumia in
            self?.handleToggleCached_Lumia(preset_Lumia, isCached_Lumia: isCached_Lumia)
        }
        cell_Lumia.onDeleteTapped_Lumia = { [weak self] in
            self?.handleDeleteCustom_Lumia(preset_Lumia)
        }
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handlePresetTapped_Lumia(filteredPresets_Lumia[indexPath.row])
    }
}

// MARK: - 预设行 Cell

/// 胶片预设列表行 Cell
/// 核心作用：展示单个预设的品牌/名称/分类/类型，提供离线缓存开关；自制配方额外展示删除按钮
private class FilmPresetRowCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "FilmPresetRowCell_Lumia"

    var onCachedToggled_Lumia: ((Bool) -> Void)?
    var onDeleteTapped_Lumia: (() -> Void)?

    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#2A2018")
        v_Lumia.layer.cornerRadius = 14
        return v_Lumia
    }()

    private let iconBg_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 20
        return v_Lumia
    }()

    private let iconView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView(image: UIImage(systemName: "camera.filters"))
        iv_Lumia.tintColor = .white
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let nameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let tagLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C0A88C")
        return lbl_Lumia
    }()

    private let cachedSwitch_Lumia: UISwitch = {
        let sw_Lumia = UISwitch()
        sw_Lumia.onTintColor = UIColor(hexstring_Lumia: "#F6A623")
        sw_Lumia.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return sw_Lumia
    }()

    private let deleteButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "trash", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#E57373")
        btn_Lumia.isHidden = true
        return btn_Lumia
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        cardView_Lumia.addSubview(iconBg_Lumia)
        iconBg_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        iconBg_Lumia.addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        cardView_Lumia.addSubview(cachedSwitch_Lumia)
        cachedSwitch_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        cachedSwitch_Lumia.addTarget(self, action: #selector(handleSwitchChanged_Lumia), for: .valueChanged)

        cardView_Lumia.addSubview(deleteButton_Lumia)
        deleteButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalTo(cachedSwitch_Lumia.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        deleteButton_Lumia.addTarget(self, action: #selector(handleDelete_Lumia), for: .touchUpInside)

        cardView_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Lumia.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(14)
            make.trailing.lessThanOrEqualTo(deleteButton_Lumia.snp.leading).offset(-8)
        }

        cardView_Lumia.addSubview(tagLabel_Lumia)
        tagLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_Lumia)
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualTo(deleteButton_Lumia.snp.leading).offset(-8)
        }
    }

    func configure_Lumia(preset: FilmPresetModel_Lumia) {
        nameLabel_Lumia.text = "\(preset.brand_Lumia)  \(preset.filmName_Lumia)"
        tagLabel_Lumia.text = "\(preset.category_Lumia.rawValue) · \(preset.stockType_Lumia.rawValue)"
        cachedSwitch_Lumia.isOn = preset.isCached_Lumia
        deleteButton_Lumia.isHidden = !preset.isCustom_Lumia

        let iconColor_Lumia: UIColor
        switch preset.stockType_Lumia {
        case .colorNegative_Lumia: iconColor_Lumia = UIColor(hexstring_Lumia: "#D4654E")
        case .slide_Lumia: iconColor_Lumia = UIColor(hexstring_Lumia: "#7B5CD6")
        case .blackWhite_Lumia: iconColor_Lumia = UIColor(hexstring_Lumia: "#8A8A8A")
        }
        iconBg_Lumia.backgroundColor = iconColor_Lumia.withAlphaComponent(0.85)
    }

    @objc private func handleSwitchChanged_Lumia() {
        onCachedToggled_Lumia?(cachedSwitch_Lumia.isOn)
    }

    @objc private func handleDelete_Lumia() {
        onDeleteTapped_Lumia?()
    }
}

// MARK: 胶片预设 ViewModel

/// 胶片预设业务逻辑层
/// 核心作用：统一管理预制品牌胶片预设与用户自制配方，负责离线缓存标记与自制配方的本地持久化
/// 设计思路：
///   - 预制预设来自 LocalData_Lumia.filmPresetList_Lumia，首次读取时与本地持久化的自制配方合并为内存缓存
///   - 自制配方 + 缓存标记均通过 UserDefaults 以 Codable JSON 形式本地存储，不联网、不依赖服务器
/// 关键属性：
///   - presets_Lumia: 内存中的全量预设缓存（预制 + 自制）
@MainActor
class FilmPresetsViewModel_Lumia {

    static let shared_Lumia = FilmPresetsViewModel_Lumia()

    /// 预设数据变更通知（缓存标记切换/新增自制/删除自制后触发）
    static let presetsDidChangeNotification_Lumia = Notification.Name("FilmPresetsDidChange_Lumia")

    private static let customPresetsKey_Lumia = "FilmPresetsViewModel_CustomPresets_Lumia"
    private static let cachedIdsKey_Lumia = "FilmPresetsViewModel_CachedIds_Lumia"
    private static let nextCustomIdKey_Lumia = "FilmPresetsViewModel_NextCustomId_Lumia"

    private var presets_Lumia: [FilmPresetModel_Lumia] = []
    private var isLoaded_Lumia = false

    private init() {}

    /// 获取全量预设（预制 + 自制），首次调用时惰性加载并与本地持久化数据合并
    func getAllPresets_Lumia() -> [FilmPresetModel_Lumia] {
        if !isLoaded_Lumia {
            loadPresets_Lumia()
        }
        return presets_Lumia
    }

    /// 设置指定预设的离线缓存标记状态并持久化
    func setCached_Lumia(presetId_Lumia: Int, isCached_Lumia: Bool) {
        guard let idx_Lumia = presets_Lumia.firstIndex(where: { $0.presetId_Lumia == presetId_Lumia }) else { return }
        presets_Lumia[idx_Lumia].isCached_Lumia = isCached_Lumia
        persistCachedIds_Lumia()
        notifyChange_Lumia()
    }

    /// 保存一份用户自制配方
    /// - Parameters:
    ///   - filmName_Lumia: 自制配方名称
    ///   - stockType_Lumia: 胶片类型
    ///   - category_Lumia: 场景分类
    ///   - params_Lumia: 调节参数
    /// - Returns: 新创建的预设模型
    @discardableResult
    func saveCustomPreset_Lumia(
        filmName_Lumia: String, stockType_Lumia: FilmStockType_Lumia,
        category_Lumia: FilmPresetCategory_Lumia, params_Lumia: FilmAdjustmentParams_Lumia
    ) -> FilmPresetModel_Lumia {
        if !isLoaded_Lumia { loadPresets_Lumia() }
        let nextId_Lumia = UserDefaults.standard.integer(forKey: Self.nextCustomIdKey_Lumia)
        let newId_Lumia = max(nextId_Lumia, 9000)
        let preset_Lumia = FilmPresetModel_Lumia(
            presetId_Lumia: newId_Lumia, brand_Lumia: "Custom", filmName_Lumia: filmName_Lumia,
            stockType_Lumia: stockType_Lumia, category_Lumia: category_Lumia,
            params_Lumia: params_Lumia, isCustom_Lumia: true, isCached_Lumia: true
        )
        presets_Lumia.append(preset_Lumia)
        UserDefaults.standard.set(newId_Lumia + 1, forKey: Self.nextCustomIdKey_Lumia)
        persistCustomPresets_Lumia()
        notifyChange_Lumia()
        return preset_Lumia
    }

    /// 删除指定自制配方
    func deleteCustomPreset_Lumia(presetId_Lumia: Int) {
        presets_Lumia.removeAll { $0.presetId_Lumia == presetId_Lumia && $0.isCustom_Lumia }
        persistCustomPresets_Lumia()
        notifyChange_Lumia()
    }

    // MARK: - 私有方法：加载与持久化

    private func loadPresets_Lumia() {
        var merged_Lumia = LocalData_Lumia.shared_Lumia.filmPresetList_Lumia
        merged_Lumia.append(contentsOf: loadCustomPresets_Lumia())

        let cachedOffIds_Lumia = Set(UserDefaults.standard.array(forKey: Self.cachedIdsKey_Lumia) as? [Int] ?? [])
        for preset_Lumia in merged_Lumia where cachedOffIds_Lumia.contains(preset_Lumia.presetId_Lumia) {
            preset_Lumia.isCached_Lumia = false
        }

        presets_Lumia = merged_Lumia
        isLoaded_Lumia = true
    }

    private func loadCustomPresets_Lumia() -> [FilmPresetModel_Lumia] {
        guard let data_Lumia = UserDefaults.standard.data(forKey: Self.customPresetsKey_Lumia),
              let decoded_Lumia = try? JSONDecoder().decode([FilmPresetModel_Lumia].self, from: data_Lumia) else { return [] }
        return decoded_Lumia
    }

    private func persistCustomPresets_Lumia() {
        let custom_Lumia = presets_Lumia.filter { $0.isCustom_Lumia }
        guard let data_Lumia = try? JSONEncoder().encode(custom_Lumia) else { return }
        UserDefaults.standard.set(data_Lumia, forKey: Self.customPresetsKey_Lumia)
    }

    /// 持久化"已取消离线缓存"的预设ID集合（预制预设默认即为已缓存，仅记录被手动取消的部分）
    private func persistCachedIds_Lumia() {
        let offIds_Lumia = presets_Lumia.filter { !$0.isCached_Lumia }.map { $0.presetId_Lumia }
        UserDefaults.standard.set(offIds_Lumia, forKey: Self.cachedIdsKey_Lumia)
    }

    private func notifyChange_Lumia() {
        NotificationCenter.default.post(name: Self.presetsDidChangeNotification_Lumia, object: nil)
    }
}
