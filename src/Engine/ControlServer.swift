// MARK: - TimeDuck · ControlServer.swift
// LiveSplit-style external control IPC engine.
// Provides a zero-dependency, local-loopback HTTP API on 127.0.0.1:1834 for
// local LLMs (Ollama, LM Studio), terminal AI agents, and browser extensions.

import Foundation
import Network

final class ControlServer {
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.oxalpha.timeduck.control-server", qos: .userInitiated)
    static let defaultPort: UInt16 = 1834
    let port: NWEndpoint.Port

    typealias CommandHandler = (_ action: String, _ label: String?, _ mode: String?) -> Void
    typealias StatusProvider = () -> [String: Any]

    private let onCommand: CommandHandler
    private let onStatus: StatusProvider

    init(port: UInt16 = ControlServer.defaultPort,
         onCommand: @escaping CommandHandler,
         onStatus: @escaping StatusProvider) {
        self.port = NWEndpoint.Port(rawValue: port) ?? NWEndpoint.Port(integerLiteral: 1834)
        self.onCommand = onCommand
        self.onStatus = onStatus
    }

    func start() {
        do {
            let tcpOptions = NWProtocolTCP.Options()
            let params = NWParameters(tls: nil, tcp: tcpOptions)
            params.allowLocalEndpointReuse = true
            params.requiredLocalEndpoint = NWEndpoint.hostPort(host: NWEndpoint.Host("127.0.0.1"), port: port)

            let l = try NWListener(using: params, on: port)
            self.listener = l

            l.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    #if DEBUG
                    print("🦆 TimeDuck ControlServer listening on http://127.0.0.1:\(l.port?.rawValue ?? 1834)")
                    #endif
                case .failed(let err):
                    #if DEBUG
                    print("⚠️ TimeDuck ControlServer failed: \(err)")
                    #endif
                default:
                    break
                }
            }

            l.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }

            l.start(queue: queue)
        } catch {
            #if DEBUG
            print("⚠️ TimeDuck ControlServer failed to start: \(error)")
            #endif
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        receiveNextChunk(connection: connection, accumulated: Data())
    }

    private func receiveNextChunk(connection: NWConnection, accumulated: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            var buffer = accumulated
            if let data = content {
                buffer.append(data)
            }
            if buffer.count > 0 {
                self.processHTTPRequest(connection: connection, data: buffer)
            } else if isComplete || error != nil {
                connection.cancel()
            }
        }
    }

    private func processHTTPRequest(connection: NWConnection, data: Data) {
        guard let requestStr = String(data: data, encoding: .utf8) else {
            sendResponse(connection: connection, status: 400, body: "{\"error\":\"Invalid Encoding\"}")
            return
        }

        let lines = requestStr.components(separatedBy: "\r\n")
        guard let requestLine = lines.first, !requestLine.isEmpty else {
            sendResponse(connection: connection, status: 400, body: "{\"error\":\"Empty Request\"}")
            return
        }

        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            sendResponse(connection: connection, status: 400, body: "{\"error\":\"Malformed Request Line\"}")
            return
        }

        let method = parts[0].uppercased()
        let rawUri = parts[1]

        if method == "OPTIONS" {
            // Support CORS preflight for web extensions & browser apps
            sendResponse(connection: connection, status: 204, body: "")
            return
        }

        // Parse URI and Query
        let urlComponents = URLComponents(string: rawUri)
        let path = urlComponents?.path.lowercased() ?? ""
        var labelParam = urlComponents?.queryItems?.first(where: {
            $0.name.lowercased() == "label" || $0.name.lowercased() == "name"
        })?.value
        let modeParam = urlComponents?.queryItems?.first(where: {
            $0.name.lowercased() == "mode"
        })?.value

        // Check for JSON payload in body
        if let bodyRange = requestStr.range(of: "\r\n\r\n") {
            let bodyStr = String(requestStr[bodyRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !bodyStr.isEmpty, let bodyData = bodyStr.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] {
                if labelParam == nil, let l = json["label"] as? String ?? json["name"] as? String {
                    labelParam = l
                }
            }
        }

        if method == "GET" && (path == "/api/status" || path == "/status" || path == "/") {
            let statusDict = self.onStatus()
            if let jsonData = try? JSONSerialization.data(withJSONObject: statusDict, options: [.prettyPrinted]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                sendResponse(connection: connection, status: 200, body: jsonString)
            } else {
                sendResponse(connection: connection, status: 500, body: "{\"error\":\"Status Serialization Failed\"}")
            }
            return
        }

        // Parse Action
        var action: String?
        if path.hasSuffix("/start") {
            action = "start"
        } else if path.hasSuffix("/split") || path.hasSuffix("/lap") {
            action = "lap"
        } else if path.hasSuffix("/stop") {
            action = "stop"
        } else if path.hasSuffix("/reset") {
            action = "reset"
        }

        if let action = action {
            self.onCommand(action, labelParam, modeParam)
            let res = "{\"ok\":true,\"action\":\"\(action)\"}"
            sendResponse(connection: connection, status: 200, body: res)
        } else {
            sendResponse(connection: connection, status: 404, body: "{\"error\":\"Unknown Endpoint\"}")
        }
    }

    private func sendResponse(connection: NWConnection, status: Int, body: String) {
        let statusText = (status == 200 ? "OK" : (status == 204 ? "No Content" : (status == 404 ? "Not Found" : "Error")))
        let bodyData = body.data(using: .utf8) ?? Data()
        let headers = """
        HTTP/1.1 \(status) \(statusText)\r
        Content-Type: application/json; charset=utf-8\r
        Content-Length: \(bodyData.count)\r
        Access-Control-Allow-Origin: *\r
        Access-Control-Allow-Methods: GET, POST, OPTIONS\r
        Access-Control-Allow-Headers: Content-Type, Authorization\r
        Connection: close\r
        \r
        
        """
        var responseData = headers.data(using: .utf8) ?? Data()
        responseData.append(bodyData)

        connection.send(content: responseData, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}
