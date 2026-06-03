import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Bague: NSObject, Codable {
    
    /// 用户ID
    var userId_Bague: Int?
    
    /// 用户名字
    var userName_Bague: String?
    
    /// 用户简介
    var userIntroduce_Bague: String?
    
    /// 用户头像
    var userHead_Bague: String?
    
    /// 用户媒体
    var userMedia_Bague: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Bague: [TitleModel_Bague] = []

    /// 用户关注数
    var userFollow_Bague: Int?

    /// 用户粉丝数
    var userFans_Bague: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Bague: Int? = nil,
         userName_Bague: String? = nil,
         userIntroduce_Bague: String? = nil,
         userHead_Bague: String? = nil,
         userMedia_Bague: [String]? = nil,
         userLike_Bague: [TitleModel_Bague] = [],
         userFollow_Bague: Int? = nil,
         userFans_Bague: Int? = nil) {
        self.userId_Bague = userId_Bague
        self.userName_Bague = userName_Bague
        self.userIntroduce_Bague = userIntroduce_Bague
        self.userHead_Bague = userHead_Bague
        self.userMedia_Bague = userMedia_Bague
        self.userLike_Bague = userLike_Bague
        self.userFollow_Bague = userFollow_Bague
        self.userFans_Bague = userFans_Bague
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Bague: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Bague: Int
    
    /// 拥有者ID
    var titleUserId_Bague: Int
    
    /// 拥有者昵称
    var titleUserName_Bague: String
    
    /// 帖子媒体
    var titleMeidas_Bague: [String]
    
    /// 帖子标题
    var title_Bague: String
    
    /// 帖子内容
    var titleContent_Bague: String
    
    /// 帖子评论列表
    var reviews_Bague: [Comment_Bague]
    
    /// 喜欢个数
    var likes_Bague: Int
    
    init(titleId_Bague: Int,
         titleUserId_Bague: Int,
         titleUserName_Bague: String,
         titleMeidas_Bague: [String],
         title_Bague: String,
         titleContent_Bague: String,
         reviews_Bague: [Comment_Bague],
         likes_Bague: Int) {
        self.titleId_Bague = titleId_Bague
        self.titleUserId_Bague = titleUserId_Bague
        self.titleUserName_Bague = titleUserName_Bague
        self.titleMeidas_Bague = titleMeidas_Bague
        self.title_Bague = title_Bague
        self.titleContent_Bague = titleContent_Bague
        self.reviews_Bague = reviews_Bague
        self.likes_Bague = likes_Bague
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Bague: NSObject, Codable {
    
    /// 用户ID
    var userId_Bague: Int?
    
    /// 用户密码
    var userPwd_Bague: String?
    
    /// 用户名称
    var userName_Bague: String?
    
    /// 用户头像
    var userHead_Bague: String?
    
    /// 用户简介
    var userIntroduce_Bague: String?
    
    /// 用户发布帖子列表
    var userPosts_Bague: [TitleModel_Bague]
    
    /// 用户喜欢帖子列表
    var userLike_Bague: [TitleModel_Bague]

    /// 用户关注列表
    var userFollow_Bague: [PrewUserModel_Bague]

    /// 我的藏包册条目列表
    var userBags_Bague: [BagItem_Bague]
    
    /// 初始化
    init(userId_Bague: Int? = nil,
         userPwd_Bague: String? = nil,
         userName_Bague: String? = nil,
         userHead_Bague: String? = nil,
         userIntroduce_Bague: String? = nil,
         userPosts_Bague: [TitleModel_Bague],
         userLike_Bague: [TitleModel_Bague],
         userFollow_Bague: [PrewUserModel_Bague],
         userBags_Bague: [BagItem_Bague] = []) {
        self.userId_Bague = userId_Bague
        self.userPwd_Bague = userPwd_Bague
        self.userName_Bague = userName_Bague
        self.userHead_Bague = userHead_Bague
        self.userIntroduce_Bague = userIntroduce_Bague
        self.userPosts_Bague = userPosts_Bague
        self.userLike_Bague = userLike_Bague
        self.userFollow_Bague = userFollow_Bague
        self.userBags_Bague = userBags_Bague
    }
}

/// 我的藏包册单件模型
/// 功能：存储用户上传的包包信息（名称/品牌/入手年份/成色/备注/图片路径）
class BagItem_Bague: NSObject, Codable {

    /// 条目唯一 ID
    var itemId_Bague: Int
    /// 包包名称（必填）
    var name_Bague: String
    /// 品牌
    var brand_Bague: String?
    /// 入手年份
    var yearAcquired_Bague: String?
    /// 成色（如 Mint / Good / Fair / Used）
    var condition_Bague: String?
    /// 备注故事
    var notes_Bague: String?
    /// 本地图片路径
    var imagePath_Bague: String?

    init(itemId_Bague: Int,
         name_Bague: String,
         brand_Bague: String? = nil,
         yearAcquired_Bague: String? = nil,
         condition_Bague: String? = nil,
         notes_Bague: String? = nil,
         imagePath_Bague: String? = nil) {
        self.itemId_Bague = itemId_Bague
        self.name_Bague = name_Bague
        self.brand_Bague = brand_Bague
        self.yearAcquired_Bague = yearAcquired_Bague
        self.condition_Bague = condition_Bague
        self.notes_Bague = notes_Bague
        self.imagePath_Bague = imagePath_Bague
    }
}

/// 中古故事馆话题模型
/// 功能：官方每日发布 3 个话题，供用户讨论
class VintageTopicItem_Bague: NSObject, Codable {

    /// 话题 ID
    var topicId_Bague: Int
    /// 话题标题
    var title_Bague: String
    /// 话题描述
    var description_Bague: String
    /// SF Symbol 图标名
    var iconName_Bague: String
    /// 话题评论列表
    var comments_Bague: [VintageComment_Bague]

    init(topicId_Bague: Int,
         title_Bague: String,
         description_Bague: String,
         iconName_Bague: String,
         comments_Bague: [VintageComment_Bague] = []) {
        self.topicId_Bague = topicId_Bague
        self.title_Bague = title_Bague
        self.description_Bague = description_Bague
        self.iconName_Bague = iconName_Bague
        self.comments_Bague = comments_Bague
    }
}

/// 中古故事馆话题评论模型
class VintageComment_Bague: NSObject, Codable {

    var commentId_Bague: Int
    var commentUserId_Bague: Int
    var commentUserName_Bague: String
    var commentContent_Bague: String

    init(commentId_Bague: Int,
         commentUserId_Bague: Int,
         commentUserName_Bague: String,
         commentContent_Bague: String) {
        self.commentId_Bague = commentId_Bague
        self.commentUserId_Bague = commentUserId_Bague
        self.commentUserName_Bague = commentUserName_Bague
        self.commentContent_Bague = commentContent_Bague
    }
}

/// 消息数据模型
class MessageModel_Bague: Codable {
    
    /// 消息ID
    var messageId_Bague: Int?
    
    /// 消息内容
    var content_Bague: String?
    
    /// 用户头像
    var userHead_Bague: String?
    
    /// 是否是我发送的
    var isMine_Bague: Bool?
    
    /// 消息时间
    var time_Bague: String?
    
    /// 初始化
    init(messageId_bague: Int? = nil,
         content_bague: String? = nil,
         userHead_bague: String? = nil,
         isMine_bague: Bool? = nil,
         time_bague: String? = nil) {
        self.messageId_Bague = messageId_bague
        self.content_Bague = content_bague
        self.userHead_Bague = userHead_bague
        self.isMine_Bague = isMine_bague
        self.time_Bague = time_bague
    }
}

/// 评论模型
class Comment_Bague: NSObject, Codable {
    
    /// 评论ID
    var commentId_Bague: Int
    
    /// 评论用户uid
    var commentUserId_Bague: Int
    
    /// 评论用户昵称
    var commentUserName_Bague: String
    
    /// 评论内容
    var commentContent_Bague: String
    
    /// 初始化
    init(commentId_Bague: Int,
         commentUserId_Bague: Int,
         commentUserName_Bague: String,
         commentContent_Bague: String) {
        self.commentId_Bague = commentId_Bague
        self.commentUserId_Bague = commentUserId_Bague
        self.commentUserName_Bague = commentUserName_Bague
        self.commentContent_Bague = commentContent_Bague
    }
}

/// 商店模型
class StoreModel_Bague: NSObject {
    
    /// ID编号
    var id_Bague: Int?
    
    /// 商品ID
    var goodsId_Bague: String?
    
    /// 商品名字
    var goodsName_Bague: String?
    
    /// 商品价格
    var goodsPrice_Bague: String?
    
    /// 是否顶部商品
    var goodIsTop_Bague: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Bague: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Bague: Bool?
    
    init(id_Bague: Int? = nil,
         goodsId_Bague: String? = nil,
         goodsName_Bague: String? = nil,
         goodsPrice_Bague: String? = nil,
         goodIsTop_Bague: Bool? = false,
         goodIsLimit_Bague: Bool? = false,
         goodIsVIP_Bague: Bool? = false) {
        self.id_Bague = id_Bague
        self.goodsId_Bague = goodsId_Bague
        self.goodsName_Bague = goodsName_Bague
        self.goodsPrice_Bague = goodsPrice_Bague
        self.goodIsTop_Bague = goodIsTop_Bague
        self.goodIsSpecial_Bague = goodIsLimit_Bague
        self.goodIsVIP_Bague = goodIsVIP_Bague
        super.init()
    }
}
