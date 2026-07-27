import Foundation
import UIKit

// MARK: 用户ViewModel

/// 登出类型枚举
/// 功能：区分删除账号和普通登出
enum LogOutType_Orna {
    /// 删除账号
    case delete_orna
    /// 普通登出
    case logout_orna
}

/// 用户状态管理类
/// 功能：管理登录用户的状态、信息更新、关注、点赞和帖子操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class UserViewModel_Orna {

    /// 单例
    static let shared_Orna = UserViewModel_Orna()

    // MARK: - 通知名称

    /// 用户状态更新通知
    static let userStateDidChangeNotification_Orna = Notification.Name("UserStateDidChange_Orna")

    // MARK: - 私有属性

    /// 当前登录用户
    private var loggedUser_Orna: LoginUserModel_Orna?

    /// 已举报/拉黑的用户ID集合（用于全局隐藏其评论等内容）
    private var blockedUserIds_Orna: Set<Int> = []

    /// 默认用户（游客）
    private let defaultUser_Orna = LoginUserModel_Orna(
        userId_Orna: 0,
        userPwd_Orna: nil,
        userName_Orna: "Guest",
        userIntroduce_Orna: "Nothing yet.",
        userHead_Orna: "default_avatar",
        userPosts_Orna: [],
        userLike_Orna: [],
        userFollow_Orna: []
    )

    private init() {}

    // MARK: - 公共属性

    /// 是否已登录
    var isLoggedIn_Orna: Bool {
        loggedUser_Orna?.userId_Orna != 0
    }

    /// 获取当前用户（未登录时返回游客）
    func getCurrentUser_Orna() -> LoginUserModel_Orna {
        loggedUser_Orna ?? defaultUser_Orna
    }

    // MARK: - 初始化

    /// 初始化用户状态（重置为游客）
    func initUser_Orna() {
        loggedUser_Orna = defaultUser_Orna
        notifyStateChange_Orna()
    }

    // MARK: - 登录 / 登出

    /// 通过用户ID登录
    /// 参数：
    /// - userId_orna: 目标用户ID
    /// - userName_orna: 登录时填写的用户名，若本地预制用户已存在同 ID 记录则优先使用预制昵称，
    ///                  否则使用该参数作为新用户昵称
    func loginById_Orna(userId_orna: Int, userName_orna: String? = nil) {
        Load_Orna.showLoading_Orna(message_Orna: "Logging in...")

        let localUser_orna = LocalData_Orna.shared_Orna.userList_Orna.first {
            $0.userId_Orna == userId_orna
        }

        loggedUser_Orna = LoginUserModel_Orna(
            userId_Orna: userId_orna,
            userPwd_Orna: nil,
            userName_Orna: localUser_orna?.userName_Orna ?? userName_orna ?? "Wanderer",
            userIntroduce_Orna: localUser_orna?.userIntroduce_Orna ?? "Nothing yet.",
            userHead_Orna: localUser_orna?.userHead_Orna ?? "user_avatar",
            userPosts_Orna: [],
            userLike_Orna: [],
            userFollow_Orna: []
        )

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            Load_Orna.dismissLoading_Orna()
            Load_Orna.showSuccess_Orna(message_Orna: "Login successful!")
            Navigation_Orna.switchToTabbar_Orna(animated: true)
            notifyStateChange_Orna()
        }
    }

    /// 用户登出
    /// 参数：
    /// - logoutType_orna: 登出类型（普通登出 / 删除账号）
    func logout_Orna(logoutType_orna: LogOutType_Orna) {
        guard isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return
        }

        loggedUser_Orna = defaultUser_Orna
        MessageViewModel_Orna.shared_Orna.clearAiChat_Orna()
        LocalData_Orna.shared_Orna.initData_Orna()
        notifyStateChange_Orna()
        Navigation_Orna.switchToTabbar_Orna()

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if logoutType_orna == .delete_orna {
                Load_Orna.showInfo_Orna(
                    message_Orna: "The account will be deleted after 24 hours. If you log in within 24 hours, it will be considered a logout failure.",
                    delay_Orna: 3.0
                )
            } else {
                Load_Orna.showSuccess_Orna(message_Orna: "Logout successful")
            }
        }
    }

    // MARK: - 用户信息更新

    /// 更新用户头像
    /// 参数：
    /// - headUrl_orna: 新头像路径
    func updateHead_Orna(headUrl_orna: String) {
        guard loggedUser_Orna != nil else { return }
        loggedUser_Orna?.userHead_Orna = headUrl_orna
        Load_Orna.showSuccess_Orna(message_Orna: "Avatar updated successfully")
        notifyStateChange_Orna()
    }

    /// 更新用户昵称
    /// 参数：
    /// - userName_orna: 新昵称
    func updateName_Orna(userName_orna: String) {
        guard loggedUser_Orna != nil else { return }
        loggedUser_Orna?.userName_Orna = userName_orna
        Load_Orna.showSuccess_Orna(message_Orna: "Name updated successfully")
        notifyStateChange_Orna()
    }

    /// 更新用户自我介绍
    /// 参数：
    /// - userIntroduce_orna: 新自我介绍内容
    func updateIntroduce_Orna(userIntroduce_orna: String) {
        guard loggedUser_Orna != nil else { return }
        loggedUser_Orna?.userIntroduce_Orna = userIntroduce_orna
        Load_Orna.showSuccess_Orna(message_Orna: "Bio updated successfully")
        notifyStateChange_Orna()
    }

    /// 上传用户封面
    /// 参数：
    /// - coverUrl_orna: 封面图片路径
    func uploadCover_Orna(coverUrl_orna: String) {
        Load_Orna.showSuccess_Orna(message_Orna: "Cover updated successfully")
        notifyStateChange_Orna()
    }

    // MARK: - 打卡功能

    /// 今日日期字符串格式器（yyyy-MM-dd）
    private static let checkInDateFormatter_Orna: DateFormatter = {
        let formatter_orna = DateFormatter()
        formatter_orna.dateFormat = "yyyy-MM-dd"
        return formatter_orna
    }()

    /// 获取指定日期的日期字符串
    private func dateString_Orna(for date_orna: Date) -> String {
        Self.checkInDateFormatter_Orna.string(from: date_orna)
    }

    /// 检查今天是否已打卡
    /// 返回值：已打卡返回 true，否则 false
    func hasCheckedInToday_Orna() -> Bool {
        guard let lastDate_orna = loggedUser_Orna?.lastCheckInDate_Orna else { return false }
        return lastDate_orna == dateString_Orna(for: Date())
    }

    /// 获取当前连续签到天数
    func getCheckInStreak_Orna() -> Int {
        loggedUser_Orna?.checkInStreak_Orna ?? 0
    }

    /// 执行打卡
    /// 功能：未登录时提示登录；已打卡时提示；未打卡时更新连续签到天数，
    ///       随机抽取一件桌面摆件加入收藏并提示获得内容，形成"签到-收藏"闭环
    func checkIn_Orna() {
        guard isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return
        }
        guard !hasCheckedInToday_Orna() else {
            Load_Orna.showWarning_Orna(message_Orna: "You have already checked in today.")
            return
        }

        updateCheckInStreak_Orna()
        let rewardOrnament_orna = drawRandomOrnament_Orna()
        if let rewardOrnament_orna, loggedUser_Orna?.ownedOrnamentIds_Orna.contains(rewardOrnament_orna.ornamentId_Orna) == false {
            loggedUser_Orna?.ownedOrnamentIds_Orna.append(rewardOrnament_orna.ornamentId_Orna)
        }

        Load_Orna.showSuccess_Orna(
            message_Orna: rewardOrnament_orna != nil
                ? "Check-in successful! You got \(rewardOrnament_orna!.ornamentName_Orna)"
                : "Check-in successful!",
            image_Orna: UIImage(systemName: "checkmark.seal.fill")
        )
        notifyStateChange_Orna()
    }

    /// 更新连续签到天数：昨日已签到则连续天数+1，否则重置为1
    private func updateCheckInStreak_Orna() {
        guard let user_orna = loggedUser_Orna else { return }
        let today_orna = Date()
        let yesterday_orna = Calendar.current.date(byAdding: .day, value: -1, to: today_orna) ?? today_orna

        if user_orna.lastCheckInDate_Orna == dateString_Orna(for: yesterday_orna) {
            user_orna.checkInStreak_Orna += 1
        } else {
            user_orna.checkInStreak_Orna = 1
        }
        user_orna.lastCheckInDate_Orna = dateString_Orna(for: today_orna)
    }

    /// 按稀有度权重随机抽取一件摆件（优先从未拥有的摆件中抽取，全部拥有时随机返回任意摆件）
    /// 返回值：抽取到的摆件，图鉴为空时返回 nil
    private func drawRandomOrnament_Orna() -> OrnamentModel_Orna? {
        let catalog_orna = LocalData_Orna.shared_Orna.ornamentCatalog_Orna
        guard !catalog_orna.isEmpty else { return nil }

        let ownedIds_orna = Set(loggedUser_Orna?.ownedOrnamentIds_Orna ?? [])
        let candidatePool_orna = catalog_orna.filter { !ownedIds_orna.contains($0.ornamentId_Orna) }
        let pool_orna = candidatePool_orna.isEmpty ? catalog_orna : candidatePool_orna

        let totalWeight_orna = pool_orna.reduce(0) { $0 + $1.ornamentRarity_Orna.weight_Orna }
        guard totalWeight_orna > 0 else { return pool_orna.randomElement() }

        var pick_orna = Int.random(in: 0..<totalWeight_orna)
        for ornament_orna in pool_orna {
            let weight_orna = ornament_orna.ornamentRarity_Orna.weight_Orna
            if pick_orna < weight_orna { return ornament_orna }
            pick_orna -= weight_orna
        }
        return pool_orna.last
    }

    // MARK: - 桌面摆件功能

    /// 获取全部摆件图鉴及其拥有状态（按拥有优先、稀有度排序）
    /// 返回值：(摆件模型, 是否已拥有) 元组数组
    func getOrnamentCatalogWithOwnership_Orna() -> [(ornament_orna: OrnamentModel_Orna, isOwned_orna: Bool)] {
        let ownedIds_orna = Set(loggedUser_Orna?.ownedOrnamentIds_Orna ?? [])
        return LocalData_Orna.shared_Orna.ornamentCatalog_Orna
            .map { ($0, ownedIds_orna.contains($0.ornamentId_Orna)) }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 && !rhs.1 }
                return lhs.0.ornamentRarity_Orna.rawValue < rhs.0.ornamentRarity_Orna.rawValue
            }
    }

    /// 获取当前用户已拥有的摆件列表
    func getOwnedOrnaments_Orna() -> [OrnamentModel_Orna] {
        let ownedIds_orna = loggedUser_Orna?.ownedOrnamentIds_Orna ?? []
        return ownedIds_orna.compactMap { LocalData_Orna.shared_Orna.getOrnamentById_Orna(ornamentId_orna: $0) }
    }

    /// 获取桌面槽位数量
    var deskSlotCount_Orna: Int {
        loggedUser_Orna?.deskSlotIds_Orna.count ?? 6
    }

    /// 获取桌面各槽位当前摆放的摆件（未摆放为 nil）
    func getDeskOrnaments_Orna() -> [OrnamentModel_Orna?] {
        let slotIds_orna = loggedUser_Orna?.deskSlotIds_Orna ?? Array(repeating: nil, count: 6)
        return slotIds_orna.map { slotId_orna in
            slotId_orna.flatMap { LocalData_Orna.shared_Orna.getOrnamentById_Orna(ornamentId_orna: $0) }
        }
    }

    /// 将摆件摆放到指定桌面槽位（仅限已拥有的摆件），传 nil 表示清空该槽位
    /// 参数：
    /// - slotIndex_orna: 目标槽位下标
    /// - ornamentId_orna: 要摆放的摆件ID，nil 表示清空
    func placeOrnamentOnDesk_Orna(slotIndex_orna: Int, ornamentId_orna: Int?) {
        guard let user_orna = loggedUser_Orna,
              slotIndex_orna >= 0, slotIndex_orna < user_orna.deskSlotIds_Orna.count else { return }

        if let ornamentId_orna, !user_orna.ownedOrnamentIds_Orna.contains(ornamentId_orna) {
            return
        }
        // 若该摆件已摆放在其他槽位，先清空原槽位，避免同一摆件重复出现
        if let ornamentId_orna {
            for i_orna in user_orna.deskSlotIds_Orna.indices where user_orna.deskSlotIds_Orna[i_orna] == ornamentId_orna {
                user_orna.deskSlotIds_Orna[i_orna] = nil
            }
        }
        user_orna.deskSlotIds_Orna[slotIndex_orna] = ornamentId_orna
        notifyStateChange_Orna()
    }

    // MARK: - 记忆摆件功能（纪念日摆件 / 人物信物摆件）

    /// 生成记忆摆件体系（摆件 / 记录 / 场景 / 场景元素）共用的自增ID
    private func nextMemoryId_Orna() -> Int {
        let id_orna = loggedUser_Orna?.nextMemoryEntityId_Orna ?? 1
        loggedUser_Orna?.nextMemoryEntityId_Orna = id_orna + 1
        return id_orna
    }

    /// 获取当前用户的记忆摆件列表
    /// 参数：
    /// - kind_orna: 按类型过滤，nil 表示返回全部
    /// 返回值：按创建时间倒序排列的记忆摆件列表
    func getMemoryOrnaments_Orna(kind_orna: MemoryOrnamentKind_Orna? = nil) -> [MemoryOrnamentModel_Orna] {
        let all_orna = loggedUser_Orna?.memoryOrnaments_Orna ?? []
        let filtered_orna = kind_orna == nil ? all_orna : all_orna.filter { $0.kind_Orna == kind_orna }
        return filtered_orna.sorted { $0.createdAt_Orna > $1.createdAt_Orna }
    }

    /// 根据ID获取记忆摆件
    func getMemoryOrnamentById_Orna(ornamentId_orna: Int) -> MemoryOrnamentModel_Orna? {
        loggedUser_Orna?.memoryOrnaments_Orna.first { $0.ornamentId_Orna == ornamentId_orna }
    }

    /// 创建记忆摆件（纪念日摆件 / 人物信物摆件）
    /// 功能：未登录时提示登录；创建成功后加入列表并通知刷新，形成"创建-成长-摆放"闭环的起点
    /// 参数：
    /// - kind_orna: 摆件类型
    /// - customName_orna: 用户自定义名称，如"旅行贝壳摆件"
    /// - colorHex_orna: 主题色，nil 时使用类型默认色
    /// - anniversaryMonth_orna / anniversaryDay_orna: 纪念日月 / 日（仅纪念日类型需要）
    /// - anniversaryStartYear_orna: 纪念日起始年份，用于计算陪伴年数（仅纪念日类型需要）
    /// - personName_orna / personRelationship_orna: 人物姓名与关系（仅人物信物类型需要）
    /// 返回值：创建成功返回新摆件模型，未登录返回 nil
    @discardableResult
    func createMemoryOrnament_Orna(
        kind_orna: MemoryOrnamentKind_Orna,
        customName_orna: String,
        colorHex_orna: String? = nil,
        anniversaryMonth_orna: Int? = nil,
        anniversaryDay_orna: Int? = nil,
        anniversaryStartYear_orna: Int? = nil,
        personName_orna: String? = nil,
        personRelationship_orna: String? = nil
    ) -> MemoryOrnamentModel_Orna? {
        guard isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return nil
        }

        let ornament_orna = MemoryOrnamentModel_Orna(
            ornamentId_Orna: nextMemoryId_Orna(),
            kind_Orna: kind_orna,
            customName_Orna: customName_orna.isEmpty ? kind_orna.displayName_Orna : customName_orna,
            colorHex_Orna: colorHex_orna ?? kind_orna.defaultColorHex_Orna,
            anniversaryMonth_Orna: kind_orna.isAnniversaryType_Orna ? anniversaryMonth_orna : nil,
            anniversaryDay_Orna: kind_orna.isAnniversaryType_Orna ? anniversaryDay_orna : nil,
            anniversaryStartYear_Orna: kind_orna.isAnniversaryType_Orna ? anniversaryStartYear_orna : nil,
            personName_Orna: kind_orna.isAnniversaryType_Orna ? nil : personName_orna,
            personRelationship_Orna: kind_orna.isAnniversaryType_Orna ? nil : personRelationship_orna
        )
        loggedUser_Orna?.memoryOrnaments_Orna.append(ornament_orna)
        notifyStateChange_Orna()
        return ornament_orna
    }

    /// 删除记忆摆件（同时从所有桌面场景中移除对它的引用，避免场景内出现悬空摆件）
    func deleteMemoryOrnament_Orna(ornamentId_orna: Int) {
        loggedUser_Orna?.memoryOrnaments_Orna.removeAll { $0.ornamentId_Orna == ornamentId_orna }
        loggedUser_Orna?.deskScenes_Orna.forEach { scene_orna in
            scene_orna.placedItems_Orna.removeAll {
                $0.type_Orna == .ornament_Orna && $0.isMemoryOrnament_Orna && $0.ornamentId_Orna == ornamentId_orna
            }
        }
        notifyStateChange_Orna()
    }

    /// 为记忆摆件新增一条记忆记录（照片 + 随笔），是驱动摆件成长的核心操作
    /// 参数：
    /// - ornamentId_orna: 目标记忆摆件ID
    /// - noteText_orna: 随笔文字内容
    /// - photoImage_orna: 可选照片，传入时会保存到 Documents 目录
    /// - entryDate_orna: 记录日期，默认今天
    func addMemoryEntry_Orna(
        ornamentId_orna: Int,
        noteText_orna: String,
        photoImage_orna: UIImage? = nil,
        entryDate_orna: Date = Date()
    ) {
        guard let ornament_orna = getMemoryOrnamentById_Orna(ornamentId_orna: ornamentId_orna) else { return }

        var photoPath_orna: String? = nil
        if let photoImage_orna {
            photoPath_orna = saveImageToDocuments_Orna(image_orna: photoImage_orna, prefix_orna: "memory_entry")
        }

        let entry_orna = MemoryEntryModel_Orna(
            entryId_Orna: nextMemoryId_Orna(),
            entryDate_Orna: entryDate_orna,
            noteText_Orna: noteText_orna,
            photoPath_Orna: photoPath_orna
        )
        ornament_orna.entries_Orna.append(entry_orna)
        Load_Orna.showSuccess_Orna(message_Orna: "Memory added! \(ornament_orna.customName_Orna) is growing 🌱")
        notifyStateChange_Orna()
    }

    /// 删除某条记忆记录
    func deleteMemoryEntry_Orna(ornamentId_orna: Int, entryId_orna: Int) {
        guard let ornament_orna = getMemoryOrnamentById_Orna(ornamentId_orna: ornamentId_orna) else { return }
        ornament_orna.entries_Orna.removeAll { $0.entryId_Orna == entryId_orna }
        notifyStateChange_Orna()
    }

    // MARK: - 桌面场景功能（自由摆放摆件 / 便签 / 相框搭建微型回忆场景）

    /// 获取当前用户的桌面场景列表（按创建时间倒序）
    func getDeskScenes_Orna() -> [DeskSceneModel_Orna] {
        (loggedUser_Orna?.deskScenes_Orna ?? []).sorted { $0.createdAt_Orna > $1.createdAt_Orna }
    }

    /// 根据ID获取桌面场景
    func getDeskSceneById_Orna(sceneId_orna: Int) -> DeskSceneModel_Orna? {
        loggedUser_Orna?.deskScenes_Orna.first { $0.sceneId_Orna == sceneId_orna }
    }

    /// 创建桌面场景
    /// 参数：
    /// - sceneName_orna: 场景名称
    /// - theme_orna: 场景主题（迷你书房 / 海边角落 / 森林小屋）
    /// 返回值：创建成功返回新场景模型，未登录返回 nil
    @discardableResult
    func createDeskScene_Orna(sceneName_orna: String, theme_orna: DeskSceneTheme_Orna) -> DeskSceneModel_Orna? {
        guard isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return nil
        }
        let scene_orna = DeskSceneModel_Orna(
            sceneId_Orna: nextMemoryId_Orna(),
            sceneName_Orna: sceneName_orna.isEmpty ? theme_orna.displayName_Orna : sceneName_orna,
            theme_Orna: theme_orna
        )
        loggedUser_Orna?.deskScenes_Orna.append(scene_orna)
        notifyStateChange_Orna()
        return scene_orna
    }

    /// 删除桌面场景
    func deleteDeskScene_Orna(sceneId_orna: Int) {
        loggedUser_Orna?.deskScenes_Orna.removeAll { $0.sceneId_Orna == sceneId_orna }
        notifyStateChange_Orna()
    }

    /// 向桌面场景中添加一个可自由摆放的元素（摆件 / 手写便签 / 迷你相框）
    /// 参数：
    /// - sceneId_orna: 目标场景ID
    /// - type_orna: 元素类型
    /// - ornamentId_orna / isMemoryOrnament_orna: 摆件类型时的引用信息
    /// - noteText_orna / noteColorHex_orna: 便签类型时的文字与背景色
    /// - photoImage_orna / photoCaption_orna: 相框类型时的图片与配文，图片会保存到 Documents 目录
    /// 返回值：添加成功返回新元素模型，场景不存在返回 nil
    @discardableResult
    func addPlacedItem_Orna(
        sceneId_orna: Int,
        type_orna: PlacedItemType_Orna,
        ornamentId_orna: Int? = nil,
        isMemoryOrnament_orna: Bool = false,
        noteText_orna: String? = nil,
        noteColorHex_orna: String? = nil,
        photoImage_orna: UIImage? = nil,
        photoCaption_orna: String? = nil
    ) -> PlacedItemModel_Orna? {
        guard let scene_orna = getDeskSceneById_Orna(sceneId_orna: sceneId_orna) else { return nil }

        var photoPath_orna: String? = nil
        if let photoImage_orna {
            photoPath_orna = saveImageToDocuments_Orna(image_orna: photoImage_orna, prefix_orna: "scene_photo")
        }

        // 新元素默认摆放在画布中心附近，并做小幅随机偏移，避免连续添加时完全重叠
        let randomOffsetX_orna = Double.random(in: -0.12...0.12)
        let randomOffsetY_orna = Double.random(in: -0.12...0.12)

        let item_orna = PlacedItemModel_Orna(
            itemId_Orna: nextMemoryId_Orna(),
            type_Orna: type_orna,
            ornamentId_Orna: ornamentId_orna,
            isMemoryOrnament_Orna: isMemoryOrnament_orna,
            noteText_Orna: noteText_orna,
            noteColorHex_Orna: noteColorHex_orna,
            photoPath_Orna: photoPath_orna,
            photoCaption_Orna: photoCaption_orna,
            relativeX_Orna: 0.5 + randomOffsetX_orna,
            relativeY_Orna: 0.5 + randomOffsetY_orna,
            scale_Orna: 1.0
        )
        scene_orna.placedItems_Orna.append(item_orna)
        notifyStateChange_Orna()
        return item_orna
    }

    /// 更新场景元素的自由摆放位置与缩放（拖拽 / 缩放手势结束后调用）
    /// 参数：
    /// - sceneId_orna: 目标场景ID
    /// - itemId_orna: 目标元素ID
    /// - relativeX_orna / relativeY_orna: 相对画布 0...1 比例坐标
    /// - scale_orna: 缩放比例
    func updatePlacedItemTransform_Orna(
        sceneId_orna: Int,
        itemId_orna: Int,
        relativeX_orna: Double,
        relativeY_orna: Double,
        scale_orna: Double
    ) {
        guard let scene_orna = getDeskSceneById_Orna(sceneId_orna: sceneId_orna),
              let item_orna = scene_orna.placedItems_Orna.first(where: { $0.itemId_Orna == itemId_orna }) else { return }
        item_orna.relativeX_Orna = min(max(relativeX_orna, 0), 1)
        item_orna.relativeY_Orna = min(max(relativeY_orna, 0), 1)
        item_orna.scale_Orna = min(max(scale_orna, 0.5), 2.0)
    }

    /// 从场景中移除一个元素
    func removePlacedItem_Orna(sceneId_orna: Int, itemId_orna: Int) {
        guard let scene_orna = getDeskSceneById_Orna(sceneId_orna: sceneId_orna) else { return }
        scene_orna.placedItems_Orna.removeAll { $0.itemId_Orna == itemId_orna }
        notifyStateChange_Orna()
    }

    /// 将图片保存到 Documents 目录，供记忆记录照片与场景相框摆件复用
    /// 参数：
    /// - image_orna: 待保存的图片
    /// - prefix_orna: 文件名前缀，用于区分用途
    /// 返回值：保存成功返回文件名（不含目录路径，供 MediaDisplayView_Orna 按文档目录规则加载），失败返回 nil
    private func saveImageToDocuments_Orna(image_orna: UIImage, prefix_orna: String) -> String? {
        guard let data_orna = image_orna.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_orna = "\(prefix_orna)_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        let docsDir_orna = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_orna = docsDir_orna.appendingPathComponent(fileName_orna)
        do {
            try data_orna.write(to: fileURL_orna)
            return fileName_orna
        } catch {
            print("❌ 保存图片失败: \(error)")
            return nil
        }
    }

    // MARK: - 关注功能

    /// 判断当前用户是否关注了指定用户
    /// 参数：
    /// - user_orna: 目标用户
    /// 返回值：已关注返回 true，未登录或未关注返回 false
    func isFollowing_Orna(user_orna: PrewUserModel_Orna) -> Bool {
        guard let logged_orna = loggedUser_Orna else { return false }
        return logged_orna.userFollow_Orna.contains { $0.userId_Orna == user_orna.userId_Orna }
    }

    /// 关注 / 取消关注用户
    /// 参数：
    /// - user_orna: 目标用户
    func followUser_Orna(user_orna: PrewUserModel_Orna) {
        guard isLoggedIn_Orna else {
            showLoginPrompt_Orna()
            return
        }

        if isFollowing_Orna(user_orna: user_orna) {
            loggedUser_Orna?.userFollow_Orna.removeAll { $0.userId_Orna == user_orna.userId_Orna }
        } else {
            loggedUser_Orna?.userFollow_Orna.append(user_orna)
        }
        notifyStateChange_Orna()
    }

    // MARK: - 举报功能

    /// 举报并屏蔽用户
    /// 功能：删除该用户的聊天记录、帖子，并从本地用户列表移除
    /// 参数：
    /// - user_orna: 被举报的用户
    func reportUser_Orna(user_orna: PrewUserModel_Orna) {
        guard let userId_orna = user_orna.userId_Orna else { return }

        blockedUserIds_Orna.insert(userId_orna)
        MessageViewModel_Orna.shared_Orna.deleteUserMessages_Orna(userId_orna: userId_orna)
        TitleViewModel_Orna.shared_Orna.deleteUserPosts_Orna(userId_orna: userId_orna)
        LocalData_Orna.shared_Orna.userList_Orna.removeAll { $0.userId_Orna == userId_orna }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Load_Orna.showSuccess_Orna(message_Orna: "This user will no longer appear.", delay_Orna: 2.0)
        }
        notifyStateChange_Orna()
    }

    // MARK: - 用户查询

    /// 判断是否是当前登录用户
    /// 参数：
    /// - userId_orna: 待判断的用户ID
    func isCurrentUser_Orna(userId_orna: Int) -> Bool {
        loggedUser_Orna?.userId_Orna == userId_orna
    }

    /// 判断用户是否已被举报/拉黑
    /// 参数：
    /// - userId_orna: 待判断的用户ID
    /// 返回值：已被举报/拉黑返回 true
    func isBlocked_Orna(userId_orna: Int) -> Bool {
        blockedUserIds_Orna.contains(userId_orna)
    }

    /// 根据用户ID获取用户信息
    /// 参数：
    /// - userId_orna: 目标用户ID
    /// 返回值：找到时返回对应用户，未找到时返回以该ID构建的默认游客模型
    func getUserById_Orna(userId_orna: Int) -> PrewUserModel_Orna {
        if let found_orna = LocalData_Orna.shared_Orna.userList_Orna.first(where: { $0.userId_Orna == userId_orna }) {
            return found_orna
        }
        let guest_orna = PrewUserModel_Orna()
        guest_orna.userId_Orna = userId_orna
        guest_orna.userName_Orna = "Guest"
        guest_orna.userHead_Orna = "default_avatar"
        return guest_orna
    }

    /// 获取用户关注排行榜
    /// 返回值：用户列表（当前按原始顺序返回）
    func getUserFollowRanking_Orna() -> [PrewUserModel_Orna] {
        LocalData_Orna.shared_Orna.userList_Orna
    }

    // MARK: - 帖子和点赞管理

    /// 将帖子添加到当前用户的帖子列表
    func addPostToCurrentUser_Orna(post_orna: TitleModel_Orna) {
        guard loggedUser_Orna != nil else { return }
        loggedUser_Orna?.userPosts_Orna.append(post_orna)
        notifyStateChange_Orna()
    }

    /// 从当前用户的帖子列表中移除帖子
    func removePostFromCurrentUser_Orna(post_orna: TitleModel_Orna) {
        guard loggedUser_Orna != nil else { return }
        loggedUser_Orna?.userPosts_Orna.removeAll { $0.titleId_Orna == post_orna.titleId_Orna }
        notifyStateChange_Orna()
    }

    /// 将帖子添加到当前用户的喜欢列表（已存在时跳过）
    func addLikeToCurrentUser_Orna(post_orna: TitleModel_Orna) {
        guard let user_orna = loggedUser_Orna,
              !user_orna.userLike_Orna.contains(where: { $0.titleId_Orna == post_orna.titleId_Orna }) else { return }
        user_orna.userLike_Orna.append(post_orna)
        notifyStateChange_Orna()
    }

    /// 从当前用户的喜欢列表中移除帖子
    func removeLikeFromCurrentUser_Orna(post_orna: TitleModel_Orna) {
        guard loggedUser_Orna != nil else { return }
        loggedUser_Orna?.userLike_Orna.removeAll { $0.titleId_Orna == post_orna.titleId_Orna }
        notifyStateChange_Orna()
    }

    /// 判断当前用户是否喜欢指定帖子
    func isLikedByCurrentUser_Orna(post_orna: TitleModel_Orna) -> Bool {
        loggedUser_Orna?.userLike_Orna.contains { $0.titleId_Orna == post_orna.titleId_Orna } ?? false
    }

    // MARK: - 私有方法

    /// 发送状态更新通知
    private func notifyStateChange_Orna() {
        NotificationCenter.default.post(
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna,
            object: nil
        )
    }

    /// 显示登录引导（延迟 0.5 秒后跳转登录页）
    private func showLoginPrompt_Orna() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Orna.toLogin_Orna(style_orna: .present_orna)
        }
    }
}
