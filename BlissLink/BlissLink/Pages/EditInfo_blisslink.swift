import SwiftUI
import PhotosUI

// MARK: - 编辑信息页
// 核心作用：编辑用户个人信息（头像、用户名、简介）
// 设计思路：现代化卡片设计，从相册选择头像，实时验证，动画自然
// 关键功能：相册头像选择、信息编辑、数据验证、保存更新

/// 编辑信息页
struct EditInfo_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    
    // MARK: - 状态
    
    @State private var userName_blisslink: String = ""
    @State private var userIntro_blisslink: String = ""
    @State private var selectedAvatarItem_blisslink: PhotosPickerItem?
    @State private var selectedAvatarImage_blisslink: UIImage?
    @State private var selectedAvatarName_blisslink: String = ""
    @State private var isSaving_blisslink: Bool = false
    
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
                    .frame(width: 280.w_blisslink, height: 280.h_blisslink)
                    .offset(x: -140.w_blisslink, y: -180.h_blisslink)
                    .blur(radius: 40)
                
                Circle()
                    .fill(Color(hex: "764BA2").opacity(0.05))
                    .frame(width: 300.w_blisslink, height: 300.h_blisslink)
                    .offset(x: 150.w_blisslink, y: 350.h_blisslink)
                    .blur(radius: 50)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28.h_blisslink) {
                        // 头像选择区域
                        avatarSection_blisslink
                        
                        // 用户名输入
                        userNameSection_blisslink
                        
                        // 简介输入
                        introSection_blisslink
                        
                        // 保存按钮
                        saveButton_blisslink
                            .padding(.top, 30.h_blisslink)
                    }
                    .padding(.horizontal, 20.w_blisslink)
                    .padding(.top, 24.h_blisslink)
                    .padding(.bottom, 40.h_blisslink)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadUserData_blisslink()
        }
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        HStack {
            // 返回按钮
            Button(action: {
                router_blisslink.pop_blisslink()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36.w_blisslink, height: 36.h_blisslink)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
            
            Spacer()
            
            // 标题
            HStack(spacing: 8.w_blisslink) {
                Image(systemName: "person.crop.circle.badge.pencil")
                    .font(.system(size: 20.sp_blisslink, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Edit Profile")
                    .font(.system(size: 18.sp_blisslink, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 占位（保持标题居中）
            Color.clear
                .frame(width: 36.w_blisslink, height: 36.h_blisslink)
        }
        .padding(.horizontal, 20.w_blisslink)
        .padding(.top, 10.h_blisslink)
        .padding(.bottom, 12.h_blisslink)
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
                    .frame(height: 3.h_blisslink)
                }
            }
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 头像选择区域
    
    private var avatarSection_blisslink: some View {
        VStack(spacing: 20.h_blisslink) {
            // 标题
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Avatar")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // 当前头像预览（可点击从相册选择）
            PhotosPicker(selection: $selectedAvatarItem_blisslink, matching: .images) {
                ZStack {
                    // 外层光晕
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "667EEA").opacity(0.3),
                                    Color(hex: "764BA2").opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 130.w_blisslink, height: 130.h_blisslink)
                        .blur(radius: 15)
                    
                    // 主头像
                    ZStack {
                        if let avatarImage_blisslink = selectedAvatarImage_blisslink {
                            // 显示从相册选择的图片
                            Image(uiImage: avatarImage_blisslink)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120.w_blisslink, height: 120.h_blisslink)
                                .clipShape(Circle())
                        } else {
                            // 显示当前用户头像
                            CurrentUserAvatarView_blisslink(
                                size_blisslink: 120.w_blisslink,
                                showOnlineIndicator_blisslink: false,
                                showEditButton_blisslink: false
                            )
                        }
                    }
                    .shadow(color: Color(hex: "667EEA").opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    // 编辑图标
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40.w_blisslink, height: 40.h_blisslink)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36.w_blisslink, height: 36.h_blisslink)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18.sp_blisslink, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 42.w_blisslink, y: 42.h_blisslink)
                    .shadow(color: Color(hex: "667EEA").opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .onChange(of: selectedAvatarItem_blisslink) { oldValue_blisslink, newValue_blisslink in
                loadSelectedAvatar_blisslink()
            }
            .bounceIn_blisslink(delay_blisslink: 0.1)
            
            // 提示文字
            VStack(spacing: 8.h_blisslink) {
                Text("Tap to select from album")
                    .font(.system(size: 14.sp_blisslink, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6.w_blisslink) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 12.sp_blisslink))
                    
                    Text("Supports JPG, PNG")
                        .font(.system(size: 12.sp_blisslink))
                }
                .foregroundColor(.secondary.opacity(0.7))
            }
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.15)
        }
        .padding(20.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 20.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - 用户名输入
    
    private var userNameSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标签
            HStack(spacing: 8.w_blisslink) {
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Username")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("*")
                    .font(.system(size: 18.sp_blisslink, weight: .bold))
                    .foregroundColor(.red)
                
                Spacer()
                
                // 字数统计
                Text("\(userName_blisslink.count)/20")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(userName_blisslink.count >= 20 ? .red : .secondary)
                    .padding(.horizontal, 10.w_blisslink)
                    .padding(.vertical, 4.h_blisslink)
                    .background(
                        Capsule()
                            .fill(userName_blisslink.count >= 20 ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                    )
            }
            
            // 输入框
            HStack(spacing: 12.w_blisslink) {
                Image(systemName: "at")
                    .font(.system(size: 18.sp_blisslink, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                TextField("Enter your username", text: $userName_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
            }
            .padding(16.w_blisslink)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .stroke(
                            !userName_blisslink.isEmpty ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.5), Color(hex: "764BA2").opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2.w_blisslink
                        )
                }
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .onChange(of: userName_blisslink) { oldValue_blisslink, newValue_blisslink in
                // 限制20字符
                if newValue_blisslink.count > 20 {
                    userName_blisslink = String(newValue_blisslink.prefix(20))
                }
            }
        }
        .padding(20.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 20.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.2)
    }
    
    // MARK: - 简介输入
    
    private var introSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标签
            HStack(spacing: 8.w_blisslink) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Bio")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 字数统计
                Text("\(userIntro_blisslink.count)/100")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(userIntro_blisslink.count >= 100 ? .red : .secondary)
                    .padding(.horizontal, 10.w_blisslink)
                    .padding(.vertical, 4.h_blisslink)
                    .background(
                        Capsule()
                            .fill(userIntro_blisslink.count >= 100 ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                    )
            }
            
            // 内容编辑器
            ZStack(alignment: .topLeading) {
                // 占位符
                if userIntro_blisslink.isEmpty {
                    HStack(spacing: 8.w_blisslink) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16.sp_blisslink))
                            .foregroundColor(Color(hex: "F2C94C"))
                        
                        Text("Describe yourself...")
                            .font(.system(size: 15.sp_blisslink))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.horizontal, 20.w_blisslink)
                    .padding(.vertical, 16.h_blisslink)
                }
                
                TextEditor(text: $userIntro_blisslink)
                    .font(.system(size: 15.sp_blisslink))
                    .padding(.horizontal, 16.w_blisslink)
                    .padding(.vertical, 12.h_blisslink)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120.h_blisslink)
                    .onChange(of: userIntro_blisslink) { oldValue_blisslink, newValue_blisslink in
                        // 限制100字符
                        if newValue_blisslink.count > 100 {
                            userIntro_blisslink = String(newValue_blisslink.prefix(100))
                        }
                    }
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .stroke(
                            !userIntro_blisslink.isEmpty ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.5), Color(hex: "764BA2").opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2.w_blisslink
                        )
                }
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
        .padding(20.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 20.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.3)
    }
    
    // MARK: - 保存按钮
    
    private var saveButton_blisslink: some View {
        Button(action: {
            handleSave_blisslink()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16.w_blisslink)
                    .fill(
                        hasChanges_blisslink && !isSaving_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 56.h_blisslink)
                
                // 顶部光晕
                if hasChanges_blisslink && !isSaving_blisslink {
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 28.h_blisslink)
                        
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16.w_blisslink))
                }
                
                // 按钮内容
                HStack(spacing: 12.w_blisslink) {
                    if isSaving_blisslink {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Saving...")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20.sp_blisslink))
                        
                        Text("Save Changes")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                    }
                }
                .foregroundColor(.white)
            }
            .shadow(
                color: hasChanges_blisslink && !isSaving_blisslink ? Color(hex: "667EEA").opacity(0.4) : Color.clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .disabled(!hasChanges_blisslink || isSaving_blisslink)
        .scaleEffect(hasChanges_blisslink && !isSaving_blisslink ? 1.0 : 0.97)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: hasChanges_blisslink)
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.4)
    }
    
    // MARK: - 计算属性
    
    /// 是否有改动
    private var hasChanges_blisslink: Bool {
        let currentUser_blisslink = userVM_blisslink.getCurrentUser_blisslink()
        
        let nameChanged_blisslink = userName_blisslink != (currentUser_blisslink.userName_blisslink ?? "")
        let introChanged_blisslink = userIntro_blisslink != (currentUser_blisslink.userIntroduce_blisslink ?? "")
        let avatarChanged_blisslink = selectedAvatarImage_blisslink != nil
        
        return nameChanged_blisslink || introChanged_blisslink || avatarChanged_blisslink
    }
    
    // MARK: - 事件处理
    
    /// 加载用户数据
    private func loadUserData_blisslink() {
        let currentUser_blisslink = userVM_blisslink.getCurrentUser_blisslink()
        userName_blisslink = currentUser_blisslink.userName_blisslink ?? ""
        userIntro_blisslink = currentUser_blisslink.userIntroduce_blisslink ?? ""
    }
    
    /// 加载选中的头像
    private func loadSelectedAvatar_blisslink() {
        guard let selectedAvatarItem_blisslink = selectedAvatarItem_blisslink else { return }
        
        Task {
            if let data_blisslink = try? await selectedAvatarItem_blisslink.loadTransferable(type: Data.self) {
                if let image_blisslink = UIImage(data: data_blisslink) {
                    await MainActor.run {
                        selectedAvatarImage_blisslink = image_blisslink
                        // 生成唯一的头像名称
                        selectedAvatarName_blisslink = "avatar_\(UUID().uuidString)"
                        
                        // 保存头像到文档目录
                        saveAvatarToDocuments_blisslink(image_blisslink: image_blisslink)
                        
                        // 触觉反馈
                        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
                        generator_blisslink.impactOccurred()
                        
                        print("✅ 头像加载成功")
                    }
                }
            }
        }
    }
    
    /// 保存头像到文档目录
    /// - Parameter image_blisslink: 要保存的头像图片
    private func saveAvatarToDocuments_blisslink(image_blisslink: UIImage) {
        guard let data_blisslink = image_blisslink.jpegData(compressionQuality: 0.8) else { return }
        
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(selectedAvatarName_blisslink).jpg")
        
        do {
            try data_blisslink.write(to: fileURL_blisslink)
            print("✅ 头像保存成功：\(fileURL_blisslink.path)")
        } catch {
            print("❌ 头像保存失败：\(error.localizedDescription)")
        }
    }
    
    /// 保存修改
    private func handleSave_blisslink() {
        // 检查是否登录
        if !userVM_blisslink.isLoggedIn_blisslink {
            // 延迟跳转到登录页面
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Router_blisslink.shared_blisslink.toLogin_blisslink()
            }
            return
        }
        
        // 验证用户名
        guard !userName_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Utils_blisslink.showWarning_blisslink(
                message_blisslink: "Username cannot be empty.",
                delay_blisslink: 1.5
            )
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        isSaving_blisslink = true
        
        // 模拟保存过程
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
            
            // 更新用户信息
            if hasChanges_blisslink {
                let currentUser_blisslink = userVM_blisslink.getCurrentUser_blisslink()
                
                // 更新用户名
                if userName_blisslink != (currentUser_blisslink.userName_blisslink ?? "") {
                    userVM_blisslink.updateName_blisslink(userName_blisslink: userName_blisslink)
                }
                
                // 更新头像
                if !selectedAvatarName_blisslink.isEmpty {
                    userVM_blisslink.updateHead_blisslink(headUrl_blisslink: selectedAvatarName_blisslink)
                }
                
                // 更新简介
                if userIntro_blisslink != (currentUser_blisslink.userIntroduce_blisslink ?? "") {
                    userVM_blisslink.updateIntroduce_blisslink(introduce_blisslink: userIntro_blisslink)
                }
            }
            
            isSaving_blisslink = false
            
            // 延迟返回
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            router_blisslink.pop_blisslink()
        }
    }
}
