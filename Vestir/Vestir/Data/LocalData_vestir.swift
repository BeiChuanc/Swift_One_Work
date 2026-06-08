import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Vestir {
    /// ID起始值
    static let userIdStart_Vestir = 10
    static let postIdStart_Vestir = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Vestir = 2
}

/// 本地数据管理类
class LocalData_Vestir {
    
    /// 单例
    static let shared_Vestir = LocalData_Vestir()
    
    /// 用户列表
    var userList_Vestir: [PrewUserModel_Vestir] = []
    
    /// 帖子列表
    var titleList_Vestir: [TitleModel_Vestir] = []

    /// 穿搭挑战列表
    var challengeList_Vestir: [OutfitChallenge_Vestir] = []
    
    /// 数据生成器
    private lazy var generator_Vestir: DataGenerator_Vestir = {
        return DataGenerator_Vestir(dataLocal_vestir: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Vestir() {
        generator_Vestir.initUsers_Vestir()
        generator_Vestir.initPosts_Vestir()
        generator_Vestir.setUserLikes_Vestir()
        initChallenges_Vestir()
    }

    /// 初始化预制穿搭挑战数据
    private func initChallenges_Vestir() {
        challengeList_Vestir = [
            OutfitChallenge_Vestir(
                challengeId_Vestir: 1,
                title_Vestir: "Monochrome Week",
                desc_Vestir: "Wear a full monochrome outfit for 3 days this week. Show the world your tonal dressing skills!",
                theme_Vestir: "Monochrome",
                badgeIcon_Vestir: "circle.lefthalf.filled",
                participantCount_Vestir: 1247,
                daysRemaining_Vestir: 4,
                isHot_Vestir: true,
                discussions_Vestir: [
                    Comment_Vestir(commentId_Vestir: 101, commentUserId_Vestir: 11,
                                   commentUserName_Vestir: "EmberSeeker",
                                   commentContent_Vestir: "Going full black today 🖤 This challenge is everything!"),
                    Comment_Vestir(commentId_Vestir: 102, commentUserId_Vestir: 12,
                                   commentUserName_Vestir: "ForestWhisper",
                                   commentContent_Vestir: "All-cream outfit with beige accessories, loving this vibe ✨"),
                    Comment_Vestir(commentId_Vestir: 103, commentUserId_Vestir: 13,
                                   commentUserName_Vestir: "FlameJumper",
                                   commentContent_Vestir: "Navy from head to toe — surprisingly versatile!"),
                ]
            ),
            OutfitChallenge_Vestir(
                challengeId_Vestir: 2,
                title_Vestir: "Street Style Weekend",
                desc_Vestir: "Rock your boldest street-style look this weekend. Sneakers, layers, and attitude — let it all out.",
                theme_Vestir: "Streetwear",
                badgeIcon_Vestir: "figure.walk.motion",
                participantCount_Vestir: 896,
                daysRemaining_Vestir: 2,
                isHot_Vestir: true,
                discussions_Vestir: [
                    Comment_Vestir(commentId_Vestir: 201, commentUserId_Vestir: 14,
                                   commentUserName_Vestir: "SkyDancer",
                                   commentContent_Vestir: "Cargo pants + oversized hoodie + chunky sneakers, ready 🔥"),
                    Comment_Vestir(commentId_Vestir: 202, commentUserId_Vestir: 15,
                                   commentUserName_Vestir: "RiverStone",
                                   commentContent_Vestir: "Who said street style can't be elegant? Blazer over graphic tee!"),
                ]
            ),
            OutfitChallenge_Vestir(
                challengeId_Vestir: 3,
                title_Vestir: "Cozy Autumn Layers",
                desc_Vestir: "Embrace fall with your coziest layered look. Sweaters, scarves, and warm tones welcome!",
                theme_Vestir: "Autumn",
                badgeIcon_Vestir: "leaf.fill",
                participantCount_Vestir: 542,
                daysRemaining_Vestir: 7,
                isHot_Vestir: false,
                discussions_Vestir: [
                    Comment_Vestir(commentId_Vestir: 301, commentUserId_Vestir: 11,
                                   commentUserName_Vestir: "EmberSeeker",
                                   commentContent_Vestir: "Knit cardigan + plaid scarf + ankle boots is my go-to 🍂"),
                ]
            ),
        ]
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Vestir(userId_vestir: Int) -> [TitleModel_Vestir] {
        return titleList_Vestir.filter { $0.titleUserId_Vestir != userId_vestir }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Vestir(postAuthorUserId_vestir: Int) -> [PrewUserModel_Vestir] {
        return userList_Vestir.filter { $0.userId_Vestir != postAuthorUserId_vestir }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Vestir {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Vestir: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "head1", "head1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "head2", "head2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "head3", "head3"),
        ("AshesToArt", "Turning moments into memories", "head4", "head4"),
        ("NightGlow", "Capturing the magic of firelight", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Vestir: [(String, String, String)] = [
        ("Perfect Bonfire Night", "The bonfire crackles softly, wrapping every face in warm light; we pass around s'mores, and stories flow as freely as the laughter. This is the kind of night that stays with you long after the embers fade.", "title1"),
        ("Magical Firelight", "There's something magical about firelight—it turns ordinary moments into treasures. Sitting here, feeling the warmth on my hands and listening to friends chat, I realize happiness is just this simple.", "title2"),
        ("Dancing Flames", "The flames dance and flicker, casting gentle shadows on the grass. No loud noises, no rush—just the glow of fire, the breeze, and people who make the night feel like home.", "title3"),
        ("Warm Hearts", "As the night grows darker, the bonfire burns brighter. It's not just the fire that warms us, but the company, the shared smiles, and the quiet connection between every heart here.", "title4"),
        ("Glowing Memories", "Look at this glowing fire and the grinning faces around it—this is what good nights are made of! Tag the person you'd drag to sit with you by such a bonfire.", "title5"),
        ("Absolute Perfection", "Last night's bonfire was absolute perfection: great friends, crispy marshmallows, and a fire that burned steady till midnight. Who's got a bonfire story to top this?", "title6"),
        ("Fire Family", "I used to think bonfires were just about fire, but now I know it's about the people. This crew turned a simple fire into an unforgettable night.", "title7"),
        ("Fun Activities", "We spent hours around this bonfire: singing off-key, playing silly games, and even debating whether the fire is orange or red. What's your go-to bonfire activity?", "title8"),
        ("Stars and Fire", "Above us, the sky is dotted with stars; below us, the bonfire paints the night in warm hues. The universe feels so big, yet this little circle of fire and friends makes everything feel so close.", "title8"),
        ("Peaceful Embers", "Embers drift up like tiny fireflies, mixing with the stars in the dark. I sit here, quiet, and let the warmth seep into my bones—this is the peace I've been craving.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Vestir: [(String, String)] = [
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
private struct RandomUtil_Vestir {
    
    /// 生成指定范围的随机整数
    static func nextInt_Vestir(min_vestir: Int, range_vestir: Int) -> Int {
        return Int.random(in: min_vestir..<(min_vestir + range_vestir))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Vestir<T>(from list_vestir: [T], count_vestir: Int) -> [T] {
        guard !list_vestir.isEmpty else { return [] }
        guard list_vestir.count > count_vestir else { return list_vestir }
        
        var selected_vestir: [T] = []
        var indices_vestir: Set<Int> = []
        
        while selected_vestir.count < count_vestir && indices_vestir.count < list_vestir.count {
            let index_vestir = Int.random(in: 0..<list_vestir.count)
            if !indices_vestir.contains(index_vestir) {
                indices_vestir.insert(index_vestir)
                selected_vestir.append(list_vestir[index_vestir])
            }
        }
        
        return selected_vestir
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Vestir {
    
    private weak var dataLocal_Vestir: LocalData_Vestir?
    
    init(dataLocal_vestir: LocalData_Vestir) {
        self.dataLocal_Vestir = dataLocal_vestir
    }
    
    /// 初始化生成用户数据
    func initUsers_Vestir() {
        guard let dataLocal_vestir = dataLocal_Vestir else { return }
        dataLocal_vestir.userList_Vestir.removeAll()
        
        for (index_vestir, userInfo_vestir) in DataSource_Vestir.usersInfo_Vestir.enumerated() {
            let (username_vestir, introduce_vestir, userHead_vestir, userAlbum_vestir) = userInfo_vestir
            
            let user_vestir = PrewUserModel_Vestir()
            user_vestir.userId_Vestir = index_vestir + DataConfig_Vestir.userIdStart_Vestir
            user_vestir.userName_Vestir = username_vestir
            user_vestir.userIntroduce_Vestir = introduce_vestir
            user_vestir.userHead_Vestir = userHead_vestir
            user_vestir.userMedia_Vestir = [userAlbum_vestir]
            user_vestir.userLike_Vestir = []
            user_vestir.userFollow_Vestir = 15 + Int.random(in: 1...50)
            user_vestir.userFans_Vestir = 20 + Int.random(in: 1...50)
            
            dataLocal_vestir.userList_Vestir.append(user_vestir)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Vestir() {
        guard let dataLocal_vestir = dataLocal_Vestir else { return }
        dataLocal_vestir.titleList_Vestir.removeAll()
        
        for (index_vestir, postInfo_vestir) in DataSource_Vestir.postsInfo_Vestir.enumerated() {
            let (title_vestir, content_vestir, media_vestir) = postInfo_vestir
            
            // 循环分配作者
            let authorIndex_vestir = index_vestir % dataLocal_vestir.userList_Vestir.count
            guard authorIndex_vestir < dataLocal_vestir.userList_Vestir.count else { continue }
            let author_vestir = dataLocal_vestir.userList_Vestir[authorIndex_vestir]
            
            // 生成评论
            let comments_vestir = generateComments_Vestir(
                postIndex_vestir: index_vestir,
                postAuthorUserId_vestir: author_vestir.userId_Vestir ?? 0
            )
            
            // 创建帖子
            let post_vestir = TitleModel_Vestir(
                titleId_Vestir: index_vestir + DataConfig_Vestir.postIdStart_Vestir,
                titleUserId_Vestir: author_vestir.userId_Vestir ?? 0,
                titleUserName_Vestir: author_vestir.userName_Vestir ?? "",
                titleMeidas_Vestir: [media_vestir],
                title_Vestir: title_vestir,
                titleContent_Vestir: content_vestir,
                reviews_Vestir: comments_vestir,
                likes_Vestir: RandomUtil_Vestir.nextInt_Vestir(min_vestir: 10, range_vestir: 150)
            )
            
            dataLocal_vestir.titleList_Vestir.append(post_vestir)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Vestir(postIndex_vestir: Int, postAuthorUserId_vestir: Int) -> [Comment_Vestir] {
        guard let dataLocal_vestir = dataLocal_Vestir else { return [] }
        
        let availableUsers_vestir = dataLocal_vestir.getAvailableCommenters_Vestir(postAuthorUserId_vestir: postAuthorUserId_vestir)
        guard availableUsers_vestir.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_vestir = availableUsers_vestir[postIndex_vestir % availableUsers_vestir.count]
        let commenter2_vestir = availableUsers_vestir[(postIndex_vestir + 1) % availableUsers_vestir.count]
        
        // 获取评论内容
        let commentIndex_vestir = postIndex_vestir % DataSource_Vestir.comments_Vestir.count
        let (comment1_vestir, comment2_vestir) = DataSource_Vestir.comments_Vestir[commentIndex_vestir]
        
        return [
            Comment_Vestir(
                commentId_Vestir: postIndex_vestir * 2 + 1,
                commentUserId_Vestir: commenter1_vestir.userId_Vestir ?? 0,
                commentUserName_Vestir: commenter1_vestir.userName_Vestir ?? "",
                commentContent_Vestir: comment1_vestir
            ),
            Comment_Vestir(
                commentId_Vestir: postIndex_vestir * 2 + 2,
                commentUserId_Vestir: commenter2_vestir.userId_Vestir ?? 0,
                commentUserName_Vestir: commenter2_vestir.userName_Vestir ?? "",
                commentContent_Vestir: comment2_vestir
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Vestir() {
        guard let dataLocal_vestir = dataLocal_Vestir else { return }
        
        for i_vestir in 0..<dataLocal_vestir.userList_Vestir.count {
            let user_vestir = dataLocal_vestir.userList_Vestir[i_vestir]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_vestir = dataLocal_vestir.getPostsExcludingUser_Vestir(
                userId_vestir: user_vestir.userId_Vestir ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_vestir = RandomUtil_Vestir.selectRandomItems_Vestir(
                from: availablePosts_vestir,
                count_vestir: DataConfig_Vestir.likePostCount_Vestir
            )
            
            dataLocal_vestir.userList_Vestir[i_vestir].userLike_Vestir = likePosts_vestir
        }
    }
}
