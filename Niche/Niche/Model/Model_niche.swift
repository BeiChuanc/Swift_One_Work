import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Niche: NSObject, Codable {
    
    /// 用户ID
    var userId_Niche: Int?
    
    /// 用户名字
    var userName_Niche: String?
    
    /// 用户简介
    var userIntroduce_Niche: String?
    
    /// 用户头像
    var userHead_Niche: String?
    
    /// 用户媒体
    var userMedia_Niche: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Niche: [TitleModel_Niche] = []

    /// 用户关注数
    var userFollow_Niche: Int?

    /// 用户粉丝数
    var userFans_Niche: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Niche: Int? = nil,
         userName_Niche: String? = nil,
         userIntroduce_Niche: String? = nil,
         userHead_Niche: String? = nil,
         userMedia_Niche: [String]? = nil,
         userLike_Niche: [TitleModel_Niche] = [],
         userFollow_Niche: Int? = nil,
         userFans_Niche: Int? = nil) {
        self.userId_Niche = userId_Niche
        self.userName_Niche = userName_Niche
        self.userIntroduce_Niche = userIntroduce_Niche
        self.userHead_Niche = userHead_Niche
        self.userMedia_Niche = userMedia_Niche
        self.userLike_Niche = userLike_Niche
        self.userFollow_Niche = userFollow_Niche
        self.userFans_Niche = userFans_Niche
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Niche: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Niche: Int
    
    /// 拥有者ID
    var titleUserId_Niche: Int
    
    /// 拥有者昵称
    var titleUserName_Niche: String
    
    /// 帖子媒体
    var titleMeidas_Niche: [String]
    
    /// 帖子标题
    var title_Niche: String
    
    /// 帖子内容
    var titleContent_Niche: String
    
    /// 帖子评论列表
    var reviews_Niche: [Comment_Niche]
    
    /// 喜欢个数
    var likes_Niche: Int
    
    init(titleId_Niche: Int,
         titleUserId_Niche: Int,
         titleUserName_Niche: String,
         titleMeidas_Niche: [String],
         title_Niche: String,
         titleContent_Niche: String,
         reviews_Niche: [Comment_Niche],
         likes_Niche: Int) {
        self.titleId_Niche = titleId_Niche
        self.titleUserId_Niche = titleUserId_Niche
        self.titleUserName_Niche = titleUserName_Niche
        self.titleMeidas_Niche = titleMeidas_Niche
        self.title_Niche = title_Niche
        self.titleContent_Niche = titleContent_Niche
        self.reviews_Niche = reviews_Niche
        self.likes_Niche = likes_Niche
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Niche: NSObject, Codable {
    
    /// 用户ID
    var userId_Niche: Int?
    
    /// 用户密码
    var userPwd_Niche: String?
    
    /// 用户名称
    var userName_Niche: String?

    /// 用户简介
    var userIntroduce_Niche: String?
    
    /// 用户头像
    var userHead_Niche: String?
    
    /// 用户发布帖子列表
    var userPosts_Niche: [TitleModel_Niche]
    
    /// 用户喜欢帖子列表
    var userLike_Niche: [TitleModel_Niche]

    /// 用户关注列表
    var userFollow_Niche: [PrewUserModel_Niche]
    
    /// 初始化
    init(userId_Niche: Int? = nil,
         userPwd_Niche: String? = nil,
         userName_Niche: String? = nil,
         userIntroduce_Niche: String? = nil,
         userHead_Niche: String? = nil,
         userPosts_Niche: [TitleModel_Niche],
         userLike_Niche: [TitleModel_Niche],
         userFollow_Niche: [PrewUserModel_Niche]) {
        self.userId_Niche = userId_Niche
        self.userPwd_Niche = userPwd_Niche
        self.userName_Niche = userName_Niche
        self.userIntroduce_Niche = userIntroduce_Niche
        self.userHead_Niche = userHead_Niche
        self.userPosts_Niche = userPosts_Niche
        self.userLike_Niche = userLike_Niche
        self.userFollow_Niche = userFollow_Niche
    }
}

/// 消息数据模型
class MessageModel_Niche: Codable {
    
    /// 消息ID
    var messageId_Niche: Int?
    
    /// 消息内容
    var content_Niche: String?
    
    /// 用户头像
    var userHead_Niche: String?
    
    /// 是否是我发送的
    var isMine_Niche: Bool?
    
    /// 消息时间
    var time_Niche: String?
    
    /// 初始化
    init(messageId_niche: Int? = nil,
         content_niche: String? = nil,
         userHead_niche: String? = nil,
         isMine_niche: Bool? = nil,
         time_niche: String? = nil) {
        self.messageId_Niche = messageId_niche
        self.content_Niche = content_niche
        self.userHead_Niche = userHead_niche
        self.isMine_Niche = isMine_niche
        self.time_Niche = time_niche
    }
}

/// 评论模型
class Comment_Niche: NSObject, Codable {
    
    /// 评论ID
    var commentId_Niche: Int
    
    /// 评论用户uid
    var commentUserId_Niche: Int
    
    /// 评论用户昵称
    var commentUserName_Niche: String
    
    /// 评论内容
    var commentContent_Niche: String
    
    /// 初始化
    init(commentId_Niche: Int,
         commentUserId_Niche: Int,
         commentUserName_Niche: String,
         commentContent_Niche: String) {
        self.commentId_Niche = commentId_Niche
        self.commentUserId_Niche = commentUserId_Niche
        self.commentUserName_Niche = commentUserName_Niche
        self.commentContent_Niche = commentContent_Niche
    }
}

/// 商店模型
class StoreModel_Niche: NSObject {
    
    /// ID编号
    var id_Niche: Int?
    
    /// 商品ID
    var goodsId_Niche: String?
    
    /// 商品名字
    var goodsName_Niche: String?
    
    /// 商品价格
    var goodsPrice_Niche: String?
    
    /// 是否顶部商品
    var goodIsTop_Niche: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Niche: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Niche: Bool?
    
    init(id_Niche: Int? = nil,
         goodsId_Niche: String? = nil,
         goodsName_Niche: String? = nil,
         goodsPrice_Niche: String? = nil,
         goodIsTop_Niche: Bool? = false,
         goodIsLimit_Niche: Bool? = false,
         goodIsVIP_Niche: Bool? = false) {
        self.id_Niche = id_Niche
        self.goodsId_Niche = goodsId_Niche
        self.goodsName_Niche = goodsName_Niche
        self.goodsPrice_Niche = goodsPrice_Niche
        self.goodIsTop_Niche = goodIsTop_Niche
        self.goodIsSpecial_Niche = goodIsLimit_Niche
        self.goodIsVIP_Niche = goodIsVIP_Niche
        super.init()
    }
}
