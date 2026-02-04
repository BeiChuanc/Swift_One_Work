import SwiftUI
import PhotosUI
import AVKit

// MARK: - 媒体上传展示组件
// 核心作用：用于发布页面的媒体上传和预览
// 设计思路：支持图片/视频上传、预览、删除功能
// 关键功能：媒体选择、预览展示、删除按钮

/// 媒体上传视图
struct MediaUploadView_blisslink: View {
    
    // MARK: - 属性
    
    /// 选中的媒体项
    @Binding var selectedMedia_blisslink: PhotosPickerItem?
    
    /// 选中的媒体图片
    @Binding var selectedMediaImage_blisslink: UIImage?
    
    /// 选中的媒体名称
    @Binding var selectedMediaName_blisslink: String
    
    /// 是否是视频
    @Binding var isVideo_blisslink: Bool
    
    /// 删除回调
    var onDelete_blisslink: (() -> Void)?
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标签
            HStack(spacing: 8.w_blisslink) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Media")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                // 必填标识
                Text("*")
                    .font(.system(size: 18.sp_blisslink, weight: .bold))
                    .foregroundColor(.red)
                
                Spacer()
                
                // 媒体类型标识
                if selectedMediaImage_blisslink != nil {
                    HStack(spacing: 6.w_blisslink) {
                        Image(systemName: isVideo_blisslink ? "video.fill" : "photo.fill")
                            .font(.system(size: 12.sp_blisslink))
                        
                        Text(isVideo_blisslink ? "Video" : "Photo")
                            .font(.system(size: 12.sp_blisslink, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "667EEA"))
                    .padding(.horizontal, 10.w_blisslink)
                    .padding(.vertical, 4.h_blisslink)
                    .background(
                        Capsule()
                            .fill(Color(hex: "667EEA").opacity(0.1))
                    )
                }
            }
            
            ZStack(alignment: .topTrailing) {
                // 媒体选择/预览
                if selectedMediaImage_blisslink != nil {
                    // 显示已选媒体
                    mediaPreviewView_blisslink
                } else {
                    // 显示选择器
                    mediaPickerView_blisslink
                }
                
                // 删除媒体按钮（仅在有媒体时显示）
                if selectedMediaImage_blisslink != nil {
                    Button(action: {
                        handleDelete_blisslink()
                    }) {
                        ZStack {
                            // 外层光晕
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 38.w_blisslink, height: 38.h_blisslink)
                            
                            // 内层背景
                            Circle()
                                .fill(Color.red)
                                .frame(width: 32.w_blisslink, height: 32.h_blisslink)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14.sp_blisslink, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(12.w_blisslink)
                }
            }
        }
    }
    
    // MARK: - 媒体预览视图
    
    private var mediaPreviewView_blisslink: some View {
        ZStack {
            if let image_blisslink = selectedMediaImage_blisslink {
                // 媒体图片
                Image(uiImage: image_blisslink)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280.h_blisslink)
                    .clipped()
                    .cornerRadius(18.w_blisslink)
                
                // 底部渐变遮罩
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80.h_blisslink)
                }
                .cornerRadius(18.w_blisslink)
                
                // 视频标识
                if isVideo_blisslink {
                    ZStack {
                        // 外层光晕
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 75.w_blisslink, height: 75.h_blisslink)
                            .blur(radius: 10)
                        
                        // 主背景
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 65.w_blisslink, height: 65.h_blisslink)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 30.sp_blisslink))
                            .foregroundColor(.white)
                            .offset(x: 2.w_blisslink)
                    }
                }
                
                // 底部媒体信息
                VStack {
                    Spacer()
                    HStack(spacing: 8.w_blisslink) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16.sp_blisslink))
                            .foregroundColor(.white)
                        
                        Text(isVideo_blisslink ? "Video selected" : "Photo selected")
                            .font(.system(size: 13.sp_blisslink, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16.w_blisslink)
                    .padding(.bottom, 16.h_blisslink)
                }
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - 媒体选择器视图
    
    private var mediaPickerView_blisslink: some View {
        PhotosPicker(selection: $selectedMedia_blisslink, matching: .any(of: [.images, .videos])) {
            ZStack {
                // 背景渐变
                RoundedRectangle(cornerRadius: 18.w_blisslink)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "667EEA").opacity(0.05),
                                Color(hex: "764BA2").opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 280.h_blisslink)
                
                // 虚线边框
                RoundedRectangle(cornerRadius: 18.w_blisslink)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2.5.w_blisslink, dash: [10, 5])
                    )
                    .frame(height: 280.h_blisslink)
                
                VStack(spacing: 20.h_blisslink) {
                    // 主图标
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "667EEA").opacity(0.15),
                                        Color(hex: "764BA2").opacity(0.15)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100.w_blisslink, height: 100.h_blisslink)
                        
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50.sp_blisslink, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(spacing: 8.h_blisslink) {
                        Text("Tap to upload photo or video")
                            .font(.system(size: 16.sp_blisslink, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // 支持格式标签
                        HStack(spacing: 8.w_blisslink) {
                            formatTag_blisslink(icon_blisslink: "photo.fill", text_blisslink: "JPG/PNG")
                            formatTag_blisslink(icon_blisslink: "video.fill", text_blisslink: "MP4")
                        }
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    /// 格式标签
    private func formatTag_blisslink(icon_blisslink: String, text_blisslink: String) -> some View {
        HStack(spacing: 4.w_blisslink) {
            Image(systemName: icon_blisslink)
                .font(.system(size: 10.sp_blisslink))
            
            Text(text_blisslink)
                .font(.system(size: 11.sp_blisslink, weight: .medium))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 10.w_blisslink)
        .padding(.vertical, 5.h_blisslink)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - 事件处理
    
    /// 删除媒体
    private func handleDelete_blisslink() {
        onDelete_blisslink?()
    }
}
