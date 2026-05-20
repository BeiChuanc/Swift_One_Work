import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: - 全屏媒体浏览页

/// 全屏媒体浏览页
/// 核心作用：
///   - 图片模式：以沉浸式黑底全屏展示，支持双指缩放、双击放大/还原、下滑关闭
///   - 视频模式：通过 AVPlayer 播放 Bundle / Documents / 网络视频，支持播放/暂停、进度条、下滑关闭
/// 设计思路：
///   - 媒体路径与 MediaDisplayView_Tidy 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Tidy:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Tidy:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Tidy: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Tidy: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Tidy: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Tidy: MediaType_Tidy = .none_Tidy

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Tidy = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Tidy: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Tidy: AVPlayer?
    private var playerLayer_Tidy: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Tidy: Any?
    /// 是否处于播放状态
    private var isPlaying_Tidy = false

    // MARK: - UI：黑色背景

    private let backgroundView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator   = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bouncesZoom      = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.backgroundColor  = .clear
        return sv
    }()

    private let imageView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Tidy: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Tidy = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Tidy), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Tidy), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Tidy: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Tidy: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Tidy: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Tidy = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Tidy), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Tidy: UILabel = {
        let l = UILabel()
        l.text          = "Swipe down to close"
        l.font          = .systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.45)
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Tidy()
        buildConstraints_Tidy()
        bindGestures_Tidy()
        loadMedia_Tidy()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.alpha = 0
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Tidy()
    }

    deinit {
        cleanupPlayer_Tidy()
    }

    // MARK: - UI 搭建

    private func buildUI_Tidy() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Tidy)

        // 图片容器
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(imageView_Tidy)
        scrollView_Tidy.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Tidy)
        videoContainerView_Tidy.addSubview(playPauseButton_Tidy)
        videoContainerView_Tidy.addSubview(progressBg_Tidy)
        progressBg_Tidy.addSubview(progressFill_Tidy)

        // 通用
        view.addSubview(loadingIndicator_Tidy)
        view.addSubview(topBar_Tidy)
        topBar_Tidy.addSubview(closeButton_Tidy)
        topBar_Tidy.addSubview(mediaTypeLabel_Tidy)
        view.addSubview(bottomHint_Tidy)
    }

    private func buildConstraints_Tidy() {
        backgroundView_Tidy.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Tidy.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Tidy.frame = view.bounds

        videoContainerView_Tidy.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Tidy.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Tidy.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Tidy.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Tidy = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Tidy.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Tidy.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Tidy.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Tidy.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Tidy.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Tidy.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Tidy?.frame = videoContainerView_Tidy.bounds
        updateImageLayout_Tidy()
    }

    // MARK: - 手势

    private func bindGestures_Tidy() {
        // 双击缩放（图片）
        let doubleTap_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Tidy(_:)))
        doubleTap_Tidy.numberOfTapsRequired = 2
        scrollView_Tidy.addGestureRecognizer(doubleTap_Tidy)

        // 单击关闭 / 视频播放切换
        let singleTap_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Tidy))
        singleTap_Tidy.numberOfTapsRequired = 1
        singleTap_Tidy.require(toFail: doubleTap_Tidy)
        scrollView_Tidy.addGestureRecognizer(singleTap_Tidy)

        // 视频区单击切换播放/暂停
        let videoTap_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Tidy))
        videoContainerView_Tidy.addGestureRecognizer(videoTap_Tidy)

        // 下滑关闭
        let pan_Tidy = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Tidy(_:)))
        pan_Tidy.delegate = self
        view.addGestureRecognizer(pan_Tidy)

        // 播放/暂停按钮
        playPauseButton_Tidy.addTarget(self, action: #selector(togglePlayPause_Tidy), for: .touchUpInside)
        closeButton_Tidy.addTarget(self, action: #selector(closeTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Tidy 和 isVideo_Tidy 加载媒体
    private func loadMedia_Tidy() {
        guard let path_Tidy = mediaPath_Tidy, !path_Tidy.isEmpty else { showEmpty_Tidy(); return }
        loadingIndicator_Tidy.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Tidy, let url_Tidy = resolveVideoURL_Tidy(path_Tidy) {
            setupVideoPlayer_Tidy(url_Tidy: url_Tidy)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Tidy = resolveVideoURL_Tidy(path_Tidy) {
            setupVideoPlayer_Tidy(url_Tidy: url_Tidy)
            return
        }

        // 图片加载流程
        resolvedType_Tidy = .image_Tidy
        loadImage_Tidy(path_Tidy: path_Tidy)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Tidy: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Tidy(_ path_Tidy: String) -> URL? {
        // Bundle 资源
        if let url_Tidy = MediaDisplayView_Tidy.bundleVideoURL_Tidy(named: path_Tidy) {
            return url_Tidy
        }
        // Documents 目录视频文件
        let docs_Tidy = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Tidy in ["mp4", "mov", "m4v"] {
            let url_Tidy = docs_Tidy.appendingPathComponent("\(path_Tidy).\(ext_Tidy)")
            if FileManager.default.fileExists(atPath: url_Tidy.path) { return url_Tidy }
        }
        // 已带扩展名的文档目录文件
        let direct_Tidy = docs_Tidy.appendingPathComponent(path_Tidy)
        if FileManager.default.fileExists(atPath: direct_Tidy.path) { return direct_Tidy }
        // 网络视频 URL
        if (path_Tidy.hasPrefix("http://") || path_Tidy.hasPrefix("https://")),
           let url_Tidy = URL(string: path_Tidy) {
            let ext_Tidy = (path_Tidy as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Tidy) { return url_Tidy }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Tidy 策略对齐）
    /// - Parameter path_Tidy: 媒体路径
    private func loadImage_Tidy(path_Tidy: String) {
        // SF Symbols
        if let img_Tidy = UIImage(systemName: path_Tidy) { applyImage_Tidy(img_Tidy); return }
        // Assets
        if let img_Tidy = UIImage(named: path_Tidy) { applyImage_Tidy(img_Tidy); return }
        // 网络
        if path_Tidy.hasPrefix("http://") || path_Tidy.hasPrefix("https://") {
            guard let url_Tidy = URL(string: path_Tidy) else { showEmpty_Tidy(); return }
            imageView_Tidy.kf.setImage(with: url_Tidy, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Tidy.stopAnimating()
                if case .success(let v_Tidy) = result { self?.onImageLoaded_Tidy(v_Tidy.image) }
                else { self?.showEmpty_Tidy() }
            }
            return
        }
        // Documents 文件名
        let docs_Tidy = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Tidy = docs_Tidy.appendingPathComponent(path_Tidy)
        if let img_Tidy = UIImage(contentsOfFile: docURL_Tidy.path) { applyImage_Tidy(img_Tidy); return }
        // 完整路径
        if let img_Tidy = UIImage(contentsOfFile: path_Tidy) { applyImage_Tidy(img_Tidy); return }
        showEmpty_Tidy()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Tidy: 视频文件 URL
    private func setupVideoPlayer_Tidy(url_Tidy: URL) {
        resolvedType_Tidy = .video_Tidy

        // 切换到视频容器
        scrollView_Tidy.isHidden         = true
        videoContainerView_Tidy.isHidden = false
        progressBg_Tidy.isHidden         = false

        mediaTypeLabel_Tidy.text = "Video"

        let player_Tidy  = AVPlayer(url: url_Tidy)
        self.player_Tidy = player_Tidy
        let layer_Tidy   = AVPlayerLayer(player: player_Tidy)
        layer_Tidy.videoGravity  = .resizeAspect
        layer_Tidy.frame         = videoContainerView_Tidy.bounds
        layer_Tidy.backgroundColor = UIColor.black.cgColor
        videoContainerView_Tidy.layer.insertSublayer(layer_Tidy, at: 0)
        playerLayer_Tidy = layer_Tidy

        // 视频就绪后淡入播放按钮
        player_Tidy.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Tidy = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Tidy = player_Tidy.addPeriodicTimeObserver(
            forInterval: interval_Tidy,
            queue: .main
        ) { [weak self] time_Tidy in
            self?.updateProgress_Tidy(currentTime_Tidy: time_Tidy)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Tidy),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Tidy.currentItem
        )

        loadingIndicator_Tidy.stopAnimating()
        player_Tidy.play()
        isPlaying_Tidy = true
        playPauseButton_Tidy.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Tidy.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Tidy: AVPlayer 当前时间
    private func updateProgress_Tidy(currentTime_Tidy: CMTime) {
        guard let duration_Tidy = player_Tidy?.currentItem?.duration,
              duration_Tidy.isNumeric, duration_Tidy.seconds > 0 else { return }
        let progress_Tidy = CGFloat(currentTime_Tidy.seconds / duration_Tidy.seconds)
        let totalW_Tidy   = progressBg_Tidy.bounds.width
        progressWidthCon_Tidy?.update(offset: totalW_Tidy * min(max(progress_Tidy, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Tidy() {
        player_Tidy?.seek(to: .zero)
        isPlaying_Tidy = false
        playPauseButton_Tidy.isSelected = false
        progressWidthCon_Tidy?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Tidy() {
        if let token_Tidy = timeObserverToken_Tidy {
            player_Tidy?.removeTimeObserver(token_Tidy)
            timeObserverToken_Tidy = nil
        }
        player_Tidy?.removeObserver(self, forKeyPath: "status")
        player_Tidy?.pause()
        player_Tidy = nil
        playerLayer_Tidy?.removeFromSuperlayer()
        playerLayer_Tidy = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Tidy = object as? AVPlayer,
              player_Tidy.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Tidy() }
    }

    // MARK: - 图片辅助

    private func applyImage_Tidy(_ image_Tidy: UIImage) {
        loadingIndicator_Tidy.stopAnimating()
        imageView_Tidy.image = image_Tidy
        imageSize_Tidy       = image_Tidy.size
        mediaTypeLabel_Tidy.text = "Photo"
        updateImageLayout_Tidy()
    }

    private func onImageLoaded_Tidy(_ image_Tidy: UIImage) {
        imageSize_Tidy = image_Tidy.size
        mediaTypeLabel_Tidy.text = "Photo"
        updateImageLayout_Tidy()
    }

    private func showEmpty_Tidy() {
        loadingIndicator_Tidy.stopAnimating()
        imageView_Tidy.image       = UIImage(systemName: "photo.slash")
        imageView_Tidy.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Tidy.contentMode = .center
    }

    private func updateImageLayout_Tidy() {
        guard imageSize_Tidy != .zero else {
            imageView_Tidy.frame = view.bounds
            scrollView_Tidy.contentSize = view.bounds.size
            return
        }
        let screenW_Tidy = view.bounds.width
        let screenH_Tidy = view.bounds.height
        let ratio_Tidy   = imageSize_Tidy.height / imageSize_Tidy.width
        let imgH_Tidy    = screenW_Tidy * ratio_Tidy
        let y_Tidy       = max(0, (screenH_Tidy - imgH_Tidy) / 2)
        imageView_Tidy.frame        = CGRect(x: 0, y: y_Tidy, width: screenW_Tidy, height: imgH_Tidy)
        scrollView_Tidy.contentSize = CGSize(width: screenW_Tidy,
                                              height: max(imgH_Tidy + y_Tidy * 2, screenH_Tidy))
        scrollView_Tidy.zoomScale   = 1.0
        centerImageIfNeeded_Tidy()
    }

    private func centerImageIfNeeded_Tidy() {
        let offX_Tidy = max(0, (scrollView_Tidy.bounds.width  - scrollView_Tidy.contentSize.width)  / 2)
        let offY_Tidy = max(0, (scrollView_Tidy.bounds.height - scrollView_Tidy.contentSize.height) / 2)
        imageView_Tidy.center = CGPoint(
            x: scrollView_Tidy.contentSize.width  / 2 + offX_Tidy,
            y: scrollView_Tidy.contentSize.height / 2 + offY_Tidy
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Tidy(_ gesture_Tidy: UITapGestureRecognizer) {
        guard resolvedType_Tidy == .image_Tidy else { return }
        if scrollView_Tidy.zoomScale > 1.0 {
            scrollView_Tidy.setZoomScale(1.0, animated: true)
        } else {
            let pt_Tidy    = gesture_Tidy.location(in: imageView_Tidy)
            let rect_Tidy  = zoomRect_Tidy(scale_Tidy: 2.5, center_Tidy: pt_Tidy)
            scrollView_Tidy.zoom(to: rect_Tidy, animated: true)
        }
    }

    @objc private func handleSingleTap_Tidy() {
        guard resolvedType_Tidy != .video_Tidy,
              scrollView_Tidy.zoomScale <= 1.01 else { return }
        dismissPage_Tidy(velocity_Tidy: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Tidy() {
        togglePlayPause_Tidy()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Tidy() {
        guard let player_Tidy = player_Tidy else { return }
        if isPlaying_Tidy {
            player_Tidy.pause()
            isPlaying_Tidy = false
            playPauseButton_Tidy.isSelected = false
        } else {
            player_Tidy.play()
            isPlaying_Tidy = true
            playPauseButton_Tidy.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Tidy.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Tidy else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Tidy.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Tidy() {
        dismissPage_Tidy(velocity_Tidy: 0)
    }

    @objc private func handlePan_Tidy(_ gesture_Tidy: UIPanGestureRecognizer) {
        guard scrollView_Tidy.zoomScale <= 1.01 else { return }
        let translation_Tidy = gesture_Tidy.translation(in: view)
        let velocity_Tidy    = gesture_Tidy.velocity(in: view).y
        switch gesture_Tidy.state {
        case .changed:
            let progress_Tidy         = max(0, translation_Tidy.y / view.bounds.height)
            backgroundView_Tidy.alpha = max(0, 1 - progress_Tidy * 1.5)
            topBar_Tidy.alpha         = max(0, 1 - progress_Tidy * 2)
            bottomHint_Tidy.alpha     = max(0, 1 - progress_Tidy * 2)
            let activeView_Tidy: UIView = resolvedType_Tidy == .video_Tidy
                ? videoContainerView_Tidy : scrollView_Tidy
            activeView_Tidy.transform = CGAffineTransform(
                translationX: translation_Tidy.x * 0.3,
                y: max(0, translation_Tidy.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Tidy = translation_Tidy.y > view.bounds.height * 0.25 || velocity_Tidy > 900
            if shouldDismiss_Tidy {
                dismissPage_Tidy(velocity_Tidy: velocity_Tidy)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Tidy.transform         = .identity
                    self.videoContainerView_Tidy.transform = .identity
                    self.backgroundView_Tidy.alpha  = 1
                    self.topBar_Tidy.alpha           = 1
                    self.bottomHint_Tidy.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Tidy: 下拉速度（影响动画时长）
    private func dismissPage_Tidy(velocity_Tidy: CGFloat) {
        guard !isDismissing_Tidy else { return }
        isDismissing_Tidy = true
        player_Tidy?.pause()
        let duration_Tidy = velocity_Tidy > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Tidy, animations: {
            self.view.alpha = 0
            let activeView_Tidy: UIView = self.resolvedType_Tidy == .video_Tidy
                ? self.videoContainerView_Tidy : self.scrollView_Tidy
            activeView_Tidy.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Tidy(scale_Tidy: CGFloat, center_Tidy: CGPoint) -> CGRect {
        let w_Tidy = scrollView_Tidy.bounds.width  / scale_Tidy
        let h_Tidy = scrollView_Tidy.bounds.height / scale_Tidy
        return CGRect(x: center_Tidy.x - w_Tidy / 2,
                      y: center_Tidy.y - h_Tidy / 2,
                      width: w_Tidy, height: h_Tidy)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Tidy: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Tidy }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Tidy() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Tidy: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Tidy = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Tidy.zoomScale <= 1.01 else { return false }
        let vel_Tidy = pan_Tidy.velocity(in: view)
        return abs(vel_Tidy.y) > abs(vel_Tidy.x) && vel_Tidy.y > 0
    }
}
