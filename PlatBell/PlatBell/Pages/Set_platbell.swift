import SwiftUI

// MARK: - 设置页
// 核心作用：应用设置和偏好配置
// 设计思路：现代化设计 + Terms + Privacy + 登出 + 删除账号
// 关键功能：协议查看、账户管理、安全退出

/// 设置页
struct Set_platbell: View {
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 是否显示Terms
    @State private var showTerms_platbell = false
    
    /// 是否显示Privacy
    @State private var showPrivacy_platbell = false
    
    /// 是否显示登出确认
    @State private var showLogoutAlert_platbell = false
    
    /// 是否显示删除账号确认
    @State private var showDeleteAlert_platbell = false
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundView_platbell
            
            ScrollView {
                VStack(spacing: 24) {
                    // 顶部标题
                    headerView_platbell
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                    
                    // Legal & Privacy 区域
                    legalSection_platbell
                        .padding(.horizontal, 16)
                    
                    // 账户管理区域
                    accountSection_platbell
                        .padding(.horizontal, 16)

                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showTerms_platbell) {
            NavigationStack {
                ProtocolContentView_platbell(
                    type_platbell: .terms_platbell,
                    content_platbell: "terms.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showTerms_platbell = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPrivacy_platbell) {
            NavigationStack {
                ProtocolContentView_platbell(
                    type_platbell: .privacy_platbell,
                    content_platbell: "privacy.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showPrivacy_platbell = false
                        }
                    }
                }
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert_platbell) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                handleLogout_platbell()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert_platbell) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                handleDeleteAccount_platbell()
            }
        } message: {
            Text("This action cannot be undone. Are you sure you want to delete your account?")
        }
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.accentBlueStart_platbell.opacity(0.08),
                ThemeColors_platbell.primaryStart_platbell.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 顶部标题
    private var headerView_platbell: some View {
        HStack(alignment: .center, spacing: 12) {
            // 返回按钮
            Button(action: {
                router_platbell.pop_platbell()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            ThemeColors_platbell.accentBlueStart_platbell.opacity(0.12)
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ThemeColors_platbell.accentBlueStart_platbell)
                }
            }
            .shadow(
                color: ThemeColors_platbell.accentBlueStart_platbell.opacity(0.2),
                radius: 6,
                x: 0,
                y: 3
            )
            
            // 装饰性图标
            ZStack {
                Circle()
                    .fill(
                        ThemeColors_platbell.gradient_platbell(at: 4)
                            .opacity(0.2)
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        ThemeColors_platbell.gradient_platbell(at: 4)
                    )
                    .rotationEffect(.degrees(0))
                    .continuousRotation_platbell(duration_platbell: 8.0)
            }
            .shadow(
                color: ThemeColors_platbell.warmStart_platbell.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                    .gradientText_platbell(gradientIndex_platbell: 4)
                
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(ThemeColors_platbell.warmStart_platbell)
                    
                    Text("Manage your account")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    /// Legal & Privacy 区域
    private var legalSection_platbell: some View {
        VStack(spacing: 12) {
            // 区域标题
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 3))
                
                Text("Legal & Privacy")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                // Terms按钮
                SettingButton_platbell(
                    title_platbell: "Terms of Service",
                    icon_platbell: "doc.plaintext",
                    showDivider_platbell: true,
                    onTap_platbell: {
                        showTerms_platbell = true
                    }
                )
                
                // Privacy按钮
                SettingButton_platbell(
                    title_platbell: "Privacy Policy",
                    icon_platbell: "hand.raised.fill",
                    showDivider_platbell: false,
                    onTap_platbell: {
                        showPrivacy_platbell = true
                    }
                )
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                    
                    RoundedRectangle(cornerRadius: 20)
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
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ThemeColors_platbell.accentBlueStart_platbell.opacity(0.3),
                                ThemeColors_platbell.primaryStart_platbell.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
        }
    }
    
    /// 账户管理区域
    private var accountSection_platbell: some View {
        VStack(spacing: 12) {
            // 区域标题
            HStack {
                Image(systemName: "person.fill.badge.minus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 4))
                
                Text("Account Management")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                // 登出按钮
                SettingButton_platbell(
                    title_platbell: "Logout",
                    icon_platbell: "rectangle.portrait.and.arrow.right",
                    showDivider_platbell: true,
                    isDestructive_platbell: false,
                    onTap_platbell: {
                        showLogoutAlert_platbell = true
                    }
                )
                
                // 删除账号按钮
                SettingButton_platbell(
                    title_platbell: "Delete Account",
                    icon_platbell: "trash.fill",
                    showDivider_platbell: false,
                    isDestructive_platbell: true,
                    onTap_platbell: {
                        showDeleteAlert_platbell = true
                    }
                )
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                    
                    RoundedRectangle(cornerRadius: 20)
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
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ThemeColors_platbell.warmStart_platbell.opacity(0.3),
                                Color.red.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理登出
    private func handleLogout_platbell() {
        userVM_platbell.logout_platbell(logoutType_platbell: .logout_platbell)
        
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Logged out successfully",
            delay_platbell: 1.5
        )
        
        // 返回并跳转到登录页
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            router_platbell.popToRoot_platbell()
            router_platbell.toLogin_platbellui()
        }
    }
    
    /// 处理删除账号
    private func handleDeleteAccount_platbell() {
        userVM_platbell.logout_platbell(logoutType_platbell: .delete_platbell)
        
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Account deleted successfully",
            delay_platbell: 1.5
        )
        
        // 返回并跳转到登录页
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            router_platbell.popToRoot_platbell()
            router_platbell.toLogin_platbellui()
        }
    }
}

// MARK: - 设置按钮组件

/// 设置按钮组件
struct SettingButton_platbell: View {
    let title_platbell: String
    let icon_platbell: String
    let showDivider_platbell: Bool
    var isDestructive_platbell: Bool = false
    let onTap_platbell: () -> Void
    
    var body: some View {
        Button(action: onTap_platbell) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // 图标
                    ZStack {
                        Circle()
                            .fill(
                                isDestructive_platbell
                                    ? Color.red.opacity(0.1)
                                    : ThemeColors_platbell.accentBlueStart_platbell.opacity(0.1)
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon_platbell)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(
                                isDestructive_platbell
                                    ? .red
                                    : ThemeColors_platbell.accentBlueStart_platbell
                            )
                    }
                    
                    // 标题
                    Text(title_platbell)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(
                            isDestructive_platbell
                                ? .red
                                : .primary
                        )
                    
                    Spacer()
                    
                    // 右箭头
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                // 分隔线
                if showDivider_platbell {
                    Divider()
                        .padding(.leading, 72)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
