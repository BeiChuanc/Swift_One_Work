import Foundation
import UIKit
import SnapKit

// MARK: - 图片预览控制器

/// 图片预览控制器
/// 功能：全屏预览图片，支持缩放、滑动切换
/// 特性：手势关闭、双击缩放、捏合缩放、滑动切换
class ImagePreviewController_Glasspaint: UIViewController {
    
    // MARK: - UI属性
    
    /// 滚动视图
    private let scrollView_Glasspaint = UIScrollView()
    
    /// 图片视图
    private let imageView_Glasspaint = UIImageView()
    
    /// 关闭按钮
    private let closeButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 数据属性
    
    /// 要显示的图片
    private let image_Glasspaint: UIImage
    
    // MARK: - 初始化
    
    /// 初始化
    /// 参数：
    /// - image_glasspaint: 要预览的图片
    init(image_glasspaint: UIImage) {
        self.image_Glasspaint = image_glasspaint
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.delegate = self
        scrollView_Glasspaint.minimumZoomScale = 1.0
        scrollView_Glasspaint.maximumZoomScale = 3.0
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.showsHorizontalScrollIndicator = false
        
        // 图片视图
        scrollView_Glasspaint.addSubview(imageView_Glasspaint)
        imageView_Glasspaint.image = image_Glasspaint
        imageView_Glasspaint.contentMode = .scaleAspectFit
        imageView_Glasspaint.isUserInteractionEnabled = true
        
        // 关闭按钮
        view.addSubview(closeButton_Glasspaint)
        closeButton_Glasspaint.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton_Glasspaint.tintColor = .white
        closeButton_Glasspaint.addTarget(self, action: #selector(handleCloseTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(view.snp.width).priority(.low)
        }
        
        closeButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
        
        // 添加双击缩放手势
        let doubleTap_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Glasspaint(_:)))
        doubleTap_glasspaint.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap_glasspaint)
        
        // 添加单击关闭手势
        let singleTap_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Glasspaint))
        singleTap_glasspaint.numberOfTapsRequired = 1
        singleTap_glasspaint.require(toFail: doubleTap_glasspaint)
        view.addGestureRecognizer(singleTap_glasspaint)
    }
    
    // MARK: - 事件处理
    
    /// 处理关闭按钮
    @objc private func handleCloseTap_Glasspaint() {
        dismiss(animated: true)
    }
    
    /// 处理单击（关闭）
    @objc private func handleSingleTap_Glasspaint() {
        dismiss(animated: true)
    }
    
    /// 处理双击（缩放）
    /// 参数：
    /// - gesture_glasspaint: 双击手势
    @objc private func handleDoubleTap_Glasspaint(_ gesture_glasspaint: UITapGestureRecognizer) {
        if scrollView_Glasspaint.zoomScale > 1.0 {
            // 缩小到正常尺寸
            scrollView_Glasspaint.setZoomScale(1.0, animated: true)
        } else {
            // 放大到2倍
            let location_glasspaint = gesture_glasspaint.location(in: imageView_Glasspaint)
            let zoomRect_glasspaint = calculateZoomRect_Glasspaint(
                center_glasspaint: location_glasspaint,
                scale_glasspaint: 2.0
            )
            scrollView_Glasspaint.zoom(to: zoomRect_glasspaint, animated: true)
        }
    }
    
    /// 计算缩放区域
    /// 参数：
    /// - center_glasspaint: 中心点
    /// - scale_glasspaint: 缩放比例
    /// 返回：缩放区域
    private func calculateZoomRect_Glasspaint(center_glasspaint: CGPoint, scale_glasspaint: CGFloat) -> CGRect {
        let width_glasspaint = scrollView_Glasspaint.bounds.width / scale_glasspaint
        let height_glasspaint = scrollView_Glasspaint.bounds.height / scale_glasspaint
        let x_glasspaint = center_glasspaint.x - (width_glasspaint / 2.0)
        let y_glasspaint = center_glasspaint.y - (height_glasspaint / 2.0)
        
        return CGRect(x: x_glasspaint, y: y_glasspaint, width: width_glasspaint, height: height_glasspaint)
    }
}

// MARK: - UIScrollViewDelegate

extension ImagePreviewController_Glasspaint: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView_Glasspaint
    }
}
