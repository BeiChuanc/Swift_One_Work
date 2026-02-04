import Foundation

// MARK: - 数据模型定义

/// 预览用户数据模型
class PrewUserModel_baseswiftui: NSObject, Codable {
    
    /// 用户ID
    var userId_baseswiftui: Int?
    
    /// 用户名字
    var userName_baseswiftui: String?
    
    /// 用户简介
    var userIntroduce_baseswiftui: String?
    
    /// 用户头像
    var userHead_baseswiftui: String?
    
    /// 用户媒体
    var userMedia_baseswiftui: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_baseswiftui: [TitleModel_baseswiftui] = []
    
    /// 用户关注数
    var userFollow_baseswiftui: Int?
    
    /// 用户粉丝数
    var userFans_baseswiftui: Int?
    
    /// 初始化方法
    override init() {
        super.init()
    }
    
    /// 自定义初始化方法
    init(userId_baseswiftui: Int? = nil,
         userName_baseswiftui: String? = nil,
         userIntroduce_baseswiftui: String? = nil,
         userHead_baseswiftui: String? = nil,
         userMedia_baseswiftui: [String]? = nil,
         userLike_baseswiftui: [TitleModel_baseswiftui] = [],
         userFollow_baseswiftui: Int? = nil,
         userFans_baseswiftui: Int? = nil) {
        self.userId_baseswiftui = userId_baseswiftui
        self.userName_baseswiftui = userName_baseswiftui
        self.userIntroduce_baseswiftui = userIntroduce_baseswiftui
        self.userHead_baseswiftui = userHead_baseswiftui
        self.userMedia_baseswiftui = userMedia_baseswiftui
        self.userLike_baseswiftui = userLike_baseswiftui
        self.userFollow_baseswiftui = userFollow_baseswiftui
        self.userFans_baseswiftui = userFans_baseswiftui
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_baseswiftui: NSObject, Codable, Identifiable {
    
    /// 帖子唯一标识符，用于 Identifiable 协议
    var id: Int { titleId_baseswiftui }
    
    /// 帖子ID
    var titleId_baseswiftui: Int
    
    /// 拥有者ID
    var titleUserId_baseswiftui: Int
    
    /// 拥有者昵称
    var titleUserName_baseswiftui: String
    
    /// 帖子媒体资源数组
    var titleMeidas_baseswiftui: [String]
    
    /// 帖子标题
    var title_baseswiftui: String
    
    /// 帖子内容
    var titleContent_baseswiftui: String
    
    /// 帖子评论列表
    var reviews_baseswiftui: [Comment_baseswiftui]
    
    /// 喜欢个数
    var likes_baseswiftui: Int
    
    /// 初始化方法
    init(titleId_baseswiftui: Int,
         titleUserId_baseswiftui: Int,
         titleUserName_baseswiftui: String,
         titleMeidas_baseswiftui: [String],
         title_baseswiftui: String,
         titleContent_baseswiftui: String,
         reviews_baseswiftui: [Comment_baseswiftui],
         likes_baseswiftui: Int) {
        self.titleId_baseswiftui = titleId_baseswiftui
        self.titleUserId_baseswiftui = titleUserId_baseswiftui
        self.titleUserName_baseswiftui = titleUserName_baseswiftui
        self.titleMeidas_baseswiftui = titleMeidas_baseswiftui
        self.title_baseswiftui = title_baseswiftui
        self.titleContent_baseswiftui = titleContent_baseswiftui
        self.reviews_baseswiftui = reviews_baseswiftui
        self.likes_baseswiftui = likes_baseswiftui
        super.init()
    }
}

/// 登录用户数据模型
class LoginUserModel_baseswiftui: NSObject, Codable, Identifiable {
    
    /// 用户唯一标识符，用于 Identifiable 协议
    var id: Int? { userId_baseswiftui }
    
    /// 用户ID
    var userId_baseswiftui: Int?
    
    /// 用户密码
    var userPwd_baseswiftui: String?
    
    /// 用户名称
    var userName_baseswiftui: String?
    
    /// 用户头像
    var userHead_baseswiftui: String?

    /// 用户简介
    var userIntroduce_baseswiftui: String?

    /// 用户封面
    var userCover_baseswiftui: String?
    
    /// 用户发布帖子列表
    var userPosts_baseswiftui: [TitleModel_baseswiftui]
    
    /// 用户喜欢帖子列表
    var userLike_baseswiftui: [TitleModel_baseswiftui]
    
    /// 用户关注列表
    var userFollow_baseswiftui: [PrewUserModel_baseswiftui]
    
    /// 初始化方法
    init(userId_baseswiftui: Int? = nil,
         userPwd_baseswiftui: String? = nil,
         userName_baseswiftui: String? = nil,
         userHead_baseswiftui: String? = nil,
         userIntroduce_baseswiftui: String? = nil,
         userCover_baseswiftui: String? = nil,
         userPosts_baseswiftui: [TitleModel_baseswiftui],
         userLike_baseswiftui: [TitleModel_baseswiftui],
         userFollow_baseswiftui: [PrewUserModel_baseswiftui]) {
        self.userId_baseswiftui = userId_baseswiftui
        self.userPwd_baseswiftui = userPwd_baseswiftui
        self.userName_baseswiftui = userName_baseswiftui
        self.userHead_baseswiftui = userHead_baseswiftui
        self.userIntroduce_baseswiftui = userIntroduce_baseswiftui
        self.userCover_baseswiftui = userCover_baseswiftui
        self.userPosts_baseswiftui = userPosts_baseswiftui
        self.userLike_baseswiftui = userLike_baseswiftui
        self.userFollow_baseswiftui = userFollow_baseswiftui
        super.init()
    }
}

/// 消息数据模型
class MessageModel_baseswiftui: Codable, Identifiable {
    
    /// 消息唯一标识符，用于 Identifiable 协议
    var id: Int? { messageId_baseswiftui }
    
    /// 消息ID
    var messageId_baseswiftui: Int?
    
    /// 消息内容
    var content_baseswiftui: String?
    
    /// 用户头像
    var userHead_baseswiftui: String?
    
    /// 是否是我发送的
    var isMine_baseswiftui: Bool?
    
    /// 消息时间
    var time_baseswiftui: String?
    
    /// 初始化方法
    init(messageId_baseswiftui: Int? = nil,
         content_baseswiftui: String? = nil,
         userHead_baseswiftui: String? = nil,
         isMine_baseswiftui: Bool? = nil,
         time_baseswiftui: String? = nil) {
        self.messageId_baseswiftui = messageId_baseswiftui
        self.content_baseswiftui = content_baseswiftui
        self.userHead_baseswiftui = userHead_baseswiftui
        self.isMine_baseswiftui = isMine_baseswiftui
        self.time_baseswiftui = time_baseswiftui
    }
}

/// 评论数据模型
class Comment_baseswiftui: NSObject, Codable, Identifiable {
    
    /// 评论唯一标识符，用于 Identifiable 协议
    var id: Int { commentId_baseswiftui }
    
    /// 评论ID
    var commentId_baseswiftui: Int
    
    /// 评论用户ID
    var commentUserId_baseswiftui: Int
    
    /// 评论用户昵称
    var commentUserName_baseswiftui: String
    
    /// 评论内容
    var commentContent_baseswiftui: String
    
    /// 初始化方法
    init(commentId_baseswiftui: Int,
         commentUserId_baseswiftui: Int,
         commentUserName_baseswiftui: String,
         commentContent_baseswiftui: String) {
        self.commentId_baseswiftui = commentId_baseswiftui
        self.commentUserId_baseswiftui = commentUserId_baseswiftui
        self.commentUserName_baseswiftui = commentUserName_baseswiftui
        self.commentContent_baseswiftui = commentContent_baseswiftui
        super.init()
    }
}
