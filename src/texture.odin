import "shared:gl.odin"
import stbi "shared:odin-stb/stb_image.odin"
import "core:strings.odin"

texture :: struct{
	width, height, id: u32,
	
}

to_c_string :: proc(s: string) -> []u8 {
	c_str := make([]u8, len(s)+1);
	copy(c_str, cast([]u8)s);
	c_str[len(s)] = 0;
	return c_str;
}

LoadTexture :: proc(path: string) -> texture{
	t: texture;

	w, h, c: i32;
	s := to_c_string(path);
	image := stbi.load(&s[0], &w, &h, &c, 4);

	gl.GenTextures(1, &t.id);
	gl.BindTexture(gl.TEXTURE_2D, t.id);

	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, image);

	stbi.image_free(image);

	t.width = u32(w);
	t.height = u32(h);

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);

	gl.BindTexture(gl.TEXTURE_2D, 0);

	return t;
}

BindTexture :: proc(t: texture){
	gl.BindTexture(gl.TEXTURE_2D, t.id);
}

UnbindTexture :: proc(){
	gl.BindTexture(gl.TEXTURE_2D, 0);
}