import SwiftUI

// MARK: - 发现页
// 核心作用：展示社区动态、挑战计划、热门榜单
// 设计思路：Tab分类切换、模块化布局、现代动感设计
// 关键功能：社区帖子展示、挑战管理、热门课程排行

/// Tab类型枚举
enum DiscoverTab_blisslink {
    case community_blisslink
    case badges_blisslink
}

/// 发现页
struct Discover_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    @ObservedObject var titleVM_baseswiftui = TitleViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var practiceVM_blisslink = PracticeViewModel_blisslink.shared_blisslink
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    // MARK: - 状态
    
    @State private var selectedTab_blisslink: DiscoverTab_blisslink = .community_blisslink
    @State private var showPostComposer_blisslink: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 顶部Tab栏
                topTabBar_blisslink
                
                // 内容区域
                TabView(selection: $selectedTab_blisslink) {
                    // 社区动态
                    communityTab_blisslink
                        .tag(DiscoverTab_blisslink.community_blisslink)
                    
                    // 徽章墙
                    badgesTab_blisslink
                        .tag(DiscoverTab_blisslink.badges_blisslink)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            // 悬浮发帖按钮（仅在社区Tab显示）
            if selectedTab_blisslink == .community_blisslink {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingPostButton_blisslink
                            .padding(.trailing, 20.w_baseswiftui)
                            .padding(.bottom, 90.h_baseswiftui)
                    }
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F7FAFC"),
                    Color(hex: "EDF2F7")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - 顶部Tab栏
    
    private var topTabBar_blisslink: some View {
        HStack(spacing: 0) {
            // Community Tab
            tabButton_blisslink(
                title_blisslink: "Community",
                tab_blisslink: .community_blisslink,
                isSelected_blisslink: selectedTab_blisslink == .community_blisslink
            )
            
            // Badges Tab
            tabButton_blisslink(
                title_blisslink: "Badges",
                tab_blisslink: .badges_blisslink,
                isSelected_blisslink: selectedTab_blisslink == .badges_blisslink
            )
        }
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.top, 16.h_baseswiftui)
        .background(Color.white)
    }
    
    /// Tab按钮
    private func tabButton_blisslink(title_blisslink: String, tab_blisslink: DiscoverTab_blisslink, isSelected_blisslink: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0)) {
                selectedTab_blisslink = tab_blisslink
            }
        }) {
            VStack(spacing: 8.h_baseswiftui) {
                Text(title_blisslink)
                    .font(.system(size: 16.sp_baseswiftui, weight: isSelected_blisslink ? .bold : .medium))
                    .foregroundColor(isSelected_blisslink ? .primary : .secondary)
                
                // 下划线
                Rectangle()
                    .fill(
                        isSelected_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3.h_baseswiftui)
                    .cornerRadius(1.5.h_baseswiftui)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 社区动态Tab
    
    private var communityTab_blisslink: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16.h_baseswiftui) {
                ForEach(Array(titleVM_baseswiftui.getPosts_baseswiftui().enumerated()), id: \.element.id) { index_blisslink, post_blisslink in
                    PostCardView_blisslink(
                        post_blisslink: post_blisslink,
                        onTap_blisslink: {
                            handlePostTap_blisslink(post_blisslink)
                        },
                        onLike_blisslink: {
                            // 点赞逻辑已在PostCardView内部处理
                        },
                        onComment_blisslink: {
                            handleComment_blisslink(post_blisslink)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .animation(
                        .spring(response: 0.55, dampingFraction: 0.8, blendDuration: 0)
                            .delay(Double(index_blisslink) * 0.06),
                        value: titleVM_baseswiftui.getPosts_baseswiftui().count
                    )
                }
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .padding(.top, 16.h_baseswiftui)
            .padding(.bottom, 100.h_baseswiftui)
        }
    }
    
    // MARK: - 徽章墙Tab
    
    @State private var selectedBadgeDiscover_blisslink: MeditationBadge_blisslink?
    @State private var showBadgeDetailDiscover_blisslink: Bool = false
    
    private var badgesTab_blisslink: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24.h_baseswiftui) {
                    // 徽章说明
                    VStack(spacing: 12.h_baseswiftui) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 50.sp_baseswiftui))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "F2994A"), Color(hex: "F2C94C")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Achievement Badges")
                            .font(.system(size: 22.sp_baseswiftui, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Complete practice milestones to unlock special badges")
                            .font(.system(size: 14.sp_baseswiftui))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40.w_baseswiftui)
                    }
                    .padding(.top, 30.h_baseswiftui)
                    
                    // 徽章网格
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 24.h_baseswiftui) {
                        ForEach(Array(localData_baseswiftui.badgeList_blisslink.enumerated()), id: \.element.id) { index_blisslink, badge_blisslink in
                            BadgeView_blisslink(
                                badge_blisslink: badge_blisslink,
                                size_blisslink: 70.w_baseswiftui,
                                showName_blisslink: true,
                                onTap_blisslink: {
                                    selectedBadgeDiscover_blisslink = badge_blisslink
                                    withAnimation {
                                        showBadgeDetailDiscover_blisslink = true
                                    }
                                }
                            )
                            .bounceIn_blisslink(delay_blisslink: Double(index_blisslink) * 0.08)
                        }
                    }
                    .padding(.horizontal, 20.w_baseswiftui)
                }
                .padding(.bottom, 100.h_baseswiftui)
            }
            
            // 徽章详情弹窗
            if showBadgeDetailDiscover_blisslink, let badge_blisslink = selectedBadgeDiscover_blisslink {
                BadgeDetailView_blisslink(
                    badge_blisslink: badge_blisslink,
                    onDismiss_blisslink: {
                        withAnimation {
                            showBadgeDetailDiscover_blisslink = false
                            selectedBadgeDiscover_blisslink = nil
                        }
                    }
                )
                .ignoresSafeArea(.all)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - 悬浮发帖按钮
    
    private var floatingPostButton_blisslink: some View {
        Button(action: {
            handleCreatePost_blisslink()
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60.w_baseswiftui, height: 60.h_baseswiftui)
                    .shadow(color: Color(hex: "667EEA").opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: "plus")
                    .font(.system(size: 24.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: showPostComposer_blisslink)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 事件处理
    
    /// 处理帖子点击
    private func handlePostTap_blisslink(_ post_blisslink: TitleModel_baseswiftui) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 跳转到帖子详情
        router_baseswiftui.toPostDetail_baseswiftui(post_baseswiftui: post_blisslink)
    }
    
    /// 处理评论
    private func handleComment_blisslink(_ post_blisslink: TitleModel_baseswiftui) {
        // 跳转到帖子详情的评论区
        router_baseswiftui.toPostDetail_baseswiftui(post_baseswiftui: post_blisslink)
    }
    
    /// 处理创建帖子
    private func handleCreatePost_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        // 跳转到发布页面
        router_baseswiftui.toRelease_baseswiftui()
    }
}
