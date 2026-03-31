import UIKit
import SnapKit

// MARK: - 首页主体视图控制器

/// 首页视图控制器
/// 功能：承载三大核心模块 —— 速记（QuickNote）、官方碎念挑战（Challenge）、时间胶囊（TimeCapsule）
/// 设计：深色系渐变，UITableView 多 Section 驱动，每个 Section 均有独立交互逻辑
/// 关键属性：speedNotes_Flick（速记列表）、challenges_Flick（挑战列表）、capsules_Flick（胶囊列表）
@MainActor
class Home_Flick: UIViewController {

    // MARK: - Section 枚举

    /// 首页 Section 类型
    private enum HomeSection_Flick: Int, CaseIterable {
        case speedNote_flick   = 0  // 速记
        case challenge_flick   = 1  // 官方挑战
        case timeCapsule_flick = 2  // 时间胶囊
    }

    // MARK: - 私有数据属性

    private var speedNotes_Flick: [SpeedNote_Flick] = []
    private var challenges_Flick: [HalfChallenge_Flick] = []
    private var capsules_Flick: [TimeCapsule_Flick] = []

    // MARK: - 速记输入状态

    private var pendingNoteText_Flick: String = ""

    // MARK: - 时间胶囊输入状态

    private var capsuleText_Flick: String = ""
    private var capsuleMoodNote_Flick: String = ""
    private var capsuleMoodEmoji_Flick: String = "☀️"
    private var capsuleUnlockOption_Flick: CapsuleUnlockOption_Flick = .oneYear_Flick

    // MARK: - 速记补充输入临时状态（noteId -> text）

    private var supplementText_Flick: [String: String] = [:]

    // MARK: - Cell 注册 ID

    private let speedNoteId_Flick   = "SpeedNoteCell"
    private let challengeId_Flick   = "ChallengeCell"
    private let capsuleId_Flick     = "CapsuleCell"

    /// 为自定义底部 Tab 胶囊预留的列表底部内边距（与 TabBar_Flick 安全区布局对齐）
    private let customTabBarBottomInset_Flick: CGFloat = 100

    // MARK: - UI 组件

    private let gradientLayer_Flick: CAGradientLayer = {
        let gl_flick = CAGradientLayer()
        gl_flick.colors = [
            UIColor(hexstring_Flick: "#0D0D1A").cgColor,
            UIColor(hexstring_Flick: "#0F0A2A").cgColor
        ]
        gl_flick.locations = [0, 1]
        return gl_flick
    }()

    private lazy var tableView_Flick: UITableView = {
        let tv_flick = UITableView(frame: .zero, style: .grouped)
        tv_flick.backgroundColor = .clear
        tv_flick.separatorStyle = .none
        tv_flick.showsVerticalScrollIndicator = false
        tv_flick.contentInsetAdjustmentBehavior = .never
        tv_flick.keyboardDismissMode = .onDrag
        return tv_flick
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Flick()
        setupTableView_Flick()
        loadData_Flick()
        observeNotifications_Flick()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Flick.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData_Flick()
        tableView_Flick.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 私有方法 - 初始化

    private func setupBackground_Flick() {
        view.layer.insertSublayer(gradientLayer_Flick, at: 0)
    }

    private func setupTableView_Flick() {
        view.addSubview(tableView_Flick)
        tableView_Flick.snp.makeConstraints { make_flick in
            make_flick.edges.equalToSuperview()
        }
        tableView_Flick.delegate = self
        tableView_Flick.dataSource = self
        tableView_Flick.register(SpeedNoteCell_Flick.self, forCellReuseIdentifier: speedNoteId_Flick)
        tableView_Flick.register(ChallengePreviewCell_Flick.self, forCellReuseIdentifier: challengeId_Flick)
        tableView_Flick.register(CapsuleItemCell_Flick.self, forCellReuseIdentifier: capsuleId_Flick)
        // tableHeaderView：顶部渐变导航栏
        tableView_Flick.tableHeaderView = buildTopBarView_Flick()
        applyTableBottomInset_Flick(keyboardHeight_flick: 0)
    }

    /// 加载所有数据
    private func loadData_Flick() {
        speedNotes_Flick = UserViewModel_Flick.shared_Flick.loadSpeedNotes_Flick()
        challenges_Flick = TitleViewModel_Flick.shared_Flick.getChallenges_Flick()
        capsules_Flick   = UserViewModel_Flick.shared_Flick.loadTimeCapsules_Flick()
    }

    private func observeNotifications_Flick() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Flick),
            name: UserViewModel_Flick.userStateDidChangeNotification_Flick, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleChallengeChange_Flick),
            name: TitleViewModel_Flick.challengeStateDidChangeNotification_Flick, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardShow_Flick(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardHide_Flick(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 私有方法 - 构建固定 UI 区块

    /// 构建顶部导航栏 View（tableHeaderView）
    private func buildTopBarView_Flick() -> UIView {
        let container_flick = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        container_flick.backgroundColor = .clear

        // 渐变遮罩
        let glLayer_flick = CAGradientLayer()
        glLayer_flick.colors = [
            UIColor(hexstring_Flick: "#7C3AED").withValues(alpha: 0.4).cgColor,
            UIColor.clear.cgColor
        ]
        glLayer_flick.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        container_flick.layer.insertSublayer(glLayer_flick, at: 0)

        // App 名称
        let appNameLabel_flick = UILabel()
        appNameLabel_flick.text = "Flick"
        appNameLabel_flick.textColor = .white
        appNameLabel_flick.font = UIFont(name: "Georgia-Bold", size: 28) ?? .boldSystemFont(ofSize: 28)
        container_flick.addSubview(appNameLabel_flick)
        appNameLabel_flick.snp.makeConstraints { make_flick in
            make_flick.bottom.equalToSuperview().offset(-14)
            make_flick.left.equalToSuperview().offset(20)
        }

        // 日期文字
        let dateLabel_flick = UILabel()
        let df_flick = DateFormatter()
        df_flick.dateFormat = "MMM d"
        dateLabel_flick.text = df_flick.string(from: Date())
        dateLabel_flick.textColor = UIColor(hexstring_Flick: "#9CA3AF")
        dateLabel_flick.font = .systemFont(ofSize: 13)
        container_flick.addSubview(dateLabel_flick)
        dateLabel_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(appNameLabel_flick)
            make_flick.right.equalToSuperview().offset(-20)
        }

        return container_flick
    }

    /// 构建速记 Section 表头（含输入框）
    private func buildSpeedNoteHeader_Flick() -> UIView {
        let container_flick = UIView()
        container_flick.backgroundColor = .clear

        // Section 标题行
        let iconLabel_flick = UILabel()
        iconLabel_flick.text = "⚡"
        iconLabel_flick.font = .systemFont(ofSize: 18)
        let titleLabel_flick = UILabel()
        titleLabel_flick.text = "Quick Thought"
        titleLabel_flick.textColor = .white
        titleLabel_flick.font = .systemFont(ofSize: 17, weight: .semibold)
        let subtitleLabel_flick = UILabel()
        subtitleLabel_flick.text = "Locked instantly · Cannot be edited"
        subtitleLabel_flick.textColor = UIColor(hexstring_Flick: "#6B7280")
        subtitleLabel_flick.font = .systemFont(ofSize: 12)

        container_flick.addSubview(iconLabel_flick)
        container_flick.addSubview(titleLabel_flick)
        container_flick.addSubview(subtitleLabel_flick)
        iconLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(16)
            make_flick.left.equalToSuperview().offset(20)
        }
        titleLabel_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(iconLabel_flick)
            make_flick.left.equalTo(iconLabel_flick.snp.right).offset(8)
        }
        subtitleLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(titleLabel_flick.snp.bottom).offset(2)
            make_flick.left.equalTo(titleLabel_flick)
        }

        // 输入卡片
        let inputCard_flick = buildNoteInputCard_Flick()
        container_flick.addSubview(inputCard_flick)
        inputCard_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(subtitleLabel_flick.snp.bottom).offset(12)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.right.equalToSuperview().offset(-16)
            make_flick.bottom.equalToSuperview().offset(-8)
        }
        return container_flick
    }

    /// 构建速记输入卡片
    private func buildNoteInputCard_Flick() -> UIView {
        let card_flick = UIView()
        card_flick.backgroundColor = UIColor(hexstring_Flick: "#1C1C2E")
        card_flick.layer.cornerRadius = 16
        card_flick.clipsToBounds = true

        // 顶部渐变装饰
        let topLine_flick = UIView()
        topLine_flick.backgroundColor = UIColor(hexstring_Flick: "#7C3AED")
        card_flick.addSubview(topLine_flick)
        topLine_flick.snp.makeConstraints { make_flick in
            make_flick.top.left.right.equalToSuperview()
            make_flick.height.equalTo(2)
        }

        // 输入框
        let textView_flick = UITextView()
        textView_flick.tag = 7701
        textView_flick.backgroundColor = .clear
        textView_flick.textColor = .white
        textView_flick.font = .systemFont(ofSize: 15)
        textView_flick.tintColor = UIColor(hexstring_Flick: "#A78BFA")
        textView_flick.isScrollEnabled = false
        textView_flick.delegate = self
        textView_flick.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 4, right: 8)
        // placeholder
        let placeholder_flick = UILabel()
        placeholder_flick.tag = 7702
        placeholder_flick.text = "What's flickering in your mind right now?"
        placeholder_flick.textColor = UIColor(hexstring_Flick: "#4B5563")
        placeholder_flick.font = .systemFont(ofSize: 15)
        placeholder_flick.numberOfLines = 0
        card_flick.addSubview(textView_flick)
        card_flick.addSubview(placeholder_flick)
        textView_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(topLine_flick.snp.bottom).offset(2)
            make_flick.left.right.equalToSuperview()
            make_flick.height.greaterThanOrEqualTo(80)
        }
        placeholder_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(textView_flick).offset(12)
            make_flick.left.equalTo(textView_flick).offset(14)
            make_flick.right.equalTo(textView_flick).offset(-14)
        }

        // 底部操作行
        let bottomRow_flick = UIView()
        card_flick.addSubview(bottomRow_flick)
        bottomRow_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(textView_flick.snp.bottom).offset(0)
            make_flick.left.right.equalToSuperview()
            make_flick.height.equalTo(44)
            make_flick.bottom.equalToSuperview()
        }

        // 字数提示
        let countLabel_flick = UILabel()
        countLabel_flick.tag = 7703
        countLabel_flick.text = "0 / 200"
        countLabel_flick.textColor = UIColor(hexstring_Flick: "#4B5563")
        countLabel_flick.font = .systemFont(ofSize: 11)
        bottomRow_flick.addSubview(countLabel_flick)
        countLabel_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalToSuperview()
            make_flick.left.equalToSuperview().offset(16)
        }

        // 锁定按钮
        let lockBtn_flick = UIButton(type: .custom)
        lockBtn_flick.tag = 7704
        lockBtn_flick.setTitle("⚡ Lock It", for: .normal)
        lockBtn_flick.setTitleColor(.white, for: .normal)
        lockBtn_flick.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        lockBtn_flick.backgroundColor = UIColor(hexstring_Flick: "#7C3AED")
        lockBtn_flick.layer.cornerRadius = 14
        lockBtn_flick.clipsToBounds = true
        lockBtn_flick.addTarget(self, action: #selector(handleLockNote_Flick), for: .touchUpInside)
        bottomRow_flick.addSubview(lockBtn_flick)
        lockBtn_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalToSuperview()
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.width.equalTo(90)
            make_flick.height.equalTo(30)
        }
        return card_flick
    }

    /// 构建官方挑战 Section 表头
    private func buildChallengeHeader_Flick() -> UIView {
        let container_flick = UIView()
        container_flick.backgroundColor = .clear

        let iconLabel_flick = UILabel()
        iconLabel_flick.text = "🔥"
        iconLabel_flick.font = .systemFont(ofSize: 18)
        let titleLabel_flick = UILabel()
        titleLabel_flick.text = "Flick Challenge"
        titleLabel_flick.textColor = .white
        titleLabel_flick.font = .systemFont(ofSize: 17, weight: .semibold)
        let subtitleLabel_flick = UILabel()
        subtitleLabel_flick.text = "Complete the other half · Share your spark"
        subtitleLabel_flick.textColor = UIColor(hexstring_Flick: "#6B7280")
        subtitleLabel_flick.font = .systemFont(ofSize: 12)

        container_flick.addSubview(iconLabel_flick)
        container_flick.addSubview(titleLabel_flick)
        container_flick.addSubview(subtitleLabel_flick)
        iconLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(16)
            make_flick.left.equalToSuperview().offset(20)
        }
        titleLabel_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(iconLabel_flick)
            make_flick.left.equalTo(iconLabel_flick.snp.right).offset(8)
        }
        subtitleLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(titleLabel_flick.snp.bottom).offset(2)
            make_flick.left.equalTo(titleLabel_flick)
            make_flick.bottom.equalToSuperview().offset(-8)
        }
        return container_flick
    }

    /// 构建时间胶囊 Section 表头（含封存创建卡片）
    private func buildCapsuleHeader_Flick() -> UIView {
        let container_flick = UIView()
        container_flick.backgroundColor = .clear

        // 标题行
        let iconLabel_flick = UILabel()
        iconLabel_flick.text = "🫙"
        iconLabel_flick.font = .systemFont(ofSize: 18)
        let titleLabel_flick = UILabel()
        titleLabel_flick.text = "Time Capsule"
        titleLabel_flick.textColor = .white
        titleLabel_flick.font = .systemFont(ofSize: 17, weight: .semibold)
        let subtitleLabel_flick = UILabel()
        subtitleLabel_flick.text = "Seal your thought · Rediscover it later"
        subtitleLabel_flick.textColor = UIColor(hexstring_Flick: "#6B7280")
        subtitleLabel_flick.font = .systemFont(ofSize: 12)

        container_flick.addSubview(iconLabel_flick)
        container_flick.addSubview(titleLabel_flick)
        container_flick.addSubview(subtitleLabel_flick)
        iconLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(16)
            make_flick.left.equalToSuperview().offset(20)
        }
        titleLabel_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(iconLabel_flick)
            make_flick.left.equalTo(iconLabel_flick.snp.right).offset(8)
        }
        subtitleLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(titleLabel_flick.snp.bottom).offset(2)
            make_flick.left.equalTo(titleLabel_flick)
        }

        // 封存卡片
        let capsuleCard_flick = buildCapsuleCreatorCard_Flick()
        container_flick.addSubview(capsuleCard_flick)
        capsuleCard_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(subtitleLabel_flick.snp.bottom).offset(12)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.right.equalToSuperview().offset(-16)
            make_flick.bottom.equalToSuperview().offset(-8)
        }
        return container_flick
    }

    /// 构建时间胶囊封存创建卡片
    private func buildCapsuleCreatorCard_Flick() -> UIView {
        let card_flick = UIView()
        card_flick.backgroundColor = UIColor(hexstring_Flick: "#1A1040")
        card_flick.layer.cornerRadius = 16
        card_flick.layer.borderWidth = 1
        card_flick.layer.borderColor = UIColor(hexstring_Flick: "#7C3AED").withValues(alpha: 0.35).cgColor
        card_flick.clipsToBounds = true

        // 顶部装饰线
        let topLine_flick = UIView()
        topLine_flick.backgroundColor = UIColor(hexstring_Flick: "#F59E0B")
        card_flick.addSubview(topLine_flick)
        topLine_flick.snp.makeConstraints { make_flick in
            make_flick.top.left.right.equalToSuperview()
            make_flick.height.equalTo(2)
        }

        // 内容输入框
        let textView_flick = UITextView()
        textView_flick.tag = 8801
        textView_flick.backgroundColor = .clear
        textView_flick.textColor = .white
        textView_flick.font = .systemFont(ofSize: 15)
        textView_flick.tintColor = UIColor(hexstring_Flick: "#F59E0B")
        textView_flick.isScrollEnabled = false
        textView_flick.delegate = self
        textView_flick.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 4, right: 8)

        let placeholder_flick = UILabel()
        placeholder_flick.tag = 8802
        placeholder_flick.text = "Write to your future self..."
        placeholder_flick.textColor = UIColor(hexstring_Flick: "#4B5563")
        placeholder_flick.font = .systemFont(ofSize: 15)
        placeholder_flick.numberOfLines = 0

        card_flick.addSubview(textView_flick)
        card_flick.addSubview(placeholder_flick)
        textView_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(topLine_flick.snp.bottom).offset(2)
            make_flick.left.right.equalToSuperview()
            make_flick.height.greaterThanOrEqualTo(80)
        }
        placeholder_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(textView_flick).offset(12)
            make_flick.left.equalTo(textView_flick).offset(14)
            make_flick.right.equalTo(textView_flick).offset(-14)
        }

        // 心情备注行
        let moodNoteField_flick = UITextField()
        moodNoteField_flick.tag = 8803
        moodNoteField_flick.backgroundColor = UIColor(hexstring_Flick: "#0D0D1A")
        moodNoteField_flick.textColor = UIColor(hexstring_Flick: "#D1D5DB")
        moodNoteField_flick.font = .systemFont(ofSize: 13)
        moodNoteField_flick.tintColor = UIColor(hexstring_Flick: "#F59E0B")
        moodNoteField_flick.attributedPlaceholder = NSAttributedString(
            string: "Add a mood note... (optional)",
            attributes: [.foregroundColor: UIColor(hexstring_Flick: "#4B5563")]
        )
        moodNoteField_flick.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        moodNoteField_flick.leftViewMode = .always
        moodNoteField_flick.layer.cornerRadius = 10
        moodNoteField_flick.clipsToBounds = true
        moodNoteField_flick.addTarget(self, action: #selector(handleMoodNoteChange_Flick(_:)), for: .editingChanged)
        card_flick.addSubview(moodNoteField_flick)
        moodNoteField_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(textView_flick.snp.bottom).offset(8)
            make_flick.left.equalToSuperview().offset(12)
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.height.equalTo(36)
        }

        // 心情 Emoji 行
        let moodRow_flick = buildMoodEmojiRow_Flick()
        card_flick.addSubview(moodRow_flick)
        moodRow_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(moodNoteField_flick.snp.bottom).offset(10)
            make_flick.left.equalToSuperview().offset(12)
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.height.equalTo(36)
        }

        // 解锁时间选择行
        let unlockRow_flick = buildUnlockOptionRow_Flick()
        card_flick.addSubview(unlockRow_flick)
        unlockRow_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(moodRow_flick.snp.bottom).offset(10)
            make_flick.left.equalToSuperview().offset(12)
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.height.equalTo(36)
        }

        // 封存按钮
        let sealBtn_flick = UIButton(type: .custom)
        sealBtn_flick.setTitle("🫙  Seal It", for: .normal)
        sealBtn_flick.setTitleColor(.white, for: .normal)
        sealBtn_flick.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        sealBtn_flick.backgroundColor = UIColor(hexstring_Flick: "#D97706")
        sealBtn_flick.layer.cornerRadius = 14
        sealBtn_flick.clipsToBounds = true
        sealBtn_flick.addTarget(self, action: #selector(handleSealCapsule_Flick), for: .touchUpInside)
        card_flick.addSubview(sealBtn_flick)
        sealBtn_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(unlockRow_flick.snp.bottom).offset(14)
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.width.equalTo(110)
            make_flick.height.equalTo(36)
            make_flick.bottom.equalToSuperview().offset(-14)
        }
        return card_flick
    }

    /// 构建心情 Emoji 选择行
    private func buildMoodEmojiRow_Flick() -> UIView {
        let container_flick = UIView()
        let label_flick = UILabel()
        label_flick.text = "Mood"
        label_flick.textColor = UIColor(hexstring_Flick: "#9CA3AF")
        label_flick.font = .systemFont(ofSize: 13)
        container_flick.addSubview(label_flick)
        label_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalToSuperview()
            make_flick.left.equalToSuperview()
        }

        let moods_flick = ["☀️", "🌊", "🌿", "🌙", "⚡", "🍂"]
        var prevBtn_flick: UIButton? = nil
        for (i_flick, emoji_flick) in moods_flick.enumerated() {
            let btn_flick = UIButton(type: .custom)
            btn_flick.tag = 8810 + i_flick
            btn_flick.setTitle(emoji_flick, for: .normal)
            btn_flick.titleLabel?.font = .systemFont(ofSize: 20)
            btn_flick.layer.cornerRadius = 16
            btn_flick.layer.borderWidth = (emoji_flick == capsuleMoodEmoji_Flick) ? 2 : 0
            btn_flick.layer.borderColor = UIColor(hexstring_Flick: "#F59E0B").cgColor
            btn_flick.addTarget(self, action: #selector(handleMoodSelect_Flick(_:)), for: .touchUpInside)
            container_flick.addSubview(btn_flick)
            btn_flick.snp.makeConstraints { make_flick in
                make_flick.centerY.equalToSuperview()
                make_flick.width.height.equalTo(32)
                if let prev_flick = prevBtn_flick {
                    make_flick.left.equalTo(prev_flick.snp.right).offset(6)
                } else {
                    make_flick.left.equalTo(label_flick.snp.right).offset(12)
                }
            }
            prevBtn_flick = btn_flick
        }
        return container_flick
    }

    /// 构建解锁时间选择行
    private func buildUnlockOptionRow_Flick() -> UIView {
        let container_flick = UIView()
        let label_flick = UILabel()
        label_flick.text = "Unlock"
        label_flick.textColor = UIColor(hexstring_Flick: "#9CA3AF")
        label_flick.font = .systemFont(ofSize: 13)
        container_flick.addSubview(label_flick)
        label_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalToSuperview()
            make_flick.left.equalToSuperview()
        }

        let options_flick = CapsuleUnlockOption_Flick.allCases
        var prevBtn_flick: UIButton? = nil
        for (i_flick, option_flick) in options_flick.enumerated() {
            let btn_flick = UIButton(type: .custom)
            btn_flick.tag = 8820 + i_flick
            btn_flick.setTitle(option_flick.label_Flick, for: .normal)
            btn_flick.setTitleColor(option_flick == capsuleUnlockOption_Flick ? .white : UIColor(hexstring_Flick: "#6B7280"), for: .normal)
            btn_flick.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
            btn_flick.backgroundColor = option_flick == capsuleUnlockOption_Flick
                ? UIColor(hexstring_Flick: "#D97706")
                : UIColor(hexstring_Flick: "#1C1C2E")
            btn_flick.layer.cornerRadius = 10
            btn_flick.clipsToBounds = true
            btn_flick.addTarget(self, action: #selector(handleUnlockOptionSelect_Flick(_:)), for: .touchUpInside)
            container_flick.addSubview(btn_flick)
            btn_flick.snp.makeConstraints { make_flick in
                make_flick.centerY.equalToSuperview()
                make_flick.height.equalTo(28)
                make_flick.width.greaterThanOrEqualTo(60)
                if let prev_flick = prevBtn_flick {
                    make_flick.left.equalTo(prev_flick.snp.right).offset(6)
                } else {
                    make_flick.left.equalTo(label_flick.snp.right).offset(10)
                }
            }
            prevBtn_flick = btn_flick
        }
        return container_flick
    }

    // MARK: - 事件处理 - 速记

    /// 点击「锁定」按钮，将输入框内容封存为速记
    @objc private func handleLockNote_Flick() {
        view.endEditing(true)
        guard UserViewModel_Flick.shared_Flick.isLoggedIn_Flick else {
            Utils_Flick.showWarning_Flick(message_Flick: "Please sign in to save a thought.")
            Navigation_Flick.toLogin_Flick(style_flick: .present_flick)
            return
        }
        let text_flick = pendingNoteText_Flick.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_flick.isEmpty else { return }
        guard UserViewModel_Flick.shared_Flick.addSpeedNote_Flick(content_flick: text_flick) != nil else { return }
        pendingNoteText_Flick = ""
        // 清空输入框
        if let inputCard_flick = findInputCard_Flick(),
           let tv_flick = inputCard_flick.viewWithTag(7701) as? UITextView {
            tv_flick.text = ""
            inputCard_flick.viewWithTag(7702)?.isHidden = false
            (inputCard_flick.viewWithTag(7703) as? UILabel)?.text = "0 / 200"
        }
    }

    /// 点击「封存」按钮，封存时间胶囊
    @objc private func handleSealCapsule_Flick() {
        view.endEditing(true)
        guard UserViewModel_Flick.shared_Flick.isLoggedIn_Flick else {
            Utils_Flick.showWarning_Flick(message_Flick: "Please sign in to seal a time capsule.")
            Navigation_Flick.toLogin_Flick(style_flick: .present_flick)
            return
        }
        let text_flick = capsuleText_Flick.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_flick.isEmpty else {
            shakeEmptyInput_Flick()
            return
        }
        UserViewModel_Flick.shared_Flick.sealTimeCapsule_Flick(
            content_flick: text_flick,
            moodNote_flick: capsuleMoodNote_Flick,
            moodEmoji_flick: capsuleMoodEmoji_Flick,
            unlockOption_flick: capsuleUnlockOption_Flick
        )
        capsuleText_Flick = ""
        capsuleMoodNote_Flick = ""
        // 清空胶囊输入框
        if let capsuleCard_flick = findCapsuleCard_Flick() {
            (capsuleCard_flick.viewWithTag(8801) as? UITextView)?.text = ""
            capsuleCard_flick.viewWithTag(8802)?.isHidden = false
            (capsuleCard_flick.viewWithTag(8803) as? UITextField)?.text = ""
        }
    }

    @objc private func handleMoodNoteChange_Flick(_ sender: UITextField) {
        capsuleMoodNote_Flick = sender.text ?? ""
    }

    @objc private func handleMoodSelect_Flick(_ sender: UIButton) {
        let moods_flick = ["☀️", "🌊", "🌿", "🌙", "⚡", "🍂"]
        let idx_flick = sender.tag - 8810
        guard idx_flick >= 0 && idx_flick < moods_flick.count else { return }
        capsuleMoodEmoji_Flick = moods_flick[idx_flick]
        // 刷新时间胶囊 Section 表头以更新选中样式
        tableView_Flick.reloadSections(
            IndexSet(integer: HomeSection_Flick.timeCapsule_flick.rawValue),
            with: .none
        )
    }

    @objc private func handleUnlockOptionSelect_Flick(_ sender: UIButton) {
        let options_flick = CapsuleUnlockOption_Flick.allCases
        let idx_flick = sender.tag - 8820
        guard idx_flick >= 0 && idx_flick < options_flick.count else { return }
        capsuleUnlockOption_Flick = options_flick[idx_flick]
        tableView_Flick.reloadSections(
            IndexSet(integer: HomeSection_Flick.timeCapsule_flick.rawValue),
            with: .none
        )
    }

    // MARK: - 辅助查找

    /// 查找速记输入卡片（通过 tag 标记）
    private func findInputCard_Flick() -> UIView? {
        return tableView_Flick.viewWithTag(7701)?.superview
    }

    /// 查找胶囊创建卡片（通过 tag 标记）
    private func findCapsuleCard_Flick() -> UIView? {
        return tableView_Flick.viewWithTag(8801)?.superview
    }

    /// 胶囊输入为空时抖动提示
    private func shakeEmptyInput_Flick() {
        let animation_flick = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_flick.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_flick.duration = 0.4
        animation_flick.values = [-8, 8, -6, 6, -4, 4, 0]
        findCapsuleCard_Flick()?.layer.add(animation_flick, forKey: "shake")
    }

    // MARK: - 通知响应

    @objc private func handleStateChange_Flick() {
        loadData_Flick()
        tableView_Flick.reloadData()
    }

    @objc private func handleChallengeChange_Flick() {
        challenges_Flick = TitleViewModel_Flick.shared_Flick.getChallenges_Flick()
        tableView_Flick.reloadSections(
            IndexSet(integer: HomeSection_Flick.challenge_flick.rawValue),
            with: .fade
        )
    }

    /// 统一设置列表底部内边距：平时为自定义 Tab 留白，键盘弹出时以键盘高度为准
    private func applyTableBottomInset_Flick(keyboardHeight_flick: CGFloat) {
        let bottom_flick = keyboardHeight_flick > 0
            ? keyboardHeight_flick + 8
            : customTabBarBottomInset_Flick
        let inset_flick = UIEdgeInsets(top: 0, left: 0, bottom: bottom_flick, right: 0)
        tableView_Flick.contentInset = inset_flick
        tableView_Flick.scrollIndicatorInsets = inset_flick
    }

    @objc private func handleKeyboardShow_Flick(_ notification_flick: Notification) {
        guard let info_flick = notification_flick.userInfo,
              let kbFrame_flick = (info_flick[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let dur_flick = info_flick[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let kbInView_flick = view.convert(kbFrame_flick, from: nil)
        let overlap_flick = max(0, view.bounds.maxY - kbInView_flick.minY)
        applyTableBottomInset_Flick(keyboardHeight_flick: overlap_flick)
        UIView.animate(withDuration: dur_flick) { self.view.layoutIfNeeded() }
    }

    @objc private func handleKeyboardHide_Flick(_ notification_flick: Notification) {
        let dur_flick = (notification_flick.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        UIView.animate(withDuration: dur_flick) {
            self.applyTableBottomInset_Flick(keyboardHeight_flick: 0)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension Home_Flick: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        HomeSection_Flick.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch HomeSection_Flick(rawValue: section) {
        case .speedNote_flick:
            return speedNotes_Flick.isEmpty ? 1 : speedNotes_Flick.count   // 1 = empty state
        case .challenge_flick:
            return challenges_Flick.count
        case .timeCapsule_flick:
            return capsules_Flick.isEmpty ? 1 : capsules_Flick.count       // 1 = empty state
        case .none:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch HomeSection_Flick(rawValue: indexPath.section) {

        case .speedNote_flick:
            if speedNotes_Flick.isEmpty {
                return makeEmptyCell_Flick(for: tableView, icon_flick: "⚡", text_flick: "Lock your first thought")
            }
            let cell_flick = tableView.dequeueReusableCell(withIdentifier: speedNoteId_Flick, for: indexPath) as! SpeedNoteCell_Flick
            cell_flick.configure_Flick(note_flick: speedNotes_Flick[indexPath.row], supplementText_Flick: supplementText_Flick)
            cell_flick.onDelete_Flick = { [weak self] noteId_flick in
                self?.confirmDeleteNote_Flick(noteId_flick: noteId_flick)
            }
            cell_flick.onAddSupplement_Flick = { [weak self] noteId_flick, text_flick in
                UserViewModel_Flick.shared_Flick.addSupplement_Flick(noteId_flick: noteId_flick, content_flick: text_flick)
                self?.supplementText_Flick[noteId_flick] = ""
            }
            cell_flick.onSupplementTextChange_Flick = { [weak self] noteId_flick, text_flick in
                self?.supplementText_Flick[noteId_flick] = text_flick
            }
            return cell_flick

        case .challenge_flick:
            let cell_flick = tableView.dequeueReusableCell(withIdentifier: challengeId_Flick, for: indexPath) as! ChallengePreviewCell_Flick
            cell_flick.configure_Flick(challenge_flick: challenges_Flick[indexPath.row])
            return cell_flick

        case .timeCapsule_flick:
            if capsules_Flick.isEmpty {
                return makeEmptyCell_Flick(for: tableView, icon_flick: "🫙", text_flick: "Your sealed thoughts will appear here")
            }
            let cell_flick = tableView.dequeueReusableCell(withIdentifier: capsuleId_Flick, for: indexPath) as! CapsuleItemCell_Flick
            cell_flick.configure_Flick(capsule_flick: capsules_Flick[indexPath.row])
            cell_flick.onDelete_Flick = { [weak self] capsuleId_flick in
                self?.confirmDeleteCapsule_Flick(capsuleId_flick: capsuleId_flick)
            }
            return cell_flick

        case .none:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch HomeSection_Flick(rawValue: section) {
        case .speedNote_flick:   return buildSpeedNoteHeader_Flick()
        case .challenge_flick:   return buildChallengeHeader_Flick()
        case .timeCapsule_flick: return buildCapsuleHeader_Flick()
        case .none:              return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch HomeSection_Flick(rawValue: section) {
        case .speedNote_flick:   return 200
        case .challenge_flick:   return 70
        case .timeCapsule_flick: return 260
        case .none:              return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { nil }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 16 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if HomeSection_Flick(rawValue: indexPath.section) == .challenge_flick,
           !challenges_Flick.isEmpty {
            Navigation_Flick.toChallengeDetail_Flick(with: challenges_Flick[indexPath.row])
        }
    }

    // MARK: - 辅助 Cell 构建

    private func makeEmptyCell_Flick(for tableView: UITableView, icon_flick: String, text_flick: String) -> UITableViewCell {
        let cell_flick = UITableViewCell()
        cell_flick.backgroundColor = .clear
        cell_flick.selectionStyle = .none
        let label_flick = UILabel()
        label_flick.text = "\(icon_flick)  \(text_flick)"
        label_flick.textColor = UIColor(hexstring_Flick: "#4B5563")
        label_flick.font = .systemFont(ofSize: 14)
        label_flick.textAlignment = .center
        cell_flick.contentView.addSubview(label_flick)
        label_flick.snp.makeConstraints { make_flick in
            make_flick.center.equalToSuperview()
            make_flick.top.equalToSuperview().offset(20)
            make_flick.bottom.equalToSuperview().offset(-20)
        }
        return cell_flick
    }

    // MARK: - 删除确认

    private func confirmDeleteNote_Flick(noteId_flick: String) {
        let alert_flick = UIAlertController(
            title: "Delete this thought?",
            message: "This cannot be undone.",
            preferredStyle: .alert
        )
        alert_flick.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_flick.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            UserViewModel_Flick.shared_Flick.deleteSpeedNote_Flick(noteId_flick: noteId_flick)
            self?.supplementText_Flick.removeValue(forKey: noteId_flick)
        }))
        present(alert_flick, animated: true)
    }

    private func confirmDeleteCapsule_Flick(capsuleId_flick: String) {
        let alert_flick = UIAlertController(
            title: "Delete this capsule?",
            message: "Sealed content will be removed permanently.",
            preferredStyle: .alert
        )
        alert_flick.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_flick.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            UserViewModel_Flick.shared_Flick.deleteTimeCapsule_Flick(capsuleId_flick: capsuleId_flick)
        }))
        present(alert_flick, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension Home_Flick: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 7701 {
            // 速记输入
            let text_flick = textView.text ?? ""
            pendingNoteText_Flick = text_flick
            // 限制 200 字
            if text_flick.count > 200 { textView.text = String(text_flick.prefix(200)) }
            textView.superview?.viewWithTag(7702)?.isHidden = !text_flick.isEmpty
            if let countLbl_flick = textView.superview?.viewWithTag(7703) as? UILabel {
                countLbl_flick.text = "\(textView.text.count) / 200"
            }
            // 动态高度刷新
            let size_flick = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .infinity))
            if textView.bounds.height != size_flick.height { tableView_Flick.beginUpdates(); tableView_Flick.endUpdates() }
        } else if textView.tag == 8801 {
            // 胶囊输入
            let text_flick = textView.text ?? ""
            capsuleText_Flick = text_flick
            textView.superview?.viewWithTag(8802)?.isHidden = !text_flick.isEmpty
            let size_flick = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .infinity))
            if textView.bounds.height != size_flick.height { tableView_Flick.beginUpdates(); tableView_Flick.endUpdates() }
        }
    }
}

// MARK: - 速记单元格

/// 速记列表单元格
/// 功能：展示单条速记（含时间锁、原始内容、补充列表），支持追加补充、删除整条
class SpeedNoteCell_Flick: UITableViewCell {

    // MARK: - UI 组件

    private let cardView_Flick: UIView = {
        let v_flick = UIView()
        v_flick.backgroundColor = UIColor(hexstring_Flick: "#111127")
        v_flick.layer.cornerRadius = 16
        v_flick.layer.borderWidth = 1
        v_flick.layer.borderColor = UIColor(hexstring_Flick: "#7C3AED").withValues(alpha: 0.2).cgColor
        v_flick.clipsToBounds = true
        return v_flick
    }()

    private let lockIcon_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.text = "🔒"
        lbl_flick.font = .systemFont(ofSize: 12)
        return lbl_flick
    }()

    private let timeLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = UIColor(hexstring_Flick: "#7C3AED")
        lbl_flick.font = .systemFont(ofSize: 11, weight: .medium)
        return lbl_flick
    }()

    private let deleteBtn_Flick: UIButton = {
        let btn_flick = UIButton(type: .custom)
        let img_flick = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        btn_flick.setImage(img_flick, for: .normal)
        btn_flick.tintColor = UIColor(hexstring_Flick: "#4B5563")
        return btn_flick
    }()

    private let contentLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = .white
        lbl_flick.font = .systemFont(ofSize: 15)
        lbl_flick.numberOfLines = 0
        return lbl_flick
    }()

    private let supplementStack_Flick: UIStackView = {
        let sv_flick = UIStackView()
        sv_flick.axis = .vertical
        sv_flick.spacing = 6
        return sv_flick
    }()

    private let addSupplementRow_Flick: UIView = UIView()
    private let supplementField_Flick: UITextField = {
        let tf_flick = UITextField()
        tf_flick.backgroundColor = UIColor(hexstring_Flick: "#1C1C2E")
        tf_flick.textColor = UIColor(hexstring_Flick: "#D1D5DB")
        tf_flick.font = .systemFont(ofSize: 13)
        tf_flick.tintColor = UIColor(hexstring_Flick: "#A78BFA")
        tf_flick.attributedPlaceholder = NSAttributedString(
            string: "+ Add a supplement...",
            attributes: [.foregroundColor: UIColor(hexstring_Flick: "#4B5563")]
        )
        tf_flick.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        tf_flick.leftViewMode = .always
        tf_flick.layer.cornerRadius = 10
        tf_flick.clipsToBounds = true
        return tf_flick
    }()
    private let addBtn_Flick: UIButton = {
        let btn_flick = UIButton(type: .custom)
        btn_flick.setTitle("+", for: .normal)
        btn_flick.setTitleColor(.white, for: .normal)
        btn_flick.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn_flick.backgroundColor = UIColor(hexstring_Flick: "#7C3AED")
        btn_flick.layer.cornerRadius = 14
        btn_flick.clipsToBounds = true
        return btn_flick
    }()

    // MARK: - 回调

    var onDelete_Flick: ((String) -> Void)?
    var onAddSupplement_Flick: ((String, String) -> Void)?
    var onSupplementTextChange_Flick: ((String, String) -> Void)?

    private var noteId_Flick: String = ""

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - 私有方法

    private func setupUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView_Flick)
        cardView_Flick.addSubview(lockIcon_Flick)
        cardView_Flick.addSubview(timeLabel_Flick)
        cardView_Flick.addSubview(deleteBtn_Flick)
        cardView_Flick.addSubview(contentLabel_Flick)
        cardView_Flick.addSubview(supplementStack_Flick)

        // 追加行
        addSupplementRow_Flick.addSubview(supplementField_Flick)
        addSupplementRow_Flick.addSubview(addBtn_Flick)
        supplementField_Flick.snp.makeConstraints { make_flick in
            make_flick.top.bottom.left.equalToSuperview()
            make_flick.right.equalTo(addBtn_Flick.snp.left).offset(-8)
        }
        addBtn_Flick.snp.makeConstraints { make_flick in
            make_flick.top.bottom.right.equalToSuperview()
            make_flick.width.equalTo(28)
        }
        cardView_Flick.addSubview(addSupplementRow_Flick)

        cardView_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(6)
            make_flick.bottom.equalToSuperview().offset(-6)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.right.equalToSuperview().offset(-16)
        }
        lockIcon_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(12)
            make_flick.left.equalToSuperview().offset(14)
        }
        timeLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(lockIcon_Flick)
            make_flick.left.equalTo(lockIcon_Flick.snp.right).offset(6)
        }
        deleteBtn_Flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(lockIcon_Flick)
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.width.height.equalTo(24)
        }
        contentLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(lockIcon_Flick.snp.bottom).offset(8)
            make_flick.left.equalToSuperview().offset(14)
            make_flick.right.equalToSuperview().offset(-14)
        }
        supplementStack_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(contentLabel_Flick.snp.bottom).offset(10)
            make_flick.left.equalToSuperview().offset(14)
            make_flick.right.equalToSuperview().offset(-14)
        }
        addSupplementRow_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(supplementStack_Flick.snp.bottom).offset(8)
            make_flick.left.equalToSuperview().offset(14)
            make_flick.right.equalToSuperview().offset(-14)
            make_flick.height.equalTo(32)
            make_flick.bottom.equalToSuperview().offset(-12)
        }

        deleteBtn_Flick.addTarget(self, action: #selector(handleDelete_Flick), for: .touchUpInside)
        addBtn_Flick.addTarget(self, action: #selector(handleAddSupplement_Flick), for: .touchUpInside)
        supplementField_Flick.addTarget(self, action: #selector(handleSupplementTextChange_Flick(_:)), for: .editingChanged)
    }

    @objc private func handleDelete_Flick() {
        onDelete_Flick?(noteId_Flick)
    }

    @objc private func handleAddSupplement_Flick() {
        let text_flick = supplementField_Flick.text ?? ""
        onAddSupplement_Flick?(noteId_Flick, text_flick)
        supplementField_Flick.text = ""
    }

    @objc private func handleSupplementTextChange_Flick(_ sender: UITextField) {
        onSupplementTextChange_Flick?(noteId_Flick, sender.text ?? "")
    }

    // MARK: - 配置

    /// 配置单元格内容
    /// - Parameters:
    ///   - note_flick: 速记数据对象
    ///   - supplementText_Flick: 当前各速记的输入框临时文字字典
    func configure_Flick(note_flick: SpeedNote_Flick, supplementText_Flick: [String: String]) {
        noteId_Flick = note_flick.noteId_Flick
        let df_flick = DateFormatter()
        df_flick.dateFormat = "MM/dd HH:mm"
        timeLabel_Flick.text = df_flick.string(from: Date(timeIntervalSince1970: note_flick.createTime_Flick))
        contentLabel_Flick.text = note_flick.content_Flick
        supplementField_Flick.text = supplementText_Flick[note_flick.noteId_Flick] ?? ""

        // 重建补充列表
        supplementStack_Flick.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for sup_flick in note_flick.supplements_Flick {
            let row_flick = UIView()
            let bullet_flick = UIView()
            bullet_flick.backgroundColor = UIColor(hexstring_Flick: "#7C3AED")
            bullet_flick.layer.cornerRadius = 3
            let supLabel_flick = UILabel()
            supLabel_flick.text = sup_flick.content_Flick
            supLabel_flick.textColor = UIColor(hexstring_Flick: "#D1D5DB")
            supLabel_flick.font = .systemFont(ofSize: 13)
            supLabel_flick.numberOfLines = 0
            row_flick.addSubview(bullet_flick)
            row_flick.addSubview(supLabel_flick)
            bullet_flick.snp.makeConstraints { make_flick in
                make_flick.top.equalToSuperview().offset(5)
                make_flick.left.equalToSuperview()
                make_flick.width.height.equalTo(6)
            }
            supLabel_flick.snp.makeConstraints { make_flick in
                make_flick.top.bottom.right.equalToSuperview()
                make_flick.left.equalTo(bullet_flick.snp.right).offset(8)
            }
            supplementStack_Flick.addArrangedSubview(row_flick)
        }
    }
}

// MARK: - 挑战预览单元格

/// 官方碎念挑战预览单元格
/// 功能：展示挑战前半段文字、标签、完成人数，点击进入详情页
class ChallengePreviewCell_Flick: UITableViewCell {

    // MARK: - UI 组件

    private let cardView_Flick: UIView = {
        let v_flick = UIView()
        v_flick.layer.cornerRadius = 18
        v_flick.clipsToBounds = true
        return v_flick
    }()

    private let gradientLayer_Flick: CAGradientLayer = {
        let gl_flick = CAGradientLayer()
        gl_flick.colors = [
            UIColor(hexstring_Flick: "#3B0764").cgColor,
            UIColor(hexstring_Flick: "#1E1040").cgColor
        ]
        gl_flick.startPoint = CGPoint(x: 0, y: 0)
        gl_flick.endPoint = CGPoint(x: 1, y: 1)
        return gl_flick
    }()

    private let tagLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = UIColor(hexstring_Flick: "#C4B5FD")
        lbl_flick.font = .systemFont(ofSize: 11, weight: .semibold)
        lbl_flick.backgroundColor = UIColor(hexstring_Flick: "#7C3AED").withValues(alpha: 0.4)
        lbl_flick.layer.cornerRadius = 9
        lbl_flick.clipsToBounds = true
        lbl_flick.textAlignment = .center
        return lbl_flick
    }()

    private let quoteLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = .white
        lbl_flick.font = UIFont(name: "Georgia-Italic", size: 18) ?? .italicSystemFont(ofSize: 18)
        lbl_flick.numberOfLines = 0
        return lbl_flick
    }()

    private let countLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = UIColor(hexstring_Flick: "#9CA3AF")
        lbl_flick.font = .systemFont(ofSize: 12)
        return lbl_flick
    }()

    private let arrowLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.text = "Complete →"
        lbl_flick.textColor = UIColor(hexstring_Flick: "#A78BFA")
        lbl_flick.font = .systemFont(ofSize: 13, weight: .medium)
        return lbl_flick
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Flick.frame = cardView_Flick.bounds
    }

    // MARK: - 私有方法

    private func setupUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView_Flick)
        cardView_Flick.layer.insertSublayer(gradientLayer_Flick, at: 0)
        cardView_Flick.addSubview(tagLabel_Flick)
        cardView_Flick.addSubview(quoteLabel_Flick)
        cardView_Flick.addSubview(countLabel_Flick)
        cardView_Flick.addSubview(arrowLabel_Flick)

        cardView_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(6)
            make_flick.bottom.equalToSuperview().offset(-6)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.right.equalToSuperview().offset(-16)
        }
        tagLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(16)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.height.equalTo(20)
            make_flick.width.greaterThanOrEqualTo(50)
        }
        quoteLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(tagLabel_Flick.snp.bottom).offset(10)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.right.equalToSuperview().offset(-16)
        }
        countLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(quoteLabel_Flick.snp.bottom).offset(12)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.bottom.equalToSuperview().offset(-16)
        }
        arrowLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(countLabel_Flick)
            make_flick.right.equalToSuperview().offset(-16)
        }
    }

    /// 配置单元格
    /// - Parameter challenge_flick: 挑战数据
    func configure_Flick(challenge_flick: HalfChallenge_Flick) {
        tagLabel_Flick.text = "  \(challenge_flick.tag_Flick)  "
        quoteLabel_Flick.text = "\u{201C}\(challenge_flick.firstHalf_Flick)\u{201D}"
        let count_flick = challenge_flick.completions_Flick.count
        countLabel_Flick.text = count_flick == 0 ? "Be first to complete" : "\(count_flick) completed"
    }
}

// MARK: - 时间胶囊单元格

/// 时间胶囊列表单元格
/// 功能：展示单条时间胶囊，支持删除；未解锁时显示倒计时，已解锁时展示内容
class CapsuleItemCell_Flick: UITableViewCell {

    // MARK: - UI 组件

    private let cardView_Flick: UIView = {
        let v_flick = UIView()
        v_flick.layer.cornerRadius = 16
        v_flick.clipsToBounds = true
        return v_flick
    }()

    private let gradientLayer_Flick: CAGradientLayer = {
        let gl_flick = CAGradientLayer()
        gl_flick.colors = [
            UIColor(hexstring_Flick: "#1A1A0A").cgColor,
            UIColor(hexstring_Flick: "#2A1F0A").cgColor
        ]
        return gl_flick
    }()

    private let lockBadge_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.font = .systemFont(ofSize: 22)
        return lbl_flick
    }()

    private let moodEmoji_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.font = .systemFont(ofSize: 22)
        return lbl_flick
    }()

    private let titleLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = UIColor(hexstring_Flick: "#F59E0B")
        lbl_flick.font = .systemFont(ofSize: 12, weight: .semibold)
        return lbl_flick
    }()

    private let contentLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = .white
        lbl_flick.font = .systemFont(ofSize: 14)
        lbl_flick.numberOfLines = 3
        return lbl_flick
    }()

    private let moodNote_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = UIColor(hexstring_Flick: "#9CA3AF")
        lbl_flick.font = .systemFont(ofSize: 12, weight: .light)
        lbl_flick.numberOfLines = 1
        return lbl_flick
    }()

    private let deleteBtn_Flick: UIButton = {
        let btn_flick = UIButton(type: .custom)
        let img_flick = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        btn_flick.setImage(img_flick, for: .normal)
        btn_flick.tintColor = UIColor(hexstring_Flick: "#4B5563")
        return btn_flick
    }()

    // MARK: - 回调

    var onDelete_Flick: ((String) -> Void)?
    private var capsuleId_Flick: String = ""

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Flick.frame = cardView_Flick.bounds
    }

    // MARK: - 私有方法

    private func setupUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView_Flick)
        cardView_Flick.layer.insertSublayer(gradientLayer_Flick, at: 0)
        cardView_Flick.addSubview(lockBadge_Flick)
        cardView_Flick.addSubview(moodEmoji_Flick)
        cardView_Flick.addSubview(titleLabel_Flick)
        cardView_Flick.addSubview(contentLabel_Flick)
        cardView_Flick.addSubview(moodNote_Flick)
        cardView_Flick.addSubview(deleteBtn_Flick)

        cardView_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(6)
            make_flick.bottom.equalToSuperview().offset(-6)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.right.equalToSuperview().offset(-16)
        }
        lockBadge_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(14)
            make_flick.left.equalToSuperview().offset(14)
        }
        moodEmoji_Flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(lockBadge_Flick)
            make_flick.left.equalTo(lockBadge_Flick.snp.right).offset(6)
        }
        titleLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(lockBadge_Flick)
            make_flick.left.equalTo(moodEmoji_Flick.snp.right).offset(8)
        }
        deleteBtn_Flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(lockBadge_Flick)
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.width.height.equalTo(24)
        }
        contentLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(lockBadge_Flick.snp.bottom).offset(10)
            make_flick.left.equalToSuperview().offset(14)
            make_flick.right.equalToSuperview().offset(-14)
        }
        moodNote_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(contentLabel_Flick.snp.bottom).offset(6)
            make_flick.left.equalToSuperview().offset(14)
            make_flick.right.equalToSuperview().offset(-14)
            make_flick.bottom.equalToSuperview().offset(-14)
        }

        deleteBtn_Flick.addTarget(self, action: #selector(handleDelete_Flick), for: .touchUpInside)
    }

    @objc private func handleDelete_Flick() {
        onDelete_Flick?(capsuleId_Flick)
    }

    // MARK: - 配置

    /// 配置单元格
    /// - Parameter capsule_flick: 时间胶囊数据
    func configure_Flick(capsule_flick: TimeCapsule_Flick) {
        capsuleId_Flick = capsule_flick.capsuleId_Flick
        moodEmoji_Flick.text = capsule_flick.moodEmoji_Flick

        if capsule_flick.isUnlocked_Flick {
            // 已解锁：展示内容
            lockBadge_Flick.text = "🔓"
            titleLabel_Flick.text = "Unsealed"
            contentLabel_Flick.text = capsule_flick.content_Flick
            contentLabel_Flick.textColor = .white
        } else {
            // 未解锁：显示倒计时
            lockBadge_Flick.text = "🔐"
            let unlockDate_flick = Date(timeIntervalSince1970: capsule_flick.unlockTime_Flick)
            let df_flick = DateFormatter()
            df_flick.dateFormat = "MMM d, yyyy"
            titleLabel_Flick.text = "Unlocks \(df_flick.string(from: unlockDate_flick))"
            contentLabel_Flick.text = "🔐  Sealed until the future..."
            contentLabel_Flick.textColor = UIColor(hexstring_Flick: "#6B7280")
        }

        let note_flick = capsule_flick.moodNote_Flick.trimmingCharacters(in: .whitespacesAndNewlines)
        moodNote_Flick.text = note_flick.isEmpty ? nil : "\"\(note_flick)\""
        moodNote_Flick.isHidden = note_flick.isEmpty
    }
}
