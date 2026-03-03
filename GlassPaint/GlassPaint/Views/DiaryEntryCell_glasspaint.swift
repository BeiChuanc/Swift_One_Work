import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 日记条目单元格

/// 日记条目单元格
/// 功能：展示彩绘日记条目（图片+文案+日期）
/// 特性：多图水平滚动展示、日期图标标记、时间显示、卡片样式、渐变边框、阴影效果
/// 关键属性：imagesScrollView_Glasspaint（图片滚动容器）、imagesStack_Glasspaint（图片栈布局）、contentLabel_Glasspaint（文案标签）
/// 关键方法：configure_Glasspaint（配置单元格数据）、configureEmpty_Glasspaint（配置空单元格）
class DiaryEntryCell_Glasspaint: UITableViewCell {
    
    // MARK: - UI属性
    
    /// 卡片容器
    private let cardContainer_Glasspaint = UIView()
    
    /// 日期标签
    private let dateLabel_Glasspaint = UILabel()
    
    /// 日期图标
    private let dateIcon_Glasspaint = UIImageView()
    
    /// 图片容器（水平滚动）
    private let imagesScrollView_Glasspaint = UIScrollView()
    
    /// 图片栈视图
    private let imagesStack_Glasspaint = UIStackView()
    
    /// 内容标签
    private let contentLabel_Glasspaint = UILabel()
    
    /// 时间标签
    private let timeLabel_Glasspaint = UILabel()
    
    /// 删除按钮
    private let deleteButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 数据属性
    
    /// 日记条目数据
    private var entry_Glasspaint: PaintingDiaryEntry_Glasspaint?
    
    /// 删除回调
    var onDelete_Glasspaint: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imagesStack_Glasspaint.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentLabel_Glasspaint.text = nil
        dateLabel_Glasspaint.text = nil
        timeLabel_Glasspaint.text = nil
        onDelete_Glasspaint = nil
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 卡片容器
        contentView.addSubview(cardContainer_Glasspaint)
        cardContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        cardContainer_Glasspaint.layer.cornerRadius = 16
        cardContainer_Glasspaint.layer.masksToBounds = false
        cardContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        cardContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardContainer_Glasspaint.layer.shadowRadius = 8
        cardContainer_Glasspaint.layer.shadowOpacity = 0.15
        
        // 日期图标
        cardContainer_Glasspaint.addSubview(dateIcon_Glasspaint)
        dateIcon_Glasspaint.image = UIImage(systemName: "calendar.circle.fill")
        dateIcon_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        dateIcon_Glasspaint.contentMode = .scaleAspectFit
        
        // 日期标签
        cardContainer_Glasspaint.addSubview(dateLabel_Glasspaint)
        dateLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        dateLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 时间标签
        cardContainer_Glasspaint.addSubview(timeLabel_Glasspaint)
        timeLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        timeLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 删除按钮
        cardContainer_Glasspaint.addSubview(deleteButton_Glasspaint)
        let deleteConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let deleteImage_glasspaint = UIImage(systemName: "trash.fill", withConfiguration: deleteConfig_glasspaint)
        deleteButton_Glasspaint.setImage(deleteImage_glasspaint, for: .normal)
        deleteButton_Glasspaint.tintColor = .white
        deleteButton_Glasspaint.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        deleteButton_Glasspaint.layer.cornerRadius = 16
        deleteButton_Glasspaint.layer.shadowColor = UIColor.red.cgColor
        deleteButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        deleteButton_Glasspaint.layer.shadowRadius = 4
        deleteButton_Glasspaint.layer.shadowOpacity = 0.3
        deleteButton_Glasspaint.addTarget(self, action: #selector(handleDeleteTap_Glasspaint), for: .touchUpInside)
        
        // 图片滚动视图
        cardContainer_Glasspaint.addSubview(imagesScrollView_Glasspaint)
        imagesScrollView_Glasspaint.showsHorizontalScrollIndicator = false
        imagesScrollView_Glasspaint.backgroundColor = .clear
        
        // 图片栈视图
        imagesScrollView_Glasspaint.addSubview(imagesStack_Glasspaint)
        imagesStack_Glasspaint.axis = .horizontal
        imagesStack_Glasspaint.spacing = 8
        imagesStack_Glasspaint.distribution = .fill
        imagesStack_Glasspaint.alignment = .center
        
        // 内容标签（固定行数）
        cardContainer_Glasspaint.addSubview(contentLabel_Glasspaint)
        contentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        contentLabel_Glasspaint.numberOfLines = 2
        contentLabel_Glasspaint.lineBreakMode = .byTruncatingTail
        
        setupConstraints_Glasspaint()
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        cardContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(220)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        dateIcon_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        dateLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(dateIcon_Glasspaint.snp.right).offset(6)
            make.centerY.equalTo(dateIcon_Glasspaint)
        }
        
        timeLabel_Glasspaint.snp.makeConstraints { make in
            make.right.equalTo(deleteButton_Glasspaint.snp.left).offset(-12)
            make.centerY.equalTo(dateIcon_Glasspaint)
        }
        
        deleteButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(32)
        }
        
        imagesScrollView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(dateIcon_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        imagesStack_Glasspaint.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.greaterThanOrEqualToSuperview()
            make.height.equalToSuperview()
        }
        
        contentLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(imagesScrollView_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16).priority(.medium)
        }
    }
    
    // MARK: - 配置方法
    
    /// 配置单元格
    /// 参数：
    /// - entry_glasspaint: 日记条目数据
    func configure_Glasspaint(with_glasspaint entry_glasspaint: PaintingDiaryEntry_Glasspaint) {
        self.entry_Glasspaint = entry_glasspaint
        
        // 日期
        let dateFormatter_glasspaint = DateFormatter()
        dateFormatter_glasspaint.dateFormat = "MMM dd, yyyy"
        dateLabel_Glasspaint.text = dateFormatter_glasspaint.string(from: entry_glasspaint.date_Glasspaint)
        
        // 时间
        let timeFormatter_glasspaint = DateFormatter()
        timeFormatter_glasspaint.dateFormat = "HH:mm"
        timeLabel_Glasspaint.text = timeFormatter_glasspaint.string(from: entry_glasspaint.createdAt_Glasspaint)
        
        // 内容
        contentLabel_Glasspaint.text = entry_glasspaint.content_Glasspaint
        
        // 清空旧图片
        imagesStack_Glasspaint.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 添加图片
        if entry_glasspaint.imagePaths_Glasspaint.isEmpty {
            // 如果没有图片，显示占位符
            let placeholderView_glasspaint = UIView()
            placeholderView_glasspaint.backgroundColor = ColorConfig_Glasspaint.divider_Glasspaint.withAlphaComponent(0.3)
            placeholderView_glasspaint.layer.cornerRadius = 12
            
            let placeholderIcon_glasspaint = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled"))
            placeholderView_glasspaint.addSubview(placeholderIcon_glasspaint)
            placeholderIcon_glasspaint.tintColor = ColorConfig_Glasspaint.textPlaceholder_Glasspaint
            placeholderIcon_glasspaint.contentMode = .scaleAspectFit
            
            placeholderIcon_glasspaint.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
            
            placeholderView_glasspaint.snp.makeConstraints { make in
                make.width.equalTo(100)
                make.height.equalTo(100)
            }
            
            imagesStack_Glasspaint.addArrangedSubview(placeholderView_glasspaint)
        } else {
            for (index_glasspaint, imagePath_glasspaint) in entry_glasspaint.imagePaths_Glasspaint.enumerated() {
                let imageContainer_glasspaint = UIView()
                imageContainer_glasspaint.backgroundColor = ColorConfig_Glasspaint.divider_Glasspaint.withAlphaComponent(0.3)
                imageContainer_glasspaint.layer.cornerRadius = 12
                imageContainer_glasspaint.clipsToBounds = true
                
                let imageView_glasspaint = UIImageView()
                imageView_glasspaint.contentMode = .scaleAspectFill
                imageView_glasspaint.backgroundColor = .clear
                imageView_glasspaint.isUserInteractionEnabled = true
                
                imageContainer_glasspaint.addSubview(imageView_glasspaint)
                
                // 加载图片
                if let url_glasspaint = URL(string: imagePath_glasspaint), imagePath_glasspaint.hasPrefix("http") {
                    imageView_glasspaint.kf.setImage(
                        with: url_glasspaint,
                        placeholder: UIImage(systemName: "photo.fill"),
                        options: [.transition(.fade(0.2))]
                    )
                } else if let localImage_glasspaint = UIImage(contentsOfFile: imagePath_glasspaint) {
                    imageView_glasspaint.image = localImage_glasspaint
                } else {
                    let placeholderIcon_glasspaint = UIImageView(image: UIImage(systemName: "photo.fill"))
                    placeholderIcon_glasspaint.tintColor = ColorConfig_Glasspaint.textPlaceholder_Glasspaint
                    placeholderIcon_glasspaint.contentMode = .scaleAspectFit
                    imageContainer_glasspaint.addSubview(placeholderIcon_glasspaint)
                    placeholderIcon_glasspaint.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                        make.width.height.equalTo(40)
                    }
                }
                
                imageView_glasspaint.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                // 添加点击手势
                let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleImageTap_Glasspaint(_:)))
                imageContainer_glasspaint.addGestureRecognizer(tapGesture_glasspaint)
                imageContainer_glasspaint.tag = index_glasspaint
                
                imageContainer_glasspaint.snp.makeConstraints { make in
                    make.width.equalTo(100)
                    make.height.equalTo(100)
                }
                
                imagesStack_Glasspaint.addArrangedSubview(imageContainer_glasspaint)
            }
        }
        
        // 更新图片滚动视图内容大小
        DispatchQueue.main.async {
            let imageCount_glasspaint = self.imagesStack_Glasspaint.arrangedSubviews.count
            let contentWidth_glasspaint = CGFloat(imageCount_glasspaint) * 100 + CGFloat(max(0, imageCount_glasspaint - 1)) * 8
            self.imagesScrollView_Glasspaint.contentSize = CGSize(width: contentWidth_glasspaint, height: 100)
        }
    }
    
    /// 配置空单元格
    func configureEmpty_Glasspaint() {
        dateLabel_Glasspaint.text = ""
        timeLabel_Glasspaint.text = ""
        contentLabel_Glasspaint.text = ""
        imagesStack_Glasspaint.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - 事件处理
    
    /// 处理删除按钮点击
    @objc private func handleDeleteTap_Glasspaint() {
        // 缩放动画
        deleteButton_Glasspaint.animatePulse_Glasspaint()
        
        // 触觉反馈
        let generator_glasspaint = UINotificationFeedbackGenerator()
        generator_glasspaint.notificationOccurred(.warning)
        
        // 触发删除回调
        onDelete_Glasspaint?()
    }
    
    /// 处理图片点击
    /// 参数：
    /// - gesture_glasspaint: 点击手势
    @objc private func handleImageTap_Glasspaint(_ gesture_glasspaint: UITapGestureRecognizer) {
        guard let containerView_glasspaint = gesture_glasspaint.view,
              let imageView_glasspaint = containerView_glasspaint.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
              let image_glasspaint = imageView_glasspaint.image else { return }
        
        // 缩放动画
        containerView_glasspaint.animatePulse_Glasspaint()
        
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .light)
        generator_glasspaint.impactOccurred()
        
        // 获取视图控制器并展示全屏图片
        if let viewController_glasspaint = findViewController_Glasspaint() {
            let previewController_glasspaint = ImagePreviewController_Glasspaint(image_glasspaint: image_glasspaint)
            viewController_glasspaint.present(previewController_glasspaint, animated: true)
        }
    }
    
    /// 查找视图控制器
    /// 返回：所在视图控制器
    private func findViewController_Glasspaint() -> UIViewController? {
        var responder_glasspaint: UIResponder? = self
        while responder_glasspaint != nil {
            if let viewController_glasspaint = responder_glasspaint as? UIViewController {
                return viewController_glasspaint
            }
            responder_glasspaint = responder_glasspaint?.next
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新阴影路径以匹配圆角
        cardContainer_Glasspaint.layer.shadowPath = UIBezierPath(
            roundedRect: cardContainer_Glasspaint.bounds,
            cornerRadius: 16
        ).cgPath
    }
}
