import UIKit
import SnapKit
import PhotosUI

// MARK: 时间胶囊创建页面

/// 时间胶囊创建页面
/// 功能：用户选择封面照片、填写文字内容、设定解锁时间后埋下时间胶囊
/// 设计：Present 模态展示，顶部导航栏含取消/保存按钮，使用 PHPicker 选图
/// 关键方法：onSave_Hush()（校验并提交）、handleImagePick_Hush()（处理图片选择）
class TimeCapsuleCreate_Hush: UIViewController {

    // MARK: - 回调

    /// 成功创建胶囊后的回调（用于刷新 Home 页面）
    var onCapsulePlanted_Hush: (() -> Void)?

    // MARK: - 私有属性

    /// 已选封面图片
    private var selectedImage_Hush: UIImage?

    // MARK: - UI 组件

    private let scrollView_Hush = UIScrollView()
    private let contentView_Hush = UIView()

    /// 封面图片选择区域
    private let photoPickerView_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = UIColor(hexstring_Hush: "#F0EDE8")
        v_hush.layer.cornerRadius = 16
        v_hush.layer.borderWidth = 2
        v_hush.layer.borderColor = UIColor(hexstring_Hush: "#E5E7EB").cgColor
        v_hush.clipsToBounds = true
        return v_hush
    }()

    /// 封面图片展示
    private let coverImageView_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.contentMode = .scaleAspectFill
        iv_hush.clipsToBounds = true
        iv_hush.isHidden = true
        return iv_hush
    }()

    /// 选图占位图标
    private let cameraIcon_Hush: UIImageView = {
        let iv_hush = UIImageView()
        let config_hush = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iv_hush.image = UIImage(systemName: "camera.fill", withConfiguration: config_hush)
        iv_hush.tintColor = UIColor(hexstring_Hush: "#9CA3AF")
        iv_hush.contentMode = .scaleAspectFit
        return iv_hush
    }()

    private let photoHintLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Tap to add a photo"
        lb_hush.textColor = UIColor(hexstring_Hush: "#9CA3AF")
        lb_hush.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb_hush.textAlignment = .center
        return lb_hush
    }()

    /// 标题输入框
    private let titleField_Hush: UITextField = {
        let tf_hush = UITextField()
        tf_hush.placeholder = "Give your capsule a title..."
        tf_hush.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        tf_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tf_hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        tf_hush.layer.cornerRadius = 12
        tf_hush.layer.borderWidth = 1
        tf_hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
        tf_hush.addLeftPadding_Hush(16)
        return tf_hush
    }()

    /// 内容输入区域
    private let contentTextView_Hush: UITextView = {
        let tv_hush = UITextView()
        tv_hush.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tv_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tv_hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        tv_hush.layer.cornerRadius = 12
        tv_hush.layer.borderWidth = 1
        tv_hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
        tv_hush.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        return tv_hush
    }()

    /// 内容占位文本
    private let placeholderLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Write something for your future self..."
        lb_hush.textColor = UIColor(hexstring_Hush: "#9CA3AF")
        lb_hush.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb_hush.numberOfLines = 0
        return lb_hush
    }()

    // MARK: - 解锁时间选择区域

    private let openDateSectionLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Open Date"
        lb_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return lb_hush
    }()

    private let dateLimitHint_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Min: 7 days · Max: 10 years"
        lb_hush.textColor = ColorConfig_Hush.textSecondary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        return lb_hush
    }()

    private let datePicker_Hush: UIDatePicker = {
        let dp_hush = UIDatePicker()
        dp_hush.datePickerMode = .date
        dp_hush.preferredDatePickerStyle = .inline
        dp_hush.tintColor = UIColor(hexstring_Hush: "#FF6B35")
        dp_hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        dp_hush.layer.cornerRadius = 14
        dp_hush.clipsToBounds = true
        // 最短7天，最长10年
        dp_hush.minimumDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        dp_hush.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        dp_hush.date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return dp_hush
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        setupNavBar_Hush()
        setupScrollView_Hush()
        setupContent_Hush()
        setupKeyboardDismiss_Hush()
        contentTextView_Hush.delegate = self
    }

    // MARK: - 布局

    /// 设置导航栏
    private func setupNavBar_Hush() {
        title = "Plant a Capsule"
        navigationController?.navigationBar.tintColor = UIColor(hexstring_Hush: "#FF6B35")
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: ColorConfig_Hush.textPrimary_Hush,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
        ]

        let cancelItem_hush = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(onCancel_Hush)
        )
        let saveItem_hush = UIBarButtonItem(
            title: "Plant",
            style: .done,
            target: self,
            action: #selector(onSave_Hush)
        )
        navigationItem.leftBarButtonItem = cancelItem_hush
        navigationItem.rightBarButtonItem = saveItem_hush
    }

    /// 设置主滚动视图
    private func setupScrollView_Hush() {
        view.addSubview(scrollView_Hush)
        scrollView_Hush.addSubview(contentView_Hush)
        scrollView_Hush.alwaysBounceVertical = true
        scrollView_Hush.showsVerticalScrollIndicator = false

        scrollView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
            make_hush.width.equalTo(view.snp.width)
        }
    }

    /// 添加内容组件及约束
    private func setupContent_Hush() {
        // 封面区
        contentView_Hush.addSubview(photoPickerView_Hush)
        photoPickerView_Hush.addSubview(coverImageView_Hush)
        photoPickerView_Hush.addSubview(cameraIcon_Hush)
        photoPickerView_Hush.addSubview(photoHintLabel_Hush)

        // 标题输入
        let titleSectionLabel_hush = makeSectionLabel_Hush(text_hush: "Title")
        contentView_Hush.addSubview(titleSectionLabel_hush)
        contentView_Hush.addSubview(titleField_Hush)

        // 内容输入
        let contentSectionLabel_hush = makeSectionLabel_Hush(text_hush: "Message")
        contentView_Hush.addSubview(contentSectionLabel_hush)
        contentView_Hush.addSubview(contentTextView_Hush)
        contentTextView_Hush.addSubview(placeholderLabel_Hush)

        // 解锁日期
        contentView_Hush.addSubview(openDateSectionLabel_Hush)
        contentView_Hush.addSubview(dateLimitHint_Hush)
        contentView_Hush.addSubview(datePicker_Hush)

        // 封面选择区
        photoPickerView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(20)
            make_hush.left.right.equalToSuperview().inset(20)
            make_hush.height.equalTo(200)
        }
        coverImageView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        cameraIcon_Hush.snp.makeConstraints { make_hush in
            make_hush.centerX.equalToSuperview()
            make_hush.centerY.equalToSuperview().offset(-14)
            make_hush.width.height.equalTo(40)
        }
        photoHintLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.centerX.equalToSuperview()
            make_hush.top.equalTo(cameraIcon_Hush.snp.bottom).offset(8)
        }

        // 标题
        titleSectionLabel_hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(photoPickerView_Hush.snp.bottom).offset(24)
            make_hush.left.equalToSuperview().offset(20)
        }
        titleField_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(titleSectionLabel_hush.snp.bottom).offset(8)
            make_hush.left.right.equalToSuperview().inset(20)
            make_hush.height.equalTo(50)
        }

        // 内容
        contentSectionLabel_hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(titleField_Hush.snp.bottom).offset(20)
            make_hush.left.equalToSuperview().offset(20)
        }
        contentTextView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(contentSectionLabel_hush.snp.bottom).offset(8)
            make_hush.left.right.equalToSuperview().inset(20)
            make_hush.height.equalTo(120)
        }
        placeholderLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(14)
            make_hush.left.equalToSuperview().offset(16)
            make_hush.right.equalToSuperview().offset(-16)
        }

        // 解锁日期
        openDateSectionLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(contentTextView_Hush.snp.bottom).offset(24)
            make_hush.left.equalToSuperview().offset(20)
        }
        dateLimitHint_Hush.snp.makeConstraints { make_hush in
            make_hush.centerY.equalTo(openDateSectionLabel_Hush)
            make_hush.right.equalToSuperview().offset(-20)
        }
        datePicker_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(openDateSectionLabel_Hush.snp.bottom).offset(10)
            make_hush.left.right.equalToSuperview().inset(20)
            make_hush.bottom.equalToSuperview().offset(-30)
        }

        // 点击封面区选图
        let tap_hush = UITapGestureRecognizer(target: self, action: #selector(onPickPhoto_Hush))
        photoPickerView_Hush.addGestureRecognizer(tap_hush)
        photoPickerView_Hush.isUserInteractionEnabled = true
    }

    /// 生成章节标题 Label 的工厂方法
    private func makeSectionLabel_Hush(text_hush: String) -> UILabel {
        let lb_hush = UILabel()
        lb_hush.text = text_hush
        lb_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return lb_hush
    }

    /// 设置点击空白区域收起键盘
    private func setupKeyboardDismiss_Hush() {
        let tap_hush = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Hush))
        tap_hush.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_hush)
    }

    // MARK: - 操作响应

    @objc private func onCancel_Hush() {
        Navigation_Hush.dismiss_Hush(from: self)
    }

    /// 提交保存时间胶囊
    @objc private func onSave_Hush() {
        guard let title_hush = titleField_Hush.text, !title_hush.trimmingCharacters(in: .whitespaces).isEmpty else {
            Utils_Hush.showError_Hush(message_Hush: "Please enter a title.")
            return
        }
        let content_hush = contentTextView_Hush.text ?? ""
        let openDate_hush = datePicker_Hush.date

        let success_hush = UserViewModel_Hush.shared_Hush.addCapsule_Hush(
            title_hush: title_hush,
            content_hush: content_hush,
            image_hush: selectedImage_Hush,
            openDate_hush: openDate_hush
        )

        if success_hush {
            onCapsulePlanted_Hush?()
            Navigation_Hush.dismiss_Hush(from: self)
        }
    }

    /// 唤起 PHPicker 选取照片
    @objc private func onPickPhoto_Hush() {
        var config_hush = PHPickerConfiguration()
        config_hush.selectionLimit = 1
        config_hush.filter = .images
        let picker_hush = PHPickerViewController(configuration: config_hush)
        picker_hush.delegate = self
        present(picker_hush, animated: true)
    }

    @objc private func dismissKeyboard_Hush() {
        view.endEditing(true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension TimeCapsuleCreate_Hush: PHPickerViewControllerDelegate {

    /// 处理图片选择结果
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider_hush = results.first?.itemProvider,
              provider_hush.canLoadObject(ofClass: UIImage.self) else { return }

        provider_hush.loadObject(ofClass: UIImage.self) { [weak self] obj_hush, _ in
            DispatchQueue.main.async {
                guard let self_hush = self, let image_hush = obj_hush as? UIImage else { return }
                self_hush.selectedImage_Hush = image_hush
                self_hush.coverImageView_Hush.image = image_hush
                self_hush.coverImageView_Hush.isHidden = false
                self_hush.cameraIcon_Hush.isHidden = true
                self_hush.photoHintLabel_Hush.isHidden = true
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension TimeCapsuleCreate_Hush: UITextViewDelegate {

    /// 输入内容时隐藏占位文本
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel_Hush.isHidden = !textView.text.isEmpty
    }
}
