import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Lumia: NSObject, Codable {
    
    /// 用户ID
    var userId_Lumia: Int?
    
    /// 用户名字
    var userName_Lumia: String?
    
    /// 用户简介
    var userIntroduce_Lumia: String?
    
    /// 用户头像
    var userHead_Lumia: String?
    
    /// 用户媒体
    var userMedia_Lumia: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Lumia: [TitleModel_Lumia] = []

    /// 用户关注数
    var userFollow_Lumia: Int?

    /// 用户粉丝数
    var userFans_Lumia: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Lumia: Int? = nil,
         userName_Lumia: String? = nil,
         userIntroduce_Lumia: String? = nil,
         userHead_Lumia: String? = nil,
         userMedia_Lumia: [String]? = nil,
         userLike_Lumia: [TitleModel_Lumia] = [],
         userFollow_Lumia: Int? = nil,
         userFans_Lumia: Int? = nil) {
        self.userId_Lumia = userId_Lumia
        self.userName_Lumia = userName_Lumia
        self.userIntroduce_Lumia = userIntroduce_Lumia
        self.userHead_Lumia = userHead_Lumia
        self.userMedia_Lumia = userMedia_Lumia
        self.userLike_Lumia = userLike_Lumia
        self.userFollow_Lumia = userFollow_Lumia
        self.userFans_Lumia = userFans_Lumia
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Lumia: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Lumia: Int
    
    /// 拥有者ID
    var titleUserId_Lumia: Int
    
    /// 拥有者昵称
    var titleUserName_Lumia: String
    
    /// 帖子媒体
    var titleMeidas_Lumia: [String]
    
    /// 帖子标题
    var title_Lumia: String
    
    /// 帖子内容
    var titleContent_Lumia: String
    
    /// 帖子评论列表
    var reviews_Lumia: [Comment_Lumia]
    
    /// 喜欢个数
    var likes_Lumia: Int
    
    init(titleId_Lumia: Int,
         titleUserId_Lumia: Int,
         titleUserName_Lumia: String,
         titleMeidas_Lumia: [String],
         title_Lumia: String,
         titleContent_Lumia: String,
         reviews_Lumia: [Comment_Lumia],
         likes_Lumia: Int) {
        self.titleId_Lumia = titleId_Lumia
        self.titleUserId_Lumia = titleUserId_Lumia
        self.titleUserName_Lumia = titleUserName_Lumia
        self.titleMeidas_Lumia = titleMeidas_Lumia
        self.title_Lumia = title_Lumia
        self.titleContent_Lumia = titleContent_Lumia
        self.reviews_Lumia = reviews_Lumia
        self.likes_Lumia = likes_Lumia
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Lumia: NSObject, Codable {
    
    /// 用户ID
    var userId_Lumia: Int?
    
    /// 用户密码
    var userPwd_Lumia: String?
    
    /// 用户名称
    var userName_Lumia: String?
    
    /// 用户头像
    var userHead_Lumia: String?

    /// 用户个人简介
    var userIntroduce_Lumia: String?
    
    /// 用户发布帖子列表
    var userPosts_Lumia: [TitleModel_Lumia]
    
    /// 用户喜欢帖子列表
    var userLike_Lumia: [TitleModel_Lumia]

    /// 用户关注列表
    var userFollow_Lumia: [PrewUserModel_Lumia]

    /// 胶片卷列表（包含今日进行中的卷和历史已冲洗的卷）
    var filmRolls_Lumia: [FilmRoll_Lumia]

    /// 时光胶囊列表
    var capsules_Lumia: [TimeCapsule_Lumia]

    /// 主题征集提交列表
    var themeSubmissions_Lumia: [ThemeSubmission_Lumia]
    
    /// 初始化
    init(userId_Lumia: Int? = nil,
         userPwd_Lumia: String? = nil,
         userName_Lumia: String? = nil,
         userHead_Lumia: String? = nil,
         userIntroduce_Lumia: String? = nil,
         userPosts_Lumia: [TitleModel_Lumia],
         userLike_Lumia: [TitleModel_Lumia],
         userFollow_Lumia: [PrewUserModel_Lumia],
         filmRolls_Lumia: [FilmRoll_Lumia] = [],
         capsules_Lumia: [TimeCapsule_Lumia] = [],
         themeSubmissions_Lumia: [ThemeSubmission_Lumia] = []) {
        self.userId_Lumia = userId_Lumia
        self.userPwd_Lumia = userPwd_Lumia
        self.userName_Lumia = userName_Lumia
        self.userHead_Lumia = userHead_Lumia
        self.userIntroduce_Lumia = userIntroduce_Lumia
        self.userPosts_Lumia = userPosts_Lumia
        self.userLike_Lumia = userLike_Lumia
        self.userFollow_Lumia = userFollow_Lumia
        self.filmRolls_Lumia = filmRolls_Lumia
        self.capsules_Lumia = capsules_Lumia
        self.themeSubmissions_Lumia = themeSubmissions_Lumia
    }
}

/// 消息数据模型
class MessageModel_Lumia: Codable {
    
    /// 消息ID
    var messageId_Lumia: Int?
    
    /// 消息内容
    var content_Lumia: String?
    
    /// 用户头像
    var userHead_Lumia: String?
    
    /// 是否是我发送的
    var isMine_Lumia: Bool?
    
    /// 消息时间
    var time_Lumia: String?
    
    /// 初始化
    init(messageId_lumia: Int? = nil,
         content_lumia: String? = nil,
         userHead_lumia: String? = nil,
         isMine_lumia: Bool? = nil,
         time_lumia: String? = nil) {
        self.messageId_Lumia = messageId_lumia
        self.content_Lumia = content_lumia
        self.userHead_Lumia = userHead_lumia
        self.isMine_Lumia = isMine_lumia
        self.time_Lumia = time_lumia
    }
}

/// 评论模型
class Comment_Lumia: NSObject, Codable {
    
    /// 评论ID
    var commentId_Lumia: Int
    
    /// 评论用户uid
    var commentUserId_Lumia: Int
    
    /// 评论用户昵称
    var commentUserName_Lumia: String
    
    /// 评论内容
    var commentContent_Lumia: String
    
    /// 初始化
    init(commentId_Lumia: Int,
         commentUserId_Lumia: Int,
         commentUserName_Lumia: String,
         commentContent_Lumia: String) {
        self.commentId_Lumia = commentId_Lumia
        self.commentUserId_Lumia = commentUserId_Lumia
        self.commentUserName_Lumia = commentUserName_Lumia
        self.commentContent_Lumia = commentContent_Lumia
    }
}

/// 商店模型
class StoreModel_Lumia: NSObject {
    
    /// ID编号
    var id_Lumia: Int?
    
    /// 商品ID
    var goodsId_Lumia: String?
    
    /// 商品名字
    var goodsName_Lumia: String?
    
    /// 商品价格
    var goodsPrice_Lumia: String?
    
    /// 是否顶部商品
    var goodIsTop_Lumia: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Lumia: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Lumia: Bool?
    
    init(id_Lumia: Int? = nil,
         goodsId_Lumia: String? = nil,
         goodsName_Lumia: String? = nil,
         goodsPrice_Lumia: String? = nil,
         goodIsTop_Lumia: Bool? = false,
         goodIsLimit_Lumia: Bool? = false,
         goodIsVIP_Lumia: Bool? = false) {
        self.id_Lumia = id_Lumia
        self.goodsId_Lumia = goodsId_Lumia
        self.goodsName_Lumia = goodsName_Lumia
        self.goodsPrice_Lumia = goodsPrice_Lumia
        self.goodIsTop_Lumia = goodIsTop_Lumia
        self.goodIsSpecial_Lumia = goodIsLimit_Lumia
        self.goodIsVIP_Lumia = goodIsVIP_Lumia
        super.init()
    }
}

// MARK: - 胶片功能模型

/// 胶片单帧（代表一张照片，24帧构成一卷）
class FilmFrame_Lumia: NSObject, Codable {
    var frameIndex_Lumia: Int
    var imagePath_Lumia: String?
    var note_Lumia: String?
    var takenAt_Lumia: String

    var isExposed_Lumia: Bool { imagePath_Lumia != nil }

    init(frameIndex_Lumia: Int, imagePath_Lumia: String? = nil, note_Lumia: String? = nil) {
        self.frameIndex_Lumia = frameIndex_Lumia
        self.imagePath_Lumia = imagePath_Lumia
        self.note_Lumia = note_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "HH:mm"
        self.takenAt_Lumia = f_Lumia.string(from: Date())
    }
}

/// 胶片卷日记（24帧/卷，代表一天或一个主题的拍摄记录）
class FilmRoll_Lumia: NSObject, Codable {
    var rollId_Lumia: Int
    var rollName_Lumia: String
    var dateString_Lumia: String
    var frames_Lumia: [FilmFrame_Lumia]
    var maxFrames_Lumia: Int
    var isDeveloped_Lumia: Bool

    var exposedCount_Lumia: Int { frames_Lumia.filter { $0.isExposed_Lumia }.count }
    var isFull_Lumia: Bool { exposedCount_Lumia >= maxFrames_Lumia }

    init(rollId_Lumia: Int, rollName_Lumia: String, dateString_Lumia: String, maxFrames_Lumia: Int = 24) {
        self.rollId_Lumia = rollId_Lumia
        self.rollName_Lumia = rollName_Lumia
        self.dateString_Lumia = dateString_Lumia
        self.maxFrames_Lumia = maxFrames_Lumia
        self.frames_Lumia = (1...maxFrames_Lumia).map { FilmFrame_Lumia(frameIndex_Lumia: $0) }
        self.isDeveloped_Lumia = false
    }
}

/// 时光胶囊（用户设定解锁时间后才可查看的照片+留言）
class TimeCapsule_Lumia: NSObject, Codable {
    var capsuleId_Lumia: Int
    var imagePath_Lumia: String?
    var message_Lumia: String
    var unlockDateString_Lumia: String
    var createdAt_Lumia: String
    var isRevealed_Lumia: Bool

    var canReveal_Lumia: Bool {
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd"
        guard let unlockDate_Lumia = f_Lumia.date(from: unlockDateString_Lumia) else { return false }
        return Date() >= unlockDate_Lumia
    }

    init(capsuleId_Lumia: Int, imagePath_Lumia: String? = nil, message_Lumia: String, unlockDateString_Lumia: String) {
        self.capsuleId_Lumia = capsuleId_Lumia
        self.imagePath_Lumia = imagePath_Lumia
        self.message_Lumia = message_Lumia
        self.unlockDateString_Lumia = unlockDateString_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd"
        self.createdAt_Lumia = f_Lumia.string(from: Date())
        self.isRevealed_Lumia = false
    }
}

/// 主题征集提交
class ThemeSubmission_Lumia: NSObject, Codable {
    var submissionId_Lumia: Int
    var themeId_Lumia: Int
    var imagePath_Lumia: String?
    var descText_Lumia: String
    var submittedAt_Lumia: String

    init(submissionId_Lumia: Int, themeId_Lumia: Int, imagePath_Lumia: String? = nil, descText_Lumia: String) {
        self.submissionId_Lumia = submissionId_Lumia
        self.themeId_Lumia = themeId_Lumia
        self.imagePath_Lumia = imagePath_Lumia
        self.descText_Lumia = descText_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd HH:mm"
        self.submittedAt_Lumia = f_Lumia.string(from: Date())
    }
}

/// 主题胶片展（每周一个征集主题）
struct FilmTheme_Lumia: Codable {
    var themeId_Lumia: Int
    var themeTitle_Lumia: String
    var themeDesc_Lumia: String
    var weekLabel_Lumia: String
    var accentColor_Lumia: String
}

/// 主题讨论区评论（用户在主题下发布的评论）
class ThemeDiscussionComment_Lumia: NSObject, Codable {
    var commentId_Lumia: Int
    var userId_Lumia: Int
    var userName_Lumia: String
    var userHead_Lumia: String?
    var content_Lumia: String
    /// 发布时间（"HH:mm"）
    var createdAt_Lumia: String

    init(commentId_Lumia: Int, userId_Lumia: Int, userName_Lumia: String,
         userHead_Lumia: String? = nil, content_Lumia: String) {
        self.commentId_Lumia = commentId_Lumia
        self.userId_Lumia = userId_Lumia
        self.userName_Lumia = userName_Lumia
        self.userHead_Lumia = userHead_Lumia
        self.content_Lumia = content_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "HH:mm"
        self.createdAt_Lumia = f_Lumia.string(from: Date())
    }
}
