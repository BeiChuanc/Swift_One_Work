import SwiftUI

// MARK: - 设置页
// 核心作用：应用设置和偏好配置（协议、登出、删除账号）
// 设计思路：现代化卡片设计，清晰的功能分组，危险操作警告
// 关键功能：查看协议、登出、删除账号

/// 设置页
struct Set_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    // MARK: - 状态
    
    @State private var showTerms_blisslink: Bool = false
    @State private var showPrivacy_blisslink: Bool = false
    @State private var showLogoutAlert_blisslink: Bool = false
    @State private var showDeleteAlert_blisslink: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F7FAFC"),
                        Color(hex: "EDF2F7"),
                        Color(hex: "E2E8F0")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 装饰圆圈
                Circle()
                    .fill(Color(hex: "667EEA").opacity(0.05))
                    .frame(width: 300.w_baseswiftui, height: 300.h_baseswiftui)
                    .offset(x: -150.w_baseswiftui, y: -200.h_baseswiftui)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "764BA2").opacity(0.05))
                    .frame(width: 280.w_baseswiftui, height: 280.h_baseswiftui)
                    .offset(x: 160.w_baseswiftui, y: 400.h_baseswiftui)
                    .blur(radius: 50)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24.h_baseswiftui) {
                        // 协议区域
                        legalSection_blisslink
                        
                        // 账户操作区域
                        accountSection_blisslink
                    }
                    .padding(.horizontal, 20.w_baseswiftui)
                    .padding(.top, 24.h_baseswiftui)
                    .padding(.bottom, 40.h_baseswiftui)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTerms_blisslink) {
            protocolView_blisslink(type_blisslink: .terms_baseswiftui)
        }
        .sheet(isPresented: $showPrivacy_blisslink) {
            protocolView_blisslink(type_blisslink: .privacy_baseswiftui)
        }
        .alert("Logout", isPresented: $showLogoutAlert_blisslink) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                handleLogout_blisslink()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert_blisslink) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                handleDeleteAccount_blisslink()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            // 返回按钮
            Button(action: {
                router_baseswiftui.pop_baseswiftui()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
            
            Spacer()
            
            // 标题
            HStack(spacing: 8.w_baseswiftui) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20.sp_baseswiftui, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Settings")
                    .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 占位
            Color.clear
                .frame(width: 36.w_baseswiftui, height: 36.h_baseswiftui)
        }
        .padding(.horizontal, 20.w_baseswiftui)
        .padding(.top, 10.h_baseswiftui)
        .padding(.bottom, 12.h_baseswiftui)
        .background(
            ZStack {
                Color.white.opacity(0.85)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
                
                // 底部渐变装饰线
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 3.h_baseswiftui)
                }
            }
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 协议区域
    
    private var legalSection_blisslink: some View {
        VStack(spacing: 12.h_baseswiftui) {
            // 标题
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16.sp_baseswiftui))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Legal")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .padding(.top, 16.h_baseswiftui)
            
            // 协议选项
            VStack(spacing: 0) {
                settingRow_blisslink(
                    icon_blisslink: "doc.plaintext",
                    title_blisslink: "Terms of Service",
                    iconColor_blisslink: Color(hex: "56CCF2"),
                    showDivider_blisslink: true
                ) {
                    showTerms_blisslink = true
                }
                
                settingRow_blisslink(
                    icon_blisslink: "lock.doc",
                    title_blisslink: "Privacy Policy",
                    iconColor_blisslink: Color(hex: "667EEA"),
                    showDivider_blisslink: false
                ) {
                    showPrivacy_blisslink = true
                }
            }
            .padding(.bottom, 16.h_baseswiftui)
        }
        .background(
            RoundedRectangle(cornerRadius: 20.w_baseswiftui)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.1)
    }
    
    // MARK: - 账户操作区域
    
    private var accountSection_blisslink: some View {
        VStack(spacing: 12.h_baseswiftui) {
            // 标题
            HStack {
                Image(systemName: "person.fill.badge.minus")
                    .font(.system(size: 16.sp_baseswiftui))
                    .foregroundColor(Color(hex: "F2994A"))
                
                Text("Account")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .padding(.top, 16.h_baseswiftui)
            
            // 账户选项
            VStack(spacing: 0) {
                settingRow_blisslink(
                    icon_blisslink: "rectangle.portrait.and.arrow.right",
                    title_blisslink: "Logout",
                    iconColor_blisslink: Color(hex: "F2994A"),
                    showDivider_blisslink: true
                ) {
                    showLogoutAlert_blisslink = true
                }
                
                settingRow_blisslink(
                    icon_blisslink: "trash.circle",
                    title_blisslink: "Delete Account",
                    iconColor_blisslink: Color.red,
                    showDivider_blisslink: false,
                    isDangerous_blisslink: true
                ) {
                    showDeleteAlert_blisslink = true
                }
            }
            .padding(.bottom, 16.h_baseswiftui)
        }
        .background(
            RoundedRectangle(cornerRadius: 20.w_baseswiftui)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.2)
    }
    
    // MARK: - 版本信息
    
    private var versionInfo_blisslink: some View {
        VStack(spacing: 12.h_baseswiftui) {
            Image(systemName: "sparkles")
                .font(.system(size: 40.sp_baseswiftui))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("BlissLink")
                .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Version 1.0.0")
                .font(.system(size: 13.sp_baseswiftui))
                .foregroundColor(.secondary)
            
            Text("Your yoga companion")
                .font(.system(size: 12.sp_baseswiftui))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30.h_baseswiftui)
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.3)
    }
    
    // MARK: - 设置行
    
    private func settingRow_blisslink(
        icon_blisslink: String,
        title_blisslink: String,
        iconColor_blisslink: Color,
        showDivider_blisslink: Bool,
        isDangerous_blisslink: Bool = false,
        action_blisslink: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                // 触觉反馈
                let generator_blisslink = UIImpactFeedbackGenerator(style: isDangerous_blisslink ? .medium : .light)
                generator_blisslink.impactOccurred()
                
                action_blisslink()
            }) {
                HStack(spacing: 16.w_baseswiftui) {
                    // 图标
                    ZStack {
                        Circle()
                            .fill(iconColor_blisslink.opacity(0.15))
                            .frame(width: 44.w_baseswiftui, height: 44.h_baseswiftui)
                        
                        Image(systemName: icon_blisslink)
                            .font(.system(size: 20.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(iconColor_blisslink)
                    }
                    
                    // 标题
                    Text(title_blisslink)
                        .font(.system(size: 16.sp_baseswiftui, weight: .medium))
                        .foregroundColor(isDangerous_blisslink ? .red : .primary)
                    
                    Spacer()
                    
                    // 箭头
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14.sp_baseswiftui, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .padding(.horizontal, 20.w_baseswiftui)
                .padding(.vertical, 16.h_baseswiftui)
            }
            
            if showDivider_blisslink {
                Divider()
                    .padding(.leading, 80.w_baseswiftui)
            }
        }
    }
    
    // MARK: - 协议视图
    
    private func protocolView_blisslink(type_blisslink: ProtocolType_baseswiftui) -> some View {
        NavigationStack {
            ProtocolContentView_baseswiftui(
                type_baseswiftui: type_blisslink,
                content_baseswiftui: getProtocolContent_blisslink(type_blisslink: type_blisslink)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        // 使用 id 比较而不是 == 运算符
                        switch type_blisslink.id {
                        case "terms":
                            showTerms_blisslink = false
                        case "privacy":
                            showPrivacy_blisslink = false
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 事件处理
    
    /// 获取协议内容
    private func getProtocolContent_blisslink(type_blisslink: ProtocolType_baseswiftui) -> String {
        // 这里可以返回实际的协议内容或URL
        switch type_blisslink {
        case .terms_baseswiftui:
            return "terms.png"
        case .privacy_baseswiftui:
            return "privacy.png"
        default:
            return ""
        }
    }
    
    /// 处理登出
    private func handleLogout_blisslink() {
        userVM_baseswiftui.logout_baseswiftui(logoutType_baseswiftui: .logout_baseswiftui)
    }
    
    /// 处理删除账号
    private func handleDeleteAccount_blisslink() {
        userVM_baseswiftui.logout_baseswiftui(logoutType_baseswiftui: .delete_baseswiftui)
    }
}
