

random :: proc(lim, seed: i32) -> i32{
	a := seed;
    a = (a * 32719 + 3) % 32749;
    return ((a % lim) + 1);
}