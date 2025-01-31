vertex VertexData satinVertex
(
    Vertex in [[stage_in]],
    // inject instancing args
    // inject shadow vertex args
    constant VertexUniforms &vertexUniforms [[buffer(VertexBufferVertexUniforms)]]
)
{
    VertexData out;
    
#if INSTANCING
    out.position = vertexUniforms.viewProjectionMatrix * instanceUniforms[instanceID].modelMatrix * in.position;
    out.normal = instanceUniforms[instanceID].normalMatrix * in.normal;
#else
    out.position = vertexUniforms.modelViewProjectionMatrix * in.position;
    out.normal = vertexUniforms.normalMatrix * in.normal;
#endif
    out.uv = in.uv;

    // inject shadow vertex calc
    return out;
}
