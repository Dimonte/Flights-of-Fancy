package ;

import actionCore.Game;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.Lib;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class Main extends Sprite 
{
	var inited:Bool;
	var game:Game;
	var titleScreen:Sprite;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
		
		createGame();
		
		addChild(game);
		
		addChild(new FPS(10, 200 * stage.stageHeight / 1080 , 0x336633));
		
		var controlsHint:Bitmap = new Bitmap(Assets.getBitmapData("img/controls_hint.png"));
		controlsHint.scaleX = controlsHint.scaleY = stage.stageHeight / controlsHint.height;
		controlsHint.x = stage.stageWidth - controlsHint.width;
		addChild(controlsHint);
		
		var retrySprite:Sprite = new Sprite();
		var retryBitmap:Bitmap = new Bitmap(Assets.getBitmapData("img/retry.png"));
		retryBitmap.smoothing = true;
		retrySprite.addChild(retryBitmap);
		retrySprite.scaleX = retrySprite.scaleY = stage.stageHeight / 1080 * 0.75;
		addChild(retrySprite);
		retrySprite.addEventListener(MouseEvent.CLICK, retrySprite_clickHandler);
		
		titleScreen = new Sprite();
		var modalBG:Sprite = new Sprite();
		modalBG.graphics.beginFill(0x0, 0.4);
		modalBG.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		modalBG.graphics.endFill();
		titleScreen.addChild(modalBG);
		
		var startButton:Sprite = new Sprite();
		var startBitmap:Bitmap = new Bitmap(Assets.getBitmapData("img/start.png"));
		startButton.addChild(startBitmap);
		startButton.x = (stage.stageWidth - startBitmap.width) / 2;
		startButton.y = (stage.stageHeight - startBitmap.height) / 2;
		titleScreen.addChild(startButton);
		startButton.addEventListener(MouseEvent.CLICK, startButton_clickHandler);
		
		addChild(titleScreen);
	}
	
	private function startButton_clickHandler(e:MouseEvent):Void 
	{
		game.start();
		titleScreen.visible = false;
	}
	
	private function retrySprite_clickHandler(e:MouseEvent):Void 
	{
		removeChild(game);
		createGame();
		addChildAt(game, 0);
		titleScreen.visible = true;
	}
	
	function createGame() 
	{
		var viewport:Rectangle = new Rectangle();
		if (stage.stageWidth > 1920 && false)
		{
			viewport.width = stage.stageWidth / 2;
			viewport.height = stage.stageHeight / 2;
			viewport.x = 2;
		}
		else 
		{
			viewport.width = stage.stageWidth;
			viewport.height = stage.stageHeight;
			viewport.x = 1;
		}
		game = new Game(Std.int(viewport.width), Std.int(viewport.height));
		//game.scaleX = game.scaleY = viewport.x;
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
