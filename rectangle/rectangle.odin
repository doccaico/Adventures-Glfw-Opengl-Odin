package rectangle

import "base:runtime"
import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

WIDTH :: 600
HEIGHT :: 600
TITLE :: "rectangle"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

set_window_center :: proc(window: glfw.WindowHandle) -> bool {
	monitor := glfw.GetPrimaryMonitor()
	if monitor == nil {
		fmt.eprintln("GLFW has failed to get the primary monitor.")
		return false
	}
	mode := glfw.GetVideoMode(monitor)
	if mode == nil {
		fmt.eprintln("GLFW has failed to get the video mode.")
		return false
	}

	x := (mode.width / 2) - (WIDTH / 2)
	y := (mode.height / 2) - (HEIGHT / 2)

	glfw.SetWindowPos(window, x, y)
	if exist_glfw_error("GLFW has failed to set window position to the center.") {
		return false
	}
	return true
}

exist_glfw_error :: proc(message: string) -> bool {
	if _, code := glfw.GetError(); code != glfw.NO_ERROR {
		fmt.eprintln(message)
		return true
	}
	return false
}

error_callback :: proc "c" (code: i32, desc: cstring) {
	context = runtime.default_context()
	fmt.eprintfln("%s (0x%x).", desc, code)
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, glfw.TRUE)
	}
}

main :: proc() {
	glfw.SetErrorCallback(error_callback)

	if !glfw.Init() {
		fmt.eprintln("GLFW has failed to load.")
		return
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	glfw.WindowHint(glfw.RESIZABLE, 0)

	window := glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)
	if window == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}
	defer glfw.DestroyWindow(window)

	glfw.SetKeyCallback(window, key_callback)

	glfw.MakeContextCurrent(window)
	if exist_glfw_error("GLFW has failed to make context.") {
		return
	}

	glfw.SwapInterval(1)
	if exist_glfw_error("GLFW has failed to set swap interval.") {
		return
	}

	if !set_window_center(window) {
		return
	}

	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)


	// vertices := [?]f32{
	// 	0.5,  0.5, 0.0,
	// 	0.5, -0.5, 0.0,
	// 	-0.5,  0.5, 0.0,
	// 	-0.5, -0.5, 0.0,
	// }

	vertices := [?]f32{
		1.0,  1.0, 0.0,
		1.0, -1.0, 0.0,
		-1.0,  1.0, 0.0,
		-1.0, -1.0, 0.0,
	}

	vbo: u32 = ---
	gl.GenBuffers(1, &vbo)
	defer gl.DeleteBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

    vao: u32 = ---
    gl.GenVertexArrays(1, &vao);
    defer gl.DeleteVertexArrays(1, &vao);
    gl.BindVertexArray(vao);
    gl.EnableVertexAttribArray(0);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0);

	vs_source :: `
        #version 330
        
        in vec3 vp;
        
        void main() {
          gl_Position = vec4(vp, 1.0);
        }`

    fs_source :: `
        #version 330

        out vec4 frag_color;

        void main() {
          frag_color = vec4(0.5, 0.0, 0.5, 1.0);
        }`

	program, ok := gl.load_shaders_source(vs_source, fs_source)
	if !ok {
		return
	}
	defer gl.DeleteProgram(program)

    // *Wireframe mode*
    // gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	gl.UseProgram(program)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.ClearColor(0.2, 0.4, 0.8, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

        // left bottom
        gl.Viewport(0, 0, WIDTH / 2, HEIGHT / 2);
        gl.DrawArrays(gl.TRIANGLE_STRIP, 0, 4);

		glfw.SwapBuffers(window)
	}
}
