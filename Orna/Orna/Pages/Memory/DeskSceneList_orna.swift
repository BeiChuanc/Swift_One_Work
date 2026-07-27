import Foundation
import UIKit
import SnapKit

// MARK: - 自适应渐变背景容器

/// 自适应渐变背景容器视图
/// 核心作用：内部持有一个 CAGradientLayer，并在自身 layoutSubviews 中将其 frame 同步为自身 bounds。
/// 设计思路：CAGradientLayer 不受 Auto Layout 管理，若由父视图（甚至更上层的祖先视图）在其自身的
///           layoutSubviews 中反过来读取本视图的 bounds 来设置渐变 frame，在 UIStackView 等场景下
///           父视图的 layoutSubviews 可能先于本视图尺寸真正确定的时机被调用，导致读到 (0,0,0,0)。
///           因此渐变尺寸同步必须放在渐变所属视图"自己"的 layoutSubviews 中，才能保证时机正确。
private class GradientBackgroundView_Orna: UIView {

    /// 当前渐变图层（对外只读，通过 setColors_Orna 更新颜色）
    private let gradientLayer_Orna = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer_Orna.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Orna.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer_Orna, at: 0)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Orna.frame = bounds
    }

    /// 更新渐变颜色（两段色，左上到右下）
    /// 参数：
    /// - startHex_orna: 起始色十六进制
    /// - endHex_orna: 结束色十六进制
    func setColors_Orna(startHex_orna: String, endHex_orna: String) {
        gradientLayer_Orna.colors = [
            UIColor(hexstring_Orna: startHex_orna).cgColor,
            UIColor(hexstring_Orna: endHex_orna).cgColor
        ]
    }
}

// MARK: 桌面场景列表页

/// 桌面场景列表页视图控制器
/// 核心作用：集中管理用户创建的全部"桌面小场景"（迷你书房 / 海边角落 / 森林小屋），
///           支持创建新场景并进入自由摆放编辑器
/// 设计思路：
///   - 顶部返回按钮 + 标题 + 新建按钮
///   - 两列网格卡片：主题渐变缩略图 + 场景名称 + 元素数量，点击进入编辑器
///   - 空状态展示统一风格缺省态卡片，引导创建第一个场景
class DeskSceneList_Orna: UIViewController {

    // MARK: - 数据

    private var scenes_Orna: [DeskSceneModel_Orna] = []

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Desk Scenes"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let addButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "plus", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Orna: "#7B61FF")
        b.layer.cornerRadius = 18
        return b
    }()

    // MARK: - UI · 列表

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    private let gridRowsStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    private let emptyStateView_Orna: EmptyStateView_Orna = {
        let v = EmptyStateView_Orna()
        v.configure_Orna(
            icon_orna: "photo.stack.fill",
            title_orna: "No desk scenes yet",
            subtitle_orna: "Create a mini study, seaside corner or forest cabin and start arranging your memories."
        )
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        observeStateChanges_Orna()
        refreshList_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshList_Orna()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(backButton_Orna)
        view.addSubview(titleLabel_Orna)
        view.addSubview(addButton_Orna)
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)
        contentView_Orna.addSubview(gridRowsStack_Orna)
        contentView_Orna.addSubview(emptyStateView_Orna)
    }

    private func setupConstraints_Orna() {
        backButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.centerX.equalToSuperview()
        }
        addButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(36)
        }
        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(18)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        gridRowsStack_Orna.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        emptyStateView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        addButton_Orna.addTarget(self, action: #selector(handleAddTapped_Orna), for: .touchUpInside)
    }

    /// 监听用户状态变化，实时刷新场景列表
    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshList_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna,
            object: nil
        )
    }

    // MARK: - 数据刷新

    /// 重新拉取场景列表并以两列网格重建卡片
    @objc private func refreshList_Orna() {
        scenes_Orna = UserViewModel_Orna.shared_Orna.getDeskScenes_Orna()

        gridRowsStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyStateView_Orna.isHidden = !scenes_Orna.isEmpty
        gridRowsStack_Orna.isHidden = scenes_Orna.isEmpty

        guard !scenes_Orna.isEmpty else { return }

        var index_orna = 0
        while index_orna < scenes_Orna.count {
            let rowStack_orna = UIStackView()
            rowStack_orna.axis = .horizontal
            rowStack_orna.spacing = 14
            rowStack_orna.distribution = .fillEqually
            gridRowsStack_Orna.addArrangedSubview(rowStack_orna)

            for columnOffset_orna in 0..<2 {
                let sceneIndex_orna = index_orna + columnOffset_orna
                if sceneIndex_orna < scenes_Orna.count {
                    let scene_orna = scenes_Orna[sceneIndex_orna]
                    let card_orna = DeskSceneCardView_Orna()
                    card_orna.configure_Orna(scene_orna: scene_orna)
                    card_orna.onTap_Orna = { [weak self] in
                        self?.handleSceneTapped_Orna(scene_orna: scene_orna)
                    }
                    card_orna.onDelete_Orna = { [weak self] in
                        self?.handleDeleteTapped_Orna(scene_orna: scene_orna)
                    }
                    rowStack_orna.addArrangedSubview(card_orna)
                } else {
                    rowStack_orna.addArrangedSubview(UIView())
                }
            }
            index_orna += 2
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 弹出创建场景面板
    @objc private func handleAddTapped_Orna() {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }
        let sheet_orna = DeskSceneCreateSheet_Orna()
        sheet_orna.onCreated_Orna = { [weak self] scene_orna in
            self?.refreshList_Orna()
            if let scene_orna { Navigation_Orna.toDeskSceneEditor_Orna(with: scene_orna) }
        }
        present(sheet_orna, animated: true)
    }

    private func handleSceneTapped_Orna(scene_orna: DeskSceneModel_Orna) {
        Navigation_Orna.toDeskSceneEditor_Orna(with: scene_orna)
    }

    /// 删除场景二次确认
    private func handleDeleteTapped_Orna(scene_orna: DeskSceneModel_Orna) {
        let alert_orna = UIAlertController(
            title: "Delete \(scene_orna.sceneName_Orna)?",
            message: "This scene and everything placed inside it will be removed.",
            preferredStyle: .alert
        )
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_orna.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            UserViewModel_Orna.shared_Orna.deleteDeskScene_Orna(sceneId_orna: scene_orna.sceneId_Orna)
            self?.refreshList_Orna()
        })
        present(alert_orna, animated: true)
    }
}

// MARK: - 桌面场景卡片视图

/// 桌面场景卡片视图
/// 核心作用：以主题渐变缩略图呈现单个桌面场景，展示名称与已摆放元素数量
private class DeskSceneCardView_Orna: UIView {

    /// 点击回调（进入编辑器）
    var onTap_Orna: (() -> Void)?

    /// 删除回调
    var onDelete_Orna: (() -> Void)?

    private let cardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }()

    private let thumbnailView_Orna: GradientBackgroundView_Orna = {
        let v = GradientBackgroundView_Orna()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    private let themeIconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white.withAlphaComponent(0.9)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.numberOfLines = 1
        return l
    }()

    private let subtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let deleteButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 12
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        addSubview(cardView_Orna)
        cardView_Orna.addSubview(thumbnailView_Orna)
        thumbnailView_Orna.addSubview(themeIconView_Orna)
        thumbnailView_Orna.addSubview(deleteButton_Orna)
        cardView_Orna.addSubview(nameLabel_Orna)
        cardView_Orna.addSubview(subtitleLabel_Orna)

        cardView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        thumbnailView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(90)
        }
        themeIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        deleteButton_Orna.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(6)
            $0.width.height.equalTo(24)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(thumbnailView_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        subtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        cardView_Orna.addGestureRecognizer(tap_orna)
        cardView_Orna.isUserInteractionEnabled = true
        deleteButton_Orna.addTarget(self, action: #selector(handleDeleteTapped_Orna), for: .touchUpInside)
    }

    /// 配置场景展示内容
    func configure_Orna(scene_orna: DeskSceneModel_Orna) {
        let colors_orna = scene_orna.theme_Orna.backgroundColorHexes_Orna
        thumbnailView_Orna.setColors_Orna(startHex_orna: colors_orna.0, endHex_orna: colors_orna.1)

        themeIconView_Orna.image = UIImage(systemName: scene_orna.theme_Orna.themeIcon_Orna)
        nameLabel_Orna.text = scene_orna.sceneName_Orna
        subtitleLabel_Orna.text = "\(scene_orna.placedItems_Orna.count) item\(scene_orna.placedItems_Orna.count == 1 ? "" : "s") placed"
    }

    @objc private func handleTap_Orna() { onTap_Orna?() }
    @objc private func handleDeleteTapped_Orna() { onDelete_Orna?() }
}

// MARK: - 桌面场景创建面板

/// 桌面场景创建面板（以系统半屏 Sheet 呈现）
/// 核心作用：引导用户填写场景名称并选择预设主题（迷你书房 / 海边角落 / 森林小屋）
class DeskSceneCreateSheet_Orna: UIViewController {

    /// 创建成功回调（回传新场景，便于调用方直接跳转编辑器）
    var onCreated_Orna: ((DeskSceneModel_Orna?) -> Void)?

    private var selectedTheme_Orna: DeskSceneTheme_Orna = .study_Orna
    private var themeCells_Orna: [ThemeOptionCell_Orna] = []

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "New Desk Scene"
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let themeSectionLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Theme"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let themeStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private let nameSectionLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Scene Name"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let nameField_Orna: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = "e.g. My Cozy Study"
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 14
        return tf
    }()

    private let createButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Create Scene", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = UIColor(hexstring_Orna: "#7B61FF")
        b.layer.cornerRadius = 24
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let sheet_orna = sheetPresentationController {
            sheet_orna.detents = [.medium()]
            sheet_orna.prefersGrabberVisible = true
            sheet_orna.preferredCornerRadius = 24
        }
        setupUI_Orna()
        setupConstraints_Orna()
        buildThemeOptions_Orna()
        createButton_Orna.addTarget(self, action: #selector(handleCreateTapped_Orna), for: .touchUpInside)
    }

    private func setupUI_Orna() {
        view.addSubview(titleLabel_Orna)
        view.addSubview(themeSectionLabel_Orna)
        view.addSubview(themeStack_Orna)
        view.addSubview(nameSectionLabel_Orna)
        view.addSubview(nameField_Orna)
        view.addSubview(createButton_Orna)

        let leftPad_orna = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        nameField_Orna.leftView = leftPad_orna
        nameField_Orna.leftViewMode = .always
    }

    private func setupConstraints_Orna() {
        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        themeSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        themeStack_Orna.snp.makeConstraints {
            $0.top.equalTo(themeSectionLabel_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(90)
        }
        nameSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(themeStack_Orna.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        nameField_Orna.snp.makeConstraints {
            $0.top.equalTo(nameSectionLabel_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
        createButton_Orna.snp.makeConstraints {
            $0.top.equalTo(nameField_Orna.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
    }

    private func buildThemeOptions_Orna() {
        themeStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        themeCells_Orna.removeAll()
        for theme_orna in DeskSceneTheme_Orna.allCases {
            let cell_orna = ThemeOptionCell_Orna()
            cell_orna.configure_Orna(theme_orna: theme_orna, isSelected_orna: theme_orna == selectedTheme_Orna)
            cell_orna.onTap_Orna = { [weak self] in
                self?.selectedTheme_Orna = theme_orna
                self?.themeCells_Orna.forEach { $0.setSelected_Orna($0 === cell_orna) }
                self?.nameField_Orna.text = self?.nameField_Orna.text?.isEmpty == false ? self?.nameField_Orna.text : theme_orna.displayName_Orna
            }
            themeStack_Orna.addArrangedSubview(cell_orna)
            themeCells_Orna.append(cell_orna)
        }
    }

    /// 创建场景并回传给调用方，便于直接跳转编辑器
    @objc private func handleCreateTapped_Orna() {
        let name_orna = (nameField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let scene_orna = UserViewModel_Orna.shared_Orna.createDeskScene_Orna(
            sceneName_orna: name_orna.isEmpty ? selectedTheme_Orna.displayName_Orna : name_orna,
            theme_orna: selectedTheme_Orna
        )
        dismiss(animated: true) { [weak self] in
            self?.onCreated_Orna?(scene_orna)
        }
    }
}

// MARK: - 场景主题选项单元

/// 场景主题选项单元
/// 核心作用：以渐变方块 + 图标呈现单个场景主题，支持选中态描边高亮
private class ThemeOptionCell_Orna: UIView {

    /// 点击回调
    var onTap_Orna: (() -> Void)?

    private let containerView_Orna: GradientBackgroundView_Orna = {
        let v = GradientBackgroundView_Orna()
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.clear.cgColor
        v.clipsToBounds = true
        return v
    }()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        addSubview(containerView_Orna)
        containerView_Orna.addSubview(iconView_Orna)
        containerView_Orna.addSubview(nameLabel_Orna)

        containerView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        iconView_Orna.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(18)
            $0.width.height.equalTo(26)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(iconView_Orna.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(4)
        }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    /// 配置主题渐变背景、图标与初始选中态
    func configure_Orna(theme_orna: DeskSceneTheme_Orna, isSelected_orna: Bool) {
        let colors_orna = theme_orna.backgroundColorHexes_Orna
        containerView_Orna.setColors_Orna(startHex_orna: colors_orna.0, endHex_orna: colors_orna.1)

        iconView_Orna.image = UIImage(systemName: theme_orna.themeIcon_Orna)
        nameLabel_Orna.text = theme_orna.displayName_Orna
        setSelected_Orna(isSelected_orna)
    }

    /// 更新选中态描边
    func setSelected_Orna(_ isSelected_orna: Bool) {
        containerView_Orna.layer.borderColor = isSelected_orna
            ? UIColor(hexstring_Orna: "#2D2A3D").cgColor
            : UIColor.clear.cgColor
    }

    @objc private func handleTap_Orna() { onTap_Orna?() }
}
