import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Hush {
    /// 个人聊天
    case personal_hush
    /// 群聊
    case group_hush
    /// AI聊天
    case ai_hush
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Hush {
    
    /// 单例
    static let shared_Hush = MessageViewModel_Hush()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Hush = Notification.Name("MessageStateDidChange_Hush")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Hush: [Int: [MessageModel_Hush]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Hush: [Int: GroupChatInfo_Hush] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Hush: [MessageModel_Hush] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Hush: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Hush() {
        userMesMap_Hush = [:]
        aiChats_Hush = []
        notifyStateChange_Hush()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Hush() -> [Int: GroupChatInfo_Hush] {
        return groupChats_Hush
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Hush(userId_hush: Int) -> [MessageModel_Hush] {
        return userMesMap_Hush[userId_hush] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Hush() -> [PrewUserModel_Hush] {
        let userIds_hush = userMesMap_Hush.keys
        return LocalData_Hush.shared_Hush.userList_Hush.filter { user in
            guard let userId = user.userId_Hush else { return false }
            return userIds_hush.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Hush() -> [MessageModel_Hush] {
        return aiChats_Hush
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Hush(groupId_hush: Int) -> [MessageModel_Hush] {
        return groupChats_Hush[groupId_hush]?.messages_hush ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Hush(userId_hush: Int) -> MessageModel_Hush? {
        return userMesMap_Hush[userId_hush]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Hush(message_hush: String, chatType_hush: ChatType_Hush, id_hush: Int) {
        let currentTime_hush = getCurrentTime_Hush()
        
        let chatMessage_hush = MessageModel_Hush(
            messageId_hush: Int(Date().timeIntervalSince1970 * 1000),
            content_hush: message_hush,
            userHead_hush: "current_user_head", // 这里应该从UserViewModel获取
            isMine_hush: true,
            time_hush: currentTime_hush
        )
        
        switch chatType_hush {
        case .personal_hush:
            // 个人聊天
            if userMesMap_Hush[id_hush] == nil {
                userMesMap_Hush[id_hush] = []
            }
            userMesMap_Hush[id_hush]?.append(chatMessage_hush)
            handleMessage_Hush(message_hush: chatMessage_hush, id_hush: id_hush, chatType_hush: chatType_hush)
            
        case .group_hush:
            // 群聊
            if var groupInfo_hush = groupChats_Hush[id_hush] {
                groupInfo_hush.messages_hush.append(chatMessage_hush)
                groupChats_Hush[id_hush] = groupInfo_hush
            } else {
                groupChats_Hush[id_hush] = GroupChatInfo_Hush(
                    gid_hush: id_hush,
                    intro_hush: "",
                    cover_hush: "",
                    join_hush: "",
                    messages_hush: [chatMessage_hush]
                )
            }
            
        case .ai_hush:
            // AI聊天
            aiChats_Hush.append(chatMessage_hush)
            handleMessage_Hush(message_hush: chatMessage_hush, id_hush: id_hush, chatType_hush: chatType_hush)
        }
        
        notifyStateChange_Hush()
    }
    
    /// 处理消息回复
    private func handleMessage_Hush(message_hush: MessageModel_Hush, id_hush: Int, chatType_hush: ChatType_Hush) {
        Task {
            let response_hush = await chatService_Hush(
                userId_hush: 0, // 这里应该从UserViewModel获取
                message_hush: message_hush.content_Hush ?? ""
            )
            
            let replyMessage_hush = MessageModel_Hush(
                messageId_hush: Int(Date().timeIntervalSince1970 * 1000),
                content_hush: response_hush ?? "Server error",
                userHead_hush: "",
                isMine_hush: false,
                time_hush: getCurrentTime_Hush()
            )
            
            switch chatType_hush {
            case .ai_hush:
                aiChats_Hush.append(replyMessage_hush)
                
            case .personal_hush:
                if userMesMap_Hush[id_hush] == nil {
                    userMesMap_Hush[id_hush] = []
                }
                userMesMap_Hush[id_hush]?.append(replyMessage_hush)
                
            case .group_hush:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Hush()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Hush(groupId_hush: Int) {
        if var groupInfo_hush = groupChats_Hush[groupId_hush] {
            groupInfo_hush.messages_hush = []
            groupChats_Hush[groupId_hush] = groupInfo_hush
            notifyStateChange_Hush()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Hush(groupId_hush: Int) {
        groupChats_Hush.removeValue(forKey: groupId_hush)
        notifyStateChange_Hush()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Hush() {
        aiChats_Hush = []
        notifyStateChange_Hush()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Hush(userId_hush: Int) {
        userMesMap_Hush.removeValue(forKey: userId_hush)
        notifyStateChange_Hush()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Hush() {
        userMesMap_Hush = [:]
        groupChats_Hush = [:]
        aiChats_Hush = []
        notifyStateChange_Hush()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Hush() -> String {
        let formatter_hush = DateFormatter()
        formatter_hush.dateFormat = "HH:mm"
        return formatter_hush.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Hush() {
        NotificationCenter.default.post(
            name: MessageViewModel_Hush.messageStateDidChangeNotification_Hush,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Hush(userId_hush: Int, message_hush: String) async -> String? {
        do {
            let bundleId_hush = "com.hush.app"
            let timestamp_hush = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_hush = generateRandomString_Hush(length_hush: 16)
            let sessionId_hush = "\(timestamp_hush)_\(randomString_hush)"
            
            // 解密URL
            let urlString_hush = decryptUrl_Hush(encryptedCodes_hush: MessageViewModel_Hush.chatService_Hush)
            guard let url_hush = URL(string: urlString_hush) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_hush = URLRequest(url: url_hush)
            request_hush.httpMethod = "POST"
            request_hush.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_hush: [String: Any] = [
                "bundle_id": bundleId_hush,
                "session_id": sessionId_hush,
                "content_type": "text",
                "content": message_hush
            ]
            
            request_hush.httpBody = try JSONSerialization.data(withJSONObject: body_hush)
            
            let (data_hush, response_hush) = try await URLSession.shared.data(for: request_hush)
            
            if let httpResponse_hush = response_hush as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_hush.statusCode)")
                
                if httpResponse_hush.statusCode == 200 {
                    if let json_hush = try JSONSerialization.jsonObject(with: data_hush) as? [String: Any],
                       let code_hush = json_hush["code"] as? Int,
                       code_hush == 1003,
                       let data_hush = json_hush["data"] as? [String: Any],
                       let answer_hush = data_hush["answer"] as? String,
                       !answer_hush.isEmpty {
                        return answer_hush
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Hush(plainUrl_Hush: String) -> [Int] {
        let xorKey_Hush = 20 // 异或密钥
        let offset_Hush = 23 // 字符偏移量
        
        var result_Hush: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Hush in plainUrl_Hush.unicodeScalars {
            let charCode_Hush = Int(char_Hush.value) + offset_Hush
            result_Hush.append(charCode_Hush)
        }
        
        // 第二层：异或加密
        var finalResult_Hush: [Int] = []
        for code_Hush in result_Hush {
            finalResult_Hush.append(code_Hush ^ xorKey_Hush)
        }
        
        print("✅ URL加密结果: \(finalResult_Hush)")
        return finalResult_Hush
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Hush(encryptedCodes_hush: [Int]) -> String {
        let xorKey_hush = 20 // 异或密钥
        let offset_hush = 23 // 字符偏移量
        
        var result_hush = ""
        
        // 第一层：异或解密
        for code_hush in encryptedCodes_hush {
            let charCode_hush = code_hush ^ xorKey_hush
            if let scalar_hush = UnicodeScalar(charCode_hush) {
                result_hush.append(Character(scalar_hush))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_hush = ""
        for char_hush in result_hush.unicodeScalars {
            let charCode_hush = Int(char_hush.value) - offset_hush
            if let scalar_hush = UnicodeScalar(charCode_hush) {
                finalResult_hush.append(Character(scalar_hush))
            }
        }
        
        return finalResult_hush
    }
    
    /// 生成随机字符串
    private func generateRandomString_Hush(length_hush: Int) -> String {
        let letters_hush = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_hush).map { _ in letters_hush.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Hush {
    /// 群组ID
    var gid_hush: Int
    /// 群组简介
    var intro_hush: String
    /// 群组封面
    var cover_hush: String
    /// 加入信息
    var join_hush: String
    /// 消息列表
    var messages_hush: [MessageModel_Hush]
}
