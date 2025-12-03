// Bindings for [[ frametimer.h ; https://github.com/mattiasgustavsson/libs/blob/main/frametimer.h ]].
package frametimer

import "core:c"

@(private)
LIB :: "lib/frametimer.lib" when ODIN_OS == .Windows else ""

when LIB == "" {
	#panic("Sorry, Your OS is unsupported")
}
foreign import lib {LIB when LIB != "" else "system:frametimer"}

Frametimer :: struct {}
// Frametimer :: distinct rawptr


@(default_calling_convention = "c", link_prefix = "frametimer_")
foreign lib {
	// frametimer_t* frametimer_create( void* memctx );
	create :: proc(memctx: rawptr) -> ^Frametimer ---
	// void frametimer_destroy( frametimer_t* frametimer );
	destroy :: proc(frametimer: ^Frametimer) ---
	// void frametimer_lock_rate( frametimer_t* frametimer, int fps );
	lock_rate :: proc(frametimer: ^Frametimer, fps: c.int) ---
	// float frametimer_update( frametimer_t* frametimer );
	update :: proc(frametimer: ^Frametimer) -> f32 ---
	// float frametimer_delta_time( frametimer_t* frametimer );
	delta_time :: proc(frametimer: ^Frametimer) -> f32 ---
	// int frametimer_frame_counter( frametimer_t* frametimer );
	frame_counter :: proc(frametimer: ^Frametimer) -> c.int ---
}
