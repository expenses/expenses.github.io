+++
title = 'sRGB Notes'
date = 2025-10-03T00:00:00Z
+++

_I wrote these notes in order to have an easy resource to link people involved in graphics work to. For a more in-depth overflow on digital color, read all of [The Hitchhiker's Guide to Digital Color](https://hg2dc.com/), starting with question 1._

# Notes

- sRGB (standard RGB) is this thing called a 'color space', but is also a means of compressing image data.
- A way to store color information at 8-bits per color channel (red, green, blue) is desired as 32 or even 16 bits per channel is too high.
- sRGB uses a compromise where brightness values (0.0 to 1.0) are stored non-linearly. 128 != 0.5.
- The function is roughly (but not exactly) x^2.4, so for 128 you have (128/256)^2.4 = 0.189. Half the bit space is dedicated to values less than 0.2. Conversely, there are only 128 values for 0.2 to 1.0.
- This is because it's easier to see the difference in monitor brightness between e.g. 0-0.05 than 0.95-1.
- sRGB is used for all color JPEG, PNG, etc images. For extremely rare non-color purposes (e.g. normal maps for 3d models) linear 8-bit values are stored instead where 128 should be used as 0.5.
- Monitors generally accept sRGB-encoded data.
- using a SRGB GPU texture format means that the linear-to-sRGB and sRGB-to-linear transfer functions are automatically applied when reading and writing. Sometimes you want/need to perform the transfer functions yourself instead and have sRGB-data in a SRGB texture.
- in a shader, there is no loss of data when going from sRGB texture (think of a greyscale 256 by 1 texture consisting of 256 brightness levels) to sRGB texture as the sRGB-to-linear transfer function is applied and then perfectly inverted again. Same with non-sRGB data to non-sRGB data.
- there IS going to be loss of data going from non-sRGB or sRGB or sRGB to non-sRGB as some of the stops will need to be rounded when converting to 8-bit again.

# Digital Color Pipeline

If you take a photo with a digital camera and then display it on a web page, the pipeline goes something like this:

<svg width="802pt" height="1253pt" viewBox="0.00 0.00 801.95 1252.53" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1 1) rotate(0) translate(4 1248.5281)">
<title>g</title>
<polygon fill="#ffffff" stroke="transparent" points="-4,4 -4,-1248.5281 797.9545,-1248.5281 797.9545,4 -4,4"/>
<!-- Light IRL\nformat: photons of various wavelengths -->
<g id="node1" class="node">
<title>Light IRL\nformat: photons of various wavelengths</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-1215.1125" rx="168.6344" ry="29.3315"/>
<text text-anchor="middle" x="396.9772" y="-1219.3125" font-family="Times,serif" font-size="14.00" fill="#000000">Light IRL</text>
<text text-anchor="middle" x="396.9772" y="-1202.5125" font-family="Times,serif" font-size="14.00" fill="#000000">format: photons of various wavelengths</text>
</g>
<!-- Camera Sensor\nHits Bayer filter, converted to RGB triplet\nformat: RGB of some kind -->
<g id="node2" class="node">
<title>Camera Sensor\nHits Bayer filter, converted to RGB triplet\nformat: RGB of some kind</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-1108.4018" rx="178.9702" ry="41.0911"/>
<text text-anchor="middle" x="396.9772" y="-1121.0018" font-family="Times,serif" font-size="14.00" fill="#000000">Camera Sensor</text>
<text text-anchor="middle" x="396.9772" y="-1104.2018" font-family="Times,serif" font-size="14.00" fill="#000000">Hits Bayer filter, converted to RGB triplet</text>
<text text-anchor="middle" x="396.9772" y="-1087.4018" font-family="Times,serif" font-size="14.00" fill="#000000">format: RGB of some kind</text>
</g>
<!-- Light IRL\nformat: photons of various wavelengths&#45;&gt;Camera Sensor\nHits Bayer filter, converted to RGB triplet\nformat: RGB of some kind -->
<g id="edge1" class="edge">
<title>Light IRL\nformat: photons of various wavelengths-&gt;Camera Sensor\nHits Bayer filter, converted to RGB triplet\nformat: RGB of some kind</title>
<path fill="none" stroke="#000000" d="M396.9772,-1185.6709C396.9772,-1177.6896 396.9772,-1168.8082 396.9772,-1159.9912"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-1159.7281 396.9772,-1149.7281 393.4773,-1159.7282 400.4773,-1159.7281"/>
</g>
<!-- Camera Raw\nformat: RGB, basically unprocessed from sensor -->
<g id="node3" class="node">
<title>Camera Raw\nformat: RGB, basically unprocessed from sensor</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-1001.6911" rx="204.0911" ry="29.3315"/>
<text text-anchor="middle" x="396.9772" y="-1005.8911" font-family="Times,serif" font-size="14.00" fill="#000000">Camera Raw</text>
<text text-anchor="middle" x="396.9772" y="-989.0911" font-family="Times,serif" font-size="14.00" fill="#000000">format: RGB, basically unprocessed from sensor</text>
</g>
<!-- Camera Sensor\nHits Bayer filter, converted to RGB triplet\nformat: RGB of some kind&#45;&gt;Camera Raw\nformat: RGB, basically unprocessed from sensor -->
<g id="edge2" class="edge">
<title>Camera Sensor\nHits Bayer filter, converted to RGB triplet\nformat: RGB of some kind-&gt;Camera Raw\nformat: RGB, basically unprocessed from sensor</title>
<path fill="none" stroke="#000000" d="M396.9772,-1066.8391C396.9772,-1058.5274 396.9772,-1049.8137 396.9772,-1041.5607"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-1041.4182 396.9772,-1031.4182 393.4773,-1041.4183 400.4773,-1041.4182"/>
</g>
<!-- Jpeg\nHeavily processed, demosaicing etc.\nformat: 8&#45;bit sRGB -->
<g id="node4" class="node">
<title>Jpeg\nHeavily processed, demosaicing etc.\nformat: 8-bit sRGB</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-894.9805" rx="155.7552" ry="41.0911"/>
<text text-anchor="middle" x="396.9772" y="-907.5805" font-family="Times,serif" font-size="14.00" fill="#000000">Jpeg</text>
<text text-anchor="middle" x="396.9772" y="-890.7805" font-family="Times,serif" font-size="14.00" fill="#000000">Heavily processed, demosaicing etc.</text>
<text text-anchor="middle" x="396.9772" y="-873.9805" font-family="Times,serif" font-size="14.00" fill="#000000">format: 8-bit sRGB</text>
</g>
<!-- Camera Raw\nformat: RGB, basically unprocessed from sensor&#45;&gt;Jpeg\nHeavily processed, demosaicing etc.\nformat: 8&#45;bit sRGB -->
<g id="edge3" class="edge">
<title>Camera Raw\nformat: RGB, basically unprocessed from sensor-&gt;Jpeg\nHeavily processed, demosaicing etc.\nformat: 8-bit sRGB</title>
<path fill="none" stroke="#000000" d="M396.9772,-972.2495C396.9772,-964.2682 396.9772,-955.3869 396.9772,-946.5698"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-946.3068 396.9772,-936.3068 393.4773,-946.3068 400.4773,-946.3068"/>
</g>
<!-- GPU Texture\nDecompressed and extended with an alpha channel\nformat: RGBA8_SRGB -->
<g id="node5" class="node">
<title>GPU Texture\nDecompressed and extended with an alpha channel\nformat: RGBA8_SRGB</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-776.3904" rx="213.7495" ry="41.0911"/>
<text text-anchor="middle" x="396.9772" y="-788.9904" font-family="Times,serif" font-size="14.00" fill="#000000">GPU Texture</text>
<text text-anchor="middle" x="396.9772" y="-772.1904" font-family="Times,serif" font-size="14.00" fill="#000000">Decompressed and extended with an alpha channel</text>
<text text-anchor="middle" x="396.9772" y="-755.3904" font-family="Times,serif" font-size="14.00" fill="#000000">format: RGBA8_SRGB</text>
</g>
<!-- Jpeg\nHeavily processed, demosaicing etc.\nformat: 8&#45;bit sRGB&#45;&gt;GPU Texture\nDecompressed and extended with an alpha channel\nformat: RGBA8_SRGB -->
<g id="edge4" class="edge">
<title>Jpeg\nHeavily processed, demosaicing etc.\nformat: 8-bit sRGB-&gt;GPU Texture\nDecompressed and extended with an alpha channel\nformat: RGBA8_SRGB</title>
<path fill="none" stroke="#000000" d="M396.9772,-853.5034C396.9772,-845.3359 396.9772,-836.6712 396.9772,-828.2126"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-828.0444 396.9772,-818.0445 393.4773,-828.0445 400.4773,-828.0444"/>
</g>
<!-- Shader Code\nConverted from 8&#45;bit to float, linearized and sampled (all done by hardware)\nformat: 32&#45;bit float -->
<g id="node6" class="node">
<title>Shader Code\nConverted from 8-bit to float, linearized and sampled (all done by hardware)\nformat: 32-bit float</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-657.8003" rx="314.5814" ry="41.0911"/>
<text text-anchor="middle" x="396.9772" y="-670.4003" font-family="Times,serif" font-size="14.00" fill="#000000">Shader Code</text>
<text text-anchor="middle" x="396.9772" y="-653.6003" font-family="Times,serif" font-size="14.00" fill="#000000">Converted from 8-bit to float, linearized and sampled (all done by hardware)</text>
<text text-anchor="middle" x="396.9772" y="-636.8003" font-family="Times,serif" font-size="14.00" fill="#000000">format: 32-bit float</text>
</g>
<!-- GPU Texture\nDecompressed and extended with an alpha channel\nformat: RGBA8_SRGB&#45;&gt;Shader Code\nConverted from 8&#45;bit to float, linearized and sampled (all done by hardware)\nformat: 32&#45;bit float -->
<g id="edge5" class="edge">
<title>GPU Texture\nDecompressed and extended with an alpha channel\nformat: RGBA8_SRGB-&gt;Shader Code\nConverted from 8-bit to float, linearized and sampled (all done by hardware)\nformat: 32-bit float</title>
<path fill="none" stroke="#000000" d="M396.9772,-734.9133C396.9772,-726.7458 396.9772,-718.0811 396.9772,-709.6225"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-709.4544 396.9772,-699.4544 393.4773,-709.4544 400.4773,-709.4544"/>
</g>
<!-- GPU Surface Texture\nConverted back into 8&#45;bit sRGB (either done by hardware or software (e.g. in a compute shader))\nformat: RGBA8_SRGB -->
<g id="node7" class="node">
<title>GPU Surface Texture\nConverted back into 8-bit sRGB (either done by hardware or software (e.g. in a compute shader))\nformat: RGBA8_SRGB</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-539.2102" rx="396.9545" ry="41.0911"/>
<text text-anchor="middle" x="396.9772" y="-551.8102" font-family="Times,serif" font-size="14.00" fill="#000000">GPU Surface Texture</text>
<text text-anchor="middle" x="396.9772" y="-535.0102" font-family="Times,serif" font-size="14.00" fill="#000000">Converted back into 8-bit sRGB (either done by hardware or software (e.g. in a compute shader))</text>
<text text-anchor="middle" x="396.9772" y="-518.2102" font-family="Times,serif" font-size="14.00" fill="#000000">format: RGBA8_SRGB</text>
</g>
<!-- Shader Code\nConverted from 8&#45;bit to float, linearized and sampled (all done by hardware)\nformat: 32&#45;bit float&#45;&gt;GPU Surface Texture\nConverted back into 8&#45;bit sRGB (either done by hardware or software (e.g. in a compute shader))\nformat: RGBA8_SRGB -->
<g id="edge6" class="edge">
<title>Shader Code\nConverted from 8-bit to float, linearized and sampled (all done by hardware)\nformat: 32-bit float-&gt;GPU Surface Texture\nConverted back into 8-bit sRGB (either done by hardware or software (e.g. in a compute shader))\nformat: RGBA8_SRGB</title>
<path fill="none" stroke="#000000" d="M396.9772,-616.3233C396.9772,-608.1557 396.9772,-599.491 396.9772,-591.0324"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-590.8643 396.9772,-580.8643 393.4773,-590.8644 400.4773,-590.8643"/>
</g>
<!-- Driver &amp; HDMI/DisplayPort cable\nformat: presumably still sRGB but driver specific -->
<g id="node8" class="node">
<title>Driver &amp; HDMI/DisplayPort cable\nformat: presumably still sRGB but driver specific</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-432.4996" rx="207.7157" ry="29.3315"/>
<text text-anchor="middle" x="396.9772" y="-436.6996" font-family="Times,serif" font-size="14.00" fill="#000000">Driver &amp; HDMI/DisplayPort cable</text>
<text text-anchor="middle" x="396.9772" y="-419.8996" font-family="Times,serif" font-size="14.00" fill="#000000">format: presumably still sRGB but driver specific</text>
</g>
<!-- GPU Surface Texture\nConverted back into 8&#45;bit sRGB (either done by hardware or software (e.g. in a compute shader))\nformat: RGBA8_SRGB&#45;&gt;Driver &amp; HDMI/DisplayPort cable\nformat: presumably still sRGB but driver specific -->
<g id="edge7" class="edge">
<title>GPU Surface Texture\nConverted back into 8-bit sRGB (either done by hardware or software (e.g. in a compute shader))\nformat: RGBA8_SRGB-&gt;Driver &amp; HDMI/DisplayPort cable\nformat: presumably still sRGB but driver specific</title>
<path fill="none" stroke="#000000" d="M396.9772,-497.6476C396.9772,-489.3358 396.9772,-480.6221 396.9772,-472.3691"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-472.2266 396.9772,-462.2267 393.4773,-472.2267 400.4773,-472.2266"/>
</g>
<!-- Monitor\nDecoded, linearized, used to light LEDs as a fraction of max brightness -->
<g id="node9" class="node">
<title>Monitor\nDecoded, linearized, used to light LEDs as a fraction of max brightness</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-337.6683" rx="294.3639" ry="29.3315"/>
<text text-anchor="middle" x="396.9772" y="-341.8683" font-family="Times,serif" font-size="14.00" fill="#000000">Monitor</text>
<text text-anchor="middle" x="396.9772" y="-325.0683" font-family="Times,serif" font-size="14.00" fill="#000000">Decoded, linearized, used to light LEDs as a fraction of max brightness</text>
</g>
<!-- Driver &amp; HDMI/DisplayPort cable\nformat: presumably still sRGB but driver specific&#45;&gt;Monitor\nDecoded, linearized, used to light LEDs as a fraction of max brightness -->
<g id="edge8" class="edge">
<title>Driver &amp; HDMI/DisplayPort cable\nformat: presumably still sRGB but driver specific-&gt;Monitor\nDecoded, linearized, used to light LEDs as a fraction of max brightness</title>
<path fill="none" stroke="#000000" d="M396.9772,-403.0142C396.9772,-394.8968 396.9772,-385.9571 396.9772,-377.365"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-377.1354 396.9772,-367.1354 393.4773,-377.1355 400.4773,-377.1354"/>
</g>
<!-- Light IRL again\nformat: still photons -->
<g id="node10" class="node">
<title>Light IRL again\nformat: still photons</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-242.837" rx="91.7112" ry="29.3315"/>
<text text-anchor="middle" x="396.9772" y="-247.037" font-family="Times,serif" font-size="14.00" fill="#000000">Light IRL again</text>
<text text-anchor="middle" x="396.9772" y="-230.237" font-family="Times,serif" font-size="14.00" fill="#000000">format: still photons</text>
</g>
<!-- Monitor\nDecoded, linearized, used to light LEDs as a fraction of max brightness&#45;&gt;Light IRL again\nformat: still photons -->
<g id="edge9" class="edge">
<title>Monitor\nDecoded, linearized, used to light LEDs as a fraction of max brightness-&gt;Light IRL again\nformat: still photons</title>
<path fill="none" stroke="#000000" d="M396.9772,-308.1829C396.9772,-300.0655 396.9772,-291.1258 396.9772,-282.5337"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-282.3041 396.9772,-272.3041 393.4773,-282.3042 400.4773,-282.3041"/>
</g>
<!-- Human Eye\nLots of complex biology stuff. Absorbed by rods &amp; cones\nformat: ??? -->
<g id="node11" class="node">
<title>Human Eye\nLots of complex biology stuff. Absorbed by rods &amp; cones\nformat: ???</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-136.1263" rx="240.1148" ry="41.0911"/>
<text text-anchor="middle" x="396.9772" y="-148.7263" font-family="Times,serif" font-size="14.00" fill="#000000">Human Eye</text>
<text text-anchor="middle" x="396.9772" y="-131.9263" font-family="Times,serif" font-size="14.00" fill="#000000">Lots of complex biology stuff. Absorbed by rods &amp; cones</text>
<text text-anchor="middle" x="396.9772" y="-115.1263" font-family="Times,serif" font-size="14.00" fill="#000000">format: ???</text>
</g>
<!-- Light IRL again\nformat: still photons&#45;&gt;Human Eye\nLots of complex biology stuff. Absorbed by rods &amp; cones\nformat: ??? -->
<g id="edge10" class="edge">
<title>Light IRL again\nformat: still photons-&gt;Human Eye\nLots of complex biology stuff. Absorbed by rods &amp; cones\nformat: ???</title>
<path fill="none" stroke="#000000" d="M396.9772,-213.3954C396.9772,-205.4141 396.9772,-196.5327 396.9772,-187.7157"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-187.4526 396.9772,-177.4527 393.4773,-187.4527 400.4773,-187.4526"/>
</g>
<!-- Brain\nformat: ??? -->
<g id="node12" class="node">
<title>Brain\nformat: ???</title>
<ellipse fill="none" stroke="#000000" cx="396.9772" cy="-29.4156" rx="56.22" ry="29.3315"/>
<text text-anchor="middle" x="396.9772" y="-33.6156" font-family="Times,serif" font-size="14.00" fill="#000000">Brain</text>
<text text-anchor="middle" x="396.9772" y="-16.8156" font-family="Times,serif" font-size="14.00" fill="#000000">format: ???</text>
</g>
<!-- Human Eye\nLots of complex biology stuff. Absorbed by rods &amp; cones\nformat: ???&#45;&gt;Brain\nformat: ??? -->
<g id="edge11" class="edge">
<title>Human Eye\nLots of complex biology stuff. Absorbed by rods &amp; cones\nformat: ???-&gt;Brain\nformat: ???</title>
<path fill="none" stroke="#000000" d="M396.9772,-94.5636C396.9772,-86.2519 396.9772,-77.5382 396.9772,-69.2852"/>
<polygon fill="#000000" stroke="#000000" points="400.4773,-69.1427 396.9772,-59.1427 393.4773,-69.1428 400.4773,-69.1427"/>
</g>
</g>
</svg>

# Thought Experiment

If human beings had 4 types of cones instead of 3 (maybe one at ~600nm), what aspects of this pipeline would need to change?

# Graphvis Source

This is here mostly for my own benefit

```
digraph g {
"Light IRL\nformat: photons of various wavelengths" -> "Camera Sensor\nHits Bayer filter, converted to RGB triplet\nformat: RGB of some kind" -> "Camera Raw\nformat: RGB, basically unprocessed from sensor" -> "Jpeg\nHeavily processed, demosaicing etc.\nformat: 8-bit sRGB" -> "GPU Texture\nDecompressed and extended with an alpha channel\nformat: RGBA8_SRGB" -> "Shader Code\nConverted from 8-bit to float, linearized and sampled (all done by hardware)\nformat: 32-bit float" -> "GPU Surface Texture\nConverted back into 8-bit sRGB (either done by hardware or software (e.g. in a compute shader))\nformat: RGBA8_SRGB" -> "Driver & HDMI/DisplayPort cable\nformat: presumably still sRGB but driver specific" -> "Monitor\nDecoded, linearized, used to light LEDs as a fraction of max brightness" -> "Light IRL again\nformat: still photons" -> "Human Eye\nLots of complex biology stuff. Absorbed by rods & cones\nformat: ???" -> "Brain\nformat: ???"
}
```
