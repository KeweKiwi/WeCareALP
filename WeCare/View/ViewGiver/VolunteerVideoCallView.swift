//
//  VolunteerVideoCallView.swift
//  WeCare
//
//  Created by student on 26/11/25.
//
import SwiftUI
import CoreLocation
import Combine
import AVFoundation

struct VolunteerVideoCallView: View {
    let volunteer: Volunteer
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRinging: Bool = true
    @State private var isConnected: Bool = false
    @State private var isMuted: Bool = false
    @State private var isCameraOff: Bool = false
    @State private var callDuration: Int = 0
    
    @StateObject private var camera = CameraService()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // TOP INFO
                VStack(spacing: 4) {
                    Text("Video Call with")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(volunteer.name)
                        .font(.title2.bold())
                    
                    if isRinging && !isConnected {
                        Text("Ringing...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    } else if isConnected {
                        Text(formatDuration(callDuration))
                            .font(.headline.monospacedDigit())
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 10)
                
                // VIDEO AREA
                ZStack(alignment: .bottomTrailing) {
                    // Remote video (VOLUNTEER) – besar dengan nama di tengah
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                        
                        VStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            Text(volunteer.name)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Local preview (CAREGIVER) – kecil (PiP) di kanan bawah
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            ZStack(alignment: .bottomTrailing) {
                                // Kotak kamera kecil (background tetep)
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isCameraOff ? Color.gray.opacity(0.85)
                                                      : Color.black.opacity(0.85))
                                    .frame(width: 120, height: 160)
                                
                                // Isi utama: kalau camera ON => preview kamera beneran (front/self POV)
                                ZStack {
                                    if isCameraOff {
                                        VStack(spacing: 6) {
                                            Image(systemName: "video.slash.fill")
                                                .font(.system(size: 36))
                                                .foregroundColor(.white)
                                            Text("Camera Off")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    } else {
                                        CameraPreviewView(session: camera.session)
                                            .overlay(
                                                // Kalau ada error configure, tampilkan kecil aja biar ga ganggu UI
                                                Group {
                                                    if let err = camera.lastError {
                                                        Text(err)
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.white)
                                                            .padding(6)
                                                            .background(Color.red.opacity(0.75))
                                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                                            .padding(6)
                                                    }
                                                },
                                                alignment: .topLeading
                                            )
                                            .overlay(
                                                Text("You")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .padding(6),
                                                alignment: .bottomLeading
                                            )
                                    }
                                }
                                .frame(width: 120, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Status MIC (off-mic) di pojok kanan bawah DALAM kotak
                                if isMuted {
                                    Image(systemName: "mic.slash.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.red.opacity(0.85))
                                        .clipShape(Circle())
                                        .padding(.trailing, 6)
                                        .padding(.bottom, 6)
                                }
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 28)
                        }
                    }
                }
                .frame(height: 380)
                
                Spacer()
                
                // SIMULATE ANSWER (Prototype)
                if isRinging && !isConnected {
                    Button(action: {
                        withAnimation(.spring()) {
                            isRinging = false
                            isConnected = true
                        }
                    }) {
                        Text("Simulate Answer (Prototype)")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#387b38"))
                    }
                }
                
                // BOTTOM CONTROLS
                HStack(spacing: 40) {
                    // Mute
                    Button(action: {
                        isMuted.toggle()
                    }) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.9))
                            .clipShape(Circle())
                    }
                    
                    // Camera toggle (POV caregiver / kotak kecil)
                    Button(action: {
                        isCameraOff.toggle()
                        if isCameraOff {
                            camera.stop()
                        } else {
                            camera.startFrontCamera()
                        }
                    }) {
                        Image(systemName: isCameraOff ? "video.slash.fill" : "video.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#91bef8"))
                            .clipShape(Circle())
                    }
                    
                    // End call
                    Button(action: {
                        camera.stop()
                        dismiss()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#fa6255"))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitle("Video Call", displayMode: .inline)
        .onReceive(timer) { _ in
            if isConnected {
                callDuration += 1
            }
        }
        .onAppear {
            if !isCameraOff {
                camera.startFrontCamera()
            }
        }
        .onDisappear {
            camera.stop()
        }
    }
    
    // MARK: - Helpers
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Camera Engine (robust)

final class CameraService: ObservableObject {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var isConfigured = false
    
    @Published var lastError: String? = nil
    
    func startFrontCamera() {
        lastError = nil
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied || status == .restricted {
            DispatchQueue.main.async {
                self.lastError = "Camera access denied/restricted"
            }
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                DispatchQueue.main.async { self.lastError = "Camera permission not granted" }
                return
            }
            
            self.sessionQueue.async {
                if !self.isConfigured {
                    let ok = self.configureFrontCameraUsingDiscovery()
                    self.isConfigured = ok
                    if !ok { return }
                }
                
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    private func configureFrontCameraUsingDiscovery() -> Bool {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // Clear existing inputs
        for input in session.inputs {
            session.removeInput(input)
        }
        
        // Lebih aman daripada .default(...):
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTrueDepthCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .front
        )
        
        guard let device = discovery.devices.first else {
            session.commitConfiguration()
            DispatchQueue.main.async { self.lastError = "Front camera not found" }
            return false
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input) else {
                session.commitConfiguration()
                DispatchQueue.main.async { self.lastError = "Cannot add camera input" }
                return false
            }
            session.addInput(input)
            session.commitConfiguration()
            return true
        } catch {
            session.commitConfiguration()
            DispatchQueue.main.async { self.lastError = "Camera input error: \(error.localizedDescription)" }
            return false
        }
    }
}

// MARK: - Preview Layer (super stable in SwiftUI)

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    
    var videoLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { videoLayer.session }
        set { videoLayer.session = newValue }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = bounds
        videoLayer.videoGravity = .resizeAspectFill
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.backgroundColor = .black
        v.session = session
        return v
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.session = session
    }
}


