import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Orna: NSObject, Codable {
    
    /// 用户ID
    var userId_Orna: Int?
    
    /// 用户名字
    var userName_Orna: String?
    
    /// 用户简介
    var userIntroduce_Orna: String?
    
    /// 用户头像
    var userHead_Orna: String?
    
    /// 用户媒体
    var userMedia_Orna: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Orna: [TitleModel_Orna] = []

    /// 用户关注数
    var userFollow_Orna: Int?

    /// 用户粉丝数
    var userFans_Orna: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Orna: Int? = nil,
         userName_Orna: String? = nil,
         userIntroduce_Orna: String? = nil,
         userHead_Orna: String? = nil,
         userMedia_Orna: [String]? = nil,
         userLike_Orna: [TitleModel_Orna] = [],
         userFollow_Orna: Int? = nil,
         userFans_Orna: Int? = nil) {
        self.userId_Orna = userId_Orna
        self.userName_Orna = userName_Orna
        self.userIntroduce_Orna = userIntroduce_Orna
        self.userHead_Orna = userHead_Orna
        self.userMedia_Orna = userMedia_Orna
        self.userLike_Orna = userLike_Orna
        self.userFollow_Orna = userFollow_Orna
        self.userFans_Orna = userFans_Orna
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Orna: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Orna: Int
    
    /// 拥有者ID
    var titleUserId_Orna: Int
    
    /// 拥有者昵称
    var titleUserName_Orna: String
    
    /// 帖子媒体
    var titleMeidas_Orna: [String]
    
    /// 帖子标题
    var title_Orna: String
    
    /// 帖子内容
    var titleContent_Orna: String
    
    /// 帖子评论列表
    var reviews_Orna: [Comment_Orna]
    
    /// 喜欢个数
    var likes_Orna: Int

    /// 媒体是否为视频（false 表示图片，默认 false）
    var isVideoMedia_Orna: Bool = false
    
    init(titleId_Orna: Int,
         titleUserId_Orna: Int,
         titleUserName_Orna: String,
         titleMeidas_Orna: [String],
         title_Orna: String,
         titleContent_Orna: String,
         reviews_Orna: [Comment_Orna],
         likes_Orna: Int,
         isVideoMedia_Orna: Bool = false) {
        self.titleId_Orna = titleId_Orna
        self.titleUserId_Orna = titleUserId_Orna
        self.titleUserName_Orna = titleUserName_Orna
        self.titleMeidas_Orna = titleMeidas_Orna
        self.title_Orna = title_Orna
        self.titleContent_Orna = titleContent_Orna
        self.reviews_Orna = reviews_Orna
        self.likes_Orna = likes_Orna
        self.isVideoMedia_Orna = isVideoMedia_Orna
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Orna: NSObject, Codable {
    
    /// 用户ID
    var userId_Orna: Int?
    
    /// 用户密码
    var userPwd_Orna: String?
    
    /// 用户名称
    var userName_Orna: String?
    
    /// 用户自我介绍
    var userIntroduce_Orna: String?
    
    /// 用户头像
    var userHead_Orna: String?
    
    /// 用户发布帖子列表
    var userPosts_Orna: [TitleModel_Orna]
    
    /// 用户喜欢帖子列表
    var userLike_Orna: [TitleModel_Orna]

    /// 用户关注列表
    var userFollow_Orna: [PrewUserModel_Orna]

    /// 已拥有的摆件ID列表（签到获得）
    var ownedOrnamentIds_Orna: [Int] = []

    /// 桌面展示槽位（固定槽位数，未摆放为 nil）
    var deskSlotIds_Orna: [Int?] = Array(repeating: nil, count: 6)

    /// 最近一次签到日期（yyyy-MM-dd）
    var lastCheckInDate_Orna: String? = nil

    /// 连续签到天数
    var checkInStreak_Orna: Int = 0

    /// 纪念摆件 / 人物信物摆件列表（恋爱纪念日、生日、毕业、旅行、宠物陪伴日及人物信物）
    var memoryOrnaments_Orna: [MemoryOrnamentModel_Orna] = []

    /// 桌面小场景列表（自由摆放摆件 / 便签 / 相框搭建的微型回忆场景）
    var deskScenes_Orna: [DeskSceneModel_Orna] = []

    /// 记忆摆件 / 记忆记录 / 桌面场景 / 场景元素共用的自增ID计数器，避免跨集合ID冲突
    var nextMemoryEntityId_Orna: Int = 1

    /// 初始化
    init(userId_Orna: Int? = nil,
         userPwd_Orna: String? = nil,
         userName_Orna: String? = nil,
         userIntroduce_Orna: String? = nil,
         userHead_Orna: String? = nil,
         userPosts_Orna: [TitleModel_Orna],
         userLike_Orna: [TitleModel_Orna],
         userFollow_Orna: [PrewUserModel_Orna]) {
        self.userId_Orna = userId_Orna
        self.userPwd_Orna = userPwd_Orna
        self.userName_Orna = userName_Orna
        self.userIntroduce_Orna = userIntroduce_Orna
        self.userHead_Orna = userHead_Orna
        self.userPosts_Orna = userPosts_Orna
        self.userLike_Orna = userLike_Orna
        self.userFollow_Orna = userFollow_Orna
    }
}

/// 消息数据模型
class MessageModel_Orna: Codable {
    
    /// 消息ID
    var messageId_Orna: Int?
    
    /// 消息内容
    var content_Orna: String?
    
    /// 用户头像
    var userHead_Orna: String?
    
    /// 是否是我发送的
    var isMine_Orna: Bool?
    
    /// 消息时间
    var time_Orna: String?
    
    /// 初始化
    init(messageId_orna: Int? = nil,
         content_orna: String? = nil,
         userHead_orna: String? = nil,
         isMine_orna: Bool? = nil,
         time_orna: String? = nil) {
        self.messageId_Orna = messageId_orna
        self.content_Orna = content_orna
        self.userHead_Orna = userHead_orna
        self.isMine_Orna = isMine_orna
        self.time_Orna = time_orna
    }
}

/// 评论模型
class Comment_Orna: NSObject, Codable {
    
    /// 评论ID
    var commentId_Orna: Int
    
    /// 评论用户uid
    var commentUserId_Orna: Int
    
    /// 评论用户昵称
    var commentUserName_Orna: String
    
    /// 评论内容
    var commentContent_Orna: String
    
    /// 初始化
    init(commentId_Orna: Int,
         commentUserId_Orna: Int,
         commentUserName_Orna: String,
         commentContent_Orna: String) {
        self.commentId_Orna = commentId_Orna
        self.commentUserId_Orna = commentUserId_Orna
        self.commentUserName_Orna = commentUserName_Orna
        self.commentContent_Orna = commentContent_Orna
    }
}

/// 摆件稀有度枚举
/// 功能：区分桌面摆件的稀有等级，用于签到抽取概率权重与视觉标识
enum OrnamentRarity_Orna: Int, Codable {
    /// 普通
    case common_Orna = 0
    /// 稀有
    case rare_Orna = 1
    /// 史诗
    case epic_Orna = 2

    /// 稀有度标签文本
    var label_Orna: String {
        switch self {
        case .common_Orna: return "Common"
        case .rare_Orna: return "Rare"
        case .epic_Orna: return "Epic"
        }
    }

    /// 稀有度主题色（十六进制）
    var colorHex_Orna: String {
        switch self {
        case .common_Orna: return "#8FA6C7"
        case .rare_Orna: return "#5B8DEF"
        case .epic_Orna: return "#B794F6"
        }
    }

    /// 抽取权重（数值越大越容易被抽中）
    var weight_Orna: Int {
        switch self {
        case .common_Orna: return 60
        case .rare_Orna: return 30
        case .epic_Orna: return 10
        }
    }
}

/// 桌面摆件数据模型
/// 功能：描述一件可收藏并可摆放到"我的桌面"的趣味摆件
/// 关键属性：图标使用系统 SF Symbols，无需依赖三方图片资源
class OrnamentModel_Orna: NSObject, Codable {

    /// 摆件ID
    var ornamentId_Orna: Int

    /// 摆件名称
    var ornamentName_Orna: String

    /// 摆件图标（SF Symbol 名称）
    var ornamentIcon_Orna: String

    /// 摆件主题色（十六进制）
    var ornamentColorHex_Orna: String

    /// 摆件稀有度
    var ornamentRarity_Orna: OrnamentRarity_Orna

    /// 初始化
    init(ornamentId_Orna: Int,
         ornamentName_Orna: String,
         ornamentIcon_Orna: String,
         ornamentColorHex_Orna: String,
         ornamentRarity_Orna: OrnamentRarity_Orna) {
        self.ornamentId_Orna = ornamentId_Orna
        self.ornamentName_Orna = ornamentName_Orna
        self.ornamentIcon_Orna = ornamentIcon_Orna
        self.ornamentColorHex_Orna = ornamentColorHex_Orna
        self.ornamentRarity_Orna = ornamentRarity_Orna
    }
}

// MARK: - 记忆摆件模型

/// 记忆摆件类型枚举
/// 功能：区分"纪念日摆件"（恋爱纪念日 / 生日 / 毕业 / 旅行 / 宠物陪伴日，逐年重复提醒）
///       与"人物信物摆件"（为家人 / 朋友 / 恋人制作的专属信物，记录相处小事），
///       并为每种类型提供默认外观与成长阶段图标序列
enum MemoryOrnamentKind_Orna: Int, Codable, CaseIterable {
    /// 恋爱相识纪念日
    case loveAnniversary_Orna = 0
    /// 生日
    case birthday_Orna = 1
    /// 毕业纪念
    case graduation_Orna = 2
    /// 旅行纪念
    case travel_Orna = 3
    /// 宠物陪伴日
    case petCompany_Orna = 4
    /// 人物信物（家人 / 好友 / 恋人）
    case person_Orna = 5

    /// 展示名称
    var displayName_Orna: String {
        switch self {
        case .loveAnniversary_Orna: return "Love Anniversary"
        case .birthday_Orna: return "Birthday"
        case .graduation_Orna: return "Graduation"
        case .travel_Orna: return "Travel Memory"
        case .petCompany_Orna: return "Pet Companion Day"
        case .person_Orna: return "Person Token"
        }
    }

    /// 默认主题色（十六进制）
    var defaultColorHex_Orna: String {
        switch self {
        case .loveAnniversary_Orna: return "#FF6B9D"
        case .birthday_Orna: return "#FF9A6C"
        case .graduation_Orna: return "#5B8DEF"
        case .travel_Orna: return "#43C6AC"
        case .petCompany_Orna: return "#B794F6"
        case .person_Orna: return "#7B61FF"
        }
    }

    /// 成长阶段图标序列（随记忆记录数量增加而推进，象征外观随时间沉淀而进化）
    var growthIcons_Orna: [String] {
        switch self {
        case .loveAnniversary_Orna:
            return ["circle.dashed", "leaf.fill", "heart", "heart.fill", "heart.circle.fill"]
        case .birthday_Orna:
            return ["circle.dashed", "sparkle", "gift", "gift.fill", "crown.fill"]
        case .graduation_Orna:
            return ["circle.dashed", "book.fill", "graduationcap", "graduationcap.fill", "star.circle.fill"]
        case .travel_Orna:
            return ["circle.dashed", "leaf.fill", "airplane", "map.fill", "sparkles"]
        case .petCompany_Orna:
            return ["pawprint", "pawprint.fill", "cat", "cat.fill", "heart.circle.fill"]
        case .person_Orna:
            return ["person", "person.fill", "person.crop.circle", "person.crop.circle.fill", "star.circle.fill"]
        }
    }

    /// 是否为"逐年重复"的纪念日类型（人物信物没有固定周期纪念日）
    var isAnniversaryType_Orna: Bool { self != .person_Orna }

    /// 分类展示标签，用于列表分组
    var categoryLabel_Orna: String { isAnniversaryType_Orna ? "Anniversary" : "Person Token" }
}

/// 单条记忆记录模型
/// 功能：承载某一天为记忆摆件补充的照片与随笔文字，是摆件成长与内容沉淀的最小单元
class MemoryEntryModel_Orna: NSObject, Codable {

    /// 记录ID
    var entryId_Orna: Int

    /// 记录日期
    var entryDate_Orna: Date

    /// 随笔文字内容
    var noteText_Orna: String

    /// 照片文件名（保存至 Documents 目录后的文件名，无照片时为 nil）
    var photoPath_Orna: String?

    /// 初始化
    init(entryId_Orna: Int, entryDate_Orna: Date, noteText_Orna: String, photoPath_Orna: String? = nil) {
        self.entryId_Orna = entryId_Orna
        self.entryDate_Orna = entryDate_Orna
        self.noteText_Orna = noteText_Orna
        self.photoPath_Orna = photoPath_Orna
    }
}

/// 记忆摆件数据模型（纪念日摆件 / 人物信物摆件）
/// 功能：描述一件"可视化的数字纪念品"——随纪念日临近泛起微光、随记忆记录增多逐步成长外观
/// 关键属性：kind_Orna 决定默认外观与成长图标序列；entries_Orna 是驱动成长的记忆记录集合
class MemoryOrnamentModel_Orna: NSObject, Codable {

    /// 成长阶段所需的最少记忆记录数量门槛（索引对应成长阶段，数值递增）
    static let growthThresholds_Orna: [Int] = [0, 3, 8, 18, 35]

    /// 纪念日光效窗口期（纪念日前后天数内摆件呈现微光提示）
    static let anniversaryGlowWindowDays_Orna = 3

    /// 摆件ID
    var ornamentId_Orna: Int

    /// 摆件类型
    var kind_Orna: MemoryOrnamentKind_Orna

    /// 用户自定义名称，如"旅行贝壳摆件"
    var customName_Orna: String

    /// 摆件主题色（十六进制）
    var colorHex_Orna: String

    /// 纪念日"月"（仅纪念日类型摆件有效，用于逐年重复判断）
    var anniversaryMonth_Orna: Int?

    /// 纪念日"日"（仅纪念日类型摆件有效）
    var anniversaryDay_Orna: Int?

    /// 纪念日起始年份（用于计算"第几年"，仅纪念日类型摆件有效）
    var anniversaryStartYear_Orna: Int?

    /// 人物信物对应的人物名称（仅人物信物类型有效）
    var personName_Orna: String?

    /// 人物关系标签，如 Family / Friend / Lover（仅人物信物类型有效）
    var personRelationship_Orna: String?

    /// 创建时间
    var createdAt_Orna: Date

    /// 记忆记录集合（照片 + 随笔），驱动摆件成长
    var entries_Orna: [MemoryEntryModel_Orna] = []

    /// 初始化
    init(ornamentId_Orna: Int,
         kind_Orna: MemoryOrnamentKind_Orna,
         customName_Orna: String,
         colorHex_Orna: String,
         anniversaryMonth_Orna: Int? = nil,
         anniversaryDay_Orna: Int? = nil,
         anniversaryStartYear_Orna: Int? = nil,
         personName_Orna: String? = nil,
         personRelationship_Orna: String? = nil,
         createdAt_Orna: Date = Date()) {
        self.ornamentId_Orna = ornamentId_Orna
        self.kind_Orna = kind_Orna
        self.customName_Orna = customName_Orna
        self.colorHex_Orna = colorHex_Orna
        self.anniversaryMonth_Orna = anniversaryMonth_Orna
        self.anniversaryDay_Orna = anniversaryDay_Orna
        self.anniversaryStartYear_Orna = anniversaryStartYear_Orna
        self.personName_Orna = personName_Orna
        self.personRelationship_Orna = personRelationship_Orna
        self.createdAt_Orna = createdAt_Orna
    }

    /// 当前成长阶段下标（0...4），由记忆记录数量对照门槛推算得出
    var growthStageIndex_Orna: Int {
        let count_orna = entries_Orna.count
        var stage_orna = 0
        for threshold_orna in Self.growthThresholds_Orna where count_orna >= threshold_orna {
            stage_orna += 1
        }
        let maxStage_orna = kind_Orna.growthIcons_Orna.count - 1
        return min(max(stage_orna - 1, 0), maxStage_orna)
    }

    /// 当前成长阶段图标（SF Symbol 名称）
    var currentGrowthIcon_Orna: String {
        kind_Orna.growthIcons_Orna[growthStageIndex_Orna]
    }

    /// 当前成长阶段名称，用于详情页展示
    var growthStageName_Orna: String {
        let names_orna = ["Just Planted", "Sprouting", "Growing", "Flourishing", "Fully Bloomed"]
        return names_orna[min(growthStageIndex_Orna, names_orna.count - 1)]
    }

    /// 距离下一成长阶段还需要的记忆记录数量（已到达最高阶段时返回 nil）
    var entriesUntilNextStage_Orna: Int? {
        let nextThresholdIndex_orna = growthStageIndex_Orna + 1
        guard nextThresholdIndex_orna < Self.growthThresholds_Orna.count,
              nextThresholdIndex_orna <= kind_Orna.growthIcons_Orna.count - 1 else { return nil }
        return max(0, Self.growthThresholds_Orna[nextThresholdIndex_orna] - entries_Orna.count)
    }

    /// 今年的纪念日日期（仅纪念日类型有效，无法构造时返回 nil）
    private var thisYearAnniversaryDate_Orna: Date? {
        guard kind_Orna.isAnniversaryType_Orna,
              let month_orna = anniversaryMonth_Orna,
              let day_orna = anniversaryDay_Orna else { return nil }
        let calendar_orna = Calendar.current
        let year_orna = calendar_orna.component(.year, from: Date())
        return calendar_orna.date(from: DateComponents(year: year_orna, month: month_orna, day: day_orna))
    }

    /// 距离下一次纪念日的天数（今年纪念日已过则计算明年），非纪念日类型返回 nil
    var daysUntilNextAnniversary_Orna: Int? {
        guard let thisYear_orna = thisYearAnniversaryDate_Orna else { return nil }
        let calendar_orna = Calendar.current
        let today_orna = calendar_orna.startOfDay(for: Date())
        let anniversaryDay_orna = calendar_orna.startOfDay(for: thisYear_orna)

        if anniversaryDay_orna >= today_orna {
            return calendar_orna.dateComponents([.day], from: today_orna, to: anniversaryDay_orna).day
        }
        // 今年纪念日已过，计算距明年同一天的天数
        guard let nextYear_orna = calendar_orna.date(byAdding: .year, value: 1, to: anniversaryDay_orna) else { return nil }
        return calendar_orna.dateComponents([.day], from: today_orna, to: nextYear_orna).day
    }

    /// 是否处于纪念日光效窗口期（纪念日前后 N 天内），用于摆件泛起微光的动态视觉提示
    var isGlowingNearAnniversary_Orna: Bool {
        guard let days_orna = daysUntilNextAnniversary_Orna else { return false }
        if days_orna <= Self.anniversaryGlowWindowDays_Orna { return true }
        // 处理"纪念日刚过去几天"仍在光效窗口内的情况（daysUntilNextAnniversary 已经指向明年）
        guard let thisYear_orna = thisYearAnniversaryDate_Orna else { return false }
        let calendar_orna = Calendar.current
        let today_orna = calendar_orna.startOfDay(for: Date())
        let anniversaryDay_orna = calendar_orna.startOfDay(for: thisYear_orna)
        let passedDays_orna = calendar_orna.dateComponents([.day], from: anniversaryDay_orna, to: today_orna).day ?? 999
        return passedDays_orna >= 0 && passedDays_orna <= Self.anniversaryGlowWindowDays_Orna
    }

    /// 纪念日已陪伴的年数（从创建 / 起始年份计算，仅用于展示，非纪念日类型返回 nil）
    var anniversaryYearsCount_Orna: Int? {
        guard kind_Orna.isAnniversaryType_Orna, let startYear_orna = anniversaryStartYear_Orna else { return nil }
        let currentYear_orna = Calendar.current.component(.year, from: Date())
        return max(0, currentYear_orna - startYear_orna)
    }
}

// MARK: - 桌面场景模型

/// 桌面场景主题枚举（自由摆放摆件搭建的微型回忆场景预设风格）
enum DeskSceneTheme_Orna: Int, Codable, CaseIterable {
    /// 迷你书房
    case study_Orna = 0
    /// 海边角落
    case seaside_Orna = 1
    /// 森林小屋
    case forest_Orna = 2

    /// 展示名称
    var displayName_Orna: String {
        switch self {
        case .study_Orna: return "Mini Study"
        case .seaside_Orna: return "Seaside Corner"
        case .forest_Orna: return "Forest Cabin"
        }
    }

    /// 背板渐变色（十六进制，起止两色）
    var backgroundColorHexes_Orna: (String, String) {
        switch self {
        case .study_Orna: return ("#F3DDBB", "#DEB584")
        case .seaside_Orna: return ("#AEE1F9", "#5B9FD6")
        case .forest_Orna: return ("#C7E8C5", "#6FA671")
        }
    }

    /// 主题图标
    var themeIcon_Orna: String {
        switch self {
        case .study_Orna: return "books.vertical.fill"
        case .seaside_Orna: return "water.waves"
        case .forest_Orna: return "tree.fill"
        }
    }
}

/// 场景元素类型枚举
enum PlacedItemType_Orna: Int, Codable {
    /// 摆件（图鉴摆件或记忆摆件）
    case ornament_Orna = 0
    /// 手写便签
    case note_Orna = 1
    /// 迷你相框
    case photoFrame_Orna = 2
}

/// 放置在桌面场景画布中的单个元素
/// 功能：记录元素类型、内容与自由摆放的位置 / 缩放，用于场景编辑器渲染与状态保存
class PlacedItemModel_Orna: NSObject, Codable {

    /// 元素ID
    var itemId_Orna: Int

    /// 元素类型
    var type_Orna: PlacedItemType_Orna

    /// 摆件类型元素引用的摆件ID
    var ornamentId_Orna: Int?

    /// 引用的摆件是否为"记忆摆件"（false 表示引用桌面摆件图鉴中的摆件）
    var isMemoryOrnament_Orna: Bool = false

    /// 便签文字内容
    var noteText_Orna: String?

    /// 便签背景色（十六进制）
    var noteColorHex_Orna: String?

    /// 迷你相框图片文件名（保存至 Documents 目录后的文件名）
    var photoPath_Orna: String?

    /// 迷你相框配文
    var photoCaption_Orna: String?

    /// 自由摆放位置（相对画布宽高的 0...1 比例坐标，适配不同屏幕尺寸）
    var relativeX_Orna: Double
    var relativeY_Orna: Double

    /// 缩放比例，营造随手摆放、远近错落的自然感
    var scale_Orna: Double

    /// 初始化
    init(itemId_Orna: Int,
         type_Orna: PlacedItemType_Orna,
         ornamentId_Orna: Int? = nil,
         isMemoryOrnament_Orna: Bool = false,
         noteText_Orna: String? = nil,
         noteColorHex_Orna: String? = nil,
         photoPath_Orna: String? = nil,
         photoCaption_Orna: String? = nil,
         relativeX_Orna: Double = 0.5,
         relativeY_Orna: Double = 0.5,
         scale_Orna: Double = 1.0) {
        self.itemId_Orna = itemId_Orna
        self.type_Orna = type_Orna
        self.ornamentId_Orna = ornamentId_Orna
        self.isMemoryOrnament_Orna = isMemoryOrnament_Orna
        self.noteText_Orna = noteText_Orna
        self.noteColorHex_Orna = noteColorHex_Orna
        self.photoPath_Orna = photoPath_Orna
        self.photoCaption_Orna = photoCaption_Orna
        self.relativeX_Orna = relativeX_Orna
        self.relativeY_Orna = relativeY_Orna
        self.scale_Orna = scale_Orna
    }
}

/// 桌面场景数据模型
/// 功能：一个可自由摆放摆件 / 手写便签 / 迷你相框的微型回忆场景，支持截图导出为纪念明信片
class DeskSceneModel_Orna: NSObject, Codable {

    /// 场景ID
    var sceneId_Orna: Int

    /// 场景名称
    var sceneName_Orna: String

    /// 场景主题
    var theme_Orna: DeskSceneTheme_Orna

    /// 场景内已摆放的元素集合
    var placedItems_Orna: [PlacedItemModel_Orna] = []

    /// 创建时间
    var createdAt_Orna: Date

    /// 初始化
    init(sceneId_Orna: Int, sceneName_Orna: String, theme_Orna: DeskSceneTheme_Orna, createdAt_Orna: Date = Date()) {
        self.sceneId_Orna = sceneId_Orna
        self.sceneName_Orna = sceneName_Orna
        self.theme_Orna = theme_Orna
        self.createdAt_Orna = createdAt_Orna
    }
}

/// 商店模型
class StoreModel_Orna: NSObject {
    
    /// ID编号
    var id_Orna: Int?
    
    /// 商品ID
    var goodsId_Orna: String?
    
    /// 商品名字
    var goodsName_Orna: String?
    
    /// 商品价格
    var goodsPrice_Orna: String?
    
    /// 是否顶部商品
    var goodIsTop_Orna: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Orna: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Orna: Bool?
    
    init(id_Orna: Int? = nil,
         goodsId_Orna: String? = nil,
         goodsName_Orna: String? = nil,
         goodsPrice_Orna: String? = nil,
         goodIsTop_Orna: Bool? = false,
         goodIsLimit_Orna: Bool? = false,
         goodIsVIP_Orna: Bool? = false) {
        self.id_Orna = id_Orna
        self.goodsId_Orna = goodsId_Orna
        self.goodsName_Orna = goodsName_Orna
        self.goodsPrice_Orna = goodsPrice_Orna
        self.goodIsTop_Orna = goodIsTop_Orna
        self.goodIsSpecial_Orna = goodIsLimit_Orna
        self.goodIsVIP_Orna = goodIsVIP_Orna
        super.init()
    }
}
