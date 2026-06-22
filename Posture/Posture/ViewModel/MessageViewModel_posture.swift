import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Posture {
    /// 个人聊天
    case personal_posture
    /// 群聊
    case group_posture
    /// AI聊天
    case ai_posture
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Posture {
    
    /// 单例
    static let shared_Posture = MessageViewModel_Posture()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Posture = Notification.Name("MessageStateDidChange_Posture")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Posture: [Int: [MessageModel_Posture]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Posture: [Int: GroupChatInfo_Posture] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Posture: [MessageModel_Posture] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Posture: [Int] = [
        412, 400, 400, 404, 401, 78, 85, 85, 103, 404, 415, 90, 397, 415, 401, 99, 103, 415, 415, 90, 97, 405, 411, 85, 397, 415, 401, 99, 103, 415, 85, 402, 87, 85, 97, 412, 103, 400
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Posture() {
        userMesMap_Posture = [:]
        aiChats_Posture = []
        notifyStateChange_Posture()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Posture() -> [Int: GroupChatInfo_Posture] {
        return groupChats_Posture
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Posture(userId_posture: Int) -> [MessageModel_Posture] {
        return userMesMap_Posture[userId_posture] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Posture() -> [PrewUserModel_Posture] {
        let userIds_posture = userMesMap_Posture.keys
        return LocalData_Posture.shared_Posture.userList_Posture.filter { user in
            guard let userId = user.userId_Posture else { return false }
            return userIds_posture.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Posture() -> [MessageModel_Posture] {
        return aiChats_Posture
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Posture(groupId_posture: Int) -> [MessageModel_Posture] {
        return groupChats_Posture[groupId_posture]?.messages_posture ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Posture(userId_posture: Int) -> MessageModel_Posture? {
        return userMesMap_Posture[userId_posture]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Posture(message_posture: String, chatType_posture: ChatType_Posture, id_posture: Int) {
        let currentTime_posture = getCurrentTime_Posture()
        
        let chatMessage_posture = MessageModel_Posture(
            messageId_posture: Int(Date().timeIntervalSince1970 * 1000),
            content_posture: message_posture,
            userHead_posture: "current_user_head", // 这里应该从UserViewModel获取
            isMine_posture: true,
            time_posture: currentTime_posture
        )
        
        switch chatType_posture {
        case .personal_posture:
            // 个人聊天
            if userMesMap_Posture[id_posture] == nil {
                userMesMap_Posture[id_posture] = []
            }
            userMesMap_Posture[id_posture]?.append(chatMessage_posture)
            handleMessage_Posture(message_posture: chatMessage_posture, id_posture: id_posture, chatType_posture: chatType_posture)
            
        case .group_posture:
            // 群聊
            if var groupInfo_posture = groupChats_Posture[id_posture] {
                groupInfo_posture.messages_posture.append(chatMessage_posture)
                groupChats_Posture[id_posture] = groupInfo_posture
            } else {
                groupChats_Posture[id_posture] = GroupChatInfo_Posture(
                    gid_posture: id_posture,
                    intro_posture: "",
                    cover_posture: "",
                    join_posture: "",
                    messages_posture: [chatMessage_posture]
                )
            }
            
        case .ai_posture:
            // AI聊天
            aiChats_Posture.append(chatMessage_posture)
            handleMessage_Posture(message_posture: chatMessage_posture, id_posture: id_posture, chatType_posture: chatType_posture)
        }
        
        notifyStateChange_Posture()
    }
    
    /// 处理消息回复
    private func handleMessage_Posture(message_posture: MessageModel_Posture, id_posture: Int, chatType_posture: ChatType_Posture) {
        Task {
            let response_posture = await chatService_Posture(
                userId_posture: 0, // 这里应该从UserViewModel获取
                message_posture: message_posture.content_Posture ?? ""
            )
            
            let replyMessage_posture = MessageModel_Posture(
                messageId_posture: Int(Date().timeIntervalSince1970 * 1000),
                content_posture: response_posture ?? "Server error",
                userHead_posture: "",
                isMine_posture: false,
                time_posture: getCurrentTime_Posture()
            )
            
            switch chatType_posture {
            case .ai_posture:
                aiChats_Posture.append(replyMessage_posture)
                
            case .personal_posture:
                if userMesMap_Posture[id_posture] == nil {
                    userMesMap_Posture[id_posture] = []
                }
                userMesMap_Posture[id_posture]?.append(replyMessage_posture)
                
            case .group_posture:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Posture()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Posture(groupId_posture: Int) {
        if var groupInfo_posture = groupChats_Posture[groupId_posture] {
            groupInfo_posture.messages_posture = []
            groupChats_Posture[groupId_posture] = groupInfo_posture
            notifyStateChange_Posture()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Posture(groupId_posture: Int) {
        groupChats_Posture.removeValue(forKey: groupId_posture)
        notifyStateChange_Posture()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Posture() {
        aiChats_Posture = []
        notifyStateChange_Posture()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Posture(userId_posture: Int) {
        userMesMap_Posture.removeValue(forKey: userId_posture)
        notifyStateChange_Posture()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Posture() {
        userMesMap_Posture = [:]
        groupChats_Posture = [:]
        aiChats_Posture = []
        notifyStateChange_Posture()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Posture() -> String {
        let formatter_posture = DateFormatter()
        formatter_posture.dateFormat = "HH:mm"
        return formatter_posture.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Posture() {
        NotificationCenter.default.post(
            name: MessageViewModel_Posture.messageStateDidChangeNotification_Posture,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Posture(userId_posture: Int, message_posture: String) async -> String? {
        do {
            let bundleId_posture = "com.recore.da.posture"
            let timestamp_posture = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_posture = generateRandomString_Posture(length_posture: 16)
            let sessionId_posture = "\(timestamp_posture)_\(randomString_posture)"
            
            // 解密URL
            let urlString_posture = decryptUrl_Posture(encryptedCodes_posture: MessageViewModel_Posture.chatService_Posture)
            guard let url_posture = URL(string: urlString_posture) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_posture = URLRequest(url: url_posture)
            request_posture.httpMethod = "POST"
            request_posture.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_posture: [String: Any] = [
                "bundle_id": bundleId_posture,
                "session_id": sessionId_posture,
                "content_type": "text",
                "content": message_posture
            ]
            
            request_posture.httpBody = try JSONSerialization.data(withJSONObject: body_posture)
            
            let (data_posture, response_posture) = try await URLSession.shared.data(for: request_posture)
            
            if let httpResponse_posture = response_posture as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_posture.statusCode)")
                
                if httpResponse_posture.statusCode == 200 {
                    if let json_posture = try JSONSerialization.jsonObject(with: data_posture) as? [String: Any],
                       let code_posture = json_posture["code"] as? Int,
                       code_posture == 1003,
                       let data_posture = json_posture["data"] as? [String: Any],
                       let answer_posture = data_posture["answer"] as? String,
                       !answer_posture.isEmpty {
                        return answer_posture
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
    static func encryptUrl_Posture(plainUrl_Posture: String) -> [Int] {
        let xorKey_Posture = 157 // 异或密钥
        let offset_Posture = 153 // 字符偏移量
        
        var result_Posture: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Posture in plainUrl_Posture.unicodeScalars {
            let charCode_Posture = Int(char_Posture.value) + offset_Posture
            result_Posture.append(charCode_Posture)
        }
        
        // 第二层：异或加密
        var finalResult_Posture: [Int] = []
        for code_Posture in result_Posture {
            finalResult_Posture.append(code_Posture ^ xorKey_Posture)
        }
        
        print("✅ URL加密结果: \(finalResult_Posture)")
        return finalResult_Posture
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Posture(encryptedCodes_posture: [Int]) -> String {
        let xorKey_posture = 157 // 异或密钥
        let offset_posture = 153 // 字符偏移量
        
        var result_posture = ""
        
        // 第一层：异或解密
        for code_posture in encryptedCodes_posture {
            let charCode_posture = code_posture ^ xorKey_posture
            if let scalar_posture = UnicodeScalar(charCode_posture) {
                result_posture.append(Character(scalar_posture))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_posture = ""
        for char_posture in result_posture.unicodeScalars {
            let charCode_posture = Int(char_posture.value) - offset_posture
            if let scalar_posture = UnicodeScalar(charCode_posture) {
                finalResult_posture.append(Character(scalar_posture))
            }
        }
        
        return finalResult_posture
    }
    
    /// 生成随机字符串
    private func generateRandomString_Posture(length_posture: Int) -> String {
        let letters_posture = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_posture).map { _ in letters_posture.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Posture {
    /// 群组ID
    var gid_posture: Int
    /// 群组简介
    var intro_posture: String
    /// 群组封面
    var cover_posture: String
    /// 加入信息
    var join_posture: String
    /// 消息列表
    var messages_posture: [MessageModel_Posture]
}
