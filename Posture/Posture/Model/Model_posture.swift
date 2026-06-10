import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Posture: NSObject, Codable {
    
    /// 用户ID
    var userId_Posture: Int?
    
    /// 用户名字
    var userName_Posture: String?
    
    /// 用户简介
    var userIntroduce_Posture: String?
    
    /// 用户头像
    var userHead_Posture: String?
    
    /// 用户媒体
    var userMedia_Posture: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Posture: [TitleModel_Posture] = []

    /// 用户关注数
    var userFollow_Posture: Int?

    /// 用户粉丝数
    var userFans_Posture: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Posture: Int? = nil,
         userName_Posture: String? = nil,
         userIntroduce_Posture: String? = nil,
         userHead_Posture: String? = nil,
         userMedia_Posture: [String]? = nil,
         userLike_Posture: [TitleModel_Posture] = [],
         userFollow_Posture: Int? = nil,
         userFans_Posture: Int? = nil) {
        self.userId_Posture = userId_Posture
        self.userName_Posture = userName_Posture
        self.userIntroduce_Posture = userIntroduce_Posture
        self.userHead_Posture = userHead_Posture
        self.userMedia_Posture = userMedia_Posture
        self.userLike_Posture = userLike_Posture
        self.userFollow_Posture = userFollow_Posture
        self.userFans_Posture = userFans_Posture
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Posture: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Posture: Int
    
    /// 拥有者ID
    var titleUserId_Posture: Int
    
    /// 拥有者昵称
    var titleUserName_Posture: String
    
    /// 帖子媒体
    var titleMeidas_Posture: [String]
    
    /// 帖子标题
    var title_Posture: String
    
    /// 帖子内容
    var titleContent_Posture: String
    
    /// 帖子评论列表
    var reviews_Posture: [Comment_Posture]
    
    /// 喜欢个数
    var likes_Posture: Int
    
    init(titleId_Posture: Int,
         titleUserId_Posture: Int,
         titleUserName_Posture: String,
         titleMeidas_Posture: [String],
         title_Posture: String,
         titleContent_Posture: String,
         reviews_Posture: [Comment_Posture],
         likes_Posture: Int) {
        self.titleId_Posture = titleId_Posture
        self.titleUserId_Posture = titleUserId_Posture
        self.titleUserName_Posture = titleUserName_Posture
        self.titleMeidas_Posture = titleMeidas_Posture
        self.title_Posture = title_Posture
        self.titleContent_Posture = titleContent_Posture
        self.reviews_Posture = reviews_Posture
        self.likes_Posture = likes_Posture
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Posture: NSObject, Codable {
    
    /// 用户ID
    var userId_Posture: Int?
    
    /// 用户密码
    var userPwd_Posture: String?
    
    /// 用户名称
    var userName_Posture: String?
    
    /// 用户头像
    var userHead_Posture: String?

    /// 用户简介
    var userIntroduce_Posture: String?
    
    /// 用户发布帖子列表
    var userPosts_Posture: [TitleModel_Posture]
    
    /// 用户喜欢帖子列表
    var userLike_Posture: [TitleModel_Posture]

    /// 用户关注列表
    var userFollow_Posture: [PrewUserModel_Posture]
    
    /// 初始化
    init(userId_Posture: Int? = nil,
         userPwd_Posture: String? = nil,
         userName_Posture: String? = nil,
         userHead_Posture: String? = nil,
         userIntroduce_Posture: String? = nil,
         userPosts_Posture: [TitleModel_Posture],
         userLike_Posture: [TitleModel_Posture],
         userFollow_Posture: [PrewUserModel_Posture]) {
        self.userId_Posture = userId_Posture
        self.userPwd_Posture = userPwd_Posture
        self.userName_Posture = userName_Posture
        self.userHead_Posture = userHead_Posture
        self.userIntroduce_Posture = userIntroduce_Posture
        self.userPosts_Posture = userPosts_Posture
        self.userLike_Posture = userLike_Posture
        self.userFollow_Posture = userFollow_Posture
    }
}

/// 消息数据模型
class MessageModel_Posture: Codable {
    
    /// 消息ID
    var messageId_Posture: Int?
    
    /// 消息内容
    var content_Posture: String?
    
    /// 用户头像
    var userHead_Posture: String?
    
    /// 是否是我发送的
    var isMine_Posture: Bool?
    
    /// 消息时间
    var time_Posture: String?
    
    /// 初始化
    init(messageId_posture: Int? = nil,
         content_posture: String? = nil,
         userHead_posture: String? = nil,
         isMine_posture: Bool? = nil,
         time_posture: String? = nil) {
        self.messageId_Posture = messageId_posture
        self.content_Posture = content_posture
        self.userHead_Posture = userHead_posture
        self.isMine_Posture = isMine_posture
        self.time_Posture = time_posture
    }
}

/// 评论模型
class Comment_Posture: NSObject, Codable {
    
    /// 评论ID
    var commentId_Posture: Int
    
    /// 评论用户uid
    var commentUserId_Posture: Int
    
    /// 评论用户昵称
    var commentUserName_Posture: String
    
    /// 评论内容
    var commentContent_Posture: String
    
    /// 初始化
    init(commentId_Posture: Int,
         commentUserId_Posture: Int,
         commentUserName_Posture: String,
         commentContent_Posture: String) {
        self.commentId_Posture = commentId_Posture
        self.commentUserId_Posture = commentUserId_Posture
        self.commentUserName_Posture = commentUserName_Posture
        self.commentContent_Posture = commentContent_Posture
    }
}

/// 体态短板枚举
/// 核心作用：标识用户的四种常见体态薄弱区域，作为体态档案的选项来源
enum PostureWeakness_Posture: String, Codable, CaseIterable {
    case neck_posture      = "Neck & Shoulders"
    case upperBack_posture = "Upper Back"
    case lowerBack_posture = "Lower Back"
    case hips_posture      = "Hips & Pelvis"
}

/// 运动基础枚举
/// 核心作用：区分用户的体能水平，用于推送对应难度的每日计划
enum FitnessLevel_Posture: String, Codable, CaseIterable {
    case beginner_posture     = "Beginner"
    case intermediate_posture = "Intermediate"
    case advanced_posture     = "Advanced"
}

/// 用户体态档案模型
/// 核心作用：存储用户自填的体态短板、每日久坐时长、运动基础，驱动每日计划生成
/// 设计思路：实现 Codable 以便直接编码至 UserDefaults 持久化
class PosturePlanProfile_Posture: NSObject, Codable {

    /// 选中的体态短板（PostureWeakness_Posture rawValue 数组）
    var weaknesses_Posture: [String]

    /// 每日久坐时长（小时）
    var dailySittingHours_Posture: Int

    /// 运动基础（FitnessLevel_Posture rawValue）
    var fitnessLevel_Posture: String

    init(weaknesses_Posture: [String] = [],
         dailySittingHours_Posture: Int = 8,
         fitnessLevel_Posture: String = FitnessLevel_Posture.beginner_posture.rawValue) {
        self.weaknesses_Posture = weaknesses_Posture
        self.dailySittingHours_Posture = dailySittingHours_Posture
        self.fitnessLevel_Posture = fitnessLevel_Posture
        super.init()
    }
}

/// 每日推荐条目模型
/// 核心作用：由系统根据体态档案动态生成，展示单条拉伸或矫正建议
class DailyRecommendation_Posture: NSObject {

    /// 建议标题
    var title_Posture: String

    /// 建议详情
    var detail_Posture: String

    /// 参考时长
    var duration_Posture: String

    /// SF Symbol 图标名
    var icon_Posture: String

    init(title_Posture: String,
         detail_Posture: String,
         duration_Posture: String,
         icon_Posture: String) {
        self.title_Posture = title_Posture
        self.detail_Posture = detail_Posture
        self.duration_Posture = duration_Posture
        self.icon_Posture = icon_Posture
        super.init()
    }
}

/// 话题模型
/// 核心作用：代表社区细分话题，包含话题信息及其评论列表
/// 设计思路：实现 Codable 便于序列化；评论复用 Comment_Posture 模型
class Topic_Posture: NSObject, Codable {

    /// 话题 ID
    var topicId_Posture: Int

    /// 话题标题
    var topicTitle_Posture: String

    /// 话题描述
    var topicDesc_Posture: String

    /// SF Symbol 图标名
    var topicIcon_Posture: String

    /// 话题评论列表
    var comments_Posture: [Comment_Posture]

    /// 参与人数
    var memberCount_Posture: Int

    init(topicId_Posture: Int,
         topicTitle_Posture: String,
         topicDesc_Posture: String,
         topicIcon_Posture: String,
         comments_Posture: [Comment_Posture] = [],
         memberCount_Posture: Int = 0) {
        self.topicId_Posture = topicId_Posture
        self.topicTitle_Posture = topicTitle_Posture
        self.topicDesc_Posture = topicDesc_Posture
        self.topicIcon_Posture = topicIcon_Posture
        self.comments_Posture = comments_Posture
        self.memberCount_Posture = memberCount_Posture
        super.init()
    }
}

/// 商店模型
class StoreModel_Posture: NSObject {
    
    /// ID编号
    var id_Posture: Int?
    
    /// 商品ID
    var goodsId_Posture: String?
    
    /// 商品名字
    var goodsName_Posture: String?
    
    /// 商品价格
    var goodsPrice_Posture: String?
    
    /// 是否顶部商品
    var goodIsTop_Posture: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Posture: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Posture: Bool?
    
    init(id_Posture: Int? = nil,
         goodsId_Posture: String? = nil,
         goodsName_Posture: String? = nil,
         goodsPrice_Posture: String? = nil,
         goodIsTop_Posture: Bool? = false,
         goodIsLimit_Posture: Bool? = false,
         goodIsVIP_Posture: Bool? = false) {
        self.id_Posture = id_Posture
        self.goodsId_Posture = goodsId_Posture
        self.goodsName_Posture = goodsName_Posture
        self.goodsPrice_Posture = goodsPrice_Posture
        self.goodIsTop_Posture = goodIsTop_Posture
        self.goodIsSpecial_Posture = goodIsLimit_Posture
        self.goodIsVIP_Posture = goodIsVIP_Posture
        super.init()
    }
}

// MARK: - 用户自定义体态计划

/// 用户自定义体态计划模型
/// 核心作用：存储用户手动添加的单条训练计划及锻炼进度。
/// 设计思路：通过 JSON 编解码持久化到 UserDefaults；progressRatio 用于 UI 进度条展示。
/// 新增字段：content（内容描述）、coverImagePath（封面本地路径）、scheduledTime（计划时间）
struct UserPlan_Posture: Codable {

    /// 计划唯一标识
    var planId_Posture: String

    /// 计划标题（用户输入）
    var title_Posture: String

    /// 计划内容描述
    var content_Posture: String

    /// 封面图片本地路径（可选）
    var coverImagePath_Posture: String?

    /// 计划时间字符串，如 "08:30"（可选）
    var scheduledTime_Posture: String?

    /// 目标时长（分钟）
    var targetMinutes_Posture: Int

    /// 已累计锻炼秒数（每次会话结束后叠加）
    var completedSeconds_Posture: Int

    /// 创建日期字符串（"yyyy-MM-dd"）
    var createdDate_Posture: String

    /// 初始化新计划
    /// - Parameters:
    ///   - title_posture: 计划标题
    ///   - content_posture: 内容描述
    ///   - coverImagePath_posture: 封面本地路径（可选）
    ///   - scheduledTime_posture: 计划时间字符串（可选）
    ///   - targetMinutes_posture: 目标时长（分钟）
    init(title_posture: String,
         content_posture: String = "",
         coverImagePath_posture: String? = nil,
         scheduledTime_posture: String? = nil,
         targetMinutes_posture: Int) {
        planId_Posture = UUID().uuidString
        title_Posture = title_posture
        content_Posture = content_posture
        coverImagePath_Posture = coverImagePath_posture
        scheduledTime_Posture = scheduledTime_posture
        targetMinutes_Posture = targetMinutes_posture
        completedSeconds_Posture = 0
        let fmt_Posture = DateFormatter()
        fmt_Posture.dateFormat = "yyyy-MM-dd"
        createdDate_Posture = fmt_Posture.string(from: Date())
    }

    /// 完成进度比例（0.0 ~ 1.0）
    var progressRatio_Posture: Double {
        let target_Posture = targetMinutes_Posture * 60
        guard target_Posture > 0 else { return 0 }
        return min(1.0, Double(completedSeconds_Posture) / Double(target_Posture))
    }

    /// 已完成分钟数（向下取整）
    var completedMinutes_Posture: Int { completedSeconds_Posture / 60 }

    /// 是否达到目标时长
    var isCompleted_Posture: Bool { completedSeconds_Posture >= targetMinutes_Posture * 60 }
}
