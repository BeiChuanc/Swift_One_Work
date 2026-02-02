import SwiftUI
import PhotosUI

// MARK: - 添加纪念贴纸Sheet
// 核心作用：提供添加纪念贴纸的完整界面
// 设计思路：相册图片选择 + 文字输入 + 智能位置分配
// 关键功能：相册图片选择、文字输入、位置计算、防止重叠

/// 添加纪念Sheet视图
struct AddMemorySheet_blisslink: View {
    
    // MARK: - 属性
    
    /// 关闭回调
    var onDismiss_blisslink: (() -> Void)?
    
    /// 添加完成回调
    var onAdd_blisslink: ((MemorySticker_blisslink) -> Void)?
    
    /// 已有的贴纸（用于防止重叠）
    var existingStickers_blisslink: [MemorySticker_blisslink]
    
    // MARK: - 状态
    
    @State private var selectedImage_blisslink: PhotosPickerItem?
    @State private var selectedUIImage_blisslink: UIImage?
    @State private var memoryText_blisslink: String = ""
    @State private var selectedPhotoName_blisslink: String = ""
    
    // MARK: - ViewModels
    
    @ObservedObject var userVM_baseswiftui = UserViewModel_baseswiftui.shared_baseswiftui
    @ObservedObject var localData_baseswiftui = LocalData_baseswiftui.shared_baseswiftui
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Button(action: {
                    handleCancel_blisslink()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24.sp_baseswiftui))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Add Memory")
                    .font(.system(size: 20.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    handleAddMemory_blisslink()
                }) {
                    Text("Add")
                        .font(.system(size: 16.sp_baseswiftui, weight: .bold))
                        .foregroundColor(isValid_blisslink ? Color(hex: "667EEA") : .gray)
                }
                .disabled(!isValid_blisslink)
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .padding(.top, 20.h_baseswiftui)
            .padding(.bottom, 16.h_baseswiftui)
            .background(Color.white)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24.h_baseswiftui) {
                    // 图片预览区域
                    imagePreviewSection_blisslink
                        .padding(.top, 20.h_baseswiftui)
                    
                    // 文字输入区域
                    textInputSection_blisslink
                    
                    // 提示信息
                    Text("Your memory will be placed on your yoga mat as a sticker")
                        .font(.system(size: 13.sp_baseswiftui))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40.w_baseswiftui)
                }
                .padding(.bottom, 40.h_baseswiftui)
            }
            .background(Color(hex: "F7FAFC"))
        }
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - 图片预览区域
    
    private var imagePreviewSection_blisslink: some View {
        VStack(spacing: 12.h_baseswiftui) {
            ZStack(alignment: .topTrailing) {
                // 点击区域 - 选择相册图片
                PhotosPicker(selection: $selectedImage_blisslink, matching: .images) {
                    ZStack {
                        // 背景渐变
                        RoundedRectangle(cornerRadius: 16.w_baseswiftui)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "667EEA").opacity(0.1),
                                        Color(hex: "764BA2").opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200.h_baseswiftui)
                        
                        if let image_blisslink = selectedUIImage_blisslink {
                            // 显示选中的图片
                            Image(uiImage: image_blisslink)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200.h_baseswiftui)
                                .clipped()
                                .cornerRadius(16.w_baseswiftui)
                        } else {
                            // 默认占位符
                            VStack(spacing: 12.h_baseswiftui) {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .font(.system(size: 60.sp_baseswiftui))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Text("Tap to select a photo")
                                    .font(.system(size: 14.sp_baseswiftui, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onChange(of: selectedImage_blisslink) { oldValue_blisslink, newValue_blisslink in
                    loadSelectedImage_blisslink()
                }
                
                // 删除按钮（仅在有图片时显示）
                if selectedUIImage_blisslink != nil {
                    Button(action: {
                        handleDeleteImage_blisslink()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 32.w_baseswiftui, height: 32.h_baseswiftui)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14.sp_baseswiftui, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding([.top, .trailing], 28.w_baseswiftui)
                }
            }
            .padding(.horizontal, 20.w_baseswiftui)
        }
    }
    
    // MARK: - 图片选择区域
    
    /// 媒体图片选项
    private func mediaImageOption_blisslink(_ imageName_blisslink: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                selectedPhotoName_blisslink = imageName_blisslink
                // 加载选中的媒体图片
                if let image_blisslink = UIImage(named: imageName_blisslink) {
                    selectedUIImage_blisslink = image_blisslink
                }
            }
            
            // 触觉反馈
            let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
            generator_blisslink.impactOccurred()
        }) {
            VStack(spacing: 8.h_baseswiftui) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12.w_baseswiftui)
                        .fill(Color.white)
                        .frame(width: 80.w_baseswiftui, height: 80.h_baseswiftui)
                    
                    if let image_blisslink = UIImage(named: imageName_blisslink) {
                        Image(uiImage: image_blisslink)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80.w_baseswiftui, height: 80.h_baseswiftui)
                            .clipped()
                            .cornerRadius(12.w_baseswiftui)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12.w_baseswiftui)
                        .strokeBorder(
                            selectedPhotoName_blisslink == imageName_blisslink ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3.w_baseswiftui
                        )
                )
                .scaleEffect(selectedPhotoName_blisslink == imageName_blisslink ? 1.08 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0), value: selectedPhotoName_blisslink)
                
                Text(extractImageName_blisslink(imageName_blisslink))
                    .font(.system(size: 11.sp_baseswiftui, weight: selectedPhotoName_blisslink == imageName_blisslink ? .bold : .medium))
                    .foregroundColor(selectedPhotoName_blisslink == imageName_blisslink ? .primary : .secondary)
                    .lineLimit(1)
                    .frame(width: 80.w_baseswiftui)
            }
        }
    }
    
    /// 提取图片名称（去掉扩展名）
    private func extractImageName_blisslink(_ fullName_blisslink: String) -> String {
        return fullName_blisslink.components(separatedBy: ".").first ?? fullName_blisslink
    }
    
    // MARK: - 文字输入区域
    
    private var textInputSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            Text("Memory Title")
                .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20.w_baseswiftui)
            
            VStack(alignment: .trailing, spacing: 8.h_baseswiftui) {
                // 文字输入框
                TextField("E.g., First outdoor meditation", text: $memoryText_blisslink)
                    .font(.system(size: 15.sp_baseswiftui))
                    .padding(16.w_baseswiftui)
                    .background(
                        RoundedRectangle(cornerRadius: 12.w_baseswiftui)
                            .fill(Color.white)
                    )
                    .onChange(of: memoryText_blisslink) { oldValue_blisslink, newValue_blisslink in
                        // 限制30字符
                        if newValue_blisslink.count > 30 {
                            memoryText_blisslink = String(newValue_blisslink.prefix(30))
                        }
                    }
                
                // 字数统计
                Text("\(memoryText_blisslink.count)/30")
                    .font(.system(size: 12.sp_baseswiftui))
                    .foregroundColor(memoryText_blisslink.count >= 30 ? .red : .secondary)
            }
            .padding(.horizontal, 20.w_baseswiftui)
        }
    }
    
    // MARK: - 计算属性
    
    /// 验证输入是否有效
    private var isValid_blisslink: Bool {
        let hasText_blisslink = !memoryText_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage_blisslink = selectedUIImage_blisslink != nil && !selectedPhotoName_blisslink.isEmpty
        return hasText_blisslink && hasImage_blisslink
    }
    
    // MARK: - 事件处理
    
    /// 加载选中的图片
    private func loadSelectedImage_blisslink() {
        guard let selectedImage_blisslink = selectedImage_blisslink else { return }
        
        Task {
            if let data_blisslink = try? await selectedImage_blisslink.loadTransferable(type: Data.self) {
                if let image_blisslink = UIImage(data: data_blisslink) {
                    await MainActor.run {
                        selectedUIImage_blisslink = image_blisslink
                        // 生成一个唯一的图片名称
                        selectedPhotoName_blisslink = "memory_\(UUID().uuidString)"
                        
                        // 保存图片到文档目录
                        saveImageToDocuments_blisslink(image_blisslink: image_blisslink, fileName_blisslink: selectedPhotoName_blisslink)
                        
                        // 触觉反馈
                        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
                        generator_blisslink.impactOccurred()
                    }
                }
            }
        }
    }
    
    /// 保存图片到文档目录
    /// - Parameters:
    ///   - image_blisslink: 要保存的图片
    ///   - fileName_blisslink: 文件名（不含扩展名）
    private func saveImageToDocuments_blisslink(image_blisslink: UIImage, fileName_blisslink: String) {
        guard let data_blisslink = image_blisslink.jpegData(compressionQuality: 0.8) else { return }
        
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(fileName_blisslink).jpg")
        
        do {
            try data_blisslink.write(to: fileURL_blisslink)
            print("✅ 图片保存成功：\(fileURL_blisslink.path)")
        } catch {
            print("❌ 图片保存失败：\(error.localizedDescription)")
        }
    }
    
    /// 处理取消操作
    private func handleCancel_blisslink() {
        // 如果有未保存的临时图片，删除它
        if !selectedPhotoName_blisslink.isEmpty && selectedPhotoName_blisslink.hasPrefix("memory_") {
            deleteImageFromDocuments_blisslink(fileName_blisslink: selectedPhotoName_blisslink)
        }
        
        onDismiss_blisslink?()
    }
    
    /// 删除选中的图片
    private func handleDeleteImage_blisslink() {
        // 如果是从相册上传的图片，删除临时保存的文件
        if !selectedPhotoName_blisslink.isEmpty && selectedPhotoName_blisslink.hasPrefix("memory_") {
            deleteImageFromDocuments_blisslink(fileName_blisslink: selectedPhotoName_blisslink)
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
            selectedUIImage_blisslink = nil
            selectedPhotoName_blisslink = ""
            selectedImage_blisslink = nil
        }
        
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
    }
    
    /// 从文档目录删除图片
    /// - Parameter fileName_blisslink: 文件名（不含扩展名）
    private func deleteImageFromDocuments_blisslink(fileName_blisslink: String) {
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(fileName_blisslink).jpg")
        
        do {
            try fileManager_blisslink.removeItem(at: fileURL_blisslink)
            print("✅ 图片删除成功：\(fileURL_blisslink.path)")
        } catch {
            print("❌ 图片删除失败：\(error.localizedDescription)")
        }
    }
    
    /// 处理添加纪念
    private func handleAddMemory_blisslink() {
        guard isValid_blisslink else { return }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        // 计算不重叠的位置
        let position_blisslink = calculateNonOverlappingPosition_blisslink()
        
        // 创建新贴纸
        let currentUserId_blisslink = userVM_baseswiftui.getCurrentUser_baseswiftui().userId_baseswiftui ?? 0
        let stickerId_blisslink = existingStickers_blisslink.count + 1
        
        let newSticker_blisslink = MemorySticker_blisslink(
            stickerId_blisslink: stickerId_blisslink,
            userId_blisslink: currentUserId_blisslink,
            photoUrl_blisslink: selectedPhotoName_blisslink,
            title_blisslink: memoryText_blisslink,
            memoryDate_blisslink: Date(),
            positionX_blisslink: position_blisslink.x,
            positionY_blisslink: position_blisslink.y,
            rotation_blisslink: Double.random(in: -12...12)
        )
        
        // 执行添加回调
        onAdd_blisslink?(newSticker_blisslink)
        
        // 关闭Sheet
        onDismiss_blisslink?()
    }
    
    /// 计算不重叠的位置
    /// - Returns: (x, y) 位置比例（0-1）
    private func calculateNonOverlappingPosition_blisslink() -> (x: CGFloat, y: CGFloat) {
        let maxAttempts_blisslink = 20
        let minDistance_blisslink: CGFloat = 0.25 // 最小距离（比例）
        
        for _ in 0..<maxAttempts_blisslink {
            let x_blisslink = CGFloat.random(in: 0.15...0.85)
            let y_blisslink = CGFloat.random(in: 0.15...0.85)
            
            // 检查是否与现有贴纸重叠
            var isOverlapping_blisslink = false
            for sticker_blisslink in existingStickers_blisslink {
                let distance_blisslink = sqrt(
                    pow(x_blisslink - sticker_blisslink.positionX_blisslink, 2) +
                    pow(y_blisslink - sticker_blisslink.positionY_blisslink, 2)
                )
                
                if distance_blisslink < minDistance_blisslink {
                    isOverlapping_blisslink = true
                    break
                }
            }
            
            if !isOverlapping_blisslink {
                return (x_blisslink, y_blisslink)
            }
        }
        
        // 如果找不到合适位置，返回中心位置
        return (0.5, 0.5)
    }
}
