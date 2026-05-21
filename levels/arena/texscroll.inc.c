void scroll_arena_dl_Circle_002_mesh_layer_1_vtx_0() {
	int i = 0;
	int count = 106;
	int width = 32 * 0x20;
	int height = 32 * 0x20;

	static int currentX = 0;
	int deltaX;
	static int currentY = 0;
	int deltaY;
	Vtx *vertices = segmented_to_virtual(arena_dl_Circle_002_mesh_layer_1_vtx_0);

	deltaX = (int)(100.0 * 0x20) % width;
	deltaY = (int)(100.0 * 0x20) % height;

	if (absi(currentX) > width) {
		deltaX -= (int)(absi(currentX) / width) * width * signum_positive(deltaX);
	}
	if (absi(currentY) > height) {
		deltaY -= (int)(absi(currentY) / height) * height * signum_positive(deltaY);
	}

	for (i = 0; i < count; i++) {
		vertices[i].n.tc[0] += deltaX;
		vertices[i].n.tc[1] += deltaY;
	}
	currentX += deltaX;	currentY += deltaY;
}

void scroll_arena_dl_Cube_001_mesh_layer_1_vtx_0() {
	int i = 0;
	int count = 26;
	int width = 32 * 0x20;
	int height = 32 * 0x20;

	static int currentX = 0;
	int deltaX;
	static int currentY = 0;
	int deltaY;
	Vtx *vertices = segmented_to_virtual(arena_dl_Cube_001_mesh_layer_1_vtx_0);

	deltaX = (int)(100.0 * 0x20) % width;
	deltaY = (int)(100.0 * 0x20) % height;

	if (absi(currentX) > width) {
		deltaX -= (int)(absi(currentX) / width) * width * signum_positive(deltaX);
	}
	if (absi(currentY) > height) {
		deltaY -= (int)(absi(currentY) / height) * height * signum_positive(deltaY);
	}

	for (i = 0; i < count; i++) {
		vertices[i].n.tc[0] += deltaX;
		vertices[i].n.tc[1] += deltaY;
	}
	currentX += deltaX;	currentY += deltaY;
}

void scroll_gfx_mat_arena_dl_f3dlite_material_001() {
	Gfx *mat = segmented_to_virtual(mat_arena_dl_f3dlite_material_001);

	shift_s(mat, 13, PACK_TILESIZE(0, 20));

};

void scroll_arena() {
	scroll_arena_dl_Circle_002_mesh_layer_1_vtx_0();
	scroll_arena_dl_Cube_001_mesh_layer_1_vtx_0();
	scroll_gfx_mat_arena_dl_f3dlite_material_001();
};
