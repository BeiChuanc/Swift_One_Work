import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Trace: NSObject, Codable {
    
    /// 用户ID
    var userId_Trace: Int?
    
    /// 用户名字
    var userName_Trace: String?
    
    /// 用户简介
    var userIntroduce_Trace: String?
    
    /// 用户头像
    var userHead_Trace: String?
    
    /// 用户媒体
    var userMedia_Trace: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Trace: [TitleModel_Trace] = []

    /// 用户关注数
    var userFollow_Trace: Int?

    /// 用户粉丝数
    var userFans_Trace: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Trace: Int? = nil,
         userName_Trace: String? = nil,
         userIntroduce_Trace: String? = nil,
         userHead_Trace: String? = nil,
         userMedia_Trace: [String]? = nil,
         userLike_Trace: [TitleModel_Trace] = [],
         userFollow_Trace: Int? = nil,
         userFans_Trace: Int? = nil) {
        self.userId_Trace = userId_Trace
        self.userName_Trace = userName_Trace
        self.userIntroduce_Trace = userIntroduce_Trace
        self.userHead_Trace = userHead_Trace
        self.userMedia_Trace = userMedia_Trace
        self.userLike_Trace = userLike_Trace
        self.userFollow_Trace = userFollow_Trace
        self.userFans_Trace = userFans_Trace
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Trace: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Trace: Int
    
    /// 拥有者ID
    var titleUserId_Trace: Int
    
    /// 拥有者昵称
    var titleUserName_Trace: String
    
    /// 帖子媒体
    var titleMeidas_Trace: [String]
    
    /// 帖子标题
    var title_Trace: String
    
    /// 帖子内容
    var titleContent_Trace: String
    
    /// 帖子评论列表
    var reviews_Trace: [Comment_Trace]
    
    /// 喜欢个数
    var likes_Trace: Int
    
    /// 帖子分类标签（Life / Night / Moments / Memory / Nature / Stars / Warmth / Friends）
    var titleTag_Trace: String
    
    init(titleId_Trace: Int,
         titleUserId_Trace: Int,
         titleUserName_Trace: String,
         titleMeidas_Trace: [String],
         title_Trace: String,
         titleContent_Trace: String,
         reviews_Trace: [Comment_Trace],
         likes_Trace: Int,
         titleTag_Trace: String = "Life") {
        self.titleId_Trace = titleId_Trace
        self.titleUserId_Trace = titleUserId_Trace
        self.titleUserName_Trace = titleUserName_Trace
        self.titleMeidas_Trace = titleMeidas_Trace
        self.title_Trace = title_Trace
        self.titleContent_Trace = titleContent_Trace
        self.reviews_Trace = reviews_Trace
        self.likes_Trace = likes_Trace
        self.titleTag_Trace = titleTag_Trace
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Trace: NSObject, Codable {
    
    /// 用户ID
    var userId_Trace: Int?
    
    /// 用户密码
    var userPwd_Trace: String?
    
    /// 用户名称
    var userName_Trace: String?
    
    /// 用户头像
    var userHead_Trace: String?
    
    /// 用户简介
    var userIntroduce_Trace: String?
    
    /// 用户发布帖子列表
    var userPosts_Trace: [TitleModel_Trace]
    
    /// 用户喜欢帖子列表
    var userLike_Trace: [TitleModel_Trace]

    /// 用户关注列表
    var userFollow_Trace: [PrewUserModel_Trace]

    /// 签到日期集合（格式 "yyyy-MM-dd"，与登录用户绑定，退出后清空）
    var userCheckInDates_Trace: Set<String>

    /// 时光记录列表（按时间戳降序，最新在前）
    var userTraceRecords_Trace: [TraceRecord_Trace]

    /// 时光记录 ID 自增计数器
    var userNextRecordId_Trace: Int

    /// 初始化
    init(userId_Trace: Int? = nil,
         userPwd_Trace: String? = nil,
         userName_Trace: String? = nil,
         userHead_Trace: String? = nil,
         userIntroduce_Trace: String? = nil,
         userPosts_Trace: [TitleModel_Trace],
         userLike_Trace: [TitleModel_Trace],
         userFollow_Trace: [PrewUserModel_Trace],
         userCheckInDates_Trace: Set<String> = [],
         userTraceRecords_Trace: [TraceRecord_Trace] = [],
         userNextRecordId_Trace: Int = 1) {
        self.userId_Trace = userId_Trace
        self.userPwd_Trace = userPwd_Trace
        self.userName_Trace = userName_Trace
        self.userHead_Trace = userHead_Trace
        self.userIntroduce_Trace = userIntroduce_Trace
        self.userPosts_Trace = userPosts_Trace
        self.userLike_Trace = userLike_Trace
        self.userFollow_Trace = userFollow_Trace
        self.userCheckInDates_Trace = userCheckInDates_Trace
        self.userTraceRecords_Trace = userTraceRecords_Trace
        self.userNextRecordId_Trace = userNextRecordId_Trace
    }
}

/// 消息数据模型
class MessageModel_Trace: Codable {
    
    /// 消息ID
    var messageId_Trace: Int?
    
    /// 消息内容
    var content_Trace: String?
    
    /// 用户头像
    var userHead_Trace: String?
    
    /// 是否是我发送的
    var isMine_Trace: Bool?
    
    /// 消息时间
    var time_Trace: String?
    
    /// 初始化
    init(messageId_trace: Int? = nil,
         content_trace: String? = nil,
         userHead_trace: String? = nil,
         isMine_trace: Bool? = nil,
         time_trace: String? = nil) {
        self.messageId_Trace = messageId_trace
        self.content_Trace = content_trace
        self.userHead_Trace = userHead_trace
        self.isMine_Trace = isMine_trace
        self.time_Trace = time_trace
    }
}

/// 评论模型
class Comment_Trace: NSObject, Codable {
    
    /// 评论ID
    var commentId_Trace: Int
    
    /// 评论用户uid
    var commentUserId_Trace: Int
    
    /// 评论用户昵称
    var commentUserName_Trace: String
    
    /// 评论内容
    var commentContent_Trace: String
    
    /// 初始化
    init(commentId_Trace: Int,
         commentUserId_Trace: Int,
         commentUserName_Trace: String,
         commentContent_Trace: String) {
        self.commentId_Trace = commentId_Trace
        self.commentUserId_Trace = commentUserId_Trace
        self.commentUserName_Trace = commentUserName_Trace
        self.commentContent_Trace = commentContent_Trace
    }
}

/// 时光记录模型（首页极简输入留存的即时记录）
/// 核心作用：记录用户的即时情绪与生活瞬间，自动标注当日时刻
/// 关键属性：content_Trace（记录内容），timestamp_Trace（时间戳），timeString_Trace（格式化时刻）
class TraceRecord_Trace: NSObject, Codable {
    
    /// 记录ID
    var recordId_Trace: Int
    
    /// 记录内容
    var content_Trace: String
    
    /// 记录时间戳
    var timestamp_Trace: Date
    
    /// 当日时刻字符串（如 "14:32"）
    var timeString_Trace: String {
        let fmt_Trace = DateFormatter()
        fmt_Trace.dateFormat = "HH:mm"
        return fmt_Trace.string(from: timestamp_Trace)
    }
    
    /// 短日期字符串（如 "Mar 3"）
    var shortDateString_Trace: String {
        let fmt_Trace = DateFormatter()
        fmt_Trace.dateFormat = "MMM d"
        return fmt_Trace.string(from: timestamp_Trace)
    }
    
    /// 日期键（用于按天分组，格式 "yyyy-MM-dd"）
    var dateKey_Trace: String {
        let fmt_Trace = DateFormatter()
        fmt_Trace.dateFormat = "yyyy-MM-dd"
        return fmt_Trace.string(from: timestamp_Trace)
    }
    
    init(recordId_Trace: Int, content_Trace: String, timestamp_Trace: Date = Date()) {
        self.recordId_Trace = recordId_Trace
        self.content_Trace = content_Trace
        self.timestamp_Trace = timestamp_Trace
        super.init()
    }
}

/// 挑战参与记录模型
/// 核心作用：存储其他用户在某挑战下留下的一条极简参与记录，用于挑战详情页的"Recent Traces"展示
/// 关键属性：authorUserId_Trace（参与者用户 UID），content_Trace（记录内容）
class ChallengeParticipation_Trace: NSObject {

    /// 参与者用户 UID（与 LocalData_Trace.userList_Trace 中的 userId 对应）
    var authorUserId_Trace: Int

    /// 参与内容（一段极简记录文字）
    var content_Trace: String

    /// - Parameters:
    ///   - authorUserId_Trace: 参与者用户 UID
    ///   - content_Trace: 参与内容
    init(authorUserId_Trace: Int,
         content_Trace: String) {
        self.authorUserId_Trace = authorUserId_Trace
        self.content_Trace = content_Trace
        super.init()
    }
}

/// 轻量记录挑战模型
/// 核心作用：承载官方或用户发起的极简打卡挑战，如「记录今日晚霞」「一句心情打卡」
/// 关键属性：title_Trace（挑战名称），emoji_Trace（视觉标志），tag_Trace（关联话题标签），isOfficial_Trace（是否官方发起），participations_Trace（预制参与记录）
class ChallengeModel_Trace: NSObject {

    /// 挑战唯一 ID
    var challengeId_Trace: Int

    /// 挑战标题（如 "Catch Tonight's Sunset"）
    var title_Trace: String

    /// 挑战描述（一句引导语）
    var description_Trace: String

    /// 代表表情（用于视觉强化）
    var emoji_Trace: String

    /// 关联话题标签（与帖子标签体系对齐）
    var tag_Trace: String

    /// 是否由官方发起（true = 官方，false = 用户社区）
    var isOfficial_Trace: Bool

    /// 参与人数
    var participants_Trace: Int

    /// 卡片渐变起始色（十六进制字符串）
    var gradientStart_Trace: String

    /// 卡片渐变结束色（十六进制字符串）
    var gradientEnd_Trace: String

    /// 该挑战的预制参与记录列表（每条由其他用户发布，展示在详情页）
    var participations_Trace: [ChallengeParticipation_Trace] = []

    /// - Parameters:
    ///   - challengeId_Trace: 唯一标识
    ///   - title_Trace: 挑战标题
    ///   - description_Trace: 引导描述
    ///   - emoji_Trace: 表情符号
    ///   - tag_Trace: 话题标签
    ///   - isOfficial_Trace: 是否官方
    ///   - participants_Trace: 参与人数
    ///   - gradientStart_Trace: 渐变起始色
    ///   - gradientEnd_Trace: 渐变结束色
    init(challengeId_Trace: Int,
         title_Trace: String,
         description_Trace: String,
         emoji_Trace: String,
         tag_Trace: String,
         isOfficial_Trace: Bool,
         participants_Trace: Int,
         gradientStart_Trace: String,
         gradientEnd_Trace: String) {
        self.challengeId_Trace = challengeId_Trace
        self.title_Trace = title_Trace
        self.description_Trace = description_Trace
        self.emoji_Trace = emoji_Trace
        self.tag_Trace = tag_Trace
        self.isOfficial_Trace = isOfficial_Trace
        self.participants_Trace = participants_Trace
        self.gradientStart_Trace = gradientStart_Trace
        self.gradientEnd_Trace = gradientEnd_Trace
        super.init()
    }
}

/// 商店模型
class StoreModel_Trace: NSObject {
    
    /// ID编号
    var id_Trace: Int?
    
    /// 商品ID
    var goodsId_Trace: String?
    
    /// 商品名字
    var goodsName_Trace: String?
    
    /// 商品价格
    var goodsPrice_Trace: String?
    
    /// 是否顶部商品
    var goodIsTop_Trace: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Trace: Bool?
    
    init(id_Trace: Int? = nil,
         goodsId_Trace: String? = nil,
         goodsName_Trace: String? = nil,
         goodsPrice_Trace: String? = nil,
         goodIsTop_Trace: Bool? = false,
         goodIsLimit_Trace: Bool? = false) {
        self.id_Trace = id_Trace
        self.goodsId_Trace = goodsId_Trace
        self.goodsName_Trace = goodsName_Trace
        self.goodsPrice_Trace = goodsPrice_Trace
        self.goodIsTop_Trace = goodIsTop_Trace
        self.goodIsSpecial_Trace = goodIsLimit_Trace
        super.init()
    }
}
