import Foundation
import Combine

// MARK: - 消息ViewModel

/// 消息类型枚举
enum ChatType_blisslink {
    /// 个人聊天
    case personal_blisslink
    /// 群聊
    case group_blisslink
    /// AI聊天
    case ai_blisslink
}

/// 消息状态管理类
class MessageViewModel_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = MessageViewModel_blisslink()
    
    // MARK: - 响应式属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    @Published var userMesMap_blisslink: [Int: [MessageModel_blisslink]] = [:]
    
    /// 群聊信息映射（群组ID -> 群聊信息）
    @Published var groupChats_blisslink: [Int: GroupChatInfo_blisslink] = [:]
    
    /// AI聊天消息列表
    @Published var aiChats_blisslink: [MessageModel_blisslink] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_blisslink: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    func initChat_blisslink() {
        userMesMap_blisslink = [:]
        aiChats_blisslink = []
        setGroup_blisslink()
    }
    
    /// 设置群聊基础信息
    private func setGroup_blisslink() {
        groupChats_blisslink = [
            10: GroupChatInfo_blisslink(
                gid_blisslink: 10,
                intro_blisslink: "Creative Ideas Hub",
                cover_blisslink: "",
                join_blisslink: "",
                messages_blisslink: []
            ),
            11: GroupChatInfo_blisslink(
                gid_blisslink: 11,
                intro_blisslink: "Tech Enthusiasts",
                cover_blisslink: "",
                join_blisslink: "",
                messages_blisslink: []
            ),
            12: GroupChatInfo_blisslink(
                gid_blisslink: 12,
                intro_blisslink: "Adventure Team",
                cover_blisslink: "",
                join_blisslink: "",
                messages_blisslink: []
            ),
            13: GroupChatInfo_blisslink(
                gid_blisslink: 13,
                intro_blisslink: "Creative Community",
                cover_blisslink: "",
                join_blisslink: "",
                messages_blisslink: []
            ),
            14: GroupChatInfo_blisslink(
                gid_blisslink: 14,
                intro_blisslink: "Friendly Circle",
                cover_blisslink: "",
                join_blisslink: "",
                messages_blisslink: []
            )
        ]
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_blisslink() -> [Int: GroupChatInfo_blisslink] {
        return groupChats_blisslink
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_blisslink(userId_blisslink: Int) -> [MessageModel_blisslink] {
        return userMesMap_blisslink[userId_blisslink] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_blisslink() -> [PrewUserModel_blisslink] {
        let userIds_blisslink = userMesMap_blisslink.keys
        return LocalData_blisslink.shared_blisslink.userList_blisslink.filter { user_blisslink in
            guard let userId_blisslink = user_blisslink.userId_blisslink else { return false }
            return userIds_blisslink.contains(userId_blisslink)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_blisslink() -> [MessageModel_blisslink] {
        return aiChats_blisslink
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_blisslink(groupId_blisslink: Int) -> [MessageModel_blisslink] {
        return groupChats_blisslink[groupId_blisslink]?.messages_blisslink ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_blisslink(userId_blisslink: Int) -> MessageModel_blisslink? {
        return userMesMap_blisslink[userId_blisslink]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_blisslink(message_blisslink: String, chatType_blisslink: ChatType_blisslink, id_blisslink: Int) {
        let currentTime_blisslink = getCurrentTime_blisslink()
        
        let chatMessage_blisslink = MessageModel_blisslink(
            messageId_blisslink: Int(Date().timeIntervalSince1970 * 1000),
            content_blisslink: message_blisslink,
            userHead_blisslink: "current_user_head", // 这里应该从UserViewModel获取
            isMine_blisslink: true,
            time_blisslink: currentTime_blisslink
        )
        
        switch chatType_blisslink {
        case .personal_blisslink:
            // 个人聊天
            if userMesMap_blisslink[id_blisslink] == nil {
                userMesMap_blisslink[id_blisslink] = []
            }
            userMesMap_blisslink[id_blisslink]?.append(chatMessage_blisslink)
            handleMessage_blisslink(message_blisslink: chatMessage_blisslink, id_blisslink: id_blisslink, chatType_blisslink: chatType_blisslink)
            
        case .group_blisslink:
            // 群聊
            if var groupInfo_blisslink = groupChats_blisslink[id_blisslink] {
                groupInfo_blisslink.messages_blisslink.append(chatMessage_blisslink)
                groupChats_blisslink[id_blisslink] = groupInfo_blisslink
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            } else {
                groupChats_blisslink[id_blisslink] = GroupChatInfo_blisslink(
                    gid_blisslink: id_blisslink,
                    intro_blisslink: "",
                    cover_blisslink: "",
                    join_blisslink: "",
                    messages_blisslink: [chatMessage_blisslink]
                )
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            }
            
        case .ai_blisslink:
            // AI聊天
            aiChats_blisslink.append(chatMessage_blisslink)
            handleMessage_blisslink(message_blisslink: chatMessage_blisslink, id_blisslink: id_blisslink, chatType_blisslink: chatType_blisslink)
        }
    }
    
    /// 处理消息回复
    private func handleMessage_blisslink(message_blisslink: MessageModel_blisslink, id_blisslink: Int, chatType_blisslink: ChatType_blisslink) {
        Task { @MainActor in
            let response_blisslink = await chatService_blisslink(
                userId_blisslink: 0, // 这里应该从UserViewModel获取
                message_blisslink: message_blisslink.content_blisslink ?? ""
            )
            
            let replyMessage_blisslink = MessageModel_blisslink(
                messageId_blisslink: Int(Date().timeIntervalSince1970 * 1000),
                content_blisslink: response_blisslink ?? "Server error",
                userHead_blisslink: "",
                isMine_blisslink: false,
                time_blisslink: getCurrentTime_blisslink()
            )
            
            switch chatType_blisslink {
            case .ai_blisslink:
                self.aiChats_blisslink.append(replyMessage_blisslink)
                
            case .personal_blisslink:
                if self.userMesMap_blisslink[id_blisslink] == nil {
                    self.userMesMap_blisslink[id_blisslink] = []
                }
                self.userMesMap_blisslink[id_blisslink]?.append(replyMessage_blisslink)
                
            case .group_blisslink:
                break // 群聊不自动回复
            }
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    
    /// 清空群聊消息
    func clearGroupMessages_blisslink(groupId_blisslink: Int) {
        if var groupInfo_blisslink = groupChats_blisslink[groupId_blisslink] {
            groupInfo_blisslink.messages_blisslink = []
            groupChats_blisslink[groupId_blisslink] = groupInfo_blisslink
            // 手动触发更新，确保UI及时刷新
            objectWillChange.send()
        }
    }
    
    /// 移除指定群组
    func removeGroup_blisslink(groupId_blisslink: Int) {
        groupChats_blisslink.removeValue(forKey: groupId_blisslink)
    }
    
    /// 清空AI聊天记录
    func clearAiChat_blisslink() {
        aiChats_blisslink = []
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_blisslink(userId_blisslink: Int) {
        userMesMap_blisslink.removeValue(forKey: userId_blisslink)
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_blisslink() {
        userMesMap_blisslink = [:]
        groupChats_blisslink = [:]
        aiChats_blisslink = []
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_blisslink() -> String {
        let formatter_blisslink = DateFormatter()
        formatter_blisslink.dateFormat = "HH:mm"
        return formatter_blisslink.string(from: Date())
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_blisslink(userId_blisslink: Int, message_blisslink: String) async -> String? {
        do {
            let bundleId_blisslink = "com.baseswiftui.app"
            let timestamp_blisslink = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_blisslink = generateRandomString_blisslink(length_blisslink: 16)
            let sessionId_blisslink = "\(timestamp_blisslink)_\(randomString_blisslink)"
            
            // 解密URL
            let urlString_blisslink = decryptUrl_blisslink(encryptedCodes_blisslink: MessageViewModel_blisslink.chatService_blisslink)
            guard let url_blisslink = URL(string: urlString_blisslink) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_blisslink = URLRequest(url: url_blisslink)
            request_blisslink.httpMethod = "POST"
            request_blisslink.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_blisslink: [String: Any] = [
                "bundle_id": bundleId_blisslink,
                "session_id": sessionId_blisslink,
                "content_type": "text",
                "content": message_blisslink
            ]
            
            request_blisslink.httpBody = try JSONSerialization.data(withJSONObject: body_blisslink)
            
            let (data_blisslink, response_blisslink) = try await URLSession.shared.data(for: request_blisslink)
            
            if let httpResponse_blisslink = response_blisslink as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_blisslink.statusCode)")
                
                if httpResponse_blisslink.statusCode == 200 {
                    if let json_blisslink = try JSONSerialization.jsonObject(with: data_blisslink) as? [String: Any],
                       let code_blisslink = json_blisslink["code"] as? Int,
                       code_blisslink == 1003,
                       let data_blisslink = json_blisslink["data"] as? [String: Any],
                       let answer_blisslink = data_blisslink["answer"] as? String,
                       !answer_blisslink.isEmpty {
                        return answer_blisslink
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_blisslink(encryptedCodes_blisslink: [Int]) -> String {
        let xorKey_blisslink = 20 // 异或密钥
        let offset_blisslink = 23 // 字符偏移量
        
        var result_blisslink = ""
        
        // 第一层：异或解密
        for code_blisslink in encryptedCodes_blisslink {
            let charCode_blisslink = code_blisslink ^ xorKey_blisslink
            if let scalar_blisslink = UnicodeScalar(charCode_blisslink) {
                result_blisslink.append(Character(scalar_blisslink))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_blisslink = ""
        for char_blisslink in result_blisslink.unicodeScalars {
            let charCode_blisslink = Int(char_blisslink.value) - offset_blisslink
            if let scalar_blisslink = UnicodeScalar(charCode_blisslink) {
                finalResult_blisslink.append(Character(scalar_blisslink))
            }
        }
        
        return finalResult_blisslink
    }
    
    /// 生成随机字符串
    private func generateRandomString_blisslink(length_blisslink: Int) -> String {
        let letters_blisslink = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_blisslink).map { _ in letters_blisslink.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_blisslink {
    /// 群组ID
    var gid_blisslink: Int
    /// 群组简介
    var intro_blisslink: String
    /// 群组封面
    var cover_blisslink: String
    /// 加入信息
    var join_blisslink: String
    /// 消息列表
    var messages_blisslink: [MessageModel_blisslink]
}
