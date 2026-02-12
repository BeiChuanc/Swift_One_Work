import Foundation

// MARK: - 数据模型定义

/// 预览用户数据模型
class PrewUserModel_platbell: NSObject, Codable {
    
    /// 用户ID
    var userId_platbell: Int?
    
    /// 用户名字
    var userName_platbell: String?
    
    /// 用户简介
    var userIntroduce_platbell: String?
    
    /// 用户头像
    var userHead_platbell: String?
    
    /// 用户媒体
    var userMedia_platbell: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_platbell: [TitleModel_platbell] = []
    
    /// 用户关注数
    var userFollow_platbell: Int?
    
    /// 用户粉丝数
    var userFans_platbell: Int?
    
    /// 初始化方法
    override init() {
        super.init()
    }
    
    /// 自定义初始化方法
    init(userId_platbell: Int? = nil,
         userName_platbell: String? = nil,
         userIntroduce_platbell: String? = nil,
         userHead_platbell: String? = nil,
         userMedia_platbell: [String]? = nil,
         userLike_platbell: [TitleModel_platbell] = [],
         userFollow_platbell: Int? = nil,
         userFans_platbell: Int? = nil) {
        self.userId_platbell = userId_platbell
        self.userName_platbell = userName_platbell
        self.userIntroduce_platbell = userIntroduce_platbell
        self.userHead_platbell = userHead_platbell
        self.userMedia_platbell = userMedia_platbell
        self.userLike_platbell = userLike_platbell
        self.userFollow_platbell = userFollow_platbell
        self.userFans_platbell = userFans_platbell
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_platbell: NSObject, Codable, Identifiable {
    
    /// 帖子唯一标识符，用于 Identifiable 协议
    var id: Int { titleId_platbell }
    
    /// 帖子ID
    var titleId_platbell: Int
    
    /// 拥有者ID
    var titleUserId_platbell: Int
    
    /// 拥有者昵称
    var titleUserName_platbell: String
    
    /// 帖子媒体资源数组
    var titleMeidas_platbell: [String]
    
    /// 帖子标题
    var title_platbell: String
    
    /// 帖子内容
    var titleContent_platbell: String
    
    /// 帖子评论列表
    var reviews_platbell: [Comment_platbell]
    
    /// 喜欢个数
    var likes_platbell: Int
    
    /// 帖子类型（0=普通帖子，1=话题帖子）
    var type_platbell: Int
    
    /// 话题标签列表（可为空，话题帖子时包含标签）
    var tags_platbell: [String]
    
    /// 初始化方法
    init(titleId_platbell: Int,
         titleUserId_platbell: Int,
         titleUserName_platbell: String,
         titleMeidas_platbell: [String],
         title_platbell: String,
         titleContent_platbell: String,
         reviews_platbell: [Comment_platbell],
         likes_platbell: Int,
         type_platbell: Int = 0,
         tags_platbell: [String] = []) {
        self.titleId_platbell = titleId_platbell
        self.titleUserId_platbell = titleUserId_platbell
        self.titleUserName_platbell = titleUserName_platbell
        self.titleMeidas_platbell = titleMeidas_platbell
        self.title_platbell = title_platbell
        self.titleContent_platbell = titleContent_platbell
        self.reviews_platbell = reviews_platbell
        self.likes_platbell = likes_platbell
        self.type_platbell = type_platbell
        self.tags_platbell = tags_platbell
        super.init()
    }
}

/// 登录用户数据模型
class LoginUserModel_platbell: NSObject, Codable, Identifiable {
    
    /// 用户唯一标识符，用于 Identifiable 协议
    var id: Int? { userId_platbell }
    
    /// 用户ID
    var userId_platbell: Int?
    
    /// 用户密码
    var userPwd_platbell: String?
    
    /// 用户名称
    var userName_platbell: String?
    
    /// 用户头像
    var userHead_platbell: String?

    /// 用户简介
    var userIntroduce_platbell: String?

    /// 用户封面
    var userCover_platbell: String?
    
    /// 用户发布帖子列表
    var userPosts_platbell: [TitleModel_platbell]
    
    /// 用户喜欢帖子列表
    var userLike_platbell: [TitleModel_platbell]
    
    /// 用户关注列表
    var userFollow_platbell: [PrewUserModel_platbell]
    
    // MARK: - 打卡数据
    
    /// 连续打卡天数
    var checkInStreak_platbell: Int = 0
    
    /// 本周打卡次数
    var checkInThisWeek_platbell: Int = 0
    
    /// 总打卡次数
    var totalCheckIns_platbell: Int = 0
    
    /// 打卡排名
    var checkInRanking_platbell: Int = 0
    
    /// 打卡积分
    var checkInPoints_platbell: Int = 0
    
    /// 最后打卡日期（格式：yyyy-MM-dd）
    var lastCheckInDate_platbell: String?
    
    /// 初始化方法
    init(userId_platbell: Int? = nil,
         userPwd_platbell: String? = nil,
         userName_platbell: String? = nil,
         userHead_platbell: String? = nil,
         userIntroduce_platbell: String? = nil,
         userCover_platbell: String? = nil,
         userPosts_platbell: [TitleModel_platbell],
         userLike_platbell: [TitleModel_platbell],
         userFollow_platbell: [PrewUserModel_platbell],
         checkInStreak_platbell: Int = 0,
         checkInThisWeek_platbell: Int = 0,
         totalCheckIns_platbell: Int = 0,
         checkInRanking_platbell: Int = 0,
         checkInPoints_platbell: Int = 0,
         lastCheckInDate_platbell: String? = nil) {
        self.userId_platbell = userId_platbell
        self.userPwd_platbell = userPwd_platbell
        self.userName_platbell = userName_platbell
        self.userHead_platbell = userHead_platbell
        self.userIntroduce_platbell = userIntroduce_platbell
        self.userCover_platbell = userCover_platbell
        self.userPosts_platbell = userPosts_platbell
        self.userLike_platbell = userLike_platbell
        self.userFollow_platbell = userFollow_platbell
        self.checkInStreak_platbell = checkInStreak_platbell
        self.checkInThisWeek_platbell = checkInThisWeek_platbell
        self.totalCheckIns_platbell = totalCheckIns_platbell
        self.checkInRanking_platbell = checkInRanking_platbell
        self.checkInPoints_platbell = checkInPoints_platbell
        self.lastCheckInDate_platbell = lastCheckInDate_platbell
        super.init()
    }
}

/// 消息数据模型
class MessageModel_platbell: Codable, Identifiable {
    
    /// 消息唯一标识符，用于 Identifiable 协议
    var id: Int? { messageId_platbell }
    
    /// 消息ID
    var messageId_platbell: Int?
    
    /// 消息内容
    var content_platbell: String?
    
    /// 用户头像
    var userHead_platbell: String?
    
    /// 是否是我发送的
    var isMine_platbell: Bool?
    
    /// 消息时间
    var time_platbell: String?
    
    /// 初始化方法
    init(messageId_platbell: Int? = nil,
         content_platbell: String? = nil,
         userHead_platbell: String? = nil,
         isMine_platbell: Bool? = nil,
         time_platbell: String? = nil) {
        self.messageId_platbell = messageId_platbell
        self.content_platbell = content_platbell
        self.userHead_platbell = userHead_platbell
        self.isMine_platbell = isMine_platbell
        self.time_platbell = time_platbell
    }
}

/// 评论数据模型
class Comment_platbell: NSObject, Codable, Identifiable {
    
    /// 评论唯一标识符，用于 Identifiable 协议
    var id: Int { commentId_platbell }
    
    /// 评论ID
    var commentId_platbell: Int
    
    /// 评论用户ID
    var commentUserId_platbell: Int
    
    /// 评论用户昵称
    var commentUserName_platbell: String
    
    /// 评论内容
    var commentContent_platbell: String
    
    /// 初始化方法
    init(commentId_platbell: Int,
         commentUserId_platbell: Int,
         commentUserName_platbell: String,
         commentContent_platbell: String) {
        self.commentId_platbell = commentId_platbell
        self.commentUserId_platbell = commentUserId_platbell
        self.commentUserName_platbell = commentUserName_platbell
        self.commentContent_platbell = commentContent_platbell
        super.init()
    }
}

/// 礼物数据模型
class StoreModel_platbell: NSObject {
    
    /// ID编号
    var id_platbell: Int?
    
    /// 商品ID
    var goodsId_platbell: String?
    
    /// 商品名字
    var goodsName_platbell: String?
    
    /// 商品价格
    var goodsPrice_platbell: String?
    
    /// 是否顶部商品
    var goodIsTop_platbell: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_platbell: Bool?
    
    init(id_platbell: Int? = nil,
         goodsId_platbell: String? = nil,
         goodsName_platbell: String? = nil,
         goodsPrice_platbell: String? = nil,
         goodIsTop_platbell: Bool? = false,
         goodIsLimit_platbell: Bool? = false) {
        self.id_platbell = id_platbell
        self.goodsId_platbell = goodsId_platbell
        self.goodsName_platbell = goodsName_platbell
        self.goodsPrice_platbell = goodsPrice_platbell
        self.goodIsTop_platbell = goodIsTop_platbell
        self.goodIsSpecial_platbell = goodIsLimit_platbell
        super.init()
    }
}

