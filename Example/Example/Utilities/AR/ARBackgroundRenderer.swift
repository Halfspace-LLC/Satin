//
//  ARBackgroundRenderer.swift
//  Example
//
//  Created by Reza Ali on 3/15/23.
//  Copyright © 2023 Hi-Rez. All rights reserved.
//

#if os(iOS)
import ARKit
import Foundation
import Metal
import Satin

class ARBackgroundRenderer: PostProcessor {
    class BackgroundMaterial: SourceMaterial {
        public var capturedImageTextureY: CVMetalTexture?
        public var capturedImageTextureCbCr: CVMetalTexture?

        public required init() {
            super.init(pipelinesURL: Bundle.main.resourceURL!
                .appendingPathComponent("Assets")
                .appendingPathComponent("Shared")
                .appendingPathComponent("Pipelines")
            )
            depthWriteEnabled = false
        }

        required init(from _: Decoder) throws {
            fatalError("init(from:) has not been implemented")
        }

        override func bind(_ renderEncoder: MTLRenderCommandEncoder, shadow: Bool) {
            super.bind(renderEncoder, shadow: shadow)
            if let textureY = capturedImageTextureY, let textureCbCr = capturedImageTextureCbCr {
                renderEncoder.setFragmentTexture(CVMetalTextureGetTexture(textureY), index: FragmentTextureIndex.Custom0.rawValue)
                renderEncoder.setFragmentTexture(CVMetalTextureGetTexture(textureCbCr), index: FragmentTextureIndex.Custom1.rawValue)
            }
        }
    }

    // Captured image texture cache
    private var capturedImageTextureCache: CVMetalTextureCache!
    private var viewportSize = CGSize(width: 0, height: 0)
    private var _updateGeometry = true

    unowned var session: ARSession

    public init(context: Context, session: ARSession) {
        self.session = session
        super.init(context: context, material: BackgroundMaterial())
        mesh.visible = false
        renderer.setClearColor([0, 0, 0, 1])
        setupTextureCache()
        NotificationCenter.default.addObserver(self, selector: #selector(ARBackgroundRenderer.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.label = "AR Background Renderer"
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func rotated() {
        _updateGeometry = true
    }

    private func update() {
        guard let frame = session.currentFrame else { return }
        updateTextures(frame)

        if _updateGeometry {
            updateGeometry(frame)
            _updateGeometry = false
        }
    }

    override func draw(renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        update()
        super.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
    }

    override func draw(renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer, renderTarget: MTLTexture) {
        update()
        super.draw(renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer, renderTarget: renderTarget)
    }

    private func updateGeometry(_ frame: ARFrame) {
        guard let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation else { return }

        // Update the texture coordinates of our image plane to aspect fill the viewport
        let displayToCameraTransform = frame.displayTransform(for: interfaceOrientation, viewportSize: viewportSize).inverted()

        let geo = QuadGeometry()
        for (index, vertex) in geo.vertexData.enumerated() {
            let uv = vertex.uv
            let textureCoord = CGPoint(x: CGFloat(uv.x), y: CGFloat(uv.y))
            let transformedCoord = textureCoord.applying(displayToCameraTransform)
            geo.vertexData[index].uv = simd_make_float2(Float(transformedCoord.x), Float(transformedCoord.y))
        }

        mesh.geometry = geo
    }

    override func resize(_ size: (width: Float, height: Float)) {
        super.resize(size)
        _updateGeometry = true
        viewportSize = CGSize(width: Int(size.width), height: Int(size.height))
    }

    func updateTextures(_ frame: ARFrame) {
        if let material = mesh.material as? BackgroundMaterial, CVPixelBufferGetPlaneCount(frame.capturedImage) == 2 {
            material.capturedImageTextureY = createTexture(
                fromPixelBuffer: frame.capturedImage,
                pixelFormat: .r8Unorm,
                planeIndex: 0
            )

            material.capturedImageTextureCbCr = createTexture(
                fromPixelBuffer: frame.capturedImage,
                pixelFormat: .rg8Unorm,
                planeIndex: 1
            )

            mesh.visible = true
        }
        else {
            mesh.visible = false
        }
    }

    private func setupTextureCache() {
        // Create captured image texture cache
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, context.device, nil, &textureCache)
        capturedImageTextureCache = textureCache
    }

    private func createTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)

        var texture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, capturedImageTextureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)

        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }
}
#endif
