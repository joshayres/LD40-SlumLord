import "shared:gl.odin"

vertex_array :: struct{
	count: u32 = 6,
	vao, vbo, ibo, tcs: u32,
}

CreateVAO :: proc(v: [8]f32, i: [6]byte, tcs: [8]f32) -> vertex_array{
	result: vertex_array;

	gl.GenVertexArrays(1, &result.vao);
	gl.BindVertexArray(result.vao);

	gl.GenBuffers(1, &result.vbo);
	gl.BindBuffer(gl.ARRAY_BUFFER, result.vbo);
	gl.BufferData(gl.ARRAY_BUFFER, size_of(v), &v[0], gl.STATIC_DRAW);
	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 0, nil);
	gl.EnableVertexAttribArray(0);

	gl.GenBuffers(1, &result.tcs);
	gl.BindBuffer(gl.ARRAY_BUFFER, result.tcs);
	gl.BufferData(gl.ARRAY_BUFFER, size_of(tcs), &tcs[0], gl.STATIC_DRAW);
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 0, nil);
	gl.EnableVertexAttribArray(1);


	gl.GenBuffers(1, &result.ibo);
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, result.ibo);
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(i), &i[0], gl.STATIC_DRAW);

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
	gl.BindBuffer(gl.ARRAY_BUFFER, 0);
	gl.BindVertexArray(0);

	return result;
}

BindVAO :: proc(v: vertex_array){
	gl.BindVertexArray(v.vao);
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, v.ibo);
}

UnbindVAO :: proc(v: vertex_array){
	gl.BindVertexArray(0);
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
}

Draw :: proc(v: vertex_array){
	gl.DrawElements(gl.TRIANGLES, i32(v.count), gl.UNSIGNED_BYTE, nil);
}

Render :: proc(v:vertex_array){
	BindVAO(v);
	Draw(v);
	UnbindVAO(v);
}