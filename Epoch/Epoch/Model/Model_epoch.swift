import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Epoch: NSObject, Codable {
    
    /// 用户ID
    var userId_Epoch: Int?
    
    /// 用户名字
    var userName_Epoch: String?
    
    /// 用户简介
    var userIntroduce_Epoch: String?
    
    /// 用户头像
    var userHead_Epoch: String?
    
    /// 用户媒体
    var userMedia_Epoch: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Epoch: [TitleModel_Epoch] = []

    /// 用户关注数
    var userFollow_Epoch: Int?

    /// 用户粉丝数
    var userFans_Epoch: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Epoch: Int? = nil,
         userName_Epoch: String? = nil,
         userIntroduce_Epoch: String? = nil,
         userHead_Epoch: String? = nil,
         userMedia_Epoch: [String]? = nil,
         userLike_Epoch: [TitleModel_Epoch] = [],
         userFollow_Epoch: Int? = nil,
         userFans_Epoch: Int? = nil) {
        self.userId_Epoch = userId_Epoch
        self.userName_Epoch = userName_Epoch
        self.userIntroduce_Epoch = userIntroduce_Epoch
        self.userHead_Epoch = userHead_Epoch
        self.userMedia_Epoch = userMedia_Epoch
        self.userLike_Epoch = userLike_Epoch
        self.userFollow_Epoch = userFollow_Epoch
        self.userFans_Epoch = userFans_Epoch
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Epoch: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Epoch: Int
    
    /// 拥有者ID
    var titleUserId_Epoch: Int
    
    /// 拥有者昵称
    var titleUserName_Epoch: String
    
    /// 帖子媒体
    var titleMeidas_Epoch: [String]
    
    /// 帖子标题
    var title_Epoch: String
    
    /// 帖子内容
    var titleContent_Epoch: String
    
    /// 帖子评论列表
    var reviews_Epoch: [Comment_Epoch]
    
    /// 喜欢个数
    var likes_Epoch: Int
    
    init(titleId_Epoch: Int,
         titleUserId_Epoch: Int,
         titleUserName_Epoch: String,
         titleMeidas_Epoch: [String],
         title_Epoch: String,
         titleContent_Epoch: String,
         reviews_Epoch: [Comment_Epoch],
         likes_Epoch: Int) {
        self.titleId_Epoch = titleId_Epoch
        self.titleUserId_Epoch = titleUserId_Epoch
        self.titleUserName_Epoch = titleUserName_Epoch
        self.titleMeidas_Epoch = titleMeidas_Epoch
        self.title_Epoch = title_Epoch
        self.titleContent_Epoch = titleContent_Epoch
        self.reviews_Epoch = reviews_Epoch
        self.likes_Epoch = likes_Epoch
    }
    
}

/// 首页仪式场景小贴士模型
/// 核心作用：统一描述首页不同仪式场景下的布置建议内容
/// 设计思路：将场景名、标题、说明和图标拆分存储，便于首页横向卡片复用
class HomeSceneTipModel_Epoch: NSObject {

    /// 场景名称
    var sceneName_Epoch: String

    /// 小贴士标题
    var tipTitle_Epoch: String

    /// 小贴士详情
    var tipDetail_Epoch: String

    /// 小贴士扩展说明
    var tipExtendedDetail_Epoch: String

    /// 小贴士执行清单
    var tipChecklist_Epoch: [String]

    /// 图标名称
    var iconName_Epoch: String

    /// 初始化首页贴士模型
    /// - Parameters:
    ///   - sceneName_Epoch: 仪式场景名称
    ///   - tipTitle_Epoch: 小贴士标题
    ///   - tipDetail_Epoch: 小贴士详情
    ///   - tipExtendedDetail_Epoch: 小贴士扩展说明
    ///   - tipChecklist_Epoch: 小贴士执行清单
    ///   - iconName_Epoch: 场景图标名称
    init(
        sceneName_Epoch: String,
        tipTitle_Epoch: String,
        tipDetail_Epoch: String,
        tipExtendedDetail_Epoch: String,
        tipChecklist_Epoch: [String],
        iconName_Epoch: String
    ) {
        self.sceneName_Epoch = sceneName_Epoch
        self.tipTitle_Epoch = tipTitle_Epoch
        self.tipDetail_Epoch = tipDetail_Epoch
        self.tipExtendedDetail_Epoch = tipExtendedDetail_Epoch
        self.tipChecklist_Epoch = tipChecklist_Epoch
        self.iconName_Epoch = iconName_Epoch
        super.init()
    }
}

/// 登录用户数据模型
class LoginUserModel_Epoch: NSObject, Codable {
    
    /// 用户ID
    var userId_Epoch: Int?
    
    /// 用户密码
    var userPwd_Epoch: String?
    
    /// 用户名称
    var userName_Epoch: String?

    /// 用户简介
    var userIntroduce_Epoch: String?
    
    /// 用户头像
    var userHead_Epoch: String?
    
    /// 用户发布帖子列表
    var userPosts_Epoch: [TitleModel_Epoch]

    /// 用户首页贴纸墙作品
    var userMomentWall_Epoch: [TitleModel_Epoch]
    
    /// 用户喜欢帖子列表
    var userLike_Epoch: [TitleModel_Epoch]

    /// 用户关注列表
    var userFollow_Epoch: [PrewUserModel_Epoch]
    
    /// 初始化
    init(userId_Epoch: Int? = nil,
         userPwd_Epoch: String? = nil,
         userName_Epoch: String? = nil,
         userIntroduce_Epoch: String? = nil,
         userHead_Epoch: String? = nil,
         userPosts_Epoch: [TitleModel_Epoch],
         userMomentWall_Epoch: [TitleModel_Epoch],
         userLike_Epoch: [TitleModel_Epoch],
         userFollow_Epoch: [PrewUserModel_Epoch]) {
        self.userId_Epoch = userId_Epoch
        self.userPwd_Epoch = userPwd_Epoch
        self.userName_Epoch = userName_Epoch
        self.userIntroduce_Epoch = userIntroduce_Epoch
        self.userHead_Epoch = userHead_Epoch
        self.userPosts_Epoch = userPosts_Epoch
        self.userMomentWall_Epoch = userMomentWall_Epoch
        self.userLike_Epoch = userLike_Epoch
        self.userFollow_Epoch = userFollow_Epoch
    }
}

/// 消息数据模型
class MessageModel_Epoch: Codable {
    
    /// 消息ID
    var messageId_Epoch: Int?
    
    /// 消息内容
    var content_Epoch: String?
    
    /// 用户头像
    var userHead_Epoch: String?
    
    /// 是否是我发送的
    var isMine_Epoch: Bool?
    
    /// 消息时间
    var time_Epoch: String?
    
    /// 初始化
    init(messageId_epoch: Int? = nil,
         content_epoch: String? = nil,
         userHead_epoch: String? = nil,
         isMine_epoch: Bool? = nil,
         time_epoch: String? = nil) {
        self.messageId_Epoch = messageId_epoch
        self.content_Epoch = content_epoch
        self.userHead_Epoch = userHead_epoch
        self.isMine_Epoch = isMine_epoch
        self.time_Epoch = time_epoch
    }
}

/// 评论模型
class Comment_Epoch: NSObject, Codable {
    
    /// 评论ID
    var commentId_Epoch: Int
    
    /// 评论用户uid
    var commentUserId_Epoch: Int
    
    /// 评论用户昵称
    var commentUserName_Epoch: String
    
    /// 评论内容
    var commentContent_Epoch: String
    
    /// 初始化
    init(commentId_Epoch: Int,
         commentUserId_Epoch: Int,
         commentUserName_Epoch: String,
         commentContent_Epoch: String) {
        self.commentId_Epoch = commentId_Epoch
        self.commentUserId_Epoch = commentUserId_Epoch
        self.commentUserName_Epoch = commentUserName_Epoch
        self.commentContent_Epoch = commentContent_Epoch
    }
}

/// 商店模型
class StoreModel_Epoch: NSObject {
    
    /// ID编号
    var id_Epoch: Int?
    
    /// 商品ID
    var goodsId_Epoch: String?
    
    /// 商品名字
    var goodsName_Epoch: String?
    
    /// 商品价格
    var goodsPrice_Epoch: String?
    
    /// 是否顶部商品
    var goodIsTop_Epoch: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Epoch: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Epoch: Bool?
    
    init(id_Epoch: Int? = nil,
         goodsId_Epoch: String? = nil,
         goodsName_Epoch: String? = nil,
         goodsPrice_Epoch: String? = nil,
         goodIsTop_Epoch: Bool? = false,
         goodIsLimit_Epoch: Bool? = false,
         goodIsVIP_Epoch: Bool? = false) {
        self.id_Epoch = id_Epoch
        self.goodsId_Epoch = goodsId_Epoch
        self.goodsName_Epoch = goodsName_Epoch
        self.goodsPrice_Epoch = goodsPrice_Epoch
        self.goodIsTop_Epoch = goodIsTop_Epoch
        self.goodIsSpecial_Epoch = goodIsLimit_Epoch
        self.goodIsVIP_Epoch = goodIsVIP_Epoch
        super.init()
    }
}
