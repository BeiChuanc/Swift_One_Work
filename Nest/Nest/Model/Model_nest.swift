import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Nest: NSObject, Codable {
    
    /// 用户ID
    var userId_Nest: Int?
    
    /// 用户名字
    var userName_Nest: String?
    
    /// 用户简介
    var userIntroduce_Nest: String?
    
    /// 用户头像
    var userHead_Nest: String?
    
    /// 用户媒体
    var userMedia_Nest: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Nest: [TitleModel_Nest] = []

    /// 用户关注数
    var userFollow_Nest: Int?

    /// 用户粉丝数
    var userFans_Nest: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Nest: Int? = nil,
         userName_Nest: String? = nil,
         userIntroduce_Nest: String? = nil,
         userHead_Nest: String? = nil,
         userMedia_Nest: [String]? = nil,
         userLike_Nest: [TitleModel_Nest] = [],
         userFollow_Nest: Int? = nil,
         userFans_Nest: Int? = nil) {
        self.userId_Nest = userId_Nest
        self.userName_Nest = userName_Nest
        self.userIntroduce_Nest = userIntroduce_Nest
        self.userHead_Nest = userHead_Nest
        self.userMedia_Nest = userMedia_Nest
        self.userLike_Nest = userLike_Nest
        self.userFollow_Nest = userFollow_Nest
        self.userFans_Nest = userFans_Nest
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Nest: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Nest: Int
    
    /// 拥有者ID
    var titleUserId_Nest: Int
    
    /// 拥有者昵称
    var titleUserName_Nest: String
    
    /// 帖子媒体
    var titleMeidas_Nest: [String]
    
    /// 帖子标题
    var title_Nest: String
    
    /// 帖子内容
    var titleContent_Nest: String
    
    /// 帖子评论列表
    var reviews_Nest: [Comment_Nest]
    
    /// 喜欢个数
    var likes_Nest: Int
    
    init(titleId_Nest: Int,
         titleUserId_Nest: Int,
         titleUserName_Nest: String,
         titleMeidas_Nest: [String],
         title_Nest: String,
         titleContent_Nest: String,
         reviews_Nest: [Comment_Nest],
         likes_Nest: Int) {
        self.titleId_Nest = titleId_Nest
        self.titleUserId_Nest = titleUserId_Nest
        self.titleUserName_Nest = titleUserName_Nest
        self.titleMeidas_Nest = titleMeidas_Nest
        self.title_Nest = title_Nest
        self.titleContent_Nest = titleContent_Nest
        self.reviews_Nest = reviews_Nest
        self.likes_Nest = likes_Nest
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Nest: NSObject, Codable {
    
    /// 用户ID
    var userId_Nest: Int?
    
    /// 用户密码
    var userPwd_Nest: String?
    
    /// 用户名称
    var userName_Nest: String?
    
    /// 用户头像
    var userHead_Nest: String?
    
    /// 用户简介
    var userBio_Nest: String?
    
    /// 用户发布帖子列表
    var userPosts_Nest: [TitleModel_Nest]
    
    /// 用户喜欢帖子列表
    var userLike_Nest: [TitleModel_Nest]

    /// 用户关注列表
    var userFollow_Nest: [PrewUserModel_Nest]

    /// 用户打卡记录列表（独居好物打卡）
    var userCheckIns_Nest: [CheckInPost_Nest]

    /// 初始化
    init(userId_Nest: Int? = nil,
         userPwd_Nest: String? = nil,
         userName_Nest: String? = nil,
         userHead_Nest: String? = nil,
         userBio_Nest: String? = nil,
         userPosts_Nest: [TitleModel_Nest],
         userLike_Nest: [TitleModel_Nest],
         userFollow_Nest: [PrewUserModel_Nest],
         userCheckIns_Nest: [CheckInPost_Nest] = []) {
        self.userId_Nest       = userId_Nest
        self.userPwd_Nest      = userPwd_Nest
        self.userName_Nest     = userName_Nest
        self.userHead_Nest     = userHead_Nest
        self.userBio_Nest      = userBio_Nest
        self.userPosts_Nest    = userPosts_Nest
        self.userLike_Nest     = userLike_Nest
        self.userFollow_Nest   = userFollow_Nest
        self.userCheckIns_Nest = userCheckIns_Nest
    }
}

/// 消息数据模型
class MessageModel_Nest: Codable {
    
    /// 消息ID
    var messageId_Nest: Int?
    
    /// 消息内容
    var content_Nest: String?
    
    /// 用户头像
    var userHead_Nest: String?
    
    /// 是否是我发送的
    var isMine_Nest: Bool?
    
    /// 消息时间
    var time_Nest: String?
    
    /// 初始化
    init(messageId_nest: Int? = nil,
         content_nest: String? = nil,
         userHead_nest: String? = nil,
         isMine_nest: Bool? = nil,
         time_nest: String? = nil) {
        self.messageId_Nest = messageId_nest
        self.content_Nest = content_nest
        self.userHead_Nest = userHead_nest
        self.isMine_Nest = isMine_nest
        self.time_Nest = time_nest
    }
}

/// 评论模型
class Comment_Nest: NSObject, Codable {
    
    /// 评论ID
    var commentId_Nest: Int
    
    /// 评论用户uid
    var commentUserId_Nest: Int
    
    /// 评论用户昵称
    var commentUserName_Nest: String
    
    /// 评论内容
    var commentContent_Nest: String
    
    /// 初始化
    init(commentId_Nest: Int,
         commentUserId_Nest: Int,
         commentUserName_Nest: String,
         commentContent_Nest: String) {
        self.commentId_Nest = commentId_Nest
        self.commentUserId_Nest = commentUserId_Nest
        self.commentUserName_Nest = commentUserName_Nest
        self.commentContent_Nest = commentContent_Nest
    }
}

/// 打卡记录模型
/// 核心作用：存储用户发布的独居好物打卡内容（封面图、描述、自定义标签）
class CheckInPost_Nest: NSObject, Codable {

    /// 打卡 ID
    var checkInId_Nest: Int
    /// 封面图路径（本地文件路径或 assets 名）
    var coverImagePath_Nest: String?
    /// 打卡描述
    var descContent_Nest: String
    /// 自定义标签列表
    var tags_Nest: [String]
    /// 发布日期字符串
    var dateString_Nest: String

    init(checkInId_Nest: Int,
         coverImagePath_Nest: String? = nil,
         descContent_Nest: String,
         tags_Nest: [String],
         dateString_Nest: String) {
        self.checkInId_Nest      = checkInId_Nest
        self.coverImagePath_Nest = coverImagePath_Nest
        self.descContent_Nest    = descContent_Nest
        self.tags_Nest           = tags_Nest
        self.dateString_Nest     = dateString_Nest
        super.init()
    }
}

/// 商店模型
class StoreModel_Nest: NSObject {
    
    /// ID编号
    var id_Nest: Int?
    
    /// 商品ID
    var goodsId_Nest: String?
    
    /// 商品名字
    var goodsName_Nest: String?
    
    /// 商品价格
    var goodsPrice_Nest: String?
    
    /// 是否顶部商品
    var goodIsTop_Nest: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Nest: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Nest: Bool?
    
    init(id_Nest: Int? = nil,
         goodsId_Nest: String? = nil,
         goodsName_Nest: String? = nil,
         goodsPrice_Nest: String? = nil,
         goodIsTop_Nest: Bool? = false,
         goodIsLimit_Nest: Bool? = false,
         goodIsVIP_Nest: Bool? = false) {
        self.id_Nest = id_Nest
        self.goodsId_Nest = goodsId_Nest
        self.goodsName_Nest = goodsName_Nest
        self.goodsPrice_Nest = goodsPrice_Nest
        self.goodIsTop_Nest = goodIsTop_Nest
        self.goodIsSpecial_Nest = goodIsLimit_Nest
        self.goodIsVIP_Nest = goodIsVIP_Nest
        super.init()
    }
}
