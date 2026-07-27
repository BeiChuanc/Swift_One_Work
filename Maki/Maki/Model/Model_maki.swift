import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Maki: NSObject, Codable {
    
    /// 用户ID
    var userId_Maki: Int?
    
    /// 用户名字
    var userName_Maki: String?
    
    /// 用户简介
    var userIntroduce_Maki: String?
    
    /// 用户头像
    var userHead_Maki: String?
    
    /// 用户媒体
    var userMedia_Maki: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Maki: [TitleModel_Maki] = []

    /// 用户关注数
    var userFollow_Maki: Int?

    /// 用户粉丝数
    var userFans_Maki: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Maki: Int? = nil,
         userName_Maki: String? = nil,
         userIntroduce_Maki: String? = nil,
         userHead_Maki: String? = nil,
         userMedia_Maki: [String]? = nil,
         userLike_Maki: [TitleModel_Maki] = [],
         userFollow_Maki: Int? = nil,
         userFans_Maki: Int? = nil) {
        self.userId_Maki = userId_Maki
        self.userName_Maki = userName_Maki
        self.userIntroduce_Maki = userIntroduce_Maki
        self.userHead_Maki = userHead_Maki
        self.userMedia_Maki = userMedia_Maki
        self.userLike_Maki = userLike_Maki
        self.userFollow_Maki = userFollow_Maki
        self.userFans_Maki = userFans_Maki
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Maki: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Maki: Int
    
    /// 拥有者ID
    var titleUserId_Maki: Int
    
    /// 拥有者昵称
    var titleUserName_Maki: String
    
    /// 帖子媒体
    var titleMeidas_Maki: [String]
    
    /// 帖子标题
    var title_Maki: String
    
    /// 帖子内容
    var titleContent_Maki: String
    
    /// 帖子评论列表
    var reviews_Maki: [Comment_Maki]
    
    /// 喜欢个数
    var likes_Maki: Int
    
    init(titleId_Maki: Int,
         titleUserId_Maki: Int,
         titleUserName_Maki: String,
         titleMeidas_Maki: [String],
         title_Maki: String,
         titleContent_Maki: String,
         reviews_Maki: [Comment_Maki],
         likes_Maki: Int) {
        self.titleId_Maki = titleId_Maki
        self.titleUserId_Maki = titleUserId_Maki
        self.titleUserName_Maki = titleUserName_Maki
        self.titleMeidas_Maki = titleMeidas_Maki
        self.title_Maki = title_Maki
        self.titleContent_Maki = titleContent_Maki
        self.reviews_Maki = reviews_Maki
        self.likes_Maki = likes_Maki
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Maki: NSObject, Codable {
    
    /// 用户ID
    var userId_Maki: Int?
    
    /// 用户密码
    var userPwd_Maki: String?
    
    /// 用户名称
    var userName_Maki: String?
    
    /// 用户自我介绍
    var userIntroduce_Maki: String?
    
    /// 用户头像
    var userHead_Maki: String?
    
    /// 用户发布帖子列表
    var userPosts_Maki: [TitleModel_Maki]
    
    /// 用户喜欢帖子列表
    var userLike_Maki: [TitleModel_Maki]

    /// 用户关注列表
    var userFollow_Maki: [PrewUserModel_Maki]
    
    /// 初始化
    init(userId_Maki: Int? = nil,
         userPwd_Maki: String? = nil,
         userName_Maki: String? = nil,
         userIntroduce_Maki: String? = nil,
         userHead_Maki: String? = nil,
         userPosts_Maki: [TitleModel_Maki],
         userLike_Maki: [TitleModel_Maki],
         userFollow_Maki: [PrewUserModel_Maki]) {
        self.userId_Maki = userId_Maki
        self.userPwd_Maki = userPwd_Maki
        self.userName_Maki = userName_Maki
        self.userIntroduce_Maki = userIntroduce_Maki
        self.userHead_Maki = userHead_Maki
        self.userPosts_Maki = userPosts_Maki
        self.userLike_Maki = userLike_Maki
        self.userFollow_Maki = userFollow_Maki
    }
}

/// 消息数据模型
class MessageModel_Maki: Codable {
    
    /// 消息ID
    var messageId_Maki: Int?
    
    /// 消息内容
    var content_Maki: String?
    
    /// 用户头像
    var userHead_Maki: String?
    
    /// 是否是我发送的
    var isMine_Maki: Bool?
    
    /// 消息时间
    var time_Maki: String?
    
    /// 初始化
    init(messageId_maki: Int? = nil,
         content_maki: String? = nil,
         userHead_maki: String? = nil,
         isMine_maki: Bool? = nil,
         time_maki: String? = nil) {
        self.messageId_Maki = messageId_maki
        self.content_Maki = content_maki
        self.userHead_Maki = userHead_maki
        self.isMine_Maki = isMine_maki
        self.time_Maki = time_maki
    }
}

/// 评论模型
class Comment_Maki: NSObject, Codable {
    
    /// 评论ID
    var commentId_Maki: Int
    
    /// 评论用户uid
    var commentUserId_Maki: Int
    
    /// 评论用户昵称
    var commentUserName_Maki: String
    
    /// 评论内容
    var commentContent_Maki: String
    
    /// 初始化
    init(commentId_Maki: Int,
         commentUserId_Maki: Int,
         commentUserName_Maki: String,
         commentContent_Maki: String) {
        self.commentId_Maki = commentId_Maki
        self.commentUserId_Maki = commentUserId_Maki
        self.commentUserName_Maki = commentUserName_Maki
        self.commentContent_Maki = commentContent_Maki
    }
}

// MARK: - 手作时光胶囊模型

/// 手作时光胶囊模型
/// 功能：记录用户上传的DIY作品成品实拍、制作视频、材料清单、心情与故事，封存至指定开启时间
/// 关键属性：openDate_Maki 决定胶囊解锁时间；isUnlocked_Maki 为计算属性，判断当前是否已到开启时间
class TimeCapsuleModel_Maki: NSObject, Codable {

    /// 胶囊ID
    var capsuleId_Maki: Int

    /// 所属用户ID
    var ownerId_Maki: Int

    /// 成品实拍封面路径
    var coverMedia_Maki: String

    /// 制作步骤视频路径（可选）
    var videoPath_Maki: String?

    /// 材料清单
    var materials_Maki: [String]

    /// 制作当天心情（emoji）
    var mood_Maki: String

    /// 作品赠送对象
    var giftTo_Maki: String

    /// 背后小故事
    var story_Maki: String

    /// 封存日期
    var createDate_Maki: Date

    /// 开启日期，到达后才可查看完整内容
    var openDate_Maki: Date

    /// 是否已被用户查看过（开启后标记为 true）
    var isOpened_Maki: Bool

    /// 是否已到达开启时间（计算属性，不参与编解码）
    var isUnlocked_Maki: Bool { Date() >= openDate_Maki }

    /// 初始化
    init(capsuleId_Maki: Int,
         ownerId_Maki: Int,
         coverMedia_Maki: String,
         videoPath_Maki: String?,
         materials_Maki: [String],
         mood_Maki: String,
         giftTo_Maki: String,
         story_Maki: String,
         createDate_Maki: Date,
         openDate_Maki: Date,
         isOpened_Maki: Bool = false) {
        self.capsuleId_Maki = capsuleId_Maki
        self.ownerId_Maki = ownerId_Maki
        self.coverMedia_Maki = coverMedia_Maki
        self.videoPath_Maki = videoPath_Maki
        self.materials_Maki = materials_Maki
        self.mood_Maki = mood_Maki
        self.giftTo_Maki = giftTo_Maki
        self.story_Maki = story_Maki
        self.createDate_Maki = createDate_Maki
        self.openDate_Maki = openDate_Maki
        self.isOpened_Maki = isOpened_Maki
    }
}

// MARK: - 旧料改造灵感模型

/// 旧料改造灵感模型
/// 功能：系统推荐的剩余材料再造方案，帮助用户为旧材料寻找新用途，形成材料传承记录
class MaterialReuseIdeaModel_Maki: NSObject {

    /// 方案ID
    var ideaId_Maki: Int

    /// 改造前材料描述
    var beforeMaterial_Maki: String

    /// 改造后作品描述
    var afterCreation_Maki: String

    /// 展示封面（Assets 图片名）
    var coverImage_Maki: String

    /// 方案说明
    var description_Maki: String

    /// 难度等级（1-3）
    var difficulty_Maki: Int

    /// 初始化
    init(ideaId_Maki: Int,
         beforeMaterial_Maki: String,
         afterCreation_Maki: String,
         coverImage_Maki: String,
         description_Maki: String,
         difficulty_Maki: Int) {
        self.ideaId_Maki = ideaId_Maki
        self.beforeMaterial_Maki = beforeMaterial_Maki
        self.afterCreation_Maki = afterCreation_Maki
        self.coverImage_Maki = coverImage_Maki
        self.description_Maki = description_Maki
        self.difficulty_Maki = difficulty_Maki
        super.init()
    }
}

/// 商店模型
class StoreModel_Maki: NSObject {
    
    /// ID编号
    var id_Maki: Int?
    
    /// 商品ID
    var goodsId_Maki: String?
    
    /// 商品名字
    var goodsName_Maki: String?
    
    /// 商品价格
    var goodsPrice_Maki: String?
    
    /// 是否顶部商品
    var goodIsTop_Maki: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Maki: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Maki: Bool?
    
    init(id_Maki: Int? = nil,
         goodsId_Maki: String? = nil,
         goodsName_Maki: String? = nil,
         goodsPrice_Maki: String? = nil,
         goodIsTop_Maki: Bool? = false,
         goodIsLimit_Maki: Bool? = false,
         goodIsVIP_Maki: Bool? = false) {
        self.id_Maki = id_Maki
        self.goodsId_Maki = goodsId_Maki
        self.goodsName_Maki = goodsName_Maki
        self.goodsPrice_Maki = goodsPrice_Maki
        self.goodIsTop_Maki = goodIsTop_Maki
        self.goodIsSpecial_Maki = goodIsLimit_Maki
        self.goodIsVIP_Maki = goodIsVIP_Maki
        super.init()
    }
}
