import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Somnia {
    /// 个人聊天
    case personal_somnia
    /// 群聊
    case group_somnia
    /// AI聊天
    case ai_somnia
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Somnia {
    
    /// 单例
    static let shared_Somnia = MessageViewModel_Somnia()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Somnia = Notification.Name("MessageStateDidChange_Somnia")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Somnia: [Int: [MessageModel_Somnia]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Somnia: [Int: GroupChatInfo_Somnia] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Somnia: [MessageModel_Somnia] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Somnia: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Somnia() {
        userMesMap_Somnia = [:]
        aiChats_Somnia = []
        notifyStateChange_Somnia()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Somnia() -> [Int: GroupChatInfo_Somnia] {
        return groupChats_Somnia
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Somnia(userId_somnia: Int) -> [MessageModel_Somnia] {
        return userMesMap_Somnia[userId_somnia] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Somnia() -> [PrewUserModel_Somnia] {
        let userIds_somnia = userMesMap_Somnia.keys
        return LocalData_Somnia.shared_Somnia.userList_Somnia.filter { user in
            guard let userId = user.userId_Somnia else { return false }
            return userIds_somnia.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Somnia() -> [MessageModel_Somnia] {
        return aiChats_Somnia
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Somnia(groupId_somnia: Int) -> [MessageModel_Somnia] {
        return groupChats_Somnia[groupId_somnia]?.messages_somnia ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Somnia(userId_somnia: Int) -> MessageModel_Somnia? {
        return userMesMap_Somnia[userId_somnia]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Somnia(message_somnia: String, chatType_somnia: ChatType_Somnia, id_somnia: Int) {
        let currentTime_somnia = getCurrentTime_Somnia()
        
        let chatMessage_somnia = MessageModel_Somnia(
            messageId_somnia: Int(Date().timeIntervalSince1970 * 1000),
            content_somnia: message_somnia,
            userHead_somnia: "current_user_head", // 这里应该从UserViewModel获取
            isMine_somnia: true,
            time_somnia: currentTime_somnia
        )
        
        switch chatType_somnia {
        case .personal_somnia:
            // 个人聊天
            if userMesMap_Somnia[id_somnia] == nil {
                userMesMap_Somnia[id_somnia] = []
            }
            userMesMap_Somnia[id_somnia]?.append(chatMessage_somnia)
            handleMessage_Somnia(message_somnia: chatMessage_somnia, id_somnia: id_somnia, chatType_somnia: chatType_somnia)
            
        case .group_somnia:
            // 群聊
            if var groupInfo_somnia = groupChats_Somnia[id_somnia] {
                groupInfo_somnia.messages_somnia.append(chatMessage_somnia)
                groupChats_Somnia[id_somnia] = groupInfo_somnia
            } else {
                groupChats_Somnia[id_somnia] = GroupChatInfo_Somnia(
                    gid_somnia: id_somnia,
                    intro_somnia: "",
                    cover_somnia: "",
                    join_somnia: "",
                    messages_somnia: [chatMessage_somnia]
                )
            }
            
        case .ai_somnia:
            // AI聊天
            aiChats_Somnia.append(chatMessage_somnia)
            handleMessage_Somnia(message_somnia: chatMessage_somnia, id_somnia: id_somnia, chatType_somnia: chatType_somnia)
        }
        
        notifyStateChange_Somnia()
    }
    
    /// 处理消息回复
    private func handleMessage_Somnia(message_somnia: MessageModel_Somnia, id_somnia: Int, chatType_somnia: ChatType_Somnia) {
        Task {
            let response_somnia = await chatService_Somnia(
                userId_somnia: 0, // 这里应该从UserViewModel获取
                message_somnia: message_somnia.content_Somnia ?? ""
            )
            
            let replyMessage_somnia = MessageModel_Somnia(
                messageId_somnia: Int(Date().timeIntervalSince1970 * 1000),
                content_somnia: response_somnia ?? "Server error",
                userHead_somnia: "",
                isMine_somnia: false,
                time_somnia: getCurrentTime_Somnia()
            )
            
            switch chatType_somnia {
            case .ai_somnia:
                aiChats_Somnia.append(replyMessage_somnia)
                
            case .personal_somnia:
                if userMesMap_Somnia[id_somnia] == nil {
                    userMesMap_Somnia[id_somnia] = []
                }
                userMesMap_Somnia[id_somnia]?.append(replyMessage_somnia)
                
            case .group_somnia:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Somnia()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Somnia(groupId_somnia: Int) {
        if var groupInfo_somnia = groupChats_Somnia[groupId_somnia] {
            groupInfo_somnia.messages_somnia = []
            groupChats_Somnia[groupId_somnia] = groupInfo_somnia
            notifyStateChange_Somnia()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Somnia(groupId_somnia: Int) {
        groupChats_Somnia.removeValue(forKey: groupId_somnia)
        notifyStateChange_Somnia()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Somnia() {
        aiChats_Somnia = []
        notifyStateChange_Somnia()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Somnia(userId_somnia: Int) {
        userMesMap_Somnia.removeValue(forKey: userId_somnia)
        notifyStateChange_Somnia()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Somnia() {
        userMesMap_Somnia = [:]
        groupChats_Somnia = [:]
        aiChats_Somnia = []
        notifyStateChange_Somnia()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Somnia() -> String {
        let formatter_somnia = DateFormatter()
        formatter_somnia.dateFormat = "HH:mm"
        return formatter_somnia.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Somnia() {
        NotificationCenter.default.post(
            name: MessageViewModel_Somnia.messageStateDidChangeNotification_Somnia,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Somnia(userId_somnia: Int, message_somnia: String) async -> String? {
        do {
            let bundleId_somnia = "com.somnia.app"
            let timestamp_somnia = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_somnia = generateRandomString_Somnia(length_somnia: 16)
            let sessionId_somnia = "\(timestamp_somnia)_\(randomString_somnia)"
            
            // 解密URL
            let urlString_somnia = decryptUrl_Somnia(encryptedCodes_somnia: MessageViewModel_Somnia.chatService_Somnia)
            guard let url_somnia = URL(string: urlString_somnia) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_somnia = URLRequest(url: url_somnia)
            request_somnia.httpMethod = "POST"
            request_somnia.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_somnia: [String: Any] = [
                "bundle_id": bundleId_somnia,
                "session_id": sessionId_somnia,
                "content_type": "text",
                "content": message_somnia
            ]
            
            request_somnia.httpBody = try JSONSerialization.data(withJSONObject: body_somnia)
            
            let (data_somnia, response_somnia) = try await URLSession.shared.data(for: request_somnia)
            
            if let httpResponse_somnia = response_somnia as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_somnia.statusCode)")
                
                if httpResponse_somnia.statusCode == 200 {
                    if let json_somnia = try JSONSerialization.jsonObject(with: data_somnia) as? [String: Any],
                       let code_somnia = json_somnia["code"] as? Int,
                       code_somnia == 1003,
                       let data_somnia = json_somnia["data"] as? [String: Any],
                       let answer_somnia = data_somnia["answer"] as? String,
                       !answer_somnia.isEmpty {
                        return answer_somnia
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
    static func encryptUrl_Somnia(plainUrl_Somnia: String) -> [Int] {
        let xorKey_Somnia = 20 // 异或密钥
        let offset_Somnia = 23 // 字符偏移量
        
        var result_Somnia: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Somnia in plainUrl_Somnia.unicodeScalars {
            let charCode_Somnia = Int(char_Somnia.value) + offset_Somnia
            result_Somnia.append(charCode_Somnia)
        }
        
        // 第二层：异或加密
        var finalResult_Somnia: [Int] = []
        for code_Somnia in result_Somnia {
            finalResult_Somnia.append(code_Somnia ^ xorKey_Somnia)
        }
        
        print("✅ URL加密结果: \(finalResult_Somnia)")
        return finalResult_Somnia
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Somnia(encryptedCodes_somnia: [Int]) -> String {
        let xorKey_somnia = 20 // 异或密钥
        let offset_somnia = 23 // 字符偏移量
        
        var result_somnia = ""
        
        // 第一层：异或解密
        for code_somnia in encryptedCodes_somnia {
            let charCode_somnia = code_somnia ^ xorKey_somnia
            if let scalar_somnia = UnicodeScalar(charCode_somnia) {
                result_somnia.append(Character(scalar_somnia))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_somnia = ""
        for char_somnia in result_somnia.unicodeScalars {
            let charCode_somnia = Int(char_somnia.value) - offset_somnia
            if let scalar_somnia = UnicodeScalar(charCode_somnia) {
                finalResult_somnia.append(Character(scalar_somnia))
            }
        }
        
        return finalResult_somnia
    }
    
    /// 生成随机字符串
    private func generateRandomString_Somnia(length_somnia: Int) -> String {
        let letters_somnia = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_somnia).map { _ in letters_somnia.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Somnia {
    /// 群组ID
    var gid_somnia: Int
    /// 群组简介
    var intro_somnia: String
    /// 群组封面
    var cover_somnia: String
    /// 加入信息
    var join_somnia: String
    /// 消息列表
    var messages_somnia: [MessageModel_Somnia]
}
