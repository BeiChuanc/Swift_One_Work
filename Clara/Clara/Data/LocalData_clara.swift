import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Clara {
    /// ID起始值
    static let userIdStart_Clara = 10
    static let postIdStart_Clara = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Clara = 2
}

/// 本地数据管理类
class LocalData_Clara {
    
    /// 单例
    static let shared_Clara = LocalData_Clara()
    
    /// 用户列表
    var userList_Clara: [PrewUserModel_Clara] = []
    
    /// 帖子列表
    var titleList_Clara: [TitleModel_Clara] = []
    
    /// 数据生成器
    private lazy var generator_Clara: DataGenerator_Clara = {
        return DataGenerator_Clara(dataLocal_clara: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Clara() {
        generator_Clara.initUsers_Clara()
        generator_Clara.initPosts_Clara()
        generator_Clara.setUserLikes_Clara()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Clara(userId_clara: Int) -> [TitleModel_Clara] {
        return titleList_Clara.filter { $0.titleUserId_Clara != userId_clara }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Clara(postAuthorUserId_clara: Int) -> [PrewUserModel_Clara] {
        return userList_Clara.filter { $0.userId_Clara != postAuthorUserId_clara }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Clara {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Clara: [(String, String, String, String)] = [
        ("BlushBloom", "Soft pastel outfits, light layers, and bright spring mornings", "head1", "head1"),
        ("SkyPetal", "Sharing airy color palettes and easy everyday spring styling", "head2", "head2"),
        ("MintMuse", "Loves fresh greens, denim mixes, and clean accessory details", "head3", "head3"),
        ("LavenderEdit", "Collecting romantic outfit ideas for calm and polished spring days", "head4", "head4"),
        ("ApricotGlow", "Into warm neutrals, floral accents, and gentle seasonal moodboards", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Clara: [(String, String, String)] = [
        ("Rose Morning Layers", "Built this look around a rose knit and soft cream base so the whole outfit feels warm but still airy. The goal was to keep the silhouette neat while letting the color story stay gentle and bright for a cool spring morning.", "title1"),
        ("City Bloom Contrast", "I like pairing vivid pink with calm neutrals because it makes the outfit feel playful without becoming too loud. The bag and shoes keep the balance, while the light layers make it easy to move from sun to shade.", "title2"),
        ("Weekend Denim Light", "This denim mix works best when the top stays clean and the accessories stay small. I kept the palette fresh with pale blue and white so the whole outfit feels casual, polished, and easy for a long spring afternoon.", "title3"),
        ("Soft Lilac Edit", "Lavender tones always make an outfit feel more romantic, especially when the textures stay light. I used simple jewelry and a smooth hairstyle so the color could be the main focus without competing details.", "title4"),
        ("Fresh Green Balance", "Green can feel surprisingly soft in spring when it is paired with white and warm beige. I wanted this look to feel energizing but still approachable, so the shape stays relaxed and the accents stay minimal.", "title5"),
        ("Sunny Cafe Look", "This outfit was made for bright windows, iced coffee, and a full day outside. A warm cardigan over a fitted base keeps the styling flexible, and the peach accents help everything feel a little more cheerful.", "title6"),
        ("Petal Street Mood", "Sometimes one statement color is enough to carry the whole look. Here I kept the base simple and let the pink outer layer bring movement, which makes the photo feel lively while the outfit still looks wearable in daily life.", "title7"),
        ("Blue Sky Pairing", "I wanted a cooler spring palette for this one, so I mixed powder blue with soft gray and white. The result feels clean, calm, and slightly elevated, especially with sneakers that keep the outfit from feeling too formal.", "title8"),
        ("Golden Hour Floral", "A tiny floral detail can shift the whole mood of an outfit. I kept everything else understated so the print could feel elegant instead of busy, and the warm light made the pink and apricot tones blend beautifully.", "title9"),
        ("Quiet Garden Fit", "This is the kind of outfit I reach for when I want to feel comfortable and put together at the same time. Light fabric, gentle colors, and a simple bag make it easy to wear while still feeling thoughtfully styled.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Clara: [(String, String)] = [
        ("The rose and cream palette feels so gentle. I would totally wear this for a spring brunch.", "Love how the layers stay soft without making the look feel heavy."),
        ("That pink really pops in the best way. The neutral pieces keep everything balanced.", "The bag choice is perfect here. It adds color without taking over the whole outfit."),
        ("This denim styling feels clean and effortless. Such an easy reference for everyday wear.", "The light blue tone makes the whole look feel extra fresh for spring."),
        ("Lavender always looks elegant when the styling stays minimal. This feels very polished.", "The simple accessories were the right call. They let the color do all the work."),
        ("Green and beige are such an underrated spring pair. This feels bright but still calm.", "I like how relaxed the silhouette is. It makes the color story even easier to wear."),
        ("This really does feel like a cafe day outfit. Soft, warm, and very photogenic.", "The cardigan color is beautiful. It gives the whole look a cheerful spring mood."),
        ("That outer layer totally carries the photo. Strong focal point without feeling too much.", "The clean base underneath makes the pink stand out even better."),
        ("Powder blue with gray is such a smart combo. It feels cool and refined.", "These sneakers keep the outfit grounded. The whole styling feels easy to copy."),
        ("The floral detail is subtle in the best way. Very pretty and not overwhelming at all.", "Golden light plus apricot tones is always a win. This one feels especially soft."),
        ("This is such a wearable garden look. Comfortable, neat, and still very intentional.", "The simple bag and light fabric make the whole outfit feel calm and complete."),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Clara {
    
    /// 生成指定范围的随机整数
    static func nextInt_Clara(min_clara: Int, range_clara: Int) -> Int {
        return Int.random(in: min_clara..<(min_clara + range_clara))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Clara<T>(from list_clara: [T], count_clara: Int) -> [T] {
        guard !list_clara.isEmpty else { return [] }
        guard list_clara.count > count_clara else { return list_clara }
        
        var selected_clara: [T] = []
        var indices_clara: Set<Int> = []
        
        while selected_clara.count < count_clara && indices_clara.count < list_clara.count {
            let index_clara = Int.random(in: 0..<list_clara.count)
            if !indices_clara.contains(index_clara) {
                indices_clara.insert(index_clara)
                selected_clara.append(list_clara[index_clara])
            }
        }
        
        return selected_clara
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Clara {
    
    private weak var dataLocal_Clara: LocalData_Clara?
    
    init(dataLocal_clara: LocalData_Clara) {
        self.dataLocal_Clara = dataLocal_clara
    }
    
    /// 初始化生成用户数据
    func initUsers_Clara() {
        guard let dataLocal_clara = dataLocal_Clara else { return }
        dataLocal_clara.userList_Clara.removeAll()
        
        for (index_clara, userInfo_clara) in DataSource_Clara.usersInfo_Clara.enumerated() {
            let (username_clara, introduce_clara, userHead_clara, userAlbum_clara) = userInfo_clara
            
            let user_clara = PrewUserModel_Clara()
            user_clara.userId_Clara = index_clara + DataConfig_Clara.userIdStart_Clara
            user_clara.userName_Clara = username_clara
            user_clara.userIntroduce_Clara = introduce_clara
            user_clara.userHead_Clara = userHead_clara
            user_clara.userMedia_Clara = [userAlbum_clara]
            user_clara.userLike_Clara = []
            user_clara.userFollow_Clara = 15 + Int.random(in: 1...50)
            user_clara.userFans_Clara = 20 + Int.random(in: 1...50)
            
            dataLocal_clara.userList_Clara.append(user_clara)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Clara() {
        guard let dataLocal_clara = dataLocal_Clara else { return }
        dataLocal_clara.titleList_Clara.removeAll()
        
        for (index_clara, postInfo_clara) in DataSource_Clara.postsInfo_Clara.enumerated() {
            let (title_clara, content_clara, media_clara) = postInfo_clara
            
            // 循环分配作者
            let authorIndex_clara = index_clara % dataLocal_clara.userList_Clara.count
            guard authorIndex_clara < dataLocal_clara.userList_Clara.count else { continue }
            let author_clara = dataLocal_clara.userList_Clara[authorIndex_clara]
            
            // 生成评论
            let comments_clara = generateComments_Clara(
                postIndex_clara: index_clara,
                postAuthorUserId_clara: author_clara.userId_Clara ?? 0
            )
            
            // 创建帖子
            let post_clara = TitleModel_Clara(
                titleId_Clara: index_clara + DataConfig_Clara.postIdStart_Clara,
                titleUserId_Clara: author_clara.userId_Clara ?? 0,
                titleUserName_Clara: author_clara.userName_Clara ?? "",
                titleMeidas_Clara: [media_clara],
                title_Clara: title_clara,
                titleContent_Clara: content_clara,
                reviews_Clara: comments_clara,
                likes_Clara: RandomUtil_Clara.nextInt_Clara(min_clara: 10, range_clara: 150)
            )
            
            dataLocal_clara.titleList_Clara.append(post_clara)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Clara(postIndex_clara: Int, postAuthorUserId_clara: Int) -> [Comment_Clara] {
        guard let dataLocal_clara = dataLocal_Clara else { return [] }
        
        let availableUsers_clara = dataLocal_clara.getAvailableCommenters_Clara(postAuthorUserId_clara: postAuthorUserId_clara)
        guard availableUsers_clara.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_clara = availableUsers_clara[postIndex_clara % availableUsers_clara.count]
        let commenter2_clara = availableUsers_clara[(postIndex_clara + 1) % availableUsers_clara.count]
        
        // 获取评论内容
        let commentIndex_clara = postIndex_clara % DataSource_Clara.comments_Clara.count
        let (comment1_clara, comment2_clara) = DataSource_Clara.comments_Clara[commentIndex_clara]
        
        return [
            Comment_Clara(
                commentId_Clara: postIndex_clara * 2 + 1,
                commentUserId_Clara: commenter1_clara.userId_Clara ?? 0,
                commentUserName_Clara: commenter1_clara.userName_Clara ?? "",
                commentContent_Clara: comment1_clara
            ),
            Comment_Clara(
                commentId_Clara: postIndex_clara * 2 + 2,
                commentUserId_Clara: commenter2_clara.userId_Clara ?? 0,
                commentUserName_Clara: commenter2_clara.userName_Clara ?? "",
                commentContent_Clara: comment2_clara
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Clara() {
        guard let dataLocal_clara = dataLocal_Clara else { return }
        
        for i_clara in 0..<dataLocal_clara.userList_Clara.count {
            let user_clara = dataLocal_clara.userList_Clara[i_clara]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_clara = dataLocal_clara.getPostsExcludingUser_Clara(
                userId_clara: user_clara.userId_Clara ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_clara = RandomUtil_Clara.selectRandomItems_Clara(
                from: availablePosts_clara,
                count_clara: DataConfig_Clara.likePostCount_Clara
            )
            
            dataLocal_clara.userList_Clara[i_clara].userLike_Clara = likePosts_clara
        }
    }
}
