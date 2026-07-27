import Foundation
import UIKit
import SnapKit

// MARK: - 首页

/// 首页视图控制器
/// 核心作用：聚合胶片功能模块（今日胶片卷+胶片柜、主题讨论区），以纵向滚动方式呈现；
///          时光胶囊功能已迁移至发现页展示，故不再包含于首页
/// 设计思路：
///   - 暖色调纸质背景（#F8F3EC）模拟冲洗相纸质感
///   - 每个模块作为独立 UIView，职责单一
///   - 通知驱动刷新，保证数据实时性
/// 关键属性：
///   - filmVM_Lumia: 胶片业务 ViewModel（今日卷/胶片柜/主题）
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
    private lazy var filmToolsSection_Lumia = FilmLabToolsView_Lumia()
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

        // 功能模块（已冲洗胶卷网格已移至独立的冲洗照片展示页；时光胶囊已移至发现页展示）
        contentStack_Lumia.addArrangedSubview(filmWallSection_Lumia)
        contentStack_Lumia.addArrangedSubview(filmToolsSection_Lumia)
        contentStack_Lumia.addArrangedSubview(themeSection_Lumia)

        // 各模块回调绑定
        filmWallSection_Lumia.onShootTapped_Lumia = { [weak self] in self?.handleShoot_Lumia() }
        filmWallSection_Lumia.onViewPhotosTapped_Lumia = { [weak self] in self?.handleViewPhotos_Lumia() }
        filmWallSection_Lumia.onDevelopTapped_Lumia = { [weak self] in self?.handleDevelop_Lumia() }
        filmWallSection_Lumia.onDeleteFrame_Lumia = { [weak self] frameIndex_Lumia in
            self?.handleDeleteFrame_Lumia(frameIndex: frameIndex_Lumia)
        }

        filmToolsSection_Lumia.onToolTapped_Lumia = { [weak self] toolType_Lumia in
            self?.handleToolTapped_Lumia(toolType_Lumia)
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

        let theme_Lumia = filmVM_Lumia.getCurrentTheme_Lumia()
        let comments_Lumia = filmVM_Lumia.getDiscussionComments_Lumia(themeId: theme_Lumia.themeId_Lumia)
        themeSection_Lumia.configure_Lumia(theme: theme_Lumia, comments: comments_Lumia)
    }

    // MARK: - 通知

    private func setupObservers_Lumia() {
        // 用户状态变更（登录/登出）→ 整页刷新
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia, object: nil
        )
        // 主题讨论区评论增/删 → 同步刷新首页评论数与预览
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDiscussionChange_Lumia),
            name: FilmViewModel_Lumia.discussionCommentDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleStateChange_Lumia() { reloadAll_Lumia() }

    /// 仅刷新主题讨论区模块，避免整页重建影响性能
    @objc private func handleDiscussionChange_Lumia() {
        let theme_Lumia = filmVM_Lumia.getCurrentTheme_Lumia()
        let comments_Lumia = filmVM_Lumia.getDiscussionComments_Lumia(themeId: theme_Lumia.themeId_Lumia)
        themeSection_Lumia.configure_Lumia(theme: theme_Lumia, comments: comments_Lumia)
    }
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
            Utils_Lumia.showInfo_Lumia(message_Lumia: "Today's roll is full! It has been developed automatically.")
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

    /// 查看冲洗照片：跳转到冲洗照片展示页，展示所有已冲洗胶卷；若暂无已冲洗胶卷则由该页面显示缺省态
    private func handleViewPhotos_Lumia() {
        Navigation_Lumia.push_Lumia(to: DevelopedPhotosPage_Lumia())
    }

    /// 冲洗今日胶卷：无需等待拍满即可提前冲洗，冲洗后照片会出现在冲洗照片展示页
    private func handleDevelop_Lumia() {
        let roll_Lumia = filmVM_Lumia.getTodayRoll_Lumia()
        guard roll_Lumia.exposedCount_Lumia > 0 else {
            Utils_Lumia.showInfo_Lumia(message_Lumia: "No frames exposed yet. Start shooting first!")
            return
        }
        let alert_Lumia = UIAlertController(
            title: "Develop Film Roll",
            message: "Develop '\(roll_Lumia.rollName_Lumia)'? It will be processed and added to your developed photos.",
            preferredStyle: .alert
        )
        alert_Lumia.addAction(UIAlertAction(title: "Develop", style: .default) { [weak self] _ in
            self?.filmVM_Lumia.developTodayRoll_Lumia()
            self?.reloadAll_Lumia()
            Utils_Lumia.showSuccess_Lumia(message_Lumia: "Roll developed! ✦")
        })
        alert_Lumia.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Lumia, animated: true)
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

    /// 进入主题讨论详情页
    private func handleEnterDiscussion_Lumia(theme: FilmTheme_Lumia) {
        let detail_Lumia = ThemeDiscussionDetail_Lumia(theme: theme)
        detail_Lumia.onCommentAdded_Lumia = { [weak self] in self?.reloadAll_Lumia() }
        detail_Lumia.modalPresentationStyle = .fullScreen
        detail_Lumia.modalTransitionStyle = .coverVertical
        present(detail_Lumia, animated: true)
    }

    /// 跳转到胶片工作室工具页（预设离线库/手动调节面板/硬件特效/曝光计算器/冲洗时长计算器）
    private func handleToolTapped_Lumia(_ toolType_Lumia: FilmToolType_Lumia) {
        let destination_Lumia: UIViewController
        switch toolType_Lumia {
        case .presetsLibrary_Lumia:
            destination_Lumia = FilmPresetsLibraryPage_Lumia()
        case .adjustmentPanel_Lumia:
            destination_Lumia = FilmAdjustmentPanelPage_Lumia()
        case .hardwareEffects_Lumia:
            destination_Lumia = FilmHardwareEffectsPage_Lumia()
        case .exposureCalculator_Lumia:
            destination_Lumia = ExposureCalculatorPage_Lumia()
        case .developingCalculator_Lumia:
            destination_Lumia = DevelopingTimeCalculatorPage_Lumia()
        }
        Navigation_Lumia.push_Lumia(to: destination_Lumia)
    }
}

// MARK: 胶片ViewModel

/// 胶片功能业务逻辑层
/// 核心作用：管理今日胶片卷的曝光、冲洗，胶片柜列表，主题征集的提交/读取
class FilmViewModel_Lumia {

    static let shared_Lumia = FilmViewModel_Lumia()

    // MARK: - 通知名称

    /// 主题讨论区评论变更通知（增/删）
    static let discussionCommentDidChangeNotification_Lumia = Notification.Name("DiscussionCommentDidChange_Lumia")

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
        postDiscussionChangeNotification_Lumia()
    }

    /// 删除指定评论
    func deleteDiscussionComment_Lumia(themeId: Int, commentId: Int) {
        discussionComments_Lumia[themeId]?.removeAll { $0.commentId_Lumia == commentId }
        postDiscussionChangeNotification_Lumia()
    }

    /// 发出主题讨论区评论变更通知，供首页及时刷新评论数与预览
    private func postDiscussionChangeNotification_Lumia() {
        NotificationCenter.default.post(
            name: FilmViewModel_Lumia.discussionCommentDidChangeNotification_Lumia,
            object: nil
        )
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
            (4, 0, "Found incredible symmetry in a downtown parking structure — film just loves hard lines."),
            (4, 1, "Shot the fire escape shadows at noon. The geometry is brutal and beautiful."),
            (4, 2, "Black and white really amplifies the urban geometry theme. Ilford Delta 100 was perfect."),
            (4, 3, "Every crosswalk, every grid window — the city is full of patterns waiting to be framed."),
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

    /// 手动冲洗今日卷（无需等待拍满即可提前冲洗，冲洗后的照片会出现在冲洗照片展示页）
    func developTodayRoll_Lumia() {
        let today_Lumia = dateString_Lumia(from: Date())
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia,
              let rollIdx_Lumia = user_Lumia.filmRolls_Lumia.firstIndex(where: {
                  $0.dateString_Lumia == today_Lumia && !$0.isDeveloped_Lumia
              }) else { return }
        user_Lumia.filmRolls_Lumia[rollIdx_Lumia].isDeveloped_Lumia = true
    }

    // MARK: - 胶片柜

    /// 获取已冲洗的胶片卷（按时间倒序）
    func getDevelopedRolls_Lumia() -> [FilmRoll_Lumia] {
        guard let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia() as? LoginUserModel_Lumia else { return [] }
        return user_Lumia.filmRolls_Lumia
            .filter { $0.isDeveloped_Lumia }
            .sorted { $0.dateString_Lumia > $1.dateString_Lumia }
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
/// 核心作用：以真实胶片条形式展示今日胶片卷，每帧可点击曝光，显示已拍/总帧数；
///          右上角提供入口跳转至冲洗照片展示页；Shoot 按钮右侧的 Develop 按钮可手动冲洗当前卷
/// 设计：深色胶片条（#1A1A2E）+ 左右穿孔 + 24 帧横向滚动
private class TodayFilmWallView_Lumia: UIView {

    var onShootTapped_Lumia: (() -> Void)?
    /// 删除指定帧回调（参数为 frameIndex）
    var onDeleteFrame_Lumia: ((Int) -> Void)?
    /// 查看冲洗照片回调（计数徽章右侧的小按钮，点击跳转到冲洗照片展示页）
    var onViewPhotosTapped_Lumia: (() -> Void)?
    /// 冲洗胶卷回调（Shoot 按钮右侧的 Develop 按钮）
    var onDevelopTapped_Lumia: (() -> Void)?

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

    /// 查看已拍照片按钮（位于计数徽章右侧 10pt 处）
    private let viewPhotosButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        btn_Lumia.setImage(UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#F6A623")
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623", alpha_Lumia: 0.12)
        btn_Lumia.layer.cornerRadius = 11
        return btn_Lumia
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

    /// 冲洗按钮：将今日卷标记为已冲洗，冲洗后的照片会出现在冲洗照片展示页
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

        // 查看已拍照片按钮：位于计数徽章右侧 10pt 处，为最靠右元素
        addSubview(viewPhotosButton_Lumia)
        viewPhotosButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(iconBg_Lumia)
            make.trailing.equalToSuperview().offset(-14)
            make.width.height.equalTo(22)
        }
        viewPhotosButton_Lumia.addTarget(self, action: #selector(handleViewPhotos_Lumia), for: .touchUpInside)

        // 计数徽章：位于查看照片按钮左侧 10pt 处
        let counterBadge_Lumia = UIView()
        counterBadge_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623", alpha_Lumia: 0.12)
        counterBadge_Lumia.layer.cornerRadius = 11
        addSubview(counterBadge_Lumia)
        counterBadge_Lumia.addSubview(counterLabel_Lumia)
        counterBadge_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(iconBg_Lumia)
            make.trailing.equalTo(viewPhotosButton_Lumia.snp.leading).offset(-10)
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
            make.width.equalTo(100)
        }
        developButton_Lumia.addTarget(self, action: #selector(handleDevelop_Lumia), for: .touchUpInside)

        btnRow_Lumia.addSubview(shootButton_Lumia)
        shootButton_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(developButton_Lumia.snp.leading).offset(-10)
        }
        shootButton_Lumia.addTarget(self, action: #selector(handleShoot_Lumia), for: .touchUpInside)
    }

    /// 配置今日胶片墙
    /// - Parameter roll: 今日胶片卷（含各帧曝光状态）
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
        developButton_Lumia.alpha = (isActive_Lumia && roll.exposedCount_Lumia > 0) ? 1.0 : 0.5
    }

    @objc private func handleShoot_Lumia() { onShootTapped_Lumia?() }
    @objc private func handleViewPhotos_Lumia() { onViewPhotosTapped_Lumia?() }
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

// MARK: - Section: 胶片工作室工具入口

/// 胶片工作室工具类型
/// 核心作用：标识首页「Film Lab Tools」卡片中的五个工具入口，供 Home_Lumia 路由到对应工具页
enum FilmToolType_Lumia: Equatable {
    /// 海量胶片预设离线库
    case presetsLibrary_Lumia
    /// 胶片参数手动调节面板
    case adjustmentPanel_Lumia
    /// 模拟胶片硬件特效
    case hardwareEffects_Lumia
    /// 曝光计算工具
    case exposureCalculator_Lumia
    /// 胶片冲洗时长计算器
    case developingCalculator_Lumia
}

/// 胶片工作室工具入口卡片
/// 核心作用：以宫格形式展示五个离线胶片工作室工具入口（预设库/手动调节/硬件特效/曝光计算/冲洗计算），
///          点击任意格子回调对应工具类型，由 Home_Lumia 负责实际跳转
/// 设计：暖棕色卡片延续首页视觉语言，两列宫格展示图标+标题，避免类似列表的纵向堆叠视觉
private class FilmLabToolsView_Lumia: UIView {

    /// 点击工具入口回调
    var onToolTapped_Lumia: ((FilmToolType_Lumia) -> Void)?

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "🧪  Film Lab Tools"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#4A3020")
        return lbl_Lumia
    }()

    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Offline darkroom toolkit for film shooters"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#B08860")
        return lbl_Lumia
    }()

    private let gridStack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 10
        sv_Lumia.distribution = .fillEqually
        return sv_Lumia
    }()

    /// 工具入口配置 (图标, 标题, 图标底色, 类型)
    private let toolItems_Lumia: [(String, String, UIColor, FilmToolType_Lumia)] = [
        ("archivebox.fill", "Presets Library", UIColor(hexstring_Lumia: "#D4654E"), .presetsLibrary_Lumia),
        ("slider.horizontal.3", "Adjustment Panel", UIColor(hexstring_Lumia: "#F6A623"), .adjustmentPanel_Lumia),
        ("sparkles", "Hardware Effects", UIColor(hexstring_Lumia: "#7B5CD6"), .hardwareEffects_Lumia),
        ("camera.aperture", "Exposure Calculator", UIColor(hexstring_Lumia: "#4A90D9"), .exposureCalculator_Lumia),
        ("timer", "Developing Timer", UIColor(hexstring_Lumia: "#3FA796"), .developingCalculator_Lumia)
    ]

    private let columns_Lumia = 2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#FFF3E0")
        layer.cornerRadius = 18
        layer.shadowColor = UIColor(hexstring_Lumia: "#D4654E").cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        let leftBar_Lumia = UIView()
        leftBar_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#7B5CD6")
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

        addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        addSubview(gridStack_Lumia)
        gridStack_Lumia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Lumia.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-12)
        }

        // 两列宫格布局：每行两个格子，最后一行不足时补占位空视图保持对齐
        let rows_Lumia = Int(ceil(Double(toolItems_Lumia.count) / Double(columns_Lumia)))
        for rowIdx_Lumia in 0..<rows_Lumia {
            let rowStack_Lumia = UIStackView()
            rowStack_Lumia.axis = .horizontal
            rowStack_Lumia.spacing = 10
            rowStack_Lumia.distribution = .fillEqually
            for colIdx_Lumia in 0..<columns_Lumia {
                let idx_Lumia = rowIdx_Lumia * columns_Lumia + colIdx_Lumia
                if idx_Lumia < toolItems_Lumia.count {
                    let (iconName_Lumia, title_Lumia, color_Lumia, _) = toolItems_Lumia[idx_Lumia]
                    let cell_Lumia = buildToolCell_Lumia(iconName: iconName_Lumia, title: title_Lumia, color: color_Lumia)
                    cell_Lumia.tag = idx_Lumia
                    let tap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleCellTapped_Lumia(_:)))
                    cell_Lumia.addGestureRecognizer(tap_Lumia)
                    cell_Lumia.isUserInteractionEnabled = true
                    rowStack_Lumia.addArrangedSubview(cell_Lumia)
                    cell_Lumia.snp.makeConstraints { make in make.height.equalTo(76) }
                } else {
                    rowStack_Lumia.addArrangedSubview(UIView())
                }
            }
            gridStack_Lumia.addArrangedSubview(rowStack_Lumia)
        }
    }

    private func buildToolCell_Lumia(iconName: String, title: String, color: UIColor) -> UIView {
        let cell_Lumia = UIView()
        cell_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        cell_Lumia.layer.cornerRadius = 14

        let iconBg_Lumia = UIView()
        iconBg_Lumia.backgroundColor = color.withAlphaComponent(0.16)
        iconBg_Lumia.layer.cornerRadius = 17
        cell_Lumia.addSubview(iconBg_Lumia)
        iconBg_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(34)
        }
        let iconView_Lumia = UIImageView(image: UIImage(systemName: iconName))
        iconView_Lumia.tintColor = color
        iconView_Lumia.contentMode = .scaleAspectFit
        iconBg_Lumia.addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(17)
        }

        let titleLbl_Lumia = UILabel()
        titleLbl_Lumia.text = title
        titleLbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLbl_Lumia.textColor = UIColor(hexstring_Lumia: "#3A2010")
        titleLbl_Lumia.textAlignment = .center
        titleLbl_Lumia.numberOfLines = 2
        cell_Lumia.addSubview(titleLbl_Lumia)
        titleLbl_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Lumia.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(6)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }

        return cell_Lumia
    }

    @objc private func handleCellTapped_Lumia(_ gesture_Lumia: UITapGestureRecognizer) {
        guard let view_Lumia = gesture_Lumia.view, view_Lumia.tag < toolItems_Lumia.count else { return }
        let type_Lumia = toolItems_Lumia[view_Lumia.tag].3
        view_Lumia.animatePressDown_Lumia {
            view_Lumia.animatePressUp_Lumia {
                self.onToolTapped_Lumia?(type_Lumia)
            }
        }
    }
}

// MARK: - 冲洗照片展示页

/// 冲洗照片展示页
/// 核心作用：直接以相册网格展示所有已冲洗胶卷中的照片（即"冲洗的照片"，不再按胶片盒分组），
///          点击今日胶片墙右上角图标跳转至此；暂无照片时展示缺省态
/// 设计思路：
///   - 顶部为悬浮返回按钮 + 标题，风格与其他二级页面（如 UserInfo_Lumia）保持一致
///   - 内容区为三列等宽方格 UICollectionView，复用 FilmFrameCell_Lumia 缩略图样式
///   - 点击任意照片进入 FullScreenImageViewer_Lumia 全屏浏览
/// 关键属性：
///   - filmVM_Lumia: 胶片业务 ViewModel，提供已冲洗胶卷数据
///   - photos_Lumia: 展平后的照片列表（帧 + 所属卷名），按卷时间倒序排列
class DevelopedPhotosPage_Lumia: UIViewController {

    // MARK: - 内部类型

    /// 相册单张照片（携带所属胶卷名，用于全屏浏览时展示说明文字）
    private struct PhotoItem_Lumia {
        let frame_Lumia: FilmFrame_Lumia
        let rollName_Lumia: String
    }

    // MARK: - 私有属性

    private let filmVM_Lumia = FilmViewModel_Lumia.shared_Lumia
    private var photos_Lumia: [PhotoItem_Lumia] = []

    private static let gridSpacing_Lumia: CGFloat = 4
    private static let gridColumns_Lumia: CGFloat = 3

    private lazy var collectionView_Lumia: UICollectionView = {
        let layout_Lumia = UICollectionViewFlowLayout()
        let cellW_Lumia = (UIScreen.main.bounds.width - 32 - Self.gridSpacing_Lumia * (Self.gridColumns_Lumia - 1)) / Self.gridColumns_Lumia
        layout_Lumia.itemSize = CGSize(width: cellW_Lumia, height: cellW_Lumia)
        layout_Lumia.minimumLineSpacing = Self.gridSpacing_Lumia
        layout_Lumia.minimumInteritemSpacing = Self.gridSpacing_Lumia
        layout_Lumia.sectionInset = UIEdgeInsets(top: 4, left: 0, bottom: 100, right: 0)
        let cv_Lumia = UICollectionView(frame: .zero, collectionViewLayout: layout_Lumia)
        cv_Lumia.backgroundColor = .clear
        cv_Lumia.showsVerticalScrollIndicator = false
        return cv_Lumia
    }()

    private let backButton_Lumia = BackButton_Lumia()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Developed Photos"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#2A1008")
        return lbl_Lumia
    }()

    /// 空状态容器：暂无冲洗照片时居中展示
    private let emptyContainer_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#F8F3EC")
        setupUI_Lumia()
        reloadData_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
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

        view.addSubview(collectionView_Lumia)
        collectionView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        collectionView_Lumia.delegate = self
        collectionView_Lumia.dataSource = self
        collectionView_Lumia.register(FilmFrameCell_Lumia.self, forCellWithReuseIdentifier: "FilmFrameCell_Lumia")

        // 空状态：图标 + 文字，居中于相册所在区域
        view.addSubview(emptyContainer_Lumia)
        emptyContainer_Lumia.snp.makeConstraints { make in
            make.center.equalTo(collectionView_Lumia)
            make.width.equalTo(220)
        }
        let emptyIcon_Lumia = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled"))
        emptyIcon_Lumia.tintColor = UIColor(hexstring_Lumia: "#C09870")
        emptyIcon_Lumia.contentMode = .scaleAspectFit
        emptyContainer_Lumia.addSubview(emptyIcon_Lumia)
        emptyIcon_Lumia.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }
        let emptyLabel_Lumia = UILabel()
        emptyLabel_Lumia.text = "No developed photos yet.\nStart shooting and develop your first roll!"
        emptyLabel_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        emptyLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#A08060")
        emptyLabel_Lumia.textAlignment = .center
        emptyLabel_Lumia.numberOfLines = 2
        emptyContainer_Lumia.addSubview(emptyLabel_Lumia)
        emptyLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Lumia.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据刷新

    /// 拉取全部已冲洗胶卷并展平为照片列表（仅保留已曝光且有图片的帧）
    private func reloadData_Lumia() {
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else { return }
        let rolls_Lumia = filmVM_Lumia.getDevelopedRolls_Lumia()
        photos_Lumia = rolls_Lumia.flatMap { roll_Lumia in
            roll_Lumia.frames_Lumia
                .filter { $0.isExposed_Lumia && $0.imagePath_Lumia != nil }
                .map { PhotoItem_Lumia(frame_Lumia: $0, rollName_Lumia: roll_Lumia.rollName_Lumia) }
        }
        collectionView_Lumia.reloadData()

        let isEmpty_Lumia = photos_Lumia.isEmpty
        emptyContainer_Lumia.isHidden = !isEmpty_Lumia
        collectionView_Lumia.isHidden = isEmpty_Lumia
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension DevelopedPhotosPage_Lumia: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos_Lumia.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Lumia = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FilmFrameCell_Lumia", for: indexPath
        ) as! FilmFrameCell_Lumia
        cell_Lumia.configure_Lumia(frame: photos_Lumia[indexPath.item].frame_Lumia)
        return cell_Lumia
    }

    /// 点击照片 → 全屏展示
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item_Lumia = photos_Lumia[indexPath.item]
        guard let path_Lumia = item_Lumia.frame_Lumia.imagePath_Lumia,
              let image_Lumia = UIImage(contentsOfFile: path_Lumia) ?? UIImage(named: path_Lumia) else { return }
        let viewer_Lumia = FullScreenImageViewer_Lumia(
            image: image_Lumia,
            caption: "\(item_Lumia.rollName_Lumia) · #\(item_Lumia.frame_Lumia.frameIndex_Lumia)"
        )
        viewer_Lumia.modalPresentationStyle = .fullScreen
        viewer_Lumia.modalTransitionStyle = .crossDissolve
        present(viewer_Lumia, animated: true)
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

        // 横幅渐变：先移除旧层，再重建；立即赋帧避免 layoutSubviews 延迟导致首次显示为空白
        bannerGradient_Lumia?.removeFromSuperlayer()
        let base_Lumia = UIColor(hexstring_Lumia: theme.accentColor_Lumia)
        let grad_Lumia = CAGradientLayer()
        grad_Lumia.colors = [base_Lumia.cgColor, base_Lumia.withAlphaComponent(0.60).cgColor]
        grad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        grad_Lumia.cornerRadius = 14
        // 提前赋 frame：此时 themeBanner_Lumia 已经过初次布局，bounds 有效；
        // layoutSubviews 后会再次同步，保证旋转/尺寸变化也能正确更新
        grad_Lumia.frame = themeBanner_Lumia.bounds
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

        // 填充评论数据
        cell_Lumia.configure_Lumia(comment_Lumia: comment_Lumia)

        // 通过 ReportDeleteHelper_Lumia 创建举报/删除按钮，保持与全局规范一致
        let actionBtn_Lumia = ReportDeleteHelper_Lumia.createDiscussionCommentButton_Lumia(
            comment_Lumia: comment_Lumia,
            size_Lumia: 12,
            color_Lumia: UIColor(hexstring_Lumia: "#C0A8D8"),
            from: self,
            onDelete_Lumia: { [weak self] in
                // 确认删除后从 FilmViewModel 移除该评论并刷新列表
                guard let self else { return }
                FilmViewModel_Lumia.shared_Lumia.deleteDiscussionComment_Lumia(
                    themeId: self.theme_Lumia.themeId_Lumia,
                    commentId: comment_Lumia.commentId_Lumia
                )
                self.reloadComments_Lumia()
                self.onCommentAdded_Lumia?()
            },
            onBlock_Lumia: { [weak self] in
                // 拉黑后同步删除该用户在讨论区的所有评论并刷新列表
                guard let self else { return }
                FilmViewModel_Lumia.shared_Lumia.deleteDiscussionComment_Lumia(
                    themeId: self.theme_Lumia.themeId_Lumia,
                    commentId: comment_Lumia.commentId_Lumia
                )
                self.reloadComments_Lumia()
                self.onCommentAdded_Lumia?()
            }
        )
        cell_Lumia.insertActionButton_Lumia(actionBtn_Lumia)

        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
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
/// 按钮由外部通过 insertActionButton_Lumia(_:) 注入，实际由 ReportDeleteHelper_Lumia 创建，
/// 不在 Cell 内部自行创建，保持职责单一
private class DiscussionCommentCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "DiscussionCommentCell_Lumia"

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

    /// 按钮占位容器，尺寸固定，实际按钮由 insertActionButton_Lumia 注入
    private let actionButtonContainer_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.clipsToBounds = false
        return v_Lumia
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

        // 按钮容器：固定尺寸，位置与原 actionButton 一致
        contentView.addSubview(actionButtonContainer_Lumia)
        actionButtonContainer_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(nameLabel_Lumia)
            make.width.height.equalTo(28)
        }

        contentView.addSubview(contentLabel_Lumia)
        contentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Lumia)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        // 清除上一次注入的按钮，防止复用时旧按钮残留
        actionButtonContainer_Lumia.subviews.forEach { $0.removeFromSuperview() }
    }

    /// 填充评论数据（不含按钮，按钮由外部注入）
    /// - Parameter comment_Lumia: 要展示的讨论区评论
    func configure_Lumia(comment_Lumia: ThemeDiscussionComment_Lumia) {
        avatarView_Lumia.configure_Lumia(userId_Lumia: comment_Lumia.userId_Lumia)
        nameLabel_Lumia.text = comment_Lumia.userName_Lumia
        timeLabel_Lumia.text = comment_Lumia.createdAt_Lumia
        contentLabel_Lumia.text = comment_Lumia.content_Lumia
    }

    /// 注入由 ReportDeleteHelper_Lumia 创建的举报/删除按钮
    /// - Parameter button_Lumia: 已配置好图标与点击动作的按钮
    func insertActionButton_Lumia(_ button_Lumia: UIButton) {
        actionButtonContainer_Lumia.subviews.forEach { $0.removeFromSuperview() }
        actionButtonContainer_Lumia.addSubview(button_Lumia)
        button_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
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
