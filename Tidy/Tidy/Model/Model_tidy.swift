import Foundation
import UIKit

// MARK: 数据模型定义

// MARK: - 家居分类模型

/// 家居物品分类模型
/// 功能：定义首页分类入口与发现页筛选 tab 所用的分类数据结构
/// 关键属性：
///   - id_Tidy: 分类唯一标识（与 TitleModel 的 titleCategory_Tidy 对应）
///   - name_Tidy: 展示名称（英文 UI）
///   - iconName_Tidy: SF Symbol 图标名
///   - colorHex_Tidy: 分类主题色十六进制值
struct HomeCategory_Tidy {
    
    /// 分类唯一标识（"all" 表示全部）
    let id_Tidy: String
    
    /// 分类展示名称
    let name_Tidy: String
    
    /// SF Symbol 图标名
    let iconName_Tidy: String
    
    /// 分类主题色十六进制值
    let colorHex_Tidy: String
}

/// 用户数据模型
class PrewUserModel_Tidy: NSObject, Codable {
    
    /// 用户ID
    var userId_Tidy: Int?
    
    /// 用户名字
    var userName_Tidy: String?
    
    /// 用户简介
    var userIntroduce_Tidy: String?
    
    /// 用户头像
    var userHead_Tidy: String?
    
    /// 用户媒体
    var userMedia_Tidy: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Tidy: [TitleModel_Tidy] = []

    /// 用户关注数
    var userFollow_Tidy: Int?

    /// 用户粉丝数
    var userFans_Tidy: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Tidy: Int? = nil,
         userName_Tidy: String? = nil,
         userIntroduce_Tidy: String? = nil,
         userHead_Tidy: String? = nil,
         userMedia_Tidy: [String]? = nil,
         userLike_Tidy: [TitleModel_Tidy] = [],
         userFollow_Tidy: Int? = nil,
         userFans_Tidy: Int? = nil) {
        self.userId_Tidy = userId_Tidy
        self.userName_Tidy = userName_Tidy
        self.userIntroduce_Tidy = userIntroduce_Tidy
        self.userHead_Tidy = userHead_Tidy
        self.userMedia_Tidy = userMedia_Tidy
        self.userLike_Tidy = userLike_Tidy
        self.userFollow_Tidy = userFollow_Tidy
        self.userFans_Tidy = userFans_Tidy
        super.init()
    }
}

/// 帖子数据模型
/// 功能：社区帖子的完整数据结构，包含分类标识用于首页/发现页筛选
class TitleModel_Tidy: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Tidy: Int
    
    /// 拥有者ID
    var titleUserId_Tidy: Int
    
    /// 拥有者昵称
    var titleUserName_Tidy: String
    
    /// 帖子媒体
    var titleMeidas_Tidy: [String]
    
    /// 帖子标题
    var title_Tidy: String
    
    /// 帖子内容
    var titleContent_Tidy: String
    
    /// 帖子评论列表
    var reviews_Tidy: [Comment_Tidy]
    
    /// 喜欢个数
    var likes_Tidy: Int
    
    /// 帖子所属家居分类标识（与 HomeCategory_Tidy.id_Tidy 对应）
    var titleCategory_Tidy: String
    
    init(titleId_Tidy: Int,
         titleUserId_Tidy: Int,
         titleUserName_Tidy: String,
         titleMeidas_Tidy: [String],
         title_Tidy: String,
         titleContent_Tidy: String,
         reviews_Tidy: [Comment_Tidy],
         likes_Tidy: Int,
         titleCategory_Tidy: String = "all") {
        self.titleId_Tidy = titleId_Tidy
        self.titleUserId_Tidy = titleUserId_Tidy
        self.titleUserName_Tidy = titleUserName_Tidy
        self.titleMeidas_Tidy = titleMeidas_Tidy
        self.title_Tidy = title_Tidy
        self.titleContent_Tidy = titleContent_Tidy
        self.reviews_Tidy = reviews_Tidy
        self.likes_Tidy = likes_Tidy
        self.titleCategory_Tidy = titleCategory_Tidy
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Tidy: NSObject, Codable {
    
    /// 用户ID
    var userId_Tidy: Int?
    
    /// 用户密码
    var userPwd_Tidy: String?
    
    /// 用户名称
    var userName_Tidy: String?
    
    /// 用户头像
    var userHead_Tidy: String?
    
    /// 用户简介
    var userIntroduce_Tidy: String?
    
    /// 用户发布帖子列表
    var userPosts_Tidy: [TitleModel_Tidy]
    
    /// 用户喜欢帖子列表
    var userLike_Tidy: [TitleModel_Tidy]

    /// 用户关注列表
    var userFollow_Tidy: [PrewUserModel_Tidy]
    
    /// 初始化
    init(userId_Tidy: Int? = nil,
         userPwd_Tidy: String? = nil,
         userName_Tidy: String? = nil,
         userHead_Tidy: String? = nil,
         userIntroduce_Tidy: String? = nil,
         userPosts_Tidy: [TitleModel_Tidy],
         userLike_Tidy: [TitleModel_Tidy],
         userFollow_Tidy: [PrewUserModel_Tidy]) {
        self.userId_Tidy = userId_Tidy
        self.userPwd_Tidy = userPwd_Tidy
        self.userName_Tidy = userName_Tidy
        self.userHead_Tidy = userHead_Tidy
        self.userIntroduce_Tidy = userIntroduce_Tidy
        self.userPosts_Tidy = userPosts_Tidy
        self.userLike_Tidy = userLike_Tidy
        self.userFollow_Tidy = userFollow_Tidy
    }
}

/// 消息数据模型
class MessageModel_Tidy: Codable {
    
    /// 消息ID
    var messageId_Tidy: Int?
    
    /// 消息内容
    var content_Tidy: String?
    
    /// 用户头像
    var userHead_Tidy: String?
    
    /// 是否是我发送的
    var isMine_Tidy: Bool?
    
    /// 消息时间
    var time_Tidy: String?
    
    /// 初始化
    init(messageId_tidy: Int? = nil,
         content_tidy: String? = nil,
         userHead_tidy: String? = nil,
         isMine_tidy: Bool? = nil,
         time_tidy: String? = nil) {
        self.messageId_Tidy = messageId_tidy
        self.content_Tidy = content_tidy
        self.userHead_Tidy = userHead_tidy
        self.isMine_Tidy = isMine_tidy
        self.time_Tidy = time_tidy
    }
}

/// 评论模型
class Comment_Tidy: NSObject, Codable {
    
    /// 评论ID
    var commentId_Tidy: Int
    
    /// 评论用户uid
    var commentUserId_Tidy: Int
    
    /// 评论用户昵称
    var commentUserName_Tidy: String
    
    /// 评论内容
    var commentContent_Tidy: String
    
    /// 初始化
    init(commentId_Tidy: Int,
         commentUserId_Tidy: Int,
         commentUserName_Tidy: String,
         commentContent_Tidy: String) {
        self.commentId_Tidy = commentId_Tidy
        self.commentUserId_Tidy = commentUserId_Tidy
        self.commentUserName_Tidy = commentUserName_Tidy
        self.commentContent_Tidy = commentContent_Tidy
    }
}

/// 商店模型
class StoreModel_Tidy: NSObject {
    
    /// ID编号
    var id_Tidy: Int?
    
    /// 商品ID
    var goodsId_Tidy: String?
    
    /// 商品名字
    var goodsName_Tidy: String?
    
    /// 商品价格
    var goodsPrice_Tidy: String?
    
    /// 是否顶部商品
    var goodIsTop_Tidy: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Tidy: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Tidy: Bool?
    
    init(id_Tidy: Int? = nil,
         goodsId_Tidy: String? = nil,
         goodsName_Tidy: String? = nil,
         goodsPrice_Tidy: String? = nil,
         goodIsTop_Tidy: Bool? = false,
         goodIsLimit_Tidy: Bool? = false,
         goodIsVIP_Tidy: Bool? = false) {
        self.id_Tidy = id_Tidy
        self.goodsId_Tidy = goodsId_Tidy
        self.goodsName_Tidy = goodsName_Tidy
        self.goodsPrice_Tidy = goodsPrice_Tidy
        self.goodIsTop_Tidy = goodIsTop_Tidy
        self.goodIsSpecial_Tidy = goodIsLimit_Tidy
        self.goodIsVIP_Tidy = goodIsVIP_Tidy
        super.init()
    }
}
