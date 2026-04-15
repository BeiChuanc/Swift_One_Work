import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Epoch {
    /// ID起始值
    static let userIdStart_Epoch = 10
    static let postIdStart_Epoch = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Epoch = 2
}

/// 本地数据管理类
class LocalData_Epoch {
    
    /// 单例
    static let shared_Epoch = LocalData_Epoch()
    
    /// 用户列表
    var userList_Epoch: [PrewUserModel_Epoch] = []
    
    /// 帖子列表
    var titleList_Epoch: [TitleModel_Epoch] = []

    /// 数据生成器
    private lazy var generator_Epoch: DataGenerator_Epoch = {
        return DataGenerator_Epoch(dataLocal_epoch: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Epoch() {
        generator_Epoch.initUsers_Epoch()
        generator_Epoch.initPosts_Epoch()
        generator_Epoch.setUserLikes_Epoch()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Epoch(userId_epoch: Int) -> [TitleModel_Epoch] {
        return titleList_Epoch.filter { $0.titleUserId_Epoch != userId_epoch }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Epoch(postAuthorUserId_epoch: Int) -> [PrewUserModel_Epoch] {
        return userList_Epoch.filter { $0.userId_Epoch != postAuthorUserId_epoch }
    }

    /// 根据用户ID获取用户
    /// - Parameter userId_epoch: 用户ID
    /// - Returns: 用户模型
    func getUser_Epoch(userId_epoch: Int) -> PrewUserModel_Epoch? {
        return userList_Epoch.first { $0.userId_Epoch == userId_epoch }
    }

    /// 根据用户名获取用户ID
    /// - Parameter userName_epoch: 用户名
    /// - Returns: 匹配到的用户ID
    func getUserIdByName_Epoch(userName_epoch: String) -> Int? {
        let normalizedName_epoch = userName_epoch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return userList_Epoch.first {
            ($0.userName_Epoch ?? "").lowercased() == normalizedName_epoch
        }?.userId_Epoch
    }

    /// 获取首页仪式场景小贴士
    /// - Returns: 首页场景贴士列表
    func getHomeSceneTips_Epoch() -> [HomeSceneTipModel_Epoch] {
        return DataSource_Epoch.homeSceneTips_Epoch
    }

    /// 更新用户关注和粉丝数量
    /// - Parameters:
    ///   - userId_epoch: 目标用户ID
    ///   - isFollowing_epoch: 是否已关注
    func updateFollowCount_Epoch(userId_epoch: Int, isFollowing_epoch: Bool) {
        guard let index_epoch = userList_Epoch.firstIndex(where: { $0.userId_Epoch == userId_epoch }) else {
            return
        }

        let currentFans_epoch = userList_Epoch[index_epoch].userFans_Epoch ?? 0
        userList_Epoch[index_epoch].userFans_Epoch = max(0, currentFans_epoch + (isFollowing_epoch ? 1 : -1))
    }

    /// 删除用户
    /// - Parameter userId_epoch: 用户ID
    func removeUser_Epoch(userId_epoch: Int) {
        userList_Epoch.removeAll { $0.userId_Epoch == userId_epoch }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Epoch {

    /// 用户头像系统图标
    static let userAvatarSymbols_Epoch: [String] = [
        "head1",
        "head2",
        "head3",
        "head4",
        "head5"
    ]

    /// 用户相册系统图标
    static let userMediaSymbols_Epoch: [String] = [
        "head1",
        "head2",
        "head3",
        "head4",
        "head5"
    ]
    
    /// 用户信息列表 (用户名, 简介)
    static let usersInfo_Epoch: [(String, String)] = [
        ("EmberSeeker", "Love turning tiny gatherings into glowing memories."),
        ("ForestWhisper", "Nature enthusiast who keeps every corner soft and warm."),
        ("FlameJumper", "Always styling cozy celebrations with playful details."),
        ("AshesToArt", "Turning everyday scenes into shareable ritual moments."),
        ("NightGlow", "Collecting sparkles, flowers and calm midnight aesthetics.")
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Epoch: [(String, String, String)] = [
        ("Soft Candle Corner", "Layered candles, dried flowers and a quiet playlist made this little corner feel like a private ceremony for the week.", "title1"),
        ("Balloon Mood Setup", "I mixed soft balloons with silver ribbons and mirror light. The whole room instantly felt brighter and more playful.", "title2"),
        ("Late Night Dinner Glow", "A tiny lamp, warm dishes and handwritten cards turned an ordinary dinner into something worth remembering.", "title3"),
        ("Window Ritual Scene", "Sheer curtains, tiny stars and gentle purple light made the window side feel like a dreamy story frame.", "title4"),
        ("Mini Flower Stage", "Just a few flowers, a tray and clean glass cups can completely change the emotion of a gathering table.", "title5"),
        ("Birthday Table Flow", "Soft gradients, layered cake stands and compact gifts made the whole table look neat but still exciting.", "title6"),
        ("Sunset Picnic Accent", "Using one fabric tone and two bright details was enough to make the grass setup feel polished and shareable.", "title7"),
        ("Mirror Light Details", "Reflections from mirrors and candles gave every photo a glossy ceremonial texture without much cost.", "title8"),
        ("Weekend Relax Decor", "I kept everything simple with linen, fruit and soft light. The atmosphere felt slow, fresh and easy to stay in.", "title9"),
        ("Star Jar Surprise", "Adding handmade jars, notes and tiny lights created a sweet surprise zone everyone wanted to photograph.", "title10"),
    ]

    /// 首页场景贴士
    static let homeSceneTips_Epoch: [HomeSceneTipModel_Epoch] = [
        HomeSceneTipModel_Epoch(
            sceneName_Epoch: "Birthday",
            tipTitle_Epoch: "Keep one hero color",
            tipDetail_Epoch: "Choose one cake-table tone and let gifts, ribbons and candles echo it for a cleaner frame.",
            tipExtendedDetail_Epoch: "Start with the cake zone, then repeat the same color in only two or three supporting details such as ribbons, flowers and cards. This keeps the birthday setup lively without letting the table feel noisy.",
            tipChecklist_Epoch: [
                "Pick one dominant color before shopping.",
                "Repeat the same tone on cake, ribbon and candles.",
                "Leave one clean area for gifts and photos."
            ],
            iconName_Epoch: "gift.fill"
        ),
        HomeSceneTipModel_Epoch(
            sceneName_Epoch: "Festival",
            tipTitle_Epoch: "Layer soft light first",
            tipDetail_Epoch: "Build the mood with warm lamps or string lights before adding banners and themed props.",
            tipExtendedDetail_Epoch: "Festival setups feel richer when light leads the scene. Use warm string lights, candles or hidden lamps to define the atmosphere first, then place banners and ornaments only where the light already feels balanced.",
            tipChecklist_Epoch: [
                "Test warm light sources before adding decor.",
                "Avoid placing all themed props at the same height.",
                "Keep one corner slightly darker for depth."
            ],
            iconName_Epoch: "sparkles"
        ),
        HomeSceneTipModel_Epoch(
            sceneName_Epoch: "Couple",
            tipTitle_Epoch: "Leave one intimate corner",
            tipDetail_Epoch: "Prepare a tiny space for notes, flowers and two glasses so photos feel personal instead of crowded.",
            tipExtendedDetail_Epoch: "Couple scenes work best when there is a clearly emotional focal point. A small side table with handwritten notes, flowers and shared objects makes the whole setting more personal than covering the room with decorations.",
            tipChecklist_Epoch: [
                "Reserve a two-person focal corner.",
                "Use flowers and notes instead of too many props.",
                "Keep background tones softer than the focal point."
            ],
            iconName_Epoch: "heart.fill"
        ),
        HomeSceneTipModel_Epoch(
            sceneName_Epoch: "Home",
            tipTitle_Epoch: "Use texture over volume",
            tipDetail_Epoch: "Linen, wood trays and quiet candles often feel more refined than filling every corner with objects.",
            tipExtendedDetail_Epoch: "Home rituals feel convincing when they look easy to live with. Focus on fabric, ceramics, wood and soft light to create warmth, and let negative space make the room feel calm instead of overloaded.",
            tipChecklist_Epoch: [
                "Choose two natural textures for the base layer.",
                "Keep tabletops less than two-thirds full.",
                "Use candles or lamps for quiet highlights."
            ],
            iconName_Epoch: "house.fill"
        ),
        HomeSceneTipModel_Epoch(
            sceneName_Epoch: "Gathering",
            tipTitle_Epoch: "Create one shared focal point",
            tipDetail_Epoch: "A central snack island or drink bar naturally brings people together and improves the whole layout.",
            tipExtendedDetail_Epoch: "Group gatherings need visual structure and movement. A central snack island, dessert table or drink bar gives guests a natural place to gather, while surrounding seating and decor stay more relaxed and breathable.",
            tipChecklist_Epoch: [
                "Place food or drinks at the center of movement.",
                "Keep walking paths clear around the main table.",
                "Use one tall decor piece so the center reads faster."
            ],
            iconName_Epoch: "person.3.fill"
        ),
        HomeSceneTipModel_Epoch(
            sceneName_Epoch: "Wedding",
            tipTitle_Epoch: "Reserve breathing space",
            tipDetail_Epoch: "Leave clean gaps between flowers, frames and signage so the ceremony details look calm and premium.",
            tipExtendedDetail_Epoch: "Wedding styling usually looks more premium when every element gets room to breathe. Instead of adding more flowers or signs, create spacing between layers so the aisle, signing table and welcome area each feel intentional.",
            tipChecklist_Epoch: [
                "Separate flowers, frames and signage by visual layers.",
                "Keep the aisle or key path unobstructed.",
                "Highlight one premium material such as glass or satin."
            ],
            iconName_Epoch: "camera.aperture"
        ),
        HomeSceneTipModel_Epoch(
            sceneName_Epoch: "Graduation",
            tipTitle_Epoch: "Mix memory props with height",
            tipDetail_Epoch: "Use books, certificates and one tall floral piece to make the setup feel layered and photo ready.",
            tipExtendedDetail_Epoch: "Graduation scenes feel memorable when personal history appears in the styling. Combine books, certificates, framed photos and one taller floral or light element so the setup tells a story instead of looking like a generic celebration table.",
            tipChecklist_Epoch: [
                "Mix framed memories with books or certificates.",
                "Build one tall point and one lower photo zone.",
                "Use school colors only as accents, not the whole base."
            ],
            iconName_Epoch: "graduationcap.fill"
        )
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Epoch: [(String, String)] = [
        ("This looks absolutely magical! Nothing beats a bonfire with good friends", "S'mores and stories by the fire—that's the perfect night right there!"),
        ("You captured the essence of what makes bonfires special! Love this vibe", "The simplicity of firelight and friendship is truly magical. Beautiful moment!"),
        ("Those dancing flames and peaceful vibes—I can feel the warmth through the screen!", "This is exactly what I needed to see today. Time to plan a bonfire night!"),
        ("The connection between hearts around a fire is something special. Beautifully said!", "Love how you describe the warmth coming from both the fire and the company"),
        ("Already know who I'd tag for this! Nothing beats bonfire nights with the right people", "First thing I'd share? Probably my terrible ghost stories! Who's with me?"),
        ("Our bonfire story: We accidentally used green wood and it wouldn't stop smoking!", "Crispy marshmallows till midnight sounds perfect! Need to organize one soon"),
        ("Your fire family sounds amazing! Count me in for round two", "It really is all about the people. The fire is just an excuse to gather!"),
        ("Off-key singing is mandatory at our bonfires too! Also love the fire color debate", "My go-to activity: trying to roast the perfect marshmallow"),
        ("The stars above and fire below—this is poetry in real life!", "That feeling of the universe being big yet feeling so close... perfectly captured!"),
        ("The embers mixing with stars is such a beautiful image. Pure peace", "Sometimes we just need warmth seeping into our bones and quiet moments"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Epoch {
    
    /// 生成指定范围的随机整数
    static func nextInt_Epoch(min_epoch: Int, range_epoch: Int) -> Int {
        return Int.random(in: min_epoch..<(min_epoch + range_epoch))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Epoch<T>(from list_epoch: [T], count_epoch: Int) -> [T] {
        guard !list_epoch.isEmpty else { return [] }
        guard list_epoch.count > count_epoch else { return list_epoch }
        
        var selected_epoch: [T] = []
        var indices_epoch: Set<Int> = []
        
        while selected_epoch.count < count_epoch && indices_epoch.count < list_epoch.count {
            let index_epoch = Int.random(in: 0..<list_epoch.count)
            if !indices_epoch.contains(index_epoch) {
                indices_epoch.insert(index_epoch)
                selected_epoch.append(list_epoch[index_epoch])
            }
        }
        
        return selected_epoch
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Epoch {
    
    private weak var dataLocal_Epoch: LocalData_Epoch?
    
    init(dataLocal_epoch: LocalData_Epoch) {
        self.dataLocal_Epoch = dataLocal_epoch
    }
    
    /// 初始化生成用户数据
    func initUsers_Epoch() {
        guard let dataLocal_epoch = dataLocal_Epoch else { return }
        dataLocal_epoch.userList_Epoch.removeAll()
        for (index_epoch, userInfo_epoch) in DataSource_Epoch.usersInfo_Epoch.enumerated() {
            let (username_epoch, introduce_epoch) = userInfo_epoch
            let userHead_epoch = DataSource_Epoch.userAvatarSymbols_Epoch[index_epoch % DataSource_Epoch.userAvatarSymbols_Epoch.count]
            let userAlbum_epoch = DataSource_Epoch.userMediaSymbols_Epoch[index_epoch % DataSource_Epoch.userMediaSymbols_Epoch.count]
            
            let user_epoch = PrewUserModel_Epoch()
            user_epoch.userId_Epoch = index_epoch + DataConfig_Epoch.userIdStart_Epoch
            user_epoch.userName_Epoch = username_epoch
            user_epoch.userIntroduce_Epoch = introduce_epoch
            user_epoch.userHead_Epoch = userHead_epoch
            user_epoch.userMedia_Epoch = [userAlbum_epoch]
            user_epoch.userLike_Epoch = []
            user_epoch.userFollow_Epoch = 15 + Int.random(in: 1...50)
            user_epoch.userFans_Epoch = 20 + Int.random(in: 1...50)
            
            dataLocal_epoch.userList_Epoch.append(user_epoch)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Epoch() {
        guard let dataLocal_epoch = dataLocal_Epoch else { return }
        dataLocal_epoch.titleList_Epoch.removeAll()
        
        for (index_epoch, postInfo_epoch) in DataSource_Epoch.postsInfo_Epoch.enumerated() {
            let (title_epoch, content_epoch, media_epoch) = postInfo_epoch
            
            // 循环分配作者
            let authorIndex_epoch = index_epoch % dataLocal_epoch.userList_Epoch.count
            guard authorIndex_epoch < dataLocal_epoch.userList_Epoch.count else { continue }
            let author_epoch = dataLocal_epoch.userList_Epoch[authorIndex_epoch]
            
            // 生成评论
            let comments_epoch = generateComments_Epoch(
                postIndex_epoch: index_epoch,
                postAuthorUserId_epoch: author_epoch.userId_Epoch ?? 0
            )
            
            // 创建帖子
            let post_epoch = TitleModel_Epoch(
                titleId_Epoch: index_epoch + DataConfig_Epoch.postIdStart_Epoch,
                titleUserId_Epoch: author_epoch.userId_Epoch ?? 0,
                titleUserName_Epoch: author_epoch.userName_Epoch ?? "",
                titleMeidas_Epoch: [media_epoch],
                title_Epoch: title_epoch,
                titleContent_Epoch: content_epoch,
                reviews_Epoch: comments_epoch,
                likes_Epoch: RandomUtil_Epoch.nextInt_Epoch(min_epoch: 10, range_epoch: 150)
            )
            
            dataLocal_epoch.titleList_Epoch.append(post_epoch)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Epoch(postIndex_epoch: Int, postAuthorUserId_epoch: Int) -> [Comment_Epoch] {
        guard let dataLocal_epoch = dataLocal_Epoch else { return [] }
        
        let availableUsers_epoch = dataLocal_epoch.getAvailableCommenters_Epoch(postAuthorUserId_epoch: postAuthorUserId_epoch)
        guard availableUsers_epoch.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_epoch = availableUsers_epoch[postIndex_epoch % availableUsers_epoch.count]
        let commenter2_epoch = availableUsers_epoch[(postIndex_epoch + 1) % availableUsers_epoch.count]
        
        // 获取评论内容
        let commentIndex_epoch = postIndex_epoch % DataSource_Epoch.comments_Epoch.count
        let (comment1_epoch, comment2_epoch) = DataSource_Epoch.comments_Epoch[commentIndex_epoch]
        
        return [
            Comment_Epoch(
                commentId_Epoch: postIndex_epoch * 2 + 1,
                commentUserId_Epoch: commenter1_epoch.userId_Epoch ?? 0,
                commentUserName_Epoch: commenter1_epoch.userName_Epoch ?? "",
                commentContent_Epoch: comment1_epoch
            ),
            Comment_Epoch(
                commentId_Epoch: postIndex_epoch * 2 + 2,
                commentUserId_Epoch: commenter2_epoch.userId_Epoch ?? 0,
                commentUserName_Epoch: commenter2_epoch.userName_Epoch ?? "",
                commentContent_Epoch: comment2_epoch
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Epoch() {
        guard let dataLocal_epoch = dataLocal_Epoch else { return }
        
        for i_epoch in 0..<dataLocal_epoch.userList_Epoch.count {
            let user_epoch = dataLocal_epoch.userList_Epoch[i_epoch]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_epoch = dataLocal_epoch.getPostsExcludingUser_Epoch(
                userId_epoch: user_epoch.userId_Epoch ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_epoch = RandomUtil_Epoch.selectRandomItems_Epoch(
                from: availablePosts_epoch,
                count_epoch: DataConfig_Epoch.likePostCount_Epoch
            )
            
            dataLocal_epoch.userList_Epoch[i_epoch].userLike_Epoch = likePosts_epoch
        }
    }
}
