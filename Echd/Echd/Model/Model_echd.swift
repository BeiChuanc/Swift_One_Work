import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Echd: NSObject, Codable {
    
    /// 用户ID
    var userId_Echd: Int?
    
    /// 用户名字
    var userName_Echd: String?
    
    /// 用户简介
    var userIntroduce_Echd: String?
    
    /// 用户头像
    var userHead_Echd: String?
    
    /// 用户媒体
    var userMedia_Echd: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Echd: [TitleModel_Echd] = []

    /// 用户关注数
    var userFollow_Echd: Int?

    /// 用户粉丝数
    var userFans_Echd: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Echd: Int? = nil,
         userName_Echd: String? = nil,
         userIntroduce_Echd: String? = nil,
         userHead_Echd: String? = nil,
         userMedia_Echd: [String]? = nil,
         userLike_Echd: [TitleModel_Echd] = [],
         userFollow_Echd: Int? = nil,
         userFans_Echd: Int? = nil) {
        self.userId_Echd = userId_Echd
        self.userName_Echd = userName_Echd
        self.userIntroduce_Echd = userIntroduce_Echd
        self.userHead_Echd = userHead_Echd
        self.userMedia_Echd = userMedia_Echd
        self.userLike_Echd = userLike_Echd
        self.userFollow_Echd = userFollow_Echd
        self.userFans_Echd = userFans_Echd
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Echd: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Echd: Int
    
    /// 拥有者ID
    var titleUserId_Echd: Int
    
    /// 拥有者昵称
    var titleUserName_Echd: String
    
    /// 帖子媒体
    var titleMeidas_Echd: [String]
    
    /// 帖子标题
    var title_Echd: String
    
    /// 帖子内容
    var titleContent_Echd: String
    
    /// 帖子评论列表
    var reviews_Echd: [Comment_Echd]
    
    /// 喜欢个数
    var likes_Echd: Int
    
    init(titleId_Echd: Int,
         titleUserId_Echd: Int,
         titleUserName_Echd: String,
         titleMeidas_Echd: [String],
         title_Echd: String,
         titleContent_Echd: String,
         reviews_Echd: [Comment_Echd],
         likes_Echd: Int) {
        self.titleId_Echd = titleId_Echd
        self.titleUserId_Echd = titleUserId_Echd
        self.titleUserName_Echd = titleUserName_Echd
        self.titleMeidas_Echd = titleMeidas_Echd
        self.title_Echd = title_Echd
        self.titleContent_Echd = titleContent_Echd
        self.reviews_Echd = reviews_Echd
        self.likes_Echd = likes_Echd
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Echd: NSObject, Codable {
    
    /// 用户ID
    var userId_Echd: Int?
    
    /// 用户密码
    var userPwd_Echd: String?
    
    /// 用户名称
    var userName_Echd: String?
    
    /// 用户头像
    var userHead_Echd: String?
    
    /// 用户发布帖子列表
    var userPosts_Echd: [TitleModel_Echd]
    
    /// 用户喜欢帖子列表
    var userLike_Echd: [TitleModel_Echd]

    /// 用户关注列表
    var userFollow_Echd: [PrewUserModel_Echd]
    
    /// 初始化
    init(userId_Echd: Int? = nil,
         userPwd_Echd: String? = nil,
         userName_Echd: String? = nil,
         userHead_Echd: String? = nil,
         userPosts_Echd: [TitleModel_Echd],
         userLike_Echd: [TitleModel_Echd],
         userFollow_Echd: [PrewUserModel_Echd]) {
        self.userId_Echd = userId_Echd
        self.userPwd_Echd = userPwd_Echd
        self.userName_Echd = userName_Echd
        self.userHead_Echd = userHead_Echd
        self.userPosts_Echd = userPosts_Echd
        self.userLike_Echd = userLike_Echd
        self.userFollow_Echd = userFollow_Echd
    }
}

/// 消息数据模型
class MessageModel_Echd: Codable {
    
    /// 消息ID
    var messageId_Echd: Int?
    
    /// 消息内容
    var content_Echd: String?
    
    /// 用户头像
    var userHead_Echd: String?
    
    /// 是否是我发送的
    var isMine_Echd: Bool?
    
    /// 消息时间
    var time_Echd: String?
    
    /// 初始化
    init(messageId_echd: Int? = nil,
         content_echd: String? = nil,
         userHead_echd: String? = nil,
         isMine_echd: Bool? = nil,
         time_echd: String? = nil) {
        self.messageId_Echd = messageId_echd
        self.content_Echd = content_echd
        self.userHead_Echd = userHead_echd
        self.isMine_Echd = isMine_echd
        self.time_Echd = time_echd
    }
}

/// 评论模型
class Comment_Echd: NSObject, Codable {
    
    /// 评论ID
    var commentId_Echd: Int
    
    /// 评论用户uid
    var commentUserId_Echd: Int
    
    /// 评论用户昵称
    var commentUserName_Echd: String
    
    /// 评论内容
    var commentContent_Echd: String
    
    /// 初始化
    init(commentId_Echd: Int,
         commentUserId_Echd: Int,
         commentUserName_Echd: String,
         commentContent_Echd: String) {
        self.commentId_Echd = commentId_Echd
        self.commentUserId_Echd = commentUserId_Echd
        self.commentUserName_Echd = commentUserName_Echd
        self.commentContent_Echd = commentContent_Echd
    }
}

/// 商店模型
class StoreModel_Echd: NSObject {
    
    /// ID编号
    var id_Echd: Int?
    
    /// 商品ID
    var goodsId_Echd: String?
    
    /// 商品名字
    var goodsName_Echd: String?
    
    /// 商品价格
    var goodsPrice_Echd: String?
    
    /// 是否顶部商品
    var goodIsTop_Echd: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Echd: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Echd: Bool?
    
    init(id_Echd: Int? = nil,
         goodsId_Echd: String? = nil,
         goodsName_Echd: String? = nil,
         goodsPrice_Echd: String? = nil,
         goodIsTop_Echd: Bool? = false,
         goodIsLimit_Echd: Bool? = false,
         goodIsVIP_Echd: Bool? = false) {
        self.id_Echd = id_Echd
        self.goodsId_Echd = goodsId_Echd
        self.goodsName_Echd = goodsName_Echd
        self.goodsPrice_Echd = goodsPrice_Echd
        self.goodIsTop_Echd = goodIsTop_Echd
        self.goodIsSpecial_Echd = goodIsLimit_Echd
        self.goodIsVIP_Echd = goodIsVIP_Echd
        super.init()
    }
}
