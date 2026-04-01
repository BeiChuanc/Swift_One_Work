import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Flick: NSObject, Codable {
    
    /// 用户ID
    var userId_Flick: Int?
    
    /// 用户名字
    var userName_Flick: String?
    
    /// 用户简介
    var userIntroduce_Flick: String?
    
    /// 用户头像
    var userHead_Flick: String?
    
    /// 用户媒体
    var userMedia_Flick: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Flick: [TitleModel_Flick] = []

    /// 用户关注数
    var userFollow_Flick: Int?

    /// 用户粉丝数
    var userFans_Flick: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Flick: Int? = nil,
         userName_Flick: String? = nil,
         userIntroduce_Flick: String? = nil,
         userHead_Flick: String? = nil,
         userMedia_Flick: [String]? = nil,
         userLike_Flick: [TitleModel_Flick] = [],
         userFollow_Flick: Int? = nil,
         userFans_Flick: Int? = nil) {
        self.userId_Flick = userId_Flick
        self.userName_Flick = userName_Flick
        self.userIntroduce_Flick = userIntroduce_Flick
        self.userHead_Flick = userHead_Flick
        self.userMedia_Flick = userMedia_Flick
        self.userLike_Flick = userLike_Flick
        self.userFollow_Flick = userFollow_Flick
        self.userFans_Flick = userFans_Flick
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Flick: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Flick: Int
    
    /// 拥有者ID
    var titleUserId_Flick: Int
    
    /// 拥有者昵称
    var titleUserName_Flick: String
    
    /// 帖子媒体
    var titleMeidas_Flick: [String]
    
    /// 帖子标题
    var title_Flick: String
    
    /// 帖子内容
    var titleContent_Flick: String
    
    /// 帖子评论列表
    var reviews_Flick: [Comment_Flick]
    
    /// 喜欢个数
    var likes_Flick: Int
    
    init(titleId_Flick: Int,
         titleUserId_Flick: Int,
         titleUserName_Flick: String,
         titleMeidas_Flick: [String],
         title_Flick: String,
         titleContent_Flick: String,
         reviews_Flick: [Comment_Flick],
         likes_Flick: Int) {
        self.titleId_Flick = titleId_Flick
        self.titleUserId_Flick = titleUserId_Flick
        self.titleUserName_Flick = titleUserName_Flick
        self.titleMeidas_Flick = titleMeidas_Flick
        self.title_Flick = title_Flick
        self.titleContent_Flick = titleContent_Flick
        self.reviews_Flick = reviews_Flick
        self.likes_Flick = likes_Flick
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Flick: NSObject, Codable {
    
    /// 用户ID
    var userId_Flick: Int?
    
    /// 用户密码
    var userPwd_Flick: String?
    
    /// 用户名称
    var userName_Flick: String?
    
    /// 用户头像
    var userHead_Flick: String?
    
    /// 用户简介
    var userIntroduce_Flick: String?
    
    /// 用户发布帖子列表
    var userPosts_Flick: [TitleModel_Flick]
    
    /// 用户喜欢帖子列表
    var userLike_Flick: [TitleModel_Flick]

    /// 用户关注列表
    var userFollow_Flick: [PrewUserModel_Flick]
    
    /// 初始化
    init(userId_Flick: Int? = nil,
         userPwd_Flick: String? = nil,
         userName_Flick: String? = nil,
         userHead_Flick: String? = nil,
         userIntroduce_Flick: String? = nil,
         userPosts_Flick: [TitleModel_Flick],
         userLike_Flick: [TitleModel_Flick],
         userFollow_Flick: [PrewUserModel_Flick]) {
        self.userId_Flick = userId_Flick
        self.userPwd_Flick = userPwd_Flick
        self.userName_Flick = userName_Flick
        self.userHead_Flick = userHead_Flick
        self.userIntroduce_Flick = userIntroduce_Flick
        self.userPosts_Flick = userPosts_Flick
        self.userLike_Flick = userLike_Flick
        self.userFollow_Flick = userFollow_Flick
    }
}

// MARK: - 登录用户扩展（分用户本地内容）

extension LoginUserModel_Flick {
    /// 与首页速记、时间胶囊在 UserDefaults 中的分库存储键一致（对应当前 userId）
    var userScopedStorageId_Flick: String {
        String(userId_Flick ?? 0)
    }
}

/// 消息数据模型
class MessageModel_Flick: Codable {
    
    /// 消息ID
    var messageId_Flick: Int?
    
    /// 消息内容
    var content_Flick: String?
    
    /// 用户头像
    var userHead_Flick: String?
    
    /// 是否是我发送的
    var isMine_Flick: Bool?
    
    /// 消息时间
    var time_Flick: String?
    
    /// 初始化
    init(messageId_flick: Int? = nil,
         content_flick: String? = nil,
         userHead_flick: String? = nil,
         isMine_flick: Bool? = nil,
         time_flick: String? = nil) {
        self.messageId_Flick = messageId_flick
        self.content_Flick = content_flick
        self.userHead_Flick = userHead_flick
        self.isMine_Flick = isMine_flick
        self.time_Flick = time_flick
    }
}

/// 评论模型
class Comment_Flick: NSObject, Codable {
    
    /// 评论ID
    var commentId_Flick: Int
    
    /// 评论用户uid
    var commentUserId_Flick: Int
    
    /// 评论用户昵称
    var commentUserName_Flick: String
    
    /// 评论内容
    var commentContent_Flick: String
    
    /// 初始化
    init(commentId_Flick: Int,
         commentUserId_Flick: Int,
         commentUserName_Flick: String,
         commentContent_Flick: String) {
        self.commentId_Flick = commentId_Flick
        self.commentUserId_Flick = commentUserId_Flick
        self.commentUserName_Flick = commentUserName_Flick
        self.commentContent_Flick = commentContent_Flick
    }
}

// MARK: - 速记模型

/// 速记补充条目
/// 功能：对原速记记录的追加说明，独立时间戳，不可修改
class SpeedNoteSupplement_Flick: NSObject, Codable {
    /// 补充ID（UUID）
    var supplementId_Flick: String
    /// 补充内容
    var content_Flick: String
    /// 补充时间戳（秒）
    var createTime_Flick: Double

    init(content_Flick: String) {
        self.supplementId_Flick = UUID().uuidString
        self.content_Flick = content_Flick
        self.createTime_Flick = Date().timeIntervalSince1970
        super.init()
    }
}

/// 速记记录
/// 功能：自动锁定录入时间的瞬间思绪原始纪念，锁定后内容不可修改，仅可追加补充或整条删除
class SpeedNote_Flick: NSObject, Codable {
    /// 速记ID（UUID）
    var noteId_Flick: String
    /// 原始内容（锁定后不可修改）
    var content_Flick: String
    /// 创建时间戳（秒，自动记录）
    var createTime_Flick: Double
    /// 追加补充列表
    var supplements_Flick: [SpeedNoteSupplement_Flick]

    init(content_Flick: String) {
        self.noteId_Flick = UUID().uuidString
        self.content_Flick = content_Flick
        self.createTime_Flick = Date().timeIntervalSince1970
        self.supplements_Flick = []
        super.init()
    }
}

// MARK: - 官方半截碎念挑战模型

/// 官方半截碎念挑战
/// 功能：官方发布前半段文字作为挑战，社区用户可补全后半段（存入 completions_Flick），
///       completions_Flick 复用 Comment_Flick 结构，支持举报/删除
class HalfChallenge_Flick: NSObject, Codable {
    /// 挑战ID
    var challengeId_Flick: String
    /// 官方提供的前半段文字
    var firstHalf_Flick: String
    /// 挑战标签（如 Life / Love / Midnight）
    var tag_Flick: String
    /// 发布日期字符串（如 "Mar 28"）
    var publishDate_Flick: String
    /// 用户补全的后半段列表（复用 Comment_Flick）
    var completions_Flick: [Comment_Flick]

    init(challengeId_Flick: String,
         firstHalf_Flick: String,
         tag_Flick: String,
         publishDate_Flick: String,
         completions_Flick: [Comment_Flick] = []) {
        self.challengeId_Flick = challengeId_Flick
        self.firstHalf_Flick = firstHalf_Flick
        self.tag_Flick = tag_Flick
        self.publishDate_Flick = publishDate_Flick
        self.completions_Flick = completions_Flick
        super.init()
    }
}

// MARK: - 时间胶囊模型

/// 时间胶囊解锁时间枚举
enum CapsuleUnlockOption_Flick: Int, Codable, CaseIterable {
    case oneMonth_Flick   = 1
    case sixMonths_Flick  = 6
    case oneYear_Flick    = 12
    case threeYears_Flick = 36
    case fiveYears_Flick  = 60

    /// 显示文案
    var label_Flick: String {
        switch self {
        case .oneMonth_Flick:   return "1 Month"
        case .sixMonths_Flick:  return "6 Months"
        case .oneYear_Flick:    return "1 Year"
        case .threeYears_Flick: return "3 Years"
        case .fiveYears_Flick:  return "5 Years"
        }
    }
}

/// 时间胶囊
/// 功能：用户将当下碎念/灵感封存，设定未来解锁时间，到期前内容锁定，仅可删除整条
class TimeCapsule_Flick: NSObject, Codable {
    /// 胶囊ID（UUID）
    var capsuleId_Flick: String
    /// 封存内容
    var content_Flick: String
    /// 心情备注（可选）
    var moodNote_Flick: String
    /// 心情 Emoji
    var moodEmoji_Flick: String
    /// 解锁时间戳（秒）
    var unlockTime_Flick: Double
    /// 创建时间戳（秒）
    var createTime_Flick: Double

    /// 是否已解锁（到达解锁时间）
    var isUnlocked_Flick: Bool {
        return Date().timeIntervalSince1970 >= unlockTime_Flick
    }

    init(content_Flick: String,
         moodNote_Flick: String,
         moodEmoji_Flick: String,
         unlockOption_Flick: CapsuleUnlockOption_Flick) {
        self.capsuleId_Flick = UUID().uuidString
        self.content_Flick = content_Flick
        self.moodNote_Flick = moodNote_Flick
        self.moodEmoji_Flick = moodEmoji_Flick
        self.createTime_Flick = Date().timeIntervalSince1970
        // 按月数推算解锁时间（近似 30 天/月）
        let seconds = Double(unlockOption_Flick.rawValue) * 30 * 24 * 3600
        self.unlockTime_Flick = Date().timeIntervalSince1970 + seconds
        super.init()
    }
}
