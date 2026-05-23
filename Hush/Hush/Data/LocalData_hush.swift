import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Hush {
    /// ID起始值
    static let userIdStart_Hush = 10
    static let postIdStart_Hush = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Hush = 2
}

/// 本地数据管理类
class LocalData_Hush {
    
    /// 单例
    static let shared_Hush = LocalData_Hush()
    
    /// 用户列表
    var userList_Hush: [PrewUserModel_Hush] = []
    
    /// 帖子列表
    var titleList_Hush: [TitleModel_Hush] = []
    
    /// 季节挑战列表（全年4季 × 3个，初始化时生成）
    var seasonChallenges_Hush: [SeasonChallengeModel_Hush] = []
    
    /// 技巧提示卡列表
    var tipCards_Hush: [TipCardModel_Hush] = []
    
    /// 数据生成器
    private lazy var generator_Hush: DataGenerator_Hush = {
        return DataGenerator_Hush(dataLocal_hush: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Hush() {
        generator_Hush.initUsers_Hush()
        generator_Hush.initPosts_Hush()
        generator_Hush.setUserLikes_Hush()
        generator_Hush.initSeasonChallenges_Hush()
        generator_Hush.initTipCards_Hush()
    }
    
    /// 获取当前季节对应的3个挑战
    /// - Returns: 当前季节的 SeasonChallengeModel_Hush 数组（最多3条）
    func getCurrentSeasonChallenges_Hush() -> [SeasonChallengeModel_Hush] {
        let season_hush = SeasonUtil_Hush.currentSeason_Hush()
        return seasonChallenges_Hush.filter { $0.season_Hush == season_hush }
    }
    
    /// 根据ID查找季节挑战
    /// - Parameter challengeId_hush: 挑战ID
    /// - Returns: 对应的 SeasonChallengeModel_Hush，未找到返回 nil
    func findChallenge_Hush(challengeId_hush: Int) -> SeasonChallengeModel_Hush? {
        return seasonChallenges_Hush.first { $0.challengeId_Hush == challengeId_hush }
    }
    
    /// 获取当天的3张灵感卡（以当天日期作为种子，每天固定3张）
    /// - Returns: 3个 InspirationCardModel_Hush
    func getDailyInspirationCards_Hush() -> [InspirationCardModel_Hush] {
        return generator_Hush.generateDailyCards_Hush()
    }
    
    /// 获取热门帖子（按点赞数降序排列，返回前 N 条）
    /// - Parameter count_hush: 返回数量，默认 3
    /// - Returns: 按 likes_Hush 降序排列的帖子数组
    func getTopPosts_Hush(count_hush: Int = 3) -> [TitleModel_Hush] {
        let sorted_hush = titleList_Hush.sorted { $0.likes_Hush > $1.likes_Hush }
        return Array(sorted_hush.prefix(count_hush))
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Hush(userId_hush: Int) -> [TitleModel_Hush] {
        return titleList_Hush.filter { $0.titleUserId_Hush != userId_hush }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Hush(postAuthorUserId_hush: Int) -> [PrewUserModel_Hush] {
        return userList_Hush.filter { $0.userId_Hush != postAuthorUserId_hush }
    }
}

// MARK: - 季节工具

/// 季节计算工具
struct SeasonUtil_Hush {
    
    /// 根据当前月份返回所在季节
    /// - Returns: "Spring" / "Summer" / "Autumn" / "Winter"
    static func currentSeason_Hush() -> String {
        let month_hush = Calendar.current.component(.month, from: Date())
        switch month_hush {
        case 3, 4, 5: return "Spring"
        case 6, 7, 8: return "Summer"
        case 9, 10, 11: return "Autumn"
        default: return "Winter"
        }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Hush {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Hush: [(String, String, String, String)] = [
        ("LensWhisper", "Finding silence in the noise of every street", "head1", "head1"),
        ("UrbanGhost", "Chasing shadows and light through city alleys", "head2", "head2"),
        ("CandidSoul", "Every corner holds a story waiting to be told", "head3", "head3"),
        ("NeonWanderer", "Lost in city lights and candid moments after dark", "head4", "head4"),
        ("SilentFrame", "Capturing the unposed, the raw, the quietly human", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Hush: [(String, String, String)] = [
        ("Morning Rush", "6:47 AM, and the city already forgets to breathe. I stood at the corner of Fifth and watched faces blur into motion—briefcases swinging, coffee cups steaming, eyes fixed somewhere far ahead. Nobody noticed me. Nobody noticed each other. That invisibility is where the real shot lives.", "title1"),
        ("Rainy Alley", "The rain does something honest to a city. It strips away the performance and leaves only reflection—puddles mirroring neon signs, umbrellas tilted like question marks, a woman in a yellow coat pausing to check her phone. I almost didn't press the shutter. Almost.", "title2"),
        ("The Old Bench", "He's been sitting on that bench every Tuesday for three years. I know because I've been walking past for just as long. Today I finally stopped. He said the pigeons are better company than most people. I think he might be right.", "title3"),
        ("Neon Midnight", "Past midnight, the streets belong to a different kind of people. The ones who work late, drift slow, or simply refuse to go home. There's no performance here—just honest faces under honest light, drenched in pink and blue from signs they've long stopped reading.", "title4"),
        ("Forgotten Corners", "The city has a memory problem. It builds over everything and calls it progress. But if you duck into the right alley, you find what it forgot: a faded mural, a locked door with a hand-painted number, a rusted bike chained to nothing.", "title5"),
        ("School Bell Echoes", "3:15 PM sounds like chaos, but it's really just freedom with a time stamp. Backpacks bounce, shoes scuff the pavement, and somewhere in the middle of all that energy is a kid walking alone, looking up at the sky like he's solving something.", "title6"),
        ("Market Colors", "The wet market at 7 AM is the most honest place in the city. No filters, no curation—just the smell of earth, the clatter of crates, and vendors who've been doing this longer than the building has been standing. Color lives here.", "title7"),
        ("Commuter Silence", "There is a particular silence inside a moving train. Twenty people, twenty private worlds, all pressed together by necessity. I never ask permission. I just try to become part of the furniture and wait for the moment someone forgets I'm there.", "title8"),
        ("Puddle Mirrors", "After the rain clears, the pavement becomes a second city—upside-down and slightly wrong. Buildings stretch into the water, headlights bloom, and the woman walking through it doesn't notice she's being doubled. I crouch low and wait for her next step.", "title9"),
        ("Last Light", "Golden hour on Clement Street lasts about eleven minutes. The light falls sideways and turns ordinary things strange—a fruit stand glowing like it's lit from within, a man's silver hair catching fire, shadows stretching three times longer than the people casting them.", "title10"),
    ]
    
    /// 灵感卡池（任务描述, SF Symbol图标名）
    static let inspirationPool_Hush: [(String, String)] = [
        ("Capture a colorful door", "door.left.hand.closed"),
        ("Shoot a walking silhouette", "figure.walk"),
        ("Frame the sky's palette", "cloud.sun.fill"),
        ("Find a reflection in a puddle", "drop.fill"),
        ("Photograph someone waiting alone", "person.fill"),
        ("Capture a vintage shop sign", "signpost.right.fill"),
        ("Shoot a shadow play on a wall", "sun.max.fill"),
        ("Find a moment of laughter on the street", "face.smiling"),
        ("Capture steam rising from food", "smoke.fill"),
        ("Shoot an empty bench at sunset", "sunset.fill"),
        ("Find a handwritten note or sign", "note.text"),
        ("Capture a child's curiosity", "eyes"),
        ("Photograph hands telling a story", "hand.raised.fill"),
        ("Shoot the first light of dawn", "sunrise.fill"),
        ("Capture an unexpected color pop", "paintpalette.fill"),
        ("Find geometry in architecture", "square.grid.3x3.fill"),
        ("Shoot a lonely figure in a crowd", "person.3.fill"),
        ("Capture umbrellas dancing in rain", "umbrella.fill"),
    ]
    
    /// 季节挑战数据（季节, 主题, 描述, 主题色Hex）
    static let seasonChallenges_Hush: [(String, String, String, String)] = [
        // 春季
        ("Spring", "First Ray of Spring Light", "Capture the first soft sunlight of spring filtering through newly budding branches or blossoms.", "#A8D5A2"),
        ("Spring", "Spring Rain Reflection", "Find a mirror-like puddle reflecting a cherry blossom or the first green leaf of the season.", "#7EC8C8"),
        ("Spring", "Street Corner in Bloom", "A busy street corner suddenly softened by one blooming flower—find the quiet beauty amid the rush.", "#F9C784"),
        // 夏季
        ("Summer", "Dusk Wind of Summer", "Show movement—a shirt hem, loose hair, or rustling leaves—caught in the warm evening breeze.", "#FF8C61"),
        ("Summer", "Ice Cold Afternoon", "A dripping ice cream, a frosted cold drink, the heat made visible in small and fleeting moments.", "#61B3FF"),
        ("Summer", "Barefoot on Asphalt", "Children, dogs, strangers—feet and the stories they tell on hot summer pavement.", "#FFD166"),
        // 秋季
        ("Autumn", "The First Fallen Leaf", "A single leaf resting on pavement, an old bench, or an outstretched hand—autumn's quiet announcement.", "#D4845A"),
        ("Autumn", "Golden Alley", "Walk down a leaf-covered alley and catch the slanted light falling through the golden canopy.", "#C9A84C"),
        ("Autumn", "Autumn Market Colors", "The warm tones of a produce market in October—deep orange, scarlet red, and harvest yellow.", "#B85C38"),
        // 冬季
        ("Winter", "Warm Light in the Cold", "A lamppost glow, a café window, a single candle—warmth radiating against the depth of winter darkness.", "#A0C4E8"),
        ("Winter", "Breath and Steam", "Exhaled breath or street food steam caught in sharp focus against a cold, grey winter background.", "#C7C7D1"),
        ("Winter", "Empty Winter Street", "The silence and loneliness of a familiar street stripped bare of summer life and warmth.", "#8FB3C9"),
    ]
    
    /// 技巧提示卡数据（正面标题, SF Symbol图标, 背面详细内容）
    static let tipCards_Hush: [(String, String, String)] = [
        ("Golden Hour", "sun.horizon.fill", "Shoot 30 minutes after sunrise or before sunset. The light turns warm, soft, and directional—everything glows."),
        ("Rule of Thirds", "grid", "Imagine a 3×3 grid over your frame. Place your subject at an intersection point for a more dynamic, balanced shot."),
        ("Embrace Shadows", "moon.fill", "Deep shadows add mystery and depth. Let darkness do half the storytelling—don't chase the light, follow the contrast."),
        ("Stay Invisible", "eye.slash.fill", "Move slowly, avoid eye contact, and become part of the environment. The best street shots happen when no one notices you."),
        ("One Lens Only", "camera.circle.fill", "Commit to a single focal length for a week. Constraints force creativity and teach you to see in a whole new way."),
        ("Shoot in Flat Light", "cloud.fill", "Overcast days create soft, even light—perfect for portraits and street scenes without the harshness of direct sun."),
        ("The 1% Moment", "timer", "90% of street photography is waiting. Stay in one good spot for 20 minutes and let the city come to you."),
        ("Follow the Energy", "bolt.fill", "Markets, train exits, school dismissals—go where life concentrates, and the shots will find you."),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Hush: [(String, String)] = [
        ("That framing is unreal. The way you disappeared into the crowd and still got this—pure instinct", "This is why I carry my camera every single day. You never know when the city gives you a moment like this"),
        ("The reflection in that puddle is more composed than most studio shots I've seen", "Rain-soaked streets are their own kind of darkroom. You nailed the exposure on this one"),
        ("Three years of patience for one conversation. That's the long game, and it paid off", "Street photography is 90% waiting and 10% not flinching. This is a masterclass in both"),
        ("Neon portraits always feel like the city is doing the lighting for you—if you know where to stand", "That pink cast on his face is everything. I can almost hear the hum of the sign above him"),
        ("The forgotten corners are where the real history is. Developers erase, photographers remember", "That rusted bike looks like it's been waiting for someone who's never coming back. Quietly devastating"),
        ("You caught the exact second between chaos and stillness. The kid looking up is the whole story", "School hours are one of the best windows for street work. Energy is completely unguarded"),
        ("Markets are basically a cheat code for color theory. The layers in this shot are incredible", "I always feel like I'm intruding in markets, but then I see work like this and remember it's worth it"),
        ("The train is one of the few places where strangers are forced to share space and still stay private", "You became furniture. That's the highest compliment you can give a street photographer"),
        ("Crouching for the puddle reflection is commitment. Most people walk past without looking down", "The doubled city is so disorienting and beautiful at the same time. What focal length was this?"),
        ("Eleven minutes is nothing. The fact that you were already there and ready is everything", "That fruit stand glow is otherworldly. Golden hour on a busy street is basically free magic"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Hush {
    
    /// 生成指定范围的随机整数
    static func nextInt_Hush(min_hush: Int, range_hush: Int) -> Int {
        return Int.random(in: min_hush..<(min_hush + range_hush))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Hush<T>(from list_hush: [T], count_hush: Int) -> [T] {
        guard !list_hush.isEmpty else { return [] }
        guard list_hush.count > count_hush else { return list_hush }
        
        var selected_hush: [T] = []
        var indices_hush: Set<Int> = []
        
        while selected_hush.count < count_hush && indices_hush.count < list_hush.count {
            let index_hush = Int.random(in: 0..<list_hush.count)
            if !indices_hush.contains(index_hush) {
                indices_hush.insert(index_hush)
                selected_hush.append(list_hush[index_hush])
            }
        }
        
        return selected_hush
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Hush {
    
    private weak var dataLocal_Hush: LocalData_Hush?
    
    init(dataLocal_hush: LocalData_Hush) {
        self.dataLocal_Hush = dataLocal_hush
    }
    
    /// 初始化生成用户数据
    func initUsers_Hush() {
        guard let dataLocal_hush = dataLocal_Hush else { return }
        dataLocal_hush.userList_Hush.removeAll()
        
        for (index_hush, userInfo_hush) in DataSource_Hush.usersInfo_Hush.enumerated() {
            let (username_hush, introduce_hush, userHead_hush, userAlbum_hush) = userInfo_hush
            
            let user_hush = PrewUserModel_Hush()
            user_hush.userId_Hush = index_hush + DataConfig_Hush.userIdStart_Hush
            user_hush.userName_Hush = username_hush
            user_hush.userIntroduce_Hush = introduce_hush
            user_hush.userHead_Hush = userHead_hush
            user_hush.userMedia_Hush = [userAlbum_hush]
            user_hush.userLike_Hush = []
            user_hush.userFollow_Hush = 15 + Int.random(in: 1...50)
            user_hush.userFans_Hush = 20 + Int.random(in: 1...50)
            
            dataLocal_hush.userList_Hush.append(user_hush)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Hush() {
        guard let dataLocal_hush = dataLocal_Hush else { return }
        dataLocal_hush.titleList_Hush.removeAll()
        
        for (index_hush, postInfo_hush) in DataSource_Hush.postsInfo_Hush.enumerated() {
            let (title_hush, content_hush, media_hush) = postInfo_hush
            
            // 循环分配作者
            let authorIndex_hush = index_hush % dataLocal_hush.userList_Hush.count
            guard authorIndex_hush < dataLocal_hush.userList_Hush.count else { continue }
            let author_hush = dataLocal_hush.userList_Hush[authorIndex_hush]
            
            // 生成评论
            let comments_hush = generateComments_Hush(
                postIndex_hush: index_hush,
                postAuthorUserId_hush: author_hush.userId_Hush ?? 0
            )
            
            // 创建帖子
            let post_hush = TitleModel_Hush(
                titleId_Hush: index_hush + DataConfig_Hush.postIdStart_Hush,
                titleUserId_Hush: author_hush.userId_Hush ?? 0,
                titleUserName_Hush: author_hush.userName_Hush ?? "",
                titleMeidas_Hush: [media_hush],
                title_Hush: title_hush,
                titleContent_Hush: content_hush,
                reviews_Hush: comments_hush,
                likes_Hush: RandomUtil_Hush.nextInt_Hush(min_hush: 10, range_hush: 150)
            )
            
            dataLocal_hush.titleList_Hush.append(post_hush)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Hush(postIndex_hush: Int, postAuthorUserId_hush: Int) -> [Comment_Hush] {
        guard let dataLocal_hush = dataLocal_Hush else { return [] }
        
        let availableUsers_hush = dataLocal_hush.getAvailableCommenters_Hush(postAuthorUserId_hush: postAuthorUserId_hush)
        guard availableUsers_hush.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_hush = availableUsers_hush[postIndex_hush % availableUsers_hush.count]
        let commenter2_hush = availableUsers_hush[(postIndex_hush + 1) % availableUsers_hush.count]
        
        // 获取评论内容
        let commentIndex_hush = postIndex_hush % DataSource_Hush.comments_Hush.count
        let (comment1_hush, comment2_hush) = DataSource_Hush.comments_Hush[commentIndex_hush]
        
        return [
            Comment_Hush(
                commentId_Hush: postIndex_hush * 2 + 1,
                commentUserId_Hush: commenter1_hush.userId_Hush ?? 0,
                commentUserName_Hush: commenter1_hush.userName_Hush ?? "",
                commentContent_Hush: comment1_hush
            ),
            Comment_Hush(
                commentId_Hush: postIndex_hush * 2 + 2,
                commentUserId_Hush: commenter2_hush.userId_Hush ?? 0,
                commentUserName_Hush: commenter2_hush.userName_Hush ?? "",
                commentContent_Hush: comment2_hush
            )
        ]
    }
    
    /// 初始化季节挑战数据（全年4季 × 3个 = 12条）
    func initSeasonChallenges_Hush() {
        guard let dataLocal_hush = dataLocal_Hush else { return }
        dataLocal_hush.seasonChallenges_Hush.removeAll()
        
        for (index_hush, info_hush) in DataSource_Hush.seasonChallenges_Hush.enumerated() {
            let (season_hush, theme_hush, desc_hush, color_hush) = info_hush
            
            // 为每个挑战生成2条预制评论（复用帖子评论数据源）
            let commentIndex_hush = index_hush % DataSource_Hush.comments_Hush.count
            let (c1_hush, c2_hush) = DataSource_Hush.comments_Hush[commentIndex_hush]
            let users_hush = dataLocal_hush.userList_Hush
            guard users_hush.count >= 2 else { continue }
            let u1_hush = users_hush[index_hush % users_hush.count]
            let u2_hush = users_hush[(index_hush + 1) % users_hush.count]
            let preComments_hush = [
                Comment_Hush(commentId_Hush: index_hush * 2 + 1,
                             commentUserId_Hush: u1_hush.userId_Hush ?? 0,
                             commentUserName_Hush: u1_hush.userName_Hush ?? "",
                             commentContent_Hush: c1_hush),
                Comment_Hush(commentId_Hush: index_hush * 2 + 2,
                             commentUserId_Hush: u2_hush.userId_Hush ?? 0,
                             commentUserName_Hush: u2_hush.userName_Hush ?? "",
                             commentContent_Hush: c2_hush),
            ]
            
            let challenge_hush = SeasonChallengeModel_Hush(
                challengeId_hush: 100 + index_hush,
                season_hush: season_hush,
                theme_hush: theme_hush,
                challengeDescription_hush: desc_hush,
                coverColorHex_hush: color_hush,
                comments_hush: preComments_hush,
                participantCount_hush: 30 + Int.random(in: 1...200)
            )
            dataLocal_hush.seasonChallenges_Hush.append(challenge_hush)
        }
    }
    
    /// 初始化技巧提示卡数据
    func initTipCards_Hush() {
        guard let dataLocal_hush = dataLocal_Hush else { return }
        dataLocal_hush.tipCards_Hush = DataSource_Hush.tipCards_Hush.enumerated().map { (index_hush, info_hush) in
            let (title_hush, icon_hush, back_hush) = info_hush
            return TipCardModel_Hush(
                tipId_Hush: index_hush,
                frontTitle_Hush: title_hush,
                frontIcon_Hush: icon_hush,
                backContent_Hush: back_hush
            )
        }
    }
    
    /// 根据当天日期生成3张灵感卡（同一天内保持不变）
    /// - Returns: 3个 InspirationCardModel_Hush
    func generateDailyCards_Hush() -> [InspirationCardModel_Hush] {
        let pool_hush = DataSource_Hush.inspirationPool_Hush
        guard pool_hush.count >= 3 else { return [] }
        
        // 使用日期作为随机种子，保证同一天返回相同结果
        let calendar_hush = Calendar.current
        let today_hush = calendar_hush.startOfDay(for: Date())
        let daySeed_hush = Int(today_hush.timeIntervalSince1970 / 86400)
        
        var indices_hush: [Int] = []
        var seed_hush = daySeed_hush
        while indices_hush.count < 3 {
            seed_hush = (seed_hush &* 1664525 &+ 1013904223) & 0x7FFFFFFF
            let idx_hush = seed_hush % pool_hush.count
            if !indices_hush.contains(idx_hush) {
                indices_hush.append(idx_hush)
            }
        }
        
        return indices_hush.enumerated().map { (pos_hush, poolIndex_hush) in
            let (task_hush, icon_hush) = pool_hush[poolIndex_hush]
            return InspirationCardModel_Hush(
                cardId_Hush: poolIndex_hush,
                task_Hush: task_hush,
                iconName_Hush: icon_hush
            )
        }
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Hush() {
        guard let dataLocal_hush = dataLocal_Hush else { return }
        
        for i_hush in 0..<dataLocal_hush.userList_Hush.count {
            let user_hush = dataLocal_hush.userList_Hush[i_hush]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_hush = dataLocal_hush.getPostsExcludingUser_Hush(
                userId_hush: user_hush.userId_Hush ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_hush = RandomUtil_Hush.selectRandomItems_Hush(
                from: availablePosts_hush,
                count_hush: DataConfig_Hush.likePostCount_Hush
            )
            
            dataLocal_hush.userList_Hush[i_hush].userLike_Hush = likePosts_hush
        }
    }
}
