import UIKit
import SnapKit

// MARK: - 日期点击弹窗

/// 日期点击弹窗页面
/// 核心作用：展示日历某一天的全部窗景记录；无数据时显示空状态和快速记录入口
/// 设计思路：Sheet 样式（pageSheet）+ 渐变头部 + 帖子列表（使用 MediaDisplayView 展示媒体）+ 空状态
/// 关键属性：year_Pane / month_Pane / day_Pane 必须在展示前赋值
class HomeDayRecordsPopup_Pane: UIViewController {

    // MARK: - 公共属性

    var year_Pane:  Int = Calendar.current.component(.year,  from: Date())
    var month_Pane: Int = Calendar.current.component(.month, from: Date())
    var day_Pane:   Int = Calendar.current.component(.day,   from: Date())

    // MARK: - 私有常量

    private let cellId_Pane = "DayRecordCell_Pane"

    // MARK: - UI 组件

    private let headerView_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var headerGradient_Pane: CAGradientLayer?

    private let dateLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let weekdayLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor.white.alpha_Pane(0.75)
        return l
    }()

    private let countChip_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.alpha_Pane(0.2)
        v.layer.cornerRadius = 10
        return v
    }()

    private let countLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private lazy var tableView_Pane: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor     = ColorConfig_Pane.backgroundPrimary_Pane
        tv.separatorStyle      = .none
        tv.showsVerticalScrollIndicator = false
        tv.alwaysBounceVertical = true
        tv.dataSource = self
        tv.delegate   = self
        tv.register(DayRecordCell_Pane.self, forCellReuseIdentifier: cellId_Pane)
        return tv
    }()

    private let emptyView_Pane: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 状态

    private var records_Pane: [TitleModel_Pane] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        setupUI_Pane()
        loadData_Pane()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Pane?.frame = headerView_Pane.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.addSubview(headerView_Pane)
        headerView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(130)
        }

        // 渐变头部
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Pane.layer.insertSublayer(gl_pane, at: 0)
        headerGradient_Pane = gl_pane

        // 关闭按钮
        let closeBtn_pane = UIButton(type: .system)
        let closeCfg_pane = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        closeBtn_pane.setImage(UIImage(systemName: "xmark", withConfiguration: closeCfg_pane), for: .normal)
        closeBtn_pane.tintColor       = .white
        closeBtn_pane.backgroundColor = UIColor.white.alpha_Pane(0.2)
        closeBtn_pane.layer.cornerRadius = 14
        closeBtn_pane.addTarget(self, action: #selector(closeTapped_Pane), for: .touchUpInside)

        headerView_Pane.addSubview(closeBtn_pane)
        closeBtn_pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(28)
        }

        // 日期信息
        headerView_Pane.addSubview(dateLabel_Pane)
        headerView_Pane.addSubview(weekdayLabel_Pane)
        headerView_Pane.addSubview(countChip_Pane)
        countChip_Pane.addSubview(countLabel_Pane)

        dateLabel_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(40)
        }
        weekdayLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(dateLabel_Pane)
            $0.top.equalTo(dateLabel_Pane.snp.bottom).offset(4)
        }
        countChip_Pane.snp.makeConstraints {
            $0.leading.equalTo(dateLabel_Pane)
            $0.top.equalTo(weekdayLabel_Pane.snp.bottom).offset(10)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(60)
        }
        countLabel_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
        }

        view.addSubview(tableView_Pane)
        tableView_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        setupEmptyView_Pane()
    }

    /// 搭建空状态视图
    private func setupEmptyView_Pane() {
        view.addSubview(emptyView_Pane)
        emptyView_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        let iconCfg_pane = UIImage.SymbolConfiguration(pointSize: 40, weight: .ultraLight)
        let icon_pane = UIImageView(image: UIImage(systemName: "camera.viewfinder", withConfiguration: iconCfg_pane))
        icon_pane.tintColor = ColorConfig_Pane.textPlaceholder_Pane
        icon_pane.contentMode = .scaleAspectFit

        let titleLabel_pane = UILabel()
        titleLabel_pane.text      = "No records on this day"
        titleLabel_pane.font      = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel_pane.textColor = ColorConfig_Pane.textSecondary_Pane
        titleLabel_pane.textAlignment = .center

        let subLabel_pane = UILabel()
        subLabel_pane.text      = "Capture a window view to remember this moment"
        subLabel_pane.font      = .systemFont(ofSize: 12, weight: .regular)
        subLabel_pane.textColor = ColorConfig_Pane.textPlaceholder_Pane
        subLabel_pane.textAlignment = .center
        subLabel_pane.numberOfLines = 2

        let recordBtn_pane = UIButton(type: .custom)
        recordBtn_pane.setTitle("  Quick Record", for: .normal)
        recordBtn_pane.setTitleColor(.white, for: .normal)
        recordBtn_pane.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        let btnCfg_pane = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        recordBtn_pane.setImage(UIImage(systemName: "camera.fill", withConfiguration: btnCfg_pane), for: .normal)
        recordBtn_pane.tintColor = .white
        recordBtn_pane.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane
        recordBtn_pane.layer.cornerRadius = 22
        recordBtn_pane.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        recordBtn_pane.layer.shadowOpacity = 0.35
        recordBtn_pane.layer.shadowOffset  = CGSize(width: 0, height: 5)
        recordBtn_pane.layer.shadowRadius  = 10
        recordBtn_pane.addTarget(self, action: #selector(quickRecordTapped_Pane), for: .touchUpInside)

        let stack_pane = UIStackView(arrangedSubviews: [icon_pane, titleLabel_pane, subLabel_pane, recordBtn_pane])
        stack_pane.axis      = .vertical
        stack_pane.spacing   = 12
        stack_pane.alignment = .center

        recordBtn_pane.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.width.equalTo(160)
        }
        icon_pane.snp.makeConstraints { $0.height.equalTo(54) }

        emptyView_Pane.addSubview(stack_pane)
        stack_pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }

    // MARK: - 数据加载

    private func loadData_Pane() {
        records_Pane = TitleViewModel_Pane.shared_Pane.getPostsByDay_Pane(
            year_pane: year_Pane,
            month_pane: month_Pane,
            day_pane: day_Pane
        )

        // 更新头部日期信息
        var comps_pane = DateComponents()
        comps_pane.year  = year_Pane
        comps_pane.month = month_Pane
        comps_pane.day   = day_Pane
        let monthNames_pane = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        let mStr_pane = month_Pane >= 1 && month_Pane <= 12 ? monthNames_pane[month_Pane - 1] : ""
        dateLabel_Pane.text  = "\(mStr_pane) \(day_Pane), \(year_Pane)"

        if let date_pane = Calendar.current.date(from: comps_pane) {
            let wf_pane = DateFormatter()
            wf_pane.dateFormat = "EEEE"
            weekdayLabel_Pane.text = wf_pane.string(from: date_pane)
        }

        let cnt_pane = records_Pane.count
        countLabel_Pane.text = cnt_pane > 0 ? "\(cnt_pane) record\(cnt_pane > 1 ? "s" : "")" : "No records"

        emptyView_Pane.isHidden = !records_Pane.isEmpty
        tableView_Pane.reloadData()
    }

    // MARK: - 动作

    @objc private func closeTapped_Pane() {
        dismiss(animated: true)
    }

    /// 打开快速记录半弹窗
    @objc private func quickRecordTapped_Pane() {
        let sheet_pane = HomeQuickRecordSheet_Pane()
        let nav_pane   = UINavigationController(rootViewController: sheet_pane)
        nav_pane.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let s_pane = nav_pane.sheetPresentationController {
                s_pane.detents            = [.medium(), .large()]
                s_pane.prefersGrabberVisible = true
            }
        }
        sheet_pane.onPublished_Pane = { [weak self] in
            self?.loadData_Pane()
        }
        present(nav_pane, animated: true)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension HomeDayRecordsPopup_Pane: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records_Pane.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_pane = tableView.dequeueReusableCell(
            withIdentifier: cellId_Pane, for: indexPath) as! DayRecordCell_Pane
        let post_pane = records_Pane[indexPath.row]
        cell_pane.configure_Pane(post_pane: post_pane)
        cell_pane.onDelete_Pane = { [weak self] in
            guard let self_pane = self else { return }
            let alert_pane = UIAlertController(
                title: "Delete Record",
                message: "Are you sure you want to delete \"\(post_pane.title_Pane)\"?",
                preferredStyle: .alert
            )
            alert_pane.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                TitleViewModel_Pane.shared_Pane.deletePost_Pane(post_pane: post_pane, isDelete_pane: true)
                self_pane.loadData_Pane()
            })
            alert_pane.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self_pane.present(alert_pane, animated: true)
        }
        return cell_pane
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post_pane = records_Pane[indexPath.row]
        dismiss(animated: true) {
            Navigation_Pane.toTitleDetail_Pane(titleModel_pane: post_pane)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}

// MARK: - 当日记录行 Cell

/// 日期弹窗内的单条记录行
/// 核心作用：左侧 MediaDisplayView 展示媒体封面，中部显示标题/主题/内容，右侧删除按钮
private class DayRecordCell_Pane: UITableViewCell {

    /// 删除按钮点击回调
    var onDelete_Pane: (() -> Void)?

    // MARK: - UI

    /// 左侧媒体展示（替换原 UIImageView，支持本地/Assets/网络图片）
    private let mediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        l.numberOfLines = 1
        return l
    }()

    private let contentLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        l.numberOfLines = 1
        return l
    }()

    private let themeChip_Pane: UILabel = {
        let l = UILabel()
        l.font            = .systemFont(ofSize: 10, weight: .medium)
        l.textColor       = ColorConfig_Pane.primaryGradientStart_Pane
        l.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.1)
        l.layer.cornerRadius = 8
        l.clipsToBounds   = true
        l.textAlignment   = .center
        return l
    }()

    /// 右侧删除按钮
    private let deleteButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        b.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        b.tintColor = ColorConfig_Pane.textPlaceholder_Pane
        return b
    }()

    // MARK: - 分割线

    private let divider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Pane() {
        selectionStyle   = .none
        backgroundColor  = ColorConfig_Pane.backgroundPrimary_Pane

        contentView.addSubview(mediaView_Pane)
        contentView.addSubview(titleLabel_Pane)
        contentView.addSubview(themeChip_Pane)
        contentView.addSubview(contentLabel_Pane)
        contentView.addSubview(deleteButton_Pane)
        contentView.addSubview(divider_Pane)

        // 删除按钮（右侧固定宽度）
        deleteButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }

        // 左侧媒体视图（正方形，居中）
        mediaView_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(58)
        }

        // 标题
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(mediaView_Pane.snp.trailing).offset(12)
            $0.trailing.equalTo(deleteButton_Pane.snp.leading).offset(-8)
            $0.top.equalTo(mediaView_Pane).offset(4)
        }

        // 主题标签
        themeChip_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleLabel_Pane)
            $0.top.equalTo(titleLabel_Pane.snp.bottom).offset(5)
            $0.height.equalTo(18)
        }

        // 描述
        contentLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleLabel_Pane)
            $0.trailing.equalTo(titleLabel_Pane)
            $0.top.equalTo(themeChip_Pane.snp.bottom).offset(4)
        }

        // 底部分割线
        divider_Pane.snp.makeConstraints {
            $0.leading.equalTo(mediaView_Pane)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        deleteButton_Pane.addTarget(self, action: #selector(deleteTapped_Pane), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 配置行数据
    /// - Parameter post_pane: 帖子数据模型
    func configure_Pane(post_pane: TitleModel_Pane) {
        titleLabel_Pane.text   = post_pane.title_Pane
        contentLabel_Pane.text = post_pane.titleContent_Pane

        // 使用 MediaDisplayView 展示媒体
        mediaView_Pane.configure_Pane(mediaPath_Pane: post_pane.titleMeidas_Pane.first)

        let theme_pane = post_pane.titleTheme_Pane
        if theme_pane.isEmpty {
            themeChip_Pane.isHidden = true
        } else {
            themeChip_Pane.isHidden = false
            themeChip_Pane.text     = "  \(theme_pane)  "
        }
    }

    // MARK: - 动作

    @objc private func deleteTapped_Pane() {
        onDelete_Pane?()
    }
}
