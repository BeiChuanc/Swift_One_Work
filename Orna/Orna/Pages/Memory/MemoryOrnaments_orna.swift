import Foundation
import UIKit
import SnapKit

// MARK: 记忆摆件列表页

/// 记忆摆件列表页视图控制器
/// 核心作用：集中展示当前用户创建的全部"纪念日摆件"与"人物信物摆件"，
///           支持按分类筛选、查看成长状态、进入详情记录记忆，并可创建新摆件
/// 设计思路：
///   - 顶部返回按钮 + 标题 + 新建按钮，风格与设置页/编辑资料页保持一致
///   - 分段控件切换 "Anniversaries" / "People" 两个分类
///   - 纵向卡片列表：圆形成长图标（纪念日临近时带微光光环）+ 名称 + 成长阶段/倒计时描述 + 删除入口
///   - 列表为空时展示统一风格的缺省态卡片
/// 关键方法：
///   - refreshList_Orna: 按当前分类重新拉取数据并刷新卡片列表
class MemoryOrnaments_Orna: UIViewController {

    // MARK: - 数据

    /// 当前选中分类（0: 纪念日摆件, 1: 人物信物摆件）
    private var selectedSegment_Orna: Int = 0

    private var displayedOrnaments_Orna: [MemoryOrnamentModel_Orna] = []

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
        l.text = "Memory Ornaments"
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

    // MARK: - UI · 分段与列表

    private let segmentControl_Orna = PillSegmentControl_Orna(titles_Orna: ["Anniversaries", "People"])

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    private let cardsStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()

    private let emptyStateView_Orna: EmptyStateView_Orna = {
        let v = EmptyStateView_Orna()
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
        view.addSubview(segmentControl_Orna)
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)
        contentView_Orna.addSubview(cardsStack_Orna)
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
        segmentControl_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(segmentControl_Orna.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        cardsStack_Orna.snp.makeConstraints {
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
        segmentControl_Orna.onSelectionChanged_Orna = { [weak self] index_orna in
            self?.selectedSegment_Orna = index_orna
            self?.refreshList_Orna()
        }
    }

    /// 监听用户状态变化，实时刷新列表（创建/删除摆件、新增记忆记录后同步更新）
    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshList_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna,
            object: nil
        )
    }

    // MARK: - 数据刷新

    /// 按当前分类重新拉取记忆摆件并重建卡片列表
    @objc private func refreshList_Orna() {
        let allOrnaments_orna = UserViewModel_Orna.shared_Orna.getMemoryOrnaments_Orna()
        displayedOrnaments_Orna = allOrnaments_orna.filter {
            selectedSegment_Orna == 0 ? $0.kind_Orna.isAnniversaryType_Orna : !$0.kind_Orna.isAnniversaryType_Orna
        }

        cardsStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyStateView_Orna.isHidden = !displayedOrnaments_Orna.isEmpty
        cardsStack_Orna.isHidden = displayedOrnaments_Orna.isEmpty

        if displayedOrnaments_Orna.isEmpty {
            emptyStateView_Orna.configure_Orna(
                icon_orna: selectedSegment_Orna == 0 ? "gift.fill" : "person.2.fill",
                title_orna: selectedSegment_Orna == 0 ? "No anniversaries yet" : "No person tokens yet",
                subtitle_orna: "Tap + to create a memory ornament and start recording moments that matter."
            )
            return
        }

        for ornament_orna in displayedOrnaments_Orna {
            let row_orna = MemoryOrnamentRowView_Orna()
            row_orna.configure_Orna(ornament_orna: ornament_orna)
            row_orna.onTap_Orna = { [weak self] in
                self?.handleRowTapped_Orna(ornament_orna: ornament_orna)
            }
            row_orna.onDelete_Orna = { [weak self] in
                self?.handleDeleteTapped_Orna(ornament_orna: ornament_orna)
            }
            cardsStack_Orna.addArrangedSubview(row_orna)
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 点击新建按钮：弹出记忆摆件创建面板
    @objc private func handleAddTapped_Orna() {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }
        let sheet_orna = MemoryOrnamentCreateSheet_Orna()
        sheet_orna.onCreated_Orna = { [weak self] in
            self?.refreshList_Orna()
        }
        present(sheet_orna, animated: true)
    }

    private func handleRowTapped_Orna(ornament_orna: MemoryOrnamentModel_Orna) {
        Navigation_Orna.toMemoryOrnamentDetail_Orna(with: ornament_orna)
    }

    /// 删除摆件二次确认
    private func handleDeleteTapped_Orna(ornament_orna: MemoryOrnamentModel_Orna) {
        let alert_orna = UIAlertController(
            title: "Delete \(ornament_orna.customName_Orna)?",
            message: "All memories recorded for this ornament will be removed. This cannot be undone.",
            preferredStyle: .alert
        )
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_orna.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            UserViewModel_Orna.shared_Orna.deleteMemoryOrnament_Orna(ornamentId_orna: ornament_orna.ornamentId_Orna)
            self?.refreshList_Orna()
        })
        present(alert_orna, animated: true)
    }
}

// MARK: - 记忆摆件列表行视图

/// 记忆摆件列表行视图
/// 核心作用：以白色圆角卡片呈现单个记忆摆件的成长图标、名称、状态描述与删除入口
private class MemoryOrnamentRowView_Orna: UIView {

    /// 点击整行回调（进入详情）
    var onTap_Orna: (() -> Void)?

    /// 点击删除回调
    var onDelete_Orna: (() -> Void)?

    private let cardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }()

    private let glowRingView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 27
        v.layer.borderWidth = 2
        v.isHidden = true
        return v
    }()

    private let circleView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        return v
    }()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let subtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let deleteButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "trash"), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#C7C2DB")
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        addSubview(cardView_Orna)
        cardView_Orna.addSubview(glowRingView_Orna)
        cardView_Orna.addSubview(circleView_Orna)
        circleView_Orna.addSubview(iconView_Orna)
        cardView_Orna.addSubview(nameLabel_Orna)
        cardView_Orna.addSubview(subtitleLabel_Orna)
        cardView_Orna.addSubview(deleteButton_Orna)

        cardView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        glowRingView_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(13)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(54)
        }
        circleView_Orna.snp.makeConstraints {
            $0.center.equalTo(glowRingView_Orna)
            $0.width.height.equalTo(48)
        }
        iconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(22)
        }
        deleteButton_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(glowRingView_Orna.snp.trailing).offset(14)
            $0.trailing.equalTo(deleteButton_Orna.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(16)
        }
        subtitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(nameLabel_Orna)
            $0.trailing.equalTo(deleteButton_Orna.snp.leading).offset(-8)
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(3)
            $0.bottom.equalToSuperview().offset(-16)
        }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        cardView_Orna.addGestureRecognizer(tap_orna)
        cardView_Orna.isUserInteractionEnabled = true
        deleteButton_Orna.addTarget(self, action: #selector(handleDeleteTapped_Orna), for: .touchUpInside)
    }

    /// 配置摆件展示内容
    func configure_Orna(ornament_orna: MemoryOrnamentModel_Orna) {
        let colorHex_orna = ornament_orna.colorHex_Orna
        circleView_Orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(0.2)
        iconView_Orna.image = UIImage(systemName: ornament_orna.currentGrowthIcon_Orna)
        iconView_Orna.tintColor = UIColor(hexstring_Orna: colorHex_orna)
        nameLabel_Orna.text = ornament_orna.customName_Orna
        glowRingView_Orna.isHidden = !ornament_orna.isGlowingNearAnniversary_Orna
        glowRingView_Orna.layer.borderColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(0.7).cgColor

        var parts_orna: [String] = [ornament_orna.growthStageName_Orna]
        if ornament_orna.kind_Orna.isAnniversaryType_Orna {
            if let years_orna = ornament_orna.anniversaryYearsCount_Orna, years_orna > 0 {
                parts_orna.append("\(years_orna)y together")
            }
            if let days_orna = ornament_orna.daysUntilNextAnniversary_Orna {
                parts_orna.append(days_orna == 0 ? "Today! ✨" : "\(days_orna)d until anniversary")
            }
        } else {
            if let name_orna = ornament_orna.personName_Orna, !name_orna.isEmpty {
                parts_orna.append(name_orna)
            }
            parts_orna.append("\(ornament_orna.entries_Orna.count) memories")
        }
        subtitleLabel_Orna.text = parts_orna.joined(separator: " · ")
    }

    @objc private func handleTap_Orna() { onTap_Orna?() }
    @objc private func handleDeleteTapped_Orna() { onDelete_Orna?() }
}

// MARK: - 记忆摆件创建面板

/// 记忆摆件创建面板（以系统半屏 Sheet 呈现）
/// 核心作用：引导用户选择摆件类型、填写名称与关键信息（纪念日日期 / 人物关系），创建后立即可开始记录记忆
class MemoryOrnamentCreateSheet_Orna: UIViewController {

    /// 创建成功回调
    var onCreated_Orna: (() -> Void)?

    // MARK: - 数据

    private var selectedKind_Orna: MemoryOrnamentKind_Orna = .loveAnniversary_Orna
    private var selectedColorHex_Orna: String = MemoryOrnamentKind_Orna.loveAnniversary_Orna.defaultColorHex_Orna
    private var selectedDate_Orna = Date()
    private var kindCells_Orna: [MemoryKindOptionCell_Orna] = []
    private var colorSwatches_Orna: [ColorSwatchView_Orna] = []

    private static let colorOptions_Orna: [String] = [
        "#7B61FF", "#FF6B9D", "#FF9A6C", "#5B8DEF", "#43C6AC", "#B794F6"
    ]

    // MARK: - UI

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "New Memory Ornament"
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let kindSectionLabel_Orna = MemoryOrnamentCreateSheet_Orna.makeFieldLabel_Orna(text: "Type")

    private let kindScrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let kindStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        return sv
    }()

    private let nameSectionLabel_Orna = MemoryOrnamentCreateSheet_Orna.makeFieldLabel_Orna(text: "Name")

    private let nameField_Orna: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = "e.g. Travel Shell Ornament"
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 14
        tf.setLeftPadding_Orna(16)
        return tf
    }()

    private let dateSectionLabel_Orna = MemoryOrnamentCreateSheet_Orna.makeFieldLabel_Orna(text: "Anniversary Date")

    private let datePicker_Orna: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.maximumDate = Date()
        return dp
    }()

    private let personSectionLabel_Orna = MemoryOrnamentCreateSheet_Orna.makeFieldLabel_Orna(text: "Person's Name")

    private let personNameField_Orna: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = "e.g. Mom, Alex..."
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 14
        tf.setLeftPadding_Orna(16)
        return tf
    }()

    private let relationshipSectionLabel_Orna = MemoryOrnamentCreateSheet_Orna.makeFieldLabel_Orna(text: "Relationship")

    private let relationshipControl_Orna = PillSegmentControl_Orna(titles_Orna: ["Family", "Friend", "Lover", "Other"])

    private let colorSectionLabel_Orna = MemoryOrnamentCreateSheet_Orna.makeFieldLabel_Orna(text: "Accent Color")

    private let colorStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 14
        sv.distribution = .equalSpacing
        return sv
    }()

    private let createButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Create Ornament", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = UIColor(hexstring_Orna: "#7B61FF")
        b.layer.cornerRadius = 24
        return b
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let sheet_orna = sheetPresentationController {
            sheet_orna.detents = [.large()]
            sheet_orna.prefersGrabberVisible = true
            sheet_orna.preferredCornerRadius = 24
        }
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        buildKindOptions_Orna()
        buildColorSwatches_Orna()
        updateFieldVisibility_Orna()
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        contentView_Orna.addSubview(titleLabel_Orna)
        contentView_Orna.addSubview(kindSectionLabel_Orna)
        contentView_Orna.addSubview(kindScrollView_Orna)
        kindScrollView_Orna.addSubview(kindStack_Orna)

        contentView_Orna.addSubview(nameSectionLabel_Orna)
        contentView_Orna.addSubview(nameField_Orna)

        contentView_Orna.addSubview(dateSectionLabel_Orna)
        contentView_Orna.addSubview(datePicker_Orna)

        contentView_Orna.addSubview(personSectionLabel_Orna)
        contentView_Orna.addSubview(personNameField_Orna)
        contentView_Orna.addSubview(relationshipSectionLabel_Orna)
        contentView_Orna.addSubview(relationshipControl_Orna)

        contentView_Orna.addSubview(colorSectionLabel_Orna)
        contentView_Orna.addSubview(colorStack_Orna)

        contentView_Orna.addSubview(createButton_Orna)
    }

    private func setupConstraints_Orna() {
        scrollView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        kindSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        kindScrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(kindSectionLabel_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(76)
        }
        kindStack_Orna.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }

        nameSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(kindScrollView_Orna.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(24)
        }
        nameField_Orna.snp.makeConstraints {
            $0.top.equalTo(nameSectionLabel_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }

        dateSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameField_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(24)
        }
        datePicker_Orna.snp.makeConstraints {
            $0.top.equalTo(dateSectionLabel_Orna.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }

        personSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameField_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(24)
        }
        personNameField_Orna.snp.makeConstraints {
            $0.top.equalTo(personSectionLabel_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
        relationshipSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(personNameField_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(24)
        }
        relationshipControl_Orna.snp.makeConstraints {
            $0.top.equalTo(relationshipSectionLabel_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }

        colorSectionLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(datePicker_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(24)
        }
        colorStack_Orna.snp.makeConstraints {
            $0.top.equalTo(colorSectionLabel_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(32)
        }

        createButton_Orna.snp.makeConstraints {
            $0.top.equalTo(colorStack_Orna.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    /// 构建 6 种摆件类型选项
    private func buildKindOptions_Orna() {
        kindStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        kindCells_Orna.removeAll()
        for kind_orna in MemoryOrnamentKind_Orna.allCases {
            let cell_orna = MemoryKindOptionCell_Orna()
            cell_orna.configure_Orna(kind_orna: kind_orna, isSelected_orna: kind_orna == selectedKind_Orna)
            cell_orna.onTap_Orna = { [weak self] in
                self?.handleKindSelected_Orna(kind_orna: kind_orna)
            }
            kindStack_Orna.addArrangedSubview(cell_orna)
            kindCells_Orna.append(cell_orna)
        }
    }

    /// 构建强调色选择圆点
    private func buildColorSwatches_Orna() {
        colorStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        colorSwatches_Orna.removeAll()
        for colorHex_orna in Self.colorOptions_Orna {
            let swatch_orna = ColorSwatchView_Orna()
            swatch_orna.configure_Orna(colorHex_orna: colorHex_orna, isSelected_orna: colorHex_orna == selectedColorHex_Orna)
            swatch_orna.onTap_Orna = { [weak self] in
                self?.selectedColorHex_Orna = colorHex_orna
                self?.colorSwatches_Orna.forEach { $0.setSelected_Orna($0 === swatch_orna) }
            }
            colorStack_Orna.addArrangedSubview(swatch_orna)
            colorSwatches_Orna.append(swatch_orna)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        createButton_Orna.addTarget(self, action: #selector(handleCreateTapped_Orna), for: .touchUpInside)
        datePicker_Orna.addTarget(self, action: #selector(handleDateChanged_Orna), for: .valueChanged)
        relationshipControl_Orna.onSelectionChanged_Orna = { [weak self] index_orna in
            self?.relationshipSelectedIndexValue_Orna = index_orna
        }
    }

    @objc private func handleDateChanged_Orna() {
        selectedDate_Orna = datePicker_Orna.date
    }

    // MARK: - 事件处理

    private func handleKindSelected_Orna(kind_orna: MemoryOrnamentKind_Orna) {
        selectedKind_Orna = kind_orna
        selectedColorHex_Orna = kind_orna.defaultColorHex_Orna
        kindCells_Orna.forEach { $0.setSelected_Orna(kind_orna: selectedKind_Orna) }
        buildColorSwatches_Orna()
        updateFieldVisibility_Orna()
    }

    /// 按当前选中类型显示/隐藏纪念日字段与人物信息字段
    private func updateFieldVisibility_Orna() {
        let isAnniversary_orna = selectedKind_Orna.isAnniversaryType_Orna
        dateSectionLabel_Orna.isHidden = !isAnniversary_orna
        datePicker_Orna.isHidden = !isAnniversary_orna
        personSectionLabel_Orna.isHidden = isAnniversary_orna
        personNameField_Orna.isHidden = isAnniversary_orna
        relationshipSectionLabel_Orna.isHidden = isAnniversary_orna
        relationshipControl_Orna.isHidden = isAnniversary_orna

        // 根据是否展示纪念日日期选择器，重新固定"强调色"分区的锚点，避免隐藏字段后出现大段空白
        colorSectionLabel_Orna.snp.remakeConstraints {
            $0.top.equalTo((isAnniversary_orna ? datePicker_Orna : relationshipControl_Orna).snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(24)
        }
    }

    /// 创建摆件：校验名称与必填信息后调用 UserViewModel 创建，成功后关闭面板
    @objc private func handleCreateTapped_Orna() {
        let name_orna = (nameField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name_orna.isEmpty else {
            Load_Orna.showWarning_Orna(message_Orna: "Please give your ornament a name")
            return
        }

        var anniversaryMonth_orna: Int? = nil
        var anniversaryDay_orna: Int? = nil
        var anniversaryStartYear_orna: Int? = nil
        var personName_orna: String? = nil
        var personRelationship_orna: String? = nil

        if selectedKind_Orna.isAnniversaryType_Orna {
            let components_orna = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate_Orna)
            anniversaryMonth_orna = components_orna.month
            anniversaryDay_orna = components_orna.day
            anniversaryStartYear_orna = components_orna.year
        } else {
            let personTypedName_orna = (personNameField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !personTypedName_orna.isEmpty else {
                Load_Orna.showWarning_Orna(message_Orna: "Please enter the person's name")
                return
            }
            personName_orna = personTypedName_orna
            personRelationship_orna = ["Family", "Friend", "Lover", "Other"][safeIndex_Orna: relationshipSelectedIndex_Orna()]
        }

        UserViewModel_Orna.shared_Orna.createMemoryOrnament_Orna(
            kind_orna: selectedKind_Orna,
            customName_orna: name_orna,
            colorHex_orna: selectedColorHex_Orna,
            anniversaryMonth_orna: anniversaryMonth_orna,
            anniversaryDay_orna: anniversaryDay_orna,
            anniversaryStartYear_orna: anniversaryStartYear_orna,
            personName_orna: personName_orna,
            personRelationship_orna: personRelationship_orna
        )
        Load_Orna.showSuccess_Orna(message_Orna: "\(name_orna) created! Start recording memories 🌱")
        onCreated_Orna?()
        dismiss(animated: true)
    }

    /// 因 PillSegmentControl_Orna 未直接暴露当前选中下标，此处通过监听记录，默认取 0（Family）
    private var relationshipSelectedIndexValue_Orna: Int = 0
    private func relationshipSelectedIndex_Orna() -> Int { relationshipSelectedIndexValue_Orna }

    private static func makeFieldLabel_Orna(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }
}

private extension Array {
    /// 安全下标访问，越界时回退到第一个元素
    subscript(safeIndex_Orna index_orna: Int) -> Element {
        indices.contains(index_orna) ? self[index_orna] : self[0]
    }
}

// MARK: - 摆件类型选项单元

/// 摆件类型选项单元
/// 核心作用：以圆形图标 + 文字呈现单个摆件类型，支持选中态高亮
class MemoryKindOptionCell_Orna: UIView {

    /// 点击回调
    var onTap_Orna: (() -> Void)?

    private var kind_Orna: MemoryOrnamentKind_Orna = .loveAnniversary_Orna

    private let circleView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.clear.cgColor
        return v
    }()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .semibold)
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
        addSubview(nameLabel_Orna)

        snp.makeConstraints { $0.width.equalTo(64) }
        circleView_Orna.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(52)
        }
        iconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(circleView_Orna.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
        }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    /// 配置类型图标、名称与初始选中态
    func configure_Orna(kind_orna: MemoryOrnamentKind_Orna, isSelected_orna: Bool) {
        self.kind_Orna = kind_orna
        iconView_Orna.image = UIImage(systemName: kind_orna.growthIcons_Orna.first ?? "circle.dashed")
        nameLabel_Orna.text = kind_orna.displayName_Orna
        setSelected_Orna(kind_orna: isSelected_orna ? kind_orna : nil)
    }

    /// 更新选中态高亮（传入当前全局选中的类型，与自身类型比较）
    func setSelected_Orna(kind_orna: MemoryOrnamentKind_Orna?) {
        let isSelected_orna = kind_orna == self.kind_Orna
        let colorHex_orna = self.kind_Orna.defaultColorHex_Orna
        circleView_Orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(isSelected_orna ? 0.24 : 0.1)
        circleView_Orna.layer.borderColor = isSelected_orna ? UIColor(hexstring_Orna: colorHex_orna).cgColor : UIColor.clear.cgColor
        iconView_Orna.tintColor = UIColor(hexstring_Orna: colorHex_orna)
    }

    @objc private func handleTap_Orna() { onTap_Orna?() }
}

// MARK: - 强调色选择圆点

/// 强调色选择圆点
/// 核心作用：呈现单个颜色圆点，选中时外圈描边高亮
class ColorSwatchView_Orna: UIView {

    /// 点击回调
    var onTap_Orna: (() -> Void)?

    private let dotView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        addSubview(dotView_Orna)
        snp.makeConstraints { $0.width.height.equalTo(32) }
        dotView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    /// 配置圆点颜色与初始选中态
    func configure_Orna(colorHex_orna: String, isSelected_orna: Bool) {
        dotView_Orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna)
        layer.borderColor = isSelected_orna ? UIColor(hexstring_Orna: colorHex_orna).cgColor : UIColor.clear.cgColor
    }

    /// 更新选中态描边
    func setSelected_Orna(_ isSelected_orna: Bool) {
        layer.borderColor = isSelected_orna ? dotView_Orna.backgroundColor?.cgColor : UIColor.clear.cgColor
    }

    @objc private func handleTap_Orna() { onTap_Orna?() }
}

// MARK: - UITextField 左内边距扩展

private extension UITextField {
    /// 设置左内边距（用于卡片式输入框留白）
    func setLeftPadding_Orna(_ amount: CGFloat) {
        let paddingView_orna = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = paddingView_orna
        leftViewMode = .always
    }
}
