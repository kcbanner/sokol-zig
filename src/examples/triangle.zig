//------------------------------------------------------------------------------
//  triangle.zig
//
//  Vertex buffer, shader, pipeline state object.
//------------------------------------------------------------------------------
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp = @import("sokol").app_gfx_glue;

const state = struct {
    var bind: sg.Bindings = .{};
    var pip: sg.Pipeline = .{};
};

export fn init() void {
    sg.setup(.{
        .context = sgapp.context()
    });

    // create vertex buffer with triangle vertices
    const vertices = [_]f32 {
        // positions         colors
         0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
         0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
        -0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .content = &vertices,
        .size = @sizeOf(@TypeOf(vertices))
    });

    // create a shader and pipeline object
    const shd = sg.makeShader(shaderDesc());
    var pip_desc: sg.PipelineDesc = .{
        .shader = shd
    };
    pip_desc.layout.attrs[0].format = .FLOAT3;
    pip_desc.layout.attrs[1].format = .FLOAT4;
    state.pip = sg.makePipeline(pip_desc);
}

export fn frame() void {
    // default pass-action clears to grey
    sg.beginDefaultPass(.{}, sapp.width(), sapp.height());
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 3, 1);
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 640,
        .height = 480,
        .window_title = "triangle.zig"
    });
}

// build a backend-specific ShaderDesc struct
fn shaderDesc() sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    switch (sg.queryBackend()) {
        .D3D11 => {
            desc.attrs[0].sem_name = "POS";
            desc.attrs[1].sem_name = "COLOR";
            desc.vs.source =
                \\struct vs_in {
                \\  float4 pos: POS;
                \\  float4 color: COLOR;
                \\};
                \\struct vs_out {
                \\  float4 color: COLOR0;
                \\  float4 pos: SV_Position;
                \\};
                \\vs_out main(vs_in inp) {
                \\  vs_out outp;
                \\  outp.pos = inp.pos;
                \\  outp.color = inp.color;
                \\  return outp;
                \\}
                ;
            desc.fs.source =
                \\float4 main(float4 color: COLOR0): SV_Target0 {
                \\  return color;
                \\}
                ;
        },
        else => {}
    }
    return desc;
}

