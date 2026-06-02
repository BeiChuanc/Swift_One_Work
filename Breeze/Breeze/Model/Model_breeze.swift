import Foundation

// MARK: 数据模型定义

// MARK: - 季节枚举

/// 四季枚举，用于季节专区与相册分类
enum Season_Breeze: String, Codable, CaseIterable {
    case spring_breeze = "Spring"
    case summer_breeze = "Summer"
    case autumn_breeze = "Autumn"
    case winter_breeze = "Winter"
    
    /// 当前季节（根据月份判断）
    static var current_Breeze: Season_Breeze {
        let month_breeze = Calendar.current.component(.month, from: Date())
        switch month_breeze {
        case 3, 4, 5:  return .spring_breeze
        case 6, 7, 8:  return .summer_breeze
        case 9, 10, 11: return .autumn_breeze
        default:        return .winter_breeze
        }
    }
    
    /// 对应 SF Symbol 图标名
    var iconName_Breeze: String {
        switch self {
        case .spring_breeze: return "leaf.fill"
        case .summer_breeze: return "sun.max.fill"
        case .autumn_breeze: return "wind"
        case .winter_breeze: return "snowflake"
        }
    }
}

// MARK: - 季节露营 Tips 模型

/// 季节露营攻略 Tip
/// 核心作用：承载四季主题露营专区的单条攻略内容（分类 + 标题 + 内容 + 图标）
class SeasonalTip_Breeze: NSObject {
    
    /// 唯一 ID
    var tipId_Breeze: Int
    
    /// 所属季节
    var season_Breeze: Season_Breeze
    
    /// 分类（"Gear" / "Outfit" / "Photography" / "Routes"）
    var category_Breeze: String
    
    /// 标题
    var title_Breeze: String
    
    /// 内容
    var content_Breeze: String
    
    /// SF Symbol 图标名
    var iconName_Breeze: String
    
    init(tipId_Breeze: Int,
         season_Breeze: Season_Breeze,
         category_Breeze: String,
         title_Breeze: String,
         content_Breeze: String,
         iconName_Breeze: String) {
        self.tipId_Breeze = tipId_Breeze
        self.season_Breeze = season_Breeze
        self.category_Breeze = category_Breeze
        self.title_Breeze = title_Breeze
        self.content_Breeze = content_Breeze
        self.iconName_Breeze = iconName_Breeze
    }
}

// MARK: - 露营相册条目模型

/// 个人露营相册条目
/// 核心作用：记录用户上传的一张露营照片及其元数据（季节/日期/地点/备注）
class CampingAlbumItem_Breeze: NSObject, Codable {
    
    /// 唯一 ID
    var itemId_Breeze: Int
    
    /// 图片存储路径（Documents 目录文件名）
    var imagePath_Breeze: String
    
    /// 所属季节原始值
    var seasonRaw_Breeze: String
    
    /// 日期字符串（"yyyy-MM-dd"）
    var dateString_Breeze: String
    
    /// 地点备注
    var locationNote_Breeze: String
    
    /// 用户备注
    var userNote_Breeze: String
    
    /// 计算属性：季节枚举
    var season_Breeze: Season_Breeze {
        Season_Breeze(rawValue: seasonRaw_Breeze) ?? .spring_breeze
    }
    
    init(itemId_Breeze: Int,
         imagePath_Breeze: String,
         seasonRaw_Breeze: String,
         dateString_Breeze: String,
         locationNote_Breeze: String,
         userNote_Breeze: String) {
        self.itemId_Breeze = itemId_Breeze
        self.imagePath_Breeze = imagePath_Breeze
        self.seasonRaw_Breeze = seasonRaw_Breeze
        self.dateString_Breeze = dateString_Breeze
        self.locationNote_Breeze = locationNote_Breeze
        self.userNote_Breeze = userNote_Breeze
    }
}

// MARK: - 帖子分类枚举

/// 帖子内容分类
/// 核心作用：标识每条帖子的主题类别，供发现页分类筛选使用
/// 关键属性：rawValue 作为显示文案，iconName_Breeze 返回对应 SF Symbol 图标名
enum PostCategory_Breeze: String, Codable, CaseIterable {
    
    /// 全部（默认 / 未分类）
    case all_breeze = "All"
    
    /// 露营
    case camping_breeze = "Camping"
    
    /// 徒步
    case hiking_breeze = "Hiking"
    
    /// 自然
    case nature_breeze = "Nature"
    
    /// 摄影
    case photography_breeze = "Photography"
    
    /// 分类对应的 SF Symbol 图标名
    var iconName_Breeze: String {
        switch self {
        case .all_breeze:         return "square.grid.2x2.fill"
        case .camping_breeze:     return "tent.2.fill"
        case .hiking_breeze:      return "figure.hiking"
        case .nature_breeze:      return "leaf.fill"
        case .photography_breeze: return "camera.fill"
        }
    }
}

/// 用户数据模型
class PrewUserModel_Breeze: NSObject, Codable {
    
    /// 用户ID
    var userId_Breeze: Int?
    
    /// 用户名字
    var userName_Breeze: String?
    
    /// 用户简介
    var userIntroduce_Breeze: String?
    
    /// 用户头像
    var userHead_Breeze: String?
    
    /// 用户媒体
    var userMedia_Breeze: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Breeze: [TitleModel_Breeze] = []

    /// 用户关注数
    var userFollow_Breeze: Int?

    /// 用户粉丝数
    var userFans_Breeze: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Breeze: Int? = nil,
         userName_Breeze: String? = nil,
         userIntroduce_Breeze: String? = nil,
         userHead_Breeze: String? = nil,
         userMedia_Breeze: [String]? = nil,
         userLike_Breeze: [TitleModel_Breeze] = [],
         userFollow_Breeze: Int? = nil,
         userFans_Breeze: Int? = nil) {
        self.userId_Breeze = userId_Breeze
        self.userName_Breeze = userName_Breeze
        self.userIntroduce_Breeze = userIntroduce_Breeze
        self.userHead_Breeze = userHead_Breeze
        self.userMedia_Breeze = userMedia_Breeze
        self.userLike_Breeze = userLike_Breeze
        self.userFollow_Breeze = userFollow_Breeze
        self.userFans_Breeze = userFans_Breeze
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Breeze: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Breeze: Int
    
    /// 拥有者ID
    var titleUserId_Breeze: Int
    
    /// 拥有者昵称
    var titleUserName_Breeze: String
    
    /// 帖子媒体
    var titleMeidas_Breeze: [String]
    
    /// 帖子标题
    var title_Breeze: String
    
    /// 帖子内容
    var titleContent_Breeze: String
    
    /// 帖子评论列表
    var reviews_Breeze: [Comment_Breeze]
    
    /// 喜欢个数
    var likes_Breeze: Int
    
    /// 帖子分类
    var titleCategory_Breeze: PostCategory_Breeze
    
    init(titleId_Breeze: Int,
         titleUserId_Breeze: Int,
         titleUserName_Breeze: String,
         titleMeidas_Breeze: [String],
         title_Breeze: String,
         titleContent_Breeze: String,
         reviews_Breeze: [Comment_Breeze],
         likes_Breeze: Int,
         titleCategory_Breeze: PostCategory_Breeze = .all_breeze) {
        self.titleId_Breeze = titleId_Breeze
        self.titleUserId_Breeze = titleUserId_Breeze
        self.titleUserName_Breeze = titleUserName_Breeze
        self.titleMeidas_Breeze = titleMeidas_Breeze
        self.title_Breeze = title_Breeze
        self.titleContent_Breeze = titleContent_Breeze
        self.reviews_Breeze = reviews_Breeze
        self.likes_Breeze = likes_Breeze
        self.titleCategory_Breeze = titleCategory_Breeze
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Breeze: NSObject, Codable {
    
    /// 用户ID
    var userId_Breeze: Int?
    
    /// 用户密码
    var userPwd_Breeze: String?
    
    /// 用户名称
    var userName_Breeze: String?
    
    /// 用户简介
    var userIntroduce_Breeze: String?
    
    /// 用户头像
    var userHead_Breeze: String?
    
    /// 用户发布帖子列表
    var userPosts_Breeze: [TitleModel_Breeze]
    
    /// 用户喜欢帖子列表
    var userLike_Breeze: [TitleModel_Breeze]

    /// 用户关注列表
    var userFollow_Breeze: [PrewUserModel_Breeze]
    
    /// 初始化
    init(userId_Breeze: Int? = nil,
         userPwd_Breeze: String? = nil,
         userName_Breeze: String? = nil,
         userIntroduce_Breeze: String? = nil,
         userHead_Breeze: String? = nil,
         userPosts_Breeze: [TitleModel_Breeze],
         userLike_Breeze: [TitleModel_Breeze],
         userFollow_Breeze: [PrewUserModel_Breeze]) {
        self.userId_Breeze = userId_Breeze
        self.userPwd_Breeze = userPwd_Breeze
        self.userName_Breeze = userName_Breeze
        self.userIntroduce_Breeze = userIntroduce_Breeze
        self.userHead_Breeze = userHead_Breeze
        self.userPosts_Breeze = userPosts_Breeze
        self.userLike_Breeze = userLike_Breeze
        self.userFollow_Breeze = userFollow_Breeze
    }
}

/// 消息数据模型
class MessageModel_Breeze: Codable {
    
    /// 消息ID
    var messageId_Breeze: Int?
    
    /// 消息内容
    var content_Breeze: String?
    
    /// 用户头像
    var userHead_Breeze: String?
    
    /// 是否是我发送的
    var isMine_Breeze: Bool?
    
    /// 消息时间
    var time_Breeze: String?
    
    /// 初始化
    init(messageId_breeze: Int? = nil,
         content_breeze: String? = nil,
         userHead_breeze: String? = nil,
         isMine_breeze: Bool? = nil,
         time_breeze: String? = nil) {
        self.messageId_Breeze = messageId_breeze
        self.content_Breeze = content_breeze
        self.userHead_Breeze = userHead_breeze
        self.isMine_Breeze = isMine_breeze
        self.time_Breeze = time_breeze
    }
}

/// 评论模型
class Comment_Breeze: NSObject, Codable {
    
    /// 评论ID
    var commentId_Breeze: Int
    
    /// 评论用户uid
    var commentUserId_Breeze: Int
    
    /// 评论用户昵称
    var commentUserName_Breeze: String
    
    /// 评论内容
    var commentContent_Breeze: String
    
    /// 初始化
    init(commentId_Breeze: Int,
         commentUserId_Breeze: Int,
         commentUserName_Breeze: String,
         commentContent_Breeze: String) {
        self.commentId_Breeze = commentId_Breeze
        self.commentUserId_Breeze = commentUserId_Breeze
        self.commentUserName_Breeze = commentUserName_Breeze
        self.commentContent_Breeze = commentContent_Breeze
    }
}

/// 商店模型
class StoreModel_Breeze: NSObject {
    
    /// ID编号
    var id_Breeze: Int?
    
    /// 商品ID
    var goodsId_Breeze: String?
    
    /// 商品名字
    var goodsName_Breeze: String?
    
    /// 商品价格
    var goodsPrice_Breeze: String?
    
    /// 是否顶部商品
    var goodIsTop_Breeze: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Breeze: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Breeze: Bool?
    
    init(id_Breeze: Int? = nil,
         goodsId_Breeze: String? = nil,
         goodsName_Breeze: String? = nil,
         goodsPrice_Breeze: String? = nil,
         goodIsTop_Breeze: Bool? = false,
         goodIsLimit_Breeze: Bool? = false,
         goodIsVIP_Breeze: Bool? = false) {
        self.id_Breeze = id_Breeze
        self.goodsId_Breeze = goodsId_Breeze
        self.goodsName_Breeze = goodsName_Breeze
        self.goodsPrice_Breeze = goodsPrice_Breeze
        self.goodIsTop_Breeze = goodIsTop_Breeze
        self.goodIsSpecial_Breeze = goodIsLimit_Breeze
        self.goodIsVIP_Breeze = goodIsVIP_Breeze
        super.init()
    }
}
