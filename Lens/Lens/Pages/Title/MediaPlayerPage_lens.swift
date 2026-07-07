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
///   - 媒体路径与 MediaDisplayView_Lens 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Lens:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Lens:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Lens: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Lens: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Lens: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Lens: MediaType_Lens = .none_Lens

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Lens = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Lens: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Lens: AVPlayer?
    private var playerLayer_Lens: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Lens: Any?
    /// 是否处于播放状态
    private var isPlaying_Lens = false

    // MARK: - UI：黑色背景

    private let backgroundView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Lens: UIScrollView = {
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

    private let imageView_Lens: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Lens), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Lens), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Lens: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Lens: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Lens: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Lens: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Lens: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Lens: UILabel = {
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
        buildUI_Lens()
        buildConstraints_Lens()
        bindGestures_Lens()
        loadMedia_Lens()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进场前预设透明，由 viewDidAppear 统一淡入，避免与系统转场动画叠加导致闪烁
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Lens()
    }

    deinit {
        cleanupPlayer_Lens()
    }

    // MARK: - UI 搭建

    private func buildUI_Lens() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Lens)

        // 图片容器
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(imageView_Lens)
        scrollView_Lens.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Lens)
        videoContainerView_Lens.addSubview(playPauseButton_Lens)
        videoContainerView_Lens.addSubview(progressBg_Lens)
        progressBg_Lens.addSubview(progressFill_Lens)

        // 通用
        view.addSubview(loadingIndicator_Lens)
        view.addSubview(topBar_Lens)
        topBar_Lens.addSubview(closeButton_Lens)
        topBar_Lens.addSubview(mediaTypeLabel_Lens)
        view.addSubview(bottomHint_Lens)
    }

    private func buildConstraints_Lens() {
        backgroundView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Lens.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Lens.frame = view.bounds

        videoContainerView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Lens.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Lens = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Lens.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Lens.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Lens?.frame = videoContainerView_Lens.bounds
        updateImageLayout_Lens()
    }

    // MARK: - 手势

    private func bindGestures_Lens() {
        // 双击缩放（图片）
        let doubleTap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Lens(_:)))
        doubleTap_Lens.numberOfTapsRequired = 2
        scrollView_Lens.addGestureRecognizer(doubleTap_Lens)

        // 单击关闭 / 视频播放切换
        let singleTap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Lens))
        singleTap_Lens.numberOfTapsRequired = 1
        singleTap_Lens.require(toFail: doubleTap_Lens)
        scrollView_Lens.addGestureRecognizer(singleTap_Lens)

        // 视频区单击切换播放/暂停
        let videoTap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Lens))
        videoContainerView_Lens.addGestureRecognizer(videoTap_Lens)

        // 下滑关闭
        let pan_Lens = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Lens(_:)))
        pan_Lens.delegate = self
        view.addGestureRecognizer(pan_Lens)

        // 播放/暂停按钮
        playPauseButton_Lens.addTarget(self, action: #selector(togglePlayPause_Lens), for: .touchUpInside)
        closeButton_Lens.addTarget(self, action: #selector(closeTapped_Lens), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Lens 和 isVideo_Lens 加载媒体
    private func loadMedia_Lens() {
        guard let path_Lens = mediaPath_Lens, !path_Lens.isEmpty else { showEmpty_Lens(); return }
        loadingIndicator_Lens.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Lens, let url_Lens = resolveVideoURL_Lens(path_Lens) {
            setupVideoPlayer_Lens(url_Lens: url_Lens)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Lens = resolveVideoURL_Lens(path_Lens) {
            setupVideoPlayer_Lens(url_Lens: url_Lens)
            return
        }

        // 图片加载流程
        resolvedType_Lens = .image_Lens
        loadImage_Lens(path_Lens: path_Lens)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Lens: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Lens(_ path_Lens: String) -> URL? {
        // Bundle 资源
        if let url_Lens = MediaDisplayView_Lens.bundleVideoURL_Lens(named: path_Lens) {
            return url_Lens
        }
        // Documents 目录视频文件
        let docs_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Lens in ["mp4", "mov", "m4v"] {
            let url_Lens = docs_Lens.appendingPathComponent("\(path_Lens).\(ext_Lens)")
            if FileManager.default.fileExists(atPath: url_Lens.path) { return url_Lens }
        }
        // 已带扩展名的文档目录文件
        let direct_Lens = docs_Lens.appendingPathComponent(path_Lens)
        if FileManager.default.fileExists(atPath: direct_Lens.path) { return direct_Lens }
        // 网络视频 URL
        if (path_Lens.hasPrefix("http://") || path_Lens.hasPrefix("https://")),
           let url_Lens = URL(string: path_Lens) {
            let ext_Lens = (path_Lens as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Lens) { return url_Lens }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Lens 策略对齐）
    /// - Parameter path_Lens: 媒体路径
    private func loadImage_Lens(path_Lens: String) {
        // SF Symbols
        if let img_Lens = UIImage(systemName: path_Lens) { applyImage_Lens(img_Lens); return }
        // Assets
        if let img_Lens = UIImage(named: path_Lens) { applyImage_Lens(img_Lens); return }
        // 网络
        if path_Lens.hasPrefix("http://") || path_Lens.hasPrefix("https://") {
            guard let url_Lens = URL(string: path_Lens) else { showEmpty_Lens(); return }
            imageView_Lens.kf.setImage(with: url_Lens, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Lens.stopAnimating()
                if case .success(let v_Lens) = result { self?.onImageLoaded_Lens(v_Lens.image) }
                else { self?.showEmpty_Lens() }
            }
            return
        }
        // Documents 文件名
        let docs_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Lens = docs_Lens.appendingPathComponent(path_Lens)
        if let img_Lens = UIImage(contentsOfFile: docURL_Lens.path) { applyImage_Lens(img_Lens); return }
        // 完整路径
        if let img_Lens = UIImage(contentsOfFile: path_Lens) { applyImage_Lens(img_Lens); return }
        showEmpty_Lens()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Lens: 视频文件 URL
    private func setupVideoPlayer_Lens(url_Lens: URL) {
        resolvedType_Lens = .video_Lens

        // 切换到视频容器
        scrollView_Lens.isHidden         = true
        videoContainerView_Lens.isHidden = false
        progressBg_Lens.isHidden         = false

        mediaTypeLabel_Lens.text = "Video"

        let player_Lens  = AVPlayer(url: url_Lens)
        self.player_Lens = player_Lens
        let layer_Lens   = AVPlayerLayer(player: player_Lens)
        layer_Lens.videoGravity  = .resizeAspect
        layer_Lens.frame         = videoContainerView_Lens.bounds
        layer_Lens.backgroundColor = UIColor.black.cgColor
        videoContainerView_Lens.layer.insertSublayer(layer_Lens, at: 0)
        playerLayer_Lens = layer_Lens

        // 视频就绪后淡入播放按钮
        player_Lens.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Lens = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Lens = player_Lens.addPeriodicTimeObserver(
            forInterval: interval_Lens,
            queue: .main
        ) { [weak self] time_Lens in
            self?.updateProgress_Lens(currentTime_Lens: time_Lens)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Lens),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Lens.currentItem
        )

        loadingIndicator_Lens.stopAnimating()
        player_Lens.play()
        isPlaying_Lens = true
        playPauseButton_Lens.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Lens.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Lens: AVPlayer 当前时间
    private func updateProgress_Lens(currentTime_Lens: CMTime) {
        guard let duration_Lens = player_Lens?.currentItem?.duration,
              duration_Lens.isNumeric, duration_Lens.seconds > 0 else { return }
        let progress_Lens = CGFloat(currentTime_Lens.seconds / duration_Lens.seconds)
        let totalW_Lens   = progressBg_Lens.bounds.width
        progressWidthCon_Lens?.update(offset: totalW_Lens * min(max(progress_Lens, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Lens() {
        player_Lens?.seek(to: .zero)
        isPlaying_Lens = false
        playPauseButton_Lens.isSelected = false
        progressWidthCon_Lens?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Lens() {
        if let token_Lens = timeObserverToken_Lens {
            player_Lens?.removeTimeObserver(token_Lens)
            timeObserverToken_Lens = nil
        }
        player_Lens?.removeObserver(self, forKeyPath: "status")
        player_Lens?.pause()
        player_Lens = nil
        playerLayer_Lens?.removeFromSuperlayer()
        playerLayer_Lens = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Lens = object as? AVPlayer,
              player_Lens.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Lens() }
    }

    // MARK: - 图片辅助

    private func applyImage_Lens(_ image_Lens: UIImage) {
        loadingIndicator_Lens.stopAnimating()
        imageView_Lens.image = image_Lens
        imageSize_Lens       = image_Lens.size
        mediaTypeLabel_Lens.text = "Photo"
        updateImageLayout_Lens()
    }

    private func onImageLoaded_Lens(_ image_Lens: UIImage) {
        imageSize_Lens = image_Lens.size
        mediaTypeLabel_Lens.text = "Photo"
        updateImageLayout_Lens()
    }

    private func showEmpty_Lens() {
        loadingIndicator_Lens.stopAnimating()
        imageView_Lens.image       = UIImage(systemName: "photo.slash")
        imageView_Lens.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Lens.contentMode = .center
    }

    private func updateImageLayout_Lens() {
        guard imageSize_Lens != .zero else {
            imageView_Lens.frame = view.bounds
            scrollView_Lens.contentSize = view.bounds.size
            return
        }
        let screenW_Lens = view.bounds.width
        let screenH_Lens = view.bounds.height
        let ratio_Lens   = imageSize_Lens.height / imageSize_Lens.width
        let imgH_Lens    = screenW_Lens * ratio_Lens
        let y_Lens       = max(0, (screenH_Lens - imgH_Lens) / 2)
        imageView_Lens.frame        = CGRect(x: 0, y: y_Lens, width: screenW_Lens, height: imgH_Lens)
        scrollView_Lens.contentSize = CGSize(width: screenW_Lens,
                                              height: max(imgH_Lens + y_Lens * 2, screenH_Lens))
        scrollView_Lens.zoomScale   = 1.0
        centerImageIfNeeded_Lens()
    }

    private func centerImageIfNeeded_Lens() {
        let offX_Lens = max(0, (scrollView_Lens.bounds.width  - scrollView_Lens.contentSize.width)  / 2)
        let offY_Lens = max(0, (scrollView_Lens.bounds.height - scrollView_Lens.contentSize.height) / 2)
        imageView_Lens.center = CGPoint(
            x: scrollView_Lens.contentSize.width  / 2 + offX_Lens,
            y: scrollView_Lens.contentSize.height / 2 + offY_Lens
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Lens(_ gesture_Lens: UITapGestureRecognizer) {
        guard resolvedType_Lens == .image_Lens else { return }
        if scrollView_Lens.zoomScale > 1.0 {
            scrollView_Lens.setZoomScale(1.0, animated: true)
        } else {
            let pt_Lens    = gesture_Lens.location(in: imageView_Lens)
            let rect_Lens  = zoomRect_Lens(scale_Lens: 2.5, center_Lens: pt_Lens)
            scrollView_Lens.zoom(to: rect_Lens, animated: true)
        }
    }

    @objc private func handleSingleTap_Lens() {
        guard resolvedType_Lens != .video_Lens,
              scrollView_Lens.zoomScale <= 1.01 else { return }
        dismissPage_Lens(velocity_Lens: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Lens() {
        togglePlayPause_Lens()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Lens() {
        guard let player_Lens = player_Lens else { return }
        if isPlaying_Lens {
            player_Lens.pause()
            isPlaying_Lens = false
            playPauseButton_Lens.isSelected = false
        } else {
            player_Lens.play()
            isPlaying_Lens = true
            playPauseButton_Lens.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Lens.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Lens else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Lens.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Lens() {
        dismissPage_Lens(velocity_Lens: 0)
    }

    @objc private func handlePan_Lens(_ gesture_Lens: UIPanGestureRecognizer) {
        guard scrollView_Lens.zoomScale <= 1.01 else { return }
        let translation_Lens = gesture_Lens.translation(in: view)
        let velocity_Lens    = gesture_Lens.velocity(in: view).y
        switch gesture_Lens.state {
        case .changed:
            let progress_Lens         = max(0, translation_Lens.y / view.bounds.height)
            backgroundView_Lens.alpha = max(0, 1 - progress_Lens * 1.5)
            topBar_Lens.alpha         = max(0, 1 - progress_Lens * 2)
            bottomHint_Lens.alpha     = max(0, 1 - progress_Lens * 2)
            let activeView_Lens: UIView = resolvedType_Lens == .video_Lens
                ? videoContainerView_Lens : scrollView_Lens
            activeView_Lens.transform = CGAffineTransform(
                translationX: translation_Lens.x * 0.3,
                y: max(0, translation_Lens.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Lens = translation_Lens.y > view.bounds.height * 0.25 || velocity_Lens > 900
            if shouldDismiss_Lens {
                dismissPage_Lens(velocity_Lens: velocity_Lens)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Lens.transform         = .identity
                    self.videoContainerView_Lens.transform = .identity
                    self.backgroundView_Lens.alpha  = 1
                    self.topBar_Lens.alpha           = 1
                    self.bottomHint_Lens.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Lens: 下拉速度（影响动画时长）
    private func dismissPage_Lens(velocity_Lens: CGFloat) {
        guard !isDismissing_Lens else { return }
        isDismissing_Lens = true
        player_Lens?.pause()
        let duration_Lens = velocity_Lens > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Lens, animations: {
            self.view.alpha = 0
            let activeView_Lens: UIView = self.resolvedType_Lens == .video_Lens
                ? self.videoContainerView_Lens : self.scrollView_Lens
            activeView_Lens.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Lens(scale_Lens: CGFloat, center_Lens: CGPoint) -> CGRect {
        let w_Lens = scrollView_Lens.bounds.width  / scale_Lens
        let h_Lens = scrollView_Lens.bounds.height / scale_Lens
        return CGRect(x: center_Lens.x - w_Lens / 2,
                      y: center_Lens.y - h_Lens / 2,
                      width: w_Lens, height: h_Lens)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Lens: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Lens }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Lens() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Lens: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Lens = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Lens.zoomScale <= 1.01 else { return false }
        let vel_Lens = pan_Lens.velocity(in: view)
        return abs(vel_Lens.y) > abs(vel_Lens.x) && vel_Lens.y > 0
    }
}
