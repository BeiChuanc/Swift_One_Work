import Foundation

// MARK: 协议文本配置

/// 协议文本配置
/// 核心作用：集中提供服务条款、隐私政策、EULA 的展示内容，供设置/登录/注册/发布等页面复用
/// 设计思路：Assets 暂无协议图片时，使用内置英文文本保证协议可正常展示，形成闭环
enum ProtocolConfig_Breeze {
    
    /// 服务条款内容
    static let termsContent_Breeze = """
    Terms of Service

    Welcome to Breeze, a community for sharing park camping moments. By using this app you agree to the following terms.

    1. Account
    You are responsible for the activity on your account and for keeping your credentials safe. You must be of legal age to use this service.

    2. Content
    You own the content you post. By posting, you grant Breeze a license to display your content within the app. Do not post content that is illegal, harmful, or infringes the rights of others.

    3. Community
    Be respectful to fellow campers. Harassment, spam, and explicit material are not allowed. We may remove content or accounts that violate these terms.

    4. Reporting
    You can report posts, comments, or users at any time. Reported content may be removed to keep the community safe.

    5. Changes
    We may update these terms from time to time. Continued use of the app means you accept the updated terms.

    Thank you for being part of the Breeze community.
    """
    
    /// 隐私政策内容
    static let privacyContent_Breeze = """
    Privacy Policy

    Breeze respects your privacy. This policy explains how we handle your information.

    1. Information We Use
    We use the username and profile details you provide to power your account. Media you select is stored locally on your device.

    2. How We Use It
    Your information is used only to provide core features such as posting, commenting, following, and messaging within the app.

    3. Sharing
    We do not sell your personal information. Content you choose to publish is visible to other users of the app.

    4. Your Choices
    You can edit your profile at any time, log out, or delete your account. Deleting your account removes your session data from the app.

    5. Security
    We take reasonable measures to protect your information, but no method of storage is completely secure.

    If you have questions about this policy, please contact support.
    """
    
    /// 最终用户许可协议内容
    static let eulaContent_Breeze = """
    End User License Agreement (EULA)

    This End User License Agreement governs your use of the Breeze application.

    1. License
    Breeze grants you a personal, non-transferable, non-exclusive license to use the app on devices you own or control.

    2. Acceptable Use
    You agree not to misuse the app, including attempts to reverse engineer, distribute, or use it for unlawful purposes.

    3. User Content
    There is zero tolerance for objectionable content or abusive behavior. Content that violates this policy will be removed within 24 hours and offending users may be removed.

    4. Termination
    This license remains in effect until terminated. It will terminate automatically if you fail to comply with any term of this agreement.

    5. Disclaimer
    The app is provided "as is" without warranties of any kind to the extent permitted by law.

    By continuing to use Breeze, you acknowledge that you have read and agree to this agreement.
    """
}
