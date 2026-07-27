import Foundation
import UIKit
import SnapKit

// MARK: 记忆摆件详情页

/// 记忆摆件详情页视图控制器
/// 核心作用：展示单个记忆摆件的成长状态（图标 / 阶段 / 距下一阶段还差多少记录）、
///           纪念日倒计时或人物关系信息，并列出全部记忆记录，支持添加新记忆推动摆件成长
/// 设计思路：
///   - 头部大卡片：成长阶段图标（纪念日临近时带微光光环）+ 名称 + 成长阶段进度条 + 状态标签
///   - "Memories" 区域纵向列出全部记忆记录（照片缩略图 + 日期 + 随笔），按时间倒序
///   - 悬浮"+"按钮弹出记录添加面板，成功保存后摆件成长阶段随记录数量自动推进，形成闭环
/// 关键属性：
///   - ornamentId_Orna: 外部传入的目标摆件ID，页面自身始终以此ID重新拉取最新数据
class MemoryOrnamentDetail_Orna: UIViewController {

    // MARK: - 数据

    /// 目标摆件ID（由 Navigation_Orna 传入）
    var ornamentId_Orna: Int = -1

    private var ornament_Orna: MemoryOrnamentModel_Orna?

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
        l.text = "Memory Ornament"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let deleteButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "trash", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#FF6B6B")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 成长状态卡片

    private let growthCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 16
        return v
    }()

    private let glowRingView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 45
        v.layer.borderWidth = 3
        v.isHidden = true
        return v
    }()

    private let circleView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 40
        return v
    }()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.textAlignment = .center
        return l
    }()

    private let statusLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let progressTrackView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        v.layer.cornerRadius = 4
        v.clipsToBounds = true
        return v
    }()

    private let progressFillView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 4
        return v
    }()

    private let nextStageLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI · 记忆记录列表

    private let memoriesTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "🖼️ Memories"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let addEntryButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        var config_orna = UIButton.Configuration.filled()
        config_orna.title = "Add Memory"
        config_orna.image = UIImage(systemName: "plus")
        config_orna.imagePadding = 6
        config_orna.baseBackgroundColor = UIColor(hexstring_Orna: "#7B61FF")
        config_orna.baseForegroundColor = .white
        config_orna.cornerStyle = .capsule
        config_orna.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        config_orna.attributedTitle = AttributedString(
            "Add Memory", attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
        )
        b.configuration = config_orna
        return b
    }()

    private let entriesStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()

    private let emptyEntriesView_Orna: EmptyStateView_Orna = {
        let v = EmptyStateView_Orna()
        v.configure_Orna(
            icon_orna: "text.book.closed.fill",
            title_orna: "No memories yet",
            subtitle_orna: "Add your first photo or note to help this ornament start growing."
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
        refreshData_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshData_Orna()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(backButton_Orna)
        view.addSubview(titleLabel_Orna)
        view.addSubview(deleteButton_Orna)
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        contentView_Orna.addSubview(growthCardView_Orna)
        growthCardView_Orna.addSubview(glowRingView_Orna)
        growthCardView_Orna.addSubview(circleView_Orna)
        circleView_Orna.addSubview(iconView_Orna)
        growthCardView_Orna.addSubview(nameLabel_Orna)
        growthCardView_Orna.addSubview(statusLabel_Orna)
        growthCardView_Orna.addSubview(progressTrackView_Orna)
        progressTrackView_Orna.addSubview(progressFillView_Orna)
        growthCardView_Orna.addSubview(nextStageLabel_Orna)

        contentView_Orna.addSubview(memoriesTitleLabel_Orna)
        contentView_Orna.addSubview(addEntryButton_Orna)
        contentView_Orna.addSubview(entriesStack_Orna)
        contentView_Orna.addSubview(emptyEntriesView_Orna)
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
        deleteButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(36)
        }
        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        growthCardView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        glowRingView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(90)
        }
        circleView_Orna.snp.makeConstraints {
            $0.center.equalTo(glowRingView_Orna)
            $0.width.height.equalTo(80)
        }
        iconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(38)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(glowRingView_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        statusLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        progressTrackView_Orna.snp.makeConstraints {
            $0.top.equalTo(statusLabel_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(8)
        }
        nextStageLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(progressTrackView_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-22)
        }

        memoriesTitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(growthCardView_Orna.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
        }
        addEntryButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(memoriesTitleLabel_Orna)
            $0.trailing.equalToSuperview().offset(-20)
        }
        entriesStack_Orna.snp.makeConstraints {
            $0.top.equalTo(memoriesTitleLabel_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        emptyEntriesView_Orna.snp.makeConstraints {
            $0.top.equalTo(memoriesTitleLabel_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        deleteButton_Orna.addTarget(self, action: #selector(handleDeleteOrnamentTapped_Orna), for: .touchUpInside)
        addEntryButton_Orna.addTarget(self, action: #selector(handleAddEntryTapped_Orna), for: .touchUpInside)
    }

    /// 监听用户状态变化，新增记忆记录后实时刷新成长状态与列表
    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshData_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna,
            object: nil
        )
    }

    // MARK: - 数据刷新

    /// 重新拉取摆件最新数据并刷新头部成长状态与记忆记录列表
    @objc private func refreshData_Orna() {
        guard let ornament_orna = UserViewModel_Orna.shared_Orna.getMemoryOrnamentById_Orna(ornamentId_orna: ornamentId_Orna) else {
            Navigation_Orna.pop_Orna(from: self)
            return
        }
        self.ornament_Orna = ornament_orna

        titleLabel_Orna.text = ornament_orna.customName_Orna
        nameLabel_Orna.text = ornament_orna.customName_Orna

        let colorHex_orna = ornament_orna.colorHex_Orna
        circleView_Orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(0.2)
        iconView_Orna.image = UIImage(systemName: ornament_orna.currentGrowthIcon_Orna)
        iconView_Orna.tintColor = UIColor(hexstring_Orna: colorHex_orna)
        progressFillView_Orna.backgroundColor = UIColor(hexstring_Orna: colorHex_orna)

        glowRingView_Orna.isHidden = !ornament_orna.isGlowingNearAnniversary_Orna
        glowRingView_Orna.layer.borderColor = UIColor(hexstring_Orna: colorHex_orna).withAlphaComponent(0.7).cgColor

        var statusParts_orna: [String] = ["🌱 \(ornament_orna.growthStageName_Orna)"]
        if ornament_orna.kind_Orna.isAnniversaryType_Orna {
            if let years_orna = ornament_orna.anniversaryYearsCount_Orna, years_orna > 0 {
                statusParts_orna.append("\(years_orna) year\(years_orna == 1 ? "" : "s") together")
            }
            if let days_orna = ornament_orna.daysUntilNextAnniversary_Orna {
                statusParts_orna.append(days_orna == 0 ? "Today is the day! ✨" : "\(days_orna) days until anniversary")
            }
        } else {
            var personLine_orna = ornament_orna.personRelationship_Orna ?? "Person Token"
            if let name_orna = ornament_orna.personName_Orna, !name_orna.isEmpty {
                personLine_orna += " · \(name_orna)"
            }
            statusParts_orna.append(personLine_orna)
        }
        statusLabel_Orna.text = statusParts_orna.joined(separator: "\n")

        let stageIndex_orna = ornament_orna.growthStageIndex_Orna
        let totalStages_orna = ornament_orna.kind_Orna.growthIcons_Orna.count
        let progressRatio_orna = CGFloat(stageIndex_orna + 1) / CGFloat(totalStages_orna)
        progressTrackView_Orna.layoutIfNeeded()
        let trackWidth_orna = progressTrackView_Orna.bounds.width
        progressFillView_Orna.snp.remakeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(max(8, trackWidth_orna * progressRatio_orna))
        }

        if let remaining_orna = ornament_orna.entriesUntilNextStage_Orna {
            nextStageLabel_Orna.text = "\(remaining_orna) more memor\(remaining_orna == 1 ? "y" : "ies") to reach the next stage"
        } else {
            nextStageLabel_Orna.text = "Fully grown — keep adding memories to cherish this ornament"
        }

        rebuildEntriesList_Orna(ornament_orna: ornament_orna)
    }

    /// 重建记忆记录卡片列表（按日期倒序）
    private func rebuildEntriesList_Orna(ornament_orna: MemoryOrnamentModel_Orna) {
        entriesStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let sortedEntries_orna = ornament_orna.entries_Orna.sorted { $0.entryDate_Orna > $1.entryDate_Orna }

        emptyEntriesView_Orna.isHidden = !sortedEntries_orna.isEmpty
        entriesStack_Orna.isHidden = sortedEntries_orna.isEmpty

        for entry_orna in sortedEntries_orna {
            let row_orna = MemoryEntryRowView_Orna()
            row_orna.configure_Orna(entry_orna: entry_orna)
            row_orna.onDelete_Orna = { [weak self] in
                self?.handleDeleteEntryTapped_Orna(entry_orna: entry_orna)
            }
            entriesStack_Orna.addArrangedSubview(row_orna)
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 删除整个记忆摆件
    @objc private func handleDeleteOrnamentTapped_Orna() {
        guard let ornament_orna = ornament_Orna else { return }
        let alert_orna = UIAlertController(
            title: "Delete \(ornament_orna.customName_Orna)?",
            message: "All memories recorded for this ornament will be removed. This cannot be undone.",
            preferredStyle: .alert
        )
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_orna.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            UserViewModel_Orna.shared_Orna.deleteMemoryOrnament_Orna(ornamentId_orna: ornament_orna.ornamentId_Orna)
            Navigation_Orna.pop_Orna(from: self)
        })
        present(alert_orna, animated: true)
    }

    /// 弹出记忆记录添加面板
    @objc private func handleAddEntryTapped_Orna() {
        let sheet_orna = MemoryEntryComposeSheet_Orna()
        sheet_orna.ornamentId_Orna = ornamentId_Orna
        present(sheet_orna, animated: true)
    }

    /// 删除单条记忆记录二次确认
    private func handleDeleteEntryTapped_Orna(entry_orna: MemoryEntryModel_Orna) {
        let alert_orna = UIAlertController(title: "Delete this memory?", message: nil, preferredStyle: .actionSheet)
        alert_orna.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            UserViewModel_Orna.shared_Orna.deleteMemoryEntry_Orna(ornamentId_orna: self.ornamentId_Orna, entryId_orna: entry_orna.entryId_Orna)
        })
        alert_orna.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_orna, animated: true)
    }
}

// MARK: - 记忆记录行视图

/// 记忆记录行视图
/// 核心作用：以白色圆角卡片呈现单条记忆记录的照片缩略图、日期与随笔文字
private class MemoryEntryRowView_Orna: UIView {

    /// 删除回调
    var onDelete_Orna: (() -> Void)?

    private let cardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 8
        return v
    }()

    private let photoView_Orna: MediaDisplayView_Orna = {
        let v = MediaDisplayView_Orna()
        v.layer.cornerRadius = 12
        v.showsBuiltInPlaceholder_Orna = false
        return v
    }()

    private let dateLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#7B61FF")
        return l
    }()

    private let noteLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.numberOfLines = 3
        return l
    }()

    private let deleteButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#C7C2DB")
        return b
    }()

    private static let dateFormatter_Orna: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Orna() {
        addSubview(cardView_Orna)
        cardView_Orna.addSubview(photoView_Orna)
        cardView_Orna.addSubview(dateLabel_Orna)
        cardView_Orna.addSubview(noteLabel_Orna)
        cardView_Orna.addSubview(deleteButton_Orna)

        cardView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        photoView_Orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(56)
        }
        deleteButton_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalToSuperview().offset(12)
            $0.width.height.equalTo(20)
        }
        dateLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(photoView_Orna.snp.trailing).offset(12)
            $0.trailing.equalTo(deleteButton_Orna.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(14)
        }
        noteLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(dateLabel_Orna)
            $0.trailing.equalToSuperview().offset(-14)
            $0.top.equalTo(dateLabel_Orna.snp.bottom).offset(4)
            $0.bottom.lessThanOrEqualToSuperview().offset(-12)
        }

        deleteButton_Orna.addTarget(self, action: #selector(handleDeleteTapped_Orna), for: .touchUpInside)
    }

    /// 配置记录展示内容
    func configure_Orna(entry_orna: MemoryEntryModel_Orna) {
        photoView_Orna.configure_Orna(mediaPath_Orna: entry_orna.photoPath_Orna)
        dateLabel_Orna.text = Self.dateFormatter_Orna.string(from: entry_orna.entryDate_Orna)
        noteLabel_Orna.text = entry_orna.noteText_Orna.isEmpty ? "（No note）" : entry_orna.noteText_Orna
    }

    @objc private func handleDeleteTapped_Orna() { onDelete_Orna?() }
}

// MARK: - 记忆记录添加面板

/// 记忆记录添加面板（以系统半屏 Sheet 呈现）
/// 核心作用：引导用户选择日期、填写随笔并可选添加照片，保存后直接推动摆件成长阶段推进
class MemoryEntryComposeSheet_Orna: UIViewController {

    /// 目标摆件ID
    var ornamentId_Orna: Int = -1

    private var pickedImage_Orna: UIImage?

    // MARK: - UI

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Add a Memory"
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let dateLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Date"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let datePicker_Orna: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.maximumDate = Date()
        return dp
    }()

    private let noteLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Note"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let noteTextView_Orna: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14, weight: .regular)
        tv.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tv.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tv.layer.cornerRadius = 14
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return tv
    }()

    private let notePlaceholderLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Write down what happened today..."
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0").withAlphaComponent(0.7)
        return l
    }()

    private let photoPreview_Orna: MediaDisplayView_Orna = {
        let v = MediaDisplayView_Orna()
        v.layer.cornerRadius = 14
        return v
    }()

    private let addPhotoButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        var config_orna = UIButton.Configuration.plain()
        config_orna.image = UIImage(systemName: "photo.on.rectangle.angled")
        config_orna.imagePadding = 6
        config_orna.baseForegroundColor = UIColor(hexstring_Orna: "#7B61FF")
        config_orna.attributedTitle = AttributedString(
            "Add Photo", attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 13, weight: .semibold)])
        )
        b.configuration = config_orna
        return b
    }()

    private let saveButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save Memory", for: .normal)
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
            sheet_orna.detents = [.medium(), .large()]
            sheet_orna.prefersGrabberVisible = true
            sheet_orna.preferredCornerRadius = 24
        }
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        noteTextView_Orna.delegate = self
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(titleLabel_Orna)
        view.addSubview(dateLabel_Orna)
        view.addSubview(datePicker_Orna)
        view.addSubview(noteLabel_Orna)
        view.addSubview(noteTextView_Orna)
        noteTextView_Orna.addSubview(notePlaceholderLabel_Orna)
        view.addSubview(photoPreview_Orna)
        view.addSubview(addPhotoButton_Orna)
        view.addSubview(saveButton_Orna)
    }

    private func setupConstraints_Orna() {
        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        dateLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(24)
        }
        datePicker_Orna.snp.makeConstraints {
            $0.top.equalTo(dateLabel_Orna.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(20)
        }
        noteLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(datePicker_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(24)
        }
        noteTextView_Orna.snp.makeConstraints {
            $0.top.equalTo(noteLabel_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(100)
        }
        notePlaceholderLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(14)
        }
        photoPreview_Orna.snp.makeConstraints {
            $0.top.equalTo(noteTextView_Orna.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(72)
        }
        addPhotoButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(photoPreview_Orna)
            $0.leading.equalTo(photoPreview_Orna.snp.trailing).offset(12)
        }
        saveButton_Orna.snp.makeConstraints {
            $0.top.equalTo(photoPreview_Orna.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        addPhotoButton_Orna.addTarget(self, action: #selector(handleAddPhotoTapped_Orna), for: .touchUpInside)
        saveButton_Orna.addTarget(self, action: #selector(handleSaveTapped_Orna), for: .touchUpInside)
    }

    // MARK: - 事件处理

    @objc private func handleAddPhotoTapped_Orna() {
        MediaPickerHelper_Orna.pickImage_Orna(from: self) { [weak self] image_orna in
            guard let self, let image_orna else { return }
            self.pickedImage_Orna = image_orna
            self.photoPreview_Orna.configureWithImage_Orna(image_Orna: image_orna)
        }
    }

    /// 保存记忆记录：随笔与照片至少填写其一，保存后关闭面板并推动摆件成长
    @objc private func handleSaveTapped_Orna() {
        let note_orna = (noteTextView_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !note_orna.isEmpty || pickedImage_Orna != nil else {
            Load_Orna.showWarning_Orna(message_Orna: "Add a note or a photo to save this memory")
            return
        }

        UserViewModel_Orna.shared_Orna.addMemoryEntry_Orna(
            ornamentId_orna: ornamentId_Orna,
            noteText_orna: note_orna,
            photoImage_orna: pickedImage_Orna,
            entryDate_orna: datePicker_Orna.date
        )
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension MemoryEntryComposeSheet_Orna: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notePlaceholderLabel_Orna.isHidden = !textView.text.isEmpty
    }
}
