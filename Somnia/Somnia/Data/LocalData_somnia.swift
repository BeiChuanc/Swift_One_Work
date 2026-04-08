import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Somnia {
    /// ID起始值
    static let userIdStart_Somnia = 10
    static let postIdStart_Somnia = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Somnia = 2
}

/// 本地数据管理类
class LocalData_Somnia {
    
    /// 单例
    static let shared_Somnia = LocalData_Somnia()
    
    /// 用户列表
    var userList_Somnia: [PrewUserModel_Somnia] = []
    
    /// 帖子列表
    var titleList_Somnia: [TitleModel_Somnia] = []
    
    /// 数据生成器
    private lazy var generator_Somnia: DataGenerator_Somnia = {
        return DataGenerator_Somnia(dataLocal_somnia: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Somnia() {
        generator_Somnia.initUsers_Somnia()
        generator_Somnia.initPosts_Somnia()
        generator_Somnia.setUserLikes_Somnia()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Somnia(userId_somnia: Int) -> [TitleModel_Somnia] {
        return titleList_Somnia.filter { $0.titleUserId_Somnia != userId_somnia }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Somnia(postAuthorUserId_somnia: Int) -> [PrewUserModel_Somnia] {
        return userList_Somnia.filter { $0.userId_Somnia != postAuthorUserId_somnia }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Somnia {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Somnia: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "head1", "head1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "head2", "head2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "head3", "head3"),
        ("AshesToArt", "Turning moments into memories", "head4", "head4"),
        ("NightGlow", "Capturing the magic of firelight", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Somnia: [(String, String, String)] = [
        ("Perfect Bonfire Night", "The bonfire crackles softly, wrapping every face in warm light; we pass around s'mores, and stories flow as freely as the laughter. This is the kind of night that stays with you long after the embers fade.", "title1"),
        ("Magical Firelight", "There's something magical about firelight—it turns ordinary moments into treasures. Sitting here, feeling the warmth on my hands and listening to friends chat, I realize happiness is just this simple.", "title2"),
        ("Dancing Flames", "The flames dance and flicker, casting gentle shadows on the grass. No loud noises, no rush—just the glow of fire, the breeze, and people who make the night feel like home.", "title3"),
        ("Warm Hearts", "As the night grows darker, the bonfire burns brighter. It's not just the fire that warms us, but the company, the shared smiles, and the quiet connection between every heart here.", "title4"),
        ("Glowing Memories", "Look at this glowing fire and the grinning faces around it—this is what good nights are made of! Tag the person you'd drag to sit with you by such a bonfire.", "title5"),
        ("Absolute Perfection", "Last night's bonfire was absolute perfection: great friends, crispy marshmallows, and a fire that burned steady till midnight. Who's got a bonfire story to top this?", "media_one"),
        ("Fire Family", "I used to think bonfires were just about fire, but now I know it's about the people. This crew turned a simple fire into an unforgettable night.", "title7"),
        ("Fun Activities", "We spent hours around this bonfire: singing off-key, playing silly games, and even debating whether the fire is orange or red. What's your go-to bonfire activity?", "title8"),
        ("Stars and Fire", "Above us, the sky is dotted with stars; below us, the bonfire paints the night in warm hues. The universe feels so big, yet this little circle of fire and friends makes everything feel so close.", "media_two"),
        ("Peaceful Embers", "Embers drift up like tiny fireflies, mixing with the stars in the dark. I sit here, quiet, and let the warmth seep into my bones—this is the peace I've been craving.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Somnia: [(String, String)] = [
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
private struct RandomUtil_Somnia {
    
    /// 生成指定范围的随机整数
    static func nextInt_Somnia(min_somnia: Int, range_somnia: Int) -> Int {
        return Int.random(in: min_somnia..<(min_somnia + range_somnia))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Somnia<T>(from list_somnia: [T], count_somnia: Int) -> [T] {
        guard !list_somnia.isEmpty else { return [] }
        guard list_somnia.count > count_somnia else { return list_somnia }
        
        var selected_somnia: [T] = []
        var indices_somnia: Set<Int> = []
        
        while selected_somnia.count < count_somnia && indices_somnia.count < list_somnia.count {
            let index_somnia = Int.random(in: 0..<list_somnia.count)
            if !indices_somnia.contains(index_somnia) {
                indices_somnia.insert(index_somnia)
                selected_somnia.append(list_somnia[index_somnia])
            }
        }
        
        return selected_somnia
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Somnia {
    
    private weak var dataLocal_Somnia: LocalData_Somnia?
    
    init(dataLocal_somnia: LocalData_Somnia) {
        self.dataLocal_Somnia = dataLocal_somnia
    }
    
    /// 初始化生成用户数据
    func initUsers_Somnia() {
        guard let dataLocal_somnia = dataLocal_Somnia else { return }
        dataLocal_somnia.userList_Somnia.removeAll()
        
        for (index_somnia, userInfo_somnia) in DataSource_Somnia.usersInfo_Somnia.enumerated() {
            let (username_somnia, introduce_somnia, userHead_somnia, userAlbum_somnia) = userInfo_somnia
            
            let user_somnia = PrewUserModel_Somnia()
            user_somnia.userId_Somnia = index_somnia + DataConfig_Somnia.userIdStart_Somnia
            user_somnia.userName_Somnia = username_somnia
            user_somnia.userIntroduce_Somnia = introduce_somnia
            user_somnia.userHead_Somnia = userHead_somnia
            user_somnia.userMedia_Somnia = [userAlbum_somnia]
            user_somnia.userLike_Somnia = []
            user_somnia.userFollow_Somnia = 15 + Int.random(in: 1...50)
            user_somnia.userFans_Somnia = 20 + Int.random(in: 1...50)
            
            dataLocal_somnia.userList_Somnia.append(user_somnia)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Somnia() {
        guard let dataLocal_somnia = dataLocal_Somnia else { return }
        dataLocal_somnia.titleList_Somnia.removeAll()
        
        for (index_somnia, postInfo_somnia) in DataSource_Somnia.postsInfo_Somnia.enumerated() {
            let (title_somnia, content_somnia, media_somnia) = postInfo_somnia
            
            // 循环分配作者
            let authorIndex_somnia = index_somnia % dataLocal_somnia.userList_Somnia.count
            guard authorIndex_somnia < dataLocal_somnia.userList_Somnia.count else { continue }
            let author_somnia = dataLocal_somnia.userList_Somnia[authorIndex_somnia]
            
            // 生成评论
            let comments_somnia = generateComments_Somnia(
                postIndex_somnia: index_somnia,
                postAuthorUserId_somnia: author_somnia.userId_Somnia ?? 0
            )
            
            // 创建帖子
            let post_somnia = TitleModel_Somnia(
                titleId_Somnia: index_somnia + DataConfig_Somnia.postIdStart_Somnia,
                titleUserId_Somnia: author_somnia.userId_Somnia ?? 0,
                titleUserName_Somnia: author_somnia.userName_Somnia ?? "",
                titleMeidas_Somnia: [media_somnia],
                title_Somnia: title_somnia,
                titleContent_Somnia: content_somnia,
                reviews_Somnia: comments_somnia,
                likes_Somnia: RandomUtil_Somnia.nextInt_Somnia(min_somnia: 10, range_somnia: 150)
            )
            
            dataLocal_somnia.titleList_Somnia.append(post_somnia)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Somnia(postIndex_somnia: Int, postAuthorUserId_somnia: Int) -> [Comment_Somnia] {
        guard let dataLocal_somnia = dataLocal_Somnia else { return [] }
        
        let availableUsers_somnia = dataLocal_somnia.getAvailableCommenters_Somnia(postAuthorUserId_somnia: postAuthorUserId_somnia)
        guard availableUsers_somnia.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_somnia = availableUsers_somnia[postIndex_somnia % availableUsers_somnia.count]
        let commenter2_somnia = availableUsers_somnia[(postIndex_somnia + 1) % availableUsers_somnia.count]
        
        // 获取评论内容
        let commentIndex_somnia = postIndex_somnia % DataSource_Somnia.comments_Somnia.count
        let (comment1_somnia, comment2_somnia) = DataSource_Somnia.comments_Somnia[commentIndex_somnia]
        
        return [
            Comment_Somnia(
                commentId_Somnia: postIndex_somnia * 2 + 1,
                commentUserId_Somnia: commenter1_somnia.userId_Somnia ?? 0,
                commentUserName_Somnia: commenter1_somnia.userName_Somnia ?? "",
                commentContent_Somnia: comment1_somnia
            ),
            Comment_Somnia(
                commentId_Somnia: postIndex_somnia * 2 + 2,
                commentUserId_Somnia: commenter2_somnia.userId_Somnia ?? 0,
                commentUserName_Somnia: commenter2_somnia.userName_Somnia ?? "",
                commentContent_Somnia: comment2_somnia
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Somnia() {
        guard let dataLocal_somnia = dataLocal_Somnia else { return }
        
        for i_somnia in 0..<dataLocal_somnia.userList_Somnia.count {
            let user_somnia = dataLocal_somnia.userList_Somnia[i_somnia]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_somnia = dataLocal_somnia.getPostsExcludingUser_Somnia(
                userId_somnia: user_somnia.userId_Somnia ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_somnia = RandomUtil_Somnia.selectRandomItems_Somnia(
                from: availablePosts_somnia,
                count_somnia: DataConfig_Somnia.likePostCount_Somnia
            )
            
            dataLocal_somnia.userList_Somnia[i_somnia].userLike_Somnia = likePosts_somnia
        }
    }
}
