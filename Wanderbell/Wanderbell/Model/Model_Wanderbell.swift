import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Wanderbell: NSObject, Codable {
    
    /// 用户ID
    var userId_Wanderbell: Int?
    
    /// 用户名字
    var userName_Wanderbell: String?
    
    /// 用户简介
    var userIntroduce_Wanderbell: String?
    
    /// 用户头像
    var userHead_Wanderbell: String?
    
    /// 用户媒体
    var userMedia_Wanderbell: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Wanderbell: [TitleModel_Wanderbell] = []
    
    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Wanderbell: Int? = nil,
         userName_Wanderbell: String? = nil,
         userIntroduce_Wanderbell: String? = nil,
         userHead_Wanderbell: String? = nil,
         userMedia_Wanderbell: [String]? = nil,
         userLike_Wanderbell: [TitleModel_Wanderbell] = []) {
        self.userId_Wanderbell = userId_Wanderbell
        self.userName_Wanderbell = userName_Wanderbell
        self.userIntroduce_Wanderbell = userIntroduce_Wanderbell
        self.userHead_Wanderbell = userHead_Wanderbell
        self.userMedia_Wanderbell = userMedia_Wanderbell
        self.userLike_Wanderbell = userLike_Wanderbell
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Wanderbell: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Wanderbell: Int
    
    /// 拥有者ID
    var titleUserId_Wanderbell: Int
    
    /// 拥有者昵称
    var titleUserName_Wanderbell: String
    
    /// 帖子媒体
    var titleMeidas_Wanderbell: [String]
    
    /// 帖子标题
    var title_Wanderbell: String
    
    /// 帖子内容
    var titleContent_Wanderbell: String
    
    /// 帖子评论列表
    var reviews_Wanderbell: [Comment_Wanderbell]
    
    /// 喜欢个数
    var likes_Wanderbell: Int
    
    init(titleId_Wanderbell: Int,
         titleUserId_Wanderbell: Int,
         titleUserName_Wanderbell: String,
         titleMeidas_Wanderbell: [String],
         title_Wanderbell: String,
         titleContent_Wanderbell: String,
         reviews_Wanderbell: [Comment_Wanderbell],
         likes_Wanderbell: Int) {
        self.titleId_Wanderbell = titleId_Wanderbell
        self.titleUserId_Wanderbell = titleUserId_Wanderbell
        self.titleUserName_Wanderbell = titleUserName_Wanderbell
        self.titleMeidas_Wanderbell = titleMeidas_Wanderbell
        self.title_Wanderbell = title_Wanderbell
        self.titleContent_Wanderbell = titleContent_Wanderbell
        self.reviews_Wanderbell = reviews_Wanderbell
        self.likes_Wanderbell = likes_Wanderbell
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Wanderbell: NSObject, Codable {
    
    /// 用户ID
    var userId_Wanderbell: Int?
    
    /// 用户密码
    var userPwd_Wanderbell: String?
    
    /// 用户名称
    var userName_Wanderbell: String?
    
    /// 用户头像
    var userHead_Wanderbell: String?
    
    /// 用户发布帖子列表
    var userPosts_Wanderbell: [TitleModel_Wanderbell]
    
    /// 用户喜欢帖子列表
    var userLike_Wanderbell: [TitleModel_Wanderbell]

    /// 用户关注列表
    var userFollow_Wanderbell: [PrewUserModel_Wanderbell]
    
    /// 初始化
    init(userId_Wanderbell: Int? = nil,
         userPwd_Wanderbell: String? = nil,
         userName_Wanderbell: String? = nil,
         userHead_Wanderbell: String? = nil,
         userPosts_Wanderbell: [TitleModel_Wanderbell],
         userLike_Wanderbell: [TitleModel_Wanderbell],
         userFollow_Wanderbell: [PrewUserModel_Wanderbell]) {
        self.userId_Wanderbell = userId_Wanderbell
        self.userPwd_Wanderbell = userPwd_Wanderbell
        self.userName_Wanderbell = userName_Wanderbell
        self.userHead_Wanderbell = userHead_Wanderbell
        self.userPosts_Wanderbell = userPosts_Wanderbell
        self.userLike_Wanderbell = userLike_Wanderbell
        self.userFollow_Wanderbell = userFollow_Wanderbell
    }
}

/// 消息数据模型
class MessageModel_Wanderbell: Codable {
    
    /// 消息ID
    var messageId_Wanderbell: Int?
    
    /// 消息内容
    var content_Wanderbell: String?
    
    /// 用户头像
    var userHead_Wanderbell: String?
    
    /// 是否是我发送的
    var isMine_Wanderbell: Bool?
    
    /// 消息时间
    var time_Wanderbell: String?
    
    /// 初始化
    init(messageId_wanderbell: Int? = nil,
         content_wanderbell: String? = nil,
         userHead_wanderbell: String? = nil,
         isMine_wanderbell: Bool? = nil,
         time_wanderbell: String? = nil) {
        self.messageId_Wanderbell = messageId_wanderbell
        self.content_Wanderbell = content_wanderbell
        self.userHead_Wanderbell = userHead_wanderbell
        self.isMine_Wanderbell = isMine_wanderbell
        self.time_Wanderbell = time_wanderbell
    }
}

/// 评论模型
class Comment_Wanderbell: NSObject, Codable {
    
    /// 评论ID
    var commentId_Wanderbell: Int
    
    /// 评论用户uid
    var commentUserId_Wanderbell: Int
    
    /// 评论用户昵称
    var commentUserName_Wanderbell: String
    
    /// 评论内容
    var commentContent_Wanderbell: String
    
    /// 初始化
    init(commentId_Wanderbell: Int,
         commentUserId_Wanderbell: Int,
         commentUserName_Wanderbell: String,
         commentContent_Wanderbell: String) {
        self.commentId_Wanderbell = commentId_Wanderbell
        self.commentUserId_Wanderbell = commentUserId_Wanderbell
        self.commentUserName_Wanderbell = commentUserName_Wanderbell
        self.commentContent_Wanderbell = commentContent_Wanderbell
    }
}
