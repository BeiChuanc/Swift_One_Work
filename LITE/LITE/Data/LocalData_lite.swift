import Foundation
import Combine

// MARK: - 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_lite {
    /// ID起始值
    static let userIdStart_lite = 10
    static let postIdStart_lite = 20
    
    /// 喜欢帖子数量
    static let likePostCount_lite = 2
}

/// 本地数据管理类
class LocalData_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = LocalData_lite()
    
    /// 用户列表
    @Published var userList_lite: [PrewUserModel_lite] = []
    
    /// 帖子列表
    @Published var titleList_lite: [TitleModel_lite] = []
    
    /// 穿搭组合列表
    @Published var outfitComboList_lite: [OutfitCombo_lite] = []
    
    /// 单品列表
    @Published var outfitItemList_lite: [OutfitItem_lite] = []
    
    /// 挑战列表
    @Published var challengeList_lite: [OutfitChallenge_lite] = []
    
    /// 时光胶囊列表
    @Published var capsuleList_lite: [OutfitCapsule_lite] = []
    
    /// 数据生成器
    private lazy var generator_lite: DataGenerator_lite = {
        return DataGenerator_lite(dataLocal_lite: self)
    }()
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    /// 初始化所有数据
    func initData_lite() {
        generator_lite.initUsers_lite()
        generator_lite.initPosts_lite()
        generator_lite.setUserLikes_lite()
        generator_lite.initOutfitItems_lite()
        generator_lite.initOutfitCombos_lite()
        generator_lite.initChallenges_lite()
        generator_lite.initCapsules_lite()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_lite(userId_lite: Int) -> [TitleModel_lite] {
        return titleList_lite.filter { $0.titleUserId_lite != userId_lite }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_lite(postAuthorUserId_lite: Int) -> [PrewUserModel_lite] {
        return userList_lite.filter { $0.userId_lite != postAuthorUserId_lite }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_lite {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_lite: [(String, String, String, String)] = [
        ("StyleVibe", "Minimalist enthusiast | Less is more 🤍", "head1", "head1"),
        ("UrbanChic", "Street fashion lover | Mix & match expert 👟", "head2", "head2"),
        ("VintageVibes", "Retro style collector | Thrift shop hunter 🕰️", "head3", "head3"),
        ("CasualElegance", "Effortless style | Comfort meets fashion ✨", "head4", "head4"),
        ("TrendSetter", "Fashion forward | Creating my own rules 🎨", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_lite: [(String, String, String)] = [
        ("Perfect White Tee Day", "There's something magical about a classic white tee paired with your favorite jeans. Simple, timeless, and effortlessly cool. This is my go-to look when I want to feel comfortable yet put together. What's your essential wardrobe piece?", "title1"),
        ("Minimalist Aesthetic", "Less is more has become my style mantra. Clean lines, neutral tones, and quality basics - that's all you need. This minimalist outfit makes me feel confident and grounded. Sometimes simplicity speaks louder than anything else.", "title2"),
        ("Street Style Vibes", "Mixing high and low, vintage and new - that's what street fashion is all about! Today's look combines thrifted finds with modern pieces. Fashion should be fun, experimental, and uniquely YOU. Who else loves creating unexpected outfit combos?", "title3"),
        ("Vintage Finds", "Scored these amazing vintage pieces at the thrift store yesterday! There's something special about wearing clothes with history and character. Each piece tells a story, and now they're part of mine. Sustainable fashion at its finest!", "title4"),
        ("Cozy Weekend Look", "Weekend mood: oversized sweater, comfy pants, and zero plans. Sometimes the best outfit is the one that makes you feel like you're wrapped in a warm hug. Who else lives for cozy weekend vibes?", "title5"),
        ("Power Dressing", "Dressed for success today! When you look good, you feel good, and when you feel good, you can conquer anything. This smart casual outfit strikes the perfect balance between professional and approachable. Ready to take on the day!", "title6"),
        ("Fashion Evolution", "Looking back at my style journey - from following trends to creating my own. Every outfit mistake taught me something valuable. Now I dress for myself, not for anyone else. That's when fashion becomes truly fun and liberating.", "title7"),
        ("Mixing Textures", "Today's experiment: mixing different textures and fabrics. Denim with knit, leather with cotton - the contrast creates such an interesting visual! Fashion is all about playing with elements and finding unexpected harmony. What texture combo do you love?", "title8"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_lite: [(String, String)] = [
        ("This outfit is giving major goals! The styling is on point 🔥", "Love how you made something so simple look so chic! Need those jeans in my life"),
        ("Minimalist perfection! Your aesthetic is so clean and cohesive ✨", "This is exactly the vibe I'm trying to achieve! Less really is more"),
        ("Street style at its finest! That mix is absolutely fire 👟", "You always nail the high-low mix! Where did you get that jacket?"),
        ("Vintage finds are the BEST! Sustainable and stylish 💚", "Thrifting is an art form and you're a master! Those pieces are stunning"),
        ("Cozy goals right here! Need this entire outfit for my weekends 🤍", "This is the level of comfort I aspire to achieve every day!"),
        ("You're absolutely glowing in this! Power dressing done right 💼", "This look screams confidence! You're inspiring me to level up my work wardrobe"),
        ("Love seeing your style evolution! Growth looks good on you 🌱", "This is so relatable! Fashion is truly about finding yourself"),
        ("The texture mixing is genius! Never thought of combining those 🤔", "This gives me so many ideas! Going to try mixing textures this week"),
    ]
    
    /// 单品信息列表 (名称, 类型, 图标, 颜色, 品牌)
    static let itemsInfo_lite: [(String, OutfitItemType_lite, String, String, String)] = [
        ("Classic White Tee", .top_lite, "tshirt.fill", "FFFFFF", "Urban Basics"),
        ("Denim Jacket", .top_lite, "figure.walk", "4A90E2", "Denim Co"),
        ("Black Sweater", .top_lite, "latch.2.case.fill", "000000", "Cozy Knits"),
        ("Striped Shirt", .top_lite, "line.3.horizontal", "E8F4F8", "Classic Line"),
        ("Hoodie", .top_lite, "figure.stand", "808080", "Street Wear"),
        
        ("Blue Jeans", .bottom_lite, "figure.walk", "2E5C8A", "Denim Co"),
        ("Black Pants", .bottom_lite, "figure.walk", "1A1A1A", "Urban Basics"),
        ("Cargo Pants", .bottom_lite, "square.stack.3d.up.fill", "4A5F3A", "Street Wear"),
        ("Khaki Shorts", .bottom_lite, "rectangle.fill", "C4A57B", "Summer Vibes"),
        ("Plaid Skirt", .bottom_lite, "square.grid.2x2.fill", "B8860B", "Vintage Style"),
        
        ("White Sneakers", .shoes_lite, "shoeprints.fill", "F8F8F8", "Comfy Steps"),
        ("Black Boots", .shoes_lite, "figure.walk", "2B2B2B", "Urban Boots"),
        ("Canvas Shoes", .shoes_lite, "hare.fill", "E8D7C3", "Casual Walk"),
        ("Running Shoes", .shoes_lite, "figure.run", "FF6B6B", "Sport Pro"),
        
        ("Backpack", .accessory_lite, "backpack.fill", "3A3A3A", "Travel Gear"),
        ("Cap", .accessory_lite, "baseball.diamond.bases", "1E3A8A", "Street Style"),
        ("Sunglasses", .accessory_lite, "sunglasses.fill", "000000", "Cool Shades"),
        ("Watch", .accessory_lite, "applewatch", "C0C0C0", "Time Master"),
    ]
    
    /// 穿搭组合信息列表 (标题, 描述, 风格, 场景, 单品ID列表)
    static let combosInfo_lite: [(String, String, OutfitStyle_lite, OutfitScene_lite, [Int])] = [
        ("Minimalist Daily", "Simple and comfortable everyday look", .casual_lite, .daily_lite, [1, 6, 11]),
        ("Smart Casual Work", "Professional yet relaxed office outfit", .formal_lite, .work_lite, [4, 7, 12]),
        ("Street Style Cool", "Urban trendsetter vibe", .street_lite, .daily_lite, [2, 8, 13]),
        ("Cozy Weekend", "Perfect for relaxing days", .casual_lite, .daily_lite, [3, 6, 11]),
        ("Date Night Chic", "Stylish and confident look", .vintage_lite, .date_lite, [4, 10, 12]),
        ("Active Sporty", "Ready for any activity", .sporty_lite, .sport_lite, [5, 9, 14]),
    ]
    
    /// 挑战信息列表 (标题, 描述, 基础单品ID, 创建者ID, 创建者名称, 是否官方)
    static let challengesInfo_lite: [(String, String, Int, Int, String, Bool)] = [
        ("White Tee Style", "Share your creative ways to style a classic white tee", 1, 0, "Official", true),
        ("Denim Remix", "Create unique looks using denim pieces", 2, 10, "TechExplorer", false),
        ("All Black Everything", "Master the art of monochrome dressing", 3, 11, "CreativeMinds", false),
    ]
    
    /// 预制用户的时空胶囊列表 (胶囊ID, 用户ID, 穿搭组合索引, 封存心得, 封存日期天数偏移, 解锁日期天数偏移, 是否已解锁, 解锁心得)
    static let capsulesInfo_lite: [(Int, Int, Int, String, Int, Int, Bool, String?)] = [
        // 已解锁的时光胶囊
        (1, 10, 1, "Starting my new job today with this smart casual look. Nervous but excited about this new chapter. Hope I'll look back and be proud of how far I've come.", -180, -1, true, "Looking back after 6 months - I've grown so much! This outfit reminds me of that nervous first day. Now I'm confident and thriving in my role."),
        
        (2, 11, 5, "Preparing for my first marathon with this sporty outfit. Training has been tough but I'm determined to cross that finish line. Let's see if future me did it!", -120, -10, true, "I did it! Completed the marathon in 4 hours 23 minutes. This outfit holds so many memories of early morning runs and pushing through pain. So proud!"),
        
        (3, 12, 3, "Cozy weekend at home, taking time to slow down and reflect. Sometimes the best outfit is the comfiest one. I wonder if I'll still cherish these quiet moments.", -90, -5, true, "Life got busier but I treasure these peaceful moments even more now. This cozy outfit reminds me to always make time for myself."),
        
        // 未解锁的时光胶囊 - 即将解锁
        (4, 13, 2, "Just moved to a new city! Everything feels unfamiliar but exciting. This street style outfit makes me feel confident exploring unknown streets. Can't wait to see what adventures await.", -30, 7, false, nil),
        
        (5, 14, 4, "Going on a first date tonight wearing my favorite vintage look. Butterflies in my stomach but feeling stylish and ready. Future me - did it work out? Are we still together?", -45, 15, false, nil),
        
        // 未解锁的时光胶囊 - 较远的未来
        (6, 10, 6, "Trying out this minimalist style for the first time. Stepping out of my comfort zone fashion-wise. Will this become my signature look or just a phase?", -60, 60, false, nil),
        
        (7, 11, 1, "Birthday outfit for turning 25! Quarter-life moment feeling both accomplished and uncertain. This casual look reflects where I am - comfortable but ready for anything.", -100, 100, false, nil),
        
        (8, 12, 5, "Setting a new fitness goal - want to run a half marathon by next year. This sporty outfit marks the beginning of my training journey. Let's see if I commit to it!", -40, 180, false, nil),
        
        // 未解锁的时光胶囊 - 一年后
        (9, 13, 4, "Starting a passion project I've been dreaming about. This confident outfit reflects how I feel today - ready to take risks and chase my dreams. Will it succeed?", -20, 365, false, nil),
        
        (10, 14, 2, "Decided to embrace my unique style instead of following trends. This street look is totally ME. Future self - I hope you're still staying true to yourself!", -50, 365, false, nil),
    ]

    /// 灵感评论列表 (评论内容, 评论用户ID, 天数偏移)
    static let inspirationCommentsInfo_lite: [(String, Int, Int)] = [
        // 预制用户发布的灵感评论 - 每个用户一条
        ("A white tee is my minimalist essential! I pair it with clean lines and neutral tones for that effortless, timeless look. Less is truly more when it comes to styling basics.", 10, -5),
        ("Street style magic happens with a white tee! Mix it with vintage denim, chunky sneakers, and layered accessories. It's all about creating that urban edge while staying comfortable.", 11, -4),
        ("Found the perfect vintage white tee at a thrift store! I style it with high-waisted retro jeans and classic accessories. Every piece tells a story, and this combo is pure nostalgia.", 12, -6),
        ("White tee + tailored blazer + smart trousers = my casual elegance formula! It's the perfect balance between comfort and sophistication for any occasion.", 13, -3),
        ("Fashion rule breaker here! I layer my white tee under bold patterns, mix unexpected textures, and add statement pieces. A classic tee is the perfect canvas for creativity.", 14, -2),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
private struct RandomUtil_lite {
    
    /// 生成指定范围的随机整数
    static func nextInt_lite(min_lite: Int, range_lite: Int) -> Int {
        return Int.random(in: min_lite..<(min_lite + range_lite))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_lite<T>(from list_lite: [T], count_lite: Int) -> [T] {
        guard !list_lite.isEmpty else { return [] }
        guard list_lite.count > count_lite else { return list_lite }
        
        var selected_lite: [T] = []
        var indices_lite: Set<Int> = []
        
        while selected_lite.count < count_lite && indices_lite.count < list_lite.count {
            let index_lite = Int.random(in: 0..<list_lite.count)
            if !indices_lite.contains(index_lite) {
                indices_lite.insert(index_lite)
                selected_lite.append(list_lite[index_lite])
            }
        }
        
        return selected_lite
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_lite {
    
    /// 弱引用本地数据管理器，避免循环引用
    private weak var dataLocal_lite: LocalData_lite?
    
    /// 初始化方法
    init(dataLocal_lite: LocalData_lite) {
        self.dataLocal_lite = dataLocal_lite
    }
    
    /// 初始化生成用户数据
    func initUsers_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.userList_lite.removeAll()
        
        for (index_lite, userInfo_lite) in DataSource_lite.usersInfo_lite.enumerated() {
            let (username_lite, introduce_lite, userHead_lite, userAlbum_lite) = userInfo_lite
            
            let user_lite = PrewUserModel_lite()
            user_lite.userId_lite = index_lite + DataConfig_lite.userIdStart_lite
            user_lite.userName_lite = username_lite
            user_lite.userIntroduce_lite = introduce_lite
            user_lite.userHead_lite = userHead_lite
            user_lite.userMedia_lite = [userAlbum_lite]
            user_lite.userLike_lite = []
            user_lite.userFollow_lite = 15 + Int.random(in: 1...50)
            user_lite.userFans_lite = 20 + Int.random(in: 1...50)
            
            dataLocal_lite.userList_lite.append(user_lite)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.titleList_lite.removeAll()
        
        for (index_lite, postInfo_lite) in DataSource_lite.postsInfo_lite.enumerated() {
            let (title_lite, content_lite, media_lite) = postInfo_lite
            
            // 循环分配作者
            let authorIndex_lite = index_lite % dataLocal_lite.userList_lite.count
            guard authorIndex_lite < dataLocal_lite.userList_lite.count else { continue }
            let author_lite = dataLocal_lite.userList_lite[authorIndex_lite]
            
            // 生成评论
            let comments_lite = generateComments_lite(
                postIndex_lite: index_lite,
                postAuthorUserId_lite: author_lite.userId_lite ?? 0
            )
            
            // 创建帖子
            let post_lite = TitleModel_lite(
                titleId_lite: index_lite + DataConfig_lite.postIdStart_lite,
                titleUserId_lite: author_lite.userId_lite ?? 0,
                titleUserName_lite: author_lite.userName_lite ?? "",
                titleMeidas_lite: [media_lite],
                title_lite: title_lite,
                titleContent_lite: content_lite,
                reviews_lite: comments_lite,
                likes_lite: RandomUtil_lite.nextInt_lite(min_lite: 10, range_lite: 150)
            )
            
            dataLocal_lite.titleList_lite.append(post_lite)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_lite(postIndex_lite: Int, postAuthorUserId_lite: Int) -> [Comment_lite] {
        guard let dataLocal_lite = dataLocal_lite else { return [] }
        
        let availableUsers_lite = dataLocal_lite.getAvailableCommenters_lite(postAuthorUserId_lite: postAuthorUserId_lite)
        guard availableUsers_lite.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_lite = availableUsers_lite[postIndex_lite % availableUsers_lite.count]
        let commenter2_lite = availableUsers_lite[(postIndex_lite + 1) % availableUsers_lite.count]
        
        // 获取评论内容
        let commentIndex_lite = postIndex_lite % DataSource_lite.comments_lite.count
        let (comment1_lite, comment2_lite) = DataSource_lite.comments_lite[commentIndex_lite]
        
        return [
            Comment_lite(
                commentId_lite: postIndex_lite * 2 + 1,
                commentUserId_lite: commenter1_lite.userId_lite ?? 0,
                commentUserName_lite: commenter1_lite.userName_lite ?? "",
                commentContent_lite: comment1_lite
            ),
            Comment_lite(
                commentId_lite: postIndex_lite * 2 + 2,
                commentUserId_lite: commenter2_lite.userId_lite ?? 0,
                commentUserName_lite: commenter2_lite.userName_lite ?? "",
                commentContent_lite: comment2_lite
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        
        for i_lite in 0..<dataLocal_lite.userList_lite.count {
            let user_lite = dataLocal_lite.userList_lite[i_lite]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_lite = dataLocal_lite.getPostsExcludingUser_lite(
                userId_lite: user_lite.userId_lite ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_lite = RandomUtil_lite.selectRandomItems_lite(
                from: availablePosts_lite,
                count_lite: DataConfig_lite.likePostCount_lite
            )
            
            dataLocal_lite.userList_lite[i_lite].userLike_lite = likePosts_lite
        }
    }
    
    /// 初始化生成穿搭单品数据
    func initOutfitItems_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.outfitItemList_lite.removeAll()
        
        for (index_lite, itemInfo_lite) in DataSource_lite.itemsInfo_lite.enumerated() {
            let (name_lite, type_lite, image_lite, color_lite, brand_lite) = itemInfo_lite
            
            let item_lite = OutfitItem_lite(
                itemId_lite: index_lite + 1,
                itemName_lite: name_lite,
                itemType_lite: type_lite,
                itemImage_lite: image_lite,
                itemColor_lite: color_lite,
                itemBrand_lite: brand_lite
            )
            
            dataLocal_lite.outfitItemList_lite.append(item_lite)
        }
    }
    
    /// 初始化生成穿搭组合数据
    func initOutfitCombos_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.outfitComboList_lite.removeAll()
        
        for (index_lite, comboInfo_lite) in DataSource_lite.combosInfo_lite.enumerated() {
            let (title_lite, description_lite, style_lite, scene_lite, itemIds_lite) = comboInfo_lite
            
            // 根据ID获取单品
            let items_lite = itemIds_lite.compactMap { itemId_lite in
                dataLocal_lite.outfitItemList_lite.first { $0.itemId_lite == itemId_lite }
            }
            
            // 前3个穿搭标记为当日穿搭，模拟用户历史记录
            let isDailyOutfit_lite = index_lite < 3
            
            let combo_lite = OutfitCombo_lite(
                comboId_lite: index_lite + 1,
                comboTitle_lite: title_lite,
                comboDescription_lite: description_lite,
                items_lite: items_lite,
                style_lite: style_lite,
                scene_lite: scene_lite,
                createDate_lite: Date().addingTimeInterval(TimeInterval(-index_lite * 86400)),
                isFavorited_lite: index_lite < 2, // 前2个标记为已收藏
                isDailyOutfit_lite: isDailyOutfit_lite,
                likes_lite: RandomUtil_lite.nextInt_lite(min_lite: 10, range_lite: 200)
            )
            
            dataLocal_lite.outfitComboList_lite.append(combo_lite)
        }
    }
    
    /// 初始化生成挑战数据
    func initChallenges_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.challengeList_lite.removeAll()
        
        for (index_lite, challengeInfo_lite) in DataSource_lite.challengesInfo_lite.enumerated() {
            let (title_lite, description_lite, baseItemId_lite, creatorId_lite, creatorName_lite, isOfficial_lite) = challengeInfo_lite
            
            // 获取基础单品
            guard let baseItem_lite = dataLocal_lite.outfitItemList_lite.first(where: { $0.itemId_lite == baseItemId_lite }) else {
                continue
            }
            
            // 为挑战生成灵感评论（使用 OutfitCombo 作为承载）
            var submissions_lite: [OutfitCombo_lite] = []
            let challengeId_lite = index_lite + 1
            
            // 为每个挑战添加预制的灵感评论
            for (commentIndex_lite, commentInfo_lite) in DataSource_lite.inspirationCommentsInfo_lite.enumerated() {
                let (content_lite, userId_lite, daysOffset_lite) = commentInfo_lite
                
                // 创建虚拟的穿搭组合来承载灵感评论
                let inspirationCombo_lite = OutfitCombo_lite(
                    comboId_lite: challengeId_lite * 1000 + commentIndex_lite,
                    comboTitle_lite: content_lite,
                    comboDescription_lite: "Inspiration comment",
                    items_lite: [baseItem_lite],
                    style_lite: .casual_lite,
                    scene_lite: .daily_lite,
                    createDate_lite: Date().addingTimeInterval(TimeInterval(daysOffset_lite * 86400)),
                    likes_lite: RandomUtil_lite.nextInt_lite(min_lite: 5, range_lite: 50),
                    userId_lite: userId_lite
                )
                
                submissions_lite.append(inspirationCombo_lite)
            }
            
            // 创建挑战
            let challenge_lite = OutfitChallenge_lite(
                challengeId_lite: challengeId_lite,
                challengeTitle_lite: title_lite,
                challengeDescription_lite: description_lite,
                baseItem_lite: baseItem_lite,
                creatorUserId_lite: creatorId_lite,
                creatorUserName_lite: creatorName_lite,
                submissions_lite: submissions_lite,
                createDate_lite: Date().addingTimeInterval(TimeInterval(-index_lite * 86400 * 7)),
                endDate_lite: Date().addingTimeInterval(TimeInterval((7 - index_lite) * 86400 * 7)),
                isOfficial_lite: isOfficial_lite,
                isActive_lite: true
            )
            
            dataLocal_lite.challengeList_lite.append(challenge_lite)
        }
    }
    
    /// 初始化生成时光胶囊数据
    func initCapsules_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.capsuleList_lite.removeAll()
        
        for capsuleInfo_lite in DataSource_lite.capsulesInfo_lite {
            let (id_lite, userId_lite, outfitIndex_lite, thoughtNote_lite, sealDaysOffset_lite, unlockDaysOffset_lite, isUnlocked_lite, unlockNote_lite) = capsuleInfo_lite
            
            // 获取对应的穿搭组合（索引从0开始，但数据从1开始，需要-1）
            let comboIndex_lite = outfitIndex_lite - 1
            guard comboIndex_lite >= 0 && comboIndex_lite < dataLocal_lite.outfitComboList_lite.count else {
                continue
            }
            let outfit_lite = dataLocal_lite.outfitComboList_lite[comboIndex_lite]
            
            // 计算封存日期和解锁日期
            let sealDate_lite = Date().addingTimeInterval(TimeInterval(sealDaysOffset_lite * 86400))
            let unlockDate_lite = Date().addingTimeInterval(TimeInterval(unlockDaysOffset_lite * 86400))
            
            // 创建时光胶囊
            let capsule_lite = OutfitCapsule_lite(
                capsuleId_lite: id_lite,
                userId_lite: userId_lite,
                outfit_lite: outfit_lite,
                thoughtNote_lite: thoughtNote_lite,
                sealDate_lite: sealDate_lite,
                unlockDate_lite: unlockDate_lite,
                isUnlocked_lite: isUnlocked_lite,
                unlockNote_lite: unlockNote_lite
            )
            
            dataLocal_lite.capsuleList_lite.append(capsule_lite)
        }
        
        // 按封存日期倒序排序（最新的在前面）
        dataLocal_lite.capsuleList_lite.sort { $0.sealDate_lite > $1.sealDate_lite }
    }
}
