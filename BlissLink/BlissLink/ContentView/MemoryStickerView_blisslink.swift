import SwiftUI

// MARK: - 纪念贴纸组件
// 核心作用：展示用户的练习纪念照片贴纸
// 设计思路：拟物化贴纸效果、可拖拽摆放
// 关键功能：贴纸展示、点击查看详情

/// 纪念贴纸视图
struct MemoryStickerView_blisslink: View {
    
    // MARK: - 属性
    
    /// 贴纸数据
    let sticker_blisslink: MemorySticker_blisslink
    
    /// 容器大小（用于计算位置）
    var containerSize_blisslink: CGSize
    
    /// 点击回调
    var onTap_blisslink: (() -> Void)?
    
    /// 动画状态
    @State private var isPressed_blisslink: Bool = false
    
    /// 加载的图片
    @State private var loadedImage_blisslink: UIImage?
    
    // MARK: - 视图主体
    
    var body: some View {
        Button(action: {
            onTap_blisslink?()
        }) {
            VStack(spacing: 0) {
                // 照片容器
                ZStack {
                    // 白色背景（拍立得效果）
                    RoundedRectangle(cornerRadius: 12.w_baseswiftui)
                        .fill(Color.white)
                        .frame(width: 120.w_baseswiftui, height: 135.h_baseswiftui)
                        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 3, y: 4)
                    
                    VStack(spacing: 0) {
                        // 展示图片
                        if let image_blisslink = loadedImage_blisslink {
                            Image(uiImage: image_blisslink)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 105.w_baseswiftui, height: 90.h_baseswiftui)
                                .clipped()
                                .cornerRadius(6.w_baseswiftui)
                        } else {
                            // 占位符
                            ZStack {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "667EEA").opacity(0.2),
                                                Color(hex: "764BA2").opacity(0.2)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 105.w_baseswiftui, height: 90.h_baseswiftui)
                                    .cornerRadius(6.w_baseswiftui)
                                
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 32.sp_baseswiftui))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                        
                        // 标题（底部白边，添加圆角）
                        Text(sticker_blisslink.title_blisslink)
                            .font(.system(size: 11.sp_baseswiftui, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(width: 105.w_baseswiftui)
                            .padding(.vertical, 7.h_baseswiftui)
                            .background(
                                RoundedRectangle(cornerRadius: 6.w_baseswiftui)
                                    .fill(Color.white)
                            )
                            .padding(.top, 5.h_baseswiftui)
                    }
                }
            }
            .rotationEffect(.degrees(sticker_blisslink.rotation_blisslink))
            .scaleEffect(isPressed_blisslink ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .position(
            x: containerSize_blisslink.width * sticker_blisslink.positionX_blisslink,
            y: containerSize_blisslink.height * sticker_blisslink.positionY_blisslink
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0), value: isPressed_blisslink)
        .onAppear {
            loadImage_blisslink()
        }
    }
    
    // MARK: - 辅助方法
    
    /// 加载图片（从 Assets 或文档目录）
    private func loadImage_blisslink() {
        // 先尝试从 Assets 加载
        if let image_blisslink = UIImage(named: sticker_blisslink.photoUrl_blisslink) {
            loadedImage_blisslink = image_blisslink
            return
        }
        
        // 如果 Assets 中没有，尝试从文档目录加载
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ 无法获取文档目录")
            return
        }
        
        let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(sticker_blisslink.photoUrl_blisslink).jpg")
        
        if let image_blisslink = UIImage(contentsOfFile: fileURL_blisslink.path) {
            loadedImage_blisslink = image_blisslink
            print("✅ 从文档目录加载图片成功：\(fileURL_blisslink.path)")
        } else {
            print("❌ 无法加载图片：\(sticker_blisslink.photoUrl_blisslink)")
        }
    }
}

// MARK: - 添加贴纸按钮

/// 添加纪念贴纸按钮
struct AddMemoryStickerButton_blisslink: View {
    
    /// 点击回调
    var onTap_blisslink: (() -> Void)?
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
            generator_blisslink.impactOccurred()
            
            onTap_blisslink?()
        }) {
            VStack(spacing: 8.h_baseswiftui) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 2.w_baseswiftui, dash: [5, 3])
                        )
                        .frame(width: 60.w_baseswiftui, height: 60.h_baseswiftui)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24.sp_baseswiftui, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text("Add Memory")
                    .font(.system(size: 11.sp_baseswiftui, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
