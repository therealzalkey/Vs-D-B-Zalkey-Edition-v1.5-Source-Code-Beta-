package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var bgDetail:FlxSprite;
	var bgShade:FlxSprite;

	var debugKeys:Array<FlxKey>;

	var gfDance:FlxSprite;      //to put the gf on the menu mme

	var danceLeft:Bool = false;


	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var bgScroll:FlxBackdrop = new FlxBackdrop(Paths.image('cubicbg'), 5, 5, true, true);
		bgScroll.scrollFactor.set();
		bgScroll.screenCenter();
		bgScroll.velocity.set(100, 100);
		bgScroll.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgScroll);
		
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bgCover:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('MenuCover'));
		bgCover.scrollFactor.set(0, yScroll);
		bgCover.setGraphicSize(Std.int(bg.width * 1.175));
		bgCover.updateHitbox();
		bgCover.screenCenter();
		bgCover.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgCover);
		
		bgShade = new FlxSprite().loadGraphic(Paths.image('Shade'));
		bgShade.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgShade);
		bgShade.screenCenter();

		bgDetail = new FlxSprite().loadGraphic(Paths.image('Detail'));
		bgDetail.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgDetail);
		bgDetail.screenCenter();

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

		for (i in 0...optionShit.length)

		// Story Mode

		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

		var menuItem:FlxSprite = new FlxSprite(100, 100);

		menuItem.scale.x = scale;

		menuItem.scale.y = scale;

		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[0]);

		menuItem.animation.addByPrefix('idle', optionShit[0] + " basic", 24);

		menuItem.animation.addByPrefix('selected', optionShit[0] + " white", 24);

		menuItem.animation.play('idle');

		menuItem.ID = 0;

		menuItem.setGraphicSize(Std.int(menuItem.width * 0.70));

		// menuItem.screenCenter(X);

		menuItems.add(menuItem);

		var scr:Float = (optionShit.length - 4) * 0.135;

		if(optionShit.length < 6) scr = 0;

		menuItem.scrollFactor.set(0, scr);

		menuItem.antialiasing = ClientPrefs.globalAntialiasing;

		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));

		menuItem.updateHitbox();

		// FreePlay Mode

		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

		var menuItem:FlxSprite = new FlxSprite(100, 250);

		menuItem.scale.x = scale;

		menuItem.scale.y = scale;

		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[1]);

		menuItem.animation.addByPrefix('idle', optionShit[1] + " basic", 24);

		menuItem.animation.addByPrefix('selected', optionShit[1] + " white", 24);

		menuItem.animation.play('idle');

		menuItem.ID = 1;

		menuItem.setGraphicSize(Std.int(menuItem.width * 0.70));

		// menuItem.screenCenter(X);

		menuItems.add(menuItem);

		var scr:Float = (optionShit.length - 4) * 0.135;

		if(optionShit.length < 6) scr = 1;

		menuItem.scrollFactor.set(1, scr);

		menuItem.antialiasing = ClientPrefs.globalAntialiasing;

		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));

		menuItem.updateHitbox();

		// Credits

		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

		var menuItem:FlxSprite = new FlxSprite(100, 400);

		menuItem.scale.x = scale;

		menuItem.scale.y = scale;

		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[2]);

		menuItem.animation.addByPrefix('idle', optionShit[2] + " basic", 24);

		menuItem.animation.addByPrefix('selected', optionShit[2] + " white", 24);

		menuItem.animation.play('idle');

		menuItem.ID = 2;

		menuItem.setGraphicSize(Std.int(menuItem.width * 0.70));

		// menuItem.screenCenter(X);

		menuItems.add(menuItem);

		var scr:Float = (optionShit.length - 4) * 0.135;

		if(optionShit.length < 6) scr = 2;

		menuItem.scrollFactor.set(2, scr);

		menuItem.antialiasing = ClientPrefs.globalAntialiasing;

		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));

		menuItem.updateHitbox();

		// Options

		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;

		var menuItem:FlxSprite = new FlxSprite(100, 550);

		menuItem.scale.x = scale;

		menuItem.scale.y = scale;

		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[3]);

		menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);

		menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);

		menuItem.animation.play('idle');

		menuItem.ID = 3;

		menuItem.setGraphicSize(Std.int(menuItem.width * 0.70));

		// menuItem.screenCenter(X);

		menuItems.add(menuItem);

		var scr:Float = (optionShit.length - 4) * 0.135;

		if(optionShit.length < 6) scr = 3;

		menuItem.scrollFactor.set(3, scr);

		menuItem.antialiasing = ClientPrefs.globalAntialiasing;

		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));

		menuItem.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);

			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');

			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, true);

			add(gfDance);

			if(gfDance != null) {
				danceLeft = !danceLeft;

				if (danceLeft) {
					gfDance.animation.play('danceLeft');
				}

			}

		//FlxG.camera.follow(camFollowPos, null, 1);

		// load the cog ready to be used
		// var cog = new FlxSprite(); // add cog character
		// cog.loadGraphic(Paths.image('menuicons/cog'));
		// add(cog);
		// cog.x = 800;
		// cog.y = -130;

		// char1 = new Character(500, -130, 'bf2', true);
		// char1.setGraphicSize(Std.int(char1.width * 0.8 / 2));
		// add(char1);
		// char1.visible = true;
		// char1.dance();

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Epitome Bambi Retake", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Psych Engine v0.6.3", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		// if (optionShit[curSelected] == 'options') {
		// 	add(cog);
		// } else {
		// 	cog.kill();
		// }

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplaySelectState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
