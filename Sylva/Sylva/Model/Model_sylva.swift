import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Sylva: NSObject, Codable {
    
    /// 用户ID
    var userId_Sylva: Int?
    
    /// 用户名字
    var userName_Sylva: String?
    
    /// 用户简介
    var userIntroduce_Sylva: String?
    
    /// 用户头像
    var userHead_Sylva: String?
    
    /// 用户媒体
    var userMedia_Sylva: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Sylva: [TitleModel_Sylva] = []

    /// 用户关注数
    var userFollow_Sylva: Int?

    /// 用户粉丝数
    var userFans_Sylva: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Sylva: Int? = nil,
         userName_Sylva: String? = nil,
         userIntroduce_Sylva: String? = nil,
         userHead_Sylva: String? = nil,
         userMedia_Sylva: [String]? = nil,
         userLike_Sylva: [TitleModel_Sylva] = [],
         userFollow_Sylva: Int? = nil,
         userFans_Sylva: Int? = nil) {
        self.userId_Sylva = userId_Sylva
        self.userName_Sylva = userName_Sylva
        self.userIntroduce_Sylva = userIntroduce_Sylva
        self.userHead_Sylva = userHead_Sylva
        self.userMedia_Sylva = userMedia_Sylva
        self.userLike_Sylva = userLike_Sylva
        self.userFollow_Sylva = userFollow_Sylva
        self.userFans_Sylva = userFans_Sylva
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Sylva: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Sylva: Int
    
    /// 拥有者ID
    var titleUserId_Sylva: Int
    
    /// 拥有者昵称
    var titleUserName_Sylva: String
    
    /// 帖子媒体
    var titleMeidas_Sylva: [String]
    
    /// 帖子标题
    var title_Sylva: String
    
    /// 帖子内容
    var titleContent_Sylva: String
    
    /// 帖子评论列表
    var reviews_Sylva: [Comment_Sylva]
    
    /// 喜欢个数
    var likes_Sylva: Int
    
    init(titleId_Sylva: Int,
         titleUserId_Sylva: Int,
         titleUserName_Sylva: String,
         titleMeidas_Sylva: [String],
         title_Sylva: String,
         titleContent_Sylva: String,
         reviews_Sylva: [Comment_Sylva],
         likes_Sylva: Int) {
        self.titleId_Sylva = titleId_Sylva
        self.titleUserId_Sylva = titleUserId_Sylva
        self.titleUserName_Sylva = titleUserName_Sylva
        self.titleMeidas_Sylva = titleMeidas_Sylva
        self.title_Sylva = title_Sylva
        self.titleContent_Sylva = titleContent_Sylva
        self.reviews_Sylva = reviews_Sylva
        self.likes_Sylva = likes_Sylva
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Sylva: NSObject, Codable {
    
    /// 用户ID
    var userId_Sylva: Int?
    
    /// 用户密码
    var userPwd_Sylva: String?
    
    /// 用户名称
    var userName_Sylva: String?
    
    /// 用户简介
    var userIntroduce_Sylva: String?
    
    /// 用户头像
    var userHead_Sylva: String?
    
    /// 用户发布帖子列表
    var userPosts_Sylva: [TitleModel_Sylva]
    
    /// 用户喜欢帖子列表
    var userLike_Sylva: [TitleModel_Sylva]

    /// 用户关注列表
    var userFollow_Sylva: [PrewUserModel_Sylva]

    /// 每日生态任务列表
    var ecoTasks_Sylva: [EcoTask_Sylva]

    /// 累计环保值（总分）
    var totalEcoPoints_Sylva: Int

    /// 每日打卡记录
    var checkInRecord_Sylva: CheckInRecord_Sylva

    /// 初始化
    init(userId_Sylva: Int? = nil,
         userPwd_Sylva: String? = nil,
         userName_Sylva: String? = nil,
         userIntroduce_Sylva: String? = nil,
         userHead_Sylva: String? = nil,
         userPosts_Sylva: [TitleModel_Sylva],
         userLike_Sylva: [TitleModel_Sylva],
         userFollow_Sylva: [PrewUserModel_Sylva],
         ecoTasks_Sylva: [EcoTask_Sylva] = [],
         totalEcoPoints_Sylva: Int = 0,
         checkInRecord_Sylva: CheckInRecord_Sylva = CheckInRecord_Sylva()) {
        self.userId_Sylva = userId_Sylva
        self.userPwd_Sylva = userPwd_Sylva
        self.userName_Sylva = userName_Sylva
        self.userIntroduce_Sylva = userIntroduce_Sylva
        self.userHead_Sylva = userHead_Sylva
        self.userPosts_Sylva = userPosts_Sylva
        self.userLike_Sylva = userLike_Sylva
        self.userFollow_Sylva = userFollow_Sylva
        self.ecoTasks_Sylva = ecoTasks_Sylva
        self.totalEcoPoints_Sylva = totalEcoPoints_Sylva
        self.checkInRecord_Sylva = checkInRecord_Sylva
    }
}

// MARK: - 生态任务相关模型

/// 任务类型枚举
enum TaskType_Sylva: String, Codable {
    case publishPost_Sylva  = "publish_post"   // 发布帖子
    case browsePost_Sylva   = "browse_post"    // 浏览帖子
    case followUser_Sylva   = "follow_user"    // 关注用户
    case likePost_Sylva     = "like_post"      // 给帖子点赞
    case commentPost_Sylva  = "comment_post"   // 评论帖子
}

/// 任务难度枚举（影响所需次数和基础奖励分值）
enum TaskDifficulty_Sylva: Int, Codable {
    case easy_Sylva   = 1  // 简单：完成快，分值低
    case medium_Sylva = 2  // 中等
    case hard_Sylva   = 3  // 困难：完成慢，分值高
}

/// 生态任务模型
/// 功能：记录每日任务状态（完成进度、日期、奖励分值），当日完成后刷新环保值
class EcoTask_Sylva: NSObject, Codable {

    /// 任务唯一 ID
    var taskId_Sylva: Int
    /// 任务类型
    var taskType_Sylva: TaskType_Sylva
    /// 任务标题（英文展示）
    var taskTitle_Sylva: String
    /// 任务描述
    var taskDesc_Sylva: String
    /// 需要完成的操作次数
    var requiredCount_Sylva: Int
    /// 当日已完成次数
    var currentCount_Sylva: Int
    /// 基础环保值奖励
    var ecoPoints_Sylva: Int
    /// 任务难度
    var difficulty_Sylva: TaskDifficulty_Sylva
    /// 任务是否已完成
    var isCompleted_Sylva: Bool
    /// 任务所属日期（yyyy-MM-dd），用于判断是否需要重置
    var taskDate_Sylva: String
    /// SF Symbol 图标名称
    var iconName_Sylva: String

    init(taskId_Sylva: Int,
         taskType_Sylva: TaskType_Sylva,
         taskTitle_Sylva: String,
         taskDesc_Sylva: String,
         requiredCount_Sylva: Int,
         ecoPoints_Sylva: Int,
         difficulty_Sylva: TaskDifficulty_Sylva,
         iconName_Sylva: String) {
        self.taskId_Sylva       = taskId_Sylva
        self.taskType_Sylva     = taskType_Sylva
        self.taskTitle_Sylva    = taskTitle_Sylva
        self.taskDesc_Sylva     = taskDesc_Sylva
        self.requiredCount_Sylva = requiredCount_Sylva
        self.currentCount_Sylva = 0
        self.ecoPoints_Sylva    = ecoPoints_Sylva
        self.difficulty_Sylva   = difficulty_Sylva
        self.isCompleted_Sylva  = false
        self.taskDate_Sylva     = EcoTask_Sylva.todayString_Sylva()
        self.iconName_Sylva     = iconName_Sylva
        super.init()
    }

    /// 返回当天日期字符串（yyyy-MM-dd）
    static func todayString_Sylva() -> String {
        let fmt_sylva = DateFormatter()
        fmt_sylva.dateFormat = "yyyy-MM-dd"
        return fmt_sylva.string(from: Date())
    }

    /// 任务完成进度（0.0 ~ 1.0）
    var progress_Sylva: Double {
        guard requiredCount_Sylva > 0 else { return 0 }
        return min(1.0, Double(currentCount_Sylva) / Double(requiredCount_Sylva))
    }
}

/// 每日打卡记录模型
/// 功能：追踪连续打卡天数，计算公益加成倍率（7天1.5x / 14天2.0x）
class CheckInRecord_Sylva: NSObject, Codable {

    /// 连续打卡天数
    var consecutiveDays_Sylva: Int
    /// 最后打卡日期（yyyy-MM-dd）
    var lastCheckInDate_Sylva: String
    /// 历史累计打卡次数
    var totalCheckIns_Sylva: Int

    override init() {
        self.consecutiveDays_Sylva  = 0
        self.lastCheckInDate_Sylva  = ""
        self.totalCheckIns_Sylva    = 0
        super.init()
    }

    /// 今日是否已打卡
    var hasCheckedInToday_Sylva: Bool {
        return lastCheckInDate_Sylva == EcoTask_Sylva.todayString_Sylva()
    }

    /// 公益加成倍率（连续打卡越多倍率越高）
    var bonusMultiplier_Sylva: Double {
        if consecutiveDays_Sylva >= 14 { return 2.0 }
        if consecutiveDays_Sylva >= 7  { return 1.5 }
        return 1.0
    }

    /// 倍率描述文字
    var multiplierText_Sylva: String {
        let m_sylva = bonusMultiplier_Sylva
        if m_sylva >= 2.0 { return "×2.0 Bonus Active!" }
        if m_sylva >= 1.5 { return "×1.5 Bonus Active!" }
        return "Check in 7 days for ×1.5 bonus"
    }
}

/// 消息数据模型
class MessageModel_Sylva: Codable {
    
    /// 消息ID
    var messageId_Sylva: Int?
    
    /// 消息内容
    var content_Sylva: String?
    
    /// 用户头像
    var userHead_Sylva: String?
    
    /// 是否是我发送的
    var isMine_Sylva: Bool?
    
    /// 消息时间
    var time_Sylva: String?
    
    /// 初始化
    init(messageId_sylva: Int? = nil,
         content_sylva: String? = nil,
         userHead_sylva: String? = nil,
         isMine_sylva: Bool? = nil,
         time_sylva: String? = nil) {
        self.messageId_Sylva = messageId_sylva
        self.content_Sylva = content_sylva
        self.userHead_Sylva = userHead_sylva
        self.isMine_Sylva = isMine_sylva
        self.time_Sylva = time_sylva
    }
}

/// 评论模型
class Comment_Sylva: NSObject, Codable {
    
    /// 评论ID
    var commentId_Sylva: Int
    
    /// 评论用户uid
    var commentUserId_Sylva: Int
    
    /// 评论用户昵称
    var commentUserName_Sylva: String
    
    /// 评论内容
    var commentContent_Sylva: String
    
    /// 初始化
    init(commentId_Sylva: Int,
         commentUserId_Sylva: Int,
         commentUserName_Sylva: String,
         commentContent_Sylva: String) {
        self.commentId_Sylva = commentId_Sylva
        self.commentUserId_Sylva = commentUserId_Sylva
        self.commentUserName_Sylva = commentUserName_Sylva
        self.commentContent_Sylva = commentContent_Sylva
    }
}

/// 商店模型
class StoreModel_Sylva: NSObject {
    
    /// ID编号
    var id_Sylva: Int?
    
    /// 商品ID
    var goodsId_Sylva: String?
    
    /// 商品名字
    var goodsName_Sylva: String?
    
    /// 商品价格
    var goodsPrice_Sylva: String?
    
    /// 是否顶部商品
    var goodIsTop_Sylva: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Sylva: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Sylva: Bool?
    
    init(id_Sylva: Int? = nil,
         goodsId_Sylva: String? = nil,
         goodsName_Sylva: String? = nil,
         goodsPrice_Sylva: String? = nil,
         goodIsTop_Sylva: Bool? = false,
         goodIsLimit_Sylva: Bool? = false,
         goodIsVIP_Sylva: Bool? = false) {
        self.id_Sylva = id_Sylva
        self.goodsId_Sylva = goodsId_Sylva
        self.goodsName_Sylva = goodsName_Sylva
        self.goodsPrice_Sylva = goodsPrice_Sylva
        self.goodIsTop_Sylva = goodIsTop_Sylva
        self.goodIsSpecial_Sylva = goodIsLimit_Sylva
        self.goodIsVIP_Sylva = goodIsVIP_Sylva
        super.init()
    }
}
