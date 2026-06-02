import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Breeze {
    /// ID起始值
    static let userIdStart_Breeze = 10
    static let postIdStart_Breeze = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Breeze = 2
}

/// 本地数据管理类
class LocalData_Breeze {
    
    /// 单例
    static let shared_Breeze = LocalData_Breeze()
    
    /// 用户列表
    var userList_Breeze: [PrewUserModel_Breeze] = []
    
    /// 帖子列表
    var titleList_Breeze: [TitleModel_Breeze] = []
    
    /// 季节露营 Tips 列表（预制静态数据，按季节分组）
    lazy var seasonalTips_Breeze: [SeasonalTip_Breeze] = SeasonalTipsSource_Breeze.all_Breeze
    
    /// 数据生成器
    private lazy var generator_Breeze: DataGenerator_Breeze = {
        return DataGenerator_Breeze(dataLocal_breeze: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Breeze() {
        generator_Breeze.initUsers_Breeze()
        generator_Breeze.initPosts_Breeze()
        generator_Breeze.setUserLikes_Breeze()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Breeze(userId_breeze: Int) -> [TitleModel_Breeze] {
        return titleList_Breeze.filter { $0.titleUserId_Breeze != userId_breeze }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Breeze(postAuthorUserId_breeze: Int) -> [PrewUserModel_Breeze] {
        return userList_Breeze.filter { $0.userId_Breeze != postAuthorUserId_breeze }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Breeze {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Breeze: [(String, String, String, String)] = [
        ("MeadowWanderer", "Chasing sunrises across national parks", "head1", "head1"),
        ("PineTrailScout", "Trail maps, tents and fresh mountain air", "head2", "head2"),
        ("RiverbendCamper", "Weekend camper, lifelong nature lover", "head3", "head3"),
        ("SummitBreeze", "Where the breeze goes, I follow", "head4", "head4"),
        ("LakesideRambler", "Collecting quiet mornings by the lake", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体, 分类)
    static let postsInfo_Breeze: [(String, String, String, PostCategory_Breeze)] = [
        ("Tent Pitched at Dawn", "Set up camp just as the first light spilled over the ridge. The grass was cool with dew and the whole meadow was ours. There is no alarm clock quite like birdsong and a gentle breeze.", "title10", .camping_breeze),
        ("A Quiet Forest Trail", "Spent the morning wandering a soft pine trail. Every turn opened to taller trees and dappled sunlight. Sometimes the best plan is no plan at all, just walking and breathing.", "title8", .nature_breeze),
        ("Mountain Views Forever", "Hiked up to the lookout and the whole valley stretched out below. The ridgelines faded into a hazy blue. Worth every step of the climb to stand up here with the wind.", "title7", .hiking_breeze),
        ("Hiking the Long Loop", "Knocked out the full perimeter loop today. Boots a little muddy, heart very full. The park feels different on foot, slower and somehow bigger all at once.", "title4", .hiking_breeze),
        ("Under the Old Oak", "Found the perfect shade tree for a lazy afternoon. Spread the blanket, opened a book, and let the hours drift by. The park is the best reading room I know.", "title5", .nature_breeze),
        ("Golden Hour Picnic", "Late afternoon sun turned the whole field amber. We laid out snacks and watched the light go soft and warm. These slow golden hours are what camping is all about.", "title6", .photography_breeze),
        ("Stargazing by the Tent", "Zero light pollution out here, so the sky absolutely glowed. We counted shooting stars until we lost track. Falling asleep under that many stars never gets old.", "title3", .camping_breeze),
        ("Wildlife Watching", "Sat still by the clearing and waited. A family of deer stepped out at dusk, calm and unbothered. Patience really is the only gear you need for moments like this.", "title2", .nature_breeze),
        ("Packed and Ready", "Backpack loaded, map folded, water topped off. Half the joy of a trip is the morning you head out. New trail today, who knows what we will find.", "title9", .camping_breeze),
        ("Morning by the Lake", "Mist rising off still water and not another soul around. The lake was a perfect mirror for the trees. I sat with my coffee and just let the quiet do its thing.", "title1", .photography_breeze),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Breeze: [(String, String)] = [
        ("Dawn camp setups are the best, nothing beats that fresh meadow air", "Adding this spot to my list right now, looks so peaceful"),
        ("Pine trails are pure therapy. Love a walk with no destination", "That dappled sunlight through the trees is everything"),
        ("That view is unreal! Which lookout trail did you take?", "The climb is always worth it for ridgelines like these"),
        ("Muddy boots, full heart, that's the whole sport right there", "Loop trails really do show you the whole park, great call"),
        ("A good shade tree and a book sounds like a perfect day", "Stealing this idea for my next park visit"),
        ("Golden hour picnics hit different, the light is so warm", "Snacks plus sunset equals the ideal afternoon"),
        ("So jealous of those dark skies! Did you catch any meteors?", "Sleeping under the stars never gets old, so true"),
        ("Patience pays off, what a calm encounter with the deer", "Wildlife at dusk is magic, glad you kept still for it"),
        ("Nothing like a fully packed bag and an open trail", "The morning you head out is honestly the best part"),
        ("A misty lake mirror at sunrise, absolutely stunning", "Coffee by still water is my kind of morning"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Breeze {
    
    /// 生成指定范围的随机整数
    static func nextInt_Breeze(min_breeze: Int, range_breeze: Int) -> Int {
        return Int.random(in: min_breeze..<(min_breeze + range_breeze))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Breeze<T>(from list_breeze: [T], count_breeze: Int) -> [T] {
        guard !list_breeze.isEmpty else { return [] }
        guard list_breeze.count > count_breeze else { return list_breeze }
        
        var selected_breeze: [T] = []
        var indices_breeze: Set<Int> = []
        
        while selected_breeze.count < count_breeze && indices_breeze.count < list_breeze.count {
            let index_breeze = Int.random(in: 0..<list_breeze.count)
            if !indices_breeze.contains(index_breeze) {
                indices_breeze.insert(index_breeze)
                selected_breeze.append(list_breeze[index_breeze])
            }
        }
        
        return selected_breeze
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Breeze {
    
    private weak var dataLocal_Breeze: LocalData_Breeze?
    
    init(dataLocal_breeze: LocalData_Breeze) {
        self.dataLocal_Breeze = dataLocal_breeze
    }
    
    /// 初始化生成用户数据
    func initUsers_Breeze() {
        guard let dataLocal_breeze = dataLocal_Breeze else { return }
        dataLocal_breeze.userList_Breeze.removeAll()
        
        for (index_breeze, userInfo_breeze) in DataSource_Breeze.usersInfo_Breeze.enumerated() {
            let (username_breeze, introduce_breeze, userHead_breeze, userAlbum_breeze) = userInfo_breeze
            
            let user_breeze = PrewUserModel_Breeze()
            user_breeze.userId_Breeze = index_breeze + DataConfig_Breeze.userIdStart_Breeze
            user_breeze.userName_Breeze = username_breeze
            user_breeze.userIntroduce_Breeze = introduce_breeze
            user_breeze.userHead_Breeze = userHead_breeze
            user_breeze.userMedia_Breeze = [userAlbum_breeze]
            user_breeze.userLike_Breeze = []
            user_breeze.userFollow_Breeze = 15 + Int.random(in: 1...50)
            user_breeze.userFans_Breeze = 20 + Int.random(in: 1...50)
            
            dataLocal_breeze.userList_Breeze.append(user_breeze)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Breeze() {
        guard let dataLocal_breeze = dataLocal_Breeze else { return }
        dataLocal_breeze.titleList_Breeze.removeAll()
        
        for (index_breeze, postInfo_breeze) in DataSource_Breeze.postsInfo_Breeze.enumerated() {
            let (title_breeze, content_breeze, media_breeze, category_breeze) = postInfo_breeze
            
            // 循环分配作者
            let authorIndex_breeze = index_breeze % dataLocal_breeze.userList_Breeze.count
            guard authorIndex_breeze < dataLocal_breeze.userList_Breeze.count else { continue }
            let author_breeze = dataLocal_breeze.userList_Breeze[authorIndex_breeze]
            
            // 生成评论
            let comments_breeze = generateComments_Breeze(
                postIndex_breeze: index_breeze,
                postAuthorUserId_breeze: author_breeze.userId_Breeze ?? 0
            )
            
            // 创建帖子（附带分类信息）
            let post_breeze = TitleModel_Breeze(
                titleId_Breeze: index_breeze + DataConfig_Breeze.postIdStart_Breeze,
                titleUserId_Breeze: author_breeze.userId_Breeze ?? 0,
                titleUserName_Breeze: author_breeze.userName_Breeze ?? "",
                titleMeidas_Breeze: [media_breeze],
                title_Breeze: title_breeze,
                titleContent_Breeze: content_breeze,
                reviews_Breeze: comments_breeze,
                likes_Breeze: RandomUtil_Breeze.nextInt_Breeze(min_breeze: 10, range_breeze: 150),
                titleCategory_Breeze: category_breeze
            )
            
            dataLocal_breeze.titleList_Breeze.append(post_breeze)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Breeze(postIndex_breeze: Int, postAuthorUserId_breeze: Int) -> [Comment_Breeze] {
        guard let dataLocal_breeze = dataLocal_Breeze else { return [] }
        
        let availableUsers_breeze = dataLocal_breeze.getAvailableCommenters_Breeze(postAuthorUserId_breeze: postAuthorUserId_breeze)
        guard availableUsers_breeze.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_breeze = availableUsers_breeze[postIndex_breeze % availableUsers_breeze.count]
        let commenter2_breeze = availableUsers_breeze[(postIndex_breeze + 1) % availableUsers_breeze.count]
        
        // 获取评论内容
        let commentIndex_breeze = postIndex_breeze % DataSource_Breeze.comments_Breeze.count
        let (comment1_breeze, comment2_breeze) = DataSource_Breeze.comments_Breeze[commentIndex_breeze]
        
        return [
            Comment_Breeze(
                commentId_Breeze: postIndex_breeze * 2 + 1,
                commentUserId_Breeze: commenter1_breeze.userId_Breeze ?? 0,
                commentUserName_Breeze: commenter1_breeze.userName_Breeze ?? "",
                commentContent_Breeze: comment1_breeze
            ),
            Comment_Breeze(
                commentId_Breeze: postIndex_breeze * 2 + 2,
                commentUserId_Breeze: commenter2_breeze.userId_Breeze ?? 0,
                commentUserName_Breeze: commenter2_breeze.userName_Breeze ?? "",
                commentContent_Breeze: comment2_breeze
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Breeze() {
        guard let dataLocal_breeze = dataLocal_Breeze else { return }
        
        for i_breeze in 0..<dataLocal_breeze.userList_Breeze.count {
            let user_breeze = dataLocal_breeze.userList_Breeze[i_breeze]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_breeze = dataLocal_breeze.getPostsExcludingUser_Breeze(
                userId_breeze: user_breeze.userId_Breeze ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_breeze = RandomUtil_Breeze.selectRandomItems_Breeze(
                from: availablePosts_breeze,
                count_breeze: DataConfig_Breeze.likePostCount_Breeze
            )
            
            dataLocal_breeze.userList_Breeze[i_breeze].userLike_Breeze = likePosts_breeze
        }
    }
}

// MARK: - 季节露营 Tips 数据源

/// 四季露营攻略静态数据，覆盖装备/穿搭/摄影/路线四个类别
private struct SeasonalTipsSource_Breeze {
    
    static let all_Breeze: [SeasonalTip_Breeze] = spring_Breeze + summer_Breeze + autumn_Breeze + winter_Breeze
    
    private static let spring_Breeze: [SeasonalTip_Breeze] = [
        SeasonalTip_Breeze(tipId_Breeze: 101, season_Breeze: .spring_breeze, category_Breeze: "Gear",
                           title_Breeze: "Lightweight Tent for Bloom Season",
                           content_Breeze: "Choose a 3-season tent with good ventilation. Spring rains can surprise you — a waterproof footprint is essential for any campsite.",
                           iconName_Breeze: "tent.2.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 102, season_Breeze: .spring_breeze, category_Breeze: "Outfit",
                           title_Breeze: "Layer Up for Cool Mornings",
                           content_Breeze: "Start with a moisture-wicking base, add a fleece mid-layer and a light rain jacket. Spring temps swing wildly between dawn and midday.",
                           iconName_Breeze: "tshirt.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 103, season_Breeze: .spring_breeze, category_Breeze: "Photography",
                           title_Breeze: "Golden Hour Wildflower Shots",
                           content_Breeze: "Shoot during the 30 mins after sunrise. Get low to frame wildflowers against the sky. A wide aperture blurs the background beautifully.",
                           iconName_Breeze: "camera.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 104, season_Breeze: .spring_breeze, category_Breeze: "Routes",
                           title_Breeze: "Follow the Bloom Trail",
                           content_Breeze: "Check local park sites for cherry blossom forecasts. Lower-elevation trails bloom first — plan a 2-day loop and camp midway.",
                           iconName_Breeze: "map.fill"),
    ]
    
    private static let summer_Breeze: [SeasonalTip_Breeze] = [
        SeasonalTip_Breeze(tipId_Breeze: 201, season_Breeze: .summer_breeze, category_Breeze: "Gear",
                           title_Breeze: "Sun Protection Essentials",
                           content_Breeze: "Pack SPF 50 sunscreen, a wide-brim hat and UV-blocking sunglasses. A lightweight tarp provides extra shade at your campsite.",
                           iconName_Breeze: "sun.max.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 202, season_Breeze: .summer_breeze, category_Breeze: "Outfit",
                           title_Breeze: "Breathable Fabrics Beat the Heat",
                           content_Breeze: "Go for loose linen or bamboo-fiber shirts. Light-colored clothing reflects sunlight. Switch to long sleeves at dusk to ward off insects.",
                           iconName_Breeze: "wind"),
        SeasonalTip_Breeze(tipId_Breeze: 203, season_Breeze: .summer_breeze, category_Breeze: "Photography",
                           title_Breeze: "Capture Blue Hour by the Lake",
                           content_Breeze: "The 15 minutes after sunset give a deep-blue sky reflected on calm water. Use a tripod and a 3-5 sec exposure for a perfect mirror effect.",
                           iconName_Breeze: "camera.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 204, season_Breeze: .summer_breeze, category_Breeze: "Routes",
                           title_Breeze: "Start Before Dawn, Rest at Noon",
                           content_Breeze: "Hit the trail by 6 AM to enjoy cool air and golden light. Rest in shade from 11 AM to 2 PM, then continue through the late afternoon.",
                           iconName_Breeze: "figure.hiking"),
    ]
    
    private static let autumn_Breeze: [SeasonalTip_Breeze] = [
        SeasonalTip_Breeze(tipId_Breeze: 301, season_Breeze: .autumn_breeze, category_Breeze: "Gear",
                           title_Breeze: "Upgrade to a 4-Season Sleeping Bag",
                           content_Breeze: "Nighttime temps can drop near freezing in autumn. Use a 0°C-rated bag and a sleeping pad with R-value ≥ 3 to insulate from cold ground.",
                           iconName_Breeze: "moon.stars.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 302, season_Breeze: .autumn_breeze, category_Breeze: "Outfit",
                           title_Breeze: "Earth Tones Blend with the Forest",
                           content_Breeze: "Wear burnt orange, olive or rust tones to complement autumn foliage in photos. Pack a down vest — evenings cool down fast.",
                           iconName_Breeze: "tshirt.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 303, season_Breeze: .autumn_breeze, category_Breeze: "Photography",
                           title_Breeze: "Fog & Foliage: the Perfect Combo",
                           content_Breeze: "Morning fog diffuses light beautifully. Shoot backlit leaves to reveal their colour. A polarizing filter deepens the red and gold tones.",
                           iconName_Breeze: "camera.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 304, season_Breeze: .autumn_breeze, category_Breeze: "Routes",
                           title_Breeze: "Chase the Peak Foliage Window",
                           content_Breeze: "Most parks hit peak colour over just 1–2 weeks. Plan mid-October trips. Ridge trails offer panoramic views of the colour canopy below.",
                           iconName_Breeze: "map.fill"),
    ]
    
    private static let winter_Breeze: [SeasonalTip_Breeze] = [
        SeasonalTip_Breeze(tipId_Breeze: 401, season_Breeze: .winter_breeze, category_Breeze: "Gear",
                           title_Breeze: "Insulated Thermos & Hand Warmers",
                           content_Breeze: "Keep a wide-mouth thermos for hot drinks. Chemical hand warmers last 8 hrs. A four-season tent with strong poles handles snow load safely.",
                           iconName_Breeze: "snowflake"),
        SeasonalTip_Breeze(tipId_Breeze: 402, season_Breeze: .winter_breeze, category_Breeze: "Outfit",
                           title_Breeze: "The 3-Layer Winter System",
                           content_Breeze: "Layer 1: merino wool base. Layer 2: heavyweight fleece. Layer 3: hardshell with taped seams. Wool socks and waterproof boots are essential.",
                           iconName_Breeze: "tshirt.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 403, season_Breeze: .winter_breeze, category_Breeze: "Photography",
                           title_Breeze: "Snow Makes Everything Cinematic",
                           content_Breeze: "Expose +1 stop above the meter reading to keep snow white, not grey. A monochrome edit of bare trees in snow is timeless. Protect your battery from cold.",
                           iconName_Breeze: "camera.fill"),
        SeasonalTip_Breeze(tipId_Breeze: 404, season_Breeze: .winter_breeze, category_Breeze: "Routes",
                           title_Breeze: "Short Days, Cozy Camps",
                           content_Breeze: "Daylight is short — aim for hikes under 8 km and set up camp before 3 PM. Snow-covered ridges at sunrise are absolutely worth the early alarm.",
                           iconName_Breeze: "figure.walk"),
    ]
}
