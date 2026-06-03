import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Bague {
    /// ID起始值
    static let userIdStart_Bague = 10
    static let postIdStart_Bague = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Bague = 2
}

/// 本地数据管理类
class LocalData_Bague {
    
    /// 单例
    static let shared_Bague = LocalData_Bague()
    
    /// 用户列表
    var userList_Bague: [PrewUserModel_Bague] = []
    
    /// 帖子列表
    var titleList_Bague: [TitleModel_Bague] = []

    /// 中古故事馆每日话题（官方固定 3 条，每日更新）
    var vintageTopics_Bague: [VintageTopicItem_Bague] = [
        VintageTopicItem_Bague(
            topicId_Bague: 1,
            title_Bague: "My First Vintage Bag",
            description_Bague: "Share the story of your very first second-hand bag find — where did you find it, and what made it special?",
            iconName_Bague: "bag.fill",
            comments_Bague: [
                VintageComment_Bague(commentId_Bague: 101, commentUserId_Bague: 11, commentUserName_Bague: "EmberSeeker", commentContent_Bague: "Found mine at a tiny market in Paris — a 90s Longchamp in perfect condition!"),
                VintageComment_Bague(commentId_Bague: 102, commentUserId_Bague: 12, commentUserName_Bague: "ForestWhisper", commentContent_Bague: "My grandma gifted me her old leather tote. It still smells like her perfume."),
            ]
        ),
        VintageTopicItem_Bague(
            topicId_Bague: 2,
            title_Bague: "Hidden Gem Spots",
            description_Bague: "Where do you hunt for niche vintage bags? Flea markets, thrift stores, online platforms — share your secret spots!",
            iconName_Bague: "mappin.and.ellipse",
            comments_Bague: [
                VintageComment_Bague(commentId_Bague: 103, commentUserId_Bague: 13, commentUserName_Bague: "FlameJumper", commentContent_Bague: "Japanese Mercari is an absolute goldmine for vintage Coach."),
                VintageComment_Bague(commentId_Bague: 104, commentUserId_Bague: 14, commentUserName_Bague: "AshesToArt", commentContent_Bague: "Local estate sales near old neighborhoods — always underpriced gems waiting!"),
            ]
        ),
        VintageTopicItem_Bague(
            topicId_Bague: 3,
            title_Bague: "Restoration Journey",
            description_Bague: "Have you ever brought an old bag back to life? Share your restoration tips, before & after moments.",
            iconName_Bague: "wrench.and.screwdriver.fill",
            comments_Bague: [
                VintageComment_Bague(commentId_Bague: 105, commentUserId_Bague: 15, commentUserName_Bague: "NightGlow", commentContent_Bague: "Used leather conditioner on a 1985 Louis Vuitton — the transformation was unreal."),
            ]
        ),
    ]
    
    /// 数据生成器
    private lazy var generator_Bague: DataGenerator_Bague = {
        return DataGenerator_Bague(dataLocal_bague: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Bague() {
        generator_Bague.initUsers_Bague()
        generator_Bague.initPosts_Bague()
        generator_Bague.setUserLikes_Bague()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Bague(userId_bague: Int) -> [TitleModel_Bague] {
        return titleList_Bague.filter { $0.titleUserId_Bague != userId_bague }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Bague(postAuthorUserId_bague: Int) -> [PrewUserModel_Bague] {
        return userList_Bague.filter { $0.userId_Bague != postAuthorUserId_bague }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Bague {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Bague: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "head1", "head1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "head2", "head2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "head3", "head3"),
        ("AshesToArt", "Turning moments into memories", "head4", "head4"),
        ("NightGlow", "Capturing the magic of firelight", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Bague: [(String, String, String)] = [
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
    static let comments_Bague: [(String, String)] = [
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
private struct RandomUtil_Bague {
    
    /// 生成指定范围的随机整数
    static func nextInt_Bague(min_bague: Int, range_bague: Int) -> Int {
        return Int.random(in: min_bague..<(min_bague + range_bague))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Bague<T>(from list_bague: [T], count_bague: Int) -> [T] {
        guard !list_bague.isEmpty else { return [] }
        guard list_bague.count > count_bague else { return list_bague }
        
        var selected_bague: [T] = []
        var indices_bague: Set<Int> = []
        
        while selected_bague.count < count_bague && indices_bague.count < list_bague.count {
            let index_bague = Int.random(in: 0..<list_bague.count)
            if !indices_bague.contains(index_bague) {
                indices_bague.insert(index_bague)
                selected_bague.append(list_bague[index_bague])
            }
        }
        
        return selected_bague
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Bague {
    
    private weak var dataLocal_Bague: LocalData_Bague?
    
    init(dataLocal_bague: LocalData_Bague) {
        self.dataLocal_Bague = dataLocal_bague
    }
    
    /// 初始化生成用户数据
    func initUsers_Bague() {
        guard let dataLocal_bague = dataLocal_Bague else { return }
        dataLocal_bague.userList_Bague.removeAll()
        
        for (index_bague, userInfo_bague) in DataSource_Bague.usersInfo_Bague.enumerated() {
            let (username_bague, introduce_bague, userHead_bague, userAlbum_bague) = userInfo_bague
            
            let user_bague = PrewUserModel_Bague()
            user_bague.userId_Bague = index_bague + DataConfig_Bague.userIdStart_Bague
            user_bague.userName_Bague = username_bague
            user_bague.userIntroduce_Bague = introduce_bague
            user_bague.userHead_Bague = userHead_bague
            user_bague.userMedia_Bague = [userAlbum_bague]
            user_bague.userLike_Bague = []
            user_bague.userFollow_Bague = 15 + Int.random(in: 1...50)
            user_bague.userFans_Bague = 20 + Int.random(in: 1...50)
            
            dataLocal_bague.userList_Bague.append(user_bague)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Bague() {
        guard let dataLocal_bague = dataLocal_Bague else { return }
        dataLocal_bague.titleList_Bague.removeAll()
        
        for (index_bague, postInfo_bague) in DataSource_Bague.postsInfo_Bague.enumerated() {
            let (title_bague, content_bague, media_bague) = postInfo_bague
            
            // 循环分配作者
            let authorIndex_bague = index_bague % dataLocal_bague.userList_Bague.count
            guard authorIndex_bague < dataLocal_bague.userList_Bague.count else { continue }
            let author_bague = dataLocal_bague.userList_Bague[authorIndex_bague]
            
            // 生成评论
            let comments_bague = generateComments_Bague(
                postIndex_bague: index_bague,
                postAuthorUserId_bague: author_bague.userId_Bague ?? 0
            )
            
            // 创建帖子
            let post_bague = TitleModel_Bague(
                titleId_Bague: index_bague + DataConfig_Bague.postIdStart_Bague,
                titleUserId_Bague: author_bague.userId_Bague ?? 0,
                titleUserName_Bague: author_bague.userName_Bague ?? "",
                titleMeidas_Bague: [media_bague],
                title_Bague: title_bague,
                titleContent_Bague: content_bague,
                reviews_Bague: comments_bague,
                likes_Bague: RandomUtil_Bague.nextInt_Bague(min_bague: 10, range_bague: 150)
            )
            
            dataLocal_bague.titleList_Bague.append(post_bague)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Bague(postIndex_bague: Int, postAuthorUserId_bague: Int) -> [Comment_Bague] {
        guard let dataLocal_bague = dataLocal_Bague else { return [] }
        
        let availableUsers_bague = dataLocal_bague.getAvailableCommenters_Bague(postAuthorUserId_bague: postAuthorUserId_bague)
        guard availableUsers_bague.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_bague = availableUsers_bague[postIndex_bague % availableUsers_bague.count]
        let commenter2_bague = availableUsers_bague[(postIndex_bague + 1) % availableUsers_bague.count]
        
        // 获取评论内容
        let commentIndex_bague = postIndex_bague % DataSource_Bague.comments_Bague.count
        let (comment1_bague, comment2_bague) = DataSource_Bague.comments_Bague[commentIndex_bague]
        
        return [
            Comment_Bague(
                commentId_Bague: postIndex_bague * 2 + 1,
                commentUserId_Bague: commenter1_bague.userId_Bague ?? 0,
                commentUserName_Bague: commenter1_bague.userName_Bague ?? "",
                commentContent_Bague: comment1_bague
            ),
            Comment_Bague(
                commentId_Bague: postIndex_bague * 2 + 2,
                commentUserId_Bague: commenter2_bague.userId_Bague ?? 0,
                commentUserName_Bague: commenter2_bague.userName_Bague ?? "",
                commentContent_Bague: comment2_bague
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Bague() {
        guard let dataLocal_bague = dataLocal_Bague else { return }
        
        for i_bague in 0..<dataLocal_bague.userList_Bague.count {
            let user_bague = dataLocal_bague.userList_Bague[i_bague]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_bague = dataLocal_bague.getPostsExcludingUser_Bague(
                userId_bague: user_bague.userId_Bague ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_bague = RandomUtil_Bague.selectRandomItems_Bague(
                from: availablePosts_bague,
                count_bague: DataConfig_Bague.likePostCount_Bague
            )
            
            dataLocal_bague.userList_Bague[i_bague].userLike_Bague = likePosts_bague
        }
    }
}
