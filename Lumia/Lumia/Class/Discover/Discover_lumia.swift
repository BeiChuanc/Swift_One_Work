import Foundation
import UIKit
import SnapKit

// MARK: - 发现页

/// 发现页视图控制器
/// 核心作用：切换栏在「Posts」帖子瀑布流与「Capsules」时光胶囊列表之间切换展示，支持搜索、举报/删除，空结果居中缺省图
/// 设计思路：
///   - 顶栏采用暗色"胶片负片"风格（深暗底色 + 左右穿孔条 + 琥珀金配色），与首页暖橙形成互补
///   - 切换栏驱动展示模式切换而非分类过滤，搜索关键词在两种模式下均可叠加生效
///   - 无数据时显示居中缺省视图
/// 关键属性：
///   - posts_Lumia / capsules_Lumia: 帖子与胶囊的全量缓存
///   - filteredPosts_Lumia / filteredCapsules_Lumia: 当前展示的过滤后数据
///   - displayMode_Lumia: 当前展示模式（Posts / Capsules）
///   - searchKeyword_Lumia: 当前搜索关键词
class Discover_Lumia: UIViewController {

    // MARK: - 展示模式

    /// 发现页展示模式：帖子瀑布流 / 时光胶囊列表
    private enum DisplayMode_Lumia {
        case posts_Lumia
        case capsules_Lumia
    }

    // MARK: - 私有属性

    private var posts_Lumia: [TitleModel_Lumia] = []
    private var filteredPosts_Lumia: [TitleModel_Lumia] = []

    private var capsules_Lumia: [TimeCapsule_Lumia] = []
    private var filteredCapsules_Lumia: [TimeCapsule_Lumia] = []

    /// 当前展示模式（切换栏驱动）
    private var displayMode_Lumia: DisplayMode_Lumia = .posts_Lumia

    /// 当前搜索关键词（小写）
    private var searchKeyword_Lumia: String = ""

    private let waterfallLayout_Lumia = WaterfallLayout_Lumia()

    private lazy var collectionView_Lumia: UICollectionView = {
        let cv_Lumia = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout_Lumia)
        cv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")
        cv_Lumia.showsVerticalScrollIndicator = false
        cv_Lumia.contentInset = UIEdgeInsets(top: 10, left: 12, bottom: 100, right: 12)
        return cv_Lumia
    }()

    /// 时光胶囊列表视图（Capsules 模式）
    private let capsuleListView_Lumia = DiscoverCapsuleListView_Lumia()

    /// 空结果缺省视图（搜索无数据时居中展示）
    private let emptyStateView_Lumia = DiscoverEmptyView_Lumia()

    private let topBar_Lumia = DiscoverTopBar_Lumia()
    private let categoryBar_Lumia = DiscoverCategoryBar_Lumia()

    /// 新建时光胶囊按钮（仅 Capsules 模式下显示，位于切换栏右侧）
    private let addCapsuleButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Lumia.setImage(UIImage(systemName: "plus", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#6A40C0")
        btn_Lumia.layer.cornerRadius = 17
        btn_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#3A1A78").cgColor
        btn_Lumia.layer.shadowOpacity = 0.3
        btn_Lumia.layer.shadowRadius = 6
        btn_Lumia.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn_Lumia.isHidden = true
        return btn_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        setupObservers_Lumia()
        loadData_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Lumia()
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")

        view.addSubview(topBar_Lumia)
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        topBar_Lumia.onSearchChanged_Lumia = { [weak self] keyword_Lumia in
            self?.searchKeyword_Lumia = keyword_Lumia.lowercased()
            self?.applyFilters_Lumia()
        }

        view.addSubview(categoryBar_Lumia)
        categoryBar_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        categoryBar_Lumia.configure_Lumia(categories_Lumia: ["Posts", "Capsules"])
        categoryBar_Lumia.onCategorySelected_Lumia = { [weak self] index_Lumia in
            self?.displayMode_Lumia = index_Lumia == 1 ? .capsules_Lumia : .posts_Lumia
            self?.addCapsuleButton_Lumia.isHidden = index_Lumia != 1
            self?.applyFilters_Lumia()
        }

        // 新建时光胶囊按钮：仅 Capsules 模式下显示，悬浮于切换栏右侧
        view.addSubview(addCapsuleButton_Lumia)
        addCapsuleButton_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(categoryBar_Lumia)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(34)
        }
        addCapsuleButton_Lumia.addTarget(self, action: #selector(handleAddCapsule_Lumia), for: .touchUpInside)

        view.addSubview(collectionView_Lumia)
        collectionView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(categoryBar_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        view.addSubview(capsuleListView_Lumia)
        capsuleListView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(categoryBar_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        capsuleListView_Lumia.isHidden = true
        capsuleListView_Lumia.onCapsuleTapped_Lumia = { [weak self] capsule_Lumia in
            self?.handleCapsuleTap_Lumia(capsule: capsule_Lumia)
        }

        // 空结果缺省视图——居中于列表所在区域
        view.addSubview(emptyStateView_Lumia)
        emptyStateView_Lumia.snp.makeConstraints { make in
            make.center.equalTo(collectionView_Lumia)
            make.width.equalTo(220)
        }
        emptyStateView_Lumia.isHidden = true

        waterfallLayout_Lumia.delegate_Lumia = self
        waterfallLayout_Lumia.numberOfColumns_Lumia = 2
        waterfallLayout_Lumia.cellPadding_Lumia = 6

        collectionView_Lumia.delegate = self
        collectionView_Lumia.dataSource = self
        collectionView_Lumia.register(
            DiscoverPostCell_Lumia.self,
            forCellWithReuseIdentifier: DiscoverPostCell_Lumia.reuseId_Lumia
        )
        // 每日教学视频推荐作为瀑布流头部注册，随帖子列表一起滚动（不再悬浮固定）
        collectionView_Lumia.register(
            DiscoverTutorialVideosView_Lumia.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DiscoverTutorialVideosView_Lumia.reuseId_Lumia
        )
    }

    // MARK: - 数据

    private func loadData_Lumia() {
        posts_Lumia = TitleViewModel_Lumia.shared_Lumia.getPosts_Lumia()
        capsules_Lumia = DiscoverCapsuleViewModel_Lumia.shared_Lumia.getCapsules_Lumia()
        applyFilters_Lumia()
        triggerEntryAnimation_Lumia()
    }

    private func reloadData_Lumia() {
        posts_Lumia = TitleViewModel_Lumia.shared_Lumia.getPosts_Lumia()
        capsules_Lumia = DiscoverCapsuleViewModel_Lumia.shared_Lumia.getCapsules_Lumia()
        applyFilters_Lumia()
    }

    /// 根据当前展示模式应用搜索关键词过滤（Posts 过滤标题/内容/作者，Capsules 过滤留言/作者）
    private func applyFilters_Lumia() {
        switch displayMode_Lumia {
        case .posts_Lumia:
            var result_Lumia = posts_Lumia
            if !searchKeyword_Lumia.isEmpty {
                result_Lumia = result_Lumia.filter {
                    $0.title_Lumia.lowercased().contains(searchKeyword_Lumia) ||
                    $0.titleContent_Lumia.lowercased().contains(searchKeyword_Lumia) ||
                    $0.titleUserName_Lumia.lowercased().contains(searchKeyword_Lumia)
                }
            }
            filteredPosts_Lumia = result_Lumia
            waterfallLayout_Lumia.invalidateLayout()
            collectionView_Lumia.reloadData()

        case .capsules_Lumia:
            var result_Lumia = capsules_Lumia
            if !searchKeyword_Lumia.isEmpty {
                result_Lumia = result_Lumia.filter {
                    $0.message_Lumia.lowercased().contains(searchKeyword_Lumia) ||
                    $0.authorUserName_Lumia.lowercased().contains(searchKeyword_Lumia)
                }
            }
            filteredCapsules_Lumia = result_Lumia
            capsuleListView_Lumia.configure_Lumia(capsules: filteredCapsules_Lumia, from: self)
        }

        updateEmptyState_Lumia()
    }

    /// 根据当前展示模式与过滤结果，切换空状态视图与对应列表视图的显示
    private func updateEmptyState_Lumia() {
        let isPostsMode_Lumia = displayMode_Lumia == .posts_Lumia
        let isEmpty_Lumia = isPostsMode_Lumia ? filteredPosts_Lumia.isEmpty : filteredCapsules_Lumia.isEmpty

        emptyStateView_Lumia.isHidden = !isEmpty_Lumia
        collectionView_Lumia.isHidden = isEmpty_Lumia || !isPostsMode_Lumia
        capsuleListView_Lumia.isHidden = isEmpty_Lumia || isPostsMode_Lumia

        if !isEmpty_Lumia && isPostsMode_Lumia { triggerEntryAnimation_Lumia() }
    }

    /// 点击新建时光胶囊按钮：呼出创建表单，成功创建后插入到列表最前面
    @objc private func handleAddCapsule_Lumia() {
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else {
            Navigation_Lumia.toLogin_Lumia(style_lumia: .present_lumia)
            return
        }
        let sheet_Lumia = CreateCapsuleSheet_Lumia()
        sheet_Lumia.onCreated_Lumia = { message_Lumia, imagePath_Lumia, unlockDate_Lumia in
            // 创建后会触发 capsuleStateDidChangeNotification_Lumia，由 handleCapsuleChange_Lumia 统一刷新列表
            DiscoverCapsuleViewModel_Lumia.shared_Lumia.createCapsule_Lumia(
                message_Lumia: message_Lumia, imagePath_Lumia: imagePath_Lumia, unlockDateString_Lumia: unlockDate_Lumia
            )
            Utils_Lumia.showSuccess_Lumia(message_Lumia: "Capsule sealed! It will unlock on \(unlockDate_Lumia).")
        }
        sheet_Lumia.modalPresentationStyle = .fullScreen
        sheet_Lumia.modalTransitionStyle = .crossDissolve
        present(sheet_Lumia, animated: true)
    }

    /// 点击时光胶囊：已解锁则揭晓并展示留言，未解锁则提示解锁时间
    private func handleCapsuleTap_Lumia(capsule: TimeCapsule_Lumia) {
        if capsule.canReveal_Lumia {
            DiscoverCapsuleViewModel_Lumia.shared_Lumia.revealCapsule_Lumia(capsuleId_Lumia: capsule.capsuleId_Lumia)
            let alert_Lumia = UIAlertController(
                title: "Capsule Revealed ✦",
                message: capsule.message_Lumia,
                preferredStyle: .alert
            )
            alert_Lumia.addAction(UIAlertAction(title: "Close", style: .cancel))
            present(alert_Lumia, animated: true)
        } else {
            Utils_Lumia.showInfo_Lumia(message_Lumia: "Unlocks on \(capsule.unlockDateString_Lumia) 📅")
        }
    }

    /// 卡片入场弹簧缩放动画
    private func triggerEntryAnimation_Lumia() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            for (idx_Lumia, cell_Lumia) in self.collectionView_Lumia.visibleCells.enumerated() {
                cell_Lumia.alpha = 0
                cell_Lumia.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
                UIView.animate(
                    withDuration: 0.55,
                    delay: Double(idx_Lumia) * 0.065,
                    usingSpringWithDamping: 0.78,
                    initialSpringVelocity: 0.4,
                    options: .curveEaseOut
                ) {
                    cell_Lumia.alpha = 1
                    cell_Lumia.transform = .identity
                }
            }
        }
    }

    // MARK: - 通知

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleChange_Lumia),
            name: TitleViewModel_Lumia.titleStateDidChangeNotification_Lumia, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUserChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia, object: nil
        )
        // 胶囊揭晓/删除/举报 → 刷新 Capsules 列表
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleCapsuleChange_Lumia),
            name: DiscoverCapsuleViewModel_Lumia.capsuleStateDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleTitleChange_Lumia() { reloadData_Lumia() }
    @objc private func handleUserChange_Lumia() { reloadData_Lumia() }
    @objc private func handleCapsuleChange_Lumia() { reloadData_Lumia() }
    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 教学视频

    /// 打开教学视频全屏播放页
    /// - Parameter named_Lumia: Bundle 中的视频资源名（不含扩展名）
    private func openTutorialVideo_Lumia(named named_Lumia: String) {
        let player_Lumia = MediaPlayerPage_Lumia()
        player_Lumia.mediaPath_Lumia = named_Lumia
        player_Lumia.isVideo_Lumia = true
        player_Lumia.modalPresentationStyle = .fullScreen
        player_Lumia.modalTransitionStyle = .crossDissolve
        Navigation_Lumia.present_Lumia(viewController: player_Lumia)
    }
}

// MARK: 发现页时光胶囊 ViewModel

/// 发现页时光胶囊业务逻辑层
/// 核心作用：管理发现页「Capsules」标签下展示的预制时光胶囊数据，处理揭晓与删除/举报后的移除
/// 设计思路：
///   - 首次调用 getCapsules_Lumia 时从 LocalData_Lumia 预制数据惰性初始化，避免重复生成
///   - 揭晓、删除/举报均触发状态变更通知，驱动 Discover_Lumia 局部刷新
/// 关键属性：
///   - capsules_Lumia: 当前展示的胶囊缓存
@MainActor
class DiscoverCapsuleViewModel_Lumia {

    static let shared_Lumia = DiscoverCapsuleViewModel_Lumia()

    /// 胶囊状态变更通知（揭晓/删除/举报后触发）
    static let capsuleStateDidChangeNotification_Lumia = Notification.Name("DiscoverCapsuleStateDidChange_Lumia")

    private var capsules_Lumia: [TimeCapsule_Lumia] = []

    private init() {}

    /// 获取展示用的胶囊列表（首次调用时惰性加载预制数据）
    /// - Returns: 当前全部胶囊（按解锁日期倒序，越新征集的越靠前）
    func getCapsules_Lumia() -> [TimeCapsule_Lumia] {
        if capsules_Lumia.isEmpty {
            capsules_Lumia = LocalData_Lumia.shared_Lumia.capsuleList_Lumia
        }
        return capsules_Lumia
    }

    /// 揭晓指定胶囊（仅解锁时间已到时才应被调用）
    /// - Parameter capsuleId_Lumia: 待揭晓的胶囊ID
    func revealCapsule_Lumia(capsuleId_Lumia: Int) {
        guard let idx_Lumia = capsules_Lumia.firstIndex(where: { $0.capsuleId_Lumia == capsuleId_Lumia }) else { return }
        capsules_Lumia[idx_Lumia].isRevealed_Lumia = true
        notifyStateChange_Lumia()
    }

    /// 删除/举报后从展示列表中移除指定胶囊
    /// - Parameter capsuleId_Lumia: 待移除的胶囊ID
    func removeCapsule_Lumia(capsuleId_Lumia: Int) {
        capsules_Lumia.removeAll { $0.capsuleId_Lumia == capsuleId_Lumia }
        notifyStateChange_Lumia()
    }

    /// 由当前登录用户创建一个新的时光胶囊，插入到列表最前面并触发刷新
    /// - Parameters:
    ///   - message_Lumia: 留言内容
    ///   - imagePath_Lumia: 附加照片本地路径（可为空）
    ///   - unlockDateString_Lumia: 解锁日期（格式 "yyyy-MM-dd"）
    /// - Returns: 新创建的胶囊模型
    @discardableResult
    func createCapsule_Lumia(message_Lumia: String, imagePath_Lumia: String?, unlockDateString_Lumia: String) -> TimeCapsule_Lumia {
        if capsules_Lumia.isEmpty { capsules_Lumia = LocalData_Lumia.shared_Lumia.capsuleList_Lumia }
        let currentUser_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()
        let capsule_Lumia = TimeCapsule_Lumia(
            capsuleId_Lumia: nextCapsuleId_Lumia(),
            authorUserId_Lumia: currentUser_Lumia.userId_Lumia ?? 0,
            authorUserName_Lumia: currentUser_Lumia.userName_Lumia ?? "Me",
            imagePath_Lumia: imagePath_Lumia,
            message_Lumia: message_Lumia,
            unlockDateString_Lumia: unlockDateString_Lumia
        )
        capsules_Lumia.insert(capsule_Lumia, at: 0)
        notifyStateChange_Lumia()
        return capsule_Lumia
    }

    /// 生成下一个可用的胶囊ID（当前最大ID + 1）
    private func nextCapsuleId_Lumia() -> Int {
        let maxId_Lumia = capsules_Lumia.map { $0.capsuleId_Lumia }.max() ?? 0
        return maxId_Lumia + 1
    }

    /// 发送胶囊状态变更通知
    private func notifyStateChange_Lumia() {
        NotificationCenter.default.post(name: Self.capsuleStateDidChangeNotification_Lumia, object: nil)
    }
}

// MARK: - 创建时光胶囊 Sheet

/// 创建时光胶囊的全屏表单
/// 核心作用：填写留言、选择解锁日期、可选附加一张照片，完成后通过 onCreated_Lumia 回调交由
///          DiscoverCapsuleViewModel_Lumia 落地创建，本页面只负责表单交互，不直接操作数据层
class CreateCapsuleSheet_Lumia: UIViewController {

    /// 创建完成回调：留言内容、附加照片本地路径（可空）、解锁日期字符串（"yyyy-MM-dd"）
    var onCreated_Lumia: ((String, String?, String) -> Void)?

    private var selectedImagePath_Lumia: String?

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
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#6A40C0")
        btn_Lumia.layer.cornerRadius = 26
        return btn_Lumia
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lumia: "#1A1030")
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

// MARK: - UICollectionViewDelegate & DataSource

extension Discover_Lumia: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPosts_Lumia.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_Lumia = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverPostCell_Lumia.reuseId_Lumia,
            for: indexPath
        ) as! DiscoverPostCell_Lumia
        let post_Lumia = filteredPosts_Lumia[indexPath.item]
        cell_Lumia.configure_Lumia(post: post_Lumia, from: self)
        cell_Lumia.onUserTapped_Lumia = { userId_Lumia in
            let user_Lumia = UserViewModel_Lumia.shared_Lumia.getUserById_Lumia(userId_lumia: userId_Lumia)
            Navigation_Lumia.toUserInfo_Lumia(with: user_Lumia)
        }
        return cell_Lumia
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Lumia.toTitleDetail_Lumia(titleModel_lumia: filteredPosts_Lumia[indexPath.item])
    }

    /// 提供随帖子列表一起滚动的教学视频推荐头部
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header_Lumia = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: DiscoverTutorialVideosView_Lumia.reuseId_Lumia,
            for: indexPath
        ) as! DiscoverTutorialVideosView_Lumia
        header_Lumia.onVideoTapped_Lumia = { [weak self] videoName_Lumia in
            self?.openTutorialVideo_Lumia(named: videoName_Lumia)
        }
        return header_Lumia
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Lumia: WaterfallLayoutDelegate_Lumia {

    func collectionView_Lumia(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat {
        let post_Lumia = filteredPosts_Lumia[indexPath.item]
        let mediaHeight_Lumia: CGFloat = indexPath.item % 3 == 0 ? 185 : (indexPath.item % 3 == 1 ? 145 : 165)
        let extraHeight_Lumia: CGFloat = post_Lumia.titleContent_Lumia.count > 80 ? 18 : 0
        return mediaHeight_Lumia + 112 + extraHeight_Lumia
    }

    /// 教学视频推荐头部高度：搜索/胶囊模式下无帖子列表时仍需展示，因此固定返回，不随过滤结果变化
    func collectionView_Lumia(
        _ collectionView: UICollectionView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return DiscoverTutorialVideosView_Lumia.headerHeight_Lumia
    }
}

// MARK: - 发现页顶部栏

/// 发现页顶部栏
/// 核心作用：展示品牌标题、副标题、EXIF 风格统计数据及搜索入口
/// 设计思路：
///   - 参考发布页风格：饱和渐变色背景 + 底部圆角，简洁无边框
///   - 紫色 → 蓝色主渐变（与首页橙色形成冷暖互补）
///   - 全白文字，搜索框半透明白色（与发布页关闭按钮同样处理）
///   - 搜索框底部 + 下边距约束到视图底部，驱动自适应高度
private class DiscoverTopBar_Lumia: UIView {

    var onSearchChanged_Lumia: ((String) -> Void)?

    /// 背景渐变图层
    private var bgGradient_Lumia: CAGradientLayer?

    // 相机光圈图标（白色）
    private let apertureIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "camera.aperture")
        iv_Lumia.tintColor = .white
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    // 主标题 DISCOVER
    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Discover"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 26) ?? UIFont.boldSystemFont(ofSize: 26)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    // 副标题（白色，低透明度）
    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Explore extraordinary shots on film"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.75)
        lbl_Lumia.adjustsFontSizeToFitWidth = true
        lbl_Lumia.minimumScaleFactor = 0.8
        return lbl_Lumia
    }()

    // EXIF 风格统计标签（等宽字体，白色低透明度）
    private let exifLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.monospacedSystemFont(ofSize: 10.5, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.70)
        return lbl_Lumia
    }()

    // 搜索框容器（半透明白色，与发布页关闭按钮同款处理）
    private let searchContainer_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_Lumia.layer.cornerRadius = 22
        v_Lumia.layer.borderWidth = 1
        v_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return v_Lumia
    }()

    private let searchIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "magnifyingglass")
        iv_Lumia.tintColor = UIColor.white.withAlphaComponent(0.80)
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let searchField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.font = UIFont.systemFont(ofSize: 14)
        tf_Lumia.backgroundColor = .clear
        tf_Lumia.textColor = .white
        tf_Lumia.returnKeyType = .search
        tf_Lumia.tintColor = .white
        tf_Lumia.attributedPlaceholder = NSAttributedString(
            string: "Search posts, creators...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.52)]
        )
        return tf_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgGradient_Lumia?.frame = bounds
    }

    /// 更新 EXIF 风格统计数据
    /// - Parameters:
    ///   - postCount_Lumia: 帖子数量
    ///   - creatorCount_Lumia: 创作者数量
    func updateStats_Lumia(postCount_Lumia: Int, creatorCount_Lumia: Int) {
        exifLabel_Lumia.text = "◉ \(postCount_Lumia) SHOTS  ·  \(creatorCount_Lumia) CREATORS  ·  35mm"
    }

    private func setupUI_Lumia() {
        // 与发布页完全一致的橙→珊瑚红渐变
        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F6A623").cgColor,
            UIColor(hexstring_Lumia: "#D4654E").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient_Lumia, at: 0)
        bgGradient_Lumia = gradient_Lumia

        // 底部两侧大圆角，与发布页（cornerRadius 24）及首页风格统一
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 24
        clipsToBounds = true

        // ── 图标 + 标题（同行）──
        addSubview(apertureIcon_Lumia)
        apertureIcon_Lumia.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(apertureIcon_Lumia)
            make.leading.equalTo(apertureIcon_Lumia.snp.trailing).offset(10)
        }

        // ── 副标题 ──
        addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(apertureIcon_Lumia.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // ── EXIF 风格统计 ──
        addSubview(exifLabel_Lumia)
        exifLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Lumia.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        updateStats_Lumia(postCount_Lumia: 248, creatorCount_Lumia: 32)

        // ── 搜索框（底部约束到 view 底部，驱动 topBar 自适应高度）──
        addSubview(searchContainer_Lumia)
        searchContainer_Lumia.snp.makeConstraints { make in
            make.top.equalTo(exifLabel_Lumia.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-18)
        }
        searchContainer_Lumia.addSubview(searchIcon_Lumia)
        searchIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        searchContainer_Lumia.addSubview(searchField_Lumia)
        searchField_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Lumia.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        searchField_Lumia.addTarget(self, action: #selector(searchChanged_Lumia), for: .editingChanged)
    }

    @objc private func searchChanged_Lumia() {
        onSearchChanged_Lumia?(searchField_Lumia.text ?? "")
    }
}

// MARK: - 空结果缺省视图

/// 搜索或分类过滤无结果时居中展示的缺省视图
/// 核心作用：给用户明确的无数据反馈，通过相机图标 + 文案引导
private class DiscoverEmptyView_Lumia: UIView {

    private let iconView_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "camera.filters")
        iv_Lumia.tintColor = UIColor(hexstring_Lumia: "#B794F6", alpha_Lumia: 0.55)
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "No Results Found"
        lbl_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#4A3580")
        lbl_Lumia.textAlignment = .center
        return lbl_Lumia
    }()

    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Try a different search keyword"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#8C7CB8")
        lbl_Lumia.textAlignment = .center
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Lumia() {
        addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(iconView_Lumia.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - 分类标签横条

/// 发现页切换栏
/// 核心作用：横向滚动标签，选中态渐变填充，未选中态淡紫透明，点击触发展示模式切换（Posts / Capsules）
private class DiscoverCategoryBar_Lumia: UIView {

    var onCategorySelected_Lumia: ((Int) -> Void)?

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsHorizontalScrollIndicator = false
        sv_Lumia.alwaysBounceHorizontal = true
        return sv_Lumia
    }()

    private let stackView_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .horizontal
        sv_Lumia.spacing = 10
        sv_Lumia.alignment = .center
        return sv_Lumia
    }()

    private var categoryButtons_Lumia: [UIButton] = []

    /// 与「Posts / Capsules」两个标签对应的图标
    private let categoryIcons_Lumia = [
        "square.grid.2x2.fill",
        "hourglass"
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")

        let line_Lumia = UIView()
        line_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#C4B8E8")
        addSubview(line_Lumia)
        line_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(line_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        scrollView_Lumia.addSubview(stackView_Lumia)
        stackView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalToSuperview()
        }
    }

    func configure_Lumia(categories_Lumia: [String]) {
        stackView_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }
        categoryButtons_Lumia.removeAll()

        for (idx_Lumia, title_Lumia) in categories_Lumia.enumerated() {
            let iconName_Lumia = idx_Lumia < categoryIcons_Lumia.count ? categoryIcons_Lumia[idx_Lumia] : "tag"
            let btn_Lumia = makeCategoryButton_Lumia(
                title_Lumia: title_Lumia, iconName_Lumia: iconName_Lumia, index_Lumia: idx_Lumia
            )
            stackView_Lumia.addArrangedSubview(btn_Lumia)
            categoryButtons_Lumia.append(btn_Lumia)
        }
        updateSelection_Lumia(index: 0)
    }

    private func makeCategoryButton_Lumia(title_Lumia: String, iconName_Lumia: String, index_Lumia: Int) -> UIButton {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let icon_Lumia = UIImage(systemName: iconName_Lumia, withConfiguration: cfg_Lumia)

        var config_Lumia = UIButton.Configuration.plain()
        config_Lumia.title = title_Lumia
        config_Lumia.image = icon_Lumia
        config_Lumia.imagePadding = 5
        config_Lumia.imagePlacement = .leading
        config_Lumia.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return outgoing
        }
        config_Lumia.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
        btn_Lumia.configuration = config_Lumia
        btn_Lumia.layer.cornerRadius = 16
        btn_Lumia.tag = index_Lumia
        btn_Lumia.addTarget(self, action: #selector(categoryTapped_Lumia(_:)), for: .touchUpInside)
        return btn_Lumia
    }

    private func updateSelection_Lumia(index: Int) {
        for (idx_Lumia, btn_Lumia) in categoryButtons_Lumia.enumerated() {
            btn_Lumia.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            if idx_Lumia == index {
                btn_Lumia.tintColor = .white
                btn_Lumia.configuration?.baseForegroundColor = .white
                btn_Lumia.backgroundColor = .clear
                let gradient_Lumia = CAGradientLayer()
                gradient_Lumia.colors = [
                    UIColor(hexstring_Lumia: "#6A40C0").cgColor,
                    UIColor(hexstring_Lumia: "#3A7ED8").cgColor
                ]
                gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
                gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
                gradient_Lumia.cornerRadius = 16
                btn_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
                DispatchQueue.main.async { gradient_Lumia.frame = btn_Lumia.bounds }
            } else {
                btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#6A40C0")
                btn_Lumia.configuration?.baseForegroundColor = UIColor(hexstring_Lumia: "#6A40C0")
                btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#6A40C0", alpha_Lumia: 0.10)
            }
        }
    }

    @objc private func categoryTapped_Lumia(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        updateSelection_Lumia(index: sender.tag)
        onCategorySelected_Lumia?(sender.tag)
    }
}

// MARK: - 发现页时光胶囊列表

/// 发现页时光胶囊列表视图
/// 核心作用：以卡片列表形式展示预制时光胶囊数据，未到解锁时间的胶囊显示锁定态；
///          每张卡片右上角提供删除/举报入口（复用 ReportDeleteHelper_Lumia）
/// 设计：深蓝夜色卡片（#1A2A3A）+ 金色解锁态强调色，延续首页原时光胶囊视觉语言
private class DiscoverCapsuleListView_Lumia: UIView {

    /// 点击胶囊卡片回调（用于揭晓留言或提示解锁时间）
    var onCapsuleTapped_Lumia: ((TimeCapsule_Lumia) -> Void)?

    private var capsules_Lumia: [TimeCapsule_Lumia] = []

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        sv_Lumia.alwaysBounceVertical = true
        return sv_Lumia
    }()

    private let stack_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .vertical
        sv_Lumia.spacing = 12
        sv_Lumia.alignment = .fill
        return sv_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")

        addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        scrollView_Lumia.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 100, right: 0)

        scrollView_Lumia.addSubview(stack_Lumia)
        stack_Lumia.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self).inset(16)
        }
    }

    /// 配置展示的胶囊列表
    /// - Parameters:
    ///   - capsules: 待展示的胶囊数据（已按搜索关键词过滤）
    ///   - viewController_Lumia: 承载举报/删除弹窗的视图控制器
    func configure_Lumia(capsules: [TimeCapsule_Lumia], from viewController_Lumia: UIViewController) {
        self.capsules_Lumia = capsules
        stack_Lumia.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for capsule_Lumia in capsules {
            stack_Lumia.addArrangedSubview(buildCard_Lumia(capsule: capsule_Lumia, from: viewController_Lumia))
        }
    }

    /// 构建单张胶囊卡片
    private func buildCard_Lumia(capsule: TimeCapsule_Lumia, from viewController_Lumia: UIViewController) -> UIView {
        let card_Lumia = UIView()
        card_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#1A2A3A")
        card_Lumia.layer.cornerRadius = 16

        // 左侧状态竖条（金色=可解锁，蓝灰=锁定）
        let leftBar_Lumia = UIView()
        leftBar_Lumia.backgroundColor = capsule.canReveal_Lumia
            ? UIColor(hexstring_Lumia: "#F6D860")
            : UIColor(hexstring_Lumia: "#2A8AAA")
        leftBar_Lumia.layer.cornerRadius = 16
        leftBar_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        card_Lumia.addSubview(leftBar_Lumia)
        leftBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }

        // 删除/举报按钮（右上角，复用 ReportDeleteHelper_Lumia）
        let actionButton_Lumia = ReportDeleteHelper_Lumia.createCapsuleReportButton_Lumia(
            capsule_Lumia: capsule,
            size_Lumia: 12,
            color_Lumia: UIColor.white.withAlphaComponent(0.55),
            from: viewController_Lumia
        )
        card_Lumia.addSubview(actionButton_Lumia)
        actionButton_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }

        // 作者头像 + 用户名
        let avatarView_Lumia = UserAvatarView_Lumia()
        avatarView_Lumia.configure_Lumia(userId_Lumia: capsule.authorUserId_Lumia)
        avatarView_Lumia.layer.cornerRadius = 12
        avatarView_Lumia.clipsToBounds = true
        card_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }

        let nameLabel_Lumia = UILabel()
        nameLabel_Lumia.text = capsule.authorUserName_Lumia
        nameLabel_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        nameLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.85)
        card_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Lumia)
            make.leading.equalTo(avatarView_Lumia.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(actionButton_Lumia.snp.leading).offset(-8)
        }

        // 锁状态图标 + 解锁日期文案
        let lockIcon_Lumia = UIImageView(
            image: UIImage(systemName: capsule.canReveal_Lumia ? "lock.open.fill" : "lock.fill")
        )
        lockIcon_Lumia.tintColor = capsule.canReveal_Lumia
            ? UIColor(hexstring_Lumia: "#F6D860")
            : UIColor.white.withAlphaComponent(0.55)
        lockIcon_Lumia.contentMode = .scaleAspectFit
        card_Lumia.addSubview(lockIcon_Lumia)
        lockIcon_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Lumia.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(16)
        }

        let dateLabel_Lumia = UILabel()
        dateLabel_Lumia.text = capsule.isRevealed_Lumia
            ? "Revealed · \(capsule.createdAt_Lumia)"
            : "Unlocks \(capsule.unlockDateString_Lumia)"
        dateLabel_Lumia.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        dateLabel_Lumia.textColor = capsule.canReveal_Lumia
            ? UIColor(hexstring_Lumia: "#F6D860")
            : UIColor.white.withAlphaComponent(0.50)
        card_Lumia.addSubview(dateLabel_Lumia)
        dateLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(lockIcon_Lumia)
            make.leading.equalTo(lockIcon_Lumia.snp.trailing).offset(8)
        }

        // 留言正文（未揭晓时显示引导文案）
        let msgLabel_Lumia = UILabel()
        msgLabel_Lumia.text = capsule.isRevealed_Lumia
            ? capsule.message_Lumia
            : "Tap to reveal when unlocked"
        msgLabel_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        msgLabel_Lumia.textColor = UIColor.white.withAlphaComponent(0.82)
        msgLabel_Lumia.numberOfLines = 3
        card_Lumia.addSubview(msgLabel_Lumia)
        msgLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(lockIcon_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // 附图（已揭晓且带图片时展示）
        if capsule.isRevealed_Lumia, let imagePath_Lumia = capsule.imagePath_Lumia {
            let mediaView_Lumia = MediaDisplayView_Lumia()
            mediaView_Lumia.configure_Lumia(mediaPath_Lumia: imagePath_Lumia)
            mediaView_Lumia.layer.cornerRadius = 10
            mediaView_Lumia.clipsToBounds = true
            card_Lumia.addSubview(mediaView_Lumia)
            mediaView_Lumia.snp.makeConstraints { make in
                make.top.equalTo(msgLabel_Lumia.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(130)
                make.bottom.equalToSuperview().offset(-14)
            }
        } else {
            msgLabel_Lumia.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-14)
            }
        }

        let tap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Lumia(_:)))
        tap_Lumia.delegate = self
        card_Lumia.addGestureRecognizer(tap_Lumia)
        card_Lumia.isUserInteractionEnabled = true
        card_Lumia.tag = capsule.capsuleId_Lumia

        return card_Lumia
    }

    /// 卡片点击：根据 tag 找到对应胶囊并回调
    @objc private func handleCardTap_Lumia(_ gesture_Lumia: UITapGestureRecognizer) {
        guard let capsuleId_Lumia = gesture_Lumia.view?.tag,
              let capsule_Lumia = capsules_Lumia.first(where: { $0.capsuleId_Lumia == capsuleId_Lumia }) else { return }
        onCapsuleTapped_Lumia?(capsule_Lumia)
    }
}

// MARK: - UIGestureRecognizerDelegate（避免点击右上角举报/删除按钮时同时触发卡片点击）

extension DiscoverCapsuleListView_Lumia: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
}

// MARK: - 每日教学视频推荐

/// 每日教学视频推荐视图
/// 核心作用：在分类切换栏下方，横向平分展示 3 支胶片摄影教学短片封面，点击进入全屏播放页；
///          作为瀑布流的 section 头部随帖子列表一起滚动，而非悬浮固定
/// 设计思路：
///   - 标题 + 描述文案说明区块用途，与发现页紫蓝色主题保持一致
///   - 3 个 MediaDisplayView_Lumia 等宽排列，间隔 10，高度 100，圆角 10
///   - 关键属性：videoNames_Lumia 对应 Bundle 中的 lumia1/lumia2/lumia3 视频资源名
private class DiscoverTutorialVideosView_Lumia: UICollectionReusableView {

    /// 复用标识（作为 UICollectionView section 头部注册使用）
    static let reuseId_Lumia = "DiscoverTutorialVideosView_Lumia"

    /// 固定总高度（供瀑布流布局计算 header 尺寸，略大于内部约束布局总高以预留安全余量）
    static let headerHeight_Lumia: CGFloat = 178

    /// 点击某个教学视频回调，参数为对应的 Bundle 视频资源名（不含扩展名）
    var onVideoTapped_Lumia: ((String) -> Void)?

    /// 教学视频资源名（对应 Bundle 中的 lumia1.mp4 / lumia2.mp4 / lumia3.mp4）
    private let videoNames_Lumia = ["lumia1", "lumia2", "lumia3"]

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "🎬  Daily Tutorial Videos"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#4A3580")
        return lbl_Lumia
    }()

    private let subtitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Quick daily picks to sharpen your film photography skills"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11.5, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#8C7CB8")
        return lbl_Lumia
    }()

    private let videosRow_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .horizontal
        sv_Lumia.spacing = 10
        sv_Lumia.distribution = .fillEqually
        sv_Lumia.alignment = .fill
        return sv_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")

        addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        addSubview(subtitleLabel_Lumia)
        subtitleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(3)
            make.leading.trailing.equalTo(titleLabel_Lumia)
        }

        addSubview(videosRow_Lumia)
        videosRow_Lumia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Lumia.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-14)
        }

        for (index_Lumia, name_Lumia) in videoNames_Lumia.enumerated() {
            let mediaView_Lumia = MediaDisplayView_Lumia()
            mediaView_Lumia.layer.cornerRadius = 10
            mediaView_Lumia.clipsToBounds = true
            mediaView_Lumia.configure_Lumia(mediaPath_Lumia: name_Lumia, isVideo_Lumia: true)
            mediaView_Lumia.tag = index_Lumia
            mediaView_Lumia.isUserInteractionEnabled = true
            let tap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Lumia(_:)))
            mediaView_Lumia.addGestureRecognizer(tap_Lumia)
            videosRow_Lumia.addArrangedSubview(mediaView_Lumia)
        }
    }

    /// 视频封面点击：根据 tag 找到对应资源名并回调
    @objc private func handleVideoTap_Lumia(_ gesture_Lumia: UITapGestureRecognizer) {
        guard let mediaView_Lumia = gesture_Lumia.view as? MediaDisplayView_Lumia,
              mediaView_Lumia.tag < videoNames_Lumia.count else { return }
        onVideoTapped_Lumia?(videoNames_Lumia[mediaView_Lumia.tag])
    }
}

// MARK: - 发现页帖子 Cell

/// 发现页帖子卡片 Cell
/// 核心作用：精美卡片展示帖子，含顶部渐变色条、媒体区、悬浮头像、互动行
class DiscoverPostCell_Lumia: UICollectionViewCell {

    static let reuseId_Lumia = "DiscoverPostCell_Lumia"
    var onUserTapped_Lumia: ((Int) -> Void)?

    private var currentPost_Lumia: TitleModel_Lumia?
    private weak var fromVC_Lumia: UIViewController?

    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#3A1A78").cgColor
        v_Lumia.layer.shadowOpacity = 0.13
        v_Lumia.layer.shadowRadius = 16
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_Lumia.clipsToBounds = false
        return v_Lumia
    }()

    // 顶部渐变色条（3pt）
    private let topAccentView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Lumia.layer.cornerRadius = 20
        return v_Lumia
    }()
    private var topAccentGradient_Lumia: CAGradientLayer?

    private let mediaView_Lumia: MediaDisplayView_Lumia = {
        let mv_Lumia = MediaDisplayView_Lumia()
        mv_Lumia.layer.cornerRadius = 20
        mv_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mv_Lumia.clipsToBounds = true
        return mv_Lumia
    }()

    // 媒体区底部渐变遮罩
    private let mediaInnerFade_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }()
    private var innerFadeGradient_Lumia: CAGradientLayer?

    // 头像边框环（悬浮叠加）
    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 17
        v_Lumia.layer.borderWidth = 2.5
        v_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#6A40C0").cgColor
        v_Lumia.backgroundColor = .white
        return v_Lumia
    }()

    private let avatarView_Lumia = UserAvatarView_Lumia()

    private let userNameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10.5, weight: .semibold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#5A3FA0")
        return lbl_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-DemiBold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let contentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        lbl_Lumia.numberOfLines = 2
        return lbl_Lumia
    }()

    private let actionRow_Lumia = UIView()

    private let heartIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "heart.fill")
        iv_Lumia.tintColor = ColorConfig_Lumia.secondaryGradientStart_Lumia
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let likeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        return lbl_Lumia
    }()

    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = ColorConfig_Lumia.textSecondary_Lumia
        return btn_Lumia
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topAccentGradient_Lumia?.frame = topAccentView_Lumia.bounds
        innerFadeGradient_Lumia?.frame = mediaInnerFade_Lumia.bounds
    }

    private func setupUI_Lumia() {
        backgroundColor = .clear
        contentView.addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 顶部渐变色条
        cardView_Lumia.addSubview(topAccentView_Lumia)
        topAccentView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
        let accentGrad_Lumia = CAGradientLayer()
        accentGrad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#6A40C0").cgColor,
            UIColor(hexstring_Lumia: "#3A7ED8").cgColor
        ]
        accentGrad_Lumia.startPoint = CGPoint(x: 0, y: 0.5)
        accentGrad_Lumia.endPoint = CGPoint(x: 1, y: 0.5)
        accentGrad_Lumia.cornerRadius = 20
        topAccentView_Lumia.layer.insertSublayer(accentGrad_Lumia, at: 0)
        topAccentGradient_Lumia = accentGrad_Lumia

        // 媒体视图
        cardView_Lumia.addSubview(mediaView_Lumia)
        mediaView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.56)
        }

        // 媒体区底部渐变遮罩
        mediaView_Lumia.addSubview(mediaInnerFade_Lumia)
        mediaInnerFade_Lumia.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        let fadeGrad_Lumia = CAGradientLayer()
        fadeGrad_Lumia.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.55).cgColor
        ]
        fadeGrad_Lumia.startPoint = CGPoint(x: 0.5, y: 0)
        fadeGrad_Lumia.endPoint = CGPoint(x: 0.5, y: 1)
        mediaInnerFade_Lumia.layer.insertSublayer(fadeGrad_Lumia, at: 0)
        innerFadeGradient_Lumia = fadeGrad_Lumia

        // 头像环（悬浮叠加媒体底部）
        cardView_Lumia.addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Lumia.snp.bottom).offset(-12)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(34)
        }
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(2.5) }
        avatarView_Lumia.layer.cornerRadius = 13
        avatarView_Lumia.clipsToBounds = true

        let avatarTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Lumia))
        avatarRing_Lumia.addGestureRecognizer(avatarTap_Lumia)
        avatarRing_Lumia.isUserInteractionEnabled = true

        cardView_Lumia.addSubview(userNameLabel_Lumia)
        userNameLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRing_Lumia).offset(6)
            make.leading.equalTo(avatarRing_Lumia.snp.trailing).offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        cardView_Lumia.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Lumia.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        cardView_Lumia.addSubview(contentLabel_Lumia)
        contentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel_Lumia)
        }

        cardView_Lumia.addSubview(actionRow_Lumia)
        actionRow_Lumia.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(26)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        actionRow_Lumia.addSubview(heartIcon_Lumia)
        heartIcon_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        actionRow_Lumia.addSubview(likeLabel_Lumia)
        likeLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(heartIcon_Lumia.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        actionRow_Lumia.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)
    }

    func configure_Lumia(post: TitleModel_Lumia, from vc: UIViewController) {
        currentPost_Lumia = post
        fromVC_Lumia = vc
        avatarView_Lumia.configure_Lumia(userId_Lumia: post.titleUserId_Lumia)
        userNameLabel_Lumia.text = post.titleUserName_Lumia
        mediaView_Lumia.configure_Lumia(mediaPath_Lumia: post.titleMeidas_Lumia.first)
        titleLabel_Lumia.text = post.title_Lumia
        contentLabel_Lumia.text = post.titleContent_Lumia
        likeLabel_Lumia.text = "\(post.likes_Lumia)"
    }

    @objc private func handleReport_Lumia() {
        guard let post_Lumia = currentPost_Lumia, let vc_Lumia = fromVC_Lumia else { return }
        let isMyPost_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(userId_lumia: post_Lumia.titleUserId_Lumia)
        if isMyPost_Lumia {
            ReportDeleteHelper_Lumia.delete_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        } else {
            ReportDeleteHelper_Lumia.report_Lumia(post_Lumia: post_Lumia, from: vc_Lumia)
        }
    }

    @objc private func handleAvatarTap_Lumia() {
        guard let post_Lumia = currentPost_Lumia else { return }
        onUserTapped_Lumia?(post_Lumia.titleUserId_Lumia)
    }
}

// MARK: - 瀑布流布局

/// 瀑布流布局代理协议
protocol WaterfallLayoutDelegate_Lumia: AnyObject {
    func collectionView_Lumia(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat

    /// 返回 section 头部高度（用于放置随列表一起滚动的教学视频推荐区），无需展示头部时返回 0
    func collectionView_Lumia(
        _ collectionView: UICollectionView,
        heightForHeaderInSection section: Int
    ) -> CGFloat
}

/// 不等高双列瀑布流布局
/// 支持在内容顶部插入一个横跨整行、随列表一起滚动的 section 头部（用于教学视频推荐区）
class WaterfallLayout_Lumia: UICollectionViewLayout {

    weak var delegate_Lumia: WaterfallLayoutDelegate_Lumia?
    var numberOfColumns_Lumia: Int = 2
    var cellPadding_Lumia: CGFloat = 6

    private var cache_Lumia: [UICollectionViewLayoutAttributes] = []
    /// 头部布局属性（随列表滚动，不悬浮）
    private var headerAttributes_Lumia: UICollectionViewLayoutAttributes?
    private var contentHeight_Lumia: CGFloat = 0
    private var contentWidth_Lumia: CGFloat {
        guard let cv_Lumia = collectionView else { return 0 }
        let insets_Lumia = cv_Lumia.contentInset
        return cv_Lumia.bounds.width - insets_Lumia.left - insets_Lumia.right
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth_Lumia, height: contentHeight_Lumia)
    }

    override func prepare() {
        guard cache_Lumia.isEmpty, headerAttributes_Lumia == nil, let cv_Lumia = collectionView else { return }

        // 头部（教学视频推荐区）：占据整行宽度，位于所有帖子卡片之前，随内容一起滚动
        let headerHeight_Lumia = delegate_Lumia?.collectionView_Lumia(cv_Lumia, heightForHeaderInSection: 0) ?? 0
        var topOffset_Lumia: CGFloat = 0
        if headerHeight_Lumia > 0 {
            let headerIndexPath_Lumia = IndexPath(item: 0, section: 0)
            let attrs_Lumia = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: headerIndexPath_Lumia
            )
            attrs_Lumia.frame = CGRect(x: 0, y: 0, width: contentWidth_Lumia, height: headerHeight_Lumia)
            headerAttributes_Lumia = attrs_Lumia
            topOffset_Lumia = headerHeight_Lumia
        }
        contentHeight_Lumia = topOffset_Lumia

        let columnWidth_Lumia = contentWidth_Lumia / CGFloat(numberOfColumns_Lumia)
        let xOffsets_Lumia = (0..<numberOfColumns_Lumia).map { CGFloat($0) * columnWidth_Lumia }
        var yOffsets_Lumia = [CGFloat](repeating: topOffset_Lumia, count: numberOfColumns_Lumia)
        var column_Lumia = 0

        for item_Lumia in 0..<cv_Lumia.numberOfItems(inSection: 0) {
            let indexPath_Lumia = IndexPath(item: item_Lumia, section: 0)
            let width_Lumia = columnWidth_Lumia - cellPadding_Lumia * 2
            let height_Lumia = delegate_Lumia?.collectionView_Lumia(
                cv_Lumia, heightForItemAt: indexPath_Lumia, withWidth: width_Lumia
            ) ?? 200
            let frame_Lumia = CGRect(
                x: xOffsets_Lumia[column_Lumia] + cellPadding_Lumia,
                y: yOffsets_Lumia[column_Lumia] + cellPadding_Lumia,
                width: width_Lumia,
                height: height_Lumia
            )
            let attrs_Lumia = UICollectionViewLayoutAttributes(forCellWith: indexPath_Lumia)
            attrs_Lumia.frame = frame_Lumia
            cache_Lumia.append(attrs_Lumia)

            contentHeight_Lumia = max(contentHeight_Lumia, frame_Lumia.maxY)
            yOffsets_Lumia[column_Lumia] += height_Lumia + cellPadding_Lumia * 2
            column_Lumia = yOffsets_Lumia[0] < yOffsets_Lumia[1] ? 0 : 1
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result_Lumia = cache_Lumia.filter { $0.frame.intersects(rect) }
        if let header_Lumia = headerAttributes_Lumia, header_Lumia.frame.intersects(rect) {
            result_Lumia.append(header_Lumia)
        }
        return result_Lumia
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache_Lumia[safe_Lumia: indexPath.item]
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        return headerAttributes_Lumia
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache_Lumia.removeAll()
        headerAttributes_Lumia = nil
        contentHeight_Lumia = 0
    }
}

// MARK: - Array 安全下标扩展

private extension Array {
    subscript(safe_Lumia index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
