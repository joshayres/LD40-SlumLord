import "core:fmt.odin";
import "core:strings.odin";
import "shared:glfw.odin";
import "shared:gl.odin";
import "shared:font.odin";

import "shader.odin"
import "math.odin";
import t "texture.odin";
import va "vertexarray.odin";
import "rand.odin";

keys: [348]bool = {false};

HouseState ::  enum{
	OK, GRASS, WATER, ROOF, PAINT, HEAT, 
}

GAMESTATE :: enum{
	MENU, PLAY, LOSE,
}

house :: struct{
	size : f32 = 5.0,
	mesh, b_mesh: va.vertex_array,
	tex: t.texture,
	bubble: [5]t.texture,
	pos: math.v2,
	r_pay_time: f32 = 60,
	pay_time, pay: f32,

	state: HouseState,

	owned: bool,
}

gui :: struct{
	size : math.v2,
	mesh, b_mesh: va.vertex_array,
	tex: t.texture,
	pos: math.v2,
	str: string,
}

CreateGui :: proc(size, pos : math.v2, str: string) -> gui{
	result: gui;

	gl_pos := [...]f32{
		-result.size.x / 2.0, -result.size.y / 2,
		-result.size.x / 2.0, result.size.y / 2,
		result.size.x / 2.0, result.size.y / 2,
		result.size.x / 2.0, -result.size.y / 2,	
	};

	indices := [...]byte{
		0,1,2,
		2,3,0
	};

	tcs := [...]f32{
		0,1,
		0,0,
		1,0,
		1,1
	};

	result.mesh = va.CreateVAO(gl_pos, indices, tcs);

	result.tex = t.LoadTexture("Art/button.png");
	result.pos = pos;
	result.str = str;

	return result;
}

Menu :: proc(prog: u32) -> GAMESTATE{
	play := CreateGui(math.v2{4, 4}, math.v2{0, 7}, "To Play Press Enter!");

	gl.UseProgram(prog);
	uniform_infos := gl.get_uniforms_from_program(prog);
	shader.setUniformMat4(uniform_infos["ml_matrix"].location, math.TranslateMat4(play.pos));
	t.BindTexture(play.tex);
	va.Render(play.mesh);
	t.UnbindTexture();
	gl.UseProgram(0);

	colors_font := font.get_colors();
	for i in 0..4 do colors_font[i] = font.Vec4{1.0, 1.0, 1.0, 1.0};
	        
	font.update_colors(4);

	font.draw_string(1600/2 - 100, 900/2 - 50, 12.0, "Press Enter To PLAY!!!");

	if keys[glfw.KEY_ENTER]{
		return GAMESTATE.PLAY;
	}
	return GAMESTATE.MENU;
}

Lose :: proc(prog: u32) -> GAMESTATE{
	play := CreateGui(math.v2{4, 4}, math.v2{0, 7}, "To Play Press Enter!");

	gl.UseProgram(prog);
	uniform_infos := gl.get_uniforms_from_program(prog);
	shader.setUniformMat4(uniform_infos["ml_matrix"].location, math.TranslateMat4(play.pos));
	t.BindTexture(play.tex);
	va.Render(play.mesh);
	t.UnbindTexture();
	gl.UseProgram(0);

	colors_font := font.get_colors();
	for i in 0..4 do colors_font[i] = font.Vec4{1.0, 1.0, 1.0, 1.0};
	        
	font.update_colors(4);

	font.draw_string(1600/2 - 100, 900/2 - 50, 12.0, "Press Enter To Play Again!!!");

	if keys[glfw.KEY_ENTER]{
		return GAMESTATE.PLAY;
	}
	return GAMESTATE.LOSE;
}

CreateHouse :: proc(v: math.v2, pay: f32, owned: bool) -> house{
	result: house;

	pos := [...]f32{
		-result.size / 2.0, -result.size / 2,
		-result.size / 2.0, result.size / 2,
		result.size / 2.0, result.size / 2,
		result.size / 2.0, -result.size / 2,	
	};

	indices := [...]byte{
		0,1,2,
		2,3,0
	};

	tcs := [...]f32{
		0,1,
		0,0,
		1,0,
		1,1
	};

	result.mesh = va.CreateVAO(pos, indices, tcs);

	pos = [...]f32{
		-result.size / 4.0, -result.size / 4,
		-result.size / 4.0, result.size / 4,
		result.size / 4.0, result.size / 4,
		result.size / 4.0, -result.size / 4,	
	};

	result.b_mesh = va.CreateVAO(pos, indices, tcs);

	result.tex = t.LoadTexture("Art/house.png");

	result.bubble[0] = t.LoadTexture("Art/textbubble_grass.png");
	result.bubble[1] = t.LoadTexture("Art/textbubble_water.png");
	result.bubble[2] = t.LoadTexture("Art/textbubble_heat.png");
	result.bubble[3] = t.LoadTexture("Art/textbubble_roof.png");
	//result.bubble[0] = t.LoadTexture("Art/textbubble_grass.png");

	result.pos = v;
	result.state = HouseState.OK;
	result.pay = pay;
	result.owned = owned;

	return result;
}

RenderHouse :: proc(h: house, prog: u32){
	gl.UseProgram(prog);
	uniform_infos := gl.get_uniforms_from_program(prog);
	shader.setUniformMat4(uniform_infos["ml_matrix"].location, math.TranslateMat4(h.pos));
	t.BindTexture(h.tex);
	va.Render(h.mesh);
	t.UnbindTexture();
	if(h.state != HouseState.OK){
		shader.setUniformMat4(uniform_infos["ml_matrix"].location, math.TranslateMat4(math.v2{h.pos.x + 2.0, h.pos.y + 2.0}));
		if(h.state == HouseState.GRASS){
			t.BindTexture(h.bubble[0]);
		}
		else if(h.state == HouseState.WATER){
			t.BindTexture(h.bubble[1]);
		}
		else if(h.state == HouseState.HEAT){
			t.BindTexture(h.bubble[2]);
		}
		else if(h.state == HouseState.ROOF){
			t.BindTexture(h.bubble[3]);
		}
		va.Render(h.b_mesh);
		t.UnbindTexture();
	}

	gl.UseProgram(0);
}

UpdateHouse :: proc(h: ^house, money: f32, number: i32) -> f32{
	if h.owned == true{
		if(h.state == HouseState.OK){
			test := rand.random(500, (number + 1) * 2 * i32(glfw.GetTime()));
			if(test < 375){
				h.state = HouseState.OK;
			}else if(test < 425){
				h.state = HouseState.GRASS;
			}else if(test < 475){
				h.state = HouseState.WATER;
			}else if(test < 490){
				h.state = HouseState.HEAT;
			}else{
				h.state = HouseState.ROOF;
			}
		}

		if keys[glfw.KEY_G] && keys[number + 49]{
			if h.state == HouseState.GRASS{
				h.state = HouseState.OK;
				money += 100.0;
			}else do
				money -= 100.0;
		}

		if keys[glfw.KEY_W] && keys[number + 49]{
			if h.state == HouseState.WATER{
				h.state = HouseState.OK;
				money += 500.0;
			}else do
				money -= 100.0;
		}

		if keys[glfw.KEY_H] && keys[number + 49]{
			if h.state == HouseState.HEAT{
				h.state = HouseState.OK;
				money += 500.0;
			}else do
				money -= 100.0;
		}

		if keys[glfw.KEY_R] && keys[number + 49]{
			if h.state == HouseState.ROOF{
				h.state = HouseState.OK;
				money += 1000.0;
			}else do
				money -= 100.0;
		}
		
		

		h.pay_time -= 1;
		if h.pay_time <= 0 {
			h.pay_time = h.r_pay_time;
			if h.state == HouseState.OK{
				money += h.pay;
			}else{
				money -= 2000.0;
			}
		}
	}
	return money;
}

clear :: proc(){
	gl.ClearColor(1.0, 0.0, 1.0, 1.0);

	gl.Clear(gl.COLOR_BUFFER_BIT);	
}

main :: proc() {
	error_callback :: proc"c"(error: i32, desc: ^u8){
		fmt.printf("Error code %d:\n	%s\n", error, strings.to_odin_string(desc));
	}
	glfw.SetErrorCallback(error_callback);

	if glfw.Init() == 0 do return;
	defer glfw.Terminate();

	//GLFW stuff
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 5);
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);

	//Window Stuff
	resx, resy := 1600.0, 900.0;
	window := glfw.CreateWindow(i32(resx), i32(resy), "OGame", nil, nil);
	if window == nil do return;

	glfw.MakeContextCurrent(window);
	glfw.SetKeyCallback(window, glfw.Key_Proc(keyCallback));
	glfw.SwapInterval(1);

	// setup opengl
    set_proc_address :: proc(p: rawptr, name: string) { 
        (cast(^rawptr)p)^ = rawptr(glfw.GetProcAddress(&name[0]));
    }
	gl.load_up_to(4, 5, set_proc_address);

	if !font.init("Art/font_3x1.bin", "shader/shader_font.vs", "shader/shader_font.fs") do return;

	//defer font.cleanup();

	bg_program, shader_success := gl.load_shaders("shader/background.vert", "shader/background.frag");
	defer gl.DeleteProgram(bg_program);

	uniform_infos := gl.get_uniforms_from_program(bg_program);

	pr_matrix := math.CreateOrthoMat4(-16, 16, -9, 9, -1, 1);

	gl.ActiveTexture(gl.TEXTURE0);

	gl.UseProgram(bg_program);
	shader.setUniformMat4(uniform_infos["pr_matrix"].location, pr_matrix);
	shader.setUniform1i(uniform_infos["tex"].location, 0);
	gl.UseProgram(0);

	h_program, h_shader_success := gl.load_shaders("shader/house.vs", "shader/house.fs");

	uniform_infos = gl.get_uniforms_from_program(h_program);

	gl.UseProgram(h_program);
	shader.setUniformMat4(uniform_infos["pr_matrix"].location, pr_matrix);
	shader.setUniform1i(uniform_infos["tex"].location, 0);
	gl.UseProgram(0);

	h : [10]house;
	h[0]= CreateHouse(math.v2{-14, 6}, 680.0, true);
	h[1]= CreateHouse(math.v2{-8, 6.5}, 800.0, false);
	h[2]= CreateHouse(math.v2{-3.5, 4.5}, 1000.0, false);
	h[3]= CreateHouse(math.v2{0, 3}, 1240.0, false);
	h[4]= CreateHouse(math.v2{4, 1}, 1400.0, false);
	h[5]= CreateHouse(math.v2{8, -0.4}, 1680.0, false);
	h[6]= CreateHouse(math.v2{11, -4}, 1900.0, false);
	h[7]= CreateHouse(math.v2{7.5, -6}, 2240.0, false);
	h[8]= CreateHouse(math.v2{0, -7}, 2560.0, false);
	h[9]= CreateHouse(math.v2{-34.1, -7.5}, 3000.0, false);

	money : f32 = 15000.0;

	pos := [...]f32{
		-16, -9,
		-16, 9,
		16, 9,
		16, -9
	};

	indices := [...]byte{
		0,1,2,
		2,3,0
	};

	tcs := [...]f32{
		0,1,
		0,0,
		1,0,
		1,1
	};

	bg := va.CreateVAO(pos, indices, tcs);

	bgt := t.LoadTexture("Art/bg.png");

	owned := 1;

	game_state := GAMESTATE.MENU;

	for glfw.WindowShouldClose(window) == glfw.FALSE {
		
		clear();
		glfw.PollEvents();

		if game_state == GAMESTATE.PLAY{
			gl.UseProgram(bg_program);
			t.BindTexture(bgt);
			va.Render(bg);
			t.UnbindTexture();
			gl.UseProgram(0);

			for i in 0..owned{
				RenderHouse(h[i], h_program);
				money = UpdateHouse(&h[i], money, i32(i));
			}
			colors_font := font.get_colors();
	        for i in 0..4 do colors_font[i] = font.Vec4{1.0, 1.0, 1.0, 1.0};
	        
			font.update_colors(4);

			font.draw_format(0, 0, 12.0, "Money : $%f", money);

			if money >= 10000.0 && keys[glfw.KEY_B] && owned < 8{
				owned += 1;
				money -= 10000.0;
				h[owned].owned = true;
			}

			if money < 0{
				game_state = GAMESTATE.LOSE;
			}
		}else if game_state == GAMESTATE.MENU{
			gl.UseProgram(bg_program);
			t.BindTexture(bgt);
			va.Render(bg);
			t.UnbindTexture();
			gl.UseProgram(0);

			game_state = Menu(h_program);
		}else if game_state == GAMESTATE.LOSE{
			gl.UseProgram(bg_program);
			t.BindTexture(bgt);
			va.Render(bg);
			t.UnbindTexture();
			gl.UseProgram(0);

			game_state = Lose(h_program);
			money = 15000.0;
			owned = 1;
		}

		glfw.SwapBuffers(window);
	}
} 

get_uniform_location :: proc(program: u32, str: string) -> i32 {
    return gl.GetUniformLocation(program, &str[0]);;
}

keyCallback :: proc(window: glfw.Window_Handle, key, scancode, action, mods: i32){
	keys[key] = action != glfw.RELEASE;
}

initOpenAL :: proc(){
	//al.Create();
}