import Foundation

// MARK: - 数据模型定义

/// 预览用户数据模型
class PrewUserModel_lite: NSObject, Codable {
    
    /// 用户ID
    var userId_lite: Int?
    
    /// 用户名字
    var userName_lite: String?
    
    /// 用户简介
    var userIntroduce_lite: String?
    
    /// 用户头像
    var userHead_lite: String?
    
    /// 用户媒体
    var userMedia_lite: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_lite: [TitleModel_lite] = []
    
    /// 用户关注数
    var userFollow_lite: Int?
    
    /// 用户粉丝数
    var userFans_lite: Int?
    
    /// 初始化方法
    override init() {
        super.init()
    }
    
    /// 自定义初始化方法
    init(userId_lite: Int? = nil,
         userName_lite: String? = nil,
         userIntroduce_lite: String? = nil,
         userHead_lite: String? = nil,
         userMedia_lite: [String]? = nil,
         userLike_lite: [TitleModel_lite] = [],
         userFollow_lite: Int? = nil,
         userFans_lite: Int? = nil) {
        self.userId_lite = userId_lite
        self.userName_lite = userName_lite
        self.userIntroduce_lite = userIntroduce_lite
        self.userHead_lite = userHead_lite
        self.userMedia_lite = userMedia_lite
        self.userLike_lite = userLike_lite
        self.userFollow_lite = userFollow_lite
        self.userFans_lite = userFans_lite
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_lite: NSObject, Codable, Identifiable {
    
    /// 帖子唯一标识符，用于 Identifiable 协议
    var id: Int { titleId_lite }
    
    /// 帖子ID
    var titleId_lite: Int
    
    /// 拥有者ID
    var titleUserId_lite: Int
    
    /// 拥有者昵称
    var titleUserName_lite: String
    
    /// 帖子媒体资源数组
    var titleMeidas_lite: [String]
    
    /// 帖子标题
    var title_lite: String
    
    /// 帖子内容
    var titleContent_lite: String
    
    /// 帖子评论列表
    var reviews_lite: [Comment_lite]
    
    /// 喜欢个数
    var likes_lite: Int
    
    /// 初始化方法
    init(titleId_lite: Int,
         titleUserId_lite: Int,
         titleUserName_lite: String,
         titleMeidas_lite: [String],
         title_lite: String,
         titleContent_lite: String,
         reviews_lite: [Comment_lite],
         likes_lite: Int) {
        self.titleId_lite = titleId_lite
        self.titleUserId_lite = titleUserId_lite
        self.titleUserName_lite = titleUserName_lite
        self.titleMeidas_lite = titleMeidas_lite
        self.title_lite = title_lite
        self.titleContent_lite = titleContent_lite
        self.reviews_lite = reviews_lite
        self.likes_lite = likes_lite
        super.init()
    }
}

/// 登录用户数据模型
class LoginUserModel_lite: NSObject, Codable, Identifiable {
    
    /// 用户唯一标识符，用于 Identifiable 协议
    var id: Int? { userId_lite }
    
    /// 用户ID
    var userId_lite: Int?
    
    /// 用户密码
    var userPwd_lite: String?
    
    /// 用户名称
    var userName_lite: String?
    
    /// 用户头像
    var userHead_lite: String?

    /// 用户简介
    var userIntroduce_lite: String?

    /// 用户封面
    var userCover_lite: String?
    
    /// 用户发布帖子列表
    var userPosts_lite: [TitleModel_lite]
    
    /// 用户喜欢帖子列表
    var userLike_lite: [TitleModel_lite]
    
    /// 用户关注列表
    var userFollow_lite: [PrewUserModel_lite]
    
    /// 初始化方法
    init(userId_lite: Int? = nil,
         userPwd_lite: String? = nil,
         userName_lite: String? = nil,
         userHead_lite: String? = nil,
         userIntroduce_lite: String? = nil,
         userCover_lite: String? = nil,
         userPosts_lite: [TitleModel_lite],
         userLike_lite: [TitleModel_lite],
         userFollow_lite: [PrewUserModel_lite]) {
        self.userId_lite = userId_lite
        self.userPwd_lite = userPwd_lite
        self.userName_lite = userName_lite
        self.userHead_lite = userHead_lite
        self.userIntroduce_lite = userIntroduce_lite
        self.userCover_lite = userCover_lite
        self.userPosts_lite = userPosts_lite
        self.userLike_lite = userLike_lite
        self.userFollow_lite = userFollow_lite
        super.init()
    }
}

/// 消息数据模型
class MessageModel_lite: Codable, Identifiable {
    
    /// 消息唯一标识符，用于 Identifiable 协议
    var id: Int? { messageId_lite }
    
    /// 消息ID
    var messageId_lite: Int?
    
    /// 消息内容
    var content_lite: String?
    
    /// 用户头像
    var userHead_lite: String?
    
    /// 是否是我发送的
    var isMine_lite: Bool?
    
    /// 消息时间
    var time_lite: String?
    
    /// 初始化方法
    init(messageId_lite: Int? = nil,
         content_lite: String? = nil,
         userHead_lite: String? = nil,
         isMine_lite: Bool? = nil,
         time_lite: String? = nil) {
        self.messageId_lite = messageId_lite
        self.content_lite = content_lite
        self.userHead_lite = userHead_lite
        self.isMine_lite = isMine_lite
        self.time_lite = time_lite
    }
}

/// 评论数据模型
class Comment_lite: NSObject, Codable, Identifiable {
    
    /// 评论唯一标识符，用于 Identifiable 协议
    var id: Int { commentId_lite }
    
    /// 评论ID
    var commentId_lite: Int
    
    /// 评论用户ID
    var commentUserId_lite: Int
    
    /// 评论用户昵称
    var commentUserName_lite: String
    
    /// 评论内容
    var commentContent_lite: String
    
    /// 初始化方法
    init(commentId_lite: Int,
         commentUserId_lite: Int,
         commentUserName_lite: String,
         commentContent_lite: String) {
        self.commentId_lite = commentId_lite
        self.commentUserId_lite = commentUserId_lite
        self.commentUserName_lite = commentUserName_lite
        self.commentContent_lite = commentContent_lite
        super.init()
    }
}
