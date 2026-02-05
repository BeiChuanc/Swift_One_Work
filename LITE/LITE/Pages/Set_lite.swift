import SwiftUI

// MARK: - 设置页
// 核心作用：应用设置和账户管理
// 设计思路：现代化卡片设计，清晰的功能分组，强调危险操作
// 关键功能：协议查看、登出、删除账号

/// 设置页
struct Set_lite: View {
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    
    @State private var showTerms_lite = false
    @State private var showPrivacy_lite = false
    @State private var showLogoutAlert_lite = false
    @State private var showDeleteAlert_lite = false
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "667eea").opacity(0.06),
                        Color(hex: "F8F9FA"),
                        Color(hex: "f093fb").opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰圆圈
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "f093fb").opacity(0.08), Color.clear],
                            center: .topTrailing,
                            startRadius: 0,
                            endRadius: 200.w_lite
                        )
                    )
                    .frame(width: 300.w_lite, height: 300.h_lite)
                    .offset(x: UIScreen.main.bounds.width - 100.w_lite, y: -80.h_lite)
                    .blur(radius: 30)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 自定义顶部导航栏
                customHeaderView_lite
                
                ScrollView {
                    VStack(spacing: 24.h_lite) {
                        // 协议区域
                        legalSection_lite
                        
                        // 账户管理区域
                        accountSection_lite
                    }
                    .padding(.horizontal, 20.w_lite)
                    .padding(.top, 24.h_lite)
                    .padding(.bottom, 40.h_lite)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTerms_lite) {
            NavigationStack {
                ProtocolContentView_lite(
                    type_lite: .terms_lite,
                    content_lite: "terms.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showTerms_lite = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPrivacy_lite) {
            NavigationStack {
                ProtocolContentView_lite(
                    type_lite: .privacy_lite,
                    content_lite: "privacy.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showPrivacy_lite = false
                        }
                    }
                }
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert_lite) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                userVM_lite.logout_lite(logoutType_lite: .logout_lite)
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert_lite) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                userVM_lite.logout_lite(logoutType_lite: .delete_lite)
            }
        } message: {
            Text("This action cannot be undone. Your account will be permanently deleted after 24 hours.")
        }
    }
    
    // MARK: - 自定义顶部导航栏
    
    /// 自定义顶部导航栏
    private var customHeaderView_lite: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12.w_lite) {
                // 返回按钮（增强版）
                Button {
                    router_lite.pop_lite()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color(hex: "F8F9FA")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44.w_lite, height: 44.h_lite)
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb").opacity(0.3), Color(hex: "f5576c").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "f093fb").opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle_lite())
                
                // 页面标题
                VStack(alignment: .leading, spacing: 4.h_lite) {
                    Text("Settings")
                        .font(.system(size: 28.sp_lite, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "212529"), Color(hex: "495057")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Manage your account")
                        .font(.system(size: 13.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "6C757D"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20.w_lite)
            .padding(.top, 12.h_lite)
            .padding(.bottom, 16.h_lite)
            .background(
                Color.white
                    .ignoresSafeArea(edges: .top)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - 协议区域
    
    /// 协议区域
    private var legalSection_lite: some View {
        VStack(spacing: 12.h_lite) {
            // 区域标题
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Legal & Privacy")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
            }
            .padding(.horizontal, 4.w_lite)
            
            VStack(spacing: 0) {
                // Terms按钮
                ProtocolButton_lite(
                    title_lite: "Terms of Service",
                    icon_lite: "doc.plaintext",
                    showDivider_lite: true,
                    onTap_lite: {
                        showTerms_lite = true
                    }
                )
                
                // Privacy按钮
                ProtocolButton_lite(
                    title_lite: "Privacy Policy",
                    icon_lite: "hand.raised.fill",
                    showDivider_lite: false,
                    onTap_lite: {
                        showPrivacy_lite = true
                    }
                )
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.8), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .stroke(Color(hex: "E9ECEF"), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
        }
    }
    
    // MARK: - 账户管理区域
    
    /// 账户管理区域
    private var accountSection_lite: some View {
        VStack(spacing: 12.h_lite) {
            // 区域标题
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "f5576c"))
                
                Text("Account Management")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Spacer()
            }
            .padding(.horizontal, 4.w_lite)
            
            VStack(spacing: 16.h_lite) {
                // 登出按钮
                DangerButton_lite(
                    icon_lite: "arrow.right.square",
                    title_lite: "Logout",
                    subtitle_lite: "Sign out of your account",
                    colors_lite: [Color(hex: "f093fb"), Color(hex: "667eea")],
                    onTap_lite: {
                        showLogoutAlert_lite = true
                    }
                )
                
                // 删除账号按钮
                DangerButton_lite(
                    icon_lite: "trash.circle.fill",
                    title_lite: "Delete Account",
                    subtitle_lite: "Permanently remove your account",
                    colors_lite: [Color(hex: "f5576c"), Color(hex: "ff9a9e")],
                    onTap_lite: {
                        showDeleteAlert_lite = true
                    }
                )
            }
        }
    }
}

// MARK: - 协议按钮组件

/// 协议按钮
struct ProtocolButton_lite: View {
    
    let title_lite: String
    let icon_lite: String
    let showDivider_lite: Bool
    let onTap_lite: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap_lite) {
                HStack(spacing: 12.w_lite) {
                    Image(systemName: icon_lite)
                        .font(.system(size: 18.sp_lite, weight: .semibold))
                        .foregroundColor(Color(hex: "667eea"))
                        .frame(width: 28.w_lite)
                    
                    Text(title_lite)
                        .font(.system(size: 16.sp_lite, weight: .semibold))
                        .foregroundColor(Color(hex: "212529"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13.sp_lite, weight: .semibold))
                        .foregroundColor(Color(hex: "ADB5BD"))
                }
                .padding(.horizontal, 18.w_lite)
                .padding(.vertical, 16.h_lite)
            }
            
            if showDivider_lite {
                Rectangle()
                    .fill(Color(hex: "E9ECEF"))
                    .frame(height: 1)
                    .padding(.horizontal, 18.w_lite)
            }
        }
    }
}

// MARK: - 危险操作按钮组件

/// 危险操作按钮
struct DangerButton_lite: View {
    
    let icon_lite: String
    let title_lite: String
    let subtitle_lite: String
    let colors_lite: [Color]
    let onTap_lite: () -> Void
    
    @State private var isPressed_lite = false
    
    var body: some View {
        Button(action: onTap_lite) {
            HStack(spacing: 16.w_lite) {
                // 图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colors_lite.map { $0.opacity(0.15) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50.w_lite, height: 50.h_lite)
                    
                    Image(systemName: icon_lite)
                        .font(.system(size: 22.sp_lite, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: colors_lite,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: colors_lite[0].opacity(0.3), radius: 8, x: 0, y: 4)
                
                // 文字
                VStack(alignment: .leading, spacing: 4.h_lite) {
                    Text(title_lite)
                        .font(.system(size: 17.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "212529"))
                    
                    Text(subtitle_lite)
                        .font(.system(size: 13.sp_lite, weight: .medium))
                        .foregroundColor(Color(hex: "ADB5BD"))
                }
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14.sp_lite, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors_lite,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(18.w_lite)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "FAFBFC")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.8), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .stroke(
                        LinearGradient(
                            colors: colors_lite.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
            .shadow(color: colors_lite[0].opacity(0.2), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed_lite ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed_lite = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed_lite = false
                    }
                }
        )
    }
}
