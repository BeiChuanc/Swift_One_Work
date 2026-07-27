import Foundation

// MARK: 本地数据存放类 - Tidy 拍照技巧社区预制数据

/// 数据配置常量
private struct DataConfig_Tidy {
    /// 用户ID起始值
    static let userIdStart_Tidy = 10
    /// 帖子ID起始值
    static let postIdStart_Tidy = 20
    /// 每位用户默认喜欢帖子数
    static let likePostCount_Tidy = 2
}

/// 本地数据管理类
/// 功能：管理预制的用户、帖子及分类数据，作为社区内容的离线数据源
/// 设计思路：单例模式，通过 DataGenerator 延迟初始化各类数据
class LocalData_Tidy {
    
    /// 单例
    static let shared_Tidy = LocalData_Tidy()
    
    /// 用户列表
    var userList_Tidy: [PrewUserModel_Tidy] = []
    
    /// 帖子列表
    var titleList_Tidy: [TitleModel_Tidy] = []
    
    /// 数据生成器（延迟初始化）
    private lazy var generator_Tidy: DataGenerator_Tidy = {
        return DataGenerator_Tidy(dataLocal_tidy: self)
    }()
    
    private init() {}
    
    /// 初始化所有预制数据
    func initData_Tidy() {
        generator_Tidy.initUsers_Tidy()
        generator_Tidy.initPosts_Tidy()
        generator_Tidy.setUserLikes_Tidy()
    }
    
    /// 获取排除指定用户的帖子列表
    /// 参数：
    /// - userId_tidy: 需排除的用户ID
    /// 返回值：过滤后的帖子数组
    func getPostsExcludingUser_Tidy(userId_tidy: Int) -> [TitleModel_Tidy] {
        return titleList_Tidy.filter { $0.titleUserId_Tidy != userId_tidy }
    }
    
    /// 获取可评论的用户列表（排除帖子作者）
    /// 参数：
    /// - postAuthorUserId_tidy: 帖子作者ID
    /// 返回值：可作为评论者的用户数组
    func getAvailableCommenters_Tidy(postAuthorUserId_tidy: Int) -> [PrewUserModel_Tidy] {
        return userList_Tidy.filter { $0.userId_Tidy != postAuthorUserId_tidy }
    }
}

// MARK: - 静态数据源（Tidy 拍照技巧主题）

/// 静态数据源 - 拍照出片技巧主题
private struct DataSource_Tidy {
    
    /// 用户信息列表 (用户名, 简介, 头像标识, 相册标识)
    static let usersInfo_Tidy: [(String, String, String, String)] = [
        ("FrameMuse",    "Portrait storyteller sharing easy camera-friendly ideas",            "head1", "head1"),
        ("LightCrafter", "Chasing soft light, clean angles, and cinematic everyday shots",     "head2", "head2"),
        ("PosePilot",    "Helping beginners look natural with simple pose cues",               "head3", "head3"),
        ("SnapStylist",  "Outfit and color pairing tips for polished photo sets",              "head4", "head4"),
        ("EditBloom",    "Mobile retouching lover focused on bright, airy finishes",           "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体标识, 分类ID)
    static let postsInfo_Tidy: [(String, String, String, String)] = [
        (
            "Golden Hour Balcony Portrait",
            "Face your subject about 45 degrees toward the sunset instead of straight on. This angle keeps the cheekbone bright, adds catchlights to the eyes, and avoids a flat face. I also lowered exposure a touch so the sky stayed warm while the skin still looked clean.",
            "title1",
            "living_room"
        ),
        (
            "Mirror Pose Guide",
            "The easiest way to avoid stiff selfies is to give your hands a job. Touch the hair, hold the phone lower than eye level, and shift one knee forward. I asked the model to breathe out between frames and the expression instantly looked more natural.",
            "title2",
            "bedroom"
        ),
        (
            "Cafe Window Composition",
            "Window seats are perfect for beginner portraits because the light direction is obvious. I framed the cup in the foreground, kept the eyes on the upper third line, and let the background blur naturally. Three simple layers made the shot feel much more premium.",
            "title3",
            "kitchen"
        ),
        (
            "Monochrome Outfit Formula",
            "When the location is already busy, I keep the clothing palette to one main color plus one neutral. Matching the jacket with the wall tone made the photo look intentional, while white shoes kept the frame from feeling too heavy.",
            "title4",
            "bathroom"
        ),
        (
            "Hidden Alley Location Scout",
            "I look for three things before shooting: clean background depth, side light, and a place to lean. This alley had soft reflected light from the wall and enough distance behind the subject to create depth even on a phone camera.",
            "title5",
            "study"
        ),
        (
            "Quick Mobile Edit Recipe",
            "My fast edit flow is brightness up slightly, highlights down, shadows up, then add a tiny bit of warmth. After that I reduce saturation on distracting colors instead of pushing the whole image. The result stays clean and still looks realistic.",
            "title6",
            "storage"
        ),
        (
            "Pocket Camera Gear Setup",
            "For lightweight street portraits I only carry a phone grip, mini reflector, power bank, and lens cloth. Keeping the kit small helps me move faster and makes the subject less nervous, which usually matters more than bringing extra gear.",
            "title7",
            "garden"
        ),
        (
            "Staircase Leading Lines",
            "Stairs naturally create arrows toward the face. I placed the model one step above me, tilted the phone slightly upward, and kept both rails inside the frame. The lines did the heavy lifting and the whole shot looked taller and cleaner.",
            "title8",
            "kitchen"
        ),
        (
            "Weekend Street Pose Flow",
            "Instead of asking for big poses, I use tiny actions: walk slowly, look back once, adjust the bag strap, then stop. Shooting through motion gives you four or five usable frames in seconds and the body language feels much less forced.",
            "media_one",
            "bedroom"
        ),
        (
            "Neon Night Portrait",
            "At night I place the strongest colored sign behind and slightly beside the subject so the face still catches a clean edge light. Locking focus first and lowering exposure keeps the neon rich without turning the skin muddy.",
            "media_two",
            "living_room"
        ),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Tidy: [(String, String)] = [
        ("That 45-degree light tip is gold. The skin still looks bright but the photo has way more depth.", "Lowering the exposure a little for sunset tones really works. Trying this tonight."),
        ("Giving the hands a job fixes awkward poses so fast. Super beginner-friendly advice.", "The breathing-out cue is such a good reminder. Expressions always look softer that way."),
        ("Foreground layers always make cafe shots feel more expensive. Love this breakdown.", "Using the upper third for the eyes made an immediate difference in my test shots."),
        ("One color plus one neutral is such an easy styling rule. Saving this for my next shoot.", "Busy backgrounds are exactly where I get stuck, so this outfit tip is perfect."),
        ("Clean background depth and side light is the scouting checklist I needed.", "Leaning spots are underrated. They instantly make people look more relaxed."),
        ("Small edits really do look more premium than pushing every slider hard.", "Selective color control instead of global saturation is such a smart mobile workflow."),
        ("A small kit keeps the vibe relaxed and that honestly helps portraits more than gear.", "Lens cloth in the pocket camera kit is so real. Tiny detail, huge difference."),
        ("Leading lines plus a lower angle made my staircase shot look much taller.", "Keeping both rails in frame gave the photo structure immediately."),
        ("Tiny movement prompts are easier than telling someone to pose from scratch.", "Walk, look back, adjust the strap is such a usable shooting sequence."),
        ("Night portraits get muddy so easily, and the exposure lock tip helped a lot.", "Placing the neon slightly behind the subject gave me way better edge light."),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成辅助方法
private struct RandomUtil_Tidy {
    
    /// 生成指定范围的随机整数
    /// 参数：
    /// - min_tidy: 最小值（含）
    /// - range_tidy: 范围跨度
    /// 返回值：随机整数
    static func nextInt_Tidy(min_tidy: Int, range_tidy: Int) -> Int {
        return Int.random(in: min_tidy..<(min_tidy + range_tidy))
    }
    
    /// 从列表中随机选择不重复的 N 个元素
    /// 参数：
    /// - list_tidy: 来源数组
    /// - count_tidy: 需要选取的数量
    /// 返回值：选取结果数组
    static func selectRandomItems_Tidy<T>(from list_tidy: [T], count_tidy: Int) -> [T] {
        guard !list_tidy.isEmpty else { return [] }
        guard list_tidy.count > count_tidy else { return list_tidy }
        
        var selected_tidy: [T] = []
        var indices_tidy: Set<Int> = []
        
        while selected_tidy.count < count_tidy && indices_tidy.count < list_tidy.count {
            let index_tidy = Int.random(in: 0..<list_tidy.count)
            if !indices_tidy.contains(index_tidy) {
                indices_tidy.insert(index_tidy)
                selected_tidy.append(list_tidy[index_tidy])
            }
        }
        
        return selected_tidy
    }
}

// MARK: - 数据生成器

/// 数据生成器
/// 功能：根据静态数据源生成用户、帖子及点赞关联数据
/// 设计思路：与 LocalData 弱引用关联，避免循环引用
class DataGenerator_Tidy {
    
    private weak var dataLocal_Tidy: LocalData_Tidy?
    
    /// 初始化
    /// 参数：
    /// - dataLocal_tidy: 所属 LocalData 实例（弱引用）
    init(dataLocal_tidy: LocalData_Tidy) {
        self.dataLocal_Tidy = dataLocal_tidy
    }
    
    /// 初始化生成用户数据
    func initUsers_Tidy() {
        guard let dataLocal_tidy = dataLocal_Tidy else { return }
        dataLocal_tidy.userList_Tidy.removeAll()
        
        for (index_tidy, userInfo_tidy) in DataSource_Tidy.usersInfo_Tidy.enumerated() {
            let (username_tidy, introduce_tidy, userHead_tidy, userAlbum_tidy) = userInfo_tidy
            
            let user_tidy = PrewUserModel_Tidy()
            user_tidy.userId_Tidy = index_tidy + DataConfig_Tidy.userIdStart_Tidy
            user_tidy.userName_Tidy = username_tidy
            user_tidy.userIntroduce_Tidy = introduce_tidy
            user_tidy.userHead_Tidy = userHead_tidy
            user_tidy.userMedia_Tidy = [userAlbum_tidy]
            user_tidy.userLike_Tidy = []
            user_tidy.userFollow_Tidy = 15 + Int.random(in: 1...50)
            user_tidy.userFans_Tidy = 20 + Int.random(in: 1...50)
            
            dataLocal_tidy.userList_Tidy.append(user_tidy)
        }
    }
    
    /// 初始化生成帖子数据（带分类标识）
    func initPosts_Tidy() {
        guard let dataLocal_tidy = dataLocal_Tidy else { return }
        dataLocal_tidy.titleList_Tidy.removeAll()
        
        for (index_tidy, postInfo_tidy) in DataSource_Tidy.postsInfo_Tidy.enumerated() {
            let (title_tidy, content_tidy, media_tidy, category_tidy) = postInfo_tidy
            
            // 循环分配作者
            let authorIndex_tidy = index_tidy % dataLocal_tidy.userList_Tidy.count
            guard authorIndex_tidy < dataLocal_tidy.userList_Tidy.count else { continue }
            let author_tidy = dataLocal_tidy.userList_Tidy[authorIndex_tidy]
            
            // 生成评论
            let comments_tidy = generateComments_Tidy(
                postIndex_tidy: index_tidy,
                postAuthorUserId_tidy: author_tidy.userId_Tidy ?? 0
            )
            
            let post_tidy = TitleModel_Tidy(
                titleId_Tidy: index_tidy + DataConfig_Tidy.postIdStart_Tidy,
                titleUserId_Tidy: author_tidy.userId_Tidy ?? 0,
                titleUserName_Tidy: author_tidy.userName_Tidy ?? "",
                titleMeidas_Tidy: [media_tidy],
                title_Tidy: title_tidy,
                titleContent_Tidy: content_tidy,
                reviews_Tidy: comments_tidy,
                likes_Tidy: RandomUtil_Tidy.nextInt_Tidy(min_tidy: 10, range_tidy: 150),
                titleCategory_Tidy: category_tidy
            )
            
            dataLocal_tidy.titleList_Tidy.append(post_tidy)
        }
    }
    
    /// 为帖子生成评论
    /// 参数：
    /// - postIndex_tidy: 帖子索引
    /// - postAuthorUserId_tidy: 帖子作者ID（排除自评）
    /// 返回值：评论数组
    private func generateComments_Tidy(postIndex_tidy: Int, postAuthorUserId_tidy: Int) -> [Comment_Tidy] {
        guard let dataLocal_tidy = dataLocal_Tidy else { return [] }
        
        let availableUsers_tidy = dataLocal_tidy.getAvailableCommenters_Tidy(
            postAuthorUserId_tidy: postAuthorUserId_tidy
        )
        guard availableUsers_tidy.count >= 2 else { return [] }
        
        let commenter1_tidy = availableUsers_tidy[postIndex_tidy % availableUsers_tidy.count]
        let commenter2_tidy = availableUsers_tidy[(postIndex_tidy + 1) % availableUsers_tidy.count]
        
        let commentIndex_tidy = postIndex_tidy % DataSource_Tidy.comments_Tidy.count
        let (comment1_tidy, comment2_tidy) = DataSource_Tidy.comments_Tidy[commentIndex_tidy]
        
        return [
            Comment_Tidy(
                commentId_Tidy: postIndex_tidy * 2 + 1,
                commentUserId_Tidy: commenter1_tidy.userId_Tidy ?? 0,
                commentUserName_Tidy: commenter1_tidy.userName_Tidy ?? "",
                commentContent_Tidy: comment1_tidy
            ),
            Comment_Tidy(
                commentId_Tidy: postIndex_tidy * 2 + 2,
                commentUserId_Tidy: commenter2_tidy.userId_Tidy ?? 0,
                commentUserName_Tidy: commenter2_tidy.userName_Tidy ?? "",
                commentContent_Tidy: comment2_tidy
            )
        ]
    }
    
    /// 随机设置各用户的喜欢帖子列表
    func setUserLikes_Tidy() {
        guard let dataLocal_tidy = dataLocal_Tidy else { return }
        
        for i_tidy in 0..<dataLocal_tidy.userList_Tidy.count {
            let user_tidy = dataLocal_tidy.userList_Tidy[i_tidy]
            
            let availablePosts_tidy = dataLocal_tidy.getPostsExcludingUser_Tidy(
                userId_tidy: user_tidy.userId_Tidy ?? 0
            )
            
            let likePosts_tidy = RandomUtil_Tidy.selectRandomItems_Tidy(
                from: availablePosts_tidy,
                count_tidy: DataConfig_Tidy.likePostCount_Tidy
            )
            
            dataLocal_tidy.userList_Tidy[i_tidy].userLike_Tidy = likePosts_tidy
        }
    }
}

// MARK: - 拍摄工具箱预制数据（胶片滤镜 / 教学图库 / 曝光推荐）

/// 拍摄工具箱静态数据源
/// 功能：提供胶片滤镜预设、离线光影教学参考卡片、场景曝光推荐表的本地预制数据，
///       均为纯本地常量，无需网络请求，供 ShootViewModel_Tidy 查询使用
struct ShootDataSource_Tidy {

    /// 胶片滤镜预设列表（6 大分组，共 8 套预设，均为 CIFilter 参数化模拟，无真实 LUT 文件）
    static let filmFilterPresets_Tidy: [FilmFilterPreset_Tidy] = [
        FilmFilterPreset_Tidy(id_Tidy: "fuji_classic", name_Tidy: "Fuji Classic Chrome",
                               group_Tidy: .fujifilm_tidy, exposure_Tidy: -0.02, saturation_Tidy: 0.86,
                               contrast_Tidy: 1.08, temperature_Tidy: -220, tint_Tidy: 4,
                               vignette_Tidy: 0.12, lutFileName_Tidy: nil),
        FilmFilterPreset_Tidy(id_Tidy: "fuji_velvia", name_Tidy: "Fuji Velvia Green",
                               group_Tidy: .fujifilm_tidy, exposure_Tidy: 0.03, saturation_Tidy: 1.18,
                               contrast_Tidy: 1.12, temperature_Tidy: -160, tint_Tidy: -6,
                               vignette_Tidy: 0.10, lutFileName_Tidy: nil),
        FilmFilterPreset_Tidy(id_Tidy: "kodak_gold", name_Tidy: "Kodak Gold Warm",
                               group_Tidy: .kodak_tidy, exposure_Tidy: 0.06, saturation_Tidy: 1.22,
                               contrast_Tidy: 1.10, temperature_Tidy: 320, tint_Tidy: 6,
                               vignette_Tidy: 0.08, lutFileName_Tidy: nil),
        FilmFilterPreset_Tidy(id_Tidy: "kodak_portra", name_Tidy: "Kodak Portra Skin",
                               group_Tidy: .kodak_tidy, exposure_Tidy: 0.04, saturation_Tidy: 1.05,
                               contrast_Tidy: 0.96, temperature_Tidy: 180, tint_Tidy: 8,
                               vignette_Tidy: 0.05, lutFileName_Tidy: nil),
        FilmFilterPreset_Tidy(id_Tidy: "ilford_hp5", name_Tidy: "Ilford HP5 Mono",
                               group_Tidy: .ilford_tidy, exposure_Tidy: 0.0, saturation_Tidy: 0.0,
                               contrast_Tidy: 1.28, temperature_Tidy: 0, tint_Tidy: 0,
                               vignette_Tidy: 0.18, lutFileName_Tidy: nil),
        FilmFilterPreset_Tidy(id_Tidy: "hk_retro", name_Tidy: "Hong Kong Neon Retro",
                               group_Tidy: .hkRetro_tidy, exposure_Tidy: -0.05, saturation_Tidy: 1.15,
                               contrast_Tidy: 1.15, temperature_Tidy: -260, tint_Tidy: 18,
                               vignette_Tidy: 0.30, lutFileName_Tidy: nil),
        FilmFilterPreset_Tidy(id_Tidy: "japanese_clean", name_Tidy: "Japanese Airy Clean",
                               group_Tidy: .japaneseClean_tidy, exposure_Tidy: 0.14, saturation_Tidy: 0.88,
                               contrast_Tidy: 0.82, temperature_Tidy: 90, tint_Tidy: 2,
                               vignette_Tidy: 0.0, lutFileName_Tidy: nil),
        FilmFilterPreset_Tidy(id_Tidy: "cinematic_teal_orange", name_Tidy: "Cinematic Teal & Orange",
                               group_Tidy: .cinematic_tidy, exposure_Tidy: -0.03, saturation_Tidy: 1.02,
                               contrast_Tidy: 1.16, temperature_Tidy: 140, tint_Tidy: -14,
                               vignette_Tidy: 0.22, lutFileName_Tidy: "cinematic_teal_orange.cube")
    ]

    /// 离线光影教学参考卡片列表（按构图分类，占位图标 + 教学文案，共 8 类各 1 条）
    static let lightingReferences_Tidy: [LightingReference_Tidy] = [
        LightingReference_Tidy(id_Tidy: 1, category_Tidy: .ruleOfThirds_tidy,
                                title_Tidy: "Eyes on the Grid Line",
                                description_Tidy: "Place the subject's eyes on the upper horizontal third line so the frame keeps breathing room while the face stays the visual anchor.",
                                iconName_Tidy: "grid"),
        LightingReference_Tidy(id_Tidy: 2, category_Tidy: .goldenSpiral_tidy,
                                title_Tidy: "Spiral Toward the Face",
                                description_Tidy: "Let a curved railing, shoreline, or shadow trail follow the spiral curve inward, ending right at the subject's face for a natural focal pull.",
                                iconName_Tidy: "tornado"),
        LightingReference_Tidy(id_Tidy: 3, category_Tidy: .symmetry_tidy,
                                title_Tidy: "Mirror the Architecture",
                                description_Tidy: "Center the subject inside symmetrical doorways, bridges, or corridors so both halves of the frame balance evenly around them.",
                                iconName_Tidy: "arrow.left.and.right.righttriangle.left.righttriangle.right"),
        LightingReference_Tidy(id_Tidy: 4, category_Tidy: .diagonal_tidy,
                                title_Tidy: "Let the Stairs Lead",
                                description_Tidy: "Shoot from a low corner so stair edges, fences, or roadlines cut the frame diagonally and pull the eye straight to the subject.",
                                iconName_Tidy: "line.diagonal"),
        LightingReference_Tidy(id_Tidy: 5, category_Tidy: .cinemaScope_tidy,
                                title_Tidy: "Wide Bars, Wide Story",
                                description_Tidy: "Crop tall distractions out with letterbox bars, keep the horizon low, and let negative space on both sides feel intentional and cinematic.",
                                iconName_Tidy: "rectangle.compress.vertical"),
        LightingReference_Tidy(id_Tidy: 6, category_Tidy: .idPhoto_tidy,
                                title_Tidy: "Clean Head and Shoulders",
                                description_Tidy: "Keep even, shadow-free lighting on the face, fill about two thirds of the frame with head and shoulders, and use a plain background.",
                                iconName_Tidy: "person.crop.rectangle"),
        LightingReference_Tidy(id_Tidy: 7, category_Tidy: .square_tidy,
                                title_Tidy: "Balance in Every Corner",
                                description_Tidy: "Square frames reward centered subjects with equal breathing room on every side, ideal for flat lays and portrait close-ups.",
                                iconName_Tidy: "square"),
        LightingReference_Tidy(id_Tidy: 8, category_Tidy: .portraitCrop_tidy,
                                title_Tidy: "Avoid Awkward Joint Cuts",
                                description_Tidy: "Crop above or below a joint, never directly through the neck, elbow, or knee, to keep portrait framing feeling natural and comfortable.",
                                iconName_Tidy: "person.crop.square")
    ]

    /// 场景曝光推荐表（人像 / 夜景 / 风光 三套经验性参数）
    static let exposureRecommendationTable_Tidy: [SceneType_Tidy: ExposureRecommendation_Tidy] = [
        .portrait_tidy: ExposureRecommendation_Tidy(
            iso_Tidy: "ISO 100-200", shutterSpeed_Tidy: "1/160s", aperture_Tidy: "f/2.0-2.8",
            tip_Tidy: "Wide aperture blurs the background while a fast shutter avoids motion blur from natural swaying."
        ),
        .night_tidy: ExposureRecommendation_Tidy(
            iso_Tidy: "ISO 800-1600", shutterSpeed_Tidy: "1/30s", aperture_Tidy: "f/1.8-2.2",
            tip_Tidy: "Brace the phone or use a small support, since low light needs higher ISO and a slower shutter."
        ),
        .landscape_tidy: ExposureRecommendation_Tidy(
            iso_Tidy: "ISO 50-100", shutterSpeed_Tidy: "1/250s", aperture_Tidy: "f/5.6-8.0",
            tip_Tidy: "A narrower aperture keeps foreground to horizon sharp, and low ISO preserves clean detail in bright skies."
        )
    ]
}
