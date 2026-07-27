import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: 胶片效果渲染引擎

/// 胶片效果渲染引擎
/// 核心作用：统一承载"胶片参数手动调节面板"与"模拟胶片硬件特效"两大工具的本地实时渲染逻辑，
///          胶片预设离线库应用预设时同样复用本引擎，避免三处渲染代码重复实现
/// 设计思路：
///   - 连续色调/色彩类参数（颗粒、灰雾、对比度、色温、饱和度、分色、暗角、漏光、脏点）使用
///     CoreImage 滤镜链本地实时渲染，全部为系统内置滤镜组合，无需网络与额外资源包
///   - 离散硬件特效（镜头瑕疵的色散/眩光/柔化/畸变通过 CoreImage 实现；划痕/水痕/霉斑/针孔/
///     相纸边框/齿孔/水印等更适合矢量绘制的效果，使用 Core Graphics 二次叠加）
/// 关键属性：
///   - context_Lumia: 复用的 CIContext，避免每次渲染重复创建带来的性能损耗
class FilmEffectsEngine_Lumia {

    /// 复用的 CoreImage 渲染上下文
    private static let context_Lumia = CIContext(options: [.useSoftwareRenderer: false])

    // MARK: - 公共方法：连续参数调节

    /// 应用胶片调节参数（颗粒/灰雾/对比度/色温/饱和度/分色/暗角/漏光/脏点）
    /// - Parameters:
    ///   - image_Lumia: 原始图片
    ///   - params_Lumia: 调节参数集合
    /// - Returns: 渲染后的图片；渲染失败时返回原图，保证调用方始终有可展示的结果
    static func applyAdjustments_Lumia(to image_Lumia: UIImage, params_Lumia: FilmAdjustmentParams_Lumia) -> UIImage {
        guard var ciImage_Lumia = CIImage(image: image_Lumia) else { return image_Lumia }
        let extent_Lumia = ciImage_Lumia.extent
        guard extent_Lumia.width > 0, extent_Lumia.height > 0 else { return image_Lumia }

        // 1. 对比度 + 饱和度（0...1 映射为 CIColorControls 的 0...2，0.5 为中性）
        ciImage_Lumia = colorControls_Lumia(
            ciImage_Lumia,
            saturation_Lumia: Float(params_Lumia.saturation_Lumia * 2),
            contrast_Lumia: Float(params_Lumia.contrast_Lumia * 2)
        )

        // 2. 色温偏移
        if params_Lumia.tempShift_Lumia != 0 {
            ciImage_Lumia = temperatureShift_Lumia(ciImage_Lumia, shift_Lumia: params_Lumia.tempShift_Lumia)
        }

        // 3. RGB 通道分色（叠加常数偏移，模拟分色染色效果）
        if params_Lumia.channelR_Lumia != 0 || params_Lumia.channelG_Lumia != 0 || params_Lumia.channelB_Lumia != 0 {
            ciImage_Lumia = channelBias_Lumia(
                ciImage_Lumia,
                r_Lumia: params_Lumia.channelR_Lumia, g_Lumia: params_Lumia.channelG_Lumia, b_Lumia: params_Lumia.channelB_Lumia
            )
        }

        // 4. 灰雾（叠加低透明度浅灰，模拟老胶片雾感）
        if params_Lumia.fog_Lumia > 0 {
            ciImage_Lumia = applyFog_Lumia(ciImage_Lumia, intensity_Lumia: params_Lumia.fog_Lumia, extent_Lumia: extent_Lumia)
        }

        // 5. 暗角
        if params_Lumia.vignette_Lumia > 0 {
            ciImage_Lumia = applyVignette_Lumia(ciImage_Lumia, intensity_Lumia: params_Lumia.vignette_Lumia)
        }

        // 6. 颗粒
        if params_Lumia.grain_Lumia > 0 {
            ciImage_Lumia = applyGrain_Lumia(ciImage_Lumia, intensity_Lumia: params_Lumia.grain_Lumia, extent_Lumia: extent_Lumia)
        }

        // 7. 漏光（通用暖色漏光，硬件特效工具可指定更丰富的风格）
        if params_Lumia.lightLeak_Lumia > 0 {
            ciImage_Lumia = applyLightLeak_Lumia(
                ciImage_Lumia, colors_Lumia: [warmLeakColor_Lumia, warmLeakColorEnd_Lumia],
                corner_Lumia: .topRight, intensity_Lumia: params_Lumia.lightLeak_Lumia, extent_Lumia: extent_Lumia
            )
        }

        // 8. 划痕脏点
        if params_Lumia.dustScratch_Lumia > 0 {
            ciImage_Lumia = applyDust_Lumia(ciImage_Lumia, intensity_Lumia: params_Lumia.dustScratch_Lumia, extent_Lumia: extent_Lumia)
        }

        return render_Lumia(ciImage_Lumia, extent_Lumia: extent_Lumia) ?? image_Lumia
    }

    /// 应用预设（内部即读取预设的调节参数进行渲染）
    static func applyPreset_Lumia(to image_Lumia: UIImage, preset_Lumia: FilmPresetModel_Lumia) -> UIImage {
        return applyAdjustments_Lumia(to: image_Lumia, params_Lumia: preset_Lumia.params_Lumia)
    }

    // MARK: - 公共方法：硬件特效

    /// 应用硬件特效（漏光 / 镜头瑕疵 / 底片瑕疵 / 相纸边框）
    /// - Parameters:
    ///   - image_Lumia: 原始图片（通常已经过 applyAdjustments_Lumia 处理）
    ///   - params_Lumia: 硬件特效参数集合
    /// - Returns: 渲染后的图片；渲染失败时返回原图
    static func applyHardwareEffects_Lumia(to image_Lumia: UIImage, params_Lumia: HardwareEffectParams_Lumia) -> UIImage {
        guard var ciImage_Lumia = CIImage(image: image_Lumia) else { return image_Lumia }
        let extent_Lumia = ciImage_Lumia.extent
        guard extent_Lumia.width > 0, extent_Lumia.height > 0 else { return image_Lumia }

        // 1. 漏光模拟
        if params_Lumia.lightLeakStyle_Lumia != .none_Lumia {
            ciImage_Lumia = renderLightLeakStyle_Lumia(
                ciImage_Lumia, style_Lumia: params_Lumia.lightLeakStyle_Lumia,
                intensity_Lumia: params_Lumia.lightLeakIntensity_Lumia, extent_Lumia: extent_Lumia
            )
        }

        // 2. 镜头瑕疵
        if params_Lumia.lensFlawStyle_Lumia != .none_Lumia {
            ciImage_Lumia = renderLensFlawStyle_Lumia(
                ciImage_Lumia, style_Lumia: params_Lumia.lensFlawStyle_Lumia,
                intensity_Lumia: params_Lumia.lensFlawIntensity_Lumia, extent_Lumia: extent_Lumia
            )
        }

        var resultImage_Lumia = render_Lumia(ciImage_Lumia, extent_Lumia: extent_Lumia) ?? image_Lumia

        // 3. 底片瑕疵（划痕/水痕/霉斑/针孔更适合矢量绘制，使用 Core Graphics 二次叠加）
        if params_Lumia.negativeFlawStyle_Lumia != .none_Lumia {
            resultImage_Lumia = drawNegativeFlaw_Lumia(
                on: resultImage_Lumia, style_Lumia: params_Lumia.negativeFlawStyle_Lumia,
                intensity_Lumia: params_Lumia.negativeFlawIntensity_Lumia
            )
        }

        // 4. 相纸边框（含齿孔与编号水印）
        if params_Lumia.borderStyle_Lumia != .none_Lumia {
            resultImage_Lumia = drawBorder_Lumia(
                on: resultImage_Lumia, style_Lumia: params_Lumia.borderStyle_Lumia,
                thickness_Lumia: params_Lumia.borderThickness_Lumia,
                showPerforations_Lumia: params_Lumia.showPerforations_Lumia,
                watermarkText_Lumia: params_Lumia.watermarkText_Lumia
            )
        }

        return resultImage_Lumia
    }

    // MARK: - 私有方法：连续参数滤镜链

    private static func colorControls_Lumia(_ image_Lumia: CIImage, saturation_Lumia: Float, contrast_Lumia: Float) -> CIImage {
        let filter_Lumia = CIFilter.colorControls()
        filter_Lumia.inputImage = image_Lumia
        filter_Lumia.saturation = saturation_Lumia
        filter_Lumia.contrast = contrast_Lumia
        filter_Lumia.brightness = 0
        return filter_Lumia.outputImage ?? image_Lumia
    }

    private static func temperatureShift_Lumia(_ image_Lumia: CIImage, shift_Lumia: Double) -> CIImage {
        let filter_Lumia = CIFilter.temperatureAndTint()
        filter_Lumia.inputImage = image_Lumia
        filter_Lumia.neutral = CIVector(x: 6500, y: 0)
        // shift 为正表示偏暖：降低目标色温值使 CoreImage 自动为画面补偿暖色调
        filter_Lumia.targetNeutral = CIVector(x: CGFloat(6500 - shift_Lumia * 3000), y: 0)
        return filter_Lumia.outputImage ?? image_Lumia
    }

    private static func channelBias_Lumia(_ image_Lumia: CIImage, r_Lumia: Double, g_Lumia: Double, b_Lumia: Double) -> CIImage {
        let filter_Lumia = CIFilter.colorMatrix()
        filter_Lumia.inputImage = image_Lumia
        filter_Lumia.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        filter_Lumia.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        filter_Lumia.bVector = CIVector(x: 0, y: 0, z: 1, w: 0)
        filter_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        // 分色偏移幅度控制在 ±0.15，避免数值过大导致色彩溢出失真
        filter_Lumia.biasVector = CIVector(x: CGFloat(r_Lumia * 0.15), y: CGFloat(g_Lumia * 0.15), z: CGFloat(b_Lumia * 0.15), w: 0)
        return filter_Lumia.outputImage ?? image_Lumia
    }

    private static func applyFog_Lumia(_ image_Lumia: CIImage, intensity_Lumia: Double, extent_Lumia: CGRect) -> CIImage {
        let fogColor_Lumia = CIColor(red: 0.85, green: 0.83, blue: 0.78, alpha: CGFloat(intensity_Lumia * 0.45))
        guard let generator_Lumia = CIFilter(name: "CIConstantColorGenerator") else { return image_Lumia }
        generator_Lumia.setValue(fogColor_Lumia, forKey: kCIInputColorKey)
        guard let fogLayer_Lumia = generator_Lumia.outputImage?.cropped(to: extent_Lumia) else { return image_Lumia }
        let composite_Lumia = CIFilter.sourceOverCompositing()
        composite_Lumia.inputImage = fogLayer_Lumia
        composite_Lumia.backgroundImage = image_Lumia
        return composite_Lumia.outputImage ?? image_Lumia
    }

    private static func applyVignette_Lumia(_ image_Lumia: CIImage, intensity_Lumia: Double) -> CIImage {
        let filter_Lumia = CIFilter.vignette()
        filter_Lumia.inputImage = image_Lumia
        filter_Lumia.radius = 1.6
        filter_Lumia.intensity = Float(intensity_Lumia)
        return filter_Lumia.outputImage ?? image_Lumia
    }

    /// 生成一张灰度随机噪点图（用于颗粒/脏点等效果的基础纹理）
    private static func noiseImage_Lumia(extent_Lumia: CGRect, offset_Lumia: CGPoint) -> CIImage {
        let generator_Lumia = CIFilter.randomGenerator()
        let full_Lumia = generator_Lumia.outputImage ?? CIImage.empty()
        return full_Lumia
            .transformed(by: CGAffineTransform(translationX: offset_Lumia.x, y: offset_Lumia.y))
            .cropped(to: extent_Lumia)
    }

    private static func applyGrain_Lumia(_ image_Lumia: CIImage, intensity_Lumia: Double, extent_Lumia: CGRect) -> CIImage {
        var noise_Lumia = noiseImage_Lumia(extent_Lumia: extent_Lumia, offset_Lumia: .zero)
        // 转灰度
        let gray_Lumia = CIFilter.colorControls()
        gray_Lumia.inputImage = noise_Lumia
        gray_Lumia.saturation = 0
        noise_Lumia = gray_Lumia.outputImage ?? noise_Lumia
        // 向中灰收拢，强度越低颗粒越不明显
        let matrix_Lumia = CIFilter.colorMatrix()
        matrix_Lumia.inputImage = noise_Lumia
        let scale_Lumia = CGFloat(intensity_Lumia)
        let biasComponent_Lumia = 0.5 * (1 - scale_Lumia)
        matrix_Lumia.rVector = CIVector(x: scale_Lumia, y: 0, z: 0, w: 0)
        matrix_Lumia.gVector = CIVector(x: 0, y: scale_Lumia, z: 0, w: 0)
        matrix_Lumia.bVector = CIVector(x: 0, y: 0, z: scale_Lumia, w: 0)
        matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        matrix_Lumia.biasVector = CIVector(x: biasComponent_Lumia, y: biasComponent_Lumia, z: biasComponent_Lumia, w: 0)
        noise_Lumia = matrix_Lumia.outputImage ?? noise_Lumia

        let overlay_Lumia = CIFilter.overlayBlendMode()
        overlay_Lumia.inputImage = noise_Lumia
        overlay_Lumia.backgroundImage = image_Lumia
        return (overlay_Lumia.outputImage ?? image_Lumia).cropped(to: extent_Lumia)
    }

    private static func applyDust_Lumia(_ image_Lumia: CIImage, intensity_Lumia: Double, extent_Lumia: CGRect) -> CIImage {
        var noise_Lumia = noiseImage_Lumia(extent_Lumia: extent_Lumia, offset_Lumia: CGPoint(x: 137, y: 59))
        // 大幅提升对比度，使随机噪点收拢为稀疏的亮斑，模拟脏点/划痕颗粒
        let controls_Lumia = CIFilter.colorControls()
        controls_Lumia.inputImage = noise_Lumia
        controls_Lumia.contrast = 1 + Float(intensity_Lumia) * 14
        controls_Lumia.brightness = -0.35
        controls_Lumia.saturation = 0
        noise_Lumia = controls_Lumia.outputImage ?? noise_Lumia

        let matrix_Lumia = CIFilter.colorMatrix()
        matrix_Lumia.inputImage = noise_Lumia
        matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity_Lumia))
        noise_Lumia = matrix_Lumia.outputImage ?? noise_Lumia

        let screen_Lumia = CIFilter.screenBlendMode()
        screen_Lumia.inputImage = noise_Lumia
        screen_Lumia.backgroundImage = image_Lumia
        return (screen_Lumia.outputImage ?? image_Lumia).cropped(to: extent_Lumia)
    }

    // 通用暖色漏光的两端颜色（供 applyAdjustments_Lumia 的通用漏光效果使用）
    private static let warmLeakColor_Lumia = CIColor(red: 1, green: 0.55, blue: 0.15, alpha: 0.9)
    private static let warmLeakColorEnd_Lumia = CIColor(red: 1, green: 0.85, blue: 0.4, alpha: 0)

    /// 漏光角落枚举（决定径向渐变中心位置）
    private enum LeakCorner_Lumia { case topLeft, topRight, bottomLeft, bottomRight, custom(CGPoint) }

    private static func applyLightLeak_Lumia(
        _ image_Lumia: CIImage, colors_Lumia: [CIColor], corner_Lumia: LeakCorner_Lumia,
        intensity_Lumia: Double, extent_Lumia: CGRect
    ) -> CIImage {
        let center_Lumia: CGPoint
        switch corner_Lumia {
        case .topLeft: center_Lumia = CGPoint(x: extent_Lumia.minX, y: extent_Lumia.maxY)
        case .topRight: center_Lumia = CGPoint(x: extent_Lumia.maxX, y: extent_Lumia.maxY)
        case .bottomLeft: center_Lumia = CGPoint(x: extent_Lumia.minX, y: extent_Lumia.minY)
        case .bottomRight: center_Lumia = CGPoint(x: extent_Lumia.maxX, y: extent_Lumia.minY)
        case .custom(let point_Lumia): center_Lumia = point_Lumia
        }

        let radius_Lumia = Float(max(extent_Lumia.width, extent_Lumia.height)) * 0.75
        let gradient_Lumia = CIFilter.radialGradient()
        gradient_Lumia.center = center_Lumia
        gradient_Lumia.radius0 = 0
        gradient_Lumia.radius1 = radius_Lumia
        gradient_Lumia.color0 = colors_Lumia.first ?? warmLeakColor_Lumia
        gradient_Lumia.color1 = colors_Lumia.last ?? warmLeakColorEnd_Lumia
        guard let leakLayer_Lumia = gradient_Lumia.outputImage?.cropped(to: extent_Lumia) else { return image_Lumia }

        // 用强度控制漏光透明度
        let matrix_Lumia = CIFilter.colorMatrix()
        matrix_Lumia.inputImage = leakLayer_Lumia
        matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity_Lumia))
        let scaledLeak_Lumia = matrix_Lumia.outputImage ?? leakLayer_Lumia

        let screen_Lumia = CIFilter.screenBlendMode()
        screen_Lumia.inputImage = scaledLeak_Lumia
        screen_Lumia.backgroundImage = image_Lumia
        return (screen_Lumia.outputImage ?? image_Lumia).cropped(to: extent_Lumia)
    }

    // MARK: - 私有方法：硬件特效 - 漏光风格

    private static func renderLightLeakStyle_Lumia(
        _ image_Lumia: CIImage, style_Lumia: LightLeakStyle_Lumia, intensity_Lumia: Double, extent_Lumia: CGRect
    ) -> CIImage {
        switch style_Lumia {
        case .none_Lumia:
            return image_Lumia
        case .warm_Lumia:
            let warm_Lumia = CIColor(red: 1, green: 0.45, blue: 0.15, alpha: 0.95)
            let warmEnd_Lumia = CIColor(red: 1, green: 0.75, blue: 0.35, alpha: 0)
            return applyLightLeak_Lumia(image_Lumia, colors_Lumia: [warm_Lumia, warmEnd_Lumia], corner_Lumia: .topRight, intensity_Lumia: intensity_Lumia, extent_Lumia: extent_Lumia)
        case .cool_Lumia:
            let cool_Lumia = CIColor(red: 0.55, green: 0.25, blue: 0.95, alpha: 0.95)
            let coolEnd_Lumia = CIColor(red: 0.35, green: 0.55, blue: 1, alpha: 0)
            return applyLightLeak_Lumia(image_Lumia, colors_Lumia: [cool_Lumia, coolEnd_Lumia], corner_Lumia: .bottomLeft, intensity_Lumia: intensity_Lumia, extent_Lumia: extent_Lumia)
        case .rainbow_Lumia:
            var result_Lumia = image_Lumia
            let blobs_Lumia: [(CIColor, LeakCorner_Lumia)] = [
                (CIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8), .topLeft),
                (CIColor(red: 1, green: 0.9, blue: 0.2, alpha: 0.8), .topRight),
                (CIColor(red: 0.5, green: 0.2, blue: 1, alpha: 0.8), .bottomRight)
            ]
            for (color_Lumia, corner_Lumia) in blobs_Lumia {
                let end_Lumia = CIColor(red: color_Lumia.red, green: color_Lumia.green, blue: color_Lumia.blue, alpha: 0)
                result_Lumia = applyLightLeak_Lumia(result_Lumia, colors_Lumia: [color_Lumia, end_Lumia], corner_Lumia: corner_Lumia, intensity_Lumia: intensity_Lumia * 0.7, extent_Lumia: extent_Lumia)
            }
            return result_Lumia
        case .edge_Lumia:
            let gradient_Lumia = CIFilter.linearGradient()
            gradient_Lumia.point0 = CGPoint(x: extent_Lumia.minX, y: extent_Lumia.midY)
            gradient_Lumia.point1 = CGPoint(x: extent_Lumia.minX + extent_Lumia.width * 0.45, y: extent_Lumia.midY)
            gradient_Lumia.color0 = CIColor(red: 1, green: 0.6, blue: 0.25, alpha: 0.9)
            gradient_Lumia.color1 = CIColor(red: 1, green: 0.8, blue: 0.4, alpha: 0)
            guard let edgeLayer_Lumia = gradient_Lumia.outputImage?.cropped(to: extent_Lumia) else { return image_Lumia }
            let matrix_Lumia = CIFilter.colorMatrix()
            matrix_Lumia.inputImage = edgeLayer_Lumia
            matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity_Lumia))
            let screen_Lumia = CIFilter.screenBlendMode()
            screen_Lumia.inputImage = matrix_Lumia.outputImage ?? edgeLayer_Lumia
            screen_Lumia.backgroundImage = image_Lumia
            return (screen_Lumia.outputImage ?? image_Lumia).cropped(to: extent_Lumia)
        case .random_Lumia:
            var result_Lumia = image_Lumia
            let spotCount_Lumia = 2
            for _ in 0..<spotCount_Lumia {
                let point_Lumia = CGPoint(
                    x: extent_Lumia.minX + CGFloat.random(in: 0...1) * extent_Lumia.width,
                    y: extent_Lumia.minY + CGFloat.random(in: 0...1) * extent_Lumia.height
                )
                let warmish_Lumia = Bool.random()
                let color_Lumia = warmish_Lumia
                    ? CIColor(red: 1, green: 0.6, blue: 0.3, alpha: 0.85)
                    : CIColor(red: 0.6, green: 0.5, blue: 1, alpha: 0.85)
                let end_Lumia = CIColor(red: color_Lumia.red, green: color_Lumia.green, blue: color_Lumia.blue, alpha: 0)
                result_Lumia = applyLightLeak_Lumia(result_Lumia, colors_Lumia: [color_Lumia, end_Lumia], corner_Lumia: .custom(point_Lumia), intensity_Lumia: intensity_Lumia * 0.75, extent_Lumia: extent_Lumia)
            }
            return result_Lumia
        }
    }

    // MARK: - 私有方法：硬件特效 - 镜头瑕疵风格

    private static func renderLensFlawStyle_Lumia(
        _ image_Lumia: CIImage, style_Lumia: LensFlawStyle_Lumia, intensity_Lumia: Double, extent_Lumia: CGRect
    ) -> CIImage {
        switch style_Lumia {
        case .none_Lumia:
            return image_Lumia
        case .chromatic_Lumia:
            return applyChromaticAberration_Lumia(image_Lumia, intensity_Lumia: intensity_Lumia, extent_Lumia: extent_Lumia)
        case .glare_Lumia:
            let center_Lumia = CGPoint(x: extent_Lumia.midX, y: extent_Lumia.maxY - extent_Lumia.height * 0.2)
            return applyGlow_Lumia(image_Lumia, center_Lumia: center_Lumia, color_Lumia: CIColor(red: 1, green: 1, blue: 0.95, alpha: 1), intensity_Lumia: intensity_Lumia, radiusScale_Lumia: 0.55, extent_Lumia: extent_Lumia)
        case .ghost_Lumia:
            var result_Lumia = image_Lumia
            let center_Lumia = CGPoint(x: extent_Lumia.midX, y: extent_Lumia.midY)
            let offsets_Lumia: [CGFloat] = [0.35, 0.6]
            for offset_Lumia in offsets_Lumia {
                let point_Lumia = CGPoint(
                    x: center_Lumia.x + (extent_Lumia.midX - center_Lumia.x) * offset_Lumia + extent_Lumia.width * 0.15,
                    y: center_Lumia.y + extent_Lumia.height * 0.15 * offset_Lumia
                )
                result_Lumia = applyGlow_Lumia(result_Lumia, center_Lumia: point_Lumia, color_Lumia: CIColor(red: 0.9, green: 0.95, blue: 1, alpha: 1), intensity_Lumia: intensity_Lumia * 0.5, radiusScale_Lumia: 0.18, extent_Lumia: extent_Lumia)
            }
            return result_Lumia
        case .vintageSoft_Lumia:
            let blur_Lumia = CIFilter.gaussianBlur()
            blur_Lumia.inputImage = image_Lumia
            blur_Lumia.radius = Float(intensity_Lumia) * 12
            guard let blurred_Lumia = blur_Lumia.outputImage?.cropped(to: extent_Lumia) else { return image_Lumia }
            let matrix_Lumia = CIFilter.colorMatrix()
            matrix_Lumia.inputImage = blurred_Lumia
            matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity_Lumia * 0.5))
            let composite_Lumia = CIFilter.sourceOverCompositing()
            composite_Lumia.inputImage = matrix_Lumia.outputImage ?? blurred_Lumia
            composite_Lumia.backgroundImage = image_Lumia
            return (composite_Lumia.outputImage ?? image_Lumia).cropped(to: extent_Lumia)
        case .spherical_Lumia:
            let distortion_Lumia = CIFilter.bumpDistortion()
            distortion_Lumia.inputImage = image_Lumia
            distortion_Lumia.center = CGPoint(x: extent_Lumia.midX, y: extent_Lumia.midY)
            distortion_Lumia.radius = Float(min(extent_Lumia.width, extent_Lumia.height)) * 0.5
            distortion_Lumia.scale = Float(intensity_Lumia) * 0.4
            return (distortion_Lumia.outputImage ?? image_Lumia).cropped(to: extent_Lumia)
        }
    }

    /// 通用光斑叠加（用于眩光/鬼影）
    private static func applyGlow_Lumia(
        _ image_Lumia: CIImage, center_Lumia: CGPoint, color_Lumia: CIColor,
        intensity_Lumia: Double, radiusScale_Lumia: CGFloat, extent_Lumia: CGRect
    ) -> CIImage {
        let radius_Lumia = Float(max(extent_Lumia.width, extent_Lumia.height) * radiusScale_Lumia)
        let gradient_Lumia = CIFilter.radialGradient()
        gradient_Lumia.center = center_Lumia
        gradient_Lumia.radius0 = 0
        gradient_Lumia.radius1 = radius_Lumia
        gradient_Lumia.color0 = color_Lumia
        gradient_Lumia.color1 = CIColor(red: color_Lumia.red, green: color_Lumia.green, blue: color_Lumia.blue, alpha: 0)
        guard let glowLayer_Lumia = gradient_Lumia.outputImage?.cropped(to: extent_Lumia) else { return image_Lumia }
        let matrix_Lumia = CIFilter.colorMatrix()
        matrix_Lumia.inputImage = glowLayer_Lumia
        matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity_Lumia))
        let screen_Lumia = CIFilter.screenBlendMode()
        screen_Lumia.inputImage = matrix_Lumia.outputImage ?? glowLayer_Lumia
        screen_Lumia.backgroundImage = image_Lumia
        return (screen_Lumia.outputImage ?? image_Lumia).cropped(to: extent_Lumia)
    }

    /// 色散（提取三通道分别做水平位移后叠加，模拟镜头色散边缘）
    private static func applyChromaticAberration_Lumia(_ image_Lumia: CIImage, intensity_Lumia: Double, extent_Lumia: CGRect) -> CIImage {
        let dx_Lumia = CGFloat(intensity_Lumia) * 10

        func isolateChannel_Lumia(_ vector_Lumia: CIVector, offset_Lumia: CGFloat) -> CIImage {
            let matrix_Lumia = CIFilter.colorMatrix()
            matrix_Lumia.inputImage = image_Lumia
            matrix_Lumia.rVector = vector_Lumia
            matrix_Lumia.gVector = vector_Lumia
            matrix_Lumia.bVector = vector_Lumia
            matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
            let channelGray_Lumia = matrix_Lumia.outputImage ?? image_Lumia
            return channelGray_Lumia.transformed(by: CGAffineTransform(translationX: offset_Lumia, y: 0))
        }

        let redChannel_Lumia = isolateChannel_Lumia(CIVector(x: 1, y: 0, z: 0, w: 0), offset_Lumia: dx_Lumia)
        let blueChannel_Lumia = isolateChannel_Lumia(CIVector(x: 0, y: 0, z: 1, w: 0), offset_Lumia: -dx_Lumia)

        // 将偏移后的红/蓝通道灰度图重新映射回各自颜色通道，再与原图做加色混合，制造边缘色散
        func tint_Lumia(_ gray_Lumia: CIImage, rVector_Lumia: CIVector, gVector_Lumia: CIVector, bVector_Lumia: CIVector) -> CIImage {
            let matrix_Lumia = CIFilter.colorMatrix()
            matrix_Lumia.inputImage = gray_Lumia
            matrix_Lumia.rVector = rVector_Lumia
            matrix_Lumia.gVector = gVector_Lumia
            matrix_Lumia.bVector = bVector_Lumia
            matrix_Lumia.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity_Lumia) * 0.6)
            return matrix_Lumia.outputImage ?? gray_Lumia
        }

        let redTinted_Lumia = tint_Lumia(redChannel_Lumia, rVector_Lumia: CIVector(x: 1, y: 0, z: 0, w: 0), gVector_Lumia: .init(x: 0, y: 0, z: 0, w: 0), bVector_Lumia: .init(x: 0, y: 0, z: 0, w: 0))
        let blueTinted_Lumia = tint_Lumia(blueChannel_Lumia, rVector_Lumia: .init(x: 0, y: 0, z: 0, w: 0), gVector_Lumia: .init(x: 0, y: 0, z: 0, w: 0), bVector_Lumia: CIVector(x: 0, y: 0, z: 1, w: 0))

        let screen1_Lumia = CIFilter.screenBlendMode()
        screen1_Lumia.inputImage = redTinted_Lumia
        screen1_Lumia.backgroundImage = image_Lumia
        let step1_Lumia = screen1_Lumia.outputImage ?? image_Lumia

        let screen2_Lumia = CIFilter.screenBlendMode()
        screen2_Lumia.inputImage = blueTinted_Lumia
        screen2_Lumia.backgroundImage = step1_Lumia
        return (screen2_Lumia.outputImage ?? step1_Lumia).cropped(to: extent_Lumia)
    }

    // MARK: - 私有方法：渲染输出

    private static func render_Lumia(_ image_Lumia: CIImage, extent_Lumia: CGRect) -> UIImage? {
        guard let cgImage_Lumia = context_Lumia.createCGImage(image_Lumia, from: extent_Lumia) else { return nil }
        return UIImage(cgImage: cgImage_Lumia)
    }

    // MARK: - 私有方法：底片瑕疵（Core Graphics 矢量叠加）

    private static func drawNegativeFlaw_Lumia(on image_Lumia: UIImage, style_Lumia: NegativeFlawStyle_Lumia, intensity_Lumia: Double) -> UIImage {
        let renderer_Lumia = UIGraphicsImageRenderer(size: image_Lumia.size)
        return renderer_Lumia.image { ctx_Lumia in
            image_Lumia.draw(at: .zero)
            let cg_Lumia = ctx_Lumia.cgContext
            let size_Lumia = image_Lumia.size
            let count_Lumia = Int(6 + intensity_Lumia * 30)

            switch style_Lumia {
            case .none_Lumia:
                break
            case .dust_Lumia:
                for _ in 0..<count_Lumia {
                    let radius_Lumia = CGFloat.random(in: 0.5...2.2)
                    let point_Lumia = randomPoint_Lumia(in: size_Lumia)
                    cg_Lumia.setFillColor(UIColor.white.withAlphaComponent(CGFloat.random(in: 0.25...0.6)).cgColor)
                    cg_Lumia.fillEllipse(in: CGRect(x: point_Lumia.x, y: point_Lumia.y, width: radius_Lumia, height: radius_Lumia))
                }
            case .scratches_Lumia:
                for _ in 0..<max(2, count_Lumia / 4) {
                    let x_Lumia = CGFloat.random(in: 0...size_Lumia.width)
                    let length_Lumia = size_Lumia.height * CGFloat.random(in: 0.3...1.0)
                    let startY_Lumia = CGFloat.random(in: 0...(size_Lumia.height - length_Lumia))
                    cg_Lumia.setStrokeColor(UIColor.white.withAlphaComponent(CGFloat.random(in: 0.25...0.5)).cgColor)
                    cg_Lumia.setLineWidth(CGFloat.random(in: 0.5...1.2))
                    cg_Lumia.move(to: CGPoint(x: x_Lumia, y: startY_Lumia))
                    cg_Lumia.addLine(to: CGPoint(x: x_Lumia + CGFloat.random(in: -6...6), y: startY_Lumia + length_Lumia))
                    cg_Lumia.strokePath()
                }
            case .waterMark_Lumia:
                for _ in 0..<max(2, count_Lumia / 6) {
                    let point_Lumia = randomPoint_Lumia(in: size_Lumia)
                    let radius_Lumia = min(size_Lumia.width, size_Lumia.height) * CGFloat.random(in: 0.08...0.20)
                    let gradient_Lumia = CGGradient(
                        colorsSpace: CGColorSpaceCreateDeviceRGB(),
                        colors: [
                            UIColor(hexstring_Lumia: "#B8D4C8", alpha_Lumia: CGFloat(intensity_Lumia * 0.28)).cgColor,
                            UIColor(hexstring_Lumia: "#B8D4C8", alpha_Lumia: 0).cgColor
                        ] as CFArray,
                        locations: [0, 1]
                    )
                    if let gradient_Lumia = gradient_Lumia {
                        cg_Lumia.drawRadialGradient(
                            gradient_Lumia, startCenter: point_Lumia, startRadius: 0,
                            endCenter: point_Lumia, endRadius: radius_Lumia, options: []
                        )
                    }
                }
            case .mold_Lumia:
                for _ in 0..<max(3, count_Lumia / 3) {
                    let point_Lumia = randomPoint_Lumia(in: size_Lumia)
                    let radius_Lumia = CGFloat.random(in: 3...14)
                    let gradient_Lumia = CGGradient(
                        colorsSpace: CGColorSpaceCreateDeviceRGB(),
                        colors: [
                            UIColor(hexstring_Lumia: "#5A5030", alpha_Lumia: CGFloat(intensity_Lumia * 0.5)).cgColor,
                            UIColor(hexstring_Lumia: "#5A5030", alpha_Lumia: 0).cgColor
                        ] as CFArray,
                        locations: [0, 1]
                    )
                    if let gradient_Lumia = gradient_Lumia {
                        cg_Lumia.drawRadialGradient(
                            gradient_Lumia, startCenter: point_Lumia, startRadius: 0,
                            endCenter: point_Lumia, endRadius: radius_Lumia, options: []
                        )
                    }
                }
            case .pinhole_Lumia:
                for _ in 0..<max(2, count_Lumia / 5) {
                    let point_Lumia = randomPoint_Lumia(in: size_Lumia)
                    let radius_Lumia = CGFloat.random(in: 1...2.5)
                    cg_Lumia.setFillColor(UIColor.white.withAlphaComponent(CGFloat.random(in: 0.6...0.9)).cgColor)
                    cg_Lumia.fillEllipse(in: CGRect(x: point_Lumia.x, y: point_Lumia.y, width: radius_Lumia, height: radius_Lumia))
                }
            }
        }
    }

    private static func randomPoint_Lumia(in size_Lumia: CGSize) -> CGPoint {
        CGPoint(x: CGFloat.random(in: 0...size_Lumia.width), y: CGFloat.random(in: 0...size_Lumia.height))
    }

    // MARK: - 私有方法：相纸边框（Core Graphics 矢量绘制）

    private static func drawBorder_Lumia(
        on image_Lumia: UIImage, style_Lumia: FilmBorderStyle_Lumia, thickness_Lumia: Double,
        showPerforations_Lumia: Bool, watermarkText_Lumia: String
    ) -> UIImage {
        let baseThickness_Lumia = CGFloat(14 + thickness_Lumia * 60)
        var top_Lumia = baseThickness_Lumia, left_Lumia = baseThickness_Lumia
        var right_Lumia = baseThickness_Lumia, bottom_Lumia = baseThickness_Lumia
        var borderColor_Lumia = UIColor.black

        switch style_Lumia {
        case .none_Lumia:
            return image_Lumia
        case .frame135_Lumia:
            top_Lumia = baseThickness_Lumia * 1.4; bottom_Lumia = baseThickness_Lumia * 1.4
            borderColor_Lumia = .black
        case .frame120_Lumia:
            borderColor_Lumia = .black
        case .polaroid_Lumia:
            bottom_Lumia = baseThickness_Lumia * 3.2
            borderColor_Lumia = .white
        case .halfFrame_Lumia:
            top_Lumia = baseThickness_Lumia * 1.1; bottom_Lumia = baseThickness_Lumia * 1.1
            left_Lumia = baseThickness_Lumia * 0.6; right_Lumia = baseThickness_Lumia * 0.6
            borderColor_Lumia = .black
        case .twinLensSquare_Lumia:
            borderColor_Lumia = .black
        case .disposable_Lumia:
            borderColor_Lumia = .white
        }

        let originalSize_Lumia = image_Lumia.size
        let canvasSize_Lumia = CGSize(width: originalSize_Lumia.width + left_Lumia + right_Lumia, height: originalSize_Lumia.height + top_Lumia + bottom_Lumia)

        let renderer_Lumia = UIGraphicsImageRenderer(size: canvasSize_Lumia)
        return renderer_Lumia.image { ctx_Lumia in
            let cg_Lumia = ctx_Lumia.cgContext
            borderColor_Lumia.setFill()
            cg_Lumia.fill(CGRect(origin: .zero, size: canvasSize_Lumia))

            image_Lumia.draw(at: CGPoint(x: left_Lumia, y: top_Lumia))

            let textColor_Lumia = borderColor_Lumia == .white ? UIColor.black.withAlphaComponent(0.55) : UIColor.white.withAlphaComponent(0.7)

            // 齿孔（沿上下边框绘制一排小圆孔，仅 135/半格 边框风格常见）
            if showPerforations_Lumia && (style_Lumia == .frame135_Lumia || style_Lumia == .halfFrame_Lumia) {
                drawPerforations_Lumia(cg_Lumia, canvasSize_Lumia: canvasSize_Lumia, topHeight_Lumia: top_Lumia, bottomHeight_Lumia: bottom_Lumia)
            }

            // 编号水印
            if !watermarkText_Lumia.isEmpty {
                let attrs_Lumia: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: max(10, baseThickness_Lumia * 0.32), weight: .semibold),
                    .foregroundColor: textColor_Lumia
                ]
                let text_Lumia = NSAttributedString(string: watermarkText_Lumia, attributes: attrs_Lumia)
                let textSize_Lumia = text_Lumia.size()
                let point_Lumia = CGPoint(
                    x: canvasSize_Lumia.width - textSize_Lumia.width - 14,
                    y: canvasSize_Lumia.height - bottom_Lumia * 0.5 - textSize_Lumia.height * 0.5
                )
                text_Lumia.draw(at: point_Lumia)
            }
        }
    }

    private static func drawPerforations_Lumia(_ cg_Lumia: CGContext, canvasSize_Lumia: CGSize, topHeight_Lumia: CGFloat, bottomHeight_Lumia: CGFloat) {
        let holeWidth_Lumia: CGFloat = 10
        let holeHeight_Lumia: CGFloat = 7
        let spacing_Lumia: CGFloat = 16
        let count_Lumia = Int(canvasSize_Lumia.width / (holeWidth_Lumia + spacing_Lumia))
        cg_Lumia.setFillColor(UIColor.black.withAlphaComponent(0.55).cgColor)

        for i_Lumia in 0..<count_Lumia {
            let x_Lumia = CGFloat(i_Lumia) * (holeWidth_Lumia + spacing_Lumia) + spacing_Lumia / 2
            let topRect_Lumia = CGRect(x: x_Lumia, y: topHeight_Lumia * 0.35, width: holeWidth_Lumia, height: holeHeight_Lumia)
            let bottomRect_Lumia = CGRect(x: x_Lumia, y: canvasSize_Lumia.height - bottomHeight_Lumia * 0.65, width: holeWidth_Lumia, height: holeHeight_Lumia)
            cg_Lumia.fillPath(in: UIBezierPath(roundedRect: topRect_Lumia, cornerRadius: 2).cgPath)
            cg_Lumia.fillPath(in: UIBezierPath(roundedRect: bottomRect_Lumia, cornerRadius: 2).cgPath)
        }
    }
}

private extension CGContext {
    /// 便捷方法：以路径直接填充（供齿孔绘制复用）
    func fillPath(in path_Lumia: CGPath) {
        addPath(path_Lumia)
        fillPath()
    }
}
