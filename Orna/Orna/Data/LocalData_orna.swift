import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 本地数据管理类
/// 功能：管理预制用户与帖子数据，提供查询过滤方法
/// 设计：单例 + 内部 DataGenerator 负责批量生成
class LocalData_Orna {
    
    static let shared_Orna = LocalData_Orna()
    
    /// 用户列表
    var userList_Orna: [PrewUserModel_Orna] = []
    
    /// 帖子列表
    var titleList_Orna: [TitleModel_Orna] = []
    
    private lazy var generator_Orna = DataGenerator_Orna(dataLocal_orna: self)
    
    private init() {}
    
    /// 初始化所有预制数据
    func initData_Orna() {
        generator_Orna.initUsers_Orna()
        generator_Orna.initPosts_Orna()
        generator_Orna.setUserLikes_Orna()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Orna(userId_orna: Int) -> [TitleModel_Orna] {
        titleList_Orna.filter { $0.titleUserId_Orna != userId_orna }
    }
    
    /// 获取可评论的用户列表（排除帖子作者）
    func getAvailableCommenters_Orna(postAuthorUserId_orna: Int) -> [PrewUserModel_Orna] {
        userList_Orna.filter { $0.userId_Orna != postAuthorUserId_orna }
    }

    // MARK: - 摆件预制数据

    /// 桌面摆件全量图鉴（预制数据，不参与随机重置）
    lazy var ornamentCatalog_Orna: [OrnamentModel_Orna] = DataSource_Orna.ornamentsInfo_Orna.enumerated().map { index, info in
        let (name, icon, rarity) = info
        return OrnamentModel_Orna(
            ornamentId_Orna: index + 1,
            ornamentName_Orna: name,
            ornamentIcon_Orna: icon,
            ornamentColorHex_Orna: rarity.colorHex_Orna,
            ornamentRarity_Orna: rarity
        )
    }

    /// 根据ID获取摆件
    func getOrnamentById_Orna(ornamentId_orna: Int) -> OrnamentModel_Orna? {
        ornamentCatalog_Orna.first { $0.ornamentId_Orna == ornamentId_orna }
    }

    // MARK: - 登录用户ID解析

    /// 根据用户名解析登录用户ID
    /// 功能：登录/注册页仅收集用户名与密码，本地演示环境下将用户名映射为稳定的用户ID
    /// 设计：优先匹配预制用户列表中的同名用户（不区分大小写），命中则复用其完整资料；
    ///       未命中时基于用户名哈希生成稳定的游客ID，保证同一用户名总是得到同一账号
    /// 参数：
    /// - userName_orna: 用户输入的用户名
    /// 返回值：解析得到的用户ID
    func resolveUserId_Orna(byName userName_orna: String) -> Int {
        let trimmed_orna = userName_orna.trimmingCharacters(in: .whitespacesAndNewlines)
        if let matched_orna = userList_Orna.first(where: {
            $0.userName_Orna?.caseInsensitiveCompare(trimmed_orna) == .orderedSame
        }), let matchedId_orna = matched_orna.userId_Orna {
            return matchedId_orna
        }
        // 未匹配到预制用户：基于名字哈希生成稳定 ID（避开预制用户ID区间 10~14）
        let hashValue_orna = abs(trimmed_orna.hashValue)
        return 1000 + (hashValue_orna % 9000)
    }
}

// MARK: - 静态数据源

/// 预制用户与帖子原始数据
private enum DataSource_Orna {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Orna: [(String, String, String, String)] = [
        ("DeskWhisperer", "Collector of tiny things that make big desks happy", "head1", "head1"),
        ("OrnamentHunter", "On a lifelong quest for the rarest desk trinkets", "head2", "head2"),
        ("ShelfCurator", "Curating cozy corners, one figurine at a time", "head3", "head3"),
        ("MiniatureMuse", "Turning ordinary desks into pocket-sized wonderlands", "head4", "head4"),
        ("CozyDeskArtist", "Painting my workspace with light, plants and trinkets", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Orna: [(String, String, String)] = [
        ("Music Box Monday Ritual", "Winding up my little music box before I start work has become a strange but comforting Monday ritual. Anyone else have a weird desk routine like this?", "title6"),
        ("Golden Compass Found a Home", "This little brass compass has traveled through three apartments with me and it finally has the perfect spot on my new shelf. Some ornaments just deserve to be centerpieces.", "title9"),
        ("Hourglass Breaks Are Underrated", "Started flipping my tiny hourglass every time I need a five minute break and it's genuinely improved my focus. Simple ornaments, surprisingly big impact.", "title8"),
        ("Retro Robot Toy Unboxing", "Finally found the vintage wind-up robot I've been hunting for months at a flea market. He now guards my monitor stand and refuses to be moved.", "title4"),
        ("Bonsai Made It Through Winter", "My desk bonsai survived the coldest month yet and even sprouted a new tiny leaf this morning. Talk to your desk plants, apparently it works.", "title2"),
        ("Star Night Lamp Vibes", "Turned off the overhead lights and let my star projector lamp take over the desk tonight. Coding under a tiny galaxy hits different, highly recommend for late night sessions.", "title1"),
        ("Tiny Zen Garden Update", "Raked my mini sand garden for the hundredth time this week and I still find it weirdly calming between meetings. Five minutes of tiny rake therapy fixes everything.", "title10"),
        ("Rubber Duck Squad Assemble", "My rubber duck collection just hit double digits and they've taken over the entire left side of my keyboard tray. Send help, or better yet, send more ducks.", "title7"),
        ("New Crystal Prism Arrived!", "Unboxed my new crystal prism today and the way it scatters rainbows across my desk every morning is pure magic. Best five dollars I've spent on desk decor in ages.", "title5"),
        ("My Desk Finally Feels Alive", "Spent the whole weekend rearranging my shelf ornaments and I'm obsessed with the result. Every little figurine now has its own spotlight, and my desk finally feels like a tiny world of its own.", "title3"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Orna: [(String, String)] = [
        ("The music box Monday ritual is adorable, might have to start my own", "Weird little routines like this make the desk feel more like home"),
        ("That compass has some serious character after all those moves", "Some ornaments just earn their spot as the centerpiece over time"),
        ("Never thought of using an hourglass for breaks, trying this today", "Simple ornaments really do make the biggest difference sometimes"),
        ("Flea market finds like that robot are the best kind of treasure", "He looks like he takes his guarding duties very seriously"),
        ("Desk plants really do listen, mine perked up after I started talking to it too", "That new leaf is such a win, congrats to your tiny bonsai"),
        ("Coding under a tiny galaxy sounds like the dream setup honestly", "Star lamps make everything feel cozier, great pick for late nights"),
        ("Tiny rake therapy is real, I do the same thing during boring calls", "There's something so satisfying about a freshly raked zen garden"),
        ("Okay the duck squad is out of control and I love every bit of it", "Ten ducks and counting, this is the kind of chaos I support"),
        ("That prism rainbow effect looks incredible, where did you find it?", "Adding this to my desk wishlist immediately, the colors are so pretty"),
        ("Your shelf arrangement is giving me so much inspiration! Need to reorganize mine now", "The little spotlight idea for each figurine is genius, definitely stealing that"),
    ]

    /// 桌面摆件图鉴 (名称, SF Symbol 图标, 稀有度)
    static let ornamentsInfo_Orna: [(String, String, OrnamentRarity_Orna)] = [
        ("Lucky Cat Figurine", "cat.fill", .common_Orna),
        ("Mini Cactus Pot", "leaf.fill", .common_Orna),
        ("Retro Snow Globe", "cloud.snow.fill", .common_Orna),
        ("Rubber Duck", "bird.fill", .common_Orna),
        ("Zen Sand Garden", "circle.dashed", .common_Orna),
        ("Tiny Hourglass", "hourglass", .common_Orna),
        ("Wind-up Music Box", "music.note", .rare_Orna),
        ("Crystal Prism", "sparkles", .rare_Orna),
        ("Star Night Lamp", "moon.stars.fill", .rare_Orna),
        ("Pixel Game Console", "gamecontroller.fill", .rare_Orna),
        ("Desk Bonsai Tree", "tree.fill", .rare_Orna),
        ("Retro Robot Toy", "cube.fill", .rare_Orna),
        ("Golden Compass", "safari.fill", .epic_Orna),
        ("Dragon Incense Burner", "flame.fill", .epic_Orna),
        ("Aurora Beacon Lamp", "light.beacon.max.fill", .epic_Orna),
        ("Royal Crown Trinket", "crown.fill", .epic_Orna)
    ]
}

// MARK: - 随机数工具

/// 随机数工具（仅供数据生成使用）
private enum RandomUtil_Orna {
    
    /// 生成 [min, min + range) 范围内的随机整数
    static func nextInt_Orna(min_orna: Int, range_orna: Int) -> Int {
        Int.random(in: min_orna..<(min_orna + range_orna))
    }
    
    /// 从列表中随机选取不重复的 N 个元素
    static func selectRandomItems_Orna<T>(from list_orna: [T], count_orna: Int) -> [T] {
        guard !list_orna.isEmpty else { return [] }
        guard list_orna.count > count_orna else { return list_orna }
        
        var selected_orna: [T] = []
        var usedIndices_orna = Set<Int>()
        while selected_orna.count < count_orna {
            let index_orna = Int.random(in: 0..<list_orna.count)
            if usedIndices_orna.insert(index_orna).inserted {
                selected_orna.append(list_orna[index_orna])
            }
        }
        return selected_orna
    }
}

// MARK: - 数据生成器

/// 预制数据生成器（仅 LocalData 内部使用）
private class DataGenerator_Orna {
    
    private weak var dataLocal_Orna: LocalData_Orna?
    
    init(dataLocal_orna: LocalData_Orna) {
        self.dataLocal_Orna = dataLocal_orna
    }
    
    /// 根据静态数据源生成用户列表
    func initUsers_Orna() {
        guard let dataLocal_orna = dataLocal_Orna else { return }
        dataLocal_orna.userList_Orna = DataSource_Orna.usersInfo_Orna.enumerated().map { index, info in
            let (name, intro, head, album) = info
            let user_orna = PrewUserModel_Orna()
            user_orna.userId_Orna = index + 10
            user_orna.userName_Orna = name
            user_orna.userIntroduce_Orna = intro
            user_orna.userHead_Orna = head
            user_orna.userMedia_Orna = [album]
            user_orna.userLike_Orna = []
            user_orna.userFollow_Orna = 15 + Int.random(in: 1...50)
            user_orna.userFans_Orna = 20 + Int.random(in: 1...50)
            return user_orna
        }
    }
    
    /// 根据静态数据源生成帖子列表（循环分配作者）
    func initPosts_Orna() {
        guard let dataLocal_orna = dataLocal_Orna else { return }
        let users_orna = dataLocal_orna.userList_Orna
        guard !users_orna.isEmpty else {
            dataLocal_orna.titleList_Orna = []
            return
        }
        
        dataLocal_orna.titleList_Orna = DataSource_Orna.postsInfo_Orna.enumerated().map { index, info in
            let (title, content, media) = info
            let author_orna = users_orna[index % users_orna.count]
            let authorId_orna = author_orna.userId_Orna ?? 0
            
            return TitleModel_Orna(
                titleId_Orna: index + 20,
                titleUserId_Orna: authorId_orna,
                titleUserName_Orna: author_orna.userName_Orna ?? "",
                titleMeidas_Orna: [media],
                title_Orna: title,
                titleContent_Orna: content,
                reviews_Orna: generateComments_Orna(postIndex_orna: index, postAuthorUserId_orna: authorId_orna),
                likes_Orna: RandomUtil_Orna.nextInt_Orna(min_orna: 10, range_orna: 150)
            )
        }
    }
    
    /// 为帖子生成两条评论
    private func generateComments_Orna(postIndex_orna: Int, postAuthorUserId_orna: Int) -> [Comment_Orna] {
        guard let dataLocal_orna = dataLocal_Orna else { return [] }
        let available_orna = dataLocal_orna.getAvailableCommenters_Orna(postAuthorUserId_orna: postAuthorUserId_orna)
        guard available_orna.count >= 2 else { return [] }
        
        let commenter1_orna = available_orna[postIndex_orna % available_orna.count]
        let commenter2_orna = available_orna[(postIndex_orna + 1) % available_orna.count]
        let (text1, text2) = DataSource_Orna.comments_Orna[postIndex_orna % DataSource_Orna.comments_Orna.count]
        
        return [
            makeComment_Orna(id: postIndex_orna * 2 + 1, user: commenter1_orna, content: text1),
            makeComment_Orna(id: postIndex_orna * 2 + 2, user: commenter2_orna, content: text2)
        ]
    }
    
    /// 为每个用户随机分配喜欢的帖子（排除自己的帖子）
    func setUserLikes_Orna() {
        guard let dataLocal_orna = dataLocal_Orna else { return }
        for i in dataLocal_orna.userList_Orna.indices {
            let userId_orna = dataLocal_orna.userList_Orna[i].userId_Orna ?? 0
            dataLocal_orna.userList_Orna[i].userLike_Orna = RandomUtil_Orna.selectRandomItems_Orna(
                from: dataLocal_orna.getPostsExcludingUser_Orna(userId_orna: userId_orna),
                count_orna: 2
            )
        }
    }
    
    /// 构建评论模型
    private func makeComment_Orna(id: Int, user: PrewUserModel_Orna, content: String) -> Comment_Orna {
        Comment_Orna(
            commentId_Orna: id,
            commentUserId_Orna: user.userId_Orna ?? 0,
            commentUserName_Orna: user.userName_Orna ?? "",
            commentContent_Orna: content
        )
    }
}
