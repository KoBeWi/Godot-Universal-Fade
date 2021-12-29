# <img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/Icon.png" width="64" height="64"> Godot Universal Fade

Universal Fade does 2 things:
- fades out
- fades in

That's it. You can use it however you need and easily so. To fade out, you do:
```GDScript
Fade.fade_out(time)
```
And your screen will fade out to black using simple fade effect. All magic like instancing effect nodes etc. happens automatically, you just call one method. The effect appears at CanvasLayer 100 and covers entire screen (adjusting automatically to its size).

When your screen is faded out, you can do:
```GDScript
Fade.fade_in(time)
```
And it will return to normal.

## How to scene transition

Fading out and in is cool and all, but you probably want to use it. The most common usage is scene transiton. You can use this piece of code:
```GDSCript
yield(Fade.fade_out(time), "finished")
get_tree().change_scene(new_scene)
Fade.fade_in(time)
```
`fade_out()` and `fade_in()` will return instance of Fade node. It emits `finished` signal when the effect ends. In case of fade in, the node is automatically freed at the end. In case of fade out, the node stays. You need to remove it yourself (using the reference you obtained) or do a fade in, which will remove it automatically.

You can pause the game while fading. The Fade node will process normally during pause.

## Additional stuff

Fade methods come with a few parameters. They are:

- `color` - color to fade to. By default it's black
- `pattern` - pattern used for the effect. See "Patterns" section. If empty string is passed (default), there will be no pattern. The patterns are located in `addons/UniversalFade` folder. For argument, your provide the part of the name that comes after "Pattern", e.g. "Diamond" to use "PatternDiamond.png".
- `reverse` - if true, pattern will be reversed
- `smooth` - if true, the pattern will have smoothed alpha

## Patterns

Probably the most cool thing about this node. You can use patterns to spice up your fading effect. Here's example pattern:

![](https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeDiamondRough.gif)

Patterns are gradient of colors ranging from white to black. The node uses a shader effect that fades the colors gradually. When fading out, white color will disappear first. When fading in, black color will appear first. When you use the `reverse` argument, the order will be reversed. You can achieve the best effect when fade in and fade out use different `reverse`.

The smooth will smoothen your alpha, i.e. the colors will fade gradually instead of being sharp. Here's a comparison between smoothed and non-smoothed fade (same pattern):

<img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeHorizontalSmooth.gif" width="320"><img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeHorizontalRough.gif" width="320">

## Included patterns

Universal Fade comes with several built-in patterns. Unfortunately I'm not good in making them, so half of them are just simple gradients. The Diamond pattern is kinda borrowed from RPG Maker, please don't tell anyone, thx.

You can easily add custom patterns to the UniversalFade directory. The included patterns are all `1920x1080` in size. The pattern will fit to screen anyways, but you might want to match the proportions, so they don't appear distorted. btw if you made a cool fade pattern and want to contribute it here, open an issue and attach the image. You will be credited here if it gets included :)

### List of patterns

(I only include either smoothed or non-smoothed preview)

- Diagonal (smoothed)

<img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeDiagonalSmooth.gif" width="320">

- Diamond (not smoothed)

<img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeDiamondRough.gif" width="320">

- GradientHorizontal (smoothed)

<img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeHorizontalSmooth.gif" width="320">

- GradientVertical (smoothed)

<img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeVerticalSmooth.gif" width="320">

- Noise (not smoothed)

<img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeNoiseRough.gif" width="320">

- Swirl (not smoothed)

<img src="https://github.com/KoBeWi/Godot-Universal-Fade/blob/master/Media/ReadmeSwirlRough.gif" width="320">
