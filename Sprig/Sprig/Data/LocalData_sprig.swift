import Foundation

// MARK: 本地预制数据管理

/// 数据配置常量
private struct DataConfig_Sprig {
    static let userIdStart_Sprig = 10
    static let postIdStart_Sprig = 20
    static let likePostCount_Sprig = 2
}

/// 本地数据管理类
/// 功能：集中管理应用的预制数据，包括用户、帖子、花卉百科、标签
class LocalData_Sprig {
    
    /// 单例
    static let shared_Sprig = LocalData_Sprig()
    
    /// 用户列表
    var userList_Sprig: [PrewUserModel_Sprig] = []
    
    /// 帖子列表
    var titleList_Sprig: [TitleModel_Sprig] = []
    
    /// 花卉百科列表
    var flowerList_Sprig: [FlowerModel_Sprig] = []
    
    /// 标签列表
    var tagList_Sprig: [FlowerTagModel_Sprig] = []
    
    /// 数据生成器（懒加载）
    private lazy var generator_Sprig: DataGenerator_Sprig = {
        return DataGenerator_Sprig(dataLocal_sprig: self)
    }()
    
    private init() {}
    
    /// 初始化全部预制数据
    func initData_Sprig() {
        generator_Sprig.initUsers_Sprig()
        generator_Sprig.initPosts_Sprig()
        generator_Sprig.setUserLikes_Sprig()
        generator_Sprig.initFlowers_Sprig()
        generator_Sprig.initTags_Sprig()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Sprig(userId_sprig: Int) -> [TitleModel_Sprig] {
        return titleList_Sprig.filter { $0.titleUserId_Sprig != userId_sprig }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Sprig(postAuthorUserId_sprig: Int) -> [PrewUserModel_Sprig] {
        return userList_Sprig.filter { $0.userId_Sprig != postAuthorUserId_sprig }
    }
}

// MARK: - 静态数据源

/// 静态数据源
private struct DataSource_Sprig {
    
    /// 用户信息 (用户名, 简介, 头像key, 相册key)
    static let usersInfo_Sprig: [(String, String, String, String)] = [
        ("BloomKeeper",   "Passionate about flower care and seasonal blooms",      "head1", "head1"),
        ("PetalWhisper",  "Chasing fragrant gardens one petal at a time",           "head2", "head2"),
        ("RootSeeker",    "I believe every plant tells a story worth nurturing",     "head3", "head3"),
        ("GardenSoul",    "Container gardening addict & indoor jungle curator",      "head4", "head4"),
        ("FloralNomad",   "Documenting bloom seasons around the world",              "head5", "head5"),
    ]
    
    /// 帖子信息 (标题, 内容, 媒体key, 标签数组)
    static let postsInfo_Sprig: [(String, String, String, [String])] = [
        (
            "Cherry Blossom Season Is Here",
            "The sakura trees outside my window finally burst into bloom this morning! Those delicate pink petals glowing in the spring light are simply breathtaking. I've been waiting all year for this two-week window of pure magic. Pro tip: morning light photography captures the translucency of sakura petals best.",
            "title1",
            ["Spring", "Fragrant"]
        ),
        (
            "My Orchid Finally Rebloomed",
            "After 14 months of patient care — just the right humidity, indirect light, and letting the bark dry between waterings — my Phalaenopsis finally pushed out a new flower spike! Seeing that tiny nub appear was pure joy. Orchids teach you that patience is the most powerful gardening tool.",
            "title2",
            ["Indoor", "Rare"]
        ),
        (
            "Sunflower Field Day",
            "Planted these sunflower seeds from scratch in early spring and now they're standing over two meters tall, faces tilting joyfully toward the sun. A small cut in the stem each morning helps them take up water better. Who knew a 50-cent seed packet could create so much happiness?",
            "title3",
            ["Summer", "Easy"]
        ),
        (
            "Rose Pruning Tips",
            "Spent the whole morning giving my David Austin roses their midsummer pruning. The key: sharp, clean shears, cuts at 45 degrees just above an outward-facing bud. Remove any crossing or dead canes. With any luck, they'll reward me with a spectacular second flush in six to eight weeks!",
            "title4",
            ["Spring", "Summer"]
        ),
        (
            "Lavender in Full Bloom",
            "My lavender hedge has erupted in waves of purple. The fragrance drifts through every open window in the house and the bees are absolutely ecstatic. I harvest the stems just before full bloom and hang them upside down to dry — the scent lingers for months in linen sachets.",
            "title5",
            ["Summer", "Fragrant"]
        ),
        (
            "Succulent Propagation 101",
            "Successfully propagated 23 new succulents from a single rosette using the leaf-pulling method. Lay them on dry soil, mist once a week, keep in bright indirect light. The tiny pink roots appearing after two weeks are the most rewarding sight in all of gardening. Zero cost, pure joy.",
            "title6",
            ["Indoor", "Easy"]
        ),
        (
            "Spring Tulip Festival",
            "A spontaneous drive to the tulip fields turned into the best afternoon of spring. Row after row of saturated color — scarlet, butter yellow, deepest plum — stretching to the horizon. I learned that tulip bulbs need a cold stratification period to bloom properly. Worth every frosty winter day!",
            "title7",
            ["Spring"]
        ),
        (
            "Monstera New Leaf Day",
            "My Monstera deliciosa just unfurled its most fenestrated leaf yet — eight gorgeous holes in a single blade! The secret has been consistent watering (letting the top 5 cm dry out), monthly liquid fertilizer during growing season, and a humidifier running nearby. Indoor jungle life is the best life.",
            "title8",
            ["Indoor"]
        ),
        (
            "Peony Season Goals",
            "My first-year peonies bloomed! I almost gave up on them last fall when the foliage died back entirely, but sure enough, those brick-red shoots pushed through the soil in March. Now: dinner-plate-sized blush blooms that literally make people stop walking to stare. Worth every year of waiting.",
            "title9",
            ["Spring", "Fragrant"]
        ),
        (
            "Hydrangea Color Magic",
            "Discovered the soil pH secret to hydrangea color this season. My test strips showed pH 5.2 — and sure enough, the blooms came out a gorgeous cornflower blue. My neighbor's identical cultivar in alkaline soil is bright pink. Same plant, completely different flower. Soil science is actual magic.",
            "title10",
            ["Summer", "Easy"]
        ),
    ]
    
    /// 评论内容 (评论1, 评论2)
    static let comments_Sprig: [(String, String)] = [
        ("The sakura light you captured is incredible! I always miss the peak window — saving this as a reminder to plan better next year.", "Two weeks of magic and then gone. That impermanence is what makes cherry blossoms so special. Stunning shot!"),
        ("14 months! Your patience is legendary. My orchid has been sulking for two years — maybe I need to rethink my watering routine.", "That moment you spot the new spike is unmatched. Pure orchid parent joy. Congrats on the reblooming!"),
        ("I planted sunflowers for the first time this summer too — completely addicted now. The stem-cut morning tip is a game changer!", "A 50-cent packet and months of anticipation — that's the best return on investment in all of gardening!"),
        ("The 45-degree cut tip is so important and so often skipped! My roses improved dramatically once I started pruning properly.", "Six to eight weeks and then that second flush — one of the best delayed rewards in gardening. Fingers crossed for yours!"),
        ("Lavender linen sachets! I've been meaning to try this for years. Do you add anything else or just the straight lavender?", "The bees in lavender are one of summer's perfect sounds. Your hedge must smell absolutely incredible up close."),
        ("23 from one rosette is unbelievable efficiency! I've tried leaf propagation before with mixed results — maybe I'm misting too much.", "The tiny roots are genuinely one of the most exciting things to discover in plant care. Little miracles every time."),
        ("Those color rows are breathtaking! I never knew about the cold stratification — explains why mine flopped when I planted them in spring.", "Tulip fields are worth the spontaneous detour every single time. What colors caught your eye most?"),
        ("Eight holes in one leaf! My monstera is still putting out solid leaves — I think I need to increase the humidity. Humidifier going on the shopping list.", "The fenestration progression on a monstera is so satisfying to watch. Yours is clearly very happy in its spot!"),
        ("Year-one peonies blooming is a gift — mine took three years! Those blush dinner-plate blooms are exactly what peony dreams are made of.", "People stopping on the street for your peonies is the highest compliment a garden can receive. Absolute magic."),
        ("Soil pH test strips are now going straight into my cart — I had no idea that's what controls hydrangea color! This is life-changing info.", "The same plant producing pink or blue based purely on soil chemistry is genuinely wild. Nature's chemistry lab in your garden!"),
    ]
    
    /// 花卉百科数据 (英文名, 中文名, emoji, SF图标, 十六进制颜色, 花期月份, 难度1-3, 浇水天数, 养护要点, 场景)
    static let flowersInfo_Sprig: [(String, String, String, String, String, [Int], Int, Int, String, String)] = [
        ("Cherry Blossom", "樱花",      "🌸", "leaf.fill",          "#F687B3", [3,4],       2, 5, "Water deeply twice a week in spring. Protect from late frost. Avoid waterlogging roots.",                           "Outdoor"),
        ("Orchid",         "兰花",      "🪷", "sparkles",            "#9F7AEA", [1,2,3,4,10,11,12], 3, 10, "Let bark dry completely between waterings. 12–14 hours indirect light. Monthly balanced fertilizer.",  "Indoor"),
        ("Rose",           "玫瑰",      "🌹", "heart.fill",          "#FC8181", [4,5,6,9,10], 2, 4, "Water at base to avoid black spot. Prune to outward buds. Feed fortnightly with rose fertilizer.",                "Outdoor"),
        ("Lavender",       "薰衣草",    "💜", "wind",                "#9F7AEA", [6,7,8],     1, 14, "Thrives in well-drained alkaline soil. Full sun 6+ hours. Never overwater — drought-tolerant.",                  "Both"),
        ("Sunflower",      "向日葵",    "🌻", "sun.max.fill",        "#F6AD55", [7,8,9],     1, 3, "Full sun essential. Water at base every 3 days. Support tall varieties. Harvest seeds when back turns yellow.", "Outdoor"),
        ("Tulip",          "郁金香",    "🌷", "camera.macro",        "#F687B3", [3,4,5],     1, 7, "Plant bulbs in autumn for spring bloom. Need cold stratification. Let foliage die back naturally post-bloom.",    "Both"),
        ("Monstera",       "龟背竹",    "🌿", "leaf.arrow.triangle.circlepath", "#48BB78", [1,2,3,4,5,6,7,8,9,10,11,12], 2, 7, "Water when top 5 cm of soil is dry. High humidity boosts fenestration. Wipe leaves monthly.", "Indoor"),
        ("Succulent",      "多肉植物",  "🪴", "drop.triangle.fill",  "#81E6D9", [1,2,3,4,5,6,7,8,9,10,11,12], 1, 14, "Water thoroughly then let soil dry completely. Bright indirect light. Gritty well-draining soil only.",  "Indoor"),
        ("Peony",          "牡丹",      "🌺", "circle.hexagongrid.fill", "#FBB6CE", [4,5,6],  2, 5, "Plant eyes just 3–5 cm below soil surface. Full sun. Deadhead spent blooms. Divide clumps every 5 years.",       "Outdoor"),
        ("Hydrangea",      "绣球花",    "🔵", "drop.fill",           "#90CDF4", [6,7,8],     2, 3, "Acidic soil (pH 5.0–5.5) for blue; alkaline for pink. Keep soil consistently moist. Afternoon shade in heat.",   "Both"),
        ("Jasmine",        "茉莉",      "🤍", "moon.stars.fill",     "#F6E05E", [6,7,8,9],   2, 5, "Water regularly during bloom season. Feed every two weeks. Prune lightly after flowering for shape.",             "Both"),
        ("Chrysanthemum",  "菊花",      "🌼", "star.fill",           "#F6AD55", [9,10,11],   1, 4, "Pinch growing tips in spring and early summer to encourage bushiness. Full sun. Deadhead regularly.",             "Both"),
        ("Lily",           "百合",      "🤍", "seal.fill",           "#FEEBC8", [6,7,8],     2, 4, "Plant bulbs twice their depth. Excellent drainage critical. Stake tall varieties. Remove pollen to extend blooms.", "Both"),
        ("Dahlia",         "大丽花",    "🌸", "hexagon.fill",        "#F6AD55", [7,8,9,10],  2, 3, "Start tubers indoors 4–6 weeks before last frost. Deadhead continuously. Lift tubers in autumn in cold climates.","Outdoor"),
        ("Gardenia",       "栀子花",    "🤍", "leaf.circle.fill",    "#81E6D9", [5,6,7],     3, 3, "High humidity essential — mist daily or use pebble tray. Acidic soil pH 5.0–6.0. Keep away from cold drafts.",   "Indoor"),
    ]
    
    /// 标签数据 (名称, SF图标, 十六进制颜色, 关联关键词)
    static let tagsInfo_Sprig: [(String, String, String, [String])] = [
        ("Spring",   "leaf.fill",       "#F687B3", ["spring", "cherry", "tulip", "peony", "sakura", "rose"]),
        ("Summer",   "sun.max.fill",    "#F6AD55", ["summer", "sunflower", "lavender", "hydrangea", "jasmine", "lily", "dahlia"]),
        ("Autumn",   "wind",            "#ED8936", ["autumn", "chrysanthemum", "dahlia", "fall"]),
        ("Winter",   "snowflake",       "#90CDF4", ["winter", "orchid", "indoor", "warm"]),
        ("Indoor",   "house.fill",      "#9F7AEA", ["indoor", "monstera", "orchid", "succulent", "gardenia"]),
        ("Easy",     "hand.thumbsup.fill", "#48BB78", ["easy", "succulent", "sunflower", "hydrangea", "chrysanthemum"]),
        ("Fragrant", "sparkles",        "#F6E05E", ["fragrant", "jasmine", "lavender", "rose", "peony", "gardenia"]),
        ("Rare",     "star.fill",       "#FC8181", ["rare", "orchid", "dahlia", "lily", "gardenia"]),
    ]
}

// MARK: - 随机数工具

/// 随机数生成工具
private struct RandomUtil_Sprig {
    
    /// 指定范围随机整数
    static func nextInt_Sprig(min_sprig: Int, range_sprig: Int) -> Int {
        return Int.random(in: min_sprig..<(min_sprig + range_sprig))
    }
    
    /// 从列表中随机选取不重复的N个元素
    static func selectRandomItems_Sprig<T>(from list_sprig: [T], count_sprig: Int) -> [T] {
        guard !list_sprig.isEmpty else { return [] }
        guard list_sprig.count > count_sprig else { return list_sprig }
        var selected_sprig: [T] = []
        var indices_sprig: Set<Int> = []
        while selected_sprig.count < count_sprig && indices_sprig.count < list_sprig.count {
            let index_sprig = Int.random(in: 0..<list_sprig.count)
            if !indices_sprig.contains(index_sprig) {
                indices_sprig.insert(index_sprig)
                selected_sprig.append(list_sprig[index_sprig])
            }
        }
        return selected_sprig
    }
}

// MARK: - 数据生成器

/// 数据生成器
/// 功能：负责生成和填充本地预制数据，包括用户、帖子、花卉、标签
class DataGenerator_Sprig {
    
    private weak var dataLocal_Sprig: LocalData_Sprig?
    
    init(dataLocal_sprig: LocalData_Sprig) {
        self.dataLocal_Sprig = dataLocal_sprig
    }
    
    /// 初始化用户数据
    func initUsers_Sprig() {
        guard let data_sprig = dataLocal_Sprig else { return }
        data_sprig.userList_Sprig.removeAll()
        for (index_sprig, info_sprig) in DataSource_Sprig.usersInfo_Sprig.enumerated() {
            let (name_sprig, intro_sprig, head_sprig, album_sprig) = info_sprig
            let user_sprig = PrewUserModel_Sprig()
            user_sprig.userId_Sprig = index_sprig + DataConfig_Sprig.userIdStart_Sprig
            user_sprig.userName_Sprig = name_sprig
            user_sprig.userIntroduce_Sprig = intro_sprig
            user_sprig.userHead_Sprig = head_sprig
            user_sprig.userMedia_Sprig = [album_sprig]
            user_sprig.userLike_Sprig = []
            user_sprig.userFollow_Sprig = 15 + Int.random(in: 1...80)
            user_sprig.userFans_Sprig = 20 + Int.random(in: 1...120)
            data_sprig.userList_Sprig.append(user_sprig)
        }
    }
    
    /// 初始化帖子数据
    func initPosts_Sprig() {
        guard let data_sprig = dataLocal_Sprig else { return }
        data_sprig.titleList_Sprig.removeAll()
        for (index_sprig, info_sprig) in DataSource_Sprig.postsInfo_Sprig.enumerated() {
            let (title_sprig, content_sprig, media_sprig, tags_sprig) = info_sprig
            let authorIndex_sprig = index_sprig % data_sprig.userList_Sprig.count
            guard authorIndex_sprig < data_sprig.userList_Sprig.count else { continue }
            let author_sprig = data_sprig.userList_Sprig[authorIndex_sprig]
            let comments_sprig = generateComments_Sprig(
                postIndex_sprig: index_sprig,
                postAuthorUserId_sprig: author_sprig.userId_Sprig ?? 0
            )
            let post_sprig = TitleModel_Sprig(
                titleId_Sprig: index_sprig + DataConfig_Sprig.postIdStart_Sprig,
                titleUserId_Sprig: author_sprig.userId_Sprig ?? 0,
                titleUserName_Sprig: author_sprig.userName_Sprig ?? "",
                titleMeidas_Sprig: [media_sprig],
                title_Sprig: title_sprig,
                titleContent_Sprig: content_sprig,
                reviews_Sprig: comments_sprig,
                likes_Sprig: RandomUtil_Sprig.nextInt_Sprig(min_sprig: 10, range_sprig: 200),
                titleTags_Sprig: tags_sprig
            )
            data_sprig.titleList_Sprig.append(post_sprig)
        }
    }
    
    /// 为指定帖子生成预制评论
    private func generateComments_Sprig(postIndex_sprig: Int, postAuthorUserId_sprig: Int) -> [Comment_Sprig] {
        guard let data_sprig = dataLocal_Sprig else { return [] }
        let available_sprig = data_sprig.getAvailableCommenters_Sprig(postAuthorUserId_sprig: postAuthorUserId_sprig)
        guard available_sprig.count >= 2 else { return [] }
        let c1_sprig = available_sprig[postIndex_sprig % available_sprig.count]
        let c2_sprig = available_sprig[(postIndex_sprig + 1) % available_sprig.count]
        let idx_sprig = postIndex_sprig % DataSource_Sprig.comments_Sprig.count
        let (text1_sprig, text2_sprig) = DataSource_Sprig.comments_Sprig[idx_sprig]
        return [
            Comment_Sprig(
                commentId_Sprig: postIndex_sprig * 2 + 1,
                commentUserId_Sprig: c1_sprig.userId_Sprig ?? 0,
                commentUserName_Sprig: c1_sprig.userName_Sprig ?? "",
                commentContent_Sprig: text1_sprig
            ),
            Comment_Sprig(
                commentId_Sprig: postIndex_sprig * 2 + 2,
                commentUserId_Sprig: c2_sprig.userId_Sprig ?? 0,
                commentUserName_Sprig: c2_sprig.userName_Sprig ?? "",
                commentContent_Sprig: text2_sprig
            )
        ]
    }
    
    /// 随机设置用户喜欢的帖子
    func setUserLikes_Sprig() {
        guard let data_sprig = dataLocal_Sprig else { return }
        for i_sprig in 0..<data_sprig.userList_Sprig.count {
            let user_sprig = data_sprig.userList_Sprig[i_sprig]
            let available_sprig = data_sprig.getPostsExcludingUser_Sprig(userId_sprig: user_sprig.userId_Sprig ?? 0)
            let liked_sprig = RandomUtil_Sprig.selectRandomItems_Sprig(
                from: available_sprig,
                count_sprig: DataConfig_Sprig.likePostCount_Sprig
            )
            data_sprig.userList_Sprig[i_sprig].userLike_Sprig = liked_sprig
        }
    }
    
    /// 初始化花卉百科数据（15种花卉）
    func initFlowers_Sprig() {
        guard let data_sprig = dataLocal_Sprig else { return }
        data_sprig.flowerList_Sprig.removeAll()
        for (index_sprig, info_sprig) in DataSource_Sprig.flowersInfo_Sprig.enumerated() {
            let (name_sprig, cnName_sprig, emoji_sprig, icon_sprig, color_sprig,
                 months_sprig, level_sprig, water_sprig, tip_sprig, place_sprig) = info_sprig
            let flower_sprig = FlowerModel_Sprig(
                flowerId_Sprig: index_sprig + 1,
                flowerName_Sprig: name_sprig,
                flowerCnName_Sprig: cnName_sprig,
                flowerEmoji_Sprig: emoji_sprig,
                flowerIcon_Sprig: icon_sprig,
                flowerHexColor_Sprig: color_sprig,
                bloomMonths_Sprig: months_sprig,
                careLevel_Sprig: level_sprig,
                waterDays_Sprig: water_sprig,
                tipText_Sprig: tip_sprig,
                placement_Sprig: place_sprig
            )
            data_sprig.flowerList_Sprig.append(flower_sprig)
        }
    }
    
    /// 初始化标签数据（8个分类标签）
    func initTags_Sprig() {
        guard let data_sprig = dataLocal_Sprig else { return }
        data_sprig.tagList_Sprig.removeAll()
        for (index_sprig, info_sprig) in DataSource_Sprig.tagsInfo_Sprig.enumerated() {
            let (name_sprig, icon_sprig, color_sprig, keywords_sprig) = info_sprig
            let tag_sprig = FlowerTagModel_Sprig(
                tagId_Sprig: index_sprig + 1,
                tagName_Sprig: name_sprig,
                tagIcon_Sprig: icon_sprig,
                tagHexColor_Sprig: color_sprig,
                relatedKeywords_Sprig: keywords_sprig
            )
            data_sprig.tagList_Sprig.append(tag_sprig)
        }
    }
}
