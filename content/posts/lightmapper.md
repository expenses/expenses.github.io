+++
title = 'Writing a lightmapper in 2026'
date = 2026-05-07T00:00:00Z
+++

### Intro

For certain kinds of static scenes, baked lightmaps still offer the best lighting quality outside of full path tracing. A few things I've been playing recently have included gorgeous baked lighting, including the [Quake QBJ3 mod](https://www.youtube.com/watch?v=b0MIbo2aQqs&t=52s) and Dishonored 2. I've been toying with a few game engines over the past few months and the one that suits my sensibilities most is Godot. Unfortunately, Godot's lightmapper isn't very good. I don't quite have time to get into the specifics of its issues here, so I'll just quote the [priorities page](https://godotengine.org/priorities/):

> Overhaul `LightmapGI` to improve baking workflow, performance, and features
> 
> `LightmapGI` needs a lot of polish and improvements for us to meet the goals we have set for it. Baking times are slower than we want and it often takes too much manual effort to get bakes to achieve the quality that users need.

I thought I'd try writing a new lightmapper. Creating a new lightmapper module within the Godot source code is the eventual goal, but for iteration speed I decided to use my own rendering framework. The workflow goes something like this:

<p style = "text-align: center;">
<img src = "/assets/process.svg" style = "width: 30%;">
</p>

A few notes on elements I won't cover in detail:
- I'm using [xatlas](https://github.com/jpcy/xatlas) to generate lightmap UVs inside Blender via a Python extension. This is better than using the built in operations for packing UVs, as it uses actual pixel values for things like padding instead of arbitrary fractions. One key detail is that xatlas generates an atlas at a specific resolution (the one I've been testing with is 1727x1745) and the final lightmap should use this size. Trying to scale that up to e.g. 2048x2048 will shift all the UVs that previously sat squarely on texel centers.
- The dilation process is very simple. For texels with invalid values, set them to the average of the valid values of their 8 neighbours.
- For the purpose of producing example images, I'm just tracing rays within a cosine-weighted hemisphere and accumulating a value if they don't hit anything.
- All ray tracing is done using Vulkan ray queries.

### Overlapping geometry

Provided that the atlas size recommended by xatlas is used and dilation is applied, the output can already be quite good even without supersampling. Here is a gif showing the impact of dilation:

<p style = "text-align: center;">
<img src = "/assets/dilation.gif" style = "width: 75%;">
</p>

However, there is still a problem with the rooftop structure. Looking at the lightmap, the issue is fairly obvious.

<p style = "text-align: center;">
<img src = "/assets/overlapping.png" style = "width: 75%;">
</p>

There's a sharp discontinuity where sample points under the building are black while their neighbours are fairly bright. This is a fairly well-known issue with lightmappers. Assuming that your geometry is generally single-sided, rays from these sample points will hit backfaces, which makes the problem easier to think about.

[Precomputed Global Illumination in Frostbite](https://media.contentapi.ea.com/content/dam/eacom/frostbite/files/gdc2018-precomputedgiobalilluminationinfrostbite.pdf) tracks the number of rays per texel that hit backfaces and discards the value if the percentage is over 50%. This probably works, but it's inelegant, requires updating a tracking variable and firing rays for a large number of texels only to discard their results later.

I've based my solution to this on [Baking artifact-free lightmaps on the GPU](https://ndotl.wordpress.com/2018/08/29/baking-artifact-free-lightmaps/) by the author of Unity's Bakery plugin. Their fix involves tracing tangential rays from each sample point, checking whether it hits a backface, and pushing the sample point out of the shadowed area if so. This final bit was tricky to get right, so I instead chose to simply discard any sample points that hit backfaces and allow them to be filled in by the dilation step.

The ray distance used for this is important: it has to be at least twice the world-space distance between two texels so that only the values on one side of a face get used in the dilation step. See the gif below if that's unclear; a tiny gap would result in the middle section being filled in with a grey value, reducing the issue but not eliminating it. It'd be best to do this step as part of rasterization and use the `ddx`/`ddx` of the position multiplied by 3 or so. I'm using a hard-coded value of 1 meter which works fine for my scene.

<p style = "text-align: center;">
<img src = "/assets/backfaces.gif" style = "width: 75%;">
</p>

### Supersampling

Supersampling isn't as important as I initially thought it would be, but it's still nice for producing smoother results and minimizing issues caused by really small geometry. The previously mentioned Frostbite paper uses 64 sample points per texel and I don't see a reason to go lower than that. The naïve approach is to just rasterize the lightmaps at 8x, but I'm on an AMD system and [have a 16k viewport size limit](https://vulkan.gpuinfo.org/displaydevicelimit.php?name=maxViewportDimensions[0]&platform=all) meaning that I'd be limited to a final lightmap resolution of 2048x2048 (without getting into fairly hacky stuff like rasterizing in tiles).

In addition, there might be slight advantages to having sample points placed not on a grid but via a low discrepancy sequence.

My code at present creates an acceleration structure from the lightmap UVs and ray-traces it top-down, 64 times per texel to generate a buffer containing triangle IDs. This is inefficient but made sense in testing, sidesteps the rasterization limits, and has the slight advantage of only requiring a compute pipeline. I'm generating per-texel offsets via the [R2 sequence](https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/):

```c
float2 R2(int index)
{
	static const float g  = 1.32471795724474602596f;
	static const float a1 = 1 / g;
	static const float a2 = 1 / (g * g);
	return float2(frac(float(index) * a1), frac(float(index) * a2));
}
```

A better solution is most likely to use a 2D array texture with 64 layers and issue 64 draw calls with similar per-texel offsets.

When lightmapping I pick a random sample point per texel and trace rays from there. The issue with this is that only _valid_ sample points should be chosen. If not, invalid locations will need to be discarded, creating darker outputs at areas such as the seams of UV islands.

<p style = "text-align: center;">
<img src = "/assets/comparison2.gif" style = "width: 75%;">
</p>

My solution is to create a 64-bit bitmask of valid sample points per texel and select a random 1 bit. Alternatively one could store just an 8-bit valid count, or use no storage at all and reservoir sample the valid locations. In a classic example of graphics programming vagueposting, the Frostbite paper mentions 'per-texel lists' of valid sample points. This is presumably something similar.

### Importance sampling

One of the missing features from the Godot lightmapper that I wanted to add was high-quality environment map lighting. Environment maps featuring the sun are a classic case where importance sampling is essential as almost all the light originates from a single area. Even with 1024 hemisphere samples, this is nowhere close to converging:

<p style = "text-align: center;">
<img src = "/assets/sampling.png" style = "width: 75%;">
</p>

I chose to write a small library for generating alias tables for importance sampling, [based on this blog post](https://idarago.github.io/the-alias-method/). The generation code is quite simple; divide values into those above and below the mean, then spread the excess sampling weight from high values onto low values via aliases. The API looks like this: 

```rust
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Alias {
    pub threshold: f32,
    pub inv_pdf: f32,
    pub fallback: u32,
}

pub fn construct<I: IntoIterator<Item = (f32, f32)>>(values: I) -> Vec<Alias>;
```

For historical reasons, I'm using the inverse of the pdf (1/pdf). I should change this in the future. The first iterator value is the sample weight, while the second is a multiplier of the final `inv_pdf`.

The alias table for an environment map is constructed like so:

```rust
alias_table::construct(envmap.rows().enumerate().flat_map(|(row, pixels)| {
	use std::f32::consts::PI;

	let height = envmap.height() as usize;
	let theta = PI * (row as f32 + 0.5) / height as f32;
	let sin_theta = theta.sin();
	pixels.map(move |p| {
		use image::Pixel;
		(p.to_luma()[0] * sin_theta, sin_theta * 2.0 * PI * PI)
	})
}))
```

The first `sin_theta` factor accounts for the fact that a texel near the poles covers a smaller solid angle than one at the equator, correcting the sampling probability. The second accounts for the fact that the environment map itself isn't being modified so values calculated with `envmap_value * alias.inv_pdf` would otherwise get higher towards the poles. Ensuring that `alias.inv_pdf` is multiplied by `sin_theta` cancels this out.

#### Multiple Importance Sampling

I want to incorporate both direct and indirect lighting. For indirect lighting I shoot a ray uniformly within a hemisphere (I'm not using cosine-weighted hemisphere sampling so it's easier to do spherical harmonics stuff) and evaluate the bounced lighting at the hit point. But what if this ray misses and goes out into the environment map? I could just discard it, but that's wasteful. Multiple importance sampling can be used to combine this hemisphere sample with the light sample from earlier.

This turned out to be easier to implement than I expected. In both the `get_direct_env_map_lighting` and `get_env_map_lighting_for_direction` functions I plug the sample pdf and constant `1.0 / (2.0 * PI)` hemisphere pdf into the MIS power heuristic:

```c
float mis_power_heuristic(float current_pdf, float other_pdf) {
    let current_pdf_2 = current_pdf * current_pdf;
    let other_pdf_2 = other_pdf * other_pdf;
    return current_pdf_2 / (current_pdf_2 + other_pdf_2);
}
```

This suppresses hemisphere-sampled values proportionally to their importance, eliminating fireflies while still converging faster than importance sampling alone.

<p style = "text-align: center;">
<img src = "/assets/importance.gif" style = "width: 75%;">
</p>
