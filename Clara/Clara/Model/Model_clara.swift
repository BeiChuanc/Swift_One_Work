import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Clara: NSObject, Codable {
    
    /// 用户ID
    var userId_Clara: Int?
    
    /// 用户名字
    var userName_Clara: String?
    
    /// 用户简介
    var userIntroduce_Clara: String?
    
    /// 用户头像
    var userHead_Clara: String?
    
    /// 用户媒体
    var userMedia_Clara: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Clara: [TitleModel_Clara] = []

    /// 用户关注数
    var userFollow_Clara: Int?

    /// 用户粉丝数
    var userFans_Clara: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Clara: Int? = nil,
         userName_Clara: String? = nil,
         userIntroduce_Clara: String? = nil,
         userHead_Clara: String? = nil,
         userMedia_Clara: [String]? = nil,
         userLike_Clara: [TitleModel_Clara] = [],
         userFollow_Clara: Int? = nil,
         userFans_Clara: Int? = nil) {
        self.userId_Clara = userId_Clara
        self.userName_Clara = userName_Clara
        self.userIntroduce_Clara = userIntroduce_Clara
        self.userHead_Clara = userHead_Clara
        self.userMedia_Clara = userMedia_Clara
        self.userLike_Clara = userLike_Clara
        self.userFollow_Clara = userFollow_Clara
        self.userFans_Clara = userFans_Clara
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Clara: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Clara: Int
    
    /// 拥有者ID
    var titleUserId_Clara: Int
    
    /// 拥有者昵称
    var titleUserName_Clara: String
    
    /// 帖子媒体
    var titleMeidas_Clara: [String]
    
    /// 帖子标题
    var title_Clara: String
    
    /// 帖子内容
    var titleContent_Clara: String
    
    /// 帖子评论列表
    var reviews_Clara: [Comment_Clara]
    
    /// 喜欢个数
    var likes_Clara: Int
    
    init(titleId_Clara: Int,
         titleUserId_Clara: Int,
         titleUserName_Clara: String,
         titleMeidas_Clara: [String],
         title_Clara: String,
         titleContent_Clara: String,
         reviews_Clara: [Comment_Clara],
         likes_Clara: Int) {
        self.titleId_Clara = titleId_Clara
        self.titleUserId_Clara = titleUserId_Clara
        self.titleUserName_Clara = titleUserName_Clara
        self.titleMeidas_Clara = titleMeidas_Clara
        self.title_Clara = title_Clara
        self.titleContent_Clara = titleContent_Clara
        self.reviews_Clara = reviews_Clara
        self.likes_Clara = likes_Clara
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Clara: NSObject, Codable {
    
    /// 用户ID
    var userId_Clara: Int?
    
    /// 用户密码
    var userPwd_Clara: String?
    
    /// 用户名称
    var userName_Clara: String?
    
    /// 用户头像
    var userHead_Clara: String?

    /// 用户简介
    var userIntroduce_Clara: String?
    
    /// 用户发布帖子列表
    var userPosts_Clara: [TitleModel_Clara]
    
    /// 用户喜欢帖子列表
    var userLike_Clara: [TitleModel_Clara]

    /// 用户关注列表
    var userFollow_Clara: [PrewUserModel_Clara]
    
    /// 初始化
    init(userId_Clara: Int? = nil,
         userPwd_Clara: String? = nil,
         userName_Clara: String? = nil,
         userHead_Clara: String? = nil,
         userIntroduce_Clara: String? = nil,
         userPosts_Clara: [TitleModel_Clara],
         userLike_Clara: [TitleModel_Clara],
         userFollow_Clara: [PrewUserModel_Clara]) {
        self.userId_Clara = userId_Clara
        self.userPwd_Clara = userPwd_Clara
        self.userName_Clara = userName_Clara
        self.userHead_Clara = userHead_Clara
        self.userIntroduce_Clara = userIntroduce_Clara
        self.userPosts_Clara = userPosts_Clara
        self.userLike_Clara = userLike_Clara
        self.userFollow_Clara = userFollow_Clara
    }
}

/// 消息数据模型
class MessageModel_Clara: Codable {
    
    /// 消息ID
    var messageId_Clara: Int?
    
    /// 消息内容
    var content_Clara: String?
    
    /// 用户头像
    var userHead_Clara: String?
    
    /// 是否是我发送的
    var isMine_Clara: Bool?
    
    /// 消息时间
    var time_Clara: String?
    
    /// 初始化
    init(messageId_clara: Int? = nil,
         content_clara: String? = nil,
         userHead_clara: String? = nil,
         isMine_clara: Bool? = nil,
         time_clara: String? = nil) {
        self.messageId_Clara = messageId_clara
        self.content_Clara = content_clara
        self.userHead_Clara = userHead_clara
        self.isMine_Clara = isMine_clara
        self.time_Clara = time_clara
    }
}

/// 评论模型
class Comment_Clara: NSObject, Codable {
    
    /// 评论ID
    var commentId_Clara: Int
    
    /// 评论用户uid
    var commentUserId_Clara: Int
    
    /// 评论用户昵称
    var commentUserName_Clara: String
    
    /// 评论内容
    var commentContent_Clara: String
    
    /// 初始化
    init(commentId_Clara: Int,
         commentUserId_Clara: Int,
         commentUserName_Clara: String,
         commentContent_Clara: String) {
        self.commentId_Clara = commentId_Clara
        self.commentUserId_Clara = commentUserId_Clara
        self.commentUserName_Clara = commentUserName_Clara
        self.commentContent_Clara = commentContent_Clara
    }
}

/// 商店模型
class StoreModel_Clara: NSObject {
    
    /// ID编号
    var id_Clara: Int?
    
    /// 商品ID
    var goodsId_Clara: String?
    
    /// 商品名字
    var goodsName_Clara: String?
    
    /// 商品价格
    var goodsPrice_Clara: String?
    
    /// 是否顶部商品
    var goodIsTop_Clara: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Clara: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Clara: Bool?
    
    init(id_Clara: Int? = nil,
         goodsId_Clara: String? = nil,
         goodsName_Clara: String? = nil,
         goodsPrice_Clara: String? = nil,
         goodIsTop_Clara: Bool? = false,
         goodIsLimit_Clara: Bool? = false,
         goodIsVIP_Clara: Bool? = false) {
        self.id_Clara = id_Clara
        self.goodsId_Clara = goodsId_Clara
        self.goodsName_Clara = goodsName_Clara
        self.goodsPrice_Clara = goodsPrice_Clara
        self.goodIsTop_Clara = goodIsTop_Clara
        self.goodIsSpecial_Clara = goodIsLimit_Clara
        self.goodIsVIP_Clara = goodIsVIP_Clara
        super.init()
    }
}
