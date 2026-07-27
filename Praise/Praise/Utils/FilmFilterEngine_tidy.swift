import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: 胶片滤镜与渐变滤镜处理引擎

/// 胶片滤镜与渐变滤镜处理引擎
/// 核心作用：基于 CoreImage 对预览图片施加胶片风格模拟效果与径向/线性渐变压暗提亮效果
/// 设计思路：
///   胶片风格通过 CIColorControls + CITemperatureAndTint + CIVignette 参数化模拟；
///   若预设关联了真实 .cube LUT 文件（当前预制数据均为空），优先通过 loadCubeLUT_Tidy 加载
///   CIColorCube 滤镜叠加使用，为后续替换真实素材预留能力；
///   渐变滤镜通过 CIRadialGradient / CILinearGradient 生成蒙版后与原图混合，实现压暗天空/提亮前景。
/// 关键属性/方法：
///   - shared_Tidy：共享实例，内部持有单个 CIContext 避免重复创建开销
///   - applyFilmFilter_Tidy：应用胶片滤镜
///   - applyGradientFilter_Tidy：应用渐变滤镜
///   - loadCubeLUT_Tidy：解析 .cube 文件构建 LUT 滤镜（基础设施预留）
class FilmFilterEngine_Tidy {

    /// 共享实例
    static let shared_Tidy = FilmFilterEngine_Tidy()

    /// 复用的 CoreImage 上下文（GPU 加速渲染，避免频繁创建）
    private let context_Tidy = CIContext()

    private init() {}

    // MARK: - 胶片滤镜

    /// 对图片应用胶片滤镜预设，模拟对应胶片风格调色
    /// 参数：
    /// - preset_tidy: 胶片滤镜预设参数
    /// - image_tidy: 原始图片
    /// 返回值：处理后的 UIImage，处理失败时返回 nil
    func applyFilmFilter_Tidy(preset_tidy: FilmFilterPreset_Tidy, to image_tidy: UIImage) -> UIImage? {
        guard let ciImage_tidy = CIImage(image: image_tidy) else { return nil }
        var output_tidy = ciImage_tidy

        // 若配置了真实 LUT 文件且加载成功，优先叠加 LUT 上色，否则走参数化模拟
        if let lutFileName_tidy = preset_tidy.lutFileName_Tidy,
           let lutFilter_tidy = loadCubeLUT_Tidy(fileName_tidy: lutFileName_tidy) {
            lutFilter_tidy.setValue(output_tidy, forKey: kCIInputImageKey)
            output_tidy = lutFilter_tidy.outputImage ?? output_tidy
        }

        // 色彩控制：饱和度 / 对比度 / 曝光近似（brightness 映射曝光）
        let colorFilter_tidy = CIFilter.colorControls()
        colorFilter_tidy.inputImage = output_tidy
        colorFilter_tidy.saturation = preset_tidy.saturation_Tidy
        colorFilter_tidy.contrast   = preset_tidy.contrast_Tidy
        colorFilter_tidy.brightness = preset_tidy.exposure_Tidy
        output_tidy = colorFilter_tidy.outputImage ?? output_tidy

        // 色温色调
        let tempFilter_tidy = CIFilter.temperatureAndTint()
        tempFilter_tidy.inputImage    = output_tidy
        tempFilter_tidy.neutral       = CIVector(x: 6500 + CGFloat(preset_tidy.temperature_Tidy), y: CGFloat(preset_tidy.tint_Tidy))
        tempFilter_tidy.targetNeutral = CIVector(x: 6500, y: 0)
        output_tidy = tempFilter_tidy.outputImage ?? output_tidy

        // 暗角
        if preset_tidy.vignette_Tidy > 0 {
            let vignetteFilter_tidy = CIFilter.vignette()
            vignetteFilter_tidy.inputImage = output_tidy
            vignetteFilter_tidy.intensity  = preset_tidy.vignette_Tidy * 2
            vignetteFilter_tidy.radius     = 1.6
            output_tidy = vignetteFilter_tidy.outputImage ?? output_tidy
        }

        return renderImage_Tidy(ciImage_tidy: output_tidy, extent_tidy: ciImage_tidy.extent)
    }

    // MARK: - LUT 加载（基础设施预留）

    /// 解析 .cube 格式 LUT 文件并构建 CIColorCube 滤镜
    /// 功能：从 Bundle 或 Documents 目录中查找同名 .cube 文件，解析 LUT_3D_SIZE 与颜色数据表，
    ///       构建可直接应用的 CIColorCube 滤镜；当前项目未内置真实 .cube 文件，找不到时返回 nil，
    ///       后续放入真实素材文件即可自动生效，无需修改调用方代码
    /// 参数：
    /// - fileName_tidy: LUT 文件名（如 "cinematic_teal_orange.cube"）
    /// 返回值：配置好的 CIFilter（colorCube），解析失败或文件不存在时返回 nil
    func loadCubeLUT_Tidy(fileName_tidy: String) -> CIFilter? {
        let fileURL_tidy: URL
        if let bundleURL_tidy = Bundle.main.url(forResource: fileName_tidy, withExtension: nil) {
            fileURL_tidy = bundleURL_tidy
        } else {
            guard let docsURL_tidy = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            fileURL_tidy = docsURL_tidy.appendingPathComponent(fileName_tidy)
        }
        guard FileManager.default.fileExists(atPath: fileURL_tidy.path),
              let content_tidy = try? String(contentsOf: fileURL_tidy, encoding: .utf8) else {
            return nil
        }

        var size_tidy = 0
        var cubeData_tidy: [Float] = []
        for line_tidy in content_tidy.split(separator: "\n") {
            let trimmed_tidy = line_tidy.trimmingCharacters(in: .whitespaces)
            if trimmed_tidy.hasPrefix("LUT_3D_SIZE") {
                let parts_tidy = trimmed_tidy.split(separator: " ")
                if parts_tidy.count > 1 { size_tidy = Int(parts_tidy[1]) ?? 0 }
            } else if let firstChar_tidy = trimmed_tidy.first, firstChar_tidy.isNumber || firstChar_tidy == "-" {
                let comps_tidy = trimmed_tidy.split(separator: " ").compactMap { Float($0) }
                if comps_tidy.count == 3 {
                    cubeData_tidy.append(contentsOf: [comps_tidy[0], comps_tidy[1], comps_tidy[2], 1.0])
                }
            }
        }
        guard size_tidy > 0, cubeData_tidy.count == size_tidy * size_tidy * size_tidy * 4 else { return nil }

        let data_tidy = cubeData_tidy.withUnsafeBufferPointer { Data(buffer: $0) }
        let filter_tidy = CIFilter.colorCube()
        filter_tidy.cubeDimension = Float(size_tidy)
        filter_tidy.cubeData      = data_tidy
        return filter_tidy
    }

    // MARK: - 渐变滤镜

    /// 对图片应用径向/线性渐变滤镜，压暗天空或提亮前景
    /// 参数：
    /// - config_tidy: 渐变滤镜配置
    /// - image_tidy: 原始图片
    /// 返回值：处理后的 UIImage，处理失败时返回 nil
    func applyGradientFilter_Tidy(config_tidy: GradientFilterConfig_Tidy, to image_tidy: UIImage) -> UIImage? {
        guard let ciImage_tidy = CIImage(image: image_tidy) else { return nil }
        let extent_tidy = ciImage_tidy.extent
        guard extent_tidy.width > 0, extent_tidy.height > 0 else { return nil }

        // 构建蒙版：darkenSky 作用于上半部分，brightenForeground 作用于下半部分
        let maskImage_tidy = makeGradientMask_Tidy(config_tidy: config_tidy, extent_tidy: extent_tidy)

        // 目标调整层：压暗用纯黑图混合，提亮用纯白图混合
        let isDarken_tidy = config_tidy.mode_Tidy == .darkenSky_tidy
        let adjustColor_tidy = isDarken_tidy ? CIColor(red: 0, green: 0, blue: 0) : CIColor(red: 1, green: 1, blue: 1)
        let adjustImage_tidy = CIImage(color: adjustColor_tidy).cropped(to: extent_tidy)

        let blendFilter_tidy = CIFilter.blendWithMask()
        blendFilter_tidy.inputImage      = adjustImage_tidy
        blendFilter_tidy.backgroundImage = ciImage_tidy
        blendFilter_tidy.maskImage       = maskImage_tidy
        guard let output_tidy = blendFilter_tidy.outputImage else { return nil }

        return renderImage_Tidy(ciImage_tidy: output_tidy, extent_tidy: extent_tidy)
    }

    /// 根据渐变配置生成灰度蒙版（白色/高透明区域=完全应用效果，黑色/低透明区域=不应用）
    /// 参数：
    /// - config_tidy: 渐变滤镜配置
    /// - extent_tidy: 原图范围
    /// 返回值：裁剪到原图范围内的蒙版 CIImage
    private func makeGradientMask_Tidy(config_tidy: GradientFilterConfig_Tidy, extent_tidy: CGRect) -> CIImage {
        let intensity_tidy = CGFloat(min(max(config_tidy.intensity_Tidy, 0), 1))
        let isDarkenSky_tidy = config_tidy.mode_Tidy == .darkenSky_tidy

        switch config_tidy.type_Tidy {
        case .linear_tidy:
            let gradient_tidy = CIFilter.linearGradient()
            // darkenSky：从顶部到中部由强转弱；brightenForeground：从底部到中部由强转弱
            let topPoint_tidy    = CGPoint(x: extent_tidy.midX, y: extent_tidy.maxY)
            let bottomPoint_tidy = CGPoint(x: extent_tidy.midX, y: extent_tidy.minY)
            gradient_tidy.point0 = isDarkenSky_tidy ? topPoint_tidy : bottomPoint_tidy
            gradient_tidy.point1 = CGPoint(x: extent_tidy.midX, y: extent_tidy.midY)
            gradient_tidy.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: intensity_tidy)
            gradient_tidy.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            return (gradient_tidy.outputImage ?? CIImage.empty()).cropped(to: extent_tidy)

        case .radial_tidy:
            let gradient_tidy = CIFilter.radialGradient()
            let center_tidy = isDarkenSky_tidy
                ? CGPoint(x: extent_tidy.midX, y: extent_tidy.maxY)
                : CGPoint(x: extent_tidy.midX, y: extent_tidy.minY)
            let radius_tidy = max(extent_tidy.width, extent_tidy.height) * 0.6
            gradient_tidy.center  = center_tidy
            gradient_tidy.radius0 = 0
            gradient_tidy.radius1 = Float(radius_tidy)
            gradient_tidy.color0  = CIColor(red: 1, green: 1, blue: 1, alpha: intensity_tidy)
            gradient_tidy.color1  = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            return (gradient_tidy.outputImage ?? CIImage.empty()).cropped(to: extent_tidy)
        }
    }

    // MARK: - 渲染工具

    /// 将 CIImage 渲染为 UIImage
    /// 参数：
    /// - ciImage_tidy: 待渲染的 CIImage
    /// - extent_tidy: 渲染范围
    /// 返回值：渲染后的 UIImage，渲染失败时返回 nil
    private func renderImage_Tidy(ciImage_tidy: CIImage, extent_tidy: CGRect) -> UIImage? {
        guard let cgImage_tidy = context_Tidy.createCGImage(ciImage_tidy, from: extent_tidy) else { return nil }
        return UIImage(cgImage: cgImage_tidy)
    }
}
