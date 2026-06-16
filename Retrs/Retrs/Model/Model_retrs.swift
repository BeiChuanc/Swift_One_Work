import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Retrs: NSObject, Codable {
    
    /// 用户ID
    var userId_Retrs: Int?
    
    /// 用户名字
    var userName_Retrs: String?
    
    /// 用户简介
    var userIntroduce_Retrs: String?
    
    /// 用户头像
    var userHead_Retrs: String?
    
    /// 用户媒体
    var userMedia_Retrs: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Retrs: [TitleModel_Retrs] = []

    /// 用户关注数
    var userFollow_Retrs: Int?

    /// 用户粉丝数
    var userFans_Retrs: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Retrs: Int? = nil,
         userName_Retrs: String? = nil,
         userIntroduce_Retrs: String? = nil,
         userHead_Retrs: String? = nil,
         userMedia_Retrs: [String]? = nil,
         userLike_Retrs: [TitleModel_Retrs] = [],
         userFollow_Retrs: Int? = nil,
         userFans_Retrs: Int? = nil) {
        self.userId_Retrs = userId_Retrs
        self.userName_Retrs = userName_Retrs
        self.userIntroduce_Retrs = userIntroduce_Retrs
        self.userHead_Retrs = userHead_Retrs
        self.userMedia_Retrs = userMedia_Retrs
        self.userLike_Retrs = userLike_Retrs
        self.userFollow_Retrs = userFollow_Retrs
        self.userFans_Retrs = userFans_Retrs
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Retrs: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Retrs: Int
    
    /// 拥有者ID
    var titleUserId_Retrs: Int
    
    /// 拥有者昵称
    var titleUserName_Retrs: String
    
    /// 帖子媒体
    var titleMeidas_Retrs: [String]
    
    /// 帖子标题
    var title_Retrs: String
    
    /// 帖子内容
    var titleContent_Retrs: String
    
    /// 帖子评论列表
    var reviews_Retrs: [Comment_Retrs]
    
    /// 喜欢个数
    var likes_Retrs: Int
    
    init(titleId_Retrs: Int,
         titleUserId_Retrs: Int,
         titleUserName_Retrs: String,
         titleMeidas_Retrs: [String],
         title_Retrs: String,
         titleContent_Retrs: String,
         reviews_Retrs: [Comment_Retrs],
         likes_Retrs: Int) {
        self.titleId_Retrs = titleId_Retrs
        self.titleUserId_Retrs = titleUserId_Retrs
        self.titleUserName_Retrs = titleUserName_Retrs
        self.titleMeidas_Retrs = titleMeidas_Retrs
        self.title_Retrs = title_Retrs
        self.titleContent_Retrs = titleContent_Retrs
        self.reviews_Retrs = reviews_Retrs
        self.likes_Retrs = likes_Retrs
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Retrs: NSObject, Codable {
    
    /// 用户ID
    var userId_Retrs: Int?
    
    /// 用户密码
    var userPwd_Retrs: String?
    
    /// 用户名称
    var userName_Retrs: String?
    
    /// 用户头像
    var userHead_Retrs: String?
    
    /// 用户发布帖子列表
    var userPosts_Retrs: [TitleModel_Retrs]
    
    /// 用户喜欢帖子列表
    var userLike_Retrs: [TitleModel_Retrs]

    /// 用户关注列表
    var userFollow_Retrs: [PrewUserModel_Retrs]
    
    /// 初始化
    init(userId_Retrs: Int? = nil,
         userPwd_Retrs: String? = nil,
         userName_Retrs: String? = nil,
         userHead_Retrs: String? = nil,
         userPosts_Retrs: [TitleModel_Retrs],
         userLike_Retrs: [TitleModel_Retrs],
         userFollow_Retrs: [PrewUserModel_Retrs]) {
        self.userId_Retrs = userId_Retrs
        self.userPwd_Retrs = userPwd_Retrs
        self.userName_Retrs = userName_Retrs
        self.userHead_Retrs = userHead_Retrs
        self.userPosts_Retrs = userPosts_Retrs
        self.userLike_Retrs = userLike_Retrs
        self.userFollow_Retrs = userFollow_Retrs
    }
}

/// 消息数据模型
class MessageModel_Retrs: Codable {
    
    /// 消息ID
    var messageId_Retrs: Int?
    
    /// 消息内容
    var content_Retrs: String?
    
    /// 用户头像
    var userHead_Retrs: String?
    
    /// 是否是我发送的
    var isMine_Retrs: Bool?
    
    /// 消息时间
    var time_Retrs: String?
    
    /// 初始化
    init(messageId_retrs: Int? = nil,
         content_retrs: String? = nil,
         userHead_retrs: String? = nil,
         isMine_retrs: Bool? = nil,
         time_retrs: String? = nil) {
        self.messageId_Retrs = messageId_retrs
        self.content_Retrs = content_retrs
        self.userHead_Retrs = userHead_retrs
        self.isMine_Retrs = isMine_retrs
        self.time_Retrs = time_retrs
    }
}

/// 评论模型
class Comment_Retrs: NSObject, Codable {
    
    /// 评论ID
    var commentId_Retrs: Int
    
    /// 评论用户uid
    var commentUserId_Retrs: Int
    
    /// 评论用户昵称
    var commentUserName_Retrs: String
    
    /// 评论内容
    var commentContent_Retrs: String
    
    /// 初始化
    init(commentId_Retrs: Int,
         commentUserId_Retrs: Int,
         commentUserName_Retrs: String,
         commentContent_Retrs: String) {
        self.commentId_Retrs = commentId_Retrs
        self.commentUserId_Retrs = commentUserId_Retrs
        self.commentUserName_Retrs = commentUserName_Retrs
        self.commentContent_Retrs = commentContent_Retrs
    }
}

/// 商店模型
class StoreModel_Retrs: NSObject {
    
    /// ID编号
    var id_Retrs: Int?
    
    /// 商品ID
    var goodsId_Retrs: String?
    
    /// 商品名字
    var goodsName_Retrs: String?
    
    /// 商品价格
    var goodsPrice_Retrs: String?
    
    /// 是否顶部商品
    var goodIsTop_Retrs: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Retrs: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Retrs: Bool?
    
    init(id_Retrs: Int? = nil,
         goodsId_Retrs: String? = nil,
         goodsName_Retrs: String? = nil,
         goodsPrice_Retrs: String? = nil,
         goodIsTop_Retrs: Bool? = false,
         goodIsLimit_Retrs: Bool? = false,
         goodIsVIP_Retrs: Bool? = false) {
        self.id_Retrs = id_Retrs
        self.goodsId_Retrs = goodsId_Retrs
        self.goodsName_Retrs = goodsName_Retrs
        self.goodsPrice_Retrs = goodsPrice_Retrs
        self.goodIsTop_Retrs = goodIsTop_Retrs
        self.goodIsSpecial_Retrs = goodIsLimit_Retrs
        self.goodIsVIP_Retrs = goodIsVIP_Retrs
        super.init()
    }
}
