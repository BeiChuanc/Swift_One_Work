import SwiftUI
import Combine

// MARK: - 首页
// 核心作用：展示今日穿搭推荐和用户穿搭时光轴
// 设计思路：分为两个核心模块 - 速推和时光轴，使用现代化卡片设计
// 关键功能：智能推荐、收藏穿搭、标记当日穿搭、时光轴记忆

/// 首页主视图
struct Home_lite: View {
    
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var selectedScene_lite: OutfitScene_lite = .daily_lite
    @State private var todayRecommendations_lite: [OutfitCombo_lite] = []
    @State private var showScenePicker_lite = false
    @State private var showAddOutfitSheet_lite = false
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            AnimatedGradientBackground_lite()
                .ignoresSafeArea()
            
            // 装饰性浮动圆圈
            FloatingCircles_lite()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28.h_lite) {
                    // 顶部导航栏
                    headerView_lite
                        .padding(.horizontal, 20.w_lite)
                        .padding(.top, 10.h_lite)
                    
                    // 今日轻搭速推模块
                    todayRecommendationSection_lite
                    
                    // 我的穿搭时光轴模块
                    timelineSection_lite
                }
                .padding(.bottom, 100.h_lite)
            }
        }
        .onAppear {
            loadRecommendations_lite()
        }
        .onReceive(localData_lite.objectWillChange) { _ in
            // 监听数据变化，自动刷新推荐列表
            loadRecommendations_lite()
        }
        .sheet(isPresented: $showAddOutfitSheet_lite) {
            AddToTimelineSheet_lite()
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var headerView_lite: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6.h_lite) {
                // 添加装饰图标
                HStack(spacing: 8.w_lite) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "FFD700"))
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 4)
                    
                    Text("Outfit Daily")
                        .font(.system(size: 32.sp_lite, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Text("Your style journey starts here")
                    .font(.system(size: 14.sp_lite, weight: .medium))
                    .foregroundColor(Color(hex: "495057"))
            }
            
            Spacer()
            
            // 场景选择按钮 - 增强版
            Button {
                showScenePicker_lite.toggle()
            } label: {
                HStack(spacing: 8.w_lite) {
                    Image(systemName: sceneIcon_lite(for: selectedScene_lite))
                        .font(.system(size: 18.sp_lite, weight: .bold))
                    
                    Text(selectedScene_lite.rawValue)
                        .font(.system(size: 14.sp_lite, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18.w_lite)
                .padding(.vertical, 12.h_lite)
                .background(
                    ZStack {
                        // 渐变背景
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // 光泽效果
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .cornerRadius(25.w_lite)
                .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 25.w_lite)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle_lite())
        }
        .actionSheet(isPresented: $showScenePicker_lite) {
            ActionSheet(
                title: Text("Select Scene"),
                message: Text("Choose your outfit scene"),
                buttons: OutfitScene_lite.allCases.map { scene_lite in
                    .default(Text(scene_lite.rawValue)) {
                        selectedScene_lite = scene_lite
                        loadRecommendations_lite()
                    }
                } + [.cancel()]
            )
        }
    }
    
    // MARK: - 今日轻搭速推模块
    
    private var todayRecommendationSection_lite: some View {
        VStack(alignment: .leading, spacing: 16.h_lite) {
            // 模块标题
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Today's Quick Picks")
                    .font(.system(size: 22.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        loadRecommendations_lite()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16.sp_lite, weight: .semibold))
                        .foregroundColor(Color(hex: "667eea"))
                        .rotationEffect(.degrees(todayRecommendations_lite.isEmpty ? 0 : 360))
                        .animation(.easeInOut(duration: 0.5), value: todayRecommendations_lite.count)
                }
            }
            .padding(.horizontal, 20.w_lite)
            
            // 推荐卡片列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16.w_lite) {
                    ForEach(todayRecommendations_lite) { outfit_lite in
                        OutfitRecommendationCard_lite(
                            outfit_lite: outfit_lite,
                            onFavorite_lite: {
                                titleVM_lite.favoriteOutfit_lite(outfit_lite: outfit_lite)
                            },
                            onAddToTimeline_lite: {
                                addToTimeline_lite(outfit_lite: outfit_lite)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20.w_lite)
            }
        }
    }
    
    // MARK: - 我的穿搭时光轴模块
    
    private var timelineSection_lite: some View {
        VStack(alignment: .leading, spacing: 16.h_lite) {
            // 模块标题
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "f093fb"))
                
                Text(userVM_lite.isLoggedIn_lite ? "My Style Timeline" : "Style Timeline Preview")
                    .font(.system(size: 22.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
                
                if userVM_lite.isLoggedIn_lite {
                    Button {
                        // 显示选择穿搭对话框
                        showAddToTimelineSheet_lite()
                    } label: {
                        HStack(spacing: 4.w_lite) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14.sp_lite, weight: .semibold))
                            
                            Text("Add Outfit")
                                .font(.system(size: 14.sp_lite, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "f093fb"))
                    }
                }
            }
            .padding(.horizontal, 20.w_lite)
            
            // 时光轴卡片列表 - 使用登录用户的时光轴数据
            if userVM_lite.isLoggedIn_lite {
                let userTimeline_lite = userVM_lite.getUserTimeline_lite()
                
                if !userTimeline_lite.isEmpty {
                    // 已登录且有数据
                    ForEach(userTimeline_lite.prefix(3)) { timeline_lite in
                        TimelineCard_lite(outfit_lite: timeline_lite.outfit_lite)
                            .padding(.horizontal, 20.w_lite)
                    }
                } else {
                    // 已登录但没有数据
                    emptyTimelineView_lite
                }
            } else {
                // 未登录，显示优化的空状态视图
                notLoggedInTimelineView_lite
            }
        }
    }
    
    // MARK: - 空状态视图
    
    /// 空时光轴视图（已登录用户）
    private var emptyTimelineView_lite: some View {
        VStack(spacing: 24.h_lite) {
            // 图标背景
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "f093fb").opacity(0.2), Color(hex: "f5576c").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120.w_lite, height: 120.h_lite)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "f093fb").opacity(0.15), Color(hex: "f5576c").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100.w_lite, height: 100.h_lite)
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 50.sp_lite, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 20.h_lite)
            
            VStack(spacing: 12.h_lite) {
                Text("No timeline yet")
                    .font(.system(size: 22.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text("Mark your outfits as \"Today\" to create memories")
                    .font(.system(size: 15.sp_lite, weight: .regular))
                    .foregroundColor(Color(hex: "6C757D"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40.w_lite)
            }
            
            // 操作提示卡片
            VStack(spacing: 12.h_lite) {
                HStack(spacing: 12.w_lite) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "667eea").opacity(0.15))
                            .frame(width: 44.w_lite, height: 44.h_lite)
                        
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "667eea"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4.h_lite) {
                        Text("Click \"Today\" button")
                            .font(.system(size: 14.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "212529"))
                        
                        Text("Add outfits to your timeline")
                            .font(.system(size: 12.sp_lite, weight: .regular))
                            .foregroundColor(Color(hex: "6C757D"))
                    }
                    
                    Spacer()
                }
                .padding(16.w_lite)
                .background(
                    RoundedRectangle(cornerRadius: 16.w_lite)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16.w_lite)
                        .stroke(Color(hex: "667eea").opacity(0.2), lineWidth: 1.5)
                )
            }
            .padding(.horizontal, 20.w_lite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30.h_lite)
    }
    
    /// 未登录时的空状态视图
    private var notLoggedInTimelineView_lite: some View {
        VStack(spacing: 24.h_lite) {
            // 图标背景
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120.w_lite, height: 120.h_lite)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.15), Color(hex: "764ba2").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100.w_lite, height: 100.h_lite)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50.sp_lite, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 20.h_lite)
            
            VStack(spacing: 12.h_lite) {
                Text("Sign in to view your timeline")
                    .font(.system(size: 22.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text("Track your style journey and create lasting memories with your favorite outfits")
                    .font(.system(size: 15.sp_lite, weight: .regular))
                    .foregroundColor(Color(hex: "6C757D"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40.w_lite)
            }
            
            // 登录按钮
            Button {
                Router_lite.shared_lite.toLogin_liteui()
            } label: {
                HStack(spacing: 12.w_lite) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20.sp_lite, weight: .bold))
                    
                    Text("Sign in now")
                        .font(.system(size: 17.sp_lite, weight: .bold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16.sp_lite, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18.h_lite)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // 高光效果
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .cornerRadius(16.w_lite)
                .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(ScaleButtonStyle_lite())
            .padding(.horizontal, 40.w_lite)
            
            // 功能介绍卡片
            VStack(spacing: 12.h_lite) {
                featureItem_lite(
                    icon: "calendar.badge.checkmark",
                    title: "Track Daily Outfits",
                    description: "Mark your favorite looks",
                    color: Color(hex: "667eea")
                )
                
                featureItem_lite(
                    icon: "photo.on.rectangle.angled",
                    title: "Visual Memories",
                    description: "Save outfit moments",
                    color: Color(hex: "f093fb")
                )
                
                featureItem_lite(
                    icon: "sparkles",
                    title: "Style Evolution",
                    description: "Watch your style grow",
                    color: Color(hex: "43e97b")
                )
            }
            .padding(.horizontal, 20.w_lite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30.h_lite)
    }
    
    /// 功能介绍项
    private func featureItem_lite(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 12.w_lite) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44.w_lite, height: 44.h_lite)
                
                Image(systemName: icon)
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4.h_lite) {
                Text(title)
                    .font(.system(size: 14.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text(description)
                    .font(.system(size: 12.sp_lite, weight: .regular))
                    .foregroundColor(Color(hex: "6C757D"))
            }
            
            Spacer()
        }
        .padding(14.w_lite)
        .background(
            RoundedRectangle(cornerRadius: 14.w_lite)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14.w_lite)
                .stroke(color.opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 辅助方法
    
    /// 加载今日推荐
    private func loadRecommendations_lite() {
        todayRecommendations_lite = titleVM_lite.getTodayRecommendations_lite(scene_lite: selectedScene_lite)
    }
    
    /// 获取场景图标
    private func sceneIcon_lite(for scene_lite: OutfitScene_lite) -> String {
        switch scene_lite {
        case .daily_lite: return "house.fill"
        case .work_lite: return "briefcase.fill"
        case .date_lite: return "heart.fill"
        case .party_lite: return "party.popper.fill"
        case .sport_lite: return "figure.run"
        }
    }
    
    /// 添加穿搭到时光轴
    private func addToTimeline_lite(outfit_lite: OutfitCombo_lite) {
        userVM_lite.addOutfitToTimeline_lite(outfit_lite: outfit_lite)
    }
    
    /// 显示添加到时光轴的Sheet
    private func showAddToTimelineSheet_lite() {
        showAddOutfitSheet_lite = true
    }
}

// MARK: - 添加到时光轴Sheet

/// 添加穿搭到时光轴的Sheet视图
struct AddToTimelineSheet_lite: View {
    
    @Environment(\.dismiss) private var dismiss_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var localData_lite = LocalData_lite.shared_lite
    
    @State private var selectedOutfit_lite: OutfitCombo_lite?
    @State private var noteText_lite = ""
    @State private var memoryTag_lite = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [
                        Color(hex: "f093fb").opacity(0.05),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24.h_lite) {
                        // 选择穿搭
                        VStack(alignment: .leading, spacing: 12.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "tshirt.fill")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "f093fb"))
                                
                                Text("Select Outfit")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12.w_lite) {
                                    ForEach(localData_lite.outfitComboList_lite.prefix(10)) { outfit_lite in
                                        OutfitSelectionCard_lite(
                                            outfit_lite: outfit_lite,
                                            isSelected_lite: selectedOutfit_lite?.comboId_lite == outfit_lite.comboId_lite,
                                            onSelect_lite: {
                                                selectedOutfit_lite = outfit_lite
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 4.w_lite)
                            }
                        }
                        
                        // 备注（可选）
                        VStack(alignment: .leading, spacing: 10.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "667eea"))
                                
                                Text("Note (Optional)")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            TextField("Add a note...", text: $noteText_lite, axis: .vertical)
                                .font(.system(size: 15.sp_lite, weight: .medium))
                                .padding(16.w_lite)
                                .lineLimit(1...3)
                                .background(Color.white)
                                .cornerRadius(12.w_lite)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12.w_lite)
                                        .stroke(Color(hex: "E9ECEF"), lineWidth: 1.5)
                                )
                        }
                        
                        // 纪念标签（可选）
                        VStack(alignment: .leading, spacing: 10.h_lite) {
                            HStack(spacing: 6.w_lite) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 14.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "FFC107"))
                                
                                Text("Memory Tag (Optional)")
                                    .font(.system(size: 15.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "495057"))
                            }
                            
                            TextField("e.g., First date outfit", text: $memoryTag_lite)
                                .font(.system(size: 15.sp_lite, weight: .medium))
                                .padding(16.w_lite)
                                .background(Color.white)
                                .cornerRadius(12.w_lite)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12.w_lite)
                                        .stroke(Color(hex: "E9ECEF"), lineWidth: 1.5)
                                )
                        }
                        
                        // 添加按钮
                        Button {
                            addSelectedOutfit_lite()
                        } label: {
                            HStack(spacing: 10.w_lite) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 18.sp_lite, weight: .bold))
                                
                                Text("Add to Timeline")
                                    .font(.system(size: 16.sp_lite, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16.h_lite)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16.w_lite)
                            .shadow(color: Color(hex: "f093fb").opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .buttonStyle(ScaleButtonStyle_lite())
                        .disabled(selectedOutfit_lite == nil)
                        .opacity(selectedOutfit_lite == nil ? 0.5 : 1.0)
                    }
                    .padding(20.w_lite)
                }
            }
            .navigationTitle("Add to Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss_lite()
                    }
                }
            }
        }
    }
    
    /// 添加选中的穿搭
    private func addSelectedOutfit_lite() {
        guard let outfit_lite = selectedOutfit_lite else { return }
        
        let note_lite = noteText_lite.trimmingCharacters(in: .whitespacesAndNewlines)
        let tag_lite = memoryTag_lite.trimmingCharacters(in: .whitespacesAndNewlines)
        
        userVM_lite.addOutfitToTimeline_lite(
            outfit_lite: outfit_lite,
            note_lite: note_lite.isEmpty ? nil : note_lite,
            memoryTag_lite: tag_lite.isEmpty ? nil : tag_lite
        )
        
        dismiss_lite()
    }
}

// MARK: - 穿搭选择卡片

/// 穿搭选择卡片
struct OutfitSelectionCard_lite: View {
    
    let outfit_lite: OutfitCombo_lite
    let isSelected_lite: Bool
    let onSelect_lite: () -> Void
    
    var body: some View {
        Button(action: onSelect_lite) {
            VStack(alignment: .leading, spacing: 10.h_lite) {
                // 单品图标
                HStack(spacing: 6.w_lite) {
                    ForEach(outfit_lite.items_lite.prefix(3)) { item_lite in
                        Image(systemName: item_lite.itemImage_lite)
                            .font(.system(size: 16.sp_lite, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32.w_lite, height: 32.h_lite)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: MediaConfig_lite.getGradientColors_lite(for: item_lite.itemName_lite),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                }
                
                Text(outfit_lite.comboTitle_lite)
                    .font(.system(size: 14.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // 选中标记
                if isSelected_lite {
                    HStack(spacing: 4.w_lite) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12.sp_lite))
                            .foregroundColor(Color(hex: "43e97b"))
                        
                        Text("Selected")
                            .font(.system(size: 11.sp_lite, weight: .bold))
                            .foregroundColor(Color(hex: "43e97b"))
                    }
                }
            }
            .padding(14.w_lite)
            .frame(width: 140.w_lite, height: 120.h_lite, alignment: .topLeading)
            .background(
                isSelected_lite ?
                    LinearGradient(
                        colors: [Color(hex: "f093fb").opacity(0.1), Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(colors: [Color.white, Color.white], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(16.w_lite)
            .overlay(
                RoundedRectangle(cornerRadius: 16.w_lite)
                    .stroke(
                        isSelected_lite ? Color(hex: "f093fb") : Color(hex: "E9ECEF"),
                        lineWidth: isSelected_lite ? 2 : 1.5
                    )
            )
            .shadow(
                color: isSelected_lite ? Color(hex: "f093fb").opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected_lite ? 12 : 6,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(ScaleButtonStyle_lite())
    }
}

// MARK: - 穿搭推荐卡片组件

/// 穿搭推荐卡片 - 增强版
struct OutfitRecommendationCard_lite: View {
    
    let outfit_lite: OutfitCombo_lite
    let onFavorite_lite: () -> Void
    let onAddToTimeline_lite: () -> Void
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @State private var isPressed_lite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 上半部分：单品展示 - 增强版
            ZStack {
                // 动态渐变背景
                LinearGradient(
                    colors: MediaConfig_lite.getGradientColors_lite(for: outfit_lite.comboTitle_lite) + [
                        MediaConfig_lite.getGradientColors_lite(for: outfit_lite.comboTitle_lite)[0].opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰性图案
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120.w_lite, height: 120.h_lite)
                    .offset(x: -40.w_lite, y: -30.h_lite)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80.w_lite, height: 80.h_lite)
                    .offset(x: 60.w_lite, y: 40.h_lite)
                    .blur(radius: 15)
                
                // 单品网格 - 更大更突出
                HStack(spacing: 12.w_lite) {
                    ForEach(outfit_lite.items_lite.prefix(3)) { item_lite in
                        VStack {
                            Image(systemName: item_lite.itemImage_lite)
                                .font(.system(size: 38.sp_lite, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 70.w_lite, height: 70.h_lite)
                                .background(
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.25))
                                        
                                        Circle()
                                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }
                }
            }
            .frame(width: 300.w_lite, height: 180.h_lite)
            
            // 下半部分：信息和操作
            VStack(alignment: .leading, spacing: 14.h_lite) {
                VStack(alignment: .leading, spacing: 8.h_lite) {
                    Text(outfit_lite.comboTitle_lite)
                        .font(.system(size: 19.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                    
                    Text(outfit_lite.comboDescription_lite)
                        .font(.system(size: 13.sp_lite, weight: .regular))
                        .foregroundColor(Color(hex: "6C757D"))
                        .lineLimit(2)
                        .lineSpacing(2)
                }
                
                // 标签 - 增强版
                HStack(spacing: 8.w_lite) {
                    EnhancedTagView_lite(
                        text_lite: outfit_lite.style_lite.rawValue,
                        icon_lite: "paintbrush.fill",
                        color_lite: Color(hex: "667eea")
                    )
                    EnhancedTagView_lite(
                        text_lite: outfit_lite.scene_lite.rawValue,
                        icon_lite: "location.fill",
                        color_lite: Color(hex: "f093fb")
                    )
                }
                
                // 操作按钮 - 增强版
                HStack(spacing: 12.w_lite) {
                    Button(action: onFavorite_lite) {
                        HStack(spacing: 6.w_lite) {
                            Image(systemName: outfit_lite.isFavorited_lite ? "heart.fill" : "heart")
                                .font(.system(size: 15.sp_lite, weight: .bold))
                            Text("Favorite")
                                .font(.system(size: 13.sp_lite, weight: .bold))
                        }
                        .foregroundColor(outfit_lite.isFavorited_lite ? .white : Color(hex: "f5576c"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12.h_lite)
                        .background(
                            outfit_lite.isFavorited_lite ?
                            LinearGradient(
                                colors: [Color(hex: "f5576c"), Color(hex: "f093fb")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color(hex: "FFF5F5"), Color(hex: "FFF5F5")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12.w_lite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12.w_lite)
                                .stroke(Color(hex: "f5576c").opacity(outfit_lite.isFavorited_lite ? 0 : 0.3), lineWidth: 1.5)
                        )
                        .shadow(
                            color: outfit_lite.isFavorited_lite ? Color(hex: "f5576c").opacity(0.3) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .buttonStyle(ScaleButtonStyle_lite())
                    
                    Button {
                        onAddToTimeline_lite()
                    } label: {
                        HStack(spacing: 6.w_lite) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 15.sp_lite, weight: .bold))
                            Text("Today")
                                .font(.system(size: 13.sp_lite, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12.h_lite)
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // 高光效果
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .cornerRadius(12.w_lite)
                        .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle_lite())
                }
            }
            .padding(18.w_lite)
            .background(
                ZStack {
                    Color.white
                    
                    // 玻璃态效果
                    LinearGradient(
                        colors: [Color.white, Color(hex: "F8F9FA")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
        }
        .frame(width: 300.w_lite)
        .cornerRadius(24.w_lite)
        .overlay(
            RoundedRectangle(cornerRadius: 24.w_lite)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 12)
        .shadow(color: MediaConfig_lite.getGradientColors_lite(for: outfit_lite.comboTitle_lite)[0].opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

// MARK: - 时光轴卡片组件

/// 时光轴卡片
struct TimelineCard_lite: View {
    
    let outfit_lite: OutfitCombo_lite
    
    var body: some View {
        HStack(spacing: 16.w_lite) {
            // 时间轴指示器
            VStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 12.w_lite, height: 12.h_lite)
                
                Rectangle()
                    .fill(Color(hex: "E9ECEF"))
                    .frame(width: 2.w_lite)
            }
            
            // 卡片内容
            VStack(alignment: .leading, spacing: 12.h_lite) {
                HStack {
                    Text(dateFormatter_lite.string(from: outfit_lite.createDate_lite))
                        .font(.system(size: 12.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 12.sp_lite))
                        .foregroundColor(Color(hex: "FFC107"))
                }
                
                Text(outfit_lite.comboTitle_lite)
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text(outfit_lite.comboDescription_lite)
                    .font(.system(size: 13.sp_lite, weight: .regular))
                    .foregroundColor(Color(hex: "6C757D"))
                    .lineLimit(2)
                
                // 单品缩略图
                HStack(spacing: 8.w_lite) {
                    ForEach(outfit_lite.items_lite.prefix(3)) { item_lite in
                        Image(systemName: item_lite.itemImage_lite)
                            .font(.system(size: 16.sp_lite))
                            .foregroundColor(.white)
                            .frame(width: 36.w_lite, height: 36.h_lite)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: MediaConfig_lite.getGradientColors_lite(for: item_lite.itemName_lite),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4.w_lite) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12.sp_lite))
                            .foregroundColor(Color(hex: "f5576c"))
                        
                        Text("\(outfit_lite.likes_lite)")
                            .font(.system(size: 12.sp_lite, weight: .medium))
                            .foregroundColor(Color(hex: "6C757D"))
                    }
                }
            }
            .padding(16.w_lite)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16.w_lite)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
    
    private var dateFormatter_lite: DateFormatter {
        let formatter_lite = DateFormatter()
        formatter_lite.dateFormat = "MMM dd, yyyy"
        return formatter_lite
    }
}

// MARK: - 标签组件

/// 标签视图
struct TagView_lite: View {
    
    let text_lite: String
    let color_lite: Color
    
    var body: some View {
        Text(text_lite)
            .font(.system(size: 11.sp_lite, weight: .semibold))
            .foregroundColor(color_lite)
            .padding(.horizontal, 10.w_lite)
            .padding(.vertical, 5.h_lite)
            .background(color_lite.opacity(0.15))
            .cornerRadius(8.w_lite)
    }
}

/// 增强版标签视图
struct EnhancedTagView_lite: View {
    
    let text_lite: String
    let icon_lite: String
    let color_lite: Color
    
    var body: some View {
        HStack(spacing: 4.w_lite) {
            Image(systemName: icon_lite)
                .font(.system(size: 10.sp_lite, weight: .bold))
            
            Text(text_lite)
                .font(.system(size: 11.sp_lite, weight: .bold))
        }
        .foregroundColor(color_lite)
        .padding(.horizontal, 12.w_lite)
        .padding(.vertical, 6.h_lite)
        .background(
            ZStack {
                Capsule()
                    .fill(color_lite.opacity(0.15))
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            Capsule()
                .stroke(color_lite.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - 动态背景组件

/// 动态渐变背景
struct AnimatedGradientBackground_lite: View {
    
    @State private var animateGradient_lite = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "667eea"),
                Color(hex: "764ba2"),
                Color(hex: "f093fb"),
                Color(hex: "667eea")
            ],
            startPoint: animateGradient_lite ? .topLeading : .bottomLeading,
            endPoint: animateGradient_lite ? .bottomTrailing : .topTrailing
        )
        .opacity(0.15)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient_lite.toggle()
            }
        }
    }
}

/// 浮动装饰圆圈
struct FloatingCircles_lite: View {
    
    @State private var animate1_lite = false
    @State private var animate2_lite = false
    @State private var animate3_lite = false
    
    var body: some View {
        ZStack {
            // 圆圈1
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "667eea").opacity(0.3), Color(hex: "764ba2").opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200.w_lite, height: 200.h_lite)
                .blur(radius: 30)
                .offset(
                    x: animate1_lite ? -50.w_lite : 50.w_lite,
                    y: animate1_lite ? -100.h_lite : -50.h_lite
                )
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate1_lite)
            
            // 圆圈2
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "f093fb").opacity(0.25), Color(hex: "f5576c").opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 250.w_lite, height: 250.h_lite)
                .blur(radius: 40)
                .offset(
                    x: animate2_lite ? UIScreen.main.bounds.width - 100.w_lite : UIScreen.main.bounds.width - 200.w_lite,
                    y: animate2_lite ? 300.h_lite : 200.h_lite
                )
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate2_lite)
            
            // 圆圈3
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFD700").opacity(0.2), Color(hex: "FFA500").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180.w_lite, height: 180.h_lite)
                .blur(radius: 35)
                .offset(
                    x: animate3_lite ? 100.w_lite : 50.w_lite,
                    y: animate3_lite ? UIScreen.main.bounds.height - 300.h_lite : UIScreen.main.bounds.height - 400.h_lite
                )
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate3_lite)
        }
        .onAppear {
            animate1_lite = true
            animate2_lite = true
            animate3_lite = true
        }
    }
}
