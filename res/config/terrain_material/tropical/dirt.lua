function data()
return {
	name = _("Dirt"),
	
	detailColorTexture = "terrain/dirt_albedo.dds",
	detailMetalGlossAoHTexture = "terrain/dirt_metal_gloss_ao_h.dds",
	detailNormalTexture = "terrain/dirt_nrml.dds",
	overlayTexture = "terrain/overlay_0.dds",

	detailSize = 1 / 32,
	overlaySize = 0.05,
	overlayStrength = 0.2,

	order = -1096,
	priority = 110000
}
end
