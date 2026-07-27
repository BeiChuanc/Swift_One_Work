import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Orna {
    /// 个人聊天
    case personal_orna
    /// AI聊天
    case ai_orna
}

/// 消息状态管理类
/// 功能：管理个人聊天与AI聊天的消息存储、发送及清空操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class MessageViewModel_Orna {

    /// 单例
    static let shared_Orna = MessageViewModel_Orna()

    // MARK: - 通知名称

    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Orna = Notification.Name("MessageStateDidChange_Orna")

    // MARK: - 私有属性

    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Orna: [Int: [MessageModel_Orna]] = [:]

    /// AI聊天消息列表
    private var aiChats_Orna: [MessageModel_Orna] = []

    /// 聊天服务URL（加密存储）
    private static let chatService_Orna: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]

    private init() {}

    // MARK: - 公共方法 - 初始化 / 退出

    /// 初始化消息
    /// 功能：清空所有消息数据（个人聊天与AI聊天）
    func initChat_Orna() {
        userMesMap_Orna = [:]
        aiChats_Orna = []
        notifyStateChange_Orna()
    }

    /// 退出登录清空所有聊天数据
    func logoutChat_Orna() {
        initChat_Orna()
    }

    // MARK: - 公共方法 - 获取数据

    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Orna(userId_orna: Int) -> [MessageModel_Orna] {
        userMesMap_Orna[userId_orna] ?? []
    }

    /// 获取有聊天记录的用户列表
    func getChatUsers_Orna() -> [PrewUserModel_Orna] {
        LocalData_Orna.shared_Orna.userList_Orna.filter {
            guard let userId = $0.userId_Orna else { return false }
            return userMesMap_Orna.keys.contains(userId)
        }
    }

    /// 获取AI聊天消息列表
    func getAiChats_Orna() -> [MessageModel_Orna] { aiChats_Orna }

    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Orna(userId_orna: Int) -> MessageModel_Orna? {
        userMesMap_Orna[userId_orna]?.last
    }

    // MARK: - 公共方法 - 发送消息

    /// 发送消息
    /// 功能：构建消息并存储，同时异步请求服务端回复
    /// 参数：
    /// - message_orna: 消息文本内容
    /// - chatType_orna: 聊天类型（个人 / AI）
    /// - id_orna: 对话目标ID（个人聊天为用户ID，AI聊天传任意占位值）
    func sendMessage_Orna(message_orna: String, chatType_orna: ChatType_Orna, id_orna: Int) {
        let msg_orna = buildMessage_Orna(content_orna: message_orna, isMine_orna: true)
        appendMessage_Orna(msg_orna, chatType_orna: chatType_orna, id_orna: id_orna)
        handleReply_Orna(for: msg_orna, chatType_orna: chatType_orna, id_orna: id_orna)
        notifyStateChange_Orna()
    }

    // MARK: - 公共方法 - 清空消息

    /// 清空AI聊天记录
    func clearAiChat_Orna() {
        aiChats_Orna = []
        notifyStateChange_Orna()
    }

    /// 删除与指定用户的消息
    func deleteUserMessages_Orna(userId_orna: Int) {
        userMesMap_Orna.removeValue(forKey: userId_orna)
        notifyStateChange_Orna()
    }

    // MARK: - 私有方法 - 消息处理

    /// 构建消息模型
    /// 功能：统一构造 MessageModel，自动填充时间戳和当前时间
    /// 参数：
    /// - content_orna: 消息文本
    /// - isMine_orna: 是否为本人发送
    /// 返回值：构建完成的 MessageModel_Orna
    private func buildMessage_Orna(content_orna: String, isMine_orna: Bool) -> MessageModel_Orna {
        MessageModel_Orna(
            messageId_orna: Int(Date().timeIntervalSince1970 * 1000),
            content_orna: content_orna,
            userHead_orna: isMine_orna ? "current_user_head" : "",
            isMine_orna: isMine_orna,
            time_orna: getCurrentTime_Orna()
        )
    }

    /// 将消息追加到对应存储
    /// 参数：
    /// - msg_orna: 要追加的消息模型
    /// - chatType_orna: 聊天类型
    /// - id_orna: 个人聊天时为用户ID
    private func appendMessage_Orna(_ msg_orna: MessageModel_Orna, chatType_orna: ChatType_Orna, id_orna: Int) {
        switch chatType_orna {
        case .personal_orna:
            userMesMap_Orna[id_orna, default: []].append(msg_orna)
        case .ai_orna:
            aiChats_Orna.append(msg_orna)
        }
    }

    /// 异步请求服务端回复并追加到对应存储
    /// 参数：
    /// - msg_orna: 已发送的消息（用于提取内容请求接口）
    /// - chatType_orna: 聊天类型
    /// - id_orna: 对话目标ID
    private func handleReply_Orna(for msg_orna: MessageModel_Orna, chatType_orna: ChatType_Orna, id_orna: Int) {
        Task {
            let content_orna = await chatService_Orna(
                userId_orna: 0,
                message_orna: msg_orna.content_Orna ?? ""
            ) ?? "Server error"

            let reply_orna = buildMessage_Orna(content_orna: content_orna, isMine_orna: false)
            appendMessage_Orna(reply_orna, chatType_orna: chatType_orna, id_orna: id_orna)
            notifyStateChange_Orna()
        }
    }

    // MARK: - 私有方法 - 工具方法

    /// 获取当前时间字符串（HH:mm 格式）
    private func getCurrentTime_Orna() -> String {
        let formatter_orna = DateFormatter()
        formatter_orna.dateFormat = "HH:mm"
        return formatter_orna.string(from: Date())
    }

    /// 发送状态更新通知
    private func notifyStateChange_Orna() {
        NotificationCenter.default.post(
            name: MessageViewModel_Orna.messageStateDidChangeNotification_Orna,
            object: nil
        )
    }

    // MARK: - 网络请求

    /// 聊天服务API
    /// 功能：向服务端发送用户消息，返回AI回复内容
    /// 参数：
    /// - userId_orna: 当前用户ID
    /// - message_orna: 消息文本内容
    /// 返回值：服务端回复文本，失败时返回 nil
    private func chatService_Orna(userId_orna: Int, message_orna: String) async -> String? {
        do {
            let sessionId_orna = "\(Int(Date().timeIntervalSince1970 * 1000))_\(generateRandomString_Orna(length_orna: 16))"
            let urlString_orna = decryptUrl_Orna(encryptedCodes_orna: MessageViewModel_Orna.chatService_Orna)

            guard let url_orna = URL(string: urlString_orna) else {
                print("❌ 错误：无效的URL")
                return nil
            }

            var request_orna = URLRequest(url: url_orna)
            request_orna.httpMethod = "POST"
            request_orna.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request_orna.httpBody = try JSONSerialization.data(withJSONObject: [
                "bundle_id": "com.orna.app",
                "session_id": sessionId_orna,
                "content_type": "text",
                "content": message_orna
            ])

            let (data_orna, response_orna) = try await URLSession.shared.data(for: request_orna)

            guard let http_orna = response_orna as? HTTPURLResponse else { return "Server error" }
            print("✅ HTTP状态码: \(http_orna.statusCode)")

            guard http_orna.statusCode == 200,
                  let json_orna = try JSONSerialization.jsonObject(with: data_orna) as? [String: Any],
                  let code_orna = json_orna["code"] as? Int, code_orna == 1003,
                  let dataDict_orna = json_orna["data"] as? [String: Any],
                  let answer_orna = dataDict_orna["answer"] as? String,
                  !answer_orna.isEmpty else { return "Server error" }

            return answer_orna
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }

    /// URL加密方法（字符偏移 +23 后异或 ^20）
    /// 功能：对明文URL进行两层加密，生成整数编码数组
    /// 参数：
    /// - plainUrl_Orna: 待加密的原始URL字符串
    /// 返回值：加密后的整数编码数组
    static func encryptUrl_Orna(plainUrl_Orna: String) -> [Int] {
        let result_Orna = plainUrl_Orna.unicodeScalars.map { (Int($0.value) + 23) ^ 20 }
        print("✅ URL加密结果: \(result_Orna)")
        return result_Orna
    }

    /// URL解密方法（异或 ^20 后字符偏移 -23）
    /// 功能：对加密整数数组进行两层解密，还原原始URL
    /// 参数：
    /// - encryptedCodes_orna: 加密整数数组
    /// 返回值：解密后的URL字符串
    private func decryptUrl_Orna(encryptedCodes_orna: [Int]) -> String {
        String(encryptedCodes_orna.compactMap {
            UnicodeScalar(($0 ^ 20) - 23).map { Character($0) }
        })
    }

    /// 生成随机字符串
    /// 参数：
    /// - length_orna: 字符串长度
    /// 返回值：由字母和数字组成的随机字符串
    private func generateRandomString_Orna(length_orna: Int) -> String {
        let letters_orna = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_orna).map { _ in letters_orna.randomElement()! })
    }
}
