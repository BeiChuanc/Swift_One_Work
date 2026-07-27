import Foundation
import UIKit

// MARK: 防抖异步图片渲染器

/// 防抖异步图片渲染器
/// 核心作用：将耗时的滤镜渲染任务放到后台队列执行，避免在主线程同步渲染导致滑块拖动卡顿；
///          若渲染耗时期间又产生了新的渲染请求，则只保留最新一次参数，丢弃排队中的旧请求，
///          防止快速拖动滑块时渲染任务持续堆积、越拖越卡
/// 设计思路：
///   - 同一时刻只允许一个渲染任务在后台队列执行（isRendering_Lumia 作为互斥标记）
///   - 渲染期间到达的新请求仅覆盖 pendingRequest_Lumia，等当前渲染完成后自动触发最新一次
/// 关键属性：
///   - Params: 泛型参数类型（如 FilmAdjustmentParams_Lumia / HardwareEffectParams_Lumia）
class DebouncedImageRenderer_Lumia<Params> {

    /// 单次渲染请求的三元组：参数、渲染函数、完成回调
    private typealias RenderRequest_Lumia = (params: Params, render: (Params) -> UIImage?, completion: (UIImage?) -> Void)

    private let queue_Lumia = DispatchQueue(label: "com.lumia.debouncedImageRenderer", qos: .userInteractive)
    private var isRendering_Lumia = false
    private var pendingRequest_Lumia: RenderRequest_Lumia?

    /// 提交一次渲染请求
    /// - Parameters:
    ///   - params_Lumia: 本次渲染所需的参数快照
    ///   - render_Lumia: 实际执行渲染的纯函数（将在后台队列调用，避免阻塞主线程/UI）
    ///   - completion_Lumia: 渲染完成后的回调（自动在主线程调用，可直接更新 UI）
    func request_Lumia(params_Lumia: Params, render_Lumia: @escaping (Params) -> UIImage?, completion_Lumia: @escaping (UIImage?) -> Void) {
        if isRendering_Lumia {
            // 已有渲染在进行中：仅记录最新参数，待当前渲染完成后自动接续，丢弃期间的中间值
            pendingRequest_Lumia = (params_Lumia, render_Lumia, completion_Lumia)
            return
        }
        start_Lumia(request_Lumia: (params_Lumia, render_Lumia, completion_Lumia))
    }

    private func start_Lumia(request_Lumia: RenderRequest_Lumia) {
        isRendering_Lumia = true
        queue_Lumia.async { [weak self] in
            let result_Lumia = request_Lumia.render(request_Lumia.params)
            DispatchQueue.main.async {
                request_Lumia.completion(result_Lumia)
                guard let self = self else { return }
                self.isRendering_Lumia = false
                if let next_Lumia = self.pendingRequest_Lumia {
                    self.pendingRequest_Lumia = nil
                    self.start_Lumia(request_Lumia: next_Lumia)
                }
            }
        }
    }
}
