import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Somnia: NSObject, Codable {
    
    /// 用户ID
    var userId_Somnia: Int?
    
    /// 用户名字
    var userName_Somnia: String?
    
    /// 用户简介
    var userIntroduce_Somnia: String?
    
    /// 用户头像
    var userHead_Somnia: String?
    
    /// 用户媒体
    var userMedia_Somnia: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Somnia: [TitleModel_Somnia] = []

    /// 用户关注数
    var userFollow_Somnia: Int?

    /// 用户粉丝数
    var userFans_Somnia: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Somnia: Int? = nil,
         userName_Somnia: String? = nil,
         userIntroduce_Somnia: String? = nil,
         userHead_Somnia: String? = nil,
         userMedia_Somnia: [String]? = nil,
         userLike_Somnia: [TitleModel_Somnia] = [],
         userFollow_Somnia: Int? = nil,
         userFans_Somnia: Int? = nil) {
        self.userId_Somnia = userId_Somnia
        self.userName_Somnia = userName_Somnia
        self.userIntroduce_Somnia = userIntroduce_Somnia
        self.userHead_Somnia = userHead_Somnia
        self.userMedia_Somnia = userMedia_Somnia
        self.userLike_Somnia = userLike_Somnia
        self.userFollow_Somnia = userFollow_Somnia
        self.userFans_Somnia = userFans_Somnia
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Somnia: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Somnia: Int
    
    /// 拥有者ID
    var titleUserId_Somnia: Int
    
    /// 拥有者昵称
    var titleUserName_Somnia: String
    
    /// 帖子媒体
    var titleMeidas_Somnia: [String]
    
    /// 帖子标题
    var title_Somnia: String
    
    /// 帖子内容
    var titleContent_Somnia: String
    
    /// 帖子评论列表
    var reviews_Somnia: [Comment_Somnia]
    
    /// 喜欢个数
    var likes_Somnia: Int
    
    init(titleId_Somnia: Int,
         titleUserId_Somnia: Int,
         titleUserName_Somnia: String,
         titleMeidas_Somnia: [String],
         title_Somnia: String,
         titleContent_Somnia: String,
         reviews_Somnia: [Comment_Somnia],
         likes_Somnia: Int) {
        self.titleId_Somnia = titleId_Somnia
        self.titleUserId_Somnia = titleUserId_Somnia
        self.titleUserName_Somnia = titleUserName_Somnia
        self.titleMeidas_Somnia = titleMeidas_Somnia
        self.title_Somnia = title_Somnia
        self.titleContent_Somnia = titleContent_Somnia
        self.reviews_Somnia = reviews_Somnia
        self.likes_Somnia = likes_Somnia
    }
    
}

/// 登录用户数据模型
/// 拓展了梦境相关数据字段：梦境册、梦境记录、梦物图腾
/// 这三个字段作为用户个人梦境数据的载体，由 DreamViewModel_Somnia 负责读写
class LoginUserModel_Somnia: NSObject, Codable {
    
    /// 用户ID
    var userId_Somnia: Int?
    
    /// 用户密码
    var userPwd_Somnia: String?
    
    /// 用户名称
    var userName_Somnia: String?
    
    /// 用户头像
    var userHead_Somnia: String?
    
    /// 用户简介
    var userIntroduce_Somnia: String?
    
    /// 用户发布帖子列表
    var userPosts_Somnia: [TitleModel_Somnia]
    
    /// 用户喜欢帖子列表
    var userLike_Somnia: [TitleModel_Somnia]

    /// 用户关注列表
    var userFollow_Somnia: [PrewUserModel_Somnia]

    // MARK: - 梦境数据字段

    /// 用户创建的梦境册列表（自定义专属梦境册）
    var userDreamBooks_Somnia: [DreamBookModel_Somnia]

    /// 用户的梦境记录列表（含梦痕时间戳与梦系列信息）
    var userDreamRecords_Somnia: [DreamRecordModel_Somnia]

    /// 用户收集的梦物图腾列表（按出现次数排序）
    var userDreamTotems_Somnia: [DreamTotemModel_Somnia]

    /// 用户每日打卡时间戳列表（全局，每天最多记录一次，用于计算连续打卡天数）
    var dailyCheckInDates_Somnia: [Double]
    
    /// 初始化
    /// - Parameters:
    ///   - userDreamBooks_Somnia: 梦境册，默认空
    ///   - userDreamRecords_Somnia: 梦境记录，默认空
    ///   - userDreamTotems_Somnia: 梦物图腾，默认空
    ///   - dailyCheckInDates_Somnia: 每日打卡时间戳，默认空
    init(userId_Somnia: Int? = nil,
         userPwd_Somnia: String? = nil,
         userName_Somnia: String? = nil,
         userHead_Somnia: String? = nil,
         userIntroduce_Somnia: String? = nil,
         userPosts_Somnia: [TitleModel_Somnia] = [],
         userLike_Somnia: [TitleModel_Somnia] = [],
         userFollow_Somnia: [PrewUserModel_Somnia] = [],
         userDreamBooks_Somnia: [DreamBookModel_Somnia] = [],
         userDreamRecords_Somnia: [DreamRecordModel_Somnia] = [],
         userDreamTotems_Somnia: [DreamTotemModel_Somnia] = [],
         dailyCheckInDates_Somnia: [Double] = []) {
        self.userId_Somnia = userId_Somnia
        self.userPwd_Somnia = userPwd_Somnia
        self.userName_Somnia = userName_Somnia
        self.userHead_Somnia = userHead_Somnia
        self.userIntroduce_Somnia = userIntroduce_Somnia
        self.userPosts_Somnia = userPosts_Somnia
        self.userLike_Somnia = userLike_Somnia
        self.userFollow_Somnia = userFollow_Somnia
        self.userDreamBooks_Somnia = userDreamBooks_Somnia
        self.userDreamRecords_Somnia = userDreamRecords_Somnia
        self.userDreamTotems_Somnia = userDreamTotems_Somnia
        self.dailyCheckInDates_Somnia = dailyCheckInDates_Somnia
    }
}

/// 消息数据模型
class MessageModel_Somnia: Codable {
    
    /// 消息ID
    var messageId_Somnia: Int?
    
    /// 消息内容
    var content_Somnia: String?
    
    /// 用户头像
    var userHead_Somnia: String?
    
    /// 是否是我发送的
    var isMine_Somnia: Bool?
    
    /// 消息时间
    var time_Somnia: String?
    
    /// 初始化
    init(messageId_somnia: Int? = nil,
         content_somnia: String? = nil,
         userHead_somnia: String? = nil,
         isMine_somnia: Bool? = nil,
         time_somnia: String? = nil) {
        self.messageId_Somnia = messageId_somnia
        self.content_Somnia = content_somnia
        self.userHead_Somnia = userHead_somnia
        self.isMine_Somnia = isMine_somnia
        self.time_Somnia = time_somnia
    }
}

/// 评论模型
class Comment_Somnia: NSObject, Codable {
    
    /// 评论ID
    var commentId_Somnia: Int
    
    /// 评论用户uid
    var commentUserId_Somnia: Int
    
    /// 评论用户昵称
    var commentUserName_Somnia: String
    
    /// 评论内容
    var commentContent_Somnia: String
    
    /// 初始化
    init(commentId_Somnia: Int,
         commentUserId_Somnia: Int,
         commentUserName_Somnia: String,
         commentContent_Somnia: String) {
        self.commentId_Somnia = commentId_Somnia
        self.commentUserId_Somnia = commentUserId_Somnia
        self.commentUserName_Somnia = commentUserName_Somnia
        self.commentContent_Somnia = commentContent_Somnia
    }
}

// MARK: - 梦境相关模型

/// 梦境册模型
/// 核心功能：用户自定义专属梦境收纳册（如"灵感梦境册"、"治愈好梦册"）
/// 关键属性：bookId、bookTitle、主题色、图标、梦境数量
class DreamBookModel_Somnia: NSObject, Codable {

    /// 梦境册唯一ID
    var bookId_Somnia: String

    /// 梦境册名称
    var bookTitle_Somnia: String

    /// 封面图标（SF Symbol 名称）
    var bookIcon_Somnia: String

    /// 主题颜色十六进制字符串
    var bookColorHex_Somnia: String

    /// 创建时间戳
    var createdAt_Somnia: Double

    /// 已收录梦境数量
    var dreamCount_Somnia: Int

    /// 打卡日期时间戳列表（每天0点后仅记录一次，用于计算连续打卡天数）
    var checkInDates_Somnia: [Double]

    /// 初始化
    /// - Parameters:
    ///   - bookId_Somnia: 唯一ID
    ///   - bookTitle_Somnia: 册名
    ///   - bookIcon_Somnia: SF Symbol 图标名
    ///   - bookColorHex_Somnia: 主题色十六进制
    ///   - createdAt_Somnia: 创建时间戳，默认当前时间
    ///   - dreamCount_Somnia: 梦境数量，默认0
    ///   - checkInDates_Somnia: 历史打卡日期时间戳，默认空
    init(bookId_Somnia: String,
         bookTitle_Somnia: String,
         bookIcon_Somnia: String,
         bookColorHex_Somnia: String,
         createdAt_Somnia: Double = Date().timeIntervalSince1970,
         dreamCount_Somnia: Int = 0,
         checkInDates_Somnia: [Double] = []) {
        self.bookId_Somnia = bookId_Somnia
        self.bookTitle_Somnia = bookTitle_Somnia
        self.bookIcon_Somnia = bookIcon_Somnia
        self.bookColorHex_Somnia = bookColorHex_Somnia
        self.createdAt_Somnia = createdAt_Somnia
        self.dreamCount_Somnia = dreamCount_Somnia
        self.checkInDates_Somnia = checkInDates_Somnia
        super.init()
    }
}

/// 梦物类型枚举
/// 人物 / 动物 / 物品 / 场景
enum DreamTotemType_Somnia: String, Codable {
    case person_Somnia = "person"
    case animal_Somnia = "animal"
    case object_Somnia = "object"
    case scene_Somnia  = "scene"
}

/// 梦物模型
/// 核心功能：记录梦里反复出现的人 / 动物 / 物品 / 场景，自动累计出现次数和时间线
/// 关键属性：名称、类型、出现次数、首次/末次出现时间
class DreamTotemModel_Somnia: NSObject, Codable {

    /// 梦物唯一ID
    var totemId_Somnia: String

    /// 梦物名称
    var name_Somnia: String

    /// 梦物类型
    var type_Somnia: DreamTotemType_Somnia

    /// 出现次数（集邮计数）
    var appearCount_Somnia: Int

    /// 首次出现时间戳
    var firstSeenTimestamp_Somnia: Double

    /// 最近出现时间戳
    var lastSeenTimestamp_Somnia: Double

    /// 展示图标（Emoji 或 SF Symbol）
    var icon_Somnia: String

    /// 初始化
    init(totemId_Somnia: String,
         name_Somnia: String,
         type_Somnia: DreamTotemType_Somnia,
         appearCount_Somnia: Int,
         firstSeenTimestamp_Somnia: Double,
         lastSeenTimestamp_Somnia: Double,
         icon_Somnia: String) {
        self.totemId_Somnia = totemId_Somnia
        self.name_Somnia = name_Somnia
        self.type_Somnia = type_Somnia
        self.appearCount_Somnia = appearCount_Somnia
        self.firstSeenTimestamp_Somnia = firstSeenTimestamp_Somnia
        self.lastSeenTimestamp_Somnia = lastSeenTimestamp_Somnia
        self.icon_Somnia = icon_Somnia
        super.init()
    }
}

/// 梦境记录模型
/// 核心功能：存储单条梦境内容，自动生成「梦痕时间戳」（入睡时间 + 月亮相位 + 情绪关键词）
/// 支持「续梦」功能，通过 seriesId 将相关梦境串联成梦系列
/// 支持噩梦标记与「不想再梦」标记
class DreamRecordModel_Somnia: NSObject, Codable {

    /// 记录唯一ID
    var recordId_Somnia: String

    /// 所属梦境册ID
    var bookId_Somnia: String

    /// 梦境内容
    var content_Somnia: String

    /// 梦痕时间戳 - 入睡时间（不可修改，自动记录）
    var sleepTime_Somnia: String

    /// 梦痕时间戳 - 月亮相位（不可修改，自动计算）
    var moonPhase_Somnia: String

    /// 梦痕时间戳 - 情绪关键词（不可修改，用户创建时填写后锁定）
    var emotionKeyword_Somnia: String

    /// 记录时间戳
    var recordTimestamp_Somnia: Double

    /// 梦系列ID（续梦时设置，null 表示独立梦境）
    var seriesId_Somnia: String?

    /// 续梦源记录ID
    var parentRecordId_Somnia: String?

    /// 是否为噩梦
    var isNightmare_Somnia: Bool

    /// 是否标记为「不想再梦」
    var isDontDream_Somnia: Bool

    /// 本梦出现的梦物标签列表（用于自动收集梦物）
    var totemTags_Somnia: [String]

    /// 初始化
    init(recordId_Somnia: String,
         bookId_Somnia: String,
         content_Somnia: String,
         sleepTime_Somnia: String,
         moonPhase_Somnia: String,
         emotionKeyword_Somnia: String,
         recordTimestamp_Somnia: Double,
         seriesId_Somnia: String? = nil,
         parentRecordId_Somnia: String? = nil,
         isNightmare_Somnia: Bool = false,
         isDontDream_Somnia: Bool = false,
         totemTags_Somnia: [String] = []) {
        self.recordId_Somnia = recordId_Somnia
        self.bookId_Somnia = bookId_Somnia
        self.content_Somnia = content_Somnia
        self.sleepTime_Somnia = sleepTime_Somnia
        self.moonPhase_Somnia = moonPhase_Somnia
        self.emotionKeyword_Somnia = emotionKeyword_Somnia
        self.recordTimestamp_Somnia = recordTimestamp_Somnia
        self.seriesId_Somnia = seriesId_Somnia
        self.parentRecordId_Somnia = parentRecordId_Somnia
        self.isNightmare_Somnia = isNightmare_Somnia
        self.isDontDream_Somnia = isDontDream_Somnia
        self.totemTags_Somnia = totemTags_Somnia
        super.init()
    }
}

/// 商店模型
class StoreModel_Somnia: NSObject {
    
    /// ID编号
    var id_Somnia: Int?
    
    /// 商品ID
    var goodsId_Somnia: String?
    
    /// 商品名字
    var goodsName_Somnia: String?
    
    /// 商品价格
    var goodsPrice_Somnia: String?
    
    /// 是否顶部商品
    var goodIsTop_Somnia: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Somnia: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Somnia: Bool?
    
    init(id_Somnia: Int? = nil,
         goodsId_Somnia: String? = nil,
         goodsName_Somnia: String? = nil,
         goodsPrice_Somnia: String? = nil,
         goodIsTop_Somnia: Bool? = false,
         goodIsLimit_Somnia: Bool? = false,
         goodIsVIP_Somnia: Bool? = false) {
        self.id_Somnia = id_Somnia
        self.goodsId_Somnia = goodsId_Somnia
        self.goodsName_Somnia = goodsName_Somnia
        self.goodsPrice_Somnia = goodsPrice_Somnia
        self.goodIsTop_Somnia = goodIsTop_Somnia
        self.goodIsSpecial_Somnia = goodIsLimit_Somnia
        self.goodIsVIP_Somnia = goodIsVIP_Somnia
        super.init()
    }
}
