import SwiftUI
import PhotosUI

// MARK: - 编辑信息页
// 核心作用：编辑用户个人信息
// 设计思路：现代化设计 + 头像编辑 + 信息修改 + 登录验证
// 关键功能：修改头像、用户名、简介，数据验证，保存更新

/// 编辑信息页
struct EditInfo_platbell: View {
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 当前用户数据
    private var currentUser_platbell: LoginUserModel_platbell {
        userVM_platbell.getCurrentUser_platbell()
    }
    
    /// 用户名
    @State private var userName_platbell: String = ""
    
    /// 用户简介
    @State private var userIntro_platbell: String = ""
    
    /// 选中的头像图片
    @State private var selectedAvatarPath_platbell: String = ""
    
    /// PhotosPicker选中的图片
    @State private var selectedPhotoItem_platbell: PhotosPickerItem?
    
    /// 是否正在加载图片
    @State private var isLoadingImage_platbell = false
    
    var body: some View {
        ZStack {
            // 渐变背景
            backgroundView_platbell
            
            ScrollView {
                VStack(spacing: 24) {
                    // 顶部装饰
                    headerView_platbell
                        .padding(.top, 20)
                    
                    // 头像编辑区域
                    avatarSection_platbell
                    
                    // 用户名输入
                    userNameInputField_platbell
                    
                    // 简介输入
                    introInputField_platbell
                    
                    // 确认修改按钮
                    confirmButton_platbell
                        .padding(.top, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            loadUserData_platbell()
        }
        .onChange(of: selectedPhotoItem_platbell) { newItem_platbell in
            Task {
                await loadSelectedPhoto_platbell(item_platbell: newItem_platbell)
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.primaryStart_platbell.opacity(0.08),
                ThemeColors_platbell.accentGreenStart_platbell.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 顶部标题区域
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
                        ThemeColors_platbell.gradient_platbell(at: 0)
                            .opacity(0.2)
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        ThemeColors_platbell.gradient_platbell(at: 0)
                    )
                    .breathing_platbell(isEnabled_platbell: true, duration_platbell: 2.5, scaleRange_platbell: 0.1)
            }
            .shadow(
                color: ThemeColors_platbell.primaryStart_platbell.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Edit Profile")
                    .font(.system(size: 32, weight: .bold))
                    .gradientText_platbell(gradientIndex_platbell: 0)
                
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(ThemeColors_platbell.primaryStart_platbell)
                    
                    Text("Update your information")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    /// 头像预览视图
    @ViewBuilder
    private var avatarPreview_platbell: some View {
        let _ = print("🖼️ 渲染头像预览，当前路径：\(selectedAvatarPath_platbell)")
        
        // 优先显示选中的新头像
        if !selectedAvatarPath_platbell.isEmpty {
            if let image_platbell = MediaUtils_platbell.loadImageFromDocuments_platbell(imageName_platbell: selectedAvatarPath_platbell) {
                let _ = print("✅ 成功加载图片：\(selectedAvatarPath_platbell)")
                // 显示本地图片
                Image(uiImage: image_platbell)
                    .resizable()
                    .scaledToFill()
            } else {
                let _ = print("⚠️ 无法加载图片：\(selectedAvatarPath_platbell)，显示默认头像")
                // 加载失败，显示默认头像
                defaultAvatarView_platbell
            }
        } else {
            let _ = print("ℹ️ 头像路径为空，显示默认头像")
            // 没有头像，显示默认
            defaultAvatarView_platbell
        }
    }
    
    /// 默认头像视图
    private var defaultAvatarView_platbell: some View {
        ZStack {
            Circle()
                .fill(ThemeColors_platbell.gradient_platbell(at: 0).opacity(0.2))
            
            if let firstLetter_platbell = currentUser_platbell.userName_platbell?.prefix(1).uppercased() {
                Text(firstLetter_platbell)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 0))
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 0))
            }
        }
    }
    
    /// 头像编辑区域
    private var avatarSection_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 0))
                
                Text("Avatar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 加载状态指示器
                if isLoadingImage_platbell {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        
                        Text("Loading...")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ThemeColors_platbell.accentBlueStart_platbell)
                    }
                }
            }
            
            // 头像预览 - 点击头像上传
            HStack {
                Spacer()
                
                PhotosPicker(
                    selection: $selectedPhotoItem_platbell,
                    matching: .images
                ) {
                    ZStack(alignment: .bottomTrailing) {
                        // 显示当前头像（支持实时预览）
                        avatarPreview_platbell
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        ThemeColors_platbell.gradient_platbell(at: 0),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(
                                color: ThemeColors_platbell.primaryStart_platbell.opacity(0.3),
                                radius: 15,
                                x: 0,
                                y: 8
                            )
                            .id(selectedAvatarPath_platbell) // 强制在路径改变时刷新视图
                        
                        // 编辑图标
                        if !isLoadingImage_platbell {
                            ZStack {
                                Circle()
                                    .fill(ThemeColors_platbell.gradient_platbell(at: 0))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .offset(x: 2, y: 2)
                        }
                    }
                }
                .disabled(isLoadingImage_platbell)
                
                Spacer()
            }
            .padding(.vertical, 20)
        }
    }
    
    /// 用户名输入框
    private var userNameInputField_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 1))
                
                Text("Username")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(userName_platbell.count)/30")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            TextField("Enter your username", text: $userName_platbell)
                .font(.system(size: 16, weight: .semibold))
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            userName_platbell.isEmpty
                                ? AnyShapeStyle(Color(.systemGray4))
                                : AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: 1)),
                            lineWidth: 1.5
                        )
                )
                .onChange(of: userName_platbell) { newValue_platbell in
                    if newValue_platbell.count > 30 {
                        userName_platbell = String(newValue_platbell.prefix(30))
                    }
                }
        }
    }
    
    /// 简介输入框
    private var introInputField_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 2))
                
                Text("Bio")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(userIntro_platbell.count)/100")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            TextEditor(text: $userIntro_platbell)
                .font(.system(size: 15))
                .frame(height: 120)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            userIntro_platbell.isEmpty
                                ? AnyShapeStyle(Color(.systemGray4))
                                : AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: 2)),
                            lineWidth: 1.5
                        )
                )
                .onChange(of: userIntro_platbell) { newValue_platbell in
                    if newValue_platbell.count > 100 {
                        userIntro_platbell = String(newValue_platbell.prefix(100))
                    }
                }
        }
    }
    
    /// 确认修改按钮
    private var confirmButton_platbell: some View {
        Button(action: saveChanges_platbell) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Save Changes")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeColors_platbell.gradient_platbell(at: 0))
            )
            .shadow(
                color: ThemeColors_platbell.primaryStart_platbell.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(isLoadingImage_platbell)
        .opacity(isLoadingImage_platbell ? 0.6 : 1.0)
    }
    
    // MARK: - 事件处理
    
    /// 加载用户数据
    private func loadUserData_platbell() {
        userName_platbell = currentUser_platbell.userName_platbell ?? ""
        userIntro_platbell = currentUser_platbell.userIntroduce_platbell ?? ""
        selectedAvatarPath_platbell = currentUser_platbell.userHead_platbell ?? ""
    }
    
    /// 从PhotosPicker加载选中的图片
    /// - Parameter item_platbell: 选中的PhotosPickerItem
    private func loadSelectedPhoto_platbell(item_platbell: PhotosPickerItem?) async {
        guard let item_platbell = item_platbell else { 
            print("⚠️ PhotosPickerItem为空")
            return 
        }
        
        print("📸 开始加载选中的图片...")
        isLoadingImage_platbell = true
        
        do {
            // 加载图片数据
            if let data_platbell = try await item_platbell.loadTransferable(type: Data.self),
               let uiImage_platbell = UIImage(data: data_platbell) {
                
                print("✅ 图片数据加载成功，尺寸：\(uiImage_platbell.size)")
                
                // 保存图片到Documents目录
                let imageName_platbell = "avatar_\(UUID().uuidString).jpg"
                print("💾 尝试保存图片：\(imageName_platbell)")
                
                if MediaUtils_platbell.saveImageToDocuments_platbell(
                    image_platbell: uiImage_platbell,
                    imageName_platbell: imageName_platbell
                ) {
                    print("✅ 图片保存成功！")
                    
                    // 更新头像路径
                    await MainActor.run {
                        print("🔄 更新头像路径：\(imageName_platbell)")
                        selectedAvatarPath_platbell = imageName_platbell
                        isLoadingImage_platbell = false
                        print("📌 当前selectedAvatarPath_platbell = \(selectedAvatarPath_platbell)")
                    }
                    
                    Utils_platbell.showSuccess_platbell(
                        message_platbell: "Avatar updated",
                        delay_platbell: 1.0
                    )
                } else {
                    print("❌ 图片保存失败")
                    await MainActor.run {
                        isLoadingImage_platbell = false
                    }
                    
                    Utils_platbell.showError_platbell(
                        message_platbell: "Failed to save image",
                        delay_platbell: 1.5
                    )
                }
            } else {
                print("❌ 无法加载图片数据")
                await MainActor.run {
                    isLoadingImage_platbell = false
                }
            }
        } catch {
            print("❌ 图片加载异常: \(error.localizedDescription)")
            await MainActor.run {
                isLoadingImage_platbell = false
            }
            
            Utils_platbell.showError_platbell(
                message_platbell: "Failed to load image",
                delay_platbell: 1.5
            )
        }
    }
    
    /// 保存更改
    private func saveChanges_platbell() {
        // 1. 检查是否登录
        guard userVM_platbell.isLoggedIn_platbell else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please login first",
                delay_platbell: 2.0
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_platbell.pop_platbell()
                router_platbell.toLogin_platbellui()
            }
            return
        }
        
        // 2. 检查数据是否有修改
        let originalUser_platbell = currentUser_platbell
        let hasChanges_platbell = userName_platbell != (originalUser_platbell.userName_platbell ?? "") ||
                                   userIntro_platbell != (originalUser_platbell.userIntroduce_platbell ?? "") ||
                                   selectedAvatarPath_platbell != (originalUser_platbell.userHead_platbell ?? "")
        
        // 3. 如果没有修改，使用原有数据
        if !hasChanges_platbell {
            Utils_platbell.showInfo_platbell(
                message_platbell: "No changes to save",
                delay_platbell: 1.5
            )
            router_platbell.pop_platbell()
            return
        }
        
        // 4. 更新用户信息（这里应该调用ViewModel的更新方法）
        if var updatedUser_platbell = userVM_platbell.loggedUser_platbell {
            updatedUser_platbell.userName_platbell = userName_platbell.isEmpty ? originalUser_platbell.userName_platbell : userName_platbell
            updatedUser_platbell.userIntroduce_platbell = userIntro_platbell.isEmpty ? originalUser_platbell.userIntroduce_platbell : userIntro_platbell
            updatedUser_platbell.userHead_platbell = selectedAvatarPath_platbell
            
            userVM_platbell.loggedUser_platbell = updatedUser_platbell
        }
        
        // 5. 显示成功提示并返回
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Profile updated successfully",
            delay_platbell: 1.5
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            router_platbell.pop_platbell()
        }
    }
}
