import UIKit
import CoreImage

// MARK: - 光源照片滤镜

/// LightPhotoFilterHelper_Lens
/// 功能：根据当前光源模式、角度与强度，对上传照片应用调色与滤镜
/// 设计：Core Image 链式处理（色彩控制 → 色相 → 色调叠加 → 方向光晕）
class LightPhotoFilterHelper_Lens {

    /// 滤镜渲染质量
    enum FilterQuality_Lens {
        /// 拖动预览：降采样 + 精简滤镜链
        case preview_Lens
        /// 最终展示：完整滤镜
        case full_Lens
    }

    /// 预览图最长边（pt）
    private static let previewMaxEdge_Lens: CGFloat = 520
    /// 成图最长边（pt）
    private static let fullMaxEdge_Lens: CGFloat = 1280

    /// CI 渲染上下文（复用提升性能）
    private static let ciContext_Lens = CIContext(options: [.useSoftwareRenderer: false])

    /// 模式级调色预设（饱和度、亮度、对比度、色调强度）
    private struct ModePreset_Lens {
        let saturation_Lens: Float
        let brightness_Lens: Float
        let contrast_Lens: Float
        let tintStrength_Lens: CGFloat
    }

    /// 根据光源环境为图片应用完整滤镜
    /// 参数：
    /// - image_Lens: 原始上传图片
    /// - light_Lens: 当前光源配置
    /// - quality_Lens: 预览或完整质量
    /// - Returns: 调色后的图片，失败时返回原图
    static func applyLightFilter_Lens(
        image_Lens: UIImage,
        light_Lens: LightEnvironmentModel_Lens,
        quality_Lens: FilterQuality_Lens = .full_Lens
    ) -> UIImage {
        let source_Lens = downscaledImage_Lens(
            image_Lens,
            maxEdge_Lens: quality_Lens == .preview_Lens ? previewMaxEdge_Lens : fullMaxEdge_Lens
        )
        guard let ciInput_Lens = CIImage(image: source_Lens) else { return image_Lens }

        let preset_Lens = modePreset_Lens(mode_Lens: light_Lens.mode_Lens)
        let intensity_Lens = CGFloat(light_Lens.intensity_Lens)

        var output_Lens = applyColorControls_Lens(
            input_Lens: ciInput_Lens,
            brightness_Lens: preset_Lens.brightness_Lens + Float((intensity_Lens - 0.5) * 0.22),
            contrast_Lens: preset_Lens.contrast_Lens + Float(intensity_Lens * 0.18),
            saturation_Lens: preset_Lens.saturation_Lens + Float(intensity_Lens * 0.25)
        ) ?? ciInput_Lens

        if quality_Lens == .full_Lens {
            let hueShift_Lens = Float(light_Lens.angle_Lens / 360.0 * .pi * 0.28)
            output_Lens = applyHueAdjust_Lens(input_Lens: output_Lens, angle_Lens: hueShift_Lens) ?? output_Lens
        }

        let tintHex_Lens = light_Lens.extractedTintHex_Lens ?? light_Lens.mode_Lens.defaultTintHex_Lens
        let tintStrength_Lens = preset_Lens.tintStrength_Lens * (0.55 + intensity_Lens * 0.65)
        output_Lens = applyTintOverlay_Lens(
            input_Lens: output_Lens,
            tintHex_Lens: tintHex_Lens,
            strength_Lens: tintStrength_Lens
        ) ?? output_Lens

        if quality_Lens == .full_Lens {
            output_Lens = applyDirectionalGlow_Lens(
                input_Lens: output_Lens,
                angle_Lens: light_Lens.angle_Lens,
                tintHex_Lens: tintHex_Lens,
                intensity_Lens: intensity_Lens
            ) ?? output_Lens
        }

        return renderCIImage_Lens(output_Lens, fallback_Lens: source_Lens) ?? image_Lens
    }

    /// 异步应用滤镜（后台渲染，主线程回调）
    static func applyLightFilterAsync_Lens(
        image_Lens: UIImage,
        light_Lens: LightEnvironmentModel_Lens,
        quality_Lens: FilterQuality_Lens,
        generation_Lens: UInt64,
        isLatestGeneration_Lens: @escaping (UInt64) -> Bool,
        completion_Lens: @escaping (UIImage) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered_Lens = applyLightFilter_Lens(
                image_Lens: image_Lens,
                light_Lens: light_Lens,
                quality_Lens: quality_Lens
            )
            DispatchQueue.main.async {
                guard isLatestGeneration_Lens(generation_Lens) else { return }
                completion_Lens(filtered_Lens)
            }
        }
    }

    /// 按最长边等比缩小，降低滤镜计算量
    private static func downscaledImage_Lens(_ image_Lens: UIImage, maxEdge_Lens: CGFloat) -> UIImage {
        let maxSide_Lens = max(image_Lens.size.width, image_Lens.size.height)
        guard maxSide_Lens > maxEdge_Lens, maxEdge_Lens > 0 else { return image_Lens }
        let scale_Lens = maxEdge_Lens / maxSide_Lens
        let targetSize_Lens = CGSize(
            width: floor(image_Lens.size.width * scale_Lens),
            height: floor(image_Lens.size.height * scale_Lens)
        )
        let renderer_Lens = UIGraphicsImageRenderer(size: targetSize_Lens)
        return renderer_Lens.image { _ in
            image_Lens.draw(in: CGRect(origin: .zero, size: targetSize_Lens))
        }
    }

    /// 从本地路径加载参考图
    static func loadLocalImage_Lens(path_Lens: String) -> UIImage? {
        if let image_Lens = UIImage(contentsOfFile: path_Lens) { return image_Lens }
        let docURL_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return UIImage(contentsOfFile: docURL_Lens.appendingPathComponent(path_Lens).path)
    }

    /// 各光源模式调色预设
    private static func modePreset_Lens(mode_Lens: LightModeType_Lens) -> ModePreset_Lens {
        switch mode_Lens {
        case .morningSun_Lens:
            return ModePreset_Lens(saturation_Lens: 1.12, brightness_Lens: 0.06, contrast_Lens: 1.04, tintStrength_Lens: 0.26)
        case .afternoonSun_Lens:
            return ModePreset_Lens(saturation_Lens: 1.18, brightness_Lens: 0.04, contrast_Lens: 1.08, tintStrength_Lens: 0.22)
        case .eveningWarm_Lens:
            return ModePreset_Lens(saturation_Lens: 1.08, brightness_Lens: -0.02, contrast_Lens: 1.12, tintStrength_Lens: 0.34)
        case .nightLamp_Lens:
            return ModePreset_Lens(saturation_Lens: 0.78, brightness_Lens: -0.08, contrast_Lens: 1.14, tintStrength_Lens: 0.38)
        case .candleLight_Lens:
            return ModePreset_Lens(saturation_Lens: 0.92, brightness_Lens: -0.05, contrast_Lens: 1.1, tintStrength_Lens: 0.36)
        case .neonPulse_Lens:
            return ModePreset_Lens(saturation_Lens: 1.42, brightness_Lens: 0.02, contrast_Lens: 1.18, tintStrength_Lens: 0.3)
        case .studioSoft_Lens:
            return ModePreset_Lens(saturation_Lens: 0.95, brightness_Lens: 0.08, contrast_Lens: 0.94, tintStrength_Lens: 0.14)
        case .overcastDay_Lens:
            return ModePreset_Lens(saturation_Lens: 0.72, brightness_Lens: 0.0, contrast_Lens: 0.9, tintStrength_Lens: 0.16)
        case .goldenHour_Lens:
            return ModePreset_Lens(saturation_Lens: 1.22, brightness_Lens: 0.03, contrast_Lens: 1.1, tintStrength_Lens: 0.4)
        case .moonlight_Lens:
            return ModePreset_Lens(saturation_Lens: 0.82, brightness_Lens: -0.06, contrast_Lens: 1.06, tintStrength_Lens: 0.32)
        case .gallerySpot_Lens:
            return ModePreset_Lens(saturation_Lens: 1.05, brightness_Lens: 0.1, contrast_Lens: 1.16, tintStrength_Lens: 0.12)
        case .exclusiveLight_Lens:
            return ModePreset_Lens(saturation_Lens: 1.1, brightness_Lens: 0.0, contrast_Lens: 1.06, tintStrength_Lens: 0.28)
        }
    }

    /// 色彩控制滤镜
    private static func applyColorControls_Lens(
        input_Lens: CIImage,
        brightness_Lens: Float,
        contrast_Lens: Float,
        saturation_Lens: Float
    ) -> CIImage? {
        guard let filter_Lens = CIFilter(name: "CIColorControls") else { return nil }
        filter_Lens.setValue(input_Lens, forKey: kCIInputImageKey)
        filter_Lens.setValue(brightness_Lens, forKey: kCIInputBrightnessKey)
        filter_Lens.setValue(contrast_Lens, forKey: kCIInputContrastKey)
        filter_Lens.setValue(saturation_Lens, forKey: kCIInputSaturationKey)
        return filter_Lens.outputImage
    }

    /// 色相微调
    private static func applyHueAdjust_Lens(input_Lens: CIImage, angle_Lens: Float) -> CIImage? {
        guard let filter_Lens = CIFilter(name: "CIHueAdjust") else { return nil }
        filter_Lens.setValue(input_Lens, forKey: kCIInputImageKey)
        filter_Lens.setValue(angle_Lens, forKey: kCIInputAngleKey)
        return filter_Lens.outputImage
    }

    /// 主题色调叠加
    private static func applyTintOverlay_Lens(
        input_Lens: CIImage,
        tintHex_Lens: String,
        strength_Lens: CGFloat
    ) -> CIImage? {
        let tint_Lens = UIColor(hexstring_Lens: tintHex_Lens)
        guard let colorFilter_Lens = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        var r_Lens: CGFloat = 0, g_Lens: CGFloat = 0, b_Lens: CGFloat = 0, a_Lens: CGFloat = 0
        tint_Lens.getRed(&r_Lens, green: &g_Lens, blue: &b_Lens, alpha: &a_Lens)
        colorFilter_Lens.setValue(CIVector(x: r_Lens, y: g_Lens, z: b_Lens, w: strength_Lens), forKey: "inputColor")

        guard let tintImage_Lens = colorFilter_Lens.outputImage?.cropped(to: input_Lens.extent),
              let blend_Lens = CIFilter(name: "CISoftLightBlendMode") else { return nil }
        blend_Lens.setValue(tintImage_Lens, forKey: kCIInputImageKey)
        blend_Lens.setValue(input_Lens, forKey: kCIInputBackgroundImageKey)
        return blend_Lens.outputImage?.cropped(to: input_Lens.extent)
    }

    /// 方向光晕（模拟光线角度）
    private static func applyDirectionalGlow_Lens(
        input_Lens: CIImage,
        angle_Lens: Double,
        tintHex_Lens: String,
        intensity_Lens: CGFloat
    ) -> CIImage? {
        let extent_Lens = input_Lens.extent
        let rad_Lens = angle_Lens * .pi / 180
        let start_Lens = CIVector(
            x: extent_Lens.midX - cos(rad_Lens) * extent_Lens.width * 0.5,
            y: extent_Lens.midY - sin(rad_Lens) * extent_Lens.height * 0.5
        )
        let end_Lens = CIVector(
            x: extent_Lens.midX + cos(rad_Lens) * extent_Lens.width * 0.5,
            y: extent_Lens.midY + sin(rad_Lens) * extent_Lens.height * 0.5
        )

        let tint_Lens = UIColor(hexstring_Lens: tintHex_Lens)
        var r_Lens: CGFloat = 1, g_Lens: CGFloat = 1, b_Lens: CGFloat = 1
        tint_Lens.getRed(&r_Lens, green: &g_Lens, blue: &b_Lens, alpha: nil)

        guard let gradientFilter_Lens = CIFilter(name: "CILinearGradient") else { return nil }
        gradientFilter_Lens.setValue(start_Lens, forKey: "inputPoint0")
        gradientFilter_Lens.setValue(end_Lens, forKey: "inputPoint1")
        gradientFilter_Lens.setValue(CIColor(red: r_Lens, green: g_Lens, blue: b_Lens, alpha: intensity_Lens * 0.55), forKey: "inputColor0")
        gradientFilter_Lens.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: intensity_Lens * 0.35), forKey: "inputColor1")

        guard let gradient_Lens = gradientFilter_Lens.outputImage?.cropped(to: extent_Lens),
              let blend_Lens = CIFilter(name: "CISoftLightBlendMode") else { return nil }
        blend_Lens.setValue(gradient_Lens, forKey: kCIInputImageKey)
        blend_Lens.setValue(input_Lens, forKey: kCIInputBackgroundImageKey)
        return blend_Lens.outputImage?.cropped(to: extent_Lens)
    }

    /// 渲染 CIImage 为 UIImage
    private static func renderCIImage_Lens(_ ciImage_Lens: CIImage, fallback_Lens: UIImage) -> UIImage? {
        let extent_Lens = ciImage_Lens.extent
        guard let cgImage_Lens = ciContext_Lens.createCGImage(ciImage_Lens, from: extent_Lens) else {
            return fallback_Lens
        }
        return UIImage(cgImage: cgImage_Lens, scale: fallback_Lens.scale, orientation: fallback_Lens.imageOrientation)
    }
}
