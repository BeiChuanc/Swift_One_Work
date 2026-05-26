import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Niche {
    /// ID起始值
    static let userIdStart_Niche = 10
    static let postIdStart_Niche = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Niche = 2
}

/// 本地数据管理类
class LocalData_Niche {
    
    /// 单例
    static let shared_Niche = LocalData_Niche()
    
    /// 用户列表
    var userList_Niche: [PrewUserModel_Niche] = []
    
    /// 帖子列表
    var titleList_Niche: [TitleModel_Niche] = []
    
    /// 数据生成器
    private lazy var generator_Niche: DataGenerator_Niche = {
        return DataGenerator_Niche(dataLocal_niche: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Niche() {
        generator_Niche.initUsers_Niche()
        generator_Niche.initPosts_Niche()
        generator_Niche.setUserLikes_Niche()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Niche(userId_niche: Int) -> [TitleModel_Niche] {
        return titleList_Niche.filter { $0.titleUserId_Niche != userId_niche }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Niche(postAuthorUserId_niche: Int) -> [PrewUserModel_Niche] {
        return userList_Niche.filter { $0.userId_Niche != postAuthorUserId_niche }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Niche {

    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    /// 主题：亚文化部落成员，涵盖独立音乐、街头艺术、暗夜美学、手作文化、独立创作
    static let usersInfo_Niche: [(String, String, String, String)] = [
        ("VioletVinyl",   "Vinyl collector & indie zine maker · thrift store is my gallery",           "head1", "head1"),
        ("UrbanGhost",    "Midnight street art hunter · I find beauty where others see blank walls",   "head2", "head2"),
        ("PetrichorSoul", "Forest forager · cottagecore dreamer · smell of rain is my perfume",        "head3", "head3"),
        ("WaxMoth",       "Candle alchemist & night market wanderer · melting wax, melting hours",     "head4", "head4"),
        ("CinderDream",   "Alt-fashion zine creator · building a world from fabric scraps & poetry",   "head5", "head5"),
    ]

    /// 帖子信息列表 (标题, 内容, 媒体URL)
    /// 主题：小众爱好日常、地下文化探索、手作与独立创作
    static let postsInfo_Niche: [(String, String, String)] = [
        (
            "Botanical Candle No.12",
            "Batch twelve. Rosemary, dried lavender, and a pinch of smoked cedarwood. The scent fills the whole room before the flame even steadies. There's something deeply meditative about melting wax in the dark with lo-fi playing softly in the background.",
            "title4"
        ),
        (
            "The Forgotten Café Corner",
            "Third visit to this café in six months and I'm still the only one who ever sits in this back corner booth. The light comes through the frosted glass at exactly 4PM in a way that makes everything look like a film still. I always bring a Murakami book. I never really read it.",
            "title5"
        ),
        (
            "Zine #3 — Finally Printed",
            "After three months of procrastinating, sketching, re-sketching, and arguing with the printer—my zine is real. Fifty copies, hand-numbered, with a cover linocut I carved at 2AM. It's imperfect in every way I planned and in some ways I didn't. I love it.",
            "title6"
        ),
        (
            "Dawn Foraging",
            "Left the house at 5:30AM before the city woke up. The forest at that hour feels like a secret the world forgot to lock. Found chanterelles near the old oak, some wild mint by the creek, and a calm I haven't felt all week. Breakfast was extraordinary.",
            "title7"
        ),
        (
            "Building My First Synth",
            "Forty-three components, two fried resistors, and one minor electrical burn later—it makes noise. Chaotic, unpredictable, beautiful noise. I didn't follow the schematic perfectly on purpose. I wanted to hear what it would do when left to figure itself out.",
            "title8"
        ),
        (
            "Rooftop Garden, Month 7",
            "Seven months ago this rooftop was bare concrete. Now: tomatoes, wildflowers, a small herb spiral, and one very aggressive mint plant that I may have underestimated. People from the floors below keep texting me asking if they can visit. I say yes every time.",
            "title9"
        ),
        (
            "Late Night Ramen Strangers",
            "2AM, the only ramen spot still open. The girl next to me was reading Dostoevsky. The guy across was drawing something I couldn't quite see. We ended up talking until the owner politely asked us to leave. We exchanged handwritten notes instead of numbers. That felt right.",
            "title10"
        ),
        (
            "Hidden Vinyl Alley",
            "Ducked into a tiny alley in the old district and found this record shop that's been there since 1987. The owner knows every pressing date by heart. Spent three hours flipping through crates and left with six records I didn't plan to buy—and zero regrets.",
            "title1"
        ),
        (
            "Thrift Haul of the Century",
            "Five hours, three thrift stores, fourteen dollars total. I don't understand people who pay retail. Every stitch in a secondhand piece has a story—I'm just the next chapter. Today's find: a 1970s suede jacket that smells like someone's best decade.",
            "title2"
        ),
        (
            "Midnight Mural Crawl",
            "Started at 11PM and didn't stop until the streets went quiet at 3AM. Found seven murals I'd never seen before—three in alleys too narrow for two people to walk side by side. The best art hides where maps don't go.",
            "title3"
        ),
    ]

    /// 评论列表 (评论1, 评论2)
    /// 体现部落成员间的共鸣、好奇与支持
    static let comments_Niche: [(String, String)] = [
        ("I can feel the crackle of those records from here. A shop that's survived since '87? That owner is a living archive.", "You left with six and zero regrets—this is the correct way to live. What was the best find?"),
        ("Fourteen dollars for a 70s suede jacket is why I will never understand fast fashion. That jacket chose you.", "The 'next chapter' line hit differently. Every thrift piece is basically a co-authored story."),
        ("Three murals in alleys too narrow to walk side by side—that's where all the real things are hiding.", "The best art hides where maps don't go. I'm saving this quote. This is the whole philosophy."),
        ("Rosemary and smoked cedarwood in the same candle? My olfactory imagination is working overtime right now.", "Batch twelve! I remember you posting batch one. This is such a beautiful slow progression to witness."),
        ("The frosted glass light at 4PM sounds like something you'd describe in a sentence and then realize you've been staring for an hour.", "Not reading the Murakami but bringing it anyway is the most honest thing I've read all week."),
        ("Hand-numbered, imperfect, made at 2AM — this is exactly what zines are supposed to be. Please tell me there's a way to get one.", "The printer argument is a rite of passage every zine maker goes through. You survived it. Congrats."),
        ("5:30AM forest. Chanterelles by the oak. You described peace better than most people do with a hundred words.", "Wild mint by the creek and unexpected calm — I need to do this. You've convinced me."),
        ("An intentional deviation from the schematic to hear what it figures out on its own. That's not building a synth, that's raising one.", "Two fried resistors is basically a tuition fee. The chaotic noise is the graduation certificate."),
        ("Seven months of bare concrete to wildflowers and tomatoes. Saying yes every time they ask to visit is the right call always.", "The mint underestimation is a universal experience. It always wins. You simply coexist with it now."),
        ("Exchanged handwritten notes instead of numbers. That is a better ending than any algorithm could have written.", "2AM Dostoevsky, mystery drawings, handwritten notes. You accidentally stumbled into a short story."),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Niche {
    
    /// 生成指定范围的随机整数
    static func nextInt_Niche(min_niche: Int, range_niche: Int) -> Int {
        return Int.random(in: min_niche..<(min_niche + range_niche))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Niche<T>(from list_niche: [T], count_niche: Int) -> [T] {
        guard !list_niche.isEmpty else { return [] }
        guard list_niche.count > count_niche else { return list_niche }
        
        var selected_niche: [T] = []
        var indices_niche: Set<Int> = []
        
        while selected_niche.count < count_niche && indices_niche.count < list_niche.count {
            let index_niche = Int.random(in: 0..<list_niche.count)
            if !indices_niche.contains(index_niche) {
                indices_niche.insert(index_niche)
                selected_niche.append(list_niche[index_niche])
            }
        }
        
        return selected_niche
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Niche {
    
    private weak var dataLocal_Niche: LocalData_Niche?
    
    init(dataLocal_niche: LocalData_Niche) {
        self.dataLocal_Niche = dataLocal_niche
    }
    
    /// 初始化生成用户数据
    func initUsers_Niche() {
        guard let dataLocal_niche = dataLocal_Niche else { return }
        dataLocal_niche.userList_Niche.removeAll()
        
        for (index_niche, userInfo_niche) in DataSource_Niche.usersInfo_Niche.enumerated() {
            let (username_niche, introduce_niche, userHead_niche, userAlbum_niche) = userInfo_niche
            
            let user_niche = PrewUserModel_Niche()
            user_niche.userId_Niche = index_niche + DataConfig_Niche.userIdStart_Niche
            user_niche.userName_Niche = username_niche
            user_niche.userIntroduce_Niche = introduce_niche
            user_niche.userHead_Niche = userHead_niche
            user_niche.userMedia_Niche = [userAlbum_niche]
            user_niche.userLike_Niche = []
            user_niche.userFollow_Niche = 15 + Int.random(in: 1...50)
            user_niche.userFans_Niche = 20 + Int.random(in: 1...50)
            
            dataLocal_niche.userList_Niche.append(user_niche)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Niche() {
        guard let dataLocal_niche = dataLocal_Niche else { return }
        dataLocal_niche.titleList_Niche.removeAll()
        
        for (index_niche, postInfo_niche) in DataSource_Niche.postsInfo_Niche.enumerated() {
            let (title_niche, content_niche, media_niche) = postInfo_niche
            
            // 循环分配作者
            let authorIndex_niche = index_niche % dataLocal_niche.userList_Niche.count
            guard authorIndex_niche < dataLocal_niche.userList_Niche.count else { continue }
            let author_niche = dataLocal_niche.userList_Niche[authorIndex_niche]
            
            // 生成评论
            let comments_niche = generateComments_Niche(
                postIndex_niche: index_niche,
                postAuthorUserId_niche: author_niche.userId_Niche ?? 0
            )
            
            // 创建帖子
            let post_niche = TitleModel_Niche(
                titleId_Niche: index_niche + DataConfig_Niche.postIdStart_Niche,
                titleUserId_Niche: author_niche.userId_Niche ?? 0,
                titleUserName_Niche: author_niche.userName_Niche ?? "",
                titleMeidas_Niche: [media_niche],
                title_Niche: title_niche,
                titleContent_Niche: content_niche,
                reviews_Niche: comments_niche,
                likes_Niche: RandomUtil_Niche.nextInt_Niche(min_niche: 10, range_niche: 150)
            )
            
            dataLocal_niche.titleList_Niche.append(post_niche)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Niche(postIndex_niche: Int, postAuthorUserId_niche: Int) -> [Comment_Niche] {
        guard let dataLocal_niche = dataLocal_Niche else { return [] }
        
        let availableUsers_niche = dataLocal_niche.getAvailableCommenters_Niche(postAuthorUserId_niche: postAuthorUserId_niche)
        guard availableUsers_niche.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_niche = availableUsers_niche[postIndex_niche % availableUsers_niche.count]
        let commenter2_niche = availableUsers_niche[(postIndex_niche + 1) % availableUsers_niche.count]
        
        // 获取评论内容
        let commentIndex_niche = postIndex_niche % DataSource_Niche.comments_Niche.count
        let (comment1_niche, comment2_niche) = DataSource_Niche.comments_Niche[commentIndex_niche]
        
        return [
            Comment_Niche(
                commentId_Niche: postIndex_niche * 2 + 1,
                commentUserId_Niche: commenter1_niche.userId_Niche ?? 0,
                commentUserName_Niche: commenter1_niche.userName_Niche ?? "",
                commentContent_Niche: comment1_niche
            ),
            Comment_Niche(
                commentId_Niche: postIndex_niche * 2 + 2,
                commentUserId_Niche: commenter2_niche.userId_Niche ?? 0,
                commentUserName_Niche: commenter2_niche.userName_Niche ?? "",
                commentContent_Niche: comment2_niche
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Niche() {
        guard let dataLocal_niche = dataLocal_Niche else { return }
        
        for i_niche in 0..<dataLocal_niche.userList_Niche.count {
            let user_niche = dataLocal_niche.userList_Niche[i_niche]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_niche = dataLocal_niche.getPostsExcludingUser_Niche(
                userId_niche: user_niche.userId_Niche ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_niche = RandomUtil_Niche.selectRandomItems_Niche(
                from: availablePosts_niche,
                count_niche: DataConfig_Niche.likePostCount_Niche
            )
            
            dataLocal_niche.userList_Niche[i_niche].userLike_Niche = likePosts_niche
        }
    }
}
