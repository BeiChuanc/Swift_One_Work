import Foundation
import UIKit
import SnapKit

// MARK: - 首页

/// 首页视图控制器
/// 核心作用：聚合四大胶片功能模块，以纵向滚动方式呈现
/// 设计思路：
///   - 暖色调纸质背景（#F8F3EC）模拟冲洗相纸质感
///   - 每个模块作为独立 UIView，职责单一
///   - 通知驱动刷新，保证数据实时性
/// 关键属性：
///   - filmVM_Lumia: 胶片业务 ViewModel（今日卷/胶片柜/胶囊/主题）
class Home_Lumia: UIViewController {

    // MARK: - 私有属性

    private let filmVM_Lumia = FilmViewModel_Lumia.shared_Lumia

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        sv_Lumia.alwaysBounceVertical = true
        return sv_Lumia
    }()

    private let contentStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 20
        sv_Lumia.alignment = .fill
        return sv_Lumia
    }()

    private lazy var filmWallSection_Lumia = TodayFilmWallView_Lumia()
    private lazy var cabinetSection_Lumia = FilmCabinetView_Lumia()
    private lazy var capsuleSection_Lumia = TimeCapsuleView_Lumia()
    private lazy var themeSection_Lumia = ThemeDiscussionView_Lumia()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#F8F3EC")
        setupUI_Lumia()
        setupObservers_Lumia()
        reloadAll_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadAll_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 底部内容内边距，防止被 Tab Bar 遮挡
        scrollView_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        scrollView_Lumia.addSubview(contentStack_Lumia)
        contentStack_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            // 距屏幕左右各 20pt
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 顶部标题行
        contentStack_Lumia.addArrangedSubview(buildHeaderView_Lumia())

        // 功能模块
        contentStack_Lumia.addArrangedSubview(filmWallSection_Lumia)
        contentStack_Lumia.addArrangedSubview(cabinetSection_Lumia)
        contentStack_Lumia.addArrangedSubview(capsuleSection_Lumia)
        contentStack_Lumia.addArrangedSubview(themeSection_Lumia)

        // 各模块回调绑定
        filmWallSection_Lumia.onShootTapped_Lumia = { [weak self] in self?.handleShoot_Lumia() }
        filmWallSection_Lumia.onDevelopTapped_Lumia = { [weak self] in self?.handleDevelop_Lumia() }
        filmWallSection_Lumia.onDeleteFrame_Lumia = { [weak self] frameIndex_Lumia in
            self?.handleDeleteFrame_Lumia(frameIndex: frameIndex_Lumia)
        }

        cabinetSection_Lumia.onRollTapped_Lumia = { [weak self] roll_Lumia in
            self?.openRollViewer_Lumia(roll: roll_Lumia)
        }
        cabinetSection_Lumia.onNewRollTapped_Lumia = { [weak self] in self?.handleNewRoll_Lumia() }
        cabinetSection_Lumia.onDeleteRoll_Lumia = { [weak self] roll_Lumia in
            self?.handleDeleteRoll_Lumia(roll: roll_Lumia)
        }

        capsuleSection_Lumia.onCreateTapped_Lumia = { [weak self] in self?.handleCreateCapsule_Lumia() }
        capsuleSection_Lumia.onCapsuleTapped_Lumia = { [weak self] capsule_Lumia in
            self?.handleCapsuleTap_Lumia(capsule: capsule_Lumia)
        }
        capsuleSection_Lumia.onDeleteCapsule_Lumia = { [weak self] capsule_Lumia in
            self?.handleDeleteCapsule_Lumia(capsule: capsule_Lumia)
        }

        themeSection_Lumia.onEnterDiscussion_Lumia = { [weak self] theme_Lumia in
            self?.handleEnterDiscussion_Lumia(theme: theme_Lumia)
        }
    }

    private func buildHeaderView_Lumia() -> UIView {
        let header_Lumia = UIView()

        // 胶片孔装饰（与 Home 主题呼应）
        let filmIcon_Lumia = UIImageView(image: UIImage(systemName: "camera.aperture"))
        filmIcon_Lumia.tintColor = UIColor(hexstring_Lumia: "#F6A623")
        filmIcon_Lumia.contentMode = .scaleAspectFit
        header_Lumia.addSubview(filmIcon_Lumia)
        filmIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        let logoLabel_Lumia = UILabel()
        let attrs_Lumia: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "AvenirNext-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor(hexstring_Lumia: "#2A1008"),
            .kern: 4.0
        ]
        logoLabel_Lumia.attributedText = NSAttributedString(string: "LUMIA", attributes: attrs_Lumia)
        header_Lumia.addSubview(logoLabel_Lumia)
        logoLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(filmIcon_Lumia.snp.trailing).offset(8)
            make.top.bottom.equalToSuperview()
        }

        let dateLabel_Lumia = UILabel()
        let df_Lumia = DateFormatter()
        df_Lumia.dateFormat = "MMM d"
        dateLabel_Lumia.text = df_Lumia.string(from: Date())
        dateLabel_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        dateLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#C08060")
        header_Lumia.addSubview(dateLabel_Lumia)
        dateLabel_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(logoLabel_Lumia)
        }

        return header_Lumia
    }

    // MARK: - 数据刷新

    private func reloadAll_Lumia() {
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else { return }
        let todayRoll_Lumia = filmVM_Lumia.getTodayRoll_Lumia()
        filmWallSection_Lumia.configure_Lumia(roll: todayRoll_Lumia)

        let developedRolls_Lumia = filmVM_Lumia.getDevelopedRolls_Lumia()
        cabinetSection_Lumia.configure_Lumia(rolls: developedRolls_Lumia)

        let capsules_Lumia = filmVM_Lumia.getCapsules_Lumia()
        capsuleSection_Lumia.configure_Lumia(capsules: capsules_Lumia)

        let theme_Lumia = filmVM_Lumia.getCurrentTheme_Lumia()
        let comments_Lumia = filmVM_Lumia.getDiscussionComments_Lumia(themeId: theme_Lumia.themeId_Lumia)
        themeSection_Lumia.configure_Lumia(theme: theme_Lumia, comments: comments_Lumia)
    }

    // MARK: - 通知

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleStateChange_Lumia() { reloadAll_Lumia() }
    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 事件处理

    /// 拍摄：打开图片选择器，将选取的照片曝光到今日胶片卷
    private func handleShoot_Lumia() {
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else {
            Navigation_Lumia.toLogin_Lumia(style_lumia: .present_lumia)
            return
        }
        let roll_Lumia = filmVM_Lumia.getTodayRoll_Lumia()
        guard !roll_Lumia.isFull_Lumia else {
            Utils_Lumia.showInfo_Lumia(message_Lumia: "Today's roll is full! Develop it to start a new one.")
            return
        }
        MediaPickerHelper_Lumia.pickImage_Lumia(from: self) { [weak self] image_Lumia in
            guard let self = self, let image_Lumia = image_Lumia else { return }
            let savedPath_Lumia = self.filmVM_Lumia.saveImageToDocuments_Lumia(image: image_Lumia)
            let success_Lumia = self.filmVM_Lumia.exposeNextFrame_Lumia(imagePath: savedPath_Lumia, note: nil)
            if success_Lumia {
                self.reloadAll_Lumia()
                Utils_Lumia.showSuccess_Lumia(message_Lumia: "Frame exposed! ✦")
            }
        }
    }

    /// 冲洗：将今日卷标记为已冲洗，移入胶片柜
    private func handleDevelop_Lumia() {
        let roll_Lumia = filmVM_Lumia.getTodayRoll_Lumia()
        guard roll_Lumia.exposedCount_Lumia > 0 else {
            Utils_Lumia.showInfo_Lumia(message_Lumia: "No frames exposed yet. Start shooting first!")
            return
        }
        let alert_Lumia = UIAlertController(
            title: "Develop Roll",
            message: "Develop '\(roll_Lumia.rollName_Lumia)'? It will be moved to your Film Cabinet.",
            preferredStyle: .alert
        )
        alert_Lumia.addAction(UIAlertAction(title: "Develop", style: .default) { [weak self] _ in
            self?.filmVM_Lumia.developTodayRoll_Lumia()
            self?.reloadAll_Lumia()
            Utils_Lumia.showSuccess_Lumia(message_Lumia: "Roll developed and saved to cabinet!")
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }

    /// 新建胶片卷（仅在今日卷已冲洗后可用）
    private func handleNewRoll_Lumia() {
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else {
            Navigation_Lumia.toLogin_Lumia(style_lumia: .present_lumia)
            return
        }
        filmVM_Lumia.startNewRoll_Lumia()
        reloadAll_Lumia()
        Utils_Lumia.showSuccess_Lumia(message_Lumia: "New roll loaded! Start shooting.")
    }

    /// 打开胶片卷查看器
    private func openRollViewer_Lumia(roll: FilmRoll_Lumia) {
        let viewer_Lumia = FilmRollViewerSheet_Lumia(roll: roll)
        viewer_Lumia.modalPresentationStyle = .fullScreen
        viewer_Lumia.modalTransitionStyle = .crossDissolve
        present(viewer_Lumia, animated: true)
    }

    /// 创建时光胶囊
    private func handleCreateCapsule_Lumia() {
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else {
            Navigation_Lumia.toLogin_Lumia(style_lumia: .present_lumia)
            return
        }
        let sheet_Lumia = CreateCapsuleSheet_Lumia()
        sheet_Lumia.onCreated_Lumia = { [weak self] message_Lumia, imagePath_Lumia, unlockDate_Lumia in
            self?.filmVM_Lumia.createCapsule_Lumia(message: message_Lumia, imagePath: imagePath_Lumia, unlockDate: unlockDate_Lumia)
            self?.reloadAll_Lumia()
            Utils_Lumia.showSuccess_Lumia(message_Lumia: "Capsule sealed! It will unlock on \(unlockDate_Lumia).")
        }
        sheet_Lumia.modalPresentationStyle = .fullScreen
        sheet_Lumia.modalTransitionStyle = .crossDissolve
        present(sheet_Lumia, animated: true)
    }

    /// 点击时光胶囊（解锁或查看）
    private func handleCapsuleTap_Lumia(capsule: TimeCapsule_Lumia) {
        if capsule.canReveal_Lumia {
            filmVM_Lumia.revealCapsule_Lumia(capsuleId: capsule.capsuleId_Lumia)
            reloadAll_Lumia()
            let alert_Lumia = UIAlertController(title: "Capsule Revealed ✦",
                                                message: capsule.message_Lumia,
                                                preferredStyle: .alert)
            alert_Lumia.addAction(UIAlertAction(title: "Close", style: .cancel))
            present(alert_Lumia, animated: true)
        } else {
            Utils_Lumia.showInfo_Lumia(message_Lumia: "Unlocks on \(capsule.unlockDateString_Lumia) 📅")
        }
    }

    /// 删除今日胶片墙指定帧（带确认）
    private func handleDeleteFrame_Lumia(frameIndex: Int) {
        let alert_Lumia = UIAlertController(title: "Delete Frame",
                                            message: "Remove frame #\(frameIndex) from today's roll?",
                                            preferredStyle: .alert)
        alert_Lumia.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.filmVM_Lumia.deleteFrame_Lumia(frameIndex: frameIndex)
            self?.reloadAll_Lumia()
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }

    /// 删除胶片柜中指定卷（带确认）
    private func handleDeleteRoll_Lumia(roll: FilmRoll_Lumia) {
        let alert_Lumia = UIAlertController(title: "Delete Roll",
                                            message: "Permanently delete '\(roll.rollName_Lumia)' and all its frames?",
                                            preferredStyle: .alert)
        alert_Lumia.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.filmVM_Lumia.deleteRoll_Lumia(rollId: roll.rollId_Lumia)
            self?.reloadAll_Lumia()
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }

    /// 删除时光胶囊（带确认）
    private func handleDeleteCapsule_Lumia(capsule: TimeCapsule_Lumia) {
        let alert_Lumia = UIAlertController(title: "Delete Capsule",
                                            message: "Permanently delete this time capsule?",
                                            preferredStyle: .alert)
        alert_Lumia.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.filmVM_Lumia.deleteCapsule_Lumia(capsuleId: capsule.capsuleId_Lumia)
            self?.reloadAll_Lumia()
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
    }

    /// 进入主题讨论详情页
    private func handleEnterDiscussion_Lumia(theme: FilmTheme_Lumia) {
        let detail_Lumia = ThemeDiscussionDetail_Lumia(theme: theme)
        detail_Lumia.onCommentAdded_Lumia = { [weak self] in self?.reloadAll_Lumia() }
        detail_Lumia.modalPresentationStyle = .fullScreen
        detail_Lumia.modalTransitionStyle = .coverVertical
        present(detail_Lumia, animated: true)
    }
}

// MARK: - 胶片 ViewModel

/// 胶片功能业务逻辑层
/// 核心作用：管理今日胶片卷的曝光、冲洗，胶片柜列表，时光胶囊的创建/解锁，主题征集的提交/读取
class FilmViewModel_Lumia {

    static let shared_Lumia = FilmViewModel_Lumia()

    /// 讨论区评论存储（themeId → 评论列表），内存持久，进程内有效
    private var discussionComments_Lumia: [Int: [ThemeDiscussionComment_Lumia]] = [:]
    private var commentIdCounter_Lumia: Int = 100

    private init() {
        seedDiscussionComments_Lumia()
    }

    // MARK: - 讨论区评论

    /// 获取指定主题的所有评论（时间正序）
    func getDiscussionComments_Lumia(themeId: Int) -> [ThemeDiscussionComment_Lumia] {
        return discussionComments_Lumia[themeId] ?? []
    }

    /// 当前用户发表评论
    func addDiscussionComment_Lumia(themeId: Int, content: String) {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()
        let comment_Lumia = ThemeDiscussionComment_Lumia(
            commentId_Lumia: commentIdCounter_Lumia,
            userId_Lumia: user_Lumia.userId_Lumia ?? 0,
            userName_Lumia: user_Lumia.userName_Lumia ?? "Me",
            userHead_Lumia: user_Lumia.userHead_Lumia,
            content_Lumia: content
        )
        commentIdCounter_Lumia += 1
        if discussionComments_Lumia[themeId] == nil {
            discussionComments_Lumia[themeId] = []
        }
        discussionComments_Lumia[themeId]?.append(comment_Lumia)
    }

    /// 删除指定评论
    func deleteDiscussionComment_Lumia(themeId: Int, commentId: Int) {
        discussionComments_Lumia[themeId]?.removeAll { $0.commentId_Lumia == commentId }
    }

    /// 预置示例评论（让讨论区初始有内容）
    private func seedDiscussionComments_Lumia() {
        let users_Lumia = LocalData_Lumia.shared_Lumia.userList_Lumia
        let seedData_Lumia: [(Int, Int, String)] = [
            (1, 0, "The golden hour light this week was absolutely stunning, especially on Portra 400!"),
            (1, 1, "I shot mine on Velvia 50 — the saturation at sunset was unreal. Highly recommend it."),
            (1, 2, "Film grain really adds something to the warmth. Can't replicate this digitally."),
            (1, 3, "Spent the whole evening waiting for the perfect light. Worth every minute."),
            (2, 0, "The puddle reflections after last night's rain were perfect for this theme."),
            (2, 1, "I pushed HP5 to 1600 — the grain at night looks incredible on wet pavement."),
            (2, 2, "Found a neon sign reflecting off a puddle. Pure magic on film."),
            (3, 0, "Natural light portraits are so honest. No filter, no pretense."),
            (3, 1, "Shot my grandma in morning light. The softness on Portra 160 is unmatched."),
        ]
        var counter_Lumia = 1
        for (themeId_Lumia, userIdx_Lumia, content_Lumia) in seedData_Lumia {
            let user_Lumia = userIdx_Lumia < users_Lumia.count ? users_Lumia[userIdx_Lumia] : nil
            let comment_Lumia = ThemeDiscussionComment_Lumia(
                commentId_Lumia: counter_Lumia,
                userId_Lumia: user_Lumia?.userId_Lumia ?? (10 + userIdx_Lumia),
                userName_Lumia: user_Lumia?.userName_Lumia ?? "Photographer",
                userHead_Lumia: user_Lumia?.userHead_Lumia,
                content_Lumia: content_Lumia
            )
            if discussionComments_Lumia[themeId_Lumia] == nil {
                discussionComments_Lumia[themeId_Lumia] = []
            }
            discussionComments_Lumia[themeId_Lumia]?.append(comment_Lumia)
            counter_Lumia += 1
        }
        commentIdCounter_Lumia = counter_Lumia + 10
    }

    // MARK: - 今日胶片墙

    /// 获取今日胶片卷（若不存在则自动新建）
    func getTodayRoll_Lumia() -> FilmRoll_Lumia {
        let today_Lumia = dateString_Lumia(from: Date())
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else {
            return FilmRoll_Lumia(rollId_Lumia: 0, rollName_Lumia: "Demo Roll", dateString_Lumia: today_Lumia)
        }
        if let existing_Lumia = user_Lumia.filmRolls_Lumia.first(where: { $0.dateString_Lumia == today_Lumia && !$0.isDeveloped_Lumia }) {
            return existing_Lumia
        }
        let newRoll_Lumia = FilmRoll_Lumia(
            rollId_Lumia: user_Lumia.filmRolls_Lumia.count + 1,
            rollName_Lumia: "Roll #\(user_Lumia.filmRolls_Lumia.count + 1)",
            dateString_Lumia: today_Lumia
        )
        user_Lumia.filmRolls_Lumia.append(newRoll_Lumia)
        return newRoll_Lumia
    }

    /// 在今日卷的下一个未曝光帧上曝光
    /// - Returns: 是否成功（卷未满时为 true）
    @discardableResult
    func exposeNextFrame_Lumia(imagePath: String?, note: String?) -> Bool {
        let today_Lumia = dateString_Lumia(from: Date())
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia,
              let rollIdx_Lumia = user_Lumia.filmRolls_Lumia.firstIndex(where: {
                  $0.dateString_Lumia == today_Lumia && !$0.isDeveloped_Lumia
              }) else { return false }

        let roll_Lumia = user_Lumia.filmRolls_Lumia[rollIdx_Lumia]
        guard !roll_Lumia.isFull_Lumia else { return false }

        if let frameIdx_Lumia = roll_Lumia.frames_Lumia.firstIndex(where: { !$0.isExposed_Lumia }) {
            roll_Lumia.frames_Lumia[frameIdx_Lumia].imagePath_Lumia = imagePath
            roll_Lumia.frames_Lumia[frameIdx_Lumia].note_Lumia = note
            let f_Lumia = DateFormatter(); f_Lumia.dateFormat = "HH:mm"
            roll_Lumia.frames_Lumia[frameIdx_Lumia].takenAt_Lumia = f_Lumia.string(from: Date())
        }
        // 满帧自动冲洗
        if roll_Lumia.isFull_Lumia { roll_Lumia.isDeveloped_Lumia = true }
        return true
    }

    /// 手动冲洗今日卷
    func developTodayRoll_Lumia() {
        let today_Lumia = dateString_Lumia(from: Date())
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia,
              let rollIdx_Lumia = user_Lumia.filmRolls_Lumia.firstIndex(where: {
                  $0.dateString_Lumia == today_Lumia && !$0.isDeveloped_Lumia
              }) else { return }
        user_Lumia.filmRolls_Lumia[rollIdx_Lumia].isDeveloped_Lumia = true
    }

    /// 新建一卷（今日没有进行中的卷时使用）
    func startNewRoll_Lumia() {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return }
        let today_Lumia = dateString_Lumia(from: Date())
        let hasActive_Lumia = user_Lumia.filmRolls_Lumia.contains { $0.dateString_Lumia == today_Lumia && !$0.isDeveloped_Lumia }
        guard !hasActive_Lumia else { return }
        let newRoll_Lumia = FilmRoll_Lumia(
            rollId_Lumia: user_Lumia.filmRolls_Lumia.count + 1,
            rollName_Lumia: "Roll #\(user_Lumia.filmRolls_Lumia.count + 1)",
            dateString_Lumia: today_Lumia
        )
        user_Lumia.filmRolls_Lumia.append(newRoll_Lumia)
    }

    // MARK: - 胶片柜

    /// 获取已冲洗的胶片卷（按时间倒序）
    func getDevelopedRolls_Lumia() -> [FilmRoll_Lumia] {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return [] }
        return user_Lumia.filmRolls_Lumia
            .filter { $0.isDeveloped_Lumia }
            .sorted { $0.dateString_Lumia > $1.dateString_Lumia }
    }

    // MARK: - 时光胶囊

    /// 创建新时光胶囊
    func createCapsule_Lumia(message: String, imagePath: String?, unlockDate: String) {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return }
        let capsule_Lumia = TimeCapsule_Lumia(
            capsuleId_Lumia: user_Lumia.capsules_Lumia.count + 1,
            imagePath_Lumia: imagePath,
            message_Lumia: message,
            unlockDateString_Lumia: unlockDate
        )
        user_Lumia.capsules_Lumia.append(capsule_Lumia)
    }

    /// 解锁并标记胶囊为已查看
    func revealCapsule_Lumia(capsuleId: Int) {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia,
              let idx_Lumia = user_Lumia.capsules_Lumia.firstIndex(where: { $0.capsuleId_Lumia == capsuleId }) else { return }
        user_Lumia.capsules_Lumia[idx_Lumia].isRevealed_Lumia = true
    }

    /// 获取当前用户的全部胶囊（按投入时间倒序）
    func getCapsules_Lumia() -> [TimeCapsule_Lumia] {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return [] }
        return user_Lumia.capsules_Lumia.reversed()
    }

    // MARK: - 删除操作

    /// 清除今日卷中指定帧的图片（还原为未曝光状态）
    func deleteFrame_Lumia(frameIndex: Int) {
        let today_Lumia = dateString_Lumia(from: Date())
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia,
              let rollIdx_Lumia = user_Lumia.filmRolls_Lumia.firstIndex(where: {
                  $0.dateString_Lumia == today_Lumia && !$0.isDeveloped_Lumia
              }),
              let frameIdx_Lumia = user_Lumia.filmRolls_Lumia[rollIdx_Lumia].frames_Lumia.firstIndex(where: {
                  $0.frameIndex_Lumia == frameIndex
              }) else { return }
        user_Lumia.filmRolls_Lumia[rollIdx_Lumia].frames_Lumia[frameIdx_Lumia].imagePath_Lumia = nil
        user_Lumia.filmRolls_Lumia[rollIdx_Lumia].frames_Lumia[frameIdx_Lumia].note_Lumia = nil
    }

    /// 从胶片柜中删除指定卷
    func deleteRoll_Lumia(rollId: Int) {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return }
        user_Lumia.filmRolls_Lumia.removeAll { $0.rollId_Lumia == rollId }
    }

    /// 删除指定时光胶囊
    func deleteCapsule_Lumia(capsuleId: Int) {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return }
        user_Lumia.capsules_Lumia.removeAll { $0.capsuleId_Lumia == capsuleId }
    }

    // MARK: - 主题征集

    /// 获取当前周的主题
    func getCurrentTheme_Lumia() -> FilmTheme_Lumia {
        // 静态主题列表，按周轮换
        let themes_Lumia: [FilmTheme_Lumia] = [
            FilmTheme_Lumia(themeId_Lumia: 1, themeTitle_Lumia: "Golden Hour", themeDesc_Lumia: "Capture the last light of day. Warm tones, long shadows, film grain.", weekLabel_Lumia: "Week 21 · 2026", accentColor_Lumia: "#F6A623"),
            FilmTheme_Lumia(themeId_Lumia: 2, themeTitle_Lumia: "Rainy Streets", themeDesc_Lumia: "Puddle reflections, blurred neon, the city in the rain.", weekLabel_Lumia: "Week 22 · 2026", accentColor_Lumia: "#4A86D4"),
            FilmTheme_Lumia(themeId_Lumia: 3, themeTitle_Lumia: "Analog Portraits", themeDesc_Lumia: "Faces in natural light. Candid. Honest. No filters.", weekLabel_Lumia: "Week 23 · 2026", accentColor_Lumia: "#C54E8A"),
            FilmTheme_Lumia(themeId_Lumia: 4, themeTitle_Lumia: "Urban Geometry", themeDesc_Lumia: "Lines, shadows, and patterns that build the city.", weekLabel_Lumia: "Week 24 · 2026", accentColor_Lumia: "#2A4A8A"),
        ]
        let weekOfYear_Lumia = Calendar.current.component(.weekOfYear, from: Date())
        return themes_Lumia[weekOfYear_Lumia % themes_Lumia.count]
    }

    /// 提交主题征集照片
    func submitToTheme_Lumia(themeId: Int, imagePath: String?, descText: String) {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return }
        let submission_Lumia = ThemeSubmission_Lumia(
            submissionId_Lumia: user_Lumia.themeSubmissions_Lumia.count + 1,
            themeId_Lumia: themeId,
            imagePath_Lumia: imagePath,
            descText_Lumia: descText
        )
        user_Lumia.themeSubmissions_Lumia.append(submission_Lumia)
    }

    /// 获取指定主题的当前用户提交列表
    func getThemeSubmissions_Lumia(themeId: Int) -> [ThemeSubmission_Lumia] {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return [] }
        return user_Lumia.themeSubmissions_Lumia.filter { $0.themeId_Lumia == themeId }.reversed()
    }

    // MARK: - 工具

    /// 保存 UIImage 到文档目录，返回文件路径
    func saveImageToDocuments_Lumia(image: UIImage) -> String {
        guard let data_Lumia = image.jpegData(compressionQuality: 0.8) else { return "" }
        let name_Lumia = "film_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_Lumia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name_Lumia)
        try? data_Lumia.write(to: url_Lumia)
        return url_Lumia.path
    }

    private func dateString_Lumia(from date: Date) -> String {
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd"
        return f_Lumia.string(from: date)
    }

    /// 获取当前用户（以 LoginUserModel_Lumia 形式）
    func currentLoginUser_Lumia() -> LoginUserModel_Lumia? {
        return UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia
    }
}

// MARK: - Section 1: 今日胶片墙

/// 今日胶片墙视图
/// 核心作用：以真实胶片条形式展示今日胶片卷，每帧可点击曝光，显示已拍/总帧数
/// 设计：深色胶片条（#1A1A2E）+ 左右穿孔 + 24 帧横向滚动
private class TodayFilmWallView_Lumia: UIView {

    var onShootTapped_Lumia: (() -> Void)?
    var onDevelopTapped_Lumia: (() -> Void)?
    /// 删除指定帧回调（参数为 frameIndex）
    var onDeleteFrame_Lumia: ((Int) -> Void)?

    private var currentRoll_Lumia: FilmRoll_Lumia?

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "✦  Today's Film Wall"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#4A3020")
        return lbl_Lumia
    }()

    private let counterLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C08060")
        return lbl_Lumia
    }()

    private let filmStripScroll_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsHorizontalScrollIndicator = false
        sv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#1A1A2E")
        sv_Lumia.layer.cornerRadius = 8
        return sv_Lumia
    }()

    private let framesStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .horizontal
        sv_Lumia.spacing = 4
        sv_Lumia.alignment = .center
        return sv_Lumia
    }()

    private let shootButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn_Lumia.setImage(UIImage(systemName: "camera.fill", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.setTitle("  Shoot", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_Lumia.tintColor = .white
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623")
        btn_Lumia.layer.cornerRadius = 20
        return btn_Lumia
    }()

    private let developButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Develop", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#8A5030"), for: .normal)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F0D8B0")
        btn_Lumia.layer.cornerRadius = 18
        return btn_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#FFF9F0")
        layer.cornerRadius = 18
        layer.shadowColor = UIColor(hexstring_Lumia: "#F6A623").cgColor
        layer.shadowOpacity = 0.14
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        // 左侧橙色融合竖条（融入卡片）
        let leftBar_Lumia = UIView()
        leftBar_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623")
        leftBar_Lumia.layer.cornerRadius = 18
        leftBar_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        addSubview(leftBar_Lumia)
        leftBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }

        // 标题图标背景圆
        let iconBg_Lumia = UIView()
        iconBg_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623", alpha_Lumia: 0.15)
        iconBg_Lumia.layer.cornerRadius = 14
        addSubview(iconBg_Lumia)
        iconBg_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(28)
        }
        let iconLabel_Lumia = UILabel()
        iconLabel_Lumia.text = "✦"
        iconLabel_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        iconLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#F6A623")
        iconLabel_Lumia.textAlignment = .center
        iconBg_Lumia.addSubview(iconLabel_Lumia)
        iconLabel_Lumia.snp.makeConstraints { make in make.center.equalToSuperview() }

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(iconBg_Lumia)
            make.leading.equalTo(iconBg_Lumia.snp.trailing).offset(8)
        }

        // 计数徽章
        let counterBadge_Lumia = UIView()
        counterBadge_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623", alpha_Lumia: 0.12)
        counterBadge_Lumia.layer.cornerRadius = 11
        addSubview(counterBadge_Lumia)
        counterBadge_Lumia.addSubview(counterLabel_Lumia)
        counterBadge_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(iconBg_Lumia)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(22)
        }
        counterLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }

        addSubview(filmStripScroll_Lumia)
        filmStripScroll_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Lumia.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(100)
        }

        filmStripScroll_Lumia.addSubview(framesStack_Lumia)
        framesStack_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            make.height.equalToSuperview().offset(-16)
        }

        let btnRow_Lumia = UIView()
        addSubview(btnRow_Lumia)
        btnRow_Lumia.snp.makeConstraints { make in
            make.top.equalTo(filmStripScroll_Lumia.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-16)
        }

        btnRow_Lumia.addSubview(developButton_Lumia)
        developButton_Lumia.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(90)
        }
        developButton_Lumia.addTarget(self, action: #selector(handleDevelop_Lumia), for: .touchUpInside)

        btnRow_Lumia.addSubview(shootButton_Lumia)
        shootButton_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(developButton_Lumia.snp.leading).offset(-10)
        }
        shootButton_Lumia.addTarget(self, action: #selector(handleShoot_Lumia), for: .touchUpInside)
    }

    func configure_Lumia(roll: FilmRoll_Lumia) {
        currentRoll_Lumia = roll
        counterLabel_Lumia.text = "\(roll.exposedCount_Lumia)/\(roll.maxFrames_Lumia)"

        framesStack_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for frame_Lumia in roll.frames_Lumia {
            let frameView_Lumia = FilmFrameMiniView_Lumia(frame: frame_Lumia)
            frameView_Lumia.snp.makeConstraints { make in make.width.equalTo(60) }
            // 只对已曝光帧传入删除回调
            if frame_Lumia.isExposed_Lumia {
                frameView_Lumia.onDeleteTapped_Lumia = { [weak self] in
                    self?.onDeleteFrame_Lumia?(frame_Lumia.frameIndex_Lumia)
                }
            }
            framesStack_Lumia.addArrangedSubview(frameView_Lumia)
        }

        let isActive_Lumia = !roll.isDeveloped_Lumia
        shootButton_Lumia.isEnabled = isActive_Lumia && !roll.isFull_Lumia
        shootButton_Lumia.alpha = (isActive_Lumia && !roll.isFull_Lumia) ? 1.0 : 0.5
        developButton_Lumia.isEnabled = isActive_Lumia && roll.exposedCount_Lumia > 0
    }

    @objc private func handleShoot_Lumia() { onShootTapped_Lumia?() }
    @objc private func handleDevelop_Lumia() { onDevelopTapped_Lumia?() }
}

/// 胶片单帧迷你视图（胶片墙中的一格）
private class FilmFrameMiniView_Lumia: UIView {

    /// 删除帧回调（仅曝光帧有效）
    var onDeleteTapped_Lumia: (() -> Void)?

    private let imageView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.contentMode = .scaleAspectFill
        iv_Lumia.clipsToBounds = true
        return iv_Lumia
    }()

    private let indexLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 8, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.45)
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    init(frame filmFrame: FilmFrame_Lumia) {
        super.init(frame: .zero)
        backgroundColor = filmFrame.isExposed_Lumia
            ? UIColor(hexstring_Lumia: "#2A2A3A")
            : UIColor(hexstring_Lumia: "#0A0A18")
        layer.cornerRadius = 3
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor

        addSubview(imageView_Lumia)
        imageView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }

        addSubview(indexLabel_Lumia)
        indexLabel_Lumia.snp.makeConstraints { make in make.center.equalToSuperview() }
        indexLabel_Lumia.text = "\(filmFrame.frameIndex_Lumia)"

        if filmFrame.isExposed_Lumia, let path_Lumia = filmFrame.imagePath_Lumia {
            if let img_Lumia = UIImage(contentsOfFile: path_Lumia) ?? UIImage(named: path_Lumia) {
                imageView_Lumia.image = img_Lumia
                imageView_Lumia.layer.cornerRadius = 3
                indexLabel_Lumia.isHidden = true
                let overlay_Lumia = UIView()
                overlay_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623").withAlphaComponent(0.15)
                overlay_Lumia.layer.cornerRadius = 3
                addSubview(overlay_Lumia)
                overlay_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }

                // 删除按钮（右上角，半透明黑底 ×）
                let delBtn_Lumia = UIButton(type: .custom)
                let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 7, weight: .bold)
                delBtn_Lumia.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
                delBtn_Lumia.tintColor = .white
                delBtn_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.55)
                delBtn_Lumia.layer.cornerRadius = 7
                addSubview(delBtn_Lumia)
                delBtn_Lumia.snp.makeConstraints { make in
                    make.top.trailing.equalToSuperview().inset(2)
                    make.width.height.equalTo(14)
                }
                delBtn_Lumia.addTarget(self, action: #selector(handleDelete_Lumia), for: .touchUpInside)
            }
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func handleDelete_Lumia() { onDeleteTapped_Lumia?() }
}

// MARK: - Section 2: 我的胶片柜

/// 我的胶片柜视图
/// 核心作用：网格展示所有已冲洗的胶片卷（每卷一个胶片盒图标），点击进入查看
/// 设计：木质暖棕色背景渐变，每盒显示卷名、日期、帧数
private class FilmCabinetView_Lumia: UIView {

    var onRollTapped_Lumia: ((FilmRoll_Lumia) -> Void)?
    var onNewRollTapped_Lumia: (() -> Void)?
    /// 删除胶片卷回调
    var onDeleteRoll_Lumia: ((FilmRoll_Lumia) -> Void)?

    private var rolls_Lumia: [FilmRoll_Lumia] = []

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "⬛  My Film Cabinet"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#3A2010")
        return lbl_Lumia
    }()

    /// 空状态容器（类属性，便于在 configure 中控制显隐）
    private let emptyContainer_Lumia: UIView = {
        let v_Lumia = UIView()
        // 禁止拦截触摸，防止覆盖在胶片盒格子上时阻断点击
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }()

    private let emptyLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "No developed rolls yet.\nStart shooting and develop your first roll!"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C09870")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let gridStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 10
        sv_Lumia.alignment = .fill
        return sv_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#7A5535")
        layer.cornerRadius = 18
        layer.shadowColor = UIColor(hexstring_Lumia: "#5A3A1A").cgColor
        layer.shadowOpacity = 0.22
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        // 左侧深棕竖条（融入卡片）
        let leftBar_Lumia = UIView()
        leftBar_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#5A3520")
        leftBar_Lumia.layer.cornerRadius = 18
        leftBar_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        addSubview(leftBar_Lumia)
        leftBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }

        // 标题图标
        let iconBg_Lumia = UIView()
        iconBg_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        iconBg_Lumia.layer.cornerRadius = 14
        addSubview(iconBg_Lumia)
        iconBg_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(28)
        }
        let iconLabel_Lumia = UILabel()
        iconLabel_Lumia.text = "🎞"
        iconLabel_Lumia.font = UIFont.systemFont(ofSize: 14)
        iconLabel_Lumia.textAlignment = .center
        iconBg_Lumia.addSubview(iconLabel_Lumia)
        iconLabel_Lumia.snp.makeConstraints { make in make.center.equalToSuperview() }

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(iconBg_Lumia)
            make.leading.equalTo(iconBg_Lumia.snp.trailing).offset(8)
        }

        addSubview(gridStack_Lumia)
        gridStack_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Lumia.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 空状态：图标 + 文字（使用类属性，configure 中控制显隐）
        addSubview(emptyContainer_Lumia)
        emptyContainer_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-20)
        }
        let emptyIcon_Lumia = UIImageView(image: UIImage(systemName: "film.stack"))
        emptyIcon_Lumia.tintColor = UIColor.white.withAlphaComponent(0.45)
        emptyIcon_Lumia.contentMode = .scaleAspectFit
        emptyContainer_Lumia.addSubview(emptyIcon_Lumia)
        emptyIcon_Lumia.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        emptyLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.70)
        emptyContainer_Lumia.addSubview(emptyLabel_Lumia)
        emptyLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configure_Lumia(rolls: [FilmRoll_Lumia]) {
        self.rolls_Lumia = rolls
        gridStack_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 同时控制整个空状态容器（局部变量改为类属性后才能在此访问）
        emptyContainer_Lumia.isHidden = !rolls.isEmpty
        emptyLabel_Lumia.isHidden = !rolls.isEmpty
        gridStack_Lumia.isHidden = rolls.isEmpty

        guard !rolls.isEmpty else { return }

        // 每行3个，分组
        let columns_Lumia = 3
        let rows_Lumia = Int(ceil(Double(rolls.count) / Double(columns_Lumia)))
        for rowIdx_Lumia in 0..<rows_Lumia {
            let rowStack_Lumia = UIStackView()
            rowStack_Lumia.axis = .horizontal
            rowStack_Lumia.spacing = 10
            rowStack_Lumia.distribution = .fillEqually
            for colIdx_Lumia in 0..<columns_Lumia {
                let idx_Lumia = rowIdx_Lumia * columns_Lumia + colIdx_Lumia
                if idx_Lumia < rolls.count {
                    let canister_Lumia = FilmCanisters_Lumia(roll: rolls[idx_Lumia])
                    canister_Lumia.onTapped_Lumia = { [weak self] in
                        self?.onRollTapped_Lumia?(rolls[idx_Lumia])
                    }
                    canister_Lumia.onDeleteTapped_Lumia = { [weak self] in
                        self?.onDeleteRoll_Lumia?(rolls[idx_Lumia])
                    }
                    rowStack_Lumia.addArrangedSubview(canister_Lumia)
                    canister_Lumia.snp.makeConstraints { make in make.height.equalTo(90) }
                } else {
                    // 占位
                    rowStack_Lumia.addArrangedSubview(UIView())
                }
            }
            gridStack_Lumia.addArrangedSubview(rowStack_Lumia)
        }
    }
}

/// 胶片盒图标视图（柜中的一卷）
private class FilmCanisters_Lumia: UIView {

    var onTapped_Lumia: (() -> Void)?
    /// 删除卷回调
    var onDeleteTapped_Lumia: (() -> Void)?

    private let roll_Lumia: FilmRoll_Lumia

    init(roll: FilmRoll_Lumia) {
        self.roll_Lumia = roll
        super.init(frame: .zero)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#C49A6C")
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexstring_Lumia: "#8B5E3C").cgColor

        let icon_Lumia = UIImageView(image: UIImage(systemName: "camera.filters"))
        icon_Lumia.tintColor = UIColor(hexstring_Lumia: "#3A2010")
        icon_Lumia.contentMode = .scaleAspectFit
        addSubview(icon_Lumia)
        icon_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(28)
        }

        let nameLabel_Lumia = UILabel()
        nameLabel_Lumia.text = roll_Lumia.rollName_Lumia
        nameLabel_Lumia.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        nameLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1008")
        nameLabel_Lumia.textAlignment = .center
        nameLabel_Lumia.numberOfLines = 1
        addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(icon_Lumia.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }

        let countLabel_Lumia = UILabel()
        countLabel_Lumia.text = "\(roll_Lumia.exposedCount_Lumia) frames"
        countLabel_Lumia.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        countLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#6A4020")
        countLabel_Lumia.textAlignment = .center
        addSubview(countLabel_Lumia)
        countLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(4)
        }

        // 删除按钮（右上角，深棕半透明背景）
        let delBtn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
        delBtn_Lumia.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
        delBtn_Lumia.tintColor = UIColor(hexstring_Lumia: "#3A1808")
        delBtn_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.20)
        delBtn_Lumia.layer.cornerRadius = 8
        addSubview(delBtn_Lumia)
        delBtn_Lumia.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(5)
            make.width.height.equalTo(16)
        }
        delBtn_Lumia.addTarget(self, action: #selector(handleDelete_Lumia), for: .touchUpInside)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia)))
        isUserInteractionEnabled = true
    }

    @objc private func handleTap_Lumia() { animatePressDown_Lumia { self.onTapped_Lumia?() } }
    @objc private func handleDelete_Lumia() { onDeleteTapped_Lumia?() }
}

// MARK: - Section 3: 时光胶囊

/// 时光胶囊视图
/// 核心作用：展示用户已创建的胶囊列表，可创建新胶囊，到期胶囊可解锁查看
private class TimeCapsuleView_Lumia: UIView {

    var onCreateTapped_Lumia: (() -> Void)?
    var onCapsuleTapped_Lumia: ((TimeCapsule_Lumia) -> Void)?
    /// 删除胶囊回调
    var onDeleteCapsule_Lumia: ((TimeCapsule_Lumia) -> Void)?

    private var capsules_Lumia: [TimeCapsule_Lumia] = []

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "⏳  Film Time Capsule"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.90)
        return lbl_Lumia
    }()

    private let createButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("+ New", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#F6D860"), for: .normal)
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        btn_Lumia.layer.cornerRadius = 14
        btn_Lumia.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        return btn_Lumia
    }()

    private let capsulesStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 8
        sv_Lumia.alignment = .fill
        return sv_Lumia
    }()

    private let emptyLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "No capsules yet.\nSeal a memory to reveal later."
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.55)
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#1A2A3A")
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.22
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        // 左侧青蓝色融合竖条
        let leftBar_Lumia = UIView()
        leftBar_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#2A8AAA")
        leftBar_Lumia.layer.cornerRadius = 18
        leftBar_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        addSubview(leftBar_Lumia)
        leftBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        addSubview(createButton_Lumia)
        createButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Lumia)
            make.trailing.equalToSuperview().offset(-14)
        }
        createButton_Lumia.addTarget(self, action: #selector(handleCreate_Lumia), for: .touchUpInside)

        addSubview(capsulesStack_Lumia)
        capsulesStack_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-14)
        }

        addSubview(emptyLabel_Lumia)
        emptyLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-22)
        }
    }

    func configure_Lumia(capsules: [TimeCapsule_Lumia]) {
        self.capsules_Lumia = capsules
        capsulesStack_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }

        emptyLabel_Lumia.isHidden = !capsules.isEmpty
        capsulesStack_Lumia.isHidden = capsules.isEmpty

        for capsule_Lumia in capsules.prefix(6) {
            let row_Lumia = buildCapsuleRow_Lumia(capsule: capsule_Lumia)
            capsulesStack_Lumia.addArrangedSubview(row_Lumia)
        }
    }

    private func buildCapsuleRow_Lumia(capsule: TimeCapsule_Lumia) -> UIView {
        let container_Lumia = UIView()
        container_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container_Lumia.layer.cornerRadius = 12

        // 左侧状态竖条（金色=可解锁，蓝灰=锁定）
        let statusBar_Lumia = UIView()
        statusBar_Lumia.backgroundColor = capsule.canReveal_Lumia
            ? UIColor(hexstring_Lumia: "#F6D860")
            : UIColor.white.withAlphaComponent(0.25)
        statusBar_Lumia.layer.cornerRadius = 2
        statusBar_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        container_Lumia.addSubview(statusBar_Lumia)
        statusBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        let icon_Lumia = UIImageView(image: UIImage(systemName: capsule.canReveal_Lumia ? "lock.open.fill" : "lock.fill"))
        icon_Lumia.tintColor = capsule.canReveal_Lumia
            ? UIColor(hexstring_Lumia: "#F6D860")
            : UIColor.white.withAlphaComponent(0.55)
        icon_Lumia.contentMode = .scaleAspectFit
        container_Lumia.addSubview(icon_Lumia)
        icon_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(statusBar_Lumia.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 删除按钮
        let delBtn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        delBtn_Lumia.setImage(UIImage(systemName: "trash", withConfiguration: cfg_Lumia), for: .normal)
        delBtn_Lumia.tintColor = UIColor.white.withAlphaComponent(0.45)
        container_Lumia.addSubview(delBtn_Lumia)
        delBtn_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        delBtn_Lumia.tag = capsule.capsuleId_Lumia
        delBtn_Lumia.addTarget(self, action: #selector(handleCapsuleDelete_Lumia(_:)), for: .touchUpInside)

        // 文字信息区（两行：解锁时间 + 内容预览）
        let infoStack_Lumia = UIStackView()
        infoStack_Lumia.axis = .vertical
        infoStack_Lumia.spacing = 2
        container_Lumia.addSubview(infoStack_Lumia)
        infoStack_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(icon_Lumia.snp.trailing).offset(10)
            make.trailing.equalTo(delBtn_Lumia.snp.leading).offset(-6)
            make.top.bottom.equalToSuperview().inset(10)
        }

        let dateLabel_Lumia = UILabel()
        dateLabel_Lumia.text = capsule.isRevealed_Lumia
            ? "Revealed · \(capsule.createdAt_Lumia)"
            : "Unlocks \(capsule.unlockDateString_Lumia)"
        dateLabel_Lumia.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        dateLabel_Lumia.textColor = capsule.canReveal_Lumia
            ? UIColor(hexstring_Lumia: "#F6D860")
            : UIColor.white.withAlphaComponent(0.50)
        infoStack_Lumia.addArrangedSubview(dateLabel_Lumia)

        let msgLabel_Lumia = UILabel()
        msgLabel_Lumia.text = capsule.isRevealed_Lumia
            ? capsule.message_Lumia
            : "Tap to reveal when unlocked"
        msgLabel_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        msgLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.82)
        msgLabel_Lumia.numberOfLines = 1
        infoStack_Lumia.addArrangedSubview(msgLabel_Lumia)

        let tap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleCapsuleTap_Lumia(_:)))
        container_Lumia.addGestureRecognizer(tap_Lumia)
        container_Lumia.isUserInteractionEnabled = true
        container_Lumia.tag = capsule.capsuleId_Lumia

        return container_Lumia
    }

    @objc private func handleCreate_Lumia() { onCreateTapped_Lumia?() }

    @objc private func handleCapsuleTap_Lumia(_ gesture: UITapGestureRecognizer) {
        guard let capsuleId_Lumia = gesture.view?.tag,
              let capsule_Lumia = capsules_Lumia.first(where: { $0.capsuleId_Lumia == capsuleId_Lumia }) else { return }
        onCapsuleTapped_Lumia?(capsule_Lumia)
    }

    @objc private func handleCapsuleDelete_Lumia(_ sender: UIButton) {
        guard let capsule_Lumia = capsules_Lumia.first(where: { $0.capsuleId_Lumia == sender.tag }) else { return }
        onDeleteCapsule_Lumia?(capsule_Lumia)
    }
}

// MARK: - Section 4: 主题胶片展

/// 主题胶片展视图
/// 核心作用：展示本周主题、用户提交的照片列表及提交入口
// MARK: - Section 4: 主题讨论区（首页卡片）

/// 主题讨论区首页卡片
/// 核心作用：展示本周主题标题、评论预览，点击进入讨论详情页
private class ThemeDiscussionView_Lumia: UIView {

    var onEnterDiscussion_Lumia: ((FilmTheme_Lumia) -> Void)?

    private var currentTheme_Lumia: FilmTheme_Lumia?
    private var bannerGradient_Lumia: CAGradientLayer?

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "💬  Theme Discussion"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#1A1030")
        return lbl_Lumia
    }()

    private let weekLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#9080C0")
        return lbl_Lumia
    }()

    private let themeBanner_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 14
        v_Lumia.isUserInteractionEnabled = true
        return v_Lumia
    }()

    private let themeNameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let themeDescLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.82)
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let enterButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Join →", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_Lumia.layer.cornerRadius = 16
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.40).cgColor
        return btn_Lumia
    }()

    private let commentCountLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#6040A0")
        return lbl_Lumia
    }()

    private let previewStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 6
        return sv_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        bannerGradient_Lumia?.frame = themeBanner_Lumia.bounds
    }

    private func setupUI_Lumia() {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(18)
        }

        addSubview(weekLabel_Lumia)
        weekLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Lumia)
            make.trailing.equalToSuperview().offset(-18)
        }

        addSubview(themeBanner_Lumia)
        themeBanner_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(14)
            make.height.equalTo(96)
        }
        themeBanner_Lumia.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEnter_Lumia)))

        // 先添加按钮，再约束标题和描述到按钮左侧，彻底避免文字被遮挡
        themeBanner_Lumia.addSubview(enterButton_Lumia)
        enterButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(32)
        }
        enterButton_Lumia.addTarget(self, action: #selector(handleEnter_Lumia), for: .touchUpInside)

        themeBanner_Lumia.addSubview(themeNameLabel_Lumia)
        themeNameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(enterButton_Lumia.snp.leading).offset(-10)
        }

        themeBanner_Lumia.addSubview(themeDescLabel_Lumia)
        themeDescLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(themeNameLabel_Lumia.snp.bottom).offset(5)
            make.leading.equalTo(themeNameLabel_Lumia)
            make.trailing.equalTo(enterButton_Lumia.snp.leading).offset(-10)
        }

        addSubview(commentCountLabel_Lumia)
        commentCountLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(themeBanner_Lumia.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(18)
        }

        addSubview(previewStack_Lumia)
        previewStack_Lumia.snp.makeConstraints { make in
            make.top.equalTo(commentCountLabel_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    func configure_Lumia(theme: FilmTheme_Lumia, comments: [ThemeDiscussionComment_Lumia]) {
        currentTheme_Lumia = theme
        weekLabel_Lumia.text = theme.weekLabel_Lumia
        themeNameLabel_Lumia.text = theme.themeTitle_Lumia
        themeDescLabel_Lumia.text = theme.themeDesc_Lumia

        // 横幅渐变
        bannerGradient_Lumia?.removeFromSuperlayer()
        let base_Lumia = UIColor(hexstring_Lumia: theme.accentColor_Lumia)
        let grad_Lumia = CAGradientLayer()
        grad_Lumia.colors = [base_Lumia.cgColor, base_Lumia.withAlphaComponent(0.60).cgColor]
        grad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        grad_Lumia.cornerRadius = 14
        themeBanner_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
        bannerGradient_Lumia = grad_Lumia

        // 评论预览（最新 2 条）
        previewStack_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }
        commentCountLabel_Lumia.text = comments.isEmpty
            ? "Be the first to comment!"
            : "💬  \(comments.count) comment\(comments.count == 1 ? "" : "s")"

        for comment_Lumia in comments.suffix(2) {
            let row_Lumia = buildPreviewRow_Lumia(comment: comment_Lumia)
            previewStack_Lumia.addArrangedSubview(row_Lumia)
        }
    }

    private func buildPreviewRow_Lumia(comment: ThemeDiscussionComment_Lumia) -> UIView {
        let container_Lumia = UIView()
        container_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")
        container_Lumia.layer.cornerRadius = 8

        let nameLabel_Lumia = UILabel()
        nameLabel_Lumia.text = comment.userName_Lumia
        nameLabel_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        nameLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#6040A0")
        container_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 0))
        }

        let textLabel_Lumia = UILabel()
        textLabel_Lumia.text = comment.content_Lumia
        textLabel_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        textLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#3A2060")
        textLabel_Lumia.numberOfLines = 1
        container_Lumia.addSubview(textLabel_Lumia)
        textLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        }

        return container_Lumia
    }

    @objc private func handleEnter_Lumia() {
        guard let theme_Lumia = currentTheme_Lumia else { return }
        onEnterDiscussion_Lumia?(theme_Lumia)
    }
}

// MARK: - 主题讨论详情页

/// 主题讨论详情页 VC
/// 核心作用：全屏展示主题、评论列表（含举报/删除）、底部输入栏
class ThemeDiscussionDetail_Lumia: UIViewController {

    var onCommentAdded_Lumia: (() -> Void)?

    private let theme_Lumia: FilmTheme_Lumia
    private var comments_Lumia: [ThemeDiscussionComment_Lumia] = []
    private var inputBarBottom_Lumia: Constraint?

    private var headerGradient_Lumia: CAGradientLayer?

    private lazy var tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .plain)
        tv_Lumia.separatorStyle = .none
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")
        tv_Lumia.showsVerticalScrollIndicator = false
        tv_Lumia.keyboardDismissMode = .onDrag
        tv_Lumia.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return tv_Lumia
    }()

    private let inputBar_Lumia = UIView()

    private let inputField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.placeholder = "Share your thoughts..."
        tf_Lumia.font = UIFont.systemFont(ofSize: 14)
        tf_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")
        tf_Lumia.layer.cornerRadius = 20
        tf_Lumia.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf_Lumia.leftViewMode = .always
        tf_Lumia.returnKeyType = .send
        return tf_Lumia
    }()

    private let sendButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Lumia.setImage(UIImage(systemName: "arrow.up", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#8A5CC8")
        btn_Lumia.layer.cornerRadius = 20
        return btn_Lumia
    }()

    init(theme: FilmTheme_Lumia) {
        self.theme_Lumia = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")
        setupUI_Lumia()
        setupKeyboard_Lumia()
        reloadComments_Lumia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Lumia?.frame = view.bounds.intersection(
            CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        )
    }

    // MARK: - UI

    private func setupUI_Lumia() {
        // 顶部渐变头
        let header_Lumia = UIView()
        view.addSubview(header_Lumia)
        header_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
        let base_Lumia = UIColor(hexstring_Lumia: theme_Lumia.accentColor_Lumia)
        let grad_Lumia = CAGradientLayer()
        grad_Lumia.colors = [base_Lumia.cgColor, base_Lumia.withAlphaComponent(0.55).cgColor]
        grad_Lumia.startPoint = CGPoint(x: 0, y: 0)
        grad_Lumia.endPoint = CGPoint(x: 1, y: 1)
        header_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
        header_Lumia.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        header_Lumia.layer.cornerRadius = 24
        headerGradient_Lumia = grad_Lumia

        // 关闭按钮
        let closeBtn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        closeBtn_Lumia.setImage(UIImage(systemName: "chevron.down", withConfiguration: cfg_Lumia), for: .normal)
        closeBtn_Lumia.tintColor = .white
        closeBtn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        closeBtn_Lumia.layer.cornerRadius = 18
        header_Lumia.addSubview(closeBtn_Lumia)
        closeBtn_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }
        closeBtn_Lumia.addTarget(self, action: #selector(handleClose_Lumia), for: .touchUpInside)

        // 主题标题
        let nameLabel_Lumia = UILabel()
        nameLabel_Lumia.text = theme_Lumia.themeTitle_Lumia
        nameLabel_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        nameLabel_Lumia.textColor = .white
        header_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-28)
        }

        let descLabel_Lumia = UILabel()
        descLabel_Lumia.text = theme_Lumia.themeDesc_Lumia
        descLabel_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.82)
        descLabel_Lumia.numberOfLines = 1
        header_Lumia.addSubview(descLabel_Lumia)
        descLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_Lumia)
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(3)
        }

        // 输入栏
        view.addSubview(inputBar_Lumia)
        inputBar_Lumia.backgroundColor = .white
        inputBar_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        inputBar_Lumia.layer.shadowOpacity = 0.10
        inputBar_Lumia.layer.shadowRadius = 8
        inputBar_Lumia.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputBar_Lumia.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
            inputBarBottom_Lumia = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        inputBar_Lumia.addSubview(sendButton_Lumia)
        sendButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        sendButton_Lumia.addTarget(self, action: #selector(handleSend_Lumia), for: .touchUpInside)

        inputBar_Lumia.addSubview(inputField_Lumia)
        inputField_Lumia.delegate = self
        inputField_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(sendButton_Lumia.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }

        // 评论列表
        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(header_Lumia.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Lumia.snp.top)
        }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(DiscussionCommentCell_Lumia.self,
                                  forCellReuseIdentifier: DiscussionCommentCell_Lumia.reuseId_Lumia)
    }

    private func reloadComments_Lumia() {
        comments_Lumia = FilmViewModel_Lumia.shared_Lumia.getDiscussionComments_Lumia(themeId: theme_Lumia.themeId_Lumia)
        tableView_Lumia.reloadData()
        if !comments_Lumia.isEmpty {
            tableView_Lumia.scrollToRow(at: IndexPath(row: comments_Lumia.count - 1, section: 0),
                                         at: .bottom, animated: false)
        }
    }

    // MARK: - 键盘

    private func setupKeyboard_Lumia() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow_Lumia(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide_Lumia(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func handleKeyboardShow_Lumia(_ n: Notification) {
        guard let kbFrame_Lumia = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let dur_Lumia = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottom_Lumia?.update(offset: -(kbFrame_Lumia.height - view.safeAreaInsets.bottom))
        UIView.animate(withDuration: dur_Lumia) { self.view.layoutIfNeeded() }
    }

    @objc private func handleKeyboardHide_Lumia(_ n: Notification) {
        guard let dur_Lumia = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottom_Lumia?.update(offset: 0)
        UIView.animate(withDuration: dur_Lumia) { self.view.layoutIfNeeded() }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 事件

    @objc private func handleClose_Lumia() { dismiss(animated: true) }

    @objc private func handleSend_Lumia() {
        let text_Lumia = inputField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Lumia.isEmpty else { return }
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else {
            dismiss(animated: true) { Navigation_Lumia.toLogin_Lumia(style_lumia: .present_lumia) }
            return
        }
        inputField_Lumia.text = ""
        view.endEditing(true)
        FilmViewModel_Lumia.shared_Lumia.addDiscussionComment_Lumia(themeId: theme_Lumia.themeId_Lumia, content: text_Lumia)
        reloadComments_Lumia()
        onCommentAdded_Lumia?()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

extension ThemeDiscussionDetail_Lumia: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments_Lumia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = tableView.dequeueReusableCell(
            withIdentifier: DiscussionCommentCell_Lumia.reuseId_Lumia, for: indexPath
        ) as! DiscussionCommentCell_Lumia
        let comment_Lumia = comments_Lumia[indexPath.row]
        let isOwn_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(userId_lumia: comment_Lumia.userId_Lumia)
        cell_Lumia.configure_Lumia(comment: comment_Lumia, isOwn: isOwn_Lumia)
        cell_Lumia.onActionTapped_Lumia = { [weak self] in
            self?.handleCommentAction_Lumia(comment: comment_Lumia, isOwn: isOwn_Lumia, indexPath: indexPath)
        }
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    /// 处理评论举报/删除操作
    private func handleCommentAction_Lumia(comment: ThemeDiscussionComment_Lumia,
                                            isOwn: Bool, indexPath: IndexPath) {
        if isOwn {
            // 自己的评论 → 使用系统 ActionSheet 确认删除
            let sheet_Lumia = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            sheet_Lumia.addAction(UIAlertAction(title: "Delete Comment", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                FilmViewModel_Lumia.shared_Lumia.deleteDiscussionComment_Lumia(
                    themeId: self.theme_Lumia.themeId_Lumia,
                    commentId: comment.commentId_Lumia
                )
                self.reloadComments_Lumia()
                self.onCommentAdded_Lumia?()
            })
            sheet_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(sheet_Lumia, animated: true)
        } else {
            // 他人的评论 → 用 ReportDeleteHelper 拉黑评论者（传入由评论信息构造的用户对象）
            let reportUser_Lumia = PrewUserModel_Lumia()
            reportUser_Lumia.userId_Lumia = comment.userId_Lumia
            reportUser_Lumia.userName_Lumia = comment.userName_Lumia
            reportUser_Lumia.userHead_Lumia = comment.userHead_Lumia
            ReportDeleteHelper_Lumia.block_Lumia(user_Lumia: reportUser_Lumia, from: self) { [weak self] in
                guard let self = self else { return }
                // 拉黑后同步删除该用户在讨论区的评论
                FilmViewModel_Lumia.shared_Lumia.deleteDiscussionComment_Lumia(
                    themeId: self.theme_Lumia.themeId_Lumia,
                    commentId: comment.commentId_Lumia
                )
                self.reloadComments_Lumia()
                self.onCommentAdded_Lumia?()
            }
        }
    }
}

extension ThemeDiscussionDetail_Lumia: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Lumia()
        return true
    }
}

// MARK: - 讨论评论 Cell

/// 主题讨论评论 Cell（头像 + 用户名 + 内容 + 时间 + 举报/删除按钮）
private class DiscussionCommentCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "DiscussionCommentCell_Lumia"
    var onActionTapped_Lumia: (() -> Void)?

    private let avatarView_Lumia = UserAvatarView_Lumia()

    private let nameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1040")
        return lbl_Lumia
    }()

    private let timeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#C0B0D8")
        return lbl_Lumia
    }()

    private let contentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#3A2060")
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()

    private let actionButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#C0A8D8")
        return btn_Lumia
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        avatarView_Lumia.layer.cornerRadius = 18
        avatarView_Lumia.clipsToBounds = true
        contentView.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(36)
        }

        contentView.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Lumia)
            make.leading.equalTo(avatarView_Lumia.snp.trailing).offset(10)
        }

        contentView.addSubview(timeLabel_Lumia)
        timeLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel_Lumia)
            make.leading.equalTo(nameLabel_Lumia.snp.trailing).offset(6)
        }

        contentView.addSubview(actionButton_Lumia)
        actionButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(nameLabel_Lumia)
            make.width.height.equalTo(28)
        }
        actionButton_Lumia.addTarget(self, action: #selector(handleAction_Lumia), for: .touchUpInside)

        contentView.addSubview(contentLabel_Lumia)
        contentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Lumia)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure_Lumia(comment: ThemeDiscussionComment_Lumia, isOwn: Bool) {
        avatarView_Lumia.configure_Lumia(userId_Lumia: comment.userId_Lumia)
        nameLabel_Lumia.text = comment.userName_Lumia
        timeLabel_Lumia.text = comment.createdAt_Lumia
        contentLabel_Lumia.text = comment.content_Lumia

        // 自己的评论：红色删除图标；他人的：灰色举报图标
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let icon_Lumia = isOwn ? "trash" : "flag"
        actionButton_Lumia.setImage(UIImage(systemName: icon_Lumia, withConfiguration: cfg_Lumia), for: .normal)
        actionButton_Lumia.tintColor = isOwn
            ? UIColor(hexstring_Lumia: "#E53E3E", alpha_Lumia: 0.75)
            : UIColor(hexstring_Lumia: "#C0A8D8")
    }

    @objc private func handleAction_Lumia() { onActionTapped_Lumia?() }
}

// MARK: - 胶片卷查看器

/// 全屏胶片卷查看器（已冲洗的卷的所有帧 + 手记）
/// 胶片卷查看器
/// 核心作用：以三列网格展示整卷已曝光帧，点击任意帧全屏放大浏览
/// 使用 UICollectionView 保证点击响应可靠，行列布局自动
class FilmRollViewerSheet_Lumia: UIViewController {

    private let roll_Lumia: FilmRoll_Lumia
    private var exposedFrames_Lumia: [FilmFrame_Lumia] = []

    // MARK: - UI 组件

    private let closeButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn_Lumia.layer.cornerRadius = 19
        return btn_Lumia
    }()

    private lazy var collectionView_Lumia: UICollectionView = {
        let spacing_Lumia: CGFloat = 4
        let cols_Lumia: CGFloat = 3
        let cellW_Lumia = (UIScreen.main.bounds.width - spacing_Lumia * (cols_Lumia + 1)) / cols_Lumia
        let layout_Lumia = UICollectionViewFlowLayout()
        layout_Lumia.itemSize = CGSize(width: cellW_Lumia, height: cellW_Lumia)
        layout_Lumia.minimumLineSpacing = spacing_Lumia
        layout_Lumia.minimumInteritemSpacing = spacing_Lumia
        layout_Lumia.sectionInset = UIEdgeInsets(top: spacing_Lumia, left: spacing_Lumia,
                                                  bottom: spacing_Lumia, right: spacing_Lumia)
        let cv_Lumia = UICollectionView(frame: .zero, collectionViewLayout: layout_Lumia)
        cv_Lumia.backgroundColor = .clear
        cv_Lumia.showsVerticalScrollIndicator = false
        return cv_Lumia
    }()

    // MARK: - 初始化

    init(roll: FilmRoll_Lumia) {
        self.roll_Lumia = roll
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#0A0A18")
        exposedFrames_Lumia = roll_Lumia.frames_Lumia.filter { $0.isExposed_Lumia }
        setupUI_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        // 顶部栏
        let topBar_Lumia = UIView()
        topBar_Lumia.backgroundColor = .clear
        view.addSubview(topBar_Lumia)
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }

        topBar_Lumia.addSubview(closeButton_Lumia)
        closeButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(38)
        }
        closeButton_Lumia.addTarget(self, action: #selector(handleClose_Lumia), for: .touchUpInside)

        let rollLabel_Lumia = UILabel()
        rollLabel_Lumia.text = roll_Lumia.rollName_Lumia
        rollLabel_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        rollLabel_Lumia.textColor = .white
        topBar_Lumia.addSubview(rollLabel_Lumia)
        rollLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.centerY.equalTo(closeButton_Lumia)
        }

        let dateLabel_Lumia = UILabel()
        dateLabel_Lumia.text = "\(roll_Lumia.dateString_Lumia)  ·  \(roll_Lumia.exposedCount_Lumia) frames"
        dateLabel_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.60)
        topBar_Lumia.addSubview(dateLabel_Lumia)
        dateLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(rollLabel_Lumia)
            make.top.equalTo(rollLabel_Lumia.snp.bottom).offset(3)
        }

        // CollectionView 网格（点击可靠）
        view.addSubview(collectionView_Lumia)
        collectionView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        collectionView_Lumia.delegate = self
        collectionView_Lumia.dataSource = self
        collectionView_Lumia.register(FilmFrameCell_Lumia.self, forCellWithReuseIdentifier: "FilmFrameCell_Lumia")

        // 空状态
        if exposedFrames_Lumia.isEmpty {
            let emptyLabel_Lumia = UILabel()
            emptyLabel_Lumia.text = "No exposed frames in this roll."
            emptyLabel_Lumia.font = UIFont.systemFont(ofSize: 14)
            emptyLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.5)
            emptyLabel_Lumia.textAlignment = .center
            view.addSubview(emptyLabel_Lumia)
            emptyLabel_Lumia.snp.makeConstraints { make in make.center.equalToSuperview() }
        }
    }

    @objc private func handleClose_Lumia() { dismiss(animated: true) }
}

// MARK: - CollectionView delegate

extension FilmRollViewerSheet_Lumia: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exposedFrames_Lumia.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Lumia = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FilmFrameCell_Lumia", for: indexPath
        ) as! FilmFrameCell_Lumia
        cell_Lumia.configure_Lumia(frame: exposedFrames_Lumia[indexPath.item])
        return cell_Lumia
    }

    /// 点击帧 → 全屏展示图片
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let frame_Lumia = exposedFrames_Lumia[indexPath.item]
        guard let path_Lumia = frame_Lumia.imagePath_Lumia,
              let image_Lumia = UIImage(contentsOfFile: path_Lumia) ?? UIImage(named: path_Lumia) else { return }
        let viewer_Lumia = FullScreenImageViewer_Lumia(image: image_Lumia,
                                                       caption: "#\(frame_Lumia.frameIndex_Lumia)  \(frame_Lumia.takenAt_Lumia)")
        viewer_Lumia.modalPresentationStyle = .fullScreen
        viewer_Lumia.modalTransitionStyle = .crossDissolve
        present(viewer_Lumia, animated: true)
    }
}

// MARK: - 帧缩略图 Cell

private class FilmFrameCell_Lumia: UICollectionViewCell {

    private let imageView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.contentMode = .scaleAspectFill
        iv_Lumia.clipsToBounds = true
        iv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#1A1A2E")
        return iv_Lumia
    }()

    private let timeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 9, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.85)
        lbl_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return lbl_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        contentView.addSubview(imageView_Lumia)
        contentView.addSubview(timeLabel_Lumia)
        imageView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        timeLabel_Lumia.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure_Lumia(frame: FilmFrame_Lumia) {
        if let path_Lumia = frame.imagePath_Lumia {
            imageView_Lumia.image = UIImage(contentsOfFile: path_Lumia) ?? UIImage(named: path_Lumia)
        }
        timeLabel_Lumia.text = "  #\(frame.frameIndex_Lumia)  \(frame.takenAt_Lumia)"
    }
}

// MARK: - 全屏图片浏览器

/// 全屏单张图片浏览，支持双指捏合缩放，下滑关闭
class FullScreenImageViewer_Lumia: UIViewController, UIScrollViewDelegate {

    private let image_Lumia: UIImage
    private let caption_Lumia: String

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.minimumZoomScale = 1.0
        sv_Lumia.maximumZoomScale = 4.0
        sv_Lumia.showsHorizontalScrollIndicator = false
        sv_Lumia.showsVerticalScrollIndicator = false
        sv_Lumia.backgroundColor = .black
        return sv_Lumia
    }()

    private let imageView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.contentMode = .scaleAspectFit
        iv_Lumia.clipsToBounds = true
        return iv_Lumia
    }()

    private let captionLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.75)
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let closeBtn_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn_Lumia.layer.cornerRadius = 20
        return btn_Lumia
    }()

    init(image: UIImage, caption: String) {
        self.image_Lumia = image
        self.caption_Lumia = caption
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // 滚动视图（缩放）
        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        scrollView_Lumia.delegate = self

        imageView_Lumia.image = image_Lumia
        scrollView_Lumia.addSubview(imageView_Lumia)
        imageView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview(); make.size.equalToSuperview() }

        // 说明文字
        view.addSubview(captionLabel_Lumia)
        captionLabel_Lumia.text = caption_Lumia
        captionLabel_Lumia.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
        }

        // 关闭按钮
        view.addSubview(closeBtn_Lumia)
        closeBtn_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(40)
        }
        closeBtn_Lumia.addTarget(self, action: #selector(handleClose_Lumia), for: .touchUpInside)

        // 双击还原缩放
        let doubleTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Lumia(_:)))
        doubleTap_Lumia.numberOfTapsRequired = 2
        scrollView_Lumia.addGestureRecognizer(doubleTap_Lumia)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return imageView_Lumia }

    @objc private func handleClose_Lumia() { dismiss(animated: true) }

    @objc private func handleDoubleTap_Lumia(_ gesture: UITapGestureRecognizer) {
        if scrollView_Lumia.zoomScale > 1.0 {
            scrollView_Lumia.setZoomScale(1.0, animated: true)
        } else {
            let point_Lumia = gesture.location(in: imageView_Lumia)
            let rect_Lumia = CGRect(x: point_Lumia.x - 50, y: point_Lumia.y - 50, width: 100, height: 100)
            scrollView_Lumia.zoom(to: rect_Lumia, animated: true)
        }
    }
}

// MARK: - 创建时光胶囊 Sheet

/// 创建时光胶囊的全屏表单
class CreateCapsuleSheet_Lumia: UIViewController {

    var onCreated_Lumia: ((String, String?, String) -> Void)?

    private var selectedImagePath_Lumia: String?
    private var unlockDateString_Lumia: String = ""

    private let messageField_Lumia: UITextView = {
        let tv_Lumia = UITextView()
        tv_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1040")
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")
        tv_Lumia.layer.cornerRadius = 12
        tv_Lumia.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv_Lumia
    }()

    private let datePicker_Lumia: UIDatePicker = {
        let dp_Lumia = UIDatePicker()
        dp_Lumia.datePickerMode = .date
        dp_Lumia.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        if #available(iOS 13.4, *) { dp_Lumia.preferredDatePickerStyle = .compact }
        dp_Lumia.tintColor = UIColor(hexstring_Lumia: "#8A5CC8")
        return dp_Lumia
    }()

    private let addPhotoButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Add Photo (Optional)", for: .normal)
        btn_Lumia.setTitleColor(UIColor(hexstring_Lumia: "#8A5CC8"), for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F8")
        btn_Lumia.layer.cornerRadius = 12
        return btn_Lumia
    }()

    private let sealButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Seal Capsule ⏳", for: .normal)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#1A4A6A")
        btn_Lumia.layer.cornerRadius = 26
        return btn_Lumia
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#0E1E2E")
        setupUI_Lumia()
    }

    private func setupUI_Lumia() {
        let closeBtn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        closeBtn_Lumia.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
        closeBtn_Lumia.tintColor = .white
        closeBtn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        closeBtn_Lumia.layer.cornerRadius = 18
        view.addSubview(closeBtn_Lumia)
        closeBtn_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        closeBtn_Lumia.addTarget(self, action: #selector(handleClose_Lumia), for: .touchUpInside)

        let titleLabel_Lumia = UILabel()
        titleLabel_Lumia.text = "New Time Capsule"
        titleLabel_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        titleLabel_Lumia.textColor = .white
        view.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.centerY.equalTo(closeBtn_Lumia)
        }

        let msgLabel_Lumia = UILabel()
        msgLabel_Lumia.text = "Your message"
        msgLabel_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        msgLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.70)
        view.addSubview(msgLabel_Lumia)
        msgLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(closeBtn_Lumia.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(22)
        }

        view.addSubview(messageField_Lumia)
        messageField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(msgLabel_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }

        let unlockLabel_Lumia = UILabel()
        unlockLabel_Lumia.text = "Unlock date"
        unlockLabel_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        unlockLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.70)
        view.addSubview(unlockLabel_Lumia)
        unlockLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(messageField_Lumia.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(22)
        }

        view.addSubview(datePicker_Lumia)
        datePicker_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(unlockLabel_Lumia)
            make.trailing.equalToSuperview().offset(-20)
        }

        view.addSubview(addPhotoButton_Lumia)
        addPhotoButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(unlockLabel_Lumia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        addPhotoButton_Lumia.addTarget(self, action: #selector(handleAddPhoto_Lumia), for: .touchUpInside)

        view.addSubview(sealButton_Lumia)
        sealButton_Lumia.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        sealButton_Lumia.addTarget(self, action: #selector(handleSeal_Lumia), for: .touchUpInside)
    }

    @objc private func handleClose_Lumia() { dismiss(animated: true) }

    @objc private func handleAddPhoto_Lumia() {
        MediaPickerHelper_Lumia.pickImage_Lumia(from: self) { [weak self] image_Lumia in
            guard let self = self, let image_Lumia = image_Lumia else { return }
            self.selectedImagePath_Lumia = FilmViewModel_Lumia.shared_Lumia.saveImageToDocuments_Lumia(image: image_Lumia)
            self.addPhotoButton_Lumia.setTitle("✓ Photo Added", for: .normal)
            self.addPhotoButton_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#D0E8D0")
        }
    }

    @objc private func handleSeal_Lumia() {
        let msg_Lumia = messageField_Lumia.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !msg_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please write a message for the capsule.")
            return
        }
        let f_Lumia = DateFormatter(); f_Lumia.dateFormat = "yyyy-MM-dd"
        let dateStr_Lumia = f_Lumia.string(from: datePicker_Lumia.date)
        dismiss(animated: true) { [weak self] in
            self?.onCreated_Lumia?(msg_Lumia, self?.selectedImagePath_Lumia, dateStr_Lumia)
        }
    }
}

// MARK: - 主题征集提交 Sheet

/// 向本周主题提交照片的全屏表单
class ThemeSubmitSheet_Lumia: UIViewController {

    var onSubmitted_Lumia: ((String?, String) -> Void)?
    private let theme_Lumia: FilmTheme_Lumia
    private var selectedImagePath_Lumia: String?

    private let descField_Lumia: UITextView = {
        let tv_Lumia = UITextView()
        tv_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1040")
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")
        tv_Lumia.layer.cornerRadius = 12
        tv_Lumia.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv_Lumia
    }()

    private let photoPreview_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.contentMode = .scaleAspectFill
        iv_Lumia.clipsToBounds = true
        iv_Lumia.layer.cornerRadius = 12
        iv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F8")
        iv_Lumia.image = UIImage(systemName: "photo.on.rectangle.angled")
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#B0A0D0")
        return iv_Lumia
    }()

    private let submitButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setTitle("Submit to Exhibition", for: .normal)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.layer.cornerRadius = 26
        return btn_Lumia
    }()

    init(theme: FilmTheme_Lumia) {
        self.theme_Lumia = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#FAFAFE")
        setupUI_Lumia()
        // 提交按钮颜色
        submitButton_Lumia.backgroundColor = UIColor(hexstring_Lumia: theme_Lumia.accentColor_Lumia)
    }

    private func setupUI_Lumia() {
        let closeBtn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        closeBtn_Lumia.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lumia), for: .normal)
        closeBtn_Lumia.tintColor = UIColor(hexstring_Lumia: "#6040A0")
        closeBtn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F8")
        closeBtn_Lumia.layer.cornerRadius = 18
        view.addSubview(closeBtn_Lumia)
        closeBtn_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        closeBtn_Lumia.addTarget(self, action: #selector(handleClose_Lumia), for: .touchUpInside)

        let titleLabel_Lumia = UILabel()
        titleLabel_Lumia.text = theme_Lumia.themeTitle_Lumia
        titleLabel_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        titleLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#1A1030")
        view.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.centerY.equalTo(closeBtn_Lumia)
        }

        // 照片预览区（点击选择）
        view.addSubview(photoPreview_Lumia)
        photoPreview_Lumia.snp.makeConstraints { make in
            make.top.equalTo(closeBtn_Lumia.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        photoPreview_Lumia.isUserInteractionEnabled = true
        photoPreview_Lumia.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickPhoto_Lumia)))

        let descLabel_Lumia = UILabel()
        descLabel_Lumia.text = "Your description"
        descLabel_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        descLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#6040A0")
        view.addSubview(descLabel_Lumia)
        descLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(photoPreview_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(22)
        }

        view.addSubview(descField_Lumia)
        descField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }

        view.addSubview(submitButton_Lumia)
        submitButton_Lumia.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        submitButton_Lumia.addTarget(self, action: #selector(handleSubmit_Lumia), for: .touchUpInside)
    }

    @objc private func handleClose_Lumia() { dismiss(animated: true) }

    @objc private func handlePickPhoto_Lumia() {
        MediaPickerHelper_Lumia.pickImage_Lumia(from: self) { [weak self] image_Lumia in
            guard let self = self, let image_Lumia = image_Lumia else { return }
            self.photoPreview_Lumia.image = image_Lumia
            self.selectedImagePath_Lumia = FilmViewModel_Lumia.shared_Lumia.saveImageToDocuments_Lumia(image: image_Lumia)
        }
    }

    @objc private func handleSubmit_Lumia() {
        let desc_Lumia = descField_Lumia.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !desc_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please write a description for your submission.")
            return
        }
        dismiss(animated: true) { [weak self] in
            self?.onSubmitted_Lumia?(self?.selectedImagePath_Lumia, desc_Lumia)
        }
    }
}
