v2 :: struct{
	x: f32,
	y: f32,
}

mat4 :: struct{
	elements: [16]f32,
}

CreateMat4 :: proc() -> mat4 {
	result : mat4;
	for n in 0..16{
		result.elements[n] = 0.0;
	}
	
	result.elements[0] = 1.0;
	result.elements[1 + 1 * 4] = 1.0;
	result.elements[2 + 2 * 4] = 1.0;
	result.elements[3 + 3 * 4] = 1.0;
	
	return result;
}

CreateOrthoMat4 :: proc(left, right, bottom, top, near, far: f32) -> mat4{

	result: mat4 = CreateMat4();
	
	result.elements[0] = 2.0 / (right - left);
	result.elements[1 + 1 * 4] = 2.0 / (top - bottom);
	result.elements[2 + 2 * 4] = 2.0 / (near -  far);
	
	
	result.elements[0 + 3 * 4] = (left + right) / (left - right);
	result.elements[1 + 3 * 4] = (bottom + top) / (bottom - top);
	result.elements[2 + 3 * 4] = (far + near) / (far - near);
	
	return result;
}

TranslateMat4 :: proc(v: v2) -> mat4{
	result: mat4 = CreateMat4();
	result.elements[0 + 3 * 4] = v.x;
	result.elements[1 + 3 * 4] = v.y;

	return result;
}

MultiplyMat4 :: proc(a: mat4, b: mat4) -> mat4{
	result: mat4 = CreateMat4();
	for x in 0..4{
		for y in 0..4{
			sum: f32;
			sum = 0.0;
			for e in 0..4{
				sum += a.elements[x + e * 4] * b.elements[e + y * 4];
			}
			result.elements[x + y * 4] = sum;
		}
	}

	return result;
}