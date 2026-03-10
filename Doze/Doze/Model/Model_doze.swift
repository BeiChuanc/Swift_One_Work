import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Doze: NSObject, Codable {
    
    /// 用户ID
    var userId_Doze: Int?
    
    /// 用户名字
    var userName_Doze: String?
    
    /// 用户简介
    var userIntroduce_Doze: String?
    
    /// 用户头像
    var userHead_Doze: String?
    
    /// 用户媒体
    var userMedia_Doze: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Doze: [TitleModel_Doze] = []

    /// 用户关注数
    var userFollow_Doze: Int?

    /// 用户粉丝数
    var userFans_Doze: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Doze: Int? = nil,
         userName_Doze: String? = nil,
         userIntroduce_Doze: String? = nil,
         userHead_Doze: String? = nil,
         userMedia_Doze: [String]? = nil,
         userLike_Doze: [TitleModel_Doze] = [],
         userFollow_Doze: Int? = nil,
         userFans_Doze: Int? = nil) {
        self.userId_Doze = userId_Doze
        self.userName_Doze = userName_Doze
        self.userIntroduce_Doze = userIntroduce_Doze
        self.userHead_Doze = userHead_Doze
        self.userMedia_Doze = userMedia_Doze
        self.userLike_Doze = userLike_Doze
        self.userFollow_Doze = userFollow_Doze
        self.userFans_Doze = userFans_Doze
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Doze: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Doze: Int
    
    /// 拥有者ID
    var titleUserId_Doze: Int
    
    /// 拥有者昵称
    var titleUserName_Doze: String
    
    /// 帖子媒体
    var titleMeidas_Doze: [String]
    
    /// 帖子标题
    var title_Doze: String
    
    /// 帖子内容
    var titleContent_Doze: String
    
    /// 帖子评论列表
    var reviews_Doze: [Comment_Doze]
    
    /// 喜欢个数
    var likes_Doze: Int
    
    init(titleId_Doze: Int,
         titleUserId_Doze: Int,
         titleUserName_Doze: String,
         titleMeidas_Doze: [String],
         title_Doze: String,
         titleContent_Doze: String,
         reviews_Doze: [Comment_Doze],
         likes_Doze: Int) {
        self.titleId_Doze = titleId_Doze
        self.titleUserId_Doze = titleUserId_Doze
        self.titleUserName_Doze = titleUserName_Doze
        self.titleMeidas_Doze = titleMeidas_Doze
        self.title_Doze = title_Doze
        self.titleContent_Doze = titleContent_Doze
        self.reviews_Doze = reviews_Doze
        self.likes_Doze = likes_Doze
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Doze: NSObject, Codable {
    
    /// 用户ID
    var userId_Doze: Int?
    
    /// 用户密码
    var userPwd_Doze: String?
    
    /// 用户名称
    var userName_Doze: String?
    
    /// 用户头像
    var userHead_Doze: String?
    
    /// 用户发布帖子列表
    var userPosts_Doze: [TitleModel_Doze]
    
    /// 用户喜欢帖子列表
    var userLike_Doze: [TitleModel_Doze]

    /// 用户关注列表
    var userFollow_Doze: [PrewUserModel_Doze]
    
    /// 初始化
    init(userId_Doze: Int? = nil,
         userPwd_Doze: String? = nil,
         userName_Doze: String? = nil,
         userHead_Doze: String? = nil,
         userPosts_Doze: [TitleModel_Doze],
         userLike_Doze: [TitleModel_Doze],
         userFollow_Doze: [PrewUserModel_Doze]) {
        self.userId_Doze = userId_Doze
        self.userPwd_Doze = userPwd_Doze
        self.userName_Doze = userName_Doze
        self.userHead_Doze = userHead_Doze
        self.userPosts_Doze = userPosts_Doze
        self.userLike_Doze = userLike_Doze
        self.userFollow_Doze = userFollow_Doze
    }
}

/// 消息数据模型
class MessageModel_Doze: Codable {
    
    /// 消息ID
    var messageId_Doze: Int?
    
    /// 消息内容
    var content_Doze: String?
    
    /// 用户头像
    var userHead_Doze: String?
    
    /// 是否是我发送的
    var isMine_Doze: Bool?
    
    /// 消息时间
    var time_Doze: String?
    
    /// 初始化
    init(messageId_doze: Int? = nil,
         content_doze: String? = nil,
         userHead_doze: String? = nil,
         isMine_doze: Bool? = nil,
         time_doze: String? = nil) {
        self.messageId_Doze = messageId_doze
        self.content_Doze = content_doze
        self.userHead_Doze = userHead_doze
        self.isMine_Doze = isMine_doze
        self.time_Doze = time_doze
    }
}

/// 评论模型
class Comment_Doze: NSObject, Codable {
    
    /// 评论ID
    var commentId_Doze: Int
    
    /// 评论用户uid
    var commentUserId_Doze: Int
    
    /// 评论用户昵称
    var commentUserName_Doze: String
    
    /// 评论内容
    var commentContent_Doze: String
    
    /// 初始化
    init(commentId_Doze: Int,
         commentUserId_Doze: Int,
         commentUserName_Doze: String,
         commentContent_Doze: String) {
        self.commentId_Doze = commentId_Doze
        self.commentUserId_Doze = commentUserId_Doze
        self.commentUserName_Doze = commentUserName_Doze
        self.commentContent_Doze = commentContent_Doze
    }
}

/// 商店模型
class StoreModel_Doze: NSObject {
    
    /// ID编号
    var id_Doze: Int?
    
    /// 商品ID
    var goodsId_Doze: String?
    
    /// 商品名字
    var goodsName_Doze: String?
    
    /// 商品价格
    var goodsPrice_Doze: String?
    
    /// 是否顶部商品
    var goodIsTop_Doze: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Doze: Bool?
    
    init(id_Doze: Int? = nil,
         goodsId_Doze: String? = nil,
         goodsName_Doze: String? = nil,
         goodsPrice_Doze: String? = nil,
         goodIsTop_Doze: Bool? = false,
         goodIsLimit_Doze: Bool? = false) {
        self.id_Doze = id_Doze
        self.goodsId_Doze = goodsId_Doze
        self.goodsName_Doze = goodsName_Doze
        self.goodsPrice_Doze = goodsPrice_Doze
        self.goodIsTop_Doze = goodIsTop_Doze
        self.goodIsSpecial_Doze = goodIsLimit_Doze
        super.init()
    }
}
