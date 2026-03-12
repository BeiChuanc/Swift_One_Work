import UIKit
import SnapKit

// MARK: 睡眠相册创建页

/// 专属宠物睡眠相册创建页面
/// 设计：深夜主题 + 单张封面图选择（画布预览+右上角删除）+ 图标/睡眠时段/标题/备注输入
/// 逻辑由 SleepAlbumCreateLogic_Doze 处理，此文件仅负责 UI 与用户交互
class SleepAlbumCreate_Doze: UIViewController {

    // MARK: - 逻辑层

    private let logic_Doze = SleepAlbumCreateLogic_Doze.shared_Doze

    // MARK: - 状态

    /// 已选封面图（单张）
    private var selectedImage_Doze: UIImage?

    /// 当前选中图标索引
    private var selectedIconIndex_Doze: Int = 0

    /// 就寝时间（默认 22:00）
    private var bedTimeDate_Doze: Date = {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 22; c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }()

    /// 起床时间（默认 07:00）
    private var wakeTimeDate_Doze: Date = {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 7; c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }()

    /// 自动计算睡眠质量百分比（睡眠时长 / 1440 min × 100）
    private var computedQualityPct_Doze: Int {
        let bedSec = Int(bedTimeDate_Doze.timeIntervalSince1970)
        let wakeSec = Int(wakeTimeDate_Doze.timeIntervalSince1970)
        var diffSec = wakeSec - bedSec
        // 处理跨天（次日起床）
        if diffSec <= 0 { diffSec += 24 * 3600 }
        return min(100, diffSec * 100 / (24 * 3600))
    }

    /// 自动计算睡眠时长（分钟）
    private var computedDurationMinutes_Doze: Int {
        let bedSec = Int(bedTimeDate_Doze.timeIntervalSince1970)
        let wakeSec = Int(wakeTimeDate_Doze.timeIntervalSince1970)
        var diffSec = wakeSec - bedSec
        if diffSec <= 0 { diffSec += 24 * 3600 }
        return diffSec / 60
    }

    // MARK: - 背景

    private let bgGradientLayer_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#12072A").cgColor,
            UIColor(hexstring_Doze: "#0A1628").cgColor
        ]
        gl.startPoint = CGPoint(x: 0.2, y: 0)
        gl.endPoint = CGPoint(x: 0.8, y: 1)
        return gl
    }()

    // MARK: - 导航栏

    private let navBar_Doze = UIView()

    private let closeButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.8)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 18
        return btn
    }()

    private let navTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "New Sleep Album"
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    private let saveButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Save", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        return btn
    }()

    private let saveBtnGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#B794F6").cgColor,
            UIColor(hexstring_Doze: "#90CDF4").cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        return gl
    }()

    // MARK: - 滚动区

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Doze = UIView()

    // MARK: - 画布区域（单张封面图预览）

    /// 画布外容器
    private let canvasContainer_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        return v
    }()

    /// 空状态提示图标
    private let canvasHintIcon_Doze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.badge.plus")
        iv.tintColor = UIColor.white.withAlphaComponent(0.3)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 空状态提示文字
    private let canvasHintLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to add a cover photo"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.35)
        lbl.textAlignment = .center
        return lbl
    }()

    /// 已选图片展示（静态，满画布 aspectFill）
    private let canvasImageView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    /// 图片删除按钮（右上角圆形 ×）
    private let canvasDeleteBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        btn.layer.cornerRadius = 14
        btn.isHidden = true
        return btn
    }()

    // MARK: - 图标选择

    private let iconSectionLabel_Doze = SleepAlbumCreate_Doze.makeSectionLabel_Doze("Album Icon")

    private let iconScrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let iconStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()

    private var iconChips_Doze: [UIButton] = []

    // MARK: - 睡眠时段

    private let sleepTimeSectionLabel_Doze = SleepAlbumCreate_Doze.makeSectionLabel_Doze("Sleep Time")

    /// 时段卡片容器
    private let sleepTimeCard_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        return v
    }()

    /// 就寝时间 Picker（compact 样式）
    private let bedTimePicker_Doze: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
        dp.tintColor = UIColor(hexstring_Doze: "#B794F6")
        dp.overrideUserInterfaceStyle = .dark
        return dp
    }()

    /// 起床时间 Picker（compact 样式）
    private let wakeTimePicker_Doze: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
        dp.tintColor = UIColor(hexstring_Doze: "#90CDF4")
        dp.overrideUserInterfaceStyle = .dark
        return dp
    }()

    /// 睡眠质量计算结果标签
    private let qualityResultLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = UIColor(hexstring_Doze: "#B794F6")
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 标题输入

    private let titleSectionLabel_Doze = SleepAlbumCreate_Doze.makeSectionLabel_Doze("Album Title")

    private let titleTextField_Doze: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "e.g. Luna's First Month",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.3)]
        )
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = .white
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf.layer.cornerRadius = 14
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        tf.returnKeyType = .next
        return tf
    }()

    // MARK: - 备注输入

    private let noteSectionLabel_Doze = SleepAlbumCreate_Doze.makeSectionLabel_Doze("Note (optional)")

    private let noteTextView_Doze: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tv.textColor = .white
        tv.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tv.layer.cornerRadius = 14
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.isScrollEnabled = false
        return tv
    }()

    private let notePlaceholderLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "A short memory or description..."
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.3)
        lbl.isUserInteractionEnabled = false
        return lbl
    }()

    // MARK: - EULA 文本按钮

    /// 用户许可协议跳转按钮，与发布页保持一致样式
    private let eulaButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: ColorConfig_Doze.primaryGradientStart_Doze,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: ColorConfig_Doze.primaryGradientStart_Doze
        ]
        btn.setAttributedTitle(NSAttributedString(string: "EULA", attributes: attrs), for: .normal)
        return btn
    }()

    // MARK: - 工厂方法

    private static func makeSectionLabel_Doze(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.55)
        return lbl
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Doze()
        setupNavBar_Doze()
        setupScrollView_Doze()
        setupCanvas_Doze()
        setupIconPicker_Doze()
        setupSleepTimePicker_Doze()
        setupTitleInput_Doze()
        setupNoteInput_Doze()
        setupKeyboard_Doze()
        updateQualityDisplay_Doze()
        animateEntrance_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradientLayer_Doze.frame = view.bounds
        saveBtnGradient_Doze.frame = saveButton_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 背景

    private func setupBackground_Doze() {
        view.layer.insertSublayer(bgGradientLayer_Doze, at: 0)
        let glow = UIView()
        glow.backgroundColor = UIColor(hexstring_Doze: "#B794F6").withAlphaComponent(0.1)
        glow.layer.cornerRadius = 110
        glow.isUserInteractionEnabled = false
        view.addSubview(glow)
        glow.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(50)
            make.top.equalToSuperview().offset(-40)
            make.width.height.equalTo(220)
        }
    }

    // MARK: - 导航栏

    private func setupNavBar_Doze() {
        view.addSubview(navBar_Doze)
        navBar_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        navBar_Doze.addSubview(closeButton_Doze)
        closeButton_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        closeButton_Doze.addTarget(self, action: #selector(handleClose_Doze), for: .touchUpInside)

        navBar_Doze.addSubview(navTitleLabel_Doze)
        navTitleLabel_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        saveButton_Doze.layer.insertSublayer(saveBtnGradient_Doze, at: 0)
        navBar_Doze.addSubview(saveButton_Doze)
        saveButton_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(68)
            make.height.equalTo(32)
        }
        saveButton_Doze.addTarget(self, action: #selector(handleSave_Doze), for: .touchUpInside)

        let sep = UIView()
        sep.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        navBar_Doze.addSubview(sep)
        sep.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    // MARK: - 滚动区

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(navBar_Doze.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        scrollView_Doze.addSubview(contentView_Doze)
        contentView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - 画布区域

    private func setupCanvas_Doze() {
        contentView_Doze.addSubview(canvasContainer_Doze)
        canvasContainer_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(260)
        }

        // 画布背景渐变
        let canvasBg = CAGradientLayer()
        canvasBg.colors = [
            UIColor(hexstring_Doze: "#2D1B69").withAlphaComponent(0.35).cgColor,
            UIColor(hexstring_Doze: "#1A2B5E").withAlphaComponent(0.35).cgColor
        ]
        canvasBg.cornerRadius = 20
        canvasBg.frame = CGRect(x: 0, y: 0,
                                width: APPSCREEN_Doze.WIDTH_Doze - 40, height: 260)
        canvasContainer_Doze.layer.insertSublayer(canvasBg, at: 0)

        // 已选封面图（满画布）
        canvasContainer_Doze.addSubview(canvasImageView_Doze)
        canvasImageView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 空状态提示图标
        canvasContainer_Doze.addSubview(canvasHintIcon_Doze)
        canvasHintIcon_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }

        // 空状态提示文字
        canvasContainer_Doze.addSubview(canvasHintLabel_Doze)
        canvasHintLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(canvasHintIcon_Doze.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // 删除按钮（右上角）
        canvasContainer_Doze.addSubview(canvasDeleteBtn_Doze)
        canvasDeleteBtn_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(28)
        }
        canvasDeleteBtn_Doze.addTarget(self, action: #selector(handleDeleteImage_Doze), for: .touchUpInside)

        // 点击画布选图
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap_Doze))
        canvasContainer_Doze.addGestureRecognizer(tap)
        canvasContainer_Doze.isUserInteractionEnabled = true
    }

    // MARK: - 图标选择

    private func setupIconPicker_Doze() {
        contentView_Doze.addSubview(iconSectionLabel_Doze)
        iconSectionLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(canvasContainer_Doze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
        }

        contentView_Doze.addSubview(iconScrollView_Doze)
        iconScrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(iconSectionLabel_Doze.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        iconScrollView_Doze.addSubview(iconStack_Doze)
        iconStack_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        let lead = UIView()
        lead.snp.makeConstraints { make in make.width.equalTo(20) }
        iconStack_Doze.addArrangedSubview(lead)

        for (i, icon) in logic_Doze.albumIcons_Doze.enumerated() {
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(systemName: icon)?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.tintColor = i == 0 ? .white : UIColor.white.withAlphaComponent(0.45)
            btn.backgroundColor = i == 0
                ? ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.3)
                : UIColor.white.withAlphaComponent(0.07)
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = i == 0 ? 1 : 0
            btn.layer.borderColor = ColorConfig_Doze.primaryGradientStart_Doze.cgColor
            btn.tag = i
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            btn.addTarget(self, action: #selector(iconChipTapped_Doze(_:)), for: .touchUpInside)
            btn.snp.makeConstraints { make in make.height.equalTo(40) }
            iconStack_Doze.addArrangedSubview(btn)
            iconChips_Doze.append(btn)
        }

        let trail = UIView()
        trail.snp.makeConstraints { make in make.width.equalTo(20) }
        iconStack_Doze.addArrangedSubview(trail)
    }

    // MARK: - 睡眠时段选择

    private func setupSleepTimePicker_Doze() {
        contentView_Doze.addSubview(sleepTimeSectionLabel_Doze)
        sleepTimeSectionLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(iconScrollView_Doze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
        }

        contentView_Doze.addSubview(sleepTimeCard_Doze)
        sleepTimeCard_Doze.snp.makeConstraints { make in
            make.top.equalTo(sleepTimeSectionLabel_Doze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        // ── 就寝时间行 ──
        let bedRow = makeTimeRow_Doze(
            icon: "moon.fill",
            iconColor: UIColor(hexstring_Doze: "#B794F6"),
            labelText: "Bed Time",
            picker: bedTimePicker_Doze
        )
        sleepTimeCard_Doze.addSubview(bedRow)
        bedRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
        bedTimePicker_Doze.date = bedTimeDate_Doze
        bedTimePicker_Doze.addTarget(self, action: #selector(bedTimeChanged_Doze), for: .valueChanged)

        // 分割线
        let sep = UIView()
        sep.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        sleepTimeCard_Doze.addSubview(sep)
        sep.snp.makeConstraints { make in
            make.top.equalTo(bedRow.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        // ── 起床时间行 ──
        let wakeRow = makeTimeRow_Doze(
            icon: "sun.max.fill",
            iconColor: UIColor(hexstring_Doze: "#FFD700"),
            labelText: "Wake Time",
            picker: wakeTimePicker_Doze
        )
        sleepTimeCard_Doze.addSubview(wakeRow)
        wakeRow.snp.makeConstraints { make in
            make.top.equalTo(sep.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
        }
        wakeTimePicker_Doze.date = wakeTimeDate_Doze
        wakeTimePicker_Doze.addTarget(self, action: #selector(wakeTimeChanged_Doze), for: .valueChanged)

        // 分割线
        let sep2 = UIView()
        sep2.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        sleepTimeCard_Doze.addSubview(sep2)
        sep2.snp.makeConstraints { make in
            make.top.equalTo(wakeRow.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        // ── 质量结果行 ──
        sleepTimeCard_Doze.addSubview(qualityResultLabel_Doze)
        qualityResultLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(sep2.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    /// 构建单行时间选择器行（图标 + 标签 + DatePicker）
    private func makeTimeRow_Doze(
        icon: String,
        iconColor: UIColor,
        labelText: String,
        picker: UIDatePicker
    ) -> UIView {
        let row = UIView()

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        row.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        let lbl = UILabel()
        lbl.text = labelText
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .white
        row.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        row.addSubview(picker)
        picker.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        return row
    }

    // MARK: - 标题输入

    private func setupTitleInput_Doze() {
        contentView_Doze.addSubview(titleSectionLabel_Doze)
        titleSectionLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(sleepTimeCard_Doze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
        }

        contentView_Doze.addSubview(titleTextField_Doze)
        titleTextField_Doze.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        titleTextField_Doze.delegate = self
    }

    // MARK: - 备注输入

    private func setupNoteInput_Doze() {
        contentView_Doze.addSubview(noteSectionLabel_Doze)
        noteSectionLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(titleTextField_Doze.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(20)
        }

        contentView_Doze.addSubview(noteTextView_Doze)
        noteTextView_Doze.snp.makeConstraints { make in
            make.top.equalTo(noteSectionLabel_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(100)
        }

        noteTextView_Doze.addSubview(notePlaceholderLabel_Doze)
        notePlaceholderLabel_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }
        noteTextView_Doze.delegate = self

        // EULA 按钮：位于内容描述下方 10pt，居中显示，撑起 contentView 底部
        contentView_Doze.addSubview(eulaButton_Doze)
        eulaButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(noteTextView_Doze.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
        eulaButton_Doze.addTarget(self, action: #selector(handleEULA_Doze), for: .touchUpInside)
    }

    // MARK: - 键盘

    private func setupKeyboard_Doze() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Doze(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Doze(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 入场动画

    private func animateEntrance_Doze() {
        let views: [UIView] = [
            navBar_Doze, canvasContainer_Doze,
            iconSectionLabel_Doze, iconScrollView_Doze,
            sleepTimeSectionLabel_Doze, sleepTimeCard_Doze,
            titleSectionLabel_Doze, titleTextField_Doze,
            noteSectionLabel_Doze, noteTextView_Doze,
            eulaButton_Doze
        ]
        views.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        for (i, v) in views.enumerated() {
            UIView.animate(withDuration: 0.45, delay: Double(i) * 0.04,
                           usingSpringWithDamping: 0.85, initialSpringVelocity: 0.4,
                           options: [.curveEaseOut]) {
                v.alpha = 1
                v.transform = .identity
            }
        }
    }

    // MARK: - 睡眠质量显示更新

    /// 根据当前时间计算并更新质量结果标签
    private func updateQualityDisplay_Doze() {
        let pct_doze = computedQualityPct_Doze
        let mins_doze = computedDurationMinutes_Doze
        let h_doze = mins_doze / 60
        let m_doze = mins_doze % 60

        // 质量颜色随百分比变化
        let qualityColor_doze: UIColor
        switch pct_doze {
        case 30...: qualityColor_doze = UIColor(hexstring_Doze: "#68D391") // 绿色 良好
        case 20...: qualityColor_doze = UIColor(hexstring_Doze: "#B794F6") // 紫色 一般
        default:    qualityColor_doze = UIColor(hexstring_Doze: "#FBB6CE") // 粉色 较短
        }
        qualityResultLabel_Doze.textColor = qualityColor_doze

        let emoji_doze = pct_doze >= 30 ? "🌙" : (pct_doze >= 20 ? "😴" : "💤")
        qualityResultLabel_Doze.text = "\(emoji_doze) Sleep Quality: \(pct_doze)%  (\(h_doze)h \(m_doze)m)"
    }

    // MARK: - 事件处理

    @objc private func handleClose_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.dismiss_Doze()
    }

    @objc private func handleSave_Doze() {
        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 优先校验登录，未登录跳转登录页
        guard UserViewModel_Doze.shared_Doze.isLoggedIn_Doze else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                Navigation_Doze.toLogin_Doze(style_doze: .present_doze)
            }
            return
        }

        let title_doze = titleTextField_Doze.text ?? ""
        let (valid_doze, msg_doze) = logic_Doze.validateAlbumInput_Doze(
            title_doze: title_doze, image_doze: selectedImage_Doze)
        guard valid_doze else {
            Utils_Doze.showWarning_Doze(message_Doze: msg_doze)
            titleTextField_Doze.animateShake_Doze()
            return
        }

        saveButton_Doze.animatePressDown_Doze { self.saveButton_Doze.animatePressUp_Doze() }

        // 格式化时间字符串
        let fmt_doze = DateFormatter()
        fmt_doze.dateFormat = "HH:mm"
        let bedStr_doze = fmt_doze.string(from: bedTimeDate_Doze)
        let wakeStr_doze = fmt_doze.string(from: wakeTimeDate_Doze)

        logic_Doze.createAndSaveAlbum_Doze(
            title_doze: title_doze,
            note_doze: noteTextView_Doze.text ?? "",
            image_doze: selectedImage_Doze,
            selectedIcon_doze: logic_Doze.albumIcons_Doze[selectedIconIndex_Doze],
            bedTime_doze: bedStr_doze,
            wakeTime_doze: wakeStr_doze,
            sleepQualityPct_doze: computedQualityPct_Doze,
            sleepDurationMinutes_doze: computedDurationMinutes_Doze
        )

        // 通知首页刷新相册区
        NotificationCenter.default.post(
            name: NSNotification.Name("SleepAlbumDidUpdate_Doze"), object: nil)

        Utils_Doze.showSuccess_Doze(message_Doze: "Album created!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Navigation_Doze.dismiss_Doze()
        }
    }

    /// 点击画布选择封面图
    @objc private func handleCanvasTap_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        MediaPickerHelper_Doze.pickImage_Doze(from: self) { [weak self] image in
            guard let self, let img = image else { return }
            self.selectedImage_Doze = img
            self.canvasImageView_Doze.image = img
            self.canvasImageView_Doze.isHidden = false
            self.canvasHintIcon_Doze.isHidden = true
            self.canvasHintLabel_Doze.isHidden = true
            self.canvasDeleteBtn_Doze.isHidden = false
            // 图片弹入动画
            self.canvasImageView_Doze.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
                self.canvasImageView_Doze.transform = .identity
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    /// 删除已选封面图
    @objc private func handleDeleteImage_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedImage_Doze = nil
        UIView.animate(withDuration: 0.2) {
            self.canvasImageView_Doze.alpha = 0
        } completion: { _ in
            self.canvasImageView_Doze.image = nil
            self.canvasImageView_Doze.isHidden = true
            self.canvasImageView_Doze.alpha = 1
            self.canvasHintIcon_Doze.isHidden = false
            self.canvasHintLabel_Doze.isHidden = false
            self.canvasDeleteBtn_Doze.isHidden = true
        }
    }

    /// 点击 EULA 跳转协议页面
    @objc private func handleEULA_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ProtocolHelper_Doze.showProtocol_Doze(
            type_Doze: .eula_Doze,
            content_Doze: "eula.png",
            from: self
        )
    }

    /// 就寝时间改变
    @objc private func bedTimeChanged_Doze() {
        bedTimeDate_Doze = bedTimePicker_Doze.date
        updateQualityDisplay_Doze()
    }

    /// 起床时间改变
    @objc private func wakeTimeChanged_Doze() {
        wakeTimeDate_Doze = wakeTimePicker_Doze.date
        updateQualityDisplay_Doze()
    }

    /// 图标选择
    @objc private func iconChipTapped_Doze(_ sender: UIButton) {
        selectedIconIndex_Doze = sender.tag
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        for (i, chip) in iconChips_Doze.enumerated() {
            let isSelected = i == sender.tag
            chip.backgroundColor = isSelected
                ? ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.3)
                : UIColor.white.withAlphaComponent(0.07)
            chip.tintColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.45)
            chip.layer.borderWidth = isSelected ? 1 : 0
        }
        sender.animatePulse_Doze()
    }

    // MARK: - 键盘通知

    @objc private func keyboardWillShow_Doze(_ notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Doze.contentInset.bottom = kbFrame.height + 16
    }

    @objc private func keyboardWillHide_Doze(_ notification: Notification) {
        scrollView_Doze.contentInset.bottom = 0
    }
}

// MARK: - UITextFieldDelegate

extension SleepAlbumCreate_Doze: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        noteTextView_Doze.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension SleepAlbumCreate_Doze: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notePlaceholderLabel_Doze.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.5).cgColor
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) { textView.layer.borderWidth = 0 }
    }
}
