import "shared:gl.odin"

import "math.odin";


setUniformMat4 :: proc(location: i32, mat: math.mat4){
	gl.UniformMatrix4fv(location, 1, gl.FALSE, &mat.elements[0]);
}

setUniform1i :: proc(location: i32, i: i32){
	gl.Uniform1i(location, i);
}