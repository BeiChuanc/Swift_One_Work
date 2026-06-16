import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Ornit: NSObject, Codable {
    
    /// 用户ID
    var userId_Ornit: Int?
    
    /// 用户名字
    var userName_Ornit: String?
    
    /// 用户简介
    var userIntroduce_Ornit: String?
    
    /// 用户头像
    var userHead_Ornit: String?
    
    /// 用户媒体
    var userMedia_Ornit: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Ornit: [TitleModel_Ornit] = []

    /// 用户关注数
    var userFollow_Ornit: Int?

    /// 用户粉丝数
    var userFans_Ornit: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Ornit: Int? = nil,
         userName_Ornit: String? = nil,
         userIntroduce_Ornit: String? = nil,
         userHead_Ornit: String? = nil,
         userMedia_Ornit: [String]? = nil,
         userLike_Ornit: [TitleModel_Ornit] = [],
         userFollow_Ornit: Int? = nil,
         userFans_Ornit: Int? = nil) {
        self.userId_Ornit = userId_Ornit
        self.userName_Ornit = userName_Ornit
        self.userIntroduce_Ornit = userIntroduce_Ornit
        self.userHead_Ornit = userHead_Ornit
        self.userMedia_Ornit = userMedia_Ornit
        self.userLike_Ornit = userLike_Ornit
        self.userFollow_Ornit = userFollow_Ornit
        self.userFans_Ornit = userFans_Ornit
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Ornit: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Ornit: Int
    
    /// 拥有者ID
    var titleUserId_Ornit: Int
    
    /// 拥有者昵称
    var titleUserName_Ornit: String
    
    /// 帖子媒体
    var titleMeidas_Ornit: [String]
    
    /// 帖子标题
    var title_Ornit: String
    
    /// 帖子内容
    var titleContent_Ornit: String
    
    /// 帖子评论列表
    var reviews_Ornit: [Comment_Ornit]
    
    /// 喜欢个数
    var likes_Ornit: Int
    
    init(titleId_Ornit: Int,
         titleUserId_Ornit: Int,
         titleUserName_Ornit: String,
         titleMeidas_Ornit: [String],
         title_Ornit: String,
         titleContent_Ornit: String,
         reviews_Ornit: [Comment_Ornit],
         likes_Ornit: Int) {
        self.titleId_Ornit = titleId_Ornit
        self.titleUserId_Ornit = titleUserId_Ornit
        self.titleUserName_Ornit = titleUserName_Ornit
        self.titleMeidas_Ornit = titleMeidas_Ornit
        self.title_Ornit = title_Ornit
        self.titleContent_Ornit = titleContent_Ornit
        self.reviews_Ornit = reviews_Ornit
        self.likes_Ornit = likes_Ornit
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Ornit: NSObject, Codable {
    
    /// 用户ID
    var userId_Ornit: Int?
    
    /// 用户密码
    var userPwd_Ornit: String?
    
    /// 用户名称
    var userName_Ornit: String?
    
    /// 用户头像
    var userHead_Ornit: String?
    
    /// 用户简介
    var userIntroduce_Ornit: String?
    
    /// 用户发布帖子列表
    var userPosts_Ornit: [TitleModel_Ornit]
    
    /// 用户喜欢帖子列表
    var userLike_Ornit: [TitleModel_Ornit]

    /// 用户关注列表
    var userFollow_Ornit: [PrewUserModel_Ornit]

    /// 每日打卡日期列表（格式：yyyy-MM-dd）
    var checkInDates_Ornit: [String]

    /// 观鸟记录列表（用户自定义添加）
    var birdObservations_Ornit: [BirdObservation_Ornit]
    
    /// 初始化
    init(userId_Ornit: Int? = nil,
         userPwd_Ornit: String? = nil,
         userName_Ornit: String? = nil,
         userHead_Ornit: String? = nil,
         userIntroduce_Ornit: String? = nil,
         userPosts_Ornit: [TitleModel_Ornit],
         userLike_Ornit: [TitleModel_Ornit],
         userFollow_Ornit: [PrewUserModel_Ornit],
         checkInDates_Ornit: [String] = [],
         birdObservations_Ornit: [BirdObservation_Ornit] = []) {
        self.userId_Ornit = userId_Ornit
        self.userPwd_Ornit = userPwd_Ornit
        self.userName_Ornit = userName_Ornit
        self.userHead_Ornit = userHead_Ornit
        self.userIntroduce_Ornit = userIntroduce_Ornit
        self.userPosts_Ornit = userPosts_Ornit
        self.userLike_Ornit = userLike_Ornit
        self.userFollow_Ornit = userFollow_Ornit
        self.checkInDates_Ornit = checkInDates_Ornit
        self.birdObservations_Ornit = birdObservations_Ornit
    }
}

/// 消息数据模型
class MessageModel_Ornit: Codable {
    
    /// 消息ID
    var messageId_Ornit: Int?
    
    /// 消息内容
    var content_Ornit: String?
    
    /// 用户头像
    var userHead_Ornit: String?
    
    /// 是否是我发送的
    var isMine_Ornit: Bool?
    
    /// 消息时间
    var time_Ornit: String?
    
    /// 初始化
    init(messageId_ornit: Int? = nil,
         content_ornit: String? = nil,
         userHead_ornit: String? = nil,
         isMine_ornit: Bool? = nil,
         time_ornit: String? = nil) {
        self.messageId_Ornit = messageId_ornit
        self.content_Ornit = content_ornit
        self.userHead_Ornit = userHead_ornit
        self.isMine_Ornit = isMine_ornit
        self.time_Ornit = time_ornit
    }
}

/// 评论模型
class Comment_Ornit: NSObject, Codable {
    
    /// 评论ID
    var commentId_Ornit: Int
    
    /// 评论用户uid
    var commentUserId_Ornit: Int
    
    /// 评论用户昵称
    var commentUserName_Ornit: String
    
    /// 评论内容
    var commentContent_Ornit: String
    
    /// 初始化
    init(commentId_Ornit: Int,
         commentUserId_Ornit: Int,
         commentUserName_Ornit: String,
         commentContent_Ornit: String) {
        self.commentId_Ornit = commentId_Ornit
        self.commentUserId_Ornit = commentUserId_Ornit
        self.commentUserName_Ornit = commentUserName_Ornit
        self.commentContent_Ornit = commentContent_Ornit
    }
}

// MARK: - 观鸟记录模型

/// 用户自定义观鸟记录模型
/// 功能：记录用户在某天某地观测到的鸟种及数量
class BirdObservation_Ornit: NSObject, Codable {

    /// 记录 ID
    var observationId_Ornit: Int

    /// 鸟种名称（用户自填）
    var birdName_Ornit: String

    /// 观测数量
    var count_Ornit: Int

    /// 观测日期（yyyy-MM-dd 格式）
    var observeDate_Ornit: String

    /// 观测地点（可选）
    var location_Ornit: String?

    init(observationId_Ornit: Int,
         birdName_Ornit: String,
         count_Ornit: Int,
         observeDate_Ornit: String,
         location_Ornit: String? = nil) {
        self.observationId_Ornit = observationId_Ornit
        self.birdName_Ornit = birdName_Ornit
        self.count_Ornit = count_Ornit
        self.observeDate_Ornit = observeDate_Ornit
        self.location_Ornit = location_Ornit
    }
}

// MARK: - 四季专题模型

/// 官方四季鸟类专题讨论模型
/// 功能：存储专题基本信息（标题、描述、配色）和用户评论列表
class SeasonalTopic_Ornit: NSObject, Codable {

    /// 专题 ID
    var topicId_Ornit: Int

    /// 季节名称（Spring / Summer / Autumn / Winter）
    var season_Ornit: String

    /// 专题标题
    var title_Ornit: String

    /// 专题描述
    var topicDescription_Ornit: String

    /// 卡片渐变起始色（十六进制）
    var gradientStart_Ornit: String

    /// 卡片渐变结束色（十六进制）
    var gradientEnd_Ornit: String

    /// 装饰图标名称（SF Symbol）
    var iconName_Ornit: String

    /// 专题评论列表
    var comments_Ornit: [Comment_Ornit]

    init(topicId_Ornit: Int,
         season_Ornit: String,
         title_Ornit: String,
         topicDescription_Ornit: String,
         gradientStart_Ornit: String,
         gradientEnd_Ornit: String,
         iconName_Ornit: String,
         comments_Ornit: [Comment_Ornit] = []) {
        self.topicId_Ornit = topicId_Ornit
        self.season_Ornit = season_Ornit
        self.title_Ornit = title_Ornit
        self.topicDescription_Ornit = topicDescription_Ornit
        self.gradientStart_Ornit = gradientStart_Ornit
        self.gradientEnd_Ornit = gradientEnd_Ornit
        self.iconName_Ornit = iconName_Ornit
        self.comments_Ornit = comments_Ornit
    }
}

// MARK: - 技巧卡片模型

/// 观鸟技巧卡片模型（静态展示数据，无需 Codable）
/// 功能：存储摄影技巧、观测经验、路线规划建议
class TipCard_Ornit: NSObject {

    /// 卡片 ID
    var tipId_Ornit: Int

    /// 分类（Photography / Observation / Route）
    var category_Ornit: String

    /// 卡片标题
    var title_Ornit: String

    /// 卡片详细内容
    var content_Ornit: String

    /// 装饰图标（SF Symbol）
    var iconName_Ornit: String

    /// 卡片强调色（十六进制）
    var accentColor_Ornit: String

    init(tipId_Ornit: Int,
         category_Ornit: String,
         title_Ornit: String,
         content_Ornit: String,
         iconName_Ornit: String,
         accentColor_Ornit: String) {
        self.tipId_Ornit = tipId_Ornit
        self.category_Ornit = category_Ornit
        self.title_Ornit = title_Ornit
        self.content_Ornit = content_Ornit
        self.iconName_Ornit = iconName_Ornit
        self.accentColor_Ornit = accentColor_Ornit
    }
}

/// 商店模型
class StoreModel_Ornit: NSObject {
    
    /// ID编号
    var id_Ornit: Int?
    
    /// 商品ID
    var goodsId_Ornit: String?
    
    /// 商品名字
    var goodsName_Ornit: String?
    
    /// 商品价格
    var goodsPrice_Ornit: String?
    
    /// 是否顶部商品
    var goodIsTop_Ornit: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Ornit: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Ornit: Bool?
    
    init(id_Ornit: Int? = nil,
         goodsId_Ornit: String? = nil,
         goodsName_Ornit: String? = nil,
         goodsPrice_Ornit: String? = nil,
         goodIsTop_Ornit: Bool? = false,
         goodIsLimit_Ornit: Bool? = false,
         goodIsVIP_Ornit: Bool? = false) {
        self.id_Ornit = id_Ornit
        self.goodsId_Ornit = goodsId_Ornit
        self.goodsName_Ornit = goodsName_Ornit
        self.goodsPrice_Ornit = goodsPrice_Ornit
        self.goodIsTop_Ornit = goodIsTop_Ornit
        self.goodIsSpecial_Ornit = goodIsLimit_Ornit
        self.goodIsVIP_Ornit = goodIsVIP_Ornit
        super.init()
    }
}
