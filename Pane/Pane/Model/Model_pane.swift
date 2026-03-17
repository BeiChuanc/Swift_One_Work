import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Pane: NSObject, Codable {
    
    /// 用户ID
    var userId_Pane: Int?
    
    /// 用户名字
    var userName_Pane: String?
    
    /// 用户简介
    var userIntroduce_Pane: String?
    
    /// 用户头像
    var userHead_Pane: String?
    
    /// 用户媒体
    var userMedia_Pane: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Pane: [TitleModel_Pane] = []

    /// 用户关注数
    var userFollow_Pane: Int?

    /// 用户粉丝数
    var userFans_Pane: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Pane: Int? = nil,
         userName_Pane: String? = nil,
         userIntroduce_Pane: String? = nil,
         userHead_Pane: String? = nil,
         userMedia_Pane: [String]? = nil,
         userLike_Pane: [TitleModel_Pane] = [],
         userFollow_Pane: Int? = nil,
         userFans_Pane: Int? = nil) {
        self.userId_Pane = userId_Pane
        self.userName_Pane = userName_Pane
        self.userIntroduce_Pane = userIntroduce_Pane
        self.userHead_Pane = userHead_Pane
        self.userMedia_Pane = userMedia_Pane
        self.userLike_Pane = userLike_Pane
        self.userFollow_Pane = userFollow_Pane
        self.userFans_Pane = userFans_Pane
        super.init()
    }
}

// MARK: - 窗景主题类型枚举

/// 窗景主题类型
/// 功能：为快速记录提供主题标签，便于分类和展示
enum WindowTheme_Pane: String, CaseIterable, Codable {
    case morningLight_pane = "🌅 Morning Light"
    case sunset_pane       = "🌇 Sunset"
    case nightView_pane    = "🌃 Night View"
    case rainyDay_pane     = "🌧 Rainy Day"
    case fourSeasons_pane  = "🍂 Four Seasons"
    case cityView_pane     = "🏙 City View"
    case nature_pane       = "🌿 Nature"
    case windowView_pane   = "🪟 Window"
}

/// 帖子数据模型
class TitleModel_Pane: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Pane: Int
    
    /// 拥有者ID
    var titleUserId_Pane: Int
    
    /// 拥有者昵称
    var titleUserName_Pane: String
    
    /// 帖子媒体
    var titleMeidas_Pane: [String]
    
    /// 帖子标题
    var title_Pane: String
    
    /// 帖子内容
    var titleContent_Pane: String
    
    /// 帖子评论列表
    var reviews_Pane: [Comment_Pane]
    
    /// 喜欢个数
    var likes_Pane: Int
    
    /// 发布日期（格式：yyyy-MM-dd），用于月度日历可视化
    var titleDate_Pane: String
    
    /// 窗景主题类型标签（快速记录时赋值）
    var titleTheme_Pane: String
    
    init(titleId_Pane: Int,
         titleUserId_Pane: Int,
         titleUserName_Pane: String,
         titleMeidas_Pane: [String],
         title_Pane: String,
         titleContent_Pane: String,
         reviews_Pane: [Comment_Pane],
         likes_Pane: Int,
         titleDate_Pane: String = "",
         titleTheme_Pane: String = "") {
        self.titleId_Pane = titleId_Pane
        self.titleUserId_Pane = titleUserId_Pane
        self.titleUserName_Pane = titleUserName_Pane
        self.titleMeidas_Pane = titleMeidas_Pane
        self.title_Pane = title_Pane
        self.titleContent_Pane = titleContent_Pane
        self.reviews_Pane = reviews_Pane
        self.likes_Pane = likes_Pane
        self.titleDate_Pane = titleDate_Pane.isEmpty
            ? TitleModel_Pane.todayDateString_Pane()
            : titleDate_Pane
        self.titleTheme_Pane = titleTheme_Pane
    }
    
    /// 返回当天日期字符串（yyyy-MM-dd）
    private static func todayDateString_Pane() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}

// MARK: - 窗景册模型

/// 自定义窗景册数据模型
/// 核心作用：存储用户创建的窗景主题相册，将同主题帖子归类整理
/// 存储方式：UserDefaults JSON 编码，按用户 ID 隔离
class WindowAlbum_Pane: NSObject, Codable {
    
    /// 相册唯一 ID（UUID 字符串）
    var albumId_Pane: String
    
    /// 相册名称
    var albumName_Pane: String
    
    /// 封面 Emoji
    var albumEmoji_Pane: String
    
    /// 相册描述
    var albumDesc_Pane: String
    
    /// 包含的帖子 ID 列表
    var postIds_Pane: [Int]
    
    /// 创建日期（格式：yyyy-MM-dd）
    var createdAt_Pane: String

    /// 本地图片文件名列表（存储在 Documents 目录，供相册详情页展示）
    /// 可选类型以兼容历史数据（旧数据中无此字段时解码为 nil）
    var imagePaths_Pane: [String]?
    
    /// 初始化
    /// - Parameters:
    ///   - albumName_pane: 相册名称
    ///   - albumEmoji_pane: 封面 Emoji
    ///   - albumDesc_pane: 相册描述
    init(albumName_pane: String,
         albumEmoji_pane: String = "🪟",
         albumDesc_pane: String = "") {
        self.albumId_Pane    = UUID().uuidString
        self.albumName_Pane  = albumName_pane
        self.albumEmoji_Pane = albumEmoji_pane
        self.albumDesc_Pane  = albumDesc_pane
        self.postIds_Pane    = []
        self.imagePaths_Pane = []
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        self.createdAt_Pane = f.string(from: Date())
    }
}

/// 登录用户数据模型
class LoginUserModel_Pane: NSObject, Codable {
    
    /// 用户ID
    var userId_Pane: Int?
    
    /// 用户名称
    var userName_Pane: String?
    
    /// 用户头像
    var userHead_Pane: String?
    
    /// 用户发布帖子列表
    var userPosts_Pane: [TitleModel_Pane]
    
    /// 用户喜欢帖子列表
    var userLike_Pane: [TitleModel_Pane]

    /// 用户关注列表
    var userFollow_Pane: [PrewUserModel_Pane]

    /// 打卡日期记录（格式 yyyy-MM-dd），供首页日历可视化使用
    var userCheckInDates_Pane: [String]

    /// 专属窗景册列表，供首页窗景册区块使用
    var userWindowAlbums_Pane: [WindowAlbum_Pane]

    /// 用户个人简介
    var userIntroduce_Pane: String?

    /// 初始化
    init(userId_Pane: Int? = nil,
         userName_Pane: String? = nil,
         userHead_Pane: String? = nil,
         userPosts_Pane: [TitleModel_Pane],
         userLike_Pane: [TitleModel_Pane],
         userFollow_Pane: [PrewUserModel_Pane],
         userCheckInDates_Pane: [String] = [],
         userWindowAlbums_Pane: [WindowAlbum_Pane] = [],
         userIntroduce_Pane: String? = nil) {
        self.userId_Pane           = userId_Pane
        self.userName_Pane         = userName_Pane
        self.userHead_Pane         = userHead_Pane
        self.userPosts_Pane        = userPosts_Pane
        self.userLike_Pane         = userLike_Pane
        self.userFollow_Pane       = userFollow_Pane
        self.userCheckInDates_Pane = userCheckInDates_Pane
        self.userWindowAlbums_Pane = userWindowAlbums_Pane
        self.userIntroduce_Pane    = userIntroduce_Pane
    }
}

/// 消息数据模型
class MessageModel_Pane: Codable {
    
    /// 消息ID
    var messageId_Pane: Int?
    
    /// 消息内容
    var content_Pane: String?
    
    /// 用户头像
    var userHead_Pane: String?
    
    /// 是否是我发送的
    var isMine_Pane: Bool?
    
    /// 消息时间
    var time_Pane: String?
    
    /// 初始化
    init(messageId_pane: Int? = nil,
         content_pane: String? = nil,
         userHead_pane: String? = nil,
         isMine_pane: Bool? = nil,
         time_pane: String? = nil) {
        self.messageId_Pane = messageId_pane
        self.content_Pane = content_pane
        self.userHead_Pane = userHead_pane
        self.isMine_Pane = isMine_pane
        self.time_Pane = time_pane
    }
}

/// 评论模型
class Comment_Pane: NSObject, Codable {
    
    /// 评论ID
    var commentId_Pane: Int
    
    /// 评论用户uid
    var commentUserId_Pane: Int
    
    /// 评论用户昵称
    var commentUserName_Pane: String
    
    /// 评论内容
    var commentContent_Pane: String
    
    /// 初始化
    init(commentId_Pane: Int,
         commentUserId_Pane: Int,
         commentUserName_Pane: String,
         commentContent_Pane: String) {
        self.commentId_Pane = commentId_Pane
        self.commentUserId_Pane = commentUserId_Pane
        self.commentUserName_Pane = commentUserName_Pane
        self.commentContent_Pane = commentContent_Pane
    }
}

/// 商店模型
class StoreModel_Pane: NSObject {
    
    /// ID编号
    var id_Pane: Int?
    
    /// 商品ID
    var goodsId_Pane: String?
    
    /// 商品名字
    var goodsName_Pane: String?
    
    /// 商品价格
    var goodsPrice_Pane: String?
    
    /// 是否顶部商品
    var goodIsTop_Pane: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Pane: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Pane: Bool?
    
    init(id_Pane: Int? = nil,
         goodsId_Pane: String? = nil,
         goodsName_Pane: String? = nil,
         goodsPrice_Pane: String? = nil,
         goodIsTop_Pane: Bool? = false,
         goodIsLimit_Pane: Bool? = false,
         goodIsVIP_Pane: Bool? = false) {
        self.id_Pane = id_Pane
        self.goodsId_Pane = goodsId_Pane
        self.goodsName_Pane = goodsName_Pane
        self.goodsPrice_Pane = goodsPrice_Pane
        self.goodIsTop_Pane = goodIsTop_Pane
        self.goodIsSpecial_Pane = goodIsLimit_Pane
        self.goodIsVIP_Pane = goodIsVIP_Pane
        super.init()
    }
}
