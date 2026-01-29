import Foundation
import UIKit
import SnapKit

// MARK: 情绪选择器

/// 情绪选择器视图
/// 功能：底部弹出的情绪选择面板，支持选择情绪类型和强度
/// 设计：毛玻璃背景、网格布局、强度滑块
class EmotionPickerView_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// 背景遮罩
    private let overlayView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view_wanderbell.alpha = 0
        return view_wanderbell
    }()
    
    /// 内容容器
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 24
        view_wanderbell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view_wanderbell
    }()
    
    /// 标题标签
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "How are you feeling?"
        label_wanderbell.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 情绪网格容器
    private let emotionsGridView_Wanderbell = UIView()
    
    /// 强度滑块
    private let intensitySlider_Wanderbell = IntensitySlider_Wanderbell()
    
    // MARK: - 属性
    
    /// 选中的情绪类型
    private var selectedEmotion_Wanderbell: EmotionType_Wanderbell?
    
    /// 情绪选择回调
    var onEmotionSelected_Wanderbell: ((EmotionType_Wanderbell, Int) -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        addSubview(overlayView_Wanderbell)
        addSubview(containerView_Wanderbell)
        
        containerView_Wanderbell.addSubview(titleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(emotionsGridView_Wanderbell)
        containerView_Wanderbell.addSubview(intensitySlider_Wanderbell)
        
        setupEmotionButtons_Wanderbell()
        
        overlayView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(500)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.right.equalToSuperview().inset(20)
        }
        
        emotionsGridView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(280)
        }
        
        intensitySlider_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(emotionsGridView_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        // 点击遮罩关闭
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(dismiss_Wanderbell))
        overlayView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    /// 设置情绪按钮
    private func setupEmotionButtons_Wanderbell() {
        let emotionTypes_wanderbell = EmotionType_Wanderbell.getAllBasicTypes_Wanderbell()
        let columns_wanderbell = 3
        _ = (emotionTypes_wanderbell.count + columns_wanderbell - 1) / columns_wanderbell
        let buttonSize_wanderbell: CGFloat = 80
        let spacing_wanderbell: CGFloat = 16
        
        for (index_wanderbell, emotionType_wanderbell) in emotionTypes_wanderbell.enumerated() {
            let row_wanderbell = index_wanderbell / columns_wanderbell
            let col_wanderbell = index_wanderbell % columns_wanderbell
            
            let button_wanderbell = createEmotionButton_Wanderbell(emotionType_wanderbell: emotionType_wanderbell)
            emotionsGridView_Wanderbell.addSubview(button_wanderbell)
            
            let x_wanderbell = CGFloat(col_wanderbell) * (buttonSize_wanderbell + spacing_wanderbell)
            let y_wanderbell = CGFloat(row_wanderbell) * (buttonSize_wanderbell + spacing_wanderbell)
            
            button_wanderbell.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(x_wanderbell)
                make.top.equalToSuperview().offset(y_wanderbell)
                make.width.height.equalTo(buttonSize_wanderbell)
            }
        }
    }
    
    /// 创建情绪按钮
    private func createEmotionButton_Wanderbell(emotionType_wanderbell: EmotionType_Wanderbell) -> UIButton {
        let button_wanderbell = UIButton(type: .custom)
        button_wanderbell.backgroundColor = emotionType_wanderbell.getColor_Wanderbell().withAlphaComponent(0.2)
        button_wanderbell.layer.cornerRadius = 16
        
        let iconImageView_wanderbell = UIImageView()
        iconImageView_wanderbell.image = UIImage(systemName: emotionType_wanderbell.getIcon_Wanderbell())
        iconImageView_wanderbell.tintColor = emotionType_wanderbell.getColor_Wanderbell()
        iconImageView_wanderbell.contentMode = .scaleAspectFit
        
        let nameLabel_wanderbell = UILabel()
        nameLabel_wanderbell.text = emotionType_wanderbell.rawValue
        nameLabel_wanderbell.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        nameLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        nameLabel_wanderbell.textAlignment = .center
        
        button_wanderbell.addSubview(iconImageView_wanderbell)
        button_wanderbell.addSubview(nameLabel_wanderbell)
        
        iconImageView_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
        
        nameLabel_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.left.right.equalToSuperview().inset(4)
        }
        
        button_wanderbell.tag = emotionType_wanderbell.hashValue
        button_wanderbell.addTarget(self, action: #selector(emotionButtonTapped_Wanderbell(_:)), for: .touchUpInside)
        
        return button_wanderbell
    }
    
    // MARK: - 显示/隐藏
    
    /// 显示选择器
    func show_Wanderbell(in viewController_wanderbell: UIViewController) {
        guard let window_wanderbell = viewController_wanderbell.view.window else { return }
        
        frame = window_wanderbell.bounds
        window_wanderbell.addSubview(self)
        
        containerView_Wanderbell.transform = CGAffineTransform(translationX: 0, y: 500)
        
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationSpring_Wanderbell,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Wanderbell.springDampingNormal_Wanderbell,
            initialSpringVelocity: AnimationConfig_Wanderbell.springVelocity_Wanderbell,
            options: [.curveEaseOut],
            animations: {
                self.overlayView_Wanderbell.alpha = 1
                self.containerView_Wanderbell.transform = .identity
            }
        )
    }
    
    /// 隐藏选择器
    @objc func dismiss_Wanderbell() {
        UIView.animate(
            withDuration: AnimationConfig_Wanderbell.durationNormal_Wanderbell,
            animations: {
                self.overlayView_Wanderbell.alpha = 0
                self.containerView_Wanderbell.transform = CGAffineTransform(translationX: 0, y: 500)
            },
            completion: { _ in
                self.removeFromSuperview()
            }
        )
    }
    
    // MARK: - 事件处理
    
    @objc private func emotionButtonTapped_Wanderbell(_ sender: UIButton) {
        // 获取所有情绪类型并找到匹配的
        let emotionTypes_wanderbell = EmotionType_Wanderbell.getAllBasicTypes_Wanderbell()
        
        for emotionType_wanderbell in emotionTypes_wanderbell {
            if sender.tag == emotionType_wanderbell.hashValue {
                selectedEmotion_Wanderbell = emotionType_wanderbell
                
                // 获取强度值
                let intensity_wanderbell = intensitySlider_Wanderbell.getCurrentIntensity_Wanderbell()
                
                // 触发回调
                onEmotionSelected_Wanderbell?(emotionType_wanderbell, intensity_wanderbell)
                
                // 关闭选择器
                dismiss_Wanderbell()
                
                // 触觉反馈
                let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
                generator_wanderbell.impactOccurred()
                
                break
            }
        }
    }
}

// MARK: - 强度滑块

/// 强度滑块视图
/// 功能：5级强度选择（1-5星）
class IntensitySlider_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Intensity"
        label_wanderbell.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let slider_Wanderbell: UISlider = {
        let slider_wanderbell = UISlider()
        slider_wanderbell.minimumValue = 1
        slider_wanderbell.maximumValue = 5
        slider_wanderbell.value = 3
        slider_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        return slider_wanderbell
    }()
    
    private let valueLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "⭐️⭐️⭐️"
        label_wanderbell.font = UIFont.systemFont(ofSize: 20)
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(titleLabel_Wanderbell)
        addSubview(slider_Wanderbell)
        addSubview(valueLabel_Wanderbell)
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        slider_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        
        valueLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(slider_Wanderbell.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        slider_Wanderbell.addTarget(self, action: #selector(sliderValueChanged_Wanderbell), for: .valueChanged)
    }
    
    @objc private func sliderValueChanged_Wanderbell() {
        let intensity_wanderbell = Int(slider_Wanderbell.value)
        let stars_wanderbell = String(repeating: "⭐️", count: intensity_wanderbell)
        valueLabel_Wanderbell.text = stars_wanderbell
    }
    
    func getCurrentIntensity_Wanderbell() -> Int {
        return Int(slider_Wanderbell.value)
    }
}
